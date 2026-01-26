# Day 18: Mock Technical Interviews

## Technical Interview Format and Structure

### Typical Interview Flow (60-90 minutes)

**Tech Lead/Architect Interview Focus:**
- Expect deeper architecture discussions (not just coding)
- More emphasis on trade-offs and decision-making
- Team leadership and mentorship questions
- Production incident handling scenarios

1. **Introduction (5-10 minutes)**
   - Interviewer introduces themselves and role
   - Brief overview of interview structure
   - Your 2-minute professional introduction

2. **Technical Discussion (20-30 minutes)**
   - Deep dive into your experience
   - Technology-specific questions
   - Architecture and design decisions

3. **Coding/Problem Solving (20-30 minutes)**
   - Live coding exercise
   - Problem-solving scenario
   - Code review or refactoring exercise

4. **System Design/Architecture (15-20 minutes)**
   - Mini system design question
   - Architecture discussion
   - Trade-off analysis

5. **Your Questions (5-10 minutes)**
   - Questions about team, tech stack, culture
   - Shows engagement and interest

---

## Common C# and .NET Questions (25+ Q&A)

### Fundamentals

**Q1: Explain the difference between value types and reference types in C#.**

**A:** Value types store data directly and are allocated on the stack (or inline in objects). Examples include int, bool, struct, enum. Reference types store a reference to the data location and are allocated on the heap. Examples include classes, interfaces, delegates, strings.

Key differences:
- Value types: Copying creates independent copies, default to 0/false/null values
- Reference types: Copying copies the reference, multiple variables can reference same object
- Value types can't be null (unless Nullable<T>), reference types can be null

**Architect follow-up:** "When would you choose a struct over a class for performance reasons? Consider memory allocation patterns and GC pressure."

**Q2: What is the difference between `String` and `StringBuilder`?**

**A:**
- `String` is immutable - every modification creates a new string object in memory
- `StringBuilder` is mutable - modifications happen in-place without creating new objects
- Use `String` for few concatenations or when immutability is desired
- Use `StringBuilder` for multiple concatenations (especially in loops) for better performance
- Example scenario: Building a CSV file with 1000 rows - StringBuilder is 10-100x faster

**Q3: Explain the different types of polymorphism in C#.**

**A:**
1. **Compile-time (Static) Polymorphism:**
   - Method overloading: Same method name, different parameters
   - Operator overloading: Custom behavior for operators

2. **Runtime (Dynamic) Polymorphism:**
   - Method overriding: Using `virtual` and `override` keywords
   - Interface implementation
   - Decided at runtime based on actual object type

```csharp
// Example
public class PaymentProcessor
{
    // Overloading (compile-time)
    public void Process(CreditCard card) { }
    public void Process(BankAccount account) { }

    // Overriding (runtime)
    public virtual decimal CalculateFee() => 2.5m;
}

public class PremiumProcessor : PaymentProcessor
{
    public override decimal CalculateFee() => 1.5m;
}
```

**Q4: What is the difference between `IEnumerable<T>` and `IQueryable<T>`?**

**A:**
- `IEnumerable<T>`: In-memory collection, uses LINQ to Objects
  - Filtering happens in application memory
  - Entire dataset loaded first, then filtered
  - Best for in-memory collections

- `IQueryable<T>`: Out-of-memory (database/remote), uses LINQ to SQL/EF
  - Filtering happens at data source (SQL query)
  - Only filtered data is loaded
  - Best for database queries

```csharp
// IEnumerable - loads all users then filters in memory
IEnumerable<User> users = context.Users.ToList();
var active = users.Where(u => u.IsActive); // Filters in C#

// IQueryable - filters at database level
IQueryable<User> users = context.Users;
var active = users.Where(u => u.IsActive); // Generates SQL WHERE clause
```

**Q5: Explain async/await and why we use it.**

**A:** Async/await enables asynchronous programming, allowing threads to be freed while waiting for I/O operations.

Benefits:
- Improves application scalability (more concurrent requests)
- Keeps UI responsive
- Better resource utilization

```csharp
// Without async - blocks thread
public string GetData()
{
    var result = httpClient.Get(url); // Thread blocked here
    return result;
}

// With async - frees thread
public async Task<string> GetDataAsync()
{
    var result = await httpClient.GetAsync(url); // Thread freed during wait
    return result;
}
```

Key points:
- Async methods should return `Task` or `Task<T>`
- Await keyword unwraps Task and resumes execution after completion
- Not the same as multi-threading - it's about freeing threads during I/O

### Object-Oriented Programming

**Q6: What are the SOLID principles? Provide examples.**

**A:**

**S - Single Responsibility Principle:**
A class should have one reason to change.
```csharp
// Bad - multiple responsibilities
public class UserService
{
    public void CreateUser() { }
    public void SendEmail() { }
    public void LogActivity() { }
}

// Good - separated responsibilities
public class UserService
{
    private IEmailService _emailService;
    private ILogger _logger;

    public void CreateUser() { }
}
```

**O - Open/Closed Principle:**
Open for extension, closed for modification.
```csharp
// Use abstraction to extend behavior
public interface IPaymentMethod { }
public class CreditCardPayment : IPaymentMethod { }
public class PayPalPayment : IPaymentMethod { }

public class PaymentProcessor
{
    public void Process(IPaymentMethod payment) { } // No modification needed for new types
}
```

**L - Liskov Substitution Principle:**
Derived classes must be substitutable for base classes.
```csharp
// Derived class should work wherever base class works
public class Rectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }
}

public class Square : Rectangle
{
    // Violates LSP if we force Width == Height
    // Better to use separate hierarchy
}
```

**I - Interface Segregation Principle:**
No client should depend on methods it doesn't use.
```csharp
// Bad - fat interface
public interface IWorker
{
    void Work();
    void Eat();
    void Sleep();
}

// Good - segregated interfaces
public interface IWorkable { void Work(); }
public interface IFeedable { void Eat(); }
```

**D - Dependency Inversion Principle:**
Depend on abstractions, not concretions.
```csharp
// Good - depends on interface
public class OrderService
{
    private readonly IPaymentGateway _gateway;

    public OrderService(IPaymentGateway gateway) // Injected
    {
        _gateway = gateway;
    }
}
```

**Q7: What is dependency injection and what are its benefits?**

**A:** Dependency Injection is a design pattern where dependencies are provided to a class rather than the class creating them.

Benefits:
- Loose coupling between classes
- Easier unit testing (can inject mocks)
- Better maintainability
- Single Responsibility adherence

```csharp
// Without DI - tightly coupled
public class OrderService
{
    private EmailService _emailService = new EmailService(); // Hard to test
}

// With DI - loosely coupled
public class OrderService
{
    private readonly IEmailService _emailService;

    public OrderService(IEmailService emailService)
    {
        _emailService = emailService; // Can inject mock for testing
    }
}

// ASP.NET Core registration
services.AddScoped<IEmailService, EmailService>();
```

**Q8: Explain the difference between abstract class and interface.**

**A:**

**Abstract Class:**
- Can have implementation
- Can have fields and constructors
- Supports access modifiers
- Single inheritance only
- Use when: Classes share common implementation

**Interface:**
- No implementation (C# 8+ allows default implementations)
- No fields, only properties/methods
- All members public by default
- Multiple inheritance supported
- Use when: Defining contracts for unrelated classes

```csharp
// Abstract class - shared implementation
public abstract class Animal
{
    protected string Name { get; set; } // Field

    public Animal(string name) // Constructor
    {
        Name = name;
    }

    public void Eat() { } // Concrete method
    public abstract void MakeSound(); // Must implement
}

// Interface - pure contract
public interface IFlyable
{
    void Fly();
}

public class Bird : Animal, IFlyable // Can implement both
{
    public Bird(string name) : base(name) { }
    public override void MakeSound() { }
    public void Fly() { }
}
```

### .NET Core & ASP.NET Core

**Q9: What is the difference between .NET Framework and .NET Core/.NET?**

**A:**

**.NET Framework (Legacy):**
- Windows-only
- Monolithic
- Full framework install required
- Web: ASP.NET (System.Web)
- Last version: 4.8

**.NET Core / .NET (Modern):**
- Cross-platform (Windows, Linux, macOS)
- Modular (NuGet packages)
- Side-by-side versioning
- Web: ASP.NET Core
- Better performance
- Cloud-optimized
- Current: .NET 8 (November 2023)

Migration considerations:
- .NET Framework maintenance mode
- New features only in .NET
- .NET Standard for shared libraries

**Q10: Explain the middleware pipeline in ASP.NET Core.**

**A:** Middleware is software assembled into an application pipeline to handle requests and responses.

Key concepts:
- Order matters - middleware executes in registration order
- Each component can execute code before and after next component
- Short-circuiting - middleware can stop pipeline execution

```csharp
public void Configure(IApplicationBuilder app)
{
    // Request flows through in order
    app.UseHttpsRedirection();     // 1. Redirect to HTTPS
    app.UseStaticFiles();          // 2. Serve static files (may short-circuit)
    app.UseRouting();              // 3. Match endpoint
    app.UseAuthentication();       // 4. Authenticate user
    app.UseAuthorization();        // 5. Authorize user
    app.UseEndpoints(endpoints =>  // 6. Execute endpoint
    {
        endpoints.MapControllers();
    });
}

// Custom middleware
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;

    public async Task InvokeAsync(HttpContext context)
    {
        // Before next middleware
        Console.WriteLine($"Request: {context.Request.Path}");

        await _next(context); // Call next middleware

        // After next middleware (response)
        Console.WriteLine($"Response: {context.Response.StatusCode}");
    }
}
```

**Q11: What are the different service lifetimes in .NET Core DI?**

**A:**

**1. Transient (AddTransient):**
- New instance created every time requested
- Use for: Lightweight, stateless services
- Example: Utility classes, factories

**2. Scoped (AddScoped):**
- New instance per HTTP request/scope
- Use for: Database contexts, unit of work
- Example: DbContext, services with per-request state

**3. Singleton (AddSingleton):**
- Single instance for application lifetime
- Use for: Stateless services, caches, configuration
- Example: Configuration, logging, memory cache

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddTransient<IEmailService, EmailService>();
    services.AddScoped<IOrderService, OrderService>();
    services.AddSingleton<IMemoryCache, MemoryCache>();
}
```

Thread safety considerations:
- Singletons must be thread-safe
- Scoped services are safe within single request
- Don't inject scoped into singleton

**Q12: How does model binding work in ASP.NET Core?**

**A:** Model binding maps HTTP request data to action method parameters.

Sources (in order):
1. Form data (POST forms)
2. Route values (URL segments)
3. Query strings
4. Request body (JSON)

```csharp
public class ProductController : ControllerBase
{
    // Binding from route
    [HttpGet("{id}")]
    public IActionResult Get(int id) // id from route
    {
    }

    // Binding from query string
    [HttpGet]
    public IActionResult Search(string query, int page = 1) // ?query=test&page=2
    {
    }

    // Binding from body
    [HttpPost]
    public IActionResult Create([FromBody] ProductDto product) // JSON body
    {
    }

    // Multiple sources
    [HttpPut("{id}")]
    public IActionResult Update(
        [FromRoute] int id,
        [FromBody] ProductDto product,
        [FromHeader] string authorization)
    {
    }
}
```

Attributes for control:
- `[FromRoute]` - URL path
- `[FromQuery]` - Query string
- `[FromBody]` - Request body
- `[FromHeader]` - HTTP header
- `[FromForm]` - Form data

### Entity Framework Core

**Q13: What is the difference between eager loading, lazy loading, and explicit loading in EF Core?**

**A:**

> **Quick Definitions:**
> - **Eager Loading**: Load related data upfront in the same query (using JOINs). "Get me orders AND their customers in one trip."
> - **Lazy Loading**: Load related data only when accessed. "Get me orders now, fetch customer only when I ask for it." (Risk: N+1 queries)
> - **Explicit Loading**: Manually trigger loading of related data on demand. "I'll tell you exactly when to load the customer."

**1. Eager Loading (Include):**
Loads related data as part of initial query.
```csharp
var orders = context.Orders
    .Include(o => o.Customer)
    .Include(o => o.OrderItems)
        .ThenInclude(oi => oi.Product)
    .ToList(); // Single query with JOINs
```
Pros: Single query, predictable performance
Cons: May load unnecessary data

**2. Lazy Loading:**
Loads related data automatically when accessed.
```csharp
var order = context.Orders.First(); // Query 1
var customer = order.Customer; // Query 2 (automatic)
```
Pros: Load only what's needed
Cons: N+1 problem, requires proxies

**3. Explicit Loading:**
Manually load related data when needed.
```csharp
var order = context.Orders.First();
context.Entry(order)
    .Collection(o => o.OrderItems)
    .Load(); // Explicit query
```
Pros: Control over when to load
Cons: More code, multiple queries

Best practice: Prefer eager loading for known relationships.

**Q14: What are tracking and no-tracking queries in EF Core?**

**A:**

**Tracking (Default):**
EF Core tracks changes to entities for update/delete operations.
```csharp
var user = context.Users.First(u => u.Id == 1); // Tracked
user.Name = "Updated";
context.SaveChanges(); // EF knows about change
```

**No-Tracking:**
EF Core doesn't track entities - read-only scenarios.
```csharp
var users = context.Users
    .AsNoTracking()
    .ToList(); // Not tracked
```

Benefits of AsNoTracking:
- Better performance (no change tracking overhead)
- Lower memory usage
- Use for read-only queries

Use tracking when:
- Need to update/delete entities
- Working with small result sets

**Q15: How do you handle database migrations in EF Core?**

**A:**

```bash
# Create migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update

# Rollback to specific migration
dotnet ef database update PreviousMigrationName

# Generate SQL script
dotnet ef migrations script

# Remove last migration (if not applied)
dotnet ef migrations remove
```

Code-first workflow:
```csharp
public class ApplicationDbContext : DbContext
{
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        modelBuilder.Entity<Order>()
            .Property(o => o.Total)
            .HasPrecision(18, 2);
    }
}
```

Production strategies:
- Generate SQL scripts for review
- Apply during deployment pipeline
- Use migration bundles for automated deployment
- Never auto-migrate in production

### Performance & Best Practices

**Q16: How do you implement caching in .NET applications?**

**A:**

**1. In-Memory Cache:**
```csharp
public class ProductService
{
    private readonly IMemoryCache _cache;

    public async Task<Product> GetProductAsync(int id)
    {
        return await _cache.GetOrCreateAsync($"product_{id}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10);
            entry.SlidingExpiration = TimeSpan.FromMinutes(2);

            return await _repository.GetByIdAsync(id);
        });
    }
}
```

**2. Distributed Cache (Redis):**
```csharp
public class ProductService
{
    private readonly IDistributedCache _cache;

    public async Task<Product> GetProductAsync(int id)
    {
        var key = $"product_{id}";
        var cached = await _cache.GetStringAsync(key);

        if (cached != null)
            return JsonSerializer.Deserialize<Product>(cached);

        var product = await _repository.GetByIdAsync(id);

        await _cache.SetStringAsync(key,
            JsonSerializer.Serialize(product),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1)
            });

        return product;
    }
}
```

**3. Response Caching:**
```csharp
[ResponseCache(Duration = 60, Location = ResponseCacheLocation.Any)]
[HttpGet]
public IActionResult GetProducts()
{
    return Ok(_products);
}
```

Cache strategies:
- Cache-Aside: Application manages cache
- Write-Through: Write to cache and DB simultaneously
- Write-Behind: Write to cache, async write to DB

**Q17: What is the Repository pattern and when should you use it?**

**A:**

Repository pattern abstracts data access logic.

```csharp
// Interface
public interface IRepository<T> where T : class
{
    Task<T> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

// Implementation
public class Repository<T> : IRepository<T> where T : class
{
    private readonly DbContext _context;
    private readonly DbSet<T> _dbSet;

    public Repository(DbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T> GetByIdAsync(int id)
    {
        return await _dbSet.FindAsync(id);
    }

    // ... other methods
}

// Specific repository
public interface IOrderRepository : IRepository<Order>
{
    Task<IEnumerable<Order>> GetOrdersByCustomerAsync(int customerId);
}

public class OrderRepository : Repository<Order>, IOrderRepository
{
    public OrderRepository(AppDbContext context) : base(context) { }

    public async Task<IEnumerable<Order>> GetOrdersByCustomerAsync(int customerId)
    {
        return await _dbSet
            .Where(o => o.CustomerId == customerId)
            .Include(o => o.OrderItems)
            .ToListAsync();
    }
}
```

Benefits:
- Decouples business logic from data access
- Easier to test (mock repositories)
- Centralized data access logic
- Swappable data sources

When NOT to use:
- Simple CRUD applications
- EF Core already provides abstraction
- Over-engineering for small projects

**Q18: How do you handle exceptions in ASP.NET Core?**

**A:**

**1. Exception Handling Middleware:**
```csharp
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception");
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception ex)
    {
        context.Response.ContentType = "application/json";

        var response = ex switch
        {
            NotFoundException => (StatusCodes.Status404NotFound, "Resource not found"),
            ValidationException => (StatusCodes.Status400BadRequest, ex.Message),
            UnauthorizedException => (StatusCodes.Status401Unauthorized, "Unauthorized"),
            _ => (StatusCodes.Status500InternalServerError, "Internal server error")
        };

        context.Response.StatusCode = response.Item1;

        await context.Response.WriteAsJsonAsync(new
        {
            error = response.Item2,
            statusCode = response.Item1
        });
    }
}
```

**2. Exception Filters:**
```csharp
public class ApiExceptionFilterAttribute : ExceptionFilterAttribute
{
    public override void OnException(ExceptionContext context)
    {
        if (context.Exception is ValidationException validationEx)
        {
            context.Result = new BadRequestObjectResult(new
            {
                errors = validationEx.Errors
            });
            context.ExceptionHandled = true;
        }
    }
}
```

**3. Global Error Handler:**
```csharp
public void Configure(IApplicationBuilder app)
{
    if (env.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }
    else
    {
        app.UseExceptionHandler("/error");
        app.UseHsts();
    }
}

[ApiController]
public class ErrorController : ControllerBase
{
    [Route("/error")]
    public IActionResult Error()
    {
        var context = HttpContext.Features.Get<IExceptionHandlerFeature>();
        var exception = context?.Error;

        // Log exception

        return Problem();
    }
}
```

**Q19: What are the different ways to improve .NET application performance?**

**A:**

**1. Async/Await:**
```csharp
// Use async for I/O operations
public async Task<List<Order>> GetOrdersAsync()
{
    return await _context.Orders.ToListAsync();
}
```

**2. Use Span<T> and Memory<T>:**
```csharp
// Reduce allocations for string/array operations
public void ProcessData(ReadOnlySpan<byte> data)
{
    // Zero-allocation processing
}
```

**3. Object Pooling:**
```csharp
var pool = ArrayPool<byte>.Shared;
var buffer = pool.Rent(size);
try
{
    // Use buffer
}
finally
{
    pool.Return(buffer);
}
```

**4. Response Compression:**
```csharp
services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<GzipCompressionProvider>();
});
```

**5. Database Optimization:**
```csharp
// Use AsNoTracking for read-only queries
var products = await _context.Products
    .AsNoTracking()
    .Where(p => p.IsActive)
    .ToListAsync();

// Use compiled queries for repeated queries
private static readonly Func<AppDbContext, int, Task<User>> GetUserById =
    EF.CompileAsyncQuery((AppDbContext context, int id) =>
        context.Users.FirstOrDefault(u => u.Id == id));
```

**6. Caching:**
- Memory cache for frequently accessed data
- Distributed cache for multi-server scenarios
- Response caching for API responses

**7. Lazy Initialization:**
```csharp
private readonly Lazy<ExpensiveService> _service =
    new Lazy<ExpensiveService>(() => new ExpensiveService());
```

**Q20: Explain how authentication and authorization work in ASP.NET Core.**

**A:**

**Authentication:** Verifying who the user is.

**Authorization:** Verifying what the user can access.

```csharp
// Startup configuration
public void ConfigureServices(IServiceCollection services)
{
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = Configuration["Jwt:Issuer"],
                ValidAudience = Configuration["Jwt:Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(Configuration["Jwt:Key"]))
            };
        });

    services.AddAuthorization(options =>
    {
        options.AddPolicy("AdminOnly", policy =>
            policy.RequireRole("Admin"));

        options.AddPolicy("MinimumAge", policy =>
            policy.Requirements.Add(new MinimumAgeRequirement(18)));
    });
}

public void Configure(IApplicationBuilder app)
{
    app.UseAuthentication(); // First
    app.UseAuthorization();  // Second
}

// Controller usage
[Authorize] // Must be authenticated
public class AccountController : ControllerBase
{
    [Authorize(Roles = "Admin")] // Must have Admin role
    public IActionResult AdminOnly() { }

    [Authorize(Policy = "MinimumAge")] // Must meet policy
    public IActionResult RestrictedContent() { }

    [AllowAnonymous] // Override class-level Authorize
    public IActionResult Public() { }
}

// Custom authorization requirement
public class MinimumAgeRequirement : IAuthorizationRequirement
{
    public int MinimumAge { get; }

    public MinimumAgeRequirement(int minimumAge)
    {
        MinimumAge = minimumAge;
    }
}

public class MinimumAgeHandler : AuthorizationHandler<MinimumAgeRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        MinimumAgeRequirement requirement)
    {
        var ageClaim = context.User.FindFirst(c => c.Type == "age");

        if (ageClaim != null && int.TryParse(ageClaim.Value, out var age))
        {
            if (age >= requirement.MinimumAge)
            {
                context.Succeed(requirement);
            }
        }

        return Task.CompletedTask;
    }
}
```

### Advanced Topics

**Q21: What is reflection and when should you use it?**

**A:** Reflection allows inspecting and manipulating types, methods, and properties at runtime.

```csharp
// Get type information
Type userType = typeof(User);
Type orderType = order.GetType();

// Get properties
PropertyInfo[] properties = userType.GetProperties();
foreach (var prop in properties)
{
    Console.WriteLine($"{prop.Name}: {prop.PropertyType}");
}

// Get and invoke methods
MethodInfo method = userType.GetMethod("UpdateEmail");
method.Invoke(userInstance, new object[] { "new@email.com" });

// Create instances dynamically
object instance = Activator.CreateInstance(userType);

// Get attributes
var attrs = userType.GetCustomAttributes<SerializableAttribute>();
```

Use cases:
- Dependency injection containers
- Serialization/deserialization
- ORM frameworks (EF Core)
- Plugin architectures
- Testing frameworks

Avoid when:
- Performance is critical (reflection is slow)
- Type-safe compile-time checking is needed
- Simple scenarios where interfaces work

**Q22: What are records in C# and when should you use them?**

**A:** Records are reference types designed for immutable data with value-based equality.

```csharp
// Record declaration
public record Person(string FirstName, string LastName, int Age);

// Equivalent to:
public class Person
{
    public string FirstName { get; init; }
    public string LastName { get; init; }
    public int Age { get; init; }

    // Auto-generated: constructor, Equals, GetHashCode, ToString, Deconstruct
}

// Usage
var person1 = new Person("John", "Doe", 30);
var person2 = new Person("John", "Doe", 30);

Console.WriteLine(person1 == person2); // True (value equality)

// With expressions (non-destructive mutation)
var person3 = person1 with { Age = 31 };

// Record structs (C# 10)
public record struct Point(int X, int Y);
```

Use records for:
- DTOs and API models
- Immutable domain models
- Value objects
- Configuration objects

Use classes for:
- Entities with identity
- Complex mutable state
- Reference equality needed

**Q23: Explain pattern matching in C#.**

**A:**

```csharp
// Type patterns
object obj = "Hello";
if (obj is string s)
{
    Console.WriteLine(s.ToUpper());
}

// Switch expressions
string GetDiscount(Customer customer) => customer switch
{
    { IsVIP: true, Orders: > 100 } => "20% off",
    { IsVIP: true } => "10% off",
    { Orders: > 50 } => "5% off",
    _ => "No discount"
};

// Property patterns
decimal CalculateShipping(Order order) => order switch
{
    { Total: > 100 } => 0,
    { Country: "US", Weight: < 5 } => 5,
    { Country: "US" } => 10,
    { Country: "CA" } => 15,
    _ => 20
};

// Relational patterns
string GetTemperatureDescription(int temp) => temp switch
{
    < 0 => "Freezing",
    >= 0 and < 10 => "Cold",
    >= 10 and < 20 => "Cool",
    >= 20 and < 30 => "Warm",
    >= 30 => "Hot"
};

// List patterns (C# 11)
int[] numbers = { 1, 2, 3, 4 };
if (numbers is [1, 2, .., var last])
{
    Console.WriteLine($"Last: {last}");
}
```

**Q24: What is middleware vs filters vs attributes in ASP.NET Core?**

**A:**

**Middleware:**
- Runs for every request
- HTTP pipeline level
- Can short-circuit pipeline
- Example: Authentication, logging

```csharp
app.Use(async (context, next) =>
{
    Console.WriteLine("Before");
    await next();
    Console.WriteLine("After");
});
```

**Filters:**
- Runs for specific actions/controllers
- MVC/API level
- Different types: Authorization, Action, Result, Exception
- Example: Validation, action logging

```csharp
public class LogActionFilter : IActionFilter
{
    public void OnActionExecuting(ActionExecutingContext context)
    {
        // Before action
    }

    public void OnActionExecuted(ActionExecutedContext context)
    {
        // After action
    }
}
```

**Attributes:**
- Metadata markers
- Can trigger filters
- Example: [Authorize], [HttpGet]

```csharp
[ServiceFilter(typeof(LogActionFilter))]
[Authorize(Roles = "Admin")]
public IActionResult AdminAction()
{
}
```

Order of execution:
1. Middleware
2. Authorization filters
3. Action filters
4. Action method
5. Result filters
6. Exception filters (if exception)

**Q25: How do you implement background tasks in .NET?**

**A:**

**1. IHostedService:**
```csharp
public class EmailQueueService : IHostedService, IDisposable
{
    private Timer _timer;

    public Task StartAsync(CancellationToken cancellationToken)
    {
        _timer = new Timer(ProcessQueue, null, TimeSpan.Zero, TimeSpan.FromMinutes(5));
        return Task.CompletedTask;
    }

    private void ProcessQueue(object state)
    {
        // Process email queue
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        _timer?.Change(Timeout.Infinite, 0);
        return Task.CompletedTask;
    }

    public void Dispose()
    {
        _timer?.Dispose();
    }
}

// Register
services.AddHostedService<EmailQueueService>();
```

**2. BackgroundService (Simplified):**
```csharp
public class DataSyncService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // Sync data
            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
        }
    }
}
```

**3. Hangfire (Advanced):**
```csharp
// Fire and forget
BackgroundJob.Enqueue(() => Console.WriteLine("Fire and forget"));

// Delayed
BackgroundJob.Schedule(() => Console.WriteLine("Delayed"), TimeSpan.FromHours(1));

// Recurring
RecurringJob.AddOrUpdate("jobId", () => ProcessOrders(), Cron.Daily);
```

---

## System Design Mini-Questions

### Question 1: Design a logging system
**Key points to discuss:**
- Log levels (Debug, Info, Warning, Error, Critical)
- Structured logging with Serilog/NLog
- Log sinks: File, Database, Azure Application Insights
- Async logging for performance
- Log rotation and retention policies
- Correlation IDs for request tracing

### Question 2: Design a file upload system
**Key points to discuss:**
- Chunk-based uploads for large files
- Validation (size, type, content)
- Virus scanning
- Storage: Blob storage vs Database
- Progress tracking
- Resume capability
- CDN for serving files

### Question 3: Design a notification system
**Key points to discuss:**
- Notification types: Email, SMS, Push, In-app
- Queue-based processing (Azure Service Bus)
- Template management
- User preferences
- Retry logic for failures
- Delivery tracking
- Rate limiting

---

## Coding Problem-Solving Approach (Non-DSA)

### Framework: UCCEE Method

**1. UNDERSTAND the Problem**
- Read the problem twice
- Identify inputs and outputs
- Ask clarifying questions
- Understand constraints

Example questions:
- "What's the expected input format?"
- "Should I handle null inputs?"
- "What's the expected behavior for edge cases?"
- "Are there performance requirements?"

**2. CLARIFY Requirements**
- Functional requirements
- Non-functional requirements (performance, security)
- Edge cases and error handling

**3. COMMUNICATE Your Approach**
- Explain your solution before coding
- Discuss trade-offs
- Mention alternatives

**4. EXECUTE with Quality Code**
- Write clean, readable code
- Use meaningful variable names
- Follow SOLID principles
- Add comments for complex logic

**5. EVALUATE and Test**
- Walk through your code
- Test with sample inputs
- Consider edge cases
- Discuss improvements

### Common Coding Scenarios

**Scenario 1: Implement a rate limiter**

```csharp
public class RateLimiter
{
    private readonly Dictionary<string, Queue<DateTime>> _requests = new();
    private readonly int _maxRequests;
    private readonly TimeSpan _timeWindow;

    public RateLimiter(int maxRequests, TimeSpan timeWindow)
    {
        _maxRequests = maxRequests;
        _timeWindow = timeWindow;
    }

    public bool AllowRequest(string userId)
    {
        lock (_requests)
        {
            if (!_requests.ContainsKey(userId))
            {
                _requests[userId] = new Queue<DateTime>();
            }

            var userRequests = _requests[userId];
            var cutoffTime = DateTime.UtcNow - _timeWindow;

            // Remove old requests
            while (userRequests.Count > 0 && userRequests.Peek() < cutoffTime)
            {
                userRequests.Dequeue();
            }

            if (userRequests.Count < _maxRequests)
            {
                userRequests.Enqueue(DateTime.UtcNow);
                return true;
            }

            return false;
        }
    }
}

// Usage
var limiter = new RateLimiter(maxRequests: 10, timeWindow: TimeSpan.FromMinutes(1));
if (limiter.AllowRequest(userId))
{
    // Process request
}
else
{
    // Return 429 Too Many Requests
}
```

**Scenario 2: Implement a simple retry mechanism**

```csharp
public class RetryHelper
{
    public static async Task<T> RetryAsync<T>(
        Func<Task<T>> operation,
        int maxRetries = 3,
        int delayMilliseconds = 1000)
    {
        for (int i = 0; i < maxRetries; i++)
        {
            try
            {
                return await operation();
            }
            catch (Exception ex) when (i < maxRetries - 1)
            {
                await Task.Delay(delayMilliseconds * (i + 1)); // Exponential backoff
            }
        }

        // Last attempt without catching
        return await operation();
    }
}

// Usage
var result = await RetryHelper.RetryAsync(
    async () => await httpClient.GetAsync(url),
    maxRetries: 3,
    delayMilliseconds: 500
);
```

**Scenario 3: Implement a simple in-memory cache with expiration**

```csharp
public class SimpleCache<TKey, TValue>
{
    private class CacheItem
    {
        public TValue Value { get; set; }
        public DateTime ExpiresAt { get; set; }
    }

    private readonly Dictionary<TKey, CacheItem> _cache = new();
    private readonly ReaderWriterLockSlim _lock = new();

    public void Set(TKey key, TValue value, TimeSpan expiration)
    {
        _lock.EnterWriteLock();
        try
        {
            _cache[key] = new CacheItem
            {
                Value = value,
                ExpiresAt = DateTime.UtcNow.Add(expiration)
            };
        }
        finally
        {
            _lock.ExitWriteLock();
        }
    }

    public bool TryGet(TKey key, out TValue value)
    {
        _lock.EnterReadLock();
        try
        {
            if (_cache.TryGetValue(key, out var item))
            {
                if (DateTime.UtcNow < item.ExpiresAt)
                {
                    value = item.Value;
                    return true;
                }
                else
                {
                    // Expired - upgrade to write lock and remove
                    _lock.ExitReadLock();
                    _lock.EnterWriteLock();
                    try
                    {
                        _cache.Remove(key);
                    }
                    finally
                    {
                        _lock.ExitWriteLock();
                        _lock.EnterReadLock();
                    }
                }
            }

            value = default;
            return false;
        }
        finally
        {
            _lock.ExitReadLock();
        }
    }
}
```

---

## How to Think Aloud During Interviews

### Why Think Aloud?
- Shows your problem-solving process
- Helps interviewer guide you if stuck
- Demonstrates communication skills
- Reveals how you approach problems

### What to Say

**1. Problem Understanding:**
"Let me make sure I understand the problem correctly. We need to... Is that correct?"

**2. Approach Planning:**
"I'm thinking of using a dictionary to track... because it provides O(1) lookup time."

**3. Trade-off Discussion:**
"I could use approach A which is simpler but less scalable, or approach B which handles edge cases better. Given the requirements, I'll go with B."

**4. Edge Cases:**
"I should handle null inputs, empty collections, and duplicate values."

**5. While Coding:**
"I'm creating a helper method here to keep the code clean and reusable."

**6. Stuck Moments:**
"I'm considering two options here. Let me think through the pros and cons..."

### What NOT to Say
- "This is easy" (sounds arrogant)
- "I don't know" (without trying)
- Long silences (communicate your thinking)
- "I should have studied more" (stay positive)

---

## Asking Clarifying Questions

### Technical Questions to Ask

**Before Coding:**
- "What are the expected input types and ranges?"
- "Should I handle null or invalid inputs?"
- "Are there any performance constraints?"
- "Should I optimize for time or space complexity?"
- "Can I use built-in libraries or should I implement from scratch?"

**For APIs/Services:**
- "What's the expected request/response format?"
- "Should I implement error handling?"
- "What authentication mechanism should I use?"
- "Should this be synchronous or asynchronous?"

**For Database/EF Core:**
- "Should I consider query performance?"
- "Should I use eager or lazy loading?"
- "Do we need to handle concurrency conflicts?"

**For Architecture:**
- "What are the scalability requirements?"
- "Should I consider distributed systems?"
- "What's the expected load/traffic?"

### Domain-Specific Questions
- "What happens if a payment fails?"
- "Should duplicate orders be prevented?"
- "What's the business rule for refunds?"

---

## Time Management During Technical Rounds

### 60-Minute Interview Breakdown

**Minutes 0-5: Introduction**
- Brief introduction
- Understand interview structure
- Set expectations

**Minutes 5-10: Problem Understanding**
- Read/listen to problem
- Ask clarifying questions
- Confirm understanding

**Minutes 10-15: Approach Discussion**
- Explain your approach
- Discuss alternatives
- Get feedback before coding

**Minutes 15-40: Implementation**
- Write code
- Think aloud
- Keep track of time

**Minutes 40-50: Testing & Refinement**
- Walk through code
- Test with examples
- Handle edge cases
- Discuss optimizations

**Minutes 50-55: Questions & Discussion**
- Answer interviewer questions
- Discuss improvements
- Alternative approaches

**Minutes 55-60: Your Questions**
- Ask about team, tech stack
- Show interest

### Time Management Tips

1. **Don't Get Stuck on Perfection**
   - Get a working solution first
   - Optimize later if time permits

2. **Skip Non-Critical Parts**
   - Focus on core logic
   - Mention what you'd add: "In production, I'd add validation here"

3. **Use Pseudo-code First**
   - For complex problems, outline logic
   - Convert to code after approval

4. **Watch for Hints**
   - Interviewer might guide you
   - Don't ignore suggestions

---

## Mock Interview Scenarios

### Scenario 1: Build a Product API

**Requirements:**
Create a REST API for managing products with CRUD operations.

**Expected Discussion:**
- Controller design
- DTOs vs Entity models
- Validation using FluentValidation
- Repository pattern
- Error handling
- Async operations

**Sample Implementation:**
```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetAll()
    {
        var products = await _productService.GetAllAsync();
        return Ok(products);
    }

    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProductDto>> GetById(int id)
    {
        var product = await _productService.GetByIdAsync(id);

        if (product == null)
            return NotFound();

        return Ok(product);
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ProductDto>> Create([FromBody] CreateProductDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var product = await _productService.CreateAsync(dto);

        return CreatedAtAction(nameof(GetById), new { id = product.Id }, product);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateProductDto dto)
    {
        if (id != dto.Id)
            return BadRequest("ID mismatch");

        var success = await _productService.UpdateAsync(dto);

        if (!success)
            return NotFound();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(int id)
    {
        var success = await _productService.DeleteAsync(id);

        if (!success)
            return NotFound();

        return NoContent();
    }
}
```

### Scenario 2: Implement Email Queue Processing

**Requirements:**
Design a system to send emails asynchronously without blocking requests.

**Expected Discussion:**
- Queue mechanism (Azure Queue/Service Bus)
- Background service
- Error handling and retries
- Monitoring and logging

**Sample Implementation:**
```csharp
public interface IEmailQueue
{
    Task EnqueueAsync(EmailMessage message);
}

public class EmailQueueService : IEmailQueue
{
    private readonly IQueueClient _queueClient;

    public async Task EnqueueAsync(EmailMessage message)
    {
        var json = JsonSerializer.Serialize(message);
        await _queueClient.SendMessageAsync(json);
    }
}

public class EmailProcessorService : BackgroundService
{
    private readonly IEmailQueue _queue;
    private readonly IEmailSender _emailSender;
    private readonly ILogger<EmailProcessorService> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                var message = await _queue.DequeueAsync();

                if (message != null)
                {
                    await ProcessEmailAsync(message);
                }
                else
                {
                    await Task.Delay(1000, stoppingToken); // Wait before checking again
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing email queue");
            }
        }
    }

    private async Task ProcessEmailAsync(EmailMessage message)
    {
        var maxRetries = 3;
        var attempt = 0;

        while (attempt < maxRetries)
        {
            try
            {
                await _emailSender.SendAsync(message);
                _logger.LogInformation($"Email sent successfully: {message.To}");
                return;
            }
            catch (Exception ex)
            {
                attempt++;
                _logger.LogWarning(ex, $"Failed to send email (attempt {attempt}/{maxRetries})");

                if (attempt < maxRetries)
                {
                    await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, attempt))); // Exponential backoff
                }
                else
                {
                    // Move to dead letter queue or log for manual intervention
                    _logger.LogError(ex, "Email failed after all retries");
                }
            }
        }
    }
}
```

### Scenario 3: Implement JWT Authentication

**Requirements:**
Add JWT authentication to an API.

**Expected Discussion:**
- Token generation
- Token validation
- Refresh tokens
- Security best practices

**Sample Implementation:**
```csharp
public class AuthService
{
    private readonly IConfiguration _configuration;
    private readonly IUserRepository _userRepository;

    public async Task<TokenResponse> AuthenticateAsync(LoginRequest request)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email);

        if (user == null || !VerifyPassword(request.Password, user.PasswordHash))
        {
            throw new UnauthorizedException("Invalid credentials");
        }

        var token = GenerateToken(user);
        var refreshToken = GenerateRefreshToken();

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(7);
        await _userRepository.UpdateAsync(user);

        return new TokenResponse
        {
            AccessToken = token,
            RefreshToken = refreshToken,
            ExpiresIn = 3600
        };
    }

    private string GenerateToken(User user)
    {
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));

        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role)
        };

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private string GenerateRefreshToken()
    {
        var randomNumber = new byte[32];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        return Convert.ToBase64String(randomNumber);
    }

    private bool VerifyPassword(string password, string hash)
    {
        // Use BCrypt or similar
        return BCrypt.Net.BCrypt.Verify(password, hash);
    }
}
```

---

## Red Flags to Avoid

### Technical Red Flags

1. **Not Asking Questions**
   - Shows lack of attention to requirements
   - Jumping to code without understanding

2. **Writing Messy Code**
   - Inconsistent naming conventions
   - No structure or organization
   - Hard-to-read logic

3. **Ignoring Edge Cases**
   - Not handling null/empty inputs
   - Not considering error scenarios

4. **Over-Engineering**
   - Adding unnecessary complexity
   - Using advanced patterns for simple problems

5. **Not Testing Your Code**
   - Not walking through with examples
   - Assuming code works without verification

6. **Poor Communication**
   - Long silences
   - Not explaining your thinking
   - Getting defensive about feedback

7. **Not Knowing Your Resume**
   - Can't explain technologies you listed
   - Can't discuss projects in detail

8. **Hardcoding Values**
   - Magic numbers without explanation
   - Not using configuration/constants

### Behavioral Red Flags

1. **Blaming Others**
   - "My team didn't follow best practices"
   - "The previous developer wrote bad code"

2. **Not Taking Ownership**
   - "That wasn't my responsibility"
   - "I was just following orders"

3. **Negativity**
   - Criticizing previous employers
   - Complaining about technologies

4. **Lack of Curiosity**
   - Not asking questions about the role
   - Not showing interest in their tech stack

5. **Arrogance**
   - "This is too easy"
   - Dismissing interviewer's suggestions

---

## Confidence-Building Techniques

### Before the Interview

**1. Preparation Ritual (Day Before)**
- Review key concepts (30 minutes)
- Practice 2-3 coding problems
- Prepare your setup (laptop, internet, quiet space)
- Get good sleep (7-8 hours)

**2. Morning Routine (Interview Day)**
- Light breakfast
- Review 1-2 quick problems
- Physical exercise (15 minutes) - reduces anxiety
- Positive visualization

**3. Technical Warm-up (1 hour before)**
- Solve one easy problem
- Review common patterns
- Test your setup (video, audio, internet)

### During the Interview

**1. Power Poses**
- Stand tall before the interview
- Confident body language
- Smile genuinely

**2. Breathing Technique (If Nervous)**
- 4-7-8 breathing: Inhale 4 seconds, hold 7 seconds, exhale 8 seconds
- Do this 2-3 times if feeling anxious

**3. Reframe Nervousness**
- "I'm excited" instead of "I'm nervous"
- Both feelings are similar, but positive framing helps

**4. Focus on What You Know**
- Start with what you're confident about
- Build momentum with small wins

**5. It's a Conversation, Not an Interrogation**
- View interviewer as a collaborator
- They want you to succeed
- Ask for hints if stuck

### Positive Self-Talk

**Replace negative thoughts:**

Negative: "I don't know this"
Positive: "Let me work through this logically"

Negative: "I'm going to fail"
Positive: "I'm prepared and capable"

Negative: "This is too hard"
Positive: "This is a chance to show my problem-solving skills"

Negative: "I should have studied more"
Positive: "I'll use what I know to tackle this"

### Recovery from Mistakes

**If you make a mistake:**
1. Acknowledge it: "I see an issue with my approach"
2. Correct it: "Let me fix that"
3. Learn from it: "That's a good catch"
4. Move forward: Don't dwell on it

**Remember:**
- Interviewers expect some mistakes
- They want to see how you handle them
- Recovery shows resilience

### Post-Interview (Regardless of Outcome)

**1. Reflect Positively**
- What did you do well?
- What would you improve?
- Learning opportunity, not judgment of worth

**2. Avoid Over-Analysis**
- Don't replay every moment
- You did your best with the information you had

**3. Next Steps**
- Send thank-you email within 24 hours
- Continue preparing for other opportunities
- Stay positive and confident

---

## Final Checklist

### Technical Skills
- [ ] Can explain C# fundamentals clearly
- [ ] Understand async/await thoroughly
- [ ] Know EF Core patterns (eager, lazy, explicit loading)
- [ ] Can discuss SOLID principles with examples
- [ ] Understand dependency injection
- [ ] Can implement basic authentication/authorization
- [ ] Know caching strategies
- [ ] Understand middleware pipeline

### Problem-Solving
- [ ] Practice UCCEE method
- [ ] Can think aloud effectively
- [ ] Ask clarifying questions
- [ ] Handle edge cases
- [ ] Test solutions thoroughly

### Communication
- [ ] Can explain technical concepts to non-technical people
- [ ] Active listening skills
- [ ] Confident but humble
- [ ] Open to feedback

### Mindset
- [ ] View interview as learning opportunity
- [ ] Stay positive and enthusiastic
- [ ] Show genuine interest in role
- [ ] Prepared with questions about team/tech

---

## Remember

**You are qualified.** You have the skills and experience. The interview is just one conversation on one day. It doesn't define your worth as a developer.

**Be authentic.** Don't pretend to know what you don't. It's okay to say "I'm not familiar with that specific technology, but here's how I'd approach learning it."

**Every interview makes you better.** Win or lose, you're gaining valuable experience.

**The right opportunity will come.** Keep preparing, stay confident, and trust the process.

Good luck!
