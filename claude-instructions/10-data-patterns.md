# 10 — Data Patterns: EF Core, Repository, LINQ, Migrations

> **Mental Model:** The database is an implementation detail. The domain defines
> what data is needed (interfaces). EF Core is the translator that converts
> C# objects to SQL. Never let SQL verbs leak into your domain or application layers.

---

## DbContext Configuration

```csharp
// ── AppDbContext.cs ────────────────────────────────────────────────────────────
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Order>    Orders    => Set<Order>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Product>  Products  => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // WHY ApplyConfigurationsFromAssembly: auto-discovers all IEntityTypeConfiguration<T>
        //   classes. No manual .ApplyConfiguration(new OrderConfiguration()) for each entity.
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // WHY soft-delete global filter: queries automatically exclude deleted records.
        //   No need to add .Where(x => !x.IsDeleted) to every query.
        modelBuilder.Entity<Order>().HasQueryFilter(o => !o.IsDeleted);
    }

    // Override SaveChangesAsync to apply audit fields automatically
    public override async Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        // WHY intercept here: audit fields are infrastructure concern — not domain's job
        var now = DateTimeOffset.UtcNow;
        foreach (var entry in ChangeTracker.Entries<IAuditable>())
        {
            if (entry.State == EntityState.Added)
                entry.Entity.CreatedAt = now;
            if (entry.State is EntityState.Added or EntityState.Modified)
                entry.Entity.UpdatedAt = now;
        }
        return await base.SaveChangesAsync(ct);
    }
}

// ── Entity configuration — separate file per entity ──────────────────────────
// WHY separate IEntityTypeConfiguration: keeps DbContext clean, each entity owns its mapping
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.HasKey(o => o.Id);

        // WHY HasConversion: EF stores OrderId as Guid, maps to strongly-typed wrapper
        builder.Property(o => o.Id)
            .HasConversion(id => id.Value, value => new OrderId(value));

        // WHY OwnsOne: Money is a Value Object — stored in same table, not a separate one
        builder.OwnsOne(o => o.Total, money =>
        {
            money.Property(m => m.Amount).HasColumnName("TotalAmount").HasPrecision(18, 2);
            money.Property(m => m.Currency).HasColumnName("TotalCurrency").HasMaxLength(3);
        });

        // WHY HasIndex: CustomerId is a frequent query predicate — index prevents table scan
        builder.HasIndex(o => o.CustomerId).HasDatabaseName("IX_Orders_CustomerId");

        // Composite index for common filtered + sorted queries
        builder.HasIndex(o => new { o.Status, o.CreatedAt })
            .HasDatabaseName("IX_Orders_Status_CreatedAt");

        builder.HasMany(o => o.Items)
            .WithOne()
            .HasForeignKey("OrderId")    // shadow foreign key — not exposed on OrderItem
            .OnDelete(DeleteBehavior.Cascade);

        // WHY Restrict not Cascade for Customer: deleting a customer should not cascade-delete orders
        //   (orders are financial records — delete separately with business rules)
        builder.HasOne<Customer>()
            .WithMany()
            .HasForeignKey(o => o.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

---

## Repository Pattern

```csharp
// ── IOrderRepository.cs (Domain layer) ───────────────────────────────────────
// WHY interface in Domain: domain defines the contract; infrastructure implements it.
//   Domain doesn't know if it's SQL Server, Cosmos DB, or in-memory.
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(OrderId id, CancellationToken ct = default);
    Task<IReadOnlyList<Order>> GetByCustomerAsync(CustomerId customerId, CancellationToken ct = default);
    Task AddAsync(Order order, CancellationToken ct = default);
    Task UpdateAsync(Order order, CancellationToken ct = default);
    // WHY no DeleteAsync: orders use soft-delete (business rule) — delete via domain method
}

// ── OrderRepository.cs (Infrastructure layer) ────────────────────────────────
public class OrderRepository(AppDbContext dbContext) : IOrderRepository
{
    public async Task<Order?> GetByIdAsync(OrderId id, CancellationToken ct)
    {
        // WHY AsNoTracking: read-only queries don't need change tracking — faster, less memory
        // Exception: if you'll modify the entity, DON'T use AsNoTracking
        return await dbContext.Orders
            .Include(o => o.Items)      // WHY explicit include: avoid N+1 on items
            .AsNoTracking()
            .FirstOrDefaultAsync(o => o.Id == id, ct);
    }

    public async Task<IReadOnlyList<Order>> GetByCustomerAsync(CustomerId customerId, CancellationToken ct)
    {
        return await dbContext.Orders
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.CreatedAt)
            .AsNoTracking()
            .ToListAsync(ct);
    }

    public async Task AddAsync(Order order, CancellationToken ct)
    {
        // WHY AddAsync not Add: AddAsync is slightly faster for value-generating keys
        await dbContext.Orders.AddAsync(order, ct);
        // WHY NOT SaveChanges here: Unit of Work pattern — caller (handler) saves once
        //   Multiple repo operations in one handler = one SaveChanges = one transaction
    }

    public Task UpdateAsync(Order order, CancellationToken ct)
    {
        // WHY no explicit attach: EF tracks entities retrieved in the same scope.
        //   Mark as modified if entity was retrieved outside this scope.
        dbContext.Orders.Update(order);
        return Task.CompletedTask;   // actual save happens in Unit of Work
    }
}
```

---

## CQRS — Query Side (Direct DB, No Repository)

```csharp
// WHY query handlers can bypass repository:
//   Repositories return domain entities. Queries need projections (DTOs).
//   Loading full entity graphs then mapping to DTOs is wasteful.
//   Direct EF queries project exactly what the UI needs.
//   Write side: repository enforces domain rules. Read side: just fetch data.

public class GetOrdersQueryHandler(AppDbContext dbContext) : IRequestHandler<GetOrdersQuery, PagedResult<OrderSummaryDto>>
{
    public async Task<PagedResult<OrderSummaryDto>> Handle(GetOrdersQuery query, CancellationToken ct)
    {
        // Build query — filters applied before execution (deferred execution)
        var q = dbContext.Orders.AsNoTracking().AsQueryable();

        if (query.Status.HasValue)
            q = q.Where(o => o.Status == query.Status.Value);

        if (query.CustomerId.HasValue)
            q = q.Where(o => o.CustomerId == query.CustomerId.Value);

        if (query.DateFrom.HasValue)
            q = q.Where(o => o.CreatedAt >= query.DateFrom.Value);

        // WHY count before paging: accurate total for pagination UI
        var totalCount = await q.CountAsync(ct);

        // WHY project to DTO with Select: avoids loading OrderItems, Customer navigation props
        //   If you use AutoMapper ProjectTo<T>(), EF generates the same optimal SQL
        var items = await q
            .OrderByDescending(o => o.CreatedAt)
            .Skip((query.Page - 1) * query.PageSize)
            .Take(query.PageSize)
            .Select(o => new OrderSummaryDto(
                o.Id.Value,
                o.Status.ToString(),
                o.Total.Amount,
                o.Total.Currency,
                o.CreatedAt,
                o.Items.Count    // WHY Count not Items: avoids loading full items collection
            ))
            .ToListAsync(ct);

        return new PagedResult<OrderSummaryDto>(items, totalCount, query.Page, query.PageSize);
    }
}
```

---

## EF Core Performance Rules

```csharp
// ── 1. Avoid N+1 queries ──────────────────────────────────────────────────────

// ❌ WRONG — N+1: 1 query for orders + N queries for items (one per order)
var orders = await dbContext.Orders.ToListAsync(ct);
foreach (var order in orders)
    Console.WriteLine(order.Items.Count);   // lazy load fires per order

// ✅ CORRECT — 1 query with JOIN
var orders = await dbContext.Orders
    .Include(o => o.Items)
    .ToListAsync(ct);

// ✅ BETTER for large sets — split query (avoids cartesian explosion)
var orders = await dbContext.Orders
    .Include(o => o.Items)
    .AsSplitQuery()    // WHY: runs 2 queries (orders, then items) joined in memory
                       //   Avoids row multiplication: 100 orders × 50 items = 5000 rows
    .ToListAsync(ct);

// ── 2. Use compiled queries for hot paths ────────────────────────────────────

// WHY compiled: EF re-compiles LINQ to SQL on every call. Compile once, call many.
//   Hot endpoints (called >100/sec) benefit significantly.
private static readonly Func<AppDbContext, Guid, Task<Order?>> GetOrderById =
    EF.CompileAsyncQuery((AppDbContext db, Guid id) =>
        db.Orders.FirstOrDefault(o => o.Id == new OrderId(id)));

// Usage:
var order = await GetOrderById(dbContext, id);

// ── 3. Bulk operations — avoid loading entities for mass updates ─────────────

// ❌ WRONG — loads all entities into memory, generates N UPDATE statements
var expiredOrders = await dbContext.Orders.Where(o => o.ExpiresAt < DateTime.UtcNow).ToListAsync();
foreach (var o in expiredOrders) o.Status = OrderStatus.Expired;
await dbContext.SaveChangesAsync();

// ✅ CORRECT — EF Core 7+ ExecuteUpdateAsync: single UPDATE statement, no entity loading
await dbContext.Orders
    .Where(o => o.ExpiresAt < DateTime.UtcNow && o.Status == OrderStatus.Active)
    .ExecuteUpdateAsync(setters =>
        setters.SetProperty(o => o.Status, OrderStatus.Expired), ct);

// ✅ CORRECT — bulk delete
await dbContext.AuditLogs
    .Where(l => l.CreatedAt < DateTime.UtcNow.AddYears(-1))
    .ExecuteDeleteAsync(ct);
```

---

## Migration Strategy

```
// ── Migration Rules ────────────────────────────────────────────────────────────

// 1. NEVER use EnsureCreated() in production — it skips migrations entirely
// 2. NEVER use Database.Migrate() in the API startup for production
//    WHY: multiple pods starting simultaneously = race condition on migrations
// 3. RUN migrations as a separate step in CI/CD (migration job) before pod rollout

// ── Correct production migration pattern ─────────────────────────────────────
// In CI/CD pipeline (before deploying new pods):
//   dotnet ef database update --project src/Orders.Infrastructure --startup-project src/Orders.Api

// ── OR: migration job in Kubernetes (runs before Deployment rollout) ──────────
// Job runs "dotnet ef database update", waits for completion, then Deployment starts
// Use initContainers in pod spec for in-cluster migrations

// ── Safe migration checklist ─────────────────────────────────────────────────
// ✅ Add column nullable first — old pods write NULL, new pods write value
// ✅ Add index CONCURRENTLY (Postgres) — non-blocking, no table lock
// ✅ Never rename columns in one migration — add new, copy data, drop old (3 migrations)
// ✅ Never add NOT NULL without a default in one step — will fail on existing rows
// ❌ Never drop columns in the same release you remove code — deploy code first, drop next release
```

---

## Pagination Pattern

```csharp
// WHY cursor-based over offset: offset pagination degrades as data grows.
//   Page 500 of 1000 = SKIP 5000 rows — DB scans all of them.
//   Cursor-based: next page marker points to the last seen row — always fast.

public record PagedResult<T>(
    IReadOnlyList<T> Items,
    int TotalCount,
    int Page,
    int PageSize)
{
    public bool HasNextPage => Page * PageSize < TotalCount;
    public bool HasPreviousPage => Page > 1;
    public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
}

// ── Cursor-based pagination for large datasets ────────────────────────────────
public async Task<CursorPagedResult<OrderSummaryDto>> GetOrdersCursorAsync(
    DateTimeOffset? cursor,   // last seen CreatedAt — null = first page
    int pageSize,
    CancellationToken ct)
{
    var query = dbContext.Orders.AsNoTracking()
        .Where(o => cursor == null || o.CreatedAt < cursor)  // WHY <: fetch OLDER than cursor
        .OrderByDescending(o => o.CreatedAt)
        .Take(pageSize + 1);   // WHY +1: fetch one extra to know if there's a next page

    var items = await query
        .Select(o => new OrderSummaryDto(o.Id.Value, o.Status.ToString(), o.Total.Amount, o.CreatedAt))
        .ToListAsync(ct);

    var hasNext = items.Count > pageSize;
    if (hasNext) items.RemoveAt(items.Count - 1);   // remove the extra item

    return new CursorPagedResult<OrderSummaryDto>(
        items,
        hasNext ? items[^1].CreatedAt : null   // next cursor = last item's timestamp
    );
}
```
