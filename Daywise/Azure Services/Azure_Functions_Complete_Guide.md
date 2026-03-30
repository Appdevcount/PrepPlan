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
18. [Error Handling & Middleware](#error-handling--middleware)
19. [Azure Functions Platform Features & Configuration](#azure-functions-platform-features--configuration)
    - [CORS Configuration](#1-cors-cross-origin-resource-sharing)
    - [Function Proxies](#2-proxies-function-proxies)
    - [Custom Handlers](#3-custom-handlers)
    - [Deployment Slots](#4-deployment-slots)
    - [Application Settings](#5-application-settings--environment-variables)
    - [Network Features](#6-network-features)
    - [IP Restrictions](#7-ip-restrictions--access-restrictions)
    - [Custom Domains & SSL](#8-custom-domains--ssltls)
    - [Warm-up Trigger](#9-warm-up-trigger-premiumdedicated-plans)
    - [Function Keys](#10-function-keys--authorization)
    - [Easy Auth](#11-easy-auth-authentication--authorization)
    - [Host.json Reference](#12-hostjson-complete-reference)
20. [Real-World Scenarios](#real-world-scenarios)
21. [Best Practices & Patterns](#best-practices--patterns)
22. [Cost Optimization](#cost-optimization)
23. [Troubleshooting Guide](#troubleshooting-guide)

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
Ahhh got it 👍 — you want a **simple mental model only for Azure Functions + Storage Account relationship**,

Perfect. Let’s simplify it deeply.

---

# 🧠 The Easiest Mental Model

## Think of Azure Function as a Temporary Worker

## Azure Functions

Azure Function =
👷 A temporary worker who:

* Comes when work arrives
* Does the job
* Leaves
* Might come back later
* Might have 10 clones helping

Now ask:

> How do multiple temporary workers coordinate?

They need a **shared notebook** 📓

---

# 📓 That Notebook Is the Storage Account

## Azure Storage

The Storage Account is:

> A shared notebook all workers use to remember things.

---

# What Goes in That Notebook?

### 1️⃣ “Who already processed what?”

If function reads from a queue:

* It must remember which message was handled
* Otherwise duplicates happen

Notebook stores checkpoint.

---

### 2️⃣ “When did I last run?”

For Timer trigger:

* It writes last execution time
* So next worker knows when to run again

---

### 3️⃣ “How many workers are running?”

When scaling:

* Azure spins up multiple instances
* They coordinate using storage
* Prevent double processing

---

### 4️⃣ Durable Functions (Big One)

Durable Functions = workflow engine.

Example:

* Step 1
* Wait for external event
* Step 2

Where is workflow state stored?

👉 Storage account.

Without it, the workflow forgets everything.

---

# 🚨 Important Mental Shift

Azure Functions are:

> Stateless compute

Stateless means:

They forget everything after execution.

So Azure needs:

> External brain

That brain = Storage Account.

---

# 🏗 Even Simpler Model

Azure Function = CPU
Storage Account = Memory

Without memory:

CPU cannot coordinate distributed tasks.

---

# 🔄 Why It’s Mandatory in Consumption Plan

Because:

* Functions scale dynamically
* Instances are created and destroyed
* They need a shared coordination mechanism

Storage provides:

* Blob leases (locking)
* Tables (metadata)
* Queues (internal messaging)

---

# 🧠 Final 1-Line Mental Model

> Azure Functions need a Storage Account because stateless, scalable workers require a shared persistent coordination layer.

---

# 🎯 Architect-Level Insight

If storage is:

* Slow
* Throttled
* In different region

Then:

* Scaling becomes slow
* Timer triggers misfire
* Durable Functions lag

That’s why production setups use:

* Dedicated storage account
* Same region
* Proper performance tier

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

## Comprehensive Bindings Examples (C#)

### Input Bindings - Detailed Examples

#### 1. Blob Storage Input Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.IO;
using System.Text;

namespace MyFunctionApp.Bindings
{
    public class BlobInputExamples
    {
        private readonly ILogger<BlobInputExamples> _logger;

        public BlobInputExamples(ILogger<BlobInputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Read blob as Stream
        [Function("ReadBlobAsStream")]
        public async Task Run(
            [QueueTrigger("processing-queue")] string fileName,
            [BlobInput("input-container/{queueTrigger}.txt", 
                Connection = "AzureWebJobsStorage")] Stream blobStream)
        {
            _logger.LogInformation($"Processing file: {fileName}");

            using var reader = new StreamReader(blobStream);
            var content = await reader.ReadToEndAsync();
            
            _logger.LogInformation($"File content length: {content.Length}");
            // Process content...
        }

        // Example 2: Read blob as string
        [Function("ReadBlobAsString")]
        public void ProcessText(
            [QueueTrigger("text-queue")] string blobName,
            [BlobInput("documents/{queueTrigger}", 
                Connection = "AzureWebJobsStorage")] string blobContent)
        {
            _logger.LogInformation($"Content: {blobContent}");
            // Direct string access
        }

        // Example 3: Read blob as byte array
        [Function("ReadBlobAsBytes")]
        public void ProcessBinary(
            [QueueTrigger("binary-queue")] string fileName,
            [BlobInput("images/{queueTrigger}.jpg", 
                Connection = "AzureWebJobsStorage")] byte[] imageData)
        {
            _logger.LogInformation($"Image size: {imageData.Length} bytes");
            // Process binary data...
        }

        // Example 4: Read JSON blob as object
        [Function("ReadBlobAsObject")]
        public void ProcessJson(
            [QueueTrigger("json-queue")] string objectId,
            [BlobInput("data/{queueTrigger}.json", 
                Connection = "AzureWebJobsStorage")] CustomerData customer)
        {
            _logger.LogInformation($"Customer: {customer.Name}, Email: {customer.Email}");
        }
    }

    public class CustomerData
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
    }
}
```

#### 2. Queue Storage Input Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Storage.Queues.Models;

namespace MyFunctionApp.Bindings
{
    public class QueueInputExamples
    {
        private readonly ILogger<QueueInputExamples> _logger;

        public QueueInputExamples(ILogger<QueueInputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Simple string message
        [Function("ProcessQueueString")]
        public void ProcessString(
            [QueueTrigger("orders", Connection = "AzureWebJobsStorage")] 
            string message)
        {
            _logger.LogInformation($"Message: {message}");
        }

        // Example 2: JSON deserialized to object
        [Function("ProcessQueueObject")]
        public async Task ProcessObject(
            [QueueTrigger("orders", Connection = "AzureWebJobsStorage")] 
            OrderMessage order)
        {
            _logger.LogInformation($"Processing order: {order.OrderId}");
            _logger.LogInformation($"Customer: {order.CustomerId}");
            _logger.LogInformation($"Amount: ${order.Amount}");
            
            // Process order...
            await Task.Delay(100); // Simulate processing
        }

        // Example 3: Access message metadata
        [Function("ProcessQueueWithMetadata")]
        public void ProcessWithMetadata(
            [QueueTrigger("orders", Connection = "AzureWebJobsStorage")] 
            string message,
            string id,
            string popReceipt,
            int dequeueCount,
            DateTimeOffset insertionTime,
            DateTimeOffset expirationTime)
        {
            _logger.LogInformation($"Message ID: {id}");
            _logger.LogInformation($"Dequeue count: {dequeueCount}");
            _logger.LogInformation($"Inserted at: {insertionTime}");
            _logger.LogInformation($"Expires at: {expirationTime}");
            
            // Handle based on dequeue count
            if (dequeueCount > 3)
            {
                _logger.LogWarning("Message has been dequeued multiple times!");
            }
        }
    }

    public class OrderMessage
    {
        public string OrderId { get; set; }
        public string CustomerId { get; set; }
        public decimal Amount { get; set; }
        public DateTime OrderDate { get; set; }
    }
}
```

#### 3. Table Storage Input Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Data.Tables;

namespace MyFunctionApp.Bindings
{
    public class TableInputExamples
    {
        private readonly ILogger<TableInputExamples> _logger;

        public TableInputExamples(ILogger<TableInputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Read single entity
        [Function("ReadTableEntity")]
        public void ReadEntity(
            [HttpTrigger(AuthorizationLevel.Function, "get", 
                Route = "user/{userId}")] HttpRequestData req,
            [TableInput("Users", "{userId}", "{userId}", 
                Connection = "AzureWebJobsStorage")] UserEntity user)
        {
            if (user != null)
            {
                _logger.LogInformation($"User found: {user.Name}, {user.Email}");
            }
            else
            {
                _logger.LogWarning("User not found");
            }
        }

        // Example 2: Query multiple entities using TableClient
        [Function("QueryTableEntities")]
        public async Task QueryEntities(
            [HttpTrigger(AuthorizationLevel.Function, "get", 
                Route = "users")] HttpRequestData req,
            [TableInput("Users", Connection = "AzureWebJobsStorage")] 
            TableClient tableClient)
        {
            var query = tableClient.QueryAsync<UserEntity>(
                filter: u => u.PartitionKey == "Active");

            await foreach (var user in query)
            {
                _logger.LogInformation($"User: {user.Name}");
            }
        }
    }

    public class UserEntity : ITableEntity
    {
        public string PartitionKey { get; set; }
        public string RowKey { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTimeOffset? Timestamp { get; set; }
        public ETag ETag { get; set; }
    }
}
```

#### 4. Cosmos DB Input Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace MyFunctionApp.Bindings
{
    public class CosmosDbInputExamples
    {
        private readonly ILogger<CosmosDbInputExamples> _logger;

        public CosmosDbInputExamples(ILogger<CosmosDbInputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Read single document by ID
        [Function("GetOrderById")]
        public HttpResponseData GetOrder(
            [HttpTrigger(AuthorizationLevel.Function, "get", 
                Route = "orders/{id}")] HttpRequestData req,
            [CosmosDBInput(
                databaseName: "OrdersDB",
                containerName: "Orders",
                Id = "{id}",
                PartitionKey = "{id}",
                Connection = "CosmosDBConnection")] OrderDocument order)
        {
            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            
            if (order != null)
            {
                response.WriteAsJsonAsync(order);
            }
            else
            {
                response.StatusCode = System.Net.HttpStatusCode.NotFound;
            }
            
            return response;
        }

        // Example 2: Query multiple documents with SQL
        [Function("GetOrdersByCustomer")]
        public HttpResponseData GetOrdersByCustomer(
            [HttpTrigger(AuthorizationLevel.Function, "get", 
                Route = "customers/{customerId}/orders")] HttpRequestData req,
            [CosmosDBInput(
                databaseName: "OrdersDB",
                containerName: "Orders",
                SqlQuery = "SELECT * FROM c WHERE c.customerId = {customerId}",
                Connection = "CosmosDBConnection")] IEnumerable<OrderDocument> orders)
        {
            _logger.LogInformation($"Found {orders.Count()} orders");

            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            response.WriteAsJsonAsync(orders);
            return response;
        }

        // Example 3: Query with parameters
        [Function("GetActiveOrders")]
        public HttpResponseData GetActiveOrders(
            [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req,
            [CosmosDBInput(
                databaseName: "OrdersDB",
                containerName: "Orders",
                SqlQuery = "SELECT * FROM c WHERE c.status = 'Active' AND c.createdDate >= @startDate",
                Connection = "CosmosDBConnection")] IEnumerable<OrderDocument> orders)
        {
            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            response.WriteAsJsonAsync(new
            {
                count = orders.Count(),
                orders = orders
            });
            return response;
        }
    }

    public class OrderDocument
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        
        [JsonProperty("customerId")]
        public string CustomerId { get; set; }
        
        [JsonProperty("orderNumber")]
        public string OrderNumber { get; set; }
        
        [JsonProperty("amount")]
        public decimal Amount { get; set; }
        
        [JsonProperty("status")]
        public string Status { get; set; }
        
        [JsonProperty("createdDate")]
        public DateTime CreatedDate { get; set; }
        
        [JsonProperty("items")]
        public List<OrderItem> Items { get; set; }
    }

    public class OrderItem
    {
        public string ProductId { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }
}
```

#### 5. SQL Input Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.Bindings
{
    public class SqlInputExamples
    {
        private readonly ILogger<SqlInputExamples> _logger;

        public SqlInputExamples(ILogger<SqlInputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Simple SQL query
        [Function("GetProducts")]
        public HttpResponseData GetProducts(
            [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req,
            [SqlInput(
                commandText: "SELECT * FROM Products WHERE IsActive = 1",
                commandType: System.Data.CommandType.Text,
                connectionStringSetting: "SqlConnectionString")] 
            IEnumerable<Product> products)
        {
            _logger.LogInformation($"Found {products.Count()} products");

            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            response.WriteAsJsonAsync(products);
            return response;
        }

        // Example 2: Parameterized query
        [Function("GetProductsByCategory")]
        public HttpResponseData GetProductsByCategory(
            [HttpTrigger(AuthorizationLevel.Function, "get", 
                Route = "products/category/{categoryId}")] HttpRequestData req,
            [SqlInput(
                commandText: "SELECT * FROM Products WHERE CategoryId = @CategoryId",
                commandType: System.Data.CommandType.Text,
                parameters: "@CategoryId={categoryId}",
                connectionStringSetting: "SqlConnectionString")] 
            IEnumerable<Product> products)
        {
            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            response.WriteAsJsonAsync(products);
            return response;
        }

        // Example 3: Stored procedure
        [Function("GetCustomerOrders")]
        public HttpResponseData GetCustomerOrders(
            [HttpTrigger(AuthorizationLevel.Function, "get", 
                Route = "customers/{customerId}/orders")] HttpRequestData req,
            [SqlInput(
                commandText: "dbo.GetCustomerOrders",
                commandType: System.Data.CommandType.StoredProcedure,
                parameters: "@CustomerId={customerId}",
                connectionStringSetting: "SqlConnectionString")] 
            IEnumerable<CustomerOrder> orders)
        {
            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            response.WriteAsJsonAsync(orders);
            return response;
        }
    }

    public class Product
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string CategoryId { get; set; }
        public decimal Price { get; set; }
        public bool IsActive { get; set; }
    }

    public class CustomerOrder
    {
        public int OrderId { get; set; }
        public int CustomerId { get; set; }
        public DateTime OrderDate { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; }
    }
}
```

---

### Output Bindings - Detailed Examples

#### 1. Blob Storage Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Text;

namespace MyFunctionApp.Bindings
{
    public class BlobOutputExamples
    {
        private readonly ILogger<BlobOutputExamples> _logger;

        public BlobOutputExamples(ILogger<BlobOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Write string to blob
        [Function("WriteBlobString")]
        [BlobOutput("output-container/{rand-guid}.txt", 
            Connection = "AzureWebJobsStorage")]
        public string WriteText(
            [QueueTrigger("data-queue")] string data)
        {
            _logger.LogInformation("Writing data to blob");
            return $"Processed at {DateTime.UtcNow}: {data}";
        }

        // Example 2: Write byte array to blob
        [Function("WriteBlobBytes")]
        [BlobOutput("images/{sys.utcNow:yyyy-MM-dd}/{rand-guid}.jpg", 
            Connection = "AzureWebJobsStorage")]
        public byte[] WriteImage(
            [QueueTrigger("image-queue")] byte[] imageData)
        {
            _logger.LogInformation($"Writing {imageData.Length} bytes");
            
            // Process image...
            var processedImage = ProcessImage(imageData);
            return processedImage;
        }

        // Example 3: Write stream to blob
        [Function("WriteBlobStream")]
        public async Task WriteStream(
            [QueueTrigger("large-data-queue")] string data,
            [BlobOutput("reports/{sys.utcNow:yyyy-MM-dd}/report-{rand-guid}.txt", 
                Connection = "AzureWebJobsStorage")] Stream outputBlob)
        {
            using var writer = new StreamWriter(outputBlob);
            await writer.WriteLineAsync("Report Header");
            await writer.WriteLineAsync($"Generated: {DateTime.UtcNow}");
            await writer.WriteLineAsync("---");
            await writer.WriteAsync(data);
        }

        // Example 4: Write JSON object to blob
        [Function("WriteBlobJson")]
        [BlobOutput("data/{id}.json", Connection = "AzureWebJobsStorage")]
        public ReportData WriteJson(
            [TimerTrigger("0 0 * * * *")] TimerInfo timer)
        {
            _logger.LogInformation("Generating report");
            
            return new ReportData
            {
                Id = Guid.NewGuid().ToString(),
                GeneratedAt = DateTime.UtcNow,
                Metrics = new Dictionary<string, int>
                {
                    { "TotalOrders", 150 },
                    { "CompletedOrders", 145 },
                    { "PendingOrders", 5 }
                }
            };
        }

        private byte[] ProcessImage(byte[] input)
        {
            // Image processing logic
            return input;
        }
    }

    public class ReportData
    {
        public string Id { get; set; }
        public DateTime GeneratedAt { get; set; }
        public Dictionary<string, int> Metrics { get; set; }
    }
}
```

#### 2. Queue Storage Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace MyFunctionApp.Bindings
{
    public class QueueOutputExamples
    {
        private readonly ILogger<QueueOutputExamples> _logger;

        public QueueOutputExamples(ILogger<QueueOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Single queue output - simple string
        [Function("WriteQueueString")]
        [QueueOutput("processing-queue", Connection = "AzureWebJobsStorage")]
        public string SendMessage(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
        {
            var message = $"Task created at {DateTime.UtcNow}";
            _logger.LogInformation($"Queuing: {message}");
            return message;
        }

        // Example 2: Single queue output - JSON object
        [Function("WriteQueueObject")]
        [QueueOutput("order-queue", Connection = "AzureWebJobsStorage")]
        public OrderMessage SendOrder(
            [HttpTrigger(AuthorizationLevel.Function, "post")] OrderRequest request)
        {
            _logger.LogInformation($"Queuing order: {request.OrderId}");
            
            return new OrderMessage
            {
                OrderId = request.OrderId,
                CustomerId = request.CustomerId,
                Amount = request.Amount,
                OrderDate = DateTime.UtcNow
            };
        }

        // Example 3: Multiple messages to same queue
        [Function("WriteMultipleMessages")]
        [QueueOutput("notifications-queue", Connection = "AzureWebJobsStorage")]
        public List<NotificationMessage> SendNotifications(
            [TimerTrigger("0 0 8 * * *")] TimerInfo timer)
        {
            _logger.LogInformation("Sending daily notifications");
            
            return new List<NotificationMessage>
            {
                new NotificationMessage { UserId = "user1", Message = "Daily summary" },
                new NotificationMessage { UserId = "user2", Message = "Daily summary" },
                new NotificationMessage { UserId = "user3", Message = "Daily summary" }
            };
        }

        // Example 4: Multiple queue outputs (different queues)
        [Function("WriteToMultipleQueues")]
        public MultiQueueOutput ProcessOrder(
            [QueueTrigger("incoming-orders")] OrderMessage order)
        {
            _logger.LogInformation($"Processing order: {order.OrderId}");
            
            return new MultiQueueOutput
            {
                PaymentQueue = new PaymentMessage
                {
                    OrderId = order.OrderId,
                    Amount = order.Amount
                },
                ShippingQueue = new ShippingMessage
                {
                    OrderId = order.OrderId,
                    CustomerId = order.CustomerId
                },
                NotificationQueue = new NotificationMessage
                {
                    UserId = order.CustomerId,
                    Message = $"Order {order.OrderId} is being processed"
                }
            };
        }
    }

    public class MultiQueueOutput
    {
        [QueueOutput("payment-queue", Connection = "AzureWebJobsStorage")]
        public PaymentMessage PaymentQueue { get; set; }
        
        [QueueOutput("shipping-queue", Connection = "AzureWebJobsStorage")]
        public ShippingMessage ShippingQueue { get; set; }
        
        [QueueOutput("notification-queue", Connection = "AzureWebJobsStorage")]
        public NotificationMessage NotificationQueue { get; set; }
    }

    public class OrderRequest
    {
        public string OrderId { get; set; }
        public string CustomerId { get; set; }
        public decimal Amount { get; set; }
    }

    public class PaymentMessage
    {
        public string OrderId { get; set; }
        public decimal Amount { get; set; }
    }

    public class ShippingMessage
    {
        public string OrderId { get; set; }
        public string CustomerId { get; set; }
    }

    public class NotificationMessage
    {
        public string UserId { get; set; }
        public string Message { get; set; }
    }
}
```

#### 3. Table Storage Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Data.Tables;

namespace MyFunctionApp.Bindings
{
    public class TableOutputExamples
    {
        private readonly ILogger<TableOutputExamples> _logger;

        public TableOutputExamples(ILogger<TableOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Write single entity
        [Function("WriteTableEntity")]
        [TableOutput("AuditLog", Connection = "AzureWebJobsStorage")]
        public AuditLogEntity LogAction(
            [HttpTrigger(AuthorizationLevel.Function, "post")] LogRequest request)
        {
            _logger.LogInformation($"Logging action: {request.Action}");
            
            return new AuditLogEntity
            {
                PartitionKey = request.UserId,
                RowKey = Guid.NewGuid().ToString(),
                Action = request.Action,
                Timestamp = DateTime.UtcNow,
                Details = request.Details
            };
        }

        // Example 2: Write multiple entities
        [Function("WriteMultipleEntities")]
        [TableOutput("UserActivity", Connection = "AzureWebJobsStorage")]
        public List<UserActivityEntity> LogActivities(
            [QueueTrigger("activity-queue")] List<ActivityData> activities)
        {
            _logger.LogInformation($"Logging {activities.Count} activities");
            
            return activities.Select(a => new UserActivityEntity
            {
                PartitionKey = a.UserId,
                RowKey = $"{DateTime.UtcNow.Ticks}_{Guid.NewGuid()}",
                ActivityType = a.Type,
                ActivityDate = DateTime.UtcNow,
                Details = a.Details
            }).ToList();
        }

        // Example 3: Update or insert entity
        [Function("UpsertTableEntity")]
        public async Task UpsertEntity(
            [HttpTrigger(AuthorizationLevel.Function, "put", 
                Route = "users/{userId}")] HttpRequestData req,
            string userId,
            [TableInput("Users", Connection = "AzureWebJobsStorage")] 
            TableClient tableClient)
        {
            var user = await req.ReadFromJsonAsync<UserProfile>();
            
            var entity = new UserProfileEntity
            {
                PartitionKey = "Users",
                RowKey = userId,
                Name = user.Name,
                Email = user.Email,
                LastUpdated = DateTime.UtcNow
            };

            // Upsert (insert or replace)
            await tableClient.UpsertEntityAsync(entity, TableUpdateMode.Replace);
            
            _logger.LogInformation($"User {userId} upserted");
        }

        // Example 4: Batch operations
        [Function("BatchTableOperations")]
        public async Task BatchWrite(
            [QueueTrigger("batch-queue")] List<UserData> users,
            [TableInput("Users", Connection = "AzureWebJobsStorage")] 
            TableClient tableClient)
        {
            var batch = new List<TableTransactionAction>();
            
            foreach (var user in users)
            {
                var entity = new UserProfileEntity
                {
                    PartitionKey = "Users",
                    RowKey = user.Id,
                    Name = user.Name,
                    Email = user.Email
                };
                
                batch.Add(new TableTransactionAction(
                    TableTransactionActionType.UpsertReplace, entity));
            }
            
            // Submit batch (max 100 operations per batch)
            if (batch.Any())
            {
                await tableClient.SubmitTransactionAsync(batch);
                _logger.LogInformation($"Batch wrote {batch.Count} entities");
            }
        }
    }

    public class AuditLogEntity : ITableEntity
    {
        public string PartitionKey { get; set; }
        public string RowKey { get; set; }
        public string Action { get; set; }
        public DateTime Timestamp { get; set; }
        public string Details { get; set; }
        DateTimeOffset? ITableEntity.Timestamp { get; set; }
        ETag ITableEntity.ETag { get; set; }
    }

    public class UserActivityEntity : ITableEntity
    {
        public string PartitionKey { get; set; }
        public string RowKey { get; set; }
        public string ActivityType { get; set; }
        public DateTime ActivityDate { get; set; }
        public string Details { get; set; }
        DateTimeOffset? ITableEntity.Timestamp { get; set; }
        ETag ITableEntity.ETag { get; set; }
    }

    public class UserProfileEntity : ITableEntity
    {
        public string PartitionKey { get; set; }
        public string RowKey { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public DateTime LastUpdated { get; set; }
        DateTimeOffset? ITableEntity.Timestamp { get; set; }
        ETag ITableEntity.ETag { get; set; }
    }

    public class LogRequest
    {
        public string UserId { get; set; }
        public string Action { get; set; }
        public string Details { get; set; }
    }

    public class ActivityData
    {
        public string UserId { get; set; }
        public string Type { get; set; }
        public string Details { get; set; }
    }

    public class UserProfile
    {
        public string Name { get; set; }
        public string Email { get; set; }
    }

    public class UserData
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
    }
}
```

#### 4. Cosmos DB Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace MyFunctionApp.Bindings
{
    public class CosmosDbOutputExamples
    {
        private readonly ILogger<CosmosDbOutputExamples> _logger;

        public CosmosDbOutputExamples(ILogger<CosmosDbOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Write single document
        [Function("WriteCosmosDocument")]
        [CosmosDBOutput(
            databaseName: "OrdersDB",
            containerName: "Orders",
            Connection = "CosmosDBConnection",
            CreateIfNotExists = true,
            PartitionKey = "/customerId")]
        public OrderDocument SaveOrder(
            [HttpTrigger(AuthorizationLevel.Function, "post")] OrderRequest request)
        {
            _logger.LogInformation($"Saving order: {request.OrderId}");
            
            return new OrderDocument
            {
                Id = request.OrderId,
                CustomerId = request.CustomerId,
                OrderNumber = $"ORD-{DateTime.UtcNow.Ticks}",
                Amount = request.Amount,
                Status = "Pending",
                CreatedDate = DateTime.UtcNow,
                Items = request.Items
            };
        }

        // Example 2: Write multiple documents
        [Function("WriteManyCosmosDocuments")]
        [CosmosDBOutput(
            databaseName: "ProductsDB",
            containerName: "Products",
            Connection = "CosmosDBConnection")]
        public List<ProductDocument> SaveProducts(
            [BlobTrigger("import/{name}.json")] List<ProductImport> products)
        {
            _logger.LogInformation($"Importing {products.Count} products");
            
            return products.Select(p => new ProductDocument
            {
                Id = Guid.NewGuid().ToString(),
                Sku = p.Sku,
                Name = p.Name,
                Price = p.Price,
                CategoryId = p.CategoryId,
                ImportedDate = DateTime.UtcNow
            }).ToList();
        }

        // Example 3: Multiple outputs to different containers
        [Function("ProcessOrderWithOutputs")]
        public OrderProcessingOutput ProcessOrder(
            [QueueTrigger("order-processing")] OrderMessage order)
        {
            _logger.LogInformation($"Processing order: {order.OrderId}");
            
            return new OrderProcessingOutput
            {
                // Save to Orders container
                Order = new OrderDocument
                {
                    Id = order.OrderId,
                    CustomerId = order.CustomerId,
                    Amount = order.Amount,
                    Status = "Processed",
                    CreatedDate = DateTime.UtcNow
                },
                
                // Save to Audit container
                Audit = new AuditDocument
                {
                    Id = Guid.NewGuid().ToString(),
                    EntityType = "Order",
                    EntityId = order.OrderId,
                    Action = "Processed",
                    Timestamp = DateTime.UtcNow,
                    UserId = "system"
                },
                
                // Save to Analytics container
                Analytics = new OrderAnalyticsDocument
                {
                    Id = $"{DateTime.UtcNow:yyyyMMdd}_{order.CustomerId}",
                    CustomerId = order.CustomerId,
                    Date = DateTime.UtcNow.Date,
                    OrderCount = 1,
                    TotalAmount = order.Amount
                }
            };
        }

        // Example 4: Conditional write with conflict handling
        [Function("UpsertCosmosDocument")]
        public async Task UpsertDocument(
            [HttpTrigger(AuthorizationLevel.Function, "put")] HttpRequestData req,
            [CosmosDBInput(
                databaseName: "CustomersDB",
                containerName: "Customers",
                Connection = "CosmosDBConnection")] CosmosClient cosmosClient)
        {
            var customerUpdate = await req.ReadFromJsonAsync<CustomerUpdate>();
            
            var container = cosmosClient.GetDatabase("CustomersDB")
                .GetContainer("Customers");
            
            try
            {
                // Try to read existing document
                var response = await container.ReadItemAsync<CustomerDocument>(
                    customerUpdate.Id, 
                    new PartitionKey(customerUpdate.CustomerId));
                
                var existing = response.Resource;
                
                // Update properties
                existing.Name = customerUpdate.Name;
                existing.Email = customerUpdate.Email;
                existing.LastModified = DateTime.UtcNow;
                
                // Replace with ETag for optimistic concurrency
                await container.ReplaceItemAsync(
                    existing, 
                    existing.Id, 
                    new PartitionKey(existing.CustomerId),
                    new ItemRequestOptions { IfMatchEtag = response.ETag });
                
                _logger.LogInformation($"Updated customer: {existing.Id}");
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                // Create new document
                var newCustomer = new CustomerDocument
                {
                    Id = customerUpdate.Id,
                    CustomerId = customerUpdate.CustomerId,
                    Name = customerUpdate.Name,
                    Email = customerUpdate.Email,
                    CreatedDate = DateTime.UtcNow,
                    LastModified = DateTime.UtcNow
                };
                
                await container.CreateItemAsync(
                    newCustomer, 
                    new PartitionKey(newCustomer.CustomerId));
                
                _logger.LogInformation($"Created customer: {newCustomer.Id}");
            }
        }
    }

    public class OrderProcessingOutput
    {
        [CosmosDBOutput(
            databaseName: "OrdersDB",
            containerName: "Orders",
            Connection = "CosmosDBConnection")]
        public OrderDocument Order { get; set; }
        
        [CosmosDBOutput(
            databaseName: "OrdersDB",
            containerName: "Audit",
            Connection = "CosmosDBConnection")]
        public AuditDocument Audit { get; set; }
        
        [CosmosDBOutput(
            databaseName: "AnalyticsDB",
            containerName: "OrderAnalytics",
            Connection = "CosmosDBConnection")]
        public OrderAnalyticsDocument Analytics { get; set; }
    }

    public class ProductDocument
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        
        [JsonProperty("sku")]
        public string Sku { get; set; }
        
        [JsonProperty("name")]
        public string Name { get; set; }
        
        [JsonProperty("price")]
        public decimal Price { get; set; }
        
        [JsonProperty("categoryId")]
        public string CategoryId { get; set; }
        
        [JsonProperty("importedDate")]
        public DateTime ImportedDate { get; set; }
    }

    public class AuditDocument
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        
        [JsonProperty("entityType")]
        public string EntityType { get; set; }
        
        [JsonProperty("entityId")]
        public string EntityId { get; set; }
        
        [JsonProperty("action")]
        public string Action { get; set; }
        
        [JsonProperty("timestamp")]
        public DateTime Timestamp { get; set; }
        
        [JsonProperty("userId")]
        public string UserId { get; set; }
    }

    public class OrderAnalyticsDocument
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        
        [JsonProperty("customerId")]
        public string CustomerId { get; set; }
        
        [JsonProperty("date")]
        public DateTime Date { get; set; }
        
        [JsonProperty("orderCount")]
        public int OrderCount { get; set; }
        
        [JsonProperty("totalAmount")]
        public decimal TotalAmount { get; set; }
    }

    public class ProductImport
    {
        public string Sku { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public string CategoryId { get; set; }
    }

    public class CustomerUpdate
    {
        public string Id { get; set; }
        public string CustomerId { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
    }

    public class CustomerDocument
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        
        [JsonProperty("customerId")]
        public string CustomerId { get; set; }
        
        [JsonProperty("name")]
        public string Name { get; set; }
        
        [JsonProperty("email")]
        public string Email { get; set; }
        
        [JsonProperty("createdDate")]
        public DateTime CreatedDate { get; set; }
        
        [JsonProperty("lastModified")]
        public DateTime LastModified { get; set; }
    }
}
```

#### 5. Service Bus Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Messaging.ServiceBus;

namespace MyFunctionApp.Bindings
{
    public class ServiceBusOutputExamples
    {
        private readonly ILogger<ServiceBusOutputExamples> _logger;

        public ServiceBusOutputExamples(ILogger<ServiceBusOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Send to queue - simple message
        [Function("SendServiceBusMessage")]
        [ServiceBusOutput("order-processing", Connection = "ServiceBusConnection")]
        public string SendToQueue(
            [HttpTrigger(AuthorizationLevel.Function, "post")] OrderRequest order)
        {
            _logger.LogInformation($"Sending order to queue: {order.OrderId}");
            return System.Text.Json.JsonSerializer.Serialize(order);
        }

        // Example 2: Send to queue - object (auto-serialized)
        [Function("SendServiceBusObject")]
        [ServiceBusOutput("notifications", Connection = "ServiceBusConnection")]
        public NotificationMessage SendNotification(
            [QueueTrigger("notification-trigger")] string userId)
        {
            return new NotificationMessage
            {
                UserId = userId,
                Message = "Your order has been processed",
                Timestamp = DateTime.UtcNow,
                Priority = "High"
            };
        }

        // Example 3: Send to topic with message properties
        [Function("SendServiceBusWithProperties")]
        public async Task SendToTopicWithProperties(
            [HttpTrigger(AuthorizationLevel.Function, "post")] EventData eventData,
            [ServiceBusOutput("events-topic", Connection = "ServiceBusConnection")] 
            ServiceBusSender sender)
        {
            var message = new ServiceBusMessage(
                System.Text.Json.JsonSerializer.Serialize(eventData))
            {
                ContentType = "application/json",
                MessageId = Guid.NewGuid().ToString(),
                Subject = eventData.EventType,
                TimeToLive = TimeSpan.FromHours(24)
            };
            
            // Add custom properties
            message.ApplicationProperties["EventType"] = eventData.EventType;
            message.ApplicationProperties["Source"] = "FunctionApp";
            message.ApplicationProperties["Priority"] = eventData.Priority;
            
            // Add session ID for ordered processing
            if (!string.IsNullOrEmpty(eventData.SessionId))
            {
                message.SessionId = eventData.SessionId;
            }
            
            await sender.SendMessageAsync(message);
            _logger.LogInformation($"Sent message {message.MessageId} to topic");
        }

        // Example 4: Send batch messages
        [Function("SendServiceBusBatch")]
        public async Task SendBatch(
            [TimerTrigger("0 */5 * * * *")] TimerInfo timer,
            [ServiceBusOutput("batch-processing", Connection = "ServiceBusConnection")] 
            ServiceBusSender sender)
        {
            var messages = GenerateBatchMessages();
            
            // Create batch
            using ServiceBusMessageBatch messageBatch = 
                await sender.CreateMessageBatchAsync();
            
            foreach (var message in messages)
            {
                var sbMessage = new ServiceBusMessage(
                    System.Text.Json.JsonSerializer.Serialize(message));
                
                if (!messageBatch.TryAddMessage(sbMessage))
                {
                    // Send current batch and create new one
                    await sender.SendMessagesAsync(messageBatch);
                    messageBatch.Dispose();
                    
                    var newBatch = await sender.CreateMessageBatchAsync();
                    newBatch.TryAddMessage(sbMessage);
                }
            }
            
            // Send remaining messages
            if (messageBatch.Count > 0)
            {
                await sender.SendMessagesAsync(messageBatch);
                _logger.LogInformation($"Sent batch of {messageBatch.Count} messages");
            }
        }

        // Example 5: Multiple Service Bus outputs
        [Function("SendToMultipleServiceBusDestinations")]
        public MultiServiceBusOutput ProcessEvent(
            [EventHubTrigger("events", Connection = "EventHubConnection")] 
            string eventData)
        {
            var evt = System.Text.Json.JsonSerializer.Deserialize<EventMessage>(eventData);
            
            return new MultiServiceBusOutput
            {
                // Send to orders queue
                OrderQueue = new OrderProcessingMessage
                {
                    OrderId = evt.OrderId,
                    Action = "Process"
                },
                
                // Send to notifications topic
                NotificationTopic = new NotificationMessage
                {
                    UserId = evt.UserId,
                    Message = $"Event processed: {evt.EventType}"
                },
                
                // Send to audit queue
                AuditQueue = new AuditMessage
                {
                    EventId = evt.EventId,
                    EventType = evt.EventType,
                    Timestamp = DateTime.UtcNow
                }
            };
        }

        private List<BatchItem> GenerateBatchMessages()
        {
            return Enumerable.Range(1, 100)
                .Select(i => new BatchItem
                {
                    Id = i,
                    Data = $"Item {i}",
                    Timestamp = DateTime.UtcNow
                })
                .ToList();
        }
    }

    public class MultiServiceBusOutput
    {
        [ServiceBusOutput("order-processing", Connection = "ServiceBusConnection")]
        public OrderProcessingMessage OrderQueue { get; set; }
        
        [ServiceBusOutput("notifications-topic", Connection = "ServiceBusConnection")]
        public NotificationMessage NotificationTopic { get; set; }
        
        [ServiceBusOutput("audit-queue", Connection = "ServiceBusConnection")]
        public AuditMessage AuditQueue { get; set; }
    }

    public class EventData
    {
        public string EventType { get; set; }
        public string Priority { get; set; }
        public string SessionId { get; set; }
        public object Payload { get; set; }
    }

    public class OrderProcessingMessage
    {
        public string OrderId { get; set; }
        public string Action { get; set; }
    }

    public class AuditMessage
    {
        public string EventId { get; set; }
        public string EventType { get; set; }
        public DateTime Timestamp { get; set; }
    }

    public class EventMessage
    {
        public string EventId { get; set; }
        public string OrderId { get; set; }
        public string UserId { get; set; }
        public string EventType { get; set; }
    }

    public class BatchItem
    {
        public int Id { get; set; }
        public string Data { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
```

#### 6. Event Grid Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Messaging.EventGrid;

namespace MyFunctionApp.Bindings
{
    public class EventGridOutputExamples
    {
        private readonly ILogger<EventGridOutputExamples> _logger;

        public EventGridOutputExamples(ILogger<EventGridOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Send single event
        [Function("SendEventGridEvent")]
        [EventGridOutput(TopicEndpointUri = "EventGridTopicEndpoint", 
            TopicKeySetting = "EventGridTopicKey")]
        public EventGridEvent PublishEvent(
            [HttpTrigger(AuthorizationLevel.Function, "post")] OrderCompletedData order)
        {
            _logger.LogInformation($"Publishing order completed event: {order.OrderId}");
            
            return new EventGridEvent(
                subject: $"orders/{order.OrderId}",
                eventType: "OrderCompleted",
                dataVersion: "1.0",
                data: new
                {
                    orderId = order.OrderId,
                    customerId = order.CustomerId,
                    amount = order.Amount,
                    completedAt = DateTime.UtcNow
                });
        }

        // Example 2: Send multiple events
        [Function("SendMultipleEventGridEvents")]
        [EventGridOutput(TopicEndpointUri = "EventGridTopicEndpoint", 
            TopicKeySetting = "EventGridTopicKey")]
        public List<EventGridEvent> PublishBatchEvents(
            [TimerTrigger("0 0 * * * *")] TimerInfo timer)
        {
            _logger.LogInformation("Publishing hourly summary events");
            
            var events = new List<EventGridEvent>();
            
            // Order summary event
            events.Add(new EventGridEvent(
                subject: "analytics/orders/hourly",
                eventType: "OrderSummary",
                dataVersion: "1.0",
                data: new
                {
                    hour = DateTime.UtcNow.Hour,
                    totalOrders = 150,
                    totalRevenue = 45000.00m
                }));
            
            // Inventory summary event
            events.Add(new EventGridEvent(
                subject: "analytics/inventory/hourly",
                eventType: "InventorySummary",
                dataVersion: "1.0",
                data: new
                {
                    hour = DateTime.UtcNow.Hour,
                    lowStockItems = 12,
                    outOfStockItems = 3
                }));
            
            return events;
        }

        // Example 3: Custom event with CloudEvent schema
        [Function("SendCloudEvent")]
        public async Task PublishCloudEvent(
            [HttpTrigger(AuthorizationLevel.Function, "post")] PaymentProcessedData payment,
            [EventGridOutput(TopicEndpointUri = "EventGridTopicEndpoint", 
                TopicKeySetting = "EventGridTopicKey")] 
            EventGridPublisherClient client)
        {
            var cloudEvent = new CloudEvent(
                source: "/payments/processor",
                type: "PaymentProcessed",
                jsonSerializableData: new
                {
                    paymentId = payment.PaymentId,
                    orderId = payment.OrderId,
                    amount = payment.Amount,
                    status = "Success"
                })
            {
                Id = Guid.NewGuid().ToString(),
                Time = DateTimeOffset.UtcNow,
                Subject = $"payments/{payment.PaymentId}"
            };
            
            await client.SendEventAsync(cloudEvent);
            _logger.LogInformation($"Published payment event: {cloudEvent.Id}");
        }
    }

    public class OrderCompletedData
    {
        public string OrderId { get; set; }
        public string CustomerId { get; set; }
        public decimal Amount { get; set; }
    }

    public class PaymentProcessedData
    {
        public string PaymentId { get; set; }
        public string OrderId { get; set; }
        public decimal Amount { get; set; }
    }
}
```

#### 7. SendGrid (Email) Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using SendGrid.Helpers.Mail;

namespace MyFunctionApp.Bindings
{
    public class SendGridOutputExamples
    {
        private readonly ILogger<SendGridOutputExamples> _logger;

        public SendGridOutputExamples(ILogger<SendGridOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Send simple email
        [Function("SendSimpleEmail")]
        [SendGridOutput(ApiKey = "SendGridApiKey")]
        public SendGridMessage SendEmail(
            [QueueTrigger("email-queue")] EmailRequest emailRequest)
        {
            _logger.LogInformation($"Sending email to: {emailRequest.To}");
            
            var message = new SendGridMessage();
            message.AddTo(emailRequest.To);
            message.SetFrom(new EmailAddress("noreply@example.com", "Example App"));
            message.SetSubject(emailRequest.Subject);
            message.AddContent(MimeType.Html, emailRequest.Body);
            
            return message;
        }

        // Example 2: Send templated email
        [Function("SendTemplatedEmail")]
        [SendGridOutput(ApiKey = "SendGridApiKey")]
        public SendGridMessage SendTemplateEmail(
            [QueueTrigger("order-confirmation")] OrderConfirmation order)
        {
            _logger.LogInformation($"Sending order confirmation to: {order.CustomerEmail}");
            
            var message = new SendGridMessage();
            message.AddTo(order.CustomerEmail);
            message.SetFrom(new EmailAddress("orders@example.com", "Example Store"));
            
            // Use SendGrid template
            message.SetTemplateId("d-1234567890abcdef");
            message.SetTemplateData(new
            {
                order_id = order.OrderId,
                customer_name = order.CustomerName,
                order_total = order.Total.ToString("C"),
                order_items = order.Items,
                order_date = order.OrderDate.ToString("f")
            });
            
            return message;
        }

        // Example 3: Send email with attachment
        [Function("SendEmailWithAttachment")]
        [SendGridOutput(ApiKey = "SendGridApiKey")]
        public SendGridMessage SendWithAttachment(
            [QueueTrigger("invoice-email")] InvoiceEmailRequest request,
            [BlobInput("invoices/{queueTrigger}.pdf")] byte[] invoicePdf)
        {
            _logger.LogInformation($"Sending invoice email to: {request.CustomerEmail}");
            
            var message = new SendGridMessage();
            message.AddTo(request.CustomerEmail);
            message.SetFrom(new EmailAddress("billing@example.com", "Example Billing"));
            message.SetSubject($"Invoice {request.InvoiceNumber}");
            message.AddContent(MimeType.Html, 
                $"<p>Please find attached invoice {request.InvoiceNumber}</p>");
            
            // Add attachment
            message.AddAttachment(
                filename: $"Invoice_{request.InvoiceNumber}.pdf",
                content: Convert.ToBase64String(invoicePdf),
                type: "application/pdf",
                disposition: "attachment");
            
            return message;
        }

        // Example 4: Send to multiple recipients
        [Function("SendBulkEmail")]
        [SendGridOutput(ApiKey = "SendGridApiKey")]
        public List<SendGridMessage> SendBulkEmails(
            [TimerTrigger("0 0 9 * * MON")] TimerInfo timer,
            [BlobInput("reports/weekly-summary.html")] string reportHtml)
        {
            _logger.LogInformation("Sending weekly summary emails");
            
            var recipients = GetSubscribers(); // Get list of subscribers
            var messages = new List<SendGridMessage>();
            
            foreach (var recipient in recipients)
            {
                var message = new SendGridMessage();
                message.AddTo(recipient.Email);
                message.SetFrom(new EmailAddress("reports@example.com", "Weekly Reports"));
                message.SetSubject("Weekly Summary Report");
                
                // Personalize content
                var personalizedHtml = reportHtml.Replace("{{name}}", recipient.Name);
                message.AddContent(MimeType.Html, personalizedHtml);
                
                // Add unsubscribe group
                message.SetAsm(12345, new List<int> { 1 });
                
                messages.Add(message);
            }
            
            return messages;
        }

        private List<Subscriber> GetSubscribers()
        {
            // Fetch from database
            return new List<Subscriber>
            {
                new Subscriber { Email = "user1@example.com", Name = "User 1" },
                new Subscriber { Email = "user2@example.com", Name = "User 2" }
            };
        }
    }

    public class EmailRequest
    {
        public string To { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
    }

    public class OrderConfirmation
    {
        public string OrderId { get; set; }
        public string CustomerEmail { get; set; }
        public string CustomerName { get; set; }
        public decimal Total { get; set; }
        public List<string> Items { get; set; }
        public DateTime OrderDate { get; set; }
    }

    public class InvoiceEmailRequest
    {
        public string InvoiceNumber { get; set; }
        public string CustomerEmail { get; set; }
    }

    public class Subscriber
    {
        public string Email { get; set; }
        public string Name { get; set; }
    }
}
```

#### 8. SQL Output Binding

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.Bindings
{
    public class SqlOutputExamples
    {
        private readonly ILogger<SqlOutputExamples> _logger;

        public SqlOutputExamples(ILogger<SqlOutputExamples> logger)
        {
            _logger = logger;
        }

        // Example 1: Insert single record
        [Function("InsertProduct")]
        [SqlOutput("dbo.Products", connectionStringSetting: "SqlConnectionString")]
        public Product SaveProduct(
            [HttpTrigger(AuthorizationLevel.Function, "post")] ProductRequest request)
        {
            _logger.LogInformation($"Saving product: {request.Name}");
            
            return new Product
            {
                ProductId = 0, // Will be auto-generated
                ProductName = request.Name,
                CategoryId = request.CategoryId,
                Price = request.Price,
                IsActive = true,
                CreatedDate = DateTime.UtcNow
            };
        }

        // Example 2: Insert multiple records
        [Function("InsertMultipleProducts")]
        [SqlOutput("dbo.Products", connectionStringSetting: "SqlConnectionString")]
        public List<Product> SaveProducts(
            [BlobTrigger("import/{name}.json")] List<ProductImport> imports)
        {
            _logger.LogInformation($"Importing {imports.Count} products");
            
            return imports.Select(p => new Product
            {
                ProductName = p.Name,
                CategoryId = p.CategoryId,
                Price = p.Price,
                IsActive = true,
                CreatedDate = DateTime.UtcNow
            }).ToList();
        }

        // Example 3: Upsert (update if exists, insert if not)
        [Function("UpsertCustomer")]
        [SqlOutput("dbo.Customers", connectionStringSetting: "SqlConnectionString")]
        public Customer UpsertCustomer(
            [HttpTrigger(AuthorizationLevel.Function, "put")] CustomerData data)
        {
            _logger.LogInformation($"Upserting customer: {data.Email}");
            
            return new Customer
            {
                CustomerId = data.CustomerId,
                CustomerName = data.Name,
                Email = data.Email,
                PhoneNumber = data.Phone,
                LastModified = DateTime.UtcNow
            };
        }
    }

    public class ProductRequest
    {
        public string Name { get; set; }
        public string CategoryId { get; set; }
        public decimal Price { get; set; }
    }

    public class CustomerData
    {
        public int CustomerId { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
    }

    public class Customer
    {
        public int CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public DateTime LastModified { get; set; }
    }
}
```

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

## Durable Functions - Orchestration (C# Implementation)

### What are Durable Functions?

Durable Functions is an extension of Azure Functions that enables **stateful workflows** in a serverless environment. It allows you to:
- Chain function calls together
- Fan-out/fan-in patterns
- Long-running orchestrations
- Human interaction workflows
- Monitor patterns

### Key Concepts

```
┌───────────────────────────────────────────────────────────┐
│             DURABLE FUNCTIONS ARCHITECTURE                │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  Client Function (Starter)                                 │
│    └── Starts orchestration                              │
│                                                           │
│  Orchestrator Function                                    │
│    ├── Defines workflow logic                            │
│    ├── Calls activity functions                          │
│    ├── Maintains state automatically                     │
│    └── Can wait for external events                      │
│                                                           │
│  Activity Functions                                       │
│    └── Do the actual work (API calls, DB operations)     │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Installation

```xml
<!-- Add to .csproj -->
<PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.DurableTask" Version="1.1.0" />
```

### 1. Basic Orchestration - Function Chaining

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.DurableFunctions
{
    /// <summary>
    /// Function Chaining Pattern
    /// Use Case: Order Processing Pipeline
    /// </summary>
    public class OrderProcessingOrchestration
    {
        private readonly ILogger<OrderProcessingOrchestration> _logger;

        public OrderProcessingOrchestration(ILogger<OrderProcessingOrchestration> logger)
        {
            _logger = logger;
        }

        // === HTTP STARTER ===
        [Function(nameof(StartOrderProcessing))]
        public async Task<HttpResponseData> StartOrderProcessing(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req,
            [DurableClient] DurableTaskClient client)
        {
            _logger.LogInformation("Starting order processing orchestration");

            // Parse request
            var orderRequest = await req.ReadFromJsonAsync<OrderRequest>();
            
            // Start orchestration
            string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
                nameof(OrderProcessingOrchestrator),
                orderRequest);

            _logger.LogInformation($\"Started orchestration with ID = '{instanceId}'\");

            // Return management URLs
            return await client.CreateCheckStatusResponseAsync(req, instanceId);
        }

        // === ORCHESTRATOR ===
        [Function(nameof(OrderProcessingOrchestrator))]
        public async Task<OrderResult> OrderProcessingOrchestrator(
            [OrchestrationTrigger] TaskOrchestrationContext context)
        {
            var order = context.GetInput<OrderRequest>();
            var logger = context.CreateReplaySafeLogger<OrderProcessingOrchestration>();

            logger.LogInformation($\"Processing order {order.OrderId}\");

            try
            {
                // Step 1: Validate order
                logger.LogInformation(\"Step 1: Validating order\");
                var validationResult = await context.CallActivityAsync<ValidationResult>(
                    nameof(ValidateOrder),
                    order);

                if (!validationResult.IsValid)
                {
                    logger.LogWarning($\"Order validation failed: {validationResult.Message}\");
                    return new OrderResult
                    {
                        OrderId = order.OrderId,
                        Status = \"Validation Failed\",
                        Message = validationResult.Message
                    };
                }

                // Step 2: Reserve inventory
                logger.LogInformation(\"Step 2: Reserving inventory\");
                var inventoryResult = await context.CallActivityAsync<InventoryResult>(
                    nameof(ReserveInventory),
                    order);

                if (!inventoryResult.Success)
                {
                    logger.LogWarning(\"Insufficient inventory\");
                    return new OrderResult
                    {
                        OrderId = order.OrderId,
                        Status = \"Out of Stock\",
                        Message = \"Insufficient inventory\"
                    };
                }

                // Step 3: Process payment
                logger.LogInformation(\"Step 3: Processing payment\");
                var paymentResult = await context.CallActivityAsync<PaymentResult>(
                    nameof(ProcessPayment),
                    new PaymentRequest
                    {
                        OrderId = order.OrderId,
                        Amount = order.TotalAmount,
                        PaymentMethod = order.PaymentMethod
                    });

                if (!paymentResult.Success)
                {
                    // Rollback inventory
                    logger.LogWarning(\"Payment failed - rolling back inventory\");
                    await context.CallActivityAsync(
                        nameof(ReleaseInventory),
                        inventoryResult.ReservationId);

                    return new OrderResult
                    {
                        OrderId = order.OrderId,
                        Status = \"Payment Failed\",
                        Message = paymentResult.Message
                    };
                }

                // Step 4: Create shipment
                logger.LogInformation(\"Step 4: Creating shipment\");
                var shipmentResult = await context.CallActivityAsync<ShipmentResult>(
                    nameof(CreateShipment),
                    new ShipmentRequest
                    {
                        OrderId = order.OrderId,
                        Items = order.Items,
                        ShippingAddress = order.ShippingAddress
                    });

                // Step 5: Send confirmation email
                logger.LogInformation(\"Step 5: Sending confirmation email\");
                await context.CallActivityAsync(
                    nameof(SendConfirmationEmail),
                    new EmailRequest
                    {
                        To = order.CustomerEmail,
                        OrderId = order.OrderId,
                        TrackingNumber = shipmentResult.TrackingNumber
                    });

                logger.LogInformation($\"Order {order.OrderId} processed successfully\");

                return new OrderResult
                {
                    OrderId = order.OrderId,
                    Status = \"Completed\",
                    TransactionId = paymentResult.TransactionId,
                    TrackingNumber = shipmentResult.TrackingNumber,
                    Message = \"Order processed successfully\"
                };
            }
            catch (Exception ex)
            {
                logger.LogError($\"Error processing order: {ex.Message}\");
                
                return new OrderResult
                {
                    OrderId = order.OrderId,
                    Status = \"Failed\",
                    Message = $\"Error: {ex.Message}\"
                };
            }
        }

        // === ACTIVITY FUNCTIONS ===

        [Function(nameof(ValidateOrder))]
        public ValidationResult ValidateOrder([ActivityTrigger] OrderRequest order)
        {
            _logger.LogInformation($\"Validating order {order.OrderId}\");

            // Validation logic
            if (string.IsNullOrEmpty(order.CustomerEmail))
            {
                return new ValidationResult
                {
                    IsValid = false,
                    Message = \"Customer email is required\"
                };
            }

            if (order.Items == null || !order.Items.Any())
            {
                return new ValidationResult
                {
                    IsValid = false,
                    Message = \"Order must contain at least one item\"
                };
            }

            if (order.TotalAmount <= 0)
            {
                return new ValidationResult
                {
                    IsValid = false,
                    Message = \"Invalid order amount\"
                };
            }

            return new ValidationResult { IsValid = true, Message = \"Valid\" };
        }

        [Function(nameof(ReserveInventory))]
        public async Task<InventoryResult> ReserveInventory([ActivityTrigger] OrderRequest order)
        {
            _logger.LogInformation($\"Reserving inventory for order {order.OrderId}\");

            // Simulate inventory check
            await Task.Delay(500);

            // In real implementation, call inventory service
            var reservationId = Guid.NewGuid().ToString();

            return new InventoryResult
            {
                Success = true,
                ReservationId = reservationId
            };
        }

        [Function(nameof(ProcessPayment))]
        public async Task<PaymentResult> ProcessPayment([ActivityTrigger] PaymentRequest payment)
        {
            _logger.LogInformation($\"Processing payment for order {payment.OrderId}\");

            // Simulate payment processing
            await Task.Delay(1000);

            // In real implementation, call payment gateway
            var transactionId = Guid.NewGuid().ToString();

            return new PaymentResult
            {
                Success = true,
                TransactionId = transactionId,
                Message = \"Payment processed successfully\"
            };
        }

        [Function(nameof(CreateShipment))]
        public async Task<ShipmentResult> CreateShipment([ActivityTrigger] ShipmentRequest shipment)
        {
            _logger.LogInformation($\"Creating shipment for order {shipment.OrderId}\");

            // Simulate shipment creation
            await Task.Delay(800);

            var trackingNumber = $\"TRACK-{DateTime.UtcNow.Ticks}\";

            return new ShipmentResult
            {
                Success = true,
                TrackingNumber = trackingNumber
            };
        }

        [Function(nameof(SendConfirmationEmail))]
        public async Task SendConfirmationEmail([ActivityTrigger] EmailRequest email)
        {
            _logger.LogInformation($\"Sending confirmation email to {email.To}\");

            // Simulate email sending
            await Task.Delay(300);

            // In real implementation, use SendGrid or similar
        }

        [Function(nameof(ReleaseInventory))]
        public async Task ReleaseInventory([ActivityTrigger] string reservationId)
        {
            _logger.LogInformation($\"Releasing inventory reservation {reservationId}\");
            await Task.Delay(200);
        }
    }

    // Models
    public class OrderRequest
    {
        public string OrderId { get; set; }
        public string CustomerEmail { get; set; }
        public List<OrderItemRequest> Items { get; set; }
        public decimal TotalAmount { get; set; }
        public string PaymentMethod { get; set; }
        public string ShippingAddress { get; set; }
    }

    public class OrderItemRequest
    {
        public string ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }

    public class ValidationResult
    {
        public bool IsValid { get; set; }
        public string Message { get; set; }
    }

    public class InventoryResult
    {
        public bool Success { get; set; }
        public string ReservationId { get; set; }
    }

    public class PaymentRequest
    {
        public string OrderId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; }
    }

    public class PaymentResult
    {
        public bool Success { get; set; }
        public string TransactionId { get; set; }
        public string Message { get; set; }
    }

    public class ShipmentRequest
    {
        public string OrderId { get; set; }
        public List<OrderItemRequest> Items { get; set; }
        public string ShippingAddress { get; set; }
    }

    public class ShipmentResult
    {
        public bool Success { get; set; }
        public string TrackingNumber { get; set; }
    }

    public class EmailRequest
    {
        public string To { get; set; }
        public string OrderId { get; set; }
        public string TrackingNumber { get; set; }
    }

    public class OrderResult
    {
        public string OrderId { get; set; }
        public string Status { get; set; }
        public string TransactionId { get; set; }
        public string TrackingNumber { get; set; }
        public string Message { get; set; }
    }
}
```

### 2. Fan-Out/Fan-In Pattern

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.DurableFunctions
{
    /// <summary>
    /// Fan-Out/Fan-In Pattern
    /// Use Case: Process multiple tasks in parallel, then aggregate results
    /// Example: Generate reports from multiple data sources
    /// </summary>
    public class ReportGenerationOrchestration
    {
        private readonly ILogger<ReportGenerationOrchestration> _logger;

        public ReportGenerationOrchestration(ILogger<ReportGenerationOrchestration> logger)
        {
            _logger = logger;
        }

        [Function(nameof(StartReportGeneration))]
        public async Task<HttpResponseData> StartReportGeneration(
            [HttpTrigger(AuthorizationLevel.Function, \"post\")] HttpRequestData req,
            [DurableClient] DurableTaskClient client)
        {
            var reportRequest = await req.ReadFromJsonAsync<ReportRequest>();

            string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
                nameof(GenerateMonthlyReportOrchestrator),
                reportRequest);

            return await client.CreateCheckStatusResponseAsync(req, instanceId);
        }

        [Function(nameof(GenerateMonthlyReportOrchestrator))]
        public async Task<MonthlyReport> GenerateMonthlyReportOrchestrator(
            [OrchestrationTrigger] TaskOrchestrationContext context)
        {
            var request = context.GetInput<ReportRequest>();
            var logger = context.CreateReplaySafeLogger<ReportGenerationOrchestration>();

            logger.LogInformation($\"Generating monthly report for {request.Year}-{request.Month:00}\");

            // Fan-out: Start multiple tasks in parallel
            var tasks = new List<Task<ReportSection>>();

            // Task 1: Sales data
            tasks.Add(context.CallActivityAsync<ReportSection>(
                nameof(GetSalesData),
                new DateRange { Year = request.Year, Month = request.Month }));

            // Task 2: Customer data
            tasks.Add(context.CallActivityAsync<ReportSection>(
                nameof(GetCustomerData),
                new DateRange { Year = request.Year, Month = request.Month }));

            // Task 3: Inventory data
            tasks.Add(context.CallActivityAsync<ReportSection>(
                nameof(GetInventoryData),
                new DateRange { Year = request.Year, Month = request.Month }));

            // Task 4: Financial data
            tasks.Add(context.CallActivityAsync<ReportSection>(
                nameof(GetFinancialData),
                new DateRange { Year = request.Year, Month = request.Month }));

            // Task 5: Marketing data
            tasks.Add(context.CallActivityAsync<ReportSection>(
                nameof(GetMarketingData),
                new DateRange { Year = request.Year, Month = request.Month }));

            // Fan-in: Wait for all tasks to complete
            logger.LogInformation(\"Waiting for all report sections to complete...\");
            var results = await Task.WhenAll(tasks);

            // Aggregate results
            var report = new MonthlyReport
            {
                ReportId = Guid.NewGuid().ToString(),
                Year = request.Year,
                Month = request.Month,
                GeneratedDate = DateTime.UtcNow,
                Sections = results.ToList(),
                Summary = CreateSummary(results)
            };

            // Generate PDF
            logger.LogInformation(\"Generating PDF report\");
            var pdfUrl = await context.CallActivityAsync<string>(
                nameof(GeneratePdfReport),
                report);

            report.PdfUrl = pdfUrl;

            // Send notification
            await context.CallActivityAsync(
                nameof(SendReportNotification),
                new ReportNotification
                {
                    ReportUrl = pdfUrl,
                    Recipients = request.Recipients
                });

            logger.LogInformation(\"Monthly report generation completed\");
            return report;
        }

        // Activity Functions
        [Function(nameof(GetSalesData))]
        public async Task<ReportSection> GetSalesData([ActivityTrigger] DateRange dateRange)
        {
            _logger.LogInformation($\"Fetching sales data for {dateRange.Year}-{dateRange.Month:00}\");
            
            // Simulate data fetching
            await Task.Delay(2000);

            return new ReportSection
            {
                SectionName = \"Sales\",
                Data = new Dictionary<string, object>
                {
                    { \"TotalSales\", 125000.00m },
                    { \"OrderCount\", 450 },
                    { \"AverageOrderValue\", 277.78m }
                }
            };
        }

        [Function(nameof(GetCustomerData))]
        public async Task<ReportSection> GetCustomerData([ActivityTrigger] DateRange dateRange)
        {
            _logger.LogInformation($\"Fetching customer data for {dateRange.Year}-{dateRange.Month:00}\");
            await Task.Delay(1500);

            return new ReportSection
            {
                SectionName = \"Customers\",
                Data = new Dictionary<string, object>
                {
                    { \"NewCustomers\", 85 },
                    { \"ReturnCustomers\", 320 },
                    { \"ChurnRate\", 2.5 }
                }
            };
        }

        [Function(nameof(GetInventoryData))]
        public async Task<ReportSection> GetInventoryData([ActivityTrigger] DateRange dateRange)
        {
            _logger.LogInformation($\"Fetching inventory data for {dateRange.Year}-{dateRange.Month:00}\");
            await Task.Delay(1800);

            return new ReportSection
            {
                SectionName = \"Inventory\",
                Data = new Dictionary<string, object>
                {
                    { \"TotalProducts\", 1250 },
                    { \"LowStockItems\", 45 },
                    { \"OutOfStockItems\", 8 }
                }
            };
        }

        [Function(nameof(GetFinancialData))]
        public async Task<ReportSection> GetFinancialData([ActivityTrigger] DateRange dateRange)
        {
            _logger.LogInformation($\"Fetching financial data for {dateRange.Year}-{dateRange.Month:00}\");
            await Task.Delay(2200);

            return new ReportSection
            {
                SectionName = \"Financial\",
                Data = new Dictionary<string, object>
                {
                    { \"Revenue\", 125000.00m },
                    { \"Expenses\", 78000.00m },
                    { \"NetProfit\", 47000.00m }
                }
            };
        }

        [Function(nameof(GetMarketingData))]
        public async Task<ReportSection> GetMarketingData([ActivityTrigger] DateRange dateRange)
        {
            _logger.LogInformation($\"Fetching marketing data for {dateRange.Year}-{dateRange.Month:00}\");
            await Task.Delay(1600);

            return new ReportSection
            {
                SectionName = \"Marketing\",
                Data = new Dictionary<string, object>
                {
                    { \"CampaignsSent\", 12 },
                    { \"EmailOpenRate\", 23.5 },
                    { \"ConversionRate\", 4.2 }
                }
            };
        }

        [Function(nameof(GeneratePdfReport))]
        public async Task<string> GeneratePdfReport([ActivityTrigger] MonthlyReport report)
        {
            _logger.LogInformation($\"Generating PDF for report {report.ReportId}\");
            
            // Simulate PDF generation
            await Task.Delay(3000);

            // Upload to blob storage and return URL
            var url = $\"https://storage.example.com/reports/{report.ReportId}.pdf\";
            return url;
        }

        [Function(nameof(SendReportNotification))]
        public async Task SendReportNotification([ActivityTrigger] ReportNotification notification)
        {
            _logger.LogInformation($\"Sending report notification to {notification.Recipients.Count} recipients\");
            await Task.Delay(500);
        }

        private string CreateSummary(ReportSection[] sections)
        {
            return $\"Report generated with {sections.Length} sections\";
        }
    }

    // Models
    public class ReportRequest
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public List<string> Recipients { get; set; }
    }

    public class DateRange
    {
        public int Year { get; set; }
        public int Month { get; set; }
    }

    public class ReportSection
    {
        public string SectionName { get; set; }
        public Dictionary<string, object> Data { get; set; }
    }

    public class MonthlyReport
    {
        public string ReportId { get; set; }
        public int Year { get; set; }
        public int Month { get; set; }
        public DateTime GeneratedDate { get; set; }
        public List<ReportSection> Sections { get; set; }
        public string Summary { get; set; }
        public string PdfUrl { get; set; }
    }

    public class ReportNotification
    {
        public string ReportUrl { get; set; }
        public List<string> Recipients { get; set; }
    }
}
```

### 3. Human Interaction Pattern (Approval Workflow)

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.DurableFunctions
{
    /// <summary>
    /// Human Interaction Pattern
    /// Use Case: Approval workflow with timeout
    /// Example: Expense approval system
    /// </summary>
    public class ApprovalWorkflowOrchestration
    {
        private readonly ILogger<ApprovalWorkflowOrchestration> _logger;

        public ApprovalWorkflowOrchestration(ILogger<ApprovalWorkflowOrchestration> logger)
        {
            _logger = logger;
        }

        [Function(nameof(StartApprovalWorkflow))]
        public async Task<HttpResponseData> StartApprovalWorkflow(
            [HttpTrigger(AuthorizationLevel.Function, \"post\")] HttpRequestData req,
            [DurableClient] DurableTaskClient client)
        {
            var expenseRequest = await req.ReadFromJsonAsync<ExpenseRequest>();

            string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
                nameof(ExpenseApprovalOrchestrator),
                expenseRequest);

            _logger.LogInformation($\"Started expense approval workflow: {instanceId}\");

            return await client.CreateCheckStatusResponseAsync(req, instanceId);
        }

        [Function(nameof(ApproveExpense))]
        public async Task<HttpResponseData> ApproveExpense(
            [HttpTrigger(AuthorizationLevel.Function, \"post\", Route = \"approval/{instanceId}/approve\")] 
            HttpRequestData req,
            [DurableClient] DurableTaskClient client,
            string instanceId)
        {
            _logger.LogInformation($\"Approving expense: {instanceId}\");

            // Raise approval event
            await client.RaiseEventAsync(instanceId, \"ApprovalEvent\", new ApprovalResponse
            {
                Approved = true,
                ApproverEmail = \"manager@company.com\",
                ApprovedDate = DateTime.UtcNow,
                Comments = \"Approved\"
            });

            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            await response.WriteStringAsync(\"Expense approved\");
            return response;
        }

        [Function(nameof(RejectExpense))]
        public async Task<HttpResponseData> RejectExpense(
            [HttpTrigger(AuthorizationLevel.Function, \"post\", Route = \"approval/{instanceId}/reject\")] 
            HttpRequestData req,
            [DurableClient] DurableTaskClient client,
            string instanceId)
        {
            _logger.LogInformation($\"Rejecting expense: {instanceId}\");

            var body = await req.ReadFromJsonAsync<RejectionRequest>();

            await client.RaiseEventAsync(instanceId, \"ApprovalEvent\", new ApprovalResponse
            {
                Approved = false,
                ApproverEmail = \"manager@company.com\",
                ApprovedDate = DateTime.UtcNow,
                Comments = body.Reason
            });

            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            await response.WriteStringAsync(\"Expense rejected\");
            return response;
        }

        [Function(nameof(ExpenseApprovalOrchestrator))]
        public async Task<ExpenseResult> ExpenseApprovalOrchestrator(
            [OrchestrationTrigger] TaskOrchestrationContext context)
        {
            var expense = context.GetInput<ExpenseRequest>();
            var logger = context.CreateReplaySafeLogger<ApprovalWorkflowOrchestration>();

            logger.LogInformation($\"Processing expense request: {expense.RequestId}\");

            try
            {
                // Step 1: Validate expense
                var validation = await context.CallActivityAsync<ValidationResult>(
                    nameof(ValidateExpense),
                    expense);

                if (!validation.IsValid)
                {
                    return new ExpenseResult
                    {
                        RequestId = expense.RequestId,
                        Status = \"Rejected\",
                        Reason = validation.Message
                    };
                }

                // Step 2: Check if auto-approval is possible (< $500)
                if (expense.Amount < 500)
                {
                    logger.LogInformation(\"Auto-approving expense under $500\");
                    
                    await context.CallActivityAsync(
                        nameof(ProcessExpensePayment),
                        expense);

                    return new ExpenseResult
                    {
                        RequestId = expense.RequestId,
                        Status = \"Auto-Approved\",
                        ApprovedAmount = expense.Amount
                    };
                }

                // Step 3: Send approval request to manager
                logger.LogInformation(\"Sending approval request to manager\");
                
                await context.CallActivityAsync(
                    nameof(SendApprovalRequest),
                    new ApprovalEmail
                    {
                        RequestId = expense.RequestId,
                        EmployeeName = expense.EmployeeName,
                        Amount = expense.Amount,
                        Description = expense.Description,
                        ApprovalUrl = $\"https://portal.company.com/approval/{context.InstanceId}\"
                    });

                // Step 4: Wait for approval event with timeout (48 hours)
                using var timeoutCts = new CancellationTokenSource();
                var approvalTask = context.WaitForExternalEvent<ApprovalResponse>(\"ApprovalEvent\");
                var timeoutTask = context.CreateTimer(
                    context.CurrentUtcDateTime.AddHours(48),
                    timeoutCts.Token);

                var winner = await Task.WhenAny(approvalTask, timeoutTask);

                if (winner == approvalTask)
                {
                    // Approval received
                    timeoutCts.Cancel();
                    var approvalResponse = await approvalTask;

                    if (approvalResponse.Approved)
                    {
                        logger.LogInformation(\"Expense approved by manager\");

                        await context.CallActivityAsync(
                            nameof(ProcessExpensePayment),
                            expense);

                        await context.CallActivityAsync(
                            nameof(SendApprovalNotification),
                            new NotificationRequest
                            {
                                To = expense.EmployeeEmail,
                                Subject = \"Expense Approved\",
                                Message = $\"Your expense request #{expense.RequestId} has been approved.\"
                            });

                        return new ExpenseResult
                        {
                            RequestId = expense.RequestId,
                            Status = \"Approved\",
                            ApprovedAmount = expense.Amount,
                            ApproverEmail = approvalResponse.ApproverEmail,
                            ApprovedDate = approvalResponse.ApprovedDate
                        };
                    }
                    else
                    {
                        logger.LogInformation(\"Expense rejected by manager\");

                        await context.CallActivityAsync(
                            nameof(SendApprovalNotification),
                            new NotificationRequest
                            {
                                To = expense.EmployeeEmail,
                                Subject = \"Expense Rejected\",
                                Message = $\"Your expense request #{expense.RequestId} has been rejected. Reason: {approvalResponse.Comments}\"
                            });

                        return new ExpenseResult
                        {
                            RequestId = expense.RequestId,
                            Status = \"Rejected\",
                            Reason = approvalResponse.Comments
                        };
                    }
                }
                else
                {
                    // Timeout - escalate to senior manager
                    logger.LogWarning(\"Approval timeout - escalating\");

                    await context.CallActivityAsync(
                        nameof(EscalateApproval),
                        expense);

                    return new ExpenseResult
                    {
                        RequestId = expense.RequestId,
                        Status = \"Escalated\",
                        Reason = \"No response within 48 hours - escalated to senior management\"
                    };
                }
            }
            catch (Exception ex)
            {
                logger.LogError($\"Error in expense approval: {ex.Message}\");
                throw;
            }
        }

        // Activity Functions
        [Function(nameof(ValidateExpense))]
        public ValidationResult ValidateExpense([ActivityTrigger] ExpenseRequest expense)
        {
            if (expense.Amount <= 0)
                return new ValidationResult { IsValid = false, Message = \"Invalid amount\" };

            if (string.IsNullOrEmpty(expense.Description))
                return new ValidationResult { IsValid = false, Message = \"Description required\" };

            if (expense.Amount > 10000)
                return new ValidationResult { IsValid = false, Message = \"Amount exceeds maximum limit\" };

            return new ValidationResult { IsValid = true };
        }

        [Function(nameof(SendApprovalRequest))]
        public async Task SendApprovalRequest([ActivityTrigger] ApprovalEmail email)
        {
            _logger.LogInformation($\"Sending approval request for {email.RequestId}\");
            // Send email logic here
            await Task.Delay(500);
        }

        [Function(nameof(ProcessExpensePayment))]
        public async Task ProcessExpensePayment([ActivityTrigger] ExpenseRequest expense)
        {
            _logger.LogInformation($\"Processing payment for expense {expense.RequestId}\");
            // Payment processing logic
            await Task.Delay(1000);
        }

        [Function(nameof(SendApprovalNotification))]
        public async Task SendApprovalNotification([ActivityTrigger] NotificationRequest notification)
        {
            _logger.LogInformation($\"Sending notification to {notification.To}\");
            await Task.Delay(300);
        }

        [Function(nameof(EscalateApproval))]
        public async Task EscalateApproval([ActivityTrigger] ExpenseRequest expense)
        {
            _logger.LogInformation($\"Escalating expense {expense.RequestId} to senior management\");
            // Escalation logic
            await Task.Delay(500);
        }
    }

    // Models
    public class ExpenseRequest
    {
        public string RequestId { get; set; }
        public string EmployeeName { get; set; }
        public string EmployeeEmail { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public string Category { get; set; }
        public DateTime RequestDate { get; set; }
    }

    public class ApprovalEmail
    {
        public string RequestId { get; set; }
        public string EmployeeName { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public string ApprovalUrl { get; set; }
    }

    public class ApprovalResponse
    {
        public bool Approved { get; set; }
        public string ApproverEmail { get; set; }
        public DateTime ApprovedDate { get; set; }
        public string Comments { get; set; }
    }

    public class RejectionRequest
    {
        public string Reason { get; set; }
    }

    public class ExpenseResult
    {
        public string RequestId { get; set; }
        public string Status { get; set; }
        public decimal? ApprovedAmount { get; set; }
        public string ApproverEmail { get; set; }
        public DateTime? ApprovedDate { get; set; }
        public string Reason { get; set; }
    }

    public class NotificationRequest
    {
        public string To { get; set; }
        public string Subject { get; set; }
        public string Message { get; set; }
    }
}
```

### 4. Monitor Pattern (Long-Running Status Check)

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.DurableFunctions
{
    /// <summary>
    /// Monitor Pattern
    /// Use Case: Poll external system until condition is met
    /// Example: Monitor deployment status
    /// </summary>
    public class DeploymentMonitorOrchestration
    {
        private readonly ILogger<DeploymentMonitorOrchestration> _logger;

        public DeploymentMonitorOrchestration(ILogger<DeploymentMonitorOrchestration> logger)
        {
            _logger = logger;
        }

        [Function(nameof(StartDeploymentMonitor))]
        public async Task<HttpResponseData> StartDeploymentMonitor(
            [HttpTrigger(AuthorizationLevel.Function, \"post\")] HttpRequestData req,
            [DurableClient] DurableTaskClient client)
        {
            var deploymentRequest = await req.ReadFromJsonAsync<DeploymentRequest>();

            string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
                nameof(MonitorDeploymentOrchestrator),
                deploymentRequest);

            return await client.CreateCheckStatusResponseAsync(req, instanceId);
        }

        [Function(nameof(MonitorDeploymentOrchestrator))]
        public async Task<DeploymentResult> MonitorDeploymentOrchestrator(
            [OrchestrationTrigger] TaskOrchestrationContext context)
        {
            var deployment = context.GetInput<DeploymentRequest>();
            var logger = context.CreateReplaySafeLogger<DeploymentMonitorOrchestration>();

            logger.LogInformation($\"Monitoring deployment: {deployment.DeploymentId}\");

            var expiryTime = context.CurrentUtcDateTime.AddHours(2); // 2 hour timeout
            var pollingInterval = TimeSpan.FromSeconds(30); // Check every 30 seconds

            while (context.CurrentUtcDateTime < expiryTime)
            {
                // Check deployment status
                var status = await context.CallActivityAsync<DeploymentStatus>(
                    nameof(CheckDeploymentStatus),
                    deployment.DeploymentId);

                logger.LogInformation($\"Deployment status: {status.State}\");

                if (status.State == \"Succeeded\")
                {
                    // Deployment successful
                    await context.CallActivityAsync(
                        nameof(SendDeploymentNotification),
                        new DeploymentNotification
                        {
                            DeploymentId = deployment.DeploymentId,
                            Status = \"Success\",
                            Message = \"Deployment completed successfully\"
                        });

                    return new DeploymentResult
                    {
                        DeploymentId = deployment.DeploymentId,
                        Status = \"Succeeded\",
                        CompletedAt = context.CurrentUtcDateTime,
                        Duration = context.CurrentUtcDateTime - deployment.StartedAt
                    };
                }
                else if (status.State == \"Failed\")
                {
                    // Deployment failed
                    await context.CallActivityAsync(
                        nameof(SendDeploymentNotification),
                        new DeploymentNotification
                        {
                            DeploymentId = deployment.DeploymentId,
                            Status = \"Failed\",
                            Message = $\"Deployment failed: {status.ErrorMessage}\"
                        });

                    return new DeploymentResult
                    {
                        DeploymentId = deployment.DeploymentId,
                        Status = \"Failed\",
                        ErrorMessage = status.ErrorMessage,
                        CompletedAt = context.CurrentUtcDateTime
                    };
                }

                // Still in progress - wait before checking again
                var nextCheck = context.CurrentUtcDateTime.Add(pollingInterval);
                await context.CreateTimer(nextCheck, CancellationToken.None);
            }

            // Timeout reached
            logger.LogWarning($\"Deployment monitoring timeout: {deployment.DeploymentId}\");

            await context.CallActivityAsync(
                nameof(SendDeploymentNotification),
                new DeploymentNotification
                {
                    DeploymentId = deployment.DeploymentId,
                    Status = \"Timeout\",
                    Message = \"Deployment monitoring timeout - manual check required\"
                });

            return new DeploymentResult
            {
                DeploymentId = deployment.DeploymentId,
                Status = \"Timeout\",
                ErrorMessage = \"Deployment monitoring timeout after 2 hours\"
            };
        }

        [Function(nameof(CheckDeploymentStatus))]
        public async Task<DeploymentStatus> CheckDeploymentStatus([ActivityTrigger] string deploymentId)
        {
            _logger.LogInformation($\"Checking deployment status: {deploymentId}\");

            // Simulate API call to deployment service
            await Task.Delay(500);

            // In real implementation, call Azure DevOps, GitHub Actions, etc.
            var random = new Random();
            var progress = random.Next(0, 100);

            if (progress > 90)
            {
                return new DeploymentStatus { State = \"Succeeded\", Progress = 100 };
            }
            else if (progress < 10)
            {
                return new DeploymentStatus 
                { 
                    State = \"Failed\", 
                    ErrorMessage = \"Build failed - syntax error in code\" 
                };
            }
            else
            {
                return new DeploymentStatus { State = \"InProgress\", Progress = progress };
            }
        }

        [Function(nameof(SendDeploymentNotification))]
        public async Task SendDeploymentNotification([ActivityTrigger] DeploymentNotification notification)
        {
            _logger.LogInformation($\"Sending deployment notification: {notification.Status}\");
            await Task.Delay(300);
        }
    }

    // Models
    public class DeploymentRequest
    {
        public string DeploymentId { get; set; }
        public string Environment { get; set; }
        public DateTime StartedAt { get; set; }
    }

    public class DeploymentStatus
    {
        public string State { get; set; } // InProgress, Succeeded, Failed
        public int Progress { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class DeploymentNotification
    {
        public string DeploymentId { get; set; }
        public string Status { get; set; }
        public string Message { get; set; }
    }

    public class DeploymentResult
    {
        public string DeploymentId { get; set; }
        public string Status { get; set; }
        public string ErrorMessage { get; set; }
        public DateTime? CompletedAt { get; set; }
        public TimeSpan? Duration { get; set; }
    }
}
```

---

## Testing Strategies (C# Implementation)

### 1. Unit Testing Azure Functions

```csharp
// Install packages:
// Microsoft.Azure.Functions.Worker
// Microsoft.Extensions.Logging
// Moq
// xUnit

using Xunit;
using Moq;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Net;
using System.Text;
using System.Text.Json;

namespace MyFunctionApp.Tests
{
    public class HttpTriggerFunctionTests
    {
        private readonly Mock<ILogger<HttpTriggerFunction>> _loggerMock;
        private readonly Mock<IOrderService> _orderServiceMock;
        private readonly HttpTriggerFunction _function;

        public HttpTriggerFunctionTests()
        {
            _loggerMock = new Mock<ILogger<HttpTriggerFunction>>();
            _orderServiceMock = new Mock<IOrderService>();
            _function = new HttpTriggerFunction(_loggerMock.Object, _orderServiceMock.Object);
        }

        [Fact]
        public async Task GetOrder_ValidId_ReturnsOrder()
        {
            // Arrange
            var orderId = \"12345\";
            var expectedOrder = new Order
            {
                Id = orderId,
                OrderNumber = \"ORD-001\",
                TotalAmount = 100.00m
            };

            _orderServiceMock
                .Setup(s => s.GetOrderAsync(orderId))
                .ReturnsAsync(expectedOrder);

            var context = CreateMockFunctionContext();
            var request = CreateMockHttpRequest(\"GET\", $\"/api/orders/{orderId}\");

            // Act
            var response = await _function.GetOrder(request, orderId, context);

            // Assert
            Assert.NotNull(response);
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            
            // Verify service was called
            _orderServiceMock.Verify(s => s.GetOrderAsync(orderId), Times.Once);
        }

        [Fact]
        public async Task GetOrder_InvalidId_ReturnsNotFound()
        {
            // Arrange
            var orderId = \"invalid\";

            _orderServiceMock
                .Setup(s => s.GetOrderAsync(orderId))
                .ReturnsAsync((Order)null);

            var context = CreateMockFunctionContext();
            var request = CreateMockHttpRequest(\"GET\", $\"/api/orders/{orderId}\");

            // Act
            var response = await _function.GetOrder(request, orderId, context);

            // Assert
            Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        }

        [Fact]
        public async Task CreateOrder_ValidRequest_ReturnsCreated()
        {
            // Arrange
            var orderRequest = new OrderRequest
            {
                CustomerEmail = \"test@example.com\",
                Items = new List<OrderItemRequest>
                {
                    new OrderItemRequest { ProductId = \"P1\", Quantity = 2, Price = 50.00m }
                },
                TotalAmount = 100.00m
            };

            var createdOrder = new Order
            {
                Id = Guid.NewGuid().ToString(),
                OrderNumber = \"ORD-001\",
                CustomerEmail = orderRequest.CustomerEmail,
                TotalAmount = orderRequest.TotalAmount,
                Status = \"Pending\"
            };

            _orderServiceMock
                .Setup(s => s.CreateOrderAsync(It.IsAny<OrderRequest>()))
                .ReturnsAsync(createdOrder);

            var context = CreateMockFunctionContext();
            var request = CreateMockHttpRequest(\"POST\", \"/api/orders\", orderRequest);

            // Act
            var response = await _function.CreateOrder(request, context);

            // Assert
            Assert.Equal(HttpStatusCode.Created, response.StatusCode);
            _orderServiceMock.Verify(s => s.CreateOrderAsync(It.IsAny<OrderRequest>()), Times.Once);
        }

        [Fact]
        public async Task CreateOrder_InvalidRequest_ReturnsBadRequest()
        {
            // Arrange
            var orderRequest = new OrderRequest
            {
                CustomerEmail = \"\", // Invalid - empty email
                Items = new List<OrderItemRequest>(),
                TotalAmount = 100.00m
            };

            var context = CreateMockFunctionContext();
            var request = CreateMockHttpRequest(\"POST\", \"/api/orders\", orderRequest);

            // Act
            var response = await _function.CreateOrder(request, context);

            // Assert
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
            _orderServiceMock.Verify(s => s.CreateOrderAsync(It.IsAny<OrderRequest>()), Times.Never);
        }

        // Helper methods
        private FunctionContext CreateMockFunctionContext()
        {
            var context = new Mock<FunctionContext>();
            var serviceProvider = new Mock<IServiceProvider>();
            
            context.SetupProperty(c => c.InstanceServices, serviceProvider.Object);
            
            return context.Object;
        }

        private HttpRequestData CreateMockHttpRequest(string method, string url, object body = null)
        {
            var context = CreateMockFunctionContext();
            var request = new Mock<HttpRequestData>(context);

            request.Setup(r => r.Method).Returns(method);
            request.Setup(r => r.Url).Returns(new Uri($\"https://localhost{url}\"));
            request.Setup(r => r.CreateResponse()).Returns(() =>
            {
                var response = new Mock<HttpResponseData>(context);
                response.SetupProperty(r => r.StatusCode);
                response.SetupProperty(r => r.Headers, new HttpHeadersCollection());
                response.SetupProperty(r => r.Body, new MemoryStream());
                return response.Object;
            });

            if (body != null)
            {
                var json = JsonSerializer.Serialize(body);
                var stream = new MemoryStream(Encoding.UTF8.GetBytes(json));
                request.Setup(r => r.Body).Returns(stream);
            }

            return request.Object;
        }
    }

    // Additional Test Class for Timer Functions
    public class TimerTriggerFunctionTests
    {
        private readonly Mock<ILogger<DailyReportFunction>> _loggerMock;
        private readonly Mock<IReportService> _reportServiceMock;
        private readonly DailyReportFunction _function;

        public TimerTriggerFunctionTests()
        {
            _loggerMock = new Mock<ILogger<DailyReportFunction>>();
            _reportServiceMock = new Mock<IReportService>();
            _function = new DailyReportFunction(_loggerMock.Object, _reportServiceMock.Object);
        }

        [Fact]
        public async Task GenerateDailyReport_CallsReportService()
        {
            // Arrange
            var timerInfo = new TimerInfo
            {
                ScheduleStatus = new ScheduleStatus
                {
                    Last = DateTime.UtcNow.AddDays(-1),
                    Next = DateTime.UtcNow.AddDays(1)
                }
            };

            _reportServiceMock
                .Setup(s => s.GenerateDailyReportAsync())
                .ReturnsAsync(true);

            // Act
            await _function.Run(timerInfo);

            // Assert
            _reportServiceMock.Verify(s => s.GenerateDailyReportAsync(), Times.Once);
        }
    }

    // Test models
    public class TimerInfo
    {
        public ScheduleStatus ScheduleStatus { get; set; }
        public bool IsPastDue { get; set; }
    }

    public class ScheduleStatus
    {
        public DateTime Last { get; set; }
        public DateTime Next { get; set; }
    }
}
```

### 2. Integration Testing

```csharp
using Xunit;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Azure.Storage.Queues;
using Azure.Storage.Blobs;
using System.Net.Http;
using System.Text;
using System.Text.Json;

namespace MyFunctionApp.IntegrationTests
{
    /// <summary>
    /// Integration tests using TestServer or actual Azure resources
    /// </summary>
    public class FunctionIntegrationTests : IAsyncLifetime
    {
        private readonly string _storageConnectionString;
        private readonly QueueClient _queueClient;
        private readonly BlobContainerClient _containerClient;
        private readonly HttpClient _httpClient;

        public FunctionIntegrationTests()
        {
            // Use Azurite for local testing or actual Azure Storage
            _storageConnectionString = \"UseDevelopmentStorage=true\"; // Azurite
            
            _queueClient = new QueueClient(_storageConnectionString, \"test-queue\");
            _containerClient = new BlobContainerClient(_storageConnectionString, \"test-container\");
            _httpClient = new HttpClient
            {
                BaseAddress = new Uri(\"http://localhost:7071\") // Local Functions host
            };
        }

        public async Task InitializeAsync()
        {
            // Setup test resources
            await _queueClient.CreateIfNotExistsAsync();
            await _containerClient.CreateIfNotExistsAsync();
        }

        public async Task DisposeAsync()
        {
            // Cleanup test resources
            await _queueClient.DeleteIfExistsAsync();
            await _containerClient.DeleteIfExistsAsync();
            _httpClient.Dispose();
        }

        [Fact]
        public async Task HttpTrigger_EndToEnd_Success()
        {
            // Arrange
            var order = new
            {
                customerEmail = \"test@example.com\",
                items = new[]
                {
                    new { productId = \"P1\", quantity = 2, price = 50.00 }
                },
                totalAmount = 100.00
            };

            var content = new StringContent(
                JsonSerializer.Serialize(order),
                Encoding.UTF8,
                \"application/json\");

            // Act
            var response = await _httpClient.PostAsync(\"/api/orders\", content);

            // Assert
            Assert.True(response.IsSuccessStatusCode);
            
            var responseBody = await response.Content.ReadAsStringAsync();
            var createdOrder = JsonSerializer.Deserialize<Order>(responseBody);
            
            Assert.NotNull(createdOrder);
            Assert.NotNull(createdOrder.Id);
            Assert.Equal(order.customerEmail, createdOrder.CustomerEmail);
        }

        [Fact]
        public async Task QueueTrigger_ProcessesMessage_Success()
        {
            // Arrange
            var message = JsonSerializer.Serialize(new
            {
                orderId = \"ORD-123\",
                action = \"process\"
            });

            // Act
            await _queueClient.SendMessageAsync(message);

            // Wait for processing (in real tests, use polling or message confirmation)
            await Task.Delay(5000);

            // Assert
            // Check if message was processed (e.g., check database, output queue, etc.)
            var properties = await _queueClient.GetPropertiesAsync();
            Assert.Equal(0, properties.Value.ApproximateMessagesCount);
        }

        [Fact]
        public async Task BlobTrigger_ProcessesBlob_Success()
        {
            // Arrange
            var blobName = $\"test-{Guid.NewGuid()}.txt\";
            var blobContent = \"Test content\";
            var blobClient = _containerClient.GetBlobClient(blobName);

            // Act
            await blobClient.UploadAsync(
                new BinaryData(blobContent),
                overwrite: true);

            // Wait for processing
            await Task.Delay(5000);

            // Assert
            // Verify that the blob was processed (check output container, database, etc.)
            var outputBlobName = $\"processed-{blobName}\";
            var outputBlobClient = _containerClient.GetBlobClient(outputBlobName);
            var exists = await outputBlobClient.ExistsAsync();
            
            Assert.True(exists);
        }
    }
}
```

### 3. Durable Functions Testing

```csharp
using Xunit;
using Moq;
using Microsoft.DurableTask;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.Tests
{
    public class DurableOrchestrationTests
    {
        private readonly Mock<ILogger<OrderProcessingOrchestration>> _loggerMock;
        private readonly OrderProcessingOrchestration _orchestration;

        public DurableOrchestrationTests()
        {
            _loggerMock = new Mock<ILogger<OrderProcessingOrchestration>>();
            _orchestration = new OrderProcessingOrchestration(_loggerMock.Object);
        }

        [Fact]
        public async Task ValidateOrder_ValidOrder_ReturnsTrue()
        {
            // Arrange
            var order = new OrderRequest
            {
                OrderId = \"ORD-001\",
                CustomerEmail = \"test@example.com\",
                Items = new List<OrderItemRequest>
                {
                    new OrderItemRequest { ProductId = \"P1\", Quantity = 1, Price = 100 }
                },
                TotalAmount = 100
            };

            // Act
            var result = _orchestration.ValidateOrder(order);

            // Assert
            Assert.True(result.IsValid);
        }

        [Fact]
        public async Task ValidateOrder_EmptyEmail_ReturnsFalse()
        {
            // Arrange
            var order = new OrderRequest
            {
                OrderId = \"ORD-001\",
                CustomerEmail = \"\",
                Items = new List<OrderItemRequest> { new OrderItemRequest() },
                TotalAmount = 100
            };

            // Act
            var result = _orchestration.ValidateOrder(order);

            // Assert
            Assert.False(result.IsValid);
            Assert.Contains(\"email\", result.Message.ToLower());
        }

        [Fact]
        public async Task ProcessPayment_ValidPayment_ReturnsSuccess()
        {
            // Arrange
            var payment = new PaymentRequest
            {
                OrderId = \"ORD-001\",
                Amount = 100,
                PaymentMethod = \"CreditCard\"
            };

            // Act
            var result = await _orchestration.ProcessPayment(payment);

            // Assert
            Assert.True(result.Success);
            Assert.NotNull(result.TransactionId);
        }
    }
}
```

---

## Security & Authentication (C# Implementation)

### 1. Managed Identity Configuration

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Azure.Cosmos;

namespace MyFunctionApp
{
    public class Program
    {
        public static void Main()
        {
            var host = new HostBuilder()
                .ConfigureFunctionsWorkerDefaults()
                .ConfigureServices((context, services) =>
                {
                    // Configure Managed Identity
                    var credential = new DefaultAzureCredential();

                    // Blob Storage with Managed Identity
                    var blobServiceEndpoint = context.Configuration[\"BlobServiceEndpoint\"];
                    services.AddSingleton(sp => 
                        new BlobServiceClient(new Uri(blobServiceEndpoint), credential));

                    // Key Vault with Managed Identity
                    var keyVaultEndpoint = context.Configuration[\"KeyVaultEndpoint\"];
                    services.AddSingleton(sp => 
                        new SecretClient(new Uri(keyVaultEndpoint), credential));

                    // Cosmos DB with Managed Identity
                    var cosmosEndpoint = context.Configuration[\"CosmosDbEndpoint\"];
                    services.AddSingleton(sp => 
                        new CosmosClient(cosmosEndpoint, credential));

                    // Application Insights
                    services.AddApplicationInsightsTelemetryWorkerService();
                    services.ConfigureFunctionsApplicationInsights();
                })
                .Build();

            host.Run();
        }
    }
}
```

### 2. JWT Token Validation

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using System.Net;

namespace MyFunctionApp.Security
{
    /// <summary>
    /// Secure HTTP Function with JWT validation
    /// </summary>
    public class SecureHttpFunction
    {
        private readonly ILogger<SecureHttpFunction> _logger;
        private readonly ITokenValidator _tokenValidator;

        public SecureHttpFunction(
            ILogger<SecureHttpFunction> logger,
            ITokenValidator tokenValidator)
        {
            _logger = logger;
            _tokenValidator = tokenValidator;
        }

        [Function(nameof(SecureEndpoint))]
        public async Task<HttpResponseData> SecureEndpoint(
            [HttpTrigger(AuthorizationLevel.Anonymous, \"get\", \"post\")] 
            HttpRequestData req)
        {
            _logger.LogInformation(\"Processing secure request\");

            // Extract and validate token
            if (!req.Headers.TryGetValues(\"Authorization\", out var authHeaders))
            {
                return await CreateUnauthorizedResponse(req, \"Missing Authorization header\");
            }

            var authHeader = authHeaders.FirstOrDefault();
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith(\"Bearer \"))
            {
                return await CreateUnauthorizedResponse(req, \"Invalid Authorization header format\");
            }

            var token = authHeader.Substring(\"Bearer \".Length).Trim();

            try
            {
                // Validate token
                var principal = await _tokenValidator.ValidateTokenAsync(token);

                if (principal == null)
                {
                    return await CreateUnauthorizedResponse(req, \"Invalid token\");
                }

                // Check claims/roles
                if (!principal.IsInRole(\"Admin\") && !principal.IsInRole(\"User\"))
                {
                    return await CreateForbiddenResponse(req, \"Insufficient permissions\");
                }

                // Extract user information
                var userId = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var email = principal.FindFirst(ClaimTypes.Email)?.Value;

                _logger.LogInformation($\"Authenticated user: {email}\");

                // Process request
                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(new
                {
                    message = \"Success\",
                    userId,
                    email,
                    roles = principal.Claims
                        .Where(c => c.Type == ClaimTypes.Role)
                        .Select(c => c.Value)
                        .ToList()
                });

                return response;
            }
            catch (SecurityTokenExpiredException)
            {
                return await CreateUnauthorizedResponse(req, \"Token expired\");
            }
            catch (SecurityTokenValidationException ex)
            {
                _logger.LogWarning($\"Token validation failed: {ex.Message}\");
                return await CreateUnauthorizedResponse(req, \"Token validation failed\");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error processing secure request\");
                return await CreateErrorResponse(req, \"Internal server error\");
            }
        }

        private async Task<HttpResponseData> CreateUnauthorizedResponse(
            HttpRequestData req, string message)
        {
            var response = req.CreateResponse(HttpStatusCode.Unauthorized);
            await response.WriteAsJsonAsync(new { error = message });
            return response;
        }

        private async Task<HttpResponseData> CreateForbiddenResponse(
            HttpRequestData req, string message)
        {
            var response = req.CreateResponse(HttpStatusCode.Forbidden);
            await response.WriteAsJsonAsync(new { error = message });
            return response;
        }

        private async Task<HttpResponseData> CreateErrorResponse(
            HttpRequestData req, string message)
        {
            var response = req.CreateResponse(HttpStatusCode.InternalServerError);
            await response.WriteAsJsonAsync(new { error = message });
            return response;
        }
    }

    // Token Validator Implementation
    public interface ITokenValidator
    {
        Task<ClaimsPrincipal> ValidateTokenAsync(string token);
    }

    public class JwtTokenValidator : ITokenValidator
    {
        private readonly ILogger<JwtTokenValidator> _logger;
        private readonly TokenValidationParameters _validationParameters;

        public JwtTokenValidator(
            ILogger<JwtTokenValidator> logger,
            IConfiguration configuration)
        {
            _logger = logger;

            _validationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = configuration[\"Jwt:Issuer\"],
                
                ValidateAudience = true,
                ValidAudience = configuration[\"Jwt:Audience\"],
                
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(configuration[\"Jwt:SecretKey\"])),
                
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(5)
            };
        }

        public async Task<ClaimsPrincipal> ValidateTokenAsync(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();

            try
            {
                var principal = tokenHandler.ValidateToken(
                    token,
                    _validationParameters,
                    out SecurityToken validatedToken);

                var jwtToken = validatedToken as JwtSecurityToken;

                if (jwtToken == null ||
                    !jwtToken.Header.Alg.Equals(
                        SecurityAlgorithms.HmacSha256,
                        StringComparison.InvariantCultureIgnoreCase))
                {
                    throw new SecurityTokenValidationException(\"Invalid token algorithm\");
                }

                return await Task.FromResult(principal);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Token validation error\");
                throw;
            }
        }
    }
}
```

### 3. Azure AD B2C Authentication

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.Resource;
using System.Net;

namespace MyFunctionApp.Security
{
    /// <summary>
    /// Azure AD B2C Protected Function
    /// </summary>
    public class AadB2CProtectedFunction
    {
        private readonly ILogger<AadB2CProtectedFunction> _logger;

        public AadB2CProtectedFunction(ILogger<AadB2CProtectedFunction> logger)
        {
            _logger = logger;
        }

        [Function(nameof(GetUserProfile))]
        [RequiredScope(\"User.Read\")] // Require specific scope
        public async Task<HttpResponseData> GetUserProfile(
            [HttpTrigger(AuthorizationLevel.Anonymous, \"get\", Route = \"profile\")] 
            HttpRequestData req,
            FunctionContext executionContext)
        {
            _logger.LogInformation(\"Getting user profile\");

            try
            {
                // Azure AD B2C automatically validates the token
                // User claims are available in FunctionContext

                var principal = executionContext.Items[\"User\"] as ClaimsPrincipal;

                if (principal == null)
                {
                    var response = req.CreateResponse(HttpStatusCode.Unauthorized);
                    await response.WriteAsJsonAsync(new { error = \"Unauthorized\" });
                    return response;
                }

                var userId = principal.FindFirst(\"sub\")?.Value;
                var email = principal.FindFirst(\"emails\")?.Value;
                var name = principal.FindFirst(\"name\")?.Value;

                _logger.LogInformation($\"User: {email}\");

                var successResponse = req.CreateResponse(HttpStatusCode.OK);
                await successResponse.WriteAsJsonAsync(new
                {
                    userId,
                    email,
                    name,
                    roles = principal.Claims
                        .Where(c => c.Type == \"extension_Role\")
                        .Select(c => c.Value)
                        .ToList()
                });

                return successResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error getting user profile\");
                var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
                await errorResponse.WriteAsJsonAsync(new { error = \"Internal server error\" });
                return errorResponse;
            }
        }
    }

    // Configure in Program.cs
    public class ProgramWithAadB2C
    {
        public static void Main()
        {
            var host = new HostBuilder()
                .ConfigureFunctionsWorkerDefaults(builder =>
                {
                    // Add authentication middleware
                    builder.UseMiddleware<AadB2CAuthenticationMiddleware>();
                })
                .ConfigureServices((context, services) =>
                {
                    // Configure Azure AD B2C
                    services.AddAuthentication(options =>
                    {
                        options.DefaultScheme = \"Bearer\";
                    })
                    .AddMicrosoftIdentityWebApi(options =>
                    {
                        context.Configuration.Bind(\"AzureAdB2C\", options);
                        options.TokenValidationParameters.NameClaimType = \"name\";
                    },
                    options =>
                    {
                        context.Configuration.Bind(\"AzureAdB2C\", options);
                    });

                    services.AddAuthorization();
                })
                .Build();

            host.Run();
        }
    }
}
```

### 4. API Key Validation

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;

namespace MyFunctionApp.Security
{
    /// <summary>
    /// API Key based authentication
    /// </summary>
    public class ApiKeyProtectedFunction
    {
        private readonly ILogger<ApiKeyProtectedFunction> _logger;
        private readonly IApiKeyValidator _apiKeyValidator;

        public ApiKeyProtectedFunction(
            ILogger<ApiKeyProtectedFunction> logger,
            IApiKeyValidator apiKeyValidator)
        {
            _logger = logger;
            _apiKeyValidator = apiKeyValidator;
        }

        [Function(nameof(SecureApiEndpoint))]
        public async Task<HttpResponseData> SecureApiEndpoint(
            [HttpTrigger(AuthorizationLevel.Anonymous, \"get\", \"post\")] 
            HttpRequestData req)
        {
            _logger.LogInformation(\"Processing API request\");

            // Extract API key from header
            if (!req.Headers.TryGetValues(\"X-API-Key\", out var apiKeyHeaders))
            {
                return await CreateUnauthorizedResponse(req, \"Missing API key\");
            }

            var apiKey = apiKeyHeaders.FirstOrDefault();

            if (string.IsNullOrEmpty(apiKey))
            {
                return await CreateUnauthorizedResponse(req, \"Invalid API key\");
            }

            // Validate API key
            var validationResult = await _apiKeyValidator.ValidateAsync(apiKey);

            if (!validationResult.IsValid)
            {
                _logger.LogWarning($\"Invalid API key attempt\");
                return await CreateUnauthorizedResponse(req, \"Unauthorized\");
            }

            // Check rate limits
            if (validationResult.RateLimitExceeded)
            {
                _logger.LogWarning($\"Rate limit exceeded for client: {validationResult.ClientId}\");
                
                var response = req.CreateResponse(HttpStatusCode.TooManyRequests);
                response.Headers.Add(\"Retry-After\", \"60\");
                await response.WriteAsJsonAsync(new
                {
                    error = \"Rate limit exceeded\",
                    retryAfter = 60
                });
                return response;
            }

            _logger.LogInformation($\"Authenticated client: {validationResult.ClientId}\");

            // Process request
            var successResponse = req.CreateResponse(HttpStatusCode.OK);
            await successResponse.WriteAsJsonAsync(new
            {
                message = \"Success\",
                clientId = validationResult.ClientId,
                remainingRequests = validationResult.RemainingRequests
            });

            return successResponse;
        }

        private async Task<HttpResponseData> CreateUnauthorizedResponse(
            HttpRequestData req, string message)
        {
            var response = req.CreateResponse(HttpStatusCode.Unauthorized);
            await response.WriteAsJsonAsync(new { error = message });
            return response;
        }
    }

    // API Key Validator
    public interface IApiKeyValidator
    {
        Task<ApiKeyValidationResult> ValidateAsync(string apiKey);
    }

    public class ApiKeyValidator : IApiKeyValidator
    {
        private readonly ILogger<ApiKeyValidator> _logger;
        private readonly IConfiguration _configuration;
        private readonly Dictionary<string, ApiKeyInfo> _apiKeys;
        private readonly Dictionary<string, RateLimitInfo> _rateLimits;

        public ApiKeyValidator(
            ILogger<ApiKeyValidator> logger,
            IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            _apiKeys = new Dictionary<string, ApiKeyInfo>();
            _rateLimits = new Dictionary<string, RateLimitInfo>();
            
            LoadApiKeys();
        }

        public async Task<ApiKeyValidationResult> ValidateAsync(string apiKey)
        {
            // Check if API key exists
            if (!_apiKeys.TryGetValue(apiKey, out var keyInfo))
            {
                return new ApiKeyValidationResult { IsValid = false };
            }

            // Check if API key is expired
            if (keyInfo.ExpiresAt.HasValue && keyInfo.ExpiresAt.Value < DateTime.UtcNow)
            {
                _logger.LogWarning($\"Expired API key used: {keyInfo.ClientId}\");
                return new ApiKeyValidationResult { IsValid = false };
            }

            // Check rate limits
            var rateLimitExceeded = await CheckRateLimitAsync(keyInfo.ClientId, keyInfo.RateLimit);

            return new ApiKeyValidationResult
            {
                IsValid = true,
                ClientId = keyInfo.ClientId,
                RateLimitExceeded = rateLimitExceeded,
                RemainingRequests = CalculateRemainingRequests(keyInfo.ClientId, keyInfo.RateLimit)
            };
        }

        private void LoadApiKeys()
        {
            // In production, load from Key Vault or database
            var keys = _configuration.GetSection(\"ApiKeys\").Get<List<ApiKeyInfo>>();
            
            if (keys != null)
            {
                foreach (var key in keys)
                {
                    _apiKeys[key.Key] = key;
                }
            }
        }

        private async Task<bool> CheckRateLimitAsync(string clientId, int maxRequestsPerMinute)
        {
            var now = DateTime.UtcNow;

            if (!_rateLimits.TryGetValue(clientId, out var rateLimitInfo))
            {
                rateLimitInfo = new RateLimitInfo
                {
                    WindowStart = now,
                    RequestCount = 0
                };
                _rateLimits[clientId] = rateLimitInfo;
            }

            // Reset window if needed
            if (now - rateLimitInfo.WindowStart > TimeSpan.FromMinutes(1))
            {
                rateLimitInfo.WindowStart = now;
                rateLimitInfo.RequestCount = 0;
            }

            rateLimitInfo.RequestCount++;

            return await Task.FromResult(rateLimitInfo.RequestCount > maxRequestsPerMinute);
        }

        private int CalculateRemainingRequests(string clientId, int maxRequestsPerMinute)
        {
            if (!_rateLimits.TryGetValue(clientId, out var rateLimitInfo))
            {
                return maxRequestsPerMinute;
            }

            return Math.Max(0, maxRequestsPerMinute - rateLimitInfo.RequestCount);
        }
    }

    public class ApiKeyInfo
    {
        public string Key { get; set; }
        public string ClientId { get; set; }
        public string ClientName { get; set; }
        public int RateLimit { get; set; } = 1000; // Requests per minute
        public DateTime? ExpiresAt { get; set; }
    }

    public class RateLimitInfo
    {
        public DateTime WindowStart { get; set; }
        public int RequestCount { get; set; }
    }

    public class ApiKeyValidationResult
    {
        public bool IsValid { get; set; }
        public string ClientId { get; set; }
        public bool RateLimitExceeded { get; set; }
        public int RemainingRequests { get; set; }
    }
}
```

---

## Error Handling & Middleware (C# Implementation)

### 1. Global Error Handling Middleware

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Middleware;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace MyFunctionApp.Middleware
{
    /// <summary>
    /// Global error handling middleware
    /// </summary>
    public class ErrorHandlingMiddleware : IFunctionsWorkerMiddleware
    {
        private readonly ILogger<ErrorHandlingMiddleware> _logger;

        public ErrorHandlingMiddleware(ILogger<ErrorHandlingMiddleware> logger)
        {
            _logger = logger;
        }

        public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
        {
            try
            {
                // Execute the function
                await next(context);
            }
            catch (ValidationException ex)
            {
                _logger.LogWarning(ex, \"Validation error in function {FunctionName}\", 
                    context.FunctionDefinition.Name);
                
                await HandleValidationError(context, ex);
            }
            catch (BusinessException ex)
            {
                _logger.LogWarning(ex, \"Business logic error in function {FunctionName}\", 
                    context.FunctionDefinition.Name);
                
                await HandleBusinessError(context, ex);
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, \"Unauthorized access in function {FunctionName}\", 
                    context.FunctionDefinition.Name);
                
                await HandleUnauthorizedError(context, ex);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Unhandled exception in function {FunctionName}\", 
                    context.FunctionDefinition.Name);
                
                await HandleUnexpectedError(context, ex);
            }
        }

        private async Task HandleValidationError(FunctionContext context, ValidationException ex)
        {
            var httpContext = await context.GetHttpRequestDataAsync();
            if (httpContext != null)
            {
                var response = httpContext.CreateResponse(HttpStatusCode.BadRequest);
                await response.WriteAsJsonAsync(new ErrorResponse
                {
                    Error = \"ValidationError\",
                    Message = ex.Message,
                    Errors = ex.Errors,
                    TraceId = context.InvocationId
                });
                
                context.GetInvocationResult().Value = response;
            }
        }

        private async Task HandleBusinessError(FunctionContext context, BusinessException ex)
        {
            var httpContext = await context.GetHttpRequestDataAsync();
            if (httpContext != null)
            {
                var response = httpContext.CreateResponse(HttpStatusCode.UnprocessableEntity);
                await response.WriteAsJsonAsync(new ErrorResponse
                {
                    Error = \"BusinessError\",
                    Message = ex.Message,
                    Code = ex.ErrorCode,
                    TraceId = context.InvocationId
                });
                
                context.GetInvocationResult().Value = response;
            }
        }

        private async Task HandleUnauthorizedError(FunctionContext context, UnauthorizedAccessException ex)
        {
            var httpContext = await context.GetHttpRequestDataAsync();
            if (httpContext != null)
            {
                var response = httpContext.CreateResponse(HttpStatusCode.Forbidden);
                await response.WriteAsJsonAsync(new ErrorResponse
                {
                    Error = \"UnauthorizedAccess\",
                    Message = \"You don't have permission to access this resource\",
                    TraceId = context.InvocationId
                });
                
                context.GetInvocationResult().Value = response;
            }
        }

        private async Task HandleUnexpectedError(FunctionContext context, Exception ex)
        {
            var httpContext = await context.GetHttpRequestDataAsync();
            if (httpContext != null)
            {
                var response = httpContext.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteAsJsonAsync(new ErrorResponse
                {
                    Error = \"InternalServerError\",
                    Message = \"An unexpected error occurred. Please try again later.\",
                    TraceId = context.InvocationId
                    // Don't expose internal error details to clients
                });
                
                context.GetInvocationResult().Value = response;
            }
        }
    }

    // Error Response Model
    public class ErrorResponse
    {
        public string Error { get; set; }
        public string Message { get; set; }
        public string Code { get; set; }
        public Dictionary<string, string[]> Errors { get; set; }
        public string TraceId { get; set; }
    }

    // Custom Exceptions
    public class ValidationException : Exception
    {
        public Dictionary<string, string[]> Errors { get; set; }

        public ValidationException(string message, Dictionary<string, string[]> errors)
            : base(message)
        {
            Errors = errors;
        }
    }

    public class BusinessException : Exception
    {
        public string ErrorCode { get; set; }

        public BusinessException(string message, string errorCode = null)
            : base(message)
        {
            ErrorCode = errorCode;
        }
    }
}
```

### 2. Logging Middleware

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Middleware;
using Microsoft.Extensions.Logging;
using System.Diagnostics;

namespace MyFunctionApp.Middleware
{
    /// <summary>
    /// Logging middleware for request/response tracking
    /// </summary>
    public class LoggingMiddleware : IFunctionsWorkerMiddleware
    {
        private readonly ILogger<LoggingMiddleware> _logger;

        public LoggingMiddleware(ILogger<LoggingMiddleware> logger)
        {
            _logger = logger;
        }

        public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
        {
            var stopwatch = Stopwatch.StartNew();
            var functionName = context.FunctionDefinition.Name;
            var invocationId = context.InvocationId;

            _logger.LogInformation(
                \"[{InvocationId}] Function {FunctionName} started\",
                invocationId,
                functionName);

            try
            {
                // Log HTTP request details
                var httpRequest = await context.GetHttpRequestDataAsync();
                if (httpRequest != null)
                {
                    _logger.LogInformation(
                        \"[{InvocationId}] HTTP {Method} {Url}\",
                        invocationId,
                        httpRequest.Method,
                        httpRequest.Url);
                }

                // Execute function
                await next(context);

                stopwatch.Stop();

                _logger.LogInformation(
                    \"[{InvocationId}] Function {FunctionName} completed successfully in {Duration}ms\",
                    invocationId,
                    functionName,
                    stopwatch.ElapsedMilliseconds);
            }
            catch (Exception ex)
            {
                stopwatch.Stop();

                _logger.LogError(ex,
                    \"[{InvocationId}] Function {FunctionName} failed after {Duration}ms\",
                    invocationId,
                    functionName,
                    stopwatch.ElapsedMilliseconds);

                throw;
            }
        }
    }
}
```

### 3. Retry Policy Implementation

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Polly;
using Polly.Retry;

namespace MyFunctionApp.Functions
{
    /// <summary>
    /// Function with retry policy using Polly
    /// </summary>
    public class ResilientFunction
    {
        private readonly ILogger<ResilientFunction> _logger;
        private readonly IExternalService _externalService;
        private readonly AsyncRetryPolicy _retryPolicy;

        public ResilientFunction(
            ILogger<ResilientFunction> logger,
            IExternalService externalService)
        {
            _logger = logger;
            _externalService = externalService;

            // Configure retry policy
            _retryPolicy = Policy
                .Handle<HttpRequestException>()
                .Or<TimeoutException>()
                .WaitAndRetryAsync(
                    retryCount: 3,
                    sleepDurationProvider: retryAttempt => 
                        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                    onRetry: (exception, timeSpan, retryCount, context) =>
                    {
                        _logger.LogWarning(
                            \"Retry {RetryCount} after {Delay}s due to {Exception}\",
                            retryCount,
                            timeSpan.TotalSeconds,
                            exception.GetType().Name);
                    });
        }

        [Function(nameof(ProcessWithRetry))]
        public async Task<HttpResponseData> ProcessWithRetry(
            [HttpTrigger(AuthorizationLevel.Function, \"post\")] HttpRequestData req)
        {
            _logger.LogInformation(\"Processing request with retry policy\");

            try
            {
                // Execute with retry policy
                var result = await _retryPolicy.ExecuteAsync(async () =>
                {
                    return await _externalService.CallExternalApiAsync();
                });

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(result);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Failed after all retries\");
                
                var errorResponse = req.CreateResponse(HttpStatusCode.ServiceUnavailable);
                await errorResponse.WriteAsJsonAsync(new
                {
                    error = \"Service temporarily unavailable. Please try again later.\"
                });
                return errorResponse;
            }
        }
    }

    // Configure advanced policies in Program.cs
    public class ProgramWithPolly
    {
        public static void Main()
        {
            var host = new HostBuilder()
                .ConfigureFunctionsWorkerDefaults()
                .ConfigureServices((context, services) =>
                {
                    // Circuit Breaker Policy
                    var circuitBreakerPolicy = Policy
                        .Handle<HttpRequestException>()
                        .CircuitBreakerAsync(
                            exceptionsAllowedBeforeBreaking: 5,
                            durationOfBreak: TimeSpan.FromSeconds(30));

                    // Timeout Policy
                    var timeoutPolicy = Policy
                        .TimeoutAsync<HttpResponseMessage>(TimeSpan.FromSeconds(10));

                    // Combine policies
                    var combinedPolicy = Policy.WrapAsync(
                        circuitBreakerPolicy,
                        timeoutPolicy);

                    services.AddSingleton(combinedPolicy);
                })
                .Build();

            host.Run();
        }
    }
}
```

---

## Azure Functions Platform Features & Configuration

### 1. CORS (Cross-Origin Resource Sharing)

**CORS** allows your HTTP-triggered functions to be called from web applications hosted on different domains.

#### Portal Configuration

Navigate to: **Function App → CORS**

```
Azure Portal Steps:
1. Go to Function App
2. Select "CORS" under API section
3. Add allowed origins:
   - https://www.example.com
   - https://app.example.com
   - http://localhost:3000 (for local development)
4. Enable "Access-Control-Allow-Credentials" if needed
5. Save changes
```

#### host.json Configuration

```json
{
  "version": "2.0",
  "extensions": {
    "http": {
      "customHeaders": {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
        "Access-Control-Max-Age": "86400"
      }
    }
  }
}
```

#### C# Code-Based CORS Handling

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Net;

namespace MyFunctionApp.Features
{
    public class CorsEnabledFunction
    {
        [Function("CorsExample")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", "options")] 
            HttpRequestData req)
        {
            // Handle preflight OPTIONS request
            if (req.Method.Equals("OPTIONS", StringComparison.OrdinalIgnoreCase))
            {
                var response = req.CreateResponse(HttpStatusCode.OK);
                AddCorsHeaders(response);
                return response;
            }

            // Handle actual request
            var result = req.CreateResponse(HttpStatusCode.OK);
            AddCorsHeaders(result);
            await result.WriteAsJsonAsync(new { message = "CORS enabled response" });
            return result;
        }

        private void AddCorsHeaders(HttpResponseData response)
        {
            response.Headers.Add("Access-Control-Allow-Origin", "*");
            response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
            response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Custom-Header");
            response.Headers.Add("Access-Control-Max-Age", "86400");
            response.Headers.Add("Access-Control-Allow-Credentials", "true");
        }
    }
}
```

#### CORS Middleware (Advanced)

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.Functions.Worker.Middleware;
using System.Net;

namespace MyFunctionApp.Middleware
{
    /// <summary>
    /// Global CORS middleware for all HTTP functions
    /// </summary>
    public class CorsMiddleware : IFunctionsWorkerMiddleware
    {
        private readonly string[] _allowedOrigins;
        private readonly string[] _allowedMethods;
        private readonly string[] _allowedHeaders;

        public CorsMiddleware(IConfiguration configuration)
        {
            _allowedOrigins = configuration.GetSection("Cors:AllowedOrigins")
                .Get<string[]>() ?? new[] { "*" };
            
            _allowedMethods = configuration.GetSection("Cors:AllowedMethods")
                .Get<string[]>() ?? new[] { "GET", "POST", "PUT", "DELETE", "OPTIONS" };
            
            _allowedHeaders = configuration.GetSection("Cors:AllowedHeaders")
                .Get<string[]>() ?? new[] { "Content-Type", "Authorization" };
        }

        public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
        {
            var requestData = await context.GetHttpRequestDataAsync();

            if (requestData != null)
            {
                // Handle preflight request
                if (requestData.Method.Equals("OPTIONS", StringComparison.OrdinalIgnoreCase))
                {
                    var response = requestData.CreateResponse(HttpStatusCode.OK);
                    AddCorsHeaders(response, requestData);
                    
                    var invocationResult = context.GetInvocationResult();
                    invocationResult.Value = response;
                    return;
                }

                // Process request
                await next(context);

                // Add CORS headers to response
                var httpResponseData = context.GetHttpResponseData();
                if (httpResponseData != null)
                {
                    AddCorsHeaders(httpResponseData, requestData);
                }
            }
            else
            {
                await next(context);
            }
        }

        private void AddCorsHeaders(HttpResponseData response, HttpRequestData request)
        {
            var origin = request.Headers.TryGetValues("Origin", out var origins) 
                ? origins.FirstOrDefault() 
                : "*";

            // Check if origin is allowed
            if (_allowedOrigins.Contains("*") || _allowedOrigins.Contains(origin))
            {
                response.Headers.Add("Access-Control-Allow-Origin", origin);
                response.Headers.Add("Access-Control-Allow-Methods", 
                    string.Join(", ", _allowedMethods));
                response.Headers.Add("Access-Control-Allow-Headers", 
                    string.Join(", ", _allowedHeaders));
                response.Headers.Add("Access-Control-Max-Age", "86400");
                response.Headers.Add("Access-Control-Allow-Credentials", "true");
            }
        }
    }

    // Register in Program.cs
    public static class ProgramWithCors
    {
        public static void Main()
        {
            var host = new HostBuilder()
                .ConfigureFunctionsWorkerDefaults(builder =>
                {
                    builder.UseMiddleware<CorsMiddleware>();
                })
                .Build();

            host.Run();
        }
    }
}
```

#### CORS Best Practices

| Scenario | Recommended Configuration |
|----------|---------------------------|
| **Public API** | Use specific origins, avoid `*` |
| **Internal API** | Whitelist only your app domains |
| **Development** | Add `http://localhost:3000`, `http://localhost:4200` |
| **Mobile Apps** | Consider using API keys instead |
| **Preflight Caching** | Set `Access-Control-Max-Age: 86400` (24 hours) |
| **Credentials** | Only enable `Allow-Credentials` when needed |

---

### 2. Proxies (Function Proxies)

**Function Proxies** allow you to define API endpoints that forward requests to other functions or backends.

⚠️ **Note:** Proxies are in maintenance mode. Consider using **Azure API Management** or **Azure Front Door** for new projects.

#### proxies.json Configuration

```json
{
  "$schema": "http://json.schemastore.org/proxies",
  "proxies": {
    "HelloProxy": {
      "matchCondition": {
        "route": "/api/hello",
        "methods": [ "GET" ]
      },
      "backendUri": "https://mybackend.azurewebsites.net/api/hello"
    },
    
    "ApiVersionProxy": {
      "matchCondition": {
        "route": "/api/v1/{*path}",
        "methods": [ "GET", "POST", "PUT", "DELETE" ]
      },
      "backendUri": "https://mybackend.azurewebsites.net/api/{path}"
    },
    
    "MockResponse": {
      "matchCondition": {
        "route": "/api/status"
      },
      "responseOverrides": {
        "response.statusCode": "200",
        "response.body": "{\"status\":\"healthy\",\"version\":\"1.0.0\"}"
      }
    },

    "HeaderTransform": {
      "matchCondition": {
        "route": "/api/users/{id}"
      },
      "backendUri": "https://legacy-api.example.com/users/{id}",
      "requestOverrides": {
        "backend.request.headers.x-custom-auth": "{request.headers.authorization}",
        "backend.request.headers.x-source": "azure-functions"
      },
      "responseOverrides": {
        "response.headers.x-powered-by": "Azure Functions"
      }
    }
  }
}
```

#### Common Proxy Use Cases

| Use Case | Configuration |
|----------|---------------|
| **API Versioning** | Route `/api/v1/*` → Backend A, `/api/v2/*` → Backend B |
| **Mock Responses** | Return static JSON for testing |
| **Header Transformation** | Add/modify headers between client and backend |
| **Route Aggregation** | Multiple backends behind single endpoint |
| **Legacy API Wrapper** | Add modern API layer over legacy systems |

---

### 3. Custom Handlers

**Custom Handlers** enable you to run Azure Functions in **any language** by implementing a simple HTTP server.

#### Architecture

```
┌────────────────────────────────────────────┐
│        Azure Functions Host                │
│  ┌──────────────────────────────────────┐ │
│  │   Function Trigger                    │ │
│  └──────────┬───────────────────────────┘ │
│             │ HTTP Request               │
│             ▼                            │
│  ┌──────────────────────────────────────┐ │
│  │   Custom Handler (Your Code)         │ │
│  │   - Rust, Go, PHP, Ruby, etc.        │ │
│  │   - Custom HTTP server on port 3000  │ │
│  └──────────┬───────────────────────────┘ │
│             │ HTTP Response              │
│             ▼                            │
│  ┌──────────────────────────────────────┐ │
│  │   Function Response                   │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

#### host.json for Custom Handler

```json
{
  "version": "2.0",
  "logging": {
    "logLevel": {
      "default": "Information"
    }
  },
  "customHandler": {
    "description": {
      "defaultExecutablePath": "handler",
      "workingDirectory": "",
      "arguments": []
    },
    "enableForwardingHttpRequest": true
  }
}
```

#### Example: Go Custom Handler

**function.json**
```json
{
  "bindings": [
    {
      "type": "httpTrigger",
      "authLevel": "anonymous",
      "direction": "in",
      "name": "req",
      "methods": ["get", "post"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

**handler.go**
```go
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
)

type InvokeRequest struct {
    Data     map[string]interface{} `json:"Data"`
    Metadata map[string]interface{} `json:"Metadata"`
}

type InvokeResponse struct {
    Outputs     map[string]interface{} `json:"Outputs"`
    Logs        []string               `json:"Logs"`
    ReturnValue interface{}            `json:"ReturnValue"`
}

func httpHandler(w http.ResponseWriter, r *http.Request) {
    var invokeRequest InvokeRequest
    
    err := json.NewDecoder(r.Body).Decode(&invokeRequest)
    if err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    // Process request
    name := "World"
    if val, ok := invokeRequest.Data["req"].(map[string]interface{}); ok {
        if query, ok := val["Query"].(map[string]interface{}); ok {
            if n, ok := query["name"].(string); ok {
                name = n
            }
        }
    }

    // Create response
    response := InvokeResponse{
        Outputs: map[string]interface{}{
            "res": map[string]interface{}{
                "statusCode": 200,
                "body":       fmt.Sprintf("Hello, %s!", name),
            },
        },
        Logs: []string{
            fmt.Sprintf("Processed request for %s", name),
        },
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func main() {
    customHandlerPort, exists := os.LookupEnv("FUNCTIONS_CUSTOMHANDLER_PORT")
    if !exists {
        customHandlerPort = "8080"
    }
    
    mux := http.NewServeMux()
    mux.HandleFunc("/api/HttpExample", httpHandler)
    
    fmt.Printf("Starting custom handler on port %s\n", customHandlerPort)
    log.Fatal(http.ListenAndServe(":"+customHandlerPort, mux))
}
```

#### Example: Rust Custom Handler

**main.rs**
```rust
use actix_web::{post, web, App, HttpResponse, HttpServer, Result};
use serde::{Deserialize, Serialize};
use std::env;

#[derive(Deserialize)]
struct InvokeRequest {
    #[serde(rename = "Data")]
    data: serde_json::Value,
    #[serde(rename = "Metadata")]
    metadata: serde_json::Value,
}

#[derive(Serialize)]
struct InvokeResponse {
    #[serde(rename = "Outputs")]
    outputs: serde_json::Value,
    #[serde(rename = "Logs")]
    logs: Vec<String>,
    #[serde(rename = "ReturnValue")]
    return_value: Option<serde_json::Value>,
}

#[post("/api/HttpExample")]
async fn http_handler(req: web::Json<InvokeRequest>) -> Result<HttpResponse> {
    let name = req.data["req"]["Query"]["name"]
        .as_str()
        .unwrap_or("World");

    let response = InvokeResponse {
        outputs: serde_json::json!({
            "res": {
                "statusCode": 200,
                "body": format!("Hello, {}!", name)
            }
        }),
        logs: vec![format!("Processed request for {}", name)],
        return_value: None,
    };

    Ok(HttpResponse::Ok().json(response))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port = env::var("FUNCTIONS_CUSTOMHANDLER_PORT")
        .unwrap_or_else(|_| "8080".to_string());
    
    println!("Starting custom handler on port {}", port);

    HttpServer::new(|| App::new().service(http_handler))
        .bind(format!("127.0.0.1:{}", port))?
        .run()
        .await
}
```

---

### 4. Deployment Slots

**Deployment Slots** provide staging environments for your Function Apps (Premium and Dedicated plans only).

#### Key Features

| Feature | Description |
|---------|-------------|
| **Slot Types** | Production (default) + up to 4 additional slots |
| **Use Cases** | Blue-green deployment, A/B testing, staging validation |
| **Slot Settings** | Some settings stick to slot, others swap |
| **Traffic Routing** | Route percentage of traffic to different slots |
| **Auto-Swap** | Automatically swap after deployment |

#### Portal Configuration

```
Azure Portal Steps:
1. Go to Function App
2. Select "Deployment slots" (under Deployment)
3. Click "+ Add Slot"
4. Name: "staging"
5. Clone settings from: "Production" (optional)
6. Click "Add"
```

#### Slot-Specific Settings

**Sticky Settings** (don't swap):
- Publishing profile
- Custom domain names
- Non-public certificates and TLS/SSL settings
- Scale settings
- Always On
- Diagnostic settings

**Settings that Swap:**
- General configuration (runtime, platform bits)
- App settings (unless marked as slot setting)
- Connection strings (unless marked as slot setting)
- Handler mappings
- Public certificates
- WebJobs content
- Hybrid connections

#### Mark Setting as Slot Setting

```bash
# Azure CLI - Mark app setting as slot setting
az functionapp config appsettings set \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --settings "SETTING_NAME=value" \
  --slot-settings SETTING_NAME
```

#### Swap Slots

```bash
# Swap staging to production
az functionapp deployment slot swap \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --slot staging \
  --target-slot production

# Swap with preview (two-phase swap)
az functionapp deployment slot swap \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --slot staging \
  --target-slot production \
  --action preview

# Complete the swap
az functionapp deployment slot swap \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --action swap
```

#### Traffic Routing

```bash
# Route 20% of traffic to staging slot
az functionapp traffic-routing set \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --distribution staging=20
```

#### Auto-Swap Configuration

```json
// local.settings.json or Application Settings
{
  "WEBSITE_SWAP_WARMUP_PING_PATH": "/api/warmup",
  "WEBSITE_SWAP_WARMUP_PING_STATUSES": "200,202",
  "WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG": "1"
}
```

---

### 5. Application Settings & Environment Variables

#### Portal Configuration

```
Azure Portal:
Function App → Configuration → Application settings
```

#### Add via Azure CLI

```bash
# Set single setting
az functionapp config appsettings set \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --settings "API_KEY=secret-value"

# Set multiple settings
az functionapp config appsettings set \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --settings \
    "DATABASE_CONNECTION=Server=..." \
    "REDIS_HOST=myredis.redis.cache.windows.net" \
    "LOG_LEVEL=Information"

# Reference Key Vault secret
az functionapp config appsettings set \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --settings \
    "MySecret=@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/MySecret/)"
```

#### Built-in Environment Variables

| Variable | Description |
|----------|-------------|
| `AZURE_FUNCTIONS_ENVIRONMENT` | `Development`, `Staging`, `Production` |
| `WEBSITE_SITE_NAME` | Function App name |
| `WEBSITE_INSTANCE_ID` | Unique instance identifier |
| `WEBSITE_HOSTNAME` | Function App hostname |
| `AzureWebJobsStorage` | Storage connection string (required) |
| `FUNCTIONS_WORKER_RUNTIME` | `dotnet-isolated`, `python`, `node`, etc. |
| `FUNCTIONS_EXTENSION_VERSION` | `~4` for Functions v4 |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | App Insights connection |

#### Access in Code (C#)

```csharp
// Access environment variables
var apiKey = Environment.GetEnvironmentVariable("API_KEY");
var connectionString = Environment.GetEnvironmentVariable("DATABASE_CONNECTION");

// Or via IConfiguration
public class MyFunction
{
    private readonly IConfiguration _configuration;

    public MyFunction(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [Function("MyFunction")]
    public async Task Run([TimerTrigger("0 0 * * * *")] TimerInfo timer)
    {
        var apiKey = _configuration["API_KEY"];
        var dbConnection = _configuration["DATABASE_CONNECTION"];
    }
}
```

---

### 6. Network Features

#### A. Virtual Network (VNet) Integration

**Enables outbound access to resources in VNet or on-premises via VPN/ExpressRoute.**

**Available in:** Premium, Dedicated plans

```bash
# Enable VNet integration
az functionapp vnet-integration add \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --vnet MyVNet \
  --subnet functions-subnet
```

**Use Cases:**
- Access private databases (SQL, Cosmos DB with private endpoint)
- Call internal APIs
- Access on-premises resources via VPN
- Comply with network security policies

#### B. Private Endpoints

**Enables inbound private access to your Function App from VNet.**

```bash
# Create private endpoint
az network private-endpoint create \
  --name MyFunctionAppPE \
  --resource-group MyResourceGroup \
  --vnet-name MyVNet \
  --subnet private-endpoints-subnet \
  --private-connection-resource-id $(az functionapp show \
    --name MyFunctionApp \
    --resource-group MyResourceGroup \
    --query id -o tsv) \
  --connection-name MyFunctionAppConnection \
  --group-id sites
```

**Features:**
- Function accessible only from VNet
- Traffic doesn't traverse public internet
- Use with Azure Private DNS zone
- Ideal for secure, internal-only functions

#### C. Service Endpoints

**Alternative to Private Endpoints for Azure services.**

```bash
# Enable service endpoint on subnet
az network vnet subnet update \
  --vnet-name MyVNet \
  --name functions-subnet \
  --resource-group MyResourceGroup \
  --service-endpoints Microsoft.Storage Microsoft.Sql
```

#### Network Feature Comparison

| Feature | VNet Integration | Private Endpoint | Service Endpoint |
|---------|------------------|------------------|------------------|
| **Direction** | Outbound | Inbound | Outbound |
| **Use Case** | Access private resources | Secure inbound access | Access Azure services |
| **Cost** | Included | ~$7.50/month + data | Free |
| **Traffic** | Via VNet | Private IP only | Via service endpoint |
| **Plans** | Premium, Dedicated | Premium, Dedicated | Premium, Dedicated |

---

### 7. IP Restrictions & Access Restrictions

**Control which IP addresses can access your Function App.**

#### Portal Configuration

```
Function App → Networking → Access restrictions
```

#### Add IP Restriction via CLI

```bash
# Allow specific IP
az functionapp config access-restriction add \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --rule-name "Allow-Office" \
  --action Allow \
  --ip-address 203.0.113.0/24 \
  --priority 100

# Allow Service Tag (e.g., Azure Front Door)
az functionapp config access-restriction add \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --rule-name "Allow-AFD" \
  --action Allow \
  --service-tag AzureFrontDoor.Backend \
  --priority 200

# Deny all others (implicit)
```

#### Access Restriction Rules

| Rule Type | Example | Use Case |
|-----------|---------|----------|
| **IP Address** | `203.0.113.0/24` | Allow office network |
| **Service Tag** | `AzureFrontDoor.Backend` | Traffic through Azure Front Door |
| **VNet/Subnet** | `/subscriptions/.../virtualNetworks/...` | Allow from specific VNet |

#### SCM (Kudu) Separate Restrictions

```bash
# Apply restrictions to deployment/SCM site separately
az functionapp config access-restriction add \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --rule-name "Allow-DevOps" \
  --action Allow \
  --ip-address 198.51.100.0/24 \
  --priority 100 \
  --scm-site true
```

---

### 8. Custom Domains & SSL/TLS

#### Add Custom Domain

```bash
# Add custom domain
az functionapp config hostname add \
  --hostname api.example.com \
  --webapp-name MyFunctionApp \
  --resource-group MyResourceGroup

# Verify domain ownership (DNS)
# Add TXT record or CNAME record as instructed
```

#### DNS Configuration

**Option 1: CNAME Record**
```
Type: CNAME
Name: api
Value: myfunctionapp.azurewebsites.net
TTL: 3600
```

**Option 2: A Record + TXT Record**
```
Type: A
Name: api
Value: <Function App IP>

Type: TXT
Name: asuid.api
Value: <Custom domain verification ID>
```

#### SSL/TLS Certificate

**Option 1: Managed Certificate (Free)**
```bash
# Create free managed certificate
az functionapp config ssl create \
  --hostname api.example.com \
  --name MyFunctionApp \
  --resource-group MyResourceGroup
```

**Option 2: Upload Custom Certificate**
```bash
# Upload PFX certificate
az functionapp config ssl upload \
  --certificate-file certificate.pfx \
  --certificate-password <password> \
  --name MyFunctionApp \
  --resource-group MyResourceGroup

# Bind certificate to hostname
az functionapp config ssl bind \
  --certificate-thumbprint <thumbprint> \
  --ssl-type SNI \
  --name MyFunctionApp \
  --resource-group MyResourceGroup
```

**Option 3: Import from Key Vault**
```bash
az functionapp config ssl import \
  --key-vault MyKeyVault \
  --key-vault-certificate-name MyCertificate \
  --name MyFunctionApp \
  --resource-group MyResourceGroup
```

#### Enforce HTTPS

```bash
az functionapp update \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --set httpsOnly=true
```

---

### 9. Warm-up Trigger (Premium/Dedicated Plans)

**Pre-warm instances before they receive traffic after scaling out.**

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace MyFunctionApp.Features
{
    public class WarmupFunction
    {
        private readonly ILogger<WarmupFunction> _logger;
        private readonly IMyService _myService;

        public WarmupFunction(
            ILogger<WarmupFunction> logger,
            IMyService myService)
        {
            _logger = logger;
            _myService = myService;
        }

        /// <summary>
        /// Warm-up trigger - runs when new instance is added
        /// Use to pre-load caches, establish connections, etc.
        /// </summary>
        [Function("warmup")]
        public async Task Run([WarmupTrigger] WarmupContext context)
        {
            _logger.LogInformation("Warming up instance");

            // Pre-load configuration
            await LoadConfigurationAsync();

            // Establish database connections
            await _myService.InitializeConnectionPoolAsync();

            // Pre-load caches
            await PreLoadCachesAsync();

            // Warm up HTTP clients
            await WarmupHttpClientsAsync();

            _logger.LogInformation("Instance warm-up complete");
        }

        private async Task LoadConfigurationAsync()
        {
            // Load configuration from Key Vault, App Configuration, etc.
            _logger.LogInformation("Loading configuration");
            await Task.Delay(100); // Simulate config load
        }

        private async Task PreLoadCachesAsync()
        {
            // Pre-populate in-memory caches
            _logger.LogInformation("Pre-loading caches");
            await Task.Delay(200); // Simulate cache load
        }

        private async Task WarmupHttpClientsAsync()
        {
            // Make initial HTTP requests to warm up connections
            _logger.LogInformation("Warming up HTTP clients");
            await Task.Delay(100); // Simulate HTTP warmup
        }
    }
}
```

**What to Do in Warm-up:**
- ✅ Load configuration from Key Vault
- ✅ Establish database connection pools
- ✅ Pre-load in-memory caches
- ✅ Initialize HTTP clients
- ✅ JIT compile frequently-used code paths
- ❌ Don't perform time-consuming operations (keep under 2-3 seconds)

---

### 10. Function Keys & Authorization

#### Function Key Levels

| Level | Scope | Use Case |
|-------|-------|----------|
| **Function Key** | Single function | Function-specific access |
| **Host Key** | All functions in app | Admin operations |
| **System Key** | Internal use | Durable Functions, extensions |
| **Master Key** | All functions (admin) | Legacy, avoid using |

#### Manage Keys via CLI

```bash
# List function keys
az functionapp keys list \
  --name MyFunctionApp \
  --resource-group MyResourceGroup

# Create new function key
az functionapp function keys set \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --function-name MyFunction \
  --key-name client1 \
  --key-value <secret-value>

# Delete function key
az functionapp function keys delete \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --function-name MyFunction \
  --key-name client1
```

#### Use Function Key in Request

```bash
# Query parameter
curl "https://myfunctionapp.azurewebsites.net/api/MyFunction?code=<function-key>"

# Header
curl "https://myfunctionapp.azurewebsites.net/api/MyFunction" \
  -H "x-functions-key: <function-key>"
```

#### Authorization Level in Code

```csharp
// Anonymous - no key required
[Function("PublicApi")]
[HttpTrigger(AuthorizationLevel.Anonymous, "get")]

// Function - function key required
[Function("ProtectedApi")]
[HttpTrigger(AuthorizationLevel.Function, "get")]

// Admin - host/master key required
[Function("AdminApi")]
[HttpTrigger(AuthorizationLevel.Admin, "post")]
```

---

### 11. Easy Auth (Authentication / Authorization)

**Built-in authentication without writing code (App Service Authentication).**

#### Supported Identity Providers

- Microsoft Entra ID (Azure AD)
- Facebook
- Google
- Twitter
- Apple
- OpenID Connect providers
- GitHub

#### Enable via Portal

```
Function App → Authentication → Add identity provider
→ Select Microsoft → Configure
```

#### Enable via CLI

```bash
# Enable Azure AD authentication
az functionapp auth update \
  --name MyFunctionApp \
  --resource-group MyResourceGroup \
  --enabled true \
  --action LoginWithAzureActiveDirectory \
  --aad-client-id <client-id> \
  --aad-client-secret <client-secret> \
  --aad-allowed-token-audiences "https://myfunctionapp.azurewebsites.net"
```

#### Auth Configuration

```json
// File: /site/wwwroot/auth.json (advanced configuration)
{
  "platform": {
    "enabled": true
  },
  "globalValidation": {
    "requireAuthentication": true,
    "unauthenticatedClientAction": "RedirectToLoginPage"
  },
  "identityProviders": {
    "azureActiveDirectory": {
      "enabled": true,
      "registration": {
        "openIdIssuer": "https://sts.windows.net/<tenant-id>/",
        "clientId": "<client-id>"
      },
      "validation": {
        "allowedAudiences": [
          "https://myfunctionapp.azurewebsites.net"
        ]
      }
    }
  },
  "login": {
    "tokenStore": {
      "enabled": true
    }
  }
}
```

#### Access User Claims in Code

```csharp
[Function("AuthenticatedFunction")]
public async Task<HttpResponseData> Run(
    [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req,
    FunctionContext context)
{
    // Easy Auth populates these headers
    var principalId = req.Headers.GetValues("X-MS-CLIENT-PRINCIPAL-ID").FirstOrDefault();
    var principalName = req.Headers.GetValues("X-MS-CLIENT-PRINCIPAL-NAME").FirstOrDefault();
    
    // Or decode the claims from X-MS-CLIENT-PRINCIPAL header
    var claimsPrincipal = GetClaimsPrincipalFromHeader(req);

    var response = req.CreateResponse(HttpStatusCode.OK);
    await response.WriteAsJsonAsync(new
    {
        userId = principalId,
        userName = principalName,
        email = claimsPrincipal.FindFirst("email")?.Value
    });

    return response;
}

private ClaimsPrincipal GetClaimsPrincipalFromHeader(HttpRequestData req)
{
    if (req.Headers.TryGetValues("X-MS-CLIENT-PRINCIPAL", out var principalHeaders))
    {
        var principal = principalHeaders.FirstOrDefault();
        if (!string.IsNullOrEmpty(principal))
        {
            var decoded = Convert.FromBase64String(principal);
            var json = Encoding.UTF8.GetString(decoded);
            // Parse JSON to ClaimsPrincipal
            // ... implementation
        }
    }
    return null;
}
```

---

### 12. Host.json Complete Reference

```json
{
  "version": "2.0",
  
  // Logging configuration
  "logging": {
    "logLevel": {
      "default": "Information",
      "Host.Results": "Error",
      "Function": "Information",
      "Microsoft": "Warning"
    },
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true,
        "maxTelemetryItemsPerSecond": 20,
        "excludedTypes": "Request;Exception"
      },
      "enableLiveMetrics": true,
      "enableDependencyTracking": true,
      "enablePerformanceCountersCollection": true
    }
  },

  // HTTP extension
  "extensions": {
    "http": {
      "routePrefix": "api",
      "maxOutstandingRequests": 200,
      "maxConcurrentRequests": 100,
      "dynamicThrottlesEnabled": true,
      "hsts": {
        "isEnabled": true,
        "maxAge": "365"
      },
      "customHeaders": {
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "DENY"
      }
    },

    // Queue trigger settings
    "queues": {
      "maxPollingInterval": "00:00:02",
      "visibilityTimeout": "00:00:30",
      "batchSize": 16,
      "maxDequeueCount": 5,
      "newBatchThreshold": 8
    },

    // Service Bus settings
    "serviceBus": {
      "prefetchCount": 100,
      "messageHandlerOptions": {
        "autoComplete": true,
        "maxConcurrentCalls": 16,
        "maxAutoRenewDuration": "00:05:00"
      },
      "sessionHandlerOptions": {
        "autoComplete": false,
        "messageWaitTimeout": "00:00:30",
        "maxAutoRenewDuration": "00:55:00",
        "maxConcurrentSessions": 8
      }
    },

    // Event Hub settings
    "eventHub": {
      "maxEventBatchSize": 100,
      "prefetchCount": 300,
      "batchCheckpointFrequency": 1
    },

    // Blob trigger settings
    "blob": {
      "maxDegreeOfParallelism": 8
    },

    // Durable Functions settings
    "durableTask": {
      "maxConcurrentActivityFunctions": 10,
      "maxConcurrentOrchestrators": 10,
      "storageProvider": {
        "type": "azure_storage",
        "connectionStringName": "AzureWebJobsStorage"
      },
      "tracing": {
        "traceInputsAndOutputs": true,
        "traceReplayEvents": false
      }
    }
  },

  // Function timeout
  "functionTimeout": "00:05:00",

  // Health monitor
  "healthMonitor": {
    "enabled": true,
    "healthCheckInterval": "00:00:10",
    "healthCheckWindow": "00:02:00",
    "healthCheckThreshold": 6,
    "counterThreshold": 0.80
  },

  // Singleton configuration
  "singleton": {
    "lockPeriod": "00:00:15",
    "listenerLockPeriod": "00:01:00",
    "listenerLockRecoveryPollingInterval": "00:01:00",
    "lockAcquisitionTimeout": "00:01:00",
    "lockAcquisitionPollingInterval": "00:00:05"
  },

  // Retry policies
  "retry": {
    "strategy": "exponentialBackoff",
    "maxRetryCount": 3,
    "minimumInterval": "00:00:05",
    "maximumInterval": "00:15:00"
  },

  // Aggregator (for batching invocations)
  "aggregator": {
    "batchSize": 1000,
    "flushTimeout": "00:00:30"
  }
}
```

---

## Real-World Scenarios (C# Implementation)

### Scenario 1: E-Commerce Order Processing System

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Extensions.Logging;
using Azure.Messaging.ServiceBus;
using Azure.Storage.Blobs;
using System.Text.Json;

namespace MyFunctionApp.RealWorld
{
    /// <summary>
    /// Complete E-Commerce Order Processing System
    /// Combines multiple triggers, bindings, and orchestrations
    /// </summary>
    public class ECommerceOrderSystem
    {
        private readonly ILogger<ECommerceOrderSystem> _logger;
        private readonly IOrderRepository _orderRepository;
        private readonly IInventoryService _inventoryService;
        private readonly IPaymentService _paymentService;
        private readonly IShippingService _shippingService;
        private readonly INotificationService _notificationService;

        public ECommerceOrderSystem(
            ILogger<ECommerceOrderSystem> logger,
            IOrderRepository orderRepository,
            IInventoryService inventoryService,
            IPaymentService paymentService,
            IShippingService shippingService,
            INotificationService notificationService)
        {
            _logger = logger;
            _orderRepository = orderRepository;
            _inventoryService = inventoryService;
            _paymentService = paymentService;
            _shippingService = shippingService;
            _notificationService = notificationService;
        }

        // === STEP 1: Receive Order via HTTP ===
        [Function(nameof(CreateOrder))]
        public async Task<HttpResponseData> CreateOrder(
            [HttpTrigger(AuthorizationLevel.Function, \"post\", Route = \"orders\")] 
            HttpRequestData req,
            [DurableClient] DurableTaskClient durableClient)
        {
            _logger.LogInformation(\"Received new order request\");

            try
            {
                // Parse request
                var orderRequest = await req.ReadFromJsonAsync<CreateOrderRequest>();

                if (orderRequest == null)
                {
                    var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
                    await badRequest.WriteAsJsonAsync(new { error = \"Invalid request body\" });
                    return badRequest;
                }

                // Validate order
                var validationErrors = ValidateOrder(orderRequest);
                if (validationErrors.Any())
                {
                    var validationError = req.CreateResponse(HttpStatusCode.BadRequest);
                    await validationError.WriteAsJsonAsync(new
                    {
                        error = \"Validation failed\",
                        errors = validationErrors
                    });
                    return validationError;
                }

                // Create order entity
                var order = new Order
                {
                    Id = Guid.NewGuid().ToString(),
                    OrderNumber = GenerateOrderNumber(),
                    CustomerId = orderRequest.CustomerId,
                    CustomerName = orderRequest.CustomerName,
                    CustomerEmail = orderRequest.CustomerEmail,
                    ShippingAddress = orderRequest.ShippingAddress,
                    BillingAddress = orderRequest.BillingAddress,
                    Items = orderRequest.Items.Select(i => new OrderItem
                    {
                        ProductId = i.ProductId,
                        ProductName = i.ProductName,
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice,
                        SubTotal = i.Quantity * i.UnitPrice
                    }).ToList(),
                    SubTotal = orderRequest.Items.Sum(i => i.Quantity * i.UnitPrice),
                    Tax = CalculateTax(orderRequest.Items, orderRequest.ShippingAddress),
                    ShippingCost = CalculateShipping(orderRequest.Items, orderRequest.ShippingAddress),
                    Status = \"Pending\",
                    CreatedAt = DateTime.UtcNow
                };

                order.TotalAmount = order.SubTotal + order.Tax + order.ShippingCost;

                // Save order to database
                await _orderRepository.CreateAsync(order);

                _logger.LogInformation($\"Order created: {order.OrderNumber}\");

                // Start durable orchestration for order processing
                var instanceId = await durableClient.ScheduleNewOrchestrationInstanceAsync(
                    nameof(OrderProcessingOrchestrator),
                    order);

                _logger.LogInformation($\"Started orchestration {instanceId} for order {order.OrderNumber}\");

                // Return response with order details and tracking
                var response = req.CreateResponse(HttpStatusCode.Created);
                response.Headers.Add(\"Location\", $\"/api/orders/{order.Id}\");
                await response.WriteAsJsonAsync(new
                {
                    orderId = order.Id,
                    orderNumber = order.OrderNumber,
                    status = order.Status,
                    totalAmount = order.TotalAmount,
                    estimatedDelivery = DateTime.UtcNow.AddDays(5),
                    orchestrationId = instanceId,
                    trackingUrl = $\"/api/orders/{order.Id}/status\"
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error creating order\");
                var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
                await errorResponse.WriteAsJsonAsync(new { error = \"Failed to create order\" });
                return errorResponse;
            }
        }

        // === STEP 2: Durable Orchestration ===
        [Function(nameof(OrderProcessingOrchestrator))]
        public async Task<OrderProcessingResult> OrderProcessingOrchestrator(
            [OrchestrationTrigger] TaskOrchestrationContext context)
        {
            var order = context.GetInput<Order>();
            var logger = context.CreateReplaySafeLogger<ECommerceOrderSystem>();

            logger.LogInformation($\"Processing order {order.OrderNumber}\");

            var result = new OrderProcessingResult { OrderId = order.Id };

            try
            {
                // === Step 1: Reserve Inventory ===
                logger.LogInformation(\"Step 1: Reserving inventory\");
                var inventoryReservation = await context.CallActivityAsync<InventoryReservationResult>(
                    nameof(ReserveInventoryActivity),
                    order);

                if (!inventoryReservation.Success)
                {
                    // Inventory not available
                    await context.CallActivityAsync(
                        nameof(UpdateOrderStatus),
                        new OrderStatusUpdate
                        {
                            OrderId = order.Id,
                            Status = \"Cancelled\",
                            Reason = \"Insufficient inventory\"
                        });

                    await context.CallActivityAsync(
                        nameof(SendNotification),
                        new OrderNotification
                        {
                            OrderId = order.Id,
                            Type = \"OrderCancelled\",
                            Recipient = order.CustomerEmail,
                            Message = \"Your order has been cancelled due to insufficient inventory.\"
                        });

                    result.Status = \"Cancelled\";
                    result.Message = \"Insufficient inventory\";
                    return result;
                }

                result.ReservationId = inventoryReservation.ReservationId;

                // === Step 2: Process Payment ===
                logger.LogInformation(\"Step 2: Processing payment\");
                var paymentResult = await context.CallActivityAsync<PaymentProcessingResult>(
                    nameof(ProcessPaymentActivity),
                    new PaymentRequest
                    {
                        OrderId = order.Id,
                        Amount = order.TotalAmount,
                        PaymentMethod = order.PaymentMethod,
                        BillingAddress = order.BillingAddress
                    });

                if (!paymentResult.Success)
                {
                    // Payment failed - release inventory
                    logger.LogWarning(\"Payment failed - releasing inventory\");

                    await context.CallActivityAsync(
                        nameof(ReleaseInventoryActivity),
                        inventoryReservation.ReservationId);

                    await context.CallActivityAsync(
                        nameof(UpdateOrderStatus),
                        new OrderStatusUpdate
                        {
                            OrderId = order.Id,
                            Status = \"PaymentFailed\",
                            Reason = paymentResult.ErrorMessage
                        });

                    await context.CallActivityAsync(
                        nameof(SendNotification),
                        new OrderNotification
                        {
                            OrderId = order.Id,
                            Type = \"PaymentFailed\",
                            Recipient = order.CustomerEmail,
                            Message = $\"Payment failed: {paymentResult.ErrorMessage}\"
                        });

                    result.Status = \"PaymentFailed\";
                    result.Message = paymentResult.ErrorMessage;
                    return result;
                }

                result.TransactionId = paymentResult.TransactionId;

                // === Step 3: Update Order Status ===
                await context.CallActivityAsync(
                    nameof(UpdateOrderStatus),
                    new OrderStatusUpdate
                    {
                        OrderId = order.Id,
                        Status = \"Confirmed\",
                        TransactionId = paymentResult.TransactionId
                    });

                // === Step 4: Send Confirmation Email ===
                await context.CallActivityAsync(
                    nameof(SendNotification),
                    new OrderNotification
                    {
                        OrderId = order.Id,
                        Type = \"OrderConfirmed\",
                        Recipient = order.CustomerEmail,
                        Message = \"Your order has been confirmed!\"
                    });

                // === Step 5: Create Shipment (with delay for processing) ===
                logger.LogInformation(\"Step 5: Creating shipment\");
                
                // Simulate processing delay (1 hour in production, 10 seconds for demo)
                await context.CreateTimer(context.CurrentUtcDateTime.AddHours(1), CancellationToken.None);

                var shipmentResult = await context.CallActivityAsync<ShipmentCreationResult>(
                    nameof(CreateShipmentActivity),
                    order);

                result.TrackingNumber = shipmentResult.TrackingNumber;

                // === Step 6: Update Order with Tracking ===
                await context.CallActivityAsync(
                    nameof(UpdateOrderStatus),
                    new OrderStatusUpdate
                    {
                        OrderId = order.Id,
                        Status = \"Shipped\",
                        TrackingNumber = shipmentResult.TrackingNumber
                    });

                // === Step 7: Send Shipping Notification ===
                await context.CallActivityAsync(
                    nameof(SendNotification),
                    new OrderNotification
                    {
                        OrderId = order.Id,
                        Type = \"OrderShipped\",
                        Recipient = order.CustomerEmail,
                        Message = $\"Your order has shipped! Tracking: {shipmentResult.TrackingNumber}\"
                    });

                // === Step 8: Generate Invoice PDF ===
                var invoiceUrl = await context.CallActivityAsync<string>(
                    nameof(GenerateInvoiceActivity),
                    order);

                result.InvoiceUrl = invoiceUrl;

                logger.LogInformation($\"Order {order.OrderNumber} processed successfully\");

                result.Status = \"Completed\";
                result.Message = \"Order processed successfully\";
                return result;
            }
            catch (Exception ex)
            {
                logger.LogError($\"Error processing order: {ex.Message}\");

                // Handle failure - release resources
                if (!string.IsNullOrEmpty(result.ReservationId))
                {
                    await context.CallActivityAsync(
                        nameof(ReleaseInventoryActivity),
                        result.ReservationId);
                }

                await context.CallActivityAsync(
                    nameof(UpdateOrderStatus),
                    new OrderStatusUpdate
                    {
                        OrderId = order.Id,
                        Status = \"Failed\",
                        Reason = \"Processing error\"
                    });

                result.Status = \"Failed\";
                result.Message = ex.Message;
                return result;
            }
        }

        // === Activity Functions ===

        [Function(nameof(ReserveInventoryActivity))]
        public async Task<InventoryReservationResult> ReserveInventoryActivity(
            [ActivityTrigger] Order order)
        {
            _logger.LogInformation($\"Reserving inventory for order {order.OrderNumber}\");

            try
            {
                var reservationId = await _inventoryService.ReserveAsync(
                    order.Items.Select(i => new InventoryReservationItem
                    {
                        ProductId = i.ProductId,
                        Quantity = i.Quantity
                    }).ToList());

                return new InventoryReservationResult
                {
                    Success = true,
                    ReservationId = reservationId
                };
            }
            catch (InsufficientInventoryException ex)
            {
                _logger.LogWarning($\"Insufficient inventory: {ex.Message}\");
                return new InventoryReservationResult
                {
                    Success = false,
                    ErrorMessage = ex.Message
                };
            }
        }

        [Function(nameof(ProcessPaymentActivity))]
        public async Task<PaymentProcessingResult> ProcessPaymentActivity(
            [ActivityTrigger] PaymentRequest payment)
        {
            _logger.LogInformation($\"Processing payment for order {payment.OrderId}\");

            try
            {
                var transactionId = await _paymentService.ProcessPaymentAsync(payment);

                return new PaymentProcessingResult
                {
                    Success = true,
                    TransactionId = transactionId
                };
            }
            catch (PaymentException ex)
            {
                _logger.LogError(ex, \"Payment processing failed\");
                return new PaymentProcessingResult
                {
                    Success = false,
                    ErrorMessage = ex.Message
                };
            }
        }

        [Function(nameof(CreateShipmentActivity))]
        public async Task<ShipmentCreationResult> CreateShipmentActivity(
            [ActivityTrigger] Order order)
        {
            _logger.LogInformation($\"Creating shipment for order {order.OrderNumber}\");

            var trackingNumber = await _shippingService.CreateShipmentAsync(new ShipmentRequest
            {
                OrderId = order.Id,
                OrderNumber = order.OrderNumber,
                RecipientName = order.CustomerName,
                ShippingAddress = order.ShippingAddress,
                Items = order.Items.Select(i => new ShipmentItem
                {
                    ProductId = i.ProductId,
                    Quantity = i.Quantity,
                    Weight = 1.0m // In real app, get from product catalog
                }).ToList()
            });

            return new ShipmentCreationResult
            {
                Success = true,
                TrackingNumber = trackingNumber
            };
        }

        [Function(nameof(GenerateInvoiceActivity))]
        public async Task<string> GenerateInvoiceActivity([ActivityTrigger] Order order)
        {
            _logger.LogInformation($\"Generating invoice for order {order.OrderNumber}\");

            // Generate PDF invoice
            var invoicePdf = GenerateInvoicePdf(order);

            // Upload to blob storage
            var blobServiceClient = new BlobServiceClient(Environment.GetEnvironmentVariable(\"AzureWebJobsStorage\"));
            var containerClient = blobServiceClient.GetBlobContainerClient(\"invoices\");
            await containerClient.CreateIfNotExistsAsync();

            var blobName = $\"{order.OrderNumber}-{DateTime.UtcNow:yyyyMMdd}.pdf\";
            var blobClient = containerClient.GetBlobClient(blobName);

            await blobClient.UploadAsync(new BinaryData(invoicePdf), overwrite: true);

            return blobClient.Uri.ToString();
        }

        [Function(nameof(ReleaseInventoryActivity))]
        public async Task ReleaseInventoryActivity([ActivityTrigger] string reservationId)
        {
            _logger.LogInformation($\"Releasing inventory reservation {reservationId}\");
            await _inventoryService.ReleaseAsync(reservationId);
        }

        [Function(nameof(UpdateOrderStatus))]
        public async Task UpdateOrderStatus([ActivityTrigger] OrderStatusUpdate update)
        {
            _logger.LogInformation($\"Updating order {update.OrderId} status to {update.Status}\");

            var order = await _orderRepository.GetByIdAsync(update.OrderId);
            if (order != null)
            {
                order.Status = update.Status;
                order.StatusReason = update.Reason;
                order.TransactionId = update.TransactionId;
                order.TrackingNumber = update.TrackingNumber;
                order.UpdatedAt = DateTime.UtcNow;

                await _orderRepository.UpdateAsync(order);
            }
        }

        [Function(nameof(SendNotification))]
        public async Task SendNotification([ActivityTrigger] OrderNotification notification)
        {
            _logger.LogInformation($\"Sending {notification.Type} notification for order {notification.OrderId}\");
            await _notificationService.SendEmailAsync(
                notification.Recipient,
                GetEmailSubject(notification.Type),
                notification.Message);
        }

        // === Step 3: Query Order Status ===
        [Function(nameof(GetOrderStatus))]
        public async Task<HttpResponseData> GetOrderStatus(
            [HttpTrigger(AuthorizationLevel.Function, \"get\", Route = \"orders/{orderId}/status\")] 
            HttpRequestData req,
            string orderId)
        {
            _logger.LogInformation($\"Getting status for order {orderId}\");

            try
            {
                var order = await _orderRepository.GetByIdAsync(orderId);

                if (order == null)
                {
                    var notFound = req.CreateResponse(HttpStatusCode.NotFound);
                    await notFound.WriteAsJsonAsync(new { error = \"Order not found\" });
                    return notFound;
                }

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(new
                {
                    orderId = order.Id,
                    orderNumber = order.OrderNumber,
                    status = order.Status,
                    createdAt = order.CreatedAt,
                    updatedAt = order.UpdatedAt,
                    trackingNumber = order.TrackingNumber,
                    estimatedDelivery = CalculateEstimatedDelivery(order)
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $\"Error getting order status: {orderId}\");
                var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
                await errorResponse.WriteAsJsonAsync(new { error = \"Failed to get order status\" });
                return errorResponse;
            }
        }

        // === Step 4: Handle Shipment Updates via Service Bus ===
        [Function(nameof(ProcessShipmentUpdate))]
        public async Task ProcessShipmentUpdate(
            [ServiceBusTrigger(\"shipment-updates\", Connection = \"ServiceBusConnection\")] 
            ServiceBusReceivedMessage message)
        {
            _logger.LogInformation($\"Processing shipment update: {message.MessageId}\");

            try
            {
                var update = JsonSerializer.Deserialize<ShipmentUpdate>(message.Body);

                var order = await _orderRepository.GetByTrackingNumberAsync(update.TrackingNumber);

                if (order != null)
                {
                    var newStatus = MapShipmentStatusToOrderStatus(update.Status);
                    
                    order.Status = newStatus;
                    order.UpdatedAt = DateTime.UtcNow;
                    await _orderRepository.UpdateAsync(order);

                    // Send notification to customer
                    await _notificationService.SendEmailAsync(
                        order.CustomerEmail,
                        $\"Order Update: {newStatus}\",
                        $\"Your order {order.OrderNumber} is now {newStatus}. \" +
                        $\"Current location: {update.Location}\");

                    _logger.LogInformation($\"Updated order {order.OrderNumber} to status {newStatus}\");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error processing shipment update\");
                throw; // Will retry based on Service Bus configuration
            }
        }

        // Helper methods
        private List<string> ValidateOrder(CreateOrderRequest order)
        {
            var errors = new List<string>();

            if (string.IsNullOrEmpty(order.CustomerEmail))
                errors.Add(\"Customer email is required\");

            if (order.Items == null || !order.Items.Any())
                errors.Add(\"Order must contain at least one item\");

            if (string.IsNullOrEmpty(order.ShippingAddress))
                errors.Add(\"Shipping address is required\");

            return errors;
        }

        private string GenerateOrderNumber()
        {
            return $\"ORD-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 8).ToUpper()}\";
        }

        private decimal CalculateTax(List<CreateOrderItemRequest> items, string address)
        {
            // Simplified tax calculation
            var subtotal = items.Sum(i => i.Quantity * i.UnitPrice);
            return subtotal * 0.08m; // 8% tax
        }

        private decimal CalculateShipping(List<CreateOrderItemRequest> items, string address)
        {
            // Simplified shipping calculation
            var totalWeight = items.Sum(i => i.Quantity);
            return totalWeight * 2.50m;
        }

        private byte[] GenerateInvoicePdf(Order order)
        {
            // In real implementation, use a PDF library like iTextSharp or QuestPDF
            return Encoding.UTF8.GetBytes($\"Invoice for order {order.OrderNumber}\");
        }

        private string GetEmailSubject(string notificationType)
        {
            return notificationType switch
            {
                \"OrderConfirmed\" => \"Order Confirmation\",
                \"OrderShipped\" => \"Your Order Has Shipped!\",
                \"OrderDelivered\" => \"Your Order Has Been Delivered\",
                \"OrderCancelled\" => \"Order Cancelled\",
                \"PaymentFailed\" => \"Payment Failed\",
                _ => \"Order Update\"
            };
        }

        private DateTime? CalculateEstimatedDelivery(Order order)
        {
            if (order.Status == \"Shipped\" && order.UpdatedAt.HasValue)
            {
                return order.UpdatedAt.Value.AddDays(3); // 3 days for delivery
            }
            return null;
        }

        private string MapShipmentStatusToOrderStatus(string shipmentStatus)
        {
            return shipmentStatus switch
            {
                \"InTransit\" => \"Shipped\",
                \"OutForDelivery\" => \"OutForDelivery\",
                \"Delivered\" => \"Delivered\",
                _ => \"Shipped\"
            };
        }
    }

    // Models for E-Commerce System
    public class CreateOrderRequest
    {
        public string CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string CustomerEmail { get; set; }
        public string ShippingAddress { get; set; }
        public string BillingAddress { get; set; }
        public List<CreateOrderItemRequest> Items { get; set; }
        public string PaymentMethod { get; set; }
    }

    public class CreateOrderItemRequest
    {
        public string ProductId { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
    }

    public class OrderProcessingResult
    {
        public string OrderId { get; set; }
        public string Status { get; set; }
        public string Message { get; set; }
        public string ReservationId { get; set; }
        public string TransactionId { get; set; }
        public string TrackingNumber { get; set; }
        public string InvoiceUrl { get; set; }
    }

    public class InventoryReservationResult
    {
        public bool Success { get; set; }
        public string ReservationId { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class PaymentProcessingResult
    {
        public bool Success { get; set; }
        public string TransactionId { get; set; }
        public string ErrorMessage { get; set; }
    }

    public class ShipmentCreationResult
    {
        public bool Success { get; set; }
        public string TrackingNumber { get; set; }
    }

    public class OrderStatusUpdate
    {
        public string OrderId { get; set; }
        public string Status { get; set; }
        public string Reason { get; set; }
        public string TransactionId { get; set; }
        public string TrackingNumber { get; set; }
    }

    public class ShipmentUpdate
    {
        public string TrackingNumber { get; set; }
        public string Status { get; set; }
        public string Location { get; set; }
        public DateTime Timestamp { get; set; }
    }

    public class InventoryReservationItem
    {
        public string ProductId { get; set; }
        public int Quantity { get; set; }
    }

    public class ShipmentItem
    {
        public string ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal Weight { get; set; }
    }

    // Custom Exceptions
    public class InsufficientInventoryException : Exception
    {
        public InsufficientInventoryException(string message) : base(message) { }
    }

    public class PaymentException : Exception
    {
        public PaymentException(string message) : base(message) { }
    }

    // Service Interfaces (implement these based on your architecture)
    public interface IOrderRepository
    {
        Task<Order> GetByIdAsync(string orderId);
        Task<Order> GetByTrackingNumberAsync(string trackingNumber);
        Task CreateAsync(Order order);
        Task UpdateAsync(Order order);
    }

    public interface IInventoryService
    {
        Task<string> ReserveAsync(List<InventoryReservationItem> items);
        Task ReleaseAsync(string reservationId);
    }

    public interface IPaymentService
    {
        Task<string> ProcessPaymentAsync(PaymentRequest payment);
    }

    public interface IShippingService
    {
        Task<string> CreateShipmentAsync(ShipmentRequest shipment);
    }

    public interface INotificationService
    {
        Task SendEmailAsync(string recipient, string subject, string message);
    }
}
```

---

## Monitoring & Observability (C# Implementation)

### 1. Application Insights Integration

```csharp
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Diagnostics;

namespace MyFunctionApp.Observability
{
    /// <summary>
    /// Comprehensive monitoring and observability implementation
    /// </summary>
    public class MonitoredFunction
    {
        private readonly ILogger<MonitoredFunction> _logger;
        private readonly TelemetryClient _telemetryClient;

        public MonitoredFunction(
            ILogger<MonitoredFunction> logger,
            TelemetryClient telemetryClient)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
        }

        [Function(nameof(ProcessWithTelemetry))]
        public async Task<HttpResponseData> ProcessWithTelemetry(
            [HttpTrigger(AuthorizationLevel.Function, \"post\")] HttpRequestData req)
        {
            var stopwatch = Stopwatch.StartNew();
            var operationId = Activity.Current?.Id ?? Guid.NewGuid().ToString();

            _logger.LogInformation(\"[{OperationId}] Starting request processing\", operationId);

            // Track custom event
            _telemetryClient.TrackEvent(\"OrderProcessingStarted\", new Dictionary<string, string>
            {
                { \"OperationId\", operationId },
                { \"Timestamp\", DateTime.UtcNow.ToString(\"o\") }
            });

            try
            {
                var requestBody = await req.ReadAsStringAsync();

                // Track custom metric - request size
                _telemetryClient.TrackMetric(\"RequestSize\", requestBody?.Length ?? 0);

                // Simulate processing with detailed tracking
                using (var operation = _telemetryClient.StartOperation<RequestTelemetry>(\"ProcessOrder\"))
                {
                    operation.Telemetry.Properties[\"OrderType\"] = \"Standard\";
                    operation.Telemetry.Properties[\"Source\"] = \"WebAPI\";

                    // Step 1: Validate (track duration)
                    var validateStopwatch = Stopwatch.StartNew();
                    await ValidateRequest(requestBody);
                    validateStopwatch.Stop();
                    _telemetryClient.TrackMetric(\"ValidationDuration\", validateStopwatch.ElapsedMilliseconds);

                    // Step 2: Process (track duration)
                    var processStopwatch = Stopwatch.StartNew();
                    var result = await ProcessRequest(requestBody);
                    processStopwatch.Stop();
                    _telemetryClient.TrackMetric(\"ProcessingDuration\", processStopwatch.ElapsedMilliseconds);

                    // Track dependency - Database call
                    var dbStopwatch = Stopwatch.StartNew();
                    var dependencyTelemetry = new DependencyTelemetry
                    {
                        Name = \"SaveToDatabase\",
                        Type = \"SQL\",
                        Target = \"OrdersDB\",
                        Data = \"INSERT INTO Orders\",
                        Timestamp = DateTimeOffset.UtcNow,
                        Duration = TimeSpan.FromMilliseconds(0)
                    };

                    try
                 {
                        await SaveToDatabase(result);
                        dbStopwatch.Stop();
                        dependencyTelemetry.Duration = dbStopwatch.Elapsed;
                        dependencyTelemetry.Success = true;
                    }
                    catch (Exception ex)
                    {
                        dependencyTelemetry.Success = false;
                        dependencyTelemetry.ResultCode = \"Error\";
                        throw;
                    }
                    finally
                    {
                        _telemetryClient.TrackDependency(dependencyTelemetry);
                    }

                    operation.Telemetry.Success = true;
                }

                stopwatch.Stop();

                // Track successful completion
                _telemetryClient.TrackEvent(\"OrderProcessingCompleted\", new Dictionary<string, string>
                {
                    { \"OperationId\", operationId },
                    { \"Duration\", stopwatch.ElapsedMilliseconds.ToString() }
                },
                new Dictionary<string, double>
                {
                    { \"ProcessingTimeMs\", stopwatch.ElapsedMilliseconds }
                });

                _logger.LogInformation(
                    \"[{OperationId}] Request processed successfully in {Duration}ms\",
                    operationId,
                    stopwatch.ElapsedMilliseconds);

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(new { success = true, operationId });
                return response;
            }
            catch (ValidationException ex)
            {
                stopwatch.Stop();

                _telemetryClient.TrackException(ex, new Dictionary<string, string>
                {
                    { \"OperationId\", operationId },
                    { \"ExceptionType\", \"Validation\" },
                    { \"Duration\", stopwatch.ElapsedMilliseconds.ToString() }
                });

                _logger.LogWarning(ex, \"[{OperationId}] Validation failed\", operationId);

                var response = req.CreateResponse(HttpStatusCode.BadRequest);
                await response.WriteAsJsonAsync(new { error = ex.Message, operationId });
                return response;
            }
            catch (Exception ex)
            {
                stopwatch.Stop();

                _telemetryClient.TrackException(ex, new Dictionary<string, string>
                {
                    { \"OperationId\", operationId },
                    { \"FunctionName\", nameof(ProcessWithTelemetry) },
                    { \"Duration\", stopwatch.ElapsedMilliseconds.ToString() }
                });

                _logger.LogError(ex, \"[{OperationId}] Error processing request\", operationId);

                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteAsJsonAsync(new { error = \"Internal server error\", operationId });
                return response;
            }
        }

        // Custom metrics tracking
        [Function(nameof(TrackCustomMetrics))]
        [FixedDelayRetry(3, \"00:00:05\")]
        public async Task TrackCustomMetrics(
            [TimerTrigger(\"0 */5 * * * *\")] TimerInfo timer)
        {
            _logger.LogInformation(\"Tracking custom metrics\");

            try
            {
                // Track business metrics
                var activeOrders = await GetActiveOrdersCount();
                _telemetryClient.TrackMetric(\"ActiveOrders\", activeOrders);

                var pendingPayments = await GetPendingPaymentsCount();
                _telemetryClient.TrackMetric(\"PendingPayments\", pendingPayments);

                var averageOrderValue = await GetAverageOrderValue();
                _telemetryClient.TrackMetric(\"AverageOrderValue\", (double)averageOrderValue);

                // Track system health
                var queueDepth = await GetQueueDepth();
                _telemetryClient.TrackMetric(\"QueueDepth\", queueDepth);

                var memoryUsage = GC.GetTotalMemory(false) / 1024 / 1024; // MB
                _telemetryClient.TrackMetric(\"MemoryUsageMB\", memoryUsage);

                _logger.LogInformation(
                    \"Metrics tracked - Active Orders: {ActiveOrders}, Pending Payments: {PendingPayments}\",
                    activeOrders,
                    pendingPayments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, \"Error tracking metrics\");
                _telemetryClient.TrackException(ex);
            }
        }

        // Health check endpoint
        [Function(nameof(HealthCheck))]
        public async Task<HttpResponseData> HealthCheck(
            [HttpTrigger(AuthorizationLevel.Anonymous, \"get\", Route = \"health\")] 
            HttpRequestData req)
        {
            var health = new
            {
                status = \"Healthy\",
                timestamp = DateTime.UtcNow,
                checks = new
                {
                    database = await CheckDatabaseHealth(),
                    storage = await CheckStorageHealth(),
                    external_api = await CheckExternalApiHealth()
                }
            };

            var allHealthy = health.checks.database && health.checks.storage && health.checks.external_api;

            var response = req.CreateResponse(allHealthy ? HttpStatusCode.OK : HttpStatusCode.ServiceUnavailable);
            await response.WriteAsJsonAsync(health);

            // Track availability
            _telemetryClient.TrackAvailability(
                \"HealthCheck\",
                DateTimeOffset.UtcNow,
                TimeSpan.FromMilliseconds(100),
                \"HealthEndpoint\",
                allHealthy);

            return response;
        }

        // Helper methods
        private async Task ValidateRequest(string requestBody)
        {
            await Task.Delay(50); // Simulate validation
            if (string.IsNullOrEmpty(requestBody))
                throw new ValidationException(\"Request body cannot be empty\");
        }

        private async Task<object> ProcessRequest(string requestBody)
        {
            await Task.Delay(200); // Simulate processing
            return new { id = Guid.NewGuid(), processed = true };
        }

        private async Task SaveToDatabase(object data)
        {
            await Task.Delay(100); // Simulate database save
        }

        private async Task<int> GetActiveOrdersCount()
        {
            await Task.Delay(50);
            return new Random().Next(100, 500);
        }

        private async Task<int> GetPendingPaymentsCount()
        {
            await Task.Delay(50);
            return new Random().Next(10, 50);
        }

        private async Task<decimal> GetAverageOrderValue()
        {
            await Task.Delay(50);
            return new Random().Next(50, 200);
        }

        private async Task<int> GetQueueDepth()
        {
            await Task.Delay(50);
            return new Random().Next(0, 100);
        }

        private async Task<bool> CheckDatabaseHealth()
        {
            await Task.Delay(50);
            return true;
        }

        private async Task<bool> CheckStorageHealth()
        {
            await Task.Delay(50);
            return true;
        }

        private async Task<bool> CheckExternalApiHealth()
        {
            await Task.Delay(50);
            return true;
        }
    }
}
```

### 2. Structured Logging

```csharp
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Text.Json;

namespace MyFunctionApp.Observability
{
    /// <summary>
    /// Structured logging best practices
    /// </summary>
    public class StructuredLoggingFunction
    {
        private readonly ILogger<StructuredLoggingFunction> _logger;

        public StructuredLoggingFunction(ILogger<StructuredLoggingFunction> logger)
        {
            _logger = logger;
        }

        [Function(nameof(ProcessOrderWithLogging))]
        public async Task<HttpResponseData> ProcessOrderWithLogging(
            [HttpTrigger(AuthorizationLevel.Function, \"post\")] HttpRequestData req)
        {
            var correlationId = req.Headers.Contains(\"x-correlation-id\")
                ? req.Headers.GetValues(\"x-correlation-id\").FirstOrDefault()
                : Guid.NewGuid().ToString();

            using (_logger.BeginScope(new Dictionary<string, object>
            {
                [\"CorrelationId\"] = correlationId,
                [\"FunctionName\"] = nameof(ProcessOrderWithLogging)
            }))
            {
                _logger.LogInformation(
                    \"Processing order request - CorrelationId: {CorrelationId}, Method: {Method}, URL: {Url}\",
                    correlationId,
                    req.Method,
                    req.Url);

                try
                {
                    var order = await req.ReadFromJsonAsync<Order>();

                    _logger.LogInformation(
                        \"Order received - OrderId: {OrderId}, CustomerId: {CustomerId}, Amount: {Amount}, ItemCount: {ItemCount}\",
                        order.Id,
                        order.CustomerId,
                        order.TotalAmount,
                        order.Items?.Count ?? 0);

                    // Validate order
                    if (order.TotalAmount <= 0)
                    {
                        _logger.LogWarning(
                            \"Invalid order amount - OrderId: {OrderId}, Amount: {Amount}\",
                            order.Id,
                            order.TotalAmount);

                        var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
                        await badRequest.WriteAsJsonAsync(new { error = \"Invalid amount\" });
                        return badRequest;
                    }

                    // Process order (simulated)
                    await Task.Delay(100);

                    _logger.LogInformation(
                        \"Order processed successfully - OrderId: {OrderId}, Duration: {DurationMs}ms\",
                        order.Id,
                        100);

                    // Log important business event
                    _logger.LogInformation(
                        \"BUSINESS_EVENT: OrderCompleted - OrderId: {OrderId}, Value: {OrderValue}, Customer: {CustomerId}\",
                        order.Id,
                        order.TotalAmount,
                        order.CustomerId);

                    var response = req.CreateResponse(HttpStatusCode.OK);
                    await response.WriteAsJsonAsync(new
                    {
                        success = true,
                        orderId = order.Id,
                        correlationId
                    });

                    return response;
                }
                catch (JsonException ex)
                {
                    _logger.LogError(ex,
                        \"Invalid JSON in request - CorrelationId: {CorrelationId}\",
                        correlationId);

                    var badRequest = req.CreateResponse(HttpStatusCode.BadRequest);
                    await badRequest.WriteAsJsonAsync(new { error = \"Invalid JSON\" });
                    return badRequest;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex,
                        \"Unhandled error processing order - CorrelationId: {CorrelationId}, ExceptionType: {ExceptionType}\",
                        correlationId,
                        ex.GetType().Name);

                    var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
                    await errorResponse.WriteAsJsonAsync(new { error = \"Internal server error\", correlationId });
                    return errorResponse;
                }
            }
        }
    }
}
```

---

## Deployment Methods (C# Implementation)

### 1. Azure DevOps YAML Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  azureSubscription: 'Azure-ServiceConnection'
  functionAppName: 'my-function-app'
  dotnetVersion: '8.x'

stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - task: UseDotNet@2
      displayName: 'Install .NET SDK'
      inputs:
        version: $(dotnetVersion)

    - task: DotNetCoreCLI@2
      displayName: 'Restore NuGet packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration)'

    - task: DotNetCoreCLI@2
      displayName: 'Run unit tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration $(buildConfiguration) --collect:\"XPlat Code Coverage\"'

    - task: PublishCodeCoverageResults@1
      displayName: 'Publish code coverage'
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(Agent.TempDirectory)/**/*cobertura.xml'

    - task: DotNetCoreCLI@2
      displayName: 'Publish Function App'
      inputs:
        command: 'publish'
        publishWebProjects: false
        projects: '**/MyFunctionApp.csproj'
        arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'
        zipAfterPublish: true

    - task: PublishBuildArtifacts@1
      displayName: 'Publish artifacts'
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'drop'

- stage: DeployDev
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
  dependsOn: Build
  jobs:
  - deployment: DeployDev
    environment: 'Development'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureFunctionApp@1
            displayName: 'Deploy to Dev'
            inputs:
              azureSubscription: $(azureSubscription)
              appType: 'functionAppLinux'
              appName: '$(functionAppName)-dev'
              package: '$(Pipeline.Workspace)/drop/*.zip'
              deploymentMethod: 'zipDeploy'
              appSettings: |
                -FUNCTIONS_WORKER_RUNTIME dotnet-isolated
                -FUNCTIONS_EXTENSION_VERSION ~4
                -AzureWebJobsStorage $(DevStorageConnectionString)
                -APPINSIGHTS_INSTRUMENTATIONKEY $(DevAppInsightsKey)

- stage: DeployProd
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  dependsOn: Build
  jobs:
  - deployment: DeployProd
    environment: 'Production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureFunctionApp@1
            displayName: 'Deploy to Production'
            inputs:
              azureSubscription: $(azureSubscription)
              appType: 'functionAppLinux'
              appName: '$(functionAppName)-prod'
              package: '$(Pipeline.Workspace)/drop/*.zip'
              deploymentMethod: 'zipDeploy'
              appSettings: |
                -FUNCTIONS_WORKER_RUNTIME dotnet-isolated
                -FUNCTIONS_EXTENSION_VERSION ~4
                -AzureWebJobsStorage $(ProdStorageConnectionString)
                -APPINSIGHTS_INSTRUMENTATIONKEY $(ProdAppInsightsKey)
```

### 2. GitHub Actions Workflow

```yaml
# .github/workflows/deploy-functions.yml
name: Deploy Azure Functions

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  AZURE_FUNCTIONAPP_NAME: my-function-app
  AZURE_FUNCTIONAPP_PACKAGE_PATH: '.'
  DOTNET_VERSION: '8.0.x'

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --configuration Release --no-restore

    - name: Test
      run: dotnet test --no-build --verbosity normal --collect:\"XPlat Code Coverage\"

    - name: Upload coverage reports
      uses: codecov/codecov-action@v3

    - name: Publish
      run: dotnet publish --configuration Release --output ./output

    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: function-app
        path: ./output

  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    needs: build-and-test
    runs-on: ubuntu-latest
    environment:
      name: Development
      url: https://${{ env.AZURE_FUNCTIONAPP_NAME }}-dev.azurewebsites.net
    steps:
    - name: Download artifact
      uses: actions/download-artifact@v3
      with:
        name: function-app
        path: ./output

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS_DEV }}

    - name: Deploy to Azure Functions
      uses: Azure/functions-action@v1
      with:
        app-name: ${{ env.AZURE_FUNCTIONAPP_NAME }}-dev
        package: './output'

  deploy-prod:
    if: github.ref == 'refs/heads/main'
    needs: build-and-test
    runs-on: ubuntu-latest
    environment:
      name: Production
      url: https://${{ env.AZURE_FUNCTIONAPP_NAME }}.azurewebsites.net
    steps:
    - name: Download artifact
      uses: actions/download-artifact@v3
      with:
        name: function-app
        path: ./output

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS_PROD }}

    - name: Deploy to Azure Functions
      uses: Azure/functions-action@v1
      with:
        app-name: ${{ env.AZURE_FUNCTIONAPP_NAME }}
        package: './output'
```

---

## Best Practices & Patterns (C# Summary)

### Key Takeaways

```csharp
// ✅ DO: Use dependency injection
public class GoodFunction
{
    private readonly ILogger<GoodFunction> _logger;
    private readonly IOrderService _orderService;

    public GoodFunction(ILogger<GoodFunction> logger, IOrderService orderService)
    {
        _logger = logger;
        _orderService = orderService;
    }
}

// ❌ DON'T: Use static dependencies
public static class BadFunction
{
    private static HttpClient _httpClient = new HttpClient(); // Memory leak!
}

// ✅ DO: Use async/await properly
public async Task<HttpResponseData> ProcessAsync(HttpRequestData req)
{
    var result = await _service.GetDataAsync();
    return await CreateResponseAsync(req, result);
}

// ❌ DON'T: Block async calls
public HttpResponseData ProcessSync(HttpRequestData req)
{
    var result = _service.GetDataAsync().Result; // Deadlock risk!
    return CreateResponseAsync(req, result).Result;
}

// ✅ DO: Handle exceptions gracefully
try
{
    await ProcessOrderAsync(order);
}
catch (ValidationException ex)
{
    _logger.LogWarning(ex, \"Validation failed for order {OrderId}\", order.Id);
    return BadRequest(\"Validation failed\");
}

// ✅ DO: Use structured logging
_logger.LogInformation(
    \"Order processed - OrderId: {OrderId}, Amount: {Amount}\",
    order.Id,
    order.TotalAmount);

// ❌ DON'T: Use string interpolation in logs
_logger.LogInformation($\"Order {order.Id} processed\"); // Poor for querying

// ✅ DO: Use Managed Identity
var credential = new DefaultAzureCredential();
var blobClient = new BlobServiceClient(endpoint, credential);

// ❌ DON'T: Store secrets in code
var connectionString = \"DefaultEndpointsProtocol=https;AccountName=...\"; // Bad!
```

---
Perfect 👌
Let’s now build the **internal execution mental model** of Azure Functions when it scales from **1 instance → 10 instances**, in a very simple way.

---

# 🧠 Mental Model: What Happens When Azure Function Scales?

We’ll use:

## Azure Functions

## Azure Storage

---

# Step 0️⃣ — Initial State (1 Instance)

Imagine:

* You have a Queue-triggered Function.
* 1 Function instance is running.
* It is reading messages from Service Bus or Storage Queue.

The Function instance:

* Pulls a message
* Locks it (Peek-lock)
* Processes it
* Completes it

At this point:

* It writes checkpoints/state in Storage.
* Everything is fine.

---

# Step 1️⃣ — Load Increases

Suddenly:

* 1,000 new messages arrive.
* Processing time per message = 2 seconds.
* Backlog increases.

Azure detects:

* Queue length growing
* Processing lag

Now the **Scale Controller** kicks in.

---

# Step 2️⃣ — Scale Controller Decision

Azure Functions has an internal component called:

👉 Scale Controller

It checks:

* Queue depth
* Message age
* CPU usage
* Execution latency

It decides:

> “1 worker is not enough. Let’s scale to 5.”

---

# Step 3️⃣ — New Instances Spin Up

Azure creates:

* Instance 2
* Instance 3
* Instance 4
* Instance 5

Now you have 5 temporary workers.

Remember:

They are stateless.

So how do they avoid processing the same message?

---

# Step 4️⃣ — Coordination via Storage

This is where:

## Azure Storage becomes critical.

Each instance:

* Uses blob leases for locking
* Stores checkpoint info
* Tracks processed items

Storage acts like:

> A distributed coordination board

Without it:

* Multiple instances might process same message
* Timer triggers may fire twice
* Durable workflows would break

---

# Step 5️⃣ — Processing in Parallel

Now:

5 instances process messages concurrently.

Queue reduces faster.

Backlog clears.

---

# Step 6️⃣ — Scale Down

When:

* Queue depth decreases
* Load normalizes

Azure decides:

> “No need for 5 workers.”

It scales down to 1.

Other 4 instances disappear.

Since state is in Storage:

Nothing is lost.

---

# 🎯 Key Insight

Azure Functions are:

> Disposable compute units

Storage Account is:

> The shared distributed brain

---

# 🧠 Even Simpler Model

Imagine:

Function instances = Uber drivers 🚗
Storage account = Uber’s central system 🖥

Drivers come and go.
Central system keeps track of:

* Who took which ride
* What’s pending
* What’s completed

Without central system → chaos.

---

# ⚠️ What If Storage Is Slow?

Then:

* Scale decisions slow down
* Lock acquisition slows
* Timer triggers misfire
* Durable Functions become sluggish

That’s why architect best practice is:

* Same region storage
* Dedicated storage account
* Monitor throttling metrics

---

# 🚀 Bonus: Durable Function Scaling

If using Durable Functions:

Each orchestration state is written to:

* Tables
* Blobs
* Queues

Heavy workflow = heavy storage I/O.

Storage performance directly affects throughput.

---

# 🔥 Final One-Line Mental Model

> Scaling Azure Functions works because multiple stateless workers coordinate using Azure Storage as a distributed control plane.

---

If you want next, I can explain:

* What happens internally during cold start
* Why Premium plan reduces cold start
* Deep dive: Scale Controller internals
* Or how this differs from Kubernetes HPA

Tell me which direction you want 👌


## Conclusion

This comprehensive guide covered Azure Functions implementation with:

✅ **All Trigger Types** - HTTP, Timer, Queue, Blob, Service Bus, Event Grid, Event Hub, Cosmos DB
✅ **Durable Functions** - Orchestration patterns (Chaining, Fan-out/Fan-in, Human Interaction, Monitor)
✅ **Complete Testing** - Unit tests, Integration tests, Durable Functions tests
✅ **Security** - Managed Identity, JWT validation, Azure AD B2C, API Keys
✅ **Error Handling** - Global middleware, custom exceptions, retry policies
✅ **Monitoring** - Application Insights, structured logging, custom metrics, health checks
✅ **Platform Features** - CORS, Proxies, Custom Handlers, Deployment Slots
✅ **Network Configuration** - VNet Integration, Private Endpoints, IP Restrictions
✅ **Authentication** - Easy Auth, Custom Domains, SSL/TLS, Function Keys
✅ **Advanced Configuration** - Application Settings, Warm-up Triggers, host.json
✅ **Real-World Scenario** - Complete E-Commerce order processing system
✅ **Deployment** - Azure DevOps, GitHub Actions, IaC
✅ **Best Practices** - DI, async/await, logging, security

### Quick Reference: Common Tasks

| Task | Command/Configuration |
|------|----------------------|
| **Enable CORS** | Portal → CORS → Add origins |
| **Add App Setting** | `az functionapp config appsettings set --settings "KEY=value"` |
| **Create Deployment Slot** | Portal → Deployment slots → Add Slot |
| **Enable VNet Integration** | `az functionapp vnet-integration add` |
| **Add Custom Domain** | `az functionapp config hostname add` |
| **Enable HTTPS Only** | `az functionapp update --set httpsOnly=true` |
| **Add IP Restriction** | `az functionapp config access-restriction add` |
| **View Logs** | Portal → Log Stream or `func azure functionapp logstream` |
| **Swap Slots** | `az functionapp deployment slot swap` |

### Additional Resources

- [Official Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Functions Best Practices](https://docs.microsoft.com/azure/azure-functions/functions-best-practices)
- [Durable Functions Documentation](https://docs.microsoft.com/azure/azure-functions/durable/)
- [Application Insights for Azure Functions](https://docs.microsoft.com/azure/azure-functions/functions-monitoring)
- [Azure Functions on GitHub](https://github.com/Azure/Azure-Functions)
- [Azure Functions Host Settings Reference](https://docs.microsoft.com/azure/azure-functions/functions-host-json)

**Happy Coding! 🚀**


---

# AZURE FUNCTIONS — COMPLETE MINDMAP (Quick Review & Recall)

```
AZURE FUNCTIONS
│
├── 1. WHAT IS IT?
│   ├── Serverless compute — run code without managing servers
│   ├── Event-driven — triggered by HTTP, timer, queue, blob, etc.
│   ├── Stateless by default (Durable Functions = stateful)
│   ├── Pay per execution (Consumption plan)
│   └── Auto-scales to zero
│
├── 2. CORE COMPONENTS
│   ├── Trigger        — what starts the function (exactly 1 per function)
│   ├── Input Binding  — pull data in (optional, multiple)
│   ├── Output Binding — push data out (optional, multiple)
│   ├── host.json      — global config (retry, timeout, logging)
│   ├── local.settings.json — local env vars (not deployed)
│   └── Function App   — container for multiple functions (same plan/storage)
│
├── 3. TRIGGERS (8 TYPES)
│   ├── HTTP         — REST API, webhooks
│   │   ├── Auth levels: Anonymous / Function / Admin
│   │   └── Returns HttpResponseData / IActionResult
│   ├── Timer        — scheduled jobs (CRON expression)
│   │   └── "0 */5 * * * *" = every 5 min
│   ├── Blob Storage — fires on blob create/update
│   │   └── Path pattern: "container/{name}"
│   ├── Queue Storage — Azure Storage Queue messages
│   │   └── Auto-retries, poison queue after max retries
│   ├── Service Bus  — enterprise messaging
│   │   ├── Queue or Topic/Subscription
│   │   └── Supports sessions, dead-letter
│   ├── Event Grid   — event routing from Azure services
│   ├── Event Hub    — high-throughput telemetry (IoT, streaming)
│   │   └── Processes in batches, checkpoints with Storage
│   └── Cosmos DB    — change feed trigger
│       └── Fires on insert/update (not delete)
│
├── 4. BINDINGS
│   ├── INPUT (read data in)
│   │   ├── Blob Input          — read a blob by name
│   │   ├── Queue Input         — peek messages
│   │   ├── Table Storage Input — read table rows
│   │   ├── Cosmos DB Input     — read documents by id/query
│   │   └── SQL Input           — read SQL rows
│   └── OUTPUT (write data out)
│       ├── Blob Output         — write file to storage
│       ├── Queue Output        — send queue message
│       ├── Table Output        — write table row
│       ├── Cosmos DB Output    — upsert document
│       ├── Service Bus Output  — send SB message
│       ├── Event Hub Output    — send event
│       ├── SignalR Output      — push to connected clients
│       ├── SQL Output          — write to SQL
│       └── HTTP Response       — return HTTP result
│
├── 5. HOSTING PLANS
│   ├── Flex Consumption (FC1) ⭐ RECOMMENDED (2024+)
│   │   ├── Per-request billing, fast cold start
│   │   └── VNet integration, no cold start penalty
│   ├── Consumption (Y1) — legacy, cold starts, cheapest
│   │   ├── Scale to zero
│   │   └── 5 min timeout (max 10)
│   ├── Premium (EP1/EP2/EP3)
│   │   ├── Pre-warmed instances (no cold start)
│   │   ├── VNet integration, unlimited timeout
│   │   └── More expensive
│   └── Dedicated (App Service Plan)
│       ├── Always-on
│       └── Use when already have App Service Plan
│
├── 6. .NET PROGRAMMING MODEL
│   ├── Isolated Worker (recommended — .NET 8+)
│   │   ├── Runs in separate process from host
│   │   ├── Full .NET DI, middleware support
│   │   └── [Function("Name")] attribute
│   └── In-Process (legacy — .NET 6, being retired)
│       └── Shares process with Functions host
│
├── 7. DURABLE FUNCTIONS (STATEFUL)
│   ├── Orchestrator  — coordinates activities, runs sequentially/in parallel
│   ├── Activity      — actual unit of work (calls APIs, writes DB)
│   ├── Client        — starts orchestration, checks status
│   └── Patterns
│       ├── Function Chaining    — A → B → C → D (sequential)
│       ├── Fan-Out / Fan-In     — parallel tasks → aggregate results
│       ├── Human Interaction    — wait for external event (approval)
│       │   └── WaitForExternalEventAsync() + RaiseEventAsync()
│       └── Monitor              — poll until condition met
│
├── 8. SECURITY
│   ├── Function Keys    — Anonymous / Function / Admin levels
│   ├── Managed Identity — access Azure resources without secrets
│   │   └── DefaultAzureCredential() — tries MI, then env vars, then VS
│   ├── JWT Validation   — validate Bearer tokens in middleware
│   ├── Azure AD B2C     — social + enterprise login
│   ├── Easy Auth        — portal-level auth (no code)
│   ├── IP Restrictions  — allowlist/blocklist CIDRs
│   └── CORS             — configure allowed origins in host.json or portal
│
├── 9. ERROR HANDLING
│   ├── Try/Catch in activity functions (not orchestrators)
│   ├── Retry policies
│   │   ├── host.json: maxRetryCount, retryInterval
│   │   └── [ExponentialBackoffRetry] attribute
│   ├── Poison queue     — messages that fail maxDequeueCount go here
│   ├── Dead-letter queue — Service Bus unprocessable messages
│   └── Global middleware — IFunctionsWorkerMiddleware (Isolated)
│
├── 10. CONFIGURATION
│   ├── host.json         — retry, timeout, logging, extensions
│   ├── local.settings.json — local dev only, never commit
│   ├── App Settings      — portal: Configuration → App Settings
│   ├── Key Vault refs    — "@Microsoft.KeyVault(SecretUri=...)"
│   └── Environment vars  — IConfiguration / Environment.GetEnvironmentVariable()
│
├── 11. PLATFORM FEATURES
│   ├── Deployment Slots  — staging/prod swap (Premium/Dedicated only)
│   ├── VNet Integration  — private network access (Premium/Flex)
│   ├── Custom Handlers   — any language via HTTP (Go, Rust, etc.)
│   ├── Proxies           — lightweight API gateway (legacy)
│   ├── Custom Domains    — bring your own domain + SSL
│   └── Warm-up Trigger   — pre-warm before traffic hits (Premium)
│
├── 12. TESTING
│   ├── Unit Test     — mock ILogger, inject fakes via DI
│   ├── Integration   — use TestHost, real bindings
│   └── Durable Test  — mock IDurableOrchestrationContext
│
├── 13. MONITORING & OBSERVABILITY
│   ├── Application Insights — built-in, configure in host.json
│   │   ├── Traces, exceptions, dependencies auto-collected
│   │   └── TelemetryClient for custom events/metrics
│   ├── Structured Logging   — ILogger<T>, log levels
│   ├── Live Metrics Stream   — real-time view in portal
│   └── KQL queries          — query logs in Log Analytics
│
├── 14. DEPLOYMENT
│   ├── Azure DevOps    — YAML pipeline, AzureFunctionApp@2 task
│   ├── GitHub Actions  — azure/functions-action
│   ├── VS Code         — Azure Functions extension, F1 → Deploy
│   ├── Azure CLI       — func azure functionapp publish
│   └── Zip Deploy      — POST to /api/zipdeploy
│
├── 15. STORAGE DEPENDENCY
│   ├── Every Function App needs Azure Storage Account
│   ├── Used for: state (Durable), leases, trigger checkpoints
│   ├── Blob    — checkpoint for Event Hub, large message offload
│   ├── Queue   — poison queue, retry state
│   └── Table   — instance state for Durable Functions
│
├── 16. WHEN TO USE / NOT USE
│   ├── USE FOR
│   │   ├── Event-driven processing (queue, blob, events)
│   │   ├── Scheduled background jobs
│   │   ├── Lightweight HTTP APIs / webhooks
│   │   ├── Glue code between services
│   │   └── Cost-sensitive workloads (pay-per-use)
│   └── DO NOT USE FOR
│       ├── Long-running processes > 10 min (use Durable or Container Apps)
│       ├── Stateful workflows without Durable Functions
│       ├── High-frequency low-latency trading (<10ms SLA)
│       └── Heavy compute (use Azure Batch or AKS)
│
└── 17. BEST PRACTICES
    ├── Single responsibility — one job per function
    ├── Idempotent — safe to retry without side effects
    ├── Use Managed Identity — never hardcode connection strings
    ├── Async everywhere — async/await for all I/O
    ├── Avoid orchestrator side effects — pure coordination only
    ├── Use output bindings — less code, no SDK needed
    ├── Configure retry in host.json — not in code
    ├── Keep functions stateless — store state externally
    └── Cold start mitigation — Premium plan or Flex Consumption
```

---

## QUICK RECALL — 1-LINE DEFINITIONS

| Term | One-liner |
|---|---|
| Function App | Container for multiple functions, shares plan + storage |
| Trigger | The event that starts the function (exactly one) |
| Binding | Declarative connection to data source/sink (no SDK code) |
| Consumption Plan | Pay per exec, scale to zero, cold starts |
| Premium Plan | Pre-warmed, VNet, no cold start, always running |
| Flex Consumption | Best of both: per-exec billing + fast start + VNet |
| Durable Functions | Extension for stateful, long-running workflows |
| Orchestrator | Coordinates activities; must be deterministic |
| Activity | Unit of work in Durable; can do I/O |
| Fan-Out/Fan-In | Run tasks in parallel, wait for all with Task.WhenAll |
| Managed Identity | Function authenticates to Azure services without secrets |
| Poison Queue | Dead messages after maxDequeueCount exceeded |
| host.json | Global config for retry, timeout, logging |
| [Timestamp] attribute | EF Core rowversion for optimistic concurrency |
| Isolated Worker | .NET 8 model — separate process, full middleware support |

---

## QUICK RECALL — TRIGGER CRON SYNTAX

```
{second} {minute} {hour} {day} {month} {day-of-week}

"0 0 * * * *"     = every hour
"0 */5 * * * *"   = every 5 minutes
"0 0 8 * * 1-5"   = 8am Mon-Fri
"0 0 0 1 * *"     = midnight on 1st of every month
```

---

## QUICK RECALL — HOSTING PLAN DECISION

```
Need cheapest, ok with cold starts?        → Consumption (Y1)
Need no cold start + VNet?                 → Premium (EP1)
Need per-exec billing + VNet + fast start? → Flex Consumption ⭐
Already have App Service Plan?             → Dedicated
```

---

## QUICK RECALL — DURABLE PATTERNS

```
A → B → C → D (one after another)         → Function Chaining
A → [B, C, D] → Wait all → E              → Fan-Out / Fan-In
Start → Wait for human → Continue         → Human Interaction
Start → Check → Sleep → Check again...    → Monitor Pattern
```

---

## QUICK RECALL — SECURITY LAYERS

```
Public endpoint with no auth              → Anonymous key level
API called by trusted clients             → Function key in header
Function accesses Key Vault / Storage     → Managed Identity
User-facing login                         → Easy Auth / Azure AD B2C
Internal microservice-to-service          → Managed Identity + RBAC
Block IPs                                 → IP Restrictions in portal
```
