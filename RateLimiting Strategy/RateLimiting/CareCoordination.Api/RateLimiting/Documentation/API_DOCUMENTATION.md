# API Documentation

## IDistributedRateLimiterService

### Methods

#### IsRequestAllowedAsync
```csharp
Task<bool> IsRequestAllowedAsync(
    string key, 
    string limiterType, 
    int maxRequests, 
    TimeSpan timeWindow)
```

**Parameters**:
- `key`: Unique identifier (e.g., "user:123", "ip:192.168.1.1")
- `limiterType`: "FixedWindow", "SlidingWindow", "TokenBucket", "Concurrency"
- `maxRequests`: Maximum requests allowed
- `timeWindow`: Time window for the limit

**Returns**: `true` if request allowed, `false` if limit exceeded

---

#### GetRemainingRequestsAsync
```csharp
Task<int> GetRemainingRequestsAsync(string key, string limiterType)
```

**Returns**: Number of remaining requests allowed

---

#### GetRetryAfterSecondsAsync
```csharp
Task<int> GetRetryAfterSecondsAsync(string key, string limiterType)
```

**Returns**: Seconds until rate limit resets

---

#### ResetRateLimitAsync
```csharp
Task ResetRateLimitAsync(string key, string limiterType)
```

**Purpose**: Reset rate limit for debugging/admin purposes

---

#### AcquireConcurrencySlotAsync
```csharp
Task<(bool acquired, string requestId)> AcquireConcurrencySlotAsync(
    string key, 
    int maxConcurrent, 
    int timeoutSeconds = 300)
```

**Returns**: Tuple with acquisition status and request ID

---

#### ReleaseConcurrencySlotAsync
```csharp
Task ReleaseConcurrencySlotAsync(string key, string requestId)
```

**Critical**: Must be called in finally block

## Configuration

### RateLimiterConfig Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| UseDistributedRateLimiting | bool | false | Enable Redis-based limiting |
| RedisConnectionString | string | "" | Redis connection |
| RedisDatabase | int | 0 | Database number (0-15) |
| RedisKeyPrefix | string | "ratelimit:" | Key prefix |
| EnableFallbackToInMemory | bool | true | Fallback if Redis fails |
| LogRateLimitViolations | bool | true | Log violations |

## Rate Limiter Types

### FixedWindow
- Simple time-window based
- Resets completely after window
- Best for: Simple, predictable limits

### SlidingWindow
- Rolling time window
- Prevents boundary bursts
- Best for: Smooth, fair limiting

### TokenBucket
- Token-based with refills
- Allows short bursts
- Best for: Burst traffic handling

### Concurrency
- Limits simultaneous operations
- Not time-based
- Best for: Resource protection
