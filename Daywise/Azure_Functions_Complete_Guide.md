# Azure Functions - Complete Comprehensive Guide

## Table of Contents

1. [Introduction & Overview](#introduction--overview)
2. [Core Concepts & Fundamentals](#core-concepts--fundamentals)
3. [When to Use Azure Functions](#when-to-use-azure-functions)
4. [Hosting Plans & Pricing Models](#hosting-plans--pricing-models)
5. [Programming Models & Languages](#programming-models--languages)
6. [Triggers - Complete Reference](#triggers---complete-reference)
7. [Bindings - Input & Output](#bindings---input--output)
8. [Development Approaches](#development-approaches)
9. [Code Implementation - C# .NET](#code-implementation---c-net)
10. [Code Implementation - Python](#code-implementation---python)
11. [Code Implementation - JavaScript/TypeScript](#code-implementation---javascripttypescript)
12. [Durable Functions - Orchestration](#durable-functions---orchestration)
13. [Dependency Injection & Configuration](#dependency-injection--configuration)
14. [Testing Strategies](#testing-strategies)
15. [Deployment Methods](#deployment-methods)
16. [Monitoring & Observability](#monitoring--observability)
17. [Security & Authentication](#security--authentication)
18. [Performance Optimization](#performance-optimization)
19. [Real-World Scenarios](#real-world-scenarios)
20. [Best Practices & Patterns](#best-practices--patterns)
21. [Cost Optimization](#cost-optimization)
22. [Troubleshooting Guide](#troubleshooting-guide)

---

## Introduction & Overview

### What are Azure Functions?

**Azure Functions** is a serverless compute service that enables you to run event-driven code without having to explicitly provision or manage infrastructure. It's Microsoft's Function-as-a-Service (FaaS) offering in Azure.

### Key Characteristics

```
┌─────────────────────────────────────────────────────────────┐
│                    AZURE FUNCTIONS                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Serverless - No infrastructure management               │
│  ✅ Event-Driven - Responds to triggers automatically       │
│  ✅ Auto-Scaling - Scales based on demand                   │
│  ✅ Pay-per-execution - Only charged when code runs         │
│  ✅ Multiple Languages - C#, Python, JavaScript, Java, etc  │
│  ✅ Built-in Integrations - 50+ triggers and bindings       │
│  ✅ Stateless or Stateful - Regular or Durable Functions    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Evolution of Azure Functions

| Version | Release | Key Features | Status |
|---------|---------|--------------|--------|
| **v1** | 2016 | .NET Framework, Windows only | Legacy |
| **v2** | 2018 | .NET Core, Cross-platform | Deprecated |
| **v3** | 2019 | .NET Core 3.1, Python 3.x | End of Life |
| **v4** | 2021 | .NET 6/7/8, Performance improvements | **Current** |

---

## Core Concepts & Fundamentals

### Architecture Components

```
┌───────────────────────────────────────────────────────────────┐
│                    FUNCTION APP HIERARCHY                     │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  Azure Subscription                                           │
│    └── Resource Group                                         │
│         └── Function App (Container/Host)                     │
│              ├── host.json (Global configuration)             │
│              ├── local.settings.json (Local dev settings)     │
│              ├── Function 1                                   │
│              │    ├── __init__.py or index.js or .cs file    │
│              │    └── function.json (Bindings - v1 model)     │
│              ├── Function 2                                   │
│              └── Function N                                   │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Function Anatomy

Every Azure Function consists of:

1. **Trigger** (Required, Exactly 1): What starts the function
2. **Input Bindings** (Optional, 0 to Many): Data read into the function
3. **Function Code** (Required): Your business logic
4. **Output Bindings** (Optional, 0 to Many): Data written from the function

```
┌──────────────┐
│   TRIGGER    │  ← Event Source (HTTP, Timer, Queue, etc.)
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│        INPUT BINDINGS (Optional)         │
│  ┌────────────┐  ┌────────────┐         │
│  │   Blob     │  │  CosmosDB  │   etc.  │
│  └────────────┘  └────────────┘         │
└──────────────┬───────────────────────────┘
               │
               ▼
       ┌───────────────┐
       │  FUNCTION     │  ← Your Code
       │  LOGIC        │
       └───────┬───────┘
               │
               ▼
┌──────────────────────────────────────────┐
│       OUTPUT BINDINGS (Optional)         │
│  ┌────────────┐  ┌────────────┐         │
│  │   Queue    │  │  Storage   │   etc.  │
│  └────────────┘  └────────────┘         │
└──────────────────────────────────────────┘
```

### Key Terminology

| Term | Definition |
|------|------------|
| **Function App** | Container that hosts one or more individual functions. Shares same configuration, pricing plan, and lifecycle. |
| **Trigger** | Defines how a function is invoked. Each function must have exactly one trigger. |
| **Binding** | Declarative way to connect to data sources. Can be input (read) or output (write). |
| **Host** | Runtime environment that executes your functions. |
| **host.json** | Global configuration file affecting all functions in the app. |
| **local.settings.json** | Local development configuration (not deployed to Azure). |
| **Application Settings** | Environment variables and connection strings (Azure portal). |
| **Execution Context** | Request-scoped object containing metadata about the current execution. |

---

## When to Use Azure Functions

### ✅ Ideal Use Cases

| Scenario | Why Azure Functions? | Example |
|----------|---------------------|---------|
| **Event Processing** | Auto-scales with event volume | Process IoT telemetry, log aggregation |
| **Scheduled Tasks** | Built-in CRON scheduling | Daily reports, database cleanup |
| **Webhooks & APIs** | Instant HTTP endpoints | GitHub webhooks, payment callbacks |
| **Data Transformation** | Process data pipelines | ETL operations, file format conversion |
| **Microservices** | Lightweight, independent services | Order processing, notification service |
| **Backend Automation** | Glue services together | Sync data between SaaS applications |
| **Real-time Data Processing** | Stream processing | Social media sentiment analysis |
| **Image/Video Processing** | On-demand media processing | Thumbnail generation, transcoding |

### ❌ Not Recommended For

| Scenario | Why Not? | Better Alternative |
|----------|----------|-------------------|
| **Long-running processes** | 10-minute default timeout (230min max) | Azure Container Instances, AKS |
| **Complex orchestrations** | Hard to manage state | Use Durable Functions instead |
| **Persistent connections** | Functions are stateless | Azure App Service, SignalR Service |
| **High-frequency small tasks** | Cold start overhead | Always-on App Service |
| **Predictable steady load** | Consumption plan overhead | App Service, Azure Kubernetes Service |

### Decision Tree

```
Start: Do you need serverless compute?
│
├── Yes
│   │
│   ├── Is it event-driven? ──── Yes ──── Azure Functions ✅
│   │                       └──── No ───── Consider App Service
│   │
│   ├── Runs < 10 minutes? ──── Yes ──── Azure Functions ✅
│   │                       └──── No ───── Azure Container Instances
│   │
│   └── Needs orchestration? ─── Yes ──── Durable Functions ✅
│                             └─── No ───── Regular Functions ✅
│
└── No ──── Consider: App Service, AKS, Container Apps
```

---

## Hosting Plans & Pricing Models

### 1. **Flex Consumption Plan (FC1)** ⭐ RECOMMENDED

**Released:** 2024 | **Status:** Current Best Practice

```yaml
Plan Type: Flex Consumption (FC1)
Billing: Per-execution + instance hours
Cold Start: ~1-2 seconds
Max Timeout: 10 minutes (default)
Scale: 0 to 1000+ instances
Always On: Optional (fast startup)
Key Benefits:
  - Pay only for what you use
  - Virtual networking support
  - Better cold start performance
  - HTTP concurrency improvements
```

**Pricing Example:**
```
- Execution: $0.20 per million executions
- Execution time: $0.000016 per GB-second
- Memory allocation: Configurable (512MB - 4GB)

Example: 1 million executions, 1GB RAM, 1 second each
= $0.20 + (1,000,000 × 1GB × 1s × $0.000016)
= $0.20 + $16
= $16.20 per month
```

### 2. **Consumption Plan (Y1)** - Legacy

**Released:** 2016 | **Status:** Maintenance Mode

```yaml
Plan Type: Consumption (Y1)
Billing: Per-execution + compute time
Cold Start: ~3-5 seconds
Max Timeout: 10 minutes
Scale: 0 to 200 instances
Always On: No
Key Limitations:
  - No VNET integration
  - Slower cold starts
  - Limited concurrency
```

### 3. **Premium Plan (EP1, EP2, EP3)**

**Use When:** Need always-on, VNET integration, or longer execution times

```yaml
Plan Type: Elastic Premium
Billing: Fixed monthly cost + scaling
Cold Start: None (pre-warmed instances)
Max Timeout: 30 minutes (unlimited with Durable)
Scale: 1 to 100 instances
Always On: Yes
Key Features:
  - No cold starts
  - VNET integration
  - Larger instance sizes
  - Advanced networking
  
Pricing: ~$150-$600/month (base) + scaling costs
```

### 4. **Dedicated Plan (App Service Plan)**

**Use When:** Already have App Service infrastructure

```yaml
Plan Type: Dedicated (S1, P1V2, etc.)
Billing: Fixed monthly (same as App Services)
Cold Start: None
Max Timeout: Unlimited
Scale: Manual or autoscale
Always On: Yes
Key Use Cases:
  - Existing App Service Plan with spare capacity
  - Predictable, steady workloads
  - Need full VM control
```

### Comparison Matrix

| Feature | Flex Consumption (FC1) | Consumption (Y1) | Premium (EP) | Dedicated (App Service) |
|---------|------------------------|------------------|--------------|-------------------------|
| **Best for** | Modern serverless | Legacy serverless | Enterprise | Steady workloads |
| **Cold Start** | 1-2s | 3-5s | None | None |
| **Timeout** | 10 min | 10 min | 30 min | Unlimited |
| **Scale to 0** | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **VNET** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes |
| **Pricing** | Pay-per-use | Pay-per-use | Fixed + usage | Fixed monthly |
| **Max Instances** | 1000+ | 200 | 100 | Based on plan |
| **Min Cost/Month** | ~$0 | ~$0 | ~$150 | ~$13 |

### Recommendation Matrix

```
┌─────────────────────────────────────────────────────────────┐
│                  HOSTING PLAN DECISION                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Startup/Dev/POC         → Flex Consumption (FC1)          │
│  Production (Event-driven) → Flex Consumption (FC1)        │
│  Enterprise (No cold start) → Premium (EP)                 │
│  Predictable Load        → Dedicated (App Service)         │
│  Hybrid Networking       → Premium or Dedicated            │
│  Budget < $50/month      → Flex Consumption (FC1)          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Programming Models & Languages

### Supported Languages

| Language | Runtime Versions | Programming Model | In-Process | Isolated Process |
|----------|------------------|-------------------|------------|------------------|
| **C#** | .NET 6, 7, 8 | v4 | ❌ Deprecated | ✅ Recommended |
| **Python** | 3.8, 3.9, 3.10, 3.11 | v2 | N/A | ✅ Only option |
| **JavaScript** | Node 16, 18, 20 | v4 | N/A | ✅ Only option |
| **TypeScript** | Node 16, 18, 20 | v4 | N/A | ✅ Only option |
| **Java** | 8, 11, 17 | v4 | N/A | ✅ Only option |
| **PowerShell** | 7.2, 7.4 | v4 | ❌ Legacy | ✅ Current |

### Programming Model Evolution

#### **Legacy (v1) - Attribute-based (function.json)**

```json
// function.json (Old approach - NOT recommended for Python/Node)
{
  "bindings": [
    {
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "authLevel": "function"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    }
  ]
}
```

#### **Modern (v4) - Code-based Configuration**

```python
# Python v2 Model (Recommended)
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="HttpExample")
@app.route(route="hello", auth_level=func.AuthLevel.FUNCTION)
def main(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse("Hello!", status_code=200)
```

```javascript
// JavaScript v4 Model (Recommended)
const { app } = require('@azure/functions');

app.http('HttpExample', {
    methods: ['GET', 'POST'],
    authLevel: 'function',
    handler: async (request, context) => {
        return { status: 200, body: 'Hello!' };
    }
});
```

### .NET Isolated vs In-Process

| Feature | In-Process (Legacy) | Isolated Process (Current) |
|---------|---------------------|----------------------------|
| **Status** | Maintenance mode | ✅ Active development |
| **Runtime** | Shared with host | Separate process |
| **.NET Version** | Tied to Functions host | Any supported .NET version |
| **Performance** | Slightly faster | Minor overhead, more flexible |
| **Middleware** | Limited | Full ASP.NET Core pipeline |
| **Dependency** | Functions SDK only | Full .NET SDK |
| **Future** | No new features | All new features |

**Migration Path:**
```
In-Process (.NET Core 3.1) 
   → Isolated Process (.NET 6)
   → Isolated Process (.NET 8) ✅ Current Best Practice
```

---

## Triggers - Complete Reference

### Overview of All Triggers

| Trigger | Use Case | Direction | Max Concurrency | Polling Mechanism |
|---------|----------|-----------|-----------------|-------------------|
| **HTTP** | REST APIs, Webhooks | In | Configurable | Push (webhook) |
| **Timer** | Scheduled jobs | In | 1 (singleton) | CRON schedule |
| **Blob Storage** | File processing | In | Per blob | Event Grid (recommended) |
| **Queue Storage** | Async work items | In | 16-32 parallel | Polling (exponential backoff) |
| **Service Bus** | Enterprise messaging | In | 16-32 parallel | Session-aware polling |
| **Event Grid** | Event-driven architecture | In | High | Push (subscription) |
| **Event Hub** | Stream processing | In | Per partition | Checkpoint-based |
| **Cosmos DB** | Change feed processing | In | Per partition | Change feed iterator |
| **SignalR** | Real-time communication | In/Out | N/A | Connection-based |
| **Kafka** | Apache Kafka | In/Out | Per partition | Consumer groups |
| **RabbitMQ** | AMQP messaging | In | Configurable | Consumer groups |
| **SendGrid** | Email | Out only | N/A | N/A |
| **Twilio** | SMS | Out only | N/A | N/A |

### 1. HTTP Trigger - Detailed

**Characteristics:**
- Most common trigger for APIs and webhooks
- Synchronous request/response pattern
- Supports all HTTP methods (GET, POST, PUT, DELETE, etc.)
- Built-in routing and authorization

**Configuration Options:**

```json
{
  "authLevel": "function",  // anonymous | function | admin
  "methods": ["get", "post"],
  "route": "products/{category}/{id?}"  // Optional route template
}
```

**Auth Levels Explained:**

| Auth Level | Who Can Call? | Use Case |
|------------|---------------|----------|
| **anonymous** | Anyone (no key required) | Public APIs, webhooks from trusted sources |
| **function** | Anyone with function key | Default, secure but shareable |
| **admin** | Only with master/admin key | Internal admin operations |

**Route Templates:**

```csharp
// Simple route
[Function("GetProduct")]
[HttpTrigger(AuthorizationLevel.Function, "get", Route = "products/{id}")]

// Multiple parameters
Route = "orders/{customerId}/items/{itemId}"

// Optional parameters
Route = "search/{term?}"  // term is optional

// Constraints
Route = "products/{id:int}"  // id must be integer
Route = "users/{name:alpha}"  // name must be alphabetic
Route = "items/{id:length(5)}"  // id must be 5 characters
```

### 2. Timer Trigger - Detailed

**CRON Expression Format:**

```
{second} {minute} {hour} {day} {month} {day-of-week}
```

**Common Patterns:**

| CRON Expression | Meaning | Use Case |
|----------------|---------|----------|
| `0 */5 * * * *` | Every 5 minutes | Health checks |
| `0 0 * * * *` | Every hour | Hourly aggregation |
| `0 0 */6 * * *` | Every 6 hours | Periodic cleanup |
| `0 0 0 * * *` | Daily at midnight | Daily reports |
| `0 0 9 * * MON-FRI` | Weekdays at 9 AM | Business hours notifications |
| `0 0 0 1 * *` | First day of month | Monthly billing |

**Advanced Timer Configuration:**

```json
{
  "schedule": "0 */5 * * * *",
  "runOnStartup": false,         // Run immediately on start
  "useMonitor": true             // Store next occurrence in storage
}
```

**Multiple Time Zones:**

```python
# UTC time (default)
@app.schedule(schedule="0 0 9 * * *", arg_name="timer")

# With timezone
@app.schedule(schedule="0 0 9 * * *", 
              arg_name="timer",
              use_monitor=True)
# Then set WEBSITE_TIME_ZONE = "Eastern Standard Time" in app settings
```

### 3. Blob Storage Trigger - Detailed

**⚠️ Important:** Use Event Grid source for production

**Configuration:**

```json
{
  "type": "blobTrigger",
  "path": "samples-workitems/{name}",
  "source": "EventGrid",  // ALWAYS use this instead of "LogsAndContainerScan"
  "connection": "AzureWebJobsStorage"
}
```

**Path Patterns:**

```
// All blobs in container
"path": "container-name/{name}"

// Blobs in folder
"path": "container-name/input/{name}"

// Filter by extension
"path": "container-name/{name}.jpg"

// Capture metadata
"path": "container-name/{folder}/{subfolder}/{filename}.{extension}"
```

**Event Grid vs Polling:**

| Aspect | Event Grid (Recommended) | Polling (Legacy) |
|--------|--------------------------|------------------|
| **Latency** | Near real-time (~2-3 sec) | 10 seconds - 10 minutes |
| **Reliability** | Guaranteed delivery | Can miss blobs |
| **Cost** | $0.60 per million events | Included, but slower |
| **Setup** | Requires Event Grid subscription | Automatic |
| **Production** | ✅ Always use this | ❌ Avoid |

### 4. Queue Storage Trigger - Detailed

**Best for:** Asynchronous work items, task queues

**Configuration:**

```json
{
  "type": "queueTrigger",
  "queueName": "orders-to-process",
  "connection": "AzureWebJobsStorage"
}
```

**Scaling Behavior:**

```
Queue Length: 16+ messages
├── Batch Size: 16 messages fetched per polling cycle
├── Parallel Execution: Up to 32 concurrent function instances
├── Polling Frequency: 
│   ├── Queue has messages: Every 100ms - 1 second
│   └── Queue is empty: Exponential backoff (up to 1 minute)
└── Scale Decision: Made every 10 seconds based on queue depth
```

**Poison Queue Handling:**

```yaml
Max Dequeue Count: 5 (default)
Behavior:
  - Message fails 5 times → Moved to {queuename}-poison queue
  - Automatic dead-letter handling
  - Manual intervention required for poison messages
```

### 5. Service Bus Trigger - Detailed

**Best for:** Enterprise messaging, guaranteed delivery, sessions

**Configuration:**

```json
{
  "type": "serviceBusTrigger",
  "queueName": "orders",
  "connection": "ServiceBusConnection",
  "isSessionsEnabled": false
}
```

**Queue vs Topic:**

| Feature | Queue | Topic |
|---------|-------|-------|
| **Consumers** | Single (competing consumers) | Multiple (pub/sub) |
| **Use Case** | Point-to-point messaging | Broadcast to subscribers |
| **Routing** | None | Filter rules per subscription |
| **Sessions** | Supported | Supported |

**Session-enabled Processing:**

```python
# Session support for ordered processing
@app.service_bus_queue_trigger(
    arg_name="msg",
    queue_name="orders",
    connection="ServiceBusConnection",
    is_sessions_enabled=True  # Ensures FIFO processing per session
)
def process_order(msg: func.ServiceBusMessage):
    session_id = msg.session_id
    # All messages with same session_id processed in order
```

### 6. Event Grid Trigger - Detailed

**Best for:** Event-driven architectures, reactive programming

**Event Grid Concepts:**

```
┌────────────┐       ┌────────────┐       ┌────────────┐
│   Event    │──────▶│ Event Grid │──────▶│ Azure      │
│   Source   │       │   Topic    │       │ Function   │
└────────────┘       └────────────┘       └────────────┘
     │                     │                     │
     │                     │                     │
  Publishes            Routes to            Subscriber
  Events           Subscriptions          (Your Code)
```

**Common Event Sources:**

| Source | Event Types |
|--------|-------------|
| **Storage Blob** | BlobCreated, BlobDeleted |
| **Container Registry** | ImagePushed, ImageDeleted |
| **IoT Hub** | DeviceTelemetry, DeviceConnected |
| **Resource Group** | ResourceWriteSuccess, ResourceDeleteSuccess |
| **Custom Topics** | Your custom events |

**Event Schema:**

```json
{
  "topic": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{account}",
  "subject": "/blobServices/default/containers/testcontainer/blobs/testfile.txt",
  "eventType": "Microsoft.Storage.BlobCreated",
  "eventTime": "2024-01-15T10:30:00.1234567Z",
  "id": "unique-event-id",
  "data": {
    "api": "PutBlob",
    "contentType": "text/plain",
    "contentLength": 1024,
    "blobType": "BlockBlob",
    "url": "https://myaccount.blob.core.windows.net/container/file.txt"
  },
  "dataVersion": "1.0",
  "metadataVersion": "1"
}
```

### 7. Event Hub Trigger - Detailed

**Best for:** Stream processing, IoT telemetry, high-throughput scenarios

**Characteristics:**

```yaml
Throughput: Millions of events per second
Retention: 1-7 days (default 1 day)
Partitions: 2-32 (Kafka-compatible)
Consumer Groups: Multiple independent consumers
Checkpointing: Automatic progress tracking
```

**Partition Strategy:**

```
Event Hub: 4 Partitions
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Part 0   │ │ Part 1   │ │ Part 2   │ │ Part 3   │
└────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
     │            │            │            │
     │            │            │            │
     ▼            ▼            ▼            ▼
┌─────────────────────────────────────────────────┐
│         Azure Function (Auto-scaled)            │
│  Instance 1  Instance 2  Instance 3  Instance 4 │
└─────────────────────────────────────────────────┘

Scaling: 1 instance per partition (max)
```

**Configuration:**

```json
{
  "type": "eventHubTrigger",
  "eventHubName": "telemetry-hub",
  "connection": "EventHubConnection",
  "consumerGroup": "$Default",
  "cardinality": "many",  // "one" for single event, "many" for batch
  "dataType": "binary"
}
```

### 8. Cosmos DB Trigger - Detailed

**Best for:** React to database changes, materialized views, CDC

**Change Feed Mechanism:**

```
Cosmos DB Container
├── Change Feed (append-only log of all changes)
│   ├── Insert operations
│   ├── Update operations
│   └── Replace operations (Delete NOT included)
│
└── Lease Container (tracks processing progress)
    ├── Partition 1 processed up to X
    ├── Partition 2 processed up to Y
    └── Partition 3 processed up to Z
```

**Configuration:**

```json
{
  "type": "cosmosDBTrigger",
  "databaseName": "myDatabase",
  "collectionName": "orders",
  "leaseCollectionName": "leases",
  "createLeaseCollectionIfNotExists": true,
  "connection": "CosmosDBConnection",
  "startFromBeginning": false,  // Process only new changes
  "maxItemsPerInvocation": 100
}
```

**Important Notes:**

- Only INSERT and UPDATE are captured (deletes are NOT in change feed)
- Use soft deletes (mark as deleted) to capture delete events
- Lease collection required for checkpointing
- At-least-once delivery (handle idempotency)

---

## Bindings - Input & Output

### Input Bindings

**Purpose:** Declaratively read data from external sources without manual SDK calls

**Supported Input Bindings:**

| Binding | Use Case | Example |
|---------|----------|---------|
| **Blob Storage** | Read files | Read uploaded CSV for processing |
| **Queue Storage** | Read queue messages | Get metadata from specific queue message |
| **Table Storage** | Read table entities | Lookup user profile |
| **Cosmos DB** | Read documents | Get order details by ID |
| **SignalR** | Connection info | Get SignalR connection details |
| **SQL** | Query database | Execute parameterized query |

**Example: Multiple Input Bindings**

```csharp
// C# with multiple input bindings
[Function("ProcessOrder")]
public static void Run(
    [QueueTrigger("orders")] string orderId,
    
    [CosmosDBInput(
        databaseName: "OrdersDB",
        collectionName: "Orders",
        Id = "{queueTriggerMessage}",
        PartitionKey = "{queueTriggerMessage}")] OrderDocument order,
    
    [BlobInput("invoices/{queueTriggerMessage}.pdf")] Stream invoicePdf,
    
    ILogger log)
{
    log.LogInformation($"Processing order {order.Id}");
    // order object is automatically populated
    // invoicePdf stream is automatically opened
}
```

### Output Bindings

**Purpose:** Declaratively write data to external sources without manual SDK calls

**Supported Output Bindings:**

| Binding | Use Case | Example |
|---------|----------|---------|
| **Blob Storage** | Write files | Save processed report |
| **Queue Storage** | Send messages | Enqueue next task |
| **Table Storage** | Write entities | Store processing logs |
| **Cosmos DB** | Write documents | Save aggregated data |
| **SignalR** | Send real-time messages | Push notifications to clients |
| **Event Grid** | Publish events | Notify other systems |
| **Service Bus** | Send messages | Send order confirmation |
| **SQL** | Insert/Update records | Update database |
| **SendGrid** | Send emails | Email customer receipts |
| **Twilio** | Send SMS | Send verification codes |

**Example: Multiple Output Bindings**

```csharp
// Multiple outputs in C#
[Function("ProcessPayment")]
[QueueOutput("payment-processed")]
[CosmosDBOutput(databaseName: "PaymentsDB", collectionName: "Payments")]
[SendGridOutput(ApiKey = "SendGridApiKey")]
public static MultiOutput Run(
    [HttpTrigger(AuthorizationLevel.Function, "post")] PaymentRequest payment)
{
    return new MultiOutput
    {
        QueueMessage = $"Payment processed: {payment.Id}",
        CosmosDocument = new { id = payment.Id, amount = payment.Amount },
        Email = new SendGridMessage { 
            To = payment.Email,
            Subject = "Payment Confirmation",
            Body = $"Your payment of ${payment.Amount} was processed."
        }
    };
}

public class MultiOutput
{
    public string QueueMessage { get; set; }
    public object CosmosDocument { get; set; }
    public SendGridMessage Email { get; set; }
}
```

### Binding Expressions

**Binding expressions** allow dynamic binding based on trigger data.

**Syntax:** `{propertyName}` or `{triggerName.propertyName}`

**Examples:**

```json
{
  "type": "blob",
  "path": "output/{sys.utcNow:yyyy-MM-dd}/{id}.json",
  "connection": "AzureWebJobsStorage"
}

// Binding expression breakdown:
// {sys.utcNow:yyyy-MM-dd} → 2024-01-15
// {id} → Value from trigger (e.g., queue message property)
// Result: output/2024-01-15/order123.json
```

**Available System Binding Expressions:**

| Expression | Description | Example Output |
|------------|-------------|----------------|
| `{sys.utcNow}` | Current UTC time | `2024-01-15T10:30:00Z` |
| `{sys.utcNow:yyyy}` | Year | `2024` |
| `{sys.utcNow:MM}` | Month | `01` |
| `{sys.utcNow:dd}` | Day | `15` |
| `{sys.randGuid}` | Random GUID | `3e3f9b8a-...` |

---

## Development Approaches

### 1. Azure Portal (Quick Start)

**Pros:**
- No local tooling required
- Instant feedback
- Good for learning/testing

**Cons:**
- Limited source control
- No local debugging
- Not suitable for production

**Steps:**

1. Navigate to Azure Portal → Create Function App
2. Select "Functions" → "+ Create"
3. Choose template (HTTP trigger, Timer, etc.)
4. Write code inline
5. Test in portal

### 2. Visual Studio Code (Recommended)

**Pros:**
- Full IDE experience
- Integrated debugging
- Source control integration
- Template support

**Installation:**

```bash
# Install Azure Functions Core Tools
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Install VS Code extension: Azure Functions

# Verify installation
func --version  # Should show 4.x.x
```

**Create New Project:**

```bash
# Interactive creation
func init MyFunctionApp --worker-runtime dotnet-isolated

# Or specify language
func init MyFunctionApp --worker-runtime python --model V2

# Navigate to project
cd MyFunctionApp

# Create a new function
func new --template "HTTP trigger" --name MyHttpFunction

# Run locally
func start
```

### 3. Visual Studio 2022

**Pros:**
- Best C# experience
- Advanced debugging
- Profiling tools
- Enterprise features

**Steps:**

1. File → New → Project
2. Search "Azure Functions"
3. Select Azure Functions template (.NET 8 Isolated)
4. Choose trigger type
5. F5 to run locally

### 4. Command Line (CI/CD)

**Azure Functions Core Tools CLI:**

```bash
# Create function app
func init MyFunctionApp --worker-runtime node --language typescript

# Add functions
func new --template "HTTP trigger" --name api
func new --template "Timer trigger" --name scheduler

# Local development
func start --port 7071

# Publish to Azure
func azure functionapp publish my-function-app-name

# Fetch remote settings
func azure functionapp fetch-app-settings my-function-app-name

# View logs
func azure functionapp logstream my-function-app-name
```

### 5. Infrastructure as Code

**Bicep Example:**

```bicep
// main.bicep - Azure Functions with Flex Consumption Plan
param location string = resourceGroup().location
param appName string = 'myapp'

// Storage account (required for Functions)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${appName}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Function App - Flex Consumption Plan (FC1)
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appName}-func'
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: functionPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
      ]
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
    }
  }
}

// Flex Consumption Plan
resource functionPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}
```

**Deploy:**

```bash
az deployment group create \
  --resource-group rg-myapp \
  --template-file main.bicep \
  --parameters appName=myapp
```

---

## Code Implementation - C# .NET

### Project Structure (.NET 8 Isolated)

```
MyFunctionApp/
├── Program.cs                 # Entry point
├── Functions/
│   ├── HttpTriggerFunction.cs
│   ├── TimerFunction.cs
│   └── BlobProcessorFunction.cs
├── Models/
│   ├── Order.cs
│   └── Customer.cs
├── Services/
│   ├── IOrderService.cs
│   └── OrderService.cs
├── host.json                  # Global configuration
├── local.settings.json        # Local development settings
└── MyFunctionApp.csproj       # Project file
```

### Basic HTTP Trigger

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;

namespace MyFunctionApp.Functions
{
    public class HttpTriggerFunction
    {
        private readonly ILogger<HttpTriggerFunction> _logger;

        public HttpTriggerFunction(ILogger<HttpTriggerFunction> logger)
        {
            _logger = logger;
        }

        [Function("HttpExample")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post")] 
            HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            // Parse query parameters
            var query = System.Web.HttpUtility.ParseQueryString(req.Url.Query);
            string? name = query["name"];

            // Read request body
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic? data = JsonSerializer.Deserialize<dynamic>(requestBody);
            name ??= data?.name;

            // Create response
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");

            var result = new
            {
                Message = $"Hello, {name ?? "World"}!",
                Timestamp = DateTime.UtcNow
            };

            await response.WriteAsJsonAsync(result);
            return response;
        }
    }
}
```

### Timer Trigger with Dependency Injection

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.Functions
{
    public class DailyReportFunction
    {
        private readonly ILogger<DailyReportFunction> _logger;
        private readonly IReportService _reportService;

        public DailyReportFunction(
            ILogger<DailyReportFunction> logger,
            IReportService reportService)
        {
            _logger = logger;
            _reportService = reportService;
        }

        // Runs daily at 2 AM UTC
        [Function("DailyReport")]
        public async Task Run(
            [TimerTrigger("0 0 2 * * *")] TimerInfo timerInfo)
        {
            _logger.LogInformation($"Daily report triggered at: {DateTime.UtcNow}");

            try
            {
                var report = await _reportService.GenerateDailyReportAsync();
                
                _logger.LogInformation($"Report generated successfully. Records: {report.RecordCount}");

                // Optionally save to blob storage
                await _reportService.SaveReportAsync(report);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating daily report");
                throw; // Re-throw to mark function execution as failed
            }

            _logger.LogInformation($"Next timer schedule at: {timerInfo.ScheduleStatus?.Next}");
        }
    }
}
```

### Queue Trigger with Output Bindings

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace MyFunctionApp.Functions
{
    public class OrderProcessorFunction
    {
        private readonly ILogger<OrderProcessorFunction> _logger;
        private readonly IOrderService _orderService;

        public OrderProcessorFunction(
            ILogger<OrderProcessorFunction> logger,
            IOrderService orderService)
        {
            _logger = logger;
            _orderService = orderService;
        }

        [Function("ProcessOrder")]
        [QueueOutput("processed-orders", Connection = "AzureWebJobsStorage")]
        [BlobOutput("receipts/{queueTrigger}.pdf", Connection = "AzureWebJobsStorage")]
        public async Task<MultipleOutputs> Run(
            [QueueTrigger("incoming-orders", Connection = "AzureWebJobsStorage")] 
            string orderMessage)
        {
            _logger.LogInformation($"Processing order: {orderMessage}");

            var order = JsonSerializer.Deserialize<Order>(orderMessage);

            // Process the order
            var result = await _orderService.ProcessOrderAsync(order);

            // Generate receipt PDF
            byte[] receiptPdf = await _orderService.GenerateReceiptAsync(result);

            return new MultipleOutputs
            {
                QueueMessage = JsonSerializer.Serialize(new
                {
                    OrderId = order.Id,
                    Status = "Processed",
                    ProcessedAt = DateTime.UtcNow
                }),
                BlobData = receiptPdf
            };
        }

        public class MultipleOutputs
        {
            [QueueOutput("processed-orders", Connection = "AzureWebJobsStorage")]
            public string QueueMessage { get; set; }

            [BlobOutput("receipts/{queueTrigger}.pdf", Connection = "AzureWebJobsStorage")]
            public byte[] BlobData { get; set; }
        }
    }
}
```

### Blob Trigger with Event Grid

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;

namespace MyFunctionApp.Functions
{
    public class ImageProcessorFunction
    {
        private readonly ILogger<ImageProcessorFunction> _logger;
        private readonly BlobServiceClient _blobServiceClient;

        public ImageProcessorFunction(
            ILogger<ImageProcessorFunction> logger,
            BlobServiceClient blobServiceClient)
        {
            _logger = logger;
            _blobServiceClient = blobServiceClient;
        }

        [Function("ProcessImage")]
        public async Task Run(
            [BlobTrigger("uploads/{name}", 
                Source = BlobTriggerSource.EventGrid,
                Connection = "AzureWebJobsStorage")] 
            Stream imageStream,
            string name,
            FunctionContext context)
        {
            _logger.LogInformation($"Processing blob: {name}, Size: {imageStream.Length} bytes");

            try
            {
                // Create thumbnail
                using var thumbnail = await CreateThumbnailAsync(imageStream, 150, 150);

                // Upload thumbnail
                var containerClient = _blobServiceClient.GetBlobContainerClient("thumbnails");
                await containerClient.CreateIfNotExistsAsync();

                var thumbnailName = $"thumb_{name}";
                var blobClient = containerClient.GetBlobClient(thumbnailName);

                await blobClient.UploadAsync(thumbnail, overwrite: true);

                _logger.LogInformation($"Thumbnail created: {thumbnailName}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error processing image: {name}");
                throw;
            }
        }

        private async Task<Stream> CreateThumbnailAsync(Stream input, int width, int height)
        {
            // Image processing logic (using ImageSharp, System.Drawing, etc.)
            // Simplified example
            var output = new MemoryStream();
            await input.CopyToAsync(output);
            output.Position = 0;
            return output;
        }
    }
}
```

### Service Bus Triggered Function

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Messaging.ServiceBus;
using System.Text.Json;

namespace MyFunctionApp.Functions
{
    public class ServiceBusFunction
    {
        private readonly ILogger<ServiceBusFunction> _logger;
        private readonly INotificationService _notificationService;

        public ServiceBusFunction(
            ILogger<ServiceBusFunction> logger,
            INotificationService notificationService)
        {
            _logger = logger;
            _notificationService = notificationService;
        }

        [Function("ProcessNotification")]
        [ServiceBusOutput("notifications-processed", Connection = "ServiceBusConnection")]
        public async Task<string> Run(
            [ServiceBusTrigger("notifications", Connection = "ServiceBusConnection")] 
            ServiceBusReceivedMessage message,
            ServiceBusMessageActions messageActions)
        {
            _logger.LogInformation($"Message ID: {message.MessageId}");
            _logger.LogInformation($"Message Body: {message.Body}");
            _logger.LogInformation($"Message Content-Type: {message.ContentType}");

            try
            {
                var notification = JsonSerializer.Deserialize<Notification>(message.Body);

                // Process notification
                await _notificationService.SendAsync(notification);

                // Complete the message (remove from queue)
                await messageActions.CompleteMessageAsync(message);

                _logger.LogInformation($"Notification sent successfully to {notification.Recipient}");

                return JsonSerializer.Serialize(new
                {
                    Status = "Sent",
                    MessageId = message.MessageId,
                    ProcessedAt = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing notification");

                // Dead-letter the message if it can't be processed
                await messageActions.DeadLetterMessageAsync(
                    message, 
                    "ProcessingError", 
                    ex.Message);

                throw;
            }
        }
    }

    public class Notification
    {
        public string Recipient { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
        public string Type { get; set; } // Email, SMS, Push
    }
}
```

### Program.cs Configuration

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Azure.Storage.Blobs;
using Azure.Identity;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults(builder =>
    {
        // Add middleware
        builder.UseMiddleware<ErrorHandlingMiddleware>();
    })
    .ConfigureServices((context, services) =>
    {
        // Application Insights
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();

        // Register services
        services.AddScoped<IOrderService, OrderService>();
        services.AddScoped<IReportService, ReportService>();
        services.AddScoped<INotificationService, NotificationService>();

        // Azure SDK clients
        services.AddSingleton(sp =>
        {
            var storageConnectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
            return new BlobServiceClient(storageConnectionString);
        });

        // HTTP Client
        services.AddHttpClient();

        // Options pattern
        services.Configure<AppSettings>(context.Configuration.GetSection("AppSettings"));
    })
    .Build();

await host.RunAsync();
```

### host.json Configuration

```json
{
  "version": "2.0",
  "logging": {
    "logLevel": {
      "default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    },
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true,
        "maxTelemetryItemsPerSecond": 20,
        "excludedTypes": "Request"
      }
    }
  },
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[4.*, 5.0.0)"
  },
  "concurrency": {
    "dynamicConcurrencyEnabled": true,
    "maximumFunctionConcurrency": 100
  },
  "functionTimeout": "00:05:00",
  "healthMonitor": {
    "enabled": true,
    "healthCheckInterval": "00:00:10",
    "healthCheckWindow": "00:02:00",
    "healthCheckThreshold": 6,
    "counterThreshold": 0.80
  },
  "retry": {
    "strategy": "exponentialBackoff",
    "maxRetryCount": 3,
    "minimumInterval": "00:00:05",
    "maximumInterval": "00:00:30"
  }
}
```

---

## Code Implementation - Python

### Project Structure (Python v2 Model)

```
function_app/
├── function_app.py            # Main entry point (all functions)
├── services/
│   ├── __init__.py
│   ├── order_service.py
│   └── notification_service.py
├── models/
│   ├── __init__.py
│   └── order.py
├── requirements.txt           # Python dependencies
├── host.json                  # Global configuration
└── local.settings.json        # Local development settings
```

### Main Function App (function_app.py)

```python
"""
Azure Functions App - Python v2 Programming Model
All functions are defined in this single file using decorators
"""

import azure.functions as func
import logging
import json
from datetime import datetime
from services.order_service import OrderService
from services.notification_service import NotificationService

# Create function app instance
app = func.FunctionApp()

# ============================================================================
# HTTP TRIGGER - REST API Endpoint
# ============================================================================

@app.function_name(name="http_trigger_example")
@app.route(route="orders/{id?}", 
           methods=["GET", "POST"], 
           auth_level=func.AuthLevel.FUNCTION)
def http_example(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP trigger function with routing
    
    GET  /api/orders        - List all orders
    GET  /api/orders/123    - Get specific order
    POST /api/orders        - Create new order
    """
    logging.info('Python HTTP trigger function processed a request.')

    # Get route parameter
    order_id = req.route_params.get('id')
    
    if req.method == 'GET':
        if order_id:
            # Get specific order
            return func.HttpResponse(
                json.dumps({
                    "orderId": order_id,
                    "status": "completed",
                    "timestamp": datetime.utcnow().isoformat()
                }),
                mimetype="application/json",
                status_code=200
            )
        else:
            # List all orders
            return func.HttpResponse(
                json.dumps({"orders": [], "count": 0}),
                mimetype="application/json"
            )
    
    elif req.method == 'POST':
        try:
            # Parse request body
            req_body = req.get_json()
            
            # Create order
            order = {
                "id": req_body.get('id'),
                "customerId": req_body.get('customerId'),
                "amount": req_body.get('amount'),
                "createdAt": datetime.utcnow().isoformat()
            }
            
            return func.HttpResponse(
                json.dumps(order),
                mimetype="application/json",
                status_code=201
            )
        except ValueError:
            return func.HttpResponse(
                "Invalid JSON in request body",
                status_code=400
            )

# ============================================================================
# TIMER TRIGGER - Scheduled Job
# ============================================================================

@app.function_name(name="timer_trigger_example")
@app.schedule(schedule="0 */5 * * * *",  # Every 5 minutes
              arg_name="timer",
              run_on_startup=False,
              use_monitor=True)
def timer_example(timer: func.TimerRequest) -> None:
    """
    Timer trigger that runs every 5 minutes
    
    CRON format: {second} {minute} {hour} {day} {month} {day of week}
    Examples:
        "0 */5 * * * *"    - Every 5 minutes
        "0 0 * * * *"      - Every hour
        "0 0 0 * * *"      - Daily at midnight
        "0 0 9 * * MON-FRI" - Weekdays at 9 AM
    """
    utc_timestamp = datetime.utcnow().isoformat()
    
    if timer.past_due:
        logging.info('The timer is past due!')
    
    logging.info(f'Python timer trigger function executed at {utc_timestamp}')
    
    # Perform scheduled task
    try:
        # Example: Cleanup old records
        logging.info("Performing scheduled cleanup task...")
        # Your cleanup logic here
        
    except Exception as e:
        logging.error(f"Error in scheduled task: {str(e)}")
        raise

# ============================================================================
# QUEUE TRIGGER - Message Processing
# ============================================================================

@app.function_name(name="queue_trigger_example")
@app.queue_trigger(arg_name="msg", 
                   queue_name="orders-to-process",
                   connection="AzureWebJobsStorage")
@app.queue_output(arg_name="outputMsg",
                  queue_name="processed-orders",
                  connection="AzureWebJobsStorage")
def queue_example(msg: func.QueueMessage, outputMsg: func.Out[str]) -> None:
    """
    Queue trigger with output binding
    Processes messages from 'orders-to-process' queue
    Sends result to 'processed-orders' queue
    """
    logging.info(f'Python queue trigger function processed a queue item: {msg.get_body().decode("utf-8")}')
    
    try:
        # Parse message
        order_data = json.loads(msg.get_body().decode('utf-8'))
        order_id = order_data.get('orderId')
        
        # Process order
        logging.info(f"Processing order {order_id}")
        
        # Simulate processing
        result = {
            "orderId": order_id,
            "status": "processed",
            "processedAt": datetime.utcnow().isoformat(),
            "dequeueCount": msg.dequeue_count
        }
        
        # Send to output queue
        outputMsg.set(json.dumps(result))
        
        logging.info(f"Order {order_id} processed successfully")
        
    except Exception as e:
        logging.error(f"Error processing queue message: {str(e)}")
        # Message will be retried automatically (up to 5 times)
        # After 5 failures, moved to poison queue
        raise

# ============================================================================
# BLOB TRIGGER - File Processing
# ============================================================================

@app.function_name(name="blob_trigger_example")
@app.blob_trigger(arg_name="blob",
                  path="uploads/{name}",
                  connection="AzureWebJobsStorage",
                  source="EventGrid")  # ALWAYS use EventGrid for production
@app.blob_output(arg_name="outputBlob",
                 path="processed/{name}.json",
                 connection="AzureWebJobsStorage")
def blob_example(blob: func.InputStream, outputBlob: func.Out[str]) -> None:
    """
    Blob trigger with Event Grid source
    Processes files uploaded to 'uploads' container
    Saves results to 'processed' container
    
    Important: Configure Event Grid subscription for near real-time processing
    """
    logging.info(f"Python blob trigger function processed blob \n"
                 f"Name: {blob.name}\n"
                 f"Blob Size: {blob.length} bytes")
    
    try:
        # Read blob content
        content = blob.read()
        
        # Process the file
        # Example: Parse CSV, process image, etc.
        result = {
            "originalFile": blob.name,
            "size": blob.length,
            "processedAt": datetime.utcnow().isoformat(),
            "status": "success"
        }
        
        # Write output
        outputBlob.set(json.dumps(result))
        
        logging.info(f"Successfully processed {blob.name}")
        
    except Exception as e:
        logging.error(f"Error processing blob {blob.name}: {str(e)}")
        raise

# ============================================================================
# SERVICE BUS TRIGGER - Enterprise Messaging
# ============================================================================

@app.function_name(name="servicebus_trigger_example")
@app.service_bus_queue_trigger(arg_name="msg",
                                queue_name="notifications",
                                connection="ServiceBusConnection")
@app.service_bus_queue_output(arg_name="outputMsg",
                               queue_name="notifications-processed",
                               connection="ServiceBusConnection")
def servicebus_example(msg: func.ServiceBusMessage, outputMsg: func.Out[str]) -> None:
    """
    Service Bus Queue trigger
    Processes messages from 'notifications' queue
    Sends confirmation to 'notifications-processed' queue
    """
    message_id = msg.message_id
    message_body = msg.get_body().decode('utf-8')
    
    logging.info(f'Python ServiceBus queue trigger processed message: {message_id}')
    logging.info(f'Message Body: {message_body}')
    logging.info(f'Content Type: {msg.content_type}')
    logging.info(f'Delivery Count: {msg.delivery_count}')
    
    try:
        # Parse message
        notification = json.loads(message_body)
        
        # Process notification
        notification_service = NotificationService()
        result = notification_service.send(notification)
        
        # Send confirmation
        confirmation = {
            "messageId": message_id,
            "status": "sent",
            "recipient": notification.get('recipient'),
            "processedAt": datetime.utcnow().isoformat()
        }
        
        outputMsg.set(json.dumps(confirmation))
        
        logging.info(f"Notification {message_id} processed successfully")
        
    except Exception as e:
        logging.error(f"Error processing Service Bus message: {str(e)}")
        # Message will be retried based on Service Bus retry policy
        raise

# ============================================================================
# SERVICE BUS TOPIC TRIGGER - Pub/Sub Pattern
# ============================================================================

@app.function_name(name="servicebus_topic_example")
@app.service_bus_topic_trigger(arg_name="msg",
                                topic_name="orders",
                                subscription_name="order-processor",
                                connection="ServiceBusConnection")
def servicebus_topic_example(msg: func.ServiceBusMessage) -> None:
    """
    Service Bus Topic trigger (Pub/Sub)
    Processes messages from 'orders' topic, 'order-processor' subscription
    """
    logging.info(f'Python ServiceBus topic trigger processed message: {msg.message_id}')
    
    try:
        message_body = msg.get_body().decode('utf-8')
        order = json.loads(message_body)
        
        # Process based on message properties
        order_type = msg.user_properties.get('OrderType')
        
        if order_type == 'Express':
            logging.info("Processing express order with priority")
        else:
            logging.info("Processing standard order")
        
        # Your processing logic here
        
    except Exception as e:
        logging.error(f"Error processing topic message: {str(e)}")
        raise

# ============================================================================
# EVENT GRID TRIGGER - Event-Driven Architecture
# ============================================================================

@app.function_name(name="eventgrid_trigger_example")
@app.event_grid_trigger(arg_name="event")
def eventgrid_example(event: func.EventGridEvent) -> None:
    """
    Event Grid trigger
    Processes events from Event Grid topics
    """
    logging.info(f"Python EventGrid trigger processed an event: {event.get_json()}")
    
    event_type = event.event_type
    subject = event.subject
    data = event.get_json()
    
    logging.info(f"Event Type: {event_type}")
    logging.info(f"Subject: {subject}")
    logging.info(f"Data: {data}")
    
    try:
        # Handle different event types
        if event_type == "Microsoft.Storage.BlobCreated":
            # Handle blob created event
            blob_url = data.get('url')
            logging.info(f"New blob created: {blob_url}")
            
        elif event_type == "Microsoft.ContainerRegistry.ImagePushed":
            # Handle container registry event
            image_name = data.get('target', {}).get('repository')
            logging.info(f"New image pushed: {image_name}")
            
        else:
            logging.info(f"Unhandled event type: {event_type}")
    
    except Exception as e:
        logging.error(f"Error processing Event Grid event: {str(e)}")
        raise

# ============================================================================
# EVENT HUB TRIGGER - Stream Processing
# ============================================================================

@app.function_name(name="eventhub_trigger_example")
@app.event_hub_message_trigger(arg_name="events",
                                event_hub_name="telemetry-hub",
                                connection="EventHubConnection")
def eventhub_example(events: List[func.EventHubEvent]) -> None:
    """
    Event Hub trigger - Batch processing
    Processes multiple events from 'telemetry-hub'
    """
    logging.info(f"Python EventHub trigger processed {len(events)} events")
    
    for event in events:
        try:
            # Parse event body
            event_body = event.get_body().decode('utf-8')
            telemetry_data = json.loads(event_body)
            
            # Event metadata
            partition_key = event.partition_key
            sequence_number = event.sequence_number
            enqueued_time = event.enqueued_time
            
            logging.info(f"Processing event from partition {partition_key}, "
                        f"sequence {sequence_number}")
            
            # Process telemetry data
            # Example: Store in database, trigger alerts, etc.
            device_id = telemetry_data.get('deviceId')
            temperature = telemetry_data.get('temperature')
            
            if temperature > 80:
                logging.warning(f"High temperature alert for device {device_id}: {temperature}°C")
            
        except Exception as e:
            logging.error(f"Error processing event: {str(e)}")
            # Continue processing other events in the batch

# ============================================================================
# COSMOS DB TRIGGER - Change Feed
# ============================================================================

@app.function_name(name="cosmosdb_trigger_example")
@app.cosmos_db_trigger(arg_name="documents",
                       database_name="OrdersDB",
                       collection_name="Orders",
                       connection_string_setting="CosmosDBConnection",
                       lease_collection_name="leases",
                       create_lease_collection_if_not_exists=True)
def cosmosdb_example(documents: func.DocumentList) -> None:
    """
    Cosmos DB trigger - Change Feed
    Processes changes (inserts/updates) in Cosmos DB
    
    Note: Deletes are NOT captured in change feed
    Use soft deletes (mark as deleted) to capture delete events
    """
    logging.info(f"Python CosmosDB trigger processed {len(documents)} documents")
    
    for doc in documents:
        try:
            # Document is a dictionary
            doc_id = doc.get('id')
            timestamp = doc.get('_ts')  # Unix timestamp of last modification
            
            logging.info(f"Processing document {doc_id}")
            
            # Example: Update materialized view, trigger notifications, etc.
            order_status = doc.get('status')
            
            if order_status == 'completed':
                # Send completion notification
                logging.info(f"Order {doc_id} completed, sending notification")
            
        except Exception as e:
            logging.error(f"Error processing Cosmos DB document: {str(e)}")
            # Continue processing other documents

# ============================================================================
# HTTP + COSMOS DB INPUT BINDING
# ============================================================================

@app.function_name(name="http_cosmos_input_example")
@app.route(route="orders/{id}", 
           methods=["GET"], 
           auth_level=func.AuthLevel.FUNCTION)
@app.cosmos_db_input(arg_name="order",
                     database_name="OrdersDB",
                     collection_name="Orders",
                     id="{id}",
                     partition_key="{id}",
                     connection_string_setting="CosmosDBConnection")
def http_cosmos_input(req: func.HttpRequest, order: func.DocumentList) -> func.HttpResponse:
    """
    HTTP trigger with Cosmos DB input binding
    Automatically reads document from Cosmos DB
    """
    if not order:
        return func.HttpResponse(
            json.dumps({"error": "Order not found"}),
            mimetype="application/json",
            status_code=404
        )
    
    # order is automatically populated from Cosmos DB
    order_doc = order[0]
    
    return func.HttpResponse(
        json.dumps(dict(order_doc)),
        mimetype="application/json"
    )

# ============================================================================
# MULTIPLE OUTPUT BINDINGS
# ============================================================================

@app.function_name(name="multiple_outputs_example")
@app.route(route="process-payment", 
           methods=["POST"], 
           auth_level=func.AuthLevel.FUNCTION)
@app.queue_output(arg_name="queueMsg",
                  queue_name="payment-processed",
                  connection="AzureWebJobsStorage")
@app.cosmos_db_output(arg_name="cosmosDoc",
                      database_name="PaymentsDB",
                      collection_name="Payments",
                      connection_string_setting="CosmosDBConnection")
def multiple_outputs(req: func.HttpRequest,
                     queueMsg: func.Out[str],
                     cosmosDoc: func.Out[func.Document]) -> func.HttpResponse:
    """
    HTTP trigger with multiple output bindings
    - Sends message to Queue
    - Saves document to Cosmos DB
    - Returns HTTP response
    """
    try:
        req_body = req.get_json()
        payment_id = req_body.get('paymentId')
        amount = req_body.get('amount')
        
        # Create payment record
        payment_record = {
            "id": payment_id,
            "amount": amount,
            "status": "processed",
            "timestamp": datetime.utcnow().isoformat()
        }
        
        # Output to queue
        queueMsg.set(json.dumps({"paymentId": payment_id, "status": "processed"}))
        
        # Output to Cosmos DB
        cosmosDoc.set(func.Document.from_dict(payment_record))
        
        return func.HttpResponse(
            json.dumps({"status": "success", "paymentId": payment_id}),
            mimetype="application/json",
            status_code=200
        )
        
    except ValueError as e:
        return func.HttpResponse(
            json.dumps({"error": "Invalid request body"}),
            mimetype="application/json",
            status_code=400
        )
```

### requirements.txt

```txt
# Azure Functions
azure-functions==1.19.0

# Azure SDK
azure-storage-blob==12.19.0
azure-cosmos==4.5.1
azure-servicebus==7.11.4
azure-eventhub==5.11.5

# Utilities
requests==2.31.0
python-dateutil==2.8.2
pytz==2024.1

# Data processing
pandas==2.2.0
numpy==1.26.3

# Optional: Image processing
# Pillow==10.2.0

# Optional: Database
# psycopg2-binary==2.9.9  # PostgreSQL
# pymongo==4.6.1  # MongoDB
```

### Service Implementation Example

```python
# services/order_service.py

import logging
from typing import Dict, Any
from azure.cosmos import CosmosClient, exceptions
import os

class OrderService:
    """
    Service for handling order operations
    """
    
    def __init__(self):
        self.cosmos_connection = os.environ.get("CosmosDBConnection")
        self.database_name = "OrdersDB"
        self.container_name = "Orders"
        
    def process_order(self, order_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process order and save to Cosmos DB
        """
        try:
            # Validate order
            if not self._validate_order(order_data):
                raise ValueError("Invalid order data")
            
            # Calculate totals
            total = self._calculate_total(order_data)
            
            # Create order document
            order = {
                "id": order_data.get('orderId'),
                "customerId": order_data.get('customerId'),
                "items": order_data.get('items'),
                "total": total,
                "status": "processed",
                "createdAt": order_data.get('createdAt')
            }
            
            # Save to Cosmos DB
            self._save_to_cosmos(order)
            
            logging.info(f"Order {order['id']} processed successfully")
            
            return order
            
        except Exception as e:
            logging.error(f"Error processing order: {str(e)}")
            raise
    
    def _validate_order(self, order_data: Dict[str, Any]) -> bool:
        """Validate order data"""
        required_fields = ['orderId', 'customerId', 'items']
        return all(field in order_data for field in required_fields)
    
    def _calculate_total(self, order_data: Dict[str, Any]) -> float:
        """Calculate order total"""
        items = order_data.get('items', [])
        return sum(item.get('price', 0) * item.get('quantity', 0) for item in items)
    
    def _save_to_cosmos(self, order: Dict[str, Any]):
        """Save order to Cosmos DB"""
        try:
            client = CosmosClient.from_connection_string(self.cosmos_connection)
            database = client.get_database_client(self.database_name)
            container = database.get_container_client(self.container_name)
            
            container.upsert_item(order)
            
        except exceptions.CosmosHttpResponseError as e:
            logging.error(f"Cosmos DB error: {e.status_code} - {e.message}")
            raise
```

---

## Code Implementation - JavaScript/TypeScript

### Project Structure (Node.js v4 Model)

```
function-app/
├── src/
│   ├── functions/
│   │   ├── httpTrigger.ts
│   │   ├── timerTrigger.ts
│   │   └── queueTrigger.ts
│   ├── services/
│   │   ├── orderService.ts
│   │   └── notificationService.ts
│   ├── models/
│   │   └── order.ts
│   └── utils/
│       └── logger.ts
├── package.json
├── tsconfig.json
├── host.json
└── local.settings.json
```

### package.json

```json
{
  "name": "my-function-app",
  "version": "1.0.0",
  "description": "Azure Functions TypeScript",
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch",
    "prestart": "npm run build",
    "start": "func start",
    "test": "jest"
  },
  "dependencies": {
    "@azure/functions": "^4.3.0",
    "@azure/storage-blob": "^12.17.0",
    "@azure/cosmos": "^4.0.0",
    "@azure/service-bus": "^7.9.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "typescript": "^5.3.0",
    "@azure/functions-core-tools": "^4.0.5404",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.0"
  }
}
```

### HTTP Trigger (TypeScript)

```typescript
// src/functions/httpTrigger.ts

import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

/**
 * HTTP Trigger with routing
 * 
 * Routes:
 * GET  /api/products       - List all products
 * GET  /api/products/:id   - Get specific product
 * POST /api/products       - Create new product
 */

interface Product {
    id: string;
    name: string;
    price: number;
    category: string;
}

export async function httpTrigger(
    request: HttpRequest,
    context: InvocationContext
): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);

    // Get route parameters
    const productId = request.params.id;

    // Handle different HTTP methods
    switch (request.method) {
        case 'GET':
            return handleGet(productId, context);
        
        case 'POST':
            return await handlePost(request, context);
        
        case 'PUT':
            return await handlePut(productId, request, context);
        
        case 'DELETE':
            return handleDelete(productId, context);
        
        default:
            return {
                status: 405,
                jsonBody: { error: 'Method not allowed' }
            };
    }
}

function handleGet(productId: string | undefined, context: InvocationContext): HttpResponseInit {
    if (productId) {
        // Get specific product
        const product: Product = {
            id: productId,
            name: 'Sample Product',
            price: 99.99,
            category: 'Electronics'
        };

        return {
            status: 200,
            jsonBody: product,
            headers: {
                'Content-Type': 'application/json'
            }
        };
    } else {
        // List all products
        const products: Product[] = [
            { id: '1', name: 'Product 1', price: 29.99, category: 'Books' },
            { id: '2', name: 'Product 2', price: 49.99, category: 'Electronics' }
        ];

        return {
            status: 200,
            jsonBody: { products, count: products.length }
        };
    }
}

async function handlePost(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    try {
        // Parse request body
        const product = await request.json() as Product;

        // Validate
        if (!product.name || !product.price) {
            return {
                status: 400,
                jsonBody: { error: 'Name and price are required' }
            };
        }

        // Generate ID
        product.id = generateId();

        context.log(`Created product: ${product.id}`);

        return {
            status: 201,
            jsonBody: product,
            headers: {
                'Location': `/api/products/${product.id}`
            }
        };

    } catch (error) {
        context.error('Error creating product:', error);
        return {
            status: 400,
            jsonBody: { error: 'Invalid request body' }
        };
    }
}

async function handlePut(
    productId: string | undefined,
    request: HttpRequest,
    context: InvocationContext
): Promise<HttpResponseInit> {
    if (!productId) {
        return {
            status: 400,
            jsonBody: { error: 'Product ID is required' }
        };
    }

    try {
        const updates = await request.json() as Partial<Product>;

        const updatedProduct: Product = {
            id: productId,
            name: updates.name || 'Updated Product',
            price: updates.price || 0,
            category: updates.category || 'General'
        };

        context.log(`Updated product: ${productId}`);

        return {
            status: 200,
            jsonBody: updatedProduct
        };

    } catch (error) {
        context.error('Error updating product:', error);
        return {
            status: 400,
            jsonBody: { error: 'Invalid request body' }
        };
    }
}

function handleDelete(productId: string | undefined, context: InvocationContext): HttpResponseInit {
    if (!productId) {
        return {
            status: 400,
            jsonBody: { error: 'Product ID is required' }
        };
    }

    context.log(`Deleted product: ${productId}`);

    return {
        status: 204
    };
}

function generateId(): string {
    return `prod_${Date.now()}_${Math.random().toString(36).substring(7)}`;
}

// Register function
app.http('httpTrigger', {
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    authLevel: 'function',
    route: 'products/{id?}',
    handler: httpTrigger
});
```

### Timer Trigger (TypeScript)

```typescript
// src/functions/timerTrigger.ts

import { app, InvocationContext, Timer } from "@azure/functions";
import { ReportService } from '../services/reportService';

/**
 * Timer Trigger - Scheduled Job
 * Runs every day at 2 AM UTC
 */

export async function timerTrigger(timer: Timer, context: InvocationContext): Promise<void> {
    context.log('Timer function started at:', new Date().toISOString());

    if (timer.isPastDue) {
        context.log('WARNING: Timer is running late!');
    }

    try {
        // Generate daily report
        const reportService = new ReportService();
        const report = await reportService.generateDailyReport();

        context.log(`Report generated successfully. Records: ${report.recordCount}`);

        // Save report to blob storage
        await reportService.saveReport(report);

        context.log('Report saved to storage');

    } catch (error) {
        context.error('Error generating report:', error);
        throw error; // Re-throw to mark function as failed
    }

    context.log('Timer function completed at:', new Date().toISOString());
    context.log('Next execution:', timer.scheduleStatus?.next);
}

// Register function
app.timer('timerTrigger', {
    schedule: '0 0 2 * * *',  // 2 AM UTC daily
    handler: timerTrigger,
    runOnStartup: false,
    useMonitor: true
});
```

### Queue Trigger with Output Bindings (TypeScript)

```typescript
// src/functions/queueTrigger.ts

import { app, InvocationContext, output } from "@azure/functions";

/**
 * Queue Trigger with multiple output bindings
 * Processes orders from queue and:
 * - Saves to Cosmos DB
 * - Sends to processing queue
 * - Saves receipt to blob storage
 */

interface Order {
    orderId: string;
    customerId: string;
    items: OrderItem[];
    total: number;
}

interface OrderItem {
    productId: string;
    quantity: number;
    price: number;
}

// Define output bindings
const cosmosOutput = output.cosmosDB({
    databaseName: 'OrdersDB',
    containerName: 'Orders',
    connection: 'CosmosDBConnection'
});

const queueOutput = output.storageQueue({
    queueName: 'processed-orders',
    connection: 'AzureWebJobsStorage'
});

const blobOutput = output.storageBlob({
    path: 'receipts/{queueTrigger}.json',
    connection: 'AzureWebJobsStorage'
});

export async function queueTrigger(
    queueItem: unknown,
    context: InvocationContext
): Promise<void> {
    context.log('Queue trigger function processed item:', queueItem);

    try {
        // Parse queue message
        const order: Order = JSON.parse(queueItem as string);

        context.log(`Processing order: ${order.orderId}`);

        // Validate order
        if (!order.orderId || !order.customerId) {
            throw new Error('Invalid order data');
        }

        // Process order
        const processedOrder = {
            ...order,
            status: 'processed',
            processedAt: new Date().toISOString()
        };

        // Output to Cosmos DB
        context.extraOutputs.set(cosmosOutput, processedOrder);

        // Output to queue
        context.extraOutputs.set(queueOutput, JSON.stringify({
            orderId: order.orderId,
            status: 'processed',
            timestamp: new Date().toISOString()
        }));

        // Output receipt to blob
        const receipt = {
            orderId: order.orderId,
            total: order.total,
            receiptDate: new Date().toISOString(),
            items: order.items
        };
        context.extraOutputs.set(blobOutput, JSON.stringify(receipt, null, 2));

        context.log(`Order ${order.orderId} processed successfully`);

    } catch (error) {
        context.error('Error processing order:', error);
        throw error; // Re-throw to retry (poison queue after 5 failures)
    }
}

// Register function with output bindings
app.storageQueue('queueTrigger', {
    queueName: 'orders-to-process',
    connection: 'AzureWebJobsStorage',
    handler: queueTrigger,
    extraOutputs: [cosmosOutput, queueOutput, blobOutput]
});
```

### Blob Trigger (TypeScript)

```typescript
// src/functions/blobTrigger.ts

import { app, InvocationContext, input, output } from "@azure/functions";
import { BlobServiceClient } from "@azure/storage-blob";

/**
 * Blob Trigger with Event Grid
 * Processes images uploaded to 'uploads' container
 * Creates thumbnails and saves to 'thumbnails' container
 */

export async function blobTrigger(
    blob: Buffer,
    context: InvocationContext
): Promise<void> {
    context.log(`Blob trigger function processed blob "${context.triggerMetadata?.name}" with size ${blob.length} bytes`);

    const blobName = context.triggerMetadata?.name as string;

    try {
        // Process image (simplified example)
        // In production, use image processing library like 'sharp'
        const thumbnail = await createThumbnail(blob);

        // Upload thumbnail
        const thumbnailName = `thumb_${blobName}`;
        await uploadThumbnail(thumbnailName, thumbnail);

        context.log(`Thumbnail created: ${thumbnailName}`);

    } catch (error) {
        context.error('Error processing blob:', error);
        throw error;
    }
}

async function createThumbnail(imageBuffer: Buffer): Promise<Buffer> {
    // Simplified: In production, use 'sharp' or similar library
    // const sharp = require('sharp');
    // return await sharp(imageBuffer)
    //     .resize(150, 150)
    //     .toBuffer();
    
    return imageBuffer; // Placeholder
}

async function uploadThumbnail(name: string, buffer: Buffer): Promise<void> {
    const connectionString = process.env.AzureWebJobsStorage;
    if (!connectionString) {
        throw new Error('Storage connection string not found');
    }

    const blobServiceClient = BlobServiceClient.fromConnectionString(connectionString);
    const containerClient = blobServiceClient.getContainerClient('thumbnails');
    
    // Create container if not exists
    await containerClient.createIfNotExists();

    const blockBlobClient = containerClient.getBlockBlobClient(name);
    await blockBlobClient.upload(buffer, buffer.length);
}

// Register function with Event Grid source
app.storageBlob('blobTrigger', {
    path: 'uploads/{name}',
    connection: 'AzureWebJobsStorage',
    source: 'EventGrid',  // IMPORTANT: Use Event Grid for production
    handler: blobTrigger
});
```

### Service Bus Trigger (TypeScript)

```typescript
// src/functions/serviceBusTrigger.ts

import { app, InvocationContext, ServiceBusReceivedMessage } from "@azure/functions";
import { NotificationService } from '../services/notificationService';

/**
 * Service Bus Queue Trigger
 * Processes notification messages
 */

interface Notification {
    recipient: string;
    subject: string;
    body: string;
    type: 'email' | 'sms' | 'push';
}

export async function serviceBusTrigger(
    message: ServiceBusReceivedMessage,
    context: InvocationContext
): Promise<void> {
    context.log('Service Bus queue function processed message:', message.messageId);
    context.log('Message body:', message.body);
    context.log('Delivery count:', message.deliveryCount);

    try {
        // Parse message
        const notification: Notification = typeof message.body === 'string' 
            ? JSON.parse(message.body)
            : message.body;

        // Process notification
        const notificationService = new NotificationService();
        await notificationService.send(notification);

        context.log(`Notification sent to ${notification.recipient}`);

        // Message is automatically completed on success

    } catch (error) {
        context.error('Error processing notification:', error);
        throw error; // Re-throw to retry based on Service Bus policy
    }
}

// Register function
app.serviceBusQueue('serviceBusTrigger', {
    queueName: 'notifications',
    connection: 'ServiceBusConnection',
    handler: serviceBusTrigger
});
```

### Event Grid Trigger (TypeScript)

```typescript
// src/functions/eventGridTrigger.ts

import { app, EventGridEvent, InvocationContext } from "@azure/functions";

/**
 * Event Grid Trigger
 * Processes events from Event Grid topics
 */

export async function eventGridTrigger(
    event: EventGridEvent,
    context: InvocationContext
): Promise<void> {
    context.log('Event Grid function processed event:', event.id);
    context.log('Event Type:', event.eventType);
    context.log('Subject:', event.subject);
    context.log('Event Time:', event.eventTime);

    try {
        // Handle different event types
        switch (event.eventType) {
            case 'Microsoft.Storage.BlobCreated':
                await handleBlobCreated(event, context);
                break;

            case 'Microsoft.ContainerRegistry.ImagePushed':
                await handleImagePushed(event, context);
                break;

            case 'Microsoft.Resources.ResourceWriteSuccess':
                await handleResourceChange(event, context);
                break;

            default:
                context.log(`Unhandled event type: ${event.eventType}`);
        }

    } catch (error) {
        context.error('Error processing Event Grid event:', error);
        throw error;
    }
}

async function handleBlobCreated(event: EventGridEvent, context: InvocationContext): Promise<void> {
    const data = event.data;
    context.log(`New blob created: ${data.url}`);
    
    // Process the blob
    // Example: Validate file, send notification, etc.
}

async function handleImagePushed(event: EventGridEvent, context: InvocationContext): Promise<void> {
    const data = event.data;
    const imageName = data.target?.repository;
    const tag = data.target?.tag;
    
    context.log(`New container image pushed: ${imageName}:${tag}`);
    
    // Example: Trigger deployment, scan for vulnerabilities, etc.
}

async function handleResourceChange(event: EventGridEvent, context: InvocationContext): Promise<void> {
    const data = event.data;
    context.log(`Resource changed: ${data.resourceUri}`);
    
    // Example: Audit logging, compliance checks, etc.
}

// Register function
app.eventGrid('eventGridTrigger', {
    handler: eventGridTrigger
});
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "Node16",
    "moduleResolution": "Node16",
    "lib": ["ES2021"],
    "outDir": "dist",
    "rootDir": "src",
    "sourceMap": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "types": ["node"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

---

*(Continued in next part due to length...)*

**Note**: This is Part 1 of the Azure Functions guide. The document continues with:
- Durable Functions
- Testing Strategies
- Deployment Methods
- Monitoring & Observability
- Security & Authentication
- Real-world Scenarios
- Best Practices

Would you like me to continue with the remaining sections?
