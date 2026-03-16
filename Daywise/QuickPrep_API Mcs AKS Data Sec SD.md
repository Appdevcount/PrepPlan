# Technical Architect Interview — Complete Preparation Guide
### For Senior .NET / Azure / Microservices Architect Roles (GCC / Product Companies)

> **Target Profile**: 12+ years .NET, Microservices, Azure, Clean Architecture
> **Interview Style**: Architecture depth + design decisions + hands-on coding mindset
> **Date Created**: 2026-03-16

---

## Table of Contents

1. [Pillar 1 — .NET Architecture](#1-net-architecture)
2. [Pillar 2 — Microservices & Distributed Systems](#2-microservices--distributed-systems)
3. [Pillar 3 — Azure Cloud Architecture](#3-azure-cloud-architecture)
4. [Pillar 4 — Containers & AKS](#4-containers--aks)
5. [Pillar 5 — Data Architecture](#5-data-architecture)
6. [Pillar 6 — Security Architecture](#6-security-architecture)
7. [Pillar 7 — DevOps & CI/CD](#7-devops--cicd)
8. [Pillar 8 — Monitoring & Observability](#8-monitoring--observability)
9. [Pillar 9 — Leadership & Architecture Decisions](#9-leadership--architecture-decisions)
10. [Pillar 10 — System Design Deep Dives](#10-system-design-deep-dives)
11. [20 Real Interview Questions & Answers](#11-20-real-interview-questions--answers)
12. [Microservices Design Cheatsheet](#12-microservices-design-cheatsheet)
13. [AKS Architecture Interview Answers](#13-aks-architecture-interview-answers)
14. [Quick Reference — Decision Trees](#14-quick-reference--decision-trees)

---

## Interview Weight Map

```
┌─────────────────────────────────────────────────────────────┐
│              INTERVIEW WEIGHT BY TOPIC                      │
├────────────────────────┬────────────────────────────────────┤
│ Azure Architecture     │ ⭐⭐⭐⭐⭐  (design + service selection) │
│ Microservices          │ ⭐⭐⭐⭐⭐  (patterns + trade-offs)      │
│ AKS / Containers       │ ⭐⭐⭐⭐   (workloads + scaling)        │
│ .NET Internals         │ ⭐⭐⭐    (async, DI, pipeline)        │
│ Security               │ ⭐⭐⭐    (OAuth2, JWT, OWASP)         │
│ SQL + NoSQL            │ ⭐⭐⭐    (when to use what + perf)    │
│ DevOps / CI/CD         │ ⭐⭐     (pipelines, GitOps)          │
│ Observability          │ ⭐⭐     (OTel, App Insights)         │
│ Leadership             │ ⭐⭐⭐    (decisions, trade-offs)      │
└────────────────────────┴────────────────────────────────────┘
```

---

# 1. .NET Architecture

> **Mental Model**: ASP.NET Core is a pipeline of middleware — think of it as airport security lanes where each checkpoint can either process or short-circuit the request.

---

## 1.1 ASP.NET Core Request Pipeline

```
┌──────────────────────────────────────────────────────────┐
│                   REQUEST PIPELINE                        │
│                                                          │
│  HTTP Request                                            │
│      ↓                                                   │
│  [Exception Handler]   ← catches all unhandled errors   │
│      ↓                                                   │
│  [HTTPS Redirection]   ← forces HTTPS                   │
│      ↓                                                   │
│  [Static Files]        ← short-circuits for static      │
│      ↓                                                   │
│  [Routing]             ← matches endpoint               │
│      ↓                                                   │
│  [CORS]                ← sets headers                   │
│      ↓                                                   │
│  [Authentication]      ← WHO are you?                   │
│      ↓                                                   │
│  [Authorization]       ← WHAT can you do?               │
│      ↓                                                   │
│  [Endpoint]            ← Controller / Minimal API       │
│      ↓                                                   │
│  HTTP Response                                           │
└──────────────────────────────────────────────────────────┘
```

**Key Insight**: Middleware order is NOT arbitrary. Authentication must come before Authorization. Routing must come before Auth because Auth middleware needs to know which endpoint is being hit to apply its policies.

```csharp
// WHY: Order is contract — changing order changes behavior
var app = builder.Build();

app.UseExceptionHandler("/error");    // WHY: outermost catches everything
app.UseHttpsRedirection();
app.UseStaticFiles();                 // WHY: short-circuit before auth = no auth on static assets
app.UseRouting();                     // WHY: must precede auth so auth can inspect endpoint metadata
app.UseCors();
app.UseAuthentication();              // WHO are you?
app.UseAuthorization();               // WHAT can you do?

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
```

---

## 1.2 Middleware — Custom Implementation

```csharp
// WHY: Custom middleware for cross-cutting concerns (correlation ID, timing, logging)
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<CorrelationIdMiddleware> _logger;

    public CorrelationIdMiddleware(RequestDelegate next, ILogger<CorrelationIdMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // WHY: Correlate logs across distributed services
        var correlationId = context.Request.Headers["X-Correlation-Id"].FirstOrDefault()
                            ?? Guid.NewGuid().ToString();

        context.Items["CorrelationId"] = correlationId;
        context.Response.Headers["X-Correlation-Id"] = correlationId;

        using (_logger.BeginScope(new { CorrelationId = correlationId }))
        {
            await _next(context); // WHY: call next or response is never completed
        }
    }
}

// Registration
app.UseMiddleware<CorrelationIdMiddleware>();
```

---

## 1.3 Dependency Injection — Lifetimes

```
┌──────────────────────────────────────────────────────────────┐
│                   DI LIFETIME MATRIX                         │
├─────────────┬──────────────┬────────────────────────────────┤
│ Lifetime    │ Instance     │ Use Case                       │
├─────────────┼──────────────┼────────────────────────────────┤
│ Singleton   │ 1 per app    │ Config, cache, HttpClient      │
│ Scoped      │ 1 per request│ DbContext, UoW, repositories   │
│ Transient   │ Every inject │ Stateless services, formatters │
└─────────────┴──────────────┴────────────────────────────────┘
```

**Captive Dependency Problem** (interview trap):
```csharp
// WRONG: Singleton holding Scoped = captive dependency
// Scoped DbContext captured in Singleton = stale, thread-unsafe
services.AddSingleton<MyService>();   // MyService depends on DbContext (Scoped)
// Fix: inject IServiceScopeFactory and create scope manually

// CORRECT
public class MyService
{
    private readonly IServiceScopeFactory _scopeFactory;
    public MyService(IServiceScopeFactory scopeFactory) => _scopeFactory = scopeFactory;

    public async Task DoWork()
    {
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        // use db safely
    }
}
```

---

## 1.4 Async/Await Internals

> **Mental Model**: async/await is a state machine — the compiler rewrites your method into a class with a `MoveNext()` method that resumes at each `await` point.

```
┌───────────────────────────────────────────────────────────┐
│               ASYNC STATE MACHINE                         │
│                                                           │
│  await GetDataAsync()                                     │
│       ↓                                                   │
│  [State 0] — synchronous up to first await               │
│       ↓                                                   │
│  [Suspend] — returns incomplete Task to caller           │
│       ↓                                                   │
│  [IO completes on threadpool thread]                      │
│       ↓                                                   │
│  [State 1] — resumes (same or different thread!)         │
│       ↓                                                   │
│  [State 2] — next await or completion                    │
└───────────────────────────────────────────────────────────┘
```

**ConfigureAwait(false)** — when and why:
```csharp
// Library code: use ConfigureAwait(false) to avoid deadlock on sync-over-async
// WHY: prevents resuming on captured SynchronizationContext (UI/ASP.NET classic)
public async Task<string> GetDataAsync()
{
    var result = await _httpClient.GetStringAsync(url).ConfigureAwait(false);
    return result;
}
// NOTE: In ASP.NET Core, ConfigureAwait(false) is optional (no SyncContext)
// but still a best practice for library code
```

**ValueTask vs Task**:
```csharp
// Task: always allocates on heap — good for operations that will be awaited
// ValueTask: stack-allocated when result is synchronous — good for hot paths
// WHY: reduces GC pressure in frequently called code

public ValueTask<int> GetCachedValueAsync(int key)
{
    if (_cache.TryGetValue(key, out var value))
        return ValueTask.FromResult(value); // WHY: no heap alloc for cache hit

    return new ValueTask<int>(FetchFromDbAsync(key)); // WHY: wraps Task for async path
}

// RULE: Never await a ValueTask twice — it's not safe (unlike Task)
```

**IAsyncEnumerable** — streaming:
```csharp
// WHY: Stream large datasets instead of loading all into memory
public async IAsyncEnumerable<Order> GetOrdersAsync(
    [EnumeratorCancellation] CancellationToken ct = default)
{
    await foreach (var order in _db.Orders.AsAsyncEnumerable().WithCancellation(ct))
        yield return order;
}

// Consumer
await foreach (var order in GetOrdersAsync())
    await ProcessAsync(order); // WHY: each item processed as it arrives
```

---

## 1.5 Minimal APIs vs Controllers

```
┌────────────────────────────────────────────────────────────────┐
│              MINIMAL API vs CONTROLLERS                        │
├─────────────────────┬──────────────────────────────────────────┤
│ Minimal API         │ Controllers                              │
├─────────────────────┼──────────────────────────────────────────┤
│ Less ceremony       │ More structure, conventions              │
│ Better for simple   │ Better for complex routing/filters       │
│ Faster startup      │ Action filters, model binding            │
│ Lambdas / groups    │ Attribute routing                        │
│ .NET 6+             │ All versions                             │
└─────────────────────┴──────────────────────────────────────────┘
```

```csharp
// Minimal API with route groups — organizes endpoints
var orders = app.MapGroup("/api/orders")
    .RequireAuthorization()           // WHY: applies to all in group
    .WithTags("Orders");

orders.MapGet("/", GetAllOrders);
orders.MapGet("/{id}", GetOrderById);
orders.MapPost("/", CreateOrder);

// WHY: Route groups reduce repetition vs individual endpoint registration
```

---

## 1.6 API Design Patterns

### Versioning Strategies

```
┌─────────────────────────────────────────────────────────────┐
│                  API VERSIONING OPTIONS                     │
├──────────────────┬──────────────────────────────────────────┤
│ URL segment      │ /api/v1/orders  — most visible, cacheable│
│ Query string     │ /api/orders?api-version=1.0              │
│ Header           │ X-Api-Version: 1.0  — clean URL         │
│ Media type       │ Accept: application/vnd.api+json;v=1    │
└──────────────────┴──────────────────────────────────────────┘
```

```csharp
// URL versioning with Asp.Versioning
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true; // WHY: backward compat
    options.ReportApiVersions = true; // WHY: tells clients what versions exist
});

[ApiVersion("1.0")]
[ApiVersion("2.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class OrdersController : ControllerBase
{
    [HttpGet, MapToApiVersion("1.0")]
    public IActionResult GetV1() => Ok("v1");

    [HttpGet, MapToApiVersion("2.0")]
    public IActionResult GetV2() => Ok("v2 — enhanced");
}
```

### Pagination

```csharp
// Offset vs Cursor pagination
// Offset: simple but slow on large datasets (DB scans N rows)
// Cursor: O(1) per page — uses index seek

// Cursor-based pagination record
public record PagedResult<T>(
    IEnumerable<T> Items,
    string? NextCursor,  // WHY: opaque token — base64 encoded last item ID
    int TotalCount
);

// Query with cursor
var query = db.Orders
    .Where(o => cursor == null || o.Id > decodedCursor) // WHY: seek pattern
    .OrderBy(o => o.Id)
    .Take(pageSize + 1); // WHY: fetch one extra to detect has-next-page
```

### Idempotency

```csharp
// WHY: Prevent duplicate operations on retry (payment charged twice)
[HttpPost("payments")]
public async Task<IActionResult> ProcessPayment(
    [FromHeader(Name = "Idempotency-Key")] string idempotencyKey,
    PaymentRequest request)
{
    // Check if key already processed
    if (await _idempotencyStore.ExistsAsync(idempotencyKey))
    {
        var cached = await _idempotencyStore.GetAsync(idempotencyKey);
        return Ok(cached); // WHY: return same result, don't reprocess
    }

    var result = await _paymentService.ProcessAsync(request);
    await _idempotencyStore.StoreAsync(idempotencyKey, result, ttl: TimeSpan.FromDays(1));
    return Ok(result);
}
```

---

## 1.7 Polly — Resilience Policies

```csharp
// WHY: Transient failures (network blips) should be retried; persistent failures should fast-fail

builder.Services.AddHttpClient<IOrderServiceClient, OrderServiceClient>()
    .AddResilienceHandler("order-pipeline", pipeline =>
    {
        // Layer 1: Retry with exponential backoff
        pipeline.AddRetry(new HttpRetryStrategyOptions
        {
            MaxRetryAttempts = 3,
            Delay = TimeSpan.FromSeconds(1),
            BackoffType = DelayBackoffType.Exponential, // WHY: avoids thundering herd
            UseJitter = true  // WHY: randomizes retry timing across instances
        });

        // Layer 2: Circuit breaker
        pipeline.AddCircuitBreaker(new HttpCircuitBreakerStrategyOptions
        {
            FailureRatio = 0.5,        // WHY: open after 50% failure rate
            SamplingDuration = TimeSpan.FromSeconds(10),
            MinimumThroughput = 10,    // WHY: need enough samples to be meaningful
            BreakDuration = TimeSpan.FromSeconds(30) // WHY: give downstream time to recover
        });

        // Layer 3: Timeout
        pipeline.AddTimeout(TimeSpan.FromSeconds(5)); // WHY: prevent slow callers from blocking threads
    });
```

---

# 2. Microservices & Distributed Systems

> **Mental Model**: Microservices are like independent departments in a company — each owns its data, has its own budget (infra), and communicates via official channels (APIs/messages). You don't walk into accounting and directly edit their spreadsheet.

---

## 2.1 Core Principles

```
┌──────────────────────────────────────────────────────────────┐
│              MICROSERVICES PRINCIPLES                        │
├──────────────────────────┬───────────────────────────────────┤
│ Principle                │ What it means in practice         │
├──────────────────────────┼───────────────────────────────────┤
│ Single Responsibility    │ One service = one business domain │
│ Database per service     │ No shared DB tables across svcs   │
│ Independent deployment   │ Deploy without touching others    │
│ Bounded Context (DDD)    │ Service owns its domain model     │
│ Fault isolation          │ Failure stays in one service      │
│ Decentralized governance │ Teams choose their own tech stack │
└──────────────────────────┴───────────────────────────────────┘
```

---

## 2.2 Communication Patterns

```
┌────────────────────────────────────────────────────────────────┐
│               SYNCHRONOUS vs ASYNCHRONOUS                      │
│                                                                │
│  SYNC (REST/gRPC)              ASYNC (Service Bus/Kafka)       │
│  ──────────────────            ──────────────────────────      │
│  Client  → Service A           Publisher → Topic/Queue         │
│  Client  ← response            Consumer ← message              │
│                                                                │
│  ✓ Simple, immediate           ✓ Decoupled, resilient          │
│  ✗ Coupling, cascading fail    ✗ Eventual consistency          │
│                                                                │
│  USE FOR:                      USE FOR:                        │
│  - Query/read                  - Commands/writes               │
│  - Real-time UX                - Long-running workflows        │
│  - Simple integrations         - Cross-service events          │
└────────────────────────────────────────────────────────────────┘
```

### gRPC for Internal Service Communication

```csharp
// WHY: gRPC is ~10x faster than REST for internal calls (binary proto, HTTP/2 multiplexing)
// inventory.proto
syntax = "proto3";
service InventoryService {
  rpc CheckStock(StockRequest) returns (StockResponse);
  rpc StreamInventory(StockRequest) returns (stream InventoryItem); // server streaming
}

// C# server implementation
public class InventoryGrpcService : InventoryService.InventoryServiceBase
{
    public override async Task<StockResponse> CheckStock(
        StockRequest request, ServerCallContext context)
    {
        var stock = await _repo.GetStockAsync(request.ProductId);
        return new StockResponse { Available = stock > 0, Quantity = stock };
    }
}
```

---

## 2.3 Saga Pattern — Distributed Transactions

> **Mental Model**: A Saga is a series of local transactions where each step publishes an event to trigger the next, and compensating transactions undo completed steps on failure — like a multi-party contract where each party can void their part if someone else defaults.

```
┌──────────────────────────────────────────────────────────────────┐
│                     SAGA PATTERN                                 │
│                                                                  │
│  ORCHESTRATION (Central coordinator)                             │
│  ─────────────────────────────────                               │
│  Saga Orchestrator                                               │
│       → OrderService.CreateOrder()   ✓                           │
│       → PaymentService.Charge()      ✓                           │
│       → InventoryService.Reserve()   ✗ FAILS                     │
│       → PaymentService.Refund()      ← compensate                │
│       → OrderService.CancelOrder()   ← compensate                │
│                                                                  │
│  CHOREOGRAPHY (Event-driven, no coordinator)                     │
│  ──────────────────────────────────────────                      │
│  OrderCreated event                                              │
│       ↓                                                          │
│  PaymentService subscribes → PaymentProcessed event             │
│       ↓                                                          │
│  InventoryService subscribes → InventoryReserved event          │
│       ↓                                                          │
│  ShippingService subscribes → ShipmentCreated event             │
└──────────────────────────────────────────────────────────────────┘
```

```
┌──────────────────────────────────────────────────────┐
│         ORCHESTRATION vs CHOREOGRAPHY                │
├──────────────────┬───────────────────────────────────┤
│ Orchestration    │ Choreography                      │
├──────────────────┼───────────────────────────────────┤
│ Central control  │ Decentralized                     │
│ Easy to trace    │ Hard to trace (need Zipkin/OTel)  │
│ Single point SPOF│ More resilient                    │
│ Good for complex │ Good for simple linear flows      │
│ Temporal Saga lib│ Service Bus / Kafka events        │
└──────────────────┴───────────────────────────────────┘
```

---

## 2.4 Event Sourcing & CQRS

```
┌────────────────────────────────────────────────────────────────┐
│                    CQRS ARCHITECTURE                           │
│                                                                │
│  Client                                                        │
│    ├── Command (write) → Command Handler → Write DB (SQL)      │
│    │                          ↓ event                          │
│    │                    Event Store (Cosmos/EventStore)        │
│    │                          ↓ projection                     │
│    │                    Read Model (Denormalized)              │
│    └── Query (read)  ← Query Handler ← Read DB (optimized)    │
└────────────────────────────────────────────────────────────────┘
```

```csharp
// Command
public record CreateOrderCommand(Guid CustomerId, List<OrderItem> Items);

// Command Handler — writes
public class CreateOrderCommandHandler : IRequestHandler<CreateOrderCommand, Guid>
{
    public async Task<Guid> Handle(CreateOrderCommand cmd, CancellationToken ct)
    {
        var order = Order.Create(cmd.CustomerId, cmd.Items); // WHY: domain logic in entity
        _repo.Add(order);
        await _repo.SaveChangesAsync(ct);
        await _eventBus.PublishAsync(new OrderCreatedEvent(order.Id)); // WHY: notify projections
        return order.Id;
    }
}

// Query handler — reads from optimized read model
public class GetOrderQueryHandler : IRequestHandler<GetOrderQuery, OrderDto>
{
    public async Task<OrderDto> Handle(GetOrderQuery query, CancellationToken ct)
        => await _readDb.Orders.Where(o => o.Id == query.Id)
                               .ProjectTo<OrderDto>(_mapper.ConfigurationProvider)
                               .FirstOrDefaultAsync(ct);
    // WHY: reads from denormalized read model — fast, no joins
}
```

---

## 2.5 Outbox Pattern — Reliable Event Publishing

> **Mental Model**: The outbox is like a message tray on your desk — you write the message AND place it in the tray atomically. A separate mail runner periodically picks up from the tray and delivers. If the runner crashes, the message is still in the tray.

```
┌────────────────────────────────────────────────────────────────┐
│                    OUTBOX PATTERN                              │
│                                                                │
│  Without Outbox:                                               │
│  Save order to DB  ← success                                  │
│  Publish to SB     ← CRASH ← message LOST                     │
│                                                                │
│  With Outbox:                                                  │
│  BEGIN TX                                                      │
│    Save order to DB                                            │
│    Write to OutboxMessages table    ← same transaction        │
│  COMMIT TX                                                     │
│       ↓                                                        │
│  Background job polls OutboxMessages                          │
│       ↓                                                        │
│  Publish to Service Bus                                        │
│       ↓                                                        │
│  Mark OutboxMessage as processed                              │
│                                                                │
│  GUARANTEE: At-least-once delivery (idempotent consumers!)    │
└────────────────────────────────────────────────────────────────┘
```

---

## 2.6 Resilience Patterns Summary

```
┌────────────────────────────────────────────────────────────────────┐
│                    RESILIENCE PATTERNS                             │
├──────────────────┬─────────────────────────────────────────────────┤
│ Pattern          │ Problem solved                                  │
├──────────────────┼─────────────────────────────────────────────────┤
│ Retry            │ Transient failures (network blip)               │
│ Circuit Breaker  │ Cascading failures (downstream unhealthy)       │
│ Bulkhead         │ Resource isolation (payment pool ≠ search pool) │
│ Timeout          │ Slow dependencies blocking threads              │
│ Fallback         │ Graceful degradation (cache, default response)  │
│ Rate Limiting    │ Protect from overload / abuse                   │
│ Health Check     │ Remove unhealthy instances from LB              │
│ Idempotency      │ Safe retries without duplicate side effects     │
└──────────────────┴─────────────────────────────────────────────────┘
```

---

## 2.7 API Gateway Pattern

```
┌────────────────────────────────────────────────────────────────┐
│                    API GATEWAY RESPONSIBILITIES                 │
│                                                                │
│  Client                                                        │
│     ↓                                                          │
│  ┌──────────────────────────────┐                             │
│  │       API Gateway            │                             │
│  │  • Authentication (JWT)      │                             │
│  │  • Rate limiting             │                             │
│  │  • Request transformation    │                             │
│  │  • Response aggregation      │                             │
│  │  • SSL termination           │                             │
│  │  • Routing / load balancing  │                             │
│  │  • Circuit breaking          │                             │
│  └──────────────────────────────┘                             │
│     ↓           ↓           ↓                                  │
│  Order Svc  Payment Svc  Catalog Svc                          │
└────────────────────────────────────────────────────────────────┘

Azure: Azure API Management (APIM)
OSS:   Ocelot (.NET), Kong, Envoy, NGINX
```

---

## 2.8 Strangler Fig Pattern

```
┌────────────────────────────────────────────────────────────────┐
│               STRANGLER FIG MIGRATION                          │
│                                                                │
│  Phase 1: Facade in front of monolith                          │
│  ─────────────────────────────────────                         │
│  Client → Facade → Monolith (all traffic)                      │
│                                                                │
│  Phase 2: Extract module to microservice                       │
│  ────────────────────────────────────────                      │
│  Client → Facade → Orders Microservice (new)                   │
│                  → Monolith (everything else)                  │
│                                                                │
│  Phase 3: Continue extracting                                  │
│  ───────────────────────────────                               │
│  Client → Facade → Orders MS                                   │
│                  → Payments MS                                 │
│                  → Inventory MS                                │
│                  → Monolith (legacy remainder)                 │
│                                                                │
│  Phase N: Decommission monolith                               │
└────────────────────────────────────────────────────────────────┘
```

---

# 3. Azure Cloud Architecture

> **Mental Model**: Azure services are LEGO bricks — each one does one job well. The architect's job is picking the right bricks and knowing which NOT to use.

---

## 3.1 Reference Architecture — Enterprise Azure

```
┌──────────────────────────────────────────────────────────────────────┐
│                    AZURE ENTERPRISE ARCHITECTURE                     │
│                                                                      │
│  Users / External                                                    │
│       ↓                                                              │
│  Azure Front Door (CDN + WAF + global load balancing)               │
│       ↓                                                              │
│  Azure Application Gateway (regional WAF + L7 routing)             │
│       ↓                                                              │
│  Azure API Management (auth + throttle + transform + versioning)    │
│       ↓                                                              │
│  ┌─────────────────────────────────────────────────────┐            │
│  │              AKS / App Service                       │            │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │            │
│  │  │ Order Service│  │Payment Service│  │Catalog   │  │            │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │            │
│  └─────────────────────────────────────────────────────┘            │
│       ↓                    ↓                   ↓                    │
│  Azure Service Bus   Azure Event Grid    Azure Cache (Redis)        │
│       ↓                    ↓                                        │
│  Background Workers   Event Handlers                                │
│       ↓                                                              │
│  ┌──────────────────────────────────────────┐                       │
│  │              Data Tier                   │                       │
│  │  Azure SQL  CosmosDB  Blob Storage       │                       │
│  └──────────────────────────────────────────┘                       │
│                                                                      │
│  Observability: App Insights + Log Analytics + Azure Monitor        │
│  Identity:      Azure AD + Managed Identity + Key Vault             │
│  Network:       VNet + Private Endpoints + NSG + UDR                │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 3.2 Azure Service Selection Guide

```
┌─────────────────────────────────────────────────────────────────────┐
│                    COMPUTE SELECTION                                │
├──────────────────────┬──────────────────────────────────────────────┤
│ Need                 │ Use                                          │
├──────────────────────┼──────────────────────────────────────────────┤
│ Full container control│ AKS                                        │
│ Simple containers    │ Azure Container Apps                        │
│ HTTP APIs, web apps  │ Azure App Service                           │
│ Event-driven, short  │ Azure Functions                             │
│ Batch processing     │ Azure Batch / Container Instances           │
│ HPC workloads        │ Azure CycleCloud                            │
└──────────────────────┴──────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    MESSAGING SELECTION                              │
├──────────────────────┬──────────────────────────────────────────────┤
│ Need                 │ Use                                          │
├──────────────────────┼──────────────────────────────────────────────┤
│ Enterprise messaging │ Azure Service Bus (queues + topics)         │
│ IoT / high volume    │ Azure Event Hub (Kafka-compatible)          │
│ Reactive events      │ Azure Event Grid (pub/sub, serverless)      │
│ Real-time (SignalR)  │ Azure Web PubSub / SignalR Service          │
└──────────────────────┴──────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    STORAGE SELECTION                                │
├──────────────────────┬──────────────────────────────────────────────┤
│ Need                 │ Use                                          │
├──────────────────────┼──────────────────────────────────────────────┤
│ Relational, ACID     │ Azure SQL / PostgreSQL Flexible Server       │
│ Global, NoSQL, JSON  │ Cosmos DB                                   │
│ Cache / session      │ Azure Cache for Redis                       │
│ Files / blobs        │ Azure Blob Storage                          │
│ Tabular / key-value  │ Azure Table Storage                         │
│ Search               │ Azure Cognitive Search / Elastic            │
└──────────────────────┴──────────────────────────────────────────────┘
```

---

## 3.3 Azure API Management (APIM) — Interview Deep Dive

```csharp
// APIM inbound policy — JWT validation + rate limiting + transform
<policies>
  <inbound>
    <!-- WHY: validate token at gateway, not per service -->
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
      <openid-config url="https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration"/>
      <required-claims>
        <claim name="aud"><value>api://my-api</value></claim>
      </required-claims>
    </validate-jwt>

    <!-- WHY: protect backend from abuse -->
    <rate-limit-by-key calls="100" renewal-period="60"
                       counter-key="@(context.Request.Headers["X-Client-Id"].AsEnumerable().FirstOrDefault())" />

    <!-- WHY: add correlation ID for distributed tracing -->
    <set-header name="X-Correlation-Id" exists-action="skip">
      <value>@(Guid.NewGuid().ToString())</value>
    </set-header>
  </inbound>
</policies>
```

---

## 3.4 Azure Service Bus vs Event Grid vs Event Hub

```
┌─────────────────────────────────────────────────────────────────────────┐
│             SERVICE BUS vs EVENT GRID vs EVENT HUB                     │
├───────────────┬──────────────────┬──────────────┬───────────────────────┤
│ Feature       │ Service Bus      │ Event Grid   │ Event Hub             │
├───────────────┼──────────────────┼──────────────┼───────────────────────┤
│ Pattern       │ Message queue    │ Event routing│ Event streaming       │
│ Order         │ FIFO guaranteed  │ No guarantee │ Per partition         │
│ Replay        │ No (TTL)         │ No           │ YES (retention 90d)  │
│ Size limit    │ 1-100 MB         │ 1 MB         │ 1 MB                 │
│ Throughput    │ Medium           │ High         │ Very high (IoT scale) │
│ Use case      │ Microservice cmd │ Azure events │ Telemetry / analytics │
│ Competing     │ YES (consumers)  │ NO (fan-out) │ Consumer groups       │
└───────────────┴──────────────────┴──────────────┴───────────────────────┘
```

**Key Interview Answer**: "Use Service Bus when you need reliable command delivery with ordering guarantees and competing consumers (e.g., order processing). Use Event Grid for reactive Azure-native event routing (e.g., trigger a Function when a Blob is uploaded). Use Event Hub for high-throughput data ingestion and replay (e.g., IoT telemetry, clickstream analytics)."

---

## 3.5 Azure Front Door vs Application Gateway vs Load Balancer

```
┌─────────────────────────────────────────────────────────────────────────┐
│         AZURE LOAD BALANCING DECISION TREE                             │
├────────────────────────┬────────────────────────────────────────────────┤
│ Global HTTP + CDN + WAF│ → Azure Front Door                            │
│ Regional HTTP + WAF    │ → Application Gateway                         │
│ Regional TCP/UDP       │ → Azure Load Balancer (standard)              │
│ DNS-based global       │ → Azure Traffic Manager                       │
└────────────────────────┴────────────────────────────────────────────────┘
```

---

## 3.6 Managed Identity — Zero Credential Architecture

```csharp
// WHY: No passwords/connection strings in code or config — identity IS the credential
// Managed Identity = service principal auto-managed by Azure

// App Service / AKS Pod → Managed Identity → Key Vault / SQL / Blob
var credential = new DefaultAzureCredential(); // WHY: works locally (dev creds) AND in Azure (MI)

// Access Key Vault
var secretClient = new SecretClient(
    new Uri("https://myvault.vault.azure.net/"),
    credential);
var secret = await secretClient.GetSecretAsync("ConnectionString");

// Access SQL with token (no password in connection string)
var conn = new SqlConnection("Server=myserver.database.windows.net;Database=mydb;");
conn.AccessToken = await new DefaultAzureCredential()
    .GetTokenAsync(new TokenRequestContext(new[] { "https://database.windows.net/.default" }));
    // WHY: SQL accepts Entra token — no username/password needed
```

---

# 4. Containers & AKS

> **Mental Model**: Kubernetes is an operating system for your data center — Pods are processes, Nodes are servers, the Scheduler is the OS process manager, and etcd is the kernel's memory.

---

## 4.1 Dockerfile Best Practices

```dockerfile
# Multi-stage build — WHY: keeps final image small (runtime only, no SDK)
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# WHY: copy csproj first for layer caching — only restored when deps change
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"

COPY . .
WORKDIR "/src/MyApi"
RUN dotnet publish -c Release -o /app/publish \
    --no-restore \         # WHY: already restored above
    /p:UseAppHost=false    # WHY: not needed in Linux container

# Runtime image — much smaller than SDK image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# WHY: non-root user — principle of least privilege
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

COPY --from=build /app/publish .
EXPOSE 80
ENV ASPNETCORE_HTTP_PORTS=80
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

---

## 4.2 Kubernetes Core Concepts

```
┌──────────────────────────────────────────────────────────────────┐
│                  KUBERNETES OBJECT HIERARCHY                     │
│                                                                  │
│  Cluster                                                         │
│  ├── Namespace (isolation boundary)                              │
│  │   ├── Deployment (desired state manager)                      │
│  │   │   └── ReplicaSet (maintains N pod replicas)               │
│  │   │       └── Pod (smallest deployable unit)                  │
│  │   │           └── Container(s) + shared network/storage       │
│  │   ├── Service (stable network endpoint for pods)              │
│  │   ├── Ingress (HTTP routing from outside cluster)             │
│  │   ├── ConfigMap (non-secret config)                           │
│  │   ├── Secret (sensitive config — base64 encoded)              │
│  │   ├── HPA (Horizontal Pod Autoscaler)                         │
│  │   ├── PVC (Persistent Volume Claim)                           │
│  │   └── ServiceAccount (pod identity)                           │
│  └── Node (VM running kubelet + container runtime)               │
└──────────────────────────────────────────────────────────────────┘
```

### Deployment YAML — Production Grade

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: production
spec:
  replicas: 3                    # WHY: HA requires minimum 3 across zones
  selector:
    matchLabels:
      app: order-service
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1          # WHY: always have capacity during rollout
      maxSurge: 1                # WHY: one extra pod during update
  template:
    metadata:
      labels:
        app: order-service
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values: [ order-service ]
            topologyKey: kubernetes.io/hostname # WHY: spread pods across nodes
      containers:
      - name: order-service
        image: myregistry.azurecr.io/order-service:1.2.3
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: Production
        - name: ConnectionStrings__Default
          valueFrom:
            secretKeyRef:
              name: order-secrets
              key: db-connection   # WHY: never hardcode secrets
        resources:
          requests:
            memory: "128Mi"        # WHY: scheduler uses requests for placement
            cpu: "100m"
          limits:
            memory: "256Mi"        # WHY: prevents OOM from killing node
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5         # WHY: pod only gets traffic when ready
        livenessProbe:
          httpGet:
            path: /health/live
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 15        # WHY: restart pod if hung/deadlocked
```

---

## 4.3 AKS Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                        AKS ARCHITECTURE                              │
│                                                                      │
│  Azure (managed)                                                     │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │  Control Plane (Azure managed, free tier or standard)      │     │
│  │  ┌──────────┐ ┌──────────────┐ ┌───────────┐ ┌────────┐  │     │
│  │  │ API Svr  │ │ Controller Mgr│ │ Scheduler │ │  etcd  │  │     │
│  │  └──────────┘ └──────────────┘ └───────────┘ └────────┘  │     │
│  └────────────────────────────────────────────────────────────┘     │
│                              ↕ kubelet                               │
│  Customer VNet                                                       │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │  Node Pool(s)                                              │     │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐          │     │
│  │  │  Node (VM) │  │  Node (VM) │  │  Node (VM) │          │     │
│  │  │  kubelet   │  │  kubelet   │  │  kubelet   │          │     │
│  │  │  Pods...   │  │  Pods...   │  │  Pods...   │          │     │
│  │  └────────────┘  └────────────┘  └────────────┘          │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Integrations: ACR, Key Vault CSI, Workload Identity, AGIC, KEDA    │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 4.4 AKS Scaling

```
┌────────────────────────────────────────────────────────────────┐
│                   AKS SCALING LAYERS                           │
│                                                                │
│  1. HPA (Horizontal Pod Autoscaler)                            │
│     Scale OUT pods based on CPU/memory/custom metrics          │
│     min: 2 → max: 20 pods based on CPU > 70%                  │
│                                                                │
│  2. KEDA (Kubernetes Event-Driven Autoscaler)                  │
│     Scale pods to ZERO based on queue depth                    │
│     Service Bus queue length > 10 → scale up workers          │
│                                                                │
│  3. Cluster Autoscaler                                         │
│     Scale OUT nodes when pods are Pending (no space)          │
│     Scale IN nodes when underutilized for 10+ min             │
│                                                                │
│  4. VPA (Vertical Pod Autoscaler)                              │
│     Adjust CPU/memory REQUESTS (restart required)             │
│     Used for right-sizing, not for live scaling               │
└────────────────────────────────────────────────────────────────┘
```

```yaml
# KEDA ScaledObject — scale on Service Bus queue depth
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: order-worker-scaler
spec:
  scaleTargetRef:
    name: order-worker
  minReplicaCount: 0         # WHY: scale to zero when queue empty = cost saving
  maxReplicaCount: 50
  triggers:
  - type: azure-servicebus
    metadata:
      queueName: orders
      messageCount: "5"      # WHY: 1 pod per 5 messages in queue
    authenticationRef:
      name: servicebus-auth  # WHY: uses Workload Identity, no connection string
```

---

## 4.5 Workload Identity — AKS

```yaml
# Pod → Azure resources without secrets
# 1. Enable OIDC issuer on AKS
az aks update --enable-oidc-issuer --enable-workload-identity -n myaks -g myrg

# 2. Create managed identity
az identity create --name order-service-identity --resource-group myrg

# 3. Federated credential
az identity federated-credential create \
  --name order-service-fc \
  --identity-name order-service-identity \
  --issuer $(az aks show -n myaks -g myrg --query "oidcIssuerProfile.issuerUrl" -o tsv) \
  --subject "system:serviceaccount:production:order-service-sa"

# 4. Annotate ServiceAccount in k8s
apiVersion: v1
kind: ServiceAccount
metadata:
  name: order-service-sa
  annotations:
    azure.workload.identity/client-id: "<managed-identity-client-id>"
    # WHY: links k8s SA to Azure managed identity
```

---

# 5. Data Architecture

> **Mental Model**: Choosing a database is like choosing transportation — SQL is a reliable car (structured, ACID), CosmosDB is an airplane (global, fast, expensive), Redis is a bicycle (fastest, but no storage), and blob is a cargo ship (cheap, slow, massive).

---

## 5.1 SQL Server — Performance Tuning

### Indexing Strategy

```sql
-- Clustered index: physical row order — one per table
-- WHY: PKs are almost always clustered
CREATE CLUSTERED INDEX IX_Orders_Id ON Orders(Id);

-- Covering index: include all columns needed by query — avoids key lookup
-- WHY: eliminates bookmark lookup = dramatically faster reads
CREATE NONCLUSTERED INDEX IX_Orders_CustomerId_Status
ON Orders(CustomerId, Status)
INCLUDE (OrderDate, TotalAmount); -- WHY: query never touches main table

-- Filtered index: partial index for selective queries
-- WHY: smaller index = faster reads + less maintenance
CREATE NONCLUSTERED INDEX IX_Orders_PendingOnly
ON Orders(CreatedAt)
WHERE Status = 'Pending'; -- WHY: only indexes pending orders
```

### Execution Plan Analysis

```sql
-- Check for missing index suggestions
SELECT
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    mid.statement,
    mid.equality_columns,
    mid.include_columns
FROM sys.dm_db_missing_index_group_stats migs
JOIN sys.dm_db_missing_index_groups mig ON migs.group_id = mig.index_group_id
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY improvement_measure DESC;
-- WHY: SQL Server tracks queries that would benefit from indexes
```

### Read/Write Splitting

```csharp
// WHY: separate read replicas for reporting queries — don't compete with writes
public class OrderRepository
{
    private readonly AppDbContext _writeContext;   // primary replica
    private readonly ReadDbContext _readContext;   // read replica (AG secondary)

    public async Task<Order> GetForUpdateAsync(Guid id)
        => await _writeContext.Orders.FindAsync(id); // WHY: must go to primary

    public async Task<IEnumerable<OrderSummaryDto>> GetSummariesAsync()
        => await _readContext.OrderSummaries.ToListAsync(); // WHY: read replica ok
}
```

---

## 5.2 Cosmos DB — Interview Essentials

```
┌──────────────────────────────────────────────────────────────────┐
│              COSMOS DB CONSISTENCY LEVELS                        │
├─────────────────────────┬────────────────────────────────────────┤
│ Level                   │ What you get                          │
├─────────────────────────┼────────────────────────────────────────┤
│ Strong                  │ Latest write always read (expensive)  │
│ Bounded Staleness       │ Reads lag writes by K ops or T time   │
│ Session (DEFAULT)       │ Read-your-writes within a session     │
│ Consistent Prefix       │ No out-of-order reads                 │
│ Eventual                │ Best performance, stale reads OK      │
└─────────────────────────┴────────────────────────────────────────┘
```

**Partition Key Selection** — most important decision:
```
Good partition key:
  ✓ High cardinality (many distinct values)
  ✓ Evenly distributes reads AND writes
  ✓ Matches most query patterns

Bad partition key:
  ✗ userId for admin dashboard (hot partition on admin queries)
  ✗ CreatedDate as date (hot partition for today's data)
  ✗ Status (only 3 values — everything on same partition)

Example decision:
  Orders collection: partition by /customerId
    WHY: each customer's orders stay together = efficient queries per customer
    RISK: if one customer has millions of orders, use /orderId instead
```

```csharp
// Cosmos DB SDK — efficient point reads vs queries
var container = cosmosClient.GetContainer("ecommerce", "orders");

// Point read — O(1), cheapest (1 RU), requires partition key + id
var response = await container.ReadItemAsync<Order>(
    id: orderId.ToString(),
    partitionKey: new PartitionKey(customerId.ToString())); // WHY: must match partition key

// Cross-partition query — expensive, avoid if possible
var query = container.GetItemQueryIterator<Order>(
    new QueryDefinition("SELECT * FROM c WHERE c.status = 'Pending'"));
// WHY: fan-out to all partitions = high RU cost
```

---

## 5.3 Redis Cache Patterns

```
┌────────────────────────────────────────────────────────────────┐
│                   CACHE PATTERNS                               │
├──────────────────────┬─────────────────────────────────────────┤
│ Cache-Aside          │ App checks cache, loads DB on miss      │
│ Write-Through        │ Write to cache AND DB simultaneously    │
│ Write-Behind         │ Write to cache, async flush to DB       │
│ Read-Through         │ Cache sits in front, fetches on miss    │
└──────────────────────┴─────────────────────────────────────────┘
```

```csharp
// Cache-aside pattern — most common in .NET
public async Task<Product> GetProductAsync(Guid id)
{
    var cacheKey = $"product:{id}";

    // 1. Check cache
    var cached = await _cache.GetStringAsync(cacheKey);
    if (cached != null)
        return JsonSerializer.Deserialize<Product>(cached)!;

    // 2. Cache miss — load from DB
    var product = await _db.Products.FindAsync(id)
        ?? throw new NotFoundException();

    // 3. Store in cache
    await _cache.SetStringAsync(cacheKey,
        JsonSerializer.Serialize(product),
        new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15), // WHY: prevent stale data forever
            SlidingExpiration = TimeSpan.FromMinutes(5)                 // WHY: evict if not accessed
        });

    return product;
}
```

**Cache Stampede Prevention**:
```csharp
// WHY: when cache expires, all concurrent requests go to DB simultaneously
// Solution: probabilistic early expiration OR distributed lock

private readonly SemaphoreSlim _semaphore = new(1, 1); // local lock (single instance)

// For multi-instance: use Redis SETNX (set-if-not-exists) as distributed lock
await _cache.SetAsync($"lock:{key}", "1", new DistributedCacheEntryOptions
{
    AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(30) // WHY: auto-expire lock
}, token: nx: true); // atomic set-if-not-exists
```

---

# 6. Security Architecture

> **Mental Model**: Security is defense in depth — like a medieval castle with moat, walls, gates, and guards at every door. No single layer is trusted completely.

---

## 6.1 OAuth2 + OpenID Connect Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                  OAUTH2 AUTHORIZATION CODE FLOW                      │
│                                                                      │
│  User Browser                                                        │
│       │                                                              │
│       │ 1. Click Login                                               │
│       ↓                                                              │
│  SPA / Web App                                                       │
│       │                                                              │
│       │ 2. Redirect to Azure AD with client_id, scope, code_challenge│
│       ↓                                                              │
│  Azure AD (Authorization Server)                                     │
│       │                                                              │
│       │ 3. User authenticates (MFA etc)                              │
│       │ 4. Returns authorization CODE to redirect_uri               │
│       ↓                                                              │
│  SPA / Web App                                                       │
│       │                                                              │
│       │ 5. Exchange code + code_verifier → access_token + id_token  │
│       │    (PKCE prevents code interception attacks)                 │
│       ↓                                                              │
│  API (Resource Server)                                               │
│       │                                                              │
│       │ 6. Validate JWT: signature, issuer, audience, expiry        │
│       │ 7. Extract claims → authorization decisions                  │
└──────────────────────────────────────────────────────────────────────┘
```

### JWT Validation in ASP.NET Core

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://login.microsoftonline.com/{tenant-id}/v2.0";
        options.Audience = "api://my-api-client-id";
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,           // WHY: reject tokens from other tenants
            ValidateAudience = true,          // WHY: reject tokens meant for other APIs
            ValidateLifetime = true,          // WHY: reject expired tokens
            ValidateIssuerSigningKey = true,  // WHY: reject forged tokens
            ClockSkew = TimeSpan.FromMinutes(1) // WHY: handle minor clock drift
        };
    });

// Policy-based authorization
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("OrdersAdmin", policy =>
        policy.RequireClaim("roles", "Orders.Admin")); // WHY: role-based from app registration
});
```

---

## 6.2 OWASP Top 10 — Architect Responses

```
┌──────────────────────────────────────────────────────────────────────┐
│              OWASP TOP 10 — HOW ARCHITECTS MITIGATE                 │
├────────────────────────────┬─────────────────────────────────────────┤
│ A01 Broken Access Control  │ Policy-based authz, least privilege     │
│ A02 Cryptographic Failures │ TLS everywhere, Key Vault for keys      │
│ A03 Injection              │ Parameterized queries, ORM, input valid │
│ A04 Insecure Design        │ Threat modeling, defense in depth       │
│ A05 Security Misconfiguration│ IaC scanning, no default passwords    │
│ A06 Vulnerable Components  │ Dependabot, SBOM, container scanning   │
│ A07 Auth Failures          │ OAuth2/OIDC, MFA, rate limiting login  │
│ A08 Software Integrity     │ Signed images, SLSA, verified deps      │
│ A09 Logging Failures       │ Centralized logging, security events   │
│ A10 SSRF                   │ Allowlist outbound, Private Endpoints  │
└────────────────────────────┴─────────────────────────────────────────┘
```

---

## 6.3 Zero Trust Architecture

```
┌────────────────────────────────────────────────────────────────┐
│               ZERO TRUST PRINCIPLES                            │
│                                                                │
│  "Never trust, always verify"                                  │
│                                                                │
│  1. Verify explicitly                                          │
│     Every request authenticated + authorized                  │
│     Verify identity, location, device, service                │
│                                                                │
│  2. Use least privilege access                                 │
│     JIT (Just-In-Time) access                                 │
│     Managed Identities (no passwords)                         │
│     Scoped RBAC roles                                          │
│                                                                │
│  3. Assume breach                                              │
│     Segment networks (private endpoints)                      │
│     End-to-end encryption                                      │
│     Audit all access                                           │
│                                                                │
│  Azure Implementation:                                         │
│  • Entra ID (AAD) for all auth                                │
│  • Managed Identity + Key Vault                               │
│  • Private Endpoints (no public DB exposure)                  │
│  • Azure Policy + Defender for Cloud                          │
│  • NSG + Azure Firewall                                        │
└────────────────────────────────────────────────────────────────┘
```

---

## 6.4 Secrets Management

```csharp
// WHY: Secrets in Key Vault, not in app settings / env vars
// Integration with ASP.NET Core configuration

builder.Configuration.AddAzureKeyVault(
    new Uri("https://myvault.vault.azure.net/"),
    new DefaultAzureCredential()); // WHY: uses Managed Identity in Azure, dev creds locally

// Access secret same as any config value
var connStr = builder.Configuration["ConnectionStrings:Default"];
// WHY: transparent — code doesn't know source is Key Vault
```

---

# 7. DevOps & CI/CD

> **Mental Model**: A good CI/CD pipeline is like an assembly line with quality gates — code moves through stations (build → test → security scan → package → deploy) and is rejected at the gate if it fails, never advancing to production.

---

## 7.1 CI/CD Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                     CI/CD PIPELINE FLOW                              │
│                                                                      │
│  Developer pushes code                                               │
│       ↓                                                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  CI Pipeline (every push)                                   │    │
│  │  ┌───────────┐ ┌──────────────┐ ┌──────────────────────┐  │    │
│  │  │  Build    │→│  Unit Tests  │→│  Security Scan       │  │    │
│  │  │ dotnet    │ │ xUnit, 80%+  │ │ SAST (Snyk, SonarQube│  │    │
│  │  │ publish   │ │ coverage     │ │ )                    │  │    │
│  │  └───────────┘ └──────────────┘ └──────────────────────┘  │    │
│  │                       ↓                                     │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  Docker Build → Image Scan → Push to ACR             │  │    │
│  │  │  (Trivy / Defender for Containers)                   │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────┘    │
│       ↓                                                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  CD Pipeline (on merge to main)                             │    │
│  │                                                             │    │
│  │  Dev → Integration Tests → Staging → Smoke Tests → Prod    │    │
│  │         (E2E, contract)              (canary/blue-green)    │    │
│  └─────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```

### GitHub Actions — .NET + AKS

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: myregistry.azurecr.io
  IMAGE: order-service

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.0'

    - name: Restore
      run: dotnet restore

    - name: Build
      run: dotnet build --no-restore -c Release

    - name: Test with coverage
      run: |
        dotnet test --no-build -c Release \
          --collect:"XPlat Code Coverage" \
          --results-directory ./coverage
    # WHY: fail pipeline if tests fail

    - name: Upload coverage
      uses: codecov/codecov-action@v4

  docker-deploy:
    needs: build-test
    if: github.ref == 'refs/heads/main'  # WHY: only deploy from main
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Login to ACR
      uses: azure/docker-login@v1
      with:
        login-server: ${{ env.REGISTRY }}
        username: ${{ secrets.ACR_USERNAME }}
        password: ${{ secrets.ACR_PASSWORD }}

    - name: Build and push
      run: |
        docker build -t ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }} .
        docker push ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}
        # WHY: tag with git SHA for traceability / rollback

    - name: Deploy to AKS
      uses: azure/k8s-deploy@v4
      with:
        namespace: production
        manifests: ./k8s/
        images: ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}
        strategy: canary       # WHY: gradual rollout reduces blast radius
        percentage: 20         # WHY: 20% of traffic to new version first
```

---

## 7.2 Deployment Strategies

```
┌──────────────────────────────────────────────────────────────────┐
│              DEPLOYMENT STRATEGIES COMPARISON                    │
├──────────────────┬───────────────────────────────────────────────┤
│ Strategy         │ How it works                                  │
├──────────────────┼───────────────────────────────────────────────┤
│ Recreate         │ Stop all → Deploy all (downtime)             │
│ Rolling Update   │ Replace pods gradually (K8s default)         │
│ Blue/Green       │ Two full environments, switch traffic        │
│ Canary           │ 5-20% traffic to new, monitor, increase      │
│ A/B Testing      │ Route by user segment for feature testing    │
│ Shadow           │ Mirror traffic, no user impact               │
└──────────────────┴───────────────────────────────────────────────┘
```

---

## 7.3 GitOps with ArgoCD / Flux

```
┌────────────────────────────────────────────────────────────────┐
│                      GITOPS FLOW                               │
│                                                                │
│  Developer                                                     │
│       ↓ PR to infra repo                                       │
│  Git Repository (source of truth for k8s manifests)           │
│       ↓ ArgoCD/Flux watches                                    │
│  GitOps Operator detects drift                                │
│       ↓ applies to cluster                                     │
│  AKS Cluster (always matches git state)                       │
│                                                                │
│  WHY: No kubectl apply from pipelines — git IS the deployment  │
│  BENEFIT: Full audit trail, rollback = git revert             │
└────────────────────────────────────────────────────────────────┘
```

---

# 8. Monitoring & Observability

> **Mental Model**: Observability is about asking questions your system wasn't designed to answer. The three pillars — metrics, logs, traces — are like vital signs (metrics), medical history (logs), and an X-ray (distributed trace) for your system.

---

## 8.1 OpenTelemetry in .NET

```csharp
// WHY: OTel is vendor-neutral — collect once, export to anywhere (App Insights, Jaeger, Datadog)
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()       // WHY: auto-traces all HTTP requests
        .AddHttpClientInstrumentation()        // WHY: traces outbound HTTP calls
        .AddEntityFrameworkCoreInstrumentation() // WHY: traces DB queries
        .AddAzureMonitorTraceExporter(o =>
            o.ConnectionString = builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]))

    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddAzureMonitorMetricExporter())

    .WithLogging(logging => logging
        .AddAzureMonitorLogExporter());

// Custom span for business operations
private static readonly ActivitySource _activitySource = new("OrderService");

public async Task<Order> CreateOrderAsync(CreateOrderCommand cmd)
{
    using var activity = _activitySource.StartActivity("CreateOrder"); // WHY: custom trace span
    activity?.SetTag("order.customerId", cmd.CustomerId);              // WHY: searchable attributes
    activity?.SetTag("order.itemCount", cmd.Items.Count);

    // ... logic

    activity?.SetTag("order.id", order.Id.ToString());
    return order;
}
```

---

## 8.2 Application Insights — Key KQL Queries

```kql
// Request failure rate by operation
requests
| where timestamp > ago(1h)
| summarize
    total = count(),
    failures = countif(success == false),
    failureRate = round(100.0 * countif(success == false) / count(), 2)
  by operation_Name
| order by failureRate desc

// Slow dependencies (P95 latency)
dependencies
| where timestamp > ago(1h)
| summarize P95 = percentile(duration, 95) by target, type
| where P95 > 1000  // WHY: highlight dependencies > 1 second P95
| order by P95 desc

// Exception tracking
exceptions
| where timestamp > ago(24h)
| summarize count() by type, outerMessage
| order by count_ desc
| take 20

// Distributed trace correlation
requests
| where operation_Id == "abc123"  // WHY: correlate all telemetry for one request
| join kind=leftouter (dependencies | project operation_Id, depName=name, depDuration=duration)
    on operation_Id
```

---

## 8.3 Health Checks

```csharp
// WHY: K8s liveness/readiness probes call /health endpoints
builder.Services.AddHealthChecks()
    .AddSqlServer(connectionString,              // WHY: check DB connectivity
        name: "database",
        failureStatus: HealthStatus.Degraded)
    .AddRedis(redisConnectionString,
        name: "cache",
        failureStatus: HealthStatus.Degraded)
    .AddAzureServiceBusQueue(
        sbConnectionString, "orders",
        name: "servicebus");

// Separate live vs ready endpoints
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false  // WHY: liveness just checks process is alive (no deps)
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
    // WHY: readiness checks all dependencies — pod gets traffic only when ready
});
```

---

# 9. Leadership & Architecture Decisions

> **Mental Model**: An architect's job is to make decisions that are hard to reverse easily, and easy to reverse quickly. Maximize reversibility by deferring irreversible decisions.

---

## 9.1 Monolith vs Microservices Decision Framework

```
┌──────────────────────────────────────────────────────────────────────┐
│           WHEN TO USE WHAT                                           │
├─────────────────────────────┬────────────────────────────────────────┤
│ Choose Monolith when:       │ Choose Microservices when:             │
├─────────────────────────────┼────────────────────────────────────────┤
│ Team < 10 engineers         │ Multiple large teams                   │
│ Early product stage         │ Independent scaling needs              │
│ Domain not well understood  │ Domain well bounded                    │
│ Simple deployment needs     │ Different tech stacks per domain       │
│ Budget constrained          │ Different release cycles per service   │
│ Startup / MVP               │ Regulatory isolation needed            │
└─────────────────────────────┴────────────────────────────────────────┘

Intermediate: Modular Monolith
  - Single deployable unit
  - Strict module boundaries (no cross-module DB access)
  - Easy to extract modules to services later
  WHY: Monolith simplicity + module independence. Best of both worlds.
```

---

## 9.2 Technology Selection Framework

```
┌────────────────────────────────────────────────────────────────┐
│         ARCHITECT'S TECHNOLOGY SELECTION CRITERIA             │
│                                                                │
│  1. Fit for purpose                                            │
│     Does it solve the specific problem efficiently?            │
│                                                                │
│  2. Team capability                                            │
│     Can the team build AND operate it?                         │
│                                                                │
│  3. Operational maturity                                       │
│     Is it production-proven at our scale?                      │
│                                                                │
│  4. Total Cost of Ownership                                    │
│     License + infra + ops + learning curve                     │
│                                                                │
│  5. Exit strategy                                              │
│     How hard to replace if it fails us?                        │
│                                                                │
│  6. Vendor lock-in risk                                        │
│     Managed service vs portable OSS                            │
│                                                                │
│  7. Security posture                                           │
│     CVE history, patching cadence, compliance                  │
└────────────────────────────────────────────────────────────────┘
```

---

## 9.3 Architecture Review Board Mindset

**Questions an architect asks in every design review:**

```
Correctness:
  • Does it solve the stated business problem?
  • What are the failure modes? How does it fail gracefully?

Scalability:
  • What is the bottleneck at 10x current load?
  • Where does state live? Can it scale horizontally?

Operability:
  • How do we deploy it? Roll it back?
  • How do we debug a production incident at 2am?
  • What alerts exist?

Security:
  • What is the trust boundary?
  • What data is sensitive? Where does it flow?

Cost:
  • What does this cost at 10x load?
  • Are there cheaper alternatives with the same SLA?

Simplicity:
  • Is this the simplest design that solves the problem?
  • What complexity are we adding? Is it justified?
```

---

## 9.4 Handling Conflict — Technical vs Business Requirements

```
Scenario: Business wants feature in 2 weeks. Proper design needs 6 weeks.

Architect approach:
  1. Understand WHY the deadline exists (is it a real constraint?)
  2. Quantify the technical debt cost of the shortcut
  3. Propose options with trade-offs, not unilateral decisions:
     Option A: Full design (6 weeks) — maintainable, scalable
     Option B: Tactical approach (2 weeks) — works, but refactor sprint required in Q2
     Option C: Negotiate scope (3 weeks) — MVP with key quality attributes
  4. Document the decision and trade-offs (Architecture Decision Records)
  5. Get explicit stakeholder sign-off on technical debt
```

---

# 10. System Design Deep Dives

---

## 10.1 Design a Payment Processing System

```
┌──────────────────────────────────────────────────────────────────────┐
│              PAYMENT PROCESSING SYSTEM                               │
│                                                                      │
│  Client                                                              │
│     ↓ POST /payments {idempotencyKey, amount, customerId}           │
│  API Gateway (APIM)                                                  │
│     ↓ Auth + rate limiting (10 payments/min per customer)           │
│  Payment API Service                                                 │
│     ↓                                                                │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Idempotency Check (Redis)                                   │   │
│  │  if key exists → return cached response (prevent duplicate)  │   │
│  └──────────────────────────────────────────────────────────────┘   │
│     ↓                                                                │
│  BEGIN DB TRANSACTION                                                │
│     ↓                                                                │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │  1. Create PaymentRecord (status=Pending)                  │     │
│  │  2. Write OutboxMessage (PaymentInitiated event)           │     │
│  │  3. Reserve idempotency key                                │     │
│  └────────────────────────────────────────────────────────────┘     │
│  COMMIT TX                                                           │
│     ↓                                                                │
│  Return 202 Accepted (paymentId for polling)                        │
│     ↓                                                                │
│  Outbox Processor polls → publishes to Service Bus                  │
│     ↓                                                                │
│  Payment Worker Service                                              │
│     ↓ calls payment gateway (Stripe/Adyen)                          │
│     ↓                                                                │
│  Update PaymentRecord status → publish PaymentCompleted/Failed      │
│     ↓                                                                │
│  Order Service subscribes → fulfills order on success               │
└──────────────────────────────────────────────────────────────────────┘

Key Design Decisions:
  • Idempotency: Redis with idempotency key prevents double-charge
  • Async: 202 Accepted + webhook/polling (payment gateways can take seconds)
  • Outbox: Guarantees event is published even if process crashes
  • Retry: Idempotent calls to payment gateway safe to retry
  • Audit: Every state change logged with timestamp and actor
```

---

## 10.2 Design a Notification System

```
┌──────────────────────────────────────────────────────────────────────┐
│              NOTIFICATION SYSTEM                                     │
│                                                                      │
│  Event Sources (Order placed, payment failed, shipment updated)      │
│       ↓ publish events                                               │
│  Azure Service Bus Topic: "notifications"                            │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Subscription: email-notifications                           │   │
│  │  Subscription: sms-notifications                             │   │
│  │  Subscription: push-notifications                            │   │
│  └──────────────────────────────────────────────────────────────┘   │
│       ↓                    ↓                   ↓                    │
│  Email Worker          SMS Worker          Push Worker              │
│  (SendGrid)            (Twilio)            (FCM/APNs)              │
│                                                                      │
│  User Preferences Service:                                           │
│  • Can a user receive SMS? (opted in?)                               │
│  • Email verified?                                                   │
│  • Push token registered?                                            │
│  • Do Not Disturb hours?                                             │
│                                                                      │
│  Template Service:                                                   │
│  • Localized templates per event type                                │
│  • Personalization tokens {{name}}, {{orderId}}                     │
│                                                                      │
│  Dead Letter Queue:                                                  │
│  • Failed deliveries → retry 3x → DLQ → alert oncall              │
│                                                                      │
│  Rate Limiting:                                                      │
│  • Max 5 notifications per user per hour (Redis counter)            │
└──────────────────────────────────────────────────────────────────────┘

Scale numbers:
  1M users, 10M notifications/day = ~115/sec average, 1000/sec peak
  Service Bus handles 10M/sec+ → not the bottleneck
  Email: SendGrid 100k/hour → need multiple accounts at scale
```

---

## 10.3 Design a File Upload System (Azure)

```
┌──────────────────────────────────────────────────────────────────────┐
│              FILE UPLOAD SYSTEM                                      │
│                                                                      │
│  Client                                                              │
│     ↓ POST /files/upload-url {filename, contentType, size}          │
│  File API                                                            │
│     ↓                                                                │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │  1. Validate: file type whitelist, max size (100MB)        │     │
│  │  2. Generate Blob Storage SAS URL (write-only, 5min TTL)   │     │
│  │  3. Store FileRecord (id, status=Pending, blobPath)        │     │
│  └────────────────────────────────────────────────────────────┘     │
│     ↓ return { uploadUrl, fileId }                                   │
│  Client uploads directly to Blob Storage (no API traffic)           │
│     ↓                                                                │
│  Blob Storage trigger → Azure Function                               │
│     ↓                                                                │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │  Post-upload processing:                                   │     │
│  │  • Virus scan (Defender for Storage)                       │     │
│  │  • Image resize / thumbnail generation                     │     │
│  │  • Metadata extraction                                     │     │
│  │  • Update FileRecord status = Ready                        │     │
│  └────────────────────────────────────────────────────────────┘     │
│     ↓                                                                │
│  Client polls GET /files/{fileId} until status=Ready               │
│     ↓                                                                │
│  Serve via CDN (Azure CDN / Front Door) with SAS read URL          │
│                                                                      │
│  WHY direct upload to Blob:                                          │
│  • API doesn't handle file bytes (no memory pressure)               │
│  • Blob Storage handles massive parallel uploads                     │
│  • Client → Blob is direct (fast, no double-network hop)            │
└──────────────────────────────────────────────────────────────────────┘
```

```csharp
// Generate SAS URL for direct upload
public async Task<UploadUrlResponse> GenerateUploadUrlAsync(UploadUrlRequest request)
{
    var blobClient = _containerClient.GetBlobClient($"uploads/{Guid.NewGuid()}/{request.FileName}");

    var sasBuilder = new BlobSasBuilder
    {
        BlobContainerName = _containerClient.Name,
        BlobName = blobClient.Name,
        Resource = "b",
        ExpiresOn = DateTimeOffset.UtcNow.AddMinutes(5),  // WHY: short TTL = reduced attack window
        Protocol = SasProtocol.Https                       // WHY: HTTPS only
    };
    sasBuilder.SetPermissions(BlobSasPermissions.Write | BlobSasPermissions.Create);
    // WHY: write-only — client cannot read other blobs

    var sasUri = blobClient.GenerateSasUri(sasBuilder);

    await _db.FileRecords.AddAsync(new FileRecord
    {
        BlobPath = blobClient.Name,
        Status = FileStatus.Pending,
        UploadedBy = _currentUser.Id
    });

    return new UploadUrlResponse(sasUri.ToString(), fileId);
}
```

---

## 10.4 Design a URL Shortener (Classic Interview Question)

```
┌──────────────────────────────────────────────────────────────────────┐
│              URL SHORTENER SYSTEM DESIGN                             │
│                                                                      │
│  POST /shorten { longUrl }                                           │
│       ↓                                                              │
│  Generate short code:                                                │
│  • Base62 encode (a-z, A-Z, 0-9) of auto-increment ID               │
│  • 7 chars = 62^7 = 3.5 trillion URLs                               │
│                                                                      │
│  Store: shortCode → longUrl (Cosmos DB partition by shortCode)      │
│  Cache: shortCode → longUrl (Redis, TTL 24h)                        │
│                                                                      │
│  GET /{code}                                                         │
│       ↓                                                              │
│  1. Check Redis cache                                                │
│  2. If miss → lookup Cosmos DB                                       │
│  3. If not found → 404                                               │
│  4. Return 301 (permanent) or 302 (temporary) redirect              │
│                                                                      │
│  Analytics (async):                                                  │
│  • Log click event to Event Hub                                      │
│  • Stream processing → Cosmos DB analytics                          │
│                                                                      │
│  Scale numbers for 100M redirects/day:                              │
│  ~1150 RPS average, ~5000 RPS peak                                  │
│  Redis easily handles 100k+ RPS → reads are the non-bottleneck     │
│  Bottleneck: write throughput for analytics                         │
└──────────────────────────────────────────────────────────────────────┘
```

---

# 11. 20 Real Interview Questions & Answers

---

## Architecture Fundamentals

**Q1: How do you approach designing a new microservices system from scratch?**

```
Answer (3-part structure):

1. Understand the domain FIRST
   • Event storming with domain experts
   • Identify bounded contexts (DDD)
   • Map aggregates, commands, events

2. Define service boundaries
   • One service per bounded context
   • Verify: can teams work independently?
   • Verify: would any change require coordinating 3+ services? (indicates wrong boundary)

3. Define communication strategy
   • Synchronous (REST/gRPC) for queries and real-time
   • Asynchronous (Service Bus) for commands and workflows
   • Design contracts first (API specs, message schemas)

Start with a modular monolith if domain isn't well understood yet.
```

---

**Q2: Explain the difference between Orchestration and Choreography in Sagas. When would you use each?**

```
Orchestration: Central coordinator tells each service what to do
  ✓ Easy to trace (one place to see full flow)
  ✓ Simpler compensations
  ✗ Coordinator is SPOF and coupling point
  USE: Complex workflows with many services, critical order flows

Choreography: Services react to events, no coordinator
  ✓ Fully decoupled
  ✓ More resilient
  ✗ Hard to trace (need distributed tracing)
  ✗ Hard to understand complete flow from code
  USE: Simple linear flows, when loose coupling is paramount

My rule: Start with choreography for < 4 steps, orchestration for complex multi-step with compensations.
```

---

**Q3: How do you handle database schema changes in microservices without downtime?**

```
Expand-Contract pattern (Blue/Green for schema):

Phase 1: EXPAND
  • Add new column (nullable or with default)
  • Deploy new code that WRITES to both old + new column
  • Old code still works (no breaking change)

Phase 2: MIGRATE
  • Backfill old rows with data in new column
  • Verify data correctness

Phase 3: CONTRACT
  • Deploy code that reads ONLY from new column
  • Drop old column

Key: Never remove a column that old code still reads.
Never rename — add + backfill + remove.
```

---

**Q4: How does gRPC differ from REST and when would you choose it?**

```
gRPC:
  • Binary Protocol Buffers (compact, fast serialization)
  • HTTP/2 (multiplexing, streaming, server push)
  • Strongly typed contracts
  • Code generation for clients
  • ~10x faster than JSON/REST for internal calls

REST:
  • Text-based JSON (human readable, easy tooling)
  • HTTP/1.1 or 2
  • Loose contracts (OpenAPI)
  • Universal browser support

Choose gRPC for:
  • Internal service-to-service communication
  • High-throughput, low-latency requirements
  • Bidirectional streaming (real-time feeds)
  • Polyglot environments (auto-generated clients)

Choose REST for:
  • Public APIs (browser clients, external partners)
  • Simple CRUD operations
  • When tooling/debugging simplicity matters
```

---

**Q5: How do you design for high availability in Azure?**

```
Layers of HA:

1. Application layer
   • Stateless services (horizontal scaling)
   • Health probes (liveness/readiness)
   • Graceful shutdown (drain connections on pod termination)

2. Platform layer (AKS)
   • Multiple replicas (minimum 3)
   • Pod anti-affinity (spread across nodes)
   • Pod Disruption Budgets (PDB: maxUnavailable: 1)
   • Multiple node pools across Availability Zones

3. Azure infrastructure
   • Zone-redundant services (AKS, SQL, Redis)
   • Azure Front Door for global failover
   • RTO/RPO defined per service tier

4. Data layer
   • SQL: Always On AG or Business Critical tier
   • Cosmos DB: multi-region writes
   • Redis: Premium tier with geo-replication
```

---

**Q6: What is the Bulkhead pattern and why is it important?**

```
Bulkhead: Isolate resources per consumer to prevent one failing consumer
from exhausting all shared resources.

Named after ship compartments — if one floods, others stay dry.

In .NET:
  // Separate thread pools per downstream service
  services.AddHttpClient("PaymentService")
      .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
      {
          MaxConnectionsPerServer = 20  // WHY: payment pool capped at 20 connections
      });

  services.AddHttpClient("CatalogService")
      .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
      {
          MaxConnectionsPerServer = 50  // WHY: catalog pool separate, higher limit
      });

Without bulkhead:
  CatalogService slowdown → exhausts shared thread pool → PaymentService also fails
  (cascading failure)

With bulkhead:
  CatalogService slowdown → its own pool exhausted → PaymentService unaffected
```

---

**Q7: How do you version APIs without breaking existing clients?**

```
Rules:
  1. Never remove or rename fields in responses (additive only)
  2. New required request fields need a version bump
  3. New optional fields don't need version bump

Strategy:
  • URL versioning: /api/v1/orders → /api/v2/orders (most explicit)
  • Support N and N-1 versions simultaneously
  • Deprecation policy: 6 months notice before removing a version
  • Add Sunset header to deprecated versions: Sunset: Sat, 01 Jan 2026 00:00:00 GMT

Consumer-driven contract testing (Pact):
  Each consumer publishes its contract → providers verify they meet all contracts
  WHY: Catch breaking changes before deployment
```

---

**Q8: What are the CAP theorem implications for distributed systems design?**

```
CAP Theorem: A distributed system can guarantee at most 2 of:
  • Consistency (all nodes see same data)
  • Availability (every request gets a response)
  • Partition Tolerance (works despite network splits)

Network partitions WILL happen → choose C or A:

CP (Consistency + Partition Tolerance):
  Examples: SQL databases, ZooKeeper, etcd, HBase
  Trade-off: May reject requests during partition
  Use for: Financial transactions, inventory (correctness critical)

AP (Availability + Partition Tolerance):
  Examples: Cosmos DB (eventual), Cassandra, DynamoDB
  Trade-off: May return stale data during partition
  Use for: Product catalog, user profiles, recommendation (availability critical)

PACELC: Extends CAP — even without partitions, E(latency) vs C(consistency) trade-off exists.
Cosmos DB lets you choose per operation consistency level.
```

---

**Q9: How do you handle secrets in a Kubernetes environment?**

```
Levels of security (best to worst):

1. Azure Key Vault + Workload Identity + CSI Driver (BEST)
   • Secrets live only in Key Vault
   • Pod gets secret via mounted volume
   • Auto-rotation supported
   • No secret stored in k8s etcd

2. Azure Key Vault + CSI Driver (without WI)
   • Uses service principal (rotation needed)

3. K8s Secrets (base64 encoded, NOT encrypted by default)
   • Enable etcd encryption at rest in AKS
   • Restrict access with RBAC
   • Never store in git

4. ConfigMap (WORST for secrets — plain text)
   • Only for non-sensitive config

Production rule: Secrets never in container images, git, or plain ConfigMaps.
```

---

**Q10: What is the Outbox pattern and why is it needed?**

```
Problem: Publishing an event AND saving to DB must be atomic.
Without Outbox, these two can get out of sync:
  • DB save succeeds, event publish fails → order created but no notification
  • Event published, DB save fails → ghost event

Outbox pattern:
  BEGIN TX
    INSERT INTO Orders (...)         -- your business data
    INSERT INTO OutboxMessages (...) -- the event you want to publish
  COMMIT TX
  (atomic — both succeed or both fail)

  Background worker polls OutboxMessages
  → publish to Service Bus
  → mark message as processed

  Result: At-least-once delivery (design consumers to be idempotent)

Library: MassTransit has built-in Outbox for EF Core.
```

---

## Cloud & Azure

**Q11: Explain how you would design a multi-tenant SaaS on Azure.**

```
Tenancy models:

1. Silo (Fully isolated)
   • Separate AKS namespace or cluster per tenant
   • Separate databases
   ✓ Max isolation, compliance-friendly
   ✗ Expensive, hard to scale # tenants

2. Pool (Shared infrastructure, logical separation)
   • Shared AKS cluster, tenant ID in all queries
   • Shared database with tenant discriminator
   • Row-level security in SQL
   ✓ Cost efficient, scales to 1000s of tenants
   ✗ Noisy neighbor risk, harder compliance

3. Bridge (Pool + Silo for premium)
   • Standard tenants: shared pool
   • Enterprise tenants: dedicated infra
   ✓ Balances cost and compliance

My approach:
  Start pool → identify whales (large tenants) → silo them
  Use tenant middleware to inject TenantId into DbContext queries automatically
  Azure API Management to route tenants to appropriate tier
```

---

**Q12: How does Azure Front Door differ from Application Gateway?**

```
Front Door:
  • Global (Anycast, 200+ PoPs worldwide)
  • CDN capabilities (static + dynamic caching)
  • Global WAF
  • Multi-region failover (seconds)
  • SSL termination at edge
  USE: Public-facing apps, global user base, CDN needs

Application Gateway:
  • Regional (within one Azure region)
  • L7 HTTP routing, path-based routing
  • URL rewrite, header manipulation
  • WebSocket support
  • Good for AKS ingress (AGIC)
  USE: Regional apps, complex L7 routing within a region

Both together:
  Front Door → regional App Gateway → AKS
  WHY: Front Door handles global routing + CDN, AppGW handles regional L7 routing
```

---

**Q13: How would you migrate a monolith to microservices without rewriting from scratch?**

```
Strangler Fig pattern:

Phase 1: Identify seams
  • Find bounded contexts in the monolith
  • Choose the first service to extract (least coupled, most independent)

Phase 2: Facade
  • Put a routing facade (APIM or NGINX) in front of monolith
  • All traffic still goes to monolith

Phase 3: Extract & redirect
  • Build Order microservice independently
  • Route /api/orders/* to new service via facade
  • Monolith still handles everything else

Phase 4: Data migration
  • Dual-write: monolith writes to both its DB and new service's DB
  • Verify consistency
  • Cut over reads to new service
  • Stop dual-write, monolith no longer writes orders

Phase 5: Repeat for next domain

Key risks:
  • Data consistency during dual-write period
  • Distributed transactions (use Saga instead of 2PC)
  • Increased operational complexity
```

---

## Performance & Scaling

**Q14: How do you diagnose and fix a slow API endpoint?**

```
Systematic approach:

1. Measure (don't guess)
   • Application Insights: identify slow operations
   • SQL Query Store: find top 10 slow queries
   • Add custom timing spans (OTel)

2. Common culprits:
   • N+1 queries → use .Include() or batch loading
   • Missing indexes → check execution plan
   • Synchronous I/O on hot path → make async
   • Missing cache → add Cache-Aside
   • Large payload → pagination + projection
   • Blocking call in middleware

3. N+1 pattern fix:
   // SLOW: 1 query + N queries for related data
   var orders = await db.Orders.ToListAsync();
   foreach (var order in orders)
       var customer = await db.Customers.FindAsync(order.CustomerId); // N queries!

   // FAST: 1 query with JOIN
   var orders = await db.Orders
       .Include(o => o.Customer)   // WHY: single JOIN query
       .ToListAsync();

4. Verify fix with load test (k6, NBomber)
```

---

**Q15: How would you design for 10x traffic spikes (e.g., Black Friday)?**

```
Preparation:

1. Auto-scaling
   • HPA on AKS: scale pods on CPU/memory
   • KEDA: scale workers on queue depth
   • Cluster Autoscaler: add nodes when pods pending

2. Load testing
   • Run k6 load test to find breaking point
   • Fix bottlenecks BEFORE the spike

3. Caching
   • Pre-warm cache for popular items
   • CDN for static assets
   • Redis for product catalog, user sessions

4. Async offloading
   • Orders → Service Bus queue → async processing
   • Email confirmations async
   • Analytics async

5. Graceful degradation
   • Disable non-critical features under extreme load
   • Feature flags (LaunchDarkly / Azure App Config)
   • Return simplified responses

6. Infrastructure pre-scaling
   • Manual scale-out before known spike
   • Scheduled scaling rules

7. Data layer
   • Read replicas for reporting
   • CosmosDB: burst RU provisioning
```

---

## Security & Compliance

**Q16: How do you implement authorization for a multi-role system?**

```csharp
// Policy-based authorization — flexible, testable

// Define policies
services.AddAuthorization(options =>
{
    options.AddPolicy("CanManageOrders", policy =>
        policy.Requirements.Add(new OrderManagementRequirement()));
});

// Requirement + Handler (separates policy from mechanism)
public class OrderManagementHandler : AuthorizationHandler<OrderManagementRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        OrderManagementRequirement requirement)
    {
        var user = context.User;

        if (user.IsInRole("OrderAdmin") ||
            user.HasClaim("permission", "orders:manage"))
        {
            context.Succeed(requirement);
        }
        // WHY: policy logic isolated — easy to unit test

        return Task.CompletedTask;
    }
}

// Resource-based authorization (can THIS user manage THIS order?)
var authResult = await _authorizationService.AuthorizeAsync(
    User, order, "CanManageOrders");
if (!authResult.Succeeded)
    return Forbid();
```

---

**Q17: What is SSRF and how would you prevent it in an Azure environment?**

```
SSRF (Server-Side Request Forgery):
  Attacker tricks your server into making requests to internal resources
  e.g., POST /fetch-url { url: "http://169.254.169.254/metadata" }
  → fetches Azure IMDS endpoint → gets managed identity token → full Azure access

Prevention:
  1. Allowlist of valid external domains (never user-controlled URLs without validation)
  2. Private Endpoints for internal Azure resources (no public internet access)
  3. Azure Firewall / NSG to block outbound to Azure metadata IPs from app pods
  4. Block link-local addresses (169.254.x.x, 10.x.x.x) in outbound allow rules
  5. Never follow redirects blindly — validate final destination URL

Network defense:
  AKS pods → outbound only to approved Azure Private Endpoints + specific external APIs
  Block 169.254.0.0/16 (Azure IMDS), 10.0.0.0/8 (internal) from app containers
```

---

## Coding & Design Patterns

**Q18: How do you implement the Repository pattern with EF Core?**

```csharp
// Generic repository — avoid for complex queries (use specific repositories instead)
// WHY: IRepository<T> causes leaky abstractions for complex scenarios

// Better: Specific repositories per aggregate
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<IEnumerable<Order>> GetByCustomerAsync(Guid customerId, CancellationToken ct = default);
    void Add(Order order);  // WHY: no async Add — EF tracking is synchronous
    void Remove(Order order);
}

public class OrderRepository : IOrderRepository
{
    private readonly AppDbContext _db;
    public OrderRepository(AppDbContext db) => _db = db;

    public async Task<Order?> GetByIdAsync(Guid id, CancellationToken ct)
        => await _db.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id, ct);

    public void Add(Order order) => _db.Orders.Add(order); // WHY: Unit of Work commits
}

// Unit of Work — groups repository operations into one transaction
public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _db;
    public IOrderRepository Orders { get; }

    public async Task<int> SaveChangesAsync(CancellationToken ct = default)
        => await _db.SaveChangesAsync(ct); // WHY: all changes committed atomically
}
```

---

**Q19: How would you implement rate limiting in .NET 8?**

```csharp
// .NET 7+ built-in rate limiting (no Polly needed for incoming)
builder.Services.AddRateLimiter(options =>
{
    // Fixed window: 100 requests per 60 seconds
    options.AddFixedWindowLimiter("api-limit", config =>
    {
        config.PermitLimit = 100;
        config.Window = TimeSpan.FromSeconds(60);
        config.QueueLimit = 10; // WHY: allow small burst to queue
        config.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
    });

    // Sliding window: smooths out bursts
    options.AddSlidingWindowLimiter("api-sliding", config =>
    {
        config.PermitLimit = 100;
        config.Window = TimeSpan.FromSeconds(60);
        config.SegmentsPerWindow = 6; // WHY: 6 x 10sec segments
    });

    // Per-client rate limiting
    options.AddPolicy("per-client", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.User?.Identity?.Name  // WHY: per authenticated user
                          ?? httpContext.Connection.RemoteIpAddress?.ToString()
                          ?? "anonymous",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 50,
                Window = TimeSpan.FromSeconds(60)
            }));

    options.OnRejected = async (context, token) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
        context.HttpContext.Response.Headers.RetryAfter = "60"; // WHY: tell client when to retry
        await context.HttpContext.Response.WriteAsync("Rate limit exceeded", token);
    };
});

app.UseRateLimiter();
app.MapControllers().RequireRateLimiting("per-client");
```

---

**Q20: How do you test microservices? What is contract testing?**

```
Testing pyramid for microservices:

1. Unit tests (most, fastest)
   • Test domain logic, use cases, handlers in isolation
   • Mock infrastructure (repo, HTTP, message bus)

2. Integration tests (some, slower)
   • Test with real dependencies (Testcontainers for DB, Redis)
   • No mocks for infrastructure — verify actual SQL queries work
   // WHY: mock/prod divergence causes hidden bugs (connection pool exhaustion, query plan changes)

3. Contract tests (Pact) — the microservices special
   Consumer publishes contract:
   "I call GET /orders/{id} and expect { id, status, items[] }"

   Provider verifies contract:
   "Does my actual API response match the consumer's contract?"

   WHY: Catch breaking API changes BEFORE deployment, no need to run full E2E suite

4. Component tests
   • Test one service with all its dependencies (DB, cache, mocks for OTHER services)
   • Verifies service works end-to-end internally

5. E2E tests (fewest, slowest)
   • Critical user journeys only
   • Runs against staging environment
   • Keep < 10 minutes or they're ignored

Testcontainers example:
[Collection("Integration")]
public class OrderRepositoryTests : IAsyncLifetime
{
    private readonly MsSqlContainer _sqlContainer = new MsSqlBuilder().Build();

    public async Task InitializeAsync() => await _sqlContainer.StartAsync();
    public async Task DisposeAsync() => await _sqlContainer.DisposeAsync();

    [Fact]
    public async Task CreateOrder_ShouldPersist()
    {
        var db = new AppDbContext(new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(_sqlContainer.GetConnectionString()).Options);
        await db.Database.MigrateAsync(); // WHY: real migrations, not in-memory

        var repo = new OrderRepository(db);
        var order = Order.Create(Guid.NewGuid(), new List<OrderItem>());
        repo.Add(order);
        await db.SaveChangesAsync();

        var found = await repo.GetByIdAsync(order.Id);
        Assert.NotNull(found);
    }
}
```

---

# 12. Microservices Design Cheatsheet

## Event-Driven Architecture Quick Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│              EVENT vs COMMAND vs QUERY                               │
├─────────────┬─────────────────────┬──────────────────────────────────┤
│ Type        │ Direction           │ Example                          │
├─────────────┼─────────────────────┼──────────────────────────────────┤
│ Command     │ One sender → one    │ CreateOrder, ProcessPayment      │
│             │ receiver            │ (imperative, has intent)         │
├─────────────┼─────────────────────┼──────────────────────────────────┤
│ Event       │ One publisher →     │ OrderCreated, PaymentFailed      │
│             │ many subscribers    │ (past tense, factual)            │
├─────────────┼─────────────────────┼──────────────────────────────────┤
│ Query       │ Request/response    │ GetOrder, ListProducts           │
│             │ synchronous         │ (no side effects)                │
└─────────────┴─────────────────────┴──────────────────────────────────┘
```

## Service Decomposition Heuristics

```
✓ Good service boundary indicators:
  • Team can build/deploy/operate independently
  • Clear business domain ownership
  • Minimal data sharing with other services
  • Different release cadence from neighbors

✗ Bad service boundary indicators:
  • Services must always deploy together
  • Service calls another service synchronously on every request (chatty)
  • Two services share a database table
  • Service has no business meaning (just "utilities")
```

## Anti-Patterns to Name in Interviews

```
┌──────────────────────────────────────────────────────────────────────┐
│              MICROSERVICES ANTI-PATTERNS                             │
├──────────────────────────┬───────────────────────────────────────────┤
│ Anti-Pattern             │ Problem                                  │
├──────────────────────────┼───────────────────────────────────────────┤
│ Distributed monolith     │ Micro-sized but tightly coupled          │
│ Shared database          │ Defeats service independence             │
│ Too fine-grained         │ Too much network overhead + complexity   │
│ Synchronous chain        │ A→B→C→D cascading failures              │
│ No API versioning        │ Breaking consumers on every deploy       │
│ Missing observability    │ Can't debug production issues            │
│ Skipping idempotency     │ Duplicate processing on retry            │
└──────────────────────────┴───────────────────────────────────────────┘
```

---

# 13. AKS Architecture Interview Answers

## Must-Know AKS Concepts for Interviews

**Q: How does pod networking work in AKS?**
```
Azure CNI: Each pod gets a real Azure VNet IP (same VNet as nodes)
  ✓ Direct routing, no overlay
  ✓ NSG rules apply at pod level
  ✗ More IPs consumed (plan subnet size carefully)

Kubenet: Pods get private IPs from pod CIDR, NAT to node IP
  ✓ Simpler, fewer IPs needed
  ✗ Extra hop (UDR required), no pod-level NSG

Azure CNI Overlay (new): Pods get IPs from separate overlay CIDR
  ✓ Best of both: VNet integration + scale
  ✓ No VNet IP exhaustion

For production: Azure CNI Overlay or Azure CNI with careful subnet planning
```

**Q: How do you expose an AKS service externally?**
```
Option 1: LoadBalancer Service
  type: LoadBalancer → Azure creates public load balancer
  Simple but: each service = one public IP

Option 2: Ingress Controller (recommended)
  Single public IP + NGINX / AGIC routes HTTP/S traffic
  Ingress rules define hostname/path routing
  TLS termination at ingress (not per service)

Option 3: AGIC (Application Gateway Ingress Controller)
  Integrates with Azure Application Gateway
  WAF capabilities, native Azure SLA
  USE: When you need WAF at ingress level

Option 4: Azure Front Door + Private Cluster
  No public IPs in AKS
  All traffic through Front Door → Private Link → AKS
  USE: Maximum security posture
```

**Q: How do you handle secrets in AKS?**
```
Best: Azure Key Vault + CSI Driver + Workload Identity
  Pods mount secrets as volumes from Key Vault
  No secrets in k8s etcd at all

Setup:
  1. Enable Key Vault provider in AKS (addon)
  2. Create SecretProviderClass pointing to Key Vault
  3. Mount in pod spec as volume
  4. Access as files or sync to k8s Secret

SecretProviderClass:
  apiVersion: secrets-store.csi.x-k8s.io/v1
  kind: SecretProviderClass
  metadata:
    name: order-secrets
  spec:
    provider: azure
    parameters:
      usePodIdentity: "false"
      clientID: "<managed-identity-client-id>"
      keyvaultName: "mykeyvault"
      tenantId: "<tenant-id>"
      objects: |
        array:
          - |
            objectName: ConnectionString
            objectType: secret
```

**Q: What is a Pod Disruption Budget?**
```
PDB guarantees a minimum number of pods remain available during
voluntary disruptions (node drain, AKS upgrade, scale-down).

apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: order-service-pdb
spec:
  minAvailable: 2          # WHY: never fewer than 2 pods
  selector:
    matchLabels:
      app: order-service

Without PDB: AKS upgrade could drain all pods simultaneously → downtime
With PDB: Upgrade respects PDB — drains one node at a time
```

---

# 14. Quick Reference — Decision Trees

## When to Use What — Quick Lookup

```
┌────────────────────────────────────────────────────────────────────┐
│              ARCHITECTURAL DECISION QUICK REFERENCE               │
│                                                                    │
│  Need global routing + CDN?          → Azure Front Door           │
│  Need regional L7 routing + WAF?     → Application Gateway        │
│  Need API gateway features?          → Azure APIM                 │
│  Need container orchestration?       → AKS                        │
│  Need simple containers, scale to 0? → Container Apps             │
│  Need event-driven functions?        → Azure Functions            │
│  Need reliable messaging + ordering? → Service Bus                │
│  Need high-throughput streaming?     → Event Hub                  │
│  Need Azure event reactions?         → Event Grid                 │
│  Need global NoSQL?                  → Cosmos DB                  │
│  Need relational ACID?               → Azure SQL                  │
│  Need caching / session?             → Azure Cache for Redis      │
│  Need blob/file storage?             → Azure Blob Storage         │
│  Need secret storage?                → Azure Key Vault            │
│  Need distributed tracing?           → OpenTelemetry + App Insights│
│  Need distributed transaction?       → Saga pattern               │
│  Need reliable event publishing?     → Outbox pattern             │
│  Need direct upload to storage?      → SAS URL (Blob)             │
│  Need zero-password DB access?       → Managed Identity           │
└────────────────────────────────────────────────────────────────────┘
```

---

## Architecture Decision Record (ADR) Template

```markdown
# ADR-001: Use gRPC for Internal Service Communication

## Status
Accepted

## Context
Internal microservices need to communicate for real-time queries.
Current REST calls have ~200ms overhead for internal calls.

## Decision
Use gRPC (Protocol Buffers + HTTP/2) for all internal synchronous communication.
Keep REST/JSON for external-facing APIs.

## Consequences
+ ~10x performance improvement for internal calls
+ Strongly typed contracts catch breaking changes at compile time
+ Bi-directional streaming available for real-time use cases
- Additional tooling for local debugging (grpcurl vs curl)
- Protocol Buffer schema requires all services to share .proto files
- Browser clients cannot call gRPC directly (need gRPC-Web or REST facade)
```

---

## Final Interview Mindset

```
┌──────────────────────────────────────────────────────────────────────┐
│              ARCHITECT INTERVIEW SUCCESS FORMULA                     │
│                                                                      │
│  1. Think out loud — narrate your reasoning                          │
│     "My first instinct is X, but the trade-off is Y, so I'd         │
│      actually prefer Z because..."                                   │
│                                                                      │
│  2. Start high-level, drill down on request                          │
│     "At high level: [diagram]. Should I go deeper on the data       │
│      layer or the API design?"                                       │
│                                                                      │
│  3. Always state trade-offs                                          │
│     Never say "X is always better than Y"                           │
│     Say "X is better for Z scenario, Y is better for W scenario"   │
│                                                                      │
│  4. Numbers matter                                                   │
│     "At 1000 RPS, Redis hits 100k RPS limit — not the bottleneck"  │
│     "Service Bus handles 10M/sec — not worried about throughput"    │
│                                                                      │
│  5. Production war stories                                           │
│     "We hit this in production when... the fix was..."              │
│                                                                      │
│  6. Ask clarifying questions                                         │
│     "What's the expected scale? Consistency requirements?            │
│      Team size? Budget constraints?"                                 │
└──────────────────────────────────────────────────────────────────────┘
```

---

*Guide created: 2026-03-16 | Profile: 12+ years .NET/Azure/Microservices | Role: Technical Architect*
