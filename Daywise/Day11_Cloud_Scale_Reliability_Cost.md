# Day 11: Cloud Scale, Reliability, and Cost Optimization

## Overview
Master cloud scaling patterns, high availability strategies, disaster recovery planning, and cost optimization techniques for Azure environments. This guide focuses on building resilient, scalable, and cost-effective cloud architectures.

---

## 1. Horizontal vs Vertical Scaling Patterns

### Scaling Strategies Comparison

```
Vertical Scaling (Scale Up/Down)
┌─────────────┐         ┌─────────────┐
│   2 vCPU    │  ════>  │   8 vCPU    │
│   4 GB RAM  │         │   32 GB RAM │
│   (P1v2)    │         │   (P3v3)    │
└─────────────┘         └─────────────┘
Pros: Simple, no code changes
Cons: Downtime, upper limits, single point of failure

Horizontal Scaling (Scale Out/In)
┌─────────┐              ┌─────────┐ ┌─────────┐ ┌─────────┐
│ Instance│  ═════════>  │Instance1│ │Instance2│ │Instance3│
│   (1)   │              │ (4 vCPU)│ │ (4 vCPU)│ │ (4 vCPU)│
└─────────┘              └─────────┘ └─────────┘ └─────────┘
Pros: High availability, no downtime, unlimited scale
Cons: Complexity, stateless design required, cost
```

### When to Use Each

| Scenario | Vertical | Horizontal |
|----------|----------|------------|
| **Database** | Preferred (easier) | Requires sharding/replication |
| **Stateless APIs** | Quick fix | Production recommended |
| **Stateful Apps** | Simpler | Requires session management |
| **Batch Processing** | Limited scale | Preferred for parallelism |
| **Memory-intensive** | Often better | Distributed caching needed |
| **Development** | Cost-effective | Production pattern |

**Architect's Decision Guide:**
- **Start with vertical scaling**: Faster to implement, validate if you have a scaling problem first
- **Migrate to horizontal**: Once you hit limits or need high availability
- **Hybrid approach**: Scale up instance size + scale out instance count for optimal cost/performance
- **Rule of thumb**: If you're restarting to scale, you need horizontal scaling

### Horizontal Scaling Implementation

#### App Service Auto-scaling
```json
{
  "name": "ScaleOut-CPUHigh",
  "properties": {
    "profiles": [
      {
        "name": "Auto-scale based on CPU",
        "capacity": {
          "minimum": "2",
          "maximum": "10",
          "default": "2"
        },
        "rules": [
          {
            "metricTrigger": {
              "metricName": "CpuPercentage",
              "metricResourceId": "[resourceId('Microsoft.Web/serverfarms', 'my-app-plan')]",
              "timeGrain": "PT1M",
              "statistic": "Average",
              "timeWindow": "PT5M",
              "timeAggregation": "Average",
              "operator": "GreaterThan",
              "threshold": 70
            },
            "scaleAction": {
              "direction": "Increase",
              "type": "ChangeCount",
              "value": "1",
              "cooldown": "PT5M"
            }
          },
          {
            "metricTrigger": {
              "metricName": "CpuPercentage",
              "timeWindow": "PT5M",
              "timeAggregation": "Average",
              "operator": "LessThan",
              "threshold": 30
            },
            "scaleAction": {
              "direction": "Decrease",
              "type": "ChangeCount",
              "value": "1",
              "cooldown": "PT10M"
            }
          }
        ]
      }
    ]
  }
}
```

#### AKS Horizontal Pod Autoscaler (HPA)
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-deployment
  minReplicas: 2
  maxReplicas: 50
  metrics:
  # CPU-based scaling
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  # Memory-based scaling
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  # Custom metrics (from Application Insights)
  - type: External
    external:
      metric:
        name: requests_per_second
        selector:
          matchLabels:
            service: api
      target:
        type: AverageValue
        averageValue: "1000"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 5
        periodSeconds: 60
      selectPolicy: Max
```

#### Container Apps KEDA Scaling
```yaml
properties:
  template:
    scale:
      minReplicas: 0  # Scale to zero
      maxReplicas: 30
      rules:
      # HTTP request based
      - name: http-rule
        http:
          metadata:
            concurrentRequests: "50"

      # Azure Service Bus queue
      - name: queue-rule
        custom:
          type: azure-servicebus
          metadata:
            queueName: orders
            messageCount: "5"
            namespace: my-servicebus
          auth:
          - secretRef: servicebus-connection
            triggerParameter: connection

      # Azure Storage Queue
      - name: storage-queue-rule
        custom:
          type: azure-queue
          metadata:
            queueName: processing-queue
            queueLength: "10"
            accountName: mystorageaccount

      # Cosmos DB change feed
      - name: cosmosdb-rule
        custom:
          type: azure-cosmosdb
          metadata:
            databaseName: OrdersDB
            collectionName: Orders
            leaseCollectionName: leases
            connectionStringFromEnv: CosmosDBConnection
```

### Application Design for Horizontal Scaling

```csharp
// BAD: Using in-memory state
public class OrderController : ControllerBase
{
    private static Dictionary<string, Order> _orderCache = new();  // ❌ Won't work across instances

    [HttpPost]
    public IActionResult CreateOrder(Order order)
    {
        _orderCache[order.Id] = order;  // Lost when instance scales down
        return Ok();
    }
}

// GOOD: Using distributed cache
public class OrderController : ControllerBase
{
    private readonly IDistributedCache _cache;
    private readonly IDatabase _redis;

    public OrderController(IDistributedCache cache, IConnectionMultiplexer redis)
    {
        _cache = cache;
        _redis = redis.GetDatabase();
    }

    [HttpPost]
    public async Task<IActionResult> CreateOrder(Order order)
    {
        // Use distributed cache
        await _cache.SetStringAsync(
            $"order:{order.Id}",
            JsonSerializer.Serialize(order),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30)
            });

        return Ok();
    }

    // Session management with Redis
    [HttpPost("cart")]
    public async Task<IActionResult> AddToCart(CartItem item)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var cartKey = $"cart:{userId}";

        // Use Redis list operations
        await _redis.ListRightPushAsync(cartKey, JsonSerializer.Serialize(item));
        await _redis.KeyExpireAsync(cartKey, TimeSpan.FromHours(24));

        return Ok();
    }
}

// Session configuration
public void ConfigureServices(IServiceCollection services)
{
    // Distributed session state
    services.AddStackExchangeRedisCache(options =>
    {
        options.Configuration = Configuration["Redis:ConnectionString"];
        options.InstanceName = "SessionCache:";
    });

    services.AddSession(options =>
    {
        options.IdleTimeout = TimeSpan.FromMinutes(30);
        options.Cookie.HttpOnly = true;
        options.Cookie.IsEssential = true;
        options.Cookie.SameSite = SameSiteMode.Strict;
    });
}
```

---

## 2. Failure Domains and Availability Zones

### Azure Availability Concepts

```
Region (e.g., East US)
│
├─ Availability Zone 1
│  ├─ Datacenter 1A
│  └─ Datacenter 1B
│
├─ Availability Zone 2
│  ├─ Datacenter 2A
│  └─ Datacenter 2B
│
└─ Availability Zone 3
   ├─ Datacenter 3A
   └─ Datacenter 3B

Each AZ:
- Physically separate location
- Independent power, cooling, networking
- <2ms latency between zones
- 99.99% SLA with zone redundancy (vs 99.95% single zone)
```

### Failure Domain Strategy

```
Single VM: 99.9% SLA
┌────────────┐
│     VM     │
└────────────┘

Availability Set: 99.95% SLA
Fault Domain 1    Fault Domain 2    Fault Domain 3
┌────────────┐    ┌────────────┐    ┌────────────┐
│    VM1     │    │    VM2     │    │    VM3     │
└────────────┘    └────────────┘    └────────────┘
└─────── Same datacenter, different racks ────────┘

Availability Zones: 99.99% SLA
Zone 1            Zone 2            Zone 3
┌────────────┐    ┌────────────┐    ┌────────────┐
│    VM1     │    │    VM2     │    │    VM3     │
└────────────┘    └────────────┘    └────────────┘
└──── Different physical datacenters ─────────────┘
```

### Implementing Zone Redundancy

#### App Service (Zone Redundant)
```json
{
  "sku": {
    "name": "P1v3",
    "tier": "PremiumV3",
    "capacity": 3
  },
  "properties": {
    "zoneRedundant": true,  // Requires 3+ instances
    "siteConfig": {
      "alwaysOn": true,
      "healthCheckPath": "/health"
    }
  }
}
```

#### AKS with Availability Zones
```bash
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --zones 1 2 3 \
  --node-count 3 \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 15
```

```yaml
# Pod topology spread across zones
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 6
  template:
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: api
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            app: api
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: api
              topologyKey: topology.kubernetes.io/zone
```

#### Azure SQL Zone Redundant
```json
{
  "sku": {
    "name": "GP_Gen5",
    "tier": "GeneralPurpose",
    "capacity": 2
  },
  "properties": {
    "zoneRedundant": true,  // Available in Premium/Business Critical
    "readScale": "Enabled",  // Read replicas
    "highAvailabilityReplicaCount": 1
  }
}
```

#### Cosmos DB Multi-Region
```csharp
var clientOptions = new CosmosClientOptions
{
    ApplicationRegion = Regions.EastUS,
    ApplicationPreferredRegions = new List<string>
    {
        Regions.EastUS,      // Primary
        Regions.EastUS2,     // Same geography for low latency
        Regions.WestUS       // Cross-geography for DR
    }
};

// Account configuration
{
  "locations": [
    {
      "locationName": "East US",
      "failoverPriority": 0,
      "isZoneRedundant": true
    },
    {
      "locationName": "East US 2",
      "failoverPriority": 1,
      "isZoneRedundant": true
    },
    {
      "locationName": "West US",
      "failoverPriority": 2,
      "isZoneRedundant": false
    }
  ],
  "enableMultipleWriteLocations": true,
  "enableAutomaticFailover": true
}
```

---

## 3. Blast Radius Containment Strategies

### Containment Principles

```
Blast Radius Concept:
┌─────────────────────────────────────────┐
│  No Containment (Monolith)              │
│  ┌───────────────────────────────────┐  │
│  │  Single failure = Total outage    │  │
│  │  Blast Radius: 100%               │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘

With Containment (Microservices):
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│Service 1│ │Service 2│ │Service 3│ │Service 4│
│  10%    │ │  10%    │ │  10%    │ │  10%    │
└─────────┘ └─────────┘ └────X────┘ └─────────┘
                              ↑
                         Failure here
                    Blast Radius: 10-25%
```

### Implementation Strategies

#### 1. Bulkhead Pattern

> **What is the Bulkhead Pattern?**
>
> The **bulkhead pattern** isolates elements of an application into pools so that if one fails, the others continue to function. Named after the compartmentalized sections of a ship's hull that prevent the entire ship from sinking if one section is breached.
>
> **How it works:**
> - Limit the number of concurrent calls to a particular resource (e.g., max 10 parallel calls to Payment Service)
> - If the limit is reached, new requests are queued or rejected immediately
> - Failures in one bulkhead don't consume resources needed by other operations
>
> **Why use it?**
> - **Isolation**: A slow dependency doesn't consume all your threads/connections
> - **Fairness**: Critical services get dedicated resources, not starved by non-critical ones
> - **Resilience**: System remains partially functional even when some dependencies fail
>
> **Example scenario:**
> ```
> Without bulkhead: Slow payment service uses all 200 threads, entire app freezes
> With bulkhead: Payment service limited to 10 threads, 190 threads serve other requests
> ```

```csharp
public class BulkheadConfiguration
{
    public static void ConfigureServices(IServiceCollection services)
    {
        // Separate thread pools for different services
        services.AddHttpClient("CriticalService")
            .AddPolicyHandler(GetBulkheadPolicy(maxParallelization: 10, maxQueuingActions: 20));

        services.AddHttpClient("NonCriticalService")
            .AddPolicyHandler(GetBulkheadPolicy(maxParallelization: 3, maxQueuingActions: 5));
    }

    private static IAsyncPolicy<HttpResponseMessage> GetBulkheadPolicy(
        int maxParallelization,
        int maxQueuingActions)
    {
        return Policy.BulkheadAsync<HttpResponseMessage>(
            maxParallelization,
            maxQueuingActions,
            onBulkheadRejectedAsync: async context =>
            {
                await LogBulkheadRejection(context);
            });
    }
}

// Resource isolation
public class ResourceIsolation
{
    private readonly SemaphoreSlim _databaseSemaphore = new(10);  // Max 10 concurrent DB calls
    private readonly SemaphoreSlim _apiSemaphore = new(5);        // Max 5 concurrent API calls

    public async Task<Order> GetOrderAsync(string orderId)
    {
        await _databaseSemaphore.WaitAsync();
        try
        {
            return await _database.GetOrderAsync(orderId);
        }
        finally
        {
            _databaseSemaphore.Release();
        }
    }

    public async Task<ExternalData> GetExternalDataAsync(string id)
    {
        await _apiSemaphore.WaitAsync();
        try
        {
            return await _externalApi.GetDataAsync(id);
        }
        finally
        {
            _apiSemaphore.Release();
        }
    }
}
```

#### 2. Circuit Breaker Isolation

> **What is a Circuit Breaker?**
>
> A **circuit breaker** is a design pattern used to detect failures and prevent cascading failures in distributed systems. It works like an electrical circuit breaker that "trips" when too much current flows through it.
>
> **Three States:**
> - **Closed** (Normal): Requests flow through. The circuit breaker monitors for failures.
> - **Open** (Tripped): After a threshold of failures, the circuit "opens" and immediately fails all requests without calling the downstream service. This prevents overwhelming an already struggling service.
> - **Half-Open** (Testing): After a timeout, the circuit allows a few test requests through. If they succeed, the circuit closes. If they fail, it opens again.
>
> **Why use it?**
> - **Fail fast**: Return errors immediately instead of waiting for timeouts
> - **Protect downstream services**: Stop sending traffic to a failing service so it can recover
> - **Preserve resources**: Don't tie up threads waiting for responses that won't come
> - **Graceful degradation**: Return cached data or defaults while the circuit is open
>
> **Example scenario:**
> ```
> Payment service is down:
> Without circuit breaker: 1000 requests wait 30s each = 500 minutes of blocked threads
> With circuit breaker: After 5 failures, circuit opens, 995 requests fail immediately
> ```

```csharp
public class ServiceResilienceConfiguration
{
    public static void ConfigureServices(IServiceCollection services)
    {
        // Each service gets its own circuit breaker
        services.AddHttpClient("PaymentService")
            .AddPolicyHandler(GetCircuitBreakerPolicy("PaymentService"))
            .AddPolicyHandler(GetRetryPolicy());

        services.AddHttpClient("InventoryService")
            .AddPolicyHandler(GetCircuitBreakerPolicy("InventoryService"))
            .AddPolicyHandler(GetRetryPolicy());

        services.AddHttpClient("ShippingService")
            .AddPolicyHandler(GetCircuitBreakerPolicy("ShippingService"))
            .AddPolicyHandler(GetRetryPolicy());
    }

    private static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy(string serviceName)
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .CircuitBreakerAsync(
                handledEventsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromSeconds(30),
                onBreak: (outcome, duration) =>
                {
                    Log.Error($"{serviceName} circuit broken for {duration}");
                    Metrics.IncrementCounter($"circuit_breaker_open.{serviceName}");
                },
                onReset: () =>
                {
                    Log.Information($"{serviceName} circuit reset");
                    Metrics.IncrementCounter($"circuit_breaker_closed.{serviceName}");
                },
                onHalfOpen: () =>
                {
                    Log.Information($"{serviceName} circuit half-open");
                });
    }
}
```

#### 3. Deployment Ring Strategy
```yaml
# Ring 0: Canary (1% traffic, internal users)
apiVersion: v1
kind: Service
metadata:
  name: api-canary
spec:
  selector:
    app: api
    version: v2
    ring: canary
---
# Ring 1: Early Adopters (10% traffic)
apiVersion: v1
kind: Service
metadata:
  name: api-early
spec:
  selector:
    app: api
    version: v2
    ring: early
---
# Ring 2: General Availability (89% traffic)
apiVersion: v1
kind: Service
metadata:
  name: api-stable
spec:
  selector:
    app: api
    version: v1
    ring: stable
```

**Azure Traffic Manager/Front Door Routing:**
```json
{
  "routingRules": [
    {
      "name": "CanaryRouting",
      "patterns": ["/api/*"],
      "routes": [
        {
          "backend": "api-v2-canary",
          "weight": 1,
          "priority": 1
        },
        {
          "backend": "api-v2-early",
          "weight": 10,
          "priority": 2
        },
        {
          "backend": "api-v1-stable",
          "weight": 89,
          "priority": 3
        }
      ]
    }
  ],
  "healthProbeSettings": {
    "path": "/health",
    "protocol": "Https",
    "intervalInSeconds": 30,
    "healthyStatusCodes": ["200-299"]
  }
}
```

#### 4. Resource Group Isolation
```
Production Environment Isolation:

Subscription
│
├─ RG-Production-EastUS-Web
│  ├─ App Service Plan (Web tier)
│  └─ App Services (3 instances)
│
├─ RG-Production-EastUS-API
│  ├─ AKS Cluster (API tier)
│  └─ Container Registry
│
├─ RG-Production-EastUS-Data
│  ├─ Azure SQL
│  ├─ Cosmos DB
│  └─ Storage Account
│
├─ RG-Production-Shared-Monitoring
│  ├─ Application Insights
│  ├─ Log Analytics
│  └─ Azure Monitor
│
└─ RG-Production-Shared-Security
   ├─ Key Vault
   ├─ Managed Identities
   └─ Private DNS Zones

Benefits:
- Failure in one resource group doesn't affect others
- Independent RBAC and policies
- Easier cost tracking
- Separate deployment lifecycles
```

---

## 4. High Availability Patterns

### Load Balancer Architecture

```
                    Internet
                       │
                       ▼
            ┌──────────────────────┐
            │  Azure Front Door    │
            │  (Global LB + WAF)   │
            └──────────┬───────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    ┌───▼───┐      ┌───▼───┐      ┌───▼───┐
    │Region1│      │Region2│      │Region3│
    │East US│      │West US│      │Europe │
    └───┬───┘      └───┬───┘      └───┬───┘
        │              │              │
    ┌───▼─────────────────────────────▼───┐
    │    Application Gateway (Regional)   │
    │           (WAF + LB)                │
    └───┬─────────────────────────────┬───┘
        │                             │
    ┌───▼───┐                     ┌───▼───┐
    │  AZ 1 │                     │  AZ 2 │
    │ App 1 │                     │ App 2 │
    │ App 2 │                     │ App 3 │
    └───────┘                     └───────┘
```

### Active-Active Pattern

```csharp
public class ActiveActiveConfiguration
{
    public void ConfigureServices(IServiceCollection services)
    {
        // Multi-region write support
        services.AddSingleton<IOrderRepository>(sp =>
        {
            var config = sp.GetRequiredService<IConfiguration>();

            return new CosmosOrderRepository(new CosmosClientOptions
            {
                ApplicationRegion = GetCurrentRegion(),
                ApplicationPreferredRegions = new List<string>
                {
                    Regions.EastUS,
                    Regions.WestUS,
                    Regions.WestEurope
                },
                ConnectionMode = ConnectionMode.Direct,
                ConsistencyLevel = ConsistencyLevel.Session
            });
        });

        // Regional caching with synchronization
        services.AddStackExchangeRedisCache(options =>
        {
            var region = GetCurrentRegion();
            options.Configuration = GetRegionalRedisConnection(region);
            options.InstanceName = $"{region}:";
        });
    }

    private string GetCurrentRegion()
    {
        // Detect region from environment or Azure metadata
        return Environment.GetEnvironmentVariable("REGION_NAME") ?? Regions.EastUS;
    }
}

// Session affinity for active-active
public class SessionAffinityMiddleware
{
    private readonly RequestDelegate _next;

    public async Task InvokeAsync(HttpContext context)
    {
        // Set ARR affinity cookie for session stickiness
        if (!context.Request.Cookies.ContainsKey("ARRAffinity"))
        {
            context.Response.Cookies.Append("ARRAffinity",
                Guid.NewGuid().ToString(),
                new CookieOptions
                {
                    HttpOnly = true,
                    Secure = true,
                    SameSite = SameSiteMode.Lax,
                    MaxAge = TimeSpan.FromHours(24)
                });
        }

        await _next(context);
    }
}
```

### Health Checks Implementation

```csharp
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddHealthChecks()
            // Basic liveness check
            .AddCheck("self", () => HealthCheckResult.Healthy())

            // Database connectivity
            .AddSqlServer(
                connectionString: Configuration["ConnectionStrings:Database"],
                name: "database",
                failureStatus: HealthStatus.Degraded,
                tags: new[] { "db", "sql" })

            // Cosmos DB
            .AddCosmosDb(
                connectionString: Configuration["Cosmos:ConnectionString"],
                database: "OrdersDB",
                name: "cosmosdb",
                failureStatus: HealthStatus.Degraded,
                tags: new[] { "db", "nosql" })

            // Redis cache
            .AddRedis(
                redisConnectionString: Configuration["Redis:ConnectionString"],
                name: "redis",
                failureStatus: HealthStatus.Degraded,
                tags: new[] { "cache" })

            // Service Bus
            .AddAzureServiceBusQueue(
                connectionString: Configuration["ServiceBus:ConnectionString"],
                queueName: "orders",
                name: "servicebus",
                failureStatus: HealthStatus.Degraded,
                tags: new[] { "messaging" })

            // External dependency
            .AddUrlGroup(
                uri: new Uri("https://api.external.com/health"),
                name: "external-api",
                failureStatus: HealthStatus.Degraded,
                tags: new[] { "external" },
                timeout: TimeSpan.FromSeconds(5))

            // Custom health check
            .AddCheck<CustomHealthCheck>("custom");
    }

    public void Configure(IApplicationBuilder app)
    {
        // Liveness probe (Kubernetes)
        app.UseHealthChecks("/health/live", new HealthCheckOptions
        {
            Predicate = (check) => check.Tags.Contains("self"),
            ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
        });

        // Readiness probe (Kubernetes)
        app.UseHealthChecks("/health/ready", new HealthCheckOptions
        {
            Predicate = (check) => check.Tags.Contains("db") || check.Tags.Contains("cache"),
            ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
        });

        // Detailed health check (internal monitoring)
        app.UseHealthChecks("/health", new HealthCheckOptions
        {
            ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
            ResultStatusCodes =
            {
                [HealthStatus.Healthy] = StatusCodes.Status200OK,
                [HealthStatus.Degraded] = StatusCodes.Status200OK,
                [HealthStatus.Unhealthy] = StatusCodes.Status503ServiceUnavailable
            }
        });
    }
}

public class CustomHealthCheck : IHealthCheck
{
    private readonly IOrderService _orderService;
    private readonly ILogger<CustomHealthCheck> _logger;

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Check if we can process orders
            var canProcess = await _orderService.CanProcessOrdersAsync();

            if (!canProcess)
            {
                return HealthCheckResult.Degraded(
                    "Order processing is degraded",
                    data: new Dictionary<string, object>
                    {
                        ["timestamp"] = DateTime.UtcNow,
                        ["reason"] = "High queue depth"
                    });
            }

            return HealthCheckResult.Healthy("Order processing is healthy");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Health check failed");
            return HealthCheckResult.Unhealthy(
                "Order processing is unhealthy",
                exception: ex);
        }
    }
}
```

---

## 5. Disaster Recovery (RTO/RPO) Planning

### Understanding RTO and RPO

> **Key DR Terminology Explained:**
>
> **RTO (Recovery Time Objective)**: The maximum acceptable time that a system can be down after a disaster. It answers: "How long can we afford to be offline?"
> - Example: RTO of 4 hours means the system must be operational within 4 hours of a disaster
> - Lower RTO = higher cost (requires hot standby, automatic failover)
>
> **RPO (Recovery Point Objective)**: The maximum acceptable amount of data loss measured in time. It answers: "How much data can we afford to lose?"
> - Example: RPO of 1 hour means you can lose up to 1 hour of data (from last backup)
> - Lower RPO = more frequent backups = higher cost
>
> **Related Terms:**
> - **MTTR (Mean Time To Recovery)**: Average time to restore service after failure
> - **MTTD (Mean Time To Detect)**: Average time to detect that a failure has occurred
> - **SLA (Service Level Agreement)**: Contractual commitment for service availability (e.g., 99.9% uptime)
> - **SLO (Service Level Objective)**: Internal target, often stricter than SLA
> - **SLI (Service Level Indicator)**: The actual measured metric (e.g., current uptime percentage)
>
> **Practical Example:**
> ```
> Your e-commerce site has:
> - RTO: 1 hour (customers can wait 1 hour max for site to return)
> - RPO: 15 minutes (can afford to lose 15 min of orders - will re-enter manually)
>
> This means:
> - You need hot standby infrastructure (not cold backup that takes 4+ hours)
> - Database replication every 15 min minimum (or real-time async replication)
> ```

```
Timeline of a Disaster:

                  Disaster
                  Occurs
                     ↓
    Normal Ops   ║   ║   Recovery Period   ║   Normal Ops
    ═════════════║═══║════════════════════ ║═══════════════
                 ║   ║                     ║
                 ║   ↓                     ↓
                 ║  Detection           Recovery
                 ║   Time                Complete
                 ║
                 └─────────────┬─────────────┘
                               │
                         RTO (Recovery Time Objective)
                    "How long can we be down?"

    ─────────────┬─────────────
                 │
    Last Backup  │  Data Loss
                 │  Window
                 └─────────────
                       │
                      RPO (Recovery Point Objective)
                 "How much data can we lose?"
```

### DR Tier Classification

| Tier | RTO | RPO | Strategy | Cost | Use Case |
|------|-----|-----|----------|------|----------|
| **Tier 0** | < 1 min | 0 | Active-Active, Sync replication | Very High | Financial trading, critical systems |
| **Tier 1** | < 1 hour | < 15 min | Hot standby, Async replication | High | E-commerce, banking |
| **Tier 2** | < 4 hours | < 1 hour | Warm standby, Regular backups | Medium | Line-of-business apps |
| **Tier 3** | < 24 hours | < 24 hours | Cold standby, Daily backups | Low | Internal tools, reporting |

### Azure DR Implementation

#### Tier 1: Mission-Critical (RTO < 1 hour, RPO < 15 min)

```csharp
// Active-Passive with automatic failover
public class Tier1DRConfiguration
{
    public void ConfigureServices(IServiceCollection services)
    {
        // Azure SQL with auto-failover group
        services.AddDbContext<OrderContext>(options =>
        {
            // Connection to failover group endpoint (not specific server)
            var connectionString =
                "Server=tcp:myapp-failover-group.database.windows.net;" +
                "Database=OrdersDB;" +
                "Authentication=Active Directory Managed Identity;";

            options.UseSqlServer(connectionString, sqlOptions =>
            {
                sqlOptions.EnableRetryOnFailure(
                    maxRetryCount: 5,
                    maxRetryDelay: TimeSpan.FromSeconds(30),
                    errorNumbersToAdd: null);
            });
        });

        // Cosmos DB multi-region
        services.AddSingleton<CosmosClient>(sp =>
        {
            return new CosmosClient(
                accountEndpoint: "https://myaccount.documents.azure.com:443/",
                new DefaultAzureCredential(),
                new CosmosClientOptions
                {
                    ApplicationPreferredRegions = new List<string>
                    {
                        Regions.EastUS,      // Primary
                        Regions.WestUS       // Automatic failover
                    },
                    ConsistencyLevel = ConsistencyLevel.BoundedStaleness,
                    // Bounded staleness: max 10 versions or 5 seconds lag
                    MaxStalenessIntervalInSeconds = 5,
                    MaxStalenessPrefix = 10
                });
        });

        // Storage with RA-GRS (Read-Access Geo-Redundant)
        services.AddSingleton<BlobServiceClient>(sp =>
        {
            var blobClientOptions = new BlobClientOptions
            {
                GeoRedundantSecondaryUri = new Uri("https://myaccount-secondary.blob.core.windows.net/"),
                Retry =
                {
                    Mode = RetryMode.Exponential,
                    MaxRetries = 5,
                    Delay = TimeSpan.FromSeconds(2),
                    MaxDelay = TimeSpan.FromSeconds(30)
                }
            };

            return new BlobServiceClient(
                new Uri("https://myaccount.blob.core.windows.net/"),
                new DefaultAzureCredential(),
                blobClientOptions);
        });
    }
}

// Azure SQL Failover Group configuration (Azure CLI/ARM)
{
  "properties": {
    "readWriteEndpoint": {
      "failoverPolicy": "Automatic",
      "failoverWithDataLossGracePeriodMinutes": 60
    },
    "readOnlyEndpoint": {
      "failoverPolicy": "Disabled"
    },
    "partnerServers": [
      {
        "id": "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Sql/servers/myserver-secondary"
      }
    ],
    "databases": [
      "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Sql/servers/myserver-primary/databases/OrdersDB"
    ]
  }
}
```

#### Tier 2: Business-Critical (RTO < 4 hours, RPO < 1 hour)

```bash
# Azure Backup configuration for VMs
az backup protection enable-for-vm \
  --resource-group myResourceGroup \
  --vault-name myRecoveryServicesVault \
  --vm myVM \
  --policy-name DefaultPolicy

# Backup policy
{
  "name": "HourlyBackupPolicy",
  "properties": {
    "backupManagementType": "AzureIaasVM",
    "schedulePolicy": {
      "schedulePolicyType": "SimpleSchedulePolicy",
      "scheduleRunFrequency": "Hourly",
      "scheduleRunTimes": ["2023-01-01T00:00:00Z"],
      "hourlySchedule": {
        "interval": 4,
        "scheduleWindowStartTime": "2023-01-01T00:00:00Z",
        "scheduleWindowDuration": 24
      }
    },
    "retentionPolicy": {
      "retentionPolicyType": "LongTermRetentionPolicy",
      "dailySchedule": {
        "retentionTimes": ["2023-01-01T02:00:00Z"],
        "retentionDuration": {
          "count": 30,
          "durationType": "Days"
        }
      },
      "weeklySchedule": {
        "daysOfTheWeek": ["Sunday"],
        "retentionTimes": ["2023-01-01T02:00:00Z"],
        "retentionDuration": {
          "count": 12,
          "durationType": "Weeks"
        }
      }
    }
  }
}
```

#### DR Testing and Validation

```csharp
public class DisasterRecoveryTest
{
    // DR drill automation
    public async Task ExecuteDRDrillAsync()
    {
        var drLog = new DrillLog
        {
            StartTime = DateTime.UtcNow,
            Type = "Planned Drill"
        };

        try
        {
            // Step 1: Verify secondary region readiness
            await VerifySecondaryRegionAsync();
            drLog.AddStep("Secondary region verified", true);

            // Step 2: Test failover (read-only)
            await TestFailoverAsync();
            drLog.AddStep("Test failover successful", true);

            // Step 3: Verify data consistency
            var isConsistent = await VerifyDataConsistencyAsync();
            drLog.AddStep("Data consistency check", isConsistent);

            // Step 4: Test application functionality
            await TestApplicationFunctionalityAsync();
            drLog.AddStep("Application functionality verified", true);

            // Step 5: Measure RTO
            var rto = DateTime.UtcNow - drLog.StartTime;
            drLog.ActualRTO = rto;
            drLog.AddStep($"RTO measured: {rto.TotalMinutes} minutes",
                rto.TotalMinutes < 60); // Must be < 1 hour

            // Step 6: Fail back to primary
            await FailbackToPrimaryAsync();
            drLog.AddStep("Failback completed", true);
        }
        catch (Exception ex)
        {
            drLog.AddStep($"Drill failed: {ex.Message}", false);
            drLog.Success = false;
        }
        finally
        {
            drLog.EndTime = DateTime.UtcNow;
            await SaveDrillLogAsync(drLog);
            await NotifyStakeholdersAsync(drLog);
        }
    }

    private async Task<bool> VerifyDataConsistencyAsync()
    {
        var primaryData = await GetDataFromPrimaryAsync();
        var secondaryData = await GetDataFromSecondaryAsync();

        // Check for data drift
        var drift = CalculateDataDrift(primaryData, secondaryData);

        if (drift.TotalRecords > 100 || drift.TimestampDelta > TimeSpan.FromMinutes(15))
        {
            await AlertDRTeamAsync($"Data drift detected: {drift}");
            return false;
        }

        return true;
    }
}
```

---

## 6. Geo-Replication Strategies

### Replication Patterns

```
Synchronous Replication (Strong Consistency)
┌─────────┐                    ┌─────────┐
│Primary  │ ══════════════════>│Secondary│
│ Region  │ <══════════════════│ Region  │
└─────────┘   Acknowledge       └─────────┘
              before commit
Pros: Zero data loss (RPO = 0)
Cons: Higher latency, limited distance
Use: Financial transactions, critical data

Asynchronous Replication (Eventual Consistency)
┌─────────┐                    ┌─────────┐
│Primary  │ ──────────────────>│Secondary│
│ Region  │    Replicate async  │ Region  │
└─────────┘                    └─────────┘
     ↓
  Commit immediately
Pros: Low latency, unlimited distance
Cons: Potential data loss (RPO > 0)
Use: Most applications, read replicas
```

### Azure Storage Replication

```
Locally Redundant Storage (LRS)
┌─────────────────────────────┐
│  Datacenter                 │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │Copy1│ │Copy2│ │Copy3│   │
│  └─────┘ └─────┘ └─────┘   │
└─────────────────────────────┘
Cost: Lowest | Durability: 99.999999999% (11 nines)

Zone-Redundant Storage (ZRS)
┌─────────┐ ┌─────────┐ ┌─────────┐
│  Zone 1 │ │  Zone 2 │ │  Zone 3 │
│ ┌─────┐ │ │ ┌─────┐ │ │ ┌─────┐ │
│ │Copy │ │ │ │Copy │ │ │ │Copy │ │
│ └─────┘ │ │ └─────┘ │ │ └─────┘ │
└─────────┘ └─────────┘ └─────────┘
Cost: Medium | Durability: 99.9999999999% (12 nines)

Geo-Redundant Storage (GRS)
Primary Region          Secondary Region (>300 miles)
┌─────────────────┐    ┌─────────────────┐
│ LRS (3 copies)  │═══>│ LRS (3 copies)  │
└─────────────────┘    └─────────────────┘
Cost: Higher | Durability: 99.99999999999999% (16 nines)

Geo-Zone-Redundant Storage (GZRS)
Primary Region          Secondary Region
┌─────────────────┐    ┌─────────────────┐
│ ZRS (3 zones)   │═══>│ LRS (3 copies)  │
└─────────────────┘    └─────────────────┘
Cost: Highest | Durability: 99.99999999999999% (16 nines)
```

### Application-Level Replication

```csharp
public class GeoReplicationService
{
    private readonly BlobServiceClient _primaryStorage;
    private readonly BlobServiceClient _secondaryStorage;

    // Write to primary, async replicate to secondary
    public async Task<string> UploadWithReplicationAsync(
        string containerName,
        string blobName,
        Stream content)
    {
        // Write to primary
        var primaryContainer = _primaryStorage.GetBlobContainerClient(containerName);
        var primaryBlob = primaryContainer.GetBlobClient(blobName);

        var uploadResult = await primaryBlob.UploadAsync(content, overwrite: true);

        // Async replication to secondary (fire-and-forget with monitoring)
        _ = Task.Run(async () =>
        {
            try
            {
                var secondaryContainer = _secondaryStorage.GetBlobContainerClient(containerName);
                var secondaryBlob = secondaryContainer.GetBlobClient(blobName);

                content.Position = 0;
                await secondaryBlob.UploadAsync(content, overwrite: true);

                Log.Information($"Replicated {blobName} to secondary region");
            }
            catch (Exception ex)
            {
                Log.Error(ex, $"Failed to replicate {blobName} to secondary");
                // Queue for retry
                await QueueReplicationRetryAsync(containerName, blobName);
            }
        });

        return uploadResult.Value.ETag.ToString();
    }

    // Read with fallback to secondary
    public async Task<Stream> DownloadWithFallbackAsync(
        string containerName,
        string blobName)
    {
        try
        {
            var primaryContainer = _primaryStorage.GetBlobContainerClient(containerName);
            var primaryBlob = primaryContainer.GetBlobClient(blobName);

            var download = await primaryBlob.DownloadAsync();
            return download.Value.Content;
        }
        catch (RequestFailedException ex) when (ex.Status == 503 || ex.Status == 500)
        {
            // Fallback to secondary region
            Log.Warning($"Primary region unavailable, reading from secondary");

            var secondaryContainer = _secondaryStorage.GetBlobContainerClient(containerName);
            var secondaryBlob = secondaryContainer.GetBlobClient(blobName);

            var download = await secondaryBlob.DownloadAsync();
            return download.Value.Content;
        }
    }
}
```

---

## 7. Autoscaling Rules and Metrics

### Comprehensive Autoscaling Configuration

```csharp
// Custom metrics for autoscaling
public class AutoscalingMetricsCollector
{
    private readonly TelemetryClient _telemetry;

    public void TrackMetrics()
    {
        // Business metrics for scaling decisions
        _telemetry.GetMetric("ActiveUsers").TrackValue(GetActiveUserCount());
        _telemetry.GetMetric("QueueDepth").TrackValue(GetQueueDepth());
        _telemetry.GetMetric("RequestLatency").TrackValue(GetAverageLatency());
        _telemetry.GetMetric("ErrorRate").TrackValue(GetErrorRate());
        _telemetry.GetMetric("DatabaseConnections").TrackValue(GetActiveConnections());
    }
}
```

**App Service Autoscale Rules (ARM Template):**
```json
{
  "type": "Microsoft.Insights/autoscalesettings",
  "apiVersion": "2022-10-01",
  "name": "ProductionAutoscale",
  "properties": {
    "profiles": [
      {
        "name": "Default",
        "capacity": {
          "minimum": "3",
          "maximum": "20",
          "default": "3"
        },
        "rules": [
          {
            "metricTrigger": {
              "metricName": "CpuPercentage",
              "metricResourceUri": "[resourceId('Microsoft.Web/serverfarms', 'myAppServicePlan')]",
              "timeGrain": "PT1M",
              "statistic": "Average",
              "timeWindow": "PT5M",
              "timeAggregation": "Average",
              "operator": "GreaterThan",
              "threshold": 70
            },
            "scaleAction": {
              "direction": "Increase",
              "type": "PercentChangeCount",
              "value": "20",
              "cooldown": "PT5M"
            }
          },
          {
            "metricTrigger": {
              "metricName": "MemoryPercentage",
              "timeWindow": "PT5M",
              "operator": "GreaterThan",
              "threshold": 80
            },
            "scaleAction": {
              "direction": "Increase",
              "type": "ChangeCount",
              "value": "2",
              "cooldown": "PT5M"
            }
          },
          {
            "metricTrigger": {
              "metricName": "HttpQueueLength",
              "timeWindow": "PT5M",
              "operator": "GreaterThan",
              "threshold": 100
            },
            "scaleAction": {
              "direction": "Increase",
              "type": "ChangeCount",
              "value": "3",
              "cooldown": "PT3M"
            }
          },
          {
            "metricTrigger": {
              "metricName": "CpuPercentage",
              "timeWindow": "PT10M",
              "operator": "LessThan",
              "threshold": 30
            },
            "scaleAction": {
              "direction": "Decrease",
              "type": "ChangeCount",
              "value": "1",
              "cooldown": "PT10M"
            }
          }
        ]
      },
      {
        "name": "BusinessHours",
        "capacity": {
          "minimum": "5",
          "maximum": "30",
          "default": "5"
        },
        "recurrence": {
          "frequency": "Week",
          "schedule": {
            "timeZone": "Eastern Standard Time",
            "days": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
            "hours": [8],
            "minutes": [0]
          }
        },
        "rules": []
      },
      {
        "name": "BlackFriday",
        "capacity": {
          "minimum": "20",
          "maximum": "100",
          "default": "20"
        },
        "fixedDate": {
          "timeZone": "Eastern Standard Time",
          "start": "2024-11-29T00:00:00",
          "end": "2024-12-02T23:59:59"
        },
        "rules": []
      }
    ],
    "notifications": [
      {
        "operation": "Scale",
        "email": {
          "sendToSubscriptionAdministrator": false,
          "customEmails": ["ops-team@company.com"]
        },
        "webhooks": [
          {
            "serviceUri": "https://alerts.company.com/autoscale"
          }
        ]
      }
    ]
  }
}
```

### Advanced AKS Autoscaling

```yaml
# Cluster Autoscaler
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-autoscaler-config
  namespace: kube-system
data:
  scale-down-enabled: "true"
  scale-down-delay-after-add: "10m"
  scale-down-unneeded-time: "10m"
  scale-down-utilization-threshold: "0.5"
  max-node-provision-time: "15m"
  skip-nodes-with-system-pods: "false"

---
# KEDA ScaledObject with multiple triggers
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: order-processor-scaler
spec:
  scaleTargetRef:
    name: order-processor
  minReplicaCount: 2
  maxReplicaCount: 50
  pollingInterval: 30
  cooldownPeriod: 300
  triggers:
  # CPU-based scaling
  - type: cpu
    metricType: Utilization
    metadata:
      value: "70"

  # Memory-based scaling
  - type: memory
    metricType: Utilization
    metadata:
      value: "80"

  # Service Bus queue
  - type: azure-servicebus
    metadata:
      queueName: orders
      namespace: my-servicebus
      messageCount: "5"
      activationMessageCount: "0"
    authenticationRef:
      name: servicebus-auth

  # Application Insights (custom metric)
  - type: azure-monitor
    metadata:
      tenantId: "xxx"
      subscriptionId: "xxx"
      resourceGroupName: "myResourceGroup"
      resourceName: "myAppInsights"
      metricName: "customMetrics/ActiveOrders"
      targetValue: "100"
      activationTargetValue: "50"
    authenticationRef:
      name: azure-monitor-auth

  # External HTTP endpoint
  - type: metrics-api
    metadata:
      targetValue: "1000"
      url: "https://api.company.com/metrics/requests-per-second"
      valueLocation: "value"

  advanced:
    restoreToOriginalReplicaCount: false
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
          - type: Percent
            value: 50
            periodSeconds: 60
          - type: Pods
            value: 5
            periodSeconds: 60
          selectPolicy: Min
        scaleUp:
          stabilizationWindowSeconds: 0
          policies:
          - type: Percent
            value: 100
            periodSeconds: 15
          - type: Pods
            value: 10
            periodSeconds: 15
          selectPolicy: Max
```

---

## 8. Chaos Engineering Mindset

### Principles of Chaos Engineering

1. **Define steady state**: Establish baseline metrics
2. **Hypothesize**: Predict what will happen
3. **Introduce chaos**: Inject failures
4. **Monitor and learn**: Observe system behavior
5. **Automate**: Run chaos experiments continuously

### Azure Chaos Studio

```json
{
  "name": "VM-Shutdown-Experiment",
  "type": "Microsoft.Chaos/experiments",
  "properties": {
    "steps": [
      {
        "name": "Step 1: Shutdown VMs",
        "branches": [
          {
            "name": "Branch 1",
            "actions": [
              {
                "type": "continuous",
                "name": "urn:csci:microsoft:virtualMachine:shutdown/1.0",
                "parameters": [
                  {
                    "key": "abruptShutdown",
                    "value": "true"
                  }
                ],
                "duration": "PT10M",
                "selectorId": "WebTierVMs"
              }
            ]
          }
        ]
      }
    ],
    "selectors": [
      {
        "id": "WebTierVMs",
        "type": "List",
        "targets": [
          {
            "type": "Microsoft.Compute/virtualMachines",
            "id": "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/web-vm-1"
          },
          {
            "type": "Microsoft.Compute/virtualMachines",
            "id": "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/web-vm-2"
          }
        ]
      }
    ]
  }
}
```

### Custom Chaos Injection

```csharp
public class ChaosMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IConfiguration _configuration;
    private readonly Random _random = new();

    public async Task InvokeAsync(HttpContext context)
    {
        var chaosEnabled = _configuration.GetValue<bool>("Chaos:Enabled");

        if (chaosEnabled && ShouldInjectChaos())
        {
            var chaosType = _configuration.GetValue<string>("Chaos:Type");

            switch (chaosType)
            {
                case "Latency":
                    await InjectLatencyAsync();
                    break;
                case "Exception":
                    InjectException();
                    break;
                case "ResourceExhaustion":
                    InjectResourceExhaustion();
                    break;
                case "HttpError":
                    await InjectHttpErrorAsync(context);
                    return;
            }
        }

        await _next(context);
    }

    private bool ShouldInjectChaos()
    {
        var probability = _configuration.GetValue<double>("Chaos:Probability", 0.01);
        return _random.NextDouble() < probability;
    }

    private async Task InjectLatencyAsync()
    {
        var latencyMs = _configuration.GetValue<int>("Chaos:LatencyMs", 5000);
        await Task.Delay(_random.Next(latencyMs / 2, latencyMs));
    }

    private void InjectException()
    {
        throw new ChaosException("Chaos Engineering: Simulated exception");
    }

    private void InjectResourceExhaustion()
    {
        // Simulate memory pressure
        var wasteMemory = new byte[10 * 1024 * 1024]; // 10 MB
        GC.KeepAlive(wasteMemory);
    }

    private async Task InjectHttpErrorAsync(HttpContext context)
    {
        var statusCodes = new[] { 500, 502, 503, 504, 429 };
        var statusCode = statusCodes[_random.Next(statusCodes.Length)];

        context.Response.StatusCode = statusCode;
        await context.Response.WriteAsJsonAsync(new
        {
            error = "Chaos Engineering: Simulated HTTP error",
            statusCode,
            timestamp = DateTime.UtcNow
        });
    }
}

// Configuration
{
  "Chaos": {
    "Enabled": true,
    "Type": "Latency",
    "Probability": 0.05,
    "LatencyMs": 3000
  }
}
```

### Chaos Experiments Examples

```bash
# Experiment 1: Network latency
# Hypothesis: System handles 3s latency gracefully

# Experiment 2: Database failover
# Hypothesis: Application recovers within 60s of DB failover

# Experiment 3: AZ failure
# Hypothesis: Traffic automatically routes to healthy AZ

# Experiment 4: High CPU load
# Hypothesis: Auto-scaling triggers and maintains SLA

# Experiment 5: Memory leak
# Hypothesis: OOMKiller restarts pod, minimal user impact
```

---

## 9. Cost Optimization Strategies

### Cost Optimization Framework

```
Cost Optimization Pillars:
┌────────────────────────────────────────┐
│ 1. Right-Sizing                        │
│    - Match resources to actual needs   │
└────────────────────────────────────────┘
┌────────────────────────────────────────┐
│ 2. Reserved Capacity                   │
│    - Commit for discounts              │
└────────────────────────────────────────┘
┌────────────────────────────────────────┐
│ 3. Auto-Scaling                        │
│    - Scale down when not needed        │
└────────────────────────────────────────┘
┌────────────────────────────────────────┐
│ 4. Spot/Preemptible Instances          │
│    - Use for fault-tolerant workloads  │
└────────────────────────────────────────┘
┌────────────────────────────────────────┐
│ 5. Lifecycle Management                │
│    - Archive/delete unused data        │
└────────────────────────────────────────┘
┌────────────────────────────────────────┐
│ 6. Resource Tagging                    │
│    - Track and attribute costs         │
└────────────────────────────────────────┘
```

### Serverless vs Always-On Cost Comparison

```
Scenario: API with variable traffic
- Average: 100 req/min
- Peak: 5,000 req/min (2 hours/day)
- Off-peak: 10 req/min (14 hours/day)

Option 1: App Service (Always-On)
- P1v3: 2 vCPU, 8 GB RAM
- Cost: $146/month (Linux) or $292/month (Windows)
- Utilization: ~20% average
- Waste: $117-234/month

Option 2: Container Apps (Scale-to-Zero)
- vCPU-s: ~50,000/month
- Memory GB-s: ~100,000/month
- Requests: ~4.3M/month
- Cost: ~$25-40/month
- Savings: ~75-85%

Option 3: Functions (Consumption)
- Executions: ~4.3M/month
- Execution time: ~200ms average
- Cost: ~$20/month
- Savings: ~86%

Option 4: Functions (Premium EP1)
- Always-ready: 1 instance
- Auto-scale: Up to 10
- Cost: ~$150/month
- Balance: Performance + reasonable cost
```

### Reserved Instances Strategy

```csharp
// Cost analysis helper
public class ReservedInstanceAnalyzer
{
    public ReservationRecommendation AnalyzeReservationPotential(
        ResourceUsage usage,
        int months = 12)
    {
        var payAsYouGoCost = usage.HoursPerMonth * usage.HourlyRate * months;

        // 1-year reserved: 40% discount
        var reserved1YearCost = usage.HoursPerMonth * usage.HourlyRate * 0.6m * months;

        // 3-year reserved: 62% discount
        var reserved3YearCost = usage.HoursPerMonth * usage.HourlyRate * 0.38m * months;

        return new ReservationRecommendation
        {
            PayAsYouGoCost = payAsYouGoCost,
            Reserved1YearCost = reserved1YearCost,
            Reserved1YearSavings = payAsYouGoCost - reserved1YearCost,
            Reserved3YearCost = reserved3YearCost,
            Reserved3YearSavings = payAsYouGoCost - reserved3YearCost,
            RecommendedAction = DetermineRecommendation(usage)
        };
    }

    private string DetermineRecommendation(ResourceUsage usage)
    {
        if (usage.ConsistentUsage && usage.MinimumMonths >= 12)
            return "Purchase 1-year reservation";

        if (usage.ConsistentUsage && usage.MinimumMonths >= 36)
            return "Purchase 3-year reservation for maximum savings";

        if (usage.VariableUsage)
            return "Use pay-as-you-go with autoscaling";

        return "Monitor usage for 3 more months before deciding";
    }
}
```

**Reservation Purchase Strategy:**
```
Dev/Test: Pay-as-you-go (stopped after hours)
Staging: Reserved instances (1-year)
Production baseline: Reserved instances (3-year)
Production burst: Pay-as-you-go or spot instances
```

### Storage Lifecycle Management

```json
{
  "rules": [
    {
      "name": "MoveToCool",
      "enabled": true,
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"],
          "prefixMatch": ["logs/", "backups/"]
        },
        "actions": {
          "baseBlob": {
            "tierToCool": {
              "daysAfterModificationGreaterThan": 30
            },
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 90
            },
            "delete": {
              "daysAfterModificationGreaterThan": 365
            }
          },
          "snapshot": {
            "delete": {
              "daysAfterCreationGreaterThan": 90
            }
          }
        }
      }
    },
    {
      "name": "DeleteOldVersions",
      "enabled": true,
      "type": "Lifecycle",
      "definition": {
        "actions": {
          "version": {
            "delete": {
              "daysAfterCreationGreaterThan": 30
            }
          }
        }
      }
    }
  ]
}

Storage Tier Costs (example):
Hot:     $0.0184/GB/month, $0.004 per 10,000 write ops
Cool:    $0.0100/GB/month, $0.010 per 10,000 write ops
Archive: $0.0020/GB/month, $5.00 per 10,000 read ops

Savings example (100 TB logs):
All Hot:     $1,840/month
30d Hot:     $614/month
60d Cool:    $667/month
Rest Archive: $182/month
Total:       $1,463/month
Savings:     $377/month (20%)
```

---

## 10. Cost Monitoring & Alerts

### Budget and Alerts Configuration

```json
{
  "type": "Microsoft.Consumption/budgets",
  "name": "ProductionBudget",
  "properties": {
    "category": "Cost",
    "amount": 10000,
    "timeGrain": "Monthly",
    "timePeriod": {
      "startDate": "2024-01-01",
      "endDate": "2024-12-31"
    },
    "filter": {
      "tags": {
        "name": "Environment",
        "values": ["Production"]
      }
    },
    "notifications": {
      "Actual_GreaterThan_80_Percent": {
        "enabled": true,
        "operator": "GreaterThan",
        "threshold": 80,
        "contactEmails": ["finance@company.com", "ops@company.com"],
        "contactRoles": ["Owner", "Contributor"],
        "contactGroups": ["/subscriptions/{sub}/resourceGroups/Alerts/providers/microsoft.insights/actionGroups/CostAlerts"],
        "thresholdType": "Actual"
      },
      "Forecasted_GreaterThan_100_Percent": {
        "enabled": true,
        "operator": "GreaterThan",
        "threshold": 100,
        "contactEmails": ["finance@company.com"],
        "thresholdType": "Forecasted"
      }
    }
  }
}
```

### Cost Analysis Automation

```csharp
public class CostAnalysisService
{
    private readonly ConsumptionManagementClient _client;

    public async Task<CostReport> GenerateMonthlyCostReportAsync()
    {
        var scope = $"/subscriptions/{subscriptionId}";
        var dateRange = new DateRange
        {
            Start = DateTime.UtcNow.AddMonths(-1).ToString("yyyy-MM-01"),
            End = DateTime.UtcNow.ToString("yyyy-MM-01")
        };

        var query = new QueryDefinition
        {
            Type = "ActualCost",
            Timeframe = "Custom",
            TimePeriod = dateRange,
            Dataset = new QueryDataset
            {
                Granularity = "Daily",
                Aggregation = new Dictionary<string, QueryAggregation>
                {
                    ["totalCost"] = new QueryAggregation { Name = "PreTaxCost", Function = "Sum" }
                },
                Grouping = new List<QueryGrouping>
                {
                    new QueryGrouping { Type = "Dimension", Name = "ResourceGroup" },
                    new QueryGrouping { Type = "Dimension", Name = "Service" },
                    new QueryGrouping { Type = "Tag", Name = "Environment" }
                }
            }
        };

        var result = await _client.Query.UsageAsync(scope, query);

        return ProcessCostData(result);
    }

    public async Task DetectAnomaliesAsync()
    {
        var currentCost = await GetCurrentMonthCostAsync();
        var historicalAverage = await GetHistoricalAverageAsync(months: 3);
        var standardDeviation = await GetStandardDeviationAsync(months: 3);

        // Detect anomalies using statistical methods
        if (currentCost > historicalAverage + (2 * standardDeviation))
        {
            await SendAnomalyAlertAsync(new CostAnomaly
            {
                CurrentCost = currentCost,
                ExpectedCost = historicalAverage,
                Deviation = (currentCost - historicalAverage) / historicalAverage * 100,
                Severity = "High"
            });
        }
    }

    public async Task<List<CostOptimizationRecommendation>> GetRecommendationsAsync()
    {
        var recommendations = new List<CostOptimizationRecommendation>();

        // Check for underutilized resources
        var underutilized = await FindUnderutilizedResourcesAsync();
        recommendations.AddRange(underutilized.Select(r => new CostOptimizationRecommendation
        {
            ResourceId = r.Id,
            Type = "Underutilized",
            CurrentCost = r.MonthlyCost,
            PotentialSavings = r.MonthlyCost * 0.7m,
            Action = $"Consider downsizing or removing {r.Name}"
        }));

        // Check for orphaned resources
        var orphaned = await FindOrphanedResourcesAsync();
        recommendations.AddRange(orphaned.Select(r => new CostOptimizationRecommendation
        {
            ResourceId = r.Id,
            Type = "Orphaned",
            CurrentCost = r.MonthlyCost,
            PotentialSavings = r.MonthlyCost,
            Action = $"Delete orphaned resource: {r.Name}"
        }));

        // Check for reservation opportunities
        var reservationOpportunities = await FindReservationOpportunitiesAsync();
        recommendations.AddRange(reservationOpportunities);

        return recommendations;
    }
}
```

---

## 11. Scaling + Cost Case Study

### Scenario: E-Commerce Platform

**Requirements:**
- Handle Black Friday traffic (100x normal load)
- Maintain <200ms p95 latency
- 99.95% availability SLA
- Optimize costs during normal operations

**Architecture:**
```
┌─────────────────────────────────────────────────────────────┐
│ Azure Front Door (Global LB + CDN)                          │
│ - Static content caching (90% of requests)                  │
│ - Cost: $35/month base + $0.06/GB                           │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│ API Management (Developer tier → Standard during events)    │
│ - Rate limiting: 1000 req/s per user                        │
│ - Response caching: 60s TTL for product catalog             │
│ - Cost: $50/month (switches to $700/month for 3 days)       │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
┌───────▼────────┐  ┌───────▼────────┐
│  AKS (East US) │  │ AKS (West US)  │
│                │  │                │
│ Normal:        │  │ Normal:        │
│ - 3 nodes      │  │ - 3 nodes      │
│ - D4s_v3       │  │ - D4s_v3       │
│ - Cost: $280/m │  │ - Cost: $280/m │
│                │  │                │
│ Black Friday:  │  │ Black Friday:  │
│ - 30 nodes     │  │ - 30 nodes     │
│ - D4s_v3       │  │ - D4s_v3       │
│ - Cost: $2800  │  │ - Cost: $2800  │
│   (3 days)     │  │   (3 days)     │
└───────┬────────┘  └───────┬────────┘
        │                   │
        └─────────┬─────────┘
                  │
        ┌─────────▼─────────┐
        │  Cosmos DB        │
        │  (Multi-region)   │
        │                   │
        │ Normal:           │
        │ - 4,000 RU/s      │
        │ - Cost: $230/m    │
        │                   │
        │ Black Friday:     │
        │ - 40,000 RU/s     │
        │ - Cost: $2300     │
        │   (autoscale)     │
        └───────────────────┘
```

**Cost Optimization Strategies Applied:**

1. **Baseline Reserved Capacity**
   - Reserved 3 AKS nodes (3-year): Save 62%
   - Reserved 2,000 RU/s Cosmos: Save 65%
   - Savings: ~$400/month

2. **Event-Based Scaling**
   - Pre-schedule scaling for known events
   - Gradual ramp-up starting 2 days before
   - Immediate scale-down after event

3. **Caching Strategy**
   - CDN for static assets: 90% cache hit ratio
   - Redis for product catalog: 95% cache hit ratio
   - APIM response cache: 80% cache hit ratio
   - Result: 90% reduction in backend calls

4. **Spot Instances for Batch Jobs**
   - Order processing workers: 70% cost reduction
   - Acceptable interruption for async workloads

**Implementation:**

```yaml
# AKS node pool configuration
apiVersion: v1
kind: NodePool
metadata:
  name: user-pool
spec:
  mode: User
  # Reserved baseline
  count: 3
  minCount: 3
  maxCount: 50
  vmSize: Standard_D4s_v3
  enableAutoScaling: true

  # Spot instances for burst capacity
  scaleSetPriority: Spot
  scaleSetEvictionPolicy: Delete
  spotMaxPrice: 0.05  # Max $0.05/hour

  # Node labels for workload assignment
  nodeLabels:
    workload: api
    tier: burst

  nodeTaints:
  - key: spot
    value: "true"
    effect: NoSchedule

---
# Deployment with node affinity
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  replicas: 10
  template:
    spec:
      # Prefer spot, tolerate regular nodes
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: tier
                operator: In
                values:
                - burst
      tolerations:
      - key: spot
        operator: Equal
        value: "true"
        effect: NoSchedule
```

```csharp
// Cosmos DB autoscale configuration
var containerProperties = new ContainerProperties
{
    Id = "products",
    PartitionKeyPath = "/category"
};

// Autoscale between 1,000 and 40,000 RU/s
ThroughputProperties autoscaleThroughput =
    ThroughputProperties.CreateAutoscaleThroughput(maxThroughput: 40000);

await database.CreateContainerIfNotExistsAsync(
    containerProperties,
    autoscaleThroughput);
```

**Results:**
```
Normal Month (November 1-24):
- AKS: $560 (2 regions, 3 nodes each, reserved)
- Cosmos DB: $115 (2,000 RU/s average with autoscale)
- APIM: $50 (Developer tier)
- CDN: $200 (traffic + bandwidth)
- Total: $925

Black Friday Weekend (November 25-27):
- AKS: $1,400 (60 nodes across regions, 3 days)
- Cosmos DB: $575 (15,000 RU/s average, spike to 40k)
- APIM: $70 (temporary upgrade, 3 days)
- CDN: $800 (10x traffic)
- Total: $2,845 (3 days)

Monthly Total: $4,770

Without optimization:
- AKS always at peak: $2,800 * 2 = $5,600
- Cosmos always at peak: $2,300
- APIM Standard: $700
- CDN: $400
- Total: $9,000

Savings: $4,230/month (47%)
Annual savings: $50,760
```

---

## Interview Questions

**Q1: Your application costs have doubled this month. How do you investigate?**

**Answer:**
1. Use Azure Cost Management to identify cost spike by resource group and service
2. Check for autoscaling events that didn't scale down
3. Look for orphaned resources (VMs, disks, IPs)
4. Review deployment history for configuration changes
5. Check for data egress spikes (cross-region transfer)
6. Analyze Cosmos DB RU consumption for inefficient queries
7. Review storage account for unexpected data growth
8. Check for DDoS or abuse causing excessive usage

**Q2: Design a DR strategy for RTO 1 hour, RPO 15 minutes, budget-conscious.**

**Answer:**
- Azure SQL: Geo-replication with read replicas (built-in)
- Cosmos DB: Multi-region with automatic failover (inherent)
- App Services: Deploy to secondary region, keep stopped (cold standby)
- Storage: RA-GRS for blobs
- Automation: Azure Site Recovery for quick failover
- Testing: Quarterly DR drills
- Cost: ~30% overhead vs active-active
- Failover: Automated Azure Traffic Manager cutover

**Q3: When would you choose vertical scaling over horizontal?**

**Answer:**
Vertical scaling when:
- Database workloads (sharding is complex)
- Legacy applications not designed for distributed systems
- Licensing costs favor larger VMs over more instances
- Temporary spike (faster than spinning up instances)
- Development/testing environments

Horizontal scaling when:
- Production stateless applications
- High availability required
- Unlimited scale needed
- Cost optimization through auto-scaling
- Microservices architecture

---

## Key Takeaways

1. **Scaling**: Horizontal scaling is preferred for production, requires stateless design
2. **Availability**: Use Availability Zones for 99.99% SLA, multi-region for DR
3. **Blast Radius**: Isolate failures through bulkheads, circuit breakers, and resource isolation
4. **RTO/RPO**: Match DR strategy to business requirements, not over-engineer
5. **Autoscaling**: Use multiple metrics, schedule for known patterns, aggressive scale-up, conservative scale-down
6. **Chaos**: Embrace failure testing, automate experiments
7. **Cost**: Right-size, use reservations for baseline, pay-as-you-go for burst
8. **Monitoring**: Proactive alerts on cost anomalies, regular optimization reviews

---

## Next Steps

- Day 12: Security Architecture
- Practice designing multi-region architectures
- Set up cost budgets and alerts
- Run a DR drill
- Implement autoscaling with custom metrics
