# PowerShell script to update namespaces in consolidated rate limiting files
# Run this from the solution root directory

$ErrorActionPreference = "Stop"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " UPDATING NAMESPACES IN RATE LIMITING FILES" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "Backend\CareCoordination.Api\RateLimiting"

# Define namespace replacements
$namespaceReplacements = @(
    @{
        File = "$baseDir\Core\IDistributedRateLimiterService.cs"
        OldNamespace = "namespace CareCoordination.Application.Abstracts.ServiceInterfaces"
        NewNamespace = "namespace CareCoordination.Api.RateLimiting.Core"
    },
    @{
        File = "$baseDir\Core\DistributedRateLimiterService.cs"
        OldNamespace = "namespace CareCoordination.Services.Implementation"
        NewNamespace = "namespace CareCoordination.Api.RateLimiting.Core"
    },
    @{
        File = "$baseDir\Configuration\RateLimiterConfig.cs"
        OldNamespace = "namespace CareCoordination.Services.Models"
        NewNamespace = "namespace CareCoordination.Api.RateLimiting.Configuration"
    },
    @{
        File = "$baseDir\Configuration\DistributedRateLimiterExtensions.cs"
        OldNamespace = "namespace CareCoordination.Api.Extensions"
        NewNamespace = "namespace CareCoordination.Api.RateLimiting.Configuration"
    },
    @{
        File = "$baseDir\Examples\RateLimitExampleController.cs"
        OldNamespace = "namespace CareCoordination.Api.Controllers"
        NewNamespace = "namespace CareCoordination.Api.RateLimiting.Examples"
    }
)

# Update each file
foreach ($replacement in $namespaceReplacements) {
    $filePath = $replacement.File
    
    if (Test-Path $filePath) {
        Write-Host "Updating: $filePath" -ForegroundColor Yellow
        
        $content = Get-Content $filePath -Raw
        $content = $content.Replace($replacement.OldNamespace, $replacement.NewNamespace)
        
        # Also update using statements that reference old namespaces
        $content = $content.Replace("using CareCoordination.Application.Abstracts.ServiceInterfaces;", "using CareCoordination.Api.RateLimiting.Core;")
        $content = $content.Replace("using CareCoordination.Services.Implementation;", "using CareCoordination.Api.RateLimiting.Core;")
        $content = $content.Replace("using CareCoordination.Services.Models;", "using CareCoordination.Api.RateLimiting.Configuration;")
        $content = $content.Replace("using CareCoordination.Services.RateLimiting;", "using CareCoordination.Api.RateLimiting.Redis;")
        
        Set-Content $filePath -Value $content -NoNewline
        
        Write-Host "  [OK] Namespace updated" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] File not found: $filePath" -ForegroundColor Red
    }
}

# Update Redis limiter files
Write-Host ""
Write-Host "Updating Redis limiter files..." -ForegroundColor Yellow

$redisFiles = @(
    "$baseDir\Redis\RedisFixedWindowRateLimiter.cs",
    "$baseDir\Redis\RedisSlidingWindowRateLimiter.cs",
    "$baseDir\Redis\RedisTokenBucketRateLimiter.cs",
    "$baseDir\Redis\RedisConcurrencyRateLimiter.cs"
)

foreach ($file in $redisFiles) {
    if (Test-Path $file) {
        Write-Host "Updating: $file" -ForegroundColor Yellow
        
        $content = Get-Content $file -Raw
        $content = $content.Replace("namespace CareCoordination.Services.RateLimiting", "namespace CareCoordination.Api.RateLimiting.Redis")
        
        Set-Content $file -Value $content -NoNewline
        
        Write-Host "  [OK] Namespace updated" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " NAMESPACES UPDATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Update Program.cs using statements:" -ForegroundColor White
Write-Host "     using CareCoordination.Api.RateLimiting.Core;" -ForegroundColor Gray
Write-Host "     using CareCoordination.Api.RateLimiting.Configuration;" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Rebuild the solution" -ForegroundColor White
Write-Host ""
Write-Host "  3. (Optional) Delete old scattered files after verifying" -ForegroundColor White
Write-Host ""
