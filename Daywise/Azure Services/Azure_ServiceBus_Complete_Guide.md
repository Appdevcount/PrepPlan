# Azure Service Bus - Complete Comprehensive Guide

## Table of Contents

1. [Introduction & Overview](#introduction--overview)
2. [Core Concepts & Architecture](#core-concepts--architecture)
3. [When to Use Service Bus](#when-to-use-service-bus)
4. [Service Bus vs Other Messaging Services](#service-bus-vs-other-messaging-services)
5. [Queues - Deep Dive](#queues---deep-dive)
6. [Topics & Subscriptions - Deep Dive](#topics--subscriptions---deep-dive)
7. [Message Properties & Metadata](#message-properties--metadata)
8. [Sessions & FIFO Processing](#sessions--fifo-processing)
9. [Dead-Letter Queues](#dead-letter-queues)
10. [Message Deferral & Scheduling](#message-deferral--scheduling)
11. [Transactions & Batching](#transactions--batching)
12. [Security & Authentication](#security--authentication)
13. [Code Implementation - C# .NET](#code-implementation---c-net)
14. [Code Implementation - Python](#code-implementation---python)
15. [Code Implementation - JavaScript/Node.js](#code-implementation---javascriptnodejs)
16. [Advanced Patterns](#advanced-patterns)
17. [Integration with Azure Functions](#integration-with-azure-functions)
18. [Monitoring & Diagnostics](#monitoring--diagnostics)
19. [Performance Optimization](#performance-optimization)
20. [High Availability & Disaster Recovery](#high-availability--disaster-recovery)
21. [Pricing & Cost Optimization](#pricing--cost-optimization)
22. [Real-World Scenarios](#real-world-scenarios)
23. [Best Practices](#best-practices)
24. [Troubleshooting Guide](#troubleshooting-guide)
25. [Migration Strategies](#migration-strategies)

---

## Mind Map — Azure Service Bus (Quick Recall)

> Mental Model: Service Bus = **Enterprise Post Office**. Namespace = building, Queue = private mailbox (one recipient), Topic = public bulletin board (many readers), Subscription = personal filter on that board, Session = ordered envelope bundle per sender.

```
AZURE SERVICE BUS
│
├── WHAT IT IS
│   ├── Fully managed enterprise message broker
│   ├── Guaranteed delivery (at-least-once / at-most-once)
│   ├── Persistent (replicated 3× per region)
│   └── FQDN: <namespace>.servicebus.windows.net
│
├── TIERS
│   ├── Basic   → Queues only, 256 KB, no Topics/Sessions/Transactions
│   ├── Standard→ Topics, Sessions, Transactions, Duplicate Detection, 256 KB
│   └── Premium → + VNET, Geo-DR, AZ, dedicated, 1 MB (100 MB large msgs), $682/mo base
│
├── MESSAGING PATTERNS
│   ├── Point-to-Point     → Queue  (competing consumers)
│   ├── Publish-Subscribe  → Topic + Subscriptions (fan-out)
│   ├── Request-Reply      → ReplyTo + CorrelationId
│   └── Session-Based      → FIFO ordered per session group
│
├── CORE COMPONENTS
│   ├── Namespace  → Container / billing unit / FQDN
│   ├── Queue      → FIFO store, single active consumer per msg
│   ├── Topic      → Distribution hub → many subscriptions
│   ├── Subscription → Virtual queue under topic + filter rule
│   └── Message    → Body (bytes) + System props + App props
│
├── MESSAGE LIFECYCLE
│   ├── Active      → Available to receive
│   ├── Locked      → Received, lock timer running (default 60s)
│   ├── Completed   → Deleted (success)
│   ├── Abandoned   → Returned, DeliveryCount++
│   ├── Dead-Letter → Moved to DLQ (poison / expired / max retries)
│   ├── Deferred    → Set aside; retrieve by SequenceNumber
│   └── Scheduled   → Enqueued at future UTC time
│
├── QUEUES — KEY CONFIG
│   ├── MaxSizeInMB: 1–5 GB (Standard) / 80 GB (Premium)
│   ├── MaxDeliveryCount: 10 (default) → triggers DLQ
│   ├── LockDuration: 60s default (max 5 min)
│   ├── TTL: 14 days default (90 days Premium)
│   ├── DuplicateDetectionWindow: 10 min default
│   └── Sessions: on/off (requires Premium for best perf)
│
├── RECEIVE MODES
│   ├── PeekLock (default)
│   │   ├── Receive → Locked (invisible to others)
│   │   ├── Complete  → delete
│   │   ├── Abandon   → return + retry
│   │   ├── DeadLetter→ move to DLQ
│   │   ├── Defer     → store by SeqNum
│   │   └── RenewLock → extend timer
│   └── ReceiveAndDelete → deleted on receive ⚠️ no retry on failure
│
├── TOPICS & SUBSCRIPTIONS
│   ├── Topic → single sender → N subscriptions each get copy
│   ├── Filter types
│   │   ├── SQL Filter      → full predicate ("Priority='High' AND Amt>1000")
│   │   ├── Correlation Filter → equality only, 50–100× faster than SQL
│   │   └── Boolean Filter  → TrueFilter (all) / FalseFilter (none)
│   ├── Filter Actions → SET properties as msg enters subscription
│   └── Use cases: regional routing, priority lanes, content-type routing
│
├── MESSAGE PROPERTIES
│   ├── System
│   │   ├── MessageId       → duplicate detection key
│   │   ├── SessionId       → FIFO session group
│   │   ├── CorrelationId   → request-reply tracing
│   │   ├── ReplyTo         → response queue name
│   │   ├── Subject         → message label (routing/filtering)
│   │   ├── ContentType     → MIME (application/json)
│   │   ├── PartitionKey    → partition routing
│   │   ├── TimeToLive      → message expiration
│   │   └── ScheduledEnqueueTime → delayed delivery
│   └── ApplicationProperties → custom KV (string/int/long/double/bool/DateTime)
│
├── SESSIONS (FIFO)
│   ├── SessionId groups msgs → consumer locks entire session
│   ├── Only one consumer processes a session at a time
│   ├── State can be persisted on session (GetSessionStateAsync)
│   └── Use cases: order steps, approval workflows, chat, financial trades, Saga
│
├── DEAD-LETTER QUEUE (DLQ)
│   ├── Auto path: <queue>/$DeadLetterQueue
│   ├── Triggered by: MaxDeliveryCount exceeded, TTL expired,
│   │               explicit DeadLetterAsync(), filter exception
│   ├── Contains: DeadLetterReason + DeadLetterErrorDescription
│   ├── Monitor: GetQueueRuntimePropertiesAsync → DeadLetterMessageCount
│   └── Remediate: inspect → fix → re-enqueue to main queue
│
├── DEFERRAL & SCHEDULING
│   ├── Defer  → message invisible; retrieve via ReceiveDeferredMessageAsync(seqNum)
│   │           Use: dependency not ready yet (e.g. wait for payment before shipping)
│   └── Schedule → ScheduleMessageAsync(msg, futureTime) / CancelScheduledMessageAsync
│                  Use: reminders, retry with exponential backoff, business-hour delivery
│
├── TRANSACTIONS & BATCHING
│   ├── Transactions → TransactionScope wraps send+receive+complete atomically
│   │                  Rollback on any failure; Standard/Premium only
│   └── Batching     → CreateMessageBatchAsync → TryAddMessage → SendMessagesAsync
│                      Reduces network calls; auto-chunks when batch is full
│
├── SECURITY & AUTH
│   ├── Managed Identity (preferred) → no secrets
│   ├── SAS (Shared Access Signature) → token scoped to Listen/Send/Manage
│   ├── RBAC roles: Azure Service Bus Data Owner/Sender/Receiver
│   ├── TLS 1.2+ enforced in transit
│   └── VNET / Private Endpoints (Premium only)
│
├── KEY CODE PATTERNS (C#)
│   ├── ServiceBusClient → thread-safe singleton (reuse via DI)
│   ├── ServiceBusSender → send / scheduleSend / sendBatch
│   ├── ServiceBusReceiver → receive / peek / receiveDeferred
│   ├── ServiceBusProcessor → event-driven (ProcessMessageAsync / ProcessErrorAsync)
│   └── ServiceBusSessionProcessor → session-aware processor
│
├── ADVANCED PATTERNS
│   ├── Competing Consumers → multiple receivers on same queue (load balance)
│   ├── Priority Queue     → multiple queues + priority-aware dispatcher
│   ├── Pub-Sub Fan-Out    → topic → N subscriptions → N consumers
│   ├── Request-Reply      → ReplyTo + CorrelationId + temp reply queue
│   ├── Outbox Pattern     → DB txn + outbox table → relay to SB atomically
│   ├── Saga / Workflow    → sessions + session state for stateful multi-step flows
│   ├── Auto-Forward       → chain queues/topics (regional → central)
│   └── Message Deferral   → reorder processing without losing message
│
├── AZURE FUNCTIONS INTEGRATION
│   ├── ServiceBusTrigger → binds queue/topic/subscription
│   ├── Auto-scales based on queue depth (KEDA-compatible)
│   ├── Supports sessions: IsSessionsEnabled = true on trigger
│   └── Output binding → ServiceBus output to send messages from Function
│
├── MONITORING & DIAGNOSTICS
│   ├── Metrics: ActiveMessages, DeadLetterMessages, IncomingMessages, ServerErrors
│   ├── Azure Monitor → Alert rules on DLQ count or error rate
│   ├── Application Insights → distributed tracing with correlation
│   ├── Diagnostic logs → OperationalLogs, VNetAndIPFilteringLogs
│   └── GetQueueRuntimePropertiesAsync → programmatic queue stats
│
├── PERFORMANCE OPTIMIZATION
│   ├── Prefetch → fetch N messages ahead (PrefetchCount)
│   ├── Batch operations → send/receive in bulk
│   ├── Correlation filters over SQL filters (50–100× faster)
│   ├── Partitioning → distribute load across brokers
│   ├── Connection reuse → singleton ServiceBusClient
│   └── Premium tier → dedicated compute for predictable latency
│
├── HIGH AVAILABILITY & DR
│   ├── Built-in: 3× replication within region
│   ├── Availability Zones → Premium, zone-redundant (auto)
│   ├── Geo-Disaster Recovery (Premium) → alias FQDN → passive failover namespace
│   │   ├── Metadata replicated; messages NOT replicated
│   │   └── Initiate failover via API/portal; alias re-points in <1 min
│   └── Active-Active → app sends to both namespaces (duplicate detection dedupes)
│
├── PRICING
│   ├── Basic:    $0.05/million ops; queues only
│   ├── Standard: $0.05–$0.80/million ops; full features; shared capacity
│   └── Premium:  $682/month/messaging unit; dedicated; VNET; AZ; Geo-DR
│
├── SERVICE BUS vs ALTERNATIVES
│   ├── Storage Queue   → simple, cheap, <64 KB, no ordering, no pub-sub
│   ├── Event Grid      → reactive eventing, high fanout, no ordering, 24h retry
│   ├── Event Hubs      → high-throughput streaming, GB/s, partition-ordered
│   └── Service Bus ✅  → enterprise, guaranteed FIFO, transactions, DLQ, filtering
│
├── BEST PRACTICES
│   ├── Always use PeekLock (never ReceiveAndDelete for critical msgs)
│   ├── Set MaxDeliveryCount to reasonable value (5–10)
│   ├── Monitor DLQ and alert on non-zero count
│   ├── Use MessageId for idempotency + duplicate detection
│   ├── Prefer Correlation filters over SQL for hot paths
│   ├── Reuse ServiceBusClient as singleton
│   ├── Renew lock for long-running processing
│   ├── Use sessions for workflow ordering (not partitioning for ordering)
│   └── Separate DLQ processing as independent background service
│
└── TROUBLESHOOTING
    ├── Message stuck in DLQ      → check DeadLetterReason; fix & re-enqueue
    ├── Lock expired              → increase LockDuration or call RenewLock
    ├── Messages out of order     → enable Sessions (ordering ≠ partitioning)
    ├── Duplicate messages        → enable DuplicateDetection + idempotent consumer
    ├── Throttling (429)          → scale to Premium or reduce send rate
    ├── Connection drops          → SDK auto-retries; check firewall/VNET rules
    └── High latency              → check PrefetchCount; switch to Premium tier
```

---

## Introduction & Overview

### What is Azure Service Bus?

**Azure Service Bus** is a fully managed enterprise message broker with message queues and publish-subscribe topics. It provides reliable, secure, and scalable message delivery between distributed applications and services.

### Key Characteristics

```
┌─────────────────────────────────────────────────────────────┐
│                   AZURE SERVICE BUS                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Enterprise Messaging - Reliable delivery at scale       │
│  ✅ Guaranteed Delivery - At-least-once, at-most-once       │
│  ✅ FIFO Processing - Session-based ordering                │
│  ✅ Publish/Subscribe - Topics with multiple subscribers    │
│  ✅ Advanced Features - Transactions, dead-lettering, etc.  │
│  ✅ High Throughput - Millions of messages per second       │
│  ✅ Low Latency - Sub-millisecond message delivery          │
│  ✅ Globally Distributed - Geo-redundancy available         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Service Bus Tiers

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| **Price** | $0.05 / million ops | $0.05 - $0.80 / million ops | $682/month base |
| **Message Size** | 256 KB | 256 KB | 1 MB (100 MB with premium large messages) |
| **Queues** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Topics** | ❌ No | ✅ Yes | ✅ Yes |
| **Transactions** | ❌ No | ✅ Yes | ✅ Yes |
| **Duplicate Detection** | ❌ No | ✅ Yes | ✅ Yes |
| **Sessions** | ❌ No | ✅ Yes | ✅ Yes |
| **Auto-Forward** | ❌ No | ✅ Yes | ✅ Yes |
| **Dead-Lettering** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Scheduled Messages** | ❌ No | ✅ Yes | ✅ Yes |
| **Geo-Disaster Recovery** | ❌ No | ❌ No | ✅ Yes |
| **VNET Integration** | ❌ No | ❌ No | ✅ Yes |
| **Dedicated Capacity** | ❌ No | ❌ No | ✅ Yes |
| **Availability Zones** | ❌ No | ❌ No | ✅ Yes |
| **Max Throughput** | Shared | Shared | Up to 80 MB/s per unit |

### Messaging Patterns Supported

1. **Point-to-Point (Queues)**
   - Single sender → Single receiver (competing consumers)
   - Load leveling, decoupling

2. **Publish-Subscribe (Topics)**
   - Single sender → Multiple receivers
   - Event broadcasting, fan-out scenarios

3. **Request-Reply**
   - Synchronous-like patterns over async messaging
   - Correlation using ReplyTo and CorrelationId

4. **Session-based**
   - FIFO ordered message processing
   - Stateful message processing

---

## Core Concepts & Architecture

### Architecture Overview

```
┌───────────────────────────────────────────────────────────────┐
│                  SERVICE BUS NAMESPACE                        │
│  (sb://mynamespace.servicebus.windows.net)                    │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐    ┌─────────────────────────────────┐  │
│  │     QUEUES      │    │    TOPICS & SUBSCRIPTIONS       │  │
│  │                 │    │                                 │  │
│  │  ┌───────────┐  │    │  ┌────────────────────────┐    │  │
│  │  │  Queue 1  │  │    │  │      Topic 1           │    │  │
│  │  │           │  │    │  │  ┌──────────────────┐  │    │  │
│  │  │  Messages │  │    │  │  │  Subscription 1  │  │    │  │
│  │  │  [M1][M2] │  │    │  │  │  Filter: X=1     │  │    │  │
│  │  └───────────┘  │    │  │  └──────────────────┘  │    │  │
│  │                 │    │  │  ┌──────────────────┐  │    │  │
│  │  ┌───────────┐  │    │  │  │  Subscription 2  │  │    │  │
│  │  │  Queue 2  │  │    │  │  │  Filter: Y='A'   │  │    │  │
│  │  │           │  │    │  │  └──────────────────┘  │    │  │
│  │  │  [M3]     │  │    │  └────────────────────────┘    │  │
│  │  └───────────┘  │    │                                 │  │
│  └─────────────────┘    └─────────────────────────────────┘  │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **Namespace**
- Container for all messaging components
- Unique fully qualified domain name (FQDN)
- Example: `mycompany.servicebus.windows.net`
- Determines pricing tier (Basic, Standard, Premium)

#### 2. **Queue**
- FIFO message store
- Point-to-point communication
- Competing consumers pattern
- Single active consumer per message

```
Producer          Queue           Consumer 1
   │               │                  │
   ├──Message 1──▶ [M1]              │
   │               [M2] ◀─────────────┤  (Receives M2)
   ├──Message 3──▶ [M3]              │
   │               [M1] ◀─Consumer 2─┤  (Receives M1)
```

#### 3. **Topic**
- Message distribution hub
- One-to-many communication
- Publish-subscribe pattern
- Multiple independent subscribers

```
Producer          Topic           Subscription 1 (Filter: Priority='High')
   │               │                  │
   ├──M1 (High)──▶ Topic ───────────▶ Receives M1
   │               │                  │
   ├──M2 (Low)───▶ Topic              │
   │               │                  │
   │               └──────────────────▶ Subscription 2 (All)
                                       Receives M1, M2
```

#### 4. **Subscription**
- Virtual queue under a topic
- Each subscription receives copy of message
- Can have filters (SQL-like expressions)
- Independent message processing

#### 5. **Message**
- Data transfer unit
- Contains:
  - **Body**: Actual payload (byte array)
  - **Properties**: Metadata (system and custom)
  - **Headers**: Routing and processing info

### Message Flow

```
┌──────────┐      ┌─────────────┐      ┌──────────┐
│ Sender   │─────▶│ Service Bus │─────▶│ Receiver │
└──────────┘      │             │      └──────────┘
                  │ ┌─────────┐ │
                  │ │ Message │ │
                  │ │  Store  │ │
                  │ └─────────┘ │
                  │             │
                  │ Persistent  │
                  │ Reliable    │
                  │ Ordered     │
                  └─────────────┘
```

### Message States

```
┌──────────────────────────────────────────────────────────┐
│                    MESSAGE LIFECYCLE                     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. Active        → Available for receive                │
│  2. Locked        → Received but not yet completed       │
│  3. Completed     → Successfully processed, deleted      │
│  4. Abandoned     → Returned to queue, redelivered       │
│  5. Dead-Letter   → Moved to DLQ (poison message)        │
│  6. Deferred      → Set aside for later retrieval        │
│  7. Scheduled     → Enqueued at future time              │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## When to Use Service Bus

### ✅ Ideal Use Cases

| Scenario | Why Service Bus? | Example |
|----------|------------------|---------|
| **Enterprise Integration** | Reliable messaging between critical systems | ERP to CRM integration, order processing |
| **Microservices Communication** | Decoupled async communication | Order service → Inventory service |
| **Event-Driven Architecture** | Publish events to multiple subscribers | Customer created → Email, Analytics, CRM |
| **Load Leveling** | Buffer between fast producer and slow consumer | High-speed IoT ingestion → Batch processing |
| **Guaranteed Delivery** | At-least-once delivery guaranteed | Financial transactions, payment processing |
| **FIFO Processing** | Strict message ordering required | Order fulfillment steps, workflow engines |
| **Long-running Workflows** | Reliable coordination of steps | Document approval workflow |
| **Temporal Decoupling** | Sender and receiver don't need to be online simultaneously | Mobile app → Backend processing |

### ❌ Not Recommended For

| Scenario | Why Not? | Better Alternative |
|----------|----------|-------------------|
| **Real-time streaming** | Not designed for continuous data streams | Event Hubs, Kafka |
| **Simple fire-and-forget** | Overkill for basic scenarios | Storage Queues |
| **Low latency (<1ms)** | Enterprise features add overhead | Redis, In-memory queues |
| **Broadcast to millions** | Topics scale to thousands, not millions | Event Grid, SignalR |
| **Large file transfer** | 1MB message limit (even premium) | Blob Storage + Queue/Event Grid |
| **State storage** | Not a database | Cosmos DB, SQL Database |

### Decision Matrix

```
Do you need guaranteed delivery? ──No──▶ Consider Storage Queue
         │
         Yes
         │
Do you need publish/subscribe? ──No──▶ Use Service Bus Queue
         │
         Yes
         │
Do you need filtering? ──No──▶ Use Service Bus Topic (no filters)
         │
         Yes
         │
Do you need ordering (FIFO)? ──No──▶ Service Bus Topic + Subscriptions
         │
         Yes
         │
Use Service Bus with Sessions ✅
```

---

## Service Bus vs Other Messaging Services

### Comparison Matrix

| Feature | Service Bus | Storage Queue | Event Grid | Event Hubs |
|---------|-------------|---------------|------------|------------|
| **Purpose** | Enterprise messaging | Simple queuing | Event routing | Stream processing |
| **Max Message Size** | 1 MB (100 MB premium) | 64 KB | 1 MB | 1 MB |
| **Delivery Guarantee** | At-least-once | At-least-once | At-least-once (24h retry) | At-least-once |
| **Ordering** | ✅ Sessions | ❌ No | ❌ No | ✅ Per partition |
| **Pub/Sub** | ✅ Topics | ❌ No | ✅ Native | ❌ No (consumer groups) |
| **Transactions** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Dead-Lettering** | ✅ Built-in | ❌ Manual | ❌ No | ❌ No |
| **Filtering** | ✅ SQL filters | ❌ No | ✅ Event types | ❌ No |
| **Max Retention** | 14 days (90 days premium) | 7 days | 24 hours | 90 days |
| **Throughput** | MB/s range | MB/s range | Millions of events/sec | GB/s range |
| **Latency** | <10ms (P95) | <100ms | <1s | <1s |
| **Pricing Model** | Per operation + size | Per operation | Per operation | Per throughput unit |
| **Use Case** | Enterprise integration | Background jobs | Event-driven apps | Big data streaming |

### When to Choose What?

```
┌─────────────────────────────────────────────────────────────┐
│                  DECISION FLOWCHART                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Need guaranteed delivery + FIFO? ────────▶ Service Bus    │
│                                                             │
│  Need pub/sub with filtering? ────────────▶ Service Bus    │
│                                                             │
│  Simple job queue (<64KB)? ───────────────▶ Storage Queue  │
│                                                             │
│  Reactive event notifications? ───────────▶ Event Grid     │
│                                                             │
│  High-throughput streaming? ──────────────▶ Event Hubs     │
│                                                             │
│  Enterprise integration? ─────────────────▶ Service Bus ✅  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Queues - Deep Dive

### Queue Concepts

**Service Bus Queue** = Ordered message store with exactly-one-delivery semantics

### Queue Properties

```yaml
Queue Configuration:
  Name: orders-queue
  Max Size: 1 GB, 2 GB, 3 GB, 4 GB, 5 GB (Standard)
            80 GB (Premium)
  Max Delivery Count: 10 (default)
  TTL (Time to Live): 14 days (default)
  Lock Duration: 60 seconds (default, 5 min max)
  Duplicate Detection Window: 10 minutes (default)
  Enable Sessions: false (default)
  Enable Dead Lettering: true
  Enable Partitioning: false (Standard tier)
  Status: Active | Disabled | SendDisabled | ReceiveDisabled
```

### Queue Operations

#### 1. **Send Message**

```csharp
await sender.SendMessageAsync(new ServiceBusMessage("Hello"));
```

**What happens:**
```
1. Message arrives at Service Bus gateway
2. Authenticated and authorized
3. Stored persistently (replicated 3x in region)
4. Acknowledgment sent to sender
5. Message becomes "Active" (available for receive)
```

#### 2. **Receive Message (Peek-Lock)**

```csharp
ServiceBusReceivedMessage message = await receiver.ReceiveMessageAsync();
// Message is LOCKED (not deleted)
await receiver.CompleteMessageAsync(message); // Delete message
```

**Message Lock:**
```
┌──────────────────────────────────────────────────────────┐
│                    PEEK-LOCK MODE                        │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. Receive → Message marked as "Locked"                 │
│  2. Lock Duration: 60 seconds (default)                  │
│  3. While locked:                                        │
│     - Invisible to other receivers                       │
│     - Processing can complete or renew lock              │
│  4. Lock expires → Message becomes active again          │
│  5. DeliveryCount incremented                            │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Receive Options:**

| Action | Method | Effect |
|--------|--------|--------|
| **Complete** | `CompleteMessageAsync()` | Delete message (successful processing) |
| **Abandon** | `AbandonMessageAsync()` | Return to queue, increment DeliveryCount |
| **Dead-Letter** | `DeadLetterMessageAsync()` | Move to DLQ (poison message) |
| **Defer** | `DeferMessageAsync()` | Set aside for later (needs sequence number) |
| **Renew Lock** | `RenewMessageLockAsync()` | Extend lock duration (for long processing) |

#### 3. **Receive Message (Receive-and-Delete)**

```csharp
var options = new ServiceBusReceiverOptions
{
    ReceiveMode = ServiceBusReceiveMode.ReceiveAndDelete
};
var receiver = client.CreateReceiver(queueName, options);
var message = await receiver.ReceiveMessageAsync(); // Message immediately deleted
```

**⚠️ WARNING:** Message is deleted immediately. If processing fails, message is lost!

### Queue Message Patterns

#### Pattern 1: Competing Consumers

```
Producer                Queue              Consumer 1
   │                     │                    │
   ├──Message 1─────▶  [M1]                  │
   │                   [M2]                   │
   │                   [M3] ◀────────────────┤  (Gets M3)
   │                   [M4]                   │
   │                   [M1] ◀────Consumer 2──┤  (Gets M1)
   │                   [M2] ◀────Consumer 3──┤  (Gets M2)
   
Load is distributed across multiple consumers
```

#### Pattern 2: Work Queue with Priority

```csharp
// Send with custom priority property
var message = new ServiceBusMessage("Task data");
message.ApplicationProperties["Priority"] = "High";
await sender.SendMessageAsync(message);

// Receiver processes high priority first (requires custom logic)
```

### Advanced Queue Features

#### 1. **Duplicate Detection**

Automatically detects and removes duplicate messages within a time window.

```csharp
// Create queue with duplicate detection
var queueOptions = new CreateQueueOptions("orders")
{
    RequiresDuplicateDetection = true,
    DuplicateDetectionHistoryTimeWindow = TimeSpan.FromMinutes(10)
};
await adminClient.CreateQueueAsync(queueOptions);

// Send with MessageId for duplicate detection
var message = new ServiceBusMessage("Order data")
{
    MessageId = "ORDER-12345" // Same MessageId = Duplicate
};
await sender.SendMessageAsync(message);
```

**How it works:**
```
Time: 10:00 - Send message with MessageId="ORDER-123"
Time: 10:02 - Send message with MessageId="ORDER-123" → REJECTED (duplicate)
Time: 10:11 - Send message with MessageId="ORDER-123" → ACCEPTED (outside window)
```

#### 2. **Auto-Forwarding**

Automatically forward messages from one queue/topic to another.

```csharp
// Create queue that auto-forwards to another queue
var queueOptions = new CreateQueueOptions("source-queue")
{
    ForwardTo = "destination-queue"
};
await adminClient.CreateQueueAsync(queueOptions);
```

**Use case:**
```
Regional Queue (West) ──Auto-Forward──▶ Central Processing Queue
Regional Queue (East) ──Auto-Forward──▶ Central Processing Queue
```

#### 3. **Scheduled Messages**

Send messages to be enqueued at a future time.

```csharp
// Schedule message for 1 hour from now
var message = new ServiceBusMessage("Reminder");
var scheduledTime = DateTimeOffset.UtcNow.AddHours(1);
await sender.ScheduleMessageAsync(message, scheduledTime);
```

**Use cases:**
- Delayed notifications
- Retry with backoff
- Business hour processing

---

## Topics & Subscriptions - Deep Dive

### Topic and Subscription Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        TOPIC                                │
│                 (One-to-Many Distribution)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Producer ────▶ Topic ────┬────▶ Subscription 1 (All)      │
│                           │                                 │
│                           ├────▶ Subscription 2 (Filter)    │
│                           │      WHERE Priority='High'      │
│                           │                                 │
│                           └────▶ Subscription 3 (Filter)    │
│                                  WHERE Region='US'          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Creating Topics and Subscriptions

#### 1. **Create Topic**

```csharp
var topicOptions = new CreateTopicOptions("orders")
{
    MaxSizeInMegabytes = 1024,
    EnableBatchedOperations = true,
    SupportOrdering = false, // Set true for ordered delivery
    RequiresDuplicateDetection = true,
    DuplicateDetectionHistoryTimeWindow = TimeSpan.FromMinutes(10)
};

await adminClient.CreateTopicAsync(topicOptions);
```

#### 2. **Create Subscription**

```csharp
var subscriptionOptions = new CreateSubscriptionOptions("orders", "all-orders")
{
    MaxDeliveryCount = 10,
    LockDuration = TimeSpan.FromMinutes(5),
    DeadLetteringOnMessageExpiration = true,
    EnableBatchedOperations = true
};

await adminClient.CreateSubscriptionAsync(subscriptionOptions);
```

### Subscription Filters

**Three types of filters:**

1. **SQL Filter** (Most powerful)
2. **Correlation Filter** (Performance optimized)
3. **Boolean Filter** (True = all messages, False = no messages)

#### SQL Filters

```csharp
// Create subscription with SQL filter
var subscriptionOptions = new CreateSubscriptionOptions("orders", "high-priority");

var filter = new SqlRuleFilter("Priority = 'High' AND Amount > 1000");
var rule = new CreateRuleOptions("HighPriorityFilter", filter);

await adminClient.CreateSubscriptionAsync(subscriptionOptions);
await adminClient.CreateRuleAsync("orders", "high-priority", rule);
```

**SQL Filter Syntax:**

```sql
-- Operators: =, <>, <, <=, >, >=, AND, OR, NOT, IN, LIKE

-- String comparison
Priority = 'High'

-- Numeric comparison
Amount > 1000

-- Combined conditions
Priority = 'High' AND Amount > 1000

-- IN operator
Region IN ('US', 'EU', 'ASIA')

-- LIKE operator
Subject LIKE '%order%'

-- EXISTS (check if property exists)
EXISTS(CustomerId)

-- System properties
sys.ContentType = 'application/json'
sys.Label = 'OrderConfirmation'
```

#### Correlation Filters (Faster)

```csharp
// Optimized for equality checks on properties
var filter = new CorrelationRuleFilter
{
    Subject = "OrderConfirmation",
    CorrelationId = "ORDER-12345",
    Properties =
    {
        ["Region"] = "US",
        ["Priority"] = "High"
    }
};

var rule = new CreateRuleOptions("USHighPriorityOrders", filter);
await adminClient.CreateRuleAsync("orders", "us-orders", rule);
```

**⚡ Performance:** Correlation filters are 50-100x faster than SQL filters!

### Filter Examples

#### Example 1: Regional Subscriptions

```csharp
// US Orders
var usFilter = new SqlRuleFilter("Region = 'US'");
await CreateSubscriptionWithFilter("orders", "us-orders", usFilter);

// EU Orders
var euFilter = new SqlRuleFilter("Region = 'EU'");
await CreateSubscriptionWithFilter("orders", "eu-orders", euFilter);

// APAC Orders
var apacFilter = new SqlRuleFilter("Region = 'APAC'");
await CreateSubscriptionWithFilter("orders", "apac-orders", apacFilter);
```

#### Example 2: Priority-based Processing

```csharp
// Critical priority - immediate processing
var criticalFilter = new SqlRuleFilter("Priority = 'Critical'");
await CreateSubscriptionWithFilter("notifications", "critical-alerts", criticalFilter);

// High priority - fast processing
var highFilter = new SqlRuleFilter("Priority = 'High'");
await CreateSubscriptionWithFilter("notifications", "high-priority", highFilter);

// Normal priority - standard processing
var normalFilter = new SqlRuleFilter("Priority IS NULL OR Priority = 'Normal'");
await CreateSubscriptionWithFilter("notifications", "normal-queue", normalFilter);
```

#### Example 3: Content-type Routing

```csharp
// JSON messages → Azure Function
var jsonFilter = new SqlRuleFilter("sys.ContentType = 'application/json'");
await CreateSubscriptionWithFilter("events", "json-processor", jsonFilter);

// XML messages → Legacy system
var xmlFilter = new SqlRuleFilter("sys.ContentType = 'application/xml'");
await CreateSubscriptionWithFilter("events", "xml-processor", xmlFilter);
```

### Filter Actions

**Actions** modify message properties as they enter subscriptions.

```csharp
var filter = new SqlRuleFilter("Amount > 1000");

var action = new SqlRuleAction(
    "SET sys.Label = 'LargeOrder'; " +
    "SET ProcessingTier = 'Premium'"
);

var rule = new CreateRuleOptions("LargeOrdersRule", filter)
{
    Action = action
};

await adminClient.CreateRuleAsync("orders", "large-orders", rule);
```

---

## Message Properties & Metadata

### Message Anatomy

```csharp
var message = new ServiceBusMessage("Message body")
{
    // ==== System Properties (Set by Service Bus) ====
    MessageId = "MSG-123",              // Unique identifier
    ContentType = "application/json",   // MIME type
    CorrelationId = "CORR-456",        // For request-reply patterns
    ReplyTo = "response-queue",        // Reply destination
    Subject = "OrderCreated",          // Message label (max 128 chars)
    To = "orders",                     // Destination
    TimeToLive = TimeSpan.FromDays(1), // Message expiration
    ScheduledEnqueueTime = DateTimeOffset.UtcNow.AddHours(1), // Scheduled delivery
    SessionId = "session-123",         // For session-enabled queues
    ReplyToSessionId = "reply-session", // Reply session
    PartitionKey = "customer-123",     // For partitioned entities
    
    // ==== Application Properties (Custom metadata) ====
    ApplicationProperties =
    {
        ["OrderId"] = "ORDER-12345",
        ["CustomerId"] = "CUST-789",
        ["Priority"] = "High",
        ["Amount"] = 1500.00,
        ["Region"] = "US",
        ["Timestamp"] = DateTime.UtcNow.ToString("o")
    }
};
```

### System Properties Reference

| Property | Type | Description | Use Case |
|----------|------|-------------|----------|
| **MessageId** | string | Unique message identifier | Duplicate detection, tracking |
| **SessionId** | string | Session identifier (if enabled) | FIFO processing |
| **CorrelationId** | string | Correlate request/response | RPC pattern, distributed tracing |
| **ReplyTo** | string | Queue/topic for replies | Request-reply pattern |
| **Subject** | string | Message label/type | Message routing, filtering |
| **ContentType** | string | MIME type | Serialization format |
| **PartitionKey** | string | Partition routing key | Load distribution |
| **TimeToLive** | TimeSpan | Message expiration | Prevent stale messages |
| **ScheduledEnqueueTime** | DateTimeOffset | Delayed delivery time | Scheduled notifications |

### Application Properties

**Custom key-value pairs** for filtering, routing, and business logic.

```csharp
// Sending
message.ApplicationProperties["CustomerId"] = 12345; // int
message.ApplicationProperties["IsVIP"] = true; // bool
message.ApplicationProperties["Amount"] = 99.99; // double
message.ApplicationProperties["Timestamp"] = DateTime.UtcNow; // DateTime
message.ApplicationProperties["Tags"] = new[] { "urgent", "retail" }; // array

// Receiving
var customerId = (int)message.ApplicationProperties["CustomerId"];
var isVIP = (bool)message.ApplicationProperties["IsVIP"];
```

**Supported Types:**
- `string`, `int`, `long`, `double`, `bool`, `DateTime`, `byte[]`

### Message Body Serialization

#### JSON (Recommended)

```csharp
using System.Text.Json;

// Send
var order = new Order { Id = 123, Amount = 99.99 };
var json = JsonSerializer.Serialize(order);
var message = new ServiceBusMessage(json)
{
    ContentType = "application/json"
};

// Receive
var receivedOrder = JsonSerializer.Deserialize<Order>(message.Body.ToString());
```

#### Binary

```csharp
// Send
byte[] data = File.ReadAllBytes("document.pdf");
var message = new ServiceBusMessage(data)
{
    ContentType = "application/pdf"
};

// Receive
byte[] receivedData = message.Body.ToArray();
File.WriteAllBytes("received.pdf", receivedData);
```

---

## Sessions & FIFO Processing

### What are Sessions?

**Sessions** provide first-in-first-out (FIFO) message delivery and enable stateful message processing.

```
┌──────────────────────────────────────────────────────────┐
│              WITHOUT SESSIONS (Unordered)                │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Queue: [M1][M3][M2][M5][M4]                             │
│                                                          │
│  Consumer 1: Receives M3                                 │
│  Consumer 2: Receives M1                                 │
│  Consumer 3: Receives M5                                 │
│                                                          │
│  ❌ Messages processed out of order                      │
│                                                          │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│               WITH SESSIONS (Ordered)                    │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Session "Order-123": [M1][M2][M3]                       │
│  Session "Order-456": [M4][M5]                           │
│                                                          │
│  Consumer 1: Locks "Order-123" → Processes M1, M2, M3   │
│  Consumer 2: Locks "Order-456" → Processes M4, M5       │
│                                                          │
│  ✅ Messages within session processed in order          │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Enabling Sessions

```csharp
// Create session-enabled queue
var queueOptions = new CreateQueueOptions("orders")
{
    RequiresSession = true
};
await adminClient.CreateQueueAsync(queueOptions);
```

**⚠️ Important:** Cannot enable/disable sessions after queue creation!

### Sending to Sessions

```csharp
var sender = client.CreateSender("orders");

// All messages with same SessionId are processed in order
await sender.SendMessageAsync(new ServiceBusMessage("Step 1")
{
    SessionId = "ORDER-12345"
});

await sender.SendMessageAsync(new ServiceBusMessage("Step 2")
{
    SessionId = "ORDER-12345"
});

await sender.SendMessageAsync(new ServiceBusMessage("Step 3")
{
    SessionId = "ORDER-12345"
});
```

### Receiving from Sessions

```csharp
// Create session receiver
var sessionReceiver = await client.AcceptNextSessionAsync("orders");

// All messages from this session delivered in order
while (true)
{
    var message = await sessionReceiver.ReceiveMessageAsync(TimeSpan.FromSeconds(5));
    if (message == null) break;
    
    Console.WriteLine($"Session: {message.SessionId}, Message: {message.Body}");
    await sessionReceiver.CompleteMessageAsync(message);
}

// Close session
await sessionReceiver.CloseAsync();
```

### Session State

**Store state between messages** in the same session.

```csharp
// Set session state
var state = new WorkflowState
{
    CurrentStep = 2,
    TotalSteps = 5,
    ProcessedItems = new List<string> { "Item1", "Item2" }
};

byte[] stateBytes = JsonSerializer.SerializeToUtf8Bytes(state);
await sessionReceiver.SetSessionStateAsync(new BinaryData(stateBytes));

// Get session state (on next message)
BinaryData stateData = await sessionReceiver.GetSessionStateAsync();
var retrievedState = JsonSerializer.Deserialize<WorkflowState>(stateData);
```

### Session Use Cases

| Scenario | Why Sessions? | Example |
|----------|---------------|---------|
| **Order Processing** | Steps must be in order | 1. Validate 2. Charge 3. Ship 4. Notify |
| **Document Workflow** | Sequential approval steps | 1. Submit 2. Manager approval 3. Finance approval |
| **Chat Applications** | Messages per conversation in order | Group chat, customer support conversations |
| **Financial Transactions** | Strict ordering required | Stock trades for same account |
| **Saga Pattern** | Distributed transactions | Multi-step booking (flight + hotel + car) |

---

## Dead-Letter Queues

### What is a Dead-Letter Queue (DLQ)?

A **dead-letter queue** stores messages that cannot be processed successfully.

```
┌──────────────────────────────────────────────────────────┐
│                  MESSAGE PROCESSING                      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Queue ──▶ Receiver ──▶ Process                          │
│               │                                          │
│               ├─ Success ──▶ Complete Message            │
│               │                                          │
│               ├─ Transient Error ──▶ Abandon (retry)     │
│               │                                          │
│               └─ Max Retries Exceeded ──▶ Dead-Letter    │
│                  Permanent Error ──▶ Dead-Letter         │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### When Messages are Dead-Lettered

1. **Exceeded MaxDeliveryCount** (default: 10 attempts)
2. **Message expired** (TTL exceeded)
3. **Explicitly dead-lettered** by application code
4. **Filter evaluation exception**

### Automatic Dead-Lettering

```csharp
// Create queue with dead-lettering enabled
var queueOptions = new CreateQueueOptions("orders")
{
    MaxDeliveryCount = 5, // Move to DLQ after 5 failed attempts
    DeadLetteringOnMessageExpiration = true // DLQ expired messages
};
```

**Scenario:**
```
Attempt 1: Abandon (DeliveryCount = 1)
Attempt 2: Abandon (DeliveryCount = 2)
Attempt 3: Abandon (DeliveryCount = 3)
Attempt 4: Abandon (DeliveryCount = 4)
Attempt 5: Abandon (DeliveryCount = 5)
Result: Message moved to DLQ automatically
```

### Explicit Dead-Lettering

```csharp
try
{
    var message = await receiver.ReceiveMessageAsync();
    
    // Attempt processing
    await ProcessMessageAsync(message);
    await receiver.CompleteMessageAsync(message);
}
catch (InvalidDataException ex)
{
    // Permanent error - no point retrying
    await receiver.DeadLetterMessageAsync(
        message,
        deadLetterReason: "InvalidData",
        deadLetterErrorDescription: ex.Message
    );
}
catch (Exception ex)
{
    // Transient error - retry
    await receiver.AbandonMessageAsync(message);
}
```

### Reading from Dead-Letter Queue

```csharp
// Dead-letter queue path: {queueName}/$deadletterqueue
var dlqReceiver = client.CreateReceiver(
    "orders",
    new ServiceBusReceiverOptions
    {
        SubQueue = SubQueue.DeadLetter
    }
);

await foreach (var message in dlqReceiver.ReceiveMessagesAsync())
{
    Console.WriteLine($"DLQ Message: {message.Body}");
    Console.WriteLine($"Reason: {message.DeadLetterReason}");
    Console.WriteLine($"Description: {message.DeadLetterErrorDescription}");
    Console.WriteLine($"Original Queue: {message.DeadLetterSource}");
    Console.WriteLine($"Delivery Count: {message.DeliveryCount}");
    
    // Decide what to do:
    // Option 1: Fix and resubmit to original queue
    // Option 2: Log and complete (delete from DLQ)
    // Option 3: Send to error handling system
    
    await dlqReceiver.CompleteMessageAsync(message);
}
```

### Reprocessing Dead-Letter Messages

```csharp
public async Task ResubmitDeadLetterMessage(ServiceBusReceivedMessage dlqMessage)
{
    var sender = client.CreateSender("orders");
    
    // Create new message from DLQ message
    var newMessage = new ServiceBusMessage(dlqMessage.Body)
    {
        MessageId = Guid.NewGuid().ToString(), // New ID
        ContentType = dlqMessage.ContentType,
        CorrelationId = dlqMessage.CorrelationId,
        SessionId = dlqMessage.SessionId
    };
    
    // Copy application properties
    foreach (var prop in dlqMessage.ApplicationProperties)
    {
        newMessage.ApplicationProperties[prop.Key] = prop.Value;
    }
    
    // Add reprocessing metadata
    newMessage.ApplicationProperties["ReprocessedFrom"] = "DLQ";
    newMessage.ApplicationProperties["OriginalMessageId"] = dlqMessage.MessageId;
    newMessage.ApplicationProperties["ReprocessedAt"] = DateTime.UtcNow;
    
    // Send to original queue
    await sender.SendMessageAsync(newMessage);
    
    // Complete (delete) from DLQ
    var dlqReceiver = client.CreateReceiver("orders", 
        new ServiceBusReceiverOptions { SubQueue = SubQueue.DeadLetter });
    await dlqReceiver.CompleteMessageAsync(dlqMessage);
}
```

### Dead-Letter Queue Monitoring

```csharp
// Get dead-letter queue statistics
var queueRuntimeProperties = await adminClient.GetQueueRuntimePropertiesAsync("orders");

Console.WriteLine($"Active Messages: {queueRuntimeProperties.Value.ActiveMessageCount}");
Console.WriteLine($"Dead-Letter Messages: {queueRuntimeProperties.Value.DeadLetterMessageCount}");
Console.WriteLine($"Scheduled Messages: {queueRuntimeProperties.Value.ScheduledMessageCount}");

// Alert if DLQ has messages
if (queueRuntimeProperties.Value.DeadLetterMessageCount > 0)
{
    await AlertOpsTeam($"Dead-letter queue has {queueRuntimeProperties.Value.DeadLetterMessageCount} messages!");
}
```

---

## Message Deferral & Scheduling

### Message Deferral

**Defer** a message to process it later (out of order).

```csharp
var message = await receiver.ReceiveMessageAsync();

if (!IsReadyToProcess(message))
{
    // Defer message and get sequence number
    long sequenceNumber = message.SequenceNumber;
    await receiver.DeferMessageAsync(message);
    
    // Store sequence number for later retrieval
    await StoreSequenceNumberAsync(sequenceNumber);
}
else
{
    await ProcessMessageAsync(message);
    await receiver.CompleteMessageAsync(message);
}

// Later, retrieve deferred message
long storedSequenceNumber = await GetStoredSequenceNumberAsync();
var deferredMessage = await receiver.ReceiveDeferredMessageAsync(storedSequenceNumber);
```

**Use case:** Message arrived too early (dependencies not ready).

### Scheduled Messages

**Schedule** messages to be enqueued at a specific future time.

```csharp
// Schedule for specific time
var message = new ServiceBusMessage("Reminder");
var scheduledTime = new DateTimeOffset(2024, 12, 25, 9, 0, 0, TimeSpan.Zero);
long sequenceNumber = await sender.ScheduleMessageAsync(message, scheduledTime);

// Schedule for relative time (1 hour from now)
var futureTime = DateTimeOffset.UtcNow.AddHours(1);
await sender.ScheduleMessageAsync(message, futureTime);

// Cancel scheduled message (before it's enqueued)
await sender.CancelScheduledMessageAsync(sequenceNumber);
```

**Use cases:**
- Delayed notifications (e.g., "Your order will arrive tomorrow")
- Retry with exponential backoff
- Business hours processing (schedule for 9 AM next day)
- Reminders and time-based triggers

### Retry with Exponential Backoff

```csharp
public async Task SendWithRetryAsync(string queueName, string messageBody)
{
    var sender = client.CreateSender(queueName);
    
    var message = new ServiceBusMessage(messageBody);
    message.ApplicationProperties["RetryCount"] = 0;
    
    try
    {
        await ProcessMessageAsync(message);
    }
    catch (TransientException ex)
    {
        int retryCount = (int)message.ApplicationProperties["RetryCount"];
        retryCount++;
        
        if (retryCount <= 5)
        {
            // Exponential backoff: 1min, 2min, 4min, 8min, 16min
            var delay = TimeSpan.FromMinutes(Math.Pow(2, retryCount - 1));
            var retryTime = DateTimeOffset.UtcNow.Add(delay);
            
            var retryMessage = new ServiceBusMessage(messageBody);
            retryMessage.ApplicationProperties["RetryCount"] = retryCount;
            retryMessage.ApplicationProperties["OriginalError"] = ex.Message;
            
            await sender.ScheduleMessageAsync(retryMessage, retryTime);
        }
        else
        {
            // Max retries exceeded
            await sender.SendMessageAsync(new ServiceBusMessage(messageBody));
        }
    }
}
```

---

## Transactions & Batching

### Transactions

**Atomic operations** - all succeed or all fail together.

```csharp
using var transactionScope = new TransactionScope(TransactionScopeAsyncFlowOption.Enabled);

var sender = client.CreateSender("orders");
var receiver = client.CreateReceiver("incoming-orders");

// Receive message
var message = await receiver.ReceiveMessageAsync();

// Process and send to another queue
await ProcessOrderAsync(message);
await sender.SendMessageAsync(new ServiceBusMessage("Processed"));

// Complete original message
await receiver.CompleteMessageAsync(message);

// Commit transaction
transactionScope.Complete();
```

**If any operation fails, everything rolls back.**

### Message Batching

**Send multiple messages** in a single network call.

```csharp
var sender = client.CreateSender("orders");

// Create batch
using ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync();

for (int i = 0; i < 100; i++)
{
    var message = new ServiceBusMessage($"Order {i}");
    
    if (!messageBatch.TryAddMessage(message))
    {
        // Batch is full, send it
        await sender.SendMessagesAsync(messageBatch);
        
        // Create new batch
        messageBatch = await sender.CreateMessageBatchAsync();
        messageBatch.TryAddMessage(message);
    }
}

// Send remaining messages
if (messageBatch.Count > 0)
{
    await sender.SendMessagesAsync(messageBatch);
}
```

**Benefits:**
- Reduced network overhead
- Better throughput
- Lower costs

---

*(Continued in next part due to length...)*

**Note**: This is Part 1 of the Service Bus guide covering core concepts. The document continues with:
- Security & Authentication
- Code Implementation (C#, Python, Node.js)
- Advanced Patterns
- Integration with Azure Functions
- Monitoring & Performance
- Real-world Scenarios
- Best Practices

Would you like me to continue with the remaining sections?
