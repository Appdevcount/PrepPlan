# 08 — Observability: Logging, Metrics, Tracing

> **Mental Model:** Observability is the difference between flying blind and flying with instruments.
> Logs = what happened. Metrics = how often / how fast. Traces = where time was spent.
> You need all three. One without the others gives an incomplete picture at 3 AM.

---

## Structured Logging Rules

```csharp
// ── RULE: Always use structured logging — never string interpolation in log calls ──

// ❌ WRONG — string interpolation creates unqueryable blobs in Application Insights
_logger.LogInformation($"Order {orderId} placed by customer {customerId}");

// ✅ CORRECT — structured: orderId and customerId are searchable fields in Log Analytics
_logger.LogInformation(
    "Order {OrderId} placed by customer {CustomerId}",
    orderId, customerId);
// In Log Analytics: | where OrderId == "abc-123"  ← this works
// With interpolation: you'd need | where message contains "abc-123"  ← slow, fragile

// ── Log levels — use the right level ─────────────────────────────────────────
_logger.LogTrace("Entering method GetOrderById with id={OrderId}", id);             // dev only
_logger.LogDebug("Cache miss for order {OrderId}", id);                             // diagnostics
_logger.LogInformation("Order {OrderId} status changed to {Status}", id, status);  // normal events
_logger.LogWarning("Order {OrderId} retry {Count} of {Max}", id, attempt, max);    // recoverable
_logger.LogError(ex, "Failed to publish order event for {OrderId}", id);           // errors
_logger.LogCritical(ex, "Database connection pool exhausted");                      // urgent

// WHY LogWarning not LogError for retries: retries are expected and handled.
//   Errors should trigger alerts. Warnings are informational but worth tracking.

// ── Correlation context — inject into every log via scope ────────────────────
// (Set up by CorrelationIdMiddleware — see 03-api-development.md)
// Every log within a request automatically includes CorrelationId
using (_logger.BeginScope(new Dictionary<string, object>
{
    ["CorrelationId"] = correlationId,
    ["UserId"]        = userId,
    ["TenantId"]      = tenantId
}))
{
    // All logs inside this scope include these fields automatically
    await ProcessOrderAsync(orderId, ct);
}
```

---

## Logging Configuration

```csharp
// ── Program.cs — configure Serilog with Application Insights ─────────────────
builder.Host.UseSerilog((ctx, services, config) =>
{
    config
        .ReadFrom.Configuration(ctx.Configuration)    // appsettings log levels
        .ReadFrom.Services(services)                  // enrichers from DI
        .Enrich.FromLogContext()                       // WHY: picks up BeginScope properties
        .Enrich.WithMachineName()                     // useful in AKS (which pod?)
        .Enrich.WithEnvironmentName()
        .WriteTo.Console(
            outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {CorrelationId} {Message:lj}{NewLine}{Exception}")
        .WriteTo.ApplicationInsights(
            services.GetRequiredService<TelemetryConfiguration>(),
            TelemetryConverter.Traces);
});

// appsettings.json minimum level overrides
// {
//   "Serilog": {
//     "MinimumLevel": {
//       "Default": "Information",
//       "Override": {
//         "Microsoft.AspNetCore": "Warning",           // framework logs are noisy
//         "Microsoft.EntityFrameworkCore": "Warning"   // EF logs every SQL query — too much
//       }
//     }
//   }
// }
```

---

## OpenTelemetry — Distributed Tracing

```csharp
// WHY OpenTelemetry: vendor-neutral tracing. Works with Application Insights,
//   Jaeger, Zipkin, Datadog. Switch backends without changing application code.

builder.Services.AddOpenTelemetry()
    .WithTracing(tracing =>
    {
        tracing
            .SetResourceBuilder(ResourceBuilder.CreateDefault()
                .AddService("orders-api", serviceVersion: "1.0.0"))
            .AddAspNetCoreInstrumentation(opts =>
            {
                // WHY filter health checks: they create thousands of spans per day
                //   and add noise to distributed traces
                opts.Filter = ctx =>
                    !ctx.Request.Path.StartsWithSegments("/health");
            })
            .AddHttpClientInstrumentation()    // auto-traces all HttpClient calls
            .AddEntityFrameworkCoreInstrumentation(opts =>
            {
                // WHY IsDevelopment only: SQL statements in traces help debugging
                //   but may contain PII — don't expose in production traces
                opts.SetDbStatementForText = builder.Environment.IsDevelopment();
            })
            .AddSource("Orders.Application")   // custom spans from application code
            .AddAzureMonitorTraceExporter(opts =>
                opts.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"]);
    })
    .WithMetrics(metrics =>
    {
        metrics
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddRuntimeInstrumentation()       // GC, thread pool, memory metrics
            .AddMeter("Orders.Application")   // custom business metrics
            .AddAzureMonitorMetricExporter(opts =>
                opts.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"]);
    });

// ── Custom activity (span) in application code ────────────────────────────────
private static readonly ActivitySource _activitySource = new("Orders.Application");

public async Task<Order> ProcessOrderAsync(PlaceOrderCommand cmd, CancellationToken ct)
{
    // WHY StartActivity: creates a child span visible in end-to-end transaction view
    using var activity = _activitySource.StartActivity("ProcessOrder");
    activity?.SetTag("order.customerId", cmd.CustomerId.ToString());

    var order = await BuildOrderAsync(cmd, ct);

    activity?.SetTag("order.id", order.Id.ToString());
    activity?.SetTag("order.itemCount", order.Items.Count);
    return order;
}
```

---

## Custom Business Metrics

```csharp
// WHY custom metrics: built-in metrics cover HTTP and DB.
//   Business metrics tell you if orders are being placed and payments succeeding.

public class OrderMetrics(IMeterFactory meterFactory)
{
    // WHY IMeterFactory not static Meter: injectable, testable, follows DI lifetime
    private readonly Meter _meter = meterFactory.Create("Orders.Application");

    private readonly Counter<long> _ordersPlaced;
    private readonly Histogram<double> _orderValue;
    private readonly Counter<long> _paymentsFailed;

    public OrderMetrics(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create("Orders.Application");

        _ordersPlaced = meter.CreateCounter<long>(
            "orders.placed.total",
            unit: "{orders}",
            description: "Total orders placed");

        _orderValue = meter.CreateHistogram<double>(
            "orders.value.usd",
            unit: "USD",
            description: "Order value distribution");

        _paymentsFailed = meter.CreateCounter<long>(
            "orders.payment_failed.total",
            unit: "{orders}");
    }

    public void RecordOrderPlaced(Order order)
    {
        // WHY tags: slice metrics by dimension (region, channel) in dashboards
        _ordersPlaced.Add(1, new TagList
        {
            { "region", order.Region },
            { "channel", order.Channel }
        });
        _orderValue.Record((double)order.Total.Amount);
    }

    public void RecordPaymentFailed(string reason)
        => _paymentsFailed.Add(1, new TagList { { "reason", reason } });
}
```

---

## Health Check Pattern

```csharp
public class PaymentGatewayHealthCheck(HttpClient httpClient) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context, CancellationToken ct)
    {
        try
        {
            // WHY 3s timeout: health check should fail fast — don't block K8s probe
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(ct);
            cts.CancelAfter(TimeSpan.FromSeconds(3));

            var response = await httpClient.GetAsync("/health", cts.Token);
            return response.IsSuccessStatusCode
                ? HealthCheckResult.Healthy()
                : HealthCheckResult.Degraded($"Returned {(int)response.StatusCode}");
        }
        catch (OperationCanceledException)
        {
            return HealthCheckResult.Unhealthy("Timed out after 3 seconds");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Unreachable", ex);
        }
    }
}
```

---

## KQL — Application Insights Queries

```kql
// Trace a single request end-to-end by correlation ID
union requests, traces, exceptions, dependencies
| where timestamp > ago(24h)
| where customDimensions["CorrelationId"] == "abc-123-def"
| order by timestamp asc
| project timestamp, itemType, message, operation_Name, success, duration

// P95 response time per endpoint
requests
| where timestamp > ago(24h)
| summarize
    p50 = percentile(duration, 50),
    p95 = percentile(duration, 95),
    count = count()
  by name
| order by p95 desc

// Exception rate by type — last hour
exceptions
| where timestamp > ago(1h)
| summarize count() by type
| order by count_ desc

// Dependency failures — slow or failed downstream calls
dependencies
| where timestamp > ago(1h)
| where success == false or duration > 2000
| project timestamp, name, target, resultCode, duration
| order by duration desc
```
