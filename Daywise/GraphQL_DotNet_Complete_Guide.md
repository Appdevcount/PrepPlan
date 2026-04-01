# GraphQL with .NET — Complete Guide: Beginner to Expert

> **Mental Model:** REST is a restaurant where you order from a fixed menu (endpoints). GraphQL is a buffet where *you* specify exactly what you want on your plate — no more, no less. The kitchen (server) exposes everything available; you fetch only what you need.

---

## Table of Contents

1. [What is GraphQL?](#1-what-is-graphql)
2. [GraphQL vs REST — Decision Guide](#2-graphql-vs-rest--decision-guide)
3. [Core Concepts](#3-core-concepts)
   - [Schema Definition Language (SDL)](#31-schema-definition-language-sdl)
   - [Types System](#32-type-system)
   - [Queries](#33-queries)
   - [Mutations](#34-mutations)
   - [Subscriptions](#35-subscriptions)
4. [Setting Up GraphQL in .NET (Hot Chocolate)](#4-setting-up-graphql-in-net-hot-chocolate)
5. [Code-First Schema Design](#5-code-first-schema-design)
6. [Resolvers — The Heart of GraphQL](#6-resolvers--the-heart-of-graphql)
7. [DataLoader — Solving the N+1 Problem](#7-dataloader--solving-the-n1-problem)
8. [Mutations with Validation](#8-mutations-with-validation)
9. [Real-Time Subscriptions](#9-real-time-subscriptions)
10. [Authentication & Authorization](#10-authentication--authorization)
11. [Filtering, Sorting & Pagination](#11-filtering-sorting--pagination)
12. [Error Handling — Domain + Field Errors](#12-error-handling--domain--field-errors)
13. [Testing GraphQL APIs](#13-testing-graphql-apis)
14. [Performance Optimization](#14-performance-optimization)
15. [Production Patterns](#15-production-patterns)
16. [Expert-Level Architecture](#16-expert-level-architecture)
17. [Quick Reference Cheat Sheet](#17-quick-reference-cheat-sheet)

---

## 1. What is GraphQL?

```
┌─────────────────────────────────────────────────────────┐
│                    REST (Traditional)                    │
│                                                         │
│  Client → GET /users/1          → { id, name, email,   │
│  Client → GET /users/1/orders   →   age, address, ...  │
│  Client → GET /orders/99/items  →   (overfetch) }       │
│                                                         │
│  Problem: Multiple round-trips + over/under-fetching    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    GraphQL (Modern)                      │
│                                                         │
│  Client → POST /graphql                                 │
│  {                                                      │
│    user(id: 1) {          ← you define the shape        │
│      name                 ← only what you need          │
│      orders {                                           │
│        total                                            │
│        items { name }                                   │
│      }                                                  │
│    }                                                    │
│  }                                                      │
│                                                         │
│  Result: 1 round-trip, exact data shape                 │
└─────────────────────────────────────────────────────────┘
```

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Single Endpoint** | All requests go to `POST /graphql` |
| **Strongly Typed** | Schema defines every field and its type |
| **Client-Driven** | Client requests exactly what it needs |
| **Introspective** | Schema can be queried at runtime (`__schema`) |
| **Hierarchical** | Data shape mirrors the UI component tree |

### When to Use GraphQL

```
┌──────────────────────────────────────────────────────────┐
│               USE GRAPHQL WHEN                           │
├──────────────────────────────────────────────────────────┤
│ ✅ Multiple clients with different data needs (web/mobile)│
│ ✅ Complex nested/relational data                        │
│ ✅ Rapid UI iteration (shape changes without API changes) │
│ ✅ BFF (Backend for Frontend) layer                      │
│ ✅ Aggregating multiple microservices                    │
├──────────────────────────────────────────────────────────┤
│               USE REST WHEN                              │
├──────────────────────────────────────────────────────────┤
│ ✅ Simple CRUD with predictable data shapes              │
│ ✅ File uploads / binary data                            │
│ ✅ HTTP caching is critical (GET caching)                │
│ ✅ Team unfamiliar with GraphQL                          │
│ ✅ Public APIs with broad consumer base                  │
└──────────────────────────────────────────────────────────┘
```

---

## 2. GraphQL vs REST — Decision Guide

| Dimension | REST | GraphQL |
|-----------|------|---------|
| **Endpoints** | Many (`/users`, `/orders`, ...) | One (`/graphql`) |
| **Data Fetching** | Fixed shape per endpoint | Client-specified shape |
| **Over-fetching** | Common | Eliminated |
| **Under-fetching** | Requires multiple requests | Single round-trip |
| **Versioning** | URL versioning (`/v1/`, `/v2/`) | Schema evolution (deprecation) |
| **Caching** | HTTP GET caching (CDN-friendly) | Requires persisted queries / APQ |
| **Error Format** | HTTP status codes | Always 200, errors in body |
| **Type Safety** | Via OpenAPI (optional) | Built-in schema types |
| **Tooling** | Postman, Swagger | GraphiQL, Banana Cake Pop |
| **Learning Curve** | Low | Medium |
| **N+1 Problem** | N/A | Requires DataLoader |

---

## 3. Core Concepts

### 3.1 Schema Definition Language (SDL)

> **Mental Model:** SDL is the *contract* — like a WSDL for SOAP, but human-readable. It's the source of truth for what data exists and what operations are possible.

```graphql
# ── Type Definitions ─────────────────────────────────────

# Object type — like a C# class
type User {
  id: ID!            # ! = non-null (required field)
  name: String!
  email: String!
  age: Int           # nullable — user may not provide age
  orders: [Order!]!  # non-null list of non-null orders
  createdAt: DateTime!
}

type Order {
  id: ID!
  total: Float!
  status: OrderStatus!  # enum type
  items: [OrderItem!]!
  user: User!           # back-reference — resolvers handle this
}

type OrderItem {
  id: ID!
  productName: String!
  quantity: Int!
  price: Float!
}

# Enum — like C# enum
enum OrderStatus {
  PENDING
  CONFIRMED
  SHIPPED
  DELIVERED
  CANCELLED
}

# ── Root Types (entry points) ─────────────────────────────

# Query = READ operations (like GET in REST)
type Query {
  user(id: ID!): User          # returns nullable (user may not exist)
  users: [User!]!              # returns list, never null
  order(id: ID!): Order
}

# Mutation = WRITE operations (like POST/PUT/DELETE in REST)
type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
  deleteUser(id: ID!): DeleteUserPayload!
}

# Subscription = REAL-TIME operations (like WebSocket in REST)
type Subscription {
  orderStatusChanged(orderId: ID!): Order!
  newOrderPlaced: Order!
}

# ── Input Types (for mutations) ───────────────────────────

# Input types are separate from output types — why?
# Because inputs can't have resolvers; they're pure data containers
input CreateUserInput {
  name: String!
  email: String!
  age: Int
}

input UpdateUserInput {
  name: String
  email: String
  age: Int
}

# Payload types wrap mutation results — allows returning errors + data
type CreateUserPayload {
  user: User           # null if creation failed
  errors: [UserError!] # field-level errors (not HTTP errors)
}

type UserError {
  message: String!
  field: String        # which field caused the error
  code: String!        # machine-readable error code
}
```

### 3.2 Type System

```
┌────────────────────────────────────────────────────────────┐
│                   GraphQL Type System                       │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Scalar Types (primitives)                                 │
│  ├── String      → C# string                              │
│  ├── Int         → C# int (32-bit)                        │
│  ├── Float       → C# double                              │
│  ├── Boolean     → C# bool                                │
│  ├── ID          → C# string (serialized, unique)         │
│  └── Custom: DateTime, Uuid, Url, JSON, Long (via lib)    │
│                                                            │
│  Composite Types                                           │
│  ├── Object Type  → class with fields + resolvers         │
│  ├── Input Type   → class for mutation arguments          │
│  ├── Enum         → enum                                  │
│  ├── Interface    → abstract type (like C# interface)     │
│  └── Union        → one of many types (like discriminated │
│                     union / C# OneOf)                      │
│                                                            │
│  Modifiers                                                 │
│  ├── String!      → non-null (required)                   │
│  ├── [String]     → nullable list of nullable strings     │
│  ├── [String!]    → nullable list of non-null strings     │
│  └── [String!]!   → non-null list of non-null strings     │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 3.3 Queries

A GraphQL query is a tree-shaped read request:

```graphql
# ── Basic Query ───────────────────────────────────────────

# Fetch user by ID — only name and email
query GetUser {
  user(id: "1") {
    name
    email
  }
}

# ── Query with Variables (parameterized — preferred) ──────

# Variables prevent injection and allow reuse
query GetUserById($userId: ID!) {
  user(id: $userId) {
    id
    name
    email
    orders {
      id
      total
      status
    }
  }
}

# Variables JSON (sent alongside the query):
# { "userId": "42" }

# ── Aliases (multiple calls in one request) ───────────────

# Rename fields to avoid collision — fetch two users at once
query GetTwoUsers {
  firstUser: user(id: "1") {
    name
    email
  }
  secondUser: user(id: "2") {
    name
    email
  }
}

# ── Fragments (reusable field sets — DRY principle) ────────

fragment UserBasicFields on User {
  id
  name
  email
}

query GetUsersWithFragment {
  user(id: "1") {
    ...UserBasicFields    # spread fragment like C# mixin
    age
  }
}

# ── Inline Fragments (for interfaces and unions) ───────────

# Imagine SearchResult is a union: User | Order | Product
query Search($term: String!) {
  search(term: $term) {
    ... on User {         # like C# pattern matching: if (x is User u)
      name
      email
    }
    ... on Order {
      total
      status
    }
    ... on Product {
      title
      price
    }
  }
}

# ── Directives (conditional field inclusion) ───────────────

query GetUserConditional($includeOrders: Boolean!, $userId: ID!) {
  user(id: $userId) {
    name
    # @include: only fetch orders if flag is true — saves bandwidth
    orders @include(if: $includeOrders) {
      total
    }
    # @skip: opposite of @include
    email @skip(if: false)
  }
}
```

### 3.4 Mutations

```graphql
# ── Basic Mutation ────────────────────────────────────────

mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    # Request the created user back (confirm what was saved)
    user {
      id
      name
      email
    }
    # Also request any validation errors
    errors {
      message
      field
      code
    }
  }
}

# Variables:
# {
#   "input": {
#     "name": "Alice",
#     "email": "alice@example.com"
#   }
# }

# ── Mutation with Optimistic Response (client-side pattern) ─

# Multiple mutations in one request execute sequentially (not parallel)
mutation BatchOperations {
  createUser: createUser(input: { name: "Bob", email: "bob@ex.com" }) {
    user { id }
  }
  updateUser: updateUser(id: "1", input: { name: "Alice Updated" }) {
    user { id name }
  }
}
```

### 3.5 Subscriptions

```graphql
# ── Real-Time Subscription ────────────────────────────────

# WebSocket connection — server PUSHES updates to client
subscription OnOrderStatusChange($orderId: ID!) {
  orderStatusChanged(orderId: $orderId) {
    id
    status
    updatedAt
  }
}

# Client receives a stream of events:
# { data: { orderStatusChanged: { id: "99", status: "SHIPPED" } } }
# { data: { orderStatusChanged: { id: "99", status: "DELIVERED" } } }
```

---

## 4. Setting Up GraphQL in .NET (Hot Chocolate)

> **Mental Model:** Hot Chocolate is to GraphQL what ASP.NET Core is to HTTP. It's the server framework that maps your C# types to a GraphQL schema and handles execution.

### NuGet Packages

```bash
# Core Hot Chocolate packages
dotnet add package HotChocolate.AspNetCore        # GraphQL server + middleware
dotnet add package HotChocolate.Data              # filtering, sorting, pagination
dotnet add package HotChocolate.Data.EntityFramework  # EF Core integration

# Optional but recommended
dotnet add package HotChocolate.AspNetCore.Authorization  # auth integration
dotnet add package HotChocolate.Subscriptions.InMemory    # in-process pub/sub
dotnet add package HotChocolate.Subscriptions.Redis       # Redis pub/sub (production)
dotnet add package HotChocolate.Diagnostics.Server        # Banana Cake Pop IDE
```

### Program.cs Setup

```csharp
// ── Program.cs ────────────────────────────────────────────────────────────────
using HotChocolate.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// ── Database ──────────────────────────────────────────────
builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlServer(builder.Configuration.GetConnectionString("Default")));

// ── GraphQL Server Registration ───────────────────────────
builder.Services
    .AddGraphQLServer()
    // Register root types — Hot Chocolate discovers fields via reflection
    .AddQueryType<QueryType>()
    .AddMutationType<MutationType>()
    .AddSubscriptionType<SubscriptionType>()
    // Projection: let clients request only specific DB columns
    // WHY: Without projections, EF loads entire entity even if client wants 1 field
    .AddProjections()
    // Filtering: enables where: { name: { contains: "Alice" } } syntax
    .AddFiltering()
    // Sorting: enables order: { name: ASC } syntax
    .AddSorting()
    // Authorization: integrates with ASP.NET Core policy system
    .AddAuthorization()
    // In-memory pub/sub for subscriptions (Redis for production)
    .AddInMemorySubscriptions()
    // Register all types from this assembly automatically
    .AddTypes();

// ── ASP.NET Core Auth (if needed) ────────────────────────
builder.Services.AddAuthentication().AddJwtBearer();
builder.Services.AddAuthorization();

var app = builder.Build();

// ── Middleware Pipeline ────────────────────────────────────
// WebSockets must come BEFORE GraphQL middleware
// WHY: Subscriptions use WebSocket protocol; order matters in ASP.NET pipeline
app.UseWebSockets();
app.UseAuthentication();
app.UseAuthorization();

// Mount GraphQL at /graphql
app.MapGraphQL();

// Banana Cake Pop — GraphQL IDE for development (like Swagger but for GraphQL)
// WHY: Lets you explore schema, write queries, test mutations interactively
app.MapBananaCakePop("/graphql-ui");

app.Run();
```

### AppDbContext

```csharp
// ── Infrastructure/Persistence/AppDbContext.cs ─────────────────────────────
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ── User ──────────────────────────────────────────
        modelBuilder.Entity<User>(e =>
        {
            e.HasKey(u => u.Id);
            e.Property(u => u.Email).HasMaxLength(256).IsRequired();
            e.HasIndex(u => u.Email).IsUnique(); // enforce unique emails at DB level
            // One-to-many: one user has many orders
            e.HasMany(u => u.Orders)
             .WithOne(o => o.User)
             .HasForeignKey(o => o.UserId)
             .OnDelete(DeleteBehavior.Cascade); // delete orders when user deleted
        });

        // ── Order ─────────────────────────────────────────
        modelBuilder.Entity<Order>(e =>
        {
            e.HasKey(o => o.Id);
            // Store enum as string — readable in DB, not magic numbers
            e.Property(o => o.Status).HasConversion<string>();
        });
    }
}
```

### Domain Entities

```csharp
// ── Domain/Entities/User.cs ───────────────────────────────────────────────

// Entities are mutable (unlike DTOs/records) — they map to DB rows
public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int? Age { get; set; }                    // nullable — optional field
    public DateTime CreatedAt { get; set; }
    public List<Order> Orders { get; set; } = [];    // navigation property — EF uses this
}

// ── Domain/Entities/Order.cs ─────────────────────────────────────────────

public class Order
{
    public int Id { get; set; }
    public decimal Total { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public int UserId { get; set; }                  // FK — always store FK explicitly
    public User User { get; set; } = null!;          // navigation property
    public List<OrderItem> Items { get; set; } = [];
}

public enum OrderStatus
{
    Pending,
    Confirmed,
    Shipped,
    Delivered,
    Cancelled
}

// ── Domain/Entities/OrderItem.cs ──────────────────────────────────────────

public class OrderItem
{
    public int Id { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public int OrderId { get; set; }
    public Order Order { get; set; } = null!;
}
```

---

## 5. Code-First Schema Design

> **Mental Model:** In code-first, your C# types *are* the schema. Hot Chocolate reads your classes via reflection and generates the SDL automatically. Think of it like EF Core Code-First — you write classes, framework generates the schema.

### Query Type

```csharp
// ── GraphQL/Queries/QueryType.cs ──────────────────────────────────────────

// [QueryType] attribute tells Hot Chocolate this class provides root queries
// WHY: Avoids needing to inherit from ObjectType<Query> — cleaner in .NET 8+
[QueryType]
public class QueryType
{
    // ── Single User Query ──────────────────────────────────
    // [ID] attribute maps C# int to GraphQL ID scalar
    // [UseProjection] lets client select only needed columns
    // [UseFiltering] adds where argument
    [UseProjection]
    public async Task<User?> GetUserAsync(
        [ID] int id,                          // argument: user(id: "1")
        AppDbContext db,                       // injected by Hot Chocolate's DI
        CancellationToken ct) =>
        await db.Users
            .Where(u => u.Id == id)
            .FirstOrDefaultAsync(ct);         // returns null if not found (nullable return)

    // ── Users List Query with Filtering/Sorting/Pagination ─
    // [UsePaging] adds Relay-spec cursor pagination: first/after/last/before
    // [UseProjection] + [UseFiltering] + [UseSorting] are Hot Chocolate middleware
    // WHY order matters: Paging → Projection → Filtering → Sorting → actual data
    [UsePaging]          // adds cursor-based pagination
    [UseProjection]      // SELECT only requested columns
    [UseFiltering]       // adds where clause
    [UseSorting]         // adds ORDER BY clause
    public IQueryable<User> GetUsers(AppDbContext db) =>
        db.Users.AsNoTracking();  // AsNoTracking: read-only query, skip change tracking overhead

    // ── Orders Query ──────────────────────────────────────
    [UsePaging(IncludeTotalCount = true)]  // total count for UI pagination display
    [UseProjection]
    [UseFiltering]
    [UseSorting]
    public IQueryable<Order> GetOrders(AppDbContext db) =>
        db.Orders.AsNoTracking();
}
```

### Object Type Extensions (splitting large types)

```csharp
// ── GraphQL/Types/UserType.cs ─────────────────────────────────────────────

// [ExtendObjectType] adds fields to an existing GraphQL type
// WHY: Keeps query class small; related fields grouped by concern
[ExtendObjectType<User>]
public class UserTypeExtensions
{
    // ── Computed Field ─────────────────────────────────────
    // This field doesn't exist on the User entity — it's computed by GraphQL
    // WHY: Client gets displayName; server computes it without DB column
    public string GetDisplayName([Parent] User user) =>  // [Parent] injects the User being resolved
        $"{user.Name} <{user.Email}>";

    // ── Related Data ───────────────────────────────────────
    // [UseDataLoader] automatically batches N queries into one
    // WHY: Prevents N+1 — without DataLoader, fetching 100 users runs 100 order queries
    public async Task<IEnumerable<Order>> GetOrdersAsync(
        [Parent] User user,
        OrdersByUserIdDataLoader dataLoader,   // injected automatically
        CancellationToken ct) =>
        await dataLoader.LoadAsync(user.Id, ct);
}
```

---

## 6. Resolvers — The Heart of GraphQL

> **Mental Model:** A resolver is like a property getter in C# — when a client requests a field, GraphQL calls its resolver function to get the value. Every field has a resolver; Hot Chocolate provides defaults for simple property mappings.

```
┌──────────────────────────────────────────────────────────────────┐
│                   Resolver Execution Flow                         │
│                                                                  │
│  Query: { user(id:1) { name, orders { total } } }               │
│                                                                  │
│  1. Root resolver: GetUser(id: 1)                                │
│     → Fetches User from DB                                       │
│     → Returns User { id:1, name:"Alice", ... }                   │
│                                                                  │
│  2. Field resolver: User.name                                    │
│     → Hot Chocolate default: returns user.Name property          │
│                                                                  │
│  3. Field resolver: User.orders                                  │
│     → Custom resolver: fetches orders WHERE userId = 1          │
│     → Returns [Order { id:10, total: 99.99 }]                   │
│                                                                  │
│  4. Field resolver: Order.total                                  │
│     → Hot Chocolate default: returns order.Total property        │
│                                                                  │
│  Result is assembled bottom-up into the requested shape          │
└──────────────────────────────────────────────────────────────────┘
```

### Resolver Patterns

```csharp
// ── GraphQL/Resolvers/OrderResolvers.cs ───────────────────────────────────

[ExtendObjectType<Order>]
public class OrderResolvers
{
    // ── Pattern 1: Service Injection ───────────────────────
    // Resolver can inject any service registered in DI
    public async Task<decimal> GetTaxAmountAsync(
        [Parent] Order order,
        ITaxCalculator taxCalculator,          // injected from DI
        CancellationToken ct) =>
        await taxCalculator.CalculateAsync(order.Total, ct);

    // ── Pattern 2: Context Access ─────────────────────────
    // IResolverContext gives access to entire execution context
    public string GetDebugInfo(
        [Parent] Order order,
        IResolverContext context)              // full resolver context
    {
        // WHY: Access field path, variables, schema from within resolver
        var fieldPath = context.Path.ToString();
        return $"Resolved at path: {fieldPath}";
    }

    // ── Pattern 3: Conditional Resolution ─────────────────
    // Only compute expensive field if client actually requested it
    [GraphQLDescription("Expensive computed field — only fetch when needed")]
    public async Task<string?> GetAnalyticsSummaryAsync(
        [Parent] Order order,
        IAnalyticsService analytics,
        CancellationToken ct) =>
        await analytics.GetOrderSummaryAsync(order.Id, ct);
}
```

### Custom Scalar Types

```csharp
// ── GraphQL/Scalars/EmailAddressType.cs ───────────────────────────────────

// Custom scalar — validates emails at the GraphQL layer (before reaching business logic)
// WHY: Catches malformed emails immediately, provides clear schema documentation
public class EmailAddressType : StringType
{
    public EmailAddressType()
        : base("EmailAddress",
               "A valid email address (RFC 5322)",
               BindingBehavior.Implicit)
    { }

    protected override bool IsInstanceOfType(string runtimeValue) =>
        // Simple validation — real app use FluentValidation or similar
        runtimeValue.Contains('@') && runtimeValue.Contains('.');

    public override bool TryDeserialize(object? resultValue, out object? runtimeValue)
    {
        if (resultValue is string s && IsInstanceOfType(s))
        {
            runtimeValue = s;
            return true;
        }
        runtimeValue = null;
        return false; // triggers a GraphQL type error — safe failure
    }
}

// Registration in Program.cs:
// .AddType<EmailAddressType>()
```

---

## 7. DataLoader — Solving the N+1 Problem

> **Mental Model:** DataLoader is like a database query batcher. Instead of making 100 individual DB calls (one per user's orders), it collects all 100 user IDs, then fires ONE query: `WHERE userId IN (1, 2, 3, ..., 100)`. Same pattern as Promise.all in JavaScript.

```
┌──────────────────────────────────────────────────────────────────┐
│                     N+1 Problem                                   │
│                                                                  │
│  Without DataLoader:                                             │
│  Query: users { orders { total } }                               │
│                                                                  │
│  1. SELECT * FROM Users              (1 query)                   │
│  2. SELECT * FROM Orders WHERE UserId = 1   (query for user 1)  │
│  3. SELECT * FROM Orders WHERE UserId = 2   (query for user 2)  │
│  ... 100 more queries for 100 users = 101 total queries!         │
│                                                                  │
│  With DataLoader:                                                 │
│  1. SELECT * FROM Users              (1 query)                   │
│  2. SELECT * FROM Orders WHERE UserId IN (1,2,...,100) (1 query) │
│                                                                  │
│  Total: 2 queries regardless of how many users                   │
└──────────────────────────────────────────────────────────────────┘
```

### BatchDataLoader Implementation

```csharp
// ── GraphQL/DataLoaders/OrdersByUserIdDataLoader.cs ───────────────────────

// BatchDataLoader<TKey, TValue>:
//   TKey   = what we search by (user ID)
//   TValue = what we return (list of orders per user)
public class OrdersByUserIdDataLoader
    : BatchDataLoader<int, IReadOnlyList<Order>>
{
    private readonly IDbContextFactory<AppDbContext> _dbFactory;

    // IDbContextFactory: creates a fresh DbContext per DataLoader batch
    // WHY: DataLoader runs outside the request DI scope; can't use scoped DbContext directly
    public OrdersByUserIdDataLoader(
        IDbContextFactory<AppDbContext> dbFactory,
        IBatchScheduler scheduler,              // Hot Chocolate's internal scheduler
        DataLoaderOptions options)
        : base(scheduler, options)
    {
        _dbFactory = dbFactory;
    }

    // LoadBatchAsync is called ONCE with ALL requested keys collected during execution
    // WHY: Hot Chocolate batches all LoadAsync calls made during one request tick
    protected override async Task<IReadOnlyDictionary<int, IReadOnlyList<Order>>>
        LoadBatchAsync(
            IReadOnlyList<int> keys,           // [1, 2, 3, ..., N] — all user IDs at once
            CancellationToken ct)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);

        // Single DB query for ALL users' orders
        var orders = await db.Orders
            .Where(o => keys.Contains(o.UserId))  // WHERE userId IN (1, 2, 3...)
            .ToListAsync(ct);

        // Group by UserId so DataLoader can map back to individual keys
        return orders
            .GroupBy(o => o.UserId)
            .ToDictionary(
                g => g.Key,
                g => (IReadOnlyList<Order>)g.ToList()
            );
    }
}

// ── Registration in Program.cs ────────────────────────────
// .AddDataLoader<OrdersByUserIdDataLoader>()
// OR automatically registered if class is in same assembly as .AddTypes()
```

### GroupDataLoader (for lookups by non-unique key)

```csharp
// ── GraphQL/DataLoaders/ProductDataLoader.cs ──────────────────────────────

// GroupDataLoader: one key maps to MULTIPLE values (like above but built-in grouping)
// Use BatchDataLoader when you need custom grouping logic
// Use GroupDataLoader for simple 1-to-many with single key field

public class OrderItemsByOrderIdDataLoader
    : GroupedDataLoader<int, OrderItem>
{
    private readonly IDbContextFactory<AppDbContext> _dbFactory;

    public OrderItemsByOrderIdDataLoader(
        IDbContextFactory<AppDbContext> dbFactory,
        IBatchScheduler scheduler,
        DataLoaderOptions options)
        : base(scheduler, options)
    {
        _dbFactory = dbFactory;
    }

    protected override async Task<ILookup<int, OrderItem>> LoadGroupedBatchAsync(
        IReadOnlyList<int> keys,
        CancellationToken ct)
    {
        await using var db = await _dbFactory.CreateDbContextAsync(ct);

        var items = await db.OrderItems
            .Where(i => keys.Contains(i.OrderId))
            .ToListAsync(ct);

        // ILookup is like Dictionary<key, IEnumerable<value>>
        // WHY: GroupedDataLoader expects ILookup — handles grouping internally
        return items.ToLookup(i => i.OrderId);
    }
}
```

### Using DataLoader in Resolvers

```csharp
// ── GraphQL/Types/OrderTypeExtensions.cs ──────────────────────────────────

[ExtendObjectType<Order>]
public class OrderTypeExtensions
{
    // Hot Chocolate injects DataLoaders as method parameters — no [FromServices] needed
    public async Task<IReadOnlyList<OrderItem>> GetItemsAsync(
        [Parent] Order order,
        OrderItemsByOrderIdDataLoader itemsLoader,  // auto-injected
        CancellationToken ct) =>
        await itemsLoader.LoadAsync(order.Id, ct);  // batched automatically

    // User DataLoader — reverse lookup
    public async Task<User> GetUserAsync(
        [Parent] Order order,
        UserByIdDataLoader userLoader,
        CancellationToken ct) =>
        await userLoader.LoadAsync(order.UserId, ct);
}
```

---

## 8. Mutations with Validation

> **Mental Model:** A mutation is like a command in CQRS. It encapsulates an intent to change state. The payload pattern (returning both data and errors) mimics the Result<T> pattern — client always knows if the operation succeeded without relying on HTTP status codes.

### Input and Payload Types

```csharp
// ── GraphQL/Mutations/CreateUserMutation.cs ───────────────────────────────

// Input record — immutable by default (record type per CLAUDE.md rule)
// WHY record: inputs are pure data containers, immutability prevents accidental mutation
public record CreateUserInput(
    string Name,
    string Email,
    int? Age
);

public record UpdateUserInput(
    [property: ID] int Id,    // [ID] maps C# int to GraphQL ID scalar
    string? Name,
    string? Email,
    int? Age
);

// Payload — wraps result + errors
// WHY separate type: allows returning partial success + error details together
public record CreateUserPayload(User? User, IReadOnlyList<UserError>? Errors = null)
{
    public bool IsSuccess => Errors is null || !Errors.Any();
}

public record UserError(string Message, string Field, string Code);
```

### Mutation Type

```csharp
// ── GraphQL/Mutations/MutationType.cs ─────────────────────────────────────

[MutationType]  // Hot Chocolate discovers all mutation methods in this class
public class MutationType
{
    // ── Create User ───────────────────────────────────────
    public async Task<CreateUserPayload> CreateUserAsync(
        CreateUserInput input,
        AppDbContext db,
        ILogger<MutationType> logger,
        CancellationToken ct)
    {
        // ── Validation (fail fast at entry point) ──────────
        var errors = ValidateCreateUserInput(input);
        if (errors.Any())
            return new CreateUserPayload(null, errors); // return errors, not exceptions

        // ── Uniqueness Check ───────────────────────────────
        bool emailExists = await db.Users.AnyAsync(u => u.Email == input.Email, ct);
        if (emailExists)
        {
            return new CreateUserPayload(null, [
                new UserError("Email already registered", "email", "EMAIL_TAKEN")
            ]);
        }

        // ── Persist ────────────────────────────────────────
        var user = new User
        {
            Name = input.Name,
            Email = input.Email,
            Age = input.Age,
            CreatedAt = DateTime.UtcNow // always UTC in server-side code
        };

        db.Users.Add(user);
        await db.SaveChangesAsync(ct);

        logger.LogInformation(
            "User created. Id={UserId} Email={Email}",
            user.Id, user.Email); // structured logging — never concatenate

        return new CreateUserPayload(user); // success: errors = null
    }

    // ── Update User ───────────────────────────────────────
    public async Task<UpdateUserPayload> UpdateUserAsync(
        UpdateUserInput input,
        AppDbContext db,
        CancellationToken ct)
    {
        var user = await db.Users.FindAsync([input.Id], ct);
        if (user is null)
        {
            return new UpdateUserPayload(null, [
                new UserError($"User {input.Id} not found", "id", "NOT_FOUND")
            ]);
        }

        // Apply only provided fields (partial update)
        // WHY: null input fields = "don't change this field" (PATCH semantics)
        if (input.Name is not null) user.Name = input.Name;
        if (input.Email is not null) user.Email = input.Email;
        if (input.Age.HasValue) user.Age = input.Age;

        await db.SaveChangesAsync(ct);
        return new UpdateUserPayload(user);
    }

    // ── Delete User ───────────────────────────────────────
    [Authorize(Roles = "Admin")] // only admins can delete
    public async Task<DeleteUserPayload> DeleteUserAsync(
        [ID] int id,
        AppDbContext db,
        CancellationToken ct)
    {
        var user = await db.Users.FindAsync([id], ct);
        if (user is null)
            return new DeleteUserPayload(false, "User not found");

        db.Users.Remove(user);
        await db.SaveChangesAsync(ct);
        return new DeleteUserPayload(true, null);
    }

    // ── Private: Input Validation ──────────────────────────
    private static List<UserError> ValidateCreateUserInput(CreateUserInput input)
    {
        var errors = new List<UserError>();

        if (string.IsNullOrWhiteSpace(input.Name))
            errors.Add(new UserError("Name is required", "name", "REQUIRED"));

        if (string.IsNullOrWhiteSpace(input.Email))
            errors.Add(new UserError("Email is required", "email", "REQUIRED"));
        else if (!input.Email.Contains('@'))
            errors.Add(new UserError("Invalid email format", "email", "INVALID_FORMAT"));

        if (input.Age.HasValue && (input.Age < 0 || input.Age > 150))
            errors.Add(new UserError("Age must be between 0 and 150", "age", "OUT_OF_RANGE"));

        return errors;
    }
}

// Additional payload records
public record UpdateUserPayload(User? User, IReadOnlyList<UserError>? Errors = null);
public record DeleteUserPayload(bool Success, string? Error);
```

---

## 9. Real-Time Subscriptions

> **Mental Model:** Subscriptions are like a pub/sub event bus exposed over WebSocket. The client subscribes to a topic; the server publishes events when relevant mutations occur. Think SignalR groups but schema-typed.

```csharp
// ── GraphQL/Subscriptions/SubscriptionType.cs ────────────────────────────

[SubscriptionType]
public class SubscriptionType
{
    // ── Order Status Changed ───────────────────────────────
    // [Subscribe] links this method to the event stream
    // [Topic] defines the pub/sub channel name
    // WHY dynamic topic: each order has its own channel — subscribers only get their order's events
    [Subscribe]
    [Topic("{orderId}")]  // topic per order ID — namespaced subscription
    public Order OnOrderStatusChanged(
        [EventMessage] Order order) => // [EventMessage] injects the published event
        order;

    // ── New Order Placed (broadcast to all subscribers) ───
    [Subscribe]
    [Topic(nameof(OnNewOrderPlaced))] // static topic — everyone gets all new orders
    public Order OnNewOrderPlaced([EventMessage] Order order) => order;
}
```

### Publishing Events from Mutations

```csharp
// ── GraphQL/Mutations/OrderMutations.cs ───────────────────────────────────

[MutationType]
public class OrderMutations
{
    // ITopicEventSender: Hot Chocolate's pub/sub publisher
    public async Task<Order> UpdateOrderStatusAsync(
        [ID] int orderId,
        OrderStatus newStatus,
        AppDbContext db,
        ITopicEventSender eventSender,         // injected — publishes to WebSocket subscribers
        CancellationToken ct)
    {
        var order = await db.Orders.FindAsync([orderId], ct)
            ?? throw new GraphQLException(
                ErrorBuilder.New()
                    .SetMessage("Order not found")
                    .SetCode("ORDER_NOT_FOUND")
                    .Build());

        order.Status = newStatus;
        await db.SaveChangesAsync(ct);

        // Publish to subscribers of this specific order's topic
        // WHY $"{orderId}": matches the [Topic("{orderId}")] pattern in SubscriptionType
        await eventSender.SendAsync(
            topic: orderId.ToString(),   // dynamic topic matches subscription
            message: order,             // the event payload
            cancellationToken: ct);

        // Also publish to the "all new orders" topic if order was just confirmed
        if (newStatus == OrderStatus.Confirmed)
            await eventSender.SendAsync(
                nameof(SubscriptionType.OnNewOrderPlaced),
                order, ct);

        return order;
    }
}
```

### Production: Redis for Subscriptions

```csharp
// ── Replace in-memory with Redis for multi-instance deployments ──────────
// WHY: In-memory pub/sub only works on single server; Redis broadcasts across all pods

builder.Services
    .AddGraphQLServer()
    .AddRedisSubscriptions(sp =>
        sp.GetRequiredService<IConnectionMultiplexer>());
// Requires: StackExchange.Redis NuGet + Redis connection string in config
```

---

## 10. Authentication & Authorization

> **Mental Model:** Auth in GraphQL works at two levels: (1) HTTP middleware checks the JWT token like any ASP.NET app; (2) `[Authorize]` attributes on resolvers/types enforce role/policy checks at field level — you can expose some fields publicly and restrict others.

### JWT Setup

```csharp
// ── Program.cs additions ──────────────────────────────────────────────────

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Auth:Authority"];
        options.Audience = builder.Configuration["Auth:Audience"];
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            // WHY ClockSkew = 0: prevent tokens valid slightly past expiry
            // Tight security; adjust if clients have clock drift issues
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization(opt =>
{
    // Policy-based auth — more flexible than role-based
    opt.AddPolicy("CanManageUsers",
        p => p.RequireRole("Admin").RequireClaim("department", "IT"));
});

// GraphQL authorization middleware
builder.Services
    .AddGraphQLServer()
    .AddAuthorization();
```

### Applying Authorization

```csharp
// ── Authorize at Type Level ────────────────────────────────────────────────

// Every resolver in this type requires authentication
[Authorize]  // equivalent to [Authorize(AuthenticationSchemes = "Bearer")]
[QueryType]
public class AdminQueryType
{
    public IQueryable<User> GetAllUsers(AppDbContext db) =>
        db.Users.AsNoTracking();
}

// ── Authorize at Field Level ──────────────────────────────────────────────

[QueryType]
public class UserQueryType
{
    // Public — no auth required
    public async Task<User?> GetUserPublicInfoAsync([ID] int id, AppDbContext db, CancellationToken ct) =>
        await db.Users.FindAsync([id], ct);

    // Requires "CanManageUsers" policy
    [Authorize(Policy = "CanManageUsers")]
    public IQueryable<User> GetAllUsersAdmin(AppDbContext db) =>
        db.Users;
}

// ── Accessing Current User in Resolver ────────────────────────────────────

[QueryType]
public class MeQueryType
{
    // IHttpContextAccessor: access current HTTP context and user claims
    public async Task<User?> GetMeAsync(
        IHttpContextAccessor httpContextAccessor,
        AppDbContext db,
        CancellationToken ct)
    {
        // Extract user ID from JWT claims
        var userIdClaim = httpContextAccessor.HttpContext?.User
            .FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!int.TryParse(userIdClaim, out var userId))
            return null; // unauthenticated

        return await db.Users.FindAsync([userId], ct);
    }
}
```

### Field-Level Authorization with Custom Directive

```csharp
// ── GraphQL/Authorization/OwnerOrAdminDirective.cs ────────────────────────

// Custom authorization: user can only see their own email, unless admin
// WHY: Role-based not enough — users should only modify their OWN data
public class OwnerOrAdminMiddleware(FieldDelegate next)
{
    public async Task InvokeAsync(IMiddlewareContext context)
    {
        var httpContext = context.Service<IHttpContextAccessor>().HttpContext!;
        var user = httpContext.User;

        // Admin bypass — can see everyone's data
        if (user.IsInRole("Admin"))
        {
            await next(context);
            return;
        }

        // Extract resource owner ID from parent object
        var parentUser = context.Parent<User>();
        var currentUserId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (parentUser.Id.ToString() != currentUserId)
        {
            // Return null instead of throwing — graceful degradation
            // WHY null vs exception: other fields still resolve; partial data is better than none
            context.Result = null;
            return;
        }

        await next(context);
    }
}
```

---

## 11. Filtering, Sorting & Pagination

> **Mental Model:** Hot Chocolate's data middleware (`UseFiltering`, `UseSorting`, `UsePaging`) automatically translates GraphQL query arguments into LINQ expressions — no manual WHERE clauses needed. It's like OData but GraphQL-native.

### Query Examples (Client Side)

```graphql
# ── Filtering ─────────────────────────────────────────────

query FilteredUsers {
  users(
    where: {
      and: [
        { name: { contains: "Alice" } }   # LIKE '%Alice%'
        { age: { gte: 18 } }              # >= 18
        { email: { endsWith: "@company.com" } }
      ]
    }
  ) {
    nodes {
      id
      name
      email
      age
    }
  }
}

# ── Sorting ───────────────────────────────────────────────

query SortedUsers {
  users(
    order: [
      { name: ASC }      # ORDER BY name ASC
      { createdAt: DESC } # THEN BY createdAt DESC
    ]
  ) {
    nodes {
      name
      createdAt
    }
  }
}

# ── Cursor-Based Pagination (Relay spec) ──────────────────

query PaginatedUsers {
  users(first: 10, after: "cursor_from_previous_page") {
    nodes {          # actual data
      id
      name
    }
    pageInfo {       # metadata for next/prev page
      hasNextPage
      hasPreviousPage
      startCursor    # cursor for first item in this page
      endCursor      # cursor for last item (use as "after" in next query)
    }
    totalCount       # total records (only if IncludeTotalCount = true)
  }
}

# ── Offset Pagination (simpler, less efficient) ────────────

query OffsetPaginatedUsers {
  usersOffset(skip: 20, take: 10) {
    items {
      id
      name
    }
    pageInfo {
      hasNextPage
    }
  }
}
```

### Custom Filtering Rules

```csharp
// ── GraphQL/Filtering/UserFilterType.cs ───────────────────────────────────

// Customize which fields are filterable — don't expose all fields by default
// WHY security: allowing filter on password hash, internal flags = data leak risk
public class UserFilterType : FilterInputType<User>
{
    protected override void Configure(IFilterInputTypeDescriptor<User> descriptor)
    {
        // Whitelist approach — only allow filtering on these fields
        descriptor.Field(u => u.Name);
        descriptor.Field(u => u.Email);
        descriptor.Field(u => u.Age);
        descriptor.Field(u => u.CreatedAt);

        // Explicitly ignore sensitive/internal fields
        descriptor.Ignore(u => u.Orders); // prevent deep filter abuse (performance)
    }
}

// Registration:
// .AddGraphQLServer()
// .AddFiltering(x => x.AddDefaults().BindRuntimeType<User, UserFilterType>())
```

---

## 12. Error Handling — Domain + Field Errors

> **Mental Model:** REST uses HTTP status codes to signal errors. GraphQL always returns 200 OK — errors travel in the response body. There are two flavors: (1) field-level errors (expected domain errors like validation), (2) execution errors (unexpected exceptions).

```
┌─────────────────────────────────────────────────────────────────┐
│               GraphQL Error Taxonomy                             │
├──────────────────────────────┬──────────────────────────────────┤
│  Domain/Expected Errors      │  System/Unexpected Errors        │
├──────────────────────────────┼──────────────────────────────────┤
│ • Validation failures        │ • Database connection failure     │
│ • Entity not found           │ • Null reference exceptions       │
│ • Business rule violations   │ • Unhandled code paths            │
│ • Permission denied          │                                  │
├──────────────────────────────┼──────────────────────────────────┤
│ Return as payload errors:    │ Return as execution errors:       │
│ { errors: [{ field, code }]} │ { errors: [{ message, path }]}   │
│ HTTP 200                     │ HTTP 200 (but with errors array)  │
│ Partial data still returned  │ Field resolves to null            │
└──────────────────────────────┴──────────────────────────────────┘
```

### Global Error Filter

```csharp
// ── GraphQL/Errors/GlobalErrorFilter.cs ──────────────────────────────────

// IErrorFilter intercepts ALL GraphQL execution errors before they reach client
// WHY: Prevent stack traces / internal info leaking to clients (OWASP)
public class GlobalErrorFilter : IErrorFilter
{
    private readonly ILogger<GlobalErrorFilter> _logger;
    private readonly IWebHostEnvironment _env;

    public GlobalErrorFilter(ILogger<GlobalErrorFilter> logger, IWebHostEnvironment env)
    {
        _logger = logger;
        _env = env;
    }

    public IError OnError(IError error)
    {
        // Log ALL errors server-side (even ones we sanitize for client)
        _logger.LogError(error.Exception,
            "GraphQL error on path {Path}: {Message}",
            string.Join(".", error.Path ?? []),
            error.Message);

        // ── Known Domain Exceptions — expose to client ─────
        if (error.Exception is DomainException domainEx)
        {
            return error
                .WithMessage(domainEx.Message)     // safe to expose
                .WithCode(domainEx.ErrorCode)
                .RemoveException();                 // strip stack trace
        }

        // ── Unknown Exceptions — sanitize for production ───
        if (!_env.IsDevelopment())
        {
            // WHY: never expose exception details in production
            // Internal error detail = attacker reconnaissance
            return error
                .WithMessage("An internal error occurred. Please try again later.")
                .WithCode("INTERNAL_SERVER_ERROR")
                .RemoveException();                 // remove sensitive stack trace
        }

        // Development: return full details for debugging
        return error;
    }
}

// Registration:
// .AddGraphQLServer()
// .AddErrorFilter<GlobalErrorFilter>()
```

### Domain Exception

```csharp
// ── Domain/Exceptions/DomainException.cs ─────────────────────────────────

// Strongly-typed exceptions for expected business rule violations
// WHY: Catch-all Exception loses context; typed exceptions = explicit contract
public class DomainException(string message, string errorCode)
    : Exception(message)
{
    public string ErrorCode { get; } = errorCode;  // machine-readable for clients
}

// Domain-specific subtypes for clarity
public class EntityNotFoundException(string entityType, object id)
    : DomainException($"{entityType} with id '{id}' was not found", "NOT_FOUND");

public class BusinessRuleViolationException(string rule)
    : DomainException(rule, "BUSINESS_RULE_VIOLATION");
```

---

## 13. Testing GraphQL APIs

> **Mental Model:** GraphQL tests have two levels: (1) unit test resolvers in isolation (pure function tests), (2) integration tests that execute real GraphQL queries against an in-memory test server + real database via Testcontainers.

### Unit Testing Resolvers

```csharp
// ── Tests/Unit/UserResolverTests.cs ───────────────────────────────────────

public class UserResolverTests
{
    // Arrange: create in-memory EF context
    private AppDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()) // fresh DB per test
            .Options;
        return new AppDbContext(options);
    }

    [Fact]
    public async Task GetUser_ExistingId_ReturnsUser()
    {
        // ── Arrange ──────────────────────────────────────
        await using var db = CreateDbContext();
        db.Users.Add(new User { Id = 1, Name = "Alice", Email = "alice@test.com", CreatedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();

        var queryType = new QueryType();

        // ── Act ───────────────────────────────────────────
        var result = await queryType.GetUserAsync(1, db, CancellationToken.None);

        // ── Assert ────────────────────────────────────────
        result.Should().NotBeNull();
        result!.Name.Should().Be("Alice");
        result.Email.Should().Be("alice@test.com");
    }

    [Fact]
    public async Task GetUser_NonExistentId_ReturnsNull()
    {
        await using var db = CreateDbContext();
        var queryType = new QueryType();

        var result = await queryType.GetUserAsync(999, db, CancellationToken.None);

        result.Should().BeNull(); // GraphQL returns null for missing optional entities
    }
}
```

### Integration Testing with TestServer

```csharp
// ── Tests/Integration/GraphQLIntegrationTests.cs ──────────────────────────

// WHY integration tests: unit tests mock too much; we need to verify
// the full pipeline: parsing → validation → execution → serialization
public class GraphQLIntegrationTests : IAsyncLifetime
{
    private WebApplicationFactory<Program> _factory = null!;
    private HttpClient _client = null!;

    public Task InitializeAsync()
    {
        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    // Replace real DB with in-memory for tests
                    services.RemoveAll<DbContextOptions<AppDbContext>>();
                    services.AddDbContext<AppDbContext>(opt =>
                        opt.UseInMemoryDatabase("TestDb"));
                });
            });
        _client = _factory.CreateClient();
        return Task.CompletedTask;
    }

    public async Task DisposeAsync()
    {
        _client.Dispose();
        await _factory.DisposeAsync();
    }

    // ── Helper: Execute GraphQL Request ───────────────────
    private async Task<JsonDocument> ExecuteQueryAsync(
        string query,
        object? variables = null)
    {
        var request = new
        {
            query,
            variables = variables ?? new { }
        };

        var json = JsonSerializer.Serialize(request);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var response = await _client.PostAsync("/graphql", content);
        response.EnsureSuccessStatusCode();

        var responseJson = await response.Content.ReadAsStringAsync();
        return JsonDocument.Parse(responseJson);
    }

    [Fact]
    public async Task CreateUser_ValidInput_ReturnCreatedUser()
    {
        // ── Arrange ──────────────────────────────────────
        const string mutation = """
            mutation CreateUser($input: CreateUserInput!) {
              createUser(input: $input) {
                user {
                  id
                  name
                  email
                }
                errors {
                  message
                  code
                }
              }
            }
            """;

        // ── Act ───────────────────────────────────────────
        var result = await ExecuteQueryAsync(mutation, new
        {
            input = new { name = "Bob", email = "bob@test.com" }
        });

        // ── Assert ────────────────────────────────────────
        var user = result.RootElement
            .GetProperty("data")
            .GetProperty("createUser")
            .GetProperty("user");

        user.GetProperty("name").GetString().Should().Be("Bob");
        user.GetProperty("email").GetString().Should().Be("bob@test.com");
        user.GetProperty("id").GetString().Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task CreateUser_DuplicateEmail_ReturnsError()
    {
        // Seed existing user
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        db.Users.Add(new User { Name = "Alice", Email = "alice@test.com", CreatedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();

        const string mutation = """
            mutation { createUser(input: { name: "Alice2", email: "alice@test.com" }) {
              user { id }
              errors { message code }
            }}
            """;

        var result = await ExecuteQueryAsync(mutation);

        var errors = result.RootElement
            .GetProperty("data")
            .GetProperty("createUser")
            .GetProperty("errors");

        errors.GetArrayLength().Should().BeGreaterThan(0);
        errors[0].GetProperty("code").GetString().Should().Be("EMAIL_TAKEN");
    }
}
```

---

## 14. Performance Optimization

> **Mental Model:** GraphQL performance is about two things: (1) don't hit the database more than needed (DataLoader, projections), (2) don't do expensive work for anonymous/repeated requests (persisted queries, response caching).

### Query Complexity Limiting

```csharp
// ── Prevent expensive deeply nested queries (DDoS protection) ────────────

// WHY: Without limits, client can write: users { orders { items { user { orders { ... } } } } }
// Each nesting level multiplies DB queries exponentially

builder.Services
    .AddGraphQLServer()
    // Max depth of nested fields — prevents deeply nested abusive queries
    .AddMaxExecutionDepthRule(maxAllowedExecutionDepth: 10)
    // Complexity: assigns "cost" to each field; reject if total exceeds limit
    .AddDocumentValidatorPlugin(
        factory: sp => new QueryComplexityRule(maxComplexity: 500));
```

### Persisted Queries

```csharp
// ── Persisted Queries: security + caching ────────────────────────────────

// WHY: 
// 1. Security: only pre-approved queries can execute (no arbitrary queries from clients)
// 2. Performance: client sends query ID (small), not full query text (large)
// 3. Enables GET requests → CDN caching

builder.Services
    .AddGraphQLServer()
    .UsePersistedQueryPipeline()
    .AddFileSystemQueryStorage("./persisted-queries"); // store query files on disk

// Client sends: { "id": "GetUser", "variables": { "userId": "1" } }
// Instead of:  { "query": "query GetUser($userId: ID!) { user(id: $userId) { ... } }", "variables": ... }
```

### Response Caching

```csharp
// ── Field-Level Caching ───────────────────────────────────────────────────

[QueryType]
public class CachedQueryType
{
    // [CacheControl] marks this field's cache policy
    // WHY: public configs change rarely; cache them aggressively at CDN level
    [CacheControl(maxAge: 3600, scope: CacheControlScope.Public)] // 1 hour, CDN-cacheable
    public IQueryable<Country> GetCountries(AppDbContext db) =>
        db.Countries.AsNoTracking();

    // Per-user data — cache privately (browser only, not CDN)
    [CacheControl(maxAge: 60, scope: CacheControlScope.Private)] // 1 minute, user-scoped
    public async Task<User?> GetMeAsync(
        IHttpContextAccessor http, AppDbContext db, CancellationToken ct) =>
        await db.Users.FindAsync([GetCurrentUserId(http)], ct);

    private static int GetCurrentUserId(IHttpContextAccessor http) =>
        int.Parse(http.HttpContext!.User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
}
```

### EF Core Projections Deep Dive

```csharp
// ── Projection: only SELECT requested columns from DB ────────────────────

// Without projection — loads ENTIRE entity even if client only wants "name":
// SELECT id, name, email, age, created_at, internal_flags, ... FROM Users

// With [UseProjection] — translates GraphQL field selection to SQL SELECT:
// Client: { users { name } }
// SQL: SELECT name FROM Users

// IMPORTANT: Projections only work with IQueryable (not List/Array)
// WHY: IQueryable is lazy — EF builds the SQL based on what's actually needed

[QueryType]
public class OptimizedQueryType
{
    [UseProjection]
    [UseFiltering]
    [UseSorting]
    public IQueryable<User> GetUsers(AppDbContext db) =>
        // AsNoTracking: skip EF's change tracking overhead — we're only reading
        // WHY critical for GraphQL: GraphQL queries are always read-only at query level
        db.Users.AsNoTracking();

    // For non-IQueryable sources, manually project
    public async Task<IEnumerable<UserSummaryDto>> GetUserSummariesAsync(
        AppDbContext db, CancellationToken ct) =>
        await db.Users
            .AsNoTracking()
            // Manual projection to DTO — even without [UseProjection]
            .Select(u => new UserSummaryDto(u.Id, u.Name, u.Orders.Count))
            .ToListAsync(ct);
}

public record UserSummaryDto(int Id, string Name, int OrderCount);
```

---

## 15. Production Patterns

### Health Checks

```csharp
// ── Program.cs ────────────────────────────────────────────────────────────

builder.Services
    .AddHealthChecks()
    .AddDbContextCheck<AppDbContext>("database")    // EF Core health check
    .AddCheck("graphql", () => HealthCheckResult.Healthy("GraphQL running"));

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});
```

### Rate Limiting (protect against query abuse)

```csharp
// ── Program.cs ────────────────────────────────────────────────────────────

builder.Services.AddRateLimiter(opt =>
{
    // WHY sliding window for GraphQL: burst-friendly but prevents sustained abuse
    opt.AddSlidingWindowLimiter("graphql", policy =>
    {
        policy.Window = TimeSpan.FromMinutes(1);
        policy.SegmentsPerWindow = 6;         // 10-second segments
        policy.PermitLimit = 100;             // 100 requests per minute
        policy.QueueLimit = 0;                // no queuing — reject immediately when over limit
    });
});

app.UseRateLimiter();
app.MapGraphQL().RequireRateLimiting("graphql");
```

### Observability

```csharp
// ── Structured Logging in Resolvers ───────────────────────────────────────

[QueryType]
public class ObservableQueryType
{
    private readonly ILogger<ObservableQueryType> _logger;

    public ObservableQueryType(ILogger<ObservableQueryType> logger) =>
        _logger = logger;

    public async Task<User?> GetUserAsync(
        [ID] int id, AppDbContext db, CancellationToken ct)
    {
        // Structured log — queryable in Application Insights / ELK
        // WHY: "{UserId}" not $"{id}" — named parameter enables filtering in log tools
        _logger.LogInformation("Fetching user. UserId={UserId}", id);

        var user = await db.Users.FindAsync([id], ct);

        if (user is null)
            _logger.LogWarning("User not found. UserId={UserId}", id);

        return user;
    }
}
```

### OpenTelemetry Tracing

```csharp
// ── Program.cs ────────────────────────────────────────────────────────────

builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()         // trace HTTP requests
        .AddEntityFrameworkCoreInstrumentation() // trace EF queries
        .AddHotChocolateInstrumentation()        // trace GraphQL resolvers
        .AddAzureMonitorTraceExporter(opt =>     // ship to Application Insights
            opt.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"])
    );
```

---

## 16. Expert-Level Architecture

### Schema Stitching / Federation

```
┌──────────────────────────────────────────────────────────────────────┐
│              GraphQL Federation Architecture                          │
│                                                                      │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────────────┐       │
│  │ User Service│    │Order Service│    │ Product Service    │       │
│  │  /graphql   │    │  /graphql   │    │    /graphql        │       │
│  │             │    │             │    │                    │       │
│  │  type User  │    │ type Order  │    │  type Product      │       │
│  │  @key(id)   │    │ @key(id)    │    │  @key(id)          │       │
│  └──────┬──────┘    └──────┬──────┘    └──────┬─────────────┘       │
│         │                  │                  │                      │
│         └──────────────────┴──────────────────┘                      │
│                            │                                         │
│                   ┌────────▼────────┐                                │
│                   │   Gateway /     │                                │
│                   │   Supergraph    │  ← single endpoint for clients │
│                   │   /graphql      │                                │
│                   └─────────────────┘                                │
│                                                                      │
│  Client queries the gateway; gateway stitches responses from         │
│  multiple subgraphs transparently                                    │
└──────────────────────────────────────────────────────────────────────┘
```

```csharp
// ── Gateway Setup with Hot Chocolate Fusion ───────────────────────────────

// Gateway service Program.cs
builder.Services
    .AddGraphQLServer()
    .AddFusionGatewayServer()            // Hot Chocolate's federation gateway
    .ConfigureFromFile("./gateway.fgp"); // compiled supergraph config

// User subgraph — declares it owns User entity
[QueryType]
public class UserSubgraphQueries
{
    // [EntityResolver] marks this as a federated entity resolver
    // WHY: Other subgraphs can reference User by ID; gateway routes accordingly
    [EntityResolver]
    public async Task<User?> GetUserByIdAsync(
        [ID] int id, AppDbContext db, CancellationToken ct) =>
        await db.Users.FindAsync([id], ct);
}
```

### CQRS + GraphQL Integration

```csharp
// ── Thin GraphQL layer over MediatR CQRS ─────────────────────────────────

// WHY: GraphQL resolvers should delegate to application layer (CQRS commands/queries)
// Keeps GraphQL as a pure transport concern; business logic stays in handlers

[QueryType]
public class CqrsQueryType
{
    // IMediator dispatches to the correct query handler
    public async Task<UserDto?> GetUserAsync(
        [ID] int id,
        IMediator mediator,            // MediatR injected by Hot Chocolate
        CancellationToken ct) =>
        await mediator.Send(new GetUserByIdQuery(id), ct); // → UserQueryHandler

    [UsePaging]
    [UseFiltering]
    [UseSorting]
    public async Task<IQueryable<UserDto>> GetUsersAsync(
        IMediator mediator, CancellationToken ct) =>
        await mediator.Send(new GetUsersQuery(), ct);       // → UsersQueryHandler
}

[MutationType]
public class CqrsMutationType
{
    public async Task<CreateUserPayload> CreateUserAsync(
        CreateUserInput input,
        IMediator mediator,
        CancellationToken ct)
    {
        var result = await mediator.Send(
            new CreateUserCommand(input.Name, input.Email, input.Age), ct);

        // Map Result<T> to GraphQL payload
        return result.IsSuccess
            ? new CreateUserPayload(result.Value)
            : new CreateUserPayload(null, result.Errors.Select(e => new UserError(e.Message, e.Field, e.Code)).ToList());
    }
}
```

### Subscriptions with Outbox Pattern

```csharp
// ── Reliable event publishing via Outbox ──────────────────────────────────

// WHY outbox: if service crashes after DB write but before event publish,
// event is lost. Outbox pattern writes event to DB in same transaction.

public class OrderService(AppDbContext db, ITopicEventSender events)
{
    public async Task UpdateOrderStatusAsync(int orderId, OrderStatus newStatus, CancellationToken ct)
    {
        // Both DB update + outbox event in ONE transaction
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        try
        {
            var order = await db.Orders.FindAsync([orderId], ct)
                ?? throw new EntityNotFoundException("Order", orderId);
            order.Status = newStatus;

            // Write event to outbox table in same transaction
            // WHY same transaction: if commit fails, event is also rolled back
            db.OutboxEvents.Add(new OutboxEvent
            {
                EventType = "OrderStatusChanged",
                Payload = JsonSerializer.Serialize(order),
                CreatedAt = DateTime.UtcNow
            });

            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            // Publish to GraphQL subscriptions (best-effort after commit)
            // The outbox processor handles republishing if this fails
            await events.SendAsync(orderId.ToString(), order, ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }
    }
}
```

---

## 17. Quick Reference Cheat Sheet

### SDL Type Modifiers

```
String      → nullable string (can be null)
String!     → required string (never null)
[String]    → nullable list, items nullable
[String!]   → nullable list, items required
[String]!   → required list, items nullable
[String!]!  → required list, items required
```

### Hot Chocolate Attribute Reference

| Attribute | Purpose | Where Used |
|-----------|---------|------------|
| `[QueryType]` | Root query class | Class |
| `[MutationType]` | Root mutation class | Class |
| `[SubscriptionType]` | Root subscription class | Class |
| `[ExtendObjectType<T>]` | Add fields to existing type | Class |
| `[Subscribe]` | Mark subscription event handler | Method |
| `[Topic("...")]` | Pub/sub channel name | Method |
| `[EventMessage]` | Inject subscription payload | Parameter |
| `[Parent]` | Inject parent resolved object | Parameter |
| `[ID]` | Map int → GraphQL ID scalar | Parameter/Property |
| `[UseProjection]` | Enable column projection | Method |
| `[UseFiltering]` | Enable `where` argument | Method |
| `[UseSorting]` | Enable `order` argument | Method |
| `[UsePaging]` | Enable cursor pagination | Method |
| `[Authorize]` | Require authentication | Method/Class |
| `[GraphQLName("...")]` | Override field name in schema | Method/Property |
| `[GraphQLIgnore]` | Hide field from schema | Property |
| `[GraphQLDescription("...")]` | Add documentation | Method/Property |

### Resolver Parameter Injection

```csharp
// Hot Chocolate auto-injects these parameter types:
Task<User?> GetUserAsync(
    [ID] int id,                    // from GraphQL argument
    [Parent] Order order,           // parent resolved object
    AppDbContext db,                // from DI container
    IMediator mediator,             // from DI container
    IResolverContext context,       // full resolver context
    ITopicEventSender sender,       // subscription publisher
    MyDataLoader loader,            // auto-batched DataLoader
    CancellationToken ct            // request cancellation
)
```

### Common GraphQL Errors and Solutions

| Error | Cause | Fix |
|-------|-------|-----|
| `Cannot return null for non-null field` | Resolver returned null for `!` field | Make field nullable OR fix resolver |
| `N+1 queries detected` | Loading related data in resolver loop | Use DataLoader |
| `Field not found in schema` | Typo or unregistered type | Check `.AddTypes()` / type registration |
| `Argument X of type Y not found` | Input type not registered | Add `[MutationType]` or `.AddInputObjectType<T>()` |
| `Subscription not receiving events` | Topic name mismatch | Check `[Topic]` matches `eventSender.SendAsync(topic)` |
| `Auth challenge not returned` | Missing `.UseAuthentication()` | Add before `.MapGraphQL()` |
| `Circular reference in schema` | Type A references B references A | Use `[GraphQLIgnore]` on one navigation |

### Operation Types Comparison

```
┌────────────────┬────────────────┬──────────────────┬─────────────────┐
│                │ Query          │ Mutation         │ Subscription    │
├────────────────┼────────────────┼──────────────────┼─────────────────┤
│ REST analog    │ GET            │ POST/PUT/DELETE  │ WebSocket/SSE   │
│ HTTP method    │ GET or POST    │ POST             │ WebSocket       │
│ Execution      │ Parallel       │ Sequential       │ Stream          │
│ Idempotent?    │ Yes            │ No               │ N/A             │
│ Cacheable?     │ Yes (APQ/GET)  │ No               │ No              │
│ Use case       │ Read data      │ Write data       │ Live updates    │
└────────────────┴────────────────┴──────────────────┴─────────────────┘
```

---

## Key Production Checklist

```
┌─────────────────────────────────────────────────────────────────────┐
│                  GraphQL Production Readiness                        │
├─────────────────────────────────────────────────────────────────────┤
│ Security                                                            │
│  ☐ Query depth limiting enabled                                     │
│  ☐ Query complexity limiting enabled                                │
│  ☐ Persisted queries (no arbitrary query execution in prod)         │
│  ☐ Rate limiting on /graphql endpoint                               │
│  ☐ Error messages sanitized (no stack traces in prod)               │
│  ☐ Authorization on all sensitive fields/types                      │
│  ☐ Input validation on all mutations                                │
│                                                                     │
│ Performance                                                         │
│  ☐ DataLoaders for all N+1-prone relationships                      │
│  ☐ [UseProjection] on all IQueryable resolvers                      │
│  ☐ AsNoTracking() on read-only queries                              │
│  ☐ Redis subscriptions (not in-memory) for multi-instance           │
│  ☐ Response caching configured for static data                      │
│                                                                     │
│ Observability                                                       │
│  ☐ OpenTelemetry tracing enabled                                    │
│  ☐ Structured logging in all resolvers                              │
│  ☐ Health check endpoint responding                                 │
│  ☐ Slow query detection configured                                  │
│                                                                     │
│ Operations                                                          │
│  ☐ Schema introspection disabled in production                      │
│  ☐ GraphiQL / Banana Cake Pop disabled in production                │
│  ☐ Schema versioning strategy documented                            │
│  ☐ Deprecation notices on removed fields (not breaking changes)     │
└─────────────────────────────────────────────────────────────────────┘
```

---

*Guide covers: Hot Chocolate 14+, .NET 8/10, EF Core 9, ASP.NET Core 10 Minimal APIs*
