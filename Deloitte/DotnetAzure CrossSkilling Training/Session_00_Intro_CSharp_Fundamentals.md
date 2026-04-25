# Session 00 — Intro: C# & .NET Fundamentals

**Duration:** 60 minutes
**Audience:** Developers from Java, Python, JavaScript, or non-programming backgrounds
**Goal:** By the end, you can read and understand C# code and feel comfortable in the upcoming sessions.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | What is .NET? Where does it run? |
| 5–20 min | C# Language Basics |
| 20–40 min | Classes, OOP Pillars, Interfaces, and Dependency Inversion |
| 40–50 min | Async/Await — The Mental Model |
| 50–58 min | Null Safety & Modern C# Shortcuts |
| 58–60 min | Key Takeaways + Q&A |

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
- Web APIs → ASP.NET Core
- Cloud functions → Azure Functions
- Background services → Worker Services
- Desktop → WPF / MAUI
- Mobile → MAUI

**Current version:** .NET 8 (LTS) / .NET 9+ in active development

---

## 2. C# Language Basics (5–20 min)

### Variables and Types

```csharp
// Value types — stored on the stack, copied when assigned
int age = 30;
bool isActive = true;
double price = 99.99;

// Reference types — stored on the heap, reference is copied
string name = "Alice";
int[] scores = { 10, 20, 30 };

// var — compiler infers the type for you (still strongly typed)
var city = "London";     // inferred as string
var count = 42;          // inferred as int
```

### String Interpolation (use this everywhere)

```csharp
string firstName = "Alice";
int age = 30;

// Old way — messy
string msg1 = "Hello " + firstName + ", age " + age;

// Modern way — use $ prefix
string msg2 = $"Hello {firstName}, age {age}";
```

### Collections

```csharp
// List<T> — growable array
var names = new List<string> { "Alice", "Bob", "Carol" };
names.Add("Dave");

// Dictionary<TKey, TValue> — key/value store
var scores = new Dictionary<string, int>
{
    ["Alice"] = 95,
    ["Bob"] = 87
};

int aliceScore = scores["Alice"]; // 95
```

### Control Flow — Same as Java/JavaScript

```csharp
// if/else
if (age >= 18)
{
    Console.WriteLine("Adult");
}
else
{
    Console.WriteLine("Minor");
}

// foreach — preferred over for when iterating
foreach (var name in names)
{
    Console.WriteLine(name);
}

// switch expression (modern C# — much cleaner)
string label = age switch
{
    < 18 => "Minor",
    < 65 => "Adult",
    _    => "Senior"   // _ is the default case
};
```

---

## 3. Classes, OOP Pillars, Interfaces, and Dependency Inversion (20–40 min)

### Mental Model
> A **class** is a blueprint. An **interface** is a contract. When you code to an interface, you can swap the blueprint anytime — like plugging a different USB device into the same port.

### Class Basics

```csharp
// ── Class Definition ────────────────────────────────────
public class Order
{
    // Properties — public data with get/set
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public decimal Total { get; private set; }  // only settable inside the class

    // Constructor
    public Order(int id, string customerName)
    {
        Id = id;
        CustomerName = customerName;
    }

    // Method
    public void AddItem(decimal itemPrice)
    {
        Total += itemPrice;
    }
}

// Usage
var order = new Order(1, "Alice");
order.AddItem(29.99m);
Console.WriteLine($"Order #{order.Id} total: {order.Total}");
```

### Record Types (Preferred for Data)

```csharp
// record — immutable by default, value equality built-in
// WHY: DTOs should never be mutated after creation — records enforce this
public record CustomerDto(int Id, string Name, string Email);

var customer = new CustomerDto(1, "Alice", "alice@example.com");

// Create a modified copy with 'with' expression
var updated = customer with { Email = "newalice@example.com" };
```

### The 4 Pillars of OOP

```
┌──────────────────┬───────────────────────────────────────────────────────┐
│  Pillar          │  What It Means                                        │
├──────────────────┼───────────────────────────────────────────────────────┤
│  Encapsulation   │  Hide internal details; expose only what's needed     │
│  Inheritance     │  A class reuses behavior from a parent class          │
│  Polymorphism    │  Same call, different behavior depending on the type  │
│  Abstraction     │  Define what to do without specifying how             │
└──────────────────┴───────────────────────────────────────────────────────┘
```

### Access Specifiers — Who Can See What

> **Mental Model:** Access specifiers are **room keys in a building**. `public` is the lobby — anyone can enter. `private` is your personal office — only you. `protected` is a family home — you and your children. `internal` is the company floor — anyone in the same building (assembly).

```
┌───────────────────────┬────────┬───────────┬──────────┬──────────────┐
│  Specifier            │ Same   │ Derived   │ Same     │ Other        │
│                       │ Class  │ Class     │ Assembly │ Assemblies   │
├───────────────────────┼────────┼───────────┼──────────┼──────────────┤
│  public               │  ✓     │  ✓        │  ✓       │  ✓           │
│  private              │  ✓     │  ✗        │  ✗       │  ✗           │
│  protected            │  ✓     │  ✓        │  ✗       │  ✗           │
│  internal             │  ✓     │  ✓        │  ✓       │  ✗           │
│  protected internal   │  ✓     │  ✓        │  ✓       │  ✗ (derived) │
│  private protected    │  ✓     │  ✓ (same  │  ✗       │  ✗           │
│                       │        │  assembly)│          │              │
└───────────────────────┴────────┴───────────┴──────────┴──────────────┘
```

```csharp
public class Employee
{
    // public — accessible everywhere
    public string Name { get; set; } = string.Empty;

    // private — only accessible inside this class
    private decimal _salary;

    // protected — accessible here and in derived classes
    protected string Department { get; set; } = string.Empty;

    // internal — accessible anywhere in the same project (assembly)
    internal int EmployeeCode { get; set; }

    // private protected — derived classes in the same assembly only
    private protected string InternalGrade { get; set; } = string.Empty;

    public Employee(string name, decimal salary)
    {
        Name = name;
        _salary = salary;  // only this class sets salary directly
    }

    // WHY: expose a controlled read — no external code can change salary directly
    public decimal GetSalary() => _salary;

    // WHY: raise is business logic — salary can only change through this method
    public void ApplyRaise(decimal percent)
    {
        if (percent <= 0) throw new ArgumentException("Percent must be positive");
        _salary += _salary * (percent / 100);
    }
}

public class Manager : Employee
{
    public Manager(string name, decimal salary) : base(name, salary) { }

    public void SetDepartment(string dept)
    {
        Department = dept;   // ✓ allowed — protected, and Manager is derived
        // _salary = 9999;   // ✗ compile error — private to Employee
    }
}
```

**Default access when you don't specify:**

```
┌──────────────────────┬──────────────────────────────────────────┐
│  Context             │  Default access                          │
├──────────────────────┼──────────────────────────────────────────┤
│  Class members       │  private                                 │
│  Top-level classes   │  internal                                │
│  Interface members   │  public (interfaces are public by def.)  │
└──────────────────────┴──────────────────────────────────────────┘
```

---

### Encapsulation — Hide the Internals

> **Mental Model:** A bank account exposes `Deposit()` and `Withdraw()` buttons. It does NOT let you directly edit the balance field — that would break the rules. Encapsulation protects the object's state.

```csharp
public class BankAccount
{
    // WHY: private — no one outside this class can set balance directly
    private decimal _balance;

    public decimal Balance => _balance;  // read-only property — get only

    public string Owner { get; }         // init-only after construction

    public BankAccount(string owner, decimal initialBalance)
    {
        Owner = owner;
        _balance = initialBalance;
    }

    public void Deposit(decimal amount)
    {
        if (amount <= 0) throw new ArgumentException("Amount must be positive");
        _balance += amount;
    }

    public void Withdraw(decimal amount)
    {
        if (amount > _balance) throw new InvalidOperationException("Insufficient funds");
        _balance -= amount;
    }
}

// Usage
var account = new BankAccount("Alice", 1000m);
account.Deposit(500m);
// account._balance = 9999;  ← compile error — field is private
Console.WriteLine(account.Balance);  // 1500
```

### Inheritance — Reuse Behavior from a Parent

> **Mental Model:** A `Dog` is an `Animal`. It inherits everything an animal can do (breathe, move) and adds its own behavior (bark). You don't rewrite breathing — you inherit it.

```csharp
// ── Base class ────────────────────────────────────────────
public class Animal
{
    public string Name { get; }

    public Animal(string name) => Name = name;

    // virtual — allows derived classes to override this
    public virtual string Speak() => "...";

    public void Breathe() => Console.WriteLine($"{Name} is breathing");
}

// ── Derived class — inherits Animal, overrides Speak ──────
public class Dog : Animal
{
    public Dog(string name) : base(name) { }  // calls parent constructor

    public override string Speak() => "Woof!";

    public void Fetch() => Console.WriteLine($"{Name} fetches the ball");
}

public class Cat : Animal
{
    public Cat(string name) : base(name) { }

    public override string Speak() => "Meow!";
}

// Usage
var dog = new Dog("Rex");
dog.Breathe();            // inherited from Animal
Console.WriteLine(dog.Speak());  // "Woof!" — overridden
dog.Fetch();              // Dog-specific
```

**sealed** — prevents further inheritance:

```csharp
// WHY: sealed prevents misuse — no one should extend this utility class
public sealed class MathHelper
{
    public static double CircleArea(double radius) => Math.PI * radius * radius;
}
```

### Polymorphism — Same Call, Different Behavior

> **Mental Model:** You tell every shape to `Draw()`. A circle draws a circle, a square draws a square. You don't write separate `DrawCircle()` and `DrawSquare()` calls — you call the same method and let each type handle it.

```csharp
// ── Runtime polymorphism — decided at runtime based on actual type ──
Animal[] animals = { new Dog("Rex"), new Cat("Whiskers"), new Dog("Buddy") };

foreach (var animal in animals)
{
    // WHY: the same Speak() call produces different output per type
    Console.WriteLine($"{animal.Name} says: {animal.Speak()}");
}
// Output:
// Rex says: Woof!
// Whiskers says: Meow!
// Buddy says: Woof!
```

```csharp
// ── Compile-time polymorphism — method overloading ────────
public class Calculator
{
    // Same method name, different parameter types
    public int Add(int a, int b) => a + b;
    public double Add(double a, double b) => a + b;
    public string Add(string a, string b) => a + b;   // concatenation
}

var calc = new Calculator();
calc.Add(1, 2);           // calls int version
calc.Add(1.5, 2.5);       // calls double version
calc.Add("Hello", " World"); // calls string version
```

### Abstraction — Define What, Not How

> **Mental Model:** A TV remote defines buttons (Power, Volume, Channel). You know WHAT each button does. You don't know HOW the TV implements them internally. Abstraction hides implementation detail behind a clean interface.

```csharp
// ── Abstract class — partial implementation, forces derived classes to complete it ──
public abstract class Shape
{
    public string Color { get; set; } = "White";

    // abstract — must be implemented by every derived class
    public abstract double Area();

    // concrete — shared behavior all shapes get
    public void Describe() => Console.WriteLine($"{Color} shape with area {Area():F2}");
}

public class Circle : Shape
{
    public double Radius { get; }
    public Circle(double radius) => Radius = radius;

    public override double Area() => Math.PI * Radius * Radius;
}

public class Rectangle : Shape
{
    public double Width { get; }
    public double Height { get; }
    public Rectangle(double w, double h) { Width = w; Height = h; }

    public override double Area() => Width * Height;
}

// Usage
Shape[] shapes = { new Circle(5), new Rectangle(4, 6) };
foreach (var s in shapes)
    s.Describe();   // each shape knows its own Area()
```

**Abstract class vs Interface — when to use which:**

```
┌───────────────────────┬──────────────────────────────────────────────────┐
│  Abstract Class       │  Interface                                       │
├───────────────────────┼──────────────────────────────────────────────────┤
│  Can have fields      │  No fields (only properties/methods/events)      │
│  Can have constructor │  No constructor                                  │
│  Single inheritance   │  A class can implement many interfaces           │
│  IS-A relationship    │  CAN-DO relationship                             │
│                       │                                                  │
│  Use when: shared     │  Use when: defining a capability contract        │
│  base behavior +      │  e.g., IDisposable, ILogger, IEmailService       │
│  some force-override  │                                                  │
└───────────────────────┴──────────────────────────────────────────────────┘
```

---

### Interface — The Contract

```csharp
// Define the contract
public interface IEmailService
{
    Task SendAsync(string to, string subject, string body);
}

// Real implementation
public class SmtpEmailService : IEmailService
{
    public async Task SendAsync(string to, string subject, string body)
    {
        // actual SMTP logic
        await Task.Delay(100); // simulate async send
        Console.WriteLine($"Email sent to {to}");
    }
}

// Fake implementation for testing
public class FakeEmailService : IEmailService
{
    public Task SendAsync(string to, string subject, string body)
    {
        Console.WriteLine($"[FAKE] Would send to {to}");
        return Task.CompletedTask;
    }
}

// Consumer — depends on interface, not the concrete class
// WHY: swapping SmtpEmailService → FakeEmailService requires zero code changes here
public class OrderService
{
    private readonly IEmailService _emailService;

    public OrderService(IEmailService emailService)  // injected from outside
    {
        _emailService = emailService;
    }

    public async Task PlaceOrderAsync(Order order)
    {
        // ... process order ...
        await _emailService.SendAsync(order.CustomerName, "Order Confirmed", "Your order is placed.");
    }
}
```

**Key rule:** Always depend on the interface (`IEmailService`), never the concrete class (`SmtpEmailService`).

---

## 4. Async/Await — The Mental Model (35–45 min)

### Mental Model
> Think of a waiter at a restaurant. When he takes your order to the kitchen, he **doesn't stand there waiting** — he goes and serves other tables. When the food is ready, he comes back. That's `async/await`: the thread doesn't block, it goes off and does other work.

### Why It Matters

```
Without async (blocking):
Thread 1: [Request]──────────────[Waiting for DB]──────────[Response]
                     ↑ thread is blocked, can't serve anyone else

With async/await:
Thread 1: [Request]──[Awaits DB]──────────────────────[Response]
                              ↑ thread is free to handle other requests
```

### The Pattern

```csharp
// ── Async method always returns Task or Task<T> ──────────
public async Task<string> GetUserNameAsync(int userId)
{
    // await releases the thread while DB query runs
    var user = await _dbContext.Users.FindAsync(userId);

    if (user == null)
        return "Unknown";

    return user.Name;
}

// Calling it — always await async methods
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
| `async void` only for event handlers | Exceptions in `async void` are swallowed |
| Suffix async methods with `Async` | Convention — makes code readable |

---

## 5. Null Safety & Modern Shortcuts (45–55 min)

### Nullable Reference Types

```csharp
// With nullable reference types enabled (default in new projects):
string name = "Alice";   // cannot be null — compiler enforces this
string? nickname = null; // the ? means "this CAN be null"

// Safe access with null-conditional operator ?.
int? length = nickname?.Length;  // null if nickname is null, not an exception

// Null-coalescing — provide a default
string display = nickname ?? "No nickname";

// Null-coalescing assignment
nickname ??= "Default";  // assign only if null
```

### Expression-Bodied Members (Shorter Syntax)

```csharp
// Old
public string GetGreeting(string name)
{
    return $"Hello, {name}";
}

// Modern — for single-expression methods
public string GetGreeting(string name) => $"Hello, {name}";
```

### LINQ — Query Collections (Preview — Deep dive on Day 5)

```csharp
var orders = new List<Order> { /* ... */ };

// Filter + transform — reads like English
var highValueOrders = orders
    .Where(o => o.Total > 100)          // filter
    .OrderByDescending(o => o.Total)    // sort
    .Select(o => new { o.Id, o.Total }) // project (pick fields)
    .ToList();
```

---

## Key Takeaways

1. **.NET is the runtime** — C# is the language. They work together; you write C#, .NET runs it.
2. **OOP in one line** — Encapsulation hides state, Inheritance reuses behavior, Polymorphism lets one call behave differently per type, Abstraction hides how behind what.
3. **Interfaces are contracts** — always code to an interface, not a concrete class; prefer interfaces over abstract classes for capability contracts.
4. **Records for data** — use `record` for DTOs; they are immutable and self-documenting.
5. **Async/await = non-blocking I/O** — never use `.Result` or `.Wait()`.
6. **`?` means nullable** — the compiler helps you avoid null-reference exceptions.

---

## Q&A Prompts

1. What's the difference between `var` and `dynamic` in C#?
2. What are the 4 pillars of OOP? Give a one-line example of each in C#.
3. What's the difference between an abstract class and an interface? When do you choose each?
4. Why would you use an interface instead of just inheriting from a base class?
5. What happens if you call an async method without `await`?
6. What does `record` give you that a regular `class` doesn't?

---

## What's Next — Day 1

Now that you can read C# code, next session we'll look at **how a modern .NET application is structured** — Clean Architecture layers, and how Azure services map to each layer.
