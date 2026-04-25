# Session 01 — Modern App Architecture

**Duration:** 60 minutes
**Audience:** Developers who completed the Intro session
**Goal:** Understand REST API principles, how modern enterprise .NET apps are structured with Clean Architecture, and how Azure services plug into each layer.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–8 min | REST API Principles |
| 8–18 min | Microservices vs Monolith — Honest Comparison |
| 18–35 min | Clean Architecture — The 4 Layers |
| 35–45 min | SOLID — The 2 You'll Use Daily |
| 45–52 min | Putting It Together — One Flow End-to-End |
| 52–60 min | Key Takeaways + Q&A |

---

## 1. REST API Principles (0–8 min)

### Mental Model
> REST is a **set of conventions**, not a technology. It's like traffic rules — everyone follows the same rules so everyone can navigate without a custom map. HTTP verbs, status codes, and URL patterns are the traffic rules for APIs.

### HTTP Verbs — One Verb, One Intent

```
┌──────────┬─────────────────────────────┬──────────────────────────────────┐
│  Verb    │  Intent                     │  Example                         │
├──────────┼─────────────────────────────┼──────────────────────────────────┤
│  GET     │  Read (no side effects)     │  GET /orders          → list     │
│  POST    │  Create new resource        │  POST /orders         → create   │
│  PUT     │  Replace entire resource    │  PUT /orders/123      → replace  │
│  PATCH   │  Update partial fields      │  PATCH /orders/123    → update   │
│  DELETE  │  Remove resource            │  DELETE /orders/123   → delete   │
└──────────┴─────────────────────────────┴──────────────────────────────────┘
```

### HTTP Status Codes — What to Return

```
2xx — Success
  200 OK           → GET, PUT, PATCH succeeded
  201 Created      → POST created a new resource (include Location header)
  204 No Content   → DELETE succeeded, nothing to return

4xx — Client Error (caller did something wrong)
  400 Bad Request  → invalid input, validation failure
  401 Unauthorized → not authenticated (no valid token)
  403 Forbidden    → authenticated but not allowed
  404 Not Found    → resource doesn't exist
  409 Conflict     → state conflict (e.g., duplicate email)

5xx — Server Error (your code is broken)
  500 Internal Server Error → unexpected exception
  503 Service Unavailable   → dependency down, under maintenance
```

### URL Naming — Resources, Not Actions

```
BAD (action-based — RPC style):
  POST /createOrder
  GET  /getOrderById?id=123
  POST /confirmOrder
  POST /deleteOrder

GOOD (resource-based — REST style):
  POST   /orders              ← create
  GET    /orders              ← list
  GET    /orders/123          ← get one
  PUT    /orders/123          ← replace
  PATCH  /orders/123/confirm  ← state transition (verb on sub-resource)
  DELETE /orders/123          ← delete

Rules:
  • Plural nouns for collections (/orders, /customers, /products)
  • Nested resources for relationships (/customers/42/orders)
  • Use query strings for filtering (/orders?status=pending&page=1)
```

---

## 2. Microservices vs Monolith — Honest Comparison (8–18 min)

### Mental Model
> A **monolith** is a single restaurant kitchen where all chefs work together — fast to set up, easy to coordinate, but gets chaotic as you grow. **Microservices** are separate specialist kitchens (pizza, sushi, burgers) — each scales independently, but the coordination overhead is real.

### Direct Comparison

```
┌────────────────────┬──────────────────────────────┬────────────────────────────────┐
│  Dimension         │  Monolith                    │  Microservices                 │
├────────────────────┼──────────────────────────────┼────────────────────────────────┤
│  Deployment        │  One artifact, easy          │  Many services, complex CI/CD  │
│  Dev startup       │  Fast — one project to run   │  Slow — many services to run   │
│  Scaling           │  Scale whole app together    │  Scale each service separately │
│  Team size         │  Works for small teams       │  Suits large, independent teams│
│  Data              │  One shared database         │  Each service owns its data    │
│  Network calls     │  In-process (fast, reliable) │  HTTP/messaging (latency, fail)│
│  Debugging         │  Single trace, easy          │  Distributed tracing needed    │
│  When it breaks    │  Whole app is affected       │  Only that service is affected │
└────────────────────┴──────────────────────────────┴────────────────────────────────┘
```

### When to Choose What

```
Start with a Monolith when:
  • Small team (< 5 engineers)
  • Startup / MVP / unclear domain boundaries
  • Rapid iteration is the priority

Move to Microservices when:
  • Teams are scaling independently and stepping on each other
  • Different parts of the app have radically different scaling needs
  • You've identified clear domain boundaries (don't guess upfront)

Common mistake: Starting with microservices on day 1
  → 3 developers running 12 services locally
  → More time on infrastructure than features
```

### Modular Monolith — The Middle Ground

```
One deployed binary, but code organized like microservices internally:
  ├── OrdersModule/
  ├── CustomersModule/
  ├── InventoryModule/
  └── SharedKernel/

Benefits:
  • Easy to develop and deploy (monolith)
  • Enforced boundaries (can split to services later if needed)
  • Best starting point for enterprise apps
```

---

## 3. Clean Architecture — The 4 Layers (18–35 min)

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
│  │  │  Business Rules │ Domain Exceptions    │      │    │
│  │  └───────────────────────────────────────┘      │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                           ↑
                    API / Presentation
              Minimal API Endpoints │ Middleware
              Request/Response Models │ Swagger
```

### Layer 1 — Domain (The Heart)

**What lives here:** Entities, business rules, domain exceptions
**What it knows about:** Nothing outside itself — zero framework references

```csharp
public class Order
{
    public Guid Id { get; private set; }
    public string CustomerId { get; private set; }
    public OrderStatus Status { get; private set; }

    public Order(string customerId)
    {
        Id = Guid.NewGuid();
        CustomerId = customerId;
        Status = OrderStatus.Pending;
    }

    // Business rule lives in the domain — not in a controller
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

**What lives here:** Use cases, interfaces for infrastructure, DTOs
**What it knows about:** Domain only — no direct DB calls, no HTTP

```csharp
// Interface defined here, implemented in Infrastructure
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(Guid id);
    Task AddAsync(Order order);
    Task SaveChangesAsync();
}

// Use case
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

        order.Confirm();  // domain rule enforced

        await _orders.SaveChangesAsync();
        await _email.SendAsync(order.CustomerId, "Order Confirmed", "Your order is confirmed.");
    }
}
```

### Layer 3 — Infrastructure (Plumbing)

**What lives here:** EF Core, repository implementations, Azure SDK calls
**What it knows about:** Application interfaces (it implements them)

```csharp
public class EfOrderRepository : IOrderRepository
{
    private readonly AppDbContext _db;
    public EfOrderRepository(AppDbContext db) => _db = db;

    public Task<Order?> GetByIdAsync(Guid id) => _db.Orders.FindAsync(id).AsTask();
    public async Task AddAsync(Order order) => await _db.Orders.AddAsync(order);
    public Task SaveChangesAsync() => _db.SaveChangesAsync();
}
```

### Layer 4 — API / Presentation (Entry Point)

**What lives here:** Endpoints, middleware, request/response models
**What it knows about:** Application layer only

```csharp
app.MapPost("/orders/{id}/confirm", async (Guid id, ConfirmOrderHandler handler) =>
{
    await handler.HandleAsync(id);
    return Results.Ok();
});
```

---

## 4. SOLID — The 2 You'll Use Daily (35–45 min)

### S — Single Responsibility Principle

**Rule:** One class, one reason to change.

```csharp
// BAD — three jobs in one class
public class OrderService
{
    public void ProcessOrder(Order order) { /* business logic */ }
    public void SendEmail(string to)     { /* email logic */ }
    public void SaveToDatabase(Order o)  { /* db logic */ }
}

// GOOD — each class has one job
public class OrderProcessor  { public void Process(Order o) { } }
public class EmailSender     { public void Send(string to)  { } }
public class OrderRepository { public void Save(Order o)    { } }
```

### D — Dependency Inversion Principle

**Rule:** Depend on abstractions (interfaces), not concretions (classes).

```csharp
// BAD — tightly coupled
public class OrderProcessor
{
    private SqlOrderRepository _repo = new SqlOrderRepository(); // hard dependency
}

// GOOD — depends on the interface; injectable, testable, swappable
public class OrderProcessor
{
    private readonly IOrderRepository _repo;
    public OrderProcessor(IOrderRepository repo) => _repo = repo;
}
```

---

## 5. One Flow End-to-End (45–52 min)

**Scenario:** User confirms an order via mobile app.

```
Mobile App
    │  POST /orders/abc123/confirm
    ▼
[API Layer]   Minimal API endpoint receives request
    │
    ▼
[Application] ConfirmOrderHandler.HandleAsync()
    │  order.Confirm()   ← domain rule checked
    ▼
[Infrastructure] EfOrderRepository.SaveChangesAsync()
    │
    ▼
[Database]    Row updated in Orders table

    ── side effect ──────────────────────────
[Infrastructure] SmtpEmailService.SendAsync()  → email sent
```

Every layer has **one job**. Changes in one layer don't ripple through the rest.

---

## Azure Integration

> **For the Azure-focused audience** — this section maps every Clean Architecture layer to an Azure service.

### Azure Service Map by Layer

```
┌──────────────────────────────────────────────────────────────────────┐
│  Layer                │  Your Code            │  Azure Service        │
├──────────────────────────────────────────────────────────────────────┤
│  API / Presentation   │  Minimal API          │  Azure App Service    │
│                       │  Containerized API    │  AKS / Container Apps │
│  Application          │  Use Cases / CQRS     │  Azure Functions      │
│  Infrastructure       │  EF Core              │  Azure SQL Database   │
│  Infrastructure       │  Cosmos DB SDK        │  Azure Cosmos DB      │
│  Infrastructure       │  File storage         │  Azure Blob Storage   │
│  Infrastructure       │  Secrets              │  Azure Key Vault      │
│  Infrastructure       │  Service Bus client   │  Azure Service Bus    │
│  Cross-cutting        │  ILogger + AI SDK     │  Application Insights │
│  Gateway              │  (managed for you)    │  Azure API Management │
└──────────────────────────────────────────────────────────────────────┘
```

### Azure App Service — Hosting the API Layer

```
Your ASP.NET Core app → publish → Azure App Service
  • Handles TLS certificates automatically
  • Built-in auto-scaling (scale out on CPU/request count)
  • Deployment slots (staging → production swap with zero downtime)
  • Environment variables injected — override appsettings per environment
```

### Azure API Management (APIM) — The Gateway

```
Internet
    │
    ▼
Azure API Management (APIM)
  ├─ Authentication (validate JWT before it reaches your app)
  ├─ Rate limiting (100 req/min per user)
  ├─ Request/Response transformation
  ├─ Developer portal (auto-generated API docs)
  └─ Routing to multiple backend APIs
    │
    ▼
Your Azure App Service (only APIM can reach it — private)
```

### Azure Well-Architected Framework — 5 Pillars

```
┌──────────────────┬──────────────────────────────────────────────┐
│  Pillar          │  Clean Architecture Alignment                │
├──────────────────┼──────────────────────────────────────────────┤
│  Reliability     │  Domain exceptions + isolated layers         │
│  Security        │  Key Vault + Managed Identity                │
│  Cost            │  Right-size layers — Functions for async     │
│  Operations      │  App Insights + health checks                │
│  Performance     │  Caching + stateless design                  │
└──────────────────┴──────────────────────────────────────────────┘
```

---

## Key Takeaways

1. **REST = conventions** — use the right verb and status code; name URLs as nouns, not actions.
2. **Start with a monolith** — microservices add real operational cost; only split when boundaries are clear.
3. **Clean Architecture = 4 layers** — Domain → Application → Infrastructure → API; dependencies point inward.
4. **Domain is the heart** — zero framework references; all business rules live here.
5. **Single Responsibility + Dependency Inversion** are the two SOLID principles you'll apply every day.

---

## Q&A Prompts

**1. Why should you return `201 Created` instead of `200 OK` for a POST that creates a resource?**

**Answer:** `201 Created` communicates precise intent — the resource now exists and the `Location` header tells the caller where to find it. `200 OK` only says "request succeeded" — it's ambiguous. Clients and API gateways use status codes to decide behavior (e.g., caching `GET 200`, logging `POST 201`).

---

**2. If you wanted to switch from Azure SQL to Cosmos DB, which layer would you change?**

**Answer:** Only the Infrastructure layer — specifically, the repository implementation. You'd replace `EfOrderRepository` (backed by SQL) with a `CosmosOrderRepository` (backed by Cosmos DB SDK). The `IOrderRepository` interface, all Application layer use cases, and the Domain layer remain completely unchanged.

---

**3. What is the difference between a use case and a controller/endpoint?**

**Answer:** A use case (like `ConfirmOrderHandler`) is pure business orchestration — it coordinates domain objects and infrastructure interfaces with no awareness of HTTP. An endpoint is the HTTP entry point — it parses the request, calls the use case, and maps the result to an HTTP response. This separation means the same use case can be triggered by HTTP, a message queue, a scheduled job, or a test.

---

**4. Where in this architecture would you add input validation?**

**Answer:** Two places with different responsibilities. (1) **API layer** — validate HTTP request shape (required fields, max length, valid format) before calling the use case. Return `400 Bad Request` for invalid input. (2) **Domain layer** — validate business rules (e.g., "order total must be positive", "can't confirm a shipped order"). Throw a `DomainException` which the global handler converts to the right HTTP response.

---

## What's Next — Day 2

You now know **what goes where**. Next session we'll build the API layer live — writing real ASP.NET Core Minimal API endpoints, wiring up Dependency Injection, and seeing the request pipeline in action.
