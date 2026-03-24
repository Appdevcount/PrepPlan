# HOW TO USE — Claude Instruction Files with Claude Code

> This guide explains exactly how these instruction files work inside Claude Code CLI,
> step by step — from first setup to advanced autonomous development sessions.

---

## What Is CLAUDE.md and Why It Exists

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Without CLAUDE.md                  │  With CLAUDE.md                        │
├──────────────────────────────────────────────────────────────────────────────┤
│  Every session starts cold           │  Every session starts knowing your     │
│  Claude asks about your stack        │  entire stack, patterns, and rules     │
│  Repeats same decisions              │  Follows your standards consistently   │
│  Generic code style                  │  Your exact style (WHY comments, etc.) │
│  You re-explain context each time    │  Zero re-explanation needed            │
└──────────────────────────────────────────────────────────────────────────────┘

CLAUDE.md = a persistent briefing document that Claude reads at the start of
every session. It's the difference between hiring a developer on Day 1
vs Day 100 — Day 100 Claude knows your whole codebase, your style, your rules.
```

---

## Step 1 — How Claude Code Discovers Instruction Files

When you run `claude` in a directory, it automatically loads instruction files in this order:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  LOAD ORDER (all accumulate — none override each other)                      │
├──────────┬───────────────────────────────────────────────────────────────────┤
│  Priority│  Location                        │  Who sets it                  │
├──────────┼──────────────────────────────────┼───────────────────────────────┤
│  1 (low) │  ~/.claude/CLAUDE.md             │  YOU — personal preferences   │
│          │  (global, all projects)          │  not committed to git         │
├──────────┼──────────────────────────────────┼───────────────────────────────┤
│  2       │  ./CLAUDE.md                     │  TEAM — committed to git      │
│          │  (project root)                  │  applies to all contributors  │
├──────────┼──────────────────────────────────┼───────────────────────────────┤
│  3       │  ./.claude/CLAUDE.md             │  TEAM — alternative location  │
│          │  (project .claude folder)        │                               │
├──────────┼──────────────────────────────────┼───────────────────────────────┤
│  4       │  sub-folder CLAUDE.md files      │  TEAM — per-module rules      │
│          │  (lazy-loaded when files opened) │                               │
├──────────┼──────────────────────────────────┼───────────────────────────────┤
│  5 (high)│  /etc/claude-code/CLAUDE.md      │  ADMIN — org policy           │
│          │  (Windows: C:\Program Files\...) │  cannot be excluded           │
└──────────┴──────────────────────────────────┴───────────────────────────────┘

IMPORTANT: All files ACCUMULATE — they don't override each other.
           A sub-folder CLAUDE.md adds to the parent's rules, not replaces them.
```

### How it walks the directory tree

```
You run: claude  (from e:\repos\...\PrepPlan)
                        │
                        ▼
         Walks UP the tree looking for CLAUDE.md:
         e:\repos\...\PrepPlan\CLAUDE.md           ← loads if exists
         e:\repos\...\ReposOfReferemce\CLAUDE.md   ← loads if exists
         e:\repos\CLAUDE.md                        ← loads if exists
                        │
                        ▼
         Also scans DOWN for CLAUDE.md in sub-folders:
         (these load ON DEMAND when you open files in those folders)
         PrepPlan\claude-instructions\CLAUDE.md    ← loads when you work here
         PrepPlan\Daywise\CLAUDE.md                ← loads when you work here
```

---

## Step 2 — Using @import to Reference These Instruction Files

The `@` syntax inside any CLAUDE.md imports another file's content directly.

```markdown
<!-- In your project root CLAUDE.md -->

# My Project

@claude-instructions/CLAUDE.md
```

That single line tells Claude: **read the entire claude-instructions/CLAUDE.md** and treat it as part of this document. Then THAT file references all 14 instruction files.

### Setting up the project root CLAUDE.md right now

Create this file at the root of your PrepPlan repo:

```bash
# File: e:\repos\Citiustech Evicore TechStack\ReposOfReferemce\PrepPlan\CLAUDE.md
```

```markdown
# PrepPlan — Enterprise Development Instructions

@claude-instructions/CLAUDE.md
```

That's it. Two lines. Claude will load all 14 instruction files automatically.

### Import rules to know

```
@relative/path/to/file.md          ← relative to the file containing the @
@/absolute/path/to/file.md         ← absolute path
@~/path/relative/to/home.md        ← from your home directory
@README.md                         ← works for any file, not just .md
@package.json                      ← Claude will read your package.json too

Depth limit: imports can chain up to 5 levels deep
On first use: Claude asks your permission before loading external @imports
```

---

## Step 3 — Starting a Claude Code Session (Step by Step)

### Option A — Start from the project folder

```bash
# Navigate to your project
cd "e:\repos\Citiustech Evicore TechStack\ReposOfReferemce\PrepPlan"

# Start Claude Code
claude
```

Claude automatically loads:
1. Your `CLAUDE.md` at the root (which @imports all instruction files)
2. All 14 instruction files are now in Claude's context
3. Claude knows your entire stack, patterns, naming conventions, and rules

### Option B — Start in a sub-folder (still loads parent CLAUDE.md)

```bash
cd "PrepPlan\Daywise\Azure Services\SimpleApi1"
claude
# Claude walks UP and finds PrepPlan\CLAUDE.md → loads everything
```

### Option C — VS Code Extension (current setup)

You're already in the VS Code extension. The CLAUDE.md at the workspace root is loaded automatically when you open a Claude Code session inside that workspace.

### What Claude sees at session start

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Session Start — Context Claude Has Loaded                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│  ✅ Tech stack (ASP.NET Core 10, Angular 18, EF Core 9, Azure)               │
│  ✅ Folder structure expectations (Domain/Application/Infrastructure/Api)    │
│  ✅ C# naming rules (PascalCase, _camelCase, Async suffix, etc.)             │
│  ✅ Comment style (WHY comments, ASCII separators)                           │
│  ✅ Record types for DTOs, interfaces for every abstraction                  │
│  ✅ API patterns (Minimal APIs, endpoint groups, HTTP result conventions)    │
│  ✅ Angular patterns (signals, OnPush, standalone, toSignal)                 │
│  ✅ Azure service patterns (Service Bus, Key Vault managed identity, etc.)   │
│  ✅ Testing rules (xUnit, Testcontainers, builder pattern, no mock DB)       │
│  ✅ Security rules (HMAC, JWT, never expose stack traces, etc.)              │
│  ✅ Resilience patterns (Polly, Outbox, Saga, Circuit Breaker)               │
│  ✅ Performance patterns (Task.WhenAll, EF projections, Span<T>)             │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 4 — How to Talk to Claude Once Instructions Are Loaded

You don't need to repeat any context. Claude already knows it all. Just give the task.

### Examples of how to ask

```
❌ VERBOSE (unnecessary — Claude already knows this):
"Please create a new ASP.NET Core Minimal API endpoint using Clean Architecture
 with a MediatR command handler, FluentValidation, using record types for DTOs,
 following the repository pattern, with WHY inline comments and ASCII separators..."

✅ CONCISE (Claude reads the instruction files, knows all of this):
"Add a POST /api/v1/invoices endpoint that creates an invoice from an order"

✅ CONCISE:
"Add an Angular component for the invoice list with pagination and loading state"

✅ CONCISE:
"Add resilience to the PaymentGateway HTTP client"

✅ CONCISE:
"Write xUnit tests for the CreateInvoiceCommandHandler"
```

Claude will automatically:
- Use the correct project structure from `01-architecture.md`
- Apply WHY comments and ASCII separators from `02-csharp-coding-style.md`
- Use the correct HTTP result conventions from `03-api-development.md`
- Apply signals and OnPush from `04-angular-frontend.md`
- Use Polly retry + circuit breaker from `12-resilience-patterns.md`
- Use Testcontainers and builder pattern from `06-testing-quality.md`

---

## Step 5 — Telling Claude Which Instruction File to Reference

When you want Claude to apply a specific set of rules, you can reference the file directly:

```
"Following 03-api-development.md, add rate limiting to the orders endpoint group"

"Use the outbox pattern from 12-resilience-patterns.md for order event publishing"

"Apply the three-state signal pattern from 04-angular-frontend.md to this component"

"Use the cursor-based pagination from 10-data-patterns.md for this query"
```

---

## Step 6 — Adding Your Own Instruction File

When you establish a new pattern, create a new instruction file:

```
1. Create the file in claude-instructions/
   e.g.: claude-instructions/15-stripe-integration.md

2. Add it to the index in CLAUDE.md:
   | [15-stripe-integration.md](15-stripe-integration.md) | Stripe webhook, payment intents, refund patterns |

3. Done. Next Claude session will automatically have it.
```

### File format to follow

```markdown
# NN — Topic Name

> **Mental Model:** One-sentence analogy that makes the concept click.

---

## Section Title

// ── ASCII separator comment ───────────────────────────────────────────────────
// WHY: explain the reason, not the what
// Mental Model: analogy specific to this code block

code examples...

---

## Decision Table

| When | Use |
|------|-----|
| ... | ... |
```

---

## Step 7 — /init Command (Auto-Generate CLAUDE.md for a New Project)

If you start a brand new project and want Claude to auto-detect its patterns:

```bash
cd /path/to/new-project
claude
/init
```

Claude Code will:
1. Scan your project structure (package.json, csproj, folders)
2. Detect build commands, test commands, language
3. Generate a starter CLAUDE.md
4. Ask you to review before writing

Then you can manually add `@claude-instructions/CLAUDE.md` to import your standards.

---

## Step 8 — Autonomous Development Mode

For longer autonomous tasks, give Claude a clear goal with context:

```
"Scaffold a new Orders feature following the instruction files:
 - Create Domain/Application/Infrastructure/Api layers per 01-architecture.md
 - .NET 10 Minimal API per 03-api-development.md
 - EF Core repository per 10-data-patterns.md
 - xUnit tests per 06-testing-quality.md
 - Service Bus integration per 05-azure-services.md

 Feature: Customer can place an order with multiple line items.
 Order goes to 'Draft' → 'Confirmed' → 'Shipped' states.
 On confirmation, publish OrderConfirmed event to Service Bus."
```

Claude will work through this autonomously, referencing the correct instruction file for each layer.

---

## Step 9 — File Size Rules (Keep Instructions Effective)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  WHY size matters: CLAUDE.md is loaded into the context window at session    │
│  start. Large files = fewer tokens left for your actual code and conversation│
│                                                                              │
│  Rule: Keep CLAUDE.md (the master index) under 200 lines.                   │
│        Individual instruction files can be longer (each is loaded on demand  │
│        via @import, not all upfront).                                        │
│                                                                              │
│  Current setup:                                                              │
│    CLAUDE.md (index)      ← ~60 lines ✅ loaded at session start            │
│    01-architecture.md     ← loaded when @imported                           │
│    02-csharp-coding.md    ← loaded when @imported                           │
│    ...etc.                ← each file consulted as needed                   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 10 — Folder Structure Summary

```
PrepPlan/
├── CLAUDE.md                          ← CREATE THIS: @imports the index below
│
└── claude-instructions/
    ├── CLAUDE.md                      ← Master index + 10 non-negotiable rules
    ├── HOW-TO-USE.md                  ← This file
    │
    ├── 01-architecture.md             ← Clean Architecture, DDD, CQRS, structure
    ├── 02-csharp-coding-style.md      ← Naming, comments, async, patterns
    ├── 03-api-development.md          ← Minimal APIs, middleware, HTTP results
    ├── 04-angular-frontend.md         ← Signals, RxJS, guards, interceptors
    ├── 05-azure-services.md           ← Service Bus, Functions, Key Vault, Cosmos
    ├── 06-testing-quality.md          ← xUnit, Testcontainers, WebApplicationFactory
    ├── 07-security-patterns.md        ← JWT, HMAC, CORS, secrets, headers
    ├── 08-observability.md            ← Logging, OpenTelemetry, KQL queries
    ├── 09-docker-kubernetes.md        ← Dockerfile, K8s manifests, HPA
    ├── 10-data-patterns.md            ← EF Core, repositories, migrations, LINQ
    ├── 11-reactjs-patterns.md         ← React hooks, Redux Toolkit, error boundaries
    ├── 12-resilience-patterns.md      ← Polly, outbox, saga, bulkhead, circuit breaker
    ├── 13-scalability-availability.md ← Caching, stateless design, multi-region, SLA
    └── 14-performance-patterns.md     ← Parallel calls, Span<T>, output cache, profiling
```

---

## Quick Reference — Common Tasks

| Task | Say to Claude |
|------|--------------|
| New .NET feature end-to-end | "Scaffold [Feature] following the instruction files" |
| New Angular component | "Add [Name] component with signals and OnPush" |
| Add HTTP resilience | "Add Polly resilience to [ServiceClient]" |
| Write tests | "Write xUnit tests for [Handler/Service]" |
| Add observability | "Add structured logging and custom metrics to [Service]" |
| New Azure Function | "Add a Service Bus triggered Function for [purpose]" |
| Dockerfile for new service | "Create a multi-stage Dockerfile for [Project]" |
| Add caching | "Add Redis cache-aside pattern to [Service]" |
| Fix performance | "Profile and optimise [endpoint/query]" |
| Add auth | "Add JWT auth + role-based policy to [endpoint group]" |

---

---

## Worked Example A — Build an Enterprise .NET API from Scratch

> **Scenario:** Build a `PatientReferral` API — patients are referred by doctors to specialists.

### Phase 1 — Scaffold the solution structure

**Prompt to Claude:**
```
Scaffold a new .NET 10 solution called PatientReferral.
Follow 01-architecture.md for the folder and project structure.
Domain: a Doctor refers a Patient to a Specialist.
Referral has states: Submitted → Accepted → Completed | Rejected.
```

**What Claude does using the instruction files:**

```
01-architecture.md  →  Creates 4 projects:
                        PatientReferral.Domain/
                        PatientReferral.Application/
                        PatientReferral.Infrastructure/
                        PatientReferral.Api/
                        tests/ (4 test projects)

01-architecture.md  →  Domain layer:
                        Entities/Referral.cs          (AggregateRoot)
                        Entities/Doctor.cs
                        ValueObjects/ReferralId.cs    (strongly-typed ID)
                        ValueObjects/SpecialtyCode.cs
                        Events/ReferralSubmitted.cs   (domain event)
                        Exceptions/ReferralNotFoundException.cs
                        Interfaces/IReferralRepository.cs

02-csharp-coding-style.md → All files use:
                        record types for DTOs
                        _camelCase private fields
                        WHY comments on every non-obvious line
                        ASCII section separators
```

---

### Phase 2 — Add the Application layer (CQRS)

**Prompt to Claude:**
```
Add the CQRS command and query handlers for:
  - SubmitReferral (command)
  - AcceptReferral (command)
  - GetReferralById (query)
  - GetReferralsByDoctor (query, paged)
Include FluentValidation and MediatR pipeline behaviors.
```

**What Claude does using the instruction files:**

```
01-architecture.md  →  Commands/ and Queries/ folder structure
                        SubmitReferral/
                          SubmitReferralCommand.cs       (record)
                          SubmitReferralCommandHandler.cs
                          SubmitReferralCommandValidator.cs
                        GetReferralsByDoctor/
                          GetReferralsByDoctorQuery.cs
                          GetReferralsByDoctorQueryHandler.cs

02-csharp-coding-style.md → Handlers use:
                        async Task<Result<ReferralId>> return type
                        CancellationToken on every method
                        WHY comments explaining each step

10-data-patterns.md  →  Query handler projects directly to DTO:
                        .Select(r => new ReferralSummaryDto(...))
                        No entity loading for read operations

06-testing-quality.md → Validator uses FluentValidation rules:
                        RuleFor(x => x.DoctorId).NotEmpty()
                        RuleFor(x => x.SpecialtyCode).MaximumLength(10)
```

---

### Phase 3 — Add the API layer

**Prompt to Claude:**
```
Add Minimal API endpoints for PatientReferral.
Group under /api/v1/referrals.
Include JWT auth, rate limiting, health checks, and correlation ID middleware.
```

**What Claude does using the instruction files:**

```
03-api-development.md →  Program.cs composition root pattern:
                          builder.Services
                            .AddApplicationServices(...)
                            .AddInfrastructureServices(...)
                            .AddApiServices(...)

                          Middleware order (correct):
                            UseExceptionHandler → UseHttpsRedirection
                            → UseCorrelationId → UseAuthentication
                            → UseAuthorization → UseRateLimiter

                          ReferralEndpoints.cs:
                            MapGroup("/referrals").WithTags("Referrals")
                            MapPost("", SubmitReferral)   → 201 Created
                            MapPut("{id}/accept", Accept) → 204 NoContent
                            MapGet("{id}", GetById)       → 200 | 404

07-security-patterns.md → JWT setup with ValidateLifetime=true, ClockSkew=0
                          FallbackPolicy = RequireAuthenticatedUser
                          "ReferralWrite" policy for POST/PUT

03-api-development.md → Health checks:
                          /health/live  (liveness — no deps)
                          /health/ready (readiness — DB + Redis)

08-observability.md  →  Correlation ID middleware wired
                         Serilog structured logging
                         App Insights telemetry
```

---

### Phase 4 — Add Infrastructure (EF Core + Service Bus)

**Prompt to Claude:**
```
Add EF Core infrastructure.
Add Service Bus publisher for ReferralSubmitted event using the outbox pattern.
Add Polly resilience to the SpecialistDirectory HTTP client.
```

**What Claude does using the instruction files:**

```
10-data-patterns.md  →  AppDbContext with:
                          ApplyConfigurationsFromAssembly()
                          SaveChangesAsync with audit intercept
                          Soft-delete global filter

                         ReferralConfiguration.cs:
                          HasConversion for ReferralId → Guid
                          OwnsOne for value objects
                          HasIndex on DoctorId and Status

05-azure-services.md →  Service Bus publisher:
                          MessageId = referralId (idempotent)
                          CorrelationId = Activity.Current?.Id

12-resilience-patterns.md → Outbox pattern:
                          OutboxMessage table
                          OutboxInterceptor on SaveChangesAsync
                          OutboxProcessor BackgroundService

12-resilience-patterns.md → Polly pipeline for SpecialistDirectory:
                          AddRetry (3 attempts, exponential+jitter)
                          AddCircuitBreaker (50% failure, 30s break)
                          AddTimeout (5s per call)
```

---

### Phase 5 — Add Tests

**Prompt to Claude:**
```
Write xUnit tests for:
  - Referral domain (state machine transitions)
  - SubmitReferralCommandHandler (mocked infra)
  - ReferralRepository (Testcontainers, real SQL Server)
  - POST /api/v1/referrals endpoint (WebApplicationFactory)
```

**What Claude does using the instruction files:**

```
06-testing-quality.md →  Domain tests (no mocks, pure):
                          Should_TransitionToAccepted_WhenReferralIsSubmitted()
                          Should_ThrowException_WhenAcceptingAlreadyRejectedReferral()
                          [Theory] with [InlineData] for invalid state transitions

                         Handler tests (mocked repos):
                          Mock<IReferralRepository>
                          Mock<IUnitOfWork>
                          Verify repo.AddAsync called once
                          Verify uow.SaveChangesAsync called once

                         Repository tests (Testcontainers):
                          MsSqlContainer spun up
                          Real EF Core migrations applied
                          Actual SQL persistence verified

                         API tests (WebApplicationFactory):
                          ApiTestFactory replaces DbContext with in-memory
                          POST /api/v1/referrals → asserts 201 + Location header
                          POST with empty DoctorId → asserts 400 + Errors["DoctorId"]
```

---

### Phase 6 — Containerise and Deploy

**Prompt to Claude:**
```
Add a Dockerfile for PatientReferral.Api.
Add Kubernetes manifests: Deployment, Service, Ingress, HPA.
Add a Bicep file for App Service Plan + Web App with managed identity.
```

**What Claude does using the instruction files:**

```
09-docker-kubernetes.md → Multi-stage Dockerfile:
                           Stage 1: sdk:10.0 — restore (cached layer), publish
                           Stage 2: aspnet:10.0 — non-root user, port 80

                          Deployment.yaml:
                           replicas: 3 (one per AZ)
                           topologySpreadConstraints
                           resources.requests + limits
                           livenessProbe /health/live
                           readinessProbe /health/ready
                           preStop sleep 5 + terminationGracePeriod: 30

                          HPA:
                           minReplicas: 3, maxReplicas: 20
                           CPU target: 70%
                           scaleDown stabilizationWindow: 300s

05-azure-services.md   → Bicep:
                           SystemAssigned managed identity
                           httpsOnly: true
                           Key Vault access policy (secrets: get, list)
                           No secrets in appSettings — all from Key Vault
```

---

### Complete Prompt Sequence Summary (Copy-Paste Ready)

```
Session start: open Claude Code in your solution folder. CLAUDE.md loads all instruction files.

Prompt 1:  "Scaffold a new .NET 10 solution called PatientReferral.
            Domain: Doctor refers Patient to Specialist.
            States: Submitted → Accepted → Completed | Rejected.
            Follow 01-architecture.md structure."

Prompt 2:  "Add CQRS handlers: SubmitReferral, AcceptReferral, GetReferralById,
            GetReferralsByDoctor (paged). Include FluentValidation pipeline."

Prompt 3:  "Add Minimal API endpoints under /api/v1/referrals.
            JWT auth, rate limiting, health checks, correlation ID."

Prompt 4:  "Add EF Core. Add outbox pattern for ReferralSubmitted event.
            Add Polly resilience to SpecialistDirectory HTTP client."

Prompt 5:  "Write xUnit tests: domain, handler (mocked), repository
            (Testcontainers), API (WebApplicationFactory)."

Prompt 6:  "Add Dockerfile, K8s manifests (Deployment, HPA), and Bicep."
```

---

## Worked Example B — Build an Enterprise React App from Scratch

> **Scenario:** Build a `ReferralPortal` — doctors submit and track patient referrals.

### Phase 1 — Scaffold the project structure

**Prompt to Claude:**
```
Scaffold a new React 18 + TypeScript app called ReferralPortal.
Follow 11-reactjs-patterns.md for the folder structure.
Features needed: auth (login), referral submission form, referral list, referral detail.
Use Redux Toolkit for state. React Router v6 for routing.
```

**What Claude does using the instruction files:**

```
11-reactjs-patterns.md →  Feature-based structure:
                            src/
                            ├── app/
                            │   ├── store/            (Redux store setup)
                            │   └── router/           (lazy-loaded routes)
                            ├── features/
                            │   ├── auth/
                            │   │   ├── components/   (LoginForm.tsx)
                            │   │   ├── hooks/        (useAuth.ts)
                            │   │   ├── store/        (authSlice.ts)
                            │   │   └── api/          (authApi.ts)
                            │   └── referrals/
                            │       ├── components/   (ReferralList, ReferralForm, ReferralDetail)
                            │       ├── hooks/        (useReferrals.ts, useReferralForm.ts)
                            │       ├── store/        (referralsSlice.ts)
                            │       └── api/          (referralsApi.ts)
                            └── shared/
                                ├── components/       (Spinner, ErrorBanner, Pagination)
                                └── hooks/            (useDebounce, useLocalStorage)
```

---

### Phase 2 — Auth feature

**Prompt to Claude:**
```
Add the auth feature.
LoginForm component, useAuth hook, authSlice with JWT storage,
axios interceptor that attaches Bearer token and handles 401 redirect.
```

**What Claude does using the instruction files:**

```
11-reactjs-patterns.md →  authSlice.ts:
                            createAsyncThunk('auth/login', ...)
                            State: { user, token, status: 'idle'|'loading'|'succeeded'|'failed' }
                            selectCurrentUser memoized selector (createSelector)

                          LoginForm.tsx:
                            Named export (not default)
                            TypeScript interface for props
                            useCallback for stable handleSubmit reference

                          useAuth.ts:
                            Encapsulates all auth logic
                            Returns { user, isAuthenticated, login, logout }

07-security-patterns.md →  Token stored in memory (not localStorage) for XSS safety
                            axios interceptor: attaches Authorization: Bearer {token}
                            401 interceptor: clears token, redirects to /login
                            returnUrl preserved in query string

11-reactjs-patterns.md →  ErrorBoundary wraps LoginForm:
                            Catches render errors, shows "Try again" fallback
```

---

### Phase 3 — Referral List with search, filter, pagination

**Prompt to Claude:**
```
Add ReferralList component.
Search by patient name (debounced 300ms).
Filter by status (Submitted/Accepted/Completed/Rejected).
Paginated — 20 per page. Loading and error states.
Use virtual scrolling for large lists.
```

**What Claude does using the instruction files:**

```
11-reactjs-patterns.md →  useReferrals.ts custom hook:
                            Accepts { search, status, page } options
                            useDebounce(searchTerm, 300) — prevents API call per keystroke
                            useCallback for fetchReferrals (stable dep for useEffect)
                            Returns { referrals, isLoading, isError, error, totalCount }

                          referralsSlice.ts:
                            createAsyncThunk('referrals/fetchAll', ...)
                            Discriminated union state (idle|loading|succeeded|failed)
                            selectFilteredReferrals = createSelector (memoized filter)

                          ReferralList.tsx:
                            React.memo — prevents full list re-render on parent state change
                            useCallback for onSelect handler (stable ref for memoized rows)
                            react-window FixedSizeList for virtual scrolling

14-performance-patterns.md → Virtual scroll: only visible rows rendered
                               Even 10,000 referrals = smooth scroll, no DOM bloat

11-reactjs-patterns.md →  Code splitting:
                            const ReferralList = lazy(() => import('./ReferralList'))
                            Wrapped in <Suspense fallback={<Spinner />}>
```

---

### Phase 4 — Referral Submission Form

**Prompt to Claude:**
```
Add ReferralForm component.
Fields: patientName, patientDOB, doctorId (dropdown), specialtyCode (dropdown), urgency, notes.
Validate: all required except notes. patientDOB must be in the past.
Prevent double-submit. Show inline field errors.
On success navigate to referral detail page.
```

**What Claude does using the instruction files:**

```
11-reactjs-patterns.md →  useReferralForm.ts:
                            React Hook Form (or controlled form with useState)
                            Yup/Zod schema validation
                            submitting state (signal-equivalent: useState<boolean>)
                            submitError state

                          ReferralForm.tsx:
                            exhaustMap equivalent: disable submit button while submitting
                            WHY: prevents duplicate submissions (double-click = 2 API calls)
                            onSubmit calls dispatch(submitReferral(formData))
                            On fulfilled: navigate(`/referrals/${id}`)
                            On rejected: show submitError banner

11-reactjs-patterns.md →  ErrorBoundary wraps the form section
                            Compound Tabs component for multi-step form (if needed)

14-performance-patterns.md → useMemo for expensive dropdown options list
                               (transforms raw specialties array → select options)
                               Recomputes only when specialties array reference changes
```

---

### Phase 5 — API Layer (axios service)

**Prompt to Claude:**
```
Add the referrals API service.
All HTTP calls go through a typed referralsApi object.
Handle errors centrally. Add retry logic for transient failures.
```

**What Claude does using the instruction files:**

```
11-reactjs-patterns.md →  referralsApi.ts:
                            Typed functions, not inline fetch in components
                            getAll(filter): Promise<PagedResult<ReferralSummary>>
                            getById(id): Promise<ReferralDetail>
                            submit(request): Promise<{ id: string }>

                          Axios instance (shared):
                            baseURL from env variable
                            authInterceptor attaches Bearer token
                            errorInterceptor handles 401/403/429/network errors
                            Returns clean Error, not AxiosError, to callers

12-resilience-patterns.md → axios-retry for transient failures:
                              3 retries, exponential backoff (200ms, 400ms, 800ms)
                              Only retry on 429, 502, 503, 504 and network errors
                              Not on 400, 401, 403, 404 (client errors — don't retry)

13-scalability-availability.md → Fallback:
                              If GET /referrals fails, show cached previous result
                              + "Showing cached data" banner
```

---

### Phase 6 — Performance, Error Boundaries, Lazy Loading

**Prompt to Claude:**
```
Add error boundaries around each feature section.
Lazy load all feature routes.
Add React.memo to ReferralRow.
Add performance profiling via React DevTools marks.
```

**What Claude does using the instruction files:**

```
11-reactjs-patterns.md →  ErrorBoundary class component:
                            getDerivedStateFromError → sets hasError state
                            componentDidCatch → logs to error tracking service
                            Nested boundaries: app-level + per-feature

                          Code splitting all routes:
                            const ReferralsPage = lazy(() => import('.../ReferralsPage'))
                            const AuthPage = lazy(() => import('.../AuthPage'))
                            <Suspense fallback={<PageLoadingSpinner />}> at router

                          React.memo on ReferralRow:
                            Prevents all 20 rows re-rendering when one is selected
                            useCallback on onSelect in parent — stable ref

14-performance-patterns.md → React.memo + useCallback rules:
                               Memo only list-item components in large lists
                               Don't add memo to every component (comparison has cost)
                               useMemo for expensive derive (sorted+filtered list)
```

---

### Complete Prompt Sequence Summary (Copy-Paste Ready)

```
Session start: open Claude Code in your React project folder. CLAUDE.md loads all instruction files.

Prompt 1:  "Scaffold a React 18 + TypeScript app called ReferralPortal.
            Feature-based structure per 11-reactjs-patterns.md.
            Features: auth, referral list, referral form, referral detail."

Prompt 2:  "Add auth feature: LoginForm, useAuth hook, authSlice,
            axios interceptor with 401 redirect. Follow 07-security-patterns.md for token storage."

Prompt 3:  "Add ReferralList: debounced search, status filter, pagination,
            virtual scrolling. Memoized selectors. Loading and error states."

Prompt 4:  "Add ReferralForm: all fields, validation, prevent double-submit,
            navigate to detail on success."

Prompt 5:  "Add referralsApi service with axios. Retry transient errors.
            Centralised error handling. Follow 12-resilience-patterns.md."

Prompt 6:  "Add ErrorBoundary per feature. Lazy load all routes.
            React.memo on ReferralRow. useMemo for filtered list."
```

---

## Side-by-Side Instruction File Usage

```
┌────────────────────────────────────┬──────────────────────────────────────────┐
│  .NET API Task                     │  Instruction File Used                   │
├────────────────────────────────────┼──────────────────────────────────────────┤
│  Folder structure                  │  01-architecture.md                      │
│  Naming, WHY comments, records     │  02-csharp-coding-style.md               │
│  Endpoints, middleware, HTTP codes │  03-api-development.md                   │
│  EF Core, repositories, migrations │  10-data-patterns.md                     │
│  Service Bus, Key Vault, Functions │  05-azure-services.md                    │
│  xUnit, Testcontainers, WebAppFac  │  06-testing-quality.md                   │
│  JWT, HMAC, secrets, CORS          │  07-security-patterns.md                 │
│  Logging, tracing, KQL             │  08-observability.md                     │
│  Dockerfile, K8s, HPA, Bicep       │  09-docker-kubernetes.md                 │
│  Polly, outbox, circuit breaker    │  12-resilience-patterns.md               │
│  Caching, read replicas, SLA       │  13-scalability-availability.md          │
│  Task.WhenAll, Span<T>, EF perf    │  14-performance-patterns.md              │
└────────────────────────────────────┴──────────────────────────────────────────┘

┌────────────────────────────────────┬──────────────────────────────────────────┐
│  React App Task                    │  Instruction File Used                   │
├────────────────────────────────────┼──────────────────────────────────────────┤
│  Folder structure                  │  11-reactjs-patterns.md                  │
│  Components, hooks, compound UI    │  11-reactjs-patterns.md                  │
│  Redux Toolkit, selectors, thunks  │  11-reactjs-patterns.md                  │
│  React.memo, useMemo, useCallback  │  11-reactjs-patterns.md + 14-perf        │
│  Error boundaries                  │  11-reactjs-patterns.md                  │
│  Code splitting, lazy loading      │  11-reactjs-patterns.md                  │
│  Token storage, axios interceptors │  07-security-patterns.md                 │
│  Retry, fallback, circuit breaker  │  12-resilience-patterns.md               │
│  Virtual scrolling, memo rules     │  14-performance-patterns.md              │
│  Caching, stateless patterns       │  13-scalability-availability.md          │
└────────────────────────────────────┴──────────────────────────────────────────┘
```

---

## Troubleshooting

```
Problem: Claude isn't following my instruction file patterns
Fix:     Reference the specific file explicitly:
         "Following 02-csharp-coding-style.md, rewrite this with proper WHY comments"

Problem: Claude seems to have forgotten context mid-session
Fix:     Context window is full. Start a new session.
         CLAUDE.md reloads fresh — no loss of rules.

Problem: Instructions conflict between files
Fix:     The more specific file wins. Reference it explicitly.
         Or add a clarifying rule to the relevant instruction file.

Problem: Claude generates code with wrong patterns
Fix:     Correct it once, then add the rule to the relevant instruction file
         so the next session starts with that correction baked in.

Problem: Want Claude to ignore instructions for one task
Fix:     "Ignore the instruction files for this — just [do X]"
```
