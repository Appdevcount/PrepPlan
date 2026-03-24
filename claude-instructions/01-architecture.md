# 01 — Project Architecture

> **Mental Model:** The application is an onion. The innermost ring (Domain) knows nothing
> about outer rings. Each outer ring depends inward — never outward. Azure, databases, and
> HTTP are all "details" that the domain doesn't care about.

---

## Folder Structure — Solution Layout

```
Solution.sln
│
├── src/
│   ├── {Feature}.Domain/            ← Pure business rules. Zero infrastructure references.
│   │   ├── Entities/                    Value objects, aggregates, domain events
│   │   ├── ValueObjects/
│   │   ├── Events/                      Domain events (not integration events)
│   │   ├── Exceptions/                  Domain-specific exceptions (OrderNotFoundException)
│   │   ├── Interfaces/                  IOrderRepository, IDomainEventDispatcher
│   │   └── Services/                    Domain services (stateless logic spanning aggregates)
│   │
│   ├── {Feature}.Application/       ← Orchestration. Depends on Domain only.
│   │   ├── Commands/                    Write operations (CQRS command side)
│   │   │   └── PlaceOrder/
│   │   │       ├── PlaceOrderCommand.cs
│   │   │       └── PlaceOrderCommandHandler.cs
│   │   ├── Queries/                     Read operations (CQRS query side)
│   │   │   └── GetOrder/
│   │   │       ├── GetOrderQuery.cs
│   │   │       └── GetOrderQueryHandler.cs
│   │   ├── Behaviors/                   MediatR pipeline behaviors (logging, validation)
│   │   ├── DTOs/                        Application-layer data transfer objects
│   │   ├── Mappings/                    AutoMapper profiles or manual mapping extensions
│   │   ├── Interfaces/                  IEmailService, IFileStorage (app-level abstractions)
│   │   └── DependencyInjection.cs       AddApplicationServices() extension
│   │
│   ├── {Feature}.Infrastructure/    ← Adapters. Implements Domain + Application interfaces.
│   │   ├── Persistence/
│   │   │   ├── AppDbContext.cs
│   │   │   ├── Configurations/          IEntityTypeConfiguration<T> files
│   │   │   ├── Repositories/            OrderRepository : IOrderRepository
│   │   │   └── Migrations/
│   │   ├── Messaging/                   Service Bus publishers/consumers
│   │   ├── ExternalServices/            HttpClient wrappers, third-party integrations
│   │   ├── Caching/                     Redis/IMemoryCache implementations
│   │   └── DependencyInjection.cs       AddInfrastructureServices() extension
│   │
│   └── {Feature}.Api/               ← Delivery mechanism. Thin. No business logic here.
│       ├── Endpoints/                   Minimal API route groups (OrderEndpoints.cs)
│       ├── Middleware/                  Exception handler, correlation ID, request logging
│       ├── Filters/                     Validation filters
│       ├── Program.cs                   Builder composition only
│       └── appsettings.json
│
└── tests/
    ├── {Feature}.Domain.Tests/          Pure unit tests — no I/O
    ├── {Feature}.Application.Tests/     Command/query handler tests (mocked infra)
    ├── {Feature}.Infrastructure.Tests/  Repository tests (Testcontainers — real DB)
    └── {Feature}.Api.Tests/             Integration tests (WebApplicationFactory)
```

---

## Dependency Rules

```
┌──────────────────────────────────────────────────┐
│                      API                         │ ← knows Application
│  (Program.cs, Endpoints, Middleware)             │
├──────────────────────────────────────────────────┤
│                 Infrastructure                   │ ← knows Domain + Application
│  (EF Core, Service Bus, Redis, HTTP clients)     │
├──────────────────────────────────────────────────┤
│                  Application                     │ ← knows Domain only
│  (Commands, Queries, Behaviors, Interfaces)      │
├──────────────────────────────────────────────────┤
│                    Domain                        │ ← knows NOTHING
│  (Entities, Value Objects, Domain Events)        │
└──────────────────────────────────────────────────┘

Arrows: ALWAYS point inward (upward in this diagram).
NEVER: Domain references Application, Application references Infrastructure.
```

---

## CQRS Pattern

```
Command side (writes):                    Query side (reads):
─────────────────────                     ───────────────────
Request → Command → Handler               Request → Query → Handler
              ↓                                       ↓
         Validate (FluentValidation)            Read-only DbContext
              ↓                                       ↓
         Domain logic                          Project to DTO directly
              ↓                                (no domain objects needed)
         Persist via IRepository
              ↓
         Publish domain events
              ↓
         Return Result<T>
```

**Rules:**
- Commands return `Result<TId>` or `Result` — never the full entity
- Queries return DTOs — never expose domain entities to the API layer
- Query handlers can query the database directly (bypassing repository) for performance
- Use `MediatR` for dispatch; add pipeline behaviors for cross-cutting concerns

---

## Domain Aggregate Rules

```csharp
// ── Aggregate Root ────────────────────────────────────────────────────────────
// WHY aggregate root: controls the consistency boundary. No external code
//   mutates child entities directly — all changes go through the root.
public class Order : AggregateRoot<OrderId>
{
    // Private setters enforce that state changes go through domain methods
    public CustomerId CustomerId { get; private set; }
    public OrderStatus Status { get; private set; }

    // Private collection — caller uses AddItem(), not _items.Add()
    private readonly List<OrderItem> _items = new();
    public IReadOnlyList<OrderItem> Items => _items.AsReadOnly();

    // Domain method — validates invariants before changing state
    public void AddItem(ProductId productId, int quantity, Money price)
    {
        // WHY invariant check here: the aggregate guards its own consistency.
        //   No service layer should be checking "is this order still open?".
        if (Status != OrderStatus.Draft)
            throw new OrderNotEditableException(Id);

        _items.Add(new OrderItem(productId, quantity, price));

        // Raise domain event — infrastructure picks this up after commit
        AddDomainEvent(new OrderItemAdded(Id, productId, quantity));
    }
}
```

---

## Value Object Pattern

```csharp
// WHY value object: two Money instances with same Amount+Currency are equal.
//   No identity — replaced wholesale, never mutated.
public sealed record Money(decimal Amount, string Currency)
{
    // Validation in constructor — can never create an invalid Money
    public Money
    {
        if (Amount < 0) throw new ArgumentException("Amount cannot be negative", nameof(Amount));
        if (string.IsNullOrWhiteSpace(Currency)) throw new ArgumentException("Currency required", nameof(Currency));
    }

    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException($"Cannot add {Currency} and {other.Currency}");
        return this with { Amount = Amount + other.Amount };
    }

    public static Money Zero(string currency) => new(0, currency);
}
```

---

## Result Pattern (no exceptions across layer boundaries)

```csharp
// WHY Result<T>: exceptions are expensive and break normal flow.
//   Application layer returns Result — callers decide what to do.
//   Domain STILL throws exceptions for invariant violations.
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string? Error { get; }

    private Result(T value) { IsSuccess = true; Value = value; }
    private Result(string error) { IsSuccess = false; Error = error; }

    public static Result<T> Success(T value) => new(value);
    public static Result<T> Failure(string error) => new(error);

    // Implicit conversion — handler code stays clean
    public static implicit operator Result<T>(T value) => Success(value);
}

// In a command handler:
public async Task<Result<Guid>> Handle(PlaceOrderCommand cmd, CancellationToken ct)
{
    var customer = await _customerRepo.GetByIdAsync(cmd.CustomerId, ct);
    if (customer is null)
        return Result<Guid>.Failure($"Customer {cmd.CustomerId} not found");

    var order = customer.PlaceOrder(cmd.Items);
    await _orderRepo.AddAsync(order, ct);
    await _unitOfWork.SaveChangesAsync(ct);

    return order.Id;   // implicit conversion to Result<Guid>
}
```

---

## DI Registration Convention

```csharp
// Each layer exposes a single extension method — Program.cs stays clean
// WHY: Program.cs becomes a composition root with no registration details

// Application/DependencyInjection.cs
public static class ApplicationServiceRegistration
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services, IConfiguration config)
    {
        services.AddMediatR(cfg =>
            cfg.RegisterServicesFromAssembly(typeof(PlaceOrderCommand).Assembly));

        services.AddValidatorsFromAssembly(typeof(PlaceOrderCommand).Assembly);

        // WHY ValidationBehavior before LoggingBehavior:
        //   validate first — don't log commands that would be rejected anyway
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));

        return services;
    }
}

// Program.cs — clean composition
builder.Services
    .AddDomainServices()
    .AddApplicationServices(builder.Configuration)
    .AddInfrastructureServices(builder.Configuration)
    .AddApiServices();
```

---

## Modular Monolith vs Microservices Decision

```
Start as Modular Monolith when:
  ✅ Team < 10 engineers
  ✅ Domain boundaries not yet proven
  ✅ Single deploy unit acceptable
  ✅ Shared database tolerable short-term

Extract to Microservice when:
  ✅ Module has independent scaling needs
  ✅ Module has separate release cadence
  ✅ Module boundary is stable and proven
  ✅ Team ownership is clear

Rule: Share the database schema, NOT the code.
      Each module owns its own tables/schemas.
      Never cross-join between module schemas in application code.
```
