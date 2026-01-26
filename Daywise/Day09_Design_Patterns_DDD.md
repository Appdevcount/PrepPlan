# Day 09: Design Patterns & Domain-Driven Design

## Overview
Design patterns solve common problems, but overuse creates complexity. This guide covers essential patterns, Domain-Driven Design principles, when to use them, and critically - when NOT to use them.

---

## 1. SOLID Principles with Real C# Examples

### Single Responsibility Principle (SRP)

**A class should have one, and only one, reason to change.**

**Architect's Interpretation:**
- "Reason to change" = stakeholder/actor requesting changes
- Example: OrderService changes when business logic changes, NOT when email provider changes
- **Anti-pattern**: God classes doing validation + persistence + business logic + notifications
- **Balance**: Don't create a class for every single responsibility (over-engineering)

```csharp
// BAD - Multiple responsibilities
public class UserService
{
    public void CreateUser(User user)
    {
        // Validation
        if (string.IsNullOrEmpty(user.Email))
            throw new ArgumentException("Email required");

        // Database
        using var connection = new SqlConnection(_connectionString);
        connection.Execute("INSERT INTO Users...", user);

        // Email
        var smtpClient = new SmtpClient("smtp.gmail.com");
        smtpClient.Send(new MailMessage("no-reply@app.com", user.Email, "Welcome!", "..."));

        // Logging
        File.AppendAllText("log.txt", $"User {user.Id} created");
    }
}
// Changes to email system, database, or logging all modify this class!

// GOOD - Single responsibility per class
public class UserService
{
    private readonly IUserRepository _repository;
    private readonly IEmailService _emailService;
    private readonly ILogger<UserService> _logger;

    public async Task CreateUserAsync(User user)
    {
        user.Validate(); // Validation is User's responsibility

        await _repository.SaveAsync(user);
        await _emailService.SendWelcomeEmailAsync(user.Email);
        _logger.LogInformation("User {UserId} created", user.Id);
    }
}

public class User
{
    public void Validate()
    {
        if (string.IsNullOrEmpty(Email))
            throw new ArgumentException("Email required");
    }
}
```

### Open/Closed Principle (OCP)

**Open for extension, closed for modification.**

```csharp
// BAD - Need to modify class to add new discount types
public class DiscountCalculator
{
    public decimal Calculate(Order order, string discountType)
    {
        if (discountType == "Seasonal")
            return order.Total * 0.1m;
        else if (discountType == "Loyalty")
            return order.Total * 0.15m;
        else if (discountType == "BlackFriday") // Need to modify for new type!
            return order.Total * 0.3m;
        return 0;
    }
}

// GOOD - Extend via new classes, don't modify existing
public interface IDiscountStrategy
{
    decimal Calculate(Order order);
}

public class SeasonalDiscount : IDiscountStrategy
{
    public decimal Calculate(Order order) => order.Total * 0.1m;
}

public class LoyaltyDiscount : IDiscountStrategy
{
    public decimal Calculate(Order order) => order.Total * 0.15m;
}

public class BlackFridayDiscount : IDiscountStrategy // New class, no changes to existing code
{
    public decimal Calculate(Order order) => order.Total * 0.3m;
}

public class DiscountCalculator
{
    public decimal Calculate(Order order, IDiscountStrategy strategy)
    {
        return strategy.Calculate(order);
    }
}

// Usage
var calculator = new DiscountCalculator();
var discount = calculator.Calculate(order, new BlackFridayDiscount());
```

### Liskov Substitution Principle (LSP)

**Subtypes must be substitutable for their base types.**

```csharp
// BAD - Violates LSP
public class Rectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }

    public int GetArea() => Width * Height;
}

public class Square : Rectangle
{
    public override int Width
    {
        get => base.Width;
        set => base.Width = base.Height = value; // Side effect!
    }

    public override int Height
    {
        get => base.Height;
        set => base.Width = base.Height = value; // Side effect!
    }
}

// Client code breaks!
void SetRectangleSize(Rectangle rect)
{
    rect.Width = 5;
    rect.Height = 10;
    Assert.Equal(50, rect.GetArea()); // Fails for Square! (100 instead of 50)
}

// GOOD - Separate abstractions
public abstract class Shape
{
    public abstract int GetArea();
}

public class Rectangle : Shape
{
    public int Width { get; set; }
    public int Height { get; set; }

    public override int GetArea() => Width * Height;
}

public class Square : Shape
{
    public int Size { get; set; }

    public override int GetArea() => Size * Size;
}
```

### Interface Segregation Principle (ISP)

**Clients should not depend on interfaces they don't use.**

```csharp
// BAD - Fat interface
public interface IWorker
{
    void Work();
    void Eat();
    void Sleep();
    void GetSalary();
}

public class HumanWorker : IWorker
{
    public void Work() { }
    public void Eat() { }
    public void Sleep() { }
    public void GetSalary() { }
}

public class RobotWorker : IWorker
{
    public void Work() { }
    public void Eat() => throw new NotImplementedException(); // Robots don't eat!
    public void Sleep() => throw new NotImplementedException();
    public void GetSalary() => throw new NotImplementedException();
}

// GOOD - Segregated interfaces
public interface IWorkable
{
    void Work();
}

public interface IFeedable
{
    void Eat();
}

public interface ISleepable
{
    void Sleep();
}

public interface IPayable
{
    void GetSalary();
}

public class HumanWorker : IWorkable, IFeedable, ISleepable, IPayable
{
    public void Work() { }
    public void Eat() { }
    public void Sleep() { }
    public void GetSalary() { }
}

public class RobotWorker : IWorkable
{
    public void Work() { }
    // Only implements what it needs
}
```

### Dependency Inversion Principle (DIP)

**Depend on abstractions, not concretions.**

```csharp
// BAD - High-level module depends on low-level module
public class OrderService
{
    private readonly SqlOrderRepository _repository; // Concrete dependency

    public OrderService()
    {
        _repository = new SqlOrderRepository(); // Tight coupling
    }

    public void CreateOrder(Order order)
    {
        _repository.Save(order);
    }
}

// GOOD - Both depend on abstraction
public interface IOrderRepository
{
    void Save(Order order);
}

public class SqlOrderRepository : IOrderRepository
{
    public void Save(Order order) { /* SQL implementation */ }
}

public class MongoOrderRepository : IOrderRepository
{
    public void Save(Order order) { /* MongoDB implementation */ }
}

public class OrderService
{
    private readonly IOrderRepository _repository; // Abstraction

    public OrderService(IOrderRepository repository) // Injected
    {
        _repository = repository;
    }

    public void CreateOrder(Order order)
    {
        _repository.Save(order); // Works with any implementation
    }
}
```

---

## 2. Essential Design Patterns

### Factory Pattern

**Use when**: Object creation logic is complex or varies by context.

**Decision Criteria:**
- ✅ Use: Multiple implementations selected at runtime, complex initialization
- ❌ Skip: Simple `new` with no logic, single implementation
- **Alternative**: Dependency injection often eliminates need for factories

```csharp
// Problem: Different payment methods have different initialization
var payment = paymentType switch
{
    "CreditCard" => new CreditCardPayment(apiKey, merchantId),
    "PayPal" => new PayPalPayment(clientId, secret),
    "Bitcoin" => new BitcoinPayment(walletAddress, network),
    _ => throw new ArgumentException("Unknown payment type")
};

// Solution: Factory
public interface IPaymentMethod
{
    Task<PaymentResult> ProcessAsync(decimal amount);
}

public class PaymentFactory
{
    private readonly IConfiguration _config;

    public IPaymentMethod Create(string paymentType)
    {
        return paymentType switch
        {
            "CreditCard" => new CreditCardPayment(
                _config["Stripe:ApiKey"],
                _config["Stripe:MerchantId"]),
            "PayPal" => new PayPalPayment(
                _config["PayPal:ClientId"],
                _config["PayPal:Secret"]),
            "Bitcoin" => new BitcoinPayment(
                _config["Bitcoin:WalletAddress"],
                _config["Bitcoin:Network"]),
            _ => throw new ArgumentException($"Unknown payment type: {paymentType}")
        };
    }
}

// Usage
public class PaymentService
{
    private readonly PaymentFactory _factory;

    public async Task ProcessPaymentAsync(Order order)
    {
        var paymentMethod = _factory.Create(order.PaymentType);
        var result = await paymentMethod.ProcessAsync(order.Total);
    }
}
```

**When NOT to use**: Simple object creation (`new User()`) - factory is overkill.

### Strategy Pattern

**Use when**: Multiple algorithms for the same task, selected at runtime.

```csharp
// Use case: Different shipping cost calculations
public interface IShippingStrategy
{
    decimal CalculateCost(Order order);
}

public class StandardShipping : IShippingStrategy
{
    public decimal CalculateCost(Order order)
    {
        return order.Weight * 0.5m;
    }
}

public class ExpressShipping : IShippingStrategy
{
    public decimal CalculateCost(Order order)
    {
        return order.Weight * 1.5m + 10m; // Higher rate + flat fee
    }
}

public class FreeShippingForPremium : IShippingStrategy
{
    public decimal CalculateCost(Order order)
    {
        return order.Customer.IsPremium ? 0 : order.Weight * 0.5m;
    }
}

public class ShippingCostCalculator
{
    public decimal Calculate(Order order, IShippingStrategy strategy)
    {
        return strategy.CalculateCost(order);
    }
}

// Usage
var calculator = new ShippingCostCalculator();
var cost = order.IsExpressShipping
    ? calculator.Calculate(order, new ExpressShipping())
    : calculator.Calculate(order, new StandardShipping());
```

**When NOT to use**: Only one algorithm, or algorithm never changes. Don't over-engineer.

### Decorator Pattern

**Use when**: Adding behavior to objects without modifying their class.

```csharp
// Base interface
public interface INotificationService
{
    Task SendAsync(string message);
}

// Base implementation
public class EmailNotificationService : INotificationService
{
    public async Task SendAsync(string message)
    {
        await SendEmailAsync(message);
    }
}

// Decorator: Add logging
public class LoggingNotificationDecorator : INotificationService
{
    private readonly INotificationService _inner;
    private readonly ILogger _logger;

    public LoggingNotificationDecorator(INotificationService inner, ILogger logger)
    {
        _inner = inner;
        _logger = logger;
    }

    public async Task SendAsync(string message)
    {
        _logger.LogInformation("Sending notification: {Message}", message);
        await _inner.SendAsync(message);
        _logger.LogInformation("Notification sent");
    }
}

// Decorator: Add retry
public class RetryNotificationDecorator : INotificationService
{
    private readonly INotificationService _inner;

    public RetryNotificationDecorator(INotificationService inner)
    {
        _inner = inner;
    }

    public async Task SendAsync(string message)
    {
        var retryPolicy = Policy
            .Handle<Exception>()
            .WaitAndRetryAsync(3, attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)));

        await retryPolicy.ExecuteAsync(() => _inner.SendAsync(message));
    }
}

// Decorator: Add rate limiting
public class RateLimitedNotificationDecorator : INotificationService
{
    private readonly INotificationService _inner;
    private readonly SemaphoreSlim _semaphore = new(10, 10); // Max 10 concurrent

    public RateLimitedNotificationDecorator(INotificationService inner)
    {
        _inner = inner;
    }

    public async Task SendAsync(string message)
    {
        await _semaphore.WaitAsync();
        try
        {
            await _inner.SendAsync(message);
        }
        finally
        {
            _semaphore.Release();
        }
    }
}

// Composition
INotificationService service = new EmailNotificationService();
service = new LoggingNotificationDecorator(service, logger);
service = new RetryNotificationDecorator(service);
service = new RateLimitedNotificationDecorator(service);

await service.SendAsync("Hello!"); // Logs, retries, rate-limits, then sends email
```

**When NOT to use**: Decorators can create long chains that are hard to debug. Use middleware/pipeline if framework supports it (ASP.NET Core middleware).

---

## 3. Repository & Unit of Work Patterns

### Repository Pattern

**Use when**: Abstract data access, support multiple data sources, testability.

**Tech Lead Reality:**
- **80% of projects don't need it** - EF Core DbContext IS a repository
- **Use when**: Switching between SQL/NoSQL, complex aggregate loading, DDD approach
- **Don't use when**: Simple CRUD, 1:1 mapping to database tables
- **Cost**: Extra abstraction layer, possible performance loss from generic queries

```csharp
public interface IOrderRepository
{
    Task<Order> GetByIdAsync(Guid id);
    Task<List<Order>> GetByCustomerAsync(Guid customerId);
    Task SaveAsync(Order order);
    Task DeleteAsync(Guid id);
}

public class SqlOrderRepository : IOrderRepository
{
    private readonly AppDbContext _db;

    public async Task<Order> GetByIdAsync(Guid id)
    {
        return await _db.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id);
    }

    public async Task<List<Order>> GetByCustomerAsync(Guid customerId)
    {
        return await _db.Orders
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    public async Task SaveAsync(Order order)
    {
        if (await _db.Orders.AnyAsync(o => o.Id == order.Id))
            _db.Orders.Update(order);
        else
            _db.Orders.Add(order);

        await _db.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid id)
    {
        var order = await _db.Orders.FindAsync(id);
        if (order != null)
        {
            _db.Orders.Remove(order);
            await _db.SaveChangesAsync();
        }
    }
}
```

### When NOT to Use Repository

**Don't use repository when**:
1. **You're just wrapping EF Core** - DbContext is already a repository/unit of work
2. **Simple CRUD app** - Repository adds no value
3. **Query complexity** - Complex queries leak through abstraction

```csharp
// ANTI-PATTERN - Leaky abstraction
public interface IOrderRepository
{
    Task<List<Order>> GetOrdersAsync(
        Guid? customerId = null,
        DateTime? startDate = null,
        DateTime? endDate = null,
        OrderStatus? status = null,
        int page = 1,
        int pageSize = 20,
        string sortBy = "CreatedAt",
        bool descending = true); // This is just IQueryable with extra steps!
}

// BETTER - Use DbContext directly or expose IQueryable
public interface IOrderRepository
{
    IQueryable<Order> GetQuery(); // Let caller build query
}

// OR - Use specification pattern for complex queries
public interface IOrderRepository
{
    Task<List<Order>> GetAsync(ISpecification<Order> spec);
}
```

### Unit of Work Pattern

**Use when**: Multiple repositories need to share a transaction.

```csharp
public interface IUnitOfWork : IDisposable
{
    IOrderRepository Orders { get; }
    ICustomerRepository Customers { get; }
    IProductRepository Products { get; }

    Task<int> SaveChangesAsync();
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}

public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _db;
    private IDbContextTransaction _transaction;

    public UnitOfWork(AppDbContext db)
    {
        _db = db;
        Orders = new OrderRepository(db);
        Customers = new CustomerRepository(db);
        Products = new ProductRepository(db);
    }

    public IOrderRepository Orders { get; }
    public ICustomerRepository Customers { get; }
    public IProductRepository Products { get; }

    public async Task<int> SaveChangesAsync()
    {
        return await _db.SaveChangesAsync();
    }

    public async Task BeginTransactionAsync()
    {
        _transaction = await _db.Database.BeginTransactionAsync();
    }

    public async Task CommitTransactionAsync()
    {
        await _transaction.CommitAsync();
    }

    public async Task RollbackTransactionAsync()
    {
        await _transaction.RollbackAsync();
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _db.Dispose();
    }
}

// Usage
public class OrderService
{
    private readonly IUnitOfWork _uow;

    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        await _uow.BeginTransactionAsync();
        try
        {
            var customer = await _uow.Customers.GetByIdAsync(request.CustomerId);
            customer.OrderCount++;
            await _uow.Customers.SaveAsync(customer);

            var order = new Order { CustomerId = customer.Id };
            await _uow.Orders.SaveAsync(order);

            foreach (var item in request.Items)
            {
                var product = await _uow.Products.GetByIdAsync(item.ProductId);
                product.Stock -= item.Quantity;
                await _uow.Products.SaveAsync(product);
            }

            await _uow.SaveChangesAsync();
            await _uow.CommitTransactionAsync();
        }
        catch
        {
            await _uow.RollbackTransactionAsync();
            throw;
        }
    }
}
```

### When NOT to Use Unit of Work

**DbContext is already a Unit of Work!** Don't wrap it unless you need:
1. Multiple DbContexts in one transaction
2. Abstraction for testing (but you can mock DbContext)
3. Switching between data sources

```csharp
// Often simpler to use DbContext directly
public class OrderService
{
    private readonly AppDbContext _db;

    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        using var transaction = await _db.Database.BeginTransactionAsync();
        try
        {
            var customer = await _db.Customers.FindAsync(request.CustomerId);
            customer.OrderCount++;

            var order = new Order { CustomerId = customer.Id };
            _db.Orders.Add(order);

            await _db.SaveChangesAsync();
            await transaction.CommitAsync();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}
```

---

## 4. Anemic vs Rich Domain Model

### Anemic Domain Model (Anti-Pattern)

**Problem**: Objects are just data containers, no behavior.

**When Anemic is Actually OK:**
- DTOs (Data Transfer Objects) - by design
- Simple CRUD applications - little business logic
- ORM entities that map 1:1 to database
- Read models in CQRS

**When Rich Model is Critical:**
- Complex business rules
- Invariants must be protected
- Domain-driven design approach
- Multi-step workflows with state transitions

```csharp
// Anemic - just properties
public class Order
{
    public Guid Id { get; set; }
    public Guid CustomerId { get; set; }
    public List<OrderItem> Items { get; set; }
    public decimal Total { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
}

// Service contains all logic
public class OrderService
{
    public void AddItem(Order order, OrderItem item)
    {
        if (order.Status != OrderStatus.Draft)
            throw new InvalidOperationException("Cannot add items to non-draft order");

        order.Items.Add(item);
        order.Total += item.Price * item.Quantity;
    }

    public void Submit(Order order)
    {
        if (order.Items.Count == 0)
            throw new InvalidOperationException("Order must have items");

        if (order.Total < 0)
            throw new InvalidOperationException("Order total cannot be negative");

        order.Status = OrderStatus.Submitted;
    }
}
// All business rules are in the service, not the domain model
```

### Rich Domain Model

**Better**: Behavior lives with the data.

```csharp
public class Order
{
    private readonly List<OrderItem> _items = new();

    public Guid Id { get; private set; }
    public Guid CustomerId { get; private set; }
    public IReadOnlyList<OrderItem> Items => _items.AsReadOnly();
    public decimal Total { get; private set; }
    public OrderStatus Status { get; private set; }
    public DateTime CreatedAt { get; private set; }

    private Order() { } // For EF Core

    public static Order Create(Guid customerId)
    {
        return new Order
        {
            Id = Guid.NewGuid(),
            CustomerId = customerId,
            Status = OrderStatus.Draft,
            CreatedAt = DateTime.UtcNow
        };
    }

    public void AddItem(Guid productId, int quantity, decimal price)
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOperationException("Cannot add items to non-draft order");

        if (quantity <= 0)
            throw new ArgumentException("Quantity must be positive");

        var existingItem = _items.FirstOrDefault(i => i.ProductId == productId);
        if (existingItem != null)
        {
            existingItem.IncreaseQuantity(quantity);
        }
        else
        {
            _items.Add(new OrderItem(productId, quantity, price));
        }

        RecalculateTotal();
    }

    public void Submit()
    {
        if (_items.Count == 0)
            throw new InvalidOperationException("Order must have items");

        if (Total <= 0)
            throw new InvalidOperationException("Order total must be positive");

        Status = OrderStatus.Submitted;
    }

    public void Cancel()
    {
        if (Status == OrderStatus.Shipped)
            throw new InvalidOperationException("Cannot cancel shipped order");

        Status = OrderStatus.Cancelled;
    }

    private void RecalculateTotal()
    {
        Total = _items.Sum(i => i.Price * i.Quantity);
    }
}

public class OrderItem
{
    public Guid ProductId { get; private set; }
    public int Quantity { get; private set; }
    public decimal Price { get; private set; }

    private OrderItem() { } // For EF Core

    internal OrderItem(Guid productId, int quantity, decimal price)
    {
        ProductId = productId;
        Quantity = quantity;
        Price = price;
    }

    internal void IncreaseQuantity(int amount)
    {
        if (amount <= 0)
            throw new ArgumentException("Amount must be positive");

        Quantity += amount;
    }
}

// Service is thin - just orchestration
public class OrderService
{
    private readonly IOrderRepository _repository;

    public async Task CreateOrderAsync(Guid customerId, List<OrderItemDto> items)
    {
        var order = Order.Create(customerId);

        foreach (var item in items)
        {
            order.AddItem(item.ProductId, item.Quantity, item.Price);
        }

        await _repository.SaveAsync(order);
    }
}
```

**Benefits**:
- Business logic is close to data
- Invariants are enforced (can't have invalid order)
- Easier to test (test Order directly, no need for service)
- Encapsulation (can't set properties directly)

---

## 5. Aggregates & Invariants

> **Domain-Driven Design (DDD) Key Terms Explained:**
>
> **Aggregate**: A cluster of related objects that are treated as a single unit for data changes. Each aggregate has a root entity (the "aggregate root") which is the only object external code can reference directly.
>
> **Why Aggregates?**
> - **Consistency boundary**: All objects in an aggregate are saved together atomically
> - **Invariant protection**: The aggregate root ensures business rules are always enforced
> - **Simplified access**: External code only interacts with the root, reducing complexity
>
> **Bounded Context**: A logical boundary within which a particular domain model is defined and applicable. Different bounded contexts can have different definitions of the same term.
> - Example: "Product" in the Sales context (price, discount) vs "Product" in the Warehouse context (weight, dimensions)
>
> **Invariant**: A business rule that must always be true. The aggregate is responsible for maintaining invariants.
> - Example: "Order total must equal sum of line item totals"
> - Example: "Account balance can never be negative"
>
> **Domain Event**: Something that happened in the domain that domain experts care about. Used to communicate between aggregates or bounded contexts.
> - Example: `OrderPlaced`, `PaymentReceived`, `InventoryReserved`
>
> **Value Object**: An immutable object defined by its attributes rather than identity. Two value objects with the same attributes are considered equal.
> - Example: Money(100, "USD"), Address, DateRange

### Aggregate Root

**Definition**: Cluster of domain objects treated as a single unit. External objects can only reference the root.

**Sizing Aggregates - Critical Decision:**
- **Too large**: Performance issues (loading entire object graph), concurrency conflicts
- **Too small**: Lose invariant protection, consistency boundaries unclear
- **Rule of thumb**: Aggregate should be transactionally consistent and fit in one DB transaction
- **Example**: Order + OrderItems = Good aggregate. Order + Customer + Product = Too large

```csharp
// Aggregate Root
public class Order // Root
{
    private readonly List<OrderItem> _items = new(); // Children

    public Guid Id { get; private set; }
    public IReadOnlyList<OrderItem> Items => _items.AsReadOnly();

    // Invariant: Order total = sum of items
    public decimal Total { get; private set; }

    // Only way to modify items is through root
    public void AddItem(Guid productId, int quantity, decimal price)
    {
        _items.Add(new OrderItem(productId, quantity, price));
        RecalculateTotal(); // Maintain invariant
    }

    public void RemoveItem(Guid itemId)
    {
        _items.RemoveAll(i => i.Id == itemId);
        RecalculateTotal(); // Maintain invariant
    }

    private void RecalculateTotal()
    {
        Total = _items.Sum(i => i.Price * i.Quantity);
    }
}

// Not an aggregate root - always accessed through Order
public class OrderItem
{
    public Guid Id { get; private set; }
    public Guid ProductId { get; private set; }
    public int Quantity { get; private set; }
    public decimal Price { get; private set; }

    // Internal - only Order can create
    internal OrderItem(Guid productId, int quantity, decimal price)
    {
        Id = Guid.NewGuid();
        ProductId = productId;
        Quantity = quantity;
        Price = price;
    }
}

// Repository operates on aggregate root only
public interface IOrderRepository
{
    Task<Order> GetByIdAsync(Guid id); // Returns Order with all items
    Task SaveAsync(Order order); // Saves Order and all items
}

// WRONG - Don't create repository for OrderItem
// public interface IOrderItemRepository { } // NO!
```

### Invariants

**Rules that must always be true.**

```csharp
public class BankAccount
{
    public decimal Balance { get; private set; }
    public decimal OverdraftLimit { get; private set; }

    // Invariant: Balance >= -OverdraftLimit
    public void Withdraw(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentException("Amount must be positive");

        var newBalance = Balance - amount;
        if (newBalance < -OverdraftLimit)
            throw new InvalidOperationException("Insufficient funds");

        Balance = newBalance;
        // Invariant maintained
    }

    public void Deposit(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentException("Amount must be positive");

        Balance += amount;
        // Invariant maintained
    }

    // Can't set Balance directly - would break invariant
    // public void SetBalance(decimal balance) { } // NO!
}
```

---

## 6. Domain Events

**Use when**: Something important happened in the domain that other parts care about.

```csharp
// Domain event
public record OrderPlacedEvent
{
    public Guid OrderId { get; init; }
    public Guid CustomerId { get; init; }
    public decimal Total { get; init; }
    public DateTime OccurredAt { get; init; }
}

// Aggregate raises events
public class Order
{
    private readonly List<IDomainEvent> _domainEvents = new();
    public IReadOnlyList<IDomainEvent> DomainEvents => _domainEvents.AsReadOnly();

    public void Submit()
    {
        if (_items.Count == 0)
            throw new InvalidOperationException("Order must have items");

        Status = OrderStatus.Submitted;

        // Raise domain event
        _domainEvents.Add(new OrderPlacedEvent
        {
            OrderId = Id,
            CustomerId = CustomerId,
            Total = Total,
            OccurredAt = DateTime.UtcNow
        });
    }

    public void ClearDomainEvents()
    {
        _domainEvents.Clear();
    }
}

// Dispatch events after saving
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly IDomainEventDispatcher _eventDispatcher;

    public async Task SubmitOrderAsync(Guid orderId)
    {
        var order = await _repository.GetByIdAsync(orderId);
        order.Submit(); // Raises event

        await _repository.SaveAsync(order); // Save first

        // Dispatch events after successful save
        foreach (var domainEvent in order.DomainEvents)
        {
            await _eventDispatcher.DispatchAsync(domainEvent);
        }

        order.ClearDomainEvents();
    }
}

// Event handlers
public class OrderPlacedEventHandler : IDomainEventHandler<OrderPlacedEvent>
{
    private readonly IEmailService _emailService;
    private readonly IInventoryService _inventoryService;

    public async Task HandleAsync(OrderPlacedEvent @event)
    {
        // Send confirmation email
        await _emailService.SendOrderConfirmationAsync(@event.CustomerId, @event.OrderId);

        // Reserve inventory
        await _inventoryService.ReserveForOrderAsync(@event.OrderId);
    }
}
```

**Domain Events vs Integration Events**:
- **Domain Events**: In-process, same bounded context, immediate
- **Integration Events**: Cross-service, via message bus, eventual consistency

---

## 7. Application vs Domain Services

### Domain Service

**Use when**: Operation involves multiple aggregates or doesn't naturally belong to one.

```csharp
// Domain service - contains domain logic
public class PricingService
{
    public decimal CalculateOrderTotal(Order order, Customer customer, List<Discount> applicableDiscounts)
    {
        var subtotal = order.Items.Sum(i => i.Price * i.Quantity);

        // Apply customer-level discount
        if (customer.IsPremium)
            subtotal *= 0.95m;

        // Apply promotional discounts
        foreach (var discount in applicableDiscounts)
        {
            subtotal -= discount.Calculate(subtotal);
        }

        // Add tax
        var tax = subtotal * customer.TaxRate;

        return subtotal + tax;
    }
}

// Used within domain
public class Order
{
    public void CalculateTotal(Customer customer, List<Discount> discounts, PricingService pricingService)
    {
        Total = pricingService.CalculateOrderTotal(this, customer, discounts);
    }
}
```

### Application Service

**Use when**: Orchestrating use cases, coordinating domain objects, infrastructure.

```csharp
// Application service - orchestrates use case
public class PlaceOrderApplicationService
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICustomerRepository _customerRepository;
    private readonly IDiscountRepository _discountRepository;
    private readonly PricingService _pricingService; // Domain service
    private readonly IPaymentGateway _paymentGateway; // Infrastructure
    private readonly IMessageBus _messageBus; // Infrastructure

    public async Task<PlaceOrderResult> ExecuteAsync(PlaceOrderCommand command)
    {
        // Load aggregates
        var customer = await _customerRepository.GetByIdAsync(command.CustomerId);
        var discounts = await _discountRepository.GetApplicableDiscountsAsync(customer);

        // Create order (domain logic)
        var order = Order.Create(customer.Id);
        foreach (var item in command.Items)
        {
            order.AddItem(item.ProductId, item.Quantity, item.Price);
        }

        // Calculate total (domain service)
        order.CalculateTotal(customer, discounts, _pricingService);

        // Process payment (infrastructure)
        var paymentResult = await _paymentGateway.ChargeAsync(order.Total);
        if (!paymentResult.IsSuccessful)
            return PlaceOrderResult.PaymentFailed(paymentResult.ErrorMessage);

        order.MarkAsPaid(paymentResult.TransactionId);

        // Save
        await _orderRepository.SaveAsync(order);

        // Publish integration event (infrastructure)
        await _messageBus.PublishAsync(new OrderPlacedIntegrationEvent
        {
            OrderId = order.Id,
            CustomerId = customer.Id,
            Total = order.Total
        });

        return PlaceOrderResult.Success(order.Id);
    }
}
```

**Key Differences**:
- **Domain Service**: Pure domain logic, no infrastructure dependencies
- **Application Service**: Orchestration, infrastructure, transaction boundaries

---

## 8. Anti-Patterns & Over-Engineering

### Generic Repository (Over-Engineering)

```csharp
// ANTI-PATTERN - Generic repository with no value
public interface IRepository<T> where T : class
{
    Task<T> GetByIdAsync(Guid id);
    Task<List<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(Guid id);
}

public class Repository<T> : IRepository<T> where T : class
{
    private readonly DbContext _db;

    public async Task<T> GetByIdAsync(Guid id) => await _db.Set<T>().FindAsync(id);
    public async Task<List<T>> GetAllAsync() => await _db.Set<T>().ToListAsync();
    public async Task AddAsync(T entity) => await _db.Set<T>().AddAsync(entity);
    // ...
}

// Problem: Real queries are more complex!
// You end up adding this:
public interface IOrderRepository : IRepository<Order> // Generic doesn't help
{
    Task<List<Order>> GetByCustomerAsync(Guid customerId);
    Task<List<Order>> GetPendingOrdersAsync();
    Task<Order> GetWithItemsAsync(Guid id);
    // All the methods you actually need
}
```

**Better**: Skip generic repository, use specific repositories.

### Service Layer Over-Engineering

```csharp
// ANTI-PATTERN - Too many layers
public class OrderController
{
    private readonly IOrderApplicationService _appService;

    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderDto dto)
    {
        var command = _mapper.Map<CreateOrderCommand>(dto);
        var result = await _appService.CreateOrderAsync(command);
        return Ok(_mapper.Map<OrderResponseDto>(result));
    }
}

public class OrderApplicationService
{
    private readonly IOrderDomainService _domainService;

    public async Task<OrderResult> CreateOrderAsync(CreateOrderCommand command)
    {
        return await _domainService.CreateOrderAsync(command);
    }
}

public class OrderDomainService
{
    private readonly IOrderRepository _repository;

    public async Task<OrderResult> CreateOrderAsync(CreateOrderCommand command)
    {
        var order = Order.Create(command.CustomerId);
        // ... create order
        await _repository.SaveAsync(order);
        return OrderResult.Success(order);
    }
}

// 3 layers doing nothing! Application and Domain services are identical!
```

**Better**: Combine when they add no value.

```csharp
public class OrderController
{
    private readonly IOrderRepository _repository;

    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
    {
        var order = Order.Create(request.CustomerId);
        foreach (var item in request.Items)
        {
            order.AddItem(item.ProductId, item.Quantity, item.Price);
        }

        await _repository.SaveAsync(order);
        return Ok(new OrderResponse { OrderId = order.Id });
    }
}
```

### Premature Abstraction

```csharp
// ANTI-PATTERN - Abstracting things you don't need
public interface ILogger
{
    void Log(string message);
}

public interface ILoggerFactory
{
    ILogger CreateLogger();
}

public interface ILoggerConfiguration
{
    void Configure(ILoggerFactory factory);
}

// Just use ILogger<T> from Microsoft.Extensions.Logging!
```

---

## 9. Pattern Misuse Stories

### Story 1: The Over-Engineered Repository

"I joined a project with 'clean architecture'. They had:
- Generic repository with 30 methods
- Unit of Work with 15 repositories
- Specification pattern for all queries
- Every query was 5 classes (Query, Handler, Validator, Specification, Mapper)

Simple query 'Get orders by customer' was 200 lines across 5 files. Changed to:
```csharp
await _db.Orders.Where(o => o.CustomerId == customerId).ToListAsync();
```
Deleted 10,000 lines of 'architecture'."

### Story 2: The Singleton Database Connection

"Team used Singleton pattern for database connection. Worked fine in dev (1 user). Production: all requests shared one connection. Deadlocks, timeouts, disaster.

Lesson: Connection pooling, not Singleton!"

### Story 3: The Abstract Factory Factory Factory

"Enterprise project had `AbstractOrderFactoryProviderFactory`. I kid you not. It created a provider that created a factory that created orders.

Why? 'Future flexibility'. They never needed it. Deleted, replaced with `new Order()`."

---

## 10. Interview Questions

### Q1: "When would you use Repository pattern?"

**Good Answer**:
"I use Repository when:

1. **Multiple data sources**: Need to switch between SQL, NoSQL, caching
2. **Complex domain logic**: Aggregate roots need specific loading (Order with Items, Customer, etc.)
3. **Testing**: Need to mock data access for unit tests

I DON'T use it when:
- Simple CRUD with EF Core (DbContext is already a repository)
- Queries are complex and leak through abstraction
- It's just wrapping DbContext with no added value

Example where it helps:
```csharp
public interface IOrderRepository
{
    Task<Order> GetByIdWithFullDetails(Guid id); // Loads Order + Items + Customer
}
```

Example where it doesn't:
```csharp
// Just use DbContext directly
await _db.Orders.Include(o => o.Items).FirstOrDefaultAsync(o => o.Id == id);
```"

### Q2: "Anemic domain model vs Rich domain model?"

**Good Answer**:
"Anemic model: Data objects with no behavior. All logic in services.

Rich model: Behavior lives with data. Objects enforce their own invariants.

I prefer rich models for complex domains:
```csharp
public class Order
{
    public void AddItem(Product product, int quantity)
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOperationException();

        _items.Add(new OrderItem(product, quantity));
        RecalculateTotal();
    }
}
```

Anemic is okay for:
- Simple CRUD apps
- Data transfer (DTOs)
- Frameworks that require it (EF Core entities sometimes)

But for core business logic, rich models are more maintainable."

### Q3: "How do you prevent over-engineering?"

**Good Answer**:
"Three rules:

1. **YAGNI** (You Aren't Gonna Need It): Don't add patterns for 'future flexibility'. Add them when you need them.

2. **Measure complexity vs value**: If a pattern adds 3 classes to save 10 lines, skip it.

3. **Real requirements, not theoretical**: 'We might need multiple databases' - are you actually switching? No? Then don't abstract it.

Example:
```csharp
// Don't do this for simple config
public interface IConfigurationProvider
{
    T Get<T>(string key);
}

// Just use this
var apiKey = _configuration["ApiKey"];
```

Add abstraction when you have 2+ real implementations, not 'maybe someday'."

### Q4: "What's an aggregate and why does it matter?"

**Good Answer**:
"Aggregate is a cluster of objects treated as a unit. Has one root that external objects reference.

Why it matters:
1. **Enforces invariants**: Order total = sum of items. Can't modify items without going through Order.
2. **Transaction boundary**: Save entire aggregate atomically.
3. **Consistency**: Aggregate is always in valid state.

Example:
```csharp
public class Order // Aggregate root
{
    private List<OrderItem> _items; // Part of aggregate

    public void AddItem(...) // Only way to modify items
    {
        _items.Add(...);
        RecalculateTotal(); // Maintain invariant
    }
}

// Repository saves entire aggregate
await _repository.SaveAsync(order); // Saves order + all items
```

Common mistake: Making OrderItem a separate aggregate with its own repository. Then Order total can be out of sync with items."

---

## Summary

**Key Principles**:

1. **SOLID** is a guideline, not a law - apply with judgment
2. **Patterns solve specific problems** - don't use patterns for the sake of patterns
3. **Repository + Unit of Work**: Often unnecessary with EF Core
4. **Rich domain models** > Anemic models for complex domains
5. **Aggregates enforce invariants** - transaction and consistency boundaries
6. **Domain events** for in-process communication
7. **Application services** orchestrate, **domain services** contain domain logic
8. **YAGNI**: Don't over-engineer for theoretical future needs
9. **Measure complexity vs value** - if pattern adds more code than it saves, skip it
10. **Abstractions should hide complexity**, not create it

**Remember**: The best code is simple, clear, and solves the actual problem - not the imaginary one.

