# 06 — Testing & Quality

> **Mental Model:** The test pyramid. Unit tests are sand (cheap, many, fast).
> Integration tests are rocks (fewer, real dependencies). E2E tests are boulders
> (expensive, few, cover user journeys). More sand than rocks. Few boulders.

---

## Test Pyramid Rules

```
          ▲
         /E\        E2E / Contract tests — 5%
        /───\       Full stack, real browser, slow
       /Integ\      Integration tests — 20%
      /────────\    Real DB (Testcontainers), real HTTP
     /  Unit    \   Unit tests — 75%
    /────────────\  No I/O, no network, fast (< 1ms each)

RULE: Tests should be honest about what they test.
  Unit test  = fast, isolated, tests ONE class/function in depth
  Integration test = tests interaction between components (e.g. repo + real DB)
  E2E test   = tests the full system as a user would use it
```

---

## Unit Test Pattern — Domain and Application

```csharp
// ── Naming convention: Should_[ExpectedBehavior]_When_[Condition] ─────────────

public class OrderTests
{
    // ── Domain tests — pure, no mocks ────────────────────────────────────────
    // WHY no mocks in domain tests: domain is pure logic. If you need mocks,
    //   you have infrastructure concerns in the domain — fix the design.

    [Fact]
    public void Should_AddItem_When_OrderIsDraft()
    {
        // Arrange — use builders/factories for readability
        var order = OrderBuilder.Create()
            .WithStatus(OrderStatus.Draft)
            .Build();

        var productId = ProductId.New();
        var price = new Money(29.99m, "USD");

        // Act
        order.AddItem(productId, quantity: 2, price);

        // Assert — FluentAssertions for readable failure messages
        order.Items.Should().HaveCount(1);
        order.Items[0].ProductId.Should().Be(productId);
        order.Items[0].Quantity.Should().Be(2);
    }

    [Fact]
    public void Should_ThrowOrderNotEditableException_When_OrderIsConfirmed()
    {
        // Arrange
        var order = OrderBuilder.Create()
            .WithStatus(OrderStatus.Confirmed)
            .Build();

        // Act + Assert — exception testing
        var act = () => order.AddItem(ProductId.New(), 1, new Money(10m, "USD"));
        act.Should().Throw<OrderNotEditableException>()
            .WithMessage("*cannot be modified*");
    }

    // Theory — parameterised test (replaces copy-paste test methods)
    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(-100)]
    public void Should_ThrowArgumentException_When_QuantityIsNotPositive(int quantity)
    {
        var order = OrderBuilder.Create().WithStatus(OrderStatus.Draft).Build();
        var act = () => order.AddItem(ProductId.New(), quantity, new Money(10m, "USD"));
        act.Should().Throw<ArgumentException>();
    }
}

// ── Application layer tests — mock infrastructure interfaces ──────────────────

public class PlaceOrderCommandHandlerTests
{
    private readonly Mock<IOrderRepository>  _orderRepo  = new();
    private readonly Mock<ICustomerRepository> _customerRepo = new();
    private readonly Mock<IUnitOfWork>       _uow        = new();
    private readonly PlaceOrderCommandHandler _handler;

    public PlaceOrderCommandHandlerTests()
    {
        // WHY constructor setup: handler is re-created for each test — clean state
        _handler = new PlaceOrderCommandHandler(_orderRepo.Object, _customerRepo.Object, _uow.Object);
    }

    [Fact]
    public async Task Should_ReturnSuccess_When_ValidOrderIsPlaced()
    {
        // Arrange
        var customerId = CustomerId.New();
        var customer   = CustomerBuilder.Create().WithId(customerId).Build();
        var command    = new PlaceOrderCommand(customerId, new[] { new OrderItem(ProductId.New(), 1, 25m) });

        _customerRepo.Setup(r => r.GetByIdAsync(customerId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(customer);

        _orderRepo.Setup(r => r.AddAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _uow.Setup(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(1);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBeEmpty();

        // Verify interactions — WHY: confirm the handler saved AND published the event
        _orderRepo.Verify(r => r.AddAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()), Times.Once);
        _uow.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Should_ReturnFailure_When_CustomerNotFound()
    {
        // Arrange
        _customerRepo.Setup(r => r.GetByIdAsync(It.IsAny<CustomerId>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((Customer?)null);

        var command = new PlaceOrderCommand(CustomerId.New(), []);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeFalse();
        result.Error.Should().Contain("not found");

        // WHY Verify Never: if customer doesn't exist, no order should be saved
        _orderRepo.Verify(r => r.AddAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()), Times.Never);
    }
}
```

---

## Integration Tests — Real Database with Testcontainers

```csharp
// WHY Testcontainers: spins up a real SQL Server/Postgres in Docker for tests.
//   Integration tests run against real EF Core migrations and real SQL.
//   No mocked repositories — tests the actual data layer.
//   Isolated per test run — no shared state between test suites.

// ── Test fixture — shared container across all tests in the class ─────────────
public class OrderRepositoryTests : IAsyncLifetime
{
    private MsSqlContainer _sqlContainer = null!;
    private AppDbContext    _dbContext    = null!;

    // IAsyncLifetime.InitializeAsync — runs before first test in the class
    public async Task InitializeAsync()
    {
        _sqlContainer = new MsSqlBuilder()
            .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
            .WithPassword("Test@Password123!")
            .Build();

        await _sqlContainer.StartAsync();

        // WHY real migrations: tests run against the exact same schema as production
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(_sqlContainer.GetConnectionString())
            .Options;

        _dbContext = new AppDbContext(options);
        await _dbContext.Database.MigrateAsync();   // run all migrations
    }

    public async Task DisposeAsync()
    {
        await _dbContext.DisposeAsync();
        await _sqlContainer.DisposeAsync();   // WHY: container stopped + removed after tests
    }

    [Fact]
    public async Task Should_PersistAndRetrieveOrder_WhenSaved()
    {
        // Arrange
        var repo = new OrderRepository(_dbContext);
        var order = OrderBuilder.Create().Build();

        // Act
        await repo.AddAsync(order, CancellationToken.None);
        await _dbContext.SaveChangesAsync();

        // Detach to force fresh load from DB (not EF change tracker)
        _dbContext.ChangeTracker.Clear();

        var retrieved = await repo.GetByIdAsync(order.Id, CancellationToken.None);

        // Assert — real DB persistence verified
        retrieved.Should().NotBeNull();
        retrieved!.Id.Should().Be(order.Id);
        retrieved.Items.Should().HaveCount(order.Items.Count);
    }
}
```

---

## API Integration Tests — WebApplicationFactory

```csharp
// WHY WebApplicationFactory: boots the real app in-memory.
//   Tests the full pipeline: routing → middleware → handler → repository.
//   No external network — fast, no test environment needed.

public class OrderEndpointsTests(ApiTestFactory factory)
    : IClassFixture<ApiTestFactory>
{
    private readonly HttpClient _client = factory.CreateClient();

    [Fact]
    public async Task Should_Return201_When_ValidOrderCreated()
    {
        // Arrange
        var request = new CreateOrderRequest(
            CustomerId: Guid.NewGuid(),
            Items: [new OrderLineItem(Guid.NewGuid(), 2, 29.99m)]
        );

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/orders", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();   // Location header required for 201

        var body = await response.Content.ReadFromJsonAsync<OrderCreatedDto>();
        body!.Id.Should().NotBeEmpty();
    }

    [Fact]
    public async Task Should_Return400_When_OrderHasNoItems()
    {
        var request = new CreateOrderRequest(Guid.NewGuid(), []);   // empty items

        var response = await _client.PostAsJsonAsync("/api/v1/orders", request);

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var problem = await response.Content.ReadFromJsonAsync<ValidationProblemDetails>();
        problem!.Errors.Should().ContainKey("Items");
    }
}

// ── ApiTestFactory — overrides services for test isolation ───────────────────
public class ApiTestFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // WHY replace DbContext: use in-memory or Testcontainers DB for isolation
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
            if (descriptor != null) services.Remove(descriptor);

            services.AddDbContext<AppDbContext>(opts =>
                opts.UseInMemoryDatabase("TestDb_" + Guid.NewGuid()));
            //  ↑ WHY Guid suffix: prevents state leakage between test class instances

            // Seed required test data
            using var scope = services.BuildServiceProvider().CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            db.Database.EnsureCreated();
            SeedTestData(db);
        });
    }

    private static void SeedTestData(AppDbContext db)
    {
        db.Customers.Add(new Customer(/* test data */));
        db.SaveChanges();
    }
}
```

---

## Test Builder Pattern

```csharp
// WHY builders: tests become readable. Arrange section shows WHAT matters,
//   not HOW to construct the object. Changes to constructors only update the builder.

public class OrderBuilder
{
    private OrderId       _id       = OrderId.New();
    private CustomerId    _customerId = CustomerId.New();
    private OrderStatus   _status   = OrderStatus.Draft;
    private List<OrderItem> _items  = [];

    public static OrderBuilder Create() => new();

    public OrderBuilder WithId(OrderId id)           { _id = id; return this; }
    public OrderBuilder WithCustomer(CustomerId id)  { _customerId = id; return this; }
    public OrderBuilder WithStatus(OrderStatus s)    { _status = s; return this; }
    public OrderBuilder WithItem(OrderItem item)     { _items.Add(item); return this; }

    public Order Build()
    {
        var order = Order.Create(_customerId);   // domain factory method
        // Use reflection or test-specific constructor to set status
        order.SetStatusForTest(_status);
        foreach (var item in _items)
            order.AddItem(item.ProductId, item.Quantity, item.UnitPrice);
        return order;
    }
}

// Usage in test:
var order = OrderBuilder.Create()
    .WithStatus(OrderStatus.Confirmed)
    .WithItem(new OrderItem(ProductId.New(), 3, new Money(25m, "USD")))
    .Build();
```

---

## What NOT to Mock

```
MOCK:
  ✅ External services (HTTP APIs, email, SMS)
  ✅ Infrastructure interfaces (IOrderRepository, IEmailSender)
  ✅ Time (ISystemClock, IClock — never DateTime.Now in testable code)
  ✅ Random values (IRandomGenerator)

DO NOT MOCK:
  ❌ Domain entities and value objects — test them directly
  ❌ Application services in their own tests — test real logic
  ❌ Database in unit tests — use Testcontainers for real DB tests
  ❌ The class under test — if you're mocking it, you're testing the mock

RULE: If a test mocks more than 3 things, the class under test
      likely has too many dependencies (SRP violation).
```
