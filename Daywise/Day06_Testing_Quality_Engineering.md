# Day 06: Testing & Quality Engineering

## Overview
Testing is not just about code coverage - it's about confidence, maintainability, and designing better systems. This guide covers testing strategies, patterns, and trade-offs for senior engineering interviews.

---

## 1. Test Types & The Test Pyramid

### The Test Pyramid Concept
```
     /\
    /  \  E2E Tests (Few, Slow, Expensive)
   /____\
  /      \  Integration Tests (Some, Medium Speed)
 /________\
/__________\ Unit Tests (Many, Fast, Cheap)
```

**Key Principle**: More unit tests, fewer integration tests, minimal E2E tests.

**Why?**
- **Speed**: Unit tests run in milliseconds, E2E in seconds/minutes
- **Reliability**: Unit tests are deterministic, E2E tests are flaky
- **Debugging**: Unit test failures pinpoint issues, E2E failures are vague
- **Cost**: E2E tests require infrastructure, databases, services

**Architect's Reality Check:**
- **Ideal ratio**: 70% unit, 20% integration, 10% E2E (adjust based on context)
- **Don't dogmatically follow pyramid**: Legacy systems may need more integration tests
- **Critical paths**: E2E tests for critical business flows (checkout, payment) are worth the cost
- **Trade-off**: Confidence vs speed - find the right balance for your system

---

## 2. Unit Testing in C#

### What Makes a Good Unit Test?

**FIRST Principles**:
- **F**ast - Milliseconds, not seconds
- **I**solated - No shared state, no dependencies
- **R**epeatable - Same result every time
- **S**elf-validating - Pass or fail, no manual checks
- **T**imely - Written with or before production code

### Example: Testing Business Logic

```csharp
// Production Code
public class OrderService
{
    private readonly IPaymentGateway _paymentGateway;
    private readonly IInventoryService _inventoryService;
    private readonly IOrderRepository _orderRepository;

    public OrderService(
        IPaymentGateway paymentGateway,
        IInventoryService inventoryService,
        IOrderRepository orderRepository)
    {
        _paymentGateway = paymentGateway;
        _inventoryService = inventoryService;
        _orderRepository = orderRepository;
    }

    public async Task<OrderResult> PlaceOrderAsync(Order order)
    {
        // Validate inventory
        if (!await _inventoryService.IsAvailableAsync(order.Items))
        {
            return OrderResult.Failed("Insufficient inventory");
        }

        // Process payment
        var paymentResult = await _paymentGateway.ChargeAsync(order.Total);
        if (!paymentResult.IsSuccessful)
        {
            return OrderResult.Failed("Payment failed");
        }

        // Reserve inventory
        await _inventoryService.ReserveAsync(order.Items);

        // Save order
        order.MarkAsPaid(paymentResult.TransactionId);
        await _orderRepository.SaveAsync(order);

        return OrderResult.Success(order.Id);
    }
}

// Unit Tests using xUnit and Moq
public class OrderServiceTests
{
    private readonly Mock<IPaymentGateway> _paymentGatewayMock;
    private readonly Mock<IInventoryService> _inventoryServiceMock;
    private readonly Mock<IOrderRepository> _orderRepositoryMock;
    private readonly OrderService _sut; // System Under Test

    public OrderServiceTests()
    {
        _paymentGatewayMock = new Mock<IPaymentGateway>();
        _inventoryServiceMock = new Mock<IInventoryService>();
        _orderRepositoryMock = new Mock<IOrderRepository>();

        _sut = new OrderService(
            _paymentGatewayMock.Object,
            _inventoryServiceMock.Object,
            _orderRepositoryMock.Object
        );
    }

    [Fact]
    public async Task PlaceOrder_WhenInventoryInsufficient_ShouldReturnFailure()
    {
        // Arrange
        var order = CreateTestOrder();
        _inventoryServiceMock
            .Setup(x => x.IsAvailableAsync(order.Items))
            .ReturnsAsync(false);

        // Act
        var result = await _sut.PlaceOrderAsync(order);

        // Assert
        Assert.False(result.IsSuccessful);
        Assert.Equal("Insufficient inventory", result.ErrorMessage);

        // Verify payment was never attempted
        _paymentGatewayMock.Verify(
            x => x.ChargeAsync(It.IsAny<decimal>()),
            Times.Never
        );
    }

    [Fact]
    public async Task PlaceOrder_WhenPaymentFails_ShouldNotReserveInventory()
    {
        // Arrange
        var order = CreateTestOrder();
        _inventoryServiceMock
            .Setup(x => x.IsAvailableAsync(order.Items))
            .ReturnsAsync(true);
        _paymentGatewayMock
            .Setup(x => x.ChargeAsync(order.Total))
            .ReturnsAsync(PaymentResult.Failed());

        // Act
        var result = await _sut.PlaceOrderAsync(order);

        // Assert
        Assert.False(result.IsSuccessful);
        _inventoryServiceMock.Verify(
            x => x.ReserveAsync(It.IsAny<IEnumerable<OrderItem>>()),
            Times.Never
        );
    }

    [Fact]
    public async Task PlaceOrder_WhenSuccessful_ShouldFollowHappyPath()
    {
        // Arrange
        var order = CreateTestOrder();
        var transactionId = "TXN-123";

        _inventoryServiceMock
            .Setup(x => x.IsAvailableAsync(order.Items))
            .ReturnsAsync(true);
        _paymentGatewayMock
            .Setup(x => x.ChargeAsync(order.Total))
            .ReturnsAsync(PaymentResult.Success(transactionId));

        // Act
        var result = await _sut.PlaceOrderAsync(order);

        // Assert
        Assert.True(result.IsSuccessful);
        Assert.Equal(order.Id, result.OrderId);

        // Verify complete workflow
        _inventoryServiceMock.Verify(
            x => x.IsAvailableAsync(order.Items),
            Times.Once
        );
        _paymentGatewayMock.Verify(
            x => x.ChargeAsync(order.Total),
            Times.Once
        );
        _inventoryServiceMock.Verify(
            x => x.ReserveAsync(order.Items),
            Times.Once
        );
        _orderRepositoryMock.Verify(
            x => x.SaveAsync(It.Is<Order>(o => o.Status == OrderStatus.Paid)),
            Times.Once
        );
    }

    private Order CreateTestOrder() => new Order
    {
        Id = Guid.NewGuid(),
        Items = new List<OrderItem> { new OrderItem("Product1", 1, 10m) },
        Total = 10m
    };
}
```

---

## 3. Mocking vs Faking

**Tech Lead Decision Framework:**
- **Mock**: External dependencies (databases, APIs, message queues) - verify interactions
- **Fake**: In-memory implementations for complex logic - test behavior with real implementation
- **Real objects**: Simple value objects, domain entities - no mocking needed
- **Anti-pattern**: Mocking everything - creates brittle tests coupled to implementation details

**Key Principle**: Mock at architecture boundaries (I/O, network), not domain logic

### Mocking (Moq)
Use when you need to **verify behavior** and **control dependencies**.

```csharp
// Verify specific interactions happened
var emailServiceMock = new Mock<IEmailService>();
emailServiceMock
    .Setup(x => x.SendAsync(It.IsAny<Email>()))
    .ReturnsAsync(true);

await _sut.ProcessOrderAsync(order);

emailServiceMock.Verify(
    x => x.SendAsync(It.Is<Email>(e => e.To == order.CustomerEmail)),
    Times.Once
);
```

### Faking
Use when you need a **lightweight implementation** for testing.

```csharp
// Fake implementation - in-memory storage
public class FakeOrderRepository : IOrderRepository
{
    private readonly Dictionary<Guid, Order> _orders = new();

    public Task SaveAsync(Order order)
    {
        _orders[order.Id] = order;
        return Task.CompletedTask;
    }

    public Task<Order> GetByIdAsync(Guid id)
    {
        _orders.TryGetValue(id, out var order);
        return Task.FromResult(order);
    }

    public Task<List<Order>> GetAllAsync()
    {
        return Task.FromResult(_orders.Values.ToList());
    }
}

// Usage in tests
var fakeRepo = new FakeOrderRepository();
var service = new OrderService(fakeRepo);

await service.CreateOrderAsync(order);
var savedOrder = await fakeRepo.GetByIdAsync(order.Id);

Assert.NotNull(savedOrder);
```

### NSubstitute Alternative

```csharp
// NSubstitute has cleaner syntax
var paymentGateway = Substitute.For<IPaymentGateway>();
paymentGateway.ChargeAsync(Arg.Any<decimal>())
    .Returns(PaymentResult.Success("TXN-123"));

await _sut.ProcessPaymentAsync(100m);

await paymentGateway.Received(1).ChargeAsync(100m);
```

**When to use what?**
- **Moq/NSubstitute**: Testing behavior, verifying interactions
- **Fakes**: Testing state, integration testing, shared test infrastructure
- **Real implementations**: Integration/E2E tests

### React Component Testing with Jest & React Testing Library

**Full Stack Testing Philosophy:**
- Backend tests (C#): Focus on business logic, data layer
- Frontend tests (React): Focus on user interaction, UI behavior
- Integration tests: Full stack API + UI workflows

```javascript
// React Component
import { useState, useEffect } from 'react';

export const OrderList: React.FC = () => {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchOrders = async () => {
            try {
                const response = await fetch('/api/orders');
                if (!response.ok) throw new Error('Failed to fetch');
                const data = await response.json();
                setOrders(data);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };

        fetchOrders();
    }, []);

    if (loading) return <div role="status">Loading...</div>;
    if (error) return <div role="alert">Error: {error}</div>;

    return (
        <ul>
            {orders.map(order => (
                <li key={order.id}>
                    Order #{order.id} - ${order.total}
                </li>
            ))}
        </ul>
    );
};

// Test with Mock Service Worker (MSW)
import { render, screen, waitFor } from '@testing-library/react';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { OrderList } from './OrderList';

// Mock API server
const server = setupServer(
    rest.get('/api/orders', (req, res, ctx) => {
        return res(ctx.json([
            { id: 1, total: 100, status: 'Pending' },
            { id: 2, total: 200, status: 'Paid' }
        ]));
    })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('OrderList Component', () => {
    test('displays loading state initially', () => {
        render(<OrderList />);
        expect(screen.getByRole('status')).toHaveTextContent('Loading...');
    });

    test('displays orders after successful fetch', async () => {
        render(<OrderList />);

        // Wait for loading to finish
        await waitFor(() => {
            expect(screen.queryByRole('status')).not.toBeInTheDocument();
        });

        // Verify orders are displayed
        expect(screen.getByText(/Order #1/)).toBeInTheDocument();
        expect(screen.getByText(/\$100/)).toBeInTheDocument();
        expect(screen.getByText(/Order #2/)).toBeInTheDocument();
    });

    test('displays error on API failure', async () => {
        // Override handler for this test
        server.use(
            rest.get('/api/orders', (req, res, ctx) => {
                return res(ctx.status(500));
            })
        );

        render(<OrderList />);

        await waitFor(() => {
            expect(screen.getByRole('alert')).toHaveTextContent('Error: Failed to fetch');
        });
    });

    test('handles empty order list', async () => {
        server.use(
            rest.get('/api/orders', (req, res, ctx) => {
                return res(ctx.json([]));
            })
        );

        render(<OrderList />);

        await waitFor(() => {
            expect(screen.queryByRole('status')).not.toBeInTheDocument();
        });

        const list = screen.getByRole('list');
        expect(list.children).toHaveLength(0);
    });
});

// Testing User Interactions
import userEvent from '@testing-library/user-event';

describe('OrderForm Component', () => {
    test('submits form with valid data', async () => {
        const mockSubmit = jest.fn();
        const user = userEvent.setup();

        render(<OrderForm onSubmit={mockSubmit} />);

        // Fill form
        await user.type(screen.getByLabelText('Product'), 'Laptop');
        await user.type(screen.getByLabelText('Quantity'), '5');
        await user.click(screen.getByRole('button', { name: 'Submit' }));

        // Verify submission
        await waitFor(() => {
            expect(mockSubmit).toHaveBeenCalledWith({
                product: 'Laptop',
                quantity: 5
            });
        });
    });

    test('shows validation error for invalid quantity', async () => {
        const user = userEvent.setup();
        render(<OrderForm onSubmit={jest.fn()} />);

        await user.type(screen.getByLabelText('Quantity'), '-1');
        await user.click(screen.getByRole('button', { name: 'Submit' }));

        expect(screen.getByText('Quantity must be positive')).toBeInTheDocument();
    });
});
```

**React Testing Best Practices:**
- **Test user behavior, not implementation** - Don't test internal state or methods
- **Use semantic queries** - getByRole, getByLabelText (better than getByTestId)
- **Mock external dependencies** - APIs, not React components
- **Test accessibility** - Ensure proper ARIA roles and labels
- **Avoid testing libraries** - Don't test React Router or React Query directly

**Tech Lead Decision: Backend vs Frontend Testing Split**
- **Backend (C#)**: Business logic (80%), data validation, authorization rules
- **Frontend (React)**: UI logic (70%), user interaction flows, error display
- **E2E Tests**: Critical paths only (10%) - login, checkout, payment

---

## 4. Integration Testing

### Testing with Real Dependencies

```csharp
public class OrderIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public OrderIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Replace real database with test database
                services.RemoveAll<DbContextOptions<OrderDbContext>>();
                services.AddDbContext<OrderDbContext>(options =>
                {
                    options.UseInMemoryDatabase("TestDb");
                });
            });
        });

        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task CreateOrder_ShouldPersistToDatabase()
    {
        // Arrange
        var request = new CreateOrderRequest
        {
            CustomerId = Guid.NewGuid(),
            Items = new[] { new OrderItemDto("Product1", 1, 10m) }
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/orders", request);

        // Assert
        response.EnsureSuccessStatusCode();
        var orderId = await response.Content.ReadFromJsonAsync<Guid>();

        // Verify in database
        using var scope = _factory.Services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<OrderDbContext>();
        var order = await dbContext.Orders.FindAsync(orderId);

        Assert.NotNull(order);
        Assert.Equal(request.CustomerId, order.CustomerId);
        Assert.Single(order.Items);
    }
}
```

### Testing with Testcontainers

```csharp
public class DatabaseIntegrationTests : IAsyncLifetime
{
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder()
        .WithDatabase("testdb")
        .WithUsername("test")
        .WithPassword("test")
        .Build();

    private OrderDbContext _dbContext;

    public async Task InitializeAsync()
    {
        await _postgres.StartAsync();

        var options = new DbContextOptionsBuilder<OrderDbContext>()
            .UseNpgsql(_postgres.GetConnectionString())
            .Options;

        _dbContext = new OrderDbContext(options);
        await _dbContext.Database.MigrateAsync();
    }

    [Fact]
    public async Task SaveOrder_ShouldPersistWithRelations()
    {
        // Arrange
        var order = new Order
        {
            CustomerId = Guid.NewGuid(),
            Items = new List<OrderItem>
            {
                new("Product1", 1, 10m),
                new("Product2", 2, 20m)
            }
        };

        // Act
        _dbContext.Orders.Add(order);
        await _dbContext.SaveChangesAsync();

        // Assert - Clear context to force reload from DB
        _dbContext.ChangeTracker.Clear();
        var savedOrder = await _dbContext.Orders
            .Include(o => o.Items)
            .FirstAsync(o => o.Id == order.Id);

        Assert.Equal(2, savedOrder.Items.Count);
    }

    public async Task DisposeAsync()
    {
        await _dbContext.DisposeAsync();
        await _postgres.DisposeAsync();
    }
}
```

---

## 5. Testing Async Code

### Common Pitfalls

```csharp
// WRONG - Test might pass even if async code fails
[Fact]
public void ProcessAsync_ShouldComplete()
{
    // This doesn't await - test completes before async operation
    _sut.ProcessAsync();

    // Assertions might run before async completes
    Assert.True(_sut.IsProcessed);
}

// CORRECT - Async test properly awaits
[Fact]
public async Task ProcessAsync_ShouldComplete()
{
    await _sut.ProcessAsync();
    Assert.True(_sut.IsProcessed);
}
```

### Testing Timeout Scenarios

```csharp
[Fact]
public async Task LongRunningOperation_ShouldTimeoutGracefully()
{
    // Arrange
    var cts = new CancellationTokenSource(TimeSpan.FromSeconds(1));

    // Act & Assert
    await Assert.ThrowsAsync<OperationCanceledException>(async () =>
    {
        await _sut.LongRunningOperationAsync(cts.Token);
    });
}
```

### Testing Parallel Operations

```csharp
[Fact]
public async Task ConcurrentRequests_ShouldHandleRaceConditions()
{
    // Arrange
    var productId = Guid.NewGuid();
    var initialStock = 10;
    await _inventoryService.SetStockAsync(productId, initialStock);

    // Act - Simulate 10 concurrent purchases
    var tasks = Enumerable.Range(0, 10)
        .Select(_ => _inventoryService.DecrementStockAsync(productId, 1))
        .ToArray();

    await Task.WhenAll(tasks);

    // Assert - No race condition, stock should be 0
    var finalStock = await _inventoryService.GetStockAsync(productId);
    Assert.Equal(0, finalStock);
}
```

---

## 6. Contract Testing

### Why Contract Testing?

**Problem**: Microservices need to integrate, but integration tests are slow and brittle.

**Solution**: Test the contract/API boundary independently.

```csharp
// Consumer-Driven Contract Testing with Pact
public class OrderServiceConsumerTests
{
    private readonly IPactBuilderV3 _pact;

    public OrderServiceConsumerTests()
    {
        _pact = Pact.V3("OrderService", "PaymentService", new PactConfig());
    }

    [Fact]
    public async Task ProcessPayment_ShouldReturnTransactionId()
    {
        // Arrange - Define expected contract
        _pact
            .UponReceiving("a request to process payment")
            .Given("payment service is available")
            .WithRequest(HttpMethod.Post, "/api/payments")
            .WithJsonBody(new
            {
                amount = 100.00,
                currency = "USD"
            })
            .WillRespond()
            .WithStatus(HttpStatusCode.OK)
            .WithJsonBody(new
            {
                transactionId = Match.Type("TXN-123"),
                status = "Success"
            });

        await _pact.VerifyAsync(async ctx =>
        {
            // Act
            var client = new HttpClient { BaseAddress = ctx.MockServerUri };
            var paymentService = new PaymentServiceClient(client);

            var result = await paymentService.ProcessPaymentAsync(100.00m, "USD");

            // Assert
            Assert.NotNull(result.TransactionId);
            Assert.Equal("Success", result.Status);
        });
    }
}
```

### Schema Validation Testing

```csharp
[Fact]
public async Task GetOrder_ShouldMatchApiSchema()
{
    // Arrange
    var expectedSchema = JSchema.Parse(@"{
        'type': 'object',
        'properties': {
            'id': {'type': 'string', 'format': 'uuid'},
            'customerId': {'type': 'string', 'format': 'uuid'},
            'total': {'type': 'number', 'minimum': 0},
            'status': {'type': 'string', 'enum': ['Pending', 'Paid', 'Shipped']},
            'items': {
                'type': 'array',
                'items': {
                    'type': 'object',
                    'properties': {
                        'productId': {'type': 'string'},
                        'quantity': {'type': 'integer', 'minimum': 1},
                        'price': {'type': 'number', 'minimum': 0}
                    },
                    'required': ['productId', 'quantity', 'price']
                }
            }
        },
        'required': ['id', 'customerId', 'total', 'status', 'items']
    }");

    // Act
    var response = await _client.GetAsync($"/api/orders/{orderId}");
    var content = await response.Content.ReadAsStringAsync();
    var json = JObject.Parse(content);

    // Assert
    Assert.True(json.IsValid(expectedSchema, out IList<string> errors),
        $"Schema validation failed: {string.Join(", ", errors)}");
}
```

### Full Stack E2E Testing with Playwright

**When to use E2E tests:**
- Critical user journeys (login, checkout, payment)
- Cross-browser compatibility
- Real user workflows that span multiple services
- Visual regression testing

```typescript
// Playwright E2E Test - Full Order Flow
import { test, expect } from '@playwright/test';

test.describe('Complete Order Flow', () => {
    test.beforeEach(async ({ page }) => {
        // Navigate to app
        await page.goto('https://localhost:3000');
    });

    test('user can create and complete an order', async ({ page }) => {
        // 1. Login
        await page.click('text=Login');
        await page.fill('[name="email"]', 'test@example.com');
        await page.fill('[name="password"]', 'password123');
        await page.click('button:has-text("Sign In")');

        // Verify redirect to dashboard
        await expect(page).toHaveURL(/.*dashboard/);
        await expect(page.locator('h1')).toContainText('Welcome');

        // 2. Create Order
        await page.click('button:has-text("New Order")');

        // Fill order form
        await page.selectOption('[name="product"]', { label: 'Laptop' });
        await page.fill('[name="quantity"]', '2');
        await page.click('button:has-text("Add to Order")');

        // Verify item in cart
        await expect(page.locator('.cart-items')).toContainText('Laptop x2');

        // 3. Submit Order
        await page.click('button:has-text("Submit Order")');

        // Wait for success message
        await expect(page.locator('.success-message')).toContainText('Order created successfully');

        // 4. Verify Order in List
        await page.click('text=My Orders');

        const orderRow = page.locator('.order-list tr').first();
        await expect(orderRow).toContainText('Laptop');
        await expect(orderRow).toContainText('Pending');

        // 5. Verify API was called correctly (network inspection)
        const orderRequest = await page.waitForResponse(
            response => response.url().includes('/api/orders') && response.request().method() === 'POST'
        );

        expect(orderRequest.status()).toBe(201);
        const orderData = await orderRequest.json();
        expect(orderData.id).toBeTruthy();
    });

    test('handles order creation failure gracefully', async ({ page }) => {
        // Mock API failure
        await page.route('/api/orders', route => {
            route.fulfill({
                status: 500,
                body: JSON.stringify({ error: 'Internal server error' })
            });
        });

        await page.click('text=Login');
        await page.fill('[name="email"]', 'test@example.com');
        await page.fill('[name="password"]', 'password123');
        await page.click('button:has-text("Sign In")');

        await page.click('button:has-text("New Order")');
        await page.selectOption('[name="product"]', { label: 'Laptop' });
        await page.click('button:has-text("Submit Order")');

        // Verify error handling
        await expect(page.locator('.error-message')).toContainText('Failed to create order');
        await expect(page.locator('.cart-items')).toBeVisible(); // Cart still visible
    });

    test('validates authentication redirect', async ({ page }) => {
        // Try to access protected route without login
        await page.goto('https://localhost:3000/orders');

        // Should redirect to login
        await expect(page).toHaveURL(/.*login/);
        await expect(page.locator('form')).toBeVisible();
    });
});

// Visual Regression Testing
test.describe('Visual Regression', () => {
    test('order page matches snapshot', async ({ page }) => {
        await page.goto('https://localhost:3000/orders');

        // Take screenshot and compare
        await expect(page).toHaveScreenshot('order-page.png', {
            fullPage: true,
            maxDiffPixels: 100 // Allow minor differences
        });
    });
});

// Performance Testing
test.describe('Performance', () => {
    test('page loads within acceptable time', async ({ page }) => {
        const startTime = Date.now();

        await page.goto('https://localhost:3000');
        await page.waitForLoadState('networkidle');

        const loadTime = Date.now() - startTime;

        expect(loadTime).toBeLessThan(3000); // 3 second threshold
    });
});

// Cross-Browser Testing (configured in playwright.config.ts)
// runs automatically on Chrome, Firefox, Safari
```

**E2E Test Configuration (playwright.config.ts):**
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
    testDir: './e2e',
    fullyParallel: true,
    forbidOnly: !!process.env.CI,
    retries: process.env.CI ? 2 : 0,
    workers: process.env.CI ? 1 : undefined,

    use: {
        baseURL: 'http://localhost:3000',
        trace: 'on-first-retry',
        screenshot: 'only-on-failure',
        video: 'retain-on-failure'
    },

    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
        {
            name: 'firefox',
            use: { ...devices['Desktop Firefox'] },
        },
        {
            name: 'webkit',
            use: { ...devices['Desktop Safari'] },
        },
        {
            name: 'Mobile Chrome',
            use: { ...devices['Pixel 5'] },
        },
    ],

    webServer: {
        command: 'npm run dev',
        url: 'http://localhost:3000',
        reuseExistingServer: !process.env.CI,
    },
});
```

**Tech Lead Decision: E2E Testing Strategy**
- **5-10% of tests**: Only critical user journeys
- **Run on PR**: Catch regressions before merge
- **Run nightly**: Full cross-browser suite
- **Cost**: Slow (2-5 min per test), but high confidence
- **Alternative**: Cypress for easier debugging, Playwright for better cross-browser support

---

## 7. Coverage vs Confidence

### The Coverage Trap

**Coverage is NOT Quality**

```csharp
// 100% code coverage, but terrible test
[Fact]
public void ProcessOrder_Test()
{
    var order = new Order();
    _sut.ProcessOrder(order); // This line is "covered"
    // No assertions! Test always passes
}

// Better: Lower coverage, higher confidence
[Theory]
[InlineData(OrderStatus.Pending, true)]
[InlineData(OrderStatus.Cancelled, false)]
[InlineData(OrderStatus.Completed, false)]
public void ProcessOrder_WithDifferentStatuses_ShouldValidateCorrectly(
    OrderStatus status, bool expectedCanProcess)
{
    // Arrange
    var order = new Order { Status = status };

    // Act
    var canProcess = _sut.CanProcessOrder(order);

    // Assert
    Assert.Equal(expectedCanProcess, canProcess);
}
```

### Mutation Testing

```csharp
// Original code
public decimal CalculateDiscount(decimal amount)
{
    if (amount > 100)
        return amount * 0.1m;
    return 0;
}

// This test has 100% coverage
[Fact]
public void CalculateDiscount_WithHighAmount_ReturnsDiscount()
{
    var discount = _sut.CalculateDiscount(150);
    Assert.True(discount > 0); // Too weak!
}

// Mutation testing would change > to >= or * to +
// A better test:
[Theory]
[InlineData(100, 0)]      // Boundary
[InlineData(100.01, 10)]  // Just over boundary
[InlineData(150, 15)]     // Normal case
public void CalculateDiscount_ShouldCalculateCorrectly(
    decimal amount, decimal expectedDiscount)
{
    var discount = _sut.CalculateDiscount(amount);
    Assert.Equal(expectedDiscount, discount);
}
```

### Metrics That Matter

1. **Defect Escape Rate**: Bugs found in production
2. **Test Execution Time**: Fast feedback loop
3. **Test Flakiness**: Percentage of intermittent failures
4. **Code Change Confidence**: Can you refactor safely?

---

## 8. What NOT to Test

### Don't Test Framework Code

```csharp
// BAD - Testing Entity Framework
[Fact]
public async Task DbContext_ShouldSaveEntity()
{
    var entity = new Order();
    _dbContext.Orders.Add(entity);
    await _dbContext.SaveChangesAsync();

    Assert.NotNull(await _dbContext.Orders.FindAsync(entity.Id));
}
// This tests EF Core, not your code!

// GOOD - Test your repository logic
[Fact]
public async Task SaveOrder_ShouldSetCreatedTimestamp()
{
    var order = new Order();
    await _repository.SaveAsync(order);

    var saved = await _repository.GetByIdAsync(order.Id);
    Assert.True(saved.CreatedAt > DateTime.UtcNow.AddSeconds(-5));
}
```

### Don't Test Private Methods

```csharp
// BAD - Using reflection to test private methods
[Fact]
public void PrivateMethod_ShouldDoSomething()
{
    var method = typeof(OrderService)
        .GetMethod("CalculateInternal", BindingFlags.NonPublic | BindingFlags.Instance);
    var result = method.Invoke(_sut, new object[] { 100 });
    Assert.Equal(110, result);
}

// GOOD - Test public behavior that uses the private method
[Fact]
public void ProcessOrder_ShouldApplyCorrectCalculation()
{
    var order = new Order { Subtotal = 100 };
    _sut.ProcessOrder(order);
    Assert.Equal(110, order.Total); // Private method is tested indirectly
}
```

### Don't Test External Services Directly

```csharp
// BAD - Testing against real Stripe API
[Fact]
public async Task Stripe_ShouldChargeCard()
{
    var stripeClient = new StripeClient("sk_test_real_key");
    var result = await stripeClient.ChargeAsync(100);
    Assert.True(result.Succeeded);
}
// Slow, costs money, can fail for many reasons

// GOOD - Test your adapter/wrapper
[Fact]
public async Task PaymentService_ShouldMapStripeResponse()
{
    var stripeMock = new Mock<IStripeClient>();
    stripeMock.Setup(x => x.ChargeAsync(100))
        .ReturnsAsync(new StripeCharge { Id = "ch_123", Status = "succeeded" });

    var service = new PaymentService(stripeMock.Object);
    var result = await service.ProcessPaymentAsync(100);

    Assert.Equal("ch_123", result.TransactionId);
    Assert.True(result.IsSuccessful);
}
```

---

## 9. Clear Testing Strategy

### Testing Strategy by Layer

```
┌─────────────────────────────────────────────┐
│ E2E Tests (5%)                              │
│ - Critical user journeys                    │
│ - Full system integration                   │
│ - Real browsers, databases, services        │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Integration Tests (15%)                     │
│ - API endpoints with real DB                │
│ - Repository with real database             │
│ - Message handlers with real queue          │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│ Unit Tests (80%)                            │
│ - Business logic                            │
│ - Domain models                             │
│ - Validators, mappers, utilities            │
└─────────────────────────────────────────────┘
```

### Example Strategy Document

```markdown
# Testing Strategy - Order Service

## Unit Tests (80% of tests)
- **Coverage Target**: 80% of business logic
- **Speed**: < 10 seconds for all unit tests
- **Tools**: xUnit, Moq, FluentAssertions
- **What to Test**:
  - Order validation logic
  - Price calculation
  - State transitions
  - Domain events
  - Business rules

## Integration Tests (15% of tests)
- **Coverage**: All API endpoints
- **Speed**: < 2 minutes
- **Tools**: WebApplicationFactory, Testcontainers
- **What to Test**:
  - Database operations
  - Message publishing
  - Authentication/Authorization
  - API contract adherence

## E2E Tests (5% of tests)
- **Coverage**: Critical paths only
- **Speed**: < 10 minutes
- **Tools**: Playwright, Docker Compose
- **What to Test**:
  - Create order → Payment → Fulfillment
  - User registration → First purchase
  - Return processing

## Performance Tests
- **Load Testing**: k6 or JMeter
- **Targets**:
  - P95 < 200ms for order creation
  - P99 < 500ms
  - Support 1000 req/sec

## Excluded from Testing
- Framework code (EF Core, ASP.NET)
- DTOs without logic
- Simple property getters/setters
- Third-party library wrappers (test our usage)
```

---

## 10. Common Interview Questions

### Q1: "How do you decide what to test?"

**Good Answer**:
"I follow the risk-based testing approach:

1. **High Risk, High Value**: Business-critical logic (payment processing, inventory management) - comprehensive unit tests with edge cases
2. **High Risk, Low Frequency**: Error handling, exceptional paths - targeted tests for each failure scenario
3. **Low Risk, High Frequency**: Simple CRUD operations - basic integration tests
4. **Infrastructure Code**: Repositories, HTTP clients - light integration tests to verify contract adherence

I focus on testing behavior, not implementation. If I can refactor without changing tests, that's a good sign. I avoid testing private methods or framework code."

### Q2: "How do you handle flaky tests?"

**Good Answer**:
"Flaky tests destroy confidence. I address them immediately:

1. **Identify Root Cause**:
   - Timing issues (race conditions, insufficient waits)
   - Shared state between tests
   - External dependencies (network, file system)
   - Non-deterministic code (random, DateTime.Now)

2. **Fix Strategies**:
   - Isolate tests completely (use test fixtures properly)
   - Use deterministic time (inject ISystemClock)
   - Avoid Thread.Sleep, use proper async/await
   - Use WaitUntil patterns for eventual consistency
   - Stub external dependencies

3. **If unfixable**: Quarantine the test, create a ticket, run it separately

Example fix:
```csharp
// Flaky - uses real time
[Fact]
public async Task Cache_ShouldExpireAfterOneMinute()
{
    _cache.Set("key", "value", TimeSpan.FromMinutes(1));
    await Task.Delay(61000); // 61 seconds
    Assert.Null(_cache.Get("key"));
}

// Fixed - inject time abstraction
[Fact]
public void Cache_ShouldExpireAfterOneMinute()
{
    var fakeClock = new FakeSystemClock();
    var cache = new Cache(fakeClock);

    cache.Set("key", "value", TimeSpan.FromMinutes(1));
    fakeClock.Advance(TimeSpan.FromMinutes(1).Add(TimeSpan.FromSeconds(1)));

    Assert.Null(cache.Get("key"));
}
```"

### Q3: "What's your approach to testing legacy code?"

**Good Answer**:
"Legacy code without tests requires a careful approach:

1. **Characterization Tests**: Write tests that describe current behavior, even if it's wrong
2. **Seam Identification**: Find where you can inject dependencies
3. **Sprout Method**: Add new functionality in a new, testable method
4. **Wrap Method**: Wrap existing code to add testability
5. **Refactor Gradually**: Make small changes under test coverage

Example:
```csharp
// Legacy code - hard to test
public class OrderProcessor
{
    public void Process(Order order)
    {
        var db = new SqlConnection(ConfigurationManager.ConnectionStrings["Default"]);
        db.Open();
        // 500 lines of spaghetti code
    }
}

// Step 1: Add seam
public class OrderProcessor
{
    protected virtual IDbConnection GetConnection()
    {
        return new SqlConnection(ConfigurationManager.ConnectionStrings["Default"]);
    }

    public void Process(Order order)
    {
        var db = GetConnection();
        db.Open();
        // 500 lines of spaghetti code
    }
}

// Now testable via inheritance
public class TestableOrderProcessor : OrderProcessor
{
    private readonly IDbConnection _connection;
    public TestableOrderProcessor(IDbConnection connection)
    {
        _connection = connection;
    }
    protected override IDbConnection GetConnection() => _connection;
}
```"

### Q4: "How do you test code that depends on DateTime.Now or random numbers?"

**Good Answer**:
```csharp
// Problem: Non-deterministic code
public class OrderService
{
    public Order CreateOrder()
    {
        return new Order
        {
            Id = Guid.NewGuid(), // Random!
            CreatedAt = DateTime.Now, // Time-dependent!
            OrderNumber = Random.Shared.Next(10000, 99999) // Random!
        };
    }
}

// Solution: Inject abstractions
public interface ISystemClock
{
    DateTime UtcNow { get; }
}

public interface IGuidGenerator
{
    Guid NewGuid();
}

public interface IOrderNumberGenerator
{
    string GenerateOrderNumber();
}

public class OrderService
{
    private readonly ISystemClock _clock;
    private readonly IGuidGenerator _guidGenerator;
    private readonly IOrderNumberGenerator _orderNumberGenerator;

    public OrderService(
        ISystemClock clock,
        IGuidGenerator guidGenerator,
        IOrderNumberGenerator orderNumberGenerator)
    {
        _clock = clock;
        _guidGenerator = guidGenerator;
        _orderNumberGenerator = orderNumberGenerator;
    }

    public Order CreateOrder()
    {
        return new Order
        {
            Id = _guidGenerator.NewGuid(),
            CreatedAt = _clock.UtcNow,
            OrderNumber = _orderNumberGenerator.GenerateOrderNumber()
        };
    }
}

// Now fully testable
[Fact]
public void CreateOrder_ShouldUseProvidedValues()
{
    var expectedId = Guid.Parse("12345678-1234-1234-1234-123456789012");
    var expectedTime = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);

    var clock = new FakeSystemClock { UtcNow = expectedTime };
    var guidGen = new FakeGuidGenerator { NextGuid = expectedId };
    var orderNumGen = new FakeOrderNumberGenerator { NextNumber = "ORD-001" };

    var service = new OrderService(clock, guidGen, orderNumGen);
    var order = service.CreateOrder();

    Assert.Equal(expectedId, order.Id);
    Assert.Equal(expectedTime, order.CreatedAt);
    Assert.Equal("ORD-001", order.OrderNumber);
}
```"

---

## 11. Anti-Patterns to Avoid

### 1. The Liar
Test that passes regardless of whether the code works.

```csharp
// BAD
[Fact]
public void ProcessOrder_ShouldWork()
{
    _sut.ProcessOrder(new Order());
    Assert.True(true); // Always passes!
}
```

### 2. The Slowpoke
Test that runs for seconds instead of milliseconds.

```csharp
// BAD
[Fact]
public async Task Cache_ShouldExpire()
{
    _cache.Set("key", "value", TimeSpan.FromMinutes(5));
    await Task.Delay(TimeSpan.FromMinutes(5)); // 5 minutes!
    Assert.Null(_cache.Get("key"));
}
```

### 3. The Giant
Test that tests too much.

```csharp
// BAD
[Fact]
public async Task CompleteOrderWorkflow_ShouldWork()
{
    // 200 lines testing everything from order creation to shipment
}

// GOOD - Split into focused tests
[Fact]
public async Task CreateOrder_WithValidData_ShouldSucceed() { }

[Fact]
public async Task ProcessPayment_WhenOrderCreated_ShouldCharge() { }

[Fact]
public async Task ShipOrder_WhenPaymentSuccessful_ShouldCreateShipment() { }
```

### 4. The Mockery
Over-mocking that tests nothing.

```csharp
// BAD - Mocking everything including the SUT!
[Fact]
public void Test()
{
    var mock = new Mock<OrderService>();
    mock.Setup(x => x.ProcessOrder(It.IsAny<Order>())).Returns(true);
    Assert.True(mock.Object.ProcessOrder(new Order()));
}
// You're just testing the mock!
```

---

## Summary

**Key Takeaways**:

1. **Test Pyramid**: Many unit tests, some integration tests, few E2E tests
2. **FIRST Principles**: Fast, Isolated, Repeatable, Self-validating, Timely
3. **Mocking vs Faking**: Mock for behavior verification, fake for lightweight state
4. **Testing Async**: Always use async/await, never rely on timing
5. **Contract Testing**: Test API boundaries without full integration
6. **Coverage ≠ Quality**: Focus on confidence and mutation coverage
7. **Don't Test**: Framework code, private methods, external services directly
8. **Strategy**: Risk-based approach, clear ownership, fast feedback

**Testing Philosophy**: Tests are not about reaching 100% coverage. They're about giving you confidence to refactor, catching regressions early, and documenting expected behavior. Good tests make you move faster, not slower.

