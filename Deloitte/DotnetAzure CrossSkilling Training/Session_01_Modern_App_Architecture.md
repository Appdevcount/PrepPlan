# Session 01 — Modern App Architecture

**Duration:** 60 minutes
**Audience:** Developers who completed the Intro session
**Goal:** Understand how modern enterprise .NET apps are structured, why layering matters, and how Azure services plug into each layer.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | The Problem: Why Architecture Matters |
| 5–20 min | Clean Architecture — The 4 Layers |
| 20–35 min | SOLID in 5 Minutes (Just the 2 You'll Use Daily) |
| 35–50 min | Azure Services — One Per Layer |
| 50–58 min | Putting It Together — One Flow End-to-End |
| 58–60 min | Key Takeaways + Q&A |

---

## 1. The Problem: Why Architecture Matters (0–5 min)

### Mental Model
> Imagine a city built without zoning laws — a factory next to a hospital next to a school. Everything is close, but any construction breaks something else. Architecture is **zoning for code** — it puts the right things in the right places so changes don't cascade.

**What happens without architecture:**
- Business logic inside controllers → impossible to test without spinning up a web server
- Database calls scattered everywhere → change DB provider = rewrite everything
- No clear ownership → every bug is a mystery tour across 10 files

**What Clean Architecture gives you:**
- Each layer has **one job** and depends only inward
- Business rules are isolated — no framework dependency, fully testable
- Infrastructure (DB, Azure, email) can be swapped without touching business logic

---

## 2. Clean Architecture — The 4 Layers (5–20 min)

### Mental Model
> Think of an onion. The center (Domain) knows nothing about the outside world. Each outer layer can see inward but never outward. Dependencies always point **toward the center**.

```
┌─────────────────────────────────────────────────────────┐
│                   Infrastructure                         │
│   EF Core │ Azure SQL │ Key Vault │ Service Bus │ Redis  │
│  ┌─────────────────────────────────────────────────┐    │
│  │                  Application                     │    │
│  │   Use Cases │ CQRS Commands/Queries │ Interfaces │    │
│  │  ┌───────────────────────────────────────┐      │    │
│  │  │               Domain                  │      │    │
│  │  │  Entities │ Value Objects │ Events     │      │    │
│  │  │  Domain Services │ Business Rules      │      │    │
│  │  └───────────────────────────────────────┘      │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                           ↑
                    API / Presentation
              Controllers │ Minimal API Endpoints
              Middleware │ Request/Response Models
```

### Layer 1 — Domain (The Heart)

**What lives here:** Entities, business rules, domain exceptions, value objects
**What it knows about:** Nothing outside itself
**Rule:** Zero framework references (`using Microsoft.*` = red flag here)

```csharp
// ── Domain Entity ────────────────────────────────────────
public class Order  // Plain C# class — no EF, no ASP.NET, nothing
{
    public Guid Id { get; private set; }
    public string CustomerId { get; private set; }
    public OrderStatus Status { get; private set; }
    private readonly List<OrderLine> _lines = new();
    public IReadOnlyList<OrderLine> Lines => _lines;

    public Order(string customerId)
    {
        Id = Guid.NewGuid();
        CustomerId = customerId;
        Status = OrderStatus.Pending;
    }

    // Business rule lives here — not in a controller
    public void Confirm()
    {
        if (Status != OrderStatus.Pending)
            throw new DomainException("Only pending orders can be confirmed.");

        Status = OrderStatus.Confirmed;
    }
}

public enum OrderStatus { Pending, Confirmed, Shipped, Cancelled }
```

### Layer 2 — Application (Orchestration)

**What lives here:** Use cases (commands/queries), interfaces for infrastructure, DTOs
**What it knows about:** Domain only
**Rule:** No direct DB calls, no HTTP — only interfaces

```csharp
// ── Interface defined in Application, implemented in Infrastructure ──
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(Guid id);
    Task AddAsync(Order order);
    Task SaveChangesAsync();
}

// ── Use Case (Command Handler) ───────────────────────────
public class ConfirmOrderHandler
{
    private readonly IOrderRepository _orders;
    private readonly IEmailService _email;

    public ConfirmOrderHandler(IOrderRepository orders, IEmailService email)
    {
        _orders = orders;
        _email = email;
    }

    public async Task HandleAsync(Guid orderId)
    {
        var order = await _orders.GetByIdAsync(orderId)
            ?? throw new NotFoundException($"Order {orderId} not found");

        order.Confirm();  // business rule enforced in domain

        await _orders.SaveChangesAsync();
        await _email.SendAsync(order.CustomerId, "Order Confirmed", "Your order is confirmed.");
    }
}
```

### Layer 3 — Infrastructure (Plumbing)

**What lives here:** EF Core DbContext, repository implementations, Azure SDK calls, email clients
**What it knows about:** Application interfaces (it implements them) + Domain entities

```csharp
// ── Implements the interface defined in Application ──────
public class EfOrderRepository : IOrderRepository
{
    private readonly AppDbContext _db;

    public EfOrderRepository(AppDbContext db) => _db = db;

    public Task<Order?> GetByIdAsync(Guid id)
        => _db.Orders.FindAsync(id).AsTask();

    public async Task AddAsync(Order order) => await _db.Orders.AddAsync(order);

    public Task SaveChangesAsync() => _db.SaveChangesAsync();
}
```

### Layer 4 — API / Presentation (Entry Point)

**What lives here:** Minimal API endpoints, middleware, request/response models
**What it knows about:** Application layer only — calls use cases, maps results to HTTP responses

```csharp
// ── Minimal API Endpoint ─────────────────────────────────
app.MapPost("/orders/{id}/confirm", async (Guid id, ConfirmOrderHandler handler) =>
{
    await handler.HandleAsync(id);
    return Results.Ok();
})
.WithName("ConfirmOrder");
```

---

## 3. SOLID — Just the 2 You'll Use Daily (20–35 min)

> Full SOLID is a separate course. Here are the two principles you'll see violated in real code every week.

### S — Single Responsibility Principle

**Rule:** One class, one reason to change.

```csharp
// BAD — this class does three different jobs
public class OrderService
{
    public void ProcessOrder(Order order) { /* business logic */ }
    public void SendEmail(string to) { /* email logic */ }
    public void SaveToDatabase(Order order) { /* db logic */ }
}

// GOOD — each class has one job
public class OrderProcessor   { public void Process(Order o) { } }
public class EmailSender      { public void Send(string to) { } }
public class OrderRepository  { public void Save(Order o) { } }
```

### D — Dependency Inversion Principle

**Rule:** Depend on abstractions (interfaces), not concretions (classes).

```csharp
// BAD — tightly coupled to SqlOrderRepository
public class OrderProcessor
{
    private SqlOrderRepository _repo = new SqlOrderRepository(); // hard dependency
}

// GOOD — depends on the interface; can be any implementation
public class OrderProcessor
{
    private readonly IOrderRepository _repo;
    public OrderProcessor(IOrderRepository repo) => _repo = repo;
}
```

**Why it matters in practice:** When you write unit tests, you inject a fake repository. Without this principle, testing requires a real SQL database.

---

## 4. Azure Services — One Per Layer (35–50 min)

### Mental Model
> Azure is your **infrastructure floor**. Each .NET layer has a matching Azure service that handles the hard parts — scaling, security, availability — so you focus on business logic.

```
┌─────────────────────────────────────────────────────────────────────┐
│  Layer              │  Your Code          │  Azure Service           │
├─────────────────────┼─────────────────────┼──────────────────────────┤
│  API / Presentation │  Minimal API        │  Azure App Service / AKS │
│  Application        │  Use Cases / CQRS   │  Azure Functions         │
│  Infrastructure     │  EF Core            │  Azure SQL / Cosmos DB   │
│  Infrastructure     │  File storage       │  Azure Blob Storage      │
│  Infrastructure     │  Secrets            │  Azure Key Vault         │
│  Infrastructure     │  HTTP between APIs  │  Azure API Management    │
│  Cross-cutting      │  Logging            │  Application Insights    │
└─────────────────────────────────────────────────────────────────────┘
```

### Azure App Service
- Hosts your ASP.NET Core web API
- Handles TLS, scaling, deployments — you just deploy a Docker image or a zip
- Think of it as **managed IIS in the cloud**

### Azure Key Vault
- Stores connection strings, API keys, certificates
- Your app reads secrets at startup — they never live in config files
- Think of it as a **hardware-locked safe for secrets**

### Azure SQL Database
- Fully managed SQL Server — same T-SQL you know
- Handles backups, HA, patching automatically
- EF Core connects to it exactly like local SQL Server

### Azure API Management (APIM)
- Sits **in front of** your API
- Handles rate limiting, authentication, API versioning, developer portal
- Think of it as a **smart traffic cop for APIs**

### Azure Application Insights
- Captures every request, dependency call, exception automatically
- You add one line of code; Azure does the rest
- Think of it as a **flight recorder for your app**

---

## 5. One Flow End-to-End (50–58 min)

**Scenario:** User confirms an order via a mobile app.

```
Mobile App
    │
    │  POST /orders/abc123/confirm
    ▼
Azure API Management          ← validates JWT, rate limits
    │
    ▼
Azure App Service             ← hosts ASP.NET Core Minimal API
    │  MapPost("/orders/{id}/confirm")
    ▼
ConfirmOrderHandler           ← Application layer use case
    │  order.Confirm()        ← Domain business rule enforced
    ▼
EfOrderRepository             ← Infrastructure saves to DB
    │
    ▼
Azure SQL Database            ← persisted

    ── side effect ──
ConfirmOrderHandler
    │  _email.SendAsync(...)
    ▼
SmtpEmailService              ← Infrastructure sends email

    ── observability ──
All layers                    → Application Insights (auto-captured)
```

Every layer has **one job**. Every Azure service has **one responsibility**. Changes in one layer don't ripple through the rest.

---

## Key Takeaways

1. **Clean Architecture = 4 layers** — Domain → Application → Infrastructure → API, dependencies point inward only.
2. **Domain is the heart** — it has zero framework dependencies and contains all business rules.
3. **Interfaces decouple layers** — Application defines the interface; Infrastructure implements it.
4. **Azure maps to layers** — App Service for hosting, Key Vault for secrets, SQL for data, APIM for gateway.
5. **Single Responsibility + Dependency Inversion** are the two SOLID principles you'll apply every day.

---

## Q&A Prompts

1. Why can't the Domain layer reference Entity Framework Core?
2. If you wanted to switch from Azure SQL to Cosmos DB, which layer would you change?
3. What is the difference between a use case and a controller?
4. Where in this architecture would you add input validation?

---

## What's Next — Day 2

You now know **what goes where**. Next session we'll build the top layer: writing real ASP.NET Core Minimal API endpoints, wiring up Dependency Injection, and seeing the request pipeline in action.
