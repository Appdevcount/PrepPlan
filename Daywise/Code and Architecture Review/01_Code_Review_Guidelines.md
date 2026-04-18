# Code Review Guidelines — Principal Engineer Perspective
> Deep expertise lens: .NET / C# · Azure · Clean Architecture · DDD · CQRS · Security · Performance
> Use this as a structured checklist and teaching reference during PR reviews.

---

## Table of Contents

1. [Mental Model — What Code Review Actually Is](#1-mental-model)
2. [Review Tiers & Effort Calibration](#2-review-tiers)
3. [Layer 1 — Correctness & Logic](#3-layer-1-correctness)
4. [Layer 2 — C# Language & .NET Runtime Quality](#4-layer-2-csharp)
5. [Layer 3 — API Design & HTTP Contracts](#5-layer-3-api)
6. [Layer 4 — Data Access & EF Core](#6-layer-4-data)
7. [Layer 5 — Async / Concurrency / Threading](#7-layer-5-async)
8. [Layer 6 — Security](#8-layer-6-security)
9. [Layer 7 — Observability & Diagnostics](#9-layer-7-observability)
10. [Layer 8 — Error Handling & Resilience](#10-layer-8-resilience)
11. [Layer 9 — Test Quality](#11-layer-9-testing)
12. [Layer 10 — Maintainability & Design Smells](#12-layer-10-maintainability)
13. [Layer 11 — Performance Hot-Paths](#13-layer-11-performance)
14. [Review Comment Templates](#14-comment-templates)
15. [Severity Classification](#15-severity)
16. [Golden Rules Checklist](#16-golden-rules)

---

## 1. Mental Model

```
┌─────────────────────────────────────────────────────────────────┐
│  CODE REVIEW = FUTURE MAINTENANCE COST AUDIT                    │
│                                                                 │
│  Every line you approve is a line you or your team must         │
│  read, debug, extend, and explain at 3 AM during an outage.     │
│                                                                 │
│  Ask: "Would I be proud to show this code in 2 years?"          │
│  Ask: "Can a new engineer understand this without asking me?"   │
│  Ask: "Will this survive 10× traffic tomorrow?"                 │
└─────────────────────────────────────────────────────────────────┘
```

Code review is NOT about perfection — it is about:
- Catching bugs before production
- Transferring knowledge bi-directionally
- Enforcing team standards consistently
- Reducing future cognitive load

---

## 2. Review Tiers & Effort Calibration

```
┌──────────────┬─────────────────────────────────┬───────────────┐
│ PR Size      │ Lines Changed (excluding tests)  │ Review Time   │
├──────────────┼─────────────────────────────────┼───────────────┤
│ Micro        │ < 50                             │ 10–15 min     │
│ Small        │ 50–200                           │ 20–40 min     │
│ Medium       │ 200–500                          │ 1–2 hours     │
│ Large        │ 500–1000                         │ Half-day      │
│ Epic (AVOID) │ > 1000                           │ Request split │
└──────────────┴─────────────────────────────────┴───────────────┘
```

**Triage rule**: PRs > 800 lines should be sent back with a split request unless they are purely mechanical (e.g., rename refactor, generated migrations).

**Review order**:
1. Read the PR description first — understand *intent*
2. Read tests first — they document expected behavior
3. Read the diff from the outermost layer inward (API → Application → Domain → Infrastructure)

---

## 3. Layer 1 — Correctness & Logic

// ── Business Logic Validation ──────────────────────────────────

### Checklist

- [ ] Does the code do what the ticket/story describes?
- [ ] Are all branching paths covered (null, empty, edge values)?
- [ ] Are boundary values handled (0, -1, Int32.MaxValue, DateTime.MinValue)?
- [ ] Is there off-by-one risk in loops or slices?
- [ ] Are conditional chains exhaustive (especially `switch` without `default`)?
- [ ] Is boolean logic free from De Morgan's law mistakes?
- [ ] Are nullable reference types (`?`) propagated correctly — no silent `null` dereferences?
- [ ] Does financial/arithmetic code use `decimal`, not `double`/`float`?
- [ ] Are date/time operations timezone-aware (`DateTimeOffset`, not `DateTime`)?

### Red Flags

```csharp
// ❌ Silent null dereference — nullable reference types are enabled but ignored
var name = user.Profile.Name; // user or Profile could be null

// ✅ Explicit null guard with meaningful error
var name = user?.Profile?.Name
    ?? throw new DomainException($"User {user?.Id} has no profile name configured.");

// ❌ Floating-point for money
double total = price * quantity; // loses precision above ~15 digits

// ✅ Decimal for financial math
decimal total = price * quantity;

// ❌ DateTime is ambiguous — which timezone?
var expires = DateTime.Now.AddDays(7);

// ✅ DateTimeOffset carries timezone offset
var expires = DateTimeOffset.UtcNow.AddDays(7);
```

---

## 4. Layer 2 — C# Language & .NET Runtime Quality

// ── Language Feature Usage ──────────────────────────────────────

### Checklist

- [ ] Are records used for DTOs / value objects (immutability by default)?
- [ ] Are `init`-only setters used where mutation post-construction is wrong?
- [ ] Is pattern matching used over `is` + cast chains?
- [ ] Are `string.IsNullOrWhiteSpace` checks used instead of `== null || == ""`?
- [ ] Are LINQ chains readable (not a single 12-clause expression)?
- [ ] Are `IEnumerable<T>` results materialized before returning across layers?
- [ ] Are `using` declarations present for all `IDisposable` objects?
- [ ] Are `ValueTask` / `Task` returned appropriately (ValueTask for hot paths, Task otherwise)?
- [ ] Is `string` concatenation in loops replaced with `StringBuilder` or interpolation?
- [ ] Are `List<T>` capacities pre-sized where size is known?
- [ ] Are `HashSet<T>` used for O(1) lookup instead of `.Contains()` on `List<T>`?

### Red Flags

```csharp
// ❌ Multiple enumeration of IEnumerable — query runs twice
IEnumerable<Order> orders = repository.GetAll();
if (orders.Any()) ProcessOrders(orders); // DB hit #1 and #2

// ✅ Materialize once
var orders = (await repository.GetAllAsync()).ToList();
if (orders.Count > 0) ProcessOrders(orders);

// ❌ Lost IDisposable — HttpClient leaked if not using IHttpClientFactory
var client = new HttpClient();

// ✅ Injected via DI / IHttpClientFactory
// HttpClient is injected via constructor — scoped lifetime managed by factory

// ❌ Mutable DTO — consumers can corrupt state
public class OrderDto { public int Id { get; set; } public string Status { get; set; } }

// ✅ Immutable record DTO
public record OrderDto(int Id, string Status);

// ❌ Is-cast chain — verbose and fragile
if (shape is Circle) { var c = (Circle)shape; }

// ✅ Pattern matching — concise and type-safe
if (shape is Circle { Radius: > 0 } c) { }
```

---

## 5. Layer 3 — API Design & HTTP Contracts

// ── ASP.NET Core Minimal API / Controller Patterns ─────────────

### Checklist

- [ ] Are HTTP verbs semantically correct (GET is idempotent, POST is not)?
- [ ] Are route parameters named consistently (`{id}`, `{orderId}`, not `{x}`)?
- [ ] Are status codes precise (`201 Created` with `Location` header on POST, `204` on DELETE, `404` on missing resource)?
- [ ] Is `ProblemDetails` (RFC 7807) returned for all error responses — never raw exception messages?
- [ ] Are query parameters validated (FluentValidation or Data Annotations)?
- [ ] Are large collection endpoints paginated — never returning unbounded lists?
- [ ] Are idempotency keys supported for POST/PUT endpoints that trigger side effects?
- [ ] Are response envelopes consistent across all endpoints?
- [ ] Is API versioning in place (`/api/v1/...`)?
- [ ] Is content-type negotiation handled?

### Red Flags

```csharp
// ❌ Leaking internal exception details
return Results.Problem(exception.ToString()); // stack trace exposed!

// ✅ Safe ProblemDetails with correlation ID
return Results.Problem(
    title: "Order processing failed",
    detail: "An unexpected error occurred. Reference: " + correlationId,
    statusCode: 500);

// ❌ Unbounded list — DoS vector
app.MapGet("/orders", async (IOrderRepository repo) =>
    await repo.GetAllAsync()); // returns millions of rows

// ✅ Paginated with cursor or page/size
app.MapGet("/orders", async (
    [FromQuery] int page,
    [FromQuery] int pageSize,
    IOrderRepository repo) =>
    await repo.GetPagedAsync(page, pageSize));

// ❌ 200 OK on resource not found
return Results.Ok(null);

// ✅ Correct 404
return order is null ? Results.NotFound() : Results.Ok(order);
```

---

## 6. Layer 4 — Data Access & EF Core

// ── Repository / Query Patterns ────────────────────────────────

### Checklist

- [ ] Are all queries projected to DTOs (`.Select()`) — never loading full entity graphs for read models?
- [ ] Is `AsNoTracking()` used on read-only queries?
- [ ] Are N+1 query patterns absent (use `.Include()` / `.ThenInclude()` or split queries)?
- [ ] Are raw SQL queries parameterized — never string-interpolated?
- [ ] Are database transactions scoped to the unit of work, not the entire request?
- [ ] Are migrations reviewed for destructive operations (column drops, renames)?
- [ ] Are indices present on foreign keys and commonly filtered columns?
- [ ] Are `IQueryable<T>` chains finalized inside the repository (not leaked to the application layer)?
- [ ] Is `SaveChangesAsync(cancellationToken)` called with the cancellation token?
- [ ] Are large batch operations chunked (not a single 50K-row `AddRange`)?

### Red Flags

```csharp
// ❌ N+1 — one query per order item
var orders = await context.Orders.ToListAsync();
foreach (var order in orders)
    order.Items = await context.OrderItems.Where(i => i.OrderId == order.Id).ToListAsync();

// ✅ Single query with eager loading
var orders = await context.Orders
    .Include(o => o.Items)
    .AsNoTracking()
    .ToListAsync(ct);

// ❌ Raw SQL with string interpolation — SQL injection
var sql = $"SELECT * FROM Orders WHERE CustomerId = '{customerId}'";

// ✅ Parameterized raw SQL
var orders = await context.Orders
    .FromSqlRaw("SELECT * FROM Orders WHERE CustomerId = {0}", customerId)
    .ToListAsync(ct);

// ❌ Full entity loaded for a count
var count = (await repo.GetAllAsync()).Count(); // loads all rows!

// ✅ Projected count at DB level
var count = await context.Orders.CountAsync(o => o.IsActive, ct);
```

---

## 7. Layer 5 — Async / Concurrency / Threading

// ── Task, ValueTask, CancellationToken, Thread Safety ──────────

### Checklist

- [ ] Is `async/await` propagated all the way up (no `.Result`, `.Wait()`, `.GetAwaiter().GetResult()`)?
- [ ] Is `ConfigureAwait(false)` used in library code (not in ASP.NET Core controllers/handlers)?
- [ ] Are `CancellationToken` parameters threaded through all async call chains?
- [ ] Are shared mutable fields protected (`lock`, `SemaphoreSlim`, `Interlocked`, `ConcurrentDictionary`)?
- [ ] Is `async void` avoided (except event handlers)?
- [ ] Are parallel operations using `Task.WhenAll` where appropriate (not sequential `await` in a loop)?
- [ ] Are `SemaphoreSlim` used for async mutual exclusion (not `lock` with `await` inside)?
- [ ] Is `IAsyncEnumerable<T>` used for streaming large result sets?

### Red Flags

```csharp
// ❌ Deadlock risk — blocking on async in synchronous context
var result = GetOrderAsync().Result; // deadlocks in sync context!

// ✅ Pure async chain
var result = await GetOrderAsync(ct);

// ❌ async void — exceptions are unobserved and crash the process
public async void ProcessOrder() { ... }

// ✅ async Task — exception propagates to caller
public async Task ProcessOrderAsync(CancellationToken ct) { ... }

// ❌ Sequential awaits when calls are independent
var customer = await GetCustomerAsync(id, ct);
var orders = await GetOrdersAsync(id, ct);

// ✅ Parallel with Task.WhenAll
var (customer, orders) = await (GetCustomerAsync(id, ct), GetOrdersAsync(id, ct));

// ❌ lock with await — lock is not async-aware
lock (_lock) { await DoSomethingAsync(); } // compiler error and conceptual bug

// ✅ SemaphoreSlim for async mutual exclusion
await _semaphore.WaitAsync(ct);
try { await DoSomethingAsync(ct); }
finally { _semaphore.Release(); }
```

---

## 8. Layer 6 — Security

// ── OWASP Top 10 · Auth · Secrets ──────────────────────────────

### Checklist

**Authentication & Authorization**
- [ ] Are all non-public endpoints decorated with `[Authorize]` / `.RequireAuthorization()`?
- [ ] Are authorization policies granular (roles, claims, resource-based) — not just `[Authorize]`?
- [ ] Is IDOR (Insecure Direct Object Reference) prevented — resource ownership validated before returning?
- [ ] Are JWT tokens validated (issuer, audience, expiry, signature algorithm)?

**Input Validation**
- [ ] Is all user input validated at the API boundary (FluentValidation, Data Annotations)?
- [ ] Are file upload types and sizes validated?
- [ ] Is HTML/rich-text content sanitized before storage (not just on display)?

**Secrets**
- [ ] Are connection strings, API keys, certificates stored in Azure Key Vault — never appsettings or code?
- [ ] Are secrets masked in logs (`[Sensitive]`, custom serializer)?
- [ ] Are environment variables in Dockerfile/K8s manifests free of secrets (use K8s Secrets + CSI driver)?

**Data Protection**
- [ ] Is PII/PHI encrypted at rest and in transit?
- [ ] Are SQL queries fully parameterized (no interpolation)?
- [ ] Is output encoding applied before rendering user content in HTML?

### Red Flags

```csharp
// ❌ IDOR — fetches any order by ID, no ownership check
app.MapGet("/orders/{id}", async (int id, IOrderRepository repo) =>
    await repo.GetByIdAsync(id));

// ✅ Ownership enforced
app.MapGet("/orders/{id}", async (
    int id,
    ClaimsPrincipal user,
    IOrderRepository repo) =>
{
    var order = await repo.GetByIdAsync(id, ct);
    // WHY: Prevents horizontal privilege escalation — user must own the order
    if (order?.CustomerId != user.GetCustomerId())
        return Results.Forbid();
    return Results.Ok(order);
});

// ❌ Connection string in appsettings.json committed to git
"ConnectionStrings": { "Default": "Server=prod.db;Password=SuperSecret123" }

// ✅ Azure Key Vault reference
"ConnectionStrings": { "Default": "@Microsoft.KeyVault(SecretUri=https://...)" }

// ❌ Secret visible in logs
_logger.LogInformation("Connecting with key: {ApiKey}", apiKey);

// ✅ Masked
_logger.LogInformation("Connecting to external service (key masked)");
```

---

## 9. Layer 7 — Observability & Diagnostics

// ── Structured Logging · Metrics · Tracing ─────────────────────

### Checklist

- [ ] Is structured logging used (`_logger.LogInformation("Order {OrderId} created", orderId)` — not string interpolation)?
- [ ] Are log levels appropriate (Debug for dev noise, Info for business events, Warning for recoverable issues, Error for faults)?
- [ ] Are correlation/trace IDs propagated across service boundaries?
- [ ] Are critical business operations logged at `Information` level with enough context to replay the event?
- [ ] Are exceptions logged with `.LogError(ex, ...)` — not `ex.ToString()`?
- [ ] Are health check endpoints implemented (`/health/live`, `/health/ready`)?
- [ ] Are custom metrics/counters emitted for business KPIs (orders processed, payment failures)?
- [ ] Are `Activity`/`ActivitySource` spans added for non-trivial operations?

### Red Flags

```csharp
// ❌ String interpolation breaks structured logging — cannot be queried in KQL
_logger.LogInformation($"Order {orderId} created for customer {customerId}");

// ✅ Structured (named placeholders) — queryable in Application Insights / Seq
_logger.LogInformation("Order {OrderId} created for {CustomerId}", orderId, customerId);

// ❌ Swallowed exception — no log, no trace
catch (Exception) { return null; }

// ✅ Logged with context
catch (Exception ex)
{
    _logger.LogError(ex, "Failed to process order {OrderId}", orderId);
    throw; // WHY: re-throw so the caller's error-handling middleware can return 500
}

// ❌ No correlation ID — can't trace request across 3 services
_logger.LogInformation("Payment processed");

// ✅ Correlation ID from Activity (OpenTelemetry propagates this)
_logger.LogInformation("Payment processed. TraceId={TraceId}", Activity.Current?.TraceId);
```

---

## 10. Layer 8 — Error Handling & Resilience

// ── Exception Strategy · Polly · Circuit Breaker ───────────────

### Checklist

- [ ] Are domain exceptions used for business rule violations (not raw `Exception`)?
- [ ] Are infrastructure exceptions (network, DB) caught and wrapped — not exposed to callers?
- [ ] Is the exception hierarchy documented and layered (Domain → Application → Infrastructure)?
- [ ] Are Polly retry policies applied to transient faults (HTTP 429, 503, DB timeouts)?
- [ ] Are circuit breakers in place for external dependencies?
- [ ] Are timeouts set on all outbound HTTP calls and DB queries?
- [ ] Is the Outbox pattern used for guaranteed message delivery (not fire-and-forget)?

### Red Flags

```csharp
// ❌ Catching and swallowing all exceptions
catch (Exception) { return false; } // failure is invisible

// ✅ Catch specific exceptions, log, re-throw or convert
catch (SqlException ex) when (ex.Number == 1205) // deadlock
{
    _logger.LogWarning(ex, "Deadlock on order {OrderId}, will retry", orderId);
    throw new TransientDatabaseException("Deadlock detected", ex);
}

// ❌ No timeout on external HTTP call — hangs forever on slow dependency
var response = await _httpClient.GetAsync("/api/orders");

// ✅ Timeout + Polly retry configured in Program.cs
// services.AddHttpClient<IPaymentClient, PaymentClient>()
//     .AddPolicyHandler(GetRetryPolicy())
//     .AddPolicyHandler(Policy.TimeoutAsync<HttpResponseMessage>(10));
```

---

## 11. Layer 9 — Test Quality

// ── xUnit · FluentAssertions · Testcontainers ──────────────────

### Checklist

- [ ] Does each test have one reason to fail (single assertion of a single behavior)?
- [ ] Are test names in `Method_Scenario_ExpectedResult` or BDD `Given_When_Then` format?
- [ ] Are tests isolated — no shared mutable state, no test-ordering dependencies?
- [ ] Are `Mock<T>` setups verifying behavior — not just returning data?
- [ ] Are integration tests using Testcontainers (real DB) — not mocked repositories?
- [ ] Are happy path, edge case, and error path tests present?
- [ ] Are tests free from magic numbers (use named constants)?
- [ ] Is Arrange-Act-Assert (AAA) structure visible (blank line between sections)?
- [ ] Are `[Fact]` vs `[Theory]` used appropriately (Theory for parameterized scenarios)?

### Red Flags

```csharp
// ❌ Test name reveals nothing
[Fact] public async Task Test1() { ... }

// ✅ Descriptive behavior specification
[Fact]
public async Task CreateOrder_WhenCustomerHasInsufficientCredit_ThrowsCreditLimitException() { }

// ❌ Multiple assertions — unclear which one fails
order.Id.Should().BeGreaterThan(0);
order.Status.Should().Be(OrderStatus.Pending);
order.CreatedAt.Should().BeCloseTo(DateTimeOffset.UtcNow, TimeSpan.FromSeconds(5));
// When it fails, you don't know if Id, Status, or CreatedAt is wrong

// ✅ Test ONE behavior per fact; use Theory for variants

// ❌ Mocked repository hides real query bugs
_mockRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(new Order { Id = 1 });
// WHY THIS IS DANGEROUS: real EF Core query may have a different projection

// ✅ Testcontainers with real SQL Server / Postgres for integration tests
```

---

## 12. Layer 10 — Maintainability & Design Smells

// ── SOLID · DDD · Clean Architecture Violations ────────────────

### Checklist

- [ ] Is the Single Responsibility Principle respected — one class, one reason to change?
- [ ] Are interfaces defined for all cross-layer dependencies?
- [ ] Is the Dependency Inversion Principle followed — high-level modules don't depend on concrete low-level modules?
- [ ] Are domain entities free of infrastructure concerns (no EF attributes on domain models)?
- [ ] Are application services free of domain logic (domain logic lives in domain entities)?
- [ ] Is the Open/Closed Principle respected — adding behavior via extension, not modification?
- [ ] Are methods < 30 lines? Classes < 300 lines? (Warning thresholds, not hard rules)
- [ ] Is there excessive nesting (> 3 levels indicates extract-method opportunity)?
- [ ] Are primitive obsession smells replaced with value objects?
- [ ] Is God Object / God Service pattern absent?

### Red Flags

```csharp
// ❌ Domain entity with EF attributes — couples domain to ORM
public class Order
{
    [Key] public int Id { get; set; }              // EF concern in domain model
    [ForeignKey("Customer")] public int CustId { get; set; }
}

// ✅ Separate persistence model from domain model
// Domain: pure C# record/class
// Infrastructure: EF entity class + mapping configuration in IEntityTypeConfiguration<T>

// ❌ Application service performing domain logic
public class OrderService
{
    public async Task PlaceOrder(OrderDto dto)
    {
        // This business rule belongs in the Order domain aggregate
        if (dto.Items.Count == 0)
            throw new Exception("Cannot place empty order");
    }
}

// ✅ Domain aggregate enforces its own invariants
public class Order
{
    public void AddItem(OrderItem item)
    {
        // WHY: Aggregate root protects its own invariant — items cannot be added after shipment
        if (Status == OrderStatus.Shipped)
            throw new DomainException("Cannot add items to a shipped order");
    }
}
```

---

## 13. Layer 11 — Performance Hot-Paths

// ── Allocation · Caching · Serialization ───────────────────────

### Checklist

- [ ] Are `Span<T>` / `Memory<T>` used for buffer operations instead of array copies?
- [ ] Is `ArrayPool<T>` / `MemoryPool<T>` used for large temporary buffers?
- [ ] Is `IMemoryCache` / `IDistributedCache` (Redis) used for expensive repeated queries?
- [ ] Are `System.Text.Json` source generators used for high-throughput serialization paths?
- [ ] Are large object allocations in hot paths profiled and minimized?
- [ ] Are `StringBuilder` used in string-building loops?
- [ ] Are expensive computations memoized or cached per-request via `HttpContext.Items`?
- [ ] Are background jobs offloaded to Azure Functions / Service Bus rather than blocking the request thread?

### Red Flags

```csharp
// ❌ New allocation on every request in hot path
app.MapGet("/ping", () =>
{
    var buffer = new byte[1024]; // allocates on every request
    return Results.Ok(Process(buffer));
});

// ✅ Pool the buffer
private static readonly ArrayPool<byte> Pool = ArrayPool<byte>.Shared;

app.MapGet("/ping", () =>
{
    var buffer = Pool.Rent(1024);
    try { return Results.Ok(Process(buffer)); }
    finally { Pool.Return(buffer); }
});

// ❌ Fetching same data 20× per request
// Called from 20 different services in one request pipeline — 20 DB round trips
var config = await _configRepo.GetAsync("feature-flags");

// ✅ Cache with sliding expiry
// WHY: Config changes rarely; caching avoids 20 DB hits per request
var config = await _cache.GetOrCreateAsync("feature-flags", async entry =>
{
    entry.SlidingExpiration = TimeSpan.FromMinutes(5);
    return await _configRepo.GetAsync("feature-flags");
});
```

---

## 14. Review Comment Templates

// ── Copy-Paste Starter Templates ───────────────────────────────

```
🚨 [BLOCKER] This is a SQL injection vulnerability. The query uses string interpolation 
with user input. Use parameterized queries or EF Core. Must fix before merge.

⚠️ [CONCERN] This method loads the entire Orders table into memory before filtering.
At scale, this will OOM the service. Use .Where() before .ToListAsync().

💡 [SUGGESTION] Consider using a ValueTask<T> here instead of Task<T> — this method
returns synchronously in the 90% case (cache hit) and would benefit from the reduced
allocation. Not blocking.

📝 [NITS] Method name `DoThing` doesn't follow the verb-noun convention we use here.
`ProcessPayment` or `ExecutePayment` would be clearer. Non-blocking.

❓ [QUESTION] What happens if the external payment API returns 429 (rate limit)?
I don't see a retry policy or backoff here. Is this intentional?

✅ [PRAISE] Nice use of the Result<T> pattern here instead of exceptions for expected
failure paths. This makes the calling code much cleaner.
```

---

## 15. Severity Classification

```
┌───────────┬────────────────────────────────────────────────────┬───────────┐
│ Severity  │ Definition                                         │ Merge?    │
├───────────┼────────────────────────────────────────────────────┼───────────┤
│ BLOCKER   │ Security vuln, data loss risk, crash, data         │ Block      │
│           │ corruption, compliance violation                    │           │
├───────────┼────────────────────────────────────────────────────┼───────────┤
│ CRITICAL  │ Performance O(N²), missing auth, swallowed         │ Block      │
│           │ exceptions, race condition                          │           │
├───────────┼────────────────────────────────────────────────────┼───────────┤
│ CONCERN   │ Design smell, wrong abstraction, missing test       │ Discuss   │
│           │ coverage for new branch                             │           │
├───────────┼────────────────────────────────────────────────────┼───────────┤
│ SUGGESTION│ Better idiom available, optional refactor           │ Author    │
│           │                                                     │ discretion│
├───────────┼────────────────────────────────────────────────────┼───────────┤
│ NITS      │ Naming, formatting, comment clarity                 │ Optional  │
└───────────┴────────────────────────────────────────────────────┴───────────┘
```

---

## 16. Golden Rules Checklist

```
BEFORE APPROVING ANY PR — RUN THROUGH THIS LIST

  Core Quality
  ☐ The code does what the ticket says
  ☐ No magic strings or hardcoded config values
  ☐ Nullable reference types respected — no silent null dereferences
  ☐ Async/await propagated — no .Result / .Wait()
  ☐ CancellationToken threaded through all async paths

  Security
  ☐ No secrets in code, config files, or logs
  ☐ All endpoints have appropriate authorization
  ☐ User input validated at the boundary
  ☐ No SQL injection vectors

  Data
  ☐ EF Core queries projected (no full entity loads for read models)
  ☐ AsNoTracking() on read queries
  ☐ No N+1 queries

  Tests
  ☐ New behavior has test coverage
  ☐ Tests are named descriptively
  ☐ Integration paths tested against real infrastructure

  Observability
  ☐ Structured logging (no string interpolation in log calls)
  ☐ Exceptions logged with context before re-throw
  ☐ Correlation IDs propagated

  Design
  ☐ Interfaces used across layers
  ☐ Domain logic in domain layer, not service or controller
  ☐ No God classes
```

---

*Principal Engineer Code Review Guidelines v1.0 — .NET + Azure stack*
