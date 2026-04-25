# Session 07 — Scalable Enterprise Design

**Duration:** 60 minutes
**Audience:** Developers who completed all previous sessions
**Goal:** Understand how to cache data to reduce database load, offload work with background jobs, design stateless services that scale horizontally, and where Azure Functions fit in the picture.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | The Scalability Problem |
| 5–20 min | Caching — IMemoryCache vs IDistributedCache |
| 20–35 min | Background Jobs — IHostedService / BackgroundService |
| 35–48 min | Stateless Design — Why Sessions Are Dangerous |
| 48–56 min | Azure Functions — The Concept |
| 56–60 min | Key Takeaways + Q&A |

---

## 1. The Scalability Problem (0–5 min)

### Mental Model
> A single server is like a single cashier at a supermarket. More customers = longer queues. Scalability means **adding more cashiers** when queues grow — but only if each cashier can work independently. If they all share a single cash drawer (shared state), adding more doesn't help.

**The 3 bottlenecks in most .NET APIs:**

```
┌───────────────────────────────────────────────────────────────┐
│  1. Repeated DB reads      → Cache frequently-read data       │
│  2. Long-running work      → Move to background jobs          │
│  3. Shared in-memory state → Stateless design + external state│
└───────────────────────────────────────────────────────────────┘
```

---

## 2. Caching — IMemoryCache vs IDistributedCache (5–20 min)

### Mental Model
> Cache is the **whiteboard next to your desk** — answers to common questions written down so you don't make a trip to the filing room (database) every time. If the whiteboard is only on your desk, it helps only you. If it's in the hallway (distributed cache), everyone benefits.

### IMemoryCache — In-Process Cache

```csharp
// ── Register ──────────────────────────────────────────────
builder.Services.AddMemoryCache();

// ── Usage ─────────────────────────────────────────────────
public class ProductService
{
    private readonly IMemoryCache _cache;
    private readonly AppDbContext _db;

    public ProductService(IMemoryCache cache, AppDbContext db)
    {
        _cache = cache;
        _db = db;
    }

    public async Task<Product?> GetByIdAsync(int id)
    {
        string cacheKey = $"product:{id}";

        // GetOrCreateAsync: return cached value or compute + store it
        return await _cache.GetOrCreateAsync(cacheKey, async entry =>
        {
            // WHY: set expiry so stale data is automatically evicted
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10);
            entry.SlidingExpiration = TimeSpan.FromMinutes(2);

            // Only runs on a cache miss
            return await _db.Products.FindAsync(id);
        });
    }

    public void InvalidateProduct(int id)
    {
        // Remove from cache when data changes
        _cache.Remove($"product:{id}");
    }
}
```

**Limitation:** Lives in the process's memory. If you run 3 instances of your API, each has its own cache — they can get out of sync.

### IDistributedCache — Shared Cache (Redis)

```csharp
// ── Register Azure Cache for Redis ───────────────────────
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration["Redis:ConnectionString"];
});

// ── Usage ─────────────────────────────────────────────────
public class ProductService
{
    private readonly IDistributedCache _cache;
    private readonly AppDbContext _db;

    public ProductService(IDistributedCache cache, AppDbContext db)
    {
        _cache = cache;
        _db = db;
    }

    public async Task<Product?> GetByIdAsync(int id)
    {
        string cacheKey = $"product:{id}";

        // IDistributedCache stores bytes — serialize/deserialize manually
        var cached = await _cache.GetStringAsync(cacheKey);
        if (cached is not null)
            return JsonSerializer.Deserialize<Product>(cached);

        var product = await _db.Products.FindAsync(id);
        if (product is not null)
        {
            await _cache.SetStringAsync(cacheKey,
                JsonSerializer.Serialize(product),
                new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
                });
        }
        return product;
    }
}
```

### When to Use Which

```
┌─────────────────────┬───────────────────────────────────────────────┐
│  IMemoryCache       │  IDistributedCache (Redis)                    │
├─────────────────────┼───────────────────────────────────────────────┤
│  Single instance    │  Multiple instances (scale-out)               │
│  Fast (in-process)  │  Slightly slower (network hop to Redis)       │
│  Lost on restart    │  Survives restarts                            │
│  Dev / simple apps  │  Production APIs with horizontal scaling      │
└─────────────────────┴───────────────────────────────────────────────┘
```

### Output Caching (ASP.NET Core 7+)

```csharp
// ── Cache entire HTTP responses — no service layer code ───
builder.Services.AddOutputCache();
app.UseOutputCache();

app.MapGet("/products", async (AppDbContext db) =>
    Results.Ok(await db.Products.AsNoTracking().ToListAsync()))
    .CacheOutput(policy => policy
        .Expire(TimeSpan.FromMinutes(5))
        .Tag("products"));  // tag allows targeted invalidation

// Invalidate when data changes
app.MapPost("/products", async (CreateProductRequest req, IOutputCacheStore store) =>
{
    // ... create product ...
    await store.EvictByTagAsync("products", default);  // clear cached responses
    return Results.Created(...);
});
```

---

## 3. Background Jobs — IHostedService / BackgroundService (20–35 min)

### Mental Model
> A background service is like the **kitchen staff working while the dining room is open**. The waiter (API endpoint) takes the order quickly and returns to the customer. The kitchen (background job) processes it separately without making the customer wait.

### The Problem Without Background Jobs

```
// SLOW: user waits 8 seconds for email + PDF + audit log
app.MapPost("/orders", async (CreateOrderRequest req, OrderService svc) =>
{
    var order = await svc.CreateAsync(req);         // 100ms
    await emailService.SendAsync(order);            // 2000ms  ← user waits
    await pdfService.GenerateInvoiceAsync(order);   // 5000ms  ← user waits
    await auditService.LogAsync(order);             // 800ms   ← user waits
    return Results.Ok(order);                       // total: ~8 seconds
});

// FAST: return immediately, process in background
app.MapPost("/orders", async (CreateOrderRequest req, OrderService svc,
    IBackgroundTaskQueue queue) =>
{
    var order = await svc.CreateAsync(req);         // 100ms
    queue.Enqueue(order);                           // <1ms — just add to queue
    return Results.Accepted();                      // total: ~101ms
});
// Email, PDF, audit run asynchronously in background
```

### BackgroundService — Long-Running Background Work

```csharp
// ── BackgroundService runs for the lifetime of the app ───
public class OrderProcessingService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<OrderProcessingService> _logger;

    public OrderProcessingService(IServiceScopeFactory scopeFactory,
        ILogger<OrderProcessingService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Order processing service started");

        // WHY: stoppingToken is signaled when the app shuts down
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessPendingOrdersAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                _logger.LogError(ex, "Error in order processing loop");
            }

            // Wait 30 seconds before next check
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }

        _logger.LogInformation("Order processing service stopped");
    }

    private async Task ProcessPendingOrdersAsync(CancellationToken ct)
    {
        // WHY: BackgroundService is Singleton; DbContext is Scoped
        // Must create a new scope to resolve Scoped services
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var pendingOrders = await db.Orders
            .Where(o => o.Status == OrderStatus.Pending)
            .Take(10)
            .ToListAsync(ct);

        foreach (var order in pendingOrders)
        {
            // ... process each order ...
            _logger.LogInformation("Processed order {OrderId}", order.Id);
        }
    }
}
```

### Register Background Services

```csharp
// ── Register as a hosted service ─────────────────────────
builder.Services.AddHostedService<OrderProcessingService>();

// Multiple hosted services run concurrently
builder.Services.AddHostedService<EmailNotificationService>();
builder.Services.AddHostedService<MetricsCollectionService>();
```

### In-Memory Background Task Queue

```csharp
// ── Simple queue for fire-and-forget tasks ────────────────
public interface IBackgroundTaskQueue
{
    void Enqueue(Func<IServiceProvider, CancellationToken, Task> workItem);
    Task<Func<IServiceProvider, CancellationToken, Task>> DequeueAsync(CancellationToken ct);
}

public class BackgroundTaskQueue : IBackgroundTaskQueue
{
    private readonly Channel<Func<IServiceProvider, CancellationToken, Task>> _queue
        = Channel.CreateUnbounded<Func<IServiceProvider, CancellationToken, Task>>();

    public void Enqueue(Func<IServiceProvider, CancellationToken, Task> workItem)
        => _queue.Writer.TryWrite(workItem);

    public async Task<Func<IServiceProvider, CancellationToken, Task>> DequeueAsync(CancellationToken ct)
        => await _queue.Reader.ReadAsync(ct);
}

// Enqueue from your endpoint:
queue.Enqueue(async (services, ct) =>
{
    var emailSvc = services.GetRequiredService<IEmailService>();
    await emailSvc.SendAsync(order.CustomerName, "Order Confirmed", "...");
});
```

---

## 4. Stateless Design — Why Sessions Are Dangerous (35–48 min)

### Mental Model
> Stateless design means each request carries **everything the server needs** — no memory between requests. It's like a fast food counter: you hand over your order slip each time, the cashier doesn't remember you from last time. This means any cashier (server instance) can serve you.

### The Problem with Server-Side Sessions

```
3 API instances running:

Request 1 → Instance A (stores session: userId=42, cartItems=[...])
Request 2 → Instance B (looks for session — NOT FOUND! Returns empty cart)
Request 3 → Instance C (looks for session — NOT FOUND! Returns 401)

With sticky sessions (load balancer always routes userId=42 to Instance A):
• If Instance A crashes → session lost
• Uneven load — some instances overloaded, others idle
• Can't scale down Instance A without losing sessions
```

### The Stateless Solution

```
┌────────────────────────────────────────────────────────────────┐
│  State Type          │  Where It Lives                         │
├────────────────────────────────────────────────────────────────┤
│  Authentication      │  JWT token (client holds it)            │
│  User session data   │  Redis / Cosmos DB (external)           │
│  Shopping cart       │  Database (or Redis for temp data)      │
│  File uploads        │  Azure Blob Storage                     │
│  Long job status     │  Database record with status field      │
└────────────────────────────────────────────────────────────────┘
```

```csharp
// ── WRONG: state in instance memory ──────────────────────
public class CartService
{
    // This dictionary is instance-specific — not shared across pods
    private readonly Dictionary<string, List<CartItem>> _carts = new();

    public void AddItem(string userId, CartItem item)
        => _carts.GetOrAdd(userId, _ => new()).Add(item); // lost on restart!
}

// ── RIGHT: state in external store ───────────────────────
public class CartService
{
    private readonly IDistributedCache _cache;

    public async Task AddItemAsync(string userId, CartItem item)
    {
        var key = $"cart:{userId}";
        var cart = await GetCartAsync(userId) ?? new Cart();
        cart.Items.Add(item);

        await _cache.SetStringAsync(key, JsonSerializer.Serialize(cart),
            new DistributedCacheEntryOptions
            {
                SlidingExpiration = TimeSpan.FromHours(24)
            });
    }
}
```

### Horizontal Scaling — The Payoff

```
With stateless design:

Load Balancer
  ├─ Instance 1  ← any request from any user
  ├─ Instance 2  ← any request from any user
  └─ Instance 3  ← any request from any user

All read state from Redis / DB — fully consistent
Scale from 3 → 10 instances in seconds (AKS auto-scaling)
One instance crashes → no data lost, load balancer routes to others
```

---

## 5. Azure Functions — The Concept (48–56 min)

### Mental Model
> Azure Functions is **your code, without the server**. You write a method that handles an event — an HTTP request, a queue message, a timer tick, a file upload. Azure runs it, scales it, and you pay only for the time it's actually executing.

```
┌──────────────────────────────────────────────────────────────────────┐
│  Traditional API (App Service):                                      │
│    Server always running → billing even when idle                    │
│    You manage scale rules                                            │
│                                                                      │
│  Azure Functions:                                                    │
│    Wakes up on trigger → processes → sleeps → billing per execution  │
│    Auto-scales to 0 (Consumption plan) or pre-warmed (Premium)      │
└──────────────────────────────────────────────────────────────────────┘
```

### Trigger Types

```
┌─────────────────────┬──────────────────────────────────────────────┐
│  Trigger            │  When It Fires                               │
├─────────────────────┼──────────────────────────────────────────────┤
│  HttpTrigger        │  HTTP request to a URL                       │
│  TimerTrigger       │  Cron schedule (every 5 min, daily at 2am)   │
│  ServiceBusTrigger  │  Message arrives on a Service Bus queue      │
│  BlobTrigger        │  File uploaded to Azure Blob Storage         │
│  QueueTrigger       │  Message arrives on Azure Storage Queue      │
│  CosmosDbTrigger    │  Document changed in Cosmos DB               │
└─────────────────────┴──────────────────────────────────────────────┘
```

### Code Examples

```csharp
// ── HTTP Trigger — lightweight API endpoint ───────────────
public class OrderFunctions
{
    private readonly IOrderService _orderService;

    public OrderFunctions(IOrderService orderService)
        => _orderService = orderService;  // DI works in Functions too

    [Function("GetOrder")]
    public async Task<HttpResponseData> GetOrderAsync(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "orders/{id}")] HttpRequestData req,
        Guid id)
    {
        var order = await _orderService.GetByIdAsync(id);
        if (order is null) return req.CreateResponse(HttpStatusCode.NotFound);

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(order);
        return response;
    }

    // ── Timer Trigger — runs on a schedule ────────────────
    [Function("DailyReport")]
    public async Task RunDailyReport(
        [TimerTrigger("0 0 2 * * *")] TimerInfo timer)  // every day at 2am UTC
    {
        // Generate and email daily order report
        await _orderService.SendDailyReportAsync();
    }

    // ── Service Bus Trigger — process messages async ──────
    [Function("ProcessOrderMessage")]
    public async Task ProcessMessage(
        [ServiceBusTrigger("orders-queue", Connection = "ServiceBus")] ServiceBusReceivedMessage msg)
    {
        var order = JsonSerializer.Deserialize<Order>(msg.Body);
        await _orderService.ProcessAsync(order!);
    }
}
```

### When to Use Functions vs App Service

```
┌─────────────────────────────┬──────────────────────────────────────┐
│  Use Azure Functions when   │  Use App Service / AKS when          │
├─────────────────────────────┼──────────────────────────────────────┤
│  Event-driven processing    │  Always-on web API                   │
│  Scheduled tasks            │  Complex routing / middleware        │
│  Fan-out/fan-in patterns    │  Long-running requests (>10 min)     │
│  Variable / spiky load      │  Predictable, steady load            │
│  Cost: pay per execution    │  Cost: pay per running instance      │
└─────────────────────────────┴──────────────────────────────────────┘
```

---

## Architecture Recap — All 7 Sessions in One Diagram

```
                         Client (Browser / Mobile)
                                   │
                                   ▼
                      Azure API Management (Session 04: Auth)
                                   │
                                   ▼
                        Azure App Service / AKS
                     ┌─────────────────────────────┐
                     │  ASP.NET Core Minimal API    │ ← Session 02
                     │  ┌─────────────────────────┐│
                     │  │  Application Layer       ││ ← Session 01
                     │  │  (Use Cases / Handlers)  ││
                     │  └────────────┬────────────┘│
                     │               │             │
                     │  ┌────────────▼───────────┐ │
                     │  │  Infrastructure Layer   │ │ ← Session 05
                     │  │  EF Core + DbContext    │ │
                     │  └────────────┬────────────┘│
                     └───────────────┼─────────────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              ▼                      ▼                       ▼
        Azure SQL DB           Azure Redis Cache        Azure Blob
        (Session 05)           (Session 07)             Storage
              │
              └── Observed by Azure Application Insights (Session 06)
              └── Secrets from Azure Key Vault (Session 03)
              └── Background jobs (Session 07)
              └── Azure Functions for async processing (Session 07)
```

---

## Key Takeaways

1. **Cache to reduce DB pressure** — `IMemoryCache` for single-instance, `IDistributedCache` (Redis) for multi-instance.
2. **Background services decouple work from requests** — return 202 Accepted immediately; process asynchronously.
3. **Stateless = scalable** — never store state in instance memory; use Redis, DB, or the JWT token itself.
4. **`IServiceScopeFactory` in background services** — BackgroundService is Singleton; always create a scope to resolve Scoped services like DbContext.
5. **Azure Functions for event-driven work** — triggers (HTTP, timer, queue, blob) handle scaling and infrastructure automatically.

---

## Q&A Prompts

1. You have 5 running API instances. A user adds items to their cart. Which instance will handle their next request? How do you ensure they see their cart? *(Answer: any instance — state must be in Redis, not in-process)*
2. Why can't you inject `AppDbContext` directly into `BackgroundService`? What do you use instead?
3. What's the difference between `AbsoluteExpiration` and `SlidingExpiration` in a cache entry?
4. When would you choose Azure Functions over a BackgroundService in your ASP.NET Core app?

---

## Course Wrap-Up

Congratulations — you've covered the full stack of a production .NET + Azure application:

| Session | What You Learned |
|---------|-----------------|
| Intro | C# types, interfaces, async/await |
| Day 1 | Clean Architecture + Azure service mapping |
| Day 2 | ASP.NET Core pipeline, DI, Minimal APIs |
| Day 3 | Configuration, Options pattern, Key Vault |
| Day 4 | JWT, claims, policies, Entra ID |
| Day 5 | EF Core, LINQ, migrations, Azure SQL |
| Day 6 | Logging, exception handling, health checks, App Insights |
| Day 7 | Caching, background jobs, stateless design, Azure Functions |

**Recommended Next Steps:**
- Build a small end-to-end project combining all 7 topics
- Explore CQRS + MediatR for the application layer
- Deep dive into Azure AKS for container orchestration
- Study the Saga pattern for distributed transactions
