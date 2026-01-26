# Entity Framework & LINQ - Complete Knowledge Repository

## Overview
This comprehensive guide covers Entity Framework Core and LINQ from fundamentals to advanced patterns, with real-world scenarios and interview questions. Designed for Senior/SDE-2/Architect level interviews at top companies.

---

## Table of Contents
1. [LINQ Fundamentals](#1-linq-fundamentals)
2. [EF Core Architecture](#2-ef-core-architecture)
3. [DbContext & Configuration](#3-dbcontext--configuration)
4. [Querying Data](#4-querying-data)
5. [Loading Strategies](#5-loading-strategies)
6. [Change Tracking](#6-change-tracking)
7. [Migrations & Schema Management](#7-migrations--schema-management)
8. [Performance Optimization](#8-performance-optimization)
9. [Advanced Patterns](#9-advanced-patterns)
10. [Concurrency & Transactions](#10-concurrency--transactions)
11. [Testing with EF Core](#11-testing-with-ef-core)
12. [Real-World Scenarios](#12-real-world-scenarios)
13. [Interview Questions & Answers](#13-interview-questions--answers)

---

## 1. LINQ Fundamentals

### What is LINQ?

**LINQ (Language Integrated Query)** is a set of technologies that allows you to write queries directly in C# (or VB.NET) using a consistent syntax, regardless of the data source (objects, databases, XML, etc.).

```
┌─────────────────────────────────────────────────────────────┐
│                    LINQ Architecture                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   C# Query Syntax    OR    Method Syntax (Fluent)           │
│         │                        │                           │
│         └──────────┬─────────────┘                           │
│                    │                                         │
│            LINQ Providers                                    │
│    ┌───────────────┼───────────────┐                        │
│    │               │               │                        │
│    ▼               ▼               ▼                        │
│ LINQ to Objects  LINQ to SQL   LINQ to XML                  │
│ (IEnumerable)    (IQueryable)  (XDocument)                  │
│                       │                                      │
│                       ▼                                      │
│              Entity Framework                                │
│              (IQueryable<T>)                                 │
│                       │                                      │
│                       ▼                                      │
│              SQL Translation                                 │
│              & Execution                                     │
└─────────────────────────────────────────────────────────────┘
```

### IEnumerable vs IQueryable - Critical Distinction

> **Interview Favorite**: This is one of the most asked questions. Understanding this difference is crucial.

```csharp
// IEnumerable<T> - In-memory execution
// All data loaded into memory, then filtered
IEnumerable<Order> orders = context.Orders;
var filtered = orders.Where(o => o.Total > 100); // Filter runs in memory!
// SQL: SELECT * FROM Orders (loads ALL orders)

// IQueryable<T> - Database execution
// Query translated to SQL, filtered at database level
IQueryable<Order> orders = context.Orders;
var filtered = orders.Where(o => o.Total > 100); // Filter translated to SQL
// SQL: SELECT * FROM Orders WHERE Total > 100

// DANGER: Converting IQueryable to IEnumerable prematurely
var badQuery = context.Orders
    .AsEnumerable()  // ❌ From here, everything runs in memory!
    .Where(o => o.Total > 100)
    .OrderBy(o => o.Date);
// Loads ALL orders, filters and sorts in memory

// CORRECT: Keep as IQueryable until you need results
var goodQuery = context.Orders
    .Where(o => o.Total > 100)  // Translated to SQL
    .OrderBy(o => o.Date)       // Translated to SQL
    .ToList();                   // Execute query
// SQL: SELECT * FROM Orders WHERE Total > 100 ORDER BY Date
```

**When to use each:**

| Scenario | Use | Reason |
|----------|-----|--------|
| Database queries | `IQueryable<T>` | SQL translation, server-side filtering |
| In-memory collections | `IEnumerable<T>` | Already in memory |
| After `ToList()`/`ToArray()` | `IEnumerable<T>` | Data already fetched |
| Unit testing with mock data | `IEnumerable<T>` | No database involved |
| Complex expressions EF can't translate | `AsEnumerable()` then filter | Fallback for unsupported operations |

### LINQ Method Syntax vs Query Syntax

```csharp
// Query Syntax (SQL-like)
var query1 = from order in context.Orders
             where order.Total > 100
             orderby order.Date descending
             select new { order.Id, order.Total };

// Method Syntax (Fluent/Lambda)
var query2 = context.Orders
    .Where(order => order.Total > 100)
    .OrderByDescending(order => order.Date)
    .Select(order => new { order.Id, order.Total });

// Both produce identical SQL!
// Method syntax is more common in production code
```

### Essential LINQ Operators

#### Filtering
```csharp
// Where - Filter elements
var expensiveOrders = orders.Where(o => o.Total > 1000);

// OfType - Filter by type
var productItems = items.OfType<ProductItem>();

// Distinct - Remove duplicates
var uniqueCategories = products.Select(p => p.Category).Distinct();

// Take/Skip - Pagination
var page2 = orders.Skip(20).Take(10); // Page 2, 10 items per page

// TakeWhile/SkipWhile - Conditional take/skip
var untilExpensive = orders.OrderBy(o => o.Total)
    .TakeWhile(o => o.Total < 1000);
```

#### Projection
```csharp
// Select - Transform elements
var orderTotals = orders.Select(o => o.Total);

// Select with index
var indexed = orders.Select((o, index) => new { Index = index, Order = o });

// SelectMany - Flatten nested collections
var allItems = orders.SelectMany(o => o.Items);

// Anonymous types
var projections = orders.Select(o => new {
    o.Id,
    o.Total,
    CustomerName = o.Customer.Name,
    ItemCount = o.Items.Count
});

// Named DTOs (recommended for production)
var dtos = orders.Select(o => new OrderSummaryDto {
    Id = o.Id,
    Total = o.Total,
    CustomerName = o.Customer.Name
});
```

#### Joining
```csharp
// Inner Join
var orderWithCustomer = from o in context.Orders
                        join c in context.Customers on o.CustomerId equals c.Id
                        select new { o.Id, c.Name };

// Method syntax join
var joined = context.Orders
    .Join(context.Customers,
          order => order.CustomerId,
          customer => customer.Id,
          (order, customer) => new { order.Id, customer.Name });

// Left Join (GroupJoin + SelectMany + DefaultIfEmpty)
var leftJoin = from o in context.Orders
               join c in context.Customers on o.CustomerId equals c.Id into customerGroup
               from c in customerGroup.DefaultIfEmpty()
               select new { o.Id, CustomerName = c != null ? c.Name : "Unknown" };

// Navigation properties (preferred in EF Core!)
var simpler = context.Orders
    .Select(o => new { o.Id, o.Customer.Name }); // EF generates JOIN automatically
```

#### Aggregation
```csharp
// Count
var totalOrders = orders.Count();
var expensiveCount = orders.Count(o => o.Total > 1000);

// Sum/Average/Min/Max
var totalRevenue = orders.Sum(o => o.Total);
var averageOrder = orders.Average(o => o.Total);
var smallestOrder = orders.Min(o => o.Total);
var largestOrder = orders.Max(o => o.Total);

// Aggregate (custom aggregation)
var concatenated = names.Aggregate((current, next) => current + ", " + next);

// Group aggregations
var salesByCategory = products
    .GroupBy(p => p.Category)
    .Select(g => new {
        Category = g.Key,
        TotalSales = g.Sum(p => p.Sales),
        AveragePrice = g.Average(p => p.Price),
        ProductCount = g.Count()
    });
```

#### Grouping
```csharp
// GroupBy - Group elements
var ordersByCustomer = orders
    .GroupBy(o => o.CustomerId)
    .Select(g => new {
        CustomerId = g.Key,
        OrderCount = g.Count(),
        TotalSpent = g.Sum(o => o.Total)
    });

// GroupBy with multiple keys
var ordersByDateAndStatus = orders
    .GroupBy(o => new { o.OrderDate.Year, o.OrderDate.Month, o.Status })
    .Select(g => new {
        g.Key.Year,
        g.Key.Month,
        g.Key.Status,
        Count = g.Count()
    });

// Having clause equivalent
var customersWithMultipleOrders = orders
    .GroupBy(o => o.CustomerId)
    .Where(g => g.Count() > 5) // HAVING COUNT(*) > 5
    .Select(g => g.Key);
```

#### Set Operations
```csharp
// Union - Combine unique elements
var allCustomerIds = activeCustomers.Union(premiumCustomers);

// Intersect - Common elements
var premiumActiveCustomers = activeCustomers.Intersect(premiumCustomers);

// Except - Elements in first but not in second
var regularCustomers = activeCustomers.Except(premiumCustomers);

// Concat - Combine all elements (including duplicates)
var allOrders = onlineOrders.Concat(storeOrders);
```

#### Element Operators
```csharp
// First/FirstOrDefault - First element
var first = orders.First();                    // Throws if empty
var firstOrNull = orders.FirstOrDefault();     // Returns null if empty
var firstExpensive = orders.First(o => o.Total > 1000);

// Single/SingleOrDefault - Exactly one element
var single = orders.Single(o => o.Id == orderId);      // Throws if 0 or >1
var singleOrNull = orders.SingleOrDefault(o => o.Id == orderId);

// Last/LastOrDefault
var lastOrder = orders.OrderBy(o => o.Date).Last();

// ElementAt/ElementAtOrDefault
var thirdOrder = orders.ElementAt(2);

// INTERVIEW TIP: Know when to use each!
// First() - When you expect multiple results but want first
// Single() - When you expect exactly one result (business rule)
// Find() - When searching by primary key (uses local cache first)
```

### Deferred vs Immediate Execution

```csharp
// DEFERRED EXECUTION - Query not executed until enumerated
var query = context.Orders
    .Where(o => o.Total > 100)
    .OrderBy(o => o.Date);
// No SQL executed yet!

// Query executes when:
foreach (var order in query) { }        // Enumeration
var list = query.ToList();              // ToList()
var array = query.ToArray();            // ToArray()
var count = query.Count();              // Aggregation
var first = query.First();              // Element access

// IMMEDIATE EXECUTION - Operators that force execution
var list = orders.ToList();
var array = orders.ToArray();
var dict = orders.ToDictionary(o => o.Id);
var lookup = orders.ToLookup(o => o.Status);

// DANGER: Multiple enumeration
var query = context.Orders.Where(o => o.Total > 100);
var count = query.Count();      // Executes query
var list = query.ToList();      // Executes query AGAIN!

// SOLUTION: Materialize once
var list = context.Orders.Where(o => o.Total > 100).ToList();
var count = list.Count;         // Uses in-memory list
```

---

## 2. EF Core Architecture

### How EF Core Works

```
┌─────────────────────────────────────────────────────────────────┐
│                     Application Code                             │
│                                                                  │
│   var orders = context.Orders                                    │
│       .Where(o => o.Total > 100)                                │
│       .Include(o => o.Customer)                                  │
│       .ToList();                                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DbContext                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │ DbSet<T>    │  │ Change      │  │ Model                   │ │
│  │ Properties  │  │ Tracker     │  │ (Entity Metadata)       │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Query Pipeline                                 │
│  1. Expression Tree Building (LINQ → Expression<Func<T,bool>>)  │
│  2. Query Compilation (Expression → SQL)                         │
│  3. Parameter Binding                                            │
│  4. Query Execution                                              │
│  5. Result Materialization (SQL Results → C# Objects)           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Database Provider                              │
│  (SQL Server / PostgreSQL / MySQL / SQLite / Cosmos DB)         │
│                                                                  │
│  Translates generic EF operations to database-specific SQL      │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Database                                    │
│                                                                  │
│  SELECT o.*, c.*                                                │
│  FROM Orders o                                                   │
│  LEFT JOIN Customers c ON o.CustomerId = c.Id                   │
│  WHERE o.Total > @p0                                            │
└─────────────────────────────────────────────────────────────────┘
```

### Entity States

```csharp
// EF Core tracks entity states for change detection

public enum EntityState
{
    Detached,    // Not tracked by context
    Unchanged,   // Tracked, no changes since query
    Added,       // New entity, will be INSERTed
    Modified,    // Existing entity with changes, will be UPDATEd
    Deleted      // Marked for deletion, will be DELETEd
}

// State transitions
var order = new Order();                    // Detached
context.Orders.Add(order);                  // Added
await context.SaveChangesAsync();           // Unchanged (after save)
order.Total = 500;                          // Modified (if tracking enabled)
context.Orders.Remove(order);               // Deleted
await context.SaveChangesAsync();           // Detached (after delete)

// Check entity state
var state = context.Entry(order).State;

// Manually set state
context.Entry(order).State = EntityState.Modified;
```

---

## 3. DbContext & Configuration

### DbContext Fundamentals

```csharp
public class ApplicationDbContext : DbContext
{
    // DbSet represents a table
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Fluent API configuration
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        // Global query filters
        modelBuilder.Entity<Order>().HasQueryFilter(o => !o.IsDeleted);

        // Seed data
        modelBuilder.Entity<OrderStatus>().HasData(
            new OrderStatus { Id = 1, Name = "Pending" },
            new OrderStatus { Id = 2, Name = "Shipped" },
            new OrderStatus { Id = 3, Name = "Delivered" }
        );
    }

    // Override SaveChanges for audit logging
    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var entries = ChangeTracker.Entries<IAuditable>();

        foreach (var entry in entries)
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    entry.Entity.CreatedBy = _currentUser.Id;
                    break;
                case EntityState.Modified:
                    entry.Entity.ModifiedAt = DateTime.UtcNow;
                    entry.Entity.ModifiedBy = _currentUser.Id;
                    break;
            }
        }

        return await base.SaveChangesAsync(cancellationToken);
    }
}
```

### Entity Configuration

```csharp
// Data Annotations approach
public class Order
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(50)]
    public string OrderNumber { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Total { get; set; }

    [ForeignKey(nameof(Customer))]
    public int CustomerId { get; set; }

    public Customer Customer { get; set; }

    public ICollection<OrderItem> Items { get; set; }
}

// Fluent API approach (preferred for complex scenarios)
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        // Table mapping
        builder.ToTable("Orders", "sales");

        // Primary key
        builder.HasKey(o => o.Id);

        // Properties
        builder.Property(o => o.OrderNumber)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(o => o.Total)
            .HasColumnType("decimal(18,2)")
            .HasDefaultValue(0);

        builder.Property(o => o.CreatedAt)
            .HasDefaultValueSql("GETUTCDATE()");

        // Indexes
        builder.HasIndex(o => o.OrderNumber)
            .IsUnique();

        builder.HasIndex(o => o.CustomerId);

        builder.HasIndex(o => new { o.CustomerId, o.OrderDate })
            .HasDatabaseName("IX_Orders_Customer_Date");

        // Relationships
        builder.HasOne(o => o.Customer)
            .WithMany(c => c.Orders)
            .HasForeignKey(o => o.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(o => o.Items)
            .WithOne(i => i.Order)
            .HasForeignKey(i => i.OrderId)
            .OnDelete(DeleteBehavior.Cascade);

        // Query filter (soft delete)
        builder.HasQueryFilter(o => !o.IsDeleted);
    }
}
```

### Relationship Configuration

```csharp
// One-to-One
public class User
{
    public int Id { get; set; }
    public UserProfile Profile { get; set; }
}

public class UserProfile
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; }
}

// Configuration
builder.HasOne(u => u.Profile)
    .WithOne(p => p.User)
    .HasForeignKey<UserProfile>(p => p.UserId);

// One-to-Many
public class Customer
{
    public int Id { get; set; }
    public ICollection<Order> Orders { get; set; } = new List<Order>();
}

public class Order
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public Customer Customer { get; set; }
}

// Configuration
builder.HasMany(c => c.Orders)
    .WithOne(o => o.Customer)
    .HasForeignKey(o => o.CustomerId);

// Many-to-Many (EF Core 5+)
public class Student
{
    public int Id { get; set; }
    public ICollection<Course> Courses { get; set; }
}

public class Course
{
    public int Id { get; set; }
    public ICollection<Student> Students { get; set; }
}

// EF Core creates join table automatically
// Or explicit join entity for additional properties:
public class Enrollment
{
    public int StudentId { get; set; }
    public Student Student { get; set; }

    public int CourseId { get; set; }
    public Course Course { get; set; }

    public DateTime EnrolledAt { get; set; }
    public string Grade { get; set; }
}
```

### DbContext Registration

```csharp
// Program.cs / Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    // SQL Server
    services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlServer(
            Configuration.GetConnectionString("DefaultConnection"),
            sqlOptions =>
            {
                sqlOptions.EnableRetryOnFailure(
                    maxRetryCount: 5,
                    maxRetryDelay: TimeSpan.FromSeconds(30),
                    errorNumbersToAdd: null);
                sqlOptions.CommandTimeout(30);
                sqlOptions.MigrationsAssembly("MyApp.Infrastructure");
            })
        .EnableSensitiveDataLogging(isDevelopment) // Only in dev!
        .EnableDetailedErrors(isDevelopment)
        .LogTo(Console.WriteLine, LogLevel.Information));

    // PostgreSQL
    services.AddDbContext<ApplicationDbContext>(options =>
        options.UseNpgsql(Configuration.GetConnectionString("PostgresConnection")));

    // SQLite (for testing)
    services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlite("Data Source=app.db"));

    // DbContext pooling (performance optimization)
    services.AddDbContextPool<ApplicationDbContext>(options =>
        options.UseSqlServer(connectionString),
        poolSize: 128);
}
```

---

## 4. Querying Data

### Basic Queries

```csharp
// Get all
var allOrders = await context.Orders.ToListAsync();

// Get by ID (uses primary key, checks local cache first)
var order = await context.Orders.FindAsync(orderId);

// Filter
var pendingOrders = await context.Orders
    .Where(o => o.Status == OrderStatus.Pending)
    .ToListAsync();

// Order
var recentOrders = await context.Orders
    .OrderByDescending(o => o.CreatedAt)
    .ThenBy(o => o.CustomerId)
    .ToListAsync();

// Pagination
var page = await context.Orders
    .OrderBy(o => o.Id)
    .Skip((pageNumber - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();

// Distinct
var uniqueCustomerIds = await context.Orders
    .Select(o => o.CustomerId)
    .Distinct()
    .ToListAsync();
```

### Projections (SELECT)

```csharp
// Anonymous type projection
var orderSummaries = await context.Orders
    .Select(o => new {
        o.Id,
        o.OrderNumber,
        o.Total,
        CustomerName = o.Customer.Name,
        ItemCount = o.Items.Count
    })
    .ToListAsync();

// DTO projection (recommended)
public class OrderSummaryDto
{
    public int Id { get; set; }
    public string OrderNumber { get; set; }
    public decimal Total { get; set; }
    public string CustomerName { get; set; }
    public int ItemCount { get; set; }
}

var dtos = await context.Orders
    .Select(o => new OrderSummaryDto {
        Id = o.Id,
        OrderNumber = o.OrderNumber,
        Total = o.Total,
        CustomerName = o.Customer.Name,
        ItemCount = o.Items.Count
    })
    .ToListAsync();

// CRITICAL: Projection avoids loading unnecessary columns
// Bad: context.Orders.ToList().Select(...) - loads ALL columns
// Good: context.Orders.Select(...).ToList() - SQL only selects needed columns
```

### Filtering with Complex Conditions

```csharp
// Multiple conditions
var orders = await context.Orders
    .Where(o => o.Status == OrderStatus.Pending
             && o.Total > 100
             && o.Customer.Country == "USA")
    .ToListAsync();

// Contains (IN clause)
var statusList = new[] { OrderStatus.Pending, OrderStatus.Processing };
var orders = await context.Orders
    .Where(o => statusList.Contains(o.Status))
    .ToListAsync();
// SQL: WHERE Status IN ('Pending', 'Processing')

// String operations
var orders = await context.Orders
    .Where(o => o.OrderNumber.StartsWith("ORD-2024"))
    .Where(o => o.Customer.Name.Contains("Smith"))
    .Where(o => EF.Functions.Like(o.Notes, "%urgent%"))
    .ToListAsync();

// Date operations
var ordersThisMonth = await context.Orders
    .Where(o => o.CreatedAt.Month == DateTime.Now.Month
             && o.CreatedAt.Year == DateTime.Now.Year)
    .ToListAsync();

// Null handling
var ordersWithNotes = await context.Orders
    .Where(o => o.Notes != null && o.Notes.Length > 0)
    .ToListAsync();

// Any/All with nested collections
var customersWithLargeOrders = await context.Customers
    .Where(c => c.Orders.Any(o => o.Total > 1000))
    .ToListAsync();

var customersAllOrdersShipped = await context.Customers
    .Where(c => c.Orders.All(o => o.Status == OrderStatus.Shipped))
    .ToListAsync();
```

### Grouping & Aggregation

```csharp
// Group by single column
var ordersByStatus = await context.Orders
    .GroupBy(o => o.Status)
    .Select(g => new {
        Status = g.Key,
        Count = g.Count(),
        TotalAmount = g.Sum(o => o.Total),
        AverageAmount = g.Average(o => o.Total)
    })
    .ToListAsync();

// Group by multiple columns
var monthlySales = await context.Orders
    .GroupBy(o => new { o.CreatedAt.Year, o.CreatedAt.Month })
    .Select(g => new {
        Year = g.Key.Year,
        Month = g.Key.Month,
        TotalSales = g.Sum(o => o.Total),
        OrderCount = g.Count()
    })
    .OrderBy(x => x.Year)
    .ThenBy(x => x.Month)
    .ToListAsync();

// Having clause (filter on aggregations)
var topCustomers = await context.Orders
    .GroupBy(o => o.CustomerId)
    .Where(g => g.Sum(o => o.Total) > 10000) // HAVING SUM(Total) > 10000
    .Select(g => new {
        CustomerId = g.Key,
        TotalSpent = g.Sum(o => o.Total)
    })
    .OrderByDescending(x => x.TotalSpent)
    .Take(10)
    .ToListAsync();
```

### Raw SQL Queries

```csharp
// FromSqlRaw - for entity queries
var orders = await context.Orders
    .FromSqlRaw("SELECT * FROM Orders WHERE Total > {0}", minTotal)
    .ToListAsync();

// FromSqlInterpolated - SQL injection safe interpolation
var orders = await context.Orders
    .FromSqlInterpolated($"SELECT * FROM Orders WHERE Status = {status}")
    .Include(o => o.Customer) // Can chain LINQ!
    .Where(o => o.Total > 100) // Can add more filters!
    .ToListAsync();

// ExecuteSqlRaw - for non-query commands
var affectedRows = await context.Database
    .ExecuteSqlRawAsync("UPDATE Orders SET Status = 'Archived' WHERE CreatedAt < {0}", cutoffDate);

// Stored procedures
var results = await context.Orders
    .FromSqlRaw("EXEC GetOrdersByCustomer @CustomerId = {0}", customerId)
    .ToListAsync();

// Keyless entities (views, stored procedure results)
[Keyless]
public class OrderReport
{
    public string CustomerName { get; set; }
    public int OrderCount { get; set; }
    public decimal TotalSpent { get; set; }
}

// In DbContext
public DbSet<OrderReport> OrderReports => Set<OrderReport>();

// OnModelCreating
modelBuilder.Entity<OrderReport>().HasNoKey().ToView("vw_OrderReport");

// Query
var reports = await context.OrderReports.ToListAsync();
```

---

## 5. Loading Strategies

### Understanding the N+1 Problem

> **What is the N+1 Query Problem?**
>
> The N+1 query problem occurs when an application executes 1 query to fetch N records, then N additional queries to fetch related data for each record. This results in N+1 database round-trips instead of 1-2 optimized queries.

```csharp
// N+1 PROBLEM DEMONSTRATION
var orders = await context.Orders.ToListAsync(); // 1 query

foreach (var order in orders)
{
    // Each access triggers a separate query!
    Console.WriteLine(order.Customer.Name); // N queries
}
// Total: N+1 queries (disaster for performance!)

// If you have 100 orders, you execute 101 queries!
```

### Eager Loading (Include)

```csharp
// Single level include
var orders = await context.Orders
    .Include(o => o.Customer)
    .ToListAsync();
// SQL: SELECT o.*, c.* FROM Orders o LEFT JOIN Customers c ON o.CustomerId = c.Id

// Multi-level include
var orders = await context.Orders
    .Include(o => o.Customer)
    .Include(o => o.Items)
        .ThenInclude(i => i.Product)
            .ThenInclude(p => p.Category)
    .ToListAsync();

// Multiple includes at same level
var orders = await context.Orders
    .Include(o => o.Customer)
        .ThenInclude(c => c.Address)
    .Include(o => o.Customer)
        .ThenInclude(c => c.PaymentMethods)
    .ToListAsync();

// Filtered include (EF Core 5+)
var orders = await context.Orders
    .Include(o => o.Items.Where(i => i.Quantity > 0))
    .ToListAsync();

// Ordering in include (EF Core 5+)
var orders = await context.Orders
    .Include(o => o.Items.OrderBy(i => i.Product.Name))
    .ToListAsync();

// DANGER: Over-including
var orders = await context.Orders
    .Include(o => o.Customer)
        .ThenInclude(c => c.Address)
        .ThenInclude(a => a.Country)
    .Include(o => o.Customer)
        .ThenInclude(c => c.Orders) // Circular! Loads ALL customer orders
            .ThenInclude(o => o.Items)
    .ToListAsync();
// This could load your entire database!
```

### Explicit Loading

```csharp
// Load related data on demand
var order = await context.Orders.FindAsync(orderId);

// Load single navigation property
await context.Entry(order)
    .Reference(o => o.Customer)
    .LoadAsync();

// Load collection navigation property
await context.Entry(order)
    .Collection(o => o.Items)
    .LoadAsync();

// Query related data without loading
var itemCount = await context.Entry(order)
    .Collection(o => o.Items)
    .Query()
    .CountAsync();

var expensiveItems = await context.Entry(order)
    .Collection(o => o.Items)
    .Query()
    .Where(i => i.Price > 100)
    .ToListAsync();

// Check if loaded
bool isLoaded = context.Entry(order)
    .Collection(o => o.Items)
    .IsLoaded;
```

### Lazy Loading

```csharp
// Enable lazy loading
services.AddDbContext<ApplicationDbContext>(options =>
    options.UseLazyLoadingProxies() // Requires proxies package
           .UseSqlServer(connectionString));

// Entity must have virtual navigation properties
public class Order
{
    public int Id { get; set; }
    public virtual Customer Customer { get; set; }  // Virtual required!
    public virtual ICollection<OrderItem> Items { get; set; }
}

// Access triggers query automatically
var order = await context.Orders.FirstAsync();
var customerName = order.Customer.Name; // Query executed here

// DANGER: Lazy loading can cause N+1 problems silently!
// Only use when you can't predict what data you'll need

// Alternative: Lazy loading without proxies
public class Order
{
    private readonly ILazyLoader _lazyLoader;
    private Customer _customer;

    public Order(ILazyLoader lazyLoader)
    {
        _lazyLoader = lazyLoader;
    }

    public Customer Customer
    {
        get => _lazyLoader.Load(this, ref _customer);
        set => _customer = value;
    }
}
```

### Split Queries

```csharp
// Problem: Cartesian explosion with multiple collections
var orders = await context.Orders
    .Include(o => o.Items)      // 10 items per order
    .Include(o => o.Shipments)  // 3 shipments per order
    .ToListAsync();
// Results in 30 rows per order (10 × 3 cartesian product)!

// Solution: Split queries (EF Core 5+)
var orders = await context.Orders
    .Include(o => o.Items)
    .Include(o => o.Shipments)
    .AsSplitQuery()  // Executes separate queries
    .ToListAsync();
// Executes 3 queries instead of 1 with cartesian explosion

// Configure globally
services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString,
        o => o.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery)));

// Override for specific query
var orders = await context.Orders
    .AsSingleQuery()  // Override global setting
    .Include(o => o.Items)
    .ToListAsync();
```

### Loading Strategy Decision Matrix

| Scenario | Strategy | Reason |
|----------|----------|--------|
| Always need related data | Eager Loading | Single query, predictable |
| Sometimes need related data | Explicit Loading | Load on demand |
| Can't predict data needs | Lazy Loading (careful!) | Automatic but risky |
| Multiple collections | Split Query | Avoid cartesian explosion |
| Read-only scenarios | No Tracking + Projection | Maximum performance |
| API responses | Projection to DTO | Select only needed fields |

---

## 6. Change Tracking

### How Change Tracking Works

```csharp
// Change tracker monitors entity states
var order = await context.Orders.FirstAsync(o => o.Id == 1);
// State: Unchanged

order.Total = 500;
// State: Modified (EF detected property change)

var entry = context.Entry(order);
Console.WriteLine(entry.State); // Modified

// See what changed
foreach (var property in entry.Properties.Where(p => p.IsModified))
{
    Console.WriteLine($"{property.Metadata.Name}: {property.OriginalValue} → {property.CurrentValue}");
}

// Original values
var originalTotal = entry.Property(o => o.Total).OriginalValue;

// Revert changes
entry.CurrentValues.SetValues(entry.OriginalValues);
// Or
entry.Reload(); // Fetches from database
```

### No-Tracking Queries

```csharp
// No tracking - better performance for read-only scenarios
var orders = await context.Orders
    .AsNoTracking()
    .Where(o => o.Status == OrderStatus.Pending)
    .ToListAsync();

// Entities are not tracked - SaveChanges won't see them
orders[0].Total = 999;
await context.SaveChangesAsync(); // Nothing saved!

// No tracking with identity resolution (EF Core 5+)
var orders = await context.Orders
    .AsNoTrackingWithIdentityResolution()
    .Include(o => o.Customer)
    .ToListAsync();
// Same customer referenced by multiple orders will be the same instance

// Configure default at context level
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
}

// Override for specific query
var trackedOrder = await context.Orders
    .AsTracking()
    .FirstAsync(o => o.Id == 1);
```

### Disconnected Entities

```csharp
// Web API scenario - entity comes from client
[HttpPut("{id}")]
public async Task<IActionResult> UpdateOrder(int id, OrderUpdateDto dto)
{
    // Option 1: Fetch and update (safest, but extra query)
    var order = await _context.Orders.FindAsync(id);
    if (order == null) return NotFound();

    order.Total = dto.Total;
    order.Status = dto.Status;
    await _context.SaveChangesAsync();

    // Option 2: Attach and mark modified (no extra query)
    var order = new Order { Id = id, Total = dto.Total, Status = dto.Status };
    _context.Orders.Attach(order);
    _context.Entry(order).State = EntityState.Modified;
    await _context.SaveChangesAsync();
    // Updates ALL columns!

    // Option 3: Update specific properties (best for partial updates)
    var order = new Order { Id = id };
    _context.Orders.Attach(order);
    _context.Entry(order).Property(o => o.Total).IsModified = true;
    _context.Entry(order).Property(o => o.Status).IsModified = true;
    order.Total = dto.Total;
    order.Status = dto.Status;
    await _context.SaveChangesAsync();
    // Only updates Total and Status

    // Option 4: ExecuteUpdate (EF Core 7+, no tracking)
    await _context.Orders
        .Where(o => o.Id == id)
        .ExecuteUpdateAsync(s => s
            .SetProperty(o => o.Total, dto.Total)
            .SetProperty(o => o.Status, dto.Status));
    // Direct SQL UPDATE, no entity loading

    return NoContent();
}
```

### Bulk Operations

```csharp
// EF Core 7+ Bulk Update
await context.Orders
    .Where(o => o.Status == OrderStatus.Pending && o.CreatedAt < cutoffDate)
    .ExecuteUpdateAsync(setters => setters
        .SetProperty(o => o.Status, OrderStatus.Cancelled)
        .SetProperty(o => o.CancelledAt, DateTime.UtcNow));
// Direct SQL: UPDATE Orders SET Status = 'Cancelled', CancelledAt = @p0 WHERE ...

// EF Core 7+ Bulk Delete
await context.Orders
    .Where(o => o.IsDeleted && o.DeletedAt < archiveDate)
    .ExecuteDeleteAsync();
// Direct SQL: DELETE FROM Orders WHERE IsDeleted = 1 AND DeletedAt < @p0

// Before EF Core 7, use third-party libraries like EFCore.BulkExtensions
await context.BulkInsertAsync(newOrders);
await context.BulkUpdateAsync(updatedOrders);
await context.BulkDeleteAsync(ordersToDelete);
await context.BulkInsertOrUpdateAsync(orders); // Upsert
```

---

## 7. Migrations & Schema Management

### Migration Commands

```bash
# Create migration
dotnet ef migrations add InitialCreate
dotnet ef migrations add AddOrderStatus --context ApplicationDbContext

# View pending migrations
dotnet ef migrations list

# Apply migrations to database
dotnet ef database update
dotnet ef database update AddOrderStatus  # Update to specific migration

# Rollback migration
dotnet ef database update PreviousMigrationName
dotnet ef database update 0  # Rollback all migrations

# Generate SQL script
dotnet ef migrations script  # All migrations
dotnet ef migrations script InitialCreate AddOrderStatus  # Range
dotnet ef migrations script --idempotent  # Safe for repeated execution

# Remove last migration (only if not applied)
dotnet ef migrations remove

# Drop database
dotnet ef database drop
```

### Migration Best Practices

```csharp
// Migration file structure
public partial class AddOrderStatus : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Forward migration
        migrationBuilder.AddColumn<int>(
            name: "Status",
            table: "Orders",
            type: "int",
            nullable: false,
            defaultValue: 0);

        // Create index
        migrationBuilder.CreateIndex(
            name: "IX_Orders_Status",
            table: "Orders",
            column: "Status");

        // Custom SQL
        migrationBuilder.Sql(@"
            UPDATE Orders
            SET Status = 1
            WHERE Status = 0 AND CreatedAt < '2024-01-01'
        ");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        // Rollback migration
        migrationBuilder.DropIndex(
            name: "IX_Orders_Status",
            table: "Orders");

        migrationBuilder.DropColumn(
            name: "Status",
            table: "Orders");
    }
}

// Apply migrations at startup (for development/testing)
public static void Main(string[] args)
{
    var host = CreateHostBuilder(args).Build();

    using (var scope = host.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        context.Database.Migrate(); // Apply pending migrations
    }

    host.Run();
}

// Production: Use SQL scripts
// Generate idempotent script and apply through CI/CD pipeline
```

---

## 8. Performance Optimization

### Query Performance Checklist

```csharp
// 1. Use projections - don't load unnecessary columns
// BAD
var orders = await context.Orders.ToListAsync();
var totals = orders.Select(o => o.Total);

// GOOD
var totals = await context.Orders.Select(o => o.Total).ToListAsync();

// 2. Use AsNoTracking for read-only queries
var orders = await context.Orders
    .AsNoTracking()
    .Where(o => o.Status == OrderStatus.Pending)
    .ToListAsync();

// 3. Avoid N+1 - use Include or projections
// BAD
var orders = await context.Orders.ToListAsync();
foreach (var order in orders)
{
    Console.WriteLine(order.Customer.Name); // N+1!
}

// GOOD
var orders = await context.Orders
    .Include(o => o.Customer)
    .ToListAsync();

// BETTER (projection)
var orderData = await context.Orders
    .Select(o => new { o.Id, CustomerName = o.Customer.Name })
    .ToListAsync();

// 4. Use pagination
var page = await context.Orders
    .OrderBy(o => o.Id)
    .Skip(pageSize * (pageNumber - 1))
    .Take(pageSize)
    .ToListAsync();

// 5. Use compiled queries for hot paths
private static readonly Func<ApplicationDbContext, int, Task<Order?>> GetOrderById =
    EF.CompileAsyncQuery((ApplicationDbContext context, int id) =>
        context.Orders.FirstOrDefault(o => o.Id == id));

// Usage
var order = await GetOrderById(context, orderId);

// 6. Use indexes strategically
modelBuilder.Entity<Order>()
    .HasIndex(o => o.CustomerId)
    .HasIndex(o => o.Status)
    .HasIndex(o => new { o.CustomerId, o.OrderDate });

// 7. Batch operations
await context.Orders
    .Where(o => o.Status == OrderStatus.Pending)
    .ExecuteUpdateAsync(s => s.SetProperty(o => o.Status, OrderStatus.Processing));
```

### Query Analysis & Logging

```csharp
// Enable logging
services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString)
           .LogTo(Console.WriteLine, LogLevel.Information)
           .EnableSensitiveDataLogging()); // Shows parameter values

// Log to ILogger
services.AddDbContext<ApplicationDbContext>((provider, options) =>
    options.UseSqlServer(connectionString)
           .LogTo(
               provider.GetRequiredService<ILogger<ApplicationDbContext>>().LogInformation,
               new[] { DbLoggerCategory.Database.Command.Name },
               LogLevel.Information));

// Get SQL for a query
var query = context.Orders.Where(o => o.Total > 100);
var sql = query.ToQueryString();
Console.WriteLine(sql);

// Add query tags for debugging
var orders = await context.Orders
    .TagWith("GetPendingOrders - Called from OrderService.GetPendingAsync")
    .Where(o => o.Status == OrderStatus.Pending)
    .ToListAsync();
// SQL includes: -- GetPendingOrders - Called from OrderService.GetPendingAsync
```

---

## 9. Advanced Patterns

### Repository Pattern

```csharp
// Generic repository interface
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(int id);
    Task<IReadOnlyList<T>> GetAllAsync();
    Task<IReadOnlyList<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(T entity);
}

// Generic repository implementation
public class Repository<T> : IRepository<T> where T : class
{
    protected readonly ApplicationDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public Repository(ApplicationDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public virtual async Task<T?> GetByIdAsync(int id)
    {
        return await _dbSet.FindAsync(id);
    }

    public virtual async Task<IReadOnlyList<T>> GetAllAsync()
    {
        return await _dbSet.ToListAsync();
    }

    public virtual async Task<IReadOnlyList<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(predicate).ToListAsync();
    }

    public virtual async Task<T> AddAsync(T entity)
    {
        await _dbSet.AddAsync(entity);
        await _context.SaveChangesAsync();
        return entity;
    }

    public virtual async Task UpdateAsync(T entity)
    {
        _dbSet.Attach(entity);
        _context.Entry(entity).State = EntityState.Modified;
        await _context.SaveChangesAsync();
    }

    public virtual async Task DeleteAsync(T entity)
    {
        _dbSet.Remove(entity);
        await _context.SaveChangesAsync();
    }
}

// Specialized repository with specific queries
public interface IOrderRepository : IRepository<Order>
{
    Task<IReadOnlyList<Order>> GetOrdersByCustomerAsync(int customerId);
    Task<IReadOnlyList<Order>> GetPendingOrdersAsync();
    Task<Order?> GetOrderWithItemsAsync(int orderId);
}

public class OrderRepository : Repository<Order>, IOrderRepository
{
    public OrderRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Order>> GetOrdersByCustomerAsync(int customerId)
    {
        return await _dbSet
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    public async Task<IReadOnlyList<Order>> GetPendingOrdersAsync()
    {
        return await _dbSet
            .Where(o => o.Status == OrderStatus.Pending)
            .Include(o => o.Customer)
            .ToListAsync();
    }

    public async Task<Order?> GetOrderWithItemsAsync(int orderId)
    {
        return await _dbSet
            .Include(o => o.Items)
                .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(o => o.Id == orderId);
    }
}
```

### Unit of Work Pattern

```csharp
public interface IUnitOfWork : IDisposable
{
    IOrderRepository Orders { get; }
    ICustomerRepository Customers { get; }
    IProductRepository Products { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private IDbContextTransaction? _transaction;

    private IOrderRepository? _orders;
    private ICustomerRepository? _customers;
    private IProductRepository? _products;

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
    }

    public IOrderRepository Orders => _orders ??= new OrderRepository(_context);
    public ICustomerRepository Customers => _customers ??= new CustomerRepository(_context);
    public IProductRepository Products => _products ??= new ProductRepository(_context);

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task BeginTransactionAsync()
    {
        _transaction = await _context.Database.BeginTransactionAsync();
    }

    public async Task CommitTransactionAsync()
    {
        try
        {
            await _context.SaveChangesAsync();
            await _transaction!.CommitAsync();
        }
        catch
        {
            await RollbackTransactionAsync();
            throw;
        }
        finally
        {
            _transaction?.Dispose();
            _transaction = null;
        }
    }

    public async Task RollbackTransactionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync();
            _transaction.Dispose();
            _transaction = null;
        }
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}

// Usage
public class OrderService
{
    private readonly IUnitOfWork _unitOfWork;

    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        await _unitOfWork.BeginTransactionAsync();

        try
        {
            var customer = await _unitOfWork.Customers.GetByIdAsync(request.CustomerId);

            var order = new Order
            {
                CustomerId = customer.Id,
                Status = OrderStatus.Pending
            };

            foreach (var item in request.Items)
            {
                var product = await _unitOfWork.Products.GetByIdAsync(item.ProductId);
                product.Stock -= item.Quantity;

                order.Items.Add(new OrderItem
                {
                    ProductId = product.Id,
                    Quantity = item.Quantity,
                    Price = product.Price
                });
            }

            await _unitOfWork.Orders.AddAsync(order);
            await _unitOfWork.CommitTransactionAsync();
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync();
            throw;
        }
    }
}
```

### Specification Pattern

```csharp
// Base specification
public interface ISpecification<T>
{
    Expression<Func<T, bool>> Criteria { get; }
    List<Expression<Func<T, object>>> Includes { get; }
    List<string> IncludeStrings { get; }
    Expression<Func<T, object>>? OrderBy { get; }
    Expression<Func<T, object>>? OrderByDescending { get; }
    int Take { get; }
    int Skip { get; }
    bool IsPagingEnabled { get; }
}

public abstract class BaseSpecification<T> : ISpecification<T>
{
    public Expression<Func<T, bool>> Criteria { get; private set; }
    public List<Expression<Func<T, object>>> Includes { get; } = new();
    public List<string> IncludeStrings { get; } = new();
    public Expression<Func<T, object>>? OrderBy { get; private set; }
    public Expression<Func<T, object>>? OrderByDescending { get; private set; }
    public int Take { get; private set; }
    public int Skip { get; private set; }
    public bool IsPagingEnabled { get; private set; }

    protected BaseSpecification() { }

    protected BaseSpecification(Expression<Func<T, bool>> criteria)
    {
        Criteria = criteria;
    }

    protected void AddInclude(Expression<Func<T, object>> includeExpression)
    {
        Includes.Add(includeExpression);
    }

    protected void AddInclude(string includeString)
    {
        IncludeStrings.Add(includeString);
    }

    protected void AddOrderBy(Expression<Func<T, object>> orderByExpression)
    {
        OrderBy = orderByExpression;
    }

    protected void AddOrderByDescending(Expression<Func<T, object>> orderByDescExpression)
    {
        OrderByDescending = orderByDescExpression;
    }

    protected void ApplyPaging(int skip, int take)
    {
        Skip = skip;
        Take = take;
        IsPagingEnabled = true;
    }
}

// Concrete specification
public class OrdersForCustomerSpecification : BaseSpecification<Order>
{
    public OrdersForCustomerSpecification(int customerId)
        : base(o => o.CustomerId == customerId)
    {
        AddInclude(o => o.Items);
        AddOrderByDescending(o => o.CreatedAt);
    }
}

public class PendingOrdersSpecification : BaseSpecification<Order>
{
    public PendingOrdersSpecification(int pageIndex, int pageSize)
        : base(o => o.Status == OrderStatus.Pending)
    {
        AddInclude(o => o.Customer);
        AddOrderBy(o => o.CreatedAt);
        ApplyPaging((pageIndex - 1) * pageSize, pageSize);
    }
}

// Specification evaluator
public static class SpecificationEvaluator<T> where T : class
{
    public static IQueryable<T> GetQuery(IQueryable<T> inputQuery, ISpecification<T> spec)
    {
        var query = inputQuery;

        if (spec.Criteria != null)
        {
            query = query.Where(spec.Criteria);
        }

        query = spec.Includes.Aggregate(query, (current, include) => current.Include(include));
        query = spec.IncludeStrings.Aggregate(query, (current, include) => current.Include(include));

        if (spec.OrderBy != null)
        {
            query = query.OrderBy(spec.OrderBy);
        }
        else if (spec.OrderByDescending != null)
        {
            query = query.OrderByDescending(spec.OrderByDescending);
        }

        if (spec.IsPagingEnabled)
        {
            query = query.Skip(spec.Skip).Take(spec.Take);
        }

        return query;
    }
}

// Usage
public async Task<List<Order>> GetOrdersAsync(ISpecification<Order> spec)
{
    return await SpecificationEvaluator<Order>
        .GetQuery(_context.Orders.AsQueryable(), spec)
        .ToListAsync();
}

// Call
var spec = new PendingOrdersSpecification(pageIndex: 2, pageSize: 10);
var orders = await _orderRepository.GetOrdersAsync(spec);
```

---

## 10. Concurrency & Transactions

### Optimistic Concurrency

```csharp
// Using RowVersion/Timestamp
public class Order
{
    public int Id { get; set; }
    public decimal Total { get; set; }

    [Timestamp]
    public byte[] RowVersion { get; set; }
}

// Fluent API
modelBuilder.Entity<Order>()
    .Property(o => o.RowVersion)
    .IsRowVersion();

// Alternative: Concurrency token on specific property
public class Product
{
    public int Id { get; set; }

    [ConcurrencyCheck]
    public int Stock { get; set; }
}

// Handle concurrency conflicts
public async Task UpdateOrderAsync(OrderUpdateDto dto)
{
    var order = await _context.Orders.FindAsync(dto.Id);

    order.Total = dto.Total;
    order.RowVersion = dto.RowVersion; // Client sends original RowVersion

    try
    {
        await _context.SaveChangesAsync();
    }
    catch (DbUpdateConcurrencyException ex)
    {
        var entry = ex.Entries.Single();
        var databaseValues = await entry.GetDatabaseValuesAsync();

        if (databaseValues == null)
        {
            throw new NotFoundException("Order was deleted");
        }

        var dbOrder = (Order)databaseValues.ToObject();

        // Option 1: Client wins (overwrite)
        entry.OriginalValues.SetValues(databaseValues);
        await _context.SaveChangesAsync();

        // Option 2: Database wins (discard client changes)
        entry.CurrentValues.SetValues(databaseValues);
        entry.State = EntityState.Unchanged;

        // Option 3: Merge (resolve conflicts)
        var resolvedOrder = MergeOrders(order, dbOrder);
        entry.CurrentValues.SetValues(resolvedOrder);
        entry.OriginalValues.SetValues(databaseValues);
        await _context.SaveChangesAsync();

        // Option 4: Throw to let user decide
        throw new ConcurrencyException("Order was modified by another user", dbOrder);
    }
}
```

### Transactions

```csharp
// Implicit transaction (SaveChanges wraps in transaction)
var order = new Order { CustomerId = 1, Total = 100 };
_context.Orders.Add(order);
await _context.SaveChangesAsync(); // Single transaction

// Explicit transaction
using var transaction = await _context.Database.BeginTransactionAsync();

try
{
    var order = new Order { CustomerId = 1, Status = OrderStatus.Pending };
    _context.Orders.Add(order);
    await _context.SaveChangesAsync();

    var product = await _context.Products.FindAsync(productId);
    product.Stock -= quantity;
    await _context.SaveChangesAsync();

    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}

// Transaction with isolation level
using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);

// Distributed transaction (multiple DbContexts)
using var scope = new TransactionScope(TransactionScopeAsyncFlowOption.Enabled);

await _orderContext.SaveChangesAsync();
await _inventoryContext.SaveChangesAsync();

scope.Complete();

// Savepoints (partial rollback)
using var transaction = await _context.Database.BeginTransactionAsync();

_context.Orders.Add(order1);
await _context.SaveChangesAsync();
await transaction.CreateSavepointAsync("AfterOrder1");

try
{
    _context.Orders.Add(order2);
    await _context.SaveChangesAsync();
}
catch
{
    await transaction.RollbackToSavepointAsync("AfterOrder1");
    // order1 is still saved, order2 is rolled back
}

await transaction.CommitAsync();
```

---

## 11. Testing with EF Core

### In-Memory Provider

```csharp
public class OrderServiceTests
{
    private ApplicationDbContext CreateInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        var context = new ApplicationDbContext(options);

        // Seed test data
        context.Customers.Add(new Customer { Id = 1, Name = "Test Customer" });
        context.Products.Add(new Product { Id = 1, Name = "Test Product", Price = 100, Stock = 10 });
        context.SaveChanges();

        return context;
    }

    [Fact]
    public async Task CreateOrder_ShouldReduceStock()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var service = new OrderService(context);

        // Act
        await service.CreateOrderAsync(new CreateOrderRequest
        {
            CustomerId = 1,
            Items = new[] { new OrderItemRequest { ProductId = 1, Quantity = 3 } }
        });

        // Assert
        var product = await context.Products.FindAsync(1);
        Assert.Equal(7, product.Stock);
    }
}
```

### SQLite In-Memory

```csharp
// SQLite is closer to real database behavior than InMemory provider
public class IntegrationTestBase : IDisposable
{
    protected ApplicationDbContext Context { get; }
    private readonly SqliteConnection _connection;

    public IntegrationTestBase()
    {
        _connection = new SqliteConnection("Filename=:memory:");
        _connection.Open();

        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseSqlite(_connection)
            .Options;

        Context = new ApplicationDbContext(options);
        Context.Database.EnsureCreated();
    }

    public void Dispose()
    {
        Context.Dispose();
        _connection.Dispose();
    }
}

[Fact]
public async Task ComplexQuery_ShouldWork()
{
    // This test uses SQLite, so complex queries are actually tested
    var result = await Context.Orders
        .GroupBy(o => o.CustomerId)
        .Select(g => new { CustomerId = g.Key, Total = g.Sum(o => o.Total) })
        .ToListAsync();

    // InMemory provider doesn't support GroupBy in some scenarios
}
```

### Mocking DbContext

```csharp
// Using Moq with IQueryable
public class OrderServiceTests
{
    [Fact]
    public async Task GetPendingOrders_ShouldReturnOnlyPending()
    {
        // Arrange
        var orders = new List<Order>
        {
            new Order { Id = 1, Status = OrderStatus.Pending },
            new Order { Id = 2, Status = OrderStatus.Shipped },
            new Order { Id = 3, Status = OrderStatus.Pending }
        }.AsQueryable();

        var mockSet = new Mock<DbSet<Order>>();
        mockSet.As<IAsyncEnumerable<Order>>()
            .Setup(m => m.GetAsyncEnumerator(default))
            .Returns(new TestAsyncEnumerator<Order>(orders.GetEnumerator()));
        mockSet.As<IQueryable<Order>>().Setup(m => m.Provider)
            .Returns(new TestAsyncQueryProvider<Order>(orders.Provider));
        mockSet.As<IQueryable<Order>>().Setup(m => m.Expression).Returns(orders.Expression);
        mockSet.As<IQueryable<Order>>().Setup(m => m.ElementType).Returns(orders.ElementType);
        mockSet.As<IQueryable<Order>>().Setup(m => m.GetEnumerator()).Returns(orders.GetEnumerator());

        var mockContext = new Mock<ApplicationDbContext>();
        mockContext.Setup(c => c.Orders).Returns(mockSet.Object);

        var service = new OrderService(mockContext.Object);

        // Act
        var result = await service.GetPendingOrdersAsync();

        // Assert
        Assert.Equal(2, result.Count);
        Assert.All(result, o => Assert.Equal(OrderStatus.Pending, o.Status));
    }
}
```

---

## 12. Real-World Scenarios

### Scenario 1: E-Commerce Order Processing

```csharp
public class OrderProcessingService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<OrderProcessingService> _logger;

    public async Task<OrderResult> ProcessOrderAsync(CreateOrderRequest request)
    {
        // Start transaction
        await using var transaction = await _context.Database.BeginTransactionAsync();

        try
        {
            // 1. Validate customer
            var customer = await _context.Customers
                .Include(c => c.DefaultAddress)
                .FirstOrDefaultAsync(c => c.Id == request.CustomerId);

            if (customer == null)
                throw new NotFoundException("Customer not found");

            // 2. Load products with stock check (pessimistic locking)
            var productIds = request.Items.Select(i => i.ProductId).ToList();
            var products = await _context.Products
                .Where(p => productIds.Contains(p.Id))
                .ToListAsync();

            // 3. Validate stock and calculate totals
            var orderItems = new List<OrderItem>();
            decimal total = 0;

            foreach (var item in request.Items)
            {
                var product = products.FirstOrDefault(p => p.Id == item.ProductId);
                if (product == null)
                    throw new NotFoundException($"Product {item.ProductId} not found");

                if (product.Stock < item.Quantity)
                    throw new InsufficientStockException(product.Name, product.Stock, item.Quantity);

                // Reduce stock
                product.Stock -= item.Quantity;

                var orderItem = new OrderItem
                {
                    ProductId = product.Id,
                    Quantity = item.Quantity,
                    UnitPrice = product.Price,
                    Total = product.Price * item.Quantity
                };

                orderItems.Add(orderItem);
                total += orderItem.Total;
            }

            // 4. Apply discount
            var discount = await CalculateDiscountAsync(customer, total);
            total -= discount;

            // 5. Create order
            var order = new Order
            {
                CustomerId = customer.Id,
                OrderNumber = await GenerateOrderNumberAsync(),
                Status = OrderStatus.Pending,
                SubTotal = orderItems.Sum(i => i.Total),
                Discount = discount,
                Total = total,
                ShippingAddressId = request.ShippingAddressId ?? customer.DefaultAddressId,
                Items = orderItems,
                CreatedAt = DateTime.UtcNow
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // 6. Commit transaction
            await transaction.CommitAsync();

            _logger.LogInformation("Order {OrderNumber} created for customer {CustomerId}",
                order.OrderNumber, customer.Id);

            return new OrderResult
            {
                OrderId = order.Id,
                OrderNumber = order.OrderNumber,
                Total = order.Total
            };
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            _logger.LogError(ex, "Failed to process order for customer {CustomerId}", request.CustomerId);
            throw;
        }
    }

    private async Task<string> GenerateOrderNumberAsync()
    {
        var today = DateTime.UtcNow.ToString("yyyyMMdd");
        var count = await _context.Orders
            .CountAsync(o => o.OrderNumber.StartsWith($"ORD-{today}"));
        return $"ORD-{today}-{count + 1:D4}";
    }
}
```

### Scenario 2: Reporting with Complex Aggregations

```csharp
public class SalesReportService
{
    public async Task<SalesReport> GenerateMonthlySalesReportAsync(int year, int month)
    {
        var startDate = new DateTime(year, month, 1);
        var endDate = startDate.AddMonths(1);

        // Main sales data
        var salesData = await _context.Orders
            .Where(o => o.CreatedAt >= startDate && o.CreatedAt < endDate)
            .Where(o => o.Status != OrderStatus.Cancelled)
            .GroupBy(o => o.CreatedAt.Date)
            .Select(g => new DailySales
            {
                Date = g.Key,
                OrderCount = g.Count(),
                TotalRevenue = g.Sum(o => o.Total),
                AverageOrderValue = g.Average(o => o.Total)
            })
            .OrderBy(d => d.Date)
            .ToListAsync();

        // Top products
        var topProducts = await _context.OrderItems
            .Where(oi => oi.Order.CreatedAt >= startDate && oi.Order.CreatedAt < endDate)
            .Where(oi => oi.Order.Status != OrderStatus.Cancelled)
            .GroupBy(oi => new { oi.ProductId, oi.Product.Name })
            .Select(g => new TopProduct
            {
                ProductId = g.Key.ProductId,
                ProductName = g.Key.Name,
                QuantitySold = g.Sum(oi => oi.Quantity),
                Revenue = g.Sum(oi => oi.Total)
            })
            .OrderByDescending(p => p.Revenue)
            .Take(10)
            .ToListAsync();

        // Sales by category
        var salesByCategory = await _context.OrderItems
            .Where(oi => oi.Order.CreatedAt >= startDate && oi.Order.CreatedAt < endDate)
            .Where(oi => oi.Order.Status != OrderStatus.Cancelled)
            .GroupBy(oi => oi.Product.Category.Name)
            .Select(g => new CategorySales
            {
                CategoryName = g.Key,
                Revenue = g.Sum(oi => oi.Total),
                PercentageOfTotal = 0 // Calculated after
            })
            .ToListAsync();

        var totalRevenue = salesByCategory.Sum(c => c.Revenue);
        foreach (var category in salesByCategory)
        {
            category.PercentageOfTotal = totalRevenue > 0
                ? (category.Revenue / totalRevenue) * 100
                : 0;
        }

        // Customer metrics
        var customerMetrics = await _context.Orders
            .Where(o => o.CreatedAt >= startDate && o.CreatedAt < endDate)
            .Where(o => o.Status != OrderStatus.Cancelled)
            .Select(o => new { o.CustomerId, o.Total })
            .GroupBy(o => o.CustomerId)
            .Select(g => new
            {
                CustomerId = g.Key,
                TotalSpent = g.Sum(o => o.Total),
                OrderCount = g.Count()
            })
            .ToListAsync();

        var newCustomers = await _context.Customers
            .CountAsync(c => c.CreatedAt >= startDate && c.CreatedAt < endDate);

        return new SalesReport
        {
            Year = year,
            Month = month,
            TotalRevenue = salesData.Sum(d => d.TotalRevenue),
            TotalOrders = salesData.Sum(d => d.OrderCount),
            AverageOrderValue = salesData.Average(d => d.AverageOrderValue),
            DailySales = salesData,
            TopProducts = topProducts,
            SalesByCategory = salesByCategory,
            NewCustomers = newCustomers,
            RepeatCustomerRate = customerMetrics.Count(c => c.OrderCount > 1) / (decimal)customerMetrics.Count * 100,
            GeneratedAt = DateTime.UtcNow
        };
    }
}
```

### Scenario 3: Soft Delete with Global Query Filters

```csharp
// Interface for soft-deletable entities
public interface ISoftDeletable
{
    bool IsDeleted { get; set; }
    DateTime? DeletedAt { get; set; }
    string? DeletedBy { get; set; }
}

// Entity implementation
public class Order : ISoftDeletable
{
    public int Id { get; set; }
    public string OrderNumber { get; set; }
    // ... other properties

    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
    public string? DeletedBy { get; set; }
}

// Configure global filter
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    foreach (var entityType in modelBuilder.Model.GetEntityTypes())
    {
        if (typeof(ISoftDeletable).IsAssignableFrom(entityType.ClrType))
        {
            var parameter = Expression.Parameter(entityType.ClrType, "e");
            var property = Expression.Property(parameter, nameof(ISoftDeletable.IsDeleted));
            var filter = Expression.Lambda(Expression.Not(property), parameter);

            modelBuilder.Entity(entityType.ClrType).HasQueryFilter(filter);
        }
    }
}

// Override SaveChanges to handle soft delete
public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
{
    foreach (var entry in ChangeTracker.Entries<ISoftDeletable>())
    {
        if (entry.State == EntityState.Deleted)
        {
            entry.State = EntityState.Modified;
            entry.Entity.IsDeleted = true;
            entry.Entity.DeletedAt = DateTime.UtcNow;
            entry.Entity.DeletedBy = _currentUser.Id;
        }
    }

    return await base.SaveChangesAsync(cancellationToken);
}

// Query includes deleted (admin scenario)
var allOrders = await _context.Orders
    .IgnoreQueryFilters()
    .ToListAsync();

// Query only deleted
var deletedOrders = await _context.Orders
    .IgnoreQueryFilters()
    .Where(o => o.IsDeleted)
    .ToListAsync();
```

---

## 13. Interview Questions & Answers

### Q1: What is the difference between IEnumerable and IQueryable?

**Answer:**

"The key difference is where the query executes:

**IEnumerable<T>**: Executes in memory. When you call `Where()` or other LINQ methods on IEnumerable, all data is loaded into memory first, then filtered. This is called LINQ to Objects.

**IQueryable<T>**: Executes on the data source (database). LINQ expressions are converted to an expression tree, which is then translated to SQL by the provider. Filtering happens at the database level.

In practice, this means:
```csharp
// Bad - loads ALL orders, then filters in memory
IEnumerable<Order> orders = context.Orders;
var filtered = orders.Where(o => o.Total > 100);

// Good - generates SQL with WHERE clause
IQueryable<Order> orders = context.Orders;
var filtered = orders.Where(o => o.Total > 100);
```

A common mistake is calling `AsEnumerable()` too early, which forces the rest of the query to execute in memory. Always keep queries as IQueryable until you need to materialize results."

---

### Q2: Explain the N+1 query problem and how to solve it.

**Answer:**

"The N+1 problem occurs when loading a list of entities (1 query) and then accessing a related property for each entity (N queries), resulting in N+1 total queries.

Example:
```csharp
var orders = context.Orders.ToList(); // 1 query
foreach (var order in orders)
{
    Console.WriteLine(order.Customer.Name); // N queries!
}
```

If you have 100 orders, this executes 101 queries!

**Solutions:**

1. **Eager Loading** with Include:
```csharp
var orders = context.Orders
    .Include(o => o.Customer)
    .ToList();
```

2. **Projection** to DTO (often best for APIs):
```csharp
var orders = context.Orders
    .Select(o => new { o.Id, CustomerName = o.Customer.Name })
    .ToList();
```

3. **Explicit Loading** for conditional loading:
```csharp
var order = context.Orders.Find(1);
if (needsCustomer)
{
    context.Entry(order).Reference(o => o.Customer).Load();
}
```

For production, I prefer projections because they select only needed columns and work well with DTOs for APIs."

---

### Q3: What are the different entity states in EF Core?

**Answer:**

"EF Core tracks entities in five states:

1. **Detached**: Entity is not tracked by the context. New entities before Add() or entities from a different context.

2. **Unchanged**: Entity is tracked and hasn't changed since being queried. No action on SaveChanges.

3. **Added**: New entity scheduled for INSERT. Created by Add() or Attach() with key = 0.

4. **Modified**: Existing entity with property changes. Will generate UPDATE on SaveChanges.

5. **Deleted**: Marked for removal. Will generate DELETE on SaveChanges.

State transitions:
```csharp
var order = new Order();           // Detached
context.Orders.Add(order);         // Added
await context.SaveChangesAsync();  // Unchanged
order.Total = 500;                 // Modified (auto-detected)
context.Orders.Remove(order);      // Deleted
await context.SaveChangesAsync();  // Detached (deleted from DB)
```

For disconnected scenarios like Web APIs, you manually set state:
```csharp
context.Entry(order).State = EntityState.Modified;
```"

---

### Q4: How would you handle concurrency conflicts?

**Answer:**

"I use optimistic concurrency with a RowVersion column:

```csharp
public class Order
{
    public int Id { get; set; }
    [Timestamp]
    public byte[] RowVersion { get; set; }
}
```

EF Core includes RowVersion in the WHERE clause:
```sql
UPDATE Orders SET Total = @Total WHERE Id = @Id AND RowVersion = @RowVersion
```

If the row was modified, the UPDATE affects 0 rows, and EF throws `DbUpdateConcurrencyException`.

I handle it based on business requirements:

```csharp
try
{
    await context.SaveChangesAsync();
}
catch (DbUpdateConcurrencyException ex)
{
    var entry = ex.Entries.Single();
    var dbValues = await entry.GetDatabaseValuesAsync();

    // Option 1: Last write wins
    entry.OriginalValues.SetValues(dbValues);
    await context.SaveChangesAsync();

    // Option 2: First write wins
    entry.CurrentValues.SetValues(dbValues);

    // Option 3: Merge and let user decide
    throw new ConcurrencyException(currentValue, dbValue);
}
```

For high-contention scenarios, I might use pessimistic locking with `UPDLOCK` hints in raw SQL."

---

### Q5: Explain AsNoTracking and when to use it.

**Answer:**

"AsNoTracking tells EF Core not to track returned entities in the change tracker. This provides:

1. **Better Performance**: No change tracking overhead, faster queries
2. **Lower Memory**: Entities aren't held in memory by the context
3. **No Accidental Updates**: Changes to entities won't be persisted

Use it for:
- **Read-only queries**: Displaying data, reports, exports
- **High-volume reads**: Where performance is critical
- **Disconnected scenarios**: When you'll serialize and send to client

```csharp
// Read-only - 30-50% faster
var orders = await context.Orders
    .AsNoTracking()
    .Where(o => o.Status == OrderStatus.Pending)
    .ToListAsync();
```

Don't use it when:
- You need to update the entities afterward
- You're using lazy loading (won't work without tracking)

**AsNoTrackingWithIdentityResolution** (EF Core 5+) is useful when you have multiple references to the same entity - it ensures they're the same instance without full tracking."

---

### Q6: How do you optimize EF Core performance?

**Answer:**

"My performance optimization checklist:

1. **Use Projections**: Select only needed columns
```csharp
.Select(o => new { o.Id, o.Total })
```

2. **Add AsNoTracking**: For read-only queries
```csharp
.AsNoTracking()
```

3. **Avoid N+1**: Use Include or projections
```csharp
.Include(o => o.Customer)
```

4. **Use Compiled Queries**: For frequently executed queries
```csharp
private static readonly Func<AppContext, int, Task<Order>> GetOrder =
    EF.CompileAsyncQuery((AppContext ctx, int id) =>
        ctx.Orders.FirstOrDefault(o => o.Id == id));
```

5. **Add Indexes**: On frequently filtered/joined columns
```csharp
builder.HasIndex(o => o.CustomerId);
```

6. **Use Bulk Operations**: For mass updates/deletes
```csharp
await context.Orders
    .Where(o => o.Status == OrderStatus.Old)
    .ExecuteDeleteAsync();
```

7. **DbContext Pooling**: Reduces context creation overhead
```csharp
services.AddDbContextPool<AppContext>(options => ...);
```

8. **Split Queries**: For multiple collection includes
```csharp
.AsSplitQuery()
```

I also enable SQL logging in development to catch inefficient queries early."

---

### Q7: What's the difference between Add, Attach, and Update?

**Answer:**

"They differ in how they set entity state:

**Add**: Sets state to `Added`. Entity will be INSERTed.
```csharp
context.Orders.Add(order);  // State = Added
// Works for new entities (Id = 0)
```

**Attach**: Sets state to `Unchanged`. Entity is tracked but won't be saved unless modified.
```csharp
context.Orders.Attach(order);  // State = Unchanged
order.Total = 500;             // State = Modified
// Use when you have an entity from outside the context
```

**Update**: Sets state to `Modified`. Entity will be UPDATEd (all columns!).
```csharp
context.Orders.Update(order);  // State = Modified
// Updates ALL columns, not just changed ones
```

For partial updates in APIs, I prefer:
```csharp
var order = new Order { Id = dto.Id };
context.Attach(order);
context.Entry(order).Property(o => o.Total).IsModified = true;
order.Total = dto.Total;
await context.SaveChangesAsync();
// Only updates Total column
```

Or with EF Core 7+:
```csharp
await context.Orders
    .Where(o => o.Id == dto.Id)
    .ExecuteUpdateAsync(s => s.SetProperty(o => o.Total, dto.Total));
```"

---

### Q8: How do you handle transactions in EF Core?

**Answer:**

"EF Core has implicit and explicit transactions:

**Implicit**: SaveChanges wraps all changes in a transaction automatically.
```csharp
context.Orders.Add(order);
context.Products.Update(product);
await context.SaveChangesAsync(); // Both in same transaction
```

**Explicit**: For spanning multiple SaveChanges or complex scenarios.
```csharp
using var transaction = await context.Database.BeginTransactionAsync();

try
{
    context.Orders.Add(order);
    await context.SaveChangesAsync(); // First batch

    product.Stock -= quantity;
    await context.SaveChangesAsync(); // Second batch

    await transaction.CommitAsync();
}
catch
{
    await transaction.RollbackAsync();
    throw;
}
```

**Distributed transactions** across multiple contexts:
```csharp
using var scope = new TransactionScope(TransactionScopeAsyncFlowOption.Enabled);

await orderContext.SaveChangesAsync();
await inventoryContext.SaveChangesAsync();

scope.Complete();
```

**Savepoints** for partial rollback (SQL Server):
```csharp
await transaction.CreateSavepointAsync('AfterOrders');
// If next operation fails
await transaction.RollbackToSavepointAsync('AfterOrders');
```

I also consider isolation levels based on requirements - ReadCommitted for most cases, Serializable for financial transactions."

---

### Q9: Describe the Repository and Unit of Work patterns with EF Core.

**Answer:**

"**Repository Pattern** abstracts data access:
```csharp
public interface IOrderRepository
{
    Task<Order> GetByIdAsync(int id);
    Task<List<Order>> GetPendingOrdersAsync();
    Task AddAsync(Order order);
}
```

**Unit of Work** coordinates multiple repositories in a single transaction:
```csharp
public interface IUnitOfWork
{
    IOrderRepository Orders { get; }
    IProductRepository Products { get; }
    Task<int> SaveChangesAsync();
}
```

**Benefits**:
- Testability (mock repositories)
- Consistent data access patterns
- Transaction coordination
- Domain-specific query methods

**Controversy**: Some argue DbContext IS already a Unit of Work and DbSet IS a Repository. Adding another layer creates unnecessary abstraction.

**My approach**:
- For simple CRUD apps: Use DbContext directly
- For complex domains: Use repositories with specification pattern
- Always: Avoid exposing IQueryable from repositories (leaky abstraction)

Instead of:
```csharp
IQueryable<Order> GetOrders(); // Leaky!
```

I prefer:
```csharp
Task<List<Order>> GetOrdersAsync(OrderFilter filter); // Explicit
```"

---

### Q10: How would you implement soft delete with EF Core?

**Answer:**

"I use global query filters for soft delete:

1. **Define interface**:
```csharp
public interface ISoftDeletable
{
    bool IsDeleted { get; set; }
    DateTime? DeletedAt { get; set; }
}
```

2. **Configure global filter**:
```csharp
modelBuilder.Entity<Order>()
    .HasQueryFilter(o => !o.IsDeleted);
```

3. **Override SaveChanges** to intercept Delete:
```csharp
public override Task<int> SaveChangesAsync(...)
{
    foreach (var entry in ChangeTracker.Entries<ISoftDeletable>()
        .Where(e => e.State == EntityState.Deleted))
    {
        entry.State = EntityState.Modified;
        entry.Entity.IsDeleted = true;
        entry.Entity.DeletedAt = DateTime.UtcNow;
    }
    return base.SaveChangesAsync(...);
}
```

4. **Query deleted items when needed**:
```csharp
// Include deleted
var all = await context.Orders.IgnoreQueryFilters().ToListAsync();

// Only deleted
var deleted = await context.Orders
    .IgnoreQueryFilters()
    .Where(o => o.IsDeleted)
    .ToListAsync();
```

**Considerations**:
- Foreign keys: Soft-deleted parents with non-deleted children
- Unique constraints: Deleted items might violate uniqueness
- Performance: Filter adds WHERE clause to all queries
- GDPR: Soft delete may not satisfy 'right to erasure'

For audit trails, I combine soft delete with temporal tables in SQL Server."

---

## Quick Reference

### Common EF Core Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `Find(id)` | Get by PK (cache first) | Entity or null |
| `First()` | First element | Entity (throws if empty) |
| `FirstOrDefault()` | First or null | Entity or null |
| `Single()` | Exactly one | Entity (throws if 0 or >1) |
| `ToList()` | Execute query | List<T> |
| `Count()` | Count elements | int |
| `Any()` | Has elements? | bool |
| `Include()` | Eager load | IQueryable |
| `AsNoTracking()` | Disable tracking | IQueryable |
| `ExecuteUpdate()` | Bulk update | int (rows affected) |
| `ExecuteDelete()` | Bulk delete | int (rows affected) |

### LINQ Method to SQL Mapping

| LINQ | SQL |
|------|-----|
| `Where()` | WHERE |
| `Select()` | SELECT |
| `OrderBy()` | ORDER BY |
| `GroupBy()` | GROUP BY |
| `Join()` | INNER JOIN |
| `Include()` | LEFT JOIN |
| `Skip().Take()` | OFFSET FETCH |
| `Count()` | COUNT(*) |
| `Sum()` | SUM() |
| `Any()` | EXISTS |
| `Contains()` | IN |
| `Distinct()` | DISTINCT |

---

## Summary

This guide covered Entity Framework Core and LINQ comprehensively:

1. **LINQ**: IEnumerable vs IQueryable, operators, deferred execution
2. **EF Core Architecture**: DbContext, entity states, change tracking
3. **Configuration**: Fluent API, relationships, conventions
4. **Querying**: Projections, filtering, grouping, raw SQL
5. **Loading Strategies**: Eager, lazy, explicit, split queries
6. **Performance**: AsNoTracking, compiled queries, bulk operations
7. **Advanced Patterns**: Repository, Unit of Work, Specification
8. **Concurrency**: Optimistic locking, conflict resolution
9. **Testing**: In-memory, SQLite, mocking

**Key Takeaways for Interviews**:
- Always explain the "why" behind your choices
- Discuss trade-offs (performance vs. complexity)
- Mention real-world experience with specific patterns
- Know the N+1 problem inside and out
- Understand when NOT to use patterns (over-engineering)
