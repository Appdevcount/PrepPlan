# Session 02 — Building APIs

**Duration:** 60 minutes
**Audience:** Developers who completed Session 01
**Goal:** Understand the ASP.NET Core request pipeline, wire up Dependency Injection, and build a working Minimal API with Swagger — live.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | What is ASP.NET Core? |
| 5–20 min | The Request Pipeline — Middleware |
| 20–35 min | Dependency Injection — Lifetimes Explained |
| 35–50 min | Live Demo — Build a Minimal API from Scratch |
| 50–58 min | DTOs vs Entities + Async Best Practices |
| 58–60 min | Key Takeaways + Q&A |

---

## 1. What is ASP.NET Core? (0–5 min)

### Mental Model
> ASP.NET Core is a **pipeline of middleware** — imagine a series of airport security checkpoints. Every HTTP request walks through them one by one. Each checkpoint can inspect, modify, short-circuit, or pass the request along.

ASP.NET Core is:
- Cross-platform (runs on Linux, Windows, Mac, containers)
- High performance — among the fastest web frameworks globally
- Built-in DI, configuration, logging, health checks — no third-party needed for basics

---

## 2. The Request Pipeline — Middleware (5–20 min)

### Mental Model
> Middleware is like **layers of an onion**. A request enters the outer layer, travels inward to your endpoint, and the response travels back out through the same layers in reverse.

```
HTTP Request
     │
     ▼
┌────────────────────────────────────────────────────────┐
│  1. HTTPS Redirection Middleware                        │
├────────────────────────────────────────────────────────┤
│  2. Authentication Middleware  (who are you?)           │
├────────────────────────────────────────────────────────┤
│  3. Authorization Middleware   (are you allowed?)       │
├────────────────────────────────────────────────────────┤
│  4. Exception Handling Middleware  (catch all errors)   │
├────────────────────────────────────────────────────────┤
│  5. Routing Middleware  (which endpoint handles this?)  │
├────────────────────────────────────────────────────────┤
│  6. Your Endpoint Handler  (your business logic)        │
└────────────────────────────────────────────────────────┘
     │
     ▼
HTTP Response (travels back through same chain in reverse)
```

### How Middleware is Registered — Program.cs

```csharp
// ── Program.cs — the entry point of every ASP.NET Core app ──
var builder = WebApplication.CreateBuilder(args);

// ── Register services into DI container ──────────────────
builder.Services.AddEndpointsApiExplorer();   // needed for Swagger
builder.Services.AddSwaggerGen();             // generate OpenAPI docs
builder.Services.AddScoped<IOrderService, OrderService>();

var app = builder.Build();

// ── Register middleware — ORDER MATTERS ──────────────────
// WHY: middleware runs top to bottom; exception handler must come before routing
// to catch errors from all downstream middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();  // must come before UseAuthorization
app.UseAuthorization();

// ── Map endpoints ─────────────────────────────────────────
app.MapGet("/health", () => Results.Ok("Healthy"));

app.Run();
```

### Writing Custom Middleware

```csharp
// Middleware is just a class with an Invoke method
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        _logger.LogInformation("Request: {Method} {Path}", context.Request.Method, context.Request.Path);

        await _next(context); // pass to next middleware

        _logger.LogInformation("Response: {StatusCode}", context.Response.StatusCode);
    }
}

// Register it
app.UseMiddleware<RequestLoggingMiddleware>();
```

---

## 3. Dependency Injection — Lifetimes Explained (20–35 min)

### Mental Model
> DI is a **hotel concierge**. You tell reception (the DI container) what services you need; it creates and delivers them to your room (your class). You don't go find them yourself. Lifetime controls how long the concierge keeps the same instance vs. making a new one.

### The 3 Lifetimes

```
┌──────────────┬───────────────────────────────┬───────────────────────────┐
│  Lifetime    │  Created When                 │  Use For                  │
├──────────────┼───────────────────────────────┼───────────────────────────┤
│  Singleton   │  Once for app lifetime        │  Config, caches, clients  │
│  Scoped      │  Once per HTTP request        │  DB context, unit of work │
│  Transient   │  Every time it's requested    │  Lightweight, stateless   │
└──────────────┴───────────────────────────────┴───────────────────────────┘
```

```csharp
// ── Registration ─────────────────────────────────────────
builder.Services.AddSingleton<IMemoryCache, MemoryCache>();   // one instance ever
builder.Services.AddScoped<AppDbContext>();                    // one per request
builder.Services.AddTransient<IEmailService, SmtpEmailService>(); // new each time

// ── Constructor Injection ─────────────────────────────────
// The container automatically resolves and injects dependencies
public class OrdersController
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrdersController> _logger;

    // WHY: constructor injection makes dependencies explicit and testable
    public OrdersController(IOrderService orderService, ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }
}
```

### Common Mistake — Captive Dependency

```csharp
// WRONG — injecting Scoped service into a Singleton
builder.Services.AddSingleton<MySingleton>(); // lives forever
builder.Services.AddScoped<MyScoped>();       // lives per request

// MySingleton holds MyScoped → MyScoped never gets released!
// ASP.NET Core will throw an exception at startup if you do this — good!
```

---

## 4. Live Demo — Build a Minimal API from Scratch (35–50 min)

### Step 1 — Create the Project

```bash
dotnet new webapi -n OrderApi --use-minimal-apis
cd OrderApi
dotnet run
# Open https://localhost:5001/swagger
```

### Step 2 — Define the Domain Model and DTO

```csharp
// ── Domain Entity ─────────────────────────────────────────
public class Order
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string CustomerName { get; set; } = string.Empty;
    public decimal Total { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

// ── Response DTO — never expose the entity directly ───────
// WHY: entities have navigation properties, lazy loading, EF internals
// that don't serialize well and expose internal structure
public record OrderResponse(Guid Id, string CustomerName, decimal Total, DateTime CreatedAt);

// ── Request DTO — validate input separately from persistence ──
public record CreateOrderRequest(string CustomerName, decimal Total);
```

### Step 3 — In-Memory Service (no DB yet)

```csharp
// ── Service Interface ─────────────────────────────────────
public interface IOrderService
{
    Task<IEnumerable<OrderResponse>> GetAllAsync();
    Task<OrderResponse?> GetByIdAsync(Guid id);
    Task<OrderResponse> CreateAsync(CreateOrderRequest request);
}

// ── In-Memory Implementation ──────────────────────────────
public class InMemoryOrderService : IOrderService
{
    private readonly List<Order> _orders = new();

    public Task<IEnumerable<OrderResponse>> GetAllAsync()
    {
        var result = _orders.Select(ToResponse);
        return Task.FromResult(result);
    }

    public Task<OrderResponse?> GetByIdAsync(Guid id)
    {
        var order = _orders.FirstOrDefault(o => o.Id == id);
        return Task.FromResult(order is null ? null : ToResponse(order));
    }

    public Task<OrderResponse> CreateAsync(CreateOrderRequest request)
    {
        var order = new Order
        {
            CustomerName = request.CustomerName,
            Total = request.Total
        };
        _orders.Add(order);
        return Task.FromResult(ToResponse(order));
    }

    private static OrderResponse ToResponse(Order o)
        => new(o.Id, o.CustomerName, o.Total, o.CreatedAt);
}
```

### Step 4 — Register and Map Endpoints

```csharp
// ── Program.cs ────────────────────────────────────────────
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// WHY: Scoped because each request should get its own isolated service instance
builder.Services.AddScoped<IOrderService, InMemoryOrderService>();

var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI();

// ── GET all orders ────────────────────────────────────────
app.MapGet("/orders", async (IOrderService svc) =>
    Results.Ok(await svc.GetAllAsync()))
    .WithName("GetOrders")
    .WithTags("Orders");

// ── GET single order ──────────────────────────────────────
app.MapGet("/orders/{id:guid}", async (Guid id, IOrderService svc) =>
{
    var order = await svc.GetByIdAsync(id);
    return order is null ? Results.NotFound() : Results.Ok(order);
})
.WithName("GetOrderById")
.WithTags("Orders");

// ── POST create order ─────────────────────────────────────
app.MapPost("/orders", async (CreateOrderRequest request, IOrderService svc) =>
{
    var created = await svc.CreateAsync(request);
    // WHY: return 201 Created with Location header pointing to the new resource
    return Results.CreatedAtRoute("GetOrderById", new { id = created.Id }, created);
})
.WithName("CreateOrder")
.WithTags("Orders");

app.Run();
```

### Step 5 — Run and Test in Swagger

```bash
dotnet run
# Navigate to https://localhost:5001/swagger
# POST /orders with { "customerName": "Alice", "total": 99.99 }
# GET  /orders to see the list
# GET  /orders/{id} with the returned ID
```

---

## 5. DTOs vs Entities + Async Best Practices (50–58 min)

### DTOs vs Entities

| | Entity | DTO |
|---|--------|-----|
| **Purpose** | Persistence model | Transfer model |
| **Contains** | DB columns, navigation props | Only fields the caller needs |
| **Mutability** | Mutable (EF tracks changes) | Immutable (`record`) |
| **Location** | Infrastructure / Domain | Application / API layer |
| **Rule** | Never return from API | Always what the API returns/receives |

### Async Best Practices Quick Reference

```csharp
// ── GOOD ──────────────────────────────────────────────────
public async Task<Order?> GetByIdAsync(Guid id)
    => await _db.Orders.FindAsync(id);

// ── BAD — blocks thread, can deadlock in ASP.NET Core ─────
public Order? GetById(Guid id)
    => _db.Orders.FindAsync(id).Result;  // NEVER .Result

// ── ConfigureAwait note ───────────────────────────────────
// In ASP.NET Core: ConfigureAwait(false) is NOT needed
// WHY: ASP.NET Core has no SynchronizationContext — ConfigureAwait(false) is a no-op
```

---

## Key Takeaways

1. **Middleware = pipeline** — runs in registration order; exception handler must be first to catch all downstream errors.
2. **DI lifetimes matter** — Scoped for per-request state (DB context), Singleton for app-wide shared state, Transient for stateless services.
3. **DTOs separate your API contract from your data model** — never expose entities directly.
4. **Minimal APIs are production-ready** — less boilerplate than controllers with the same capability.
5. **Always `await` async methods** — `.Result` and `.Wait()` block threads and cause deadlocks.

---

## Q&A Prompts

1. What happens if you register a `Scoped` service but inject it into a `Singleton`?
2. Why do we use `Results.CreatedAtRoute` instead of just `Results.Ok` for POST?
3. When would you use a controller class instead of Minimal API?
4. Why should DTOs be `record` types rather than `class`?

---

## What's Next — Day 3

Your API works — but it's reading secrets like DB connection strings from `appsettings.json`. That's a security risk. Next session we'll see how to manage configuration safely, use the Options pattern, and read secrets from Azure Key Vault.
