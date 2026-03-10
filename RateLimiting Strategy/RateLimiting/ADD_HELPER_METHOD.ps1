$file = "Backend\CareCoordination.Api\RateLimiting\Core\DistributedRateLimiterService.cs"
$lines = [System.IO.File]::ReadAllLines($file)

$helperMethod = @"

        private async Task<bool> GetConcurrencyAllowedAsync(string key, int maxRequests)
        {
            var remaining = await _concurrencyLimiter.GetRemainingAsync(key, maxRequests);
            return remaining > 0;
        }
"@

# Find the line with "throw; // Fail closed" and insert after the closing brace
$insertIndex = -1
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "throw; // Fail closed") {
        # Find the next two closing braces
        $braceCount = 0
        for ($j = $i; $j -lt $lines.Length; $j++) {
            if ($lines[$j] -match '^\s+\}$') {
                $braceCount++
                if ($braceCount -eq 2) {
                    $insertIndex = $j + 1
                    break
                }
            }
        }
        break
    }
}

if ($insertIndex -gt 0) {
    $newLines = @()
    $newLines += $lines[0..($insertIndex-1)]
    $newLines += ""
    $newLines += "        private async Task<bool> GetConcurrencyAllowedAsync(string key, int maxRequests)"
    $newLines += "        {"
    $newLines += "            var remaining = await _concurrencyLimiter.GetRemainingAsync(key, maxRequests);"
    $newLines += "            return remaining > 0;"
    $newLines += "        }"
    $newLines += $lines[$insertIndex..($lines.Length-1)]
    
    [System.IO.File]::WriteAllLines($file, $newLines)
    Write-Host "Helper method added successfully!" -ForegroundColor Green
} else {
    Write-Host "Could not find insertion point" -ForegroundColor Red
}
