using StackExchange.Redis;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace CareCoordination.Api.RateLimiting.Redis
{
    /// <summary>
    /// Redis-based Sliding Window Rate Limiter for distributed systems
    /// 
    /// HOW IT WORKS:
    /// =============
    /// Unlike Fixed Window (resets completely), Sliding Window uses SORTED SETS
    /// to track individual request timestamps, creating a true "rolling window"
    /// 
    /// REDIS DATA STRUCTURE:
    /// ====================
    /// Key: "ratelimit:sliding:user123"
    /// Type: Sorted Set (ZSET)
    /// Members: Each request's unique ID
    /// Scores: Unix timestamp in milliseconds
    /// 
    /// Example Timeline (60 second window, limit 100):
    /// Time 0:00 ? User makes 80 requests ? ZSET has 80 members
    /// Time 0:30 ? User makes 25 requests ? ZSET has 105 members
    /// Time 0:45 ? User makes 10 requests ? System checks:
    ///   1. Current time = 0:45 (45 seconds)
    ///   2. Window start = 0:45 - 60s = -15s (clips to 0:00)
    ///   3. Count requests from 0:00 to 0:45 ? Finds 115 requests
    ///   4. 115 > 100 ? REJECT ?
    /// Time 1:05 ? User tries again ? System checks:
    ///   1. Current time = 1:05 (65 seconds)
    ///   2. Window start = 1:05 - 60s = 0:05
    ///   3. Remove old entries (before 0:05) ? 80 requests removed
    ///   4. Count from 0:05 to 1:05 ? Finds 35 requests
    ///   5. 35 < 100 ? ALLOW ?
    /// 
    /// DISTRIBUTED BENEFITS:
    /// ====================
    /// Server A: Adds request with score=1705345200123
    /// Server B: Adds request with score=1705345200456
    /// Server C: Adds request with score=1705345200789
    /// ALL servers query SAME sorted set ? Consistent count
    /// 
    /// ADVANTAGES OVER FIXED WINDOW:
    /// =============================
    /// Fixed Window Problem:
    ///   ?? 09:59:59 ? 99 requests ? All allowed ?
    ///   ?? 10:00:01 ? 99 requests ? Window reset, all allowed ?
    ///   TOTAL: 198 requests in 2 seconds! ? Burst attack
    /// 
    /// Sliding Window Solution:
    ///   ?? 09:59:59 ? 99 requests
    ///   ?? 10:00:01 ? System checks last 60 seconds
    ///       ?? Includes requests from 09:59:59
    ///       ?? 99 + 1 = 100 ? Only 1 more allowed in next 58 seconds ?
    /// </summary>
    public class RedisSlidingWindowRateLimiter
    {
        private readonly IConnectionMultiplexer _redis;
        private readonly string _keyPrefix;

        public RedisSlidingWindowRateLimiter(IConnectionMultiplexer redis, string keyPrefix = "ratelimit:sliding:")
        {
            _redis = redis ?? throw new ArgumentNullException(nameof(redis));
            _keyPrefix = keyPrefix;
        }

        /// <summary>
        /// Check if request is allowed under sliding window rate limit
        /// </summary>
        /// <param name="identifier">Unique key (IP, UserID, etc.)</param>
        /// <param name="maxRequests">Maximum requests allowed in window</param>
        /// <param name="windowSeconds">Time window in seconds</param>
        /// <returns>True if allowed, false if limit exceeded</returns>
        public async Task<bool> IsAllowedAsync(string identifier, int maxRequests, int windowSeconds)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                // Current timestamp in milliseconds (for precision)
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                
                // Calculate window start time (X seconds ago)
                var windowStart = now - (windowSeconds * 1000);

                // STEP 1: Remove old entries (cleanup expired requests)
                // ZREMRANGEBYSCORE removes all members with score < windowStart
                // This keeps the sorted set clean and prevents memory bloat
                await db.SortedSetRemoveRangeByScoreAsync(redisKey, 0, windowStart);

                // STEP 2: Count requests in current window
                // ZCOUNT counts members with score between windowStart and now
                var currentCount = await db.SortedSetLengthAsync(redisKey);

                // STEP 3: Check if limit exceeded
                if (currentCount >= maxRequests)
                {
                    return false; // Rate limit exceeded
                }

                // STEP 4: Add current request to sorted set
                // Use unique request ID as member, timestamp as score
                // Member must be unique to avoid duplicates
                var requestId = $"{now}:{Guid.NewGuid()}";
                await db.SortedSetAddAsync(redisKey, requestId, now);

                // STEP 5: Set expiration on the key (cleanup if idle)
                // TTL = window + buffer time
                await db.KeyExpireAsync(redisKey, TimeSpan.FromSeconds(windowSeconds + 10));

                return true; // Request allowed
            }
            catch (RedisException ex)
            {
                Console.WriteLine($"Redis error in sliding window limiter: {ex.Message}");
                return true; // Fail open
            }
        }

        /// <summary>
        /// Get remaining requests in current window
        /// </summary>
        public async Task<int> GetRemainingAsync(string identifier, int maxRequests, int windowSeconds)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                var windowStart = now - (windowSeconds * 1000);

                // Clean up old entries first
                await db.SortedSetRemoveRangeByScoreAsync(redisKey, 0, windowStart);

                // Count requests in current window
                var currentCount = await db.SortedSetLengthAsync(redisKey);
                
                return Math.Max(0, maxRequests - (int)currentCount);
            }
            catch (RedisException)
            {
                return maxRequests;
            }
        }

        /// <summary>
        /// Get seconds until oldest request expires from window
        /// </summary>
        public async Task<int> GetRetryAfterSecondsAsync(string identifier, int windowSeconds)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                // Get oldest request in window
                var oldestRequests = await db.SortedSetRangeByScoreWithScoresAsync(
                    redisKey, 
                    order: Order.Ascending, 
                    take: 1
                );

                if (oldestRequests.Length == 0)
                {
                    return 0; // No requests in window
                }

                var oldestTimestamp = (long)oldestRequests[0].Score;
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                var ageMs = now - oldestTimestamp;
                var ageSeconds = (int)(ageMs / 1000);

                // Time until oldest request falls out of window
                return Math.Max(0, windowSeconds - ageSeconds);
            }
            catch (RedisException)
            {
                return windowSeconds;
            }
        }

        /// <summary>
        /// Reset rate limit for specific identifier
        /// </summary>
        public async Task ResetAsync(string identifier)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";
            await db.KeyDeleteAsync(redisKey);
        }

        /// <summary>
        /// Get detailed analytics for monitoring
        /// </summary>
        public async Task<SlidingWindowStats> GetStatsAsync(string identifier, int windowSeconds)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                var windowStart = now - (windowSeconds * 1000);

                // Get all requests in current window
                var requests = await db.SortedSetRangeByScoreWithScoresAsync(
                    redisKey,
                    windowStart,
                    now,
                    order: Order.Ascending
                );

                if (requests.Length == 0)
                {
                    return new SlidingWindowStats
                    {
                        TotalRequests = 0,
                        OldestRequestAge = 0,
                        NewestRequestAge = 0,
                        RequestsPerSecond = 0
                    };
                }

                var oldestTimestamp = (long)requests.First().Score;
                var newestTimestamp = (long)requests.Last().Score;
                var windowDuration = (newestTimestamp - oldestTimestamp) / 1000.0; // seconds

                return new SlidingWindowStats
                {
                    TotalRequests = requests.Length,
                    OldestRequestAge = (int)((now - oldestTimestamp) / 1000),
                    NewestRequestAge = (int)((now - newestTimestamp) / 1000),
                    RequestsPerSecond = windowDuration > 0 ? requests.Length / windowDuration : 0
                };
            }
            catch (RedisException)
            {
                return new SlidingWindowStats();
            }
        }
    }

    /// <summary>
    /// Statistics for sliding window rate limiter
    /// </summary>
    public class SlidingWindowStats
    {
        public int TotalRequests { get; set; }
        public int OldestRequestAge { get; set; }
        public int NewestRequestAge { get; set; }
        public double RequestsPerSecond { get; set; }
    }

    // MEMORY CONSIDERATIONS:
    // =====================
    // Each request = ~100 bytes in Redis (member + score + overhead)
    // 100 requests/minute = ~10 KB per user
    // 1 million users = ~10 GB memory
    // 
    // OPTIMIZATION: Use approximate sliding window
    // Instead of storing each request, use multiple fixed windows
    // Trade accuracy for memory efficiency
    // 
    // WHEN TO USE SLIDING WINDOW:
    // ==========================
    // ? Need smooth, fair rate limiting
    // ? Prevent boundary burst attacks
    // ? Medium traffic (< 1M requests/minute per key)
    // ? Users pay for API usage (billing accuracy)
    // 
    // ? Extremely high traffic (use Token Bucket)
    // ? Memory constrained (use Fixed Window)
    // ? Ultra-low latency needed (Redis commands = 2-3ms vs 1 for fixed window)
}
