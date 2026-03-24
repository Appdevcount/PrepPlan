# Redis — Advanced Patterns in .NET

> **Mental Model:** Advanced Redis is about making multiple operations feel like one.
> Pipelines = one delivery truck for many packages. Lua scripts = one chef doing multiple steps atomically.
> Transactions = a promise to either do all or nothing.

---

## Table of Contents
1. [Pipelining — Batch Commands](#pipelining--batch-commands)
2. [Transactions — MULTI/EXEC](#transactions--multiexec)
3. [Optimistic Locking with WATCH](#optimistic-locking-with-watch)
4. [Lua Scripting — Atomic Custom Operations](#lua-scripting--atomic-custom-operations)
5. [Bloom Filter Pattern](#bloom-filter-pattern)
6. [Two-Level Cache (L1 + L2)](#two-level-cache-l1--l2)
7. [Redis Search (Full-Text)](#redis-search-full-text)
8. [Connection Pooling & Multiplexer Patterns](#connection-pooling--multiplexer-patterns)
9. [Redis Cluster — Sharding & Multi-Key Operations](#redis-cluster--sharding--multi-key-operations)
10. [Sentinel — High Availability](#sentinel--high-availability)
11. [Azure Cache for Redis — Managed Setup](#azure-cache-for-redis--managed-setup)
12. [Performance Tuning Checklist](#performance-tuning-checklist)

---

## Pipelining — Batch Commands

> **Mental Model:** Instead of mailing 10 letters one by one (10 round trips), put them all in one envelope (1 round trip). Results come back together.

```csharp
// WHY: Each Redis command normally = 1 network round trip (~0.5ms on LAN)
// Pipeline batches N commands into 1 round trip → ~N× speedup for independent commands

// ── Method 1: IBatch (fire-and-forget batching) ────────────────────────
public async Task RecordMultipleEventsAsync(IEnumerable<UserEvent> events)
{
    var batch = _db.CreateBatch();

    // Queue all commands — none execute until batch.Execute()
    var tasks = events.Select(evt => batch.StringIncrementAsync($"events:{evt.Type}:{evt.Date}"))
        .ToList();

    batch.Execute(); // Sends all commands in one round trip

    // WHY: Await tasks AFTER Execute() — results are now available
    await Task.WhenAll(tasks);
}

// ── Method 2: Explicit pipeline for mixed operations ───────────────────
public async Task<UserDashboard> GetUserDashboardAsync(int userId)
{
    // WHY: Without pipeline, this would be 5 separate round trips
    var batch = _db.CreateBatch();

    var profileTask = batch.StringGetAsync($"user:{userId}:profile");
    var cartTask = batch.HashGetAllAsync($"cart:{userId}");
    var notifCountTask = batch.ListLengthAsync($"notifications:{userId}");
    var scoreTask = batch.SortedSetScoreAsync("leaderboard:global", userId.ToString());
    var sessionTask = batch.KeyExistsAsync($"session:{userId}");

    batch.Execute(); // 1 network round trip for all 5 commands

    return new UserDashboard(
        Profile: JsonSerializer.Deserialize<UserProfile>(await profileTask ?? "{}"),
        CartItemCount: (await cartTask).Length,
        NotificationCount: await notifCountTask,
        LeaderboardScore: await scoreTask,
        IsOnline: await sessionTask);
}

// ── Method 3: Script bulk operations ──────────────────────────────────
public async Task BulkSetWithTtlAsync(Dictionary<string, string> keyValues, TimeSpan ttl)
{
    var batch = _db.CreateBatch();
    var tasks = keyValues.Select(kv =>
        batch.StringSetAsync(kv.Key, kv.Value, ttl)).ToList();
    batch.Execute();
    await Task.WhenAll(tasks);
}
```

---

## Transactions — MULTI/EXEC

> **Mental Model:** MULTI/EXEC is like a to-do list you hand the waiter all at once.
> Either all orders execute together, or none do (if DISCARD is called).
> Unlike SQL transactions — no rollback on partial failure.

```csharp
// WHY: Redis transactions queue commands and execute atomically — no other client
// can interleave commands between MULTI and EXEC

public async Task<bool> TransferCreditsAsync(
    string fromUser, string toUser, long amount)
{
    string fromKey = $"credits:{fromUser}";
    string toKey = $"credits:{toUser}";

    var trans = _db.CreateTransaction();

    // Queue commands (executed atomically on Execute())
    // WHY: These return Task immediately — results available after Execute()
    var fromTask = trans.StringDecrementAsync(fromKey, amount);
    var toTask = trans.StringIncrementAsync(toKey, amount);

    // Execute atomically — sends MULTI + commands + EXEC
    bool committed = await trans.ExecuteAsync();

    if (!committed) return false;

    var fromBalance = await fromTask;
    var toBalance = await toTask;

    // NOTE: Redis doesn't rollback on error — validate before debit in practice
    // For credit transfer, use Lua script for true atomic conditional operation
    return true;
}

// ── Better: Conditional transaction with WATCH ─────────────────────────
// See: Optimistic Locking section below
```

---

## Optimistic Locking with WATCH

> **Mental Model:** WATCH is a tripwire. If the watched key changes before EXEC fires,
> the transaction is abandoned (returns null). Then retry from scratch.

```csharp
// WHY: WATCH + MULTI/EXEC = optimistic concurrency within Redis
// Lower overhead than distributed lock for low-contention scenarios
public async Task<bool> UpdateIfUnchangedAsync(
    string key, string expectedValue, string newValue)
{
    const int maxRetries = 3;

    for (int attempt = 0; attempt < maxRetries; attempt++)
    {
        // WHY: Multiplexer.GetDatabase() for WATCH requires same connection context
        // Use CreateTransaction which handles WATCH internally
        var trans = _db.CreateTransaction();

        // WHY: AddCondition = WATCH + check — if key changes between now and EXEC, abort
        trans.AddCondition(Condition.StringEqual(key, expectedValue));

        var setTask = trans.StringSetAsync(key, newValue);

        bool committed = await trans.ExecuteAsync();
        if (committed) return true;

        // Watch fired — another process changed the value, retry
        if (attempt < maxRetries - 1)
            await Task.Delay(TimeSpan.FromMilliseconds(50 * (attempt + 1)));
    }

    return false; // Could not update within retry budget
}

// ── Available Conditions ───────────────────────────────────────────────
// Condition.StringEqual(key, value)    → WATCH + GET check
// Condition.StringNotEqual(key, value)
// Condition.KeyExists(key)
// Condition.KeyNotExists(key)
// Condition.HashEqual(key, field, value)
// Condition.SortedSetEqual(key, member, score)
// Condition.ListIndexEqual(key, index, value)
```

---

## Lua Scripting — Atomic Custom Operations

> **Mental Model:** Lua script is a stored procedure for Redis.
> Redis executes the entire script without interruption — maximum atomicity.

```csharp
// ── Pre-load scripts for reuse ─────────────────────────────────────────
// WHY: SCRIPT LOAD caches script on Redis side, call via SHA1 — faster than sending script text
public class LuaScriptCache
{
    private readonly IServer _server;
    private readonly Dictionary<string, LoadedLuaScript> _cache = new();

    public async Task<LoadedLuaScript> LoadAsync(string scriptText)
    {
        if (!_cache.TryGetValue(scriptText, out var loaded))
        {
            var script = LuaScript.Prepare(scriptText);
            loaded = await script.LoadAsync(_server);
            _cache[scriptText] = loaded;
        }
        return loaded;
    }

    public async Task<RedisResult> RunAsync(string scriptText, object? parameters = null)
    {
        var loaded = await LoadAsync(scriptText);
        return await loaded.EvaluateAsync(_db, parameters);
    }
}

// ── Example: Atomic get-or-set with expiry ─────────────────────────────
public async Task<string?> GetOrSetAtomicAsync(
    string key, string value, TimeSpan ttl)
{
    // WHY: Atomically set if not exists AND get current value in one step
    const string script = @"
        local val = redis.call('GET', KEYS[1])
        if val then
            return val
        else
            redis.call('SET', KEYS[1], ARGV[1], 'PX', ARGV[2])
            return ARGV[1]
        end";

    var result = await _db.ScriptEvaluateAsync(script,
        new RedisKey[] { key },
        new RedisValue[] { value, (long)ttl.TotalMilliseconds });

    return result.ToString();
}

// ── Example: Atomic counter with max limit ─────────────────────────────
// WHY: Prevents counter exceeding max without locking
public async Task<(bool Success, long CurrentCount)> IncrementIfBelowAsync(
    string key, long max, TimeSpan ttl)
{
    const string script = @"
        local count = redis.call('GET', KEYS[1])
        count = tonumber(count or 0)
        if count >= tonumber(ARGV[1]) then
            return {0, count}
        end
        local new_count = redis.call('INCR', KEYS[1])
        if new_count == 1 then
            redis.call('PEXPIRE', KEYS[1], ARGV[2])
        end
        return {1, new_count}";

    var result = (RedisResult[])await _db.ScriptEvaluateAsync(script,
        new RedisKey[] { key },
        new RedisValue[] { max, (long)ttl.TotalMilliseconds });

    return ((long)result[0] == 1, (long)result[1]);
}

// ── Example: Multi-key atomic transfer ─────────────────────────────────
public async Task<bool> AtomicTransferAsync(
    string sourceKey, string destKey, string value)
{
    const string script = @"
        if redis.call('SISMEMBER', KEYS[1], ARGV[1]) == 0 then
            return 0  -- not in source
        end
        redis.call('SREM', KEYS[1], ARGV[1])
        redis.call('SADD', KEYS[2], ARGV[1])
        return 1";

    var result = await _db.ScriptEvaluateAsync(script,
        new RedisKey[] { sourceKey, destKey },
        new RedisValue[] { value });

    return (long)result == 1;
}
```

---

## Bloom Filter Pattern

> **Mental Model:** A bloom filter is a security checkpoint that never has false negatives
> but can have false positives. "Definitely NOT in set" is always correct.
> "Maybe in set" might be wrong (~1% false positive rate).

```csharp
// WHY: Bloom filter uses O(m) space regardless of number of elements
// Perfect for "have I seen this before?" checks without storing all items
// Use case: deduplication, URL seen check, spam detection

// Redis 4.0+ includes RedisBloom module — Azure Cache for Redis Enterprise supports it
// Without module: implement with Bitmap

public class BitMapBloomFilter
{
    private readonly IDatabase _db;
    private readonly string _key;
    private readonly int _hashFunctions; // Number of hash functions
    private readonly int _bitSetSize;    // Total bits in the filter

    public BitMapBloomFilter(IDatabase db, string key, int bitSetSize = 1_000_000, int hashFunctions = 7)
    {
        _db = db;
        _key = key;
        _bitSetSize = bitSetSize;
        _hashFunctions = hashFunctions;
    }

    // Get bit positions for an item (using multiple hash functions)
    private IEnumerable<long> GetBitPositions(string item)
    {
        for (int i = 0; i < _hashFunctions; i++)
        {
            // WHY: Combine item with seed for each hash function
            var hash = HashCode.Combine(item.GetHashCode(), i);
            yield return Math.Abs(hash) % _bitSetSize;
        }
    }

    // Add item to bloom filter
    public async Task AddAsync(string item)
    {
        var batch = _db.CreateBatch();
        var tasks = GetBitPositions(item)
            .Select(pos => batch.StringSetBitAsync(_key, pos, true))
            .ToList();
        batch.Execute();
        await Task.WhenAll(tasks);
    }

    // Check if item MIGHT be in the set
    public async Task<bool> MightContainAsync(string item)
    {
        var positions = GetBitPositions(item).ToArray();

        var batch = _db.CreateBatch();
        var tasks = positions
            .Select(pos => batch.StringGetBitAsync(_key, pos))
            .ToList();
        batch.Execute();

        var bits = await Task.WhenAll(tasks);

        // WHY: If ANY bit is 0, item definitely not in set
        // If ALL bits are 1, item MIGHT be in set (could be false positive)
        return bits.All(b => b);
    }
}

// RedisBloom module (Enterprise) — much simpler
public class RedisBloomFilter
{
    private readonly IDatabase _db;

    // BF.ADD key item
    public async Task AddAsync(string filterKey, string item)
        => await _db.ExecuteAsync("BF.ADD", filterKey, item);

    // BF.EXISTS key item
    public async Task<bool> ExistsAsync(string filterKey, string item)
    {
        var result = await _db.ExecuteAsync("BF.EXISTS", filterKey, item);
        return (long)result == 1;
    }

    // BF.MADD key item [item ...]
    public async Task AddManyAsync(string filterKey, params string[] items)
        => await _db.ExecuteAsync("BF.MADD", new[] { (object)filterKey }.Concat(items).ToArray());
}
```

---

## Two-Level Cache (L1 + L2)

> **Mental Model:** L1 = your desk drawer (in-process memory, nanoseconds).
> L2 = the office supply room (Redis, sub-millisecond).
> Database = the warehouse across town (milliseconds).

```csharp
// WHY: Two-level cache dramatically reduces Redis load for frequently accessed data
// L1 = IMemoryCache (fast, local, not shared across instances)
// L2 = Redis (slower, shared across all instances, persistent)

public class TwoLevelCache
{
    private readonly IMemoryCache _l1;
    private readonly IDatabase _l2;
    private static readonly TimeSpan L1Ttl = TimeSpan.FromSeconds(30);  // Short L1 TTL
    private static readonly TimeSpan L2Ttl = TimeSpan.FromMinutes(15);  // Longer L2 TTL

    public async Task<T?> GetOrSetAsync<T>(
        string key,
        Func<Task<T?>> loader,
        CancellationToken ct = default) where T : class
    {
        // ── Try L1 (in-process memory) ─────────────────────────────────
        if (_l1.TryGetValue(key, out T? l1Value))
            return l1Value;

        // ── Try L2 (Redis) ─────────────────────────────────────────────
        var l2Value = await _l2.StringGetAsync(key);
        if (l2Value.HasValue)
        {
            var value = JsonSerializer.Deserialize<T>(l2Value!);
            // WHY: Populate L1 from L2 hit to serve next request from memory
            _l1.Set(key, value, L1Ttl);
            return value;
        }

        // ── L2 miss — load from DB ─────────────────────────────────────
        var fresh = await loader();
        if (fresh is null) return null;

        var json = JsonSerializer.Serialize(fresh);

        // WHY: Set both L1 and L2 to warm the whole cache path
        _l1.Set(key, fresh, L1Ttl);
        await _l2.StringSetAsync(key, json, L2Ttl);

        return fresh;
    }

    public async Task InvalidateAsync(string key)
    {
        // WHY: Remove from both levels on invalidation
        _l1.Remove(key);
        await _l2.KeyDeleteAsync(key);

        // WHY: Also broadcast to other instances so they clear their L1 cache
        // (See Pub/Sub cache invalidation in guide 03)
    }
}
```

---

## Redis Search (Full-Text)

```csharp
// WHY: RediSearch module enables full-text search, filtering, and aggregation
// Available in Azure Cache for Redis Enterprise tier

// ── Create Index ───────────────────────────────────────────────────────
// FT.CREATE idx:products ON HASH PREFIX 1 product:
//   SCHEMA name TEXT WEIGHT 5.0 SORTABLE
//          description TEXT
//          price NUMERIC SORTABLE
//          category TAG
//          inStock TAG

// ── Index documents (Hash-based) ──────────────────────────────────────
public async Task IndexProductAsync(Product product)
{
    // Products are stored as Hashes — RediSearch indexes them automatically
    await _db.HashSetAsync($"product:{product.Id}", new HashEntry[]
    {
        new("name", product.Name),
        new("description", product.Description),
        new("price", product.Price.ToString()),
        new("category", product.Category),
        new("inStock", product.InStock ? "true" : "false")
    });
}

// ── Full-text search ───────────────────────────────────────────────────
public async Task<SearchResults> SearchProductsAsync(
    string query, string? category = null,
    decimal? minPrice = null, decimal? maxPrice = null,
    int offset = 0, int limit = 20)
{
    // Build FT.SEARCH query
    var searchQuery = query;

    if (category is not null)
        searchQuery += $" @category:{{{category}}}"; // TAG filter

    if (minPrice.HasValue || maxPrice.HasValue)
    {
        var min = minPrice.HasValue ? minPrice.Value.ToString() : "-inf";
        var max = maxPrice.HasValue ? maxPrice.Value.ToString() : "+inf";
        searchQuery += $" @price:[{min} {max}]"; // NUMERIC range filter
    }

    // WHY: FT.SEARCH returns matching docs with scores
    var result = await _db.ExecuteAsync("FT.SEARCH",
        "idx:products",
        searchQuery,
        "LIMIT", offset, limit,
        "SORTBY", "price", "ASC",
        "RETURN", "3", "name", "price", "category");

    return ParseSearchResults(result);
}

// ── Autocomplete with SUGGEST ──────────────────────────────────────────
public async Task AddSuggestionAsync(string key, string suggestion, double score = 1.0)
    => await _db.ExecuteAsync("FT.SUGADD", key, suggestion, score);

public async Task<IEnumerable<string>> GetSuggestionsAsync(string key, string prefix, int max = 5)
{
    var result = await _db.ExecuteAsync("FT.SUGGET", key, prefix, "MAX", max);
    return ((RedisResult[])result!).Select(r => r.ToString()!);
}
```

---

## Connection Pooling & Multiplexer Patterns

```csharp
// WHY: StackExchange.Redis is fully multiplexed — ONE ConnectionMultiplexer
// serves ALL concurrent requests efficiently (unlike raw socket-per-request)

// ── Singleton registration ─────────────────────────────────────────────
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
{
    var config = ConfigurationOptions.Parse(
        builder.Configuration.GetConnectionString("Redis")!);

    // Connection resilience
    config.AbortOnConnectFail = false;    // Don't crash if Redis is down on startup
    config.ConnectRetry = 5;              // Retry connection 5 times
    config.ConnectTimeout = 5000;         // 5s connection timeout
    config.SyncTimeout = 5000;            // 5s command timeout
    config.AsyncTimeout = 5000;

    // Performance
    config.SocketManager = SocketManager.ThreadPool; // WHY: Better for I/O bound workloads

    // Monitoring
    config.ReconnectRetryPolicy = new ExponentialRetry(5000);

    return ConnectionMultiplexer.Connect(config);
});

// ── Multiple databases ─────────────────────────────────────────────────
// WHY: Redis supports 16 databases (0-15) for logical isolation
// (Redis Cluster only supports DB 0)
var cacheDb = multiplexer.GetDatabase(0);  // Cache
var sessionDb = multiplexer.GetDatabase(1); // Sessions
var queueDb = multiplexer.GetDatabase(2);   // Queues

// ── Connection events for observability ───────────────────────────────
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
{
    var mux = ConnectionMultiplexer.Connect(connectionString);

    mux.ConnectionFailed += (_, e) =>
        sp.GetRequiredService<ILogger<Program>>()
            .LogError("Redis connection failed: {Reason}", e.FailureType);

    mux.ConnectionRestored += (_, e) =>
        sp.GetRequiredService<ILogger<Program>>()
            .LogInformation("Redis connection restored");

    mux.ErrorMessage += (_, e) =>
        sp.GetRequiredService<ILogger<Program>>()
            .LogWarning("Redis error: {Message}", e.Message);

    return mux;
});
```

---

## Redis Cluster — Sharding & Multi-Key Operations

```
┌──────────────────────────────────────────────────────────────────┐
│                   REDIS CLUSTER SLOTS                            │
│                                                                  │
│  16384 hash slots distributed across nodes                       │
│                                                                  │
│  Node 1: slots 0-5460      Node 2: slots 5461-10922             │
│  Node 3: slots 10923-16383                                       │
│                                                                  │
│  Key routing: CRC16(key) % 16384 → node                         │
│  Hash tags: {user:1}:profile → hash on {user:1} → same node    │
└──────────────────────────────────────────────────────────────────┘
```

```csharp
// ── Hash tags — force related keys to same slot ─────────────────────────
// WHY: Multi-key operations (MGET, pipelines) require all keys on same slot
// Wrap the shared portion in {} to force same slot

// BAD (may be on different nodes):
var keys = new RedisKey[] { "user:1:profile", "user:1:settings" };

// GOOD (hash tags force same slot):
var keys = new RedisKey[] { "{user:1}:profile", "{user:1}:settings" };
await _db.StringGetAsync(keys); // Works in cluster — same node

// ── Cluster-safe SCAN ──────────────────────────────────────────────────
// WHY: SCAN is per-node in cluster — must scan all nodes
public async IAsyncEnumerable<RedisKey> ScanAllNodesAsync(string pattern)
{
    var endpoints = _multiplexer.GetEndPoints();

    foreach (var endpoint in endpoints)
    {
        var server = _multiplexer.GetServer(endpoint);
        if (server.IsReplica) continue; // WHY: Only scan primaries

        await foreach (var key in server.KeysAsync(pattern: pattern))
            yield return key;
    }
}
```

---

## Sentinel — High Availability

```csharp
// WHY: Redis Sentinel provides automatic failover — if master fails,
// Sentinel promotes a replica and notifies clients

builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
{
    var config = new ConfigurationOptions
    {
        // WHY: Connect to Sentinels, not Redis directly
        // StackExchange.Redis handles master discovery automatically
        EndPoints =
        {
            { "sentinel1.internal", 26379 },
            { "sentinel2.internal", 26379 },
            { "sentinel3.internal", 26379 }
        },
        ServiceName = "mymaster",  // WHY: Sentinel master name configured in sentinel.conf
        AbortOnConnectFail = false,
        Password = "redis-password"
    };

    return ConnectionMultiplexer.Connect(config);
});
```

---

## Azure Cache for Redis — Managed Setup

```csharp
// ── Connection string (Azure Portal → Access Keys) ────────────────────
// Format: <name>.redis.cache.windows.net:6380,password=<key>,ssl=True,abortConnect=False

// ── appsettings.json ───────────────────────────────────────────────────
{
    "ConnectionStrings": {
        "Redis": "myredis.redis.cache.windows.net:6380,password=abc123,ssl=True,abortConnect=False,connectTimeout=5000"
    }
}

// ── Managed Identity (preferred over access keys) ─────────────────────
// WHY: Managed Identity eliminates stored credentials — auto-rotated by Azure
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
{
    var credential = new DefaultAzureCredential();
    var token = await credential.GetTokenAsync(new TokenRequestContext(
        new[] { "https://redis.azure.com/.default" }));

    var config = new ConfigurationOptions
    {
        EndPoints = { "myredis.redis.cache.windows.net:6380" },
        Ssl = true,
        Password = token.Token, // AAD token as password
        User = "<managed-identity-object-id>"
    };

    return ConnectionMultiplexer.Connect(config);
});

// ── Azure Redis Tiers ─────────────────────────────────────────────────
/*
  Basic: Dev/test, single node, no SLA, no persistence
  Standard: HA with replica, 99.9% SLA, no clustering
  Premium: Clustering, geo-replication, Redis Modules, VNet, 99.9% SLA
  Enterprise: Redis Stack (Search, Bloom, etc.), 99.99% SLA
  Enterprise Flash: Large datasets, NVMe SSD tier, 99.99% SLA
*/
```

---

## Performance Tuning Checklist

```
✅ Client Configuration
   □ ConnectionMultiplexer: singleton, abortConnect=false
   □ connectTimeout=5000, syncTimeout=5000
   □ Pipeline independent reads (IBatch)
   □ Fire-and-forget with StringSetAsync when result not needed (flags: CommandFlags.FireAndForget)

✅ Key Design
   □ Keys < 100 bytes (use short names, avoid UUIDs in keys)
   □ No KEYS * (use SCAN with cursor)
   □ Hash tags for cluster multi-key ops
   □ All keys have TTL (no orphaned keys)

✅ Value Sizes
   □ Values < 100KB (split large objects)
   □ Use MessagePack over JSON for bandwidth-sensitive paths
   □ Compress large blobs with GZip before storing

✅ Commands
   □ LRANGE 0 -1 → avoid on large lists (paginate)
   □ SMEMBERS → avoid on large sets (use SSCAN)
   □ HGETALL → avoid on large hashes (use HMGET for specific fields)
   □ SORT → avoid (expensive), precompute sorted order with ZADD

✅ Memory
   □ maxmemory set (leave headroom: set to 75% of available RAM)
   □ maxmemory-policy = allkeys-lru for cache workloads
   □ Monitor memory fragmentation ratio (redis-cli INFO memory)
   □ Use Redis Hash for objects < 64 fields (uses ziplist encoding, very compact)

✅ Serialization
   □ System.Text.Json with source generator for startup perf
   □ MessagePack for high-throughput key paths
   □ Pre-serialize to byte[] and reuse buffers with ArrayPool

✅ Monitoring KPIs
   □ keyspace_hit_ratio > 90%
   □ evicted_keys = 0 (or low)
   □ connected_clients < 10,000
   □ latency p99 < 5ms
   □ memory_fragmentation_ratio between 1.0 and 1.5

✅ Azure-Specific
   □ Use Premium tier for VNet integration (security)
   □ Enable geo-replication for multi-region apps
   □ Use Private Endpoint (not public internet)
   □ Enable Microsoft Entra authentication (no stored keys)
   □ Monitor via Azure Monitor Metrics + Alerts
```

---

## Quick Command Reference

```bash
# ── INFO & Monitoring ────────────────────────────────────────
redis-cli INFO server          # Server info
redis-cli INFO memory          # Memory usage
redis-cli INFO stats           # Hit/miss stats
redis-cli INFO clients         # Connected clients
redis-cli INFO replication     # Master/replica status
redis-cli SLOWLOG GET 10       # Last 10 slow commands
redis-cli LATENCY HISTORY      # Latency history

# ── Key Operations ───────────────────────────────────────────
redis-cli SCAN 0 MATCH "user:*" COUNT 100   # Safe key scan (vs KEYS *)
redis-cli DEBUG OBJECT mykey   # Encoding, LRU, serialization size
redis-cli OBJECT ENCODING key  # ziplist, skiplist, hashtable, etc.
redis-cli OBJECT IDLETIME key  # Seconds since last access

# ── Performance ──────────────────────────────────────────────
redis-cli --latency            # Real-time latency monitoring
redis-cli --latency-history    # Historical latency
redis-cli --stat               # Live stats (like top for Redis)
redis-benchmark -n 100000 -q  # Benchmark throughput

# ── Config ───────────────────────────────────────────────────
redis-cli CONFIG GET maxmemory
redis-cli CONFIG SET maxmemory 2gb
redis-cli CONFIG GET maxmemory-policy
redis-cli CONFIG SET maxmemory-policy allkeys-lru
redis-cli CONFIG REWRITE        # Save config changes to redis.conf
```

---

*See also:*
- [00-Redis-Overview-DataTypes.md](00-Redis-Overview-DataTypes.md)
- [01-Redis-Caching-Patterns.md](01-Redis-Caching-Patterns.md)
- [02-Redis-Session-Distributed-State.md](02-Redis-Session-Distributed-State.md)
- [03-Redis-PubSub-Messaging.md](03-Redis-PubSub-Messaging.md)
- [04-Redis-Distributed-Locking.md](04-Redis-Distributed-Locking.md)
- [05-Redis-Rate-Limiting.md](05-Redis-Rate-Limiting.md)
- [06-Redis-Streams.md](06-Redis-Streams.md)
- [07-Redis-Leaderboards-SortedSets.md](07-Redis-Leaderboards-SortedSets.md)
