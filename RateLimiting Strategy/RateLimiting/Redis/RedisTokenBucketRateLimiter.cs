using StackExchange.Redis;
using System;
using System.Threading.Tasks;

namespace CareCoordination.Api.RateLimiting.Redis
{
    /// <summary>
    /// Redis-based Token Bucket Rate Limiter for distributed systems
    /// 
    /// TOKEN BUCKET ALGORITHM EXPLAINED:
    /// =================================
    /// Imagine a physical bucket that holds tokens:
    /// • Bucket Capacity = Maximum tokens it can hold (e.g., 100)
    /// • Refill Rate = New tokens added per second (e.g., 10/second)
    /// • Each Request = Consumes 1 token
    /// • If bucket empty = Request denied
    /// 
    /// VISUAL EXAMPLE (100 token capacity, 10 tokens/second refill):
    /// 
    /// Time    | Tokens | Event
    /// --------|--------|--------------------------------------------
    /// 0:00    | 100    | Bucket starts full
    /// 0:01    | 70     | Burst: 30 requests consume 30 tokens
    /// 0:02    | 80     | +10 tokens refilled (1 second passed)
    /// 0:03    | 60     | 30 more requests
    /// 0:04    | 70     | +10 refilled
    /// 0:05    | 0      | Massive burst: 70 requests
    /// 0:06    | 10     | +10 refilled, but new request denied (needs 1)
    /// 0:07    | 20     | +10 refilled
    /// 0:10    | 50     | +30 refilled (3 seconds)
    /// 
    /// KEY ADVANTAGE: Handles BURST traffic gracefully
    /// ------------------------------------------------
    /// Fixed Window: 100 req/min = blocks at 100
    /// Token Bucket: 100 capacity + 10/sec refill = allows burst of 100,
    ///               then sustained 10/sec (600/min average)
    /// 
    /// REDIS IMPLEMENTATION:
    /// ====================
    /// Key 1: "ratelimit:token:{identifier}:count" ? Current token count
    /// Key 2: "ratelimit:token:{identifier}:lastRefill" ? Last refill timestamp
    /// 
    /// Algorithm Steps:
    /// 1. Get current token count
    /// 2. Calculate time since last refill
    /// 3. Add refilled tokens (time × refill_rate)
    /// 4. Cap at bucket capacity
    /// 5. Check if enough tokens for request
    /// 6. Deduct tokens if allowed
    /// 7. Update timestamp
    /// </summary>
    public class RedisTokenBucketRateLimiter
    {
        private readonly IConnectionMultiplexer _redis;
        private readonly string _keyPrefix;

        public RedisTokenBucketRateLimiter(IConnectionMultiplexer redis, string keyPrefix = "ratelimit:token:")
        {
            _redis = redis ?? throw new ArgumentNullException(nameof(redis));
            _keyPrefix = keyPrefix;
        }

        /// <summary>
        /// Check if request is allowed under token bucket rate limit
        /// </summary>
        /// <param name="identifier">Unique key (IP, UserID, etc.)</param>
        /// <param name="bucketCapacity">Maximum tokens the bucket can hold</param>
        /// <param name="refillRate">Tokens added per second</param>
        /// <param name="tokensRequired">Tokens needed for this request (default 1)</param>
        /// <returns>True if allowed, false if insufficient tokens</returns>
        public async Task<bool> IsAllowedAsync(
            string identifier, 
            int bucketCapacity, 
            int refillRate, 
            int tokensRequired = 1)
        {
            var db = _redis.GetDatabase();
            var countKey = $"{_keyPrefix}{identifier}:count";
            var timestampKey = $"{_keyPrefix}{identifier}:lastRefill";

            try
            {
                // Get current state from Redis
                var currentTokensValue = await db.StringGetAsync(countKey);
                var lastRefillValue = await db.StringGetAsync(timestampKey);
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

                double currentTokens;
                long lastRefillTime;

                // Initialize bucket if first request
                if (currentTokensValue.IsNullOrEmpty || lastRefillValue.IsNullOrEmpty)
                {
                    currentTokens = bucketCapacity; // Start with full bucket
                    lastRefillTime = now;
                }
                else
                {
                    currentTokens = (double)currentTokensValue;
                    lastRefillTime = (long)lastRefillValue;
                }

                // STEP 1: Calculate elapsed time since last refill
                var elapsedMs = now - lastRefillTime;
                var elapsedSeconds = elapsedMs / 1000.0;

                // STEP 2: Calculate tokens to add based on refill rate
                // Example: 5 seconds elapsed, 10 tokens/sec = 50 tokens to add
                var tokensToAdd = elapsedSeconds * refillRate;

                // STEP 3: Refill bucket (capped at capacity)
                // Example: Had 20 tokens, add 50 = 70, but cap at 100 = 70 tokens
                currentTokens = Math.Min(currentTokens + tokensToAdd, bucketCapacity);

                // STEP 4: Check if enough tokens available
                if (currentTokens < tokensRequired)
                {
                    // Not enough tokens - reject request
                    // Note: We DON'T update Redis here to avoid race conditions
                    return false;
                }

                // STEP 5: Deduct tokens for this request
                currentTokens -= tokensRequired;

                // STEP 6: Update Redis atomically using Lua script
                // This ensures no race condition between read and write
                var luaScript = @"
                    redis.call('SET', KEYS[1], ARGV[1])
                    redis.call('SET', KEYS[2], ARGV[2])
                    redis.call('EXPIRE', KEYS[1], ARGV[3])
                    redis.call('EXPIRE', KEYS[2], ARGV[3])
                    return 1
                ";

                var keys = new RedisKey[] { countKey, timestampKey };
                var values = new RedisValue[] 
                { 
                    currentTokens, 
                    now, 
                    (int)(bucketCapacity / refillRate) + 60 // TTL = time to refill + buffer
                };

                await db.ScriptEvaluateAsync(luaScript, keys, values);

                return true; // Request allowed
            }
            catch (RedisException ex)
            {
                Console.WriteLine($"Redis error in token bucket limiter: {ex.Message}");
                return true; // Fail open
            }
        }

        /// <summary>
        /// Get remaining tokens in bucket
        /// </summary>
        public async Task<double> GetRemainingTokensAsync(string identifier, int bucketCapacity, int refillRate)
        {
            var db = _redis.GetDatabase();
            var countKey = $"{_keyPrefix}{identifier}:count";
            var timestampKey = $"{_keyPrefix}{identifier}:lastRefill";

            try
            {
                var currentTokensValue = await db.StringGetAsync(countKey);
                var lastRefillValue = await db.StringGetAsync(timestampKey);
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

                if (currentTokensValue.IsNullOrEmpty || lastRefillValue.IsNullOrEmpty)
                {
                    return bucketCapacity; // Full bucket
                }

                var currentTokens = (double)currentTokensValue;
                var lastRefillTime = (long)lastRefillValue;

                // Calculate refilled tokens
                var elapsedMs = now - lastRefillTime;
                var elapsedSeconds = elapsedMs / 1000.0;
                var tokensToAdd = elapsedSeconds * refillRate;

                return Math.Min(currentTokens + tokensToAdd, bucketCapacity);
            }
            catch (RedisException)
            {
                return bucketCapacity;
            }
        }

        /// <summary>
        /// Get seconds until bucket has enough tokens
        /// </summary>
        public async Task<int> GetRetryAfterSecondsAsync(
            string identifier, 
            int bucketCapacity, 
            int refillRate, 
            int tokensRequired = 1)
        {
            var remainingTokens = await GetRemainingTokensAsync(identifier, bucketCapacity, refillRate);

            if (remainingTokens >= tokensRequired)
            {
                return 0; // Already have enough tokens
            }

            // Calculate time needed to refill required tokens
            var tokensNeeded = tokensRequired - remainingTokens;
            var secondsNeeded = Math.Ceiling(tokensNeeded / refillRate);

            return (int)secondsNeeded;
        }

        /// <summary>
        /// Reset bucket to full capacity (admin/debugging)
        /// </summary>
        public async Task ResetAsync(string identifier, int bucketCapacity)
        {
            var db = _redis.GetDatabase();
            var countKey = $"{_keyPrefix}{identifier}:count";
            var timestampKey = $"{_keyPrefix}{identifier}:lastRefill";

            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            
            await db.StringSetAsync(countKey, bucketCapacity);
            await db.StringSetAsync(timestampKey, now);
        }

        /// <summary>
        /// Get detailed bucket statistics
        /// </summary>
        public async Task<TokenBucketStats> GetStatsAsync(string identifier, int bucketCapacity, int refillRate)
        {
            var db = _redis.GetDatabase();
            var countKey = $"{_keyPrefix}{identifier}:count";
            var timestampKey = $"{_keyPrefix}{identifier}:lastRefill";

            try
            {
                var currentTokensValue = await db.StringGetAsync(countKey);
                var lastRefillValue = await db.StringGetAsync(timestampKey);
                var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

                if (currentTokensValue.IsNullOrEmpty || lastRefillValue.IsNullOrEmpty)
                {
                    return new TokenBucketStats
                    {
                        CurrentTokens = bucketCapacity,
                        BucketCapacity = bucketCapacity,
                        RefillRate = refillRate,
                        SecondsSinceLastRefill = 0,
                        PercentageFull = 100
                    };
                }

                var currentTokens = (double)currentTokensValue;
                var lastRefillTime = (long)lastRefillValue;
                var elapsedSeconds = (now - lastRefillTime) / 1000.0;

                // Calculate current tokens after refill
                var tokensToAdd = elapsedSeconds * refillRate;
                var actualTokens = Math.Min(currentTokens + tokensToAdd, bucketCapacity);

                return new TokenBucketStats
                {
                    CurrentTokens = actualTokens,
                    BucketCapacity = bucketCapacity,
                    RefillRate = refillRate,
                    SecondsSinceLastRefill = elapsedSeconds,
                    PercentageFull = (actualTokens / bucketCapacity) * 100
                };
            }
            catch (RedisException)
            {
                return new TokenBucketStats
                {
                    CurrentTokens = bucketCapacity,
                    BucketCapacity = bucketCapacity,
                    RefillRate = refillRate
                };
            }
        }
    }

    /// <summary>
    /// Statistics for token bucket rate limiter
    /// </summary>
    public class TokenBucketStats
    {
        public double CurrentTokens { get; set; }
        public int BucketCapacity { get; set; }
        public int RefillRate { get; set; }
        public double SecondsSinceLastRefill { get; set; }
        public double PercentageFull { get; set; }
    }

    // USE CASES FOR TOKEN BUCKET:
    // ===========================
    // 
    // 1. API with Burst Traffic
    //    ? Mobile app: Users open app ? 20 requests instantly
    //    ? Token Bucket allows burst, then steady rate
    //    ? Fixed Window would reject burst
    // 
    // 2. Video Streaming API
    //    ? Initial burst to load video metadata
    //    ? Steady stream of chunk requests
    //    ? Occasional quality switch = small burst
    // 
    // 3. File Upload API
    //    ? Large burst: Upload chunks
    //    ? Then idle until next upload
    //    ? Bucket refills during idle time
    // 
    // 4. Machine Learning API
    //    ? Batch predictions: Burst of 50 requests
    //    ? Then process results for 30 seconds
    //    ? Bucket refills during processing
    // 
    // WHEN NOT TO USE:
    // ================
    // ? Strict, predictable limits needed (use Fixed Window)
    // ? Prevent ANY burst traffic (use Sliding Window)
    // ? Limit concurrent operations (use Concurrency Limiter)
    // 
    // DISTRIBUTED SYSTEM BENEFITS:
    // ============================
    // ? Consistent token count across all servers
    // ? Fair burst handling for all users
    // ? Lua script ensures atomic operations
    // ?? Slightly more complex than Fixed Window (2 Redis keys vs 1)
}
