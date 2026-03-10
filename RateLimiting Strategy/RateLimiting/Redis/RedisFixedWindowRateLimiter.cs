using StackExchange.Redis;
using System;
using System.Threading.Tasks;

namespace CareCoordination.Api.RateLimiting.Redis
{
    /// <summary>
    /// Redis-based Fixed Window Rate Limiter for distributed systems
    /// 
    /// HOW IT WORKS IN DISTRIBUTED ENVIRONMENT:
    /// ========================================
    /// Problem: Multiple servers tracking requests independently = inconsistent limits
    /// Solution: Single Redis instance tracks ALL requests from ALL servers
    /// 
    /// Example with 3 servers (Server A, B, C):
    /// ?? Server A: Receives 40 requests for user "john@example.com"
    /// ?? Server B: Receives 35 requests for user "john@example.com"
    /// ?? Server C: Receives 30 requests for user "john@example.com"
    /// 
    /// WITHOUT Redis (In-Memory):
    /// ?? Server A thinks: 40/100 requests used ? Allows more
    /// ?? Server B thinks: 35/100 requests used ? Allows more
    /// ?? Server C thinks: 30/100 requests used ? Allows more
    /// TOTAL: 105 requests but each server allows more! ? LIMIT BYPASSED
    /// 
    /// WITH Redis (Distributed):
    /// ?? Server A: Increments Redis counter: 1, 2, 3... 40
    /// ?? Server B: Increments same Redis counter: 41, 42... 75
    /// ?? Server C: Increments same Redis counter: 76, 77... 100
    /// At 100: Redis blocks ALL servers from allowing more requests ? LIMIT ENFORCED
    /// 
    /// KEY FEATURES:
    /// • Atomic Operations: INCR command is atomic (no race conditions)
    /// • Automatic Expiration: Keys auto-delete after window expires
    /// • Network Latency: ~1-2ms overhead vs in-memory (acceptable tradeoff)
    /// • Single Source of Truth: One counter shared across all instances
    /// </summary>
    public class RedisFixedWindowRateLimiter
    {
        private readonly IConnectionMultiplexer _redis;
        private readonly string _keyPrefix;

        public RedisFixedWindowRateLimiter(IConnectionMultiplexer redis, string keyPrefix = "ratelimit:fixed:")
        {
            _redis = redis ?? throw new ArgumentNullException(nameof(redis));
            _keyPrefix = keyPrefix;
        }

        /// <summary>
        /// Check if request is allowed under fixed window rate limit
        /// </summary>
        /// <param name="identifier">Unique key (IP, UserID, etc.)</param>
        /// <param name="maxRequests">Maximum requests allowed in window</param>
        /// <param name="windowSeconds">Time window in seconds</param>
        /// <returns>True if allowed, false if limit exceeded</returns>
        public async Task<bool> IsAllowedAsync(string identifier, int maxRequests, int windowSeconds)
        {
            var db = _redis.GetDatabase();

            // Generate time-based key that resets every window
            // Example: "ratelimit:fixed:user123:2024-01-15-14:30" (for 60 second window)
            var currentWindow = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / windowSeconds;
            var redisKey = $"{_keyPrefix}{identifier}:{currentWindow}";

            try
            {
                // ATOMIC OPERATION: Increment counter and return new value
                // This is thread-safe across ALL servers
                // Redis guarantees atomicity - no two servers can increment simultaneously
                var currentCount = await db.StringIncrementAsync(redisKey);

                // First request sets expiration
                // TTL = window duration + small buffer for cleanup
                if (currentCount == 1)
                {
                    await db.KeyExpireAsync(redisKey, TimeSpan.FromSeconds(windowSeconds + 5));
                }

                // Check if limit exceeded
                return currentCount <= maxRequests;
            }
            catch (RedisException ex)
            {
                // Log error and fail open (allow request) or fail closed (deny request)
                // Fail open = better user experience but less security
                // Fail closed = better security but may cause false rejections
                Console.WriteLine($"Redis error in rate limiter: {ex.Message}");
                return true; // Fail open - allow request if Redis unavailable
            }
        }

        /// <summary>
        /// Get remaining requests in current window
        /// </summary>
        public async Task<int> GetRemainingAsync(string identifier, int maxRequests, int windowSeconds)
        {
            var db = _redis.GetDatabase();
            var currentWindow = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / windowSeconds;
            var redisKey = $"{_keyPrefix}{identifier}:{currentWindow}";

            try
            {
                var currentCount = await db.StringGetAsync(redisKey);
                if (currentCount.IsNullOrEmpty)
                {
                    return maxRequests;
                }

                var used = (int)currentCount;
                return Math.Max(0, maxRequests - used);
            }
            catch (RedisException)
            {
                return maxRequests; // Assume full quota available if Redis fails
            }
        }

        /// <summary>
        /// Get seconds until window resets
        /// </summary>
        public async Task<int> GetRetryAfterSecondsAsync(string identifier, int windowSeconds)
        {
            var db = _redis.GetDatabase();
            var currentWindow = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / windowSeconds;
            var redisKey = $"{_keyPrefix}{identifier}:{currentWindow}";

            try
            {
                var ttl = await db.KeyTimeToLiveAsync(redisKey);
                return ttl.HasValue ? (int)ttl.Value.TotalSeconds : windowSeconds;
            }
            catch (RedisException)
            {
                return windowSeconds; // Return full window as fallback
            }
        }

        /// <summary>
        /// Reset rate limit for specific identifier (admin/debugging)
        /// </summary>
        public async Task ResetAsync(string identifier)
        {
            var db = _redis.GetDatabase();
            
            // Delete all keys matching pattern
            // Note: In production, use Redis SCAN instead of KEYS for better performance
            var pattern = $"{_keyPrefix}{identifier}:*";
            var endpoints = _redis.GetEndPoints();
            
            foreach (var endpoint in endpoints)
            {
                var server = _redis.GetServer(endpoint);
                await foreach (var key in server.KeysAsync(pattern: pattern))
                {
                    await db.KeyDeleteAsync(key);
                }
            }
        }
    }

    // DISTRIBUTED SYSTEM BENEFITS:
    // ============================
    // ? Consistent Limits: All servers see same counter
    // ? No Synchronization Issues: Redis handles atomicity
    // ? Auto Cleanup: Keys expire automatically
    // ? High Availability: Redis Cluster/Sentinel for redundancy
    // ? Observable: Monitor Redis metrics for rate limit analytics
    // 
    // DRAWBACKS:
    // ==========
    // ? Network Latency: ~1-2ms per request (vs nanoseconds for in-memory)
    // ? Single Point of Failure: If Redis down, need fallback strategy
    // ? Cost: Redis hosting cost (Azure Redis Cache, AWS ElastiCache)
    // ? Complexity: Need to manage Redis infrastructure
    // 
    // WHEN TO USE:
    // ============
    // ? Multi-server deployment (load balancer, multiple instances)
    // ? Need strict, accurate rate limiting
    // ? API with external consumers (billing/quotas)
    // ? Single server deployment (use in-memory)
    // ? Ultra-low latency requirements (< 1ms)
}
