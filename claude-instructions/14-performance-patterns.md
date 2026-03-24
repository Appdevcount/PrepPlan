# 14 — Performance Patterns

> **Mental Model:** Performance is like water flowing through a pipe.
> The slowest section (bottleneck) determines total throughput — widening every OTHER
> section achieves nothing. Find the bottleneck first. Measure before you optimise.

---

## Performance First Principles

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  RULE 1: Measure first. Never optimise on instinct.                          │
│  RULE 2: Optimise the hottest code path. 80% of time in 20% of code.        │
│  RULE 3: Avoid work — skip, cache, batch, paginate.                          │
│  RULE 4: Defer work — async, queues, background jobs.                        │
│  RULE 5: Parallelise work — Task.WhenAll, parallel DB reads.                 │
│  RULE 6: Don't allocate — object pooling, Span<T>, stackalloc.               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## API Response Time — Parallel DB Calls

```csharp
// ── WRONG — serial DB calls: total time = sum of all calls ───────────────────
public async Task<DashboardDto> GetDashboardSlowAsync(Guid userId, CancellationToken ct)
{
    var orders    = await _orderRepo.GetRecentAsync(userId, ct);    // 80ms
    var invoices  = await _invoiceRepo.GetRecentAsync(userId, ct);  // 60ms
    var profile   = await _customerRepo.GetByIdAsync(userId, ct);   // 40ms
    // Total: 180ms (sequential)
    return new DashboardDto(orders, invoices, profile);
}

// ── CORRECT — parallel DB calls: total time = max(individual calls) ──────────
// WHY Task.WhenAll: all three queries run concurrently — different DB connections.
//   On a multi-core server, EF Core handles each on its own thread pool thread.
public async Task<DashboardDto> GetDashboardFastAsync(Guid userId, CancellationToken ct)
{
    // Start all three — don't await yet
    var ordersTask   = _orderRepo.GetRecentAsync(userId, ct);
    var invoicesTask = _invoiceRepo.GetRecentAsync(userId, ct);
    var profileTask  = _customerRepo.GetByIdAsync(userId, ct);

    // Await all simultaneously
    await Task.WhenAll(ordersTask, invoicesTask, profileTask);
    // Total: ~80ms (limited by the slowest query)

    return new DashboardDto(
        await ordersTask,    // WHY await again: reads the result (already completed)
        await invoicesTask,
        await profileTask);
}

// ── CORRECT with cancellation propagation ────────────────────────────────────
// WHY CancellationToken.None for individual tasks:
//   If ct is cancelled, WhenAll itself throws OperationCanceledException.
//   Individual tasks may have already started — passing ct would cancel mid-flight DB reads.
//   Simpler: let WhenAll handle cancellation at the top level.
```

---

## EF Core Performance

```csharp
// ── 1. Select only what you need (projection) ────────────────────────────────
// WHY: loading full entities loads ALL columns including blobs and unused navigation props.
//   SQL: SELECT * vs SELECT Id, Name, Status — the difference is huge on wide tables.

// ❌ WRONG — loads all 30 columns + navigation properties into memory
var orders = await _db.Orders.Include(o => o.Items).ToListAsync(ct);
var summaries = orders.Select(o => new OrderSummaryDto(o.Id, o.Status, o.Items.Count)).ToList();

// ✅ CORRECT — projects in SQL, only 3 columns transferred over the network
var summaries = await _db.Orders
    .Select(o => new OrderSummaryDto(
        o.Id,
        o.Status,
        o.Items.Count   // COUNT in SQL, not in-memory
    ))
    .ToListAsync(ct);

// ── 2. Use compiled queries for repeated hot-path queries ─────────────────────
// WHY: EF compiles LINQ → SQL on every call. Compile once → cache → reuse.
//   Benchmark: ~2ms saved per call. At 10,000 calls/sec = 20 CPU-seconds saved.
private static readonly Func<AppDbContext, Guid, Task<Order?>> GetOrderByIdCompiled =
    EF.CompileAsyncQuery((AppDbContext db, Guid id) =>
        db.Orders
            .AsNoTracking()
            .FirstOrDefault(o => o.Id == new OrderId(id)));

// ── 3. Streaming large result sets — avoid loading 100k rows into memory ──────
// WHY AsAsyncEnumerable: processes one row at a time → constant memory regardless of result size.
//   ToListAsync() loads EVERYTHING into memory before processing starts.
public async IAsyncEnumerable<ExportRow> StreamOrderExportAsync(
    [EnumeratorCancellation] CancellationToken ct)
{
    await foreach (var order in _db.Orders
        .AsNoTracking()
        .OrderBy(o => o.CreatedAt)
        .AsAsyncEnumerable()
        .WithCancellation(ct))
    {
        yield return new ExportRow(order.Id, order.Total, order.CreatedAt);
        // Each row is yielded and can be written to a CSV/stream before the next is read
    }
}

// ── 4. Bulk operations — avoid loading entities for mass changes ─────────────
// WHY ExecuteUpdateAsync: single UPDATE statement, no entity loading, no change tracker
await _db.Orders
    .Where(o => o.ExpiresAt < DateTime.UtcNow && o.Status == OrderStatus.Active)
    .ExecuteUpdateAsync(s =>
        s.SetProperty(o => o.Status, OrderStatus.Expired)
         .SetProperty(o => o.UpdatedAt, DateTime.UtcNow), ct);
// SQL: UPDATE Orders SET Status='Expired', UpdatedAt=NOW() WHERE ExpiresAt < NOW() AND Status='Active'
// One round trip, zero entities in memory.
```

---

## Memory Allocation — Reduce GC Pressure

```csharp
// ── Span<T> — stack-allocated slice, zero heap allocation ────────────────────
// WHY Span: string.Substring allocates a new string. Span<char> is a window into existing memory.
//   At 10,000 req/sec on a hot path, substring allocations add up to significant GC pressure.

// ❌ WRONG — allocates new string per call
public string ParseOrderId(string header)
{
    // "Bearer eyJhbGc..." → "eyJhbGc..."
    return header.Substring(7);   // new heap allocation
}

// ✅ CORRECT — zero allocation with Span
public ReadOnlySpan<char> ParseOrderId(ReadOnlySpan<char> header)
{
    return header[7..];   // slice, no allocation — same memory
}

// ── ArrayPool<T> — rent/return buffers instead of allocating ─────────────────
// WHY: processing large byte arrays (file upload, message parsing) in a loop
//   would allocate a new byte[] on every iteration. ArrayPool reuses.
public async Task ProcessWebhookPayloadAsync(Stream body, CancellationToken ct)
{
    // Rent from pool — returns a shared buffer (may be larger than requested)
    var buffer = ArrayPool<byte>.Shared.Rent(4096);
    try
    {
        int bytesRead;
        while ((bytesRead = await body.ReadAsync(buffer, ct)) > 0)
        {
            // Process buffer[0..bytesRead] — never read beyond bytesRead
            ProcessChunk(buffer.AsSpan(0, bytesRead));
        }
    }
    finally
    {
        ArrayPool<byte>.Shared.Return(buffer);   // WHY finally: always return to pool
    }
}

// ── ObjectPool<T> — reuse expensive-to-create objects ────────────────────────
// WHY: StringBuilder, regex matches, JSON writers — expensive to new() repeatedly
builder.Services.AddSingleton<ObjectPool<StringBuilder>>(serviceProvider =>
    new DefaultObjectPoolProvider().CreateStringBuilderPool());

public class ReportBuilder(ObjectPool<StringBuilder> pool)
{
    public string BuildReport(IEnumerable<Order> orders)
    {
        var sb = pool.Get();   // rent from pool
        try
        {
            foreach (var order in orders)
                sb.AppendLine($"{order.Id},{order.Total},{order.Status}");
            return sb.ToString();
        }
        finally
        {
            pool.Return(sb);   // WHY finally: return even if exception — prevents pool starvation
        }
    }
}
```

---

## Response Caching & Compression

```csharp
// ── Output caching — cache full HTTP responses ────────────────────────────────
// WHY: identical GET /api/products responses cached for 60s.
//   100 users hitting the same endpoint = 1 DB query, not 100.
builder.Services.AddOutputCache(opts =>
{
    opts.AddPolicy("products-cache", policy =>
        policy.Expire(TimeSpan.FromSeconds(60))
              .Tag("products")           // WHY tag: invalidate all "products" cached responses on update
              .VaryByHeader("Accept-Language")  // WHY vary: different lang = different response
              .VaryByQuery("category", "page")); // WHY vary by query: ?category=books is different from ?category=electronics
});

app.UseOutputCache();

app.MapGet("/api/products", async (IProductService svc, CancellationToken ct) =>
    Results.Ok(await svc.GetAllAsync(ct))
).CacheOutput("products-cache");

// Invalidate on product update
app.MapPut("/api/products/{id}", async (Guid id, UpdateProductRequest req,
    IProductService svc, IOutputCacheStore cache, CancellationToken ct) =>
{
    await svc.UpdateAsync(id, req, ct);
    // WHY EvictByTag: invalidates all responses tagged "products" across all pods
    await cache.EvictByTagAsync("products", ct);
    return Results.NoContent();
});

// ── Response compression ──────────────────────────────────────────────────────
// WHY: JSON over 1KB benefits from GZIP/Brotli. 70-80% size reduction typical.
//   Less network bandwidth = faster response for clients, lower egress cost.
builder.Services.AddResponseCompression(opts =>
{
    opts.EnableForHttps = true;   // WHY: BREACH attack risk is low for API responses
    opts.Providers.Add<BrotliCompressionProvider>();    // WHY Brotli first: better compression than GZIP
    opts.Providers.Add<GzipCompressionProvider>();      // Fallback for older clients
    opts.MimeTypes = ResponseCompressionDefaults.MimeTypes
        .Append("application/json");
});

builder.Services.Configure<BrotliCompressionProviderOptions>(opts =>
    opts.Level = CompressionLevel.Fastest);  // WHY Fastest not Optimal: CPU trade-off for API responses
```

---

## .NET Performance Profiling Reference

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Tool                  │ What it measures          │ When to use              │
├──────────────────────────────────────────────────────────────────────────────┤
│  BenchmarkDotNet       │ Method-level throughput   │ Comparing two approaches │
│                        │ Memory allocations        │                          │
├──────────────────────────────────────────────────────────────────────────────┤
│  dotnet-trace          │ CPU profiling             │ High CPU process         │
│                        │ GC events                 │                          │
├──────────────────────────────────────────────────────────────────────────────┤
│  dotnet-counters       │ Runtime counters live      │ Quick health check       │
│                        │ (GC, threads, exceptions)  │                          │
├──────────────────────────────────────────────────────────────────────────────┤
│  dotnet-dump           │ Memory heap dump           │ Memory leak / OOM        │
├──────────────────────────────────────────────────────────────────────────────┤
│  Application Insights  │ End-to-end traces          │ Production profiling     │
│  (Profiler)            │ CPU flame graphs            │ No code change needed    │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Frontend Performance — React & Angular

```typescript
// ── Virtual scrolling — render only visible rows ─────────────────────────────
// WHY: rendering 10,000 <tr> elements = 10,000 DOM nodes = page hangs.
//   Virtual scroll renders only the ~20 visible rows + a few buffer rows.

// Angular CDK Virtual Scroll
@Component({
  template: `
    <cdk-virtual-scroll-viewport itemSize="50" class="order-list">
      <!-- *cdkVirtualFor renders only visible items — same API as *ngFor -->
      <div *cdkVirtualFor="let order of orders$ | async" class="order-row">
        {{ order.id }} — {{ order.total | currency }}
      </div>
    </cdk-virtual-scroll-viewport>
  `
})
export class OrderListComponent {
  orders$ = this.orderService.getOrders();   // Observable<Order[]> — even 100k items OK
}

// React — react-window
import { FixedSizeList } from 'react-window';
function OrderList({ orders }: { orders: Order[] }) {
  const Row = ({ index, style }: { index: number; style: CSSProperties }) => (
    // WHY style spread: react-window injects exact position — required for virtual layout
    <div style={style} className="order-row">
      {orders[index].id} — {orders[index].total}
    </div>
  );

  return (
    <FixedSizeList
      height={600}        // viewport height
      itemCount={orders.length}
      itemSize={50}       // row height in px
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}

// ── Change Detection — Angular OnPush ────────────────────────────────────────
// WHY OnPush: Default CD checks the ENTIRE component tree on every event.
//   OnPush: re-renders only when @Input reference changes OR signal updates.
//   For a list of 100 rows, OnPush means 99 rows skip the check entirely.
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,  // every component
})
```

---

## Performance Benchmarks to Know

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Operation                          │ Rough latency    │ Notes                │
├──────────────────────────────────────────────────────────────────────────────┤
│  L1 cache hit                       │ ~1 ns            │                      │
│  L2/L3 cache hit                    │ ~10 ns           │                      │
│  RAM access                         │ ~100 ns          │                      │
│  Redis GET (same datacenter)        │ ~0.5 ms          │                      │
│  SQL query (indexed, simple)        │ ~1–5 ms          │                      │
│  SQL query (full table scan)        │ ~100ms–10s       │ Add an index         │
│  HTTP call (same Azure region)      │ ~5–20 ms         │                      │
│  HTTP call (cross-continent)        │ ~100–300 ms      │ Cache or CDN it      │
│  Service Bus send + receive         │ ~30–100 ms       │                      │
│  Cold start: .NET on AKS            │ ~500ms–2s        │ Use AlwaysOn or HPA  │
│  Cold start: Azure Function         │ ~1–10s           │ Use Premium plan      │
└──────────────────────────────────────────────────────────────────────────────┘

Golden Rules:
  P50 (median) latency < 100ms for all synchronous API reads
  P95 latency < 500ms
  P99 latency < 1s
  Anything > 1s should be async (202 Accepted + polling or WebSocket notification)
```
