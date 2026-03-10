# PowerShell Script: Consolidate ALL Rate Limiting Files into API Project
# Location: Backend/CareCoordination.Api/RateLimiting/
# Run from: Backend directory

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host " CONSOLIDATE ALL RATE LIMITING FILES INTO API PROJECT" -ForegroundColor Cyan
Write-Host " Target: Backend/CareCoordination.Api/RateLimiting/" -ForegroundColor Cyan
Write-Host "================================================================`n" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$targetRoot = "CareCoordination.Api/RateLimiting"

# ============================================================
# STEP 1: CREATE FOLDER STRUCTURE
# ============================================================

Write-Host "Step 1: Creating folder structure..." -ForegroundColor Yellow

$folders = @(
    "$targetRoot",
    "$targetRoot/Core",
    "$targetRoot/Redis",
    "$targetRoot/Configuration",
    "$targetRoot/Examples",
    "$targetRoot/Documentation"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  ? Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "  ? Exists: $folder" -ForegroundColor Gray
    }
}

Write-Host ""

# ============================================================
# STEP 2: COPY/MOVE CODE FILES
# ============================================================

Write-Host "Step 2: Copying code files..." -ForegroundColor Yellow

$codeFiles = @{
    # Core Services
    "CareCoordination.Application/Abstracts/ServiceInterfaces/IDistributedRateLimiterService.cs" = "$targetRoot/Core/IDistributedRateLimiterService.cs"
    "CareCoordination.Services/Implementation/DistributedRateLimiterService.cs" = "$targetRoot/Core/DistributedRateLimiterService.cs"
    "CareCoordination.Api/Extensions/DistributedRateLimiterExtensions.cs" = "$targetRoot/Core/ServiceExtensions.cs"
    
    # Redis Limiters
    "CareCoordination.Services/RateLimiting/RedisFixedWindowRateLimiter.cs" = "$targetRoot/Redis/RedisFixedWindowRateLimiter.cs"
    "CareCoordination.Services/RateLimiting/RedisSlidingWindowRateLimiter.cs" = "$targetRoot/Redis/RedisSlidingWindowRateLimiter.cs"
    "CareCoordination.Services/RateLimiting/RedisTokenBucketRateLimiter.cs" = "$targetRoot/Redis/RedisTokenBucketRateLimiter.cs"
    "CareCoordination.Services/RateLimiting/RedisConcurrencyRateLimiter.cs" = "$targetRoot/Redis/RedisConcurrencyRateLimiter.cs"
    
    # Configuration
    "CareCoordination.Services/Models/RateLimiterConfig.cs" = "$targetRoot/Configuration/RateLimiterConfig.cs"
    
    # Examples
    "CareCoordination.Api/Controllers/RateLimitExampleController.cs" = "$targetRoot/Examples/RateLimitExampleController.cs"
}

$copiedCount = 0
$skippedCount = 0

foreach ($mapping in $codeFiles.GetEnumerator()) {
    $source = $mapping.Key
    $dest = $mapping.Value
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "  ? Copied: $(Split-Path $dest -Leaf)" -ForegroundColor Green
        Write-Host "    From: $source" -ForegroundColor Gray
        Write-Host "    To:   $dest" -ForegroundColor Gray
        $copiedCount++
    } else {
        Write-Host "  ? Not found: $source" -ForegroundColor Yellow
        $skippedCount++
    }
}

Write-Host ""

# ============================================================
# STEP 3: COPY DOCUMENTATION FILES
# ============================================================

Write-Host "Step 3: Copying documentation files..." -ForegroundColor Yellow

$docFiles = @{
    "DISTRIBUTED_RATE_LIMITING.md" = "$targetRoot/Documentation/IMPLEMENTATION_GUIDE.md"
    "CareCoordination.Services/DistributedRateLimiting/QUICK_REFERENCE.md" = "$targetRoot/Documentation/QUICK_REFERENCE.md"
}

$docCount = 0

foreach ($mapping in $docFiles.GetEnumerator()) {
    $source = $mapping.Key
    $dest = $mapping.Value
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "  ? Copied: $(Split-Path $dest -Leaf)" -ForegroundColor Green
        $docCount++
    } else {
        Write-Host "  ? Not found: $source" -ForegroundColor Yellow
    }
}

Write-Host ""

# ============================================================
# STEP 4: CREATE ADDITIONAL DOCUMENTATION
# ============================================================

Write-Host "Step 4: Creating additional documentation..." -ForegroundColor Yellow

# Create TROUBLESHOOTING.md
$troubleshootingContent = @"
# Troubleshooting Guide

## Common Issues

### 1. Redis Connection Failed
**Error**: "Failed to connect to Redis"

**Solutions**:
``````bash
# Test connection
redis-cli -h localhost -p 6379 ping

# Check firewall
# Check Redis is running
docker ps | grep redis
``````

### 2. Namespace Errors
**Error**: "Type or namespace name 'IDistributedRateLimiterService' could not be found"

**Solution**:
``````csharp
// Add to using statements:
using CareCoordination.Api.RateLimiting.Core;
``````

### 3. Rate Limit Not Working
**Check**:
1. Verify ``UseDistributedRateLimiting`` in appsettings.json
2. Check Redis keys: ``redis-cli keys "ratelimit:*"``
3. Enable logging in configuration

### 4. Concurrency Slots Not Released
**Solution**: Always use try-finally
``````csharp
var (acquired, requestId) = await _rateLimiter.AcquireAsync(...);
try {
    // work
} finally {
    await _rateLimiter.ReleaseAsync(key, requestId); // MUST call
}
``````

## Performance Issues

### High Latency
- Check Redis network latency
- Consider in-memory for internal endpoints
- Use connection pooling

### Memory Issues
- Reduce key TTL
- Use Fixed Window instead of Sliding Window
- Clean up old keys

## Configuration Issues

### Settings Not Applied
1. Check appsettings.json syntax
2. Verify environment-specific config
3. Restart application

### Redis Authentication
``````json
{
  "RedisConnectionString": "host:6380,password=key,ssl=true"
}
``````

## Getting Help
1. Check logs in Application Insights
2. Review Redis metrics
3. Test with simple Fixed Window first
"@

Set-Content -Path "$targetRoot/Documentation/TROUBLESHOOTING.md" -Value $troubleshootingContent
Write-Host "  ? Created: TROUBLESHOOTING.md" -ForegroundColor Green

# Create API_DOCUMENTATION.md
$apiDocContent = @"
# API Documentation

## IDistributedRateLimiterService

### Methods

#### IsRequestAllowedAsync
``````csharp
Task<bool> IsRequestAllowedAsync(
    string key, 
    string limiterType, 
    int maxRequests, 
    TimeSpan timeWindow)
``````

**Parameters**:
- ``key``: Unique identifier (e.g., "user:123", "ip:192.168.1.1")
- ``limiterType``: "FixedWindow", "SlidingWindow", "TokenBucket", "Concurrency"
- ``maxRequests``: Maximum requests allowed
- ``timeWindow``: Time window for the limit

**Returns**: ``true`` if request allowed, ``false`` if limit exceeded

---

#### GetRemainingRequestsAsync
``````csharp
Task<int> GetRemainingRequestsAsync(string key, string limiterType)
``````

**Returns**: Number of remaining requests allowed

---

#### GetRetryAfterSecondsAsync
``````csharp
Task<int> GetRetryAfterSecondsAsync(string key, string limiterType)
``````

**Returns**: Seconds until rate limit resets

---

#### ResetRateLimitAsync
``````csharp
Task ResetRateLimitAsync(string key, string limiterType)
``````

**Purpose**: Reset rate limit for debugging/admin purposes

---

#### AcquireConcurrencySlotAsync
``````csharp
Task<(bool acquired, string requestId)> AcquireConcurrencySlotAsync(
    string key, 
    int maxConcurrent, 
    int timeoutSeconds = 300)
``````

**Returns**: Tuple with acquisition status and request ID

---

#### ReleaseConcurrencySlotAsync
``````csharp
Task ReleaseConcurrencySlotAsync(string key, string requestId)
``````

**Critical**: Must be called in finally block

## Configuration

### RateLimiterConfig Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| UseDistributedRateLimiting | bool | false | Enable Redis-based limiting |
| RedisConnectionString | string | "" | Redis connection |
| RedisDatabase | int | 0 | Database number (0-15) |
| RedisKeyPrefix | string | "ratelimit:" | Key prefix |
| EnableFallbackToInMemory | bool | true | Fallback if Redis fails |
| LogRateLimitViolations | bool | true | Log violations |

## Rate Limiter Types

### FixedWindow
- Simple time-window based
- Resets completely after window
- Best for: Simple, predictable limits

### SlidingWindow
- Rolling time window
- Prevents boundary bursts
- Best for: Smooth, fair limiting

### TokenBucket
- Token-based with refills
- Allows short bursts
- Best for: Burst traffic handling

### Concurrency
- Limits simultaneous operations
- Not time-based
- Best for: Resource protection
"@

Set-Content -Path "$targetRoot/Documentation/API_DOCUMENTATION.md" -Value $apiDocContent
Write-Host "  ? Created: API_DOCUMENTATION.md" -ForegroundColor Green

Write-Host ""

# ============================================================
# STEP 5: CREATE INDEX FILE
# ============================================================

Write-Host "Step 5: Creating master index..." -ForegroundColor Yellow

$indexContent = @"
# Complete File Index

Location: ``Backend/CareCoordination.Api/RateLimiting/``

## Folder Structure

``````
RateLimiting/
??? START_HERE.md                          ? Begin here
??? INDEX.md                               ? This file
?
??? Core/                                  ? Core services
?   ??? IDistributedRateLimiterService.cs
?   ??? DistributedRateLimiterService.cs
?   ??? ServiceExtensions.cs
?
??? Redis/                                 ? Redis implementations
?   ??? RedisFixedWindowRateLimiter.cs
?   ??? RedisSlidingWindowRateLimiter.cs
?   ??? RedisTokenBucketRateLimiter.cs
?   ??? RedisConcurrencyRateLimiter.cs
?
??? Configuration/                         ? Config models
?   ??? RateLimiterConfig.cs
?
??? Examples/                              ? Working examples
?   ??? RateLimitExampleController.cs
?
??? Documentation/                         ? All guides
    ??? IMPLEMENTATION_GUIDE.md
    ??? QUICK_REFERENCE.md
    ??? TROUBLESHOOTING.md
    ??? API_DOCUMENTATION.md
``````

## Quick Navigation

| Want to... | Go to |
|------------|-------|
| Get started | START_HERE.md |
| See examples | Examples/RateLimitExampleController.cs |
| Quick patterns | Documentation/QUICK_REFERENCE.md |
| Full setup | Documentation/IMPLEMENTATION_GUIDE.md |
| Solve problems | Documentation/TROUBLESHOOTING.md |
| API reference | Documentation/API_DOCUMENTATION.md |

## File Descriptions

### Core/ (3 files)
- **IDistributedRateLimiterService.cs** - Service interface
- **DistributedRateLimiterService.cs** - Implementation with fallback
- **ServiceExtensions.cs** - DI registration methods

### Redis/ (4 files)
- **RedisFixedWindowRateLimiter.cs** - Time-window limiting
- **RedisSlidingWindowRateLimiter.cs** - Rolling window limiting
- **RedisTokenBucketRateLimiter.cs** - Burst handling
- **RedisConcurrencyRateLimiter.cs** - Concurrency control

### Configuration/ (1 file)
- **RateLimiterConfig.cs** - Strongly-typed settings

### Examples/ (1 file)
- **RateLimitExampleController.cs** - 8 working examples

### Documentation/ (4 files)
- **IMPLEMENTATION_GUIDE.md** - Complete setup guide
- **QUICK_REFERENCE.md** - Developer cheat sheet
- **TROUBLESHOOTING.md** - Problem solving
- **API_DOCUMENTATION.md** - Method reference

## Namespaces

All code uses namespace: ``CareCoordination.Api.RateLimiting.*``

- Core: ``CareCoordination.Api.RateLimiting.Core``
- Redis: ``CareCoordination.Api.RateLimiting.Redis``
- Configuration: ``CareCoordination.Api.RateLimiting.Configuration``

## Total Files

- Code files: 9
- Documentation: 5
- Total: 14 files

Everything in one place!
"@

Set-Content -Path "$targetRoot/INDEX.md" -Value $indexContent
Write-Host "  ? Created: INDEX.md" -ForegroundColor Green

Write-Host ""

# ============================================================
# SUMMARY
# ============================================================

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " CONSOLIDATION COMPLETE!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "?? Summary:" -ForegroundColor White
Write-Host "  Code files copied:   $copiedCount" -ForegroundColor Green
Write-Host "  Files skipped:       $skippedCount" -ForegroundColor Yellow
Write-Host "  Documentation:       $($docCount + 3)" -ForegroundColor Green
Write-Host "  Total files:         $(($copiedCount + $docCount + 3))" -ForegroundColor Green
Write-Host ""
Write-Host "?? Location:" -ForegroundColor White
Write-Host "  $targetRoot" -ForegroundColor Cyan
Write-Host ""
Write-Host "??  IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Update namespaces in all code files:" -ForegroundColor White
Write-Host "   namespace CareCoordination.Api.RateLimiting.Core" -ForegroundColor Gray
Write-Host "   namespace CareCoordination.Api.RateLimiting.Redis" -ForegroundColor Gray
Write-Host "   namespace CareCoordination.Api.RateLimiting.Configuration" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Update Program.cs:" -ForegroundColor White
Write-Host "   using CareCoordination.Api.RateLimiting.Core;" -ForegroundColor Gray
Write-Host "   builder.Services.AddDistributedRateLimiting(builder.Configuration);" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Update controller using statements:" -ForegroundColor White
Write-Host "   using CareCoordination.Api.RateLimiting.Core;" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Rebuild solution:" -ForegroundColor White
Write-Host "   Ctrl+Shift+B" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Delete old files after verification" -ForegroundColor White
Write-Host ""
Write-Host "?? Start here:" -ForegroundColor Cyan
Write-Host "   $targetRoot/START_HERE.md" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
