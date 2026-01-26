# Day 2 — Advanced C# & .NET Internals (DEEP)

## Overview
This day focuses on deep understanding of C# internals that senior developers and architects must master. These topics frequently appear in technical interviews for architect/lead positions.

---

## 1. Async/Await Internals

### Concept
`async`/`await` is syntactic sugar that the compiler transforms into a state machine.

### Expert-Level Approaches

**Approach 1: SynchronizationContext-Aware Design**
- For library code: Always use `ConfigureAwait(false)` to avoid capturing context
- For application code: Understand context behavior (ASP.NET Core has no context, WPF/WinForms do)
- Trade-off: Performance vs UI thread safety

**Approach 2: Custom Awaitable Types**
```csharp
// Advanced: Create custom awaitable for specialized async patterns
public struct CustomAwaitable
{
    public CustomAwaiter GetAwaiter() => new CustomAwaiter();
}

public struct CustomAwaiter : INotifyCompletion
{
    public bool IsCompleted => /* custom logic */;
    public void OnCompleted(Action continuation) => /* custom scheduling */;
    public void GetResult() => /* return value or throw */;
}
```

**Approach 3: AsyncLocal for Ambient Context**
```csharp
// Propagate context across async calls without explicit parameters
private static readonly AsyncLocal<CorrelationContext> _context = new();

public static void SetCorrelationId(string id)
{
    _context.Value = new CorrelationContext { CorrelationId = id };
}

public static string GetCorrelationId() => _context.Value?.CorrelationId;
```

**Architectural Trade-offs:**
- **Sync over Async**: Never block async code - causes thread pool starvation
- **ValueTask vs Task**: Use ValueTask for hot paths with frequent sync completion
- **IAsyncEnumerable**: Stream large datasets without loading all in memory
- **Cancellation tokens**: Always propagate CancellationToken for cooperative cancellation

### State Machine - Conceptual Understanding

```csharp
// What you write:
public async Task<string> GetDataAsync()
{
    var result = await FetchFromDatabaseAsync();
    var processed = await ProcessDataAsync(result);
    return processed;
}

// What the compiler generates (conceptually):
public Task<string> GetDataAsync()
{
    var stateMachine = new <GetDataAsync>d__0();
    stateMachine.<>t__builder = AsyncTaskMethodBuilder<string>.Create();
    stateMachine.<>1__state = -1;
    stateMachine.<>t__builder.Start(ref stateMachine);
    return stateMachine.<>t__builder.Task;
}

// State machine has states:
// -1: Initial state
// 0: After first await
// 1: After second await
// -2: Completed
```

### Key Interview Points
- Each `await` creates a continuation point
- State machine captures local variables as fields
- `AsyncTaskMethodBuilder` manages the Task lifecycle
- Execution can complete synchronously if the awaited task is already complete

---

## 2. Task vs Thread vs ValueTask

### Task
```csharp
// Represents an ongoing operation
// Always allocates on heap
public async Task<int> CalculateAsync()
{
    await Task.Delay(100);
    return 42;
}

// Use when:
// - Asynchronous I/O operations
// - You need Task composition (WhenAll, WhenAny)
// - Result might be awaited multiple times
```

### Thread
```csharp
// Represents an OS-level execution thread
// Heavy resource (1MB stack by default)
public void ProcessData()
{
    var thread = new Thread(() =>
    {
        // CPU-intensive work
        PerformCalculation();
    });
    thread.Start();
}

// Use when:
// - Long-running CPU-bound work
// - Need thread-specific settings (priority, apartment state)
// - NOT for async I/O (wasteful)
```

### ValueTask
```csharp
// Struct-based, can avoid heap allocation
// when result is immediately available
public async ValueTask<int> GetCachedValueAsync(string key)
{
    if (_cache.TryGetValue(key, out var value))
    {
        return value; // Synchronous completion - no heap allocation
    }

    var result = await FetchFromDatabaseAsync(key);
    _cache[key] = result;
    return result;
}

// Use when:
// - High-performance scenarios
// - Result often available synchronously
// - Hot path optimizations

// DON'T:
// - Await multiple times (causes undefined behavior)
// - Store for later use
```

### Comparison Table
| Feature | Task | Thread | ValueTask |
|---------|------|--------|-----------|
| Allocation | Heap | OS Thread | Stack (when sync) |
| Cost | Low | High (1MB+) | Minimal |
| Reusable | Yes | N/A | No |
| Best For | Async I/O | CPU-bound | Hot paths |

---

## 3. CPU-Bound vs IO-Bound

### IO-Bound Operations
```csharp
// Operation waits for external resource
// Thread is released during wait
public async Task<string> ReadFileAsync()
{
    // Thread released while OS reads file
    return await File.ReadAllTextAsync("data.txt");
}

// Correct pattern:
public async Task<Order> GetOrderAsync(int id)
{
    return await _dbContext.Orders
        .Where(o => o.Id == id)
        .FirstOrDefaultAsync(); // Thread released during DB query
}
```

### CPU-Bound Operations
```csharp
// Operation uses CPU continuously
// Thread must actively work

// WRONG - blocks thread pool thread:
public async Task<int> CalculateAsync()
{
    return await Task.Run(() =>
    {
        int sum = 0;
        for (int i = 0; i < 1000000; i++)
            sum += i;
        return sum;
    });
}

// BETTER - use synchronous for CPU-bound:
public int Calculate()
{
    int sum = 0;
    for (int i = 0; i < 1000000; i++)
        sum += i;
    return sum;
}

// Or use Parallel for heavy CPU work:
public int CalculateParallel()
{
    return Parallel.For(0, 1000000, () => 0,
        (i, state, local) => local + i,
        local => local).Result;
}
```

---

## 4. ThreadPool Starvation

### The Problem
```csharp
// DANGEROUS - blocks thread pool threads
public async Task<string> BadPatternAsync()
{
    // .Result blocks a thread pool thread
    var result = SomeAsyncMethod().Result;
    return result;
}

// In ASP.NET Core:
public IActionResult Get()
{
    // All thread pool threads get blocked waiting
    var data = GetDataAsync().Result; // DEADLOCK RISK!
    return Ok(data);
}
```

### How It Happens
1. Request comes in (uses thread pool thread)
2. Synchronously blocks on async operation (.Result or .Wait())
3. Async operation tries to continue on thread pool
4. No threads available (all blocked)
5. Deadlock or severe performance degradation

### Solution
```csharp
// CORRECT - async all the way
public async Task<IActionResult> GetAsync()
{
    var data = await GetDataAsync(); // Thread released during await
    return Ok(data);
}

// If you MUST block (console app startup):
public static void Main(string[] args)
{
    // Use GetAwaiter().GetResult() instead of .Result
    var result = InitializeAsync().GetAwaiter().GetResult();
}
```

### Detection
```csharp
// Monitor thread pool in production
ThreadPool.GetAvailableThreads(out int workerThreads, out int ioThreads);
_logger.LogWarning($"Available threads: {workerThreads} worker, {ioThreads} IO");

// Low numbers indicate starvation
```

---

## 5. Sync-Over-Async Deadlocks

### Classic Deadlock Scenario
```csharp
// ASP.NET Framework (NOT Core) with sync context
public ActionResult Index()
{
    // 1. Request thread captures SynchronizationContext
    // 2. .Result blocks the request thread
    // 3. Async method tries to resume on captured context
    // 4. Context is blocked by .Result
    // 5. DEADLOCK
    var data = GetDataAsync().Result;
    return View(data);
}

private async Task<Data> GetDataAsync()
{
    await Task.Delay(100);
    // Tries to resume on original context - can't!
    return new Data();
}
```

### Why ASP.NET Core Doesn't Deadlock
```csharp
// ASP.NET Core has no SynchronizationContext
// Continuations run on any thread pool thread
public IActionResult Index()
{
    // Still BAD (thread pool starvation) but won't deadlock
    var data = GetDataAsync().Result;
    return View(data);
}
```

### ConfigureAwait(false)
```csharp
// Library code - don't capture context
public async Task<string> LibraryMethodAsync()
{
    await Task.Delay(100).ConfigureAwait(false);
    // Continuation runs on thread pool, not original context
    return "result";
}

// Application code - usually capture context
public async Task ButtonClickAsync()
{
    var result = await GetDataAsync(); // Default: ConfigureAwait(true)
    textBox.Text = result; // Safe to update UI
}
```

---

## 6. Garbage Collection

### Expert-Level Approaches

**Approach 1: Workstation vs Server GC**
```csharp
// Configure in project file
<PropertyGroup>
  <ServerGarbageCollection>true</ServerGarbageCollection>  <!-- Throughput over latency -->
  <ConcurrentGarbageCollection>true</ConcurrentGarbageCollection>  <!-- Background GC -->
  <RetainVMGarbageCollection>false</RetainVMGarbageCollection>  <!-- Release memory to OS -->
</PropertyGroup>
```
- **Workstation GC**: Lower latency, single heap, suitable for client apps
- **Server GC**: Higher throughput, multiple heaps (one per core), for server apps
- **Trade-off**: Memory usage vs throughput

**Approach 2: GC.Collect() Strategic Use**
```csharp
// RARELY use GC.Collect(), but valid scenarios:
public class LargeDataProcessor
{
    public void ProcessBatch()
    {
        // Process large batch that creates Gen 0/1 garbage
        ProcessHugeDataSet();

        // Strategic full collection before long-running operation
        GC.Collect(2, GCCollectionMode.Aggressive, blocking: true, compacting: true);
        GC.WaitForPendingFinalizers();
        GC.Collect(); // Clean up finalizer queue

        // Now start long-running work with clean slate
        StartLongRunningTask();
    }
}
```

**Approach 3: Span<T> and Memory<T> for Zero-Allocation**
```csharp
// Architect-level: Avoid allocations with Span<T>
public class ZeroAllocParser
{
    public int ParseInt(ReadOnlySpan<char> text)
    {
        // No string allocation, works directly with stack/heap data
        return int.Parse(text);
    }

    // Use stackalloc for small buffers
    public void ProcessSmallBuffer()
    {
        Span<byte> buffer = stackalloc byte[256]; // No heap allocation
        FillBuffer(buffer);
    }
}
```

**Approach 4: Object Pooling Architecture**
```csharp
// Enterprise pattern: Pool expensive objects
public class ObjectPoolingStrategy
{
    private readonly ObjectPool<StringBuilder> _builderPool;
    private readonly ObjectPool<byte[]> _bufferPool;

    public ObjectPoolingStrategy()
    {
        _builderPool = new DefaultObjectPool<StringBuilder>(
            new StringBuilderPooledObjectPolicy());
        _bufferPool = new DefaultObjectPool<byte[]>(
            new ArrayPooledObjectPolicy(4096));
    }
}
```

**Architectural Decision Framework:**
- **LOH > 85KB**: Use ArrayPool, object pooling, or streaming
- **High allocation rate**: Profile with dotMemory, PerfView
- **GC pressure**: Monitor Gen 2 collection frequency
- **Trade-offs**: Memory pooling complexity vs allocation pressure

### Generations

```csharp
// Generation 0: Short-lived objects
public void ProcessRequest()
{
    var temp = new StringBuilder(); // Gen 0
    temp.Append("data");
    // temp eligible for collection immediately
}

// Generation 1: Medium-lived
// Objects that survive one Gen 0 collection

// Generation 2: Long-lived objects
public class Service
{
    private readonly Cache _cache = new Cache(); // Gen 2

    // _cache survives multiple collections -> Gen 2
}
```

### Collection Frequency
- Gen 0: Very frequent (milliseconds)
- Gen 1: Less frequent
- Gen 2: Rare (causes full GC - expensive)

### Interview Question: Why Generations?
```csharp
// Generational hypothesis: Most objects die young
// By collecting Gen 0 frequently, we reclaim memory fast
// without scanning long-lived Gen 2 objects every time

// Gen 0 collection: ~1ms
// Full Gen 2 collection: ~100ms+ (blocks all threads)
```

---

## 7. Large Object Heap (LOH)

### Concept
```csharp
// Objects >= 85,000 bytes go to LOH
public class DataProcessor
{
    // This goes to LOH, not regular heap
    private byte[] largeBuffer = new byte[100_000];
}

// LOH characteristics:
// 1. Not compacted by default (fragmentation risk)
// 2. Collected only during Gen 2 GC
// 3. Can cause OutOfMemoryException even with free memory
```

### LOH Fragmentation Problem
```csharp
// PROBLEM:
public void ProcessFiles()
{
    for (int i = 0; i < 1000; i++)
    {
        // Allocates 1MB on LOH each time
        var buffer = new byte[1_000_000];
        ProcessData(buffer);
        // buffer released, but LOH not compacted
        // Fragmentation increases
    }
}

// SOLUTION: Reuse buffers
public class BufferPool
{
    private byte[] _sharedBuffer = new byte[1_000_000];

    public void ProcessFiles()
    {
        for (int i = 0; i < 1000; i++)
        {
            ProcessData(_sharedBuffer); // Reuse same buffer
            Array.Clear(_sharedBuffer, 0, _sharedBuffer.Length);
        }
    }
}

// Or use ArrayPool
public void ProcessFilesWithPool()
{
    var buffer = ArrayPool<byte>.Shared.Rent(1_000_000);
    try
    {
        ProcessData(buffer);
    }
    finally
    {
        ArrayPool<byte>.Shared.Return(buffer);
    }
}
```

---

## 8. Allocation Pressure

### Concept
Too many allocations force frequent garbage collections, causing performance issues.

```csharp
// HIGH allocation pressure
public string BuildReport(List<int> numbers)
{
    string result = "";
    foreach (var num in numbers)
    {
        // Creates new string each iteration!
        result += num.ToString() + ",";
    }
    return result;
}

// LOW allocation pressure
public string BuildReportOptimized(List<int> numbers)
{
    var sb = new StringBuilder(numbers.Count * 10);
    foreach (var num in numbers)
    {
        sb.Append(num);
        sb.Append(',');
    }
    return sb.ToString();
}
```

### Common Sources of Pressure
```csharp
// 1. Boxing value types
public void LogValue(int value)
{
    // int boxed to object - heap allocation
    Console.WriteLine("Value: {0}", value);
}

// 2. LINQ with closures
public List<int> FilterNumbers(List<int> numbers, int threshold)
{
    // Closure captures 'threshold' - allocation
    return numbers.Where(n => n > threshold).ToList();
}

// 3. Unnecessary ToList() calls
public void ProcessData(IEnumerable<int> numbers)
{
    var list = numbers.ToList(); // Allocation!
    foreach (var num in list)
        Process(num);
}

// Better:
public void ProcessDataOptimized(IEnumerable<int> numbers)
{
    foreach (var num in numbers) // No allocation
        Process(num);
}
```

---

## 9. Struct vs Class Trade-offs

### When to Use Struct
```csharp
// Good struct candidates:
// - Small (< 16 bytes recommended)
// - Immutable
// - Value semantics needed
// - Short-lived

public readonly struct Point
{
    public int X { get; }
    public int Y { get; }

    public Point(int x, int y)
    {
        X = x;
        Y = y;
    }
}

// Usage - no heap allocation
public void DrawLine()
{
    var start = new Point(0, 0); // Stack
    var end = new Point(10, 10); // Stack
    Draw(start, end);
}
```

### When NOT to Use Struct
```csharp
// BAD - large mutable struct
public struct LargeData // DON'T!
{
    public int Field1;
    public int Field2;
    // ... 20 more fields

    public void Modify() // Mutating struct - confusing behavior
    {
        Field1 = 42;
    }
}

// Problem:
public void UseLargeData()
{
    var data = new LargeData();
    ModifyData(data); // Entire struct COPIED
    // data.Field1 is still 0! (copy was modified)
}

private void ModifyData(LargeData data)
{
    data.Field1 = 42; // Modifies the COPY
}
```

### Performance Comparison
```csharp
// Class: Heap allocation, GC pressure, indirection
public class PersonClass
{
    public string Name { get; set; }
    public int Age { get; set; }
}

// Struct: Stack allocation (if local), no GC, copy semantics
public readonly struct PersonStruct
{
    public string Name { get; }
    public int Age { get; }
}

// In a tight loop:
for (int i = 0; i < 1_000_000; i++)
{
    var p = new PersonClass { Name = "John", Age = 30 }; // 1M allocations
}

for (int i = 0; i < 1_000_000; i++)
{
    var p = new PersonStruct { Name = "John", Age = 30 }; // Potentially zero allocations
}
```

---

## 10. DI Lifetimes & Captive Dependencies

### Expert-Level Approaches

**Approach 1: Lifetime Validation in Development**
```csharp
// Enable scope validation to catch captive dependencies
public static IHostBuilder CreateHostBuilder(string[] args) =>
    Host.CreateDefaultBuilder(args)
        .UseDefaultServiceProvider((context, options) =>
        {
            options.ValidateScopes = context.HostingEnvironment.IsDevelopment();
            options.ValidateOnBuild = true; // Validate at startup
        });
```

**Approach 2: Keyed Services (.NET 8+)**
```csharp
// Multiple implementations with different lifetimes
services.AddKeyedScoped<INotificationService, EmailNotificationService>("email");
services.AddKeyedSingleton<INotificationService, SmsNotificationService>("sms");

public class NotificationController
{
    public NotificationController(
        [FromKeyedServices("email")] INotificationService emailService,
        [FromKeyedServices("sms")] INotificationService smsService)
    {
    }
}
```

**Approach 3: Factory Pattern for Mixed Lifetimes**
```csharp
// Resolve captive dependency using factory
public class SingletonService
{
    private readonly Func<IScopedService> _scopedFactory;

    public SingletonService(Func<IScopedService> scopedFactory)
    {
        _scopedFactory = scopedFactory; // Inject factory, not instance
    }

    public void DoWork()
    {
        var scoped = _scopedFactory(); // Create new instance on demand
        scoped.Process();
    }
}

// Registration
services.AddSingleton<SingletonService>();
services.AddScoped<IScopedService, ScopedService>();
services.AddTransient<Func<IScopedService>>(sp =>
    () => sp.GetRequiredService<IScopedService>());
```

**Approach 4: Scrutor for Decorator Pattern**
```csharp
// Advanced: Automatic decorator registration
services.AddScoped<IOrderService, OrderService>();
services.Decorate<IOrderService, CachedOrderService>();
services.Decorate<IOrderService, LoggingOrderService>();

// Execution order: Logging -> Caching -> Actual Service
```

**Architectural Decision Matrix:**

| Scenario | Lifetime | Reasoning |
|----------|----------|-----------|
| DbContext | Scoped | One per request, not thread-safe |
| HTTP Clients | Singleton (via IHttpClientFactory) | Connection pooling, DNS refresh |
| Caching | Singleton | Shared state across requests |
| User-specific data | Scoped | Isolated per request |
| Stateless services | Singleton | Memory efficient, thread-safe |
| Heavy object creation | Singleton with ObjectPool | Reduce allocation pressure |

### Lifetimes
```csharp
// Singleton: One instance for application lifetime
services.AddSingleton<ICache, MemoryCache>();

// Scoped: One instance per request (in ASP.NET Core)
services.AddScoped<IOrderService, OrderService>();

// Transient: New instance every time
services.AddTransient<IEmailSender, EmailSender>();
```

### Captive Dependency Problem
```csharp
// PROBLEM: Singleton captures Scoped dependency
public class SingletonService // Registered as Singleton
{
    private readonly IOrderService _orderService; // Scoped!

    public SingletonService(IOrderService orderService)
    {
        // This IOrderService instance is captured for app lifetime
        // But it should be per-request!
        // DbContext inside will be disposed but still referenced
        _orderService = orderService;
    }

    public void DoWork()
    {
        // Using disposed DbContext - CRASH!
        _orderService.ProcessOrder();
    }
}

// SOLUTION 1: Match lifetimes
services.AddScoped<SingletonService>(); // Make it Scoped

// SOLUTION 2: Use IServiceProvider
public class SingletonService
{
    private readonly IServiceProvider _serviceProvider;

    public SingletonService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public void DoWork()
    {
        using var scope = _serviceProvider.CreateScope();
        var orderService = scope.ServiceProvider.GetRequiredService<IOrderService>();
        orderService.ProcessOrder();
    }
}
```

---

## 11. Exception Handling Strategy

### Best Practices
```csharp
// DON'T catch and ignore
public void BadPattern()
{
    try
    {
        ProcessData();
    }
    catch { } // Swallows exceptions - very bad!
}

// DO catch specific exceptions
public async Task<Order> GetOrderAsync(int id)
{
    try
    {
        return await _repository.GetByIdAsync(id);
    }
    catch (DbException ex)
    {
        _logger.LogError(ex, "Database error fetching order {OrderId}", id);
        throw; // Re-throw to preserve stack trace
    }
}

// DON'T throw generic exceptions
public void ValidateOrder(Order order)
{
    if (order == null)
        throw new Exception("Order is null"); // Bad!
}

// DO throw specific exceptions
public void ValidateOrderCorrect(Order order)
{
    if (order == null)
        throw new ArgumentNullException(nameof(order));

    if (order.Total < 0)
        throw new InvalidOperationException($"Order total cannot be negative: {order.Total}");
}
```

### Exception Filters
```csharp
// Use when to filter exceptions
public async Task<string> FetchDataAsync(string url)
{
    try
    {
        return await _httpClient.GetStringAsync(url);
    }
    catch (HttpRequestException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
    {
        _logger.LogWarning("Resource not found: {Url}", url);
        return null;
    }
    catch (HttpRequestException ex) when (ex.StatusCode == HttpStatusCode.Unauthorized)
    {
        _logger.LogError("Unauthorized access: {Url}", url);
        throw new UnauthorizedAccessException("API access denied", ex);
    }
}
```

---

## 12. Performance Profiling Mindset

### Key Metrics to Monitor
```csharp
// 1. Allocations
// Use BenchmarkDotNet or dotMemory

// 2. GC collections
var gen0 = GC.CollectionCount(0);
var gen1 = GC.CollectionCount(1);
var gen2 = GC.CollectionCount(2);

// 3. Response times
var sw = Stopwatch.StartNew();
await ProcessRequestAsync();
sw.Stop();
_logger.LogInformation("Request took {ElapsedMs}ms", sw.ElapsedMilliseconds);

// 4. Thread pool health
ThreadPool.GetAvailableThreads(out int workerThreads, out int ioThreads);
ThreadPool.GetMaxThreads(out int maxWorkerThreads, out int maxIoThreads);

// 5. Memory usage
var usedMemory = GC.GetTotalMemory(false);
var process = Process.GetCurrentProcess();
var workingSet = process.WorkingSet64;
```

### Measurement Tools
- **BenchmarkDotNet**: Micro-benchmarking
- **PerfView**: CPU and memory profiling
- **dotTrace**: Performance profiling
- **dotMemory**: Memory profiling
- **Application Insights**: Production monitoring

---

## Interview Question Samples

### Q1: How does async/await work under the hood?
**Answer**: The compiler transforms async methods into state machines. Each await point becomes a state. Local variables are lifted to fields. The AsyncTaskMethodBuilder manages Task lifecycle. When an await completes, the state machine resumes from the next state.

### Q2: When would you use ValueTask over Task?
**Answer**: ValueTask is useful in high-performance scenarios where the result is often available synchronously (e.g., cached data). It's a struct that can avoid heap allocation. However, it should never be awaited multiple times and is best for hot paths with frequent synchronous completions.

### Q3: Explain ThreadPool starvation
**Answer**: Occurs when all thread pool threads are blocked, preventing new work from executing. Common cause: blocking on async operations with .Result or .Wait(). Solution: async all the way, never block on async code.

### Q4: What's the captive dependency problem?
**Answer**: When a longer-lived service (Singleton) captures a shorter-lived dependency (Scoped). This causes the Scoped service to live longer than intended, often leading to disposed resources being accessed. Fix by matching lifetimes or using IServiceProvider to resolve dependencies on-demand.

---

## Real Performance/Failure Stories (Prepare 2)

### Story 1: ThreadPool Starvation in Production
*"We had an API that would occasionally become unresponsive. Investigation showed all 1000 thread pool threads were blocked. Root cause: a library was using .Result on async database calls. Fixed by making the call chain fully async, reducing thread usage by 95%."*

### Story 2: LOH Fragmentation OutOfMemoryException
*"Application crashed with OutOfMemoryException despite having 4GB free RAM. Profiling showed LOH fragmentation from repeatedly allocating 100KB byte arrays. Implemented ArrayPool<byte>.Shared, eliminating the allocations and solving the crashes."*

---

## How to Design a Scalable .NET API? (Be Ready)

### Key Points to Cover:
1. **Async all the way** - Never block threads
2. **Connection pooling** - Reuse database connections
3. **Caching** - Response caching, distributed cache (Redis)
4. **Stateless design** - Enable horizontal scaling
5. **Background processing** - Queue heavy work (Azure Service Bus, Hangfire)
6. **Health checks** - Monitor dependencies
7. **Rate limiting** - Protect from abuse
8. **Efficient serialization** - Use System.Text.Json
9. **Database optimization** - Proper indexing, connection management
10. **Monitoring** - Application Insights, logging with correlation IDs

---

---

## 13. Tech Lead / Architect Level: Performance Architecture Patterns

### Pattern 1: Tiered Caching Strategy

```csharp
public class MultiTierCachingArchitecture
{
    private readonly MemoryCache _l1Cache; // Local in-memory (fastest)
    private readonly IDistributedCache _l2Cache; // Redis (shared)
    private readonly IDatabase _database; // Source of truth

    public async Task<Product> GetProductAsync(Guid id)
    {
        // L1: Check in-memory cache (< 1ms)
        if (_l1Cache.TryGetValue(id, out Product product))
            return product;

        // L2: Check distributed cache (< 10ms)
        var cached = await _l2Cache.GetStringAsync($"product:{id}");
        if (cached != null)
        {
            product = JsonSerializer.Deserialize<Product>(cached);
            _l1Cache.Set(id, product, TimeSpan.FromMinutes(5)); // Populate L1
            return product;
        }

        // L3: Database (< 100ms)
        product = await _database.GetProductAsync(id);

        // Populate both caches
        await _l2Cache.SetStringAsync($"product:{id}",
            JsonSerializer.Serialize(product),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1)
            });

        _l1Cache.Set(id, product, TimeSpan.FromMinutes(5));

        return product;
    }
}
```

**Decision Framework:**
- **L1 (Memory)**: Hot data, < 100MB, < 5 min TTL
- **L2 (Redis)**: Warm data, shared across instances, < 1 hour TTL
- **L3 (Database)**: Cold data, source of truth

### Pattern 2: Circuit Breaker with Metrics

```csharp
public class ObservableCircuitBreaker
{
    private readonly IAsyncPolicy _policy;
    private readonly IMetricsCollector _metrics;

    public ObservableCircuitBreaker(IMetricsCollector metrics)
    {
        _metrics = metrics;

        _policy = Policy
            .Handle<HttpRequestException>()
            .CircuitBreakerAsync(
                handledEventsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromSeconds(30),
                onBreak: (exception, duration) =>
                {
                    _metrics.Increment("circuit_breaker.open");
                    _metrics.Gauge("circuit_breaker.duration_seconds", duration.TotalSeconds);
                },
                onReset: () => _metrics.Increment("circuit_breaker.reset"),
                onHalfOpen: () => _metrics.Increment("circuit_breaker.half_open"));
    }
}
```

### Pattern 3: Bulkhead Isolation

```csharp
// Separate thread pools for critical vs non-critical operations
public class BulkheadPattern
{
    private readonly SemaphoreSlim _criticalSemaphore = new(10, 10);
    private readonly SemaphoreSlim _nonCriticalSemaphore = new(5, 5);

    public async Task<T> ExecuteCriticalAsync<T>(Func<Task<T>> operation)
    {
        await _criticalSemaphore.WaitAsync();
        try
        {
            return await operation();
        }
        finally
        {
            _criticalSemaphore.Release();
        }
    }

    // Non-critical operations get fewer resources
    public async Task<T> ExecuteNonCriticalAsync<T>(Func<Task<T>> operation)
    {
        await _nonCriticalSemaphore.WaitAsync();
        try
        {
            return await operation();
        }
        finally
        {
            _nonCriticalSemaphore.Release();
        }
    }
}
```

### Pattern 4: Adaptive Concurrency Control

```csharp
// Automatically adjust concurrency based on latency
public class AdaptiveConcurrencyLimiter
{
    private int _concurrencyLimit = 10;
    private readonly SemaphoreSlim _semaphore;
    private readonly ConcurrentQueue<double> _latencies = new();

    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
    {
        await _semaphore.WaitAsync();
        var sw = Stopwatch.StartNew();

        try
        {
            var result = await operation();
            sw.Stop();

            _latencies.Enqueue(sw.Elapsed.TotalMilliseconds);
            AdjustConcurrency();

            return result;
        }
        finally
        {
            _semaphore.Release();
        }
    }

    private void AdjustConcurrency()
    {
        if (_latencies.Count < 100) return;

        var avgLatency = _latencies.Average();

        // Increase concurrency if latency is low
        if (avgLatency < 100 && _concurrencyLimit < 100)
        {
            _concurrencyLimit++;
            // Recreate semaphore with new limit
        }
        // Decrease if latency is high
        else if (avgLatency > 500 && _concurrencyLimit > 5)
        {
            _concurrencyLimit--;
        }

        // Clear old samples
        while (_latencies.Count > 100)
            _latencies.TryDequeue(out _);
    }
}
```

### Architecture Decision Record (ADR) Template

```markdown
# ADR: Choose ValueTask for High-Performance Caching Layer

## Context
GetProductAsync is called 10,000 times/sec. 70% of requests hit cache (synchronous completion).
Task<T> allocates ~96 bytes per call = 672MB/sec allocation pressure.

## Decision
Use ValueTask<Product> instead of Task<Product> for cache methods.

## Consequences
**Positive:**
- Reduced allocation from 672MB/sec to ~200MB/sec (3.4x improvement)
- P99 latency improved from 45ms to 12ms
- GC pressure reduced by 70%

**Negative:**
- Cannot await ValueTask multiple times (added guard code)
- Slightly more complex code
- Team needs training on ValueTask semantics

## Alternatives Considered
1. **Keep Task<T>**: Simple but unacceptable allocation pressure
2. **Synchronous cache**: Doesn't support async data sources
3. **Object pooling Task<T>**: Complex, diminishing returns

## Status
Accepted - Deployed to production 2024-01-15
```

---

## 14. Tech Lead Interview: System Performance Story Template

### Story Structure

**Situation:**
"In my previous role as Tech Lead at [Company], we had a .NET Core API handling 50,000 req/min. During Black Friday, we hit 99th percentile latency of 5 seconds, causing customer complaints and revenue loss."

**Investigation:**
"I led the performance investigation:
1. **Profiling**: Used dotTrace to identify hot paths - found LINQ queries allocating 2GB/sec
2. **Metrics**: Application Insights showed thread pool exhaustion (0 available threads)
3. **Root Cause**: Sync-over-async pattern blocking 200+ threads waiting for database calls"

**Solution:**
"Implemented three-tier strategy:
1. **Immediate**: Converted all .Result/.Wait() to async/await - reduced thread usage 80%
2. **Short-term**: Added Redis caching layer for product catalog - reduced DB load 60%
3. **Long-term**: Implemented CQRS with read replicas - separated read/write traffic"

**Result:**
"P99 latency dropped from 5s to 120ms (97% improvement). System now handles 200,000 req/min on same infrastructure. Estimated $2M annual cost savings from avoided infrastructure scaling."

**Lessons Learned:**
"1. Always async all the way - no exceptions
2. Observability before optimization - can't improve what you can't measure
3. Tiered approach: quick wins + strategic improvements
4. Performance testing in staging prevented similar issues"

---

## Deliverables
- ✔ Master 25+ advanced C# concepts
- ✔ Prepare 2 real performance/failure stories
- ✔ Be ready to explain scalable .NET API design
- ✔ Understand architectural trade-offs for each pattern
- ✔ Can articulate decision frameworks for tech choices
- ✔ Know when NOT to use advanced patterns
