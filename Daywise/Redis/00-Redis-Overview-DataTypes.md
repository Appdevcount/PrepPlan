# Redis — Complete Overview & Data Types (with .NET)

> **Mental Model:** Redis is a Swiss Army knife in memory. It's not just a key-value store — it's a data structure server.
> Think of it like RAM with superpowers: ultra-fast reads/writes (sub-millisecond), persistence options, and 10+ native data structures.

---

## Table of Contents
1. [What Is Redis?](#what-is-redis)
2. [Architecture & Internals](#architecture--internals)
3. [Data Types Deep Dive](#data-types-deep-dive)
4. [.NET Setup & Connection](#net-setup--connection)
5. [Key Naming Conventions](#key-naming-conventions)
6. [Expiry & Eviction Policies](#expiry--eviction-policies)
7. [Persistence Modes](#persistence-modes)
8. [Redis vs Alternatives](#redis-vs-alternatives)
9. [Production Checklist](#production-checklist)

---

## What Is Redis?

```
┌─────────────────────────────────────────────────────────────────┐
│                        REDIS CAPABILITIES                       │
├─────────────────┬───────────────────────────────────────────────┤
│  Data Structures│  String, Hash, List, Set, Sorted Set,         │
│                 │  Stream, HyperLogLog, Geo, Bitmap             │
├─────────────────┼───────────────────────────────────────────────┤
│  Use Cases      │  Cache, Session, Queue, Pub/Sub, Rate Limit,  │
│                 │  Leaderboard, Distributed Lock, Search        │
├─────────────────┼───────────────────────────────────────────────┤
│  Performance    │  ~100K ops/sec single node, sub-ms latency    │
├─────────────────┼───────────────────────────────────────────────┤
│  Durability     │  RDB snapshots + AOF write-ahead log          │
├─────────────────┼───────────────────────────────────────────────┤
│  HA Options     │  Sentinel (failover) / Cluster (sharding)     │
└─────────────────┴───────────────────────────────────────────────┘
```

**Redis = Remote Dictionary Server** — single-threaded event loop, all operations are atomic.

---

## Architecture & Internals

```
┌────────────────────────────────────────────────────────────────┐
│                    REDIS INTERNALS                             │
│                                                                │
│  Client Connections                                            │
│       │                                                        │
│       ▼                                                        │
│  ┌──────────────┐     ┌──────────────────────────────────┐    │
│  │ Event Loop   │────▶│  In-Memory Data Store            │    │
│  │ (single      │     │  (hash table of key→value)       │    │
│  │  threaded)   │     └──────────────────────────────────┘    │
│  └──────────────┘              │                              │
│         │              ┌───────┴────────┐                     │
│         │              │                │                     │
│         ▼              ▼                ▼                     │
│  ┌─────────────┐  ┌──────────┐  ┌─────────────┐             │
│  │ Networking  │  │  RDB     │  │    AOF       │             │
│  │ (I/O mux)  │  │ Snapshot │  │  Write-Ahead │             │
│  └─────────────┘  └──────────┘  │    Log       │             │
│                                  └─────────────┘             │
└────────────────────────────────────────────────────────────────┘
```

**Key Insight:** Single-threaded means NO race conditions on individual operations — every command is automatically atomic. This is why Redis locks and counters work reliably.

---

## Data Types Deep Dive

### 1. String
> **Mental Model:** Like a variable. Can hold text, numbers, binary (up to 512MB).

```
Key → Value
user:1:name → "Alice"
counter:visits → 42
session:abc123 → "{json...}"
```

**Common Commands:**
```bash
SET key value [EX seconds] [NX|XX]
GET key
INCR key          # atomic increment
INCRBY key delta
GETSET key newval # get old, set new (atomic)
MSET k1 v1 k2 v2  # multi-set
MGET k1 k2        # multi-get
```

**.NET Example:**
```csharp
// WHY: StackExchange.Redis is the go-to .NET client — battle-tested, async-first
IDatabase db = redis.GetDatabase();

await db.StringSetAsync("user:1:name", "Alice", TimeSpan.FromMinutes(30));
var name = await db.StringGetAsync("user:1:name");

// Atomic counter — safe without locks because Redis is single-threaded
long visits = await db.StringIncrementAsync("counter:page:home");

// Conditional set — only if not exists (NX pattern for distributed locking)
bool wasSet = await db.StringSetAsync("lock:resource", "token123",
    TimeSpan.FromSeconds(30), When.NotExists);
```

---

### 2. Hash
> **Mental Model:** Like a C# object / dictionary stored under one key. Best for entities with multiple fields.

```
Key → Field → Value
user:1 → { name: "Alice", email: "a@b.com", age: "30" }
```

**Common Commands:**
```bash
HSET key field value [field value ...]
HGET key field
HMGET key field1 field2
HGETALL key        # get all fields
HINCRBY key field delta
HDEL key field
HEXISTS key field
HKEYS key / HVALS key
```

**.NET Example:**
```csharp
// WHY: HSET is more efficient than storing serialized JSON when you
// need to update individual fields without reading the whole object
var fields = new HashEntry[]
{
    new("name", "Alice"),
    new("email", "alice@example.com"),
    new("age", 30)
};
await db.HashSetAsync("user:1", fields);

// Read single field — efficient, avoids deserializing entire object
var email = await db.HashGetAsync("user:1", "email");

// Read all fields as a dictionary
var all = await db.HashGetAllAsync("user:1");
var dict = all.ToDictionary(e => e.Name.ToString(), e => e.Value.ToString());

// Atomic increment on hash field
await db.HashIncrementAsync("user:1", "loginCount", 1);
```

---

### 3. List
> **Mental Model:** A doubly-linked list. Use for queues (LPUSH/RPOP) or stacks (LPUSH/LPOP). Also for activity feeds.

```
Key → [item1, item2, item3, ...]  (ordered by insertion)
```

**Common Commands:**
```bash
LPUSH key val      # push left (head)
RPUSH key val      # push right (tail)
LPOP key           # pop left
RPOP key           # pop right
LRANGE key 0 -1   # all elements
LLEN key
BLPOP key timeout  # blocking pop (great for worker queues)
LINSERT key BEFORE/AFTER pivot value
```

**.NET Example:**
```csharp
// WHY: RPUSH + BLPOP = reliable FIFO queue between producers and workers
// Producer
await db.ListRightPushAsync("queue:emails", JsonSerializer.Serialize(emailJob));

// Consumer (blocking — waits up to 30s for a message)
var result = await db.ListLeftPopAsync("queue:emails");
if (result.HasValue)
{
    var job = JsonSerializer.Deserialize<EmailJob>(result!);
    await ProcessEmail(job);
}

// Activity feed — keep last 100 items (trim after push)
await db.ListLeftPushAsync($"feed:{userId}", JsonSerializer.Serialize(activity));
await db.ListTrimAsync($"feed:{userId}", 0, 99); // WHY: prevents unbounded growth
```

---

### 4. Set
> **Mental Model:** Unordered collection of unique strings. Like `HashSet<string>`. Great for tags, unique visitors, and set operations (union/intersect).

```
Key → {member1, member2, member3}  (no duplicates, no order)
```

**Common Commands:**
```bash
SADD key member [member ...]
SREM key member
SISMEMBER key member    # O(1) membership check
SMEMBERS key            # all members
SCARD key               # count
SUNION key1 key2        # union
SINTER key1 key2        # intersection
SDIFF key1 key2         # difference
SMOVE src dst member    # atomic move
```

**.NET Example:**
```csharp
// WHY: Set membership check is O(1) — ideal for "has user X seen this?" checks
await db.SetAddAsync($"seen:article:{articleId}", userId);
bool hasSeen = await db.SetContainsAsync($"seen:article:{articleId}", userId);

// Tags — union across multiple articles to find all tags used
await db.SetAddAsync($"tags:article:{articleId}", new RedisValue[] { "redis", "caching", "dotnet" });

// Friends in common (intersection)
var common = await db.SetCombineAsync(SetOperation.Intersect,
    $"friends:{userA}", $"friends:{userB}");

// Unique daily active users
string dayKey = $"dau:{DateTime.UtcNow:yyyy-MM-dd}";
await db.SetAddAsync(dayKey, userId);
await db.KeyExpireAsync(dayKey, TimeSpan.FromDays(7)); // WHY: auto-cleanup old day keys
long dauCount = await db.SetLengthAsync(dayKey);
```

---

### 5. Sorted Set (ZSet)
> **Mental Model:** Set + score for every member. Automatically sorted by score. Perfect for leaderboards, priority queues, time-series indexes.

```
Key → { member: score, member: score, ... }  (sorted ascending by score)
```

**Common Commands:**
```bash
ZADD key score member [score member ...]
ZINCRBY key delta member     # atomic increment score
ZRANK key member             # 0-based rank (lowest score = rank 0)
ZREVRANK key member          # rank from highest
ZSCORE key member            # get score
ZRANGE key start stop [WITHSCORES] [REV]
ZRANGEBYSCORE key min max    # range by score
ZREM key member
ZCARD key
ZPOPMIN key [count]          # pop lowest-score members
ZPOPMAX key [count]          # pop highest-score members
```

**.NET Example:**
```csharp
// WHY: Sorted set gives O(log N) insert/update and O(log N + M) range queries
// Leaderboard — score = points
await db.SortedSetAddAsync("leaderboard:game1", userId, score);
await db.SortedSetIncrementAsync("leaderboard:game1", userId, pointsEarned);

// Top 10 players (highest scores first)
var top10 = await db.SortedSetRangeByRankWithScoresAsync(
    "leaderboard:game1", 0, 9, Order.Descending);

foreach (var entry in top10)
    Console.WriteLine($"{entry.Element}: {entry.Score}");

// Player's rank
long? rank = await db.SortedSetRankAsync("leaderboard:game1", userId, Order.Descending);

// Rate limiting with sliding window (score = timestamp)
double now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
string windowKey = $"ratelimit:{clientId}";
await db.SortedSetAddAsync(windowKey, Guid.NewGuid().ToString(), now);
await db.SortedSetRemoveRangeByScoreAsync(windowKey, 0, now - 60_000); // WHY: remove entries older than 1 min window
long requestCount = await db.SortedSetLengthAsync(windowKey);
```

---

### 6. HyperLogLog
> **Mental Model:** A probabilistic data structure for counting unique items. Uses ~12KB regardless of how many unique items you track. Accuracy: ~0.81% error.

**.NET Example:**
```csharp
// WHY: Counting billions of unique visitors with ~12KB memory vs gigabytes for exact counting
await db.HyperLogLogAddAsync("unique:visitors:2024-01-15", visitorId);
long approxCount = await db.HyperLogLogLengthAsync("unique:visitors:2024-01-15");

// Merge multiple HLLs (union of unique counts across days)
await db.HyperLogLogMergeAsync("unique:visitors:week", new RedisKey[]
{
    "unique:visitors:2024-01-15",
    "unique:visitors:2024-01-16",
    "unique:visitors:2024-01-17"
});
```

---

### 7. Geo
> **Mental Model:** Sorted set under the hood, but with lat/lng encoded as score. Enables radius searches and distance calculations.

**.NET Example:**
```csharp
// Store locations
await db.GeoAddAsync("restaurants", new GeoEntry(longitude: -73.935242, latitude: 40.730610, member: "restaurant:1"));
await db.GeoAddAsync("restaurants", new GeoEntry(-73.985242, 40.748610, "restaurant:2"));

// Find restaurants within 5km of user
var nearby = await db.GeoRadiusAsync("restaurants",
    longitude: -73.960, latitude: 40.740,
    radius: 5, unit: GeoUnit.Kilometers,
    count: 10, order: Order.Ascending);

// Distance between two places
var dist = await db.GeoDistanceAsync("restaurants", "restaurant:1", "restaurant:2", GeoUnit.Kilometers);
```

---

### 8. Stream
> **Mental Model:** Like an append-only log (similar to Kafka topics but simpler). Each entry has a unique ID. Supports consumer groups for competing consumers.

See dedicated guide: [06-Redis-Streams.md](06-Redis-Streams.md)

---

### 9. Bitmap
> **Mental Model:** Array of bits. Use for very compact boolean flags. 1 bit per user = 125MB for 1 billion users.

**.NET Example:**
```csharp
// Daily active users bitmap (1 bit per user ID)
string key = $"active:{DateTime.UtcNow:yyyy-MM-dd}";
await db.StringSetBitAsync(key, userId, true);
bool isActive = await db.StringGetBitAsync(key, userId);

// Count active users today
long activeCount = await db.StringBitCountAsync(key);
```

---

## .NET Setup & Connection

### NuGet Packages
```xml
<!-- Primary client — used by most .NET applications -->
<PackageReference Include="StackExchange.Redis" Version="2.7.*" />

<!-- Microsoft abstraction layer (IDistributedCache) -->
<PackageReference Include="Microsoft.Extensions.Caching.StackExchangeRedis" Version="9.*" />
```

### Connection Setup (Program.cs)
```csharp
// WHY: ConnectionMultiplexer is thread-safe and expensive to create —
// always register as Singleton and reuse across requests
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
{
    var config = ConfigurationOptions.Parse(
        builder.Configuration.GetConnectionString("Redis")!);

    // WHY: Enable reconnect retry to handle transient network blips in Azure
    config.ReconnectRetryPolicy = new ExponentialRetry(5000);
    config.ConnectTimeout = 5000;
    config.SyncTimeout = 5000;
    config.AbortOnConnectFail = false; // WHY: don't crash app if Redis is temporarily down

    return ConnectionMultiplexer.Connect(config);
});

// IDistributedCache for ASP.NET session, output cache, etc.
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis");
    options.InstanceName = "myapp:"; // WHY: namespace prefix prevents key collisions in shared Redis
});
```

### appsettings.json
```json
{
  "ConnectionStrings": {
    "Redis": "localhost:6379,password=secret,ssl=false,abortConnect=false"
  }
}
```

### Azure Redis Cache connection string
```
myredis.redis.cache.windows.net:6380,password=<key>,ssl=True,abortConnect=False
```

---

## Key Naming Conventions

```
Pattern: {object-type}:{id}:{field}
Examples:
  user:1001:profile
  session:abc123xyz
  cache:product:456
  ratelimit:ip:192.168.1.1
  lock:order:processing
  leaderboard:game:season2
  queue:email:pending
  feed:user:1001

// WHY: colons as separators match Redis Insight UI's tree view grouping
// WHY: object type first allows wildcard scans: SCAN 0 MATCH user:*
```

---

## Expiry & Eviction Policies

### Setting TTL
```csharp
// Set with expiry at creation
await db.StringSetAsync("key", "value", TimeSpan.FromMinutes(10));

// Set expiry on existing key
await db.KeyExpireAsync("key", TimeSpan.FromHours(1));

// Set absolute expiry
await db.KeyExpireAsync("key", DateTime.UtcNow.AddDays(1));

// Remove expiry (make persistent)
await db.KeyPersistAsync("key");

// Check remaining TTL
TimeSpan? ttl = await db.KeyTimeToLiveAsync("key");
```

### Eviction Policies (redis.conf)
```
┌────────────────────┬──────────────────────────────────────────┐
│ Policy             │ Behavior                                 │
├────────────────────┼──────────────────────────────────────────┤
│ noeviction         │ Return error when memory full (default)  │
│ allkeys-lru        │ Evict any key using LRU                  │
│ volatile-lru       │ Evict only keys with TTL using LRU       │
│ allkeys-lfu        │ Evict by least-frequently-used           │
│ volatile-lfu       │ Evict TTL keys by LFU                    │
│ allkeys-random     │ Evict random key                         │
│ volatile-ttl       │ Evict key closest to expiry              │
└────────────────────┴──────────────────────────────────────────┘

// WHY for caching use cases: allkeys-lru is standard — ensures memory is bounded
// WHY for session storage: volatile-lru — sessions have TTLs, keep persistent keys safe
```

---

## Persistence Modes

```
┌───────────────────────────────────────────────────────────┐
│               RDB vs AOF Comparison                       │
├──────────────┬────────────────────────────────────────────┤
│              │  RDB (Snapshot)     │  AOF (Write-ahead)   │
├──────────────┼─────────────────────┼──────────────────────┤
│ How          │ Point-in-time dump  │ Append every command │
│ File size    │ Compact             │ Larger               │
│ Recovery     │ Fast restart        │ More data preserved  │
│ Data loss    │ Up to last snapshot │ ~1 second (fsync)    │
│ Performance  │ No impact normally  │ Slight overhead      │
│ Use when     │ Cache (OK to lose)  │ Session/queue data   │
└──────────────┴─────────────────────┴──────────────────────┘

// WHY: For pure caching, disable persistence entirely (maxmemory-policy allkeys-lru)
// WHY: For session stores, use AOF everysec — tolerate 1s loss, fast writes
// WHY: For message queues, use AOF always — no data loss, accept write overhead
```

---

## Redis vs Alternatives

```
┌─────────────────┬──────────┬──────────┬────────────┬─────────────┐
│ Feature         │ Redis    │ Memcached│ Hazelcast  │ In-Memory   │
├─────────────────┼──────────┼──────────┼────────────┼─────────────┤
│ Data structures │ 10+      │ String   │ Map/Queue  │ Any         │
│ Persistence     │ Yes      │ No       │ Yes        │ No          │
│ Pub/Sub         │ Yes      │ No       │ Yes        │ No          │
│ Clustering      │ Yes      │ Yes      │ Yes        │ No          │
│ Transactions    │ MULTI    │ No       │ Yes        │ No          │
│ LUA scripting   │ Yes      │ No       │ Yes        │ No          │
│ Streams         │ Yes      │ No       │ No         │ No          │
│ .NET support    │ Excellent│ Good     │ Good       │ Native      │
│ Azure managed   │ Yes      │ No       │ No         │ No          │
└─────────────────┴──────────┴──────────┴────────────┴─────────────┘
```

---

## Production Checklist

```
✅ Connection
   □ ConnectionMultiplexer registered as Singleton
   □ abortConnect=false to survive transient outages
   □ connectTimeout and syncTimeout set (5s each)
   □ Key prefix / InstanceName set to avoid collisions

✅ Memory
   □ maxmemory set (never let Redis use all RAM)
   □ maxmemory-policy configured for use case
   □ All volatile keys have TTL

✅ Security
   □ Password / ACL configured
   □ Redis not exposed on public internet
   □ TLS enabled in production (ssl=true)
   □ bind 127.0.0.1 or private VNet only

✅ Observability
   □ Monitor connected clients, memory, hit rate
   □ Alert on evicted_keys > 0 (memory pressure)
   □ Alert on keyspace_misses / keyspace_hits ratio
   □ Use SLOWLOG to detect slow commands

✅ HA
   □ Redis Sentinel (failover) or Redis Cluster (sharding)
   □ Azure Cache for Redis Premium (geo-replication)
   □ Application handles connection failures gracefully

✅ Keys
   □ Consistent naming convention (type:id:field)
   □ No KEYS * in production (use SCAN instead)
   □ Large keys identified and split if > 100KB
```

---

*Next:* [01-Redis-Caching-Patterns.md](01-Redis-Caching-Patterns.md) — Cache-Aside, Write-Through, Read-Through, Write-Behind with full .NET code
