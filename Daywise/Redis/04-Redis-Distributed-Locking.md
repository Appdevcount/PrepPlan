# Redis — Distributed Locking in .NET

> **Mental Model:** A distributed lock is a traffic light at a shared intersection.
> Only one car (process) goes at a time. The light has a timer (TTL) — if the car breaks down,
> the light eventually resets so other cars aren't stuck waiting forever.

---

## Table of Contents
1. [Why Distributed Locks?](#why-distributed-locks)
2. [Simple Lock — SET NX EX](#simple-lock--set-nx-ex)
3. [Safe Lock Release with Lua Script](#safe-lock-release-with-lua-script)
4. [RedLock Algorithm (Multi-Node)](#redlock-algorithm-multi-node)
5. [RedLock.net Library](#redlocknet-library)
6. [Lock with Auto-Renewal (Watchdog)](#lock-with-auto-renewal-watchdog)
7. [Reentrant Lock](#reentrant-lock)
8. [Real-World Scenarios](#real-world-scenarios)
   - [Order Processing — Prevent Duplicate Orders](#order-processing)
   - [Inventory Decrement](#inventory-decrement)
   - [Scheduled Job — Single Leader Election](#scheduled-job--single-leader-election)
   - [API Idempotency Keys](#api-idempotency-keys)
9. [Common Pitfalls](#common-pitfalls)
10. [Lock vs Transaction vs Queue](#lock-vs-transaction-vs-queue)

---

## Why Distributed Locks?

```
┌───────────────────────────────────────────────────────────────────┐
│                THE RACE CONDITION PROBLEM                         │
│                                                                   │
│  Server A: reads inventory = 1                                   │
│  Server B: reads inventory = 1                                   │
│  Server A: inventory > 0, creates order                          │
│  Server B: inventory > 0, creates order  ← BOTH orders created! │
│  Server A: decrements → inventory = 0                            │
│  Server B: decrements → inventory = -1  ← OVERSOLD!             │
│                                                                   │
│  WITH DISTRIBUTED LOCK:                                          │
│  Server A: acquires lock → reads 1 → creates order → dec → 0    │
│  Server B: lock busy → waits → acquires lock → reads 0 → reject │
└───────────────────────────────────────────────────────────────────┘
```

---

## Simple Lock — SET NX EX

```csharp
// WHY: SET key value NX EX is atomic — set only if Not eXists, with EXpiry
// This is the foundation of all Redis locking

public class RedisDistributedLock
{
    private readonly IDatabase _db;

    public RedisDistributedLock(IConnectionMultiplexer redis)
        => _db = redis.GetDatabase();

    // ── Acquire lock ───────────────────────────────────────────────────
    public async Task<string?> AcquireAsync(
        string resource,
        TimeSpan lockTimeout,
        int maxRetries = 3,
        TimeSpan? retryDelay = null)
    {
        // WHY: Unique token proves WE own the lock — prevents accidental unlock by other processes
        string token = Guid.NewGuid().ToString("N");
        string key = $"lock:{resource}";
        retryDelay ??= TimeSpan.FromMilliseconds(100);

        for (int attempt = 0; attempt <= maxRetries; attempt++)
        {
            // WHY: When.NotExists = NX flag — atomic conditional SET
            bool acquired = await _db.StringSetAsync(
                key, token, lockTimeout, When.NotExists);

            if (acquired) return token; // Success — return token for later release

            if (attempt < maxRetries)
            {
                // WHY: Exponential backoff with jitter prevents all retriers thundering at once
                var delay = retryDelay.Value * (attempt + 1)
                    + TimeSpan.FromMilliseconds(Random.Shared.Next(0, 50));
                await Task.Delay(delay);
            }
        }

        return null; // Failed to acquire within retry budget
    }

    // ── Release lock (WRONG WAY — don't do this) ──────────────────────
    // BAD: Two separate operations — NOT atomic, another process may have taken the lock
    // await _db.StringGetAsync(key);  // check token
    // await _db.KeyDeleteAsync(key);  // delete (WRONG — race condition between these)

    // ── Release lock (CORRECT WAY — Lua script) ───────────────────────
    private const string ReleaseLockScript = @"
        if redis.call('GET', KEYS[1]) == ARGV[1] then
            return redis.call('DEL', KEYS[1])
        else
            return 0
        end";
    // WHY: Lua scripts execute atomically in Redis — no race between GET and DEL

    public async Task<bool> ReleaseAsync(string resource, string token)
    {
        string key = $"lock:{resource}";
        var result = await _db.ScriptEvaluateAsync(
            ReleaseLockScript,
            new RedisKey[] { key },
            new RedisValue[] { token });

        return (long)result == 1; // 1 = deleted, 0 = lock was not ours
    }
}
```

### Usage Pattern
```csharp
public class InventoryService
{
    private readonly RedisDistributedLock _lock;
    private readonly IInventoryRepository _db;

    public async Task<bool> DecrementInventoryAsync(int productId, int quantity)
    {
        string resource = $"inventory:{productId}";

        // Acquire lock with 30 second timeout
        var token = await _lock.AcquireAsync(resource, TimeSpan.FromSeconds(30));
        if (token is null)
            throw new LockAcquisitionException($"Could not acquire lock for product {productId}");

        try
        {
            var product = await _db.GetByIdAsync(productId);

            if (product.Stock < quantity)
                return false; // Insufficient stock

            product.Stock -= quantity;
            await _db.UpdateAsync(product);
            return true;
        }
        finally
        {
            // WHY: Always release in finally — even if exception occurs
            await _lock.ReleaseAsync(resource, token);
        }
    }
}
```

---

## Safe Lock Release with Lua Script

```lua
-- WHY: Lua script is atomic — Redis executes it without interruption
-- GET and DEL happen as one operation

-- Check: does the lock key hold OUR token?
if redis.call('GET', KEYS[1]) == ARGV[1] then
    -- Yes: delete the lock (we own it)
    return redis.call('DEL', KEYS[1])
else
    -- No: someone else's lock or already expired
    return 0
end
```

```csharp
// Extend lock TTL (watchdog pattern) using Lua:
private const string ExtendLockScript = @"
    if redis.call('GET', KEYS[1]) == ARGV[1] then
        return redis.call('PEXPIRE', KEYS[1], ARGV[2])
    else
        return 0
    end";

public async Task<bool> ExtendAsync(string resource, string token, TimeSpan extension)
{
    var result = await _db.ScriptEvaluateAsync(
        ExtendLockScript,
        new RedisKey[] { $"lock:{resource}" },
        new RedisValue[] { token, (long)extension.TotalMilliseconds });

    return (long)result == 1;
}
```

---

## RedLock Algorithm (Multi-Node)

> **Mental Model:** RedLock is a majority vote — acquire lock on N independent Redis nodes.
> If majority (N/2+1) say yes, the lock is held. Even if 1-2 nodes fail, the lock still works.

```
┌───────────────────────────────────────────────────────────────┐
│                   REDLOCK ALGORITHM                           │
│                                                               │
│  Acquire on 5 independent Redis nodes:                        │
│                                                               │
│  Node 1: ✅ acquired  (10ms)                                 │
│  Node 2: ✅ acquired  (12ms)                                 │
│  Node 3: ✅ acquired  (11ms)  ← Quorum (3/5) achieved       │
│  Node 4: ❌ timeout                                           │
│  Node 5: ✅ acquired  (13ms)                                 │
│                                                               │
│  Total elapsed: 46ms                                          │
│  Effective TTL: original_ttl - elapsed = e.g. 30s - 46ms    │
│                                                               │
│  On release: release on ALL nodes (even failed ones)         │
└───────────────────────────────────────────────────────────────┘
```

**When to use RedLock:**
- You need true distributed safety across Redis Cluster nodes
- Single Redis node failure would break your system
- High-stakes operations (payments, inventory, leader election)

---

## RedLock.net Library

```xml
<!-- NuGet -->
<PackageReference Include="RedLock.net" Version="2.*" />
```

```csharp
// ── Setup ──────────────────────────────────────────────────────────────
builder.Services.AddSingleton<IDistributedLockFactory>(sp =>
{
    // WHY: Multiple endpoints = true RedLock — single = simple Redis lock
    var endpoints = new List<RedLockEndPoint>
    {
        new DnsEndPoint("redis1.internal", 6379),
        new DnsEndPoint("redis2.internal", 6379),
        new DnsEndPoint("redis3.internal", 6379),
    };

    return RedLockFactory.Create(endpoints);
});

// ── Usage ──────────────────────────────────────────────────────────────
public class PaymentService
{
    private readonly IDistributedLockFactory _lockFactory;

    public async Task<PaymentResult> ProcessPaymentAsync(Guid orderId, decimal amount)
    {
        string resource = $"payment:{orderId}";

        // WHY: expiryTime = lock TTL (how long before auto-release)
        // waitTime = how long to wait to acquire
        // retryTime = how often to retry during waitTime
        await using var redLock = await _lockFactory.CreateLockAsync(
            resource: resource,
            expiryTime: TimeSpan.FromSeconds(30),
            waitTime: TimeSpan.FromSeconds(10),
            retryTime: TimeSpan.FromMilliseconds(200));

        if (!redLock.IsAcquired)
        {
            // WHY: Another instance is processing this payment — return conflict
            throw new PaymentAlreadyProcessingException(orderId);
        }

        // Critical section — guaranteed only one instance runs this
        return await ChargeCardAsync(orderId, amount);
    }
}
```

---

## Lock with Auto-Renewal (Watchdog)

> **Problem:** Operation takes 45 seconds but lock TTL is 30 seconds → lock expires, another process steals it.
> **Solution:** Background watchdog renews the lock while the operation is running.

```csharp
public class AutoRenewingLock : IAsyncDisposable
{
    private readonly IDatabase _db;
    private readonly string _key;
    private readonly string _token;
    private readonly TimeSpan _ttl;
    private readonly CancellationTokenSource _cts;
    private readonly Task _renewalTask;

    private AutoRenewingLock(IDatabase db, string key, string token, TimeSpan ttl)
    {
        _db = db;
        _key = key;
        _token = token;
        _ttl = ttl;
        _cts = new CancellationTokenSource();

        // WHY: Renew at 1/3 of TTL to ensure we always renew well before expiry
        _renewalTask = StartRenewalLoop(_ttl / 3, _cts.Token);
    }

    private async Task StartRenewalLoop(TimeSpan interval, CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            try
            {
                await Task.Delay(interval, ct);
                await ExtendAsync(_ttl);
            }
            catch (OperationCanceledException) { break; }
        }
    }

    private const string ExtendScript = @"
        if redis.call('GET', KEYS[1]) == ARGV[1] then
            return redis.call('PEXPIRE', KEYS[1], ARGV[2])
        else
            return 0
        end";

    private async Task ExtendAsync(TimeSpan ttl)
        => await _db.ScriptEvaluateAsync(ExtendScript,
            new RedisKey[] { _key },
            new RedisValue[] { _token, (long)ttl.TotalMilliseconds });

    public static async Task<AutoRenewingLock?> AcquireAsync(
        IDatabase db, string resource, TimeSpan ttl)
    {
        string token = Guid.NewGuid().ToString("N");
        string key = $"lock:{resource}";

        bool acquired = await db.StringSetAsync(key, token, ttl, When.NotExists);
        return acquired ? new AutoRenewingLock(db, key, token, ttl) : null;
    }

    public async ValueTask DisposeAsync()
    {
        await _cts.CancelAsync();

        // Release lock via Lua script
        const string script = @"
            if redis.call('GET', KEYS[1]) == ARGV[1] then
                return redis.call('DEL', KEYS[1])
            else
                return 0
            end";

        await _db.ScriptEvaluateAsync(script,
            new RedisKey[] { _key },
            new RedisValue[] { _token });
    }
}

// Usage
await using var @lock = await AutoRenewingLock.AcquireAsync(db, "long-job:1", TimeSpan.FromSeconds(30));
if (@lock is null) throw new LockAcquisitionException("Could not acquire lock");

// This can run for minutes — lock auto-renews
await LongRunningOperationAsync();
// Lock released when 'using' block exits
```

---

## Reentrant Lock

```csharp
// WHY: Reentrant lock allows the same process/thread to acquire the lock multiple times
// without deadlocking (useful for recursive operations)

public class ReentrantRedisLock
{
    private readonly IDatabase _db;

    // WHY: Store the counter in the Redis lock value — allows same holder to increment
    public async Task<bool> AcquireAsync(string resource, string holderId, TimeSpan ttl)
    {
        string key = $"lock:{resource}";

        // Check if WE already hold this lock
        var currentHolder = await _db.StringGetAsync(key);
        if (currentHolder.HasValue && currentHolder.ToString().StartsWith(holderId))
        {
            // We hold it — increment reentry count and extend TTL
            var parts = currentHolder.ToString().Split(':');
            int count = int.Parse(parts[1]) + 1;
            await _db.StringSetAsync(key, $"{holderId}:{count}", ttl);
            return true;
        }

        // Try to acquire fresh
        bool acquired = await _db.StringSetAsync(
            key, $"{holderId}:1", ttl, When.NotExists);
        return acquired;
    }

    public async Task<bool> ReleaseAsync(string resource, string holderId)
    {
        string key = $"lock:{resource}";

        const string script = @"
            local val = redis.call('GET', KEYS[1])
            if not val then return 0 end
            local parts = {}
            for part in string.gmatch(val, '[^:]+') do parts[#parts+1] = part end
            if parts[1] ~= ARGV[1] then return 0 end
            local count = tonumber(parts[2]) - 1
            if count <= 0 then
                return redis.call('DEL', KEYS[1])
            else
                redis.call('SET', KEYS[1], ARGV[1] .. ':' .. count)
                redis.call('EXPIRE', KEYS[1], ARGV[2])
                return 1
            end";

        var result = await _db.ScriptEvaluateAsync(script,
            new RedisKey[] { key },
            new RedisValue[] { holderId, 30 });

        return (long)result >= 1;
    }
}
```

---

## Real-World Scenarios

### Order Processing

```csharp
// WHY: Prevent duplicate orders from double-click, network retry, or payment webhook replay
public class OrderProcessor
{
    private readonly RedisDistributedLock _lock;
    private readonly IOrderRepository _orders;

    public async Task<Order> ProcessOrderAsync(CreateOrderCommand cmd)
    {
        // Lock by idempotency key (client-provided or generated from content)
        string resource = $"order:create:{cmd.IdempotencyKey}";

        var token = await _lock.AcquireAsync(resource, TimeSpan.FromSeconds(30));
        if (token is null)
        {
            // Another instance is processing the same order
            await Task.Delay(500); // Brief wait

            // Check if it was already created
            var existing = await _orders.FindByIdempotencyKeyAsync(cmd.IdempotencyKey);
            return existing ?? throw new OrderProcessingException("Could not acquire lock");
        }

        try
        {
            // Double-check idempotency after acquiring lock
            var existing = await _orders.FindByIdempotencyKeyAsync(cmd.IdempotencyKey);
            if (existing is not null) return existing;

            return await CreateOrderAsync(cmd);
        }
        finally
        {
            await _lock.ReleaseAsync(resource, token);
        }
    }
}
```

---

### Inventory Decrement

```csharp
public class InventoryService
{
    public async Task<bool> ReserveStockAsync(int productId, int quantity)
    {
        string resource = $"inventory:{productId}";

        // WHY: Short lock timeout — inventory checks are fast, don't hold lock long
        var token = await _lock.AcquireAsync(resource, TimeSpan.FromSeconds(5));
        if (token is null)
            throw new ServiceUnavailableException("Inventory service temporarily unavailable");

        try
        {
            var stock = await _db.GetStockAsync(productId);
            if (stock < quantity) return false;

            await _db.ReserveAsync(productId, quantity);
            return true;
        }
        finally
        {
            await _lock.ReleaseAsync(resource, token);
        }
    }
}
```

---

### Scheduled Job — Single Leader Election

```csharp
// WHY: In Kubernetes with multiple replicas, only ONE pod should run scheduled jobs
// Redis lock = leader election — the pod that acquires the lock runs the job

public class LeaderElectionWorker : BackgroundService
{
    private readonly IDatabase _redis;
    private readonly IJobRunner _jobRunner;
    private readonly string _podId;

    public LeaderElectionWorker(IConnectionMultiplexer redis, IJobRunner jobs)
    {
        _redis = redis.GetDatabase();
        _jobRunner = jobs;
        _podId = Environment.MachineName; // Unique per pod in K8s
    }

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            // WHY: Heartbeat-based leader election — renew every 30 seconds
            bool isLeader = await _redis.StringSetAsync(
                "leader:scheduled-jobs",
                _podId,
                TimeSpan.FromSeconds(60), // Lock TTL = 60s
                When.NotExists);

            // If we didn't get fresh lock, check if we're already the leader
            if (!isLeader)
            {
                var currentLeader = await _redis.StringGetAsync("leader:scheduled-jobs");
                isLeader = currentLeader == _podId;

                if (isLeader)
                {
                    // Extend our leadership TTL
                    await _redis.KeyExpireAsync("leader:scheduled-jobs", TimeSpan.FromSeconds(60));
                }
            }

            if (isLeader)
            {
                await _jobRunner.RunScheduledJobsAsync(ct);
            }

            await Task.Delay(TimeSpan.FromSeconds(30), ct);
        }
    }
}
```

---

### API Idempotency Keys

```csharp
// WHY: Idempotency keys prevent duplicate API operations (e.g., payment processed twice)
// Redis lock holds for the duration of the request, then stores result

public class IdempotencyMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IDatabase _redis;

    public async Task InvokeAsync(HttpContext context)
    {
        var idempotencyKey = context.Request.Headers["Idempotency-Key"].ToString();

        if (string.IsNullOrEmpty(idempotencyKey))
        {
            await _next(context);
            return;
        }

        string cacheKey = $"idempotency:{idempotencyKey}";
        string lockKey = $"idempotency:lock:{idempotencyKey}";
        string lockToken = Guid.NewGuid().ToString("N");

        // ── Check if already processed ─────────────────────────────────
        var cached = await _redis.StringGetAsync(cacheKey);
        if (cached.HasValue)
        {
            // Return cached response
            var cachedResponse = JsonSerializer.Deserialize<CachedResponse>(cached!);
            context.Response.StatusCode = cachedResponse!.StatusCode;
            await context.Response.WriteAsync(cachedResponse.Body);
            return;
        }

        // ── Acquire lock to prevent concurrent processing ───────────────
        bool acquired = await _redis.StringSetAsync(
            lockKey, lockToken, TimeSpan.FromSeconds(30), When.NotExists);

        if (!acquired)
        {
            context.Response.StatusCode = StatusCodes.Status409Conflict;
            await context.Response.WriteAsJsonAsync(new { error = "Request in progress" });
            return;
        }

        try
        {
            // Process request
            await _next(context);

            // Cache the response for idempotency
            // WHY: Store for 24 hours — caller can retry with same key
            await _redis.StringSetAsync(cacheKey,
                JsonSerializer.Serialize(new CachedResponse(
                    context.Response.StatusCode, "response-body")),
                TimeSpan.FromHours(24));
        }
        finally
        {
            // Release lock
            const string script = @"
                if redis.call('GET', KEYS[1]) == ARGV[1] then
                    return redis.call('DEL', KEYS[1])
                else return 0 end";
            await _redis.ScriptEvaluateAsync(script,
                new RedisKey[] { lockKey }, new RedisValue[] { lockToken });
        }
    }
}

public record CachedResponse(int StatusCode, string Body);
```

---

## Common Pitfalls

```
┌────────────────────────────────────────────────────────────────────┐
│                    COMMON LOCK MISTAKES                            │
├────────────────────────────────────────────────────────────────────┤
│ ❌ Not using unique token                                          │
│    → Another process with expired lock can delete your lock       │
│    ✅ Always generate a UUID token when acquiring                  │
│                                                                    │
│ ❌ Using GET + DEL (non-atomic release)                            │
│    → Race condition between check and delete                       │
│    ✅ Always use Lua script for atomic release                     │
│                                                                    │
│ ❌ TTL too short                                                   │
│    → Lock expires while operation is still running                │
│    ✅ Use watchdog auto-renewal for long operations                │
│                                                                    │
│ ❌ TTL too long                                                    │
│    → System locked for hours if process crashes                   │
│    ✅ Keep TTL reasonable (1-5x expected operation time)          │
│                                                                    │
│ ❌ Not releasing in finally block                                  │
│    → Exception leaves lock unreleased                             │
│    ✅ Always use try/finally or IAsyncDisposable                  │
│                                                                    │
│ ❌ Single-node Redis for critical locks                            │
│    → Redis restart loses all locks — stuck systems                │
│    ✅ Use RedLock.net with 3+ independent nodes for critical ops  │
│                                                                    │
│ ❌ Ignoring clock drift                                            │
│    → Server clocks can drift, making TTL calculations off         │
│    ✅ RedLock subtracts clock drift from validity window          │
└────────────────────────────────────────────────────────────────────┘
```

---

## Lock vs Transaction vs Queue

```
┌─────────────────────┬──────────────────────────────────────────────┐
│ Mechanism           │ Best for                                      │
├─────────────────────┼──────────────────────────────────────────────┤
│ Redis Lock          │ Cross-process mutual exclusion on a resource │
│ Redis MULTI/EXEC    │ Atomic multi-key operations within Redis      │
│ Database transaction│ ACID guarantees within a single DB           │
│ Queue + worker      │ Serialize work without blocking callers       │
│ Optimistic locking  │ Low-contention scenarios (CAS with version)  │
└─────────────────────┴──────────────────────────────────────────────┘

// WHY: Redis MULTI/EXEC is NOT the same as a distributed lock
// MULTI/EXEC prevents interleaving of Redis commands but doesn't block other clients
// WATCH + MULTI/EXEC = optimistic locking within Redis only

// Example: WATCH-based optimistic locking for Redis-only operations
var trans = _db.CreateTransaction();
trans.AddCondition(Condition.StringEqual("inventory:product:1", "5")); // WATCH
_ = trans.StringDecrementAsync("inventory:product:1");
bool committed = await trans.ExecuteAsync(); // Fails if value changed since WATCH
```

---

*Next:* [05-Redis-Rate-Limiting.md](05-Redis-Rate-Limiting.md) — Fixed window, sliding window, token bucket, leaky bucket in .NET
