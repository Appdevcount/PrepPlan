# Azure Event Hubs — Complete Guide (Beginner to Expert)
> Deep-dive reference: architecture, code, patterns, security, performance, and interview prep.
> Stack: C# / .NET 8+, Azure SDK, Kafka Protocol, Bicep, KQL

---

## Table of Contents

| # | Section |
|---|---------|
| 1 | [What is Azure Event Hubs?](#1-what-is-azure-event-hubs) |
| 2 | [Core Concepts — The Building Blocks](#2-core-concepts) |
| 3 | [Event Hubs Tiers](#3-event-hubs-tiers) |
| 4 | [Architecture Deep Dive](#4-architecture-deep-dive) |
| 5 | [Sending Events — Producer (Beginner → Expert)](#5-sending-events--producer) |
| 6 | [Receiving Events — Consumer (Beginner → Expert)](#6-receiving-events--consumer) |
| 7 | [EventProcessorClient — Production-Grade Consumer](#7-eventprocessorclient--production-grade) |
| 8 | [Checkpointing & Offset Management](#8-checkpointing--offset-management) |
| 9 | [Partitioning Strategy — Critical Design Decision](#9-partitioning-strategy) |
| 10 | [Kafka Protocol Support](#10-kafka-protocol-support) |
| 11 | [Schema Registry](#11-schema-registry) |
| 12 | [Event Hubs Capture](#12-event-hubs-capture) |
| 13 | [Azure Functions Integration](#13-azure-functions-integration) |
| 14 | [Stream Analytics Integration](#14-stream-analytics-integration) |
| 15 | [Security — Auth, Network, Encryption](#15-security) |
| 16 | [Monitoring, Metrics & KQL](#16-monitoring-metrics--kql) |
| 17 | [Advanced Patterns](#17-advanced-patterns) |
| 18 | [Geo-Replication & Disaster Recovery](#18-geo-replication--disaster-recovery) |
| 19 | [Performance & Scaling](#19-performance--scaling) |
| 20 | [Provisioning with Bicep & Terraform](#20-provisioning-with-bicep--terraform) |
| 21 | [Event Hubs vs Service Bus vs Event Grid vs Kafka](#21-event-hubs-vs-alternatives) |
| 22 | [Production Checklist](#22-production-checklist) |
| 23 | [Interview Q&A — 30 Questions](#23-interview-qa) |

---

## 1. What is Azure Event Hubs?

> **Mental Model:** Event Hubs is a multi-lane highway for data. Thousands of cars (events) enter from on-ramps (producers) and flow through dedicated lanes (partitions). Multiple highway patrol cars (consumer groups) can monitor every lane simultaneously — each at their own speed — without interfering with each other.

Azure Event Hubs is a **fully managed, real-time data streaming platform** and event ingestion service. It can receive and process millions of events per second with low latency.

```
┌────────────────────────────────────────────────────────────────────────┐
│                      AZURE EVENT HUBS — BIG PICTURE                    │
│                                                                         │
│  Producers (any language/platform)                                      │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐                               │
│  │ App  │  │ IoT  │  │ Logs │  │Click │  ... (millions/sec)            │
│  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘                               │
│     │         │          │          │                                   │
│     └─────────┴──────────┴──────────┘                                   │
│                          │  AMQP / HTTPS / Kafka                        │
│                          ▼                                              │
│              ┌───────────────────────┐                                  │
│              │    Event Hub           │  (append-only log)              │
│              │  ┌──────────────────┐ │                                  │
│              │  │ Partition 0      │ │◄── Events stored up to 90 days  │
│              │  │ [e0][e1][e2]...  │ │                                  │
│              │  ├──────────────────┤ │                                  │
│              │  │ Partition 1      │ │                                  │
│              │  │ [e0][e1][e2]...  │ │                                  │
│              │  ├──────────────────┤ │                                  │
│              │  │ Partition N      │ │                                  │
│              │  └──────────────────┘ │                                  │
│              └───────────────────────┘                                  │
│                          │                                              │
│         ┌────────────────┼────────────────┐                             │
│         │                │                │                             │
│   Consumer Group A  Consumer Group B   Capture                         │
│   (Analytics)       (Monitoring)       (Blob/ADLS)                     │
│   reads at offset   reads at offset                                    │
│   1024              987                                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Characteristics

| Property | Value |
|----------|-------|
| Protocol | AMQP 1.0, HTTPS, Apache Kafka 1.0+ |
| Throughput | Millions of events/sec, GB/sec |
| Latency | Milliseconds |
| Retention | 1 hour – 90 days |
| Max event size | 1 MB (Standard/Premium) |
| Ordering | Guaranteed within a partition |
| Delivery | At-least-once |
| Replay | Yes — consumers control their offset |

### When to Use Event Hubs

- **Telemetry ingestion:** Application logs, metrics, click-streams
- **IoT data pipeline:** Device sensor data at massive scale
- **Event streaming:** Clickstream analytics, fraud detection
- **Log aggregation:** Centralize logs from many services before forwarding to Splunk/Elastic
- **Real-time analytics pipeline:** Feed Azure Stream Analytics, Databricks, Synapse

### When NOT to Use Event Hubs

- **Reliable command messages** between services → use Azure Service Bus
- **Reactive push notifications** on Azure resource changes → use Event Grid
- **Request/reply pattern** → use Service Bus with correlation ID
- **Message ordering across all events** (not just per partition) → use Service Bus sessions

---

## 2. Core Concepts

> **Mental Model:** Think of Event Hubs like a library with multiple bookshelves (partitions). Books are added to shelves in order. Multiple reading groups can read the same shelves independently, each with their own bookmark (offset/checkpoint).

---

### 2.1 Namespace

The top-level container — like a server that hosts multiple Event Hubs.

```
Namespace: mycompany-eventhubs.servicebus.windows.net
├── Event Hub: orders
├── Event Hub: payments
├── Event Hub: telemetry
└── Event Hub: user-activity
```

- Namespace = billing unit (Throughput Units are defined at namespace level in Standard)
- Namespace has its own FQDN, connection strings, firewall rules

---

### 2.2 Event Hub

An individual stream — analogous to a Kafka Topic.

- Has N partitions (configured at creation, cannot be reduced)
- Has message retention (1h to 90 days depending on tier)
- Has consumer groups

---

### 2.3 Partitions — The Heart of Event Hubs

```
┌─────────────────────────────────────────────────────────────────┐
│                         PARTITION DETAIL                         │
│                                                                  │
│  Partition 0  (append-only, ordered log)                         │
│  ┌────┬────┬────┬────┬────┬────┬────┬────┬────┐                │
│  │ e0 │ e1 │ e2 │ e3 │ e4 │ e5 │ e6 │ e7 │ e8 │ ...          │
│  └────┴────┴────┴────┴────┴────┴────┴────┴────┘                │
│    │                                                              │
│  offset=0  offset=1  ...  (monotonically increasing)            │
│                                                                  │
│  Each event has:                                                 │
│  - Sequence Number (monotonic within partition)                  │
│  - Offset (byte position within partition)                       │
│  - Enqueued Time (UTC timestamp when received by Event Hubs)     │
│  - Partition Key (used for routing)                              │
│  - Properties (custom key-value metadata)                        │
│  - Body (binary payload, max 1MB)                                │
└──────────────────────────────────────────────────────────────────┘
```

**Critical Rules:**
- Events within a single partition are **always ordered** (by sequence number)
- Ordering is **NOT guaranteed across partitions**
- Partition count is **fixed at creation** — cannot reduce; can only increase on Premium/Dedicated
- Default: 4 partitions. Max: 2048 (Premium/Dedicated), 32 (Standard)

---

### 2.4 Consumer Groups

```
┌──────────────────────────────────────────────────────────────────┐
│                      CONSUMER GROUPS                              │
│                                                                   │
│  Same Event Hub, 3 independent Consumer Groups:                   │
│                                                                   │
│  Partition 0: [e0][e1][e2][e3][e4][e5][e6][e7]                  │
│                                                                   │
│  analytics-cg:   ↑                                               │
│                  offset=2 (processing slowly, behind by 5)        │
│                                                                   │
│  monitoring-cg:              ↑                                   │
│                              offset=5 (real-time, almost current) │
│                                                                   │
│  archive-cg:                           ↑                         │
│                                        offset=7 (near real-time)  │
└──────────────────────────────────────────────────────────────────┘
```

- Each consumer group has an **independent read cursor (offset)** per partition
- One consumer group = one logical "view" of the stream
- Up to **100 consumer groups** per Event Hub (Standard/Premium)
- The **`$Default`** consumer group always exists

**Rule:** Each **partition** within a consumer group should have **at most one active reader** at a time. Multiple readers on the same partition in the same CG = duplicate reads and conflicts.

---

### 2.5 Key Terms Reference

| Term | Definition |
|------|-----------|
| **Sequence Number** | Monotonically increasing integer per partition (assigned by Event Hubs) |
| **Offset** | Byte offset of an event within a partition stream |
| **Enqueued Time** | UTC time when Event Hubs received the event |
| **Partition Key** | String used to hash-route events to a partition; same key = same partition |
| **Checkpoint** | Saving your read position (offset/sequence) so you can resume after restart |
| **Consumer Lag** | Latest offset − consumer's current offset = how far behind the consumer is |
| **Throughput Unit (TU)** | Scale unit for Standard namespace (1 TU = 1 MB/s in, 2 MB/s out) |
| **Processing Unit (PU)** | Scale unit for Premium namespace (more powerful than TU) |
| **Capture** | Auto-archive feature — writes events to Blob/ADLS in Avro/Parquet format |
| **Schema Registry** | Central repository for Avro/JSON schemas with versioning |

---

## 3. Event Hubs Tiers

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        EVENT HUBS TIER COMPARISON                             │
├────────────────┬──────────┬──────────┬───────────────┬──────────────────────┤
│ Feature        │  Basic   │ Standard │   Premium      │  Dedicated           │
├────────────────┼──────────┼──────────┼───────────────┼──────────────────────┤
│ Partitions     │ 2-32     │ 2-32     │ 2-2048        │ 2-2048               │
│ Consumer Groups│ 1 (Def.) │ 20 max   │ 100 max       │ Unlimited            │
│ Retention      │ 1 day    │ 7 days   │ 90 days       │ 90 days              │
│ Capture        │ No       │ Yes      │ Yes           │ Yes                  │
│ Schema Registry│ No       │ Yes      │ Yes           │ Yes                  │
│ Private Endpoint│ No      │ No       │ Yes           │ Yes                  │
│ Kafka Protocol │ No       │ Yes      │ Yes           │ Yes                  │
│ Scaling        │ 1-20 TU  │ 1-40 TU  │ 1-16 PU       │ Dedicated cluster    │
│ Geo-DR         │ No       │ Yes      │ Yes           │ Yes                  │
│ Geo-replication│ No       │ No       │ Yes (Preview) │ Yes                  │
│ SLA            │ 99.9%    │ 99.9%    │ 99.95%        │ 99.99%               │
│ Isolation      │ Shared   │ Shared   │ Isolated infra│ Fully dedicated      │
│ Use Case       │ Dev/Test │ Standard │ High perf,    │ Enterprise, highest  │
│                │          │ workloads│ compliance    │ throughput           │
└────────────────┴──────────┴──────────┴───────────────┴──────────────────────┘
```

### Throughput Units vs Processing Units

**Standard — Throughput Units (TU):**
- 1 TU = 1 MB/s ingress, 2 MB/s egress, up to 1,000 events/sec
- Auto-inflate: TUs auto-scale up (but NOT down) to defined max
- Shared infrastructure (noisy neighbor possible)

**Premium — Processing Units (PU):**
- Isolated compute — no noisy neighbor problem
- 1 PU ≈ 10-15x a single TU in throughput
- Supports Availability Zones, Private Endpoints, up to 2048 partitions
- Scale up AND down dynamically

**Dedicated — Capacity Units (CU):**
- Entire cluster reserved for you
- Predictable performance at enterprise scale
- Fixed pricing regardless of usage

---

## 4. Architecture Deep Dive

### 4.1 Internal Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                    EVENT HUBS INTERNAL ARCHITECTURE                 │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    AMQP/Kafka Gateway                        │   │
│  │  (protocol translation, auth, TLS termination)              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│  ┌───────────────────────────▼─────────────────────────────────┐   │
│  │                   Partition Manager                          │   │
│  │  (assigns partitions, tracks offsets, manages leases)       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│         ┌────────────────────┼────────────────────┐                │
│         ▼                    ▼                    ▼                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│  │ Partition 0 │    │ Partition 1 │    │ Partition N │            │
│  │  (3 replicas│    │  (3 replicas│    │  (3 replicas│            │
│  │   within AZ)│    │   within AZ)│    │   within AZ)│            │
│  └─────────────┘    └─────────────┘    └─────────────┘            │
│                                                                     │
│  Storage: Apache Kafka-like commit log (append-only segments)       │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Event Routing

```
Producer sends event
       │
       ├─ With Partition Key → Hash(key) % PartitionCount → specific partition
       │                       (guaranteed: same key = same partition always)
       │
       ├─ With Partition ID → directly to that partition (bypass hashing)
       │
       └─ No key, No ID → Round-robin across partitions (load balanced)
                          (ordering NOT preserved across events without key)
```

### 4.3 Lease Management (How Consumer Groups Work at Scale)

When using `EventProcessorClient` (the production SDK), each partition is "leased":

```
Namespace: Blob Storage (lease store)
  ├── partition-0.json  { "ownerId": "consumer-instance-A", "offset": 1024 }
  ├── partition-1.json  { "ownerId": "consumer-instance-B", "offset": 987  }
  ├── partition-2.json  { "ownerId": "consumer-instance-A", "offset": 2048 }
  └── partition-3.json  { "ownerId": "consumer-instance-C", "offset": 512  }

WHY: Leases prevent two consumer instances from reading the same partition
     simultaneously, which would cause duplicate processing.
```

When a consumer instance dies, its lease expires (default: 60 seconds), and another instance picks it up. This is **automatic load balancing**.

---

## 5. Sending Events — Producer

### 5.1 Beginner — Send a Single Event

```csharp
// ── NuGet: Azure.Messaging.EventHubs ─────────────────────────────────
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;

// WHY: EventHubProducerClient is thread-safe and long-lived.
// Create once, reuse throughout the application lifetime.
await using var producer = new EventHubProducerClient(
    connectionString: "Endpoint=sb://my-ns.servicebus.windows.net/;...",
    eventHubName: "orders");

// WHY: Always send in batches for efficiency — EventDataBatch handles
// size limits automatically and throws if an event is too large to fit
using EventDataBatch batch = await producer.CreateBatchAsync();

// Create event — body is binary (use JSON serialization)
var orderEvent = new OrderCreatedEvent(
    OrderId: Guid.NewGuid().ToString(),
    CustomerId: "cust-123",
    TotalAmount: 299.99m,
    CreatedAt: DateTimeOffset.UtcNow);

var eventData = new EventData(
    BinaryData.FromObjectAsJson(orderEvent));  // serializes to UTF-8 JSON

// Add metadata as properties — searchable without deserializing body
eventData.Properties["EventType"] = "Order.Created";
eventData.Properties["SchemaVersion"] = "1.0";
eventData.Properties["TenantId"] = "tenant-abc";

// WHY: TryAdd returns false (doesn't throw) if event is too large for batch
if (!batch.TryAdd(eventData))
    throw new InvalidOperationException("Event too large for batch");

// WHY: SendAsync is the ONLY way to send — never SendSync
await producer.SendAsync(batch);

Console.WriteLine($"Sent batch with {batch.Count} event(s)");
```

### 5.2 Intermediate — Batch Sending with Partition Key

```csharp
// ── Batch with Partition Key (guarantees partition co-location) ───────
public async Task SendOrderEventsAsync(
    EventHubProducerClient producer,
    string tenantId,
    IEnumerable<OrderEvent> events,
    CancellationToken ct)
{
    // WHY: CreateBatchOptions.PartitionKey ensures all events in THIS batch
    // go to the same partition. Same key across batches → same partition.
    var batchOptions = new CreateBatchOptions
    {
        PartitionKey = tenantId   // WHY: All events for a tenant are co-located
                                  // and ordered relative to each other
    };

    using var batch = await producer.CreateBatchAsync(batchOptions, ct);

    foreach (var orderEvent in events)
    {
        var data = new EventData(BinaryData.FromObjectAsJson(orderEvent));
        data.Properties["EventType"] = orderEvent.GetType().Name;
        data.ContentType = "application/json";  // WHY: Self-describing for consumers

        if (!batch.TryAdd(data))
        {
            // WHY: Flush current batch and start a new one when full
            // Avoids silently dropping events that don't fit
            if (batch.Count > 0)
                await producer.SendAsync(batch, ct);

            // Start fresh batch — must reset since EventDataBatch is not reusable
            batch.Dispose();
            using var newBatch = await producer.CreateBatchAsync(batchOptions, ct);

            if (!newBatch.TryAdd(data))
                throw new InvalidOperationException(
                    $"Event for {orderEvent.GetType().Name} exceeds max batch size");
        }
    }

    // WHY: Send remaining events in the last batch
    if (batch.Count > 0)
        await producer.SendAsync(batch, ct);
}
```

### 5.3 Advanced — High-Throughput Producer with Partitioned Batching

```csharp
// ── High-throughput: one batch per partition, sent in parallel ────────
public sealed class PartitionedProducer : IAsyncDisposable
{
    private readonly EventHubProducerClient _producer;
    private readonly ILogger<PartitionedProducer> _logger;

    public PartitionedProducer(string connectionString, string hubName,
        ILogger<PartitionedProducer> logger)
    {
        _producer = new EventHubProducerClient(connectionString, hubName,
            new EventHubProducerClientOptions
            {
                // WHY: RetryOptions prevents transient failures from losing events
                RetryOptions = new EventHubsRetryOptions
                {
                    Mode = EventHubsRetryMode.Exponential,
                    MaximumRetries = 5,
                    Delay = TimeSpan.FromMilliseconds(500),
                    MaximumDelay = TimeSpan.FromSeconds(30)
                }
            });
        _logger = logger;
    }

    public async Task SendPartitionedAsync(
        IEnumerable<(string PartitionKey, object Payload)> events,
        CancellationToken ct)
    {
        // WHY: Group by partition key first — one batch per key for max throughput
        var grouped = events
            .GroupBy(e => e.PartitionKey)
            .ToDictionary(g => g.Key, g => g.Select(e => e.Payload).ToList());

        // WHY: Task.WhenAll sends all partition batches in parallel
        // instead of sequential (N * latency → max_latency)
        var sendTasks = grouped.Select(async kvp =>
        {
            var batchOptions = new CreateBatchOptions { PartitionKey = kvp.Key };
            using var batch = await _producer.CreateBatchAsync(batchOptions, ct);

            foreach (var payload in kvp.Value)
            {
                var eventData = new EventData(BinaryData.FromObjectAsJson(payload));
                eventData.Properties["PartitionKey"] = kvp.Key;
                eventData.Properties["SentAt"] = DateTimeOffset.UtcNow.ToString("O");

                if (!batch.TryAdd(eventData))
                {
                    _logger.LogWarning("Batch full for key {Key}, sending partial batch",
                        kvp.Key);
                    await _producer.SendAsync(batch, ct);
                }
            }

            if (batch.Count > 0)
            {
                await _producer.SendAsync(batch, ct);
                _logger.LogDebug("Sent {Count} events for partition key {Key}",
                    batch.Count, kvp.Key);
            }
        });

        await Task.WhenAll(sendTasks);
    }

    // WHY: DisposeAsync ensures AMQP connection is properly closed
    public async ValueTask DisposeAsync() => await _producer.DisposeAsync();
}
```

### 5.4 Producer with Managed Identity (Production Best Practice)

```csharp
// ── Use Managed Identity — no connection string in code ──────────────
// WHY: Managed Identity eliminates secret rotation risk entirely
// In Azure: uses the resource's system/user-assigned identity automatically
// Locally: uses developer's az login credentials via DefaultAzureCredential
using Azure.Identity;

var producer = new EventHubProducerClient(
    fullyQualifiedNamespace: "my-ns.servicebus.windows.net", // WHY: no shared secret in FQDN
    eventHubName: "orders",
    credential: new DefaultAzureCredential());               // WHY: works in all environments

// Required RBAC role: "Azure Event Hubs Data Sender" on the Event Hub or Namespace
```

---

## 6. Receiving Events — Consumer

### 6.1 Beginner — Read from a Single Partition

```csharp
// ── Simple consumer — reads from one partition ────────────────────────
// WHY: Use this for debugging/exploration; use EventProcessorClient in production
await using var consumer = new PartitionReceiver(
    consumerGroup: EventHubConsumerClient.DefaultConsumerGroupName,
    partitionId: "0",                                    // hardcoded partition
    eventPosition: EventPosition.FromEnqueuedTime(       // WHY: start from 1 hour ago
        DateTimeOffset.UtcNow.AddHours(-1)),
    connectionString: connectionString,
    eventHubName: "orders");

// WHY: CancellationToken allows graceful shutdown
using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));

await foreach (var partitionEvent in consumer.ReadBatchAsync(
    maximumMessageCount: 100,
    maximumWaitTime: TimeSpan.FromSeconds(5),            // WHY: don't block forever
    cancellationToken: cts.Token))
{
    var body = partitionEvent.Data.EventBody.ToObjectFromJson<OrderCreatedEvent>();
    Console.WriteLine($"Received order: {body.OrderId} at offset {partitionEvent.Data.Offset}");
}
```

### 6.2 Intermediate — EventHubConsumerClient (Browse/Inspect)

```csharp
// ── PartitionReceiver for inspecting specific events by position ───────
await using var consumerClient = new EventHubConsumerClient(
    consumerGroup: "$Default",
    connectionString: connectionString,
    eventHubName: "orders");

// Get partition metadata first
var properties = await consumerClient.GetEventHubPropertiesAsync();
Console.WriteLine($"Partitions: {string.Join(", ", properties.PartitionIds)}");

foreach (var partitionId in properties.PartitionIds)
{
    var partInfo = await consumerClient.GetPartitionPropertiesAsync(partitionId);
    Console.WriteLine($"Partition {partitionId}:");
    Console.WriteLine($"  Last Sequence: {partInfo.LastEnqueuedSequenceNumber}");
    Console.WriteLine($"  Last Offset:   {partInfo.LastEnqueuedOffset}");
    Console.WriteLine($"  Is Empty:      {partInfo.IsEmpty}");
    Console.WriteLine($"  Last Enqueued: {partInfo.LastEnqueuedTime}");
}

// WHY: EventPosition.Earliest = replay ALL events from the beginning
// Use EventPosition.Latest for real-time (only new events after subscribe)
var startPosition = EventPosition.FromSequenceNumber(
    sequenceNumber: 1000,
    isInclusive: true);   // WHY: isInclusive=true reads FROM sequence 1000 (not after)

await foreach (var eventData in consumerClient.ReadEventsFromPartitionAsync(
    partitionId: "0",
    startingPosition: startPosition,
    cancellationToken: CancellationToken.None))
{
    Console.WriteLine($"Seq: {eventData.Data.SequenceNumber}, " +
                      $"Offset: {eventData.Data.Offset}, " +
                      $"Body: {eventData.Data.EventBody}");

    // WHY: Break manually since this is an infinite stream
    if (eventData.Data.SequenceNumber > 1100) break;
}
```

---

## 7. EventProcessorClient — Production-Grade

> **Mental Model:** EventProcessorClient is the automated factory floor manager — it assigns workers (instances) to assembly lines (partitions), tracks where each line stopped, and reassigns work if a worker goes home sick, without losing a single item.

This is the **correct way** to consume events in production. It handles:
- Partition ownership via distributed lease management
- Automatic load balancing across consumer instances
- Checkpointing (saving read position)
- Error handling and recovery

```csharp
// ── NuGet: Azure.Messaging.EventHubs.Processor ───────────────────────
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;

// ── Setup ─────────────────────────────────────────────────────────────
// WHY: BlobContainerClient stores partition leases and checkpoints
// This is the coordination store that enables distributed consumer groups
var storageClient = new BlobContainerClient(
    storageConnectionString,
    containerName: "event-processor-checkpoints");

// WHY: Create container if not exists — idempotent
await storageClient.CreateIfNotExistsAsync();

var processor = new EventProcessorClient(
    checkpointStore: storageClient,
    consumerGroup: "$Default",
    connectionString: eventHubsConnectionString,
    eventHubName: "orders",
    clientOptions: new EventProcessorClientOptions
    {
        // WHY: Each instance claims a partition for this long before it must renew
        // If renewal fails (instance dies), another instance can claim after this period
        PartitionOwnershipExpirationInterval = TimeSpan.FromSeconds(60),

        // WHY: How often the processor rebalances ownership across instances
        LoadBalancingUpdateInterval = TimeSpan.FromSeconds(10),

        // WHY: Max events buffered per partition before processing
        // Higher = higher throughput but more memory
        CacheEventCount = 100,

        // WHY: How long to wait for events before cycling (prevents tight loops)
        MaximumWaitTime = TimeSpan.FromSeconds(30),

        RetryOptions = new EventHubsRetryOptions
        {
            Mode = EventHubsRetryMode.Exponential,
            MaximumRetries = 5,
            MaximumDelay = TimeSpan.FromSeconds(30)
        }
    });

// ── Register Handlers ─────────────────────────────────────────────────
processor.ProcessEventAsync += ProcessEventHandler;
processor.ProcessErrorAsync += ProcessErrorHandler;
processor.PartitionInitializingAsync += PartitionInitializingHandler;
processor.PartitionClosingAsync += PartitionClosingHandler;

// ── Start Processing ──────────────────────────────────────────────────
// WHY: StartProcessingAsync is non-blocking — returns immediately
// The processor runs on background threads
await processor.StartProcessingAsync();

// WHY: Keep alive — wait for shutdown signal (Ctrl+C or app stop)
using var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    cts.Cancel();
};

try
{
    await Task.Delay(Timeout.Infinite, cts.Token);
}
catch (TaskCanceledException) { }
finally
{
    // WHY: StopProcessingAsync gracefully drains in-flight events
    await processor.StopProcessingAsync();
}
```

### 7.1 Event Handler — Full Implementation

```csharp
// ── Process Event Handler ─────────────────────────────────────────────
private async Task ProcessEventHandler(ProcessEventArgs eventArgs)
{
    try
    {
        // WHY: HasEvent is false during idle cycles (MaximumWaitTime elapsed, no events)
        // This still fires so you can do periodic tasks (flush buffers, etc.)
        if (!eventArgs.HasEvent)
        {
            // Opportunity for periodic housekeeping — e.g., flush accumulated state
            return;
        }

        // ── Read event metadata ───────────────────────────────────────
        var eventData = eventArgs.Data;
        var partitionId = eventArgs.Partition.PartitionId;

        Console.WriteLine($"Partition {partitionId} | " +
                          $"SeqNo: {eventData.SequenceNumber} | " +
                          $"Offset: {eventData.Offset} | " +
                          $"EnqueuedTime: {eventData.EnqueuedTime:O}");

        // ── Read custom properties ────────────────────────────────────
        if (eventData.Properties.TryGetValue("EventType", out var eventType))
            Console.WriteLine($"EventType: {eventType}");

        // ── Deserialize body ──────────────────────────────────────────
        var order = eventData.EventBody.ToObjectFromJson<OrderCreatedEvent>();
        Console.WriteLine($"Processing order: {order.OrderId}");

        // ── Business logic ────────────────────────────────────────────
        await ProcessOrderAsync(order);

        // ── Checkpoint AFTER successful processing ────────────────────
        // WHY: Checkpoint AFTER processing, never before
        // If we crash after checkpoint but before processing, we'd LOSE the event
        // At-least-once: crash before checkpoint → replay the event (idempotent handler needed)
        await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
    }
    catch (JsonException ex)
    {
        // WHY: Deserialize errors are non-retryable — log and skip (dead-letter manually)
        // Don't checkpoint so we can investigate, but don't block the partition
        _logger.LogError(ex, "Deserialization failed for event at offset {Offset}",
            eventArgs.Data?.Offset);

        // Option: Write to dead-letter blob storage manually for investigation
        await WriteToDlqAsync(eventArgs.Data, ex);

        // WHY: Checkpoint anyway to avoid infinite loop on poison message
        await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
    }
    catch (Exception ex) when (ex is not OperationCanceledException)
    {
        // WHY: Non-fatal errors are logged; processor will retry the event
        // (will re-read from last checkpoint on this partition)
        _logger.LogError(ex, "Error processing event on partition {Partition}",
            eventArgs.Partition.PartitionId);
        // Do NOT checkpoint — forces retry from last checkpoint
        throw; // Re-throw causes processor to invoke ProcessErrorAsync
    }
}
```

### 7.2 Error Handler

```csharp
// ── Error Handler ─────────────────────────────────────────────────────
private Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
{
    // WHY: This fires for infrastructure errors (connection lost, lease stolen)
    // NOT for exceptions thrown in ProcessEventHandler (those propagate differently)

    var isWarning = eventArgs.Exception is EventHubsException ehEx &&
                    ehEx.IsTransient;  // WHY: Transient errors self-heal — just log warning

    if (isWarning)
        _logger.LogWarning(eventArgs.Exception,
            "Transient error on partition {Partition}, operation: {Operation}",
            eventArgs.PartitionId, eventArgs.Operation);
    else
        _logger.LogError(eventArgs.Exception,
            "Fatal error on partition {Partition}, operation: {Operation}",
            eventArgs.PartitionId, eventArgs.Operation);

    return Task.CompletedTask;
}
```

### 7.3 Partition Lifecycle Handlers

```csharp
// ── Partition Initializing — called when this instance claims a partition ──
private Task PartitionInitializingHandler(PartitionInitializingEventArgs eventArgs)
{
    _logger.LogInformation("Claiming partition {Partition}", eventArgs.PartitionId);

    // WHY: Override start position per partition if needed
    // Default: resume from last checkpoint, or from Latest if no checkpoint
    // Override for custom replay scenarios:
    // eventArgs.DefaultStartingPosition = EventPosition.Earliest; // replay all
    // eventArgs.DefaultStartingPosition = EventPosition.FromEnqueuedTime(
    //     DateTimeOffset.UtcNow.AddHours(-1));                    // last hour

    return Task.CompletedTask;
}

// ── Partition Closing — called when this instance releases a partition ──
private Task PartitionClosingHandler(PartitionClosingEventArgs eventArgs)
{
    // WHY: CloseReason tells you WHY the partition was released:
    // OwnershipLost = another instance took the lease (normal rebalance)
    // Shutdown = processor is stopping (graceful)
    _logger.LogInformation("Releasing partition {Partition}, reason: {Reason}",
        eventArgs.PartitionId, eventArgs.Reason);

    // Good place to flush any local state buffered for this partition
    return Task.CompletedTask;
}
```

### 7.4 DI Registration (ASP.NET Core / Worker Service)

```csharp
// ── Program.cs — production Worker Service setup ─────────────────────
builder.Services.AddSingleton(_ =>
{
    var storageClient = new BlobContainerClient(
        builder.Configuration["Storage:ConnectionString"],
        "eventhub-checkpoints");
    storageClient.CreateIfNotExists();
    return storageClient;
});

builder.Services.AddSingleton(sp =>
    new EventProcessorClient(
        checkpointStore: sp.GetRequiredService<BlobContainerClient>(),
        consumerGroup: "$Default",
        // WHY: Use Managed Identity in production — no secrets
        fullyQualifiedNamespace: builder.Configuration["EventHub:Namespace"],
        eventHubName: builder.Configuration["EventHub:HubName"],
        credential: new DefaultAzureCredential()));

// WHY: BackgroundService ensures processor starts with the app
// and stops gracefully on shutdown
builder.Services.AddHostedService<EventHubProcessorService>();
```

```csharp
// ── EventHubProcessorService.cs ───────────────────────────────────────
public sealed class EventHubProcessorService : BackgroundService
{
    private readonly EventProcessorClient _processor;
    private readonly ILogger<EventHubProcessorService> _logger;

    public EventHubProcessorService(
        EventProcessorClient processor,
        ILogger<EventHubProcessorService> logger)
    {
        _processor = processor;
        _logger = logger;
        _processor.ProcessEventAsync += OnProcessEventAsync;
        _processor.ProcessErrorAsync += OnProcessErrorAsync;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await _processor.StartProcessingAsync(stoppingToken);
        // WHY: Await stoppingToken to keep the service alive until shutdown
        await Task.Delay(Timeout.Infinite, stoppingToken).ConfigureAwait(false);
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Stopping Event Hub processor...");
        await _processor.StopProcessingAsync(cancellationToken);
        await base.StopAsync(cancellationToken);
    }

    private async Task OnProcessEventAsync(ProcessEventArgs args)
    {
        // ... process logic ...
        await args.UpdateCheckpointAsync(args.CancellationToken);
    }

    private Task OnProcessErrorAsync(ProcessErrorEventArgs args)
    {
        _logger.LogError(args.Exception, "Processor error on partition {P}", args.PartitionId);
        return Task.CompletedTask;
    }
}
```

---

## 8. Checkpointing & Offset Management

> **Mental Model:** A bookmark in a book. If you close the book, the bookmark tells you exactly where to resume. Without it, you'd have to start from the beginning every time.

```
┌──────────────────────────────────────────────────────────────────────┐
│                    CHECKPOINT STRATEGIES                              │
│                                                                      │
│  Strategy 1: Checkpoint every event                                  │
│  [e0]✓ [e1]✓ [e2]✓ [e3]✓ [e4]✓                                    │
│  PRO: Minimal reprocessing on crash                                  │
│  CON: High Blob Storage I/O and cost; slower throughput             │
│                                                                      │
│  Strategy 2: Checkpoint every N events (batch checkpoint)            │
│  [e0][e1][e2][e3][e4][e5][e6][e7][e8][e9]✓  (every 10)            │
│  PRO: Better throughput, lower storage cost                          │
│  CON: On crash, up to 9 events are reprocessed (must be idempotent) │
│                                                                      │
│  Strategy 3: Checkpoint on timer (every 30 seconds)                  │
│  PRO: Decouples checkpointing from event count                       │
│  CON: Variable reprocessing window                                   │
│                                                                      │
│  RECOMMENDATION: Strategy 2 or 3 with idempotent handlers           │
└──────────────────────────────────────────────────────────────────────┘
```

### Batch Checkpointing Pattern

```csharp
// ── Batch checkpoint — checkpoint every 100 events or every 30 seconds ─
public sealed class BatchCheckpointProcessor
{
    private int _eventCount = 0;
    private ProcessEventArgs? _lastEventArgs;
    private readonly SemaphoreSlim _checkpointLock = new(1, 1);
    private readonly Timer _checkpointTimer;

    public BatchCheckpointProcessor()
    {
        // WHY: Timer ensures checkpoint happens even if traffic is low
        _checkpointTimer = new Timer(
            callback: async _ => await CheckpointIfPendingAsync(),
            state: null,
            dueTime: TimeSpan.FromSeconds(30),
            period: TimeSpan.FromSeconds(30));
    }

    public async Task HandleEventAsync(ProcessEventArgs args)
    {
        if (!args.HasEvent) return;

        // Process the event
        var order = args.Data.EventBody.ToObjectFromJson<OrderCreatedEvent>();
        await ProcessOrderAsync(order);

        // Track for batch checkpoint
        Interlocked.Increment(ref _eventCount);
        _lastEventArgs = args;  // WHY: Store latest args for checkpoint reference

        // WHY: Checkpoint every 100 events — balance between throughput and safety
        if (_eventCount % 100 == 0)
            await CheckpointIfPendingAsync();
    }

    private async Task CheckpointIfPendingAsync()
    {
        // WHY: Lock prevents concurrent checkpoint calls (timer + count-based)
        if (!await _checkpointLock.WaitAsync(0)) return; // Skip if already checkpointing
        try
        {
            if (_lastEventArgs is not null && _lastEventArgs.HasEvent)
            {
                await _lastEventArgs.UpdateCheckpointAsync(CancellationToken.None);
                _lastEventArgs = null;  // Clear after checkpoint
            }
        }
        finally
        {
            _checkpointLock.Release();
        }
    }
}
```

### EventPosition Options

```csharp
// ── Starting positions ────────────────────────────────────────────────
// From the very beginning (replay all stored events)
EventPosition.Earliest

// Only new events from now (skip all existing events)
EventPosition.Latest

// Resume from a specific offset (byte position)
EventPosition.FromOffset(offset: "12345", isInclusive: true)

// Resume from a sequence number
EventPosition.FromSequenceNumber(sequenceNumber: 999, isInclusive: false)

// Resume from a time (useful for time-based replay)
EventPosition.FromEnqueuedTime(DateTimeOffset.UtcNow.AddHours(-24))
```

---

## 9. Partitioning Strategy

> This is the **most critical design decision** in Event Hubs. Get it wrong and you'll have ordering issues, hot partitions, or poor scalability.

### 9.1 Partition Key Selection

```csharp
// ── Good partition keys ───────────────────────────────────────────────

// ✓ TenantId — all events for a tenant are ordered relative to each other
await producer.SendAsync(batch, new SendEventOptions { PartitionKey = tenantId });

// ✓ CustomerId — ordered view per customer (important for projections)
await producer.SendAsync(batch, new SendEventOptions { PartitionKey = customerId });

// ✓ DeviceId — IoT: all readings from one device are ordered
await producer.SendAsync(batch, new SendEventOptions { PartitionKey = deviceId });

// ✗ Bad: Timestamp as key — near-infinite cardinality, uneven distribution
// ✗ Bad: Static key ("all-events") — routes ALL events to ONE partition = hot partition
// ✗ Bad: Random key — you lose ordering but gain distribution (use null instead)
// ✗ Bad: Low-cardinality key with skew (e.g., "US" vs "UK" where 90% is US)
```

### 9.2 Hot Partition Problem

```
Problem: Partition key "region" with 90% events for "US"
  Partition 0 (US):  [e][e][e][e][e][e][e][e][e]  ← overloaded
  Partition 1 (EU):  [e]
  Partition 2 (APAC):[e]
  
Result: Partition 0 throughput exhausted; events queued; latency spikes

Solution 1: Use higher-cardinality key (customerId instead of region)
Solution 2: Composite key (region + customerId suffix: "US-cust-001")
Solution 3: No partition key (let Event Hubs load-balance round-robin)
            Accept: no ordering guarantee
```

### 9.3 How Many Partitions?

```
Rule of thumb:
  Partitions ≥ Max expected concurrent consumers
  Partitions ≥ Peak throughput (MB/s) / (1 MB/s per partition)

Decision table:
  ┌─────────────────────────┬──────────────────────────────────┐
  │  Requirement             │  Partition Count                 │
  ├─────────────────────────┼──────────────────────────────────┤
  │  < 100K events/sec       │  4-8 (default is fine)          │
  │  100K - 1M events/sec    │  16-32                          │
  │  > 1M events/sec         │  64-256+ (Premium/Dedicated)    │
  │  Per-entity ordering     │  Min = distinct entity count    │
  │  Kafka migration         │  Match Kafka topic partition cnt │
  └─────────────────────────┴──────────────────────────────────┘

WARNING: Partitions CANNOT be reduced after creation.
         Start conservative; Premium allows increase later.
```

---

## 10. Kafka Protocol Support

> **Mental Model:** Event Hubs speaks "Kafka dialect" fluently — your Kafka producer/consumer code works with minimal config changes, as if Event Hubs IS a Kafka broker.

```
Standard Kafka App:
  kafkaProducer.BootstrapServers = "kafka-broker:9092"

Event Hubs (Kafka endpoint):
  kafkaProducer.BootstrapServers = "my-ns.servicebus.windows.net:9093"
  (same code, different config — no code changes needed)
```

### C# Confluent.Kafka Producer → Event Hubs

```csharp
// ── NuGet: Confluent.Kafka ────────────────────────────────────────────
using Confluent.Kafka;

var config = new ProducerConfig
{
    BootstrapServers = "my-ns.servicebus.windows.net:9093",
    SecurityProtocol = SecurityProtocol.SaslSsl,
    SaslMechanism   = SaslMechanism.Plain,
    SaslUsername    = "$ConnectionString",  // WHY: literal string "$ConnectionString"
    SaslPassword    = eventHubsConnectionString,
    // WHY: Event Hubs requires SSL; Kafka's default port 9092 is not used
    SslCaLocation   = "probe",  // WHY: Use system CA store
    // Performance tuning
    Acks = Acks.All,            // WHY: Wait for all replicas — durability guarantee
    LingerMs = 5,               // WHY: Buffer for 5ms to batch more events per request
    BatchSize = 1048576,        // WHY: 1MB batch max
    CompressionType = CompressionType.Snappy // WHY: Reduce bandwidth cost
};

using var producer = new ProducerBuilder<string, string>(config).Build();

var result = await producer.ProduceAsync(
    topic: "orders",          // WHY: Kafka "topic" = Event Hubs "event hub name"
    message: new Message<string, string>
    {
        Key = customerId,     // WHY: Kafka message key = Event Hubs partition key
        Value = JsonSerializer.Serialize(order)
    });

Console.WriteLine($"Delivered to partition {result.Partition} at offset {result.Offset}");
```

### C# Confluent.Kafka Consumer via Event Hubs Kafka Endpoint

```csharp
// ── appsettings.json structure (read via IConfiguration) ─────────────
// {
//   "EventHubs": {
//     "Namespace": "my-ns.servicebus.windows.net",
//     "ConnectionString": "Endpoint=sb://my-ns.servicebus.windows.net/;SharedAccessKey=..."
//   }
// }

// ── NuGet: Confluent.Kafka ────────────────────────────────────────────
using Confluent.Kafka;

// ── Kafka Consumer configured against Event Hubs endpoint ────────────
var consumerConfig = new ConsumerConfig
{
    // WHY: Event Hubs Kafka endpoint is on port 9093 (SASL_SSL)
    BootstrapServers = $"{configuration["EventHubs:Namespace"]}:9093",
    SecurityProtocol  = SecurityProtocol.SaslSsl,
    SaslMechanism     = SaslMechanism.Plain,
    // WHY: Literal string "$ConnectionString" is the required Kafka username for Event Hubs
    SaslUsername      = "$ConnectionString",
    SaslPassword      = configuration["EventHubs:ConnectionString"],

    // WHY: Consumer group maps directly to Event Hubs consumer group
    GroupId           = "analytics-cg",
    AutoOffsetReset   = AutoOffsetReset.Earliest,  // WHY: Start from beginning on first run

    // WHY: Disable auto-commit — manage checkpoints manually for at-least-once safety
    EnableAutoCommit  = false,

    // Throughput tuning
    FetchMinBytes     = 1024,          // WHY: Wait for at least 1KB before returning — reduces round-trips
    FetchWaitMaxMs    = 500,           // WHY: Max 500ms wait if FetchMinBytes not met
    MaxPartitionFetchBytes = 1048576   // WHY: 1MB max per partition fetch (matches Event Hubs max event size)
};

using var consumer = new ConsumerBuilder<string, string>(consumerConfig)
    .SetErrorHandler((_, e) =>
        logger.LogError("Kafka consumer error: {Reason} (IsFatal={Fatal})", e.Reason, e.IsFatal))
    .SetPartitionsAssignedHandler((c, partitions) =>
        logger.LogInformation("Assigned partitions: {Partitions}",
            string.Join(", ", partitions.Select(p => p.Partition.Value))))
    .SetPartitionsRevokedHandler((c, partitions) =>
    {
        // WHY: Commit offsets before partition is revoked to avoid reprocessing
        c.Commit(partitions.Select(p => new TopicPartitionOffset(
            p.Topic, p.Partition, c.Position(p))));
        logger.LogInformation("Revoked partitions: {Partitions}",
            string.Join(", ", partitions.Select(p => p.Partition.Value)));
    })
    .Build();

consumer.Subscribe("orders");  // WHY: Kafka "topic" = Event Hubs event hub name

using var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) => { e.Cancel = true; cts.Cancel(); };

try
{
    while (!cts.IsCancellationRequested)
    {
        var result = consumer.Consume(cts.Token);
        if (result is null) continue;

        var order = JsonSerializer.Deserialize<OrderCreatedEvent>(result.Message.Value);
        await ProcessOrderAsync(order);

        // WHY: StoreOffset + manual commit every N messages — balance durability vs throughput
        consumer.StoreOffset(result);
        if (result.Offset.Value % 100 == 0)
            consumer.Commit();  // Commit every 100 messages
    }
}
catch (OperationCanceledException) { /* graceful shutdown */ }
finally
{
    consumer.Commit();  // WHY: Final commit on shutdown — don't lose last batch
    consumer.Close();
}
```

### Kafka vs Event Hubs Concept Mapping

| Kafka | Event Hubs |
|-------|-----------|
| Broker Cluster | Namespace |
| Topic | Event Hub |
| Partition | Partition |
| Consumer Group | Consumer Group |
| Offset | Offset |
| Producer | Producer |
| Consumer | Consumer |
| Zookeeper | Not needed (managed) |
| Schema Registry | Event Hubs Schema Registry |
| Kafka Streams | Azure Stream Analytics / Flink |

### Kafka Protocol Limitations on Event Hubs

| Feature | Event Hubs Support |
|---------|--------------------|
| Kafka Transactions | Not supported |
| Log Compaction | Not supported |
| Kafka Streams | Partial (use Azure Stream Analytics instead) |
| Kafka Connect | Supported |
| Exactly-once semantics | Not supported |
| Topic creation via Kafka API | Not supported (use Azure API) |

---

## 11. Schema Registry

> **Mental Model:** Schema Registry is the central dictionary for your event language. Producers write "Edition #5 of the dictionary" (schema v1.2). Consumers look up Edition #5 to understand the grammar. If the dictionary changes, old editions still work (schema evolution).

```
┌──────────────────────────────────────────────────────────────────┐
│                    SCHEMA REGISTRY FLOW                           │
│                                                                   │
│  Producer                                                         │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │ 1. Register schema (once): POST /schemagroups/orders/... │    │
│  │ 2. Serialize event with schema ID in header              │    │
│  │ 3. Publish to Event Hub                                  │    │
│  └──────────────────────────────────────────────────────────┘    │
│                           │                                       │
│                           ▼                                       │
│  Consumer                                                         │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │ 1. Read schema ID from event header                      │    │
│  │ 2. Fetch schema from registry (cached locally)           │    │
│  │ 3. Deserialize event body using schema                   │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                   │
│  WHY: Producers and consumers never need to share schema code.   │
│       Schema evolution (adding optional fields) handled by       │
│       compatibility rules (BACKWARD, FORWARD, FULL).             │
└──────────────────────────────────────────────────────────────────┘
```

### Schema Compatibility Modes

| Mode | Rule | Example |
|------|------|---------|
| **None** | No compatibility check | Dev/test only |
| **Backward** | New schema can read data written by old schema | Consumer upgraded first |
| **Forward** | Old schema can read data written by new schema | Producer upgraded first |
| **Full** | Both backward AND forward compatible | Safe rolling upgrades |

### Avro Schema Example

```json
// OrderCreated.avsc — Avro schema definition
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.mycompany.orders",
  "fields": [
    { "name": "orderId",    "type": "string" },
    { "name": "customerId", "type": "string" },
    { "name": "totalAmount","type": "double" },
    { "name": "createdAt",  "type": "long",  "logicalType": "timestamp-millis" },
    // WHY: New optional field with default = backward compatible
    { "name": "couponCode", "type": ["null", "string"], "default": null }
  ]
}
```

### C# — Schema Registry with Avro

```csharp
// ── NuGet: Microsoft.Azure.Data.SchemaRegistry.ApacheAvro ────────────
using Azure.Data.SchemaRegistry;
using Microsoft.Azure.Data.SchemaRegistry.ApacheAvro;

// WHY: SchemaRegistryAvroSerializer handles schema caching, versioning, and
// embedding schema ID in the event payload header automatically
var schemaRegistryClient = new SchemaRegistryClient(
    fullyQualifiedNamespace: "my-ns.servicebus.windows.net",
    credential: new DefaultAzureCredential());

var serializer = new SchemaRegistryAvroSerializer(
    client: schemaRegistryClient,
    groupName: "orders-schema-group",
    serializerOptions: new SchemaRegistryAvroSerializerOptions
    {
        AutoRegisterSchemas = true  // WHY: Register schema on first use (dev convenience)
                                    // Set false in production — schemas should be pre-registered
    });

// ── Producer with Schema Serialization ───────────────────────────────
var orderEvent = new OrderCreated
{
    orderId = Guid.NewGuid().ToString(),
    customerId = "cust-456",
    totalAmount = 199.99,
    createdAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
};

// WHY: Serializer adds schema ID to Content-Type header for consumers
var eventData = await serializer.SerializeAsync<EventData, OrderCreated>(orderEvent);
await producer.SendAsync(new[] { eventData });

// ── Consumer with Schema Deserialization ──────────────────────────────
// Schema ID is read from Content-Type header — no hardcoding
var order = await serializer.DeserializeAsync<OrderCreated>(eventArgs.Data);
```

---

## 12. Event Hubs Capture

> **Mental Model:** Capture is a security camera recording — it automatically archives your event stream to cheap storage (Blob/ADLS) in the background. You control when recording starts and how large each "tape" (file) gets.

```
┌──────────────────────────────────────────────────────────────────────┐
│                       EVENT HUBS CAPTURE                             │
│                                                                      │
│  Event Hub ──► Capture Engine ──► Azure Blob Storage                │
│                (runs inside Azure)   or Azure Data Lake Gen2        │
│                                                                      │
│  File format: Apache Avro (self-describing, compact binary)          │
│                                                                      │
│  File naming pattern:                                                │
│  {Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}    │
│  /{Minute}/{Second}.avro                                             │
│  e.g.: my-ns/orders/0/2025/04/01/14/30/00.avro                     │
│                                                                      │
│  Capture triggers (whichever comes first):                           │
│  - Time window: every X minutes (1-15 min)                          │
│  - Size window: every Y MB (10-500 MB)                              │
└──────────────────────────────────────────────────────────────────────┘
```

### Bicep — Enable Capture

```bicep
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  name: '${namespace.name}/orders'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 4
    captureDescription: {
      enabled: true
      // WHY: Avro is the only supported format — self-describing, compact
      encoding: 'Avro'
      intervalInSeconds: 300        // WHY: 5-minute capture windows
      sizeLimitInBytes: 314572800   // WHY: 300MB per file — balance file count vs size
      skipEmptyArchives: true       // WHY: Don't create empty files during idle periods
      destination: {
        name: 'EventHubArchive.AzureBlockBlob'
        properties: {
          storageAccountResourceId: storageAccount.id
          blobContainer: 'eventhub-archive'
          // WHY: Custom naming pattern for easy Hive/Spark partitioning
          archiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
        }
      }
    }
  }
}
```

### Reading Captured Avro Files

```csharp
// ── NuGet: Apache.Avro ────────────────────────────────────────────────
using Avro.File;
using Avro.Generic;

// WHY: Use Azure.Storage.Blobs to download Avro files from Capture container
var blobClient = containerClient.GetBlobClient(blobPath);
using var stream = await blobClient.OpenReadAsync();

// WHY: DataFileReader reads Avro format — header contains schema
using var reader = DataFileReader<GenericRecord>.OpenReader(stream);
while (reader.HasNext())
{
    var record = reader.Next();
    // Captured events have special Avro schema wrapping the original body
    var body = (byte[])record["Body"];
    var originalEvent = JsonSerializer.Deserialize<OrderCreatedEvent>(body);
    Console.WriteLine($"Captured order: {originalEvent.OrderId}");
}
```

---

## 13. Azure Functions Integration

> **Mental Model:** Azure Functions + Event Hubs = automatic assembly line workers. Functions scale out one instance per partition, each worker processes its lane at full speed.

### 13.1 Basic Event Hub Trigger

```csharp
// ── Single event processing ───────────────────────────────────────────
public class OrderEventFunction
{
    private readonly ILogger<OrderEventFunction> _logger;

    public OrderEventFunction(ILogger<OrderEventFunction> logger)
        => _logger = logger;

    [Function("ProcessOrderEvent")]
    public async Task Run(
        // WHY: Connection = name of the app setting containing the Event Hubs connection string
        // ConsumerGroup = specific group for this function (isolate from other consumers)
        [EventHubTrigger(
            eventHubName: "orders",
            Connection = "EventHub__ConnectionString",       // WHY: __ for nested config sections
            ConsumerGroup = "order-processor-cg",
            IsBatched = false)]                             // WHY: false = one event at a time
        EventData eventData,                                // full Event Hubs SDK type

        // WHY: PartitionContext gives partition metadata without SDK overhead
        PartitionContext partitionContext,
        FunctionContext context)
    {
        _logger.LogInformation(
            "Processing event: Partition={P}, Offset={O}, SeqNo={S}, EnqueuedTime={T}",
            partitionContext.PartitionId,
            eventData.Offset,
            eventData.SequenceNumber,
            eventData.EnqueuedTime);

        // Read custom properties
        if (eventData.Properties.TryGetValue("EventType", out var eventType))
            _logger.LogInformation("EventType: {Type}", eventType);

        // Deserialize body
        var order = eventData.EventBody.ToObjectFromJson<OrderCreatedEvent>();
        await ProcessOrderAsync(order);
    }
}
```

### 13.2 Batch Processing (High Throughput)

```csharp
// ── Batch trigger — process up to MaxBatchSize events per invocation ──
[Function("ProcessOrderEventsBatch")]
public async Task RunBatch(
    [EventHubTrigger(
        eventHubName: "orders",
        Connection = "EventHub__ConnectionString",
        ConsumerGroup = "batch-processor-cg",
        IsBatched = true)]              // WHY: IsBatched=true = array of events per invocation
    EventData[] events,                 // all events in the batch
    PartitionContext[] partitionContexts,
    FunctionContext context,
    CancellationToken cancellationToken)
{
    _logger.LogInformation("Processing batch of {Count} events", events.Length);

    // WHY: Process all events in the batch concurrently (they're independent)
    // Exception in one should not stop others — catch individually
    var tasks = events.Select(async (eventData, index) =>
    {
        try
        {
            var order = eventData.EventBody.ToObjectFromJson<OrderCreatedEvent>();
            await ProcessOrderAsync(order, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process event at index {I}, offset {O}",
                index, eventData.Offset);
            // Don't rethrow — let other events succeed
            // Write failed events to dead-letter storage for retry
            await WriteToDeadLetterAsync(eventData, ex);
        }
    });

    await Task.WhenAll(tasks);
}
```

### 13.3 host.json Tuning

```json
{
  "version": "2.0",
  "extensions": {
    "eventHubs": {
      "batchCheckpointFrequency": 5,
      // WHY: Checkpoint every 5 function invocations — balance durability vs perf

      "eventProcessorOptions": {
        "maxBatchSize": 64,
        // WHY: 64 events per invocation — match to processing throughput per instance

        "prefetchCount": 300,
        // WHY: Pre-fetch 300 events into memory — reduces round-trips to Event Hubs
        //      Higher = better throughput but more memory per instance

        "receiveTimeout": "00:01:00",
        // WHY: Wait up to 1 min for events before returning empty batch
        //      Prevents tight-loop cost when traffic is low

        "maxWaitTime": "00:00:30"
        // WHY: 30s max wait — triggers callback even if batch is not full
        //      Ensures latency SLA even under low volume
      }
    }
  }
}
```

### 13.4 Scaling Behavior

```
Event Hubs Trigger Scale:
  1 partition → max 1 concurrent function instance (per partition)
  
  If Event Hub has 4 partitions:
    Scale rule: max 4 instances (1 per partition)
    
  If traffic spikes:
    Instance 1 → handles partitions 0, 1 (if only 2 instances)
    Instance 2 → handles partitions 2, 3
    
    Scale to 4 instances:
    Instance 1 → partition 0
    Instance 2 → partition 1
    Instance 3 → partition 2
    Instance 4 → partition 3
    
WHY: NEVER have more function instances than partitions for the same consumer group.
     Extra instances sit idle — they can't steal partitions from active instances.
```

---

## 14. Stream Analytics Integration

> **Mental Model:** Stream Analytics is a SQL query engine running continuously over a river of events. Instead of batch queries against static tables, it runs windowed queries against the flowing stream.

```
┌────────────────────────────────────────────────────────────────────┐
│                   STREAM ANALYTICS JOB                             │
│                                                                    │
│  Input:  Event Hubs (orders stream)                               │
│  Query:  SQL-like, time-windowed aggregations                     │
│  Output: Blob, SQL, Power BI, Cosmos DB, Event Hubs, Service Bus  │
└────────────────────────────────────────────────────────────────────┘
```

### Stream Analytics Query Examples

```sql
-- ── Tumbling Window — count orders per minute per region ──────────────
SELECT
    System.Timestamp() AS WindowEnd,          -- WHY: Window close time
    region,
    COUNT(*) AS OrderCount,
    SUM(totalAmount) AS TotalRevenue,
    AVG(totalAmount) AS AvgOrderValue
INTO [sql-output]                              -- WHY: Write to Azure SQL
FROM [eventhub-orders] TIMESTAMP BY createdAt -- WHY: Use event time, not arrival time
GROUP BY
    region,
    TumblingWindow(minute, 1)                  -- WHY: Non-overlapping 1-minute buckets

-- ── Sliding Window — detect anomaly (order rate > 1000/min) ──────────
SELECT
    System.Timestamp() AS AlertTime,
    COUNT(*) AS OrderCount
INTO [alerts-output]
FROM [eventhub-orders]
GROUP BY SlidingWindow(minute, 1)              -- WHY: Overlapping window — fires on each event
HAVING COUNT(*) > 1000

-- ── Hopping Window — moving average over 5-min with 1-min hop ────────
SELECT
    System.Timestamp() AS WindowEnd,
    AVG(totalAmount) AS MovingAvg5Min
INTO [metrics-output]
FROM [eventhub-orders]
GROUP BY HoppingWindow(minute, 5, 1)           -- WHY: 5min window, slides every 1min

-- ── Pattern Detection — late payment alert ───────────────────────────
SELECT
    e1.orderId,
    e1.customerId,
    DATEDIFF(minute, e1.createdAt, System.Timestamp()) AS MinutesWithoutPayment
INTO [alert-output]
FROM [eventhub-orders] e1
WHERE NOT EXISTS (
    SELECT 1
    FROM [eventhub-payments] e2
    WHERE e1.orderId = e2.orderId
    AND DATEDIFF(minute, e1.createdAt, e2.paidAt) < 30
)
AND System.Timestamp() > DATEADD(minute, 30, e1.createdAt)
```

---

## 15. Security

### 15.1 Authentication Options

```
┌────────────────────────────────────────────────────────────────────┐
│              EVENT HUBS AUTHENTICATION                              │
├──────────────────────────────────────┬─────────────────────────────┤
│  Method                              │  When to Use                │
├──────────────────────────────────────┼─────────────────────────────┤
│  Connection String (SAS)             │  Dev/test, legacy apps      │
│  Shared Access Signature (SAS token) │  Third-party producers      │
│  Managed Identity (System-assigned)  │  Single Azure resource      │
│  Managed Identity (User-assigned)    │  Multiple resources sharing │
│  Workload Identity (AKS)             │  Kubernetes pods            │
│  App Registration (client cred.)     │  External apps, CI/CD       │
└──────────────────────────────────────┴─────────────────────────────┘
```

### 15.2 RBAC Roles

| Role | Permissions | Use For |
|------|-------------|---------|
| Azure Event Hubs Data Owner | Full control | Admin operations |
| Azure Event Hubs Data Sender | Send events only | Producers |
| Azure Event Hubs Data Receiver | Read events only | Consumers |

```csharp
// ── NuGet: Azure.ResourceManager.EventHubs + Azure.ResourceManager.Authorization
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.Authorization;
using Azure.ResourceManager.Authorization.Models;

// ── Assign "Azure Event Hubs Data Sender" role to a Managed Identity ─
var armClient = new ArmClient(new DefaultAzureCredential());

// Build the Event Hub resource ID (scope) — least privilege: hub level, not namespace
var eventHubResourceId = EventHubsEventHubResource.CreateResourceIdentifier(
    subscriptionId: subscriptionId,
    resourceGroupName: resourceGroupName,
    namespaceName: namespaceName,
    eventHubName: eventHubName);

var eventHubResource = armClient.GetEventHubsEventHubResource(eventHubResourceId);

// WHY: "Azure Event Hubs Data Sender" role definition GUID is fixed across all tenants
// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
const string dataSenderRoleId = "2b629674-e913-4c01-ae53-ef4638d8f975";

var roleAssignmentContent = new RoleAssignmentCreateOrUpdateContent(
    roleDefinitionId: new ResourceIdentifier(
        $"/subscriptions/{subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/{dataSenderRoleId}"),
    principalId: managedIdentityObjectId)  // Object ID of the Managed Identity
{
    PrincipalType = RoleManagementPrincipalType.ServicePrincipal  // WHY: Managed Identity is a service principal
};

// WHY: Role assignment name must be a deterministic GUID to be idempotent
var roleAssignmentName = Guid.NewGuid().ToString();
await eventHubResource.GetRoleAssignments()
    .CreateOrUpdateAsync(
        WaitUntil.Completed,
        roleAssignmentName,
        roleAssignmentContent);

Console.WriteLine($"Assigned 'Event Hubs Data Sender' to identity {managedIdentityObjectId} " +
                  $"on Event Hub '{eventHubName}' (scope: hub-level, least privilege)");
```

### 15.3 SAS Token (for Third-Party Producers)

```csharp
// ── Generate time-limited SAS token for a third party ────────────────
public static string GenerateSasToken(
    string resourceUri,
    string keyName,
    string key,
    TimeSpan validity)
{
    // WHY: Short validity (15min-1hr) limits blast radius if token is intercepted
    var expiry = DateTimeOffset.UtcNow.Add(validity).ToUnixTimeSeconds();
    var stringToSign = Uri.EscapeDataString(resourceUri) + "\n" + expiry;
    
    using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(key));
    var signature = Convert.ToBase64String(
        hmac.ComputeHash(Encoding.UTF8.GetBytes(stringToSign)));
    
    return $"SharedAccessSignature sr={Uri.EscapeDataString(resourceUri)}" +
           $"&sig={Uri.EscapeDataString(signature)}" +
           $"&se={expiry}" +
           $"&skn={keyName}";
}
```

### 15.4 Network Security

```bicep
// ── Restrict access to private network only ───────────────────────────
resource namespaceNetworkRules 'Microsoft.EventHub/namespaces/networkRuleSets@2023-01-01-preview' = {
  name: '${namespace.name}/default'
  properties: {
    // WHY: Deny public access by default — only allow explicit trusted sources
    defaultAction: 'Deny'
    publicNetworkAccess: 'Disabled'   // WHY: Force all traffic through Private Endpoint

    // Trusted Azure services that bypass network rules
    trustedServiceAccessEnabled: true  // WHY: Allows Azure Monitor, Azure Functions, etc.
                                        // to access Event Hubs even when public is disabled

    // Allow specific IP ranges (e.g., on-prem Kafka Connect)
    ipRules: [
      {
        action: 'Allow'
        ipMask: '203.0.113.0/24'  // WHY: On-prem network CIDR
      }
    ]

    // Allow specific VNets via Service Endpoints (alternative to Private Endpoint)
    virtualNetworkRules: [
      {
        subnet: { id: subnetId }
        ignoreMissingVnetServiceEndpoint: false
      }
    ]
  }
}
```

### 15.5 Encryption

```bicep
resource namespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  properties: {
    encryption: {
      keySource: 'Microsoft.KeyVault'  // WHY: Customer-Managed Key (CMK)
      keyVaultProperties: [
        {
          keyName: 'eventhubs-encryption-key'
          keyVaultUri: 'https://my-kv.vault.azure.net'
          // WHY: No keyVersion = always use latest key version (auto-rotation)
        }
      ]
      requireInfrastructureEncryption: true  // WHY: Double encryption (infra + CMK)
    }
  }
}
```

---

## 16. Monitoring, Metrics & KQL

### 16.1 Key Metrics to Monitor

```
┌────────────────────────────────────────────────────────────────────────┐
│                    CRITICAL EVENT HUBS METRICS                          │
├───────────────────────────────┬────────────────────────────────────────┤
│  Metric                        │  Alert Threshold & Reason              │
├───────────────────────────────┼────────────────────────────────────────┤
│  Incoming Bytes                │  > 80% of TU limit → scale up TUs     │
│  Outgoing Bytes                │  > 80% of TU limit → scale up TUs     │
│  Incoming Messages             │  Sudden drop → producer issue          │
│  Outgoing Messages             │  Sudden drop → consumer issue          │
│  Throttled Requests            │  > 0 → TUs exhausted, add more        │
│  Consumer Lag (per partition)  │  > threshold → consumer too slow       │
│  Active Connections            │  Near limit → connection leak          │
│  Errors                        │  > 0 → investigate type               │
│  Server Errors                 │  > 0 → Azure platform issue           │
│  User Errors                   │  > 0 → auth/quota/validation issue    │
└───────────────────────────────┴────────────────────────────────────────┘
```

### 16.2 KQL Queries for Event Hubs

```kql
// ── Throughput over time ──────────────────────────────────────────────
AzureMetrics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| where MetricName in ("IncomingBytes", "OutgoingBytes")
| summarize avg(Average) by bin(TimeGenerated, 5m), MetricName
| render timechart

// ── Throttled requests (TU exhaustion alert) ──────────────────────────
AzureMetrics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| where MetricName == "ThrottledRequests"
| where Total > 0
| summarize ThrottleCount = sum(Total) by bin(TimeGenerated, 1m), Resource
| where ThrottleCount > 0
| order by TimeGenerated desc

// ── Consumer lag by consumer group and partition ───────────────────────
// WHY: High lag = consumers can't keep up; investigate CPU/parallelism
AzureMetrics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| where MetricName == "ConsumerLag"
| extend Partition = tostring(split(ResourceId, "/")[10])
| summarize MaxLag = max(Maximum) by bin(TimeGenerated, 5m), Partition
| render timechart

// ── Error breakdown by type ───────────────────────────────────────────
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| where OperationName contains "Error"
| summarize Count = count() by OperationName, ResultDescription
| order by Count desc

// ── Active connections monitoring ─────────────────────────────────────
AzureMetrics
| where ResourceProvider == "MICROSOFT.EVENTHUB"
| where MetricName == "ActiveConnections"
| summarize AvgConnections = avg(Average), MaxConnections = max(Maximum)
    by bin(TimeGenerated, 5m), Resource
| render timechart
```

### 16.3 Custom Metrics from Consumer

```csharp
// ── Track consumer lag in Application Insights ───────────────────────
private readonly TelemetryClient _telemetry;

private async Task TrackConsumerLagAsync(
    ProcessEventArgs eventArgs, string consumerGroup)
{
    var partitionInfo = await _eventHubsClient
        .GetPartitionPropertiesAsync(eventArgs.Partition.PartitionId);

    // WHY: Lag = latest sequence number - current consumer sequence number
    var lag = partitionInfo.LastEnqueuedSequenceNumber -
              eventArgs.Data.SequenceNumber;

    // WHY: Custom metric enables alerting on consumer falling behind
    _telemetry.TrackMetric("EventHub.ConsumerLag", (double)lag,
        new Dictionary<string, string>
        {
            ["PartitionId"] = eventArgs.Partition.PartitionId,
            ["ConsumerGroup"] = consumerGroup,
            ["EventHubName"] = "orders"
        });
}
```

### 16.4 Diagnostic Settings

```bicep
// ── Enable diagnostic logs to Log Analytics ───────────────────────────
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'eventhubs-diagnostics'
  scope: namespace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      { category: 'ArchiveLogs';       enabled: true }   // Capture job logs
      { category: 'OperationalLogs';   enabled: true }   // Admin operations
      { category: 'AutoScaleLogs';     enabled: true }   // TU auto-inflate events
      { category: 'KafkaCoordinatorLogs'; enabled: true }// Kafka consumer group coord
      { category: 'EventHubVNetConnectionEvent'; enabled: true } // Network access
    ]
    metrics: [
      { category: 'AllMetrics'; enabled: true }
    ]
  }
}
```

---

## 17. Advanced Patterns

### 17.1 Fan-Out Pattern

```
One Event Hub → Multiple Consumer Groups → Different processors

                          ┌─► Analytics Consumer Group
                          │    (aggregates for reporting)
Event Hub (orders) ───────┼─► Fraud Detection Consumer Group
                          │    (real-time ML scoring)
                          ├─► Notification Consumer Group
                          │    (send order confirmation emails)
                          └─► Archive Consumer Group
                               (write to cold storage)

WHY: Each CG reads independently — analytics slowness does NOT affect
     fraud detection latency. Total data is read 4x but processed independently.
```

### 17.2 Event Replay Pattern

```csharp
// ── Replay events from a specific time (rebuild read model) ──────────
// Use case: New microservice needs historical data, or read model corrupted
public async Task ReplayEventsAsync(
    EventHubConsumerClient client,
    DateTimeOffset replayFrom,
    Func<EventData, Task> processor,
    CancellationToken ct)
{
    var properties = await client.GetEventHubPropertiesAsync(ct);

    // WHY: Process each partition independently for max throughput
    var replayTasks = properties.PartitionIds.Select(async partitionId =>
    {
        // WHY: FromEnqueuedTime lets us replay from a business-meaningful point
        var startPosition = EventPosition.FromEnqueuedTime(replayFrom);

        await foreach (var eventData in client.ReadEventsFromPartitionAsync(
            partitionId, startPosition, cancellationToken: ct))
        {
            await processor(eventData.Data);

            // WHY: Break when we reach "now" — caught up to real-time
            if (eventData.Data.EnqueuedTime >= DateTimeOffset.UtcNow.AddSeconds(-5))
                break;
        }
    });

    await Task.WhenAll(replayTasks);
}
```

### 17.3 Dead Letter Queue (Manual Implementation)

> Event Hubs has no native DLQ. Implement manually with Blob Storage.

```csharp
// ── Write poison messages to DLQ blob container ───────────────────────
public class EventHubsDeadLetterService
{
    private readonly BlobContainerClient _dlqContainer;

    public async Task SendToDeadLetterAsync(
        EventData eventData,
        Exception reason,
        string partitionId)
    {
        var dlqEntry = new
        {
            // WHY: Preserve all original event metadata for replay/debugging
            OriginalPartitionId = partitionId,
            OriginalOffset = eventData.Offset,
            OriginalSequenceNumber = eventData.SequenceNumber,
            OriginalEnqueuedTime = eventData.EnqueuedTime,
            OriginalProperties = eventData.Properties,
            Body = eventData.EventBody.ToString(),
            FailureReason = reason.GetType().Name,
            FailureMessage = reason.Message,
            FailureStackTrace = reason.StackTrace,
            DeadLetteredAt = DateTimeOffset.UtcNow
        };

        // WHY: Name includes partition and sequence for easy lookup
        var blobName = $"dlq/{partitionId}/{eventData.SequenceNumber:D20}.json";
        var content = BinaryData.FromObjectAsJson(dlqEntry);

        await _dlqContainer.UploadBlobAsync(blobName, content);
    }
}
```

### 17.4 Exactly-Once Processing (Idempotency Pattern)

> Event Hubs guarantees **at-least-once** delivery. Implement idempotency in your consumer.

```csharp
// ── Idempotent event processor using Redis deduplication ─────────────
public class IdempotentOrderProcessor
{
    private readonly IDatabase _redis;
    private readonly IOrderRepository _orders;

    public async Task<bool> ProcessAsync(EventData eventData, CancellationToken ct)
    {
        // WHY: Unique key = EventHub + Partition + SequenceNumber
        // This is globally unique per event across all replicas
        var idempotencyKey = $"processed:orders:{eventData.PartitionId}:{eventData.SequenceNumber}";

        // WHY: SET NX (set if not exists) + EX (expire after 7 days) is atomic
        // Returns true if set, false if already existed (duplicate)
        var isNew = await _redis.StringSetAsync(
            idempotencyKey,
            "1",
            expiry: TimeSpan.FromDays(7),    // WHY: Match Event Hubs retention period
            when: When.NotExists);            // WHY: Atomic NX prevents race condition

        if (!isNew)
        {
            // WHY: Log at Debug — duplicates are expected and harmless
            _logger.LogDebug("Duplicate event skipped: Partition={P}, SeqNo={S}",
                eventData.PartitionId, eventData.SequenceNumber);
            return false;  // Already processed
        }

        var order = eventData.EventBody.ToObjectFromJson<OrderCreatedEvent>();
        await _orders.CreateAsync(order, ct);
        return true;
    }
}
```

### 17.5 Aggregator Pattern (Stateful Event Processing)

```csharp
// ── In-memory aggregation with periodic flush ─────────────────────────
// Use case: Count events per tenant per minute without round-tripping DB for each event
public sealed class TenantEventAggregator
{
    private readonly ConcurrentDictionary<string, long> _counts = new();
    private readonly IMetricsRepository _metrics;
    private DateTimeOffset _windowStart = DateTimeOffset.UtcNow;

    public async Task AccumulateAsync(EventData eventData)
    {
        if (!eventData.Properties.TryGetValue("TenantId", out var tenantId))
            return;

        // WHY: Atomic increment — thread-safe across concurrent partition processing
        _counts.AddOrUpdate(tenantId.ToString()!, 1, (_, count) => count + 1);

        // WHY: Flush every minute — group by tumbling window
        if (DateTimeOffset.UtcNow - _windowStart > TimeSpan.FromMinutes(1))
            await FlushAsync();
    }

    private async Task FlushAsync()
    {
        var snapshot = _counts.ToDictionary(k => k.Key, v => v.Value);
        _counts.Clear();
        var windowEnd = DateTimeOffset.UtcNow;

        // WHY: Batch write all aggregations — single DB round-trip per window
        await _metrics.BulkInsertAsync(snapshot.Select(kvp =>
            new TenantMetric(kvp.Key, kvp.Value, _windowStart, windowEnd)));

        _windowStart = windowEnd;
    }
}
```

### 17.6 Change Data Capture (CDC) via Event Hubs

```csharp
// ── SQL Server CDC → Event Hubs (using Debezium or custom) ───────────
// Pattern: Capture every DB change and publish to Event Hubs
// WHY: Enables event sourcing on existing SQL databases without modifying the app

// With Azure SQL: Use Azure SQL Change Feed or SQL Server CDC + custom publisher
// With Azure Cosmos DB: Built-in Change Feed → Event Hubs binding in Azure Functions

[Function("CosmosDbCdcToEventHubs")]
[EventHubOutput("cdc-stream", Connection = "EventHub__ConnectionString")]
public static async Task<string[]> Run(
    [CosmosDBTrigger(
        databaseName: "mydb",
        containerName: "orders",
        Connection = "CosmosDB__ConnectionString",
        LeaseContainerName = "leases",
        CreateLeaseContainerIfNotExists = true)]
    IReadOnlyList<JsonDocument> documents)
{
    // WHY: Transform CosmosDB change feed items to Event Hubs events
    return documents
        .Select(doc => doc.RootElement.GetRawText())
        .ToArray();  // WHY: Return array → sent as batch to Event Hubs output binding
}
```

---

## 18. Geo-Replication & Disaster Recovery

### 18.1 Geo-Disaster Recovery (Metadata-Only)

```
┌─────────────────────────────────────────────────────────────────────┐
│             GEO-DISASTER RECOVERY (Standard / Premium)              │
│                                                                     │
│  Primary Namespace     ←─── Metadata alias ───►  Secondary Namespace│
│  (East US — Active)          (read-only           (West US — Passive)│
│                               DNS alias)                            │
│                                                                     │
│  Events are NOT replicated — only namespace config (entities,       │
│  consumer groups, auth rules) is synced.                            │
│                                                                     │
│  On failover:                                                        │
│  1. Promote Secondary → Primary                                     │
│  2. Alias DNS switches to secondary in < 1 minute                   │
│  3. All clients using alias reconnect automatically                 │
│                                                                     │
│  Data loss: Events not yet consumed on Primary ARE LOST             │
│  WHY: Metadata-only DR is fast but not zero-RPO                     │
└─────────────────────────────────────────────────────────────────────┘
```

```csharp
// ── Initiate failover (Azure SDK) ─────────────────────────────────────
var client = new EventHubsManagementClient(credential);

// WHY: Manual failover (you control timing) vs forced (auto)
await client.DisasterRecoveryConfigs.FailOverAsync(
    resourceGroupName: "my-rg",
    namespaceName: "my-ns-primary",
    alias: "my-eh-alias");

// Clients using alias need no code change after failover
// Connection string: Endpoint=sb://my-eh-alias.servicebus.windows.net/;...
```

### 18.2 Geo-Replication (Premium — Data Replication)

```
┌─────────────────────────────────────────────────────────────────────┐
│              GEO-REPLICATION (Premium — Preview)                    │
│                                                                     │
│  Region A (Primary)         Region B (Secondary)                    │
│  ┌─────────────────┐        ┌─────────────────┐                    │
│  │  Event Hub      │──────► │  Event Hub      │  Events replicated  │
│  │  (read/write)   │  async │  (read/write)   │  asynchronously    │
│  └─────────────────┘        └─────────────────┘                    │
│                                                                     │
│  RPO: Near-zero (seconds)      RTO: Near-zero (auto-failover)      │
│  WHY: Unlike metadata-only DR, actual event data is replicated      │
└─────────────────────────────────────────────────────────────────────┘
```

### 18.3 Active-Active Multi-Region Pattern

```csharp
// ── Active-Active: publish to both regions, consume from nearest ──────
// WHY: No single point of failure; consumers always get events even if one region fails
public class MultiRegionEventHubProducer
{
    private readonly EventHubProducerClient _primaryProducer;
    private readonly EventHubProducerClient _secondaryProducer;

    public async Task SendAsync(EventData eventData, CancellationToken ct)
    {
        // WHY: Add replication marker to prevent infinite re-processing
        // when consumers in Region B also publish to the other region
        eventData.Properties["OriginRegion"] = "eastus";
        eventData.Properties["ReplicationId"] = Guid.NewGuid().ToString();

        using var batch1 = await _primaryProducer.CreateBatchAsync(ct);
        using var batch2 = await _secondaryProducer.CreateBatchAsync(ct);
        batch1.TryAdd(eventData);
        batch2.TryAdd(eventData);

        // WHY: Send to both regions in parallel — total latency = max(region1, region2)
        await Task.WhenAll(
            _primaryProducer.SendAsync(batch1, ct),
            _secondaryProducer.SendAsync(batch2, ct));
    }
}
```

---

## 19. Performance & Scaling

### 19.1 Throughput Limits

```
Standard Namespace:
  1 TU = 1 MB/s ingress (publish) = 2 MB/s egress (consume)
  1 TU = 1,000 events/sec ingress

  With Auto-inflate (auto-scale TUs):
  ┌────────────────────────────────────────────────────────┐
  │  Traffic spikes → TUs auto-increase (up to max you set)│
  │  WHY: TUs never auto-decrease — set max carefully       │
  │  Cost: Each TU = ~$0.03/hour regardless of usage       │
  └────────────────────────────────────────────────────────┘

Premium Namespace:
  1 PU = ~10x TU equivalent
  Scale up/down dynamically
  Better choice for predictable high throughput
```

### 19.2 Producer Performance Tuning

```csharp
// ── High-throughput producer configuration ────────────────────────────
var producerOptions = new EventHubProducerClientOptions
{
    RetryOptions = new EventHubsRetryOptions
    {
        Mode = EventHubsRetryMode.Exponential,
        MaximumRetries = 3,
        Delay = TimeSpan.FromMilliseconds(250),
        MaximumDelay = TimeSpan.FromSeconds(10)
    },
    ConnectionOptions = new EventHubConnectionOptions
    {
        // WHY: AMQP is more efficient than HTTPS for high-throughput scenarios
        // HTTPS adds HTTP overhead per request; AMQP is persistent connection
        TransportType = EventHubsTransportType.AmqpTcp  // Default; prefer over AmqpWebSockets
    }
};

// Performance tips:
// 1. ALWAYS use EventDataBatch (never send events one-by-one)
// 2. Fill batches as close to 1MB as possible before sending
// 3. Use multiple producers (one per partition) for very high throughput
// 4. Use AMQP over TCP (not WebSockets) unless firewall requires port 443
// 5. Reuse producers — don't create per-request (AMQP connections are expensive)
// 6. Consider compression for large text payloads (gzip before creating EventData)
```

### 19.3 Consumer Performance Tuning

```
Consumer throughput formula:
  Throughput = (Partitions) × (Processing speed per partition)
  
To increase throughput:
  Option 1: Add more partitions (increase parallelism ceiling)
            - Requires Event Hub recreation (partition count is immutable in Standard)
            - Can increase in Premium
  
  Option 2: Optimize per-partition processing
            - Batch processing (IsBatched=true in Azure Functions)
            - Async I/O (never block thread pool threads)
            - Reduce DB round-trips (batch inserts instead of one-by-one)
  
  Option 3: Parallel processing within a partition
            - Only if your use case allows reordering within a partition
            - Use SemaphoreSlim to control parallelism
```

```csharp
// ── Parallel processing within partition (if ordering not required) ───
private async Task ProcessEventHandler(ProcessEventArgs eventArgs)
{
    if (!eventArgs.HasEvent) return;

    var order = eventArgs.Data.EventBody.ToObjectFromJson<OrderCreatedEvent>();

    // WHY: If business logic allows, process sub-tasks in parallel
    // e.g., Send email AND update inventory AND notify warehouse simultaneously
    await Task.WhenAll(
        _emailService.SendOrderConfirmationAsync(order),
        _inventoryService.ReserveStockAsync(order),
        _warehouseService.CreatePicklistAsync(order));

    await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
}
```

### 19.4 Connection Management

```csharp
// ── Singleton producers/consumers via DI (CRITICAL) ───────────────────
// WHY: EventHubProducerClient maintains an AMQP connection pool
//      Creating per-request wastes connections and causes port exhaustion
builder.Services.AddSingleton<EventHubProducerClient>(sp =>
    new EventHubProducerClient(
        fullyQualifiedNamespace: configuration["EventHub:Namespace"],
        eventHubName: configuration["EventHub:OrdersHub"],
        credential: new DefaultAzureCredential()));

// WHY: EventHubConsumerClient for browsing/exploring (NOT for production consumption)
// For production, use EventProcessorClient (registered similarly as Singleton)
```

---

## 20. Provisioning with Bicep & Terraform

### 20.1 Bicep — Complete Namespace + Event Hub

```bicep
// ── Event Hubs Namespace ──────────────────────────────────────────────
@description('Environment name (dev, staging, prod)')
param envName string

@description('Azure region')
param location string = resourceGroup().location

// WHY: Premium provides isolated infra, Private Endpoints, longer retention
@allowed(['Standard', 'Premium'])
param tier string = 'Standard'

param throughputUnits int = 2  // WHY: Start conservative; enable auto-inflate for Standard

resource namespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: 'evhns-${envName}-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: tier
    tier: tier
    capacity: throughputUnits
  }
  properties: {
    isAutoInflateEnabled: tier == 'Standard'      // WHY: Auto-scale TUs (Standard only)
    maximumThroughputUnits: tier == 'Standard' ? 20 : null
    kafkaEnabled: true                             // WHY: Enable Kafka protocol for compatibility
    minimumTlsVersion: '1.2'                      // WHY: Never allow TLS < 1.2
    publicNetworkAccess: 'Disabled'                // WHY: All traffic via Private Endpoint
    disableLocalAuth: true                         // WHY: Force Entra ID; ban SAS keys
    zoneRedundant: true                            // WHY: Survive AZ failure (Premium auto-enables)
  }
}

// ── Event Hub (orders) ────────────────────────────────────────────────
resource ordersHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: namespace
  name: 'orders'
  properties: {
    partitionCount: 8              // WHY: 8 partitions = up to 8 concurrent consumer instances
    messageRetentionInDays: 7      // WHY: 7 days matches Standard max (use Premium for 90 days)
    captureDescription: {
      enabled: true
      encoding: 'Avro'
      intervalInSeconds: 300       // WHY: 5-min capture windows
      sizeLimitInBytes: 314572800  // WHY: 300MB per file
      skipEmptyArchives: true
      destination: {
        name: 'EventHubArchive.AzureBlockBlob'
        properties: {
          storageAccountResourceId: storageAccount.id
          blobContainer: 'eh-capture'
          archiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
        }
      }
    }
  }
}

// ── Consumer Groups ────────────────────────────────────────────────────
resource analyticsConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
  parent: ordersHub
  name: 'analytics-cg'            // WHY: Dedicated CG per consumer — isolation
}

resource fraudDetectionConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2023-01-01-preview' = {
  parent: ordersHub
  name: 'fraud-detection-cg'
}

// ── RBAC Assignment ────────────────────────────────────────────────────
resource senderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(namespace.id, processingApp.id, 'sender')
  scope: ordersHub                 // WHY: Scope to Event Hub, not namespace (least privilege)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',
      '2b629674-e913-4c01-ae53-ef4638d8f975') // Azure Event Hubs Data Sender
    principalId: processingApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output namespaceFqdn string = '${namespace.name}.servicebus.windows.net'
output ordersHubName string = ordersHub.name
```

### 20.2 Terraform — Event Hubs

```hcl
# ── Event Hubs Namespace ──────────────────────────────────────────────
resource "azurerm_eventhub_namespace" "main" {
  name                     = "evhns-${var.env}-${random_id.suffix.hex}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = "Standard"
  capacity                 = 2             # WHY: TU count; enables auto_inflate to handle spikes
  auto_inflate_enabled     = true
  maximum_throughput_units = 20
  kafka_enabled            = true          # WHY: Kafka protocol compatibility

  network_rulesets {
    default_action                 = "Deny"  # WHY: Deny-by-default; allow explicitly
    trusted_service_access_enabled = true    # WHY: Allow Azure Monitor/Functions bypass
    
    virtual_network_rule {
      subnet_id = var.app_subnet_id
    }
  }

  tags = var.common_tags
}

# ── Event Hub ─────────────────────────────────────────────────────────
resource "azurerm_eventhub" "orders" {
  name                = "orders"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = 8     # WHY: Fixed at creation — choose based on expected parallelism
  message_retention   = 7     # WHY: Standard max is 7 days

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300
    size_limit_in_bytes = 314572800
    skip_empty_archives = true

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = azurerm_storage_container.capture.name
      storage_account_id  = azurerm_storage_account.main.id
    }
  }
}

# ── Consumer Groups ───────────────────────────────────────────────────
resource "azurerm_eventhub_consumer_group" "analytics" {
  name                = "analytics-cg"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.orders.name
  resource_group_name = var.resource_group_name
}

# ── RBAC ──────────────────────────────────────────────────────────────
resource "azurerm_role_assignment" "sender" {
  scope                = azurerm_eventhub.orders.id   # WHY: Least privilege — hub not namespace
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = var.producer_identity_object_id
}
```

---

## 21. Event Hubs vs Alternatives

### Full Comparison

```
┌──────────────────────────────────────────────────────────────────────────────┐
│              EVENT HUBS vs SERVICE BUS vs EVENT GRID vs KAFKA                 │
├──────────────────┬──────────────┬─────────────┬────────────────┬─────────────┤
│ Feature          │ Event Hubs   │ Service Bus │ Event Grid     │ Kafka       │
├──────────────────┼──────────────┼─────────────┼────────────────┼─────────────┤
│ Model            │ Pull/Stream  │ Pull/Push   │ Push           │ Pull/Stream │
│ Purpose          │ Streaming    │ Messaging   │ Event routing  │ Streaming   │
│ Ordering         │ Per partition│ Per session │ No guarantee   │ Per partition│
│ Retention        │ Hours-90days │ Up to 14d   │ 24h retry      │ Configurable│
│ Max Msg Size     │ 1 MB         │ 100 MB (Prem)│ 1 MB          │ 1 MB default│
│ Replay           │ Yes          │ No          │ No             │ Yes         │
│ Throughput       │ Very High    │ High        │ Very High      │ Very High   │
│ Dead Letter      │ Manual       │ Built-in    │ Blob (manual)  │ Manual      │
│ Kafka Compat     │ Yes          │ No          │ No             │ Native      │
│ Managed          │ Fully        │ Fully       │ Fully          │ Self-managed│
│ Schema Registry  │ Yes (Prem)   │ No          │ No             │ Confluent SR│
│ Protocol         │ AMQP/Kafka   │ AMQP/HTTP   │ HTTP/Webhooks  │ Kafka       │
│ Transactions     │ No           │ Yes         │ No             │ Yes         │
│ Sessions         │ No           │ Yes         │ No             │ No (native) │
│ Use When         │ Telemetry,   │ Commands,   │ React to Azure │ Large-scale │
│                  │ Streaming,   │ Workflows,  │ resource events│ event log   │
│                  │ Log agg.     │ Ordered msgs│                │ on-prem     │
└──────────────────┴──────────────┴─────────────┴────────────────┴─────────────┘
```

### Decision Tree

```
Need to ingest high-volume events (IoT, telemetry, clickstream)?
└──► Azure Event Hubs

Need reliable, guaranteed delivery for business messages?
└──► Azure Service Bus

Need to react to Azure resource state changes (blob created, VM deleted)?
└──► Azure Event Grid

Already running Apache Kafka on-prem?
├──► Migrate to Azure Event Hubs (Kafka protocol) — managed, no ops
└──► Keep Kafka if you need: transactions, compaction, Kafka-native tooling

Need ordering guarantees across ALL events (not just per entity)?
└──► Azure Service Bus (Sessions)
     OR
     Event Hubs with single partition (bottleneck — not recommended at scale)
```

---

## 22. Production Checklist

### Infrastructure

- [ ] **Tier:** Standard for ≤40 TU; Premium for high throughput, Private Endpoint, 90-day retention
- [ ] **Partitions:** Set based on peak parallelism + expected throughput; cannot reduce
- [ ] **Retention:** Minimum 7 days for debugging; 90 days if replay/DR needed (Premium)
- [ ] **Auto-inflate enabled** (Standard) with sensible maximum TU limit
- [ ] **Zone redundancy enabled** (automatic in Premium)
- [ ] **Geo-DR configured** for mission-critical workloads
- [ ] **Capture enabled** for audit/compliance/cold storage requirements

### Security

- [ ] **Public network access disabled** — all traffic via Private Endpoint
- [ ] **Local auth disabled** (`disableLocalAuth: true`) — force Entra ID, ban SAS keys
- [ ] **Managed Identity / Workload Identity** for all producers and consumers
- [ ] **RBAC scoped to Event Hub** (not namespace) — Data Sender / Data Receiver roles
- [ ] **TLS minimum version 1.2** enforced
- [ ] **Customer-Managed Key** for encryption at rest (compliance requirement)
- [ ] **Diagnostic settings** → Log Analytics for all log categories

### Consumer Configuration

- [ ] **Dedicated consumer group** per logical consumer (never share `$Default`)
- [ ] **EventProcessorClient** used (not raw PartitionReceiver) for production
- [ ] **Blob checkpoint store** configured with appropriate storage redundancy (ZRS)
- [ ] **Checkpointing strategy** defined (every N events or every T seconds)
- [ ] **Idempotent event handlers** — at-least-once delivery means duplicates are possible
- [ ] **Dead letter** mechanism for poison messages (Blob-based DLQ)
- [ ] **Consumer lag monitored** with alerts (lag > threshold → consumer falling behind)
- [ ] **Graceful shutdown** handled (StopProcessingAsync in hosted service)

### Producer Configuration

- [ ] **Singleton producers** (one per Event Hub per process — don't create per-request)
- [ ] **EventDataBatch** always used (never single-event sends)
- [ ] **Retry policy** configured with exponential backoff
- [ ] **Partition key strategy** documented and tested for even distribution
- [ ] **AMQP over TCP** (not WebSockets) unless firewall requires port 443

### Operational

- [ ] **Consumer lag alert**: lag > X for > Y minutes → PagerDuty/email
- [ ] **Throttled requests alert**: any throttling → TU limit reached
- [ ] **Error rate alert**: user errors / server errors > threshold
- [ ] **Runbook**: what to do when consumer lag spikes
- [ ] **Runbook**: what to do when TU throttling occurs
- [ ] **Load test** run at 2x expected peak throughput
- [ ] **Chaos test**: kill consumer instance — verify rebalancing works

---

## 23. Interview Q&A

**Q1: Explain the difference between a partition, an offset, and a sequence number.**

> **Partition:** An independent, ordered, append-only log segment. Event Hubs distributes events across N partitions. Events within a partition are always ordered. Events across partitions have no ordering guarantee.
>
> **Sequence Number:** A monotonically increasing integer assigned by Event Hubs to each event within a partition. Always increases by 1. Used for ordered replay.
>
> **Offset:** The byte position of an event within a partition's storage stream. Not continuous integers (byte positions vary by event size). Used by the consumer to seek to a specific position. Both can be used to resume consumption.

---

**Q2: Why can't you have more consumer instances than partitions?**

> Each partition within a consumer group can only be owned by one consumer instance at a time (enforced by lease management in `EventProcessorClient`). If you have 4 partitions and 8 instances, 4 instances own one partition each; the other 4 sit idle waiting for a lease. They don't split a partition — they can't read the same partition simultaneously without coordination. Extra instances provide failover capacity (they steal leases from dead instances) but don't add processing throughput.

---

**Q3: How do you guarantee ordering in Event Hubs?**

> Ordering is guaranteed **within a partition**. To guarantee that related events (e.g., all events for a customer) are ordered relative to each other:
> 1. Use a **partition key** (e.g., `customerId`) — all events with the same key always land on the same partition
> 2. Ensure your consumer processes events from that partition sequentially (don't parallelize within a partition if ordering matters)
>
> You **cannot** guarantee ordering across partitions. If you need global ordering, use **Azure Service Bus with Sessions** instead — but accept the throughput penalty.

---

**Q4: What is consumer lag and how do you monitor it?**

> Consumer lag = the difference between the latest event sequence number on a partition and the consumer's current checkpoint sequence number. It measures how far behind a consumer is.
>
> High lag means: consumer is slower than the producer rate. Causes: underpowered compute, slow DB writes, synchronous I/O blocking threads, insufficient parallelism.
>
> Monitor via: Azure Monitor metric `ConsumerLag`, custom Application Insights metrics in your consumer, or tools like `kafka-consumer-groups.sh --describe` (Kafka protocol). Alert when lag > SLO threshold for > N minutes.

---

**Q5: How does Event Hubs handle a consumer crash mid-processing?**

> When using `EventProcessorClient`:
> 1. Crashed instance stops renewing its partition leases
> 2. After `PartitionOwnershipExpirationInterval` (default 60s), lease expires
> 3. Another living instance detects expired leases during load balancing
> 4. Living instance claims the orphaned partitions
> 5. Resumes from the **last checkpoint** (not where crash happened)
> 6. Events between last checkpoint and crash point are **reprocessed** (at-least-once)
>
> This is why idempotent event handlers are non-negotiable. The system auto-recovers with no human intervention.

---

**Q6: What happens if you don't checkpoint?**

> If you never call `UpdateCheckpointAsync`, the checkpoint store retains the default starting position (usually `EventPosition.Latest` for first run). On restart, the processor starts from `Latest` — skipping all events that arrived while it was running. You lose all those events from your consumer's perspective (they're still in the Event Hub, but your consumer missed them). Always checkpoint, even if you choose a batched/periodic strategy.

---

**Q7: Explain the Capture feature. When would you use it?**

> Capture automatically archives all events from an Event Hub to Azure Blob Storage or Azure Data Lake Gen2 in Apache Avro format. Configured with a time window (1-15 min) and size window (10-500 MB) — whichever triggers first creates a new Avro file.
>
> Use cases:
> - **Compliance/audit:** Retain raw events beyond Event Hubs' 90-day limit
> - **Cold analytics:** Batch processing with Spark, Synapse, or Hive on Avro files
> - **Data lake ingestion:** Part of a Lambda/Kappa architecture (speed + batch layer)
> - **Disaster recovery:** Secondary read of events if consumer falls behind catastrophically
>
> WHY Avro: Self-describing (schema embedded in file header), compact binary format, supported by all major analytics platforms.

---

**Q8: How does the Kafka endpoint differ from native Event Hubs SDK?**

> The Kafka endpoint is an **AMQP-to-Kafka translation layer** that Event Hubs exposes. Your Kafka client sends Kafka wire protocol on port 9093; Azure translates it to Event Hubs internally.
>
> Limitations compared to native SDK:
> - No Kafka Transactions (no exactly-once)
> - No Log Compaction
> - No Kafka Streams (use Stream Analytics)
> - Topic management (partition count changes) must be done via Azure API, not Kafka API
> - `$ConnectionString` is the Kafka username — unusual but required
>
> Benefits: Migrate existing Kafka apps to Azure without code changes; get managed infrastructure.

---

**Q9: How would you implement exactly-once processing on top of at-least-once delivery?**

> Event Hubs guarantees at-least-once delivery (duplicate events possible if consumer crashes before checkpointing). Achieve exactly-once processing via **idempotent consumers**:
>
> 1. **Deduplication store:** Redis `SET NX` with key = `{namespace}:{hub}:{partition}:{sequenceNumber}` and TTL = retention period. If key already exists, skip processing.
> 2. **Database constraint:** Natural deduplication via UNIQUE constraint on `EventId` in SQL. INSERT with IGNORE or ON CONFLICT DO NOTHING.
> 3. **Idempotent business logic:** "Set status to PAID" instead of "increment payment count."
> 4. **Outbox + Transaction:** DB write + deduplication check in the same transaction.
>
> The right approach depends on your throughput requirements and what your downstream systems support.

---

**Q10: You have a hot partition issue. One partition is receiving 95% of events. How do you fix it?**

> 1. **Diagnose:** Check `IncomingMessages` and `IncomingBytes` metrics per partition in Azure Monitor. Confirm the skew.
> 2. **Root cause:** Low-cardinality or skewed partition key (e.g., `countryCode` where 95% is "US").
> 3. **Fix Options:**
>    - **Increase cardinality:** Change key to `customerId` (high cardinality, even distribution)
>    - **Composite key:** `US-{randomSuffix}` to spread US events across multiple partitions (lose strict ordering per country, gain distribution)
>    - **Remove partition key:** Let Event Hubs round-robin (lose ordering, gain even distribution)
>    - **Sub-partition at application layer:** Route US events to a second Event Hub with its own partitions
> 4. **Prevention:** Load-test partition distribution before production; monitor `IncomingMessages` per partition.

---

**Q11: What is the difference between EventPosition.Earliest, EventPosition.Latest, and a checkpoint?**

> - **Earliest:** Start reading from the very first event ever stored in the partition (subject to retention period). Use for: initial replay, rebuilding a read model from scratch.
> - **Latest:** Start reading only events that arrive AFTER this consumer subscribes. All historical events are skipped. Use for: real-time processing where history doesn't matter.
> - **Checkpoint:** Resume from exactly where the consumer last saved its position. This is the normal operational mode. No events are skipped; no unnecessary replay. Use for: all production consumers using `EventProcessorClient`.

---

**Q12: How would you design a telemetry pipeline that ingests 5 million IoT device events per second?**

> 1. **Ingestion:** Event Hubs Premium with 256 partitions (Premium supports up to 2048), Kafka protocol for device SDKs. Each device uses `deviceId` as partition key.
> 2. **Processing:** Azure Stream Analytics (ASA) for real-time windowed aggregations (alert if device temp > threshold). Scale ASA Streaming Units.
> 3. **Hot path:** ASA → Cosmos DB (last known state per device, ~ms latency reads)
> 4. **Cold path:** Event Hubs Capture → Azure Data Lake Gen2 in Avro format → Synapse Analytics for historical analysis.
> 5. **Schema:** Schema Registry with Avro — compact binary format reduces bandwidth 60-70% vs JSON.
> 6. **Monitoring:** Consumer lag alerts, TU/PU utilization alerts, Stream Analytics watermark delay alerts.
> 7. **Geo-redundancy:** Premium geo-replication (active-active). Devices publish to nearest region.

---

**Q13: What RBAC roles are required for a producer-only app vs a consumer-only app?**

> - **Producer:** `Azure Event Hubs Data Sender` — can only send events. Cannot read. Scope to the specific Event Hub (not namespace) for least privilege.
> - **Consumer:** `Azure Event Hubs Data Receiver` — can only read events. Cannot send.
> - **Both:** `Azure Event Hubs Data Owner` — full access. Avoid for app identities; use only for admin/management.
>
> Always use **Managed Identity** (system or user-assigned) rather than SAS connection strings. Disable local auth (`disableLocalAuth: true`) at the namespace level to prevent any SAS-based access.

---

**Q14: Explain the lease/ownership mechanism in EventProcessorClient.**

> `EventProcessorClient` uses a **Blob Storage-based distributed lease** to coordinate multiple instances:
>
> 1. Each instance tries to claim partitions by writing a blob (e.g., `partition-0.json`) with its instance ID and a lease expiry timestamp.
> 2. The blob update uses **Azure Blob Storage optimistic concurrency** (ETag) — only one instance can write at a time.
> 3. Each claimed instance renews its lease periodically (every ~`PartitionOwnershipExpirationInterval / 3`).
> 4. If an instance fails, its lease expires. Other instances detect this during their load-balancing cycle and claim the orphaned partitions.
> 5. Load balancing redistributes partitions evenly across all living instances every `LoadBalancingUpdateInterval`.
>
> This is the same mechanism Kafka uses with Zookeeper for consumer group coordination, but implemented entirely on Azure Blob Storage.

---

**Q15: How do you test Event Hubs consumers locally without Azure?**

> Options:
> 1. **Azure Event Hubs emulator** (official Docker container): `docker run -p 5672:5672 mcr.microsoft.com/azure-messaging/eventhubs-emulator:latest`. Fully compatible with the Azure SDK.
> 2. **Testcontainers + Azurite** (for checkpoint Blob): Use `TestcontainersBuilder` with the emulator image. Clean integration tests.
> 3. **Interface abstraction:** Abstract event processing behind `IEventProcessor` interface. Unit test the processor logic with xUnit + Moq; the Event Hubs trigger wiring is excluded.
> 4. **Azure Standard namespace** with dev-tier resources: Create a dedicated `dev` namespace. Cheaper than Premium; sufficient for testing.

---

*End of Azure Event Hubs Complete Guide*
*Coverage: 23 sections · Beginner → Expert · C# producer/consumer · Kafka protocol · Schema Registry · Capture · Azure Functions · Stream Analytics · Security · Monitoring (KQL) · Advanced patterns · Bicep/Terraform · 15 Interview Q&As*
