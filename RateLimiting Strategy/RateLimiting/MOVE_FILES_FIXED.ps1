# Fixed PowerShell Script - Run from Solution Root
# This script handles the correct path structure

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host " CONSOLIDATE RATE LIMITING FILES - FIXED VERSION" -ForegroundColor Cyan
Write-Host "================================================================`n" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"

# Get current directory
$currentDir = Get-Location
Write-Host "Current directory: $currentDir`n" -ForegroundColor Gray

# Define paths
$targetRoot = "Backend\CareCoordination.Api\RateLimiting"

# ============================================================
# STEP 1: CREATE FOLDER STRUCTURE
# ============================================================

Write-Host "Step 1: Creating folder structure..." -ForegroundColor Yellow

$folders = @(
    "$targetRoot\Core",
    "$targetRoot\Redis",
    "$targetRoot\Configuration",
    "$targetRoot\Examples",
    "$targetRoot\Documentation"
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
# STEP 2: COPY CODE FILES
# ============================================================

Write-Host "Step 2: Copying code files..." -ForegroundColor Yellow

$codeFiles = @{
    # Core Services
    "Backend\CareCoordination.Application\Abstracts\ServiceInterfaces\IDistributedRateLimiterService.cs" = "$targetRoot\Core\IDistributedRateLimiterService.cs"
    "Backend\CareCoordination.Services\Implementation\DistributedRateLimiterService.cs" = "$targetRoot\Core\DistributedRateLimiterService.cs"
    "Backend\CareCoordination.Api\Extensions\DistributedRateLimiterExtensions.cs" = "$targetRoot\Core\ServiceExtensions.cs"
    
    # Redis Limiters
    "Backend\CareCoordination.Services\RateLimiting\RedisFixedWindowRateLimiter.cs" = "$targetRoot\Redis\RedisFixedWindowRateLimiter.cs"
    "Backend\CareCoordination.Services\RateLimiting\RedisSlidingWindowRateLimiter.cs" = "$targetRoot\Redis\RedisSlidingWindowRateLimiter.cs"
    "Backend\CareCoordination.Services\RateLimiting\RedisTokenBucketRateLimiter.cs" = "$targetRoot\Redis\RedisTokenBucketRateLimiter.cs"
    "Backend\CareCoordination.Services\RateLimiting\RedisConcurrencyRateLimiter.cs" = "$targetRoot\Redis\RedisConcurrencyRateLimiter.cs"
    
    # Configuration
    "Backend\CareCoordination.Services\Models\RateLimiterConfig.cs" = "$targetRoot\Configuration\RateLimiterConfig.cs"
    
    # Examples
    "Backend\CareCoordination.Api\Controllers\RateLimitExampleController.cs" = "$targetRoot\Examples\RateLimitExampleController.cs"
}

$copiedCount = 0
$skippedCount = 0

foreach ($mapping in $codeFiles.GetEnumerator()) {
    $source = $mapping.Key
    $dest = $mapping.Value
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "  ? Copied: $(Split-Path $source -Leaf)" -ForegroundColor Green
        Write-Host "    ? $dest" -ForegroundColor Gray
        $copiedCount++
    } else {
        Write-Host "  ? Not found: $source" -ForegroundColor Red
        $skippedCount++
    }
}

Write-Host ""

# ============================================================
# STEP 3: COPY DOCUMENTATION
# ============================================================

Write-Host "Step 3: Copying documentation..." -ForegroundColor Yellow

$docFiles = @{
    "Backend\DISTRIBUTED_RATE_LIMITING.md" = "$targetRoot\Documentation\IMPLEMENTATION_GUIDE.md"
}

$docCount = 0

foreach ($mapping in $docFiles.GetEnumerator()) {
    $source = $mapping.Key
    $dest = $mapping.Value
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "  ? Copied: $(Split-Path $dest -Leaf)" -ForegroundColor Green
        $docCount++
    }
}

Write-Host ""

# ============================================================
# SUMMARY
# ============================================================

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " SUMMARY" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Code files copied:   $copiedCount / 9" -ForegroundColor $(if ($copiedCount -eq 9) { "Green" } else { "Yellow" })
Write-Host "Files not found:     $skippedCount" -ForegroundColor $(if ($skippedCount -eq 0) { "Green" } else { "Red" })
Write-Host "Documentation:       $docCount" -ForegroundColor Green
Write-Host ""

if ($copiedCount -gt 0) {
    Write-Host "? Files copied to: $targetRoot" -ForegroundColor Green
    Write-Host ""
    Write-Host "?? NEXT STEPS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Update namespaces in copied files:" -ForegroundColor White
    Write-Host "   Core\*.cs       ? namespace CareCoordination.Api.RateLimiting.Core" -ForegroundColor Gray
    Write-Host "   Redis\*.cs      ? namespace CareCoordination.Api.RateLimiting.Redis" -ForegroundColor Gray
    Write-Host "   Configuration\* ? namespace CareCoordination.Api.RateLimiting.Configuration" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Update Program.cs:" -ForegroundColor White
    Write-Host "   using CareCoordination.Api.RateLimiting.Core;" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Rebuild solution (Ctrl+Shift+B)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "? No files were copied!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible issues:" -ForegroundColor Yellow
    Write-Host "1. Script not run from solution root directory" -ForegroundColor Gray
    Write-Host "2. Files have been moved/deleted" -ForegroundColor Gray
    Write-Host "3. Path structure is different" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Try running from solution root (where .sln file is located)" -ForegroundColor White
}

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
