# Quick Interview Prep — Tomorrow's Topics
> **Date:** 2026-03-02 | **Format:** Lead Developer Level Q&A + Essential Code + Mental Models

---

## Table of Contents
1. [Terraform — IaC for Application Infrastructure](#1-terraform--iac-for-application-infrastructure)
2. [Unit & Integration Testing with xUnit](#2-unit--integration-testing-with-xunit)
3. [SQL — Core Interview Topics](#3-sql--core-interview-topics)
4. [Durable Task Library — Fan-out/in, Retries, Compensations](#4-durable-task-library--fan-outin-retries-compensations)
5. [Azure Container Apps](#5-azure-container-apps)
6. [.NET API — Lead Developer Level](#6-net-api--lead-developer-level)
7. [Webhooks — Design & Production Patterns](#7-webhooks--design--production-patterns)

---

## 1. Terraform — IaC for Application Infrastructure

```
┌─────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Terraform is a DECLARATIVE FLIGHT PLAN       │
│  You describe destination → Terraform figures out the route │
│  State file = current position of the plane                 │
└─────────────────────────────────────────────────────────────┘
```

### Core Workflow
```
terraform init      → Download providers & modules
terraform plan      → Diff: desired vs current state (DRY RUN)
terraform apply     → Execute the plan, update state
terraform destroy   → Tear down all managed resources
terraform fmt       → Format HCL files
terraform validate  → Syntax + logic check (no API calls)
```

### HCL Building Blocks
```hcl
# Provider — authenticates to Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"         # ~> allows PATCH bumps only
    }
  }
  backend "azurerm" {             # Remote state — ALWAYS use in production
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate001"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Variables — inputs to the module
variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus2"
  validation {
    condition     = contains(["eastus2", "westus2"], var.location)
    error_message = "Only approved regions allowed."
  }
}

# Resource — a managed infrastructure object
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-app"
  location = var.location
  tags     = local.common_tags
}

# Local — computed values, avoid repetition
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Team        = "Platform"
  }
}

# Data source — READ existing resources (not managed by this config)
data "azurerm_client_config" "current" {}

# Output — expose values for other modules or humans
output "resource_group_id" {
  value       = azurerm_resource_group.main.id
  description = "ID of the resource group"
}
```

### Modules Pattern
```hcl
# Root module calling a child module
module "app_service" {
  source = "./modules/app-service"       # local path

  # --- or from registry ---
  # source  = "Azure/app-service/azurerm"
  # version = "1.0.0"

  name                = "app-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_name            = "P1v3"
}

# Child module exposes outputs
output "app_url" {
  value = module.app_service.default_hostname
}
```

### State Management
```
┌─────────────────────────────────────────────────────────────┐
│  STATE = source of truth for what Terraform OWNS            │
│  Remote state = Azure Blob (team-safe, locking via lease)   │
│                                                             │
│  terraform state list          → list all resources         │
│  terraform state show <res>    → inspect one resource       │
│  terraform state rm <res>      → remove from state (orphan) │
│  terraform import <res> <id>   → adopt existing resource    │
│  terraform taint <res>         → force recreate on next apply│
└─────────────────────────────────────────────────────────────┘
```

### Key Interview Questions & Answers

**Q: What is the difference between `terraform plan` and `apply`?**
> `plan` generates an execution plan showing what WOULD change — no side effects. `apply` executes the plan and updates state. Always review plan output before apply in production.

**Q: How do you manage secrets in Terraform?**
> 1. Use Azure Key Vault + `data "azurerm_key_vault_secret"` — secret never in `.tf` files
> 2. Pass as env vars: `TF_VAR_db_password=...`
> 3. Mark output as `sensitive = true` to suppress in logs
> 4. **Never** store `.tfstate` locally if it contains secrets — use remote state with encryption

**Q: What is `terraform taint` / when do you use `lifecycle`?**
> `taint` forces a resource to be destroyed + recreated on next apply. `lifecycle` blocks control this declaratively:
```hcl
lifecycle {
  create_before_destroy = true   # zero-downtime replacement
  prevent_destroy       = true   # guard prod databases
  ignore_changes        = [tags] # ignore drift in specific attrs
}
```

**Q: Explain `depends_on` vs implicit dependency.**
> Terraform infers dependencies from attribute references: `resource_group_name = azurerm_resource_group.main.name` creates implicit dependency. Use explicit `depends_on` only when dependency isn't reflected in attributes (e.g., role assignment must exist before app starts).

**Q: What are Terraform workspaces?**
> Named state environments within one backend. `terraform workspace new staging` creates isolated state. Good for dev/staging/prod from same config. **Caveat:** complex configs often prefer separate directories or modules instead.

**Q: How do you handle breaking provider upgrades?**
> Pin versions with `~>`. Use `terraform providers lock` to generate `.terraform.lock.hcl`. Test upgrades in non-prod workspace first.

**Q: For-each vs count?**
```hcl
# count — positional (index), fragile with insertions
resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_names)
  name  = var.subnet_names[count.index]
}

# for_each — map/set keyed (stable, preferred for lists of objects)
resource "azurerm_subnet" "subnet" {
  for_each = toset(var.subnet_names)
  name     = each.value
}
```

**Q: How do you structure Terraform for a real app?**
```
infra/
├── modules/
│   ├── app-service/      # reusable child module
│   ├── sql-database/
│   └── container-app/
├── environments/
│   ├── dev/
│   │   ├── main.tf       # calls modules with dev vars
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       └── terraform.tfvars
└── shared/               # shared resources (networking, ACR)
```

---

## 2. Unit & Integration Testing with xUnit

```
┌─────────────────────────────────────────────────────────────┐
│  MENTAL MODEL:                                              │
│  Unit test   = test one gear in isolation (mock everything) │
│  Integration = test gears meshing (real DB/HTTP in-process) │
│  E2E         = test the whole machine (real environment)    │
└─────────────────────────────────────────────────────────────┘
```

### xUnit Core Attributes
```csharp
// [Fact] — no parameters, always runs
[Fact]
public void Add_TwoNumbers_ReturnsSum()
{
    var calc = new Calculator();
    var result = calc.Add(2, 3);
    Assert.Equal(5, result);
}

// [Theory] + [InlineData] — parameterized
[Theory]
[InlineData(2, 3, 5)]
[InlineData(-1, 1, 0)]
[InlineData(0, 0, 0)]
public void Add_Various_ReturnsSum(int a, int b, int expected)
{
    Assert.Equal(expected, new Calculator().Add(a, b));
}

// [MemberData] — data from property/method
public static IEnumerable<object[]> DivisionData =>
    new List<object[]>
    {
        new object[] { 10, 2, 5 },
        new object[] { 9, 3, 3 },
    };

[Theory]
[MemberData(nameof(DivisionData))]
public void Divide_ValidInputs_ReturnsQuotient(int a, int b, int expected)
    => Assert.Equal(expected, new Calculator().Divide(a, b));
```

### Fixtures — Shared Setup/Teardown
```csharp
// Class fixture — shared across tests IN ONE CLASS
public class DatabaseFixture : IDisposable
{
    public SqlConnection Connection { get; }

    public DatabaseFixture()
    {
        Connection = new SqlConnection("Server=(localdb)\\...");
        Connection.Open();
        // seed test data
    }

    public void Dispose() => Connection.Dispose();
}

public class OrderRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly DatabaseFixture _fixture;

    public OrderRepositoryTests(DatabaseFixture fixture)
        => _fixture = fixture;   // injected by xUnit

    [Fact]
    public async Task GetOrder_ExistingId_ReturnsOrder()
    {
        var repo = new OrderRepository(_fixture.Connection);
        var order = await repo.GetByIdAsync(1);
        Assert.NotNull(order);
    }
}

// Collection fixture — shared across MULTIPLE test classes
[CollectionDefinition("Database")]
public class DatabaseCollection : ICollectionFixture<DatabaseFixture> { }

[Collection("Database")]
public class InvoiceTests { /* ... */ }
```

### Mocking with Moq
```csharp
// Setup + Verify pattern
[Fact]
public async Task CreateOrder_ValidRequest_PublishesEvent()
{
    // Arrange
    var mockRepo = new Mock<IOrderRepository>();
    var mockBus  = new Mock<IMessageBus>();

    mockRepo.Setup(r => r.AddAsync(It.IsAny<Order>()))
            .ReturnsAsync(new Order { Id = 42 });

    var svc = new OrderService(mockRepo.Object, mockBus.Object);

    // Act
    await svc.CreateOrderAsync(new CreateOrderRequest { ... });

    // Assert
    mockBus.Verify(b => b.PublishAsync(
        It.Is<OrderCreatedEvent>(e => e.OrderId == 42)),
        Times.Once);    // exactly once — important!
}

// Throwing from mock
mockRepo.Setup(r => r.GetByIdAsync(99))
        .ThrowsAsync(new NotFoundException("Order not found"));

// Capture argument
var captured = new List<Order>();
mockRepo.Setup(r => r.AddAsync(It.IsAny<Order>()))
        .Callback<Order>(o => captured.Add(o))
        .ReturnsAsync((Order o) => o);
```

### Integration Tests — WebApplicationFactory
```csharp
// Full in-process HTTP integration test (no real server)
public class OrdersApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public OrdersApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    // Replace real DB with in-memory
                    services.RemoveAll<DbContextOptions<AppDbContext>>();
                    services.AddDbContext<AppDbContext>(o =>
                        o.UseInMemoryDatabase("TestDb"));

                    // Or replace with Testcontainers (real SQL in Docker)
                    // services.AddDbContext<AppDbContext>(o =>
                    //     o.UseSqlServer(_sqlContainer.ConnectionString));
                });
            })
            .CreateClient();
    }

    [Fact]
    public async Task GetOrders_ReturnsOk()
    {
        var response = await _client.GetAsync("/api/orders");
        response.EnsureSuccessStatusCode();
        var orders = await response.Content.ReadFromJsonAsync<List<OrderDto>>();
        Assert.NotNull(orders);
    }
}
```

### Testcontainers (Real Dependencies in Docker)
```csharp
public class SqlIntegrationTests : IAsyncLifetime
{
    private readonly MsSqlContainer _sqlContainer =
        new MsSqlBuilder()
            .WithPassword("Strong@Passw0rd!")
            .Build();

    public Task InitializeAsync() => _sqlContainer.StartAsync();
    public Task DisposeAsync()    => _sqlContainer.StopAsync();

    [Fact]
    public async Task Repository_Insert_CanRetrieve()
    {
        var connStr = _sqlContainer.GetConnectionString();
        // run migrations, seed, test
    }
}
```

### Assert Cheat Sheet
```csharp
Assert.Equal(expected, actual);
Assert.NotEqual(a, b);
Assert.True(condition);
Assert.False(condition);
Assert.Null(obj);
Assert.NotNull(obj);
Assert.Throws<ArgumentNullException>(() => method(null));
await Assert.ThrowsAsync<NotFoundException>(() => svc.GetAsync(99));
Assert.Contains(item, collection);
Assert.Empty(collection);
Assert.IsType<OrderDto>(result);
Assert.IsAssignableFrom<IEnumerable<OrderDto>>(result);
```

### Key Interview Q&A

**Q: Difference between xUnit, NUnit, MSTest?**
> xUnit: modern, no `[SetUp]`/`[TearDown]` (uses constructor/Dispose), parallel by default, preferred for .NET Core. NUnit: `[SetUp]`/`[TearDown]`, `[TestCase]`. MSTest: Microsoft built-in, slower, `[TestInitialize]`.

**Q: How do you test private methods?**
> You don't — test behavior through public API. If private logic is complex enough to test, extract it to a new class. `InternalsVisibleTo` for internal, but avoid testing implementation details.

**Q: What is AAA pattern?**
> **Arrange** (setup), **Act** (call SUT), **Assert** (verify output). Keeps tests readable and focused.

**Q: How do you test code that calls DateTime.Now?**
> Inject `IDateTimeProvider` or `TimeProvider` (built-in since .NET 8). Avoids time-dependent flaky tests.

**Q: How do you ensure test isolation?**
> No shared mutable state. Each test gets fresh instance (xUnit creates new class instance per test). Use `IClassFixture` only for read-only/expensive setup. Rollback DB transactions in teardown.

### Integration Testing & Testcontainers — Deep Dive

## 1. Mental Model: The Testing Spectrum

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE TESTING SPECTRUM                             │
│                                                                     │
│      /\           E2E Tests                                         │
│     /  \          • Real browser / real app / real infra            │
│    /    \         • Slowest (minutes), most fragile                 │
│   /──────\        • Use for: critical happy paths only              │
│  /        \                                                         │
│ / Integr.  \      Integration Tests  ← THIS GUIDE                  │
│/────────────\     • Real HTTP / real DB (via Testcontainers)        │
│              \    • Medium speed (seconds), mostly reliable         │
│   Unit Tests  \   • Use for: contracts, DB queries, API behavior    │
│────────────────\                                                    │
│                 \  • Fastest (ms), ultra-reliable                   │
│                  \ • Use for: business logic, algorithms            │
│                   \• Mock all external deps                         │
└─────────────────────────────────────────────────────────────────────┘

DECISION TREE:
Does the test need a DB / HTTP / broker?
  YES → Integration test (Testcontainers if real behavior matters)
  NO  → Unit test (mock everything)
Does it need a real browser / full deployment?
  YES → E2E test (Playwright, Cypress)
```

### The "Confidence vs Speed" Trade-off

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  UNIT TEST                INTEGRATION TEST           E2E        │
│                                                                 │
│  mock.Setup(r =>          real SQL Server            real app   │
│    r.GetUser(1))          real HTTP stack            real UI    │
│  .Returns(fakeUser)       real EF Core               real flow  │
│                                                                 │
│  Fast: ~1ms               Medium: ~2-10s             Slow: 30s+ │
│  Isolation: perfect       Isolation: good            Poor       │
│  Confidence: low          Confidence: HIGH           Highest    │
│  (mocks lie!)             (real behavior)                       │
│                                                                 │
│  KEY INSIGHT: "My mock said it works" ≠ "It actually works"    │
│  Integration tests catch what unit tests miss:                  │
│  • SQL query mistakes (wrong JOIN, missing index)              │
│  • EF Core mapping bugs (wrong column name)                    │
│  • Serialization mismatches (JSON property casing)             │
│  • Auth middleware ordering issues                              │
│  • Middleware pipeline bugs                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. What Integration Tests Actually Are

### Scope Options

```
NARROW INTEGRATION TEST:
  Test a single class against a real DB
  ┌──────────────┐      ┌──────────────────┐
  │  OrderRepo   │─────▶│  SQL Server       │
  │  (your class)│      │  (Testcontainers) │
  └──────────────┘      └──────────────────┘
  No HTTP layer. Just: does the SQL work?

BROAD INTEGRATION TEST (most common):
  Test the full HTTP stack against real deps
  ┌─────────┐  HTTP  ┌─────────────┐  EF Core  ┌──────────┐
  │HttpClient│──────▶│ ASP.NET Core│──────────▶│SQL Server│
  │(test)   │        │ (in-process)│           │(TC)      │
  └─────────┘        └─────────────┘           └──────────┘
  Tests: routing, middleware, validation, auth, DB, serialization

COMPONENT TEST:
  Whole service with all deps containerized
  Used in: microservices testing, contract testing
```

### What to Integration Test

```
✓ TEST THESE:
  • Repository / data access layer SQL queries
  • API endpoints (status codes, response shapes, validation errors)
  • Authentication / authorization (401, 403 behaviors)
  • EF Core migrations (schema actually matches model)
  • Message consumer behavior (process a real message)
  • Cache interactions (Redis SET/GET/TTL)
  • Complex query correctness (pagination, filtering, sorting)

✗ DON'T INTEGRATION TEST THESE (use unit tests):
  • Pure business logic / calculations
  • Domain rules that don't touch external systems
  • Error handling within a service class
  • Mapping / transformation logic
```

---

## 3. WebApplicationFactory — Testing the Full HTTP Stack

**Mental Model**: WebApplicationFactory boots your ASP.NET Core app **in-process** (no real TCP port), gives you an `HttpClient` that talks directly to the in-memory pipeline. No network latency. Real middleware. Real DI container.

```
WITHOUT WebApplicationFactory:
  Test → real network → kestrel → your app → DB
         (need running server)

WITH WebApplicationFactory:
  Test → TestServer (in-process) → your app pipeline → DB
         (no network, boots in test process)
```

### Level 1: Basic Setup

```csharp
// NuGet: Microsoft.AspNetCore.Mvc.Testing

// Your API project must have:
// <Project Sdk="Microsoft.NET.Sdk.Web">
// and Program.cs must be accessible:
// public partial class Program { }  // at the bottom of Program.cs

public class BasicApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public BasicApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task HealthCheck_Returns200()
    {
        var response = await _client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task GetOrders_Unauthenticated_Returns401()
    {
        var response = await _client.GetAsync("/api/orders");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
```

### Level 2: Replacing Services (Override DI)

```csharp
public class OrdersApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public OrdersApiTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    private HttpClient CreateClientWithOverrides(Action<IServiceCollection> configureServices)
    {
        return _factory
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    configureServices(services);
                });
            })
            .CreateClient();
    }

    [Fact]
    public async Task GetOrders_WithInMemoryDb_ReturnsOrders()
    {
        var client = CreateClientWithOverrides(services =>
        {
            // Remove real DB
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
            if (descriptor != null) services.Remove(descriptor);

            // Add in-memory DB (fast but limited — see section 4)
            services.AddDbContext<AppDbContext>(options =>
                options.UseInMemoryDatabase("TestDb_" + Guid.NewGuid()));

            // Seed test data
            var sp = services.BuildServiceProvider();
            using var scope = sp.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            db.Orders.AddRange(new Order { Id = 1, Amount = 100 });
            db.SaveChanges();
        });

        var response = await client.GetAsync("/api/orders");
        response.EnsureSuccessStatusCode();
    }
}
```

### Level 3: Custom WebApplicationFactory (Recommended Pattern)

```csharp
// Create a reusable custom factory — the STANDARD production pattern
public class CustomWebAppFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    // Testcontainers (covered in section 6) go here
    private readonly MsSqlContainer _sqlContainer = new MsSqlBuilder()
        .WithPassword("Strong@Passw0rd!")
        .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
        .Build();

    // Called BEFORE tests run
    public async Task InitializeAsync()
    {
        await _sqlContainer.StartAsync();
    }

    // Called AFTER all tests run
    public async Task DisposeAsync()
    {
        await _sqlContainer.DisposeAsync();
    }

    // Override the app configuration for tests
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // 1. Remove real DB registration
            services.RemoveAll<DbContextOptions<AppDbContext>>();
            services.RemoveAll<AppDbContext>();

            // 2. Point to Testcontainer SQL Server
            services.AddDbContext<AppDbContext>(options =>
                options.UseSqlServer(_sqlContainer.GetConnectionString()));

            // 3. Run EF migrations on test DB
            var sp = services.BuildServiceProvider();
            using var scope = sp.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            db.Database.Migrate();   // creates real schema!
        });

        // Set environment to Test (can be used in app to skip certain startup)
        builder.UseEnvironment("Testing");
    }
}

// Tests use the custom factory
public class OrdersApiTests : IClassFixture<CustomWebAppFactory>
{
    private readonly HttpClient _client;
    private readonly CustomWebAppFactory _factory;

    public OrdersApiTests(CustomWebAppFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false,   // catch 302s explicitly
            HandleCookies = true
        });
    }

    [Fact]
    public async Task CreateOrder_ValidRequest_Returns201WithLocation()
    {
        var request = new { Amount = 250.00m, CustomerId = 1 };

        var response = await _client.PostAsJsonAsync("/api/orders", request);

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        Assert.NotNull(response.Headers.Location);   // check Location header
    }
}
```

---

## 4. The Problem with Fakes (InMemory DB)

```
┌─────────────────────────────────────────────────────────────────┐
│  EF Core InMemoryDatabase — LOOKS like a DB, ISN'T one         │
│                                                                 │
│  What it DOES:                                                  │
│  ✓ Stores entities in memory                                    │
│  ✓ Basic LINQ queries work                                       │
│  ✓ Fast (no Docker needed)                                       │
│                                                                 │
│  What it DOESN'T do:                                            │
│  ✗ SQL constraints (unique, foreign key, check constraints)     │
│  ✗ Transactions / rollback                                       │
│  ✗ Raw SQL queries (FromSqlRaw, ExecuteSqlRaw)                  │
│  ✗ Stored procedures, views, functions                           │
│  ✗ DB-specific features (JSON columns, hierarchyid, sequences)  │
│  ✗ Cascade delete behavior                                       │
│  ✗ Concurrency handling                                          │
│                                                                 │
│  WHEN TO USE InMemory:                                          │
│  ✓ Smoke tests / pure logic tests touching DB-like API          │
│  ✓ When you KNOW you won't use raw SQL or constraints           │
│                                                                 │
│  WHEN TO USE Testcontainers (real DB):                          │
│  ✓ Any time you run migrations                                   │
│  ✓ Any time you use raw SQL / stored procs                      │
│  ✓ When testing DB constraints matter                            │
│  ✓ Production-confidence tests                                   │
└─────────────────────────────────────────────────────────────────┘
```

### SQLite — The Middle Ground

```csharp
// SQLite is a real relational DB, runs in-process, no Docker needed
// Better than InMemory for most cases, cheaper than Testcontainers

services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite("DataSource=:memory:"));   // in-memory SQLite

// OR file-based (persists across tests):
options.UseSqlite($"DataSource={Path.GetTempFileName()}");

// Limitations vs SQL Server:
// ✗ No schema (dbo.), no identity seed behavior
// ✗ Limited JSON support, no TVPs
// ✗ Different datetime handling
// USE WHEN: you want real SQL but can't use Docker (restricted CI)
```

### Decision Matrix

```
┌──────────────────┬──────────┬────────────┬───────────────┬──────────────────┐
│                  │ InMemory │   SQLite   │ Testcontainers│  Real DB (CI env)│
├──────────────────┼──────────┼────────────┼───────────────┼──────────────────┤
│ Speed            │ Fastest  │ Fast       │ 2-10s startup │ Fast (reuse)     │
│ SQL Accuracy     │ None     │ Partial    │ EXACT         │ EXACT            │
│ Constraints      │ No       │ Yes        │ Yes           │ Yes              │
│ Raw SQL          │ No       │ Yes        │ Yes           │ Yes              │
│ Docker required  │ No       │ No         │ Yes           │ No               │
│ Isolation        │ Perfect  │ Good       │ Perfect       │ Shared (risky)   │
│ CI friendliness  │ Always   │ Always     │ Need Docker   │ Need env setup   │
└──────────────────┴──────────┴────────────┴───────────────┴──────────────────┘
```

---

## 5. Testcontainers — How It Works

**Mental Model**: Testcontainers is a .NET library that talks to your local **Docker daemon** via socket. It pulls images, starts containers, waits for them to be ready, gives you a connection string, and kills them when tests end. All automated.

```
┌──────────────────────────────────────────────────────────────────┐
│                HOW TESTCONTAINERS WORKS                          │
│                                                                  │
│  Test Code                                                       │
│  ┌─────────────────────┐                                         │
│  │ new MsSqlBuilder()  │                                         │
│  │   .WithPassword()   │                                         │
│  │   .Build()          │──────┐                                  │
│  │ container.Start()   │      │ Docker API calls                 │
│  └─────────────────────┘      │ (via /var/run/docker.sock)       │
│                               ▼                                  │
│                    ┌─────────────────────┐                       │
│                    │   Docker Daemon     │                        │
│                    │                    │                        │
│                    │  1. Pull image      │                        │
│                    │  2. Create container│                        │
│                    │  3. Start container │                        │
│                    │  4. Expose ports   │                        │
│                    └──────────┬──────────┘                       │
│                               │                                  │
│                    ┌──────────▼──────────┐                       │
│                    │  SQL Server         │                        │
│                    │  127.0.0.1:XXXXX    │◀── random host port   │
│                    │  (mapped to 1433    │    (avoids conflicts)  │
│                    │   inside container) │                        │
│                    └─────────────────────┘                       │
│                                                                  │
│  container.GetConnectionString()                                 │
│  → "Server=127.0.0.1,XXXXX;User Id=sa;Password=...;..."         │
│                                                                  │
│  After tests: container.StopAsync() → container destroyed        │
└──────────────────────────────────────────────────────────────────┘

REQUIREMENTS:
  • Docker Desktop (Windows/Mac) or Docker Engine (Linux)
  • Docker socket accessible: /var/run/docker.sock (Linux/Mac)
                              npipe:////./pipe/docker_engine (Windows)
  • Internet access to pull images (first run only — cached after)
```

### NuGet Package Structure

```
Testcontainers (base)              → core Docker interaction
Testcontainers.MsSql               → SQL Server specific builder
Testcontainers.PostgreSql           → PostgreSQL specific builder
Testcontainers.Redis                → Redis specific builder
Testcontainers.RabbitMq             → RabbitMQ specific builder
Testcontainers.Kafka                → Kafka specific builder
Testcontainers.MongoDb              → MongoDB specific builder
Testcontainers.Azurite              → Azure Storage emulator
Testcontainers.LocalStack           → AWS services emulator
```

```xml
<!-- In your test project .csproj -->
<ItemGroup>
  <PackageReference Include="Testcontainers.MsSql" Version="3.9.0" />
  <PackageReference Include="Testcontainers.PostgreSql" Version="3.9.0" />
  <PackageReference Include="Testcontainers.Redis" Version="3.9.0" />
  <PackageReference Include="Testcontainers.RabbitMq" Version="3.9.0" />
  <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="8.0.0" />
  <PackageReference Include="Respawn" Version="6.2.1" />   <!-- DB reset -->
</ItemGroup>
```

---

## 6. Core Containers: SQL, Postgres, Redis, RabbitMQ

### SQL Server Container

```csharp
// Builder pattern — configure before starting
private readonly MsSqlContainer _sqlContainer = new MsSqlBuilder()
    .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
    .WithPassword("Strong@Passw0rd!")    // must meet SQL Server complexity rules
    .WithEnvironment("ACCEPT_EULA", "Y") // included automatically by builder
    .WithPortBinding(1433, true)         // true = random host port (default)
    .WithWaitStrategy(                   // wait until container is READY
        Wait.ForUnixContainer()
            .UntilPortIsAvailable(1433))
    .Build();

// Usage
await _sqlContainer.StartAsync();

string connStr = _sqlContainer.GetConnectionString();
// → "Server=127.0.0.1,54321;Database=master;User Id=sa;Password=Strong@Passw0rd!;..."

// Always stop after tests
await _sqlContainer.StopAsync();   // or DisposeAsync()
```

### PostgreSQL Container

```csharp
private readonly PostgreSqlContainer _pgContainer = new PostgreSqlBuilder()
    .WithImage("postgres:16-alpine")    // alpine = smaller image
    .WithDatabase("testdb")
    .WithUsername("testuser")
    .WithPassword("testpass")
    .Build();

await _pgContainer.StartAsync();

string connStr = _pgContainer.GetConnectionString();
// → "Host=127.0.0.1;Port=XXXXX;Database=testdb;Username=testuser;Password=testpass"

// With Npgsql:
services.AddDbContext<AppDbContext>(o => o.UseNpgsql(connStr));
```

### Redis Container

```csharp
private readonly RedisContainer _redisContainer = new RedisBuilder()
    .WithImage("redis:7-alpine")
    .Build();

await _redisContainer.StartAsync();

string connStr = _redisContainer.GetConnectionString();
// → "127.0.0.1:XXXXX"

// With StackExchange.Redis:
var connection = await ConnectionMultiplexer.ConnectAsync(connStr);

// With Microsoft.Extensions.Caching.StackExchangeRedis:
services.AddStackExchangeRedisCache(options =>
    options.Configuration = connStr);
```

### RabbitMQ Container

```csharp
private readonly RabbitMqContainer _rabbitContainer = new RabbitMqBuilder()
    .WithImage("rabbitmq:3-management-alpine")
    .WithUsername("guest")
    .WithPassword("guest")
    .Build();

await _rabbitContainer.StartAsync();

string connStr = _rabbitContainer.GetConnectionString();
// → "amqp://guest:guest@127.0.0.1:XXXXX/"

// With MassTransit:
services.AddMassTransitTestHarness(x =>
{
    x.UsingRabbitMq((ctx, cfg) =>
    {
        cfg.Host(connStr);
        cfg.ConfigureEndpoints(ctx);
    });
});
```

### Custom / Generic Container

```csharp
// For anything without a specific builder — use ContainerBuilder
private readonly IContainer _wiremockContainer = new ContainerBuilder()
    .WithImage("wiremock/wiremock:latest")
    .WithPortBinding(8080, true)
    .WithCommand("--port", "8080", "--verbose")
    .WithWaitStrategy(
        Wait.ForUnixContainer()
            .UntilHttpRequestIsSucceeded(r => r.ForPath("/__admin/mappings").ForPort(8080)))
    .WithBindMount(Path.Combine(Directory.GetCurrentDirectory(), "wiremock"), "/home/wiremock")
    .Build();

string wiremockUrl = $"http://localhost:{_wiremockContainer.GetMappedPublicPort(8080)}";
```

---

## 7. Lifecycle Management: IAsyncLifetime

**Mental Model**: `IAsyncLifetime` is xUnit's hook to run async setup/teardown. Like a constructor/Dispose but async.

```
Test class lifecycle with IAsyncLifetime:

  InitializeAsync()    ← runs BEFORE first test in class
       ↓
  [Fact] Test1()
       ↓
  [Fact] Test2()
       ↓
  DisposeAsync()       ← runs AFTER last test in class
```

### Pattern A: Container per Test Class (Simple)

```csharp
// Each test CLASS gets its own container
// Pros: perfect isolation   Cons: slow (starts N containers for N test classes)

public class OrderRepositoryTests : IAsyncLifetime
{
    private readonly MsSqlContainer _sqlContainer = new MsSqlBuilder()
        .WithPassword("Strong@Passw0rd!")
        .Build();

    private AppDbContext _db = null!;
    private string _connStr = null!;

    // Runs once before all [Fact]s in this class
    public async Task InitializeAsync()
    {
        await _sqlContainer.StartAsync();
        _connStr = _sqlContainer.GetConnectionString();

        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(_connStr)
            .Options;

        _db = new AppDbContext(options);
        await _db.Database.MigrateAsync();   // apply migrations
        await SeedAsync(_db);                // seed test data
    }

    // Runs once after all [Fact]s in this class
    public async Task DisposeAsync()
    {
        await _db.DisposeAsync();
        await _sqlContainer.DisposeAsync();
    }

    [Fact]
    public async Task GetOrderById_ExistingId_ReturnsOrder()
    {
        var repo = new OrderRepository(_db);
        var order = await repo.GetByIdAsync(1);

        Assert.NotNull(order);
        Assert.Equal(1, order.Id);
    }

    [Fact]
    public async Task GetOrderById_MissingId_ReturnsNull()
    {
        var repo = new OrderRepository(_db);
        var order = await repo.GetByIdAsync(9999);

        Assert.Null(order);
    }

    private async Task SeedAsync(AppDbContext db)
    {
        db.Orders.AddRange(
            new Order { Id = 1, Amount = 100, CustomerId = 1 },
            new Order { Id = 2, Amount = 200, CustomerId = 1 }
        );
        await db.SaveChangesAsync();
    }
}
```

---

## 8. Shared Containers: Collection Fixtures

**Mental Model**: Starting a SQL Server container takes 3-8 seconds. If you have 10 test classes, that's 30-80 seconds wasted. **Collection fixtures** share ONE container across ALL test classes in a collection.

```
WITHOUT Collection Fixture:         WITH Collection Fixture:
  TestClass A → start container       One container starts ONCE
  TestClass A tests run (3s start)    ┌──────────────────────┐
  TestClass A → stop container        │  SharedDatabaseFixture│
                                      │  (one SQL container)  │
  TestClass B → start container       └─────────┬────────────┘
  TestClass B tests run (3s start)              │
  TestClass B → stop container          ┌───────┴────────┐
                                    TestA     TestB    TestC
  Total: 6s startup overhead        (all share same container)

  Total: 3s startup (once!)
```

### Step 1: Create the Shared Fixture

```csharp
// SharedDatabaseFixture.cs
public class SharedDatabaseFixture : IAsyncLifetime
{
    // ONE container for ALL test classes in the collection
    public MsSqlContainer SqlContainer { get; } = new MsSqlBuilder()
        .WithPassword("Strong@Passw0rd!")
        .Build();

    public string ConnectionString => SqlContainer.GetConnectionString();

    public async Task InitializeAsync()
    {
        await SqlContainer.StartAsync();

        // Run migrations ONCE on the shared container
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(ConnectionString)
            .Options;
        using var db = new AppDbContext(options);
        await db.Database.MigrateAsync();
    }

    public async Task DisposeAsync()
    {
        await SqlContainer.DisposeAsync();
    }
}
```

### Step 2: Register the Collection

```csharp
// CollectionDefinition.cs
// This file just declares the collection — no logic needed
[CollectionDefinition("Database")]
public class DatabaseCollection : ICollectionFixture<SharedDatabaseFixture>
{
    // xUnit uses this class as a marker — leave it empty
}
```

### Step 3: Use in Multiple Test Classes

```csharp
[Collection("Database")]   // ← must match CollectionDefinition name
public class OrderRepositoryTests
{
    private readonly SharedDatabaseFixture _fixture;

    public OrderRepositoryTests(SharedDatabaseFixture fixture)
    {
        _fixture = fixture;   // SAME instance across all [Collection("Database")] classes
    }

    [Fact]
    public async Task CreateOrder_PersistsToDb()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(_fixture.ConnectionString)
            .Options;

        using var db = new AppDbContext(options);
        // IMPORTANT: clean DB before each test (see section 9)
        await db.Orders.ExecuteDeleteAsync();

        db.Orders.Add(new Order { Amount = 100 });
        await db.SaveChangesAsync();

        Assert.Equal(1, await db.Orders.CountAsync());
    }
}

[Collection("Database")]   // shares the SAME container
public class CustomerRepositoryTests
{
    private readonly SharedDatabaseFixture _fixture;

    public CustomerRepositoryTests(SharedDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task GetAllCustomers_ReturnsSeededData()
    {
        // container already running — no startup delay here!
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(_fixture.ConnectionString)
            .Options;
        using var db = new AppDbContext(options);
        // ...
    }
}
```

---

## 9. Database Reset Strategies

**The Problem**: Tests share a DB container but must NOT share data. Test A's inserted rows must be invisible to Test B.

```
┌──────────────────────────────────────────────────────────────┐
│              DATABASE RESET OPTIONS                          │
│                                                              │
│  1. RESPAWN (best for integration tests)                     │
│     Deletes all data between tests via smart DELETE          │
│     Respects FK order. Fast (~50ms). No recreation needed.   │
│                                                              │
│  2. TRANSACTION ROLLBACK                                     │
│     Wrap each test in a transaction, rollback at end         │
│     Fast but: doesn't work with parallel tests or            │
│     code that uses its own transactions                       │
│                                                              │
│  3. DROP & RECREATE DATABASE                                 │
│     Drop DB, recreate, run migrations                        │
│     Slowest (2-5s per test). Guaranteed clean state.        │
│     Use only if Respawn doesn't fit                          │
│                                                              │
│  4. EF CORE DELETERANGE                                      │
│     db.Orders.ExecuteDeleteAsync() per table                 │
│     Fast but: you must know all tables & correct order       │
│                                                              │
│  RECOMMENDATION: Use Respawn for shared containers           │
└──────────────────────────────────────────────────────────────┘
```

### Strategy 1: Respawn (Recommended)

```csharp
// NuGet: Respawn

public class SharedDatabaseFixture : IAsyncLifetime
{
    public MsSqlContainer SqlContainer { get; } = new MsSqlBuilder()
        .WithPassword("Strong@Passw0rd!")
        .Build();

    private Respawner _respawner = null!;

    public async Task InitializeAsync()
    {
        await SqlContainer.StartAsync();

        // Run migrations
        using var db = CreateDbContext();
        await db.Database.MigrateAsync();

        // Configure Respawner AFTER migrations (needs schema to exist)
        await using var conn = new SqlConnection(SqlContainer.GetConnectionString());
        await conn.OpenAsync();

        _respawner = await Respawner.CreateAsync(conn, new RespawnerOptions
        {
            TablesToIgnore = new[] { new Table("__EFMigrationsHistory") },
            DbAdapter = DbAdapter.SqlServer
        });
    }

    // Call this at the start of each test or in a base class
    public async Task ResetDatabaseAsync()
    {
        await using var conn = new SqlConnection(SqlContainer.GetConnectionString());
        await conn.OpenAsync();
        await _respawner.ResetAsync(conn);
    }

    public AppDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer(SqlContainer.GetConnectionString())
            .Options;
        return new AppDbContext(options);
    }

    public async Task DisposeAsync()
    {
        await SqlContainer.DisposeAsync();
    }
}

// Usage in test class — reset before each test
[Collection("Database")]
public class OrderTests : IAsyncLifetime
{
    private readonly SharedDatabaseFixture _fixture;

    public OrderTests(SharedDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    // Reset DB before THIS test class's tests
    public async Task InitializeAsync() => await _fixture.ResetDatabaseAsync();
    public Task DisposeAsync() => Task.CompletedTask;

    [Fact]
    public async Task Test_StartsWith_CleanDatabase()
    {
        using var db = _fixture.CreateDbContext();
        // DB is guaranteed empty (Respawn wiped it)
        Assert.Equal(0, await db.Orders.CountAsync());
    }
}
```

### Strategy 2: Transaction Rollback

```csharp
// Wrap each test in a transaction, rollback at end
// Works well for repository-level tests where you control the connection

public class OrderRepositoryTests : IAsyncLifetime
{
    private readonly SharedDatabaseFixture _fixture;
    private SqlConnection _connection = null!;
    private SqlTransaction _transaction = null!;

    public OrderRepositoryTests(SharedDatabaseFixture fixture) => _fixture = fixture;

    public async Task InitializeAsync()
    {
        _connection = new SqlConnection(_fixture.ConnectionString);
        await _connection.OpenAsync();
        _transaction = _connection.BeginTransaction();    // start before each test
    }

    public async Task DisposeAsync()
    {
        await _transaction.RollbackAsync();    // ROLLBACK — nothing committed!
        await _connection.DisposeAsync();
    }

    [Fact]
    public async Task Insert_ThenRollback_LeavesNoTrace()
    {
        // This INSERT will be ROLLED BACK in DisposeAsync
        var cmd = new SqlCommand(
            "INSERT INTO Orders (Amount) VALUES (100)", _connection, _transaction);
        await cmd.ExecuteNonQueryAsync();

        // Verify it's there within THIS transaction
        var countCmd = new SqlCommand(
            "SELECT COUNT(*) FROM Orders", _connection, _transaction);
        var count = (int)await countCmd.ExecuteScalarAsync();
        Assert.Equal(1, count);

        // After test: DisposeAsync rolls back → DB unchanged for next test
    }
}
```

---

## 10. WebApplicationFactory + Testcontainers Combined

This is the **production-standard pattern** — full HTTP integration tests with a real DB.

```
HTTP Request Flow in Integration Test:

  [Fact] test code
     ↓
  HttpClient (in-process)
     ↓
  ASP.NET Core Pipeline
  (middleware, routing, auth, filters)
     ↓
  Controller / Endpoint Handler
     ↓
  Service Layer
     ↓
  Repository / EF Core
     ↓
  SQL Server (Testcontainer)
     ↓
  response back up the chain
```

### The Complete Pattern

```csharp
// IntegrationTestFactory.cs
public class IntegrationTestFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    // All containers declared here
    private readonly MsSqlContainer _sqlContainer = new MsSqlBuilder()
        .WithPassword("Strong@Passw0rd!")
        .Build();

    private readonly RedisContainer _redisContainer = new RedisBuilder()
        .WithImage("redis:7-alpine")
        .Build();

    private Respawner _respawner = null!;

    public async Task InitializeAsync()
    {
        // Start containers in PARALLEL — saves time
        await Task.WhenAll(
            _sqlContainer.StartAsync(),
            _redisContainer.StartAsync()
        );

        // Run migrations (after containers are up)
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.MigrateAsync();

        // Setup Respawner
        await using var conn = new SqlConnection(_sqlContainer.GetConnectionString());
        await conn.OpenAsync();
        _respawner = await Respawner.CreateAsync(conn, new RespawnerOptions
        {
            TablesToIgnore = new[] { new Table("__EFMigrationsHistory") },
            DbAdapter = DbAdapter.SqlServer
        });
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Replace SQL Server
            services.RemoveAll<DbContextOptions<AppDbContext>>();
            services.AddDbContext<AppDbContext>(o =>
                o.UseSqlServer(_sqlContainer.GetConnectionString()));

            // Replace Redis
            services.RemoveAll<IConnectionMultiplexer>();
            services.AddSingleton<IConnectionMultiplexer>(_ =>
                ConnectionMultiplexer.Connect(_redisContainer.GetConnectionString()));

            // Replace external HTTP clients with fakes
            services.RemoveAll<IExternalPaymentService>();
            services.AddSingleton<IExternalPaymentService, FakePaymentService>();
        });

        builder.UseEnvironment("Testing");
    }

    public async Task ResetDatabaseAsync()
    {
        await using var conn = new SqlConnection(_sqlContainer.GetConnectionString());
        await conn.OpenAsync();
        await _respawner.ResetAsync(conn);
    }

    public new async Task DisposeAsync()
    {
        await _sqlContainer.DisposeAsync();
        await _redisContainer.DisposeAsync();
    }
}

// CollectionDefinition.cs
[CollectionDefinition("Integration")]
public class IntegrationCollection : ICollectionFixture<IntegrationTestFactory> { }

// Base test class to avoid boilerplate
public abstract class IntegrationTestBase : IAsyncLifetime
{
    protected readonly IntegrationTestFactory Factory;
    protected readonly HttpClient Client;

    protected IntegrationTestBase(IntegrationTestFactory factory)
    {
        Factory = factory;
        Client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
    }

    // Reset DB before each test class's tests run
    public async Task InitializeAsync() => await Factory.ResetDatabaseAsync();
    public Task DisposeAsync() => Task.CompletedTask;

    // Helper: seed data
    protected async Task SeedAsync(Func<AppDbContext, Task> seedAction)
    {
        using var scope = Factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await seedAction(db);
        await db.SaveChangesAsync();
    }
}

// Actual test class — clean and minimal
[Collection("Integration")]
public class OrdersApiTests : IntegrationTestBase
{
    public OrdersApiTests(IntegrationTestFactory factory) : base(factory) { }

    [Fact]
    public async Task GetOrder_ExistingId_Returns200WithOrder()
    {
        // Arrange — seed specific data for this test
        await SeedAsync(async db =>
        {
            db.Orders.Add(new Order { Id = 1, Amount = 100, Status = "Pending" });
        });

        // Act
        var response = await Client.GetAsync("/api/orders/1");

        // Assert
        response.EnsureSuccessStatusCode();
        var order = await response.Content.ReadFromJsonAsync<OrderDto>();
        Assert.Equal(1, order!.Id);
        Assert.Equal(100, order.Amount);
    }

    [Fact]
    public async Task CreateOrder_InvalidAmount_Returns400()
    {
        var body = new { Amount = -1 };  // negative amount

        var response = await Client.PostAsJsonAsync("/api/orders", body);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var problem = await response.Content.ReadFromJsonAsync<ProblemDetails>();
        Assert.Contains("Amount", problem!.Extensions.Keys);
    }

    [Fact]
    public async Task GetOrder_NotFound_Returns404()
    {
        var response = await Client.GetAsync("/api/orders/9999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }
}
```

---

## 11. Advanced Patterns

### Pattern A: Bypass Authentication in Tests

```csharp
// Option 1: TestAuthHandler — fake auth that always succeeds
public class TestAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public TestAuthHandler(IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger, UrlEncoder encoder) : base(options, logger, encoder) { }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.Name, "testuser"),
            new Claim(ClaimTypes.NameIdentifier, "user-123"),
            new Claim(ClaimTypes.Role, "Admin"),
            new Claim("tenant_id", "tenant-abc"),
        };
        var identity = new ClaimsIdentity(claims, "TestScheme");
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, "TestScheme");
        return Task.FromResult(AuthenticateResult.Success(ticket));
    }
}

// Register in ConfigureWebHost:
builder.ConfigureServices(services =>
{
    services.AddAuthentication("TestScheme")
        .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>("TestScheme", _ => { });
});

// Option 2: Use JWT — generate real token in test
private string GenerateTestToken(string userId, string role = "User")
{
    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("test-secret-key-min-32-chars!!"));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
    var token = new JwtSecurityToken(
        claims: new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userId),
            new Claim(ClaimTypes.Role, role)
        },
        expires: DateTime.UtcNow.AddHours(1),
        signingCredentials: creds);
    return new JwtSecurityTokenHandler().WriteToken(token);
}

// Usage:
Client.DefaultRequestHeaders.Authorization =
    new AuthenticationHeaderValue("Bearer", GenerateTestToken("user-123", "Admin"));
```

### Pattern B: Test Data Builders

```csharp
// Fluent builder for creating test data — avoids bloated [Fact] methods
public class OrderBuilder
{
    private int _id = 1;
    private decimal _amount = 100m;
    private string _status = "Pending";
    private int _customerId = 1;
    private DateTime _createdAt = DateTime.UtcNow;

    public OrderBuilder WithId(int id) { _id = id; return this; }
    public OrderBuilder WithAmount(decimal amount) { _amount = amount; return this; }
    public OrderBuilder WithStatus(string status) { _status = status; return this; }
    public OrderBuilder WithCustomer(int customerId) { _customerId = customerId; return this; }
    public OrderBuilder CreatedDaysAgo(int days) { _createdAt = DateTime.UtcNow.AddDays(-days); return this; }

    public Order Build() => new Order
    {
        Id = _id,
        Amount = _amount,
        Status = _status,
        CustomerId = _customerId,
        CreatedAt = _createdAt
    };

    public static OrderBuilder AnOrder() => new();
}

// Usage in tests — reads like a sentence
[Fact]
public async Task GetExpiredOrders_ReturnsOnlyOldPendingOrders()
{
    await SeedAsync(async db =>
    {
        db.Orders.AddRange(
            OrderBuilder.AnOrder().WithId(1).WithStatus("Pending").CreatedDaysAgo(30).Build(),
            OrderBuilder.AnOrder().WithId(2).WithStatus("Pending").CreatedDaysAgo(2).Build(),  // recent
            OrderBuilder.AnOrder().WithId(3).WithStatus("Completed").CreatedDaysAgo(30).Build() // completed
        );
    });

    var response = await Client.GetAsync("/api/orders/expired");
    var orders = await response.Content.ReadFromJsonAsync<List<OrderDto>>();

    // Only Order 1 is old AND pending
    Assert.Single(orders!);
    Assert.Equal(1, orders![0].Id);
}
```

### Pattern C: WireMock for External HTTP Dependencies

```csharp
// NuGet: WireMock.Net

public class IntegrationTestFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    // WireMock server replaces external payment API
    private WireMockServer _wireMock = null!;

    public async Task InitializeAsync()
    {
        _wireMock = WireMockServer.Start();  // random port

        // Stub: successful payment
        _wireMock
            .Given(Request.Create()
                .WithPath("/payments/charge")
                .UsingPost())
            .RespondWith(Response.Create()
                .WithStatusCode(200)
                .WithBodyAsJson(new { transactionId = "txn-123", status = "Success" }));

        // Stub: payment failure for specific amount
        _wireMock
            .Given(Request.Create()
                .WithPath("/payments/charge")
                .UsingPost()
                .WithBody(new JsonPathMatcher("$.amount", "0")))
            .RespondWith(Response.Create()
                .WithStatusCode(400)
                .WithBodyAsJson(new { error = "Invalid amount" }));
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Point HttpClient at WireMock
            services.AddHttpClient<IPaymentGateway, PaymentGateway>(client =>
                client.BaseAddress = new Uri(_wireMock.Url!));
        });
    }

    public new async Task DisposeAsync()
    {
        _wireMock.Stop();
        _wireMock.Dispose();
    }
}

// Test verifies WireMock was called
[Fact]
public async Task CreateOrder_ValidPayment_CompletesOrder()
{
    var response = await Client.PostAsJsonAsync("/api/orders", new { Amount = 100 });

    Assert.Equal(HttpStatusCode.Created, response.StatusCode);

    // Verify external API was actually called
    var calls = Factory.WireMock.LogEntries
        .Where(e => e.RequestMessage.Path == "/payments/charge")
        .ToList();
    Assert.Single(calls);
}
```

---

## 12. Testing Event-Driven Systems

### Testing RabbitMQ Consumers

```csharp
// Test that publishing a message triggers the right behavior
[Collection("Integration")]
public class OrderCreatedConsumerTests : IntegrationTestBase
{
    public OrderCreatedConsumerTests(IntegrationTestFactory factory) : base(factory) { }

    [Fact]
    public async Task OrderCreated_Event_TriggersInventoryReduction()
    {
        // Arrange — seed inventory
        await SeedAsync(async db =>
        {
            db.Products.Add(new Product { Id = 1, Stock = 100 });
        });

        // Act — publish event directly (via MassTransit test harness)
        using var scope = Factory.Services.CreateScope();
        var harness = scope.ServiceProvider.GetRequiredService<ITestHarness>();
        await harness.Start();

        await harness.Bus.Publish(new OrderCreatedEvent
        {
            OrderId = Guid.NewGuid(),
            ProductId = 1,
            Quantity = 5
        });

        // Assert — wait for consumer to process (with timeout)
        var consumed = await harness.Consumed.Any<OrderCreatedEvent>(
            x => x.Context.Message.ProductId == 1,
            timeout: TimeSpan.FromSeconds(5));

        Assert.True(consumed);

        // Verify DB side effect
        using var db = Factory.CreateDbContext();
        var product = await db.Products.FindAsync(1);
        Assert.Equal(95, product!.Stock);   // 100 - 5
    }
}

// MassTransit Test Harness setup in factory
builder.ConfigureServices(services =>
{
    services.AddMassTransitTestHarness(x =>
    {
        x.AddConsumer<OrderCreatedConsumer>();
        x.UsingRabbitMq((ctx, cfg) =>
        {
            cfg.Host(_rabbitContainer.GetConnectionString());
            cfg.ConfigureEndpoints(ctx);
        });
    });
});
```

### Testing with Outbox Pattern

```csharp
[Fact]
public async Task CreateOrder_PublishesOutboxMessage()
{
    // Act — create order via API
    var response = await Client.PostAsJsonAsync("/api/orders",
        new { Amount = 100, CustomerId = 1 });
    response.EnsureSuccessStatusCode();

    // Assert — check outbox table has the message
    using var scope = Factory.Services.CreateScope();
    using var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

    var outboxMsg = await db.OutboxMessages
        .OrderByDescending(m => m.CreatedAt)
        .FirstOrDefaultAsync();

    Assert.NotNull(outboxMsg);
    Assert.Equal("OrderCreated", outboxMsg!.MessageType);
    Assert.False(outboxMsg.ProcessedAt.HasValue);   // not yet sent
}
```

---

## 13. CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/integration-tests.yml
name: Integration Tests

on: [push, pull_request]

jobs:
  integration-tests:
    runs-on: ubuntu-latest   # Linux runners have Docker built-in

    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Verify Docker is running
        run: docker info           # Testcontainers needs this

      - name: Run integration tests
        run: dotnet test tests/IntegrationTests/
             --configuration Release
             --logger "trx;LogFileName=results.trx"
             --results-directory ./test-results

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: ./test-results/*.trx

# NOTE: docker.sock is available on ubuntu-latest runners automatically
# Windows runners also support Docker (windows containers or Linux via WSL2)
```

### Azure DevOps

```yaml
# azure-pipelines.yml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'   # has Docker

steps:
  - task: UseDotNet@2
    inputs:
      version: '8.x'

  - script: docker info
    displayName: 'Verify Docker'

  - task: DotNetCoreCLI@2
    displayName: 'Integration Tests'
    inputs:
      command: 'test'
      projects: 'tests/IntegrationTests/*.csproj'
      arguments: '--configuration Release --collect:"XPlat Code Coverage"'

  - task: PublishTestResults@2
    inputs:
      testResultsFormat: 'VSTest'
      testResultsFiles: '**/*.trx'
```

### Testcontainers Cloud (No Docker Required)

```csharp
// For restricted CI environments without Docker:
// Testcontainers Cloud runs containers remotely

// Set environment variable: TC_CLOUD_TOKEN=your-token
// Testcontainers automatically detects and uses cloud

// No code changes needed — same API, containers run in TC cloud
```

### Ryuk (Reaper Container) — Auto Cleanup

```
Testcontainers automatically starts a "Ryuk" container alongside yours.
Ryuk monitors for test process death and kills all test containers —
even if your test crashes or you kill the process.

  Your test crashes mid-run?
  → Ryuk detects process death → kills SQL container → no zombie containers

  Disable Ryuk (not recommended):
  Environment variable: TESTCONTAINERS_RYUK_DISABLED=true
```

---

## 14. Anti-Patterns & Gotchas

```
┌───────────────────────────────────────────────────────────────────┐
│                    ANTI-PATTERNS                                  │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. SHARED MUTABLE STATE                                          │
│     Bad:  Tests insert rows without cleanup                       │
│            → Test B fails because Test A's data is still there   │
│     Fix:  Respawn before each test class                          │
│                                                                   │
│  2. CONTAINER PER [FACT]                                          │
│     Bad:  Start/stop a container inside each [Fact]              │
│            → 100 tests × 5s startup = 500s test run              │
│     Fix:  Use IClassFixture or Collection fixture                 │
│                                                                   │
│  3. TESTING IMPLEMENTATION DETAILS                                │
│     Bad:  Assert that OrderRepository.GetById called SQL JOIN     │
│     Fix:  Assert the returned Order has correct fields            │
│            (test behavior, not internals)                         │
│                                                                   │
│  4. USING PRODUCTION CONNECTION STRINGS                           │
│     Bad:  Integration tests hitting a shared dev/staging DB       │
│            → Pollutes shared DB, tests interfere with each other  │
│     Fix:  Always Testcontainers (isolated per test run)           │
│                                                                   │
│  5. NOT AWAITING CONTAINER READINESS                              │
│     Bad:  _container.StartAsync() then immediately connect        │
│            → Connection refused because DB not yet accepting      │
│     Fix:  Testcontainers' WaitStrategy handles this automatically │
│            (it waits until port is accepting connections)         │
│                                                                   │
│  6. PARALLEL TESTS WITH SHARED DB (NO RESET)                     │
│     Bad:  xUnit runs tests in parallel → DB state corrupted      │
│     Fix:  Use [assembly: CollectionBehavior(DisableTestParallelization=true)]│
│            OR use Respawn to reset between each test             │
│                                                                   │
│  7. EMBEDDING BUSINESS LOGIC IN TESTS                             │
│     Bad:  Test calculates expected total itself                   │
│     Fix:  Use hardcoded expected values — test catches regressions│
│                                                                   │
│  8. NOT TESTING UNHAPPY PATHS                                     │
│     Bad:  Only testing 200 OK                                     │
│     Fix:  Test 400, 401, 403, 404, 409, 500 responses            │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

### Common Gotchas

```csharp
// GOTCHA 1: Program.cs must be accessible from test project
// Add to bottom of Program.cs:
public partial class Program { }   // makes class visible to WebApplicationFactory<Program>

// GOTCHA 2: MsSqlContainer password must meet complexity rules
// At least 8 chars, uppercase, lowercase, digit, special char
.WithPassword("Strong@Passw0rd!")   // ✓
.WithPassword("password")           // ✗ SQL Server rejects this

// GOTCHA 3: EF Core migrations run on the test DB, not InMemory
// InMemory doesn't support migrations — always use a real DB container
await db.Database.MigrateAsync();   // runs all pending migrations

// GOTCHA 4: Parallel test execution can corrupt shared DB
// Disable parallelism at assembly level in a file:
// tests/IntegrationTests/AssemblyInfo.cs
[assembly: CollectionBehavior(DisableTestParallelization = true)]

// Or per-collection:
[CollectionDefinition("Integration", DisableParallelization = true)]

// GOTCHA 5: Container startup takes time — use WaitStrategy
new MsSqlBuilder()
    .WithWaitStrategy(Wait.ForUnixContainer().UntilPortIsAvailable(1433))
    .Build();
// Without this: GetConnectionString() may give a port that's not accepting connections yet

// GOTCHA 6: Respawn must be initialized AFTER migrations run
// (it reads schema from DB to know which tables to truncate)
await db.Database.MigrateAsync();         // ← first
_respawner = await Respawner.CreateAsync(conn, options);  // ← after

// GOTCHA 7: HttpClient created by factory is in-process (no real port)
// Don't use CreateClient() URLs like "http://localhost:5000"
var client = factory.CreateClient();  // ✓ in-process
// client.BaseAddress is set automatically to the test server address
```

---

## 15. Expert-Level Q&A

**Q: When would you NOT use Testcontainers?**
> - Tests run on machines without Docker (some corporate environments, some CI)
> - You need millisecond-fast test suites and business logic doesn't hit real SQL
> - Testing a pure domain layer — no external deps — unit tests are fine
> - You're using SQLite/InMemory intentionally for smoke tests

**Q: How do you handle database migrations in integration tests?**
> Call `db.Database.MigrateAsync()` in the fixture's `InitializeAsync()`. This runs EF Core migrations against the container's DB, creating the real schema. This is better than `EnsureCreated()` because it validates migration files work correctly — a real production concern.

**Q: What's the difference between IClassFixture and ICollectionFixture?**
> `IClassFixture<T>`: one instance per test class, not shared across classes. `ICollectionFixture<T>`: one instance shared across ALL classes in the collection. For expensive resources like DB containers, use `ICollectionFixture` so you start only one container for many test classes.

**Q: How do you test that a 401 is returned for unauthenticated requests?**
> Create the `HttpClient` without setting auth headers, hit the protected endpoint, assert `HttpStatusCode.Unauthorized`. In the `TestAuthHandler` setup, don't register it for those specific tests — or create a second `CreateClient()` without auth headers.

**Q: How do you test race conditions / concurrency?**
> Spin up multiple `HttpClient`s (or `Task.WhenAll` multiple requests), then verify DB state is consistent. Example: two requests both try to buy the last item — only one should succeed, DB stock should be 0 not -1.

**Q: What's Respawn and how does it differ from truncating tables?**
> Respawn (`Respawn` NuGet) deletes all data in the correct order respecting foreign key constraints. It queries `INFORMATION_SCHEMA` to build the delete order automatically. Plain `TRUNCATE` fails if FK constraints exist. `DELETE` in wrong order fails too. Respawn handles all of this automatically.

**Q: How do you test async background jobs (Hangfire, hosted services)?**
> For `IHostedService`: trigger the processing manually in the test by calling the method directly (if you inject the service from DI). For Hangfire: use Hangfire's test server or trigger jobs synchronously. For `BackgroundService`: expose the processing logic as a public/internal method and call it directly.

**Q: What about Docker-in-Docker for CI?**
> GitHub Actions `ubuntu-latest` runners have Docker natively — no DinD needed. Azure DevOps hosted agents (`ubuntu-latest`) also have Docker. Testcontainers detects the Docker socket automatically. For self-hosted agents, ensure Docker is installed.

**Q: How do you test EF Core optimistic concurrency?**
> Seed an entity, fetch it in two separate DbContext instances, update one and save (succeeds), update the other and save — expect `DbUpdateConcurrencyException`. Integration test proves the concurrency token (rowversion/timestamp) is correctly configured.

**Q: Testcontainers vs docker-compose for integration tests?**
> Testcontainers: containers start/stop in code, no external files, works in any environment with Docker, perfect isolation per test run. docker-compose: requires separate file, manual start/stop, containers can be reused across runs (faster repeated runs but risk of state contamination). For CI: prefer Testcontainers for isolation. For local dev with many services: docker-compose pre-started can be faster.

---

## Quick Setup Checklist

```
NEW INTEGRATION TEST PROJECT SETUP:

□ 1. Create xUnit test project
     dotnet new xunit -n MyApp.IntegrationTests

□ 2. Add NuGet packages
     Testcontainers.MsSql (or Postgres, Redis, etc.)
     Microsoft.AspNetCore.Mvc.Testing
     Respawn
     Microsoft.NET.Test.Sdk
     coverlet.collector

□ 3. Reference your API project
     <ProjectReference Include="../MyApp.Api/MyApp.Api.csproj" />

□ 4. Add to API's Program.cs
     public partial class Program { }

□ 5. Create IntegrationTestFactory.cs
     • Extends WebApplicationFactory<Program>, IAsyncLifetime
     • Declare Testcontainers
     • Override ConfigureWebHost to replace services

□ 6. Create CollectionDefinition.cs
     [CollectionDefinition("Integration")]
     public class IntegrationCollection : ICollectionFixture<IntegrationTestFactory> {}

□ 7. Create base test class (IntegrationTestBase)
     • Holds HttpClient
     • Calls ResetDatabaseAsync() in InitializeAsync

□ 8. Write first test
     [Collection("Integration")]
     public class MyFirstTest : IntegrationTestBase { ... }

□ 9. Disable parallelism (if using shared DB)
     [assembly: CollectionBehavior(DisableTestParallelization = true)]

□ 10. Run: dotnet test --configuration Release
```

---

## 3. SQL — Core Interview Topics

```
┌─────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: SQL is set-based algebra, not loops          │
│  Think in SETS of rows, not row-by-row iteration            │
└─────────────────────────────────────────────────────────────┘
```

### Sample Data Used Throughout This Section

**Customers**

| Id | Name   |
|----|--------|
| 1  | Alice  |
| 2  | Bob    |
| 3  | Carol  |

**Orders**

| Id | CustomerId | OrderDate  | TotalAmount | Status   |
|----|-----------|------------|-------------|----------|
| 1  | 1         | 2025-01-10 | 500.00      | Shipped  |
| 2  | 1         | 2025-03-15 | 1200.00     | Pending  |
| 3  | 1         | 2025-06-20 | 300.00      | Shipped  |
| 4  | 2         | 2025-02-05 | 8500.00     | Shipped  |
| 5  | 2         | 2025-05-18 | 3200.00     | Pending  |
| 6  | NULL      | 2025-04-01 | 750.00      | Pending  |

**Employees** *(for recursive CTE)*

| Id | Name    | ManagerId |
|----|---------|-----------|
| 1  | CEO     | NULL      |
| 2  | VP Eng  | 1         |
| 3  | VP Sales| 1         |
| 4  | Dev Lead| 2         |
| 5  | Dev1    | 4         |
| 6  | Dev2    | 4         |

---

### Joins — Visual Reference
```
INNER JOIN   → only matching rows on both sides
LEFT JOIN    → all left + matching right (NULL if no match)
RIGHT JOIN   → all right + matching left
FULL OUTER   → all rows from both, NULL where no match
CROSS JOIN   → cartesian product (every combo)
SELF JOIN    → table joined to itself (hierarchy/pairs)
```

**INNER JOIN** — customers who have orders:
```sql
SELECT o.Id, c.Name, o.TotalAmount
FROM Orders o
INNER JOIN Customers c ON o.CustomerId = c.Id;
```

| Id | Name  | TotalAmount |
|----|-------|-------------|
| 1  | Alice | 500.00      |
| 2  | Alice | 1200.00     |
| 3  | Alice | 300.00      |
| 4  | Bob   | 8500.00     |
| 5  | Bob   | 3200.00     |

> Carol has no orders → excluded. Order 6 has NULL CustomerId → excluded.

**LEFT JOIN + orphan filter** — orders with NO matching customer:
```sql
SELECT o.Id, c.Name
FROM Orders o
LEFT JOIN Customers c ON o.CustomerId = c.Id
WHERE c.Id IS NULL;
```

| Id | Name |
|----|------|
| 6  | NULL |

> Order 6 has `CustomerId = NULL` → no customer match → only row returned.

**FULL OUTER JOIN** — all orders and all customers, nulls where no match:
```sql
SELECT o.Id AS OrderId, c.Name AS Customer
FROM Orders o
FULL OUTER JOIN Customers c ON o.CustomerId = c.Id;
```

| OrderId | Customer |
|---------|----------|
| 1       | Alice    |
| 2       | Alice    |
| 3       | Alice    |
| 4       | Bob      |
| 5       | Bob      |
| 6       | NULL     |
| NULL    | Carol    |

> Carol row appears with NULL OrderId — customer exists but has no orders.

---

### Indexes
```sql
-- Clustered: physical order of table rows (1 per table, usually PK)
CREATE CLUSTERED INDEX IX_Orders_Id ON Orders(Id);

-- Non-clustered: separate B-tree with pointer to row
CREATE NONCLUSTERED INDEX IX_Orders_CustomerId
ON Orders(CustomerId)
INCLUDE (OrderDate, TotalAmount);   -- covering index: avoids key lookup

-- Filtered index: partial index (selective)
CREATE NONCLUSTERED INDEX IX_Orders_Pending
ON Orders(CustomerId)
WHERE Status = 'Pending';           -- only indexes pending rows
```

**Q: When does an index HURT performance?**
> INSERT/UPDATE/DELETE must maintain all indexes. High write tables: fewer indexes. Wide indexes with many INCLUDE cols waste space. Low-cardinality columns (bool, gender) rarely benefit.

**Q: What is index seek vs scan?**
> **Seek**: navigates B-tree directly to matching rows — O(log n). **Scan**: reads entire index — O(n). Use seek for high-cardinality lookups. Scans are fine for small tables or when fetching >15-20% of rows.

---

### Window Functions — Key Pattern

```sql
SELECT
    Id          AS OrderId,
    CustomerId,
    OrderDate,
    TotalAmount,
    ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY OrderDate DESC)  AS rn,
    RANK()       OVER (PARTITION BY CustomerId ORDER BY TotalAmount DESC) AS rnk,
    SUM(TotalAmount) OVER (PARTITION BY CustomerId)                      AS CustomerTotal,
    LAG(TotalAmount, 1) OVER (PARTITION BY CustomerId ORDER BY OrderDate) AS PrevOrderAmt
FROM Orders
WHERE CustomerId IS NOT NULL;
```

**Output:**

| OrderId | CustomerId | OrderDate  | TotalAmount | rn | rnk | CustomerTotal | PrevOrderAmt |
|---------|-----------|------------|-------------|----|----|---------------|--------------|
| 3       | 1         | 2025-06-20 | 300.00      | 1  | 3  | 2000.00       | 1200.00      |
| 2       | 1         | 2025-03-15 | 1200.00     | 2  | 1  | 2000.00       | 500.00       |
| 1       | 1         | 2025-01-10 | 500.00      | 3  | 2  | 2000.00       | NULL         |
| 5       | 2         | 2025-05-18 | 3200.00     | 1  | 2  | 11700.00      | 8500.00      |
| 4       | 2         | 2025-02-05 | 8500.00     | 2  | 1  | 11700.00      | NULL         |

> **Key observations:**
> - `rn` resets per customer (PARTITION BY CustomerId) — row 1 is most recent order per partition
> - `rnk` is by TotalAmount DESC — Bob's $8500 order gets rank 1 within his partition
> - `CustomerTotal` is the same for all rows in the same partition (Alice = 2000, Bob = 11700)
> - `PrevOrderAmt` for the earliest order per customer is NULL (no prior row in window)

**Get LATEST order per customer** — classic interview pattern:
```sql
WITH RankedOrders AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY OrderDate DESC) AS rn
    FROM Orders
    WHERE CustomerId IS NOT NULL
)
SELECT OrderId, CustomerId, OrderDate, TotalAmount
FROM RankedOrders
WHERE rn = 1;
```

**Output:**

| OrderId | CustomerId | OrderDate  | TotalAmount |
|---------|-----------|------------|-------------|
| 3       | 1         | 2025-06-20 | 300.00      |
| 5       | 2         | 2025-05-18 | 3200.00     |

> Only 1 row per customer — the most recent by `OrderDate`. Carol excluded (no orders).

**RANK vs DENSE_RANK vs ROW_NUMBER** — when TotalAmount ties:

```sql
-- Suppose two orders both have TotalAmount = 500
-- OrderId 1: Alice, 500   OrderId 7: Alice, 500
SELECT OrderId, TotalAmount,
    ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY TotalAmount) AS row_num,
    RANK()       OVER (PARTITION BY CustomerId ORDER BY TotalAmount) AS rnk,
    DENSE_RANK() OVER (PARTITION BY CustomerId ORDER BY TotalAmount) AS dense_rnk
FROM Orders WHERE CustomerId = 1;
```

| OrderId | TotalAmount | row_num | rnk | dense_rnk |
|---------|-------------|---------|-----|-----------|
| 1       | 500.00      | 1       | 1   | 1         |
| 7       | 500.00      | 2       | 1   | 1         |
| 2       | 1200.00     | 3       | 3   | 2         |

> `ROW_NUMBER`: always unique (arbitrary tiebreak). `RANK`: ties share rank, skips next (1,1,3). `DENSE_RANK`: ties share rank, no skip (1,1,2).

---

### CTEs & Recursive CTEs

**Simple CTE** — high-value customers (total orders > $5,000):
```sql
WITH HighValueOrders AS (
    SELECT CustomerId, SUM(TotalAmount) AS Total
    FROM Orders
    GROUP BY CustomerId
    HAVING SUM(TotalAmount) > 5000
)
SELECT c.Name, h.Total
FROM Customers c
JOIN HighValueOrders h ON c.Id = h.CustomerId;
```

**Output:**

| Name | Total    |
|------|----------|
| Bob  | 11700.00 |

> Alice's total = 2000 (below threshold). Bob = 11700 → qualifies. Carol has no orders → excluded.

**Recursive CTE** — org chart hierarchy:
```sql
WITH OrgChart AS (
    -- Anchor: root (no manager)
    SELECT Id, Name, ManagerId, 0 AS Level
    FROM Employees
    WHERE ManagerId IS NULL

    UNION ALL

    -- Recursive: each employee reporting to already-found employees
    SELECT e.Id, e.Name, e.ManagerId, oc.Level + 1
    FROM Employees e
    JOIN OrgChart oc ON e.ManagerId = oc.Id
)
SELECT Id, Name, ManagerId, Level
FROM OrgChart
ORDER BY Level, Name;
```

**Output:**

| Id | Name     | ManagerId | Level |
|----|----------|-----------|-------|
| 1  | CEO      | NULL      | 0     |
| 2  | VP Eng   | 1         | 1     |
| 3  | VP Sales | 1         | 1     |
| 4  | Dev Lead | 2         | 2     |
| 5  | Dev1     | 4         | 3     |
| 6  | Dev2     | 4         | 3     |

> Anchor fires once (CEO). Recursion fires 3 more times expanding level by level until no new rows match.

---

### Transactions & Isolation Levels
```sql
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE Accounts SET Balance -= 100 WHERE Id = 1;
    UPDATE Accounts SET Balance += 100 WHERE Id = 2;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;   -- re-raise original error
END CATCH;

-- Isolation levels (READ UNCOMMITTED → SERIALIZABLE)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;   -- default SQL Server
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;          -- optimistic, avoids locks
```

**Before transaction:**

| Id | Balance  |
|----|---------|
| 1  | 1000.00 |
| 2  | 500.00  |

**After COMMIT:**

| Id | Balance  |
|----|---------|
| 1  | 900.00  |
| 2  | 600.00  |

**After ROLLBACK** (if UPDATE 2 fails):

| Id | Balance  |
|----|---------|
| 1  | 1000.00 |
| 2  | 500.00  |

> Atomicity: both updates succeed or neither persists.

**Q: ACID properties?**
> **A**tomicity: all or nothing. **C**onsistency: DB moves from valid state to valid state. **I**solation: concurrent txns don't see each other's partial work. **D**urability: committed data survives crash.

**Q: Dirty read / Phantom read?**
> Dirty read: reading uncommitted data (READ UNCOMMITTED). Non-repeatable read: same row read twice gives different values. Phantom read: same range query gives different row count. SNAPSHOT isolation prevents these without heavy locking.

**Isolation Level Comparison:**

| Level            | Dirty Read | Non-Repeatable | Phantom | Notes                        |
|------------------|-----------|----------------|---------|------------------------------|
| READ UNCOMMITTED | ✅ possible | ✅ possible   | ✅ possible | Fastest, no locks          |
| READ COMMITTED   | ❌ blocked  | ✅ possible   | ✅ possible | SQL Server default          |
| REPEATABLE READ  | ❌          | ❌ blocked    | ✅ possible | Locks rows read             |
| SERIALIZABLE     | ❌          | ❌            | ❌ blocked  | Locks ranges, slowest       |
| SNAPSHOT         | ❌          | ❌            | ❌ blocked  | Optimistic, row versioning  |

---

### Stored Procedures vs Inline SQL

```sql
CREATE OR ALTER PROCEDURE usp_GetCustomerOrders
    @CustomerId INT,
    @FromDate   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;   -- suppress "X rows affected" messages

    SELECT o.Id, o.OrderDate, o.TotalAmount
    FROM Orders o
    WHERE o.CustomerId = @CustomerId
      AND (@FromDate IS NULL OR o.OrderDate >= @FromDate)
    ORDER BY o.OrderDate DESC;
END;

-- EXEC usp_GetCustomerOrders @CustomerId = 1, @FromDate = '2025-02-01';
```

**Output** (`@CustomerId = 1, @FromDate = '2025-02-01'`):

| Id | OrderDate  | TotalAmount |
|----|------------|-------------|
| 3  | 2025-06-20 | 300.00      |
| 2  | 2025-03-15 | 1200.00     |

> Order 1 (2025-01-10) excluded because it's before `@FromDate = 2025-02-01`.

---

### Normalization Quick Reference
```
1NF: Atomic columns, no repeating groups
2NF: 1NF + no partial dependency on composite PK
3NF: 2NF + no transitive dependency (non-key depends on non-key)
BCNF: stricter 3NF
```

**Denormalization example — pre-computed aggregate:**

| OrderId | CustomerId | CustomerName | TotalAmount | CustomerTotal |
|---------|-----------|-------------|-------------|---------------|
| 1       | 1         | Alice       | 500.00      | 2000.00       |
| 2       | 1         | Alice       | 1200.00     | 2000.00       |

> `CustomerTotal` violates 3NF (transitive: depends on CustomerId, not PK=OrderId). Acceptable in read-heavy reporting tables.

**Q: When do you DENORMALIZE?**
> Read-heavy reporting, analytics, data warehouses (star schema). When JOIN cost > storage cost. Pre-computed aggregates (totals, counts on wide tables).

---

### Performance Q&A

**Q: Query is slow — what do you check?**
> 1. `SET STATISTICS IO, TIME ON` — check logical reads
> 2. Execution plan (Estimated vs Actual) — look for scans, key lookups, sorts
> 3. Missing index hints in plan
> 4. Parameter sniffing (`OPTION (RECOMPILE)` or `OPTIMIZE FOR`)
> 5. Statistics out of date (`UPDATE STATISTICS`)

**`SET STATISTICS IO ON` sample output:**
```
Table 'Orders'. Scan count 1, logical reads 847, physical reads 0
-- 847 logical reads = 847 x 8KB pages read from buffer cache
-- High number → missing index or full scan → investigate execution plan
```

**Q: What is a covering index?**
> Index that satisfies the query without touching the base table. Include all columns needed by SELECT + WHERE in the index (using `INCLUDE`).

**Covering index example:**
```sql
-- Query: find pending orders for a customer, show date and amount
SELECT OrderDate, TotalAmount
FROM Orders
WHERE CustomerId = 2 AND Status = 'Pending';

-- WITHOUT covering index: index seek on CustomerId → key lookup for OrderDate, TotalAmount
-- WITH covering index: single seek, no table touch
CREATE NONCLUSTERED INDEX IX_Orders_Cust_Status
ON Orders (CustomerId, Status)
INCLUDE (OrderDate, TotalAmount);   -- all SELECT columns included
```

**Execution plan difference:**

| Without Covering Index | With Covering Index |
|----------------------|---------------------|
| Index Seek (50%) + Key Lookup (50%) | Index Seek (100%) |
| 2 operators, 2 I/Os | 1 operator, 1 I/O |

**Q: UNION vs UNION ALL?**
```sql
-- UNION deduplicates
SELECT CustomerId FROM Orders WHERE TotalAmount > 1000
UNION
SELECT CustomerId FROM Orders WHERE Status = 'Pending';
```

| CustomerId |
|-----------|
| 1         |
| 2         |

> Bob (CustomerId=2) appears in both sets but is returned once. Sort + dedup cost applied.

```sql
-- UNION ALL keeps all rows including duplicates
SELECT CustomerId FROM Orders WHERE TotalAmount > 1000
UNION ALL
SELECT CustomerId FROM Orders WHERE Status = 'Pending';
```

| CustomerId |
|-----------|
| 1         |
| 2         |
| 1         |
| 2         |

> Bob appears twice. No sort/dedup — always prefer `UNION ALL` unless deduplication is explicitly required.

---

## 4. Durable Task Library — Fan-out/in, Retries, Compensations

```
┌─────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Orchestrator = MOVIE DIRECTOR                │
│  Director (orchestrator) coordinates actors (activities)    │
│  Director never does work directly — just directs           │
│  Journal (history) = script the director replays to resume  │
└─────────────────────────────────────────────────────────────┘
```

### Core Concepts
```
Orchestrator function  → stateful workflow, deterministic, replays from journal
Activity function      → unit of work, can be async, retried independently
Sub-orchestration      → child orchestrator called from parent
Entity (Durable Entity)→ small stateful actor, persists across calls
```

### Basic Orchestrator
```csharp
[FunctionName("ProcessOrderOrchestrator")]
public static async Task<OrderResult> RunOrchestrator(
    [OrchestrationTrigger] IDurableOrchestrationContext context,
    ILogger log)
{
    var order = context.GetInput<Order>();

    // Activities called via context — NOT directly
    var inventoryResult = await context.CallActivityAsync<bool>(
        "CheckInventory", order.ItemId);

    if (!inventoryResult)
        return OrderResult.OutOfStock;

    var paymentResult = await context.CallActivityAsync<PaymentResult>(
        "ProcessPayment", order.Payment);

    return OrderResult.Success;
}

[FunctionName("CheckInventory")]
public static bool CheckInventory(
    [ActivityTrigger] int itemId, ILogger log)
{
    // Real work happens here — can call DB, APIs, etc.
    return InventoryService.Check(itemId);
}
```

### Fan-out / Fan-in Pattern
```csharp
[FunctionName("BatchProcessOrchestrator")]
public static async Task<List<Result>> RunBatchOrchestrator(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var items = context.GetInput<List<WorkItem>>();

    // FAN-OUT: launch all activities in parallel
    var tasks = items.Select(item =>
        context.CallActivityAsync<Result>("ProcessItem", item)
    ).ToList();

    // FAN-IN: wait for ALL to complete
    var results = await Task.WhenAll(tasks);

    return results.ToList();
}

// KEY INSIGHT: Task.WhenAll inside orchestrator = durable parallel execution
// Each activity is independently scheduled, retried, and tracked
```

### Fan-out with Throttling
```csharp
// Process in batches to avoid overwhelming downstream systems
var batches = items.Chunk(10);   // .NET 6+ Chunk
foreach (var batch in batches)
{
    var batchTasks = batch.Select(item =>
        context.CallActivityAsync<Result>("ProcessItem", item));
    await Task.WhenAll(batchTasks);  // wait for each batch before next
}
```

### Retries
```csharp
var retryOptions = new RetryOptions(
    firstRetryInterval: TimeSpan.FromSeconds(5),  // initial wait
    maxNumberOfAttempts: 3)
{
    BackoffCoefficient    = 2.0,   // exponential: 5s, 10s, 20s
    MaxRetryInterval      = TimeSpan.FromMinutes(5),
    RetryTimeout          = TimeSpan.FromMinutes(30),
    Handle = ex => ex is TransientException   // only retry certain exceptions
};

var result = await context.CallActivityWithRetryAsync<Result>(
    "UnreliableActivity",
    retryOptions,
    inputData);

// KEY INSIGHT: Retries are durable — if the host crashes mid-retry,
// the framework resumes from the correct retry attempt (not from scratch)
```

### Compensation / Saga Pattern
```csharp
// Saga: compensate completed steps on failure
[FunctionName("TravelBookingOrchestrator")]
public static async Task RunTravelBooking(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    string flightId = null, hotelId = null;

    try
    {
        flightId = await context.CallActivityAsync<string>("BookFlight", context.GetInput<Trip>());
        hotelId  = await context.CallActivityAsync<string>("BookHotel",  context.GetInput<Trip>());
        await context.CallActivityAsync("ChargeCreditCard", new ChargeRequest { FlightId = flightId, HotelId = hotelId });
    }
    catch (Exception)
    {
        // COMPENSATE in REVERSE order
        if (hotelId  != null) await context.CallActivityAsync("CancelHotel",  hotelId);
        if (flightId != null) await context.CallActivityAsync("CancelFlight", flightId);
        throw;   // re-throw so orchestration is marked Failed
    }
}
```

### Human Approval / Waiting for External Event
```csharp
[FunctionName("ApprovalWorkflow")]
public static async Task RunApproval(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var request = context.GetInput<ApprovalRequest>();

    // Send notification (email, Teams, etc.)
    await context.CallActivityAsync("SendApprovalEmail", request);

    // Wait for external event — durably (host can restart)
    var approval = await context.WaitForExternalEvent<bool>(
        "ApprovalDecision",
        TimeSpan.FromDays(3));   // timeout after 3 days

    if (!context.IsReplaying)   // avoid duplicate logging during replay
        context.SetCustomStatus(approval ? "Approved" : "Rejected");

    if (approval)
        await context.CallActivityAsync("ExecuteRequest", request);
    else
        await context.CallActivityAsync("NotifyRejection", request);
}

// Raise the event from external HTTP trigger:
// await client.RaiseEventAsync(instanceId, "ApprovalDecision", true);
```

### Orchestrator Determinism Rules
```
✅ DO:
  - context.CallActivityAsync(...)
  - context.CreateTimer(context.CurrentUtcDateTime.Add(...))
  - context.GetInput<T>()
  - context.WaitForExternalEvent(...)
  - context.NewGuid()

❌ NEVER in orchestrator:
  - DateTime.Now / DateTime.UtcNow  → use context.CurrentUtcDateTime
  - Guid.NewGuid()                  → use context.NewGuid()
  - Random numbers
  - Thread.Sleep / Task.Delay       → use context.CreateTimer()
  - I/O (DB, HTTP, files) directly  → put in Activity
  - Environment.GetEnvironmentVariable → inject via Activity
```

### Key Interview Q&A

**Q: How does durable orchestration survive crashes?**
> Event sourcing via history table. On restart, orchestrator replays from event history — all `await` points fast-forward using recorded results. Only new activities execute real work.

**Q: What happens if you break determinism?**
> Replay produces different results than original execution → corrupted state, incorrect branching, or infinite loops. Always use `context.` variants for time, GUIDs, randomness.

**Q: Fan-out vs parallel activities — what's the limit?**
> No hard SDK limit, but practical limits: storage throughput, downstream rate limits, memory. Use chunked batches for thousands of items.

**Q: Durable Entity vs Orchestration?**
> Orchestration: sequential/parallel workflow with a start and end. Entity: long-lived stateful actor responding to operations (like a counter, cart) — no defined end. Entities are called via `context.CallEntityAsync`.

---

## 5. Azure Container Apps

```
┌─────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Container Apps = Kubernetes without K8s ops  │
│  You bring containers, Azure manages the cluster plumbing   │
│  Scale to zero ✓  Dapr sidecar ✓  Event-driven ✓           │
└─────────────────────────────────────────────────────────────┘
```

### Architecture Hierarchy
```
Azure Subscription
└── Resource Group
    └── Container Apps Environment     ← shared networking/logging boundary
        ├── Container App A             ← your microservice
        │   ├── Revision 1 (20% traffic)
        │   └── Revision 2 (80% traffic)   ← blue-green / canary
        ├── Container App B
        └── Dapr Components             ← pub/sub, state, bindings
```

### Environment Types
| | Workload Profiles | Consumption Only |
|---|---|---|
| **Use for** | Dedicated compute, GPU, compliance | Cost-optimized, burstable |
| **Scaling** | Scale to zero + dedicated | Scale to zero always |
| **Networking** | VNet injection ✓ | VNet injection ✓ |
| **Recommended** | Production microservices | Dev/test, event-driven jobs |

### Quick Deploy — Azure CLI
```bash
# Create environment
az containerapp env create \
  --name cae-myapp-prod \
  --resource-group rg-myapp \
  --location eastus2

# Create container app
az containerapp create \
  --name ca-orders-api \
  --resource-group rg-myapp \
  --environment cae-myapp-prod \
  --image myacr.azurecr.io/orders-api:v2 \
  --target-port 8080 \
  --ingress external \          # external = internet-accessible
  --min-replicas 1 \
  --max-replicas 20 \
  --cpu 0.5 --memory 1.0Gi

# Update to new image (creates new revision)
az containerapp update \
  --name ca-orders-api \
  --resource-group rg-myapp \
  --image myacr.azurecr.io/orders-api:v3
```

### Scaling Rules
```yaml
# Bicep / ARM scale definition
scale:
  minReplicas: 0          # scale to zero = zero cost when idle
  maxReplicas: 30
  rules:
    - name: http-scaling
      http:
        metadata:
          concurrentRequests: "50"   # scale up when >50 req/replica

    - name: queue-scaling
      azureQueue:
        queueName: orders-queue
        queueLength: "5"            # 1 replica per 5 messages
        auth:
          - secretRef: storage-conn-string
            triggerParameter: connection

    - name: cpu-scaling
      custom:
        type: cpu
        metadata:
          type: Utilization
          value: "70"
```

### Revisions — Traffic Splitting
```bash
# Multiple active revisions (for canary)
az containerapp ingress traffic set \
  --name ca-orders-api \
  --resource-group rg-myapp \
  --revision-weight ca-orders-api--v1=80 ca-orders-api--v2=20

# Revision modes:
# Single   → only latest revision active (default, most apps)
# Multiple → multiple revisions active simultaneously (A/B, canary)
```

### Secrets & Environment Variables
```bash
# Add secret (from Key Vault reference or plain)
az containerapp secret set \
  --name ca-orders-api \
  --resource-group rg-myapp \
  --secrets "db-conn=keyvaultref:https://kv-myapp.vault.azure.net/secrets/DbConn"

# Reference secret as env var
az containerapp update \
  --name ca-orders-api \
  --set-env-vars "ConnectionStrings__Default=secretref:db-conn"
```

### Dapr Integration — Beginner to Expert

---

#### LEVEL 1 — BEGINNER: What Problem Does Dapr Solve?

```
┌──────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Dapr = Universal Adapter for Microservices        │
│                                                                  │
│  WITHOUT Dapr: each service hardcodes broker SDK, Redis SDK,     │
│  retry logic, mTLS certs, secrets client, tracing setup...       │
│                                                                  │
│  WITH Dapr: your app calls localhost:3500 (always the same API)  │
│  Dapr sidecar handles the actual broker/Redis/Vault behind it    │
│                                                                  │
│  App says: "publish this event"                                  │
│  Dapr says: "ok — today it's Service Bus, tomorrow it's Kafka,  │
│              you don't need to change a single line of code"     │
└──────────────────────────────────────────────────────────────────┘
```

**The Sidecar Pattern:**
```
┌──────────────────────────────────────────────────────────────────┐
│                     Pod / Container Group                        │
│  ┌──────────────────┐        ┌─────────────────────────────┐    │
│  │   Your App       │        │      Dapr Sidecar            │    │
│  │   :8080          │◄──────►│      :3500  (HTTP API)       │    │
│  │                  │        │      :50001 (gRPC API)        │    │
│  │  calls           │        │                             │    │
│  │  localhost:3500  │        │  ┌────────────────────────┐ │    │
│  └──────────────────┘        │  │  Building Blocks        │ │    │
│                               │  │  - Service Invocation  │ │    │
│                               │  │  - State Management    │ │    │
│                               │  │  - Pub/Sub             │ │    │
│                               │  │  - Bindings            │ │    │
│                               │  │  - Secrets             │ │    │
│                               │  │  - Actors              │ │    │
│                               │  │  - Workflows           │ │    │
│                               │  └────────────────────────┘ │    │
│                               └─────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

**The 8 Dapr Building Blocks:**

| Building Block | What It Does | Backend Examples |
|---|---|---|
| Service Invocation | Service-to-service HTTP/gRPC with retries + mTLS | Any HTTP service |
| State Management | Key/value store with transactions & ETags | Redis, CosmosDB, SQL |
| Pub/Sub | Async message broker abstraction | Service Bus, Kafka, Redis |
| Bindings (Input) | Trigger app from external system | Cron, Queue, Blob, HTTP |
| Bindings (Output) | Call external system from app | Blob, SMTP, Twilio |
| Secrets | Read secrets from vault | Key Vault, env vars, K8s secrets |
| Configuration | Dynamic config with change notifications | App Config, Redis |
| Actors | Stateful virtual actors with timers/reminders | Built-in (uses state store) |

**Local Development Setup:**
```bash
# Install Dapr CLI
winget install Dapr.CLI         # Windows
brew install dapr/tap/dapr      # Mac

# Initialize Dapr locally (starts Redis + Zipkin in Docker)
dapr init

# Run your app WITH the Dapr sidecar
dapr run \
  --app-id orders-api \         # unique name for this service
  --app-port 5000 \             # your app's HTTP port
  --dapr-http-port 3500 \       # Dapr's API port (default 3500)
  -- dotnet run                 # your actual start command

# Check running apps
dapr list
```

---

#### LEVEL 2 — INTERMEDIATE: Building Blocks Deep Dive

---

##### Building Block 1: Service Invocation

```
orders-api                    Dapr Sidecar              inventory-api
    │                              │                          │
    │  POST localhost:3500/        │                          │
    │  v1.0/invoke/                │                          │
    │  inventory-api/method/       │  discovers service       │
    │  api/inventory/check  ──────►│  via name resolution ───►│
    │                              │  adds retries + mTLS     │
    │◄─────────────────────────────│◄─────────────────────────│
```

```csharp
// === C# SDK (Dapr.Client NuGet) ===

// Setup
builder.Services.AddDaprClient();

// Injection
public class OrderService(DaprClient dapr) { }

// GET request to another service
var inventory = await daprClient.InvokeMethodAsync<InventoryResult>(
    HttpMethod.Get,
    "inventory-api",           // target Dapr app-id (NOT a URL)
    "api/inventory/check",     // target endpoint path
    new CancellationTokenSource(TimeSpan.FromSeconds(10)).Token);

// POST with body
var result = await daprClient.InvokeMethodAsync<CreateOrderRequest, OrderResult>(
    HttpMethod.Post,
    "orders-api",
    "api/orders",
    new CreateOrderRequest { ItemId = 42, Qty = 1 });
```

```yaml
# resiliency.yaml — sidecar-level retry/circuit breaker (no app code needed)
apiVersion: dapr.io/v1alpha1
kind: Resiliency
metadata:
  name: myresiliency
spec:
  policies:
    retries:
      retryForever:
        policy: exponential
        maxInterval: 15s
        maxRetries: -1          # infinite retries
    circuitBreakers:
      simpleCB:
        maxRequests: 1
        interval: 10s
        timeout: 30s
        trip: consecutiveFailures >= 3   # open after 3 consecutive failures

  targets:
    apps:
      inventory-api:             # apply to calls targeting this app
        retry: retryForever
        circuitBreaker: simpleCB
```

> **Key Insight:** Dapr service invocation adds automatic mTLS between sidecars — services communicate encrypted WITHOUT you writing any TLS code.

---

##### Building Block 2: State Management

```
Your App ──► Dapr Sidecar ──► State Store Component
              (key/value API)   (Redis / CosmosDB / SQL / etc.)
```

```csharp
// Save state
await daprClient.SaveStateAsync(
    storeName: "statestore",       // component name (matches YAML)
    key:       "order-42",         // your key
    value:     new Order { Id = 42, Status = "Pending" });

// Get state
var order = await daprClient.GetStateAsync<Order>("statestore", "order-42");

// Delete state
await daprClient.DeleteStateAsync("statestore", "order-42");

// Optimistic concurrency with ETags — prevents lost updates
var (order, etag) = await daprClient.GetStateAndETagAsync<Order>("statestore", "order-42");
order.Status = "Shipped";

var success = await daprClient.TrySaveStateAsync(
    "statestore", "order-42", order,
    etag,                          // if etag changed, save returns false
    new StateOptions { Consistency = ConsistencyMode.Strong });

if (!success) throw new ConcurrencyException("Order was modified, retry");
```

```yaml
# statestore.yaml — component definition (swap backend without code change)
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore              # this name is used in your code
spec:
  type: state.redis             # swap to state.azure.cosmosdb for prod
  version: v1
  metadata:
  - name: redisHost
    value: "localhost:6379"
  - name: actorStateStore       # mark as actor state store too
    value: "true"
```

**State Transactions — atomic multi-key operations:**
```csharp
var ops = new List<StateTransactionRequest>
{
    new("cart-user1",  JsonSerializer.SerializeToUtf8Bytes(cart),    StateOperationType.Upsert),
    new("balance-user1", JsonSerializer.SerializeToUtf8Bytes(balance), StateOperationType.Upsert),
    new("reservation-42", null,                                        StateOperationType.Delete),
};
await daprClient.ExecuteStateTransactionAsync("statestore", ops);
// All three ops succeed or all fail — atomically
```

---

##### Building Block 3: Pub/Sub

```
Publisher                Dapr Sidecar        Broker            Consumer Sidecar    Consumer App
    │                        │                 │                     │                  │
    │ PublishEventAsync ─────►│                 │                     │                  │
    │                        │─── publish ─────►│                     │                  │
    │                        │                 │────── deliver ───────►│                  │
    │                        │                 │                     │──POST /orders ───►│
    │                        │                 │                     │                  │ process
    │                        │                 │◄─────────── 200 ────│◄── return 200 ──│
```

```csharp
// Publisher — doesn't know what broker or who's listening
await daprClient.PublishEventAsync(
    pubsubName: "pubsub",         // component name
    topicName:  "orders",         // topic
    data:       new OrderCreatedEvent { OrderId = 42, Total = 99.99m },
    cancellationToken: ct);

// With CloudEvents metadata
await daprClient.PublishEventAsync("pubsub", "orders",
    new OrderCreatedEvent { OrderId = 42 },
    new Dictionary<string, string>
    {
        { "ttlInSeconds", "3600" },   // message TTL
        { "rawPayload", "true" }
    });
```

```csharp
// Consumer — ASP.NET Core subscription (Dapr POSTs to this endpoint)
// Program.cs:
app.MapSubscribeHandler();   // exposes GET /dapr/subscribe endpoint Dapr queries

// Controller:
[ApiController]
public class OrdersSubscriberController : ControllerBase
{
    [Topic("pubsub", "orders")]        // Dapr attribute — subscribes to topic
    [HttpPost("orders")]
    public async Task<IActionResult> HandleOrder(OrderCreatedEvent evt)
    {
        // Dapr delivers via POST with CloudEvents envelope
        await _orderProcessor.ProcessAsync(evt);

        // Return 200/204 = ACK (message deleted from broker)
        // Return 404/500  = NACK (message redelivered by Dapr)
        // Return 200 + { "status": "DROP" } = discard without retry
        return Ok();
    }
}
```

```yaml
# pubsub.yaml — broker component (swap broker, zero code change)
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub
spec:
  type: pubsub.azure.servicebus.topics   # or pubsub.kafka, pubsub.redis
  version: v1
  metadata:
  - name: connectionString
    secretKeyRef:                        # reference to secret, not hardcoded
      name: servicebus-secret
      key: connectionString
  - name: maxConcurrentHandlers
    value: "10"
  - name: prefetchCount
    value: "20"
```

**Subscription filtering — only receive relevant events:**
```yaml
# subscription.yaml — declarative subscription with filter
apiVersion: dapr.io/v2alpha1
kind: Subscription
metadata:
  name: orders-subscription
spec:
  pubsubname: pubsub
  topic: orders
  routes:
    rules:
      - match: 'event.type == "order.created"'
        path: /orders/created
      - match: 'event.type == "order.shipped"'
        path: /orders/shipped
    default: /orders/unknown
  scopes:
    - orders-processor           # only this app-id receives it
```

---

##### Building Block 4: Input/Output Bindings

```
INPUT BINDING: External system ──► Dapr ──► POST your endpoint
OUTPUT BINDING: Your app ──► Dapr ──► External system (no SDK needed)
```

```yaml
# cron-binding.yaml — trigger your app on a schedule (no cron job infra needed)
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: scheduled-cleanup
spec:
  type: bindings.cron
  version: v1
  metadata:
  - name: schedule
    value: "@every 1h"    # or "0 2 * * *" standard cron

# blob-binding.yaml — trigger on new file in Azure Blob Storage
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: new-reports
spec:
  type: bindings.azure.blobstorage
  version: v1
  metadata:
  - name: storageAccount
    value: "mystorageaccount"
  - name: container
    value: "reports"
```

```csharp
// Input binding — Dapr POSTs to this endpoint when cron fires or blob arrives
[ApiController]
public class BindingController : ControllerBase
{
    [HttpPost("scheduled-cleanup")]     // name must match component metadata.name
    public async Task<IActionResult> RunScheduledCleanup()
    {
        await _cleanupService.RunAsync();
        return Ok();
    }

    [HttpPost("new-reports")]
    public async Task<IActionResult> ProcessNewReport([FromBody] BlobBindingPayload payload)
    {
        // payload.Data = base64 of blob content
        // payload.Metadata["blobName"] = filename
        await _reportProcessor.ProcessAsync(payload);
        return Ok();
    }
}

// Output binding — call external system without its SDK
await daprClient.InvokeBindingAsync(
    bindingName: "send-email",         // component name
    operation:   "create",             // operation supported by binding
    data:        new { to = "user@example.com", subject = "Order Confirmed" });
```

---

##### Building Block 5: Secrets

```csharp
// Read secret from Key Vault / K8s secrets / env vars — same API
var secrets = await daprClient.GetSecretAsync(
    storeName:  "secretstore",         // component pointing to Key Vault
    key:        "db-connection-string");
var connStr = secrets["db-connection-string"];

// Multi-value secret (Key Vault secret with JSON value)
var allSecrets = await daprClient.GetBulkSecretAsync("secretstore");
```

```yaml
# secretstore.yaml — points to Azure Key Vault
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: secretstore
spec:
  type: secretstores.azure.keyvault
  version: v1
  metadata:
  - name: vaultName
    value: "kv-myapp-prod"
  - name: azureClientId               # Managed Identity client ID
    value: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# NOTE: With Managed Identity, no credentials in YAML — Dapr uses pod identity
```

---

#### LEVEL 3 — ADVANCED: Actors, Workflows, and Production Patterns

---

##### Building Block 6: Dapr Actors (Virtual Actor Pattern)

```
┌──────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Actor = a tiny stateful object with a mailbox     │
│  - Has unique ID (e.g., "cart-user-42")                          │
│  - Only one method runs at a time (no concurrency within actor)  │
│  - State automatically persisted to state store                  │
│  - Garbage collected when idle, rehydrated on next call          │
│  - Timers: fire-and-forget schedule (reset on deactivation)      │
│  - Reminders: durable schedule (survive restarts)               │
└──────────────────────────────────────────────────────────────────┘
```

```csharp
// 1. Define actor interface
public interface IShoppingCartActor : IActor
{
    Task AddItemAsync(CartItem item);
    Task RemoveItemAsync(string itemId);
    Task<CartSummary> GetSummaryAsync();
    Task CheckoutAsync();
}

// 2. Implement actor
[Actor(TypeName = "ShoppingCartActor")]
public class ShoppingCartActor : Actor, IShoppingCartActor
{
    private const string StateKey = "cart-items";

    public ShoppingCartActor(ActorHost host) : base(host) { }

    protected override async Task OnActivateAsync()
    {
        // Called when actor is first created or rehydrated
        var exists = await StateManager.ContainsStateAsync(StateKey);
        if (!exists) await StateManager.SetStateAsync(StateKey, new List<CartItem>());
    }

    public async Task AddItemAsync(CartItem item)
    {
        var items = await StateManager.GetStateAsync<List<CartItem>>(StateKey);
        items.Add(item);
        await StateManager.SetStateAsync(StateKey, items);
        // State automatically saved to state store — survives restarts
    }

    public async Task<CartSummary> GetSummaryAsync()
    {
        var items = await StateManager.GetStateAsync<List<CartItem>>(StateKey);
        return new CartSummary { Items = items, Total = items.Sum(i => i.Price * i.Qty) };
    }

    // Reminder — durable, survives actor deactivation
    public async Task RegisterAbandonedCartReminderAsync()
    {
        await RegisterReminderAsync(
            "abandoned-cart-check",
            null,
            dueTime: TimeSpan.FromHours(1),    // first fire in 1hr
            period: TimeSpan.FromHours(24));    // then every 24hrs
    }

    public async Task ReceiveReminderAsync(string name, byte[] state,
        TimeSpan dueTime, TimeSpan period)
    {
        if (name == "abandoned-cart-check")
        {
            var summary = await GetSummaryAsync();
            if (summary.Items.Any())
                await _emailService.SendAbandonedCartEmailAsync(Id.GetId());
        }
    }
}

// 3. Register actor
builder.Services.AddActors(options =>
{
    options.Actors.RegisterActor<ShoppingCartActor>();
    options.ActorIdleTimeout          = TimeSpan.FromMinutes(60);  // deactivate after 60min idle
    options.DrainOngoingCallTimeout   = TimeSpan.FromSeconds(30);  // graceful shutdown drain
    options.RemindersStoragePartitions = 7;                         // partition reminders for scale
});
app.MapActorsHandlers();   // exposes /dapr/config and actor endpoints

// 4. Call actor from another service
var proxy = ActorProxy.Create<IShoppingCartActor>(
    new ActorId("user-42"),      // unique ID for this actor instance
    "ShoppingCartActor");        // actor type name
await proxy.AddItemAsync(new CartItem { ItemId = "sku-99", Price = 29.99m, Qty = 2 });
var summary = await proxy.GetSummaryAsync();
```

> **When to use Actors vs Orchestration:**
> - **Actor**: long-lived entity with own state and behavior (cart, session, device twin)
> - **Orchestration**: workflow with steps and compensation (order process, approval flow)

---

##### Building Block 7: Dapr Workflows (Dapr v1.10+)

```
MENTAL MODEL: Dapr Workflow ≈ Azure Durable Functions for any platform
Orchestrator + Activities — deterministic replay, durable state
```

```csharp
// 1. Define workflow
public class OrderProcessingWorkflow : Workflow<OrderRequest, OrderResult>
{
    public override async Task<OrderResult> RunAsync(
        WorkflowContext context, OrderRequest input)
    {
        // Deterministic: use context.CurrentUtcDateTime, not DateTime.UtcNow
        var orderId = context.InstanceId;

        // Call activities (can retry, run in parallel)
        var inventoryOk = await context.CallActivityAsync<bool>(
            nameof(CheckInventoryActivity), input.ItemId);

        if (!inventoryOk)
            return new OrderResult { Status = "OutOfStock" };

        // Parallel fan-out
        var paymentTask  = context.CallActivityAsync<string>(nameof(ProcessPaymentActivity), input.Payment);
        var reserveTask  = context.CallActivityAsync<bool>(nameof(ReserveInventoryActivity), input.ItemId);
        await Task.WhenAll(paymentTask, reserveTask);

        // Wait for external event (human approval, webhook, etc.)
        var approved = await context.WaitForExternalEventAsync<bool>(
            "manager-approval",
            TimeSpan.FromHours(48));   // timeout if no response in 48hrs

        if (!approved)
        {
            // Compensate: refund and release
            await context.CallActivityAsync(nameof(RefundPaymentActivity), await paymentTask);
            await context.CallActivityAsync(nameof(ReleaseInventoryActivity), input.ItemId);
            return new OrderResult { Status = "Rejected" };
        }

        await context.CallActivityAsync(nameof(ShipOrderActivity), orderId);
        return new OrderResult { Status = "Shipped", OrderId = orderId };
    }
}

// 2. Define activities
public class CheckInventoryActivity : WorkflowActivity<string, bool>
{
    private readonly IInventoryService _inventory;
    public CheckInventoryActivity(IInventoryService inventory) => _inventory = inventory;

    public override async Task<bool> RunAsync(WorkflowActivityContext context, string itemId)
        => await _inventory.IsAvailableAsync(itemId);
}

// 3. Register
builder.Services.AddDaprWorkflow(options =>
{
    options.RegisterWorkflow<OrderProcessingWorkflow>();
    options.RegisterActivity<CheckInventoryActivity>();
    options.RegisterActivity<ProcessPaymentActivity>();
    options.RegisterActivity<ShipOrderActivity>();
    options.RegisterActivity<RefundPaymentActivity>();
});

// 4. Start workflow
var workflowClient = app.Services.GetRequiredService<DaprWorkflowClient>();
var instanceId = await workflowClient.ScheduleNewWorkflowAsync(
    nameof(OrderProcessingWorkflow),
    instanceId: $"order-{Guid.NewGuid()}",   // unique per workflow run
    input: new OrderRequest { ItemId = "sku-99", Payment = paymentInfo });

// 5. Raise external event (from webhook or approval endpoint)
await workflowClient.RaiseEventAsync(instanceId, "manager-approval", true);

// 6. Query status
var metadata = await workflowClient.GetWorkflowMetadataAsync(instanceId);
Console.WriteLine(metadata.RuntimeStatus);  // Running, Completed, Failed
```

---

##### Production: Dapr on Azure Container Apps

```bash
# ACA automatically manages Dapr sidecar injection
az containerapp create \
  --name ca-orders-api \
  --resource-group rg-myapp \
  --environment cae-myapp-prod \
  --image myacr.azurecr.io/orders-api:v1 \
  --dapr-enabled true \
  --dapr-app-id "orders-api" \
  --dapr-app-port 8080 \
  --dapr-app-protocol http \
  --target-port 8080

# Register a Dapr component (shared across all apps in environment)
az containerapp env dapr-component set \
  --name cae-myapp-prod \
  --resource-group rg-myapp \
  --dapr-component-name pubsub \
  --yaml pubsub.yaml
```

**Component YAML with scopes (restrict which apps use it):**
```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub
spec:
  type: pubsub.azure.servicebus.topics
  version: v1
  metadata:
  - name: connectionString
    secretKeyRef:
      name: servicebus-conn
      key: connectionString
  - name: maxActiveMessages
    value: "100"
scopes:                         # ONLY these app-ids can use this component
  - orders-api
  - inventory-api
  - notification-service
```

---

##### Production: Observability — Distributed Tracing with Dapr

```
Every Dapr service invocation + pub/sub delivery automatically creates spans.
Zero code change needed — tracing is built into the sidecar.
```

```yaml
# tracing config (applied at environment level in ACA)
apiVersion: dapr.io/v1alpha1
kind: Configuration
metadata:
  name: daprConfig
spec:
  tracing:
    samplingRate: "1"            # 1 = 100% sampling (use 0.1 in prod = 10%)
    zipkin:
      endpointAddress: "http://zipkin:9411/api/v2/spans"
    otel:
      endpointAddress: "http://otel-collector:4317"
      isSecure: false
      protocol: grpc
```

```
Trace view in Zipkin / App Insights:
orders-api ──────────────────────────────────── 245ms total
  └── dapr invoke: inventory-api/check ──────── 82ms
  └── dapr publish: orders topic ─────────────── 15ms
      └── inventory-api subscribe: /orders ───── 120ms (async)
```

---

##### Production: Security — mTLS Between Services

```
┌──────────────────────────────────────────────────────────────────┐
│  Dapr security without any cert management code                  │
│                                                                  │
│  Dapr Control Plane (Sentry) issues certificates automatically   │
│  Every sidecar gets a SPIFFE-standard identity certificate        │
│  All sidecar-to-sidecar traffic is mTLS encrypted by default     │
│                                                                  │
│  orders-api sidecar ──(mTLS, cert verified)──► inventory sidecar │
│  Your app code: zero SSL/TLS code                                │
└──────────────────────────────────────────────────────────────────┘
```

```yaml
# Access control — restrict what services can call each other
apiVersion: dapr.io/v1alpha1
kind: Configuration
metadata:
  name: inventory-api-config
spec:
  accessControl:
    defaultAction: deny          # deny-by-default (secure baseline)
    trustDomain: "production"
    policies:
    - appId: orders-api          # only orders-api can call inventory-api
      defaultAction: allow
      namespace: "default"
      operations:
      - name: /api/inventory/**
        httpVerb: ['GET']
        action: allow
    - appId: admin-service
      defaultAction: allow
      operations:
      - name: /api/inventory/**
        httpVerb: ['GET', 'POST', 'DELETE']
        action: allow
```

---

##### Dapr Component Comparison — When to Use What

| Scenario | Use This Building Block | Example Component |
|---|---|---|
| Service calls another service synchronously | Service Invocation | (built-in, no YAML needed) |
| Temporary cache / session data | State Management | state.redis |
| Durable entity state (cart, profile) | Actors + State | state.azure.cosmosdb |
| Async fire-and-forget events | Pub/Sub | pubsub.azure.servicebus |
| Schedule recurring work | Input Binding (cron) | bindings.cron |
| React to new files/queue messages | Input Binding | bindings.azure.storagequeues |
| Call external API/SMTP/SMS | Output Binding | bindings.smtp, bindings.twilio |
| Multi-step workflow with compensation | Workflows | (built-in, uses state store) |

---

##### Dapr Interview Q&A — Lead Level

**Q: What is the Dapr sidecar and why is it separate from the app?**
> Separation of concerns: the app focuses on business logic; the sidecar handles infrastructure cross-cutting (retries, mTLS, tracing, secret reading, broker protocol). Upgrading Dapr = redeploy sidecar only, not the app. Multiple languages can use the same Dapr API (HTTP/gRPC on localhost:3500).

**Q: How does Dapr pub/sub guarantee at-least-once delivery?**
> The broker (Service Bus, Kafka) holds the message. Dapr sidecar delivers to your app via POST. If your app returns 2xx, Dapr ACKs to broker (message deleted). If 4xx/5xx, broker retries. Your app must be idempotent — use the `ce-id` CloudEvents header as idempotency key.

**Q: What happens to an Actor during a rolling deployment?**
> Dapr drains actors gracefully: `DrainOngoingCallTimeout` lets running methods finish before the pod is terminated. Reminders fire from the new pod because they're stored in the state store (durable). State is reloaded from the state store on reactivation.

**Q: How is Dapr Workflow different from Durable Functions?**
> Same programming model (orchestrator + activities, deterministic replay, external events). Dapr Workflow runs on any platform (K8s, ACA, self-hosted) — not Azure-only. Uses Dapr's state store for history (any backend). Durable Functions is Azure-only but has deeper Azure integration. Choose Dapr Workflow when you need cloud-agnostic orchestration.

**Q: How do you swap a state store from Redis (dev) to CosmosDB (prod) without code change?**
> Change only the component YAML file — `type: state.redis` → `type: state.azure.cosmosdb`, update metadata (endpoint, key). Your app code calls `daprClient.SaveStateAsync("statestore", ...)` — the name `statestore` stays the same. Zero code change.

**Q: How do you test Dapr applications locally without a real broker or Redis?**
> 1. `dapr init` starts local Redis + Zipkin via Docker. 2. Use `dapr run` to start app + sidecar. 3. For unit tests: mock `DaprClient` with `Moq` — it's an interface. 4. For integration tests: use `dapr run` with in-memory components (`type: state.in-memory`, `type: pubsub.in-memory`).

**Q: What is the difference between a Dapr Timer and a Dapr Reminder?**
> **Timer**: fires on schedule but does NOT persist across actor deactivation. If actor is garbage-collected, timer is lost. Use for: short-lived periodic checks while actor is active. **Reminder**: durable, stored in state store, survives actor deactivation and process restarts. Use for: critical scheduled operations (abandoned cart, subscription renewal).

**Q: How do you handle poison messages in Dapr pub/sub?**
> 1. Configure max delivery count on the broker component (e.g., `maxDeliveryCount: 5`). 2. After max retries, broker moves to dead-letter topic. 3. Subscribe to dead-letter topic with a separate handler for alerting/logging. 4. In your handler, return `{ "status": "DROP" }` to discard without retry (for known bad messages).

```csharp
// Explicit DROP vs RETRY vs SUCCESS from subscription handler
[Topic("pubsub", "orders")]
[HttpPost("orders")]
public IActionResult HandleOrder(OrderCreatedEvent evt)
{
    if (evt.OrderId <= 0)
        return Ok(new { status = "DROP" });    // discard — bad message, no retry

    try
    {
        _processor.Process(evt);
        return Ok();                           // SUCCESS — ACK to broker
    }
    catch (TransientException)
    {
        return StatusCode(500);                // RETRY — Dapr will redeliver
    }
}
```

### Jobs vs Container Apps
| | Container App | Container App Job |
|---|---|---|
| **Lifecycle** | Long-running service | Runs to completion |
| **Trigger** | HTTP / KEDA event | Schedule, Event, Manual |
| **Example** | API, worker | Nightly batch, CI task |
| **Scale to zero** | Yes (HTTP, events) | Always (runs on demand) |

### Container App Job — Scheduled
```bash
az containerapp job create \
  --name job-nightly-report \
  --resource-group rg-myapp \
  --environment cae-myapp-prod \
  --trigger-type Schedule \
  --cron-expression "0 2 * * *" \   # 2 AM UTC daily
  --image myacr.azurecr.io/report-job:latest \
  --cpu 1.0 --memory 2.0Gi \
  --parallelism 1 \
  --replica-completion-count 1
```

### Networking
```
Ingress (External)  → internet-accessible FQDN: ca-name.env-hash.eastus2.azurecontainerapps.io
Ingress (Internal)  → only reachable within same environment
No Ingress          → triggered internally (jobs, workers)

Custom domains: bring your own cert or use managed cert (free!)
```

### Monitoring
```bash
# Built-in Log Analytics integration
az containerapp logs show \
  --name ca-orders-api \
  --resource-group rg-myapp \
  --follow   # stream live

# KQL in Log Analytics
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "ca-orders-api"
| where Log_s contains "ERROR"
| order by TimeGenerated desc
```

### Key Interview Q&A

**Q: Container Apps vs AKS — when to choose?**
```
Container Apps → no K8s ops expertise, scale to zero critical,
                 event-driven, Dapr needed, fast time to value
AKS            → full K8s control, custom node configs, GPU workloads,
                 complex networking, existing K8s manifests, compliance
```

**Q: How does Container Apps scale to zero?**
> When HTTP-triggered: environment's HTTP proxy holds cold requests, scales from 0→1, then handles queued requests. With KEDA event triggers: polls queue/topic length, scales accordingly. Minimum 0 replicas = zero compute cost when idle.

**Q: What is a revision in Container Apps?**
> Immutable snapshot of container app configuration + image version. New revision created on each `az containerapp update`. Single-revision mode: only latest active. Multiple-revision mode: traffic split across revisions for canary/blue-green deployments.

**Q: How do you share state between Container App replicas?**
> Never use in-process memory for shared state. Use: Azure Cache for Redis, Dapr state store (abstracts Redis/CosmosDB/etc.), Azure Storage, SQL/CosmosDB. Replicas are stateless by design.

**Q: How do environment variables and secrets work?**
> Secrets stored encrypted in environment, referenced by name. Env vars can reference secrets via `secretref:`. Key Vault references (`keyvaultref:`) allow using Key Vault without copying secrets. Changes to secrets require revision restart to take effect.

**Q: Container Apps vs Azure Functions?**
> Functions: event-driven, per-execution billing, built-in triggers (timer, blob, HTTP), max execution time limits. Container Apps: full control over runtime, longer-lived, custom binaries, port-based services. Container Apps now also has Jobs, bridging the gap.

---

## 6. .NET API — Lead Developer Level

```
┌─────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: ASP.NET Core = a pipeline of middleware       │
│  Every request flows IN → through each middleware → OUT     │
│  Middleware is composable, ordered, and short-circuitable   │
└─────────────────────────────────────────────────────────────┘
```

### Middleware Pipeline — Order Matters
```csharp
// Program.cs — middleware ORDER determines behaviour
var app = builder.Build();

// Exception handler FIRST — wraps all downstream errors
app.UseExceptionHandler("/error");

// HSTS / HTTPS redirect — before routing
app.UseHttpsRedirection();

// Static files — short-circuit before auth for perf
app.UseStaticFiles();

// Routing — makes endpoint metadata available to next middleware
app.UseRouting();

// Auth MUST come after UseRouting (needs route data) and before UseEndpoints
app.UseAuthentication();  // "Who are you?"
app.UseAuthorization();   // "Are you allowed?"

// Rate limiting after auth (user identity available)
app.UseRateLimiter();

// Output caching — after auth so cache is per-user if needed
app.UseOutputCache();

// Endpoints at the end
app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
```

**Lead-level: what happens if you put `UseAuthorization` before `UseRouting`?**
> Authorization middleware won't find the endpoint metadata (roles, policies) because `UseRouting` hasn't resolved the endpoint yet. You'll get 401/403 incorrectly or policies never applied.

### Minimal API vs Controller-based — When to Choose
```csharp
// Minimal API — best for: simple CRUD, microservices, high throughput
app.MapGet("/orders/{id}", async (int id, IOrderService svc) =>
{
    var order = await svc.GetByIdAsync(id);
    return order is null ? Results.NotFound() : Results.Ok(order);
})
.RequireAuthorization("OrdersRead")
.WithName("GetOrder")
.WithOpenApi()
.CacheOutput(p => p.Expire(TimeSpan.FromMinutes(5)));

// Route groups — DRY grouping with shared prefix + middleware
var orders = app.MapGroup("/api/v1/orders")
    .RequireAuthorization()
    .WithTags("Orders")
    .AddEndpointFilter<ValidationFilter<CreateOrderRequest>>();

orders.MapPost("/", CreateOrder);
orders.MapGet("/{id}", GetOrder);

// Controller — best for: complex domain logic, filters, large teams, conventions
[ApiController]          // enables auto model validation + binding source inference
[Route("api/v1/[controller]")]
public class OrdersController : ControllerBase { ... }
```

### Dependency Injection — Lifetimes & Pitfalls
```csharp
// Lifetimes
builder.Services.AddTransient<IEmailSender, SmtpEmailSender>();   // new instance every injection
builder.Services.AddScoped<IOrderRepository, OrderRepository>();  // one per HTTP request
builder.Services.AddSingleton<ICache, MemoryCache>();             // one for app lifetime

// CAPTIVE DEPENDENCY BUG — common lead-level trap
// Singleton capturing Scoped = Scoped lives as long as Singleton (whole app)
// This is a leak: DB context outlives the request, causes concurrency bugs

// WRONG:
builder.Services.AddSingleton<IOrderProcessor>(sp =>
    new OrderProcessor(sp.GetRequiredService<IOrderRepository>())); // Scoped captured!

// CORRECT: use IServiceScopeFactory to resolve scoped per operation
builder.Services.AddSingleton<IOrderProcessor>(sp =>
{
    var scopeFactory = sp.GetRequiredService<IServiceScopeFactory>();
    return new OrderProcessor(scopeFactory);   // creates scope on demand
});

// Or validate DI container at startup (catches mistakes early):
builder.Services.BuildServiceProvider(validateScopes: true);
// Or in host:
builder.Host.UseDefaultServiceProvider(o => o.ValidateScopes = true);
```

### Filters vs Middleware — Lead Decision
```
Middleware:
  + Runs for ALL requests (static files, 404s, non-MVC routes)
  + Access to raw HttpContext
  - No access to MVC context (controller, action, model state)
  Use for: auth, logging, CORS, compression, rate limiting

Filters:
  + Access to ActionContext, result, model state, controller
  + Scoped to specific controllers/actions via attributes
  - Only runs within MVC pipeline
  Use for: validation, model transformation, audit logging, exception per-controller

Filter execution order: Authorization → Resource → Action → Exception → Result

// Global exception filter
public class GlobalExceptionFilter : IExceptionFilter
{
    public void OnException(ExceptionContext ctx)
    {
        var (status, title) = ctx.Exception switch
        {
            NotFoundException  => (404, "Not Found"),
            ValidationException => (422, "Validation Failed"),
            UnauthorizedException => (403, "Forbidden"),
            _ => (500, "Internal Server Error")
        };
        ctx.Result = new ObjectResult(new ProblemDetails
        {
            Status = status, Title = title,
            Detail = ctx.Exception.Message
        }) { StatusCode = status };
        ctx.ExceptionHandled = true;
    }
}
// Register globally:
builder.Services.AddControllers(o => o.Filters.Add<GlobalExceptionFilter>());
```

### API Versioning Strategies
```csharp
// Install: Asp.Versioning.Mvc or Asp.Versioning.Http (Minimal APIs)
builder.Services.AddApiVersioning(o =>
{
    o.DefaultApiVersion = new ApiVersion(1, 0);
    o.AssumeDefaultVersionWhenUnspecified = true;
    o.ReportApiVersions = true;   // adds api-supported-versions header
    o.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),     // /api/v1/orders
        new HeaderApiVersionReader("X-API-Version"),   // header
        new QueryStringApiVersionReader("api-version") // ?api-version=1.0
    );
});

// Controller versioning
[ApiVersion("1.0")]
[ApiVersion("2.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class OrdersController : ControllerBase
{
    [HttpGet, MapToApiVersion("1.0")]
    public IActionResult GetV1() => Ok("v1 response");

    [HttpGet, MapToApiVersion("2.0")]
    public IActionResult GetV2() => Ok("v2 response with extras");
}
```

**Lead Q: URL segment vs header versioning — which do you recommend?**
> **URL segment** (`/v1/orders`) for public APIs — discoverable, cacheable, easy to test in browser. **Header** for internal/private APIs — cleaner URLs, but harder to test. **Never query string alone in production** — caches treat `?api-version=1` and `?api-version=2` as same URL unless cache key includes query params.

### Authentication & Authorization
```csharp
// JWT Bearer setup
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.Authority = "https://login.microsoftonline.com/{tenantId}/v2.0";
        o.Audience  = "api://my-app-client-id";
        o.TokenValidationParameters = new()
        {
            ValidateIssuerSigningKey = true,
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ClockSkew                = TimeSpan.FromMinutes(2)  // not 5min default
        };
        // Events for custom logic
        o.Events = new JwtBearerEvents
        {
            OnTokenValidated = ctx =>
            {
                // Add custom claims, check DB, etc.
                return Task.CompletedTask;
            }
        };
    });

// Policy-based authorization
builder.Services.AddAuthorization(o =>
{
    o.AddPolicy("OrdersWrite", p => p
        .RequireAuthenticatedUser()
        .RequireClaim("scope", "orders.write")
        .RequireRole("OrderManager", "Admin"));

    o.AddPolicy("SameRegionOnly", p =>
        p.AddRequirements(new SameRegionRequirement()));  // custom

    // Default policy applied when [Authorize] used without policy name
    o.DefaultPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();

    // Fallback policy — applied when NO [Authorize] attribute
    o.FallbackPolicy = o.DefaultPolicy;   // secure by default!
});

// Custom requirement handler
public class SameRegionHandler : AuthorizationHandler<SameRegionRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext ctx, SameRegionRequirement req)
    {
        var userRegion = ctx.User.FindFirstValue("region");
        var requestRegion = (ctx.Resource as HttpContext)?
            .GetRouteValue("region")?.ToString();
        if (userRegion == requestRegion) ctx.Succeed(req);
        return Task.CompletedTask;
    }
}
```

### Resilient HttpClient with IHttpClientFactory + Polly
```csharp
// Typed client
public class PaymentClient(HttpClient http)
{
    public async Task<PaymentResult> ChargeAsync(ChargeRequest req)
        => await http.PostAsJsonAsync("/charge", req)
                     .GetFromJsonAsync<PaymentResult>();
}

// Registration with resilience pipeline (.NET 8+ Microsoft.Extensions.Http.Resilience)
builder.Services.AddHttpClient<PaymentClient>(c =>
{
    c.BaseAddress = new Uri("https://payments.internal/");
    c.Timeout = TimeSpan.FromSeconds(30);
})
.AddStandardResilienceHandler(o =>
{
    // Configures: retry, circuit breaker, timeout, hedge, rate limiter
    o.Retry.MaxRetryAttempts = 3;
    o.Retry.Delay = TimeSpan.FromMilliseconds(200);
    o.Retry.BackoffType = DelayBackoffType.Exponential;
    o.Retry.ShouldHandle = args =>
        ValueTask.FromResult(args.Outcome.Result?.StatusCode
            is HttpStatusCode.TooManyRequests or HttpStatusCode.ServiceUnavailable);
    o.CircuitBreaker.FailureRatio = 0.5;
    o.CircuitBreaker.SamplingDuration = TimeSpan.FromSeconds(10);
});

// WHY IHttpClientFactory? Manages HttpClient lifecycle — avoids socket exhaustion
// (new HttpClient() per request leaks sockets for TIME_WAIT duration ~4 min)
// Factory pools handlers, rotates DNS, respects DI lifetime
```

### Problem Details — RFC 7807 (Industry Standard Error Response)
```csharp
builder.Services.AddProblemDetails(o =>
{
    o.CustomizeProblemDetails = ctx =>
    {
        ctx.ProblemDetails.Extensions["traceId"] =
            Activity.Current?.Id ?? ctx.HttpContext.TraceIdentifier;
        ctx.ProblemDetails.Extensions["environment"] =
            ctx.HttpContext.RequestServices
               .GetRequiredService<IHostEnvironment>().EnvironmentName;
    };
});

// Returns standard shape:
// {
//   "type": "https://tools.ietf.org/html/rfc7807",
//   "title": "Validation Failed",
//   "status": 422,
//   "detail": "One or more fields failed validation.",
//   "traceId": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01",
//   "errors": { "Email": ["Invalid email format"] }
// }
```

### Rate Limiting (.NET 7+)
```csharp
builder.Services.AddRateLimiter(o =>
{
    o.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    // Fixed window: 100 req per user per minute
    o.AddPolicy("PerUserFixed", ctx =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: ctx.User?.Identity?.Name ?? ctx.Connection.RemoteIpAddress?.ToString(),
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 10   // buffer 10 requests before rejecting
            }));

    // Sliding window for burst-sensitive endpoints
    o.AddSlidingWindowLimiter("StrictSliding", o =>
    {
        o.PermitLimit = 20;
        o.Window = TimeSpan.FromSeconds(30);
        o.SegmentsPerWindow = 6;  // 6 x 5-second segments
    });

    // Concurrency limiter for expensive endpoints
    o.AddConcurrencyLimiter("HeavyReport", o =>
    {
        o.PermitLimit = 5;   // only 5 simultaneous report generations
        o.QueueLimit = 2;
    });
});

// Apply to endpoint:
app.MapGet("/reports/heavy", GenerateReport)
   .RequireRateLimiting("HeavyReport");
```

### Output Caching (.NET 7+)
```csharp
builder.Services.AddOutputCache(o =>
{
    o.AddBasePolicy(p => p.Expire(TimeSpan.FromMinutes(1)));
    o.AddPolicy("ProductCatalog", p => p
        .Expire(TimeSpan.FromMinutes(30))
        .Tag("products")                   // for targeted invalidation
        .VaryByRouteValue("category")      // separate cache per category
        .VaryByHeader("Accept-Language")); // separate cache per locale
});

// Invalidate by tag (e.g., after product update):
var cache = app.Services.GetRequiredService<IOutputCacheStore>();
await cache.EvictByTagAsync("products", CancellationToken.None);

// Endpoint:
app.MapGet("/catalog/{category}", GetCatalog)
   .CacheOutput("ProductCatalog");
```

### Background Services & Hosted Services
```csharp
// IHostedService: manual Start/Stop
// BackgroundService: abstract, overrides ExecuteAsync (preferred)
public class OutboxProcessor(IServiceScopeFactory scopeFactory, ILogger<OutboxProcessor> log)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await using var timer = new PeriodicTimer(TimeSpan.FromSeconds(10));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            using var scope = scopeFactory.CreateScope();  // new scope per tick
            var processor = scope.ServiceProvider.GetRequiredService<IOutboxService>();
            try
            {
                await processor.ProcessPendingAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                log.LogError(ex, "Outbox processing failed");
                // don't throw — keeps the background service alive
            }
        }
    }
}

builder.Services.AddHostedService<OutboxProcessor>();
```

### Health Checks
```csharp
builder.Services.AddHealthChecks()
    .AddSqlServer(connStr, tags: ["db", "ready"])
    .AddRedis(redisConnStr, tags: ["cache", "ready"])
    .AddUrlGroup(new Uri("https://payment.api/health"), tags: ["external"])
    .AddCheck<CustomBusinessCheck>("business-rules", tags: ["ready"]);

// Separate liveness vs readiness (K8s pattern)
app.MapHealthChecks("/health/live",  new() { Predicate = _ => false });  // always alive if process up
app.MapHealthChecks("/health/ready", new() { Predicate = hc => hc.Tags.Contains("ready") });
app.MapHealthChecks("/health",       new()
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse  // rich JSON output
});
```

### Key Lead-Level Q&A

**Q: How do you handle distributed tracing across microservices?**
> Use `Activity` / `ActivitySource` (System.Diagnostics) + W3C Trace Context propagation. Wire up OpenTelemetry SDK with OTLP exporter to Jaeger/Zipkin/App Insights. Middleware auto-propagates `traceparent` header. Add `AddSource("MyApp")` in OTEL setup to capture custom spans.

**Q: How would you design API versioning for a 3-year-old platform?**
> 1. Assess — count active consumers per version, deprecation policy (e.g., 12-month sunset). 2. URL segment for external, header for internal. 3. Create version-specific DTOs, not model classes. 4. Use `[MapToApiVersion]` to share controller, split action. 5. Return `Sunset` + `Deprecation` headers on old versions. 6. Generate per-version Swagger docs.

**Q: What is the `[ApiController]` attribute doing under the hood?**
> Enables: (1) automatic 400 response on `ModelState.IsValid == false` without `if (!ModelState.IsValid)` checks, (2) binding source inference (`[FromBody]`, `[FromRoute]`, `[FromQuery]` inferred), (3) problem details for client errors. It's a composite attribute — shorthand for 3 separate behaviors.

**Q: How do you prevent N+1 queries in a REST API backed by EF Core?**
> 1. Eager loading with `.Include()` for known relationships. 2. Projection with `.Select()` to DTOs — only fetch needed columns. 3. Split queries (`.AsSplitQuery()`) for collection navigations. 4. Batch with DataLoader pattern (GraphQL) or manual grouping. 5. Add EF Core interceptor to log query count per request, alert if > N.

**Q: Transient fault handling — what's your default strategy?**
> `Microsoft.Extensions.Http.Resilience` with `AddStandardResilienceHandler()` covers: retry with jitter, circuit breaker, timeout. Customize `ShouldHandle` predicate to exclude non-transient (4xx). Add `Polly.RateLimiting` for downstream rate limits (429 + `Retry-After` header parsing).

**Q: How do you design a secure internal API between microservices?**
> 1. mTLS at infrastructure level (Service Mesh / Container Apps with Dapr). 2. JWT from Azure AD — each service gets its own App Registration, issues tokens with `scope` or `roles` claims. 3. Use Managed Identity (`DefaultAzureCredential`) — no secrets in config. 4. Network policy: allow only within same VNet/environment. 5. `[RequireScope("orders.read")]` on endpoints.

**Q: What is the Outbox pattern and why does it matter in APIs?**
> When an API saves to DB AND publishes an event, both operations must atomically succeed or both fail. Outbox: write event to `OutboxMessages` table in same DB transaction. Background service polls and publishes to message broker. Guarantees at-least-once delivery without distributed transaction (no two-phase commit). Mark messages `Processed` after publish; use idempotency keys on consumers.

**Q: How do you implement idempotent API endpoints?**
```csharp
// Client sends Idempotency-Key header (UUID per request)
[HttpPost("orders")]
public async Task<IActionResult> CreateOrder(
    [FromHeader(Name = "Idempotency-Key")] string? idempotencyKey,
    CreateOrderRequest request)
{
    if (idempotencyKey != null)
    {
        var cached = await _cache.GetAsync<OrderResult>($"idem:{idempotencyKey}");
        if (cached != null) return Ok(cached);   // replay stored response
    }

    var result = await _orderService.CreateAsync(request);

    if (idempotencyKey != null)
        await _cache.SetAsync($"idem:{idempotencyKey}", result, TimeSpan.FromHours(24));

    return CreatedAtRoute("GetOrder", new { result.Id }, result);
}
// KEY: same key → same response, no duplicate creation
```

---

## 7. Webhooks — Design & Production Patterns

```
┌─────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: Webhooks = "Don't call us, we'll call you"   │
│  HTTP callbacks pushed by producer to consumer's endpoint   │
│  Pull (polling) = consumer asks "anything new?"             │
│  Push (webhook) = producer calls "here's what happened"     │
└─────────────────────────────────────────────────────────────┘
```

### Webhook Architecture
```
PRODUCER side                           CONSUMER side
──────────────                          ─────────────
Event occurs                            HTTPS endpoint registered
    ↓                                       ↑
Write to outbox DB ──── retry loop ────→ POST /webhooks/orders
    ↓                                       ↓
Background sender                       Validate HMAC signature
    ↓                                       ↓
Sign payload (HMAC-SHA256)              Enqueue to internal queue
    ↓                                       ↓
POST with timeout                       Return 200 IMMEDIATELY
    ↓                                       ↓
On 2xx → mark delivered             Process asynchronously
On 4xx → dead letter (no retry)         ↓
On 5xx → retry with backoff         Idempotency check (dedup key)
    ↓
Retry budget exhausted → dead letter
```

### Producer: Secure Outgoing Webhooks
```csharp
// Sign every payload with HMAC-SHA256 (GitHub / Stripe pattern)
public class WebhookSender(HttpClient http, IWebhookSecretStore secrets)
{
    public async Task SendAsync(WebhookSubscription sub, WebhookEvent evt)
    {
        var payload = JsonSerializer.Serialize(evt);
        var payloadBytes = Encoding.UTF8.GetBytes(payload);

        // Per-subscriber signing secret — rotate without breaking other consumers
        var secret = await secrets.GetSecretAsync(sub.SubscriberId);
        var signature = ComputeHmac(payloadBytes, secret);

        using var request = new HttpRequestMessage(HttpMethod.Post, sub.EndpointUrl)
        {
            Content = new StringContent(payload, Encoding.UTF8, "application/json")
        };

        request.Headers.Add("X-Webhook-Signature", $"sha256={signature}");
        request.Headers.Add("X-Webhook-Event",     evt.EventType);
        request.Headers.Add("X-Webhook-Id",        evt.EventId);      // idempotency
        request.Headers.Add("X-Webhook-Timestamp", evt.OccurredAt.ToString("O")); // replay prevention

        var response = await http.SendAsync(request);

        if ((int)response.StatusCode >= 500)
            throw new WebhookDeliveryException($"Server error {response.StatusCode}");

        if ((int)response.StatusCode >= 400)
            await HandleDeadLetterAsync(sub, evt, response.StatusCode); // 4xx = consumer bug, no retry
    }

    private static string ComputeHmac(byte[] payload, string secret)
    {
        var keyBytes = Encoding.UTF8.GetBytes(secret);
        using var hmac = new HMACSHA256(keyBytes);
        return Convert.ToHexString(hmac.ComputeHash(payload)).ToLower();
    }
}
```

### Producer: Retry with Exponential Backoff + Dead Letter
```csharp
public class WebhookOutboxProcessor(IServiceScopeFactory scopeFactory) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        await using var timer = new PeriodicTimer(TimeSpan.FromSeconds(15));
        while (await timer.WaitForNextTickAsync(ct))
        {
            using var scope = scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var sender = scope.ServiceProvider.GetRequiredService<WebhookSender>();

            // Fetch pending/retryable — not yet dead-lettered
            var pending = await db.WebhookOutbox
                .Where(w => w.Status == WebhookStatus.Pending
                         && w.NextRetryAt <= DateTime.UtcNow
                         && w.AttemptCount < 10)      // max 10 attempts
                .OrderBy(w => w.CreatedAt)
                .Take(50)
                .ToListAsync(ct);

            foreach (var item in pending)
            {
                try
                {
                    await sender.SendAsync(item.Subscription, item.Event);
                    item.Status = WebhookStatus.Delivered;
                }
                catch
                {
                    item.AttemptCount++;
                    item.NextRetryAt = DateTime.UtcNow.AddSeconds(
                        Math.Min(30 * Math.Pow(2, item.AttemptCount), 3600)); // cap at 1hr
                    if (item.AttemptCount >= 10)
                        item.Status = WebhookStatus.DeadLettered;
                }
                await db.SaveChangesAsync(ct);
            }
        }
    }
}
```

### Consumer: Secure Incoming Webhook Endpoint
```csharp
[ApiController]
[Route("webhooks")]
public class WebhookController(IWebhookProcessor processor, IOptions<WebhookOptions> opts) : ControllerBase
{
    [HttpPost("github")]
    public async Task<IActionResult> ReceiveGitHub()
    {
        // 1. Read raw body BEFORE model binding (signature must match raw bytes)
        Request.EnableBuffering();
        using var ms = new MemoryStream();
        await Request.Body.CopyToAsync(ms);
        var rawBody = ms.ToArray();
        Request.Body.Position = 0;

        // 2. Validate HMAC-SHA256 signature — REJECT if invalid
        var signature = Request.Headers["X-Hub-Signature-256"].FirstOrDefault();
        if (!ValidateSignature(rawBody, signature, opts.Value.GitHubSecret))
            return Unauthorized("Invalid signature");

        // 3. Replay attack prevention: check timestamp freshness
        var timestamp = Request.Headers["X-Webhook-Timestamp"].FirstOrDefault();
        if (DateTimeOffset.TryParse(timestamp, out var ts)
            && DateTimeOffset.UtcNow - ts > TimeSpan.FromMinutes(5))
            return BadRequest("Webhook too old — possible replay attack");

        // 4. Idempotency: check event ID to deduplicate retries
        var eventId = Request.Headers["X-Webhook-Id"].FirstOrDefault();
        if (eventId != null && await processor.IsAlreadyProcessedAsync(eventId))
            return Ok("Already processed");   // 200, not error — tells producer to stop retrying

        // 5. Deserialize and ENQUEUE — do NOT process synchronously
        var evt = JsonSerializer.Deserialize<GitHubEvent>(rawBody);
        await processor.EnqueueAsync(evt!, eventId);

        // 6. Return 200 FAST — producer has short timeout (e.g. 10s)
        return Ok();
    }

    private static bool ValidateSignature(byte[] payload, string? header, string secret)
    {
        if (header is null || !header.StartsWith("sha256=")) return false;
        var received = header["sha256=".Length..];
        var keyBytes = Encoding.UTF8.GetBytes(secret);
        using var hmac = new HMACSHA256(keyBytes);
        var expected = Convert.ToHexString(hmac.ComputeHash(payload)).ToLower();
        // CryptographicOperations.FixedTimeEquals prevents timing attacks
        return CryptographicOperations.FixedTimeEquals(
            Encoding.ASCII.GetBytes(received),
            Encoding.ASCII.GetBytes(expected));
    }
}
```

### Webhook Subscription Management
```csharp
// Schema: webhook subscriptions table
// ┌────────────────────────────────────────────────────────┐
// │ Id | SubscriberId | EndpointUrl | EventTypes[] | Secret│
// │    | Active | CreatedAt | LastDeliveredAt | FailCount  │
// └────────────────────────────────────────────────────────┘

// Registration endpoint
[HttpPost("subscriptions")]
public async Task<IActionResult> Subscribe(WebhookSubscribeRequest req)
{
    // Validate endpoint BEFORE saving — send a test ping
    var verified = await _verifier.PingEndpointAsync(req.EndpointUrl);
    if (!verified) return BadRequest("Endpoint did not respond to verification ping");

    var secret = GenerateSecret();   // per-subscriber, returned ONCE to caller
    var sub = new WebhookSubscription
    {
        SubscriberId = req.SubscriberId,
        EndpointUrl  = req.EndpointUrl,
        EventTypes   = req.EventTypes,
        Secret       = _encryptor.Encrypt(secret),  // store encrypted
        Active       = true
    };
    await _db.AddAsync(sub);
    await _db.SaveChangesAsync();

    return Ok(new { sub.Id, Secret = secret });  // return plaintext ONCE only
}

// Auto-disable after N consecutive failures (circuit breaker at subscription level)
if (sub.ConsecutiveFailures >= 5)
{
    sub.Active = false;
    await _notifier.SendDeactivationEmailAsync(sub.SubscriberId);
}
```

### Event Ordering & Versioning
```csharp
// Webhook payload — always include version + sequence number
public record WebhookEvent
{
    public string EventId      { get; init; } = Guid.NewGuid().ToString(); // idempotency key
    public string EventType    { get; init; } = "";   // "order.created", "order.shipped"
    public int    Version      { get; init; } = 1;    // payload schema version
    public long   Sequence     { get; init; }         // monotonically increasing per resource
    public DateTimeOffset OccurredAt { get; init; } = DateTimeOffset.UtcNow;
    public string ResourceId   { get; init; } = "";   // e.g. orderId — for ordering
    public object Data         { get; init; } = new();
}

// Consumer: handle out-of-order delivery
// PROBLEM: order.shipped may arrive before order.created (network variance)
// SOLUTION 1: sequence check — reject or re-queue if sequence gap
// SOLUTION 2: upsert/idempotent handler — apply regardless of order
// SOLUTION 3: EventGrid / Service Bus — sequence guarantees within partition
```

### Azure Event Grid as Webhook Backbone
```
┌─────────────────────────────────────────────────────────────────┐
│  Event Grid = managed webhook fan-out + retry + dead letter     │
│                                                                 │
│  Your app → publishes to Event Grid Topic                       │
│  Event Grid → delivers to N subscribers (webhooks, queues, etc.)│
│  Built-in: retry (24hr), dead letter to blob, batching          │
└─────────────────────────────────────────────────────────────────┘
```
```csharp
// Publish to Event Grid (CloudEvents schema — industry standard)
var client = new EventGridPublisherClient(
    new Uri("https://my-topic.eastus2-1.eventgrid.azure.net/api/events"),
    new AzureKeyCredential(topicKey));

var evt = new CloudEvent(
    source: "/orders/service",
    type:   "com.mycompany.orders.created",
    data:   new { OrderId = 42, CustomerId = 7 })
{
    Id      = Guid.NewGuid().ToString(),  // idempotency key
    Time    = DateTimeOffset.UtcNow,
    Subject = "orders/42"
};

await client.SendEventAsync(evt);

// Consumer receives with signature validation (Event Grid signs delivery)
// Event Grid provides: CloudEvents mode, retry up to 24hrs, exponential backoff,
// dead letter to Azure Storage Blob after exhaustion
```

### Key Lead-Level Q&A

**Q: Why must webhook consumers return 200 immediately?**
> Producers have short HTTP timeouts (5–30s). If consumer does synchronous DB writes/processing, any slowness or crash returns 5xx and triggers producer retry — causing duplicate deliveries. Queue-first pattern: insert to queue/DB in <100ms, return 200. Background worker processes at own pace.

**Q: How do you prevent replay attacks on webhooks?**
> 1. Include timestamp in signed payload (`X-Webhook-Timestamp`). 2. Consumer checks timestamp is within window (±5 minutes). 3. Cache processed event IDs (Redis/DB) for dedup window. 4. Per-subscriber secrets — compromised secret only affects one subscriber.

**Q: Producer delivers the same event twice — how does consumer handle it?**
> Idempotency key (`X-Webhook-Id`) stored in Redis or DB. Before processing, check if key exists. If yes → return 200 (not error). If no → process + store key with TTL. This is "at-least-once delivery + consumer idempotency = effectively-once semantics."

**Q: How do you handle a consumer endpoint going down for 2 hours?**
> Producer's outbox + retry schedule absorbs the outage. With exponential backoff capped at 1 hour: retries at 30s, 1m, 2m, 4m, 8m, 16m, 32m, 1hr, 1hr... continues delivering for 24hr+ without burning the consumer. After N failures, notify the subscriber and optionally disable subscription with re-enable mechanism.

**Q: How do you test webhooks locally during development?**
> ngrok or VS Dev Tunnels (`devtunnel host`) expose localhost via HTTPS. Alternative: local test harness that POSTs mock payloads with correct signature. For integration tests: spin up test server with `WebApplicationFactory`, POST signed payload directly.

**Q: Webhook vs Polling vs WebSocket vs SSE — when to choose?**
```
Webhooks:   Push, HTTP, consumer must have public endpoint, event-driven
            Best for: B2B integrations, payment callbacks, CRM sync

Polling:    Consumer requests every N seconds, simple, wastes resources
            Best for: low-frequency events, consumer behind firewall/NAT

WebSocket:  Bidirectional, persistent TCP, low latency
            Best for: real-time chat, live collaboration, gaming

SSE:        Server push over HTTP, one-directional, auto-reconnect
            Best for: live dashboards, notifications, stock tickers
```

**Q: How do you version webhook payloads without breaking consumers?**
> 1. Additive changes (new optional fields) — non-breaking, just document. 2. Breaking changes: bump `version` field in payload + new event type (`order.created.v2`). 3. Support both types simultaneously during migration window. 4. Communicate `Sunset` date for old version. 5. Consumers use `eventType` discriminator to route to correct handler version.

**Q: How do you implement webhook signature verification to avoid timing attacks?**
> Use `CryptographicOperations.FixedTimeEquals()` (not string `==`). String equality short-circuits on first mismatch — leaks timing information usable for HMAC forgery. Fixed-time comparison always takes constant time regardless of where strings differ.

---

---

## Section 8 — Azure Entra ID: OAuth2/OIDC, App Registrations, Scopes, Roles & Managed Identities

> **Lead-level framing:** You don't just "add auth" — you design a trust boundary. Every token has an audience, every claim has a purpose, and every identity (human or workload) should follow least-privilege. Managed Identities eliminate credential rotation entirely for workload-to-Azure-service communication.

---

### 8.1 Mental Model: The Three Identity Planes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     AZURE ENTRA ID (formerly AAD)                           │
│                                                                             │
│  HUMAN IDENTITIES          WORKLOAD IDENTITIES       EXTERNAL IDENTITIES   │
│  ┌───────────────┐        ┌───────────────────┐     ┌───────────────────┐  │
│  │ Users/Groups  │        │ App Registrations │     │ B2C / External    │  │
│  │ + MFA         │        │ Service Principals│     │ Identity Provider │  │
│  │ + Conditional │        │ Managed Identities│     │ (Google, GitHub)  │  │
│  │   Access      │        │ (System/User)     │     │                   │  │
│  └───────────────┘        └───────────────────┘     └───────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘

OAuth2/OIDC: How identities authenticate and get tokens
App Registrations: How your API/app is registered as a resource in Entra ID
Scopes & Roles: What the token authorizes (delegated vs application permissions)
Managed Identities: Pod/VM/Function authenticates to Azure services WITHOUT passwords
```

---

### 8.2 OAuth2 / OIDC Flows — Which to Use When

| Flow | Use Case | Token Type | Lead Interview Trigger |
|------|----------|------------|----------------------|
| **Authorization Code + PKCE** | SPA / Mobile app (public client) | Access + ID + Refresh | "User logs in via browser" |
| **Client Credentials** | Service-to-service (no user) | Access token only | "Backend calls another API" |
| **On-Behalf-Of (OBO)** | API calls downstream API on user's behalf | Delegated access token | "Middle-tier API propagates user identity" |
| **Device Code** | CLI tools, IoT, headless | Access + Refresh | "No browser available" |
| **Implicit** | Legacy SPAs (deprecated) | Access + ID | "Don't use this — use Auth Code + PKCE" |

```
Authorization Code + PKCE (most common for user-facing apps):

Browser                  Your API               Entra ID
   │── GET /login ──────────────────────────────────▶│
   │   redirect_uri, code_challenge(PKCE), scope     │
   │◀─ 302 redirect to Entra ID login ───────────────│
   │── user logs in ──────────────────────────────▶  │
   │◀─ 302 redirect back with ?code=xyz ──────────── │
   │── POST /token (code + code_verifier) ─────────▶ │
   │◀─ { access_token, id_token, refresh_token } ─── │
   │── GET /api/resource Authorization: Bearer <AT>─▶│
   │                          validates AT via JWKS   │
   │◀─ 200 data ──────────────────────────────────── │
```

---

### 8.3 App Registration: The Complete Picture

An **App Registration** is the identity record of your application in Entra ID. Every API and every client that calls it needs one.

```
┌──────────────────────────────────────────────────────────────────┐
│  App Registration: "MyApp-API"                                   │
│                                                                  │
│  Application ID (Client ID): 11111111-aaaa-bbbb-cccc-dddddddddd  │
│  Tenant ID:                  22222222-aaaa-bbbb-cccc-dddddddddd  │
│  Application ID URI:         api://11111111-aaaa-bbbb-cccc-ddd   │
│                                                                  │
│  EXPOSE AN API (what this app offers to callers):                │
│  ├── Scope: api://11111111.../Orders.Read    (delegated)         │
│  ├── Scope: api://11111111.../Orders.Write   (delegated)         │
│  └── App Role: Order.Admin                  (application)       │
│                                                                  │
│  APP ROLES (assigned to users/groups or other apps):            │
│  ├── Role: "Reader"  → assigned to Group "SalesTeam"            │
│  └── Role: "Admin"   → assigned to Service Principal "BatchJob" │
│                                                                  │
│  CERTIFICATES & SECRETS (for Client Credentials flow):          │
│  └── Client Secret: xxxxxxxx (or Certificate thumbprint)        │
└──────────────────────────────────────────────────────────────────┘
```

**Create via Azure CLI:**
```bash
# Register the API app
az ad app create \
  --display-name "MyApp-API" \
  --sign-in-audience AzureADMyOrg

# Get the app ID
APP_ID=$(az ad app list --display-name "MyApp-API" --query "[0].appId" -o tsv)

# Set the Application ID URI
az ad app update --id $APP_ID \
  --identifier-uris "api://$APP_ID"

# Add a scope (delegated permission)
az ad app update --id $APP_ID --set oauth2Permissions='[{
  "adminConsentDescription": "Read orders",
  "adminConsentDisplayName": "Orders.Read",
  "id": "aaaaaaaa-1111-2222-3333-444444444444",
  "isEnabled": true,
  "type": "User",
  "userConsentDescription": "Read your orders",
  "userConsentDisplayName": "Read orders",
  "value": "Orders.Read"
}]'

# Add an App Role
az ad app update --id $APP_ID --set appRoles='[{
  "allowedMemberTypes": ["Application"],
  "description": "Full admin access to orders",
  "displayName": "Order.Admin",
  "id": "bbbbbbbb-1111-2222-3333-444444444444",
  "isEnabled": true,
  "value": "Order.Admin"
}]'

# Create a Service Principal for the app
az ad sp create --id $APP_ID
```

---

### 8.4 Scopes vs App Roles — The Lead-Level Distinction

| | **Scopes (Delegated Permissions)** | **App Roles (Application Permissions)** |
|--|-------------------------------------|----------------------------------------|
| **Who acts** | User (delegated to client app) | Application itself (no user) |
| **Token subject** | User's OID | Service Principal's OID |
| **Claim in token** | `scp: "Orders.Read"` | `roles: ["Order.Admin"]` |
| **Consent** | User or admin consents | Admin-only consent |
| **Use case** | User logs in → reads their own orders | Background job → reads ALL orders |
| **Flow** | Auth Code, OBO | Client Credentials |

**Validating in .NET 8 API:**
```csharp
// Program.cs
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));

builder.Services.AddAuthorization(options =>
{
    // Delegated scope: user called us with their token
    options.AddPolicy("ReadOrders", policy =>
        policy.RequireScope("Orders.Read"));          // checks 'scp' claim

    // App role: a service/daemon called us
    options.AddPolicy("AdminOrders", policy =>
        policy.RequireRole("Order.Admin"));           // checks 'roles' claim

    // Either human or service can read
    options.AddPolicy("ReadOrdersAny", policy =>
        policy.RequireAssertion(ctx =>
            ctx.User.HasClaim("scp", "Orders.Read") ||
            ctx.User.IsInRole("Order.Admin")));
});

// appsettings.json
{
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "TenantId": "22222222-aaaa-bbbb-cccc-dddddddddd",
    "ClientId": "11111111-aaaa-bbbb-cccc-dddddddddd",   // audience validation
    "Audience": "api://11111111-aaaa-bbbb-cccc-dddddddddd"
  }
}
```

```csharp
// Minimal API endpoints with policy enforcement
app.MapGet("/orders", async (IOrderService svc) => await svc.GetAllAsync())
   .RequireAuthorization("ReadOrdersAny");

app.MapDelete("/orders/{id}", async (int id, IOrderService svc) => await svc.DeleteAsync(id))
   .RequireAuthorization("AdminOrders");   // only service principals with Order.Admin role
```

---

### 8.5 On-Behalf-Of (OBO) — Middle-Tier Propagation

The most misunderstood flow. Used when your API (tier 2) needs to call a downstream API (tier 3) **as the original user**, not as itself.

```
User ──[User Token for API-A]──▶ API-A
                                   │
                                   │ OBO Exchange (POST /oauth2/v2.0/token)
                                   │ grant_type=urn:ietf:params:oauth2:grant-type:jwt-bearer
                                   │ assertion=<User Token for API-A>
                                   │ requested_token_use=on_behalf_of
                                   │ scope=api://API-B/.default
                                   ▼
                                Entra ID issues new token (subject=User, audience=API-B)
                                   │
                               API-A ──[User Token for API-B]──▶ API-B
```

```csharp
// In API-A: exchange the incoming user token for a downstream token
public class OrderService
{
    private readonly ITokenAcquisition _tokenAcquisition;

    public async Task<IEnumerable<Order>> GetOrdersAsync()
    {
        // Acquires token on behalf of the currently authenticated user
        string downstreamToken = await _tokenAcquisition.GetAccessTokenForUserAsync(
            new[] { "api://inventory-api-client-id/Inventory.Read" });

        _httpClient.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", downstreamToken);

        return await _httpClient.GetFromJsonAsync<IEnumerable<Order>>("/inventory");
    }
}

// appsettings.json — API-A needs its own client secret to do OBO exchange
{
  "AzureAd": {
    "TenantId": "...",
    "ClientId": "api-a-client-id",
    "ClientSecret": "..."          // or use Managed Identity + federated credential
  }
}
```

---

### 8.6 Managed Identities — Eliminating Credential Rotation

> **Key Insight:** A Managed Identity is a Service Principal whose credentials are managed entirely by Azure. The app never sees a password. The Azure runtime (VM, AKS node, Function, Container App) acquires tokens from a local metadata endpoint — no secret in config, no KeyVault fetch for the identity itself.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ WITHOUT Managed Identity:                                                    │
│   App → reads ClientSecret from config → POST /token → gets access token    │
│   Problem: secret expires, rotates, leaks in logs, stored in KeyVault       │
│                                                                              │
│ WITH Managed Identity:                                                       │
│   App → GET http://169.254.169.254/metadata/identity/oauth2/token           │
│          (Azure IMDS — local metadata endpoint, no network call to AAD)     │
│        → gets access token automatically                                     │
│   Problem: none. Azure rotates credentials transparently.                   │
└──────────────────────────────────────────────────────────────────────────────┘
```

**System-Assigned vs User-Assigned:**
```
System-Assigned:                    User-Assigned:
├── Tied to one resource            ├── Standalone resource (reusable)
├── Deleted when resource deleted   ├── Persists independently
├── One identity per resource       ├── Assign to multiple resources
└── Use: single-app scenarios       └── Use: shared identity across services
```

**Enable on AKS (Workload Identity — the modern approach):**
```bash
# 1. Enable OIDC issuer and Workload Identity on AKS cluster
az aks update -g myRG -n myAKS \
  --enable-oidc-issuer \
  --enable-workload-identity

# 2. Create a User-Assigned Managed Identity
az identity create -g myRG -n myapp-identity

IDENTITY_CLIENT_ID=$(az identity show -g myRG -n myapp-identity --query clientId -o tsv)
OIDC_ISSUER=$(az aks show -g myRG -n myAKS --query oidcIssuerProfile.issuerUrl -o tsv)

# 3. Federate the Kubernetes Service Account with the Managed Identity
az identity federated-credential create \
  --name myapp-federated \
  --identity-name myapp-identity \
  --resource-group myRG \
  --issuer $OIDC_ISSUER \
  --subject "system:serviceaccount:myapp:myapp-sa"   # namespace:serviceaccount

# 4. Grant the identity access to Azure resources
az role assignment create \
  --assignee $IDENTITY_CLIENT_ID \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/.../resourceGroups/myRG/providers/Microsoft.KeyVault/vaults/myKV
```

**Kubernetes Service Account + Pod annotation:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
  namespace: myapp
  annotations:
    azure.workload.identity/client-id: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"  # Managed Identity client ID

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
  namespace: myapp
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"   # ← inject OIDC token volume
    spec:
      serviceAccountName: myapp-sa             # ← linked to Managed Identity above
      containers:
      - name: api
        image: myregistry.io/myapp:1.0
```

**In .NET — DefaultAzureCredential automatically picks up Workload Identity:**
```csharp
// Works locally (dev credentials) AND in AKS (Workload Identity) AND in Azure (Managed Identity)
// Zero code change needed between environments
var credential = new DefaultAzureCredential();

// Key Vault
var kvClient = new SecretClient(
    new Uri("https://myKV.vault.azure.net"),
    credential);                               // ← no connection strings, no secrets

// Service Bus
var sbClient = new ServiceBusClient(
    "mybus.servicebus.windows.net",
    credential);                               // ← no SAS keys

// Storage
var blobClient = new BlobServiceClient(
    new Uri("https://mystorage.blob.core.windows.net"),
    credential);
```

**DefaultAzureCredential resolution order:**
```
1. EnvironmentCredential          (AZURE_CLIENT_ID + AZURE_CLIENT_SECRET env vars)
2. WorkloadIdentityCredential     (AKS Workload Identity — OIDC token file)
3. ManagedIdentityCredential      (VM/Function/Container App system/user identity)
4. SharedTokenCacheCredential     (Visual Studio cached token)
5. VisualStudioCredential
6. AzureCliCredential             (az login — local dev)
7. AzurePowerShellCredential
8. InteractiveBrowserCredential   (last resort)
```

---

### 8.7 Conditional Access & Token Validation — Lead-Level Checklist

**What your API MUST validate on every token:**
```csharp
// These are validated automatically by AddMicrosoftIdentityWebApi:
// ✔ Signature: verify against Entra ID JWKS endpoint (cached, auto-refreshed)
// ✔ Expiry (exp claim): token not expired
// ✔ Audience (aud claim): matches your app's Application ID URI
// ✔ Issuer (iss claim): matches your tenant's issuer URL
// ✔ Not Before (nbf claim): token is valid now

// What you must validate YOURSELF in code:
// ✔ Scope or Role: does token have the right scp/roles claim?
// ✔ Tenant: is iss from YOUR tenant (multi-tenant apps must check this)
// ✔ Token version: v1 (iss=.../tenantId/) vs v2 (iss=.../v2.0/) — check manifest
```

**Token version gotcha (v1 vs v2):**
```json
// v1 token (default if accessTokenAcceptedVersion is null):
{ "iss": "https://sts.windows.net/tenantId/", "aud": "client-id-guid", "scp": "..." }

// v2 token (accessTokenAcceptedVersion: 2 in app manifest):
{ "iss": "https://login.microsoftonline.com/tenantId/v2.0", "aud": "api://client-id", "scp": "..." }
```
```bash
# Set to v2 in app manifest:
az ad app update --id $APP_ID --set api.requestedAccessTokenVersion=2
```

---

### 8.8 Interview Q&A — Azure Entra ID

**Q: What's the difference between a Scope and an App Role?**
> Scopes are delegated — a user grants a client app permission to act on their behalf. App Roles are application-level — the calling application itself is granted permission, with no user involved. Scopes appear in the `scp` claim, roles in the `roles` claim.

**Q: When would you use OBO vs Client Credentials in a microservices chain?**
> OBO when you need to propagate user identity downstream for audit trails, per-user data isolation, or user-specific resource access. Client Credentials when the middle-tier API is acting on its own behalf (batch jobs, system operations). OBO requires the middle-tier app to have a client secret or certificate — a Managed Identity with federated credential is a cleaner alternative in AKS.

**Q: What's the advantage of Workload Identity over pod-level Managed Identity (aad-pod-identity)?**
> `aad-pod-identity` used node-level MSI and annotated pods, with a custom webhook. Workload Identity uses the OIDC standard — the pod gets a projected service account token file, which is exchanged directly with Entra ID. It's more secure (token scoped to pod, short-lived), doesn't require privileged daemonset, and is the officially supported approach from AKS 1.24+.

**Q: DefaultAzureCredential fails in production. How do you debug it?**
> Enable diagnostic logging: `new DefaultAzureCredential(new DefaultAzureCredentialOptions { Diagnostics = { IsLoggingEnabled = true } })`. Check that `AZURE_CLIENT_ID` env var is set (for User-Assigned MI), that the pod has the `azure.workload.identity/use: "true"` label, that the service account annotation matches the Managed Identity client ID, and that the federated credential subject matches the `system:serviceaccount:namespace:name` exactly.

**Q: How do you handle token caching to avoid throttling Entra ID?**
> Microsoft.Identity.Web handles in-process token caching automatically. For distributed scenarios (multiple pods), add `builder.Services.AddDistributedTokenCaches().AddStackExchangeRedisCache(...)` to share the MSAL token cache across pod instances. MSAL automatically refreshes tokens before expiry using the refresh token.

---

## Section 9 — CI/CD: Blue-Green & Canary Deployments + SonarCloud Quality Gates

> **Lead-level framing:** Deployment strategy is a risk management decision. Blue-Green eliminates downtime and gives instant rollback but doubles infrastructure cost. Canary reduces blast radius by routing a fraction of traffic to the new version, letting you observe metrics before full rollout. Quality gates ensure neither strategy ships broken code.

---

### 9.1 Blue-Green Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BLUE-GREEN — MENTAL MODEL                            │
│                                                                         │
│  BLUE (current live)          GREEN (new version, ready)               │
│  ┌─────────────────┐          ┌─────────────────┐                      │
│  │  v1.0 Pods      │          │  v2.0 Pods      │                      │
│  │  (100% traffic) │          │  (0% traffic    │                      │
│  │                 │          │  — warming up)  │                      │
│  └─────────────────┘          └─────────────────┘                      │
│          ↑                            │                                 │
│    Azure LB / App Gateway             │ SWITCH (one DNS change)        │
│                                       ↓                                 │
│  After switch:                                                          │
│  BLUE  → standby (keep for rollback)                                    │
│  GREEN → 100% traffic (now "live")                                      │
│                                                                         │
│  Rollback: flip the switch back. Zero pod restarts.                    │
└─────────────────────────────────────────────────────────────────────────┘
```

#### Blue-Green on AKS with Kubernetes Services

**Strategy:** Two Deployments (`app-blue`, `app-green`), one Service with a `slot` label selector that you flip.

```yaml
# blue-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  namespace: myapp
spec:
  replicas: 3
  selector:
    matchLabels: { app: myapp, slot: blue }
  template:
    metadata:
      labels: { app: myapp, slot: blue }
    spec:
      containers:
      - name: api
        image: myregistry.io/myapp:1.0    # BLUE = current stable version

---
# green-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  namespace: myapp
spec:
  replicas: 3
  selector:
    matchLabels: { app: myapp, slot: green }
  template:
    metadata:
      labels: { app: myapp, slot: green }
    spec:
      containers:
      - name: api
        image: myregistry.io/myapp:2.0    # GREEN = new version being deployed

---
# service.yaml — the ONLY thing that changes during a blue-green switch
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: myapp
spec:
  selector:
    app: myapp
    slot: blue     # ← CHANGE THIS to "green" to switch traffic
  ports:
    - port: 80
      targetPort: 80
```

**Switch traffic (the actual deployment):**
```bash
# 1. Deploy green (while blue is still live)
kubectl apply -f green-deployment.yaml

# 2. Wait for green to be fully healthy
kubectl rollout status deployment/app-green -n myapp

# 3. Run smoke tests against green directly (port-forward or internal service)
kubectl port-forward deployment/app-green 8081:80 -n myapp &
curl http://localhost:8081/health   # green health check

# 4. SWITCH — patch the service selector (atomic, instant, no downtime)
kubectl patch service myapp-service -n myapp \
  -p '{"spec":{"selector":{"app":"myapp","slot":"green"}}}'

# 5. Verify traffic is on green
kubectl get endpoints myapp-service -n myapp   # should show green pod IPs

# 6. Keep blue running for 15 mins, then scale down (rollback window)
sleep 900 && kubectl scale deployment/app-blue --replicas=0 -n myapp

# ROLLBACK (if something goes wrong on green):
kubectl patch service myapp-service -n myapp \
  -p '{"spec":{"selector":{"app":"myapp","slot":"blue"}}}'
```

#### Blue-Green on Azure Container Apps (Revision-based)

```bash
# Deploy new revision (green) — no traffic yet
az containerapp revision copy \
  --name myapp \
  --resource-group myRG \
  --image myregistry.io/myapp:2.0 \
  --revision-suffix green-v2

# Split traffic: 0% green, 100% blue (verify green is healthy first)
az containerapp ingress traffic set \
  --name myapp --resource-group myRG \
  --revision-weight myapp--green-v2=0 myapp--blue-v1=100

# Switch: 100% green
az containerapp ingress traffic set \
  --name myapp --resource-group myRG \
  --revision-weight myapp--green-v2=100 myapp--blue-v1=0

# Rollback: flip back instantly
az containerapp ingress traffic set \
  --name myapp --resource-group myRG \
  --revision-weight myapp--green-v2=0 myapp--blue-v1=100
```

#### Blue-Green in Azure DevOps Pipeline

```yaml
# azure-pipelines-blue-green.yml
trigger:
  branches:
    include: [main]

variables:
  imageTag: $(Build.BuildId)
  containerRegistry: myregistry.azurecr.io

stages:
- stage: Build
  jobs:
  - job: BuildAndPush
    pool: { vmImage: ubuntu-latest }
    steps:
    - task: Docker@2
      inputs:
        command: buildAndPush
        repository: myapp
        dockerfile: Dockerfile
        containerRegistry: myACRServiceConnection
        tags: $(imageTag)

    - task: SonarCloudPrepare@1          # ← quality gate (see Section 9.3)
      inputs:
        SonarCloud: mySonarCloudConnection
        organization: my-org
        scannerMode: MSBuild
        projectKey: my-project

    - script: dotnet build --no-restore
    - script: dotnet test --no-build --collect:"XPlat Code Coverage"

    - task: SonarCloudAnalyze@1
    - task: SonarCloudPublish@1
      inputs:
        pollingTimeoutSec: 300

- stage: DeployGreen
  dependsOn: Build
  condition: succeeded()
  jobs:
  - job: DeployToGreen
    steps:
    - task: KubernetesManifest@1
      inputs:
        action: deploy
        kubernetesServiceConnection: myAKSConnection
        namespace: myapp
        manifests: k8s/green-deployment.yaml
        containers: myregistry.azurecr.io/myapp:$(imageTag)

    - script: |
        kubectl rollout status deployment/app-green -n myapp --timeout=5m
      displayName: Wait for green to be healthy

    - script: |
        # Smoke test green directly before switching
        POD=$(kubectl get pod -n myapp -l slot=green -o jsonpath='{.items[0].metadata.name}')
        kubectl exec $POD -n myapp -- curl -f http://localhost/health
      displayName: Smoke test green pods

- stage: SwitchTraffic
  dependsOn: DeployGreen
  condition: succeeded()
  jobs:
  - deployment: SwitchToGreen
    environment: production         # ← requires manual approval gate in ADO
    strategy:
      runOnce:
        deploy:
          steps:
          - script: |
              kubectl patch service myapp-service -n myapp \
                -p '{"spec":{"selector":{"app":"myapp","slot":"green"}}}'
            displayName: Switch service selector to green

          - script: |
              sleep 900 && \
              kubectl scale deployment/app-blue --replicas=0 -n myapp
            displayName: Scale down blue after 15min rollback window
```

---

### 9.2 Canary Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CANARY — MENTAL MODEL                                │
│                                                                         │
│  STABLE (v1.0, 90%)           CANARY (v2.0, 10%)                       │
│  ┌─────────────────┐          ┌─────────────────┐                      │
│  │  9 Pods         │          │  1 Pod          │                      │
│  │                 │◀─────────│                 │                      │
│  └─────────────────┘  Traffic │ └───────────────┘                      │
│                         split                                           │
│  Watch metrics for 10%:                                                 │
│   • Error rate: < 0.1%?  ✔ promote → 20% → 50% → 100%                 │
│   • P99 latency: < 500ms? ✗ rollback → scale canary to 0              │
└─────────────────────────────────────────────────────────────────────────┘
```

#### Canary on AKS with NGINX Ingress (header/weight-based)

```yaml
# stable-deployment.yaml  (existing, stays running)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-stable
  namespace: myapp
spec:
  replicas: 9
  selector:
    matchLabels: { app: myapp, track: stable }
  template:
    metadata:
      labels: { app: myapp, track: stable }
    spec:
      containers:
      - name: api
        image: myregistry.io/myapp:1.0

---
# canary-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
  namespace: myapp
spec:
  replicas: 1            # 1 canary pod out of 10 total = 10% traffic
  selector:
    matchLabels: { app: myapp, track: canary }
  template:
    metadata:
      labels: { app: myapp, track: canary }
    spec:
      containers:
      - name: api
        image: myregistry.io/myapp:2.0

---
# stable-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: stable-ingress
  namespace: myapp
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: api.myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: { name: stable-service, port: { number: 80 } }

---
# canary-ingress.yaml — NGINX weight-based canary
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: canary-ingress
  namespace: myapp
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/canary: "true"          # ← marks as canary
    nginx.ingress.kubernetes.io/canary-weight: "10"     # ← 10% of traffic
    # Optional: route specific users to canary via header
    # nginx.ingress.kubernetes.io/canary-by-header: "X-Canary"
    # nginx.ingress.kubernetes.io/canary-by-header-value: "always"
spec:
  rules:
  - host: api.myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: { name: canary-service, port: { number: 80 } }
```

**Progressive promotion script:**
```bash
# Promote canary: 10% → 25% → 50% → 100%
for WEIGHT in 25 50 100; do
  kubectl annotate ingress canary-ingress -n myapp \
    nginx.ingress.kubernetes.io/canary-weight="$WEIGHT" --overwrite

  echo "Canary at $WEIGHT% — watching metrics for 5 minutes..."
  sleep 300

  # Check error rate (requires Prometheus/metrics-server)
  ERROR_RATE=$(kubectl exec -n monitoring prometheus-0 -- \
    promtool query instant 'rate(http_requests_total{status=~"5..",version="2.0"}[5m]) / rate(http_requests_total{version="2.0"}[5m])')

  if (( $(echo "$ERROR_RATE > 0.01" | bc -l) )); then
    echo "Error rate too high ($ERROR_RATE) — rolling back canary"
    kubectl delete ingress canary-ingress -n myapp
    kubectl scale deployment/app-canary --replicas=0 -n myapp
    exit 1
  fi
done

# Full promotion: update stable image, delete canary
kubectl set image deployment/app-stable api=myregistry.io/myapp:2.0 -n myapp
kubectl delete ingress canary-ingress -n myapp
kubectl delete deployment app-canary -n myapp
```

#### Canary on Azure Container Apps

```bash
# Deploy canary revision (10% traffic)
az containerapp revision copy \
  --name myapp --resource-group myRG \
  --image myregistry.io/myapp:2.0 \
  --revision-suffix canary-v2

az containerapp ingress traffic set \
  --name myapp --resource-group myRG \
  --revision-weight myapp--stable-v1=90 myapp--canary-v2=10

# After validating metrics, promote to 100%
az containerapp ingress traffic set \
  --name myapp --resource-group myRG \
  --revision-weight myapp--canary-v2=100 myapp--stable-v1=0

# Deactivate old revision
az containerapp revision deactivate \
  --name myapp --resource-group myRG \
  --revision myapp--stable-v1
```

#### Canary in Azure DevOps Pipeline

```yaml
# azure-pipelines-canary.yml
stages:
- stage: DeployCanary
  jobs:
  - job: CanaryRollout
    steps:
    - script: |
        # Deploy canary at 10%
        kubectl apply -f k8s/canary-deployment.yaml
        kubectl apply -f k8s/canary-ingress.yaml   # canary-weight=10

    - script: |
        echo "Waiting 10 minutes — monitoring canary metrics..."
        sleep 600

        # Query Application Insights for canary error rate
        ERROR_RATE=$(az monitor metrics list \
          --resource /subscriptions/.../components/myAppInsights \
          --metric "requests/failed" \
          --filter "cloud_RoleName eq 'myapp' and customDimensions/version eq '2.0'" \
          --interval PT5M \
          --query "value[0].timeseries[0].data[-1].average" -o tsv)

        if (( $(echo "$ERROR_RATE > 1" | bc -l) )); then
          echo "##vso[task.logissue type=error]Canary error rate $ERROR_RATE% exceeds threshold"
          exit 1
        fi

- stage: PromoteCanary
  dependsOn: DeployCanary
  condition: succeeded()
  jobs:
  - deployment: FullPromotion
    environment: production
    strategy:
      runOnce:
        deploy:
          steps:
          - script: |
              # Update stable to new version, remove canary
              kubectl set image deployment/app-stable api=$(imageTag) -n myapp
              kubectl delete ingress canary-ingress -n myapp
              kubectl delete deployment app-canary -n myapp
```

---

### 9.3 SonarCloud Quality Gates

> **Mental Model:** SonarCloud is a PR-blocking reviewer that counts bugs, vulnerabilities, code smells, and coverage gaps. A Quality Gate is a pass/fail policy — if new code fails the gate, the PR is blocked and the pipeline fails.

```
┌──────────────────────────────────────────────────────────────────────────┐
│                 DEFAULT SONARCLOUD QUALITY GATE                          │
│                                                                          │
│  On NEW code introduced in this PR:                                      │
│  ┌─────────────────────────────────────────────────────┐                │
│  │  Coverage on new code       ≥ 80%        FAIL if < │                │
│  │  Duplicated lines on new    < 3%         FAIL if > │                │
│  │  Maintainability Rating     A            FAIL if < │                │
│  │  Reliability Rating         A            FAIL if < │                │
│  │  Security Rating            A            FAIL if < │                │
│  │  Security Hotspots reviewed 100%         FAIL if < │                │
│  └─────────────────────────────────────────────────────┘                │
│                                                                          │
│  Result: PASSED ✔ or FAILED ✗ (PR cannot merge if FAILED)               │
└──────────────────────────────────────────────────────────────────────────┘
```

**Step 1 — Configure .NET project for SonarCloud analysis:**
```xml
<!-- Directory.Build.props — enable coverage collection -->
<PropertyGroup>
  <CollectCoverage>true</CollectCoverage>
  <CoverletOutputFormat>opencover</CoverletOutputFormat>
  <CoverletOutput>./coverage/</CoverletOutput>
</PropertyGroup>
```

**Step 2 — Azure DevOps Pipeline with SonarCloud:**
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include: [main, develop]
  paths:
    exclude: ['**/*.md']

variables:
  buildConfiguration: Release
  dotnetVersion: '10.x'

pool:
  vmImage: ubuntu-latest

steps:
- task: UseDotNet@2
  inputs:
    version: $(dotnetVersion)

- task: SonarCloudPrepare@1
  inputs:
    SonarCloud: mySonarCloudServiceConnection   # Service connection in ADO
    organization: my-org-key
    scannerMode: MSBuild
    projectKey: my-org_my-project
    projectName: MyProject
    extraProperties: |
      sonar.cs.opencover.reportsPaths=**/coverage/*.opencover.xml
      sonar.coverage.exclusions=**/*Tests*/**,**/Program.cs,**/Migrations/**
      sonar.exclusions=**/wwwroot/**,**/obj/**
      sonar.qualitygate.wait=true    # ← BLOCKS pipeline until gate result is known

- script: dotnet restore
  displayName: Restore

- script: dotnet build --configuration $(buildConfiguration) --no-restore
  displayName: Build

- script: |
    dotnet test --no-build \
      --configuration $(buildConfiguration) \
      --collect:"XPlat Code Coverage" \
      --results-directory ./TestResults \
      -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=opencover
  displayName: Test + Coverage

- task: SonarCloudAnalyze@1
  displayName: Run SonarCloud Analysis

- task: SonarCloudPublish@1
  displayName: Publish Quality Gate Result
  inputs:
    pollingTimeoutSec: 300    # wait up to 5 min for gate result

# Optional: fail the pipeline explicitly on gate failure
- script: |
    GATE_STATUS=$(curl -s -u $(SONAR_TOKEN): \
      "https://sonarcloud.io/api/qualitygates/project_status?projectKey=my-org_my-project" \
      | jq -r '.projectStatus.status')
    echo "Quality Gate: $GATE_STATUS"
    if [ "$GATE_STATUS" != "OK" ]; then
      echo "##vso[task.logissue type=error]SonarCloud Quality Gate FAILED"
      exit 1
    fi
  env:
    SONAR_TOKEN: $(SONAR_TOKEN)
  displayName: Assert Quality Gate passed
```

**Step 3 — GitHub Actions equivalent:**
```yaml
# .github/workflows/ci.yml
name: CI + SonarCloud

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0    # ← SonarCloud requires full history for blame info

    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.x'

    - name: Install SonarCloud scanner
      run: dotnet tool install --global dotnet-sonarscanner

    - name: SonarCloud Begin
      run: |
        dotnet sonarscanner begin \
          /k:"my-org_my-project" \
          /o:"my-org" \
          /d:sonar.token="${{ secrets.SONAR_TOKEN }}" \
          /d:sonar.host.url="https://sonarcloud.io" \
          /d:sonar.cs.opencover.reportsPaths="**/coverage/*.opencover.xml" \
          /d:sonar.qualitygate.wait=true

    - run: dotnet build --no-restore
    - run: dotnet test --no-build --collect:"XPlat Code Coverage" -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=opencover

    - name: SonarCloud End
      run: dotnet sonarscanner end /d:sonar.token="${{ secrets.SONAR_TOKEN }}"
      # Pipeline fails here if Quality Gate fails (/d:sonar.qualitygate.wait=true)
```

**Step 4 — Custom Quality Gate (stricter for lead-level teams):**
```
Custom gate: "Lead Team Gate"
┌────────────────────────────────────────────────────┐
│ Coverage on new code        ≥ 90%   (not 80%)      │
│ No new Blocker issues       = 0                    │
│ No new Critical issues      = 0                    │
│ Security Hotspots reviewed  = 100%                 │
│ Duplicated lines            < 2%   (not 3%)        │
└────────────────────────────────────────────────────┘

Set via SonarCloud UI: Organization → Quality Gates → Create → Add Conditions → Set as Default
```

**What SonarCloud catches that your tests don't:**
```
Issue Category      Example
─────────────────   ──────────────────────────────────────────────────────
Bugs (Reliability)  Null dereference, collection modified during iteration
Vulnerabilities     Hard-coded credentials, SQL injection risk, insecure random
Code Smells         Cognitive complexity > 15, dead code, magic numbers
Security Hotspots   Regex-based HTML parsing, MD5 usage, HTTP not HTTPS
Duplication         Copy-pasted blocks > 10 lines
Coverage gaps       Lines never executed by any test
```

---

### 9.4 Combined Pipeline: Build → Quality Gate → Deploy Blue-Green

```yaml
# Full pipeline combining all concepts
stages:
- stage: Build
  jobs:
  - job: BuildTestAnalyze
    steps:
    - task: SonarCloudPrepare@1
      inputs: { ... }               # SonarCloud configured

    - script: dotnet build
    - script: dotnet test --collect:"XPlat Code Coverage"

    - task: SonarCloudAnalyze@1
    - task: SonarCloudPublish@1     # ← BLOCKS here if Quality Gate fails

    - task: Docker@2
      inputs:
        command: buildAndPush       # only runs if SonarCloud passed

- stage: DeployGreen
  dependsOn: Build
  condition: succeeded()            # ← won't deploy if quality gate failed
  jobs:
  - job: Green
    steps:
    - script: kubectl apply -f k8s/green-deployment.yaml
    - script: kubectl rollout status deployment/app-green -n myapp

- stage: SwitchAndValidate
  dependsOn: DeployGreen
  jobs:
  - deployment: Switch
    environment: production         # manual approval gate
    strategy:
      runOnce:
        deploy:
          steps:
          - script: |
              # Switch traffic
              kubectl patch service myapp-service -n myapp \
                -p '{"spec":{"selector":{"slot":"green"}}}'

              # Post-deploy smoke test
              sleep 60
              curl -f https://api.myapp.com/health || \
                (kubectl patch service myapp-service -n myapp \
                   -p '{"spec":{"selector":{"slot":"blue"}}}' && exit 1)
```

---

### 9.5 Interview Q&A — CI/CD & Quality Gates

**Q: Blue-Green vs Canary — when do you choose which?**
> Blue-Green when you need instant, atomic switching with zero-downtime — best when you can't observe partial traffic (database migrations, breaking API changes) or need guaranteed instant rollback. Canary when you want to validate new code against real production traffic before full rollout — best for stateless microservices where you can monitor error rates, latency, and business metrics per version and gradually promote.

**Q: What happens to in-flight requests during a blue-green switch?**
> The Kubernetes Service selector change is atomic at the control plane, but in-flight TCP connections to Blue pods aren't terminated immediately — they drain naturally. Configure `terminationGracePeriodSeconds` (e.g. 30s) and a `preStop` sleep hook on Blue pods so the LB stops routing new connections while existing ones complete. App Gateway / NGINX Ingress drain connections before removing backend pool members.

**Q: How do you handle database migrations in Blue-Green?**
> Apply backward-compatible migrations BEFORE the switch. Version N+1 code must run against version N schema. Use the expand/contract pattern: add nullable column → deploy → backfill → add NOT NULL constraint. Never drop or rename columns in the same release as the code change. Feature flags let you decouple schema migration from feature activation.

**Q: SonarCloud Quality Gate failed on a PR. What's your process?**
> First, check which condition failed (coverage, reliability, security). For coverage: identify uncovered critical paths and add meaningful tests — not just coverage padding. For reliability/vulnerabilities: fix the flagged issue; if it's a false positive, mark it as "Won't Fix" with justification in SonarCloud. Never lower the gate threshold — raise the code quality instead. Blocked PRs are merged only after the gate passes.

**Q: How do you prevent Quality Gate from blocking hotfixes?**
> Use a separate `hotfix/*` pipeline that skips SonarCloud but still runs all tests. Add a post-merge job that runs the full analysis on the hotfix commit so the tech debt is tracked. Some teams allow "gate bypass" with explicit approval from two lead engineers, logged in the PR.

---

## Quick Summary Table

| Topic | Most Important Lead Concept | Most Likely Interview Question |
|-------|----------------------|-------------------------------|
| **Terraform** | State + plan/apply + remote backend | Captive dependency pitfall? Module strategy? |
| **xUnit** | IClassFixture, WebApplicationFactory | Unit vs Integration? Testcontainers vs InMemory? |
| **SQL** | Window functions + execution plans | Clustered vs non-clustered? Query optimization? |
| **Durable Task** | Determinism + fan-out/WhenAll + Sagas | Crash recovery? When to break determinism? |
| **Container Apps** | Revisions + KEDA scaling + Dapr | AKS vs Container Apps? Scale to zero? |
| **.NET API** | Middleware order + DI lifetimes + Outbox | N+1 queries? Idempotent endpoints? Fallback policy? |
| **Webhooks** | Queue-first consumer + HMAC + idempotency | Replay attacks? At-least-once delivery? |
| **Entra ID / Auth** | Scope vs Role + OBO + Workload Identity | Managed Identity vs secret? OBO vs Client Credentials? |
| **Blue-Green / Canary** | Label selector flip + NGINX canary-weight | DB migrations in Blue-Green? Canary promotion criteria? |
| **SonarCloud** | Quality Gate = PR blocker + coverage on new code | Gate failed — what do you do? Hotfix bypass strategy? |

---

*Good luck tomorrow! Lead-level interviews test architectural reasoning — always explain the WHY behind decisions, not just the WHAT.*
