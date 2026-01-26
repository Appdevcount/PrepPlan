# Day 16: Senior-Level Coding Interview Prep

## Overview
Senior-level coding interviews focus less on algorithmic puzzles and more on clean code, design patterns, refactoring skills, and real-world problem-solving. This guide covers principles, patterns, and practices that demonstrate senior engineering maturity.

---

## Clean Code Principles with C# Examples

**Senior Engineer Expectations:**
- Code that communicates intent clearly
- Designs that balance simplicity with extensibility
- Understanding trade-offs (not just "best practices")
- Knowing when to refactor vs when to leave code alone

### 1. Meaningful Naming

**Poor:**
```csharp
public class Manager
{
    public void Process(List<Data> d)
    {
        foreach (var item in d)
        {
            var x = item.Value * 1.1;
            Save(x);
        }
    }
}
```

**Good:**
```csharp
public class OrderProcessor
{
    private const decimal SalesTaxRate = 0.10m;

    public void ProcessOrders(List<Order> orders)
    {
        foreach (var order in orders)
        {
            var totalWithTax = CalculateTotalWithTax(order.Subtotal);
            _repository.SaveOrder(order.Id, totalWithTax);
        }
    }

    private decimal CalculateTotalWithTax(decimal subtotal)
    {
        return subtotal * (1 + SalesTaxRate);
    }
}
```

**Why it's better:**
- Class name describes what it does (processes orders, not vague "Manager")
- Method parameters have clear types and names
- Constants are named, not magic numbers
- Variable names describe intent (totalWithTax vs. x)

---

### 2. Single Responsibility Principle (SRP)

**Poor - Multiple Responsibilities:**
```csharp
public class UserService
{
    public void CreateUser(User user)
    {
        // Validation
        if (string.IsNullOrEmpty(user.Email))
            throw new Exception("Email required");

        if (!user.Email.Contains("@"))
            throw new Exception("Invalid email");

        // Database
        using var connection = new SqlConnection(_connectionString);
        connection.Open();
        var command = new SqlCommand(
            "INSERT INTO Users (Email, Name) VALUES (@Email, @Name)",
            connection);
        command.Parameters.AddWithValue("@Email", user.Email);
        command.Parameters.AddWithValue("@Name", user.Name);
        command.ExecuteNonQuery();

        // Email notification
        var smtpClient = new SmtpClient("smtp.example.com");
        smtpClient.Send("welcome@example.com", user.Email,
            "Welcome!", "Welcome to our platform!");

        // Logging
        File.AppendAllText("log.txt", $"User created: {user.Email}");
    }
}
```

**Good - Separated Responsibilities:**
```csharp
// Validation responsibility
public class UserValidator
{
    public ValidationResult Validate(User user)
    {
        var errors = new List<string>();

        if (string.IsNullOrEmpty(user.Email))
            errors.Add("Email is required");

        if (!IsValidEmail(user.Email))
            errors.Add("Email format is invalid");

        return new ValidationResult
        {
            IsValid = !errors.Any(),
            Errors = errors
        };
    }

    private bool IsValidEmail(string email)
    {
        return !string.IsNullOrEmpty(email) &&
               email.Contains("@") &&
               email.Contains(".");
    }
}

// Data access responsibility
public interface IUserRepository
{
    Task CreateAsync(User user);
}

public class SqlUserRepository : IUserRepository
{
    private readonly string _connectionString;

    public async Task CreateAsync(User user)
    {
        await using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        await using var command = new SqlCommand(
            "INSERT INTO Users (Email, Name) VALUES (@Email, @Name)",
            connection);

        command.Parameters.AddWithValue("@Email", user.Email);
        command.Parameters.AddWithValue("@Name", user.Name);

        await command.ExecuteNonQueryAsync();
    }
}

// Notification responsibility
public interface INotificationService
{
    Task SendWelcomeEmailAsync(string email);
}

public class EmailNotificationService : INotificationService
{
    private readonly IEmailClient _emailClient;

    public async Task SendWelcomeEmailAsync(string email)
    {
        await _emailClient.SendAsync(new EmailMessage
        {
            To = email,
            Subject = "Welcome!",
            Body = "Welcome to our platform!"
        });
    }
}

// Orchestration - single responsibility: coordinate the workflow
public class UserService
{
    private readonly UserValidator _validator;
    private readonly IUserRepository _repository;
    private readonly INotificationService _notificationService;
    private readonly ILogger<UserService> _logger;

    public UserService(
        UserValidator validator,
        IUserRepository repository,
        INotificationService notificationService,
        ILogger<UserService> logger)
    {
        _validator = validator;
        _repository = repository;
        _notificationService = notificationService;
        _logger = logger;
    }

    public async Task<Result> CreateUserAsync(User user)
    {
        // Validate
        var validationResult = _validator.Validate(user);
        if (!validationResult.IsValid)
            return Result.Failure(validationResult.Errors);

        try
        {
            // Save
            await _repository.CreateAsync(user);

            // Notify
            await _notificationService.SendWelcomeEmailAsync(user.Email);

            // Log
            _logger.LogInformation("User created: {Email}", user.Email);

            return Result.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create user: {Email}", user.Email);
            return Result.Failure("Failed to create user");
        }
    }
}
```

**Benefits:**
- Each class has one reason to change
- Easy to test in isolation
- Easy to replace implementations (e.g., switch from SQL to Cosmos DB)
- Clear separation of concerns

---

### 3. Open/Closed Principle (OCP)

**Poor - Open for Modification:**
```csharp
public class DiscountCalculator
{
    public decimal Calculate(Order order, string customerType)
    {
        decimal discount = 0;

        if (customerType == "Regular")
            discount = order.Total * 0.05m;
        else if (customerType == "Premium")
            discount = order.Total * 0.10m;
        else if (customerType == "VIP")
            discount = order.Total * 0.20m;

        return discount;
    }
}
```

**Good - Open for Extension, Closed for Modification:**
```csharp
// Strategy pattern - open for extension
public interface IDiscountStrategy
{
    decimal Calculate(Order order);
}

public class RegularCustomerDiscount : IDiscountStrategy
{
    public decimal Calculate(Order order) => order.Total * 0.05m;
}

public class PremiumCustomerDiscount : IDiscountStrategy
{
    public decimal Calculate(Order order) => order.Total * 0.10m;
}

public class VipCustomerDiscount : IDiscountStrategy
{
    public decimal Calculate(Order order) => order.Total * 0.20m;
}

// New discount type? Just add a new class, don't modify existing code
public class SeasonalDiscount : IDiscountStrategy
{
    private readonly decimal _seasonalRate;

    public SeasonalDiscount(decimal seasonalRate)
    {
        _seasonalRate = seasonalRate;
    }

    public decimal Calculate(Order order) => order.Total * _seasonalRate;
}

public class DiscountCalculator
{
    private readonly IDiscountStrategy _strategy;

    public DiscountCalculator(IDiscountStrategy strategy)
    {
        _strategy = strategy;
    }

    public decimal Calculate(Order order)
    {
        return _strategy.Calculate(order);
    }
}

// Usage
var calculator = new DiscountCalculator(new VipCustomerDiscount());
var discount = calculator.Calculate(order);
```

---

### 4. Dependency Inversion Principle (DIP)

**Poor - High-level module depends on low-level module:**
```csharp
public class OrderService
{
    private readonly SqlOrderRepository _repository;

    public OrderService()
    {
        _repository = new SqlOrderRepository(); // Tight coupling
    }

    public void ProcessOrder(Order order)
    {
        _repository.Save(order);
    }
}
```

**Good - Both depend on abstraction:**
```csharp
// Abstraction
public interface IOrderRepository
{
    Task SaveAsync(Order order);
    Task<Order> GetByIdAsync(int orderId);
}

// Low-level module
public class SqlOrderRepository : IOrderRepository
{
    private readonly string _connectionString;

    public SqlOrderRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task SaveAsync(Order order)
    {
        // SQL implementation
    }

    public async Task<Order> GetByIdAsync(int orderId)
    {
        // SQL implementation
    }
}

// High-level module depends on abstraction
public class OrderService
{
    private readonly IOrderRepository _repository;

    public OrderService(IOrderRepository repository)
    {
        _repository = repository; // Dependency injection
    }

    public async Task ProcessOrderAsync(Order order)
    {
        await _repository.SaveAsync(order);
    }
}

// Easy to test with mock
public class OrderServiceTests
{
    [Test]
    public async Task ProcessOrder_ShouldSaveToRepository()
    {
        // Arrange
        var mockRepository = new Mock<IOrderRepository>();
        var service = new OrderService(mockRepository.Object);
        var order = new Order { Id = 1, Total = 100 };

        // Act
        await service.ProcessOrderAsync(order);

        // Assert
        mockRepository.Verify(r => r.SaveAsync(order), Times.Once);
    }
}
```

---

## Refactoring Legacy Code Strategies

### Strategy 1: Characterization Tests First

**Scenario:** You inherit untested legacy code.

**Legacy Code:**
```csharp
public class PriceCalculator
{
    public double Calculate(int quantity, double price, string code)
    {
        double result = quantity * price;

        if (code == "SUMMER")
            result = result * 0.9;
        else if (code == "WINTER")
            result = result * 0.85;
        else if (code == "SPRING")
            result = result * 0.95;

        if (quantity > 100)
            result = result * 0.95;

        if (result > 1000)
            result = result * 0.98;

        return result;
    }
}
```

**Step 1: Write Characterization Tests (capture current behavior)**
```csharp
public class PriceCalculatorTests
{
    private readonly PriceCalculator _calculator;

    public PriceCalculatorTests()
    {
        _calculator = new PriceCalculator();
    }

    [Test]
    public void Calculate_NoCode_ReturnsQuantityTimesPrice()
    {
        var result = _calculator.Calculate(10, 5.0, "");
        Assert.That(result, Is.EqualTo(50.0));
    }

    [Test]
    public void Calculate_SummerCode_Applies10PercentDiscount()
    {
        var result = _calculator.Calculate(10, 10.0, "SUMMER");
        Assert.That(result, Is.EqualTo(90.0));
    }

    [Test]
    public void Calculate_QuantityOver100_AppliesVolumeDiscount()
    {
        var result = _calculator.Calculate(101, 10.0, "");
        Assert.That(result, Is.EqualTo(959.5)); // 1010 * 0.95
    }

    [Test]
    public void Calculate_TotalOver1000_AppliesLargeOrderDiscount()
    {
        var result = _calculator.Calculate(101, 10.0, "");
        Assert.That(result, Is.EqualTo(959.5 * 0.98));
    }

    [Test]
    public void Calculate_MultipleDiscounts_AppliesAll()
    {
        var result = _calculator.Calculate(101, 10.0, "SUMMER");
        // 101 * 10 = 1010
        // Summer: 1010 * 0.9 = 909
        // Volume: 909 * 0.95 = 863.55
        // Large order: 863.55 * 0.98 = 846.279
        Assert.That(result, Is.EqualTo(846.279).Within(0.01));
    }
}
```

**Step 2: Refactor with Test Safety Net**
```csharp
public class PriceCalculator
{
    private readonly IReadOnlyDictionary<string, decimal> _seasonalDiscounts =
        new Dictionary<string, decimal>
        {
            { "SUMMER", 0.10m },
            { "WINTER", 0.15m },
            { "SPRING", 0.05m }
        };

    private const decimal VolumeDiscountThreshold = 100;
    private const decimal VolumeDiscountRate = 0.05m;
    private const decimal LargeOrderThreshold = 1000;
    private const decimal LargeOrderDiscountRate = 0.02m;

    public decimal Calculate(int quantity, decimal price, string seasonalCode)
    {
        var subtotal = quantity * price;
        var afterSeasonalDiscount = ApplySeasonalDiscount(subtotal, seasonalCode);
        var afterVolumeDiscount = ApplyVolumeDiscount(afterSeasonalDiscount, quantity);
        var finalTotal = ApplyLargeOrderDiscount(afterVolumeDiscount);

        return finalTotal;
    }

    private decimal ApplySeasonalDiscount(decimal amount, string code)
    {
        if (string.IsNullOrEmpty(code) || !_seasonalDiscounts.ContainsKey(code))
            return amount;

        var discountRate = _seasonalDiscounts[code];
        return amount * (1 - discountRate);
    }

    private decimal ApplyVolumeDiscount(decimal amount, int quantity)
    {
        if (quantity <= VolumeDiscountThreshold)
            return amount;

        return amount * (1 - VolumeDiscountRate);
    }

    private decimal ApplyLargeOrderDiscount(decimal amount)
    {
        if (amount <= LargeOrderThreshold)
            return amount;

        return amount * (1 - LargeOrderDiscountRate);
    }
}
```

**All tests still pass, but code is now:**
- Readable (clear method names)
- Maintainable (easy to add new discount types)
- Testable (each method can be tested independently)
- Self-documenting (constants explain magic numbers)

---

### Strategy 2: Strangler Fig Pattern

**Scenario:** Large legacy class that's too risky to refactor all at once.

**Approach:**
```csharp
// Legacy code (don't touch initially)
public class LegacyOrderProcessor
{
    public void ProcessOrder(Order order)
    {
        // 500 lines of complex logic
    }
}

// Step 1: Create new interface and adapter
public interface IOrderProcessor
{
    Task ProcessAsync(Order order);
}

public class LegacyOrderProcessorAdapter : IOrderProcessor
{
    private readonly LegacyOrderProcessor _legacy;

    public LegacyOrderProcessorAdapter()
    {
        _legacy = new LegacyOrderProcessor();
    }

    public Task ProcessAsync(Order order)
    {
        _legacy.ProcessOrder(order); // Delegate to legacy
        return Task.CompletedTask;
    }
}

// Step 2: Gradually extract logic to new implementation
public class ModernOrderProcessor : IOrderProcessor
{
    private readonly IOrderValidator _validator;
    private readonly IPaymentService _paymentService;
    private readonly IInventoryService _inventoryService;
    private readonly LegacyOrderProcessor _legacyFallback; // Safety net

    public async Task ProcessAsync(Order order)
    {
        try
        {
            // New implementation (gradually add more logic here)
            var validationResult = await _validator.ValidateAsync(order);
            if (!validationResult.IsValid)
                throw new ValidationException(validationResult.Errors);

            await _paymentService.ChargeAsync(order);
            await _inventoryService.ReserveAsync(order);

            // More logic...
        }
        catch (NotImplementedException)
        {
            // Fall back to legacy for unimplemented features
            _legacyFallback.ProcessOrder(order);
        }
    }
}

// Step 3: Feature flag to toggle between implementations
public class OrderProcessorFactory
{
    private readonly IConfiguration _config;

    public IOrderProcessor Create()
    {
        var useModernProcessor = _config.GetValue<bool>("UseModernOrderProcessor");

        return useModernProcessor
            ? new ModernOrderProcessor()
            : new LegacyOrderProcessorAdapter();
    }
}
```

**Benefits:**
- Gradual migration (low risk)
- Can toggle back if issues arise
- Each piece can be tested independently
- Eventually, remove legacy code entirely

---

## Exception-Safe Code Patterns

### Pattern 1: Using Statements for Resource Management

**Poor - Manual Cleanup:**
```csharp
public async Task<List<Order>> GetOrdersAsync()
{
    var connection = new SqlConnection(_connectionString);
    connection.Open();

    var command = new SqlCommand("SELECT * FROM Orders", connection);
    var reader = command.ExecuteReader();

    var orders = new List<Order>();
    while (reader.Read())
    {
        orders.Add(MapToOrder(reader));
    }

    reader.Close();
    command.Dispose();
    connection.Close(); // What if an exception occurs before this?

    return orders;
}
```

**Good - Using Statement (Guaranteed Cleanup):**
```csharp
public async Task<List<Order>> GetOrdersAsync()
{
    await using var connection = new SqlConnection(_connectionString);
    await connection.OpenAsync();

    await using var command = new SqlCommand("SELECT * FROM Orders", connection);
    await using var reader = await command.ExecuteReaderAsync();

    var orders = new List<Order>();
    while (await reader.ReadAsync())
    {
        orders.Add(MapToOrder(reader));
    }

    return orders;
    // connection, command, and reader are automatically disposed
}
```

---

### Pattern 2: Try-Catch with Specific Exceptions

**Poor - Catch All Exceptions:**
```csharp
public async Task<Order> GetOrderAsync(int orderId)
{
    try
    {
        return await _repository.GetByIdAsync(orderId);
    }
    catch (Exception ex) // Too broad
    {
        _logger.LogError(ex, "Error getting order");
        return null; // Swallows important errors
    }
}
```

**Good - Catch Specific Exceptions:**
```csharp
public async Task<Order> GetOrderAsync(int orderId)
{
    try
    {
        return await _repository.GetByIdAsync(orderId);
    }
    catch (SqlException ex) when (ex.Number == 2) // Timeout
    {
        _logger.LogWarning(ex, "Database timeout getting order {OrderId}", orderId);
        throw new TimeoutException($"Database timeout for order {orderId}", ex);
    }
    catch (SqlException ex) when (ex.Number == -1) // Connection failure
    {
        _logger.LogError(ex, "Database connection failed");
        throw new DataAccessException("Database unavailable", ex);
    }
    catch (InvalidOperationException ex)
    {
        _logger.LogError(ex, "Order {OrderId} not found", orderId);
        throw new OrderNotFoundException(orderId, ex);
    }
    // Let other exceptions propagate
}
```

---

### Pattern 3: Result Pattern (Avoid Exceptions for Flow Control)

**Poor - Exceptions for Expected Scenarios:**
```csharp
public Order CreateOrder(OrderRequest request)
{
    if (request.Items.Count == 0)
        throw new InvalidOperationException("Order must have items");

    if (request.Total < 0)
        throw new ArgumentException("Total cannot be negative");

    if (!_inventory.HasStock(request.Items))
        throw new OutOfStockException();

    return _repository.Save(new Order(request));
}
```

**Good - Result Pattern:**
```csharp
public class Result<T>
{
    public bool IsSuccess { get; }
    public T Value { get; }
    public string Error { get; }

    private Result(bool isSuccess, T value, string error)
    {
        IsSuccess = isSuccess;
        Value = value;
        Error = error;
    }

    public static Result<T> Success(T value) => new(true, value, null);
    public static Result<T> Failure(string error) => new(false, default, error);
}

public async Task<Result<Order>> CreateOrderAsync(OrderRequest request)
{
    // Validation
    if (request.Items.Count == 0)
        return Result<Order>.Failure("Order must have items");

    if (request.Total < 0)
        return Result<Order>.Failure("Total cannot be negative");

    // Business logic
    var stockCheck = await _inventory.CheckStockAsync(request.Items);
    if (!stockCheck.IsAvailable)
        return Result<Order>.Failure($"Out of stock: {stockCheck.MissingItems}");

    // Success path
    var order = new Order(request);
    await _repository.SaveAsync(order);

    return Result<Order>.Success(order);
}

// Usage
var result = await _orderService.CreateOrderAsync(request);
if (result.IsSuccess)
{
    return Ok(result.Value);
}
else
{
    return BadRequest(result.Error);
}
```

**Benefits:**
- Exceptions reserved for truly exceptional cases
- Expected failures are part of the return type
- Easier to test
- More explicit control flow

---

## Performance-Aware Coding Practices

### 1. Avoid N+1 Query Problem

**Poor - N+1 Queries:**
```csharp
public async Task<List<OrderDto>> GetOrdersWithCustomersAsync()
{
    var orders = await _context.Orders.ToListAsync(); // 1 query

    var result = new List<OrderDto>();
    foreach (var order in orders) // N queries
    {
        var customer = await _context.Customers
            .FirstOrDefaultAsync(c => c.Id == order.CustomerId);

        result.Add(new OrderDto
        {
            OrderId = order.Id,
            CustomerName = customer.Name
        });
    }

    return result;
}
```

**Good - Eager Loading:**
```csharp
public async Task<List<OrderDto>> GetOrdersWithCustomersAsync()
{
    var orders = await _context.Orders
        .Include(o => o.Customer) // Single query with JOIN
        .Select(o => new OrderDto
        {
            OrderId = o.Id,
            CustomerName = o.Customer.Name
        })
        .ToListAsync();

    return orders;
}
```

---

### 2. Use Async/Await Properly

**Poor - Blocking Async Calls:**
```csharp
public List<Order> GetOrders()
{
    var orders = _repository.GetOrdersAsync().Result; // Deadlock risk!
    return orders;
}
```

**Good - Async All the Way:**
```csharp
public async Task<List<Order>> GetOrdersAsync()
{
    var orders = await _repository.GetOrdersAsync();
    return orders;
}

// Or if you truly need sync, use GetAwaiter().GetResult()
public List<Order> GetOrdersSync()
{
    return _repository.GetOrdersAsync().GetAwaiter().GetResult();
}
```

---

### 3. Minimize Allocations

**Poor - Unnecessary Allocations:**
```csharp
public string BuildQuery(List<int> ids)
{
    var query = "SELECT * FROM Orders WHERE Id IN (";
    foreach (var id in ids)
    {
        query += id + ","; // Creates new string each iteration!
    }
    query = query.TrimEnd(',') + ")";
    return query;
}
```

**Good - StringBuilder for String Concatenation:**
```csharp
public string BuildQuery(List<int> ids)
{
    var sb = new StringBuilder("SELECT * FROM Orders WHERE Id IN (");
    for (int i = 0; i < ids.Count; i++)
    {
        if (i > 0) sb.Append(',');
        sb.Append(ids[i]);
    }
    sb.Append(')');
    return sb.ToString();
}

// Even better - use parameterized queries
public string BuildQuery(List<int> ids)
{
    return $"SELECT * FROM Orders WHERE Id IN ({string.Join(",", ids)})";
}
```

---

### 4. Caching Strategies

**Poor - No Caching:**
```csharp
public async Task<List<Category>> GetCategoriesAsync()
{
    return await _context.Categories.ToListAsync(); // Database hit every time
}
```

**Good - In-Memory Cache:**
```csharp
public class CategoryService
{
    private readonly IMemoryCache _cache;
    private readonly ApplicationDbContext _context;
    private const string CacheKey = "categories";

    public async Task<List<Category>> GetCategoriesAsync()
    {
        if (_cache.TryGetValue(CacheKey, out List<Category> categories))
        {
            return categories;
        }

        categories = await _context.Categories.ToListAsync();

        _cache.Set(CacheKey, categories, TimeSpan.FromHours(1));

        return categories;
    }

    public async Task InvalidateCacheAsync()
    {
        _cache.Remove(CacheKey);
    }
}
```

---

## Testable Design Patterns

### Pattern 1: Dependency Injection

**Hard to Test:**
```csharp
public class OrderService
{
    public void ProcessOrder(Order order)
    {
        var repository = new SqlOrderRepository(); // Hard dependency
        var emailService = new SmtpEmailService(); // Can't mock

        repository.Save(order);
        emailService.SendOrderConfirmation(order);
    }
}
```

**Easy to Test:**
```csharp
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly IEmailService _emailService;

    public OrderService(IOrderRepository repository, IEmailService emailService)
    {
        _repository = repository;
        _emailService = emailService;
    }

    public async Task ProcessOrderAsync(Order order)
    {
        await _repository.SaveAsync(order);
        await _emailService.SendOrderConfirmationAsync(order);
    }
}

// Test
[Test]
public async Task ProcessOrder_ShouldSaveAndSendEmail()
{
    // Arrange
    var mockRepo = new Mock<IOrderRepository>();
    var mockEmail = new Mock<IEmailService>();
    var service = new OrderService(mockRepo.Object, mockEmail.Object);
    var order = new Order { Id = 1 };

    // Act
    await service.ProcessOrderAsync(order);

    // Assert
    mockRepo.Verify(r => r.SaveAsync(order), Times.Once);
    mockEmail.Verify(e => e.SendOrderConfirmationAsync(order), Times.Once);
}
```

---

### Pattern 2: Factory Pattern for Complex Object Creation

**Hard to Test:**
```csharp
public class ReportGenerator
{
    public Report GenerateReport(ReportType type)
    {
        if (type == ReportType.Sales)
        {
            var db = new SqlConnection("...");
            var report = new SalesReport(db);
            return report.Generate();
        }
        else if (type == ReportType.Inventory)
        {
            var db = new SqlConnection("...");
            var api = new HttpClient();
            var report = new InventoryReport(db, api);
            return report.Generate();
        }
        // ...
    }
}
```

**Easy to Test with Factory:**
```csharp
public interface IReport
{
    Task<Report> GenerateAsync();
}

public interface IReportFactory
{
    IReport Create(ReportType type);
}

public class ReportFactory : IReportFactory
{
    private readonly IServiceProvider _serviceProvider;

    public ReportFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public IReport Create(ReportType type)
    {
        return type switch
        {
            ReportType.Sales => _serviceProvider.GetRequiredService<SalesReport>(),
            ReportType.Inventory => _serviceProvider.GetRequiredService<InventoryReport>(),
            _ => throw new ArgumentException($"Unknown report type: {type}")
        };
    }
}

public class ReportGenerator
{
    private readonly IReportFactory _factory;

    public ReportGenerator(IReportFactory factory)
    {
        _factory = factory;
    }

    public async Task<Report> GenerateReportAsync(ReportType type)
    {
        var report = _factory.Create(type);
        return await report.GenerateAsync();
    }
}

// Test
[Test]
public async Task GenerateReport_SalesType_ShouldUseSalesReport()
{
    // Arrange
    var mockReport = new Mock<IReport>();
    var mockFactory = new Mock<IReportFactory>();
    mockFactory.Setup(f => f.Create(ReportType.Sales)).Returns(mockReport.Object);

    var generator = new ReportGenerator(mockFactory.Object);

    // Act
    await generator.GenerateReportAsync(ReportType.Sales);

    // Assert
    mockReport.Verify(r => r.GenerateAsync(), Times.Once);
}
```

---

## Code Review Best Practices

### What to Look For in Code Reviews

**1. Correctness:**
- Does the code do what it's supposed to do?
- Are edge cases handled?
- Are there any logic errors?

**2. Design:**
- Is the code in the right place?
- Does it follow SOLID principles?
- Is it extensible?

**3. Readability:**
- Can you understand what it does without asking?
- Are names meaningful?
- Is it overly complex?

**4. Tests:**
- Are there tests for the new code?
- Do tests cover edge cases?
- Are tests readable?

**5. Security:**
- Are inputs validated?
- Is sensitive data protected?
- Are there any SQL injection risks?

**6. Performance:**
- Are there any obvious performance issues?
- N+1 queries?
- Unnecessary allocations?

---

### How to Give Feedback

**Poor Feedback:**
```
"This is wrong."
"Why did you do it this way?"
"This is bad code."
```

**Good Feedback:**
```
"I think there's a bug here. If userId is null, this will throw a NullReferenceException.
Consider adding a null check: if (userId == null) throw new ArgumentNullException(nameof(userId));"

"This approach works, but I'm concerned about performance. This loop makes a database call
for each item, which could be slow for large lists. Have you considered using Include()
to load all the data in a single query?"

"Naming suggestion: 'Process()' is a bit generic. Would 'ValidateAndSaveOrder()' be more
descriptive?"

"Nice use of the strategy pattern here! This makes it easy to add new discount types."
```

**Framework:**
- Be specific
- Explain the "why"
- Suggest alternatives
- Praise good work

---

## Common Coding Interview Patterns (Non-DSA)

### Pattern 1: API Design

**Question:** Design a RESTful API for a blog system with posts, comments, and users.

**Answer:**
```
Resources:
GET    /api/posts              - List all posts (with pagination)
GET    /api/posts/{id}         - Get single post
POST   /api/posts              - Create post (auth required)
PUT    /api/posts/{id}         - Update post (auth + ownership required)
DELETE /api/posts/{id}         - Delete post (auth + ownership required)

GET    /api/posts/{id}/comments       - Get comments for a post
POST   /api/posts/{id}/comments       - Add comment (auth required)
DELETE /api/comments/{id}              - Delete comment (auth + ownership required)

GET    /api/users/{id}         - Get user profile
PUT    /api/users/{id}         - Update profile (auth + ownership required)

Request/Response Examples:

POST /api/posts
Request:
{
  "title": "My First Post",
  "content": "Hello world!",
  "tags": ["introduction", "blog"]
}

Response (201 Created):
{
  "id": 123,
  "title": "My First Post",
  "content": "Hello world!",
  "authorId": 456,
  "createdAt": "2026-01-19T10:00:00Z",
  "tags": ["introduction", "blog"],
  "_links": {
    "self": "/api/posts/123",
    "author": "/api/users/456",
    "comments": "/api/posts/123/comments"
  }
}

Error Response (400 Bad Request):
{
  "error": "ValidationError",
  "message": "Title is required",
  "details": [
    {
      "field": "title",
      "message": "Title cannot be empty"
    }
  ]
}
```

**Key Points to Mention:**
- RESTful conventions (nouns, not verbs)
- Proper HTTP methods (GET, POST, PUT, DELETE)
- Status codes (200, 201, 400, 404, 500)
- Authentication/authorization
- Pagination for lists
- HATEOAS links (optional, but impressive)
- Error handling format

---

### Pattern 2: Database Schema Design

**Question:** Design a database schema for an e-commerce system with products, orders, and customers.

**Answer:**
```sql
-- Customers
CREATE TABLE Customers (
    Id INT PRIMARY KEY IDENTITY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(500) NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    INDEX IX_Customers_Email (Email)
);

-- Products
CREATE TABLE Products (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(18,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    CategoryId INT,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    INDEX IX_Products_CategoryId (CategoryId)
);

-- Orders
CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY,
    CustomerId INT NOT NULL,
    OrderDate DATETIME2 DEFAULT GETUTCDATE(),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    TotalAmount DECIMAL(18,2) NOT NULL,
    ShippingAddress NVARCHAR(500),
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
    INDEX IX_Orders_CustomerId (CustomerId),
    INDEX IX_Orders_OrderDate (OrderDate)
);

-- OrderItems (many-to-many relationship)
CREATE TABLE OrderItems (
    Id INT PRIMARY KEY IDENTITY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL, -- Capture price at time of order
    FOREIGN KEY (OrderId) REFERENCES Orders(Id) ON DELETE CASCADE,
    FOREIGN KEY (ProductId) REFERENCES Products(Id),
    INDEX IX_OrderItems_OrderId (OrderId),
    INDEX IX_OrderItems_ProductId (ProductId)
);
```

**Key Points to Mention:**
- Primary keys (IDENTITY)
- Foreign keys for relationships
- Indexes on foreign keys and commonly queried fields
- Appropriate data types (DECIMAL for money, DATETIME2 for dates)
- Capturing historical data (UnitPrice in OrderItems)
- Cascade deletes where appropriate
- Constraints (NOT NULL, UNIQUE)

---

### Pattern 3: Multithreading/Concurrency

**Question:** Implement a thread-safe counter.

**Poor:**
```csharp
public class Counter
{
    private int _count = 0;

    public void Increment()
    {
        _count++; // Not thread-safe!
    }

    public int GetCount()
    {
        return _count;
    }
}
```

**Good - Using Lock:**
```csharp
public class Counter
{
    private int _count = 0;
    private readonly object _lock = new object();

    public void Increment()
    {
        lock (_lock)
        {
            _count++;
        }
    }

    public int GetCount()
    {
        lock (_lock)
        {
            return _count;
        }
    }
}
```

**Better - Using Interlocked:**
```csharp
public class Counter
{
    private int _count = 0;

    public void Increment()
    {
        Interlocked.Increment(ref _count); // Atomic operation, faster than lock
    }

    public int GetCount()
    {
        return Interlocked.CompareExchange(ref _count, 0, 0); // Thread-safe read
    }
}
```

---

## Live Coding Tips for Senior Roles

### 1. Talk Through Your Thought Process

**Bad:**
*Silently starts coding*

**Good:**
"Okay, so I need to design a URL shortener. Let me start by clarifying requirements:
- How many URLs will we shorten? This affects whether I need a database or can use in-memory.
- Do we need analytics (click tracking)?
- What's the expected lifetime of short URLs?

Assuming we need persistence and millions of URLs, I'll use:
- A database to store mappings (long URL → short code)
- A hash function or base62 encoding to generate short codes
- Redis for caching frequently accessed URLs

Let me start with the data model..."
```

---

### 2. Write Clean Code from the Start

**Bad:**
```csharp
public string s(string u) {
    var r = ""; // What is r?
    for (int i=0;i<6;i++) r+=chars[rand.Next(chars.Length)];
    db.Insert(r,u);
    return r;
}
```

**Good:**
```csharp
public string ShortenUrl(string longUrl)
{
    const int ShortCodeLength = 6;

    var shortCode = GenerateShortCode(ShortCodeLength);

    _repository.Save(shortCode, longUrl);

    return $"{_baseUrl}/{shortCode}";
}

private string GenerateShortCode(int length)
{
    const string Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var code = new char[length];

    for (int i = 0; i < length; i++)
    {
        code[i] = Characters[_random.Next(Characters.Length)];
    }

    return new string(code);
}
```

---

### 3. Handle Edge Cases

**Don't forget to discuss:**
```csharp
public string ShortenUrl(string longUrl)
{
    // Edge case: Null or empty URL
    if (string.IsNullOrWhiteSpace(longUrl))
        throw new ArgumentException("URL cannot be null or empty", nameof(longUrl));

    // Edge case: Invalid URL format
    if (!Uri.TryCreate(longUrl, UriKind.Absolute, out _))
        throw new ArgumentException("Invalid URL format", nameof(longUrl));

    // Edge case: URL already shortened (check if it exists)
    var existingCode = _repository.FindByLongUrl(longUrl);
    if (existingCode != null)
        return $"{_baseUrl}/{existingCode}";

    // Edge case: Collision in short code generation
    string shortCode;
    int attempts = 0;
    const int MaxAttempts = 10;

    do
    {
        shortCode = GenerateShortCode(6);
        attempts++;
    } while (_repository.Exists(shortCode) && attempts < MaxAttempts);

    if (attempts >= MaxAttempts)
        throw new InvalidOperationException("Failed to generate unique short code");

    _repository.Save(shortCode, longUrl);

    return $"{_baseUrl}/{shortCode}";
}
```

---

### 4. Write Tests as You Go (If Time Permits)

```csharp
[Test]
public void ShortenUrl_ValidUrl_ReturnsShortUrl()
{
    // Arrange
    var service = new UrlShortenerService(_mockRepository.Object);
    var longUrl = "https://www.example.com/very/long/url";

    // Act
    var result = service.ShortenUrl(longUrl);

    // Assert
    Assert.That(result, Does.StartWith("https://short.ly/"));
    Assert.That(result.Length, Is.EqualTo("https://short.ly/".Length + 6));
}

[Test]
public void ShortenUrl_NullUrl_ThrowsArgumentException()
{
    var service = new UrlShortenerService(_mockRepository.Object);

    Assert.Throws<ArgumentException>(() => service.ShortenUrl(null));
}

[Test]
public void ShortenUrl_ExistingUrl_ReturnsSameShortCode()
{
    // Arrange
    var service = new UrlShortenerService(_mockRepository.Object);
    var longUrl = "https://www.example.com/test";

    _mockRepository.Setup(r => r.FindByLongUrl(longUrl)).Returns("abc123");

    // Act
    var result = service.ShortenUrl(longUrl);

    // Assert
    Assert.That(result, Is.EqualTo("https://short.ly/abc123"));
    _mockRepository.Verify(r => r.Save(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
}
```

---

### 5. Discuss Trade-offs

"I'm using a random short code generator here, which is simple but has collision risk. Alternatives:
- **Base62 encoding of auto-increment ID**: Guaranteed unique, but reveals how many URLs we've shortened
- **Hash of URL + salt**: More secure, but fixed hash length might run out for billions of URLs
- **Pre-generated pool of codes**: Fast, no collisions, but requires managing the pool

For this problem, random with collision check is a good balance."

---

## Senior-Level Interview Questions to Practice

### System Design Coding Questions

1. **Design a rate limiter** (token bucket or sliding window algorithm)
2. **Implement a LRU cache** (using dictionary + doubly linked list)
3. **Design a notification system** (priority queue, background workers)
4. **Build a simple job scheduler** (cron-like syntax parsing, task execution)

### Refactoring Questions

1. "Here's a 200-line God Class. How would you refactor it?"
2. "This code has multiple responsibilities. Apply SOLID principles."
3. "This legacy code has no tests. How do you start refactoring it?"

### Architecture Questions

1. "Design the data model for a multi-tenant SaaS application"
2. "How would you handle API versioning?"
3. "Explain your approach to error handling across layers (controller → service → repository)"

---

## Summary Checklist for Senior Coding Interviews

Before the interview, ensure you can:

**Clean Code:**
- [ ] Explain SOLID principles with examples
- [ ] Write self-documenting code (meaningful names, small functions)
- [ ] Identify and refactor code smells

**Design Patterns:**
- [ ] Implement Strategy, Factory, Repository patterns
- [ ] Explain when to use each pattern
- [ ] Demonstrate dependency injection

**Testing:**
- [ ] Write unit tests with mocks
- [ ] Explain test-driven development (TDD)
- [ ] Demonstrate characterization testing for legacy code

**Performance:**
- [ ] Identify and fix N+1 query problems
- [ ] Use async/await correctly
- [ ] Explain caching strategies

**Code Review:**
- [ ] Give constructive feedback
- [ ] Identify security issues
- [ ] Suggest improvements diplomatically

**Communication:**
- [ ] Explain technical decisions to non-technical people
- [ ] Discuss trade-offs clearly
- [ ] Ask clarifying questions before coding

You've got this. Senior interviews are about demonstrating judgment, not just coding speed.
