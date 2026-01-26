# 60 C# Coding Interview Questions for Senior .NET Developers

This document contains a curated list of 60 C# coding interview questions, ranging from beginner to expert level, commonly asked in top service-based and product-based companies in India. Each question includes a detailed explanation, reasoning, and a sample coding implementation.

---

## Beginner Level

### 1. What is the difference between `ref` and `out` parameters in C#?
**Explanation:**
Both `ref` and `out` are used to pass arguments by reference. The difference is that `ref` requires the variable to be initialized before passing, while `out` does not.

**Reason:**
Understanding parameter passing is fundamental for debugging and API design.

**Code Example:**
```csharp
void RefExample(ref int x) { x += 10; }
void OutExample(out int x) { x = 20; }

int a = 5;
RefExample(ref a); // a = 15
int b;
OutExample(out b); // b = 20
```

---

### 2. What is the difference between `==` and `.Equals()` in C#?
**Explanation:**
`==` checks for reference equality for reference types (unless overloaded), while `.Equals()` checks for value equality.

**Reason:**
Prevents bugs in object comparison.

**Code Example:**
```csharp
string s1 = "hello";
string s2 = new string("hello".ToCharArray());
Console.WriteLine(s1 == s2); // True
Console.WriteLine(s1.Equals(s2)); // True
```

---

### 3. What is boxing and unboxing in C#?
**Explanation:**
Boxing is converting a value type to object type. Unboxing is extracting the value type from the object.

**Reason:**
Affects performance and memory usage.

**Code Example:**
```csharp
int i = 123;
object o = i; // Boxing
int j = (int)o; // Unboxing
```

---

### 4. What is the difference between `Array` and `ArrayList`?
**Explanation:**
`Array` is strongly typed, fixed size. `ArrayList` is non-generic, can store any type, and resizes dynamically.

**Reason:**
Choosing the right collection impacts type safety and performance.

**Code Example:**
```csharp
int[] arr = new int[3];
ArrayList list = new ArrayList();
list.Add(1);
list.Add("two");
```

---

### 5. What is a delegate in C#?
**Explanation:**
A delegate is a type-safe function pointer, used for callbacks and event handling.

**Reason:**
Delegates are foundational for events and LINQ.

**Code Example:**
```csharp
delegate int MathOp(int x, int y);
MathOp add = (a, b) => a + b;
Console.WriteLine(add(2, 3)); // 5
```

---

### 6. What is the difference between `abstract` class and `interface`?
**Explanation:**
An abstract class can have implementations; interfaces cannot (prior to C# 8). A class can inherit multiple interfaces but only one abstract class.

**Reason:**
Affects design and extensibility.

**Code Example:**
```csharp
abstract class Animal { public abstract void Speak(); }
interface IFly { void Fly(); }
```

---

### 7. What is the use of `using` statement in C#?
**Explanation:**
Ensures that `IDisposable` objects are disposed automatically.

**Reason:**
Prevents resource leaks.

**Code Example:**
```csharp
using (var fs = new FileStream("file.txt", FileMode.Open))
{
    // Use fs
}
```

---

### 8. What is the difference between `const` and `readonly`?
**Explanation:**
`const` is compile-time constant, `readonly` is runtime constant (can be set in constructor).

**Reason:**
Affects immutability and initialization.

**Code Example:**
```csharp
const int X = 10;
readonly int Y;
public MyClass() { Y = 20; }
```

---

### 9. What is the purpose of `lock` statement?
**Explanation:**
Ensures that a block of code runs by only one thread at a time.

**Reason:**
Prevents race conditions in multithreaded code.

**Code Example:**
```csharp
private object syncObj = new object();
lock(syncObj) { /* critical section */ }
```

---

### 10. What is the difference between `public`, `private`, `protected`, and `internal`?
**Explanation:**
These are access modifiers controlling visibility of members.

**Reason:**
Affects encapsulation and API design.

**Code Example:**
```csharp
public int A;
private int B;
protected int C;
internal int D;
```

---

## Intermediate Level

### 11. What is LINQ and why is it useful?
**Explanation:**
LINQ (Language Integrated Query) allows querying collections in a declarative way.

**Reason:**
Improves code readability and maintainability.

**Code Example:**
```csharp
var nums = new[] {1,2,3,4};
var even = nums.Where(x => x % 2 == 0);
```

---

### 12. Explain the difference between `Task` and `Thread`.
**Explanation:**
`Task` is a higher-level abstraction for asynchronous programming, while `Thread` is a lower-level OS thread.

**Reason:**
Choosing the right concurrency model is crucial for scalability.

**Code Example:**
```csharp
Task.Run(() => Console.WriteLine("Task"));
new Thread(() => Console.WriteLine("Thread")).Start();
```

---

### 13. What is dependency injection?
**Explanation:**
A design pattern where dependencies are provided from outside rather than created inside.

**Reason:**
Improves testability and maintainability.

**Code Example:**
```csharp
public class Service { }
public class Consumer {
    private Service _service;
    public Consumer(Service service) { _service = service; }
}
```

---

### 14. What is the difference between `IEnumerable` and `IEnumerator`?
**Explanation:**
`IEnumerable` exposes an enumerator, while `IEnumerator` provides the iteration logic.

**Reason:**
Understanding iteration is key for custom collections.

**Code Example:**
```csharp
foreach(var item in collection) { }
```

---

### 15. What is a `Nullable` type?
**Explanation:**
Allows value types to represent null values.

**Reason:**
Useful for database and optional values.

**Code Example:**
```csharp
int? x = null;
if (x.HasValue) { Console.WriteLine(x.Value); }
```

---

### 16. What is the difference between `override`, `new`, and `virtual` keywords?
**Explanation:**
`virtual` allows a method to be overridden, `override` overrides it, `new` hides it.

**Reason:**
Affects polymorphism and method resolution.

**Code Example:**
```csharp
class Base { public virtual void Foo() { } }
class Derived : Base { public override void Foo() { } }
```

---

### 17. What is the difference between `Dispose` and `Finalize`?
**Explanation:**
`Dispose` is called explicitly to free resources, `Finalize` is called by GC.

**Reason:**
Proper resource management is critical.

**Code Example:**
```csharp
public void Dispose() { /* free resources */ }
~MyClass() { /* finalizer */ }
```

---

### 18. What is covariance and contravariance?
**Explanation:**
Covariance allows a method to return a more derived type, contravariance allows a method to accept a less derived type.

**Reason:**
Affects generic type safety.

**Code Example:**
```csharp
IEnumerable<string> strs = new List<string>(); // Covariance
Action<object> act = (obj) => { }; // Contravariance
```

---

### 19. What is the difference between `static` and instance members?
**Explanation:**
`static` members belong to the type, instance members belong to the object.

**Reason:**
Affects memory usage and design.

**Code Example:**
```csharp
class MyClass { public static int X; public int Y; }
```

---

### 20. What is the use of `async` and `await`?
**Explanation:**
Used for asynchronous programming, allowing non-blocking code.

**Reason:**
Improves responsiveness and scalability.

**Code Example:**
```csharp
async Task<int> GetDataAsync() { await Task.Delay(1000); return 42; }
```

---

## Advanced Level

### 21. What is the difference between shallow copy and deep copy?
**Explanation:**
Shallow copy copies references, deep copy copies objects recursively.

**Reason:**
Prevents unintended side effects.

**Code Example:**
```csharp
var shallow = obj;
var deep = JsonConvert.DeserializeObject<MyClass>(JsonConvert.SerializeObject(obj));
```

---

### 22. What is memory leak in .NET and how to prevent it?
**Explanation:**
Occurs when objects are not released due to references, even if not needed.

**Reason:**
Affects application performance and stability.

**Code Example:**
```csharp
// Unsubscribe from events, dispose objects
```

---

### 23. Explain SOLID principles.
**Explanation:**
SOLID stands for Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.

**Reason:**
Improves code maintainability and scalability.

**Code Example:**
```csharp
// Example: Single Responsibility Principle
class ReportPrinter { public void Print() { } }
```

---

### 24. What is the difference between `Task.Wait()` and `await`?
**Explanation:**
`Task.Wait()` blocks the thread, `await` does not.

**Reason:**
Affects scalability and deadlock risk.

**Code Example:**
```csharp
await task; // Non-blocking
// task.Wait(); // Blocking
```

---

### 25. What is thread safety and how do you ensure it?
**Explanation:**
Thread safety ensures that shared data is accessed by only one thread at a time.

**Reason:**
Prevents data corruption.

**Code Example:**
```csharp
lock(syncObj) { /* critical section */ }
```

---

### 26. What is the difference between `IQueryable` and `IEnumerable`?
**Explanation:**
`IEnumerable` executes queries in memory, `IQueryable` can translate queries to remote data sources (like SQL).

**Reason:**
Affects performance and query execution.

**Code Example:**
```csharp
IQueryable<User> users = db.Users;
IEnumerable<User> localUsers = users.ToList();
```

---

### 27. What is a deadlock and how can you avoid it?
**Explanation:**
A deadlock occurs when two or more threads wait indefinitely for each other to release resources.

**Reason:**
Prevents application hangs.

**Code Example:**
```csharp
// Avoid nested locks, use lock ordering
```

---

### 28. What is the difference between `yield return` and `return`?
**Explanation:**
`yield return` returns elements one at a time, `return` exits the method.

**Reason:**
Enables lazy evaluation.

**Code Example:**
```csharp
IEnumerable<int> GetNumbers() { yield return 1; yield return 2; }
```

---

### 29. What is the use of `Span<T>`?
**Explanation:**
`Span<T>` provides a type-safe, memory-safe view over contiguous memory.

**Reason:**
Improves performance for memory-intensive operations.

**Code Example:**
```csharp
Span<int> span = stackalloc int[10];
```

---

### 30. What is the difference between `async void` and `async Task`?
**Explanation:**
`async void` is used for event handlers, `async Task` for async methods.

**Reason:**
`async void` cannot be awaited or caught for exceptions.

**Code Example:**
```csharp
async void OnClick(object sender, EventArgs e) { await Task.Delay(100); }
async Task DoWorkAsync() { await Task.Delay(100); }
```

---

## Expert Level

### 31. How does garbage collection work in .NET?
**Explanation:**
GC automatically frees memory by collecting unused objects. It uses generations and compacts memory.

**Reason:**
Affects performance and memory usage.

**Code Example:**
```csharp
GC.Collect();
```

---

### 32. What is the difference between `Task.Run` and `Task.Factory.StartNew`?
**Explanation:**
`Task.Run` is simpler and preferred for CPU-bound work. `Task.Factory.StartNew` offers more options but is complex.

**Reason:**
Affects task scheduling and performance.

**Code Example:**
```csharp
Task.Run(() => { });
Task.Factory.StartNew(() => { }, TaskCreationOptions.LongRunning);
```

---

### 33. What is the use of `ConfigureAwait(false)`?
**Explanation:**
Prevents capturing the synchronization context, improving performance in library code.

**Reason:**
Prevents deadlocks in UI apps.

**Code Example:**
```csharp
await SomeAsync().ConfigureAwait(false);
```

---

### 34. What is reflection and when would you use it?
**Explanation:**
Reflection allows inspecting and modifying metadata at runtime.

**Reason:**
Used for dynamic type discovery, plugins, serialization.

**Code Example:**
```csharp
Type t = typeof(MyClass);
var props = t.GetProperties();
```

---

### 35. What is the difference between `ValueTask` and `Task`?
**Explanation:**
`ValueTask` is a lightweight alternative to `Task` for performance-critical scenarios.

**Reason:**
Reduces allocations for frequently completed tasks.

**Code Example:**
```csharp
async ValueTask<int> GetValueAsync() { return 42; }
```

---

### 36. What is the use of `Span<T>` and `Memory<T>`?
**Explanation:**
`Span<T>` is stack-only, `Memory<T>` can be used on heap and supports async.

**Reason:**
Improves performance for large data processing.

**Code Example:**
```csharp
Memory<int> mem = new int[10];
```

---

### 37. What is the difference between `Semaphore` and `Mutex`?
**Explanation:**
`Semaphore` allows multiple threads, `Mutex` allows only one.

**Reason:**
Used for different synchronization scenarios.

**Code Example:**
```csharp
Semaphore sem = new Semaphore(2, 2);
Mutex mutex = new Mutex();
```

---

### 38. What is the use of `volatile` keyword?
**Explanation:**
Ensures that a variable is always read from memory, not cache.

**Reason:**
Prevents stale data in multithreaded code.

**Code Example:**
```csharp
volatile int flag;
```

---

### 39. What is the difference between `Task.WhenAll` and `Task.WhenAny`?
**Explanation:**
`Task.WhenAll` waits for all tasks, `Task.WhenAny` waits for any one.

**Reason:**
Used for different async coordination scenarios.

**Code Example:**
```csharp
await Task.WhenAll(task1, task2);
await Task.WhenAny(task1, task2);
```

---

### 40. What is the use of `IAsyncEnumerable<T>`?
**Explanation:**
Allows asynchronous iteration over a collection.

**Reason:**
Improves scalability for streaming data.

**Code Example:**
```csharp
async IAsyncEnumerable<int> GetNumbersAsync() { yield return 1; await Task.Delay(100); }
```

---

## Expert/Architect Level

### 41. How do you implement a custom attribute in C#?
**Explanation:**
Custom attributes add metadata to code elements.

**Reason:**
Used for frameworks, validation, and code generation.

**Code Example:**
```csharp
[AttributeUsage(AttributeTargets.Class)]
public class MyAttr : Attribute { }
```

---

### 42. What is the use of `Expression Trees`?
**Explanation:**
Expression trees represent code as data, enabling dynamic query generation.

**Reason:**
Used in LINQ providers, ORM frameworks.

**Code Example:**
```csharp
Expression<Func<int, bool>> expr = x => x > 5;
```

---

### 43. What is the difference between `ICloneable` and copy constructors?
**Explanation:**
`ICloneable` provides a `Clone()` method, copy constructors are explicit.

**Reason:**
Affects object copying semantics.

**Code Example:**
```csharp
public class MyClass : ICloneable { public object Clone() => MemberwiseClone(); }
```

---

### 44. What is the use of `dynamic` keyword?
**Explanation:**
Bypasses compile-time type checking, resolved at runtime.

**Reason:**
Used for interop, dynamic languages, and reflection.

**Code Example:**
```csharp
dynamic obj = "hello";
Console.WriteLine(obj.Length);
```

---

### 45. What is the difference between `Func`, `Action`, and `Predicate`?
**Explanation:**
`Func` returns a value, `Action` does not, `Predicate` returns a bool.

**Reason:**
Used for delegates and LINQ.

**Code Example:**
```csharp
Func<int, int> square = x => x * x;
Action<string> print = s => Console.WriteLine(s);
Predicate<int> isEven = x => x % 2 == 0;
```

---

### 46. What is the use of `Tuple` and `ValueTuple`?
**Explanation:**
Tuples group multiple values. `ValueTuple` is a lightweight struct version.

**Reason:**
Improves code readability and reduces boilerplate.

**Code Example:**
```csharp
var tuple = (1, "hello");
```

---

### 47. What is the difference between `Dictionary` and `ConcurrentDictionary`?
**Explanation:**
`ConcurrentDictionary` is thread-safe, `Dictionary` is not.

**Reason:**
Used in multithreaded scenarios.

**Code Example:**
```csharp
var dict = new ConcurrentDictionary<int, string>();
```

---

### 48. What is the use of `Lazy<T>`?
**Explanation:**
Delays object creation until needed.

**Reason:**
Improves performance and resource usage.

**Code Example:**
```csharp
Lazy<MyClass> lazy = new Lazy<MyClass>(() => new MyClass());
```

---

### 49. What is the difference between `await Task.Yield()` and `await Task.Delay(0)`?
**Explanation:**
`Task.Yield()` forces an asynchronous yield, `Task.Delay(0)` schedules a continuation after a delay.

**Reason:**
Affects scheduling and responsiveness.

**Code Example:**
```csharp
await Task.Yield();
await Task.Delay(0);
```

---

### 50. What is the use of `CancellationToken`?
**Explanation:**
Allows cooperative cancellation of async operations.

**Reason:**
Improves responsiveness and resource management.

**Code Example:**
```csharp
CancellationTokenSource cts = new CancellationTokenSource();
await Task.Run(() => { if (cts.Token.IsCancellationRequested) return; });
```

---

## System Design & Architecture

### 51. How would you design a thread-safe singleton in C#?
**Explanation:**
Ensures only one instance is created, even in multithreaded scenarios.

**Reason:**
Prevents bugs in shared resources.

**Code Example:**
```csharp
public sealed class Singleton {
    private static readonly Lazy<Singleton> instance = new Lazy<Singleton>(() => new Singleton());
    public static Singleton Instance => instance.Value;
    private Singleton() { }
}
```

---

### 52. How do you implement a producer-consumer pattern?
**Explanation:**
Separates data production and consumption using a thread-safe queue.

**Reason:**
Improves throughput and decouples components.

**Code Example:**
```csharp
BlockingCollection<int> queue = new BlockingCollection<int>();
Task producer = Task.Run(() => { for (int i = 0; i < 10; i++) queue.Add(i); queue.CompleteAdding(); });
Task consumer = Task.Run(() => { foreach (var item in queue.GetConsumingEnumerable()) Console.WriteLine(item); });
```

---

### 53. How would you design a RESTful API in .NET?
**Explanation:**
Use ASP.NET Core, controllers, routing, and dependency injection.

**Reason:**
Industry standard for web services.

**Code Example:**
```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase {
    [HttpGet]
    public IEnumerable<Product> Get() { return ...; }
}
```

---

### 54. How do you handle exceptions in async code?
**Explanation:**
Use try-catch with await, handle AggregateException for tasks.

**Reason:**
Prevents unhandled exceptions and crashes.

**Code Example:**
```csharp
try { await SomeAsync(); } catch (Exception ex) { /* handle */ }
```

---

### 55. How do you implement logging in .NET applications?
**Explanation:**
Use built-in logging frameworks like ILogger, Serilog, NLog.

**Reason:**
Aids in monitoring and debugging.

**Code Example:**
```csharp
public class MyService {
    private readonly ILogger<MyService> _logger;
    public MyService(ILogger<MyService> logger) { _logger = logger; }
    public void DoWork() { _logger.LogInformation("Working"); }
}
```

---

### 56. How do you secure a .NET web application?
**Explanation:**
Use authentication, authorization, HTTPS, input validation, and secure storage.

**Reason:**
Prevents security vulnerabilities.

**Code Example:**
```csharp
services.AddAuthentication();
services.AddAuthorization();
app.UseHttpsRedirection();
```

---

### 57. How do you implement caching in .NET?
**Explanation:**
Use MemoryCache, DistributedCache, or third-party providers.

**Reason:**
Improves performance and scalability.

**Code Example:**
```csharp
IMemoryCache cache;
cache.Set("key", value, TimeSpan.FromMinutes(5));
```

---

### 58. How do you implement unit testing in .NET?
**Explanation:**
Use frameworks like MSTest, NUnit, or xUnit.

**Reason:**
Ensures code correctness and prevents regressions.

**Code Example:**
```csharp
[TestMethod]
public void TestAdd() { Assert.AreEqual(4, Add(2,2)); }
```

---

### 59. How do you implement dependency injection in ASP.NET Core?
**Explanation:**
Register services in the DI container and inject via constructor.

**Reason:**
Promotes loose coupling and testability.

**Code Example:**
```csharp
services.AddScoped<IMyService, MyService>();
public class MyController {
    public MyController(IMyService service) { }
}
```

---

### 60. How do you implement middleware in ASP.NET Core?
**Explanation:**
Middleware is a component that handles requests and responses in the pipeline.

**Reason:**
Used for cross-cutting concerns like logging, authentication.

**Code Example:**
```csharp
public class MyMiddleware {
    private readonly RequestDelegate _next;
    public MyMiddleware(RequestDelegate next) { _next = next; }
    public async Task Invoke(HttpContext context) {
        // Do something
        await _next(context);
    }
}
app.UseMiddleware<MyMiddleware>();
```

---

*This list is based on real interview experiences and expert recommendations for senior .NET developers in India.*
