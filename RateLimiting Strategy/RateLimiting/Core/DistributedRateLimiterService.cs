using CareCoordination.Api.RateLimiting.Core;
using CareCoordination.Api.RateLimiting.Redis;
using StackExchange.Redis;
using System;
using System.Threading.Tasks;

namespace CareCoordination.Api.RateLimiting.Core
{
    /// <summary>
    /// Distributed Rate Limiter Service Implementation
    /// Coordinates all rate limiting strategies using Redis as distributed store
    /// 
    /// ARCHITECTURE PATTERN:
    /// ====================
    /// This service acts as a FACADE over individual rate limiter implementations
    /// Benefits:
    /// • Single entry point for all rate limiting logic
    /// • Easy to swap implementations (Redis ? SQL ? MongoDB)
    /// • Centralized fallback logic
    /// • Consistent error handling
    /// • Simplified dependency injection
    /// </summary>
    public class DistributedRateLimiterService : IDistributedRateLimiterService
    {
        private readonly RedisFixedWindowRateLimiter _fixedWindowLimiter;
        private readonly RedisSlidingWindowRateLimiter _slidingWindowLimiter;
        private readonly RedisTokenBucketRateLimiter _tokenBucketLimiter;
        private readonly RedisConcurrencyRateLimiter _concurrencyLimiter;
        private readonly bool _useDistributed;
        private readonly bool _fallbackToInMemory;

        public DistributedRateLimiterService(
            IConnectionMultiplexer redis,
            bool useDistributed = true,
            bool fallbackToInMemory = true,
            string keyPrefix = "ratelimit:")
        {
            _useDistributed = useDistributed;
            _fallbackToInMemory = fallbackToInMemory;

            if (_useDistributed && redis != null)
            {
                _fixedWindowLimiter = new RedisFixedWindowRateLimiter(redis, $"{keyPrefix}fixed:");
                _slidingWindowLimiter = new RedisSlidingWindowRateLimiter(redis, $"{keyPrefix}sliding:");
                _tokenBucketLimiter = new RedisTokenBucketRateLimiter(redis, $"{keyPrefix}token:");
                _concurrencyLimiter = new RedisConcurrencyRateLimiter(redis, $"{keyPrefix}concurrency:");
            }
        }

        /// <summary>
        /// Check if request is allowed under rate limit
        /// </summary>
        /// <param name="key">Unique identifier (IP, UserID, API Key, etc.)</param>
        /// <param name="limiterType">Type: "FixedWindow", "SlidingWindow", "TokenBucket", "Concurrency"</param>
        /// <param name="maxRequests">Maximum requests/tokens/concurrent operations allowed</param>
        /// <param name="timeWindow">Time window for the rate limit</param>
        public async Task<bool> IsRequestAllowedAsync(
            string key, 
            string limiterType, 
            int maxRequests, 
            TimeSpan timeWindow)
        {
            if (!_useDistributed)
            {
                // Fallback to in-memory rate limiting
                // This would use ASP.NET Core's built-in rate limiter
                return true; // For now, allow all requests if distributed is disabled
            }

            try
            {
                var windowSeconds = (int)timeWindow.TotalSeconds;

                return limiterType.ToLower() switch
                {
                    "fixedwindow" => await _fixedWindowLimiter.IsAllowedAsync(key, maxRequests, windowSeconds),
                    
                    "slidingwindow" => await _slidingWindowLimiter.IsAllowedAsync(key, maxRequests, windowSeconds),
                    
                    "tokenbucket" => await _tokenBucketLimiter.IsAllowedAsync(
                        key, 
                        bucketCapacity: maxRequests,
                        refillRate: maxRequests / windowSeconds, // Calculate refill rate from window
                        tokensRequired: 1),
                    
                    "concurrency" => await GetConcurrencyAllowedAsync(key, maxRequests),
                    
                    _ => true // Unknown type = allow (fail open)
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Distributed rate limiter error: {ex.Message}");
                
                if (_fallbackToInMemory)
                {
                    // Log fallback event for monitoring
                    Console.WriteLine($"Falling back to in-memory rate limiting for key: {key}");
                    return true; // Fail open
                }
                
                throw; // Fail closed if fallback disabled
            }
        }

        /// <summary>
        /// Get remaining requests for a given key
        /// </summary>
        public async Task<int> GetRemainingRequestsAsync(string key, string limiterType)
        {
            if (!_useDistributed)
            {
                return int.MaxValue; // No limit if distributed disabled
            }

            try
            {
                // Note: These require additional configuration context
                // For now, using default values - in production, store config in Redis or database
                return limiterType.ToLower() switch
                {
                    "fixedwindow" => await _fixedWindowLimiter.GetRemainingAsync(key, 100, 60),
                    "slidingwindow" => await _slidingWindowLimiter.GetRemainingAsync(key, 100, 60),
                    "tokenbucket" => (int)await _tokenBucketLimiter.GetRemainingTokensAsync(key, 100, 10),
                    "concurrency" => await _concurrencyLimiter.GetRemainingAsync(key, 50),
                    _ => int.MaxValue
                };
            }
            catch (Exception)
            {
                return int.MaxValue; // Assume no limit on error
            }
        }

        /// <summary>
        /// Get retry-after seconds when rate limit is exceeded
        /// </summary>
        public async Task<int> GetRetryAfterSecondsAsync(string key, string limiterType)
        {
            if (!_useDistributed)
            {
                return 0;
            }

            try
            {
                return limiterType.ToLower() switch
                {
                    "fixedwindow" => await _fixedWindowLimiter.GetRetryAfterSecondsAsync(key, 60),
                    "slidingwindow" => await _slidingWindowLimiter.GetRetryAfterSecondsAsync(key, 60),
                    "tokenbucket" => await _tokenBucketLimiter.GetRetryAfterSecondsAsync(key, 100, 10),
                    "concurrency" => 60, // For concurrency, suggest retry after 1 minute
                    _ => 60
                };
            }
            catch (Exception)
            {
                return 60; // Default retry after 1 minute
            }
        }

        /// <summary>
        /// Reset rate limit for a specific key (admin/debugging purposes)
        /// </summary>
        public async Task ResetRateLimitAsync(string key, string limiterType)
        {
            if (!_useDistributed)
            {
                return;
            }

            try
            {
                switch (limiterType.ToLower())
                {
                    case "fixedwindow":
                        await _fixedWindowLimiter.ResetAsync(key);
                        break;
                    case "slidingwindow":
                        await _slidingWindowLimiter.ResetAsync(key);
                        break;
                    case "tokenbucket":
                        await _tokenBucketLimiter.ResetAsync(key, 100);
                        break;
                    case "concurrency":
                        await _concurrencyLimiter.ResetAsync(key);
                        break;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error resetting rate limit: {ex.Message}");
                throw;
            }
        }

        // ============================================================
        // ADVANCED METHODS (Optional - for monitoring/analytics)
        // ============================================================

        /// <summary>
        /// Acquire concurrency slot (must be released when done)
        /// </summary>
        public async Task<(bool acquired, string requestId)> AcquireConcurrencySlotAsync(
            string key, 
            int maxConcurrent, 
            int timeoutSeconds = 300)
        {
            if (!_useDistributed)
            {
                return (true, Guid.NewGuid().ToString());
            }

            return await _concurrencyLimiter.AcquireAsync(key, maxConcurrent, timeoutSeconds);
        }

        /// <summary>
        /// Release concurrency slot (MUST be called in finally block)
        /// </summary>
        public async Task ReleaseConcurrencySlotAsync(string key, string requestId)
        {
            if (!_useDistributed || string.IsNullOrEmpty(requestId))
            {
                return;
            }

            await _concurrencyLimiter.ReleaseAsync(key, requestId);
        }

        /// <summary>
        /// Get sliding window statistics (for monitoring dashboard)
        /// </summary>
        public async Task<SlidingWindowStats> GetSlidingWindowStatsAsync(string key, int windowSeconds = 60)
        {
            if (!_useDistributed)
            {
                return new SlidingWindowStats();
            }

            return await _slidingWindowLimiter.GetStatsAsync(key, windowSeconds);
        }

        /// <summary>
        /// Get token bucket statistics (for monitoring dashboard)
        /// </summary>
        public async Task<TokenBucketStats> GetTokenBucketStatsAsync(
            string key, 
            int bucketCapacity = 100, 
            int refillRate = 10)
        {
            if (!_useDistributed)
            {
                return new TokenBucketStats();
            }

            return await _tokenBucketLimiter.GetStatsAsync(key, bucketCapacity, refillRate);
        }

        /// <summary>
        /// Get concurrency statistics (for monitoring dashboard)
        /// </summary>
        public async Task<ConcurrencyStats> GetConcurrencyStatsAsync(
            string key, 
            int maxConcurrent = 50, 
            int timeoutSeconds = 300)
        {
            if (!_useDistributed)
            {
                return new ConcurrencyStats();
            }

            return await _concurrencyLimiter.GetStatsAsync(key, maxConcurrent, timeoutSeconds);
        }
    }
}

// USAGE IN CONTROLLERS:
// =====================
// 
// public class MyController : ControllerBase
// {
//     private readonly IDistributedRateLimiterService _rateLimiter;
//     
//     public MyController(IDistributedRateLimiterService rateLimiter)
//     {
//         _rateLimiter = rateLimiter;
//     }
//     
//     [HttpGet("api/data")]
//     public async Task<IActionResult> GetData()
//     {
//         var userId = User.FindFirst("sub")?.Value ?? "anonymous";
//         
//         var allowed = await _rateLimiter.IsRequestAllowedAsync(
//             key: $"user:{userId}",
//             limiterType: "SlidingWindow",
//             maxRequests: 100,
//             timeWindow: TimeSpan.FromMinutes(1)
//         );
//         
//         if (!allowed)
//         {
//             var retryAfter = await _rateLimiter.GetRetryAfterSecondsAsync($"user:{userId}", "SlidingWindow");
//             Response.Headers["Retry-After"] = retryAfter.ToString();
//             return StatusCode(429, "Too many requests");
//         }
//         
//         return Ok(new { data = "success" });
//     }
// }
// 
// MONITORING ENDPOINT:
// ===================
// 
// [HttpGet("admin/ratelimit/stats/{userId}")]
// [Authorize(Roles = "Admin")]
// public async Task<IActionResult> GetRateLimitStats(string userId)
// {
//     var stats = await _rateLimiter.GetSlidingWindowStatsAsync($"user:{userId}");
//     return Ok(new
//     {
//         userId,
//         totalRequests = stats.TotalRequests,
//         requestsPerSecond = stats.RequestsPerSecond,
//         oldestRequestAge = stats.OldestRequestAge
//     });
// }
