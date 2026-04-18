# Integration Review Guidelines — Principal Engineer Perspective
> Deep expertise lens: REST APIs · Azure Service Bus · Event-Driven · gRPC · Webhooks · Third-Party SDKs · Contract Testing
> Use this for reviewing how systems connect, communicate, and remain reliable at their boundaries.

---

## Table of Contents

1. [Mental Model — What Integration Review Is](#1-mental-model)
2. [Integration Taxonomy](#2-integration-taxonomy)
3. [Pillar 1 — REST/HTTP API Integration](#3-rest-http)
4. [Pillar 2 — Azure Service Bus Integration](#4-service-bus)
5. [Pillar 3 — Event-Driven / Event Grid Integration](#5-event-driven)
6. [Pillar 4 — Azure Functions Integration Patterns](#6-azure-functions)
7. [Pillar 5 — gRPC / Internal Service Communication](#7-grpc)
8. [Pillar 6 — Third-Party / Vendor SDK Integration](#8-third-party)
9. [Pillar 7 — Webhook Integration](#9-webhooks)
10. [Pillar 8 — Database Integration Across Services](#10-database)
11. [Pillar 9 — Authentication & Authorization Between Services](#11-auth)
12. [Pillar 10 — Contract Testing & API Compatibility](#12-contract-testing)
13. [Pillar 11 — Resilience at Integration Points](#13-resilience)
14. [Pillar 12 — Observability at Integration Boundaries](#14-observability)
15. [Integration Anti-Patterns Catalogue](#15-anti-patterns)
16. [Integration Review Checklist (Consolidated)](#16-consolidated-checklist)

---

## 1. Mental Model

```
┌─────────────────────────────────────────────────────────────────────┐
│  INTEGRATION REVIEW = FAILURE BOUNDARY AUDIT                        │
│                                                                     │
│  Every integration point is a potential failure mode.              │
│  The question is not "does it work?" but:                          │
│                                                                     │
│    • What happens when the other side is slow?                     │
│    • What happens when the other side is down?                     │
│    • What happens when the message arrives twice?                  │
│    • What happens when the schema changes without notice?          │
│    • What happens when 10× more messages arrive than expected?     │
│                                                                     │
│  Integration is where most production incidents originate.         │
│  It deserves MORE scrutiny than internal code.                     │
└─────────────────────────────────────────────────────────────────────┘
```

**The Integration Review contract is three questions:**
1. **How does data get from A to B?** (protocol, format, transport)
2. **What guarantees are made?** (at-least-once, exactly-once, ordered?)
3. **What happens when it breaks?** (retry, DLQ, circuit break, compensate)

---

## 2. Integration Taxonomy

```
┌──────────────────────────────────────────────────────────────────────┐
│  INTEGRATION STYLES — CHOOSE DELIBERATELY                            │
├────────────────────┬─────────────────┬───────────────────────────────┤
│ Style              │ Azure Service   │ Best For                       │
├────────────────────┼─────────────────┼───────────────────────────────┤
│ Synchronous HTTP   │ APIM + AKS      │ Query, real-time response      │
│ Async Message      │ Service Bus     │ Commands, reliable delivery    │
│ Event Streaming    │ Event Hubs      │ High-volume telemetry, logs    │
│ Event Grid         │ Event Grid      │ Cloud events, fan-out          │
│ gRPC               │ AKS internal    │ High-perf internal service RPC │
│ Webhook            │ HTTPS callback  │ External push notifications    │
│ File/Batch         │ Blob + Functions│ Large data transfers, ETL      │
│ Database CDC       │ Cosmos Change   │ Event sourcing, replication    │
│                    │ Feed / SQL CDC  │                                │
└────────────────────┴─────────────────┴───────────────────────────────┘
```

**Decision Rule:**
- Use **synchronous** when the caller needs the result immediately to continue
- Use **asynchronous** when the operation can be processed later or by another service
- Use **events** when multiple consumers need to react to state changes

---

## 3. Pillar 1 — REST/HTTP API Integration

// ── Inbound & Outbound HTTP API Design ─────────────────────────

### Review Checklist

**API Client Design**
- [ ] Is `IHttpClientFactory` used — never `new HttpClient()`?
- [ ] Are named or typed HTTP clients registered in DI with base address and default headers?
- [ ] Are timeouts set explicitly on all outbound HTTP calls (not relying on OS defaults = infinite)?
- [ ] Are Polly retry policies applied via `AddPolicyHandler` — not inline try/catch loops?
- [ ] Is HTTP response status code checked before deserializing the body?
- [ ] Is the `Content-Type` header validated before assuming JSON structure?

**Request/Response Design**
- [ ] Are all API contracts documented in OpenAPI/Swagger?
- [ ] Are request models validated (FluentValidation) before processing?
- [ ] Is `ProblemDetails` (RFC 7807) the standard error envelope?
- [ ] Are 4xx errors (client errors) distinguished from 5xx errors (server errors)?
- [ ] Is HTTP caching implemented for idempotent resources (`Cache-Control`, `ETag`, `Last-Modified`)?
- [ ] Are large response bodies paginated?
- [ ] Is `gzip` compression enabled for large payloads?

**API Versioning**
- [ ] Is URL versioning used (`/api/v1/`)?
- [ ] Are deprecation headers present (`Deprecation`, `Sunset`) for old versions?
- [ ] Are both versions running simultaneously during the migration window?

### Red Flags

```csharp
// ❌ HttpClient created directly — socket exhaustion risk
var client = new HttpClient();
var response = await client.GetAsync("https://api.example.com/orders");

// ✅ Typed client via IHttpClientFactory
public class OrderApiClient(HttpClient httpClient)
{
    // WHY: HttpClientFactory manages connection pooling and DNS refresh
    public async Task<OrderDto?> GetOrderAsync(int id, CancellationToken ct)
    {
        var response = await httpClient.GetAsync($"/orders/{id}", ct);
        response.EnsureSuccessStatusCode(); // throws HttpRequestException on 4xx/5xx
        return await response.Content.ReadFromJsonAsync<OrderDto>(ct);
    }
}

// ❌ No timeout — caller hangs forever if payment API is slow
var response = await _httpClient.PostAsync("/payments", content);

// ✅ Timeout registered in DI
services.AddHttpClient<IPaymentClient, PaymentClient>(client =>
{
    client.BaseAddress = new Uri(config["PaymentApi:BaseUrl"]!);
    client.Timeout = TimeSpan.FromSeconds(10); // WHY: SLA requires < 10s payment response
})
.AddPolicyHandler(GetRetryPolicy())
.AddPolicyHandler(GetCircuitBreakerPolicy());

// ❌ Deserializing without checking status code
var order = await response.Content.ReadFromJsonAsync<OrderDto>(); // explodes on 404 body

// ✅ Defensive deserialization
if (!response.IsSuccessStatusCode)
{
    var problem = await response.Content.ReadFromJsonAsync<ProblemDetails>();
    throw new ExternalApiException(problem?.Title ?? "Unknown error", response.StatusCode);
}
var order = await response.Content.ReadFromJsonAsync<OrderDto>(ct);
```

---

## 4. Pillar 2 — Azure Service Bus Integration

// ── Topics · Queues · Sessions · DLQ · Outbox ──────────────────

### Review Checklist

**Producer Side**
- [ ] Is the Outbox pattern used to ensure message delivery is tied to the DB transaction?
- [ ] Are messages serialized to JSON with a documented schema version (`MessageVersion` property)?
- [ ] Are messages idempotent (same message sent twice produces same result)?
- [ ] Are `MessageId` values set to business-meaningful IDs (not Guid.NewGuid() alone) for deduplication?
- [ ] Are messages partitioned with a `PartitionKey` for ordering guarantees?
- [ ] Are large message payloads stored in Blob Storage (claim-check pattern) if > 256KB?

**Consumer Side**
- [ ] Is the consumer processing messages inside a try/catch with explicit `CompleteMessageAsync` on success?
- [ ] Is `AbandonMessageAsync` called on transient failures (so retry mechanism kicks in)?
- [ ] Is `DeadLetterMessageAsync` called on poison messages (unrecoverable) with a reason?
- [ ] Are message lock renewals implemented for long-running processing?
- [ ] Is idempotency enforced at the consumer (check if already processed before applying side effects)?

**Infrastructure**
- [ ] Is Dead Letter Queue (DLQ) monitored with alerting?
- [ ] Are message TTL values appropriate (not infinite)?
- [ ] Is Premium tier used when VNET integration is required?
- [ ] Are `MaxDeliveryCount` settings appropriate for the retry strategy?

### Key Pattern: Outbox + Service Bus

```csharp
// ── Outbox Pattern — atomic: DB write + message publish ─────────

// WHY: Without Outbox, a crash between SaveChanges and SendAsync
//      causes the DB to be updated but the message to be lost.
//      Outbox ensures both succeed or both are retried.

public class PlaceOrderCommandHandler(
    IOrderRepository orders,
    IOutboxRepository outbox,
    IUnitOfWork uow)
{
    public async Task<OrderId> Handle(PlaceOrderCommand cmd, CancellationToken ct)
    {
        var order = Order.Create(cmd.CustomerId, cmd.Items);

        await orders.AddAsync(order, ct);

        // Write message to outbox table in SAME transaction
        await outbox.AddAsync(new OutboxMessage
        {
            Id = Guid.NewGuid(),
            MessageType = nameof(OrderPlacedEvent),
            Payload = JsonSerializer.Serialize(new OrderPlacedEvent(order.Id)),
            CreatedAt = DateTimeOffset.UtcNow,
            Status = OutboxStatus.Pending
        }, ct);

        await uow.CommitAsync(ct); // single DB transaction
        return order.Id;
    }
}

// Separate background worker polls outbox and publishes to Service Bus
// If publish fails, outbox message remains Pending and retried

// ── Idempotent Consumer ──────────────────────────────────────────

public async Task ProcessMessageAsync(ServiceBusReceivedMessage msg, CancellationToken ct)
{
    var orderId = msg.ApplicationProperties["OrderId"]?.ToString();

    // WHY: Service Bus guarantees at-least-once delivery; we must handle duplicates
    if (await _processedMessageStore.ExistsAsync(msg.MessageId, ct))
    {
        await _processor.CompleteMessageAsync(msg, ct);
        return;
    }

    try
    {
        await _orderService.FulfillAsync(orderId, ct);
        await _processedMessageStore.MarkAsync(msg.MessageId, ct);
        await _processor.CompleteMessageAsync(msg, ct);
    }
    catch (TransientException)
    {
        // Will be redelivered after lock expires
        await _processor.AbandonMessageAsync(msg, ct);
    }
    catch (PoisonMessageException ex)
    {
        _logger.LogError(ex, "Poison message {MessageId}", msg.MessageId);
        await _processor.DeadLetterMessageAsync(msg, ex.Message, ex.ToString(), ct);
    }
}
```

---

## 5. Pillar 3 — Event-Driven / Event Grid Integration

// ── Cloud Events · Fan-Out · Event Schema ──────────────────────

### Review Checklist

- [ ] Are events modeled as immutable facts (past tense: `OrderPlaced`, `PaymentFailed`)?
- [ ] Are events using CloudEvents schema format for interoperability?
- [ ] Are event schemas versioned (`v1`, `v2`) with additive-only changes?
- [ ] Are breaking schema changes handled with a new event type (not mutation of old)?
- [ ] Is the event payload self-contained (include enough data so consumers don't need to call back)?
- [ ] Are event consumers decoupled from each other (no consumer knows about other consumers)?
- [ ] Are event Grid topics private (not publicly accessible)?
- [ ] Are retry policies and dead-lettering configured on Event Grid subscriptions?

### Event Schema Standards

```json
// ✅ CloudEvents format — interoperable and toolable
{
  "specversion": "1.0",
  "type": "com.evicore.orders.v1.OrderPlaced",
  "source": "/services/orders",
  "id": "ord-20240115-abc123",
  "time": "2024-01-15T10:30:00Z",
  "datacontenttype": "application/json",
  "data": {
    "orderId": "ord-abc123",
    "customerId": "cust-xyz789",
    "totalAmount": 250.00,
    "currency": "USD",
    "placedAt": "2024-01-15T10:30:00Z"
  }
}

// ❌ Thin event — forces consumers to call back (chattiness + coupling)
{
  "type": "OrderPlaced",
  "orderId": "ord-abc123"
  // WHY THIS IS BAD: every consumer now needs to HTTP GET /orders/ord-abc123
  // Under load, this creates N×consumers calls to the orders service
}
```

---

## 6. Pillar 4 — Azure Functions Integration Patterns

// ── Triggers · Bindings · Durable Functions ─────────────────────

### Review Checklist

**Trigger Design**
- [ ] Is the correct trigger used for the workload? (HTTP, Timer, Service Bus, Blob, Event Hubs)
- [ ] Are HTTP-triggered Functions behind APIM or protected with Function Key / AAD?
- [ ] Are Timer triggers using NCRONTAB expressions — tested for correct schedule?
- [ ] Are Service Bus-triggered Functions handling DLQ correctly?
- [ ] Is `maxConcurrentCalls` configured for Service Bus triggers to prevent overload?

**Durable Functions**
- [ ] Are long-running workflows using Durable Orchestrators — not plain Functions with Thread.Sleep?
- [ ] Are orchestrator functions deterministic (no random, DateTime.Now, or external calls outside Activities)?
- [ ] Are Activity inputs/outputs serializable?
- [ ] Are fan-out/fan-in patterns using `Task.WhenAll` on activity tasks?
- [ ] Is compensation logic implemented for failed sagas?

**Cold Start / Performance**
- [ ] Is Premium plan or Dedicated used for latency-sensitive Functions?
- [ ] Is Always On / pre-warmed instances configured?
- [ ] Are dependencies registered in static field (outside Function method) to survive across invocations?

```csharp
// ❌ DbContext recreated every invocation — no connection reuse
[Function("ProcessOrder")]
public async Task Run([ServiceBusTrigger("orders")] string message)
{
    var context = new OrderDbContext(...); // new connection every time
    await context.Orders.AddAsync(...);
}

// ✅ DbContext injected via DI (registered in Program.cs) — connection pool reused
public class ProcessOrderFunction(IOrderRepository orders, ILogger<ProcessOrderFunction> logger)
{
    [Function("ProcessOrder")]
    public async Task Run(
        [ServiceBusTrigger("orders", Connection = "ServiceBusConnection")] string message,
        CancellationToken ct)
    {
        // WHY: DI-injected repository uses scoped DbContext — properly lifetime managed
        var order = JsonSerializer.Deserialize<OrderMessage>(message);
        await orders.ProcessAsync(order, ct);
    }
}
```

---

## 7. Pillar 5 — gRPC / Internal Service Communication

// ── Protobuf Contracts · Streaming · Versioning ─────────────────

### Review Checklist

- [ ] Are `.proto` contracts stored in a shared repository / NuGet package (not copy-pasted)?
- [ ] Are proto fields using `optional` for backward compatibility?
- [ ] Are field numbers never reused (even for removed fields)?
- [ ] Is TLS configured for all gRPC channels (mTLS for zero-trust)?
- [ ] Are gRPC status codes used correctly (NOT_FOUND vs INVALID_ARGUMENT vs INTERNAL)?
- [ ] Are deadlines propagated across gRPC calls (not just set at the entry point)?
- [ ] Is gRPC health checking (`grpc.health.v1`) implemented?
- [ ] Are streaming RPCs used only where necessary (not as a workaround for pagination)?

### Versioning Rules

```protobuf
// ✅ Safe field additions (backward compatible)
message OrderRequest {
  int32 order_id = 1;
  string customer_id = 2;
  optional string idempotency_key = 3; // NEW — optional, backward-compatible
}

// ❌ Field number reuse — breaks existing clients silently
message OrderRequest {
  int32 order_id = 1;
  // customer_id was field 2 — removed (don't reuse 2!)
  string new_field = 2; // DANGER: old clients still send customer_id on field 2
}

// ✅ Reserve removed field numbers
message OrderRequest {
  int32 order_id = 1;
  reserved 2; // WHY: Prevents future accidental reuse of removed customer_id field
  reserved "customer_id";
}
```

---

## 8. Pillar 6 — Third-Party / Vendor SDK Integration

// ── Abstraction · Version Lock · Fallback ───────────────────────

### Review Checklist

- [ ] Is every third-party SDK wrapped behind a domain interface (Anti-Corruption Layer)?
- [ ] Are third-party SDK types converted to internal domain types at the boundary?
- [ ] Are SDK versions pinned to specific versions (not floating `*`)?
- [ ] Is there a documented upgrade path for major SDK version changes?
- [ ] Are SDK-specific exceptions caught and wrapped in domain exceptions?
- [ ] Is the SDK configured via `IOptions<T>` from Key Vault — not hardcoded?
- [ ] Is the SDK client registered as Singleton where safe (verify thread safety in docs)?
- [ ] Is there a mock/stub implementation for local development (no real API calls in dev)?

```csharp
// ── Anti-Corruption Layer for Third-Party SDK ────────────────────

// Domain interface — pure, no third-party types
public interface IPaymentGateway
{
    Task<PaymentResult> ChargeAsync(PaymentRequest request, CancellationToken ct);
}

// Infrastructure adapter — SDK details isolated here
public class StripePaymentGateway(
    StripeClient stripe,  // third-party SDK type stays HERE only
    ILogger<StripePaymentGateway> logger)
    : IPaymentGateway
{
    public async Task<PaymentResult> ChargeAsync(PaymentRequest request, CancellationToken ct)
    {
        try
        {
            var options = new PaymentIntentCreateOptions   // Stripe-specific type
            {
                Amount = (long)(request.Amount * 100),    // Stripe uses cents
                Currency = request.Currency.ToLower(),
                Customer = request.CustomerId.Value
            };

            var intent = await stripe.PaymentIntents.CreateAsync(options, cancellationToken: ct);

            // WHY: Convert Stripe's domain type to our domain type here — callers never see Stripe
            return PaymentResult.Success(intent.Id, intent.Status);
        }
        catch (StripeException ex)
        {
            logger.LogError(ex, "Stripe charge failed for order {OrderId}", request.OrderId);
            // WHY: Wrap vendor exception — domain layer cannot reference StripeException
            throw new PaymentGatewayException("Payment processing failed", ex);
        }
    }
}
```

---

## 9. Pillar 7 — Webhook Integration

// ── Inbound · Outbound · Signature Validation ──────────────────

### Review Checklist

**Inbound Webhooks (receiving from external systems)**
- [ ] Is the webhook signature validated (HMAC-SHA256 or provider-specific header)?
- [ ] Is webhook processing asynchronous (return 200 immediately, process via queue)?
- [ ] Is idempotency enforced (webhook may be delivered multiple times)?
- [ ] Is the webhook secret rotatable without downtime?
- [ ] Is the request body read once and cached (re-reading stream breaks signature validation)?

**Outbound Webhooks (sending to customer systems)**
- [ ] Are retries implemented with exponential backoff for failed deliveries?
- [ ] Is the webhook payload signed with HMAC so receivers can validate authenticity?
- [ ] Are webhook delivery logs stored for debugging/replay?
- [ ] Is a configurable retry window (e.g., 24 hours) in place, after which the delivery is abandoned?
- [ ] Is the customer's endpoint validated (reachable, HTTPS-only)?

### Signature Validation Pattern

```csharp
// ── Inbound Webhook Signature Validation ────────────────────────

[ApiController]
public class WebhookController(
    IWebhookProcessor processor,
    IOptions<WebhookOptions> options) : ControllerBase
{
    [HttpPost("webhooks/github")]
    public async Task<IActionResult> Receive(CancellationToken ct)
    {
        // WHY: Read body once — stream is forward-only
        Request.EnableBuffering();
        using var reader = new StreamReader(Request.Body, leaveOpen: true);
        var rawBody = await reader.ReadToEndAsync(ct);
        Request.Body.Position = 0;

        // WHY: Validate HMAC before any processing — reject forged webhooks early
        var signature = Request.Headers["X-Hub-Signature-256"].ToString();
        if (!ValidateSignature(rawBody, signature, options.Value.Secret))
            return StatusCode(401);

        // WHY: Return 200 immediately — long processing causes provider timeout + retry storm
        _ = processor.EnqueueAsync(rawBody, ct); // fire-and-forget via queue
        return Ok();
    }

    private static bool ValidateSignature(string body, string signature, string secret)
    {
        var key = Encoding.UTF8.GetBytes(secret);
        var bodyBytes = Encoding.UTF8.GetBytes(body);
        var hash = HMACSHA256.HashData(key, bodyBytes);
        var expected = "sha256=" + Convert.ToHexString(hash).ToLower();
        // WHY: CryptographicOperations.FixedTimeEquals prevents timing attacks
        return CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(expected),
            Encoding.UTF8.GetBytes(signature));
    }
}
```

---

## 10. Pillar 8 — Database Integration Across Services

// ── Data Ownership · CDC · Cross-Service Query ──────────────────

### Review Checklist

- [ ] Is each service's database completely private (no other service has credentials)?
- [ ] Is cross-service data access via API calls or events — never direct SQL queries?
- [ ] Is Change Data Capture (CDC) used where event sourcing from legacy DB is needed?
- [ ] Are read models denormalized and owned by the consuming service?
- [ ] Is eventual consistency explicitly acknowledged in the design with documented lag bounds?
- [ ] Are data migrations backward compatible during rolling deployments?

### Expand-Contract Pattern for Zero-Downtime Migrations

```
┌───────────────────────────────────────────────────────────────────┐
│  EXPAND-CONTRACT MIGRATION PATTERN                                │
│                                                                   │
│  Goal: Rename column customer_id → client_id without downtime     │
│                                                                   │
│  Phase 1 — EXPAND (deploy new app version that writes both cols)  │
│   ALTER TABLE Orders ADD COLUMN client_id INT;                    │
│   App writes to BOTH customer_id AND client_id                    │
│                                                                   │
│  Phase 2 — BACKFILL (background job)                              │
│   UPDATE Orders SET client_id = customer_id WHERE client_id IS NULL│
│                                                                   │
│  Phase 3 — MIGRATE (deploy app version that reads new column)     │
│   App reads from client_id; still writes both (backward compat)   │
│                                                                   │
│  Phase 4 — CONTRACT (after all consumers are on new version)      │
│   ALTER TABLE Orders DROP COLUMN customer_id;                     │
│   Remove dual-write from app                                      │
└───────────────────────────────────────────────────────────────────┘
```

---

## 11. Pillar 9 — Authentication & Authorization Between Services

// ── Service-to-Service Auth · Workload Identity · JWT ───────────

### Review Checklist

**Service Identity**
- [ ] Are Azure Managed Identities used for all Azure service connections (zero secrets)?
- [ ] Is Workload Identity Federation used for AKS pods calling Azure APIs?
- [ ] Are service-to-service calls authenticated (not "trust the network")?
- [ ] Are client credentials (OAuth 2.0) used for service-to-service JWT tokens?

**Token Validation**
- [ ] Are JWT tokens validated for: issuer, audience, expiry, algorithm (`alg: RS256` — not `none`)?
- [ ] Is token signature verified against the identity provider's public key (JWKS endpoint)?
- [ ] Are tokens short-lived (< 15 minutes for access tokens)?
- [ ] Is token caching with proactive refresh implemented (not fetching a new token on every request)?

**Zero-Trust Principles**
- [ ] Is mTLS used for internal service communication in AKS (via Istio or Linkerd)?
- [ ] Are network policies restricting which pods can communicate (not open mesh)?
- [ ] Are secrets never passed as environment variables in plain text?

```csharp
// ── Managed Identity Token Acquisition for Service-to-Service ───

// WHY: No passwords, no rotation, no secrets — Azure manages the credential lifecycle
public class SecureApiClient(HttpClient httpClient, TokenCredential credential)
{
    private AccessToken _cachedToken;
    private static readonly string[] Scopes = ["https://management.azure.com/.default"];

    public async Task<OrderDto?> GetOrderAsync(int id, CancellationToken ct)
    {
        // WHY: Cache token and refresh proactively — avoid token fetch on every request
        if (_cachedToken.ExpiresOn < DateTimeOffset.UtcNow.AddMinutes(2))
        {
            _cachedToken = await credential.GetTokenAsync(
                new TokenRequestContext(Scopes), ct);
        }

        httpClient.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", _cachedToken.Token);

        return await httpClient.GetFromJsonAsync<OrderDto>($"/orders/{id}", ct);
    }
}
```

---

## 12. Pillar 10 — Contract Testing & API Compatibility

// ── Consumer-Driven Contracts · Pact · OpenAPI Diff ─────────────

### Review Checklist

- [ ] Are API contracts (OpenAPI specs) committed to source control?
- [ ] Is OpenAPI diff run in CI to detect breaking changes (removed fields, changed types)?
- [ ] Are consumer-driven contract tests (Pact) in place for critical service pairs?
- [ ] Are integration tests running against the real service (not mocked HTTP)?
- [ ] Are API compatibility policies documented (no breaking changes without major version bump)?

**Breaking vs Non-Breaking Changes**

```
┌──────────────────────────────────────────────────────────────────┐
│  API CHANGE COMPATIBILITY MATRIX                                 │
├──────────────────────────┬──────────────┬────────────────────────┤
│ Change                   │ Safe?        │ Action Required         │
├──────────────────────────┼──────────────┼────────────────────────┤
│ Add optional field       │ ✅ Yes       │ None                   │
│ Add new endpoint         │ ✅ Yes       │ None                   │
│ Add new enum value       │ ⚠️ Careful   │ Check consumer default │
│ Remove field             │ ❌ No        │ Major version bump     │
│ Rename field             │ ❌ No        │ Major version bump     │
│ Change field type        │ ❌ No        │ Major version bump     │
│ Remove endpoint          │ ❌ No        │ Deprecate + 6 mo wait  │
│ Change error format      │ ❌ No        │ Major version bump     │
│ Change auth scheme       │ ❌ No        │ Coordinated migration  │
└──────────────────────────┴──────────────┴────────────────────────┘
```

---

## 13. Pillar 11 — Resilience at Integration Points

// ── Polly · Timeout · Circuit Breaker · Bulkhead ───────────────

### Review Checklist

- [ ] Is there a retry policy for every outbound HTTP call (exponential backoff + jitter)?
- [ ] Are circuit breakers in place for all external dependencies?
- [ ] Are timeouts set at every integration boundary (HTTP, DB, message bus)?
- [ ] Is the bulkhead pattern isolating high-risk external calls from critical paths?
- [ ] Are fallback strategies defined for degraded operation (cache, default response, reject gracefully)?
- [ ] Is jitter added to retry delays to prevent synchronized retry storms?

### Canonical Polly Configuration

```csharp
// ── Resilience Pipeline for External HTTP Integration ────────────

// WHY: Without this, a slow payment API will exhaust the thread pool
//      and take down the entire orders service via cascading failure

services.AddHttpClient<IPaymentClient, PaymentClient>()
    .AddResilienceHandler("payment-api", builder =>
    {
        // Retry: 3 attempts, exponential backoff 1s/2s/4s + jitter
        builder.AddRetry(new HttpRetryStrategyOptions
        {
            MaxRetryAttempts = 3,
            Delay = TimeSpan.FromSeconds(1),
            BackoffType = DelayBackoffType.Exponential,
            UseJitter = true,  // WHY: Prevents synchronized retry storms from all pods
            ShouldHandle = args => args.Outcome switch
            {
                { Exception: HttpRequestException } => PredicateResult.True(),
                { Result.StatusCode: HttpStatusCode.TooManyRequests } => PredicateResult.True(),
                { Result.StatusCode: HttpStatusCode.ServiceUnavailable } => PredicateResult.True(),
                _ => PredicateResult.False()
            }
        });

        // Circuit breaker: open after 50% failure rate over 30 seconds
        builder.AddCircuitBreaker(new HttpCircuitBreakerStrategyOptions
        {
            FailureRatio = 0.5,
            SamplingDuration = TimeSpan.FromSeconds(30),
            MinimumThroughput = 10,
            BreakDuration = TimeSpan.FromSeconds(30),
            OnOpened = args =>
            {
                // WHY: Log circuit open so ops team knows payment API is degraded
                logger.LogWarning("Payment API circuit opened — using degraded mode");
                return ValueTask.CompletedTask;
            }
        });

        // Timeout: individual attempt timeout
        builder.AddTimeout(TimeSpan.FromSeconds(10));
    });
```

---

## 14. Pillar 12 — Observability at Integration Boundaries

// ── Distributed Tracing · Integration Metrics ──────────────────

### Review Checklist

- [ ] Are W3C TraceContext headers (`traceparent`, `tracestate`) propagated across all integration calls?
- [ ] Are Service Bus messages including trace context in application properties?
- [ ] Are integration latency metrics measured per endpoint (P50, P95, P99)?
- [ ] Are error rates measured per dependency (not just aggregated)?
- [ ] Are dependency call durations tracked in Application Insights automatically?
- [ ] Are DLQ message counts alerted on threshold?
- [ ] Are outgoing message counts and lag metrics tracked (consumer group lag for Event Hubs)?

### Trace Context Propagation in Service Bus

```csharp
// ── Propagate OpenTelemetry trace context into Service Bus message ─

public async Task PublishAsync<T>(T @event, CancellationToken ct) where T : IEvent
{
    var message = new ServiceBusMessage(JsonSerializer.Serialize(@event))
    {
        MessageId = @event.EventId.ToString(),
        Subject = typeof(T).Name,
        ContentType = "application/json"
    };

    // WHY: Without this, the trace breaks at the Service Bus boundary —
    //      consumer has no link back to the originating request trace
    var activity = Activity.Current;
    if (activity is not null)
    {
        message.ApplicationProperties["traceparent"] = activity.Id;
        message.ApplicationProperties["tracestate"] = activity.TraceStateString;
    }

    await _sender.SendMessageAsync(message, ct);
}

// Consumer restores the trace context:
public async Task ProcessMessageAsync(ServiceBusReceivedMessage msg, CancellationToken ct)
{
    // WHY: Create a linked activity so this consumer span appears under the originating trace
    var parentContext = msg.ApplicationProperties.TryGetValue("traceparent", out var tp)
        ? ActivityContext.TryParse(tp.ToString()!, null, out var ctx) ? ctx : default
        : default;

    using var activity = _activitySource.StartActivity(
        "ProcessOrder",
        ActivityKind.Consumer,
        parentContext);

    await ProcessAsync(msg, ct);
}
```

---

## 15. Integration Anti-Patterns Catalogue

| Anti-Pattern | Description | Impact | Fix |
|---|---|---|---|
| **Synchronous Chain** | A→B→C→D all synchronous HTTP; D is slow, A times out | Full cascade failure | Use async messaging for non-critical steps |
| **Chatty Integration** | 50 HTTP calls to build one page | High latency, thundering herd | BFF/aggregator pattern or GraphQL |
| **Shared Database** | Two services sharing the same schema | Schema coupling, deployment coupling | Each service owns its data |
| **Fire and Forget** | Message sent, no delivery guarantee | Silent data loss | Outbox pattern |
| **No Idempotency** | Processing the same message twice creates duplicate orders | Data corruption | Idempotency keys + deduplication store |
| **Versioning Ignored** | JSON fields renamed without coordination | Consumer crashes | Additive-only schema changes + versions |
| **No DLQ Monitoring** | Dead-letter queue fills silently for days | Messages lost, no visibility | Alert on DLQ message count |
| **SDK Leaked** | Third-party types used throughout application layers | Vendor lock-in, uncontrolled upgrades | Anti-Corruption Layer (ACL) |
| **No Circuit Breaker** | External API outage → thread pool exhaustion → service down | Cascading failure | Polly circuit breaker on all externals |
| **Webhook Synchronous** | Webhook handler does all processing synchronously | Provider retries, causes duplicate processing | Queue-based async processing |
| **Timeout Not Set** | Default OS socket timeout (infinite / 300s) used | Request hangs, resources held | Explicit timeout on every external call |
| **Token Per Request** | New OAuth2 token fetched on every outbound HTTP request | 2× latency, identity provider throttled | Token cache with proactive refresh |

---

## 16. Integration Review Checklist (Consolidated)

```
INTEGRATION REVIEW — MASTER CHECKLIST

  HTTP/REST Integration
  ☐ IHttpClientFactory used — never new HttpClient()
  ☐ Timeout set on all outbound calls
  ☐ Retry + circuit breaker via Polly
  ☐ Status code checked before deserializing
  ☐ ProblemDetails for error responses

  Service Bus Integration
  ☐ Outbox pattern for atomic DB + publish
  ☐ Idempotency enforced in consumer
  ☐ DLQ monitored with alerting
  ☐ Message schema versioned
  ☐ Lock renewal for long-running processing

  Event-Driven
  ☐ Events are immutable past-tense facts
  ☐ CloudEvents schema for interoperability
  ☐ Schema additive-only changes
  ☐ Dead-lettering configured

  Third-Party SDKs
  ☐ Anti-Corruption Layer (ACL) wrapping all SDK types
  ☐ SDK version pinned
  ☐ Vendor exceptions wrapped in domain exceptions
  ☐ Mock implementation for local dev

  Webhooks
  ☐ Signature validated before processing
  ☐ Body read once and buffered
  ☐ 200 returned immediately (async processing)
  ☐ Idempotency enforced

  Authentication
  ☐ Managed Identity / Workload Identity for Azure services
  ☐ JWT validated (issuer, audience, expiry, alg)
  ☐ Token cached with proactive refresh
  ☐ mTLS for internal service communication

  Contract Quality
  ☐ OpenAPI spec committed to source control
  ☐ Breaking change detection in CI
  ☐ Consumer-driven contract tests for critical pairs

  Resilience
  ☐ Every external call has: timeout + retry + circuit breaker
  ☐ Jitter on retry delays
  ☐ Fallback defined for degraded mode

  Observability
  ☐ W3C trace context propagated across all integration calls
  ☐ Integration latency measured per dependency
  ☐ Error rate per dependency alerted
  ☐ DLQ message count alerted
```

---

*Principal Engineer Integration Review Guidelines v1.0 — .NET + Azure stack*
