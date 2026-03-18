# DDD · Clean Architecture · CQRS — Expert Architect Complete Guide
> **Source of Truth** | C# / .NET 8+ | Production-Grade | All Scenarios Covered

---

## Table of Contents

1. [Mental Models & Philosophy](#1-mental-models--philosophy)
2. [Domain-Driven Design — Strategic Patterns](#2-domain-driven-design--strategic-patterns)
   - 2.1 [Ubiquitous Language](#21-ubiquitous-language)
   - 2.2 [Bounded Contexts](#22-bounded-contexts)
   - 2.3 [Context Mapping](#23-context-mapping)
   - 2.4 [Subdomains](#24-subdomains)
3. [Domain-Driven Design — Tactical Patterns](#3-domain-driven-design--tactical-patterns)
   - 3.1 [Entities](#31-entities)
   - 3.2 [Value Objects](#32-value-objects)
   - 3.3 [Aggregates & Aggregate Roots](#33-aggregates--aggregate-roots)
   - 3.4 [Domain Events](#34-domain-events)
   - 3.5 [Repositories](#35-repositories)
   - 3.6 [Domain Services](#36-domain-services)
   - 3.7 [Factories](#37-factories)
   - 3.8 [Specifications](#38-specifications)
4. [Clean Architecture](#4-clean-architecture)
   - 4.1 [Layer Responsibilities](#41-layer-responsibilities)
   - 4.2 [Dependency Rule](#42-dependency-rule)
   - 4.3 [Project Structure](#43-project-structure)
   - 4.4 [Layer Contracts (Interfaces)](#44-layer-contracts-interfaces)
5. [CQRS — Command Query Responsibility Segregation](#5-cqrs--command-query-responsibility-segregation)
   - 5.1 [Why CQRS](#51-why-cqrs)
   - 5.2 [Commands — Write Side](#52-commands--write-side)
   - 5.3 [Queries — Read Side](#53-queries--read-side)
   - 5.4 [MediatR Pipeline](#54-mediatr-pipeline)
   - 5.5 [Pipeline Behaviors (Cross-Cutting)](#55-pipeline-behaviors-cross-cutting)
6. [Full Integration — DDD + Clean Arch + CQRS](#6-full-integration--ddd--clean-arch--cqrs)
   - 6.1 [Reference Domain: Order Management](#61-reference-domain-order-management)
   - 6.2 [Complete Command Flow](#62-complete-command-flow)
   - 6.3 [Complete Query Flow](#63-complete-query-flow)
7. [Domain Events & Integration Events](#7-domain-events--integration-events)
   - 7.1 [Domain Events (in-process)](#71-domain-events-in-process)
   - 7.2 [Integration Events (cross-service)](#72-integration-events-cross-service)
   - 7.3 [Outbox Pattern](#73-outbox-pattern)
8. [Advanced Patterns](#8-advanced-patterns)
   - 8.1 [Event Sourcing](#81-event-sourcing)
   - 8.2 [Saga / Process Manager](#82-saga--process-manager)
   - 8.3 [Eventual Consistency](#83-eventual-consistency)
   - 8.4 [Read Model Projections](#84-read-model-projections)
9. [Validation Strategy](#9-validation-strategy)
10. [Testing Strategy](#10-testing-strategy)
11. [Anti-Patterns & Pitfalls](#11-anti-patterns--pitfalls)
12. [Architectural Decision Reference](#12-architectural-decision-reference)

---

## 1. Mental Models & Philosophy

```
┌─────────────────────────────────────────────────────────────────────┐
│  MENTAL MODEL: City Planning                                        │
│                                                                     │
│  DDD          = Understand the city's neighborhoods (domains)       │
│                 and their unique cultures (ubiquitous language)     │
│                                                                     │
│  Clean Arch   = Zoning laws — business rules live in the CENTER,   │
│                 databases & UIs on the OUTSIDE, never the reverse   │
│                                                                     │
│  CQRS         = Separate roads for trucks (writes) vs tourists     │
│                 (reads) — optimized separately, no traffic jams     │
└─────────────────────────────────────────────────────────────────────┘
```

### Core Philosophy

| Principle | What it means |
|-----------|---------------|
| **Domain first** | Business rules, not technical constraints, drive design |
| **Ubiquitous Language** | Same words in code, conversations, and documentation |
| **Protect the domain** | Domain layer has zero infrastructure dependencies |
| **Inversion of control** | Application core defines interfaces; infra implements them |
| **Separate concerns** | Commands change state; Queries only read state |

> **Key Insight**: These three patterns are *complementary*, not competing. DDD defines WHAT your system models. Clean Architecture defines WHERE code lives. CQRS defines HOW operations flow. A system using all three is predictable, testable, and scalable.

---

## 2. Domain-Driven Design — Strategic Patterns

### 2.1 Ubiquitous Language

**Mental Model**: Every team speaks the same language as the business. If your domain expert says "Order" and your code says "PurchaseTransaction", you have a translation tax that compounds into bugs.

```
WRONG: Generic developer language
───────────────────────────────────
class UserRecord         // should be: Customer
class ProcessItem()      // should be: PlaceOrder()
class StatusCode = 3     // should be: OrderStatus.Shipped

RIGHT: Ubiquitous language
───────────────────────────────────
class Customer            // exact term domain expert uses
void PlaceOrder()         // verb the business uses
OrderStatus.Shipped       // state the business recognizes
```

**Practice**: Build a Glossary — live document, updated by developers AND domain experts:

```markdown
| Term              | Bounded Context | Meaning                                      |
|-------------------|----------------|----------------------------------------------|
| Order             | Sales          | Customer intent to purchase; mutable until Confirmed |
| Order             | Fulfillment    | Confirmed purchase ready for warehouse       |
| Customer          | Sales          | Any person browsing or buying                |
| Client            | Billing        | Legal entity responsible for payment         |
```

> **Key Insight**: The same word ("Order") can mean different things in different Bounded Contexts. This is correct — resist the urge to unify. Unifying creates a God Object that satisfies no one.

---

### 2.2 Bounded Contexts

**Mental Model**: Embassy territory. Inside an embassy, a country's own laws apply. At the border, translation happens. Each Bounded Context is sovereign over its own model.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        E-Commerce Platform                              │
│                                                                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐  │
│  │   Sales BC       │  │  Fulfillment BC  │  │    Billing BC        │  │
│  │                  │  │                  │  │                      │  │
│  │  - Customer      │  │  - Shipment      │  │  - Invoice           │  │
│  │  - Cart          │  │  - PickList      │  │  - PaymentMethod     │  │
│  │  - Order (draft) │  │  - Order (confirmed) │  - Transaction      │  │
│  │  - Catalog       │  │  - Warehouse     │  │  - Subscription      │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────────┘  │
│          │                      │                        │              │
│          └──────────────────────┴────────────────────────┘              │
│                         Integration Layer                               │
└─────────────────────────────────────────────────────────────────────────┘
```

**Identifying Bounded Context boundaries:**
- Where terminology changes between teams
- Where data ownership is unclear (red flag: shared mutable table)
- Where deployment independence is needed
- Where team/organizational boundaries exist (Conway's Law)

---

### 2.3 Context Mapping

**Mental Model**: Political map between countries — relationships, trade agreements, dependencies.

```
┌──────────────────────────────────────────────────────────────────┐
│                    Context Map Patterns                          │
│                                                                  │
│  Partnership          ←→ Both teams coordinate changes together  │
│  Shared Kernel        ←→ Shared model owned by BOTH teams        │
│  Customer-Supplier    ↓  Downstream depends on upstream          │
│  Conformist           ↓  Downstream conforms to upstream model   │
│  Anti-Corruption Layer ↓ Downstream translates upstream model    │
│  Open Host Service    →  Upstream provides formal API/protocol   │
│  Published Language   →  Upstream publishes shared schema        │
│  Separate Ways        ✗  No integration; each solves own problem │
└──────────────────────────────────────────────────────────────────┘
```

**Anti-Corruption Layer (ACL) — most important for independence:**

```csharp
// External / upstream model (e.g., legacy ERP)
public class ErpProductRecord
{
    public string PROD_ID { get; set; }
    public string PROD_NM { get; set; }
    public decimal SELL_PRC { get; set; }
    public string STK_STS { get; set; } // "1" = in stock, "0" = out
}

// Our domain model (Sales BC)
public class Product
{
    public ProductId Id { get; private set; }
    public string Name { get; private set; }
    public Money Price { get; private set; }
    public bool IsInStock { get; private set; }
}

// ACL — translates without leaking external model into domain
public class ErpProductTranslator
{
    public Product Translate(ErpProductRecord erp)
    {
        return Product.Create(
            id: ProductId.From(erp.PROD_ID),
            name: erp.PROD_NM,
            price: Money.InUsd(erp.SELL_PRC),
            isInStock: erp.STK_STS == "1"   // WHY: isolate legacy magic strings
        );
    }
}
```

---

### 2.4 Subdomains

| Type | Description | Approach |
|------|-------------|----------|
| **Core Domain** | Competitive advantage; unique to business | DDD + full tactical patterns |
| **Supporting Domain** | Necessary but not differentiating | Simpler design; maybe CRUD |
| **Generic Domain** | Commodity (auth, email, payments) | Buy/use SaaS; don't build |

```
E-Commerce Example:
┌────────────────────────────────────────────────────────────┐
│  Core: Recommendation Engine, Dynamic Pricing, Fraud       │
│        Detection                         ← Full DDD here  │
│                                                            │
│  Supporting: Order Fulfillment, Customer Profiles          │
│              ← Simpler design acceptable                   │
│                                                            │
│  Generic: Auth (Auth0), Email (SendGrid), Payments (Stripe)│
│           ← Just integrate, don't build                    │
└────────────────────────────────────────────────────────────┘
```

---

## 3. Domain-Driven Design — Tactical Patterns

### 3.1 Entities

**Mental Model**: A person. Your identity stays the same even if you change your name, address, or job. Identity is separate from attributes.

```csharp
// Base Entity — provides identity and equality by ID
public abstract class Entity<TId>
{
    public TId Id { get; protected set; }

    // WHY: Equality based on ID, not reference or values
    public override bool Equals(object? obj)
    {
        if (obj is not Entity<TId> other) return false;
        if (ReferenceEquals(this, other)) return true;
        if (GetType() != other.GetType()) return false;
        return EqualityComparer<TId>.Default.Equals(Id, other.Id);
    }

    public override int GetHashCode() => Id!.GetHashCode();
    public static bool operator ==(Entity<TId>? a, Entity<TId>? b)
        => a?.Equals(b) ?? b is null;
    public static bool operator !=(Entity<TId>? a, Entity<TId>? b)
        => !(a == b);
}

// Typed ID — prevents primitive obsession and wrong-id bugs
public record OrderId(Guid Value)
{
    public static OrderId New() => new(Guid.NewGuid());
    public static OrderId From(Guid value) => new(value);
    public override string ToString() => Value.ToString();
}

// Concrete Entity
public class Order : Entity<OrderId>
{
    public CustomerId CustomerId { get; private set; }
    public OrderStatus Status { get; private set; }
    public Money TotalAmount { get; private set; }
    private readonly List<OrderLine> _lines = new();
    public IReadOnlyList<OrderLine> Lines => _lines.AsReadOnly();

    // WHY: Private constructor forces use of factory method
    private Order() { }

    // Factory method — controlled creation with invariant checks
    public static Order Create(CustomerId customerId)
    {
        ArgumentNullException.ThrowIfNull(customerId);

        var order = new Order
        {
            Id = OrderId.New(),
            CustomerId = customerId,
            Status = OrderStatus.Draft,
            TotalAmount = Money.Zero
        };

        return order;
    }

    // Business method — encapsulates behaviour and invariants
    public void AddLine(ProductId productId, int quantity, Money unitPrice)
    {
        // WHY: Invariant — can't modify a confirmed order
        if (Status != OrderStatus.Draft)
            throw new OrderAlreadyConfirmedException(Id);

        if (quantity <= 0)
            throw new InvalidQuantityException(quantity);

        var existingLine = _lines.FirstOrDefault(l => l.ProductId == productId);
        if (existingLine is not null)
        {
            existingLine.IncreaseQuantity(quantity);
        }
        else
        {
            _lines.Add(OrderLine.Create(Id, productId, quantity, unitPrice));
        }

        RecalculateTotal();
    }

    public void Confirm()
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOrderStatusTransitionException(Status, OrderStatus.Confirmed);

        if (!_lines.Any())
            throw new EmptyOrderException(Id);

        Status = OrderStatus.Confirmed;
        // WHY: Raise domain event — signals side effects without coupling
        AddDomainEvent(new OrderConfirmedDomainEvent(Id, CustomerId, TotalAmount));
    }

    private void RecalculateTotal()
    {
        TotalAmount = _lines.Aggregate(Money.Zero, (sum, line) => sum + line.LineTotal);
    }
}
```

---

### 3.2 Value Objects

**Mental Model**: A $20 bill. You don't care WHICH $20 bill you have — only the value matters. Replace one with another identical bill: no difference.

```csharp
// Base Value Object — structural equality
public abstract class ValueObject
{
    protected abstract IEnumerable<object?> GetEqualityComponents();

    public override bool Equals(object? obj)
    {
        if (obj is null || obj.GetType() != GetType()) return false;
        return GetEqualityComponents()
            .SequenceEqual(((ValueObject)obj).GetEqualityComponents());
    }

    public override int GetHashCode()
        => GetEqualityComponents()
            .Aggregate(0, (h, c) => HashCode.Combine(h, c));

    public static bool operator ==(ValueObject? a, ValueObject? b)
        => a?.Equals(b) ?? b is null;
    public static bool operator !=(ValueObject? a, ValueObject? b)
        => !(a == b);
}

// Money — classic value object
public sealed class Money : ValueObject
{
    public decimal Amount { get; }
    public string Currency { get; }

    public static Money Zero => new(0, "USD");
    public static Money InUsd(decimal amount) => new(amount, "USD");

    private Money(decimal amount, string currency)
    {
        if (amount < 0) throw new ArgumentException("Amount cannot be negative");
        if (string.IsNullOrWhiteSpace(currency)) throw new ArgumentException("Currency required");

        Amount = Math.Round(amount, 2);  // WHY: monetary precision always 2dp
        Currency = currency.ToUpperInvariant();
    }

    // WHY: Immutable arithmetic — always returns new instance
    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new CurrencyMismatchException(Currency, other.Currency);
        return new Money(Amount + other.Amount, Currency);
    }

    public Money Multiply(int factor)
        => new(Amount * factor, Currency);

    public static Money operator +(Money a, Money b) => a.Add(b);
    public static Money operator *(Money m, int factor) => m.Multiply(factor);

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Amount;
        yield return Currency;
    }

    public override string ToString() => $"{Currency} {Amount:F2}";
}

// Address value object
public sealed class Address : ValueObject
{
    public string Street { get; }
    public string City { get; }
    public string PostalCode { get; }
    public string Country { get; }

    public Address(string street, string city, string postalCode, string country)
    {
        Street = street ?? throw new ArgumentNullException(nameof(street));
        City = city ?? throw new ArgumentNullException(nameof(city));
        PostalCode = postalCode ?? throw new ArgumentNullException(nameof(postalCode));
        Country = country ?? throw new ArgumentNullException(nameof(country));
    }

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Street;
        yield return City;
        yield return PostalCode;
        yield return Country;
    }
}

// Email — validated value object
public sealed class Email : ValueObject
{
    public string Value { get; }

    public Email(string value)
    {
        if (!IsValid(value))
            throw new InvalidEmailException(value);
        Value = value.ToLowerInvariant();
    }

    private static bool IsValid(string email)
        => !string.IsNullOrWhiteSpace(email) && email.Contains('@') && email.Contains('.');

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Value;
    }

    public override string ToString() => Value;
    public static implicit operator string(Email e) => e.Value;
}
```

> **Key Insight**: If two objects are equal when ALL their attributes are equal — use a Value Object. If they have a lifecycle and need identity tracking — use an Entity.

---

### 3.3 Aggregates & Aggregate Roots

**Mental Model**: A binder with a cover sheet. You can only access the binder through the cover sheet. The cover sheet enforces what changes are valid inside.

```
┌─────────────────────────────────────────────────────────────────┐
│  Aggregate Boundary                                             │
│                                                                 │
│  ┌─────────────────┐                                            │
│  │  Order (ROOT)   │ ← Only entry point                        │
│  │  - Id           │                                            │
│  │  - Status       │   ┌──────────────────┐                    │
│  │  - TotalAmount  │──▶│  OrderLine       │                    │
│  │                 │   │  - ProductId     │                    │
│  │  AddLine()      │   │  - Quantity      │                    │
│  │  Confirm()      │   │  - UnitPrice     │                    │
│  │  Cancel()       │   └──────────────────┘                    │
│  └─────────────────┘                                            │
│                                                                 │
│  Rules:                                                         │
│  1. Only Order Root can be obtained from Repository             │
│  2. OrderLine cannot be modified directly from outside          │
│  3. Invariants enforced inside the aggregate boundary           │
│  4. Each aggregate is a consistency boundary                    │
└─────────────────────────────────────────────────────────────────┘
```

**Aggregate Design Rules:**
1. One transaction = one aggregate change (in most cases)
2. Reference other aggregates by **ID only**, never by object reference
3. Keep aggregates **small** — minimizes lock contention
4. Aggregates protect **invariants** — business rules that must always hold

```csharp
// Aggregate Root base — with domain events support
public abstract class AggregateRoot<TId> : Entity<TId>
{
    private readonly List<IDomainEvent> _domainEvents = new();
    public IReadOnlyList<IDomainEvent> DomainEvents => _domainEvents.AsReadOnly();

    protected void AddDomainEvent(IDomainEvent domainEvent)
        => _domainEvents.Add(domainEvent);

    public void ClearDomainEvents()
        => _domainEvents.Clear();
}

// OrderLine — part of Order aggregate, NOT a root
public class OrderLine : Entity<OrderLineId>
{
    public OrderId OrderId { get; private set; }     // WHY: knows parent by ID
    public ProductId ProductId { get; private set; }
    public int Quantity { get; private set; }
    public Money UnitPrice { get; private set; }
    public Money LineTotal => UnitPrice * Quantity;

    private OrderLine() { }

    internal static OrderLine Create(            // WHY: internal — only Order can create
        OrderId orderId,
        ProductId productId,
        int quantity,
        Money unitPrice)
    {
        return new OrderLine
        {
            Id = OrderLineId.New(),
            OrderId = orderId,
            ProductId = productId,
            Quantity = quantity,
            UnitPrice = unitPrice
        };
    }

    internal void IncreaseQuantity(int by)        // WHY: internal — only Order calls this
    {
        if (by <= 0) throw new ArgumentException("Increase must be positive");
        Quantity += by;
    }
}
```

**Aggregate Size — Decision Table:**

| Signal | Recommendation |
|--------|---------------|
| Data always read together | Keep in one aggregate |
| Data changed independently | Split into separate aggregates |
| Need eventual consistency between parts | Split and use domain events |
| Many concurrent users modify same data | Split to reduce contention |

---

### 3.4 Domain Events

**Mental Model**: A newspaper headline. "Order Confirmed!" — other parts of the business (Billing, Fulfillment, Notifications) independently react to news without the reporter knowing who reads it.

```csharp
// Domain Event marker interface
public interface IDomainEvent
{
    Guid EventId { get; }
    DateTime OccurredOn { get; }
}

// Base domain event
public abstract record DomainEvent : IDomainEvent
{
    public Guid EventId { get; } = Guid.NewGuid();
    public DateTime OccurredOn { get; } = DateTime.UtcNow;
}

// Concrete domain events — record per event, immutable
public record OrderConfirmedDomainEvent(
    OrderId OrderId,
    CustomerId CustomerId,
    Money TotalAmount) : DomainEvent;

public record OrderCancelledDomainEvent(
    OrderId OrderId,
    string Reason) : DomainEvent;

public record OrderLineAddedDomainEvent(
    OrderId OrderId,
    ProductId ProductId,
    int Quantity) : DomainEvent;

// Domain Event Handler interface
public interface IDomainEventHandler<TEvent> where TEvent : IDomainEvent
{
    Task Handle(TEvent domainEvent, CancellationToken cancellationToken);
}

// Example Handler — in Application layer
public class SendOrderConfirmationEmailHandler
    : IDomainEventHandler<OrderConfirmedDomainEvent>
{
    private readonly IEmailService _emailService;
    private readonly ICustomerRepository _customerRepo;

    public SendOrderConfirmationEmailHandler(
        IEmailService emailService,
        ICustomerRepository customerRepo)
    {
        _emailService = emailService;
        _customerRepo = customerRepo;
    }

    public async Task Handle(
        OrderConfirmedDomainEvent domainEvent,
        CancellationToken cancellationToken)
    {
        var customer = await _customerRepo.GetByIdAsync(
            domainEvent.CustomerId, cancellationToken);

        await _emailService.SendAsync(new OrderConfirmationEmail
        {
            To = customer.Email,
            OrderId = domainEvent.OrderId,
            Total = domainEvent.TotalAmount
        }, cancellationToken);
    }
}
```

---

### 3.5 Repositories

**Mental Model**: A filing cabinet. You ask it for a specific folder by ID or criteria. You put folders back when done. It hides HOW files are stored (drawer, cloud, database).

```csharp
// Repository interface — lives in Domain layer
// WHY: Domain defines the contract; Infrastructure implements it
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(OrderId id, CancellationToken ct = default);
    Task<IEnumerable<Order>> GetByCustomerAsync(CustomerId customerId, CancellationToken ct = default);
    Task AddAsync(Order order, CancellationToken ct = default);
    Task UpdateAsync(Order order, CancellationToken ct = default);
    Task DeleteAsync(OrderId id, CancellationToken ct = default);
}

// Repository implementation — lives in Infrastructure layer
public class OrderRepository : IOrderRepository
{
    private readonly AppDbContext _dbContext;

    public OrderRepository(AppDbContext dbContext)
        => _dbContext = dbContext;

    public async Task<Order?> GetByIdAsync(OrderId id, CancellationToken ct = default)
    {
        return await _dbContext.Orders
            .Include(o => o.Lines)          // WHY: load aggregate fully
            .FirstOrDefaultAsync(o => o.Id == id, ct);
    }

    public async Task<IEnumerable<Order>> GetByCustomerAsync(
        CustomerId customerId, CancellationToken ct = default)
    {
        return await _dbContext.Orders
            .Where(o => o.CustomerId == customerId)
            .Include(o => o.Lines)
            .ToListAsync(ct);
    }

    public async Task AddAsync(Order order, CancellationToken ct = default)
    {
        await _dbContext.Orders.AddAsync(order, ct);
        // WHY: SaveChanges NOT called here — Unit of Work pattern
        //      The application layer (via IUnitOfWork) commits the transaction
    }

    public async Task UpdateAsync(Order order, CancellationToken ct = default)
    {
        _dbContext.Orders.Update(order);
    }

    public async Task DeleteAsync(OrderId id, CancellationToken ct = default)
    {
        var order = await GetByIdAsync(id, ct);
        if (order is not null)
            _dbContext.Orders.Remove(order);
    }
}

// Unit of Work — coordinates multiple repos in one transaction
public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken ct = default);
}

// EF Core DbContext implements IUnitOfWork naturally
public class AppDbContext : DbContext, IUnitOfWork
{
    public DbSet<Order> Orders { get; set; } = null!;
    public DbSet<Customer> Customers { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder builder)
    {
        builder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
    }
}
```

---

### 3.6 Domain Services

**Mental Model**: A notary. Some actions don't belong to any single entity (e.g., transferring money requires both accounts). Domain Services host these cross-entity operations.

```csharp
// Domain Service — stateless, lives in Domain layer
// Use when: operation involves multiple aggregates, or doesn't belong to any single entity

public interface IOrderPricingService
{
    Money CalculateFinalPrice(Order order, Customer customer, IEnumerable<Coupon> coupons);
}

public class OrderPricingService : IOrderPricingService
{
    // WHY: Pure domain logic — no infrastructure dependencies
    public Money CalculateFinalPrice(
        Order order,
        Customer customer,
        IEnumerable<Coupon> coupons)
    {
        var baseTotal = order.TotalAmount;

        // Apply loyalty discount based on customer tier
        var loyaltyDiscount = customer.Tier switch
        {
            CustomerTier.Gold   => 0.10m,  // 10%
            CustomerTier.Silver => 0.05m,  // 5%
            _                   => 0.00m
        };

        var afterLoyalty = baseTotal * (1 - loyaltyDiscount);

        // Apply coupon discounts (stacking allowed per business rule)
        var couponDiscount = coupons
            .Where(c => c.IsValidFor(order))
            .Sum(c => c.DiscountAmount.Amount);

        var finalAmount = afterLoyalty.Amount - couponDiscount;

        return Money.InUsd(Math.Max(0, finalAmount)); // WHY: floor at 0
    }
}
```

**When to use Domain Service vs Entity method:**

| Scenario | Use |
|----------|-----|
| Operation on single aggregate | Entity/Aggregate Root method |
| Operation spanning two aggregates | Domain Service |
| Operation needs external data to compute | Domain Service |
| Pure business rule, no infra | Domain Service in Domain layer |
| Needs DB/API access | Application Service in Application layer |

---

### 3.7 Factories

**Mental Model**: An assembly line. Complex creation logic extracted so the Aggregate Root constructor stays clean.

```csharp
// Factory — for complex aggregate creation
public interface IOrderFactory
{
    Task<Order> CreateFromCartAsync(CartId cartId, CancellationToken ct);
}

public class OrderFactory : IOrderFactory
{
    private readonly ICartRepository _cartRepo;
    private readonly IProductRepository _productRepo;

    public OrderFactory(ICartRepository cartRepo, IProductRepository productRepo)
    {
        _cartRepo = cartRepo;
        _productRepo = productRepo;
    }

    public async Task<Order> CreateFromCartAsync(CartId cartId, CancellationToken ct)
    {
        var cart = await _cartRepo.GetByIdAsync(cartId, ct)
            ?? throw new CartNotFoundException(cartId);

        var order = Order.Create(cart.CustomerId);

        foreach (var cartItem in cart.Items)
        {
            var product = await _productRepo.GetByIdAsync(cartItem.ProductId, ct)
                ?? throw new ProductNotFoundException(cartItem.ProductId);

            // WHY: Re-check price at time of order creation (cart may be stale)
            order.AddLine(product.Id, cartItem.Quantity, product.CurrentPrice);
        }

        return order;
    }
}
```

---

### 3.8 Specifications

**Mental Model**: A filter recipe. Encapsulate query criteria as objects — composable, reusable, and testable.

```csharp
// Specification interface
public interface ISpecification<T>
{
    Expression<Func<T, bool>> Criteria { get; }
    List<Expression<Func<T, object>>> Includes { get; }
    bool IsSatisfiedBy(T entity);
}

// Base Specification
public abstract class Specification<T> : ISpecification<T>
{
    public Expression<Func<T, bool>> Criteria { get; protected set; } = x => true;
    public List<Expression<Func<T, object>>> Includes { get; } = new();

    public bool IsSatisfiedBy(T entity)
        => Criteria.Compile()(entity);

    // Composition operators
    public Specification<T> And(Specification<T> other)
        => new AndSpecification<T>(this, other);

    public Specification<T> Or(Specification<T> other)
        => new OrSpecification<T>(this, other);
}

// Concrete specification
public class PendingOrdersForCustomerSpec : Specification<Order>
{
    public PendingOrdersForCustomerSpec(CustomerId customerId)
    {
        Criteria = order =>
            order.CustomerId == customerId &&
            order.Status == OrderStatus.Draft;

        Includes.Add(o => o.Lines); // WHY: pre-load related data
    }
}

// Usage in repository
public async Task<IEnumerable<Order>> FindAsync(
    Specification<Order> spec, CancellationToken ct)
{
    var query = _dbContext.Orders.AsQueryable();

    foreach (var include in spec.Includes)
        query = query.Include(include);

    return await query
        .Where(spec.Criteria)
        .ToListAsync(ct);
}

// Composing specs
var spec = new PendingOrdersForCustomerSpec(customerId)
    .And(new OrdersAboveAmountSpec(Money.InUsd(100)));
```

---

## 4. Clean Architecture

### 4.1 Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────────┐
│                    Clean Architecture Layers                    │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Presentation Layer                      │  │
│  │  API Controllers, gRPC, SignalR, Console, Blazor          │  │
│  │  - Maps HTTP → Commands/Queries                           │  │
│  │  - Returns HTTP responses from Results                    │  │
│  └───────────────────────────────┬───────────────────────────┘  │
│                                  │ depends on                   │
│  ┌───────────────────────────────▼───────────────────────────┐  │
│  │                   Application Layer                       │  │
│  │  Commands, Queries, Handlers, Validators, DTOs            │  │
│  │  - Orchestrates use cases                                 │  │
│  │  - Calls domain objects and infrastructure contracts      │  │
│  │  - No business rules here — delegates to Domain           │  │
│  └─────────────┬─────────────────────────────────────────────┘  │
│                │ depends on                                      │
│  ┌─────────────▼─────────────────────────────────────────────┐  │
│  │                     Domain Layer                          │  │
│  │  Entities, Value Objects, Aggregates, Domain Events       │  │
│  │  Domain Services, Repository Interfaces                   │  │
│  │  - ZERO infrastructure dependencies                       │  │
│  │  - Pure business rules and language                       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                          ▲                                       │
│  ┌───────────────────────┴───────────────────────────────────┐  │
│  │                 Infrastructure Layer                      │  │
│  │  EF Core, Repositories, Email, Azure Service Bus,         │  │
│  │  Redis, External APIs, File Storage                       │  │
│  │  - Implements domain interfaces                           │  │
│  │  - All I/O lives here                                     │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Dependency Rule

> **The Golden Rule**: Source code dependencies must point **inward only**. Inner layers know NOTHING about outer layers.

```
Domain         →  knows nothing
Application    →  knows Domain
Infrastructure →  knows Domain (implements interfaces)
Presentation   →  knows Application (sends Commands/Queries)

ILLEGAL:
  Domain       → Application     ✗
  Domain       → Infrastructure  ✗
  Application  → Infrastructure  ✗  (must use interfaces)
  Application  → Presentation    ✗
```

---

### 4.3 Project Structure

```
OrderManagement.sln
│
├── src/
│   ├── OrderManagement.Domain/                ← innermost, no NuGet deps
│   │   ├── Common/
│   │   │   ├── Entity.cs
│   │   │   ├── AggregateRoot.cs
│   │   │   ├── ValueObject.cs
│   │   │   └── IDomainEvent.cs
│   │   ├── Orders/
│   │   │   ├── Order.cs
│   │   │   ├── OrderLine.cs
│   │   │   ├── OrderStatus.cs
│   │   │   ├── Events/
│   │   │   │   ├── OrderConfirmedDomainEvent.cs
│   │   │   │   └── OrderCancelledDomainEvent.cs
│   │   │   ├── Exceptions/
│   │   │   │   └── OrderAlreadyConfirmedException.cs
│   │   │   └── IOrderRepository.cs           ← interface in Domain
│   │   ├── Customers/
│   │   │   ├── Customer.cs
│   │   │   └── ICustomerRepository.cs
│   │   └── ValueObjects/
│   │       ├── Money.cs
│   │       ├── Address.cs
│   │       └── Email.cs
│   │
│   ├── OrderManagement.Application/           ← use cases, no EF/DB
│   │   ├── Orders/
│   │   │   ├── Commands/
│   │   │   │   ├── PlaceOrder/
│   │   │   │   │   ├── PlaceOrderCommand.cs
│   │   │   │   │   ├── PlaceOrderCommandHandler.cs
│   │   │   │   │   └── PlaceOrderCommandValidator.cs
│   │   │   │   └── ConfirmOrder/
│   │   │   │       ├── ConfirmOrderCommand.cs
│   │   │   │       └── ConfirmOrderCommandHandler.cs
│   │   │   └── Queries/
│   │   │       ├── GetOrderById/
│   │   │       │   ├── GetOrderByIdQuery.cs
│   │   │       │   ├── GetOrderByIdQueryHandler.cs
│   │   │       │   └── OrderDto.cs
│   │   │       └── GetOrdersByCustomer/
│   │   │           ├── GetOrdersByCustomerQuery.cs
│   │   │           └── GetOrdersByCustomerQueryHandler.cs
│   │   ├── Common/
│   │   │   ├── Behaviors/
│   │   │   │   ├── ValidationBehavior.cs
│   │   │   │   ├── LoggingBehavior.cs
│   │   │   │   └── TransactionBehavior.cs
│   │   │   └── Interfaces/
│   │   │       ├── IEmailService.cs
│   │   │       └── ICacheService.cs
│   │   └── DependencyInjection.cs
│   │
│   ├── OrderManagement.Infrastructure/        ← all I/O
│   │   ├── Persistence/
│   │   │   ├── AppDbContext.cs
│   │   │   ├── Configurations/
│   │   │   │   └── OrderConfiguration.cs
│   │   │   └── Repositories/
│   │   │       ├── OrderRepository.cs
│   │   │       └── CustomerRepository.cs
│   │   ├── Messaging/
│   │   │   └── ServiceBusEventPublisher.cs
│   │   ├── Email/
│   │   │   └── SmtpEmailService.cs
│   │   └── DependencyInjection.cs
│   │
│   └── OrderManagement.Api/                   ← outermost
│       ├── Controllers/
│       │   └── OrdersController.cs
│       ├── Middleware/
│       │   └── ExceptionHandlingMiddleware.cs
│       └── Program.cs
│
└── tests/
    ├── OrderManagement.Domain.Tests/
    ├── OrderManagement.Application.Tests/
    └── OrderManagement.Integration.Tests/
```

---

### 4.4 Layer Contracts (Interfaces)

```csharp
// Application layer defines additional contracts
// (Domain defines IRepository; Application defines everything else)

// Contracts in Application layer
namespace OrderManagement.Application.Common.Interfaces;

public interface IEmailService
{
    Task SendAsync(EmailMessage message, CancellationToken ct = default);
}

public interface ICacheService
{
    Task<T?> GetAsync<T>(string key, CancellationToken ct = default);
    Task SetAsync<T>(string key, T value, TimeSpan? expiry = null, CancellationToken ct = default);
    Task RemoveAsync(string key, CancellationToken ct = default);
}

public interface ICurrentUser
{
    Guid UserId { get; }
    string Email { get; }
    IEnumerable<string> Roles { get; }
    bool IsInRole(string role);
}

// Infrastructure implements them
public class RedisCache : ICacheService { ... }
public class SmtpEmailService : IEmailService { ... }
public class HttpContextCurrentUser : ICurrentUser { ... }
```

---

## 5. CQRS — Command Query Responsibility Segregation

### 5.1 Why CQRS

```
WITHOUT CQRS: Single model for reads and writes
─────────────────────────────────────────────────
  Problem 1: Queries return full aggregate (complex joins, N+1)
  Problem 2: Domain model has navigation properties for querying — breaks encapsulation
  Problem 3: Can't scale reads and writes independently
  Problem 4: Validation and projection concerns mixed in same object

WITH CQRS: Separate models
─────────────────────────────────────────────────
  Write model  = Aggregate-based, enforces invariants, rich domain model
  Read model   = Flat DTO optimized for display, can be denormalized

  Benefits:
  ✓ Queries can bypass domain model and hit read DB directly
  ✓ Write and read DBs can be scaled/optimized independently
  ✓ Event sourcing becomes natural
  ✓ No compromise between query efficiency and domain integrity
```

**CQRS Spectrum (choose right level):**

| Level | Write | Read | When to use |
|-------|-------|------|-------------|
| **Single DB** | Domain model + EF Core | Same DB, different query | Most applications |
| **Read Model** | Domain model + EF Core | Separate read-optimized table | Read-heavy, complex queries |
| **Separate DB** | Write DB (SQL) | Read DB (Cosmos/Elastic) | High-scale, different storage needs |
| **Event Sourced** | Event store | Projections from events | Full audit trail needed |

---

### 5.2 Commands — Write Side

```csharp
// Command = intent to change state
// Convention: verb + noun (PlaceOrder, ConfirmOrder, CancelOrder)

// MediatR IRequest<TResponse> — command with typed result
public record PlaceOrderCommand(
    Guid CustomerId,
    List<OrderLineRequest> Lines
) : IRequest<PlaceOrderResult>;

public record OrderLineRequest(
    Guid ProductId,
    int Quantity
);

// Result — use Result pattern (avoid exceptions for business failures)
public record PlaceOrderResult(
    bool IsSuccess,
    Guid? OrderId = null,
    string? Error = null)
{
    public static PlaceOrderResult Success(Guid orderId) => new(true, orderId);
    public static PlaceOrderResult Failure(string error) => new(false, Error: error);
}

// Command Handler — in Application layer
public class PlaceOrderCommandHandler : IRequestHandler<PlaceOrderCommand, PlaceOrderResult>
{
    private readonly IOrderRepository _orderRepo;
    private readonly ICustomerRepository _customerRepo;
    private readonly IProductRepository _productRepo;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IDomainEventDispatcher _eventDispatcher;

    public PlaceOrderCommandHandler(
        IOrderRepository orderRepo,
        ICustomerRepository customerRepo,
        IProductRepository productRepo,
        IUnitOfWork unitOfWork,
        IDomainEventDispatcher eventDispatcher)
    {
        _orderRepo = orderRepo;
        _customerRepo = customerRepo;
        _productRepo = productRepo;
        _unitOfWork = unitOfWork;
        _eventDispatcher = eventDispatcher;
    }

    public async Task<PlaceOrderResult> Handle(
        PlaceOrderCommand command,
        CancellationToken cancellationToken)
    {
        // 1. Validate pre-conditions (beyond FluentValidation)
        var customerId = CustomerId.From(command.CustomerId);
        var customer = await _customerRepo.GetByIdAsync(customerId, cancellationToken);
        if (customer is null)
            return PlaceOrderResult.Failure($"Customer {customerId} not found");

        // 2. Create aggregate via factory/static method
        var order = Order.Create(customerId);

        // 3. Apply domain operations (business rules enforced inside aggregate)
        foreach (var lineRequest in command.Lines)
        {
            var productId = ProductId.From(lineRequest.ProductId);
            var product = await _productRepo.GetByIdAsync(productId, cancellationToken);

            if (product is null)
                return PlaceOrderResult.Failure($"Product {productId} not found");

            if (!product.IsInStock)
                return PlaceOrderResult.Failure($"Product {product.Name} is out of stock");

            order.AddLine(product.Id, lineRequest.Quantity, product.Price);
        }

        // 4. Persist
        await _orderRepo.AddAsync(order, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // 5. Dispatch domain events (AFTER successful save)
        await _eventDispatcher.DispatchAsync(order.DomainEvents, cancellationToken);
        order.ClearDomainEvents();

        return PlaceOrderResult.Success(order.Id.Value);
    }
}
```

---

### 5.3 Queries — Read Side

```csharp
// Query = read intent — no state change, can be cached

public record GetOrderByIdQuery(Guid OrderId) : IRequest<OrderDetailDto?>;

// DTO — flat, display-optimized, no domain logic
public record OrderDetailDto(
    Guid Id,
    string CustomerName,
    string Status,
    decimal TotalAmount,
    string Currency,
    DateTime CreatedAt,
    List<OrderLineDto> Lines
);

public record OrderLineDto(
    Guid ProductId,
    string ProductName,
    int Quantity,
    decimal UnitPrice,
    decimal LineTotal
);

// Query Handler — can bypass domain model for efficiency
public class GetOrderByIdQueryHandler : IRequestHandler<GetOrderByIdQuery, OrderDetailDto?>
{
    private readonly IReadDbContext _readDb; // WHY: separate read context, no change tracking

    public GetOrderByIdQueryHandler(IReadDbContext readDb)
        => _readDb = readDb;

    public async Task<OrderDetailDto?> Handle(
        GetOrderByIdQuery query,
        CancellationToken cancellationToken)
    {
        // Direct SQL-like projection — NO domain aggregate loaded
        // WHY: Avoids loading full aggregate with invariants for a read-only operation
        var result = await _readDb.Orders
            .AsNoTracking()                 // WHY: read-only, no EF change tracking overhead
            .Where(o => o.Id == query.OrderId)
            .Select(o => new OrderDetailDto(
                o.Id.Value,
                o.Customer.FullName,        // join — fine for queries, not for writes
                o.Status.ToString(),
                o.TotalAmount.Amount,
                o.TotalAmount.Currency,
                o.CreatedAt,
                o.Lines.Select(l => new OrderLineDto(
                    l.ProductId.Value,
                    l.Product.Name,
                    l.Quantity,
                    l.UnitPrice.Amount,
                    l.LineTotal.Amount
                )).ToList()
            ))
            .FirstOrDefaultAsync(cancellationToken);

        return result;
    }
}

// Paged query example
public record GetOrdersByCustomerQuery(
    Guid CustomerId,
    int Page = 1,
    int PageSize = 20,
    string? StatusFilter = null
) : IRequest<PagedResult<OrderSummaryDto>>;

public record PagedResult<T>(
    IEnumerable<T> Items,
    int TotalCount,
    int Page,
    int PageSize)
{
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
    public bool HasNextPage => Page < TotalPages;
    public bool HasPreviousPage => Page > 1;
}

public class GetOrdersByCustomerQueryHandler
    : IRequestHandler<GetOrdersByCustomerQuery, PagedResult<OrderSummaryDto>>
{
    private readonly IReadDbContext _readDb;

    public async Task<PagedResult<OrderSummaryDto>> Handle(
        GetOrdersByCustomerQuery query, CancellationToken ct)
    {
        var baseQuery = _readDb.Orders
            .AsNoTracking()
            .Where(o => o.CustomerId.Value == query.CustomerId);

        if (query.StatusFilter is not null)
        {
            var status = Enum.Parse<OrderStatus>(query.StatusFilter);
            baseQuery = baseQuery.Where(o => o.Status == status);
        }

        var totalCount = await baseQuery.CountAsync(ct);

        var items = await baseQuery
            .OrderByDescending(o => o.CreatedAt)
            .Skip((query.Page - 1) * query.PageSize)
            .Take(query.PageSize)
            .Select(o => new OrderSummaryDto(
                o.Id.Value,
                o.Status.ToString(),
                o.TotalAmount.Amount,
                o.CreatedAt,
                o.Lines.Count
            ))
            .ToListAsync(ct);

        return new PagedResult<OrderSummaryDto>(
            items, totalCount, query.Page, query.PageSize);
    }
}
```

---

### 5.4 MediatR Pipeline

```csharp
// Program.cs / DI setup
builder.Services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssembly(typeof(PlaceOrderCommand).Assembly);

    // WHY: Order matters — validation runs before logging, transaction wraps handler
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(TransactionBehavior<,>));
});

// Controller — thin, just maps HTTP to CQRS
[ApiController]
[Route("api/orders")]
public class OrdersController : ControllerBase
{
    private readonly IMediator _mediator;

    public OrdersController(IMediator mediator)
        => _mediator = mediator;

    [HttpPost]
    public async Task<IActionResult> PlaceOrder(
        [FromBody] PlaceOrderCommand command,
        CancellationToken ct)
    {
        var result = await _mediator.Send(command, ct);

        return result.IsSuccess
            ? CreatedAtAction(nameof(GetOrder), new { id = result.OrderId }, result)
            : BadRequest(result.Error);
    }

    [HttpPost("{id}/confirm")]
    public async Task<IActionResult> ConfirmOrder(Guid id, CancellationToken ct)
    {
        var result = await _mediator.Send(new ConfirmOrderCommand(id), ct);
        return result.IsSuccess ? NoContent() : BadRequest(result.Error);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetOrder(Guid id, CancellationToken ct)
    {
        var order = await _mediator.Send(new GetOrderByIdQuery(id), ct);
        return order is null ? NotFound() : Ok(order);
    }

    [HttpGet("by-customer/{customerId}")]
    public async Task<IActionResult> GetByCustomer(
        Guid customerId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken ct = default)
    {
        var result = await _mediator.Send(
            new GetOrdersByCustomerQuery(customerId, page, pageSize), ct);
        return Ok(result);
    }
}
```

---

### 5.5 Pipeline Behaviors (Cross-Cutting)

```csharp
// 1. Validation Behavior — runs FluentValidation before handler
public class ValidationBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
        => _validators = validators;

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        if (!_validators.Any())
            return await next();   // WHY: skip if no validators registered

        var context = new ValidationContext<TRequest>(request);

        var failures = _validators
            .Select(v => v.Validate(context))
            .SelectMany(r => r.Errors)
            .Where(f => f is not null)
            .ToList();

        if (failures.Any())
            throw new ValidationException(failures);

        return await next();
    }
}

// FluentValidation validator — co-located with command
public class PlaceOrderCommandValidator : AbstractValidator<PlaceOrderCommand>
{
    public PlaceOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId)
            .NotEmpty().WithMessage("Customer ID is required");

        RuleFor(x => x.Lines)
            .NotEmpty().WithMessage("Order must have at least one line");

        RuleForEach(x => x.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId)
                .NotEmpty().WithMessage("Product ID required");
            line.RuleFor(l => l.Quantity)
                .GreaterThan(0).WithMessage("Quantity must be positive");
        });
    }
}

// 2. Logging Behavior — structured logs for every request
public class LoggingBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;

    public LoggingBehavior(ILogger<LoggingBehavior<TRequest, TResponse>> logger)
        => _logger = logger;

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var requestName = typeof(TRequest).Name;

        _logger.LogInformation("Handling {RequestName} {@Request}", requestName, request);

        var sw = Stopwatch.StartNew();
        try
        {
            var response = await next();
            sw.Stop();

            _logger.LogInformation(
                "Handled {RequestName} in {ElapsedMs}ms",
                requestName, sw.ElapsedMilliseconds);

            return response;
        }
        catch (Exception ex)
        {
            sw.Stop();
            _logger.LogError(ex,
                "Error handling {RequestName} after {ElapsedMs}ms",
                requestName, sw.ElapsedMilliseconds);
            throw;
        }
    }
}

// 3. Transaction Behavior — wraps commands in DB transaction
// WHY: Only apply to commands (ICommand marker), not queries
public interface ICommand { }
public interface ICommand<TResponse> : IRequest<TResponse>, ICommand { }

public class TransactionBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : ICommand<TResponse>   // WHY: only commands get transactions
{
    private readonly IDbContext _dbContext;

    public TransactionBehavior(IDbContext dbContext)
        => _dbContext = dbContext;

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        await using var transaction = await _dbContext.BeginTransactionAsync(cancellationToken);
        try
        {
            var response = await next();
            await transaction.CommitAsync(cancellationToken);
            return response;
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }
}

// 4. Caching Behavior — for queries
public interface ICacheableQuery
{
    string CacheKey { get; }
    TimeSpan CacheDuration { get; }
}

public class CachingBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>, ICacheableQuery
{
    private readonly ICacheService _cache;
    private readonly ILogger<CachingBehavior<TRequest, TResponse>> _logger;

    public CachingBehavior(ICacheService cache,
        ILogger<CachingBehavior<TRequest, TResponse>> logger)
    {
        _cache = cache;
        _logger = logger;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var cached = await _cache.GetAsync<TResponse>(request.CacheKey, cancellationToken);
        if (cached is not null)
        {
            _logger.LogDebug("Cache hit for {CacheKey}", request.CacheKey);
            return cached;
        }

        var response = await next();

        await _cache.SetAsync(
            request.CacheKey, response, request.CacheDuration, cancellationToken);

        return response;
    }
}

// Usage — query with cache
public record GetOrderByIdQuery(Guid OrderId)
    : IRequest<OrderDetailDto?>, ICacheableQuery
{
    public string CacheKey => $"order:{OrderId}";
    public TimeSpan CacheDuration => TimeSpan.FromMinutes(5);
}
```

---

## 6. Full Integration — DDD + Clean Arch + CQRS

### 6.1 Reference Domain: Order Management

```
┌──────────────────────────────────────────────────────────────────────┐
│                    Order Management — Full Flow                      │
│                                                                      │
│  HTTP POST /api/orders                                               │
│       │                                                              │
│       ▼                                                              │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │  API Layer (Presentation)                                    │    │
│  │  OrdersController.PlaceOrder()                               │    │
│  │  → PlaceOrderCommand { CustomerId, Lines[] }                 │    │
│  └───────────────────────────┬──────────────────────────────────┘    │
│                              │ mediator.Send()                       │
│  ┌───────────────────────────▼──────────────────────────────────┐    │
│  │  MediatR Pipeline                                            │    │
│  │  ValidationBehavior → LoggingBehavior → TransactionBehavior  │    │
│  └───────────────────────────┬──────────────────────────────────┘    │
│                              │                                       │
│  ┌───────────────────────────▼──────────────────────────────────┐    │
│  │  Application Layer                                           │    │
│  │  PlaceOrderCommandHandler                                    │    │
│  │  1. Load Customer (via ICustomerRepository)                  │    │
│  │  2. Load Products (via IProductRepository)                   │    │
│  │  3. Order.Create(customerId)                                 │    │
│  │  4. order.AddLine(...)  ← domain logic                       │    │
│  │  5. orderRepo.AddAsync(order)                                │    │
│  │  6. unitOfWork.SaveChangesAsync()                            │    │
│  │  7. Dispatch DomainEvents                                    │    │
│  └──────────┬────────────────────────────────────┬─────────────┘    │
│             │ domain calls                        │ infra calls      │
│  ┌──────────▼──────────────┐         ┌────────────▼─────────────┐   │
│  │  Domain Layer           │         │  Infrastructure Layer     │   │
│  │  Order (Aggregate)      │         │  OrderRepository (EF)     │   │
│  │  - AddLine()            │         │  AppDbContext              │   │
│  │  - Confirm()            │         │  SmtpEmailService         │   │
│  │  Domain events raised   │         │  ServiceBusPublisher      │   │
│  └─────────────────────────┘         └──────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

### 6.2 Complete Command Flow

```csharp
// ── Domain ─────────────────────────────────────────────────────

// Order.cs (Domain)
public class Order : AggregateRoot<OrderId>
{
    public CustomerId CustomerId { get; private set; }
    public OrderStatus Status { get; private set; }
    public Money TotalAmount { get; private set; }
    public DateTime CreatedAt { get; private set; }
    private readonly List<OrderLine> _lines = new();
    public IReadOnlyList<OrderLine> Lines => _lines.AsReadOnly();

    private Order() { }

    public static Order Create(CustomerId customerId)
    {
        var order = new Order
        {
            Id = OrderId.New(),
            CustomerId = customerId,
            Status = OrderStatus.Draft,
            TotalAmount = Money.Zero,
            CreatedAt = DateTime.UtcNow
        };

        order.AddDomainEvent(new OrderCreatedDomainEvent(order.Id, customerId));
        return order;
    }

    public void AddLine(ProductId productId, int quantity, Money unitPrice)
    {
        Guard.Against.InvalidStatus(Status, OrderStatus.Draft, "add line");
        Guard.Against.NonPositive(quantity, nameof(quantity));

        var existing = _lines.FirstOrDefault(l => l.ProductId == productId);
        if (existing is not null)
            existing.IncreaseQuantity(quantity);
        else
            _lines.Add(OrderLine.Create(Id, productId, quantity, unitPrice));

        RecalculateTotal();
    }

    public Result Confirm()
    {
        if (Status != OrderStatus.Draft)
            return Result.Failure($"Cannot confirm order in status {Status}");

        if (!_lines.Any())
            return Result.Failure("Cannot confirm empty order");

        Status = OrderStatus.Confirmed;
        AddDomainEvent(new OrderConfirmedDomainEvent(Id, CustomerId, TotalAmount));

        return Result.Success();
    }

    public Result Cancel(string reason)
    {
        if (Status == OrderStatus.Shipped)
            return Result.Failure("Cannot cancel a shipped order");

        Status = OrderStatus.Cancelled;
        AddDomainEvent(new OrderCancelledDomainEvent(Id, reason));

        return Result.Success();
    }

    private void RecalculateTotal()
        => TotalAmount = _lines.Aggregate(Money.Zero, (s, l) => s + l.LineTotal);
}

// ── Application ────────────────────────────────────────────────

// ConfirmOrderCommand.cs
public record ConfirmOrderCommand(Guid OrderId) : ICommand<Result>;

// ConfirmOrderCommandValidator.cs
public class ConfirmOrderCommandValidator : AbstractValidator<ConfirmOrderCommand>
{
    public ConfirmOrderCommandValidator()
    {
        RuleFor(x => x.OrderId).NotEmpty();
    }
}

// ConfirmOrderCommandHandler.cs
public class ConfirmOrderCommandHandler : IRequestHandler<ConfirmOrderCommand, Result>
{
    private readonly IOrderRepository _orderRepo;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IDomainEventDispatcher _eventDispatcher;

    public ConfirmOrderCommandHandler(
        IOrderRepository orderRepo,
        IUnitOfWork unitOfWork,
        IDomainEventDispatcher eventDispatcher)
    {
        _orderRepo = orderRepo;
        _unitOfWork = unitOfWork;
        _eventDispatcher = eventDispatcher;
    }

    public async Task<Result> Handle(ConfirmOrderCommand command, CancellationToken ct)
    {
        var orderId = OrderId.From(command.OrderId);

        var order = await _orderRepo.GetByIdAsync(orderId, ct);
        if (order is null)
            return Result.Failure($"Order {orderId} not found");

        // WHY: Business logic stays in domain; handler just orchestrates
        var result = order.Confirm();
        if (!result.IsSuccess)
            return result;

        await _unitOfWork.SaveChangesAsync(ct);
        await _eventDispatcher.DispatchAsync(order.DomainEvents, ct);
        order.ClearDomainEvents();

        return Result.Success();
    }
}
```

### 6.3 Complete Query Flow

```csharp
// Separate Read DbContext — no change tracking, potential separate DB
public class ReadDbContext
{
    private readonly IConfiguration _config;

    public ReadDbContext(IConfiguration config) => _config = config;

    // WHY: Use Dapper or raw SQL for queries — maximum performance, no ORM overhead
    public async Task<OrderDetailDto?> GetOrderDetailAsync(Guid orderId, CancellationToken ct)
    {
        using var connection = new SqlConnection(_config.GetConnectionString("ReadDb"));

        var sql = @"
            SELECT
                o.Id, o.Status, o.TotalAmount, o.Currency, o.CreatedAt,
                c.FullName AS CustomerName,
                ol.ProductId, p.Name AS ProductName,
                ol.Quantity, ol.UnitPrice,
                (ol.Quantity * ol.UnitPrice) AS LineTotal
            FROM Orders o
            INNER JOIN Customers c ON c.Id = o.CustomerId
            LEFT JOIN OrderLines ol ON ol.OrderId = o.Id
            LEFT JOIN Products p ON p.Id = ol.ProductId
            WHERE o.Id = @OrderId AND o.DeletedAt IS NULL";

        // WHY: Multi-map Dapper query to avoid N+1
        var orderDict = new Dictionary<Guid, OrderDetailDto>();

        await connection.QueryAsync<dynamic>(sql,
            new { OrderId = orderId });

        // Map via multi-map if needed...
        // Full Dapper multi-map example:
        await connection.QueryAsync<OrderDetailDto, OrderLineDto, OrderDetailDto>(
            sql,
            (order, line) =>
            {
                if (!orderDict.TryGetValue(Guid.Parse(order.Id.ToString()), out var existing))
                {
                    existing = order with { Lines = new List<OrderLineDto>() };
                    orderDict[Guid.Parse(order.Id.ToString())] = existing;
                }
                (existing.Lines as List<OrderLineDto>)?.Add(line);
                return existing;
            },
            new { OrderId = orderId },
            splitOn: "ProductId"
        );

        return orderDict.Values.FirstOrDefault();
    }
}
```

---

## 7. Domain Events & Integration Events

### 7.1 Domain Events (in-process)

```
Domain Events = internal signals within a Bounded Context
─────────────────────────────────────────────────────────
  Raised by:   Aggregate during a state change
  Dispatched:  AFTER successful save (in same transaction or immediately after)
  Handled by:  Application layer handlers
  Scope:       Single process / single BC

Lifecycle:
  Order.Confirm()
    → raises OrderConfirmedDomainEvent (in-memory)
  Handler.Handle()
    → SaveChanges()       (persist order state)
    → DispatchDomainEvents()
       → SendConfirmationEmailHandler runs
       → UpdateInventoryHandler runs
       → CreateInvoiceHandler runs
```

```csharp
// Domain Event Dispatcher — dispatches in-memory events synchronously or async
public interface IDomainEventDispatcher
{
    Task DispatchAsync(
        IReadOnlyList<IDomainEvent> domainEvents,
        CancellationToken ct = default);
}

public class MediatRDomainEventDispatcher : IDomainEventDispatcher
{
    private readonly IMediator _mediator;

    public MediatRDomainEventDispatcher(IMediator mediator)
        => _mediator = mediator;

    public async Task DispatchAsync(
        IReadOnlyList<IDomainEvent> domainEvents,
        CancellationToken ct = default)
    {
        foreach (var domainEvent in domainEvents)
        {
            // WHY: Publish (not Send) — all handlers run, not just one
            await _mediator.Publish(domainEvent, ct);
        }
    }
}

// Domain Event as MediatR notification
public record OrderConfirmedDomainEvent(
    OrderId OrderId,
    CustomerId CustomerId,
    Money TotalAmount) : DomainEvent, INotification;

// Multiple handlers — all run
public class StartFulfillmentOnOrderConfirmedHandler
    : INotificationHandler<OrderConfirmedDomainEvent>
{
    private readonly IFulfillmentService _fulfillmentService;

    public async Task Handle(
        OrderConfirmedDomainEvent notification,
        CancellationToken cancellationToken)
    {
        await _fulfillmentService.CreatePickListAsync(
            notification.OrderId, cancellationToken);
    }
}

public class SendConfirmationEmailOnOrderConfirmedHandler
    : INotificationHandler<OrderConfirmedDomainEvent>
{
    private readonly IEmailService _emailService;
    private readonly ICustomerRepository _customerRepo;

    public async Task Handle(
        OrderConfirmedDomainEvent notification,
        CancellationToken cancellationToken)
    {
        var customer = await _customerRepo.GetByIdAsync(
            notification.CustomerId, cancellationToken);

        await _emailService.SendOrderConfirmationAsync(
            customer!.Email, notification.OrderId, notification.TotalAmount);
    }
}
```

---

### 7.2 Integration Events (cross-service)

```
Integration Events = cross-Bounded Context / cross-service signals
───────────────────────────────────────────────────────────────────
  Raised by:   Application layer handler (triggered by domain event)
  Transported: Message broker (Azure Service Bus, RabbitMQ, Kafka)
  Handled by:  Other microservices / BCs
  Scope:       Multi-process / multi-service

Domain Event → Integration Event translation:
  OrderConfirmedDomainEvent (internal)
    → translate to →
  OrderConfirmedIntegrationEvent (external message payload)
    → publish to Service Bus
    → Inventory BC, Billing BC, Notification BC each subscribe
```

```csharp
// Integration Event — designed for serialization, schema stability
public record OrderConfirmedIntegrationEvent
{
    public Guid EventId { get; init; } = Guid.NewGuid();
    public DateTime OccurredOn { get; init; } = DateTime.UtcNow;
    public int SchemaVersion { get; init; } = 1;         // WHY: for consumers to handle versioning
    public Guid OrderId { get; init; }
    public Guid CustomerId { get; init; }
    public decimal TotalAmount { get; init; }
    public string Currency { get; init; } = default!;
    public List<IntegrationOrderLine> Lines { get; init; } = new();
}

public record IntegrationOrderLine(
    Guid ProductId,
    string ProductName,
    int Quantity,
    decimal UnitPrice);

// Integration Event Publisher interface (Application layer)
public interface IIntegrationEventPublisher
{
    Task PublishAsync<T>(T integrationEvent, CancellationToken ct = default)
        where T : class;
}

// Handler that bridges domain event → integration event
public class PublishIntegrationEventOnOrderConfirmedHandler
    : INotificationHandler<OrderConfirmedDomainEvent>
{
    private readonly IIntegrationEventPublisher _publisher;
    private readonly IOrderRepository _orderRepo; // WHY: need full order data for event

    public async Task Handle(
        OrderConfirmedDomainEvent notification,
        CancellationToken cancellationToken)
    {
        var order = await _orderRepo.GetByIdAsync(notification.OrderId, cancellationToken);

        var integrationEvent = new OrderConfirmedIntegrationEvent
        {
            OrderId = notification.OrderId.Value,
            CustomerId = notification.CustomerId.Value,
            TotalAmount = notification.TotalAmount.Amount,
            Currency = notification.TotalAmount.Currency,
            Lines = order!.Lines.Select(l => new IntegrationOrderLine(
                l.ProductId.Value,
                "Product Name",  // WHY: denormalize for consumer independence
                l.Quantity,
                l.UnitPrice.Amount
            )).ToList()
        };

        await _publisher.PublishAsync(integrationEvent, cancellationToken);
    }
}
```

---

### 7.3 Outbox Pattern

**Mental Model**: A physical outbox on your desk. You put letters in it BEFORE your assistant picks them up. Even if your assistant is late, the letters don't get lost. The write to DB and write to outbox happen in the same transaction.

```
Problem without Outbox:
  1. SaveChanges() → Order saved in DB ✓
  2. Publish to Service Bus → Network failure ✗
  Result: Order saved but event never sent → INCONSISTENCY

Solution — Outbox Pattern:
  1. SaveChanges() + Write to OutboxMessages in SAME TRANSACTION ✓
  2. Background worker reads OutboxMessages → publishes → marks sent ✓
  Result: At-least-once delivery guaranteed
```

```csharp
// OutboxMessage — stored in same DB
public class OutboxMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string EventType { get; set; } = default!;     // WHY: type for deserialization
    public string Payload { get; set; } = default!;       // JSON serialized event
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ProcessedAt { get; set; }            // null = unprocessed
    public string? Error { get; set; }                    // last error if any
    public int RetryCount { get; set; }
}

// Save to outbox in same transaction as domain change
public class SaveIntegrationEventToOutboxHandler
    : INotificationHandler<OrderConfirmedDomainEvent>
{
    private readonly AppDbContext _dbContext;

    public async Task Handle(
        OrderConfirmedDomainEvent notification,
        CancellationToken cancellationToken)
    {
        var integrationEvent = MapToIntegrationEvent(notification);

        var outboxMessage = new OutboxMessage
        {
            EventType = integrationEvent.GetType().FullName!,
            Payload = JsonSerializer.Serialize(integrationEvent)
        };

        // WHY: Same DbContext = same transaction. If SaveChanges fails, both roll back.
        await _dbContext.OutboxMessages.AddAsync(outboxMessage, cancellationToken);
        // No SaveChanges here — will be committed by UoW in command handler
    }
}

// Background worker — processes outbox
public class OutboxProcessor : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<OutboxProcessor> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await ProcessPendingMessagesAsync(stoppingToken);
            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken); // WHY: polling interval
        }
    }

    private async Task ProcessPendingMessagesAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var publisher = scope.ServiceProvider.GetRequiredService<IIntegrationEventPublisher>();

        var messages = await dbContext.OutboxMessages
            .Where(m => m.ProcessedAt == null && m.RetryCount < 3)
            .OrderBy(m => m.CreatedAt)
            .Take(20)       // WHY: batch size — prevents overwhelming publisher
            .ToListAsync(ct);

        foreach (var message in messages)
        {
            try
            {
                var eventType = Type.GetType(message.EventType)!;
                var @event = JsonSerializer.Deserialize(message.Payload, eventType)!;

                await publisher.PublishAsync(@event, ct);

                message.ProcessedAt = DateTime.UtcNow;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process outbox message {Id}", message.Id);
                message.Error = ex.Message;
                message.RetryCount++;
            }
        }

        await dbContext.SaveChangesAsync(ct);
    }
}
```

---

## 8. Advanced Patterns

### 8.1 Event Sourcing

**Mental Model**: A bank ledger. You don't store current balance — you store every deposit and withdrawal. Current state = replay all events. Append-only. Complete audit trail.

```
Traditional (State Sourcing):
  DB stores current state:  Order { Status: "Confirmed", Total: $150 }

Event Sourcing:
  DB stores events:
    1. OrderCreated    { CustomerId: X }
    2. LineAdded       { ProductId: A, Qty: 2, Price: $50 }
    3. LineAdded       { ProductId: B, Qty: 1, Price: $50 }
    4. OrderConfirmed  { }

  Replay → derive current state
```

```csharp
// Event-sourced aggregate base
public abstract class EventSourcedAggregate<TId>
{
    public TId Id { get; protected set; } = default!;
    public int Version { get; private set; }           // WHY: optimistic concurrency
    private readonly List<IDomainEvent> _uncommittedEvents = new();
    public IReadOnlyList<IDomainEvent> UncommittedEvents => _uncommittedEvents.AsReadOnly();

    // Apply event — updates in-memory state
    protected abstract void Apply(IDomainEvent domainEvent);

    protected void RaiseEvent(IDomainEvent domainEvent)
    {
        Apply(domainEvent);                   // WHY: update state FIRST
        _uncommittedEvents.Add(domainEvent);  // then record for persistence
        Version++;
    }

    // Rehydrate from event history
    public void LoadFromHistory(IEnumerable<IDomainEvent> history)
    {
        foreach (var @event in history)
        {
            Apply(@event);
            Version++;
        }
    }

    public void ClearUncommittedEvents()
        => _uncommittedEvents.Clear();
}

// Event-sourced Order aggregate
public class Order : EventSourcedAggregate<OrderId>
{
    public CustomerId CustomerId { get; private set; } = default!;
    public OrderStatus Status { get; private set; }
    public Money TotalAmount { get; private set; } = Money.Zero;
    private readonly List<OrderLine> _lines = new();

    // Private — only reconstituted via events
    private Order() { }

    // Create — raises event, does NOT set state directly
    public static Order Create(CustomerId customerId)
    {
        var order = new Order();
        order.RaiseEvent(new OrderCreatedDomainEvent(OrderId.New(), customerId));
        return order;
    }

    public void AddLine(ProductId productId, int quantity, Money unitPrice)
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOperationException("Cannot add lines to non-draft order");

        RaiseEvent(new OrderLineAddedDomainEvent(Id, productId, quantity, unitPrice));
    }

    public void Confirm()
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOperationException("Order is not in draft state");

        RaiseEvent(new OrderConfirmedDomainEvent(Id, CustomerId, TotalAmount));
    }

    // WHY: Apply() handles ALL state changes — single source of truth
    protected override void Apply(IDomainEvent domainEvent)
    {
        switch (domainEvent)
        {
            case OrderCreatedDomainEvent e:
                Id = e.OrderId;
                CustomerId = e.CustomerId;
                Status = OrderStatus.Draft;
                break;

            case OrderLineAddedDomainEvent e:
                _lines.Add(new OrderLine(e.ProductId, e.Quantity, e.UnitPrice));
                TotalAmount = _lines.Aggregate(Money.Zero,
                    (sum, l) => sum + l.UnitPrice * l.Quantity);
                break;

            case OrderConfirmedDomainEvent:
                Status = OrderStatus.Confirmed;
                break;

            case OrderCancelledDomainEvent:
                Status = OrderStatus.Cancelled;
                break;
        }
    }
}

// Event Store interface
public interface IEventStore
{
    Task<IEnumerable<IDomainEvent>> LoadEventsAsync(
        Guid aggregateId, CancellationToken ct = default);

    Task AppendEventsAsync(
        Guid aggregateId,
        int expectedVersion,   // WHY: optimistic concurrency
        IEnumerable<IDomainEvent> events,
        CancellationToken ct = default);
}

// Event-sourced repository
public class EventSourcedOrderRepository
{
    private readonly IEventStore _eventStore;

    public async Task<Order?> GetByIdAsync(OrderId id, CancellationToken ct)
    {
        var events = await _eventStore.LoadEventsAsync(id.Value, ct);
        if (!events.Any()) return null;

        var order = new Order();  // needs parameterless constructor
        order.LoadFromHistory(events);
        return order;
    }

    public async Task SaveAsync(Order order, CancellationToken ct)
    {
        await _eventStore.AppendEventsAsync(
            order.Id.Value,
            order.Version - order.UncommittedEvents.Count,  // WHY: expected version for OCC
            order.UncommittedEvents,
            ct);

        order.ClearUncommittedEvents();
    }
}
```

---

### 8.2 Saga / Process Manager

**Mental Model**: A travel agency booking a trip. Flight, hotel, and car must all be confirmed. If the hotel fails, cancel the flight and car. Coordinates a multi-step distributed process with compensations.

```
Order Placement Saga:
─────────────────────────────────────────────────────
  Step 1: Reserve inventory      → InventoryReserved / InventoryFailed
  Step 2: Process payment        → PaymentProcessed / PaymentFailed
  Step 3: Create shipment        → ShipmentCreated / ShipmentFailed

  Compensation (on failure):
    PaymentFailed  → Release inventory reservation
    ShipmentFailed → Refund payment + Release inventory
```

```csharp
// Saga state — persisted between steps
public class OrderPlacementSagaState
{
    public Guid SagaId { get; set; } = Guid.NewGuid();
    public Guid OrderId { get; set; }
    public SagaStep CurrentStep { get; set; }
    public bool InventoryReserved { get; set; }
    public bool PaymentProcessed { get; set; }
    public Guid? PaymentTransactionId { get; set; }
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public SagaStatus Status { get; set; } = SagaStatus.InProgress;
}

public enum SagaStep
{
    ReservingInventory,
    ProcessingPayment,
    CreatingShipment,
    Completed,
    Compensating
}

// Saga — orchestration style (single coordinator)
public class OrderPlacementSaga :
    INotificationHandler<OrderConfirmedDomainEvent>,
    INotificationHandler<InventoryReservedEvent>,
    INotificationHandler<InventoryReservationFailedEvent>,
    INotificationHandler<PaymentProcessedEvent>,
    INotificationHandler<PaymentFailedEvent>
{
    private readonly ISagaRepository<OrderPlacementSagaState> _sagaRepo;
    private readonly IInventoryService _inventoryService;
    private readonly IPaymentService _paymentService;
    private readonly IShipmentService _shipmentService;

    // Step 1: Order confirmed → start saga
    public async Task Handle(OrderConfirmedDomainEvent notification, CancellationToken ct)
    {
        var state = new OrderPlacementSagaState
        {
            OrderId = notification.OrderId.Value,
            CurrentStep = SagaStep.ReservingInventory
        };

        await _sagaRepo.SaveAsync(state, ct);

        // Trigger step 1
        await _inventoryService.ReserveForOrderAsync(
            notification.OrderId, ct);
    }

    // Step 1 success → proceed to step 2
    public async Task Handle(InventoryReservedEvent notification, CancellationToken ct)
    {
        var state = await _sagaRepo.GetByOrderIdAsync(notification.OrderId, ct);
        state.InventoryReserved = true;
        state.CurrentStep = SagaStep.ProcessingPayment;

        await _sagaRepo.SaveAsync(state, ct);
        await _paymentService.ProcessForOrderAsync(notification.OrderId, ct);
    }

    // Step 1 failure → saga done (no compensation needed yet)
    public async Task Handle(InventoryReservationFailedEvent notification, CancellationToken ct)
    {
        var state = await _sagaRepo.GetByOrderIdAsync(notification.OrderId, ct);
        state.Status = SagaStatus.Failed;

        await _sagaRepo.SaveAsync(state, ct);
        // Notify order BC to cancel the order
    }

    // Step 2 failure → compensate step 1
    public async Task Handle(PaymentFailedEvent notification, CancellationToken ct)
    {
        var state = await _sagaRepo.GetByOrderIdAsync(notification.OrderId, ct);
        state.CurrentStep = SagaStep.Compensating;

        await _sagaRepo.SaveAsync(state, ct);

        if (state.InventoryReserved)
            await _inventoryService.ReleaseReservationAsync(notification.OrderId, ct);
    }
}
```

---

### 8.3 Eventual Consistency

```csharp
// Scenario: Order confirmed in Sales BC → Inventory must update in separate BC
// These run in separate services; consistency is eventual (via events)

// Sales BC publishes:
public record OrderConfirmedIntegrationEvent { ... }

// Inventory BC subscribes and handles:
public class ReserveInventoryOnOrderConfirmedHandler
{
    private readonly IInventoryRepository _inventoryRepo;
    private readonly IUnitOfWork _unitOfWork;

    public async Task HandleAsync(
        OrderConfirmedIntegrationEvent @event,
        CancellationToken ct)
    {
        foreach (var line in @event.Lines)
        {
            var stock = await _inventoryRepo.GetByProductIdAsync(
                ProductId.From(line.ProductId), ct);

            // WHY: Idempotency key — message may arrive twice (at-least-once delivery)
            if (stock.HasReservation(@event.EventId))
                continue;

            stock.Reserve(line.Quantity, @event.EventId);
            await _inventoryRepo.UpdateAsync(stock, ct);
        }

        await _unitOfWork.SaveChangesAsync(ct);
    }
}

// WHY idempotency: Service Bus / message brokers guarantee at-least-once delivery.
// If the handler succeeds but acknowledgment fails, message is redelivered.
// Idempotency key prevents double-processing.
```

---

### 8.4 Read Model Projections

```csharp
// Denormalized read table — optimized for querying
public class OrderSummaryProjection
{
    public Guid OrderId { get; set; }
    public string CustomerName { get; set; } = default!;
    public string CustomerEmail { get; set; } = default!;
    public string Status { get; set; } = default!;
    public decimal TotalAmount { get; set; }
    public int LineCount { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ConfirmedAt { get; set; }
}

// Projection handler — updates read model when events occur
public class OrderSummaryProjectionHandler :
    INotificationHandler<OrderCreatedDomainEvent>,
    INotificationHandler<OrderConfirmedDomainEvent>,
    INotificationHandler<OrderCancelledDomainEvent>
{
    private readonly IProjectionStore _projectionStore;
    private readonly ICustomerRepository _customerRepo;

    public async Task Handle(OrderCreatedDomainEvent notification, CancellationToken ct)
    {
        var customer = await _customerRepo.GetByIdAsync(notification.CustomerId, ct);

        var projection = new OrderSummaryProjection
        {
            OrderId = notification.OrderId.Value,
            CustomerName = customer!.FullName,
            CustomerEmail = customer.Email,
            Status = "Draft",
            TotalAmount = 0,
            LineCount = 0,
            CreatedAt = notification.OccurredOn
        };

        await _projectionStore.UpsertAsync(projection, ct);
    }

    public async Task Handle(OrderConfirmedDomainEvent notification, CancellationToken ct)
    {
        var projection = await _projectionStore.GetAsync<OrderSummaryProjection>(
            notification.OrderId.Value, ct);

        projection!.Status = "Confirmed";
        projection.TotalAmount = notification.TotalAmount.Amount;
        projection.ConfirmedAt = notification.OccurredOn;

        await _projectionStore.UpsertAsync(projection, ct);
    }

    public async Task Handle(OrderCancelledDomainEvent notification, CancellationToken ct)
    {
        await _projectionStore.UpdateStatusAsync(
            notification.OrderId.Value, "Cancelled", ct);
    }
}
```

---

## 9. Validation Strategy

```
Three levels of validation in DDD + Clean Architecture:
────────────────────────────────────────────────────────
  Level 1: Input validation    (Presentation → Application boundary)
           FluentValidation on Commands/Queries
           "Is this well-formed?" — format, required fields, ranges

  Level 2: Business validation (inside Aggregates)
           Domain invariants enforced by domain objects
           "Is this allowed by business rules?" — status transitions, limits

  Level 3: Domain constraint   (raised as exceptions or Result failures)
           e.g., "Cannot confirm empty order", "Product out of stock"
```

```csharp
// Level 1 — FluentValidation (Application layer)
public class PlaceOrderCommandValidator : AbstractValidator<PlaceOrderCommand>
{
    public PlaceOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId)
            .NotEmpty();

        RuleFor(x => x.Lines)
            .NotEmpty()
            .WithMessage("Must have at least one order line");

        RuleForEach(x => x.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).NotEmpty();
            line.RuleFor(l => l.Quantity)
                .GreaterThan(0)
                .LessThanOrEqualTo(1000)   // WHY: business limit — fraud prevention
                .WithMessage("Quantity must be between 1 and 1000");
        });
    }
}

// Level 2 — Domain invariants (Domain layer, in Aggregate)
public void AddLine(ProductId productId, int quantity, Money unitPrice)
{
    if (Status != OrderStatus.Draft)
        throw new DomainException($"Cannot add lines to order in status {Status}");

    if (quantity <= 0)
        throw new DomainException("Quantity must be positive");

    if (_lines.Count >= 50)   // WHY: business invariant — max 50 lines per order
        throw new DomainException("Order cannot have more than 50 lines");

    // ... proceed
}

// Result type — for business failures that are expected outcomes
public class Result
{
    public bool IsSuccess { get; }
    public string? Error { get; }

    protected Result(bool isSuccess, string? error)
    {
        IsSuccess = isSuccess;
        Error = error;
    }

    public static Result Success() => new(true, null);
    public static Result Failure(string error) => new(false, error);

    public static Result<T> Success<T>(T value) => new(value, true, null);
    public static Result<T> Failure<T>(string error) => new(default!, false, error);
}

public class Result<T> : Result
{
    public T Value { get; }

    internal Result(T value, bool isSuccess, string? error)
        : base(isSuccess, error) => Value = value;

    public static implicit operator Result<T>(T value) => Success(value);
}
```

---

## 10. Testing Strategy

```
Testing Pyramid for DDD + Clean Architecture:
──────────────────────────────────────────────────────────
  Unit Tests (fast, no I/O)
    ├── Domain: Aggregate/Entity behaviour (no mocks needed)
    ├── Domain: Value object equality, invariants
    └── Application: Command handler with mocked repos

  Integration Tests (with DB)
    ├── Repository tests against real EF/SQL
    ├── Command handler end-to-end (with real DB)
    └── Domain event → handler chain

  E2E / API Tests
    └── HTTP → DB round trip
```

```csharp
// Domain test — pure, no mocks
public class OrderTests
{
    [Fact]
    public void AddLine_WhenDraftOrder_ShouldUpdateTotal()
    {
        // Arrange
        var order = Order.Create(CustomerId.New());
        var productId = ProductId.New();
        var price = Money.InUsd(50m);

        // Act
        order.AddLine(productId, 2, price);

        // Assert
        order.TotalAmount.Should().Be(Money.InUsd(100m));
        order.Lines.Should().HaveCount(1);
    }

    [Fact]
    public void AddLine_WhenConfirmedOrder_ShouldThrow()
    {
        // Arrange
        var order = CreateConfirmedOrder();

        // Act & Assert
        var act = () => order.AddLine(ProductId.New(), 1, Money.InUsd(10));

        act.Should().Throw<DomainException>()
            .WithMessage("*Draft*");
    }

    [Fact]
    public void Confirm_WhenDraftOrderWithLines_ShouldRaiseDomainEvent()
    {
        // Arrange
        var order = Order.Create(CustomerId.New());
        order.AddLine(ProductId.New(), 1, Money.InUsd(50));

        // Act
        order.Confirm();

        // Assert
        order.DomainEvents.Should().ContainSingle()
            .Which.Should().BeOfType<OrderConfirmedDomainEvent>();

        order.Status.Should().Be(OrderStatus.Confirmed);
    }

    [Fact]
    public void Confirm_WhenEmptyOrder_ShouldReturnFailure()
    {
        var order = Order.Create(CustomerId.New());

        var result = order.Confirm();

        result.IsSuccess.Should().BeFalse();
        result.Error.Should().Contain("empty");
    }

    private static Order CreateConfirmedOrder()
    {
        var order = Order.Create(CustomerId.New());
        order.AddLine(ProductId.New(), 1, Money.InUsd(50));
        order.Confirm();
        return order;
    }
}

// Value Object test
public class MoneyTests
{
    [Fact]
    public void TwoMoneyWithSameAmountAndCurrency_ShouldBeEqual()
    {
        var a = Money.InUsd(100);
        var b = Money.InUsd(100);

        a.Should().Be(b);
        (a == b).Should().BeTrue();
    }

    [Fact]
    public void Add_DifferentCurrencies_ShouldThrow()
    {
        var usd = Money.InUsd(100);
        var eur = new Money(100, "EUR");

        var act = () => usd.Add(eur);

        act.Should().Throw<CurrencyMismatchException>();
    }
}

// Application layer test — handler with mocked infra
public class PlaceOrderCommandHandlerTests
{
    private readonly Mock<IOrderRepository> _orderRepo = new();
    private readonly Mock<ICustomerRepository> _customerRepo = new();
    private readonly Mock<IProductRepository> _productRepo = new();
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IDomainEventDispatcher> _eventDispatcher = new();

    private PlaceOrderCommandHandler CreateHandler() => new(
        _orderRepo.Object,
        _customerRepo.Object,
        _productRepo.Object,
        _unitOfWork.Object,
        _eventDispatcher.Object);

    [Fact]
    public async Task Handle_ValidCommand_ShouldCreateOrderAndReturnSuccess()
    {
        // Arrange
        var customerId = Guid.NewGuid();
        var productId = Guid.NewGuid();

        _customerRepo
            .Setup(r => r.GetByIdAsync(It.IsAny<CustomerId>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Customer.Create(CustomerId.From(customerId), "John", new Email("j@a.com")));

        _productRepo
            .Setup(r => r.GetByIdAsync(It.IsAny<ProductId>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Product.Create(ProductId.From(productId), "Widget", Money.InUsd(25), true));

        var command = new PlaceOrderCommand(
            customerId,
            new List<OrderLineRequest> { new(productId, 2) });

        var handler = CreateHandler();

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.OrderId.Should().NotBeNull();

        _orderRepo.Verify(r => r.AddAsync(
            It.IsAny<Order>(), It.IsAny<CancellationToken>()), Times.Once);

        _unitOfWork.Verify(u => u.SaveChangesAsync(
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_CustomerNotFound_ShouldReturnFailure()
    {
        _customerRepo
            .Setup(r => r.GetByIdAsync(It.IsAny<CustomerId>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((Customer?)null);

        var command = new PlaceOrderCommand(Guid.NewGuid(),
            new List<OrderLineRequest> { new(Guid.NewGuid(), 1) });

        var result = await CreateHandler().Handle(command, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.Error.Should().Contain("not found");
    }
}

// Integration test — real EF Core + SQLite in-memory
public class OrderRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly DatabaseFixture _fixture;

    public OrderRepositoryTests(DatabaseFixture fixture)
        => _fixture = fixture;

    [Fact]
    public async Task GetByIdAsync_ExistingOrder_ReturnsWithLines()
    {
        using var scope = _fixture.CreateScope();
        var dbContext = scope.GetRequiredService<AppDbContext>();
        var repo = new OrderRepository(dbContext);

        var order = Order.Create(CustomerId.New());
        order.AddLine(ProductId.New(), 2, Money.InUsd(50));
        await repo.AddAsync(order);
        await dbContext.SaveChangesAsync();

        var loaded = await repo.GetByIdAsync(order.Id);

        loaded.Should().NotBeNull();
        loaded!.Lines.Should().HaveCount(1);
        loaded.TotalAmount.Should().Be(Money.InUsd(100));
    }
}
```

---

## 11. Anti-Patterns & Pitfalls

| Anti-Pattern | Problem | Fix |
|---|---|---|
| **Anemic Domain Model** | Entities are just DTOs; logic in services | Move business rules into entities |
| **Fat Application Services** | Application handlers contain domain logic | Push logic into aggregates |
| **God Aggregate** | Order contains Customer, Product, Inventory | Reference by ID; keep aggregates small |
| **Leaking Domain to Infrastructure** | Domain entity has `[Column]`, `[JsonIgnore]` | Use EF Fluent API config in Infrastructure |
| **CQRS Overkill** | Using CQRS for simple CRUD apps | Only apply CQRS where complexity warrants |
| **Domain Service for everything** | All logic in domain services, entities empty | Entity methods first; service only for cross-aggregate |
| **No Ubiquitous Language** | Code uses different terms than domain experts | Align naming in every conversation and code review |
| **Shared DB across BCs** | Two bounded contexts share the same table | Each BC owns its data; integrate via events |
| **Synchronous cross-BC calls** | Sales BC calls Inventory BC via HTTP in-transaction | Use events + eventual consistency |
| **Skipping ACL** | Directly using upstream model in domain | Always translate at BC boundaries |

```csharp
// ANTI-PATTERN: Anemic domain model
public class Order  // just a bag of properties
{
    public Guid Id { get; set; }
    public string Status { get; set; } = "Draft";
    public decimal Total { get; set; }
}

// ...all logic in service:
public class OrderService
{
    public void ConfirmOrder(Order order)
    {
        if (order.Status != "Draft") throw new Exception("...");
        order.Status = "Confirmed";  // WHY THIS IS BAD: business rules outside domain
    }
}

// CORRECT: Rich domain model
public class Order : AggregateRoot<OrderId>
{
    public Result Confirm()  // business rule INSIDE the entity
    {
        if (Status != OrderStatus.Draft)
            return Result.Failure("...");
        Status = OrderStatus.Confirmed;
        AddDomainEvent(new OrderConfirmedDomainEvent(Id, CustomerId, TotalAmount));
        return Result.Success();
    }
}
```

```csharp
// ANTI-PATTERN: Infrastructure leaking into Domain
public class Order
{
    [Key]                           // ← EF attribute in domain layer
    [JsonPropertyName("order_id")]  // ← serialization in domain layer
    public Guid Id { get; set; }
}

// CORRECT: Domain is clean; EF config in Infrastructure
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.HasKey(o => o.Id);

        builder.Property(o => o.Id)
            .HasConversion(id => id.Value, value => OrderId.From(value));

        builder.OwnsOne(o => o.TotalAmount, money =>
        {
            money.Property(m => m.Amount).HasColumnName("TotalAmount");
            money.Property(m => m.Currency).HasColumnName("Currency").HasMaxLength(3);
        });

        builder.HasMany(o => o.Lines)
            .WithOne()
            .HasForeignKey("OrderId");
    }
}
```

---

## 12. Architectural Decision Reference

### When to use DDD Tactical Patterns

| Complexity | Domain Richness | Recommendation |
|---|---|---|
| Low (CRUD) | Low | Skip tactical DDD; use simple CRUD |
| Medium | Medium | Entities + Value Objects only |
| High | High (Core Domain) | Full tactical DDD |

### When to Apply CQRS

| Scenario | Apply CQRS? |
|---|---|
| Simple CRUD microservice | No |
| Read-heavy with complex queries | Yes (single DB, separate read model) |
| High write throughput + analytics queries | Yes (separate DBs) |
| Event sourcing | Yes (mandatory) |
| Mixed read/write complexity | Yes (same DB, different handlers) |

### Consistency Decision

```
Same Aggregate → Strong consistency (one transaction)
Different Aggregates (same BC) → Prefer events, eventual consistency
Different BCs → Must be eventual consistency (via integration events)
```

### Aggregate Design Checklist

```
□ Can this be null without violating business rules?  → separate aggregate
□ Can this be updated independently?                  → separate aggregate
□ Is this always changed together with the root?      → keep in same aggregate
□ Does this need its own lifecycle?                   → separate aggregate
□ Is this shared across multiple aggregates?          → reference by ID
```

### Layer Dependency Quick Reference

```
                    ALLOWED DEPENDENCIES
Domain        ←── Application ←── Infrastructure
                      ←── Presentation

Domain        → nothing (no deps)
Application   → Domain only
Infrastructure→ Domain (implements interfaces)
Presentation  → Application (sends Commands/Queries)
```

### Complete DI Wiring

```csharp
// Domain layer — no DI needed (pure classes)

// Application layer DI
public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services)
    {
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(typeof(PlaceOrderCommand).Assembly);
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
        });

        services.AddValidatorsFromAssembly(typeof(PlaceOrderCommandValidator).Assembly);

        services.AddScoped<IDomainEventDispatcher, MediatRDomainEventDispatcher>();
        services.AddScoped<IOrderFactory, OrderFactory>();

        return services;
    }
}

// Infrastructure layer DI
public static class InfrastructureServiceExtensions
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>(opts =>
            opts.UseSqlServer(configuration.GetConnectionString("Default")));

        services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<AppDbContext>());

        // Repositories
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<ICustomerRepository, CustomerRepository>();
        services.AddScoped<IProductRepository, ProductRepository>();

        // Application contracts
        services.AddScoped<IEmailService, SmtpEmailService>();
        services.AddScoped<ICacheService, RedisCacheService>();
        services.AddScoped<IIntegrationEventPublisher, ServiceBusEventPublisher>();
        services.AddScoped<ICurrentUser, HttpContextCurrentUser>();

        // Background services
        services.AddHostedService<OutboxProcessor>();

        return services;
    }
}

// Program.cs
var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddApplicationServices()
    .AddInfrastructureServices(builder.Configuration)
    .AddControllers();

var app = builder.Build();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.MapControllers();
app.Run();
```

---

## Summary Matrix

```
┌──────────────────────────────────────────────────────────────────────┐
│  Pattern          │  Purpose              │  Layer        │  Key    │
│──────────────────────────────────────────────────────────────────────│
│  Entity           │  Identity + lifecycle │  Domain       │  ID-eq  │
│  Value Object     │  Immutable values     │  Domain       │  Val-eq │
│  Aggregate Root   │  Consistency boundary │  Domain       │  1-txn  │
│  Domain Event     │  State-change signal  │  Domain→App   │  async  │
│  Repository       │  Persistence gateway  │  Domain(i/f)  │  1/aggr │
│  Domain Service   │  Cross-entity logic   │  Domain       │  no-IO  │
│  Specification    │  Query encapsulation  │  Domain       │  compos │
│  Command          │  Write intent         │  Application  │  1-txn  │
│  Query            │  Read intent          │  Application  │  no-chg │
│  Pipeline Behav.  │  Cross-cutting        │  Application  │  MediatR│
│  Integration Evt  │  Cross-BC signal      │  Infra→Bus    │  at-1x  │
│  Outbox           │  Reliable publish     │  Infra        │  same-tx│
│  Saga             │  Long running process │  Application  │  comp.  │
│  Projection       │  Read model update    │  Application  │  event  │
└──────────────────────────────────────────────────────────────────────┘
```

> **Final Key Insight**: The combination of DDD + Clean Architecture + CQRS creates a system where:
> - **Business rules** are explicit, discoverable, and testable in isolation
> - **Infrastructure** can be swapped without touching business logic
> - **Reads** are fast (no domain overhead) and **writes** are safe (invariants enforced)
> - **Bugs** surface at domain boundaries, not scattered in services
> - **Onboarding** is faster — code reads like the domain expert's language
