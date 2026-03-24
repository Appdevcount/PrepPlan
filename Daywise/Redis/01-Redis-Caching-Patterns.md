# Redis — Caching Patterns in .NET

> **Mental Model:** A cache is a speedometer buffer between your slow database and your fast API.
> Redis caching patterns decide WHO fills the cache, WHEN, and WHAT happens on a miss.

---

## Table of Contents
1. [Pattern 1: Cache-Aside (Lazy Loading)](#pattern-1-cache-aside-lazy-loading)
2. [Pattern 2: Write-Through](#pattern-2-write-through)
3. [Pattern 3: Write-Behind (Write-Back)](#pattern-3-write-behind-write-back)
4. [Pattern 4: Read-Through](#pattern-4-read-through)
5. [Pattern 5: Refresh-Ahead](#pattern-5-refresh-ahead)
6. [IDistributedCache — ASP.NET Core Integration](#idistributedcache--aspnet-core-integration)
7. [Output Caching in .NET 8+](#output-caching-in-net-8)
8. [Cache Stampede / Thundering Herd Prevention](#cache-stampede--thundering-herd-prevention)
9. [Cache Invalidation Strategies](#cache-invalidation-strategies)
10. [Serialization Best Practices](#serialization-best-practices)
11. [Monitoring Cache Effectiveness](#monitoring-cache-effectiveness)

---

## Pattern 1: Cache-Aside (Lazy Loading)

> **Mental Model:** The application does its own shopping. If the item isn't on the shelf (cache), go to the warehouse (DB) and stock the shelf yourself.

```
┌─────────────────────────────────────────────────────────────┐
│                  CACHE-ASIDE FLOW                           │
│                                                             │
│  App ──── GET key ────▶ Redis                              │
│            │                │                              │
│            │    MISS        │ HIT                          │
│            ▼                ▼                              │
│          DB Query         Return                           │
│            │             cached value                      │
│            ▼                                               │
│          SET key+TTL ──▶ Redis                             │
│            │                                               │
│            ▼                                               │
│          Return value                                      │
└─────────────────────────────────────────────────────────────┘
```

**Pros:** Only caches what's actually requested. Simple. DB is always source of truth.
**Cons:** Cold start = all misses. Race condition between multiple processes on miss.

**.NET Implementation:**
```csharp
// ── Cache-Aside Service ────────────────────────────────────────────
public class ProductCacheService
{
    private readonly IDatabase _redis;
    private readonly IProductRepository _db;
    private readonly ILogger<ProductCacheService> _logger;

    // WHY: Prefix all keys to namespace them — prevents collisions in shared Redis
    private const string KeyPrefix = "product:";
    private static readonly TimeSpan DefaultTtl = TimeSpan.FromMinutes(15);

    public ProductCacheService(
        IConnectionMultiplexer redis,
        IProductRepository db,
        ILogger<ProductCacheService> logger)
    {
        _redis = redis.GetDatabase();
        _db = db;
        _logger = logger;
    }

    public async Task<Product?> GetProductAsync(int productId, CancellationToken ct = default)
    {
        string key = $"{KeyPrefix}{productId}";

        // ── Step 1: Try cache ──────────────────────────────────────────
        var cached = await _redis.StringGetAsync(key);
        if (cached.HasValue)
        {
            _logger.LogDebug("Cache HIT for {Key}", key);
            return JsonSerializer.Deserialize<Product>(cached!);
        }

        // ── Step 2: Cache MISS — go to DB ──────────────────────────────
        _logger.LogDebug("Cache MISS for {Key}", key);
        var product = await _db.GetByIdAsync(productId, ct);

        if (product is null) return null;

        // ── Step 3: Populate cache ─────────────────────────────────────
        // WHY: Add small random jitter to TTL to prevent cache stampede
        // where many keys expire simultaneously and hammer the DB
        var jitter = TimeSpan.FromSeconds(Random.Shared.Next(0, 30));
        await _redis.StringSetAsync(key,
            JsonSerializer.Serialize(product),
            DefaultTtl + jitter);

        return product;
    }

    // ── Invalidation — call after write operations ─────────────────────
    public async Task InvalidateProductAsync(int productId)
    {
        string key = $"{KeyPrefix}{productId}";
        await _redis.KeyDeleteAsync(key);
        _logger.LogInformation("Cache invalidated for {Key}", key);
    }
}
```

---

## Pattern 2: Write-Through

> **Mental Model:** Always update the shelf (cache) AND the warehouse (DB) at the same time when you put something away. Shelf is never stale.

```
┌─────────────────────────────────────────────────────────────┐
│                 WRITE-THROUGH FLOW                          │
│                                                             │
│  App ──── UPDATE ──▶ Cache Service                         │
│                           │                                │
│                    ┌──────┴───────┐                        │
│                    ▼              ▼                         │
│                 Redis DB       SQL DB                      │
│                    │              │                         │
│                    └──────┬───────┘                        │
│                           ▼                                │
│                    Return success                          │
└─────────────────────────────────────────────────────────────┘
```

**Pros:** Cache always fresh. Reads are always cache hits (after first write).
**Cons:** Write latency = DB + Redis. Cache fills with data that may not be read.

**.NET Implementation:**
```csharp
public class WriteThroughProductService
{
    private readonly IDatabase _redis;
    private readonly IProductRepository _db;

    public async Task<Product> UpdateProductAsync(int id, UpdateProductDto dto, CancellationToken ct)
    {
        // ── Write to DB first ──────────────────────────────────────────
        // WHY: DB is source of truth — if DB write fails, cache stays consistent
        var product = await _db.UpdateAsync(id, dto, ct);

        // ── Immediately update cache ───────────────────────────────────
        string key = $"product:{id}";
        await _redis.StringSetAsync(key,
            JsonSerializer.Serialize(product),
            TimeSpan.FromMinutes(15));

        return product;
    }

    // ── Transaction: DB + Cache atomically using ITransaction ──────────
    // NOTE: Redis MULTI/EXEC doesn't span DB, but we can pipeline cache updates
    public async Task<Product> CreateProductAsync(CreateProductDto dto, CancellationToken ct)
    {
        var product = await _db.CreateAsync(dto, ct);

        // WHY: Use pipeline to batch multiple Redis writes without round-trip per command
        var batch = _redis.CreateBatch();
        var setTask = batch.StringSetAsync($"product:{product.Id}",
            JsonSerializer.Serialize(product), TimeSpan.FromMinutes(15));

        // Also invalidate any list caches
        var delTask = batch.KeyDeleteAsync("products:list:all");

        batch.Execute();
        await Task.WhenAll(setTask, delTask);

        return product;
    }
}
```

---

## Pattern 3: Write-Behind (Write-Back)

> **Mental Model:** Write to the shelf immediately (fast), queue a note to update the warehouse later (async). Risk: if the note is lost, warehouse is out of sync.

```
┌─────────────────────────────────────────────────────────────┐
│                 WRITE-BEHIND FLOW                           │
│                                                             │
│  App ──── WRITE ──▶ Redis (immediate return)               │
│                          │                                  │
│                    Queue write event                        │
│                          │                                  │
│                    Background worker                        │
│                          │                                  │
│                          ▼                                  │
│                       SQL DB (async, batched)              │
└─────────────────────────────────────────────────────────────┘
```

**Pros:** Extremely fast writes. Can batch DB writes for efficiency.
**Cons:** Risk of data loss. Complexity. Usually replaced by outbox pattern in enterprise.

**.NET Implementation:**
```csharp
// WHY: Use Redis List as a durable queue for pending DB writes
public class WriteBehindService
{
    private readonly IDatabase _redis;
    private const string WriteQueueKey = "queue:pending-writes";

    public async Task WriteAsync<T>(string cacheKey, T value, CancellationToken ct)
    {
        var json = JsonSerializer.Serialize(value);

        // ── Write to cache immediately (fast path) ─────────────────────
        await _redis.StringSetAsync(cacheKey, json, TimeSpan.FromHours(1));

        // ── Queue for async DB write ───────────────────────────────────
        var writeEvent = new PendingWrite
        {
            CacheKey = cacheKey,
            Payload = json,
            Timestamp = DateTime.UtcNow
        };
        await _redis.ListRightPushAsync(WriteQueueKey, JsonSerializer.Serialize(writeEvent));
    }
}

// Background worker that drains the queue and writes to DB
public class WriteBehindWorker : BackgroundService
{
    private readonly IDatabase _redis;
    private readonly IProductRepository _db;

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            // WHY: Process up to 100 writes per batch to reduce DB round trips
            var batch = new List<PendingWrite>();
            for (int i = 0; i < 100; i++)
            {
                var item = await _redis.ListLeftPopAsync(WriteQueueKey);
                if (!item.HasValue) break;
                batch.Add(JsonSerializer.Deserialize<PendingWrite>(item!)!);
            }

            if (batch.Count > 0)
                await _db.BulkUpsertAsync(batch, ct);

            await Task.Delay(TimeSpan.FromMilliseconds(500), ct); // process every 500ms
        }
    }
}
```

---

## Pattern 4: Read-Through

> **Mental Model:** Instead of you fetching from the warehouse, you hire a store clerk (cache library). The clerk auto-fetches on miss. You only talk to the clerk.

```csharp
// WHY: Read-through is Cache-Aside but abstracted into a generic helper
// so every caller doesn't have to implement the miss-then-load logic
public class RedisReadThroughCache
{
    private readonly IDatabase _redis;

    // Generic read-through: returns cached value OR calls loader and caches result
    public async Task<T?> GetOrSetAsync<T>(
        string key,
        Func<Task<T?>> loader,
        TimeSpan ttl,
        CancellationToken ct = default) where T : class
    {
        // ── Try cache first ────────────────────────────────────────────
        var cached = await _redis.StringGetAsync(key);
        if (cached.HasValue)
            return JsonSerializer.Deserialize<T>(cached!);

        // ── Cache miss: load from source ───────────────────────────────
        var value = await loader();
        if (value is null) return null;

        // ── Store in cache with TTL jitter ─────────────────────────────
        var jitter = TimeSpan.FromSeconds(Random.Shared.Next(-30, 30));
        await _redis.StringSetAsync(key, JsonSerializer.Serialize(value), ttl + jitter);

        return value;
    }
}

// Usage — clean call site, no cache logic in business code
public class ProductService
{
    private readonly RedisReadThroughCache _cache;
    private readonly IProductRepository _db;

    public async Task<Product?> GetProductAsync(int id, CancellationToken ct)
        => await _cache.GetOrSetAsync(
            key: $"product:{id}",
            loader: () => _db.GetByIdAsync(id, ct),
            ttl: TimeSpan.FromMinutes(15),
            ct: ct);
}
```

---

## Pattern 5: Refresh-Ahead

> **Mental Model:** Before the milk expires, proactively buy fresh milk. Cache refreshes itself before TTL hits, so users never see a miss.

```csharp
// WHY: Refresh-ahead prevents the latency spike users see on cache miss
// by warming the cache BEFORE it expires (at ~80% of TTL)
public class RefreshAheadCache
{
    private readonly IDatabase _redis;

    public async Task<T?> GetWithRefreshAsync<T>(
        string key,
        Func<Task<T?>> loader,
        TimeSpan ttl) where T : class
    {
        var cached = await _redis.StringGetAsync(key);
        var remaining = await _redis.KeyTimeToLiveAsync(key);

        if (cached.HasValue)
        {
            // WHY: If less than 20% of TTL remains, trigger background refresh
            // so the NEXT user gets fresh data without waiting
            bool shouldRefresh = remaining.HasValue && remaining.Value < ttl * 0.2;

            if (shouldRefresh)
            {
                // Fire-and-forget background refresh
                _ = Task.Run(async () =>
                {
                    var fresh = await loader();
                    if (fresh is not null)
                        await _redis.StringSetAsync(key, JsonSerializer.Serialize(fresh), ttl);
                });
            }

            return JsonSerializer.Deserialize<T>(cached!);
        }

        // Cold miss — load synchronously
        var value = await loader();
        if (value is not null)
            await _redis.StringSetAsync(key, JsonSerializer.Serialize(value), ttl);

        return value;
    }
}
```

---

## IDistributedCache — ASP.NET Core Integration

```csharp
// WHY: IDistributedCache is the ASP.NET Core abstraction for distributed cache
// Allows swapping Redis with NCache, SQL, or In-Memory without changing business code

// ── Registration ─────────────────────────────────────────────────────
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = "localhost:6379";
    options.InstanceName = "MyApp:"; // WHY: auto-prefix all keys
});

// ── Usage ─────────────────────────────────────────────────────────────
public class UserService
{
    private readonly IDistributedCache _cache;
    private readonly IUserRepository _db;

    public async Task<UserDto?> GetUserAsync(int userId, CancellationToken ct)
    {
        string key = $"user:{userId}";

        // Try cache
        var bytes = await _cache.GetAsync(key, ct);
        if (bytes is not null)
            return JsonSerializer.Deserialize<UserDto>(bytes);

        // Miss — load from DB
        var user = await _db.GetByIdAsync(userId, ct);
        if (user is null) return null;

        // Cache result
        var options = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30),
            // WHY: SlidingExpiration resets TTL on each access — good for session data
            // Don't use both absolute + sliding for the same key (absolute takes precedence)
        };
        await _cache.SetAsync(key, JsonSerializer.SerializeToUtf8Bytes(user), options, ct);

        return user;
    }

    public async Task InvalidateAsync(int userId, CancellationToken ct)
        => await _cache.RemoveAsync($"user:{userId}", ct);
}
```

---

## Output Caching in .NET 8+

```csharp
// WHY: Output caching caches entire HTTP responses, not just data
// Redis-backed output cache survives app restarts and works across multiple instances

// ── Registration ─────────────────────────────────────────────────────
builder.Services.AddOutputCache(options =>
{
    options.AddBasePolicy(builder => builder.Cache());

    // Named policy for specific endpoints
    options.AddPolicy("Products", builder =>
        builder
            .Cache()
            .Expire(TimeSpan.FromMinutes(5))
            .Tag("products") // WHY: Tag enables group invalidation
            .SetVaryByQuery("category", "page")); // WHY: Vary cache by query params
});

// WHY: Use Redis store so cache is shared across all pods in AKS
builder.Services.AddStackExchangeRedisOutputCache(options =>
    options.Configuration = "localhost:6379");

app.UseOutputCache();

// ── Endpoint with output cache ────────────────────────────────────────
app.MapGet("/products", async (IProductService svc) =>
{
    var products = await svc.GetAllAsync();
    return Results.Ok(products);
})
.CacheOutput("Products");

// ── Invalidate output cache by tag ────────────────────────────────────
app.MapPost("/products", async (CreateProductDto dto,
    IProductService svc,
    IOutputCacheStore cache,
    CancellationToken ct) =>
{
    var product = await svc.CreateAsync(dto, ct);

    // WHY: Evict all cache entries tagged "products" after a product is created
    await cache.EvictByTagAsync("products", ct);

    return Results.Created($"/products/{product.Id}", product);
});
```

---

## Cache Stampede / Thundering Herd Prevention

> **Problem:** 10,000 concurrent requests, cache expires — all 10,000 go to the DB simultaneously.

```
┌───────────────────────────────────────────────────────────────┐
│              THUNDERING HERD PROBLEM                          │
│                                                               │
│  T=0: Cache expires                                           │
│  T=1: 10,000 requests hit ──▶ 10,000 DB queries  ← PROBLEM  │
│                                                               │
│              SOLUTIONS                                        │
│  1. Probabilistic early refresh (JitterExpiry)                │
│  2. Redis lock (only ONE request rebuilds cache)              │
│  3. Background refresh before expiry (Refresh-Ahead)         │
└───────────────────────────────────────────────────────────────┘
```

```csharp
// Solution: Mutex Lock Pattern — only one process loads from DB
public class StampedeProtectedCache
{
    private readonly IDatabase _redis;

    public async Task<T?> GetOrSetWithLockAsync<T>(
        string key,
        Func<Task<T?>> loader,
        TimeSpan ttl) where T : class
    {
        // Fast path — try cache first (no lock needed)
        var cached = await _redis.StringGetAsync(key);
        if (cached.HasValue)
            return JsonSerializer.Deserialize<T>(cached!);

        // ── Acquire distributed lock ───────────────────────────────────
        string lockKey = $"lock:{key}";
        string lockToken = Guid.NewGuid().ToString(); // WHY: unique token prevents accidental unlock
        bool acquired = await _redis.StringSetAsync(lockKey, lockToken,
            TimeSpan.FromSeconds(30), When.NotExists);

        if (acquired)
        {
            try
            {
                // Double-check: another process may have loaded while we waited
                cached = await _redis.StringGetAsync(key);
                if (cached.HasValue)
                    return JsonSerializer.Deserialize<T>(cached!);

                // We hold the lock — load from DB
                var value = await loader();
                if (value is not null)
                    await _redis.StringSetAsync(key, JsonSerializer.Serialize(value), ttl);

                return value;
            }
            finally
            {
                // WHY: LUA script ensures we only delete OUR lock token, not someone else's
                const string deleteLockScript = @"
                    if redis.call('GET', KEYS[1]) == ARGV[1] then
                        return redis.call('DEL', KEYS[1])
                    else
                        return 0
                    end";
                await _redis.ScriptEvaluateAsync(deleteLockScript,
                    new RedisKey[] { lockKey },
                    new RedisValue[] { lockToken });
            }
        }
        else
        {
            // WHY: Another process holds the lock and is loading the data
            // Spin-wait briefly (poll) instead of hammering the DB
            for (int i = 0; i < 10; i++)
            {
                await Task.Delay(100);
                cached = await _redis.StringGetAsync(key);
                if (cached.HasValue)
                    return JsonSerializer.Deserialize<T>(cached!);
            }

            // Fallback: load directly if lock holder failed
            return await loader();
        }
    }
}
```

---

## Cache Invalidation Strategies

```
┌────────────────────┬─────────────────────────────────────────┐
│ Strategy           │ When to use                             │
├────────────────────┼─────────────────────────────────────────┤
│ TTL expiry         │ Data freshness acceptable to be stale   │
│ On-write delete    │ Cache-aside — delete on every update    │
│ Tag-based eviction │ Group invalidation (output cache)       │
│ Event-driven       │ Pub/Sub: DB triggers cache invalidation │
│ Version key        │ Embed version in key (user:1:v3)        │
│ Write-through      │ Update both DB and cache on every write │
└────────────────────┴─────────────────────────────────────────┘
```

```csharp
// Event-driven invalidation using Redis Pub/Sub
// WHY: Broadcast invalidation across all app instances in a cluster

// Publisher (called after DB update)
public class CacheInvalidationPublisher
{
    private readonly ISubscriber _subscriber;
    private const string Channel = "cache:invalidation";

    public async Task PublishInvalidationAsync(string cacheKey)
        => await _subscriber.PublishAsync(
            RedisChannel.Literal(Channel),
            cacheKey);
}

// Subscriber (each app instance subscribes on startup)
public class CacheInvalidationSubscriber : IHostedService
{
    private readonly ISubscriber _subscriber;
    private readonly IMemoryCache _localCache; // WHY: also invalidate local in-memory cache

    public async Task StartAsync(CancellationToken ct)
    {
        await _subscriber.SubscribeAsync(
            RedisChannel.Literal("cache:invalidation"),
            (channel, key) =>
            {
                _localCache.Remove(key.ToString());
            });
    }

    public async Task StopAsync(CancellationToken ct)
        => await _subscriber.UnsubscribeAllAsync();
}
```

---

## Serialization Best Practices

```csharp
// ── Recommended: System.Text.Json with source generator ───────────────
// WHY: Source generator avoids reflection overhead in hot paths
[JsonSerializable(typeof(Product))]
[JsonSerializable(typeof(UserDto))]
[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
public partial class AppJsonContext : JsonSerializerContext { }

// Serialize
byte[] bytes = JsonSerializer.SerializeToUtf8Bytes(product, AppJsonContext.Default.Product);
await db.StringSetAsync(key, bytes);

// Deserialize
var cached = await db.StringGetAsync(key);
var product = JsonSerializer.Deserialize(cached!, AppJsonContext.Default.Product);

// ── MessagePack for maximum performance ───────────────────────────────
// WHY: MessagePack is ~3x faster than JSON and ~40% smaller payload
// Use for high-throughput scenarios (>100K cache reads/sec)
// NuGet: MessagePack
[MessagePackObject]
public record Product(
    [property: Key(0)] int Id,
    [property: Key(1)] string Name,
    [property: Key(2)] decimal Price);

var bytes = MessagePackSerializer.Serialize(product);
await db.StringSetAsync(key, bytes);
var cached = await db.StringGetAsync(key);
var product = MessagePackSerializer.Deserialize<Product>(cached!);
```

---

## Monitoring Cache Effectiveness

```csharp
// WHY: Track hit rate to know if cache is actually helping
// A hit rate < 70% suggests cache keys or TTLs need tuning
public class CacheMetricsDecorator : IProductService
{
    private readonly IProductService _inner;
    private readonly IDatabase _redis;
    private readonly ILogger _logger;

    public async Task<Product?> GetProductAsync(int id, CancellationToken ct)
    {
        string key = $"product:{id}";
        bool isHit = (await _redis.KeyExistsAsync(key));

        // WHY: Increment counters in Redis to get cluster-wide stats
        if (isHit)
            await _redis.StringIncrementAsync("metrics:cache:hits");
        else
            await _redis.StringIncrementAsync("metrics:cache:misses");

        return await _inner.GetProductAsync(id, ct);
    }
}

// Query hit rate
var hits = (long)await db.StringGetAsync("metrics:cache:hits");
var misses = (long)await db.StringGetAsync("metrics:cache:misses");
double hitRate = (double)hits / (hits + misses) * 100;
Console.WriteLine($"Cache hit rate: {hitRate:F1}%");
```

```bash
# Redis CLI: built-in hit/miss stats
redis-cli INFO stats | grep -E "keyspace_hits|keyspace_misses|expired_keys|evicted_keys"

# Monitor in real time
redis-cli --latency
redis-cli MONITOR  # WARNING: performance impact, use in dev only
```

---

## Pattern Comparison Summary

```
┌───────────────────┬──────────┬──────────┬────────────┬────────────────┐
│ Pattern           │ Read     │ Write    │ Staleness  │ Complexity     │
│                   │ Perf     │ Perf     │ Risk       │                │
├───────────────────┼──────────┼──────────┼────────────┼────────────────┤
│ Cache-Aside       │ Fast     │ Normal   │ Medium     │ Low            │
│ Write-Through     │ Fast     │ Slower   │ Low        │ Medium         │
│ Write-Behind      │ Fast     │ Fastest  │ High       │ High           │
│ Read-Through      │ Fast     │ Normal   │ Medium     │ Medium         │
│ Refresh-Ahead     │ Fastest  │ Normal   │ Very Low   │ High           │
└───────────────────┴──────────┴──────────┴────────────┴────────────────┘

Recommendation:
  Default: Cache-Aside + TTL jitter (80% of use cases)
  High read throughput: Read-Through with stampede protection
  High write throughput: Write-Behind (with outbox for safety)
  API responses: Output caching with tag-based invalidation
```

---

*Next:* [02-Redis-Session-Distributed-State.md](02-Redis-Session-Distributed-State.md) — ASP.NET Core session, distributed state, sticky vs stateless
