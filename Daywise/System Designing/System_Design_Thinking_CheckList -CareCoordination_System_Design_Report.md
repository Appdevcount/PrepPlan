# CareCoordination - System Design Analysis Report

**Date:** 2026-02-14
**Scope:** Backend (.NET 9 API) & UI (React 18 SPA)
**Reference:** System Design Thinking Checklist

---

## 1. Vision & Business Understanding

| Aspect | Current State |
|---|---|
| **Domain** | Healthcare - Prior Authorization & Care Coordination |
| **Target Users** | Internal clinical staff, case coordinators, and reviewers at eviCore/Aetna |
| **Core Problem** | Streamline prior authorization workflows: request creation, search, case management, dashboard tracking, and document attachments |
| **Business Criticality** | High - healthcare compliance (HIPAA), patient care timelines, payer-provider coordination |
| **Production URL** | `https://imageone.carecorenational.com/CareCoordinationUI` |

### Trade-offs Identified
| Gain | Sacrifice |
|---|---|
| Compliance-first design (HIPAA, PII) | Higher development friction |
| Integration with legacy ImageOne systems | Tighter coupling to existing ecosystem |

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 1.1 | No documented business KPIs or SLAs in codebase | Cannot measure success | Define SLAs (e.g., 99.9% uptime, <2s page load) and track via dashboards |
| 1.2 | Scope boundaries not formally documented | Feature creep risk | Create ADR (Architecture Decision Records) for scope boundaries |

**Score: 3/5** | **Risk Level: Medium**

---

## 2. Requirements Analysis

### 2.1 Functional Requirements (Identified from Controllers & UI Routes)

| Module | Backend Controller | UI Page/Component | Key Flows |
|---|---|---|---|
| **Authentication** | `AuthController` | `Login.tsx`, `AuthProvider.tsx` | Token generation, validation, refresh, user details |
| **Dashboard** | `DashboardController` | `Dashboard.tsx`, `CCDashboard/` | Case assignment, dashboard details, assignee details |
| **Request Creation** | `RequestCreationController` | `CreateRequestView.tsx`, `RequestCreation/` | Create new prior auth requests |
| **Request Search** | `RequestSearchController` | `SearchRequestView.tsx` | Search existing requests |
| **Request View** | `RequestViewController` | `RequestSummaryView.tsx`, `RequestSummary/` | View request details and summary |
| **Case Management** | `CaseManagementController` | (Integrated in dashboard) | Case workflow operations |
| **Attachments** | `AttachmentsController` | (Integrated in request views) | Upload/download case documents |
| **Lookups** | `LookupController` | `LookupService.ts` | Reference data (procedure codes, sites, physicians) |

### 2.2 Non-Functional Requirements

| Requirement | Current State | Assessment |
|---|---|---|
| **Availability** | No explicit HA config; single API instance via Docker | Not defined - needs SLA target |
| **Latency** | No caching layer for API responses; in-memory cache for API tokens only | Needs baseline measurement |
| **Scalability** | Single monolith API, no horizontal scaling config | Limited - Docker but no orchestration observed |
| **Security** | JWT + API Key dual auth, HSTS, XSS filter, security headers, RSA signing | Strong foundation |
| **Compliance** | HIPAA context (healthcare), PII handling | Needs formal audit trail review |

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 2.1 | No formal SLA/SLO targets defined | Cannot measure reliability | Define 99.9% availability, <500ms API p95 latency |
| 2.2 | No rate limiting on API endpoints | Abuse/DDoS vulnerability | Add rate limiting middleware (e.g., `AspNetCoreRateLimit`) |
| 2.3 | Edge cases not formally documented | Silent failures | Document edge cases per endpoint (timeout, empty results, concurrent edits) |

**Score: 3/5** | **Risk Level: Medium**

---

## 3. Constraints

| Constraint | Details |
|---|---|
| **Team** | CitiusTech development team (assumed mid-size) |
| **Cloud** | Azure (Application Insights, Azure DevOps, APIM) |
| **Legacy Dependencies** | ImageOne system, AetnaAuth, UPADS, GeneralDataService (WCF/SOAP Connected Service) |
| **Database** | SQL Server (via Dapper ORM, `Microsoft.Data.SqlClient`) |
| **Vendor Lock-in** | Moderate - Azure Application Insights, Azure APIM, Azure DevOps NuGet feeds |
| **Regulatory** | HIPAA compliance required for healthcare data |

### Trade-offs Identified
| Gain | Sacrifice |
|---|---|
| Leveraging existing Azure ecosystem | Vendor lock-in |
| Dapper for performance | Manual SQL management vs EF Code-First migrations |
| Legacy integration (ImageOne) | Coupling to older system patterns |

**Score: 3/5** | **Risk Level: Medium**

---

## 4. Risk Identification

| Risk Category | Risk | Likelihood | Impact | Mitigation Status |
|---|---|---|---|---|
| **Technical** | Single database connection string, no read replicas | Medium | High | Not mitigated |
| **Technical** | No circuit breaker for external service calls (APIM, ImageOne, AetnaAuth) | High | High | Not mitigated |
| **Technical** | Hardcoded API key in `appsettings.json` (`"ApiKey": "MyAPIKey7347627"`) | High | Critical | **Needs immediate fix** - move to Azure Key Vault |
| **Technical** | `throw` after `return StatusCode(...)` in controllers - dead code | Low | Low | Code cleanup needed |
| **Security** | Token stored in `localStorage` (XSS vulnerable) | Medium | High | Consider `httpOnly` cookies |
| **Operational** | No health check endpoints | Medium | Medium | Add `/health` endpoint |
| **Business** | Legacy SOAP service dependency (`GeneralDataService`) | Medium | Medium | Plan migration to REST |
| **Operational** | SonarQube configured but many folders excluded from coverage | Medium | Medium | Reduce exclusions over time |

### Critical Risks Requiring Immediate Action
1. **Hardcoded API key** in appsettings.json - must be moved to secret management
2. **No circuit breaker** for external HTTP calls - could cascade failures
3. **localStorage token storage** - XSS attack vector

**Score: 2/5** | **Risk Level: High**

---

## 5. Architecture Style

### Current: Layered Monolith (Clean Architecture)

```
┌─────────────────────────────────────────────────┐
│                  CareCoordination.Api            │
│         (Controllers, Middleware, DTOs)          │
├─────────────────────────────────────────────────┤
│            CareCoordination.Application          │
│    (Handlers, Interfaces, Logger, Mappers)       │
├──────────────────────┬──────────────────────────┤
│  CareCoordination.   │  CareCoordination.       │
│  Services            │  DAL                     │
│  (External APIs,     │  (Dapper, SQL Server,    │
│   HTTP Clients,      │   Repositories)          │
│   Token Cache)       │                          │
├──────────────────────┴──────────────────────────┤
│            CareCoordination.Domain               │
│        (Entities, Constants, Validators)         │
└─────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Project | Responsibility |
|---|---|---|
| **Presentation** | `CareCoordination.Api` | REST controllers, DTOs, middleware (JWT/API Key), XSS filter, security headers |
| **Application** | `CareCoordination.Application` | Business logic handlers, interface abstractions (DAL, Service, Handler), logging, AutoMapper profiles |
| **Infrastructure - External** | `CareCoordination.Services` | HTTP client wrappers, external API calls (APIM, AetnaAuth, Object Valet), token caching, file handling |
| **Infrastructure - Data** | `CareCoordination.DAL` | Dapper repositories, SQL Server access, DB service, type handlers |
| **Domain** | `CareCoordination.Domain` | Entity definitions, constants, validators, enums |
| **Tests** | `CareCoordination.Tests` | Unit tests for handlers, controllers, DAL, services, mappers, validators |

### Dependency Flow
```
Api → Application → Domain
Api → DAL → Application → Domain
Api → Services → Application → Domain
```

### Assessment
| Aspect | Evaluation |
|---|---|
| **Style Appropriateness** | Good fit for current team size and application scope |
| **Separation of Concerns** | Well-structured with clear layer boundaries |
| **Testability** | Interfaces defined for all layers; DI properly configured |
| **Evolution Path** | Can evolve to modular monolith or extract microservices if needed |

### Gaps & Recommendations
| # | Gap | Recommendation |
|---|---|---|
| 5.1 | Dockerfile references `CareCoordination.Infrastructure` (stale/mismatched) | Update Dockerfile to match actual project structure |
| 5.2 | No global exception handling middleware | Add `UseExceptionHandler` middleware for consistent error responses |
| 5.3 | Duplicate DI registrations (`IUserManagement` registered twice as Transient + Scoped) | Fix to single registration with appropriate lifetime |

**Score: 4/5** | **Risk Level: Low**

---

## 6. High-Level Component Design

### Backend Component Flow
```
Client (React SPA)
    │
    ▼
┌────────────────────┐
│   Nginx (UI Host)  │ ─── Static files, gzip, SPA fallback
└────────┬───────────┘
         │ HTTPS
         ▼
┌────────────────────┐
│  .NET 9 API        │
│  ┌──────────────┐  │
│  │ Middleware    │  │ ─── JWT Auth, API Key, XSS Filter, Security Headers
│  ├──────────────┤  │
│  │ Controllers  │  │ ─── 8 REST controllers
│  ├──────────────┤  │
│  │ Handlers     │  │ ─── Business logic orchestration
│  ├──────────────┤  │
│  │ Services     │  │ ─── External API integration
│  │ ┌──────────┐ │  │
│  │ │MemCache  │ │  │ ─── In-memory token caching
│  │ └──────────┘ │  │
│  ├──────────────┤  │
│  │ DAL (Dapper) │  │ ─── Data access
│  └──────────────┘  │
└────────┬───────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌──────────────────┐
│SQL     │ │ External Systems │
│Server  │ │ - Azure APIM     │
│(2 DBs) │ │ - ImageOne       │
└────────┘ │ - AetnaAuth      │
           │ - Object Valet   │
           │ - UPADS          │
           │ - GeneralData    │
           │   (WCF/SOAP)     │
           └──────────────────┘
```

### UI Component Architecture
```
App.tsx
├── Provider (Redux Store)
├── BrowserRouter (basename=/CareCoordinationUI)
│   ├── ErrorBoundary
│   │   └── AuthProvider (Context API)
│   │       ├── Sidebar (Navigation)
│   │       └── MainContent (Routes)
│   │           ├── /login → Login
│   │           ├── / → Dashboard (Protected)
│   │           ├── /createrequest → CreateRequest (Protected)
│   │           ├── /searchrequest → SearchRequest (Protected)
│   │           ├── /viewrequest → ViewRequest (Protected)
│   │           └── /invalidsession → InvalidSession
```

### Assessment
| Aspect | Status |
|---|---|
| Clear service boundaries | Yes - well-defined layers |
| API vs async separation | API only (sync) - no async messaging |
| Statelessness | API is stateless (JWT-based auth) |
| Backward compatibility | No versioning strategy in API routes |

**Score: 3/5** | **Risk Level: Medium**

---

## 7. Data Architecture

### Database Strategy

| Aspect | Details |
|---|---|
| **DBMS** | Microsoft SQL Server |
| **ORM** | Dapper (micro-ORM) - raw SQL with object mapping |
| **Connection Strings** | `PreAuthin` (primary), `OAOData` (secondary/reference) |
| **Connection Management** | Scoped `IDbConnection` via DI (SqlConnection) |
| **Type Handling** | Custom Dapper type handlers configured at startup |

### Data Flow
```
Controller → Handler → Repository (DAL) → Dapper → SQL Server
                 ↕
         AutoMapper (Model ↔ DTO transformations)
```

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 7.1 | No database migrations framework | Schema drift risk | Add DbUp or FluentMigrator for versioned migrations |
| 7.2 | No read replica configuration | Single point of failure | Configure read replicas for reporting queries |
| 7.3 | No data archival/retention policy visible | Storage growth, compliance risk | Define retention policies for case data |
| 7.4 | Connection string as singleton string (not typed config) | Configuration management issue | Use `IOptions<T>` pattern |
| 7.5 | No query performance monitoring | Slow query risks | Add SQL query logging/profiling |

**Score: 2/5** | **Risk Level: High**

---

## 8. Integration & Communication

### External Service Integrations

| Service | Protocol | Purpose | Auth Method |
|---|---|---|---|
| **Azure APIM** (Member Procedure Eligibility) | REST/HTTPS | Member eligibility checks | Subscription key (`Ocp-Apim-Subscription-Key`) |
| **Azure APIM** (Site Service) | REST/HTTPS | Site details lookup | Subscription key |
| **Object Valet (OV)** | REST/HTTPS (OAuth2) | Document management (upload/download/list) | OAuth2 Client Credentials |
| **AetnaAuth** | REST/HTTPS (OAuth2) | Auth migration API | OAuth2 Client Credentials |
| **ImageOne/UPADS** | HTTPS | Member eligibility, physician lookup | URL-based integration |
| **GeneralDataService** | WCF/SOAP | General data operations | Connected Service reference |
| **Application Insights** | SDK | Telemetry, logging, monitoring | Instrumentation Key |

### Communication Pattern Assessment

| Aspect | Current | Recommendation |
|---|---|---|
| **Pattern** | 100% Synchronous (HTTP) | Add async for non-blocking ops (notifications, document processing) |
| **Timeout handling** | Not explicitly configured on HttpClient | Add `HttpClient` timeout + Polly retry policies |
| **Idempotency** | Not implemented | Add idempotency keys for request creation |
| **Circuit breaker** | Not implemented | Add Polly circuit breaker for all external calls |
| **DLQ** | N/A (no messaging) | Consider for failed document uploads |

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 8.1 | No retry/circuit breaker for external HTTP calls | Cascading failures | Add Polly (`Microsoft.Extensions.Http.Polly`) |
| 8.2 | All communication is synchronous | Blocking on slow external services | Consider async message queue for document processing |
| 8.3 | SOAP/WCF dependency (GeneralDataService) | Legacy technology risk | Plan migration to REST API |
| 8.4 | No request correlation IDs for distributed tracing | Debugging difficulty | Add correlation ID middleware |

**Score: 2/5** | **Risk Level: High**

---

## 9. Scaling Strategy

### Current State

| Aspect | Status |
|---|---|
| **Containerization** | Dockerfile exists for API (multi-stage build, .NET 9) |
| **Orchestration** | Not configured (no Kubernetes manifests, docker-compose) |
| **Load Balancing** | Not configured |
| **Auto-scaling** | Not configured |
| **CDN** | Nginx serves static UI assets with gzip compression |

### Bottleneck Analysis

| Bottleneck Area | Current Handling | Risk |
|---|---|---|
| **Read-heavy (Dashboard, Search)** | Direct DB queries via Dapper | High under load |
| **Write-heavy (Request Creation)** | Direct DB writes | Medium |
| **External API calls** | Synchronous, no pooling | High |
| **File attachments** | Via Object Valet API | Medium |
| **Token caching** | In-memory (`IMemoryCache`) | Lost on restart, not distributed |

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 9.1 | No Redis/distributed cache | Cache loss on restart; can't scale out | Add Redis for token cache & frequently accessed lookups |
| 9.2 | No response caching for lookup APIs | Unnecessary DB load | Add `[ResponseCache]` for static lookup data |
| 9.3 | No horizontal scaling infrastructure | Single instance bottleneck | Add Kubernetes/Azure Container Apps config |
| 9.4 | UI build not optimized (CRA, no code splitting config) | Larger bundle size | Migrate to Vite or configure CRA code splitting |
| 9.5 | No CDN for UI assets in production | Slower global access | Deploy UI behind Azure CDN |

**Score: 2/5** | **Risk Level: High**

---

## 10. Failure & Resilience Design

### Current State

| Pattern | Implemented? | Details |
|---|---|---|
| **Global exception handler** | Partial | Per-controller try-catch, no global middleware |
| **Error boundary (UI)** | Yes | `ErrorBoundary` component wraps app |
| **Graceful degradation** | No | No fallback for external service failures |
| **Retry logic** | No | No retry on transient failures |
| **Circuit breaker** | No | No circuit breaker pattern |
| **Health checks** | No | No `/health` endpoint |
| **Dead letter queue** | N/A | No messaging infrastructure |

### Issues Found in Error Handling

```csharp
// Pattern found in multiple controllers - dead code after return:
catch(Exception ex)
{
    _logger.LogException("...", ex);
    return StatusCode(500, ex.Message);  // Returns error message to client
    throw;  // DEAD CODE - never reached
}
```

**Issues:**
1. Exception message exposed to client (information disclosure)
2. Dead `throw` statement after `return`
3. No structured error response model

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 10.1 | No global exception handling middleware | Inconsistent error responses | Add `UseExceptionHandler` with standardized error model |
| 10.2 | Exception messages returned to clients | Information disclosure | Return generic error messages; log details server-side |
| 10.3 | No retry for transient failures | Temporary failures become permanent | Add Polly retry policies |
| 10.4 | No health check endpoint | Cannot monitor API health | Add `Microsoft.AspNetCore.Diagnostics.HealthChecks` |
| 10.5 | UI has no offline/degraded mode | Blank screens on API failure | Add loading states and error messaging per feature |

**Score: 1/5** | **Risk Level: Critical**

---

## 11. Security Architecture

### Current Implementation

| Security Control | Status | Details |
|---|---|---|
| **Authentication** | JWT Bearer + API Key | RSA-signed JWT tokens, API key header validation |
| **Authorization** | Role-based (RBAC) | `[Authorize]` attribute on controllers; `ProtectedRoute` with `allowedRoles` on UI |
| **Token Management** | Custom implementation | Generate, validate, refresh token endpoints |
| **HSTS** | Enabled | 365-day max-age, preload, include subdomains |
| **Security Headers** | Yes | X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy, CSP |
| **CORS** | Configured | Specific origins whitelisted |
| **XSS Protection** | `XssFilterAttribute` on all controllers | Input sanitization |
| **HTTPS** | Enforced | `UseHttpsRedirection()` |
| **Secrets Management** | Partial | Placeholder tokens (`__value__`) for CI/CD substitution |

### Security Concerns

| # | Concern | Severity | Details |
|---|---|---|---|
| 11.1 | **Hardcoded API key** in appsettings.json | Critical | `"ApiKey": "MyAPIKey7347627"` - must move to Key Vault |
| 11.2 | **Token in localStorage** | High | Vulnerable to XSS; prefer httpOnly cookies |
| 11.3 | `ValidateIssuer = false`, `ValidateAudience = false` | Medium | JWT validation not fully strict |
| 11.4 | No audit logging for sensitive operations | Medium | HIPAA requires audit trails |
| 11.5 | `allowedRoles={['']}` on all protected routes | Medium | Empty string role - effectively no role check |
| 11.6 | `Console.WriteLine` for auth failures | Low | Should use structured logging |
| 11.7 | User permissions check (`LEA`) referenced but implementation unclear | Medium | Verify enforcement |

### Recommendations
| # | Recommendation | Priority |
|---|---|---|
| S1 | Move all secrets to Azure Key Vault | P0 - Immediate |
| S2 | Switch token storage from localStorage to httpOnly secure cookies | P1 |
| S3 | Enable JWT Issuer and Audience validation | P1 |
| S4 | Implement proper RBAC with defined roles on protected routes | P1 |
| S5 | Add HIPAA-compliant audit logging | P1 |
| S6 | Add rate limiting for auth endpoints | P2 |

**Score: 3/5** | **Risk Level: High**

---

## 12. Observability & Operations

### Current State

| Capability | Status | Technology |
|---|---|---|
| **Application Logging** | Custom | `AppInsightsLogger` → Azure Application Insights |
| **Telemetry** | Basic | `TelemetryClient` for traces, exceptions, requests |
| **UI Analytics** | Configured | `@microsoft/applicationinsights-web` + `applicationinsights-react-js` |
| **Code Quality** | Configured | SonarQube with `sonar-project.properties` |
| **Test Coverage** | Configured | Jest with coverage reports (lcov, cobertura); SonarQube integration |
| **Structured Logging** | No | String-based log messages, not structured |
| **Distributed Tracing** | No | No correlation IDs |
| **Health Checks** | No | No health check endpoints |
| **Dashboards** | Unknown | No evidence of App Insights dashboards/alerts |

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 12.1 | No structured logging (using string interpolation) | Hard to query/filter logs | Use Serilog with structured properties |
| 12.2 | No correlation ID propagation | Cannot trace requests across layers | Add correlation ID middleware |
| 12.3 | No health check endpoints | Cannot detect unhealthy instances | Add health checks for DB, external services |
| 12.4 | No SLA monitoring/alerting | Silent failures | Configure App Insights alerts for error rates, latency |
| 12.5 | `TelemetryConfiguration` created manually (not via DI) | Missing auto-collected telemetry | Use `AddApplicationInsightsTelemetry()` |

**Score: 2/5** | **Risk Level: High**

---

## 13. Deployment & DevOps

### Current State

| Aspect | Status | Details |
|---|---|---|
| **Backend Containerization** | Dockerfile | Multi-stage build (.NET 9 SDK → Runtime) |
| **UI Hosting** | Nginx | Static file serving with gzip, SPA fallback |
| **CI/CD** | Azure DevOps (inferred) | NuGet feed on Azure DevOps, SonarQube integration |
| **Build Tool (UI)** | Create React App (react-scripts 5.0.1) | Standard CRA build pipeline |
| **Code Quality Gate** | SonarQube | Quality gate enabled (`sonar.qualitygate.wait=true`) |
| **Test Automation** | Jest (UI), xUnit (Backend inferred) | Coverage reports in multiple formats |

### Dockerfile Issues
```dockerfile
# Line 18 references non-existent project:
COPY ["Carecoordination.Infrastructure/Carecoordination.Infrastructure.csproj", ...]
# Actual projects: CareCoordination.DAL, CareCoordination.Services
```

### Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 13.1 | Dockerfile is out of sync with project structure | Build failures | Update Dockerfile to match current projects |
| 13.2 | No docker-compose for local development | Developer friction | Add docker-compose with API + SQL Server |
| 13.3 | No Kubernetes/container orchestration manifests | Cannot auto-scale | Add K8s manifests or Azure Container Apps config |
| 13.4 | No canary/blue-green deployment config | Risky deployments | Configure staged rollouts |
| 13.5 | Base image uses `dotnet/runtime` instead of `dotnet/aspnet` | **API won't run** - missing ASP.NET runtime | Change to `mcr.microsoft.com/dotnet/aspnet:9.0` |
| 13.6 | CRA is in maintenance mode | Future tech debt | Plan migration to Vite |

**Score: 2/5** | **Risk Level: High**

---

## 14. Cost Awareness

| Aspect | Current State | Observation |
|---|---|---|
| **Cloud Platform** | Azure | App Insights, APIM, DevOps |
| **Compute** | Docker containers (likely Azure App Service or AKS) | No auto-scale limits defined |
| **Database** | SQL Server (likely Azure SQL) | Two databases (PreAuthin, OAOData) |
| **External APIs** | Azure APIM with subscription keys | APIM costs scale with call volume |
| **Monitoring** | Application Insights | Data ingestion costs scale with telemetry volume |
| **Storage** | Object Valet for documents | Document storage grows over time |

### Gaps & Recommendations
| # | Gap | Recommendation |
|---|---|---|
| 14.1 | No auto-scale limits documented | Define min/max instances and scale triggers |
| 14.2 | No data retention/archival policy | Archive old case data to reduce storage costs |
| 14.3 | App Insights may over-log | Configure sampling to control telemetry costs |

**Score: 3/5** | **Risk Level: Medium**

---

## 15. Evolution & Future Proofing

### Current Extensibility Assessment

| Aspect | Status |
|---|---|
| **API Versioning** | Not implemented - routes are `api/[controller]` |
| **Feature Flags** | Not implemented |
| **Plugin Architecture** | Not implemented |
| **Schema Migrations** | Not implemented (no migration framework) |
| **UI Module Federation** | Not implemented (single SPA) |

### Recommendations
| # | Recommendation | Priority |
|---|---|---|
| 15.1 | Add API versioning (`api/v1/...`) | P1 |
| 15.2 | Add database migration framework | P1 |
| 15.3 | Plan CRA → Vite migration | P2 |
| 15.4 | Consider micro-frontend architecture as features grow | P3 |
| 15.5 | Add feature flags for gradual rollouts | P2 |

**Score: 2/5** | **Risk Level: Medium**

---

## 16. UI-Specific Architecture Analysis

### Tech Stack Summary

| Technology | Version | Purpose |
|---|---|---|
| React | 18.3.1 | UI framework |
| TypeScript | 4.9.5 | Type safety |
| Redux Toolkit | 2.5.0 | State management |
| React Router | 6.30.3 | Client-side routing |
| Axios | 1.13.2 | HTTP client |
| Bootstrap 5 + React Bootstrap | 5.3.3 / 2.10.7 | UI component library |
| Formik + Yup | 2.4.6 / 1.6.1 | Form management & validation |
| Styled Components | 6.1.14 | CSS-in-JS styling |
| React Table | 7.8.0 | Data tables |
| React Toastify | 11.0.2 | Toast notifications |
| Moment.js | 2.30.1 | Date handling |
| XLSX | 0.18.5 | Excel export |
| Application Insights | 3.3.4 | Telemetry |

### State Management Architecture
```
Redux Store
├── auth (authSlice) → User info, tokens
├── request (requestSlice) → Request data
└── restricted (restrictedReducer) → Permission state

State Persistence: localStorage (via saveState/loadState)
```

### UI Gaps & Recommendations
| # | Gap | Risk | Recommendation |
|---|---|---|---|
| 16.1 | `moment.js` is in maintenance mode (large bundle) | Bundle size | Migrate to `date-fns` or `dayjs` |
| 16.2 | `react-table` v7 is legacy | No updates | Migrate to `@tanstack/react-table` v8 |
| 16.3 | Mixed styling: CSS Modules + Styled Components + Bootstrap | Inconsistency | Standardize on one approach |
| 16.4 | `noImplicitAny: false` in tsconfig | Reduced type safety | Enable `noImplicitAny: true` |
| 16.5 | State persisted to localStorage (sensitive data risk) | Security | Encrypt or limit persisted state |
| 16.6 | No lazy loading / code splitting for routes | Larger initial bundle | Add `React.lazy()` for route-level splitting |
| 16.7 | No error handling in API service layer | Silent failures | Add Axios interceptors for global error handling |

**Score: 3/5** | **Risk Level: Medium**

---

## Overall System Design Scorecard

| # | Category | Score (1-5) | Risk Level | Priority |
|---|---|---|---|---|
| 1 | Vision & Business Understanding | 3 | Medium | - |
| 2 | Requirements | 3 | Medium | P2 |
| 3 | Constraints | 3 | Medium | - |
| 4 | Risk Identification | 2 | High | P0 |
| 5 | Architecture Style | 4 | Low | - |
| 6 | High-Level Component Design | 3 | Medium | P2 |
| 7 | Data Architecture | 2 | High | P1 |
| 8 | Integration & Communication | 2 | High | P1 |
| 9 | Scaling Strategy | 2 | High | P2 |
| 10 | Failure & Resilience | 1 | **Critical** | **P0** |
| 11 | Security | 3 | High | **P0** |
| 12 | Observability | 2 | High | P1 |
| 13 | Deployment & DevOps | 2 | High | P1 |
| 14 | Cost Awareness | 3 | Medium | P2 |
| 15 | Evolution & Future Proofing | 2 | Medium | P2 |
| 16 | UI Architecture | 3 | Medium | P2 |
| | **Overall Average** | **2.5** | **High** | |

---

## Prioritized Action Plan

### P0 - Critical (Immediate)
1. **Remove hardcoded API key** from `appsettings.json` → Azure Key Vault
2. **Fix Dockerfile** - change base image from `dotnet/runtime` to `dotnet/aspnet`; update project references
3. **Add global exception handling middleware** - stop exposing exception messages to clients
4. **Fix dead code** - remove unreachable `throw` after `return` in controllers
5. **Implement proper role checks** - `allowedRoles={['']}` effectively bypasses authorization

### P1 - High (Next Sprint)
6. Add **Polly resilience policies** (retry, circuit breaker, timeout) for all external HTTP calls
7. Add **health check endpoints** (`/health`, `/health/ready`)
8. Switch token storage from **localStorage to httpOnly cookies**
9. Enable **JWT Issuer/Audience validation**
10. Add **structured logging** (Serilog) with correlation IDs
11. Add **database migration framework** (DbUp or FluentMigrator)
12. Fix **duplicate DI registrations** (IUserManagement, ITokenManagement)
13. Add **HIPAA audit logging** for sensitive operations

### P2 - Medium (Next Quarter)
14. Add **API versioning** (`api/v1/...`)
15. Add **rate limiting** middleware
16. Add **Redis distributed cache** (replace in-memory cache)
17. Add **response caching** for lookup/reference data APIs
18. Implement **React lazy loading** for route-level code splitting
19. Migrate from **Moment.js to date-fns**
20. Migrate from **react-table v7 to @tanstack/react-table v8**
21. Standardize **CSS approach** (pick one: CSS Modules or Styled Components)
22. Enable **TypeScript strict mode** (`noImplicitAny: true`)
23. Add **docker-compose** for local development
24. Plan **CRA to Vite** migration

### P3 - Low (Future)
25. Plan migration of **SOAP/WCF GeneralDataService** to REST
26. Evaluate **micro-frontend** architecture for UI scalability
27. Add **feature flags** for gradual rollouts
28. Configure **Kubernetes manifests** for auto-scaling
29. Implement **data archival/retention** policies

---

## Architect Communication Summary

> Based on the healthcare compliance requirements, team structure, and current application scope, the **layered monolith architecture is appropriate** for CareCoordination.
>
> The system has a **solid architectural foundation** (clean layered design, proper DI, separation of concerns) but has **critical gaps in resilience, security hygiene, and operational readiness** that must be addressed before scaling.
>
> **Immediate priorities** are: fixing security issues (hardcoded keys, token storage), adding resilience patterns (circuit breakers, retry), and improving error handling (global exception middleware).
>
> If the application grows in scope or traffic, the architecture can evolve toward a **modular monolith** and eventually extract high-traffic modules (e.g., Dashboard, Request Search) into separate services.

---

*Report generated based on static codebase analysis. Runtime behavior, performance benchmarks, and infrastructure configuration may reveal additional findings.*
