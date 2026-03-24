# System Design Problems — .NET Deep Dive
### Real Interview Problems from Indian Product & Service Companies
### Single Source of Truth for Interview Preparation

> **Profile**: Senior .NET Architect | 12+ yrs | Microservices, Azure, DDD, Clean Architecture
> **Scope**: Problems actually asked at Flipkart, Razorpay, PhonePe, Paytm, Swiggy, Zomato, Ola, Meesho, CRED, Groww, Zerodha + GCC/Service Companies (TCS, Infosys, Wipro, HCL, Cognizant, Capgemini)

---

## Table of Contents

| # | Problem | Companies | Difficulty |
|---|---------|-----------|------------|
| [01](#problem-01-url-shortener) | URL Shortener (TinyURL) | Universal | Medium |
| [02](#problem-02-rate-limiter) | Distributed Rate Limiter | Razorpay, PhonePe, All APIs | Medium |
| [03](#problem-03-notification-system) | Multi-Channel Notification System | Paytm, PhonePe, All Fintech | Medium-Hard |
| [04](#problem-04-payment-wallet) | Digital Payment Wallet | Razorpay, PhonePe, Paytm, CRED | Hard |
| [05](#problem-05-food-delivery) | Food Ordering + Real-time Tracking | Swiggy, Zomato, Blinkit | Hard |
| [06](#problem-06-chat-system) | Real-time Chat / Messaging | WhatsApp-like, All companies | Hard |
| [07](#problem-07-ecommerce-orders) | E-commerce Order Management | Flipkart, Meesho, Myntra | Hard |
| [08](#problem-08-cab-booking) | Cab Booking / Ride Sharing | Ola, Rapido | Hard |
| [09](#problem-09-search-autocomplete) | Search Autocomplete / Typeahead | All e-commerce | Medium |
| [10](#problem-10-job-scheduler) | Distributed Job / Task Scheduler | GCC, HCL, TCS, Infosys | Medium-Hard |
| [11](#problem-11-auth-service) | Auth & Authorization Service (SSO/JWT) | All companies | Medium |
| [12](#problem-12-inventory-system) | Inventory Management with Reservations | Flipkart, Meesho, Pharmeasy | Hard |
| [13](#problem-13-leaderboard) | Leaderboard / Real-time Ranking System | Groww, Dream11, MPL, CRED, Zerodha | Medium |
| [14](#problem-14-api-gateway) | API Gateway / Backend for Frontend (BFF) | TCS, Infosys, HCL, Flipkart platform | Medium-Hard |
| [15](#problem-15-file-storage) | File / Document Storage System | Freshworks, Zoho, Healthcare GCCs | Medium-Hard |

---

## How to Use This Guide in an Interview

```
FRAMEWORK: RECDSD
R  – Requirements (functional + non-functional)
E  – Estimates (QPS, storage, bandwidth)
C  – Core API design
D  – Data model (DB choice + schema)
S  – System design (architecture diagram narration)
D  – Deep dives (bottlenecks, trade-offs, failure scenarios)
```

**Time box**: 45-min interview → 5 min req, 5 min est, 5 min API, 10 min design, 20 min deep-dive
**Always ask**: "Should I optimize for read or write?", "What's the acceptable latency SLA?", "Eventual consistency OK?"

---

---

# Problem 01: URL Shortener

## Asked At
Universal — Razorpay screening, Flipkart, Infosys GCC, HCL, CRED take-homes

---

## Requirements

### Functional
- Given a long URL, generate a short URL (e.g., `short.ly/aB3xK`)
- Redirect short URL → original URL
- Optional: custom alias, expiry TTL, analytics (click count, geo)

### Non-Functional
- 100M URLs created/day, 1B redirects/day (10:1 read-heavy)
- Redirect latency < 10ms (P99)
- 99.99% availability for redirects
- URL must be unique, collision-free

---

## Capacity Estimation

```
Writes:  100M/day  →  ~1,160 writes/sec
Reads:   1B/day    →  ~11,600 reads/sec  (10:1)

URL record: 500 bytes avg
Storage/day: 100M × 500B = 50 GB/day
5 years: 50 GB × 365 × 5 ≈ 91 TB

Short code: 6 chars from [a-z A-Z 0-9] = 62^6 = 56 billion combos → sufficient
```

---

## Architecture

```
┌──────────┐    POST /shorten     ┌───────────────┐    generate    ┌──────────────┐
│  Client  │ ──────────────────→  │  API Gateway  │ ─────────────→ │ URL Service  │
│          │                      │  (Rate Limit) │               │  (.NET 10)   │
│          │    GET /{code}        └───────────────┘               └──────┬───────┘
│          │ ──────────────────→        │                                 │
└──────────┘                            │                          ┌──────┴───────┐
                                        │                          │   Redis      │
                                   ┌────▼────┐                    │   Cache      │
                                   │Redirect │ ←── cache hit ─────│  (hot URLs)  │
                                   │ Service │                    └──────────────┘
                                   └────┬────┘
                                        │ cache miss
                                   ┌────▼──────────┐
                                   │  PostgreSQL   │
                                   │  (URL store)  │
                                   └───────────────┘
                                        │
                                   ┌────▼──────────┐
                                   │  Kafka        │ → Analytics Consumer
                                   │  (click events│
                                   └───────────────┘
```

---

## Database Schema

```sql
CREATE TABLE urls (
    short_code      VARCHAR(10)  PRIMARY KEY,
    original_url    TEXT         NOT NULL,
    user_id         BIGINT,
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    expires_at      TIMESTAMPTZ,
    is_active       BOOLEAN      DEFAULT TRUE,
    click_count     BIGINT       DEFAULT 0     -- eventual, updated via Kafka consumer
);

CREATE INDEX idx_urls_user_id    ON urls(user_id);
CREATE INDEX idx_urls_expires_at ON urls(expires_at) WHERE is_active = TRUE;
```

---

## Core API Design

```
POST   /api/v1/urls          { longUrl, alias?, ttlDays? }  → { shortUrl, code, expiresAt }
GET    /{code}               → 301/302 Redirect
GET    /api/v1/urls/{code}   → URL metadata + stats
DELETE /api/v1/urls/{code}   → deactivate
```

---

## .NET Implementation

### ID Generation — Base62 Encoding

```csharp
// UrlShortenerService.cs
public class UrlShortenerService
{
    private const string Alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private const int CodeLength = 6;

    private readonly IUrlRepository _repo;
    private readonly IDistributedCache _cache;
    private readonly IEventPublisher _events;

    public async Task<ShortenResult> ShortenAsync(ShortenRequest request)
    {
        // 1. Validate
        if (!Uri.IsWellFormedUriString(request.LongUrl, UriKind.Absolute))
            throw new ValidationException("Invalid URL");

        // 2. Check if custom alias requested
        var code = request.Alias ?? await GenerateUniqueCodeAsync();

        // 3. Persist
        var entity = new UrlEntity
        {
            ShortCode   = code,
            OriginalUrl = request.LongUrl,
            UserId      = request.UserId,
            ExpiresAt   = request.TtlDays.HasValue
                          ? DateTime.UtcNow.AddDays(request.TtlDays.Value)
                          : null,
            IsActive    = true
        };

        await _repo.InsertAsync(entity);

        // 4. Warm cache immediately (avoids thundering herd on first access)
        await _cache.SetStringAsync(
            $"url:{code}",
            request.LongUrl,
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
            }
        );

        return new ShortenResult { ShortCode = code, ShortUrl = $"https://short.ly/{code}" };
    }

    private async Task<string> GenerateUniqueCodeAsync()
    {
        // Strategy: Snowflake-like unique ID → Base62 encode
        // Collision rate is near-zero; handle if needed with retry
        const int maxAttempts = 3;
        for (int i = 0; i < maxAttempts; i++)
        {
            var code = GenerateBase62Code();
            if (!await _repo.ExistsAsync(code))
                return code;
        }
        throw new Exception("Failed to generate unique code after retries");
    }

    private static string GenerateBase62Code()
    {
        // Use crypto-random for unpredictability (prevents enumeration attacks)
        var bytes = new byte[8];
        RandomNumberGenerator.Fill(bytes);
        var num = Math.Abs(BitConverter.ToInt64(bytes, 0));

        var sb = new StringBuilder();
        while (sb.Length < CodeLength)
        {
            sb.Insert(0, Alphabet[(int)(num % 62)]);
            num /= 62;
        }
        return sb.ToString()[..CodeLength];
    }
}
```

### Redirect Controller (Critical Path — Must Be Fast)

```csharp
// RedirectController.cs
[ApiController]
public class RedirectController : ControllerBase
{
    private readonly IDistributedCache _cache;
    private readonly IUrlRepository _repo;
    private readonly IEventPublisher _events;

    [HttpGet("/{code}")]
    public async Task<IActionResult> Redirect(string code)
    {
        // 1. Cache lookup first (sub-millisecond)
        var cached = await _cache.GetStringAsync($"url:{code}");
        if (cached is not null)
        {
            // Fire-and-forget analytics (don't block redirect)
            _ = _events.PublishAsync("url.clicked", new ClickEvent
            {
                Code = code,
                Timestamp = DateTime.UtcNow,
                UserAgent = Request.Headers.UserAgent.ToString(),
                IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString()
            });

            return RedirectPermanent(cached); // 301 = browser caches, saves future hits
        }

        // 2. DB fallback
        var url = await _repo.GetByCodeAsync(code);
        if (url is null || !url.IsActive)
            return NotFound();

        if (url.ExpiresAt.HasValue && url.ExpiresAt < DateTime.UtcNow)
        {
            await _repo.DeactivateAsync(code); // lazy cleanup
            return Gone(); // 410
        }

        // 3. Repopulate cache
        await _cache.SetStringAsync($"url:{code}", url.OriginalUrl,
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
            });

        _ = _events.PublishAsync("url.clicked", new ClickEvent { Code = code });

        return RedirectPermanent(url.OriginalUrl);
    }

    private IActionResult Gone() => StatusCode(410, "URL has expired");
}
```

### Analytics Consumer (Kafka → DB)

```csharp
// ClickAnalyticsConsumer.cs — runs as BackgroundService
public class ClickAnalyticsConsumer : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        using var consumer = new ConsumerBuilder<string, ClickEvent>(_config).Build();
        consumer.Subscribe("url.clicked");

        // Batch updates to avoid per-click DB writes
        var batch = new List<ClickEvent>(capacity: 100);
        var timer = new PeriodicTimer(TimeSpan.FromSeconds(5));

        while (!ct.IsCancellationRequested)
        {
            var result = consumer.Consume(TimeSpan.FromMilliseconds(100));
            if (result?.Message is not null)
                batch.Add(result.Message.Value);

            if (batch.Count >= 100 || await timer.WaitForNextTickAsync(ct))
            {
                if (batch.Count > 0)
                {
                    // Bulk UPDATE using group-by count
                    await _repo.BulkIncrementClicksAsync(
                        batch.GroupBy(e => e.Code)
                             .Select(g => (g.Key, g.Count()))
                             .ToList()
                    );
                    batch.Clear();
                }
            }
        }
    }
}
```

---

## Trade-offs & Design Decisions

| Decision | Option A | Option B | Choice & Why |
|----------|----------|----------|--------------|
| ID generation | DB auto-increment | Base62 random | **Base62 random** — no sequential enumeration, works distributed |
| Redirect HTTP code | 301 (permanent) | 302 (temporary) | **302** if analytics needed (browser won't cache, all hits reach server); 301 if cost matters |
| Cache eviction | LRU | TTL-based | **TTL 24h** — 80% of traffic hits top 20% URLs (Pareto); TTL simple and effective |
| DB | MySQL | PostgreSQL | Either; **PostgreSQL** for JSONB if storing analytics metadata |
| Code collisions | Retry | Pre-generated pool | **Retry** — collision at 6-char Base62 with 100M entries is <0.0001% |

---

## Interview Traps & What Interviewers Check

1. **301 vs 302** — The redirect code choice reveals whether you understand analytics vs cost
2. **Thundering herd** — If cache expires, 1000 requests hit DB simultaneously for same URL → use cache locking / probabilistic early expiry
3. **Custom alias conflicts** — What if two users want same alias? → UNIQUE constraint + 409 Conflict response
4. **Sequential ID attack** — Auto-increment allows enumeration → Base62 random prevents this
5. **Deletion semantics** — Hard delete vs soft delete (is_active flag) for audit/compliance

---

---

# Problem 02: Distributed Rate Limiter

## Asked At
Razorpay (mandatory), PhonePe, PayU, all API platform teams, Infosys GCC

---

## Requirements

### Functional
- Limit requests per user/API key (e.g., 1000 req/minute)
- Multiple strategies: per-user, per-IP, per-endpoint, per-tenant
- Return 429 Too Many Requests with Retry-After header when exceeded
- Allow burst: 200 req/sec burst, then throttle

### Non-Functional
- Decision latency < 5ms (must not add perceptible delay)
- Distributed — same limit applies across all API server instances
- 99.999% accuracy (can't double-charge payments)
- Graceful degradation: if Redis fails, fail-open or fail-closed (configurable)

---

## Algorithms Compared

```
┌────────────────────┬───────────────┬──────────────┬─────────────────────────────────┐
│ Algorithm          │ Memory        │ Accuracy     │ Burst Handling                  │
├────────────────────┼───────────────┼──────────────┼─────────────────────────────────┤
│ Fixed Window       │ O(1)          │ Edge spikes  │ 2x burst at window boundary     │
│ Sliding Window Log │ O(requests)   │ Exact        │ Accurate, memory intensive      │
│ Sliding Window     │ O(1)          │ ~approx      │ Good balance                    │
│ Counter (hybrid)   │               │              │                                 │
│ Token Bucket       │ O(1)          │ Exact        │ Best — natural burst support    │
│ Leaky Bucket       │ O(1)          │ Exact        │ Smooth output, no burst         │
└────────────────────┴───────────────┴──────────────┴─────────────────────────────────┘
```

**Production choice**: Token Bucket (natural burst + refill) or Sliding Window Counter (Redis-friendly)

---

## Architecture

```
                        ┌──────────────────────────────┐
 Request                │       API Gateway /           │
──────────────────────→ │   ASP.NET Core Middleware     │
                        │                               │
                        │  1. Extract identity key      │
                        │  2. Call RateLimiterService   │
                        │  3. Allow / 429               │
                        └──────────────┬────────────────┘
                                       │
                              ┌────────▼────────┐
                              │  Redis Cluster  │
                              │  (atomic Lua)   │
                              └─────────────────┘
                                       │ fallback
                              ┌────────▼────────┐
                              │ In-Memory Local │
                              │ (fail-open mode)│
                              └─────────────────┘
```

---

## .NET Implementation

### Token Bucket — Redis Lua Script (Atomic)

```csharp
// TokenBucketRateLimiter.cs
public class TokenBucketRateLimiter : IRateLimiter
{
    private readonly IConnectionMultiplexer _redis;

    // Lua script executes atomically on Redis (no race conditions)
    private const string LuaScript = @"
        local key        = KEYS[1]
        local capacity   = tonumber(ARGV[1])
        local refillRate = tonumber(ARGV[2])   -- tokens per second
        local requested  = tonumber(ARGV[3])
        local now        = tonumber(ARGV[4])   -- Unix ms

        local bucket = redis.call('HMGET', key, 'tokens', 'last_refill')
        local tokens     = tonumber(bucket[1]) or capacity
        local lastRefill = tonumber(bucket[2]) or now

        -- Calculate tokens to add based on elapsed time
        local elapsed = math.max(0, now - lastRefill) / 1000  -- seconds
        local newTokens = math.min(capacity, tokens + elapsed * refillRate)

        if newTokens >= requested then
            newTokens = newTokens - requested
            redis.call('HMSET', key, 'tokens', newTokens, 'last_refill', now)
            redis.call('EXPIRE', key, 3600)
            return 1  -- allowed
        else
            redis.call('HMSET', key, 'tokens', newTokens, 'last_refill', now)
            redis.call('EXPIRE', key, 3600)
            return 0  -- denied
        end
    ";

    public async Task<RateLimitResult> IsAllowedAsync(RateLimitContext context)
    {
        var key = BuildKey(context);
        var db  = _redis.GetDatabase();

        try
        {
            var result = await db.ScriptEvaluateAsync(
                LuaScript,
                new RedisKey[]  { key },
                new RedisValue[]
                {
                    context.Config.Capacity,    // max tokens
                    context.Config.RefillRate,  // tokens/sec
                    1,                          // tokens requested
                    DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
                }
            );

            return new RateLimitResult
            {
                IsAllowed   = (int)result == 1,
                RetryAfterMs = (int)result == 0 ? CalculateRetryAfter(context) : 0
            };
        }
        catch (RedisException ex)
        {
            // Fail-open: log and allow (don't block payments due to Redis outage)
            _logger.LogError(ex, "Redis unavailable for rate limiting — failing open");
            return new RateLimitResult { IsAllowed = true };
        }
    }

    private static string BuildKey(RateLimitContext ctx)
        => $"rl:{ctx.Strategy}:{ctx.Identifier}";
        // e.g., "rl:api_key:rz_live_xxx", "rl:ip:192.168.1.1", "rl:tenant:acme"
}
```

### Sliding Window Counter (Alternative — simpler Redis ops)

```csharp
public class SlidingWindowRateLimiter : IRateLimiter
{
    public async Task<RateLimitResult> IsAllowedAsync(RateLimitContext context)
    {
        var db  = _redis.GetDatabase();
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var windowMs = context.Config.WindowSeconds * 1000;
        var key = $"sw:{context.Identifier}";

        // Use Redis Sorted Set: score = timestamp, member = unique request ID
        var pipe = db.CreateTransaction();

        _ = pipe.SortedSetRemoveRangeByScoreAsync(key, 0, now - windowMs); // prune old
        _ = pipe.SortedSetAddAsync(key, Guid.NewGuid().ToString(), now);   // add current
        var countTask = pipe.SortedSetLengthAsync(key);
        _ = pipe.KeyExpireAsync(key, TimeSpan.FromSeconds(context.Config.WindowSeconds * 2));

        await pipe.ExecuteAsync();

        var count = await countTask;
        return new RateLimitResult
        {
            IsAllowed    = count <= context.Config.Limit,
            CurrentCount = (int)count,
            Limit        = context.Config.Limit
        };
    }
}
```

### ASP.NET Core Middleware

```csharp
// RateLimitMiddleware.cs
public class RateLimitMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IRateLimiter _limiter;
    private readonly RateLimitOptions _options;

    public async Task InvokeAsync(HttpContext context)
    {
        var identifier = ExtractIdentifier(context); // API key or IP
        var config     = _options.GetConfigFor(context.Request.Path);

        var result = await _limiter.IsAllowedAsync(new RateLimitContext
        {
            Identifier = identifier,
            Strategy   = _options.Strategy,
            Config     = config
        });

        // Always add headers (good API practice)
        context.Response.Headers["X-RateLimit-Limit"]     = config.Limit.ToString();
        context.Response.Headers["X-RateLimit-Remaining"] =
            Math.Max(0, config.Limit - result.CurrentCount).ToString();
        context.Response.Headers["X-RateLimit-Reset"]     =
            DateTimeOffset.UtcNow.AddSeconds(config.WindowSeconds).ToUnixTimeSeconds().ToString();

        if (!result.IsAllowed)
        {
            context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            context.Response.Headers["Retry-After"] = (result.RetryAfterMs / 1000).ToString();
            await context.Response.WriteAsJsonAsync(new
            {
                error   = "Rate limit exceeded",
                retryIn = $"{result.RetryAfterMs}ms"
            });
            return;
        }

        await _next(context);
    }

    private string ExtractIdentifier(HttpContext ctx)
    {
        // Priority: API key > JWT sub > IP
        if (ctx.Request.Headers.TryGetValue("X-API-Key", out var key))
            return $"apikey:{key}";
        if (ctx.User.Identity?.IsAuthenticated == true)
            return $"user:{ctx.User.FindFirstValue(ClaimTypes.NameIdentifier)}";
        return $"ip:{ctx.Connection.RemoteIpAddress}";
    }
}
```

### Registration & Config

```csharp
// Program.cs
builder.Services.Configure<RateLimitOptions>(config =>
{
    config.Strategy = RateLimitStrategy.TokenBucket;
    config.Rules = new()
    {
        ["/api/v1/payments/*"] = new() { Capacity = 100, RefillRate = 10, WindowSeconds = 60 },
        ["/api/v1/search/*"]   = new() { Capacity = 500, RefillRate = 50, WindowSeconds = 60 },
        ["default"]            = new() { Capacity = 1000, RefillRate = 100, WindowSeconds = 60 }
    };
});

builder.Services.AddSingleton<IRateLimiter, TokenBucketRateLimiter>();
app.UseMiddleware<RateLimitMiddleware>();
```

---

## Trade-offs

| Concern | Decision | Reasoning |
|---------|----------|-----------|
| Redis atomicity | Lua script | EVAL runs atomically, no WATCH/MULTI overhead |
| Redis failure | Fail-open | Payment APIs prefer availability over strict rate control |
| Per-tenant limits | Different keys | `rl:tenant:acme:endpoint:payments` |
| Distributed consensus | Accept ~1% inaccuracy | Perfect counting needs distributed locks; not worth it |
| Memory per user | ~200 bytes/user in Redis | 10M users = 2 GB — acceptable |

---

## What Interviewers Check

1. **Atomicity in Redis** — Must explain why Lua script vs INCR + EXPIRE (race condition with two commands)
2. **Algorithm choice trade-offs** — Fixed window edge case (2x burst at boundaries)
3. **Multi-region** — How to rate-limit across regions? (Sticky sessions or accept per-region limits)
4. **Burst vs sustained** — Token bucket elegantly handles both

---

---

# Problem 03: Multi-Channel Notification System

## Asked At
Paytm, PhonePe, Razorpay, Swiggy, Zomato, Flipkart — nearly universal in product companies

---

## Requirements

### Functional
- Send notifications via: Email, SMS, Push (FCM/APNs), WhatsApp, In-App
- Template-based with personalization (name, amount, OTP)
- Priority: Critical (OTP, payment) > High (order update) > Normal (marketing)
- Scheduling: immediate + scheduled future
- User preferences: opt-in/opt-out per channel
- Deduplication: don't send same notification twice

### Non-Functional
- Critical notifications: < 2s end-to-end
- Throughput: 1M notifications/min (marketing blasts)
- At-least-once delivery with idempotency
- Delivery receipts and failure tracking

---

## Architecture

```
┌───────────────┐   event    ┌──────────────────┐
│  Order Svc    │ ─────────→ │                  │
│  Payment Svc  │ ─────────→ │  Notification    │     Priority Queues
│  Promo Svc    │ ─────────→ │  Orchestrator    │ ──→ [Critical]  → Email/SMS Workers
└───────────────┘            │  (.NET Worker)   │ ──→ [High]      → Push Workers
                             │                  │ ──→ [Normal]    → WhatsApp Workers
                             └────────┬─────────┘
                                      │
                             ┌────────▼─────────┐
                             │  Kafka Topics     │
                             │  notification.*   │
                             └────────┬─────────┘
                                      │
                      ┌───────────────┼───────────────┐
                      ▼               ▼               ▼
              ┌──────────────┐ ┌──────────────┐ ┌───────────────┐
              │ Email Worker │ │  SMS Worker  │ │  Push Worker  │
              │ (SendGrid)   │ │  (Twilio)    │ │  (Firebase)   │
              └──────┬───────┘ └──────┬───────┘ └───────┬───────┘
                     │                │                  │
                     └───────────────→┴←─────────────────┘
                                      │
                             ┌────────▼─────────┐
                             │  Notification DB  │
                             │  (delivery status)│
                             └──────────────────┘
```

---

## Database Schema

```sql
-- Notifications table
CREATE TABLE notifications (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key VARCHAR(128) UNIQUE NOT NULL,    -- prevents duplicates
    user_id         BIGINT       NOT NULL,
    template_id     VARCHAR(100) NOT NULL,
    channel         VARCHAR(20)  NOT NULL,            -- email/sms/push/whatsapp
    priority        SMALLINT     DEFAULT 2,           -- 1=critical, 2=high, 3=normal
    payload         JSONB        NOT NULL,             -- template variables
    status          VARCHAR(20)  DEFAULT 'pending',   -- pending/sent/failed/bounced
    scheduled_at    TIMESTAMPTZ,
    sent_at         TIMESTAMPTZ,
    failed_at       TIMESTAMPTZ,
    failure_reason  TEXT,
    retry_count     SMALLINT     DEFAULT 0,
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX idx_notifications_user    ON notifications(user_id);
CREATE INDEX idx_notifications_status  ON notifications(status) WHERE status = 'pending';
CREATE INDEX idx_notifications_sched   ON notifications(scheduled_at) WHERE scheduled_at IS NOT NULL;

-- User preferences
CREATE TABLE user_notification_prefs (
    user_id         BIGINT       NOT NULL,
    channel         VARCHAR(20)  NOT NULL,
    category        VARCHAR(50)  NOT NULL,           -- transactional/marketing/otp
    is_opted_in     BOOLEAN      DEFAULT TRUE,
    PRIMARY KEY (user_id, channel, category)
);
```

---

## .NET Implementation

### Notification Orchestrator

```csharp
// NotificationOrchestrator.cs
public class NotificationOrchestrator : INotificationOrchestrator
{
    private readonly IPreferenceService _prefs;
    private readonly ITemplateEngine    _templates;
    private readonly IKafkaProducer     _kafka;
    private readonly INotificationRepo  _repo;

    public async Task SendAsync(NotificationRequest request)
    {
        // 1. Idempotency check (prevents double-send on retry)
        if (await _repo.ExistsAsync(request.IdempotencyKey))
        {
            _logger.LogInformation("Duplicate notification skipped: {Key}", request.IdempotencyKey);
            return;
        }

        // 2. Determine effective channels (respect user preferences)
        var userPrefs   = await _prefs.GetAsync(request.UserId);
        var channels    = DetermineChannels(request, userPrefs);

        if (channels.Count == 0) return; // user opted out of all channels

        // 3. Render template
        var template    = await _templates.GetAsync(request.TemplateId);
        var rendered    = RenderTemplate(template, request.Variables);

        // 4. Persist notification record (before publishing — ensures we can track)
        var notifId = await _repo.CreateAsync(new NotificationEntity
        {
            IdempotencyKey = request.IdempotencyKey,
            UserId         = request.UserId,
            TemplateId     = request.TemplateId,
            Priority       = request.Priority,
            Payload        = request.Variables,
            Status         = NotificationStatus.Pending
        });

        // 5. Fan-out to per-channel Kafka topics
        foreach (var channel in channels)
        {
            var topic = GetTopic(channel, request.Priority);
            await _kafka.PublishAsync(topic, new ChannelNotification
            {
                NotificationId = notifId,
                Channel        = channel,
                Recipient      = GetRecipient(request.UserId, channel),
                Subject        = rendered.Subject,
                Body           = rendered.Body,
                ScheduledAt    = request.ScheduledAt
            });
        }
    }

    private static string GetTopic(Channel channel, Priority priority)
        => priority == Priority.Critical
           ? $"notification.critical.{channel.ToString().ToLower()}"
           : $"notification.{channel.ToString().ToLower()}";

    private List<Channel> DetermineChannels(NotificationRequest req, UserPrefs prefs)
    {
        return req.RequestedChannels
            .Where(c => prefs.IsOptedIn(c, req.Category) || req.Priority == Priority.Critical)
            // OTP/Critical always sent regardless of preferences (regulatory requirement)
            .ToList();
    }
}
```

### Generic Channel Worker (with Retry + Circuit Breaker)

```csharp
// ChannelWorker.cs — base class for Email/SMS/Push workers
public abstract class ChannelWorker<TMessage> : BackgroundService
{
    protected abstract Task<DeliveryResult> DeliverAsync(TMessage message, CancellationToken ct);
    protected abstract string Topic { get; }

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        using var consumer = BuildConsumer();
        consumer.Subscribe(Topic);

        var policy = Policy
            .Handle<ProviderException>()
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)),
                onRetry: (ex, delay, attempt, _) =>
                    _logger.LogWarning("Retry {Attempt} after {Delay}s: {Ex}", attempt, delay.TotalSeconds, ex.Message)
            );

        while (!ct.IsCancellationRequested)
        {
            var msg = consumer.Consume(ct);
            var notification = Deserialize(msg.Message.Value);

            try
            {
                var result = await policy.ExecuteAsync(() => DeliverAsync(notification, ct));

                await _repo.UpdateStatusAsync(notification.NotificationId,
                    result.IsSuccess ? NotificationStatus.Sent : NotificationStatus.Failed,
                    result.Error);

                consumer.Commit(msg);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to deliver notification {Id}", notification.NotificationId);
                await _repo.UpdateStatusAsync(notification.NotificationId,
                    NotificationStatus.Failed, ex.Message);

                // Dead letter: move to DLQ for manual investigation
                await _kafka.PublishAsync("notification.dlq", notification);
                consumer.Commit(msg); // commit to avoid infinite retry of undeliverable msgs
            }
        }
    }
}

// Email Worker
public class EmailWorker : ChannelWorker<ChannelNotification>
{
    protected override string Topic => "notification.email";

    protected override async Task<DeliveryResult> DeliverAsync(
        ChannelNotification msg, CancellationToken ct)
    {
        // SendGrid / AWS SES integration
        var response = await _sendGrid.SendEmailAsync(new SendGridMessage
        {
            From    = new EmailAddress("noreply@company.com"),
            To      = { new EmailAddress(msg.Recipient) },
            Subject = msg.Subject,
            HtmlContent = msg.Body
        }, ct);

        return new DeliveryResult
        {
            IsSuccess = response.IsSuccessStatusCode,
            Error     = response.IsSuccessStatusCode ? null : await response.Body.ReadAsStringAsync()
        };
    }
}
```

### Template Engine

```csharp
// TemplateEngine.cs — Handlebars-style templating
public class TemplateEngine : ITemplateEngine
{
    private readonly IMemoryCache _cache;
    private readonly ITemplateRepo _repo;

    public async Task<RenderedTemplate> RenderAsync(string templateId,
        Dictionary<string, object> variables)
    {
        var template = await _cache.GetOrCreateAsync($"tmpl:{templateId}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30);
            return await _repo.GetAsync(templateId);
        });

        // Simple variable substitution: {{name}}, {{amount}}, {{otp}}
        var subject = ReplacePlaceholders(template.SubjectTemplate, variables);
        var body    = ReplacePlaceholders(template.BodyTemplate, variables);

        return new RenderedTemplate { Subject = subject, Body = body };
    }

    private static string ReplacePlaceholders(string template, Dictionary<string, object> vars)
    {
        foreach (var (key, value) in vars)
            template = template.Replace($"{{{{{key}}}}}", value?.ToString() ?? string.Empty);
        return template;
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Fan-out strategy | Kafka per-channel topics | Allows independent scaling of Email vs SMS workers |
| Priority handling | Separate Kafka topics | Critical topic has dedicated consumer group with more partitions |
| Template storage | DB + cache | Templates change infrequently; 30-min cache reduces DB load |
| Deduplication | Idempotency key in DB | Unique constraint ensures exactly-once even on crash-restart |
| User preferences | Checked at orchestrator | One check before fan-out; prevents unnecessary work |
| Dead letter queue | Separate DLQ topic | Operations team can inspect and replay failed notifications |

---

---

# Problem 04: Digital Payment Wallet

## Asked At
Razorpay (very deep), PhonePe, Paytm, CRED, Groww — CRITICAL problem

---

## Requirements

### Functional
- Add money to wallet (from bank/card)
- Transfer money: wallet → wallet, wallet → bank
- View transaction history with pagination
- Balance inquiry (always accurate)
- Reversals / refunds

### Non-Functional
- **ACID transactions** — balance must never be incorrect
- Idempotency — payment deducted exactly once (retry-safe)
- 99.999% uptime for balance reads
- Audit trail for every balance change (regulatory requirement)
- Fraud detection (velocity checks)

---

## The Core Challenge: Distributed Money Movement

```
THE FUNDAMENTAL RULE: Money must never be created or destroyed.
Sum of all balances must remain constant before and after any transaction.

Debit Alice by ₹500  AND  Credit Bob by ₹500  — BOTH or NEITHER.
```

---

## Architecture

```
┌─────────┐   POST /transfer   ┌──────────────────────┐
│ Mobile  │ ──────────────────→│   Payment Service    │
│  App    │                    │   (.NET 10 API)      │
└─────────┘                    └──────────┬───────────┘
                                          │
                           ┌──────────────▼──────────────┐
                           │    Wallet Core Engine       │
                           │                             │
                           │  1. Idempotency check       │
                           │  2. Fraud check             │
                           │  3. Balance check           │
                           │  4. DB Transaction          │
                           │     - Debit sender          │
                           │     - Credit receiver       │
                           │     - Ledger entries        │
                           │  5. Publish event           │
                           └──────────────┬──────────────┘
                                          │
                     ┌────────────────────┼────────────────────┐
                     ▼                    ▼                    ▼
             ┌──────────────┐   ┌──────────────────┐  ┌──────────────┐
             │  PostgreSQL  │   │   Kafka Events   │  │  Redis Cache │
             │  (wallets,   │   │  (audit, notifs) │  │  (balances)  │
             │   ledger)    │   └──────────────────┘  └──────────────┘
             └──────────────┘
```

---

## Database Schema (Double-Entry Accounting)

```sql
-- Wallets table
CREATE TABLE wallets (
    id          BIGSERIAL    PRIMARY KEY,
    user_id     BIGINT       NOT NULL UNIQUE,
    balance     NUMERIC(15,2) NOT NULL DEFAULT 0.00,  -- Always non-negative
    currency    CHAR(3)      NOT NULL DEFAULT 'INR',
    status      VARCHAR(20)  NOT NULL DEFAULT 'active',  -- active/blocked/closed
    version     BIGINT       NOT NULL DEFAULT 0,         -- optimistic locking
    updated_at  TIMESTAMPTZ  DEFAULT NOW(),
    CONSTRAINT balance_non_negative CHECK (balance >= 0)
);

-- Double-entry ledger (immutable audit log)
-- Every transaction creates EXACTLY 2 entries: debit + credit
CREATE TABLE ledger_entries (
    id              BIGSERIAL    PRIMARY KEY,
    transaction_id  UUID         NOT NULL,
    wallet_id       BIGINT       NOT NULL REFERENCES wallets(id),
    entry_type      CHAR(2)      NOT NULL,   -- 'DR' or 'CR'
    amount          NUMERIC(15,2) NOT NULL,
    balance_after   NUMERIC(15,2) NOT NULL,  -- snapshot for fast audit
    description     TEXT,
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);

-- Transactions table (idempotency + status tracking)
CREATE TABLE transactions (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key VARCHAR(128) NOT NULL UNIQUE,  -- client-provided
    from_wallet_id  BIGINT       REFERENCES wallets(id),
    to_wallet_id    BIGINT       REFERENCES wallets(id),
    amount          NUMERIC(15,2) NOT NULL,
    type            VARCHAR(30)  NOT NULL,   -- p2p_transfer/add_money/withdrawal
    status          VARCHAR(20)  NOT NULL DEFAULT 'initiated',
    failure_reason  TEXT,
    metadata        JSONB,
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_ledger_wallet_id     ON ledger_entries(wallet_id, created_at DESC);
CREATE INDEX idx_transactions_wallet  ON transactions(from_wallet_id, created_at DESC);
```

---

## .NET Implementation

### Wallet Transfer — Core Transaction Logic

```csharp
// WalletService.cs
public class WalletService : IWalletService
{
    private readonly IDbContextFactory<WalletDbContext> _dbFactory;
    private readonly IFraudDetector    _fraud;
    private readonly IEventPublisher   _events;
    private readonly IDistributedCache _cache;

    public async Task<TransferResult> TransferAsync(TransferRequest request)
    {
        // ─── STEP 1: Idempotency Check ─────────────────────────────────────
        // If client retries, return same result without double-charging
        var existing = await GetExistingTransactionAsync(request.IdempotencyKey);
        if (existing is not null)
            return TransferResult.FromExisting(existing);

        // ─── STEP 2: Fraud Check ───────────────────────────────────────────
        var fraudResult = await _fraud.EvaluateAsync(new FraudContext
        {
            UserId   = request.SenderId,
            Amount   = request.Amount,
            Channel  = request.Channel,
            Metadata = request.Metadata
        });

        if (fraudResult.IsBlocked)
            return TransferResult.Blocked(fraudResult.Reason);

        // ─── STEP 3: Database Transaction ─────────────────────────────────
        await using var db = await _dbFactory.CreateDbContextAsync();
        await using var tx = await db.Database.BeginTransactionAsync(
            IsolationLevel.ReadCommitted); // READ COMMITTED is sufficient here

        try
        {
            // Lock both wallets in consistent order (lower ID first) to prevent deadlock
            var walletIds     = new[] { request.SenderWalletId, request.ReceiverWalletId }
                                    .OrderBy(id => id).ToArray();
            var senderFirst   = walletIds[0] == request.SenderWalletId;

            // SELECT FOR UPDATE — pessimistic lock
            var wallets = await db.Wallets
                .FromSqlInterpolated(
                    $"SELECT * FROM wallets WHERE id = ANY({walletIds}) FOR UPDATE")
                .ToDictionaryAsync(w => w.Id);

            var sender   = wallets[request.SenderWalletId];
            var receiver = wallets[request.ReceiverWalletId];

            // ─── Validations ───────────────────────────────────────────────
            if (sender.Status != WalletStatus.Active)
                throw new WalletException("Sender wallet is not active");
            if (receiver.Status != WalletStatus.Active)
                throw new WalletException("Receiver wallet is not active");
            if (sender.Balance < request.Amount)
                throw new InsufficientFundsException(sender.Balance, request.Amount);

            // ─── Create Transaction Record ────────────────────────────────
            var transactionId = Guid.NewGuid();
            db.Transactions.Add(new TransactionEntity
            {
                Id             = transactionId,
                IdempotencyKey = request.IdempotencyKey,
                FromWalletId   = request.SenderWalletId,
                ToWalletId     = request.ReceiverWalletId,
                Amount         = request.Amount,
                Type           = TransactionType.P2PTransfer,
                Status         = TransactionStatus.Processing
            });

            // ─── Debit Sender ─────────────────────────────────────────────
            sender.Balance  -= request.Amount;
            sender.Version  += 1;
            db.LedgerEntries.Add(new LedgerEntry
            {
                TransactionId = transactionId,
                WalletId      = sender.Id,
                EntryType     = EntryType.Debit,
                Amount        = request.Amount,
                BalanceAfter  = sender.Balance,
                Description   = $"Transfer to {receiver.UserId}"
            });

            // ─── Credit Receiver ──────────────────────────────────────────
            receiver.Balance  += request.Amount;
            receiver.Version  += 1;
            db.LedgerEntries.Add(new LedgerEntry
            {
                TransactionId = transactionId,
                WalletId      = receiver.Id,
                EntryType     = EntryType.Credit,
                Amount        = request.Amount,
                BalanceAfter  = receiver.Balance,
                Description   = $"Transfer from {sender.UserId}"
            });

            await db.SaveChangesAsync();
            await tx.CommitAsync();

            // ─── Post-Commit: Invalidate Cache & Publish Events ───────────
            await Task.WhenAll(
                _cache.RemoveAsync($"balance:{sender.UserId}"),
                _cache.RemoveAsync($"balance:{receiver.UserId}"),
                _events.PublishAsync("payment.completed", new PaymentCompletedEvent
                {
                    TransactionId = transactionId,
                    SenderId      = request.SenderId,
                    ReceiverId    = request.ReceiverId,
                    Amount        = request.Amount
                })
            );

            return TransferResult.Success(transactionId, sender.Balance);
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }
}
```

### Balance with Optimistic Locking (for High-Read Scenarios)

```csharp
// Get balance — serve from cache for speed
public async Task<decimal> GetBalanceAsync(long userId)
{
    var cacheKey = $"balance:{userId}";
    var cached   = await _cache.GetStringAsync(cacheKey);

    if (cached is not null)
        return decimal.Parse(cached);

    await using var db = await _dbFactory.CreateDbContextAsync();
    var wallet = await db.Wallets
        .AsNoTracking()
        .FirstOrDefaultAsync(w => w.UserId == userId)
        ?? throw new WalletNotFoundException(userId);

    // Short TTL — balance changes frequently
    await _cache.SetStringAsync(cacheKey, wallet.Balance.ToString(),
        new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(10)
        });

    return wallet.Balance;
}
```

### Reversal / Refund

```csharp
public async Task<ReversalResult> ReverseAsync(ReversalRequest request)
{
    // Refunds are NEW transactions in opposite direction
    // Never UPDATE existing ledger entries — they are immutable

    var original = await _repo.GetTransactionAsync(request.OriginalTransactionId)
        ?? throw new TransactionNotFoundException(request.OriginalTransactionId);

    if (original.Status != TransactionStatus.Completed)
        throw new InvalidOperationException("Can only reverse completed transactions");

    return await TransferAsync(new TransferRequest
    {
        IdempotencyKey   = $"refund:{request.OriginalTransactionId}",
        SenderWalletId   = original.ToWalletId,    // reverse direction
        ReceiverWalletId = original.FromWalletId,
        Amount           = original.Amount,
        Metadata         = new { RefundOf = original.Id }
    });
}
```

---

## Trade-offs

| Concern | Decision | Reasoning |
|---------|----------|-----------|
| Locking strategy | Pessimistic (SELECT FOR UPDATE) | Money requires strict consistency; optimistic locks cause high retry rate under contention |
| Deadlock prevention | Always lock in wallet ID order | Consistent ordering eliminates circular wait |
| Ledger | Immutable double-entry | Audit compliance; balance can be recalculated from ledger if needed |
| Balance cache TTL | 10 seconds | Stale balance could cause user confusion; short TTL is safer |
| Idempotency | Client-provided key + DB unique constraint | Retry-safe from mobile app reconnects |
| Isolation level | READ COMMITTED | SERIALIZABLE has too much overhead; explicit locks handle the critical section |

---

## Interview Deep-Dive Questions (Razorpay Style)

1. **"What if the server crashes after DB commit but before publishing Kafka event?"**
   → Use Transactional Outbox pattern — write event to `outbox` table in same transaction; separate poller publishes to Kafka

2. **"What if balance goes negative due to concurrent transactions?"**
   → CHECK constraint in DB, plus pessimistic lock means only one transaction proceeds at a time

3. **"How would you handle UPI integration?"**
   → NPCI gateway adapter; 2-phase: debit source wallet → hold → confirm with NPCI → credit destination

4. **"Scale to 10M transactions/day — DB bottleneck?"**
   → Shard by user_id (consistent hashing); read replicas for balance queries; time-series tables for old ledger entries

---

---

# Problem 05: Food Ordering + Real-time Tracking

## Asked At
Swiggy (exhaustively), Zomato, Dunzo, Blinkit, Urban Company

---

## Requirements

### Functional
- Browse restaurants, menus, items
- Place order (cart → checkout → payment → confirmation)
- Real-time order status tracking (placed → accepted → preparing → picked → delivered)
- Real-time delivery agent location (GPS updates every 5 seconds)
- ETA calculation
- Ratings & reviews post-delivery

### Non-Functional
- Order placement: < 500ms
- Location updates: handle 500K concurrent drivers updating location
- Real-time tracking: < 1s lag for customer to see driver location
- Peak: 50K concurrent orders during lunch rush

---

## Architecture

```
┌──────────┐                    ┌──────────────────────────────────────────┐
│ Customer │ ←── WebSocket ───→ │         API Gateway                      │
│   App    │                    └────┬─────────────┬───────────────────────┘
└──────────┘                         │             │
                                     ▼             ▼
┌──────────┐   HTTPS POST     ┌──────────────┐ ┌────────────────────┐
│  Driver  │ ──────────────→  │  Order Svc   │ │  Location Service  │
│   App    │ (GPS updates)    │  (.NET 10)   │ │  (.NET + Redis)    │
└──────────┘                  └──────┬───────┘ └────────┬───────────┘
                                     │                  │
                              ┌──────▼──────┐    ┌──────▼──────────┐
                              │  Postgres   │    │  Redis Geo      │
                              │  (orders)   │    │  (driver locs)  │
                              └──────┬──────┘    └─────────────────┘
                                     │
                              ┌──────▼──────┐
                              │   Kafka     │
                              │  (events)   │
                              └──────┬──────┘
                                     │
                     ┌───────────────┼──────────────────┐
                     ▼               ▼                  ▼
             ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐
             │  Notification│ │ ETA Service  │ │  Push to Customer │
             │    Service   │ │  (routing)   │ │  via SignalR Hub  │
             └──────────────┘ └──────────────┘ └──────────────────┘
```

---

## Database Schema

```sql
-- Orders
CREATE TABLE orders (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id     BIGINT       NOT NULL,
    restaurant_id   BIGINT       NOT NULL,
    driver_id       BIGINT,
    status          VARCHAR(30)  NOT NULL DEFAULT 'placed',
    total_amount    NUMERIC(10,2) NOT NULL,
    delivery_address JSONB       NOT NULL,
    items           JSONB        NOT NULL,   -- snapshot of items at order time
    placed_at       TIMESTAMPTZ  DEFAULT NOW(),
    accepted_at     TIMESTAMPTZ,
    picked_up_at    TIMESTAMPTZ,
    delivered_at    TIMESTAMPTZ
);

-- Order status history (event log)
CREATE TABLE order_status_history (
    id          BIGSERIAL    PRIMARY KEY,
    order_id    UUID         NOT NULL REFERENCES orders(id),
    status      VARCHAR(30)  NOT NULL,
    note        TEXT,
    actor_type  VARCHAR(20),  -- customer/driver/system/restaurant
    actor_id    BIGINT,
    created_at  TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX idx_orders_customer ON orders(customer_id, placed_at DESC);
CREATE INDEX idx_orders_driver   ON orders(driver_id) WHERE status NOT IN ('delivered','cancelled');
```

---

## .NET Implementation

### Real-time Location Updates (Driver → Redis Geo)

```csharp
// LocationService.cs
public class LocationService : ILocationService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IHubContext<TrackingHub> _hub;
    private readonly IEventPublisher _events;

    public async Task UpdateDriverLocationAsync(LocationUpdate update)
    {
        var db = _redis.GetDatabase();

        // Redis GEO: stores coordinates indexed for radius queries
        // Key: "driver:locations", member: driverId, score: geohash
        await db.GeoAddAsync(
            "driver:locations",
            new GeoEntry(update.Longitude, update.Latitude, update.DriverId.ToString())
        );

        // Track which order this driver is handling (for targeted push)
        var orderId = await db.StringGetAsync($"driver:{update.DriverId}:active_order");
        if (orderId.HasValue)
        {
            // Push location directly to customer watching this order
            await _hub.Clients
                .Group($"order:{orderId}")
                .SendAsync("DriverLocationUpdated", new
                {
                    DriverId  = update.DriverId,
                    Lat       = update.Latitude,
                    Lng       = update.Longitude,
                    Timestamp = update.Timestamp
                });
        }
    }

    public async Task<IEnumerable<NearbyDriver>> FindNearbyDriversAsync(
        double lat, double lng, double radiusKm)
    {
        var db      = _redis.GetDatabase();
        var results = await db.GeoSearchAsync(
            "driver:locations",
            new GeoSearchCircle(lng, lat, radiusKm, GeoUnit.Kilometers),
            order: Order.Ascending,
            count: 10
        );

        return results.Select(r => new NearbyDriver
        {
            DriverId   = long.Parse(r.Member!),
            DistanceKm = r.Distance ?? 0
        });
    }
}
```

### Order State Machine

```csharp
// OrderStateMachine.cs — explicit state transitions
public class OrderStateMachine
{
    // Valid transitions map
    private static readonly Dictionary<OrderStatus, OrderStatus[]> ValidTransitions = new()
    {
        [OrderStatus.Placed]     = [OrderStatus.Accepted,  OrderStatus.Cancelled],
        [OrderStatus.Accepted]   = [OrderStatus.Preparing, OrderStatus.Cancelled],
        [OrderStatus.Preparing]  = [OrderStatus.ReadyForPickup],
        [OrderStatus.ReadyForPickup] = [OrderStatus.PickedUp],
        [OrderStatus.PickedUp]   = [OrderStatus.Delivered, OrderStatus.ReturnInitiated],
        [OrderStatus.Delivered]  = [],  // terminal
        [OrderStatus.Cancelled]  = []   // terminal
    };

    public async Task TransitionAsync(Guid orderId, OrderStatus newStatus,
        TransitionContext ctx, CancellationToken ct = default)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);
        await using var tx = await db.Database.BeginTransactionAsync(ct);

        var order = await db.Orders
            .Where(o => o.Id == orderId)
            .FirstOrDefaultAsync(ct)
            ?? throw new OrderNotFoundException(orderId);

        if (!ValidTransitions.TryGetValue(order.Status, out var allowed) ||
            !allowed.Contains(newStatus))
        {
            throw new InvalidStateTransitionException(order.Status, newStatus);
        }

        order.Status = newStatus;
        SetTimestamp(order, newStatus);

        db.OrderStatusHistory.Add(new OrderStatusHistory
        {
            OrderId   = orderId,
            Status    = newStatus,
            ActorType = ctx.ActorType,
            ActorId   = ctx.ActorId,
            Note      = ctx.Note
        });

        await db.SaveChangesAsync(ct);
        await tx.CommitAsync(ct);

        // Notify customer via SignalR
        await _hub.Clients.Group($"order:{orderId}").SendAsync(
            "OrderStatusChanged", new { orderId, newStatus, timestamp = DateTime.UtcNow }, ct);

        // Publish for other services (notification, analytics)
        await _events.PublishAsync($"order.{newStatus.ToString().ToLower()}",
            new OrderStatusEvent { OrderId = orderId, NewStatus = newStatus });
    }
}
```

### SignalR Hub for Real-time Tracking

```csharp
// TrackingHub.cs
[Authorize]
public class TrackingHub : Hub
{
    public async Task SubscribeToOrder(string orderId)
    {
        // Validate customer owns this order
        var customerId = Context.User!.FindFirstValue(ClaimTypes.NameIdentifier);
        var order      = await _orderService.GetAsync(Guid.Parse(orderId));

        if (order.CustomerId.ToString() != customerId)
        {
            await Clients.Caller.SendAsync("Error", "Not authorized");
            return;
        }

        await Groups.AddToGroupAsync(Context.ConnectionId, $"order:{orderId}");

        // Send current state immediately on subscribe
        await Clients.Caller.SendAsync("CurrentState", new
        {
            Status   = order.Status,
            DriverId = order.DriverId
        });
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        // Groups auto-cleanup on disconnect
        await base.OnDisconnectedAsync(exception);
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Location storage | Redis GEO | O(log N) radius search, in-memory for speed; driver locs are ephemeral |
| Real-time push | SignalR (WebSocket) | Bi-directional, handles reconnect, integrates with .NET DI |
| Order state | Explicit state machine | Prevents invalid transitions; all history preserved |
| Items snapshot in order | JSONB in orders table | Menu prices change; order must reflect price at time of purchase |
| ETA calculation | Separate service | Call routing API (Google Maps/HERE) asynchronously; cache route estimates |

---

---

# Problem 06: Real-time Chat / Messaging System

## Asked At
All product companies, Infosys (GCC teams building collaboration tools), HCL, Wipro

---

## Requirements

### Functional
- 1:1 and group messaging (up to 500 members)
- Message delivery: sent → delivered → read receipts
- Online presence / last seen
- Message history with pagination
- Media attachments (images/files)
- Push notifications when offline

### Non-Functional
- < 100ms message delivery (P99)
- 10M concurrent connections
- Messages must not be lost
- Offline message sync on reconnect

---

## Architecture

```
┌──────────┐  WebSocket    ┌──────────────────────────┐
│  Client  │ ────────────→ │   WebSocket Gateway      │
│  (Alice) │               │   (SignalR / .NET)        │
└──────────┘               └───────────┬──────────────┘
                                       │
┌──────────┐  WebSocket                │  Route via Redis pub/sub
│  Client  │ ────────────→ ┌───────────▼──────────────┐
│   (Bob)  │               │   WebSocket Gateway      │   ← Different server instance
└──────────┘               └───────────┬──────────────┘
                                       │
                            ┌──────────▼──────────────┐
                            │   Message Service       │
                            │   - Store message       │
                            │   - Route to recipients │
                            │   - Update receipts     │
                            └──────────┬──────────────┘
                                       │
              ┌────────────────────────┼────────────────────┐
              ▼                        ▼                    ▼
      ┌──────────────┐       ┌──────────────────┐  ┌──────────────┐
      │  Cassandra   │       │  Redis           │  │   Kafka      │
      │  (messages)  │       │  (presence/      │  │  (offline    │
      │              │       │   routing)       │  │   notifs)    │
      └──────────────┘       └──────────────────┘  └──────────────┘
```

---

## Database Schema

```sql
-- Cassandra (optimized for chat — high write, time-series reads)
-- Table: messages_by_conversation
CREATE TABLE messages_by_conversation (
    conversation_id UUID,
    message_id      TIMEUUID,        -- ordered by time, globally unique
    sender_id       BIGINT,
    content         TEXT,
    content_type    TEXT,            -- text/image/video/file
    media_url       TEXT,
    is_deleted      BOOLEAN,
    created_at      TIMESTAMP,
    PRIMARY KEY ((conversation_id), message_id)  -- partition by conv, cluster by time
) WITH CLUSTERING ORDER BY (message_id DESC);    -- newest first

-- PostgreSQL for user/conversation metadata
CREATE TABLE conversations (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    type            VARCHAR(10)  NOT NULL,  -- direct/group
    name            VARCHAR(200),           -- for groups
    created_by      BIGINT,
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);

CREATE TABLE conversation_members (
    conversation_id UUID    NOT NULL REFERENCES conversations(id),
    user_id         BIGINT  NOT NULL,
    joined_at       TIMESTAMPTZ DEFAULT NOW(),
    last_read_at    TIMESTAMPTZ,
    is_admin        BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (conversation_id, user_id)
);
```

---

## .NET Implementation

### Chat Hub (SignalR)

```csharp
// ChatHub.cs
[Authorize]
public class ChatHub : Hub
{
    private readonly IMessageService    _messages;
    private readonly IPresenceService   _presence;
    private readonly IConnectionMapping _connections;

    public override async Task OnConnectedAsync()
    {
        var userId = GetUserId();

        // Register this connection (user may have multiple devices)
        await _connections.AddAsync(userId, Context.ConnectionId);
        await _presence.SetOnlineAsync(userId);

        // Add to all user's conversation groups for routing
        var conversations = await _messages.GetUserConversationsAsync(userId);
        foreach (var convId in conversations)
            await Groups.AddToGroupAsync(Context.ConnectionId, $"conv:{convId}");

        // Notify contacts about online status
        await Clients.Others.SendAsync("UserOnline", userId);

        await base.OnConnectedAsync();
    }

    public async Task SendMessage(SendMessageRequest request)
    {
        var senderId = GetUserId();

        // 1. Persist first (message must not be lost)
        var message = await _messages.StoreAsync(new Message
        {
            ConversationId = request.ConversationId,
            SenderId       = senderId,
            Content        = request.Content,
            ContentType    = request.ContentType
        });

        // 2. Acknowledge to sender immediately
        await Clients.Caller.SendAsync("MessageAcknowledged", new
        {
            ClientMessageId = request.ClientMessageId,
            MessageId       = message.Id,
            Timestamp       = message.CreatedAt
        });

        // 3. Deliver to all members in conversation group
        // (Redis backplane routes to correct server instances)
        await Clients.Group($"conv:{request.ConversationId}")
            .SendAsync("NewMessage", new MessageDto
            {
                MessageId      = message.Id,
                ConversationId = request.ConversationId,
                SenderId       = senderId,
                Content        = message.Content,
                ContentType    = message.ContentType,
                CreatedAt      = message.CreatedAt
            });

        // 4. Offline users — publish to Kafka for push notification
        var offlineMembers = await _presence.GetOfflineMembersAsync(request.ConversationId);
        if (offlineMembers.Any())
        {
            await _events.PublishAsync("chat.message.offline", new OfflineMessageEvent
            {
                MessageId       = message.Id,
                OfflineUserIds  = offlineMembers,
                ConversationId  = request.ConversationId,
                SenderName      = await GetDisplayNameAsync(senderId),
                Preview         = TruncateForNotification(message.Content)
            });
        }
    }

    public async Task MarkRead(Guid conversationId, Guid lastReadMessageId)
    {
        var userId = GetUserId();
        await _messages.UpdateLastReadAsync(conversationId, userId, lastReadMessageId);

        // Notify sender(s) about read receipt
        await Clients.Group($"conv:{conversationId}").SendAsync("MessageRead", new
        {
            ReadBy = userId,
            UpToMessageId = lastReadMessageId,
            ReadAt = DateTime.UtcNow
        });
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = GetUserId();
        await _connections.RemoveAsync(userId, Context.ConnectionId);

        // Only set offline if no other connections (multi-device support)
        if (!await _connections.HasConnectionsAsync(userId))
        {
            await _presence.SetOfflineAsync(userId);
            await Clients.Others.SendAsync("UserOffline", userId);
        }

        await base.OnDisconnectedAsync(exception);
    }

    private long GetUserId()
        => long.Parse(Context.User!.FindFirstValue(ClaimTypes.NameIdentifier)!);
}
```

### Presence Service (Redis)

```csharp
// PresenceService.cs
public class PresenceService : IPresenceService
{
    private readonly IConnectionMultiplexer _redis;

    public async Task SetOnlineAsync(long userId)
    {
        var db = _redis.GetDatabase();
        // Sorted set: score = timestamp, allows "last seen" query
        await db.SortedSetAddAsync("online_users", userId.ToString(),
            DateTimeOffset.UtcNow.ToUnixTimeSeconds());
        await db.KeyExpireAsync($"presence:{userId}", TimeSpan.FromMinutes(5));
    }

    public async Task<bool> IsOnlineAsync(long userId)
    {
        var db = _redis.GetDatabase();
        var score = await db.SortedSetScoreAsync("online_users", userId.ToString());
        if (score is null) return false;

        // Consider offline if last heartbeat > 60 seconds ago
        var lastSeen = DateTimeOffset.FromUnixTimeSeconds((long)score);
        return (DateTimeOffset.UtcNow - lastSeen).TotalSeconds < 60;
    }

    public async Task<long[]> GetOfflineMembersAsync(Guid conversationId)
    {
        var members = await _memberRepo.GetMemberIdsAsync(conversationId);
        var tasks   = members.Select(id => IsOnlineAsync(id));
        var online  = await Task.WhenAll(tasks);

        return members.Where((_, i) => !online[i]).ToArray();
    }
}
```

### Multi-Instance Routing with Redis Backplane

```csharp
// Program.cs
builder.Services.AddSignalR()
    .AddStackExchangeRedis(connectionString, options =>
    {
        options.Configuration.ChannelPrefix = "chat";
        // Redis pub/sub routes messages between server instances
        // SignalR handles this transparently
    });
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Message storage | Cassandra | High write throughput; time-ordered reads by conversation efficient |
| Routing across servers | Redis pub/sub (SignalR backplane) | Built-in .NET support; handles cross-server group messaging |
| Presence | Redis sorted set | TTL-based expiry; last-seen timestamp from score |
| Offline delivery | Kafka → Push notification worker | Decoupled; push can be retried; doesn't block message storage |
| Read receipts | Client-driven MarkRead call | Server-driven (detecting read) is complex; client knows best |

---

---

# Problem 07: E-commerce Order Management

## Asked At
Flipkart, Meesho, Myntra, Nykaa, Snapdeal, Amazon India GCC

---

## Requirements

### Functional
- Place order (cart checkout)
- Order states: placed → payment_pending → paid → processing → shipped → delivered
- Order cancellation / returns
- Multi-seller order splitting
- Warehouse fulfillment integration

### Non-Functional
- Idempotent order creation
- Handle 100K orders/minute during Big Billion Days sales
- Consistent inventory (no overselling)
- Distributed transaction (inventory deduction + order creation + payment)

---

## The Saga Pattern (Distributed Transaction)

```
Order creation spans multiple services — Saga orchestrates rollback on failure.

┌─────────────────────────────────────────────────────────────────────────────┐
│                        SAGA: Place Order                                     │
│                                                                               │
│  Step 1: Reserve Inventory   ──→  (success) ──→  Step 2: Charge Payment     │
│                │ (fail: item OOS)                           │ (fail: card declined) │
│                ▼                                            ▼                │
│         [Already handled]                     Compensate: Release Inventory │
│                                                                               │
│  Step 2: Charge Payment      ──→  (success) ──→  Step 3: Create Order Record │
│                                                            │ (fail: DB error) │
│                                                            ▼                │
│                                               Compensate: Refund Payment +  │
│                                               Release Inventory              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## .NET Implementation — Saga Orchestrator

```csharp
// PlaceOrderSaga.cs
public class PlaceOrderSaga : ISaga<PlaceOrderCommand>
{
    private readonly IInventoryService _inventory;
    private readonly IPaymentService   _payment;
    private readonly IOrderRepository  _orders;
    private readonly IEventPublisher   _events;

    public async Task<OrderResult> ExecuteAsync(PlaceOrderCommand cmd)
    {
        // Keep track of compensations
        var compensations = new Stack<Func<Task>>();

        try
        {
            // ── STEP 1: Reserve inventory ──────────────────────────────────
            var reservationId = await _inventory.ReserveAsync(cmd.Items);
            compensations.Push(() => _inventory.ReleaseReservationAsync(reservationId));

            // ── STEP 2: Process payment ────────────────────────────────────
            var paymentResult = await _payment.ChargeAsync(new PaymentRequest
            {
                IdempotencyKey = $"order:{cmd.IdempotencyKey}:payment",
                Amount         = cmd.TotalAmount,
                PaymentMethod  = cmd.PaymentMethodId,
                CustomerId     = cmd.CustomerId
            });

            if (!paymentResult.IsSuccess)
                throw new PaymentFailedException(paymentResult.FailureReason);

            compensations.Push(() => _payment.RefundAsync(paymentResult.TransactionId));

            // ── STEP 3: Create order record ────────────────────────────────
            var order = await _orders.CreateAsync(new OrderEntity
            {
                IdempotencyKey  = cmd.IdempotencyKey,
                CustomerId      = cmd.CustomerId,
                Items           = cmd.Items,
                TotalAmount     = cmd.TotalAmount,
                ReservationId   = reservationId,
                PaymentId       = paymentResult.TransactionId,
                Status          = OrderStatus.Paid
            });

            // ── Confirm inventory reservation → deduct actual stock ─────────
            await _inventory.ConfirmReservationAsync(reservationId);
            compensations.Clear(); // success — no compensation needed

            // Publish domain event for fulfillment, notifications
            await _events.PublishAsync("order.placed", new OrderPlacedEvent
            {
                OrderId    = order.Id,
                CustomerId = cmd.CustomerId,
                Items      = cmd.Items,
                Amount     = cmd.TotalAmount
            });

            return OrderResult.Success(order.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Order saga failed, running compensations");

            // Execute compensations in reverse order (LIFO)
            while (compensations.TryPop(out var compensate))
            {
                try { await compensate(); }
                catch (Exception compEx)
                {
                    // Log but continue other compensations
                    _logger.LogError(compEx, "Compensation failed");
                }
            }

            return OrderResult.Failure(ex.Message);
        }
    }
}
```

### Inventory Reservation (Prevents Overselling)

```csharp
// InventoryService.cs
public class InventoryService : IInventoryService
{
    public async Task<Guid> ReserveAsync(IEnumerable<OrderItem> items)
    {
        await using var db = await _dbFactory.CreateDbContextAsync();
        await using var tx = await db.Database.BeginTransactionAsync(IsolationLevel.ReadCommitted);

        var reservationId = Guid.NewGuid();

        foreach (var item in items)
        {
            // Atomic: check AND decrement available quantity
            var rowsAffected = await db.Database.ExecuteSqlInterpolatedAsync($"""
                UPDATE inventory
                SET reserved_quantity = reserved_quantity + {item.Quantity}
                WHERE product_id = {item.ProductId}
                  AND (available_quantity - reserved_quantity) >= {item.Quantity}
            """);

            if (rowsAffected == 0)
                throw new OutOfStockException(item.ProductId);
        }

        // Record reservation for cleanup if saga fails
        db.InventoryReservations.Add(new InventoryReservation
        {
            Id         = reservationId,
            Items      = items.ToList(),
            ExpiresAt  = DateTime.UtcNow.AddMinutes(10),  // auto-expire if not confirmed
            Status     = ReservationStatus.Active
        });

        await db.SaveChangesAsync();
        await tx.CommitAsync();

        return reservationId;
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Distributed transaction | Saga pattern | 2PC is too slow and brittle across services; Saga provides compensating transactions |
| Inventory locking | UPDATE with WHERE clause | Atomic check-and-update; no explicit SELECT FOR UPDATE needed |
| Reservation expiry | TTL + background cleanup | Handles abandoned carts; background job releases expired reservations |
| Order splitting | Saga per sub-order | Each seller fulfills independently; failures are isolated |

---

---

# Problem 08: Cab Booking / Ride Sharing

## Asked At
Ola (core interview), Rapido, Porter, Yulu

---

## Requirements

### Functional
- Book a cab (specify pickup/drop)
- Match nearby available drivers
- Real-time driver location tracking
- Fare calculation (base + distance + surge pricing)
- Trip lifecycle: requested → driver_assigned → driver_enroute → trip_started → completed

### Non-Functional
- Driver matching: < 2 seconds
- Location updates: 500K drivers updating every 5s
- Surge pricing: compute in real-time based on demand

---

## Architecture

```
                          ┌──────────────────────┐
  Ride Request            │    Booking Service   │
─────────────────────────→│    (.NET 10 API)     │
                          └──────────┬───────────┘
                                     │
              ┌──────────────────────┼──────────────────┐
              ▼                      ▼                  ▼
      ┌──────────────┐    ┌─────────────────┐  ┌──────────────────┐
      │  Matching    │    │  Surge Pricing  │  │  Redis GEO       │
      │  Service     │    │  Engine         │  │  (driver locs)   │
      └──────┬───────┘    └─────────────────┘  └──────────────────┘
             │
      ┌──────▼───────┐
      │  Driver Push │ ─── WebSocket/FCM ──→ Driver App
      │  & Accept    │
      └──────────────┘
```

---

## .NET Implementation

### Driver Matching Algorithm

```csharp
// MatchingService.cs
public class MatchingService : IMatchingService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IDriverRepository _drivers;

    public async Task<MatchResult> FindDriverAsync(RideRequest request)
    {
        var db = _redis.GetDatabase();

        // 1. Find geographically nearby available drivers
        var nearby = await db.GeoSearchAsync(
            "driver:available",  // only active, available drivers in this set
            new GeoSearchCircle(request.PickupLng, request.PickupLat, radiusKm: 3.0, GeoUnit.Kilometers),
            order: Order.Ascending,
            count: 20
        );

        if (!nearby.Any())
        {
            // Expand radius progressively (3km → 5km → 8km)
            nearby = await db.GeoSearchAsync(
                "driver:available",
                new GeoSearchCircle(request.PickupLng, request.PickupLat, radiusKm: 8.0, GeoUnit.Kilometers),
                order: Order.Ascending,
                count: 20
            );
        }

        if (!nearby.Any())
            return MatchResult.NoDriversAvailable();

        // 2. Rank drivers by: distance + rating + acceptance rate
        var driverIds  = nearby.Select(n => long.Parse(n.Member!)).ToList();
        var driverData = await _drivers.GetMetadataAsync(driverIds);

        var ranked = driverData
            .Select(d => new
            {
                Driver     = d,
                Score      = CalculateScore(d, nearby.First(n => long.Parse(n.Member!) == d.Id).Distance ?? 999)
            })
            .OrderByDescending(x => x.Score)
            .Select(x => x.Driver)
            .ToList();

        // 3. Sequential offer (ask top driver, timeout 15s, try next)
        foreach (var driver in ranked)
        {
            var accepted = await OfferRideAsync(driver.Id, request);
            if (accepted)
            {
                // Remove driver from available set
                await db.SortedSetRemoveAsync("driver:available", driver.Id.ToString());
                return MatchResult.Matched(driver);
            }
        }

        return MatchResult.NoAcceptance();
    }

    private static double CalculateScore(DriverMetadata driver, double distanceKm)
    {
        // Lower distance = higher score; higher rating = higher score
        return (driver.Rating * 20)           // 5.0 rating = 100 points
             + (driver.AcceptanceRate * 10)   // 100% = 10 points
             - (distanceKm * 5);              // penalty per km
    }

    private async Task<bool> OfferRideAsync(long driverId, RideRequest request)
    {
        // Push ride request to driver via SignalR/FCM
        await _hub.Clients.Group($"driver:{driverId}")
            .SendAsync("RideOffer", new RideOfferDto
            {
                RequestId      = request.Id,
                PickupLocation = request.PickupAddress,
                DropLocation   = request.DropAddress,
                EstFare        = request.EstimatedFare,
                ExpiresAt      = DateTime.UtcNow.AddSeconds(15)
            });

        // Wait for driver response (up to 15 seconds)
        var tcs     = new TaskCompletionSource<bool>();
        var timeout = Task.Delay(TimeSpan.FromSeconds(15));

        _pendingOffers[request.Id] = tcs;

        var completed = await Task.WhenAny(tcs.Task, timeout);
        _pendingOffers.TryRemove(request.Id, out _);

        return completed == tcs.Task && await tcs.Task;
    }
}
```

### Surge Pricing Engine

```csharp
// SurgePricingEngine.cs
public class SurgePricingEngine : ISurgePricingEngine
{
    // Surge multiplier based on supply/demand ratio in a geohash cell
    public async Task<decimal> GetSurgeMultiplierAsync(double lat, double lng)
    {
        var db      = _redis.GetDatabase();
        var geohash = Geohash.Encode(lat, lng, precision: 5); // ~4.9km × 4.9km cell

        var demandKey = $"demand:{geohash}";  // ride requests in last 5 min
        var supplyKey = $"supply:{geohash}";  // available drivers in cell

        var demand = (double)(await db.StringGetAsync(demandKey) ?? "0");
        var supply = (double)(await db.StringGetAsync(supplyKey) ?? "1");

        var ratio = supply > 0 ? demand / supply : 10; // if no supply, max surge

        // Surge tiers (Ola-style)
        return ratio switch
        {
            < 1.0  => 1.0m,   // 1x — balanced
            < 1.5  => 1.25m,  // 1.25x
            < 2.0  => 1.5m,   // 1.5x
            < 3.0  => 2.0m,   // 2x
            _      => 2.5m    // 2.5x — max
        };
    }

    // Called every minute by a background job
    public async Task RefreshDemandSupplyAsync(string geohash)
    {
        var db = _redis.GetDatabase();

        var activeDemand  = await CountActiveRequestsInCellAsync(geohash);
        var activeDrivers = await CountAvailableDriversInCellAsync(geohash);

        await db.StringSetAsync($"demand:{geohash}", activeDemand, TimeSpan.FromMinutes(5));
        await db.StringSetAsync($"supply:{geohash}", activeDrivers, TimeSpan.FromMinutes(5));
    }
}
```

---

---

# Problem 09: Search Autocomplete / Typeahead

## Asked At
Flipkart, Amazon India, Myntra, Zomato (restaurant search), BigBasket, JioMart

---

## Requirements

### Functional
- Return top 10 suggestions as user types
- Rank by: popularity + personalization
- Handle typos (fuzzy search)
- Category-aware: products vs restaurants vs locations

### Non-Functional
- Response time < 50ms (P99)
- 100K queries/second at peak
- Update index within 1 hour of new popular searches

---

## Architecture

```
 Keystrokes          ┌──────────────┐    Redis      ┌──────────────────┐
──────────────────→  │  Search API  │ ────────────→ │  Trie in Redis   │
                     │  (.NET 10)   │               │  (prefix cache)  │
                     └──────────────┘               └──────────────────┘
                            │ cache miss
                     ┌──────▼──────────┐
                     │  Elasticsearch  │
                     │  (full text +   │
                     │   fuzzy)        │
                     └──────┬──────────┘
                            │
                     ┌──────▼──────────┐
                     │  Analytics      │
                     │  Pipeline       │ ← Kafka (search events) → Spark → update popularity
                     └─────────────────┘
```

---

## .NET Implementation

### Prefix-Based Autocomplete with Redis Sorted Sets

```csharp
// AutocompleteService.cs
public class AutocompleteService : IAutocompleteService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly ISearchClient _elastic;

    public async Task<IEnumerable<Suggestion>> GetSuggestionsAsync(string prefix, int topN = 10)
    {
        prefix = prefix.ToLowerInvariant().Trim();
        if (prefix.Length < 2) return Enumerable.Empty<Suggestion>();

        // 1. Check Redis prefix cache (ultra-fast path)
        var cacheKey = $"ac:{prefix}";
        var cached   = await _redis.GetDatabase().StringGetAsync(cacheKey);
        if (cached.HasValue)
            return JsonSerializer.Deserialize<Suggestion[]>(cached!)!;

        // 2. Elasticsearch for full-text + fuzzy
        var response = await _elastic.SearchAsync<SearchDocument>(s => s
            .Index("product_search")
            .Query(q => q
                .Bool(b => b
                    .Should(
                        sh => sh.MatchPhrasePrefix(m => m.Field(f => f.Title).Query(prefix).Boost(2)), // exact prefix boost
                        sh => sh.Fuzzy(fz => fz.Field(f => f.Title).Value(prefix).Fuzziness(Fuzziness.Auto)) // typo tolerance
                    )
                )
            )
            .Sort(so => so.Descending(SortSpecialField.Score).Descending(f => f.SearchCount)) // popularity
            .Size(topN)
        );

        var suggestions = response.Hits
            .Select(h => new Suggestion
            {
                Text     = h.Source!.Title,
                Category = h.Source.Category,
                Score    = h.Score ?? 0
            })
            .ToArray();

        // 3. Cache for 60s (high traffic, stale OK for autocomplete)
        await _redis.GetDatabase().StringSetAsync(
            cacheKey,
            JsonSerializer.Serialize(suggestions),
            TimeSpan.FromSeconds(60)
        );

        return suggestions;
    }

    // Called when building/updating index
    public async Task IndexTermAsync(string term, long searchCount)
    {
        var db = _redis.GetDatabase();

        // Redis Sorted Set: store all prefixes of term with popularity score
        // e.g., "apple iphone" → index "a", "ap", "app", ..., "apple i", ... all pointing to this term
        var termKey = "autocomplete_index";

        // Enumerate all prefixes
        for (int i = 1; i <= term.Length; i++)
        {
            var prefix = term[..i].ToLowerInvariant();
            await db.SortedSetAddAsync(termKey, term, searchCount); // score = popularity
        }
    }
}
```

### Popularity Update Pipeline

```csharp
// SearchAnalyticsConsumer.cs — Kafka consumer updates search popularity
public class SearchAnalyticsConsumer : BackgroundService
{
    // Batch search events every 30 seconds, update Elasticsearch popularity scores
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        var counts = new ConcurrentDictionary<string, int>();
        var timer  = new PeriodicTimer(TimeSpan.FromSeconds(30));

        while (!ct.IsCancellationRequested)
        {
            var msg = _consumer.Consume(TimeSpan.FromMilliseconds(50));
            if (msg is not null)
                counts.AddOrUpdate(msg.Message.Value.Query.ToLower(), 1, (_, v) => v + 1);

            if (await timer.WaitForNextTickAsync(ct))
            {
                var snapshot = counts.ToArray();
                counts.Clear();

                foreach (var (term, count) in snapshot)
                {
                    await _elastic.UpdateByQueryAsync<SearchDocument>(u => u
                        .Index("product_search")
                        .Query(q => q.Term(t => t.Field(f => f.Title).Value(term)))
                        .Script(sc => sc.Source("ctx._source.searchCount += params.count")
                                        .Params(p => p.Add("count", count))));
                }
            }
        }
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Fast path | Redis sorted set | Sub-millisecond; stores top suggestions per prefix |
| Fuzzy search | Elasticsearch | Native fuzziness, relevance scoring |
| Cache duration | 60 seconds | Suggestions don't change per-second; 60s fine for autocomplete UX |
| Popularity update | Batched every 30s | Near-real-time without per-search DB write |

---

---

# Problem 10: Distributed Job Scheduler

## Asked At
TCS GCC, HCL, Wipro (enterprise), Infosys (insurance/banking automation), Cognizant (BPO automation)

---

## Requirements

### Functional
- Schedule one-time and recurring jobs (cron expressions)
- Job types: API calls, data exports, report generation, email triggers
- Distributed — multiple scheduler nodes, no double execution
- Job history, failure retry with backoff
- Job priority and cancellation

### Non-Functional
- At-most-once or at-least-once delivery (configurable)
- Fault tolerant — node failure doesn't lose jobs
- Scale to 10M scheduled jobs

---

## Architecture

```
┌───────────────┐   schedule job    ┌──────────────────────┐
│  Admin API    │ ────────────────→ │   Job Scheduler DB   │
│  (.NET API)   │                   │   (PostgreSQL)       │
└───────────────┘                   └──────────┬───────────┘
                                               │
                    ┌──────────────────────────┤
                    │  Scheduler Nodes (×N)    │
                    │  - Each node polls for   │
                    │    due jobs              │
                    │  - Distributed lock via  │◄────── Redis
                    │    Redis to avoid dup    │       (leader lock)
                    │  - Execute or delegate   │
                    └──────────────────────────┘
                                │
                    ┌───────────▼──────────────┐
                    │   Worker Pool            │
                    │   (executes job logic)   │
                    └──────────────────────────┘
```

---

## .NET Implementation

### Job Scheduler (Distributed Lock via Redis)

```csharp
// JobSchedulerService.cs — BackgroundService on each node
public class JobSchedulerService : BackgroundService
{
    private readonly IJobRepository _jobs;
    private readonly IJobExecutor   _executor;
    private readonly IDistributedLock _lock;

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            // Only one node processes due jobs at a time (distributed lock)
            await using var lockHandle = await _lock.TryAcquireAsync(
                "job_scheduler_leader",
                expiry: TimeSpan.FromSeconds(30));

            if (lockHandle is not null)
            {
                await ProcessDueJobsAsync(ct);
            }
            // Non-leader nodes wait before trying again
            await Task.Delay(TimeSpan.FromSeconds(5), ct);
        }
    }

    private async Task ProcessDueJobsAsync(CancellationToken ct)
    {
        // Claim next batch of due jobs atomically
        var dueJobs = await _jobs.ClaimDueJobsAsync(
            batchSize:      50,
            lockUntil:      DateTime.UtcNow.AddMinutes(5), // if not completed in 5min, another node can pick up
            claimingNodeId: _nodeId
        );

        // Execute all due jobs in parallel (bounded parallelism)
        var options = new ParallelOptions
        {
            MaxDegreeOfParallelism = 10,
            CancellationToken = ct
        };

        await Parallel.ForEachAsync(dueJobs, options, async (job, token) =>
        {
            await ExecuteJobAsync(job, token);
        });
    }

    private async Task ExecuteJobAsync(JobEntity job, CancellationToken ct)
    {
        var startedAt = DateTime.UtcNow;
        try
        {
            await _executor.ExecuteAsync(job);

            await _jobs.MarkCompletedAsync(job.Id, DateTime.UtcNow - startedAt);

            // Schedule next run for recurring jobs
            if (job.CronExpression is not null)
            {
                var next = CronExpression.Parse(job.CronExpression).GetNextOccurrence(DateTime.UtcNow);
                await _jobs.ScheduleNextRunAsync(job.Id, next!.Value);
            }
        }
        catch (Exception ex)
        {
            var retryAt = job.RetryCount < 3
                          ? DateTime.UtcNow.AddSeconds(Math.Pow(2, job.RetryCount) * 30)
                          : null; // give up after 3 retries

            await _jobs.MarkFailedAsync(job.Id, ex.Message, retryAt);
        }
    }
}
```

### ClaimDueJobsAsync (Atomic SQL)

```csharp
// JobRepository.cs
public async Task<List<JobEntity>> ClaimDueJobsAsync(
    int batchSize, DateTime lockUntil, string claimingNodeId)
{
    // CTE with FOR UPDATE SKIP LOCKED — PostgreSQL feature for job queues
    // Prevents two nodes from picking same job without blocking each other
    var jobs = await _db.Jobs.FromSqlInterpolated($"""
        WITH due_jobs AS (
            SELECT id FROM jobs
            WHERE status = 'pending'
              AND next_run_at <= NOW()
              AND (locked_until IS NULL OR locked_until < NOW())
            ORDER BY priority DESC, next_run_at ASC
            LIMIT {batchSize}
            FOR UPDATE SKIP LOCKED  -- KEY: skip rows locked by other nodes
        )
        UPDATE jobs
        SET status = 'running',
            locked_until = {lockUntil},
            claiming_node = {claimingNodeId},
            last_picked_at = NOW()
        FROM due_jobs
        WHERE jobs.id = due_jobs.id
        RETURNING jobs.*
    """).ToListAsync();

    return jobs;
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Distributed locking | Redis + SKIP LOCKED | Redis for coarse leader election; SKIP LOCKED for fine-grained row locking |
| At-least-once delivery | Locked-until timeout | If node crashes, lock expires and another node picks up |
| Retry strategy | Exponential backoff | Avoid thundering herd on external service failures |
| Cron parsing | Cronos library (.NET) | Production-ready, handles DST, complex expressions |

---

---

# Problem 11: Authentication & Authorization Service

## Asked At
All companies — usually asked as "design SSO" or "design auth for microservices"

---

## Requirements

### Functional
- Login (username/password, OAuth2, OTP)
- JWT access token + refresh token
- Role-based access control (RBAC)
- Token revocation
- Multi-device sessions

### Non-Functional
- Token validation < 5ms (P99) — happens on every API request
- Support 50M active users
- Refresh tokens rotated on use (security)

---

## .NET Implementation

### JWT Token Service

```csharp
// TokenService.cs
public class TokenService : ITokenService
{
    private readonly JwtOptions _options;
    private readonly IRefreshTokenRepository _refreshTokens;
    private readonly IDistributedCache _cache;

    public async Task<AuthTokens> GenerateTokensAsync(UserPrincipal user)
    {
        // ── Access Token (short-lived, 15 min) ────────────────────────────
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub,  user.Id.ToString()),
            new(JwtRegisteredClaimNames.Email, user.Email),
            new(JwtRegisteredClaimNames.Jti,   Guid.NewGuid().ToString()), // unique per token
            new("roles", JsonSerializer.Serialize(user.Roles)),
            new("tenant", user.TenantId.ToString())
        };

        var key         = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.SecretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var expiry      = DateTime.UtcNow.AddMinutes(15);

        var accessToken = new JwtSecurityToken(
            issuer:   _options.Issuer,
            audience: _options.Audience,
            claims:   claims,
            expires:  expiry,
            signingCredentials: credentials
        );

        var accessTokenString = new JwtSecurityTokenHandler().WriteToken(accessToken);

        // ── Refresh Token (long-lived, 7 days, stored in DB) ──────────────
        var refreshToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

        await _refreshTokens.StoreAsync(new RefreshTokenEntity
        {
            Token      = HashToken(refreshToken),  // store hash, not plaintext
            UserId     = user.Id,
            DeviceId   = user.DeviceId,
            ExpiresAt  = DateTime.UtcNow.AddDays(7),
            CreatedAt  = DateTime.UtcNow
        });

        return new AuthTokens
        {
            AccessToken  = accessTokenString,
            RefreshToken = refreshToken,
            ExpiresAt    = expiry
        };
    }

    public async Task<AuthTokens> RefreshAsync(string refreshToken)
    {
        var hash   = HashToken(refreshToken);
        var stored = await _refreshTokens.GetByHashAsync(hash)
            ?? throw new UnauthorizedException("Invalid refresh token");

        if (stored.ExpiresAt < DateTime.UtcNow)
            throw new UnauthorizedException("Refresh token expired");

        if (stored.IsRevoked)
            throw new SecurityException("Refresh token reuse detected"); // potential theft

        // Rotate: revoke old, issue new
        await _refreshTokens.RevokeAsync(stored.Id, reason: "rotated");

        var user = await _userService.GetPrincipalAsync(stored.UserId);
        return await GenerateTokensAsync(user);
    }

    public async Task RevokeAllSessionsAsync(long userId)
    {
        // Revoke all refresh tokens (logout from all devices)
        await _refreshTokens.RevokeAllAsync(userId);

        // Add user to blocklist for access token duration
        // (Access tokens are stateless JWTs — can't be individually revoked without blocklist)
        await _cache.SetStringAsync(
            $"revoked_user:{userId}",
            "1",
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(16) // > access token TTL
            }
        );
    }

    // Called by middleware on every request — MUST be fast
    public async Task<bool> IsTokenRevokedAsync(long userId, string jti)
    {
        // Check user-level revocation (all tokens)
        var userRevoked = await _cache.GetStringAsync($"revoked_user:{userId}");
        if (userRevoked is not null) return true;

        // Check specific token revocation
        var tokenRevoked = await _cache.GetStringAsync($"revoked_jti:{jti}");
        return tokenRevoked is not null;
    }
}
```

### Auth Middleware (Token Validation)

```csharp
// JwtValidationMiddleware.cs
public class JwtValidationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly TokenValidationParameters _validationParams;
    private readonly ITokenService _tokenService;

    public async Task InvokeAsync(HttpContext context)
    {
        var token = ExtractToken(context);

        if (token is not null)
        {
            try
            {
                var handler    = new JwtSecurityTokenHandler();
                var principal  = handler.ValidateToken(token, _validationParams, out var validatedToken);
                var jwtToken   = (JwtSecurityToken)validatedToken;

                var userId = long.Parse(principal.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
                var jti    = jwtToken.Id;

                // Check revocation (Redis lookup — fast)
                if (await _tokenService.IsTokenRevokedAsync(userId, jti))
                {
                    context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                    await context.Response.WriteAsJsonAsync(new { error = "Token revoked" });
                    return;
                }

                context.User = principal;
            }
            catch (SecurityTokenException)
            {
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                return;
            }
        }

        await _next(context);
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Token lifetime | 15 min access / 7 day refresh | Short access tokens limit breach window; refresh for UX |
| Refresh token storage | DB (hashed) | Enables revocation, rotation, audit; plaintext refresh tokens are secrets |
| Access token revocation | Redis blocklist | JWTs are stateless; blocklist handles edge cases (password change, logout-all) |
| Token rotation | Rotate on every refresh | Detect replay attacks (stolen refresh token); if old token reused, revoke all |
| RBAC storage | Claims in JWT | Avoids DB lookup per request; roles don't change frequently |

---

---

# Problem 12: Inventory Management with Reservations

## Asked At
Flipkart, Meesho, PharmEasy, BigBasket, 1mg — especially for flash sales

---

## Requirements

### Functional
- Track inventory per SKU per warehouse
- Reserve stock when item added to cart
- Commit reservation on order placement
- Release reservation on cart abandonment (TTL-based)
- Handle overselling prevention during flash sales

### Non-Functional
- Flash sale: 100K simultaneous add-to-cart for same item
- No overselling — strictly enforce stock limits
- Low latency reserve: < 50ms

---

## The Core Problem: Preventing Overselling Under High Concurrency

```
100K users simultaneously try to buy the last 10 units.
Solution: Redis atomic decrement + DB validation on commit.
```

---

## .NET Implementation

### Redis-Based Fast Reservation

```csharp
// InventoryReservationService.cs
public class InventoryReservationService : IInventoryReservationService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IInventoryRepository   _dbRepo;

    // Redis Lua: atomic check-and-reserve
    private const string ReserveLua = @"
        local key = KEYS[1]
        local qty = tonumber(ARGV[1])
        local current = tonumber(redis.call('GET', key) or '0')
        if current >= qty then
            redis.call('DECRBY', key, qty)
            return 1  -- success
        else
            return 0  -- insufficient stock
        end
    ";

    public async Task<ReservationResult> ReserveAsync(ReservationRequest request)
    {
        var stockKey = $"stock:available:{request.SkuId}:{request.WarehouseId}";
        var db       = _redis.GetDatabase();

        // Atomic check-and-decrement in Redis (handles 100K concurrent requests)
        var result = (int)await db.ScriptEvaluateAsync(
            ReserveLua,
            new RedisKey[]  { stockKey },
            new RedisValue[] { request.Quantity }
        );

        if (result == 0)
            return ReservationResult.InsufficientStock();

        // Create reservation record (for TTL-based release)
        var reservationId = Guid.NewGuid();
        var reservationKey = $"reservation:{reservationId}";

        await db.StringSetAsync(
            reservationKey,
            JsonSerializer.Serialize(new
            {
                SkuId       = request.SkuId,
                WarehouseId = request.WarehouseId,
                Quantity    = request.Quantity,
                CartId      = request.CartId
            }),
            TimeSpan.FromMinutes(15) // auto-release in 15 min if cart abandoned
        );

        // Also track in DB asynchronously (for reporting, not critical path)
        _ = _dbRepo.CreateReservationAsync(new ReservationEntity
        {
            Id          = reservationId,
            SkuId       = request.SkuId,
            WarehouseId = request.WarehouseId,
            Quantity    = request.Quantity,
            ExpiresAt   = DateTime.UtcNow.AddMinutes(15)
        });

        return ReservationResult.Success(reservationId);
    }

    public async Task CommitReservationAsync(Guid reservationId)
    {
        var db  = _redis.GetDatabase();
        var key = $"reservation:{reservationId}";

        var data = await db.StringGetAsync(key);
        if (!data.HasValue)
            throw new ReservationExpiredException(reservationId);

        // Delete Redis reservation (no need to restore Redis stock — it was already decremented)
        await db.KeyDeleteAsync(key);

        // Commit to DB: decrement actual inventory
        await _dbRepo.CommitReservationAsync(reservationId);
    }

    public async Task ReleaseReservationAsync(Guid reservationId)
    {
        var db  = _redis.GetDatabase();
        var key = $"reservation:{reservationId}";

        var data = await db.StringGetAsync(key);
        if (!data.HasValue) return; // already expired/released

        var reservation = JsonSerializer.Deserialize<ReservationData>(data!);
        var stockKey    = $"stock:available:{reservation!.SkuId}:{reservation.WarehouseId}";

        // Restore Redis stock atomically
        await db.StringIncrementAsync(stockKey, reservation.Quantity);
        await db.KeyDeleteAsync(key);

        // Update DB
        await _dbRepo.ReleaseReservationAsync(reservationId);
    }
}
```

### Redis Stock Sync Background Service

```csharp
// StockSyncService.cs — periodically syncs Redis with DB to handle Redis crashes
public class StockSyncService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        var timer = new PeriodicTimer(TimeSpan.FromMinutes(5));
        while (await timer.WaitForNextTickAsync(ct))
        {
            var skus = await _dbRepo.GetAllActiveSkusAsync();
            var db   = _redis.GetDatabase();

            foreach (var sku in skus)
            {
                var availableStock = sku.TotalStock - sku.CommittedStock;
                var stockKey       = $"stock:available:{sku.Id}:{sku.WarehouseId}";

                // SET only if Redis key doesn't exist (don't overwrite live reservations)
                // Use NX flag: only set if Not eXists
                await db.StringSetAsync(stockKey, availableStock,
                    when: When.NotExists);
            }
        }
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Fast path | Redis atomic decrement | Handles flash sale concurrency without DB locking |
| Reservation expiry | Redis TTL | Automatic cart abandonment release; no explicit cleanup needed |
| DB sync | Async (fire-and-forget) | DB write not in critical path; availability > consistency here |
| Overselling risk | Redis + Lua atomic | Lua runs atomically on single Redis node; no race condition |
| Redis crash recovery | 5-min sync job | Restores Redis from DB; brief inconsistency acceptable |

---

---

# Common Cross-Cutting Patterns

## 1. Transactional Outbox (Prevents event loss after DB commit)

```csharp
// Instead of publishing event separately, write to outbox table in same transaction:
await using var tx = await db.Database.BeginTransactionAsync();

db.Orders.Add(order);
db.OutboxMessages.Add(new OutboxMessage
{
    Id      = Guid.NewGuid(),
    Topic   = "order.placed",
    Payload = JsonSerializer.Serialize(orderEvent),
    Status  = OutboxStatus.Pending
});

await db.SaveChangesAsync(); // Both order and outbox in same transaction
await tx.CommitAsync();

// Separate poller picks up outbox messages and publishes to Kafka
// (at-least-once; use idempotency key in consumer to handle duplicates)
```

## 2. Circuit Breaker (Polly)

```csharp
// Program.cs
builder.Services.AddHttpClient<IPaymentGateway, PaymentGateway>()
    .AddResilienceHandler("payment", pipeline =>
    {
        pipeline.AddCircuitBreaker(new CircuitBreakerStrategyOptions
        {
            FailureRatio          = 0.5,      // open if 50% fail
            SamplingDuration      = TimeSpan.FromSeconds(30),
            MinimumThroughput     = 10,
            BreakDuration         = TimeSpan.FromSeconds(30),
            OnOpened              = args => { _logger.LogWarning("Circuit opened: {Outcome}", args.Outcome); return default; }
        });
        pipeline.AddRetry(new RetryStrategyOptions
        {
            MaxRetryAttempts    = 3,
            BackoffType         = DelayBackoffType.Exponential,
            Delay               = TimeSpan.FromMilliseconds(200)
        });
        pipeline.AddTimeout(TimeSpan.FromSeconds(5));
    });
```

## 3. Health Checks

```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "postgres")
    .AddRedis(redisConnectionString, name: "redis")
    .AddKafka(kafkaConfig, name: "kafka");

app.MapHealthChecks("/health",     new() { ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse });
app.MapHealthChecks("/health/live",  new() { Predicate = _ => false }); // always alive if process running
app.MapHealthChecks("/health/ready", new() { Predicate = hc => hc.Tags.Contains("ready") });
```

---

# Interview Answer Framework — Quick Reference

## Estimation Templates

```
READS:    QPS × P99 latency × 1.5 (headroom) = connections needed
WRITES:   TPS × record_size = storage growth/sec
STORAGE:  write_rate × record_size × 86400 × 365 × years × replication_factor
CACHE:    if Pareto (80/20) applies: 20% of data = 80% of reads → cache 20% of dataset
```

## Database Selection Guide

```
Use PostgreSQL when:  ACID, relational, complex queries, financial data
Use Cassandra when:   High write throughput, time-series, event log, chat messages
Use Redis when:       Caching, sessions, leaderboards, rate limiting, pub-sub, geo queries
Use Elasticsearch:    Full-text search, fuzzy, faceted, analytics
Use MongoDB:          Flexible schema, document hierarchies, catalog data
Use InfluxDB/TimescaleDB: Metrics, IoT data, monitoring
```

## CAP Theorem Quick Application

```
Payment systems:      CP (Consistency over Availability — can't show wrong balance)
Social media feed:    AP (Availability over Consistency — stale feed is OK)
Inventory (flash):    CP (prevent overselling — Consistency critical)
Autocomplete:         AP (stale suggestions are fine)
Chat messages:        AP + eventual consistency (deliver in order eventually)
```

---

---

# Problem 13: Leaderboard / Real-time Ranking System

## Asked At
Groww, Zerodha (portfolio P&L leaderboard), Dream11 (fantasy sports rank), MPL, CRED (rewards gamification), upGrad (learning streaks)

---

## Requirements

### Functional
- Update a user's score in real time (trade P&L, fantasy points, quiz score)
- Get user's current rank (globally or within a cohort/group)
- Get top-N leaderboard (paginated)
- Get rank of user + N neighbors (context window around user)
- Historical snapshots (daily/weekly/monthly leaderboard)

### Non-Functional
- Rank update latency < 50ms
- 5M concurrent users on Dream11 during IPL match
- Read-heavy: top-10 fetched every second by millions
- Leaderboard resets on schedule (weekly, per-contest)

---

## Capacity Estimation

```
Active users during IPL:  5M
Score updates/sec:        500K (every ball, every trade event)
Top-10 reads/sec:         2M  (everyone refreshing)
User rank reads/sec:      1M

Redis Sorted Set size:    5M members × ~50 bytes = 250 MB per leaderboard
```

---

## Architecture

```
  Score Event         ┌──────────────────────────────────────────┐
(trade/fantasy/quiz)  │           Score Ingestion API            │
─────────────────────→│           (.NET 10 Minimal API)          │
                      └────────────────┬─────────────────────────┘
                                       │
                          ┌────────────▼────────────┐
                          │   Redis Sorted Set      │
                          │   (live leaderboard)    │
                          │                         │
                          │  ZADD  → update score   │
                          │  ZRANK → get rank        │
                          │  ZRANGE → top-N          │
                          └────────────┬────────────┘
                                       │ async snapshot
                          ┌────────────▼────────────┐
                          │   PostgreSQL            │
                          │   (historical snapshots │
                          │    + user profiles)     │
                          └────────────┬────────────┘
                                       │
                          ┌────────────▼────────────┐
                          │   Kafka                 │
                          │   (score.updated events)│
                          │   → notification worker │
                          │     (rank milestone)    │
                          └─────────────────────────┘
```

---

## Database Schema

```sql
-- PostgreSQL: leaderboard snapshots (historical)
CREATE TABLE leaderboard_snapshots (
    id              BIGSERIAL    PRIMARY KEY,
    leaderboard_id  VARCHAR(100) NOT NULL,   -- "global_weekly_2026_W11"
    user_id         BIGINT       NOT NULL,
    score           NUMERIC(15,4) NOT NULL,
    rank            INT          NOT NULL,
    snapshot_at     TIMESTAMPTZ  NOT NULL,
    UNIQUE (leaderboard_id, user_id)
);

CREATE INDEX idx_snapshot_lb_rank ON leaderboard_snapshots(leaderboard_id, rank);

-- User score history (for audit/dispute)
CREATE TABLE score_events (
    id              BIGSERIAL    PRIMARY KEY,
    leaderboard_id  VARCHAR(100) NOT NULL,
    user_id         BIGINT       NOT NULL,
    delta           NUMERIC(15,4) NOT NULL,  -- positive or negative
    source          VARCHAR(50),             -- "trade", "quiz_answer", "fantasy_points"
    reference_id    VARCHAR(200),            -- trade ID, question ID
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX idx_score_events_user ON score_events(leaderboard_id, user_id, created_at DESC);
```

---

## Redis Data Model

```
Key pattern:  leaderboard:{leaderboard_id}
Type:         Sorted Set
Member:       user_id (string)
Score:        cumulative score (double — Redis sorts ascending by default, use negation for desc)

Examples:
  leaderboard:global_weekly  → { "user:1001": 9850.5, "user:2233": 8720.0, ... }
  leaderboard:contest:ipl_2026_m01 → { "user:5541": 120, ... }
```

---

## .NET Implementation

### Leaderboard Service

```csharp
// LeaderboardService.cs
public class LeaderboardService : ILeaderboardService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly ILeaderboardRepository _repo;
    private readonly IEventPublisher        _events;

    // Called on every score event (trade executed, quiz answered, etc.)
    public async Task UpdateScoreAsync(ScoreUpdateRequest request)
    {
        var db  = _redis.GetDatabase();
        var key = LeaderboardKey(request.LeaderboardId);

        // ZINCRBY: atomic increment — handles concurrent updates safely
        // Returns new total score
        var newScore = await db.SortedSetIncrementAsync(
            key,
            request.UserId.ToString(),
            (double)request.ScoreDelta
        );

        // Async: persist to score_events for audit (not on critical path)
        _ = _repo.AppendScoreEventAsync(new ScoreEvent
        {
            LeaderboardId = request.LeaderboardId,
            UserId        = request.UserId,
            Delta         = request.ScoreDelta,
            Source        = request.Source,
            ReferenceId   = request.ReferenceId
        });

        // Publish milestone events (e.g., entered top 10, rank 1)
        _ = CheckAndPublishMilestoneAsync(request.LeaderboardId, request.UserId, newScore);
    }

    // Get top-N — most called method, must be sub-millisecond
    public async Task<IEnumerable<LeaderboardEntry>> GetTopAsync(
        string leaderboardId, int topN = 100, int offset = 0)
    {
        var db  = _redis.GetDatabase();
        var key = LeaderboardKey(leaderboardId);

        // ZREVRANGEBYSCORE with scores — highest score first
        var entries = await db.SortedSetRangeByRankWithScoresAsync(
            key,
            start: offset,
            stop:  offset + topN - 1,
            order: Order.Descending    // highest score = rank 1
        );

        // Enrich with user display info (cached separately)
        var userIds     = entries.Select(e => long.Parse(e.Element!)).ToArray();
        var userProfiles = await GetCachedProfilesAsync(userIds);

        return entries.Select((e, i) => new LeaderboardEntry
        {
            Rank        = offset + i + 1,
            UserId      = long.Parse(e.Element!),
            Score       = (decimal)e.Score,
            DisplayName = userProfiles.GetValueOrDefault(long.Parse(e.Element!))?.DisplayName ?? "Unknown"
        });
    }

    // Get a user's rank + N neighbors (the "you are here" view)
    public async Task<UserRankContext> GetUserRankContextAsync(
        string leaderboardId, long userId, int neighborCount = 5)
    {
        var db  = _redis.GetDatabase();
        var key = LeaderboardKey(leaderboardId);

        // ZREVRANK: 0-indexed rank from top
        var zeroBasedRank = await db.SortedSetRankAsync(
            key,
            userId.ToString(),
            Order.Descending
        );

        if (zeroBasedRank is null)
            return UserRankContext.NotOnLeaderboard();

        var rank   = (int)zeroBasedRank.Value + 1; // 1-indexed
        var score  = await db.SortedSetScoreAsync(key, userId.ToString());

        // Fetch neighbors: N above and N below
        var windowStart = Math.Max(0, (int)zeroBasedRank.Value - neighborCount);
        var windowEnd   = (int)zeroBasedRank.Value + neighborCount;

        var neighbors = await GetTopAsync(leaderboardId, windowEnd - windowStart + 1, windowStart);

        return new UserRankContext
        {
            UserId    = userId,
            Rank      = rank,
            Score     = (decimal)(score ?? 0),
            Neighbors = neighbors.ToList()
        };
    }

    // Leaderboard reset — called by scheduled job (weekly/daily)
    public async Task ResetLeaderboardAsync(string leaderboardId)
    {
        var db  = _redis.GetDatabase();
        var key = LeaderboardKey(leaderboardId);

        // 1. Snapshot current state to PostgreSQL before reset
        var totalMembers = await db.SortedSetLengthAsync(key);
        const int batchSize = 1000;

        for (long offset = 0; offset < totalMembers; offset += batchSize)
        {
            var batch = await db.SortedSetRangeByRankWithScoresAsync(
                key, offset, offset + batchSize - 1, Order.Descending);

            var snapshots = batch.Select((e, i) => new LeaderboardSnapshot
            {
                LeaderboardId = leaderboardId,
                UserId        = long.Parse(e.Element!),
                Score         = (decimal)e.Score,
                Rank          = (int)(offset + i + 1),
                SnapshotAt    = DateTime.UtcNow
            }).ToList();

            await _repo.BulkInsertSnapshotAsync(snapshots);
        }

        // 2. Delete the key (reset all scores to 0)
        await db.KeyDeleteAsync(key);

        _logger.LogInformation("Leaderboard {Id} reset — {Count} users snapshotted",
            leaderboardId, totalMembers);
    }

    private async Task CheckAndPublishMilestoneAsync(
        string leaderboardId, long userId, double newScore)
    {
        var rank = await _redis.GetDatabase()
            .SortedSetRankAsync(LeaderboardKey(leaderboardId), userId.ToString(), Order.Descending);

        if (rank is null) return;
        var rankInt = (int)rank.Value + 1;

        // Milestone thresholds: entered top 10, top 100, rank 1
        if (rankInt == 1 || rankInt == 10 || rankInt == 100)
        {
            await _events.PublishAsync("leaderboard.milestone", new MilestoneEvent
            {
                UserId        = userId,
                LeaderboardId = leaderboardId,
                Rank          = rankInt,
                Score         = (decimal)newScore
            });
        }
    }

    private static string LeaderboardKey(string id) => $"leaderboard:{id}";
}
```

### Leaderboard API Endpoints

```csharp
// Program.cs (Minimal API)
app.MapPost("/api/v1/leaderboards/{id}/scores", async (
    string id, ScoreUpdateRequest req, ILeaderboardService svc) =>
{
    await svc.UpdateScoreAsync(req with { LeaderboardId = id });
    return Results.NoContent();
});

app.MapGet("/api/v1/leaderboards/{id}/top", async (
    string id, int top = 100, int offset = 0, ILeaderboardService svc) =>
    Results.Ok(await svc.GetTopAsync(id, top, offset)));

app.MapGet("/api/v1/leaderboards/{id}/users/{userId}/rank", async (
    string id, long userId, ILeaderboardService svc) =>
    Results.Ok(await svc.GetUserRankContextAsync(id, userId)));
```

### Leaderboard Reset Scheduled Job

```csharp
// WeeklyLeaderboardResetJob.cs
public class WeeklyLeaderboardResetJob : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        // Fire every Sunday midnight IST
        var timer = new PeriodicTimer(TimeSpan.FromHours(1));
        while (await timer.WaitForNextTickAsync(ct))
        {
            var now = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow,
                          TimeZoneInfo.FindSystemTimeZoneById("India Standard Time"));

            if (now.DayOfWeek == DayOfWeek.Sunday && now.Hour == 0)
            {
                var activeLeaderboards = await _repo.GetActiveLeaderboardIdsAsync();
                foreach (var id in activeLeaderboards)
                    await _leaderboardService.ResetLeaderboardAsync(id);
            }
        }
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Core data structure | Redis Sorted Set | O(log N) for ZADD/ZRANK; O(log N + M) for range queries; perfect fit |
| Score ordering | Descending via `Order.Descending` | Highest score = rank 1; no need for score negation in StackExchange.Redis |
| Snapshotting | Batch to PostgreSQL before reset | Historical leaderboards needed for prize disbursement + disputes |
| User profile data | Separate cache | Leaderboard sorted set holds only userId + score; display names cached apart to keep sorted set lean |
| Rank ties | Redis assigns no tie-breaking by default | Tied users get same score; break ties by insert order (first to reach score wins) if needed via composite score: `score * 1e9 + (MaxTs - ts)` |
| Milestone notifications | Async fire-and-forget | Don't slow down score update API for notification delivery |

---

## Interview Deep-Dive Questions (Dream11/Groww Style)

1. **"Redis can only hold data in memory — 5M users × 100 leaderboards = too much?"**
   → Each entry is ~50 bytes. 5M × 50B = 250MB per leaderboard. 10 active leaderboards = 2.5GB — fits in a Redis node. Archive inactive leaderboards to PostgreSQL.

2. **"What if Redis crashes during IPL final — leaderboard lost?"**
   → Redis AOF persistence (append-only log) + Redis replication. On crash, replica promotes. Score events in Kafka can replay to rebuild.

3. **"Two users submit score at the exact same millisecond — race condition?"**
   → `ZINCRBY` is atomic at Redis command level. No race condition. Sequential on single Redis node.

4. **"How to support group/cohort leaderboards (only friends)?"**
   → Separate sorted set per group: `leaderboard:group:{groupId}`. Fan-out score updates to all groups the user belongs to. Bounded by max group size.

---

---

# Problem 14: API Gateway / Backend for Frontend (BFF)

## Asked At
TCS, Infosys, HCL, Wipro, Cognizant (mandatory for microservices architecture rounds), Flipkart platform team, Razorpay developer platform

---

## Requirements

### Functional
- Route incoming requests to correct downstream microservices
- Aggregate responses from multiple services into one response (BFF)
- Authentication: validate JWT before forwarding
- Rate limiting per client/API key
- Request/response transformation (rename fields, filter sensitive data)
- Circuit breaker per downstream service

### Non-Functional
- Gateway overhead < 5ms
- 99.999% availability (single point of entry for all traffic)
- Zero-downtime service routing changes
- Detailed request tracing (correlationId across all services)

---

## Architecture

```
 External         ┌──────────────────────────────────────────────────────┐
 Clients          │                    API Gateway                        │
──────────────→   │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │
                  │  │  Auth    │ │  Rate    │ │ Routing  │ │  BFF   │  │
                  │  │Middleware│→│  Limiter │→│  (YARP)  │→│ Aggreg │  │
                  │  └──────────┘ └──────────┘ └────┬─────┘ └───┬────┘  │
                  └───────────────────────────────────┼──────────┼───────┘
                                                      │          │
                     ┌────────────────┬───────────────┘          │ aggregate
                     ▼                ▼                          ▼
              ┌────────────┐  ┌──────────────┐    ┌─────────────────────┐
              │ Order Svc  │  │  User Svc    │    │  Order + User +     │
              │ :8001      │  │  :8002       │    │  Inventory combined │
              └────────────┘  └──────────────┘    └─────────────────────┘
              ┌────────────┐  ┌──────────────┐
              │Inventory   │  │ Payment Svc  │
              │ Svc :8003  │  │  :8004       │
              └────────────┘  └──────────────┘
```

---

## .NET Implementation — YARP-Based Gateway

YARP (Yet Another Reverse Proxy) is Microsoft's production-grade reverse proxy library for .NET. Used by Bing, Teams, and Azure internally.

### Project Setup

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .AddConfigFilter<AuthConfigFilter>();   // dynamic config transforms

builder.Services.AddSingleton<IRateLimiter, TokenBucketRateLimiter>();
builder.Services.AddHttpContextAccessor();

var app = builder.Build();

// Middleware pipeline — ORDER MATTERS
app.UseMiddleware<CorrelationIdMiddleware>();   // 1. Stamp all requests with trace ID
app.UseMiddleware<RequestLoggingMiddleware>();  // 2. Log incoming request
app.UseMiddleware<AuthMiddleware>();            // 3. Validate JWT
app.UseMiddleware<RateLimitMiddleware>();       // 4. Enforce rate limits
app.MapReverseProxy(pipeline =>
{
    pipeline.UsePassiveHealthChecks();         // 5. Skip unhealthy upstreams
});

app.Run();
```

### YARP Configuration (appsettings.json)

```json
{
  "ReverseProxy": {
    "Routes": {
      "orders-route": {
        "ClusterId": "orders-cluster",
        "Match": { "Path": "/api/v1/orders/{**catch-all}" },
        "Transforms": [
          { "PathPattern": "/api/orders/{**catch-all}" },
          { "RequestHeader": "X-Internal-Gateway", "Set": "true" },
          { "ResponseHeader": "X-Powered-By", "Remove": "true" }
        ]
      },
      "users-route": {
        "ClusterId": "users-cluster",
        "Match": { "Path": "/api/v1/users/{**catch-all}" },
        "Transforms": [
          { "PathPattern": "/api/users/{**catch-all}" }
        ]
      },
      "payments-route": {
        "ClusterId": "payments-cluster",
        "Match": {
          "Path": "/api/v1/payments/{**catch-all}",
          "Headers": [{ "Name": "X-API-Key", "Mode": "Exists" }]
        }
      }
    },
    "Clusters": {
      "orders-cluster": {
        "HealthCheck": {
          "Passive": { "Enabled": true },
          "Active": { "Enabled": true, "Interval": "00:00:10", "Path": "/health" }
        },
        "Destinations": {
          "orders-1": { "Address": "http://orders-svc:8001/" },
          "orders-2": { "Address": "http://orders-svc-2:8001/" }
        }
      },
      "users-cluster": {
        "LoadBalancingPolicy": "RoundRobin",
        "Destinations": {
          "users-1": { "Address": "http://users-svc:8002/" }
        }
      },
      "payments-cluster": {
        "LoadBalancingPolicy": "LeastRequests",
        "Destinations": {
          "payments-1": { "Address": "http://payments-svc:8004/" }
        }
      }
    }
  }
}
```

### Correlation ID Middleware

```csharp
// CorrelationIdMiddleware.cs
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string HeaderName = "X-Correlation-Id";

    public async Task InvokeAsync(HttpContext context)
    {
        // Accept from client or generate new
        var correlationId = context.Request.Headers[HeaderName].FirstOrDefault()
                            ?? Guid.NewGuid().ToString("N");

        context.Items["CorrelationId"] = correlationId;

        // Add to all downstream request headers (YARP will forward)
        context.Request.Headers[HeaderName] = correlationId;

        // Add to response so client can trace
        context.Response.OnStarting(() =>
        {
            context.Response.Headers[HeaderName] = correlationId;
            return Task.CompletedTask;
        });

        // Structured logging scope
        using (_logger.BeginScope(new Dictionary<string, object>
               { ["CorrelationId"] = correlationId }))
        {
            await _next(context);
        }
    }
}
```

### BFF Aggregator — Combine Multiple Service Calls

```csharp
// OrderDashboardAggregator.cs — custom endpoint, NOT reverse proxied
// Returns combined order + user + inventory data in one call
[ApiController]
[Route("api/v1/dashboard")]
public class DashboardController : ControllerBase
{
    private readonly IHttpClientFactory _httpFactory;

    [HttpGet("orders/{orderId}")]
    public async Task<IActionResult> GetOrderDashboard(Guid orderId)
    {
        var http = _httpFactory.CreateClient("internal"); // pre-configured with base URL + auth

        // Fan-out: call all 3 services in parallel
        var orderTask     = http.GetFromJsonAsync<OrderDto>($"http://orders-svc/api/orders/{orderId}");
        var inventoryTask = http.GetFromJsonAsync<InventoryDto>($"http://inventory-svc/api/inventory/order/{orderId}");

        await Task.WhenAll(orderTask, inventoryTask);

        var order     = await orderTask;
        var inventory = await inventoryTask;

        // Fetch user profile only after we know the userId from order
        var user = await http.GetFromJsonAsync<UserDto>($"http://users-svc/api/users/{order!.CustomerId}");

        // Compose aggregated response — client makes 1 call instead of 3
        return Ok(new OrderDashboardResponse
        {
            Order         = order,
            Customer      = user,
            InventoryInfo = inventory
        });
    }
}
```

### Circuit Breaker per Downstream (Polly via Named HttpClient)

```csharp
// Program.cs — register named HttpClients with resilience
foreach (var service in new[] { "orders-svc", "users-svc", "payments-svc", "inventory-svc" })
{
    builder.Services.AddHttpClient(service, client =>
    {
        client.BaseAddress = new Uri($"http://{service}/");
        client.Timeout     = TimeSpan.FromSeconds(5);
    })
    .AddResilienceHandler($"{service}-pipeline", pipeline =>
    {
        pipeline.AddCircuitBreaker(new CircuitBreakerStrategyOptions
        {
            FailureRatio      = 0.5,
            SamplingDuration  = TimeSpan.FromSeconds(30),
            MinimumThroughput = 5,
            BreakDuration     = TimeSpan.FromSeconds(30),
            OnOpened = args =>
            {
                _logger.LogWarning("Circuit OPEN for {Service}", service);
                return default;
            }
        });
        pipeline.AddTimeout(TimeSpan.FromSeconds(3));
        pipeline.AddRetry(new RetryStrategyOptions
        {
            MaxRetryAttempts = 2,
            BackoffType      = DelayBackoffType.Exponential,
            Delay            = TimeSpan.FromMilliseconds(100)
        });
    });
}
```

### Dynamic Route Reload (Zero-Downtime Config Change)

```csharp
// RouteConfigProvider.cs — load routes from DB or config service
public class DatabaseRouteConfigProvider : IProxyConfigProvider
{
    private volatile InMemoryConfig _config;
    private readonly IRouteRepository _repo;

    public IProxyConfig GetConfig() => _config;

    // Call this when routes change in DB (via admin API)
    public async Task RefreshAsync()
    {
        var routes   = await _repo.GetRoutesAsync();
        var clusters = await _repo.GetClustersAsync();

        var newConfig = new InMemoryConfig(routes, clusters);
        var oldConfig = Interlocked.Exchange(ref _config, newConfig);
        oldConfig.SignalChange(); // YARP hot-reloads — zero downtime
    }
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Proxy library | YARP | Microsoft-built, .NET-native, hot-reload, production-proven at Bing scale |
| Auth location | Gateway middleware | Single enforcement point; downstream services trust `X-Internal-Gateway` header |
| BFF aggregation | Separate controller in gateway | YARP handles simple proxying; complex aggregation needs custom code |
| Circuit breaker | Per-downstream Polly | Isolate failures — one failing service doesn't cascade to others |
| Config storage | JSON + DB hybrid | JSON for base config; DB for dynamic per-tenant routing changes |
| Correlation ID | Generate at gateway | All downstream logs share same ID; enables distributed tracing (Jaeger/Zipkin) |

---

## Interview Deep-Dive Questions (Infosys/TCS Style)

1. **"Why use YARP over Nginx/Kong?"**
   → YARP is .NET-native — shares process, DI container, Polly policies, and middleware with the app. No separate Nginx process to manage. For .NET shops, simpler operations. Kong is better for polyglot.

2. **"How do you handle versioning across services?"**
   → Route-level path transforms in YARP: external `/api/v2/orders` → internal `/api/orders` (services own their own version). Gateway is version-agnostic.

3. **"What's the difference between API Gateway and BFF?"**
   → Gateway: generic routing/auth/rate-limit for all clients. BFF: client-specific aggregation (mobile BFF returns compressed, fewer fields; web BFF returns richer data). Often same process, different routes.

4. **"Single point of failure concern?"**
   → Deploy multiple gateway instances behind a cloud load balancer (Azure Application Gateway / AWS ALB). Gateway itself is stateless (JWT validation uses shared secret, rate limiting uses shared Redis).

---

---

# Problem 15: File / Document Storage System

## Asked At
Freshworks, Zoho, Persistent Systems, Hexaware, Mphasis, Healthcare GCCs (Cigna, UHG, Evicore-style), HRMS platforms (Darwinbox, Keka)

---

## Requirements

### Functional
- Upload files (up to 5 GB) with chunked/resumable upload
- Download via pre-signed URL (time-limited, no auth header needed)
- File versioning (keep last N versions)
- Deduplication (same file content = same storage, different records)
- Virus/malware scan before making file accessible
- Metadata: file name, type, size, uploader, tags, expiry

### Non-Functional
- Upload throughput: 10 GB/s aggregate
- Download: 100K concurrent, served from CDN
- Durability: 99.999999999% (11 nines) — Azure Blob / S3 provides this
- Storage optimization: deduplication saves ~30% for enterprise doc management

---

## Architecture

```
  Client              ┌──────────────────────────────────────────────┐
──────────────────→   │           File Service (.NET 10)             │
                      │                                              │
                      │  POST /upload/initiate  → create upload job  │
                      │  PUT  /upload/{id}/chunk → accept chunks     │
                      │  POST /upload/{id}/complete → assemble        │
                      │  GET  /files/{id}/download-url → presigned   │
                      └────────────────┬─────────────────────────────┘
                                       │
               ┌───────────────────────┼───────────────────────┐
               ▼                       ▼                       ▼
      ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
      │  Azure Blob      │   │  PostgreSQL       │   │  Redis           │
      │  Storage         │   │  (file metadata)  │   │  (upload state,  │
      │  (actual files)  │   │                  │   │   chunk tracking) │
      └──────────────────┘   └──────────────────┘   └──────────────────┘
               │
               │ on upload complete
      ┌────────▼─────────┐
      │  Kafka           │   → Virus Scanner Worker (ClamAV / Defender)
      │  file.uploaded   │   → Thumbnail Generator Worker
      └──────────────────┘   → Index Worker (Elasticsearch for search)
```

---

## Database Schema

```sql
-- File metadata
CREATE TABLE files (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    content_hash    VARCHAR(64)  NOT NULL,           -- SHA-256 of content (dedup key)
    storage_key     VARCHAR(500) NOT NULL,           -- Azure Blob path
    original_name   VARCHAR(500) NOT NULL,
    mime_type       VARCHAR(100),
    size_bytes      BIGINT       NOT NULL,
    uploader_id     BIGINT       NOT NULL,
    tenant_id       BIGINT       NOT NULL,
    status          VARCHAR(20)  DEFAULT 'processing', -- processing/clean/infected/failed
    version         INT          DEFAULT 1,
    parent_id       UUID         REFERENCES files(id), -- for versioning: points to previous version
    tags            JSONB,
    expires_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_files_content_hash_tenant ON files(content_hash, tenant_id);
CREATE INDEX idx_files_uploader  ON files(uploader_id, created_at DESC);
CREATE INDEX idx_files_tenant    ON files(tenant_id, status);

-- Upload sessions (for resumable chunked upload)
CREATE TABLE upload_sessions (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    uploader_id     BIGINT       NOT NULL,
    file_name       VARCHAR(500) NOT NULL,
    total_size      BIGINT       NOT NULL,
    chunk_size      INT          NOT NULL DEFAULT 5242880,  -- 5 MB
    total_chunks    INT          NOT NULL,
    status          VARCHAR(20)  DEFAULT 'in_progress',
    expires_at      TIMESTAMPTZ  DEFAULT NOW() + INTERVAL '24 hours',
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);
```

---

## .NET Implementation

### Chunked Upload Service

```csharp
// FileUploadService.cs
public class FileUploadService : IFileUploadService
{
    private readonly BlobServiceClient  _blobService;
    private readonly IFileRepository    _fileRepo;
    private readonly IDistributedCache  _cache;
    private readonly IEventPublisher    _events;

    // Step 1: Client calls this to initiate upload, gets session ID back
    public async Task<InitiateUploadResponse> InitiateUploadAsync(InitiateUploadRequest request)
    {
        var chunkSize   = 5 * 1024 * 1024;  // 5 MB per chunk
        var totalChunks = (int)Math.Ceiling((double)request.FileSizeBytes / chunkSize);

        var session = new UploadSession
        {
            Id          = Guid.NewGuid(),
            UploaderId  = request.UserId,
            FileName    = request.FileName,
            TotalSize   = request.FileSizeBytes,
            ChunkSize   = chunkSize,
            TotalChunks = totalChunks,
            ExpiresAt   = DateTime.UtcNow.AddHours(24)
        };

        await _fileRepo.CreateUploadSessionAsync(session);

        // Track received chunks in Redis (fast BitSet-like tracking)
        await _cache.SetStringAsync(
            $"upload:{session.Id}:chunks",
            new string('0', totalChunks),  // "000...0" — each char = one chunk
            new DistributedCacheEntryOptions { AbsoluteExpiration = session.ExpiresAt }
        );

        return new InitiateUploadResponse
        {
            SessionId   = session.Id,
            ChunkSize   = chunkSize,
            TotalChunks = totalChunks
        };
    }

    // Step 2: Client uploads each chunk (can be parallelised from client side)
    public async Task UploadChunkAsync(Guid sessionId, int chunkIndex, Stream chunkData)
    {
        var containerClient = _blobService.GetBlobContainerClient("uploads");
        var blockId         = Convert.ToBase64String(Encoding.UTF8.GetBytes(chunkIndex.ToString("D6")));
        var blobClient      = containerClient.GetBlockBlobClient($"chunks/{sessionId}");

        // Upload chunk as Azure Block Blob block (uncommitted)
        await blobClient.StageBlockAsync(blockId, chunkData);

        // Mark chunk received in Redis
        var db            = _cache;
        var trackingKey   = $"upload:{sessionId}:chunks";
        var currentMask   = await _cache.GetStringAsync(trackingKey) ?? string.Empty;

        if (chunkIndex < currentMask.Length)
        {
            var arr          = currentMask.ToCharArray();
            arr[chunkIndex]  = '1';
            await _cache.SetStringAsync(trackingKey, new string(arr),
                new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24) });
        }
    }

    // Step 3: Client calls complete — assembly + dedup check
    public async Task<CompleteUploadResponse> CompleteUploadAsync(
        Guid sessionId, string clientSha256Hash)
    {
        var session = await _fileRepo.GetUploadSessionAsync(sessionId)
            ?? throw new NotFoundException("Upload session not found or expired");

        // Verify all chunks received
        var mask = await _cache.GetStringAsync($"upload:{sessionId}:chunks") ?? "";
        if (mask.Contains('0'))
        {
            var missing = mask.Select((c, i) => (c, i)).Where(x => x.c == '0')
                              .Select(x => x.i).ToArray();
            throw new IncompleteUploadException(missing);
        }

        // Commit all blocks in order (Azure Blob: commit block list)
        var containerClient = _blobService.GetBlobContainerClient("uploads");
        var blobClient      = containerClient.GetBlockBlobClient($"chunks/{sessionId}");

        var blockList = Enumerable.Range(0, session.TotalChunks)
            .Select(i => Convert.ToBase64String(Encoding.UTF8.GetBytes(i.ToString("D6"))));

        await blobClient.CommitBlockListAsync(blockList);

        // Deduplication: check if this content hash already exists for this tenant
        var existing = await _fileRepo.GetByContentHashAsync(clientSha256Hash, session.TenantId);
        if (existing is not null)
        {
            // Don't store duplicate — point to existing storage
            var dedupFile = await _fileRepo.CreateFileRecordAsync(new FileEntity
            {
                ContentHash  = clientSha256Hash,
                StorageKey   = existing.StorageKey,  // reuse same blob
                OriginalName = session.FileName,
                SizeBytes    = session.TotalSize,
                UploaderId   = session.UploaderId,
                TenantId     = session.TenantId,
                Status       = FileStatus.Clean       // already scanned
            });

            // Clean up the duplicate upload blob
            await blobClient.DeleteIfExistsAsync();

            return new CompleteUploadResponse { FileId = dedupFile.Id, WasDeduplicated = true };
        }

        // Move from temp chunks path to permanent storage
        var permanentKey  = $"files/{session.TenantId}/{clientSha256Hash}";
        var destClient    = containerClient.GetBlockBlobClient(permanentKey);
        await destClient.StartCopyFromUriAsync(blobClient.Uri);
        await blobClient.DeleteIfExistsAsync();

        // Create file record (status = processing, pending virus scan)
        var fileEntity = await _fileRepo.CreateFileRecordAsync(new FileEntity
        {
            ContentHash  = clientSha256Hash,
            StorageKey   = permanentKey,
            OriginalName = session.FileName,
            SizeBytes    = session.TotalSize,
            UploaderId   = session.UploaderId,
            TenantId     = session.TenantId,
            Status       = FileStatus.Processing
        });

        // Trigger async processing pipeline
        await _events.PublishAsync("file.uploaded", new FileUploadedEvent
        {
            FileId     = fileEntity.Id,
            StorageKey = permanentKey,
            MimeType   = session.MimeType,
            TenantId   = session.TenantId
        });

        return new CompleteUploadResponse { FileId = fileEntity.Id, WasDeduplicated = false };
    }

    // Generate pre-signed download URL (client downloads directly from Azure Blob — no gateway bandwidth)
    public async Task<string> GenerateDownloadUrlAsync(Guid fileId, long requestingUserId,
        TimeSpan validity)
    {
        var file = await _fileRepo.GetAsync(fileId)
            ?? throw new NotFoundException($"File {fileId} not found");

        // Authorization check
        if (!await _authz.CanReadFileAsync(requestingUserId, file))
            throw new ForbiddenException();

        if (file.Status != FileStatus.Clean)
            throw new FileNotReadyException("File is still being processed or failed scanning");

        var containerClient = _blobService.GetBlobContainerClient("uploads");
        var blobClient      = containerClient.GetBlobClient(file.StorageKey);

        // SAS token: time-limited, read-only, no auth header needed (CDN-friendly)
        var sasUri = blobClient.GenerateSasUri(BlobSasPermissions.Read,
            DateTimeOffset.UtcNow.Add(validity));

        return sasUri.ToString();
    }
}
```

### Virus Scanner Worker

```csharp
// VirusScanWorker.cs — Kafka consumer
public class VirusScanWorker : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        using var consumer = BuildConsumer("file.uploaded");

        while (!ct.IsCancellationRequested)
        {
            var msg  = consumer.Consume(ct);
            var evt  = Deserialize<FileUploadedEvent>(msg.Message.Value);

            try
            {
                // Download from Blob to stream (don't buffer entire file in memory)
                var blobClient = _blobService
                    .GetBlobContainerClient("uploads")
                    .GetBlobClient(evt.StorageKey);

                await using var stream = await blobClient.OpenReadAsync(cancellationToken: ct);

                // ClamAV scan via TCP socket (Unix) or Windows Defender SDK
                var scanResult = await _scanner.ScanAsync(stream, ct);

                var newStatus = scanResult.IsClean
                    ? FileStatus.Clean
                    : FileStatus.Infected;

                await _fileRepo.UpdateStatusAsync(evt.FileId, newStatus,
                    scanResult.ThreatName);

                if (!scanResult.IsClean)
                {
                    // Quarantine: move to separate container, alert security team
                    await QuarantineFileAsync(evt.StorageKey);
                    await _events.PublishAsync("file.infected", new FileInfectedEvent
                    {
                        FileId     = evt.FileId,
                        ThreatName = scanResult.ThreatName,
                        TenantId   = evt.TenantId
                    });
                }
                else
                {
                    // Notify uploader file is ready
                    await _events.PublishAsync("file.ready", new FileReadyEvent
                    {
                        FileId    = evt.FileId,
                        TenantId  = evt.TenantId,
                        FileName  = evt.FileName
                    });
                }

                consumer.Commit(msg);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Scan failed for file {FileId}", evt.FileId);
                await _fileRepo.UpdateStatusAsync(evt.FileId, FileStatus.ScanFailed, ex.Message);
                consumer.Commit(msg);
            }
        }
    }
}
```

### File Versioning

```csharp
// FileVersioningService.cs
public async Task<FileEntity> UploadNewVersionAsync(
    Guid existingFileId, Stream newContent, long userId)
{
    var current = await _fileRepo.GetAsync(existingFileId)
        ?? throw new NotFoundException();

    // Upload new version (goes through same chunked upload flow)
    var newFile = await CreateFileAsync(newContent, userId);

    newFile.ParentId = existingFileId;   // link to previous version
    newFile.Version  = current.Version + 1;
    await _fileRepo.SaveAsync(newFile);

    // Enforce max versions policy (keep latest 10, delete older blobs)
    var allVersions = await _fileRepo.GetVersionHistoryAsync(existingFileId);
    var toDelete    = allVersions
        .OrderByDescending(v => v.Version)
        .Skip(10)  // keep 10 latest
        .ToList();

    foreach (var old in toDelete)
        await DeleteBlobAsync(old.StorageKey);

    return newFile;
}
```

---

## Trade-offs

| Decision | Choice | Reason |
|----------|--------|--------|
| Upload mechanism | Chunked (5MB blocks) | Large files need resume capability; Azure Block Blob natively supports uncommitted blocks |
| Deduplication | SHA-256 content hash | Identical files → same blob; saves storage for duplicate contracts/templates |
| Virus scan | Async after upload | Don't block upload completion; scan asynchronously and update status |
| Download mechanism | Pre-signed SAS URL | Client downloads directly from Azure CDN — no bandwidth through API servers |
| File status model | processing → clean/infected | File inaccessible until scanned; prevents access to unscanned files |
| Version storage | Separate records with parent_id | Full audit trail; can restore any version; old blobs deleted per retention policy |

---

## Interview Deep-Dive Questions (Healthcare GCC Style)

1. **"How do you handle files that fail virus scan — HIPAA/compliance?"**
   → Immediately quarantine to isolated container with no public access. Log to audit trail with timestamp, file hash, threat name. Alert security team via PagerDuty. Never delete — move to forensic storage.

2. **"What if client loses connection mid-upload?"**
   → Resumable upload: client re-initiates with same session ID, Redis tracks which chunks arrived, client re-uploads only missing chunks. Session valid for 24 hours.

3. **"Deduplication — is SHA-256 collision-safe?"**
   → SHA-256 collision probability is astronomically low (2^256). In practice, no known collision exists. For ultra-paranoid systems, also verify file size matches.

4. **"Scale: 10 million files/day upload throughput?"**
   → Azure Blob Storage scales horizontally. API layer stateless — scale out behind load balancer. Virus scan workers scale via Kafka consumer group partitions. PostgreSQL metadata: partition by tenant_id or use Citus for horizontal scale.

---

# Practice Checklist

For each problem you practice:

- [ ] State functional requirements without prompting
- [ ] Estimate QPS and storage within 2 minutes
- [ ] Draw architecture diagram (narrate while drawing)
- [ ] Explain DB choice and schema key design decisions
- [ ] Write core logic in .NET (at least pseudocode)
- [ ] Identify top 3 bottlenecks and how to solve each
- [ ] Answer: "What if X fails?" for each major component
- [ ] Answer: "How do you scale from 1K to 10M users?"
- [ ] Answer: "What monitoring/alerting would you set up?"

---

*Guide Version: 1.0 | Created: 2026-03-17 | Stack: .NET 10, PostgreSQL, Redis, Kafka, Elasticsearch, SignalR*


Here’s a **pure list of real system design problems** asked in **Indian product & service companies (incl. .NET roles)** — compiled from **Reddit threads, interview experiences, LinkedIn posts, and prep platforms** (no theory, just problems).

---

# 🔥 Real System Design Problems (India – .NET / Backend / Fullstack)

## 🟢 Common (VERY frequently asked in India)

* Design URL Shortener (TinyURL / Bitly)
* Design Notification System (Email + SMS + Push)
* Design Authentication System (JWT / OAuth / SSO)
* Design Rate Limiter (API Gateway level)
* Design Logging & Monitoring System
* Design Distributed Cache (Redis-like)
* Design File Upload Service (Azure Blob / S3 style)
* Design API Gateway (routing, throttling, auth)

👉 These are asked because interviewers check **practical backend thinking, not fancy systems**

---

## 🟡 Real Problems from Indian Interview Experiences (Reddit / LinkedIn)

### From Reddit discussions (developersIndia etc.)

* Design **parking lot system (LLD + HLD mix)**
* Design **multi-tenant SaaS system**
* Design **chat system (WhatsApp-like)**
* Design **job queue system (background processing)**
* Design **audit logging system for enterprise apps**
* Design **configurable workflow engine**
* Design **feature flag system**
* Design **document storage & versioning system**

💬 Example insight from Reddit:

> “Some interviewers focus on DB design, others on scalability, others on extensibility.” ([Reddit][1])

---

## 🟠 Product Companies (Flipkart, Amazon, Swiggy, Razorpay style)

* Design **payment system (UPI / wallet / Razorpay-like)**
* Design **order management system (e-commerce)**
* Design **inventory management system**
* Design **real-time delivery tracking system (Swiggy/Zomato)**
* Design **search autocomplete system**
* Design **recommendation system (basic level)**
* Design **high-scale product catalog system**
* Design **shopping cart system with concurrency**

---

## 🔴 FinTech / Banking (.NET-heavy domain in India)

* Design **transaction processing system**
* Design **fraud detection pipeline (basic design)**
* Design **ledger system (double-entry accounting)**
* Design **payment reconciliation system**
* Design **rate-limited secure API for banking**
* Design **KYC document verification system**

---

## 🟣 Enterprise / Service Companies (TCS, Infosys, Cognizant, Accenture)

* Design **HRMS system**
* Design **leave management system**
* Design **role-based access control (RBAC) system**
* Design **multi-region enterprise app (Azure-based)**
* Design **reporting/analytics system**
* Design **batch processing system (ETL jobs)**
* Design **file processing pipeline (CSV → DB → API)**

---

## 🔵 Real-world .NET-focused scenarios (VERY IMPORTANT for you)

These are **high probability for your profile (Architect / .NET / Azure)**:

* Design **microservices architecture using Azure App Services + APIM**
* Design **health check & monitoring system for microservices**
* Design **distributed caching with fallback (Redis + DB)**
* Design **event-driven system using Service Bus / Kafka**
* Design **secure API with Azure AD B2C**
* Design **multi-tenant SaaS using .NET + Azure**
* Design **file processing system using Azure Functions**
* Design **CI/CD pipeline + zero downtime deployment**

---

## 🟤 Advanced / Architect-Level (less common but asked for 10+ yrs)

* Design **global scalable system (multi-region, DR strategy)**
* Design **distributed locking system**
* Design **event sourcing + CQRS system**
* Design **real-time analytics pipeline**
* Design **system handling 1M+ concurrent users**
* Design **data consistency strategy across services**
* Design **graceful degradation system**

---

## ⚫ Classic Big-Tech style (also asked in Indian interviews now)

* Design WhatsApp
* Design YouTube
* Design Uber
* Design Netflix
* Design Google Docs
* Design BookMyShow (VERY common in India) ([DEV Community][2])

---

# 🧠 Important Reality (from real experiences)

* Same problem → **different expectations per interviewer**
* Focus areas vary:

  * HLD (components, scalability)
  * LLD (classes, DB schema)
  * Trade-offs (VERY important for senior roles)
* No single “correct” answer → evaluation is on **thinking process** ([Reddit][1])

---

# 🚀 If you want next level (highly recommended)

I can:

* Convert this into **Top 20 MUST prepare problems for your exact profile**
* Give **expected answers + architecture diagrams (Azure + .NET)**
* Run **mock architect-level system design interview**

Just tell:
👉 *“Give me top 20 with solutions”*

[1]: https://www.reddit.com/r/developersIndia/comments/ok3lvr/system_design_interviews_in_india/?utm_source=chatgpt.com "System Design Interviews in India : r/developersIndia"
[2]: https://dev.to/somadevtoo/top-50-system-design-interview-questions-for-2024-5dbk?utm_source=chatgpt.com "Top 50 System Design Interview Questions for 2026"
