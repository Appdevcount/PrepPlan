# Redis — Rate Limiting in .NET

> **Mental Model:** Rate limiting is a bouncer at a club — X people allowed in per minute.
> Too many? Wait outside. Redis keeps count so ALL bouncers (servers) agree on the number.

---

## Table of Contents
1. [Rate Limiting Algorithms Compared](#rate-limiting-algorithms-compared)
2. [Fixed Window Counter](#fixed-window-counter)
3. [Sliding Window Log (Sorted Set)](#sliding-window-log-sorted-set)
4. [Sliding Window Counter (Hybrid)](#sliding-window-counter-hybrid)
5. [Token Bucket](#token-bucket)
6. [Leaky Bucket](#leaky-bucket)
7. [ASP.NET Core Rate Limiter + Redis](#aspnet-core-rate-limiter--redis)
8. [Middleware Implementation](#middleware-implementation)
9. [Per-User, Per-IP, Per-Endpoint Policies](#per-user-per-ip-per-endpoint-policies)
10. [Rate Limit Headers (RFC 6585)](#rate-limit-headers-rfc-6585)
11. [Production Patterns](#production-patterns)

---

## Rate Limiting Algorithms Compared

```
┌────────────────────┬────────────┬─────────────┬──────────────┬───────────────┐
│ Algorithm          │ Burst      │ Smoothness  │ Memory       │ Complexity    │
├────────────────────┼────────────┼─────────────┼──────────────┼───────────────┤
│ Fixed Window       │ ✅ Allowed │ ❌ Spiky    │ O(1)         │ Simple        │
│ Sliding Window Log │ ❌ Limited │ ✅ Smooth   │ O(requests)  │ Medium        │
│ Sliding Window Ctr │ Partial    │ ✅ Good     │ O(1)         │ Medium        │
│ Token Bucket       │ ✅ Allowed │ ✅ Smooth   │ O(1)         │ Medium        │
│ Leaky Bucket       │ ❌ No      │ ✅ Smooth   │ O(1)         │ Complex       │
└────────────────────┴────────────┴─────────────┴──────────────┴───────────────┘

Recommendation by use case:
  API gateway throttling → Token Bucket (allows bursts, smooth average)
  Login protection       → Sliding Window Log (strict per-IP)
  Background job limits  → Fixed Window (simple, good enough)
  Payment endpoints      → Sliding Window Counter (balance of accuracy + memory)
```

---

## Fixed Window Counter

> **Mental Model:** Reset a counter every minute. If you've made 100 requests this minute, stop.
> Problem: 100 requests at 00:59 + 100 requests at 01:00 = 200 in 2 seconds.

```csharp
// WHY: Simplest algorithm — just INCR + EXPIRE per time window
public class FixedWindowRateLimiter
{
    private readonly IDatabase _redis;

    public async Task<RateLimitResult> CheckAsync(
        string identifier,   // IP, userId, apiKey, etc.
        string endpoint,
        int limit,           // max requests
        TimeSpan window)     // window size (e.g., 1 minute)
    {
        // WHY: Include window timestamp in key so it auto-resets each window
        long windowId = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / (long)window.TotalSeconds;
        string key = $"ratelimit:fixed:{endpoint}:{identifier}:{windowId}";

        // ── Atomic increment + read ────────────────────────────────────
        long count = await _redis.StringIncrementAsync(key);

        // ── Set TTL on first request ───────────────────────────────────
        if (count == 1)
        {
            // WHY: TTL = 2x window to handle edge case where increment happens
            // just before window boundary — key survives to prevent phantom counts
            await _redis.KeyExpireAsync(key, window * 2);
        }

        bool allowed = count <= limit;
        long remaining = Math.Max(0, limit - count);

        // Calculate when current window resets
        var windowStart = DateTimeOffset.FromUnixTimeSeconds(windowId * (long)window.TotalSeconds);
        var resetAt = windowStart + window;

        return new RateLimitResult(allowed, count, remaining, limit, resetAt);
    }
}

public record RateLimitResult(
    bool IsAllowed,
    long Current,
    long Remaining,
    long Limit,
    DateTimeOffset ResetsAt);
```

---

## Sliding Window Log (Sorted Set)

> **Mental Model:** Keep a timestamp log of every request. Count requests in the last N seconds.
> Most accurate but uses O(requests) memory.

```csharp
// WHY: Sorted Set with score=timestamp allows efficient range queries for window
public class SlidingWindowLogRateLimiter
{
    private readonly IDatabase _redis;

    public async Task<RateLimitResult> CheckAsync(
        string identifier,
        string endpoint,
        int limit,
        TimeSpan window)
    {
        string key = $"ratelimit:sliding:{endpoint}:{identifier}";
        long nowMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        long windowStartMs = nowMs - (long)window.TotalMilliseconds;

        // WHY: Use Lua script to make all operations atomic — prevents race conditions
        const string script = @"
            local key = KEYS[1]
            local now = tonumber(ARGV[1])
            local window_start = tonumber(ARGV[2])
            local limit = tonumber(ARGV[3])
            local ttl = tonumber(ARGV[4])
            local request_id = ARGV[5]

            -- Remove timestamps outside the window
            redis.call('ZREMRANGEBYSCORE', key, 0, window_start)

            -- Count current requests in window
            local count = redis.call('ZCARD', key)

            if count < limit then
                -- Add current request with timestamp as score
                redis.call('ZADD', key, now, request_id)
                redis.call('PEXPIRE', key, ttl)
                return {1, count + 1}   -- allowed=1, new count
            else
                redis.call('PEXPIRE', key, ttl)
                return {0, count}        -- allowed=0, current count
            end";

        var result = await _redis.ScriptEvaluateAsync(script,
            new RedisKey[] { key },
            new RedisValue[]
            {
                nowMs,
                windowStartMs,
                limit,
                (long)window.TotalMilliseconds,
                $"{nowMs}:{Guid.NewGuid():N}" // Unique member (score=nowMs)
            });

        var values = (RedisResult[])result!;
        bool allowed = (long)values[0] == 1;
        long count = (long)values[1];

        return new RateLimitResult(
            allowed, count,
            Math.Max(0, limit - count),
            limit,
            DateTimeOffset.UtcNow + window);
    }
}
```

---

## Sliding Window Counter (Hybrid)

> **Mental Model:** The best of both worlds — use two fixed windows (current + previous) and calculate overlap.
> Memory: O(1). Accuracy: ~99% (linear interpolation).

```csharp
// WHY: Most production rate limiters use this — Cloudflare, GitHub, etc.
// Formula: count = prev_window_count * (1 - elapsed_in_current/window_size) + current_count
public class SlidingWindowCounterRateLimiter
{
    private readonly IDatabase _redis;

    public async Task<RateLimitResult> CheckAsync(
        string identifier,
        string endpoint,
        int limit,
        TimeSpan window)
    {
        long windowSizeMs = (long)window.TotalMilliseconds;
        long nowMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        long currentWindowId = nowMs / windowSizeMs;
        long prevWindowId = currentWindowId - 1;

        string currentKey = $"ratelimit:sw:{endpoint}:{identifier}:{currentWindowId}";
        string prevKey = $"ratelimit:sw:{endpoint}:{identifier}:{prevWindowId}";

        const string script = @"
            local curr_key = KEYS[1]
            local prev_key = KEYS[2]
            local limit = tonumber(ARGV[1])
            local window_ms = tonumber(ARGV[2])
            local now_ms = tonumber(ARGV[3])
            local window_id = tonumber(ARGV[4])

            -- Get counts from both windows
            local curr_count = tonumber(redis.call('GET', curr_key) or 0)
            local prev_count = tonumber(redis.call('GET', prev_key) or 0)

            -- How far into the current window are we? (0.0 to 1.0)
            local elapsed_in_window = (now_ms % window_ms) / window_ms

            -- Weighted count: previous window contributes less as current window fills
            local weighted_count = prev_count * (1 - elapsed_in_window) + curr_count

            if weighted_count < limit then
                -- Increment current window counter
                local new_count = redis.call('INCR', curr_key)
                redis.call('PEXPIRE', curr_key, window_ms * 2)
                return {1, math.floor(weighted_count + 1), new_count}
            else
                return {0, math.floor(weighted_count), curr_count}
            end";

        var result = await _redis.ScriptEvaluateAsync(script,
            new RedisKey[] { currentKey, prevKey },
            new RedisValue[]
            {
                limit,
                windowSizeMs,
                nowMs,
                currentWindowId
            });

        var values = (RedisResult[])result!;
        bool allowed = (long)values[0] == 1;
        long weightedCount = (long)values[1];

        return new RateLimitResult(
            allowed,
            weightedCount,
            Math.Max(0, limit - weightedCount),
            limit,
            DateTimeOffset.UtcNow + TimeSpan.FromMilliseconds(windowSizeMs - (nowMs % windowSizeMs)));
    }
}
```

---

## Token Bucket

> **Mental Model:** A bucket fills with tokens at a fixed rate (refill rate).
> Each request consumes a token. If the bucket is empty, reject or wait.
> Allows bursts up to bucket capacity, then smooths to refill rate.

```csharp
// WHY: Token bucket is ideal for APIs — allows short bursts while enforcing sustained rate
public class TokenBucketRateLimiter
{
    private readonly IDatabase _redis;

    public async Task<RateLimitResult> CheckAsync(
        string identifier,
        string endpoint,
        int capacity,       // max tokens (burst size)
        double refillRate,  // tokens per second
        double tokensPerRequest = 1)
    {
        string key = $"ratelimit:tokenbucket:{endpoint}:{identifier}";
        long nowMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        // WHY: Lua script ensures atomic read-modify-write
        const string script = @"
            local key = KEYS[1]
            local now = tonumber(ARGV[1])
            local capacity = tonumber(ARGV[2])
            local refill_rate = tonumber(ARGV[3])   -- tokens per millisecond
            local tokens_per_req = tonumber(ARGV[4])
            local ttl = tonumber(ARGV[5])

            local data = redis.call('HMGET', key, 'tokens', 'last_refill')
            local tokens = tonumber(data[1] or capacity)
            local last_refill = tonumber(data[2] or now)

            -- Calculate tokens to add since last refill
            local elapsed_ms = now - last_refill
            local new_tokens = elapsed_ms * refill_rate
            tokens = math.min(capacity, tokens + new_tokens)

            local allowed = 0
            if tokens >= tokens_per_req then
                tokens = tokens - tokens_per_req
                allowed = 1
            end

            -- Save updated state
            redis.call('HMSET', key, 'tokens', tokens, 'last_refill', now)
            redis.call('PEXPIRE', key, ttl)

            return {allowed, math.floor(tokens)}";

        double refillRatePerMs = refillRate / 1000.0; // Convert to per-millisecond
        long ttlMs = (long)(capacity / refillRate * 2 * 1000); // 2x fill time

        var result = await _redis.ScriptEvaluateAsync(script,
            new RedisKey[] { key },
            new RedisValue[]
            {
                nowMs,
                capacity,
                refillRatePerMs,
                tokensPerRequest,
                ttlMs
            });

        var values = (RedisResult[])result!;
        bool allowed = (long)values[0] == 1;
        long remaining = (long)values[1];

        return new RateLimitResult(
            allowed, capacity - remaining, remaining, capacity,
            DateTimeOffset.UtcNow.AddSeconds(tokensPerRequest / refillRate));
    }
}
```

---

## Leaky Bucket

```csharp
// WHY: Leaky bucket enforces strict output rate — no bursts allowed
// Requests queue up; the bucket "leaks" at a fixed rate
// Best for: payment processing, external API calls with strict rate limits

public class LeakyBucketRateLimiter
{
    private readonly IDatabase _redis;

    public async Task<RateLimitResult> CheckAsync(
        string identifier,
        string endpoint,
        int capacity,      // max queue size
        double leakRate)   // requests processed per second
    {
        string key = $"ratelimit:leaky:{endpoint}:{identifier}";
        long nowMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        const string script = @"
            local key = KEYS[1]
            local now = tonumber(ARGV[1])
            local capacity = tonumber(ARGV[2])
            local leak_rate = tonumber(ARGV[3])  -- per millisecond
            local ttl = tonumber(ARGV[4])

            local data = redis.call('HMGET', key, 'level', 'last_leak')
            local level = tonumber(data[1] or 0)
            local last_leak = tonumber(data[2] or now)

            -- Calculate how much has leaked since last check
            local elapsed = now - last_leak
            local leaked = elapsed * leak_rate
            level = math.max(0, level - leaked)

            local allowed = 0
            if level < capacity then
                level = level + 1
                allowed = 1
            end

            redis.call('HMSET', key, 'level', level, 'last_leak', now)
            redis.call('PEXPIRE', key, ttl)

            return {allowed, math.floor(level)}";

        var result = await _redis.ScriptEvaluateAsync(script,
            new RedisKey[] { key },
            new RedisValue[]
            {
                nowMs,
                capacity,
                leakRate / 1000.0,
                (long)(capacity / leakRate * 2 * 1000)
            });

        var values = (RedisResult[])result!;
        bool allowed = (long)values[0] == 1;
        long level = (long)values[1];

        return new RateLimitResult(
            allowed, level, capacity - level, capacity, DateTimeOffset.UtcNow);
    }
}
```

---

## ASP.NET Core Rate Limiter + Redis

```csharp
// .NET 7+ has built-in rate limiting middleware
// Use Redis-backed custom policy for distributed (multi-pod) rate limiting

// ── Program.cs ─────────────────────────────────────────────────────────
builder.Services.AddRateLimiter(options =>
{
    options.OnRejected = async (context, ct) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
        context.HttpContext.Response.Headers.RetryAfter =
            context.Lease.TryGetMetadata(MetadataName.RetryAfterDelta, out var delay)
            ? ((int)delay.TotalSeconds).ToString()
            : "60";

        await context.HttpContext.Response.WriteAsJsonAsync(new
        {
            error = "Too many requests",
            retryAfter = context.HttpContext.Response.Headers.RetryAfter
        }, ct);
    };

    // Fixed window: 100 requests per minute per IP
    options.AddPolicy("api", httpContext =>
    {
        var ipAddress = httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return RateLimitPartition.GetFixedWindowLimiter(ipAddress, _ =>
            new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 2 // Queue up to 2 extra requests
            });
    });

    // Stricter: 5 login attempts per 15 minutes per IP
    options.AddPolicy("login", httpContext =>
    {
        var ipAddress = httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return RateLimitPartition.GetSlidingWindowLimiter(ipAddress, _ =>
            new SlidingWindowRateLimiterOptions
            {
                PermitLimit = 5,
                Window = TimeSpan.FromMinutes(15),
                SegmentsPerWindow = 3 // 5 minute segments
            });
    });
});

app.UseRateLimiter();

// Apply policies to endpoints
app.MapPost("/auth/login", LoginHandler).RequireRateLimiting("login");
app.MapGet("/api/products", GetProducts).RequireRateLimiting("api");
```

> **Note:** ASP.NET Core's built-in rate limiter is in-process only. For distributed rate limiting across pods, use Redis-backed middleware shown below.

---

## Middleware Implementation

```csharp
// WHY: Custom middleware provides distributed rate limiting backed by Redis
// Works across multiple app instances (pods in AKS)

public class RedisRateLimitMiddleware
{
    private readonly RequestDelegate _next;
    private readonly SlidingWindowCounterRateLimiter _rateLimiter;
    private readonly RateLimitOptions _options;

    public async Task InvokeAsync(HttpContext context)
    {
        var identifier = GetIdentifier(context);
        var policy = GetPolicy(context.Request.Path);

        var result = await _rateLimiter.CheckAsync(
            identifier,
            context.Request.Path.Value!,
            policy.Limit,
            policy.Window);

        // WHY: Always add rate limit headers so clients can implement backoff
        context.Response.Headers["X-RateLimit-Limit"] = result.Limit.ToString();
        context.Response.Headers["X-RateLimit-Remaining"] = result.Remaining.ToString();
        context.Response.Headers["X-RateLimit-Reset"] = result.ResetsAt.ToUnixTimeSeconds().ToString();

        if (!result.IsAllowed)
        {
            context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            context.Response.Headers["Retry-After"] =
                ((int)(result.ResetsAt - DateTimeOffset.UtcNow).TotalSeconds).ToString();

            await context.Response.WriteAsJsonAsync(new
            {
                error = "Rate limit exceeded",
                limit = result.Limit,
                retryAfterSeconds = (int)(result.ResetsAt - DateTimeOffset.UtcNow).TotalSeconds
            });
            return;
        }

        await _next(context);
    }

    private string GetIdentifier(HttpContext context)
    {
        // WHY: Prefer authenticated user ID over IP (users behind NAT share an IP)
        if (context.User.Identity?.IsAuthenticated == true)
            return $"user:{context.User.FindFirst("sub")?.Value}";

        // Check for API key
        if (context.Request.Headers.TryGetValue("X-Api-Key", out var apiKey))
            return $"apikey:{apiKey}";

        // Fall back to IP
        return $"ip:{context.Connection.RemoteIpAddress}";
    }

    private (int Limit, TimeSpan Window) GetPolicy(string path) => path switch
    {
        var p when p.StartsWith("/auth") => (5, TimeSpan.FromMinutes(15)),
        var p when p.StartsWith("/api/payments") => (10, TimeSpan.FromMinutes(1)),
        _ => (100, TimeSpan.FromMinutes(1))
    };
}
```

---

## Per-User, Per-IP, Per-Endpoint Policies

```csharp
// WHY: Different identifiers and limits for different scenarios
public class MultiTierRateLimiter
{
    private readonly SlidingWindowCounterRateLimiter _rateLimiter;

    public async Task<bool> CheckAllTiersAsync(HttpContext context)
    {
        var ip = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        var userId = context.User.FindFirst("sub")?.Value;
        var endpoint = context.Request.Path.Value!;

        // ── Tier 1: Global IP limit (prevent DDoS) ────────────────────
        var ipResult = await _rateLimiter.CheckAsync(
            ip, "global", limit: 1000, window: TimeSpan.FromMinutes(1));
        if (!ipResult.IsAllowed) return false;

        // ── Tier 2: Per-user authenticated limit ──────────────────────
        if (userId is not null)
        {
            var userResult = await _rateLimiter.CheckAsync(
                userId, endpoint, limit: 200, window: TimeSpan.FromMinutes(1));
            if (!userResult.IsAllowed) return false;
        }

        // ── Tier 3: Endpoint-specific limit ───────────────────────────
        // WHY: Expensive endpoints get stricter limits
        if (endpoint.Contains("export") || endpoint.Contains("report"))
        {
            var key = userId ?? ip;
            var heavyResult = await _rateLimiter.CheckAsync(
                key, "heavy-endpoint", limit: 5, window: TimeSpan.FromHours(1));
            if (!heavyResult.IsAllowed) return false;
        }

        return true;
    }
}
```

---

## Rate Limit Headers (RFC 6585)

```csharp
// WHY: Standard headers let clients implement exponential backoff automatically
// RFC 6585 + Draft IETF ratelimit-headers

public static class RateLimitHeaderExtensions
{
    public static void AddRateLimitHeaders(
        this HttpResponse response, RateLimitResult result)
    {
        // Standard headers
        response.Headers["X-RateLimit-Limit"] = result.Limit.ToString();
        response.Headers["X-RateLimit-Remaining"] = result.Remaining.ToString();
        response.Headers["X-RateLimit-Reset"] = result.ResetsAt.ToUnixTimeSeconds().ToString();

        if (!result.IsAllowed)
        {
            // Retry-After in seconds (standard 429 header)
            var retryAfter = Math.Max(1, (int)(result.ResetsAt - DateTimeOffset.UtcNow).TotalSeconds);
            response.Headers["Retry-After"] = retryAfter.ToString();
        }
    }
}
```

---

## Production Patterns

```
✅ Lua Scripts
   □ All rate limit operations use Lua for atomicity
   □ Scripts pre-loaded using SCRIPT LOAD for performance

✅ Key Design
   □ Include time window in key for automatic cleanup
   □ Set TTL on every key (2x window size for safety)
   □ Namespace keys: ratelimit:{algorithm}:{endpoint}:{id}:{window}

✅ Error Handling
   □ Redis unavailable → fail open (allow request) for availability
   □ Log Redis failures — don't crash the app
   □ Circuit breaker around Redis calls for rate limiter

✅ Headers
   □ Always return X-RateLimit-* headers on every response
   □ Return Retry-After on 429 responses
   □ Document rate limits in API spec

✅ Monitoring
   □ Alert when 429 rate exceeds threshold (attack or misconfigured client)
   □ Track top offending IPs/users
   □ Dashboard: requests/sec, 429/sec, rate limit key counts

✅ Performance
   □ Rate limiter adds <1ms overhead with local Redis
   □ Pipeline multiple limit checks (IP + user + endpoint) when possible
   □ Consider in-process cache layer for global limits (read heavy)
```

---

*Next:* [06-Redis-Streams.md](06-Redis-Streams.md) — Redis Streams as durable message queue, consumer groups, XADD/XREADGROUP in .NET
