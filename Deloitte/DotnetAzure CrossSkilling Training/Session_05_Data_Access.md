# Session 05 — Data Access Patterns

**Duration:** 60 minutes
**Audience:** Developers who completed Session 04
**Goal:** Understand how Entity Framework Core maps C# classes to database tables, write LINQ queries with confidence, run Code First migrations, and know where Azure SQL fits.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | Data Access Options in .NET |
| 5–20 min | EF Core — How It Works (DbContext, Entities, Tracking) |
| 20–35 min | Code First Migrations — Live Demo |
| 35–50 min | LINQ — The 7 Operators You'll Use Every Day |
| 50–58 min | Transactions + Azure SQL Quick Overview |
| 58–60 min | Key Takeaways + Q&A |

---

## 1. Data Access Options in .NET (0–5 min)

### Mental Model
> EF Core is an **object-relational mapper (ORM)**. You work with C# objects; EF Core translates your LINQ queries into SQL and maps the results back to objects. You rarely write raw SQL.

```
┌──────────────────────────────────────────────────────────────┐
│  Option            │  When to Use                            │
├──────────────────────────────────────────────────────────────┤
│  EF Core (ORM)     │  CRUD apps, business logic-heavy       │
│  Dapper (micro)    │  High-perf read queries, reporting      │
│  Raw ADO.NET       │  Legacy, or when you need full control  │
└──────────────────────────────────────────────────────────────┘
```

This session focuses on **EF Core** — the default for new .NET apps.

---

## 2. EF Core — How It Works (5–20 min)

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
// ── Entity — maps to a table in the database ─────────────
public class Customer
{
    public int Id { get; set; }               // EF recognizes "Id" as primary key
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
    public Customer Customer { get; set; } = null!;  // navigation back to Customer
}

public enum OrderStatus { Pending, Confirmed, Shipped, Cancelled }
```

### Define DbContext

```csharp
// ── DbContext = your database session ────────────────────
public class AppDbContext : DbContext
{
    // Constructor receives options (connection string etc.) from DI
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    // Each DbSet maps to a table
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ── Fluent API — configure table/column details ───
        modelBuilder.Entity<Customer>(e =>
        {
            e.Property(c => c.Email).HasMaxLength(256).IsRequired();
            e.HasIndex(c => c.Email).IsUnique();  // unique constraint
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
// ── Register EF Core with SQL Server ─────────────────────
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("Default"),
        sql => sql.CommandTimeout(30)));
```

### Change Tracking — The Core EF Concept

```csharp
// EF Core tracks every entity you load from the DB
// When you call SaveChangesAsync(), it generates SQL for any changes

await using var db = /* injected */;

var customer = await db.Customers.FindAsync(1);
// EF now tracks this customer

customer.Name = "Updated Name";
// EF detects this change (it compares against original snapshot)

await db.SaveChangesAsync();
// EF generates: UPDATE Customers SET Name = 'Updated Name' WHERE Id = 1

// ── To disable tracking for read-only queries (performance) ──
// WHY: tracking has overhead; skip it when you won't modify data
var customers = await db.Customers
    .AsNoTracking()
    .ToListAsync();
```

---

## 3. Code First Migrations — Live Demo (20–35 min)

### Mental Model
> A migration is a **versioned script** that describes how the database schema changes from one version of your model to the next. You write C# model changes; EF generates the migration; the migration creates/alters the actual database.

### Step 1 — Install Tools

```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet tool install --global dotnet-ef
```

### Step 2 — Create Initial Migration

```bash
# EF inspects your DbContext and entities, generates a migration file
dotnet ef migrations add InitialCreate

# This creates:
# Migrations/
#   20241101000000_InitialCreate.cs     ← Up() and Down() methods
#   AppDbContextModelSnapshot.cs        ← snapshot of current model
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

### Step 3 — Apply Migration to Database

```bash
# Apply all pending migrations to your local DB
dotnet ef database update
```

### Step 4 — Add a New Column (Model Change)

```csharp
// Add a property to Customer
public string? PhoneNumber { get; set; }
```

```bash
dotnet ef migrations add AddCustomerPhone
dotnet ef database update
```

### Apply Migrations at App Startup (for non-production or dev)

```csharp
// WHY: auto-migrate at startup is convenient for dev/test
// In production, run migrations as a separate deployment step
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await db.Database.MigrateAsync();
}
```

---

## 4. LINQ — The 7 Operators You'll Use Every Day (35–50 min)

### Mental Model
> LINQ is **SQL written in C#**. Instead of `SELECT * FROM Orders WHERE Total > 100`, you write `orders.Where(o => o.Total > 100)`. EF Core translates LINQ to SQL — the database does the heavy lifting.

```csharp
// ── Setup: assume these are injected via DI ───────────────
AppDbContext db; // injected

// ── 1. Where — filter rows ───────────────────────────────
var pendingOrders = await db.Orders
    .Where(o => o.Status == OrderStatus.Pending)
    .ToListAsync();

// ── 2. Select — project (pick specific columns) ──────────
// WHY: only fetch what you need — avoids loading large columns
var orderSummaries = await db.Orders
    .Select(o => new { o.Id, o.Total, o.Status })
    .ToListAsync();

// ── 3. FirstOrDefault / SingleOrDefault ──────────────────
// FirstOrDefault: returns first match or null (no exception)
// SingleOrDefault: returns the one match, throws if more than one
var order = await db.Orders
    .FirstOrDefaultAsync(o => o.Id == 42);

// ── 4. Include — load related data (eager loading) ───────
// WHY: without Include, Orders.Customer would be null
var customerWithOrders = await db.Customers
    .Include(c => c.Orders)          // JOIN to Orders table
    .FirstOrDefaultAsync(c => c.Id == 1);

// ── 5. OrderBy / OrderByDescending ───────────────────────
var recentOrders = await db.Orders
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
bool hasOrders = await db.Orders.AnyAsync(o => o.CustomerId == 1);
int orderCount = await db.Orders.CountAsync(o => o.Status == OrderStatus.Pending);
decimal totalRevenue = await db.Orders.SumAsync(o => o.Total);
```

### LINQ to SQL Translation Example

```csharp
// What you write:
var results = await db.Orders
    .Where(o => o.Total > 100 && o.Status == OrderStatus.Confirmed)
    .OrderByDescending(o => o.CreatedAt)
    .Take(5)
    .Select(o => new { o.Id, o.Total })
    .ToListAsync();

// What EF Core sends to SQL Server:
// SELECT TOP(5) [o].[Id], [o].[Total]
// FROM [Orders] AS [o]
// WHERE [o].[Total] > 100.0 AND [o].[Status] = 1
// ORDER BY [o].[CreatedAt] DESC
```

---

## 5. Transactions + Azure SQL Overview (50–58 min)

### Transactions in EF Core

```csharp
// ── SaveChangesAsync IS the unit of work ─────────────────
// All changes tracked since last SaveChanges run in one transaction
var customer = new Customer { Name = "Alice", Email = "alice@test.com", CreatedAt = DateTime.UtcNow };
db.Customers.Add(customer);

var order = new Order { CustomerId = customer.Id, Total = 99.99m, Status = OrderStatus.Pending, CreatedAt = DateTime.UtcNow };
db.Orders.Add(order);

// WHY: both inserts happen atomically — if one fails, neither is committed
await db.SaveChangesAsync();

// ── Explicit transaction — when you need to span multiple SaveChanges ──
await using var transaction = await db.Database.BeginTransactionAsync();
try
{
    // ... multiple operations ...
    await db.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}
```

### Azure SQL — What You Need to Know

```
┌──────────────────────────────────────────────────────────────────┐
│  Azure SQL Database = SQL Server in the cloud                    │
│                                                                  │
│  What Azure manages for you:                                     │
│  ✓ Backups (point-in-time restore up to 35 days)                │
│  ✓ High Availability (99.99% SLA with Business Critical tier)   │
│  ✓ Patching and version upgrades                                 │
│  ✓ Geo-replication (read replicas in other regions)             │
│                                                                  │
│  What you manage:                                                │
│  • Choose the right tier (DTU vs vCore model)                   │
│  • Set firewall rules / private endpoints                        │
│  • Run migrations on deployment                                  │
│  • Monitor query performance (Query Performance Insight)         │
└──────────────────────────────────────────────────────────────────┘
```

**Connection string for Azure SQL:**
```json
{
  "ConnectionStrings": {
    "Default": "Server=myserver.database.windows.net;Database=mydb;Authentication=Active Directory Managed Identity;"
  }
}
```

*Using Managed Identity (no password in the connection string!)*

---

## Key Takeaways

1. **DbContext = session** — one per request (register as `Scoped`); it tracks changes and translates LINQ to SQL.
2. **Migrations are versioned schema changes** — always check migration files into Git; apply them in CI/CD before deploying the app.
3. **AsNoTracking() for reads** — when you don't modify data, skip tracking for significant performance gains.
4. **SaveChangesAsync = unit of work** — all tracked changes in one request commit atomically in one transaction.
5. **Include() for related data** — forgetting it causes N+1 query problems (loading one order → loading customer → another query per order).

---

## Q&A Prompts

1. What is the N+1 query problem? How does `Include()` solve it?
2. When would you use `AsNoTracking()`?
3. What's the difference between `FirstOrDefault` and `SingleOrDefault`?
4. Why should you run migrations as a separate deployment step instead of `MigrateAsync()` at startup in production?

---

## What's Next — Day 6

The data layer is working. Now how do you know if it's working **well** in production? Next session covers structured logging, global exception handling, health checks, and Azure Application Insights — the tools that tell you what's happening inside your running app.
