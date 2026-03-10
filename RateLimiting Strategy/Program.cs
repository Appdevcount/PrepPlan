using CareCoordination.Api.Helpers;
using CareCoordination.Api.Middleware;
using CareCoordination.Api.RateLimiting.Configuration;
using CareCoordination.Application.Abstracts.DALInterfaces;
using CareCoordination.Application.Abstracts.HandlerInterfaces;
using CareCoordination.Application.Abstracts.ServiceInterfaces;
using CareCoordination.Application.Handlers;
using CareCoordination.Application.Logger;
using CareCoordination.DAL.Configuration;
using CareCoordination.DAL.Implementation;
using CareCoordination.Domain.Constants;
using CareCoordination.Services.Helpers;
using CareCoordination.Services.Implementation;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.Metrics;
using System.Net.Sockets;
using System.Resources;
using System.Security.Cryptography;
using System.ServiceModel.Channels;
using System.Text;
using System.Threading.RateLimiting;
using System.Threading.Tasks;
using static Dapper.SqlMapper;
using static System.Runtime.InteropServices.JavaScript.JSType;


var builder = WebApplication.CreateBuilder(args);

// Configure Dapper type handlers early in the application startup
DapperConfiguration.Configure();

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddControllers(options =>
{
    options.Filters.Add<XssFilterAttribute>();
});


// Add HSTS configuration
builder.Services.AddHsts(options =>
{
    options.Preload = true;
    options.IncludeSubDomains = true;
    options.MaxAge = TimeSpan.FromDays(365);
});

builder.Services.RegisterServices();
builder.Services.AddCors(allowsites
=> allowsites.AddPolicy(name: "AllowOrigin", options => options
.WithOrigins("https://imageone.carecorenational.com/CareCoordinationUI", "http://localhost:3000/", "http://localhost:5290", "https://localhost:7036")
.AllowAnyHeader()
.AllowAnyMethod()));

// ============================================================
// DISTRIBUTED RATE LIMITING SETUP
// ============================================================
// Add distributed rate limiting service (Redis-based)
// This provides centralized rate limiting across multiple server instances
// Configuration is loaded from appsettings.json "RateLimiter" section
// 
// SETUP INSTRUCTIONS:
// 1. Set "UseDistributedRateLimiting": true in appsettings.json
// 2. Configure Redis connection string
// 3. Service will automatically use Redis for rate limiting
// 
// If UseDistributedRateLimiting = false, the service is still registered
// but acts as a no-op (allows all requests)
// This enables you to use the same code with/without Redis
builder.Services.AddDistributedRateLimiting(builder.Configuration);

// ============================================================
// IN-MEMORY RATE LIMITING SETUP (Original)
// ============================================================
// This section configures ASP.NET Core's built-in rate limiting
// USE CASES:
// • Single server deployment (no load balancer)
// • Low latency requirements (nanoseconds vs milliseconds)
// • Development/testing environments
// • Internal endpoints that don't need strict enforcement
// 
// For distributed systems (multiple servers), use the distributed
// rate limiter service above instead
// ============================================================

builder.Services.AddRateLimiter(rateLimiterOptions =>
{
    rateLimiterOptions.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
    {
        // Global limiter that applies to all requests - can be used for overall API protection
        // Example: Limit to 1000 requests per minute globally
        return RateLimitPartition.GetFixedWindowLimiter("Global", _ => new FixedWindowRateLimiterOptions
        {
            Window = TimeSpan.FromMinutes(1),
            PermitLimit = 1000,
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            QueueLimit = 0,
            AutoReplenishment = true
        });
    });
    // ============================================================
    // 1. FIXED WINDOW LIMITER (Currently in your code)
    // ============================================================
    // Allows a fixed number of requests within a time window.
    // Window resets completely after the time period expires.
    // Example: 100 requests per 10 seconds - at 0:10, counter resets to 0
    rateLimiterOptions.AddFixedWindowLimiter("Fixed", options =>
    {
        // Time period for the window
        options.Window = TimeSpan.FromSeconds(10);

        // Maximum number of requests allowed in the window
        options.PermitLimit = 100;

        // How queued requests are processed when limit is reached
        // OldestFirst = FIFO (First In, First Out)
        // NewestFirst = LIFO (Last In, First Out)
        options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;

        // Number of requests to queue when limit is reached
        // 0 = no queuing, requests are rejected immediately
        options.QueueLimit = 0;

        // Whether the limiter should automatically replenish permits
        options.AutoReplenishment = true;
    });

    // ============================================================
    // 2. SLIDING WINDOW LIMITER
    // ============================================================
    // Similar to Fixed Window but smoother - uses both current and previous window
    // Prevents burst traffic at window boundaries
    // Example: At 0:15, considers requests from both 0:00-0:10 and 0:10-0:20
    rateLimiterOptions.AddSlidingWindowLimiter("Sliding", options =>
    {
//    When to Choose Sliding Window 🎯
//✅ Use Sliding Window when:
//•	You need fair, smooth rate limiting
//•	You want to prevent boundary burst attacks
//•	Your API serves many concurrent users
//•	You need more predictable behavior
//❌ Don't use Sliding Window when:
//•	You have extremely high traffic(use Token Bucket)
//•	You need to limit concurrent operations(use Concurrency Limiter)
//•	Memory is extremely constrained (use Fixed Window)
        // Time period for each window segment
        options.Window = TimeSpan.FromSeconds(10);

        // Maximum requests allowed per window
        options.PermitLimit = 100;

        // Number of segments to divide the window into
        // More segments = smoother rate limiting but more memory
        // Example: 5 segments = window divided into 5 parts of 2 seconds each
        options.SegmentsPerWindow = 5;
        //// More segments = More accurate but uses MORE memory
        //options.SegmentsPerWindow = 60;  // Very smooth, but 60 buckets to track

        //// Fewer segments = Less accurate but uses LESS memory  
        //options.SegmentsPerWindow = 2;   // Almost like fixed window

        //// Your config = Balanced middle ground
        //options.SegmentsPerWindow = 5;   // Good balance ✅
//        At 10:00, the limiter checks:
//        -Last 10 minutes = 9:50 - 10:00
//        - Counts ALL requests in this rolling window
//-Smoothly prevents the boundary burst

        options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        options.QueueLimit = 0;
    });

    // ============================================================
    // 3. TOKEN BUCKET LIMITER
    // ============================================================
    // Bucket starts with tokens. Each request consumes a token.
    // Tokens replenish at a constant rate.
    // Allows short bursts while maintaining average rate
    // Good for APIs that need to handle occasional spikes
    rateLimiterOptions.AddTokenBucketLimiter("TokenBucket", options =>
    {
//    Think of the Token Bucket like a restaurant with a ticket system:
//•	The Bucket = A bowl that holds meal tickets
//•	Tokens = Physical tickets that customers need to order
//•	TokenLimit(100) = The bowl can hold max 100 tickets
//•	Each Request = A customer wants to order, needs 1 ticket
//•	Replenishment = Staff adds new tickets to the bowl at a steady rate

//// Fixed Window (strict, resets completely)
//Fixed: 100 requests per 10 seconds
//At 0:09 → 99 requests used → User blocked
//At 0:10 → Counter resets to 0 → 100 requests available again

//// Token Bucket (flexible, gradual replenishment)
//Bucket: 100 tokens, refill 10 every 10 seconds
//At 0:09 → 99 tokens used → 1 token left
//At 0:10 → +10 tokens added → 11 tokens available(not reset to 100!)

//    Time | Tokens Available | Event
//-------- | ------------------| ----------------------------------------
//0:00 | 100 | Starting state(bucket full)
//0:01 | 70 | 30 requests come in (BURST accepted!)
//0:02 | 40 | 30 more requests(still OK)
//0:03 | 10 | 30 more requests(getting low)
//0:04 | 0 | 10 requests(bucket empty - reject new ones)
//0:10 | 10 | +10 tokens replenished(10 seconds passed)
//0:11 | 5 | 5 requests served from new tokens
//0:20 | 15 | +10 more tokens(20 seconds total)

        // Maximum number of tokens the bucket can hold
        // This allows burst requests up to this limit
        options.TokenLimit = 100;

        // How quickly tokens are added back to the bucket
        options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        options.QueueLimit = 0;

        // Time period for token replenishment
        options.ReplenishmentPeriod = TimeSpan.FromSeconds(10);

        // Number of tokens added per replenishment period
        // Example: 10 tokens every 10 seconds = 1 token/second average
        options.TokensPerPeriod = 10;

        // Whether to add tokens automatically over time
        options.AutoReplenishment = true;
    });

    // ============================================================
    // 4. CONCURRENCY LIMITER
    // ============================================================
    // Limits the NUMBER OF CONCURRENT REQUESTS being processed
    // Not time-based - focuses on simultaneous active requests
    // Ideal for protecting resource-intensive operations (database, file I/O)
    rateLimiterOptions.AddConcurrencyLimiter("Concurrency", options =>
    {
        //        // ❌ WRONG CHOICE: Fixed Window
        //        // Problem: All 100 users could upload at once = server crash!
        //        Window = 10 seconds, PermitLimit = 100
        //→ Allows 100 simultaneous large file operations

        //// ✅ RIGHT CHOICE: Concurrency
        //// Only 50 files processing at once = safe!
        //PermitLimit = 50
        //→ Limits actual concurrent load on server resources

//        Use Concurrency When       Use Fixed Window When
//✅ Protecting database connections   ✅ Preventing API abuse
//✅ Limiting file I / O operations  ✅ Enforcing usage quotas
//✅ CPU - intensive tasks   ✅ Simple rate limiting
//✅ Memory - intensive operations   ✅ Billing / pricing limits

        // Maximum number of requests that can be processed simultaneously
        options.PermitLimit = 50;

        options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;

        // Number of requests to queue when concurrent limit is reached
        options.QueueLimit = 10;
    });

    // ============================================================
    // 5. IP ADDRESS-BASED RATE LIMITING
    // ============================================================
    // Each IP address gets its own rate limit
    // Prevents single IP from abusing the API
    // Uses Fixed Window with partition key based on IP
    rateLimiterOptions.AddFixedWindowLimiter("IpBased", options =>
    {
        options.Window = TimeSpan.FromMinutes(1);
        options.PermitLimit = 60; // 60 requests per minute per IP
        options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        options.QueueLimit = 0;
        options.AutoReplenishment = true;
    }).AddPolicy("IpBased", context =>
    {
        // Extract IP address from request
        var ipAddress = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        
        // Create partition based on IP address
        return RateLimitPartition.GetFixedWindowLimiter(ipAddress, _ => new FixedWindowRateLimiterOptions
        {
            Window = TimeSpan.FromMinutes(1),
            PermitLimit = 60,
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            QueueLimit = 0,
            AutoReplenishment = true
        });
    });

    // ============================================================
    // 6. USER-BASED RATE LIMITING (Authenticated Users)
    // ============================================================
    // Each authenticated user gets their own rate limit
    // Requires authentication to be enabled
    // More generous limits for authenticated users
    rateLimiterOptions.AddPolicy("UserBased", context =>
    {
        // Extract user ID from claims (requires JWT authentication)
        var userId = context.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value 
                     ?? context.User?.FindFirst("sub")?.Value 
                     ?? "anonymous";
        
        // Different limits for authenticated vs anonymous users
        if (userId == "anonymous")
        {
            // Anonymous users: 10 requests per minute
            return RateLimitPartition.GetFixedWindowLimiter(userId, _ => new FixedWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                PermitLimit = 10,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0,
                AutoReplenishment = true
            });
        }
        else
        {
            // Authenticated users: 100 requests per minute
            return RateLimitPartition.GetFixedWindowLimiter(userId, _ => new FixedWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                PermitLimit = 100,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0,
                AutoReplenishment = true
            });
        }
    });

    // ============================================================
    // 7. SUBSCRIPTION KEY / API KEY-BASED RATE LIMITING
    // ============================================================
    // Each API key gets its own rate limit
    // Ideal for external API consumers with different subscription tiers
    // Bronze/Silver/Gold tier example
    rateLimiterOptions.AddPolicy("SubscriptionBased", context =>
    {
        // Extract API key from header
        var apiKey = context.Request.Headers["X-API-KEY"].FirstOrDefault() ?? "none";
        
        // In production, you would look up the subscription tier from database
        // For this example, we'll use a simple logic
        var subscriptionTier = GetSubscriptionTier(apiKey);
        
        return subscriptionTier switch
        {
            "Gold" => RateLimitPartition.GetTokenBucketLimiter(apiKey, _ => new TokenBucketRateLimiterOptions
            {
                TokenLimit = 1000,
                ReplenishmentPeriod = TimeSpan.FromMinutes(1),
                TokensPerPeriod = 1000,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0,
                AutoReplenishment = true
            }),
            "Silver" => RateLimitPartition.GetTokenBucketLimiter(apiKey, _ => new TokenBucketRateLimiterOptions
            {
                TokenLimit = 500,
                ReplenishmentPeriod = TimeSpan.FromMinutes(1),
                TokensPerPeriod = 500,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0,
                AutoReplenishment = true
            }),
            "Bronze" => RateLimitPartition.GetTokenBucketLimiter(apiKey, _ => new TokenBucketRateLimiterOptions
            {
                TokenLimit = 100,
                ReplenishmentPeriod = TimeSpan.FromMinutes(1),
                TokensPerPeriod = 100,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0,
                AutoReplenishment = true
            }),
            _ => RateLimitPartition.GetTokenBucketLimiter("default", _ => new TokenBucketRateLimiterOptions
            {
                TokenLimit = 10,
                ReplenishmentPeriod = TimeSpan.FromMinutes(1),
                TokensPerPeriod = 10,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0,
                AutoReplenishment = true
            })
        };
    });

    // ============================================================
    // 8. COMBINED IP + USER RATE LIMITING
    // ============================================================
    // Rate limit based on combination of IP and User
    // More granular control
    rateLimiterOptions.AddPolicy("IpAndUserBased", context =>
    {
        var ipAddress = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        var userId = context.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "anonymous";
        var partitionKey = $"{ipAddress}:{userId}";
        
        return RateLimitPartition.GetSlidingWindowLimiter(partitionKey, _ => new SlidingWindowRateLimiterOptions
        {
            Window = TimeSpan.FromMinutes(1),
            PermitLimit = 50,
            SegmentsPerWindow = 6,
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            QueueLimit = 0
        });
    });

    //// ============================================================
    //// CHAINED LIMITERS (Advanced)
    //// ============================================================
    //// Combine multiple limiters - request must pass ALL checks
    //// Example: Max 100 requests per minute AND max 10 concurrent requests
    //rateLimiterOptions.AddChainedLimiter("Chained", options =>
    //{
    //    options.Chains = new[]
    //    {
    //        "Fixed",        // Must pass fixed window check
    //        "Concurrency"   // AND must pass concurrency check
    //    };
    //});

//    instead of above use like below for chaining
//    [EnableRateLimiting("Fixed")]
//[EnableRateLimiting("Concurrency")] // Note: Only one will actually apply
//public class MyController : ControllerBase { }

// ============================================================
// GLOBAL REJECTION BEHAVIOR
// ============================================================
// Called when a request is rejected by any limiter
rateLimiterOptions.OnRejected = async (context, cancellationToken) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;

        // Optional: Add Retry-After header
        if (context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter))
        {
            context.HttpContext.Response.Headers.RetryAfter = retryAfter.TotalSeconds.ToString();
        }

        await context.HttpContext.Response.WriteAsync(
            "Too many requests. Please try again later.",
            cancellationToken);
    };
});

// Helper method to determine subscription tier
// In production, this should query a database or cache
static string GetSubscriptionTier(string apiKey)
{
    // This is a simplified example - in production, look up from database
    if (string.IsNullOrEmpty(apiKey) || apiKey == "none")
        return "None";
    
    // Example: You could check against a dictionary, database, or distributed cache
    // var tier = await _subscriptionService.GetTierAsync(apiKey);
    
    // For demonstration purposes only:
    if (apiKey.StartsWith("gold_"))
        return "Gold";
    if (apiKey.StartsWith("silver_"))
        return "Silver";
    if (apiKey.StartsWith("bronze_"))
        return "Bronze";
    
    return "Bronze"; // Default tier
}

//Quick Comparison Guide
//Limiter Type	Use Case	Key Benefit
//Fixed Window	Simple rate limiting	Easy to understand, predictable
//Sliding Window	Smooth rate limiting	Prevents boundary bursts
//Token Bucket	Bursty traffic	Allows short spikes, fair over time
//Concurrency	Resource protection	Limits simultaneous operations

//// Apply globally to all endpoints
//app.UseRateLimiter();

//// Or apply to specific endpoints:
//app.MapGet("/api/data", () => "Hello")
//    .RequireRateLimiting("Fixed");

//// Or on controllers:
//[EnableRateLimiting("Sliding")]
//public class MyController : ControllerBase { }


string connectionString = builder.Configuration.GetConnectionString("PreAuthin");
builder.Services.AddSingleton(connectionString);
builder.Services.AddSingleton<IApplicationLogger, AppInsightsLogger>();

    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            var rsa = RSA.Create();
            var CertConfigSubject = builder.Configuration["CertConfigSubject"] ?? throw new ArgumentException("CertConfigSubject missing.");
            string publicKeyPem = CertificateHelper.GetRSAPublicKey(CertConfigSubject);
            rsa.ImportFromPem(publicKeyPem.ToCharArray());
            options.Events = new JwtBearerEvents
            {
                OnAuthenticationFailed = context =>
                {
                    Console.WriteLine(context.Exception.Message);
                    return Task.CompletedTask;
                }
            };
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateLifetime = true,
                ValidateIssuer = false,
                ValidateAudience = false,
                IssuerSigningKey = new RsaSecurityKey(rsa),
                ValidateIssuerSigningKey = true,
                ClockSkew = TimeSpan.Zero,
            };
        });

//Auto Mapper Service
builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
builder.Services.AddOpenApi();
builder.Services.AddSwaggerGen(c =>
{
    // Define the API key scheme
    c.AddSecurityDefinition("ApiKey", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Name = "X-API-KEY",
        Type = SecuritySchemeType.ApiKey,
        Description = "API Key needed to access the endpoints"
    });
    // Define the JWT bearer scheme
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "JWT Authorization header using the Bearer scheme."
    });
    // Apply security requirements globally
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
{
{
new OpenApiSecurityScheme
{
Reference = new OpenApiReference
{
Type = ReferenceType.SecurityScheme,
Id = "Bearer"
}
},
new string[] {}
}
});

});


var app = builder.Build();

app.MapOpenApi();
app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("./v1/swagger.json", "Care Coordination");
});

app.UseHttpsRedirection();

app.UseCors("AllowOrigin");

// Enhanced HSTS configuration
app.UseHsts();

app.UseHttpsRedirection();
app.UseRouting();

// Enhanced security headers
app.Use(async (context, next) =>
{
    // Remove server information disclosure
    context.Response.Headers.Remove("X-Powered-By");

    // Security headers
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    context.Response.Headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()";

    // Content Security Policy
    context.Response.Headers.Remove("Content-Security-Policy");
    context.Response.Headers["Content-Security-Policy"] = "default-src 'self'";
    await next();
});

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();


app.Run();
