param (
    [Parameter(Mandatory=$true)]
    [string]$prUrl,

    [Parameter(Mandatory=$false)]
    [string]$personalAccessToken = "ADD YOUR PAT",

    [Parameter(Mandatory=$false)]
    [string]$commentsFilePath = "D:\PRAutomation\comments.json",

    [Parameter(Mandatory=$false)]
    [switch]$EnableDebug
)

# Suppress implicit Invoke-RestMethod verbose output unless -EnableDebug passed
if (-not $EnableDebug) {
    $VerbosePreference = 'SilentlyContinue'
    $PSDefaultParameterValues['Invoke-RestMethod:Verbose'] = $false
    $PSDefaultParameterValues['Invoke-WebRequest:Verbose'] = $false
} else {
    $VerbosePreference = 'Continue'
    Write-Verbose "Debug/Verbose mode enabled."
}

# Function to test PAT token validity
function Test-PATToken {
    param($token, $organization)
    
    try {
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($token)"))
        $headers = @{
            Authorization = "Basic $base64AuthInfo"
            "Content-Type" = "application/json"
        }
        
        $testUrl = "https://dev.azure.com/$organization/_apis/projects?api-version=7.1-preview.4"
        $response = Invoke-RestMethod -Uri $testUrl -Method Get -Headers $headers -ErrorAction Stop
        return @{
            Valid = $true
            Message = "PAT token is valid"
        }
    }
    catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        
        if ($statusCode -eq 401 -or $statusCode -eq 403) {
            return @{
                Valid = $false
                Message = "PAT token has expired or is invalid"
                StatusCode = $statusCode
            }
        }
        
        # For other errors, we'll assume the token might be valid but there's another issue
        return @{
            Valid = $true
            Message = "Unable to verify PAT token, but continuing: $($_.Exception.Message)"
            Warning = $true
        }
    }
}

# Enhanced function to validate PR with better error handling
function Test-PullRequestExists {
    param($organization, $project, $repositoryId, $pullRequestId, $headers)
    
    try {
        # First, let's try to get repository information
        $repoUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId?api-version=7.1-preview.1"
        #Write-Verbose "Testing repository access: $repoUrl"
        
        try {
            $repoResponse = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers $headers -ErrorAction Stop
            #Write-Host "✓ Repository '$repositoryId' found in project '$project'" -ForegroundColor Green
        }
        catch {
            #Write-Warning "Could not verify repository access, but continuing with PR validation..."
        }
        
        # Now test the PR
        $prUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId/pullRequests/$pullRequestId"
        #Write-Verbose "Testing PR access: $prUrl"
        
        $response = Invoke-RestMethod -Uri $prUrl -Method Get -Headers $headers #-ErrorAction Stop
        
        # Validate the response has required properties
        if (-not $response) {
            throw "Empty response received from PR API"
        }
        
        # Check if PR is in a valid state for commenting
        $validStatuses = @("active", "draft")
        if ($response.status -notin $validStatuses) {
            Write-Warning "PR status is '$($response.status)'. Comments can still be added but PR may be completed/abandoned."
        }
        
        return @{
            Exists = $true
            Valid = $true
            Status = $response.status
            Title = $response.title
            CreatedBy = if ($response.createdBy) { $response.createdBy.displayName } else { "Unknown" }
            Repository = if ($response.repository) { $response.repository.name } else { $repositoryId }
            Project = if ($response.repository -and $response.repository.project) { $response.repository.project.name } else { $project }
            SourceBranch = if ($response.sourceRefName) { $response.sourceRefName.Replace("refs/heads/", "") } else { "Unknown" }
            TargetBranch = if ($response.targetRefName) { $response.targetRefName.Replace("refs/heads/", "") } else { "Unknown" }
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        $statusCode = $null
        
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            
            # Try to get more detailed error information
            try {
                $errorStream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($errorStream)
                $responseBody = $reader.ReadToEnd()
                #Write-Verbose "Error response body: $responseBody"
            }
            catch {
                Write-Verbose "Could not read error response body"
            }
        }
        
        return @{
            Exists = $false
            Valid = $false
            Error = $errorMessage
            StatusCode = $statusCode
        }
    }
}

# Function to show user-friendly PR error message
function Show-PullRequestError {
    param($organization, $project, $repositoryId, $pullRequestId, $originalUrl, $errorInfo)
    
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                     PULL REQUEST VALIDATION FAILED              ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "❌ Issue: Unable to access or validate the pull request" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 Details:" -ForegroundColor Yellow
    Write-Host "   Organization: $organization" -ForegroundColor White
    Write-Host "   Project: $project" -ForegroundColor White
    Write-Host "   Repository: $repositoryId" -ForegroundColor White
    Write-Host "   PR ID: $pullRequestId" -ForegroundColor White
    Write-Host "   URL: $originalUrl" -ForegroundColor Gray
    
    if ($errorInfo.StatusCode) {
        Write-Host ""
        Write-Host "🔍 HTTP Status Code: $($errorInfo.StatusCode)" -ForegroundColor Yellow
        switch ($errorInfo.StatusCode) {
            401 { 
                Write-Host "   → Authentication failed - PAT token may be expired or invalid" -ForegroundColor White 
                Write-Host "   → Generate new token: https://dev.azure.com/$organization/_usersSettings/tokens" -ForegroundColor Cyan
            }
            403 { 
                Write-Host "   → Access denied - you may not have permission to view this PR/repository" -ForegroundColor White 
                Write-Host "   → Check if you have 'Read' permissions on the repository" -ForegroundColor Cyan
            }
            404 { 
                Write-Host "   → Resource not found - PR, repository, or project may not exist" -ForegroundColor White 
                Write-Host "   → Verify the PR ID and repository name are correct" -ForegroundColor Cyan  
            }
            default {
                Write-Host "   → Unexpected error occurred" -ForegroundColor White
            }
        }
    }
    
    #if ($errorInfo.Error) {
    #    Write-Host ""
    #    Write-Host "📝 Error Details:" -ForegroundColor Yellow
    #    Write-Host "   $($errorInfo.Error)" -ForegroundColor White
    #}
    
   #Write-Host ""
   #Write-Host "🔧 Troubleshooting Steps:" -ForegroundColor Green
   #Write-Host "   1. Copy the PR URL directly from Azure DevOps browser" -ForegroundColor White
   #Write-Host "   2. Verify you can access the PR in your browser" -ForegroundColor White
   #Write-Host "   3. Check your PAT token has not expired" -ForegroundColor White
   #Write-Host "   4. Ensure PAT token has 'Code (read)' permissions" -ForegroundColor White
   #Write-Host "   5. Verify the repository name matches exactly (case-sensitive)" -ForegroundColor White
   #Write-Host ""
}

# Function to display PR project information
function Show-PullRequestProjectInfo {
    param($prInfo)
    
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    PULL REQUEST VALIDATED                       ║" -ForegroundColor Green  
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "✅ Pull Request is Valid and Accessible!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Project Information:" -ForegroundColor Cyan
    Write-Host "   🎯 Target Project: $($prInfo.Repository)" -ForegroundColor Yellow -BackgroundColor DarkBlue
    #Write-Host "   📁 Azure DevOps Project: $($prInfo.Project)" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 PR Details:" -ForegroundColor Cyan  
    Write-Host "   📝 Title: $($prInfo.Title)" -ForegroundColor White
    Write-Host "   📊 Status: $($prInfo.Status)" -ForegroundColor $(if ($prInfo.Status -eq "active") { "Green" } else { "Yellow" })
    Write-Host "   👤 Created by: $($prInfo.CreatedBy)" -ForegroundColor White
    Write-Host "   🌿 Source Branch: $($prInfo.SourceBranch)" -ForegroundColor White
    Write-Host "   🎯 Target Branch: $($prInfo.TargetBranch)" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Comments will be applied to: $($prInfo.Repository) Project PR" -ForegroundColor White -BackgroundColor DarkGray
    Write-Host ""
}

# Function to create and display severity distribution table
function Show-SeverityDistributionTable {
    param($json)
    
    if (-not $json.SuggestedChanges) {
        Write-Error "Invalid JSON structure. Expected 'SuggestedChanges' property."
        return $null
    }
    
    # Calculate distribution
    $distribution = @{}
    foreach ($comment in $json.SuggestedChanges) {
        if ($comment.Severity) {
            if ($distribution.ContainsKey($comment.Severity)) {
                $distribution[$comment.Severity]++
            } else {
                $distribution[$comment.Severity] = 1
            }
        }
    }
    
    if ($distribution.Count -eq 0) {
        Write-Warning "No severity data found in comments."
        return $null
    }
    
    $totalComments = ($distribution.Values | Measure-Object -Sum).Sum
    
    # Create table data
    $tableData = @()
    $severityOrder = @("Critical", "High", "Medium", "Low")
    
    # Add standard severities first
    foreach ($severity in $severityOrder) {
        if ($distribution.ContainsKey($severity)) {
            $count = $distribution[$severity]
            $percentage = [math]::Round(($count / $totalComments) * 100, 1)
            $tableData += [PSCustomObject]@{
                Severity = $severity
                Count = $count
                Percentage = "$percentage%"
                'Progress Bar' = ('█' * [math]::Round($percentage / 5)) + ('░' * (20 - [math]::Round($percentage / 5)))
            }
        }
    }
    
    # Add any non-standard severities
    foreach ($severity in $distribution.Keys | Where-Object { $_ -notin $severityOrder }) {
        $count = $distribution[$severity]
        $percentage = [math]::Round(($count / $totalComments) * 100, 1)
        $tableData += [PSCustomObject]@{
            Severity = $severity
            Count = $count
            Percentage = "$percentage%"
            'Progress Bar' = ('█' * [math]::Round($percentage / 5)) + ('░' * (20 - [math]::Round($percentage / 5)))
        }
    }
    
    # Display the table
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    SEVERITY DISTRIBUTION TABLE                   ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Comments: $totalComments" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host ""
    
    # Custom table formatting with colors
    $headerFormat = "{0,-12} {1,-8} {2,-12} {3,-25}"
    $rowFormat = "{0,-12} {1,-8} {2,-12} {3,-25}"
    
    Write-Host ($headerFormat -f "SEVERITY", "COUNT", "PERCENTAGE", "VISUAL DISTRIBUTION") -ForegroundColor Yellow
    Write-Host ("─" * 65) -ForegroundColor Gray
    
    foreach ($row in $tableData) {
        $color = switch ($row.Severity) {
            "Critical" { "Magenta" }
            "High" { "Red" }
            "Medium" { "Yellow" }
            "Low" { "Green" }
            default { "White" }
        }
        
        Write-Host ($rowFormat -f $row.Severity, $row.Count, $row.Percentage, $row.'Progress Bar') -ForegroundColor $color
    }
    
    Write-Host ("─" * 65) -ForegroundColor Gray
    Write-Host ""
    
    return $distribution
}

# Enable verbose output for debugging
$VerbosePreference = "Continue"

Write-Host "🚀 Azure DevOps PR Comment Automation Script" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Parse the PR URL
if ($prUrl -match "https://dev\.azure\.com/([^/]+)/([^/]+)/_git/([^/]+)/pullrequest/(\d+)") {
    $organization = $matches[1]
    $project = $matches[2]
    $repositoryId = $matches[3]
    $pullRequestId = [int]$matches[4]
    
    #    Write-Host "`n✓ PR URL parsed successfully" -ForegroundColor Green
    Write-Host "  Organization: $organization" -ForegroundColor Gray
    Write-Host "  Azure DevOps Project: $project" -ForegroundColor Gray
    #Write-Host "  Repository/Project: $repositoryId" -ForegroundColor Gray
    Write-Host "  PR ID: $pullRequestId" -ForegroundColor Gray
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                      INVALID PR URL FORMAT                      ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "❌ Error: The provided PR URL format is invalid." -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Expected format:" -ForegroundColor Yellow
    Write-Host "   https://dev.azure.com/[organization]/[project]/_git/[repository]/pullrequest/[id]" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Your URL:" -ForegroundColor Yellow
    Write-Host "   $prUrl" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Example of correct URL:" -ForegroundColor Cyan
    Write-Host "   https://dev.azure.com/eviCoreDev/XPlatform/_git/Ruleset.UCT.Adapter.Consumer/pullrequest/142688" -ForegroundColor Green
    exit 1
}

# Test PAT token validity
#Write-Host "`n🔐 Validating Personal Access Token..." -ForegroundColor Cyan
$tokenValidation = Test-PATToken -token $personalAccessToken -organization $organization

if (-not $tokenValidation.Valid) {
    Write-Host "❌ $($tokenValidation.Message)" -ForegroundColor Red
    if ($tokenValidation.StatusCode) {
        Write-Host "   Status Code: $($tokenValidation.StatusCode)" -ForegroundColor Yellow
    }
    Write-Host "   Generate new token: https://dev.azure.com/$organization/_usersSettings/tokens" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ $($tokenValidation.Message)" -ForegroundColor Green
if ($tokenValidation.Warning) {
    Write-Host "⚠️  Warning: $($tokenValidation.Message)" -ForegroundColor Yellow
}

# Encode PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))
$headers = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

# Test if PR exists and is accessible with enhanced validation
#Write-Host "`n🔍 Validating Pull Request..." -ForegroundColor Cyan
#Write-Host "   Testing access to: https://dev.azure.com/$organization/$project/_git/$repositoryId/pullrequest/$pullRequestId" -ForegroundColor Gray

$prValidation = Test-PullRequestExists -organization $organization -project $project -repositoryId $repositoryId -pullRequestId $pullRequestId -headers $headers

if (-not $prValidation.Valid) {
    Show-PullRequestError -organization $organization -project $project -repositoryId $repositoryId -pullRequestId $pullRequestId -originalUrl $prUrl -errorInfo $prValidation
    
    # Ask user if they want to continue anyway (for debugging)
    Write-Host ""
    $continueAnyway = Read-Host "🤔 Do you want to try continuing anyway? This might help identify the exact issue (Y/N)"
    if ($continueAnyway -notmatch '^[Yy]$') {
        exit 1
    }
    Write-Host "⚠️  Continuing with potentially invalid PR..." -ForegroundColor Yellow
} else {
    # Display project information prominently
    Show-PullRequestProjectInfo -prInfo $prValidation
}

# Load comments from the specified file path
Write-Host "📄 Loading comments from: $commentsFilePath" -ForegroundColor Cyan
if (-Not (Test-Path $commentsFilePath)) {
    Write-Error "comments.json file not found at path: $commentsFilePath"
    exit 1
}

$json = Get-Content -Raw -Path $commentsFilePath | ConvertFrom-Json

# Display severity distribution in tabular format
$severityDistribution = Show-SeverityDistributionTable -json $json

if (-not $severityDistribution) {
    Write-Error "Unable to process severity distribution. Exiting."
    exit 1
}

# Prompt user for severity level
Write-Host "Select the severity level of comments to apply:" -ForegroundColor Cyan
Write-Host "1. All (Apply all comments)" -ForegroundColor Yellow
Write-Host "2. Critical (Apply only Critical severity comments)" -ForegroundColor Magenta
Write-Host "3. High (Apply only High severity comments)" -ForegroundColor Red
Write-Host "4. Medium (Apply only Medium severity comments)" -ForegroundColor Yellow
Write-Host "5. Low (Apply only Low severity comments)" -ForegroundColor Green

do {
    $choice = Read-Host "Enter your choice (1-5)"
    switch ($choice) {
        "1" { $filterSeverity = "All"; break }
        "2" { $filterSeverity = "Critical"; break }
        "3" { $filterSeverity = "High"; break }
        "4" { $filterSeverity = "Medium"; break }
        "5" { $filterSeverity = "Low"; break }
        default { 
            Write-Host "Invalid choice. Please enter 1, 2, 3, 4, or 5." -ForegroundColor Red
            $filterSeverity = $null
        }
    }
} while ($null -eq $filterSeverity)

Write-Host "`n🎯 Selected severity filter: $filterSeverity for $repositoryId Project" -ForegroundColor Green -BackgroundColor DarkBlue

# Count total comments and filtered comments for user feedback
$totalComments = $json.SuggestedChanges.Count
$filteredComments = if ($filterSeverity -eq "All") { 
    $totalComments 
} else { 
    ($json.SuggestedChanges | Where-Object { $_.Severity -eq $filterSeverity }).Count 
}

Write-Host "Total comments available: $totalComments" -ForegroundColor Cyan
Write-Host "Comments to be applied with '$filterSeverity' filter: $filteredComments" -ForegroundColor Cyan

if ($filteredComments -eq 0) {
    Write-Host "No comments match the selected severity level. Exiting." -ForegroundColor Yellow
    Write-Host "Total PR comments added: 0" -ForegroundColor Magenta
    exit 0
}

# Confirm with user before proceeding
Write-Host ""
Write-Host "🚀 Ready to apply $filteredComments comment(s) to $repositoryId Project PR #$pullRequestId" -ForegroundColor Magenta
$confirmation = Read-Host "Do you want to proceed? (Y/N)"
if ($confirmation -notmatch '^[Yy]$') {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    Write-Host "Total PR comments added: 0" -ForegroundColor Magenta
    exit 0
}

# Initialize counters
$commentCount = 0
$successfulComments = 0
$failedComments = 0

Write-Host "`n🔄 Starting to apply comments to $repositoryId Project..." -ForegroundColor Cyan

# Post each comment to the PR
foreach ($comment in $json.SuggestedChanges) {
    if ($filterSeverity -ne "All" -and $comment.Severity -ne $filterSeverity) {
        continue
    }

    $commentCount++
    $body = @{
        comments = @(@{
            parentCommentId = 0
            content = @"
**Severity**: $($comment.Severity)

**Category**: $($comment.Category)

**Issue**: $($comment.Issue)

**Suggestion**: $($comment.Suggestion)

**Rationale**: $($comment.Rationale)
"@
            commentType = "text"
        })
        status = "active"
        threadContext = @{
            filePath = $comment.FileName
            rightFileStart = @{
                line = $comment.LineNoStart
                offset = 1
            }
            rightFileEnd = @{
                line = $comment.LineNoEnd
                offset = 1
            }
        }
    } | ConvertTo-Json -Depth 10

    $url = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId/pullRequests/$pullRequestId/threads?api-version=7.1-preview.1"

    Write-Host "[$commentCount/$filteredComments] Posting comment to $($comment.FileName) at line $($comment.LineNoStart)..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ErrorAction Stop
        Write-Host "✓ Comment posted with ID: $($response.id)" -ForegroundColor Green
        $successfulComments++
    } catch {
        $errorMessage = $_.Exception.Message
        $statusCode = $null
        
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        
        Write-Host "✗ Failed to post comment (Status: $statusCode): $errorMessage" -ForegroundColor Red
        $failedComments++
        
        # Check for specific errors that indicate PR issues
        if ($errorMessage -like "*TF401180*" -or $errorMessage -like "*pull request*not found*" -or $statusCode -eq 404) {
            Write-Host "❌ PR-related error detected. This confirms the PR validation issue." -ForegroundColor Red
            Write-Host "   Consider checking the PR URL manually in Azure DevOps." -ForegroundColor Yellow
        }
    }
}

# Turn off verbose output for clean summary
$VerbosePreference = "SilentlyContinue"

# Print summary at the end
Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                           SUMMARY                               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Project: $repositoryId" -ForegroundColor Yellow
Write-Host "📝 Total PR comments added: $successfulComments" -ForegroundColor Green
if ($failedComments -gt 0) {
    Write-Host "❌ Failed to add: $failedComments comments" -ForegroundColor Red
}
Write-Host "🔍 Severity filter applied: $filterSeverity" -ForegroundColor Cyan
Write-Host "🔗 PR URL: $prUrl" -ForegroundColor Gray
Write-Host ""

if ($failedComments -gt 0) {
    Write-Host "💡 If you're seeing failures for a valid PR, consider:" -ForegroundColor Yellow
    Write-Host "   1. Checking your PAT token permissions (Code: Read & Write)" -ForegroundColor White
    Write-Host "   2. Verifying you can manually comment on this PR in Azure DevOps" -ForegroundColor White
    Write-Host "   3. Ensuring the PR is in 'Active' status" -ForegroundColor White
}
# https://evicorehealthcare.atlassian.net/wiki/spaces/XG/pages/2894430235/XPG+-+PR+-+Code+Review+Comments+Automation