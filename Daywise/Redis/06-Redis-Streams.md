# Redis Streams — Durable Messaging & Event Sourcing in .NET

> **Mental Model:** Redis Streams is like a persistent, append-only scroll.
> Every message gets a unique time-based ID. Readers can pick up from any point in history.
> Consumer groups allow multiple workers to share the load — each message delivered to only one worker.

---

## Table of Contents
1. [Streams vs Pub/Sub vs Kafka vs Service Bus](#streams-vs-pubsub-vs-kafka-vs-service-bus)
2. [Core Concepts](#core-concepts)
3. [Basic XADD / XREAD](#basic-xadd--xread)
4. [Consumer Groups — Competing Consumers](#consumer-groups)
5. [Message Acknowledgement & Pending Messages](#message-acknowledgement--pending-messages)
6. [Dead-Letter Handling](#dead-letter-handling)
7. [Full Producer / Consumer in .NET](#full-producer--consumer-in-net)
8. [Event Sourcing with Streams](#event-sourcing-with-streams)
9. [Outbox Pattern with Streams](#outbox-pattern-with-streams)
10. [Stream Trimming & Retention](#stream-trimming--retention)
11. [Monitoring Streams](#monitoring-streams)

---

## Streams vs Pub/Sub vs Kafka vs Service Bus

```
┌─────────────────┬──────────────┬──────────────┬──────────────┬──────────────────┐
│ Feature         │ Pub/Sub      │ Streams      │ Kafka        │ Service Bus      │
├─────────────────┼──────────────┼──────────────┼──────────────┼──────────────────┤
│ Persistence     │ ❌ No        │ ✅ Yes       │ ✅ Yes       │ ✅ Yes           │
│ Replay          │ ❌ No        │ ✅ Yes       │ ✅ Yes       │ ❌ No            │
│ Consumer groups │ ❌ No        │ ✅ Yes       │ ✅ Yes       │ ✅ Yes (topics)  │
│ ACK required    │ ❌ No        │ ✅ Yes       │ Offset       │ ✅ Yes           │
│ Delivery        │ At-most-once │ At-least-once│ At-least-once│ At-least-once    │
│ Dead-letter     │ ❌ No        │ Manual       │ ❌ Manual    │ ✅ Built-in      │
│ Latency         │ Sub-ms       │ Sub-ms       │ ~5ms         │ ~10ms            │
│ Throughput      │ Very high    │ Very high    │ Very high    │ Moderate         │
│ Managed         │ No           │ No           │ Via Azure    │ ✅ Fully managed │
│ Cross-service   │ In-process   │ In-process   │ ✅ Yes       │ ✅ Yes           │
└─────────────────┴──────────────┴──────────────┴──────────────┴──────────────────┘

Use Redis Streams when:
  ✅ Need durable queuing without external broker
  ✅ Multiple worker instances consuming from same stream
  ✅ Want to replay events within a service
  ✅ Simple audit log / event history
  ✅ Lower ops overhead than Kafka

Use Kafka/Service Bus when:
  ✅ Cross-service messaging with SLA guarantees
  ✅ Built-in dead-letter queue
  ✅ Regulatory compliance / long-term retention
  ✅ Multi-region replication
```

---

## Core Concepts

```
┌─────────────────────────────────────────────────────────────────────┐
│                      REDIS STREAM ANATOMY                           │
│                                                                     │
│  Stream: "orders"                                                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ ID              │ Fields                                       │  │
│  │─────────────────│─────────────────────────────────────────── │  │
│  │ 1706123456789-0 │ orderId=1 userId=42 amount=99.99           │  │
│  │ 1706123456800-0 │ orderId=2 userId=15 amount=49.50           │  │
│  │ 1706123456901-0 │ orderId=3 userId=42 amount=199.00          │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Consumer Group: "order-processors"                                 │
│  ┌───────────────────────────────────────────────────────────┐     │
│  │ Consumer     │ Pending Messages (delivered, not ACKed)    │     │
│  │ worker-1     │ [1706123456789-0]                          │     │
│  │ worker-2     │ [1706123456800-0, 1706123456901-0]         │     │
│  └───────────────────────────────────────────────────────────┘     │
│                                                                     │
│  ID Format: {milliseconds}-{sequence}                               │
│  Special IDs: "*" = auto-generate, ">" = new messages only         │
│               "0" = all pending, "0-0" = beginning of stream       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Basic XADD / XREAD

```csharp
// ── XADD: Append to stream ─────────────────────────────────────────────
public class OrderStreamProducer
{
    private readonly IDatabase _db;
    private const string StreamKey = "stream:orders";

    public async Task<string> PublishOrderCreatedAsync(OrderCreatedEvent evt)
    {
        // WHY: Use StreamEntry fields as key-value pairs (like a dictionary)
        // Each message can have multiple named fields
        var fields = new NameValueEntry[]
        {
            new("eventType", "OrderCreated"),
            new("orderId", evt.OrderId),
            new("userId", evt.UserId),
            new("amount", evt.Amount.ToString()),
            new("timestamp", evt.Timestamp.ToString("O")),
            new("correlationId", evt.CorrelationId)
        };

        // WHY: "*" as message ID = Redis auto-generates timestamp-based ID
        // This guarantees ordering and global uniqueness
        var messageId = await _db.StreamAddAsync(
            StreamKey,
            fields,
            messageId: "*",  // auto-generate
            maxLength: 10000, // WHY: cap stream size to prevent unbounded growth
            useApproximateMaxLength: true); // WHY: approximate is faster (doesn't scan entire stream)

        return messageId!;
    }
}

// ── XREAD: Read from stream (no consumer group — fan-out read) ─────────
public class OrderStreamReader
{
    private readonly IDatabase _db;

    // Read latest messages since a given ID
    public async Task<IEnumerable<StreamMessage>> ReadNewAsync(
        string lastId = "0", // "0" = from beginning, "$" = only new after subscribe
        int count = 10)
    {
        var results = await _db.StreamReadAsync(
            "stream:orders",
            position: lastId,
            count: count);

        return results.Select(msg => new StreamMessage(
            msg.Id.ToString(),
            msg.Values.ToDictionary(e => e.Name.ToString(), e => e.Value.ToString())));
    }

    // Poll continuously
    public async Task PollAsync(CancellationToken ct)
    {
        string lastId = "$"; // WHY: Start from NOW, not beginning of stream

        while (!ct.IsCancellationRequested)
        {
            var messages = await _db.StreamReadAsync("stream:orders", lastId, count: 10);

            foreach (var msg in messages)
            {
                await ProcessAsync(msg);
                lastId = msg.Id!; // Track position
            }

            if (!messages.Any())
                await Task.Delay(100, ct); // WHY: Brief pause when no messages to prevent busy-loop
        }
    }
}

public record StreamMessage(string Id, Dictionary<string, string> Fields);
```

---

## Consumer Groups

> **Mental Model:** A consumer group is a team of workers (consumers) sharing a workload.
> Each message is delivered to exactly ONE worker in the group — natural load balancing.

```csharp
// ── Create Consumer Group ──────────────────────────────────────────────
public async Task EnsureConsumerGroupAsync(string streamKey, string groupName)
{
    try
    {
        // WHY: "$" = start group from NOW (ignore historical messages)
        // "0" = start from beginning (replay all existing messages)
        await _db.StreamCreateConsumerGroupAsync(
            streamKey, groupName,
            position: "$",       // Only process new messages
            createStream: true); // WHY: Create stream if it doesn't exist
    }
    catch (RedisServerException ex) when (ex.Message.Contains("BUSYGROUP"))
    {
        // WHY: Group already exists — ignore this error, it's idempotent
    }
}

// ── XREADGROUP: Consume messages as part of a group ────────────────────
public async Task<StreamEntry[]> ReadGroupAsync(
    string streamKey,
    string groupName,
    string consumerName, // WHY: Unique per consumer instance (e.g., hostname + pod ID)
    int count = 10)
{
    return await _db.StreamReadGroupAsync(
        streamKey,
        groupName,
        consumerName,
        position: ">",   // WHY: ">" = only undelivered messages (not pending/retries)
        count: count,
        noAck: false);   // WHY: noAck=false = we must XACK each message after processing
}

// ── XACK: Acknowledge processing complete ─────────────────────────────
public async Task AcknowledgeAsync(string streamKey, string groupName, string messageId)
{
    await _db.StreamAcknowledgeAsync(streamKey, groupName, messageId);
    // WHY: Without ACK, message stays in "Pending Entries List" (PEL)
    // and can be reclaimed by other consumers if this one crashes
}
```

---

## Message Acknowledgement & Pending Messages

```csharp
// ── Check Pending Messages (delivered but not ACKed) ──────────────────
public async Task<StreamPendingInfo> GetPendingInfoAsync(string streamKey, string groupName)
{
    // Summary of pending messages
    return await _db.StreamPendingAsync(streamKey, groupName);
    // Returns: count, min/max IDs, consumers with pending counts
}

// ── Get Pending Message Details ────────────────────────────────────────
public async Task<StreamPendingMessageInfo[]> GetPendingMessagesAsync(
    string streamKey,
    string groupName,
    int count = 100,
    TimeSpan? minIdleTime = null)
{
    // WHY: Filter by idle time to find messages stuck > 5 minutes (consumer crashed)
    return await _db.StreamPendingMessagesAsync(
        streamKey, groupName,
        count: count,
        consumerName: RedisValue.Null, // All consumers
        minId: "-",
        maxId: "+");
}

// ── XCLAIM: Steal a pending message from a crashed consumer ───────────
public async Task ReclaimStaleMessagesAsync(
    string streamKey,
    string groupName,
    string newConsumerName,
    TimeSpan minIdleTime)
{
    // Find messages idle longer than minIdleTime
    var pending = await _db.StreamPendingMessagesAsync(
        streamKey, groupName, count: 100, consumerName: RedisValue.Null, "-", "+");

    var staleIds = pending
        .Where(p => p.IdleTimeInMilliseconds > minIdleTime.TotalMilliseconds)
        .Select(p => p.MessageId)
        .ToArray();

    if (!staleIds.Any()) return;

    // WHY: XCLAIM transfers ownership to this consumer for reprocessing
    var reclaimed = await _db.StreamClaimAsync(
        streamKey, groupName, newConsumerName,
        (long)minIdleTime.TotalMilliseconds,
        staleIds);

    foreach (var msg in reclaimed)
    {
        await ReprocessMessageAsync(msg);
        await _db.StreamAcknowledgeAsync(streamKey, groupName, msg.Id);
    }
}
```

---

## Dead-Letter Handling

```csharp
// WHY: Redis Streams don't have built-in dead-letter — implement manually
// Strategy: after N delivery attempts, move message to dead-letter stream

public class StreamConsumerWithDlq
{
    private readonly IDatabase _db;
    private const string StreamKey = "stream:orders";
    private const string DlqKey = "stream:orders:dlq";
    private const string GroupName = "order-processors";
    private const int MaxRetries = 3;

    public async Task ProcessWithRetryAsync(string consumerName, CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            // ── Read new messages ──────────────────────────────────────
            var messages = await _db.StreamReadGroupAsync(
                StreamKey, GroupName, consumerName, ">", count: 10);

            foreach (var msg in messages)
                await HandleMessageAsync(msg, consumerName);

            // ── Check for messages to retry (pending, idle > 30s) ──────
            await ReclaimAndRetryAsync(consumerName);

            if (!messages.Any())
                await Task.Delay(100, ct);
        }
    }

    private async Task HandleMessageAsync(StreamEntry msg, string consumerName)
    {
        try
        {
            var fields = msg.Values.ToDictionary(e => e.Name.ToString(), e => e.Value.ToString());
            await ProcessOrderAsync(fields);

            // ── Success: ACK the message ───────────────────────────────
            await _db.StreamAcknowledgeAsync(StreamKey, GroupName, msg.Id);
        }
        catch (Exception ex)
        {
            // WHY: Don't ACK on failure — message stays in PEL for retry
            // The idle time will eventually trigger reclaim-and-retry
            Console.Error.WriteLine($"Failed to process {msg.Id}: {ex.Message}");
        }
    }

    private async Task ReclaimAndRetryAsync(string consumerName)
    {
        var pending = await _db.StreamPendingMessagesAsync(
            StreamKey, GroupName, 100, RedisValue.Null, "-", "+");

        foreach (var p in pending.Where(p => p.IdleTimeInMilliseconds > 30_000))
        {
            // ── Check delivery count ───────────────────────────────────
            if (p.DeliveryCount >= MaxRetries)
            {
                // ── Move to dead-letter queue ──────────────────────────
                // WHY: Read the original message content to copy to DLQ
                var original = await _db.StreamRangeAsync(StreamKey, p.MessageId, p.MessageId);
                if (original.Any())
                {
                    var dlqFields = original[0].Values
                        .Concat(new[]
                        {
                            new NameValueEntry("originalId", p.MessageId.ToString()),
                            new NameValueEntry("deliveryCount", p.DeliveryCount),
                            new NameValueEntry("movedAt", DateTime.UtcNow.ToString("O"))
                        }).ToArray();

                    await _db.StreamAddAsync(DlqKey, dlqFields);
                }

                // ACK to remove from pending
                await _db.StreamAcknowledgeAsync(StreamKey, GroupName, p.MessageId);
            }
            else
            {
                // Reclaim for retry
                await _db.StreamClaimAsync(
                    StreamKey, GroupName, consumerName, 30_000, new[] { p.MessageId });
            }
        }
    }
}
```

---

## Full Producer / Consumer in .NET

```csharp
// ── Generic Stream Producer ────────────────────────────────────────────
public class StreamProducer<T>
{
    private readonly IDatabase _db;
    private readonly string _streamKey;
    private readonly int _maxLength;

    public StreamProducer(IConnectionMultiplexer redis, string streamKey, int maxLength = 10000)
    {
        _db = redis.GetDatabase();
        _streamKey = streamKey;
        _maxLength = maxLength;
    }

    public async Task<string> PublishAsync(T message, Dictionary<string, string>? metadata = null)
    {
        var fields = new List<NameValueEntry>
        {
            new("payload", JsonSerializer.Serialize(message)),
            new("type", typeof(T).Name),
            new("timestamp", DateTime.UtcNow.ToString("O")),
            new("messageId", Guid.NewGuid().ToString())
        };

        if (metadata is not null)
            fields.AddRange(metadata.Select(kv => new NameValueEntry(kv.Key, kv.Value)));

        return (await _db.StreamAddAsync(
            _streamKey, fields.ToArray(), "*", _maxLength, true))!;
    }
}

// ── Generic Stream Consumer (Hosted Service) ───────────────────────────
public abstract class StreamConsumer<T> : BackgroundService
{
    private readonly IDatabase _db;
    private readonly string _streamKey;
    private readonly string _groupName;
    private readonly string _consumerName;

    protected StreamConsumer(
        IConnectionMultiplexer redis,
        string streamKey,
        string groupName)
    {
        _db = redis.GetDatabase();
        _streamKey = streamKey;
        _groupName = groupName;
        _consumerName = $"{Environment.MachineName}-{Guid.NewGuid():N[8]}";
    }

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        await EnsureGroupAsync();

        while (!ct.IsCancellationRequested)
        {
            try
            {
                var messages = await _db.StreamReadGroupAsync(
                    _streamKey, _groupName, _consumerName, ">", count: 10, noAck: false);

                if (!messages.Any())
                {
                    await Task.Delay(50, ct);
                    continue;
                }

                foreach (var msg in messages)
                {
                    try
                    {
                        var payloadJson = msg.Values
                            .FirstOrDefault(v => v.Name == "payload").Value;

                        var payload = JsonSerializer.Deserialize<T>(payloadJson!);
                        await ProcessAsync(payload!, msg.Id.ToString(), ct);

                        await _db.StreamAcknowledgeAsync(_streamKey, _groupName, msg.Id);
                    }
                    catch (Exception ex) when (ex is not OperationCanceledException)
                    {
                        await OnProcessingFailedAsync(msg, ex);
                    }
                }
            }
            catch (OperationCanceledException) { break; }
            catch (Exception ex)
            {
                await Task.Delay(1000, ct); // Brief backoff on infrastructure errors
            }
        }
    }

    protected abstract Task ProcessAsync(T message, string messageId, CancellationToken ct);

    protected virtual Task OnProcessingFailedAsync(StreamEntry msg, Exception ex)
    {
        // Override for custom error handling / DLQ
        return Task.CompletedTask;
    }

    private async Task EnsureGroupAsync()
    {
        try
        {
            await _db.StreamCreateConsumerGroupAsync(_streamKey, _groupName, "$", true);
        }
        catch (RedisServerException ex) when (ex.Message.Contains("BUSYGROUP")) { }
    }
}

// ── Concrete consumer implementation ──────────────────────────────────
public class OrderCreatedConsumer : StreamConsumer<OrderCreatedEvent>
{
    private readonly IEmailService _email;

    public OrderCreatedConsumer(IConnectionMultiplexer redis, IEmailService email)
        : base(redis, "stream:orders", "email-notifications")
    {
        _email = email;
    }

    protected override async Task ProcessAsync(
        OrderCreatedEvent evt, string messageId, CancellationToken ct)
    {
        await _email.SendOrderConfirmationAsync(evt.UserId, evt.OrderId, ct);
    }
}

// Registration
builder.Services.AddHostedService<OrderCreatedConsumer>();
```

---

## Event Sourcing with Streams

```csharp
// WHY: Redis Streams naturally model event sourcing — append-only, ordered, replayable
public class EventStore
{
    private readonly IDatabase _db;

    public async Task<string> AppendEventAsync<TEvent>(
        string aggregateId,
        TEvent @event,
        int? expectedVersion = null) where TEvent : IDomainEvent
    {
        string streamKey = $"events:{typeof(TEvent).Name.Replace("Event", "").ToLower()}:{aggregateId}";

        // WHY: Optimistic concurrency — check stream length matches expected version
        if (expectedVersion.HasValue)
        {
            var length = await _db.StreamLengthAsync(streamKey);
            if (length != expectedVersion.Value)
                throw new ConcurrencyException($"Expected version {expectedVersion} but got {length}");
        }

        return (await _db.StreamAddAsync(streamKey, new NameValueEntry[]
        {
            new("eventType", @event.GetType().Name),
            new("payload", JsonSerializer.Serialize(@event)),
            new("occurredAt", @event.OccurredAt.ToString("O")),
            new("version", (await _db.StreamLengthAsync(streamKey)).ToString())
        }))!;
    }

    public async Task<IEnumerable<IDomainEvent>> GetEventsAsync(
        string aggregateId,
        string aggregateType,
        string fromVersion = "0")
    {
        string streamKey = $"events:{aggregateType}:{aggregateId}";
        var entries = await _db.StreamRangeAsync(streamKey, fromVersion, "+");

        return entries.Select(e =>
        {
            var fields = e.Values.ToDictionary(v => v.Name.ToString(), v => v.Value.ToString());
            var eventType = fields["eventType"];
            var payload = fields["payload"];
            return DeserializeEvent(eventType, payload);
        });
    }

    // Rebuild aggregate from events (replay)
    public async Task<TAggregate> RehydrateAsync<TAggregate>(
        string aggregateId) where TAggregate : AggregateRoot, new()
    {
        var aggregate = new TAggregate();
        var events = await GetEventsAsync(aggregateId, typeof(TAggregate).Name);

        foreach (var evt in events)
            aggregate.Apply(evt);

        return aggregate;
    }
}
```

---

## Outbox Pattern with Streams

```csharp
// WHY: Outbox pattern ensures events are published if DB transaction succeeds
// Even if Redis is down at publish time, the outbox worker retries

// ── Step 1: Write to DB + Outbox in same transaction ──────────────────
public class OrderCommandHandler
{
    private readonly AppDbContext _dbContext;

    public async Task HandleAsync(CreateOrderCommand cmd, CancellationToken ct)
    {
        var order = Order.Create(cmd);

        // Write order + outbox event in same DB transaction
        _dbContext.Orders.Add(order);
        _dbContext.OutboxMessages.Add(new OutboxMessage
        {
            Id = Guid.NewGuid(),
            Type = "OrderCreated",
            Payload = JsonSerializer.Serialize(new OrderCreatedEvent(order.Id, order.UserId)),
            CreatedAt = DateTime.UtcNow,
            ProcessedAt = null
        });

        await _dbContext.SaveChangesAsync(ct); // Atomic — either both or neither
    }
}

// ── Step 2: Outbox worker reads DB and publishes to Redis Stream ───────
public class OutboxPublisherWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IDatabase _redis;

    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            // Get unprocessed outbox messages
            var messages = await db.OutboxMessages
                .Where(m => m.ProcessedAt == null)
                .OrderBy(m => m.CreatedAt)
                .Take(50)
                .ToListAsync(ct);

            foreach (var msg in messages)
            {
                await _redis.StreamAddAsync($"stream:{msg.Type.ToLower()}", new NameValueEntry[]
                {
                    new("type", msg.Type),
                    new("payload", msg.Payload),
                    new("outboxId", msg.Id.ToString())
                });

                msg.ProcessedAt = DateTime.UtcNow;
            }

            if (messages.Any())
                await db.SaveChangesAsync(ct);

            await Task.Delay(TimeSpan.FromSeconds(1), ct);
        }
    }
}
```

---

## Stream Trimming & Retention

```csharp
// WHY: Streams grow unbounded without trimming — set maxLength on XADD
// or run periodic trimming

// ── Trim on add (most efficient) ──────────────────────────────────────
await _db.StreamAddAsync("stream:events", fields,
    maxLength: 100_000,           // Keep last 100K messages
    useApproximateMaxLength: true); // WHY: faster — doesn't need exact trimming

// ── Trim to time-based ID ──────────────────────────────────────────────
// Delete messages older than 7 days
var cutoffMs = DateTimeOffset.UtcNow.AddDays(-7).ToUnixTimeMilliseconds();
await _db.StreamTrimAsync("stream:events",
    maxLength: 0,
    useApproximateMaxLength: true);

// ── Manual time-based cleanup ──────────────────────────────────────────
// XTRIM stream MINID ~1706123456789-0  (delete before this ID)
await _db.ExecuteAsync("XTRIM", "stream:events", "MINID", "~", $"{cutoffMs}-0");

// ── Monitor stream length ──────────────────────────────────────────────
long length = await _db.StreamLengthAsync("stream:orders");
var info = await _db.StreamInfoAsync("stream:orders");
// info.FirstEntry, info.LastEntry, info.Length, info.Groups
```

---

## Monitoring Streams

```bash
# Stream info
XINFO STREAM orders
XINFO GROUPS orders
XINFO CONSUMERS orders order-processors

# Pending messages per group
XPENDING orders order-processors - + 100

# Stream length
XLEN orders

# Read specific range
XRANGE orders 1706123456789-0 + COUNT 10

# Delete specific entries (when DLQ'd)
XDEL orders 1706123456789-0
```

```csharp
// Monitoring in .NET
public class StreamHealthChecker
{
    private readonly IDatabase _db;

    public async Task<StreamHealthReport> CheckAsync(string streamKey, string groupName)
    {
        var info = await _db.StreamInfoAsync(streamKey);
        var pending = await _db.StreamPendingAsync(streamKey, groupName);

        return new StreamHealthReport(
            StreamLength: info.Length,
            PendingCount: pending.PendingMessageCount,
            OldestPendingMs: pending.PendingMessageCount > 0
                ? (long)(DateTime.UtcNow - pending.LowestPendingMessageId.ToString()
                    .Split('-').First()
                    .Let(ms => DateTimeOffset.FromUnixTimeMilliseconds(long.Parse(ms)).UtcDateTime)).TotalMilliseconds
                : 0);
    }
}

public record StreamHealthReport(long StreamLength, long PendingCount, long OldestPendingMs);
```

---

*Next:* [07-Redis-Leaderboards-SortedSets.md](07-Redis-Leaderboards-SortedSets.md) — Leaderboards, priority queues, time-series indexing
