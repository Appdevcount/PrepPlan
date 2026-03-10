using System;

namespace CareCoordination.Api.RateLimiting.Configuration
{
    /// <summary>
    /// Configuration model for distributed rate limiting
    /// </summary>
    public class RateLimiterConfig
    {
        /// <summary>
        /// Enable distributed rate limiting (uses Redis)
        /// If false, falls back to in-memory rate limiting
        /// </summary>
        public bool UseDistributedRateLimiting { get; set; } = false;

        /// <summary>
        /// Redis connection string for distributed rate limiting
        /// Example: "localhost:6379,ssl=false,abortConnect=false"
        /// </summary>
        public string RedisConnectionString { get; set; } = string.Empty;

        /// <summary>
        /// Redis database number (0-15 typically)
        /// Use different database for isolation from other Redis data
        /// </summary>
        public int RedisDatabase { get; set; } = 0;

        /// <summary>
        /// Prefix for all Redis keys to avoid collisions
        /// Example: "ratelimit:" -> Keys like "ratelimit:ip:192.168.1.1"
        /// </summary>
        public string RedisKeyPrefix { get; set; } = "ratelimit:";

        /// <summary>
        /// Enable Redis key expiration cleanup
        /// Automatically removes expired keys to save memory
        /// </summary>
        public bool EnableKeyExpiration { get; set; } = true;

        /// <summary>
        /// Connection timeout for Redis operations (in milliseconds)
        /// </summary>
        public int RedisConnectionTimeout { get; set; } = 5000;

        /// <summary>
        /// Enable fallback to in-memory if Redis is unavailable
        /// Prevents application downtime if Redis fails
        /// </summary>
        public bool EnableFallbackToInMemory { get; set; } = true;

        /// <summary>
        /// Log rate limit violations for monitoring
        /// </summary>
        public bool LogRateLimitViolations { get; set; } = true;

        /// <summary>
        /// Default rate limit settings - Fixed Window
        /// </summary>
        public FixedWindowSettings FixedWindow { get; set; } = new();

        /// <summary>
        /// Default rate limit settings - Sliding Window
        /// </summary>
        public SlidingWindowSettings SlidingWindow { get; set; } = new();

        /// <summary>
        /// Default rate limit settings - Token Bucket
        /// </summary>
        public TokenBucketSettings TokenBucket { get; set; } = new();

        /// <summary>
        /// Default rate limit settings - Concurrency
        /// </summary>
        public ConcurrencySettings Concurrency { get; set; } = new();
    }

    public class FixedWindowSettings
    {
        public int WindowSeconds { get; set; } = 60;
        public int MaxRequests { get; set; } = 100;
    }

    public class SlidingWindowSettings
    {
        public int WindowSeconds { get; set; } = 60;
        public int MaxRequests { get; set; } = 100;
        public int Segments { get; set; } = 6;
    }

    public class TokenBucketSettings
    {
        public int BucketCapacity { get; set; } = 100;
        public int RefillRate { get; set; } = 10; // tokens per second
        public int RefillInterval { get; set; } = 1; // seconds
    }

    public class ConcurrencySettings
    {
        public int MaxConcurrentRequests { get; set; } = 50;
        public int QueueLimit { get; set; } = 10;
    }
}
