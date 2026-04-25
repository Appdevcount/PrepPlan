# Session 05 — Data Access Patterns (Enriched)

**Duration:** 60 minutes
**Audience:** Developers who completed Session 04
**Goal:** Understand EF Core, write LINQ queries, run migrations, apply the Repository pattern, and know when Cosmos DB is the right choice.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | Data Access Options in .NET |
| 5–18 min | EF Core — DbContext, Entities, Change Tracking |
| 18–30 min | Code First Migrations — Live Demo |
| 30–42 min | LINQ — The 7 Operators You'll Use Every Day |
| 42–50 min | Repository Pattern |
| 50–58 min | Transactions + Azure SQL + Cosmos DB Overview |
| 58–60 min | Key Takeaways + Q&A |

---

## 1. Data Access Options in .NET (0–5 min)

### Mental Model
> EF Core is an **object-relational mapper (ORM)**. You work with C# objects; EF Core translates your LINQ queries into SQL and maps results back to objects. You rarely write raw SQL.

```
┌──────────────────────────────────────────────────────────────┐
│  Option            │  When to Use                            │
├──────────────────────────────────────────────────────────────┤
│  EF Core (ORM)     │  CRUD apps, business logic-heavy        │
│  Dapper (micro)    │  High-perf read queries, reporting      │
│  Raw ADO.NET       │  Legacy, or when you need full control  │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. EF Core — DbContext, Entities, Change Tracking (5–18 min)

### The 3 Core Concepts

```
┌──────────────────────────────────────────────────────────────┐
│  Entity       = A C# class that maps to a database table    │
│  DbContext    = The session/connection manager + query API   │
│  DbSet<T>     = Represents a table you can query/modify      │
└──────────────────────────────────────────────────────────────┘
```

### Define Entities

```csharp
public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    // Navigation property — EF loads related orders
    public List<Order> Orders { get; set; } = new();
}

public class Order
{
    public int Id { get; set; }
    public decimal Total { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }

    // Foreign key
    public int CustomerId { get; set; }
    public Customer Customer { get; set; } = null!;
}

public enum OrderStatus { Pending, Confirmed, Shipped, Cancelled }
```

### Define DbContext

```csharp
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Customer>(e =>
        {
            e.Property(c => c.Email).HasMaxLength(256).IsRequired();
            e.HasIndex(c => c.Email).IsUnique();
        });

        modelBuilder.Entity<Order>(e =>
        {
            // WHY: decimal precision must be explicit — SQL default is too wide
            e.Property(o => o.Total).HasPrecision(18, 2);
        });
    }
}
```

### Register in Program.cs

```csharp
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("Default"),
        sql => sql.CommandTimeout(30)));
```

### Change Tracking — The Core EF Concept

```csharp
var customer = await db.Customers.FindAsync(1);
// EF now tracks this customer

customer.Name = "Updated Name";
// EF detects this change

await db.SaveChangesAsync();
// EF generates: UPDATE Customers SET Name = 'Updated Name' WHERE Id = 1

// ── Disable tracking for read-only queries ────────────────
// WHY: tracking has overhead; skip it when you won't modify data
var customers = await db.Customers
    .AsNoTracking()
    .ToListAsync();
```

---

## 3. Code First Migrations — Live Demo (18–30 min)

### Mental Model
> A migration is a **versioned script** — you write C# model changes, EF generates the migration, the migration creates/alters the actual database schema.

### Step 1 — Install Tools

```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet tool install --global dotnet-ef
```

### Step 2 — Create Initial Migration

```bash
dotnet ef migrations add InitialCreate

# Creates:
# Migrations/
#   20241101000000_InitialCreate.cs     ← Up() and Down() methods
#   AppDbContextModelSnapshot.cs        ← current model snapshot
```

### Generated Migration File

```csharp
public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Customers",
            columns: table => new
            {
                Id = table.Column<int>(nullable: false)
                    .Annotation("SqlServer:Identity", "1, 1"),
                Name = table.Column<string>(nullable: false),
                Email = table.Column<string>(maxLength: 256, nullable: false),
                CreatedAt = table.Column<DateTime>(nullable: false)
            },
            constraints: table => table.PrimaryKey("PK_Customers", x => x.Id));

        migrationBuilder.CreateIndex(
            name: "IX_Customers_Email",
            table: "Customers",
            column: "Email",
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "Customers");
    }
}
```

### Step 3 — Apply to Database

```bash
dotnet ef database update
```

### Adding Columns (Model Change)

```csharp
// Add property to Customer
public string? PhoneNumber { get; set; }
```

```bash
dotnet ef migrations add AddCustomerPhone
dotnet ef database update
```

---

## 4. LINQ — The 7 Operators You'll Use Every Day (30–42 min)

### Mental Model
> LINQ is **SQL written in C#**. Instead of `SELECT * FROM Orders WHERE Total > 100`, you write `orders.Where(o => o.Total > 100)`. EF Core translates LINQ to SQL — the database does the heavy lifting.

```csharp
AppDbContext db; // injected

// ── 1. Where — filter ─────────────────────────────────────
var pending = await db.Orders
    .Where(o => o.Status == OrderStatus.Pending)
    .ToListAsync();

// ── 2. Select — project (pick only needed columns) ────────
// WHY: avoid loading large columns you don't need
var summaries = await db.Orders
    .Select(o => new { o.Id, o.Total, o.Status })
    .ToListAsync();

// ── 3. FirstOrDefault / SingleOrDefault ──────────────────
// FirstOrDefault: first match or null (no exception)
// SingleOrDefault: exactly one match — throws if more than one
var order = await db.Orders.FirstOrDefaultAsync(o => o.Id == 42);

// ── 4. Include — eager load related data ─────────────────
// WHY: without Include, Customer navigation property is null
var customerWithOrders = await db.Customers
    .Include(c => c.Orders)
    .FirstOrDefaultAsync(c => c.Id == 1);

// ── 5. OrderBy / Take — sort + paginate ──────────────────
var recent = await db.Orders
    .OrderByDescending(o => o.CreatedAt)
    .Take(10)
    .ToListAsync();

// ── 6. GroupBy — aggregate ───────────────────────────────
var salesByCustomer = await db.Orders
    .GroupBy(o => o.CustomerId)
    .Select(g => new
    {
        CustomerId = g.Key,
        TotalSales = g.Sum(o => o.Total),
        OrderCount = g.Count()
    })
    .ToListAsync();

// ── 7. Any / Count / Sum / Average ───────────────────────
bool hasOrders  = await db.Orders.AnyAsync(o => o.CustomerId == 1);
int count       = await db.Orders.CountAsync(o => o.Status == OrderStatus.Pending);
decimal revenue = await db.Orders.SumAsync(o => o.Total);
```

### LINQ → SQL Translation Example

```csharp
// What you write:
var results = await db.Orders
    .Where(o => o.Total > 100 && o.Status == OrderStatus.Confirmed)
    .OrderByDescending(o => o.CreatedAt)
    .Take(5)
    .Select(o => new { o.Id, o.Total })
    .ToListAsync();

// SQL EF Core sends:
// SELECT TOP(5) [o].[Id], [o].[Total]
// FROM [Orders] AS [o]
// WHERE [o].[Total] > 100.0 AND [o].[Status] = 1
// ORDER BY [o].[CreatedAt] DESC
```

---

## 5. Repository Pattern (42–50 min)

### Mental Model
> The Repository pattern is a **filing cabinet abstraction** — your application asks for data by name ("get order by ID"), not by drawer ("run this SQL query"). Swap the filing cabinet (SQL → Cosmos DB) without changing who asks.

### Why Use It?

```
Without Repository:
  OrderService → directly calls db.Orders.Where(...).ToListAsync()
  Problem: OrderService now knows about EF Core, SQL, tracking, DbContext
           Testing requires a real (or in-memory) database

With Repository:
  OrderService → calls IOrderRepository.GetPendingAsync()
  Infrastructure layer handles EF Core details
  Tests inject a fake repository — no database needed
```

### Interface (Application Layer)

```csharp
// Defined in Application layer — no EF Core reference
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(int id);
    Task<IEnumerable<Order>> GetPendingAsync();
    Task<IEnumerable<Order>> GetByCustomerAsync(int customerId);
    Task AddAsync(Order order);
    Task SaveChangesAsync();
}
```

### Implementation (Infrastructure Layer)

```csharp
// Defined in Infrastructure layer — knows about EF Core
public class EfOrderRepository : IOrderRepository
{
    private readonly AppDbContext _db;

    public EfOrderRepository(AppDbContext db) => _db = db;

    public Task<Order?> GetByIdAsync(int id)
        => _db.Orders.FindAsync(id).AsTask();

    public Task<IEnumerable<Order>> GetPendingAsync()
        => _db.Orders
              .Where(o => o.Status == OrderStatus.Pending)
              .AsNoTracking()
              .ToListAsync()
              .ContinueWith(t => (IEnumerable<Order>)t.Result);

    public Task<IEnumerable<Order>> GetByCustomerAsync(int customerId)
        => _db.Orders
              .Where(o => o.CustomerId == customerId)
              .Include(o => o.Customer)
              .AsNoTracking()
              .ToListAsync()
              .ContinueWith(t => (IEnumerable<Order>)t.Result);

    public async Task AddAsync(Order order) => await _db.Orders.AddAsync(order);

    public Task SaveChangesAsync() => _db.SaveChangesAsync();
}
```

### Registration

```csharp
// WHY: Scoped — one repository instance per request, same as DbContext
builder.Services.AddScoped<IOrderRepository, EfOrderRepository>();
```

---

## 6. Transactions + Azure SQL + Cosmos DB Overview (50–58 min)

### Transactions in EF Core

```csharp
// SaveChangesAsync IS the unit of work — atomic by default
var customer = new Customer { Name = "Alice", Email = "alice@test.com", CreatedAt = DateTime.UtcNow };
db.Customers.Add(customer);

var order = new Order { CustomerId = customer.Id, Total = 99.99m, Status = OrderStatus.Pending, CreatedAt = DateTime.UtcNow };
db.Orders.Add(order);

// WHY: both inserts happen in one transaction — if one fails, neither is committed
await db.SaveChangesAsync();

// Explicit transaction — for multiple SaveChanges calls
await using var transaction = await db.Database.BeginTransactionAsync();
try
{
    await db.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}
```

---

## Azure Integration

> **For the Azure-focused audience** — Azure SQL for relational data and Cosmos DB for document/NoSQL scenarios.

### Azure SQL Database

```
┌──────────────────────────────────────────────────────────────────┐
│  Azure SQL = SQL Server in the cloud                             │
│                                                                  │
│  What Azure manages for you:                                     │
│  ✓ Backups (point-in-time restore up to 35 days)                │
│  ✓ High Availability (99.99% SLA with Business Critical tier)   │
│  ✓ Patching and version upgrades                                 │
│  ✓ Geo-replication (read replicas in other regions)             │
└──────────────────────────────────────────────────────────────────┘
```

**Connection string with Managed Identity (no password!):**
```json
{
  "ConnectionStrings": {
    "Default": "Server=myserver.database.windows.net;Database=mydb;Authentication=Active Directory Managed Identity;"
  }
}
```

### Azure Cosmos DB — When to Choose It

```
┌──────────────────────────────────────────────────────────────────┐
│  Choose Cosmos DB when:                                          │
│  • Schema is flexible or varies per document                     │
│  • Global distribution needed (data close to users worldwide)    │
│  • Extreme throughput (millions of reads/writes per second)      │
│  • Hierarchical/nested data that doesn't fit relational tables   │
│                                                                  │
│  Stay with Azure SQL when:                                       │
│  • You need JOINS across multiple tables                         │
│  • Strong ACID transactions across entities                      │
│  • Team knows SQL and relational modeling                        │
└──────────────────────────────────────────────────────────────────┘
```

### Cosmos DB Key Concepts

```
┌──────────────────────┬────────────────────────────────────────────┐
│  Concept             │  What it Means                             │
├──────────────────────┼────────────────────────────────────────────┤
│  Container           │  Like a table, but stores JSON documents   │
│  Document            │  A JSON object — no fixed schema           │
│  Partition Key       │  Field used to distribute data across nodes│
│  RU (Request Unit)   │  Cost unit — 1 RU ≈ read of 1KB document  │
└──────────────────────┴────────────────────────────────────────────┘
```

```bash
dotnet add package Microsoft.Azure.Cosmos
```

```csharp
// Simple Cosmos DB read — uses SDK directly (not EF Core)
var cosmosClient = new CosmosClient(connectionString);
var container = cosmosClient.GetContainer("mydb", "orders");

// Read a single document by ID and partition key
var response = await container.ReadItemAsync<OrderDocument>(
    id: "order-123",
    partitionKey: new PartitionKey("customer-456"));

var order = response.Resource;

// Query with LINQ-like syntax
var query = container.GetItemQueryIterator<OrderDocument>(
    new QueryDefinition("SELECT * FROM c WHERE c.status = @status")
        .WithParameter("@status", "Pending"));

while (query.HasMoreResults)
{
    var page = await query.ReadNextAsync();
    foreach (var doc in page) { /* process */ }
}
```

---

## Key Takeaways

1. **DbContext = session** — one per request (Scoped); tracks changes and translates LINQ to SQL.
2. **Migrations = versioned schema** — always commit migration files; apply them before deploying the app.
3. **AsNoTracking() for reads** — skip tracking for significant performance gains on read-only queries.
4. **Repository pattern = clean boundary** — Application layer stays ignorant of EF Core; tests inject fakes.
5. **Cosmos DB for document/global scale** — not a SQL replacement; choose based on data shape and scale needs.

---

## Q&A Prompts

**1. What is the N+1 query problem? How does `Include()` solve it?**

**Answer:** N+1 happens when you load N orders and then, for each order, run a separate query to load its customer — resulting in 1 + N database round trips. `Include(o => o.Customer)` tells EF Core to JOIN the Customers table in a single query, fetching all data in one round trip. Without `Include`, the navigation property is null (lazy loading is off by default in modern EF Core).

---

**2. When would you use `AsNoTracking()`?**

**Answer:** Whenever you're reading data that you won't modify and save back. EF Core maintains a snapshot of every tracked entity to detect changes, which has memory and CPU overhead. For read-only scenarios (API GET endpoints, reports, dashboard data), `AsNoTracking()` skips that overhead entirely and can improve performance by 20–50% for large result sets.

---

**3. What's the difference between `FirstOrDefault` and `SingleOrDefault`?**

**Answer:** `FirstOrDefault` returns the first matching row or null — it works even if multiple rows match. `SingleOrDefault` returns the one matching row or null, but throws `InvalidOperationException` if more than one row matches. Use `FirstOrDefault` for lists, `SingleOrDefault` when your query should return exactly one row (like finding by primary key, though `FindAsync` is better for that).

---

**4. When would you choose Cosmos DB over Azure SQL?**

**Answer:** Cosmos DB when: your data is naturally hierarchical (an order with its lines and events all in one document), you need to serve users globally with low latency (multi-region writes), or your throughput requirements exceed what a single SQL instance can handle. Azure SQL when: you need complex JOINs, strong transactions across multiple entities, or your team is already productive with SQL. Don't use Cosmos DB just because it's "modern" — SQL is often the right tool.

---

## What's Next — Day 6

The data layer is working. Now how do you know if it's working **well** in production? Next session covers structured logging, global exception handling, health checks, and Azure Application Insights.
