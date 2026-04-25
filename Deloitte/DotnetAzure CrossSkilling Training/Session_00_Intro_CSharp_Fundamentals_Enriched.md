# Session 00 — Intro: C# & .NET Fundamentals

**Duration:** 60 minutes
**Audience:** Developers from Java, Python, JavaScript, or non-programming backgrounds
**Goal:** By the end, you can read and understand C# code and feel comfortable in the upcoming sessions.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | What is .NET? Where does it run? |
| 5–15 min | dotnet CLI + Project Structure |
| 15–28 min | C# Language Basics |
| 28–40 min | Classes, Interfaces, and Dependency Inversion |
| 40–50 min | Async/Await — The Mental Model |
| 50–57 min | Null Safety, Exception Handling & Modern Shortcuts |
| 57–60 min | Key Takeaways + Q&A |

---

## 1. What is .NET? (0–5 min)

### Mental Model
> Think of .NET as the **engine under the hood**. C# is the steering wheel you use to drive it. The engine handles memory, threads, garbage collection — you just write C# and .NET takes care of the rest.

```
┌─────────────────────────────────────────────────────────┐
│                      Your C# Code                       │
├─────────────────────────────────────────────────────────┤
│              .NET Runtime (CLR / CoreCLR)               │
│   Memory Management │ Threading │ GC │ Type System      │
├─────────────────────────────────────────────────────────┤
│              Operating System (Windows/Linux/Mac)        │
└─────────────────────────────────────────────────────────┘
```

**.NET runs everywhere:**

| Area | Technology |
|------|-----------|
| Web APIs | ASP.NET Core |
| Cloud functions | Azure Functions |
| Background services | Worker Services |
| Desktop | WPF / MAUI |
| Mobile | .NET MAUI |

**Current version:** .NET 8 (LTS) / .NET 9 (latest)

---

## 2. dotnet CLI + Project Structure (5–15 min)

### Mental Model
> The `dotnet` CLI is your **Swiss Army knife**. You create, build, run, test, and publish apps entirely from the command line — no IDE required.

### Essential Commands

```bash
# ── Create a new project ──────────────────────────────────
dotnet new webapi -n MyApi          # ASP.NET Core Web API
dotnet new console -n MyApp         # Console app
dotnet new classlib -n MyLibrary    # Class library (shared code)
dotnet new xunit -n MyTests         # xUnit test project

# ── Build and run ─────────────────────────────────────────
dotnet build                        # compile — check for errors
dotnet run                          # build + run
dotnet watch run                    # run + auto-restart on file save (hot reload)

# ── Dependencies (NuGet packages) ────────────────────────
dotnet add package Newtonsoft.Json  # install a package
dotnet restore                      # restore all packages from .csproj

# ── Tests ─────────────────────────────────────────────────
dotnet test                         # run all tests

# ── Publish (for deployment) ──────────────────────────────
dotnet publish -c Release -o ./out  # optimized build ready to deploy
```

### Solution & Project Structure

```
MySolution/                         ← solution folder
├── MySolution.sln                  ← solution file (groups all projects)
├── MyApi/                          ← Web API project
│   ├── MyApi.csproj                ← project file (dependencies, target framework)
│   ├── Program.cs                  ← entry point
│   ├── appsettings.json            ← configuration
│   └── Endpoints/                  ← your code
├── MyApi.Application/              ← use cases / business logic project
│   └── MyApi.Application.csproj
├── MyApi.Domain/                   ← entities / domain rules
│   └── MyApi.Domain.csproj
└── MyApi.Tests/                    ← test project
    └── MyApi.Tests.csproj
```

```bash
# Create a solution and add projects to it
dotnet new sln -n MySolution
dotnet sln add MyApi/MyApi.csproj
dotnet sln add MyApi.Application/MyApi.Application.csproj

# Add a project reference (MyApi depends on MyApi.Application)
dotnet add MyApi/MyApi.csproj reference MyApi.Application/MyApi.Application.csproj
```

### The .csproj File

```xml
<!-- MyApi.csproj — project configuration -->
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>    <!-- .NET version -->
    <Nullable>enable</Nullable>                  <!-- null safety on -->
    <ImplicitUsings>enable</ImplicitUsings>      <!-- auto-imports common namespaces -->
  </PropertyGroup>

  <ItemGroup>
    <!-- NuGet package references -->
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>
</Project>
```

---

## 3. C# Language Basics (15–28 min)

### Variables and Types

```csharp
// Value types — stored on the stack, copied when assigned
int age = 30;
bool isActive = true;
double price = 99.99;
decimal money = 99.99m;   // use decimal for money — avoids floating-point errors

// Reference types — stored on the heap, reference is copied
string name = "Alice";
int[] scores = { 10, 20, 30 };

// var — compiler infers the type (still strongly typed, not dynamic)
var city = "London";     // inferred as string
var count = 42;          // inferred as int
```

### String Interpolation

```csharp
string firstName = "Alice";
int age = 30;

string msg = $"Hello {firstName}, age {age}";       // preferred
string upper = $"Name: {firstName.ToUpper()}";      // expressions work too
string padded = $"Total: {99.99m:C}";               // format specifiers work too
```

### Collections

```csharp
// List<T> — growable array
var names = new List<string> { "Alice", "Bob", "Carol" };
names.Add("Dave");
names.Remove("Bob");
int count = names.Count;       // not .Length — that's arrays

// Dictionary<TKey, TValue> — key/value store
var scores = new Dictionary<string, int>
{
    ["Alice"] = 95,
    ["Bob"] = 87
};
scores["Carol"] = 91;                                 // add or update
bool exists = scores.TryGetValue("Dave", out int val); // safe read
```

### Control Flow

```csharp
// if/else
if (age >= 18) { Console.WriteLine("Adult"); }
else           { Console.WriteLine("Minor"); }

// foreach — preferred over for when iterating
foreach (var name in names)
    Console.WriteLine(name);

// switch expression (modern C# — clean one-liner)
string label = age switch
{
    < 18 => "Minor",
    < 65 => "Adult",
    _    => "Senior"   // _ is the default (catch-all)
};
```

---

## 4. Classes, Interfaces, and Dependency Inversion (28–40 min)

### Mental Model
> A **class** is a blueprint. An **interface** is a contract. When you code to an interface, you can swap the blueprint anytime — like plugging a different USB device into the same port.

### Class Basics

```csharp
public class Order
{
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public decimal Total { get; private set; }

    public Order(int id, string customerName)
    {
        Id = id;
        CustomerName = customerName;
    }

    public void AddItem(decimal itemPrice)
    {
        Total += itemPrice;
    }
}

var order = new Order(1, "Alice");
order.AddItem(29.99m);
Console.WriteLine($"Order #{order.Id} total: {order.Total}");
```

### Record Types (Preferred for Data Transfer)

```csharp
// record — immutable, value-equality, one-liner declaration
// WHY: DTOs should never be mutated after creation — records enforce this
public record CustomerDto(int Id, string Name, string Email);

var customer = new CustomerDto(1, "Alice", "alice@example.com");
var updated  = customer with { Email = "newalice@example.com" }; // new copy, original unchanged
```

### Interface — The Contract

```csharp
public interface IEmailService
{
    Task SendAsync(string to, string subject, string body);
}

// Real implementation
public class SmtpEmailService : IEmailService
{
    public async Task SendAsync(string to, string subject, string body)
    {
        await Task.Delay(100); // simulate SMTP
        Console.WriteLine($"Email sent to {to}");
    }
}

// Fake for testing
public class FakeEmailService : IEmailService
{
    public Task SendAsync(string to, string subject, string body)
    {
        Console.WriteLine($"[FAKE] Would send to {to}");
        return Task.CompletedTask;
    }
}

// Consumer depends on interface — not the concrete class
// WHY: swap SmtpEmailService ↔ FakeEmailService with zero changes here
public class OrderService
{
    private readonly IEmailService _emailService;
    public OrderService(IEmailService emailService) => _emailService = emailService;

    public async Task PlaceOrderAsync(Order order)
    {
        await _emailService.SendAsync(order.CustomerName, "Order Confirmed", "Your order is placed.");
    }
}
```

---

## 5. Async/Await — The Mental Model (40–50 min)

### Mental Model
> Think of a waiter at a restaurant. When he takes your order to the kitchen, he **doesn't stand there waiting** — he goes and serves other tables. When the food is ready, he comes back. That's `async/await`: the thread doesn't block, it goes off and does other work.

```
Without async (blocking):
Thread 1: [Request]────────────[Waiting for DB]──────────[Response]
                    ↑ thread is blocked, can't serve anyone else

With async/await:
Thread 1: [Request]──[Awaits DB]────────────────────[Response]
                              ↑ thread is free to handle other requests
```

### The Pattern

```csharp
// Async method returns Task or Task<T>
public async Task<string> GetUserNameAsync(int userId)
{
    var user = await _dbContext.Users.FindAsync(userId); // releases thread here
    return user?.Name ?? "Unknown";
}

// Always await — never .Result or .Wait()
public async Task PrintUserAsync()
{
    string name = await GetUserNameAsync(42);
    Console.WriteLine($"User: {name}");
}
```

### Rules

| Rule | Why |
|------|-----|
| If a method does I/O, make it `async Task` | I/O always involves waiting |
| Always `await` — never `.Result` or `.Wait()` | `.Result` blocks the thread and can deadlock |
| `async void` only for event handlers | Exceptions in `async void` are swallowed silently |
| Suffix async methods with `Async` | Convention — makes code readable |

---

## 6. Exception Handling, Null Safety & Modern Shortcuts (50–57 min)

### Exception Handling — try/catch/finally

```csharp
// ── Basic structure ────────────────────────────────────────
try
{
    var order = await _orderService.GetByIdAsync(id);
    order.Confirm();
}
catch (NotFoundException ex)
{
    // Catch specific exception types first (most specific → most general)
    Console.WriteLine($"Not found: {ex.Message}");
}
catch (Exception ex)
{
    // Catch-all — log and rethrow or handle gracefully
    _logger.LogError(ex, "Unexpected error");
    throw;  // rethrow preserves the original stack trace
}
finally
{
    // Always runs — use for cleanup (close connections, release resources)
    // In modern C# with 'using', you rarely need finally for resource cleanup
}

// ── using — auto-disposes at end of scope ─────────────────
// WHY: replaces try/finally for disposable resources
await using var connection = new SqlConnection(connectionString);
await connection.OpenAsync();
// connection.Dispose() called automatically when scope ends
```

### Nullable Reference Types

```csharp
string name = "Alice";    // cannot be null — compiler enforces this
string? nickname = null;  // ? means "this CAN be null"

int? length = nickname?.Length;       // null-conditional: null if nickname is null
string display = nickname ?? "None";  // null-coalescing: default if null
nickname ??= "Default";               // assign only if currently null
```

### Expression-Bodied Members

```csharp
// Long form
public string GetGreeting(string name)
{
    return $"Hello, {name}";
}

// Short form — for single-expression methods
public string GetGreeting(string name) => $"Hello, {name}";
```

### LINQ Preview (Deep dive — Day 5)

```csharp
var orders = new List<Order> { /* ... */ };

var highValueOrders = orders
    .Where(o => o.Total > 100)
    .OrderByDescending(o => o.Total)
    .Select(o => new { o.Id, o.Total })
    .ToList();
```

---

## Azure Integration

> **For the Azure-focused audience** — this section shows where .NET skills connect directly to Azure. The concepts above are the foundation for everything Azure in Sessions 1–7.

### Where .NET Runs in Azure

```
┌──────────────────────────────────────────────────────────────────┐
│  .NET Skill             │  Azure Service It Powers               │
├──────────────────────────────────────────────────────────────────┤
│  ASP.NET Core Web API   │  Azure App Service / AKS               │
│  BackgroundService      │  Azure Container Apps / AKS Jobs       │
│  Azure Functions SDK    │  Azure Functions                       │
│  EF Core                │  Azure SQL / Cosmos DB                 │
│  ILogger + App Insights │  Azure Monitor / Application Insights  │
└──────────────────────────────────────────────────────────────────┘
```

### dotnet publish → Azure Deployment

```bash
# Publish a self-contained release build
dotnet publish -c Release -r linux-x64 --self-contained -o ./publish

# This output folder is what you deploy to Azure App Service or
# package into a Docker image for AKS / Container Apps
```

### NuGet Packages Used Across Azure Sessions

```bash
# You'll add these in upcoming sessions — preview them here
dotnet add package Azure.Identity                                # Managed Identity auth
dotnet add package Azure.Extensions.AspNetCore.Configuration.Secrets  # Key Vault config
dotnet add package Microsoft.ApplicationInsights.AspNetCore     # App Insights telemetry
dotnet add package Microsoft.EntityFrameworkCore.SqlServer       # Azure SQL via EF Core
dotnet add package Azure.Messaging.ServiceBus                    # Service Bus messaging
```

---

## Key Takeaways

1. **.NET is the runtime** — C# is the language. You write C#; .NET runs it anywhere (Windows, Linux, containers, Azure).
2. **`dotnet` CLI is your main tool** — create, build, run, test, publish without an IDE.
3. **Interfaces are contracts** — always code to an interface, not a concrete class.
4. **Records for data** — use `record` for DTOs; they are immutable and self-documenting.
5. **Async/await = non-blocking I/O** — never use `.Result` or `.Wait()`; always `await`.

---

## Q&A Prompts

**1. What's the difference between `var` and `dynamic` in C#?**

**Answer:** `var` is still statically typed — the compiler infers the type at compile time, so you get full IntelliSense and compile-time errors. `dynamic` bypasses compile-time checks entirely; type resolution happens at runtime. You almost never use `dynamic` in normal application code — it's mainly for interop with COM or dynamic languages.

---

**2. Why would you use an interface instead of just inheriting from a base class?**

**Answer:** C# only allows single inheritance (a class can have one base class), but a class can implement many interfaces. Interfaces also don't force an implementation hierarchy — `SmtpEmailService` and `SendGridEmailService` can both implement `IEmailService` without being related classes. More importantly, interfaces make testing easy: you inject a fake implementation without changing the consumer at all.

---

**3. What happens if you call an async method without `await`?**

**Answer:** The method starts but the calling code doesn't wait for it to finish. You get a "fire and forget" — the returned `Task` is discarded, exceptions are swallowed silently, and you get a compiler warning. Always `await` unless you explicitly intend fire-and-forget (and even then, store the `Task` and handle exceptions).

---

**4. What does `record` give you that a regular `class` doesn't?**

**Answer:** Three things automatically: (1) **Value equality** — two records with the same property values are equal (`==`), unlike classes which compare by reference. (2) **Immutability** — properties are `init`-only by default. (3) **`with` expressions** — create a modified copy without mutating the original. Records also generate a readable `ToString()` for free.

---

## What's Next — Day 1

Now that you can read C# code, next session we'll look at **how a modern .NET application is structured** — Clean Architecture layers, REST API principles, and how Azure services map to each layer.
