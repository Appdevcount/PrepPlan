# Day 10: Azure Core Services - Deep Dive

## Overview
Master Azure's core services with a focus on service selection, integration patterns, and architectural trade-offs. This guide covers essential decision-making frameworks for cloud architects.

---

## 1. Service Selection Decision Trees

### App Service vs Container Apps vs AKS

```
Decision Tree:
┌─────────────────────────────────────┐
│ Do you need full K8s API access?   │
│         YES → AKS                   │
└─────────────────────────────────────┘
              │ NO
              ↓
┌─────────────────────────────────────┐
│ Microservices with event-driven     │
│ scale-to-zero requirements?         │
│         YES → Container Apps        │
└─────────────────────────────────────┘
              │ NO
              ↓
┌─────────────────────────────────────┐
│ Traditional web app or API?         │
│         YES → App Service           │
└─────────────────────────────────────┘
```

#### App Service
**Best For:**
- Traditional web applications
- REST APIs with predictable traffic
- Quick deployment without container expertise
- Built-in CI/CD integration

**Architect's Decision Criteria:**
- **Choose App Service if**: Team lacks container expertise, need fast time-to-market, traditional monolith/modular monolith
- **Cost model**: Always running (no scale-to-zero), predictable monthly cost
- **Scaling limits**: Up to 30 instances (P3v3), good for most applications
- **When to avoid**: Highly variable traffic (paying for idle time), need custom OS/kernel configs

**Pros:**
- Fully managed platform (PaaS)
- Built-in deployment slots
- Easy SSL/TLS management
- Auto-scaling based on metrics
- Integrated authentication

**Cons:**
- Limited customization of runtime environment
- Windows-based can be expensive
- No scale-to-zero capability

**Configuration Example:**
```json
{
  "name": "my-app-service",
  "location": "eastus",
  "sku": {
    "name": "P1v3",
    "tier": "PremiumV3",
    "capacity": 2
  },
  "properties": {
    "serverFarmId": "/subscriptions/.../serverfarms/my-plan",
    "siteConfig": {
      "netFrameworkVersion": "v8.0",
      "alwaysOn": true,
      "http20Enabled": true,
      "minTlsVersion": "1.2",
      "ftpsState": "Disabled",
      "healthCheckPath": "/health"
    }
  }
}
```

#### Container Apps
**Best For:**
- Event-driven microservices
- Background workers with variable load
- KEDA-based auto-scaling scenarios
- Cost-sensitive workloads (scale-to-zero)

**Architect's Decision Criteria:**
- **Choose Container Apps if**: Microservices architecture, sporadic/bursty traffic, need Dapr for service mesh
- **Cost model**: Pay for actual usage, scales to zero = significant savings for low-traffic services
- **Trade-off**: Less control than AKS, but much simpler to manage
- **Real-world use case**: Background job processors that run hourly - only pay for those minutes

**Pros:**
- Scale to zero (cost savings)
- KEDA-based event-driven scaling
- Dapr integration for microservices
- Managed ingress and service discovery
- Simpler than AKS

**Cons:**
- Limited Kubernetes API access
- Newer service (less mature)
- Less control over infrastructure

**Configuration Example:**
```yaml
properties:
  configuration:
    activeRevisionsMode: Multiple
    ingress:
      external: true
      targetPort: 8080
      traffic:
      - latestRevision: true
        weight: 100
    dapr:
      enabled: true
      appId: order-processor
      appPort: 8080
    secrets:
    - name: queue-connection
      value: "..."
  template:
    containers:
    - image: myregistry.azurecr.io/orderapi:v1
      name: order-api
      resources:
        cpu: 0.5
        memory: 1Gi
    scale:
      minReplicas: 0
      maxReplicas: 10
      rules:
      - name: queue-scaling
        custom:
          type: azure-servicebus
          metadata:
            queueName: orders
            messageCount: "5"
```

#### Azure Kubernetes Service (AKS)
**Best For:**
- Complex microservices architectures
- Need full Kubernetes control
- Multi-cloud/hybrid deployments
- Advanced networking requirements

**Pros:**
- Full Kubernetes API access
- Maximum flexibility and control
- Rich ecosystem of tools
- Advanced networking options
- Supports complex deployment patterns

**Cons:**
- Higher operational complexity
- Requires Kubernetes expertise
- More expensive (always-on nodes)
- Longer learning curve

**Key Configuration:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-api
  template:
    metadata:
      labels:
        app: order-api
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: order-api
        image: myregistry.azurecr.io/orderapi:v1
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
```

#### Azure Static Web Apps (For React/Frontend SPAs)

**Best For:**
- React, Vue, Angular applications
- Jamstack sites (Next.js, Gatsby)
- Serverless APIs with Azure Functions
- Global CDN distribution
- Static sites with dynamic API backends

**Architect's Decision Criteria:**
- **Choose Static Web Apps if**: Modern SPA, need global CDN, integrated authentication, GitHub Actions CI/CD
- **Cost model**: Free tier (100GB bandwidth/month), Enterprise tier adds custom domains, SLA
- **When to avoid**: Need server-side rendering at edge (use Azure Front Door + App Service), complex backend requirements

**Pros:**
- Automatic global CDN distribution
- Built-in staging environments (preview URLs per PR)
- Free SSL certificates
- Integrated authentication (Azure AD, GitHub, Twitter, Google)
- Serverless API routes with Azure Functions
- GitHub Actions CI/CD out of the box
- Custom domains with automatic HTTPS

**Cons:**
- Limited to static content + serverless functions
- No control over CDN configuration (compared to Azure CDN)
- Functions limited to HTTP triggers

**Configuration (staticwebapp.config.json):**
```json
{
  "routes": [
    {
      "route": "/api/*",
      "allowedRoles": ["authenticated"]
    },
    {
      "route": "/admin/*",
      "allowedRoles": ["admin"]
    },
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*.{png,jpg,gif}", "/css/*", "/api/*"]
  },
  "responseOverrides": {
    "404": {
      "rewrite": "/index.html",
      "statusCode": 200
    }
  },
  "globalHeaders": {
    "content-security-policy": "default-src 'self' 'unsafe-inline' https:",
    "x-frame-options": "DENY",
    "x-content-type-options": "nosniff",
    "referrer-policy": "strict-origin-when-cross-origin"
  },
  "mimeTypes": {
    ".json": "application/json",
    ".wasm": "application/wasm"
  },
  "platform": {
    "apiRuntime": "node:18"
  }
}
```

**GitHub Actions Deployment:**
```yaml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - main

jobs:
  build_and_deploy:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true

      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/" # App source code path
          api_location: "api" # Api source code path (optional)
          output_location: "build" # Built app content directory (for React: build, for Vue: dist)
        env:
          NODE_VERSION: '18'
          REACT_APP_API_URL: ${{ secrets.API_URL }}

  close_pull_request:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
```

**React App Structure for Static Web Apps:**
```
my-react-app/
├── public/
│   └── staticwebapp.config.json  ← Configuration
├── src/
│   ├── components/
│   └── App.tsx
├── api/                           ← Azure Functions (optional)
│   ├── GetProducts/
│   │   ├── index.ts
│   │   └── function.json
│   └── host.json
└── package.json
```

**Serverless API with Azure Functions:**
```typescript
// api/GetProducts/index.ts
import { AzureFunction, Context, HttpRequest } from "@azure/functions";

const httpTrigger: AzureFunction = async function (
    context: Context,
    req: HttpRequest
): Promise<void> {
    // Access user authentication
    const clientPrincipal = req.headers["x-ms-client-principal"];

    if (!clientPrincipal) {
        context.res = {
            status: 401,
            body: "Unauthorized"
        };
        return;
    }

    // Query database or external API
    const products = await fetchProductsFromDatabase();

    context.res = {
        status: 200,
        headers: {
            "Content-Type": "application/json",
            "Cache-Control": "max-age=300" // 5 min cache
        },
        body: JSON.stringify(products)
    };
};

export default httpTrigger;
```

**Full Stack Decision Matrix:**

| Scenario | Solution | Reasoning |
|----------|----------|-----------|
| React SPA + .NET API | Static Web Apps (frontend) + App Service (backend) | Separate scaling, easier deployment |
| React + Serverless | Static Web Apps with Functions | Simplest, lowest cost for low traffic |
| Next.js SSR | App Service (Node.js) or Container Apps | Need server-side rendering |
| React + High traffic | Static Web Apps + Azure Front Door + App Service | Global CDN + custom routing |
| Multi-tenant SPA | Static Web Apps + Azure AD B2C | Built-in authentication |

---

## 2. Azure SQL vs Cosmos DB Trade-offs

### Decision Matrix

| Criterion | Azure SQL | Cosmos DB |
|-----------|-----------|-----------|
| **Data Model** | Relational (ACID) | Multi-model (NoSQL) |
| **Consistency** | Strong | Tunable (5 levels) |
| **Scalability** | Vertical (up to 128 vCores) | Horizontal (unlimited) |
| **Global Distribution** | Read replicas, Failover groups | Multi-master, active-active |
| **Latency** | Single-digit ms (same region) | < 10ms (P99, globally) |
| **Query Language** | T-SQL | SQL API, MongoDB, Gremlin, Cassandra |
| **Cost Model** | DTU or vCore-based | RU/s-based |
| **Best For** | Traditional apps, complex joins | Global apps, high throughput |

### Azure SQL Database

**Use Cases:**
- Line-of-business applications
- Data warehousing (Synapse)
- Applications requiring complex joins and transactions
- Migrating from on-premises SQL Server

**Tiers:**
```csharp
// Serverless tier for variable workloads
{
  "sku": {
    "name": "GP_S_Gen5",
    "tier": "GeneralPurpose",
    "family": "Gen5",
    "capacity": 2
  },
  "properties": {
    "autoPauseDelay": 60,  // Minutes of inactivity before pause
    "minCapacity": 0.5,    // Min vCores
    "maxSizeBytes": 34359738368  // 32 GB
  }
}

// Hyperscale for large databases (100TB+)
{
  "sku": {
    "name": "HS_Gen5",
    "tier": "Hyperscale",
    "capacity": 4
  }
}
```

**Connection Resiliency Pattern:**
```csharp
public class SqlResiliencyPolicy
{
    public static IAsyncPolicy<SqlConnection> GetConnectionPolicy()
    {
        return Policy
            .Handle<SqlException>(ex => IsTransient(ex))
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: retryAttempt =>
                    TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                onRetry: (exception, timeSpan, retryCount, context) =>
                {
                    Log.Warning($"Retry {retryCount} after {timeSpan}");
                });
    }

    private static bool IsTransient(SqlException ex)
    {
        var transientErrors = new[] { 4060, 40197, 40501, 40613, 49918, 49919, 49920 };
        return transientErrors.Contains(ex.Number);
    }
}
```

### Cosmos DB

**Use Cases:**
- IoT and telemetry data
- Real-time analytics
- Globally distributed applications
- Shopping cart, session state
- High-throughput scenarios

**Consistency Levels:**
```
Strong     ────────────────────────────────  Highest consistency, highest latency
  ↓        Read always returns latest write
Bounded    ────────────────────────────────  Staleness bounded by K versions or T time
Staleness  Guarantees within defined lag
  ↓
Session    ────────────────────────────────  Strong within session, eventual outside
  ↓        Default, best balance for most apps
Consistent ────────────────────────────────  Reads may lag behind writes
Prefix     Guarantees reads never see out-of-order writes
  ↓
Eventual   ────────────────────────────────  Lowest consistency, lowest latency
           Highest availability and performance
```

**Configuration Example:**
```csharp
// Cosmos DB client setup
var clientOptions = new CosmosClientOptions
{
    ConnectionMode = ConnectionMode.Direct,
    ConsistencyLevel = ConsistencyLevel.Session,
    MaxRetryAttemptsOnRateLimitedRequests = 9,
    MaxRetryWaitTimeOnRateLimitedRequests = TimeSpan.FromSeconds(30),
    ApplicationRegion = Regions.EastUS,
    // Enable multi-region writes
    ApplicationPreferredRegions = new List<string>
    {
        Regions.EastUS,
        Regions.WestUS,
        Regions.NorthEurope
    }
};

var client = new CosmosClient(connectionString, clientOptions);

// Partition key design is critical
var containerProperties = new ContainerProperties
{
    Id = "orders",
    PartitionKeyPath = "/customerId",  // Choose wisely!
    // Indexing policy
    IndexingPolicy = new IndexingPolicy
    {
        Automatic = true,
        IndexingMode = IndexingMode.Consistent,
        IncludedPaths = { new IncludedPath { Path = "/*" } },
        ExcludedPaths = { new ExcludedPath { Path = "/metadata/*" } }
    }
};

await database.CreateContainerAsync(containerProperties, throughput: 400);
```

**Change Feed Pattern:**
```csharp
public class CosmosChangeFeedProcessor
{
    private Container monitoredContainer;
    private Container leaseContainer;

    public async Task StartAsync()
    {
        var changeFeedProcessor = monitoredContainer
            .GetChangeFeedProcessorBuilder<Order>("orderProcessor", HandleChangesAsync)
            .WithInstanceName("instance1")
            .WithLeaseContainer(leaseContainer)
            .WithStartTime(DateTime.UtcNow.AddHours(-1))
            .Build();

        await changeFeedProcessor.StartAsync();
    }

    private async Task HandleChangesAsync(
        IReadOnlyCollection<Order> changes,
        CancellationToken cancellationToken)
    {
        foreach (var order in changes)
        {
            // Trigger downstream processing
            await eventPublisher.PublishAsync(new OrderChangedEvent(order));
        }
    }
}
```

---

## 3. Service Bus vs Event Grid vs Event Hub

### Comparison Matrix

| Feature | Service Bus | Event Grid | Event Hub |
|---------|-------------|------------|-----------|
| **Pattern** | Message queuing | Pub/Sub events | Event streaming |
| **Message Size** | Up to 256 KB (1 MB premium) | Up to 1 MB | Up to 1 MB |
| **Throughput** | Moderate | High | Very High (millions/sec) |
| **Ordering** | Session-based ordering | No guarantee | Partition-based |
| **Retention** | Default 14 days (max 90) | 24 hours | 1-90 days |
| **Delivery** | At-least-once, At-most-once | At-least-once | At-least-once |
| **Use Case** | Command/Transaction | Event notification | Telemetry, logs, streaming |

### Service Bus

**Architecture:**
```
Producer → [Queue] → Competing Consumers
                ↓
          [Dead Letter Queue]

Producer → [Topic] → [Subscription 1] → Consumer A
                  → [Subscription 2] → Consumer B
                  → [Subscription 3] → Consumer C
```

**Queue Configuration:**
```csharp
public class ServiceBusConfiguration
{
    public static async Task ConfigureQueueAsync(ServiceBusAdministrationClient adminClient)
    {
        var queueOptions = new CreateQueueOptions("orders")
        {
            // Enable duplicate detection
            RequiresDuplicateDetection = true,
            DuplicateDetectionHistoryTimeWindow = TimeSpan.FromMinutes(10),

            // Dead letter after 5 delivery attempts
            MaxDeliveryCount = 5,

            // Message TTL
            DefaultMessageTimeToLive = TimeSpan.FromDays(14),

            // Enable sessions for ordering
            RequiresSession = true,

            // Enable partitioning for throughput
            EnablePartitioning = true,

            // Lock duration for processing
            LockDuration = TimeSpan.FromMinutes(5)
        };

        await adminClient.CreateQueueAsync(queueOptions);
    }
}
```

**Publisher Pattern:**
```csharp
public class OrderMessagePublisher
{
    private readonly ServiceBusSender _sender;

    public async Task PublishOrderAsync(Order order)
    {
        var message = new ServiceBusMessage(JsonSerializer.Serialize(order))
        {
            MessageId = order.Id.ToString(),
            SessionId = order.CustomerId.ToString(), // For ordering
            ContentType = "application/json",
            Subject = "order.created",
            TimeToLive = TimeSpan.FromDays(7),

            // Custom properties for filtering
            ApplicationProperties =
            {
                ["OrderType"] = order.Type,
                ["Priority"] = order.Priority,
                ["Region"] = order.Region
            }
        };

        // Schedule for future delivery
        if (order.ScheduledDelivery.HasValue)
        {
            await _sender.ScheduleMessageAsync(message, order.ScheduledDelivery.Value);
        }
        else
        {
            await _sender.SendMessageAsync(message);
        }
    }
}
```

**Consumer Pattern with Retry:**
```csharp
public class OrderMessageConsumer
{
    private readonly ServiceBusProcessor _processor;

    public async Task StartProcessingAsync()
    {
        _processor.ProcessMessageAsync += MessageHandler;
        _processor.ProcessErrorAsync += ErrorHandler;

        await _processor.StartProcessingAsync();
    }

    private async Task MessageHandler(ProcessMessageEventArgs args)
    {
        var order = JsonSerializer.Deserialize<Order>(args.Message.Body.ToString());

        try
        {
            await ProcessOrderAsync(order);

            // Complete the message
            await args.CompleteMessageAsync(args.Message);
        }
        catch (TransientException ex)
        {
            // Abandon to retry (respects MaxDeliveryCount)
            await args.AbandonMessageAsync(args.Message);
        }
        catch (PermanentException ex)
        {
            // Move to dead letter queue with reason
            await args.DeadLetterMessageAsync(
                args.Message,
                "ProcessingFailed",
                ex.Message);
        }
    }

    private Task ErrorHandler(ProcessErrorEventArgs args)
    {
        Console.WriteLine($"Error: {args.Exception}");
        return Task.CompletedTask;
    }
}
```

### Event Grid

**Use Cases:**
- React to Blob storage events
- Azure resource state changes
- Custom application events
- Serverless event routing

**Topic and Subscription:**
```csharp
public class EventGridPublisher
{
    private readonly EventGridPublisherClient _client;

    public async Task PublishEventsAsync(IEnumerable<OrderEvent> orderEvents)
    {
        var events = orderEvents.Select(e => new EventGridEvent(
            subject: $"/orders/{e.OrderId}",
            eventType: "Orders.Created",
            dataVersion: "1.0",
            data: new
            {
                OrderId = e.OrderId,
                CustomerId = e.CustomerId,
                Total = e.Total,
                Timestamp = DateTime.UtcNow
            }
        ));

        await _client.SendEventsAsync(events);
    }
}

// Webhook subscription filter
{
  "filter": {
    "subjectBeginsWith": "/orders/",
    "subjectEndsWith": ".created",
    "includedEventTypes": ["Orders.Created", "Orders.Updated"],
    "advancedFilters": [
      {
        "operatorType": "NumberGreaterThan",
        "key": "data.Total",
        "value": 1000
      },
      {
        "operatorType": "StringIn",
        "key": "data.Region",
        "values": ["US-East", "US-West"]
      }
    ]
  }
}
```

### Event Hub

**Use Cases:**
- Telemetry and diagnostics
- Click-stream analysis
- Real-time analytics pipeline
- IoT device data ingestion

**Producer:**
```csharp
public class TelemetryEventProducer
{
    private readonly EventHubProducerClient _producer;

    public async Task SendBatchAsync(IEnumerable<TelemetryData> data)
    {
        using var eventBatch = await _producer.CreateBatchAsync();

        foreach (var telemetry in data)
        {
            var eventData = new EventData(JsonSerializer.Serialize(telemetry))
            {
                // Partition key ensures ordering within partition
                PartitionKey = telemetry.DeviceId
            };

            if (!eventBatch.TryAdd(eventData))
            {
                // Batch is full, send and create new batch
                await _producer.SendAsync(eventBatch);
                eventBatch.Dispose();
                eventBatch = await _producer.CreateBatchAsync();
                eventBatch.TryAdd(eventData);
            }
        }

        if (eventBatch.Count > 0)
        {
            await _producer.SendAsync(eventBatch);
        }
    }
}
```

**Consumer with Checkpointing:**
```csharp
public class TelemetryEventConsumer
{
    private readonly EventProcessorClient _processor;

    public async Task StartProcessingAsync()
    {
        _processor.ProcessEventAsync += ProcessEventHandler;
        _processor.ProcessErrorAsync += ProcessErrorHandler;

        await _processor.StartProcessingAsync();
    }

    private async Task ProcessEventHandler(ProcessEventArgs args)
    {
        var telemetry = JsonSerializer.Deserialize<TelemetryData>(
            args.Data.EventBody.ToString());

        await ProcessTelemetryAsync(telemetry);

        // Checkpoint every 100 events
        if (args.Partition.PartitionId.GetHashCode() % 100 == 0)
        {
            await args.UpdateCheckpointAsync(args.CancellationToken);
        }
    }

    private Task ProcessErrorHandler(ProcessErrorEventArgs args)
    {
        Console.WriteLine($"Partition {args.PartitionId} error: {args.Exception}");
        return Task.CompletedTask;
    }
}
```

---

## 4. API Management (APIM) Policies

### Policy Structure
```xml
<policies>
    <inbound>
        <!-- Policies applied before forwarding request to backend -->
    </inbound>
    <backend>
        <!-- Override backend service behavior -->
    </backend>
    <outbound>
        <!-- Policies applied before sending response to client -->
    </outbound>
    <on-error>
        <!-- Policies applied when error occurs -->
    </on-error>
</policies>
```

### Common Policy Examples

#### Rate Limiting and Throttling
```xml
<policies>
    <inbound>
        <!-- Per-subscription rate limit -->
        <rate-limit calls="100" renewal-period="60" />

        <!-- Per-IP rate limit -->
        <rate-limit-by-key
            calls="20"
            renewal-period="60"
            counter-key="@(context.Request.IpAddress)" />

        <!-- Quota limit (per month) -->
        <quota calls="1000000" renewal-period="2592000" />

        <!-- Concurrent request limit -->
        <limit-concurrency key="@(context.Subscription.Id)" max-count="10">
            <when condition="@(context.Response.StatusCode == 429)">
                <retry condition="@(context.Response.StatusCode == 429)"
                       count="3"
                       interval="1" />
            </when>
        </limit-concurrency>
    </inbound>
</policies>
```

#### Authentication and Authorization
```xml
<policies>
    <inbound>
        <!-- Validate JWT token -->
        <validate-jwt
            header-name="Authorization"
            failed-validation-httpcode="401"
            failed-validation-error-message="Unauthorized">
            <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration" />
            <required-claims>
                <claim name="aud">
                    <value>api://my-api</value>
                </claim>
                <claim name="roles" match="any">
                    <value>Admin</value>
                    <value>User</value>
                </claim>
            </required-claims>
        </validate-jwt>

        <!-- Check for specific header -->
        <check-header name="X-API-Key" failed-check-httpcode="401">
            <value>@(context.Vault.GetSecret("api-key"))</value>
        </check-header>
    </inbound>
</policies>
```

#### Caching
```xml
<policies>
    <inbound>
        <!-- Cache lookup -->
        <cache-lookup
            vary-by-developer="false"
            vary-by-developer-groups="false"
            downstream-caching-type="public">
            <vary-by-query-parameter>category</vary-by-query-parameter>
            <vary-by-query-parameter>page</vary-by-query-parameter>
        </cache-lookup>
        <base />
    </inbound>
    <outbound>
        <!-- Store in cache for 1 hour -->
        <cache-store duration="3600" />
        <base />
    </outbound>
</policies>
```

#### Request/Response Transformation
```xml
<policies>
    <inbound>
        <!-- Set backend URL based on condition -->
        <choose>
            <when condition="@(context.Request.Headers.GetValueOrDefault('X-Version','v1') == 'v2')">
                <set-backend-service base-url="https://api-v2.example.com" />
            </when>
            <otherwise>
                <set-backend-service base-url="https://api-v1.example.com" />
            </otherwise>
        </choose>

        <!-- Add header to backend request -->
        <set-header name="X-Request-Id" exists-action="override">
            <value>@(Guid.NewGuid().ToString())</value>
        </set-header>

        <!-- Rewrite URL -->
        <rewrite-uri template="/api/v2/{path}" copy-unmatched-params="true" />

        <!-- Transform request body -->
        <set-body template="liquid">
        {
            "timestamp": "{{context.Timestamp}}",
            "originalRequest": {{body}}
        }
        </set-body>
    </inbound>
    <outbound>
        <!-- Transform response -->
        <set-body>
        @{
            var response = context.Response.Body.As<JObject>(preserveContent: true);
            response["metadata"] = new JObject(
                new JProperty("apiVersion", "1.0"),
                new JProperty("timestamp", DateTime.UtcNow)
            );
            return response.ToString();
        }
        </set-body>

        <!-- Add CORS headers -->
        <cors allow-credentials="true">
            <allowed-origins>
                <origin>https://example.com</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
        </cors>
    </outbound>
</policies>
```

#### Circuit Breaker Pattern
```xml
<policies>
    <inbound>
        <retry
            condition="@(context.Response.StatusCode >= 500)"
            count="3"
            interval="2"
            max-interval="10"
            delta="2"
            first-fast-retry="true">
            <forward-request timeout="10" />
        </retry>
    </inbound>
    <on-error>
        <!-- Fallback response -->
        <return-response>
            <set-status code="503" reason="Service Unavailable" />
            <set-header name="Retry-After" exists-action="override">
                <value>60</value>
            </set-header>
            <set-body>@{
                return new JObject(
                    new JProperty("error", "Service temporarily unavailable"),
                    new JProperty("retryAfter", 60)
                ).ToString();
            }</set-body>
        </return-response>
    </on-error>
</policies>
```

---

## 5. Azure AD vs Azure AD B2C

### Azure AD (Entra ID)

**Use Cases:**
- Enterprise applications
- Employee authentication
- Internal line-of-business apps
- Office 365 integration

**Key Features:**
- Single Sign-On (SSO)
- Multi-Factor Authentication (MFA)
- Conditional Access policies
- Role-Based Access Control (RBAC)
- Integration with on-premises AD

**App Registration:**
```csharp
// Azure AD authentication setup
public void ConfigureServices(IServiceCollection services)
{
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddMicrosoftIdentityWebApi(options =>
        {
            Configuration.Bind("AzureAd", options);
            options.TokenValidationParameters.NameClaimType = "name";
            options.TokenValidationParameters.RoleClaimType = "roles";
        },
        options => { Configuration.Bind("AzureAd", options); });

    services.AddAuthorization(options =>
    {
        options.AddPolicy("RequireAdminRole", policy =>
            policy.RequireRole("Admin"));

        options.AddPolicy("RequireReadScope", policy =>
            policy.RequireClaim("http://schemas.microsoft.com/identity/claims/scope", "api.read"));
    });
}

// appsettings.json
{
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "TenantId": "{tenant-id}",
    "ClientId": "{client-id}",
    "Audience": "api://{client-id}"
  }
}
```

### Azure AD B2C

**Use Cases:**
- Customer-facing applications
- Social identity providers (Google, Facebook)
- Custom branding and UX
- Self-service password reset
- Millions of consumer identities

**Key Features:**
- Social and local accounts
- Custom user journeys (User Flows & Custom Policies)
- White-label authentication
- API connectors for custom logic
- High scalability (billions of authentications/day)

**Configuration:**
```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddMicrosoftIdentityWebApi(options =>
        {
            Configuration.Bind("AzureAdB2C", options);
        },
        options => { Configuration.Bind("AzureAdB2C", options); });
}

// appsettings.json
{
  "AzureAdB2C": {
    "Instance": "https://{tenant-name}.b2clogin.com/",
    "ClientId": "{client-id}",
    "Domain": "{tenant-name}.onmicrosoft.com",
    "SignUpSignInPolicyId": "B2C_1_signupsignin",
    "ResetPasswordPolicyId": "B2C_1_passwordreset",
    "EditProfilePolicyId": "B2C_1_profileediting"
  }
}
```

**Custom Policy (User Journey):**
```xml
<UserJourney Id="SignUpOrSignIn">
  <OrchestrationSteps>
    <OrchestrationStep Order="1" Type="CombinedSignInAndSignUp">
      <ClaimsProviderSelections>
        <ClaimsProviderSelection TargetClaimsExchangeId="GoogleExchange" />
        <ClaimsProviderSelection TargetClaimsExchangeId="FacebookExchange" />
        <ClaimsProviderSelection ValidationClaimsExchangeId="LocalAccountSigninEmailExchange" />
      </ClaimsProviderSelections>
    </OrchestrationStep>

    <OrchestrationStep Order="2" Type="ClaimsExchange">
      <ClaimsExchanges>
        <ClaimsExchange Id="GoogleExchange" TechnicalProfileReferenceId="Google-OAuth2" />
        <ClaimsExchange Id="FacebookExchange" TechnicalProfileReferenceId="Facebook-OAUTH" />
      </ClaimsExchanges>
    </OrchestrationStep>

    <!-- API Connector for custom validation -->
    <OrchestrationStep Order="3" Type="ClaimsExchange">
      <ClaimsExchanges>
        <ClaimsExchange Id="ValidateUser" TechnicalProfileReferenceId="REST-ValidateProfile" />
      </ClaimsExchanges>
    </OrchestrationStep>
  </OrchestrationSteps>
</UserJourney>
```

### Comparison

| Feature | Azure AD | Azure AD B2C |
|---------|----------|--------------|
| **Target Users** | Employees, partners | Customers, consumers |
| **Scale** | Thousands-millions | Millions-billions |
| **Identity Providers** | Enterprise (SAML, WS-Fed) | Social + Enterprise |
| **Customization** | Limited branding | Full white-label |
| **Pricing** | Per user/month | Per authentication |
| **MFA** | Built-in | Configurable |
| **User Management** | Admin portal | Self-service |

---

## 6. Managed Identity Patterns

### Types of Managed Identities

```
System-Assigned Identity
┌─────────────────────┐
│  Azure Resource     │
│  (App Service)      │
│  ┌───────────────┐  │
│  │ MI: Auto-gen  │  │ ← Lifecycle tied to resource
│  │ ID: xyz123    │  │ ← Deleted with resource
│  └───────────────┘  │
└─────────────────────┘

User-Assigned Identity
┌─────────────────────┐     ┌─────────────────────┐
│  Resource 1         │────→│  Managed Identity   │
└─────────────────────┘     │  (Shared)           │
┌─────────────────────┐     │  ID: abc789         │
│  Resource 2         │────→│                     │
└─────────────────────┘     └─────────────────────┘
                             ↑ Independent lifecycle
```

### Common Patterns

#### 1. App Service → Key Vault
```csharp
// Enable system-assigned identity in App Service
// Azure Portal: App Service → Identity → System assigned: On

public class SecretService
{
    private readonly SecretClient _secretClient;

    public SecretService(IConfiguration configuration)
    {
        var keyVaultUrl = configuration["KeyVault:VaultUrl"];

        // DefaultAzureCredential automatically uses Managed Identity in Azure
        var credential = new DefaultAzureCredential();
        _secretClient = new SecretClient(new Uri(keyVaultUrl), credential);
    }

    public async Task<string> GetSecretAsync(string secretName)
    {
        KeyVaultSecret secret = await _secretClient.GetSecretAsync(secretName);
        return secret.Value;
    }
}

// Grant access in Key Vault
// Access policies → Add → Select principal (App Service name)
// Secret permissions: Get, List
```

#### 2. App Service → Azure SQL
```csharp
public class DatabaseContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        var connectionString = "Server=tcp:myserver.database.windows.net;Database=mydb;";

        optionsBuilder.UseSqlServer(connectionString, options =>
        {
            options.EnableRetryOnFailure();
        });
    }

    // Connection interceptor to add access token
    public class AzureSqlAuthenticationInterceptor : DbConnectionInterceptor
    {
        public override async ValueTask<InterceptionResult> ConnectionOpeningAsync(
            DbConnection connection,
            ConnectionEventData eventData,
            InterceptionResult result,
            CancellationToken cancellationToken = default)
        {
            var sqlConnection = (SqlConnection)connection;

            if (sqlConnection.AccessToken == null)
            {
                var credential = new DefaultAzureCredential();
                var token = await credential.GetTokenAsync(
                    new TokenRequestContext(new[] { "https://database.windows.net/.default" }),
                    cancellationToken);

                sqlConnection.AccessToken = token.Token;
            }

            return result;
        }
    }
}

// SQL Database: Create user for managed identity
-- CREATE USER [app-service-name] FROM EXTERNAL PROVIDER;
-- ALTER ROLE db_datareader ADD MEMBER [app-service-name];
-- ALTER ROLE db_datawriter ADD MEMBER [app-service-name];
```

#### 3. Function App → Storage Account
```csharp
public class BlobService
{
    private readonly BlobServiceClient _blobServiceClient;

    public BlobService(IConfiguration configuration)
    {
        var storageUrl = configuration["Storage:BlobServiceUrl"];
        var credential = new DefaultAzureCredential();

        _blobServiceClient = new BlobServiceClient(
            new Uri(storageUrl),
            credential);
    }

    public async Task<BlobClient> GetBlobClientAsync(string containerName, string blobName)
    {
        var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
        await containerClient.CreateIfNotExistsAsync();

        return containerClient.GetBlobClient(blobName);
    }
}

// Storage Account → Access Control (IAM)
// Add role assignment: Storage Blob Data Contributor
```

#### 4. AKS → Azure Resources
```yaml
# Install AAD Pod Identity
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: my-identity
spec:
  type: 0  # User-assigned identity
  resourceID: /subscriptions/{sub}/resourcegroups/{rg}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity}
  clientID: {client-id}

---
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: my-identity-binding
spec:
  azureIdentity: my-identity
  selector: my-app  # Label selector

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    metadata:
      labels:
        aadpodidbinding: my-app  # Matches selector
    spec:
      containers:
      - name: app
        image: myapp:latest
```

**Modern Workload Identity (Recommended):**
```yaml
# Use Workload Identity (replaces AAD Pod Identity)
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workload-identity-sa
  annotations:
    azure.workload.identity/client-id: {client-id}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"
    spec:
      serviceAccountName: workload-identity-sa
      containers:
      - name: app
        image: myapp:latest
```

---

## 7. Key Vault Integration

### Best Practices

**Architecture:**
```
Application
    ↓
DefaultAzureCredential
    ↓
┌─────────────────────────────────┐
│ Tries in order:                 │
│ 1. Environment Variables        │
│ 2. Managed Identity             │ ← In Azure
│ 3. Visual Studio                │ ← Local dev
│ 4. Azure CLI                    │ ← Local dev
│ 5. Azure PowerShell             │
└─────────────────────────────────┘
    ↓
Azure Key Vault
```

### Configuration Integration

**ASP.NET Core:**
```csharp
public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureAppConfiguration((context, config) =>
            {
                if (context.HostingEnvironment.IsProduction())
                {
                    var builtConfig = config.Build();
                    var keyVaultUrl = builtConfig["KeyVault:VaultUrl"];

                    // Add Key Vault as configuration source
                    config.AddAzureKeyVault(
                        new Uri(keyVaultUrl),
                        new DefaultAzureCredential(),
                        new KeyVaultSecretManager());
                }
            })
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
}

// Custom secret manager for prefix filtering
public class PrefixKeyVaultSecretManager : KeyVaultSecretManager
{
    private readonly string _prefix;

    public PrefixKeyVaultSecretManager(string prefix)
    {
        _prefix = $"{prefix}-";
    }

    public override bool Load(SecretProperties secret)
    {
        return secret.Name.StartsWith(_prefix);
    }

    public override string GetKey(KeyVaultSecret secret)
    {
        return secret.Name.Substring(_prefix.Length)
            .Replace("--", ConfigurationPath.KeyDelimiter);
    }
}
```

### Secret Rotation Pattern

```csharp
public class RotatingSecretService
{
    private readonly SecretClient _secretClient;
    private readonly IMemoryCache _cache;
    private readonly TimeSpan _cacheDuration = TimeSpan.FromHours(1);

    public async Task<string> GetSecretAsync(string secretName)
    {
        return await _cache.GetOrCreateAsync($"secret-{secretName}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = _cacheDuration;

            var secret = await _secretClient.GetSecretAsync(secretName);
            return secret.Value.Value;
        });
    }

    // Proactive rotation check
    public async Task CheckAndRotateAsync(string secretName)
    {
        var secret = await _secretClient.GetSecretAsync(secretName);

        var daysUntilExpiry = (secret.Value.Properties.ExpiresOn - DateTimeOffset.UtcNow)?.TotalDays;

        if (daysUntilExpiry < 30)
        {
            // Trigger rotation workflow
            await TriggerRotationAsync(secretName);
        }
    }
}
```

### Certificate Management

```csharp
public class CertificateService
{
    private readonly CertificateClient _certificateClient;

    public async Task<X509Certificate2> GetCertificateAsync(string certificateName)
    {
        // Download certificate with private key
        var certificate = await _certificateClient.DownloadCertificateAsync(certificateName);
        return certificate.Value;
    }

    public async Task InstallCertificateAsync(string certificateName)
    {
        var certificate = await GetCertificateAsync(certificateName);

        using var store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
        store.Open(OpenFlags.ReadWrite);
        store.Add(certificate);
        store.Close();
    }
}

// Use certificate for HTTPS
public void ConfigureKestrel(WebHostBuilderContext context, KestrelServerOptions options)
{
    var certificateService = context.Configuration.GetSection("Certificate");
    var certName = certificateService["Name"];

    options.ConfigureHttpsDefaults(httpsOptions =>
    {
        httpsOptions.ServerCertificateSelector = (ctx, name) =>
        {
            // Load from Key Vault
            var cert = GetCertificateFromKeyVault(certName).GetAwaiter().GetResult();
            return cert;
        };
    });
}
```

---

## 8. VNet and Private Endpoints

### Virtual Network Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Virtual Network (10.0.0.0/16)                           │
│                                                         │
│  ┌────────────────────────┐  ┌────────────────────────┐ │
│  │ Subnet: Web            │  │ Subnet: App            │ │
│  │ (10.0.1.0/24)          │  │ (10.0.2.0/24)          │ │
│  │ - App Service (VNet    │  │ - AKS Nodes            │ │
│  │   Integration)         │  │ - Function Apps        │ │
│  │ - NSG: Allow 443       │  │ - NSG: Allow internal  │ │
│  └────────────────────────┘  └────────────────────────┘ │
│                                                         │
│  ┌────────────────────────┐  ┌────────────────────────┐ │
│  │ Subnet: Data           │  │ Subnet: Private        │ │
│  │ (10.0.3.0/24)          │  │ Endpoints (10.0.4.0/24)│ │
│  │ - SQL MI               │  │ - Storage PE           │ │
│  │ - Service delegation   │  │ - Key Vault PE         │ │
│  └────────────────────────┘  │ - Cosmos DB PE         │ │
│                              └────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### VNet Integration (App Service)

```csharp
// Enable regional VNet integration
// App Service → Networking → VNet integration → Add VNet

// Route all traffic through VNet
{
  "name": "vnetRouteAllEnabled",
  "properties": {
    "vnetRouteAllEnabled": true,  // Route all outbound through VNet
    "vnetName": "my-vnet",
    "vnetResourceGroup": "my-rg",
    "vnetSubnetName": "app-subnet"
  }
}

// Access resources using private IPs
public class PrivateResourceAccess
{
    public async Task<string> AccessPrivateSqlAsync()
    {
        // Uses private endpoint IP instead of public
        var connectionString = "Server=myserver.database.windows.net;Database=mydb;";
        // Traffic stays within VNet
        using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();
        return "Connected via private endpoint";
    }
}
```

### Private Endpoint Configuration

**Storage Account Private Endpoint:**
```json
{
  "name": "storage-private-endpoint",
  "properties": {
    "subnet": {
      "id": "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/private-endpoints"
    },
    "privateLinkServiceConnections": [
      {
        "name": "storage-connection",
        "properties": {
          "privateLinkServiceId": "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage}",
          "groupIds": ["blob"]
        }
      }
    ]
  }
}
```

**Private DNS Zone:**
```
Private DNS Zone: privatelink.blob.core.windows.net

A Record:
mystorageaccount.blob.core.windows.net → 10.0.4.4

Configuration:
1. Create Private DNS Zone
2. Link to VNet
3. Create A record for private endpoint IP
4. Disable public network access on storage account
```

### Network Security Groups (NSG)

```json
{
  "securityRules": [
    {
      "name": "AllowHTTPS",
      "properties": {
        "priority": 100,
        "direction": "Inbound",
        "access": "Allow",
        "protocol": "Tcp",
        "sourceAddressPrefix": "Internet",
        "sourcePortRange": "*",
        "destinationAddressPrefix": "VirtualNetwork",
        "destinationPortRange": "443"
      }
    },
    {
      "name": "AllowAppToDatabase",
      "properties": {
        "priority": 110,
        "direction": "Outbound",
        "access": "Allow",
        "protocol": "Tcp",
        "sourceAddressPrefix": "10.0.2.0/24",
        "sourcePortRange": "*",
        "destinationAddressPrefix": "10.0.3.0/24",
        "destinationPortRange": "1433"
      }
    },
    {
      "name": "DenyAllOutbound",
      "properties": {
        "priority": 1000,
        "direction": "Outbound",
        "access": "Deny",
        "protocol": "*",
        "sourceAddressPrefix": "*",
        "sourcePortRange": "*",
        "destinationAddressPrefix": "*",
        "destinationPortRange": "*"
      }
    }
  ]
}
```

### Service Endpoints vs Private Endpoints

| Feature | Service Endpoints | Private Endpoints |
|---------|------------------|-------------------|
| **Traffic Path** | Over Azure backbone | Fully private (VNet IP) |
| **DNS** | Public DNS | Private DNS required |
| **Firewall** | IP-based rules | No public access needed |
| **Cost** | Free | Charged per endpoint |
| **Services** | Limited services | Most Azure services |
| **Cross-region** | No | Yes |

---

## 9. Cold Starts and Mitigation

### Understanding Cold Starts

```
Consumption Plan Cold Start Timeline:
┌──────────────────────────────────────────────────────────┐
│ Trigger arrives                                           │
│   ↓                                                       │
│ Container allocation (1-3s)                              │
│   ↓                                                       │
│ Runtime initialization (2-5s)                            │
│   ↓                                                       │
│ Application startup (.NET: 3-10s)                        │
│   ↓                                                       │
│ Function execution                                        │
│                                                           │
│ Total cold start: 6-18 seconds                           │
└──────────────────────────────────────────────────────────┘
```

### Mitigation Strategies

#### 1. Premium Plan (Recommended)
```json
{
  "sku": {
    "name": "EP1",
    "tier": "ElasticPremium"
  },
  "properties": {
    "alwaysReady": [
      {
        "name": "http",
        "instanceCount": 2
      }
    ],
    "maximumElasticWorkerCount": 20,
    "reserved": false
  }
}
```

**Benefits:**
- Pre-warmed instances (always ready)
- VNet integration
- Unlimited execution duration
- Predictable performance

#### 2. Application Initialization
```csharp
public class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        // Eager initialization
        builder.Services.AddSingleton<IService>(sp =>
        {
            var service = new ExpensiveService();
            service.Initialize(); // Load caches, connections, etc.
            return service;
        });

        // HTTP client factory (connection pooling)
        builder.Services.AddHttpClient<IApiClient, ApiClient>()
            .SetHandlerLifetime(TimeSpan.FromMinutes(5));

        // Database connection pooling
        builder.Services.AddDbContextPool<AppDbContext>(options =>
            options.UseSqlServer(connectionString),
            poolSize: 128);
    }

    public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
    {
        // Preload configuration
        builder.ConfigurationBuilder
            .AddJsonFile("local.settings.json", optional: true)
            .AddEnvironmentVariables();
    }
}
```

#### 3. Optimize Package Size
```xml
<!-- Function.csproj -->
<PropertyGroup>
  <TargetFramework>net8.0</TargetFramework>
  <AzureFunctionsVersion>v4</AzureFunctionsVersion>

  <!-- Reduce package size -->
  <PublishTrimmed>true</PublishTrimmed>
  <PublishReadyToRun>true</PublishReadyToRun>

  <!-- Remove unnecessary assemblies -->
  <TrimMode>link</TrimMode>
</PropertyGroup>

<ItemGroup>
  <!-- Only include necessary packages -->
  <PackageReference Include="Microsoft.NET.Sdk.Functions" Version="4.2.0" />
  <PackageReference Include="Microsoft.Azure.Functions.Extensions" Version="1.1.0" />
</ItemGroup>
```

#### 4. Keep-Warm Pattern
```csharp
public class WarmupFunction
{
    private readonly IEnumerable<IWarmable> _warmableServices;

    [FunctionName("Warmup")]
    public async Task Run(
        [WarmupTrigger] WarmupContext context,
        ILogger log)
    {
        log.LogInformation("Function app warming up...");

        foreach (var service in _warmableServices)
        {
            await service.WarmupAsync();
        }
    }

    // Timer trigger to keep warm
    [FunctionName("KeepWarm")]
    public async Task KeepWarm(
        [TimerTrigger("0 */5 * * * *")] TimerInfo timer,
        ILogger log)
    {
        log.LogInformation("Keep-warm ping");
        // Ping critical endpoints
        await HttpClient.GetAsync("https://myapi.azurewebsites.net/health");
    }
}
```

#### 5. Monitoring Cold Starts
```csharp
public class ColdStartMonitoring
{
    private static bool _isColdStart = true;
    private static readonly Stopwatch _startupTimer = Stopwatch.StartNew();

    [FunctionName("HttpTrigger")]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req,
        ILogger log)
    {
        if (_isColdStart)
        {
            _startupTimer.Stop();
            log.LogMetric("ColdStartDuration", _startupTimer.ElapsedMilliseconds);
            log.LogWarning($"Cold start detected: {_startupTimer.ElapsedMilliseconds}ms");
            _isColdStart = false;
        }

        return new OkObjectResult("Hello");
    }
}
```

---

## 10. Throttling Limits and Handling

### Azure Service Limits

| Service | Limit | Scope |
|---------|-------|-------|
| **App Service** | 1,920 requests/min | Per instance |
| **Function (Consumption)** | 200 concurrent | Per function app |
| **Function (Premium)** | Unlimited | Per plan |
| **Azure SQL (S3)** | 100 DTU | Per database |
| **Cosmos DB** | RU/s limit | Per container |
| **Storage (Blob)** | 20,000 req/s | Per account |
| **Service Bus** | 1,000 msg/s (Standard) | Per namespace |
| **Event Hub** | 1 MB/s per TU | Per namespace |

### Handling Throttling

#### Retry with Exponential Backoff
```csharp
public class ThrottlingHandler : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        var retryCount = 0;
        var maxRetries = 5;

        while (true)
        {
            var response = await base.SendAsync(request, cancellationToken);

            if (response.StatusCode != (HttpStatusCode)429 || retryCount >= maxRetries)
            {
                return response;
            }

            // Check Retry-After header
            var retryAfter = response.Headers.RetryAfter?.Delta
                ?? TimeSpan.FromSeconds(Math.Pow(2, retryCount));

            await Task.Delay(retryAfter, cancellationToken);
            retryCount++;
        }
    }
}

// Using Polly
//
// Key Terminology:
// - Exponential Backoff: Progressively increasing delay between retries (1s, 2s, 4s, 8s...)
//   This prevents overwhelming a struggling service with continuous retry attempts.
//
// - Jitter: Random variation added to delays to prevent "thundering herd" problems.
//   Without jitter, all clients retry at exactly the same time (1s, 2s, 4s), creating spikes.
//   With jitter: Client A retries at 1.2s, Client B at 1.7s, Client C at 0.9s - spreading load.
//
public static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .OrResult(msg => msg.StatusCode == (HttpStatusCode)429)
        .WaitAndRetryAsync(
            retryCount: 5,
            sleepDurationProvider: (retryAttempt, response, context) =>
            {
                // Use Retry-After if available
                if (response.Result?.Headers.RetryAfter?.Delta.HasValue == true)
                {
                    return response.Result.Headers.RetryAfter.Delta.Value;
                }

                // Exponential backoff with jitter
                var baseDelay = TimeSpan.FromSeconds(Math.Pow(2, retryAttempt));
                var jitter = TimeSpan.FromMilliseconds(Random.Shared.Next(0, 1000));
                return baseDelay + jitter;
            },
            onRetryAsync: (outcome, timespan, retryAttempt, context) =>
            {
                Log.Warning($"Retry {retryAttempt} after {timespan}");
                return Task.CompletedTask;
            });
}
```

#### Circuit Breaker
```csharp
public static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .OrResult(msg => msg.StatusCode == (HttpStatusCode)429)
        .CircuitBreakerAsync(
            handledEventsAllowedBeforeBreaking: 3,
            durationOfBreak: TimeSpan.FromSeconds(30),
            onBreak: (outcome, duration) =>
            {
                Log.Error($"Circuit broken for {duration}");
            },
            onReset: () =>
            {
                Log.Information("Circuit reset");
            },
            onHalfOpen: () =>
            {
                Log.Information("Circuit half-open");
            });
}

// Combine policies
var policyWrap = Policy.WrapAsync(
    GetCircuitBreakerPolicy(),
    GetRetryPolicy(),
    GetTimeoutPolicy());
```

#### Cosmos DB RU Management
```csharp
public class CosmosThrottlingHandler
{
    private readonly Container _container;

    public async Task<T> ExecuteWithRetryAsync<T>(Func<Task<T>> operation)
    {
        while (true)
        {
            try
            {
                return await operation();
            }
            catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.TooManyRequests)
            {
                // Wait for suggested retry time
                await Task.Delay(ex.RetryAfter ?? TimeSpan.FromSeconds(1));
            }
        }
    }

    // Batch operations to optimize RU usage
    public async Task BulkInsertAsync<T>(IEnumerable<T> items)
    {
        var tasks = items.Select(async item =>
        {
            return await ExecuteWithRetryAsync(async () =>
            {
                return await _container.CreateItemAsync(item);
            });
        });

        await Task.WhenAll(tasks);
    }

    // Monitor RU consumption
    public async Task<double> GetConsumedRUAsync<T>(Func<Task<T>> query)
    {
        var response = await query();

        if (response is ItemResponse<T> itemResponse)
        {
            return itemResponse.RequestCharge;
        }
        else if (response is FeedResponse<T> feedResponse)
        {
            return feedResponse.RequestCharge;
        }

        return 0;
    }
}
```

---

## 11. Azure Reference Architecture

### E-Commerce Platform Architecture

```
                              ┌─────────────────┐
                              │  Azure Front    │
                              │  Door / CDN     │
                              └────────┬────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
              ┌─────▼─────┐     ┌─────▼─────┐     ┌─────▼─────┐
              │  Web App  │     │  Web App  │     │  Web App  │
              │  (East US)│     │ (West US) │     │ (Europe)  │
              └─────┬─────┘     └─────┬─────┘     └─────┬─────┘
                    │                  │                  │
                    └──────────────────┼──────────────────┘
                                       │
                              ┌────────▼────────┐
                              │  API Management │
                              │  (Multi-region) │
                              └────────┬────────┘
                                       │
        ┌──────────────────────────────┼──────────────────────────────┐
        │                              │                              │
  ┌─────▼─────┐              ┌─────────▼─────────┐          ┌────────▼────────┐
  │  Order    │              │   Product         │          │  Identity       │
  │  Service  │              │   Service         │          │  Service        │
  │  (AKS)    │              │   (Container Apps)│          │  (App Service)  │
  └─────┬─────┘              └─────────┬─────────┘          └────────┬────────┘
        │                              │                              │
        │ ┌────────────────────────────┼──────────────────────────────┤
        │ │                            │                              │
  ┌─────▼─▼─────┐            ┌─────────▼─────────┐          ┌────────▼────────┐
  │  Service    │            │   Cosmos DB       │          │  Azure AD B2C   │
  │  Bus        │            │   (Multi-region)  │          └─────────────────┘
  └─────┬───────┘            └───────────────────┘
        │
  ┌─────▼─────┐
  │  Function │
  │  Apps     │
  │  (Workers)│
  └─────┬─────┘
        │
  ┌─────▼─────┐
  │  Azure    │
  │  SQL      │
  └───────────┘

Shared Services:
├─ Application Insights (Monitoring)
├─ Key Vault (Secrets)
├─ Azure Storage (Blobs, Queues)
├─ Azure Cache for Redis
└─ Log Analytics
```

### Service Trade-offs

#### Web Layer
**Azure Front Door**
- Pros: Global load balancing, WAF, SSL offload, caching
- Cons: Cost, complexity
- Trade-off: Use CDN for static content only to reduce cost

**App Service vs Container Apps**
- App Service: Simpler, fully managed, good for monoliths
- Container Apps: Microservices, scale-to-zero, event-driven
- Trade-off: Start with App Service, migrate to containers as you grow

#### API Layer
**API Management**
- Pros: Centralized policies, analytics, developer portal
- Cons: Added latency (1-5ms), cost
- Trade-off: Use Consumption tier for dev/test, Standard+ for production

#### Compute Layer
**AKS vs Container Apps vs Functions**
- AKS: Maximum control, complex orchestration, always-on cost
- Container Apps: Balanced simplicity and scale, good for microservices
- Functions: Event-driven, scale-to-zero, best for background tasks
- Trade-off: Use Functions for async workers, Container Apps for APIs, AKS only if you need K8s

#### Data Layer
**Azure SQL vs Cosmos DB**
- SQL: Relational, ACID, complex queries, vertical scaling
- Cosmos DB: NoSQL, global distribution, horizontal scaling, eventual consistency
- Trade-off: SQL for transactional data, Cosmos for global read-heavy workloads

**Caching Strategy**
- Redis: Session state, frequently accessed data
- CDN: Static assets, API responses
- Cosmos DB: Built-in caching with Session consistency
- Trade-off: Balance cache hit ratio vs memory cost

#### Messaging
**Service Bus vs Event Grid vs Event Hub**
- Service Bus: Guaranteed delivery, transactions, ordering
- Event Grid: Serverless, reactive, filtering
- Event Hub: High-throughput streaming, analytics
- Trade-off: Service Bus for commands, Event Grid for events, Event Hub for telemetry

---

## Interview Questions

### Scenario-Based Questions

**Q1: Design a globally distributed e-commerce platform with <100ms latency worldwide.**

**Answer:**
```
Architecture Components:
1. Azure Front Door for global routing and WAF
2. Multi-region App Services (East US, West Europe, Southeast Asia)
3. Cosmos DB with multi-master write (5 regions)
4. Azure CDN for static assets
5. Azure Cache for Redis (geo-replicated)
6. API Management (multi-region deployment)

Trade-offs:
- Cost: Multi-region significantly increases cost (3-5x)
- Complexity: Conflict resolution in Cosmos DB
- Consistency: Accept eventual consistency for reads
- Data sovereignty: Implement geo-fencing for certain data

Latency optimization:
- Session affinity to nearest region
- Read from nearest Cosmos DB replica
- Cache product catalog in Redis (TTL: 5 minutes)
- CDN for images and static content (cache: 1 day)
```

**Q2: Your Function App has 30-second cold starts. How do you fix it?**

**Answer:**
```
Analysis:
1. Measure actual cold start components:
   - Container allocation
   - Runtime initialization
   - Application startup
   - Dependency injection setup

Solutions (in order of impact):
1. Move to Premium Plan (eliminates cold starts)
   - Pre-warmed instances
   - Cost: $150-500/month vs $0 on Consumption

2. Optimize application:
   - Reduce package size (ReadyToRun, Trimming)
   - Lazy load dependencies
   - Remove unused packages
   - Expected improvement: 10-15 seconds

3. Keep-warm pattern:
   - Timer trigger every 5 minutes
   - Cons: Wastes executions, not guaranteed

4. Move to Container Apps or App Service:
   - Always-on capability
   - Better for HTTP-triggered functions

Recommendation: Premium Plan if budget allows, otherwise optimize + keep-warm.
```

**Q3: Design a secure CI/CD pipeline for Azure deployments.**

**Answer:**
```
Pipeline stages:
1. Build
   - Restore dependencies
   - Run unit tests (80% coverage required)
   - Static code analysis (SonarQube)
   - Security scanning (Snyk, WhiteSource)
   - Build artifacts

2. Dev Deployment
   - Deploy to App Service dev slot
   - Run integration tests
   - Run security tests (OWASP ZAP)
   - Smoke tests

3. QA Deployment
   - Deploy to QA environment
   - Run full regression suite
   - Performance testing
   - Manual approval gate

4. Production Deployment
   - Deploy to staging slot
   - Warm-up period (5 minutes)
   - Health check validation
   - Swap slots (zero downtime)
   - Monitor for 15 minutes
   - Auto-rollback on errors

Security measures:
- Use Managed Identity for Azure access
- Store secrets in Key Vault
- Sign commits and artifacts
- Implement branch protection
- Require PR reviews
- Scan for secrets in code
- Use private agents for builds
- Implement least privilege RBAC
```

### Technical Deep Dive

**Q4: Explain the difference between System-Assigned and User-Assigned Managed Identities.**

**Answer:**
- System-Assigned: Lifecycle tied to resource, auto-deleted, simpler
- User-Assigned: Independent lifecycle, can be shared across resources, better for multi-resource scenarios
- Use System-Assigned for single-resource scenarios (App Service → Key Vault)
- Use User-Assigned when multiple resources need same permissions or when identity needs to outlive resources

**Q5: How does Cosmos DB achieve global distribution with low latency?**

**Answer:**
- Data replicated to multiple regions
- Multi-master write capability (active-active)
- Partition-based horizontal scaling
- 5 consistency levels (Strong to Eventual)
- Last-write-wins or custom conflict resolution
- Trade-off: Consistency vs availability vs latency
- Read operations served from nearest region
- Write operations can be regional or global based on consistency level

**Q6: When would you choose Service Bus over Event Grid?**

**Answer:**
Service Bus:
- Need guaranteed message delivery
- Require transaction support
- Message ordering is critical
- Dead-letter queue handling
- Message sessions
- Duplicate detection

Event Grid:
- Serverless event routing
- React to Azure resource events
- Fan-out to multiple subscribers
- Lower cost for high-volume events
- No ordering guarantees needed

---

## Key Takeaways

1. **Service Selection**: Choose based on specific requirements, not trends
2. **Managed Identity**: Always prefer over connection strings/keys
3. **Private Endpoints**: Use for production workloads requiring security
4. **Cold Starts**: Premium Plan or optimization, not keep-warm hacks
5. **Throttling**: Implement exponential backoff and circuit breakers
6. **Architecture**: Start simple, add complexity only when needed
7. **Cost vs Performance**: Always consider trade-offs explicitly
8. **Security**: Defense in depth with multiple layers

---

## Next Steps

- Day 11: Cloud Scale, Reliability, and Cost Optimization
- Practice designing multi-region architectures
- Hands-on with Managed Identities and Key Vault
- Build a sample microservices architecture on Azure
