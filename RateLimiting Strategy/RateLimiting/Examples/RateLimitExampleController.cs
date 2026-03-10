using CareCoordination.Api.RateLimiting.Core;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace CareCoordination.Api.RateLimiting.Examples
{
    /// <summary>
    /// Example controller demonstrating distributed rate limiting patterns
    /// COPY THESE PATTERNS to your actual controllers
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class RateLimitExampleController : ControllerBase
    {
        private readonly IDistributedRateLimiterService _rateLimiter;
        private readonly ILogger<RateLimitExampleController> _logger;

        public RateLimitExampleController(
            IDistributedRateLimiterService rateLimiter,
            ILogger<RateLimitExampleController> logger)
        {
            _rateLimiter = rateLimiter;
            _logger = logger;
        }

        // ============================================================
        // EXAMPLE 1: IP-BASED RATE LIMITING
        // ============================================================
        // Limit requests per IP address
        // Use for: Public endpoints, preventing IP-based abuse
        [HttpGet("ip-limited")]
        public async Task<IActionResult> IpBasedExample()
        {
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var key = $"ip:{ipAddress}";

            var allowed = await _rateLimiter.IsRequestAllowedAsync(
                key: key,
                limiterType: "FixedWindow",
                maxRequests: 60, // 60 requests
                timeWindow: TimeSpan.FromMinutes(1) // per minute
            );

            if (!allowed)
            {
                var retryAfter = await _rateLimiter.GetRetryAfterSecondsAsync(key, "FixedWindow");
                Response.Headers["Retry-After"] = retryAfter.ToString();
                
                _logger.LogWarning("Rate limit exceeded for IP: {IP}", ipAddress);
                
                return StatusCode(429, new
                {
                    error = "Too many requests",
                    message = $"Please try again in {retryAfter} seconds",
                    ipAddress = ipAddress
                });
            }

            // Add rate limit info headers
            var remaining = await _rateLimiter.GetRemainingRequestsAsync(key, "FixedWindow");
            Response.Headers["X-RateLimit-Limit"] = "60";
            Response.Headers["X-RateLimit-Remaining"] = remaining.ToString();

            return Ok(new { message = "Success", ipAddress });
        }

        // ============================================================
        // EXAMPLE 2: USER-BASED RATE LIMITING
        // ============================================================
        // Limit requests per authenticated user
        // Use for: Protecting user-specific resources
        [HttpGet("user-limited")]
        [Authorize] // Requires authentication
        public async Task<IActionResult> UserBasedExample()
        {
            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                         ?? User.FindFirst("sub")?.Value
                         ?? "anonymous";
            
            var key = $"user:{userId}";

            // Different limits for anonymous vs authenticated
            var maxRequests = userId == "anonymous" ? 10 : 100;

            var allowed = await _rateLimiter.IsRequestAllowedAsync(
                key: key,
                limiterType: "SlidingWindow", // Smooth rate limiting
                maxRequests: maxRequests,
                timeWindow: TimeSpan.FromMinutes(1)
            );

            if (!allowed)
            {
                var retryAfter = await _rateLimiter.GetRetryAfterSecondsAsync(key, "SlidingWindow");
                Response.Headers["Retry-After"] = retryAfter.ToString();
                
                return StatusCode(429, new
                {
                    error = "Too many requests",
                    userId = userId,
                    limit = maxRequests
                });
            }

            return Ok(new { message = "Success", userId, limit = maxRequests });
        }

        // ============================================================
        // EXAMPLE 3: API KEY-BASED RATE LIMITING (SUBSCRIPTION TIERS)
        // ============================================================
        // Different limits based on subscription tier
        // Use for: External API consumers with paid tiers
        [HttpGet("subscription-limited")]
        public async Task<IActionResult> SubscriptionBasedExample()
        {
            var apiKey = Request.Headers["X-API-KEY"].FirstOrDefault() ?? "none";
            
            // In production, look up tier from database
            var tier = GetSubscriptionTier(apiKey);
            var (maxRequests, limiterType) = GetTierLimits(tier);

            var key = $"apikey:{apiKey}";

            var allowed = await _rateLimiter.IsRequestAllowedAsync(
                key: key,
                limiterType: limiterType,
                maxRequests: maxRequests,
                timeWindow: TimeSpan.FromMinutes(1)
            );

            if (!allowed)
            {
                var retryAfter = await _rateLimiter.GetRetryAfterSecondsAsync(key, limiterType);
                Response.Headers["Retry-After"] = retryAfter.ToString();
                
                return StatusCode(429, new
                {
                    error = "Rate limit exceeded",
                    tier = tier,
                    limit = $"{maxRequests} requests/minute",
                    message = "Upgrade your subscription for higher limits"
                });
            }

            var remaining = await _rateLimiter.GetRemainingRequestsAsync(key, limiterType);
            Response.Headers["X-RateLimit-Tier"] = tier;
            Response.Headers["X-RateLimit-Limit"] = maxRequests.ToString();
            Response.Headers["X-RateLimit-Remaining"] = remaining.ToString();

            return Ok(new
            {
                message = "Success",
                tier = tier,
                limit = maxRequests,
                remaining = remaining
            });
        }

        // ============================================================
        // EXAMPLE 4: CONCURRENCY LIMITING (FILE UPLOADS)
        // ============================================================
        // Limit number of concurrent long-running operations
        // Use for: File uploads, video processing, report generation
        [HttpPost("upload")]
        public async Task<IActionResult> ConcurrencyLimitedExample([FromForm] IFormFile file)
        {
            var userId = User.FindFirst("sub")?.Value ?? "anonymous";
            var key = $"upload:{userId}";

            // Try to acquire concurrency slot
            var (acquired, requestId) = await _rateLimiter.AcquireConcurrencySlotAsync(
                key: key,
                maxConcurrent: 3, // Max 3 concurrent uploads per user
                timeoutSeconds: 300 // 5 minute timeout
            );

            if (!acquired)
            {
                return StatusCode(429, new
                {
                    error = "Too many concurrent uploads",
                    message = "Please wait for your current uploads to complete",
                    maxConcurrent = 3
                });
            }

            try
            {
                _logger.LogInformation("Upload started for user {UserId}, RequestId: {RequestId}", userId, requestId);

                // Simulate long-running upload
                await Task.Delay(TimeSpan.FromSeconds(2));
                
                // In real code: await _storageService.UploadFileAsync(file);

                return Ok(new
                {
                    message = "Upload successful",
                    fileName = file.FileName,
                    requestId = requestId
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Upload failed for user {UserId}", userId);
                return StatusCode(500, "Upload failed");
            }
            finally
            {
                // CRITICAL: Always release concurrency slot
                await _rateLimiter.ReleaseConcurrencySlotAsync(key, requestId);
                _logger.LogInformation("Upload completed for user {UserId}, RequestId: {RequestId}", userId, requestId);
            }
        }

        // ============================================================
        // EXAMPLE 5: TOKEN BUCKET (BURST TRAFFIC HANDLING)
        // ============================================================
        // Allows burst traffic while maintaining average rate
        // Use for: Mobile apps, batch operations, video streaming
        [HttpGet("burst-allowed")]
        public async Task<IActionResult> TokenBucketExample()
        {
            var userId = User.FindFirst("sub")?.Value ?? "anonymous";
            var key = $"burst:{userId}";

            var allowed = await _rateLimiter.IsRequestAllowedAsync(
                key: key,
                limiterType: "TokenBucket",
                maxRequests: 100, // Bucket capacity
                timeWindow: TimeSpan.FromSeconds(10) // Refill period
            );

            if (!allowed)
            {
                var retryAfter = await _rateLimiter.GetRetryAfterSecondsAsync(key, "TokenBucket");
                Response.Headers["Retry-After"] = retryAfter.ToString();
                
                return StatusCode(429, new
                {
                    error = "Rate limit exceeded",
                    message = "Token bucket empty. Please wait for refill."
                });
            }

            return Ok(new { message = "Success - burst traffic allowed" });
        }

        // ============================================================
        // EXAMPLE 6: ADMIN ENDPOINT - RESET RATE LIMITS
        // ============================================================
        // Allow admins to reset rate limits (debugging, customer support)
        [HttpPost("admin/reset/{userId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ResetRateLimit(string userId, [FromQuery] string limiterType = "FixedWindow")
        {
            var key = $"user:{userId}";
            
            await _rateLimiter.ResetRateLimitAsync(key, limiterType);
            
            _logger.LogWarning("Rate limit reset by admin for user {UserId}, type {LimiterType}", userId, limiterType);
            
            return Ok(new
            {
                message = "Rate limit reset successfully",
                userId = userId,
                limiterType = limiterType
            });
        }

        // ============================================================
        // EXAMPLE 7: MONITORING ENDPOINT - GET RATE LIMIT STATS
        // ============================================================
        // Monitor rate limit usage for analytics
        [HttpGet("admin/stats/{userId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetRateLimitStats(string userId)
        {
            var key = $"user:{userId}";
            
            // Get stats from different limiters
            var slidingStats = await _rateLimiter.GetSlidingWindowStatsAsync(key, 60);
            var tokenStats = await _rateLimiter.GetTokenBucketStatsAsync(key, 100, 10);
            var concurrencyStats = await _rateLimiter.GetConcurrencyStatsAsync(key, 5);
            
            return Ok(new
            {
                userId = userId,
                slidingWindow = new
                {
                    totalRequests = slidingStats.TotalRequests,
                    requestsPerSecond = slidingStats.RequestsPerSecond,
                    oldestRequestAge = slidingStats.OldestRequestAge
                },
                tokenBucket = new
                {
                    currentTokens = tokenStats.CurrentTokens,
                    capacity = tokenStats.BucketCapacity,
                    percentageFull = tokenStats.PercentageFull
                },
                concurrency = new
                {
                    currentConcurrent = concurrencyStats.CurrentConcurrency,
                    maxConcurrent = concurrencyStats.MaxConcurrency,
                    availableSlots = concurrencyStats.AvailableSlots
                }
            });
        }

        // ============================================================
        // HELPER METHODS
        // ============================================================

        private string GetSubscriptionTier(string apiKey)
        {
            // In production, look up from database/cache
            if (apiKey.StartsWith("gold_")) return "Gold";
            if (apiKey.StartsWith("silver_")) return "Silver";
            if (apiKey.StartsWith("bronze_")) return "Bronze";
            return "Free";
        }

        private (int maxRequests, string limiterType) GetTierLimits(string tier)
        {
            return tier switch
            {
                "Gold" => (10000, "TokenBucket"),    // 10k requests/min with burst
                "Silver" => (1000, "SlidingWindow"), // 1k requests/min smooth
                "Bronze" => (100, "SlidingWindow"),  // 100 requests/min smooth
                _ => (10, "FixedWindow")             // 10 requests/min strict
            };
        }
    }
}

// ============================================================
// DEPLOYMENT CHECKLIST
// ============================================================
// 
// ? Install Redis (Azure Redis Cache, AWS ElastiCache, or self-hosted)
// ? Update appsettings.json with Redis connection string
// ? Set UseDistributedRateLimiting = true
// ? Add StackExchange.Redis NuGet package
// ? Test Redis connectivity before deploying
// ? Set up Redis monitoring/alerts
// ? Configure Redis persistence (AOF/RDB)
// ? Enable Redis Cluster for high availability
// ? Test fallback behavior when Redis is down
// ? Monitor rate limit violations in Application Insights
// 
// ============================================================
// PERFORMANCE CONSIDERATIONS
// ============================================================
// 
// In-Memory Rate Limiting:
// • Latency: ~0.001ms (nanoseconds)
// • Consistency: Per-server only
// • Memory: ~10KB per 1000 users
// • Cost: Free
// 
// Distributed Rate Limiting (Redis):
// • Latency: ~1-2ms (network round-trip)
// • Consistency: Cross all servers
// • Memory: Redis RAM (~100 bytes per user)
// • Cost: Redis hosting ($20-500/month)
// 
// RECOMMENDATION:
// • Development: In-memory (faster, simpler)
// • Production (1 server): In-memory
// • Production (multiple servers): Distributed (Redis)
// • Hybrid: In-memory for internal, distributed for public APIs
