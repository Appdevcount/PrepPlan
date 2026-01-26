# Appendix A: Monitoring, Observability & Application Insights

## Overview
Production systems require comprehensive monitoring and observability to detect issues, debug failures, and optimize performance. This guide covers Application Insights, distributed tracing, logging strategies, and alerting for Senior/SDE-2 interviews at top companies.

**Real Interview Context:**
- Amazon: "How do you monitor a distributed microservices system?"
- Microsoft: "Explain distributed tracing and how Application Insights implements it"
- Netflix: "Design an alerting strategy for a high-traffic service"
- Google: "How do you debug a performance issue in production without impacting users?"

---

## 1. Observability vs Monitoring

### The Three Pillars of Observability

```
┌────────────────────────────────────────────────────────────┐
│              OBSERVABILITY PILLARS                         │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─────────┐      ┌─────────┐      ┌─────────┐          │
│  │ METRICS │      │  LOGS   │      │ TRACES  │          │
│  └────┬────┘      └────┬────┘      └────┬────┘          │
│       │                │                 │               │
│   System health    Event details    Request flow        │
│   CPU, Memory      Errors, Info     Latency, Deps       │
│   Request/sec      User actions     Service calls       │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Tech Lead Decision Framework:**

| Need | Tool | Example |
|------|------|---------|
| **What's broken?** | Metrics | CPU spike, 500 errors increasing |
| **Why is it broken?** | Logs | Exception stack trace, user input |
| **Where is it slow?** | Traces | Database query taking 5 seconds |

---

## 2. Application Insights Integration

### Setup and Configuration

```csharp
// Program.cs - ASP.NET Core
var builder = WebApplication.CreateBuilder(args);

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"];
    options.EnableAdaptiveSampling = true; // Reduce cost, sample data
    options.EnableDependencyTrackingTelemetryModule = true; // Track HTTP, SQL, etc.
    options.EnableEventCounterCollectionModule = true; // .NET counters
    options.EnablePerformanceCounterCollectionModule = false; // Disable if not needed
});

// Add telemetry processors (filters/enrichment)
builder.Services.AddApplicationInsightsTelemetryProcessor<CustomTelemetryProcessor>();

// Add custom dimensions to all telemetry
builder.Services.AddSingleton<ITelemetryInitializer, CustomTelemetryInitializer>();

var app = builder.Build();

// Track HTTP requests/responses automatically
app.UseHttpsRedirection();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.Run();
```

### Custom Telemetry Initializer

```csharp
// Add custom properties to ALL telemetry
public class CustomTelemetryInitializer : ITelemetryInitializer
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CustomTelemetryInitializer(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public void Initialize(ITelemetry telemetry)
    {
        var context = _httpContextAccessor.HttpContext;
        if (context == null) return;

        // Add user ID to all events
        var userId = context.User?.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!string.IsNullOrEmpty(userId))
        {
            telemetry.Context.User.Id = userId;
        }

        // Add correlation ID
        var correlationId = context.Request.Headers["X-Correlation-ID"].FirstOrDefault()
                          ?? context.TraceIdentifier;
        telemetry.Context.Operation.Id = correlationId;

        // Add custom dimensions
        if (telemetry is ISupportProperties propertiesTelemetry)
        {
            propertiesTelemetry.Properties["Environment"] =
                Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown";
            propertiesTelemetry.Properties["MachineName"] = Environment.MachineName;
            propertiesTelemetry.Properties["Version"] =
                Assembly.GetExecutingAssembly().GetName().Version?.ToString() ?? "Unknown";
        }
    }
}

// Filter out telemetry (reduce noise/cost)
public class CustomTelemetryProcessor : ITelemetryProcessor
{
    private readonly ITelemetryProcessor _next;

    public CustomTelemetryProcessor(ITelemetryProcessor next)
    {
        _next = next;
    }

    public void Process(ITelemetry item)
    {
        // Filter out health check requests
        if (item is RequestTelemetry request)
        {
            if (request.Url.AbsolutePath.Contains("/health") ||
                request.Url.AbsolutePath.Contains("/ready"))
            {
                return; // Don't send to App Insights
            }
        }

        // Filter out successful dependency calls to reduce cost
        if (item is DependencyTelemetry dependency)
        {
            if (dependency.Success == true && dependency.Duration < TimeSpan.FromSeconds(1))
            {
                return; // Skip fast, successful calls
            }
        }

        _next.Process(item);
    }
}
```

---

## 3. Custom Metrics and Events

### Tracking Business Metrics

```csharp
public class OrderController : ControllerBase
{
    private readonly TelemetryClient _telemetryClient;
    private readonly IOrderService _orderService;

    [HttpPost("orders")]
    public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
    {
        var stopwatch = Stopwatch.StartNew();

        try
        {
            var order = await _orderService.CreateOrderAsync(dto);

            // Track custom event
            _telemetryClient.TrackEvent("OrderCreated", new Dictionary<string, string>
            {
                ["OrderId"] = order.Id.ToString(),
                ["CustomerId"] = order.CustomerId.ToString(),
                ["TotalItems"] = order.Items.Count.ToString(),
                ["PaymentMethod"] = order.PaymentMethod
            }, new Dictionary<string, double>
            {
                ["OrderTotal"] = (double)order.Total,
                ["ProcessingTime"] = stopwatch.Elapsed.TotalMilliseconds
            });

            // Track custom metric (aggregated over time)
            _telemetryClient.TrackMetric("OrderValue", (double)order.Total);
            _telemetryClient.GetMetric("OrdersByPaymentMethod", "PaymentMethod")
                .TrackValue(1, order.PaymentMethod);

            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (PaymentFailedException ex)
        {
            // Track exception with context
            _telemetryClient.TrackException(ex, new Dictionary<string, string>
            {
                ["CustomerId"] = dto.CustomerId.ToString(),
                ["PaymentMethod"] = dto.PaymentMethod,
                ["Amount"] = dto.Total.ToString()
            });

            return BadRequest(new { error = "Payment failed" });
        }
        finally
        {
            stopwatch.Stop();
        }
    }

    // Track custom metric for business KPIs
    public async Task TrackDailyRevenue()
    {
        var revenue = await _orderService.GetTodaysRevenueAsync();

        _telemetryClient.TrackMetric(new MetricTelemetry
        {
            Name = "DailyRevenue",
            Sum = (double)revenue,
            Timestamp = DateTimeOffset.UtcNow,
            Properties =
            {
                ["Date"] = DateTime.UtcNow.Date.ToString("yyyy-MM-dd")
            }
        });
    }
}

// Background service for periodic metrics
public class MetricsCollectorService : BackgroundService
{
    private readonly TelemetryClient _telemetryClient;
    private readonly IServiceScopeFactory _scopeFactory;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var orderService = scope.ServiceProvider.GetRequiredService<IOrderService>();

                // Track active orders
                var activeOrders = await orderService.GetActiveOrderCountAsync();
                _telemetryClient.TrackMetric("ActiveOrders", activeOrders);

                // Track pending orders older than 1 hour (SLA breach)
                var pendingOrders = await orderService.GetPendingOrdersOlderThanAsync(TimeSpan.FromHours(1));
                _telemetryClient.TrackMetric("SLABreach.PendingOrders", pendingOrders);

                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
            }
            catch (Exception ex)
            {
                _telemetryClient.TrackException(ex);
            }
        }
    }
}
```

---

## 4. Distributed Tracing

### Correlation Across Services

```csharp
// Service A: Order Service
public class OrderService
{
    private readonly HttpClient _httpClient;
    private readonly TelemetryClient _telemetryClient;

    public async Task<Order> CreateOrderAsync(CreateOrderDto dto)
    {
        // Start custom operation (creates span)
        using var operation = _telemetryClient.StartOperation<DependencyTelemetry>("ProcessOrder");
        operation.Telemetry.Type = "Internal";

        try
        {
            // Call Inventory Service
            using var inventoryOperation = _telemetryClient.StartOperation<DependencyTelemetry>(
                "CheckInventory",
                operation.Telemetry.Context.Operation.Id);

            inventoryOperation.Telemetry.Type = "HTTP";
            inventoryOperation.Telemetry.Target = "inventory-service";

            var inventoryResponse = await _httpClient.PostAsync(
                "http://inventory-service/api/inventory/reserve",
                JsonContent.Create(dto.Items));

            inventoryOperation.Telemetry.Success = inventoryResponse.IsSuccessStatusCode;
            inventoryOperation.Telemetry.ResultCode = ((int)inventoryResponse.StatusCode).ToString();

            if (!inventoryResponse.IsSuccessStatusCode)
            {
                throw new InventoryUnavailableException();
            }

            // Call Payment Service
            using var paymentOperation = _telemetryClient.StartOperation<DependencyTelemetry>(
                "ProcessPayment",
                operation.Telemetry.Context.Operation.Id);

            paymentOperation.Telemetry.Type = "HTTP";
            paymentOperation.Telemetry.Target = "payment-service";

            var paymentResponse = await _httpClient.PostAsync(
                "http://payment-service/api/payments",
                JsonContent.Create(new { Amount = dto.Total }));

            paymentOperation.Telemetry.Success = paymentResponse.IsSuccessStatusCode;

            // Save order
            var order = await _repository.SaveAsync(dto.ToOrder());

            operation.Telemetry.Success = true;
            return order;
        }
        catch (Exception ex)
        {
            operation.Telemetry.Success = false;
            _telemetryClient.TrackException(ex);
            throw;
        }
    }
}

// Service B: Inventory Service (receives correlated request)
public class InventoryController : ControllerBase
{
    private readonly TelemetryClient _telemetryClient;

    [HttpPost("inventory/reserve")]
    public async Task<IActionResult> ReserveInventory(ReserveInventoryDto dto)
    {
        // Application Insights automatically correlates this with parent operation
        // The Operation ID from Service A is propagated via HTTP headers

        var stopwatch = Stopwatch.StartNew();

        try
        {
            var result = await _inventoryService.ReserveAsync(dto.Items);

            _telemetryClient.TrackEvent("InventoryReserved", new Dictionary<string, string>
            {
                ["ItemCount"] = dto.Items.Count.ToString()
            }, new Dictionary<string, double>
            {
                ["ReservationTime"] = stopwatch.Elapsed.TotalMilliseconds
            });

            return Ok(result);
        }
        catch (InsufficientInventoryException ex)
        {
            _telemetryClient.TrackException(ex);
            return BadRequest(new { error = "Insufficient inventory" });
        }
    }
}

// Querying distributed traces in Application Insights
// Kusto Query:
// requests
// | where timestamp > ago(1h)
// | where operation_Name == "POST Orders/Create"
// | join kind=inner (
//     dependencies
//     | where type == "HTTP"
// ) on operation_Id
// | project timestamp, operation_Id, name, target, duration, resultCode
// | order by timestamp desc
```

### W3C TraceContext Propagation

```csharp
// Automatic propagation with HttpClient + Application Insights
builder.Services.AddHttpClient("InventoryService", client =>
{
    client.BaseAddress = new Uri("http://inventory-service");
})
.AddHttpMessageHandler<CorrelationHandler>(); // Propagate trace context

public class CorrelationHandler : DelegatingHandler
{
    private readonly TelemetryClient _telemetryClient;

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        // W3C TraceContext headers are automatically added by Application Insights:
        // traceparent: 00-{trace-id}-{parent-id}-{trace-flags}
        // tracestate: additional vendor-specific data

        // Start dependency tracking
        var sw = Stopwatch.StartNew();
        var response = await base.SendAsync(request, cancellationToken);
        sw.Stop();

        // Track dependency
        _telemetryClient.TrackDependency(
            "HTTP",
            request.RequestUri.Host,
            $"{request.Method} {request.RequestUri.PathAndQuery}",
            null,
            DateTimeOffset.UtcNow.Subtract(sw.Elapsed),
            sw.Elapsed,
            ((int)response.StatusCode).ToString(),
            response.IsSuccessStatusCode);

        return response;
    }
}
```

---

## 5. Structured Logging

### Serilog Integration

```csharp
// Program.cs
using Serilog;
using Serilog.Events;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("System", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithEnvironmentName()
    .Enrich.WithProperty("Application", "OrderService")
    .WriteTo.Console(
        outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}")
    .WriteTo.ApplicationInsights(
        builder.Configuration["ApplicationInsights:ConnectionString"],
        TelemetryConverter.Traces)
    .CreateLogger();

builder.Host.UseSerilog();

// Usage with structured logging
public class OrderService
{
    private readonly ILogger<OrderService> _logger;

    public async Task<Order> CreateOrderAsync(CreateOrderDto dto)
    {
        // Structured logging with named properties
        _logger.LogInformation(
            "Creating order for customer {CustomerId} with {ItemCount} items totaling {OrderTotal:C}",
            dto.CustomerId,
            dto.Items.Count,
            dto.Total);

        try
        {
            var order = await ProcessOrderAsync(dto);

            _logger.LogInformation(
                "Order {OrderId} created successfully in {Duration}ms",
                order.Id,
                stopwatch.ElapsedMilliseconds);

            return order;
        }
        catch (PaymentFailedException ex)
        {
            _logger.LogError(ex,
                "Payment failed for customer {CustomerId}. Amount: {Amount:C}, Method: {PaymentMethod}",
                dto.CustomerId,
                dto.Total,
                dto.PaymentMethod);
            throw;
        }
    }
}

// Query logs in Application Insights:
// traces
// | where customDimensions.CustomerId == "12345"
// | where timestamp > ago(1h)
// | order by timestamp desc
```

### Log Correlation with Scopes

```csharp
public class OrderController : ControllerBase
{
    private readonly ILogger<OrderController> _logger;

    [HttpPost("orders")]
    public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
    {
        // Create log scope - all logs within this scope will include these properties
        using (_logger.BeginScope(new Dictionary<string, object>
        {
            ["CustomerId"] = dto.CustomerId,
            ["CorrelationId"] = HttpContext.TraceIdentifier,
            ["UserAgent"] = HttpContext.Request.Headers["User-Agent"].ToString()
        }))
        {
            _logger.LogInformation("Order creation started");

            var order = await _orderService.CreateOrderAsync(dto);

            _logger.LogInformation("Order creation completed");

            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
    }
}
```

---

## 6. Alerting Strategies

### Application Insights Alerts

```csharp
// Configure alerts via ARM template or Azure CLI
// Alert on high error rate
{
  "name": "High Error Rate Alert",
  "criteria": {
    "allOf": [
      {
        "name": "ErrorRate",
        "metricName": "requests/failed",
        "operator": "GreaterThan",
        "threshold": 5, // 5% error rate
        "timeAggregation": "Percentage",
        "dimensions": []
      }
    ]
  },
  "windowSize": "PT5M", // 5 minute window
  "evaluationFrequency": "PT1M", // Check every minute
  "severity": 2, // 0 = Critical, 1 = Error, 2 = Warning
  "actions": [
    {
      "actionGroupId": "/subscriptions/.../actionGroups/on-call-team"
    }
  ]
}

// Alert on slow response times
{
  "name": "Slow Response Time",
  "criteria": {
    "metricName": "requests/duration",
    "operator": "GreaterThan",
    "threshold": 3000, // 3 seconds
    "timeAggregation": "Average",
    "dimensions": [
      {
        "name": "operation_Name",
        "operator": "Include",
        "values": ["POST Orders/Create"]
      }
    ]
  },
  "windowSize": "PT5M",
  "severity": 3
}

// Alert on custom metric (SLA breach)
{
  "name": "SLA Breach - Pending Orders",
  "criteria": {
    "metricName": "SLABreach.PendingOrders",
    "operator": "GreaterThan",
    "threshold": 10,
    "timeAggregation": "Maximum"
  },
  "windowSize": "PT15M",
  "severity": 1 // High priority
}
```

### Smart Detection (AI-based Anomalies)

```csharp
// Application Insights Smart Detection automatically alerts on:
// 1. Failure rate anomalies
// 2. Response time degradation
// 3. Memory leak detection
// 4. Security issue detection
// 5. Trace severity ratio changes

// Configure via Azure Portal or ARM:
{
  "name": "Failure Anomalies",
  "ruleDefinitions": {
    "Name": "Failure Anomalies",
    "DisplayName": "Failure Anomalies",
    "Description": "Detects unusual increase in failure rate",
    "IsEnabled": true,
    "IsInPreview": false
  },
  "actionGroups": [
    "/subscriptions/.../actionGroups/smart-detection-team"
  ]
}
```

---

## 7. Performance Profiling

### Application Insights Profiler

```csharp
// Enable profiler in appsettings.json
{
  "ApplicationInsights": {
    "ConnectionString": "InstrumentationKey=...",
    "EnableProfiler": true,
    "ProfilerSettings": {
      "IsEnabled": true,
      "CollectionPlan": "Continuous",
      "CpuTriggerConfiguration": {
        "Threshold": 80, // CPU > 80%
        "Duration": "00:00:30" // For 30 seconds
      },
      "MemoryTriggerConfiguration": {
        "Threshold": 90 // Memory > 90%
      }
    }
  }
}

// Profiler automatically captures:
// - Method call stacks
// - CPU usage per method
// - Time spent in each method
// - Database query execution time
// - HTTP call latency

// View in Azure Portal:
// Application Insights → Investigate → Performance → Profiler Traces
```

### Custom Performance Tracking

```csharp
public class PerformanceTracker : IDisposable
{
    private readonly TelemetryClient _telemetryClient;
    private readonly string _operationName;
    private readonly Stopwatch _stopwatch;
    private readonly IOperationHolder<RequestTelemetry> _operation;

    public PerformanceTracker(TelemetryClient telemetryClient, string operationName)
    {
        _telemetryClient = telemetryClient;
        _operationName = operationName;
        _stopwatch = Stopwatch.StartNew();
        _operation = _telemetryClient.StartOperation<RequestTelemetry>(operationName);
    }

    public void Dispose()
    {
        _stopwatch.Stop();
        _operation.Telemetry.Duration = _stopwatch.Elapsed;
        _operation.Telemetry.Success = true;

        // Track if operation is slow
        if (_stopwatch.ElapsedMilliseconds > 1000)
        {
            _telemetryClient.TrackTrace(
                $"Slow operation detected: {_operationName} took {_stopwatch.ElapsedMilliseconds}ms",
                SeverityLevel.Warning,
                new Dictionary<string, string>
                {
                    ["OperationName"] = _operationName,
                    ["Duration"] = _stopwatch.ElapsedMilliseconds.ToString()
                });
        }

        _operation.Dispose();
    }
}

// Usage
public async Task<Order> ProcessOrderAsync(CreateOrderDto dto)
{
    using var _ = new PerformanceTracker(_telemetryClient, "ProcessOrder");

    // Business logic
    return await _orderService.CreateOrderAsync(dto);
}
```

---

## 8. Kusto Query Language (KQL) for Analysis

### Common Queries

```kql
// Find slow requests (> 3 seconds)
requests
| where timestamp > ago(1h)
| where duration > 3000
| project timestamp, name, url, duration, resultCode, operation_Id
| order by duration desc
| take 100

// Error rate over time
requests
| where timestamp > ago(24h)
| summarize
    TotalRequests = count(),
    FailedRequests = countif(success == false),
    ErrorRate = todouble(countif(success == false)) / count() * 100
    by bin(timestamp, 5m)
| render timechart

// Top 10 slowest dependencies
dependencies
| where timestamp > ago(1h)
| summarize
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95),
    Count = count()
    by name, type, target
| order by P95Duration desc
| take 10

// Find correlated failures (same operation_Id)
let failedRequests = requests
    | where timestamp > ago(1h)
    | where success == false
    | project operation_Id, name, resultCode;
dependencies
| where timestamp > ago(1h)
| join kind=inner failedRequests on operation_Id
| project timestamp, operation_Id, name, name1, target, duration, resultCode, resultCode1
| order by timestamp desc

// Track custom events by user
customEvents
| where timestamp > ago(7d)
| where name == "OrderCreated"
| extend UserId = tostring(customDimensions.CustomerId)
| summarize
    OrderCount = count(),
    TotalRevenue = sum(todouble(customMeasurements.OrderTotal))
    by UserId
| order by TotalRevenue desc
| take 100

// Exception analysis
exceptions
| where timestamp > ago(24h)
| summarize Count = count() by type, outerMessage
| order by Count desc

// Dependency failure analysis
dependencies
| where timestamp > ago(1h)
| where success == false
| summarize FailureCount = count() by target, name, resultCode
| order by FailureCount desc
```

---

## 9. Real Interview Scenarios

### Amazon: Debugging Production Issue

**Question:** "Your API suddenly starts returning 500 errors at 3x the normal rate. How do you investigate?"

**Answer:**

```
1. Check Application Insights Dashboard
   - Error rate spike? When did it start?
   - Which endpoints? All or specific?

2. Query exceptions:
   exceptions
   | where timestamp > ago(1h)
   | summarize Count = count() by type, outerMessage
   | order by Count desc

3. Check recent deployments:
   - Was there a code change?
   - Configuration change?

4. Check dependencies:
   dependencies
   | where timestamp > ago(1h)
   | where success == false
   | summarize Count = count() by target, resultCode

5. Check distributed traces:
   requests
   | where timestamp > ago(1h)
   | where success == false
   | take 10
   | join kind=inner dependencies on operation_Id
   | project timestamp, name, target, duration, resultCode

6. Rollback or fix:
   - If deployment issue → rollback
   - If external dependency → implement circuit breaker
   - If database → check connection pool exhaustion
```

**Interview Talking Points:**
- "I start with high-level metrics (error rate, latency) to understand scope"
- "Distributed tracing helps identify which service in the chain is failing"
- "Custom dimensions (user ID, tenant ID) help identify affected users"
- "I set up alerts to catch issues before customers report them"

### Microsoft: Performance Degradation

**Question:** "Users report the app is slow. How do you find the bottleneck?"

**Answer:**

```kql
// 1. Check P95 latency trend
requests
| where timestamp > ago(24h)
| summarize P95 = percentile(duration, 95) by bin(timestamp, 5m)
| render timechart

// 2. Find slowest operations
requests
| where timestamp > ago(1h)
| summarize AvgDuration = avg(duration), P95 = percentile(duration, 95) by name
| order by P95 desc

// 3. Check dependencies for that operation
let slowOperation = "POST Orders/Create";
dependencies
| where timestamp > ago(1h)
| where operation_Name == slowOperation
| summarize AvgDuration = avg(duration), P95 = percentile(duration, 95) by name, target
| order by P95 desc

// 4. Use Profiler to find CPU hotspots
// Azure Portal → Performance → Profiler Traces

// 5. Check for N+1 queries (many fast DB calls)
dependencies
| where timestamp > ago(1h)
| where type == "SQL"
| where operation_Name == slowOperation
| summarize Count = count() by operation_Id
| where Count > 10
```

**Root Causes:**
- Database query without index (sudden data growth)
- N+1 query problem (lazy loading in ORM)
- External API slow/timing out
- Memory leak causing GC pressure
- Lock contention (too many concurrent requests)

---

## 10. Key Takeaways

**Tech Lead / Architect Level:**
1. **Three Pillars** - Metrics (what), Logs (why), Traces (where)
2. **Application Insights** - Native integration with .NET, auto-instrumentation
3. **Distributed Tracing** - W3C TraceContext propagates across services
4. **Structured Logging** - Use Serilog with named properties, not string interpolation
5. **Custom Metrics** - Track business KPIs, not just technical metrics
6. **Alerting** - Alert on SLOs (error rate, latency), not every error
7. **Sampling** - Use adaptive sampling in production to control cost
8. **KQL Proficiency** - Essential for deep analysis and dashboards
9. **Smart Detection** - AI-based anomaly detection catches issues proactively
10. **Profiler** - Capture real production call stacks to find bottlenecks

**Interview Preparation:**
- Be ready to explain distributed tracing and correlation IDs
- Know KQL syntax for common queries (errors, latency, dependencies)
- Discuss trade-offs: sampling vs cost, logging levels, telemetry volume
- Walk through debugging scenarios using Application Insights
- Explain the difference between metrics, logs, and traces

**Red Flags to Avoid:**
- ❌ "I log everything to file and grep through it" → Use structured logging!
- ❌ "I don't need monitoring, we have low traffic" → Monitoring is for debugging, not just scale!
- ❌ "I alert on every exception" → Alert on SLOs, not noise!
- ❌ "I don't use distributed tracing" → Can't debug microservices without it!
- ❌ "I only look at metrics after users complain" → Proactive monitoring catches issues first!
