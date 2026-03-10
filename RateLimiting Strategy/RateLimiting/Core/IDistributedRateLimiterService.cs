using System;
using System.Threading.Tasks;

namespace CareCoordination.Api.RateLimiting.Core
{
    /// <summary>
    /// Interface for distributed rate limiting service
    /// Used across multiple server instances with Redis as centralized store
    /// </summary>
    public interface IDistributedRateLimiterService
    {
        /// <summary>
        /// Check if a request is allowed under the rate limit
        /// </summary>
        /// <param name="key">Unique identifier (IP, UserID, API Key, etc.)</param>
        /// <param name="limiterType">Type of rate limiter (FixedWindow, SlidingWindow, TokenBucket, Concurrency)</param>
        /// <param name="maxRequests">Maximum number of requests allowed</param>
        /// <param name="timeWindow">Time window for the rate limit</param>
        /// <returns>True if request is allowed, false if rate limit exceeded</returns>
        Task<bool> IsRequestAllowedAsync(string key, string limiterType, int maxRequests, TimeSpan timeWindow);

        /// <summary>
        /// Get remaining requests for a given key
        /// </summary>
        /// <param name="key">Unique identifier</param>
        /// <param name="limiterType">Type of rate limiter</param>
        /// <returns>Number of remaining requests allowed</returns>
        Task<int> GetRemainingRequestsAsync(string key, string limiterType);

        /// <summary>
        /// Get retry-after seconds when rate limit is exceeded
        /// </summary>
        /// <param name="key">Unique identifier</param>
        /// <param name="limiterType">Type of rate limiter</param>
        /// <returns>Seconds until rate limit resets</returns>
        Task<int> GetRetryAfterSecondsAsync(string key, string limiterType);

        /// <summary>
        /// Reset rate limit for a specific key (admin/debugging purposes)
        /// </summary>
        /// <param name="key">Unique identifier</param>
        /// <param name="limiterType">Type of rate limiter</param>
        Task ResetRateLimitAsync(string key, string limiterType);

        /// <summary>
        /// Acquire concurrency slot (must be released when done)
        /// </summary>
        Task<(bool acquired, string requestId)> AcquireConcurrencySlotAsync(string key, int maxConcurrent, int timeoutSeconds = 300);

        /// <summary>
        /// Release concurrency slot (MUST be called in finally block)
        /// </summary>
        Task ReleaseConcurrencySlotAsync(string key, string requestId);

        /// <summary>
        /// Get sliding window statistics (for monitoring dashboard)
        /// </summary>
        Task<SlidingWindowStats> GetSlidingWindowStatsAsync(string key, int windowSeconds = 60);

        /// <summary>
        /// Get token bucket statistics (for monitoring dashboard)
        /// </summary>
        Task<TokenBucketStats> GetTokenBucketStatsAsync(string key, int bucketCapacity = 100, int refillRate = 10);

        /// <summary>
        /// Get concurrency statistics (for monitoring dashboard)
        /// </summary>
        Task<ConcurrencyStats> GetConcurrencyStatsAsync(string key, int maxConcurrent = 50, int timeoutSeconds = 300);
    }

    // Statistics classes for monitoring
    public class SlidingWindowStats
    {
        public int TotalRequests { get; set; }
        public double RequestsPerSecond { get; set; }
        public double OldestRequestAge { get; set; }
    }

    public class TokenBucketStats
    {
        public double CurrentTokens { get; set; }
        public int BucketCapacity { get; set; }
        public double PercentageFull { get; set; }
    }

    public class ConcurrencyStats
    {
        public int CurrentConcurrency { get; set; }
        public int MaxConcurrency { get; set; }
        public int AvailableSlots { get; set; }
    }
}
