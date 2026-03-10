using CareCoordination.Api.RateLimiting.Core;
using CareCoordination.Api.RateLimiting.Core;
using CareCoordination.Api.RateLimiting.Configuration;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StackExchange.Redis;
using System;
using System.Threading.RateLimiting;

namespace CareCoordination.Api.RateLimiting.Configuration
{
    /// <summary>
    /// Extension methods for configuring distributed rate limiting
    /// Supports both in-memory (single server) and Redis (distributed) implementations
    /// </summary>
    public static class DistributedRateLimiterExtensions
    {
        /// <summary>
        /// Add distributed rate limiting services to DI container
        /// 
        /// CONFIGURATION IN APPSETTINGS.JSON:
        /// {
        ///   "RateLimiter": {
        ///     "UseDistributedRateLimiting": true,
        ///     "RedisConnectionString": "localhost:6379",
        ///     "RedisDatabase": 1,
        ///     "RedisKeyPrefix": "ratelimit:",
        ///     "EnableFallbackToInMemory": true
        ///   }
        /// }
        /// </summary>
        public static IServiceCollection AddDistributedRateLimiting(
            this IServiceCollection services, 
            IConfiguration configuration)
        {
            // Load rate limiter configuration from appsettings
            var rateLimiterConfig = configuration.GetSection("RateLimiter").Get<RateLimiterConfig>() 
                                    ?? new RateLimiterConfig();

            // Register configuration as singleton for access in services
            services.AddSingleton(rateLimiterConfig);

            if (rateLimiterConfig.UseDistributedRateLimiting)
            {
                // ========================================
                // DISTRIBUTED MODE: Use Redis
                // ========================================
                
                // Configure Redis connection
                var redisOptions = ConfigurationOptions.Parse(rateLimiterConfig.RedisConnectionString);
                redisOptions.ConnectTimeout = rateLimiterConfig.RedisConnectionTimeout;
                redisOptions.AbortOnConnectFail = false; // Don't crash if Redis unavailable
                redisOptions.DefaultDatabase = rateLimiterConfig.RedisDatabase;

                // Register Redis connection as singleton
                services.AddSingleton<IConnectionMultiplexer>(sp =>
                {
                    try
                    {
                        return ConnectionMultiplexer.Connect(redisOptions);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Failed to connect to Redis: {ex.Message}");
                        
                        if (rateLimiterConfig.EnableFallbackToInMemory)
                        {
                            Console.WriteLine("Falling back to in-memory rate limiting");
                            return null; // Service will handle null and fallback
                        }
                        
                        throw; // Fail fast if fallback disabled
                    }
                });

                // Register distributed rate limiter service
                services.AddSingleton<IDistributedRateLimiterService>(sp =>
                {
                    var redis = sp.GetService<IConnectionMultiplexer>();
                    return new DistributedRateLimiterService(
                        redis,
                        useDistributed: redis != null,
                        fallbackToInMemory: rateLimiterConfig.EnableFallbackToInMemory,
                        keyPrefix: rateLimiterConfig.RedisKeyPrefix
                    );
                });
            }
            else
            {
                // ========================================
                // IN-MEMORY MODE: Single Server
                // ========================================
                
                // Register rate limiter service that always uses in-memory
                services.AddSingleton<IDistributedRateLimiterService>(sp =>
                {
                    return new DistributedRateLimiterService(
                        redis: null,
                        useDistributed: false,
                        fallbackToInMemory: true
                    );
                });
            }

            return services;
        }

        /// <summary>
        /// Add distributed rate limiting with custom Redis connection
        /// Use this when you already have Redis configured
        /// </summary>
        public static IServiceCollection AddDistributedRateLimiting(
            this IServiceCollection services,
            IConnectionMultiplexer redis,
            string keyPrefix = "ratelimit:")
        {
            services.AddSingleton<IDistributedRateLimiterService>(sp =>
            {
                return new DistributedRateLimiterService(
                    redis,
                    useDistributed: true,
                    fallbackToInMemory: true,
                    keyPrefix: keyPrefix
                );
            });

            return services;
        }

        /// <summary>
        /// Add hybrid rate limiting: In-memory for most endpoints, distributed for specific ones
        /// Best for gradual migration or cost optimization
        /// 
        /// Example:
        /// - Public API endpoints ? Distributed (strict enforcement)
        /// - Internal endpoints ? In-memory (lower latency)
        /// </summary>
        public static IServiceCollection AddHybridRateLimiting(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            // Add both in-memory (built-in ASP.NET Core) and distributed (Redis)
            
            // In-memory rate limiting (existing code in Program.cs)
            services.AddRateLimiter(options =>
            {
                // Keep existing in-memory limiters for internal use
                options.AddFixedWindowLimiter("InMemory_Fixed", opt =>
                {
                    opt.Window = TimeSpan.FromSeconds(10);
                    opt.PermitLimit = 100;
                    opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
                    opt.QueueLimit = 0;
                });
            });

            // Distributed rate limiting for critical endpoints
            services.AddDistributedRateLimiting(configuration);

            return services;
        }
    }

    /// <summary>
    /// Custom middleware for distributed rate limiting
    /// Apply to specific routes or globally
    /// 
    /// USAGE IN PROGRAM.CS:
    /// app.UseDistributedRateLimiting();
    /// 
    /// OR per endpoint:
    /// app.MapGet("/api/public/data", handler).UseDistributedRateLimiting("SlidingWindow", 100, 60);
    /// </summary>
    public static class DistributedRateLimiterMiddlewareExtensions
    {
        /// <summary>
        /// Use distributed rate limiting middleware globally
        /// Applies to ALL endpoints unless explicitly disabled
        /// </summary>
        public static IApplicationBuilder UseDistributedRateLimitingMiddleware(
            this IApplicationBuilder app,
            string limiterType = "FixedWindow",
            int maxRequests = 1000,
            int windowSeconds = 60)
        {
            app.Use(async (context, next) =>
            {
                var rateLimiter = context.RequestServices.GetService<IDistributedRateLimiterService>();
                
                if (rateLimiter != null)
                {
                    // Extract identifier (IP by default, can be customized)
                    var identifier = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
                    
                    // Check rate limit
                    var allowed = await rateLimiter.IsRequestAllowedAsync(
                        identifier,
                        limiterType,
                        maxRequests,
                        TimeSpan.FromSeconds(windowSeconds)
                    );

                    if (!allowed)
                    {
                        // Rate limit exceeded
                        var retryAfter = await rateLimiter.GetRetryAfterSecondsAsync(identifier, limiterType);
                        context.Response.Headers["Retry-After"] = retryAfter.ToString();
                        context.Response.StatusCode = 429;
                        await context.Response.WriteAsync("Too many requests. Please try again later.");
                        return;
                    }

                    // Add rate limit headers for transparency
                    var remaining = await rateLimiter.GetRemainingRequestsAsync(identifier, limiterType);
                    context.Response.Headers["X-RateLimit-Limit"] = maxRequests.ToString();
                    context.Response.Headers["X-RateLimit-Remaining"] = remaining.ToString();
                }

                await next();
            });

            return app;
        }
    }
}

// ============================================================
// USAGE EXAMPLES
// ============================================================

// 1. BASIC SETUP (Program.cs):
// -----------------------------
// builder.Services.AddDistributedRateLimiting(builder.Configuration);
// 
// app.UseDistributedRateLimitingMiddleware("SlidingWindow", 1000, 60);

// 2. HYBRID SETUP (some distributed, some in-memory):
// ---------------------------------------------------
// builder.Services.AddHybridRateLimiting(builder.Configuration);
// 
// // Public endpoints use distributed
// app.MapGet("/api/public/data", handler)
//    .UseDistributedRateLimiting("SlidingWindow", 100, 60);
// 
// // Internal endpoints use in-memory (faster)
// app.MapGet("/api/internal/data", handler)
//    .RequireRateLimiting("InMemory_Fixed");

// 3. CUSTOM REDIS CONNECTION:
// ---------------------------
// var redis = ConnectionMultiplexer.Connect("your-redis-connection");
// builder.Services.AddDistributedRateLimiting(redis, "myapp:ratelimit:");

// 4. CONTROLLER-BASED USAGE:
// ---------------------------
// public class ApiController : ControllerBase
// {
//     private readonly IDistributedRateLimiterService _rateLimiter;
//     
//     [HttpPost("upload")]
//     public async Task<IActionResult> Upload()
//     {
//         var userId = User.FindFirst("sub")?.Value;
//         var (acquired, requestId) = await _rateLimiter.AcquireConcurrencySlotAsync(userId, 5);
//         
//         if (!acquired)
//         {
//             return StatusCode(429, "Too many concurrent uploads");
//         }
//         
//         try
//         {
//             await ProcessUploadAsync();
//             return Ok();
//         }
//         finally
//         {
//             await _rateLimiter.ReleaseConcurrencySlotAsync(userId, requestId);
//         }
//     }
// }

// ============================================================
// MONITORING & OBSERVABILITY
// ============================================================

// Add health check for Redis connectivity:
// builder.Services.AddHealthChecks()
//     .AddRedis(
//         configuration["RateLimiter:RedisConnectionString"],
//         name: "redis-ratelimiter",
//         tags: new[] { "ratelimiter", "redis" }
//     );

// Add Application Insights custom metrics:
// - Rate limit hits/misses
// - Redis latency
// - Fallback events
// - Top rate-limited IPs/users
