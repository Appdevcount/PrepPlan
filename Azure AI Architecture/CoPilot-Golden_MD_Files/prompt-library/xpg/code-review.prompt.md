# AMS Controller Code Review Prompt

## Overview
This prompt is designed for conducting comprehensive code reviews of the AMS (Anti Malware System) Controller - an ASP.NET Core Web API application that handles file scanning, Kafka messaging, Azure Blob storage integration, and Application Insights telemetry.

## Architecture Context
The application follows a clean architecture pattern with:
- **Controllers**: API endpoints for file submission and health checks
- **Workers**: Business logic for processing anti-malware scanning operations
- **Models**: Data transfer objects and domain models for malware scanning
- **Interfaces**: Abstraction layer for dependency injection
- **External Dependencies**: Kafka messaging, Azure Blob Storage, Application Insights
- **Testing**: XUnit test coverage for all components

## Code Review Instructions

**IMPORTANT: Always ask the user first about the scope of review before proceeding.**

### Step 1: Review Scope Selection (Ask user to input 1 or 2) 
Please specify which type of code review you want:

1. **Changes Only Review**: Review only the changes between current branch and master/main branch
2. **Full Codebase Review**: Review all files in the entire repository

**User Input Required**: Type either "1" or "2" to indicate your preference.

### Step 2: Code Review Analysis

Based on the user's scope selection:

#### For Full Codebase Review:
- Analyze all C# source files (.cs) including:
  - Controllers (AmsPostController.cs)
  - Workers (AmsWorker.cs) 
  - Models (AMSModel.cs)
  - Interfaces (IAmsWorker.cs)
  - Startup configuration and Program.cs
- Review configuration files (appsettings.json, appsettings.Development.json, Dockerfile)
- Examine project structure and dependencies (.csproj, NuGet.Config)
- Validate Kubernetes manifests (deployment.yml, service.yml, ingress.yml, etc.)
- Check test coverage and test quality in XUnit.Evicore.AMSController project
- Review logging implementation and Application Insights integration
- Validate Kafka configuration and message handling
- Assess Azure Blob Storage integration
- Check security practices and input validation

#### For Changes Only Review:
Consider the following branch as default branch: "master"
- First, execute: `git diff origin/master..HEAD --name-only` to identify changed files
- Then execute: `git diff origin/master..HEAD` to get the actual changes
- Focus analysis only on the modified lines and affected components
- Consider impact on existing functionality, especially:
  - API contract changes
  - Configuration modifications
  - Dependency updates
  - Security implications
  - Performance impacts
  - Breaking changes

### Step 3: Review Focus Areas

#### ASP.NET Core Specific Review Points:
- **API Design**: RESTful principles, HTTP status codes, route patterns
- **Dependency Injection**: Proper service registration and lifetime management
- **Configuration**: Environment-specific settings, secrets management
- **Middleware**: Request pipeline configuration, error handling
- **Security**: Authentication, authorization, input validation, XSS prevention
- **Performance**: Async/await patterns, memory management, caching
- **Logging**: Structured logging, log levels, sensitive data handling

#### Architecture & Code Quality:
- **SOLID Principles**: Single responsibility, dependency inversion
- **Error Handling**: Exception management, user-friendly error responses
- **Testing**: Unit test coverage, integration tests, test quality
- **Documentation**: XML documentation, API documentation
- **Code Standards**: Naming conventions, code formatting, maintainability

#### Integration & External Dependencies:
- **Kafka Integration**: Message serialization, error handling, connection management
- **Azure Blob Storage**: Connection strings, retry policies, error handling
- **Application Insights**: Telemetry configuration, performance monitoring
- **Docker**: Dockerfile optimization, security practices

### Step 4: Security Review Checklist:
- Input validation and sanitization (especially file uploads)
- SQL injection prevention (if applicable)
- Cross-site scripting (XSS) protection
- Authentication and authorization mechanisms
- Secrets management (connection strings, API keys)
- HTTPS enforcement
- CORS configuration
- File upload security (size limits, file type validation)

### Step 5: Performance Review Checklist:
- Async/await usage for I/O operations
- Memory leaks and resource disposal
- Database query optimization (if applicable)
- Caching strategies
- API response time optimization
- File handling efficiency
- Connection pooling

**Output Format**
Provide your analysis in the following JSON structure:

```json
{
    "CodeReviewed": true,
    "SeverityDistribution": {
        "Critical": 0,
        "High": 0,
        "Medium": 0,
        "Low": 0
    },
    "SuggestedChanges": [
        {
            "FileName": "/evicore.AMSController/Controller/AmsPostController.cs",
            "LineNoStart": 45,
            "LineNoEnd": 49,
            "Severity": "High|Medium|Low|Critical",
            "Category": "Performance|Security|Code Quality|Error Handling|API Design|Testing|Configuration|Architecture|Documentation",
            "Issue": "Brief description of the identified issue",
            "Suggestion": "Detailed suggestion for improvement with code example if applicable",
            "Rationale": "Explanation of why this change is recommended and its impact"
        }
    ],
    "RecommendedActions": [
        "Immediate actions that should be taken before merging (Critical/High severity issues)",
        "Follow-up improvements for future iterations (Medium/Low severity issues)",
        "Architecture improvements for long-term maintainability",
        "Performance optimizations to consider",
        "Security enhancements to implement"
    ],
    "OverallAssessment": "Brief summary of the overall code quality, architecture adherence, security posture, and major findings. Include recommendations for the development team."
}
```

### JSON Format Requirements:
- Validate the JSON format for correctness
- Correct any structural issues
- Ensure FileName starts with '/' and includes the full relative path from project root
- Convert double quotes to single quotes in SuggestedChanges Issue, Suggestion, and Rationale fields only
- For LineNoStart and LineNoEnd, provide accurate and wider line number ranges that encompass the actual issues identified
- Ensure proper indentation is maintained in the JSON output
- Include specific line numbers based on actual file analysis

### Model Identification:
The ReviewedByModel field must accurately reflect the AI model being used for the code review. Common values include:
- "GPT-4"
- "GPT-4 Turbo" 
- "Claude Sonnet 3.5"
- "Claude Opus"
- "Gemini Pro"

**Important**: Always specify the exact model name as provided by the user or detected by the system.

### Quality Assurance:
Before providing the final JSON response:
1. Verify all file paths are accurate and exist in the repository
2. Ensure line numbers correspond to actual code locations
3. Validate that severity levels match the criticality of issues
4. Confirm all JSON syntax is valid
5. Check that recommendations are actionable and specific to the codebase