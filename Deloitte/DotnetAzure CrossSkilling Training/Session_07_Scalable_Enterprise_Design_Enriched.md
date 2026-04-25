# Session 07 — Scalable Enterprise Design (Enriched)

**Duration:** 60 minutes
**Audience:** Developers who completed all previous sessions
**Goal:** Understand how to cache data to reduce database load, offload work with background jobs, design stateless services that scale horizontally, understand event-driven patterns with Azure Service Bus, and where Azure Functions and API Management fit in the picture.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | The Scalability Problem |
| 5–20 min | Caching — IMemoryCache vs IDistributedCache |
| 20–35 min | Background Jobs — IHostedService / BackgroundService |
| 35–45 min | Stateless Design — Why Sessions Are Dangerous |
| 45–55 min | Event-Driven Basics — Azure Service Bus |
| 55–60 min | Key Takeaways + Q&A |

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

### Cache Expiration — Absolute vs Sliding

```
┌────────────────────────┬──────────────────────────────────────────────────┐
│  AbsoluteExpiration    │  Entry expires at a fixed point in time          │
│                        │  Good for: data that changes on a known schedule │
│                        │  e.g., product catalog refreshed every 10 min    │
├────────────────────────┼──────────────────────────────────────────────────┤
│  SlidingExpiration     │  Entry expires if not accessed for N minutes     │
│                        │  Timer resets on every access                    │
│                        │  Good for: user session data, hot items          │
│                        │  Risk: popular items never expire (use both!)    │
└────────────────────────┴──────────────────────────────────────────────────┘

// WHY: combine both — absolute prevents indefinite retention, sliding removes idle entries
entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10); // hard cap
entry.SlidingExpiration = TimeSpan.FromMinutes(2);                 // evict if idle
```

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

### BackgroundService vs IHostedService — When to Use Which

```
┌──────────────────────┬───────────────────────────────────────────────────┐
│  BackgroundService   │  Abstract base class — wraps IHostedService       │
│                      │  Use: long-running loops (polling, processing)    │
│                      │  Built-in cancellation token wiring               │
├──────────────────────┼───────────────────────────────────────────────────┤
│  IHostedService      │  Raw interface with StartAsync/StopAsync          │
│                      │  Use: initialization work, one-shot startup tasks │
└──────────────────────┴───────────────────────────────────────────────────┘
```

---

## 4. Stateless Design — Why Sessions Are Dangerous (35–45 min)

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

## 5. Event-Driven Basics — Azure Service Bus (45–55 min)

### Mental Model
> Service Bus is a **post office between services**. Service A drops a letter (message) in a mailbox (queue). Service B picks it up and processes it whenever it's ready. Neither needs to know about the other's schedule — they're decoupled in time.

### Why Not Just Call the Other Service Directly?

```
Without messaging (direct HTTP call):
  API-A  ──── POST /process ────►  API-B
                                     │
              API-B is down ◄────── X (API-A gets an error, must retry, may drop the request)

With messaging (Service Bus queue):
  API-A  ──── sends message ────►  [Queue]  ◄──── API-B polls and processes
                                              │
              API-B restarts ──────────────── message is still in queue, not lost
              API-B is slow  ──────────────── messages accumulate, processed in order
```

### Queue vs Topic/Subscription

```
┌─────────────────────┬─────────────────────────────────────────────────────┐
│  Queue              │  One sender → one receiver (point-to-point)         │
│                     │  Each message delivered to exactly one consumer     │
│                     │  Use: task processing, work distribution            │
├─────────────────────┼─────────────────────────────────────────────────────┤
│  Topic/Subscription │  One sender → many receivers (publish-subscribe)    │
│                     │  Each subscription gets a copy of every message     │
│                     │  Use: events (OrderPlaced → email + inventory + audit)│
└─────────────────────┴─────────────────────────────────────────────────────┘

Example:
  Queue:  API-A sends "process-order" → one worker picks it up
  Topic:  API-A publishes "order-placed" → EmailService, InventoryService, AuditService
          each get their own copy via separate subscriptions
```

### Producer — Sending a Message

```csharp
// ── Install package ───────────────────────────────────────
// dotnet add package Azure.Messaging.ServiceBus

// ── Setup ─────────────────────────────────────────────────
builder.Services.AddSingleton(new ServiceBusClient(
    builder.Configuration["ServiceBus:ConnectionString"]));

// ── Send a message to a queue ────────────────────────────
public class OrderService
{
    private readonly ServiceBusClient _busClient;

    public OrderService(ServiceBusClient busClient) => _busClient = busClient;

    public async Task PlaceOrderAsync(Order order)
    {
        // Save to DB first
        await _db.Orders.AddAsync(order);
        await _db.SaveChangesAsync();

        // WHY: publish event AFTER successful DB save — don't publish if the DB fails
        var sender = _busClient.CreateSender("orders-queue");
        var payload = JsonSerializer.Serialize(new { order.Id, order.CustomerId, order.Total });
        var message = new ServiceBusMessage(payload)
        {
            // WHY: MessageId deduplicates if the same message is sent twice
            MessageId = order.Id.ToString(),
            ContentType = "application/json"
        };

        await sender.SendMessageAsync(message);
    }
}
```

### Consumer — Processing a Message

```csharp
// ── Process messages via BackgroundService ────────────────
public class OrderMessageConsumer : BackgroundService
{
    private readonly ServiceBusClient _busClient;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<OrderMessageConsumer> _logger;

    public OrderMessageConsumer(ServiceBusClient busClient,
        IServiceScopeFactory scopeFactory, ILogger<OrderMessageConsumer> logger)
    {
        _busClient = busClient;
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var processor = _busClient.CreateProcessor("orders-queue");

        // Called for each message
        processor.ProcessMessageAsync += async args =>
        {
            var body = args.Message.Body.ToString();
            var order = JsonSerializer.Deserialize<OrderMessage>(body)!;

            _logger.LogInformation("Processing order {OrderId}", order.Id);

            using var scope = _scopeFactory.CreateScope();
            var emailSvc = scope.ServiceProvider.GetRequiredService<IEmailService>();
            await emailSvc.SendOrderConfirmationAsync(order.CustomerId, order.Id);

            // WHY: CompleteMessageAsync removes it from the queue — only call after success
            await args.CompleteMessageAsync(args.Message);
        };

        // Called on error — message returns to queue for retry
        processor.ProcessErrorAsync += args =>
        {
            _logger.LogError(args.Exception, "Service Bus error on {EntityPath}", args.EntityPath);
            return Task.CompletedTask;
        };

        await processor.StartProcessingAsync(stoppingToken);
        await Task.Delay(Timeout.Infinite, stoppingToken);
        await processor.StopProcessingAsync();
    }
}
```

### Dead-Letter Queue — When Messages Fail Repeatedly

```
Message arrives in queue
  │
  ├─ Consumer processes successfully → CompleteMessageAsync() → removed from queue ✓
  │
  └─ Consumer throws exception → message returns to queue for retry
         │
         └─ After max delivery count (default 10) → moved to Dead-Letter Queue
                                                      (orders-queue/$DeadLetterQueue)

WHY dead-letter matters:
  Poison messages (malformed data, missing references) don't block the queue forever
  Your team can inspect dead-letter messages, fix the issue, and resubmit
```

---

## Azure Integration

> **For the Azure-focused audience** — this section covers Azure Cache for Redis, Azure Service Bus in depth, Azure API Management policies, and Azure Functions triggers for event-driven compute.

### Azure Cache for Redis

```
┌──────────────────────────────────────────────────────────────────┐
│  Azure Cache for Redis = fully managed Redis in Azure            │
│                                                                  │
│  Tiers:                                                          │
│  Basic   → single node, dev/test only                           │
│  Standard → primary + replica, 99.9% SLA                        │
│  Premium → clustering, persistence, VNet injection              │
│                                                                  │
│  Use cases beyond caching:                                       │
│  • Session store for stateless apps                              │
│  • Pub/Sub messaging (lightweight)                               │
│  • Leaderboards (sorted sets)                                    │
│  • Rate limiting counters (INCR + EXPIRE)                        │
└──────────────────────────────────────────────────────────────────┘
```

```csharp
// Connection with Managed Identity (no password in config)
builder.Services.AddStackExchangeRedisCache(options =>
{
    // In Azure: use connection string from Key Vault
    options.Configuration = builder.Configuration["Redis:ConnectionString"];
    options.InstanceName = "OrderApi:";  // namespaces all keys
});
```

### Azure Service Bus — Production Setup

```
┌──────────────────────────────────────────────────────────────────┐
│  Service Bus Tiers                                               │
│                                                                  │
│  Basic   → queues only, no topics, 256KB messages               │
│  Standard → queues + topics, 256KB, best for dev                 │
│  Premium → large messages (100MB), VNet, Geo-DR, dedicated      │
└──────────────────────────────────────────────────────────────────┘
```

```csharp
// WHY: use DefaultAzureCredential for Managed Identity — no connection string needed
builder.Services.AddSingleton(new ServiceBusClient(
    fullyQualifiedNamespace: "yournamespace.servicebus.windows.net",
    credential: new DefaultAzureCredential()));
```

**Topic/Subscription pattern — one event, many consumers:**

```csharp
// Publisher (Order API) — publishes to topic
var topicSender = busClient.CreateSender("order-events");
await topicSender.SendMessageAsync(new ServiceBusMessage(
    JsonSerializer.Serialize(new OrderPlacedEvent(order.Id, order.Total))));

// Consumer 1 (Email Service) — subscribes to "order-events" topic, "email-sub" subscription
var emailProcessor = busClient.CreateProcessor("order-events", "email-sub");

// Consumer 2 (Inventory Service) — same topic, different subscription
var inventoryProcessor = busClient.CreateProcessor("order-events", "inventory-sub");

// Both get a copy of every OrderPlacedEvent message
```

### Azure API Management (APIM) — Policy Basics

> **Mental Model:** APIM is a **bouncer and translator** at the door of all your APIs. It enforces who can enter (auth), how often (rate limits), and can transform requests/responses without touching your backend code.

```
Client Request
    │
    ▼
Azure API Management
    ├─ Inbound policies  (validate JWT, rate limit, add headers)
    │       │
    │       ▼
    │  Your Backend API (App Service / AKS)
    │       │
    ▼       ▼
    ├─ Outbound policies (transform response, cache, mask data)
    │
    ▼
Client Response
```

**Rate Limiting Policy (XML):**

```xml
<!-- Inbound policy: max 100 calls per minute per subscription key -->
<inbound>
    <rate-limit-by-key
        calls="100"
        renewal-period="60"
        counter-key="@(context.Subscription.Id)" />
    <base />
</inbound>
```

**JWT Validation Policy:**

```xml
<!-- Validate JWT token before reaching backend -->
<inbound>
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
        <openid-config url="https://login.microsoftonline.com/{tenant-id}/.well-known/openid-configuration" />
        <audiences>
            <audience>api://your-app-client-id</audience>
        </audiences>
    </validate-jwt>
    <base />
</inbound>
```

**Header Injection Policy (pass caller identity to backend):**

```xml
<!-- Add correlation ID and user identity to downstream request -->
<inbound>
    <set-header name="X-Correlation-ID" exists-action="skip">
        <value>@(Guid.NewGuid().ToString())</value>
    </set-header>
    <set-header name="X-User-Id" exists-action="override">
        <value>@(context.User.Id)</value>
    </set-header>
    <base />
</inbound>
```

### Azure Functions — Full Trigger Reference

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

```csharp
// ── Service Bus Trigger — replaces BackgroundService consumer ──
[Function("ProcessOrderMessage")]
public async Task ProcessMessage(
    [ServiceBusTrigger("orders-queue", Connection = "ServiceBus")] ServiceBusReceivedMessage msg,
    ServiceBusMessageActions messageActions)
{
    var order = JsonSerializer.Deserialize<OrderMessage>(msg.Body.ToString())!;

    // WHY: use DI-injected services just like in ASP.NET Core
    await _emailService.SendOrderConfirmationAsync(order.CustomerId, order.Id);

    // WHY: complete the message so it's removed from the queue
    await messageActions.CompleteMessageAsync(msg);
}

// ── Timer Trigger — scheduled job without BackgroundService ──
[Function("DailyReport")]
public async Task RunDailyReport(
    [TimerTrigger("0 0 2 * * *")] TimerInfo timer)  // every day at 2am UTC
{
    _logger.LogInformation("Daily report triggered at {Time}", DateTime.UtcNow);
    await _reportService.GenerateAndEmailAsync();
}
```

**Functions vs BackgroundService — when each is right:**

```
┌─────────────────────────────┬──────────────────────────────────────┐
│  Use Azure Functions when   │  Use BackgroundService when          │
├─────────────────────────────┼──────────────────────────────────────┤
│  Event-driven (queue, blob) │  Polling loop inside your API app    │
│  Scheduled tasks (timer)    │  In-memory queue processing          │
│  Variable / spiky load      │  Tight coupling to app lifecycle      │
│  No always-on API needed    │  Always-on API already running       │
│  Cost: pay per execution    │  No extra infra needed               │
└─────────────────────────────┴──────────────────────────────────────┘
```

---

## Architecture Recap — All 7 Sessions in One Diagram

```
                         Client (Browser / Mobile)
                                   │
                                   ▼
                      Azure API Management (Session 04: Auth + Rate Limit)
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
              ├── Observed by Azure Application Insights (Session 06)
              ├── Secrets from Azure Key Vault (Session 03)
              ├── Background jobs / Service Bus consumers (Session 07)
              └── Azure Functions for async event-driven processing (Session 07)

                    Service Bus Queue/Topic
                    ┌────────────────────┐
                    │  OrderPlaced event │◄── API (producer)
                    └────────────────────┘
                      │          │
                      ▼          ▼
               EmailService  InventoryService  (consumers — subscriptions)
```

---

## Key Takeaways

1. **Cache to reduce DB pressure** — `IMemoryCache` for single-instance, `IDistributedCache` (Redis) for multi-instance; combine `AbsoluteExpiration` + `SlidingExpiration` for safety.
2. **Background services decouple work from requests** — return 202 Accepted immediately; process asynchronously via `BackgroundService` or Service Bus.
3. **Stateless = scalable** — never store state in instance memory; use Redis, DB, or the JWT token itself.
4. **`IServiceScopeFactory` in background services** — `BackgroundService` is Singleton; always create a scope to resolve Scoped services like `DbContext`.
5. **Service Bus decouples producers from consumers** — queues for point-to-point, topics for publish-subscribe; dead-letter queue catches poison messages.

---

## Q&A Prompts

**1. You have 5 running API instances. A user adds items to their cart. Which instance will handle their next request? How do you ensure they see their cart?**

**Answer:** Any instance — the load balancer distributes requests round-robin with no guarantees about routing. The cart must not be stored in the instance's memory. Instead, store it in Redis (`IDistributedCache`) keyed by `cart:{userId}`. Every instance reads from and writes to the same Redis store, so the cart is visible regardless of which instance handles the request. This is the core principle of stateless design: any instance can handle any request because state lives externally.

---

**2. Why can't you inject `AppDbContext` directly into `BackgroundService`? What do you use instead?**

**Answer:** `BackgroundService` is registered as a `Singleton` — it lives for the entire application lifetime. `AppDbContext` is `Scoped` — it's designed to live for one request, then be disposed. Injecting a Scoped service into a Singleton is the "captive dependency" problem: the `DbContext` would never be disposed, connections would leak, and EF Core's change tracker would accumulate stale state. Instead, inject `IServiceScopeFactory` and call `_scopeFactory.CreateScope()` inside the method, then resolve `AppDbContext` from the scope. Dispose the scope when done — this properly manages the `DbContext` lifetime.

---

**3. What's the difference between `AbsoluteExpiration` and `SlidingExpiration` in a cache entry?**

**Answer:** `AbsoluteExpiration` removes the entry after a fixed time regardless of usage — e.g., "always refresh product data after 10 minutes." `SlidingExpiration` removes the entry if it hasn't been accessed for N minutes, resetting on every read — e.g., "evict a user session after 30 minutes of inactivity." The risk with sliding-only expiration is that a very popular item might never expire. Best practice: use both — `AbsoluteExpiration` as a hard cap (prevents indefinitely stale data), `SlidingExpiration` to evict cold entries sooner.

---

**4. When would you choose Azure Functions over a BackgroundService in your ASP.NET Core app?**

**Answer:** Use Azure Functions when the work is event-driven and your API doesn't need to be always running — processing Service Bus messages, responding to file uploads, running daily reports. Functions scale to zero on the Consumption plan, so you only pay when they execute. Use BackgroundService when the work is tightly coupled to your API's lifecycle (e.g., an in-memory task queue that the API populates), when the processing needs access to in-process state, or when adding a separate Azure Function deployment would add unjustified infrastructure complexity for a simple periodic task. In general: if work is triggered by external events and volume is unpredictable, prefer Functions.

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
| Day 7 | Caching, background jobs, stateless design, Service Bus, APIM |

**Recommended Next Steps:**
- Build a small end-to-end project combining all 7 topics
- Explore CQRS + MediatR for the application layer
- Deep dive into Azure AKS for container orchestration
- Study the Saga pattern for distributed transactions
- Explore Durable Functions for long-running, stateful workflows
