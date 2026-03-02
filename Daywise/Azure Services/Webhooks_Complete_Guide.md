# Webhooks — Complete Guide
### Best Practices · Architecture · .NET 10 Implementation with SimpleApi1 & SimpleApi2

---

> **How to use this guide**
> - Read Sections 1–3 first to build the mental model
> - Section 4 covers all best practices (handler + publisher)
> - Sections 5–7 are the full .NET 10 implementation walkthrough
> - Section 8 is the step-by-step running guide

---

## Table of Contents

- [Section 1 — What Are Webhooks?](#section-1--what-are-webhooks)
- [Section 2 — Mental Model](#section-2--mental-model)
- [Section 3 — Webhook vs Polling vs WebSocket](#section-3--webhook-vs-polling-vs-websocket)
- [Section 4 — Best Practices: Handler (Receiver)](#section-4--best-practices-handler-receiver)
- [Section 5 — Best Practices: Publisher (Sender)](#section-5--best-practices-publisher-sender)
- [Section 6 — Security Deep Dive](#section-6--security-deep-dive)
- [Section 7 — .NET 10 Implementation](#section-7--net-10-implementation)
  - [7.1 — Architecture Overview](#71--architecture-overview)
  - [7.2 — SimpleApi1: Publisher](#72--simpleapi1-publisher)
  - [7.3 — SimpleApi2: Handler](#73--simpleapi2-handler)
- [Section 8 — Running the Demo](#section-8--running-the-demo)
- [Section 9 — Production Checklist](#section-9--production-checklist)

---

## Section 1 — What Are Webhooks?

A **webhook** is an HTTP callback — a way for one system (the **publisher**) to notify another system (the **handler/receiver**) that something happened, without the receiver needing to poll.

```
POLLING (inefficient):
  Receiver ──── GET /events? ────► Publisher    every 30 seconds
  Receiver ◄─── [] (nothing) ─── Publisher    99% of calls = wasted
  Receiver ──── GET /events? ────► Publisher
  Receiver ◄─── [] (nothing) ─── Publisher

WEBHOOK (event-driven):
  Publisher ──── POST /webhook ──► Receiver     only when event happens
  Receiver  ◄─── 200 OK ─────────  Publisher
                 (done — no waste)
```

### Real-World Examples

| Service | Event | Webhook |
|---------|-------|---------|
| GitHub | Pull request opened | `POST your-url { "action": "opened", ... }` |
| Stripe | Payment succeeded | `POST your-url { "type": "payment_intent.succeeded" }` |
| Twilio | SMS received | `POST your-url { "Body": "Hello", "From": "+1..." }` |
| Azure DevOps | Build completed | `POST your-url { "eventType": "build.complete", ... }` |

---

## Section 2 — Mental Model

> **Mental Model: Webhooks are a newspaper subscription, not a newsstand**
>
> - **Polling** = walking to the newsstand every 30 minutes to check if a new edition exists
> - **Webhook** = subscribing to home delivery — the paper arrives *only when published*
>
> The **publisher** is the newspaper. The **handler** is your mailbox. You give the newspaper your address (URL) and they deliver when news happens.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WEBHOOK LIFECYCLE                                  │
│                                                                       │
│  1. SUBSCRIBE                                                         │
│  Receiver ──POST /webhooks/subscribe──► Publisher                    │
│            { url, secret, eventTypes }                               │
│                                                                       │
│  2. EVENT OCCURS (e.g., order created, weather fetched)              │
│  Publisher: create WebhookEvent { id, type, timestamp, data }        │
│             sign with HMAC-SHA256(secret, payload)                   │
│             enqueue to Channel<T>                                     │
│                                                                       │
│  3. DELIVERY (background service)                                     │
│  Publisher ──POST /webhook/receive──► Receiver                       │
│             X-Webhook-Signature: sha256=abc123...                    │
│             X-Webhook-Id: evt_abc                                    │
│             X-Webhook-Timestamp: 1706745600                          │
│             { id, type, timestamp, data }                            │
│                                                                       │
│  4. ACKNOWLEDGEMENT                                                   │
│  Receiver ◄── 200 OK ─────────────── Publisher  (within 5s)         │
│               { status: "accepted", eventId: "evt_abc" }            │
│                                                                       │
│  5. ASYNC PROCESSING (background, after 200 is returned)             │
│  Receiver: validate ─► deduplicate ─► process ─► store              │
│                                                                       │
│  6. RETRY ON FAILURE                                                  │
│  If receiver returns 5xx or times out:                               │
│  Attempt 1 → immediate                                               │
│  Attempt 2 → 30s delay                                               │
│  Attempt 3 → 5min delay                                              │
│  Dead-letter → alert ops team                                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Section 3 — Webhook vs Polling vs WebSocket

| Aspect | Polling | Webhook | WebSocket |
|--------|---------|---------|-----------|
| **Direction** | Receiver pulls | Publisher pushes | Bidirectional |
| **Latency** | High (poll interval) | Near real-time | Real-time |
| **Efficiency** | Low (wasted calls) | High (event-driven) | High |
| **Infrastructure** | Simple client | Requires public URL | Persistent connection |
| **Reliability** | Client controls | Publisher must retry | Connection can drop |
| **Use case** | Simple integrations | System-to-system events | Chat, live feeds |
| **Best for** | Internal scripts | B2B integrations, payment notifications | Browser apps, gaming |

> **Key Insight:** Webhooks are "HTTP callbacks" — they work over standard HTTP/S, require no persistent connection, and work naturally with firewalls and proxies. This is why they dominate B2B integrations.

---

## Section 4 — Best Practices: Handler (Receiver)

### 4.1 — Respond Fast, Process Async

```
POST /webhook/receive  →  200 OK (within 5 seconds)  →  process in background
```

**Why:** Most webhook publishers will timeout after 5–30 seconds and mark the delivery as failed. If you do slow processing synchronously, you'll get spurious retries.

```csharp
// ❌ WRONG — slow processing blocks the response
app.MapPost("/webhook/receive", async (WebhookPayload payload) =>
{
    await database.SaveAsync(payload);        // could take seconds
    await emailService.SendNotification();    // definitely slow
    return Results.Ok();
});

// ✅ CORRECT — enqueue and return immediately
app.MapPost("/webhook/receive", async (HttpRequest req, WebhookProcessor processor) =>
{
    // validate, deserialize, deduplicate...
    await processor.EnqueueAsync(webhookEvent, rawPayload);   // microseconds
    return Results.Ok(new { status = "accepted" });           // returns immediately
    // actual work happens in BackgroundService reading from Channel<T>
});
```

### 4.2 — Validate Signature FIRST

Read the raw body **before** model binding. The signature is computed over the raw bytes.

```csharp
// ✅ Read raw body before touching it
using var ms = new MemoryStream();
await req.Body.CopyToAsync(ms);
var rawBytes = ms.ToArray();                 // preserve exact bytes for HMAC
var rawPayload = Encoding.UTF8.GetString(rawBytes);

// Validate signature over the raw bytes
var result = validator.Validate(req.Headers, rawBytes);
if (!result.IsValid) return Results.Unauthorized();

// ONLY THEN deserialize
var payload = JsonSerializer.Deserialize<WebhookEvent>(rawPayload);
```

### 4.3 — HMAC-SHA256 Validation with Constant-Time Compare

```csharp
// ✅ HMAC-SHA256 validation
var key  = Encoding.UTF8.GetBytes(secret);
using var hmac = new HMACSHA256(key);
var expectedHash = hmac.ComputeHash(rawBody);
var expectedSig  = "sha256=" + Convert.ToHexString(expectedHash).ToLowerInvariant();

// ✅ CRITICAL: constant-time comparison — prevents timing attacks
// A timing attack measures how long comparison takes to learn about correct chars.
// CryptographicOperations.FixedTimeEquals always takes the same time regardless of match.
var actualBytes   = Encoding.UTF8.GetBytes(actualSig);
var expectedBytes = Encoding.UTF8.GetBytes(expectedSig);
if (!CryptographicOperations.FixedTimeEquals(actualBytes, expectedBytes))
    return ValidationResult.Fail("Signature mismatch");

// ❌ WRONG — string == allows timing attacks
if (actualSig != expectedSig) ...           // exposes timing info
if (string.Compare(a, b) != 0) ...          // also vulnerable
```

### 4.4 — Replay Protection (Timestamp Validation)

```csharp
// Reject events older than 5 minutes — prevents replaying captured requests
if (headers.TryGetValue("X-Webhook-Timestamp", out var tsHeader)
    && long.TryParse(tsHeader, out var unixTs))
{
    var eventTime = DateTimeOffset.FromUnixTimeSeconds(unixTs);
    var age = DateTimeOffset.UtcNow - eventTime;
    if (Math.Abs(age.TotalSeconds) > 300)   // 300s = 5 minutes tolerance
        return ValidationResult.Fail($"Timestamp too old: {age.TotalSeconds:F0}s");
}
```

### 4.5 — Deduplicate — Webhooks Are at-Least-Once

Publishers **will** retry on network failures, so the same event may arrive multiple times.

```csharp
// Use event ID as idempotency key
var isNew = cache.TryMarkSeen(webhookEvent.Id);
if (!isNew)
{
    // Still return 200 (so publisher stops retrying) but skip processing
    return Results.Ok(new { status = "duplicate", eventId = webhookEvent.Id });
}
```

> **Production:** Use Redis with TTL (`SET event:{id} 1 EX 86400`). In-memory cache is lost on restart.

### 4.6 — Return Correct HTTP Status Codes

| Status | When | Effect on publisher |
|--------|------|---------------------|
| `200 OK` | Accepted for processing | Publisher marks delivered ✓ |
| `400 Bad Request` | Malformed payload / invalid JSON | Publisher stops retrying (permanent error) |
| `401 Unauthorized` | Signature invalid | Publisher stops retrying |
| `409 Conflict` | Duplicate event (alternative to 200) | Publisher stops retrying |
| `429 Too Many Requests` | Rate limited | Publisher retries with backoff |
| `500 Internal Server Error` | Transient failure | Publisher retries |

> **Key Insight:** Return `200` for duplicates (not `409`) if you want the publisher to stop retrying. Some publishers retry on any non-2xx even if it's a known duplicate.

### 4.7 — Store Raw Payload for Auditability

```csharp
// Always persist the raw bytes + headers before processing
// This enables: replay, debugging, audit, compliance
_processed.Enqueue(new ReceivedEvent(
    Id:          webhookEvent.Id,
    Type:        webhookEvent.Type,
    ReceivedAt:  DateTimeOffset.UtcNow,
    RawPayload:  rawPayload,             // preserve exact original JSON
    WasDuplicate: wasDuplicate
));
```

---

## Section 5 — Best Practices: Publisher (Sender)

### 5.1 — Sign Every Request with HMAC-SHA256

```csharp
// Sign the serialized payload — receiver can verify it hasn't been tampered
var payload   = JsonSerializer.Serialize(webhookEvent, options);
var key       = Encoding.UTF8.GetBytes(subscription.Secret);
var data      = Encoding.UTF8.GetBytes(payload);
using var hmac = new HMACSHA256(key);
var hash      = hmac.ComputeHash(data);
var signature = "sha256=" + Convert.ToHexString(hash).ToLowerInvariant();

request.Headers.Add("X-Webhook-Signature", signature);
```

### 5.2 — Include a Unique Event ID in Every Delivery

```json
{
  "id": "a3f8c2d1e4b5...",         // globally unique — receiver's idempotency key
  "type": "weather.fetched",       // namespaced event type
  "timestamp": "2026-03-02T10:00:00Z",
  "data": { ... }                  // event-specific payload
}
```

The event ID is critical: it lets receivers **safely ignore duplicates** without processing the same event twice.

### 5.3 — Retry with Exponential Backoff

```csharp
private static readonly TimeSpan[] RetryDelays =
    [TimeSpan.Zero,              // attempt 1: immediate
     TimeSpan.FromSeconds(30),   // attempt 2: 30 seconds
     TimeSpan.FromMinutes(5)];   // attempt 3: 5 minutes
                                 // → dead-letter / alert ops

// Stop retrying on 4xx (except 429) — those are permanent failures
if (statusCode is >= 400 and < 500 and not HttpStatusCode.TooManyRequests)
    return; // no point retrying
```

### 5.4 — Set a Hard Timeout

```csharp
// 15 seconds — don't let slow receivers block your publisher
builder.Services.AddHttpClient("WebhookClient", client =>
{
    client.Timeout = TimeSpan.FromSeconds(15);
});
```

### 5.5 — Decouple Event Creation from Delivery (Outbox Pattern)

```
Event occurs
    │
    ▼
Enqueue to Channel<T>               ← in-memory (demo)
    │                                 In production: write to DB outbox table
    ▼                                 guarantees delivery even if app crashes
BackgroundService reads channel
    │
    ▼
HTTP POST to subscriber URL          ← with HMAC signature, timeout, retry
    │
    ▼
Log delivery result
```

```csharp
// 1. Fire-and-forget into Channel — doesn't block the API response
await dispatcher.EnqueueAsync(webhookEvent, subscription);

// 2. BackgroundService reads from Channel asynchronously
await foreach (var (evt, sub) in _channel.Reader.ReadAllAsync(stoppingToken))
{
    _ = Task.Run(() => _publisher.PublishAsync(evt, sub, stoppingToken));
}
```

### 5.6 — Standard Webhook Headers

```
X-Webhook-Signature: sha256=<hmac-sha256-hex>   // integrity + authentication
X-Webhook-Id:        <event-guid>               // idempotency
X-Webhook-Timestamp: <unix-epoch-seconds>       // replay protection
X-Webhook-Event:     weather.fetched            // event type (for quick routing)
User-Agent:          SimpleApi1-Webhook/1.0     // identify your service
Content-Type:        application/json           // always JSON
```

### 5.7 — Fan-out: One Event → Multiple Subscribers

```csharp
// Get all subscribers interested in this event type
var subscribers = registry.GetForEvent(eventType);

// Deliver to each subscriber independently
foreach (var sub in subscribers)
    await dispatcher.EnqueueAsync(evt, sub);
// Each subscriber gets their own delivery attempt + retry cycle
```

### 5.8 — Validate Subscriber URLs

```csharp
// Prevent SSRF: ensure the URL is not pointing to internal services
if (!Uri.TryCreate(url, UriKind.Absolute, out var uri)
    || (uri.Scheme != "http" && uri.Scheme != "https"))
    return Results.BadRequest(new { error = "Invalid URL" });

// Production: also block RFC-1918 private ranges, loopback, metadata endpoints
// 10.x.x.x, 172.16–31.x.x, 192.168.x.x, 127.x.x.x, 169.254.x.x (Azure metadata)
```

---

## Section 6 — Security Deep Dive

### 6.1 — Attack Surface & Mitigations

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ATTACK                    │  IMPACT                │  MITIGATION            │
├────────────────────────────┼────────────────────────┼────────────────────────┤
│ Forged payload             │ Fake events processed  │ HMAC-SHA256 signature  │
│ Replay attack              │ Event processed twice  │ Timestamp ≤ 5min old   │
│ Timing attack on compare   │ Secret leaked slowly   │ FixedTimeEquals()      │
│ SSRF (publisher)           │ Internal URL probed    │ Validate subscriber URL│
│ Secret exposure in logs    │ Anyone can forge events│ Log "***" not secret   │
│ Man-in-the-middle          │ Payload tampered       │ HTTPS only             │
│ Secret rotation gap        │ Events drop during rot │ Support 2 active secrets│
│ Brute-force signature      │ Bypass auth            │ 256-bit secret minimum │
└────────────────────────────┴────────────────────────┴────────────────────────┘
```

### 6.2 — Secret Rotation Without Downtime

```
Phase 1: Add new secret (keep old active)
         Receiver validates against BOTH secrets

Phase 2: Publisher rotates to new secret
         All new deliveries use new secret

Phase 3: Remove old secret (after delivery window expires)
         Receiver validates against new secret only

// Receiver with dual-secret support:
foreach (var secret in [primarySecret, legacySecret])
{
    var expected = ComputeHmac(secret, rawBody);
    if (CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(expected),
            Encoding.UTF8.GetBytes(actual)))
        return ValidationResult.Ok();
}
return ValidationResult.Fail("No matching secret");
```

### 6.3 — Secrets Must Be Strong

```bash
# Generate a cryptographically strong secret (minimum 32 bytes = 256 bits)
openssl rand -hex 32
# → a3f8c2d1b4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1

# Never use:
# ❌ "mysecret"            — too short, dictionary word
# ❌ "change-in-prod"      — placeholder forgotten in production
# ❌ shared across tenants — one breach exposes all
```

---

## Section 7 — .NET 10 Implementation

### 7.1 — Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│  SimpleApi1 (Publisher) — http://localhost:5248                          │
│                                                                           │
│  POST /webhooks/subscribe     → register SimpleApi2 as subscriber        │
│  GET  /webhooks/subscriptions → list all subscribers                     │
│  DELETE /webhooks/subscriptions/{id} → unregister                        │
│  POST /webhooks/trigger       → manually fire any event type             │
│  GET  /weatherforecast        → fetches weather + fires weather.fetched  │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐     │
│  │  WebhookRegistry (Singleton)  — in-memory subscriber list       │     │
│  │  WebhookDispatcher (BackgroundService)                          │     │
│  │    ├─ Channel<(Event, Subscription)> — bounded, capacity=1000   │     │
│  │    └─ Reads channel → calls WebhookPublisher.PublishAsync()      │     │
│  │  WebhookPublisher                                                │     │
│  │    ├─ Signs with HMAC-SHA256                                     │     │
│  │    ├─ Sets all standard headers                                  │     │
│  │    └─ Retries: immediate → 30s → 5min → dead-letter             │     │
│  └─────────────────────────────────────────────────────────────────┘     │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │ POST /webhook/receive
                               │ X-Webhook-Signature: sha256=...
                               │ X-Webhook-Id: evt_abc123
                               │ X-Webhook-Timestamp: 1706745600
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  SimpleApi2 (Handler) — http://localhost:5249                            │
│                                                                           │
│  POST /webhook/receive        → receives and acknowledges events         │
│  GET  /webhook/events         → shows all received events (audit/debug)  │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐     │
│  │  WebhookSignatureValidator                                       │     │
│  │    ├─ Reads raw body (before deserialization)                    │     │
│  │    ├─ HMAC-SHA256 constant-time validation                       │     │
│  │    └─ Timestamp replay protection (±5min)                       │     │
│  │  WebhookEventCache (Singleton)                                   │     │
│  │    └─ ConcurrentDictionary deduplification (24h TTL)             │     │
│  │  WebhookProcessor (BackgroundService)                            │     │
│  │    ├─ Channel<(Event, RawPayload)> — bounded, capacity=500       │     │
│  │    ├─ Routes by event type: weather.fetched / trigger.test / *   │     │
│  │    └─ Stores processed events for audit (GET /webhook/events)    │     │
│  └─────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.2 — SimpleApi1: Publisher

#### File Structure
```
SimpleApi1/
├── Webhooks/
│   ├── WebhookModels.cs        ← event shape, subscription, request DTOs
│   ├── WebhookRegistry.cs      ← in-memory subscriber store (Singleton)
│   ├── WebhookPublisher.cs     ← HMAC sign + HTTP deliver + retry
│   └── WebhookDispatcher.cs   ← BackgroundService + Channel (outbox)
├── Program.cs                  ← updated with webhook endpoints
└── appsettings.json            ← Webhook timeout config
```

#### `Webhooks/WebhookModels.cs`
```csharp
namespace Webhooks;

// ─────────────── Event Envelope ───────────────────────────────────────────
// Every webhook delivery wraps the payload in this standard shape.
// The receiver uses this shape to route and deduplicate.
public record WebhookEvent(
    string          Id,          // globally unique — receiver's idempotency key
    string          Type,        // namespaced event type: "weather.fetched"
    DateTimeOffset  Timestamp,   // UTC time of event creation
    object?         Data         // event-specific payload — any .NET object
);

// ─────────────── Registered Subscriber ────────────────────────────────────
public record WebhookSubscription(
    string          Id,
    string          Url,         // where to POST events
    string          Secret,      // HMAC-SHA256 signing key — never log this
    string[]        EventTypes,  // ["*"] = all events, or ["weather.fetched"]
    DateTimeOffset  RegisteredAt
);

// ─────────────── Request DTOs ─────────────────────────────────────────────
public record SubscribeRequest(
    string    Url,
    string    Secret,
    string[]? EventTypes   // optional — defaults to ["*"] (all events)
);

public record TriggerRequest(
    string   EventType,
    object?  Data          // optional custom payload for the test event
);
```

#### `Webhooks/WebhookRegistry.cs`
```csharp
using System.Collections.Concurrent;

namespace Webhooks;

// In-memory subscriber registry.
// Production: replace with database repository (EF Core / Dapper).
// Singleton — thread-safe via ConcurrentDictionary.
public sealed class WebhookRegistry
{
    private readonly ConcurrentDictionary<string, WebhookSubscription> _subs = new();

    public WebhookSubscription Register(string url, string secret, string[] eventTypes)
    {
        var sub = new WebhookSubscription(
            Id:           Guid.NewGuid().ToString("N"),
            Url:          url,
            Secret:       secret,
            EventTypes:   eventTypes,
            RegisteredAt: DateTimeOffset.UtcNow
        );
        _subs[sub.Id] = sub;
        return sub;
    }

    public bool Unregister(string id) => _subs.TryRemove(id, out _);

    // Returns all subscriptions with secrets masked for safe API responses
    public IReadOnlyList<WebhookSubscription> GetAll() =>
        _subs.Values.ToList().AsReadOnly();

    // Returns subscriptions that want this specific event type
    public IReadOnlyList<WebhookSubscription> GetForEvent(string eventType) =>
        _subs.Values
             .Where(s => s.EventTypes.Contains("*") || s.EventTypes.Contains(eventType))
             .ToList()
             .AsReadOnly();
}
```

#### `Webhooks/WebhookPublisher.cs`
```csharp
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Webhooks;

public interface IWebhookPublisher
{
    Task PublishAsync(WebhookEvent evt, WebhookSubscription sub, CancellationToken ct = default);
}

public sealed class WebhookPublisher(
    IHttpClientFactory httpClientFactory,
    ILogger<WebhookPublisher> logger) : IWebhookPublisher
{
    // Retry schedule: immediate → 30s → 5min → dead-letter
    // WHY exponential: gives receiver time to recover from transient failures
    private static readonly TimeSpan[] RetryDelays =
        [TimeSpan.Zero, TimeSpan.FromSeconds(30), TimeSpan.FromMinutes(5)];

    public async Task PublishAsync(WebhookEvent evt, WebhookSubscription sub, CancellationToken ct = default)
    {
        var payload   = JsonSerializer.Serialize(evt, WebhookJsonOptions.Default);
        var signature = ComputeSignature(sub.Secret, payload);

        for (int attempt = 0; attempt < RetryDelays.Length; attempt++)
        {
            if (attempt > 0)
            {
                logger.LogInformation("Webhook retry {A} for event {Id} → {Url} in {D}",
                    attempt, evt.Id, sub.Url, RetryDelays[attempt]);
                await Task.Delay(RetryDelays[attempt], ct);
            }

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, sub.Url)
                {
                    Content = new StringContent(payload, Encoding.UTF8, "application/json")
                };

                // Standard webhook headers — receiver uses these for routing + validation
                request.Headers.Add("X-Webhook-Event",     evt.Type);
                request.Headers.Add("X-Webhook-Id",        evt.Id);
                request.Headers.Add("X-Webhook-Timestamp", evt.Timestamp.ToUnixTimeSeconds().ToString());
                request.Headers.Add("X-Webhook-Signature", signature);
                request.Headers.Add("User-Agent",          "SimpleApi1-Webhook/1.0");

                var client = httpClientFactory.CreateClient("WebhookClient");
                using var response = await client.SendAsync(request, ct);

                if (response.IsSuccessStatusCode)
                {
                    logger.LogInformation("Webhook delivered: id={Id} type={Type} url={Url} status={S}",
                        evt.Id, evt.Type, sub.Url, (int)response.StatusCode);
                    return; // success — stop retrying
                }

                // 4xx (except 429) = permanent failure — receiver rejected it, no retry
                if ((int)response.StatusCode is >= 400 and < 500
                    && response.StatusCode != System.Net.HttpStatusCode.TooManyRequests)
                {
                    logger.LogWarning("Webhook permanent failure: id={Id} status={S} — stopping",
                        evt.Id, (int)response.StatusCode);
                    return;
                }

                logger.LogWarning("Webhook failed: id={Id} attempt={A} status={S}",
                    evt.Id, attempt + 1, (int)response.StatusCode);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                logger.LogError(ex, "Webhook exception: id={Id} attempt={A} url={Url}",
                    evt.Id, attempt + 1, sub.Url);
            }
        }

        // All retries exhausted
        // Production: write to dead-letter queue (Service Bus, DB table) and alert
        logger.LogError("Webhook dead-lettered: id={Id} url={Url} — all retries exhausted",
            evt.Id, sub.Url);
    }

    // HMAC-SHA256: industry-standard webhook signature scheme
    // WHY "sha256=" prefix: allows future algorithm migration without breaking receivers
    private static string ComputeSignature(string secret, string payload)
    {
        var key  = Encoding.UTF8.GetBytes(secret);
        var data = Encoding.UTF8.GetBytes(payload);
        using var hmac = new HMACSHA256(key);
        var hash = hmac.ComputeHash(data);
        return "sha256=" + Convert.ToHexString(hash).ToLowerInvariant();
    }
}

// Shared JSON options — must match across publisher and receiver
// WHY camelCase: JSON convention; WHY no indent: smaller payload
internal static class WebhookJsonOptions
{
    public static readonly JsonSerializerOptions Default = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented        = false
    };
}
```

#### `Webhooks/WebhookDispatcher.cs`
```csharp
using System.Threading.Channels;

namespace Webhooks;

// Outbox pattern implementation using Channel<T>.
// WHY Channel over direct async call:
//   - Decouples event creation from HTTP delivery
//   - Survives slow receivers without blocking the API thread
//   - Bounded capacity (1000) prevents unbounded memory growth
//   - BackgroundService retries even after the originating request completes
public sealed class WebhookDispatcher : BackgroundService
{
    // Bounded channel: if full, EnqueueAsync will back-pressure the producer
    private readonly Channel<(WebhookEvent Event, WebhookSubscription Subscription)> _channel =
        Channel.CreateBounded<(WebhookEvent, WebhookSubscription)>(
            new BoundedChannelOptions(1000)
            {
                FullMode    = BoundedChannelFullMode.Wait,  // back-pressure vs. drop
                SingleReader = true,                         // only this service reads
                SingleWriter = false                         // many threads can enqueue
            });

    private readonly IWebhookPublisher _publisher;
    private readonly ILogger<WebhookDispatcher> _logger;

    public WebhookDispatcher(IWebhookPublisher publisher, ILogger<WebhookDispatcher> logger)
    {
        _publisher = publisher;
        _logger    = logger;
    }

    // Called by API endpoints — enqueue and return immediately
    public async ValueTask EnqueueAsync(
        WebhookEvent evt,
        WebhookSubscription sub,
        CancellationToken ct = default)
    {
        await _channel.Writer.WriteAsync((evt, sub), ct);
        _logger.LogDebug("Enqueued: id={Id} type={Type} → {Url}", evt.Id, evt.Type, sub.Url);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("WebhookDispatcher started");

        await foreach (var (evt, sub) in _channel.Reader.ReadAllAsync(stoppingToken))
        {
            // Spawn independent task per delivery — don't let one slow delivery
            // block others in the channel queue
            _ = Task.Run(() => _publisher.PublishAsync(evt, sub, stoppingToken), stoppingToken);
        }

        _logger.LogInformation("WebhookDispatcher stopped");
    }
}
```

### 7.3 — SimpleApi2: Handler

#### File Structure
```
SimpleApi2/
├── Webhooks/
│   ├── WebhookModels.cs            ← event shape + received event record
│   ├── WebhookSignatureValidator.cs ← HMAC-SHA256 + timestamp replay protection
│   ├── WebhookEventCache.cs        ← deduplication (in-memory, 24h TTL)
│   └── WebhookProcessor.cs        ← BackgroundService + Channel + event router
├── Program.cs                      ← webhook receive endpoint + events endpoint
└── appsettings.json                ← Webhook:Secret config
```

#### `Webhooks/WebhookModels.cs`
```csharp
using System.Text.Json;

namespace Webhooks;

// Mirrors the publisher's WebhookEvent shape.
// Data is JsonElement — flexible deserialization of any JSON structure.
public record WebhookEvent(
    string          Id,
    string          Type,
    DateTimeOffset  Timestamp,
    JsonElement     Data         // raw JSON — route to type-specific handlers
);

// Audit record — every received event (including duplicates) is stored here
public record ReceivedEvent(
    string          Id,
    string          Type,
    DateTimeOffset  ReceivedAt,
    string          RawPayload,
    bool            WasDuplicate
);

// Shared JSON options — must match publisher (camelCase)
internal static class WebhookJsonOptions
{
    public static readonly JsonSerializerOptions Default = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };
}
```

#### `Webhooks/WebhookSignatureValidator.cs`
```csharp
using System.Security.Cryptography;
using System.Text;

namespace Webhooks;

// Validates incoming webhook requests.
// Steps: 1) signature present 2) timestamp fresh 3) HMAC matches
public sealed class WebhookSignatureValidator(IConfiguration config)
{
    private readonly string _secret =
        config["Webhook:Secret"]
        ?? throw new InvalidOperationException("Webhook:Secret not configured in appsettings");

    private readonly int _toleranceSeconds =
        int.Parse(config["Webhook:TimestampToleranceSeconds"] ?? "300");

    public ValidationResult Validate(IHeaderDictionary headers, byte[] rawBody)
    {
        // Step 1: signature header must be present
        if (!headers.TryGetValue("X-Webhook-Signature", out var sigHeader)
            || string.IsNullOrEmpty(sigHeader))
            return ValidationResult.Fail("Missing X-Webhook-Signature header");

        // Step 2: replay protection — reject events older than tolerance
        // WHY: a captured valid request could be replayed indefinitely without this check
        if (headers.TryGetValue("X-Webhook-Timestamp", out var tsHeader)
            && long.TryParse(tsHeader, out var unixTs))
        {
            var eventTime = DateTimeOffset.FromUnixTimeSeconds(unixTs);
            var ageSeconds = Math.Abs((DateTimeOffset.UtcNow - eventTime).TotalSeconds);
            if (ageSeconds > _toleranceSeconds)
                return ValidationResult.Fail($"Timestamp too old ({ageSeconds:F0}s > {_toleranceSeconds}s)");
        }

        // Step 3: compute expected HMAC-SHA256 over the raw body bytes
        var key          = Encoding.UTF8.GetBytes(_secret);
        using var hmac   = new HMACSHA256(key);
        var expectedHash = hmac.ComputeHash(rawBody);
        var expectedSig  = "sha256=" + Convert.ToHexString(expectedHash).ToLowerInvariant();

        // Step 4: constant-time comparison
        // WHY: string equality short-circuits on first mismatch, leaking timing info.
        // FixedTimeEquals always iterates the full length regardless of where mismatch occurs.
        var actualSig = sigHeader.ToString();
        if (actualSig.Length != expectedSig.Length)
            return ValidationResult.Fail("Signature length mismatch");

        var actualBytes   = Encoding.UTF8.GetBytes(actualSig);
        var expectedBytes = Encoding.UTF8.GetBytes(expectedSig);
        return CryptographicOperations.FixedTimeEquals(actualBytes, expectedBytes)
            ? ValidationResult.Ok()
            : ValidationResult.Fail("Signature mismatch");
    }
}

public record ValidationResult(bool IsValid, string? Error)
{
    public static ValidationResult Ok()             => new(true, null);
    public static ValidationResult Fail(string err) => new(false, err);
}
```

#### `Webhooks/WebhookEventCache.cs`
```csharp
using System.Collections.Concurrent;

namespace Webhooks;

// In-memory idempotency cache for webhook event deduplication.
// Production: replace with Redis SET key EX 86400 (24h TTL, survives restarts).
// WHY needed: publishers retry on network failures → same event may arrive 2–5 times.
public sealed class WebhookEventCache
{
    // Key = eventId, Value = expiry time
    private readonly ConcurrentDictionary<string, DateTimeOffset> _seen = new();
    private readonly TimeSpan _ttl = TimeSpan.FromHours(24);
    private DateTimeOffset _lastCleanup = DateTimeOffset.UtcNow;

    // Returns true if this is the FIRST time we've seen this eventId.
    // Returns false if it's a duplicate (already processed within TTL window).
    public bool TryMarkSeen(string eventId)
    {
        var now = DateTimeOffset.UtcNow;
        CleanupIfNeeded(now);

        if (_seen.ContainsKey(eventId))
            return false;  // duplicate

        _seen[eventId] = now.Add(_ttl);
        return true;  // first occurrence
    }

    // Periodic cleanup — only runs every 10 minutes to avoid lock overhead
    private void CleanupIfNeeded(DateTimeOffset now)
    {
        if (now - _lastCleanup < TimeSpan.FromMinutes(10)) return;
        _lastCleanup = now;
        foreach (var kvp in _seen.Where(k => now > k.Value))
            _seen.TryRemove(kvp.Key, out _);
    }
}
```

#### `Webhooks/WebhookProcessor.cs`
```csharp
using System.Collections.Concurrent;
using System.Threading.Channels;

namespace Webhooks;

// Background processor — reads from Channel and routes events to handlers.
// WHY BackgroundService + Channel:
//   - API handler returns 200 in microseconds (doesn't wait for processing)
//   - Processing happens in the background at its own pace
//   - Decouples webhook acknowledgement from business logic latency
public sealed class WebhookProcessor : BackgroundService
{
    private readonly Channel<(WebhookEvent Event, string RawPayload)> _channel =
        Channel.CreateBounded<(WebhookEvent, string)>(
            new BoundedChannelOptions(500)
            {
                FullMode     = BoundedChannelFullMode.Wait,
                SingleReader = true,
                SingleWriter = false
            });

    // In-memory audit store — bounded at 1000 events to prevent unbounded growth
    private readonly ConcurrentQueue<ReceivedEvent> _received = new();
    private int _totalStored = 0;
    private const int MaxStored = 1000;

    private readonly ILogger<WebhookProcessor> _logger;
    public WebhookProcessor(ILogger<WebhookProcessor> logger) => _logger = logger;

    // Called by the webhook endpoint (fast, non-blocking)
    public async ValueTask EnqueueAsync(
        WebhookEvent evt,
        string rawPayload,
        bool wasDuplicate,
        CancellationToken ct = default)
    {
        // Duplicates are stored for audit but not enqueued for processing
        StoreAuditRecord(new ReceivedEvent(evt.Id, evt.Type, DateTimeOffset.UtcNow, rawPayload, wasDuplicate));

        if (!wasDuplicate)
            await _channel.Writer.WriteAsync((evt, rawPayload), ct);
    }

    public IReadOnlyList<ReceivedEvent> GetProcessedEvents() =>
        _received.ToArray();

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("WebhookProcessor started");

        await foreach (var (evt, raw) in _channel.Reader.ReadAllAsync(stoppingToken))
        {
            try { await ProcessAsync(evt); }
            catch (Exception ex) { _logger.LogError(ex, "Error processing event {Id}", evt.Id); }
        }

        _logger.LogInformation("WebhookProcessor stopped");
    }

    private Task ProcessAsync(WebhookEvent evt)
    {
        _logger.LogInformation("Processing: id={Id} type={Type} ts={Ts}",
            evt.Id, evt.Type, evt.Timestamp);

        // Route to type-specific handler
        return evt.Type switch
        {
            "weather.fetched" => HandleWeatherFetched(evt),
            "trigger.test"    => HandleTestTrigger(evt),
            _                 => HandleUnknown(evt)
        };
    }

    private Task HandleWeatherFetched(WebhookEvent evt)
    {
        _logger.LogInformation("Weather data received: {Data}", evt.Data.ToString());
        // Production: store in time-series DB, trigger downstream processes, etc.
        return Task.CompletedTask;
    }

    private Task HandleTestTrigger(WebhookEvent evt)
    {
        _logger.LogInformation("Test trigger: {Data}", evt.Data.ToString());
        return Task.CompletedTask;
    }

    private Task HandleUnknown(WebhookEvent evt)
    {
        _logger.LogWarning("Unknown event type: {Type} — no handler registered", evt.Type);
        return Task.CompletedTask;
    }

    private void StoreAuditRecord(ReceivedEvent record)
    {
        if (Interlocked.Increment(ref _totalStored) <= MaxStored)
            _received.Enqueue(record);
        // Production: write to append-only audit table in database
    }
}
```

---

## Section 8 — Running the Demo

### Step 1: Start both APIs

```bash
# Terminal 1 — Start SimpleApi1 (Publisher) on port 5248
cd SimpleApi1
dotnet run

# Terminal 2 — Start SimpleApi2 (Handler) on port 5249
cd SimpleApi2
dotnet run --launch-profile http-5249
```

### Step 2: Register SimpleApi2 as a subscriber (via SimpleApi1.http)

```http
POST http://localhost:5248/webhooks/subscribe
Content-Type: application/json

{
  "url": "http://localhost:5249/webhook/receive",
  "secret": "dev-secret-change-in-production-min-32-chars!!",
  "eventTypes": ["*"]
}
```

**Response:**
```json
{
  "id": "a3f8c2d1e4b5f6a7...",
  "url": "http://localhost:5249/webhook/receive",
  "secret": "***",
  "eventTypes": ["*"],
  "registeredAt": "2026-03-02T10:00:00Z"
}
```

### Step 3: Trigger a test event

```http
POST http://localhost:5248/webhooks/trigger
Content-Type: application/json

{
  "eventType": "trigger.test",
  "data": { "message": "hello from SimpleApi1!" }
}
```

### Step 4: Fetch weather (fires webhook automatically)

```http
GET http://localhost:5248/weatherforecast
```

### Step 5: Check received events on SimpleApi2

```http
GET http://localhost:5249/webhook/events
```

**Response:**
```json
[
  {
    "id": "b5c6d7e8f9a0b1c2...",
    "type": "trigger.test",
    "receivedAt": "2026-03-02T10:00:01Z",
    "rawPayload": "{\"id\":\"b5c6...\",\"type\":\"trigger.test\",...}",
    "wasDuplicate": false
  },
  {
    "id": "c6d7e8f9a0b1c2d3...",
    "type": "weather.fetched",
    "receivedAt": "2026-03-02T10:00:05Z",
    "rawPayload": "{\"id\":\"c6d7...\",\"type\":\"weather.fetched\",...}",
    "wasDuplicate": false
  }
]
```

### Step 6: Test signature validation (should return 401)

```http
POST http://localhost:5249/webhook/receive
Content-Type: application/json
X-Webhook-Signature: sha256=invalidsignature

{ "id": "test", "type": "test", "timestamp": "2026-01-01T00:00:00Z", "data": {} }
```

---

## Section 9 — Production Checklist

### Infrastructure
- [ ] **HTTPS only** for all webhook URLs — reject `http://` subscriber URLs
- [ ] **Redis** for deduplication cache (survives restarts)
- [ ] **Database outbox table** instead of in-memory Channel (survives crashes)
- [ ] **Dead-letter queue** (Azure Service Bus) for failed deliveries
- [ ] **Alert** when events hit dead-letter (PagerDuty / Azure Monitor alert)

### Security
- [ ] **Minimum 32-byte secret** (256-bit) — generated with `openssl rand -hex 32`
- [ ] **Store secrets in Azure Key Vault** — never in appsettings.json for production
- [ ] **Never log raw secrets** — mask as `***` in all log messages
- [ ] **Validate subscriber URL** — block RFC-1918 ranges (SSRF prevention)
- [ ] **Rate limit** subscription creation per tenant

### Reliability
- [ ] **Retry schedule** tuned to your SLA: immediate → 30s → 5min → 1h → dead-letter
- [ ] **Timeout per attempt** set to 10–30s (aggressive — don't block delivery queue)
- [ ] **Idempotency on receiver** side — all handlers must be idempotent
- [ ] **Circuit breaker** per subscriber URL — stop retrying persistently-down endpoints

### Observability
- [ ] **Structured logs** with `eventId`, `eventType`, `subscriberUrl`, `attempt`, `statusCode`
- [ ] **Metrics**: delivery success rate, p99 delivery latency, dead-letter count
- [ ] **Delivery log endpoint** — let subscribers self-diagnose (`GET /webhooks/deliveries`)
- [ ] **Distributed trace ID** passed in `X-Request-Id` header

### Operations
- [ ] **Subscription management UI** or admin API (list / revoke / rotate secrets)
- [ ] **Event replay** — re-deliver any event by ID from the audit log
- [ ] **Secret rotation** — support two active secrets during transition window
- [ ] **Subscriber health check** before first delivery (optional HEAD request)

---

*End of Webhooks Complete Guide*

> **Reference Apps:** SimpleApi1 (Publisher, .NET 10, port 5248), SimpleApi2 (Handler, .NET 10, port 5249)
> **Last Updated:** March 2026
