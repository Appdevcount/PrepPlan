# Day 4-5 — Core Foundation Topics

## Overview
These days cover foundational concepts that are essential but often assumed. Review these to ensure there are no gaps in your knowledge.

---

## 1. HTTP Fundamentals

### HTTP Methods & Semantics

**Architect's Decision Guide:**
- **Idempotent methods** (GET, PUT, DELETE): Safe to retry automatically
- **Non-idempotent methods** (POST, PATCH): Require client-side idempotency handling
- **Common mistake**: Using GET for operations that modify state
- **Best practice**: Use POST for non-idempotent operations, PUT for full replacement

**Full Stack Consideration:**
- **React/SPA**: Use `fetch` API or libraries (axios, React Query) to consume these endpoints
- **Error handling**: Frontend must handle all HTTP status codes gracefully
- **Loading states**: Frontend shows loading indicators during async requests
- **Optimistic updates**: Frontend can update UI before API response for better UX

```csharp
// GET - Retrieve resource (idempotent, safe, cacheable)
[HttpGet("orders/{id}")]
public async Task<ActionResult<OrderDto>> GetOrder(int id)
{
    // Should not modify state
    // Can be cached
    // Multiple calls return same result
}

// React/TypeScript client example
const fetchOrder = async (orderId: number): Promise<Order> => {
    const response = await fetch(`/api/orders/${orderId}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        }
    });

    if (!response.ok) {
        if (response.status === 404) throw new NotFoundError('Order not found');
        if (response.status === 401) throw new UnauthorizedError('Please login');
        throw new Error('Failed to fetch order');
    }

    return response.json();
};

// POST - Create resource (not idempotent)
[HttpPost("orders")]
public async Task<ActionResult<OrderDto>> CreateOrder(CreateOrderDto dto)
{
    // Creates new resource
    // Multiple calls create multiple resources
    // Returns 201 Created with Location header
    var order = await _service.CreateAsync(dto);
    return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
}

// React hook with React Query for optimistic updates
const useCreateOrder = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async (orderData: CreateOrderDto) => {
            const response = await fetch('/api/orders', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(orderData)
            });

            if (!response.ok) throw new Error('Failed to create order');
            return response.json();
        },
        onMutate: async (newOrder) => {
            // Optimistic update - show in UI immediately
            await queryClient.cancelQueries({ queryKey: ['orders'] });
            const previousOrders = queryClient.getQueryData(['orders']);

            queryClient.setQueryData(['orders'], (old: Order[]) => [
                ...old,
                { ...newOrder, id: 'temp-' + Date.now(), status: 'Creating...' }
            ]);

            return { previousOrders };
        },
        onSuccess: (data) => {
            // Refresh data after successful creation
            queryClient.invalidateQueries({ queryKey: ['orders'] });
        },
        onError: (err, newOrder, context) => {
            // Rollback on error
            queryClient.setQueryData(['orders'], context?.previousOrders);
        }
    });
};

// PUT - Replace resource (idempotent)
[HttpPut("orders/{id}")]
public async Task<IActionResult> UpdateOrder(int id, UpdateOrderDto dto)
{
    // Replaces entire resource
    // Multiple calls with same data produce same result
    await _service.UpdateAsync(id, dto);
    return NoContent();
}

// PATCH - Partial update (not necessarily idempotent)
[HttpPatch("orders/{id}")]
public async Task<IActionResult> PatchOrder(int id, JsonPatchDocument<OrderDto> patch)
{
    // Updates specific fields
    var order = await _service.GetAsync(id);
    patch.ApplyTo(order);
    await _service.SaveAsync(order);
    return NoContent();
}

// DELETE - Remove resource (idempotent)
[HttpDelete("orders/{id}")]
public async Task<IActionResult> DeleteOrder(int id)
{
    // First call deletes, subsequent calls return 404 or 204
    await _service.DeleteAsync(id);
    return NoContent();
}
```

### Status Codes

**Tech Lead Guidelines:**
- **200 vs 204**: Use 204 (No Content) for successful operations with no response body
- **201 vs 200**: Always use 201 for resource creation with Location header
- **400 vs 422**: 400 for malformed requests, 422 for valid format but business rule violation
- **401 vs 403**: 401 = not authenticated, 403 = authenticated but not authorized
- **500 vs 503**: 503 when dependency is down (retry later), 500 for unexpected errors

```csharp
// 2xx Success
return Ok(data);                          // 200 OK
return Created(location, data);           // 201 Created
return Accepted();                        // 202 Accepted (async operation)
return NoContent();                       // 204 No Content

// 3xx Redirection
return RedirectToAction("GetOrder", new { id });  // 302 Found
return RedirectPermanent("/new-url");     // 301 Moved Permanently

// 4xx Client Errors
return BadRequest(modelState);            // 400 Bad Request
return Unauthorized();                    // 401 Unauthorized
return Forbidden();                       // 403 Forbidden
return NotFound();                        // 404 Not Found
return Conflict("Resource already exists"); // 409 Conflict
return UnprocessableEntity(errors);       // 422 Unprocessable Entity

// 5xx Server Errors
return StatusCode(500, "Internal error"); // 500 Internal Server Error
return StatusCode(503, "Service unavailable"); // 503 Service Unavailable
```

### HTTP Headers
```csharp
// Request headers
[HttpGet("orders")]
public async Task<IActionResult> GetOrders(
    [FromHeader(Name = "Authorization")] string authHeader,
    [FromHeader(Name = "Accept")] string accept,
    [FromHeader(Name = "If-None-Match")] string etag)
{
    // Authorization: Bearer <token>
    // Accept: application/json
    // If-None-Match: "version-123"
}

// Response headers
[HttpGet("orders/{id}")]
public async Task<IActionResult> GetOrder(int id)
{
    var order = await _service.GetAsync(id);

    Response.Headers.Add("Cache-Control", "max-age=3600");
    Response.Headers.Add("ETag", $"\"{order.Version}\"");
    Response.Headers.Add("X-Rate-Limit-Remaining", "99");

    return Ok(order);
}

// CORS headers
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins("https://example.com", "http://localhost:3000") // React dev server
              .WithMethods("GET", "POST", "PUT", "DELETE")
              .WithHeaders("Content-Type", "Authorization")
              .AllowCredentials(); // Required for cookies/auth tokens
    });
});

// Full Stack Integration - CORS for React Apps
**React Development Setup:**
// package.json - proxy API calls during development
{
  "proxy": "https://localhost:5001"
}

// Production - explicit fetch with credentials
const response = await fetch('https://api.myapp.com/orders', {
    method: 'POST',
    credentials: 'include', // Send cookies with request
    headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(orderData)
});

**Architect's Decision:**
- **Development**: Use proxy to avoid CORS issues locally
- **Production**: Configure CORS on backend, whitelist specific origins (never use "*")
- **Credentials**: Only enable AllowCredentials() if using cookies (not for bearer tokens)
- **Preflight**: Browser sends OPTIONS request first for non-simple requests
```

---

## 2. RESTful API Design Principles

### Resource Naming
```
Good:
/api/orders                 - Collection
/api/orders/123             - Specific resource
/api/orders/123/items       - Sub-resource
/api/customers/456/orders   - Nested resource

Bad:
/api/getOrders              - Verb in URL (use HTTP method)
/api/order                  - Singular for collection
/api/orders/delete/123      - Action in URL
```

### REST Constraints
```csharp
// 1. Stateless - each request contains all needed info
[HttpGet("orders")]
public async Task<IActionResult> GetOrders(
    [FromQuery] int page,
    [FromQuery] int pageSize,
    [FromHeader(Name = "Authorization")] string token)
{
    // Don't rely on server-side session
    // All state in request (auth token, pagination params)
}

// 2. Cacheable - explicitly mark responses
[HttpGet("products/{id}")]
[ResponseCache(Duration = 3600, Location = ResponseCacheLocation.Any)]
public async Task<ActionResult<ProductDto>> GetProduct(int id)
{
    // Response can be cached for 1 hour
}

// 3. Uniform Interface
// - Use standard HTTP methods
// - Consistent resource structure
// - HATEOAS (optional)

// 4. Layered System - client doesn't know if connected to end server
// - Use load balancers, API gateways transparently
```

---

## 3. SQL & Database Fundamentals

### Indexes
```sql
-- Clustered Index (table is physically ordered by this)
-- Only one per table
CREATE CLUSTERED INDEX IX_Orders_OrderDate
ON Orders(OrderDate);

-- Non-Clustered Index (separate structure with pointers)
-- Can have multiple
CREATE NONCLUSTERED INDEX IX_Orders_CustomerId
ON Orders(CustomerId)
INCLUDE (OrderDate, Total); -- Covering index

-- Composite Index (order matters!)
CREATE INDEX IX_Orders_CustomerId_OrderDate
ON Orders(CustomerId, OrderDate);

-- Good for: WHERE CustomerId = 1
-- Good for: WHERE CustomerId = 1 AND OrderDate > '2024-01-01'
-- Bad for: WHERE OrderDate > '2024-01-01' (CustomerId not specified)

-- Index usage in EF Core
public class Order
{
    public int Id { get; set; }

    [Index] // Creates index
    public int CustomerId { get; set; }

    [Index(nameof(CustomerId), nameof(OrderDate))] // Composite
    public DateTime OrderDate { get; set; }
}
```

### Query Optimization

#### Understanding the N+1 Query Problem

**What is the N+1 Query Problem?**

The N+1 query problem is a common performance anti-pattern in database access where an application executes 1 initial query to fetch a list of N records, then executes N additional queries (one for each record) to fetch related data. This results in N+1 total database round-trips instead of 1 or 2 optimized queries.

**Why is it a problem?**
- **Performance Impact**: Each database query has overhead (network latency, connection setup, query parsing). With N+1 queries, if you have 100 orders, you make 101 database calls instead of 1-2.
- **Scalability**: The problem gets exponentially worse as data grows. 1,000 orders = 1,001 queries.
- **Database Load**: Excessive queries can overwhelm the database connection pool and slow down the entire application.

**Example Scenario:**
```
Fetching 100 orders with customer names:

N+1 Approach (BAD):
- Query 1: SELECT * FROM Orders                    → Returns 100 orders
- Query 2: SELECT * FROM Customers WHERE Id = 1    → Customer for Order 1
- Query 3: SELECT * FROM Customers WHERE Id = 2    → Customer for Order 2
- ... (98 more queries)
- Query 101: SELECT * FROM Customers WHERE Id = 100
Total: 101 queries, ~500ms+ latency

Optimized Approach (GOOD):
- Query 1: SELECT o.*, c.* FROM Orders o
           JOIN Customers c ON o.CustomerId = c.Id
Total: 1 query, ~5ms latency
```

**How to detect N+1 queries:**
- Monitor SQL logs for repetitive similar queries
- Use Application Insights to track database call counts per request
- Enable EF Core logging with `EnableSensitiveDataLogging()`

```csharp
// BAD - N+1 query problem
public async Task<List<OrderDto>> GetOrdersWithCustomer()
{
    var orders = await _context.Orders.ToListAsync(); // 1 query

    foreach (var order in orders)
    {
        // N queries (one per order)!
        var customer = await _context.Customers
            .FirstOrDefaultAsync(c => c.Id == order.CustomerId);
    }
}

// GOOD - Eager loading
public async Task<List<OrderDto>> GetOrdersWithCustomerOptimized()
{
    var orders = await _context.Orders
        .Include(o => o.Customer)  // Single JOIN
        .Include(o => o.Items)
            .ThenInclude(i => i.Product)
        .ToListAsync(); // 1 query

    return orders;
}

// Use AsNoTracking for read-only queries
public async Task<List<OrderDto>> GetOrdersReadOnly()
{
    return await _context.Orders
        .AsNoTracking() // Faster, no change tracking overhead
        .Select(o => new OrderDto
        {
            Id = o.Id,
            Total = o.Total
        })
        .ToListAsync();
}

// Avoid loading unnecessary data
// BAD
var orders = await _context.Orders
    .Include(o => o.Items) // Loads all items
    .ToListAsync();

// GOOD - Project only needed fields
var orders = await _context.Orders
    .Select(o => new OrderSummaryDto
    {
        Id = o.Id,
        Total = o.Total,
        ItemCount = o.Items.Count // Calculated in SQL
    })
    .ToListAsync();
```

### Transactions
```csharp
// Manual transaction control
public async Task TransferFunds(int fromAccount, int toAccount, decimal amount)
{
    using var transaction = await _context.Database.BeginTransactionAsync();

    try
    {
        var from = await _context.Accounts.FindAsync(fromAccount);
        var to = await _context.Accounts.FindAsync(toAccount);

        from.Balance -= amount;
        to.Balance += amount;

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();
    }
    catch
    {
        await transaction.RollbackAsync();
        throw;
    }
}

// Isolation levels
public async Task ReadData()
{
    using var transaction = await _context.Database.BeginTransactionAsync(
        IsolationLevel.ReadCommitted); // Default

    // ReadUncommitted - Dirty reads possible
    // ReadCommitted - No dirty reads
    // RepeatableRead - No dirty reads, no non-repeatable reads
    // Serializable - Strictest, prevents phantom reads
    // Snapshot - Uses row versioning
}
```

### Connection Pooling
```csharp
// Connection string configuration
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=MyDb;User Id=sa;Password=***;Min Pool Size=5;Max Pool Size=100;Connection Lifetime=300;"
}

// Proper DbContext usage in DI
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions =>
        {
            sqlOptions.EnableRetryOnFailure(
                maxRetryCount: 3,
                maxRetryDelay: TimeSpan.FromSeconds(10),
                errorNumbersToAdd: null);
        }));

// NEVER do this (creates connection leak)
public class BadService
{
    private readonly AppDbContext _context;

    public BadService()
    {
        _context = new AppDbContext(); // BAD! Not pooled, never disposed
    }
}

// CORRECT - use DI
public class GoodService
{
    private readonly AppDbContext _context;

    public GoodService(AppDbContext context) // Injected, properly managed
    {
        _context = context;
    }
}
```

---

## 4. Authentication vs Authorization

### Authentication - "Who are you?"
```csharp
// JWT Authentication setup
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// Generate JWT token
public string GenerateToken(User user)
{
    var claims = new[]
    {
        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
        new Claim(ClaimTypes.Name, user.Username),
        new Claim(ClaimTypes.Email, user.Email),
        new Claim(ClaimTypes.Role, user.Role)
    };

    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

    var token = new JwtSecurityToken(
        issuer: _config["Jwt:Issuer"],
        audience: _config["Jwt:Audience"],
        claims: claims,
        expires: DateTime.UtcNow.AddHours(24),
        signingCredentials: creds);

    return new JwtSecurityTokenHandler().WriteToken(token);
}

// Protect endpoints
[Authorize] // Requires authentication
[HttpGet("profile")]
public async Task<ActionResult<UserProfile>> GetProfile()
{
    var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
    return await _service.GetProfileAsync(int.Parse(userId));
}

// React Frontend - JWT Authentication
**Full Stack Auth Flow:**

// 1. React Context for Auth State
interface AuthContextType {
    user: User | null;
    token: string | null;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
    isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [user, setUser] = useState<User | null>(null);
    const [token, setToken] = useState<string | null>(
        sessionStorage.getItem('token') // Or use memory for better security
    );

    const login = async (email: string, password: string) => {
        const response = await fetch('/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        if (!response.ok) throw new Error('Login failed');

        const data = await response.json();
        setToken(data.token);
        setUser(data.user);

        // SECURITY NOTE: sessionStorage is XSS vulnerable
        // Better: Store in memory and use refresh tokens
        sessionStorage.setItem('token', data.token);
    };

    const logout = () => {
        setToken(null);
        setUser(null);
        sessionStorage.removeItem('token');
    };

    return (
        <AuthContext.Provider value={{
            user,
            token,
            login,
            logout,
            isAuthenticated: !!token
        }}>
            {children}
        </AuthContext.Provider>
    );
};

// 2. Protected Route Component
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const { isAuthenticated } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        if (!isAuthenticated) {
            navigate('/login');
        }
    }, [isAuthenticated, navigate]);

    if (!isAuthenticated) return null;

    return <>{children}</>;
};

// 3. API Client with Token Injection
const createAuthenticatedFetch = (token: string | null) => {
    return async (url: string, options: RequestInit = {}) => {
        const headers = {
            'Content-Type': 'application/json',
            ...(token && { 'Authorization': `Bearer ${token}` }),
            ...options.headers
        };

        const response = await fetch(url, { ...options, headers });

        if (response.status === 401) {
            // Token expired - redirect to login
            window.location.href = '/login';
            throw new Error('Unauthorized');
        }

        return response;
    };
};

// 4. Usage in Components
const ProfilePage: React.FC = () => {
    const { token } = useAuth();
    const [profile, setProfile] = useState<UserProfile | null>(null);

    useEffect(() => {
        const fetchProfile = async () => {
            const authFetch = createAuthenticatedFetch(token);
            const response = await authFetch('/api/profile');
            const data = await response.json();
            setProfile(data);
        };

        fetchProfile();
    }, [token]);

    return <div>{profile?.name}</div>;
};

**Token Storage Decision Matrix:**
| Storage | Security | Persistence | XSS Vulnerable | Best For |
|---------|----------|-------------|----------------|----------|
| Memory (useState) | High | No | Partial | Short sessions, high security |
| sessionStorage | Low | Session | Yes | Acceptable risk, session-only |
| localStorage | Low | Permanent | Yes | ❌ Avoid for tokens |
| HttpOnly Cookie | Highest | Yes | No | ✅ Best with CSRF protection |
```

### Authorization - "What can you do?"
```csharp
// Role-based authorization
[Authorize(Roles = "Admin")]
[HttpDelete("users/{id}")]
public async Task<IActionResult> DeleteUser(int id)
{
    // Only Admin role can execute
}

// Policy-based authorization
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));

    options.AddPolicy("CanDeleteOrder", policy =>
        policy.Requirements.Add(new OrderDeletionRequirement()));

    options.AddPolicy("MinimumAge", policy =>
        policy.Requirements.Add(new MinimumAgeRequirement(18)));
});

// Custom authorization handler
public class OrderDeletionRequirement : IAuthorizationRequirement { }

public class OrderDeletionHandler : AuthorizationHandler<OrderDeletionRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        OrderDeletionRequirement requirement)
    {
        var userRole = context.User.FindFirstValue(ClaimTypes.Role);

        if (userRole == "Admin" || userRole == "Manager")
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}

// Register handler
builder.Services.AddSingleton<IAuthorizationHandler, OrderDeletionHandler>();

// Use policy
[Authorize(Policy = "CanDeleteOrder")]
[HttpDelete("orders/{id}")]
public async Task<IActionResult> DeleteOrder(int id)
{
    // Only users who meet policy requirements
}

// Resource-based authorization
[HttpPut("orders/{id}")]
public async Task<IActionResult> UpdateOrder(int id, UpdateOrderDto dto)
{
    var order = await _service.GetAsync(id);

    // Check if user owns the order
    var authResult = await _authorizationService.AuthorizeAsync(
        User, order, "CanModifyOrder");

    if (!authResult.Succeeded)
    {
        return Forbid();
    }

    await _service.UpdateAsync(order, dto);
    return NoContent();
}
```

---

## 5. LINQ Fundamentals

### Deferred Execution
```csharp
// Query is not executed here
var query = _context.Orders
    .Where(o => o.Total > 100)
    .OrderBy(o => o.OrderDate);

// Execution happens here (when enumerated)
var orders = await query.ToListAsync(); // Database query executed

// Multiple enumerations = multiple executions
foreach (var order in query) { } // Query executed
foreach (var order in query) { } // Query executed AGAIN

// Solution: materialize once
var ordersList = await query.ToListAsync();
foreach (var order in ordersList) { } // In-memory
foreach (var order in ordersList) { } // In-memory
```

### Query vs Method Syntax
```csharp
// Query syntax
var results = from o in _context.Orders
              where o.Total > 100
              orderby o.OrderDate descending
              select new { o.Id, o.Total };

// Method syntax (same result)
var results = _context.Orders
    .Where(o => o.Total > 100)
    .OrderByDescending(o => o.OrderDate)
    .Select(o => new { o.Id, o.Total });

// Method syntax is more flexible
var results = _context.Orders
    .Where(o => o.Total > 100)
    .GroupBy(o => o.CustomerId)
    .Select(g => new
    {
        CustomerId = g.Key,
        OrderCount = g.Count(),
        TotalSpent = g.Sum(o => o.Total)
    });
```

### Common Operations
```csharp
// Filtering
var filtered = orders.Where(o => o.Total > 100);

// Projection
var projected = orders.Select(o => new OrderDto
{
    Id = o.Id,
    Total = o.Total
});

// Aggregation
var total = orders.Sum(o => o.Total);
var average = orders.Average(o => o.Total);
var count = orders.Count();
var any = orders.Any(o => o.Total > 1000);
var all = orders.All(o => o.Total > 0);

// Grouping
var grouped = orders
    .GroupBy(o => o.CustomerId)
    .Select(g => new
    {
        CustomerId = g.Key,
        Orders = g.ToList()
    });

// Joining
var result = _context.Orders
    .Join(_context.Customers,
        order => order.CustomerId,
        customer => customer.Id,
        (order, customer) => new
        {
            OrderId = order.Id,
            CustomerName = customer.Name
        });

// Left join
var leftJoin = _context.Customers
    .GroupJoin(_context.Orders,
        customer => customer.Id,
        order => order.CustomerId,
        (customer, orders) => new
        {
            Customer = customer,
            Orders = orders
        })
    .SelectMany(
        x => x.Orders.DefaultIfEmpty(),
        (x, order) => new
        {
            CustomerName = x.Customer.Name,
            OrderId = order?.Id
        });

// Pagination
var page = orders
    .Skip((pageNumber - 1) * pageSize)
    .Take(pageSize);

// First/Single/Last
var first = orders.First(); // Throws if empty
var firstOrDefault = orders.FirstOrDefault(); // Returns null if empty
var single = orders.Single(o => o.Id == 1); // Throws if 0 or >1 results
var singleOrDefault = orders.SingleOrDefault(o => o.Id == 1);
var last = orders.Last();
```

---

## 6. Async/Await Best Practices

### Async All the Way
```csharp
// BAD - Mixing sync and async
public void ProcessOrder(int orderId)
{
    var order = GetOrderAsync(orderId).Result; // Blocks!
    UpdateOrder(order);
}

// GOOD - Async all the way
public async Task ProcessOrderAsync(int orderId)
{
    var order = await GetOrderAsync(orderId);
    await UpdateOrderAsync(order);
}
```

### ConfigureAwait
```csharp
// Library code - don't need context
public async Task<Data> FetchDataAsync()
{
    var result = await _httpClient.GetAsync(url)
        .ConfigureAwait(false); // Don't capture context

    return await result.Content.ReadAsAsync<Data>()
        .ConfigureAwait(false);
}

// Application code - usually need context (ASP.NET Core doesn't matter)
public async Task<IActionResult> GetData()
{
    var data = await FetchDataAsync(); // Default ConfigureAwait(true)
    return Ok(data); // Safe, same context
}
```

### Cancellation Tokens
```csharp
[HttpGet("orders")]
public async Task<ActionResult<List<OrderDto>>> GetOrders(
    CancellationToken cancellationToken)
{
    // Token automatically cancelled if client disconnects

    var orders = await _context.Orders
        .ToListAsync(cancellationToken); // Pass to async operations

    return Ok(orders);
}

// Manual cancellation
public async Task ProcessWithTimeout()
{
    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));

    try
    {
        await LongRunningOperationAsync(cts.Token);
    }
    catch (OperationCanceledException)
    {
        // Operation timed out
    }
}
```

---

## 7. Serialization (JSON)

### System.Text.Json (Default in ASP.NET Core)
```csharp
// Configuration
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.DefaultIgnoreCondition =
            JsonIgnoreCondition.WhenWritingNull;
        options.JsonSerializerOptions.Converters.Add(
            new JsonStringEnumConverter());
    });

// Custom serialization
public class Order
{
    public int Id { get; set; }

    [JsonPropertyName("order_total")]
    public decimal Total { get; set; }

    [JsonIgnore] // Don't serialize
    public string InternalNotes { get; set; }

    [JsonConverter(typeof(CustomDateTimeConverter))]
    public DateTime OrderDate { get; set; }
}

// Manual serialization
var json = JsonSerializer.Serialize(order, new JsonSerializerOptions
{
    WriteIndented = true
});

var order = JsonSerializer.Deserialize<Order>(json);
```

### Newtonsoft.Json (Legacy, more features)
```csharp
builder.Services.AddControllers()
    .AddNewtonsoftJson(options =>
    {
        options.SerializerSettings.ContractResolver =
            new CamelCasePropertyNamesContractResolver();
        options.SerializerSettings.NullValueHandling = NullValueHandling.Ignore;
        options.SerializerSettings.Converters.Add(
            new StringEnumConverter());
    });

public class Order
{
    [JsonProperty("order_id")]
    public int Id { get; set; }

    [JsonIgnore]
    public string Internal { get; set; }
}
```

---

## 8. Caching Basics

### In-Memory Cache
```csharp
builder.Services.AddMemoryCache();

public class ProductService
{
    private readonly IMemoryCache _cache;

    public async Task<Product> GetProductAsync(int id)
    {
        var cacheKey = $"product_{id}";

        if (_cache.TryGetValue(cacheKey, out Product product))
        {
            return product; // Cache hit
        }

        // Cache miss - fetch from database
        product = await _repository.GetByIdAsync(id);

        // Store in cache
        _cache.Set(cacheKey, product, new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10),
            SlidingExpiration = TimeSpan.FromMinutes(2)
        });

        return product;
    }
}
```

### Response Caching
```csharp
builder.Services.AddResponseCaching();

app.UseResponseCaching();

[HttpGet("products/{id}")]
[ResponseCache(Duration = 3600, Location = ResponseCacheLocation.Any)]
public async Task<ActionResult<ProductDto>> GetProduct(int id)
{
    // Response cached for 1 hour
    var product = await _service.GetAsync(id);
    return Ok(product);
}

// Vary by query string
[ResponseCache(Duration = 3600, VaryByQueryKeys = new[] { "category", "page" })]
[HttpGet("products")]
public async Task<IActionResult> GetProducts(string category, int page)
{
    // Different cache entries for different query params
}
```

### Distributed Cache (Redis)
```csharp
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis");
    options.InstanceName = "MyApp_";
});

public class OrderService
{
    private readonly IDistributedCache _cache;

    public async Task<Order> GetOrderAsync(int id)
    {
        var cacheKey = $"order_{id}";

        var cached = await _cache.GetStringAsync(cacheKey);
        if (cached != null)
        {
            return JsonSerializer.Deserialize<Order>(cached);
        }

        var order = await _repository.GetByIdAsync(id);

        await _cache.SetStringAsync(
            cacheKey,
            JsonSerializer.Serialize(order),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
            });

        return order;
    }
}
```

---

## 9. Environment Configuration

### appsettings.json
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyDb;"
  },
  "JwtSettings": {
    "Issuer": "MyApp",
    "Audience": "MyApp",
    "Key": "super-secret-key",
    "ExpirationMinutes": 1440
  },
  "ExternalApis": {
    "PaymentGateway": {
      "BaseUrl": "https://api.payment.com",
      "ApiKey": "key123"
    }
  }
}
```

### Configuration binding
```csharp
// Options pattern
public class JwtSettings
{
    public string Issuer { get; set; }
    public string Audience { get; set; }
    public string Key { get; set; }
    public int ExpirationMinutes { get; set; }
}

// Registration
builder.Services.Configure<JwtSettings>(
    builder.Configuration.GetSection("JwtSettings"));

// Usage
public class AuthService
{
    private readonly JwtSettings _jwtSettings;

    public AuthService(IOptions<JwtSettings> jwtSettings)
    {
        _jwtSettings = jwtSettings.Value;
    }

    public string GenerateToken(User user)
    {
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_jwtSettings.Key));
        // Use _jwtSettings.Issuer, etc.
    }
}
```

### Environment-specific configuration
```
appsettings.json                 - Base settings
appsettings.Development.json     - Dev overrides
appsettings.Production.json      - Prod overrides
```

```csharp
// In Program.cs - automatically loaded based on environment
var environment = builder.Environment.EnvironmentName; // "Development" or "Production"

if (builder.Environment.IsDevelopment())
{
    // Development-specific configuration
}
else
{
    // Production-specific configuration
}

// User secrets (Development only)
// dotnet user-secrets set "ApiKey" "secret123"
var apiKey = builder.Configuration["ApiKey"];
```

---

## Deliverables
- ✔ Solid understanding of HTTP, REST, and API design
- ✔ Database query optimization and indexing knowledge
- ✔ Authentication vs Authorization clarity
- ✔ LINQ proficiency
- ✔ Async/await best practices
- ✔ Configuration management
