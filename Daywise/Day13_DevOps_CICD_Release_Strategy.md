# Day 13: DevOps, CI/CD & Release Strategy

## Overview
Master modern DevOps practices, CI/CD pipelines, deployment strategies, and release management patterns essential for senior engineering roles. This guide focuses on decision-making frameworks and trade-offs that tech leads and architects must understand.

---

## 1. CI/CD Pipeline Stages

### The Complete Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        CI/CD PIPELINE                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [Code Push] → [Build] → [Test] → [Scan] → [Package] → [Deploy]│
│                   ↓        ↓        ↓         ↓          ↓      │
│                 Compile  Unit    Security   Artifact   Staging   │
│                 Restore  Integr  Quality    Registry   Prod     │
│                          E2E     Gates                          │
└──────────────────────────────────────────────────────────────────┘
```

**Architect's Decision Framework:**
- **Pipeline as Code**: Store pipeline definitions in source control (YAML, not UI clicks)
- **Fast feedback**: Fail fast - run fastest tests first
- **Parallelization**: Run independent stages in parallel to reduce total time
- **Artifacts once**: Build once, deploy many times (immutable artifacts)

### Stage 1: Build & Compile

```yaml
# Azure DevOps YAML Pipeline Example
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    exclude:
    - docs/*
    - README.md

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  dotnetVersion: '8.0.x'

stages:
- stage: Build
  displayName: 'Build and Compile'
  jobs:
  - job: BuildJob
    displayName: 'Build Application'
    steps:

    # Cache NuGet packages for faster builds
    - task: Cache@2
      inputs:
        key: 'nuget | "$(Agent.OS)" | **/packages.lock.json'
        path: $(Pipeline.Workspace)/.nuget/packages
        restoreKeys: |
          nuget | "$(Agent.OS)"
      displayName: 'Cache NuGet packages'

    # Install .NET SDK
    - task: UseDotNetCore@2
      inputs:
        version: $(dotnetVersion)
      displayName: 'Use .NET SDK $(dotnetVersion)'

    # Restore dependencies
    - script: dotnet restore --locked-mode
      displayName: 'Restore NuGet packages'

    # Build solution
    - script: dotnet build
        --configuration $(buildConfiguration)
        --no-restore
        /p:TreatWarningsAsErrors=true
      displayName: 'Build solution'

    # Publish application
    - script: dotnet publish
        --configuration $(buildConfiguration)
        --output $(Build.ArtifactStagingDirectory)
        --no-build
      displayName: 'Publish application'

    # Publish build artifacts
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'drop'
      displayName: 'Publish artifacts'
```

**Tech Lead Best Practices:**
- **Deterministic builds**: Lock package versions (packages.lock.json)
- **Treat warnings as errors**: Enforce code quality early
- **Build once principle**: Same artifact deployed to all environments
- **Caching strategy**: Cache dependencies to speed up builds (5-10x faster)

### Stage 2: Automated Testing

```yaml
- stage: Test
  displayName: 'Automated Testing'
  dependsOn: Build
  jobs:

  # Unit Tests (Fast - 30 seconds)
  - job: UnitTests
    displayName: 'Unit Tests'
    steps:
    - task: DotNetCoreCLI@2
      inputs:
        command: 'test'
        projects: '**/*UnitTests.csproj'
        arguments: >
          --configuration $(buildConfiguration)
          --no-build
          --logger trx
          --collect:"XPlat Code Coverage"
          -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=opencover
      displayName: 'Run unit tests'

    # Publish test results
    - task: PublishTestResults@2
      inputs:
        testResultsFormat: 'VSTest'
        testResultsFiles: '**/*.trx'
        failTaskOnFailedTests: true
      displayName: 'Publish test results'

    # Publish code coverage
    - task: PublishCodeCoverageResults@1
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'
      displayName: 'Publish code coverage'

  # Integration Tests (Medium - 2-3 minutes)
  - job: IntegrationTests
    displayName: 'Integration Tests'
    dependsOn: UnitTests
    steps:
    - script: |
        docker-compose -f docker-compose.test.yml up -d
        dotnet test **/*IntegrationTests.csproj --no-build
        docker-compose -f docker-compose.test.yml down
      displayName: 'Run integration tests with Docker'

  # E2E Tests (Slow - 5-10 minutes, run in parallel)
  - job: E2ETests
    displayName: 'E2E Tests'
    dependsOn: UnitTests
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    steps:
    - script: |
        # Deploy to ephemeral test environment
        az containerapp up --name test-$(Build.BuildId)

        # Run Playwright E2E tests
        npx playwright test --reporter=junit

        # Cleanup
        az containerapp delete --name test-$(Build.BuildId) --yes
      displayName: 'Run E2E tests'
```

**Architect's Testing Strategy:**
- **Test pyramid**: 70% unit, 20% integration, 10% E2E
- **Fast feedback loop**: Unit tests complete in <1 minute
- **Parallel execution**: Run test suites in parallel
- **Ephemeral environments**: Spin up test infrastructure, tear down after
- **Skip E2E on PRs**: Only run full suite on main branch (too slow for dev loop)

### Stage 3: Security & Quality Gates

```yaml
- stage: SecurityAndQuality
  displayName: 'Security Scanning & Quality Gates'
  dependsOn: Test
  jobs:

  # Static Code Analysis
  - job: CodeAnalysis
    displayName: 'Static Code Analysis'
    steps:
    - task: SonarCloudPrepare@1
      inputs:
        SonarCloud: 'SonarCloud'
        organization: 'your-org'
        scannerMode: 'MSBuild'
        projectKey: 'your-project'

    - script: dotnet build
      displayName: 'Build for analysis'

    - task: SonarCloudAnalyze@1
      displayName: 'Run code analysis'

    - task: SonarCloudPublish@1
      inputs:
        pollingTimeoutSec: '300'
      displayName: 'Publish quality gate results'

  # Security Scanning
  - job: SecurityScan
    displayName: 'Security Vulnerability Scan'
    steps:
    # Dependency scanning
    - script: |
        dotnet list package --vulnerable --include-transitive
      displayName: 'Check for vulnerable packages'

    # Container scanning (if using Docker)
    - task: AzureContainerRegistry@0
      inputs:
        command: 'scan'
        imageName: '$(containerRegistry)/$(imageName):$(Build.BuildId)'
      displayName: 'Scan container for vulnerabilities'

    # Secret scanning
    - script: |
        # Use tools like GitGuardian, TruffleHog
        docker run --rm -v $(Build.SourcesDirectory):/code \
          trufflesecurity/trufflehog:latest filesystem /code \
          --json --fail
      displayName: 'Scan for secrets in code'

  # Quality Gate Check
  - job: QualityGate
    displayName: 'Quality Gate Enforcement'
    dependsOn:
    - CodeAnalysis
    - SecurityScan
    steps:
    - script: |
        # Custom quality gate logic
        COVERAGE=$(cat coverage.json | jq '.coverage')
        if (( $(echo "$COVERAGE < 80" | bc -l) )); then
          echo "Code coverage $COVERAGE% is below 80% threshold"
          exit 1
        fi

        # Check for critical security issues
        CRITICAL_ISSUES=$(cat security-report.json | jq '.critical')
        if [ "$CRITICAL_ISSUES" -gt 0 ]; then
          echo "Found $CRITICAL_ISSUES critical security issues"
          exit 1
        fi
      displayName: 'Enforce quality gates'
```

**Tech Lead Quality Gate Strategy:**

| Metric | Threshold | Action on Failure |
|--------|-----------|-------------------|
| Code Coverage | > 80% | Block merge |
| Critical Bugs | 0 | Block merge |
| Code Smells | < 10 per 1000 LOC | Warning only |
| Security Vulnerabilities (Critical/High) | 0 | Block deployment |
| Build Time | < 10 minutes | Optimize pipeline |
| Test Pass Rate | 100% | Block merge |

**Decision Trade-offs:**
- **Strict vs Flexible gates**: Strict gates improve quality but can slow velocity
- **Coverage targets**: 80% is reasonable, 100% is diminishing returns
- **Security posture**: Zero critical vulnerabilities (non-negotiable), low/medium can be triaged

### React/Frontend Pipeline Integration

**Full Stack Pipeline Architecture:**

```
┌────────────────────────────────────────────────────────────────────┐
│                   FULL STACK CI/CD PIPELINE                        │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────┐          ┌─────────────────┐                 │
│  │ Backend (.NET)  │          │ Frontend (React)│                 │
│  └────────┬────────┘          └────────┬────────┘                 │
│           │                             │                          │
│           ├─ Build (dotnet)             ├─ Build (npm/vite)        │
│           ├─ Unit Tests                 ├─ Unit Tests (Jest)       │
│           ├─ Integration Tests          ├─ Component Tests (RTL)   │
│           ├─ Dependency Scan            ├─ Dependency Scan (npm)   │
│           ├─ SonarQube                  ├─ ESLint + TypeScript     │
│           ├─ Publish API                ├─ Build Production        │
│           │                             │                          │
│           └──────────┬──────────────────┘                          │
│                      │                                             │
│                      ├─ E2E Tests (Playwright) - Full Stack        │
│                      ├─ Security Scan (OWASP ZAP)                  │
│                      ├─ Deploy to Staging                          │
│                      └─ Deploy to Production                       │
└────────────────────────────────────────────────────────────────────┘
```

**React Build Pipeline (Azure DevOps):**

```yaml
# Frontend pipeline: react-app-pipeline.yml
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    include:
    - frontend/**

pool:
  vmImage: 'ubuntu-latest'

variables:
  nodeVersion: '20.x'
  workingDirectory: 'frontend'

stages:
- stage: BuildFrontend
  displayName: 'Build React App'
  jobs:
  - job: BuildJob
    displayName: 'Build and Test'
    steps:

    # Install Node.js
    - task: NodeTool@0
      inputs:
        versionSpec: $(nodeVersion)
      displayName: 'Install Node.js $(nodeVersion)'

    # Cache node_modules for faster builds
    - task: Cache@2
      inputs:
        key: 'npm | "$(Agent.OS)" | $(workingDirectory)/package-lock.json'
        path: $(workingDirectory)/node_modules
        restoreKeys: |
          npm | "$(Agent.OS)"
      displayName: 'Cache node_modules'

    # Install dependencies
    - script: |
        cd $(workingDirectory)
        npm ci  # Use ci instead of install for deterministic builds
      displayName: 'npm ci'

    # Lint code
    - script: |
        cd $(workingDirectory)
        npm run lint
      displayName: 'Run ESLint'

    # TypeScript type checking
    - script: |
        cd $(workingDirectory)
        npm run type-check || tsc --noEmit
      displayName: 'TypeScript type check'

    # Run unit and component tests
    - script: |
        cd $(workingDirectory)
        npm run test:ci -- --coverage --watchAll=false
      displayName: 'Run Jest tests'
      env:
        CI: true

    # Publish test results
    - task: PublishTestResults@2
      condition: succeededOrFailed()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '$(workingDirectory)/test-results/junit.xml'
        failTaskOnFailedTests: true
      displayName: 'Publish test results'

    # Publish code coverage
    - task: PublishCodeCoverageResults@1
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(workingDirectory)/coverage/cobertura-coverage.xml'
        reportDirectory: '$(workingDirectory)/coverage'
      displayName: 'Publish code coverage'

    # Security audit
    - script: |
        cd $(workingDirectory)
        npm audit --audit-level=high
      displayName: 'npm security audit'
      continueOnError: true  # Warning only, don't block build

    # Build production bundle
    - script: |
        cd $(workingDirectory)
        npm run build
      displayName: 'Build production bundle'
      env:
        REACT_APP_API_URL: $(apiUrl)
        REACT_APP_ENV: production
        GENERATE_SOURCEMAP: false  # Don't expose source code

    # Analyze bundle size
    - script: |
        cd $(workingDirectory)
        npm run analyze || echo "Bundle analysis skipped"
      displayName: 'Analyze bundle size'
      continueOnError: true

    # Publish build artifacts
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: '$(workingDirectory)/build'
        artifactName: 'react-app'
      displayName: 'Publish React build artifacts'

    # Optional: Publish build stats for monitoring
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: '$(workingDirectory)/build-stats.json'
        artifactName: 'build-stats'
      condition: and(succeeded(), ne(variables['Build.Reason'], 'PullRequest'))
      displayName: 'Publish build stats'
```

**Package.json scripts for CI:**

```json
{
  "scripts": {
    "build": "vite build",
    "test": "vitest",
    "test:ci": "vitest run --reporter=junit --reporter=default --outputFile=test-results/junit.xml",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint . --ext .ts,.tsx --max-warnings 0",
    "type-check": "tsc --noEmit",
    "analyze": "vite-bundle-visualizer"
  },
  "devDependencies": {
    "@vitest/coverage-v8": "^1.0.0",
    "vite-bundle-visualizer": "^1.0.0"
  }
}
```

**GitHub Actions for React (Alternative):**

```yaml
# .github/workflows/react-app.yml
name: React App CI/CD

on:
  push:
    branches: [main, develop]
    paths:
      - 'frontend/**'
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend

    steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
        cache-dependency-path: frontend/package-lock.json

    - name: Install dependencies
      run: npm ci

    - name: Lint
      run: npm run lint

    - name: Type check
      run: npm run type-check

    - name: Run tests
      run: npm run test:ci

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./frontend/coverage/cobertura-coverage.xml
        flags: frontend

    - name: Security audit
      run: npm audit --audit-level=high
      continue-on-error: true

    - name: Build
      run: npm run build
      env:
        VITE_API_URL: ${{ secrets.API_URL }}
        VITE_APP_ENV: production

    - name: Upload build artifacts
      uses: actions/upload-artifact@v4
      with:
        name: react-build
        path: frontend/build
        retention-days: 7

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Download build artifacts
      uses: actions/download-artifact@v4
      with:
        name: react-build
        path: frontend/build

    - name: Deploy to Azure Static Web Apps
      uses: Azure/static-web-apps-deploy@v1
      with:
        azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
        repo_token: ${{ secrets.GITHUB_TOKEN }}
        action: 'upload'
        app_location: 'frontend/build'
        skip_app_build: true
```

**Environment Variables Management for React:**

```yaml
# Variable groups in Azure DevOps
variables:
  # Development
  - group: react-app-dev
    variables:
      apiUrl: 'https://dev-api.example.com'
      appInsightsKey: '$(devAppInsightsKey)'

  # Production
  - group: react-app-prod
    variables:
      apiUrl: 'https://api.example.com'
      appInsightsKey: '$(prodAppInsightsKey)'

# Build with environment-specific variables
- script: |
    cd $(workingDirectory)
    echo "VITE_API_URL=$(apiUrl)" > .env.production
    echo "VITE_APP_INSIGHTS_KEY=$(appInsightsKey)" >> .env.production
    npm run build
  displayName: 'Build with environment variables'
```

**React-specific Quality Gates:**

```yaml
- stage: FrontendQualityGates
  displayName: 'Frontend Quality Gates'
  dependsOn: BuildFrontend
  jobs:
  - job: EnforceQuality
    steps:
    - script: |
        # Bundle size check (fail if main bundle > 500KB)
        BUNDLE_SIZE=$(du -k $(workingDirectory)/build/static/js/main.*.js | cut -f1)
        if [ $BUNDLE_SIZE -gt 500 ]; then
          echo "Bundle size ${BUNDLE_SIZE}KB exceeds 500KB limit"
          exit 1
        fi

        # Test coverage check (fail if < 70%)
        COVERAGE=$(jq '.total.lines.pct' $(workingDirectory)/coverage/coverage-summary.json)
        if (( $(echo "$COVERAGE < 70" | bc -l) )); then
          echo "Test coverage $COVERAGE% is below 70% threshold"
          exit 1
        fi

        # TypeScript errors (fail if any errors)
        npm run type-check

        # Lint warnings (fail if > 0 warnings)
        npm run lint -- --max-warnings 0
      displayName: 'Enforce frontend quality gates'
```

**Full Stack E2E Pipeline:**

```yaml
- stage: E2E
  displayName: 'End-to-End Tests'
  dependsOn:
  - BuildBackend
  - BuildFrontend
  jobs:
  - job: PlaywrightTests
    displayName: 'Playwright E2E Tests'
    steps:
    # Download both backend and frontend artifacts
    - task: DownloadBuildArtifacts@1
      inputs:
        artifactName: 'backend-api'
        downloadPath: '$(System.ArtifactsDirectory)'

    - task: DownloadBuildArtifacts@1
      inputs:
        artifactName: 'react-app'
        downloadPath: '$(System.ArtifactsDirectory)'

    # Start backend API
    - script: |
        cd $(System.ArtifactsDirectory)/backend-api
        dotnet MyApi.dll &
        sleep 5  # Wait for API to start
      displayName: 'Start backend API'

    # Serve frontend build
    - script: |
        npm install -g serve
        serve -s $(System.ArtifactsDirectory)/react-app -p 3000 &
        sleep 3
      displayName: 'Serve React app'

    # Install Playwright
    - script: |
        npx playwright install --with-deps chromium
      displayName: 'Install Playwright'

    # Run E2E tests
    - script: |
        npx playwright test --reporter=junit
      displayName: 'Run Playwright tests'
      env:
        BASE_URL: http://localhost:3000
        API_URL: http://localhost:5000

    # Publish E2E test results
    - task: PublishTestResults@2
      condition: succeededOrFailed()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/test-results/junit.xml'
        failTaskOnFailedTests: true
      displayName: 'Publish E2E test results'
```

**Tech Lead Decision Matrix for Frontend Pipelines:**

| Scenario | Build Tool | CI/CD Platform | Deployment Target |
|----------|------------|----------------|-------------------|
| **React + .NET API** | Vite | Azure DevOps | Azure Static Web Apps + App Service |
| **React (CDN only)** | Vite | GitHub Actions | Azure Static Web Apps / Cloudflare Pages |
| **Enterprise monorepo** | Nx/Turbo | Azure DevOps | AKS (Backend) + Static Web Apps (Frontend) |
| **Micro-frontends** | Module Federation | Azure DevOps | Azure Container Apps (each MFE) |

**Interview Talking Points:**
- "We build backend and frontend in parallel to optimize CI/CD time"
- "Frontend artifacts are immutable - built once, deployed to dev → staging → prod"
- "We enforce bundle size limits (< 500KB main bundle) in quality gates"
- "Environment variables are injected at build time, not runtime, for SPAs"
- "E2E tests run after both backend and frontend builds complete"
- "We use npm ci instead of npm install for deterministic, reproducible builds"

---

## 2. Code Coverage Strategy

### The Coverage Debate

**Architect's Reality Check:**
- **Coverage ≠ Quality**: 100% coverage doesn't mean bug-free code
- **Useful metric**: Identifies untested code, tracks trends
- **Don't game it**: Tests that just hit lines without assertions are useless
- **Focus on critical paths**: Payment, authentication, data loss scenarios need 100%

### Coverage Targets by Code Type

```csharp
// Domain Logic - Target: 90-100% coverage
public class OrderCalculator
{
    public decimal CalculateTotal(Order order, Discount discount)
    {
        // Critical business logic - must be tested thoroughly
        var subtotal = order.Items.Sum(i => i.Price * i.Quantity);
        var discountAmount = discount.Calculate(subtotal);
        var tax = (subtotal - discountAmount) * order.TaxRate;
        return subtotal - discountAmount + tax;
    }
}

// Infrastructure Code - Target: 60-70% coverage
public class OrderRepository
{
    // CRUD operations - integration tests preferred
    public async Task<Order> GetByIdAsync(Guid id)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id);
    }
}

// Controllers/API Layer - Target: 70-80% coverage
[ApiController]
public class OrdersController : ControllerBase
{
    // Test happy path + common error cases
    [HttpPost]
    public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
    {
        var order = await _service.CreateOrderAsync(dto);
        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
    }
}
```

**Coverage Strategy Matrix:**

| Code Type | Coverage Target | Test Type | Priority |
|-----------|----------------|-----------|----------|
| Domain/Business Logic | 90-100% | Unit | Critical |
| Services/Use Cases | 80-90% | Unit + Integration | High |
| Controllers/APIs | 70-80% | Integration | Medium |
| Infrastructure | 60-70% | Integration | Medium |
| UI Components | 60-70% | Component/E2E | Low |
| Configuration | 0-20% | Manual/E2E | Low |

### Mutation Testing (Advanced)

```yaml
# Stryker.NET - Mutation Testing
- script: |
    dotnet tool install -g dotnet-stryker
    dotnet stryker --reporter html --reporter dashboard
  displayName: 'Run mutation tests'
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
```

**What is Mutation Testing?**
- Changes your code (mutates it) and re-runs tests
- If tests still pass, your tests aren't catching bugs (poor quality)
- **Use case**: Validate test suite effectiveness, not for every build (too slow)

---

## 3. Deployment Strategies

### Blue-Green Deployment

```
┌────────────────────────────────────────┐
│  Production Traffic                    │
│         100%                           │
│          ↓                             │
│    [Load Balancer]                     │
│          ↓                             │
│    ┌─────────┐                         │
│    │  BLUE   │ ← Current (v1.0)        │
│    │ (Live)  │                         │
│    └─────────┘                         │
│                                        │
│    ┌─────────┐                         │
│    │  GREEN  │ ← New (v1.1)            │
│    │ (Idle)  │   Deploy here           │
│    └─────────┘                         │
│                                        │
│  After validation, switch traffic:     │
│          ↓                             │
│    ┌─────────┐                         │
│    │  BLUE   │ ← Old (v1.0)            │
│    │ (Idle)  │   Quick rollback        │
│    └─────────┘                         │
│                                        │
│    ┌─────────┐                         │
│    │  GREEN  │ ← Current (v1.1)        │
│    │ (Live)  │   Now serving traffic   │
│    └─────────┘                         │
└────────────────────────────────────────┘
```

**Implementation:**

```yaml
# Azure DevOps Blue-Green Deployment
- stage: DeployProduction
  displayName: 'Blue-Green Deployment'
  jobs:
  - deployment: DeployGreen
    displayName: 'Deploy to Green Slot'
    environment: 'Production'
    strategy:
      runOnce:
        deploy:
          steps:
          # Deploy to staging/green slot
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'Azure-Connection'
              appName: 'my-app'
              deployToSlotOrASE: true
              resourceGroupName: 'prod-rg'
              slotName: 'green'
              package: '$(Pipeline.Workspace)/drop/*.zip'

          # Warm up the slot
          - script: |
              curl https://my-app-green.azurewebsites.net/health
              sleep 10
            displayName: 'Warm up green slot'

          # Run smoke tests against green
          - script: |
              newman run smoke-tests.json \
                --env-var baseUrl=https://my-app-green.azurewebsites.net
            displayName: 'Smoke test green slot'

          # Swap slots (blue ← green)
          - task: AzureAppServiceManage@0
            inputs:
              azureSubscription: 'Azure-Connection'
              action: 'Swap Slots'
              webAppName: 'my-app'
              resourceGroupName: 'prod-rg'
              sourceSlot: 'green'
              targetSlot: 'production'

          # Monitor for issues (5 minutes)
          - script: |
              for i in {1..30}; do
                ERROR_RATE=$(curl -s https://api.app-insights.io/errors | jq '.rate')
                if (( $(echo "$ERROR_RATE > 5" | bc -l) )); then
                  echo "Error rate $ERROR_RATE% exceeds threshold!"
                  # Trigger rollback
                  exit 1
                fi
                sleep 10
              done
            displayName: 'Monitor error rates'
```

**When to Use Blue-Green:**
- ✅ Need instant rollback capability
- ✅ Can afford 2x infrastructure cost temporarily
- ✅ Zero-downtime requirement
- ❌ Database schema changes (migration complexity)
- ❌ Stateful applications without session affinity

### Canary Deployment

```
┌────────────────────────────────────────┐
│  Production Traffic                    │
│                                        │
│  Phase 1: 5% canary                    │
│    [Load Balancer]                     │
│       ↙ 95%      5% ↘                  │
│  [v1.0 - Stable]  [v1.1 - Canary]      │
│   95% of users    5% test group        │
│                                        │
│  Phase 2: 25% canary (if metrics OK)   │
│       ↙ 75%      25% ↘                 │
│  [v1.0 - Stable]  [v1.1 - Canary]      │
│                                        │
│  Phase 3: 100% (gradual rollout)       │
│            100% ↓                      │
│         [v1.1 - Stable]                │
└────────────────────────────────────────┘
```

**Implementation with Flagger (Kubernetes):**

```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: my-api
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-api

  service:
    port: 80

  analysis:
    # Duration of canary analysis
    interval: 1m
    threshold: 5
    maxWeight: 50
    stepWeight: 10

    # Metrics for canary analysis
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
      interval: 1m

    - name: request-duration
      thresholdRange:
        max: 500
      interval: 1m

    # Alerts
    webhooks:
    - name: load-test
      url: http://flagger-loadtester/
      timeout: 5s
      metadata:
        cmd: "hey -z 1m -q 10 -c 2 http://my-api-canary/"
```

**Canary Decision Framework:**

| Metric | Threshold | Action |
|--------|-----------|--------|
| Error Rate | > 1% increase | Halt rollout |
| Latency P99 | > 20% increase | Halt rollout |
| HTTP 5xx | > 0.1% | Halt rollout |
| Success Rate | < 99% | Rollback |
| Memory Usage | > 90% | Halt, investigate |

**When to Use Canary:**
- ✅ High-risk changes (algorithm changes, major refactors)
- ✅ Gradual validation with real users
- ✅ A/B testing capability
- ✅ Lower infrastructure cost than blue-green
- ❌ Need instant rollback (gradual rollback slower)
- ❌ Cannot split traffic (no load balancer support)

### Rolling Deployment

**Kubernetes Rolling Update:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-api
spec:
  replicas: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2        # Max 2 extra pods during update
      maxUnavailable: 1  # Max 1 pod unavailable

  template:
    spec:
      containers:
      - name: api
        image: myregistry.azurecr.io/api:v1.1

        # Readiness probe - when pod is ready
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5

        # Liveness probe - when pod is healthy
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
```

**Rolling Update Process:**
1. Create 1-2 new pods with new version
2. Wait for readiness probe to pass
3. Route traffic to new pods
4. Terminate 1-2 old pods
5. Repeat until all replicas updated

**When to Use Rolling:**
- ✅ Standard deployment (least complex)
- ✅ Can tolerate gradual rollout
- ✅ Low-risk changes
- ❌ Need instant rollback
- ❌ Breaking API changes

---

## 4. Feature Toggles (Feature Flags)

### The Feature Toggle Pattern

```csharp
// Feature toggle abstraction
public interface IFeatureManager
{
    Task<bool> IsEnabledAsync(string featureName);
    Task<bool> IsEnabledAsync(string featureName, ITargetingContext context);
}

// Usage in code
public class OrderService
{
    private readonly IFeatureManager _featureManager;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order();

        // New discount algorithm behind feature flag
        if (await _featureManager.IsEnabledAsync("NewDiscountAlgorithm"))
        {
            order.ApplyDiscount(CalculateDiscountV2(request));
        }
        else
        {
            order.ApplyDiscount(CalculateDiscountV1(request));
        }

        return await _repository.SaveAsync(order);
    }
}

// Azure App Configuration setup
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddAzureAppConfiguration();
        services.AddFeatureManagement()
            .AddFeatureFilter<TargetingFilter>()
            .AddFeatureFilter<TimeWindowFilter>();
    }
}
```

### Feature Toggle Configuration

```json
{
  "feature_management": {
    "feature_flags": [
      {
        "id": "NewDiscountAlgorithm",
        "description": "New discount calculation with tiered pricing",
        "enabled": true,
        "conditions": {
          "client_filters": [
            {
              "name": "Microsoft.Targeting",
              "parameters": {
                "Audience": {
                  "Users": [
                    "user1@example.com",
                    "user2@example.com"
                  ],
                  "Groups": [
                    {
                      "Name": "Beta Testers",
                      "RolloutPercentage": 20
                    },
                    {
                      "Name": "Premium Users",
                      "RolloutPercentage": 100
                    }
                  ],
                  "DefaultRolloutPercentage": 0
                }
              }
            },
            {
              "name": "Microsoft.TimeWindow",
              "parameters": {
                "Start": "2024-01-15T00:00:00Z",
                "End": "2024-02-15T00:00:00Z"
              }
            }
          ]
        }
      }
    ]
  }
}
```

### Feature Toggle Types

**1. Release Toggles (Temporary)**
```csharp
// Decouple deployment from release
if (await _features.IsEnabledAsync("NewCheckoutFlow"))
{
    return await NewCheckoutFlowAsync();
}
return await OldCheckoutFlowAsync();

// DELETE THIS CODE once rolled out 100%
```

**2. Experiment Toggles (A/B Testing)**
```csharp
// A/B test - 50/50 split
var variant = await _features.IsEnabledAsync("CheckoutVariantB")
    ? "B"
    : "A";

_analytics.Track("CheckoutVariant", new { variant });
```

**3. Ops Toggles (Kill Switch)**
```csharp
// Disable expensive feature under load
if (await _features.IsEnabledAsync("RecommendationEngine"))
{
    return await _recommendationService.GetRecommendationsAsync();
}
// Fallback: return empty recommendations
return Array.Empty<Product>();
```

**4. Permission Toggles (Permanent)**
```csharp
// Premium feature gate
if (await _features.IsEnabledAsync("AdvancedAnalytics", _user))
{
    return await _analytics.GetAdvancedReportAsync();
}
throw new UnauthorizedException("Premium feature");
```

**Tech Lead Feature Toggle Strategy:**

| Toggle Type | Lifetime | Who Controls | Clean Up? |
|-------------|----------|--------------|-----------|
| Release | Days-Weeks | Dev Team | Yes - after 100% rollout |
| Experiment | Weeks-Months | Product/Data | Yes - after experiment |
| Ops | Permanent | Ops/SRE | No |
| Permission | Permanent | Product | No |

**Anti-patterns to Avoid:**
- ❌ **Toggle spaghetti**: Too many nested toggles (max 2-3 deep)
- ❌ **Zombie toggles**: Old toggles never cleaned up
- ❌ **Testing debt**: Not testing both code paths
- ❌ **Complex logic**: Business logic shouldn't depend on 5+ toggle combinations

---

## 5. Rollback vs Roll-Forward

### The Eternal Debate

**Architect's Decision Matrix:**

| Factor | Rollback | Roll-Forward |
|--------|----------|--------------|
| **Speed** | Instant (seconds) | Requires code change (minutes-hours) |
| **Safety** | Known working state | Fixes root cause |
| **Database** | Complex with schema changes | Handles migrations cleanly |
| **Customer Impact** | Minimizes downtime | May prolong incident |
| **Learning** | Less urgency to fix | Forces proper fix |
| **Best For** | Critical prod incidents | Non-critical issues, schema migrations |

### Rollback Strategy

```yaml
# Automated rollback on deployment failure
- stage: DeployProduction
  displayName: 'Deploy to Production with Auto-Rollback'
  jobs:
  - deployment: DeployProd
    environment: 'Production'
    strategy:
      runOnce:
        deploy:
          steps:
          # Deploy new version
          - task: AzureWebApp@1
            inputs:
              appName: 'my-app'
              package: '$(Pipeline.Workspace)/drop/*.zip'
            name: DeployStep

          # Health check
          - script: |
              sleep 30  # Warm-up

              HEALTH_STATUS=$(curl -s https://my-app.azurewebsites.net/health | jq -r '.status')

              if [ "$HEALTH_STATUS" != "Healthy" ]; then
                echo "Health check failed: $HEALTH_STATUS"
                echo "##vso[task.setvariable variable=ShouldRollback]true"
                exit 1
              fi
            displayName: 'Health check'
            continueOnError: true

          # Monitor error rates
          - script: |
              for i in {1..12}; do  # 2 minutes of monitoring
                ERROR_RATE=$(az monitor metrics list \
                  --resource /subscriptions/.../my-app \
                  --metric Http5xx \
                  --aggregation Average \
                  | jq '.value[0].timeseries[0].data[0].average')

                if (( $(echo "$ERROR_RATE > 5" | bc -l) )); then
                  echo "Error rate $ERROR_RATE% exceeds 5% threshold"
                  echo "##vso[task.setvariable variable=ShouldRollback]true"
                  exit 1
                fi

                sleep 10
              done
            displayName: 'Monitor error rates'
            continueOnError: true

        on:
          failure:
            steps:
            # Rollback to previous version
            - task: AzureAppServiceManage@0
              condition: eq(variables['ShouldRollback'], 'true')
              inputs:
                azureSubscription: 'Azure-Connection'
                action: 'Swap Slots'
                webAppName: 'my-app'
                sourceSlot: 'production'
                targetSlot: 'previous'
              displayName: 'ROLLBACK: Swap to previous version'

            # Alert team
            - script: |
                curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
                  -H 'Content-Type: application/json' \
                  -d '{
                    "text": "🚨 PRODUCTION DEPLOYMENT FAILED - ROLLED BACK",
                    "attachments": [{
                      "color": "danger",
                      "fields": [
                        {"title": "Build", "value": "$(Build.BuildNumber)", "short": true},
                        {"title": "Reason", "value": "Health check or error rate threshold exceeded"}
                      ]
                    }]
                  }'
              displayName: 'Alert team of rollback'
```

### Roll-Forward Strategy

```csharp
// Database migration that supports both old and new code
public class Migration_AddEmailVerifiedColumn : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Add new column (nullable initially)
        migrationBuilder.AddColumn<bool>(
            name: "EmailVerified",
            table: "Users",
            nullable: true,  // Allow nulls during transition
            defaultValue: false);

        // Backfill existing users
        migrationBuilder.Sql(
            "UPDATE Users SET EmailVerified = 0 WHERE EmailVerified IS NULL");
    }

    // Second migration (deploy later) - make NOT NULL
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AlterColumn<bool>(
            name: "EmailVerified",
            table: "Users",
            nullable: false);  // Now require the value
    }
}

// Application code compatible with both states
public class UserService
{
    public async Task<User> GetUserAsync(Guid id)
    {
        var user = await _repository.GetByIdAsync(id);

        // Handle both old DB (EmailVerified = null) and new DB
        user.IsVerified = user.EmailVerified ?? false;

        return user;
    }
}
```

**Migration Strategy (Expand-Contract Pattern):**
1. **Expand**: Add new column/table (nullable)
2. **Migrate**: Dual-write to both old and new
3. **Contract**: Remove old column/table after all code updated

---

## 6. Infrastructure as Code (IaC)

### The IaC Mindset

**Principles:**
- **Version controlled**: All infrastructure in git
- **Reviewable**: Infrastructure changes go through PRs
- **Testable**: Validate infrastructure before deployment
- **Repeatable**: Same code → same infrastructure
- **Immutable**: Replace, don't modify (cattle, not pets)

### Terraform Example (Azure)

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "production.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "prod-${var.app_name}-rg"
  location = var.location

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "Engineering"
  }
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "prod-${var.app_name}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "P1v3"  # Production tier

  # Auto-scaling configuration
  per_site_scaling_enabled = true
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "prod-${var.app_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    always_on = true

    application_stack {
      dotnet_version = "8.0"
    }

    # Health check
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5

    # Deployment slot configuration
    auto_swap_slot_name = "staging"
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "ASPNETCORE_ENVIRONMENT"                = "Production"
    "FeatureManagement__ConnectionString"   = azurerm_app_configuration.main.primary_read_key[0].connection_string
  }

  identity {
    type = "SystemAssigned"
  }
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "prod-${var.app_name}-ai"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  retention_in_days   = 90
}

# Auto-scaling rules
resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "prod-${var.app_name}-autoscale"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  target_resource_id  = azurerm_service_plan.main.id

  profile {
    name = "default"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    # Scale out rule: CPU > 70%
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Scale in rule: CPU < 30%
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }
}

# Output values
output "app_service_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_service_identity" {
  value = azurerm_linux_web_app.main.identity[0].principal_id
}
```

### IaC Pipeline

```yaml
# terraform-pipeline.yml
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - infrastructure/*

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: Validate
  displayName: 'Validate Terraform'
  jobs:
  - job: ValidateJob
    steps:
    - task: TerraformInstaller@0
      inputs:
        terraformVersion: '1.5.0'

    # Format check
    - script: terraform fmt -check -recursive
      workingDirectory: $(System.DefaultWorkingDirectory)/infrastructure
      displayName: 'Check formatting'

    # Validate syntax
    - script: |
        terraform init -backend=false
        terraform validate
      workingDirectory: $(System.DefaultWorkingDirectory)/infrastructure
      displayName: 'Validate syntax'

    # Security scanning
    - script: |
        wget https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-linux-amd64
        chmod +x tfsec-linux-amd64
        ./tfsec-linux-amd64 --format junit > tfsec-results.xml
      workingDirectory: $(System.DefaultWorkingDirectory)/infrastructure
      displayName: 'Security scan with tfsec'

- stage: Plan
  displayName: 'Terraform Plan'
  dependsOn: Validate
  jobs:
  - job: PlanJob
    steps:
    - task: TerraformCLI@0
      inputs:
        command: 'init'
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure'
        backendType: 'azurerm'
        backendServiceArm: 'Azure-Connection'
        backendAzureRmResourceGroupName: 'terraform-state-rg'
        backendAzureRmStorageAccountName: 'tfstate'
        backendAzureRmContainerName: 'tfstate'
        backendAzureRmKey: 'production.tfstate'

    - task: TerraformCLI@0
      inputs:
        command: 'plan'
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure'
        commandOptions: '-out=tfplan'
        environmentServiceName: 'Azure-Connection'

    # Show plan for review
    - script: terraform show tfplan
      workingDirectory: $(System.DefaultWorkingDirectory)/infrastructure
      displayName: 'Show plan'

- stage: Apply
  displayName: 'Terraform Apply'
  dependsOn: Plan
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: ApplyJob
    environment: 'Production-Infrastructure'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: TerraformCLI@0
            inputs:
              command: 'apply'
              workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure'
              commandOptions: 'tfplan'
              environmentServiceName: 'Azure-Connection'
```

---

## 7. Environment Promotion Strategy

### The Environment Ladder

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  DEV → TEST → STAGING → CANARY → PRODUCTION        │
│   ↓      ↓       ↓         ↓          ↓            │
│  Fast  Auto   Manual   Gradual   Monitored         │
│  Fail  Tests  QA Gate  Rollout   Alerts            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Environment Configuration Matrix

| Aspect | Dev | Test | Staging | Production |
|--------|-----|------|---------|------------|
| **Infrastructure** | Shared/Small | Shared/Medium | Prod-like | Prod Scale |
| **Data** | Synthetic | Anonymized Prod | Anonymized Prod | Real |
| **Deployment** | On commit | On merge to main | Manual gate | Automated with gates |
| **Testing** | Unit + Fast Integration | Full test suite | Smoke + E2E | Smoke + Monitoring |
| **Monitoring** | Basic | Standard | Full | Full + On-call |
| **Cost** | $100/month | $500/month | $2K/month | $20K/month |

### Configuration Management

```csharp
// appsettings.{Environment}.json pattern
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=prod-sql.database.windows.net;..."
  },
  "FeatureManagement": {
    "ConnectionString": "Endpoint=https://prod-config.azconfig.io"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Warning",      // Less verbose in prod
      "Microsoft": "Error"
    }
  },
  "AppSettings": {
    "MaxRetryAttempts": 3,
    "CacheExpirationMinutes": 60,
    "EnableDetailedErrors": false  // Never in production
  }
}

// Key Vault for secrets
public class Startup
{
    public void ConfigureAppConfiguration(IConfigurationBuilder builder)
    {
        var config = builder.Build();
        var keyVaultEndpoint = config["KeyVault:Endpoint"];

        if (!string.IsNullOrEmpty(keyVaultEndpoint))
        {
            builder.AddAzureKeyVault(
                new Uri(keyVaultEndpoint),
                new DefaultAzureCredential());
        }
    }
}
```

---

## 8. End-to-End Release Pipeline (Complete Example)

### The Complete Flow

```yaml
# complete-pipeline.yml
name: $(Date:yyyyMMdd)$(Rev:.r)

trigger:
  branches:
    include:
    - main
    - develop

variables:
  buildConfiguration: 'Release'
  azureSubscription: 'Azure-Production'

stages:
#──────────────────────────────────────────────────────
# STAGE 1: BUILD & TEST
#──────────────────────────────────────────────────────
- stage: Build
  displayName: 'Build Application'
  jobs:
  - job: BuildJob
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Checkout code
    - checkout: self
      fetchDepth: 0  # Full history for GitVersion

    # Version calculation
    - task: GitVersion@5
      inputs:
        runtime: 'core'
        configFilePath: 'GitVersion.yml'

    # Build
    - task: DotNetCoreCLI@2
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) /p:Version=$(GitVersion.SemVer)'

    # Unit Tests
    - task: DotNetCoreCLI@2
      inputs:
        command: 'test'
        projects: '**/*UnitTests.csproj'
        arguments: '--configuration $(buildConfiguration) --collect:"XPlat Code Coverage"'

    # Publish
    - task: DotNetCoreCLI@2
      inputs:
        command: 'publish'
        publishWebProjects: true
        arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'

    # Publish artifacts
    - publish: $(Build.ArtifactStagingDirectory)
      artifact: 'drop'

#──────────────────────────────────────────────────────
# STAGE 2: QUALITY GATES
#──────────────────────────────────────────────────────
- stage: QualityGates
  displayName: 'Quality & Security Gates'
  dependsOn: Build
  jobs:
  - job: SecurityScan
    displayName: 'Security Scanning'
    steps:
    - task: DependencyCheck@0
      inputs:
        projectName: 'MyApp'
        scanPath: '$(Build.SourcesDirectory)'
        format: 'HTML'

  - job: CodeQuality
    displayName: 'Code Quality Analysis'
    steps:
    - task: SonarCloudAnalyze@1
    - task: SonarCloudPublish@1
      inputs:
        pollingTimeoutSec: '300'

#──────────────────────────────────────────────────────
# STAGE 3: DEV DEPLOYMENT
#──────────────────────────────────────────────────────
- stage: DeployDev
  displayName: 'Deploy to Dev'
  dependsOn: QualityGates
  jobs:
  - deployment: DeployDevJob
    environment: 'Development'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: $(azureSubscription)
              appName: 'dev-myapp'
              package: '$(Pipeline.Workspace)/drop/*.zip'

#──────────────────────────────────────────────────────
# STAGE 4: TEST ENVIRONMENT
#──────────────────────────────────────────────────────
- stage: DeployTest
  displayName: 'Deploy to Test'
  dependsOn: DeployDev
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployTestJob
    environment: 'Test'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: $(azureSubscription)
              appName: 'test-myapp'
              package: '$(Pipeline.Workspace)/drop/*.zip'

          # Integration Tests
          - task: DotNetCoreCLI@2
            inputs:
              command: 'test'
              projects: '**/*IntegrationTests.csproj'
              arguments: '--configuration $(buildConfiguration)'

#──────────────────────────────────────────────────────
# STAGE 5: STAGING DEPLOYMENT
#──────────────────────────────────────────────────────
- stage: DeployStaging
  displayName: 'Deploy to Staging'
  dependsOn: DeployTest
  jobs:
  - deployment: DeployStagingJob
    environment: 'Staging'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: $(azureSubscription)
              appName: 'staging-myapp'
              package: '$(Pipeline.Workspace)/drop/*.zip'

          # Smoke Tests
          - script: |
              newman run $(System.DefaultWorkingDirectory)/tests/smoke-tests.json \
                --env-var baseUrl=https://staging-myapp.azurewebsites.net
            displayName: 'Run smoke tests'

#──────────────────────────────────────────────────────
# STAGE 6: PRODUCTION DEPLOYMENT (BLUE-GREEN)
#──────────────────────────────────────────────────────
- stage: DeployProduction
  displayName: 'Deploy to Production (Blue-Green)'
  dependsOn: DeployStaging
  jobs:
  - deployment: DeployProdJob
    environment: 'Production'
    strategy:
      runOnce:
        deploy:
          steps:
          # Deploy to green slot
          - task: AzureWebApp@1
            inputs:
              azureSubscription: $(azureSubscription)
              appName: 'prod-myapp'
              deployToSlotOrASE: true
              resourceGroupName: 'prod-rg'
              slotName: 'green'
              package: '$(Pipeline.Workspace)/drop/*.zip'

          # Warm up
          - script: |
              for i in {1..10}; do
                curl -s https://prod-myapp-green.azurewebsites.net/health
                sleep 2
              done
            displayName: 'Warm up green slot'

          # Smoke tests on green
          - script: |
              newman run tests/smoke-tests.json \
                --env-var baseUrl=https://prod-myapp-green.azurewebsites.net
            displayName: 'Smoke test green slot'

          # Swap slots
          - task: AzureAppServiceManage@0
            inputs:
              azureSubscription: $(azureSubscription)
              action: 'Swap Slots'
              webAppName: 'prod-myapp'
              resourceGroupName: 'prod-rg'
              sourceSlot: 'green'
              targetSlot: 'production'

          # Post-deployment monitoring
          - script: |
              sleep 60
              ERROR_COUNT=$(az monitor metrics list \
                --resource /subscriptions/.../prod-myapp \
                --metric Http5xx \
                --aggregation Total \
                | jq '.value[0].timeseries[0].data[0].total')

              if [ "$ERROR_COUNT" -gt 10 ]; then
                echo "##vso[task.logissue type=error]High error count: $ERROR_COUNT"
                exit 1
              fi
            displayName: 'Monitor deployment health'
```

---

## Interview Questions & Answers

### Q1: "How do you decide between blue-green and canary deployments?"

**Strong Answer:**
"The choice depends on three factors:

**Use Blue-Green when:**
- Need instant rollback capability (financial systems, critical services)
- Can afford 2x infrastructure cost temporarily
- Schema changes are minimal or backward compatible

**Use Canary when:**
- Want to validate with real users gradually (A/B testing)
- Need to minimize infrastructure cost
- High-risk algorithm or business logic changes

**Example from experience:**
At my previous company, we used blue-green for our payment service because we needed instant rollback capability if anything went wrong. But for our recommendation engine, we used canary deployment with a 5% → 25% → 100% rollout over 2 days because we wanted to validate the new ML model with real traffic before full rollout.

The key is matching the strategy to your risk tolerance and infrastructure budget."

### Q2: "What's your approach to managing feature flags?"

**Strong Answer:**
"Feature flags are powerful but can become technical debt if not managed properly. My approach:

**1. Categorize toggles:**
- Release toggles (temporary): Delete within 2 weeks of 100% rollout
- Experiment toggles (temporary): Clean up after experiment concludes
- Ops toggles (permanent): Kill switches for expensive features
- Permission toggles (permanent): Premium feature gates

**2. Clean up strategy:**
- Every release, review all active flags
- Add Jira tickets for flag removal
- Set expiration dates in configuration

**3. Testing:**
- Unit test both code paths
- Integration tests with flags on/off
- Never deploy with untested flag combinations

**Example:**
We implemented a 'zombie flag' detector that runs weekly and alerts us to flags that haven't changed state in 30 days. This reduced our flag count from 45 to 12 permanent flags."

### Q3: "How do you handle database migrations in production?"

**Strong Answer:**
"Database migrations are high-risk because they're harder to rollback than code. I use the expand-contract pattern:

**Phase 1 - Expand (Week 1):**
- Add new column/table (nullable, with default value)
- Deploy code that writes to both old and new
- Old code still works

**Phase 2 - Migrate (Week 2):**
- Backfill data for existing records
- Verify data quality
- Monitor for issues

**Phase 3 - Contract (Week 3):**
- Deploy code that only uses new column
- Remove old column once confident

**Example:**
When we migrated from storing user preferences as JSON to individual columns, we ran dual-write for 2 weeks. This gave us confidence to rollback code at any point without data loss. The total migration took 3 weeks, but we had zero downtime and could rollback at any stage."

---

## Summary

**Tech Lead/Architect Mindset for CI/CD:**

1. **Pipeline as Code**: Everything version controlled and reviewable
2. **Fast Feedback**: Fail fast, run fastest tests first
3. **Quality Gates**: Automated, but don't make them too strict
4. **Deployment Strategy**: Match strategy to risk level
5. **Feature Flags**: Enable decoupling deployment from release
6. **Rollback Plan**: Always have an escape hatch
7. **IaC**: Infrastructure is code, treat it the same
8. **Observability**: Can't deploy what you can't monitor

**Remember:**
- Perfect is the enemy of good - start simple, iterate
- Optimize for mean time to recovery (MTTR), not mean time between failures (MTBF)
- Every deployment is a learning opportunity

---

## Deliverables
✔ End-to-end release pipeline explanation
✔ Decision frameworks for deployment strategies
✔ Feature flag management patterns
✔ IaC best practices with examples
✔ Rollback vs roll-forward trade-offs
✔ Quality gate strategies
✔ Production-ready pipeline templates
