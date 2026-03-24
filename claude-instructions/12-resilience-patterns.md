# 12 — Resilience Patterns

> **Mental Model:** Resilience is accepting that failures WILL happen and designing so
> they don't cascade. Like circuit breakers in a building — one overloaded outlet
> doesn't burn down the whole floor. Failures are isolated, retried, or gracefully degraded.

---

## Resilience Decision Tree

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      RESILIENCE PATTERN SELECTOR                             │
├──────────────────────────────────────────────────────────────────────────────┤
│ Failure is transient (network blip, 503)?    → Retry with backoff            │
│ Dependency is consistently slow/failing?     → Circuit Breaker               │
│ Operation MUST complete (payment, email)?    → Outbox Pattern                │
│ Partial failure tolerable (recommendations)? → Fallback / Bulkhead           │
│ Overload protection?                         → Rate Limiting + Timeout       │
│ Long-running, resumable work?                → Durable Functions / Saga      │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Polly — Resilience Pipelines

```csharp
// WHY Polly: composable resilience policies for any async operation.
//   HttpClient, DB calls, Service Bus — all can use the same pipeline.

// ── Registration — add resilience to named HttpClient ────────────────────────
builder.Services.AddHttpClient<IPaymentGateway, PaymentGatewayClient>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["PaymentGateway:BaseUrl"]!);
    client.Timeout = TimeSpan.FromSeconds(30);   // WHY 30s: outer timeout — circuit breaker
})
.AddResilienceHandler("payment-pipeline", pipeline =>
{
    // ── 1. Retry — handles transient failures ────────────────────────────────
    // WHY retry FIRST (outermost): retries should happen before circuit breaker checks state
    pipeline.AddRetry(new HttpRetryStrategyOptions
    {
        MaxRetryAttempts = 3,

        // WHY exponential + jitter: exponential avoids hammering a recovering service.
        //   Jitter spreads retries from multiple pods — prevents thundering herd.
        Delay = TimeSpan.FromMilliseconds(200),
        BackoffType = DelayBackoffType.Exponential,
        UseJitter = true,

        // WHY predicate: only retry on transient HTTP errors, not 400/401/403/404
        ShouldHandle = new PredicateBuilder<HttpResponseMessage>()
            .Handle<HttpRequestException>()
            .Handle<TimeoutRejectedException>()
            .HandleResult(r => r.StatusCode is
                HttpStatusCode.RequestTimeout or
                HttpStatusCode.TooManyRequests or
                HttpStatusCode.BadGateway or
                HttpStatusCode.ServiceUnavailable or
                HttpStatusCode.GatewayTimeout),

        OnRetry = args =>
        {
            // Log each retry attempt — visible in distributed traces
            logger.LogWarning(
                "Retry {Attempt} for {Url} after {Delay}ms",
                args.AttemptNumber,
                args.Outcome.Result?.RequestMessage?.RequestUri,
                args.RetryDelay.TotalMilliseconds);
            return default;
        }
    });

    // ── 2. Circuit Breaker — stops hammering a failing service ───────────────
    // WHY AFTER retry: retry runs first; circuit breaker trips after enough failures
    // Mental model: retry = "try again"; circuit breaker = "stop trying, service is down"
    pipeline.AddCircuitBreaker(new HttpCircuitBreakerStrategyOptions
    {
        // Trip after 50% failure rate across a 30s window with minimum 10 requests
        FailureRatio = 0.5,
        SamplingDuration = TimeSpan.FromSeconds(30),
        MinimumThroughput = 10,

        // WHY 30s BreakDuration: give the downstream service time to recover.
        //   During this window, all requests immediately fail with BrokenCircuitException.
        //   This prevents your service from queueing 1000 requests that all timeout.
        BreakDuration = TimeSpan.FromSeconds(30),

        OnOpened = args =>
        {
            logger.LogError(
                "Circuit OPENED for payment gateway. Break duration: {Duration}s",
                args.BreakDuration.TotalSeconds);
            return default;
        },
        OnClosed = args =>
        {
            logger.LogInformation("Circuit CLOSED — payment gateway recovered");
            return default;
        },
        OnHalfOpened = args =>
        {
            logger.LogInformation("Circuit HALF-OPEN — testing payment gateway with probe request");
            return default;
        }
    });

    // ── 3. Timeout — every call has a deadline ───────────────────────────────
    // WHY timeout: without it, a slow dependency holds a thread forever.
    //   Multiply by 10 concurrent requests = thread pool exhaustion = full outage.
    pipeline.AddTimeout(TimeSpan.FromSeconds(5));
});
```

---

## Fallback Pattern

```csharp
// WHY fallback: when primary fails, return degraded-but-useful response.
//   Recommendations: return popular items. Config: return defaults. Cache: return stale.

public class ProductRecommendationService(
    IRecommendationEngine engine,
    IMemoryCache cache,
    ILogger<ProductRecommendationService> logger)
{
    public async Task<IReadOnlyList<Product>> GetRecommendationsAsync(
        Guid userId, CancellationToken ct)
    {
        // WHY try/catch not Polly fallback: this is application-level business logic.
        //   Polly fallback is for HTTP transport. App-level fallback is here.
        try
        {
            var recommendations = await engine.GetForUserAsync(userId, ct);

            // Cache successful result for 5 minutes
            // WHY: if engine fails later, we serve slightly stale data (better than nothing)
            cache.Set($"recs:{userId}", recommendations, TimeSpan.FromMinutes(5));

            return recommendations;
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Recommendation engine failed for user {UserId} — using fallback", userId);

            // Fallback tier 1: stale cache (user-specific)
            if (cache.TryGetValue($"recs:{userId}", out IReadOnlyList<Product>? cached) && cached is not null)
                return cached;

            // Fallback tier 2: popular items (not personalised)
            if (cache.TryGetValue("popular-products", out IReadOnlyList<Product>? popular) && popular is not null)
                return popular;

            // Fallback tier 3: empty list (UI shows "Check back later")
            // WHY return empty not throw: recommendations are non-critical.
            //   Throwing would break the product page because of a non-essential widget.
            return Array.Empty<Product>();
        }
    }
}
```

---

## Outbox Pattern — Guaranteed Message Delivery

```csharp
// WHY Outbox: "save to DB and publish event" must be atomic.
//   Without outbox: save succeeds, publish fails → order exists but no event sent → inconsistency.
//   Outbox: write event to SAME DB transaction as the entity → both commit or both rollback.
//   Background job reads outbox and publishes → at-least-once delivery guaranteed.

// ── Domain — raise events that get stored in outbox ──────────────────────────
public class Order : AggregateRoot
{
    public void Confirm()
    {
        Status = OrderStatus.Confirmed;
        // WHY AddDomainEvent not publish directly: event stored to DB in same transaction
        AddDomainEvent(new OrderConfirmedEvent(Id, CustomerId, Total, ConfirmedAt: DateTime.UtcNow));
    }
}

// ── Infrastructure — OutboxMessage table ─────────────────────────────────────
public class OutboxMessage
{
    public Guid   Id            { get; init; } = Guid.NewGuid();
    public string Type          { get; init; } = string.Empty;   // event type name
    public string Payload       { get; init; } = string.Empty;   // JSON serialized event
    public DateTime OccurredOn  { get; init; } = DateTime.UtcNow;
    public DateTime? ProcessedOn { get; set; }  // null = not yet published
    public string? Error        { get; set; }   // last error if publish failed
    public int RetryCount       { get; set; }
}

// ── SaveChanges intercept — serialize domain events to outbox ─────────────────
public class OutboxInterceptor : SaveChangesInterceptor
{
    public override async ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData, InterceptionResult<int> result, CancellationToken ct)
    {
        var db = eventData.Context as AppDbContext;
        if (db is null) return await base.SavingChangesAsync(eventData, result, ct);

        // Convert domain events to outbox messages before SaveChanges commits
        var outboxMessages = db.ChangeTracker.Entries<AggregateRoot>()
            .SelectMany(e => e.Entity.DomainEvents)
            .Select(evt => new OutboxMessage
            {
                Type    = evt.GetType().Name,
                Payload = JsonSerializer.Serialize(evt, evt.GetType())
            })
            .ToList();

        if (outboxMessages.Any())
        {
            await db.OutboxMessages.AddRangeAsync(outboxMessages, ct);
            // WHY: same SaveChanges → same transaction → atomic write of entity + events
        }

        return await base.SavingChangesAsync(eventData, result, ct);
    }
}

// ── Background job — publish from outbox to Service Bus ──────────────────────
public class OutboxProcessor(IServiceScopeFactory scopeFactory) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        // WHY PeriodicTimer not Task.Delay: PeriodicTimer compensates for processing time.
        //   Task.Delay(10s) → process (5s) → wait another 10s = 15s cycle.
        //   PeriodicTimer(10s) → fires every 10s regardless of processing duration.
        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(10));

        while (await timer.WaitForNextTickAsync(ct))
        {
            using var scope = scopeFactory.CreateScope();
            var db        = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var publisher = scope.ServiceProvider.GetRequiredService<IMessagePublisher>();

            // Fetch unprocessed messages — pessimistic lock prevents duplicate processing
            var messages = await db.OutboxMessages
                .Where(m => m.ProcessedOn == null && m.RetryCount < 5)
                .OrderBy(m => m.OccurredOn)
                .Take(20)   // WHY batch: process in chunks to avoid long transactions
                .ToListAsync(ct);

            foreach (var message in messages)
            {
                try
                {
                    await publisher.PublishAsync(message.Type, message.Payload, ct);
                    message.ProcessedOn = DateTime.UtcNow;   // mark complete
                }
                catch (Exception ex)
                {
                    message.Error = ex.Message;
                    message.RetryCount++;   // will be skipped after 5 retries (manual intervention)
                }
            }

            await db.SaveChangesAsync(ct);
        }
    }
}
```

---

## Bulkhead Pattern — Isolate Failures

```csharp
// WHY Bulkhead: a slow dependency shouldn't exhaust the whole thread pool.
//   Allocate a fixed number of concurrent calls per dependency.
//   Like watertight compartments in a ship — one flooded section doesn't sink the whole vessel.

builder.Services.AddHttpClient<IInventoryService, InventoryServiceClient>()
    .AddResilienceHandler("inventory-bulkhead", pipeline =>
    {
        // Limit concurrent calls to inventory service
        pipeline.AddConcurrencyLimiter(new ConcurrencyLimiterOptions
        {
            // WHY 20: inventory is non-critical — limit it so a slow inventory
            //   response doesn't consume all available threads for payment
            PermitLimit = 20,
            QueueLimit  = 5,    // queue 5 additional — reject the rest with BulkheadRejectedException
        });

        pipeline.AddTimeout(TimeSpan.FromSeconds(3));  // WHY 3s: inventory is read-only, fail fast
    });
```

---

## Saga Pattern — Distributed Transactions

```csharp
// WHY Saga: distributed systems can't use DB transactions across services.
//   A Saga is a sequence of local transactions with compensating actions on failure.
//
// Choreography (event-driven):   each step publishes an event, next step listens
// Orchestration (central):       one orchestrator tells each step what to do
//
// Use Orchestration when:  steps have complex conditional logic, easy to see the full flow
// Use Choreography when:   simple linear flow, services are independent

// ── Orchestration-based Order Saga using Durable Functions ───────────────────

[DurableTask.Orchestrator]
public class PlaceOrderSaga
{
    public async Task<SagaResult> RunAsync(TaskOrchestrationContext ctx, PlaceOrderInput input)
    {
        var log = ctx.CreateReplaySafeLogger<PlaceOrderSaga>();

        // Step 1: Reserve inventory
        var inventoryResult = await ctx.CallActivityAsync<ReserveResult>(
            nameof(ReserveInventoryActivity), input.Items);

        if (!inventoryResult.Success)
        {
            log.LogWarning("Saga failed at inventory — no compensation needed");
            return SagaResult.Failed("Insufficient inventory");
        }

        // Step 2: Charge payment
        var paymentResult = await ctx.CallActivityAsync<ChargeResult>(
            nameof(ChargePaymentActivity), new ChargeInput(input.CustomerId, input.Total));

        if (!paymentResult.Success)
        {
            // WHY compensate: inventory was reserved — must release it (undo step 1)
            log.LogWarning("Payment failed — compensating inventory reservation");
            await ctx.CallActivityAsync(
                nameof(ReleaseInventoryActivity), inventoryResult.ReservationId);
            return SagaResult.Failed("Payment declined");
        }

        // Step 3: Create order record
        var orderId = await ctx.CallActivityAsync<Guid>(
            nameof(CreateOrderActivity), new CreateOrderInput(input, paymentResult.ChargeId));

        // Step 4: Send confirmation email (non-critical — don't fail saga if this fails)
        try
        {
            await ctx.CallActivityAsync(
                nameof(SendConfirmationEmailActivity), orderId);
        }
        catch (Exception ex)
        {
            // WHY catch+continue: email failure shouldn't roll back a completed payment
            log.LogWarning(ex, "Confirmation email failed — saga continues");
        }

        return SagaResult.Success(orderId);
    }
}
```

---

## Timeout Strategy Reference

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Operation                    │ Recommended Timeout │ Reasoning              │
├──────────────────────────────────────────────────────────────────────────────┤
│  Synchronous API read         │ 3–5 seconds         │ User is waiting        │
│  Payment / critical write     │ 10–15 seconds       │ Must complete, retry   │
│  Background job step          │ 30–60 seconds       │ No user waiting        │
│  File / bulk import           │ 5–30 minutes        │ Use Durable Functions  │
│  Health check probe           │ 2–3 seconds         │ K8s probe timeout      │
│  Database query (read)        │ 5 seconds           │ Index should make fast │
│  Database query (write)       │ 10 seconds          │ Locks, cascades        │
│  External HTTP call           │ 5 seconds           │ Retry handles retries  │
└──────────────────────────────────────────────────────────────────────────────┘

RULE: Always set a timeout. "No timeout" = infinite wait = thread leak.
RULE: Timeout < retry interval × max retries. Don't retry after outer timeout fires.
RULE: Circuit breaker break duration > retry delay × max retries.
      (Break long enough that retries would have exhausted before circuit re-closes)
```
