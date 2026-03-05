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

---

### Terraform — Azure Container Apps (IaC)
```hcl
# main.tf — Container Apps environment + app

terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.90" }
  }
}

provider "azurerm" {
  features {}
}

# ── Variables ────────────────────────────────────────────────────
variable "resource_group" { default = "rg-myapp-prod" }
variable "location"       { default = "eastus2" }
variable "acr_login_server" { description = "e.g. myacr.azurecr.io" }
variable "image_tag"        { default = "latest" }

# ── Resource Group ────────────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

# ── Log Analytics (required by Container Apps environment) ────────
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-myapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ── Container Apps Environment ────────────────────────────────────
resource "azurerm_container_app_environment" "env" {
  name                       = "cae-myapp-prod"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  # WHY workload_profile: enables Dedicated tier for consistent CPU (not Consumption)
  workload_profile {
    name                  = "Warm"
    workload_profile_type = "D4"   # 4 CPU, 8 GB RAM per instance
    minimum_count         = 1
    maximum_count         = 5
  }
}

# ── Container App ────────────────────────────────────────────────
resource "azurerm_container_app" "api" {
  name                         = "ca-api-service"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Multiple"   # WHY: enables traffic splitting / canary

  identity {
    type = "SystemAssigned"                   # WHY: managed identity for Key Vault / ACR
  }

  # Registry credentials via managed identity (no passwords)
  registry {
    server   = var.acr_login_server
    identity = "System"
  }

  template {
    min_replicas = 1
    max_replicas = 10

    container {
      name   = "api"
      image  = "${var.acr_login_server}/api-service:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name        = "ConnectionStrings__Default"
        secret_name = "db-connection-string"    # references secret defined below
      }
      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
    }

    # ── KEDA HTTP scaling rule ──────────────────────────────────
    http_scale_rule {
      name                = "http-scaler"
      concurrent_requests = "100"    # scale up when >100 concurrent requests per replica
    }
  }

  # ── Ingress ───────────────────────────────────────────────────
  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "http"

    traffic_weight {
      label           = "current"
      latest_revision = true
      percentage      = 100
    }
  }

  # ── Secrets (stored in Container Apps — reference Key Vault in prod) ──
  secret {
    name  = "db-connection-string"
    value = "Server=...;Initial Catalog=mydb;..."
  }
}

# ── Outputs ──────────────────────────────────────────────────────
output "container_app_url" {
  value = azurerm_container_app.api.ingress[0].fqdn
}
output "managed_identity_principal_id" {
  value = azurerm_container_app.api.identity[0].principal_id
}
```
```bash
# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Update image tag (zero-downtime rolling update)
terraform apply -var="image_tag=v2.3.1"
```

---

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

### ServiceBusMessage — Complete Property Reference

```csharp
// Every settable property on ServiceBusMessage explained:
var message = new ServiceBusMessage(body: BinaryData.FromObjectAsJson(order))
{
    // ── IDENTITY ──────────────────────────────────────────────────────────
    MessageId = order.Id.ToString(),
    // WHY: String (max 128 chars). Used for duplicate detection (dedup window
    //      set on queue/topic: RequiresDuplicateDetection = true).
    //      Service Bus discards a message with same MessageId within the window.
    //      If not set: Service Bus assigns a random GUID. Always set it yourself
    //      so you control idempotency.

    CorrelationId = Activity.Current?.TraceId.ToString() ?? Guid.NewGuid().ToString(),
    // WHY: Free-form string. Use for distributed tracing (pass W3C trace ID).
    //      Also usable in CorrelationRuleFilter subscription filters.

    // ── ROUTING ───────────────────────────────────────────────────────────
    SessionId = order.CustomerId.ToString(),
    // WHY: Enables session-based FIFO. Only valid if queue/topic has
    //      RequiresSession = true. Messages with same SessionId go to
    //      the same consumer in order. Leave null for non-session queues.

    ReplyTo = "orders-reply-queue",
    // WHY: Request/Reply pattern. Receiver knows which queue to send response to.
    //      Consumer reads this and sends reply to that queue.

    ReplyToSessionId = correlationId,
    // WHY: Pair with ReplyTo in request/reply when reply queue is session-enabled.
    //      Lets requester filter for its specific reply.

    To = "billing-service",
    // WHY: Informational routing hint. Not used by Service Bus for routing
    //      (subscriptions/filters do that). Useful for logging/tracing.

    Subject = "OrderCreated",
    // WHY: Formerly called "Label". Short human-readable event name.
    //      Appears in portal message browser. Can be used in SqlRuleFilter:
    //      Filter = new SqlRuleFilter("sys.subject = 'OrderCreated'")

    // ── TIMING ────────────────────────────────────────────────────────────
    TimeToLive = TimeSpan.FromHours(24),
    // WHY: Message expires after this duration. Expired messages go to DLQ
    //      if the queue has DeadLetteringOnMessageExpiration = true.
    //      If not set: inherits queue/topic default TTL.
    //      Use to prevent processing stale orders.

    ScheduledEnqueueTime = DateTimeOffset.UtcNow.AddMinutes(30),
    // WHY: Message won't be visible in queue until this time.
    //      Perfect for: reminder notifications, delayed retries,
    //      future-scheduled jobs. Stored as "scheduled" state, not in flight.
    //      Cancel with: await sender.CancelScheduledMessageAsync(sequenceNumber)

    // ── CONTENT ───────────────────────────────────────────────────────────
    ContentType = "application/json",
    // WHY: MIME type of the body. Not enforced by Service Bus (informational).
    //      Helps consumers know how to deserialize the body.
    //      Standards: "application/json", "application/xml", "text/plain"

    // ── CUSTOM APPLICATION PROPERTIES ─────────────────────────────────────
    ApplicationProperties =
    {
        ["OrderType"]   = order.Type,       // string
        ["Priority"]    = order.Priority,   // string
        ["Amount"]      = order.Total,      // double (not decimal — not supported)
        ["IsRetry"]     = false,            // bool
        ["RetryCount"]  = 0,                // int
        // WHY: Used in SqlRuleFilter and CorrelationRuleFilter on subscriptions.
        //      Supported types: string, int, long, double, bool, DateTime, Guid.
        //      ⚠️ decimal is NOT supported — use double.
        //      ⚠️ Max 64 properties, total < 64 KB including body.
    }
};
```

---

### Receive Modes — PeekLock vs ReceiveAndDelete

```csharp
// ── MODE 1: PeekLock (default — at-least-once) ──────────────────────────────
// Message stays in queue, locked for you. You must Settle it.
await using var receiver = client.CreateReceiver("orders",
    new ServiceBusReceiverOptions
    {
        ReceiveMode = ServiceBusReceiveMode.PeekLock,   // default
        PrefetchCount = 10  // WHY: pre-fetch 10 msgs from broker to local buffer.
                            //      Reduces round trips. Set to MaxConcurrentCalls.
    });

var msg = await receiver.ReceiveMessageAsync(maxWaitTime: TimeSpan.FromSeconds(5));
if (msg != null)
{
    try
    {
        await ProcessAsync(msg.Body.ToObjectFromJson<Order>());
        await receiver.CompleteMessageAsync(msg);   // ← DELETE from queue
    }
    catch (BusinessException ex)
    {
        await receiver.DeadLetterMessageAsync(msg,  // ← move to DLQ
            deadLetterReason: "BusinessRuleViolation",
            deadLetterErrorDescription: ex.Message);
    }
    catch (TransientException)
    {
        await receiver.AbandonMessageAsync(msg);    // ← return to queue, increment DeliveryCount
    }
}
// If you do NOTHING: lock expires → message returns to queue automatically.
// Lock duration set on queue (default 60s). Renew with:
// await receiver.RenewMessageLockAsync(msg);  // for long-running processing

// ── MODE 2: ReceiveAndDelete (at-most-once) ──────────────────────────────────
// Message immediately DELETED from queue on receive. No settlement needed.
await using var receiver2 = client.CreateReceiver("orders",
    new ServiceBusReceiverOptions
    {
        ReceiveMode = ServiceBusReceiveMode.ReceiveAndDelete
        // ⚠️ If your process crashes after receive but before processing:
        //    message is LOST — no recovery. No Complete/Abandon methods available.
        // USE WHEN: telemetry, audit logs, analytics events where loss is acceptable.
    });

var msg2 = await receiver2.ReceiveMessageAsync();
if (msg2 != null)
{
    await ProcessAsync(msg2.Body.ToObjectFromJson<Order>());
    // No settlement call needed — already deleted on receive
}
```

---

### ServiceBusReceiver — Direct Pull Methods (vs Processor)

```csharp
// WHY USE RECEIVER DIRECTLY (vs Processor)?
// Processor = push-based, continuous background loop (long-running service)
// Receiver = pull-based, you control when/how many to receive (batch jobs, CLI tools)

await using var receiver = client.CreateReceiver("orders");

// ── Receive single message (with timeout) ────────────────────────────────────
ServiceBusReceivedMessage? msg =
    await receiver.ReceiveMessageAsync(maxWaitTime: TimeSpan.FromSeconds(10));
// Returns null if queue empty after timeout. Does NOT throw if empty.

// ── Receive a batch ──────────────────────────────────────────────────────────
IReadOnlyList<ServiceBusReceivedMessage> batch =
    await receiver.ReceiveMessagesAsync(
        maxMessages: 20,                        // upper bound (may get fewer)
        maxWaitTime: TimeSpan.FromSeconds(5));   // returns early if queue drains

foreach (var m in batch)
{
    await ProcessAsync(m);
    await receiver.CompleteMessageAsync(m);
}

// ── Peek without consuming (non-destructive inspection) ──────────────────────
// Peek does NOT lock the message — another consumer can still receive it.
// Use for: monitoring, debugging, admin tools.
IReadOnlyList<ServiceBusReceivedMessage> peeked =
    await receiver.PeekMessagesAsync(maxMessages: 10);

foreach (var m in peeked)
{
    Console.WriteLine($"Seq:{m.SequenceNumber} | Id:{m.MessageId} | Enqueued:{m.EnqueuedTime}");
    // ⚠️ Cannot Complete/Abandon a peeked message — it has no lock token.
}

// Peek from a specific sequence number (for paging through queue):
var peekedPage2 = await receiver.PeekMessagesAsync(
    maxMessages: 10,
    fromSequenceNumber: peeked.Last().SequenceNumber + 1);

// ── Renew lock (for long-running processing) ─────────────────────────────────
// Default lock duration on queue = 60s. Renew before it expires.
var lockRenewalTask = Task.Run(async () =>
{
    while (!processingComplete)
    {
        await Task.Delay(TimeSpan.FromSeconds(45));    // renew every 45s
        await receiver.RenewMessageLockAsync(msg!);   // extends by another lock duration
    }
});
```

---

### Message Deferral — Full Pattern

```csharp
// SCENARIO: OrderLine message arrives BEFORE its parent Order message.
//           Can't process OrderLine without Order. Defer it, process later.

await using var receiver = client.CreateReceiver("order-events");

// ── Step 1: Receive out-of-order message, defer it ───────────────────────────
var msg = await receiver.ReceiveMessageAsync();
if (msg != null && !await OrderExistsAsync(msg.ApplicationProperties["OrderId"].ToString()!))
{
    // Store the SequenceNumber — this is your "handle" to retrieve it later
    var sequenceNumber = msg.SequenceNumber;
    await _deferredStore.SaveAsync(
        key: $"deferred:{msg.ApplicationProperties["OrderId"]}",
        value: sequenceNumber.ToString());

    await receiver.DeferMessageAsync(msg,
        propertiesToModify: new Dictionary<string, object>
        {
            ["DeferredReason"] = "ParentOrderNotFound",  // custom tracking property
            ["DeferredAt"] = DateTimeOffset.UtcNow.ToString("O")
        });
    // Message state: Active → Deferred. Won't appear in normal receive.
    // It stays in queue indefinitely (subject to TTL).
}

// ── Step 2: Later, when Order arrives, retrieve the deferred OrderLine ────────
var order = await receiver.ReceiveMessageAsync();  // gets the parent Order
await ProcessOrderAsync(order);
await receiver.CompleteMessageAsync(order);

// Now retrieve all deferred messages waiting for this order:
var deferredSeqStr = await _deferredStore.GetAsync($"deferred:{order.MessageId}");
if (long.TryParse(deferredSeqStr, out var deferredSeq))
{
    // Must use same receiver (same queue) to retrieve deferred message
    var deferred = await receiver.ReceiveDeferredMessageAsync(deferredSeq);
    await ProcessOrderLineAsync(deferred);
    await receiver.CompleteMessageAsync(deferred);
    await _deferredStore.DeleteAsync($"deferred:{order.MessageId}");
}

// ── Retrieve multiple deferred messages ──────────────────────────────────────
var sequenceNumbers = new long[] { 1001L, 1005L, 1009L };
IReadOnlyList<ServiceBusReceivedMessage> deferredBatch =
    await receiver.ReceiveDeferredMessagesAsync(sequenceNumbers);
```

---

### Scheduled Messages

```csharp
// WHY: Enqueue a message that won't be visible until a future time.
// Use cases: send reminder email in 3 days, retry after backoff, future job.

await using var sender = client.CreateSender("notifications");

// ── Option A: ScheduledEnqueueTime on message ────────────────────────────────
var message = new ServiceBusMessage(BinaryData.FromObjectAsJson(reminder))
{
    ScheduledEnqueueTime = DateTimeOffset.UtcNow.AddDays(3),
    MessageId = $"reminder-{userId}-{appointmentId}"
};
await sender.SendMessageAsync(message);
// Message is in "Scheduled" state — not receivable until ScheduledEnqueueTime.

// ── Option B: ScheduleMessageAsync (returns cancellable sequence number) ──────
long sequenceNumber = await sender.ScheduleMessageAsync(
    message: new ServiceBusMessage(BinaryData.FromObjectAsJson(reminder))
    {
        MessageId = $"reminder-{userId}-{appointmentId}"
    },
    scheduledEnqueueTime: DateTimeOffset.UtcNow.AddDays(3));

// Store sequenceNumber if you might need to cancel:
await _reminderStore.SaveSequenceNumberAsync(userId, appointmentId, sequenceNumber);

// ── Cancel a scheduled message before it fires ────────────────────────────────
var seq = await _reminderStore.GetSequenceNumberAsync(userId, appointmentId);
await sender.CancelScheduledMessageAsync(seq);
// After cancel: message is deleted. If already fired (past time): throws exception.

// ── Schedule a batch ─────────────────────────────────────────────────────────
var sequenceNumbers = await sender.ScheduleMessagesAsync(
    messages: reminders.Select(r => new ServiceBusMessage(BinaryData.FromObjectAsJson(r))
    {
        ScheduledEnqueueTime = r.SendAt,
        MessageId = r.Id
    }),
    scheduledEnqueueTime: DateTimeOffset.UtcNow.AddHours(1));
// Note: all messages in batch get the SAME ScheduledEnqueueTime.
// For different times: schedule individually or use ApplicationProperties.
```

---

### ServiceBusAdministrationClient — Runtime Management

```csharp
// WHY: Programmatically create/update queues, topics, subscriptions, rules.
// Also: inspect live queue state (message counts, sizes).
// NuGet: Azure.Messaging.ServiceBus (includes administration)

var adminClient = new ServiceBusAdministrationClient(
    "myns.servicebus.windows.net",
    new DefaultAzureCredential());

// ── Create Queue ─────────────────────────────────────────────────────────────
await adminClient.CreateQueueAsync(new CreateQueueOptions("orders")
{
    MaxSizeInMegabytes = 5120,                       // 5 GB queue size
    DefaultMessageTimeToLive = TimeSpan.FromDays(7), // message TTL
    LockDuration = TimeSpan.FromSeconds(60),         // PeekLock duration
    MaxDeliveryCount = 10,                           // attempts before DLQ
    RequiresDuplicateDetection = true,
    DuplicateDetectionHistoryTimeWindow = TimeSpan.FromMinutes(10),
    RequiresSession = false,
    EnableDeadLetteringOnMessageExpiration = true,   // expired → DLQ
    AutoDeleteOnIdle = TimeSpan.FromDays(7),         // delete queue if idle 7 days
    EnablePartitioning = false                       // partitioning = higher throughput
});

// ── Create Topic + Subscriptions ─────────────────────────────────────────────
await adminClient.CreateTopicAsync(new CreateTopicOptions("orders-topic")
{
    MaxSizeInMegabytes = 5120,
    DefaultMessageTimeToLive = TimeSpan.FromHours(24),
    EnablePartitioning = false
});

await adminClient.CreateSubscriptionAsync(
    new CreateSubscriptionOptions("orders-topic", "billing")
    {
        MaxDeliveryCount = 5,
        LockDuration = TimeSpan.FromSeconds(60),
        DeadLetteringOnMessageExpiration = true,
        // Auto-delete subscription if no receivers connected for N days:
        AutoDeleteOnIdle = TimeSpan.MaxValue
    },
    new CreateRuleOptions
    {
        Name = "BillingFilter",
        Filter = new SqlRuleFilter("OrderType IN ('Insurance','Pharmacy')"),
        Action = new SqlRuleAction("SET Priority = 'High'")  // modify on match
    });

// ── Get Queue Runtime Info (live message counts) ──────────────────────────────
QueueRuntimeProperties runtimeProps =
    await adminClient.GetQueueRuntimePropertiesAsync("orders");

Console.WriteLine($"Active messages:       {runtimeProps.ActiveMessageCount}");
Console.WriteLine($"Dead-letter messages:  {runtimeProps.DeadLetterMessageCount}");
Console.WriteLine($"Scheduled messages:    {runtimeProps.ScheduledMessageCount}");
Console.WriteLine($"Transferred to DLQ:    {runtimeProps.TransferDeadLetterMessageCount}");
Console.WriteLine($"Total message count:   {runtimeProps.TotalMessageCount}");
Console.WriteLine($"Size on disk:          {runtimeProps.SizeInBytes / 1024 / 1024} MB");
Console.WriteLine($"Created at:            {runtimeProps.CreatedAt}");
Console.WriteLine($"Last accessed:         {runtimeProps.AccessedAt}");

// ── Get Topic Subscription Runtime Info ──────────────────────────────────────
SubscriptionRuntimeProperties subProps =
    await adminClient.GetSubscriptionRuntimePropertiesAsync("orders-topic", "billing");
Console.WriteLine($"Billing subscription backlog: {subProps.ActiveMessageCount}");

// ── Check if queue exists, update settings ────────────────────────────────────
if (await adminClient.QueueExistsAsync("orders"))
{
    var queueProps = await adminClient.GetQueueAsync("orders");
    queueProps.Value.MaxDeliveryCount = 15;   // increase retry attempts
    await adminClient.UpdateQueueAsync(queueProps.Value);
}

// ── List all queues ────────────────────────────────────────────────────────────
await foreach (var queue in adminClient.GetQueuesAsync())
{
    Console.WriteLine($"{queue.Name} | MaxDelivery:{queue.MaxDeliveryCount} | Session:{queue.RequiresSession}");
}

// ── Add/Remove Rules on existing subscription ─────────────────────────────────
// Remove the default $Default rule (matches everything) first:
await adminClient.DeleteRuleAsync("orders-topic", "billing", "$Default");

// Add a correlation filter (faster than SQL filter — O(1) hash):
await adminClient.CreateRuleAsync("orders-topic", "billing",
    new CreateRuleOptions
    {
        Name = "CorrelationFilter",
        Filter = new CorrelationRuleFilter
        {
            CorrelationId = "order-created",
            ApplicationProperties = { ["Region"] = "US-East" }
        }
    });
```

---

### Retry Policy & Client Configuration

```csharp
// WHY: Transient errors (network blip, Service Bus throttling) are common.
// Configure retry policy at client level — applies to ALL operations.

var client = new ServiceBusClient(
    "myns.servicebus.windows.net",
    new DefaultAzureCredential(),
    new ServiceBusClientOptions
    {
        // ── Retry Policy ─────────────────────────────────────────────────
        RetryOptions = new ServiceBusRetryOptions
        {
            Mode = ServiceBusRetryMode.Exponential,
            // Exponential = 1s, 2s, 4s, 8s... (with jitter)
            // Fixed       = same delay each time

            MaxRetries = 5,
            // Total attempts = MaxRetries + 1 (initial try).
            // Applies to: Send, Receive, Complete, Abandon, etc.

            Delay = TimeSpan.FromSeconds(1),
            // Exponential: base delay (doubles each retry).
            // Fixed: constant delay between retries.

            MaxDelay = TimeSpan.FromSeconds(30),
            // Cap on exponential backoff. Won't wait longer than this.

            TryTimeout = TimeSpan.FromSeconds(60),
            // Timeout for a SINGLE attempt (before it fails and retries).
            // Set higher for slow networks or large messages.
        },

        // ── Transport ────────────────────────────────────────────────────
        TransportType = ServiceBusTransportType.AmqpWebSockets,
        // AmqpTcp (default): port 5671 — fastest, lowest latency.
        // AmqpWebSockets:    port 443 — use when port 5671 is blocked by firewall.
        //                    Corporate networks often block non-standard ports.

        // ── Connection ──────────────────────────────────────────────────
        // Idle timeout for AMQP connection — reconnects automatically after.
        // Default: no idle timeout (always-on connection).
    });

// ── Per-Operation Timeout (override retry for specific call) ─────────────────
var receiver = client.CreateReceiver("orders");
var msg = await receiver.ReceiveMessageAsync(
    maxWaitTime: TimeSpan.FromSeconds(30));
// maxWaitTime = how long to wait if queue is EMPTY. Not the same as RetryOptions.TryTimeout.
// Returns null if nothing arrives within maxWaitTime (no exception).

// ── Health Check (check namespace connectivity) ───────────────────────────────
// Pattern: try to get queue properties as a connectivity probe
try
{
    var adminClient = new ServiceBusAdministrationClient("myns.servicebus.windows.net", credential);
    var props = await adminClient.GetQueueAsync("orders");
    // Success → namespace is reachable and queue exists
    healthCheckResult = HealthCheckResult.Healthy($"Queue: {props.Value.Name}");
}
catch (ServiceBusException ex) when (ex.Reason == ServiceBusFailureReason.MessagingEntityNotFound)
{
    healthCheckResult = HealthCheckResult.Unhealthy("orders queue does not exist");
}
catch (Exception ex)
{
    healthCheckResult = HealthCheckResult.Unhealthy($"Service Bus unreachable: {ex.Message}");
}
```

---

### Transactional Send (Outbox Pattern)

```csharp
// WHY: Ensure a DB write and a message publish are atomic.
// If DB succeeds but message send fails → inconsistency.
// If message send succeeds but DB fails → inconsistency.
// Solution: Service Bus transactions (client-side, not distributed 2PC).

// ── Service Bus transaction: send to multiple entities atomically ─────────────
await using var sender1 = client.CreateSender("billing-queue");
await using var sender2 = client.CreateSender("inventory-queue");

// Start a transaction (scoped to single namespace — not cross-namespace!)
ServiceBusTransactionContext txContext;
using (var ts = new TransactionScope(TransactionScopeAsyncFlowOption.Enabled))
{
    txContext = await client.CreateTransactionAsync();   // returns a transaction handle

    await sender1.SendMessageAsync(billingMsg, txContext);
    await sender2.SendMessageAsync(inventoryMsg, txContext);

    ts.Complete();  // commit both sends atomically
}
// IMPORTANT: TransactionScope here manages the Service Bus transaction.
// This is NOT a DTC transaction — does NOT span SQL Server + Service Bus.

// ── True Outbox Pattern (DB + Service Bus eventual consistency) ───────────────
// 1. In same DB transaction: write order + write OutboxMessage row
// 2. Background job reads OutboxMessage, sends to Service Bus, marks as Sent
// This guarantees exactly-once publishing even if step 2 crashes and retries.

// Step 1 (in OrderService):
await using var dbTx = await _db.Database.BeginTransactionAsync();
_db.Orders.Add(order);
_db.OutboxMessages.Add(new OutboxMessage
{
    Id = Guid.NewGuid(),
    Payload = JsonSerializer.Serialize(new OrderCreatedEvent(order.Id, order.CustomerId)),
    EventType = nameof(OrderCreatedEvent),
    CreatedAt = DateTime.UtcNow,
    SentAt = null  // null = not yet published
});
await _db.SaveChangesAsync();
await dbTx.CommitAsync();  // ← DB transaction: order + outbox row committed together

// Step 2 (OutboxPublisher background service):
var pending = await _db.OutboxMessages
    .Where(m => m.SentAt == null)
    .OrderBy(m => m.CreatedAt)
    .Take(100)
    .ToListAsync();

foreach (var outboxMsg in pending)
{
    await _sender.SendMessageAsync(new ServiceBusMessage(outboxMsg.Payload)
    {
        MessageId = outboxMsg.Id.ToString(),   // WHY: dedup — safe to retry
        Subject = outboxMsg.EventType
    });
    outboxMsg.SentAt = DateTime.UtcNow;
}
await _db.SaveChangesAsync();   // mark as sent (idempotent — OK if duplicate)
```

---

### Processor vs Receiver — When to Use Which

```
┌────────────────────────┬────────────────────────────────────────────────────┐
│                        │ ServiceBusProcessor        ServiceBusReceiver       │
├────────────────────────┼────────────────────────────────────────────────────┤
│ Pattern                │ Push (continuous loop)     Pull (you control)       │
│ Use case               │ Long-running worker svc    Batch jobs, CLI tools    │
│ Concurrency            │ MaxConcurrentCalls=N       Manual Task.WhenAll      │
│ Lock renewal           │ Automatic                  Manual RenewMessageLock  │
│ Error handling         │ ProcessErrorAsync event    try/catch per message    │
│ Start/Stop             │ StartProcessingAsync()     Call ReceiveMessageAsync  │
│                        │ StopProcessingAsync()      when needed              │
│ Prefetch               │ PrefetchCount option       PrefetchCount option     │
│ Session support        │ CreateSessionProcessor()   CreateReceiver(session)  │
│ Graceful shutdown      │ StopProcessingAsync waits  Drain receive loop       │
│                        │ for in-flight to finish    with CancellationToken   │
└────────────────────────┴────────────────────────────────────────────────────┘

CHOOSE Processor when:
  - ASP.NET Core hosted service (IHostedService)
  - Need automatic lock renewal
  - Want managed concurrency (10 parallel handlers)
  - Production microservice consuming continuously

CHOOSE Receiver when:
  - Azure Function (has its own trigger framework)
  - Batch processing: drain queue at midnight, process, stop
  - CLI/admin tool: peek messages for debugging
  - Need fine-grained pull control (rate limiting)
  - Integration tests (receive & assert specific messages)
```

---

### Terraform — Azure Service Bus (IaC)
```hcl
# ── Service Bus Namespace + Queue + Topic + Subscription ─────────

resource "azurerm_servicebus_namespace" "sb" {
  name                = "sb-myapp-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"      # Standard = topics; Premium = VNet, private endpoints
  # For Premium:
  # sku              = "Premium"
  # premium_messaging_partitions = 1   # 1, 2, or 4
}

# ── Queue (point-to-point, single consumer) ──────────────────────
resource "azurerm_servicebus_queue" "orders" {
  name         = "orders-queue"
  namespace_id = azurerm_servicebus_namespace.sb.id

  max_delivery_count              = 10           # after 10 failures → dead-letter
  lock_duration                   = "PT1M"       # ISO 8601: 1 minute lock (PeekLock)
  default_message_time_to_live    = "P7D"        # messages expire after 7 days
  dead_lettering_on_message_expiration = true    # expired messages → DLQ
  requires_duplicate_detection    = true         # WHY: dedup within 10min window
  duplicate_detection_history_time_window = "PT10M"
  enable_partitioning             = false        # true = 16 partitions (Standard tier)
  requires_session                = false        # true = ordered per session
}

# ── Dead-Letter Queue is created automatically — no resource needed
# Access via: {queue_name}/$DeadLetterQueue

# ── Topic + Subscriptions (pub/sub, multiple consumers) ──────────
resource "azurerm_servicebus_topic" "order_events" {
  name         = "order-events"
  namespace_id = azurerm_servicebus_namespace.sb.id

  default_message_time_to_live = "P7D"
  requires_duplicate_detection = true
  duplicate_detection_history_time_window = "PT10M"
}

resource "azurerm_servicebus_subscription" "billing_sub" {
  name               = "billing-subscription"
  topic_id           = azurerm_servicebus_topic.order_events.id
  max_delivery_count = 10
  lock_duration      = "PT1M"
  dead_lettering_on_message_expiration = true
}

resource "azurerm_servicebus_subscription" "notifications_sub" {
  name               = "notifications-subscription"
  topic_id           = azurerm_servicebus_topic.order_events.id
  max_delivery_count = 10
  lock_duration      = "PT1M"
}

# ── SQL Filter on subscription (only specific messages) ──────────
resource "azurerm_servicebus_subscription_rule" "billing_filter" {
  name            = "high-value-orders"
  subscription_id = azurerm_servicebus_subscription.billing_sub.id
  filter_type     = "SqlFilter"
  sql_filter      = "OrderTotal > 1000 AND OrderType = 'Premium'"
  # WHY: billing only processes high-value premium orders via SQL filter
}

# ── Authorization Rule (Sender / Receiver RBAC) ───────────────────
resource "azurerm_servicebus_namespace_authorization_rule" "sender" {
  name         = "orders-sender"
  namespace_id = azurerm_servicebus_namespace.sb.id
  listen       = false
  send         = true
  manage       = false
}

resource "azurerm_servicebus_namespace_authorization_rule" "receiver" {
  name         = "orders-receiver"
  namespace_id = azurerm_servicebus_namespace.sb.id
  listen       = true
  send         = false
  manage       = false
}

output "servicebus_connection_string" {
  value     = azurerm_servicebus_namespace.sb.default_primary_connection_string
  sensitive = true
}
output "sender_connection_string" {
  value     = azurerm_servicebus_namespace_authorization_rule.sender.primary_connection_string
  sensitive = true
}
```

---

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

### Execution Plans — How They Work & How to Analyze Them

```
┌───────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Execution Plan = SQL Server's Recipe for Your Query│
│                                                                   │
│  You write SQL (WHAT you want).                                  │
│  The Query Optimizer writes the plan (HOW to get it).            │
│                                                                   │
│  Plan = a tree of operators. Data flows right → left.            │
│  Leaf nodes (rightmost) = data sources (tables, indexes).        │
│  Root node (leftmost) = final result returned to client.         │
│                                                                   │
│  Cost = optimizer's guess at resource usage (not real time).     │
│  Actual rows vs Estimated rows = accuracy of that guess.         │
└───────────────────────────────────────────────────────────────────┘
```

#### Step 1 — How to Get an Execution Plan

```sql
-- Option A: SSMS keyboard shortcuts
--   Ctrl+L         → Estimated plan (no query runs, instant)
--   Ctrl+M → then Ctrl+E  → Actual plan (query runs, real row counts)

-- Option B: T-SQL — Actual plan with statistics (for scripts/automation)
SET STATISTICS IO ON;      -- shows logical reads per table
SET STATISTICS TIME ON;    -- shows parse/compile/execute CPU + elapsed ms

SET STATISTICS PROFILE ON; -- text-based actual plan (each operator + row counts)

-- Option C: Get cached plan for a past query (from DMV — no re-run needed)
SELECT qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qs.sql_handle = <your_handle>;
-- The query_plan column is clickable XML in SSMS → opens graphical plan

-- Option D: EXPLAIN equivalent for quick text output
SET SHOWPLAN_TEXT ON;
GO
SELECT * FROM Orders WHERE CustomerId = 1;
GO
SET SHOWPLAN_TEXT OFF;
-- Output:
--   |--Nested Loops(Inner Join)
--       |--Index Seek(OBJECT:([Orders].[NIX_Orders_CustomerId]),
--                    SEEK:([CustomerId]=(1)) ORDERED FORWARD)
--       |--RID Lookup(OBJECT:([Orders]))
```

#### Step 2 — How to Read the Plan (Direction & Flow)

```
SSMS Graphical Plan — reading order:

  [SELECT]  ←  [Hash Match]  ←  [Sort]  ←  [Clustered Index Scan: Orders]
    root         join                           leaf = data source
    (result)     ↑                              (reads from here first)
                 [Index Seek: Customers]  ←── another leaf

  Arrow direction: data flows RIGHT → LEFT (leaves to root).
  Arrow THICKNESS: proportional to row count flowing through that pipe.
                   Thin arrow after a Seek = few rows (good).
                   Thick arrow after a Scan = many rows (investigate).

  Node SIZE in SSMS: proportional to relative cost % of that operator.
                     Large node = expensive step = fix this first.

  Reading order for analysis:
    1. Find the WIDEST arrow (most rows flowing = most work)
    2. Find the LARGEST node (highest % cost)
    3. Check Seeks vs Scans on leaf nodes
    4. Check for Key Lookups
    5. Check Estimated vs Actual rows on every operator
```

#### Step 3 — Every Operator Explained

```
┌──────────────────────┬────────────────────────────────────────────────────────┐
│ Operator             │ Meaning + What to Do                                   │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Clustered Index SEEK │ ✅ Best case. B-tree traversal to specific rows.        │
│                      │    Uses = or BETWEEN on clustered key.                  │
│                      │    Expected: Estimated Rows ≈ Actual Rows               │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Index SEEK           │ ✅ Non-clustered B-tree traversal.                      │
│ (non-clustered)      │    Fast if covering index (no lookup needed).           │
│                      │    Check: does it have a Key Lookup sibling?            │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Clustered Index SCAN │ ⚠️  Reads entire table.                                 │
│                      │    OK for small tables (<10K rows).                    │
│                      │    On large tables: find WHERE clause, add index.      │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Index SCAN           │ ⚠️  Reads entire non-clustered index.                   │
│                      │    May be Forced by: non-sargable predicate,           │
│                      │    or optimizer decides scan cheaper than seek+lookup. │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Key Lookup           │ ⚠️  After non-clustered seek, goes back to clustered   │
│ (RID Lookup)         │    index to fetch columns not in the NC index.         │
│                      │    Fix: add missing columns to INCLUDE clause.         │
│                      │    If lookup > 1000 rows → add INCLUDE, saves big I/O │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Nested Loops Join    │ ✅ (usually) Outer loop × inner seek.                   │
│                      │    Fast when outer has FEW rows.                       │
│                      │    ⚠️  If outer has many rows → many seeks → slow.     │
│                      │    Optimizer chooses this when inner has index.        │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Hash Match           │ ⚠️  Builds hash table from one input, probes with      │
│ (Hash Join)          │    other. Used for large unsorted inputs.              │
│                      │    Signs: missing index on join column, large tables.  │
│                      │    Warning icon = hash SPILL to tempdb (memory issue). │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Merge Join           │ ✅ Both inputs pre-sorted on join key. Very efficient.  │
│                      │    Optimizer uses this when indexes provide sort order.│
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Sort                 │ ⚠️  No index supports ORDER BY / GROUP BY / DISTINCT.  │
│                      │    Adds cost proportional to rows × log(rows).        │
│                      │    Fix: add index with same column order as ORDER BY.  │
│                      │    Warning icon = sort SPILL to tempdb.               │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Filter               │ ⚠️  Predicate applied AFTER rows retrieved.            │
│                      │    Means WHERE clause couldn't be pushed into index.   │
│                      │    Cause: non-sargable function, OR condition, cast.   │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Compute Scalar       │ ✅ (usually) Evaluate expression (YEAR(), ISNULL()...) │
│                      │    ⚠️  If appears BEFORE index seek: function wraps    │
│                      │    indexed column → prevents seek (non-sargable).      │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Parallelism          │ Repartition / Gather streams for parallel query.        │
│ (Exchange)           │    MAXDOP > 1 and optimizer chose parallel plan.       │
│                      │    CXPACKET waits = one thread waiting for others.    │
│                      │    Skewed data = one partition does 90% of work.       │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Spool                │ ⚠️  Caches intermediate results in tempdb.             │
│ (Table/Index Spool)  │    Appears in correlated subqueries, triggers.        │
│                      │    Fix: rewrite as JOIN or CTE.                       │
├──────────────────────┼────────────────────────────────────────────────────────┤
│ Lazy Spool           │ ❌ Very expensive. Re-executes inner tree per row.      │
│                      │    Cause: correlated subquery in SELECT list.          │
│                      │    Fix: rewrite as LEFT JOIN.                          │
└──────────────────────┴────────────────────────────────────────────────────────┘
```

#### Step 4 — Tooltip Properties to Check on Every Operator

```
Right-click any operator → Properties (F4) — key fields:

┌───────────────────────────────────────────────────────────────────────────┐
│ Property              │ What it means                                     │
├───────────────────────┼───────────────────────────────────────────────────┤
│ Estimated Rows        │ Optimizer's prediction (from statistics).          │
│ Actual Rows           │ Real count from execution. Compare to Estimated.  │
│                       │ Ratio > 10x → statistics are stale/wrong → UPDATE │
│                       │ STATISTICS or reconsider partition key design.     │
├───────────────────────┼───────────────────────────────────────────────────┤
│ Estimated Cost        │ Relative cost % of this operator vs whole plan.   │
│ (Subtree Cost)        │ Focus on operators > 20% cost.                    │
├───────────────────────┼───────────────────────────────────────────────────┤
│ Actual Executions     │ How many times THIS operator ran.                 │
│                       │ If Nested Loops inner seek executed 50,000 times  │
│                       │ → outer loop returned 50K rows → too many seeks.  │
├───────────────────────┼───────────────────────────────────────────────────┤
│ Output List           │ Columns this operator outputs to parent.           │
│                       │ Look for columns you don't need (SELECT * smell). │
├───────────────────────┼───────────────────────────────────────────────────┤
│ Predicate             │ WHERE clause applied at this operator.            │
│ Seek Predicate        │ On Index Seek: shows which columns are seeked.    │
│                       │ Missing your WHERE column here → not seekable.    │
├───────────────────────┼───────────────────────────────────────────────────┤
│ Warnings              │ ⚠️ No Join Predicate (Cartesian product)           │
│                       │ ⚠️ Implicit Conversion (type mismatch)            │
│                       │ ⚠️ Residual (predicate can't be applied at seek)  │
│                       │ ⚠️ Spill (Sort/Hash used tempdb — memory too low) │
├───────────────────────┼───────────────────────────────────────────────────┤
│ Memory Grant          │ How much memory SQL allocated for Sort/Hash.      │
│                       │ Spill = grant was too small → query-level hint:   │
│                       │   OPTION (MIN_GRANT_PERCENT = 25)                 │
└───────────────────────┴───────────────────────────────────────────────────┘
```

#### Step 5 — STATISTICS IO + TIME Output (Text-Based)
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT o.OrderId, o.Status, c.Name
FROM Orders o
JOIN Customers c ON o.CustomerId = c.Id
WHERE o.Status = 'Pending';
```

```
-- Output in Messages tab:

SQL Server parse and compile time:
   CPU time = 0 ms,  elapsed time = 12 ms.

Table 'Customers'. Scan count 0, logical reads 3, physical reads 0,
                   read-ahead reads 0, lob logical reads 0.
Table 'Orders'.    Scan count 1, logical reads 84240, physical reads 0,
                   read-ahead reads 0, lob logical reads 0.

SQL Server Execution Times:
   CPU time = 3891 ms,  elapsed time = 4012 ms.
```

**How to read STATISTICS IO output:**
```
Column              Meaning
────────────────────────────────────────────────────────────────────────
Scan count          Number of index scans. 0 = seek (no scan). 1 = one
                    full scan. N = N scans (e.g., nested loop inner).

logical reads       Pages read from buffer pool (8KB each).
                    84,240 × 8KB = ~657 MB read! Screams missing index.
                    Compare: Customers = 3 reads (point seek). Perfect.
                    Rule: > 1,000 logical reads = investigate for index.

physical reads      Pages read from disk (not in buffer cache).
                    0 = all in memory. Non-zero = cold cache or RAM issue.

read-ahead reads    Pages prefetched (SQL predicts you'll need them).
                    High = large scan expected. Symptom of missing index.

CPU time (3,891ms)  Time CPU spent. 3.9 seconds for ONE query = problem.
elapsed time        Wall-clock time including waits (IO, locks).
                    elapsed >> CPU = waiting (IO, blocking, network).
                    elapsed ≈ CPU = CPU-bound.

GOAL: logical reads < 100 for OLTP queries. CPU time < 100ms.
```

#### Step 6 — Full Analysis Walkthrough: Bad Query vs Fixed Query

```sql
-- ❌ BAD QUERY — causes table scan
SELECT o.OrderId, o.TotalAmount, c.Name, c.Email
FROM Orders o
JOIN Customers c ON o.CustomerId = c.Id
WHERE YEAR(o.CreatedAt) = 2024
  AND o.Status = 'Pending';
```

```
-- Estimated plan (SSMS text representation):
-- [SELECT]
--   └─ [Nested Loops Inner Join]               Cost: 100%
--        ├─ [Clustered Index SCAN: Orders]      Cost: 94%  ← PROBLEM
--        │     Scan count: 1
--        │     Logical reads: 84,240            ← reads entire table
--        │     Filter: YEAR([CreatedAt])=(2024) ← function prevents seek
--        │     Estimated rows: 50,000
--        │     Actual rows: 12,847              ← 4x over-estimated
--        │
--        └─ [Clustered Index SEEK: Customers]   Cost: 6%
--               Seek Predicate: CustomerId = Orders.CustomerId
--               Actual Executions: 12,847       ← 12K seeks (one per order)
--               Logical reads: 3 each × 12K = 38,541 total

-- STATISTICS IO:
-- Orders:    Scan count 1, logical reads 84,240
-- Customers: Scan count 0, logical reads 38,541
-- CPU time = 3,891 ms
```

```
WHAT THE PLAN IS TELLING YOU:
  1. Clustered Index SCAN on Orders (94% cost) → entire 8M row table read
     Why? YEAR(CreatedAt) = non-sargable → SQL can't seek on a function result
     Fix: Replace with range predicate

  2. Nested Loops × 12,847 executions on Customers
     OK here (3 reads each = index seek), but if Customers was large → problem
     Monitor: Actual Executions on inner node

  3. Estimated 50K rows, Actual 12K → statistics off (4x error)
     Fix: UPDATE STATISTICS dbo.Orders
```

```sql
-- ✅ FIXED QUERY
SELECT o.OrderId, o.TotalAmount, c.Name, c.Email
FROM Orders o
JOIN Customers c ON o.CustomerId = c.Id
WHERE o.CreatedAt >= '2024-01-01'          -- ← sargable range
  AND o.CreatedAt < '2025-01-01'           -- ← no function wrapper
  AND o.Status = 'Pending';

-- Add covering index:
CREATE NONCLUSTERED INDEX NIX_Orders_Status_Created
ON Orders(Status, CreatedAt)
INCLUDE (CustomerId, TotalAmount, OrderId); -- WHY: all columns query needs
```

```
-- Fixed plan:
-- [SELECT]
--   └─ [Nested Loops Inner Join]               Cost: 100%
--        ├─ [Index SEEK: NIX_Orders_Status_Created]  Cost: 42%  ✅
--        │     Seek Predicate: Status='Pending'
--        │                     AND CreatedAt >= '2024-01-01'
--        │                     AND CreatedAt < '2025-01-01'
--        │     Scan count: 1
--        │     Logical reads: 48              ← 84,240 → 48 (1750x fewer!)
--        │     Actual rows: 12,847
--        │     Estimated rows: 12,200         ← accurate now (stats updated)
--        │
--        └─ [Clustered Index SEEK: Customers]  Cost: 58%
--               Actual Executions: 12,847

-- STATISTICS IO after fix:
-- Orders:    Scan count 1, logical reads 48       ← was 84,240
-- Customers: Scan count 0, logical reads 38,541
-- CPU time = 142 ms                               ← was 3,891 ms (27x faster)
```

#### Step 7 — Key Lookup: Spot and Fix It

```
SYMPTOM in plan:
  [Nested Loops]
    ├─ [Index Seek: NIX_Orders_CustomerId]   ← seeks on CustomerId
    └─ [Key Lookup: Orders]                  ← ⚠️ goes BACK to clustered index
         Output: TotalAmount, Status, CreatedAt   ← these columns missing from NC index

TOOLTIP on Key Lookup:
  "Lookup Columns: TotalAmount, Status, CreatedAt"  ← columns to add to INCLUDE
  Actual Executions: 45,000                          ← 45K extra B-tree traversals!
  Logical reads: 2 each × 45,000 = 90,000 extra reads

FIX: Add those columns to INCLUDE:
  ALTER INDEX NIX_Orders_CustomerId ON Orders
  DROP_EXISTING = ON;  -- rebuild with new columns

  CREATE NONCLUSTERED INDEX NIX_Orders_CustomerId
  ON Orders(CustomerId)
  INCLUDE (TotalAmount, Status, CreatedAt);  -- ← now a covering index

RESULT AFTER FIX:
  [Nested Loops]
    ├─ [Index Seek: NIX_Orders_CustomerId]   ✅
    (Key Lookup node is GONE)

RULE OF THUMB:
  Key Lookup with Executions < 100 → probably OK, low overhead
  Key Lookup with Executions > 1,000 → add INCLUDE columns
  Key Lookup with Executions > 10,000 → HIGH PRIORITY fix
```

#### Step 8 — Common Warning Icons in SSMS Plans

```
⚠️ Yellow triangle on operator — hover to see message:

"No Join Predicate"
  → Cartesian product (every row × every row).
  → Missing ON clause or always-true condition like ON 1=1.
  → Immediate fix required — can produce billions of rows.

"Type Conversion in Expression"
  → Column is INT, parameter is VARCHAR (or vice versa).
  → SQL converts every row → prevents index seek → full scan.
  → Fix: match data types. Use explicit CAST in the predicate, not on column.
  → Example: WHERE CustomerId = @id  (where @id is NVARCHAR but col is INT)
             Fix: DECLARE @id INT = 123  or  WHERE CustomerId = CAST(@id AS INT)

"Spill Level 1/2/3 to TempDB"
  → Sort or Hash operator ran out of memory grant.
  → Rows written to tempdb disk → 10-100x slower than in-memory.
  → Fix options:
      (a) Add index so Sort is eliminated entirely
      (b) Increase server memory
      (c) OPTION (MIN_GRANT_PERCENT = 25) — force larger memory grant
      (d) Reduce rows before Sort (more selective WHERE clause)

"Residual Predicate"
  → Predicate partially applied at seek but revalidated after.
  → On LIKE '%keyword%': leading wildcard means full index scan,
    residual filter removes non-matches after reading all pages.
  → Fix: Full-Text Search for wildcard text searches.
```

#### Step 9 — Estimated vs Actual Rows: The Statistics Story

```
Ratio: Actual / Estimated   What It Means
────────────────────────────────────────────────────────────────────────
0.9 – 1.1                   Excellent. Statistics accurate.
                            Optimizer chose the right plan.

2 – 5                       Moderate skew. Plan may be suboptimal
                            but usually acceptable for OLTP.

> 10                        Stale statistics. Optimizer picked wrong
                            join order, wrong index.
                            Fix: UPDATE STATISTICS WITH FULLSCAN

> 100                       Critical. Plan is catastrophically wrong.
                            Often causes Hash Joins where Nested Loops
                            expected, or table scans on 10M+ rows.

Estimated > Actual          Optimizer expected MORE rows than arrived.
(over-estimate)             → May have chosen Hash Join (expects large
                               input) where Nested Loops would be faster.

Actual > Estimated          Optimizer expected FEWER rows (under-estimate)
(under-estimate)            → May have chosen Nested Loops, inner seeks
                               100x more times than expected.
                            → This is the more common performance killer.

HOW TO FIX STATISTICS:
  -- Single table
  UPDATE STATISTICS dbo.Orders WITH FULLSCAN;

  -- Whole database (run during low-traffic window)
  EXEC sp_updatestats;  -- only updates tables with changes since last update

  -- Scheduled (SQL Agent job, daily):
  EXEC [dbo].[IndexOptimize]  -- Ola Hallengren solution (industry standard)
    @Databases = 'mydb',
    @UpdateStatistics = 'ALL',
    @OnlyModifiedStatistics = 'Y';
```

#### Summary: 5-Minute Plan Analysis Checklist

```
When you open an execution plan in SSMS:

□ 1. Any ⚠️ warning icons?
      → Hover → read message → fix type mismatch or missing join pred first

□ 2. Any SCAN on a large table (> 100K rows)?
      → Find that table's WHERE clause → is predicate sargable?
      → Check Missing Index hint (green text at top of plan in SSMS)

□ 3. Any Key Lookup?
      → Hover → note "Output List" (missing INCLUDE columns)
      → Check Actual Executions → if > 1,000, add those to INCLUDE

□ 4. Estimated rows vs Actual rows on every operator.
      → > 10x difference → UPDATE STATISTICS on that table

□ 5. Actual Executions on inner Nested Loops node.
      → Should equal outer rows. If > 10,000 → outer too fat → add index on outer

□ 6. Any Sort operators?
      → Look at sort key → add index with same column order

□ 7. SET STATISTICS IO ON → logical reads.
      → > 1,000 reads for a simple OLTP query = investigate index coverage

□ 8. Hash Match Join on tables you expect to be joined by index?
      → Check join column has index on BOTH tables
      → Check statistics — optimizer may have wrong row count estimates
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

---

### Terraform — Azure SQL Server (IaC)
```hcl
# ── SQL Server + Database + Firewall + Elastic Pool (optional) ────

variable "sql_admin_login"    { default = "sqladmin" }
variable "sql_admin_password" {
  sensitive = true
  # In CI/CD: export TF_VAR_sql_admin_password="..." or use Key Vault
}

resource "azurerm_mssql_server" "sql" {
  name                         = "sql-myapp-prod"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"              # SQL Server 2019 compatible
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  # WHY: Managed Identity for Azure AD auth (no passwords in connection strings)
  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azurerm_client_config.current.object_id
  }

  minimum_tls_version = "1.2"

  identity {
    type = "SystemAssigned"   # WHY: needed for Azure AD authentication
  }
}

# ── Database ─────────────────────────────────────────────────────
resource "azurerm_mssql_database" "db" {
  name      = "myapp-prod"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "GP_Gen5_2"           # General Purpose, 2 vCores (serverless: "GP_S_Gen5_1")

  # Serverless (auto-pause after idle — good for dev/test):
  # sku_name                    = "GP_S_Gen5_1"
  # auto_pause_delay_in_minutes = 60
  # min_capacity                = 0.5

  max_size_gb                 = 32
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant              = false         # true for Business Critical + geo-redundancy
  read_scale                  = false         # true = read-only replicas for reporting
  geo_backup_enabled          = true

  short_term_retention_policy {
    retention_days           = 7
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    weekly_retention  = "P4W"   # keep 4 weekly backups
    monthly_retention = "P3M"   # keep 3 monthly backups
    yearly_retention  = "P1Y"
    week_of_year      = 1
  }
}

# ── Firewall: allow Azure services (for Container Apps / Functions) ──
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
  # WHY: "0.0.0.0–0.0.0.0" is a magic value that means "allow Azure services"
  #       not actually opens all IPs
}

# ── Private Endpoint (production recommendation — no public internet) ──
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-sql-myapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

output "sql_connection_string" {
  value     = "Server=${azurerm_mssql_server.sql.fully_qualified_domain_name};Database=${azurerm_mssql_database.db.name};Authentication=Active Directory Default;"
  sensitive = false   # no password — uses managed identity
}
```

---

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
┌────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Integration Tests = The Proof of Wiring             │
│                                                                    │
│  Unit test:       "does this method compute the right result?"     │
│  Integration test:"does this HTTP call hit the DB and return 201?"│
│                                                                    │
│  Pyramid:  Unit (fast, many) → Integration (medium) → E2E (slow)  │
│                                                                    │
│  Real DB + real HTTP pipeline + mock ONLY external systems         │
│  = catch DI misconfigurations, EF mapping bugs, auth wiring issues│
└────────────────────────────────────────────────────────────────────┘
```

### Why Integration Tests Catch What Unit Tests Miss
```
Unit test misses                    Integration test catches
─────────────────────────────────   ──────────────────────────────────
EF Core query is wrong              Real SQL runs, returns wrong data
DI registration is missing          Factory starts, DI throws on build
Auth middleware not wired           401 instead of 200
Model validation not applied        400 instead of 201
FluentValidation not registered     Pass-through of invalid data
Middleware order wrong              Wrong behavior in pipeline
CQRS handler not registered         MediatR throws unhandled type
```

---

### Step 0 — NuGet Packages (What to Install)
```xml
<!-- YourProject.IntegrationTests.csproj -->
<ItemGroup>
  <!-- Core: in-memory HTTP server wrapping your real app -->
  <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="9.*" />

  <!-- Test framework -->
  <PackageReference Include="xunit" Version="2.*" />
  <PackageReference Include="xunit.runner.visualstudio" Version="2.*" />
  <PackageReference Include="FluentAssertions" Version="6.*" />

  <!-- Spin up real Docker containers for DB, Redis, etc. -->
  <PackageReference Include="Testcontainers" Version="3.*" />
  <PackageReference Include="Testcontainers.MsSql" Version="3.*" />
  <PackageReference Include="Testcontainers.PostgreSql" Version="3.*" />
  <PackageReference Include="Testcontainers.Redis" Version="3.*" />

  <!-- Reset DB between tests without DROP/CREATE -->
  <PackageReference Include="Respawn" Version="6.*" />

  <!-- Fake HTTP responses for external services -->
  <PackageReference Include="WireMock.Net" Version="1.*" />

  <!-- Reference your actual app project -->
  <ProjectReference Include="..\YourApi\YourApi.csproj" />
</ItemGroup>
```

---

### Step 1 — Make Program.cs Testable
```csharp
// ❌ BAD — WebApplicationFactory cannot find the entry point
// internal sealed class Program { }  ← internal by default in .NET 6+

// ✅ GOOD — expose Program as partial so tests can reference it
// At the very bottom of Program.cs, add:
public partial class Program { }    // ← zero code, just makes it public
```
```
WHY: WebApplicationFactory<Program> needs Program as a generic type argument.
If Program is internal, the test project (different assembly) cannot see it.
Adding `public partial class Program { }` is the standard .NET fix.
```

---

### Step 2 — WebApplicationFactory: What It Does
```
                        ┌────────────────────────────────────────┐
                        │  WebApplicationFactory<Program>        │
                        │                                        │
Request                 │  ┌────────────────────────────────┐   │
─────► HttpClient ─────►│  │  Kestrel (in-memory transport) │   │
                        │  │  Your real middleware pipeline  │   │
Response                │  │  Your real DI container        │   │
◄─────                 │  │  Your real controllers/endpoints│   │
                        │  └────────────────────────────────┘   │
                        │                                        │
                        │  ConfigureWebHost() → override services│
                        │  (swap real DB → test container DB)    │
                        └────────────────────────────────────────┘

Key insight: NO actual network socket. HttpClient talks in-process.
             Your full middleware stack runs. Real routing, real auth.
```

---

### Step 3 — Custom Factory: Full Production-Ready Setup
```csharp
// ApiFactory.cs — one file that owns ALL test infrastructure
public class ApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    // ── Testcontainers ──────────────────────────────────────────
    private readonly MsSqlContainer _db = new MsSqlBuilder()
        .WithPassword("Test@1234!")                   // SQL Server 2022 in Docker
        .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
        .Build();

    private readonly RedisContainer _redis = new RedisBuilder().Build();

    // ── Respawn ─────────────────────────────────────────────────
    private Respawner _respawner = default!;
    private SqlConnection _connection = default!;

    // ── WireMock for external HTTP services ─────────────────────
    public WireMockServer ExternalPaymentApi { get; } =
        WireMockServer.Start();                        // random port, fake HTTP server

    // ── Override services ────────────────────────────────────────
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");             // WHY: appsettings.Testing.json loaded

        builder.ConfigureServices(services =>
        {
            // 1. Remove real DB, replace with test container DB
            services.RemoveAll<DbContextOptions<AppDbContext>>();
            services.AddDbContext<AppDbContext>(opts =>
                opts.UseSqlServer(_db.GetConnectionString()));

            // 2. Remove real Redis, replace with test container
            services.RemoveAll<IConnectionMultiplexer>();
            services.AddSingleton<IConnectionMultiplexer>(_ =>
                ConnectionMultiplexer.Connect(_redis.GetConnectionString()));

            // 3. Replace external payment API URL with WireMock URL
            services.Configure<PaymentOptions>(opts =>
                opts.BaseUrl = ExternalPaymentApi.Urls[0]);

            // 4. Replace Service Bus with fake (no Azurite needed for most tests)
            services.RemoveAll<ServiceBusClient>();
            services.AddSingleton<IEventPublisher, FakeEventPublisher>();

            // 5. Replace auth: accept any JWT signed with test key
            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(opts =>
                {
                    opts.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = false,
                        ValidateAudience = false,
                        ValidateLifetime = false,              // WHY: tests don't care about expiry
                        IssuerSigningKey = new SymmetricSecurityKey(
                            Encoding.UTF8.GetBytes("super-secret-test-key-32-chars!!")),
                    };
                });
        });

        // Suppress startup logs in test output (optional but clean)
        builder.ConfigureLogging(logging => logging.SetMinimumLevel(LogLevel.Warning));
    }

    // ── Lifecycle ────────────────────────────────────────────────
    public async Task InitializeAsync()
    {
        // Start containers in parallel
        await Task.WhenAll(_db.StartAsync(), _redis.StartAsync());

        // Apply EF migrations against the test container DB
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.MigrateAsync();

        // Prepare Respawn (must happen AFTER migrations, so tables exist)
        _connection = new SqlConnection(_db.GetConnectionString());
        await _connection.OpenAsync();
        _respawner = await Respawner.CreateAsync(_connection, new RespawnerOptions
        {
            DbAdapter = DbAdapter.SqlServer,
            TablesToIgnore = ["__EFMigrationsHistory"]  // keep migrations table
        });
        await _connection.CloseAsync();
    }

    // ── DB Reset Helper (called by each test class) ──────────────
    public async Task ResetDatabaseAsync()
    {
        await _connection.OpenAsync();
        await _respawner.ResetAsync(_connection);  // DELETE all rows — faster than DROP/CREATE
        await _connection.CloseAsync();
    }

    // ── JWT Helper ───────────────────────────────────────────────
    public string GenerateTestJwt(string userId = "test-user-1",
        string role = "User", string[]? permissions = null)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, userId),
            new(ClaimTypes.Role, role),
        };
        if (permissions != null)
            claims.AddRange(permissions.Select(p => new Claim("permission", p)));

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes("super-secret-test-key-32-chars!!"));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(claims: claims, signingCredentials: creds);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public new async Task DisposeAsync()
    {
        await _connection.DisposeAsync();
        await Task.WhenAll(_db.DisposeAsync().AsTask(), _redis.DisposeAsync().AsTask());
        ExternalPaymentApi.Dispose();
        await base.DisposeAsync();
    }
}
```

---

### Step 4 — Collection Fixture (One Container for All Tests)
```csharp
// ────────────────────────────────────────────────────────────────
// IMPORTANT: Without [CollectionDefinition], each test CLASS gets
// its own factory = Docker containers start/stop per class = SLOW.
// With [CollectionDefinition] + ICollectionFixture, ONE factory
// is shared across ALL test classes in the collection.
// ────────────────────────────────────────────────────────────────

// 1. Define the collection
[CollectionDefinition("Integration")]
public class IntegrationCollection : ICollectionFixture<ApiFactory> { }

// 2. Tag every test class with [Collection("Integration")]
[Collection("Integration")]
public class OrderTests : IAsyncLifetime          // IAsyncLifetime for per-class setup
{
    private readonly HttpClient _client;
    protected readonly ApiFactory Factory;

    public OrderTests(ApiFactory factory)
    {
        Factory = factory;
        _client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false,            // WHY: test redirects explicitly
            HandleCookies = true
        });

        // Inject Bearer token for every request
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", factory.GenerateTestJwt());
    }

    // Per test-CLASS reset — runs once before all tests in THIS class
    public async Task InitializeAsync() => await Factory.ResetDatabaseAsync();
    public Task DisposeAsync() => Task.CompletedTask;
}
```

---

### Step 5 — Test Data Builder Pattern
```csharp
// ❌ BAD — raw object construction scattered everywhere
var request = new CreateOrderRequest { CustomerId = "c1", Items = [...] };

// ✅ GOOD — builder that has sensible defaults, easy to override
public class OrderRequestBuilder
{
    private string _customerId = Guid.NewGuid().ToString();  // unique per test
    private List<OrderItemDto> _items = [new("SKU-001", 1, 19.99m)];
    private string? _idempotencyKey;

    public OrderRequestBuilder WithCustomer(string id) { _customerId = id; return this; }
    public OrderRequestBuilder WithItem(string sku, int qty, decimal price)
    {
        _items.Add(new(sku, qty, price)); return this;
    }
    public OrderRequestBuilder WithIdempotencyKey(string key)
    {
        _idempotencyKey = key; return this;
    }

    public (CreateOrderRequest Request, string? IdempotencyKey) Build()
        => (new CreateOrderRequest { CustomerId = _customerId, Items = _items }, _idempotencyKey);
}

// Usage in tests — readable and isolated
var (req, key) = new OrderRequestBuilder()
    .WithCustomer("vip-customer")
    .WithItem("PREMIUM-SKU", 3, 99.99m)
    .Build();
```

---

### Step 6 — Full End-to-End Test: Every Pattern in One Place
```csharp
[Collection("Integration")]
public class OrderTests : IAsyncLifetime
{
    private readonly HttpClient _client;
    private readonly ApiFactory _factory;
    private readonly FakeEventPublisher _publisher;

    public OrderTests(ApiFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer",
                factory.GenerateTestJwt(userId: "user-123", role: "Customer"));

        // Resolve the fake publisher registered in factory
        _publisher = factory.Services.GetRequiredService<IEventPublisher>()
            as FakeEventPublisher ?? throw new InvalidOperationException();
    }

    // ── Happy path: create order ─────────────────────────────────
    [Fact]
    public async Task CreateOrder_ValidRequest_Returns201_And_PublishesEvent()
    {
        // Arrange
        _publisher.Clear();                        // WHY: events from previous test may linger
        var (req, _) = new OrderRequestBuilder()
            .WithItem("SKU-A", 2, 50.00m)
            .Build();

        // Act
        var response = await _client.PostAsJsonAsync("/api/orders", req);

        // Assert — HTTP
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var order = await response.Content.ReadFromJsonAsync<OrderResponse>();
        order!.Id.Should().NotBeEmpty();
        order.Status.Should().Be("Pending");
        order.Total.Should().Be(100.00m);          // 2 × $50

        // Assert — Location header (REST best practice)
        response.Headers.Location!.ToString()
            .Should().Contain($"/api/orders/{order.Id}");

        // Assert — Database state (read directly from DB, not via API)
        await VerifyDatabaseAsync(order.Id, expectedStatus: "Pending");

        // Assert — Domain event published
        var events = _publisher.GetPublished<OrderCreatedEvent>();
        events.Should().ContainSingle(e =>
            e.OrderId == order.Id && e.CustomerId == "user-123");
    }

    // ── Validation: missing required field ──────────────────────
    [Fact]
    public async Task CreateOrder_MissingItems_Returns400WithErrors()
    {
        var req = new CreateOrderRequest { CustomerId = "c1", Items = [] }; // empty items

        var response = await _client.PostAsJsonAsync("/api/orders", req);

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var problem = await response.Content.ReadFromJsonAsync<ValidationProblemDetails>();
        problem!.Errors.Should().ContainKey("Items");
    }

    // ── Auth: unauthenticated request ───────────────────────────
    [Fact]
    public async Task CreateOrder_NoToken_Returns401()
    {
        _client.DefaultRequestHeaders.Authorization = null;  // remove token
        var response = await _client.PostAsJsonAsync("/api/orders", new { });
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    // ── Auth: insufficient role ──────────────────────────────────
    [Fact]
    public async Task GetAllOrders_AsCustomer_Returns403()
    {
        // Customer role should not access admin endpoint
        var response = await _client.GetAsync("/api/admin/orders");
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    // ── Idempotency: same key twice = same result ────────────────
    [Fact]
    public async Task CreateOrder_SameIdempotencyKey_ReturnsSameOrder()
    {
        var key = Guid.NewGuid().ToString();
        var (req, _) = new OrderRequestBuilder().Build();

        var r1 = await SendWithIdempotencyKey(req, key);
        var r2 = await SendWithIdempotencyKey(req, key);

        var o1 = await r1.Content.ReadFromJsonAsync<OrderResponse>();
        var o2 = await r2.Content.ReadFromJsonAsync<OrderResponse>();
        o1!.Id.Should().Be(o2!.Id);
        r2.StatusCode.Should().Be(HttpStatusCode.OK);   // 2nd = 200, not 201
    }

    // ── External HTTP mock (WireMock) ───────────────────────────
    [Fact]
    public async Task CreateOrder_WhenPaymentFails_Returns402()
    {
        // Configure WireMock to return payment failure
        _factory.ExternalPaymentApi
            .Given(Request.Create().WithPath("/payments").UsingPost())
            .RespondWith(Response.Create()
                .WithStatusCode(402)
                .WithBodyAsJson(new { error = "insufficient_funds" }));

        var (req, _) = new OrderRequestBuilder().Build();
        var response = await _client.PostAsJsonAsync("/api/orders", req);

        response.StatusCode.Should().Be(HttpStatusCode.PaymentRequired);
    }

    // ── Helper: verify DB directly ──────────────────────────────
    private async Task VerifyDatabaseAsync(Guid orderId, string expectedStatus)
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var order = await db.Orders.FindAsync(orderId);
        order.Should().NotBeNull();
        order!.Status.Should().Be(expectedStatus);
    }

    private async Task<HttpResponseMessage> SendWithIdempotencyKey(
        CreateOrderRequest req, string key)
    {
        var http = new HttpRequestMessage(HttpMethod.Post, "/api/orders")
        {
            Content = JsonContent.Create(req)
        };
        http.Headers.Add("Idempotency-Key", key);
        return await _client.SendAsync(http);
    }

    public async Task InitializeAsync() => await _factory.ResetDatabaseAsync();
    public Task DisposeAsync() => Task.CompletedTask;
}
```

---

### Step 7 — Testing Service Bus Consumers Directly
```csharp
// Pattern 1: Unit-test the handler in isolation
// Use ServiceBusModelFactory to create a real ServiceBusReceivedMessage
[Fact]
public async Task OrderCreatedHandler_ValidMessage_CreatesInvoice()
{
    // ServiceBusModelFactory is part of Azure.Messaging.ServiceBus — no mocking needed
    var @event = new OrderCreatedEvent(
        OrderId: Guid.NewGuid(), CustomerId: "c-1", Total: 99.99m);

    var sbMessage = ServiceBusModelFactory.ServiceBusReceivedMessage(
        body: BinaryData.FromObjectAsJson(@event),
        messageId: Guid.NewGuid().ToString(),
        correlationId: "test-correlation");

    // Create a real ServiceBusMessageActions mock
    var actions = Substitute.For<ServiceBusMessageActions>();

    // Resolve the handler from DI (it has real dependencies)
    using var scope = _factory.Services.CreateScope();
    var handler = scope.ServiceProvider.GetRequiredService<OrderCreatedHandler>();

    // Act
    await handler.HandleAsync(sbMessage, actions, CancellationToken.None);

    // Assert
    await actions.Received(1).CompleteMessageAsync(sbMessage, default);

    using var dbScope = _factory.Services.CreateScope();
    var db = dbScope.ServiceProvider.GetRequiredService<AppDbContext>();
    var invoice = await db.Invoices.FirstOrDefaultAsync(i => i.CustomerId == "c-1");
    invoice.Should().NotBeNull();
}

// Pattern 2: Integration test with Azurite (Service Bus emulator)
// (Requires Testcontainers.Azurite or a real Service Bus dev namespace)
[Fact]
public async Task OrderProcessor_E2E_MessageFlowsFromQueueToDatabase()
{
    // Use Azurite container (see TestContainers section below)
    var sender = _factory.Services.GetRequiredService<ServiceBusSender>();
    var message = new ServiceBusMessage(BinaryData.FromObjectAsJson(
        new OrderCreatedEvent(Guid.NewGuid(), "c-2", 149.99m)));

    await sender.SendMessageAsync(message);

    // Wait for processor to handle it (poll with timeout)
    var deadline = DateTime.UtcNow.AddSeconds(10);
    Invoice? invoice = null;
    while (DateTime.UtcNow < deadline && invoice == null)
    {
        await Task.Delay(200);
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        invoice = await db.Invoices.FirstOrDefaultAsync(i => i.CustomerId == "c-2");
    }
    invoice.Should().NotBeNull("processor should handle message within 10s");
}
```

---

### Step 8 — TestContainers: All Container Types
```csharp
// ── SQL Server ───────────────────────────────────────────────────
var sql = new MsSqlBuilder()
    .WithPassword("StrongP@ss1")
    .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
    .Build();

// ── PostgreSQL ───────────────────────────────────────────────────
var postgres = new PostgreSqlBuilder()
    .WithDatabase("testdb")
    .WithUsername("test")
    .WithPassword("test")
    .Build();

// ── Redis ────────────────────────────────────────────────────────
var redis = new RedisBuilder()
    .WithImage("redis:7-alpine")      // lightweight image
    .Build();

// ── MongoDB ──────────────────────────────────────────────────────
var mongo = new MongoDbBuilder()
    .WithUsername("test").WithPassword("test")
    .Build();

// ── Azurite (Azure Storage + Service Bus emulator) ───────────────
var azurite = new AzuriteBuilder()
    .WithInMemoryPersistence()        // no file system needed in CI
    .Build();

// ── Start in parallel to save time ──────────────────────────────
await Task.WhenAll(sql.StartAsync(), redis.StartAsync(), azurite.StartAsync());

// Connection strings are available after StartAsync()
string connStr = sql.GetConnectionString();     // "Server=localhost,12345;..."
string redisConn = redis.GetConnectionString(); // "localhost:12346"
```

---

### Step 9 — Respawn: Database Reset Deep Dive
```csharp
// WHY Respawn over DROP/CREATE:
// DROP + CREATE migrations takes 3-15 seconds per test class
// Respawn: DELETE all rows via foreign-key-aware graph traversal → ~50ms

// Setup (once after migrations)
var respawner = await Respawner.CreateAsync(connection, new RespawnerOptions
{
    DbAdapter = DbAdapter.SqlServer,         // or DbAdapter.Postgres
    TablesToIgnore = [                        // tables that should NOT be cleared
        "__EFMigrationsHistory",             // keep migration history
        "LookupCountries",                   // reference data seeded once
        "LookupCurrencies"
    ],
    TablesToInclude = null,                  // null = all tables except TablesToIgnore
    SchemasToExclude = ["dbo_readonly"],     // skip read-only schemas
    WithReseed = true,                        // reset IDENTITY columns to 0
});

// Reset (before each test class)
await connection.OpenAsync();
await respawner.ResetAsync(connection);      // DELETE in correct FK order
await connection.CloseAsync();

// Lifecycle pattern in factory:
// ┌─ Test Class 1 starts ─────────────────────────────────────────┐
// │  InitializeAsync() → ResetDatabaseAsync() → all tables empty  │
// │  Test A runs, creates orders 1,2,3                            │
// │  Test B runs, creates orders 4,5 (sees A's data if parallel!) │
// └───────────────────────────────────────────────────────────────┘
// ┌─ Test Class 2 starts ─────────────────────────────────────────┐
// │  InitializeAsync() → ResetDatabaseAsync() → orders gone       │
// │  Test C runs on a clean slate                                 │
// └───────────────────────────────────────────────────────────────┘
```

---

### Step 10 — Fake Event Publisher / Captured Events
```csharp
public class FakeEventPublisher : IEventPublisher
{
    private readonly ConcurrentBag<object> _published = new();

    public Task PublishAsync<T>(T @event, CancellationToken ct = default)
    {
        _published.Add(@event!);
        return Task.CompletedTask;
    }

    public IReadOnlyList<T> GetPublished<T>() => _published.OfType<T>().ToList();
    public bool WasPublished<T>(Func<T, bool> predicate) =>
        _published.OfType<T>().Any(predicate);
    public void Clear() => _published.Clear();
}

// Assert exactly one event with specific values
var events = _publisher.GetPublished<OrderCreatedEvent>();
events.Should().HaveCount(1);
events[0].OrderId.Should().Be(expectedOrderId);

// Assert NO events published (e.g., failed request should not publish)
var events = _publisher.GetPublished<OrderCreatedEvent>();
events.Should().BeEmpty("failed validation should not publish domain events");
```

---

### Step 11 — Seeding Test Data in DB
```csharp
// ── Option A: Seed via EF Core directly ─────────────────────────
private async Task SeedAsync(AppDbContext db, params Order[] orders)
{
    db.Orders.AddRange(orders);
    await db.SaveChangesAsync();
}

// ── Option B: Seed via API endpoint ─────────────────────────────
// Preferred: validates the full creation pipeline
var seedResponse = await _client.PostAsJsonAsync("/api/orders", seedRequest);
seedResponse.EnsureSuccessStatusCode();
var seeded = await seedResponse.Content.ReadFromJsonAsync<OrderResponse>();

// ── Use in test ──────────────────────────────────────────────────
[Fact]
public async Task GetOrder_ExistingOrder_Returns200WithDetails()
{
    // Seed
    using var scope = _factory.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var order = Order.Create("cust-1", [new OrderLine("SKU-1", 1, 10m)]);
    db.Orders.Add(order);
    await db.SaveChangesAsync();

    // Act
    var response = await _client.GetAsync($"/api/orders/{order.Id}");

    // Assert
    response.StatusCode.Should().Be(HttpStatusCode.OK);
    var result = await response.Content.ReadFromJsonAsync<OrderResponse>();
    result!.Id.Should().Be(order.Id);
}
```

---

### Step 12 — Avoiding Flaky Tests: Rules
```
Rule 1: Never depend on insertion order
        ✓ Sort results before asserting, or use .ContainSingle(predicate)

Rule 2: Never share mutable state between tests
        ✓ Use unique IDs per test (Guid.NewGuid())
        ✓ Use IAsyncLifetime.InitializeAsync to reset DB per class

Rule 3: Never use Thread.Sleep — use polling with timeout
        ✓ while (DateTime.UtcNow < deadline) { await Task.Delay(100); ... }

Rule 4: Be specific in assertions
        ✗ result.Should().NotBeNull()
        ✓ result.OrderId.Should().Be(expectedId)

Rule 5: Test one behaviour per test
        ✗ "CreateOrder_WorksCorrectly"
        ✓ "CreateOrder_ValidRequest_Returns201"
        ✓ "CreateOrder_ValidRequest_PublishesOrderCreatedEvent"

Rule 6: Make tests independent of clock
        ✓ Inject IDateTimeProvider / TimeProvider (mockable)
        ✗ DateTime.UtcNow.AddDays(1) hardcoded in production code
```

---

### Step 13 — CI/CD: Running Integration Tests
```yaml
# GitHub Actions — integration tests with Docker (Testcontainers uses Docker socket)
- name: Run Integration Tests
  run: dotnet test tests/YourProject.IntegrationTests --no-build
  env:
    DOCKER_HOST: unix:///var/run/docker.sock    # Linux runners have Docker by default
    TESTCONTAINERS_RYUK_DISABLED: "true"        # WHY: Ryuk (cleanup container) causes issues
                                                 # in some CI environments

# Azure DevOps
- task: DotNetCoreCLI@2
  displayName: 'Integration Tests'
  inputs:
    command: 'test'
    projects: '**/*IntegrationTests*.csproj'
  env:
    DOCKER_HOST: unix:///var/run/docker.sock
```

---

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
┌──────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Modular Monolith = Microservices in One Process   │
│                                                                  │
│  Traditional monolith: one big ball of mud, everything touches  │
│                         everything, can't change without fear   │
│                                                                  │
│  Microservices: fully isolated, but distributed system tax      │
│                 (network failures, distributed tracing, devops) │
│                                                                  │
│  Modular Monolith: strong domain BOUNDARIES like microservices  │
│                    but ONE process, NO network between modules  │
│                    "Pay domain tax, not distributed systems tax"│
│                                                                  │
│  Key rules:                                                      │
│  1. Each module owns its DB schema — NO cross-module table joins │
│  2. Cross-module calls only via events / public module API      │
│  3. Boundaries enforced by architecture tests (NetArchTest)     │
│  4. "Deploy as one, design as many"                             │
└──────────────────────────────────────────────────────────────────┘
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

---

### Domain Layer — Aggregate Roots, Value Objects, Domain Events
```csharp
// ── Aggregate Root (Orders.Domain) ──────────────────────────────
// WHY: Aggregate Root is the consistency boundary. ALL changes to
//      the aggregate go through the root. No one else touches internals.

public class Order : AggregateRoot                  // base class holds domain events
{
    public Guid Id { get; private set; }
    public string CustomerId { get; private set; } = default!;
    public Money TotalAmount { get; private set; } = default!;
    public OrderStatus Status { get; private set; }
    private readonly List<OrderLine> _lines = [];
    public IReadOnlyList<OrderLine> Lines => _lines.AsReadOnly();

    private Order() { }  // WHY: EF Core needs parameterless ctor (private = not public API)

    // Factory method = the ONLY way to create an Order
    public static Order Create(string customerId, IReadOnlyList<OrderLineInput> inputs)
    {
        if (!inputs.Any()) throw new DomainException("Order must have at least one line");

        var order = new Order
        {
            Id = Guid.NewGuid(),
            CustomerId = customerId,
            Status = OrderStatus.Pending
        };
        foreach (var i in inputs)
            order._lines.Add(OrderLine.Create(i.Sku, i.Quantity, i.Price));

        order.TotalAmount = Money.From(order._lines.Sum(l => l.LineTotal.Amount));

        // Raise domain event — will be dispatched AFTER SaveChanges
        order.AddDomainEvent(new OrderCreatedEvent(order.Id, customerId, order.TotalAmount));
        return order;
    }

    public void Cancel(string reason)
    {
        if (Status != OrderStatus.Pending)
            throw new DomainException($"Cannot cancel order in status {Status}");
        Status = OrderStatus.Cancelled;
        AddDomainEvent(new OrderCancelledEvent(Id, reason));
    }
}

// ── Value Object (immutable, compared by value not reference) ────
public record Money(decimal Amount, string Currency)
{
    public static Money From(decimal amount, string currency = "USD")
    {
        if (amount < 0) throw new DomainException("Money cannot be negative");
        return new Money(amount, currency);
    }
    public Money Add(Money other)
    {
        if (Currency != other.Currency) throw new DomainException("Currency mismatch");
        return new Money(Amount + other.Amount, Currency);
    }
}

// ── AggregateRoot base (SharedKernel) ───────────────────────────
public abstract class AggregateRoot
{
    private readonly List<IDomainEvent> _events = [];
    public IReadOnlyList<IDomainEvent> DomainEvents => _events.AsReadOnly();
    protected void AddDomainEvent(IDomainEvent @event) => _events.Add(@event);
    public void ClearDomainEvents() => _events.Clear();
}

// ── Domain Event ─────────────────────────────────────────────────
public record OrderCreatedEvent(Guid OrderId, string CustomerId, Money Total)
    : IDomainEvent
{
    public Guid EventId { get; } = Guid.NewGuid();
    public DateTime OccurredAt { get; } = DateTime.UtcNow;
}
```

---

### Application Layer — CQRS with MediatR (Commands & Queries)
```csharp
// ── COMMAND: side effect, returns Result (not data) ──────────────
public record CreateOrderCommand(string CustomerId, List<OrderLineInput> Items)
    : IRequest<Result<Guid>>;

public class CreateOrderCommandHandler
    : IRequestHandler<CreateOrderCommand, Result<Guid>>
{
    private readonly IOrderRepository _repo;
    private readonly IUnitOfWork _uow;

    public async Task<Result<Guid>> Handle(
        CreateOrderCommand cmd, CancellationToken ct)
    {
        var order = Order.Create(cmd.CustomerId, cmd.Items);
        await _repo.AddAsync(order, ct);
        await _uow.CommitAsync(ct);          // SaveChanges + dispatch domain events
        return Result.Success(order.Id);
    }
}

// ── QUERY: no side effects, returns data ─────────────────────────
public record GetOrderQuery(Guid OrderId) : IRequest<Result<OrderDto>>;

public class GetOrderQueryHandler : IRequestHandler<GetOrderQuery, Result<OrderDto>>
{
    private readonly IOrderReadRepository _read;   // WHY: separate read repo = no EF tracking

    public async Task<Result<OrderDto>> Handle(GetOrderQuery q, CancellationToken ct)
    {
        var order = await _read.GetByIdAsync(q.OrderId, ct);
        if (order is null) return Result.NotFound<OrderDto>($"Order {q.OrderId} not found");
        return Result.Success(order.ToDto());
    }
}

// ── API endpoint wires to commands ───────────────────────────────
// Orders.API/OrderEndpoints.cs
public static class OrderEndpoints
{
    public static void MapOrderEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/orders").RequireAuthorization();

        group.MapPost("/", async (CreateOrderRequest req,
            ISender sender, CancellationToken ct) =>
        {
            var cmd = new CreateOrderCommand(req.CustomerId, req.Items);
            var result = await sender.Send(cmd, ct);
            return result.IsSuccess
                ? Results.Created($"/api/orders/{result.Value}", result.Value)
                : Results.BadRequest(result.Error);
        });

        group.MapGet("/{id:guid}", async (Guid id, ISender sender, CancellationToken ct) =>
        {
            var result = await sender.Send(new GetOrderQuery(id), ct);
            return result.IsSuccess ? Results.Ok(result.Value) : Results.NotFound();
        });
    }
}
```

---

### Pipeline Behaviors — Validation, Logging, Unit of Work
```csharp
// Pipeline behaviors wrap EVERY command/query — like middleware for MediatR
// Request → [LoggingBehavior] → [ValidationBehavior] → [Handler]

// ── 1. Logging Behavior ──────────────────────────────────────────
public class LoggingBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;

    public async Task<TResponse> Handle(TRequest request,
        RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        var name = typeof(TRequest).Name;
        _logger.LogInformation("Handling {Request}: {@Payload}", name, request);
        var sw = Stopwatch.StartNew();
        var response = await next();
        _logger.LogInformation("Handled {Request} in {Elapsed}ms", name, sw.ElapsedMilliseconds);
        return response;
    }
}

// ── 2. Validation Behavior (FluentValidation) ────────────────────
public class ValidationBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public async Task<TResponse> Handle(TRequest request,
        RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        if (!_validators.Any()) return await next();

        var context = new ValidationContext<TRequest>(request);
        var failures = _validators
            .Select(v => v.Validate(context))
            .SelectMany(r => r.Errors)
            .Where(f => f != null)
            .ToList();

        if (failures.Any())
            throw new ValidationException(failures);    // caught by exception middleware

        return await next();
    }
}

// Validator (defined next to the command, in Application layer)
public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Items).NotEmpty().WithMessage("Order must have at least one item");
        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.Sku).NotEmpty();
            item.RuleFor(i => i.Quantity).GreaterThan(0);
            item.RuleFor(i => i.Price).GreaterThan(0);
        });
    }
}

// ── 3. Unit of Work Behavior ─────────────────────────────────────
// Wraps commands in a transaction + dispatches domain events after SaveChanges
public class UnitOfWorkBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : ICommand  // marker interface — only for commands, not queries
{
    private readonly AppDbContext _db;
    private readonly IDomainEventDispatcher _dispatcher;

    public async Task<TResponse> Handle(TRequest request,
        RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        var result = await next();                   // run the command handler

        // Collect all domain events from tracked aggregates
        var aggregates = _db.ChangeTracker.Entries<AggregateRoot>()
            .Where(e => e.Entity.DomainEvents.Any())
            .Select(e => e.Entity)
            .ToList();

        var events = aggregates.SelectMany(a => a.DomainEvents).ToList();
        aggregates.ForEach(a => a.ClearDomainEvents());

        await _db.SaveChangesAsync(ct);              // persist to DB

        // Dispatch events AFTER successful save
        foreach (var @event in events)
            await _dispatcher.DispatchAsync(@event, ct);

        return result;
    }
}

// Register in module:
services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssembly(typeof(OrdersModule).Assembly);
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(UnitOfWorkBehavior<,>));
});
```

---

### Outbox Pattern — Reliable Domain Event Dispatch
```
WHY: If you publish events BEFORE SaveChanges → save fails → event already sent (phantom event)
     If you publish events AFTER SaveChanges  → publish fails → event lost (data inconsistency)
     Outbox: save events IN SAME TRANSACTION as data, publish separately → guaranteed at-least-once

┌───────────────────────────────────────────────────────────────────────┐
│  Request                                                              │
│    → Command Handler creates Order + adds event to OutboxMessages     │
│    → SaveChanges (Order + OutboxMessage in ONE DB transaction)        │
│                                                                       │
│  Background Worker (OutboxProcessor runs every 5s)                   │
│    → SELECT * FROM OutboxMessages WHERE ProcessedAt IS NULL           │
│    → Publish to MediatR / Service Bus                                 │
│    → UPDATE OutboxMessages SET ProcessedAt = NOW()                    │
└───────────────────────────────────────────────────────────────────────┘
```
```csharp
// ── 1. OutboxMessage entity ──────────────────────────────────────
public class OutboxMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Type { get; set; } = default!;        // fully qualified event type name
    public string Payload { get; set; } = default!;     // JSON serialized event
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ProcessedAt { get; set; }           // null = not yet processed
    public string? Error { get; set; }
}

// ── 2. Add to DbContext ──────────────────────────────────────────
public class AppDbContext : DbContext
{
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();
}

// ── 3. Intercept SaveChanges to write events to Outbox ───────────
// In UnitOfWorkBehavior — before SaveChanges:
var domainEvents = GetAllDomainEvents(_db);
foreach (var @event in domainEvents)
{
    _db.OutboxMessages.Add(new OutboxMessage
    {
        Type = @event.GetType().AssemblyQualifiedName!,
        Payload = JsonSerializer.Serialize(@event, @event.GetType())
    });
}
await _db.SaveChangesAsync(ct);   // events + data in one transaction

// ── 4. Background processor (Hangfire or IHostedService) ─────────
public class OutboxProcessor : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            await ProcessOutboxAsync(ct);
            await Task.Delay(TimeSpan.FromSeconds(5), ct);
        }
    }

    private async Task ProcessOutboxAsync(CancellationToken ct)
    {
        using var scope = _services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var publisher = scope.ServiceProvider.GetRequiredService<IPublisher>();

        var messages = await db.OutboxMessages
            .Where(m => m.ProcessedAt == null)
            .OrderBy(m => m.CreatedAt)
            .Take(20)                                     // process in batches
            .ToListAsync(ct);

        foreach (var msg in messages)
        {
            try
            {
                var type = Type.GetType(msg.Type)!;
                var @event = (IDomainEvent)JsonSerializer.Deserialize(msg.Payload, type)!;
                await publisher.Publish(@event, ct);      // in-process dispatch
                msg.ProcessedAt = DateTime.UtcNow;
            }
            catch (Exception ex)
            {
                msg.Error = ex.Message;                   // dead-letter: mark failed
            }
        }
        await db.SaveChangesAsync(ct);
    }
}
```

---

### Module Public API — Contracts Between Modules
```csharp
// ── Problem: Billing needs to know if an Order exists ────────────
// BAD: Billing.Application references Orders.Infrastructure.OrderRepository
// GOOD: Orders module exposes a contract (interface) in SharedKernel

// SharedKernel/Contracts/IOrderFacade.cs
public interface IOrderFacade
{
    Task<OrderSummary?> GetOrderSummaryAsync(Guid orderId, CancellationToken ct = default);
}

// record in SharedKernel — value object safe to share
public record OrderSummary(Guid Id, string CustomerId, decimal Total, string Status);

// Orders.Infrastructure implements the facade
public class OrderFacade : IOrderFacade
{
    private readonly OrdersDbContext _db;
    public async Task<OrderSummary?> GetOrderSummaryAsync(Guid orderId, CancellationToken ct)
    {
        return await _db.Orders
            .Where(o => o.Id == orderId)
            .Select(o => new OrderSummary(o.Id, o.CustomerId, o.TotalAmount.Amount, o.Status.ToString()))
            .FirstOrDefaultAsync(ct);
    }
}

// Billing can now use IOrderFacade — no direct DB dependency
public class GenerateInvoiceHandler : IRequestHandler<GenerateInvoiceCommand>
{
    private readonly IOrderFacade _orders;   // registered by Orders module
    public async Task Handle(GenerateInvoiceCommand cmd, CancellationToken ct)
    {
        var order = await _orders.GetOrderSummaryAsync(cmd.OrderId, ct)
            ?? throw new NotFoundException($"Order {cmd.OrderId}");
        // ... generate invoice
    }
}
```

---

### EF Core Per-Module: Separate DbContext + Schema
```csharp
// Orders module gets its own DbContext — COMPLETELY isolated from Billing.DbContext
public class OrdersDbContext : DbContext
{
    public OrdersDbContext(DbContextOptions<OrdersDbContext> options) : base(options) { }

    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    protected override void OnModelCreating(ModelBuilder model)
    {
        model.HasDefaultSchema("orders");           // WHY: schema isolation in SQL Server

        model.Entity<Order>(b =>
        {
            b.ToTable("Orders");                    // orders.Orders
            b.HasKey(o => o.Id);
            b.Property(o => o.CustomerId).HasMaxLength(100).IsRequired();
            b.OwnsOne(o => o.TotalAmount, m =>      // WHY: Money is a value object
            {
                m.Property(x => x.Amount).HasColumnName("TotalAmount").HasColumnType("decimal(18,2)");
                m.Property(x => x.Currency).HasColumnName("Currency").HasMaxLength(3);
            });
            b.HasMany(o => o.Lines).WithOne()
                .HasForeignKey("OrderId").OnDelete(DeleteBehavior.Cascade);
        });
    }
}

// Migrations are PER DbContext (separate migrations folder per module)
// Orders: dotnet ef migrations add Init --context OrdersDbContext --output-dir Migrations/Orders
// Billing: dotnet ef migrations add Init --context BillingDbContext --output-dir Migrations/Billing
```

---

### Full Request Flow — Order to Billing (End to End)
```
Browser / API Client
       │
       ▼  POST /api/orders
  ┌────────────────────────────────────────────────────┐
  │  Orders.API — OrderEndpoints.MapPost               │
  │  → ISender.Send(CreateOrderCommand)                │
  └────────────────────┬───────────────────────────────┘
                       │  MediatR pipeline:
                       │  LoggingBehavior
                       │  ValidationBehavior (FluentValidation)
                       │  UnitOfWorkBehavior
                       ▼
  ┌────────────────────────────────────────────────────┐
  │  CreateOrderCommandHandler                         │
  │  → Order.Create(customerId, items)                 │
  │  → order.AddDomainEvent(OrderCreatedEvent)         │
  │  → _repo.AddAsync(order)                           │
  └────────────────────┬───────────────────────────────┘
                       │  UnitOfWorkBehavior:
                       │  → writes OrderCreatedEvent → OutboxMessages
                       │  → SaveChanges (Order + OutboxMessage in 1 TX)
                       │  → Returns 201 Created to client
                       │
  ┌────────────────────▼───────────────────────────────┐
  │  OutboxProcessor (background, 5s loop)             │
  │  → reads OutboxMessages WHERE ProcessedAt IS NULL  │
  │  → IPublisher.Publish(OrderCreatedEvent)           │
  └────────────────────┬───────────────────────────────┘
                       │  MediatR dispatches to ALL handlers:
                       ▼
  ┌─────────────────────────────┐  ┌─────────────────────────┐
  │  Billing module             │  │  Notifications module   │
  │  ChargeCustomerHandler      │  │  SendConfirmationEmail  │
  │  → creates Invoice          │  │  → enqueues email       │
  └─────────────────────────────┘  └─────────────────────────┘
```

---

### Modular Monolith vs Microservices vs Monolith
| Dimension | Monolith | Modular Monolith | Microservices |
|-----------|----------|-----------------|---------------|
| Deployment | Single | Single | Per service |
| DB | Shared schema | Separate schema per module | Separate DB per service |
| Communication | Direct call | In-process events / facades | HTTP/gRPC/queue |
| Cross-module join | Direct SQL JOIN | Facade or event-driven | API call |
| Complexity | Low | Medium | High |
| Scalability | Whole app | Whole app | Per service |
| Distributed tracing | Not needed | Not needed | Required |
| Testing | Simple | Medium (DI isolation) | Complex (contracts) |
| Best for | MVP / small teams | Growing teams, unclear bounds | Large teams, proven bounds |

### Key Interview Q&A

**Q: How does a modular monolith differ from a clean architecture monolith?**
> Clean Architecture is about **layer boundaries** (Domain → Application → Infrastructure). Modular Monolith is about **domain/feature boundaries** — each module is a vertical slice with its own layers. A modular monolith can use clean architecture within each module.

**Q: What is the Outbox pattern and why do you need it?**
> Without an outbox, you face the "dual write" problem: save to DB AND publish an event — if one fails, you get inconsistency. The Outbox writes events to the SAME DB transaction as data, then a background processor reliably publishes them separately. This gives at-least-once delivery without distributed transactions.

**Q: How do modules communicate without sharing the DB?**
> Two patterns: (1) **Facade** — one module exposes an `IOrderFacade` interface in SharedKernel; the other module's handler uses it via DI. (2) **Domain events** — modules subscribe to events via MediatR `INotificationHandler`. The Outbox pattern makes this reliable. No cross-module EF `DbContext` access ever.

**Q: How do you prevent modules from sharing database tables?**
> (1) Separate `DbContext` per module (different schema prefix: `orders.*`, `billing.*`). (2) Architecture tests (NetArchTest) that verify no cross-module EF `DbSet` access. (3) Each module owns migrations for its schema. (4) Read-only facade contracts if one module needs another's data.

**Q: When would you extract a module into a microservice?**
> When: (1) Module needs independent scaling. (2) Module needs a different deployment cadence. (3) Team ownership requires isolation. (4) Different tech stack. The modular design makes extraction MUCH safer — event contracts and interfaces are already defined.

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

---

### useMemo — Deep Dive

```
┌───────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: useMemo = Spreadsheet cell with a formula         │
│  Only recalculates when its inputs (dependencies) change.        │
│  The rest of the time it returns the cached result.             │
│                                                                   │
│  Two purposes:                                                    │
│  1. Skip expensive computation on every render                   │
│  2. Preserve REFERENTIAL IDENTITY of objects/arrays              │
│     (so React.memo children don't re-render)                     │
└───────────────────────────────────────────────────────────────────┘
```

#### Purpose 1 — Skip Expensive Computation
```tsx
// PROBLEM: expensive filter/sort runs on EVERY render, even when
// unrelated state changes (e.g., a modal opens, a counter ticks)
function OrderDashboard({ orders, filters, theme }) {
    // ❌ BAD — runs on every render
    const filtered = orders
        .filter(o => o.status === filters.status && o.total >= filters.minAmount)
        .sort((a, b) => b.createdAt - a.createdAt);
    // If orders = 50,000 items, this is heavy work every time theme changes.

    return <div className={theme}><OrderTable data={filtered} /></div>;
}

// ✅ GOOD — only recomputes when orders or filters change
function OrderDashboard({ orders, filters, theme }) {
    const filtered = useMemo(
        () => orders
            .filter(o => o.status === filters.status && o.total >= filters.minAmount)
            .sort((a, b) => b.createdAt - a.createdAt),
        [orders, filters.status, filters.minAmount]  // ← NOT theme
        // WHY: theme is not in deps → theme change skips this computation
    );

    return <div className={theme}><OrderTable data={filtered} /></div>;
}
```

#### Purpose 2 — Referential Identity (The Hidden Power)
```tsx
// PROBLEM: object created inline gets a NEW reference on every render
// even if values are the same → React.memo child always re-renders

const ParentComponent = ({ userId }) => {
    const [count, setCount] = useState(0);

    // ❌ BAD — new object reference every render (count changes → new obj)
    const apiConfig = { endpoint: '/api/orders', userId };
    //  apiConfig === apiConfig (previous render) → FALSE (different reference)
    //  React.memo(OrderList) sees new prop → re-renders even though userId unchanged

    return (
        <>
            <button onClick={() => setCount(c => c + 1)}>{count}</button>
            <OrderList config={apiConfig} />  {/* always re-renders! */}
        </>
    );
};

// ✅ GOOD — stable reference, only changes when userId changes
const ParentComponent = ({ userId }) => {
    const [count, setCount] = useState(0);

    const apiConfig = useMemo(
        () => ({ endpoint: '/api/orders', userId }),
        [userId]  // same object reference until userId changes
    );

    return (
        <>
            <button onClick={() => setCount(c => c + 1)}>{count}</button>
            <OrderList config={apiConfig} />  {/* skips re-render when count changes */}
        </>
    );
};

// Same problem with arrays:
// ❌ BAD
const columns = ['id', 'status', 'total'];  // new array every render

// ✅ GOOD — if columns never change, define OUTSIDE the component
const COLUMNS = ['id', 'status', 'total'];  // module-level constant

// Or if columns depend on props:
const columns = useMemo(
    () => visibleFields.map(f => ({ key: f, label: t(f) })),
    [visibleFields, t]
);
```

#### The Dependency Array — Common Mistakes
```tsx
// MISTAKE 1: Missing dependency → stale value
const total = useMemo(() => {
    return items.reduce((sum, i) => sum + i.price * quantity, 0);
    //                                              ^^^^^^^^
}, [items]);  // ← quantity missing! Uses stale quantity from closure

// FIX: include ALL variables from outer scope used inside
const total = useMemo(() => {
    return items.reduce((sum, i) => sum + i.price * quantity, 0);
}, [items, quantity]);

// MISTAKE 2: Object/function in deps → new reference every render → memo never hits
const config = { pageSize: 10 };  // new object each render
const result = useMemo(() => processData(data, config), [data, config]);
// config is a new object every render → useMemo recomputes every time!

// FIX: either destructure stable primitives or memoize the config too
const { pageSize } = config;
const result = useMemo(() => processData(data, pageSize), [data, pageSize]);

// MISTAKE 3: Over-memoizing trivial computations
// ❌ POINTLESS — comparison + memo overhead > computation cost
const isValid = useMemo(() => name.length > 0, [name]);
// FIX: just inline it
const isValid = name.length > 0;

// MISTAKE 4: Using useMemo for side effects
// ❌ WRONG — useMemo is for values, not side effects
useMemo(() => {
    fetch('/api/log', { method: 'POST', body: JSON.stringify({ event: 'viewed' }) });
}, [userId]);
// FIX: use useEffect for side effects
```

#### When to Use vs NOT Use useMemo
```
USE useMemo when:
✓ Computation > ~1ms (filter/sort/map on >1000 items, complex math)
✓ Result is an object/array passed as prop to a React.memo component
✓ Result is used as a dependency in useEffect or useCallback
✓ Heavy chart/graph data transformations (D3, Recharts data prep)

SKIP useMemo when:
✗ Simple calculations (string concat, boolean check, field access)
✗ Component renders infrequently anyway (<10 renders expected)
✗ The value is a primitive (number, string) — primitives compare by value
✗ You're not sure — profile first with React DevTools Profiler

RULE: Profile before memoizing. Premature useMemo adds code complexity
      and the memoization itself has overhead (closure + comparison).
      useMemo shines when you MEASURE a render performance problem.
```

---

### useCallback — Deep Dive

```
┌───────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: useCallback = useMemo for functions               │
│  useMemo(() => value, deps)    → memoized VALUE                  │
│  useCallback(fn, deps)         → memoized FUNCTION REFERENCE     │
│                                                                   │
│  They are identical under the hood:                              │
│  useCallback(fn, deps) === useMemo(() => fn, deps)              │
│                                                                   │
│  Purpose: give a STABLE function reference so child components   │
│  wrapped in React.memo don't re-render just because the parent   │
│  re-rendered (which would create a new function object).         │
└───────────────────────────────────────────────────────────────────┘
```

#### The Core Problem It Solves
```tsx
// Why functions cause unnecessary re-renders:

function ParentList({ items }) {
    const [filter, setFilter] = useState('all');

    // ❌ BAD: new function reference on every render (even filter unchanged)
    const handleDelete = (id: string) => {
        deleteItem(id);
    };

    return items.map(item =>
        // React.memo on Row is USELESS — handleDelete is always new
        <Row key={item.id} item={item} onDelete={handleDelete} />
    );
}

// ✅ GOOD: stable reference — only changes if deleteItem changes
function ParentList({ items }) {
    const [filter, setFilter] = useState('all');

    const handleDelete = useCallback((id: string) => {
        deleteItem(id);
    }, [deleteItem]);  // ← only recreate if deleteItem changes

    return items.map(item =>
        // Now React.memo on Row actually works — same function reference
        <Row key={item.id} item={item} onDelete={handleDelete} />
    );
}

const Row = React.memo(({ item, onDelete }: RowProps) => {
    console.log('Row rendered:', item.id);  // only logs when item or onDelete changes
    return <button onClick={() => onDelete(item.id)}>{item.name}</button>;
});
```

#### The Stale Closure Problem — The Most Common Bug
```tsx
// PROBLEM: function captures value from render at the time it was created
function Counter() {
    const [count, setCount] = useState(0);

    // ❌ BAD: handleClick closes over the INITIAL count (0)
    //         useCallback with [] deps → created once → always sees count = 0
    const handleClick = useCallback(() => {
        setCount(count + 1);  // count is stale — always 0!
    }, []);  // ← count not in deps → stale closure

    // After 3 clicks: count still shows 1, not 3!
}

// ✅ FIX 1: Add count to dependencies (function recreated when count changes)
const handleClick = useCallback(() => {
    setCount(count + 1);
}, [count]);  // ← now captures current count, but function recreates often

// ✅ FIX 2: Functional update (BEST — no stale closure, stable reference)
const handleClick = useCallback(() => {
    setCount(prev => prev + 1);  // ← always gets latest state, NO dep needed
}, []);  // stable reference + correct value ← this is the right pattern

// ✅ FIX 3: useRef for values you need in callback but don't want as deps
function useEventCallback<T extends (...args: any[]) => any>(fn: T): T {
    const ref = useRef(fn);
    useLayoutEffect(() => { ref.current = fn; });  // always points to latest fn
    return useCallback((...args: any[]) => ref.current(...args), []) as T;
}
// Usage: const stableHandler = useEventCallback(expensiveCallback);
// → stable reference, always calls latest version — useful for event handlers
```

#### useCallback with useEffect Dependencies — Avoiding Infinite Loops
```tsx
// PROBLEM: function in useEffect deps → recreated on render → effect runs → state changes → render → loop
function SearchComponent({ query }) {
    const [results, setResults] = useState([]);

    // ❌ BAD: fetchResults is new every render → useEffect runs every render
    const fetchResults = async () => {
        const data = await api.search(query);
        setResults(data);
    };

    useEffect(() => {
        fetchResults();
    }, [fetchResults]);  // ← new function every render → infinite loop!
}

// ✅ FIX 1: useCallback stabilizes fetchResults
function SearchComponent({ query }) {
    const [results, setResults] = useState([]);

    const fetchResults = useCallback(async () => {
        const data = await api.search(query);
        setResults(data);
    }, [query]);  // ← only recreates when query changes (correct!)

    useEffect(() => {
        fetchResults();
    }, [fetchResults]);  // ← runs only when query changes, no loop
}

// ✅ FIX 2 (simpler): inline the function inside useEffect (eliminate useCallback)
function SearchComponent({ query }) {
    const [results, setResults] = useState([]);

    useEffect(() => {
        const fetchResults = async () => {
            const data = await api.search(query);
            setResults(data);
        };
        fetchResults();
    }, [query]);  // ← query is primitive → React compares by value, no loop
    // WHY: if function isn't used outside useEffect, no need to hoist it out
}
```

#### Practical useCallback Patterns
```tsx
// Pattern 1: Stable event handlers for large lists
function OrderTable({ orders }: { orders: Order[] }) {
    const [selectedId, setSelectedId] = useState<string | null>(null);

    // Without useCallback: new fn every render → all 1000 OrderRow re-render
    // With useCallback: stable fn → only clicked row re-renders (if memo'd)
    const handleSelect = useCallback((id: string) => {
        setSelectedId(id);
    }, []);  // ← no deps: setSelectedId from useState is always stable

    return orders.map(o =>
        <OrderRow key={o.id} order={o} onSelect={handleSelect} isSelected={o.id === selectedId} />
    );
}

// Pattern 2: Callbacks passed to custom hooks
function useOrderActions(orderId: string) {
    const approve = useCallback(async () => {
        await api.approveOrder(orderId);
    }, [orderId]);  // recreates only when orderId changes

    const reject = useCallback(async (reason: string) => {
        await api.rejectOrder(orderId, reason);
    }, [orderId]);

    return { approve, reject };
}

// Pattern 3: Debounced search with useCallback
function SearchBar({ onSearch }: { onSearch: (q: string) => void }) {
    // Memoize the debounced function so it's not recreated on each render
    const debouncedSearch = useCallback(
        debounce((query: string) => onSearch(query), 300),
        [onSearch]  // stable if parent wrapped onSearch in useCallback
    );

    return <input onChange={e => debouncedSearch(e.target.value)} />;
}

// Pattern 4: useCallback with parameters via closure
function TodoList({ todos }: { todos: Todo[] }) {
    const handleToggle = useCallback((id: string) => {
        // id captured in closure from each call-site
        dispatch({ type: 'TOGGLE', payload: id });
    }, [dispatch]);  // dispatch from useReducer is always stable

    return todos.map(todo => (
        <TodoItem
            key={todo.id}
            todo={todo}
            onToggle={() => handleToggle(todo.id)}  // ← ⚠️ this creates new fn
            // Better: pass handleToggle and have TodoItem call it with own id
            onToggle={handleToggle}  // ← TodoItem calls: onToggle(todo.id)
        />
    ));
}
```

#### useMemo vs useCallback vs React.memo — The Full Picture
```
┌──────────────────┬──────────────────────────┬───────────────────────────────────────┐
│                  │ What it memoizes         │ When to use                           │
├──────────────────┼──────────────────────────┼───────────────────────────────────────┤
│ useMemo          │ A computed VALUE          │ Expensive computation, referentially  │
│                  │ (any JS value)            │ stable object/array for child props   │
├──────────────────┼──────────────────────────┼───────────────────────────────────────┤
│ useCallback      │ A FUNCTION reference      │ Handler passed to React.memo child,   │
│                  │                          │ function used as useEffect dependency  │
├──────────────────┼──────────────────────────┼───────────────────────────────────────┤
│ React.memo       │ A COMPONENT's output      │ Child component re-renders too often, │
│                  │ (skips re-render)         │ props are stable (primitives or memo'd)│
└──────────────────┴──────────────────────────┴───────────────────────────────────────┘

They work TOGETHER:
  React.memo(Child)         → only re-renders if props change (by reference)
  useCallback(fn, [])       → stable function ref → React.memo sees same prop
  useMemo(() => obj, [dep]) → stable object ref  → React.memo sees same prop

If you use React.memo WITHOUT useCallback/useMemo on parent functions/objects:
  React.memo is useless — the prop reference always changes.

CORRECT SEQUENCE:
  1. Measure with React DevTools Profiler (is this component actually slow?)
  2. If yes: wrap in React.memo
  3. If parent passes functions → wrap those in useCallback
  4. If parent passes objects/arrays → wrap those in useMemo
```

---

### Redux Toolkit (RTK) — Complete Guide

```
┌───────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Redux = Single Source of Truth                    │
│  All app state in ONE store (a big JavaScript object)           │
│  State is READ-ONLY — only actions can change it                │
│  Reducers = pure functions: (state, action) → newState          │
│                                                                   │
│  Redux Toolkit = Redux + Immer + Thunk + DevTools baked in      │
│  "Redux without the boilerplate"                                 │
│                                                                   │
│  Data flow (unidirectional):                                     │
│  UI → dispatch(action) → reducer → new state → UI re-renders   │
└───────────────────────────────────────────────────────────────────┘
```

#### Core Architecture
```
Store
├── ordersSlice    (state.orders)
│   ├── state: { items[], status, error, filters }
│   ├── reducers: setFilter, clearAll
│   └── extraReducers: fetchOrders.pending/fulfilled/rejected
│
├── authSlice      (state.auth)
│   ├── state: { user, token, isAuthenticated }
│   └── reducers: setUser, logout
│
└── cartSlice      (state.cart)
    ├── state: { items[], total }
    └── reducers: addItem, removeItem, updateQty, clear
```

#### Step 1 — createSlice (Reducers + Actions in One)
```tsx
// npm install @reduxjs/toolkit react-redux

import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface OrdersState {
    items: Order[];
    status: 'idle' | 'loading' | 'succeeded' | 'failed';
    error: string | null;
    filters: {
        status: string;
        dateRange: [string, string] | null;
    };
    selectedOrderId: string | null;
}

const initialState: OrdersState = {
    items: [],
    status: 'idle',
    error: null,
    filters: { status: 'all', dateRange: null },
    selectedOrderId: null,
};

export const ordersSlice = createSlice({
    name: 'orders',   // WHY: prefix for all action types: 'orders/setFilter'

    initialState,

    reducers: {
        // WHY: Immer is built-in — you CAN "mutate" state here safely.
        //      Immer intercepts mutations and produces immutable updates.

        setFilter: (state, action: PayloadAction<Partial<OrdersState['filters']>>) => {
            state.filters = { ...state.filters, ...action.payload };
            // Looks like mutation but Immer makes this immutable internally
        },

        selectOrder: (state, action: PayloadAction<string | null>) => {
            state.selectedOrderId = action.payload;
        },

        orderUpdated: (state, action: PayloadAction<Order>) => {
            const idx = state.items.findIndex(o => o.id === action.payload.id);
            if (idx !== -1) {
                state.items[idx] = action.payload;  // Immer: direct assignment OK!
            }
        },

        clearOrders: (state) => {
            state.items = [];
            state.status = 'idle';
            state.error = null;
        },

        // Prepare callback: transform payload before it reaches reducer
        orderAdded: {
            reducer: (state, action: PayloadAction<Order>) => {
                state.items.push(action.payload);
            },
            prepare: (order: Partial<Order>) => ({
                payload: {
                    id: crypto.randomUUID(),
                    createdAt: new Date().toISOString(),
                    status: 'Pending',
                    ...order,
                } as Order
            })
        }
    },

    // extraReducers: handle actions from OUTSIDE this slice (e.g., async thunks)
    extraReducers: (builder) => {
        builder
            .addCase(fetchOrders.pending, (state) => {
                state.status = 'loading';
                state.error = null;
            })
            .addCase(fetchOrders.fulfilled, (state, action) => {
                state.status = 'succeeded';
                state.items = action.payload;           // replace entire list
                // OR: upsert (add new, update existing):
                // ordersAdapter.upsertMany(state, action.payload);
            })
            .addCase(fetchOrders.rejected, (state, action) => {
                state.status = 'failed';
                state.error = action.payload as string ?? action.error.message ?? 'Unknown error';
            })
            // Handle actions from OTHER slices
            .addCase(authSlice.actions.logout, (state) => {
                // Clear orders when user logs out
                return initialState;  // OR: state.items = []
            });
    }
});

// Export actions (auto-generated from reducers object)
export const { setFilter, selectOrder, orderUpdated, clearOrders, orderAdded } = ordersSlice.actions;

// Export reducer (goes into store)
export default ordersSlice.reducer;
```

#### Step 2 — createAsyncThunk (Async Actions)
```tsx
import { createAsyncThunk } from '@reduxjs/toolkit';

// createAsyncThunk auto-generates 3 action types:
//   'orders/fetchOrders/pending'
//   'orders/fetchOrders/fulfilled'
//   'orders/fetchOrders/rejected'

export const fetchOrders = createAsyncThunk(
    'orders/fetchOrders',          // action type prefix
    async (filters: OrderFilters, thunkAPI) => {
        try {
            const response = await api.getOrders(filters);
            return response.data;  // becomes action.payload in .fulfilled
        } catch (err: any) {
            // Return a rejected action with custom error payload
            return thunkAPI.rejectWithValue(err.response?.data?.message ?? err.message);
        }
    },
    {
        // Prevent duplicate concurrent requests (if already fetching, skip)
        condition: (_, { getState }) => {
            const { orders } = getState() as RootState;
            return orders.status !== 'loading';  // false = cancel this dispatch
        }
    }
);

// Thunk with multiple dispatches (for complex workflows)
export const approveOrderWithNotification = createAsyncThunk(
    'orders/approve',
    async (orderId: string, { dispatch, getState }) => {
        const order = await api.approveOrder(orderId);

        // Dispatch other actions from within a thunk
        dispatch(orderUpdated(order));
        dispatch(notificationsSlice.actions.add({
            type: 'success',
            message: `Order ${orderId} approved`
        }));

        return order;
    }
);

// Dispatch with result handling (in a component):
const handleApprove = async (id: string) => {
    const resultAction = await dispatch(approveOrderWithNotification(id));

    if (approveOrderWithNotification.fulfilled.match(resultAction)) {
        toast.success('Approved!');
    } else {
        toast.error(resultAction.error.message ?? 'Failed');
    }
};
```

#### Step 3 — configureStore
```tsx
// store/index.ts
import { configureStore } from '@reduxjs/toolkit';
import ordersReducer from './ordersSlice';
import authReducer from './authSlice';
import cartReducer from './cartSlice';
import { ordersApi } from './ordersApiSlice';  // RTK Query (see below)

export const store = configureStore({
    reducer: {
        orders: ordersReducer,
        auth: authReducer,
        cart: cartReducer,
        [ordersApi.reducerPath]: ordersApi.reducer,  // RTK Query reducer
    },

    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
            // Customize serializability check (warn if non-serializable in state)
            serializableCheck: {
                ignoredActions: ['persist/PERSIST'],  // if using redux-persist
            }
        })
        .concat(ordersApi.middleware)    // RTK Query middleware (cache, polling)
        .concat(loggingMiddleware),      // custom middleware

    devTools: process.env.NODE_ENV !== 'production',
    // WHY: Redux DevTools — time-travel, action log, state diff
    //      NEVER enable in production (exposes full state tree)
});

// TypeScript: infer types from store
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// Typed hooks (use THESE instead of raw useSelector/useDispatch)
export const useAppSelector = useSelector.withTypes<RootState>();
export const useAppDispatch = useDispatch.withTypes<AppDispatch>();
```

#### Step 4 — useSelector & useDispatch in Components
```tsx
// Typed selectors (always use typed versions)
import { useAppSelector, useAppDispatch } from '../store';
import { setFilter, fetchOrders, selectOrder } from '../store/ordersSlice';

function OrderDashboard() {
    const dispatch = useAppDispatch();

    // ── useSelector — subscribe to slice of state ──────────────────────────
    const orders = useAppSelector(state => state.orders.items);
    const status = useAppSelector(state => state.orders.status);
    const filters = useAppSelector(state => state.orders.filters);
    const user = useAppSelector(state => state.auth.user);

    // ── Memoized selector (avoid expensive recomputation) ──────────────────
    // Re-runs only when orders or filters change (not on every selector call)
    const filteredOrders = useAppSelector(state =>
        state.orders.items.filter(o =>
            filters.status === 'all' || o.status === filters.status
        )
    );
    // ⚠️ Problem: inline function in useSelector creates new result array
    //             every render → causes re-render of any component using it.
    // Fix: use createSelector (see Selectors section below)

    // ── Dispatch actions ────────────────────────────────────────────────────
    useEffect(() => {
        if (status === 'idle') {
            dispatch(fetchOrders(filters));  // async thunk
        }
    }, [dispatch, status, filters]);

    const handleFilterChange = (newFilter: string) => {
        dispatch(setFilter({ status: newFilter }));  // sync action
    };

    const handleSelect = (id: string) => {
        dispatch(selectOrder(id));
    };

    if (status === 'loading') return <Spinner />;
    if (status === 'failed') return <Error />;

    return (
        <div>
            <FilterBar value={filters.status} onChange={handleFilterChange} />
            {filteredOrders.map(o =>
                <OrderCard key={o.id} order={o} onClick={() => handleSelect(o.id)} />
            )}
        </div>
    );
}
```

#### Step 5 — createSelector (Memoized Selectors — Reselect)
```tsx
import { createSelector } from '@reduxjs/toolkit';  // reselect is built-in

// WHY: useAppSelector with inline function = new array ref every call
//      createSelector memoizes → only recomputes when inputs change

// Input selectors (cheap, grab raw state)
const selectAllOrders = (state: RootState) => state.orders.items;
const selectFilter = (state: RootState) => state.orders.filters.status;
const selectMinAmount = (state: RootState) => state.orders.filters.minAmount;

// Output selector (expensive, memoized)
export const selectFilteredOrders = createSelector(
    [selectAllOrders, selectFilter, selectMinAmount],  // input selectors
    (orders, statusFilter, minAmount) => {             // result function
        // Only runs when orders, statusFilter, or minAmount change
        return orders
            .filter(o => statusFilter === 'all' || o.status === statusFilter)
            .filter(o => o.total >= (minAmount ?? 0))
            .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    }
);

// Selector with parameters (factory pattern)
export const makeSelectOrdersByCustomer = () =>
    createSelector(
        [selectAllOrders, (_: RootState, customerId: string) => customerId],
        (orders, customerId) => orders.filter(o => o.customerId === customerId)
    );

// Usage in component:
function CustomerOrders({ customerId }: { customerId: string }) {
    // Create selector instance PER component instance (not shared — avoids cache collision)
    const selectOrdersByCustomer = useMemo(makeSelectOrdersByCustomer, []);
    const orders = useAppSelector(state => selectOrdersByCustomer(state, customerId));
    // ← memoized: only recomputes when state.orders.items or customerId changes
}
```

#### Step 6 — RTK Query (Data Fetching Built Into Redux)
```tsx
// WHY: RTK Query = React Query but integrated with Redux store.
//      Auto-generates hooks, caches responses, handles loading/error states,
//      tags-based cache invalidation. For API-heavy apps with Redux already.

import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const ordersApi = createApi({
    reducerPath: 'ordersApi',    // key in Redux store
    baseQuery: fetchBaseQuery({
        baseUrl: '/api/',
        // Auth header on every request:
        prepareHeaders: (headers, { getState }) => {
            const token = (getState() as RootState).auth.token;
            if (token) headers.set('Authorization', `Bearer ${token}`);
            return headers;
        }
    }),
    tagTypes: ['Order', 'Customer'],  // for cache invalidation

    endpoints: (builder) => ({
        // ── GET (query) ────────────────────────────────────────────────────
        getOrders: builder.query<Order[], OrderFilters>({
            query: (filters) => ({
                url: 'orders',
                params: filters,
            }),
            providesTags: (result) =>
                result
                    ? [...result.map(({ id }) => ({ type: 'Order' as const, id })),
                       { type: 'Order', id: 'LIST' }]
                    : [{ type: 'Order', id: 'LIST' }],
            // WHY: providesTags — tells RTK Query WHICH cache entries this
            //      query populates. When invalidated, auto-refetch triggers.
        }),

        getOrderById: builder.query<Order, string>({
            query: (id) => `orders/${id}`,
            providesTags: (_, __, id) => [{ type: 'Order', id }],
        }),

        // ── POST/PUT/DELETE (mutation) ─────────────────────────────────────
        createOrder: builder.mutation<Order, CreateOrderRequest>({
            query: (body) => ({
                url: 'orders',
                method: 'POST',
                body,
            }),
            invalidatesTags: [{ type: 'Order', id: 'LIST' }],
            // WHY: invalidatesTags — after create, RTK Query auto-refetches
            //      any query that providesTags matching 'Order LIST'.
        }),

        updateOrderStatus: builder.mutation<Order, { id: string; status: string }>({
            query: ({ id, ...body }) => ({
                url: `orders/${id}/status`,
                method: 'PATCH',
                body,
            }),
            invalidatesTags: (_, __, { id }) => [
                { type: 'Order', id },           // invalidate this specific order
                { type: 'Order', id: 'LIST' },   // invalidate the list
            ],
            // Optimistic update (show change immediately, rollback on error)
            async onQueryStarted({ id, status }, { dispatch, queryFulfilled }) {
                const patch = dispatch(
                    ordersApi.util.updateQueryData('getOrders', undefined, (draft) => {
                        const order = draft.find(o => o.id === id);
                        if (order) order.status = status;
                    })
                );
                try { await queryFulfilled; }
                catch { patch.undo(); }  // rollback on error
            }
        }),

        deleteOrder: builder.mutation<void, string>({
            query: (id) => ({ url: `orders/${id}`, method: 'DELETE' }),
            invalidatesTags: (_, __, id) => [{ type: 'Order', id }],
        }),
    })
});

// Auto-generated hooks (naming: use + endpoint name + Query/Mutation)
export const {
    useGetOrdersQuery,
    useGetOrderByIdQuery,
    useCreateOrderMutation,
    useUpdateOrderStatusMutation,
    useDeleteOrderMutation,
} = ordersApi;

// ── Usage in component ────────────────────────────────────────────────────
function OrderList({ filters }: { filters: OrderFilters }) {
    // Automatic: loading, error, caching, background refetch, deduplication
    const {
        data: orders,
        isLoading,        // true ONLY on first load (no cached data)
        isFetching,       // true on any fetch (including background refresh)
        isError,
        error,
        refetch           // manually trigger refetch
    } = useGetOrdersQuery(filters, {
        pollingInterval: 30_000,    // auto-refetch every 30s
        skip: !filters.customerId,  // don't fetch if no customerId
        refetchOnMountOrArgChange: true,  // refetch if component remounts
        selectFromResult: ({ data, ...rest }) => ({
            // Transform/filter before component receives it (memoized):
            data: data?.filter(o => o.priority === 'High'),
            ...rest
        })
    });

    const [updateStatus, { isLoading: isUpdating }] = useUpdateOrderStatusMutation();

    const handleApprove = async (id: string) => {
        try {
            await updateStatus({ id, status: 'Approved' }).unwrap();
            // .unwrap() → throws on error (instead of returning error object)
            toast.success('Approved!');
        } catch (err) {
            toast.error('Failed to approve');
        }
    };

    if (isLoading) return <Spinner />;
    if (isError) return <Error message={error.toString()} />;

    return (
        <ul>
            {orders?.map(o => (
                <li key={o.id}>
                    {o.id}
                    <button onClick={() => handleApprove(o.id)} disabled={isUpdating}>
                        Approve
                    </button>
                </li>
            ))}
        </ul>
    );
}
```

#### Redux Middleware — Custom Logging / Error Handling
```tsx
// Custom middleware (runs between dispatch and reducer)
const loggingMiddleware = (store: MiddlewareAPI) => (next: Dispatch) => (action: Action) => {
    console.group(action.type);
    console.log('dispatching:', action);
    const result = next(action);           // call next middleware / reducer
    console.log('next state:', store.getState());
    console.groupEnd();
    return result;
};

const errorMiddleware = (store: MiddlewareAPI) => (next: Dispatch) => (action: Action) => {
    if (action.type.endsWith('/rejected')) {
        // Centralized error logging for all failed async thunks
        const payload = (action as any).payload;
        const error = (action as any).error;
        Sentry.captureException(new Error(payload ?? error?.message), {
            extra: { action: action.type }
        });
    }
    return next(action);
};
```

#### Redux Toolkit vs Zustand vs Context
```
┌─────────────────────┬──────────────────┬─────────────────┬───────────────────┐
│ Criteria            │ Redux Toolkit    │ Zustand         │ Context API       │
├─────────────────────┼──────────────────┼─────────────────┼───────────────────┤
│ Boilerplate         │ Medium (RTK low) │ Very low        │ Low               │
│ Bundle size         │ ~12KB            │ ~1KB            │ 0 (built-in)      │
│ DevTools            │ Excellent        │ Good            │ Basic             │
│ Time-travel debug   │ Yes              │ Yes (middleware) │ No                │
│ Async actions       │ createAsyncThunk │ Manual/async fn  │ Manual useEffect  │
│ Data fetching       │ RTK Query        │ Needs React Query│ Needs React Query │
│ Learning curve      │ High             │ Very Low        │ Low               │
│ Team convention     │ Forces patterns  │ Flexible        │ Flexible          │
│ Best for            │ Large teams,     │ Medium apps,    │ Auth/theme/locale │
│                     │ complex flows,   │ quick state,    │ low-freq updates  │
│                     │ enterprise       │ small teams     │                   │
└─────────────────────┴──────────────────┴─────────────────┴───────────────────┘

DECISION RULE:
  New project + small team → Zustand + React Query
  Enterprise + large team + already using Redux → Redux Toolkit + RTK Query
  Auth/theme only → Context API
  Never mix Redux + React Query for the same data (pick one)
```

#### Redux Interview Q&A

**Q: What is the difference between a reducer and an action?**
> An **action** is a plain object `{ type: string, payload?: any }` — it describes WHAT happened ("order approved"). A **reducer** is a pure function `(state, action) => newState` — it describes HOW state changes in response. Actions are dispatched by the UI; reducers handle them.

**Q: Why must reducers be pure functions?**
> Redux DevTools time-travel works by replaying actions through reducers. If reducers have side effects (API calls, random values, Date.now()), replaying produces different results — time-travel breaks. Pure functions: same input → always same output, no side effects.

**Q: What does Immer do in Redux Toolkit?**
> Immer wraps your reducer with a Proxy that intercepts "mutations". When you write `state.items.push(newItem)` in a slice reducer, Immer records the mutation and produces a new immutable state object. The original state is never modified. This eliminates the spread-heavy `{ ...state, items: [...state.items, newItem] }` pattern.

**Q: createSelector vs inline selector — why does it matter?**
> `useAppSelector(s => s.orders.items.filter(...))` creates a new array reference every call → any component using this selector re-renders on EVERY state change (even unrelated). `createSelector` memoizes: if `s.orders.items` and filter params didn't change, returns the exact same array reference → no unnecessary re-render.

**Q: RTK Query vs React Query — when to choose?**
> RTK Query when you already use Redux and want your server state in the Redux store (single store for everything, shared cache between unrelated components via Redux, powerful DevTools integration). React Query when you want a lighter solution, don't need Redux for other state, or are using Zustand. Both solve the same problem — pick one, don't mix them for the same data.

---

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

---

---

# Appendix: Sample Outputs & How to Read Them

> Every command and query from the guide above — with realistic sample output, field-by-field annotation, and what to look for in production.

---

## A. Azure Container Apps — CLI Outputs

---

### A1. `az containerapp env create` — Output
```json
{
  "id": "/subscriptions/aaaa-bbbb-cccc/resourceGroups/rg-prod/providers/Microsoft.App/managedEnvironments/cae-prod",
  "location": "eastus2",
  "name": "cae-prod",
  "properties": {
    "appLogsConfiguration": {
      "destination": "log-analytics",
      "logAnalyticsConfiguration": {
        "customerId": "workspace-guid-here"
      }
    },
    "defaultDomain": "proudsky-abc123.eastus2.azurecontainerapps.io",
    "provisioningState": "Succeeded",
    "staticIp": "20.55.140.10",
    "zoneRedundant": false
  },
  "type": "Microsoft.App/managedEnvironments"
}
```

**How to read it:**
```
Field                    Meaning & What to Check
─────────────────────────────────────────────────────────────────────
provisioningState        "Succeeded" = env is ready. "Failed" = check
                         Activity Log in Azure Portal for details.

defaultDomain            Every app in this env gets a subdomain under
                         this. e.g. api-service.proudsky-abc123.eastus2
                         .azurecontainerapps.io

staticIp                 Outbound IP of this environment. Whitelist this
                         in your SQL Server / downstream firewall rules.

zoneRedundant            false = single zone (non-prod OK)
                         true  = spans 3 AZs — required for production SLA
```

---

### A2. `az containerapp create` — Output (abbreviated)
```json
{
  "name": "api-service",
  "properties": {
    "configuration": {
      "activeRevisionsMode": "Single",
      "ingress": {
        "external": true,
        "fqdn": "api-service.proudsky-abc123.eastus2.azurecontainerapps.io",
        "targetPort": 80,
        "transport": "Auto"
      }
    },
    "latestReadyRevisionName": "api-service--abc1234",
    "latestRevisionFqdn": "api-service--abc1234.proudsky-abc123.eastus2.azurecontainerapps.io",
    "outboundIpAddresses": ["20.55.140.10"],
    "provisioningState": "Succeeded",
    "runningStatus": "Running",
    "template": {
      "containers": [
        {
          "image": "myacr.azurecr.io/api:v2",
          "name": "api",
          "resources": { "cpu": 0.5, "ephemeralStorage": "2Gi", "memory": "1Gi" }
        }
      ],
      "scale": {
        "maxReplicas": 10,
        "minReplicas": 1
      }
    }
  }
}
```

**How to read it:**
```
Field                        Meaning & What to Check
──────────────────────────────────────────────────────────────────────
fqdn                         Public HTTPS URL for your app. Test with:
                             curl https://api-service.proudsky...io/health

latestReadyRevisionName      Format: <app-name>--<hash>. Each deploy
                             creates a new hash. Use this name when
                             doing traffic splits.

latestRevisionFqdn           Direct URL to THIS revision only — useful
                             for testing canary before routing traffic.

runningStatus                "Running" = replicas are healthy.
                             "Degraded" = some replicas failing → check
                             az containerapp logs show --name api-service

outboundIpAddresses          IPs that downstream services see on requests
                             from this app — whitelist in firewalls.

resources.ephemeralStorage   Temp disk per replica (2Gi default).
                             Writes to /tmp only — not persistent.
```

---

### A3. `az containerapp ingress traffic set` — Output
```json
{
  "fqdn": "api-service.proudsky-abc123.eastus2.azurecontainerapps.io",
  "traffic": [
    {
      "latestRevision": false,
      "revisionName": "api-service--abc1234",
      "weight": 80
    },
    {
      "latestRevision": true,
      "revisionName": "api-service--xyz9999",
      "weight": 20
    }
  ]
}
```

**How to read it:**
```
Field                  Meaning
──────────────────────────────────────────────────────────────────────
traffic[]              Array of revision splits. All weights MUST sum
                       to 100 — CLI enforces this.

latestRevision: false  Named (previous) revision — pinned by name.
weight: 80             80% of traffic → old stable version.

latestRevision: true   Current newest revision.
weight: 20             20% → canary. Monitor error rates here first.
                       When confident: set to weight: 100, remove old.

HOW TO PROMOTE: After canary validation:
  az containerapp ingress traffic set \
    --revision-weight latest=100
  This removes the old revision from traffic automatically.
```

---

### A4. `az containerapp logs show --follow` — Log Stream Format
```
2026-03-05T10:22:01.123Z  api-service  api  info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
2026-03-05T10:22:03.441Z  api-service  api  info: OrderController[0]
      Order created: ord-abc123, customer: c-001
2026-03-05T10:22:03.552Z  api-service  api  warn: Microsoft.AspNetCore.HttpsPolicy[6]
      Response code 200 for GET /health in 2ms
2026-03-05T10:22:15.001Z  api-service  api  fail: OrderService[0]
      Unhandled exception processing order ord-xyz999
      System.TimeoutException: DB connection timeout after 30s
         at OrderRepository.SaveAsync() ...
```

**How to read it:**
```
Column 1 (timestamp)    UTC timestamp — all Container Apps logs in UTC.
                        Match with your App Insights traces using this.

Column 2 (app name)     Container App name — useful in multi-app envs.

Column 3 (container)    Container name within the app (you can have
                        multiple containers in one app via sidecars).

Level keywords          info / warn / fail — scan for "fail" in CI
                        to detect startup errors post-deployment.

USEFUL FILTERS:
  --tail 50             Last 50 lines (no streaming)
  --filter "ERROR"      Show only lines containing "ERROR"
  --format json         Structured JSON output (pipe to jq for queries)

KQL equivalent in Log Analytics:
  ContainerAppConsoleLogs_CL
  | where ContainerAppName_s == "api-service"
  | where Log_s contains "Exception"
  | order by TimeGenerated desc
  | take 50
```

---

## B. SQL Server — DMV Query Sample Outputs

---

### B1. Top 10 Expensive Queries by CPU
```
Sample output (formatted for readability):

avg_cpu_ms  avg_reads  execution_count  query_text
──────────  ─────────  ───────────────  ──────────────────────────────────────────
 48,230        82,100            1,204  SELECT o.*, c.Name FROM Orders o
                                        JOIN Customers c ON o.CustomerId = c.Id
                                        WHERE o.Status = 'Pending'
  9,820        14,500           48,310  SELECT * FROM Orders WHERE YEAR(CreatedAt) = 2024
  3,120         2,900          120,450  SELECT TOP 1 * FROM Orders WHERE OrderId = @p0
    840           320          890,000  SELECT COUNT(*) FROM AuditLog
    210            80        2,100,000  SELECT UserId, Name FROM Users WHERE Email = @p0
```

**How to read it:**
```
Column           What It Tells You
──────────────────────────────────────────────────────────────────────────
avg_cpu_ms       Average CPU time per execution (microseconds in DMV,
                 converted to ms here). Row 1: 48 seconds of CPU per run!
                 → Definitely needs an index or query rewrite.

avg_reads        Logical reads = pages read from buffer pool.
                 82,100 pages × 8KB = ~641 MB read per execution.
                 High reads = missing index (scanning) or SELECT *.

execution_count  How often it runs. Row 3: 120K runs × 3,120ms = massive
                 total CPU. Even a "fast" query × millions of runs = problem.

WHAT TO FIX:
Row 1: avg_reads 82K → run ACTUAL execution plan → likely TABLE SCAN.
       Check for missing index on (Status) INCLUDE (CustomerId, Name).

Row 2: YEAR(CreatedAt) → NON-SARGABLE. Fix:
       WHERE CreatedAt >= '2024-01-01' AND CreatedAt < '2025-01-01'

Row 4: COUNT(*) on AuditLog with 0 avg_reads is suspicious — may be
       using a cached plan from when table was small. UPDATE STATISTICS.
```

---

### B2. Missing Index Recommendations
```
Sample output:

improvement_measure  create_index_statement
───────────────────  ──────────────────────────────────────────────────────────────────
        2,847,234    CREATE INDEX IX_Orders_Status ON dbo.Orders (Status)
                     INCLUDE (CustomerId, TotalAmount, CreatedAt)

          384,910    CREATE INDEX IX_AuditLog_EntityId ON dbo.AuditLog (EntityId, EntityType)
                     INCLUDE (CreatedAt, UserId, Action)

           28,441    CREATE INDEX IX_Users_Email ON dbo.Users (Email)

            1,204    CREATE INDEX IX_Orders_AgentId ON dbo.Orders (AgentId)
                     INCLUDE (Status, CreatedAt)
```

**How to read it:**
```
Column                  Meaning
──────────────────────────────────────────────────────────────────────
improvement_measure     SQL Server's estimated benefit score.
                        = avg_total_user_cost × avg_user_impact
                          × (seeks + scans intercepted)
                        Higher = more benefit. NOT a time estimate.
                        Use as PRIORITY ORDER, not absolute value.

create_index_statement  Ready-to-run T-SQL. BUT:
                        ⚠ Review before executing in prod:
                        1. Check if similar index exists (consolidate)
                        2. Evaluate write overhead (every INSERT/UPDATE
                           must maintain the index)
                        3. Run CREATE INDEX ... WITH (ONLINE=ON) in prod
                           to avoid table lock

RULE OF THUMB:
  improvement_measure > 100,000 → high priority, create ASAP
  improvement_measure 10K–100K  → medium, schedule for next maintenance
  improvement_measure < 10K     → low, batch with other changes
  Also: SQL Server only keeps ~500 missing index suggestions — reset on restart.
```

---

### B3. Currently Running Queries
```
Sample output:

session_id  status   wait_type        wait_time  blocking_session_id  cpu_time  logical_reads  current_statement
──────────  ───────  ───────────────  ─────────  ───────────────────  ────────  ─────────────  ─────────────────────────────────────────────────────────
        55  running  NULL             0          0                    48,210    91,000         SELECT o.*, c.Name FROM Orders o JOIN Customers...
        67  suspended LCK_M_S        12,500     55                   120       200            UPDATE Orders SET Status='Completed' WHERE OrderId=@p0
        71  suspended PAGEIOLATCH_SH 3,200      0                    9,800     45,000         SELECT * FROM AuditLog WHERE CreatedAt > '2024-01-01'
        82  sleeping  ASYNC_NETWORK_IO 28,000   0                    2,100     800            SELECT OrderId, Status FROM Orders WHERE CustomerId=@p0
```

**How to read it:**
```
Column               Meaning & Action
──────────────────────────────────────────────────────────────────────────
status
  running            Actively using CPU right now.
  suspended          Waiting for something (see wait_type).
  sleeping           Query done, waiting for client to fetch results.

wait_type
  NULL               Running — no wait. This is your CPU consumer.
  LCK_M_S (row 67)  Shared lock wait. Blocked by session 55.
                     Session 55 holds a lock that 67 needs.
                     → Kill 55 if it's stuck: KILL 55
                     → Long-term: shorter transactions, RCSI isolation.
  PAGEIOLATCH_SH     Reading pages from disk (not in buffer cache).
  (row 71)           → Add RAM for SQL Server, or fix the scan with index.
  ASYNC_NETWORK_IO   SQL is done, client reading slowly (row 82).
  (row 82)           → App is streaming a large result set. Paginate instead.

wait_time            How long (ms) this wait has lasted. 12,500 = 12.5 sec.
                     Long waits + blocking = user-facing timeouts.

blocking_session_id  Non-zero = this session is BLOCKED by that session.
                     Row 67 blocked by 55. Trace the chain upward
                     to find the ROOT blocker (has blocking_session_id = 0).

logical_reads        91,000 reads for one query → enormous scan.
                     Cross-reference with missing index DMV (B2 above).

IMMEDIATE TRIAGE STEPS:
  1. Find rows where wait_time > 5000 → active incident
  2. Find root blocker (blocking_session_id = 0, status = running/sleeping)
  3. Check their current_statement — is it a long transaction?
  4. If stuck: KILL <session_id> (confirm with dev first)
  5. Long-term: move to RCSI, reduce transaction scope
```

---

### B4. Index Fragmentation
```
Sample output:

table_name   index_name                    avg_fragmentation_pct  page_count
───────────  ────────────────────────────  ─────────────────────  ──────────
Orders       CIX_Orders_Id                 67.3                   284,100     ← REBUILD
Orders       NIX_Orders_CustomerId_Status  34.1                   48,200      ← REBUILD
AuditLog     CIX_AuditLog_Id               22.8                   920,000     ← REORGANIZE
Users        NIX_Users_Email               8.4                    12,300      ← OK
Sessions     NIX_Sessions_Token            2.1                    4,100       ← OK
```

**How to read it:**
```
avg_fragmentation_pct   Threshold → Action
────────────────────────────────────────────────────────────────────────
> 30%                   REBUILD   — rewrites index from scratch (fast reads,
                                    but holds schema lock briefly unless ONLINE)
10–30%                  REORGANIZE — defragments in-place, always online,
                                    slower than rebuild but safe for prod hours
< 10%                   SKIP      — fragmentation not worth fixing

page_count              Index size in 8KB pages.
                        Don't REBUILD tiny indexes (<1000 pages) — overhead
                        not worth it. Focus on large, heavily fragmented ones.

FIX COMMANDS:
  -- Rebuild (large fragmentation, large index)
  ALTER INDEX CIX_Orders_Id ON dbo.Orders
  REBUILD WITH (ONLINE = ON, SORT_IN_TEMPDB = ON);   -- ONLINE avoids lock

  -- Reorganize (medium fragmentation, or non-enterprise edition)
  ALTER INDEX NIX_Orders_CustomerId_Status ON dbo.Orders REORGANIZE;

WHY IT MATTERS:
  Fragmented index = SQL reads extra pages (half-empty pages).
  67% fragmentation on Orders CIX: for every 1000 data pages,
  SQL reads ~1730 pages. That's the extra I/O causing PAGEIOLATCH waits.

SCHEDULE:
  Run this DMV weekly. Automate with SQL Agent job or Ola Hallengren scripts.
```

---

### B5. Blocking Chain
```
Sample output:

blocker  blocked  wait_type  wait_time  blocked_query
───────  ───────  ─────────  ─────────  ────────────────────────────────────────────
55       67       LCK_M_S    15,200     UPDATE Orders SET Status='Completed' WHERE...
55       71       LCK_M_U    14,800     UPDATE Orders SET RetryCount=RetryCount+1...
67       88       LCK_M_X    3,100      SELECT * FROM Orders WITH (UPDLOCK) WHERE...
```

**How to read it:**
```
Reading the chain:
  Session 55 → blocks 67 and 71 directly
  Session 67 → blocks 88 (because 67 is itself blocked, it holds locks too)

  Full chain: 55 → 67 → 88 (and 55 → 71)

Root blocker = 55 (it appears only in the "blocker" column, never in "blocked")

TO DIAGNOSE ROOT BLOCKER (session 55):
  SELECT r.status, r.wait_type, SUBSTRING(t.text,1,500) AS sql_text,
         s.last_request_start_time, s.open_transaction_count
  FROM sys.dm_exec_requests r
  CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
  JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
  WHERE r.session_id = 55;

COMMON ROOT CAUSES:
  open_transaction_count > 0 + status = sleeping
    → App opened a transaction, did work, forgot to COMMIT/ROLLBACK.
      Fix: add try/finally { connection.Rollback() } or use using(var tx=...)

  Long-running UPDATE without index
    → Holds row locks for the duration. Fix: add index, smaller batches.

wait_type meanings on blocked side:
  LCK_M_S   = wants Shared lock (for SELECT)
  LCK_M_U   = wants Update lock (pre-cursor to X)
  LCK_M_X   = wants Exclusive lock (for UPDATE/DELETE)
  LCK_M_SCH_M = Schema modification lock (ALTER TABLE in progress)
```

---

### B6. Statistics Age / Modification Counter
```
Sample output:

table_name   stat_name                  last_updated          rows      rows_sampled  modification_counter
───────────  ─────────────────────────  ────────────────────  ────────  ────────────  ────────────────────
Orders       _WA_Sys_CustomerId_Orders  2026-01-15 03:00:00   8,420,000  84,200        2,840,000     ← STALE
AuditLog     _WA_Sys_EntityId_AuditLog  2026-03-04 03:00:00  45,200,000  452,000       1,200,000     ← STALE
Users        PK_Users                   2026-03-05 02:00:00     420,000  420,000          12,000     ← OK
```

**How to read it:**
```
Column                  Meaning
────────────────────────────────────────────────────────────────────────
last_updated            When SQL last sampled the data distribution.
                        Jan 15 → nearly 2 months old → statistics stale.

rows                    Total rows in the table now.

rows_sampled            How many rows SQL sampled last time it updated stats.
                        84,200 of 8.4M = 1% sample → low accuracy for
                        skewed data distributions.

modification_counter    Rows inserted/updated/deleted since last update.
                        2,840,000 changes on Orders = SQL's estimated row
                        counts (used by query optimizer) are 34% wrong!
                        This causes bad execution plans → slow queries.

AUTO UPDATE threshold:  SQL auto-updates stats when 20% of rows change
                        (for tables < 500K rows). For large tables (8.4M):
                        threshold = 20% = 1.68M → already exceeded here.
                        But auto-update may not have fired yet (async).

FIX:
  UPDATE STATISTICS dbo.Orders WITH FULLSCAN;   -- 100% sample, most accurate
  UPDATE STATISTICS dbo.AuditLog;               -- default sample (faster)

SCHEDULE IN PRODUCTION:
  -- Nightly after index rebuild (rebuild auto-updates stats)
  -- After bulk load operations
  -- When query plans suddenly get worse (first thing to check)
```

---

## C. Cosmos DB — SDK Sample Outputs

---

### C1. Point Read Response
```csharp
var response = await container.ReadItemAsync<Order>(
    id: "ord-abc123",
    partitionKey: new PartitionKey("c-001"));

// Console.WriteLine($"RU consumed: {response.RequestCharge}");
```

```
RU consumed: 1.0
```

**How to read it:**
```
Value   Meaning
──────────────────────────────────────────────────────────────────────
1.0 RU  Point read (id + partitionKey) = always ~1 RU regardless of
        document size (up to 1KB). For larger docs, it scales linearly.
        This is the MINIMUM cost operation in Cosmos DB.

        Compare to a cross-partition query returning 100 docs: ~25–50 RU
        → 25–50x more expensive than point reads.

IMPLICATION: Design your data model so your hot-path operations
             are point reads. Denormalize to avoid joins.
```

---

### C2. Query Iterator — Page-by-Page Output
```csharp
double totalRU = 0;
int pageNumber = 0;
while (iterator.HasMoreResults)
{
    var page = await iterator.ReadNextAsync();
    totalRU += page.RequestCharge;
    pageNumber++;
    Console.WriteLine($"Page {pageNumber}: {page.Count} items, {page.RequestCharge} RU");
}
Console.WriteLine($"Total: {totalRU} RU across {pageNumber} pages");
```

```
-- Single-partition query (customerId = "c-001", 215 matching docs):
Page 1: 100 items, 12.4 RU
Page 2: 100 items, 11.9 RU
Page 3: 15 items, 2.3 RU
Total: 26.6 RU across 3 pages

-- Cross-partition query (no partitionKey filter, same 215 docs, 8 partitions):
Page 1: 100 items, 89.2 RU
Page 2: 100 items, 84.7 RU
Page 3: 15 items, 31.1 RU
Total: 205.0 RU across 3 pages
```

**How to read it:**
```
Scenario              RU     Explanation
─────────────────────────────────────────────────────────────────────
Single-partition      26.6   Only 1 physical partition queried.
                             Cost scales with docs returned + index scan.

Cross-partition       205.0  All 8 partitions queried in parallel,
                             results merged. RU = sum of all partitions.
                             ~7.7× more expensive for same result.

page.RequestCharge           RU for THIS page. Add across pages for total.
                             Log this to Application Insights to track
                             query cost over time.

MaxItemCount = 100           Pages of 100 docs. Smaller pages = more
                             round trips but lower per-request RU.

RULE: If total RU > 50 for a query on your hot path,
      reconsider your partition key or data model.
```

---

### C3. Patch Operation Response
```csharp
var patchResponse = await container.PatchItemAsync<Order>(...);
Console.WriteLine($"Patch RU: {patchResponse.RequestCharge}");
Console.WriteLine($"ETag: {patchResponse.ETag}");
```

```
Patch RU: 10.8
ETag: "00000000-0000-0000-f8c5-b3d2a1e09a00"
```

**How to read it:**
```
Field    Meaning
──────────────────────────────────────────────────────────────────────
Patch RU 10.8 RU for updating 3 fields on one document.
         Compare: full Replace (UpsertItem of whole doc) = ~12–15 RU.
         Patch is cheaper because only modified fields are transmitted.

ETag     Optimistic concurrency token. Store this if you need
         conditional updates (next update passes this ETag via
         ItemRequestOptions.IfMatchEtag — fails with 412 if doc
         was modified by someone else between your read and write).
         Use for: shopping cart, inventory counts, any shared state.
```

---

### C4. Transactional Batch Response
```csharp
using var batchResponse = await batch.ExecuteAsync();
Console.WriteLine($"Batch success: {batchResponse.IsSuccessStatusCode}");
Console.WriteLine($"Total RU: {batchResponse.RequestCharge}");
for (int i = 0; i < batchResponse.Count; i++)
{
    var op = batchResponse[i];
    Console.WriteLine($"  Op[{i}]: {op.StatusCode} ({op.RequestCharge} RU)");
}
```

```
-- SUCCESS case:
Batch success: True
Total RU: 42.3
  Op[0]: Created (10.2 RU)     -- CreateItem: order
  Op[1]: Created (8.1 RU)      -- CreateItem: orderLine1
  Op[2]: Created (8.4 RU)      -- CreateItem: orderLine2
  Op[3]: OK (15.6 RU)          -- PatchItem: cart status

-- FAILURE case (e.g., unique constraint violation on Op[0]):
Batch success: False
Total RU: 3.1
  Op[0]: Conflict (3.1 RU)     -- duplicate id — ENTIRE batch rolled back
  Op[1]: FailedDependency       -- not attempted (batch atomic)
  Op[2]: FailedDependency
  Op[3]: FailedDependency
```

**How to read it:**
```
IsSuccessStatusCode    True = ALL operations committed atomically.
                       False = ALL operations rolled back (atomic guarantee).

StatusCode per op:
  Created (201)        Document created.
  OK (200)             Patch/replace succeeded.
  Conflict (409)       Duplicate id — document already exists.
  FailedDependency     This op not attempted (prior op in batch failed).
  PreconditionFailed   ETag mismatch (optimistic concurrency failure).

RequestCharge per op   RU for individual operation within the batch.
Total RU               Billed even on failure (the index traversal cost).

KEY INSIGHT: Batch = same partitionKey for ALL ops. If you try to
             batch across partition keys → ArgumentException at build time.
```

---

## D. Integration Testing — Test Runner Output

---

### D1. xUnit + TestContainers — Console Output on Run
```
-- Starting test run...

[xUnit.net 00:00:00.12]   Starting: ApiTests
[xUnit.net 00:00:01.30]   Testcontainers: Creating container for image postgres:16-alpine
[xUnit.net 00:00:03.82]   Testcontainers: Container started (id: 3fa7c2b1)
[xUnit.net 00:00:03.83]   Host: localhost, Port: 52341
[xUnit.net 00:00:04.10]   Applying EF Core migrations...
[xUnit.net 00:00:04.88]   Migrations applied. Database ready.
[xUnit.net 00:00:04.90]   WebApplicationFactory: Starting test host...

  OrderTests
    [PASS] CreateOrder_ValidRequest_Returns201WithOrderId             00:00:00.342
    [PASS] CreateOrder_DuplicateIdempotencyKey_Returns200SameOrder    00:00:00.218
    [FAIL] CreateOrder_InvalidCustomerId_Returns422                   00:00:00.119

  ── FAILURE: CreateOrder_InvalidCustomerId_Returns422
     Expected: StatusCode 422 (UnprocessableEntity)
     Actual:   StatusCode 400 (BadRequest)
     at OrderTests.CreateOrder_InvalidCustomerId_Returns422() line 87

  BillingIntegrationTests
    [PASS] ChargeOnOrderCreated_PublishesPaymentEvent                 00:00:00.441
    [PASS] ChargeOnOrderCreated_DBFailure_RollsBackTransaction        00:00:00.882

[xUnit.net 00:00:06.22]   Testcontainers: Removing container 3fa7c2b1
[xUnit.net 00:00:07.14]   Finished: ApiTests

Tests:     4 passed, 1 failed, 0 skipped
Time:      7.14 seconds
```

**How to read it:**
```
Section                      What to look for
──────────────────────────────────────────────────────────────────────
Container startup time       3.82 − 1.30 = 2.5 sec to start Postgres.
(lines 3–5)                  First run pulls image (~5–10 sec). Cached
                             on subsequent runs. Use IClassFixture to
                             start ONCE per test class, not per test.

Migration time (line 7)      0.78 sec for migrations. If slow: check
                             you're not rebuilding the DB per test.
                             Use Respawn to reset data, not the DB.

[PASS] with timing           342ms for HTTP round-trip in test.
                             If > 2s: check DB query plans, missing index,
                             or await deadlock in async test code.

[FAIL] with expected/actual  StatusCode mismatch: API returns 400 but
                             test expects 422. Options:
                             (a) Fix the API to return 422 (correct)
                             (b) Fix the assertion if 400 is correct
                             Line number tells you exactly where to look.

Container cleanup (last line) Testcontainers auto-removes on dispose.
                              If tests crash mid-run, orphaned containers
                              may remain → run: docker ps -a | grep test

Total time: 7.14 sec         Healthy for integration tests. If > 30 sec:
                             profile startup, parallelize with [assembly: CollectionBehavior(MaxParallelThreads = 4)]
```

---

### D2. Fake Event Publisher — Assertion Output on Failure
```
FluentAssertions failure:

Expected collection to contain a single item matching
  e.CustomerId == "c-test-1"
but found 0 matching items in
  [OrderCreatedEvent { OrderId=ord-abc, CustomerId="c-test-2", Total=99.99 }]
```

**How to read it:**
```
The test published an event with CustomerId = "c-test-2"
but the assertion checked for "c-test-1".

Likely bug: wrong CustomerId used in test arrange section,
OR the handler is reading from a different request field.

Check: The CreateOrderRequest in the test uses CustomerId = "c-test-1" ?
       The OrderService correctly propagates CustomerId to the event ?
       The FakeEventPublisher.Clear() was called at the start of this test ?
```

---

## E. Redis / Cache — CLI and SDK Outputs

---

### E1. Redis CLI — All Data Types
```bash
# Connect
redis-cli -h myredis.redis.cache.windows.net -p 6380 --tls -a <password>

# --- STRING ---
SET product:123 "{\"id\":123,\"name\":\"Widget\",\"price\":29.99}" EX 300
# Output:
OK

GET product:123
# Output:
"{\"id\":123,\"name\":\"Widget\",\"price\":29.99}"

TTL product:123
# Output:
298    ← seconds remaining before expiry (started at 300)
       -1 = no expiry (permanent), -2 = key doesn't exist

# --- HASH ---
HSET user:456 name "Alice" email "alice@ex.com" plan "premium"
# Output:
(integer) 3    ← number of NEW fields added (existing fields updated don't count)

HGET user:456 name
# Output:
"Alice"

HGETALL user:456
# Output:
1) "name"
2) "Alice"
3) "email"
4) "alice@ex.com"
5) "plan"
6) "premium"

# Why alternating? Redis returns flat array: [field1, value1, field2, value2, ...]

# --- LIST ---
LPUSH notifications:user:456 "{\"msg\":\"Order shipped\"}" "{\"msg\":\"Payment received\"}"
# Output:
(integer) 2    ← total items in list now

LRANGE notifications:user:456 0 -1
# Output:
1) "{\"msg\":\"Payment received\"}"    ← LPUSH = left push, so LAST pushed = index 0
2) "{\"msg\":\"Order shipped\"}"

# -1 = last element. LRANGE 0 9 = first 10 items.

# --- SET ---
SADD visitors:2026-03-05 "user-001" "user-002" "user-001"
# Output:
(integer) 2    ← only 2 added (user-001 duplicate ignored — sets are unique!)

SCARD visitors:2026-03-05
# Output:
(integer) 2    ← cardinality (count of unique members)

# --- SORTED SET (leaderboard) ---
ZADD leaderboard 1500 "player-001" 2300 "player-002" 900 "player-003"
# Output:
(integer) 3    ← members added

ZREVRANGE leaderboard 0 2 WITHSCORES
# Output:
1) "player-002"    ← rank 1 (highest score)
2) "2300"
3) "player-001"    ← rank 2
4) "1500"
5) "player-003"    ← rank 3
6) "900"
# ZREVRANGE = highest first. ZRANGE = lowest first.

ZRANK leaderboard "player-001"
# Output:
(integer) 1    ← 0-indexed rank. 0 = lowest (ZRANK), use ZREVRANK for top rank.

ZREVRANK leaderboard "player-001"
# Output:
(integer) 1    ← rank 1 from top (0 = highest scorer = player-002)
```

---

### E2. Distributed Lock — Step-by-Step Output
```bash
# Acquire lock (SET NX = only set if Not eXists)
SET lock:order:ord-123 "instance-a-guid-here" NX PX 30000
# Output when lock acquired:
OK

# Output when lock already held by another instance:
(nil)    ← null = lock not acquired, someone else holds it

# Check who holds the lock
GET lock:order:ord-123
# Output:
"instance-b-guid-here"    ← different instance holds it!

# Release (only if you own it — using Lua for atomicity)
EVAL "if redis.call('get',KEYS[1])==ARGV[1] then return redis.call('del',KEYS[1]) else return 0 end" 1 lock:order:ord-123 "instance-a-guid-here"
# Output when you own it:
(integer) 1    ← deleted successfully

# Output when you DON'T own it (race condition prevented):
(integer) 0    ← not deleted (someone else's lock, or already expired)
```

**How to read it:**
```
Value    Meaning
──────────────────────────────────────────────────────────────────────
OK       Lock acquired. Proceed with critical section.

(nil)    Lock not acquired. Options:
         (a) Retry after short sleep (polling — simple)
         (b) Fail fast and tell caller to retry
         (c) Use Lua pub/sub to wait for release (advanced)

PX 30000 Lock expires after 30,000ms = 30 seconds.
         WHY: if your process crashes, lock auto-releases.
         Set to max expected critical section duration + margin.

Lua script atomicity:
  Without Lua: GET → compare → DEL has TOCTOU race:
    1. You GET → your value matches
    2. Lock expires → other instance acquires
    3. You DEL → you delete their lock! ← BUG

  With Lua: GET + compare + DEL is ONE atomic operation.
            No other command can run between them.

(integer) 0 from Lua = you tried to release but didn't own it.
         Log this as a warning — your critical section took longer
         than the lock TTL (lock expired while you were working).
         Fix: increase PX value or use lock renewal pattern.
```

---

### E3. IMemoryCache — Eviction Callback Output
```csharp
entry.RegisterPostEvictionCallback((key, value, reason, state) =>
    _logger.LogInformation("Cache evicted: {Key}, reason: {Reason}", key, reason));
```

```
-- Log output examples:

info: ProductService[0]
      Cache evicted: products:all, reason: Expired
      // TTL hit — normal, expected. Cache will be refilled on next request.

info: ProductService[0]
      Cache evicted: products:all, reason: Capacity
      // Memory pressure evicted this. Consider:
      // 1. Increase MemoryCache size limit (SizeLimit in options)
      // 2. Set lower Priority on less important cache entries
      // 3. Reduce number of cached items

info: ProductService[0]
      Cache evicted: products:all, reason: Removed
      // Explicit _cache.Remove("products:all") was called.
      // Expected on data update — correct invalidation behavior.
```

**How to read it:**
```
Reason      What happened
────────────────────────────────────────────────────────────────────────────
Expired     AbsoluteExpiration or SlidingExpiration hit. Normal.
            If this happens too frequently on hot data → increase TTL.

Capacity    MemoryCache evicted to free memory (LRU-ish policy).
            ALERT: if you see this frequently, cached data keeps getting
            evicted before it's useful → increase cache size or reduce
            what you cache. Check: services.AddMemoryCache(o => o.SizeLimit = 500)

Removed     Manual eviction via cache.Remove(key). Expected on data writes.

Replaced    A new value was set for the same key while old was cached.
            Common in stampede recovery — second request also filled cache.

None        Entry was never evicted — still in cache (you see this when
            using GetOrCreate and the item is still warm).
```

---

## F. React — Browser DevTools & Console Outputs

---

### F1. React DevTools — Component Re-render Profiler
```
-- React Profiler output (Flamegraph view):
Render #1 (commit duration: 12ms)
  App                    2ms  ──────────────────────────────
    AuthProvider         1ms  ──────────────────────
      Sidebar            0.2ms ────
      OrderList          8ms  ──────────────────────────────────────────────────
        OrderItem(1)     0.4ms ──
        OrderItem(2)     0.4ms ──
        OrderItem(3)   ...×47 more
      CreateOrderForm    0.8ms ────────

Render #2 (after adding one order, commit duration: 1ms)
  App                    0ms  (skipped — React.memo)
    AuthProvider         0ms  (skipped)
      OrderList          0.9ms ───────
        OrderItem(NEW)   0.5ms ──
        [all others]     0ms  (skipped — React.memo stable props)
      CreateOrderForm    0.3ms ──
```

**How to read it:**
```
commit duration    Total time React spent updating the DOM for this render.
                   < 16ms = 60fps (smooth)
                   > 16ms = frame drop, user sees jank

Component colors (DevTools):
  Gray    = did not re-render (React.memo worked ✓)
  Yellow  = re-rendered but fast (<1ms) — OK
  Orange  = re-rendered, took 1–10ms — investigate
  Red     = re-rendered, took >10ms — OPTIMIZE THIS

OrderList (8ms on render #1):
  Rendering 50 OrderItems × 0.4ms = 20ms total work.
  Fix: React.memo on OrderItem ✓ (render #2 shows 0ms for existing items)
       useVirtualizer if list > 200 items

Render #2 savings:
  Only NEW item rendered (0.5ms vs 12ms total). React.memo + stable
  useCallback props prevented 49 unnecessary re-renders.
  → This is correct behavior — memoization is working.
```

---

### F2. React Query DevTools — Cache State
```
-- React Query DevTools panel (browser extension):

QueryKey                  Status    Updated          StaleTime  Data
────────────────────────  ────────  ───────────────  ─────────  ──────────────────
['orders', 'c-001']       fresh     2s ago           5m 0s      [{id:'ord-1'...}]
['orders', 'c-002']       stale     6m ago           expired    [{id:'ord-5'...}]
['products']              loading   just now         5m 0s      undefined
['users', 'u-001']        error     30s ago          5m 0s      null

Mutations:
  createOrder             idle      last: 2m ago     success    {id:'ord-new-1'}
```

**How to read it:**
```
Status   Meaning & Behavior
──────────────────────────────────────────────────────────────────────────
fresh    Data fetched recently, within staleTime (5 min).
         React Query WON'T refetch when component mounts.
         User gets cached data instantly.

stale    Data older than staleTime.
         On next component mount or window focus → React Query
         refetches in background. User sees stale data immediately,
         then fresh data updates (stale-while-revalidate pattern).

loading  Fetching right now — no cached data. Show spinner.

error    Fetch failed. React Query retried 2 times (default), gave up.
         Data = null. Component's error state shows error message.
         Will retry on next window focus.

QueryKey ['orders', 'c-001'] vs ['orders', 'c-002']:
         Different keys = different cache entries. Changing customerId
         in a component → new cache entry → possible loading state.
         WHY: this is correct — different customers = different data.

invalidateQueries(['orders']):
         Marks ALL keys starting with 'orders' as stale.
         If components are currently mounted → immediate background refetch.
         If not mounted → refetch on next mount.
```

---

### F3. useEffect — Common Console Warnings and Fixes
```javascript
// WARNING 1: Missing dependency
Warning: React Hook useEffect has a missing dependency: 'userId'.
Either include it or remove the dependency array.

// Your code:
useEffect(() => {
    fetchUser(userId);  // ← uses userId
}, []);                 // ← but not listed here!

// Fix:
useEffect(() => {
    fetchUser(userId);
}, [userId]);           // ← add it. Effect now re-runs when userId changes.

// ─────────────────────────────────────────────────────────────

// WARNING 2: setState on unmounted component (React 17 and below)
Warning: Can't perform a React state update on an unmounted component.
This is a no-op, but it indicates a memory leak.

// Your code:
useEffect(() => {
    fetch('/api/orders').then(r => r.json()).then(setOrders);  // no cleanup!
}, []);

// Fix:
useEffect(() => {
    const controller = new AbortController();
    fetch('/api/orders', { signal: controller.signal })
        .then(r => r.json())
        .then(setOrders)
        .catch(e => { if (e.name !== 'AbortError') setError(e); });
    return () => controller.abort();   // ← cleanup cancels fetch on unmount
}, []);

// ─────────────────────────────────────────────────────────────

// WARNING 3: Infinite loop
// Symptom: browser tab freezes, Network tab shows hundreds of requests/sec

// Your code (bug):
const [data, setData] = useState([]);
useEffect(() => {
    fetch('/api').then(r => r.json()).then(d => setData(d));
}, [data]);  // ← data changes → effect runs → setData → data changes → loop!

// Fix: don't put state that the effect SETS in its own dependency array
useEffect(() => {
    fetch('/api').then(r => r.json()).then(d => setData(d));
}, []);   // ← empty = run once on mount only
```

---

### F4. Zustand — DevTools State Snapshot
```javascript
// Redux DevTools (works with Zustand via middleware)

// Action logged:
{
  "type": "addItem",
  "payload": { "id": "p-123", "name": "Widget", "price": 29.99, "qty": 1 }
}

// State before:
{
  "items": [
    { "id": "p-100", "name": "Gadget", "price": 49.99, "qty": 2 }
  ]
}

// State after:
{
  "items": [
    { "id": "p-100", "name": "Gadget", "price": 49.99, "qty": 2 },
    { "id": "p-123", "name": "Widget", "price": 29.99, "qty": 1 }
  ]
}

// Time-travel: click any past action to "jump" UI to that state.
// Useful for reproducing bugs: "the cart was wrong AFTER this addItem"
```

**How to read it:**
```
State diff     Shows exactly what changed between actions.
               Green lines = added, red lines = removed.
               No change = React Query data (managed separately).

Action type    Matches the function name in your Zustand store:
               "addItem" → const addItem = (item) => set(state => ...)

DEBUGGING WORKFLOW:
  1. Reproduce the bug in the browser
  2. Open Redux DevTools → find the action where state went wrong
  3. Click "Jump to state" → UI reverts to that exact state
  4. Check if the action's payload is correct
     - Wrong payload → bug in the component calling the action
     - Correct payload, wrong state after → bug in the store reducer
```

---

*Appendix Date: 2026-03-05 | Covers: All CLI commands, SQL DMVs, Cosmos DB SDK, Integration Test output, Redis CLI, React DevTools*
