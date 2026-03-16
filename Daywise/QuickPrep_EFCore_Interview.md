# Entity Framework Core — Quick Interview Prep
### Focused · Code-Heavy · STEP-Annotated · Interview-Targeted

> **How to use:** Each section = one interview topic. Read the Mental Model, scan the code with STEP comments, check the Q&A bullets. ~90 min cover-to-cover.

---

## Table of Contents
- [1 — DbContext & DbSet — The Core Contract](#1--dbcontext--dbset)
- [2 — Relationships (1:1, 1:N, M:N)](#2--relationships)
- [3 — Querying: LINQ → SQL Translation](#3--querying-linq--sql-translation)
- [4 — Change Tracking](#4--change-tracking)
- [5 — Migrations](#5--migrations)
- [6 — Loading Strategies (Eager / Lazy / Explicit)](#6--loading-strategies)
- [7 — Raw SQL & Stored Procedures](#7--raw-sql--stored-procedures)
- [8 — Transactions & Concurrency](#8--transactions--concurrency)
- [9 — Performance Patterns](#9--performance-patterns)
- [10 — Repository & Unit of Work Patterns](#10--repository--unit-of-work)
- [11 — Testing with EF Core (InMemory / SQLite)](#11--testing)
- [12 — Top 30 Interview Q&A](#12--top-30-interview-qa)

---

## 1 — DbContext & DbSet

> **🧠 Mental Model: DbContext = a shopping cart session.**
> Items you put in (Add), modify (Update), or remove (Remove) are tracked in memory. Nothing hits the DB until you call `SaveChanges()` — that's the checkout.

```
DbContext lifecycle:
  ┌──────────────────────────────────────────────┐
  │  DbContext (scoped per request in ASP.NET)   │
  │  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
  │  │ DbSet<T> │  │ DbSet<T> │  │ DbSet<T>  │  │
  │  │ Products │  │ Orders   │  │ Customers │  │
  │  └──────────┘  └──────────┘  └───────────┘  │
  │                                              │
  │  ChangeTracker → tracks Added/Modified/Deleted│
  │  SaveChanges() → flushes to DB in 1 txn      │
  └──────────────────────────────────────────────┘
```

```csharp
// ─── ENTITY ───
public class Product {
    public int Id { get; set; }               // PK by convention (Id or <Type>Id)
    public string Name { get; set; } = "";
    public decimal Price { get; set; }
    public int CategoryId { get; set; }       // FK by convention
    public Category Category { get; set; }    // navigation property
}

// ─── DbContext ───
public class AppDbContext : DbContext {
    // STEP 1: Declare DbSet for each entity — maps to a DB table
    public DbSet<Product> Products { get; set; }
    public DbSet<Category> Categories { get; set; }

    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options) { }

    protected override void OnModelCreating(ModelBuilder modelBuilder) {
        // STEP 2: Fluent API config overrides conventions
        modelBuilder.Entity<Product>(e => {
            e.HasKey(p => p.Id);
            e.Property(p => p.Name).IsRequired().HasMaxLength(200);
            e.Property(p => p.Price).HasColumnType("decimal(18,2)");
            // STEP 3: Define relationship + delete behavior
            e.HasOne(p => p.Category)
             .WithMany(c => c.Products)
             .HasForeignKey(p => p.CategoryId)
             .OnDelete(DeleteBehavior.Restrict); // WHY Restrict? Prevent accidental cascade deletes
        });
    }
}

// ─── Registration (Program.cs) ───
// STEP 4: Register DbContext as Scoped (one instance per HTTP request)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("Default")));
// WHY Scoped? DbContext is NOT thread-safe — one per request ensures isolation
```

**Key Interview Points:**
- `DbContext` should be **Scoped** in DI — never Singleton (thread-safety), never Transient (expensive)
- Conventions: `Id` or `<TypeName>Id` → PK auto-detected; nav property + FK → relationship auto-detected
- Fluent API > Data Annotations for complex configs (richer, keeps entity clean)

---

## 2 — Relationships

> **🧠 Mental Model: Relationships = foreign keys + navigation properties.**
> EF infers relationship type from cardinality of navigation properties. You make it explicit with Fluent API.

```
1:N  →  HasOne(...).WithMany(...)
M:N  →  HasMany(...).WithMany(...)   ← EF 5+ auto join table
1:1  →  HasOne(...).WithOne(...)
```

```csharp
// ─── ONE-TO-MANY ───
public class Order {
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public Customer Customer { get; set; }         // nav to parent
    public List<OrderItem> Items { get; set; }     // nav to children
}

// ─── MANY-TO-MANY (EF Core 5+, skip navigation — no explicit join entity) ───
public class Student {
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public List<Course> Courses { get; set; } = new(); // M:N — EF creates join table
}
public class Course {
    public int Id { get; set; }
    public string Title { get; set; } = "";
    public List<Student> Students { get; set; } = new();
}
// Fluent config for M:N:
// modelBuilder.Entity<Student>().HasMany(s => s.Courses).WithMany(c => c.Students);

// ─── MANY-TO-MANY with payload (explicit join entity) ───
public class StudentCourse {
    public int StudentId { get; set; }
    public int CourseId { get; set; }
    public DateTime EnrolledAt { get; set; }      // extra data on join
    public Student Student { get; set; }
    public Course Course { get; set; }
}
// Fluent:
// modelBuilder.Entity<StudentCourse>().HasKey(sc => new { sc.StudentId, sc.CourseId });

// ─── ONE-TO-ONE ───
public class User {
    public int Id { get; set; }
    public UserProfile Profile { get; set; }       // optional 1:1
}
public class UserProfile {
    public int Id { get; set; }
    public int UserId { get; set; }               // FK on dependent side
    public User User { get; set; }
}
// Fluent:
// modelBuilder.Entity<User>().HasOne(u => u.Profile).WithOne(p => p.User)
//     .HasForeignKey<UserProfile>(p => p.UserId);
```

**Key Interview Points:**
- In 1:N, FK lives on the **many** (child) side
- In 1:1, FK lives on the **dependent** (less important) side
- `DeleteBehavior.Cascade` (default for required), `Restrict`, `SetNull`, `NoAction`
- M:N with payload → always use explicit join entity

---

## 3 — Querying: LINQ → SQL Translation

> **🧠 Mental Model: LINQ is a query description. SQL is executed only when you "materialize" (ToList, First, Count, etc.).**
> Before materialization, you're building an expression tree — no DB round trip yet.

```
IQueryable pipeline:
  _ctx.Products                          ← IQueryable<Product> (no query yet)
      .Where(p => p.Price > 10)         ← adds WHERE clause (still no query)
      .OrderBy(p => p.Name)             ← adds ORDER BY
      .Take(20)                         ← adds TOP 20
      .ToList()                         ← EXECUTES SQL → returns List<Product>
```

```csharp
// STEP 1: Build a deferred query (IQueryable — no DB hit yet)
IQueryable<Product> query = _ctx.Products
    .Where(p => p.Price > 10 && p.CategoryId == categoryId);

// STEP 2: Add optional filters dynamically (still deferred)
if (!string.IsNullOrEmpty(search))
    query = query.Where(p => p.Name.Contains(search)); // → SQL LIKE '%search%'

// STEP 3: Project to DTO to avoid over-fetching columns
// WHY Select/projection? Fetches only needed columns, not entire entity
var results = await query
    .OrderBy(p => p.Name)
    .Select(p => new ProductDto {          // STEP 3: project to DTO
        Id = p.Id,
        Name = p.Name,
        CategoryName = p.Category.Name    // JOIN generated automatically
    })
    .Skip((page - 1) * pageSize)          // STEP 4: pagination — OFFSET
    .Take(pageSize)                       // STEP 4: pagination — FETCH NEXT
    .ToListAsync();                       // STEP 5: materialize — SQL executes here

// ─── COMMON OPERATORS ───
// Single result:
var product = await _ctx.Products.FirstOrDefaultAsync(p => p.Id == id);
// WHY FirstOrDefault over Single? Single throws if more than 1 found — use when PK

// Aggregates (translate to SQL COUNT/SUM/AVG):
int count = await _ctx.Products.CountAsync(p => p.Price > 100);
decimal total = await _ctx.Orders.SumAsync(o => o.Total);

// Check existence (more efficient than Any().Count() > 0):
bool exists = await _ctx.Products.AnyAsync(p => p.Name == name);
// WHY AnyAsync? Generates SELECT TOP 1, not SELECT COUNT(*) — faster

// Group by:
var grouped = await _ctx.Products
    .GroupBy(p => p.CategoryId)
    .Select(g => new { CategoryId = g.Key, Count = g.Count(), AvgPrice = g.Average(p => p.Price) })
    .ToListAsync();

// ─── SPLITTING vs CLIENT EVALUATION ───
// BAD — C# method can't translate to SQL → client evaluation (entire table loaded!)
var bad = _ctx.Products.Where(p => MyCustomMethod(p.Name)).ToList(); // ⚠️ loads ALL rows

// GOOD — use SQL-translatable expressions only in Where/Select on IQueryable
var good = _ctx.Products.Where(p => p.Name.StartsWith("A")).ToList(); // → SQL LIKE 'A%'
```

**Key Interview Points:**
- `IQueryable` = deferred/lazy — no SQL until materialized
- `IEnumerable` = already in memory — filtering happens in C#, not SQL
- `AsNoTracking()` for read-only queries — 2× faster (skips change tracking)
- Client evaluation in EF6 was silent; EF Core **throws** by default — good!
- `Select` projection is critical for performance — avoid loading full entities for reads

---

## 4 — Change Tracking

> **🧠 Mental Model: ChangeTracker = a diff tool.**
> It takes a snapshot of entities when loaded, then compares on `SaveChanges()` to generate minimal UPDATE SQL.

```
Entity States:
  Detached   → not tracked by any context
  Added      → will INSERT on SaveChanges
  Unchanged  → loaded, not modified
  Modified   → at least one property changed → will UPDATE
  Deleted    → will DELETE on SaveChanges
```

```csharp
// STEP 1: Load entity — EF snapshots it as Unchanged
var product = await _ctx.Products.FindAsync(id);
// FindAsync: checks 1st-level cache (identity map) before hitting DB

// STEP 2: Modify property — state auto-changes to Modified
product.Price = 99.99m;
// WHY auto-detect? ChangeTracker compares current vs snapshot

// STEP 3: SaveChanges generates only the UPDATE for changed columns
await _ctx.SaveChangesAsync();
// → UPDATE Products SET Price = 99.99 WHERE Id = @id  (only Price column!)

// ─── EXPLICIT STATE MANAGEMENT ───
// Disconnected scenario (API receives DTO, not tracked entity):
var updated = new Product { Id = id, Name = dto.Name, Price = dto.Price };

// Option A: Attach + mark Modified (updates ALL columns)
_ctx.Products.Update(updated);   // STEP: attaches and marks entire entity Modified
await _ctx.SaveChangesAsync();   // → UPDATE Products SET Name=..., Price=... WHERE Id=...

// Option B: Attach + mark specific properties (updates only changed columns)
_ctx.Products.Attach(updated);                            // STEP: attach as Unchanged
_ctx.Entry(updated).Property(p => p.Price).IsModified = true; // STEP: mark only Price
await _ctx.SaveChangesAsync();   // → UPDATE Products SET Price=... WHERE Id=...
// WHY Option B? Avoids overwriting columns you didn't intend to change

// ─── AsNoTracking ── for read-only queries (no snapshot, no state, faster)
var products = await _ctx.Products.AsNoTracking().ToListAsync();
// WHY? 20-40% faster for read-only — no ChangeTracker overhead
// Use for: GET endpoints, reports, exports

// ─── DISCONNECTED UPDATE PATTERN (repository / clean arch) ───
public async Task UpdateAsync(ProductDto dto) {
    // STEP 1: Load fresh entity from DB
    var entity = await _ctx.Products.FindAsync(dto.Id)
        ?? throw new NotFoundException();
    // STEP 2: Apply DTO values (only what changed)
    entity.Name = dto.Name;
    entity.Price = dto.Price;
    // STEP 3: EF already tracks it — SaveChanges generates minimal UPDATE
    await _ctx.SaveChangesAsync();
}
```

**Key Interview Points:**
- `FindAsync(id)` checks identity map first (in-memory cache) — prefer over `FirstOrDefaultAsync` for PK lookups
- `Update()` marks ALL properties modified → over-broad UPDATE; use `Attach` + `IsModified` for targeted
- `AsNoTracking()` for any query where you won't write back — significant perf gain
- Each `DbContext` instance = its own identity map — entities with same PK are same object instance

---

## 5 — Migrations

> **🧠 Mental Model: Migrations = version-controlled ALTER TABLE scripts, auto-generated from your model diff.**

```
Model change → add-migration → snapshot diff → migration file → update-database → schema updated
```

```bash
# STEP 1: Add a new migration (generates Up/Down methods from model diff)
dotnet ef migrations add AddProductDescription

# STEP 2: Review generated migration file (always review before applying!)
# File: Migrations/20240315_AddProductDescription.cs

# STEP 3: Apply to database
dotnet ef database update

# STEP 4: Rollback to a specific migration
dotnet ef database update PreviousMigrationName

# STEP 5: Remove last migration (only if NOT applied to DB)
dotnet ef migrations remove

# Generate SQL script (for production — don't run update-database directly on prod!)
dotnet ef migrations script FromMigration ToMigration -o migrate.sql
```

```csharp
// ─── GENERATED MIGRATION STRUCTURE ───
public partial class AddProductDescription : Migration {
    protected override void Up(MigrationBuilder migrationBuilder) {
        // STEP 1 (Up): Apply schema change
        migrationBuilder.AddColumn<string>(
            name: "Description",
            table: "Products",
            type: "nvarchar(500)",
            nullable: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder) {
        // STEP 2 (Down): Revert schema change (rollback)
        migrationBuilder.DropColumn(name: "Description", table: "Products");
    }
}

// ─── APPLY MIGRATIONS AT STARTUP (dev/test only) ───
// NEVER use MigrateAsync() in production — use SQL scripts instead
using var scope = app.Services.CreateScope();
var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
await db.Database.MigrateAsync(); // applies pending migrations on startup
```

**Key Interview Points:**
- Always **review** generated migrations — EF can't always detect rename vs drop+add
- Never run `MigrateAsync()` in production — use generated SQL scripts through CD pipeline
- `ModelSnapshot` file tracks current model state; never edit it manually
- Data migrations (seeding existing data) → add custom SQL in `Up()` via `migrationBuilder.Sql(...)`

---

## 6 — Loading Strategies

> **🧠 Mental Model: Three ways to fetch related data — each with different SQL and performance implications.**

```
Eager Loading  → JOIN in original query           → Use: always need the related data
Lazy Loading   → separate SELECT on first access  → Use: rarely (N+1 risk!)
Explicit Load  → you control when to load         → Use: conditional loading
```

```csharp
// ─── EAGER LOADING (Include / ThenInclude) ───
// STEP 1: Use Include to JOIN related entities in a single query
var orders = await _ctx.Orders
    .Include(o => o.Customer)                          // JOIN Customers
    .Include(o => o.Items)                             // JOIN OrderItems
        .ThenInclude(i => i.Product)                   // JOIN Products (nested)
    .Where(o => o.CustomerId == customerId)
    .ToListAsync();
// → Generates: SELECT ... FROM Orders JOIN Customers JOIN OrderItems JOIN Products WHERE ...
// WHY Eager? One round trip; predictable; best for known, always-needed relationships

// ─── LAZY LOADING (NOT recommended — N+1 problem) ───
// Requires: Install-Package Microsoft.EntityFrameworkCore.Proxies
// + optionsBuilder.UseLazyLoadingProxies()
// + navigation properties must be virtual
var order = await _ctx.Orders.FindAsync(id);
var name = order.Customer.Name; // STEP: triggers a SELECT for Customer here — invisible SQL!
// ⚠️ N+1 PROBLEM: In a loop over 100 orders → 101 SQL queries!
foreach (var o in orders)
    Console.WriteLine(o.Customer.Name); // 100 hidden SELECT queries → CATASTROPHIC

// ─── EXPLICIT LOADING (manual control) ───
var order = await _ctx.Orders.FindAsync(id);

// STEP 1: Load reference navigation (1 side of 1:N or 1:1)
await _ctx.Entry(order).Reference(o => o.Customer).LoadAsync();

// STEP 2: Load collection navigation (N side)
await _ctx.Entry(order).Collection(o => o.Items).LoadAsync();

// STEP 3: Can add filters to collection load
await _ctx.Entry(order)
    .Collection(o => o.Items)
    .Query()
    .Where(i => i.Price > 50)   // load only expensive items
    .LoadAsync();
// WHY Explicit? Load conditionally without always paying the JOIN cost

// ─── SPLIT QUERIES (EF Core 5+) — avoids cartesian explosion ───
// Problem: Include on multiple collections → result set = rows × rows (huge!)
// Solution: split into separate queries automatically
var orders2 = await _ctx.Orders
    .Include(o => o.Items)
    .Include(o => o.Tags)
    .AsSplitQuery()      // STEP: EF executes 3 separate SELECTs instead of 1 massive JOIN
    .ToListAsync();
```

**Key Interview Points:**
- **Lazy loading = N+1 bug waiting to happen** — avoid unless you have specific reason
- `Include` generates a single JOIN query (or split queries with `AsSplitQuery`)
- Cartesian explosion: `Include` on 2 collections of size N → N² rows returned; use `AsSplitQuery`
- `Select` projection avoids the loading strategy question entirely (and is usually best for reads)

---

## 7 — Raw SQL & Stored Procedures

```csharp
// ─── FromSqlRaw / FromSqlInterpolated ───
// STEP 1: Use FromSqlInterpolated for safe parameterized queries
int minPrice = 50;
var products = await _ctx.Products
    .FromSqlInterpolated($"SELECT * FROM Products WHERE Price > {minPrice}") // SAFE: parameterized
    .ToListAsync();

// WHY NOT FromSqlRaw with string concat? SQL injection risk!
// BAD:
var bad = _ctx.Products.FromSqlRaw($"SELECT * FROM Products WHERE Name = '{name}'"); // ⚠️ INJECTION

// GOOD with FromSqlRaw (use explicit SqlParameter):
var param = new SqlParameter("@name", name);
var safe = _ctx.Products.FromSqlRaw("SELECT * FROM Products WHERE Name = @name", param);

// STEP 2: Chain LINQ after FromSql (EF wraps it in a subquery)
var filtered = await _ctx.Products
    .FromSqlInterpolated($"SELECT * FROM Products WHERE CategoryId = {catId}")
    .Where(p => p.Price > 10)   // → added as WHERE on outer query
    .OrderBy(p => p.Name)
    .ToListAsync();

// ─── STORED PROCEDURES ───
// STEP 3: For stored procs that return entities
var results = await _ctx.Products
    .FromSqlRaw("EXEC GetProductsByCategory @categoryId", new SqlParameter("@categoryId", id))
    .ToListAsync();

// STEP 4: For stored procs that return no entity (or scalar) — use ExecuteSqlInterpolatedAsync
await _ctx.Database.ExecuteSqlInterpolatedAsync(
    $"EXEC ArchiveOldOrders @cutoffDate = {DateTime.UtcNow.AddYears(-1)}");

// STEP 5: Non-entity result sets — use raw ADO.NET via DbConnection
var conn = _ctx.Database.GetDbConnection();
await conn.OpenAsync();
using var cmd = conn.CreateCommand();
cmd.CommandText = "SELECT SUM(Total) FROM Orders WHERE Year = 2024";
var total = (decimal)await cmd.ExecuteScalarAsync();
```

**Key Interview Points:**
- `FromSqlInterpolated` is safe (C# interpolation → SQL parameters); `FromSqlRaw` with string concat is not
- `FromSql` result must map to a `DbSet<T>` entity type (or use keyless entity)
- `ExecuteSqlInterpolatedAsync` for DML (INSERT/UPDATE/DELETE) not returning rows
- For complex result sets, project with raw SQL + `Dapper` alongside EF (they share the same connection)

---

## 8 — Transactions & Concurrency

> **🧠 Mental Model: SaveChanges wraps everything in ONE transaction automatically. For multi-SaveChanges operations, use explicit transactions.**

```csharp
// ─── IMPLICIT TRANSACTION (default) ───
// Every SaveChanges call wraps ALL its changes in a single transaction
_ctx.Products.Add(product);
_ctx.Orders.Add(order);
await _ctx.SaveChangesAsync(); // STEP: both inserts → 1 atomic transaction

// ─── EXPLICIT TRANSACTION ───
// STEP 1: Begin explicit transaction
await using var transaction = await _ctx.Database.BeginTransactionAsync();
try {
    _ctx.Products.Add(new Product { Name = "X", Price = 10 });
    await _ctx.SaveChangesAsync();  // STEP 2: first save (still in transaction)

    _ctx.Orders.Add(new Order { Total = 500 });
    await _ctx.SaveChangesAsync();  // STEP 3: second save (same transaction)

    // STEP 4: Commit only if both succeed
    await transaction.CommitAsync();
} catch {
    // STEP 5: Rollback on any failure — both saves are undone
    await transaction.RollbackAsync();
    throw;
}

// ─── OPTIMISTIC CONCURRENCY (row versioning) ───
public class Product {
    public int Id { get; set; }
    public string Name { get; set; } = "";
    [Timestamp]                         // maps to SQL rowversion / timestamp column
    public byte[] RowVersion { get; set; } // EF adds WHERE RowVersion = @original in UPDATE
}
// Fluent alternative:
// entity.Property(p => p.RowVersion).IsRowVersion();

// How it works:
// User A loads product (RowVersion = 0x0001)
// User B loads product (RowVersion = 0x0001)
// User A saves → RowVersion becomes 0x0002
// User B tries to save → WHERE RowVersion = 0x0001 matches 0 rows → DbUpdateConcurrencyException!

public async Task UpdateProductAsync(ProductDto dto) {
    try {
        var product = await _ctx.Products.FindAsync(dto.Id);
        product.Price = dto.Price;
        product.RowVersion = dto.RowVersion; // STEP: include original token from client
        await _ctx.SaveChangesAsync();       // STEP: EF checks token in WHERE clause
    }
    catch (DbUpdateConcurrencyException ex) {
        // STEP: Handle conflict — reload and retry, or return 409 Conflict
        var entry = ex.Entries.Single();
        var dbValues = await entry.GetDatabaseValuesAsync();
        throw new ConflictException("Data was modified by another user.");
    }
}

// ─── PESSIMISTIC CONCURRENCY ─── (rare in EF Core — use raw SQL)
// SELECT ... WITH (UPDLOCK, ROWLOCK) — locks row until transaction commits
await _ctx.Database.ExecuteSqlRawAsync("SELECT 1 FROM Products WITH (UPDLOCK) WHERE Id = @id",
    new SqlParameter("@id", id));
```

**Key Interview Points:**
- `SaveChanges` = one implicit transaction; multiple `SaveChanges` calls = multiple transactions
- Optimistic concurrency: `[Timestamp]` or `[ConcurrencyCheck]` — add to `WHERE` clause
- `DbUpdateConcurrencyException` → handle by reload + re-apply, or 409 to client
- Optimistic = assume no conflict (web scale); Pessimistic = lock row (high-contention, short ops)

---

## 9 — Performance Patterns

```
PERFORMANCE QUICK WINS:
  1. AsNoTracking()            → read-only queries: 20-40% faster
  2. Select() projection       → fetch only needed columns
  3. AsSplitQuery()            → avoid cartesian explosion on multi-Include
  4. Compiled queries          → skip LINQ → expression tree parsing (hot paths)
  5. Bulk operations           → EF Core 7 ExecuteUpdateAsync / ExecuteDeleteAsync
  6. Pagination                → Skip/Take (always); never load all rows
  7. Indexes                   → HasIndex() in Fluent API; covering indexes for filters
```

```csharp
// ─── AsNoTracking ───
// STEP 1: Apply to read-only queries to skip ChangeTracker snapshot
var list = await _ctx.Products
    .AsNoTracking()          // no snapshot, no identity map update
    .Where(p => p.Price > 10)
    .ToListAsync();

// ─── SELECT PROJECTION (best read pattern) ───
// STEP 2: Never load full entity if only a few columns needed
var names = await _ctx.Products
    .Where(p => p.CategoryId == id)
    .Select(p => new { p.Id, p.Name })  // SQL: SELECT Id, Name FROM Products WHERE...
    .ToListAsync();

// ─── COMPILED QUERIES (hot paths — avoids expression tree compilation overhead) ───
// STEP 3: Pre-compile query at startup, reuse efficiently
private static readonly Func<AppDbContext, int, Task<Product?>> GetById =
    EF.CompileAsyncQuery((AppDbContext ctx, int id) =>
        ctx.Products.AsNoTracking().FirstOrDefault(p => p.Id == id));

var product = await GetById(_ctx, 42); // no LINQ compilation overhead on every call

// ─── BULK UPDATE / DELETE (EF Core 7+) — no entity loading! ───
// STEP 4: Update without loading entities (direct SQL UPDATE)
await _ctx.Products
    .Where(p => p.CategoryId == oldCatId)
    .ExecuteUpdateAsync(s => s
        .SetProperty(p => p.CategoryId, newCatId)
        .SetProperty(p => p.UpdatedAt, DateTime.UtcNow));
// → UPDATE Products SET CategoryId=@new, UpdatedAt=@now WHERE CategoryId=@old

// STEP 5: Delete without loading entities (direct SQL DELETE)
await _ctx.Products
    .Where(p => p.IsArchived)
    .ExecuteDeleteAsync();
// → DELETE FROM Products WHERE IsArchived = 1
// WHY? Old way: load entities → delete each → SaveChanges = N+1 deletes!

// ─── INDEXES ───
// STEP 6: Define indexes in Fluent API for frequently filtered/sorted columns
modelBuilder.Entity<Product>()
    .HasIndex(p => p.CategoryId);                           // simple index

modelBuilder.Entity<Product>()
    .HasIndex(p => new { p.CategoryId, p.Price })           // composite index
    .HasDatabaseName("IX_Products_Category_Price");

modelBuilder.Entity<Product>()
    .HasIndex(p => p.Name)
    .IsUnique();                                            // unique constraint + index

// ─── N+1 DIAGNOSIS ───
// Enable logging to see generated SQL:
optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information)
              .EnableSensitiveDataLogging(); // includes parameter values (dev only!)
```

**Key Interview Points:**
- `ExecuteUpdateAsync` / `ExecuteDeleteAsync` (EF Core 7) = bulk ops without loading entities — massive perf win
- Compiled queries: useful for very hot paths (high-frequency, same query shape)
- Enable `LogTo` in dev to see generated SQL and catch N+1 issues early
- `AsSingleQuery` vs `AsSplitQuery` trade-off: single = 1 round trip but cartesian explosion; split = multiple round trips but no duplication

---

## 10 — Repository & Unit of Work

> **🧠 Mental Model: Repository = abstraction over DbSet. Unit of Work = abstraction over DbContext/SaveChanges.**
> Controversial in EF Core world — DbContext IS already a Unit of Work, DbSet IS already a Repository.

```csharp
// ─── GENERIC REPOSITORY ───
public interface IRepository<T> where T : class {
    Task<T?> GetByIdAsync(int id);
    Task<IReadOnlyList<T>> GetAllAsync();
    Task AddAsync(T entity);
    void Update(T entity);
    void Delete(T entity);
}

public class Repository<T> : IRepository<T> where T : class {
    protected readonly AppDbContext _ctx;
    protected readonly DbSet<T> _set;

    public Repository(AppDbContext ctx) {
        _ctx = ctx;
        _set = ctx.Set<T>(); // STEP 1: Get the correct DbSet<T> dynamically
    }

    // STEP 2: Read by PK — uses identity map cache first
    public async Task<T?> GetByIdAsync(int id) =>
        await _set.FindAsync(id);

    // STEP 3: Read all — AsNoTracking for read-only lists
    public async Task<IReadOnlyList<T>> GetAllAsync() =>
        await _set.AsNoTracking().ToListAsync();

    // STEP 4: Add to context (not yet saved)
    public async Task AddAsync(T entity) => await _set.AddAsync(entity);

    // STEP 5: Mark modified (EF detects changes automatically if tracked)
    public void Update(T entity) => _ctx.Entry(entity).State = EntityState.Modified;

    // STEP 6: Mark for deletion
    public void Delete(T entity) => _set.Remove(entity);
}

// ─── UNIT OF WORK ───
public interface IUnitOfWork : IDisposable {
    IRepository<Product> Products { get; }
    IRepository<Order> Orders { get; }
    Task<int> SaveAsync();
}

public class UnitOfWork : IUnitOfWork {
    private readonly AppDbContext _ctx;

    // STEP 1: Lazy-init repositories (same DbContext instance = same transaction)
    public IRepository<Product> Products => _productRepo ??= new Repository<Product>(_ctx);
    public IRepository<Order> Orders => _orderRepo ??= new Repository<Order>(_ctx);
    private Repository<Product>? _productRepo;
    private Repository<Order>? _orderRepo;

    public UnitOfWork(AppDbContext ctx) { _ctx = ctx; }

    // STEP 2: Delegate to DbContext — all pending changes saved atomically
    public Task<int> SaveAsync() => _ctx.SaveChangesAsync();

    public void Dispose() => _ctx.Dispose();
}

// Usage in service:
public class OrderService {
    private readonly IUnitOfWork _uow;
    public OrderService(IUnitOfWork uow) { _uow = uow; }

    public async Task CreateOrderAsync(CreateOrderDto dto) {
        // STEP 1: Add entities to tracked context (via repositories)
        var order = new Order { CustomerId = dto.CustomerId, Total = dto.Total };
        await _uow.Orders.AddAsync(order);
        // STEP 2: Single SaveAsync commits all changes in one transaction
        await _uow.SaveAsync();
    }
}
```

**Key Interview Points:**
- DbContext IS already a Unit of Work and DbSet IS already a Repository — adding another layer is optional
- Benefits of Repository: testability (mock `IRepository`), swappable data sources
- Downside: leaky abstraction — you lose EF-specific features like `Include`, `FromSql`
- Prefer concrete repositories per aggregate (not generic) + use DbContext directly in simple scenarios

---

## 11 — Testing

> **🧠 Mental Model: Use InMemory for unit tests (fast, no schema). Use SQLite in-memory for integration tests (real SQL, schema migrations).**

```csharp
// ─── IN-MEMORY PROVIDER (unit tests — no real SQL) ───
public class ProductServiceTests {
    private AppDbContext CreateContext() {
        // STEP 1: Configure InMemory database with unique name per test
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString()) // unique per test
            .Options;
        return new AppDbContext(options);
    }

    [Fact]
    public async Task GetProduct_ReturnsProduct_WhenExists() {
        // STEP 2: Arrange — seed data
        await using var ctx = CreateContext();
        ctx.Products.Add(new Product { Id = 1, Name = "Widget", Price = 9.99m });
        await ctx.SaveChangesAsync();

        // STEP 3: Act — use a NEW context (simulates separate request)
        await using var readCtx = CreateContext(); // WHY new context? Verify DB persistence, not cache
        var service = new ProductService(readCtx);
        var product = await service.GetByIdAsync(1);

        // STEP 4: Assert
        Assert.NotNull(product);
        Assert.Equal("Widget", product.Name);
    }
}

// ─── SQLITE IN-MEMORY (integration tests — real SQL dialect) ───
// WHY SQLite over InMemory? InMemory doesn't enforce FK constraints, doesn't support transactions
// SQLite runs real SQL but in-process — good balance of speed and fidelity
public class IntegrationTestBase : IDisposable {
    protected AppDbContext Ctx;
    private SqliteConnection _conn;

    public IntegrationTestBase() {
        // STEP 1: Open persistent SQLite in-memory connection
        _conn = new SqliteConnection("DataSource=:memory:");
        _conn.Open();

        // STEP 2: Configure DbContext to use this connection
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite(_conn)
            .Options;
        Ctx = new AppDbContext(options);

        // STEP 3: Apply migrations to create schema
        Ctx.Database.EnsureCreated(); // or Ctx.Database.MigrateAsync() for migration-based
    }

    public void Dispose() {
        Ctx.Dispose();
        _conn.Dispose();
    }
}

// ─── MOCKING WITH Moq (Repository pattern) ───
[Fact]
public async Task CreateOrder_CallsSaveAsync() {
    // STEP 1: Mock the UnitOfWork (no real DB needed)
    var mockUow = new Mock<IUnitOfWork>();
    var mockOrders = new Mock<IRepository<Order>>();
    mockUow.Setup(u => u.Orders).Returns(mockOrders.Object);
    mockUow.Setup(u => u.SaveAsync()).ReturnsAsync(1);

    var service = new OrderService(mockUow.Object);

    // STEP 2: Act
    await service.CreateOrderAsync(new CreateOrderDto { CustomerId = 1, Total = 100 });

    // STEP 3: Verify interactions
    mockOrders.Verify(r => r.AddAsync(It.IsAny<Order>()), Times.Once);
    mockUow.Verify(u => u.SaveAsync(), Times.Once);
}
```

**Key Interview Points:**
- `UseInMemoryDatabase` — fast, no SQL constraints enforcement, good for unit tests
- `UseSqlite` in-memory — enforces FK, runs real SQL, better for integration tests
- Always create new `DbContext` per test — never share between tests (state pollution)
- Repository pattern enables pure mocking without any DB provider

---

## 12 — Top 30 Interview Q&A

### Core Concepts

**Q1: What is DbContext? What lifetime should it have in ASP.NET Core?**
> DbContext is the Unit of Work and session with the database. It tracks changes and coordinates writes. In ASP.NET Core, it should be **Scoped** (one instance per HTTP request). Singleton → thread-safety issues; Transient → too expensive to create per injection.

**Q2: What is the difference between `Add`, `Attach`, `Update`, `Entry`?**
> - `Add` → marks entity and its untracked graph as `Added` (INSERT)
> - `Attach` → marks as `Unchanged` (starts tracking without inserting)
> - `Update` → marks all properties `Modified` (full UPDATE all columns)
> - `Entry(entity).Property(...).IsModified = true` → targeted partial UPDATE

**Q3: Explain Optimistic vs Pessimistic Concurrency.**
> **Optimistic:** Assume no conflict; add `[Timestamp]` rowversion; EF adds `WHERE RowVersion = @original` to UPDATE; throw `DbUpdateConcurrencyException` if 0 rows affected. Used for web-scale.
> **Pessimistic:** Lock the row with `SELECT ... WITH (UPDLOCK)` via raw SQL; used for high-contention, short-lived operations (e.g., inventory decrement).

**Q4: What causes N+1 problem? How do you fix it?**
> Loading a list of entities, then accessing a navigation property on each item triggers a separate SELECT per item. Fix: `Include()` (eager load), `Select()` projection, or `AsSplitQuery()` for multiple collections.

**Q5: When would you use `AsNoTracking()`?**
> Any read-only query where you won't modify and SaveChanges the result. Skips ChangeTracker snapshot = faster. Use on GET endpoints, reports, exports.

**Q6: Difference between `IQueryable` and `IEnumerable` in EF?**
> `IQueryable` is composable — filters/projections are translated to SQL (runs in DB). `IEnumerable` is in-memory — once you cross the boundary (e.g., call `ToList()`), further LINQ runs in C# on all loaded rows.

**Q7: What is a compiled query and when should you use it?**
> `EF.CompileAsyncQuery(...)` pre-compiles the LINQ expression tree at startup, skipping compilation overhead on each call. Use for hot paths called thousands of times per second.

**Q8: Explain `ExecuteUpdateAsync` / `ExecuteDeleteAsync` (EF Core 7).**
> Bulk update/delete without loading entities into memory. Generates a direct `UPDATE ... WHERE` or `DELETE ... WHERE`. Dramatic performance win over load-then-modify patterns for bulk operations.

### Relationships & Mapping

**Q9: How does EF detect relationships by convention?**
> EF looks for: (1) a navigation property on one side, (2) a FK property named `<NavProp>Id` or `<Type>Id`. If found, it wires the relationship. Use Fluent API to override.

**Q10: When would you use a keyless entity type?**
> For mapping SQL views, raw SQL result sets, or join results that have no PK. Configure with `modelBuilder.Entity<MyView>().HasNoKey().ToView("ViewName")`.

**Q11: What is table splitting vs owned entities?**
> **Table splitting:** Multiple entity types map to the same table (share PK).
> **Owned entities:** `OwnsOne`/`OwnsMany` — value objects embedded in the owner's table (no separate PK visible to EF). Good for DDD Value Objects like `Address`.

**Q12: What is shadow property?**
> A property that exists in the EF model and DB schema but NOT on the .NET entity class. Useful for audit columns (`CreatedAt`, `UpdatedAt`). Access via `_ctx.Entry(entity).Property("CreatedAt").CurrentValue`.

### Migrations

**Q13: Should you use `MigrateAsync()` in production?**
> No. Use `dotnet ef migrations script` to generate SQL, review it, then run via your CD pipeline. `MigrateAsync()` is fine in dev/test but risky in production (race conditions if multiple instances start simultaneously).

**Q14: How do you handle a rename (vs drop+add) in migrations?**
> EF generates drop+add by default (data loss!). Manually edit the migration to use `migrationBuilder.RenameColumn(...)` or `RenameTable(...)` instead.

### Performance

**Q15: What is cartesian explosion?**
> When using multiple `Include()` on collection navigations, EF generates a JOIN that multiplies rows. E.g., 100 orders × 5 items × 3 tags = 1500 rows returned. Use `AsSplitQuery()` to issue 3 separate SELECs instead.

**Q16: How would you optimize a slow EF query?**
> 1. Check generated SQL (`LogTo` or SQL Profiler) — look for missing WHERE, extra columns
> 2. Add `AsNoTracking()` if read-only
> 3. Use `Select()` to project only needed columns
> 4. Add DB indexes for filter/sort columns
> 5. Replace eager load with explicit load if data not always needed
> 6. Use `AsSplitQuery` for multi-collection includes
> 7. Use compiled query for hot paths

**Q17: What is the identity map in EF Core?**
> Within a single `DbContext` instance, loading an entity with the same PK twice returns the same C# object reference. The second query hits the in-memory cache, not the DB. This is why `FindAsync(id)` is preferred over `FirstOrDefaultAsync(p => p.Id == id)` for PK lookups.

### Architecture

**Q18: Is the Repository pattern necessary with EF Core?**
> Controversial. DbContext is already a Unit of Work; DbSet is already a Repository. Extra layer adds complexity but helps with: testability (mock `IRepository`), abstracting data source, enforcing aggregate boundaries. For simple CRUD, inject DbContext directly.

**Q19: How do you handle soft deletes in EF Core?**
> Use a Global Query Filter: `modelBuilder.Entity<Product>().HasQueryFilter(p => !p.IsDeleted)`. All queries automatically exclude deleted rows. Use `IgnoreQueryFilters()` when you need to include them.

**Q20: How do you implement audit fields (CreatedAt, UpdatedAt) automatically?**
> Override `SaveChangesAsync` in DbContext:
> ```csharp
> var entries = ChangeTracker.Entries<IAuditable>();
> foreach (var e in entries) {
>     if (e.State == EntityState.Added) e.Entity.CreatedAt = DateTime.UtcNow;
>     if (e.State is EntityState.Added or EntityState.Modified)
>         e.Entity.UpdatedAt = DateTime.UtcNow;
> }
> ```

**Q21: What is the difference between `[DatabaseGenerated(DatabaseGeneratedOption.Identity)]` and `[DatabaseGenerated(DatabaseGeneratedOption.Computed)]`?**
> `Identity` → value generated on INSERT only (e.g., IDENTITY column, NEWID()).
> `Computed` → value generated on both INSERT and UPDATE (e.g., computed columns, ROWVERSION).
> EF reads back the generated value after the operation.

### Testing

**Q22: Why is `UseInMemoryDatabase` not ideal for integration tests?**
> It doesn't enforce FK constraints, doesn't support transactions, and doesn't run real SQL. `UseSqlite` in-memory is better — it enforces constraints and runs actual SQL.

**Q23: How do you test a service that uses DbContext without a real database?**
> Option A (InMemory/SQLite): inject a real `DbContext` configured with test provider.
> Option B (Repository mock): abstract DbContext behind `IRepository<T>` / `IUnitOfWork`, mock with Moq.
> Option A is more realistic; Option B is faster and simpler for unit tests.

### Advanced

**Q24: What is TPH vs TPT vs TPC inheritance?**
> - **TPH (Table Per Hierarchy):** All derived types in one table with discriminator column. Default. Fast reads, sparse columns.
> - **TPT (Table Per Type):** Each type gets its own table; JOIN required to read derived type. Normalized but slower.
> - **TPC (Table Per Concrete, EF Core 7+):** Each concrete type has its own full table; no JOIN; no shared PK sequence.

**Q25: How do you handle database-generated values (sequences, computed columns)?**
> Mark with `[DatabaseGenerated]` or Fluent: `e.Property(p => p.CreatedAt).ValueGeneratedOnAdd()`. EF reads back the value after INSERT/UPDATE using `OUTPUT` clause (SQL Server) or SELECT (others).

**Q26: What is `DbContextFactory` and when is it useful?**
> `IDbContextFactory<T>` creates `DbContext` instances on demand, outside the DI lifetime. Useful for: background services (long-lived, not scoped), Blazor Server (component lifetime ≠ request), parallel operations.

**Q27: How do you configure a global query filter?**
> In `OnModelCreating`:
> ```csharp
> modelBuilder.Entity<Product>().HasQueryFilter(p => p.TenantId == _tenantId);
> ```
> Use for soft deletes, multi-tenancy, row-level security.
> Override with `.IgnoreQueryFilters()` when needed.

**Q28: What is an owned entity and how does it relate to DDD Value Objects?**
> Owned entities (`OwnsOne`, `OwnsMany`) map to the same table as the owner (no separate PK). They model DDD Value Objects — immutable, identity-less parts of an aggregate root. E.g., `Order` owns `Address` — address columns live in the Orders table.

**Q29: How do EF Core interceptors work?**
> Interceptors hook into EF pipeline events: `SaveChanges`, `DbCommand` execution, `DbConnection`, `DbTransaction`. Register via `AddInterceptors()`. Use for: logging all SQL, injecting tenant filter, audit logging, retry logic.
> ```csharp
> public class AuditInterceptor : SaveChangesInterceptor {
>     public override ValueTask<InterceptionResult<int>> SavingChangesAsync(...) { ... }
> }
> options.AddInterceptors(new AuditInterceptor());
> ```

**Q30: Explain EF Core's `ValueConverter` and `ValueComparer`.**
> `ValueConverter`: transforms a .NET type to/from the DB type. E.g., store `enum` as string, serialize `List<string>` as JSON column.
> `ValueComparer`: tells EF how to detect changes in complex types (important for collection value converters).
> ```csharp
> entity.Property(p => p.Tags)
>     .HasConversion(
>         v => JsonSerializer.Serialize(v, null),
>         v => JsonSerializer.Deserialize<List<string>>(v, null)!);
> ```

---

```
QUICK DECISION TREE:
═══════════════════════════════════════════════════════════════════════
  Need to READ data?
    Always needed related data?  → Include() (eager)
    Conditionally needed?        → Explicit Load or Select projection
    Read-only?                   → Add AsNoTracking()
    Only some columns?           → Select() projection (best option)

  Need to WRITE data?
    Single entity?               → Load → modify → SaveChanges
    Bulk update (no load)?       → ExecuteUpdateAsync (EF Core 7)
    Bulk delete (no load)?       → ExecuteDeleteAsync (EF Core 7)
    Multiple SaveChanges atomically? → Explicit transaction

  Slow query?
    Check SQL first              → LogTo / SQL Profiler
    Read-only?                   → AsNoTracking
    Missing index?               → HasIndex() in Fluent API
    Cartesian explosion?         → AsSplitQuery
    Hot path?                    → Compiled query
═══════════════════════════════════════════════════════════════════════
```

---

*Quick Prep · EF Core 7/8 · C# · ~90 min read*
