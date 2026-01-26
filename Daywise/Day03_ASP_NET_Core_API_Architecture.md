# Day 3 — ASP.NET Core & API Architecture (DEEP)

## Overview
Master the end-to-end request flow in ASP.NET Core and understand where different types of logic belong. Critical for architect/lead interviews.

---

## 1. Clean Architecture Layers & Flow

### The Layers

```
┌─────────────────────────────────────┐
│     Presentation (API/UI)           │  ← Controllers, ViewModels
├─────────────────────────────────────┤
│     Application Layer               │  ← Use Cases, DTOs, Validators
├─────────────────────────────────────┤
│     Domain Layer                    │  ← Entities, Value Objects, Domain Logic
├─────────────────────────────────────┤
│     Infrastructure Layer            │  ← DbContext, External Services
└─────────────────────────────────────┘
```

**Architect Decision Guide:**
- **Use Clean Architecture when**: Complex domain logic, long-lived project, multiple UIs/channels
- **Skip Clean Architecture when**: Simple CRUD, rapid prototyping, small team unfamiliar with DDD
- **Cost**: More files, initial complexity, learning curve
- **Benefit**: Testability, maintainability, technology independence
- **Common mistake**: Over-layering - don't create layers that just pass data through

### Implementation Example

```csharp
// Domain Layer - Core business logic
namespace Domain.Entities
{
    public class Order
    {
        public int Id { get; private set; }
        public decimal Total { get; private set; }
        public OrderStatus Status { get; private set; }
        private List<OrderItem> _items = new();
        public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();

        public void AddItem(Product product, int quantity)
        {
            if (quantity <= 0)
                throw new DomainException("Quantity must be positive");

            if (Status != OrderStatus.Draft)
                throw new DomainException("Cannot modify submitted order");

            _items.Add(new OrderItem(product, quantity));
            RecalculateTotal();
        }

        private void RecalculateTotal()
        {
            Total = _items.Sum(i => i.Price * i.Quantity);
        }

        public void Submit()
        {
            if (!_items.Any())
                throw new DomainException("Cannot submit empty order");

            Status = OrderStatus.Submitted;
        }
    }
}

// Application Layer - Use Cases/Application Services
namespace Application.Orders
{
    public class CreateOrderCommand
    {
        public int CustomerId { get; set; }
        public List<OrderItemDto> Items { get; set; }
    }

    public class CreateOrderHandler
    {
        private readonly IOrderRepository _orderRepository;
        private readonly IProductRepository _productRepository;
        private readonly IUnitOfWork _unitOfWork;

        public async Task<int> Handle(CreateOrderCommand command)
        {
            var order = new Order(command.CustomerId);

            foreach (var item in command.Items)
            {
                var product = await _productRepository.GetByIdAsync(item.ProductId);
                if (product == null)
                    throw new NotFoundException($"Product {item.ProductId} not found");

                order.AddItem(product, item.Quantity);
            }

            await _orderRepository.AddAsync(order);
            await _unitOfWork.CommitAsync();

            return order.Id;
        }
    }
}

// Infrastructure Layer - Data access
namespace Infrastructure.Persistence
{
    public class OrderRepository : IOrderRepository
    {
        private readonly AppDbContext _context;

        public async Task<Order> GetByIdAsync(int id)
        {
            return await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);
        }

        public async Task AddAsync(Order order)
        {
            await _context.Orders.AddAsync(order);
        }
    }
}

// Presentation Layer - API Controllers
namespace API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly CreateOrderHandler _createOrderHandler;

        [HttpPost]
        public async Task<ActionResult<int>> CreateOrder(CreateOrderCommand command)
        {
            var orderId = await _createOrderHandler.Handle(command);
            return CreatedAtAction(nameof(GetOrder), new { id = orderId }, orderId);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<OrderDto>> GetOrder(int id)
        {
            // Implementation
        }
    }
}
```

### Dependency Flow
- **Domain** → No dependencies (pure business logic)
- **Application** → Depends on Domain
- **Infrastructure** → Depends on Application & Domain (implements interfaces)
- **Presentation** → Depends on Application (uses handlers/services)

---

## 2. Kestrel → Middleware → Filters → Controllers

### Request Pipeline Flow

```
HTTP Request
    ↓
[Kestrel Web Server]
    ↓
[Middleware 1] ───→ (can short-circuit)
    ↓
[Middleware 2]
    ↓
[Middleware N]
    ↓
[Routing Middleware]
    ↓
[Endpoint Middleware]
    ↓
[Authorization Filter]
    ↓
[Action Filter - OnActionExecuting]
    ↓
[Controller Action]
    ↓
[Action Filter - OnActionExecuted]
    ↓
[Result Filter]
    ↓
[Exception Filter] (if exception)
    ↓
HTTP Response
```

### Kestrel Configuration
```csharp
// Program.cs
builder.WebHost.ConfigureKestrel(options =>
{
    // Maximum request body size
    options.Limits.MaxRequestBodySize = 10 * 1024 * 1024; // 10MB

    // Connection limits
    options.Limits.MaxConcurrentConnections = 100;
    options.Limits.MaxConcurrentUpgradedConnections = 100;

    // Timeouts
    options.Limits.KeepAliveTimeout = TimeSpan.FromMinutes(2);
    options.Limits.RequestHeadersTimeout = TimeSpan.FromSeconds(30);
});
```

---

## 3. Middleware vs Filters

### When to Use Middleware
```csharp
// Use middleware for:
// - Cross-cutting concerns affecting ALL requests
// - Operating before routing (when you don't know the endpoint)
// - Low-level HTTP concerns

// Example: Request logging middleware
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path;
        var method = context.Request.Method;

        _logger.LogInformation("Request: {Method} {Path}", method, path);

        await _next(context); // Call next middleware

        _logger.LogInformation("Response: {StatusCode}", context.Response.StatusCode);
    }
}

// Registration
app.UseMiddleware<RequestLoggingMiddleware>();
```

### When to Use Filters
```csharp
// Use filters for:
// - MVC/API-specific concerns
// - Operating on controller actions
// - Need access to MVC context (model, action parameters)

// Example: Action filter for validation
public class ValidateModelAttribute : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        if (!context.ModelState.IsValid)
        {
            context.Result = new BadRequestObjectResult(context.ModelState);
        }
    }
}

// Usage
[ValidateModel]
[HttpPost]
public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
{
    // ModelState already validated
}
```

### Order of Execution

```csharp
// Startup/Program.cs
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Middleware - executes in ORDER
app.UseHttpsRedirection();      // 1
app.UseStaticFiles();            // 2
app.UseRouting();                // 3 - Determines endpoint
app.UseAuthentication();         // 4
app.UseAuthorization();          // 5
app.UseMiddleware<CustomMiddleware>(); // 6
app.MapControllers();            // 7 - Endpoint middleware

// Filters - execute in TYPE order:
// 1. Authorization Filters
// 2. Resource Filters
// 3. Action Filters
// 4. Exception Filters
// 5. Result Filters
```

### Comparison Table
| Feature | Middleware | Filters |
|---------|------------|---------|
| Scope | Entire pipeline | MVC actions only |
| Registration | Pipeline order | Global/Controller/Action |
| Access to | HttpContext | ActionContext, ModelState |
| Can short-circuit | Yes | Yes |
| DI | Constructor only | Constructor + Method |
| Best for | HTTP-level concerns | MVC-specific logic |

---

## 4. Model Binding & Validation

### Model Binding Sources

```csharp
[HttpPost("orders/{id}/items")]
public async Task<IActionResult> AddOrderItem(
    [FromRoute] int id,              // From URL path
    [FromQuery] bool notify,         // From query string ?notify=true
    [FromBody] AddItemDto dto,       // From request body (JSON)
    [FromHeader(Name = "X-Api-Key")] string apiKey, // From header
    [FromServices] IOrderService orderService)      // From DI container
{
    await orderService.AddItem(id, dto, notify);
    return Ok();
}

// Complex binding
public class OrderQuery
{
    [FromQuery(Name = "status")]
    public OrderStatus? Status { get; set; }

    [FromQuery(Name = "from")]
    public DateTime? DateFrom { get; set; }

    [FromQuery(Name = "to")]
    public DateTime? DateTo { get; set; }

    [FromQuery(Name = "page")]
    public int Page { get; set; } = 1;

    [FromQuery(Name = "size")]
    public int PageSize { get; set; } = 10;
}

[HttpGet]
public async Task<IActionResult> GetOrders([FromQuery] OrderQuery query)
{
    // Automatically binds query string to object
}
```

### Validation

```csharp
// Data Annotations
public class CreateOrderDto
{
    [Required(ErrorMessage = "Customer ID is required")]
    public int CustomerId { get; set; }

    [Required]
    [MinLength(1, ErrorMessage = "Order must have at least one item")]
    public List<OrderItemDto> Items { get; set; }
}

public class OrderItemDto
{
    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "Product ID must be positive")]
    public int ProductId { get; set; }

    [Required]
    [Range(1, 1000, ErrorMessage = "Quantity must be between 1 and 1000")]
    public int Quantity { get; set; }
}

// FluentValidation (Better for complex rules)
public class CreateOrderDtoValidator : AbstractValidator<CreateOrderDto>
{
    public CreateOrderDtoValidator()
    {
        RuleFor(x => x.CustomerId)
            .GreaterThan(0)
            .WithMessage("Customer ID must be positive");

        RuleFor(x => x.Items)
            .NotEmpty()
            .WithMessage("Order must have at least one item");

        RuleForEach(x => x.Items)
            .SetValidator(new OrderItemDtoValidator());

        RuleFor(x => x.Items)
            .Must(items => items.Select(i => i.ProductId).Distinct().Count() == items.Count)
            .WithMessage("Duplicate products in order");
    }
}

// Registration
builder.Services.AddFluentValidation(fv =>
    fv.RegisterValidatorsFromAssemblyContaining<CreateOrderDtoValidator>());

// Automatic validation
[HttpPost]
public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
{
    // FluentValidation runs automatically
    // ModelState.IsValid checked by ValidateModel filter
}
```

### Custom Model Binder
```csharp
// For complex binding scenarios
public class OrderStatusBinder : IModelBinder
{
    public Task BindModelAsync(ModelBindingContext bindingContext)
    {
        var value = bindingContext.ValueProvider.GetValue("status").FirstValue;

        if (string.IsNullOrEmpty(value))
        {
            return Task.CompletedTask;
        }

        if (Enum.TryParse<OrderStatus>(value, true, out var status))
        {
            bindingContext.Result = ModelBindingResult.Success(status);
        }
        else
        {
            bindingContext.ModelState.AddModelError(
                bindingContext.ModelName,
                $"Invalid order status: {value}");
        }

        return Task.CompletedTask;
    }
}

// Usage
public async Task<IActionResult> GetOrders(
    [ModelBinder(typeof(OrderStatusBinder))] OrderStatus status)
{
    // Custom binding logic applied
}
```

---

## 5. Global Error Handling

### Exception Handler Middleware (Recommended)

```csharp
// Custom middleware
public class GlobalExceptionHandlerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionHandlerMiddleware> _logger;

    public GlobalExceptionHandlerMiddleware(
        RequestDelegate next,
        ILogger<GlobalExceptionHandlerMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";

        var response = exception switch
        {
            NotFoundException notFoundEx => new
            {
                statusCode = StatusCodes.Status404NotFound,
                message = notFoundEx.Message
            },
            ValidationException validationEx => new
            {
                statusCode = StatusCodes.Status400BadRequest,
                message = "Validation failed",
                errors = validationEx.Errors
            },
            UnauthorizedAccessException => new
            {
                statusCode = StatusCodes.Status401Unauthorized,
                message = "Unauthorized access"
            },
            _ => new
            {
                statusCode = StatusCodes.Status500InternalServerError,
                message = "An error occurred processing your request"
            }
        };

        context.Response.StatusCode = response.statusCode;
        await context.Response.WriteAsJsonAsync(response);
    }
}

// Register FIRST in pipeline
app.UseMiddleware<GlobalExceptionHandlerMiddleware>();
```

### Built-in Exception Handler
```csharp
// Development
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    // Production - custom error page
    app.UseExceptionHandler("/error");

    // Or use Problem Details
    app.UseExceptionHandler(errorApp =>
    {
        errorApp.Run(async context =>
        {
            var exceptionHandlerFeature = context.Features.Get<IExceptionHandlerFeature>();
            var exception = exceptionHandlerFeature?.Error;

            var problemDetails = new ProblemDetails
            {
                Status = StatusCodes.Status500InternalServerError,
                Title = "An error occurred",
                Detail = exception?.Message
            };

            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await context.Response.WriteAsJsonAsync(problemDetails);
        });
    });
}
```

### Exception Filter (MVC-specific)
```csharp
public class ApiExceptionFilter : IExceptionFilter
{
    private readonly ILogger<ApiExceptionFilter> _logger;

    public ApiExceptionFilter(ILogger<ApiExceptionFilter> logger)
    {
        _logger = logger;
    }

    public void OnException(ExceptionContext context)
    {
        _logger.LogError(context.Exception, "API exception occurred");

        var result = context.Exception switch
        {
            NotFoundException ex => new NotFoundObjectResult(new { error = ex.Message }),
            ValidationException ex => new BadRequestObjectResult(new { errors = ex.Errors }),
            _ => new ObjectResult(new { error = "Internal server error" })
            {
                StatusCode = StatusCodes.Status500InternalServerError
            }
        };

        context.Result = result;
        context.ExceptionHandled = true;
    }
}

// Register globally
builder.Services.AddControllers(options =>
{
    options.Filters.Add<ApiExceptionFilter>();
});
```

---

## 6. API Versioning Strategies

### URL Versioning
```csharp
// Most common and visible

// Nuget: Asp.Versioning.Mvc
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
});

[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiVersion("1.0")]
public class OrdersV1Controller : ControllerBase
{
    [HttpGet("{id}")]
    public async Task<OrderDto> GetOrder(int id)
    {
        // V1 implementation
    }
}

[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiVersion("2.0")]
public class OrdersV2Controller : ControllerBase
{
    [HttpGet("{id}")]
    public async Task<OrderDtoV2> GetOrder(int id)
    {
        // V2 implementation with additional fields
    }
}

// URLs: /api/v1/orders/123 and /api/v2/orders/123
```

### Header Versioning
```csharp
builder.Services.AddApiVersioning(options =>
{
    options.ApiVersionReader = new HeaderApiVersionReader("X-API-Version");
});

[ApiController]
[Route("api/[controller]")]
[ApiVersion("1.0")]
[ApiVersion("2.0")]
public class OrdersController : ControllerBase
{
    [HttpGet("{id}"), MapToApiVersion("1.0")]
    public async Task<OrderDto> GetOrderV1(int id)
    {
        // V1 implementation
    }

    [HttpGet("{id}"), MapToApiVersion("2.0")]
    public async Task<OrderDtoV2> GetOrderV2(int id)
    {
        // V2 implementation
    }
}

// Request: GET /api/orders/123
// Header: X-API-Version: 2.0
```

### Query String Versioning
```csharp
builder.Services.AddApiVersioning(options =>
{
    options.ApiVersionReader = new QueryStringApiVersionReader("api-version");
});

// Request: GET /api/orders/123?api-version=2.0
```

---

## 7. Idempotent APIs

### Concept
Same request multiple times produces same result without side effects.

```csharp
// NON-idempotent (BAD)
[HttpPost("orders/{orderId}/items")]
public async Task<IActionResult> AddItem(int orderId, AddItemDto dto)
{
    // Problem: Calling twice adds item twice!
    var order = await _repository.GetByIdAsync(orderId);
    order.AddItem(dto.ProductId, dto.Quantity);
    await _repository.SaveAsync();

    return Ok();
}

// IDEMPOTENT (GOOD) - Using idempotency key
[HttpPost("orders/{orderId}/items")]
public async Task<IActionResult> AddItemIdempotent(
    int orderId,
    AddItemDto dto,
    [FromHeader(Name = "Idempotency-Key")] string idempotencyKey)
{
    if (string.IsNullOrEmpty(idempotencyKey))
        return BadRequest("Idempotency-Key header required");

    // Check if we already processed this request
    var existing = await _idempotencyStore.GetAsync(idempotencyKey);
    if (existing != null)
    {
        // Return cached response
        return Ok(existing);
    }

    var order = await _repository.GetByIdAsync(orderId);
    order.AddItem(dto.ProductId, dto.Quantity);
    await _repository.SaveAsync();

    var result = new { orderId, itemAdded = true };

    // Cache the result
    await _idempotencyStore.SetAsync(idempotencyKey, result, TimeSpan.FromHours(24));

    return Ok(result);
}

// PUT is naturally idempotent
[HttpPut("orders/{id}")]
public async Task<IActionResult> UpdateOrder(int id, UpdateOrderDto dto)
{
    // Calling multiple times with same data produces same state
    var order = await _repository.GetByIdAsync(id);
    if (order == null)
        return NotFound();

    order.Update(dto);
    await _repository.SaveAsync();

    return Ok();
}

// DELETE is naturally idempotent
[HttpDelete("orders/{id}")]
public async Task<IActionResult> DeleteOrder(int id)
{
    // First call deletes, subsequent calls return same result
    var order = await _repository.GetByIdAsync(id);
    if (order == null)
        return NotFound(); // Same response whether already deleted or not

    await _repository.DeleteAsync(order);
    return NoContent();
}
```

---

## 8. Background Services

### IHostedService Implementation
```csharp
public class OrderProcessingService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<OrderProcessingService> _logger;

    public OrderProcessingService(
        IServiceProvider serviceProvider,
        ILogger<OrderProcessingService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Order Processing Service started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var orderService = scope.ServiceProvider.GetRequiredService<IOrderService>();

                await orderService.ProcessPendingOrdersAsync();

                await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing orders");
                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
            }
        }

        _logger.LogInformation("Order Processing Service stopped");
    }
}

// Registration
builder.Services.AddHostedService<OrderProcessingService>();
```

### Periodic Timer (Better for .NET 6+)
```csharp
public class MetricsCollectionService : BackgroundService
{
    private readonly ILogger<MetricsCollectionService> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(5));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            await CollectMetricsAsync();
        }
    }

    private async Task CollectMetricsAsync()
    {
        // Collect and publish metrics
    }
}
```

---

## 9. Graceful Shutdown

### Implementation
```csharp
public class DataSyncService : BackgroundService
{
    private readonly ILogger<DataSyncService> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await SyncDataAsync(stoppingToken);
            await Task.Delay(TimeSpan.FromMinutes(10), stoppingToken);
        }
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Data Sync Service stopping - completing current sync");

        // Complete current work gracefully
        await base.StopAsync(cancellationToken);

        _logger.LogInformation("Data Sync Service stopped");
    }

    private async Task SyncDataAsync(CancellationToken cancellationToken)
    {
        // Check cancellation token periodically
        if (cancellationToken.IsCancellationRequested)
        {
            _logger.LogInformation("Sync cancelled");
            return;
        }

        // Do work...
    }
}

// Configuration
builder.Services.Configure<HostOptions>(options =>
{
    options.ShutdownTimeout = TimeSpan.FromSeconds(30); // Wait time for graceful shutdown
});
```

---

## 10. Logging & Correlation IDs

### Correlation ID Middleware
```csharp
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string CorrelationIdHeader = "X-Correlation-ID";

    public CorrelationIdMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.Request.Headers[CorrelationIdHeader].FirstOrDefault()
                            ?? Guid.NewGuid().ToString();

        context.Items["CorrelationId"] = correlationId;
        context.Response.Headers.Add(CorrelationIdHeader, correlationId);

        using (LogContext.PushProperty("CorrelationId", correlationId))
        {
            await _next(context);
        }
    }
}

// Structured logging with Serilog
builder.Host.UseSerilog((context, configuration) =>
{
    configuration
        .Enrich.FromLogContext()
        .Enrich.WithProperty("Application", "OrderService")
        .WriteTo.Console(outputTemplate:
            "[{Timestamp:HH:mm:ss} {Level:u3}] {CorrelationId} {Message:lj}{NewLine}{Exception}")
        .WriteTo.ApplicationInsights(TelemetryConfiguration.Active, TelemetryConverter.Traces);
});

// Usage in controller
[HttpGet("{id}")]
public async Task<IActionResult> GetOrder(int id)
{
    _logger.LogInformation("Fetching order {OrderId}", id);
    // Log automatically includes CorrelationId
}
```

---

## 11. Health Checks

### Implementation
```csharp
// Custom health check
public class DatabaseHealthCheck : IHealthCheck
{
    private readonly AppDbContext _context;

    public DatabaseHealthCheck(AppDbContext context)
    {
        _context = context;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _context.Database.ExecuteSqlRawAsync(
                "SELECT 1", cancellationToken);

            return HealthCheckResult.Healthy("Database is reachable");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy(
                "Database is unreachable", ex);
        }
    }
}

// Registration
builder.Services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database")
    .AddUrlGroup(new Uri("https://api.external-service.com/health"), "external-api")
    .AddRedis(configuration["Redis:ConnectionString"], "redis");

// Endpoints
app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";

        var result = JsonSerializer.Serialize(new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration
            })
        });

        await context.Response.WriteAsync(result);
    }
});

// Liveness (is app running?) and Readiness (can it handle traffic?)
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false // No checks, just alive
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
```

---

## Interview Questions

### Q: Explain the complete request flow in ASP.NET Core
**Answer**: Request → Kestrel → Middleware chain (order matters) → Routing → Endpoint selection → Authorization Filter → Resource Filter → Model Binding → Action Filter (before) → Controller Action → Action Filter (after) → Result Filter → Response → Middleware chain (reverse) → Kestrel → Client. Exceptions caught by Exception Filters or Exception Middleware.

### Q: When would you use middleware vs filters?
**Answer**: Middleware for cross-cutting HTTP concerns affecting all requests (logging, CORS, authentication). Filters for MVC-specific logic tied to actions (validation, authorization on specific endpoints, result transformation). Middleware runs before routing; filters run as part of MVC pipeline.

### Q: How do you make an API idempotent?
**Answer**: Use idempotency keys (client-generated unique IDs) in headers. Store processed requests with their results. If same key received, return cached result instead of re-processing. PUT and DELETE are naturally idempotent. POST requires explicit handling.

---

## Where Logic Belongs / Does NOT Belong

### Controllers Should:
- Accept requests
- Validate input (basic)
- Call application services
- Return responses
- Handle HTTP concerns

### Controllers Should NOT:
- Contain business logic
- Directly access database
- Have complex logic
- Know about domain entities

### Application Layer Should:
- Orchestrate use cases
- Handle transactions
- Coordinate domain objects
- Transform DTOs to domain objects

### Domain Layer Should:
- Contain business rules
- Protect invariants
- Be framework-agnostic
- Have no dependencies on outer layers

---

## Deliverables
- ✔ Master end-to-end request flow explanation
- ✔ Understand Clean Architecture layers
- ✔ Know where different logic belongs
