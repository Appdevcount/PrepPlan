# Day 07: System Design Fundamentals

## Overview
System design interviews assess your ability to architect scalable, reliable, and maintainable systems. This guide covers fundamental patterns, trade-offs, and real-world design decisions for senior/architect-level positions.

---

## 1. Monolith vs Microservices

### The Eternal Debate

**Monolith First** is usually the right answer.

**Tech Lead Decision Framework:**
- **Team size < 20**: Monolith (easier coordination)
- **Domain complexity unclear**: Monolith (discover boundaries first)
- **Startup/MVP**: Monolith (speed to market)
- **Team size > 50**: Consider microservices (organizational scalability)
- **Proven bounded contexts**: Microservices make sense

**Real-world Trade-offs:**
- Monolith → Microservices: Possible but requires effort
- Microservices → Monolith: Nearly impossible (the "distributed monolith" trap)
- **Middle ground**: Modular monolith with well-defined boundaries

```
MONOLITH                          MICROSERVICES
┌─────────────────────┐          ┌──────┐ ┌──────┐ ┌──────┐
│   Single Process    │          │Order │ │Inven │ │Pay   │
│ ┌─────────────────┐ │          │Svc   │ │-tory │ │-ment │
│ │ Order Module    │ │          └──┬───┘ └───┬──┘ └───┬──┘
│ ├─────────────────┤ │             │         │        │
│ │ Inventory Mod   │ │          ┌──┴─────────┴────────┴──┐
│ ├─────────────────┤ │          │    API Gateway/Bus     │
│ │ Payment Module  │ │          └────────────────────────┘
│ └─────────────────┘ │
│ Single Database     │          Individual Databases
└─────────────────────┘
```

### When to Choose Monolith

**Pros**:
- Simple deployment (one artifact)
- Easy to debug and trace
- ACID transactions work naturally
- Lower operational overhead
- Faster development initially

**Cons**:
- Scaling requires scaling entire app
- Deployment is all-or-nothing
- Can become unwieldy over time
- Technology stack lock-in

```csharp
// Monolith: Simple, transactional, fast
public class OrderService
{
    private readonly AppDbContext _db;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        using var transaction = await _db.Database.BeginTransactionAsync();
        try
        {
            // All in one transaction - ACID guarantees
            var order = new Order { CustomerId = request.CustomerId };
            _db.Orders.Add(order);

            // Reduce inventory
            var product = await _db.Products.FindAsync(request.ProductId);
            product.Stock -= request.Quantity;

            // Record payment
            var payment = new Payment { OrderId = order.Id, Amount = product.Price * request.Quantity };
            _db.Payments.Add(payment);

            await _db.SaveChangesAsync();
            await transaction.CommitAsync();

            return order;
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}
```

### When to Choose Microservices

**Use when**:
- Team is large (50+ engineers)
- Different components have different scaling needs
- Independent deployment is critical
- Different tech stacks needed per domain

**Cons**:
- Distributed systems complexity
- No ACID transactions across services
- Network latency and failures
- Debugging is harder
- Data consistency challenges

```csharp
// Microservices: Distributed, eventually consistent, complex
public class OrderService
{
    private readonly IInventoryServiceClient _inventory;
    private readonly IPaymentServiceClient _payment;
    private readonly IMessageBus _bus;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        // Create order locally
        var order = new Order { CustomerId = request.CustomerId, Status = OrderStatus.Pending };
        await _repository.SaveAsync(order);

        // Call inventory service (can fail!)
        try
        {
            await _inventory.ReserveStockAsync(request.ProductId, request.Quantity);
        }
        catch (Exception ex)
        {
            order.Status = OrderStatus.Failed;
            await _repository.SaveAsync(order);
            throw;
        }

        // Publish event for payment service (async!)
        await _bus.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            Amount = request.Amount
        });

        // Order is created, but payment happens later (eventual consistency)
        return order;
    }
}
```

### The Modular Monolith (Best of Both Worlds)

```csharp
// Organize as logical modules within a monolith
// Later, can extract to microservices if needed

namespace ECommerce.Orders
{
    public interface IOrderService { }
    internal class OrderService : IOrderService { } // Internal - not accessible outside
}

// Frontend Architecture: BFF (Backend for Frontend) Pattern
**Full Stack Consideration - BFF Pattern:**

When you have multiple clients (Web, Mobile, Desktop), the BFF pattern provides client-specific APIs:

```
React Web App          Mobile App           Desktop App
      │                    │                     │
      ├────────────────────┼─────────────────────┤
      │                    │                     │
      ▼                    ▼                     ▼
┌──────────┐        ┌──────────┐         ┌──────────┐
│Web BFF   │        │Mobile BFF│         │Desktop   │
│(GraphQL) │        │(REST)    │         │BFF (gRPC)│
└────┬─────┘        └────┬─────┘         └────┬─────┘
     │                   │                     │
     └───────────────────┼─────────────────────┘
                         │
                    ┌────▼─────┐
                    │ Backend  │
                    │ Services │
                    └──────────┘
```

**BFF Pattern Benefits:**
- **Optimized for client needs**: Web gets rich data, mobile gets minimal payloads
- **Different protocols**: GraphQL for web, REST for mobile, gRPC for desktop
- **Aggregation**: BFF combines multiple backend calls into one client call
- **Security**: BFF handles auth tokens, never exposed to client

```typescript
// Web BFF (Next.js API Routes) - Optimized for React
export default async function handler(req, res) {
    // Aggregate multiple service calls
    const [orders, customer, recommendations] = await Promise.all([
        fetch('http://order-service/api/orders'),
        fetch('http://customer-service/api/customers'),
        fetch('http://recommendation-service/api/recommendations')
    ]);

    // Transform and combine for web client
    const webOptimizedResponse = {
        orders: await orders.json(),
        customer: await customer.json(),
        recommendations: await recommendations.json(),
        // Web-specific formatting
        formattedTotal: formatCurrency(orders.total)
    };

    res.json(webOptimizedResponse);
}

// Mobile BFF (ASP.NET Core) - Minimal payload
[HttpGet("dashboard")]
public async Task<ActionResult<MobileDashboard>> GetMobileDashboard()
{
    // Fetch only what mobile needs
    var orders = await _orderService.GetRecentOrdersAsync(limit: 5);

    return new MobileDashboard
    {
        // Minimal data for mobile bandwidth
        RecentOrders = orders.Select(o => new {
            o.Id,
            o.Status,
            o.Total
        }).ToList(),
        // Pre-computed on backend to save mobile CPU
        TotalSpent = orders.Sum(o => o.Total)
    };
}

namespace ECommerce.Inventory
{
    public interface IInventoryService { }
    internal class InventoryService : IInventoryService { }
}

// Communication via interfaces/events, not direct coupling
public class OrderCreationHandler
{
    private readonly IOrderService _orders;
    private readonly IInventoryService _inventory;
    private readonly IEventBus _eventBus;

    public async Task HandleAsync(CreateOrderCommand command)
    {
        // Use interfaces - could be in-process or remote later
        var order = await _orders.CreateAsync(command);
        await _inventory.ReserveAsync(command.Items);

        // Publish event - works same in monolith or microservices
        await _eventBus.PublishAsync(new OrderCreatedEvent(order.Id));
    }
}
```

---

## 2. Stateless Services Design

### Why Stateless Matters

**Stateless services** enable:
- Horizontal scaling (add more instances)
- Load balancing (any instance can handle any request)
- Easy deployment (no session migration)
- Resilience (instance failure doesn't lose data)

```
STATEFUL (BAD)                    STATELESS (GOOD)
┌─────────────┐                  ┌─────────────┐
│ Server 1    │                  │ Server 1    │
│ Sessions:   │                  │ No State    │
│ {user:abc}  │                  └─────────────┘
└─────────────┘                         │
      │                           ┌─────▼─────┐
      │ User ABC must             │   Redis   │
      │ go to Server 1            │ {user:abc}│
      ▼                           └───────────┘
Load Balancer                            │
(needs sticky                    ┌───────┴────────┐
 sessions)                       │                │
                          ┌──────▼──┐      ┌──────▼──┐
                          │Server 1 │      │Server 2 │
                          │No State │      │No State │
                          └─────────┘      └─────────┘
                          Any server can handle request
```

### Making Services Stateless

```csharp
// BAD - Stateful service (session stored in memory)
public class CartController : ControllerBase
{
    private static readonly Dictionary<string, Cart> _carts = new(); // Static state!

    [HttpPost("cart/add")]
    public IActionResult AddToCart([FromBody] AddItemRequest request)
    {
        var userId = User.Identity.Name;
        if (!_carts.ContainsKey(userId))
            _carts[userId] = new Cart();

        _carts[userId].Items.Add(request.Item);
        return Ok();
    }
}
// Problem: Works only on the server that handled the request

// GOOD - Stateless service (state in Redis)
public class CartController : ControllerBase
{
    private readonly IDistributedCache _cache;

    public CartController(IDistributedCache cache)
    {
        _cache = cache;
    }

    [HttpPost("cart/add")]
    public async Task<IActionResult> AddToCart([FromBody] AddItemRequest request)
    {
        var userId = User.Identity.Name;
        var cartJson = await _cache.GetStringAsync($"cart:{userId}");
        var cart = cartJson != null
            ? JsonSerializer.Deserialize<Cart>(cartJson)
            : new Cart();

        cart.Items.Add(request.Item);

        await _cache.SetStringAsync($"cart:{userId}",
            JsonSerializer.Serialize(cart),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
            });

        return Ok();
    }
}
```

### State Storage Options

```csharp
// 1. Redis - Fast, distributed cache
services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = "localhost:6379";
});

// 2. SQL Server - Persistent, consistent
services.AddDistributedSqlServerCache(options =>
{
    options.ConnectionString = "...";
    options.SchemaName = "dbo";
    options.TableName = "SessionState";
});

// 3. DynamoDB, Cosmos DB - Global distribution
services.AddSingleton<IDistributedCache, CosmosDbCache>();
```

---

## 3. Synchronous vs Asynchronous Communication

### Sync (Request-Response)

**Use for**: Immediate consistency required, user waiting

```csharp
// HTTP REST call
public class OrderService
{
    private readonly HttpClient _paymentClient;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order { Id = Guid.NewGuid(), Total = request.Total };
        await _repository.SaveAsync(order);

        // SYNCHRONOUS - Wait for payment to complete
        var paymentRequest = new { OrderId = order.Id, Amount = order.Total };
        var response = await _paymentClient.PostAsJsonAsync("/api/payments", paymentRequest);

        if (!response.IsSuccessStatusCode)
        {
            order.Status = OrderStatus.PaymentFailed;
            await _repository.SaveAsync(order);
            throw new PaymentException("Payment failed");
        }

        var payment = await response.Content.ReadFromJsonAsync<PaymentResponse>();
        order.TransactionId = payment.TransactionId;
        order.Status = OrderStatus.Paid;
        await _repository.SaveAsync(order);

        return order;
    }
}
```

**Pros**:
- Simple to understand
- Immediate feedback
- Strong consistency

**Cons**:
- Tight coupling (if payment service is down, orders fail)
- Latency adds up (order creation = order save + payment call + order update)
- Scaling bottleneck (payment service limits order throughput)

### Async (Event-Driven)

**Use for**: Decoupling, handling failures, background processing

```csharp
// Event-based communication
public class OrderService
{
    private readonly IMessageBus _bus;

    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order
        {
            Id = Guid.NewGuid(),
            Total = request.Total,
            Status = OrderStatus.PendingPayment
        };
        await _repository.SaveAsync(order);

        // ASYNCHRONOUS - Publish event, don't wait
        await _bus.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            Amount = order.Total,
            CustomerId = request.CustomerId
        });

        // Return immediately - payment happens in background
        return order;
    }
}

// Separate handler processes payment
public class ProcessPaymentHandler : IEventHandler<OrderCreatedEvent>
{
    private readonly IPaymentGateway _gateway;
    private readonly IOrderRepository _orders;

    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        try
        {
            var result = await _gateway.ChargeAsync(@event.Amount);

            var order = await _orders.GetByIdAsync(@event.OrderId);
            order.TransactionId = result.TransactionId;
            order.Status = OrderStatus.Paid;
            await _orders.SaveAsync(order);

            await _bus.PublishAsync(new OrderPaidEvent { OrderId = order.Id });
        }
        catch (Exception ex)
        {
            // Handle failure, retry, or compensate
            await _bus.PublishAsync(new PaymentFailedEvent
            {
                OrderId = @event.OrderId,
                Reason = ex.Message
            });
        }
    }
}
```

**Pros**:
- Loose coupling (services don't know about each other)
- Resilient (failures don't cascade)
- Scalable (can process events in parallel)

**Cons**:
- Eventual consistency (order is created before payment)
- More complex (need to handle event ordering, duplicates)
- Harder to debug (distributed tracing needed)

---

## 4. Caching Strategies

### Cache-Aside (Lazy Loading)

Most common pattern - application manages cache.

**Architect-Level Considerations:**
- **Cache warming**: Pre-populate cache on startup for critical data
- **Thundering herd**: Use distributed locks or request coalescing
- **Cache coherency**: Invalidation strategy must match write patterns
- **Monitoring**: Track hit ratio, latency improvements, eviction rates

```csharp
public class ProductService
{
    private readonly IDistributedCache _cache;
    private readonly IProductRepository _repository;

    public async Task<Product> GetProductAsync(Guid id)
    {
        var cacheKey = $"product:{id}";

        // 1. Try to get from cache
        var cached = await _cache.GetStringAsync(cacheKey);
        if (cached != null)
        {
            return JsonSerializer.Deserialize<Product>(cached);
        }

        // 2. Cache miss - load from database
        var product = await _repository.GetByIdAsync(id);
        if (product == null)
            return null;

        // 3. Store in cache for next time
        await _cache.SetStringAsync(cacheKey,
            JsonSerializer.Serialize(product),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15)
            });

        return product;
    }
}
```

**Pros**: Simple, works for most cases
**Cons**: Cache miss causes latency spike

### Write-Through

Write to cache and database simultaneously.

```csharp
public class ProductService
{
    public async Task UpdateProductAsync(Product product)
    {
        var cacheKey = $"product:{product.Id}";

        // Write to both simultaneously
        await Task.WhenAll(
            _repository.UpdateAsync(product),
            _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(product))
        );
    }

    public async Task<Product> GetProductAsync(Guid id)
    {
        var cacheKey = $"product:{id}";

        // Always check cache first
        var cached = await _cache.GetStringAsync(cacheKey);
        if (cached != null)
            return JsonSerializer.Deserialize<Product>(cached);

        // If not in cache, load and cache (shouldn't happen often)
        var product = await _repository.GetByIdAsync(id);
        if (product != null)
            await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(product));

        return product;
    }
}
```

**Pros**: Cache always warm, no latency spikes
**Cons**: Writes are slower, cache might contain unread data

### Write-Behind (Write-Back)

Write to cache immediately, write to database asynchronously.

```csharp
public class ProductService
{
    private readonly IBackgroundTaskQueue _queue;

    public async Task UpdateProductAsync(Product product)
    {
        var cacheKey = $"product:{product.Id}";

        // 1. Write to cache immediately
        await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(product));

        // 2. Queue database write for background processing
        _queue.Enqueue(async () =>
        {
            await _repository.UpdateAsync(product);
        });
    }
}

// Background worker
public class DatabaseWriteWorker : BackgroundService
{
    private readonly IBackgroundTaskQueue _queue;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var workItem = await _queue.DequeueAsync(stoppingToken);
            try
            {
                await workItem();
            }
            catch (Exception ex)
            {
                // Log error, retry, or write to dead-letter queue
            }
        }
    }
}
```

**Pros**: Fastest writes, absorbs write spikes
**Cons**: Risk of data loss if cache fails before write to DB

### Frontend Caching with React Query / TanStack Query

**Full Stack Caching Strategy:**
- **Backend**: Redis/distributed cache for server-side data
- **Frontend**: React Query for client-side cache + state management

```typescript
// React Query - Declarative data fetching with caching
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Fetch with automatic caching
const useProducts = () => {
    return useQuery({
        queryKey: ['products'],
        queryFn: async () => {
            const response = await fetch('/api/products');
            return response.json();
        },
        staleTime: 5 * 60 * 1000, // Consider data fresh for 5 minutes
        cacheTime: 10 * 60 * 1000, // Keep in cache for 10 minutes
        refetchOnWindowFocus: false, // Don't refetch when user returns to tab
    });
};

// Usage in component
const ProductList: React.FC = () => {
    const { data: products, isLoading, error } = useProducts();

    if (isLoading) return <div>Loading...</div>;
    if (error) return <div>Error loading products</div>;

    return (
        <ul>
            {products.map(p => <li key={p.id}>{p.name}</li>)}
        </ul>
    );
};

// Optimistic updates with cache manipulation
const useUpdateProduct = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async (product: Product) => {
            const response = await fetch(`/api/products/${product.id}`, {
                method: 'PUT',
                body: JSON.stringify(product)
            });
            return response.json();
        },
        onMutate: async (updatedProduct) => {
            // Cancel outgoing refetches
            await queryClient.cancelQueries({ queryKey: ['products'] });

            // Snapshot previous value
            const previous = queryClient.getQueryData(['products']);

            // Optimistically update cache
            queryClient.setQueryData(['products'], (old: Product[]) =>
                old.map(p => p.id === updatedProduct.id ? updatedProduct : p)
            );

            return { previous };
        },
        onError: (err, updatedProduct, context) => {
            // Rollback on error
            queryClient.setQueryData(['products'], context?.previous);
        },
        onSettled: () => {
            // Refetch after mutation (success or error)
            queryClient.invalidateQueries({ queryKey: ['products'] });
        }
    });
};

// Architect's Decision: Client-Side Cache Strategy
**When to use React Query:**
- ✅ Server state (data from APIs)
- ✅ Automatic caching and refetching
- ✅ Optimistic updates for better UX
- ✅ Background synchronization

**When to use React Context/Redux:**
- ✅ Client-side UI state (theme, modals, forms)
- ✅ State not derived from server
- ✅ Complex client-only state machines

**Hybrid Approach (Best Practice):**
- **React Query**: All server data (orders, products, users)
- **Zustand/Context**: UI state (sidebar open, current theme, draft forms)
```

---

## 5. Cache Invalidation Patterns

> "There are only two hard things in Computer Science: cache invalidation and naming things." - Phil Karlton

### TTL (Time-To-Live)

Simplest approach - cache expires after fixed time.

```csharp
await _cache.SetStringAsync(key, value, new DistributedCacheEntryOptions
{
    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15)
});
```

**Pros**: Simple, prevents stale data
**Cons**: Can serve stale data until expiry, cache stampede on expiry

### Explicit Invalidation

Invalidate cache when data changes.

```csharp
public class ProductService
{
    public async Task UpdateProductAsync(Product product)
    {
        // Update database
        await _repository.UpdateAsync(product);

        // Invalidate cache
        var cacheKey = $"product:{product.Id}";
        await _cache.RemoveAsync(cacheKey);

        // Optionally, also invalidate related caches
        await _cache.RemoveAsync($"products:category:{product.CategoryId}");
    }
}
```

**Pros**: Always consistent
**Cons**: Need to track all cache keys, complex with many relationships

### Event-Based Invalidation

Use events to invalidate cache across services.

```csharp
// Publisher
public class ProductService
{
    public async Task UpdateProductAsync(Product product)
    {
        await _repository.UpdateAsync(product);

        // Publish event
        await _bus.PublishAsync(new ProductUpdatedEvent
        {
            ProductId = product.Id,
            CategoryId = product.CategoryId
        });
    }
}

// Subscriber (could be in different service)
public class ProductCacheInvalidationHandler : IEventHandler<ProductUpdatedEvent>
{
    public async Task HandleAsync(ProductUpdatedEvent @event)
    {
        await _cache.RemoveAsync($"product:{@event.ProductId}");
        await _cache.RemoveAsync($"products:category:{@event.CategoryId}");
    }
}
```

### Cache Stampede Protection

When cache expires, many requests hit database simultaneously.

```csharp
public class ProductService
{
    private static readonly SemaphoreSlim _lock = new SemaphoreSlim(1, 1);

    public async Task<Product> GetProductAsync(Guid id)
    {
        var cacheKey = $"product:{id}";
        var cached = await _cache.GetStringAsync(cacheKey);

        if (cached != null)
            return JsonSerializer.Deserialize<Product>(cached);

        // Only one thread loads from database
        await _lock.WaitAsync();
        try
        {
            // Double-check after acquiring lock
            cached = await _cache.GetStringAsync(cacheKey);
            if (cached != null)
                return JsonSerializer.Deserialize<Product>(cached);

            // Load from database
            var product = await _repository.GetByIdAsync(id);

            if (product != null)
            {
                await _cache.SetStringAsync(cacheKey,
                    JsonSerializer.Serialize(product),
                    new DistributedCacheEntryOptions
                    {
                        AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15)
                    });
            }

            return product;
        }
        finally
        {
            _lock.Release();
        }
    }
}
```

---

## 6. Retry & Circuit Breaker Patterns

### Retry Pattern with Polly

```csharp
// Configure retry policy
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .Or<TimeoutException>()
    .WaitAndRetryAsync(
        retryCount: 3,
        sleepDurationProvider: attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)), // Exponential backoff
        onRetry: (exception, timespan, retryCount, context) =>
        {
            _logger.LogWarning(exception,
                "Retry {RetryCount} after {Delay}s", retryCount, timespan.TotalSeconds);
        });

// Use policy
var response = await retryPolicy.ExecuteAsync(async () =>
{
    return await _httpClient.GetAsync("https://api.example.com/products");
});
```

### Circuit Breaker Pattern

Prevents cascading failures by "opening" the circuit when errors exceed threshold.

```
CLOSED → OPEN → HALF-OPEN → CLOSED
(normal)  (fail fast)  (testing)  (recovered)

States:
- CLOSED: Normal operation, requests pass through
- OPEN: Too many failures, reject all requests immediately
- HALF-OPEN: Allow one request to test if service recovered
```

```csharp
// Circuit breaker configuration
var circuitBreakerPolicy = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(
        handledEventsAllowedBeforeBreaking: 5,  // Open after 5 failures
        durationOfBreak: TimeSpan.FromSeconds(30), // Stay open for 30s
        onBreak: (exception, duration) =>
        {
            _logger.LogError(exception, "Circuit breaker opened for {Duration}s", duration.TotalSeconds);
        },
        onReset: () =>
        {
            _logger.LogInformation("Circuit breaker reset");
        },
        onHalfOpen: () =>
        {
            _logger.LogInformation("Circuit breaker half-open, testing service");
        });

// Combine with retry
var policyWrap = Policy.WrapAsync(retryPolicy, circuitBreakerPolicy);

try
{
    var response = await policyWrap.ExecuteAsync(async () =>
    {
        return await _httpClient.GetAsync("https://api.example.com/products");
    });
}
catch (BrokenCircuitException)
{
    // Circuit is open, fail fast
    _logger.LogWarning("Request rejected - circuit breaker is open");
    return StatusCode(503, "Service temporarily unavailable");
}
```

### Complete Resilience Policy

```csharp
public class ResilientHttpClient
{
    private readonly HttpClient _httpClient;
    private readonly IAsyncPolicy<HttpResponseMessage> _policy;

    public ResilientHttpClient(HttpClient httpClient, ILogger<ResilientHttpClient> logger)
    {
        _httpClient = httpClient;

        // 1. Timeout policy (5 seconds per attempt)
        var timeoutPolicy = Policy.TimeoutAsync<HttpResponseMessage>(5);

        // 2. Retry policy (3 attempts with exponential backoff)
        var retryPolicy = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .Or<TimeoutRejectedException>()
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)),
                onRetry: (outcome, timespan, retryCount, context) =>
                {
                    logger.LogWarning("Retry {RetryCount} after {Delay}s",
                        retryCount, timespan.TotalSeconds);
                });

        // 3. Circuit breaker (open after 5 failures, stay open for 30s)
        var circuitBreakerPolicy = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .CircuitBreakerAsync(
                handledEventsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromSeconds(30),
                onBreak: (result, duration) =>
                {
                    logger.LogError("Circuit breaker opened for {Duration}s", duration.TotalSeconds);
                },
                onReset: () => logger.LogInformation("Circuit breaker reset"));

        // 4. Fallback policy (return cached response or default)
        var fallbackPolicy = Policy<HttpResponseMessage>
            .Handle<BrokenCircuitException>()
            .Or<TimeoutRejectedException>()
            .FallbackAsync(
                fallbackAction: async ct =>
                {
                    logger.LogWarning("Using fallback response");
                    return new HttpResponseMessage(HttpStatusCode.OK)
                    {
                        Content = new StringContent("{\"cached\": true}")
                    };
                });

        // Combine all policies
        _policy = Policy.WrapAsync(fallbackPolicy, circuitBreakerPolicy, retryPolicy, timeoutPolicy);
    }

    public async Task<HttpResponseMessage> GetAsync(string url)
    {
        return await _policy.ExecuteAsync(() => _httpClient.GetAsync(url));
    }
}
```

---

## 7. Rate Limiting Strategies

### Fixed Window

**When to use each algorithm:**
- **Fixed Window**: Simple, good enough for most cases, but allows bursts at boundaries
- **Sliding Window**: More accurate, prevents boundary bursts, higher memory cost
- **Token Bucket**: Allows controlled bursts, best for bursty traffic patterns
- **Leaky Bucket**: Smooths traffic, best for downstream rate limiting

```csharp
public class FixedWindowRateLimiter
{
    private readonly IDistributedCache _cache;
    private readonly int _maxRequests;
    private readonly TimeSpan _window;

    public FixedWindowRateLimiter(IDistributedCache cache, int maxRequests, TimeSpan window)
    {
        _cache = cache;
        _maxRequests = maxRequests;
        _window = window;
    }

    public async Task<bool> IsAllowedAsync(string clientId)
    {
        var key = $"ratelimit:{clientId}:{DateTime.UtcNow.Ticks / _window.Ticks}";
        var countStr = await _cache.GetStringAsync(key);
        var count = countStr != null ? int.Parse(countStr) : 0;

        if (count >= _maxRequests)
            return false;

        await _cache.SetStringAsync(key, (count + 1).ToString(),
            new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = _window });

        return true;
    }
}
```

**Problem**: Burst at window boundaries (100 requests at 00:00:59, 100 more at 00:01:00)

### Sliding Window

```csharp
public class SlidingWindowRateLimiter
{
    private readonly IConnectionMultiplexer _redis;
    private readonly int _maxRequests;
    private readonly TimeSpan _window;

    public async Task<bool> IsAllowedAsync(string clientId)
    {
        var key = $"ratelimit:{clientId}";
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var windowStart = now - (long)_window.TotalMilliseconds;

        var db = _redis.GetDatabase();

        // Use Redis sorted set - score is timestamp
        var transaction = db.CreateTransaction();

        // Remove old entries
        transaction.SortedSetRemoveRangeByScoreAsync(key, 0, windowStart);

        // Count current entries
        var countTask = transaction.SortedSetLengthAsync(key);

        await transaction.ExecuteAsync();
        var count = await countTask;

        if (count >= _maxRequests)
            return false;

        // Add current request
        await db.SortedSetAddAsync(key, now.ToString(), now);
        await db.KeyExpireAsync(key, _window);

        return true;
    }
}
```

### Token Bucket

```csharp
public class TokenBucketRateLimiter
{
    private readonly IDistributedCache _cache;
    private readonly int _bucketSize;
    private readonly int _refillRate; // tokens per second

    public async Task<bool> IsAllowedAsync(string clientId)
    {
        var key = $"ratelimit:bucket:{clientId}";
        var bucketJson = await _cache.GetStringAsync(key);

        TokenBucket bucket;
        if (bucketJson == null)
        {
            bucket = new TokenBucket
            {
                Tokens = _bucketSize,
                LastRefill = DateTime.UtcNow
            };
        }
        else
        {
            bucket = JsonSerializer.Deserialize<TokenBucket>(bucketJson);

            // Refill tokens based on time passed
            var elapsed = (DateTime.UtcNow - bucket.LastRefill).TotalSeconds;
            var tokensToAdd = (int)(elapsed * _refillRate);
            bucket.Tokens = Math.Min(_bucketSize, bucket.Tokens + tokensToAdd);
            bucket.LastRefill = DateTime.UtcNow;
        }

        if (bucket.Tokens < 1)
            return false;

        bucket.Tokens--;
        await _cache.SetStringAsync(key, JsonSerializer.Serialize(bucket));

        return true;
    }

    private class TokenBucket
    {
        public int Tokens { get; set; }
        public DateTime LastRefill { get; set; }
    }
}
```

### ASP.NET Core Built-in Rate Limiting (.NET 7+)

```csharp
// Program.cs
builder.Services.AddRateLimiter(options =>
{
    // Fixed window
    options.AddFixedWindowLimiter("fixed", opt =>
    {
        opt.Window = TimeSpan.FromMinutes(1);
        opt.PermitLimit = 100;
        opt.QueueLimit = 10;
    });

    // Sliding window
    options.AddSlidingWindowLimiter("sliding", opt =>
    {
        opt.Window = TimeSpan.FromMinutes(1);
        opt.PermitLimit = 100;
        opt.SegmentsPerWindow = 6; // 10-second segments
    });

    // Token bucket
    options.AddTokenBucketLimiter("token", opt =>
    {
        opt.TokenLimit = 100;
        opt.ReplenishmentPeriod = TimeSpan.FromSeconds(1);
        opt.TokensPerPeriod = 10;
    });

    // Concurrency limiter
    options.AddConcurrencyLimiter("concurrent", opt =>
    {
        opt.PermitLimit = 10; // Max 10 concurrent requests
        opt.QueueLimit = 5;
    });
});

app.UseRateLimiter();

// Apply to endpoint
app.MapGet("/api/products", () => { })
    .RequireRateLimiting("sliding");

// Or globally
[EnableRateLimiting("fixed")]
public class ProductsController : ControllerBase { }
```

---

## 8. Idempotency in Distributed Systems

### The Problem

Network failures can cause duplicate requests.

```
Client → Server: "Create Order $100"
           ↓
Server creates order
           ↓
Server → Client: Response (lost in network!)

Client thinks it failed, retries
Client → Server: "Create Order $100" (again!)
           ↓
Server creates ANOTHER order (charged twice!)
```

### Solution: Idempotency Keys

```csharp
public class OrderController : ControllerBase
{
    private readonly IOrderRepository _orders;
    private readonly IDistributedCache _cache;

    [HttpPost("orders")]
    public async Task<IActionResult> CreateOrder(
        [FromBody] CreateOrderRequest request,
        [FromHeader(Name = "Idempotency-Key")] string idempotencyKey)
    {
        if (string.IsNullOrEmpty(idempotencyKey))
            return BadRequest("Idempotency-Key header required");

        var cacheKey = $"idempotency:{idempotencyKey}";

        // Check if we've seen this key before
        var cachedResponse = await _cache.GetStringAsync(cacheKey);
        if (cachedResponse != null)
        {
            // Return cached response - idempotent!
            var existingOrder = JsonSerializer.Deserialize<Order>(cachedResponse);
            return Ok(existingOrder);
        }

        // First time seeing this key - process request
        var order = new Order
        {
            Id = Guid.NewGuid(),
            CustomerId = request.CustomerId,
            Total = request.Total,
            IdempotencyKey = idempotencyKey // Store key with order
        };

        await _orders.SaveAsync(order);

        // Cache the response for 24 hours
        await _cache.SetStringAsync(cacheKey,
            JsonSerializer.Serialize(order),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
            });

        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
    }
}
```

### Database-Based Idempotency

```csharp
public class Order
{
    public Guid Id { get; set; }
    public string IdempotencyKey { get; set; } // Unique index
    public decimal Total { get; set; }
    // ...
}

// DbContext configuration
modelBuilder.Entity<Order>()
    .HasIndex(o => o.IdempotencyKey)
    .IsUnique();

// Service
public async Task<Order> CreateOrderAsync(CreateOrderRequest request, string idempotencyKey)
{
    // Try to find existing order with this key
    var existing = await _db.Orders
        .FirstOrDefaultAsync(o => o.IdempotencyKey == idempotencyKey);

    if (existing != null)
        return existing; // Already processed

    var order = new Order
    {
        Id = Guid.NewGuid(),
        IdempotencyKey = idempotencyKey,
        Total = request.Total
    };

    try
    {
        _db.Orders.Add(order);
        await _db.SaveChangesAsync();
        return order;
    }
    catch (DbUpdateException ex) when (ex.IsUniqueConstraintViolation())
    {
        // Race condition - another request created it
        return await _db.Orders.FirstAsync(o => o.IdempotencyKey == idempotencyKey);
    }
}
```

---

## 9. CAP Theorem

### The Theorem

You can only guarantee 2 of 3:

**Architect's Reality Check:**
- Network partitions WILL happen (P is mandatory in distributed systems)
- Real choice: **CP vs AP**
- Most systems need different guarantees for different data
- **Example**: User profile (AP - eventual consistency OK), Bank balance (CP - must be consistent)
- **C**onsistency: All nodes see the same data
- **A**vailability: Every request gets a response
- **P**artition Tolerance: System continues despite network failures

```
      Consistency
           /\
          /  \
         /    \
        /  CA  \
       /        \
      /          \
     /  CP    AP  \
    /              \
   /_Partition______\_Availability
      Tolerance
```

### CP System (Consistency + Partition Tolerance)

**Example**: Banking systems, inventory management

```csharp
// Strong consistency - all replicas must agree
public class InventoryService
{
    private readonly IDbConnection _db;

    public async Task<bool> ReserveStockAsync(Guid productId, int quantity)
    {
        // Use transaction with READ COMMITTED or higher
        using var transaction = await _db.BeginTransactionAsync(IsolationLevel.ReadCommitted);

        var product = await _db.QuerySingleAsync<Product>(
            "SELECT * FROM Products WHERE Id = @Id FOR UPDATE", // Lock row
            new { Id = productId });

        if (product.Stock < quantity)
        {
            await transaction.RollbackAsync();
            return false; // Unavailable if stock insufficient
        }

        product.Stock -= quantity;
        await _db.ExecuteAsync(
            "UPDATE Products SET Stock = @Stock WHERE Id = @Id",
            new { product.Stock, product.Id });

        await transaction.CommitAsync();
        return true;
    }
}
```

**Trade-off**: If partition occurs, system becomes unavailable (can't guarantee consistency).

### AP System (Availability + Partition Tolerance)

**Example**: Social media feeds, DNS, shopping cart

```csharp
// Eventually consistent - always available
public class ShoppingCartService
{
    private readonly IDistributedCache _cache;

    public async Task AddItemAsync(string userId, CartItem item)
    {
        var key = $"cart:{userId}";

        // Best-effort write - might go to one replica
        var cartJson = await _cache.GetStringAsync(key);
        var cart = cartJson != null
            ? JsonSerializer.Deserialize<Cart>(cartJson)
            : new Cart();

        cart.Items.Add(item);

        // Write succeeds even if some replicas are down
        await _cache.SetStringAsync(key, JsonSerializer.Serialize(cart));

        // Eventually, all replicas will sync
    }
}
```

**Trade-off**: Different users might see different cart states temporarily.

### Practical Example: Multi-Region Database

```csharp
// Cosmos DB - AP system with tunable consistency
var cosmosClient = new CosmosClient(
    connectionString,
    new CosmosClientOptions
    {
        ConsistencyLevel = ConsistencyLevel.Eventual // Fastest, but might read stale data
        // ConsistencyLevel.Strong       - CP behavior (slow, consistent)
        // ConsistencyLevel.BoundedStaleness - Read lag < 10 minutes
        // ConsistencyLevel.Session      - Consistent within user session (good for UX)
    });

// With eventual consistency
var cart = await container.ReadItemAsync<Cart>(cartId, partitionKey);
// Might not reflect latest write from another region

// Force strong consistency for critical operations
var order = await container.ReadItemAsync<Order>(
    orderId,
    partitionKey,
    new ItemRequestOptions { ConsistencyLevel = ConsistencyLevel.Strong });
```

---

## 10. Read/Write Separation (CQRS Light)

> **What is CQRS?**
>
> **CQRS (Command Query Responsibility Segregation)** is an architectural pattern that separates read operations (queries) from write operations (commands) into different models, and often different databases.
>
> **Key Concepts:**
> - **Command**: An operation that changes state (create, update, delete). Commands don't return data.
> - **Query**: An operation that reads state without modifying it. Queries return data.
> - **Write Model**: Optimized for transactional integrity, normalized structure
> - **Read Model**: Optimized for query performance, denormalized, can have pre-computed views
>
> **Why use CQRS?**
> - **Scalability**: Read and write workloads scale independently (reads usually 10-100x more than writes)
> - **Optimization**: Each model optimized for its purpose (normalized writes, denormalized reads)
> - **Complexity Management**: Separates complex business logic (commands) from simple queries
> - **Performance**: Read model can be heavily cached, replicated, or use different storage
>
> **When to use:**
> - Read/write ratio is very skewed (e.g., 100:1 reads to writes)
> - Complex domain with many business rules
> - Different scaling needs for reads vs writes
> - Read queries need complex aggregations
>
> **When NOT to use:**
> - Simple CRUD applications
> - Small scale (added complexity not worth it)
> - Strong consistency requirements between reads and writes

### The Pattern

Separate read and write models for scalability.

```
        Write Path (Commands)          Read Path (Queries)
              │                              │
    ┌─────────▼──────────┐         ┌────────▼─────────┐
    │  Command Handler   │         │  Query Handler   │
    └─────────┬──────────┘         └────────┬─────────┘
              │                              │
    ┌─────────▼──────────┐         ┌────────▼─────────┐
    │  Write Database    │────────▶│  Read Database   │
    │  (Normalized)      │ Sync    │  (Denormalized)  │
    └────────────────────┘         └──────────────────┘
```

### Implementation

```csharp
// Write Model - Normalized, transactional
public class OrderCommandHandler
{
    private readonly ApplicationDbContext _db;
    private readonly IMessageBus _bus;

    public async Task<Guid> HandleCreateOrderAsync(CreateOrderCommand command)
    {
        using var transaction = await _db.Database.BeginTransactionAsync();

        var order = new Order
        {
            Id = Guid.NewGuid(),
            CustomerId = command.CustomerId,
            Status = OrderStatus.Pending
        };
        _db.Orders.Add(order);

        foreach (var item in command.Items)
        {
            _db.OrderItems.Add(new OrderItem
            {
                OrderId = order.Id,
                ProductId = item.ProductId,
                Quantity = item.Quantity
            });
        }

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        // Publish event to update read model
        await _bus.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            CustomerId = command.CustomerId,
            Items = command.Items.ToList()
        });

        return order.Id;
    }
}

// Read Model - Denormalized for fast queries
public class OrderQueryHandler
{
    private readonly IMongoDatabase _readDb; // Document database for reads

    public async Task<OrderSummary> GetOrderSummaryAsync(Guid orderId)
    {
        var collection = _readDb.GetCollection<OrderSummary>("OrderSummaries");

        // Single document with all data - no joins!
        return await collection
            .Find(o => o.Id == orderId)
            .FirstOrDefaultAsync();
    }

    public async Task<List<OrderListItem>> GetCustomerOrdersAsync(Guid customerId)
    {
        var collection = _readDb.GetCollection<OrderListItem>("OrderList");

        // Optimized for this specific query
        return await collection
            .Find(o => o.CustomerId == customerId)
            .SortByDescending(o => o.CreatedAt)
            .Limit(50)
            .ToListAsync();
    }
}

// Read Model Updater
public class OrderCreatedEventHandler : IEventHandler<OrderCreatedEvent>
{
    private readonly IMongoDatabase _readDb;

    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        var collection = _readDb.GetCollection<OrderSummary>("OrderSummaries");

        // Build denormalized document
        var summary = new OrderSummary
        {
            Id = @event.OrderId,
            CustomerId = @event.CustomerId,
            Items = @event.Items.Select(i => new OrderItemSummary
            {
                ProductName = GetProductName(i.ProductId), // Denormalize
                Quantity = i.Quantity,
                Price = i.Price
            }).ToList(),
            Total = @event.Items.Sum(i => i.Price * i.Quantity),
            CreatedAt = DateTime.UtcNow
        };

        await collection.InsertOneAsync(summary);
    }
}
```

### Benefits

- **Write DB**: Optimized for consistency, normalized, transactional
- **Read DB**: Optimized for query performance, denormalized, eventual consistency
- **Scaling**: Scale reads independently (most apps are read-heavy)

---

## 11. Back-Pressure Handling

### The Problem

Fast producers overwhelm slow consumers.

```
Producer: 1000 msg/sec ──▶ Queue ──▶ Consumer: 100 msg/sec
                            (fills up!)
```

### Solution 1: Push-Back

```csharp
public class MessagePublisher
{
    private readonly IMessageQueue _queue;
    private readonly int _maxQueueSize = 10000;

    public async Task PublishAsync<T>(T message)
    {
        var currentSize = await _queue.GetSizeAsync();

        if (currentSize >= _maxQueueSize)
        {
            // Apply back-pressure - slow down producer
            await Task.Delay(TimeSpan.FromSeconds(1)); // Wait before retry

            // Or throw exception to signal producer to slow down
            throw new QueueFullException("Queue at capacity, please retry later");
        }

        await _queue.EnqueueAsync(message);
    }
}
```

### Solution 2: Bounded Channels (.NET)

```csharp
public class OrderProcessingService
{
    private readonly Channel<Order> _channel;

    public OrderProcessingService()
    {
        // Bounded channel with back-pressure
        _channel = Channel.CreateBounded<Order>(new BoundedChannelOptions(1000)
        {
            FullMode = BoundedChannelFullMode.Wait // Producer waits when full
            // FullMode = BoundedChannelFullMode.DropOldest // Drop oldest item
            // FullMode = BoundedChannelFullMode.DropNewest // Drop newest item
            // FullMode = BoundedChannelFullMode.DropWrite // Drop current write
        });

        // Start consumer
        _ = ConsumeOrdersAsync();
    }

    public async Task EnqueueOrderAsync(Order order)
    {
        // This will block if channel is full (back-pressure!)
        await _channel.Writer.WriteAsync(order);
    }

    private async Task ConsumeOrdersAsync()
    {
        await foreach (var order in _channel.Reader.ReadAllAsync())
        {
            await ProcessOrderAsync(order);
        }
    }
}
```

### Solution 3: Rate Limiting Producer

```csharp
public class RateLimitedPublisher
{
    private readonly SemaphoreSlim _rateLimiter;

    public RateLimitedPublisher(int maxConcurrent)
    {
        _rateLimiter = new SemaphoreSlim(maxConcurrent, maxConcurrent);
    }

    public async Task PublishAsync<T>(T message)
    {
        await _rateLimiter.WaitAsync(); // Wait for slot
        try
        {
            await _queue.EnqueueAsync(message);
        }
        finally
        {
            // Release after a delay to control rate
            _ = Task.Delay(TimeSpan.FromMilliseconds(100))
                .ContinueWith(_ => _rateLimiter.Release());
        }
    }
}
```

---

## 12. Complete System Design Example

### Problem: Design an E-Commerce Order System

**Requirements**:
- Handle 1000 orders/minute
- 99.9% availability
- Order placement < 500ms (P95)
- Support inventory tracking
- Process payments
- Eventually notify warehouse

### Solution Architecture

```
           ┌──────────────┐
           │  API Gateway │ (Rate Limiting, Auth)
           └──────┬───────┘
                  │
     ┌────────────┼────────────┐
     │            │            │
┌────▼─────┐ ┌───▼────┐ ┌─────▼────┐
│Order Svc │ │Inv Svc │ │Payment   │
└────┬─────┘ └───┬────┘ │Service   │
     │           │       └─────┬────┘
     │      ┌────▼────┐        │
     │      │ Redis   │        │
     │      │ Cache   │        │
     │      └─────────┘        │
     │                         │
     └──────────┬──────────────┘
                │
         ┌──────▼───────┐
         │  Event Bus   │ (Azure Service Bus / RabbitMQ)
         └──────┬───────┘
                │
    ┌───────────┼────────────┐
    │           │            │
┌───▼───────┐ ┌─▼────────┐ ┌▼────────┐
│Warehouse  │ │Email     │ │Analytics│
│Service    │ │Service   │ │Service  │
└───────────┘ └──────────┘ └─────────┘
```

### Implementation

```csharp
// 1. API Gateway (Rate Limiting + Circuit Breaker)
[ApiController]
[Route("api/orders")]
[EnableRateLimiting("sliding")] // 100 req/min per user
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrdersController> _logger;

    [HttpPost]
    public async Task<IActionResult> CreateOrder(
        [FromBody] CreateOrderRequest request,
        [FromHeader(Name = "Idempotency-Key")] string idempotencyKey,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(idempotencyKey))
            return BadRequest("Idempotency-Key header required");

        try
        {
            var order = await _orderService.CreateOrderAsync(request, idempotencyKey, cancellationToken);
            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (InsufficientInventoryException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (PaymentFailedException ex)
        {
            return BadRequest(ex.Message);
        }
    }
}

// 2. Order Service (Orchestration + Resilience)
public class OrderService : IOrderService
{
    private readonly IOrderRepository _orders;
    private readonly IInventoryServiceClient _inventory;
    private readonly IPaymentServiceClient _payment;
    private readonly IMessageBus _bus;
    private readonly IDistributedCache _cache;
    private readonly ILogger<OrderService> _logger;

    public async Task<Order> CreateOrderAsync(
        CreateOrderRequest request,
        string idempotencyKey,
        CancellationToken cancellationToken)
    {
        // Check idempotency
        var cacheKey = $"order:idempotency:{idempotencyKey}";
        var cached = await _cache.GetStringAsync(cacheKey, cancellationToken);
        if (cached != null)
        {
            _logger.LogInformation("Returning cached order for idempotency key {Key}", idempotencyKey);
            return JsonSerializer.Deserialize<Order>(cached);
        }

        // Create order (pending status)
        var order = new Order
        {
            Id = Guid.NewGuid(),
            CustomerId = request.CustomerId,
            Status = OrderStatus.Pending,
            IdempotencyKey = idempotencyKey,
            CreatedAt = DateTime.UtcNow
        };

        await _orders.SaveAsync(order, cancellationToken);

        try
        {
            // Step 1: Check inventory (with circuit breaker)
            var inventoryAvailable = await _inventory.CheckAvailabilityAsync(
                request.Items,
                cancellationToken);

            if (!inventoryAvailable)
            {
                order.Status = OrderStatus.InsufficientInventory;
                await _orders.SaveAsync(order, cancellationToken);
                throw new InsufficientInventoryException("Insufficient inventory");
            }

            // Step 2: Reserve inventory (with retry)
            await _inventory.ReserveAsync(order.Id, request.Items, cancellationToken);
            order.Status = OrderStatus.InventoryReserved;
            await _orders.SaveAsync(order, cancellationToken);

            // Step 3: Process payment (with timeout)
            var paymentResult = await _payment.ChargeAsync(
                order.Id,
                request.PaymentMethod,
                order.Total,
                cancellationToken);

            if (!paymentResult.IsSuccessful)
            {
                // Compensate - release inventory
                await _inventory.ReleaseAsync(order.Id, cancellationToken);
                order.Status = OrderStatus.PaymentFailed;
                await _orders.SaveAsync(order, cancellationToken);
                throw new PaymentFailedException("Payment failed");
            }

            // Success!
            order.Status = OrderStatus.Confirmed;
            order.TransactionId = paymentResult.TransactionId;
            await _orders.SaveAsync(order, cancellationToken);

            // Publish event (fire-and-forget)
            await _bus.PublishAsync(new OrderConfirmedEvent
            {
                OrderId = order.Id,
                CustomerId = order.CustomerId,
                Items = request.Items,
                Total = order.Total
            }, cancellationToken);

            // Cache result (24 hours)
            await _cache.SetStringAsync(
                cacheKey,
                JsonSerializer.Serialize(order),
                new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
                },
                cancellationToken);

            return order;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create order {OrderId}", order.Id);
            order.Status = OrderStatus.Failed;
            await _orders.SaveAsync(order, cancellationToken);
            throw;
        }
    }
}

// 3. Inventory Service (Caching + Optimistic Locking)
public class InventoryService : IInventoryService
{
    private readonly IDistributedCache _cache;
    private readonly IInventoryRepository _repository;

    public async Task<bool> CheckAvailabilityAsync(
        List<OrderItem> items,
        CancellationToken cancellationToken)
    {
        foreach (var item in items)
        {
            // Check cache first
            var cacheKey = $"inventory:stock:{item.ProductId}";
            var cachedStock = await _cache.GetStringAsync(cacheKey, cancellationToken);

            int stock;
            if (cachedStock != null)
            {
                stock = int.Parse(cachedStock);
            }
            else
            {
                // Cache miss - load from database
                stock = await _repository.GetStockAsync(item.ProductId, cancellationToken);
                await _cache.SetStringAsync(
                    cacheKey,
                    stock.ToString(),
                    new DistributedCacheEntryOptions
                    {
                        AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
                    },
                    cancellationToken);
            }

            if (stock < item.Quantity)
                return false;
        }

        return true;
    }

    public async Task ReserveAsync(
        Guid orderId,
        List<OrderItem> items,
        CancellationToken cancellationToken)
    {
        using var transaction = await _repository.BeginTransactionAsync(cancellationToken);

        try
        {
            foreach (var item in items)
            {
                // Optimistic locking (row version)
                var product = await _repository.GetProductAsync(item.ProductId, cancellationToken);

                if (product.Stock < item.Quantity)
                    throw new InsufficientInventoryException();

                product.Stock -= item.Quantity;
                await _repository.UpdateProductAsync(product, cancellationToken);

                // Invalidate cache
                await _cache.RemoveAsync($"inventory:stock:{item.ProductId}", cancellationToken);

                // Record reservation
                await _repository.AddReservationAsync(new Reservation
                {
                    OrderId = orderId,
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(15) // Auto-release if payment fails
                }, cancellationToken);
            }

            await transaction.CommitAsync(cancellationToken);
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }
}

// 4. Event Handlers (Async Processing)
public class OrderConfirmedEventHandler : IEventHandler<OrderConfirmedEvent>
{
    private readonly IWarehouseService _warehouse;
    private readonly IEmailService _email;

    public async Task HandleAsync(OrderConfirmedEvent @event)
    {
        // These run asynchronously, don't block order creation
        await Task.WhenAll(
            _warehouse.CreateShipmentAsync(@event.OrderId, @event.Items),
            _email.SendOrderConfirmationAsync(@event.CustomerId, @event.OrderId)
        );
    }
}

// 5. Resilient HTTP Client
public class InventoryServiceClient : IInventoryServiceClient
{
    private readonly HttpClient _httpClient;
    private readonly IAsyncPolicy<HttpResponseMessage> _policy;

    public InventoryServiceClient(HttpClient httpClient)
    {
        _httpClient = httpClient;

        var retry = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .WaitAndRetryAsync(3, attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)));

        var circuitBreaker = Policy
            .HandleResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
            .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));

        var timeout = Policy.TimeoutAsync<HttpResponseMessage>(5);

        _policy = Policy.WrapAsync(circuitBreaker, retry, timeout);
    }

    public async Task<bool> CheckAvailabilityAsync(List<OrderItem> items, CancellationToken ct)
    {
        var response = await _policy.ExecuteAsync(() =>
            _httpClient.PostAsJsonAsync("/api/inventory/check", items, ct));

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<bool>(cancellationToken: ct);
    }
}
```

### Key Design Decisions

1. **Sync for critical path** (inventory, payment) - need immediate feedback
2. **Async for notifications** (warehouse, email) - don't block user
3. **Idempotency** - safe retries
4. **Circuit breaker** - prevent cascading failures
5. **Caching** - reduce database load
6. **Event-driven** - loose coupling
7. **Graceful degradation** - fail fast with meaningful errors

---

## Interview Questions

### Q1: "Monolith or microservices for a new startup?"

**Good Answer**: "Monolith first, always. Here's why:

1. **Speed**: Faster to develop, deploy, and iterate
2. **Simplicity**: No distributed systems complexity
3. **Cost**: Lower operational overhead
4. **Transactions**: ACID transactions are easy
5. **Discovery**: Don't know service boundaries yet

Start with a modular monolith - use clear boundaries (interfaces, modules) so you CAN extract microservices later if needed. Most startups fail before they need to scale beyond a monolith.

Only go microservices when:
- Team > 50 engineers
- Different components need independent scaling
- You have DevOps maturity (CI/CD, monitoring, tracing)"

### Q2: "How do you handle consistency across microservices?"

**Good Answer**: "You can't have ACID transactions across services, so you have two options:

**1. Saga Pattern** (covered in Day 08)
**2. Eventual Consistency**

Example: Order service doesn't wait for email service
```csharp
// Order created immediately
await _repository.SaveOrderAsync(order);

// Email sent asynchronously
await _bus.PublishAsync(new OrderCreatedEvent { OrderId = order.Id });
```

User sees 'Order confirmed' instantly. Email arrives seconds later. This is acceptable for most use cases.

For critical consistency (e.g., payment), use synchronous calls within the same transaction boundary, or use a distributed transaction coordinator (not recommended - complex and slow)."

### Q3: "How do you design for high availability?"

**Good Answer**:
"1. **No single point of failure**: Everything is replicated
2. **Stateless services**: Any instance can handle any request
3. **Graceful degradation**: Failing components don't bring down system
4. **Circuit breakers**: Fast failure, don't wait for timeouts
5. **Health checks**: Automatic removal of unhealthy instances
6. **Multi-region**: Deploy across regions for disaster recovery

Example:
```csharp
// Fallback when payment service is down
try
{
    await _paymentService.ChargeAsync(amount);
}
catch (PaymentServiceException)
{
    // Fall back to async processing
    await _queue.EnqueueAsync(new ProcessPaymentLater { OrderId = order.Id });
    return OrderResult.PendingPayment(); // Still let user continue
}
```"

---

## Summary

**Key Principles**:
1. **Start simple**: Monolith first
2. **Stateless services**: Enable horizontal scaling
3. **Async where possible**: Decouple services
4. **Cache aggressively**: Reduce load
5. **Fail gracefully**: Circuit breakers, retries, fallbacks
6. **Idempotency**: Safe retries
7. **CAP theorem**: Choose consistency OR availability (can't have both during partition)
8. **Eventual consistency**: Acceptable for most use cases

