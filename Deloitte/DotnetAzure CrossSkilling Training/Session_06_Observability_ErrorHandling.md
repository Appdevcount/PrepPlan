# Session 06 — Observability & Error Handling

**Duration:** 60 minutes
**Audience:** Developers who completed Session 05
**Goal:** Instrument your API with structured logging, build a global exception handler, add health checks, and understand how Azure Application Insights ties it all together.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | Why Observability Matters in Production |
| 5–20 min | ILogger — Structured Logging |
| 20–35 min | Global Exception Handling Middleware |
| 35–48 min | Health Checks |
| 48–57 min | Azure Application Insights |
| 57–60 min | Key Takeaways + Q&A |

---

## 1. Why Observability Matters in Production (0–5 min)

### Mental Model
> Running a production app without observability is like flying a plane with no instruments — you're moving fast but can't see anything. Observability gives you **altitude, speed, and warning lights**: logs tell you what happened, metrics show trends, traces follow a request across services.

**The 3 Pillars:**

```
┌──────────────────────────────────────────────────────────────┐
│  Logs      │  What happened (events, errors, debug info)     │
│  Metrics   │  How much / how fast (request rate, latency)    │
│  Traces    │  Where time was spent (across services/layers)  │
└──────────────────────────────────────────────────────────────┘
```

**Without observability:**
- "The API is slow" → where? Which endpoint? Which DB query?
- "A user got an error" → what error? What was the request? What was their userId?

---

## 2. ILogger — Structured Logging (5–20 min)

### Mental Model
> `ILogger` is the **standard logging interface** in .NET. You write structured log entries (key-value pairs, not just strings). Azure Application Insights, Seq, Splunk, and others all consume this format — you swap the sink, not the code.

### Injecting ILogger

```csharp
// ── ILogger<T> — T is the source category (class name) ──
public class OrderService : IOrderService
{
    private readonly ILogger<OrderService> _logger;
    private readonly AppDbContext _db;

    public OrderService(ILogger<OrderService> logger, AppDbContext db)
    {
        _logger = logger;
        _db = db;
    }

    public async Task<Order?> GetByIdAsync(int id)
    {
        // WHY: structured logging — {OrderId} becomes a queryable property
        // NOT: $"Fetching order {id}" — that produces a plain string
        _logger.LogInformation("Fetching order {OrderId}", id);

        var order = await _db.Orders.FindAsync(id);

        if (order is null)
            _logger.LogWarning("Order {OrderId} not found", id);

        return order;
    }
}
```

### Log Levels — Choose the Right One

```
┌──────────────────┬──────────────────────────────────────────────────────┐
│  Level           │  Use When                                            │
├──────────────────┼──────────────────────────────────────────────────────┤
│  LogTrace        │  Extremely verbose — step-by-step internal detail    │
│  LogDebug        │  Development diagnostics — values, flow decisions    │
│  LogInformation  │  Normal operations — request received, order placed  │
│  LogWarning      │  Unexpected but recoverable — record not found       │
│  LogError        │  Failures that need attention — exception caught     │
│  LogCritical     │  App-level failures — DB down, startup crash         │
└──────────────────┴──────────────────────────────────────────────────────┘
```

```csharp
// ── Real-world usage patterns ─────────────────────────────
public async Task ConfirmOrderAsync(int orderId)
{
    _logger.LogInformation("Confirming order {OrderId}", orderId);

    try
    {
        var order = await _db.Orders.FindAsync(orderId);
        if (order is null)
        {
            _logger.LogWarning("Confirm failed — order {OrderId} not found", orderId);
            return;
        }

        order.Confirm();
        await _db.SaveChangesAsync();

        _logger.LogInformation("Order {OrderId} confirmed successfully", orderId);
    }
    catch (Exception ex)
    {
        // WHY: LogError with the exception object captures the full stack trace
        _logger.LogError(ex, "Failed to confirm order {OrderId}", orderId);
        throw;
    }
}
```

### Structured vs. Unstructured Logging

```csharp
// ── UNSTRUCTURED — plain string, hard to query ────────────
_logger.LogInformation($"Order {order.Id} confirmed for customer {order.CustomerId}");
// Stored as: "Order 123 confirmed for customer 456"
// Searching: LIKE '%Order%' — slow and imprecise

// ── STRUCTURED — key-value pairs, queryable ───────────────
_logger.LogInformation("Order {OrderId} confirmed for customer {CustomerId}",
    order.Id, order.CustomerId);
// Stored as: Message="Order {OrderId}..." OrderId=123 CustomerId=456
// Searching: WHERE OrderId = 123 — fast and precise
```

### Configure Log Levels in appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore.Database.Command": "Warning"
    }
  }
}
```

*Set EF Core SQL logging to `Information` temporarily to see the generated SQL — helpful when debugging.*

---

## 3. Global Exception Handling Middleware (20–35 min)

### Mental Model
> Without a global handler, every unhandled exception returns a raw ASP.NET stack trace to the caller — exposing internals and scaring users. The global handler is a **catch-all safety net**: it logs the error internally and returns a clean, safe response.

### Problem Without a Handler

```json
// What users see without global error handling:
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.6.1",
  "title": "An error occurred while processing your request.",
  "status": 500,
  "detail": "Connection to server 'prod-sql.database.windows.net' failed... [Full stack trace]"
}
// SECURITY RISK: leaks server names, DB details, stack traces
```

### Build the Global Exception Handler

```csharp
// ── Exception middleware — wraps the entire pipeline ──────
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context); // run the rest of the pipeline
        }
        catch (NotFoundException ex)
        {
            // Known domain exception — log at Warning, return 404
            _logger.LogWarning(ex, "Resource not found: {Message}", ex.Message);
            await WriteErrorResponse(context, StatusCodes.Status404NotFound, ex.Message);
        }
        catch (ValidationException ex)
        {
            _logger.LogWarning(ex, "Validation error: {Message}", ex.Message);
            await WriteErrorResponse(context, StatusCodes.Status400BadRequest, ex.Message);
        }
        catch (Exception ex)
        {
            // Unexpected error — log at Error with full exception, return generic 500
            // WHY: never return internal details (connection strings, stack traces) to callers
            _logger.LogError(ex, "Unhandled exception processing {Method} {Path}",
                context.Request.Method, context.Request.Path);

            await WriteErrorResponse(context, StatusCodes.Status500InternalServerError,
                "An unexpected error occurred. Please try again later.");
        }
    }

    private static async Task WriteErrorResponse(HttpContext context, int statusCode, string message)
    {
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        var response = new { error = message, traceId = context.TraceIdentifier };
        await context.Response.WriteAsJsonAsync(response);
    }
}
```

### Domain Exceptions

```csharp
// ── Typed exceptions for known business errors ────────────
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}

public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}

public class DomainException : Exception
{
    public DomainException(string message) : base(message) { }
}
```

### Register in Program.cs

```csharp
// ── Must be the FIRST middleware so it catches everything ─
app.UseMiddleware<GlobalExceptionMiddleware>();

// ... rest of middleware
app.UseAuthentication();
app.UseAuthorization();
```

### Using Built-in Problem Details (Alternative)

```csharp
// .NET 8+ built-in exception handler — simpler setup
builder.Services.AddProblemDetails();
app.UseExceptionHandler();

// Customize per exception type
app.UseExceptionHandler(opt =>
    opt.Run(async context =>
    {
        var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
        // ... handle and write response
    }));
```

---

## 4. Health Checks (35–48 min)

### Mental Model
> Health checks are **status lights on your dashboard**. Kubernetes, Azure App Service, and load balancers ping these endpoints to decide if your instance is ready to receive traffic or should be restarted.

### The Two Check Types

```
/health/live    — Is the process running? (Liveness)
                  Simple: return 200 if the app hasn't crashed
                  K8s restarts the pod if this fails

/health/ready   — Is the app ready to serve traffic? (Readiness)
                  Checks: DB connection, external services
                  K8s stops sending traffic if this fails
```

### Register and Map Health Checks

```csharp
// ── Register ──────────────────────────────────────────────
builder.Services.AddHealthChecks()
    .AddSqlServer(
        builder.Configuration.GetConnectionString("Default")!,
        name: "database",
        tags: new[] { "ready" })   // tagged as readiness check
    .AddUrlGroup(
        new Uri("https://external-api.example.com/health"),
        name: "external-api",
        tags: new[] { "ready" });

// ── Map endpoints ─────────────────────────────────────────
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    // Liveness: only checks with no tags (basic process check)
    Predicate = check => check.Tags.Count == 0
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse  // detailed JSON
});
```

### Health Check Response

```json
// GET /health/ready
{
  "status": "Healthy",
  "duration": "00:00:00.0234567",
  "entries": {
    "database": {
      "status": "Healthy",
      "duration": "00:00:00.0187123"
    },
    "external-api": {
      "status": "Degraded",
      "description": "Response time 2.3s — above threshold",
      "duration": "00:00:02.3001456"
    }
  }
}
```

### Correlation ID — Thread Your Logs Together

```csharp
// ── Middleware: add a correlation ID to every request ─────
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string CorrelationIdHeader = "X-Correlation-ID";

    public CorrelationIdMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context)
    {
        // Use incoming correlation ID (from upstream caller) or generate one
        var correlationId = context.Request.Headers[CorrelationIdHeader].FirstOrDefault()
            ?? Guid.NewGuid().ToString();

        context.Response.Headers[CorrelationIdHeader] = correlationId;

        // WHY: adding to Items lets any middleware/handler read it
        context.Items[CorrelationIdHeader] = correlationId;

        // Add to log scope so every log in this request includes the correlation ID
        using (_logger.BeginScope(new Dictionary<string, object>
            { ["CorrelationId"] = correlationId }))
        {
            await _next(context);
        }
    }
}
```

---

## 5. Azure Application Insights (48–57 min)

### Mental Model
> Application Insights is your app's **flight recorder and analytics dashboard**. It auto-captures every request, every dependency call (DB, HTTP), every exception — and lets you query, visualize, and alert on all of it without changing your logging code.

### What It Captures Automatically

```
┌────────────────────────────────────────────────────────────┐
│  Requests        → URL, duration, status code, user        │
│  Dependencies    → DB queries, HTTP calls, Service Bus     │
│  Exceptions      → Full stack trace, associated request    │
│  Performance     → Slow requests, P99 latency              │
│  Custom Events   → Anything you log with TrackEvent()      │
└────────────────────────────────────────────────────────────┘
```

### Setup — One Line of Code

```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

```csharp
// ── Program.cs ────────────────────────────────────────────
builder.Services.AddApplicationInsightsTelemetry(
    builder.Configuration["ApplicationInsights:ConnectionString"]);
// That's it — requests, dependencies, exceptions all captured automatically
```

### Custom Telemetry

```csharp
// Inject TelemetryClient for custom events and metrics
public class OrderService
{
    private readonly TelemetryClient _telemetry;

    public OrderService(TelemetryClient telemetry) => _telemetry = telemetry;

    public async Task PlaceOrderAsync(Order order)
    {
        // Track a custom business event
        _telemetry.TrackEvent("OrderPlaced", new Dictionary<string, string>
        {
            ["CustomerId"] = order.CustomerId.ToString(),
            ["OrderTotal"] = order.Total.ToString("F2")
        });

        // Track a custom metric
        _telemetry.TrackMetric("OrderValue", (double)order.Total);
    }
}
```

### Kusto Query — Find Errors in App Insights

```kusto
// Find all failed requests in the last hour
requests
| where timestamp > ago(1h)
| where success == false
| project timestamp, name, resultCode, duration, operation_Id
| order by timestamp desc
| take 50
```

---

## Key Takeaways

1. **Structured logging** — use `{NamedParameters}` not string interpolation; they become queryable fields in App Insights.
2. **Global exception middleware** — sits first in the pipeline, logs internally, returns a clean safe response externally.
3. **Health checks = Kubernetes signals** — `/health/live` for liveness, `/health/ready` for readiness; always expose both.
4. **Correlation IDs** — add them to every request so you can trace a user's journey across multiple log entries.
5. **App Insights auto-captures** everything with one line of code — requests, dependencies, exceptions, performance.

---

## Q&A Prompts

1. What's the difference between `LogWarning` and `LogError`? When do you choose each?
2. Why should the global exception handler never return the real exception message to the caller?
3. What's the difference between a liveness check and a readiness check?
4. How does structured logging differ from writing `$"Order {id} confirmed"` as a log string?

---

## What's Next — Day 7

Your app is observable. The final session covers **scale**: how to cache data to reduce DB pressure, run background jobs without blocking requests, and design stateless services that can scale horizontally across multiple instances.
