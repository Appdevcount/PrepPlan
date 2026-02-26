# Azure Cosmos DB – Complete End-to-End Guide (for .NET Developers)

> Single-source study guide to become productive and confident with Azure Cosmos DB (API for NoSQL) using .NET.

---

## Table of Contents

1. **Mental Model & Big Picture**  
2. **Core Concepts & Terminology**  
3. **When to Use Cosmos DB (vs Other Datastores)**  
4. **Prerequisites, Tooling & Setup**  
5. **Creating Cosmos Resources with Azure CLI & Portal**  
6. **.NET SDK Setup (Azure.Cosmos)**  
7. **Data Modeling & Partitioning (API for NoSQL)**  
8. **CRUD Operations with .NET SDK**  
9. **Querying with SQL & LINQ (and Continuation Tokens)**  
10. **Throughput, RU/s, and Scaling (Manual, Autoscale, Serverless)**  
11. **Indexing, Consistency Levels, and Multi-Region**  
12. **Transactions, Stored Procedures, Triggers, and UDFs**  
13. **Change Feed & Event-Driven Architectures**  
14. **Security, Networking, and Connection Configuration**  
15. **Diagnostics, Logging, and Troubleshooting**  
16. **Real-World Cosmos DB Challenges (20) & Solutions**  
17. **Sample Document Structures & Query Patterns**  
18. **Interview Questions for .NET Developers (Cosmos-Focused)**  
19. **Quick Reference Cheat Sheet (Commands, SDK Snippets)**  

> This guide focuses on **Azure Cosmos DB for NoSQL** (the SQL API). Other APIs (Mongo, Table, Cassandra, Gremlin) exist but are not the primary focus here.

---

## 1. Mental Model & Big Picture

### 1.1 Simple Mental Model

Think of Azure Cosmos DB (API for NoSQL) as:

> **Globally distributed, horizontally scalable, low-latency JSON document database with tunable consistency and request-unit based throughput.**

Key ideas:

- **JSON documents** – You store schema-free JSON objects ("items").
- **Containers** – Logical collections of JSON items (similar to tables/collections). Each container has a **partition key**.
- **Logical partitions** – Group of items that share the same partition key value, stored and scaled together.
- **Physical partitions** – Internal units of storage/throughput. Many logical partitions are mapped to each physical partition.
- **Request Units (RU)** – Normalized cost unit for reads, writes, and queries.
- **Multi-region** – Write/read from multiple regions with well-defined consistency guarantees.

Visual mental model:

```text
Cosmos DB Account
  └── Database(s)
        └── Container(s)
              └── Item(s) (JSON documents)
                    └── Property 'partitionKey' decides which logical partition

RU/s (throughput) is allocated at container or database level and consumed by operations.
```

### 1.2 How Cosmos Differs from SQL Server

- **No fixed schema** – Cosmos stores arbitrary JSON; schema is managed at the application level.
- **Partitioning is mandatory** – You must choose a partition key for scalable containers.
- **No joins across containers** – You typically denormalize and embed related data.
- **Request Units** – You think in terms of RU cost instead of CPU/IO.
- **Global distribution** – Built-in multi-region writes and reads.

---

## 2. Core Concepts & Terminology

### 2.1 Account, Database, Container, Item

- **Account** – Top-level resource tied to an Azure subscription & region(s).  
- **Database** – Logical grouping of containers. Can have shared throughput for containers.  
- **Container** – Schema-free collection of JSON items. Requires:
  - `id` (container name)  
  - `/partitionKeyPath` (e.g., `/customerId`)  
  - Indexing policy, TTL, etc.  
- **Item** – A JSON document with an `id` and partition key property.

### 2.2 Partition Key & Logical Partitions

- Partition key is a **path in the JSON** (e.g., `/tenantId`, `/category`).
- All items with the same partition key value belong to one **logical partition**.
- Logical partitions are mapped to **physical partitions** automatically.
- Good partition keys:
  - High cardinality (many distinct values).  
  - Even access distribution (avoid hotspots).  
  - Commonly used in query filters and joins (inside same partition).

### 2.3 Request Units (RU)

- Every operation consumes RUs: reads, writes, queries, stored procedures.
- **Point read (by id + partition key)** is cheapest (~1 RU for 1 KB docs).  
- Queries that scan, sort, or cross partitions cost more RUs.
- Throttling (HTTP 429) occurs when RU/s usage exceeds provisioned throughput.

### 2.4 Consistency Levels

For Cosmos DB account:

- **Strong** – Linearizability. Highest consistency, highest RU and latency.  
- **Bounded Staleness** – Reads lag behind writes by `K` versions or `T` time.  
- **Session (default)** – Causal consistency per client session; good balance.  
- **Consistent Prefix** – Reads never see out-of-order writes.  
- **Eventual** – Lowest guarantees, best performance.

You can override consistency **per request** in the .NET SDK.

---

## 3. When to Use Cosmos DB (vs Other Datastores)

Use Cosmos DB when:

- You need **low-latency reads/writes at global scale**.  
- You want **automated horizontal scaling** for large volumes.  
- You handle **operational data** (telemetry, user profiles, IoT events, shopping carts, etc.).  
- You need **multi-region** active-active or active-passive configurations.

You might prefer:

- **Azure SQL / PostgreSQL** for relational workloads, complex joins, transactions across many entities.  
- **Azure Table Storage** for extremely cheap, simple key-value with no need for global distribution.

---

## 4. Prerequisites, Tooling & Setup

### 4.1 Tools

Make sure these are available:

```bash
az --version              # Azure CLI
# Optional: Azure Cosmos DB Emulator (for local dev)
# .NET SDK (8.0 or later recommended)
dotnet --version
```

Install the .NET Cosmos DB SDK package in your project:

```bash
dotnet add package Azure.Cosmos
```

### 4.2 Azure Login & Subscription

```bash
az login
az account list -o table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

---

## 5. Creating Cosmos Resources with Azure CLI & Portal

### 5.1 Create Resource Group

```bash
RESOURCE_GROUP="rg-cosmos-demo"
LOCATION="eastus"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

Sample output (shape):

```json
{
  "name": "rg-cosmos-demo",
  "location": "eastus",
  "properties": { "provisioningState": "Succeeded" }
}
```

### 5.2 Create Cosmos DB Account (API for NoSQL)

```bash
COSMOS_ACCOUNT="cosmos-demo-12345"   # must be globally unique

az cosmosdb create \
  --name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --locations regionName=$LOCATION failoverPriority=0 \
  --kind GlobalDocumentDB
```

### 5.3 Create Database & Container

```bash
DB_NAME="demo-db"
CONTAINER_NAME="orders"
PARTITION_KEY="/customerId"

# Create database
az cosmosdb sql database create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --name $DB_NAME

# Create container with provisioned throughput
az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --database-name $DB_NAME \
  --name $CONTAINER_NAME \
  --partition-key-path $PARTITION_KEY \
  --throughput 400
```

### 5.4 Get Connection Info

```bash
PRIMARY_KEY=$(az cosmosdb keys list \
  --name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --type keys \
  --query primaryMasterKey -o tsv)

ENDPOINT=$(az cosmosdb show \
  --name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query documentEndpoint -o tsv)

echo $ENDPOINT
# Example: https://cosmos-demo-12345.documents.azure.com:443/
```

Use `ENDPOINT` and `PRIMARY_KEY` in local dev, or prefer **Managed Identity** / `DefaultAzureCredential` in production.

---

## 6. .NET SDK Setup (Azure.Cosmos)

### 6.1 Basic Client Initialization

```csharp
using Azure.Cosmos;

// Typically, read endpoint and key from configuration / Key Vault
string endpoint = builder.Configuration["Cosmos:Endpoint"]!;
string key      = builder.Configuration["Cosmos:Key"]!;

// CosmosClient is designed to be a singleton for the whole app
CosmosClientOptions options = new CosmosClientOptions
{
    ApplicationName = "SimpleCosmosDemo",      // Helps identify in diagnostics
    AllowBulkExecution = true,                  // Enables bulk ops pattern
};

CosmosClient cosmosClient = new CosmosClient(endpoint, key, options);

// Get a reference to the database and container (will be created later if needed)
CosmosDatabase database = cosmosClient.GetDatabase("demo-db");
CosmosContainer container = database.GetContainer("orders");
```

### 6.2 Using DefaultAzureCredential (Managed Identity)

In production, prefer **passwordless** auth:

```csharp
using Azure.Cosmos;
using Azure.Identity;

var endpoint = builder.Configuration["Cosmos:Endpoint"]!; // Only endpoint is needed

var credential = new DefaultAzureCredential();

CosmosClient cosmosClient = new CosmosClient(endpoint, credential, new CosmosClientOptions
{
    ApplicationName = "SimpleCosmosDemo",
});
```

> Ensure your app’s **managed identity** has `Cosmos DB Built-in Data Contributor` role at the Cosmos account or database scope.

---

## 7. Data Modeling & Partitioning (API for NoSQL)

### 7.1 Example Domain – E-commerce Orders

We’ll use an **orders** container with documents like:

```json
{
  "id": "order_123",
  "customerId": "cust_42",          // partition key
  "orderDateUtc": "2024-10-01T12:34:56Z",
  "status": "Placed",
  "totalAmount": 149.99,
  "currency": "USD",
  "items": [
    { "sku": "SKU100", "name": "Keyboard", "quantity": 1, "price": 49.99 },
    { "sku": "SKU200", "name": "Mouse",    "quantity": 2, "price": 50.00 }
  ],
  "shippingAddress": {
    "line1": "123 Main St",
    "city": "Seattle",
    "country": "US"
  }
}
```

### 7.2 Choosing a Partition Key

For the `orders` container:

- **Good partition key**: `/customerId`
  - Spreads orders across customers.  
  - Most queries are scoped by customer (e.g., "get orders for a customer").  
  - Single customer’s data stays within one logical partition (helpful for per-customer transactions, aggregations).

Bad choices:

- `/country` – too few distinct values, can create hot partitions.  
- `/status` – a few values (`Placed`, `Shipped`, `Cancelled`).

### 7.3 Modeling Relationships

- **Embed** child data that is always loaded with the parent (e.g., `items` inside `order`).  
- **Reference** using IDs when data is shared or very large (e.g., reference `productId` and look up from a `products` container when necessary).

### 7.4 Hierarchical Partition Key Patterns

For complex applications (multi-tenant SaaS, time-series data, organizational hierarchies), you may need **hierarchical or synthetic partition keys**.

#### 7.4.1 Synthetic Compound Keys

Create a partition key by combining multiple logical levels:

```csharp
// Pattern 1: Tenant + User (Multi-tenant SaaS)
string partitionKey = $"{tenantId}#{userId}";
// Examples: "tenant_1#user_42", "tenant_1#user_99"

// Pattern 2: Category + Year-Month (Time-series with categories)
string partitionKey = $"{category}#{orderDate:yyyy-MM}";
// Examples: "electronics#2024-10", "clothing#2024-11"

// Pattern 3: Region + Store (Geographic hierarchy)
string partitionKey = $"{region}#{storeId}";
// Examples: "us-west#store_123", "eu-central#store_456"

// Pattern 4: Department + Employee (Organizational hierarchy)
string partitionKey = $"{departmentCode}#{employeeId}";
// Examples: "ENG#emp_001", "SALES#emp_002"
```

#### 7.4.2 Document Structure with Hierarchical Keys

```json
{
  "id": "order_12345",
  "partitionKey": "tenant_1#user_42",
  "tenantId": "tenant_1",
  "userId": "user_42",
  "orderDateUtc": "2024-10-01T10:00:00Z",
  "status": "Placed",
  "totalAmount": 149.99,
  "items": [
    { "sku": "SKU100", "quantity": 1, "price": 49.99 }
  ]
}
```

```csharp
// Domain model
record Order(
    string id,
    string tenantId,
    string userId,
    DateTime orderDateUtc,
    string status,
    double totalAmount)
{
    // Computed property for partition key
    public string PartitionKey => $"{tenantId}#{userId}";
}

// Usage
var order = new Order(
    id: Guid.NewGuid().ToString(),
    tenantId: "tenant_1",
    userId: "user_42",
    orderDateUtc: DateTime.UtcNow,
    status: "Placed",
    totalAmount: 149.99);

await container.CreateItemAsync(order, new PartitionKey(order.PartitionKey));
```

#### 7.4.3 Query Patterns with Hierarchical Keys

**Query 1: All orders for specific tenant + user (single partition)**

```csharp
string pk = $"{tenantId}#{userId}";

var query = new QueryDefinition(
    "SELECT * FROM c WHERE c.partitionKey = @pk ORDER BY c.orderDateUtc DESC")
    .WithParameter("@pk", pk);

FeedIterator<Order> iterator = container.GetItemQueryIterator<Order>(
    query,
    requestOptions: new QueryRequestOptions
    {
        PartitionKey = new PartitionKey(pk), // Very efficient - single partition
        MaxItemCount = 50
    });
```

**Query 2: All orders for a tenant (cross-partition across users)**

```csharp
// More expensive - scans multiple partitions
var query = new QueryDefinition(
    "SELECT * FROM c WHERE STARTSWITH(c.partitionKey, @tenantPrefix)")
    .WithParameter("@tenantPrefix", "tenant_1#");

FeedIterator<Order> iterator = container.GetItemQueryIterator<Order>(
    query,
    requestOptions: new QueryRequestOptions
    {
        MaxConcurrency = -1, // Parallelize across partitions
        MaxItemCount = 100
    });
```

**Query 3: Aggregation within tenant**

```sql
-- Total sales per user within tenant (requires cross-partition query)
SELECT 
    c.userId,
    SUM(c.totalAmount) AS totalSales,
    COUNT(1) AS orderCount
FROM c
WHERE STARTSWITH(c.partitionKey, "tenant_1#")
GROUP BY c.userId
```

#### 7.4.4 Use Cases and Trade-offs

**Use Case 1: Multi-Tenant SaaS Application**

```csharp
// Partition key: tenantId#userId
public record UserProfile(
    string id,
    string tenantId,
    string userId,
    string email,
    List<string> roles)
{
    public string PartitionKey => $"{tenantId}#{userId}";
}

// ✅ Pros:
// - Perfect data isolation per tenant+user
// - Efficient single-partition reads
// - Transactional operations within partition
// - Easy to implement row-level security

// ⚠️ Cons:
// - Cross-user queries within tenant are expensive
// - Reporting/analytics needs separate aggregation
// - May need secondary containers for tenant-wide data
```

**Use Case 2: Time-Series Data with Categories**

```csharp
// Partition key: category#yyyyMM
public record TelemetryEvent(
    string id,
    string category,
    DateTime timestampUtc,
    Dictionary<string, object> metrics)
{
    public string PartitionKey => $"{category}#{timestampUtc:yyyy-MM}";
}

// ✅ Pros:
// - Natural time-based partitioning
// - Queries within category+month are fast
// - Old partitions can use TTL for auto-deletion
// - Good for IoT, logging, monitoring use cases

// ⚠️ Cons:
// - Cross-month queries are expensive
// - Hot partitions if current month has high traffic
// - Need to handle month boundaries carefully
```

**Use Case 3: Geographic Hierarchy**

```csharp
// Partition key: region#storeId
public record Sale(
    string id,
    string region,
    string storeId,
    DateTime saleTimestamp,
    decimal amount)
{
    public string PartitionKey => $"{region}#{storeId}";
}

// ✅ Pros:
// - Queries scoped to store are very efficient
// - Regional queries possible (though cross-partition)
// - Aligns with business structure

// ⚠️ Cons:
// - Global aggregations require full scan
// - Uneven store sizes = uneven partition sizes
```

#### 7.4.5 Migration Strategy for Hierarchical Keys

If you need to change from simple to hierarchical partition keys:

**Step 1: Create New Container**

```bash
az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --database-name $DB_NAME \
  --name orders-v2 \
  --partition-key-path /partitionKey \
  --throughput 400
```

**Step 2: Migrate Data with Change Feed**

```csharp
ChangeFeedProcessor migrationProcessor = oldContainer
    .GetChangeFeedProcessorBuilder<Order>(
        "migration-processor",
        async (IReadOnlyCollection<Order> changes, CancellationToken ct) =>
        {
            foreach (var order in changes)
            {
                // Transform to new structure
                var newOrder = order with
                {
                    PartitionKey = $"{order.tenantId}#{order.userId}"
                };

                // Write to new container
                await newContainer.UpsertItemAsync(
                    newOrder,
                    new PartitionKey(newOrder.PartitionKey),
                    cancellationToken: ct);
            }
        })
    .WithLeaseContainer(leaseContainer)
    .WithStartTime(DateTime.MinValue) // Start from beginning
    .Build();

await migrationProcessor.StartAsync();
```

**Step 3: Dual-Write Period**

Write to both containers during transition:

```csharp
public async Task CreateOrderAsync(Order order)
{
    // Write to old container (existing partition key)
    await oldContainer.CreateItemAsync(order, new PartitionKey(order.customerId));

    // Also write to new container (new partition key)
    var newOrder = order with { PartitionKey = $"{order.tenantId}#{order.userId}" };
    await newContainer.CreateItemAsync(newOrder, new PartitionKey(newOrder.PartitionKey));
}
```

**Step 4: Switch Reads to New Container**

Once migration completes, update application to read from new container.

**Step 5: Decommission Old Container**

After validation period, delete old container.

#### 7.4.6 Best Practices

1. **Delimiter Choice**: Use `#` or `|` or `::` - avoid characters in your data
2. **Cardinality**: Ensure compound key still has high cardinality
3. **Query Patterns**: Design partition key based on 80% of your queries
4. **Max Size**: Partition key value max 2KB; keep compound keys reasonably short
5. **Immutability**: Partition keys can't be changed; plan carefully
6. **Testing**: Load test with production-like data distribution
7. **Documentation**: Document partition key strategy for team

#### 7.4.7 Anti-Patterns to Avoid

❌ **Too Many Levels**: `tenant#region#store#dept#user` (too complex)  
❌ **Low Cardinality**: `{country}#{status}` (only ~200 combinations globally)  
❌ **Timestamp at Start**: `{yyyyMMdd}#{tenantId}` (creates hot partitions on current day)  
❌ **User-Specific + High Write**: `{userId}` for global write-heavy app (hot partitions)  
❌ **No Business Meaning**: Random GUIDs (can't optimize queries)  

---

## 8. CRUD Operations with .NET SDK

Assume you have:

```csharp
record Order(
    string id,
    string customerId,
    DateTime orderDateUtc,
    string status,
    double totalAmount,
    string currency);
```

### 8.1 Create Item

```csharp
// Build a sample order
var order = new Order(
    id: Guid.NewGuid().ToString(),
    customerId: "cust_42",
    orderDateUtc: DateTime.UtcNow,
    status: "Placed",
    totalAmount: 149.99,
    currency: "USD");

// Partition key must match the container's partition key path (/customerId)
PartitionKey pk = new(order.customerId);

ItemResponse<Order> createResponse = await container.CreateItemAsync(order, pk);

Console.WriteLine($"Created order with RU charge: {createResponse.RequestCharge}");
Console.WriteLine($"ActivityId: {createResponse.ActivityId}");
```

### 8.2 Read Item (Point Read)

```csharp
string orderId = order.id;           // Known id
string customerId = order.customerId; // Known partition key value

ItemResponse<Order> readResponse = await container.ReadItemAsync<Order>(
    id: orderId,
    partitionKey: new PartitionKey(customerId));

Order existingOrder = readResponse.Resource;
Console.WriteLine($"Order status: {existingOrder.status}");
```

### 8.3 Replace Item (Update)

```csharp
// Update status and replace the whole document
Order updatedOrder = existingOrder with { status = "Shipped" };

ItemResponse<Order> replaceResponse = await container.ReplaceItemAsync(
    item: updatedOrder,
    id: updatedOrder.id,
    partitionKey: new PartitionKey(updatedOrder.customerId));

Console.WriteLine($"Updated order. New status: {replaceResponse.Resource.status}");
```

### 8.4 Upsert Item

```csharp
// Upsert = insert if not exists, replace if exists
Order upsertedOrder = existingOrder with { totalAmount = 199.99 };

ItemResponse<Order> upsertResponse = await container.UpsertItemAsync(
    item: upsertedOrder,
    partitionKey: new PartitionKey(upsertedOrder.customerId));

Console.WriteLine($"Upsert RU charge: {upsertResponse.RequestCharge}");
```

### 8.5 Delete Item

```csharp
await container.DeleteItemAsync<Order>(
    id: orderId,
    partitionKey: new PartitionKey(customerId));

Console.WriteLine($"Deleted order {orderId} for customer {customerId}.");
```

---

## 9. Querying with SQL & LINQ (and Continuation Tokens)

### 9.1 Simple SQL Query

```csharp
// Get all orders for a specific customer ordered by date descending
string sql = "SELECT * FROM c WHERE c.customerId = @customerId ORDER BY c.orderDateUtc DESC";

QueryDefinition queryDef = new QueryDefinition(sql)
    .WithParameter("@customerId", "cust_42");

FeedIterator<Order> iterator = container.GetItemQueryIterator<Order>(queryDef);

while (iterator.HasMoreResults)
{
    FeedResponse<Order> page = await iterator.ReadNextAsync();

    Console.WriteLine($"Page RU charge: {page.RequestCharge}");

    foreach (Order o in page)
    {
        Console.WriteLine($"Order {o.id} status {o.status}");
    }
}
```

### 9.2 Continuation Tokens (Pagination)

Cosmos uses **continuation tokens** to page through results efficiently.

```csharp
string continuationToken = null;        // Start with null to get first page
int pageSize = 10;                      // Page size

QueryDefinition pagedQuery = new QueryDefinition(
    "SELECT * FROM c WHERE c.customerId = @customerId ORDER BY c.orderDateUtc DESC")
    .WithParameter("@customerId", "cust_42");

// Loop page-by-page
do
{
    FeedIterator<Order> feedIterator = container.GetItemQueryIterator<Order>(
        pagedQuery,
        continuationToken: continuationToken,
        requestOptions: new QueryRequestOptions
        {
            MaxItemCount = pageSize,
            PartitionKey = new PartitionKey("cust_42") // if known, helps RU and perf
        });

    if (!feedIterator.HasMoreResults)
    {
        break;
    }

    FeedResponse<Order> response = await feedIterator.ReadNextAsync();

    Console.WriteLine($"Fetched {response.Count} items, RU: {response.RequestCharge}");

    foreach (Order o in response)
    {
        Console.WriteLine($"Order {o.id} total {o.totalAmount}");
    }

    // Store continuation token (e.g., return to client, persist for later)
    continuationToken = response.ContinuationToken;

} while (continuationToken != null);
```

> Use continuation tokens when building server-side pagination APIs. You can return them to clients (e.g., `nextPageToken`) instead of exposing `skip/take` or `OFFSET/FETCH` which are inefficient.

### 9.2.1 Building Paginated Web APIs with Continuation Tokens

**Scenario**: ASP.NET Core API endpoint that returns paginated orders to a React/Angular/Vue frontend.

#### Response DTO Pattern

```csharp
public record PagedResponse<T>(
    List<T> Items,
    string? NextPageToken,
    bool HasMore,
    int PageSize,
    PaginationMetadata Metadata);

public record PaginationMetadata(
    double RequestCharge,
    int ItemCount,
    string? ActivityId);
```

#### API Controller Implementation

```csharp
using Microsoft.AspNetCore.Mvc;
using System.Text;

[ApiController]
[Route("api/customers/{customerId}/orders")]
public class OrdersController : ControllerBase
{
    private readonly CosmosContainer _container;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(CosmosContainer container, ILogger<OrdersController> logger)
    {
        _container = container;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResponse<Order>>> GetOrders(
        string customerId,
        [FromQuery] string? pageToken = null,
        [FromQuery] int pageSize = 20)
    {
        // Validate page size
        if (pageSize < 1 || pageSize > 100)
        {
            return BadRequest("Page size must be between 1 and 100");
        }

        try
        {
            // Decode continuation token (URL-safe Base64)
            string? continuationToken = string.IsNullOrEmpty(pageToken)
                ? null
                : DecodeToken(pageToken);

            var query = new QueryDefinition(
                "SELECT * FROM c WHERE c.customerId = @customerId ORDER BY c.orderDateUtc DESC")
                .WithParameter("@customerId", customerId);

            FeedIterator<Order> iterator = _container.GetItemQueryIterator<Order>(
                query,
                continuationToken: continuationToken,
                requestOptions: new QueryRequestOptions
                {
                    MaxItemCount = pageSize,
                    PartitionKey = new PartitionKey(customerId)
                });

            if (!iterator.HasMoreResults)
            {
                return Ok(new PagedResponse<Order>(
                    Items: new List<Order>(),
                    NextPageToken: null,
                    HasMore: false,
                    PageSize: pageSize,
                    Metadata: new PaginationMetadata(0, 0, null)));
            }

            FeedResponse<Order> response = await iterator.ReadNextAsync();

            // Encode continuation token for URL safety
            string? nextPageToken = response.ContinuationToken != null
                ? EncodeToken(response.ContinuationToken)
                : null;

            _logger.LogInformation(
                "Fetched {Count} orders for customer {CustomerId}, RU: {RU}",
                response.Count, customerId, response.RequestCharge);

            return Ok(new PagedResponse<Order>(
                Items: response.ToList(),
                NextPageToken: nextPageToken,
                HasMore: nextPageToken != null,
                PageSize: pageSize,
                Metadata: new PaginationMetadata(
                    RequestCharge: response.RequestCharge,
                    ItemCount: response.Count,
                    ActivityId: response.ActivityId)));
        }
        catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.BadRequest)
        {
            _logger.LogWarning("Invalid continuation token provided");
            return BadRequest("Invalid page token. Please start from the first page.");
        }
    }

    // URL-safe Base64 encoding (replace +/ with -_ and remove padding)
    private string EncodeToken(string token) =>
        Convert.ToBase64String(Encoding.UTF8.GetBytes(token))
            .Replace('+', '-')
            .Replace('/', '_')
            .TrimEnd('=');

    private string DecodeToken(string encodedToken)
    {
        // Restore padding and standard Base64 characters
        string base64 = encodedToken
            .Replace('-', '+')
            .Replace('_', '/');

        int padding = (4 - (base64.Length % 4)) % 4;
        base64 = base64.PadRight(base64.Length + padding, '=');

        return Encoding.UTF8.GetString(Convert.FromBase64String(base64));
    }
}
```

#### Frontend Consumption (TypeScript/JavaScript)

```typescript
interface Order {
  id: string;
  customerId: string;
  orderDateUtc: string;
  status: string;
  totalAmount: number;
  currency: string;
}

interface PagedResponse<T> {
  items: T[];
  nextPageToken: string | null;
  hasMore: boolean;
  pageSize: number;
  metadata: {
    requestCharge: number;
    itemCount: number;
    activityId: string | null;
  };
}

// Fetcher function
async function fetchOrders(
  customerId: string,
  pageToken?: string
): Promise<PagedResponse<Order>> {
  const params = new URLSearchParams({ pageSize: '20' });
  if (pageToken) {
    params.append('pageToken', pageToken);
  }

  const response = await fetch(
    `/api/customers/${customerId}/orders?${params}`,
    {
      headers: { 'Accept': 'application/json' }
    }
  );

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${await response.text()}`);
  }

  return response.json();
}

// Usage Pattern 1: Infinite Scroll
class InfiniteScrollOrders {
  private currentToken: string | null = null;
  private allOrders: Order[] = [];
  private loading = false;

  async loadMoreOrders(customerId: string): Promise<void> {
    if (this.loading) return;

    this.loading = true;
    try {
      const result = await fetchOrders(
        customerId,
        this.currentToken ?? undefined
      );

      this.allOrders.push(...result.items);
      this.currentToken = result.nextPageToken;

      console.log(`Loaded ${result.items.length} orders, RU: ${result.metadata.requestCharge}`);

      if (!result.hasMore) {
        console.log('All orders loaded');
      }
    } finally {
      this.loading = false;
    }
  }

  hasMore(): boolean {
    return this.currentToken !== null;
  }
}

// Usage Pattern 2: Traditional Page-by-Page Navigation
class PagedOrdersList {
  private tokenHistory: (string | null)[] = [null]; // Stack of tokens for back navigation
  private currentPageIndex = 0;
  private currentOrders: Order[] = [];

  async loadPage(customerId: string, direction: 'next' | 'previous' | 'first'): Promise<void> {
    if (direction === 'first') {
      this.tokenHistory = [null];
      this.currentPageIndex = 0;
    } else if (direction === 'previous' && this.currentPageIndex > 0) {
      this.currentPageIndex--;
      const token = this.tokenHistory[this.currentPageIndex];
      const result = await fetchOrders(customerId, token ?? undefined);
      this.currentOrders = result.items;
      return;
    } else if (direction === 'next') {
      const token = this.tokenHistory[this.currentPageIndex + 1];
      const result = await fetchOrders(customerId, token ?? undefined);
      this.currentOrders = result.items;

      if (result.nextPageToken && this.tokenHistory.length === this.currentPageIndex + 1) {
        this.tokenHistory.push(result.nextPageToken);
      }
      this.currentPageIndex++;
      return;
    }

    // Load first page
    const result = await fetchOrders(customerId);
    this.currentOrders = result.items;

    if (result.nextPageToken) {
      this.tokenHistory.push(result.nextPageToken);
    }
  }

  canGoPrevious(): boolean {
    return this.currentPageIndex > 0;
  }

  canGoNext(): boolean {
    return this.tokenHistory.length > this.currentPageIndex + 1;
  }
}

// Usage example in a React component (pseudo-code)
function OrdersComponent({ customerId }: { customerId: string }) {
  const [orders, setOrders] = React.useState<Order[]>([]);
  const [pageToken, setPageToken] = React.useState<string | null>(null);
  const [hasMore, setHasMore] = React.useState(true);

  const loadMore = async () => {
    const result = await fetchOrders(customerId, pageToken ?? undefined);
    setOrders(prev => [...prev, ...result.items]);
    setPageToken(result.nextPageToken);
    setHasMore(result.hasMore);
  };

  return (
    <div>
      {orders.map(order => (
        <div key={order.id}>{order.id} - ${order.totalAmount}</div>
      ))}
      {hasMore && <button onClick={loadMore}>Load More</button>}
    </div>
  );
}
```

#### Best Practices for Continuation Tokens

1. **Security Considerations**:
   - Continuation tokens are **opaque** but may contain sensitive info
   - Use HTTPS to prevent token interception
   - Consider encrypting tokens if they traverse untrusted clients
   - Set short expiration if storing tokens server-side

2. **Error Handling**:
   - Tokens can expire or become invalid (Cosmos returns 400)
   - Always handle invalid token errors gracefully
   - Provide "Start Over" option in UI

3. **Caching Strategy**:
   - Can cache pages with tokens for short duration (1-5 min)
   - Include Cache-Control headers: `Cache-Control: private, max-age=60`
   - Invalidate cache on data mutations

4. **Performance**:
   - Specify `PartitionKey` in `QueryRequestOptions` when known (reduces RU cost)
   - Use appropriate `MaxItemCount` (10-100 is typical)
   - Monitor RU consumption via `response.RequestCharge`

5. **UX Patterns**:
   - **Infinite Scroll**: Best for mobile, feeds, timelines
   - **Traditional Pagination**: Best for tables, search results with known context
   - **Load More Button**: Best for performance-conscious apps

### 9.3 Cross-Partition Queries

If your query does not specify a partition key or partition key range, Cosmos may perform a **cross-partition** query.

```csharp
var query = new QueryDefinition("SELECT * FROM c WHERE c.status = 'Placed'");

FeedIterator<Order> crossPartitionIterator = container.GetItemQueryIterator<Order>(
    query,
    requestOptions: new QueryRequestOptions
    {
        MaxConcurrency = -1,  // Let SDK parallelize across partitions
        MaxItemCount = 100
    });
```

Use cross-partition queries sparingly for high-volume workloads; prefer queries scoped to a single partition when possible.

### 9.4 LINQ Queries

`Azure.Cosmos` supports a subset of LINQ, translated to Cosmos SQL.

```csharp
IQueryable<Order> queryable = container.GetItemLinqQueryable<Order>(allowSynchronousQueryExecution: false);

var linqQuery = queryable
    .Where(o => o.customerId == "cust_42" && o.status == "Placed")
    .OrderByDescending(o => o.orderDateUtc)
    .Take(20);

using FeedIterator<Order> iteratorLinq = linqQuery.ToFeedIterator();

while (iteratorLinq.HasMoreResults)
{
    FeedResponse<Order> response = await iteratorLinq.ReadNextAsync();

    foreach (Order o in response)
    {
        Console.WriteLine($"LINQ order {o.id}");
    }
}
```

### 9.5 Complete Pagination Patterns: DB to UI Architecture

This section covers end-to-end patterns for implementing production-grade pagination from Cosmos DB through your API layer to the frontend.

#### 9.5.1 Architecture Overview

```text
┌─────────────┐      ┌──────────────┐      ┌─────────────┐      ┌────────────┐
│             │      │              │      │             │      │            │
│  Frontend   │─────▶│  Web API     │─────▶│  Cosmos DB  │──────│  Physical  │
│  (React/    │◀─────│  (ASP.NET    │◀─────│  Container  │      │  Partitions│
│   Angular)  │      │   Core)      │      │             │      │            │
│             │      │              │      │             │      │            │
└─────────────┘      └──────────────┘      └─────────────┘      └────────────┘
     │                     │                      │
     │ GET /orders?        │ Query with           │
     │ pageToken=xyz       │ continuation token   │
     │                     │                      │
     │◀────────────────────│◀─────────────────────│
     │ { items: [...],     │ FeedResponse<T>      │
     │   nextPageToken,    │ + ContinuationToken  │
     │   hasMore }         │                      │
```

#### 9.5.2 Stateless vs Stateful Pagination

**Stateless Pagination (Recommended)**

- Client holds continuation token
- Server doesn't store pagination state
- Horizontally scalable (any server can handle request)
- Token travels in query string or request body

```csharp
// Stateless approach - token from client
[HttpGet("orders")]
public async Task<PagedResponse<Order>> GetOrders(
    [FromQuery] string? pageToken,
    [FromQuery] int pageSize = 20)
{
    string? token = pageToken != null ? DecodeToken(pageToken) : null;
    // Query Cosmos with token...
}
```

**Stateful Pagination (Session-based)**

- Server stores token in session/cache (Redis)
- Client only knows "page number"
- More complex but can support page numbers
- Requires sticky sessions or distributed cache

```csharp
public record PaginationSession(
    string QueryId,
    Dictionary<int, string> PageTokens,
    DateTime CreatedAt);

// Stateful approach - tokens cached server-side
[HttpGet("orders")]
public async Task<PagedResponse<Order>> GetOrdersStateful(
    [FromQuery] string sessionId,
    [FromQuery] int pageNumber = 1)
{
    // Retrieve session from Redis
    var session = await _cache.GetAsync<PaginationSession>($"pagination:{sessionId}");

    if (session == null || (DateTime.UtcNow - session.CreatedAt).TotalMinutes > 10)
    {
        // Session expired or invalid
        return BadRequest("Session expired. Please start a new query.");
    }

    string? token = session.PageTokens.GetValueOrDefault(pageNumber - 1);

    var result = await QueryWithToken(token);

    // Store next page token
    if (result.ContinuationToken != null)
    {
        session.PageTokens[pageNumber] = result.ContinuationToken;
        await _cache.SetAsync($"pagination:{sessionId}", session, TimeSpan.FromMinutes(10));
    }

    return BuildResponse(result, pageNumber);
}
```

#### 9.5.3 Bi-Directional Pagination (Previous/Next)

**Challenge**: Cosmos continuation tokens are **forward-only**. To support "Previous" button:

**Solution 1: Client-Side Token Stack**

```typescript
class PaginationNavigator {
  private tokenStack: (string | null)[] = [null]; // Stack of tokens
  private currentIndex = 0;

  async goNext(fetchFn: (token?: string) => Promise<PagedResponse<any>>): Promise<void> {
    const currentToken = this.tokenStack[this.currentIndex];
    const result = await fetchFn(currentToken ?? undefined);

    // Save next token if available
    if (result.nextPageToken) {
      if (this.tokenStack.length === this.currentIndex + 1) {
        this.tokenStack.push(result.nextPageToken);
      }
    }

    this.currentIndex++;
  }

  async goPrevious(fetchFn: (token?: string) => Promise<PagedResponse<any>>): Promise<void> {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      const token = this.tokenStack[this.currentIndex];
      await fetchFn(token ?? undefined);
    }
  }

  canGoPrevious(): boolean {
    return this.currentIndex > 0;
  }

  canGoNext(): boolean {
    return this.tokenStack.length > this.currentIndex + 1;
  }
}
```

**Solution 2: Server-Side Token Cache (Redis)**

```csharp
public interface IPaginationCache
{
    Task StoreTokenAsync(string sessionId, int pageNumber, string token, TimeSpan ttl);
    Task<string?> GetTokenAsync(string sessionId, int pageNumber);
}

[HttpGet("orders/paged")]
public async Task<ActionResult<PagedResponse<Order>>> GetOrdersPaged(
    [FromQuery] string sessionId,
    [FromQuery] int page = 1)
{
    if (page < 1) return BadRequest("Page must be >= 1");

    // Get token for requested page
    string? token = page == 1
        ? null
        : await _paginationCache.GetTokenAsync(sessionId, page - 1);

    var response = await QueryCosmosAsync(token);

    // Cache token for next page
    if (response.ContinuationToken != null)
    {
        await _paginationCache.StoreTokenAsync(
            sessionId,
            page,
            response.ContinuationToken,
            TimeSpan.FromMinutes(15));
    }

    return Ok(new PagedResponse<Order>(
        Items: response.ToList(),
        NextPageToken: page.ToString(), // Just page number to client
        HasMore: response.ContinuationToken != null,
        PageSize: response.Count,
        Metadata: new PaginationMetadata(
            response.RequestCharge,
            response.Count,
            response.ActivityId)));
}
```

#### 9.5.4 Pagination with Filtering and Search

**Challenge**: Continuation tokens are tied to the original query. Changing filters invalidates the token.

**Solution**: Encode filter parameters in session/token management.

```csharp
public record QueryContext(
    string CustomerId,
    string? StatusFilter,
    DateTime? FromDate,
    DateTime? ToDate);

public record PaginationState(
    string ContinuationToken,
    QueryContext Context,
    DateTime CreatedAt);

[HttpGet("orders/search")]
public async Task<PagedResponse<Order>> SearchOrders(
    [FromQuery] string customerId,
    [FromQuery] string? status,
    [FromQuery] DateTime? fromDate,
    [FromQuery] DateTime? toDate,
    [FromQuery] string? pageToken)
{
    QueryContext currentContext = new(customerId, status, fromDate, toDate);

    PaginationState? state = null;
    if (!string.IsNullOrEmpty(pageToken))
    {
        state = DecodeAndValidatePaginationState(pageToken);

        // Verify query context hasn't changed
        if (state?.Context != currentContext)
        {
            // Filters changed - restart from beginning
            _logger.LogWarning("Query context changed, restarting pagination");
            state = null;
        }
    }

    // Build dynamic query based on filters
    var queryBuilder = new StringBuilder("SELECT * FROM c WHERE c.customerId = @customerId");
    var queryDef = new QueryDefinition(queryBuilder.ToString())
        .WithParameter("@customerId", customerId);

    if (!string.IsNullOrEmpty(status))
    {
        queryBuilder.Append(" AND c.status = @status");
        queryDef = queryDef.WithParameter("@status", status);
    }

    if (fromDate.HasValue)
    {
        queryBuilder.Append(" AND c.orderDateUtc >= @fromDate");
        queryDef = queryDef.WithParameter("@fromDate", fromDate.Value);
    }

    queryBuilder.Append(" ORDER BY c.orderDateUtc DESC");

    FeedIterator<Order> iterator = _container.GetItemQueryIterator<Order>(
        new QueryDefinition(queryBuilder.ToString()),
        continuationToken: state?.ContinuationToken,
        requestOptions: new QueryRequestOptions
        {
            MaxItemCount = 20,
            PartitionKey = new PartitionKey(customerId)
        });

    var response = await iterator.ReadNextAsync();

    // Encode continuation token with context
    string? nextToken = response.ContinuationToken != null
        ? EncodePaginationState(new PaginationState(
            response.ContinuationToken,
            currentContext,
            DateTime.UtcNow))
        : null;

    return new PagedResponse<Order>(
        response.ToList(),
        nextToken,
        response.ContinuationToken != null,
        20,
        new PaginationMetadata(response.RequestCharge, response.Count, response.ActivityId));
}
```

#### 9.5.5 Infinite Scroll Implementation

**Frontend Pattern (React with Intersection Observer)**:

```typescript
import { useEffect, useRef, useState } from 'react';

function useInfiniteScroll(
  customerId: string,
  pageSize: number = 20
) {
  const [orders, setOrders] = useState<Order[]>([]);
  const [pageToken, setPageToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);

  const loadMore = async () => {
    if (loading || !hasMore) return;

    setLoading(true);
    try {
      const result = await fetchOrders(customerId, pageToken ?? undefined);
      setOrders(prev => [...prev, ...result.items]);
      setPageToken(result.nextPageToken);
      setHasMore(result.hasMore);
    } catch (error) {
      console.error('Failed to load orders:', error);
    } finally {
      setLoading(false);
    }
  };

  return { orders, loading, hasMore, loadMore };
}

function OrdersList({ customerId }: { customerId: string }) {
  const { orders, loading, hasMore, loadMore } = useInfiniteScroll(customerId);
  const observerTarget = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      entries => {
        if (entries[0].isIntersecting && hasMore && !loading) {
          loadMore();
        }
      },
      { threshold: 1.0 }
    );

    if (observerTarget.current) {
      observer.observe(observerTarget.current);
    }

    return () => observer.disconnect();
  }, [hasMore, loading, loadMore]);

  return (
    <div>
      {orders.map(order => (
        <OrderCard key={order.id} order={order} />
      ))}
      {loading && <div>Loading more...</div>}
      <div ref={observerTarget} style={{ height: '20px' }} />
      {!hasMore && <div>No more orders</div>}
    </div>
  );
}
```

#### 9.5.6 Performance Optimization

**1. Prefetching Next Page**:

```typescript
class PrefetchingPaginator {
  private cache = new Map<string, PagedResponse<any>>();

  async getCurrentPage(token: string | null): Promise<PagedResponse<Order>> {
    const cacheKey = token ?? 'first';

    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey)!;
    }

    const result = await fetchOrders('cust_42', token ?? undefined);
    this.cache.set(cacheKey, result);

    // Prefetch next page in background
    if (result.nextPageToken) {
      this.prefetchInBackground(result.nextPageToken);
    }

    return result;
  }

  private async prefetchInBackground(token: string): Promise<void> {
    setTimeout(async () => {
      try {
        const result = await fetchOrders('cust_42', token);
        this.cache.set(token, result);
      } catch (error) {
        console.warn('Prefetch failed:', error);
      }
    }, 100); // Small delay to avoid blocking current render
  }
}
```

**2. Request Coalescing**:

```csharp
public class CoalescedPaginationService
{
    private readonly SemaphoreSlim _semaphore = new(1, 1);
    private readonly Dictionary<string, Task<FeedResponse<Order>>> _inFlightRequests = new();

    public async Task<FeedResponse<Order>> GetPageAsync(string cacheKey, Func<Task<FeedResponse<Order>>> queryFn)
    {
        await _semaphore.WaitAsync();
        try
        {
            // If identical request is in-flight, reuse it
            if (_inFlightRequests.TryGetValue(cacheKey, out var existingTask))
            {
                return await existingTask;
            }

            var task = queryFn();
            _inFlightRequests[cacheKey] = task;

            try
            {
                return await task;
            }
            finally
            {
                _inFlightRequests.Remove(cacheKey);
            }
        }
        finally
        {
            _semaphore.Release();
        }
    }
}
```

#### 9.5.7 Error Handling Best Practices

```csharp
[HttpGet("orders")]
public async Task<ActionResult<PagedResponse<Order>>> GetOrdersWithErrorHandling(
    string customerId,
    [FromQuery] string? pageToken)
{
    try
    {
        string? token = pageToken != null ? DecodeToken(pageToken) : null;

        var response = await _container.GetItemQueryIterator<Order>(
            new QueryDefinition("SELECT * FROM c WHERE c.customerId = @cid")
                .WithParameter("@cid", customerId),
            continuationToken: token,
            requestOptions: new QueryRequestOptions
            {
                MaxItemCount = 20,
                PartitionKey = new PartitionKey(customerId)
            }
        ).ReadNextAsync();

        return Ok(BuildPagedResponse(response));
    }
    catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.BadRequest)
    {
        _logger.LogWarning(ex, "Invalid continuation token");
        return BadRequest(new ProblemDetails
        {
            Title = "Invalid Page Token",
            Detail = "The continuation token is invalid or expired. Please restart from the first page.",
            Status = 400,
            Instance = HttpContext.Request.Path
        });
    }
    catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.TooManyRequests)
    {
        _logger.LogWarning(ex, "Rate limited by Cosmos DB");
        return StatusCode(429, new ProblemDetails
        {
            Title = "Too Many Requests",
            Detail = "Please retry after a short delay.",
            Status = 429,
            Extensions = { ["Retry-After"] = "5" }
        });
    }
    catch (CosmosException ex)
    {
        _logger.LogError(ex, "Cosmos DB error during pagination");
        return StatusCode(500, new ProblemDetails
        {
            Title = "Database Error",
            Status = 500
        });
    }
}
```

#### 9.5.8 Monitoring and Metrics

```csharp
public class PaginationMetricsService
{
    private readonly ILogger<PaginationMetricsService> _logger;

    public void RecordPageLoad(
        string endpoint,
        int pageSize,
        double ruCharge,
        int itemCount,
        TimeSpan duration)
    {
        // Log structured metrics
        _logger.LogInformation(
            "Pagination metrics: Endpoint={Endpoint}, PageSize={PageSize}, " +
            "RU={RU}, Items={Items}, Duration={Duration}ms",
            endpoint, pageSize, ruCharge, itemCount, duration.TotalMilliseconds);

        // Send to Application Insights or Prometheus
        // metrics.RecordHistogram("pagination_duration_ms", duration.TotalMilliseconds);
        // metrics.RecordCounter("pagination_ru_total", ruCharge);
    }
}
```

**Key Metrics to Track**:
- Average RU per page
- Average latency per page load
- Percentage of invalid token errors
- Cache hit rate (if using caching)
- Pages loaded per session
- Abandonment rate (users who don't complete pagination)

---

## 10. Throughput, RU/s, and Scaling

### 10.1 Provisioned Throughput vs Autoscale vs Serverless

- **Provisioned throughput** – Fixed RU/s (e.g., 400 RU/s) billed hourly. Good predictability.  
- **Autoscale** – RU/s automatically scales between 10%–100% of a max (e.g., 400–4000). Good for variable workloads.  
- **Serverless** – Pay-per-request. Good for sporadic/low traffic workloads.

### 10.2 Changing Throughput with Azure CLI

```bash
# Update container throughput to 1000 RU/s
az cosmosdb sql container throughput update \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --database-name $DB_NAME \
  --name $CONTAINER_NAME \
  --throughput 1000
```

### 10.3 RU Budgeting Mental Model

- Estimate RU per operation (use diagnostics or emulator).  
- Multiply by expected operations per second.  
- Add safety margin (20–30%).  
- Use **autoscale** if traffic is spiky.

---

## 11. Indexing, Consistency Levels, and Multi-Region

### 11.1 Indexing Deep Dive

Cosmos DB indexing is critical for query performance and RU cost optimization. This section covers all indexing patterns in depth.

#### 11.1.1 Default Indexing Policy

By default, Cosmos DB:
- Indexes **all properties** automatically
- Uses **range indexes** for strings and numbers
- Uses **consistent** indexing mode (synchronous)
- Applies to all items in the container

Default policy (JSON):

```json
{
  "indexingMode": "consistent",
  "automatic": true,
  "includedPaths": [
    {
      "path": "/*"
    }
  ],
  "excludedPaths": [
    {
      "path": "/\"_etag\"/?"  // System property excluded
    }
  ]
}
```

**When Default Works Well**:
- Small datasets (< 100K items)
- Unknown query patterns
- Prototyping phase
- Read-heavy workloads with simple queries

**When to Customize**:
- Large documents with many properties
- Write-heavy workloads (indexing costs RUs)
- Specific query patterns known upfront
- Properties with large values (arrays, nested objects)

#### 11.1.2 Composite Indexes (Multi-Property Optimization)

Composite indexes optimize queries with multiple ORDER BY clauses or filters on multiple properties.

**Problem Without Composite Index**:

```sql
-- This query is expensive without composite index
SELECT * FROM c 
WHERE c.customerId = 'cust_42' 
ORDER BY c.status ASC, c.orderDateUtc DESC
```

**Solution: Add Composite Index**:

```json
{
  "indexingMode": "consistent",
  "automatic": true,
  "includedPaths": [{ "path": "/*" }],
  "excludedPaths": [{ "path": "/\"_etag\"/?" }],
  "compositeIndexes": [
    [
      { "path": "/customerId", "order": "ascending" },
      { "path": "/status", "order": "ascending" },
      { "path": "/orderDateUtc", "order": "descending" }
    ],
    [
      { "path": "/status", "order": "ascending" },
      { "path": "/totalAmount", "order": "descending" }
    ]
  ]
}
```

**Setting Composite Index via Azure CLI**:

```bash
# Create JSON file: composite-index.json
cat > composite-index.json << 'EOF'
{
  "indexingMode": "consistent",
  "automatic": true,
  "includedPaths": [{ "path": "/*" }],
  "excludedPaths": [{ "path": "/\"_etag\"/?" }],
  "compositeIndexes": [
    [
      { "path": "/customerId", "order": "ascending" },
      { "path": "/orderDateUtc", "order": "descending" }
    ]
  ]
}
EOF

az cosmosdb sql container update \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --database-name $DB_NAME \
  --name $CONTAINER_NAME \
  --idx @composite-index.json
```

**Setting via .NET SDK (Container Creation)**:

```csharp
var containerProperties = new ContainerProperties
{
    Id = "orders",
    PartitionKeyPath = "/customerId",
    IndexingPolicy = new IndexingPolicy
    {
        IndexingMode = IndexingMode.Consistent,
        Automatic = true,
        IncludedPaths = { new IncludedPath { Path = "/*" } },
        ExcludedPaths = { new ExcludedPath { Path = "/\"_etag\"/?" } },
        CompositeIndexes =
        {
            new Collection<CompositePath>
            {
                new CompositePath { Path = "/customerId", Order = CompositePathSortOrder.Ascending },
                new CompositePath { Path = "/orderDateUtc", Order = CompositePathSortOrder.Descending }
            },
            new Collection<CompositePath>
            {
                new CompositePath { Path = "/status", Order = CompositePathSortOrder.Ascending },
                new CompositePath { Path = "/totalAmount", Order = CompositePathSortOrder.Descending }
            }
        }
    }
};

await database.CreateContainerIfNotExistsAsync(containerProperties, throughput: 400);
```

**Composite Index Benefits**:
- ✅ Up to 10x RU reduction for ORDER BY queries
- ✅ Enables efficient multi-filter queries
- ✅ Supports both ASC and DESC orderings
- ✅ Required for ORDER BY on multiple properties

**Composite Index Rules**:
- Maximum 100 composite indexes per container
- Maximum 10 paths per composite index
- Order matters: `/a, /b` is different from `/b, /a`
- Must match query's ORDER BY sequence exactly
- Can combine with filters

#### 11.1.3 Spatial Indexes (Geospatial Queries)

For location-based queries (distance, within polygon, etc.).

**Document with GeoJSON**:

```json
{
  "id": "store_123",
  "name": "Seattle Downtown",
  "location": {
    "type": "Point",
    "coordinates": [-122.3321, 47.6062]
  },
  "serviceRadius": 5000
}
```

**Indexing Policy with Spatial Index**:

```json
{
  "indexingMode": "consistent",
  "automatic": true,
  "includedPaths": [
    { "path": "/*" }
  ],
  "excludedPaths": [
    { "path": "/\"_etag\"/?" }
  ],
  "spatialIndexes": [
    {
      "path": "/location/*",
      "types": ["Point", "Polygon", "LineString"]
    }
  ]
}
```

**Geospatial Queries**:

```sql
-- Find stores within 10km of a point
SELECT * FROM c
WHERE ST_DISTANCE(c.location, {
  "type": "Point",
  "coordinates": [-122.3321, 47.6062]
}) < 10000

-- Find stores within a polygon (delivery zone)
SELECT * FROM c
WHERE ST_WITHIN(c.location, {
  "type": "Polygon",
  "coordinates": [[
    [-122.5, 47.5],
    [-122.5, 47.7],
    [-122.1, 47.7],
    [-122.1, 47.5],
    [-122.5, 47.5]
  ]]
})
```

**.NET SDK Spatial Query**:

```csharp
using Microsoft.Azure.Cosmos.Spatial;

var point = new Point(-122.3321, 47.6062);

var query = new QueryDefinition(
    @"SELECT c.id, c.name, ST_DISTANCE(c.location, @point) AS distance 
      FROM c 
      WHERE ST_DISTANCE(c.location, @point) < @maxDistance
      ORDER BY ST_DISTANCE(c.location, @point)")
    .WithParameter("@point", point)
    .WithParameter("@maxDistance", 10000);

var iterator = container.GetItemQueryIterator<dynamic>(query);
```

#### 11.1.4 Wildcard and Array Indexing

**Wildcard Path Indexing**:

Index all properties under a path without specifying each one:

```json
{
  "indexingMode": "consistent",
  "includedPaths": [
    { "path": "/metadata/*" },      // Index all properties under metadata
    { "path": "/tags/[]/*/" },      // Index all array elements and their properties
    { "path": "/attributes/?" }      // Index only the attributes property itself
  ],
  "excludedPaths": [
    { "path": "/largePayload/*" }   // Exclude everything under largePayload
  ]
}
```

**Path Patterns**:
- `/*` = all properties at root level and nested
- `/propertyName/*` = all nested properties under propertyName
- `/propertyName/?` = only the property itself, not nested
- `/array/[]/*` = all elements in array and their properties

**Array Indexing Example**:

```json
{
  "id": "order_123",
  "customerId": "cust_42",
  "items": [
    { "sku": "SKU100", "category": "electronics", "price": 49.99 },
    { "sku": "SKU200", "category": "accessories", "price": 19.99 }
  ],
  "tags": ["bulk", "priority", "express"]
}
```

**Query arrays with ARRAY_CONTAINS**:

```sql
-- Find orders with specific tag
SELECT * FROM c WHERE ARRAY_CONTAINS(c.tags, "priority")

-- Find orders with items in category
SELECT * FROM c 
WHERE EXISTS(
  SELECT VALUE item 
  FROM item IN c.items 
  WHERE item.category = "electronics"
)
```

**Indexing policy for arrays**:

```json
{
  "indexingMode": "consistent",
  "includedPaths": [
    { "path": "/*" },
    { "path": "/items/[]/category/?" },   // Index category in items array
    { "path": "/items/[]/sku/?" },        // Index SKU in items array
    { "path": "/tags/[]/?" }              // Index tag array elements
  ],
  "excludedPaths": [
    { "path": "/items/[]/description/*" } // Exclude descriptions
  ]
}
```

#### 11.1.5 Included vs Excluded Paths Strategy

**Strategy 1: Include-All, Exclude Specific (Default)**

Good for: Dynamic schemas, most properties queried

```json
{
  "includedPaths": [{ "path": "/*" }],
  "excludedPaths": [
    { "path": "/\"_etag\"/?" },
    { "path": "/largeBlob/*" },
    { "path": "/auditLog/*" },
    { "path": "/internalMetadata/*" }
  ]
}
```

**Strategy 2: Exclude-All, Include Specific (Write-Optimized)**

Good for: Known query patterns, write-heavy, large documents

```json
{
  "includedPaths": [
    { "path": "/customerId/?" },
    { "path": "/status/?" },
    { "path": "/orderDateUtc/?" },
    { "path": "/totalAmount/?" }
  ],
  "excludedPaths": [
    { "path": "/*" }  // Exclude everything not explicitly included
  ]
}
```

**RU Impact Comparison**:

| Scenario | Included Paths | Excluded Paths | Write RU Impact |
|----------|---------------|----------------|------------------|
| Default (all indexed) | `/*` | `/_etag` | Baseline |
| Exclude large fields | `/*` | `/largeBlob/*`, `/auditLog/*` | -20% to -40% |
| Include only queried | `/id/?`, `/status/?` | `/*` | -60% to -80% |

#### 11.1.6 Index Metrics and Performance Analysis

**View Index Metrics in Query Diagnostics**:

```csharp
var query = new QueryDefinition(
    "SELECT * FROM c WHERE c.status = @status ORDER BY c.orderDateUtc DESC")
    .WithParameter("@status", "Placed");

var iterator = container.GetItemQueryIterator<Order>(
    query,
    requestOptions: new QueryRequestOptions
    {
        MaxItemCount = 50,
        PopulateIndexMetrics = true  // Enable index metrics
    });

var response = await iterator.ReadNextAsync();

Console.WriteLine($"Index Metrics: {response.IndexMetrics}");
Console.WriteLine($"RU Charge: {response.RequestCharge}");
```

**Sample Index Metrics Output**:

```
Index Utilization: Used indexes: [SingleField: /status], Scanned: 1000 docs, Returned: 100 docs
Index Metrics: Utilized Single Indexes: [{"FilterExpression":"Equality match on /status","IndexDocumentExpression":"/status","IndexImpactScore":"High"}]
```

**Analyze Query Plan (Portal)**:
1. Navigate to Cosmos account → Data Explorer
2. Run query with "Enable query metrics"
3. Check "Index Hit" percentage
4. Review "Retrieved Document Count" vs "Output Document Count"

**Key Metrics**:
- **Index Hit Ratio**: Should be > 90% for efficient queries
- **Retrieved vs Output Count**: Large ratio indicates scanning
- **RU Charge**: Compare with/without index to measure impact

#### 11.1.7 Complete Indexing Policy Example (Production)

```json
{
  "indexingMode": "consistent",
  "automatic": true,
  "includedPaths": [
    { "path": "/*" }
  ],
  "excludedPaths": [
    { "path": "/\"_etag\"/?" },
    { "path": "/largePayload/*" },
    { "path": "/internalMetadata/*" },
    { "path": "/auditTrail/[]/*" }
  ],
  "compositeIndexes": [
    [
      { "path": "/tenantId", "order": "ascending" },
      { "path": "/userId", "order": "ascending" },
      { "path": "/createdAt", "order": "descending" }
    ],
    [
      { "path": "/status", "order": "ascending" },
      { "path": "/priority", "order": "descending" },
      { "path": "/dueDate", "order": "ascending" }
    ],
    [
      { "path": "/category", "order": "ascending" },
      { "path": "/totalAmount", "order": "descending" }
    ]
  ],
  "spatialIndexes": [
    {
      "path": "/location/*",
      "types": ["Point"]
    },
    {
      "path": "/serviceArea/*",
      "types": ["Polygon"]
    }
  ]
}
```

**.NET SDK: Update Existing Container's Index Policy**:

```csharp
public async Task UpdateIndexingPolicyAsync(CosmosContainer container)
{
    // Read existing container properties
    var containerResponse = await container.ReadContainerAsync();
    var properties = containerResponse.Resource;

    // Modify indexing policy
    properties.IndexingPolicy = new IndexingPolicy
    {
        IndexingMode = IndexingMode.Consistent,
        Automatic = true,
        IncludedPaths = { new IncludedPath { Path = "/*" } },
        ExcludedPaths = 
        { 
            new ExcludedPath { Path = "/\"_etag\"/?" },
            new ExcludedPath { Path = "/largeBlob/*" }
        },
        CompositeIndexes =
        {
            new Collection<CompositePath>
            {
                new CompositePath { Path = "/customerId", Order = CompositePathSortOrder.Ascending },
                new CompositePath { Path = "/orderDateUtc", Order = CompositePathSortOrder.Descending }
            }
        }
    };

    // Replace container (index rebuild happens asynchronously)
    await container.ReplaceContainerAsync(properties);

    Console.WriteLine("Indexing policy updated. Index rebuild in progress...");
}
```

**Note**: Index policy changes trigger **asynchronous reindexing**. Check progress:

```bash
az cosmosdb sql container show \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --database-name $DB_NAME \
  --name $CONTAINER_NAME \
  --query 'resource.indexingPolicy'
```

#### 11.1.8 Indexing Best Practices Summary

**DO**:
✅ Start with default policy, optimize based on real query patterns  
✅ Add composite indexes for multi-property ORDER BY  
✅ Exclude large properties not used in queries (blobs, long text)  
✅ Use spatial indexes for geolocation queries  
✅ Monitor RU costs before/after index changes  
✅ Test with production-like data volumes  
✅ Include partition key in queries when possible  

**DON'T**:
❌ Over-index - every index costs write RUs  
❌ Exclude properties you query on (causes scan)  
❌ Forget to update indexes when adding new query patterns  
❌ Use `indexingMode: "none"` unless truly write-only container  
❌ Create too many composite indexes (max 100, but review each)  
❌ Ignore index metrics during performance troubleshooting  

**Trade-off Summary**:

| More Indexing | Less Indexing |
|---------------|---------------|
| ✅ Faster queries | ✅ Faster writes |
| ✅ Lower query RU | ✅ Lower write RU |
| ❌ Higher write RU | ❌ Higher query RU |
| ❌ Larger storage | ✅ Smaller storage |

**Rule of Thumb**: If a property appears in `WHERE`, `ORDER BY`, `JOIN`, or `GROUP BY`, it should be indexed.

### 11.2 Consistency Levels (Revisited)

In the SDK you can override per request:

```csharp
using Azure.Cosmos;

// Override consistency for a single read
ItemRequestOptions strongReadOptions = new ItemRequestOptions
{
    ConsistencyLevel = ConsistencyLevel.Strong
};

ItemResponse<Order> strongRead = await container.ReadItemAsync<Order>(
    id: orderId,
    partitionKey: new PartitionKey(customerId),
    requestOptions: strongReadOptions);
```

### 11.3 Multi-Region & Failover

- Add regions using Azure Portal or CLI.  
- Choose **multi-region writes** or **single-region write, multi-region read**.  
- Use preferred regions in the client to minimize latency.

```csharp
CosmosClientOptions multiRegionOptions = new CosmosClientOptions
{
    ApplicationPreferredRegions = new List<string> { "East US", "West Europe" }
};

CosmosClient client = new CosmosClient(endpoint, key, multiRegionOptions);
```

---

## 12. Transactions, Stored Procedures, Triggers, and UDFs

### 12.1 Transactions with Bulk Operations and Patch

Transactions in Cosmos DB are **scoped to a single logical partition**.

In .NET you can use **transactional batch**:

```csharp
PartitionKey pk = new("cust_42");

TransactionalBatch batch = container.CreateTransactionalBatch(pk)
    .CreateItem(new { id = "order_200", customerId = "cust_42", status = "Placed" })
    .ReplaceItem("order_123", new { id = "order_123", customerId = "cust_42", status = "Cancelled" });

TransactionalBatchResponse batchResponse = await batch.ExecuteAsync();

if (!batchResponse.IsSuccessStatusCode)
{
    Console.WriteLine($"Batch failed with status: {batchResponse.StatusCode}");
}
```

### 12.2 Stored Procedures (JavaScript)

Stored procedures run server-side in the Cosmos engine.

Example (conceptual) stored procedure `spCreateOrderAndLog` in JavaScript:

```javascript
function spCreateOrderAndLog(order, logEntry) {
    var context = getContext();
    var collection = context.getCollection();

    // Create order document
    var accepted = collection.createDocument(collection.getSelfLink(), order, function (err, orderDoc) {
        if (err) throw err;

        // Create log document only if order creation succeeds
        var acceptedLog = collection.createDocument(collection.getSelfLink(), logEntry, function (err2) {
            if (err2) throw err2;
        });

        if (!acceptedLog) throw new Error("Log doc creation not accepted");
    });

    if (!accepted) throw new Error("Order doc creation not accepted");
}
```

Called from .NET:

```csharp
var sprocId = "spCreateOrderAndLog";

var orderDoc = new { id = "order_300", customerId = "cust_42", status = "Placed" };
var logEntry = new { id = "log_1", type = "OrderCreated", orderId = "order_300" };

StoredProcedureExecuteResponse<dynamic> sprocResponse = await container.Scripts.ExecuteStoredProcedureAsync<dynamic>(
    sprocId,
    partitionKey: new PartitionKey("cust_42"),
    parameters: new[] { orderDoc, logEntry });
```

> Stored procedures, triggers, and UDFs are written in JavaScript; use them for server-side logic within a partition.

---

## 13. Change Feed & Event-Driven Architectures

Change feed gives you an **ordered log of changes** (inserts and updates) for a container.

### 13.1 Pull Model with .NET SDK

```csharp
ChangeFeedProcessor changeFeedProcessor = container.GetChangeFeedProcessorBuilder<Order>(
        processorName: "orders-processor",
        onChangesDelegate: async (IReadOnlyCollection<Order> changes, CancellationToken cancellationToken) =>
        {
            foreach (Order changedOrder in changes)
            {
                // Handle new/updated orders here (e.g., send event, update cache)
                Console.WriteLine($"Change feed: order {changedOrder.id} status {changedOrder.status}");
            }
        })
    .WithInstanceName("worker-1")
    .WithLeaseContainer(database.GetContainer("leases")) // a second container for leases
    .Build();

await changeFeedProcessor.StartAsync();

// Later, when shutting down
await changeFeedProcessor.StopAsync();
```

- **Lease container** tracks progress; partitioned the same way as source container.
- Scale out by running processors on multiple instances (they coordinate via leases).

---

## 14. Security, Networking, and Connection Configuration

- Use **managed identities** instead of primary keys in production.  
- Restrict network access with **private endpoints** or **IP firewalls**.  
- Use **TLS (HTTPS)** connections only.  
- Configure **connection mode**:
  - Direct (TCP) – best performance, default for production.  
  - Gateway (HTTPS) – simpler networking, less performant.

```csharp
CosmosClientOptions secureOptions = new CosmosClientOptions
{
    ConnectionMode = ConnectionMode.Direct,     // or ConnectionMode.Gateway
    LimitToEndpoint = true                      // Do not auto-discover other regions
};

CosmosClient secureClient = new CosmosClient(endpoint, credential, secureOptions);
```

---

## 15. Diagnostics, Logging, and Troubleshooting

### 15.1 Diagnostics on Responses

```csharp
FeedResponse<Order> response = await iterator.ReadNextAsync();

Console.WriteLine($"ActivityId: {response.ActivityId}");
Console.WriteLine($"RequestCharge: {response.RequestCharge}");
Console.WriteLine($"Diagnostics: {response.Diagnostics}");
```

- `Diagnostics` shows timing, retries, and server contact info.  
- Use it during development to tune queries and partitioning.

### 15.2 Handling 429 (Request Rate Too Large)

The SDK automatically **retries** on 429 with exponential backoff. You can tune retry options:

```csharp
CosmosClientOptions tunedOptions = new CosmosClientOptions
{
    ApplicationName = "TunedClient",
    ThrottlingRetryOptions = new ThrottlingRetryOptions
    {
        MaxRetryAttemptsOnThrottledRequests = 9,      // default 9
        MaxRetryWaitTimeOnThrottledRequests = TimeSpan.FromSeconds(30)
    }
};
```

Additionally, you should **reduce RU consumption** by optimizing queries and partition keys.

### 15.3 Common Error Types

- `429` – Throttling; increase RU or optimize workload.  
- `404` – Item not found; verify id + partition key.  
- `412` – Precondition failed when using ETags for concurrency.  
- `503` – Service unavailable; transient, retry with backoff.

---

## 16. Real-World Cosmos DB Challenges (20) & Solutions

Below are 20 realistic Cosmos-specific challenges, with patterns and sample .NET snippets.

> These are meant as **learning patterns**. In real apps, combine them with logging, metrics, and defensive programming.

### Challenge 1: Hot Partition and Frequent 429s

**Symptom:** Throttling (429) mostly for items with the same partition key.

**Root Cause:** Poor partition key choice; too many requests hitting a small set of logical partitions.

**Solution:**

- Redesign partition key (e.g., use `/customerId` instead of `/country`).  
- Introduce **synthetic keys** when needed (e.g., `/customerRegionId` or `/category#yyyyMM`).

Code pattern to create synthetic key:

```csharp
string syntheticPk = $"{order.customerId}#{order.orderDateUtc:yyyyMM}";  // spreads orders by month
```

Update container partition key accordingly and migrate data (e.g., via change feed or migration script).

---

### Challenge 2: High RU Cost for Queries

**Symptom:** Queries consuming hundreds or thousands of RU/s.

**Root Cause:**

- Scanning too many documents (no partition key filter).  
- Over-indexing (indexing large fields not used in queries).  
- Using `SELECT *` instead of projecting specific fields.

**Solutions:**

- Always filter by partition key when possible.
- Use **projections**:

```csharp
var definition = new QueryDefinition(
    "SELECT c.id, c.status, c.totalAmount FROM c WHERE c.customerId = @customerId")
    .WithParameter("@customerId", "cust_42");
```

- Customize indexing to exclude unused fields.

---

### Challenge 3: Cross-Partition ORDER BY Slow

**Symptom:** Query with `ORDER BY` over all partitions is slow and expensive.

**Root Cause:** ORDER BY across partitions requires more work and RUs.

**Solution:**

- Scope queries to a single partition when ordering is required.  
- Or add **composite indexes** for fields used together in ORDER BY.

```json
{
  "compositeIndexes": [
    [
      { "path": "/customerId", "order": "ascending" },
      { "path": "/orderDateUtc", "order": "descending" }
    ]
  ]
}
```

---

### Challenge 4: Large Documents (> 2 MB)

**Symptom:** Writes fail because items exceed maximum document size.

**Solution:**

- Store large blobs in **Azure Blob Storage**, keep only references (URLs, metadata) in Cosmos.

```json
{
  "id": "order_123",
  "customerId": "cust_42",
  "invoiceBlobUrl": "https://account.blob.core.windows.net/invoices/123.pdf"
}
```

---

### Challenge 5: Concurrency Conflicts (Last Write Wins)

**Symptom:** Multiple writers overwrite each other’s updates.

**Solution:** Use **ETags** for optimistic concurrency.

```csharp
ItemResponse<Order> read = await container.ReadItemAsync<Order>(
    orderId,
    new PartitionKey(customerId));

Order current = read.Resource;
string etag = read.ETag;  // existing version

Order updated = current with { status = "Cancelled" };

ItemRequestOptions opts = new ItemRequestOptions
{
    IfMatchEtag = etag    // only update if ETag matches
};

try
{
    ItemResponse<Order> replaced = await container.ReplaceItemAsync(
        updated,
        updated.id,
        new PartitionKey(updated.customerId),
        opts);
}
catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.PreconditionFailed)
{
    // Another writer changed the doc; reload and merge
}
```

---

### Challenge 6: Migrating Partition Keys

**Symptom:** Need to change partition key design after going to production.

**Solution:**

- Create **new container** with the new partition key.  
- Use **change feed** or custom scripts to read from old container, transform, and write into new one.  
- Swap consumers to the new container and decommission old.

---

### Challenge 7: High Latency from Certain Regions

**Symptom:** Clients in a specific region see higher latency.

**Solution:**

- Add Cosmos replica in that region and configure **preferred regions** in the client.  
- For multi-region writes, ensure multi-write is enabled and use nearest region preference.

```csharp
CosmosClientOptions geoOptions = new CosmosClientOptions
{
    ApplicationPreferredRegions = new List<string> { "West Europe", "East US" }
};
```

---

### Challenge 8: Timeouts and Transient Errors

**Symptom:** Occasional timeouts on heavy load.

**Solution:**

- Tune `RequestTimeout` and retry policies.  
- Ensure enough RU/s.  
- Use `MaxConcurrentOperations` for bulk operations.

```csharp
CosmosClientOptions timeoutOptions = new CosmosClientOptions
{
    RequestTimeout = TimeSpan.FromSeconds(10)
};
```

---

### Challenge 9: Inefficient `OFFSET LIMIT` Pagination

**Symptom:** Using `OFFSET`/`LIMIT` pattern causes slow and expensive pagination.

**Solution:** Use **continuation tokens** instead.

Pattern:

- First request: `continuationToken = null`.  
- Next pages: use `response.ContinuationToken`.

(See Section 9.2 for full code.)

---

### Challenge 10: Mixed API Usage (SQL + Mongo)

**Symptom:** Confusion and errors when trying to use Mongo driver against SQL API endpoint.

**Solution:**

- Each account is created with a specific API type (NoSQL/SQL, Mongo, etc.).  
- Ensure you use the correct **SDK and endpoint** for the chosen API.

---

### Challenge 11: Leases Container Too Small for Change Feed

**Symptom:** Change feed processor stalls or rebalances poorly.

**Solution:**

- Make sure **lease container** has sufficient throughput and partitions.  
- Use same partition key path as source or a high-cardinality key.

---

### Challenge 12: Missing Indexes and Slow Queries

**Symptom:** Queries are slow, and RU charge is high.

**Solution:**

- Inspect query plan (via portal or diagnostics).  
- Add or adjust indexes; remove unused indexes to reduce RU on writes.

---

### Challenge 13: TTL and Data Retention

**Symptom:** Data grows unbounded, increasing cost.

**Solution:**

- Enable **Time to Live (TTL)** at the container or item level.  
- Items automatically expire and are deleted after configured seconds.

```json
{
  "defaultTtl": 2592000   // 30 days in seconds
}
```

---

### Challenge 14: Multi-Tenant Design

**Symptom:** Need to store multiple tenants efficiently.

**Solution:**

- Use `/tenantId` as part of partition key (e.g., `/tenantId`) or synthetic key.  
- Optionally include `tenantId` in item `id` to avoid collisions.

```json
{
  "id": "tenant_1:order_123",
  "tenantId": "tenant_1",
  "customerId": "cust_42"
}
```

---

### Challenge 15: Large Fan-Out Queries for Analytics

**Symptom:** Need complex analytics across entire data set.

**Solution:**

- Export data from Cosmos to **Azure Synapse / Data Lake** using **Change Feed** or Data Integration tools.  
- Use Cosmos for operational workload; analytics platform for heavy reporting.

---

### Challenge 16: SDK Version Mismatches

**Symptom:** Using outdated SDK leads to missing features or performance issues.

**Solution:**

- Standardize on latest Azure.Cosmos version; keep dependencies up to date.  
- Use **`Azure.Cosmos`** (v3+) rather than legacy `Microsoft.Azure.DocumentDB`.

---

### Challenge 17: Partition Key in URL Routing (Microservices)

**Symptom:** Microservice endpoints do not expose partition key, causing inefficient queries.

**Solution:**

- Include partition key in route design:

```csharp
// Example minimal API route: /customers/{customerId}/orders/{orderId}
app.MapGet("/customers/{customerId}/orders/{orderId}", async (
    string customerId,
    string orderId,
    CosmosContainer container) =>
{
    ItemResponse<Order> response = await container.ReadItemAsync<Order>(
        orderId,
        new PartitionKey(customerId));

    return Results.Ok(response.Resource);
});
```

---

### Challenge 18: Incorrect Time Handling

**Symptom:** Queries using dates behave unexpectedly due to time zone differences.

**Solution:**

- Store times in **UTC** only (e.g., `orderDateUtc`).  
- Normalize all date comparisons to UTC.

---

### Challenge 19: Missing Idempotency in Event Processing

**Symptom:** Duplicate events processed via change feed or external buses.

**Solution:**

- Design **idempotent** handlers.  
- Use unique IDs / upsert patterns.

```csharp
// Upsert with idempotency based on eventId
var doc = new { id = eventId, payload = payload };
await container.UpsertItemAsync(doc, new PartitionKey(eventIdTenantId));
```

---

### Challenge 20: Cost Surprises at Scale

**Symptom:** Monthly bill higher than expected.

**Solution:**

- Right-size RU/s; use **autoscale** where possible.  
- Use TTL for soft-deleted or time-bound data.  
- Review RU hot spots with diagnostics, refactor queries and partitioning.

---

## 17. Sample Document Structures & Query Patterns

### 17.1 User Profile

```json
{
  "id": "user_123",
  "tenantId": "tenant_1",
  "email": "alice@example.com",
  "displayName": "Alice",
  "roles": ["Admin", "Approver"],
  "signupDateUtc": "2024-01-10T13:00:00Z"
}
```

Sample query: all admins for a tenant.

```sql
SELECT c.id, c.email
FROM c
WHERE c.tenantId = @tenantId AND ARRAY_CONTAINS(c.roles, @role)
```

### 17.2 IoT Telemetry Event

```json
{
  "id": "evt_20241001_00001",
  "deviceId": "dev_42",            // partition key
  "timestampUtc": "2024-10-01T10:00:00Z",
  "temperature": 22.5,
  "humidity": 0.55
}
```

Sample query: last 50 readings for a device.

```sql
SELECT TOP 50 *
FROM c
WHERE c.deviceId = @deviceId
ORDER BY c.timestampUtc DESC
```

---

## 18. Interview Questions for .NET Developers (Cosmos-Focused)

### 18.1 Conceptual Questions

- Explain the difference between **logical partitions** and **physical partitions** in Cosmos DB.  
- What is a **partition key**? How do you choose a good one?  
- How do **Request Units (RU)** work? How do you estimate RU requirements?  
- Compare **consistency levels** in Cosmos DB and when to use each.  
- What are the trade-offs between **Provisioned throughput**, **Autoscale**, and **Serverless**?  
- How do you design data models in Cosmos DB compared to relational databases?  
- Explain the **change feed** and a scenario where you’d use it.  
- What is **TTL** and how is it configured?  
- How do you implement **multi-tenant** solutions in Cosmos?  
- Why are transactions in Cosmos limited to a single logical partition?

### 18.2 .NET / SDK-Specific Questions

- Show how to initialize a `CosmosClient` using **managed identity** in a .NET API.  
- How do you perform pagination with the Cosmos .NET SDK? Why use **continuation tokens** instead of `OFFSET`?  
- Demonstrate how to handle **optimistic concurrency** using **ETags** in the SDK.  
- How do you log **RU consumption** and **diagnostics** for queries in a .NET app?  
- What is a **transactional batch** in the Azure.Cosmos SDK and when would you use it?  
- How do you configure **preferred regions** in the .NET SDK?  
- How would you write a **change feed processor** in .NET to react to new items?  
- What are common error codes (`429`, `404`, `412`) and how do you handle them in .NET code?  
- How would you structure a .NET microservice route to efficiently interact with Cosmos (partition key in route)?  
- How do you migrate from the older `DocumentClient` SDK to `Azure.Cosmos`?

---

## 19. Quick Reference Cheat Sheet

### 19.1 Azure CLI

```bash
# Create account
az cosmosdb create --name $COSMOS_ACCOUNT --resource-group $RESOURCE_GROUP --kind GlobalDocumentDB

# Create SQL database
az cosmosdb sql database create --account-name $COSMOS_ACCOUNT --resource-group $RESOURCE_GROUP --name $DB_NAME

# Create SQL container
az cosmosdb sql container create \
  --account-name $COSMOS_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --database-name $DB_NAME \
  --name $CONTAINER_NAME \
  --partition-key-path /customerId \
  --throughput 400

# Get keys
az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RESOURCE_GROUP --type keys
```

### 19.2 .NET SDK Snippets

```csharp
// Create client with key
var client = new CosmosClient(endpoint, key);

// Create / get database and container
CosmosDatabase db = await client.CreateDatabaseIfNotExistsAsync("demo-db");
CosmosContainer container = await db.CreateContainerIfNotExistsAsync("orders", "/customerId", 400);

// Create item
await container.CreateItemAsync(order, new PartitionKey(order.customerId));

// Query with continuation tokens
FeedIterator<Order> it = container.GetItemQueryIterator<Order>(new QueryDefinition("SELECT * FROM c"));
while (it.HasMoreResults)
{
    FeedResponse<Order> page = await it.ReadNextAsync();
}
```

---

> With this guide, you should have a solid end-to-end understanding of Azure Cosmos DB (API for NoSQL) from a .NET developer’s perspective: concepts, data modeling, SDK usage, performance tuning, real-world challenges, and interview preparation.
