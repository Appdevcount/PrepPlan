# Session 02 — Building APIs (Enriched)

**Duration:** 60 minutes
**Audience:** Developers who completed Session 01
**Goal:** Understand the ASP.NET Core request pipeline, wire up Dependency Injection, add model validation, and build a working Minimal API with Swagger — live.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | What is ASP.NET Core? |
| 5–18 min | The Request Pipeline — Middleware |
| 18–30 min | Dependency Injection — Lifetimes Explained |
| 30–44 min | Live Demo — Build a Minimal API from Scratch |
| 44–52 min | Model Validation |
| 52–58 min | DTOs vs Entities + Async Best Practices |
| 58–60 min | Key Takeaways + Q&A |

---

## 1. What is ASP.NET Core? (0–5 min)

### Mental Model
> ASP.NET Core is a **pipeline of middleware** — imagine a series of airport security checkpoints. Every HTTP request walks through them one by one. Each checkpoint can inspect, modify, short-circuit, or pass the request along.

ASP.NET Core is:
- Cross-platform (runs on Linux, Windows, Mac, Docker containers)
- Consistently ranked among the **fastest web frameworks** globally (TechEmpower benchmarks)
- Ships with built-in DI, configuration, logging, health checks — no third-party needed for basics

---

## 2. The Request Pipeline — Middleware (5–18 min)

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
var builder = WebApplication.CreateBuilder(args);

// ── Register services into DI container ──────────────────
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IOrderService, OrderService>();

var app = builder.Build();

// ── Register middleware — ORDER MATTERS ──────────────────
// WHY: exception handler must come before routing to catch errors
// from all downstream middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();  // must come before UseAuthorization
app.UseAuthorization();

app.MapGet("/health", () => Results.Ok("Healthy"));

app.Run();
```

### Writing Custom Middleware

```csharp
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
        _logger.LogInformation("→ {Method} {Path}", context.Request.Method, context.Request.Path);
        await _next(context);  // pass to next middleware
        _logger.LogInformation("← {StatusCode}", context.Response.StatusCode);
    }
}

// Register it — placed before routing
app.UseMiddleware<RequestLoggingMiddleware>();
```

---

## 3. Dependency Injection — Lifetimes Explained (18–30 min)

### Mental Model
> DI is a **hotel concierge**. You tell reception (the DI container) what services you need; it creates and delivers them to your room (your class). You don't go find them yourself. Lifetime controls how long the concierge keeps the same instance vs. making a new one.

### The 3 Lifetimes

```
┌──────────────┬────────────────────────────────┬─────────────────────────────────┐
│  Lifetime    │  Created When                  │  Use For                        │
├──────────────┼────────────────────────────────┼─────────────────────────────────┤
│  Singleton   │  Once for entire app lifetime  │  Config, caches, HTTP clients   │
│  Scoped      │  Once per HTTP request         │  DB context, unit of work       │
│  Transient   │  Every time it is requested    │  Lightweight, stateless helpers │
└──────────────┴────────────────────────────────┴─────────────────────────────────┘
```

```csharp
// ── Registration ─────────────────────────────────────────
builder.Services.AddSingleton<IMemoryCache, MemoryCache>();
builder.Services.AddScoped<AppDbContext>();
builder.Services.AddTransient<IEmailService, SmtpEmailService>();

// ── Constructor Injection ─────────────────────────────────
// WHY: constructor injection makes dependencies explicit and testable
public class OrdersController
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(IOrderService orderService, ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }
}
```

### Common Mistake — Captive Dependency

```csharp
// WRONG — injecting a Scoped service into a Singleton
builder.Services.AddSingleton<MySingleton>();
builder.Services.AddScoped<MyScoped>();
// ASP.NET Core detects this and throws at startup — good!

// FIX: inject IServiceScopeFactory into the Singleton and create a scope manually
public class MySingleton
{
    private readonly IServiceScopeFactory _scopeFactory;
    public MySingleton(IServiceScopeFactory scopeFactory) => _scopeFactory = scopeFactory;

    public async Task DoWorkAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var myScoped = scope.ServiceProvider.GetRequiredService<MyScoped>();
    }
}
```

---

## 4. Live Demo — Build a Minimal API from Scratch (30–44 min)

### Step 1 — Create the Project

```bash
dotnet new webapi -n OrderApi --use-minimal-apis
cd OrderApi
dotnet run
# Open https://localhost:5001/swagger
```

### Step 2 — Define Domain Model and DTOs

```csharp
public class Order
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string CustomerName { get; set; } = string.Empty;
    public decimal Total { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

// WHY: never expose the entity directly — entities carry EF internals
public record OrderResponse(Guid Id, string CustomerName, decimal Total, DateTime CreatedAt);
public record CreateOrderRequest(string CustomerName, decimal Total);
```

### Step 3 — Service + Endpoints

```csharp
public interface IOrderService
{
    Task<IEnumerable<OrderResponse>> GetAllAsync();
    Task<OrderResponse?> GetByIdAsync(Guid id);
    Task<OrderResponse> CreateAsync(CreateOrderRequest request);
}

public class InMemoryOrderService : IOrderService
{
    private readonly List<Order> _orders = new();

    public Task<IEnumerable<OrderResponse>> GetAllAsync()
        => Task.FromResult(_orders.Select(ToResponse));

    public Task<OrderResponse?> GetByIdAsync(Guid id)
    {
        var o = _orders.FirstOrDefault(o => o.Id == id);
        return Task.FromResult(o is null ? null : ToResponse(o));
    }

    public Task<OrderResponse> CreateAsync(CreateOrderRequest request)
    {
        var order = new Order { CustomerName = request.CustomerName, Total = request.Total };
        _orders.Add(order);
        return Task.FromResult(ToResponse(order));
    }

    private static OrderResponse ToResponse(Order o)
        => new(o.Id, o.CustomerName, o.Total, o.CreatedAt);
}
```

### Step 4 — Program.cs with Endpoints

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IOrderService, InMemoryOrderService>();

var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/orders", async (IOrderService svc) =>
    Results.Ok(await svc.GetAllAsync()))
    .WithName("GetOrders").WithTags("Orders");

app.MapGet("/orders/{id:guid}", async (Guid id, IOrderService svc) =>
{
    var order = await svc.GetByIdAsync(id);
    return order is null ? Results.NotFound() : Results.Ok(order);
})
.WithName("GetOrderById").WithTags("Orders");

app.MapPost("/orders", async (CreateOrderRequest request, IOrderService svc) =>
{
    var created = await svc.CreateAsync(request);
    return Results.CreatedAtRoute("GetOrderById", new { id = created.Id }, created);
})
.WithName("CreateOrder").WithTags("Orders");

app.Run();
```

---

## 5. Model Validation (44–52 min)

### Mental Model
> Validation is a **bouncer at the door**. Bad data should be rejected at the entry point before it ever reaches your business logic or database.

### DataAnnotations — Declarative Validation

```csharp
public class CreateOrderRequest
{
    [Required(ErrorMessage = "Customer name is required")]
    [MaxLength(100, ErrorMessage = "Customer name cannot exceed 100 characters")]
    public string CustomerName { get; set; } = string.Empty;

    [Range(0.01, 1_000_000, ErrorMessage = "Total must be between 0.01 and 1,000,000")]
    public decimal Total { get; set; }

    [Required]
    [MinLength(1)]
    public List<string> Items { get; set; } = new();
}
```

### Manual Validation in Minimal APIs

```csharp
app.MapPost("/orders", async (CreateOrderRequest request, IOrderService svc) =>
{
    var validationResults = new List<ValidationResult>();
    var context = new ValidationContext(request);

    if (!Validator.TryValidateObject(request, context, validationResults, validateAllProperties: true))
    {
        var errors = validationResults.ToDictionary(
            v => v.MemberNames.FirstOrDefault() ?? "field",
            v => new[] { v.ErrorMessage ?? "Invalid" });

        return Results.ValidationProblem(errors);
    }

    var created = await svc.CreateAsync(request);
    return Results.CreatedAtRoute("GetOrderById", new { id = created.Id }, created);
});
```

### Fluent Validation (Preferred for Complex Rules)

```bash
dotnet add package FluentValidation.AspNetCore
```

```csharp
public class CreateOrderRequestValidator : AbstractValidator<CreateOrderRequest>
{
    public CreateOrderRequestValidator()
    {
        RuleFor(x => x.CustomerName)
            .NotEmpty().WithMessage("Customer name is required")
            .MaximumLength(100);

        RuleFor(x => x.Total)
            .GreaterThan(0).WithMessage("Total must be positive")
            .LessThanOrEqualTo(1_000_000);

        RuleFor(x => x.Items).NotEmpty().WithMessage("At least one item is required");
    }
}

builder.Services.AddValidatorsFromAssemblyContaining<CreateOrderRequestValidator>();

app.MapPost("/orders", async (
    CreateOrderRequest request,
    IValidator<CreateOrderRequest> validator,
    IOrderService svc) =>
{
    var result = await validator.ValidateAsync(request);
    if (!result.IsValid)
        return Results.ValidationProblem(result.ToDictionary());

    var created = await svc.CreateAsync(request);
    return Results.CreatedAtRoute("GetOrderById", new { id = created.Id }, created);
});
```

### Validation Error Response Shape

```json
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "CustomerName": ["Customer name is required"],
    "Total": ["Total must be positive"]
  }
}
```

---

## 6. DTOs vs Entities + Async Best Practices (52–58 min)

### DTOs vs Entities

| | Entity | DTO |
|---|--------|-----|
| **Purpose** | Persistence model | Transfer model |
| **Contains** | DB columns, navigation props | Only fields the caller needs |
| **Mutability** | Mutable (EF tracks changes) | Immutable (`record`) |
| **Location** | Infrastructure / Domain | Application / API layer |
| **Rule** | Never return from API | Always what the API returns/receives |

### Async Best Practices

```csharp
// GOOD
public async Task<Order?> GetByIdAsync(Guid id)
    => await _db.Orders.FindAsync(id);

// BAD — blocks thread, can deadlock
public Order? GetById(Guid id)
    => _db.Orders.FindAsync(id).Result;  // NEVER .Result
```

---

## Azure Integration

> **For the Azure-focused audience** — this section covers how your Minimal API connects to Azure hosting and gateway services.

### Deploying Your API to Azure App Service

```bash
dotnet publish -c Release -o ./publish

az webapp deploy \
  --resource-group MyRG \
  --name my-order-api \
  --src-path ./publish \
  --type zip
```

### Environment-Specific Swagger

```csharp
// WHY: Swagger in production reveals your API surface to attackers
if (app.Environment.IsDevelopment() || app.Environment.IsStaging())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Order API v1");
        c.RoutePrefix = string.Empty;
    });
}
```

### Swagger Enrichment — Response Types

```csharp
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Order API",
        Version = "v1",
        Description = "Manages customer orders"
    });
});

app.MapGet("/orders/{id:guid}", async (Guid id, IOrderService svc) =>
{
    var order = await svc.GetByIdAsync(id);
    return order is null ? Results.NotFound() : Results.Ok(order);
})
.Produces<OrderResponse>(200)
.Produces(404)
.WithSummary("Get a single order by ID");
```

### Azure API Management + Your API

```
What APIM adds on top of your Minimal API:
  ┌─────────────────────────────────────────────────────┐
  │  APIM Policy (applied before your API is called)   │
  │                                                     │
  │  <inbound>                                          │
  │    <rate-limit calls="100" renewal-period="60"/>   │  ← rate limiting
  │    <validate-jwt header-name="Authorization"/>     │  ← JWT check at gateway
  │    <set-header name="X-API-Version" value="v1"/>  │  ← header injection
  │  </inbound>                                         │
  └─────────────────────────────────────────────────────┘
  Offloads cross-cutting concerns from your API code
```

---

## Key Takeaways

1. **Middleware = pipeline** — runs in registration order; exception handler must be first.
2. **DI lifetimes matter** — Scoped for per-request state, Singleton for app-wide, Transient for stateless.
3. **Validate at the boundary** — reject bad input at the API layer with `Results.ValidationProblem()`.
4. **DTOs separate your API contract from your data model** — never expose entities directly.
5. **Always `await` async methods** — `.Result` and `.Wait()` block threads and cause deadlocks.

---

## Q&A Prompts

**1. What happens if you register a `Scoped` service but inject it into a `Singleton`?**

**Answer:** The Scoped service gets "captured" inside the Singleton and is never released per-request — it becomes effectively a Singleton too, which can cause stale data and concurrency bugs. ASP.NET Core detects this at startup and throws an `InvalidOperationException` by default. Fix it by injecting `IServiceScopeFactory` into the Singleton and creating a scope manually per unit of work.

---

**2. Why do we use `Results.CreatedAtRoute` instead of just `Results.Ok` for POST?**

**Answer:** `201 Created` tells the caller that a new resource was created. The `Location` header in the response tells them exactly where to find the new resource — they can immediately do a `GET` to that URL. `200 OK` provides none of this context. Many clients and API tools rely on this distinction for correct behavior.

---

**3. When would you use a controller class instead of Minimal API?**

**Answer:** Minimal APIs are the modern preferred approach. Controllers are better when: you have many related endpoints that benefit from class grouping, you need automatic model binding validation (controllers auto-return 400 on failed DataAnnotations), or you're maintaining an existing controller-based codebase. New projects should default to Minimal APIs.

---

**4. Why should request/response DTOs be `record` types rather than `class`?**

**Answer:** `record` enforces immutability (properties are `init`-only by default) which is correct for DTOs — you shouldn't mutate a request after deserialization. Records also generate value-based equality and a useful `ToString()` for free. A `class` DTO would require manually adding `{ get; init; }` on every property to achieve the same safety.

---

## What's Next — Day 3

Your API works — but it's reading the DB connection string from `appsettings.json`. That's a security risk. Next session we'll see how to manage configuration safely, use the Options pattern for typed config, and read secrets from Azure Key Vault without any credentials in your code.
