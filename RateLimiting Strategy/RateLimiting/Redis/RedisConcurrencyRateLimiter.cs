using StackExchange.Redis;
using System;
using System.Threading.Tasks;

namespace CareCoordination.Api.RateLimiting.Redis
{
    /// <summary>
    /// Redis-based Concurrency Limiter for distributed systems
    /// 
    /// CONCURRENCY LIMITER VS OTHER LIMITERS:
    /// ======================================
    /// Fixed/Sliding/Token Bucket = Limit requests PER TIME PERIOD
    /// Concurrency Limiter = Limit SIMULTANEOUS ACTIVE REQUESTS
    /// 
    /// PROBLEM IT SOLVES:
    /// ==================
    /// Scenario: File Upload API
    /// - Each upload takes 30 seconds to process
    /// - Server can handle max 50 concurrent uploads (CPU/memory limit)
    /// - Without concurrency limit:
    ///   ?? 100 users upload simultaneously
    ///   ?? Server tries to process all 100 at once
    ///   ?? CPU/Memory maxed out
    ///   ?? Server crashes ?
    /// 
    /// With Concurrency Limiter:
    /// ?? First 50 uploads: Start processing ?
    /// ?? Next 50 uploads: Queued (or rejected)
    /// ?? As uploads finish, queued ones start
    /// ?? Server stable, all uploads complete ?
    /// 
    /// REDIS IMPLEMENTATION:
    /// ====================
    /// Key: "ratelimit:concurrency:{identifier}"
    /// Type: Sorted Set (ZSET)
    /// Members: Unique request IDs
    /// Scores: Start timestamp (for tracking/debugging)
    /// 
    /// How it works:
    /// 1. Request arrives ? Generate unique ID
    /// 2. Add ID to sorted set
    /// 3. Count members in set
    /// 4. If count <= limit ? Allow request
    /// 5. When request completes ? Remove ID from set
    /// 
    /// DISTRIBUTED EXAMPLE:
    /// ===================
    /// Server A: Handles 20 concurrent uploads
    /// Server B: Handles 18 concurrent uploads
    /// Server C: Handles 12 concurrent uploads
    /// 
    /// WITHOUT Redis (In-Memory):
    /// ?? Server A: 20/50 limit ? Allows 30 more
    /// ?? Server B: 18/50 limit ? Allows 32 more
    /// ?? Server C: 12/50 limit ? Allows 38 more
    /// TOTAL: 50 active, but each server allows MORE
    /// Result: 150 concurrent operations possible ?
    /// 
    /// WITH Redis (Distributed):
    /// ?? Sorted Set has 50 members (global count)
    /// ?? Server A tries to add: ZADD returns count = 51
    /// ?? Server A sees count > 50 ? Rejects
    /// ?? All servers coordinate through same set ?
    /// 
    /// KEY DIFFERENCE: "Release" required
    /// ==================================
    /// Other limiters: Automatic (time-based expiration)
    /// Concurrency: Manual release when operation completes
    /// 
    /// Example:
    /// try
    /// {
    ///     if (await limiter.AcquireAsync("user123"))
    ///     {
    ///         // Process long-running operation
    ///         await UploadFileAsync();
    ///     }
    /// }
    /// finally
    /// {
    ///     // MUST release when done!
    ///     await limiter.ReleaseAsync("user123", requestId);
    /// }
    /// </summary>
    public class RedisConcurrencyRateLimiter
    {
        private readonly IConnectionMultiplexer _redis;
        private readonly string _keyPrefix;

        public RedisConcurrencyRateLimiter(IConnectionMultiplexer redis, string keyPrefix = "ratelimit:concurrency:")
        {
            _redis = redis ?? throw new ArgumentNullException(nameof(redis));
            _keyPrefix = keyPrefix;
        }

        /// <summary>
        /// Try to acquire a concurrency slot
        /// Returns a request ID that MUST be used to release the slot when done
        /// </summary>
        /// <param name="identifier">Unique key (IP, UserID, endpoint, etc.)</param>
        /// <param name="maxConcurrent">Maximum concurrent operations allowed</param>
        /// <param name="requestId">Output: Unique request ID for releasing slot</param>
        /// <param name="timeoutSeconds">Maximum time before auto-release (safety mechanism)</param>
        /// <returns>True if acquired, false if limit reached</returns>
        public async Task<(bool acquired, string requestId)> AcquireAsync(
            string identifier, 
            int maxConcurrent, 
            int timeoutSeconds = 300) // Default 5 minutes timeout
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                
                // STEP 1: Cleanup stale entries (timed out requests)
                // Remove entries older than timeout period
                var staleThreshold = now - (timeoutSeconds * 1000);
                await db.SortedSetRemoveRangeByScoreAsync(redisKey, 0, staleThreshold);

                // STEP 2: Check current concurrency count
                var currentCount = await db.SortedSetLengthAsync(redisKey);

                if (currentCount >= maxConcurrent)
                {
                    return (false, string.Empty); // Limit reached
                }

                // STEP 3: Generate unique request ID
                var requestId = Guid.NewGuid().ToString();

                // STEP 4: Try to add to sorted set (atomic operation)
                // Use Lua script to ensure atomicity
                var luaScript = @"
                    local current = redis.call('ZCARD', KEYS[1])
                    if current < tonumber(ARGV[2]) then
                        redis.call('ZADD', KEYS[1], ARGV[3], ARGV[1])
                        redis.call('EXPIRE', KEYS[1], ARGV[4])
                        return 1
                    else
                        return 0
                    end
                ";

                var keys = new RedisKey[] { redisKey };
                var values = new RedisValue[] 
                { 
                    requestId,           // ARGV[1]: Request ID
                    maxConcurrent,       // ARGV[2]: Max concurrent limit
                    now,                 // ARGV[3]: Timestamp
                    timeoutSeconds + 60  // ARGV[4]: Key TTL
                };

                var result = await db.ScriptEvaluateAsync(luaScript, keys, values);

                if ((int)result == 1)
                {
                    return (true, requestId); // Acquired successfully
                }
                else
                {
                    return (false, string.Empty); // Race condition: limit reached
                }
            }
            catch (RedisException ex)
            {
                Console.WriteLine($"Redis error in concurrency limiter: {ex.Message}");
                // Fail open: Allow request but return empty ID (can't release)
                return (true, string.Empty);
            }
        }

        /// <summary>
        /// Release a concurrency slot when operation completes
        /// MUST be called in a finally block to ensure release
        /// </summary>
        /// <param name="identifier">Same identifier used in Acquire</param>
        /// <param name="requestId">Request ID returned from Acquire</param>
        public async Task ReleaseAsync(string identifier, string requestId)
        {
            if (string.IsNullOrEmpty(requestId))
            {
                return; // Nothing to release (fallback case)
            }

            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                // Remove request from sorted set
                await db.SortedSetRemoveAsync(redisKey, requestId);
            }
            catch (RedisException ex)
            {
                Console.WriteLine($"Redis error releasing concurrency slot: {ex.Message}");
                // Log but don't throw - release failures shouldn't break user flow
            }
        }

        /// <summary>
        /// Get current number of concurrent operations
        /// </summary>
        public async Task<int> GetCurrentConcurrencyAsync(string identifier, int timeoutSeconds = 300)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                var staleThreshold = now - (timeoutSeconds * 1000);

                // Cleanup stale entries
                await db.SortedSetRemoveRangeByScoreAsync(redisKey, 0, staleThreshold);

                // Return current count
                return (int)await db.SortedSetLengthAsync(redisKey);
            }
            catch (RedisException)
            {
                return 0;
            }
        }

        /// <summary>
        /// Get remaining concurrency slots available
        /// </summary>
        public async Task<int> GetRemainingAsync(string identifier, int maxConcurrent, int timeoutSeconds = 300)
        {
            var current = await GetCurrentConcurrencyAsync(identifier, timeoutSeconds);
            return Math.Max(0, maxConcurrent - current);
        }

        /// <summary>
        /// Reset all concurrency slots (admin/debugging)
        /// WARNING: This will forcibly release ALL active operations
        /// </summary>
        public async Task ResetAsync(string identifier)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";
            await db.KeyDeleteAsync(redisKey);
        }

        /// <summary>
        /// Get detailed concurrency statistics
        /// </summary>
        public async Task<ConcurrencyStats> GetStatsAsync(string identifier, int maxConcurrent, int timeoutSeconds = 300)
        {
            var db = _redis.GetDatabase();
            var redisKey = $"{_keyPrefix}{identifier}";

            try
            {
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                var staleThreshold = now - (timeoutSeconds * 1000);

                // Cleanup stale entries
                await db.SortedSetRemoveRangeByScoreAsync(redisKey, 0, staleThreshold);

                // Get all active requests
                var activeRequests = await db.SortedSetRangeByScoreWithScoresAsync(redisKey);

                if (activeRequests.Length == 0)
                {
                    return new ConcurrencyStats
                    {
                        CurrentConcurrency = 0,
                        MaxConcurrency = maxConcurrent,
                        AvailableSlots = maxConcurrent,
                        PercentageUsed = 0,
                        OldestRequestAge = 0
                    };
                }

                var oldestTimestamp = (long)activeRequests[0].Score;
                var oldestAge = (int)((now - oldestTimestamp) / 1000);

                return new ConcurrencyStats
                {
                    CurrentConcurrency = activeRequests.Length,
                    MaxConcurrency = maxConcurrent,
                    AvailableSlots = Math.Max(0, maxConcurrent - activeRequests.Length),
                    PercentageUsed = (double)activeRequests.Length / maxConcurrent * 100,
                    OldestRequestAge = oldestAge
                };
            }
            catch (RedisException)
            {
                return new ConcurrencyStats
                {
                    MaxConcurrency = maxConcurrent,
                    AvailableSlots = maxConcurrent
                };
            }
        }
    }

    /// <summary>
    /// Statistics for concurrency limiter
    /// </summary>
    public class ConcurrencyStats
    {
        public int CurrentConcurrency { get; set; }
        public int MaxConcurrency { get; set; }
        public int AvailableSlots { get; set; }
        public double PercentageUsed { get; set; }
        public int OldestRequestAge { get; set; }
    }

    // USAGE PATTERN:
    // ==============
    // 
    // [HttpPost("upload")]
    // public async Task<IActionResult> UploadFile()
    // {
    //     var userId = User.FindFirst("sub")?.Value;
    //     var (acquired, requestId) = await _limiter.AcquireAsync(userId, maxConcurrent: 5);
    //     
    //     if (!acquired)
    //     {
    //         return StatusCode(429, "Too many concurrent uploads");
    //     }
    //     
    //     try
    //     {
    //         await ProcessFileUploadAsync(); // Long-running operation
    //         return Ok();
    //     }
    //     finally
    //     {
    //         await _limiter.ReleaseAsync(userId, requestId); // ALWAYS release!
    //     }
    // }
    // 
    // COMMON USE CASES:
    // =================
    // 
    // 1. Database Connection Pool Protection
    //    ? Limit concurrent database queries
    //    ? Prevent connection pool exhaustion
    // 
    // 2. External API Calls
    //    ? Third-party API has concurrency limit
    //    ? Enforce limit across all servers
    // 
    // 3. File I/O Operations
    //    ? Limit concurrent file uploads/downloads
    //    ? Prevent disk I/O bottleneck
    // 
    // 4. CPU-Intensive Operations
    //    ? Video encoding, image processing
    //    ? Prevent CPU overload
    // 
    // 5. Memory-Intensive Operations
    //    ? Large report generation
    //    ? Prevent out-of-memory errors
    // 
    // CRITICAL GOTCHAS:
    // =================
    // ?? ALWAYS release in finally block
    // ?? Set timeout to prevent stuck slots
    // ?? Monitor for stale entries (debugging)
    // ?? Log acquire/release for tracing
}
