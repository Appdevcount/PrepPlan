# QuickPrep — Azure Services & Cloud Design Patterns
> Expert-level interview preparation covering Azure PaaS/networking services, cloud design patterns, Well-Architected Framework, and cost optimization.
> Last updated: 2026-04-03

---

## Table of Contents

| # | Section |
|---|---------|
| 1 | [Cloud Design Patterns](#1-cloud-design-patterns) |
| 2 | [Azure Functions](#2-azure-functions) |
| 3 | [Azure Cache for Redis](#3-azure-cache-for-redis) |
| 4 | [Microsoft Entra ID (Azure AD)](#4-microsoft-entra-id) |
| 5 | [API Management (APIM)](#5-api-management-apim) |
| 6 | [Event Grid](#6-event-grid) |
| 7 | [Event Hubs](#7-event-hubs) |
| 8 | [Azure Monitor](#8-azure-monitor) |
| 9 | [Application Gateway](#9-application-gateway) |
| 10 | [Azure DNS](#10-azure-dns) |
| 11 | [Private Link & Private Endpoint](#11-private-link--private-endpoint) |
| 12 | [Traffic Manager](#12-traffic-manager) |
| 13 | [Virtual Network Manager (VNet Manager)](#13-virtual-network-manager) |
| 14 | [Storage Accounts](#14-storage-accounts) |
| 15 | [Azure Well-Architected Framework](#15-azure-well-architected-framework) |
| 16 | [Cost Optimization Techniques](#16-cost-optimization-techniques) |
| 17 | [Top Interview Q&A — 40 Questions](#17-top-interview-qa) |

---

## 1. Cloud Design Patterns

> **Mental Model:** Design patterns are battle-tested blueprints — like architectural blueprints for a skyscraper. You don't reinvent structural engineering each time; you apply proven load-bearing techniques to your specific building.

```
┌──────────────────────────────────────────────────────────────────────┐
│                    CLOUD DESIGN PATTERN TAXONOMY                     │
├─────────────────┬────────────────────┬───────────────────────────────┤
│  Availability   │   Data Management  │   Design & Implementation     │
│  ─────────────  │  ──────────────── │  ────────────────────────────  │
│  Circuit Breaker│  CQRS              │  Strangler Fig                │
│  Retry          │  Event Sourcing    │  Sidecar                      │
│  Bulkhead       │  Saga              │  Ambassador                   │
│  Health Endpoint│  Sharding          │  Anti-Corruption Layer        │
│  Throttling     │  Cache-Aside       │  Backends for Frontends       │
│                 │  Outbox            │  Gateway Aggregation          │
├─────────────────┴────────────────────┴───────────────────────────────┤
│  Messaging                                                           │
│  Competing Consumers · Publisher-Subscriber · Queue-Based Load Level │
│  Priority Queue · Scheduler Agent Supervisor · Choreography vs Orch  │
└──────────────────────────────────────────────────────────────────────┘
```

---

### 1.1 Retry Pattern

**Problem:** Transient faults (network blip, throttling) cause unnecessary failures.

**Solution:** Automatically retry the operation with exponential back-off + jitter.

```csharp
// ── Polly Retry with Exponential Backoff ─────────────────────────────
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .Or<TaskCanceledException>()
    .WaitAndRetryAsync(
        retryCount: 3,
        // WHY exponential + jitter: avoids thundering herd when many clients retry simultaneously
        sleepDurationProvider: attempt =>
            TimeSpan.FromSeconds(Math.Pow(2, attempt)) +
            TimeSpan.FromMilliseconds(Random.Shared.Next(0, 200)),
        onRetry: (ex, delay, attempt, ctx) =>
            logger.LogWarning("Retry {Attempt} after {Delay}ms: {Error}", attempt, delay.TotalMilliseconds, ex.Message)
    );
```

**When NOT to retry:** 401 Unauthorized, 400 Bad Request — retrying won't help; fix the request.

---

### 1.2 Circuit Breaker Pattern

> **Mental Model:** An electrical circuit breaker — when too many failures occur, it "opens" (trips) to stop cascading failures. After a timeout it enters "half-open" to probe recovery.

```
  CLOSED ──(failures >= threshold)──► OPEN ──(timeout)──► HALF-OPEN
     ▲                                                         │
     └──────────────── success ───────────────────────────────┘
                                              │
                              failure ──────► OPEN (again)
```

```csharp
// ── Polly Circuit Breaker ────────────────────────────────────────────
var cb = Policy
    .Handle<Exception>()
    .CircuitBreakerAsync(
        exceptionsAllowedBeforeBreaking: 5,
        durationOfBreak: TimeSpan.FromSeconds(30),         // WHY 30s: gives downstream time to recover
        onBreak: (ex, duration) => logger.LogError("Circuit OPEN for {Duration}", duration),
        onReset: () => logger.LogInformation("Circuit CLOSED — downstream recovered"),
        onHalfOpen: () => logger.LogInformation("Circuit HALF-OPEN — probing")
    );
```

---

### 1.3 Bulkhead Pattern

> **Mental Model:** Compartments on a ship — if one floods, the others stay dry. Isolate failures to a bounded thread pool or connection pool.

```csharp
// WHY: Prevent one slow downstream from exhausting all HttpClient connections
var bulkhead = Policy.BulkheadAsync(
    maxParallelization: 10,       // max concurrent calls
    maxQueuingActions: 20,        // max waiting in queue
    onBulkheadRejectedAsync: ctx =>
    {
        logger.LogWarning("Bulkhead full — request rejected");
        return Task.CompletedTask;
    });
```

**Azure Implementation:** Separate App Service Plans / AKS node pools per workload criticality tier.

---

### 1.4 CQRS (Command Query Responsibility Segregation)

> **Mental Model:** A restaurant with separate chefs — one for hot dishes (commands / writes), one for cold station (queries / reads). They never share a cutting board.

```
                     ┌──────────────┐
    User ──Write──►  │   Command    │──► Write DB (normalized, ACID)
                     │   Handler    │──► Publishes DomainEvent
                     └──────────────┘
                                             │
                                    EventBus / Outbox
                                             │
                     ┌──────────────┐        ▼
    User ──Read───►  │    Query     │◄── Read DB (denormalized, optimized projections)
                     │   Handler   │
                     └──────────────┘
```

**Key Insight:** Read models can be completely different databases — SQL for writes, Redis or CosmosDB for reads. Scale them independently.

---

### 1.5 Event Sourcing

> **Mental Model:** A bank ledger — you never erase a transaction; you record every debit/credit and derive the current balance by replaying the ledger.

```
Append-Only Event Store:
  [AccountOpened] → [MoneyDeposited: +1000] → [MoneyWithdrawn: -200] → [MoneyDeposited: +500]
  
  Current state = replay of all events → Balance: 1300
```

**Benefits:**
- Complete audit trail (compliance, GDPR deletion via event suppression)
- Temporal queries ("what was the balance on March 1st?")
- Event replay for new projections

**Azure:** Azure Cosmos DB (append-only container) + Azure Event Hubs (event log) + Azure Functions for projections.

---

### 1.6 Saga Pattern (Distributed Transactions)

> **Mental Model:** Booking a trip with separate vendors — hotel, flight, car. If one fails, each vendor has a cancellation policy (compensating transaction).

```
Choreography-based Saga:
  OrderService ──► [OrderCreated event]
       │
  PaymentService subscribes ──► [PaymentProcessed event]
       │
  InventoryService subscribes ──► [InventoryReserved event]
       │
  ShippingService subscribes ──► [OrderFulfilled event]

  On failure: publish [PaymentFailed] → each service compensates itself
```

```
Orchestration-based Saga:
  SagaOrchestrator ──► PaymentService.Charge()
                    ──► InventoryService.Reserve()
                    ──► ShippingService.Ship()
                    
  On failure: orchestrator calls compensations in reverse order
```

| | Choreography | Orchestration |
|--|--|--|
| Coupling | Loose | Tighter (orchestrator knows all) |
| Visibility | Hard (trace via events) | Easy (single orchestrator log) |
| Azure | Event Grid / Service Bus | Durable Functions |

---

### 1.7 Outbox Pattern

**Problem:** Writing to DB and publishing an event must be atomic — if publish fails after DB commit, event is lost.

```
┌─────────────────────────────────────────────────────────────┐
│  Transaction                                                │
│   ① INSERT Order → Orders table                            │
│   ② INSERT Event → Outbox table  (same transaction)        │
└─────────────────────────────────────────────────────────────┘
        │
  Background worker polls Outbox table
        │
  Publish to Service Bus → mark Outbox row as Processed
```

**Key Insight:** Guarantees at-least-once delivery. Make consumers idempotent to handle duplicates.

---

### 1.8 Strangler Fig Pattern

> **Mental Model:** A strangler fig vine grows around a host tree, eventually replacing it while the tree still stands. Incrementally migrate a monolith by routing traffic to new microservices.

```
                     ┌─────────────────┐
User ──────────────► │   API Gateway   │ (Azure APIM)
                     └────────┬────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
       [/orders/*]      [/payments/*]    [/catalog/*]
          New μS            New μS         Legacy Monolith
       (migrated)         (migrated)     (still running)
```

---

### 1.9 Cache-Aside (Lazy Loading)

```csharp
// WHY: Never pre-warm everything — load on demand, evict on TTL
public async Task<Product> GetProductAsync(string id)
{
    var cached = await redis.GetAsync<Product>($"product:{id}");
    if (cached is not null) return cached;             // cache hit

    var product = await db.Products.FindAsync(id);    // cache miss → DB
    await redis.SetAsync($"product:{id}", product,    // populate cache
        expiry: TimeSpan.FromMinutes(10));             // WHY 10min: balance freshness vs DB load
    return product;
}
```

**Write strategies:**
| Strategy | Description | Use When |
|----------|-------------|----------|
| Cache-Aside | App manages cache | General purpose |
| Write-Through | Write to cache + DB together | High read/write |
| Write-Behind | Write to cache, async to DB | High write throughput |
| Read-Through | Cache fetches from DB on miss | Consistent abstraction |

---

### 1.10 Competing Consumers

> **Mental Model:** A fast-food counter with 5 cashiers sharing one queue — whoever is free takes the next order.

```
Producers ──► [Queue / Topic] ◄── Consumer 1
                               ◄── Consumer 2   (horizontal scale)
                               ◄── Consumer 3
```

**Azure:** Azure Service Bus Queue + multiple Azure Functions instances with `[ServiceBusTrigger]`.

---

### 1.11 Backends for Frontends (BFF)

**Problem:** Mobile and web have different data needs. A generic API is either too fat or too thin.

```
Web App ──► BFF-Web  ──► Microservices
Mobile  ──► BFF-Mobile ──► Microservices  (aggregates, trims data for mobile bandwidth)
IoT     ──► BFF-IoT ──► Microservices
```

**Azure:** Separate Azure APIM products or separate Azure Functions per client type.

---

### 1.12 Throttling Pattern

**Problem:** Uncontrolled request spikes exhaust resources.

```csharp
// Azure APIM rate-limit policy (XML)
<rate-limit calls="100" renewal-period="60" />   // WHY: 100 req/min per subscription
<quota calls="10000" renewal-period="86400" />    // WHY: daily cap prevents abuse
```

**Azure:** APIM rate-limit, App Service throttling, Azure Front Door WAF rate rules.

---

### 1.13 Sidecar & Ambassador Patterns

| Pattern | Description | Azure Example |
|---------|-------------|---------------|
| **Sidecar** | Helper container alongside main app (same pod) | Envoy proxy, log agent (OMS), secrets rotator |
| **Ambassador** | Proxy that handles outbound calls on behalf of the app | Dapr sidecar, nginx proxy for legacy app |
| **Adapter** | Standardizes incompatible interfaces | Protocol translation sidecar |

---

### 1.14 Sharding Pattern

> **Mental Model:** Library with books sorted by topic into different rooms — you don't search all rooms, just the right one.

**Sharding strategies:**

| Strategy | Description | Example |
|----------|-------------|---------|
| Range | Shard by value range | Date ranges per shard |
| Hash | Consistent hash of key | `hash(tenantId) % N` |
| Lookup | Shard map table | Tenant → Shard mapping |
| Geography | Shard by region | EU data stays EU |

**Azure:** Cosmos DB (automatic partitioning), SQL Elastic Pools, Event Hubs partitions.

---

## 2. Azure Functions

> **Mental Model:** Serverless function = a vending machine. You insert a trigger (coin), the machine runs exactly the logic needed, dispenses the result, and shuts down. You pay only for what's dispensed.

```
┌──────────────────────────────────────────────────────────┐
│                  AZURE FUNCTIONS ANATOMY                  │
├──────────────┬───────────────────────────────────────────┤
│   TRIGGERS   │  HTTP · Timer · Service Bus · Event Hub   │
│              │  Blob · Queue · CosmosDB · Event Grid      │
├──────────────┼───────────────────────────────────────────┤
│   BINDINGS   │  Input: CosmosDB, Blob, Table, SQL        │
│  (I/O wiring)│  Output: Service Bus, Queue, Blob, SignalR │
├──────────────┼───────────────────────────────────────────┤
│   HOSTING    │  Consumption · Premium · Dedicated (ASP)  │
│    PLANS     │  Flex Consumption · Container Apps        │
└──────────────┴───────────────────────────────────────────┘
```

### Hosting Plan Comparison

| Plan | Cold Start | Scale | Max Timeout | VNet Integration | Use When |
|------|-----------|-------|-------------|-----------------|----------|
| Consumption | Yes (~1-3s) | Auto (0→N) | 10 min | Premium VNet only | Low/variable traffic |
| Premium | No (pre-warmed) | Auto | Unlimited | Full | Consistent load, no cold start |
| Dedicated | No | Manual/ASP | Unlimited | Full | Long-running, predictable cost |
| Flex Consumption | Minimal | Auto + concurrency | Configurable | Yes | Best of Consumption + VNet |

### Key Interview Points

```csharp
// ── Durable Functions — Orchestration ────────────────────────────────
[FunctionName("OrderOrchestrator")]
public async Task RunOrchestrator([OrchestrationTrigger] IDurableOrchestrationContext ctx)
{
    // WHY: Orchestration code must be deterministic — no DateTime.Now, no random, no I/O directly
    var order = ctx.GetInput<OrderDto>();
    
    await ctx.CallActivityAsync("ChargePayment", order.PaymentInfo);
    await ctx.CallActivityAsync("ReserveInventory", order.Items);
    
    // WHY: WaitForExternalEvent enables human-in-the-loop workflows
    var approved = await ctx.WaitForExternalEvent<bool>("ManagerApproval",
        timeout: TimeSpan.FromHours(24));

    if (!approved) await ctx.CallActivityAsync("CancelOrder", order.Id);
}
```

**Durable Patterns:**
| Pattern | Use Case |
|---------|----------|
| Function Chaining | Sequential steps with shared state |
| Fan-out/Fan-in | Parallel processing, aggregate results |
| Async HTTP API | Long-running ops with polling endpoint |
| Monitor | Polling loop with flexible sleep (replace Timer) |
| Human Interaction | Approval workflows with timeout |
| Aggregator | Stateful event accumulation |

---

## 3. Azure Cache for Redis

> **Mental Model:** Redis is the RAM on your kitchen counter — small, blazing fast, holds what you're actively cooking with. The fridge (DB) is slower but holds everything.

```
┌─────────────────────────────────────────────────────────────┐
│                AZURE CACHE FOR REDIS TIERS                  │
├───────────┬──────────┬────────────┬────────────────────────-┤
│   Basic   │ Standard │  Premium   │  Enterprise             │
│  Single   │  Replica │ Clustering │  Redis Modules          │
│  No SLA   │  99.9%   │  99.9%     │  99.999% (active-active)│
│  Dev/test │  Prod    │  High perf │  Mission critical       │
└───────────┴──────────┴────────────┴─────────────────────────┘
```

### Redis Data Structures & Use Cases

| Structure | Commands | Use Case |
|-----------|---------|----------|
| String | GET/SET/INCR | Session data, counters, feature flags |
| Hash | HGET/HSET/HGETALL | User profile objects |
| List | LPUSH/RPOP/LRANGE | Message queues, recent items |
| Set | SADD/SMEMBERS/SINTER | Tags, unique visitors, following/followers |
| Sorted Set | ZADD/ZRANGE/ZRANGEBYSCORE | Leaderboards, rate limiting, time-series |
| Stream | XADD/XREAD | Event streaming (Redis alternative to Kafka) |
| HyperLogLog | PFADD/PFCOUNT | Approximate unique counts (cardinality) |
| Geo | GEOADD/GEODIST | Location-based queries |
| Pub/Sub | PUBLISH/SUBSCRIBE | Real-time messaging (no persistence) |

### C# Integration

```csharp
// ── StackExchange.Redis — Production Setup ──────────────────────────
// WHY: Lazy<> ensures single thread-safe connection initialization
private static readonly Lazy<ConnectionMultiplexer> LazyConnection = new(() =>
    ConnectionMultiplexer.Connect(new ConfigurationOptions
    {
        EndPoints = { "my-cache.redis.cache.windows.net:6380" },
        Password = Environment.GetEnvironmentVariable("REDIS_KEY"),
        Ssl = true,                        // WHY: Azure Redis requires TLS
        AbortOnConnectFail = false,        // WHY: Retry on startup instead of crashing
        ReconnectRetryPolicy = new ExponentialRetry(5000), // WHY: Exponential backoff on reconnect
        SyncTimeout = 5000,                // WHY: Fail fast rather than hang indefinitely
        ConnectTimeout = 10000
    }));

// ── Distributed Cache via IDistributedCache ─────────────────────────
// WHY: IDistributedCache abstraction allows swapping Redis for in-memory in tests
services.AddStackExchangeRedisCache(opts =>
{
    opts.Configuration = configuration.GetConnectionString("Redis");
    opts.InstanceName = "myapp:";          // WHY: Namespace keys to avoid collisions
});
```

### Redis Rate Limiting (Sliding Window)

```lua
-- Lua script — atomic sliding window rate limit
-- WHY Lua: MULTI/EXEC is non-atomic for reads; Lua runs server-side atomically
local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])  -- window in ms
local limit = tonumber(ARGV[3])

redis.call('ZREMRANGEBYSCORE', key, '-inf', now - window)  -- remove expired entries
local count = redis.call('ZCARD', key)
if count < limit then
    redis.call('ZADD', key, now, now)
    redis.call('PEXPIRE', key, window)
    return 1  -- allowed
end
return 0  -- rejected
```

### Key Interview Points

- **Eviction Policies:** `volatile-lru` (evict keys with TTL), `allkeys-lru` (evict any), `noeviction` (return error)
- **Persistence:** RDB (snapshots) vs AOF (append-only log) — Premium supports both
- **Geo-replication:** Premium tier supports passive geo-replication; Enterprise supports active-active
- **Redis Cluster:** Automatic sharding across 10 shards (Premium), 16,384 hash slots
- **Session State:** Replace ASP.NET in-memory session with Redis for multi-instance apps

---

## 4. Microsoft Entra ID

> **Mental Model:** Entra ID is the corporate security desk — it issues badges (tokens), knows who has access to which rooms (roles/scopes), and can federate with other companies' security desks (B2B/B2C).

```
┌──────────────────────────────────────────────────────────────┐
│                    ENTRA ID ECOSYSTEM                         │
├─────────────────┬────────────────────┬───────────────────────┤
│   Entra ID      │  Entra ID B2B      │  Entra ID B2C         │
│  (Employees)    │  (Partner access)  │  (Customers)          │
│  Internal apps  │  Guest accounts    │  Social logins        │
│  SSO, MFA       │  Cross-tenant      │  Custom OIDC flows    │
│  RBAC, PIM      │  collaboration     │  Branded experience   │
└─────────────────┴────────────────────┴───────────────────────┘
```

### Authentication Flows

| Flow | Use Case | When to Use |
|------|----------|-------------|
| Authorization Code + PKCE | SPAs, mobile apps | Public clients (no client secret) |
| Client Credentials | Daemon/service-to-service | No user context needed |
| On-Behalf-Of (OBO) | API calling another API on user's behalf | Delegated permissions chain |
| Device Code | CLI tools, smart TVs | No browser on device |
| Implicit | ~~Legacy SPAs~~ | **Deprecated — use Auth Code + PKCE** |

```csharp
// ── Client Credentials Flow — Service-to-Service ────────────────────
// WHY: Managed Identity is preferred over client secrets — no secret rotation needed
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration, "AzureAd");

// In calling service — use DefaultAzureCredential (Managed Identity in Azure)
var credential = new DefaultAzureCredential();
var tokenRequest = new TokenRequestContext(
    new[] { "https://management.azure.com/.default" });
var token = await credential.GetTokenAsync(tokenRequest);
```

### RBAC vs ABAC

| | RBAC (Role-Based) | ABAC (Attribute-Based) |
|--|--|--|
| Control | Roles assigned to users | Conditions on attributes |
| Example | "Owner", "Reader", "Contributor" | "Can read blobs tagged Dept=Finance" |
| Azure | Built-in roles + Custom Roles | Azure Conditions on role assignments |
| Granularity | Coarse | Fine-grained |

### Conditional Access

```
User attempts login
       │
       ▼
[Signal Evaluation]
  - User location (IP/country)
  - Device compliance (Intune)
  - App sensitivity
  - Sign-in risk (Identity Protection)
       │
       ▼
[Grant/Block/Challenge]
  ✓ Grant if compliant device + low risk
  ✗ Block if high-risk country
  ⚠ Require MFA if medium risk
```

### Managed Identity

```csharp
// WHY: Managed Identity eliminates credentials from code entirely
// Azure automatically rotates the underlying service principal credentials
var client = new SecretClient(
    new Uri("https://my-vault.vault.azure.net/"),
    new DefaultAzureCredential()); // Uses Managed Identity in Azure, dev credentials locally

var secret = await client.GetSecretAsync("ConnectionString");
```

**System-Assigned vs User-Assigned Managed Identity:**

| | System-Assigned | User-Assigned |
|--|--|--|
| Lifecycle | Tied to resource | Independent resource |
| Sharing | 1 resource only | Multiple resources share same identity |
| Use When | Single resource needs identity | Multiple resources need same access |

### PIM (Privileged Identity Management)

- Just-In-Time (JIT) elevation — no standing admin access
- Approval workflows for high-privilege roles
- Time-bound role activation (e.g., 8 hours max)
- Full audit log of who elevated when and why

---

## 5. API Management (APIM)

> **Mental Model:** APIM is an airport — flights (APIs) come in, but every passenger (request) goes through security (policies), customs (transformations), and passport control (authentication) before reaching their gate (backend).

```
                    ┌────────────────────────────────────┐
Consumer ──HTTPS──► │           APIM Gateway             │
                    │  ┌──────────────────────────────┐  │
                    │  │  Inbound Policies             │  │
                    │  │  - Auth (JWT/OAuth/Cert)      │  │
                    │  │  - Rate Limit / Quota         │  │
                    │  │  - IP Filter                  │  │
                    │  │  - Transform (headers/body)   │  │
                    │  └──────────────────────────────┘  │
                    │  ┌──────────────────────────────┐  │
                    │  │  Backend call                 │  │
                    │  │  (with retry, circuit breaker)│  │
                    │  └──────────────────────────────┘  │
                    │  ┌──────────────────────────────┐  │
                    │  │  Outbound Policies            │  │
                    │  │  - Response caching           │  │
                    │  │  - CORS headers               │  │
                    │  │  - Body transform (JSON↔XML)  │  │
                    │  └──────────────────────────────┘  │
                    └────────────────────────────────────┘
```

### APIM Tiers

| Tier | SLA | VNet | Developer Portal | Scale Units | Use |
|------|-----|------|-----------------|-------------|-----|
| Developer | None | Injection | Yes | 1 | Testing only |
| Basic | 99.95% | None | Yes | 1-2 | Simple APIs |
| Standard | 99.95% | Injection | Yes | 1-4 | Production |
| Premium | 99.99% | Full injection | Yes | N | Multi-region, enterprise |
| Consumption | 99.95% | None | No | Auto | Serverless, event-driven |

### Key Policies

```xml
<!-- ── JWT Validation ──────────────────────────────────────────────── -->
<validate-jwt header-name="Authorization" failed-validation-httpcode="401">
    <openid-config url="https://login.microsoftonline.com/{tenantId}/.well-known/openid-configuration"/>
    <required-claims>
        <claim name="aud" match="all">
            <value>api://my-api-app-id</value>  <!-- WHY: Ensure token is for THIS API -->
        </claim>
    </required-claims>
</validate-jwt>

<!-- ── Rate Limiting per subscription key ────────────────────────────-->
<rate-limit-by-key calls="100" renewal-period="60"
    counter-key="@(context.Subscription?.Key ?? "anonymous")" />

<!-- ── Response Caching ──────────────────────────────────────────────-->
<cache-lookup vary-by-developer="false" vary-by-developer-groups="false">
    <vary-by-header>Accept-Language</vary-by-header>  <!-- WHY: Cache per language -->
</cache-lookup>
<cache-store duration="300" />  <!-- WHY: 5-min TTL — balance freshness vs backend load -->

<!-- ── Backend Circuit Breaker ───────────────────────────────────────-->
<retry condition="@(context.Response.StatusCode >= 500)"
    count="3" interval="2" first-fast-retry="true" />
```

### Self-Hosted Gateway

Deploy APIM gateway container on-premises or in other clouds — traffic stays local, management plane stays in Azure. Useful for hybrid scenarios (on-prem + Azure).

---

## 6. Event Grid

> **Mental Model:** Event Grid is a postal sorting office — publishers drop envelopes (events), and the sorting office routes each envelope to the right mailbox (subscriber) based on the address (filter).

```
┌──────────────────────────────────────────────────────────────┐
│                      EVENT GRID FLOW                         │
│                                                              │
│  Publishers                Topics          Subscribers       │
│  ───────────               ──────          ───────────       │
│  Azure Blob ──────────────► System ──┬───► Azure Function    │
│  Azure Resources ─────────► Topic   ├───► Logic Apps        │
│  Custom App ─────────────► Custom   ├───► Event Hubs        │
│                            Topic    ├───► Service Bus       │
│                                     └───► Webhook           │
└──────────────────────────────────────────────────────────────┘
```

### Event Grid vs Service Bus vs Event Hubs

| | Event Grid | Service Bus | Event Hubs |
|--|-----------|-------------|-----------|
| Model | Push (reactive) | Pull/Push (reliable) | Pull (streaming) |
| Purpose | Event notifications | Business messaging | Big data ingestion |
| Ordering | No guarantee | Per session | Per partition |
| Retention | 24h (retry) | 14 days max | 1 day–90 days |
| Throughput | Millions of events | High | Very high (MB/s) |
| Consumers | Multiple (filter-based) | Competing or topic | Consumer groups |
| Protocol | HTTP webhooks | AMQP, HTTP | AMQP, Kafka, HTTP |
| Use When | React to state changes | Reliable commands/tasks | Log/telemetry streaming |

### C# — Custom Topic Publishing

```csharp
// ── Publish to Event Grid Custom Topic ───────────────────────────────
var client = new EventGridPublisherClient(
    new Uri(configuration["EventGrid:TopicEndpoint"]),
    new AzureKeyCredential(configuration["EventGrid:TopicKey"]));

var events = new List<EventGridEvent>
{
    new EventGridEvent(
        subject: $"orders/{order.Id}",    // WHY: Subject enables server-side filtering
        eventType: "Order.Created",
        dataVersion: "1.0",
        data: BinaryData.FromObjectAsJson(new { order.Id, order.TotalAmount }))
    {
        EventTime = DateTimeOffset.UtcNow
    }
};

await client.SendEventsAsync(events);
```

### Dead-Letter & Retry

- Default retry: exponential back-off over 24 hours (max 30 attempts)
- Dead-letter: undeliverable events → Blob storage (configure DLQ endpoint)
- Filter events at subscription level: event type filter, subject begins/ends with, advanced filters (data fields)

### CloudEvents Schema

Event Grid supports both native schema and **CloudEvents 1.0** — prefer CloudEvents for interoperability across clouds.

---

## 7. Event Hubs

> **Mental Model:** Event Hubs is a highway with multiple lanes (partitions). Each car (event) enters a lane, and readers (consumer groups) drive each lane independently at their own speed.

```
┌─────────────────────────────────────────────────────────────────┐
│                     EVENT HUBS ARCHITECTURE                     │
│                                                                 │
│  Producers ──► Namespace ──► Event Hub                         │
│                              │                                  │
│              ┌───────────────┼────────────────┐                 │
│              │               │                │                 │
│         Partition 0    Partition 1      Partition N             │
│         [e][e][e]...   [e][e][e]...    [e][e][e]...            │
│                                                                 │
│  Consumer Groups (independent read cursors per partition):      │
│   - analytics-cg (offset: 1024)                                │
│   - monitoring-cg (offset: 987)                                │
│   - archive-cg (offset: 1024)                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Partition** | Ordered, immutable sequence of events. Default: 4, Max: 2048 |
| **Consumer Group** | Independent reader cursor — each CG reads at its own pace |
| **Checkpoint** | Save read position so consumer can resume after restart |
| **Capture** | Auto-archive events to Blob/ADLS Gen2 in Avro format |
| **Offset** | Position of an event within a partition |
| **Sequence Number** | Monotonically increasing within a partition |

### Tiers

| Tier | Throughput Units | Retention | Features |
|------|-----------------|-----------|---------|
| Basic | 1-20 TU | 1 day | - |
| Standard | 1-40 TU | 7 days | Consumer groups, Capture |
| Premium | PU-based | 90 days | Dedicated infra, Schema Registry |
| Dedicated | Dedicated Cluster | 90 days | Highest throughput, private |

### Kafka Protocol Support

```csharp
// WHY: Event Hubs exposes Kafka endpoint — migrate Kafka apps with config change only
var config = new ProducerConfig
{
    BootstrapServers = "my-ns.servicebus.windows.net:9093",
    SecurityProtocol = SecurityProtocol.SaslSsl,
    SaslMechanism = SaslMechanism.Plain,
    SaslUsername = "$ConnectionString",
    SaslPassword = connectionString
};
```

### Schema Registry

- Stores Avro/JSON schemas centrally
- Producers validate against schema before publishing
- Consumers deserialize without embedded schema overhead
- Supports schema evolution (backward/forward compatibility)

### Partitioning Strategy

```csharp
// WHY: Use partition key to guarantee ordering for related events
// Events with same partition key always land on same partition
await producer.SendAsync(new EventData(Encoding.UTF8.GetBytes(json))
{
    // WHY: TenantId as key ensures all events for a tenant are ordered
    PartitionKey = order.TenantId
});
```

---

## 8. Azure Monitor

> **Mental Model:** Azure Monitor is mission control — telemetry (data) from every satellite (resource) flows to the control room (Log Analytics workspace) where operators (alerts, dashboards) monitor and act.

```
┌──────────────────────────────────────────────────────────────────────┐
│                        AZURE MONITOR STACK                           │
│                                                                      │
│  Sources                  Collection              Analysis/Action    │
│  ───────                  ──────────              ───────────────    │
│  Apps (App Insights) ────►                        ┌─ KQL Queries    │
│  VMs (Agents) ───────────► Log Analytics    ─────►├─ Dashboards     │
│  Containers (AKS) ───────► Workspace              ├─ Alerts ──► Action Groups │
│  Azure Resources ────────►                        └─ Workbooks      │
│  Custom (API/SDK) ────────►                                         │
│                                                                      │
│  Metrics (time-series) ──► Azure Metrics DB ─────► Metric Alerts    │
│                            (free, 93-day)          Auto-scale Rules  │
└──────────────────────────────────────────────────────────────────────┘
```

### Logs vs Metrics

| | Metrics | Logs |
|--|---------|------|
| Type | Numeric, time-series | Structured records |
| Retention | 93 days (free) | 30-730 days (paid) |
| Query | Simple, fast | KQL (rich) |
| Use | Alerting, auto-scale | Diagnostics, audit |
| Cost | Free (platform) | Per GB ingested |

### KQL — Key Query Examples

```kql
// ── Request failure rate by endpoint ─────────────────────────────────
requests
| where timestamp > ago(1h)
| summarize
    total = count(),
    failed = countif(success == false)
    by name
| extend failureRate = round(failed * 100.0 / total, 2)
| where failureRate > 5    // WHY: Alert threshold — 5% failure rate is SLO breach
| order by failureRate desc

// ── P99 latency per operation ─────────────────────────────────────────
requests
| where timestamp > ago(24h)
| summarize percentiles(duration, 50, 95, 99) by name
| order by percentile_duration_99 desc

// ── Exceptions with stack traces ──────────────────────────────────────
exceptions
| where timestamp > ago(1h)
| project timestamp, type, outerMessage, innermostMessage, assembly
| order by timestamp desc
| take 50

// ── CPU spike correlation with request volume ─────────────────────────
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize avg(CounterValue) by bin(TimeGenerated, 5m)
| join kind=leftouter (
    requests | summarize count() by bin(timestamp, 5m)
) on $left.TimeGenerated == $right.timestamp
| render timechart
```

### Application Insights

```csharp
// ── OpenTelemetry + Application Insights ─────────────────────────────
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddSqlClientInstrumentation()
        .AddAzureMonitorTraceExporter(opts =>
            opts.ConnectionString = configuration["ApplicationInsights:ConnectionString"]))
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddAzureMonitorMetricExporter(opts =>
            opts.ConnectionString = configuration["ApplicationInsights:ConnectionString"]));

// ── Custom Telemetry ──────────────────────────────────────────────────
var telemetry = serviceProvider.GetRequiredService<TelemetryClient>();

// Track business event (not just tech metrics)
telemetry.TrackEvent("OrderPlaced", new Dictionary<string, string>
{
    ["OrderId"] = order.Id,
    ["TenantId"] = order.TenantId
}, new Dictionary<string, double>
{
    ["Amount"] = (double)order.TotalAmount
});
```

### Alert Types

| Alert Type | Trigger | Use Case |
|-----------|---------|----------|
| Metric Alert | Threshold on metric (CPU > 80%) | Infrastructure alerts |
| Log Alert | KQL query returns results | Business logic alerts |
| Activity Log Alert | Azure operation (delete VM) | Compliance, governance |
| Smart Detection | AI-detected anomaly | App Insights only |
| Prometheus Alert | PromQL on scraped metrics | Kubernetes / AKS |

### Action Groups

```
Alert fires
    │
    ▼
Action Group
    ├─ Email / SMS / Push notification
    ├─ Azure Function (custom remediation)
    ├─ Logic App (ITSM ticketing)
    ├─ Webhook (PagerDuty, OpsGenie)
    └─ ITSM connector (ServiceNow)
```

---

## 9. Application Gateway

> **Mental Model:** Application Gateway is a smart traffic cop at the city entrance — it inspects every vehicle (HTTP request) at Layer 7, directs trucks to loading docks (backend pools), blocks suspicious cars (WAF), and can rewrite license plates (URL rewrite).

```
Internet ──► [Public IP] ──► Application Gateway ──► Backend Pool
                              │                        ├─ VMs
                              ├─ WAF (OWASP rules)     ├─ VMSS
                              ├─ SSL Termination       ├─ AKS pods
                              ├─ Cookie Affinity       ├─ App Service
                              ├─ URL-based routing     └─ Private IPs
                              ├─ Multi-site hosting
                              └─ Autoscaling (v2)
```

### App Gateway vs Azure Load Balancer vs Front Door

| Feature | App Gateway | Load Balancer | Front Door |
|---------|-------------|---------------|-----------|
| Layer | L7 (HTTP) | L4 (TCP/UDP) | L7 (global) |
| Scope | Regional | Regional | Global |
| SSL Termination | Yes | No | Yes |
| WAF | Yes | No | Yes |
| URL Routing | Yes | No | Yes |
| Cookie Affinity | Yes | No | No |
| WebSocket | Yes | Yes | No |
| Use When | Regional L7 LB + WAF | Non-HTTP, low latency | Multi-region global LB |

### WAF (Web Application Firewall)

- **Detection mode:** Log threats, don't block (use for tuning)
- **Prevention mode:** Block malicious requests
- **OWASP Core Rule Set (CRS):** Protects against SQLi, XSS, CSRF, LFI, RFI
- **Custom rules:** IP allow/deny lists, geo-filtering, rate-limiting
- **Managed rules:** Microsoft-maintained threat intelligence rules

### Key Configuration Concepts

```
Listener ──► Rule ──► Backend Pool
                       │
                  Health Probe (HTTP GET /health every 30s)
                       │
                  HTTP Settings (timeout, affinity, protocol)
```

**Multi-site hosting:** One App Gateway, multiple domain names → separate backends per host header.

**URL-based routing:**
- `/api/*` → API App Service
- `/images/*` → Blob Storage CDN
- `/` → SPA Static Web App

---

## 10. Azure DNS

> **Mental Model:** Azure DNS is a global phone book — when you type `api.mycompany.com`, Azure DNS is the operator that looks up the number (IP address).

```
┌──────────────────────────────────────────────────────────┐
│                    DNS RECORD TYPES                       │
├────────┬─────────────────────────────────────────────────┤
│   A    │  Maps hostname → IPv4 address                   │
│  AAAA  │  Maps hostname → IPv6 address                   │
│  CNAME │  Alias — hostname → another hostname            │
│  MX    │  Mail exchange server                           │
│  TXT   │  Domain verification, SPF, DKIM                 │
│  NS    │  Nameserver delegation                          │
│  SOA   │  Start of Authority (zone metadata)             │
│  SRV   │  Service location (port + protocol)             │
│  PTR   │  Reverse DNS (IP → hostname)                    │
│  CAA   │  Which CAs can issue certs for this domain      │
└────────┴─────────────────────────────────────────────────┘
```

### Public vs Private DNS Zones

| | Public DNS Zone | Private DNS Zone |
|--|----------------|-----------------|
| Resolution | Anywhere on internet | Within linked VNets only |
| Use Case | External-facing domains | Internal service discovery |
| Example | `api.contoso.com` | `myapp.internal.contoso.com` |
| Auto-registration | No | Yes (VMs auto-register A records) |

### Private DNS — Service Discovery Pattern

```
AKS Pod ──► resolves ──► myapi.internal.contoso.com
                                   │
                        Private DNS Zone (linked to AKS VNet)
                                   │
                        A record: 10.0.2.5 (internal load balancer IP)
```

### Azure DNS vs Custom DNS

**Azure-Provided DNS (168.63.129.16):**
- Resolves Azure Private DNS zones
- Resolves public internet via Azure DNS

**Custom DNS Server:** Use when you need AD-integrated DNS or on-premises resolution. Forward Azure-specific zones to 168.63.129.16.

### DNS Best Practices

- **Low TTL during migration** (60s) to allow fast cutover; increase to 3600s after stable
- **Alias records** for apex domains (`contoso.com` → Traffic Manager / Front Door) — CNAME not allowed at apex
- **DNSSEC:** Enable for public zones in production (Preview as of 2025)
- **CAA records:** Restrict certificate issuance to your CA only

---

## 11. Private Link & Private Endpoint

> **Mental Model:** Private Endpoint is a private entrance to a building (Azure service). Instead of going through the public lobby (public internet), you enter through a private door directly into your office floor (VNet).

```
Without Private Endpoint:
  Your VNet ──► Public Internet ──► Azure Storage public endpoint
  (traffic leaves Azure backbone, exposes public IP)

With Private Endpoint:
  Your VNet ──► Private Endpoint (10.0.1.5) ──► Azure Storage
  (traffic stays on Microsoft backbone, no public exposure)
```

### Components

| Component | Description |
|-----------|-------------|
| **Private Endpoint** | NIC with private IP in your VNet |
| **Private Link Service** | Your own service exposed via Private Link |
| **Private DNS Zone** | Resolves service FQDN to private IP |
| **Azure Private Link** | The platform feature connecting these |

### DNS Resolution for Private Endpoints

```
App queries: mystorageaccount.blob.core.windows.net
                     │
         Azure DNS sees CNAME:
         mystorageaccount.privatelink.blob.core.windows.net
                     │
         Private DNS Zone: privatelink.blob.core.windows.net
         A record: 10.0.1.5 (private endpoint IP)
                     │
         Traffic goes to Private Endpoint NIC → Storage
```

**WHY Private DNS Zone is critical:** Without it, the FQDN resolves to the public IP even with a private endpoint configured.

### Services Supporting Private Link

Storage, SQL, CosmosDB, Key Vault, App Service, AKS API server, ACR, Service Bus, Event Hubs, APIM, Cognitive Services, and more.

### Bicep — Private Endpoint Example

```bicep
// ── Private Endpoint for Azure SQL ───────────────────────────────────
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pe-sql-${envName}'
  location: location
  properties: {
    subnet: { id: subnetId }
    privateLinkServiceConnections: [
      {
        name: 'sql-connection'
        properties: {
          privateLinkServiceId: sqlServer.id
          // WHY: groupId defines which sub-resource to expose (sqlServer vs sqlOnDemand)
          groupIds: [ 'sqlServer' ]
        }
      }
    ]
  }
}

// ── Private DNS Zone Group (auto-registers A record) ─────────────────
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: sqlPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
```

---

## 12. Traffic Manager

> **Mental Model:** Traffic Manager is an air traffic controller for internet traffic — it uses DNS to direct planes (users) to the best airport (Azure region) based on routing rules (proximity, performance, failover).

```
User DNS Query: myapp.trafficmanager.net
       │
       ▼
Traffic Manager Profile
       │
       ├─ Endpoint 1: East US  (weight: 70, healthy ✓)
       ├─ Endpoint 2: West EU  (weight: 30, healthy ✓)
       └─ Endpoint 3: SE Asia  (degraded — health probe failing ✗)
       │
       ▼
Returns CNAME to best endpoint (East US 70% / West EU 30%)
```

### Routing Methods

| Method | Description | Use Case |
|--------|-------------|----------|
| **Priority** | Primary/failover — highest priority that's healthy | Active-passive DR |
| **Weighted** | Distribute by weight | Canary deployments, A/B testing |
| **Performance** | Route to lowest latency endpoint (closest to user) | Global perf optimization |
| **Geographic** | Route by user's geographic location | Data sovereignty, compliance |
| **MultiValue** | Return multiple endpoints (for redundancy) | DNS-aware clients |
| **Subnet** | Route by source IP ranges | Custom routing logic, differentiated services |

### Nested Profiles

```
Traffic Manager (Global — Priority routing)
├─ Profile A: East US region (Performance routing across 3 zones)
│   ├─ App Service East US 1
│   └─ App Service East US 2
└─ Profile B: West EU region (DR — priority 2, only activated if East fails)
    └─ App Service West EU
```

### Health Probes

- HTTP(S) or TCP probes to `/health` endpoint
- Configurable interval (10-300s), timeout, tolerated failures
- Endpoint considered unhealthy when consecutive failures exceed threshold

**WHY Traffic Manager uses DNS (not proxy):** No latency added — once DNS resolves, client connects directly to endpoint. But: no session persistence across region failover.

### Traffic Manager vs Front Door vs Load Balancer

| | Traffic Manager | Front Door | App Gateway |
|--|----------------|-----------|-------------|
| Scope | Global | Global | Regional |
| Protocol | DNS-based | HTTP Proxy | HTTP Proxy |
| SSL Termination | No | Yes | Yes |
| WAF | No | Yes | Yes |
| Latency | Zero (DNS only) | Minimal | Low |

---

## 13. Virtual Network Manager

> **Mental Model:** VNet Manager is a network city planner — instead of manually configuring roads (peerings) and traffic rules between each city block (VNet), you define policies centrally and the city planner enforces them everywhere.

```
Without VNet Manager:
  VNet A ←──peering──► VNet B   (manually configure each pair)
  VNet A ←──peering──► VNet C   (N*(N-1)/2 peerings for N VNets)
  VNet B ←──peering──► VNet C

With VNet Manager:
  ┌─────────────────────────────────┐
  │     VNet Manager               │
  │   ┌──────────────────────┐     │
  │   │  Network Group       │     │
  │   │  (VNet A, B, C, D)   │     │
  │   └──────────────────────┘     │
  │   ┌──────────────────────┐     │
  │   │  Connectivity Config │     │
  │   │  (Hub-spoke topology)│     │
  │   └──────────────────────┘     │
  │   ┌──────────────────────┐     │
  │   │  Security Config     │     │
  │   │  (Admin Rules)       │     │
  │   └──────────────────────┘     │
  └─────────────────────────────────┘
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Network Group** | Logical grouping of VNets (manual or Azure Policy-based dynamic membership) |
| **Connectivity Configuration** | Hub-and-spoke or mesh topology applied to a group |
| **Security Admin Config** | Centrally enforced NSG-like rules that override local NSGs |
| **Deployment** | Changes deployed per-region to take effect |

### Connectivity Topologies

**Hub-and-Spoke:**
```
                    Hub VNet (shared services: DNS, Firewall, VPN GW)
                         │
         ┌───────────────┼───────────────┐
         │               │               │
      Spoke A         Spoke B         Spoke C
    (workload 1)    (workload 2)    (workload 3)
```

**Mesh (direct spoke-to-spoke):**
- All VNets in group peer with each other directly
- Useful when spokes need direct low-latency communication

### Security Admin Rules

```
Priority   Action   Src            Dst              Port    Direction
────────   ──────   ───────────    ──────────────   ─────   ─────────
100        Allow    CorpNetwork    VirtualNetwork   443     Inbound   (allow HTTPS from corp)
200        Deny     Internet       VirtualNetwork   22      Inbound   (block SSH from internet)
300        Always   *              10.0.0.0/8       *       *         (overrides any local NSG)
```

**WHY Admin Rules matter:** Local NSG admins cannot override Security Admin Rules — enforces compliance at scale across hundreds of VNets.

---

## 14. Storage Accounts

> **Mental Model:** A Storage Account is a postal hub with different departments — Blob (parcels warehouse), File (filing cabinets), Queue (outbox trays), Table (card catalogue).

```
┌────────────────────────────────────────────────────────────────────┐
│                    STORAGE ACCOUNT SERVICES                        │
├──────────────┬─────────────────────────────────────────────────────┤
│     Blob     │  Object storage. Hot/Cool/Cold/Archive tiers.       │
│              │  Block blobs (files), Append blobs (logs),          │
│              │  Page blobs (VHDs). CDN origin, static website.     │
├──────────────┼─────────────────────────────────────────────────────┤
│  Azure Files │  SMB/NFS file shares. Mount on VMs, AKS, on-prem.  │
│              │  Replaces on-prem file servers.                     │
├──────────────┼─────────────────────────────────────────────────────┤
│    Queue     │  Simple message queue. 64KB per message. 7-day TTL. │
│              │  AT-LEAST-ONCE delivery. Simpler than Service Bus.  │
├──────────────┼─────────────────────────────────────────────────────┤
│    Table     │  NoSQL key-value store. PartitionKey + RowKey.      │
│              │  Cheap, schemaless. Use CosmosDB for more features. │
└──────────────┴─────────────────────────────────────────────────────┘
```

### Blob Tiers & Lifecycle Management

| Tier | Access | Latency | Cost | Use Case |
|------|--------|---------|------|----------|
| Hot | Frequent | ms | High storage, low access | Active data |
| Cool | Infrequent | ms | Lower storage, higher access | 30-day minimum |
| Cold | Rare | ms | Even lower | 90-day minimum |
| Archive | Rare | Hours (rehydrate) | Cheapest storage | Long-term retention |

```json
// ── Lifecycle Policy — auto-tier blobs ───────────────────────────────
{
  "rules": [
    {
      "name": "tiering-policy",
      "type": "Lifecycle",
      "definition": {
        "filters": { "blobTypes": ["blockBlob"] },
        "actions": {
          "baseBlob": {
            "tierToCool": { "daysAfterModificationGreaterThan": 30 },
            "tierToArchive": { "daysAfterModificationGreaterThan": 180 },
            "delete": { "daysAfterModificationGreaterThan": 2555 }
          }
        }
      }
    }
  ]
}
```

### Redundancy Options

| Option | Description | SLA | Durability | Region |
|--------|-------------|-----|-----------|--------|
| LRS | 3 copies in one datacenter | 99.9% | 11 9s | Single |
| ZRS | 3 copies across 3 AZs | 99.9% | 12 9s | Single |
| GRS | LRS + async to secondary region | 99.9%/99% | 16 9s | Paired |
| GZRS | ZRS + async to secondary region | 99.9%/99% | 16 9s | Paired |
| RA-GRS | GRS + read from secondary | 99.99% | 16 9s | Paired |

**WHY choose ZRS over LRS for production:** Single datacenter failure (fire, flooding) takes LRS down. ZRS survives full AZ outage.

### SAS Tokens — Types & Best Practices

```csharp
// ── User Delegation SAS (preferred — uses Entra ID, not account key) ─
var userDelegationKey = await blobServiceClient.GetUserDelegationKeyAsync(
    startsOn: DateTimeOffset.UtcNow,
    expiresOn: DateTimeOffset.UtcNow.AddHours(1));  // WHY: Short TTL limits blast radius

var sasBuilder = new BlobSasBuilder
{
    BlobContainerName = "uploads",
    BlobName = blobName,
    Resource = "b",
    StartsOn = DateTimeOffset.UtcNow,
    ExpiresOn = DateTimeOffset.UtcNow.AddMinutes(15),  // WHY: Upload SAS — 15min is enough
    Protocol = SasProtocol.Https,                       // WHY: Never allow HTTP
    IPRange = new SasIPRange(userClientIp)              // WHY: Bind to client IP
};
sasBuilder.SetPermissions(BlobSasPermissions.Write | BlobSasPermissions.Create);

var sasToken = sasBuilder.ToSasQueryParameters(userDelegationKey, accountName).ToString();
```

| SAS Type | Key Used | Best For |
|----------|----------|---------|
| Account SAS | Storage Account Key | Full account access (avoid) |
| Service SAS | Storage Account Key | Specific resource (legacy) |
| User Delegation SAS | Entra ID token | Preferred — short-lived, auditable |

### Storage Account Security Checklist

- [ ] Disable public blob access (container-level public is off by default in new accounts)
- [ ] Enforce HTTPS-only (`supportsHttpsTrafficOnly: true`)
- [ ] Enable Soft Delete for blobs (7-365 days recovery window)
- [ ] Enable versioning for critical data
- [ ] Use Private Endpoints — disable public network access
- [ ] Enable Azure Defender for Storage (malware scanning, threat detection)
- [ ] Rotate storage account keys via Key Vault or use Managed Identity
- [ ] Enable blob change feed for audit trail

---

## 15. Azure Well-Architected Framework

> **Mental Model:** The WAF is like a building code inspector — 5 inspectors (pillars) each check a different aspect: structural safety (reliability), fire safety (security), energy efficiency (cost), elevator speed (performance), and ease of maintenance (operational excellence).

```
┌────────────────────────────────────────────────────────────────┐
│               AZURE WELL-ARCHITECTED FRAMEWORK                 │
│                                                                │
│  ┌──────────────┐  ┌────────────┐  ┌──────────────────────┐  │
│  │  Reliability │  │  Security  │  │ Cost Optimization     │  │
│  │             │  │            │  │                       │  │
│  │ Design for  │  │ Zero Trust │  │ Right-size resources  │  │
│  │ failure     │  │ Encrypt    │  │ Elasticity            │  │
│  │ HA, DR, RTO │  │ everywhere │  │ Reserved Instances    │  │
│  └──────────────┘  └────────────┘  └──────────────────────┘  │
│  ┌──────────────────────────────┐  ┌──────────────────────┐  │
│  │  Performance Efficiency      │  │ Operational Excellence│  │
│  │                              │  │                       │  │
│  │ Correct resource types       │  │ IaC, CI/CD            │  │
│  │ Caching, async patterns      │  │ Observability         │  │
│  │ Scale out not up             │  │ Runbooks, chaos eng.  │  │
│  └──────────────────────────────┘  └──────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ + Sustainability (6th pillar — added 2023)               │ │
│  │  Carbon efficiency, reduce idle resources, carbon-aware  │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

---

### Pillar 1: Reliability

**Core Concepts:**
- **RTO (Recovery Time Objective):** Max acceptable downtime after failure
- **RPO (Recovery Point Objective):** Max acceptable data loss (in time)
- **SLA:** What Microsoft guarantees; **SLO:** What you target; **SLI:** What you measure

| RTO | RPO | Strategy |
|-----|-----|----------|
| Hours | Hours | Backup & Restore (cold DR) |
| Minutes | Minutes | Warm standby (scaled-down replica) |
| Seconds | Seconds | Active-Active multi-region |
| Zero | Zero | Chaos-tested HA with auto-failover |

**Key Patterns:**
- **Availability Zones:** Spread VMs/App Services across 3 AZs within region
- **Health Model:** Define what "healthy" means per service, not just "ping responds"
- **Chaos Engineering:** Deliberately inject failures to find weaknesses (Azure Chaos Studio)
- **Graceful Degradation:** Return cached data when DB is down, rather than returning 500

```csharp
// WHY: Health check should reflect business readiness, not just HTTP 200
builder.Services.AddHealthChecks()
    .AddSqlServer(connectionString, name: "sqldb", tags: ["critical"])
    .AddRedis(redisConnection, name: "redis", tags: ["cache"])
    .AddAzureServiceBusQueue(sbConnection, queueName, name: "servicebus")
    .AddCheck<CustomBusinessHealthCheck>("business-rules", tags: ["critical"]);

// WHY: Separate liveness (is the process alive?) from readiness (can it serve traffic?)
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("liveness")
});
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("critical")
});
```

---

### Pillar 2: Security

**Zero Trust Principles:**
1. **Verify explicitly** — always authenticate and authorize (never implicit trust)
2. **Use least privilege** — minimum permissions needed
3. **Assume breach** — design as if the attacker is already inside

**Key Controls:**
| Layer | Control |
|-------|---------|
| Identity | MFA, Conditional Access, PIM, Managed Identity |
| Network | Private Endpoints, NSG, Azure Firewall, WAF |
| Data | Encryption at rest (AES-256), in transit (TLS 1.2+), at process (CMK) |
| Application | Input validation, OWASP Top 10, dependency scanning |
| Monitoring | Defender for Cloud, Sentinel (SIEM), audit logs |

**Encryption Key Hierarchy:**
```
Azure managed key (free, transparent)
  ↑ upgrade
Customer-Managed Key (CMK) in Key Vault (you control rotation)
  ↑ upgrade
Customer-Provided Key (CPK) — you provide key per-request (Blob only)
```

---

### Pillar 3: Cost Optimization

(See Section 16 for detail)

**Quick Principles:**
- **Measure before optimizing** — use Azure Cost Analysis, Advisor
- **Right-size:** Use SKU recommendations; don't over-provision "just in case"
- **Elasticity:** Scale down to zero when idle (Consumption plan, Container Apps)
- **Reserved Instances / Savings Plans:** Commit 1-3 years for 40-72% discount

---

### Pillar 4: Performance Efficiency

**Key Principles:**
- Use the right data store for each workload (don't use SQL for everything)
- Cache aggressively at every layer (CDN → Redis → in-memory)
- Design for horizontal scale (stateless services)
- Avoid N+1 queries (use `.Include()` or projections, not lazy loading in loops)
- Use async I/O everywhere (non-blocking threads)

**Performance Testing Types:**
| Test | Description |
|------|-------------|
| Load Test | Gradual ramp-up to expected load |
| Stress Test | Beyond limits — find the breaking point |
| Soak Test | Sustained load over hours/days — find memory leaks |
| Spike Test | Sudden traffic burst — test elasticity |

```csharp
// WHY: Parallel I/O calls — don't await sequentially if calls are independent
var (products, inventory, prices) = await (
    productService.GetProductsAsync(ids),
    inventoryService.GetInventoryAsync(ids),
    pricingService.GetPricesAsync(ids)
).WhenAll();   // 3 calls in parallel instead of sequential 3x latency
```

---

### Pillar 5: Operational Excellence

**Key Practices:**
- **Infrastructure as Code:** All resources in Bicep/Terraform — no manual portal changes
- **GitOps:** Code change → automated pipeline → deployment (no manual deployments)
- **Observability:** Logs + Metrics + Traces correlated by correlation ID
- **Runbooks:** Documented response procedures for each alert type
- **Game Days:** Scheduled chaos exercises to practice incident response
- **Feature Flags:** Decouple deployment from release (LaunchDarkly, Azure App Configuration)

```yaml
# ── Azure DevOps Pipeline — Safe Deployment Strategy ─────────────────
stages:
- stage: Dev
  jobs: [Build, Test, DeployDev]
- stage: Staging
  dependsOn: Dev
  jobs: [DeployStaging, SmokeTest, PerformanceTest]
- stage: Production
  dependsOn: Staging
  jobs:
  - deployment: BlueGreen     # WHY: Zero-downtime swap
    strategy:
      runOnce:
        deploy:
          steps:
          - script: az webapp deployment slot swap ...
          - script: run smoke tests against production
          - script: roll back if smoke tests fail
```

---

## 16. Cost Optimization Techniques

> **Mental Model:** Cloud cost optimization is like managing a hotel — some rooms need to always be ready (reserved), some can be vacant when quiet (consumption), and others can be rented out short-notice at discount (spot). Matching the room type to the booking pattern is the skill.

### Cost Optimization Levers

```
┌──────────────────────────────────────────────────────────────────┐
│               COST OPTIMIZATION FRAMEWORK                        │
├─────────────────────┬────────────────────────────────────────────┤
│  VISIBILITY         │  Azure Cost Analysis, Cost Alerts,         │
│                     │  Cloudability, Apptio                       │
├─────────────────────┼────────────────────────────────────────────┤
│  RIGHT-SIZING       │  Advisor right-size, Compute resize,       │
│                     │  AKS node pool right-sizing                │
├─────────────────────┼────────────────────────────────────────────┤
│  COMMITMENT         │  Reserved Instances, Savings Plans,        │
│  DISCOUNTS          │  Azure Hybrid Benefit                      │
├─────────────────────┼────────────────────────────────────────────┤
│  ELASTICITY         │  Auto-scale, scale to zero, spot VMs,     │
│                     │  Consumption-based services                │
├─────────────────────┼────────────────────────────────────────────┤
│  ARCHITECTURE       │  Serverless, managed services, tiered      │
│  CHOICES            │  storage, CDN offload, caching             │
└─────────────────────┴────────────────────────────────────────────┘
```

### Reserved Instances vs Savings Plans

| | Reserved Instances | Azure Savings Plans |
|--|---------------------|---------------------|
| Discount | Up to 72% | Up to 65% |
| Commitment | Specific VM size/region | Hourly spend commitment |
| Flexibility | Low (size/region locked) | High (any compute) |
| Term | 1 or 3 years | 1 or 3 years |
| Use When | Stable, predictable VMs | Mixed/flexible compute |

### Azure Hybrid Benefit

- Use existing Windows Server licenses → save up to 40% on Windows VMs
- Use existing SQL Server licenses → save up to 55% on Azure SQL
- Use on-prem Red Hat / SUSE licenses for Linux VMs

### Spot VMs / Spot Node Pools

- **Discount:** Up to 90% off pay-as-you-go
- **Risk:** Evicted with 30-second notice when Azure needs capacity
- **Use For:** Batch jobs, CI/CD agents, rendering, dev/test, stateless workloads

```yaml
# ── AKS Spot Node Pool ───────────────────────────────────────────────
nodePoolProfiles:
- name: spotpool
  vmSize: Standard_D4s_v3
  scaleSetPriority: Spot        # WHY: Spot = preemptible, heavily discounted
  spotMaxPrice: -1              # WHY: -1 = pay up to on-demand price (maximize availability)
  evictionPolicy: Delete        # WHY: Pods must be rescheduled to regular pool on eviction
  nodeTaints:
  - "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
```

### Storage Cost Optimization

```
Blob Lifecycle → Hot (0-30d) → Cool (30-90d) → Cold (90-180d) → Archive (180d+)
                                                                    │
                                                              Legal hold / compliance
```

- **Reserved Capacity:** Commit to 100TB+ for 10-38% discount on storage
- **Blob tiering:** Lifecycle policies auto-move blobs to cheaper tiers
- **Snapshot cleanup:** Enable soft delete + auto-delete old snapshots
- **Compression:** Gzip responses (CDN + App Gateway) — reduces bandwidth costs

### Compute Cost Patterns

| Resource | Cost-Saving Technique |
|----------|----------------------|
| VMs | Resize, RI, Hybrid Benefit, auto-shutdown dev VMs at 6pm |
| App Service | Scale down at off-peak, use Consumption plan for low traffic |
| AKS | Cluster autoscaler + HPA + Spot node pools, scale to zero namespaces |
| Azure SQL | Serverless tier (pauses after idle), elastic pools (share DTUs) |
| Azure Functions | Consumption plan (pay per invocation) |
| Containers | Container Apps with scale-to-zero |

### Cost Governance

```
FinOps Maturity Stages:
Crawl: visibility (tags, budgets, alerts)
Walk:  optimization (right-size, RI, auto-shutdown)
Run:   optimization culture (chargeback, showback, engineering ownership)
```

**Tagging strategy for cost allocation:**
```json
{
  "Environment": "Production",
  "CostCenter": "Engineering-Platform",
  "Application": "OrderService",
  "Team": "backend-core",
  "Tier": "Critical"
}
```

**Azure Policy — enforce tags:**
```json
{
  "if": { "field": "tags['CostCenter']", "exists": "false" },
  "then": { "effect": "deny" }
}
```

### Azure Advisor Cost Recommendations

- Shutdown idle VMs (CPU < 5% for 7+ days)
- Right-size underutilized VMs
- Buy Reserved Instances for consistent usage
- Delete unattached managed disks
- Remove unused public IP addresses
- Move infrequently accessed storage to cheaper tier

---

## 17. Top Interview Q&A

### Cloud Design Patterns

**Q1: How do you decide between Choreography and Orchestration for a Saga?**

> Use **Choreography** when services should be loosely coupled and you're comfortable tracing flows via events. Use **Orchestration** (Durable Functions) when you need a clear audit trail, complex branching logic, timeout/compensation, or human-in-the-loop steps. For new greenfield microservices with simpler flows, choreography is often better; for complex business processes, orchestration wins on debuggability.

**Q2: How does the Outbox Pattern prevent message loss in distributed systems?**

> In a transaction, both the DB write and the outbox event insert are committed atomically. A background worker (or CDC — Change Data Capture via Debezium) polls the outbox table and publishes events. This decouples "did I write?" from "did I publish?" The consumer must be idempotent because at-least-once delivery means duplicate events may arrive.

**Q3: When would you use Event Sourcing, and what are its downsides?**

> **Use it when:** you need a complete audit trail (financial systems, medical records), temporal queries ("what was state at time T?"), or want to derive multiple projections from the same event stream. **Downsides:** querying current state requires replay or a projection; schema evolution of events is hard (old events must still be replayable); eventual consistency means read models are slightly stale; operational complexity (snapshots needed for long-lived aggregates).

---

### Azure Services

**Q4: What's the difference between Event Grid, Event Hubs, and Service Bus? When would you use each?**

> - **Event Grid:** Reactive to state changes (blob uploaded, VM deleted). Fan-out to many subscribers with filtering. Push-based, not designed for ordering or high throughput streaming.
> - **Event Hubs:** High-throughput streaming (millions of events/sec). Partitioned log, multiple consumer groups reading independently. Kafka-compatible. Use for telemetry, clickstream, IoT.
> - **Service Bus:** Reliable messaging for commands/tasks between services. Guaranteed delivery, dead-letter queue, sessions for ordering, transactions. Use for business workflows between microservices.

**Q5: How would you ensure zero cold starts on Azure Functions?**

> Use **Premium Plan** with pre-warmed instances (always-ready instances configured). In Consumption plan, use Azure Functions **Warm-up trigger** (host.json `healthMonitor.enabled`) or **Durable Entities** to maintain state. For Flex Consumption: configure minimum instance count. Alternatively, move latency-sensitive code to App Service or Container Apps.

**Q6: How does Entra ID Managed Identity work under the hood?**

> Azure creates a service principal in Entra ID and automatically provisions and rotates the credential (certificate). Your app requests a token from the **IMDS endpoint** (`169.254.169.254/metadata/identity/oauth2/token`) — this is accessible only from inside the Azure resource. The IMDS validates the VM/App Service identity and returns a JWT scoped to the requested resource. No secret ever leaves Azure's control plane.

**Q7: How would you architect APIM for a zero-downtime API versioning strategy?**

> Use **URL versioning** (`/api/v1/`, `/api/v2/`) or **header versioning** (`Api-Version: 2024-01`). In APIM, create separate API revisions (for non-breaking changes) or API versions (for breaking changes). Set the current revision as default. Route V1 and V2 to the same or different backends. Use APIM Versions + Revision: V2 backend can be a new microservice; V1 routes to the monolith (Strangler Fig pattern).

**Q8: What is the difference between Application Gateway WAF and Azure Front Door WAF?**

> **Application Gateway WAF:** Regional L7 LB. Use when traffic doesn't cross regions, you need cookie-based affinity, WebSocket support, or AKS Ingress via AGIC. **Front Door WAF:** Global Anycast network, routes to the closest POP. Use for multi-region, global performance, DDoS protection at global edge. Both support OWASP CRS; Front Door adds bot protection, geo-filtering at global scale. For maximum protection: Front Door (global edge) + App Gateway (regional, before AKS).

**Q9: How does Private Endpoint DNS resolution work, and what breaks if you configure it wrong?**

> When a Private Endpoint is created, the service's FQDN (e.g., `mystorageaccount.blob.core.windows.net`) gets a CNAME to `mystorageaccount.privatelink.blob.core.windows.net`. A Private DNS Zone (`privatelink.blob.core.windows.net`) linked to the VNet resolves this to the private IP. **If the DNS zone isn't linked:** the CNAME resolves via public DNS to the public IP — the private endpoint exists but isn't used. Traffic goes over the internet. Fix: link Private DNS Zones to all VNets and ensure on-prem DNS forwards Azure zones to 168.63.129.16.

**Q10: What are the consistency levels in Azure Cosmos DB and when would you use each?**

> 5 levels from strong → eventual:
> - **Strong:** Linearizable reads — most consistent, highest latency, single-region only for writes
> - **Bounded Staleness:** Reads lag behind writes by K versions or T seconds — predictable lag
> - **Session (default):** Read-your-own-writes within a session — best balance for most apps
> - **Consistent Prefix:** Never see out-of-order writes, may see stale data
> - **Eventual:** Lowest latency/cost, no ordering guarantees — use for counters, social feeds

**Q11: How would you implement distributed rate limiting across multiple API instances?**

> Don't use in-memory counters — they're per-instance and don't reflect true request rate. Use **Redis with a Lua sliding window script** (atomic increment + TTL) as shared state. All instances check the same Redis key (`ratelimit:{clientId}:{window}`). For very high scale, use **Azure API Management** rate-limit policy (managed, distributed). For token-bucket algorithm, use Redis `INCR` + `EXPIRE`. Ensure Redis is Premium tier with replication for HA.

**Q12: Traffic Manager vs Front Door — when to use which?**

> **Traffic Manager:** Pure DNS-based global routing. Zero latency overhead. No SSL termination, no WAF, no proxy. Use when you don't need HTTP features, just global failover or geographic routing. Ideal for non-HTTP protocols or when you have App Gateway/Front Door at each region already.
>
> **Front Door:** HTTP proxy at global edge (150+ PoPs). SSL termination, WAF, URL rewriting, caching, HTTP/2, WebSockets. Lower latency for HTTP because it terminates TCP at the nearest PoP. Use as the primary global entry point for HTTP(S) workloads.

**Q13: How do you implement multi-tenancy in Azure architecture?**

> Three models:
> - **Silo (dedicated per tenant):** Each tenant gets their own Azure SQL DB / App Service. Highest isolation, highest cost.
> - **Pool (shared with row-level security):** All tenants in shared DB, tenant ID in every row, Row Level Security (RLS) enforces isolation. Cheapest, lowest isolation.
> - **Bridge (hybrid):** Shared compute, per-tenant data store (e.g., separate CosmosDB containers or partitions). Balance of cost and isolation.
>
> Use **Entra ID B2C** for external tenant identity. Use **APIM subscriptions** per tenant for rate limiting. Tag all resources with `TenantId` for cost allocation.

**Q14: How would you design a system to handle 1 million events per second on Azure?**

> 1. **Ingestion:** Azure Event Hubs (32 partitions × ~25K events/partition/sec) — Scale TUs to needed throughput. Enable Kafka protocol for existing producers.
> 2. **Processing:** Azure Stream Analytics (real-time SQL queries over streams) or Azure Functions with Event Hub trigger (1 function instance per partition).
> 3. **Storage:** Azure Data Lake Gen2 (raw data via Event Hubs Capture), Cosmos DB (hot path, low-latency queries), Azure Synapse (cold path analytics).
> 4. **Monitoring:** Application Insights for processing lag metrics; alert on consumer lag (checkpoint offset − latest offset > threshold).

**Q15: What is the Azure Well-Architected Framework, and how would you apply it in a design review?**

> WAF is Microsoft's set of architectural best practices across 5 (now 6) pillars: Reliability, Security, Cost Optimization, Performance Efficiency, Operational Excellence, and Sustainability. In a design review, I use the WAF assessment tool in Azure portal, run through checklists per pillar, score current state, and identify top risks. Example: for a new microservice, check: does it have health endpoints (Reliability)? Does it use Managed Identity (Security)? Is it on the right compute tier (Cost)? Is it async (Performance)? Is it deployed via IaC (OpEx)?

---

### Reliability & HA

**Q16: What is the difference between active-active and active-passive multi-region?**

> - **Active-Passive (warm standby):** Primary region handles all traffic. Secondary is on but idle (or scaled down). On failure, failover via Traffic Manager DNS switch. RTO: minutes (DNS TTL + failover). RPO: seconds to minutes (async replication lag).
> - **Active-Active:** Both regions handle live traffic simultaneously. Traffic Manager/Front Door load balances between them. On failure, surviving region absorbs all traffic. RTO: near-zero (automatic). RPO: near-zero (synchronous or near-synchronous replication). **Complexity:** requires conflict-free data writes (Cosmos DB multi-write, SQL Always On) — much harder to implement correctly.

**Q17: How do you implement blue-green deployment in Azure?**

> **App Service:** Deployment Slots — deploy to `staging` slot, run smoke tests, then `az webapp deployment slot swap --slot staging` (atomic slot swap, zero downtime). Instantly roll back by swapping again.
>
> **AKS:** Two Deployments (`blue` and `green`), one Service pointing to current. Update service selector to switch traffic. Or use NGINX Ingress weighted routing to gradually shift traffic.
>
> **API Management:** Revisions — new revision is staging, make it current when validated.

---

### Security

**Q18: How would you secure secrets in an AKS-hosted application?**

> **Never use Kubernetes Secrets directly** — they're base64 (not encrypted by default). Options:
> 1. **Azure Key Vault + CSI Driver (preferred):** Mount Key Vault secrets as files/env vars via `SecretProviderClass`. Uses Workload Identity (pod-level Managed Identity) — no stored credentials.
> 2. **Azure Key Vault + Workload Identity SDK:** App reads secrets at runtime using DefaultAzureCredential with Workload Identity.
> 3. **Enable Kubernetes Secrets encryption at rest** (etcd encryption) as a baseline.
> Never: store secrets in ConfigMaps, environment variables in Dockerfiles, or plain Kubernetes Secrets without encryption.

**Q19: What is PKCE and why is it required for SPAs?**

> PKCE (Proof Key for Code Exchange) prevents authorization code interception attacks in public clients (SPAs, mobile apps). Flow:
> 1. Client generates a random `code_verifier`
> 2. Client sends SHA-256 hash (`code_challenge`) in the auth request
> 3. Authorization server stores the challenge
> 4. When exchanging the code for a token, client sends the original `code_verifier`
> 5. Server verifies hash(verifier) == stored challenge
>
> Without PKCE, a malicious app intercepting the authorization code could exchange it for tokens. SPAs can't store client secrets securely (the secret is in browser JS), so PKCE replaces the secret.

---

### Cost

**Q20: A team's Azure bill doubled this month. Walk me through how you'd investigate.**

> 1. **Azure Cost Analysis:** Group by resource type, resource group, and tag — identify top 3 cost drivers
> 2. **Check for untagged resources:** Untagged resources might be orphaned or newly created
> 3. **Look for:**
>    - Unintentional data transfer/egress charges (cross-region, internet egress)
>    - VMs running 24/7 that should be dev (auto-shutdown missing)
>    - Storage blob access tier mismatch (archive being accessed = rehydration cost)
>    - Log Analytics over-ingestion (a service started logging verbosely)
>    - DDoS or traffic spike (Event Hubs TU auto-inflate)
>    - Missing RI — VMs running on PAYG that should be reserved
> 4. **Set up Cost Alerts** for future anomalies (Budget alerts at 80% / 100% threshold)
> 5. **Enable Azure Advisor** recommendations and prioritize top cost items

---

### Networking

**Q21: You have a VNet with 10 spoke VNets that all need to communicate with each other and a shared hub. How do you manage this at scale?**

> Use **Azure Virtual Network Manager**. Create a Network Group with all 11 VNets. Apply a Connectivity Configuration with hub-spoke topology pointing to the hub VNet. For spoke-to-spoke communication, enable **direct spoke connectivity** (mesh between spokes within the group) or route all spoke-to-spoke via hub Azure Firewall for inspection. Use **Security Admin Configs** for centrally enforced NSG-like rules (e.g., block internet from all spokes regardless of local NSG overrides). This scales to hundreds of VNets without manually managing N*(N-1)/2 peerings.

**Q22: Explain how you'd ensure a microservice's database is never reachable from the public internet.**

> 1. **Private Endpoint** on Azure SQL/CosmosDB — assigns private IP in the VNet
> 2. **Disable public network access** on the database resource
> 3. **Private DNS Zone** (`privatelink.database.windows.net`) linked to VNet — FQDN resolves to private IP
> 4. **NSG on subnet** — allow only the app's subnet to reach port 1433, deny all other traffic
> 5. **Azure Firewall** in hub — all outbound internet blocked; only approved FQDNs allowed
> 6. **For AKS:** Configure Azure SQL connection from within the VNet using the private endpoint, validate via `nslookup` that the FQDN resolves to 10.x.x.x not the public IP

---

### Storage & Data

**Q23: When would you use Azure Storage Queue vs Azure Service Bus?**

> **Storage Queue:** Simple, cheap ($0.004/10K operations), up to 64KB per message, 7-day max TTL, at-least-once delivery, no dead-letter. Use for simple background job queuing, telemetry pipelines, or when cost and simplicity matter most.
>
> **Service Bus:** Advanced features — sessions (ordered delivery), dead-letter queue, duplicate detection, transactions, 256KB–100MB messages, 14-day TTL, topic/subscription pub-sub. Use for business-critical workflows, complex routing, guaranteed delivery with DLQ.
>
> Rule of thumb: if you'd reach for RabbitMQ features, use Service Bus. If you just need a task queue, Storage Queue suffices.

---

### Redis

**Q24: How do you handle cache stampede (thundering herd) when cache expires?**

> **Problem:** When a hot cache key expires, hundreds of concurrent requests all miss the cache and hammer the DB simultaneously.
>
> **Solutions:**
> - **Mutex/Lock:** First request acquires a distributed lock (Redis `SET NX PX`), fetches from DB, populates cache. Others wait and then hit the cache. Adds latency for lock waiters.
> - **Probabilistic Early Expiration (XFetch):** Randomly re-fetch slightly before actual expiry — smooths out the spike.
> - **Background refresh:** Don't set TTL-based expiry; instead, a background worker proactively refreshes before expiry.
> - **Stale-while-revalidate:** Serve stale data to all concurrent requests; one async task refreshes in the background (HTTP Cache-Control: stale-while-revalidate pattern, implementable with Redis).

---

### Observability

**Q25: How do you correlate traces across microservices in Azure?**

> Use **W3C TraceContext** (`traceparent` / `tracestate` headers) propagated in every HTTP call and message. In ASP.NET Core + OpenTelemetry, this is automatic with `AddAspNetCoreInstrumentation()` + `AddHttpClientInstrumentation()`. Each service adds spans to the same trace (same `traceId`). In Application Insights, use `operation_Id` to correlate — query: `union traces, requests, dependencies | where operation_Id == "abc123"`. For Service Bus / Event Hubs, propagate `Diagnostic-Id` in message properties.

---

### Quick-Fire Answers

| Question | Answer |
|----------|--------|
| What is Azure Availability Zone? | Physically separate datacenters within a region (independent power, cooling, networking). VMs spread across AZs survive single datacenter failure. |
| What is the difference between scale up and scale out? | Scale up = bigger VM (vertical); Scale out = more instances (horizontal). Always prefer scale out for cloud-native (stateless). |
| How many partitions should Event Hubs have? | Match to peak parallel consumers needed; partitions can't be reduced after creation. Default 4; max 2048 (Standard). |
| What is KEDA? | Kubernetes Event-Driven Autoscaler — scales pods based on external queue depth (Service Bus, Event Hubs, Kafka, etc.) including scale-to-zero. |
| What is Dapr? | Distributed Application Runtime — sidecar providing state, pub-sub, service invocation, secret management as standard APIs, abstracting the underlying Azure service. |
| What is the maximum message size in Service Bus? | Standard: 256KB. Premium: up to 100MB (with message sessions). |
| How does Azure AD token validation work? | Validate signature (using JWKS endpoint), issuer, audience, expiry. ASP.NET Core `AddMicrosoftIdentityWebApi` does this automatically. |
| What is the difference between NSG and Azure Firewall? | NSG: L4 filter on VNet subnet/NIC — allow/deny by IP/port. Azure Firewall: L4+L7 managed firewall, FQDN filtering, threat intelligence, TLS inspection, centrally managed. |
| What is Managed Disk vs Unmanaged Disk? | Managed Disk: Azure manages the underlying storage account. Unmanaged: you create/manage storage accounts yourself. Always use Managed Disks. |
| What does "idempotent" mean in messaging? | Processing the same message multiple times produces the same result as processing it once. Required for at-least-once delivery systems. |

---

## Quick Reference — Decision Trees

### Compute Decision Tree

```
Need to run code?
│
├─ Event-driven / short bursts (<10min)?
│   └─► Azure Functions (Consumption)
│
├─ Containerized workload?
│   ├─ Need full Kubernetes control? ──► AKS
│   └─ Want managed, less ops? ────────► Container Apps
│
├─ Web app / API, no containers?
│   ├─ Simple web app? ─────────────────► App Service
│   └─ Static SPA? ─────────────────────► Static Web Apps
│
└─ Need full VM control (legacy, GPU, special OS)?
    └─► Azure Virtual Machines
```

### Storage Decision Tree

```
What are you storing?
│
├─ Files / blobs (documents, images, backups)? ──► Azure Blob Storage
├─ Relational data, ACID, complex queries? ──────► Azure SQL Database
├─ Global, multi-region, NoSQL, schemaless? ─────► Azure Cosmos DB
├─ High-speed key-value cache? ──────────────────► Azure Cache for Redis
├─ Time-series data (metrics, IoT)? ─────────────► Azure Data Explorer
├─ SMB file share (mount on VMs)? ──────────────► Azure Files
├─ Data warehouse, analytical queries? ──────────► Azure Synapse Analytics
└─ Simple message queue? ────────────────────────► Azure Storage Queue
```

### Networking / Connectivity Decision Tree

```
Exposing to internet?
├─ Single region HTTP? ──────────────────────────► App Gateway (+ WAF)
├─ Multi-region global HTTP? ────────────────────► Front Door (+ WAF)
├─ DNS-based global routing (non-HTTP)? ─────────► Traffic Manager
└─ No internet — internal only? ─────────────────► Internal Load Balancer

Connecting services privately?
├─ App → Azure PaaS (SQL, Storage, etc.)? ──────► Private Endpoint
├─ On-prem → Azure? ─────────────────────────────► ExpressRoute / VPN Gateway
└─ Azure VNet → Azure VNet? ─────────────────────► VNet Peering / VNet Manager
```

---

*End of QuickPrep — Azure Services & Cloud Design Patterns*
*Total coverage: 14 Azure services + 14 cloud patterns + WAF 5 pillars + cost optimization + 25 Q&As*
