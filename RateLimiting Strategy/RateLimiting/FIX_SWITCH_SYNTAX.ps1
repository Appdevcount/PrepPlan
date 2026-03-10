# Fix switch expression in DistributedRateLimiterService.cs
$file = "Backend\CareCoordination.Api\RateLimiting\Core\DistributedRateLimiterService.cs"
$content = Get-Content $file -Raw

# Replace the problematic switch case with a simple await call
$oldPattern = @'
                    "concurrency" => await GetConcurrencyAllowedAsync\(key, maxRequests\),
'@

$newPattern = @'
                    "concurrency" => await CheckConcurrencyAsync(key, maxRequests),
'@

$content = $content -replace [regex]::Escape($oldPattern), $newPattern

# Now add the helper method right after the IsRequestAllowedAsync method closes
$insertPoint = "            }"  + "`r`n" + "        }"  + "`r`n" + "`r`n" + "        /// <summary>"
$helperMethod = @"
        private async Task<bool> CheckConcurrencyAsync(string key, int maxRequests)
        {
            var remaining = await _concurrencyLimiter.GetRemainingAsync(key, maxRequests);
            return remaining > 0;
        }

"@

if ($content -notmatch "CheckConcurrencyAsync") {
    $content = $content -replace ([regex]::Escape($insertPoint)), ($helperMethod + $insertPoint)
}

Set-Content $file -Value $content -NoNewline
Write-Host "Fixed switch expression syntax error" -ForegroundColor Green
