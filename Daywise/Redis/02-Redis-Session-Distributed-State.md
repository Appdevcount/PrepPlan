# Redis — Session Management & Distributed State in .NET

> **Mental Model:** Session is a user's shopping cart at a supermarket.
> Without Redis, when the cashier changes (server restarts / load balancer), the cart vanishes.
> Redis is the central cart storage that any cashier (server instance) can access.

---

## Table of Contents
1. [The Problem with In-Process Session](#the-problem-with-in-process-session)
2. [ASP.NET Core Distributed Session with Redis](#aspnet-core-distributed-session-with-redis)
3. [Custom Session Store (Fine-Grained Control)](#custom-session-store-fine-grained-control)
4. [JWT + Redis Token Blacklist](#jwt--redis-token-blacklist)
5. [User Preferences & Per-User State](#user-preferences--per-user-state)
6. [Shopping Cart Implementation](#shopping-cart-implementation)
7. [Distributed Counters & Aggregates](#distributed-counters--aggregates)
8. [Feature Flags per User](#feature-flags-per-user)
9. [Temporary Tokens (Email Verification, Password Reset)](#temporary-tokens)
10. [Security Considerations](#security-considerations)

---

## The Problem with In-Process Session

```
┌─────────────────────────────────────────────────────────────────┐
│              WITHOUT REDIS (Sticky Sessions Problem)            │
│                                                                 │
│  User ──▶ Load Balancer ──▶ Server A (has session)            │
│  User ──▶ Load Balancer ──▶ Server B (NO session) ← FAIL      │
│                                                                 │
│              WITH REDIS (Stateless Servers)                     │
│                                                                 │
│  User ──▶ Load Balancer ──▶ Server A ──▶ Redis                │
│  User ──▶ Load Balancer ──▶ Server B ──▶ Redis (same session) │
│                                                                 │
│  ✅ Servers are stateless — any server handles any request     │
│  ✅ Server restarts don't lose session data                    │
│  ✅ Scale horizontally without sticky sessions                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## ASP.NET Core Distributed Session with Redis

### Setup
```csharp
// ── Program.cs ────────────────────────────────────────────────────────
// NuGet: Microsoft.Extensions.Caching.StackExchangeRedis

builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis");
    options.InstanceName = "session:"; // WHY: namespace prefix prevents key collisions
});

builder.Services.AddSession(options =>
{
    // WHY: 20 min idle timeout — industry standard for security
    options.IdleTimeout = TimeSpan.FromMinutes(20);

    // WHY: HttpOnly prevents JavaScript from reading session cookie (XSS protection)
    options.Cookie.HttpOnly = true;

    // WHY: Essential=true bypasses cookie consent for session cookies
    options.Cookie.IsEssential = true;

    // WHY: Secure=true sends cookie only over HTTPS
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;

    options.Cookie.SameSite = SameSiteMode.Strict; // WHY: CSRF protection
});

app.UseSession(); // Must be before UseRouting/MapControllers
```

### Basic Usage
```csharp
public class SessionController : ControllerBase
{
    // WHY: Session is stored as byte arrays in Redis — helper extensions for convenience
    public IActionResult SetSession()
    {
        HttpContext.Session.SetString("username", "alice");
        HttpContext.Session.SetInt32("userId", 42);

        // Complex objects — serialize to JSON bytes
        var prefs = new UserPreferences { Theme = "dark", Language = "en" };
        HttpContext.Session.Set("preferences",
            JsonSerializer.SerializeToUtf8Bytes(prefs));

        return Ok();
    }

    public IActionResult GetSession()
    {
        var username = HttpContext.Session.GetString("username"); // null if not set
        var userId = HttpContext.Session.GetInt32("userId");

        var prefBytes = HttpContext.Session.Get("preferences");
        var prefs = prefBytes is not null
            ? JsonSerializer.Deserialize<UserPreferences>(prefBytes)
            : null;

        return Ok(new { username, userId, prefs });
    }

    public IActionResult ClearSession()
    {
        HttpContext.Session.Clear(); // WHY: Removes all session keys but keeps the session cookie
        return Ok();
    }
}
```

### Session Extension Helper
```csharp
// WHY: Extension methods provide type-safe session access without scattered JSON code
public static class SessionExtensions
{
    public static void SetObject<T>(this ISession session, string key, T value)
        => session.Set(key, JsonSerializer.SerializeToUtf8Bytes(value));

    public static T? GetObject<T>(this ISession session, string key)
    {
        var bytes = session.Get(key);
        return bytes is null ? default : JsonSerializer.Deserialize<T>(bytes);
    }
}

// Usage
HttpContext.Session.SetObject("cart", shoppingCart);
var cart = HttpContext.Session.GetObject<ShoppingCart>("cart");
```

---

## Custom Session Store (Fine-Grained Control)

```csharp
// WHY: Custom store gives full control over key structure, TTL logic, and events
// Use when you need: audit logging, session metadata, concurrent session limits

public class RedisSessionStore
{
    private readonly IDatabase _redis;
    private const string SessionPrefix = "session:";
    private static readonly TimeSpan SessionTtl = TimeSpan.FromMinutes(20);

    public async Task<UserSession?> GetAsync(string sessionId, CancellationToken ct)
    {
        var key = $"{SessionPrefix}{sessionId}";

        // Get all session fields from Hash
        var hash = await _redis.HashGetAllAsync(key);
        if (hash.Length == 0) return null;

        // WHY: Extend TTL on every access — sliding expiration behavior
        await _redis.KeyExpireAsync(key, SessionTtl);

        return new UserSession
        {
            SessionId = sessionId,
            UserId = int.Parse(hash.FirstOrDefault(e => e.Name == "userId").Value!),
            Username = hash.FirstOrDefault(e => e.Name == "username").Value!,
            CreatedAt = DateTime.Parse(hash.FirstOrDefault(e => e.Name == "createdAt").Value!),
            IpAddress = hash.FirstOrDefault(e => e.Name == "ip").Value!
        };
    }

    public async Task CreateAsync(UserSession session, CancellationToken ct)
    {
        var key = $"{SessionPrefix}{session.SessionId}";

        // WHY: Hash fields are more efficient than serialized JSON when fields need individual updates
        var fields = new HashEntry[]
        {
            new("userId", session.UserId),
            new("username", session.Username),
            new("createdAt", session.CreatedAt.ToString("O")),
            new("ip", session.IpAddress)
        };

        await _redis.HashSetAsync(key, fields);
        await _redis.KeyExpireAsync(key, SessionTtl);

        // WHY: Track all sessions per user to enable "logout from all devices"
        await _redis.SetAddAsync($"user:{session.UserId}:sessions", session.SessionId);
    }

    public async Task DeleteAsync(string sessionId, int userId, CancellationToken ct)
    {
        await _redis.KeyDeleteAsync($"{SessionPrefix}{sessionId}");
        await _redis.SetRemoveAsync($"user:{userId}:sessions", sessionId);
    }

    public async Task DeleteAllSessionsForUserAsync(int userId, CancellationToken ct)
    {
        // Get all session IDs for this user
        var sessions = await _redis.SetMembersAsync($"user:{userId}:sessions");

        // WHY: Batch delete all sessions in one pipeline for efficiency
        var batch = _redis.CreateBatch();
        var tasks = sessions
            .Select(s => batch.KeyDeleteAsync($"{SessionPrefix}{s}"))
            .ToList();
        tasks.Add(batch.KeyDeleteAsync($"user:{userId}:sessions"));
        batch.Execute();
        await Task.WhenAll(tasks);
    }
}
```

---

## JWT + Redis Token Blacklist

> **Problem:** JWTs are stateless — you can't revoke them before expiry.
> **Solution:** Redis blacklist — check every request if the JWT ID is in the blacklist.

```
┌───────────────────────────────────────────────────────────────┐
│               JWT BLACKLIST FLOW                              │
│                                                               │
│  Login  ──▶ Issue JWT (jti: uuid, exp: +1h)                  │
│                                                               │
│  Request ──▶ Validate JWT signature                          │
│           ──▶ Check Redis: SISMEMBER blacklist:{jti}         │
│                if in blacklist → 401 Unauthorized            │
│                else → proceed                                │
│                                                               │
│  Logout  ──▶ SADD blacklist:{jti} with TTL = JWT remaining exp│
└───────────────────────────────────────────────────────────────┘
```

```csharp
// ── Token Blacklist Service ────────────────────────────────────────────
public class TokenBlacklistService
{
    private readonly IDatabase _redis;
    private const string Prefix = "blacklist:";

    // WHY: Use the JWT 'jti' (JWT ID) claim as the blacklist key
    // Store the jti with TTL matching the JWT's remaining expiry
    public async Task RevokeAsync(string jti, DateTime jwtExpiry)
    {
        var remaining = jwtExpiry - DateTime.UtcNow;
        if (remaining <= TimeSpan.Zero) return; // Already expired, no need to blacklist

        await _redis.StringSetAsync($"{Prefix}{jti}", "revoked", remaining);
    }

    public async Task<bool> IsRevokedAsync(string jti)
        => await _redis.KeyExistsAsync($"{Prefix}{jti}");
}

// ── JWT Middleware integration ─────────────────────────────────────────
public class JwtBlacklistMiddleware
{
    private readonly RequestDelegate _next;

    public async Task InvokeAsync(HttpContext context,
        TokenBlacklistService blacklist,
        ILogger<JwtBlacklistMiddleware> logger)
    {
        // Only check authenticated requests
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var jti = context.User.FindFirst("jti")?.Value;
            if (jti is not null && await blacklist.IsRevokedAsync(jti))
            {
                logger.LogWarning("Revoked token access attempt for jti: {Jti}", jti);
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                return;
            }
        }

        await _next(context);
    }
}

// ── Logout endpoint ─────────────────────────────────────────────────────
app.MapPost("/auth/logout", async (
    ClaimsPrincipal user,
    TokenBlacklistService blacklist) =>
{
    var jti = user.FindFirst("jti")?.Value
        ?? throw new InvalidOperationException("Token missing jti claim");

    var exp = long.Parse(user.FindFirst("exp")?.Value ?? "0");
    var expiry = DateTimeOffset.FromUnixTimeSeconds(exp).UtcDateTime;

    await blacklist.RevokeAsync(jti, expiry);
    return Results.Ok(new { message = "Logged out successfully" });
}).RequireAuthorization();
```

---

## User Preferences & Per-User State

```csharp
// WHY: User preferences are read on every request — Redis Hash is ideal
// Individual field updates don't require deserializing the whole object
public class UserPreferencesService
{
    private readonly IDatabase _redis;
    private static readonly TimeSpan Ttl = TimeSpan.FromDays(30);

    private string Key(int userId) => $"prefs:{userId}";

    public async Task<UserPreferences> GetAsync(int userId)
    {
        var hash = await _redis.HashGetAllAsync(Key(userId));

        if (hash.Length == 0)
        {
            // Return defaults if no preferences stored
            return new UserPreferences();
        }

        var dict = hash.ToDictionary(e => e.Name.ToString(), e => e.Value.ToString());

        return new UserPreferences
        {
            Theme = dict.GetValueOrDefault("theme", "light"),
            Language = dict.GetValueOrDefault("language", "en"),
            ItemsPerPage = int.Parse(dict.GetValueOrDefault("itemsPerPage", "20")),
            NotificationsEnabled = bool.Parse(dict.GetValueOrDefault("notifications", "true"))
        };
    }

    public async Task SetThemeAsync(int userId, string theme)
    {
        // WHY: Update single field without loading/saving entire object
        await _redis.HashSetAsync(Key(userId), "theme", theme);
        await _redis.KeyExpireAsync(Key(userId), Ttl);
    }

    public async Task SaveAsync(int userId, UserPreferences prefs)
    {
        var fields = new HashEntry[]
        {
            new("theme", prefs.Theme),
            new("language", prefs.Language),
            new("itemsPerPage", prefs.ItemsPerPage),
            new("notifications", prefs.NotificationsEnabled.ToString())
        };

        await _redis.HashSetAsync(Key(userId), fields);
        await _redis.KeyExpireAsync(Key(userId), Ttl);
    }
}
```

---

## Shopping Cart Implementation

```csharp
// WHY: Shopping cart uses Redis Hash — one field per product, score = quantity
// Survives page refreshes, browser closes, and server restarts
public class ShoppingCartService
{
    private readonly IDatabase _redis;
    private static readonly TimeSpan CartTtl = TimeSpan.FromDays(7);

    private string CartKey(string cartId) => $"cart:{cartId}";

    // ── Add or update item ─────────────────────────────────────────────
    public async Task AddItemAsync(string cartId, int productId, int quantity, decimal price)
    {
        string key = CartKey(cartId);

        // WHY: Store as JSON to include price snapshot at time of adding
        // Prevents price changes mid-session from affecting cart total
        var item = new CartItem(productId, quantity, price);
        await _redis.HashSetAsync(key, productId.ToString(), JsonSerializer.Serialize(item));
        await _redis.KeyExpireAsync(key, CartTtl);
    }

    // ── Increment quantity ─────────────────────────────────────────────
    public async Task IncrementQuantityAsync(string cartId, int productId, int delta = 1)
    {
        string key = CartKey(cartId);
        var existing = await _redis.HashGetAsync(key, productId.ToString());

        if (!existing.HasValue) return;

        var item = JsonSerializer.Deserialize<CartItem>(existing!)!;
        var updated = item with { Quantity = Math.Max(0, item.Quantity + delta) };

        if (updated.Quantity == 0)
            await _redis.HashDeleteAsync(key, productId.ToString()); // Remove if quantity hits 0
        else
            await _redis.HashSetAsync(key, productId.ToString(), JsonSerializer.Serialize(updated));
    }

    // ── Get full cart ──────────────────────────────────────────────────
    public async Task<Cart> GetCartAsync(string cartId)
    {
        string key = CartKey(cartId);
        var all = await _redis.HashGetAllAsync(key);

        var items = all
            .Select(e => JsonSerializer.Deserialize<CartItem>(e.Value!)!)
            .ToList();

        return new Cart(cartId, items, items.Sum(i => i.Price * i.Quantity));
    }

    // ── Remove item ────────────────────────────────────────────────────
    public async Task RemoveItemAsync(string cartId, int productId)
        => await _redis.HashDeleteAsync(CartKey(cartId), productId.ToString());

    // ── Clear cart (after checkout) ────────────────────────────────────
    public async Task ClearCartAsync(string cartId)
        => await _redis.KeyDeleteAsync(CartKey(cartId));

    // ── Merge anonymous cart into authenticated user cart ──────────────
    public async Task MergeCartsAsync(string anonymousCartId, string userCartId)
    {
        var anonCart = await GetCartAsync(anonymousCartId);
        foreach (var item in anonCart.Items)
            await AddItemAsync(userCartId, item.ProductId, item.Quantity, item.Price);

        await ClearCartAsync(anonymousCartId);
    }
}

public record CartItem(int ProductId, int Quantity, decimal Price);
public record Cart(string CartId, List<CartItem> Items, decimal Total);
```

---

## Distributed Counters & Aggregates

```csharp
// WHY: Redis INCR is atomic — safe for counters across multiple servers
public class DistributedCounterService
{
    private readonly IDatabase _redis;

    // Page view counter
    public async Task<long> IncrementPageViewsAsync(string pageId)
        => await _redis.StringIncrementAsync($"views:page:{pageId}");

    // Daily counter with automatic daily reset via TTL
    public async Task<long> TrackDailyEventAsync(string eventName, string userId)
    {
        string key = $"daily:{eventName}:{DateTime.UtcNow:yyyy-MM-dd}";

        // WHY: HINCRBY lets us aggregate per-user counts in one key
        var count = await _redis.HashIncrementAsync(key, userId, 1);

        // Set TTL on first increment
        if (count == 1)
            await _redis.KeyExpireAsync(key, TimeSpan.FromDays(7));

        return count;
    }

    // Multi-counter update in one pipeline (no round trips per counter)
    public async Task RecordPurchaseAsync(int userId, decimal amount, string category)
    {
        var batch = _redis.CreateBatch();

        // WHY: Pipeline all increments together — single network round trip
        _ = batch.StringIncrementAsync("stats:total-purchases");
        _ = batch.StringIncrementAsync($"stats:category:{category}:purchases");
        _ = batch.StringIncrementByFloatAsync($"stats:total-revenue", (double)amount);
        _ = batch.StringIncrementAsync($"user:{userId}:purchase-count");
        _ = batch.StringIncrementByFloatAsync($"user:{userId}:total-spent", (double)amount);

        batch.Execute();
    }
}
```

---

## Feature Flags per User

```csharp
// WHY: Redis Set stores which users have a feature enabled
// O(1) membership check — instant per-request feature gate
public class FeatureFlagService
{
    private readonly IDatabase _redis;

    // Enable feature for specific users (beta testers)
    public async Task EnableForUserAsync(string feature, int userId)
        => await _redis.SetAddAsync($"feature:{feature}:users", userId);

    // Enable for percentage rollout
    public async Task EnableForPercentageAsync(string feature, int percentage)
        => await _redis.StringSetAsync($"feature:{feature}:percent", percentage);

    public async Task<bool> IsEnabledAsync(string feature, int userId)
    {
        // WHY: Check explicit user list first (overrides percentage)
        bool inUserList = await _redis.SetContainsAsync($"feature:{feature}:users", userId);
        if (inUserList) return true;

        // Check percentage rollout
        var percent = await _redis.StringGetAsync($"feature:{feature}:percent");
        if (!percent.HasValue) return false;

        // WHY: Use userId modulo for consistent per-user assignment
        // (same user always gets same result, even across requests)
        return (userId % 100) < int.Parse(percent!);
    }

    // Kill switch — disable globally
    public async Task DisableGloballyAsync(string feature)
        => await _redis.StringSetAsync($"feature:{feature}:disabled", "true");

    public async Task<bool> IsGloballyDisabledAsync(string feature)
        => await _redis.KeyExistsAsync($"feature:{feature}:disabled");
}
```

---

## Temporary Tokens

> Password reset, email verification, OTP — short-lived tokens that expire automatically.

```csharp
// WHY: Redis TTL is perfect for one-time tokens — auto-expire without cron jobs
public class TemporaryTokenService
{
    private readonly IDatabase _redis;

    // Generate and store password reset token
    public async Task<string> CreatePasswordResetTokenAsync(int userId)
    {
        string token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)); // Crypto-random
        string key = $"reset:{token}";

        // WHY: Store userId so we know which account to reset without exposing it in the URL
        await _redis.StringSetAsync(key, userId.ToString(), TimeSpan.FromMinutes(15));

        return token; // Send in email as: /reset-password?token={token}
    }

    // Validate and consume token (one-time use)
    public async Task<int?> ConsumePasswordResetTokenAsync(string token)
    {
        string key = $"reset:{token}";

        // WHY: GetDelete is atomic — get value AND delete in one operation
        // Prevents token reuse (race condition safe)
        var value = await _redis.StringGetDeleteAsync(key);
        if (!value.HasValue) return null; // Token not found or already used

        return int.Parse(value!);
    }

    // Email verification OTP
    public async Task<string> CreateEmailOtpAsync(string email)
    {
        string otp = Random.Shared.Next(100000, 999999).ToString();
        string key = $"otp:email:{email}";

        // WHY: Re-use key (overwrite) so user can request a new OTP without old one lingering
        await _redis.StringSetAsync(key, otp, TimeSpan.FromMinutes(5));

        // WHY: Track attempts to prevent brute-force
        await _redis.StringSetAsync($"otp:attempts:{email}", "0", TimeSpan.FromMinutes(5));

        return otp;
    }

    public async Task<bool> VerifyEmailOtpAsync(string email, string otp)
    {
        string attemptsKey = $"otp:attempts:{email}";
        long attempts = await _redis.StringIncrementAsync(attemptsKey);

        // WHY: Lock after 5 failed attempts to prevent brute force
        if (attempts > 5)
            return false;

        string key = $"otp:email:{email}";
        var stored = await _redis.StringGetDeleteAsync(key); // consume on success

        if (!stored.HasValue) return false;

        bool valid = stored == otp;
        if (!valid) // Put it back if wrong (don't consume on failure)
        {
            // Note: TTL lost on GetDelete, restore with original TTL approximation
            await _redis.StringSetAsync(key, stored!, TimeSpan.FromMinutes(5));
        }

        return valid;
    }
}
```

---

## Security Considerations

```
✅ Session Security
   □ Session cookie: HttpOnly=true, Secure=true, SameSite=Strict
   □ Regenerate session ID after login (prevent session fixation)
   □ Store minimal data in session (no passwords, no full PII)
   □ Enforce idle timeout (20 min) and absolute timeout (8 hours)

✅ Token Security
   □ Use cryptographically random tokens (RandomNumberGenerator)
   □ One-time use: GetDelete atomically consumes token
   □ Short TTLs: reset=15min, OTP=5min, session=20min idle
   □ Rate limit OTP attempts with Redis counter

✅ Redis Security
   □ Enable Redis AUTH password
   □ Use Redis ACL to restrict commands per user
   □ Never store plaintext passwords in session/cache
   □ Encrypt sensitive data before storing in Redis
   □ TLS between app and Redis in production

✅ GDPR
   □ On user account deletion: clear all session:*, cart:*, prefs:*, user:* keys
   □ Don't store PII in Redis keys (use userId, not email)
```

---

*Next:* [03-Redis-PubSub-Messaging.md](03-Redis-PubSub-Messaging.md) — Pub/Sub channels, pattern subscriptions, event-driven architecture
