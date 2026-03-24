# CLAUDE.md — Master Instruction File
> Autonomous development instructions derived from this repository's architecture, patterns, and preferences.
> All instruction files in this folder are authoritative. Read them before writing any code.

---

## Instruction Files Index

| File | Purpose |
|------|---------|
| [01-architecture.md](01-architecture.md) | Clean Architecture layers, DDD, CQRS, project structure |
| [02-csharp-coding-style.md](02-csharp-coding-style.md) | C# naming, comments, patterns, record types, async |
| [03-api-development.md](03-api-development.md) | ASP.NET Core Minimal APIs, endpoints, middleware, HTTP results |
| [04-angular-frontend.md](04-angular-frontend.md) | Angular components, signals, RxJS, guards, HTTP client |
| [05-azure-services.md](05-azure-services.md) | Azure Functions, Service Bus, AKS, Cosmos DB, Key Vault |
| [06-testing-quality.md](06-testing-quality.md) | xUnit, integration tests, test architecture, mocking rules |
| [07-security-patterns.md](07-security-patterns.md) | Auth, HMAC, secrets, input validation, OWASP |
| [08-observability.md](08-observability.md) | Structured logging, metrics, Application Insights, health checks |
| [09-docker-kubernetes.md](09-docker-kubernetes.md) | Dockerfiles, multi-stage builds, K8s manifests, Helm |
| [10-data-patterns.md](10-data-patterns.md) | EF Core, repository pattern, Cosmos DB, migrations, LINQ |
| [11-reactjs-patterns.md](11-reactjs-patterns.md) | React components, hooks, Redux Toolkit, error boundaries, code splitting |
| [12-resilience-patterns.md](12-resilience-patterns.md) | Polly retry/circuit breaker, fallback, outbox, bulkhead, Saga |
| [13-scalability-availability.md](13-scalability-availability.md) | Stateless design, caching tiers, DB read replicas, multi-region, SLA |
| [14-performance-patterns.md](14-performance-patterns.md) | Parallel calls, EF projections, Span/ArrayPool, output cache, virtual scroll |

---

## Non-Negotiable Rules (apply everywhere)

1. **Inline WHY comments** on every non-obvious decision — never "what", always "why"
2. **ASCII separators** to visually group related code blocks (`// ── Section ───────`)
3. **Mental model analogy** at the top of every new concept block
4. **Record types** for all DTOs — immutable by default
5. **Interfaces for every abstraction** — never depend on a concrete class across layers
6. **Async-first** — `Task`/`ValueTask` everywhere I/O happens; never `.Result` or `.Wait()`
7. **Security-first** — mask secrets, validate inputs at boundaries, never leak internals in errors
8. **No magic strings** — constants, enums, or strongly-typed options for all config keys
9. **Fail fast, fail loud** — validate at entry points; throw domain exceptions deep inside
10. **Read the relevant instruction file before generating code for that concern**

---

## Tech Stack Defaults

| Layer | Technology |
|-------|-----------|
| Backend API | ASP.NET Core 10 Minimal APIs |
| Language | C# 12+ with nullable reference types enabled |
| DI Container | Microsoft.Extensions.DependencyInjection (built-in) |
| ORM | Entity Framework Core 9 |
| Testing | xUnit + FluentAssertions + Testcontainers |
| Frontend | Angular 18+ (standalone components, signals) |
| Containerization | Docker multi-stage + Kubernetes (AKS) |
| Cloud | Azure (Functions, Service Bus, Cosmos DB, Key Vault, AKS) |
| IaC | Bicep (primary) / Terraform (multi-cloud) |
| Observability | ILogger<T> + Application Insights + OpenTelemetry |
| Messaging | Azure Service Bus (enterprise) / Azure Storage Queue (simple) |
