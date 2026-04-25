# Session 06 — Observability & Error Handling (Enriched)

**Duration:** 60 minutes
**Audience:** Developers who completed Session 05
**Goal:** Instrument your API with structured logging (including scopes and correlation IDs), build a global exception handler, add health checks, and understand how Azure Application Insights ties it all together.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | Why Observability Matters in Production |
| 5–20 min | ILogger — Structured Logging + Scopes |
| 20–35 min | Global Exception Handling Middleware |
| 35–45 min | Correlation IDs — Thread Your Logs Together |
| 45–55 min | Health Checks |
| 55–60 min | Key Takeaways + Q&A |

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
- "A user got an error" → what error? What was the request?

---

## 2. ILogger — Structured Logging + Scopes (5–20 min)

### Mental Model
> `ILogger` is the **standard logging interface** in .NET. You write structured log entries (key-value pairs, not just strings). Azure Application Insights, Seq, Splunk, and others all consume this format — you swap the sink, not the code.

### Injecting ILogger

```csharp
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
        // NOT: $"Fetching order {id}" — that produces a plain unqueryable string
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

### ILogger Scopes — Attach Context to All Logs in a Block

```csharp
// WHY: BeginScope attaches extra properties to every log inside the using block
// All log entries inside this scope will automatically include OrderId and UserId
using (_logger.BeginScope(new Dictionary<string, object>
{
    ["OrderId"] = order.Id,
    ["UserId"]  = userId
}))
{
    _logger.LogInformation("Starting order confirmation");
    await _emailService.SendAsync(order.CustomerName, "Confirmed", "...");
    _logger.LogInformation("Email sent successfully");
    // Both log lines include OrderId and UserId automatically
}
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

*Temporarily set EF Core SQL logging to `Information` to see generated SQL — useful when debugging.*

---

## 3. Global Exception Handling Middleware (20–35 min)

### Mental Model
> Without a global handler, every unhandled exception returns a raw ASP.NET stack trace to the caller — exposing internals and scaring users. The global handler is a **catch-all safety net**: it logs the error internally and returns a clean, safe response.

### Problem Without a Handler

```json
// What users see without global error handling:
{
  "type": "...",
  "title": "An error occurred.",
  "status": 500,
  "detail": "Connection to server 'prod-sql.database.windows.net' failed... [Full stack trace]"
}
// SECURITY RISK: leaks server names, DB details, stack traces
```

### Domain Exceptions — Typed Errors

```csharp
// WHY: typed exceptions let the middleware return the right HTTP status per error type
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

### Build the Global Exception Middleware

```csharp
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
            await _next(context);
        }
        catch (NotFoundException ex)
        {
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

### Register in Program.cs — First in Pipeline

```csharp
// ── Must be the FIRST middleware so it catches everything ─
app.UseMiddleware<GlobalExceptionMiddleware>();

app.UseAuthentication();
app.UseAuthorization();
```

---

## 4. Correlation IDs — Thread Your Logs Together (35–45 min)

### Mental Model
> A correlation ID is a **case number** attached to every log entry for a single request. When a user reports "I got an error at 2:15 PM", you search by their correlation ID and see every log entry — across every layer and service — that was part of their request.

### Full Correlation ID Middleware

```csharp
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<CorrelationIdMiddleware> _logger;
    private const string CorrelationIdHeader = "X-Correlation-ID";

    public CorrelationIdMiddleware(RequestDelegate next, ILogger<CorrelationIdMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Use incoming correlation ID (from upstream caller) or generate a new one
        // WHY: if API-A calls API-B, we want the same correlation ID to flow through
        var correlationId = context.Request.Headers[CorrelationIdHeader].FirstOrDefault()
            ?? Guid.NewGuid().ToString();

        // Add to response so the caller can log it on their side
        context.Response.Headers[CorrelationIdHeader] = correlationId;

        // Add to Items so exception middleware and endpoints can read it
        context.Items[CorrelationIdHeader] = correlationId;

        // WHY: BeginScope attaches CorrelationId to EVERY log entry in this request
        using (_logger.BeginScope(new Dictionary<string, object>
            { ["CorrelationId"] = correlationId }))
        {
            await _next(context);
        }
    }
}

// Register — must be BEFORE exception middleware to cover all log entries
app.UseMiddleware<CorrelationIdMiddleware>();
app.UseMiddleware<GlobalExceptionMiddleware>();
```

### What This Gives You in Application Insights

```
Search: CorrelationId = "abc-123-def"

Result: All log entries for that request, in order:
  [INFO ] CorrelationId=abc-123 → Request: GET /orders/42
  [INFO ] CorrelationId=abc-123 → Fetching order 42
  [WARN ] CorrelationId=abc-123 → Order 42 not found
  [WARN ] CorrelationId=abc-123 → Resource not found: Order 42 not found
  [INFO ] CorrelationId=abc-123 → Response: 404
```

---

## 5. Health Checks (45–55 min)

### Mental Model
> Health checks are **status lights on your dashboard**. Kubernetes, Azure App Service, and load balancers ping these endpoints to decide if your instance is ready to receive traffic or should be restarted.

```
/health/live    — Is the process running? (Liveness)
                  K8s restarts the pod if this returns non-200

/health/ready   — Is the app ready to serve traffic? (Readiness)
                  Checks: DB reachable, dependencies up
                  K8s stops sending traffic if this returns non-200
```

### Register and Map Health Checks

```csharp
builder.Services.AddHealthChecks()
    .AddSqlServer(
        builder.Configuration.GetConnectionString("Default")!,
        name: "database",
        tags: new[] { "ready" })
    .AddUrlGroup(
        new Uri("https://external-api.example.com/health"),
        name: "external-api",
        tags: new[] { "ready" });

// Liveness — basic process check (no tags = always healthy if app is running)
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = check => check.Tags.Count == 0
});

// Readiness — checks all "ready" tagged checks
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});
```

### Health Check Response

```json
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
      "description": "Response time 2.3s — above threshold"
    }
  }
}
```

---

## Azure Integration

> **For the Azure-focused audience** — this section covers Azure Application Insights: setup, what it auto-captures, custom telemetry, and KQL queries.

### Azure Application Insights — Setup

```
┌────────────────────────────────────────────────────────────┐
│  What It Captures Automatically                            │
├────────────────────────────────────────────────────────────┤
│  Requests        → URL, duration, status code, user        │
│  Dependencies    → DB queries, HTTP calls, Service Bus     │
│  Exceptions      → Full stack trace, associated request    │
│  Performance     → Slow requests, P99 latency              │
│  Custom Events   → Anything you log via TrackEvent()       │
└────────────────────────────────────────────────────────────┘
```

```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

```csharp
// One line of code — everything is captured automatically
builder.Services.AddApplicationInsightsTelemetry(
    builder.Configuration["ApplicationInsights:ConnectionString"]);
```

### Custom Telemetry

```csharp
public class OrderService
{
    private readonly TelemetryClient _telemetry;

    public OrderService(TelemetryClient telemetry) => _telemetry = telemetry;

    public async Task PlaceOrderAsync(Order order)
    {
        // Track a custom business event
        _telemetry.TrackEvent("OrderPlaced", new Dictionary<string, string>
        {
            ["CustomerId"]   = order.CustomerId.ToString(),
            ["OrderTotal"]   = order.Total.ToString("F2")
        });

        // Track a custom metric
        _telemetry.TrackMetric("OrderValue", (double)order.Total);
    }
}
```

### Kusto Query — Find Errors in App Insights

```kusto
// Failed requests in the last hour
requests
| where timestamp > ago(1h)
| where success == false
| project timestamp, name, resultCode, duration, operation_Id
| order by timestamp desc
| take 50

// Find all logs for a specific correlation ID
traces
| where customDimensions["CorrelationId"] == "abc-123-def"
| project timestamp, message, severityLevel
| order by timestamp asc
```

---

## Key Takeaways

1. **Structured logging** — use `{NamedParameters}` not string interpolation; they become queryable fields.
2. **`BeginScope`** — attach request-level context (OrderId, UserId) to all logs in a block automatically.
3. **Global exception middleware** — sits first in the pipeline, logs internally, returns a clean safe response.
4. **Correlation IDs** — flow across services so you can trace one user's journey through all log entries.
5. **Health checks = Kubernetes signals** — `/health/live` for liveness, `/health/ready` for readiness.

---

## Q&A Prompts

**1. What's the difference between `LogWarning` and `LogError`? When do you choose each?**

**Answer:** `LogWarning` is for unexpected but recoverable situations — a record wasn't found, a retry is happening, a request came in with unusual parameters. The system handled it gracefully. `LogError` is for failures that require attention — an exception was caught, a critical operation failed, data may be in an inconsistent state. Monitoring alerts are usually set to fire on `LogError` and above.

---

**2. Why should the global exception handler never return the real exception message to the caller?**

**Answer:** Exception messages often contain sensitive internal details — server names, database connection strings, table names, class names, file paths. Returning these to callers (especially in production) is a significant security vulnerability: it helps attackers understand your system's internals. Always log the full exception internally (where only your team sees it), and return a generic safe message to the caller.

---

**3. What's the difference between a liveness check and a readiness check?**

**Answer:** A liveness check answers "is the process still alive and not deadlocked?" — it should be extremely simple (return 200 immediately). If it fails, Kubernetes restarts the pod. A readiness check answers "is the app ready to handle traffic?" — it checks dependencies (DB reachable, external APIs responding). If it fails, Kubernetes stops routing traffic to that instance but doesn't restart it. Never put DB checks in liveness — a slow DB would cause endless pod restarts.

---

**4. How does structured logging differ from writing `$"Order {id} confirmed"` as a log string?**

**Answer:** String interpolation produces a flat string — "Order 123 confirmed" — which can only be searched with text pattern matching (slow, imprecise). Structured logging stores the template separately from the values: message template = "Order {OrderId} confirmed", OrderId = 123 as a distinct field. In Application Insights, you can then filter `WHERE OrderId = 123` using an indexed field query — orders of magnitude faster and precise. You can also aggregate: "show me all orders above value X that were confirmed today."

---

## What's Next — Day 7

Your app is observable. The final session covers **scale**: caching to reduce DB pressure, background jobs to decouple long work from requests, stateless design for horizontal scaling, event-driven patterns with Azure Service Bus, and Azure Functions for event-driven compute.
