# Day 19: Mock System Design - Azure Edition

## System Design Interview Structure

### Typical Format (45-60 minutes)

**Architect-Level Expectations:**
- Show breadth AND depth - know when to go deep
- Articulate trade-offs explicitly (not just list options)
- Consider operational aspects (monitoring, deployment, cost)
- Azure-specific: Leverage managed services appropriately

**1. Problem Statement (5 minutes)**
- Interviewer presents a high-level problem
- Usually ambiguous and open-ended
- Examples: "Design Twitter", "Design a URL shortener"

**2. Requirements Gathering (10-15 minutes)**
- Ask clarifying questions
- Define functional requirements
- Define non-functional requirements
- Establish scope and constraints

**3. High-Level Design (10-15 minutes)**
- Draw architecture diagram
- Identify main components
- Explain data flow
- Discuss APIs

**4. Deep Dive (15-20 minutes)**
- Drill into specific components
- Discuss trade-offs
- Address scalability
- Consider edge cases

**5. Wrap-up (5 minutes)**
- Summarize design
- Discuss potential improvements
- Answer follow-up questions

---

## How to Approach Ambiguous Requirements

### The RAISED Framework

**R - Requirements Clarification**

Ask about:
- **Users:** How many users? Daily active users? Concurrent users?
- **Scale:** Read vs Write ratio? Data volume? Growth rate?
- **Features:** Core features vs nice-to-have?
- **Constraints:** Budget? Timeline? Team size?

**Example Questions:**
```
"How many users are we expecting?"
"What's the read-to-write ratio?"
"Do we need real-time updates or is eventual consistency okay?"
"What's our budget constraint?"
"Should we optimize for latency or throughput?"
"What's the expected data retention period?"
```

**A - Assumptions Document**

State your assumptions clearly:
```
"I'm going to assume:
- 10 million daily active users
- 100:1 read-to-write ratio
- Average response time < 200ms
- 99.9% availability requirement
- Global user base (multi-region)
- Budget: ~$50K/month on Azure
Is this reasonable?"
```

**I - Identify Core Features**

Prioritize features:
```
Must Have (MVP):
- User authentication
- Create short URL
- Redirect to original URL

Nice to Have:
- Custom aliases
- Analytics
- Expiration

Out of Scope (for this interview):
- Mobile apps
- Advanced analytics
- A/B testing
```

**S - Scope Definition**

Be explicit about what you're designing:
```
"For this interview, I'll focus on:
1. Backend API design
2. Database schema
3. Caching strategy
4. Scalability approach

I'll mention but not detail:
- Authentication mechanism
- Monitoring setup
- CI/CD pipeline"
```

**E - Estimation Calculations**

Do back-of-envelope calculations:
```
Storage Calculation:
- 100M URLs created per month
- Average URL size: 500 bytes
- Metadata: 500 bytes
- Total per URL: 1KB
- Monthly storage: 100M * 1KB = 100GB
- Yearly: 1.2TB
- 5-year retention: 6TB

Bandwidth:
- 100M writes/month = 40 writes/second (average)
- 10B reads/month (100:1 ratio) = 4000 reads/second
- Read bandwidth: 4000 * 1KB = 4MB/s
```

**D - Design Start**

Now begin your design with confidence.

---

## Azure-Specific Design Patterns

### 1. API Gateway Pattern

**Use Azure API Management**

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│  Azure API Management   │  Rate limiting, authentication,
│                         │  caching, transformation
└──────────┬──────────────┘
           │
           ├──────────────┐
           ▼              ▼
    ┌──────────┐    ┌──────────┐
    │Service A │    │Service B │
    └──────────┘    └──────────┘
```

**Benefits:**
- Centralized authentication
- Rate limiting
- Request/response transformation
- Analytics and monitoring
- Cache frequently accessed data

**When to use:**
- Microservices architecture
- Public APIs
- Need for API versioning
- Multiple backend services

### 2. Event-Driven Architecture Pattern

**Use Azure Event Grid + Azure Functions**

```
┌──────────┐        ┌─────────────────┐
│  Source  │───────▶│ Azure Event Grid│
└──────────┘        └────────┬────────┘
                             │
                    ┌────────┼────────┐
                    ▼        ▼        ▼
              ┌─────────┬─────────┬─────────┐
              │Function │Function │Function │
              │   A     │   B     │   C     │
              └─────────┴─────────┴─────────┘
```

**Use cases:**
- Order processing
- Notification systems
- Data pipeline
- Serverless workflows

### 3. Queue-Based Load Leveling Pattern

**Use Azure Service Bus / Storage Queue**

```
┌─────────┐        ┌───────────┐        ┌──────────────┐
│ Client  │───────▶│   Queue   │───────▶│   Worker     │
└─────────┘        │           │        │  (Scale 1-N) │
                   └───────────┘        └──────────────┘
```

**Benefits:**
- Decouples producers and consumers
- Handles traffic spikes
- Enables async processing
- Guarantees message delivery

### 4. Cache-Aside Pattern

**Use Azure Redis Cache**

```
Application requests data:
1. Check cache (Azure Redis)
2. If miss, query database (Azure SQL)
3. Store result in cache
4. Return to client

┌─────────────┐
│ Application │
└─────┬───────┘
      │
      ├──────1. Check──────▶┌─────────────┐
      │                     │ Redis Cache │
      │◀─────2. Miss────────└─────────────┘
      │
      ├──────3. Query───────▶┌──────────┐
      │                      │Azure SQL │
      │◀─────4. Return───────└──────────┘
      │
      └──────5. Cache────────▶┌─────────────┐
                              │ Redis Cache │
                              └─────────────┘
```

### 5. CQRS (Command Query Responsibility Segregation)

**Separate read and write models**

```
┌────────────┐
│   Client   │
└─────┬──────┘
      │
      ├─────Commands─────▶┌──────────────┐
      │                   │ Write Model  │
      │                   │ (Azure SQL)  │
      │                   └──────┬───────┘
      │                          │
      │                          ▼
      │                   ┌──────────────┐
      │                   │  Event Bus   │
      │                   └──────┬───────┘
      │                          │
      │                          ▼
      │                   ┌──────────────┐
      └─────Queries──────▶│  Read Model  │
                          │(Cosmos DB/   │
                          │ Cache)       │
                          └──────────────┘
```

**When to use:**
- Different read/write patterns
- High read-to-write ratio
- Complex queries on read side
- Need for different data models

### 6. Retry Pattern

**Use Polly with Azure Services**

```csharp
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .WaitAndRetryAsync(3, retryAttempt =>
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));

await retryPolicy.ExecuteAsync(async () =>
{
    return await httpClient.GetAsync(url);
});
```

### 7. Circuit Breaker Pattern

**Prevent cascading failures**

```csharp
var circuitBreakerPolicy = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(
        exceptionsAllowedBeforeBreaking: 3,
        durationOfBreak: TimeSpan.FromMinutes(1)
    );
```

**States:**
- Closed: Normal operation
- Open: Failures detected, requests fail fast
- Half-Open: Testing if service recovered

### 8. Bulkhead Pattern

**Use Azure Function Consumption Plan with Separate Apps**

Isolate resources to prevent total failure:
- Separate Function Apps for critical vs non-critical
- Different App Service Plans
- Separate database connection pools

---

## Drawing Architecture Diagrams

### Key Components to Include

**1. Client Layer**
```
┌─────────────┐  ┌─────────────┐
│ Web Client  │  │Mobile Client│
└─────────────┘  └─────────────┘
```

**2. Gateway/Load Balancer**
```
┌───────────────────────────┐
│ Azure Front Door / APIM   │
└───────────────────────────┘
```

**3. Application Layer**
```
┌──────────────┐  ┌──────────────┐
│  App Service │  │   Functions  │
│  (REST API)  │  │ (Background) │
└──────────────┘  └──────────────┘
```

**4. Caching Layer**
```
┌───────────────┐
│  Redis Cache  │
└───────────────┘
```

**5. Database Layer**
```
┌──────────────┐  ┌──────────────┐
│  Azure SQL   │  │  Cosmos DB   │
└──────────────┘  └──────────────┘
```

**6. Storage Layer**
```
┌──────────────┐
│ Blob Storage │
└──────────────┘
```

**7. Messaging Layer**
```
┌──────────────┐  ┌──────────────┐
│ Service Bus  │  │  Event Grid  │
└──────────────┘  └──────────────┘
```

**8. Monitoring**
```
┌──────────────────────────┐
│ Application Insights     │
│ Log Analytics            │
└──────────────────────────┘
```

### Diagram Best Practices

1. **Use Standard Shapes**
   - Rectangles for services
   - Cylinders for databases
   - Clouds for external services
   - Arrows for data flow

2. **Label Everything**
   - Component names
   - Data flow direction
   - Protocols (HTTP, gRPC, AMQP)

3. **Show Critical Paths**
   - Highlight main user flows
   - Use different colors for read/write paths

4. **Include Numbers**
   - Request/second rates
   - Data volumes
   - Latency requirements

---

## Discussing Trade-offs

### Common Trade-off Categories

**1. Consistency vs Availability (CAP Theorem)**

**Strong Consistency:**
- Pros: Data always up-to-date, no conflicts
- Cons: Higher latency, lower availability
- Azure Example: Azure SQL with default isolation

**Eventual Consistency:**
- Pros: High availability, better performance
- Cons: Temporary inconsistencies, conflict resolution
- Azure Example: Cosmos DB with eventual consistency

**When to discuss:**
"For this URL shortener, I'd choose strong consistency for the URL creation (can't have duplicate short URLs), but eventual consistency for analytics data."

**2. SQL vs NoSQL**

**Azure SQL:**
- Pros: ACID transactions, complex queries, relationships
- Cons: Vertical scaling limits, schema changes
- Use for: Financial transactions, inventory

**Cosmos DB:**
- Pros: Horizontal scaling, flexible schema, low latency
- Cons: No joins, eventual consistency (by default), cost
- Use for: User profiles, product catalogs, IoT data

**When to discuss:**
"I'm choosing Cosmos DB because:
1. We need to scale globally (multi-region writes)
2. User profiles have flexible schemas
3. We can tolerate eventual consistency
4. We need single-digit millisecond reads"

**3. Serverless vs App Service**

**Azure Functions (Serverless):**
- Pros: Auto-scale, pay-per-execution, no infrastructure
- Cons: Cold starts, execution time limits, stateless
- Use for: Event processing, scheduled jobs, webhooks

**App Service:**
- Pros: Always warm, long-running, stateful, easier debugging
- Cons: Pay for reserved capacity, manual scaling
- Use for: APIs with consistent traffic, WebSocket connections

**When to discuss:**
"For the main API, I'd use App Service because we have consistent traffic and need low latency. For image processing triggered by uploads, I'd use Functions for cost-efficiency."

**4. Caching Strategy**

**Cache-Aside:**
- Pros: Application controls cache logic
- Cons: Cache miss penalty, potential stale data

**Write-Through:**
- Pros: Cache always up-to-date
- Cons: Write latency, unnecessary caching

**When to discuss:**
"I'm using cache-aside with a 10-minute TTL because:
- Product data doesn't change frequently
- Acceptable to show slightly stale data
- Reduces database load by 90%"

**5. Synchronous vs Asynchronous**

**Synchronous:**
- Pros: Immediate feedback, simpler error handling
- Cons: Blocks caller, doesn't handle spikes well

**Asynchronous (Queue-based):**
- Pros: Handles spikes, decoupled, retry logic
- Cons: Complex error handling, eventual processing

**When to discuss:**
"For order placement, I'd use synchronous for payment validation (need immediate response), but async for order fulfillment (can be processed in background)."

---

## Scaling Strategies Discussion

### Horizontal vs Vertical Scaling

**Vertical Scaling (Scale Up):**
- Larger machine (more CPU/RAM)
- Easier (no code changes)
- Limited by hardware
- Single point of failure
- Azure: Change App Service Plan tier

**Horizontal Scaling (Scale Out):**
- More machines
- Better availability
- Needs stateless design
- Load balancing required
- Azure: Add instances to App Service Plan

**Discuss strategy:**
```
"I'd design for horizontal scaling because:
1. We expect exponential user growth
2. Vertical scaling has limits
3. Better fault tolerance (multiple instances)
4. Azure makes it easy with auto-scale rules"
```

### Database Scaling

**1. Read Replicas**
```
┌─────────────┐
│   Primary   │──────Writes
│  (Master)   │
└──────┬──────┘
       │ Replication
       ├──────────┬──────────┐
       ▼          ▼          ▼
   ┌────────┐ ┌────────┐ ┌────────┐
   │Replica1│ │Replica2│ │Replica3│──Reads
   └────────┘ └────────┘ └────────┘
```

**When to use:**
- High read-to-write ratio (100:1)
- Read latency optimization
- Geographic distribution

**Azure implementation:**
- Azure SQL: Active geo-replication
- Cosmos DB: Multi-region reads

**2. Sharding (Horizontal Partitioning)**
```
Users 1-1M      → Shard 1 (Region: East US)
Users 1M-2M     → Shard 2 (Region: West US)
Users 2M-3M     → Shard 3 (Region: Europe)
```

**Sharding strategies:**
- Range-based: User ID 1-1M, 1M-2M
- Hash-based: Hash(UserID) % num_shards
- Geography-based: User location

**Azure implementation:**
- Cosmos DB: Partition key
- Azure SQL: Elastic Database Tools

**3. CQRS with Separate Read/Write Databases**
```
Write Model (Azure SQL - Optimized for writes)
    ↓
  Events
    ↓
Read Model (Cosmos DB - Optimized for reads)
```

### Application Scaling

**1. Stateless Design**
```csharp
// Bad - stores state in memory
public class BadController : ControllerBase
{
    private static List<User> _users = new List<User>(); // Won't work across instances
}

// Good - stores state in distributed cache/database
public class GoodController : ControllerBase
{
    private readonly IDistributedCache _cache;

    public async Task<User> GetUser(int id)
    {
        return await _cache.GetAsync<User>($"user:{id}");
    }
}
```

**2. Auto-scaling Rules**
```
Azure App Service Auto-scale:
- Scale out when: CPU > 70% for 5 minutes
- Scale in when: CPU < 30% for 10 minutes
- Min instances: 2 (for availability)
- Max instances: 20
```

**3. Content Delivery Network (CDN)**
```
Static Content (images, CSS, JS)
    ↓
Azure CDN (Edge locations worldwide)
    ↓
Users get content from nearest edge location
```

---

## Cost Analysis Discussion

### Cost Optimization Strategies

**1. Right-Sizing Resources**
```
Example: App Service Plan
- P1v2: $146/month (1 core, 3.5GB RAM)
- P2v2: $292/month (2 cores, 7GB RAM)
- P3v2: $584/month (4 cores, 14GB RAM)

Decision: Start with P1v2, monitor CPU/memory, scale up if needed
```

**2. Reserved Instances**
```
Savings:
- Pay-as-you-go: $292/month
- 1-year reserved: $219/month (25% savings)
- 3-year reserved: $146/month (50% savings)

Use for: Production workloads with predictable usage
```

**3. Serverless for Variable Workloads**
```
Azure Functions Consumption Plan:
- First 1M executions free
- $0.20 per million executions after
- $0.000016 per GB-second

vs App Service Plan:
- $146/month minimum (P1v2)

Choose Functions if: < 200 hours/month runtime
```

**4. Storage Tiers**
```
Azure Blob Storage:
- Hot tier: $0.018 per GB/month (frequent access)
- Cool tier: $0.01 per GB/month (infrequent access, 30+ days)
- Archive tier: $0.002 per GB/month (rare access, 180+ days)

Use lifecycle policies to auto-tier
```

**5. Cosmos DB Optimization**
```
Serverless mode:
- Pay per RU consumed
- Good for: Dev/test, sporadic traffic

Provisioned throughput:
- Reserved RUs (400 RU/s minimum)
- Good for: Production, predictable traffic

Autoscale:
- Scale between min/max RUs
- Good for: Variable traffic with known max
```

### Sample Cost Discussion

**Scenario: URL Shortener with 10M monthly active users**

```
Monthly Cost Estimate:

Compute:
- App Service (P2v2): $292
- Azure Functions (background): ~$50
Subtotal: $342

Database:
- Cosmos DB (autoscale 1000-10000 RU/s): ~$400
- Azure SQL (analytics): $100
Subtotal: $500

Cache:
- Redis Cache (C1 Standard): $72

Storage:
- Blob Storage (100GB hot): $2

Networking:
- Azure Front Door: $35
- Outbound bandwidth (1TB): $87

Monitoring:
- Application Insights: ~$50

Total: ~$1,088/month

Optimizations to discuss:
1. Use Functions instead of App Service if traffic is variable (-$200)
2. Use SQL instead of Cosmos DB if global distribution not needed (-$300)
3. Implement aggressive caching to reduce database costs (-20%)
```

**What interviewers want to hear:**
- "I'd start with a smaller setup and scale based on actual usage"
- "I'd monitor costs using Azure Cost Management"
- "I'd set up budget alerts to prevent overruns"
- "I'd use dev/test pricing for non-production environments"

---

## Practice Problem 1: Design a URL Shortener on Azure

### Requirements Gathering

**Functional Requirements:**
1. Generate short URL from long URL
2. Redirect short URL to original URL
3. Custom aliases (optional)
4. Analytics (click tracking)

**Non-Functional Requirements:**
1. High availability (99.9%)
2. Low latency (<100ms for redirects)
3. Handle 100M URLs
4. 10,000 requests/second
5. URL expiration (optional)

### Calculations

**Storage:**
```
- 100M URLs
- Each entry: Short URL (7 chars) + Long URL (500 chars) + metadata
- Average: 1KB per entry
- Total: 100GB
```

**Short URL Generation:**
```
Base62 encoding (a-z, A-Z, 0-9 = 62 characters)
- 6 characters: 62^6 = 56 billion combinations
- 7 characters: 62^7 = 3.5 trillion combinations
- Use 7 characters for safety
```

### High-Level Design

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │
       ▼
┌────────────────────────┐
│  Azure Front Door      │  (CDN, SSL, DDoS protection)
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│  API Management        │  (Rate limiting, API key)
└──────┬─────────────────┘
       │
       ├────Create URL────▶┌──────────────────┐
       │                   │  App Service     │
       │                   │  (REST API)      │
       │                   └────────┬─────────┘
       │                            │
       └────Redirect─────▶┌─────────▼────────┐
                          │  Redis Cache     │
                          │  (Hot URLs)      │
                          └─────────┬────────┘
                                    │ On miss
                                    ▼
                          ┌──────────────────┐
                          │   Cosmos DB      │
                          │   (URL storage)  │
                          └──────────────────┘

Background Processing:
┌──────────────────┐       ┌──────────────────┐
│  Service Bus     │──────▶│ Azure Function   │
│  (Click events)  │       │ (Analytics)      │
└──────────────────┘       └────────┬─────────┘
                                    │
                                    ▼
                          ┌──────────────────┐
                          │  Azure SQL       │
                          │  (Analytics)     │
                          └──────────────────┘
```

### API Design

**Create Short URL:**
```http
POST /api/urls
Content-Type: application/json

{
  "longUrl": "https://example.com/very/long/url",
  "customAlias": "mylink",  // Optional
  "expiresAt": "2024-12-31T23:59:59Z"  // Optional
}

Response 201 Created:
{
  "shortUrl": "https://short.ly/a1b2c3d",
  "longUrl": "https://example.com/very/long/url",
  "createdAt": "2024-01-15T10:30:00Z",
  "expiresAt": null
}
```

**Redirect:**
```http
GET /a1b2c3d

Response 301 Moved Permanently
Location: https://example.com/very/long/url
```

**Get Analytics:**
```http
GET /api/urls/a1b2c3d/analytics

Response 200 OK:
{
  "shortUrl": "a1b2c3d",
  "clicks": 1250,
  "uniqueClicks": 890,
  "clicksByCountry": {
    "US": 450,
    "UK": 200,
    "CA": 150
  },
  "clicksByDate": [...]
}
```

### Database Schema

**Cosmos DB (URL Storage):**
```json
{
  "id": "a1b2c3d",  // Partition key
  "longUrl": "https://example.com/very/long/url",
  "userId": "user123",
  "createdAt": "2024-01-15T10:30:00Z",
  "expiresAt": null,
  "customAlias": false,
  "clicks": 0,  // Eventual consistency okay
  "_ts": 1234567890
}
```

**Azure SQL (Analytics):**
```sql
CREATE TABLE ClickEvents (
    Id BIGINT PRIMARY KEY IDENTITY,
    ShortUrl VARCHAR(10),
    Timestamp DATETIME2,
    IpAddress VARCHAR(45),
    UserAgent VARCHAR(500),
    Country VARCHAR(2),
    Referrer VARCHAR(500),
    INDEX IX_ShortUrl_Timestamp (ShortUrl, Timestamp)
);
```

### Short URL Generation Strategy

**Approach 1: Counter-based with Base62 encoding**
```csharp
public class UrlShortener
{
    private static readonly string Base62 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    public string Encode(long id)
    {
        var result = new StringBuilder();

        while (id > 0)
        {
            result.Insert(0, Base62[(int)(id % 62)]);
            id /= 62;
        }

        return result.ToString().PadLeft(7, 'a');
    }

    public long Decode(string shortUrl)
    {
        long result = 0;
        foreach (var c in shortUrl)
        {
            result = result * 62 + Base62.IndexOf(c);
        }
        return result;
    }
}

// Generate unique ID using distributed counter in Redis
var counter = await _redisCache.StringIncrementAsync("url_counter");
var shortUrl = _urlShortener.Encode(counter);
```

**Approach 2: Hash-based (MD5/SHA256)**
```csharp
public string GenerateShortUrl(string longUrl)
{
    using var md5 = MD5.Create();
    var hash = md5.ComputeHash(Encoding.UTF8.GetBytes(longUrl));
    var base64 = Convert.ToBase64String(hash);
    var shortUrl = base64.Substring(0, 7);

    // Check for collision
    if (await _repository.ExistsAsync(shortUrl))
    {
        // Append counter or regenerate with salt
        shortUrl = base64.Substring(0, 6) + _random.Next(0, 62).ToString();
    }

    return shortUrl;
}
```

**Trade-off discussion:**
- Counter-based: Guaranteed unique, but needs distributed counter (Redis)
- Hash-based: Simpler, but potential collisions need handling

### Caching Strategy

**Two-tier caching:**

**1. In-Memory Cache (L1) - MemoryCache**
```csharp
var url = await _memoryCache.GetOrCreateAsync(shortUrl, async entry =>
{
    entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5);
    return await GetFromRedis(shortUrl);
});
```

**2. Redis Cache (L2)**
```csharp
public async Task<string> GetLongUrlAsync(string shortUrl)
{
    // Try cache
    var cached = await _redis.StringGetAsync(shortUrl);
    if (!cached.IsNull)
        return cached.ToString();

    // Cache miss - get from database
    var urlMapping = await _cosmosDb.GetAsync(shortUrl);

    if (urlMapping != null)
    {
        // Cache for 1 hour
        await _redis.StringSetAsync(shortUrl, urlMapping.LongUrl,
            TimeSpan.FromHours(1));

        return urlMapping.LongUrl;
    }

    return null;
}
```

**Cache invalidation:**
- TTL-based (1 hour)
- Explicit invalidation on URL update/delete

### Analytics Processing

**Async event processing:**
```csharp
[HttpGet("{shortUrl}")]
public async Task<IActionResult> Redirect(string shortUrl)
{
    var longUrl = await _urlService.GetLongUrlAsync(shortUrl);

    if (longUrl == null)
        return NotFound();

    // Fire-and-forget analytics (don't block redirect)
    _ = Task.Run(async () =>
    {
        await _serviceBus.SendMessageAsync(new ClickEvent
        {
            ShortUrl = shortUrl,
            Timestamp = DateTime.UtcNow,
            IpAddress = HttpContext.Connection.RemoteIpAddress.ToString(),
            UserAgent = Request.Headers["User-Agent"].ToString(),
            Referrer = Request.Headers["Referer"].ToString()
        });
    });

    return Redirect(longUrl);
}
```

**Background processing with Azure Function:**
```csharp
[FunctionName("ProcessClickEvents")]
public async Task Run(
    [ServiceBusTrigger("click-events")] ClickEvent clickEvent,
    ILogger log)
{
    // Enrich data
    var country = await _geoService.GetCountryAsync(clickEvent.IpAddress);

    // Store in Azure SQL for analytics
    await _analyticsRepository.AddAsync(new ClickRecord
    {
        ShortUrl = clickEvent.ShortUrl,
        Timestamp = clickEvent.Timestamp,
        Country = country,
        UserAgent = clickEvent.UserAgent,
        Referrer = clickEvent.Referrer
    });

    // Update Cosmos DB click count (eventual consistency okay)
    await _urlRepository.IncrementClicksAsync(clickEvent.ShortUrl);
}
```

### Scaling Strategy

**1. App Service Auto-scale:**
```
Scale rules:
- CPU > 70% for 5 min → Add instance
- CPU < 30% for 10 min → Remove instance
- Min: 2 instances (availability)
- Max: 20 instances
```

**2. Cosmos DB:**
```
- Use partition key: shortUrl
- Autoscale: 1000 - 10000 RU/s
- Multi-region writes for global users
```

**3. Redis Cache:**
```
- Start: C1 Standard (1GB)
- Monitor: Cache hit ratio, memory usage
- Scale: C2, C3 based on needs
```

### Trade-offs to Discuss

**1. Cosmos DB vs Azure SQL for URL storage:**
- Chose Cosmos DB because:
  - Global distribution (low latency worldwide)
  - Horizontal scaling
  - Key-value access pattern (simple lookups)
- Azure SQL would work if:
  - Single region sufficient
  - Need complex queries
  - Strong consistency critical

**2. Sync vs Async analytics:**
- Chose async because:
  - Redirect latency critical (<100ms)
  - Analytics can be eventual
  - Handles traffic spikes better

**3. Counter vs Hash for short URL generation:**
- Chose counter because:
  - Guaranteed uniqueness
  - Predictable length
  - No collision handling needed

---

## Practice Problem 2: Design a Chat Application

### Requirements

**Functional:**
1. One-on-one messaging
2. Group chats
3. Real-time delivery
4. Message history
5. Online status
6. Typing indicators
7. Media sharing

**Non-Functional:**
1. 1M concurrent users
2. 100M messages/day
3. Real-time (<100ms latency)
4. 99.99% availability
5. Message encryption

### High-Level Design

```
┌──────────────┐
│  Web/Mobile  │
│   Client     │
└──────┬───────┘
       │ WebSocket
       ▼
┌────────────────────────┐
│  Azure SignalR Service │ (Manages WebSocket connections)
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│  App Service           │ (Chat API, Hub)
│  (SignalR Hub)         │
└──────┬─────────────────┘
       │
       ├──────────────┬──────────────┬──────────────┐
       ▼              ▼              ▼              ▼
┌──────────┐   ┌──────────┐  ┌──────────┐  ┌──────────┐
│Cosmos DB │   │Service   │  │  Blob    │  │  Redis   │
│(Messages)│   │  Bus     │  │ Storage  │  │  (Cache) │
└──────────┘   └────┬─────┘  └──────────┘  └──────────┘
                    │
                    ▼
               ┌──────────────┐
               │Azure Function│
               │(Notifications│
               │ Push/Email)  │
               └──────────────┘
```

### Why Azure SignalR Service?

**Benefits:**
- Manages 100K+ concurrent WebSocket connections per unit
- Auto-scales connection management
- Frees app servers from connection overhead
- Handles connection lifecycle

**Alternative:**
- Self-hosted SignalR requires sticky sessions, connection management, scaling complexity

### Database Design

**Cosmos DB Container: Messages**
```json
{
  "id": "msg_12345",
  "chatId": "chat_abc",  // Partition key
  "senderId": "user_123",
  "content": "Hello!",
  "contentType": "text",  // text, image, file
  "mediaUrl": null,
  "timestamp": "2024-01-15T10:30:00Z",
  "deliveredTo": ["user_456"],
  "readBy": ["user_456"],
  "replyTo": null,
  "_ts": 1234567890
}
```

**Cosmos DB Container: Chats**
```json
{
  "id": "chat_abc",  // Partition key
  "type": "direct",  // direct or group
  "participants": ["user_123", "user_456"],
  "createdAt": "2024-01-15T10:00:00Z",
  "lastMessage": {
    "content": "Hello!",
    "timestamp": "2024-01-15T10:30:00Z",
    "senderId": "user_123"
  },
  "metadata": {
    "name": "Project Discussion",  // For group chats
    "avatar": "https://..."
  }
}
```

**Azure SQL: Users**
```sql
CREATE TABLE Users (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE,
    Email NVARCHAR(100),
    PasswordHash NVARCHAR(500),
    ProfilePictureUrl NVARCHAR(500),
    LastSeen DATETIME2,
    IsOnline BIT,
    CreatedAt DATETIME2
);

CREATE INDEX IX_Users_Username ON Users(Username);
```

### Real-time Messaging Flow

**Send Message:**
```csharp
// SignalR Hub
public class ChatHub : Hub
{
    private readonly IMessageService _messageService;
    private readonly IConnectionManager _connectionManager;

    public async Task SendMessage(string chatId, string content)
    {
        var userId = Context.UserIdentifier;

        // Save message
        var message = await _messageService.CreateAsync(new Message
        {
            ChatId = chatId,
            SenderId = userId,
            Content = content,
            Timestamp = DateTime.UtcNow
        });

        // Get chat participants
        var participants = await _chatService.GetParticipantsAsync(chatId);

        // Send to online participants via SignalR
        foreach (var participant in participants.Where(p => p != userId))
        {
            await Clients.User(participant).SendAsync("ReceiveMessage", message);
        }

        // Queue notifications for offline users
        var offlineUsers = await GetOfflineUsers(participants);
        foreach (var user in offlineUsers)
        {
            await _serviceBus.SendMessageAsync(new NotificationMessage
            {
                UserId = user,
                Type = "NewMessage",
                Data = message
            });
        }
    }

    public async Task MarkAsRead(string chatId, string messageId)
    {
        var userId = Context.UserIdentifier;

        await _messageService.MarkAsReadAsync(messageId, userId);

        // Notify sender
        var message = await _messageService.GetAsync(messageId);
        await Clients.User(message.SenderId).SendAsync("MessageRead", new
        {
            MessageId = messageId,
            ReadBy = userId
        });
    }

    public async Task Typing(string chatId)
    {
        var userId = Context.UserIdentifier;
        var participants = await _chatService.GetParticipantsAsync(chatId);

        await Clients.Users(participants.Where(p => p != userId).ToList())
            .SendAsync("UserTyping", new { ChatId = chatId, UserId = userId });
    }

    // Connection lifecycle
    public override async Task OnConnectedAsync()
    {
        var userId = Context.UserIdentifier;
        await _userService.UpdateStatusAsync(userId, isOnline: true);

        // Notify friends
        var friends = await _userService.GetFriendsAsync(userId);
        await Clients.Users(friends).SendAsync("UserOnline", userId);

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception exception)
    {
        var userId = Context.UserIdentifier;
        await _userService.UpdateStatusAsync(userId, isOnline: false);

        // Notify friends
        var friends = await _userService.GetFriendsAsync(userId);
        await Clients.Users(friends).SendAsync("UserOffline", userId);

        await base.OnDisconnectedAsync(exception);
    }
}
```

### Message History & Pagination

```csharp
[HttpGet("chats/{chatId}/messages")]
public async Task<ActionResult<PagedResult<Message>>> GetMessages(
    string chatId,
    [FromQuery] string continuationToken = null,
    [FromQuery] int pageSize = 50)
{
    // Check authorization
    if (!await _chatService.IsParticipantAsync(chatId, User.GetUserId()))
        return Forbid();

    // Query Cosmos DB with pagination
    var query = _cosmosContainer
        .GetItemQueryIterator<Message>(
            new QueryDefinition("SELECT * FROM c WHERE c.chatId = @chatId ORDER BY c.timestamp DESC")
                .WithParameter("@chatId", chatId),
            continuationToken,
            new QueryRequestOptions { MaxItemCount = pageSize });

    var response = await query.ReadNextAsync();

    return Ok(new PagedResult<Message>
    {
        Items = response.ToList(),
        ContinuationToken = response.ContinuationToken
    });
}
```

### Media Sharing

**Upload flow:**
```csharp
[HttpPost("chats/{chatId}/media")]
public async Task<ActionResult<MediaUploadResponse>> UploadMedia(
    string chatId,
    IFormFile file)
{
    // Validate file
    if (file.Length > 10 * 1024 * 1024) // 10MB limit
        return BadRequest("File too large");

    var allowedTypes = new[] { "image/jpeg", "image/png", "video/mp4" };
    if (!allowedTypes.Contains(file.ContentType))
        return BadRequest("Invalid file type");

    // Generate unique filename
    var blobName = $"{chatId}/{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";

    // Upload to Blob Storage
    var blobClient = _blobContainerClient.GetBlobClient(blobName);
    await blobClient.UploadAsync(file.OpenReadStream(), new BlobHttpHeaders
    {
        ContentType = file.ContentType
    });

    // Generate SAS URL (valid for 7 days)
    var sasUrl = blobClient.GenerateSasUri(
        BlobSasPermissions.Read,
        DateTimeOffset.UtcNow.AddDays(7));

    return Ok(new MediaUploadResponse
    {
        Url = sasUrl.ToString(),
        ThumbnailUrl = await GenerateThumbnailAsync(blobName, file.ContentType)
    });
}
```

### Scaling Considerations

**1. SignalR Scale-Out:**
```
Azure SignalR Service:
- Standard tier: Up to 100K concurrent connections per unit
- Add units for more connections
- Automatic load balancing across units
```

**2. Cosmos DB Partitioning:**
```
Partition key: chatId
- Even distribution if chats are evenly sized
- Hot partition issue for popular group chats

Solution for hot partitions:
- Composite partition key: chatId + date
- Synthetic partition key: chatId + hash(messageId)
```

**3. Message Delivery Guarantee:**
```
Use Service Bus for offline message queue:
- At-least-once delivery
- Dead-letter queue for failed deliveries
- Duplicate detection
```

### Trade-offs to Discuss

**1. SignalR vs Polling:**
- SignalR: Real-time, efficient, complex
- Polling: Simple, higher latency, more requests
- Chose SignalR for real-time requirement

**2. Cosmos DB vs Azure SQL:**
- Cosmos DB: Scales better, flexible schema, global distribution
- Azure SQL: Better for complex queries, transactions
- Chose Cosmos DB for scalability and global reach

**3. Blob Storage vs Database for media:**
- Blob Storage: Cost-effective, CDN integration, better performance
- Database: Simpler, transactional
- Chose Blob Storage for large files

---

## Practice Problem 3: Design a File Storage Service (Dropbox-like)

### Requirements

**Functional:**
1. Upload files (up to 2GB)
2. Download files
3. File sharing (public/private links)
4. Folder structure
5. File versioning
6. Real-time sync across devices
7. Search files

**Non-Functional:**
1. 10M users
2. Average 100GB per user
3. 99.99% durability
4. Support 10,000 concurrent uploads
5. Global access

### Calculations

```
Storage:
- 10M users * 100GB = 1 Petabyte
- 20% growth annually = 200TB/year

Bandwidth:
- Average file size: 5MB
- 1M uploads/day = 5TB/day upload
- 10M downloads/day = 50TB/day download

Metadata:
- 10M users * 10,000 files = 100B file records
- Metadata per file: 1KB
- Total metadata: 100TB
```

### High-Level Design

```
┌──────────────┐
│   Client     │
│   (Desktop/  │
│    Mobile)   │
└──────┬───────┘
       │
       ▼
┌────────────────────────┐
│  Azure Front Door      │ (SSL, CDN, geo-routing)
└──────┬─────────────────┘
       │
       ├────Metadata API────▶┌──────────────────┐
       │                     │  App Service     │
       │                     │  (REST API)      │
       │                     └────────┬─────────┘
       │                              │
       │                              ▼
       │                     ┌──────────────────┐
       │                     │   Cosmos DB      │
       │                     │   (Metadata)     │
       │                     └──────────────────┘
       │
       └────File Upload/────▶┌──────────────────┐
            Download         │  Blob Storage    │
                            │  (Files)         │
                            └──────────────────┘

Sync Mechanism:
┌──────────────┐       ┌──────────────┐
│  SignalR     │◀─────│  Function    │
│  (Notify     │      │  (Watch blob │
│   clients)   │      │   changes)   │
└──────────────┘       └──────────────┘
```

### Database Schema

**Cosmos DB Container: Files**
```json
{
  "id": "file_12345",
  "userId": "user_123",  // Partition key
  "name": "document.pdf",
  "path": "/Work/Projects/document.pdf",
  "parentFolderId": "folder_789",
  "size": 1048576,
  "contentType": "application/pdf",
  "blobUrl": "https://storage.blob.core.windows.net/files/user_123/file_12345_v1",
  "version": 1,
  "checksum": "md5_hash_here",
  "isDeleted": false,
  "createdAt": "2024-01-15T10:00:00Z",
  "modifiedAt": "2024-01-15T10:00:00Z",
  "versions": [
    {
      "version": 1,
      "blobUrl": "...",
      "size": 1048576,
      "createdAt": "2024-01-15T10:00:00Z"
    }
  ],
  "sharedWith": [],
  "publicLink": null
}
```

**Cosmos DB Container: Folders**
```json
{
  "id": "folder_789",
  "userId": "user_123",  // Partition key
  "name": "Projects",
  "path": "/Work/Projects",
  "parentFolderId": "folder_456",
  "createdAt": "2024-01-15T09:00:00Z"
}
```

**Cosmos DB Container: Shares**
```json
{
  "id": "share_abc",
  "fileId": "file_12345",
  "ownerId": "user_123",
  "sharedWith": "user_456",  // or "public"
  "permissions": "read",  // read, write
  "expiresAt": "2024-12-31T23:59:59Z",
  "token": "public_token_xyz",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### File Upload Strategy

**Chunked Upload for Large Files:**

```csharp
[HttpPost("files/upload/initiate")]
public async Task<ActionResult<UploadSession>> InitiateUpload(
    [FromBody] InitiateUploadRequest request)
{
    var userId = User.GetUserId();

    // Validate quota
    var currentUsage = await _storageService.GetUsageAsync(userId);
    if (currentUsage + request.FileSize > GetUserQuota(userId))
        return BadRequest("Storage quota exceeded");

    // Create upload session
    var sessionId = Guid.NewGuid().ToString();
    var blockBlobClient = _blobContainerClient.GetBlockBlobClient(
        $"{userId}/{sessionId}");

    // Store session metadata
    await _uploadSessionRepository.CreateAsync(new UploadSession
    {
        Id = sessionId,
        UserId = userId,
        FileName = request.FileName,
        FileSize = request.FileSize,
        TotalChunks = (int)Math.Ceiling(request.FileSize / (double)ChunkSize),
        UploadedChunks = new HashSet<int>(),
        BlobUrl = blockBlobClient.Uri.ToString(),
        CreatedAt = DateTime.UtcNow,
        ExpiresAt = DateTime.UtcNow.AddHours(24)
    });

    return Ok(new UploadSessionResponse
    {
        SessionId = sessionId,
        ChunkSize = ChunkSize
    });
}

[HttpPost("files/upload/{sessionId}/chunk/{chunkIndex}")]
public async Task<ActionResult> UploadChunk(
    string sessionId,
    int chunkIndex,
    IFormFile chunk)
{
    var session = await _uploadSessionRepository.GetAsync(sessionId);

    if (session == null || session.UserId != User.GetUserId())
        return NotFound();

    // Upload chunk as block
    var blockId = Convert.ToBase64String(
        Encoding.UTF8.GetBytes(chunkIndex.ToString().PadLeft(5, '0')));

    var blockBlobClient = new BlockBlobClient(new Uri(session.BlobUrl));
    await blockBlobClient.StageBlockAsync(blockId, chunk.OpenReadStream());

    // Update session
    session.UploadedChunks.Add(chunkIndex);
    await _uploadSessionRepository.UpdateAsync(session);

    // If all chunks uploaded, commit
    if (session.UploadedChunks.Count == session.TotalChunks)
    {
        await CommitUpload(session, blockBlobClient);
    }

    return Ok();
}

private async Task CommitUpload(UploadSession session, BlockBlobClient blockBlobClient)
{
    // Commit blocks
    var blockList = session.UploadedChunks
        .OrderBy(c => c)
        .Select(c => Convert.ToBase64String(
            Encoding.UTF8.GetBytes(c.ToString().PadLeft(5, '0'))))
        .ToList();

    await blockBlobClient.CommitBlockListAsync(blockList);

    // Create file metadata
    var fileId = Guid.NewGuid().ToString();
    await _fileRepository.CreateAsync(new FileMetadata
    {
        Id = fileId,
        UserId = session.UserId,
        Name = session.FileName,
        Size = session.FileSize,
        BlobUrl = session.BlobUrl,
        Version = 1,
        CreatedAt = DateTime.UtcNow,
        ModifiedAt = DateTime.UtcNow
    });

    // Cleanup session
    await _uploadSessionRepository.DeleteAsync(session.Id);

    // Notify other devices via SignalR
    await _hubContext.Clients.User(session.UserId)
        .SendAsync("FileUploaded", fileId);
}
```

### File Download

**Optimized download with CDN:**

```csharp
[HttpGet("files/{fileId}/download")]
public async Task<ActionResult> DownloadFile(string fileId)
{
    var file = await _fileRepository.GetAsync(fileId);

    if (file == null)
        return NotFound();

    // Check permissions
    if (!await CanAccessFile(User.GetUserId(), file))
        return Forbid();

    // Generate SAS URL (valid for 1 hour)
    var blobClient = new BlobClient(new Uri(file.BlobUrl));
    var sasUrl = blobClient.GenerateSasUri(
        BlobSasPermissions.Read,
        DateTimeOffset.UtcNow.AddHours(1));

    // Return redirect to SAS URL (client downloads directly from Blob Storage)
    return Redirect(sasUrl.ToString());

    // Alternative: Stream through API (not recommended for large files)
    // var stream = await blobClient.OpenReadAsync();
    // return File(stream, file.ContentType, file.Name);
}
```

### File Versioning

**Create new version:**

```csharp
[HttpPut("files/{fileId}")]
public async Task<ActionResult> UpdateFile(string fileId, IFormFile newVersion)
{
    var file = await _fileRepository.GetAsync(fileId);

    if (file == null || file.UserId != User.GetUserId())
        return NotFound();

    // Upload new version
    var newBlobUrl = $"{file.BlobUrl}_v{file.Version + 1}";
    var blobClient = _blobContainerClient.GetBlobClient(newBlobUrl);
    await blobClient.UploadAsync(newVersion.OpenReadStream());

    // Update metadata
    file.Versions.Add(new FileVersion
    {
        Version = file.Version,
        BlobUrl = file.BlobUrl,
        Size = file.Size,
        CreatedAt = file.ModifiedAt
    });

    file.Version++;
    file.BlobUrl = newBlobUrl;
    file.Size = newVersion.Length;
    file.ModifiedAt = DateTime.UtcNow;

    await _fileRepository.UpdateAsync(file);

    // Notify other devices
    await _hubContext.Clients.User(file.UserId)
        .SendAsync("FileModified", fileId);

    return Ok();
}

[HttpPost("files/{fileId}/restore/{version}")]
public async Task<ActionResult> RestoreVersion(string fileId, int version)
{
    var file = await _fileRepository.GetAsync(fileId);

    if (file == null || file.UserId != User.GetUserId())
        return NotFound();

    var versionInfo = file.Versions.FirstOrDefault(v => v.Version == version);

    if (versionInfo == null)
        return NotFound("Version not found");

    // Create new version from old version
    var newVersion = file.Version + 1;
    var newBlobUrl = $"{file.BlobUrl}_v{newVersion}";

    // Copy old version to new blob
    var sourceBlobClient = new BlobClient(new Uri(versionInfo.BlobUrl));
    var destBlobClient = _blobContainerClient.GetBlobClient(newBlobUrl);
    await destBlobClient.StartCopyFromUriAsync(sourceBlobClient.Uri);

    // Update metadata
    file.Versions.Add(new FileVersion
    {
        Version = file.Version,
        BlobUrl = file.BlobUrl,
        Size = file.Size,
        CreatedAt = file.ModifiedAt
    });

    file.Version = newVersion;
    file.BlobUrl = newBlobUrl;
    file.Size = versionInfo.Size;
    file.ModifiedAt = DateTime.UtcNow;

    await _fileRepository.UpdateAsync(file);

    return Ok();
}
```

### File Sharing

**Generate public link:**

```csharp
[HttpPost("files/{fileId}/share")]
public async Task<ActionResult<ShareLink>> CreateShareLink(
    string fileId,
    [FromBody] CreateShareRequest request)
{
    var file = await _fileRepository.GetAsync(fileId);

    if (file == null || file.UserId != User.GetUserId())
        return NotFound();

    var shareToken = GenerateSecureToken();

    var share = new Share
    {
        Id = Guid.NewGuid().ToString(),
        FileId = fileId,
        OwnerId = file.UserId,
        SharedWith = request.SharedWith ?? "public",
        Permissions = request.Permissions,
        Token = shareToken,
        ExpiresAt = request.ExpiresAt,
        CreatedAt = DateTime.UtcNow
    };

    await _shareRepository.CreateAsync(share);

    var shareUrl = $"{_baseUrl}/share/{shareToken}";

    return Ok(new ShareLinkResponse
    {
        Url = shareUrl,
        Token = shareToken,
        ExpiresAt = request.ExpiresAt
    });
}

[HttpGet("share/{token}")]
[AllowAnonymous]
public async Task<ActionResult> AccessSharedFile(string token)
{
    var share = await _shareRepository.GetByTokenAsync(token);

    if (share == null || (share.ExpiresAt.HasValue && share.ExpiresAt < DateTime.UtcNow))
        return NotFound();

    var file = await _fileRepository.GetAsync(share.FileId);

    // Generate temporary SAS URL
    var blobClient = new BlobClient(new Uri(file.BlobUrl));
    var sasUrl = blobClient.GenerateSasUri(
        BlobSasPermissions.Read,
        DateTimeOffset.UtcNow.AddHours(1));

    return Redirect(sasUrl.ToString());
}
```

### Real-time Sync

**Using Azure Functions + SignalR:**

```csharp
// Function triggered on blob changes
[FunctionName("BlobChangeNotifier")]
public async Task Run(
    [BlobTrigger("files/{userId}/{fileId}")] Stream blobStream,
    string userId,
    string fileId,
    [SignalR(HubName = "fileSync")] IAsyncCollector<SignalRMessage> signalRMessages)
{
    // Notify user's other devices
    await signalRMessages.AddAsync(new SignalRMessage
    {
        UserId = userId,
        Target = "FileChanged",
        Arguments = new[] { fileId }
    });
}

// Client-side handling
public class FileSyncClient
{
    private HubConnection _connection;

    public async Task ConnectAsync(string userId)
    {
        _connection = new HubConnectionBuilder()
            .WithUrl($"{_baseUrl}/fileSync?userId={userId}")
            .WithAutomaticReconnect()
            .Build();

        _connection.On<string>("FileChanged", async (fileId) =>
        {
            await SyncFileAsync(fileId);
        });

        await _connection.StartAsync();
    }

    private async Task SyncFileAsync(string fileId)
    {
        // Download updated file metadata
        var file = await _apiClient.GetFileAsync(fileId);

        // Check if local version is outdated
        var localFile = _localDb.GetFile(fileId);

        if (localFile == null || localFile.ModifiedAt < file.ModifiedAt)
        {
            // Download file
            await DownloadFileAsync(fileId);
        }
    }
}
```

### Search Functionality

**Using Azure Cognitive Search:**

```csharp
// Index files in Azure Cognitive Search
public class FileIndexer
{
    private readonly SearchClient _searchClient;

    public async Task IndexFileAsync(FileMetadata file)
    {
        var document = new FileSearchDocument
        {
            Id = file.Id,
            Name = file.Name,
            Path = file.Path,
            Content = await ExtractTextContentAsync(file),
            OwnerId = file.UserId,
            Tags = file.Tags,
            CreatedAt = file.CreatedAt,
            ModifiedAt = file.ModifiedAt
        };

        await _searchClient.IndexDocumentsAsync(
            IndexDocumentsBatch.Upload(new[] { document }));
    }

    private async Task<string> ExtractTextContentAsync(FileMetadata file)
    {
        // For text files, PDFs, Word docs - extract content
        // Use Azure Form Recognizer or similar service
        if (file.ContentType == "application/pdf")
        {
            var blobClient = new BlobClient(new Uri(file.BlobUrl));
            var stream = await blobClient.OpenReadAsync();
            return await _pdfExtractor.ExtractTextAsync(stream);
        }

        return string.Empty;
    }
}

// Search API
[HttpGet("files/search")]
public async Task<ActionResult<SearchResults>> SearchFiles([FromQuery] string query)
{
    var userId = User.GetUserId();

    var searchOptions = new SearchOptions
    {
        Filter = $"ownerId eq '{userId}'",
        OrderBy = { "modifiedAt desc" },
        Size = 50
    };

    var results = await _searchClient.SearchAsync<FileSearchDocument>(query, searchOptions);

    return Ok(results.Value.GetResults().Select(r => r.Document));
}
```

### Scaling & Optimization

**1. Blob Storage:**
```
- Hot tier: Recently accessed files
- Cool tier: Files not accessed for 30+ days (lifecycle policy)
- Archive tier: Old versions (90+ days)

Cost optimization:
- Hot: $0.018/GB/month
- Cool: $0.01/GB/month
- Archive: $0.002/GB/month
```

**2. CDN Integration:**
```
- Azure CDN in front of Blob Storage
- Cache frequently accessed files
- Reduce blob storage egress costs
- Lower latency for global users
```

**3. Deduplication:**
```
- Store files by content hash
- Multiple file records can point to same blob
- Saves storage for duplicate files

Example:
User A uploads file → Hash: abc123 → Blob: /blobs/abc123
User B uploads same file → Hash: abc123 → Reference same blob
```

**4. Compression:**
```
- Compress files before upload (client-side)
- Especially for text files, JSON, XML
- Save bandwidth and storage costs
```

### Trade-offs to Discuss

**1. Metadata storage (Cosmos DB vs Azure SQL):**
- Chose Cosmos DB for:
  - Horizontal scaling
  - Global distribution
  - Flexible schema
- Azure SQL would work for smaller scale

**2. Direct blob access vs API proxy:**
- Direct (SAS URL): Lower latency, less bandwidth cost
- API proxy: Better control, easier logging
- Chose direct for downloads, API for uploads

**3. Real-time sync vs polling:**
- Real-time (SignalR): Better UX, complex
- Polling: Simple, higher latency
- Chose real-time for Dropbox-like experience

---

## Practice Problem 4: Design an Order Processing System

### Requirements

**Functional:**
1. Place orders
2. Process payments
3. Manage inventory
4. Order fulfillment
5. Shipping integration
6. Order tracking
7. Returns/refunds

**Non-Functional:**
1. Handle 10,000 orders/hour
2. 99.99% availability (critical for revenue)
3. Strong consistency for inventory/payments
4. Idempotent operations
5. Audit trail for compliance

### High-Level Design

```
┌──────────────┐
│  Client      │
└──────┬───────┘
       │
       ▼
┌────────────────────────┐
│  API Gateway (APIM)    │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│  Order Service (API)   │
└──────┬─────────────────┘
       │
       ├─────────────┬─────────────┬─────────────┐
       ▼             ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  Order   │  │ Payment  │  │Inventory │  │Shipping  │
│  Queue   │  │ Service  │  │ Service  │  │ Service  │
└────┬─────┘  └──────────┘  └──────────┘  └──────────┘
     │
     ▼
┌────────────┐        ┌──────────────┐
│  Azure     │───────▶│   Order      │
│  Function  │        │ Processor    │
└────────────┘        └──────┬───────┘
                             │
                    ┌────────┼────────┐
                    ▼        ▼        ▼
              ┌─────────┬─────────┬─────────┐
              │Azure SQL│Cosmos DB│Event Hub│
              │(Orders) │(Catalog)│(Events) │
              └─────────┴─────────┴─────────┘
```

### Database Schema

**Azure SQL (Orders - ACID compliance):**
```sql
CREATE TABLE Orders (
    OrderId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    OrderNumber VARCHAR(50) UNIQUE NOT NULL,
    Status VARCHAR(50) NOT NULL, -- Pending, Confirmed, Processing, Shipped, Delivered, Cancelled
    TotalAmount DECIMAL(18,2) NOT NULL,
    Currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    PaymentStatus VARCHAR(50), -- Pending, Completed, Failed, Refunded
    PaymentMethod VARCHAR(50),
    ShippingAddress NVARCHAR(MAX), -- JSON
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    INDEX IX_Orders_UserId (UserId),
    INDEX IX_Orders_Status (Status),
    INDEX IX_Orders_CreatedAt (CreatedAt)
);

CREATE TABLE OrderItems (
    OrderItemId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    OrderId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    ProductName NVARCHAR(200),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    TotalPrice DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    INDEX IX_OrderItems_OrderId (OrderId)
);

CREATE TABLE OrderEvents (
    EventId BIGINT PRIMARY KEY IDENTITY,
    OrderId UNIQUEIDENTIFIER NOT NULL,
    EventType VARCHAR(50) NOT NULL,
    EventData NVARCHAR(MAX), -- JSON
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    INDEX IX_OrderEvents_OrderId (OrderId)
);

CREATE TABLE Inventory (
    ProductId UNIQUEIDENTIFIER PRIMARY KEY,
    AvailableQuantity INT NOT NULL,
    ReservedQuantity INT NOT NULL,
    Version ROWVERSION, -- For optimistic concurrency
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);
```

**Cosmos DB (Product Catalog):**
```json
{
  "id": "product_123",
  "name": "Laptop",
  "description": "...",
  "price": 999.99,
  "category": "Electronics",
  "attributes": {
    "brand": "Dell",
    "model": "XPS 15"
  },
  "images": ["url1", "url2"]
}
```

### Order Placement Flow

**API Endpoint:**
```csharp
[HttpPost("orders")]
public async Task<ActionResult<OrderResponse>> CreateOrder(
    [FromBody] CreateOrderRequest request)
{
    var userId = User.GetUserId();

    // 1. Validate request
    if (!request.Items.Any())
        return BadRequest("Order must contain at least one item");

    // 2. Generate idempotency key from request (prevent duplicate orders)
    var idempotencyKey = $"{userId}:{request.CartId}:{DateTime.UtcNow:yyyyMMddHH}";
    var existingOrder = await _orderRepository.GetByIdempotencyKeyAsync(idempotencyKey);

    if (existingOrder != null)
        return Ok(existingOrder); // Return existing order

    // 3. Check inventory availability
    var inventoryCheck = await _inventoryService.CheckAvailabilityAsync(request.Items);

    if (!inventoryCheck.AllAvailable)
        return BadRequest($"Insufficient inventory for: {string.Join(", ", inventoryCheck.UnavailableItems)}");

    // 4. Calculate total
    var items = await _productService.GetProductsAsync(request.Items.Select(i => i.ProductId));
    var orderTotal = items.Sum(p => p.Price * request.Items.First(i => i.ProductId == p.Id).Quantity);

    // 5. Create order (status: Pending)
    var order = new Order
    {
        Id = Guid.NewGuid(),
        UserId = userId,
        OrderNumber = GenerateOrderNumber(),
        Status = OrderStatus.Pending,
        TotalAmount = orderTotal,
        PaymentStatus = PaymentStatus.Pending,
        IdempotencyKey = idempotencyKey,
        CreatedAt = DateTime.UtcNow
    };

    await _orderRepository.CreateAsync(order);

    // 6. Send to processing queue
    await _serviceBus.SendMessageAsync("order-processing", new OrderCreatedEvent
    {
        OrderId = order.Id,
        UserId = userId,
        Items = request.Items,
        TotalAmount = orderTotal
    });

    // 7. Return order immediately (async processing)
    return AcceptedAtAction(nameof(GetOrder), new { id = order.Id }, order);
}
```

### Background Processing (Azure Function)

**Order Processing Workflow:**
```csharp
[FunctionName("ProcessOrder")]
public async Task Run(
    [ServiceBusTrigger("order-processing")] OrderCreatedEvent orderEvent,
    ILogger log)
{
    var orderId = orderEvent.OrderId;

    try
    {
        // Step 1: Reserve inventory
        var inventoryReserved = await ReserveInventoryAsync(orderEvent.Items, orderId);

        if (!inventoryReserved)
        {
            await UpdateOrderStatusAsync(orderId, OrderStatus.Cancelled, "Insufficient inventory");
            return;
        }

        // Step 2: Process payment
        var paymentResult = await ProcessPaymentAsync(orderId, orderEvent.TotalAmount);

        if (!paymentResult.Success)
        {
            // Release inventory reservation
            await ReleaseInventoryAsync(orderId);

            await UpdateOrderStatusAsync(orderId, OrderStatus.Cancelled, "Payment failed");
            return;
        }

        // Step 3: Confirm order
        await UpdateOrderStatusAsync(orderId, OrderStatus.Confirmed, "Order confirmed");

        // Step 4: Trigger fulfillment
        await _serviceBus.SendMessageAsync("order-fulfillment", new OrderConfirmedEvent
        {
            OrderId = orderId
        });

        // Step 5: Send confirmation email
        await _serviceBus.SendMessageAsync("notifications", new EmailNotification
        {
            To = orderEvent.UserId,
            Template = "OrderConfirmation",
            Data = new { OrderId = orderId }
        });
    }
    catch (Exception ex)
    {
        log.LogError(ex, $"Error processing order {orderId}");

        // Implement retry logic with exponential backoff
        throw; // Service Bus will retry
    }
}

private async Task<bool> ReserveInventoryAsync(List<OrderItem> items, Guid orderId)
{
    using var transaction = await _dbContext.Database.BeginTransactionAsync();

    try
    {
        foreach (var item in items)
        {
            var inventory = await _dbContext.Inventory
                .FromSqlRaw("SELECT * FROM Inventory WITH (UPDLOCK, ROWLOCK) WHERE ProductId = {0}", item.ProductId)
                .FirstOrDefaultAsync();

            if (inventory == null || inventory.AvailableQuantity < item.Quantity)
            {
                await transaction.RollbackAsync();
                return false;
            }

            inventory.AvailableQuantity -= item.Quantity;
            inventory.ReservedQuantity += item.Quantity;
        }

        await _dbContext.SaveChangesAsync();
        await transaction.CommitAsync();

        return true;
    }
    catch
    {
        await transaction.RollbackAsync();
        return false;
    }
}

private async Task<PaymentResult> ProcessPaymentAsync(Guid orderId, decimal amount)
{
    // Idempotent payment processing
    var existingPayment = await _paymentRepository.GetByOrderIdAsync(orderId);

    if (existingPayment != null)
        return new PaymentResult { Success = existingPayment.Status == "Completed" };

    // Call payment gateway
    var paymentRequest = new PaymentRequest
    {
        OrderId = orderId,
        Amount = amount,
        IdempotencyKey = orderId.ToString() // Prevents duplicate charges
    };

    var result = await _paymentGateway.ProcessAsync(paymentRequest);

    // Store payment record
    await _paymentRepository.CreateAsync(new Payment
    {
        OrderId = orderId,
        Amount = amount,
        Status = result.Success ? "Completed" : "Failed",
        TransactionId = result.TransactionId,
        ProcessedAt = DateTime.UtcNow
    });

    return result;
}
```

### Saga Pattern for Distributed Transactions

**Compensating transactions for failures:**

```csharp
public class OrderSaga
{
    private readonly List<Func<Task>> _compensations = new();

    public async Task<bool> ExecuteAsync()
    {
        try
        {
            // Step 1: Reserve inventory
            await ReserveInventory();
            _compensations.Add(ReleaseInventory);

            // Step 2: Process payment
            await ProcessPayment();
            _compensations.Add(RefundPayment);

            // Step 3: Create shipment
            await CreateShipment();
            _compensations.Add(CancelShipment);

            return true;
        }
        catch (Exception ex)
        {
            // Execute compensations in reverse order
            _compensations.Reverse();

            foreach (var compensation in _compensations)
            {
                try
                {
                    await compensation();
                }
                catch (Exception compensationEx)
                {
                    // Log compensation failure
                    // May need manual intervention
                }
            }

            return false;
        }
    }

    private async Task ReserveInventory() { /* ... */ }
    private async Task ReleaseInventory() { /* ... */ }
    private async Task ProcessPayment() { /* ... */ }
    private async Task RefundPayment() { /* ... */ }
    private async Task CreateShipment() { /* ... */ }
    private async Task CancelShipment() { /* ... */ }
}
```

### Event Sourcing for Audit Trail

**Store all state changes as events:**

```csharp
public class OrderEventStore
{
    public async Task AppendEventAsync(Guid orderId, OrderEvent orderEvent)
    {
        await _dbContext.OrderEvents.AddAsync(new OrderEventEntity
        {
            OrderId = orderId,
            EventType = orderEvent.GetType().Name,
            EventData = JsonSerializer.Serialize(orderEvent),
            CreatedAt = DateTime.UtcNow
        });

        await _dbContext.SaveChangesAsync();

        // Also publish to Event Hub for real-time processing
        await _eventHub.SendAsync(orderEvent);
    }

    public async Task<Order> ReconstructOrderAsync(Guid orderId)
    {
        var events = await _dbContext.OrderEvents
            .Where(e => e.OrderId == orderId)
            .OrderBy(e => e.CreatedAt)
            .ToListAsync();

        var order = new Order { Id = orderId };

        foreach (var eventEntity in events)
        {
            var orderEvent = DeserializeEvent(eventEntity);
            order = ApplyEvent(order, orderEvent);
        }

        return order;
    }

    private Order ApplyEvent(Order order, OrderEvent orderEvent)
    {
        return orderEvent switch
        {
            OrderCreatedEvent e => order with
            {
                UserId = e.UserId,
                TotalAmount = e.TotalAmount,
                Status = OrderStatus.Pending
            },
            OrderConfirmedEvent e => order with { Status = OrderStatus.Confirmed },
            OrderShippedEvent e => order with
            {
                Status = OrderStatus.Shipped,
                TrackingNumber = e.TrackingNumber
            },
            OrderDeliveredEvent e => order with { Status = OrderStatus.Delivered },
            _ => order
        };
    }
}
```

### Scaling Considerations

**1. Queue-based processing:**
```
Benefits:
- Decouples order placement from processing
- Handles traffic spikes (queue acts as buffer)
- Failed orders can be retried
- Enables async processing

Azure Service Bus configuration:
- Standard tier with partitioning (higher throughput)
- Message TTL: 14 days
- Dead-letter queue for failed messages
- Max delivery count: 10
```

**2. Database scaling:**
```
Azure SQL:
- Read replicas for reporting/analytics
- Horizontal partitioning by date (OrderId includes timestamp)
- In-memory OLTP for hot tables (Inventory)

Inventory table optimization:
- UPDLOCK hint to prevent deadlocks
- Optimistic concurrency with ROWVERSION
- Batch updates for performance
```

**3. Caching:**
```
Redis Cache:
- Product catalog (rarely changes)
- User session data
- Order status (cache recent orders)

Cache strategy:
- Write-through for product updates
- Cache-aside for reads
- TTL: 10 minutes for products
```

### Trade-offs to Discuss

**1. Sync vs Async order processing:**
- Sync: Immediate confirmation, longer response time
- Async: Fast response, eventual consistency
- Chose async for better UX and scalability

**2. Strong vs Eventual consistency:**
- Inventory: Strong (can't oversell)
- Order status: Eventual (async updates okay)
- Payments: Strong (ACID transactions)

**3. Event Sourcing vs CRUD:**
- Event Sourcing: Complete audit trail, complex queries
- CRUD: Simpler, no historical reconstruction
- Chose Event Sourcing for compliance and debugging

**4. Monolith vs Microservices:**
- Monolith: Simpler, single deployment
- Microservices: Independent scaling, complex orchestration
- Recommendation: Start monolith, extract services as needed

---

## Evaluation Criteria Interviewers Use

### What Interviewers Look For

**1. Requirements Gathering (20%)**
- Asks clarifying questions
- States assumptions clearly
- Defines scope appropriately
- Identifies constraints

**2. High-Level Design (25%)**
- Identifies major components
- Explains data flow
- Draws clear diagrams
- Considers user experience

**3. Deep Dive (30%)**
- Discusses trade-offs thoughtfully
- Knows when to use specific technologies
- Addresses scalability proactively
- Handles edge cases

**4. Communication (15%)**
- Explains thinking clearly
- Uses appropriate terminology
- Listens to feedback
- Adjusts based on hints

**5. Problem-Solving (10%)**
- Structured approach
- Breaks down complex problems
- Identifies potential issues
- Proposes solutions

### Red Flags

1. **Jumping to Solution**
   - Not asking questions
   - Assuming requirements
   - Over-engineering from the start

2. **Lack of Trade-off Discussion**
   - "We should use microservices" (without justification)
   - Not considering alternatives
   - One-size-fits-all mentality

3. **Ignoring Constraints**
   - Not considering cost
   - Ignoring scale requirements
   - Over-complicating simple problems

4. **Poor Communication**
   - Long silences
   - Unclear explanations
   - Not listening to interviewer

5. **Unrealistic Designs**
   - No consideration for failure scenarios
   - Ignoring operational complexity
   - Not addressing monitoring/logging

### How to Excel

**1. Think Aloud**
```
"I'm considering using Cosmos DB here because we need global distribution and the data model is flexible. However, Azure SQL would also work if we don't need multi-region writes. What are your thoughts on the geographic distribution requirement?"
```

**2. Discuss Trade-offs**
```
"For caching, I could use:
- Redis: Better performance, managed service, higher cost
- In-memory: Simpler, cheaper, but lost on restart

Given the read-heavy nature and need for high availability, I'd recommend Redis."
```

**3. Address Scale Proactively**
```
"At 10K requests/second, we'd need:
- Auto-scaling App Service (2-20 instances)
- Database read replicas
- CDN for static content
- Caching to reduce database load by 80%"
```

**4. Consider Operations**
```
"We'd need:
- Application Insights for monitoring
- Log Analytics for centralized logging
- Alerts on error rate, latency, and availability
- Health check endpoints for auto-scaling"
```

**5. Be Pragmatic**
```
"For MVP, I'd start with a simpler architecture:
- Single-region deployment
- Azure SQL without read replicas
- Basic caching

Then scale based on actual usage patterns. This saves cost and complexity while we validate the product."
```

---

## Final Tips

### Before the Interview
- Review common Azure services
- Practice drawing diagrams
- Prepare back-of-envelope calculations
- Review CAP theorem, consistency models
- Be ready to discuss projects you've worked on

### During the Interview
- Ask questions early and often
- State assumptions clearly
- Draw diagrams (even in virtual interviews, use shared whiteboard)
- Think aloud
- Be open to feedback
- Don't be afraid to change your approach

### After the Interview
- Summarize your design briefly
- Mention what you'd add with more time
- Ask about their current architecture (shows interest)

### Remember
- There's no single "correct" design
- Interviewers want to see your thought process
- It's okay to say "I'm not sure, but here's how I'd find out"
- Be honest about what you know and don't know
- System design is a conversation, not a test

Good luck!
