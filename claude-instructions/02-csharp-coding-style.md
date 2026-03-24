# 02 — C# Coding Style & Patterns

> **Mental Model:** Code is written once, read a hundred times. Every non-obvious line
> must carry a "WHY" — the compiler understands the "what" already.

---

## Naming Conventions

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Element               │  Convention        │  Example                       │
├──────────────────────────────────────────────────────────────────────────────┤
│  Class                 │  PascalCase        │  OrderService                  │
│  Interface             │  IPascalCase       │  IOrderRepository              │
│  Record (DTO)          │  PascalCase        │  CreateOrderRequest            │
│  Method                │  PascalCase        │  GetByIdAsync                  │
│  Property              │  PascalCase        │  CustomerId                    │
│  Private field         │  _camelCase        │  _orderRepository              │
│  Local variable        │  camelCase         │  orderId                       │
│  Constant              │  PascalCase        │  MaxRetryCount                 │
│  Enum value            │  PascalCase        │  OrderStatus.Confirmed         │
│  Generic type param    │  T or TEntity      │  Result<TValue>                │
│  Async method          │  Suffix Async      │  GetOrderAsync                 │
│  Extension method      │  PascalCase        │  ToDto(), AddApplicationServices│
│  Test method           │  Should_When_      │  Should_ThrowException_WhenOrderNotFound │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Comment Style — The WHY Rule

```csharp
// ── RULE: Comment WHY, not WHAT. The code shows what. ────────────────────────

// ❌ WRONG — restates the code
// Gets the order by id
var order = await _repo.GetByIdAsync(id, ct);

// ✅ CORRECT — explains the reason
// WHY async: this always hits the database. Never use .Result here — it blocks
//   the thread pool under load and causes deadlocks in ASP.NET Core.
var order = await _repo.GetByIdAsync(id, ct);

// ── Section separators — use for logical groupings within a file ─────────────
// ── Service registrations ────────────────────────────────────────────────────
builder.Services.AddScoped<IOrderService, OrderService>();

// ── Inline clarifications — attach to the line, not above ───────────────────
return Results.Created($"/orders/{order.Id}", order.ToDto());  // 201 + Location header

// ── Block comments for complex logic ────────────────────────────────────────
// Retry with exponential backoff because Service Bus occasionally returns 429
// under burst load. We cap at 3 retries with 2^n * 100ms delays (100, 200, 400ms).
// Anything beyond 3 retries is likely a broker outage — re-throw for the caller.
```

---

## Record Types for DTOs

```csharp
// WHY records: immutable by default (no accidental mutation), structural equality,
//   built-in ToString(), with-expression for transformation, zero boilerplate.
//   Use for ALL request/response objects that cross layer boundaries.

// Request DTO — positional record (concise)
public record CreateOrderRequest(
    Guid CustomerId,
    IReadOnlyList<OrderLineItem> Items,
    string? Notes = null              // optional field with default
);

// Response DTO — positional record
public record OrderResponse(
    Guid Id,
    string Status,
    decimal Total,
    DateTimeOffset CreatedAt
);

// Nested value in a record
public record OrderLineItem(Guid ProductId, int Quantity, decimal UnitPrice);

// WHY NOT class for DTOs:
//   classes are mutable by default — a handler can accidentally modify a request DTO
//   records prevent that AND give you equality/ToString() for free in tests
```

---

## Async Patterns

```csharp
// ── RULE: Async all the way down. Never block. ────────────────────────────────

// ✅ CORRECT async method signature
public async Task<Order?> GetByIdAsync(OrderId id, CancellationToken ct = default)
{
    // Pass ct to every awaitable — allows request cancellation (user navigates away)
    return await _dbContext.Orders
        .Include(o => o.Items)
        .FirstOrDefaultAsync(o => o.Id == id, ct);   // WHY ct: honours HTTP request timeout
}

// ✅ ValueTask for hot paths (frequently called, often synchronous)
// WHY ValueTask: avoids heap allocation for Task when result is cached/synchronous
public ValueTask<bool> ExistsInCacheAsync(string key)
{
    var exists = _cache.TryGetValue(key, out _);
    return ValueTask.FromResult(exists);   // no allocation when cache hit
}

// ✅ ConfigureAwait(false) in library/infrastructure code
// WHY: infrastructure has no SynchronizationContext needs. Avoids deadlock in
//   frameworks that use a single-threaded sync context (old ASP.NET, WinForms).
//   In ASP.NET Core this doesn't matter but is good habit in shared libraries.
public async Task<string> ReadFileAsync(string path, CancellationToken ct)
{
    return await File.ReadAllTextAsync(path, ct).ConfigureAwait(false);
}

// ❌ NEVER do these:
task.Result;            // blocks thread — deadlocks under load
task.Wait();            // same problem
async void Method() {}  // exceptions swallowed — only acceptable in event handlers
```

---

## Dependency Injection Lifetimes

```csharp
// ── Lifetime decision tree ────────────────────────────────────────────────────
//
// AddSingleton  — one instance for the ENTIRE app lifetime
//   Use for: thread-safe stateless services, caches, config, HttpClient factories
//   DANGER: never inject Scoped or Transient into Singleton (captive dependency)
//
// AddScoped     — one instance per HTTP REQUEST
//   Use for: DbContext, Unit of Work, anything that must be consistent per request
//   DANGER: not safe to use outside a scope (background services need IServiceScopeFactory)
//
// AddTransient  — new instance every time it's requested
//   Use for: lightweight services with no shared state, validators, factories
//   DANGER: if it holds resources (IDisposable), they may not be disposed promptly

builder.Services.AddSingleton<IWebhookRegistry, WebhookRegistry>();   // thread-safe, stateful
builder.Services.AddScoped<IOrderRepository, OrderRepository>();       // per-request DB access
builder.Services.AddTransient<IOrderValidator, OrderValidator>();      // lightweight, stateless

// ── Background service needing scoped dependency ─────────────────────────────
public class OrderProcessingService(IServiceScopeFactory scopeFactory) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            // WHY CreateScope: BackgroundService is Singleton — can't inject Scoped directly.
            //   Create a new scope per unit of work to get a fresh DbContext.
            using var scope = scopeFactory.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<IOrderRepository>();
            await ProcessPendingOrdersAsync(repo, ct);
        }
    }
}
```

---

## Exception Handling Strategy

```csharp
// ── RULE: Domain throws, Application catches, API translates ─────────────────

// Domain — throw specific exceptions for invariant violations
public class OrderNotFoundException(Guid orderId)
    : Exception($"Order {orderId} was not found") { }

public class OrderNotEditableException(Guid orderId)
    : Exception($"Order {orderId} cannot be modified in its current status") { }

// Application — catch domain exceptions, convert to Result
// (Exceptions don't cross layer boundaries as control flow)

// API — global exception middleware translates to HTTP responses
// Never expose stack traces or internal error details to the client
app.UseExceptionHandler(errApp => errApp.Run(async ctx =>
{
    var ex = ctx.Features.Get<IExceptionHandlerFeature>()?.Error;

    var (status, code) = ex switch
    {
        OrderNotFoundException      => (404, "ORDER_NOT_FOUND"),
        OrderNotEditableException   => (409, "ORDER_NOT_EDITABLE"),
        ValidationException         => (400, "VALIDATION_FAILED"),
        UnauthorizedAccessException => (403, "FORBIDDEN"),
        _                          => (500, "INTERNAL_ERROR")
    };

    ctx.Response.StatusCode = status;
    await ctx.Response.WriteAsJsonAsync(new
    {
        Code = code,
        // WHY generic message for 500: never expose internals (stack trace, connection strings)
        Message = status == 500 ? "An unexpected error occurred" : ex!.Message,
        TraceId = ctx.TraceIdentifier   // correlate with logs without exposing stack trace
    });
}));
```

---

## Options Pattern for Configuration

```csharp
// WHY Options pattern: strongly-typed config, validated at startup, injectable.
//   Never use IConfiguration["key"] directly in services — no type safety, no validation.

// Options class — validates configuration at startup
public class ServiceBusOptions
{
    public const string SectionName = "ServiceBus";

    [Required]
    public string ConnectionString { get; init; } = string.Empty;

    [Required]
    public string QueueName { get; init; } = string.Empty;

    [Range(1, 100)]
    public int MaxConcurrentCalls { get; init; } = 10;
}

// Registration
builder.Services
    .AddOptions<ServiceBusOptions>()
    .BindConfiguration(ServiceBusOptions.SectionName)
    .ValidateDataAnnotations()          // validates on first use
    .ValidateOnStart();                 // WHY ValidateOnStart: catch missing config at startup,
                                        //   not on the first message processed (fail fast)

// Usage in a service — inject IOptions<T> or IOptionsSnapshot<T>
public class ServiceBusPublisher(IOptions<ServiceBusOptions> options)
{
    private readonly ServiceBusOptions _config = options.Value;
    // options.Value throws at startup if ValidateOnStart detected a problem
}
```

---

## Channel Pattern for Background Queues

```csharp
// WHY Channel<T>: bounded, backpressure-aware, allocation-efficient.
//   Don't use ConcurrentQueue + Thread.Sleep polling — wasteful and no backpressure.

public class WebhookDispatcher : BackgroundService
{
    // Bounded channel — rejects writes when full (caller gets false from TryWrite)
    // WHY BoundedChannelFullMode.Wait: producer awaits instead of dropping or crashing
    private readonly Channel<WebhookEvent> _queue =
        Channel.CreateBounded<WebhookEvent>(new BoundedChannelOptions(500)
        {
            FullMode = BoundedChannelFullMode.Wait,   // back-pressure: block producer
            SingleReader = true,                       // WHY: one background worker reads
            SingleWriter = false                       // WHY: many API calls can enqueue
        });

    public async ValueTask EnqueueAsync(WebhookEvent evt, CancellationToken ct)
        => await _queue.Writer.WriteAsync(evt, ct);

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        // ReadAllAsync is the cleanest consumer — async-enumerable over the channel
        await foreach (var evt in _queue.Reader.ReadAllAsync(ct))
        {
            await DispatchAsync(evt, ct);
        }
    }
}
```

---

## Strongly-Typed IDs

```csharp
// WHY strongly-typed IDs: prevents passing a CustomerId where OrderId is expected.
//   Guid is Guid — compiler won't catch swapped parameters. Wrapper types do.

[StronglyTypedId]   // use StronglyTypedId NuGet OR write the record manually
public readonly record struct OrderId(Guid Value)
{
    public static OrderId New() => new(Guid.NewGuid());
    public static OrderId Parse(string s) => new(Guid.Parse(s));
    public override string ToString() => Value.ToString();
}

// Usage — compile-time error if you pass wrong ID type
void ProcessOrder(OrderId orderId, CustomerId customerId) { ... }

// ❌ compiler error: ProcessOrder(customerId, orderId);  — caught at compile time
// ✅ correct:        ProcessOrder(orderId, customerId);
```

---

## Cancellation Token Propagation

```csharp
// RULE: Accept CancellationToken in every public async method.
//       Pass it to every awaitable inside.
//       Never use CancellationToken.None in production code paths.

// WHY: HTTP requests carry a timeout. When a client disconnects or times out,
//   ASP.NET Core cancels the request's token. Without propagation, the server
//   keeps running the full query/HTTP call even after nobody is waiting for it.

public async Task<IReadOnlyList<Order>> GetPagedOrdersAsync(
    int page, int pageSize,
    CancellationToken ct)                           // always accept ct
{
    return await _dbContext.Orders
        .OrderByDescending(o => o.CreatedAt)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync(ct);                           // always pass ct
}
```
