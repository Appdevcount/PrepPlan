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

### 11.1 Indexing

- Default policy indexes all properties with range indexes.  
- You can customize indexing for performance:
  - Exclude large or rarely-queried fields.  
  - Add composite indexes for multi-property order-by.

Example indexing policy snippet (conceptual):

```json
{
  "indexingMode": "consistent",
  "includedPaths": [
    { "path": "/customerId/?" },
    { "path": "/orderDateUtc/?" },
    { "path": "/status/?" }
  ],
  "excludedPaths": [
    { "path": "/largeBlob/*" }
  ]
}
```

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
