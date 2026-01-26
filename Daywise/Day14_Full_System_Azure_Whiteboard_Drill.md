# Day 14: Full System Azure Whiteboard Drill

## Overview
Master the 60-minute system design interview with Azure-focused architecture patterns. This guide provides structured templates, real examples, and architect-level confidence building.

---

## 60-Minute System Design Exercise Template

### Time Allocation Strategy
```
0-10 min:  Requirements Gathering & Clarification
10-20 min: High-Level Architecture & Components
20-35 min: Deep Dive into Critical Components
35-45 min: Scale, Security, and Reliability
45-55 min: Cost Optimization & Trade-offs
55-60 min: Q&A and Edge Cases
```

**Architect-Level Strategy:**
- **Don't jump to solution**: Resist urge to start drawing immediately
- **Establish constraints first**: Scale, budget, SLAs drive architecture choices
- **Think out loud**: Articulate trade-offs as you make decisions
- **Start simple, iterate**: Begin with MVP, then layer complexity
- **Azure-specific**: Mention Azure services by name, show familiarity

### The Opening Framework (First 10 Minutes)

**Start with these questions:**
1. "Let me clarify the functional requirements first..."
2. "What's our expected scale - users, transactions, data volume?"
3. "Are there specific latency or availability SLAs?"
4. "What's our budget constraint and timeline?"
5. "Any compliance requirements - GDPR, HIPAA, PCI-DSS?"

**Template Script:**
```
"Thank you for the problem. Before I start designing, let me ensure
I understand the requirements correctly. I'll ask a few clarifying
questions, then propose a high-level architecture, and we can dive
deeper into areas you're most interested in."
```

---

## Requirements Gathering Framework

### Functional Requirements Checklist
```markdown
Core Features:
- [ ] What are the primary user actions?
- [ ] What data needs to be stored and retrieved?
- [ ] Are there any workflows or state machines?
- [ ] Integration requirements with external systems?
- [ ] Admin/management capabilities needed?

User Experience:
- [ ] Web, mobile, or both?
- [ ] Real-time updates required?
- [ ] Offline capabilities needed?
- [ ] Search functionality requirements?
```

### Non-Functional Requirements Template
```markdown
Scale & Performance:
- Daily Active Users (DAU): ___________
- Peak requests per second: ___________
- Data volume (current/5-year): ___________
- Read:Write ratio: ___________
- P95 latency target: ___________

Availability & Reliability:
- SLA target: ___________% (e.g., 99.9%, 99.99%)
- Acceptable downtime: ___________
- Data consistency requirements: ___________
- Geographic distribution: ___________

Security & Compliance:
- Authentication method: ___________
- Data sensitivity level: ___________
- Regulatory requirements: ___________
- Audit logging needs: ___________
```

---

## Architecture Diagramming Best Practices

### Visual Hierarchy Rules

**Layer 1: Client/Entry Points**
```
[Web Browsers] [Mobile Apps] [Partner APIs]
         ▼           ▼            ▼
```

**Layer 2: Edge/Gateway**
```
    [Azure Front Door / API Gateway]
                ▼
        [Load Balancer]
```

**Layer 3: Application Services**
```
    [Service A]  [Service B]  [Service C]
         ▼           ▼            ▼
```

**Layer 4: Data/Storage**
```
    [Cache]  [Database]  [Blob Storage]
```

**Layer 5: Supporting Services**
```
[Monitoring] [Logging] [Message Queue] [CDN]
```

### Diagramming Tips for Whiteboard

1. **Start with boxes, not lines**
   - Draw all major components first
   - Then connect with arrows showing data flow

2. **Use consistent shapes**
   - Rectangles: Services/Applications
   - Cylinders: Databases/Storage
   - Clouds: External services
   - Diamonds: Decision points

3. **Label everything clearly**
   - Component names
   - Data flow direction (arrows)
   - Protocols (HTTP, gRPC, async)
   - Azure service names

4. **Show scaling explicitly**
   - Multiple boxes for distributed services
   - Load balancer icons
   - Auto-scaling annotations

### Example Notation System
```
[Web App]              = Azure App Service
[Container]            = Azure Container Apps / AKS
((Cache))              = Azure Redis Cache
{Queue}                = Azure Service Bus / Storage Queue
|DB|                   = Azure SQL / Cosmos DB
[===Blob===]           = Azure Blob Storage
[CDN]                  = Azure CDN / Front Door
```

---

## Security Considerations Checklist

### Authentication & Authorization
```markdown
Identity Management:
- [ ] Azure AD B2C for customer identity
- [ ] Azure AD for employee/internal access
- [ ] Managed Identity for service-to-service auth
- [ ] Multi-factor authentication (MFA)
- [ ] OAuth 2.0 / OpenID Connect flows

Authorization:
- [ ] Role-Based Access Control (RBAC)
- [ ] Attribute-Based Access Control (ABAC)
- [ ] Resource-level permissions
- [ ] API key management (Azure Key Vault)
```

### Network Security
```markdown
Perimeter Protection:
- [ ] Azure Front Door with WAF
- [ ] DDoS Protection Standard
- [ ] Private endpoints for PaaS services
- [ ] Network Security Groups (NSGs)
- [ ] Application Security Groups (ASGs)

Internal Security:
- [ ] Virtual Network isolation
- [ ] Subnet segmentation
- [ ] Service endpoints
- [ ] VPN Gateway for hybrid connectivity
- [ ] Azure Firewall for egress filtering
```

### Data Protection
```markdown
Encryption:
- [ ] TLS 1.2+ for data in transit
- [ ] Azure Storage Service Encryption (at rest)
- [ ] Transparent Data Encryption for SQL
- [ ] Customer-managed keys (Azure Key Vault)
- [ ] Column-level encryption for sensitive data

Data Privacy:
- [ ] Data residency requirements
- [ ] PII identification and masking
- [ ] Data retention policies
- [ ] Right to deletion (GDPR)
- [ ] Audit logging of data access
```

### Application Security
```markdown
Code & Runtime:
- [ ] Input validation and sanitization
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS protection headers
- [ ] CSRF tokens
- [ ] Dependency scanning (GitHub Advanced Security)
- [ ] Secrets management (never in code)
- [ ] Container scanning (Azure Defender)

API Security:
- [ ] Rate limiting / throttling
- [ ] API versioning strategy
- [ ] Request/response validation
- [ ] CORS policies
- [ ] API Management policies
```

---

## Scale Planning Methodology

### Horizontal vs Vertical Scaling Decision Matrix

| Scenario | Recommendation | Azure Service |
|----------|---------------|---------------|
| Stateless web apps | Horizontal | App Service with scale-out |
| Read-heavy database | Horizontal (replicas) | Cosmos DB, SQL read replicas |
| CPU-intensive tasks | Vertical initially | VM size upgrade |
| Microservices | Horizontal | AKS with HPA |
| Background jobs | Horizontal | Azure Functions consumption |

### Scaling Triggers and Thresholds

**CPU-based scaling:**
```yaml
Scale Out: CPU > 70% for 5 minutes
Scale In:  CPU < 30% for 10 minutes
Min Instances: 2 (HA)
Max Instances: 20 (cost control)
```

**Queue-based scaling:**
```yaml
Scale Out: Message count > 100
Scale In:  Message count < 10
Processing Target: 10 messages per instance
```

**Time-based scaling:**
```yaml
Business Hours (8AM-6PM): 10 instances
Off Hours (6PM-8AM): 2 instances
Weekend: 3 instances
```

### Data Scaling Strategies

**Database Sharding:**
```
User ID-based sharding:
- Shard 1: Users 0-999,999 (East US)
- Shard 2: Users 1M-1.9M (West US)
- Shard 3: Users 2M+ (Europe)

Routing logic in application layer
Use Cosmos DB partitioning for automatic sharding
```

**Caching Layers:**
```
L1: Browser cache (static assets) - 24 hours
L2: CDN cache (images, videos) - 7 days
L3: Redis cache (API responses) - 1 hour
L4: Database query cache - 5 minutes
```

**Read Replicas:**
```
Primary (Write): East US 2
Replica 1 (Read): West US 2
Replica 2 (Read): North Europe

Application routing:
- Writes → Primary
- User reads → Nearest replica
- Reports/Analytics → Dedicated replica
```

---

## Cost Estimation Approaches

### Azure Cost Estimation Template

**Compute Costs:**
```
App Service (P2v3):
- 4 instances × $0.40/hour = $1.60/hour
- 730 hours/month = $1,168/month

Azure Functions (Consumption):
- 100M executions × $0.20/1M = $20
- Execution time cost ≈ $15
- Total: $35/month

AKS Cluster:
- 3 nodes × D4s_v3 ($0.192/hour) = $420/month
- Load Balancer: $20/month
- Total: $440/month
```

**Storage Costs:**
```
Blob Storage (Hot tier):
- 1 TB × $0.018/GB = $18/month
- 1M write operations × $0.05/10K = $5
- 10M read operations × $0.004/10K = $4
- Total: $27/month

Azure SQL Database (General Purpose):
- 8 vCore × $0.539/hour = $3,156/month
- Storage: 500 GB × $0.115/GB = $57.50/month
- Total: $3,213.50/month
```

**Data Transfer Costs:**
```
Outbound Data Transfer:
- First 100 GB: Free
- Next 10 TB: $0.087/GB = $870 (for 10 TB)

CDN (Standard):
- 10 TB × $0.081/GB = $829/month
```

### Cost Optimization Strategies

**Immediate Wins:**
```markdown
1. Reserved Instances (1-3 year commitment)
   - Save 40-60% on VMs and SQL
   - Example: $3,156/month → $1,578/month

2. Azure Hybrid Benefit
   - Use existing Windows licenses
   - Save up to 40% on Windows VMs

3. Auto-shutdown for non-prod
   - Dev/Test: Shutdown nights/weekends
   - Save 70% on non-prod environments

4. Right-sizing
   - Monitor actual CPU/memory usage
   - Downsize over-provisioned resources
   - Typical saving: 20-30%
```

**Architecture-level optimizations:**
```markdown
1. Serverless for sporadic workloads
   - Functions instead of always-on App Service
   - Container Apps for microservices

2. Managed services over IaaS
   - Azure SQL vs SQL on VMs (no OS patching cost)
   - App Service vs VMs (PaaS management)

3. Cool/Archive tiers for old data
   - Move data older than 90 days to Cool tier
   - Move data older than 1 year to Archive
   - Save 50-90% on storage

4. Compression and deduplication
   - Enable blob compression
   - Use Azure NetApp Files deduplication
```

---

## Failure Handling Strategies

### Failure Modes and Responses

**Single Instance Failure:**
```
Problem: One web server crashes
Solution:
- Load balancer health checks (15-second interval)
- Automatic removal from pool
- Traffic redistributed to healthy instances
- Auto-scaling triggers new instance

Azure Implementation:
- App Service: Automatic instance replacement
- AKS: Kubernetes pod restart and replica management
- VM Scale Sets: Health extension + auto-repair
```

**Database Failure:**
```
Problem: Primary database unavailable
Solution:
- Automated failover to secondary (Azure SQL)
- Connection string retry logic
- Circuit breaker pattern in application

Azure Implementation:
- Azure SQL: Auto-failover groups (30s RTO)
- Cosmos DB: Multi-region writes
- PostgreSQL: Read replicas with manual promotion

Application Pattern:
try {
    await _dbContext.SaveChangesAsync();
} catch (SqlException ex) when (ex.IsTransient) {
    // Retry with exponential backoff
    await Task.Delay(RetryDelay);
    await _dbContext.SaveChangesAsync();
}
```

**Region Failure:**
```
Problem: Entire Azure region down
Solution:
- Multi-region active-active or active-passive
- Azure Front Door for traffic routing
- Cross-region replication

Azure Implementation:
Active-Passive:
- Primary: East US 2 (serves all traffic)
- Secondary: West US 2 (warm standby)
- Azure Site Recovery for failover
- RTO: 15-30 minutes

Active-Active:
- Both regions serve traffic
- Azure Front Door routes to nearest healthy region
- Cosmos DB multi-region writes
- RTO: Seconds (automatic routing)
```

### Resilience Patterns

**Circuit Breaker:**
```csharp
public class CircuitBreakerService
{
    private int _failureCount = 0;
    private DateTime _lastFailureTime;
    private const int FailureThreshold = 5;
    private const int TimeoutSeconds = 60;

    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
    {
        if (_failureCount >= FailureThreshold)
        {
            if ((DateTime.UtcNow - _lastFailureTime).TotalSeconds < TimeoutSeconds)
            {
                throw new CircuitBreakerOpenException();
            }
            _failureCount = 0; // Try again
        }

        try
        {
            var result = await operation();
            _failureCount = 0; // Success - reset
            return result;
        }
        catch (Exception)
        {
            _failureCount++;
            _lastFailureTime = DateTime.UtcNow;
            throw;
        }
    }
}
```

**Retry with Exponential Backoff:**
```csharp
public async Task<HttpResponseMessage> CallExternalApiAsync(string url)
{
    int maxRetries = 3;
    int delayMs = 1000;

    for (int i = 0; i < maxRetries; i++)
    {
        try
        {
            return await _httpClient.GetAsync(url);
        }
        catch (HttpRequestException) when (i < maxRetries - 1)
        {
            await Task.Delay(delayMs * (int)Math.Pow(2, i)); // 1s, 2s, 4s
        }
    }
    throw new Exception("Max retries exceeded");
}
```

**Bulkhead Isolation:**
```csharp
// Separate thread pools for different operations
private readonly SemaphoreSlim _databaseSemaphore = new(10); // Max 10 concurrent DB calls
private readonly SemaphoreSlim _externalApiSemaphore = new(5); // Max 5 concurrent API calls

public async Task<Data> GetFromDatabaseAsync()
{
    await _databaseSemaphore.WaitAsync();
    try
    {
        return await _database.QueryAsync();
    }
    finally
    {
        _databaseSemaphore.Release();
    }
}
```

**Graceful Degradation:**
```csharp
public async Task<ProductRecommendations> GetRecommendationsAsync(int userId)
{
    try
    {
        // Try ML-powered recommendations
        return await _mlService.GetPersonalizedRecommendationsAsync(userId);
    }
    catch (Exception ex)
    {
        _logger.LogWarning(ex, "ML service unavailable, using fallback");
        // Fallback to simple popularity-based recommendations
        return await _cache.GetPopularProductsAsync();
    }
}
```

---

## Example 1: Design a Complete E-Commerce System

### Problem Statement
Design a scalable e-commerce platform (similar to Amazon) that handles:
- 10 million registered users, 1 million DAU
- 500,000 products
- 50,000 orders per day
- Peak traffic: 10,000 requests/second during sales
- 99.95% availability SLA
- Global presence (US, EU, Asia)

### Requirements Gathering (Interviewer Dialog)

**You:** "Let me clarify the functional requirements. What are the core features we need to support?"

**Interviewer:** "Product catalog, search, shopping cart, checkout, order tracking, and payment processing."

**You:** "For search, what's the expected response time and do we need features like filters, sorting, autocomplete?"

**Interviewer:** "Yes to all. Response time should be under 500ms."

**You:** "Payment processing - are we processing payments ourselves or using third-party providers?"

**Interviewer:** "Third-party like Stripe, but we need to handle payment state management."

**You:** "What about inventory management? Real-time stock updates?"

**Interviewer:** "Yes, we need to prevent overselling. Stock should be reserved during checkout."

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer                             │
│  [Web Browsers]  [iOS App]  [Android App]  [Partner APIs]   │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   Edge & CDN Layer                           │
│    [Azure Front Door + WAF]  →  [Azure CDN]                 │
│         (DDoS Protection, SSL Termination)                   │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 API Gateway Layer                            │
│              [Azure API Management]                          │
│   (Rate Limiting, Auth, Caching, Monitoring)                │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│               Microservices Layer (AKS)                      │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Product  │  │  Search  │  │   Cart   │  │  Order   │   │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
│  ┌────┴─────┐  ┌───┴──────┐  ┌───┴──────┐ ┌───┴──────┐   │
│  │Inventory │  │ Payment  │  │Shipping  │ │  User    │   │
│  │ Service  │  │ Service  │  │ Service  │ │ Service  │   │
│  └──────────┘  └──────────┘  └──────────┘ └──────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   Data Layer                                 │
│                                                              │
│  ((Redis Cache))   {Service Bus}   [Blob Storage]          │
│                                                              │
│  |Cosmos DB|    |Azure SQL|    [Azure Cognitive Search]    │
│  (Catalog)      (Orders)        (Product Search)            │
└─────────────────────────────────────────────────────────────┘
```

### Component Deep Dive

**Product Service:**
```
Responsibilities:
- Product CRUD operations
- Category management
- Product recommendations

Technology:
- .NET 8 minimal APIs
- Cosmos DB (catalog data) - partitioned by category
- Redis Cache (hot products, 1-hour TTL)
- Azure Blob Storage (product images)

Scaling:
- 10 pod replicas (AKS)
- Horizontal Pod Autoscaler (CPU > 70%)
- Read from Cosmos DB replicas

API Example:
GET /api/products/{id}
  → Check Redis cache
  → If miss, query Cosmos DB
  → Cache result
  → Return with CDN URLs for images
```

**Search Service:**
```
Responsibilities:
- Full-text product search
- Filters, facets, sorting
- Autocomplete suggestions

Technology:
- Azure Cognitive Search
- Change feed from Cosmos DB for indexing
- Redis for autocomplete cache

Scaling:
- Search service: S2 tier (36 replicas)
- Index partitioning by region
- CDN caching of common searches

Search Flow:
User types "nike shoes"
  → API Management (check cache)
  → Search Service queries Azure Cognitive Search
  → Apply filters (price, size, color)
  → Return ranked results (50ms latency)
```

**Cart Service:**
```
Responsibilities:
- Add/remove items
- Cart persistence
- Price calculation

Technology:
- Redis for active carts (2-hour TTL)
- Azure SQL for persistent carts
- Event-driven updates via Service Bus

Scaling Challenge:
- Peak load: 5,000 cart updates/second
- Redis cluster: 5 shards
- Optimistic locking for concurrent updates

Cart Reservation:
When user proceeds to checkout:
  1. Lock cart items
  2. Reserve inventory (Inventory Service)
  3. Create pending order
  4. Start 10-minute checkout timer
  5. Release reservation if timeout
```

**Order Service:**
```
Responsibilities:
- Order creation
- Order state management
- Order history

Technology:
- Azure SQL (ACID transactions)
- Service Bus for order events
- Cosmos DB for order history (read-heavy)

State Machine:
Pending → PaymentProcessing → Confirmed → Shipped → Delivered
                ↓
             Cancelled

Transaction Management:
BEGIN TRANSACTION
  - Create order record
  - Decrement inventory
  - Create payment intent (Stripe)
  - Publish OrderCreated event
COMMIT
```

**Payment Service:**
```
Responsibilities:
- Payment processing (Stripe integration)
- Payment retry logic
- Refund handling

Idempotency:
- Store payment intent ID
- Prevent duplicate charges
- Retry with same idempotency key

Circuit Breaker:
- If Stripe fails 5 times, open circuit
- Queue payments for later processing
- Notify customer of delay
```

### Security Implementation

```markdown
1. Authentication:
   - Azure AD B2C for customers
   - JWT tokens (1-hour expiry)
   - Refresh token rotation

2. API Security:
   - API Management: OAuth 2.0 validation
   - Rate limiting: 1000 req/min per user
   - IP whitelisting for partner APIs

3. Data Security:
   - PCI-DSS compliance (no card storage)
   - Stripe tokenization
   - Encrypted PII (email, phone)
   - TDE on Azure SQL

4. Network Security:
   - Private endpoints for all PaaS
   - NSGs blocking internet access to data tier
   - WAF rules (OWASP top 10)
```

### Scaling Strategy

**Traffic Distribution:**
```
Region 1 (US East): 50% traffic
  - AKS: 20 nodes (D4s_v3)
  - Azure SQL: General Purpose 16 vCore
  - Redis: Premium P4 cluster

Region 2 (West Europe): 30% traffic
  - AKS: 12 nodes
  - Azure SQL: Read replica
  - Redis: Premium P3 cluster

Region 3 (Southeast Asia): 20% traffic
  - AKS: 8 nodes
  - Azure SQL: Read replica
  - Redis: Premium P3 cluster
```

**Database Scaling:**
```
Write Operations: Primary (US East)
Read Operations:
  - 70% from read replicas (distributed)
  - 30% from primary (stale reads acceptable)

Sharding Strategy (if needed):
- Orders: Partition by user_id (hash)
- Products: Partition by category
```

### Cost Estimation

```
Compute (AKS): 40 nodes × $140/month = $5,600/month
Azure SQL: 16 vCore GP + 2 replicas = $4,800/month
Cosmos DB: 50,000 RU/s = $2,920/month
Redis Cache: 3 × P4 instances = $3,000/month
Azure Search: S2 tier = $2,000/month
Blob Storage: 10 TB = $180/month
Front Door + CDN: 20 TB egress = $1,600/month
API Management: Premium tier = $2,800/month

Total: ~$23,000/month
With reserved instances (3-year): ~$15,000/month (35% savings)
```

### Failure Scenarios

**Database Failure:**
```
Scenario: Primary SQL database fails
Response:
1. Auto-failover group promotes secondary (30s)
2. Connection strings automatically updated
3. Brief unavailability during failover
4. Application retry logic handles transition

Impact: <1 minute downtime
```

**Payment Service Failure:**
```
Scenario: Stripe API is down
Response:
1. Circuit breaker opens
2. Orders queued in Service Bus
3. Display "Payment processing delayed" message
4. Process queue when Stripe recovers

Impact: No lost orders, delayed confirmation
```

**Search Service Failure:**
```
Scenario: Azure Cognitive Search unavailable
Response:
1. Fallback to basic Cosmos DB query
2. Limited filtering capabilities
3. Cache previous search results

Impact: Degraded search experience, no downtime
```

---

## Example 2: Design a Real-Time Notification System

### Problem Statement
Design a system to send real-time notifications to users across:
- Push notifications (mobile)
- Email
- SMS
- In-app notifications
- Web push

Requirements:
- 50 million users
- 500 million notifications/day
- Sub-second delivery for critical notifications
- Delivery tracking and analytics
- User preference management
- Template management

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Notification Sources                       │
│  [Order Service] [Payment Service] [Promotions] [Admin]     │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Notification Gateway (API)                      │
│         [Azure API Management + App Service]                │
│                                                              │
│  POST /api/notifications/send                               │
│  {                                                           │
│    "userId": "12345",                                       │
│    "template": "order_confirmed",                           │
│    "channels": ["push", "email"],                           │
│    "priority": "high",                                      │
│    "data": {...}                                            │
│  }                                                           │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Processing Layer                                │
│                                                              │
│  [Service Bus Topic] → [Subscription per Channel]           │
│                                                              │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│   │  Push    │  │  Email   │  │   SMS    │  │  In-App  │  │
│   │ Processor│  │Processor │  │Processor │  │Processor │  │
│   │(Functions)│  │(Functions)│  │(Functions)│  │(Functions)│  │
│   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
└────────┼────────────────┼──────────────┼──────────────┼─────┘
         ▼                ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│               Delivery Providers                             │
│  [Azure Notification  [SendGrid]  [Twilio]   [SignalR]      │
│       Hubs]                                                  │
└─────────────────────────────────────────────────────────────┘
         │                │              │              │
         ▼                ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Data Layer                                 │
│                                                              │
│  [Cosmos DB]         [Application Insights]                 │
│  - User preferences  - Delivery analytics                   │
│  - Notification log  - Failure tracking                     │
│  - Templates                                                 │
└─────────────────────────────────────────────────────────────┘
```

### Component Details

**Notification Gateway:**
```csharp
[HttpPost("send")]
public async Task<IActionResult> SendNotification([FromBody] NotificationRequest request)
{
    // 1. Validate request
    if (!ModelState.IsValid)
        return BadRequest();

    // 2. Load user preferences
    var preferences = await _cosmos.GetUserPreferencesAsync(request.UserId);

    // 3. Filter channels based on preferences
    var allowedChannels = request.Channels
        .Where(c => preferences.EnabledChannels.Contains(c))
        .ToList();

    // 4. Load template
    var template = await _cosmos.GetTemplateAsync(request.Template);

    // 5. Enqueue to Service Bus
    var message = new ServiceBusMessage
    {
        Body = JsonSerializer.SerializeToUtf8Bytes(new
        {
            request.UserId,
            Template = template,
            Channels = allowedChannels,
            Data = request.Data,
            Priority = request.Priority
        }),
        MessageId = Guid.NewGuid().ToString(),
        SessionId = request.Priority == "high" ? "priority" : "standard"
    };

    await _serviceBus.SendAsync(message);

    return Accepted(new { MessageId = message.MessageId });
}
```

**Push Notification Processor (Azure Function):**
```csharp
[FunctionName("PushProcessor")]
public async Task ProcessPush(
    [ServiceBusTrigger("notifications", "push", Connection = "ServiceBus")]
    ServiceBusReceivedMessage message,
    ILogger log)
{
    var notification = JsonSerializer.Deserialize<NotificationMessage>(message.Body);

    try
    {
        // Get device tokens
        var devices = await _cosmos.GetUserDevicesAsync(notification.UserId);

        // Prepare push payload
        var pushPayload = new ApplePushNotification
        {
            Alert = notification.Template.Title,
            Body = RenderTemplate(notification.Template.Body, notification.Data),
            Badge = 1,
            Sound = "default",
            CustomData = notification.Data
        };

        // Send via Azure Notification Hubs
        await _notificationHub.SendAppleNativeNotificationAsync(
            JsonSerializer.Serialize(pushPayload),
            devices.Select(d => d.Token).ToList()
        );

        // Log delivery
        await LogDeliveryAsync(notification, "push", "delivered");
    }
    catch (Exception ex)
    {
        log.LogError(ex, "Push notification failed");

        // Retry logic (Service Bus handles this automatically)
        throw; // Will retry based on Service Bus policy
    }
}
```

**Email Processor with Rate Limiting:**
```csharp
[FunctionName("EmailProcessor")]
public async Task ProcessEmail(
    [ServiceBusTrigger("notifications", "email", Connection = "ServiceBus")]
    ServiceBusReceivedMessage message,
    ILogger log)
{
    var notification = JsonSerializer.Deserialize<NotificationMessage>(message.Body);

    // Rate limiting check (SendGrid: 100 emails/second)
    await _rateLimiter.WaitAsync();

    try
    {
        var user = await _cosmos.GetUserAsync(notification.UserId);

        var emailMessage = new SendGridMessage
        {
            From = new EmailAddress("noreply@company.com"),
            Subject = notification.Template.Subject,
            PlainTextContent = RenderTemplate(notification.Template.TextBody, notification.Data),
            HtmlContent = RenderTemplate(notification.Template.HtmlBody, notification.Data)
        };
        emailMessage.AddTo(user.Email);

        // Tracking
        emailMessage.SetClickTracking(true, true);
        emailMessage.SetOpenTracking(true);

        var response = await _sendGrid.SendEmailAsync(emailMessage);

        await LogDeliveryAsync(notification, "email",
            response.IsSuccessStatusCode ? "sent" : "failed");
    }
    finally
    {
        _rateLimiter.Release();
    }
}
```

### Scaling Strategy

**Service Bus Configuration:**
```
Topic: notifications
  - Partitioning: Enabled (16 partitions)
  - Message TTL: 24 hours
  - Max delivery count: 3
  - Dead letter on expiration: Yes

Subscriptions:
  1. push-subscription
     - Filter: channel = 'push'
     - Max concurrent calls: 100

  2. email-subscription
     - Filter: channel = 'email'
     - Max concurrent calls: 50

  3. sms-subscription
     - Filter: channel = 'sms'
     - Max concurrent calls: 20

Scaling:
- Premium tier: 16 messaging units
- Throughput: ~160,000 messages/second
```

**Function App Scaling:**
```yaml
Push Processor:
  Plan: Premium EP2 (7 GB RAM)
  Max instances: 50
  Trigger: 32 messages per execution
  Expected throughput: 1,600 notifications/second

Email Processor:
  Plan: Premium EP1
  Max instances: 30
  Rate limit: 100 emails/second
  Batch processing: 10 emails per execution
```

**Database Design (Cosmos DB):**
```javascript
// Container: UserPreferences
{
  "id": "user_12345",
  "userId": "12345",
  "enabledChannels": ["push", "email"],
  "quietHours": {
    "start": "22:00",
    "end": "08:00",
    "timezone": "America/New_York"
  },
  "frequency": {
    "marketing": "weekly",
    "transactional": "always"
  }
}

// Container: NotificationLog (Partitioned by date)
{
  "id": "notif_123",
  "userId": "12345",
  "channel": "push",
  "template": "order_confirmed",
  "status": "delivered",
  "timestamp": "2026-01-19T10:30:00Z",
  "deliveryTime": 1.2, // seconds
  "partitionKey": "2026-01-19"
}

// Partition strategy
Partition Key: /partitionKey (date)
Throughput: 10,000 RU/s (autoscale)
TTL: 90 days (automatic cleanup)
```

### Reliability and Failure Handling

**Dead Letter Queue Processing:**
```csharp
[FunctionName("DeadLetterProcessor")]
public async Task ProcessDeadLetters(
    [ServiceBusTrigger("notifications/$DeadLetterQueue", Connection = "ServiceBus")]
    ServiceBusReceivedMessage message,
    ILogger log)
{
    var notification = JsonSerializer.Deserialize<NotificationMessage>(message.Body);

    // Log failure
    await _applicationInsights.TrackEventAsync("NotificationFailed", new Dictionary<string, string>
    {
        ["UserId"] = notification.UserId,
        ["Template"] = notification.Template.Id,
        ["Reason"] = message.DeadLetterReason,
        ["ErrorDescription"] = message.DeadLetterErrorDescription
    });

    // Alert on-call engineer if critical
    if (notification.Priority == "high")
    {
        await _pagerDuty.TriggerIncidentAsync(
            $"Critical notification failed: {notification.Template.Id}");
    }

    // Store for manual retry
    await _cosmos.CreateAsync("failed-notifications", notification);
}
```

**Circuit Breaker for External Services:**
```csharp
public class TwilioService
{
    private readonly ICircuitBreakerPolicy _circuitBreaker;

    public TwilioService()
    {
        _circuitBreaker = Policy
            .Handle<TwilioException>()
            .CircuitBreakerAsync(
                exceptionsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromMinutes(1),
                onBreak: (ex, duration) => {
                    // Log and alert
                    _logger.LogError("Twilio circuit breaker opened");
                },
                onReset: () => {
                    _logger.LogInformation("Twilio circuit breaker reset");
                }
            );
    }

    public async Task<bool> SendSmsAsync(string to, string body)
    {
        return await _circuitBreaker.ExecuteAsync(async () =>
        {
            await _twilioClient.SendMessageAsync(to, body);
            return true;
        });
    }
}
```

### Cost Estimation

```
Service Bus (Premium, 16 MU): $11,200/month
Azure Functions (Premium EP2): 50 instances = $5,000/month
Cosmos DB (10K RU/s): $584/month
Azure Notification Hubs (Enterprise): $2,000/month
SendGrid (500M emails): $3,000/month
Twilio SMS (1M messages): $10,000/month
Application Insights: $500/month

Total: ~$32,300/month

Optimization opportunities:
- Use consumption plan for non-critical channels: Save $3,000
- Negotiate Twilio/SendGrid volume discounts: Save $4,000
- Reduce Cosmos DB TTL from 90 to 30 days: Save $200
```

---

## Architect-Level Confidence Building Tips

### Before the Interview

**1. Practice Drawing on Whiteboards:**
```
Exercise:
- Set 15-minute timer
- Pick a system (Netflix, Uber, Twitter)
- Draw complete architecture
- Explain out loud as if interviewer is present

Do this 5 times before interview day
```

**2. Memorize Your Azure Service Portfolio:**
```
Compute:       App Service, Functions, AKS, Container Apps
Storage:       Blob, SQL, Cosmos DB, Table Storage
Networking:    Front Door, API Management, Load Balancer, VPN Gateway
Messaging:     Service Bus, Event Grid, Event Hubs
Cache:         Redis Cache, CDN
AI/Search:     Cognitive Search, OpenAI Service
Security:      Key Vault, AD B2C, Managed Identity
Monitoring:    Application Insights, Log Analytics, Azure Monitor
```

**3. Build a Mental Model Library:**
```
Pattern 1: API-first microservices
Pattern 2: Event-driven architecture
Pattern 3: CQRS with event sourcing
Pattern 4: Strangler fig (legacy migration)
Pattern 5: Multi-region active-active
Pattern 6: Cache-aside pattern
Pattern 7: Saga pattern (distributed transactions)
```

### During the Interview

**1. Start Strong:**
```
First 30 seconds matter:
- Thank the interviewer
- Restate the problem
- Ask if you understood correctly
- Project confidence (even if nervous)

"Thank you for the problem. So you're asking me to design
a scalable notification system that can handle 500 million
notifications per day across multiple channels. Before I
start, let me clarify a few requirements..."
```

**2. Think Out Loud:**
```
Bad: *draws in silence for 5 minutes*

Good: "I'm starting with the client layer here at the top.
Users will access this through web and mobile apps, so I'll
add Azure Front Door for global load balancing and DDoS
protection. Now, for the API layer, I'm thinking API
Management would give us rate limiting and authentication..."
```

**3. Show Trade-off Analysis:**
```
Example:
"For the database, I'm considering two options:

Option 1: Azure SQL with read replicas
  Pros: ACID transactions, familiar SQL
  Cons: Vertical scaling limits, schema rigidity

Option 2: Cosmos DB
  Pros: Horizontal scaling, multi-region writes
  Cons: Higher cost, eventual consistency

Given the requirement for global distribution and the
read-heavy workload, I'd recommend Cosmos DB with strong
consistency for writes and eventual for reads."
```

**4. Proactively Address Non-Functionals:**
```
Don't wait for interviewer to ask about:
- Security: "For security, I'd implement..."
- Monitoring: "To monitor this system, I'd use..."
- Cost: "This architecture would cost approximately..."
- Scaling: "To handle 10x growth..."
```

**5. Recover from Mistakes:**
```
If you realize an error:

Bad: *tries to hide it*

Good: "Actually, I want to revise my approach to the caching
layer. I initially suggested caching at the application level,
but given the distributed nature of the system, a Redis cluster
would provide better consistency."

Interviewers respect candidates who self-correct.
```

### Handling Tough Questions

**"How would this handle 100x traffic?"**
```
Framework:
1. Identify bottlenecks: "The first bottleneck would be..."
2. Scaling strategy: "I'd implement horizontal scaling for..."
3. Data tier: "Database would need sharding/partitioning..."
4. Cost awareness: "This would increase costs by approximately..."
5. Alternative: "Alternatively, we could use serverless to..."
```

**"What if the database goes down?"**
```
Framework:
1. Prevention: "To prevent this, I'd implement..."
2. Detection: "We'd detect this through health checks..."
3. Recovery: "Automatic failover would trigger..."
4. Impact: "Users would experience..."
5. Mitigation: "To minimize impact, I'd add..."
```

**"This seems over-engineered. Can you simplify?"**
```
Response:
"Great point. Let me identify the MVP architecture:
- Start with: App Service + Azure SQL + Redis
- Defer: Multi-region, microservices, event sourcing
- Migration path: When we hit X users, we'd split into..."

Shows you can balance ideal vs. practical.
```

### Body Language and Presence

**1. Use the Whiteboard Confidently:**
```
- Stand to the side (don't block your work)
- Draw large and clear (visible from 10 feet)
- Use different colors for different layers
- Point while explaining
- Erase and redraw if needed (shows flexibility)
```

**2. Engage the Interviewer:**
```
- Make eye contact regularly
- Read their body language (nodding = good, confused look = clarify)
- Ask: "Does this make sense so far?"
- Invite input: "What would you like me to dive deeper into?"
```

**3. Time Management:**
```
Use watch or visible clock:
- 10 min in: "I've covered requirements and high-level design"
- 30 min in: "Let me now detail the critical components"
- 45 min in: "I'll cover monitoring and costs"
- 55 min in: "Let me summarize and open for questions"
```

### Post-Design Checklist

Before you say "I'm done," verify you covered:
```
[ ] Functional requirements met
[ ] Scale numbers addressed
[ ] Security mentioned (auth, encryption, network)
[ ] Monitoring and observability
[ ] Failure scenarios and recovery
[ ] Cost estimation provided
[ ] Trade-offs explained
[ ] At least one alternative approach mentioned
```

---

## Final Mental Prep

### The Night Before
- Review 2-3 system design examples (just high-level, don't cram)
- Get 8 hours of sleep
- Prepare your questions for the interviewer
- Lay out professional attire
- Test video/audio if remote interview

### The Morning Of
- Eat a good breakfast
- Arrive 15 minutes early (or login early for remote)
- Do a 5-minute breathing exercise
- Review your "mental model library" (just the names)
- Tell yourself: "I've prepared thoroughly. I can do this."

### During the Interview
- You're not expected to know everything
- Asking questions is a strength, not a weakness
- It's okay to take 30 seconds to think before answering
- Focus on demonstrating your thought process
- Remember: They're assessing how you'd work with them

### Remember
**You're not designing the perfect system. You're demonstrating:**
1. Structured thinking
2. Communication skills
3. Technical knowledge
4. Trade-off analysis
5. Ability to collaborate

Good luck! You've got this.
