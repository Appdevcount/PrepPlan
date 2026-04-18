# Architecture Review Guidelines — Principal Engineer Perspective
> Deep expertise lens: Clean Architecture · DDD · CQRS · Azure · Microservices · Event-Driven · Resilience
> Use this as the canonical framework for architecture design reviews, RFC reviews, and technical debt assessments.

---

## Table of Contents

1. [Mental Model — What Architecture Review Is](#1-mental-model)
2. [Review Triggers & Cadence](#2-review-triggers)
3. [Dimension 1 — Structural Integrity (Clean Architecture)](#3-structural-integrity)
4. [Dimension 2 — Domain Model Quality (DDD)](#4-domain-model)
5. [Dimension 3 — CQRS & Messaging Patterns](#5-cqrs-messaging)
6. [Dimension 4 — Azure Infrastructure Design](#6-azure-infrastructure)
7. [Dimension 5 — Security Architecture](#7-security-architecture)
8. [Dimension 6 — Scalability & Performance Architecture](#8-scalability)
9. [Dimension 7 — Resilience & Fault Tolerance](#9-resilience)
10. [Dimension 8 — Observability Architecture](#10-observability)
11. [Dimension 9 — Data Architecture](#11-data-architecture)
12. [Dimension 10 — Deployment Architecture (CI/CD & AKS)](#12-deployment)
13. [Architecture Anti-Patterns Catalogue](#13-anti-patterns)
14. [Architecture Decision Record (ADR) Template](#14-adr-template)
15. [Architecture Review Scorecard](#15-scorecard)

---

## 1. Mental Model

```
┌─────────────────────────────────────────────────────────────────────┐
│  ARCHITECTURE REVIEW = FUTURE CHANGE COST ASSESSMENT               │
│                                                                     │
│  Good architecture is not about elegance — it is about:            │
│    • How cheaply can we add a new feature?                         │
│    • How quickly can we isolate a failing component?               │
│    • How safely can we scale one part without touching others?     │
│    • How easily can a new engineer understand the system?          │
│                                                                     │
│  Every architectural decision creates load-bearing walls.          │
│  Choose carefully — load-bearing walls are expensive to move.      │
└─────────────────────────────────────────────────────────────────────┘
```

**The 3 questions every architecture must answer clearly:**
1. **What is the separation of concerns?** — Which layer owns which responsibility?
2. **What are the failure modes?** — How does each dependency fail, and how does the system respond?
3. **What is the data contract?** — How does data flow between systems, and who owns the schema?

---

## 2. Review Triggers & Cadence

```
┌──────────────────────────────────────────────────────────────────────┐
│ WHEN TO TRIGGER AN ARCHITECTURE REVIEW                               │
├──────────────────────────────────────────────────────────────────────┤
│ Mandatory                                                            │
│  • New service / microservice being created                          │
│  • New external dependency being added (third-party API, vendor SDK) │
│  • Cross-cutting change affecting > 2 services                       │
│  • Change to authentication / authorization model                    │
│  • Change to data ownership / database schema shared across services │
│  • Addition of new infrastructure (new AKS namespace, new ASB topic) │
│  • Change to CI/CD pipeline that affects production deployments      │
│                                                                      │
│ Recommended                                                          │
│  • Any RFC (Request for Comment) document                            │
│  • Quarterly architecture health check                               │
│  • Performance-driven refactors above a certain scale               │
└──────────────────────────────────────────────────────────────────────┘
```

**Review artefacts required:**
- Architecture diagram (C4 Level 1 + Level 2 minimum)
- Data flow diagram for cross-service communication
- ADR (Architecture Decision Record) for each non-obvious choice
- Non-functional requirements (NFRs): latency SLOs, throughput targets, availability targets

---

## 3. Dimension 1 — Structural Integrity (Clean Architecture)

// ── Layer Isolation · Dependency Direction ──────────────────────

### The Dependency Rule

```
┌──────────────────────────────────────────────────────────────────┐
│                     Dependency Direction                         │
│                                                                  │
│   Presentation / API  →  Application  →  Domain                 │
│                                   ↑                             │
│                          Infrastructure                         │
│                                                                  │
│  Rule: ALL arrows point INWARD. Domain knows nothing about       │
│  anything outside it. Infrastructure implements interfaces       │
│  defined in Domain or Application.                              │
└──────────────────────────────────────────────────────────────────┘
```

### Review Checklist

**Project Structure**
- [ ] Does the solution have distinct projects per layer? (`Domain`, `Application`, `Infrastructure`, `API`)
- [ ] Does the `Domain` project have zero references to NuGet packages (no EF Core, no ASP.NET)?
- [ ] Does the `Application` project reference only `Domain` — never `Infrastructure`?
- [ ] Does the `Infrastructure` project implement interfaces defined in `Domain`/`Application`?
- [ ] Does the `API` project compose everything via DI — never calling infrastructure directly?

**Boundary Enforcement**
- [ ] Are there no circular project references?
- [ ] Are there no domain objects being passed into API response models (DTO mapping present)?
- [ ] Are there no infrastructure types (EF `DbContext`, Azure SDK clients) in `Application` or `Domain`?

**Common Violations**

```
❌ VIOLATION: Application service directly instantiates infrastructure
   OrderService (Application) → new SqlOrderRepository() [Infrastructure]

✅ CORRECT: Application depends on interface; infrastructure registered in DI
   OrderService (Application) → IOrderRepository [Domain interface]
   SqlOrderRepository (Infrastructure) → implements IOrderRepository

❌ VIOLATION: Domain entity has EF Core data annotations
   public class Order { [Key] public int Id; [Required] public string Name; }

✅ CORRECT: EF configuration isolated in infrastructure
   class OrderConfiguration : IEntityTypeConfiguration<Order> { ... }
   // WHY: Domain model must remain persistence-ignorant for portability

❌ VIOLATION: Controller calls repository directly, bypassing application layer
   OrderController → _orderRepository.GetByIdAsync(id)

✅ CORRECT: Controller calls mediator or application service
   OrderController → _mediator.Send(new GetOrderQuery(id))
```

---

## 4. Dimension 2 — Domain Model Quality (DDD)

// ── Aggregates · Value Objects · Domain Events · Bounded Contexts

### Checklist

**Aggregates**
- [ ] Is each aggregate root identified and enforcing its own invariants?
- [ ] Are child entities only accessed through the aggregate root?
- [ ] Are aggregate roots exposed via `IRepository<TAggregateRoot>` — never raw `IQueryable<T>`?
- [ ] Are aggregates small? (Large aggregates = contention; split into smaller ones)

**Value Objects**
- [ ] Are all domain concepts that lack identity (Money, Address, Email, CustomerId) modeled as value objects (C# `record`)?
- [ ] Are primitive obsession smells replaced with value objects?
- [ ] Are value object validations in the value object constructor — not scattered in services?

**Domain Events**
- [ ] Are side effects triggered via domain events — not direct method calls?
- [ ] Are domain events raised inside aggregates — not in application services?
- [ ] Are domain events published asynchronously after the transaction commits (Outbox pattern)?

**Bounded Contexts**
- [ ] Is each bounded context responsible for a distinct business capability?
- [ ] Are shared concepts mapped between contexts via Anti-Corruption Layers (ACL)?
- [ ] Are context maps documented (Upstream/Downstream relationships, Shared Kernel, Partnership)?

### Key Diagrams to Review

```
┌───────────────────────────────────────────────────────────────────┐
│  AGGREGATE BOUNDARY REVIEW                                        │
│                                                                   │
│  Question: Does this aggregate have a single transaction          │
│  boundary? If I need to update both Order and Inventory           │
│  together, are they in the same aggregate or separate?            │
│                                                                   │
│  Rule: Prefer small aggregates + eventual consistency over        │
│  large aggregates + strong consistency.                           │
│                                                                   │
│  Red flag: Aggregate root references ANOTHER aggregate's          │
│  entity (not just its ID).                                        │
│  Fix: Replace object reference with ID reference.                 │
└───────────────────────────────────────────────────────────────────┘

// ❌ Aggregate references another aggregate's entity
public class Order
{
    public Customer Customer { get; private set; } // full object — wrong!
}

// ✅ Aggregate references another aggregate by ID only
public class Order
{
    public CustomerId CustomerId { get; private set; } // ID only — correct
}
```

---

## 5. Dimension 3 — CQRS & Messaging Patterns

// ── Command/Query Separation · MediatR · Service Bus · Outbox ────

### Checklist

**CQRS**
- [ ] Are reads (Queries) and writes (Commands) in separate handlers?
- [ ] Do Query handlers return DTOs/read models — never domain entities?
- [ ] Do Command handlers return only success/failure indicators — not full objects?
- [ ] Are read models optimized for the query (denormalized, projected) — not re-using write models?

**Event-Driven Design**
- [ ] Are domain events published via an event bus after successful commits?
- [ ] Is the Outbox pattern used for at-least-once delivery guarantee?
- [ ] Are events idempotent — can the same event be processed twice safely?
- [ ] Are consumer groups named correctly to ensure proper parallelism control?
- [ ] Is event schema evolution handled (backward/forward compatibility)?

**Message Contract Governance**
- [ ] Are message contracts (event/command schemas) versioned?
- [ ] Are consumers using schema validation?
- [ ] Is there a dead-letter queue strategy with alerting?

```
┌───────────────────────────────────────────────────────────────────┐
│  CQRS FLOW                                                        │
│                                                                   │
│  HTTP POST /orders                                                │
│       │                                                           │
│       ▼                                                           │
│  PlaceOrderCommand ──→ PlaceOrderCommandHandler                   │
│                              │                                    │
│                              ├─→ Validates command               │
│                              ├─→ Loads Order aggregate           │
│                              ├─→ Calls order.Place()             │
│                              ├─→ Raises OrderPlacedDomainEvent   │
│                              ├─→ Saves via UoW (DB + Outbox)     │
│                              └─→ Returns Result<OrderId>         │
│                                                                   │
│  HTTP GET /orders/{id}                                            │
│       │                                                           │
│       ▼                                                           │
│  GetOrderQuery ──→ GetOrderQueryHandler                           │
│                         │                                         │
│                         ├─→ Hits READ DB (replica or projection)  │
│                         ├─→ Projects to OrderDetailDto            │
│                         └─→ Returns OrderDetailDto (no domain)   │
└───────────────────────────────────────────────────────────────────┘
```

---

## 6. Dimension 4 — Azure Infrastructure Design

// ── AKS · Service Bus · Functions · Key Vault · Cosmos · APIM ───

### Checklist

**Compute**
- [ ] Is AKS node pool sizing appropriate? (System node pool separate from user node pools)
- [ ] Are pod resource requests/limits set (prevents noisy-neighbor issues)?
- [ ] Are Horizontal Pod Autoscaler (HPA) rules configured based on real metrics (CPU, custom queue depth)?
- [ ] Are pod disruption budgets (PDB) preventing full cluster disruption during upgrades?

**Networking**
- [ ] Is ingress TLS terminated at the NGINX/AGIC ingress — not at each pod?
- [ ] Are Network Policies defined to restrict pod-to-pod communication?
- [ ] Is the AKS cluster using a private endpoint (no public API server)?
- [ ] Is Azure CNI or Overlay mode chosen deliberately based on IP space requirements?

**Messaging (Azure Service Bus)**
- [ ] Are topics/queues correctly sized (Standard vs Premium for VNET integration)?
- [ ] Is dead-letter queue (DLQ) monitoring in place with alerting?
- [ ] Are message lock durations appropriate for processing time?
- [ ] Is session-based ordering needed, and if so, is it configured?

**Secrets**
- [ ] Are all secrets in Key Vault — referenced via CSI driver or environment variable reference?
- [ ] Is Key Vault soft delete + purge protection enabled?
- [ ] Are Key Vault access policies replaced with Azure RBAC?

**Storage / Data**
- [ ] Is the correct Cosmos DB consistency level chosen for the access pattern?
- [ ] Are Cosmos DB partition keys chosen to avoid hot partitions?
- [ ] Is Azure SQL geo-redundant backup retention configured?

### Reference Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PRODUCTION AZURE TOPOLOGY                       │
│                                                                     │
│   Internet                                                          │
│       │                                                             │
│       ▼                                                             │
│  [Azure Front Door / CDN] ──→ WAF Policy                           │
│       │                                                             │
│       ▼                                                             │
│  [API Management (APIM)] ──→ Rate limit, auth, versioning          │
│       │                                                             │
│       ▼                                                             │
│  [AKS — Private Cluster]                                           │
│   ├─ ingress-nginx (L7)                                             │
│   ├─ [Orders Service Pod]  ──→ Azure Service Bus (orders topic)    │
│   ├─ [Inventory Service Pod]                                        │
│   └─ [Notification Service Pod]                                     │
│                                                                     │
│  [Azure Functions] ──→ Timer / Service Bus / HTTP triggers          │
│                                                                     │
│  Data Layer                                                         │
│   ├─ Azure SQL (write DB, geo-redundant)                            │
│   ├─ Cosmos DB (read model / event store)                           │
│   └─ Azure Cache for Redis (session, distributed cache)             │
│                                                                     │
│  Secrets / Identity                                                 │
│   └─ Azure Key Vault ──→ Workload Identity (no password!)          │
│                                                                     │
│  Observability                                                      │
│   └─ Application Insights ──→ Log Analytics Workspace ──→ Alerts   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 7. Dimension 5 — Security Architecture

// ── Zero Trust · Identity · Network Segmentation ────────────────

### Checklist

**Identity & Access**
- [ ] Is Workload Identity (federated credentials) used instead of Service Principal client secrets?
- [ ] Is Managed Identity used for all Azure service connections (SQL, Service Bus, Key Vault)?
- [ ] Is RBAC applied at the minimal necessary scope (least privilege)?
- [ ] Are service-to-service calls authenticated with JWT/mTLS — not shared API keys?

**Network Security**
- [ ] Are all services in a VNET (no public endpoints for databases, message buses)?
- [ ] Are Network Security Groups (NSG) rules following deny-all-except pattern?
- [ ] Is Azure Private DNS used for private endpoint name resolution?
- [ ] Is TLS 1.2+ enforced on all endpoints (TLS 1.0/1.1 disabled)?

**Application Security**
- [ ] Is input validation enforced at the API gateway level (APIM policies) AND in the service?
- [ ] Are OWASP Top 10 mitigations in place?
- [ ] Is WAF (Web Application Firewall) deployed in front of public-facing services?
- [ ] Are tokens short-lived (JWT < 15 min access token) with refresh token rotation?
- [ ] Is PII tokenized/encrypted before reaching the data layer?

**Compliance**
- [ ] Are audit logs capturing who changed what and when (Azure Monitor Activity Log)?
- [ ] Is data residency enforced (geo-restriction in region pairs)?
- [ ] Is GDPR right-to-erasure handled in the data model?

---

## 8. Dimension 6 — Scalability & Performance Architecture

// ── Stateless · Caching · Read Replicas · Multi-Region ──────────

### Checklist

**Stateless Design**
- [ ] Are API pods stateless? (Session state externalized to Redis — not in-memory)
- [ ] Are background jobs idempotent (can be run multiple times safely)?
- [ ] Are file uploads streamed to Blob Storage — not buffered in the service?

**Caching Architecture**
- [ ] Is a multi-tier cache in place? (L1 in-process → L2 Redis → L3 DB)
- [ ] Are cache invalidation strategies explicit (TTL, event-driven invalidation)?
- [ ] Are cache keys namespaced to prevent collision across services?
- [ ] Is cache stampede protection in place (single-flight / locking on cache miss)?

**Database Scaling**
- [ ] Are read replicas used for read-heavy workloads (CQRS read side)?
- [ ] Are database connection pools sized correctly (EF Core's default is 100)?
- [ ] Are long-running queries identified and have execution plan optimizations?
- [ ] Are hot partitions in Cosmos DB identified and partition key designed to distribute?

**Horizontal Scaling**
- [ ] Can the system scale from 1 to 100 pods without architectural changes?
- [ ] Are external state dependencies (files, in-memory data) eliminated?
- [ ] Is KEDA (Kubernetes Event-Driven Autoscaling) used for event-driven workloads?

```
┌───────────────────────────────────────────────────────────────────┐
│  SCALABILITY REVIEW QUESTION FRAMEWORK                            │
│                                                                   │
│  For each component, ask:                                         │
│  1. What is the bottleneck when load doubles?                     │
│  2. Can you scale this component independently?                   │
│  3. Does scaling this component require coordination?             │
│  4. What is the cost profile at 10× load?                        │
└───────────────────────────────────────────────────────────────────┘
```

---

## 9. Dimension 7 — Resilience & Fault Tolerance

// ── Circuit Breaker · Retry · Bulkhead · Saga · Chaos ────────────

### Checklist

**Transient Fault Handling**
- [ ] Are HTTP client retry policies configured (exponential backoff + jitter)?
- [ ] Are DB command timeouts set explicitly (not relying on driver defaults)?
- [ ] Are Azure SDK calls wrapped with Polly policies or using built-in SDK retry?

**Circuit Breaker**
- [ ] Are circuit breakers in place for each external dependency?
- [ ] Are circuit breaker state changes (open/close) logged and alerted?
- [ ] Is a fallback behavior defined for when the circuit is open?

**Bulkhead**
- [ ] Are thread pools / connection pools partitioned per dependency?
- [ ] Are resource-intensive operations isolated from critical paths?

**Saga / Distributed Transactions**
- [ ] Are multi-service workflows modeled as Sagas (choreography or orchestration)?
- [ ] Does each saga step have a compensating transaction?
- [ ] Is saga state persisted durably (not in-memory)?

**Chaos Engineering**
- [ ] Has fault injection been considered (Azure Chaos Studio, Simmy)?
- [ ] Are runbooks written for common failure scenarios?
- [ ] Is there a game day process to validate resilience?

```
┌───────────────────────────────────────────────────────────────────┐
│  RESILIENCE MATRIX — REVIEW THIS FOR EACH EXTERNAL DEPENDENCY     │
│                                                                   │
│  Dependency     │ Timeout │ Retry │ Circuit │ Fallback │ DLQ?    │
│  ─────────────────────────────────────────────────────────────── │
│  Azure SQL      │  30s    │ 3×    │  Yes    │  Cache   │  N/A    │
│  Service Bus    │  60s    │ SDK   │  Yes    │  Queue   │  Yes    │
│  Payment API    │  10s    │ 2×    │  Yes    │  Reject  │  N/A    │
│  Redis          │   2s    │ 1×    │  Yes    │  DB hit  │  N/A    │
└───────────────────────────────────────────────────────────────────┘
```

---

## 10. Dimension 8 — Observability Architecture

// ── The Three Pillars: Logs · Metrics · Traces ──────────────────

### Checklist

**Logging**
- [ ] Is structured logging (JSON) used across all services?
- [ ] Are logs routed to a central Log Analytics Workspace?
- [ ] Is log severity used consistently (no `Error` logs for expected business events)?
- [ ] Are correlation IDs (TraceId, SpanId, CorrelationId) in all log entries?

**Metrics**
- [ ] Are golden signals (Latency, Traffic, Errors, Saturation) measured per service?
- [ ] Are SLI/SLO targets defined and alerted on?
- [ ] Are custom business metrics emitted (orders/sec, payment success rate)?
- [ ] Is Prometheus scraping enabled on AKS pods with proper annotations?

**Tracing**
- [ ] Is distributed tracing (OpenTelemetry) propagating context across all HTTP and message calls?
- [ ] Are trace IDs visible in Application Insights end-to-end transactions?
- [ ] Are slow spans (> 1s) triggering alerts?

**Alerting**
- [ ] Are alerts actionable — every alert has a runbook?
- [ ] Are SLO burn rate alerts implemented (not just raw error rate)?
- [ ] Are critical path availability alerts PagerDuty/Teams-integrated?

---

## 11. Dimension 9 — Data Architecture

// ── Ownership · Schema Evolution · Event Sourcing ───────────────

### Checklist

**Data Ownership**
- [ ] Does each microservice own its data store — no shared database between services?
- [ ] Is cross-service data access via API calls or events — never direct DB queries across service boundaries?
- [ ] Are reporting/analytical queries served from a separate read model (OLAP/data warehouse) — not the OLTP DB?

**Schema Evolution**
- [ ] Are EF Core migrations reviewed for backward compatibility (is the app deployable without taking downtime)?
- [ ] Are breaking schema changes separated from application changes (expand-contract pattern)?
- [ ] Are event schemas versioned and backward-compatible?

**Data Consistency**
- [ ] Is the correct consistency model chosen per bounded context (strong vs eventual)?
- [ ] Are saga compensations handling partial failures?
- [ ] Is the Outbox pattern ensuring at-least-once event delivery?

```
┌───────────────────────────────────────────────────────────────────┐
│  DATA OWNERSHIP ANTI-PATTERN                                      │
│                                                                   │
│  ❌ Orders Service         →  SELECT * FROM inventory.Products    │
│     (crosses DB boundary — tight coupling, no ownership)          │
│                                                                   │
│  ✅ Orders Service         →  GET /products/{id} (via API)        │
│     OR subscribes to ProductPriceChanged event and caches         │
│     a local denormalized copy of price                            │
└───────────────────────────────────────────────────────────────────┘
```

---

## 12. Dimension 10 — Deployment Architecture (CI/CD & AKS)

// ── Pipeline Design · GitOps · Blue-Green · Helm ────────────────

### Checklist

**CI Pipeline**
- [ ] Does CI run on every PR? (Build → Unit Tests → Integration Tests → SAST scan)
- [ ] Are Docker image builds reproducible (fixed base image tags, not `latest`)?
- [ ] Are container vulnerability scans (Trivy / Microsoft Defender for Containers) in the pipeline?
- [ ] Are secrets never printed in pipeline logs?

**CD Pipeline / GitOps**
- [ ] Is ArgoCD or Flux used for GitOps-style deployments?
- [ ] Are Helm chart values separated per environment (`values-dev.yaml`, `values-prod.yaml`)?
- [ ] Is image tagging based on commit SHA — not `latest`?
- [ ] Are deployment rollback capabilities tested?

**Release Strategy**
- [ ] Is blue-green or canary deployment configured for zero-downtime releases?
- [ ] Are readiness probes configured so Kubernetes waits for health before routing traffic?
- [ ] Are liveness probes distinguishable from readiness probes?
- [ ] Are PreStop hooks and `terminationGracePeriodSeconds` set for graceful drain?

```
┌───────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT PIPELINE STAGES                                       │
│                                                                   │
│  PR → CI: Build + Unit Test + SAST + Image Scan                  │
│        ↓                                                          │
│  Merge → CD: Integration Tests + Helm Deploy → DEV               │
│        ↓                                                          │
│  Tag → CD: E2E Tests + Approval Gate → STAGING                   │
│        ↓                                                          │
│  Release: Canary (5% traffic) → Monitor SLOs → Full rollout      │
│        ↓                                                          │
│  Post-Deploy: Smoke tests + Alerting validation                   │
└───────────────────────────────────────────────────────────────────┘
```

---

## 13. Architecture Anti-Patterns Catalogue

// ── The Most Expensive Mistakes ─────────────────────────────────

| Anti-Pattern | Description | Fix |
|---|---|---|
| **Distributed Monolith** | Microservices that deploy independently but require synchronized releases | Define clear bounded contexts; use events for cross-service communication |
| **Shared Database** | Multiple services reading/writing the same DB schema | Each service owns its data; communicate via APIs or events |
| **Anemic Domain Model** | Domain objects are data bags; all logic is in services | Move invariant enforcement into aggregates and value objects |
| **Mega Service** | One service doing 10 things (orders, inventory, billing, shipping) | Split by bounded context; apply single-responsibility to services |
| **Chatty Microservices** | 20 synchronous HTTP calls to render one page | BFF pattern, GraphQL federation, or event-sourced read models |
| **Synchronous Saga** | Distributed workflow with sequential blocking HTTP calls | Event-driven choreography or orchestration with Durable Functions |
| **No Circuit Breaker** | All downstream failures cascade | Polly circuit breakers on all external calls |
| **Magic Config Service** | One config service all others depend on at startup | Externalize config via Azure App Configuration + Key Vault; cache at startup |
| **God Aggregate** | Aggregate with 50 fields, 30 methods, loaded for every use case | Split into focused aggregates; use projections for read queries |
| **No Versioning** | API changes break consumers without notice | URL versioning + deprecation headers + consumer-driven contract tests |
| **Logging as Monitoring** | No SLO/SLI metrics — only log volume is tracked | Instrument custom metrics; build dashboards on error rates and latency |
| **Snowflake Infrastructure** | AKS clusters created manually — not reproducible | Bicep/Terraform for all infrastructure; pipelines for all changes |

---

## 14. Architecture Decision Record (ADR) Template

```markdown
# ADR-{number}: {Title}

## Status
[ ] Proposed | [ ] Accepted | [ ] Deprecated | [ ] Superseded by ADR-{n}

## Date
YYYY-MM-DD

## Context
What is the problem we are trying to solve?
What are the constraints (technical, team, time, budget)?

## Decision Drivers
- Driver 1: (e.g., team familiarity with X)
- Driver 2: (e.g., Azure WAF recommendation for this scenario)
- Driver 3: (e.g., SLA requirement of 99.9%)

## Considered Options
1. Option A — {brief description}
2. Option B — {brief description}
3. Option C — {brief description}

## Decision
We chose Option {X} because {reason directly tied to decision drivers}.

## Consequences
### Positive
- ...

### Negative
- ...
- Technical debt: {description} — to be addressed by {date/milestone}

## Compliance Checklist
- [ ] Security review completed
- [ ] Cost estimate reviewed
- [ ] Runbook written
- [ ] Monitoring/alerting designed
```

---

## 15. Architecture Review Scorecard

```
┌────────────────────────────────────────────────────────────────────┐
│  ARCHITECTURE REVIEW SCORECARD (0 = Not present, 3 = Excellent)   │
├──────────────────────────────────────┬──────────┬─────────────────┤
│ Dimension                            │ Score    │ Notes           │
├──────────────────────────────────────┼──────────┼─────────────────┤
│ 1. Clean Architecture Layers         │  /3      │                 │
│ 2. Domain Model Quality (DDD)        │  /3      │                 │
│ 3. CQRS / Event-Driven Design        │  /3      │                 │
│ 4. Azure Infrastructure Design       │  /3      │                 │
│ 5. Security Architecture             │  /3      │                 │
│ 6. Scalability / Performance         │  /3      │                 │
│ 7. Resilience / Fault Tolerance      │  /3      │                 │
│ 8. Observability (Logs/Metrics/Trace)│  /3      │                 │
│ 9. Data Architecture                 │  /3      │                 │
│ 10. Deployment Architecture          │  /3      │                 │
├──────────────────────────────────────┼──────────┼─────────────────┤
│ TOTAL                                │  /30     │                 │
├──────────────────────────────────────┼──────────┼─────────────────┤
│ 27–30: Production-ready              │          │                 │
│ 21–26: Minor gaps, track in backlog  │          │                 │
│ 15–20: Significant gaps, plan sprint │          │                 │
│  0–14: Do not proceed to production  │          │                 │
└──────────────────────────────────────┴──────────┴─────────────────┘
```

---

*Principal Engineer Architecture Review Guidelines v1.0 — .NET + Azure stack*
