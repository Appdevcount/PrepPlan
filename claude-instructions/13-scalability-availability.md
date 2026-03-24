# 13 — Scalability & Availability

> **Mental Model:** Scalability is adding more trucks when demand grows.
> Availability is ensuring the road is never fully blocked — even when a truck breaks down.
> They are related but distinct. You can have a highly available system that doesn't scale,
> and a scalable system with poor availability during scaling events.

---

## Scalability Dimensions

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  HORIZONTAL SCALING (scale out)      │  VERTICAL SCALING (scale up)          │
│  Add more instances                  │  Bigger machine                       │
│  ✅ Unlimited theoretically          │  ❌ Hardware ceiling                  │
│  ✅ No downtime to scale             │  ❌ Usually requires restart           │
│  ✅ Fault tolerant (1 instance fails)│  ✅ Simpler (single instance)         │
│  ❌ Requires stateless design        │  ❌ Single point of failure            │
│                                      │                                       │
│  Use for: API pods, workers, caches  │  Use for: DB primaries, legacy apps   │
└──────────────────────────────────────────────────────────────────────────────┘

RULE: Design every service as if it will have 100 instances.
      If it can't, document why and plan the migration.
```

---

## Stateless Service Design

```csharp
// ── RULE: API instances must be stateless — any request can go to any pod ─────
// State lives in: Redis (sessions/cache), DB (data), Service Bus (work queue)
// State NEVER lives in: static fields, in-memory collections, instance fields

// ❌ WRONG — in-memory state breaks horizontal scaling
public class OrderService
{
    // This list is per-process — Pod 1 has different data than Pod 2
    private static readonly List<Order> _pendingOrders = new();

    public void Queue(Order order) => _pendingOrders.Add(order);
    // If user calls Queue() on Pod 1 and checks status on Pod 2 → empty!
}

// ✅ CORRECT — state in Redis (shared across all pods)
public class OrderService(IConnectionMultiplexer redis)
{
    private readonly IDatabase _db = redis.GetDatabase();

    public async Task QueueAsync(Order order, CancellationToken ct)
    {
        // WHY Redis list: atomic, survives pod restart, visible to all pods
        await _db.ListRightPushAsync("pending-orders", JsonSerializer.Serialize(order));
    }
}

// ── Session state → Redis ─────────────────────────────────────────────────────
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration["Redis:ConnectionString"];
    // WHY Redis not in-memory: in-memory session is per-pod.
    //   User logs in on Pod 1 → next request routes to Pod 2 → session gone → logged out.
    options.InstanceName = "orders-session:";
});

builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(20);
    options.Cookie.HttpOnly = true;   // WHY: prevents JS access to session cookie (XSS)
    options.Cookie.IsEssential = true;
});
```

---

## Caching Strategy

```csharp
// ── Cache-Aside Pattern — most common, most flexible ─────────────────────────
// Mental model: check your pocket for cash before going to the ATM.
// Read: try cache → miss → read DB → write to cache → return
// Write: write to DB → invalidate cache (don't write cache — consistency risk)

public class ProductService(IDistributedCache cache, IProductRepository repo)
{
    private static string CacheKey(Guid id) => $"product:{id}";

    public async Task<Product?> GetByIdAsync(Guid id, CancellationToken ct)
    {
        // 1. Try cache first
        var cached = await cache.GetStringAsync(CacheKey(id), ct);
        if (cached is not null)
            return JsonSerializer.Deserialize<Product>(cached);

        // 2. Cache miss — read from DB
        var product = await repo.GetByIdAsync(id, ct);
        if (product is null) return null;

        // 3. Write to cache with TTL
        // WHY 5min TTL: product data changes infrequently — serve stale for 5min is acceptable.
        //   Shorter TTL = more DB hits. Longer = more stale data.
        await cache.SetStringAsync(
            CacheKey(id),
            JsonSerializer.Serialize(product),
            new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5) },
            ct);

        return product;
    }

    public async Task UpdateAsync(Product product, CancellationToken ct)
    {
        await repo.UpdateAsync(product, ct);

        // WHY invalidate not update: race condition if you update cache AND DB.
        //   Cache invalidation forces next read to get fresh data from DB.
        await cache.RemoveAsync(CacheKey(product.Id), ct);
    }
}

// ── Cache Levels Decision ─────────────────────────────────────────────────────
/*
┌────────────────┬──────────────────┬────────────────────────────────────────┐
│ Level          │ Location         │ Use for                                │
├────────────────┼──────────────────┼────────────────────────────────────────┤
│ L1: In-memory  │ IMemoryCache     │ Tiny, rarely changing (config, enums)  │
│                │ per-pod          │ Loses data on pod restart — OK for refs │
├────────────────┼──────────────────┼────────────────────────────────────────┤
│ L2: Redis      │ IDistributedCache│ Session, user data, product catalog    │
│                │ shared all pods  │ Survives pod restart, shared across pods│
├────────────────┼──────────────────┼────────────────────────────────────────┤
│ L3: CDN        │ Azure Front Door │ Static assets, API responses (GET only)│
│                │ global edge      │ Offloads origin completely for GETs    │
└────────────────┴──────────────────┴────────────────────────────────────────┘
*/
```

---

## Database Scaling Patterns

```csharp
// ── Read Replicas — separate read and write traffic ──────────────────────────
// WHY read replicas: writes go to primary (serialized), reads go to replicas (parallel).
//   Query-heavy workloads: 90% reads, 10% writes — replicas handle 90% of traffic.

public class OrderDbContext(DbContextOptions<OrderDbContext> options) : DbContext(options) {}

// Register two contexts — write uses primary, read uses replica
builder.Services.AddDbContext<OrderDbContext>(opts =>
    opts.UseSqlServer(config["Database:Primary"]));   // write operations

builder.Services.AddDbContext<OrderReadDbContext>(opts =>
    opts.UseSqlServer(config["Database:ReadReplica"])
        .UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking));
        // WHY NoTracking on read context: read replica is read-only — tracking wastes memory

// ── Connection Pool Tuning ────────────────────────────────────────────────────
// WHY pool tuning: default pool size may be too low for high-concurrency APIs.
//   Too few connections = requests queue waiting for available connection.
//   Too many = DB runs out of connections (SQL Server default max: 32767).
builder.Services.AddDbContext<OrderDbContext>(opts =>
    opts.UseSqlServer(config["Database:Primary"],
        sqlOptions => sqlOptions
            .CommandTimeout(30)
            .EnableRetryOnFailure(3, TimeSpan.FromSeconds(5), null)));

// In connection string:
// "Max Pool Size=200;Min Pool Size=5;Connection Timeout=15"
// WHY Max 200: each AKS pod gets up to 200 connections.
//   With 10 pods: 2000 max connections to DB — set DB max accordingly.

// ── Cosmos DB Partition Strategy ─────────────────────────────────────────────
/*
Choosing a partition key:
  ✅ High cardinality (many unique values): tenantId, userId, orderId
  ✅ Evenly distributed writes: avoid "hot" partitions (e.g., status='pending')
  ✅ Frequently queried together: queries within a partition are fast + cheap
  ✅ Immutable: never change a partition key after creation

  ❌ Low cardinality (country, status) — too few partitions, hot partition
  ❌ Auto-increment IDs — writes always go to the "latest" partition

  Rule: if you always query by X, X is likely a good partition key.
*/
```

---

## Message Queue — Async Offloading

```csharp
// WHY async offloading: slow operations (email, PDF generation, inventory sync)
//   shouldn't block the HTTP response. Enqueue and return 202 Accepted.
//   Worker processes the job independently — API stays fast.

// ── Endpoint — accept work, enqueue, return immediately ─────────────────────
app.MapPost("/orders/{id}/invoice", async (
    Guid id,
    IServiceBusSender sender,
    CancellationToken ct) =>
{
    await sender.SendAsync(new GenerateInvoiceMessage(id), ct);

    // WHY 202 Accepted not 200/201: work was accepted but NOT yet complete.
    //   Client should poll /orders/{id}/invoice/status for completion.
    return Results.Accepted($"/orders/{id}/invoice/status");
});

// ── KEDA — scale workers based on queue depth ────────────────────────────────
// WHY KEDA: HPA scales on CPU/memory. KEDA scales on BUSINESS metrics (queue depth).
//   0 messages = 0 worker pods (scale to zero — save cost).
//   1000 messages = 10 worker pods (scale out fast).
/*
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: invoice-worker-scaler
spec:
  scaleTargetRef:
    name: invoice-worker
  minReplicaCount: 0          # WHY 0: scale to zero when queue empty (cost saving)
  maxReplicaCount: 20
  triggers:
    - type: azure-servicebus
      metadata:
        queueName: invoice-generation
        messageCount: "5"     # WHY 5: spin up 1 pod per 5 messages in queue
        connectionFromEnv: SERVICEBUS_CONNECTION
*/
```

---

## Availability Patterns

```csharp
// ── Multi-region Active-Active ────────────────────────────────────────────────
/*
                    ┌──────────────────────────────────┐
                    │        Azure Front Door           │
                    │  (global load balancer + CDN)     │
                    └──────┬───────────────────┬────────┘
                           │                   │
               ┌───────────▼──┐         ┌──────▼──────────┐
               │  East US     │         │   West Europe    │
               │  AKS Cluster │         │   AKS Cluster    │
               │  + SQL Prim  │◄───────►│   + SQL Prim     │
               └──────────────┘  geo-   └─────────────────-┘
                                 replication

WHY Front Door not Traffic Manager:
  Front Door: L7 (HTTP), path-based routing, WAF, caching, health probes every 30s.
  Traffic Manager: L4 (DNS), slower failover (TTL based), no WAF.
*/

// ── Health Probe — Front Door needs this ─────────────────────────────────────
app.MapGet("/health/ready", async (
    AppDbContext db,
    IConnectionMultiplexer redis,
    CancellationToken ct) =>
{
    // WHY check ALL dependencies: if DB is down, this pod can't serve traffic.
    //   Front Door will route to the other region instead.
    var dbOk    = await db.Database.CanConnectAsync(ct);
    var redisOk = redis.IsConnected;

    if (!dbOk || !redisOk)
    {
        return Results.Problem(
            detail: $"DB: {dbOk}, Redis: {redisOk}",
            statusCode: 503);   // 503 → Front Door stops routing to this instance
    }

    return Results.Ok(new { status = "healthy", region = Environment.MachineName });
});

// ── Graceful degradation — serve reduced functionality when dependency fails ──
public class DashboardService(
    IOrderService orders,
    IAnalyticsService analytics,
    ILogger<DashboardService> logger)
{
    public async Task<DashboardViewModel> GetDashboardAsync(CancellationToken ct)
    {
        // Orders are critical — if this fails, throw (show error page)
        var recentOrders = await orders.GetRecentAsync(ct);

        // Analytics is non-critical — degrade gracefully
        IReadOnlyList<ChartPoint>? salesChart = null;
        try
        {
            salesChart = await analytics.GetSalesChartAsync(ct);
        }
        catch (Exception ex)
        {
            // WHY log warning not error: analytics failure is expected during maintenance
            logger.LogWarning(ex, "Analytics unavailable — dashboard will show without chart");
        }

        return new DashboardViewModel(recentOrders, salesChart);
        // WHY null salesChart OK: template shows "Analytics unavailable" placeholder
    }
}
```

---

## SLA / SLO Targets Reference

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Availability   │ Downtime/year  │ Downtime/month │ Architecture needed       │
├──────────────────────────────────────────────────────────────────────────────┤
│  99.0%  (2 9s)  │ 87.6 hours     │ 7.3 hours      │ Single region, no HA      │
│  99.9%  (3 9s)  │ 8.7 hours      │ 43.8 minutes   │ AKS multi-node, zone-spread│
│  99.95%         │ 4.4 hours      │ 21.9 minutes   │ Multi-AZ + health probes  │
│  99.99% (4 9s)  │ 52.6 minutes   │ 4.4 minutes    │ Multi-region active-active│
│  99.999% (5 9s) │ 5.3 minutes    │ 26 seconds     │ Multi-region + chaos eng. │
└──────────────────────────────────────────────────────────────────────────────┘

RULE: Each dependency reduces your SLA.
  Your SLA ≤ MIN(dependency SLAs) if dependencies are in series.
  Azure SQL SLA: 99.99%
  Azure Service Bus SLA: 99.9%
  Your composite SLA: ≤ 99.9% (limited by Service Bus)

Design for your SLO, not your SLA — SLO is what you actually achieve,
SLA is what you're contractually obligated to. Aim for SLO > SLA by 0.5-1%.
```
