# Quick Interview Prep — Deep Dive Edition
> **Topics:** Azure Container Apps · Service Bus · SQL Server & Cosmos DB Performance · Integration Testing · Modular Monolith · Distributed vs In-Memory Cache · React.js
> **Format:** Lead/Architect Level Q&A + SDK Code + Mental Models + Production Insights

---

## Table of Contents
1. [Azure Container Apps](#1-azure-container-apps)
2. [Azure Service Bus — Advanced](#2-azure-service-bus--advanced)
3. [SQL Server — Performance & Troubleshooting](#3-sql-server--performance--troubleshooting)
4. [Cosmos DB — Performance & Troubleshooting](#4-cosmos-db--performance--troubleshooting)
5. [Integration Testing — .NET](#5-integration-testing--net)
6. [Modular Monolith Architecture](#6-modular-monolith-architecture)
7. [Distributed vs In-Memory Cache](#7-distributed-vs-in-memory-cache)
8. [React.js — Core to Advanced](#8-reactjs--core-to-advanced)

---

## 1. Azure Container Apps

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Container Apps = Managed Kubernetes for Humans   │
│  You give it a Docker image → It handles K8s, Envoy, KEDA      │
│  Think: "AKS without the PhD in Kubernetes required"           │
│                                                                  │
│  Environment = shared VNet boundary (like a K8s namespace)      │
│  Container App = a deployable microservice unit                  │
│  Revision = immutable snapshot of your app config               │
└─────────────────────────────────────────────────────────────────┘
```

### Architecture Hierarchy
```
Azure Subscription
└── Resource Group
    └── Container Apps Environment          ← shared VNet, logs, DNS
        ├── Container App: api-service      ← your microservice
        │   ├── Revision v1 (20%)          ← canary / blue-green
        │   └── Revision v2 (80%)
        ├── Container App: worker-service
        │   └── Revision v1 (100%)
        └── Dapr Component: servicebus      ← pluggable building block
```

### Key Concepts Table
| Concept | What It Means | Production Use |
|---------|--------------|----------------|
| **Revision** | Immutable snapshot of container config | Blue-green, canary |
| **Replica** | Running instance of a revision | Horizontal scale |
| **Ingress** | HTTP(S) entry point, internal or external | Load balancing |
| **Dapr** | Sidecar for service discovery, pub/sub, state | Microservice patterns |
| **KEDA** | Event-driven autoscaler built-in | Scale-to-zero on queues |
| **Environment** | Shared VNet boundary for all apps | Isolation + DNS |

### CLI — Essential Commands
```bash
# Provision environment
az containerapp env create \
  --name cae-prod \
  --resource-group rg-prod \
  --location eastus2 \
  --logs-workspace-id $WORKSPACE_ID \
  --logs-workspace-key $WORKSPACE_KEY

# Deploy a container app
az containerapp create \
  --name api-service \
  --resource-group rg-prod \
  --environment cae-prod \
  --image myacr.azurecr.io/api:v2 \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 10 \
  --cpu 0.5 \
  --memory 1.0Gi \
  --env-vars "DB_CONN=secretref:dbconn" \
  --secrets "dbconn=<conn-string>"

# Update with traffic split (canary deployment)
az containerapp update \
  --name api-service \
  --resource-group rg-prod \
  --image myacr.azurecr.io/api:v3

az containerapp ingress traffic set \
  --name api-service \
  --resource-group rg-prod \
  --revision-weight latest=20 previous=80   # 20% canary

# Scale rules — KEDA on Service Bus queue
az containerapp update \
  --name worker-service \
  --resource-group rg-prod \
  --scale-rule-name sb-rule \
  --scale-rule-type azure-servicebus \
  --scale-rule-metadata "queueName=orders" "namespace=myns" "messageCount=10" \
  --scale-rule-auth "connection=sb-connection-string"

# View logs
az containerapp logs show \
  --name api-service \
  --resource-group rg-prod \
  --follow
```

### Bicep — Production Template
```bicep
param location string = resourceGroup().location
param environment string = 'prod'

resource env 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'cae-${environment}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspace.properties.customerId
        sharedKey: logWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'api-service'
  location: location
  identity: { type: 'SystemAssigned' }       // WHY: managed identity for Key Vault
  properties: {
    environmentId: env.id
    configuration: {
      activeRevisionsMode: 'Multiple'         // WHY: enables traffic splitting
      ingress: {
        external: true
        targetPort: 80
        traffic: [
          { latestRevision: true, weight: 100 }
        ]
      }
      secrets: [
        { name: 'dbconn', value: dbConnectionString }
      ]
      registries: [
        {
          server: 'myacr.azurecr.io'
          identity: 'system'                  // WHY: use managed identity, not password
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'api'
          image: 'myacr.azurecr.io/api:latest'
          resources: { cpu: json('0.5'), memory: '1Gi' }
          env: [
            { name: 'DB_CONN', secretRef: 'dbconn' }
            { name: 'ASPNETCORE_ENVIRONMENT', value: 'Production' }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 20
        rules: [
          {
            name: 'http-scaling'
            http: { metadata: { concurrentRequests: '50' } }
          }
        ]
      }
    }
  }
}
```

### Dapr Integration — Pub/Sub with Service Bus
```csharp
// Program.cs — enable Dapr sidecar
builder.Services.AddControllers().AddDapr();   // WHY: registers DaprClient + CloudEvents

// Publishing an event via Dapr (abstracts broker)
[ApiController]
public class OrderController : ControllerBase
{
    private readonly DaprClient _dapr;
    public OrderController(DaprClient dapr) => _dapr = dapr;

    [HttpPost("orders")]
    public async Task<IActionResult> CreateOrder(CreateOrderRequest req)
    {
        var order = new Order(Guid.NewGuid(), req.Items);

        // Dapr routes this to whatever pub/sub component is configured
        // (Service Bus, Redis, Kafka — swap without code change)
        await _dapr.PublishEventAsync(
            pubsubName: "servicebus",           // component name in dapr/components/
            topicName: "orders",
            data: order);

        return Accepted(order);
    }
}

// Subscribing via Dapr topic
[Topic("servicebus", "orders")]                // maps to dapr subscription
[HttpPost("orders-processor")]
public async Task<IActionResult> ProcessOrder(Order order)
{
    // process order
    return Ok();
}
```

```yaml
# dapr/components/pubsub.yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: servicebus
spec:
  type: pubsub.azure.servicebus.topics
  version: v1
  metadata:
    - name: connectionString
      secretKeyRef:
        name: sb-secret
        key: connectionString
```

### .NET SDK — Deploy & Manage Programmatically
```csharp
// NuGet: Azure.ResourceManager.AppContainers
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.AppContainers;

var credential = new DefaultAzureCredential();
var client = new ArmClient(credential);

// Get container app
var app = client
    .GetSubscriptionResource(new ResourceIdentifier($"/subscriptions/{subId}"))
    .GetResourceGroup("rg-prod")
    .GetContainerApp("api-service");

// Get all revisions
await foreach (var revision in app.GetContainerAppRevisions().GetAllAsync())
{
    Console.WriteLine($"{revision.Data.Name}: {revision.Data.TrafficWeight}%");
}

// Activate/deactivate revision
var revisionResource = await app.GetContainerAppRevision("api-service--v2").GetAsync();
await revisionResource.Value.ActivateRevisionAsync();
```

### Key Interview Q&A

**Q: Container Apps vs AKS — when do you choose each?**
```
Container Apps:
✓ Microservices / event-driven apps
✓ Unknown/spiky traffic (scale-to-zero)
✓ No K8s expertise in team
✓ Dapr-based service mesh
✗ Cannot run DaemonSets, CRDs, custom admission controllers
✗ Less control over node pools, GPU nodes

AKS:
✓ Complex workloads (stateful apps, GPU, Windows containers)
✓ Need full K8s API surface
✓ Multi-tenant isolation via namespaces
✓ Existing K8s manifests / Helm charts
✗ More operational overhead
```

**Q: How does scaling work in Container Apps?**
> Built on **KEDA** (Kubernetes Event-Driven Autoscaling). Scale triggers include HTTP concurrent requests, Service Bus message count, Event Hub lag, CPU/memory, custom metrics via Prometheus. Scale-to-zero is possible for non-HTTP workloads.

**Q: What is a revision and why does it matter?**
> A revision is an **immutable, versioned snapshot** of your container app configuration. Every change that touches container image, env vars, or resource limits creates a new revision. With `activeRevisionsMode: Multiple`, you can split traffic between revisions — enabling blue-green or canary deployments without downtime.

**Q: How do you handle secrets in Container Apps?**
> Three tiers: (1) **Container Apps Secrets** — stored in the environment, referenced via `secretRef`; (2) **Key Vault references** — via Managed Identity + `@Microsoft.KeyVault(...)` notation; (3) **Dapr Secret Store** — abstracts the secret backend. Production preference: Key Vault with System Assigned Identity, no passwords in manifests.

---

## 2. Azure Service Bus — Advanced

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Service Bus = Post Office for Enterprise Apps    │
│  Queue = one recipient (point-to-point)                        │
│  Topic = magazine subscription (pub/sub, many recipients)      │
│  Session = dedicated mailbox per customer (ordered delivery)   │
│  Dead-Letter = return-to-sender shelf                          │
└─────────────────────────────────────────────────────────────────┘
```

### Queue vs Topic vs Subscription
```
Queue (Point-to-Point):
  Producer → [Q: orders] → Consumer
  One message = one consumer processes it

Topic + Subscriptions (Pub/Sub):
  Producer → [Topic: orders]
                 ├── Subscription: billing    → BillingService
                 ├── Subscription: inventory  → InventoryService
                 └── Subscription: audit      → AuditService
  One message = ALL subscriptions get a copy (with optional filters)

Session-enabled Queue (Ordered per Session):
  Producer → [Q: orders, session=customer-123] → Consumer holding session-123 lock
  Guarantees FIFO per session ID — perfect for customer order streams
```

### SDK — Sender & Receiver (Azure.Messaging.ServiceBus)
```csharp
// NuGet: Azure.Messaging.ServiceBus

// --- SENDER ---
await using var client = new ServiceBusClient(
    "myns.servicebus.windows.net",
    new DefaultAzureCredential());           // WHY: no connection string in prod

await using var sender = client.CreateSender("orders");

// Send single message
var message = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(order))
{
    MessageId = order.Id.ToString(),         // WHY: idempotency — dedup window 10 min
    CorrelationId = correlationId,           // WHY: distributed tracing
    SessionId = order.CustomerId.ToString(), // WHY: session ordering (if queue is session-enabled)
    TimeToLive = TimeSpan.FromHours(24),     // WHY: don't process stale orders
    ApplicationProperties =
    {
        ["OrderType"] = order.Type,          // WHY: used in subscription filters
        ["Priority"] = order.Priority
    }
};
await sender.SendMessageAsync(message);

// Send batch (efficient — single round-trip)
using var batch = await sender.CreateMessageBatchAsync();
foreach (var o in orders)
{
    var msg = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(o));
    if (!batch.TryAddMessage(msg))
    {
        await sender.SendMessagesAsync(batch);  // flush when full
        // reset batch and add current message
    }
}
await sender.SendMessagesAsync(batch);

// --- PROCESSOR (production pattern — handles receive loop, lock renewal, retries) ---
await using var processor = client.CreateProcessor("orders", new ServiceBusProcessorOptions
{
    MaxConcurrentCalls = 10,                 // WHY: control parallelism
    AutoCompleteMessages = false,            // WHY: manual control — complete only on success
    MaxAutoLockRenewalDuration = TimeSpan.FromMinutes(5)  // WHY: long-running tasks
});

processor.ProcessMessageAsync += async args =>
{
    try
    {
        var order = args.Message.Body.ToObjectFromJson<Order>();
        await ProcessOrderAsync(order);
        await args.CompleteMessageAsync(args.Message);  // WHY: removes from queue
    }
    catch (BusinessException ex)
    {
        // Known error — dead-letter with reason
        await args.DeadLetterMessageAsync(args.Message,
            deadLetterReason: "BusinessRuleViolation",
            deadLetterErrorDescription: ex.Message);
    }
    catch (TransientException)
    {
        // Let retry policy handle it — message goes back with incremented DeliveryCount
        await args.AbandonMessageAsync(args.Message);
    }
};

processor.ProcessErrorAsync += args =>
{
    _logger.LogError(args.Exception, "Service Bus processor error: {Source}", args.ErrorSource);
    return Task.CompletedTask;
};

await processor.StartProcessingAsync();
```

### Session-Aware Processor (Ordered Processing)
```csharp
// WHY: sessions guarantee FIFO per SessionId — critical for stateful workflows
await using var sessionProcessor = client.CreateSessionProcessor("orders-session",
    new ServiceBusSessionProcessorOptions
    {
        MaxConcurrentSessions = 8,            // 8 sessions processed in parallel
        MaxConcurrentCallsPerSession = 1,     // 1 message at a time per session (FIFO)
        SessionIdleTimeout = TimeSpan.FromSeconds(30)
    });

sessionProcessor.ProcessMessageAsync += async args =>
{
    // args.SessionId is always set — messages within same session are sequential
    var order = args.Message.Body.ToObjectFromJson<Order>();

    // Optionally read/write session state (durable per-session storage)
    var state = await args.GetSessionStateAsync();
    var context = state != null
        ? JsonSerializer.Deserialize<SessionContext>(state.ToArray())
        : new SessionContext();

    await ProcessOrderAsync(order, context);
    context.LastProcessedId = order.Id;
    await args.SetSessionStateAsync(
        BinaryData.FromObjectAsJson(context));

    await args.CompleteMessageAsync(args.Message);
};
```

### Topic Filters & Subscriptions
```csharp
// Create SQL filter subscription — only high-priority orders
var adminClient = new ServiceBusAdministrationClient(connectionString);

await adminClient.CreateSubscriptionAsync(
    new CreateSubscriptionOptions("orders", "high-priority"),
    new CreateRuleOptions
    {
        Name = "HighPriorityFilter",
        Filter = new SqlRuleFilter("Priority = 'High' AND OrderType <> 'Test'"),
        Action = new SqlRuleAction("SET sys.label = 'urgent'")  // modify message
    });

// Correlation filter (much faster than SQL — O(1) hash lookup)
await adminClient.CreateRuleAsync("orders", "billing",
    new CreateRuleOptions
    {
        Filter = new CorrelationRuleFilter
        {
            ApplicationProperties = { ["OrderType"] = "Insurance" }
        }
    });
```

### Dead-Letter Queue Processing
```csharp
// DLQ path: "queuename/$DeadLetterQueue" or "topic/subscriptions/subname/$DeadLetterQueue"
await using var dlqReceiver = client.CreateReceiver(
    "orders",
    new ServiceBusReceiverOptions
    {
        SubQueue = SubQueue.DeadLetter,
        ReceiveMode = ServiceBusReceiveMode.PeekLock
    });

var dlqMessages = await dlqReceiver.ReceiveMessagesAsync(maxMessages: 100);
foreach (var msg in dlqMessages)
{
    var reason = msg.DeadLetterReason;
    var description = msg.DeadLetterErrorDescription;
    var deliveryCount = msg.DeliveryCount;

    _logger.LogWarning("DLQ: {Id} | Reason: {Reason} | Attempts: {Count}",
        msg.MessageId, reason, deliveryCount);

    // Reprocess or archive
    if (CanReprocess(reason))
    {
        await sender.SendMessageAsync(new ServiceBusMessage(msg));
        await dlqReceiver.CompleteMessageAsync(msg);
    }
}
```

### Key Interview Q&A

**Q: At-Least-Once vs At-Most-Once delivery?**
```
At-Least-Once (PeekLock — default):
  Message locked → process → Complete/Abandon
  Risk: duplicate processing if app crashes after process but before Complete
  Mitigation: idempotent handlers, MessageId-based dedup

At-Most-Once (ReceiveAndDelete):
  Message deleted on receive
  Risk: message lost if app crashes during processing
  Use when: log/analytics where occasional loss is acceptable
```

**Q: How do you prevent duplicate message processing?**
> (1) **Service Bus built-in dedup**: set `RequiresDuplicateDetection = true` + unique `MessageId` — 10-min dedup window. (2) **Idempotent handler**: check database before processing (`INSERT IF NOT EXISTS` with MessageId). (3) **Outbox pattern** for transactional guarantee.

**Q: When do you use sessions vs regular queues?**
> Sessions when you need **FIFO ordering per entity** (e.g., all events for customer-123 must be processed in order). Each session ID gets its own sequential mailbox. Regular queues for parallel, unordered processing where throughput matters.

**Q: How does message deferral work?**
> `DeferMessageAsync()` moves the message to a deferred state — it stays in the queue but won't be delivered by normal receive. You store the `SequenceNumber` and retrieve it later via `ReceiveDeferredMessageAsync(sequenceNumber)`. Use for out-of-order messages that depend on a predecessor.

---

## 3. SQL Server — Performance & Troubleshooting

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: SQL Performance = Data Access Path Optimization  │
│  Every query either SEEKS or SCANS                             │
│  Seek = index + key = O(log n) — FAST                         │
│  Scan = read every row = O(n) — SLOW at scale                 │
│  Your job: eliminate scans, verify with execution plans        │
└─────────────────────────────────────────────────────────────────┘
```

### Index Types & When to Use
```sql
-- Clustered Index: physical order of the table (1 per table)
-- Choose: monotonically increasing key (int identity, newsequentialid)
-- Never: newid() — causes page splits (fragmentation)
CREATE CLUSTERED INDEX CIX_Orders_Id ON Orders(OrderId);

-- Non-Clustered Index: separate B-tree pointing to clustered rows
CREATE NONCLUSTERED INDEX NIX_Orders_CustomerId
ON Orders(CustomerId)                          -- key column (seekable)
INCLUDE (Status, TotalAmount, CreatedAt);      -- WHY: covering index — avoids key lookup

-- Filtered Index: partial index for selective queries
CREATE NONCLUSTERED INDEX NIX_Orders_Pending
ON Orders(CreatedAt)
WHERE Status = 'Pending';                      -- WHY: 5% of rows — tiny, fast index

-- Columnstore Index: for analytics / aggregation (batch mode)
CREATE NONCLUSTERED COLUMNSTORE INDEX NCSI_Orders_Analytics
ON Orders(CustomerId, ProductId, Amount, OrderDate);

-- Composite Index — column order matters!
-- Rule: equality predicates first, range predicates last
-- Query: WHERE CustomerId = 1 AND OrderDate > '2024-01-01'
CREATE NONCLUSTERED INDEX NIX_Orders_Customer_Date
ON Orders(CustomerId, OrderDate);              -- CustomerId = equality, OrderDate = range
```

### Reading Execution Plans — Key Operators
```
SEEK    → Index used correctly, targeted rows fetched     ✅
SCAN    → Full table/index scan — investigate if table is large ⚠️
LOOKUP  → Key Lookup after non-clustered seek → add INCLUDE columns ⚠️
HASH JOIN → Large unsorted inputs, possible missing index ⚠️
NESTED LOOPS → OK for small outer input, many inner seeks ✅
SORT    → No supporting index for ORDER BY / GROUP BY → add index ⚠️
SPILL   → Sort/hash ran out of memory → grant more, tune query ❌

-- Cost threshold:
-- "Estimated Subtree Cost" > 5 in SSMS plan → investigate
-- "Actual Rows" >> "Estimated Rows" → statistics outdated → UPDATE STATISTICS
```

### DMVs — Production Troubleshooting Toolkit
```sql
-- TOP 10 most expensive queries by CPU
SELECT TOP 10
    qs.total_cpu_time / qs.execution_count AS avg_cpu_ms,
    qs.total_logical_reads / qs.execution_count AS avg_reads,
    qs.execution_count,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.text)
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS query_text,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY avg_cpu_ms DESC;

-- Missing index recommendations (SQL Server suggests)
SELECT TOP 20
    mid.statement AS table_name,
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    'CREATE INDEX IX_' + REPLACE(REPLACE(mid.statement,'.','_'),'[','') +
        ' ON ' + mid.statement + ' (' +
        ISNULL(mid.equality_columns,'') +
        CASE WHEN mid.inequality_columns IS NOT NULL
             THEN ',' + mid.inequality_columns ELSE '' END + ')' +
        ISNULL(' INCLUDE (' + mid.included_columns + ')','') AS create_index_statement
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY improvement_measure DESC;

-- Currently running queries with wait types
SELECT
    r.session_id, r.status, r.wait_type, r.wait_time, r.blocking_session_id,
    r.cpu_time, r.logical_reads, r.total_elapsed_time,
    SUBSTRING(t.text, (r.statement_start_offset/2)+1, 4000) AS current_statement
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50 AND r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;

-- Index fragmentation (fragmentation > 30% → rebuild; 10-30% → reorganize)
SELECT
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10 AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Blocking chain
SELECT
    blocking_session_id AS blocker,
    session_id AS blocked,
    wait_type, wait_time,
    SUBSTRING(t.text, 1, 500) AS blocked_query
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE blocking_session_id > 0;

-- Statistics age (rows modified since last update)
SELECT
    OBJECT_NAME(s.object_id) AS table_name,
    s.name AS stat_name,
    sp.last_updated,
    sp.rows, sp.rows_sampled, sp.modification_counter
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE sp.modification_counter > 1000
ORDER BY sp.modification_counter DESC;
```

### Query Optimization Patterns
```sql
-- ANTI-PATTERN: Function on indexed column → prevents seek
SELECT * FROM Orders WHERE YEAR(CreatedAt) = 2024;      -- BAD: scan

-- FIX: Sargable predicate
SELECT * FROM Orders
WHERE CreatedAt >= '2024-01-01' AND CreatedAt < '2025-01-01';  -- GOOD: seek

-- ANTI-PATTERN: Implicit conversion → type mismatch index scan
-- If OrderRef is VARCHAR but you pass NVARCHAR:
SELECT * FROM Orders WHERE OrderRef = N'ORD-001';        -- BAD: N prefix on varchar column

-- ANTI-PATTERN: SELECT * → over-fetches columns, invalidates covering indexes
SELECT * FROM Orders WHERE CustomerId = 1;              -- BAD

-- FIX: project only needed columns
SELECT OrderId, Status, TotalAmount FROM Orders WHERE CustomerId = 1;  -- GOOD

-- ANTI-PATTERN: OR on different columns → can't use single index
SELECT * FROM Orders WHERE CustomerId = 1 OR AgentId = 1;  -- BAD

-- FIX: UNION ALL (each branch can use its own index)
SELECT OrderId FROM Orders WHERE CustomerId = 1
UNION ALL
SELECT OrderId FROM Orders WHERE AgentId = 1 AND CustomerId <> 1;

-- Pagination — OFFSET/FETCH with covering index
SELECT OrderId, Status, CreatedAt
FROM Orders
WHERE CustomerId = @CustomerId
ORDER BY CreatedAt DESC
OFFSET (@Page - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;
-- Index: (CustomerId, CreatedAt DESC) INCLUDE (OrderId, Status)

-- Batch deletes — avoid long-running transactions + log bloat
DECLARE @Deleted INT = 1;
WHILE @Deleted > 0
BEGIN
    DELETE TOP (5000) FROM AuditLog WHERE CreatedAt < DATEADD(DAY, -90, GETUTCDATE());
    SET @Deleted = @@ROWCOUNT;
    WAITFOR DELAY '00:00:01';  -- yield to other transactions
END
```

### Common Wait Types & What They Mean
| Wait Type | Meaning | Fix |
|-----------|---------|-----|
| `ASYNC_NETWORK_IO` | Client reading results slowly | Reduce result set, streaming |
| `LCK_M_X` | Exclusive lock wait (blocking) | Shorter transactions, row-level locking |
| `PAGEIOLATCH_SH` | Reading from disk (cache miss) | Add RAM, fix missing indexes |
| `CXPACKET` | Parallelism wait (one thread waits) | Check MAXDOP, fix skew in data |
| `SOS_SCHEDULER_YIELD` | CPU-bound query yielding | Optimize query, add CPU |
| `WRITELOG` | Waiting to write to transaction log | Faster disk for log, batch writes |

### Key Interview Q&A

**Q: Query runs fine in dev but slow in prod — why?**
> (1) **Parameter sniffing**: cached plan optimized for different parameter values → `OPTION (RECOMPILE)` or `OPTIMIZE FOR UNKNOWN`. (2) **Statistics outdated** in prod (more data) → `UPDATE STATISTICS`. (3) **Data distribution skew** — dev has balanced test data, prod has 90% orders for one customer. (4) **Blocking/locking** in prod from concurrent users. (5) **Different indexes** — forgot to deploy.

**Q: How do you handle a 500M-row table?**
> (1) **Table Partitioning** on date column — partition elimination in queries. (2) **Columnstore index** for analytics. (3) **Archiving** old data to cold storage. (4) **Read replicas** for reporting. (5) **Covering indexes** to avoid table lookups. (6) Evaluate if this belongs in a different store (Cosmos DB, Data Lake).

**Q: NOLOCK hint — is it safe?**
> `NOLOCK` / `READ UNCOMMITTED` reads dirty (uncommitted) data — can return phantom rows, missing rows, or duplicate rows. It does NOT eliminate blocking, only lock acquisition. Use `READ COMMITTED SNAPSHOT ISOLATION (RCSI)` instead — readers don't block writers, no dirty reads. Enable at database level: `ALTER DATABASE db SET READ_COMMITTED_SNAPSHOT ON`.

---

## 4. Cosmos DB — Performance & Troubleshooting

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Cosmos DB = Distributed Hash Map at Global Scale │
│  Partition Key = the "hash key" — determines physical partition │
│  Everything fast within a partition (single server)            │
│  Cross-partition query = ask every server → expensive          │
│  Design rule: 80% of queries should include the partition key  │
└─────────────────────────────────────────────────────────────────┘
```

### Partition Key Design — The #1 Decision
```
Good Partition Keys:
✓ High cardinality (many distinct values)
✓ Even distribution of reads AND writes
✓ Present in most query predicates
✓ Immutable (can't change after insert)

Examples:
  /customerId    — good if each customer has ~100 docs, millions of customers
  /orderId       — good if queries always filter by order
  /tenantId      — good for multi-tenant, each tenant has many docs

Bad Partition Keys:
✗ /status       — only 3-5 values → hot partition
✗ /country      — skewed (US has 10x more than others)
✗ /isActive     — boolean → only 2 partitions
✗ /createdDate  — if ingesting thousands per second → single hot partition

Synthetic Partition Key (when no single good key exists):
  "partitionKey": "${customerId}_${year}"   // spread while keeping some grouping

Hierarchical Partition Keys (preview, up to 3 levels):
  /tenantId / /customerId / /category      // logical hierarchy
```

### SDK — CRUD Operations (.NET)
```csharp
// NuGet: Microsoft.Azure.Cosmos (v3)

// Setup (singleton — expensive to create)
var client = new CosmosClient(
    accountEndpoint: "https://myaccount.documents.azure.com:443/",
    tokenCredential: new DefaultAzureCredential(),
    new CosmosClientOptions
    {
        SerializerOptions = new CosmosSerializationOptions
        {
            PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase
        },
        ConnectionMode = ConnectionMode.Direct,        // WHY: lower latency than Gateway
        MaxRetryAttemptsOnRateLimitedRequests = 9,    // WHY: handle 429 TooManyRequests
        MaxRetryWaitTimeOnRateLimitedRequests = TimeSpan.FromSeconds(30)
    });

var container = client.GetContainer("mydb", "orders");

// Point read (most efficient — O(1), ~1ms, ~1 RU)
var response = await container.ReadItemAsync<Order>(
    id: orderId,
    partitionKey: new PartitionKey(customerId));

Console.WriteLine($"RU consumed: {response.RequestCharge}");  // always log RU!

// Create
var order = new Order { Id = Guid.NewGuid().ToString(), CustomerId = "c-123" };
var createResponse = await container.CreateItemAsync(
    order,
    new PartitionKey(order.CustomerId));

// Upsert (create or replace)
await container.UpsertItemAsync(order, new PartitionKey(order.CustomerId));

// Patch (partial update — avoid reading whole doc to update one field)
await container.PatchItemAsync<Order>(
    id: orderId,
    partitionKey: new PartitionKey(customerId),
    patchOperations: new[]
    {
        PatchOperation.Set("/status", "Completed"),
        PatchOperation.Set("/completedAt", DateTime.UtcNow),
        PatchOperation.Increment("/retryCount", 1)
    });

// Query within partition (fast — single partition)
var query = new QueryDefinition(
    "SELECT * FROM c WHERE c.customerId = @customerId AND c.status = @status")
    .WithParameter("@customerId", customerId)
    .WithParameter("@status", "Pending");

var iterator = container.GetItemQueryIterator<Order>(
    query,
    requestOptions: new QueryRequestOptions
    {
        PartitionKey = new PartitionKey(customerId),  // WHY: pin to partition
        MaxItemCount = 100
    });

double totalRU = 0;
while (iterator.HasMoreResults)
{
    var page = await iterator.ReadNextAsync();
    totalRU += page.RequestCharge;
    foreach (var item in page) { /* process */ }
}

// Bulk operations (high throughput ingestion)
var tasks = items.Select(item =>
    container.UpsertItemAsync(item, new PartitionKey(item.PartitionKey))
        .ContinueWith(t => t.Result.RequestCharge));

var charges = await Task.WhenAll(tasks);
// Note: enable AllowBulkExecution in CosmosClientOptions for true bulk
```

### Change Feed — Real-time Event Streaming
```csharp
// Change Feed Processor — tracks position in lease container
var processor = container
    .GetChangeFeedProcessorBuilder<Order>(
        processorName: "order-projector",
        onChangesDelegate: HandleChangesAsync)
    .WithInstanceName("instance-1")
    .WithLeaseContainer(leaseContainer)
    .WithMaxItems(50)
    .WithPollInterval(TimeSpan.FromSeconds(5))
    .Build();

await processor.StartAsync();

static async Task HandleChangesAsync(
    ChangeFeedProcessorContext context,
    IReadOnlyCollection<Order> changes,
    CancellationToken ct)
{
    foreach (var order in changes)
    {
        // Project to read model, push to Event Grid, sync to SQL
        await ProjectOrderAsync(order);
    }
}
```

### Indexing Policy Optimization
```json
// Default: all properties indexed → high RU on writes, flexible reads
// Optimized: index only queried properties
{
  "indexingMode": "consistent",
  "includedPaths": [
    { "path": "/customerId/?" },
    { "path": "/status/?" },
    { "path": "/createdAt/?" }
  ],
  "excludedPaths": [
    { "path": "/*" },             // exclude everything by default
    { "path": "/\"_etag\"/?" }
  ],
  "compositeIndexes": [
    [
      { "path": "/customerId", "order": "ascending" },
      { "path": "/createdAt", "order": "descending" }   // ORDER BY support
    ]
  ]
}
```

### RU Optimization Strategies
```
Write optimization:
  → Reduce indexed properties (fewer paths in indexingPolicy)
  → Use Patch instead of Replace (partial update)
  → Batch via Transactional Batch (same partition, atomic)
  → Use bulk mode for ingestion

Read optimization:
  → Always include partitionKey in queries
  → Prefer point reads (id + partitionKey) over queries
  → Add composite indexes for ORDER BY
  → Use continuation tokens for pagination (not OFFSET)
  → Cache frequently read reference data

Hot partition detection:
  → Metrics → "Normalized RU Consumption by PartitionKeyRangeId"
  → One range consistently at 100% → hot partition → re-design key
```

### Transactional Batch (same partition)
```csharp
var batch = container.CreateTransactionalBatch(new PartitionKey(customerId));
batch.CreateItem(order);
batch.CreateItem(orderLine1);
batch.CreateItem(orderLine2);
batch.PatchItem(cartId, new[] { PatchOperation.Set("/status", "Converted") });

using var response = await batch.ExecuteAsync();
if (!response.IsSuccessStatusCode)
{
    // Entire batch rolled back — check response[i].StatusCode for each op
    throw new Exception($"Batch failed: {response.ErrorMessage}");
}
```

### Key Interview Q&A

**Q: How do you choose between Cosmos DB and SQL Server?**
```
Choose Cosmos DB when:
✓ Global distribution required (multi-region writes)
✓ Document model (variable schema, nested objects)
✓ Extreme scale (>10K RU/s sustained)
✓ Schema-less or rapidly evolving data model
✓ Event sourcing / change feed patterns

Choose SQL Server when:
✓ Complex joins and relational integrity
✓ ACID transactions across multiple entities
✓ Ad-hoc reporting, analytics with aggregations
✓ Team expertise in SQL
✓ Smaller scale (<500K records)
```

**Q: What happens when you cross partition boundaries in a query?**
> Fan-out query: Cosmos DB sends the query to every physical partition, runs it in parallel, and merges results. RU cost multiplies by number of partitions. ORDER BY across partitions requires merge sort. Aggregates like COUNT(*) are supported but expensive. Avoid cross-partition queries in hot paths.

**Q: How do you handle schema evolution in Cosmos DB?**
> (1) **Additive changes**: just add new properties — existing docs don't break. (2) **Breaking changes**: use document versioning (`"schemaVersion": 2`), migrate via Change Feed processor. (3) **Polymorphism**: use a `type` discriminator field, read model handles both old and new shape. SDK handles missing properties as null.

---

## 5. Integration Testing — .NET

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Integration Tests = Reality Check                │
│  Unit test: "does this method work in isolation?"              │
│  Integration test: "does the whole slice work together?"       │
│  Use real DB, real HTTP pipeline, mock only external services  │
│  Goal: catch wiring bugs that unit tests miss                  │
└─────────────────────────────────────────────────────────────────┘
```

### WebApplicationFactory — Full HTTP Pipeline Testing
```csharp
// NuGet: Microsoft.AspNetCore.Mvc.Testing, xunit

// Custom factory — override services for testing
public class ApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    private readonly PostgreSqlContainer _db = new PostgreSqlBuilder()
        .WithDatabase("testdb")
        .WithUsername("test")
        .WithPassword("test")
        .Build();

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove real DB registration
            services.RemoveAll<DbContextOptions<AppDbContext>>();
            services.RemoveAll<AppDbContext>();

            // Use test container DB
            services.AddDbContext<AppDbContext>(opts =>
                opts.UseNpgsql(_db.GetConnectionString()));

            // Replace external HTTP client with mock
            services.AddHttpClient<IPaymentGateway, PaymentGateway>()
                .ConfigurePrimaryHttpMessageHandler(() =>
                    new MockPaymentHandler());

            // Replace outbox publisher with fake
            services.AddSingleton<IEventPublisher, FakeEventPublisher>();
        });
    }

    public async Task InitializeAsync()
    {
        await _db.StartAsync();

        // Apply migrations
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.MigrateAsync();
    }

    public new async Task DisposeAsync()
    {
        await _db.DisposeAsync();
        await base.DisposeAsync();
    }
}
```

### Test Class — Shared Factory (Collection Fixture)
```csharp
// Shared factory across ALL tests in the collection (one container start)
[CollectionDefinition("Api")]
public class ApiCollection : ICollectionFixture<ApiFactory> { }

[Collection("Api")]
public class OrderTests : IAsyncLifetime
{
    private readonly HttpClient _client;
    private readonly ApiFactory _factory;

    public OrderTests(ApiFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", GenerateTestJwt());
    }

    [Fact]
    public async Task CreateOrder_ValidRequest_Returns201WithOrderId()
    {
        // Arrange
        var request = new CreateOrderRequest
        {
            CustomerId = "c-test-1",
            Items = [new OrderItem("SKU-001", 2, 29.99m)]
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/orders", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);

        var order = await response.Content.ReadFromJsonAsync<OrderResponse>();
        order.Should().NotBeNull();
        order!.Id.Should().NotBeEmpty();
        order.Status.Should().Be("Pending");

        // Verify DB state
        await VerifyDatabaseAsync(order.Id, "Pending");
    }

    [Fact]
    public async Task CreateOrder_DuplicateIdempotencyKey_Returns200SameOrder()
    {
        // Arrange
        var idempotencyKey = Guid.NewGuid().ToString();
        var request = new CreateOrderRequest { CustomerId = "c-test-2" };

        // Act — send twice with same idempotency key
        var r1 = await _client.PostAsJsonAsync("/api/orders", request,
            headers: [("Idempotency-Key", idempotencyKey)]);
        var r2 = await _client.PostAsJsonAsync("/api/orders", request,
            headers: [("Idempotency-Key", idempotencyKey)]);

        // Assert
        var o1 = await r1.Content.ReadFromJsonAsync<OrderResponse>();
        var o2 = await r2.Content.ReadFromJsonAsync<OrderResponse>();
        o1!.Id.Should().Be(o2!.Id);  // same order returned
    }

    public async Task InitializeAsync() =>
        await _factory.ResetDatabaseAsync();  // clean state per test class

    public Task DisposeAsync() => Task.CompletedTask;
}
```

### TestContainers — Spin Up Real Dependencies
```csharp
// NuGet: Testcontainers, Testcontainers.MsSql, Testcontainers.Redis

public class InfrastructureFixture : IAsyncLifetime
{
    public MsSqlContainer Sql { get; } = new MsSqlBuilder()
        .WithPassword("P@ssw0rd123")
        .Build();

    public RedisContainer Redis { get; } = new RedisBuilder().Build();

    public ServiceBusContainer ServiceBus { get; } =
        new ServiceBusBuilder()
            .WithQueue("orders")
            .Build();

    public async Task InitializeAsync()
    {
        // Start all containers in parallel
        await Task.WhenAll(
            Sql.StartAsync(),
            Redis.StartAsync(),
            ServiceBus.StartAsync());
    }

    public async Task DisposeAsync()
    {
        await Task.WhenAll(
            Sql.DisposeAsync().AsTask(),
            Redis.DisposeAsync().AsTask(),
            ServiceBus.DisposeAsync().AsTask());
    }
}
```

### Respawn — Database Reset Between Tests
```csharp
// NuGet: Respawn — resets DB to clean state faster than dropping/recreating
public class ApiFactory : WebApplicationFactory<Program>
{
    private Respawner _respawner = default!;
    private DbConnection _connection = default!;

    public async Task ResetDatabaseAsync()
    {
        await _connection.OpenAsync();
        await _respawner.ResetAsync(_connection);
        await _connection.CloseAsync();
    }

    public async Task InitializeAsync()
    {
        await _db.StartAsync();
        _connection = new NpgsqlConnection(_db.GetConnectionString());
        _respawner = await Respawner.CreateAsync(_connection, new RespawnerOptions
        {
            DbAdapter = DbAdapter.Postgres,
            TablesToIgnore = ["__EFMigrationsHistory"]
        });
    }
}
```

### Fake Event Publisher — Capture Published Events
```csharp
public class FakeEventPublisher : IEventPublisher
{
    private readonly ConcurrentBag<object> _published = new();

    public Task PublishAsync<T>(T @event, CancellationToken ct = default)
    {
        _published.Add(@event!);
        return Task.CompletedTask;
    }

    public IEnumerable<T> GetPublished<T>() => _published.OfType<T>();
    public void Clear() => _published.Clear();
}

// In test:
[Fact]
public async Task CreateOrder_ShouldPublishOrderCreatedEvent()
{
    var publisher = _factory.Services.GetRequiredService<IEventPublisher>() as FakeEventPublisher;

    await _client.PostAsJsonAsync("/api/orders", request);

    var events = publisher!.GetPublished<OrderCreatedEvent>();
    events.Should().ContainSingle(e => e.CustomerId == "c-test-1");
}
```

### Key Interview Q&A

**Q: Unit test vs Integration test — when do you use each?**
```
Unit tests:
✓ Business logic, domain rules
✓ Pure functions, calculations
✓ Edge cases, error paths
✓ Fast feedback loop (ms per test)
✗ Don't test DB queries, HTTP routing, middleware

Integration tests:
✓ API endpoints end-to-end
✓ EF Core queries against real DB
✓ Middleware pipeline (auth, validation)
✓ Service Bus consumer handlers
✗ Slower (seconds), not for every case
```

**Q: How do you avoid test interdependence?**
> (1) **Respawn** database between test classes. (2) **Generate unique test data** per test (random IDs). (3) **Don't share mutable state** in factories. (4) Mark tests `[Collection("Api")]` with one factory instance but reset DB state per class. (5) Avoid relying on insertion order.

**Q: How do you test Service Bus consumers?**
> Inject a real (test container) or fake Service Bus. For unit testing the handler: pass a `ServiceBusReceivedMessage` created via `ServiceBusModelFactory.ServiceBusReceivedMessage(...)`. For integration: use Testcontainers with Azure Service Bus emulator or use `ServiceBusAdministrationClient` against a real dev namespace.

---

## 6. Modular Monolith Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Modular Monolith = Microservices in One Process │
│  Strong module boundaries enforced at compile time             │
│  Modules communicate via in-process messaging, not HTTP        │
│  Can extract a module to a service when needed                 │
│  "Deploy as one, design as many"                               │
└─────────────────────────────────────────────────────────────────┘
```

### Architecture Diagram
```
┌──────────────────────────────────────────────────────────────────┐
│                     ASP.NET Core Host                            │
│                                                                  │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────────────┐ │
│  │  Orders      │  │  Billing      │  │  Notifications       │ │
│  │  Module      │  │  Module       │  │  Module              │ │
│  │              │  │               │  │                      │ │
│  │  - Domain    │  │  - Domain     │  │  - Domain            │ │
│  │  - AppLayer  │  │  - AppLayer   │  │  - AppLayer          │ │
│  │  - Infra     │  │  - Infra      │  │  - Infra             │ │
│  │  - API       │  │  - API        │  │  - API               │ │
│  └──────┬───────┘  └──────┬────────┘  └──────────┬───────────┘ │
│         │  In-Process     │  MediatR               │            │
│         └─────────────────┴────────────────────────┘            │
│                    Internal Event Bus                            │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Shared Kernel (no business logic)                         │ │
│  │  - Common interfaces, base classes                        │ │
│  │  - Shared infrastructure (logging, auth)                  │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

### Module Structure — Each Module is Self-Contained
```
src/
├── Modules/
│   ├── Orders/
│   │   ├── Orders.Domain/
│   │   │   ├── Order.cs
│   │   │   ├── OrderLine.cs
│   │   │   └── IOrderRepository.cs
│   │   ├── Orders.Application/
│   │   │   ├── Commands/CreateOrderCommand.cs
│   │   │   ├── Queries/GetOrderQuery.cs
│   │   │   └── Events/OrderCreatedEvent.cs      ← internal domain event
│   │   ├── Orders.Infrastructure/
│   │   │   ├── OrderRepository.cs               ← only this module sees its own DB tables
│   │   │   └── OrdersDbContext.cs
│   │   └── Orders.API/
│   │       ├── OrdersController.cs
│   │       └── OrdersModule.cs                  ← registration entry point
│   │
│   └── Billing/
│       ├── Billing.Domain/
│       ├── Billing.Application/
│       │   └── Handlers/OrderCreatedHandler.cs  ← handles Orders event
│       ├── Billing.Infrastructure/
│       └── Billing.API/
│
├── SharedKernel/
│   ├── IDomainEvent.cs
│   ├── IEventBus.cs
│   └── Result.cs
└── Host/
    └── Program.cs
```

### Module Registration (IModuleInstaller Pattern)
```csharp
// Each module exposes a single registration method
public interface IModuleInstaller
{
    void Install(IServiceCollection services, IConfiguration configuration);
}

// Orders module
public class OrdersModule : IModuleInstaller
{
    public void Install(IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<OrdersDbContext>(opts =>
            opts.UseSqlServer(configuration.GetConnectionString("Orders")));

        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(OrdersModule).Assembly));
    }
}

// Host — discover and register all modules
// Program.cs
var modules = Assembly.GetExecutingAssembly()
    .GetReferencedAssemblies()
    .SelectMany(a => Assembly.Load(a).GetTypes())
    .Where(t => typeof(IModuleInstaller).IsAssignableFrom(t) && !t.IsInterface)
    .Select(Activator.CreateInstance)
    .Cast<IModuleInstaller>();

foreach (var module in modules)
    module.Install(builder.Services, builder.Configuration);
```

### Cross-Module Communication — In-Process Event Bus
```csharp
// Domain event (defined in Orders module)
public record OrderCreatedEvent(Guid OrderId, string CustomerId, decimal Total)
    : IDomainEvent;

// Billing module handles it — via MediatR INotificationHandler
public class ChargeCustomerOnOrderCreated
    : INotificationHandler<OrderCreatedEvent>
{
    private readonly IBillingService _billing;

    public async Task Handle(OrderCreatedEvent notification, CancellationToken ct)
    {
        await _billing.ChargeAsync(notification.CustomerId, notification.Total, ct);
    }
}

// In Orders domain service — publish the event
public class OrderService
{
    private readonly IPublisher _publisher;  // MediatR IPublisher

    public async Task<Order> CreateOrderAsync(CreateOrderCommand cmd)
    {
        var order = Order.Create(cmd.CustomerId, cmd.Items);
        await _repository.SaveAsync(order);

        // In-process — same transaction, immediate delivery
        await _publisher.Publish(new OrderCreatedEvent(
            order.Id, order.CustomerId, order.Total));

        return order;
    }
}
```

### Enforcing Module Boundaries — Architecture Tests
```csharp
// NuGet: NetArchTest.Rules — enforce boundaries at CI
[Fact]
public void BillingModule_ShouldNotReference_OrdersInfrastructure()
{
    var result = Types
        .InAssembly(typeof(BillingModule).Assembly)
        .ShouldNot()
        .HaveDependencyOn("Orders.Infrastructure")
        .GetResult();

    result.IsSuccessful.Should().BeTrue(
        "Billing should not access Orders database directly");
}

[Fact]
public void Modules_ShouldOnlyCommunicate_ViaSharedKernel()
{
    var moduleAssemblies = new[] { "Orders", "Billing", "Notifications" };

    foreach (var module in moduleAssemblies)
    {
        var others = moduleAssemblies.Except([module]);
        foreach (var other in others)
        {
            Types.InNamespace($"{module}.Infrastructure")
                .ShouldNot()
                .HaveDependencyOn($"{other}.Infrastructure")
                .GetResult()
                .IsSuccessful.Should().BeTrue();
        }
    }
}
```

### Modular Monolith vs Microservices vs Monolith
| Dimension | Monolith | Modular Monolith | Microservices |
|-----------|----------|-----------------|---------------|
| Deployment | Single | Single | Per service |
| DB | Shared schema | Separate schema per module | Separate DB per service |
| Communication | Direct call | In-process events | HTTP/gRPC/queue |
| Complexity | Low | Medium | High |
| Scalability | Whole app | Whole app | Per service |
| Best for | MVP / small teams | Growing teams, unclear boundaries | Large teams, proven boundaries |

### Key Interview Q&A

**Q: How does a modular monolith differ from a clean architecture monolith?**
> Clean Architecture is about **layer boundaries** (Domain → Application → Infrastructure). Modular Monolith is about **domain/feature boundaries** — each module is a vertical slice with its own layers. A modular monolith can use clean architecture within each module.

**Q: How do you prevent modules from sharing database tables?**
> (1) Separate `DbContext` per module (different schema prefix: `orders.*`, `billing.*`). (2) Architecture tests (NetArchTest) that verify no cross-module EF `DbSet` access. (3) Each module owns migrations for its schema. (4) Read-only projections if one module needs another's data.

**Q: When would you extract a module into a microservice?**
> When: (1) Module needs independent scaling (e.g., report generation is CPU-heavy). (2) Module needs a different deployment cadence. (3) Team ownership requires isolation. (4) Module would benefit from a different technology stack. The modular design makes extraction safer — the interface/event contracts are already defined.

---

## 7. Distributed vs In-Memory Cache

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL:                                                  │
│  In-Memory = sticky note on YOUR desk — fast, private, lost   │
│              when you leave                                     │
│  Distributed = whiteboard in shared office — slightly slower, │
│                everyone sees it, survives restarts             │
│                                                                 │
│  Rule: If you have >1 instance, you NEED distributed cache    │
└─────────────────────────────────────────────────────────────────┘
```

### Comparison Table
| Aspect | IMemoryCache | IDistributedCache (Redis) |
|--------|-------------|--------------------------|
| Scope | Single process | All instances |
| Speed | ~microseconds (RAM) | ~1ms (network + Redis) |
| Size limit | Limited by process RAM | Redis cluster (TBs) |
| Persistence | Lost on restart | Configurable (RDB/AOF) |
| Invalidation | Only local | Pub/sub across instances |
| Consistency | No cross-instance | Eventual (single Redis) |
| Cost | Free (RAM) | Redis service cost |
| When to use | Single instance, ref data | Multi-instance, user sessions, distributed locks |

### IMemoryCache — In-Process Cache
```csharp
// Registration
builder.Services.AddMemoryCache();

// Usage
public class ProductService
{
    private readonly IMemoryCache _cache;
    private static readonly string CacheKey = "products:all";

    public async Task<IReadOnlyList<Product>> GetAllAsync(CancellationToken ct)
    {
        return await _cache.GetOrCreateAsync(CacheKey, async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5);
            entry.SlidingExpiration = TimeSpan.FromMinutes(2);  // reset TTL on access
            entry.Priority = CacheItemPriority.High;            // WHY: survive memory pressure
            entry.RegisterPostEvictionCallback((key, value, reason, state) =>
                _logger.LogInformation("Cache evicted: {Key}, reason: {Reason}", key, reason));

            return await _db.Products.AsNoTracking().ToListAsync(ct);
        })!;
    }

    // Manual invalidation
    public void InvalidateProducts() => _cache.Remove(CacheKey);
}
```

### IDistributedCache — Redis
```csharp
// Registration
builder.Services.AddStackExchangeRedisCache(opts =>
{
    opts.Configuration = "myredis.redis.cache.windows.net:6380,password=...,ssl=True";
    opts.InstanceName = "myapp:";   // WHY: prefix all keys to avoid collision
});

// Low-level: IDistributedCache (byte[])
public class SessionRepository
{
    private readonly IDistributedCache _cache;

    public async Task SetSessionAsync(string sessionId, UserSession session)
    {
        var bytes = JsonSerializer.SerializeToUtf8Bytes(session);
        await _cache.SetAsync(
            $"session:{sessionId}",
            bytes,
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1),
                SlidingExpiration = TimeSpan.FromMinutes(20)
            });
    }

    public async Task<UserSession?> GetSessionAsync(string sessionId)
    {
        var bytes = await _cache.GetAsync($"session:{sessionId}");
        return bytes is null
            ? null
            : JsonSerializer.Deserialize<UserSession>(bytes);
    }
}
```

### StackExchange.Redis — Direct (Higher Control)
```csharp
// NuGet: StackExchange.Redis
// Register as singleton — connection is expensive
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
    ConnectionMultiplexer.Connect(new ConfigurationOptions
    {
        EndPoints = { "myredis.redis.cache.windows.net:6380" },
        Password = "...",
        Ssl = true,
        ConnectRetry = 5,
        AbortOnConnectFail = false,     // WHY: don't crash on startup if Redis is down
        ReconnectRetryPolicy = new LinearRetry(500)
    }));

public class RedisRepository
{
    private readonly IDatabase _db;

    public RedisRepository(IConnectionMultiplexer redis)
        => _db = redis.GetDatabase();

    // String (most common)
    await _db.StringSetAsync("key", "value", TimeSpan.FromMinutes(5));
    var val = await _db.StringGetAsync("key");

    // Hash (user profile — field-level access)
    await _db.HashSetAsync("user:123", new HashEntry[]
    {
        new("name", "Alice"),
        new("email", "alice@example.com"),
        new("plan", "premium")
    });
    var name = await _db.HashGetAsync("user:123", "name");

    // List (queue, leaderboard)
    await _db.ListLeftPushAsync("notifications:user:123", JsonSerializer.Serialize(notification));
    var notifs = await _db.ListRangeAsync("notifications:user:123", 0, 9);  // top 10

    // Set (unique visitors, tags)
    await _db.SetAddAsync("visitors:2024-01-01", userId);
    var count = await _db.SetLengthAsync("visitors:2024-01-01");

    // Sorted Set (leaderboard)
    await _db.SortedSetAddAsync("leaderboard", playerId, score);
    var top10 = await _db.SortedSetRangeByRankWithScoresAsync("leaderboard", 0, 9, Order.Descending);

    // Distributed Lock (Redlock pattern)
    var lockKey = $"lock:order:{orderId}";
    var lockValue = Guid.NewGuid().ToString();
    var acquired = await _db.StringSetAsync(lockKey, lockValue, TimeSpan.FromSeconds(30), When.NotExists);

    if (acquired)
    {
        try { /* critical section */ }
        finally
        {
            // Release only if we still own the lock (Lua script for atomicity)
            var script = @"if redis.call('get', KEYS[1]) == ARGV[1] then
                               return redis.call('del', KEYS[1])
                           else return 0 end";
            await _db.ScriptEvaluateAsync(script, new RedisKey[] { lockKey }, new RedisValue[] { lockValue });
        }
    }
}
```

### Cache Patterns
```csharp
// Cache-Aside (most common)
public async Task<Product> GetProductAsync(int id)
{
    var cached = await _cache.GetAsync<Product>($"product:{id}");
    if (cached is not null) return cached;

    var product = await _db.Products.FindAsync(id);
    if (product is not null)
        await _cache.SetAsync($"product:{id}", product, TimeSpan.FromMinutes(10));

    return product!;
}

// Write-Through (write to cache and DB simultaneously)
public async Task UpdateProductAsync(Product product)
{
    await _db.Products.UpdateAsync(product);
    await _db.SaveChangesAsync();
    await _cache.SetAsync($"product:{product.Id}", product, TimeSpan.FromMinutes(10));
}

// Cache stampede prevention — single-flight pattern
private static readonly ConcurrentDictionary<string, SemaphoreSlim> _locks = new();

public async Task<T> GetOrCreateWithLockAsync<T>(string key, Func<Task<T>> factory)
{
    var cached = await _cache.GetAsync<T>(key);
    if (cached is not null) return cached;

    var semaphore = _locks.GetOrAdd(key, _ => new SemaphoreSlim(1, 1));
    await semaphore.WaitAsync();
    try
    {
        // Double-check after acquiring lock
        cached = await _cache.GetAsync<T>(key);
        if (cached is not null) return cached;

        var result = await factory();
        await _cache.SetAsync(key, result, TimeSpan.FromMinutes(5));
        return result;
    }
    finally
    {
        semaphore.Release();
    }
}
```

### Key Interview Q&A

**Q: What happens if you use IMemoryCache with multiple replicas?**
> Cache inconsistency. Instance A caches product price $10. Instance B updates price to $15 and clears its own cache. Instance A still serves $10 until its TTL expires. If a user's requests round-robin between A and B, they see different prices. **Solution**: use Redis (IDistributedCache) or use `IMemoryCache` only for truly global reference data with short TTL.

**Q: How do you invalidate related cache entries?**
> (1) **Key patterns + SCAN**: prefix keys (`products:*`), use Redis SCAN + DEL — never KEYS in prod (blocks). (2) **Cache tags** (via extension libs). (3) **Event-driven invalidation**: on product update, publish event → all instances clear their in-memory cache via Redis pub/sub. (4) **Short TTL** — accept eventual consistency.

**Q: What is cache stampede and how do you prevent it?**
> When a popular cache key expires, thousands of requests simultaneously hit the DB. Fixes: (1) **Mutex/Lock**: only one request refills cache. (2) **Probabilistic early expiration**: proactively refresh before expiry. (3) **Stale-while-revalidate**: serve stale data while refreshing in background. (4) **Jitter**: add random offset to TTL to avoid simultaneous expiry.

---

## 8. React.js — Core to Advanced

```
┌─────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: React = Reactive View Layer                      │
│  State changes → React re-renders → Virtual DOM diff → DOM     │
│  Components = functions that return JSX (UI description)       │
│  Hooks = functions that tap into React's lifecycle             │
│  "UI is a function of state: UI = f(state)"                   │
└─────────────────────────────────────────────────────────────────┘
```

### Core Hooks — Detailed
```tsx
import React, { useState, useEffect, useCallback, useMemo, useRef, useContext } from 'react';

// --- useState: local component state ---
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);

// Functional update (safe when new state depends on old)
setCount(prev => prev + 1);  // WHY: avoids stale closure bug in async

// Object state — always spread, never mutate
setUser(prev => ({ ...prev!, name: 'Alice' }));

// --- useEffect: side effects (data fetching, subscriptions, DOM manipulation) ---
// Dependency array controls WHEN effect runs:
// []     → run once on mount (like componentDidMount)
// [dep]  → run when dep changes
// none   → run after every render (rare — usually wrong)

useEffect(() => {
    const controller = new AbortController();  // WHY: cancel on unmount

    async function fetchUser() {
        try {
            const res = await fetch(`/api/users/${id}`, { signal: controller.signal });
            const data = await res.json();
            setUser(data);
        } catch (e) {
            if (e instanceof Error && e.name !== 'AbortError') setError(e);
        }
    }

    fetchUser();

    return () => controller.abort();  // WHY: cleanup — prevent setState on unmounted
}, [id]);  // re-fetch when id changes

// --- useCallback: memoize function reference (prevent child re-renders) ---
const handleSubmit = useCallback(async (formData: FormData) => {
    await submitOrder(formData);
}, [submitOrder]);  // only recreate when submitOrder changes
// WHY: if passed to React.memo child, stable reference prevents re-render

// --- useMemo: memoize expensive computation ---
const filteredOrders = useMemo(
    () => orders.filter(o => o.status === activeFilter && o.total > minAmount),
    [orders, activeFilter, minAmount]  // WHY: only recompute when these change
);
// WHY: filter on 10K orders is expensive — don't redo every render

// --- useRef: mutable value without triggering re-render ---
const timerRef = useRef<NodeJS.Timeout | null>(null);
const inputRef = useRef<HTMLInputElement>(null);

// Access DOM element
inputRef.current?.focus();

// Store previous value
function usePrevious<T>(value: T): T | undefined {
    const ref = useRef<T>();
    useEffect(() => { ref.current = value; }, [value]);
    return ref.current;
}
```

### Custom Hooks — Reusable Logic
```tsx
// useFetch — generic data fetching hook
function useFetch<T>(url: string) {
    const [data, setData] = useState<T | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<Error | null>(null);

    useEffect(() => {
        const controller = new AbortController();
        setLoading(true);

        fetch(url, { signal: controller.signal })
            .then(r => r.json() as Promise<T>)
            .then(setData)
            .catch(e => { if (e.name !== 'AbortError') setError(e); })
            .finally(() => setLoading(false));

        return () => controller.abort();
    }, [url]);

    return { data, loading, error };
}

// useLocalStorage — persist state across refreshes
function useLocalStorage<T>(key: string, initialValue: T) {
    const [stored, setStored] = useState<T>(() => {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : initialValue;
        } catch { return initialValue; }
    });

    const setValue = (value: T | ((prev: T) => T)) => {
        const toStore = value instanceof Function ? value(stored) : value;
        setStored(toStore);
        localStorage.setItem(key, JSON.stringify(toStore));
    };

    return [stored, setValue] as const;
}

// useDebounce — delay fast inputs (search, autocomplete)
function useDebounce<T>(value: T, delay: number): T {
    const [debounced, setDebounced] = useState(value);
    useEffect(() => {
        const timer = setTimeout(() => setDebounced(value), delay);
        return () => clearTimeout(timer);
    }, [value, delay]);
    return debounced;
}

// Usage
const SearchBar = () => {
    const [query, setQuery] = useState('');
    const debouncedQuery = useDebounce(query, 300);
    const { data: results } = useFetch(`/api/search?q=${debouncedQuery}`);
    // ...
};
```

### Context API — Global State Without Redux
```tsx
// Auth context
interface AuthContextType {
    user: User | null;
    login: (credentials: Credentials) => Promise<void>;
    logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

// Custom hook — prevents null check in consumers
export function useAuth() {
    const ctx = useContext(AuthContext);
    if (!ctx) throw new Error('useAuth must be used within AuthProvider');
    return ctx;
}

export function AuthProvider({ children }: { children: ReactNode }) {
    const [user, setUser] = useState<User | null>(null);

    const login = useCallback(async (credentials: Credentials) => {
        const response = await fetch('/api/auth/login', {
            method: 'POST',
            body: JSON.stringify(credentials),
            headers: { 'Content-Type': 'application/json' }
        });
        const { user, token } = await response.json();
        localStorage.setItem('token', token);
        setUser(user);
    }, []);

    const logout = useCallback(() => {
        localStorage.removeItem('token');
        setUser(null);
    }, []);

    return (
        <AuthContext.Provider value={{ user, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
}

// Consumer
function ProfileButton() {
    const { user, logout } = useAuth();
    return <button onClick={logout}>Logout {user?.name}</button>;
}
```

### React Query (TanStack Query) — Server State Management
```tsx
// NuGet: @tanstack/react-query — handles loading, caching, re-fetching, background sync
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Setup
const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            staleTime: 5 * 60 * 1000,   // 5 min — don't refetch if data is fresh
            retry: 2,
            refetchOnWindowFocus: false   // disable for admin apps
        }
    }
});

// Query — fetch and cache
function OrderList({ customerId }: { customerId: string }) {
    const { data: orders, isLoading, error } = useQuery({
        queryKey: ['orders', customerId],    // cache key — refetch if key changes
        queryFn: () => fetchOrders(customerId),
        enabled: !!customerId                // WHY: don't fetch if no customerId
    });

    if (isLoading) return <Spinner />;
    if (error) return <ErrorMessage error={error} />;
    return <ul>{orders?.map(o => <OrderItem key={o.id} order={o} />)}</ul>;
}

// Mutation — create/update/delete with cache invalidation
function CreateOrderForm() {
    const queryClient = useQueryClient();

    const mutation = useMutation({
        mutationFn: (order: CreateOrderRequest) =>
            fetch('/api/orders', { method: 'POST', body: JSON.stringify(order) }).then(r => r.json()),

        onSuccess: (newOrder) => {
            // Invalidate — triggers refetch of order lists
            queryClient.invalidateQueries({ queryKey: ['orders'] });

            // OR: optimistic update — add to cache immediately
            queryClient.setQueryData<Order[]>(['orders', newOrder.customerId], prev =>
                prev ? [...prev, newOrder] : [newOrder]);
        },

        onError: (error) => toast.error(`Failed: ${error.message}`)
    });

    return (
        <form onSubmit={e => {
            e.preventDefault();
            mutation.mutate({ customerId: 'c-1', items: [] });
        }}>
            <button disabled={mutation.isPending}>
                {mutation.isPending ? 'Creating...' : 'Create Order'}
            </button>
        </form>
    );
}
```

### Performance Optimization
```tsx
// React.memo — prevent re-render if props unchanged
const OrderItem = React.memo(({ order }: { order: Order }) => {
    return <div>{order.id} - {order.status}</div>;
    // WHY: if parent re-renders but order prop didn't change, skip re-render
}, (prev, next) => prev.order.id === next.order.id && prev.order.status === next.order.status);
// Second arg = custom comparison (default: shallow equality)

// Code splitting — lazy load routes
const OrderDashboard = lazy(() => import('./pages/OrderDashboard'));

function App() {
    return (
        <Suspense fallback={<PageSpinner />}>
            <Routes>
                <Route path="/orders" element={<OrderDashboard />} />
            </Routes>
        </Suspense>
    );
}

// Virtual list — render only visible items (10K+ rows)
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualOrderList({ orders }: { orders: Order[] }) {
    const parentRef = useRef<HTMLDivElement>(null);
    const virtualizer = useVirtualizer({
        count: orders.length,
        getScrollElement: () => parentRef.current,
        estimateSize: () => 60   // estimated row height
    });

    return (
        <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
            <div style={{ height: virtualizer.getTotalSize() }}>
                {virtualizer.getVirtualItems().map(item => (
                    <div key={item.key} style={{ transform: `translateY(${item.start}px)` }}>
                        <OrderRow order={orders[item.index]} />
                    </div>
                ))}
            </div>
        </div>
    );
}
```

### State Management — When to Use What
```
Local state (useState):
✓ UI state (modal open, tab selection)
✓ Form field values
✓ Component-specific loading/error

Context API:
✓ Auth/user info (read frequently, changed rarely)
✓ Theme, locale
✓ Data passed through 3+ levels of components
✗ High-frequency updates (causes all consumers to re-render)

React Query / SWR:
✓ Server state (API data)
✓ Caching, background refetch, pagination
✓ Mutations with cache invalidation
✓ Best practice for 90% of "global state" needs

Zustand / Redux Toolkit:
✓ Complex client-side state (shopping cart, multi-step wizard)
✓ State shared across many unrelated components
✓ Undo/redo, time-travel debugging (Redux DevTools)
✗ Don't use for server data — use React Query instead
```

### Zustand — Lightweight State Management
```tsx
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface CartStore {
    items: CartItem[];
    addItem: (item: CartItem) => void;
    removeItem: (id: string) => void;
    total: () => number;
    clear: () => void;
}

const useCartStore = create<CartStore>()(
    persist(
        (set, get) => ({
            items: [],
            addItem: (item) => set(state => ({
                items: state.items.find(i => i.id === item.id)
                    ? state.items.map(i => i.id === item.id ? { ...i, qty: i.qty + 1 } : i)
                    : [...state.items, { ...item, qty: 1 }]
            })),
            removeItem: (id) => set(state => ({
                items: state.items.filter(i => i.id !== id)
            })),
            total: () => get().items.reduce((sum, i) => sum + i.price * i.qty, 0),
            clear: () => set({ items: [] })
        }),
        { name: 'cart-storage' }   // WHY: persist to localStorage automatically
    )
);

// Usage — no Provider needed
function CartIcon() {
    const count = useCartStore(state => state.items.length);  // selective subscribe
    return <Badge count={count} />;
}
```

### TypeScript + React — Practical Patterns
```tsx
// Component props
interface OrderCardProps {
    order: Order;
    onSelect?: (id: string) => void;    // optional callback
    className?: string;
}

// Generic component
function DataTable<T extends { id: string }>({
    data, columns, onRowClick
}: {
    data: T[];
    columns: Column<T>[];
    onRowClick?: (row: T) => void;
}) { /* ... */ }

// Event handler types
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) =>
    setValue(e.target.value);

const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    /* ... */
};

// Discriminated union for API states
type AsyncState<T> =
    | { status: 'idle' }
    | { status: 'loading' }
    | { status: 'success'; data: T }
    | { status: 'error'; error: Error };

function useAsync<T>(asyncFn: () => Promise<T>) {
    const [state, setState] = useState<AsyncState<T>>({ status: 'idle' });

    const execute = useCallback(async () => {
        setState({ status: 'loading' });
        try {
            const data = await asyncFn();
            setState({ status: 'success', data });
        } catch (error) {
            setState({ status: 'error', error: error as Error });
        }
    }, [asyncFn]);

    return { state, execute };
}
```

### Key Interview Q&A

**Q: What is the Virtual DOM and why does React use it?**
> React keeps a lightweight JavaScript tree (Virtual DOM) mirroring the real DOM. On state change, React creates a new Virtual DOM tree, diffs it against the previous (reconciliation), and applies **only the minimal set of real DOM mutations**. Direct DOM manipulation is slow; batch-computing changes in memory then applying them is faster.

**Q: When does a component re-render?**
> (1) Its own `setState` is called. (2) Its parent re-renders (unless wrapped in `React.memo`). (3) A context it consumes changes. (4) A hook it uses (custom hook with internal state) changes. Fix unnecessary re-renders with `React.memo`, `useCallback`, `useMemo`, and selective context subscriptions.

**Q: useEffect cleanup — why is it important?**
> Without cleanup: subscriptions, timers, and async requests continue running after the component unmounts → memory leaks and setting state on unmounted components (React warning). Return a cleanup function: `return () => { subscription.unsubscribe(); controller.abort(); clearTimeout(timer); }`.

**Q: How do you handle concurrent state updates safely?**
> Use **functional updates**: `setCount(prev => prev + 1)` instead of `setCount(count + 1)`. The functional form always receives the latest state value, even inside closures created at different times. For complex state transitions, use `useReducer` which batches updates and gives you a pure reducer function.

**Q: React.memo vs useMemo vs useCallback?**
```
React.memo(Component)  → memoize component render (skip if props same)
useMemo(() => value)   → memoize computed value (skip recomputation)
useCallback(() => fn)  → memoize function reference (stable ref for deps/props)

All three: comparison via Object.is() (shallow equality for objects/arrays)
```

**Q: What is React Query and why use it over useEffect for data fetching?**
> React Query manages **server state**: automatic caching, background refetching, stale-while-revalidate, deduplication of simultaneous requests, pagination, optimistic updates, and loading/error states. `useEffect` for data fetching has known pitfalls: race conditions, no caching, no automatic retry, manual loading state management. React Query solves all of these declaratively.

---

## Quick Reference Decision Trees

### Cache Choice
```
Multiple instances? ──Yes──→ Redis (IDistributedCache)
       │
      No
       │
Session/user data? ──Yes──→ Redis (shared across requests)
       │
      No
       │
Reference data, short TTL? ──Yes──→ IMemoryCache (fast, simple)
       │
      No
       ↓
Evaluate CDN or response caching
```

### Container Apps vs AKS
```
Need Kubernetes primitives (DaemonSet, CRD, GPU)? ──Yes──→ AKS
       │
      No
       │
Event-driven / scale-to-zero? ──Yes──→ Container Apps
       │
      No
       │
Microservices with Dapr? ──Yes──→ Container Apps
       │
      No
       ↓
Either works — choose by team K8s expertise
```

### React State
```
Is it server data? ──Yes──→ React Query
       │
      No
       │
Shared across many components? ──Yes──→ Zustand or Context
       │
      No
       │
Local UI state? ──Yes──→ useState / useReducer
```

---

*Guide Date: 2026-03-05 | Level: Lead / Senior Developer*
