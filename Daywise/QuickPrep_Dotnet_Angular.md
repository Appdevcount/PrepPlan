Great — this is a **very strong real-world interview set** (perfect for your Tech Lead / Architect goal). I’ll give you **crisp but deep answers** (interview-ready), with **examples + when to use + pitfalls**.

---

# 🔷 Angular

## 1. Lifecycle Hooks

Sequence (most asked):

```
ngOnChanges → ngOnInit → ngDoCheck → ngAfterContentInit 
→ ngAfterContentChecked → ngAfterViewInit → ngAfterViewChecked → ngOnDestroy
```

**Example**

```ts
ngOnInit() {
  this.loadData();
}

ngOnDestroy() {
  this.subscription.unsubscribe();
}
```

👉 Use:

* `ngOnInit` → API calls
* `ngOnDestroy` → cleanup (avoid memory leaks)

---

## 2. Angular Bootstrap

Bootstrapping = **starting point of Angular app**

```ts
platformBrowserDynamic().bootstrapModule(AppModule);
```

In modern Angular (standalone):

```ts
bootstrapApplication(AppComponent);
```

👉 Root component loads first

---

## 3. AOT (Ahead Of Time Compilation)

* Compile **HTML + TS → JS at build time**
* Improves:

  * Performance 🚀
  * Smaller bundle
  * Early error detection

👉 Opposite: JIT (runtime compilation)

---

## 4. RxJS

### Types of Operators

* Creation → `of`, `from`
* Transformation → `map`
* Filtering → `filter`
* Combination → `combineLatest`
* Higher-order → `switchMap`, `mergeMap`

### switchMap vs mergeMap

| Feature          | switchMap  | mergeMap   |
| ---------------- | ---------- | ---------- |
| Cancels previous | ✅ Yes      | ❌ No       |
| Parallel calls   | ❌ No       | ✅ Yes      |
| Use case         | Search API | Bulk calls |

👉 Example:

```ts
this.search$.pipe(
  switchMap(val => this.api.search(val))
);
```

---

## 5. Pipes

Built-in: `date`, `currency`, `uppercase`

### Custom Pipe

```ts
@Pipe({ name: 'reverse' })
export class ReversePipe implements PipeTransform {
  transform(value: string): string {
    return value.split('').reverse().join('');
  }
}
```

---

## 6. Directives

Types:

* Component
* Structural → `*ngIf`, `*ngFor`
* Attribute → `ngClass`

### Custom Directive

```ts
@Directive({ selector: '[appHighlight]' })
export class HighlightDirective {
  constructor(el: ElementRef) {
    el.nativeElement.style.backgroundColor = 'yellow';
  }
}
```

---

## 7. Route Guards

Types:

* `CanActivate`
* `CanDeactivate`
* `Resolve`

```ts
canActivate(): boolean {
  return this.authService.isLoggedIn();
}
```

---

## 8. Exception Handling in RxJS

```ts
this.api.getData().pipe(
  catchError(err => {
    console.log(err);
    return of([]);
  })
);
```

---

## 9. Change Detection

Default:

* Checks entire component tree

OnPush:

* Checks only when:

  * Input changes
  * Event triggered

```ts
changeDetection: ChangeDetectionStrategy.OnPush
```

👉 Improves performance

---

## 10. Reactive Forms

```ts
this.form = new FormGroup({
  name: new FormControl('', Validators.required)
});
```

### Custom Validation

```ts
function customValidator(control: AbstractControl) {
  return control.value === 'admin' ? { invalid: true } : null;
}
```

---

## 11. NgRx

* Store → State
* Actions → Events
* Reducer → Pure function

```ts
const reducer = createReducer(
  initialState,
  on(addItem, (state, action) => [...state, action.item])
);
```

---

## 12. Signals (Modern Angular 🚀)

```ts
count = signal(0);

this.count.set(1);
```

👉 Replaces:

* RxJS in simple cases
* Improves performance

---

# 🔷 .NET / C#

## 1. SOLID

* S → Single Responsibility
* O → Open/Closed
* L → Liskov
* I → Interface Segregation
* D → Dependency Injection

---

## 2. Design Patterns (Real-world)

* Repository
* Unit of Work
* Factory
* Strategy
* CQRS (you already use 👍)

---

## 3. Abstract Class Use

* Partial implementation + base behavior

```csharp
abstract class Payment {
    public abstract void Pay();
}
```

---

## 4. Interface vs Abstract

| Feature              | Interface | Abstract |
| -------------------- | --------- | -------- |
| Multiple inheritance | ✅         | ❌        |
| Implementation       | ❌         | ✅        |

---

## 5. virtual vs override

```csharp
public virtual void Method() {}
public override void Method() {}
```

---

## 6. ref vs out

| Feature                | ref | out |
| ---------------------- | --- | --- |
| Must initialize        | ✅   | ❌   |
| Return multiple values | ❌   | ✅   |

---

## 7. Generics

```csharp
class Repository<T> {
   public T GetById(int id) {}
}
```

---

## 8. Middleware

Pipeline component

```csharp
public async Task Invoke(HttpContext context) {
   await _next(context);
}
```

---

## 9. Authentication & Authorization

* Auth → Who you are (JWT, Azure AD B2C)
* AuthZ → What you can access (Roles, Policies)

---

## 10. Action Filters

* Authorization
* Action
* Result
* Exception

---

## 11. Rate Limiting

```csharp
builder.Services.AddRateLimiter();
```

👉 Protect API from abuse

---

## 12. Model Binding

Maps request → C# object

```csharp
public IActionResult Create(User user)
```

---

## 13. WebHost

* Hosts app
* Kestrel server

---

## 14. Model Validation

```csharp
[Required]
public string Name { get; set; }
```

---

## 15. .NET Standard

* Common API across frameworks

---

## 16. Migration (.NET)

Key considerations:

* Breaking changes
* Dependency upgrade
* Performance testing

---

## 17. EF Core

### Deferred Execution

```csharp
var query = context.Users.Where(x => x.IsActive);
```

Executed only when:

```csharp
query.ToList();
```

### AsNoTracking

* Read-only → faster

### Lazy Loading

* Loads related data when accessed

---

# 🔷 SQL

## 1. Clustered vs Non-Clustered

| Clustered              | Non-Clustered  |
| ---------------------- | -------------- |
| Data stored physically | Separate index |
| One per table          | Many           |

---

## 2. CTE

```sql
WITH CTE AS (
   SELECT * FROM Employees
)
SELECT * FROM CTE;
```

---

## 3. Window Function

```sql
SELECT name, RANK() OVER (ORDER BY salary DESC)
FROM Employees;
```

---

## 4. Performance Optimization

* Indexing
* Avoid SELECT *
* Use joins properly
* Query plan analysis

---

## 5. Second Highest Salary

```sql
SELECT MAX(Salary)
FROM Employees
WHERE Salary < (SELECT MAX(Salary) FROM Employees);
```

---

# 🔥 Final Tip (Very Important for YOU)

At your experience (12+ years), interviewers expect:

👉 Not just answers — but:

* Trade-offs
* When NOT to use
* Real project examples

Example:

> "We used OnPush + trackBy to optimize a large grid rendering ~10k records"

---

If you want next level 🔥
I can convert this into:

✅ Mock interview (like real panel)
✅ Scenario-based Q&A (very high probability questions)
✅ C# + Angular combined architecture questions

Just tell me 👍
Perfect — this set is **very aligned to architect-level interviews**. I’ll give you **interview-quality answers + code + when to use + pitfalls**.

---

# 🔷 1. Middleware using Delegate (Core Concept)

👉 Middleware = **Request → Response pipeline**

### ✅ Using `Use` (Delegate-based middleware)

```csharp
app.Use(async (context, next) =>
{
    Console.WriteLine("Before Request");

    await next(); // Call next middleware

    Console.WriteLine("After Response");
});
```

### ✅ Custom Middleware Class

```csharp
public class LoggingMiddleware
{
    private readonly RequestDelegate _next;

    public LoggingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        Console.WriteLine("Request started");

        await _next(context);

        Console.WriteLine("Response completed");
    }
}
```

Register:

```csharp
app.UseMiddleware<LoggingMiddleware>();
```

👉 **Interview Tip**

* Order matters (Auth before Authorization, etc.)
* Short-circuiting possible (don’t call `next()`)

---

# 🔷 2. Facade Design Pattern

👉 Provides a **simple interface over complex system**

### Example (Real-world: Payment system)

```csharp
public class PaymentFacade
{
    private readonly CardService _card;
    private readonly FraudService _fraud;

    public PaymentFacade(CardService card, FraudService fraud)
    {
        _card = card;
        _fraud = fraud;
    }

    public bool ProcessPayment()
    {
        if (!_fraud.Check())
            return false;

        return _card.Charge();
    }
}
```

👉 **Use Case**

* Hide complexity
* Simplify APIs

👉 **Example in your world**

* API Gateway / Service Layer = Facade

---

# 🔷 3. Liskov Substitution Principle (LSP)

👉 **Definition**

> Derived class should be replaceable with base class without breaking behavior

### ❌ Violation Example

```csharp
class Bird {
   public virtual void Fly() {}
}

class Penguin : Bird {
   public override void Fly() {
      throw new Exception("Cannot fly"); // ❌ violation
   }
}
```

### ✅ Fix

```csharp
interface IFlyable {
   void Fly();
}
```

👉 **Interview Tip**

* Avoid “Not Supported Exception”
* Use proper abstractions

---

# 🔷 4. Repository Design Pattern

👉 Abstracts data access

### Interface

```csharp
public interface IRepository<T>
{
    Task<T> GetById(int id);
    Task Add(T entity);
}
```

### Implementation

```csharp
public class Repository<T> : IRepository<T> where T : class
{
    private readonly DbContext _context;

    public Repository(DbContext context)
    {
        _context = context;
    }

    public async Task<T> GetById(int id)
    {
        return await _context.Set<T>().FindAsync(id);
    }

    public async Task Add(T entity)
    {
        await _context.Set<T>().AddAsync(entity);
    }
}
```

👉 **Pros**

* Testability
* Separation of concerns

👉 **Cons (Important for Architect)**

* EF Core already acts like repository → avoid over abstraction

---

# 🔷 5. One-to-Many in EF Core

### Models

```csharp
public class Customer
{
    public int Id { get; set; }
    public List<Order> Orders { get; set; }
}

public class Order
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public Customer Customer { get; set; }
}
```

### Fluent API

```csharp
modelBuilder.Entity<Order>()
    .HasOne(o => o.Customer)
    .WithMany(c => c.Orders)
    .HasForeignKey(o => o.CustomerId);
```

👉 **Key Concepts**

* Navigation properties
* Foreign key

---

# 🔷 6. Microservices vs Monolith (Config + Scaling)

## Monolith

* Single app
* Shared config (appsettings.json)

### Scaling

* Vertical scaling (increase CPU/RAM)
* Whole app scaled together

---

## Microservices

* Multiple services
* Independent config

### Configuration

* Per service config
* Azure App Config / Key Vault (in your case)

### Scaling

* Horizontal scaling per service
* Example:

  * Payment → 10 instances
  * Notification → 2 instances

👉 **Interview Gold Line**

> "Microservices allow selective scaling based on load patterns"

---

# 🔷 7. Read appsettings by Key

### Using IConfiguration

```csharp
var value = configuration["MyKey"];
```

### Nested

```csharp
var value = configuration["Section:SubKey"];
```

---

# 🔷 8. IOptions vs IConfiguration

| Feature       | IConfiguration | IOptions              |
| ------------- | -------------- | --------------------- |
| Type safety   | ❌              | ✅                     |
| Direct access | ✅              | ❌                     |
| Best for      | Quick read     | Strongly typed config |

### Example

```csharp
public class MySettings {
   public string Name { get; set; }
}
```

```csharp
builder.Services.Configure<MySettings>(
    builder.Configuration.GetSection("MySettings"));
```

Usage:

```csharp
public class MyService {
   public MyService(IOptions<MySettings> options) {
      var name = options.Value.Name;
   }
}
```

👉 **Variants**

* `IOptionsSnapshot` (per request)
* `IOptionsMonitor` (real-time changes)

---

# 🔷 9. Scoped vs Transient

| Lifetime  | Behavior                |
| --------- | ----------------------- |
| Transient | New instance every time |
| Scoped    | One per request         |
| Singleton | One for app             |

### Example

```csharp
services.AddTransient<IMyService, MyService>();
services.AddScoped<IMyService, MyService>();
```

---

## 🔥 Real-world understanding (Important)

### Scoped

* DB Context → must be scoped

### Transient

* Lightweight stateless services

### ❌ Common Mistake

> Injecting scoped into singleton → runtime error

---

# 🔥 Architect-Level Add-ons (Use in Interview)

👉 Say this to stand out:

* “We avoided repository overuse since EF Core already implements Unit of Work”
* “We used IOptionsMonitor for dynamic config reload in production”
* “We used middleware for cross-cutting concerns like logging, correlation ID”

---

If you want next level 🚀
I can:

✅ Turn this into **real scenario-based questions**
✅ Add **Azure + Microservices architecture answers**
✅ Give **coding + design combo questions (very high probability in interviews)**
