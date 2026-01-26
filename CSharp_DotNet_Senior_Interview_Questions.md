# C# and .NET Senior Developer Interview Questions
## Real Interview Experience - From Public Forums & Company Portals

> **Sources**: Questions compiled from [CodeJourney.net](https://www.codejourney.net/real-net-interview-questions-2024-2025/), [Glassdoor](https://www.glassdoor.com/Interview/net-developer-interview-questions-SRCH_KO0,13.htm), [InterviewBit](https://www.interviewbit.com/dot-net-interview-questions/), [Toptal](https://www.toptal.com/c-sharp/interview-questions), [DEV Community](https://dev.to/), [ByteHide](https://www.bytehide.com/), [Bool.dev](https://bool.dev/), and real interview experiences shared on Reddit and technical forums.

---

## Table of Contents

1. [Company-Wise Interview Patterns](#company-wise-interview-patterns)
2. [Core C# Fundamentals](#core-c-fundamentals)
3. [Object-Oriented Programming](#object-oriented-programming)
4. [Async/Await & Multithreading](#asyncawait--multithreading)
5. [Memory Management & Garbage Collection](#memory-management--garbage-collection)
6. [Collections & Data Structures](#collections--data-structures)
7. [SOLID Principles & Design Patterns](#solid-principles--design-patterns)
8. [Dependency Injection](#dependency-injection)
9. [Entity Framework Core](#entity-framework-core)
10. [ASP.NET Core Web API](#aspnet-core-web-api)
11. [Microservices & Distributed Systems](#microservices--distributed-systems)
12. [System Design Questions](#system-design-questions)
13. [Behavioral & Scenario-Based Questions](#behavioral--scenario-based-questions)
14. [LINQ Interview Questions](#linq-interview-questions)
15. [Modern C# Features (.NET 6/7/8)](#modern-c-features-net-678)
16. [SQL Server for .NET Developers](#sql-server-for-net-developers)
17. [Coding Problems & LeetCode Patterns](#coding-problems--leetcode-patterns)
18. [Real Interview Experiences](#real-interview-experiences)

---

# Company-Wise Interview Patterns

## Service-Based Companies (TCS, Infosys, Wipro, Cognizant, Accenture)

**Interview Structure:**
- Round 1: Technical Interview (45-60 mins) - Focus on fundamentals
- Round 2: HR Interview (15-20 mins)

**Common Focus Areas:**
- OOPs concepts in C#
- SQL queries and database concepts
- Web API basics
- Entity Framework fundamentals
- Basic design patterns

**Typical Questions Asked (from Glassdoor):**
- What is a Constructor? How many types?
- Explain method overloading vs method overriding
- What is Web API? How to consume it?
- Types of indexes in SQL
- What is authentication vs authorization?

---

## Product-Based Companies (Microsoft, Amazon, Startups)

**Interview Structure:**
- Round 1: Online Assessment (MCQ + Coding)
- Round 2: Technical Phone Screen (30-45 mins)
- Round 3-5: On-site/Virtual Loops (System Design + Coding + Behavioral)

**Common Focus Areas:**
- Data structures and algorithms
- System design and architecture
- Problem-solving approach
- Production debugging experience
- Leadership principles (Amazon)

**Typical Questions Asked (from real experiences):**
- Design a distributed caching system
- How would you diagnose a performance issue in production?
- Implement a rate limiter
- Design patterns you've applied in real projects

---

# Core C# Fundamentals

## 1. What is the difference between `class` and `struct`?

**Frequently Asked At:** Microsoft, Infosys, TCS, Product Companies

**Answer:**

| Feature | Class | Struct |
|---------|-------|--------|
| Type | Reference type | Value type |
| Storage | Heap | Stack (typically) |
| Default | null | Cannot be null (unless nullable) |
| Inheritance | Supports | No inheritance |
| Constructor | Can have parameterless | Must initialize all fields |
| Performance | Heap allocation overhead | Better for small data |

```csharp
// Class Example - Reference Type
public class PersonClass
{
    public string Name { get; set; }
    public int Age { get; set; }
}

// Struct Example - Value Type
public struct PersonStruct
{
    public string Name { get; set; }
    public int Age { get; set; }

    // Struct requires constructor to initialize all fields
    public PersonStruct(string name, int age)
    {
        Name = name;
        Age = age;
    }
}

// Demonstration
public void DemonstrateClassVsStruct()
{
    // Reference type behavior
    PersonClass person1 = new PersonClass { Name = "John", Age = 30 };
    PersonClass person2 = person1; // Both point to same object
    person2.Name = "Jane";
    Console.WriteLine(person1.Name); // Output: "Jane" - both changed!

    // Value type behavior
    PersonStruct struct1 = new PersonStruct("John", 30);
    PersonStruct struct2 = struct1; // Creates a copy
    struct2.Name = "Jane";
    Console.WriteLine(struct1.Name); // Output: "John" - original unchanged!
}
```

**When to use Struct:**
- Small data containers (< 16 bytes ideally)
- Immutable data
- Frequently created/destroyed objects
- No need for inheritance

---

## 2. What is the difference between `string` and `StringBuilder`?

**Frequently Asked At:** All companies - Very common question

**Answer:**

```csharp
// String - Immutable
// Every modification creates a new string object
public void StringExample()
{
    string result = "";

    // BAD: Creates 1000 string objects in memory!
    for (int i = 0; i < 1000; i++)
    {
        result += i.ToString(); // Each += creates new string
    }
}

// StringBuilder - Mutable
// Modifies the same buffer, much more efficient
public void StringBuilderExample()
{
    StringBuilder sb = new StringBuilder();

    // GOOD: Uses single buffer, resizes when needed
    for (int i = 0; i < 1000; i++)
    {
        sb.Append(i);
    }

    string result = sb.ToString();
}
```

**Performance Comparison:**

| Operation | String | StringBuilder |
|-----------|--------|---------------|
| Immutability | Immutable | Mutable |
| Memory | New object per change | Single buffer |
| Concatenation | O(n²) for loops | O(n) |
| Thread Safety | Thread-safe | Not thread-safe |
| Best For | Few modifications | Many modifications |

**Real Interview Follow-up:** "How would you process a large text file?"

```csharp
public async Task<string> ProcessLargeFile(string filePath)
{
    var sb = new StringBuilder();

    // Use StreamReader for large files
    using var reader = new StreamReader(filePath);

    string line;
    while ((line = await reader.ReadLineAsync()) != null)
    {
        // Process and append
        sb.AppendLine(ProcessLine(line));
    }

    return sb.ToString();
}

// For extremely large files, use StringWriter with streaming
public async Task ProcessAndWriteLargeFile(string inputPath, string outputPath)
{
    using var reader = new StreamReader(inputPath);
    using var writer = new StreamWriter(outputPath);

    string line;
    while ((line = await reader.ReadLineAsync()) != null)
    {
        await writer.WriteLineAsync(ProcessLine(line));
    }
}

private string ProcessLine(string line) => line.ToUpperInvariant();
```

---

## 3. What is the difference between `const` and `readonly`?

**Frequently Asked At:** TCS, Infosys, Microsoft

**Answer:**

```csharp
public class ConstVsReadonly
{
    // CONST: Compile-time constant
    // - Must be assigned at declaration
    // - Value is embedded in IL code
    // - Only primitive types and strings
    // - Implicitly static
    public const double Pi = 3.14159;
    public const string AppName = "MyApp";
    // public const DateTime StartDate = DateTime.Now; // ERROR! Not compile-time

    // READONLY: Runtime constant
    // - Can be assigned in declaration or constructor
    // - Value stored in memory
    // - Can be any type
    // - Can be instance or static
    public readonly DateTime CreatedAt;
    public readonly ILogger Logger;
    public static readonly int MaxRetries = int.Parse(Environment.GetEnvironmentVariable("MAX_RETRIES") ?? "3");

    public ConstVsReadonly(ILogger logger)
    {
        CreatedAt = DateTime.UtcNow; // Assigned in constructor
        Logger = logger;
    }
}

// Important: const values are "baked in" at compile time
// If you change a const in a library, consumers must recompile!
```

**Key Differences:**

| Feature | const | readonly |
|---------|-------|----------|
| Assigned | Declaration only | Declaration or constructor |
| Evaluation | Compile-time | Runtime |
| Types | Primitives, strings | Any type |
| Static | Always static | Instance or static |
| Memory | Embedded in IL | Stored in memory |

---

## 4. What are `ref`, `out`, and `in` parameters?

**Frequently Asked At:** Microsoft, Product Companies

**Answer:**

```csharp
public class ParameterModifiers
{
    // REF: Pass by reference, must be initialized before passing
    public void RefExample(ref int value)
    {
        value = value * 2; // Can read and modify
    }

    // OUT: Pass by reference, must be assigned inside method
    public void OutExample(out int result)
    {
        // Must assign before method returns
        result = 42;
    }

    // IN: Pass by reference (readonly), cannot modify
    public void InExample(in LargeStruct data)
    {
        // data.Value = 10; // ERROR! Cannot modify
        Console.WriteLine(data.Value); // Can only read
    }

    // Practical example: TryParse pattern uses 'out'
    public bool TryParseCustom(string input, out int result)
    {
        if (int.TryParse(input, out result))
        {
            result *= 2; // Some custom logic
            return true;
        }
        result = 0;
        return false;
    }

    // Usage
    public void Demo()
    {
        // ref - must initialize
        int refValue = 5;
        RefExample(ref refValue);
        Console.WriteLine(refValue); // 10

        // out - no initialization needed
        OutExample(out int outValue);
        Console.WriteLine(outValue); // 42

        // in - for large structs to avoid copying
        var largeData = new LargeStruct { Value = 100 };
        InExample(in largeData);
    }
}

public struct LargeStruct
{
    public int Value;
    public double Data1, Data2, Data3, Data4; // Large struct
}
```

---

## 5. What is the difference between `==` and `.Equals()`?

**Frequently Asked At:** All companies

**Answer:**

```csharp
public class EqualityComparison
{
    public void DemonstrateEquality()
    {
        // Value Types - Both compare values
        int a = 5, b = 5;
        Console.WriteLine(a == b);        // True
        Console.WriteLine(a.Equals(b));   // True

        // Reference Types - Different behavior
        string s1 = "hello";
        string s2 = "hello";
        string s3 = new string("hello".ToCharArray());

        // String has overloaded == to compare content
        Console.WriteLine(s1 == s2);           // True (interned strings)
        Console.WriteLine(s1 == s3);           // True (overloaded ==)
        Console.WriteLine(s1.Equals(s3));      // True
        Console.WriteLine(ReferenceEquals(s1, s3)); // False (different objects)

        // Object comparison
        object obj1 = new Person { Name = "John" };
        object obj2 = new Person { Name = "John" };

        Console.WriteLine(obj1 == obj2);       // False (reference comparison)
        Console.WriteLine(obj1.Equals(obj2));  // Depends on Equals override
    }
}

// Proper equality implementation
public class Person : IEquatable<Person>
{
    public string Name { get; set; }
    public int Age { get; set; }

    public override bool Equals(object obj)
    {
        return Equals(obj as Person);
    }

    public bool Equals(Person other)
    {
        if (other is null) return false;
        if (ReferenceEquals(this, other)) return true;
        return Name == other.Name && Age == other.Age;
    }

    public override int GetHashCode()
    {
        return HashCode.Combine(Name, Age);
    }

    public static bool operator ==(Person left, Person right)
    {
        if (left is null) return right is null;
        return left.Equals(right);
    }

    public static bool operator !=(Person left, Person right)
    {
        return !(left == right);
    }
}
```

---

# Object-Oriented Programming

## 6. What is the difference between `abstract class` and `interface`?

**Frequently Asked At:** All companies - One of the most common questions

**Answer:**

```csharp
// Abstract Class - Partial implementation
public abstract class Animal
{
    // Can have fields
    protected string name;

    // Can have constructor
    protected Animal(string name)
    {
        this.name = name;
    }

    // Can have implemented methods
    public void Sleep()
    {
        Console.WriteLine($"{name} is sleeping");
    }

    // Abstract methods - must be implemented
    public abstract void MakeSound();

    // Virtual methods - can be overridden
    public virtual void Move()
    {
        Console.WriteLine($"{name} is moving");
    }
}

// Interface - Contract only (C# 8+ allows default implementations)
public interface IFlyable
{
    void Fly();

    // C# 8+ Default implementation
    void Land()
    {
        Console.WriteLine("Landing...");
    }
}

public interface ISwimmable
{
    void Swim();
}

// A class can implement multiple interfaces
// But can only inherit from one abstract class
public class Duck : Animal, IFlyable, ISwimmable
{
    public Duck(string name) : base(name) { }

    public override void MakeSound()
    {
        Console.WriteLine("Quack!");
    }

    public void Fly()
    {
        Console.WriteLine($"{name} is flying");
    }

    public void Swim()
    {
        Console.WriteLine($"{name} is swimming");
    }
}
```

**Key Differences:**

| Feature | Abstract Class | Interface |
|---------|---------------|-----------|
| Inheritance | Single | Multiple |
| Fields | Yes | No (only in C# 11+ static) |
| Constructor | Yes | No |
| Access Modifiers | Any | Public (default) |
| Implementation | Partial | None (C# 7), Default (C# 8+) |
| Use Case | IS-A relationship | CAN-DO capability |

**When to use what:**
- **Abstract class**: When classes share common behavior and state
- **Interface**: When defining a contract that can be implemented by unrelated classes

---

## 7. Explain method overloading vs method overriding

**Frequently Asked At:** Infosys, TCS, Wipro - Cross-questioned in interviews

**Answer:**

```csharp
public class OverloadingVsOverriding
{
    // METHOD OVERLOADING - Compile-time polymorphism
    // Same method name, different parameters
    public class Calculator
    {
        public int Add(int a, int b)
        {
            return a + b;
        }

        public double Add(double a, double b)
        {
            return a + b;
        }

        public int Add(int a, int b, int c)
        {
            return a + b + c;
        }

        // Return type alone doesn't count as overload!
        // public double Add(int a, int b) { } // ERROR - same signature
    }

    // METHOD OVERRIDING - Runtime polymorphism
    // Same signature, different implementation in derived class
    public class Shape
    {
        public virtual double CalculateArea()
        {
            return 0;
        }
    }

    public class Circle : Shape
    {
        public double Radius { get; set; }

        public override double CalculateArea()
        {
            return Math.PI * Radius * Radius;
        }
    }

    public class Rectangle : Shape
    {
        public double Width { get; set; }
        public double Height { get; set; }

        public override double CalculateArea()
        {
            return Width * Height;
        }
    }

    // Demonstration of runtime polymorphism
    public void CalculateAreas()
    {
        List<Shape> shapes = new List<Shape>
        {
            new Circle { Radius = 5 },
            new Rectangle { Width = 4, Height = 6 }
        };

        foreach (var shape in shapes)
        {
            // Calls the appropriate overridden method at runtime
            Console.WriteLine($"Area: {shape.CalculateArea()}");
        }
    }
}
```

| Feature | Overloading | Overriding |
|---------|-------------|------------|
| Polymorphism | Compile-time | Runtime |
| Signature | Different parameters | Same signature |
| Inheritance | Not required | Required |
| Keywords | None | virtual/override |
| Binding | Early binding | Late binding |

---

## 8. What is the difference between `new` and `override` keywords?

**Frequently Asked At:** Microsoft, Product companies

**Answer:**

```csharp
public class NewVsOverride
{
    public class BaseClass
    {
        public virtual void VirtualMethod()
        {
            Console.WriteLine("Base: VirtualMethod");
        }

        public void NonVirtualMethod()
        {
            Console.WriteLine("Base: NonVirtualMethod");
        }
    }

    public class DerivedWithOverride : BaseClass
    {
        // Override - replaces base implementation in vtable
        public override void VirtualMethod()
        {
            Console.WriteLine("Derived: VirtualMethod (override)");
        }
    }

    public class DerivedWithNew : BaseClass
    {
        // New - hides base method, creates new slot
        public new void VirtualMethod()
        {
            Console.WriteLine("Derived: VirtualMethod (new)");
        }

        // Hide non-virtual method
        public new void NonVirtualMethod()
        {
            Console.WriteLine("Derived: NonVirtualMethod (new)");
        }
    }

    public void Demonstrate()
    {
        // Override behavior
        BaseClass obj1 = new DerivedWithOverride();
        obj1.VirtualMethod(); // "Derived: VirtualMethod (override)"

        // New behavior - reference type matters!
        BaseClass obj2 = new DerivedWithNew();
        obj2.VirtualMethod(); // "Base: VirtualMethod" - base method called!

        DerivedWithNew obj3 = new DerivedWithNew();
        obj3.VirtualMethod(); // "Derived: VirtualMethod (new)"

        // This is why 'new' can be dangerous - unexpected behavior
    }
}
```

**Key Insight:**
- `override`: Polymorphic behavior - derived method called regardless of reference type
- `new`: Hides base method - which method is called depends on reference type

---

# Async/Await & Multithreading

## 9. Explain async/await and how it works internally

**Frequently Asked At:** All companies - Critical for senior roles

**Answer:**

```csharp
public class AsyncAwaitExplained
{
    // Basic async/await pattern
    public async Task<string> FetchDataAsync(string url)
    {
        using var client = new HttpClient();

        // When await is hit:
        // 1. If task is not complete, method returns to caller
        // 2. Continuation is scheduled
        // 3. Thread is freed (not blocked!)
        string result = await client.GetStringAsync(url);

        // This runs after the await completes
        return ProcessData(result);
    }

    // What the compiler generates (simplified state machine)
    /*
    The compiler transforms async methods into state machines:

    1. Creates a struct implementing IAsyncStateMachine
    2. Local variables become fields
    3. await points become states
    4. MoveNext() method handles state transitions
    */

    // Common patterns

    // 1. Parallel execution with Task.WhenAll
    public async Task<(string, string)> FetchMultipleAsync()
    {
        var task1 = FetchDataAsync("https://api1.example.com");
        var task2 = FetchDataAsync("https://api2.example.com");

        // Both tasks run concurrently
        await Task.WhenAll(task1, task2);

        return (task1.Result, task2.Result);
    }

    // 2. First completed with Task.WhenAny
    public async Task<string> FetchWithFallbackAsync(string primary, string fallback)
    {
        var primaryTask = FetchDataAsync(primary);
        var fallbackTask = FetchDataAsync(fallback);

        var completedTask = await Task.WhenAny(primaryTask, fallbackTask);
        return await completedTask;
    }

    // 3. Timeout pattern
    public async Task<string> FetchWithTimeoutAsync(string url, TimeSpan timeout)
    {
        using var cts = new CancellationTokenSource(timeout);

        try
        {
            using var client = new HttpClient();
            return await client.GetStringAsync(url, cts.Token);
        }
        catch (OperationCanceledException)
        {
            throw new TimeoutException($"Request to {url} timed out");
        }
    }

    private string ProcessData(string data) => data.ToUpperInvariant();
}
```

---

## 10. What are the common pitfalls in async programming?

**Frequently Asked At:** Microsoft, Senior roles at all companies

**Answer:**

```csharp
public class AsyncPitfalls
{
    // PITFALL 1: Async void - Fire and forget with no error handling
    // BAD - Exceptions cannot be caught!
    public async void BadAsyncVoid()
    {
        await Task.Delay(100);
        throw new Exception("This will crash the app!");
    }

    // GOOD - Use async Task
    public async Task GoodAsyncTask()
    {
        await Task.Delay(100);
        throw new Exception("This can be caught");
    }

    // PITFALL 2: Deadlock with .Result or .Wait()
    // BAD - Can deadlock in UI/ASP.NET contexts
    public string DeadlockExample()
    {
        // This blocks the thread and can cause deadlock
        return FetchDataAsync().Result; // DON'T DO THIS!
    }

    // GOOD - Use async all the way
    public async Task<string> NoDeadlockExample()
    {
        return await FetchDataAsync();
    }

    // PITFALL 3: Not using ConfigureAwait in libraries
    public async Task<string> LibraryMethodAsync()
    {
        // In library code, use ConfigureAwait(false)
        // to avoid capturing synchronization context
        var data = await FetchDataAsync().ConfigureAwait(false);
        return ProcessData(data);
    }

    // PITFALL 4: Forgetting to await
    public async Task ForgotToAwait()
    {
        // BAD - Task is not awaited, exceptions are lost!
        _ = DoSomethingAsync(); // Fire and forget

        // GOOD - Await the task
        await DoSomethingAsync();
    }

    // PITFALL 5: Sequential instead of parallel
    // BAD - Sequential execution
    public async Task SequentialBad()
    {
        var result1 = await FetchDataAsync(); // Wait
        var result2 = await FetchDataAsync(); // Then wait again
    }

    // GOOD - Parallel execution
    public async Task ParallelGood()
    {
        var task1 = FetchDataAsync();
        var task2 = FetchDataAsync();
        await Task.WhenAll(task1, task2); // Both run concurrently
    }

    // PITFALL 6: Not handling exceptions in Task.WhenAll
    public async Task HandleWhenAllExceptions()
    {
        var tasks = new[]
        {
            Task.FromException(new Exception("Error 1")),
            Task.FromException(new Exception("Error 2")),
            Task.FromResult("Success")
        };

        try
        {
            await Task.WhenAll(tasks);
        }
        catch (Exception ex)
        {
            // Only first exception is thrown
            Console.WriteLine(ex.Message); // "Error 1"

            // To get all exceptions:
            var allExceptions = tasks
                .Where(t => t.IsFaulted)
                .SelectMany(t => t.Exception.InnerExceptions);
        }
    }

    private Task<string> FetchDataAsync() => Task.FromResult("data");
    private Task DoSomethingAsync() => Task.CompletedTask;
    private string ProcessData(string data) => data;
}
```

---

## 11. What is the difference between `Task` and `ValueTask`?

**Frequently Asked At:** Microsoft, Senior roles

**Answer:**

```csharp
public class TaskVsValueTask
{
    private readonly Dictionary<string, string> _cache = new();

    // Task - Always allocates on heap
    public async Task<string> GetDataWithTaskAsync(string key)
    {
        if (_cache.TryGetValue(key, out var cached))
        {
            return cached; // Still allocates Task wrapper
        }

        var data = await FetchFromDatabaseAsync(key);
        _cache[key] = data;
        return data;
    }

    // ValueTask - Can avoid allocation for synchronous paths
    public ValueTask<string> GetDataWithValueTaskAsync(string key)
    {
        if (_cache.TryGetValue(key, out var cached))
        {
            return new ValueTask<string>(cached); // No heap allocation!
        }

        return new ValueTask<string>(FetchAndCacheAsync(key));
    }

    private async Task<string> FetchAndCacheAsync(string key)
    {
        var data = await FetchFromDatabaseAsync(key);
        _cache[key] = data;
        return data;
    }

    private Task<string> FetchFromDatabaseAsync(string key)
        => Task.FromResult($"Data for {key}");
}
```

**Key Differences:**

| Feature | Task | ValueTask |
|---------|------|-----------|
| Allocation | Always heap | Stack when synchronous |
| Await multiple times | Yes | No - single await only |
| Use case | General async | High-frequency, often cached |
| Complexity | Simple | More constraints |

**Rules for ValueTask:**
1. Never await more than once
2. Never call .Result or .Wait() multiple times
3. Never use with Task.WhenAll directly

---

## 12. How do you limit concurrent async operations?

**Frequently Asked At:** Product companies, System design interviews

**Answer:**

```csharp
public class ConcurrencyControl
{
    // Method 1: SemaphoreSlim
    public async Task ProcessWithSemaphoreAsync(IEnumerable<string> urls, int maxConcurrency)
    {
        using var semaphore = new SemaphoreSlim(maxConcurrency);

        var tasks = urls.Select(async url =>
        {
            await semaphore.WaitAsync();
            try
            {
                return await ProcessUrlAsync(url);
            }
            finally
            {
                semaphore.Release();
            }
        });

        await Task.WhenAll(tasks);
    }

    // Method 2: Parallel.ForEachAsync (.NET 6+)
    public async Task ProcessWithParallelForEachAsync(IEnumerable<string> urls, int maxConcurrency)
    {
        var options = new ParallelOptions
        {
            MaxDegreeOfParallelism = maxConcurrency
        };

        await Parallel.ForEachAsync(urls, options, async (url, ct) =>
        {
            await ProcessUrlAsync(url);
        });
    }

    // Method 3: Channel-based producer-consumer
    public async Task ProcessWithChannelAsync(IEnumerable<string> urls, int maxConcurrency)
    {
        var channel = Channel.CreateBounded<string>(new BoundedChannelOptions(100)
        {
            FullMode = BoundedChannelFullMode.Wait
        });

        // Producer
        var producer = Task.Run(async () =>
        {
            foreach (var url in urls)
            {
                await channel.Writer.WriteAsync(url);
            }
            channel.Writer.Complete();
        });

        // Consumers
        var consumers = Enumerable.Range(0, maxConcurrency)
            .Select(_ => Task.Run(async () =>
            {
                await foreach (var url in channel.Reader.ReadAllAsync())
                {
                    await ProcessUrlAsync(url);
                }
            }));

        await Task.WhenAll(consumers.Append(producer));
    }

    // Method 4: Batching
    public async Task ProcessInBatchesAsync(IEnumerable<string> urls, int batchSize)
    {
        var batches = urls
            .Select((url, index) => new { url, index })
            .GroupBy(x => x.index / batchSize)
            .Select(g => g.Select(x => x.url));

        foreach (var batch in batches)
        {
            var tasks = batch.Select(ProcessUrlAsync);
            await Task.WhenAll(tasks);
        }
    }

    private async Task<string> ProcessUrlAsync(string url)
    {
        await Task.Delay(100); // Simulate work
        return $"Processed: {url}";
    }
}
```

---

# Memory Management & Garbage Collection

## 13. Explain how Garbage Collection works in .NET

**Frequently Asked At:** Microsoft, Senior roles at product companies

**Answer:**

```csharp
public class GarbageCollectionExplained
{
    /*
    Garbage Collection in .NET follows a generational approach:

    Generation 0 (Gen 0):
    - Newly allocated objects
    - Collected most frequently
    - Typically short-lived objects

    Generation 1 (Gen 1):
    - Objects that survived Gen 0 collection
    - Buffer between Gen 0 and Gen 2

    Generation 2 (Gen 2):
    - Long-lived objects
    - Collected least frequently
    - Full GC is expensive

    Large Object Heap (LOH):
    - Objects >= 85,000 bytes
    - Collected with Gen 2
    - Not compacted by default (can fragment)
    */

    // Demonstrating GC behavior
    public void DemonstrateGC()
    {
        // Force GC (don't do this in production!)
        GC.Collect();
        GC.WaitForPendingFinalizers();

        // Get current generation of an object
        var obj = new object();
        int generation = GC.GetGeneration(obj);
        Console.WriteLine($"Object is in Gen {generation}");

        // Memory info
        var info = GC.GetGCMemoryInfo();
        Console.WriteLine($"Heap Size: {info.HeapSizeBytes}");
        Console.WriteLine($"Gen 0 Collections: {GC.CollectionCount(0)}");
        Console.WriteLine($"Gen 1 Collections: {GC.CollectionCount(1)}");
        Console.WriteLine($"Gen 2 Collections: {GC.CollectionCount(2)}");
    }

    // Memory pressure and optimization
    public void MemoryOptimizationTips()
    {
        // 1. Use ArrayPool for temporary arrays
        var pool = ArrayPool<byte>.Shared;
        byte[] buffer = pool.Rent(1024);
        try
        {
            // Use buffer
        }
        finally
        {
            pool.Return(buffer);
        }

        // 2. Use Span<T> for stack allocation
        Span<int> stackArray = stackalloc int[100];

        // 3. Use structs for small, short-lived data
        var point = new Point(10, 20); // Value type, stack allocated
    }

    private readonly struct Point
    {
        public int X { get; }
        public int Y { get; }
        public Point(int x, int y) => (X, Y) = (x, y);
    }
}
```

---

## 14. Explain `IDisposable` and the Dispose pattern

**Frequently Asked At:** All companies

**Answer:**

```csharp
public class DisposablePattern : IDisposable
{
    private bool _disposed = false;
    private IntPtr _unmanagedResource; // Unmanaged resource
    private Stream _managedResource;   // Managed resource

    public DisposablePattern()
    {
        _unmanagedResource = Marshal.AllocHGlobal(100);
        _managedResource = new MemoryStream();
    }

    // Public Dispose method
    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this); // Prevent finalizer from running
    }

    // Protected virtual Dispose
    protected virtual void Dispose(bool disposing)
    {
        if (_disposed) return;

        if (disposing)
        {
            // Dispose managed resources
            _managedResource?.Dispose();
        }

        // Always clean up unmanaged resources
        if (_unmanagedResource != IntPtr.Zero)
        {
            Marshal.FreeHGlobal(_unmanagedResource);
            _unmanagedResource = IntPtr.Zero;
        }

        _disposed = true;
    }

    // Finalizer - safety net for unmanaged resources
    ~DisposablePattern()
    {
        Dispose(false);
    }

    // Throw if disposed
    private void ThrowIfDisposed()
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(DisposablePattern));
    }

    public void DoWork()
    {
        ThrowIfDisposed();
        // Work with resources
    }
}

// Modern C# with IAsyncDisposable
public class AsyncDisposableExample : IAsyncDisposable, IDisposable
{
    private readonly HttpClient _client = new();
    private bool _disposed;

    public async ValueTask DisposeAsync()
    {
        if (_disposed) return;

        // Async cleanup
        await Task.Delay(10); // Simulate async cleanup

        Dispose(false);
        GC.SuppressFinalize(this);
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (_disposed) return;

        if (disposing)
        {
            _client.Dispose();
        }

        _disposed = true;
    }
}

// Usage
public class UsageExamples
{
    public async Task Example()
    {
        // Synchronous dispose
        using var resource = new DisposablePattern();
        resource.DoWork();

        // Async dispose
        await using var asyncResource = new AsyncDisposableExample();
    }
}
```

**Key Points:**
1. Dispose pattern allows deterministic cleanup
2. Finalizer is a safety net (avoid if possible)
3. `GC.SuppressFinalize` prevents double cleanup
4. Always check `_disposed` before operations
5. Use `IAsyncDisposable` for async cleanup needs

---

## 15. What is the difference between Finalize and Dispose?

**Frequently Asked At:** Microsoft, Cognizant

**Answer:**

| Feature | Dispose | Finalize |
|---------|---------|----------|
| Called by | Developer | GC |
| Timing | Deterministic | Non-deterministic |
| Interface | IDisposable | Object destructor |
| Performance | Good | Expensive (2 GC cycles) |
| Use for | Managed + Unmanaged | Unmanaged only (backup) |

```csharp
public class FinalizeVsDispose
{
    /*
    Why Finalizers require 2 GC cycles:

    Cycle 1:
    - GC identifies object as garbage
    - Object has finalizer, so it's placed in finalization queue
    - Object is NOT collected

    Cycle 2:
    - Finalizer thread runs the finalizer
    - Object is now eligible for collection
    - Object is finally collected

    This is why GC.SuppressFinalize is important!
    */
}
```

---

# Collections & Data Structures

## 16. Explain the performance characteristics of common collections

**Frequently Asked At:** Product companies, Microsoft

**Answer:**

```csharp
public class CollectionPerformance
{
    // Time Complexity Summary
    /*
    Operation       | List<T>  | Dictionary<K,V> | HashSet<T> | SortedSet<T>
    ----------------|----------|-----------------|------------|-------------
    Add             | O(1)*    | O(1)*           | O(1)*      | O(log n)
    Remove          | O(n)     | O(1)            | O(1)       | O(log n)
    Contains/Find   | O(n)     | O(1)            | O(1)       | O(log n)
    Index Access    | O(1)     | O(1) by key     | N/A        | N/A
    Insert at start | O(n)     | N/A             | N/A        | N/A

    * Amortized - can be O(n) when resizing
    */

    public void DemonstratePerformance()
    {
        // List - Good for ordered data, index access
        var list = new List<int> { 1, 2, 3, 4, 5 };
        var item = list[2];          // O(1)
        bool contains = list.Contains(3); // O(n) - linear search!

        // Dictionary - Good for key-value lookups
        var dict = new Dictionary<string, int>
        {
            ["one"] = 1,
            ["two"] = 2
        };
        var value = dict["one"];     // O(1)
        bool hasKey = dict.ContainsKey("one"); // O(1)

        // HashSet - Good for unique items and fast lookups
        var set = new HashSet<int> { 1, 2, 3, 4, 5 };
        bool inSet = set.Contains(3); // O(1)
        set.Add(6);                   // O(1)

        // SortedSet - Maintains order, tree-based
        var sortedSet = new SortedSet<int> { 5, 2, 8, 1 };
        // Items are: 1, 2, 5, 8
        bool inSorted = sortedSet.Contains(5); // O(log n)
    }

    // Real-world scenario: Finding duplicates
    public List<int> FindDuplicates_Slow(int[] numbers)
    {
        // O(n²) - BAD!
        var duplicates = new List<int>();
        for (int i = 0; i < numbers.Length; i++)
        {
            for (int j = i + 1; j < numbers.Length; j++)
            {
                if (numbers[i] == numbers[j] && !duplicates.Contains(numbers[i]))
                    duplicates.Add(numbers[i]);
            }
        }
        return duplicates;
    }

    public List<int> FindDuplicates_Fast(int[] numbers)
    {
        // O(n) - GOOD!
        var seen = new HashSet<int>();
        var duplicates = new HashSet<int>();

        foreach (var num in numbers)
        {
            if (!seen.Add(num))
                duplicates.Add(num);
        }

        return duplicates.ToList();
    }

    // Choosing the right collection
    public void ChoosingCollections()
    {
        // Need order + index access? -> List<T>
        // Need key-value pairs + fast lookup? -> Dictionary<K,V>
        // Need unique items + fast lookup? -> HashSet<T>
        // Need sorted unique items? -> SortedSet<T>
        // Need sorted key-value? -> SortedDictionary<K,V>
        // Need thread-safe? -> ConcurrentDictionary, ConcurrentBag, etc.
        // Need FIFO? -> Queue<T>
        // Need LIFO? -> Stack<T>
    }
}
```

---

## 17. How does Dictionary<TKey, TValue> work internally?

**Frequently Asked At:** Microsoft, Product companies

**Answer:**

```csharp
public class DictionaryInternals
{
    /*
    Dictionary uses a hash table with separate chaining:

    1. When you add a key-value pair:
       - GetHashCode() is called on the key
       - Hash is used to find the bucket index
       - Entry is added to that bucket

    2. When buckets have collisions:
       - Multiple entries stored in same bucket (chaining)
       - Equality comparison (Equals) resolves which entry

    3. When load factor exceeded:
       - Dictionary resizes (doubles capacity)
       - All entries are rehashed
       - This is O(n) but amortized O(1)
    */

    // Custom key type - MUST override GetHashCode and Equals
    public class PersonKey : IEquatable<PersonKey>
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }

        public override int GetHashCode()
        {
            // Use HashCode.Combine for proper hash distribution
            return HashCode.Combine(FirstName, LastName);
        }

        public override bool Equals(object obj)
        {
            return Equals(obj as PersonKey);
        }

        public bool Equals(PersonKey other)
        {
            if (other is null) return false;
            return FirstName == other.FirstName && LastName == other.LastName;
        }
    }

    // Demonstrating hash collisions
    public void HashCollisionDemo()
    {
        var dict = new Dictionary<string, int>();

        // These might have same hash but different values
        dict["Aa"] = 1;  // "Aa".GetHashCode() might equal "BB".GetHashCode()
        dict["BB"] = 2;

        // Dictionary handles this with equality check
        Console.WriteLine(dict["Aa"]); // 1
        Console.WriteLine(dict["BB"]); // 2
    }

    // Optimizing dictionary usage
    public void OptimizationTips()
    {
        // 1. Set initial capacity if size is known
        var dict = new Dictionary<string, int>(capacity: 10000);

        // 2. Use TryGetValue instead of ContainsKey + indexer
        // BAD - two lookups
        if (dict.ContainsKey("key"))
        {
            var value = dict["key"];
        }

        // GOOD - single lookup
        if (dict.TryGetValue("key", out var value2))
        {
            // Use value2
        }

        // 3. Use GetValueOrDefault (.NET Core 2.0+)
        var value3 = dict.GetValueOrDefault("key", defaultValue: 0);
    }
}
```

---

# SOLID Principles & Design Patterns

## 18. Explain SOLID principles with code examples

**Frequently Asked At:** All companies - Very common for senior roles

**Answer:**

```csharp
// S - Single Responsibility Principle
// A class should have only one reason to change

// BAD - Multiple responsibilities
public class BadEmployee
{
    public void CalculateSalary() { }
    public void SaveToDatabase() { }
    public void GenerateReport() { }
}

// GOOD - Separated responsibilities
public class Employee
{
    public string Name { get; set; }
    public decimal Salary { get; set; }
}

public class SalaryCalculator
{
    public decimal Calculate(Employee employee) => employee.Salary * 1.1m;
}

public class EmployeeRepository
{
    public void Save(Employee employee) { /* Save to DB */ }
}

public class EmployeeReportGenerator
{
    public string Generate(Employee employee) => $"Report for {employee.Name}";
}

// O - Open/Closed Principle
// Open for extension, closed for modification

// BAD - Need to modify class for new shapes
public class BadAreaCalculator
{
    public double Calculate(object shape)
    {
        if (shape is Rectangle r)
            return r.Width * r.Height;
        else if (shape is Circle c)
            return Math.PI * c.Radius * c.Radius;
        // Need to modify this for every new shape!
        return 0;
    }
}

// GOOD - Extend without modification
public interface IShape
{
    double CalculateArea();
}

public class Rectangle : IShape
{
    public double Width { get; set; }
    public double Height { get; set; }
    public double CalculateArea() => Width * Height;
}

public class Circle : IShape
{
    public double Radius { get; set; }
    public double CalculateArea() => Math.PI * Radius * Radius;
}

// L - Liskov Substitution Principle
// Subtypes must be substitutable for their base types

// BAD - Square violates rectangle's contract
public class BadRectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }
}

public class BadSquare : BadRectangle
{
    public override int Width
    {
        set { base.Width = base.Height = value; }
    }
    public override int Height
    {
        set { base.Width = base.Height = value; }
    }
}

// GOOD - Separate abstractions
public interface IReadOnlyShape
{
    double Area { get; }
}

public class GoodRectangle : IReadOnlyShape
{
    public int Width { get; }
    public int Height { get; }
    public double Area => Width * Height;

    public GoodRectangle(int width, int height)
    {
        Width = width;
        Height = height;
    }
}

public class GoodSquare : IReadOnlyShape
{
    public int Side { get; }
    public double Area => Side * Side;

    public GoodSquare(int side) => Side = side;
}

// I - Interface Segregation Principle
// Clients should not depend on methods they don't use

// BAD - Fat interface
public interface IBadWorker
{
    void Work();
    void Eat();
    void Sleep();
}

public class Robot : IBadWorker
{
    public void Work() { /* OK */ }
    public void Eat() { throw new NotImplementedException(); } // Robots don't eat!
    public void Sleep() { throw new NotImplementedException(); }
}

// GOOD - Segregated interfaces
public interface IWorkable
{
    void Work();
}

public interface IFeedable
{
    void Eat();
}

public class Human : IWorkable, IFeedable
{
    public void Work() { }
    public void Eat() { }
}

public class GoodRobot : IWorkable
{
    public void Work() { }
    // No need to implement Eat!
}

// D - Dependency Inversion Principle
// High-level modules should not depend on low-level modules

// BAD - High-level depends on low-level
public class BadOrderService
{
    private readonly SqlOrderRepository _repository = new SqlOrderRepository();

    public void CreateOrder() { _repository.Save(); }
}

// GOOD - Both depend on abstraction
public interface IOrderRepository
{
    void Save(Order order);
}

public class GoodOrderService
{
    private readonly IOrderRepository _repository;

    public GoodOrderService(IOrderRepository repository)
    {
        _repository = repository;
    }

    public void CreateOrder(Order order)
    {
        _repository.Save(order);
    }
}
```

---

## 19. What design patterns have you used in real projects?

**Frequently Asked At:** All companies - Common senior interview question

**Answer:**

```csharp
// 1. REPOSITORY PATTERN
public interface IRepository<T> where T : class
{
    Task<T> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

public class OrderRepository : IRepository<Order>
{
    private readonly DbContext _context;

    public OrderRepository(DbContext context)
    {
        _context = context;
    }

    public async Task<Order> GetByIdAsync(int id)
    {
        return await _context.Set<Order>().FindAsync(id);
    }

    // ... other implementations
}

// 2. FACTORY PATTERN
public interface INotificationSender
{
    Task SendAsync(string message, string recipient);
}

public class EmailSender : INotificationSender
{
    public Task SendAsync(string message, string recipient)
        => Task.CompletedTask; // Send email
}

public class SmsSender : INotificationSender
{
    public Task SendAsync(string message, string recipient)
        => Task.CompletedTask; // Send SMS
}

public class NotificationFactory
{
    public INotificationSender Create(NotificationType type)
    {
        return type switch
        {
            NotificationType.Email => new EmailSender(),
            NotificationType.Sms => new SmsSender(),
            _ => throw new ArgumentException("Unknown type")
        };
    }
}

// 3. STRATEGY PATTERN
public interface IPaymentStrategy
{
    Task<PaymentResult> ProcessPaymentAsync(decimal amount);
}

public class CreditCardPayment : IPaymentStrategy
{
    public Task<PaymentResult> ProcessPaymentAsync(decimal amount)
    {
        // Process credit card
        return Task.FromResult(new PaymentResult { Success = true });
    }
}

public class PayPalPayment : IPaymentStrategy
{
    public Task<PaymentResult> ProcessPaymentAsync(decimal amount)
    {
        // Process PayPal
        return Task.FromResult(new PaymentResult { Success = true });
    }
}

public class PaymentProcessor
{
    private readonly IPaymentStrategy _strategy;

    public PaymentProcessor(IPaymentStrategy strategy)
    {
        _strategy = strategy;
    }

    public Task<PaymentResult> ProcessAsync(decimal amount)
    {
        return _strategy.ProcessPaymentAsync(amount);
    }
}

// 4. DECORATOR PATTERN
public interface IDataService
{
    Task<string> GetDataAsync(string key);
}

public class DataService : IDataService
{
    public async Task<string> GetDataAsync(string key)
    {
        await Task.Delay(100); // Simulate DB call
        return $"Data for {key}";
    }
}

public class CachingDecorator : IDataService
{
    private readonly IDataService _inner;
    private readonly IMemoryCache _cache;

    public CachingDecorator(IDataService inner, IMemoryCache cache)
    {
        _inner = inner;
        _cache = cache;
    }

    public async Task<string> GetDataAsync(string key)
    {
        return await _cache.GetOrCreateAsync(key, async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5);
            return await _inner.GetDataAsync(key);
        });
    }
}

public class LoggingDecorator : IDataService
{
    private readonly IDataService _inner;
    private readonly ILogger _logger;

    public LoggingDecorator(IDataService inner, ILogger logger)
    {
        _inner = inner;
        _logger = logger;
    }

    public async Task<string> GetDataAsync(string key)
    {
        _logger.LogInformation("Getting data for {Key}", key);
        var result = await _inner.GetDataAsync(key);
        _logger.LogInformation("Retrieved data for {Key}", key);
        return result;
    }
}

// 5. BUILDER PATTERN
public class EmailBuilder
{
    private string _to;
    private string _subject;
    private string _body;
    private List<string> _attachments = new();
    private bool _isHtml;

    public EmailBuilder To(string to)
    {
        _to = to;
        return this;
    }

    public EmailBuilder Subject(string subject)
    {
        _subject = subject;
        return this;
    }

    public EmailBuilder Body(string body, bool isHtml = false)
    {
        _body = body;
        _isHtml = isHtml;
        return this;
    }

    public EmailBuilder WithAttachment(string path)
    {
        _attachments.Add(path);
        return this;
    }

    public Email Build()
    {
        return new Email
        {
            To = _to,
            Subject = _subject,
            Body = _body,
            IsHtml = _isHtml,
            Attachments = _attachments
        };
    }
}

// Usage
var email = new EmailBuilder()
    .To("user@example.com")
    .Subject("Hello")
    .Body("<h1>Welcome</h1>", isHtml: true)
    .WithAttachment("file.pdf")
    .Build();
```

---

# Dependency Injection

## 20. Explain Dependency Injection and its lifetime scopes

**Frequently Asked At:** All companies

**Answer:**

```csharp
// Service Registration in .NET
public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // SINGLETON: One instance for entire application lifetime
        // Use for: Stateless services, caching, configuration
        builder.Services.AddSingleton<ICacheService, MemoryCacheService>();

        // SCOPED: One instance per HTTP request (or scope)
        // Use for: DbContext, repositories, per-request state
        builder.Services.AddScoped<IOrderRepository, OrderRepository>();
        builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

        // TRANSIENT: New instance every time requested
        // Use for: Lightweight, stateless services
        builder.Services.AddTransient<IEmailService, EmailService>();

        var app = builder.Build();
        app.Run();
    }
}

// Common DI Patterns

// 1. Constructor Injection (Preferred)
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly ILogger<OrderService> _logger;

    public OrderService(IOrderRepository repository, ILogger<OrderService> logger)
    {
        _repository = repository;
        _logger = logger;
    }
}

// 2. Method Injection (for occasional dependencies)
public class ReportGenerator
{
    public string Generate(IDataFormatter formatter, Data data)
    {
        return formatter.Format(data);
    }
}

// 3. Property Injection (avoid if possible)
public class LegacyService
{
    public ILogger Logger { get; set; } // Not recommended
}

// 4. Options Pattern for configuration
public class EmailSettings
{
    public string SmtpServer { get; set; }
    public int Port { get; set; }
    public string Username { get; set; }
}

// Registration
// builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("Email"));

public class EmailService
{
    private readonly EmailSettings _settings;

    public EmailService(IOptions<EmailSettings> options)
    {
        _settings = options.Value;
    }
}

// 5. Factory Pattern with DI
public interface IServiceFactory
{
    IService Create(string type);
}

public class ServiceFactory : IServiceFactory
{
    private readonly IServiceProvider _provider;

    public ServiceFactory(IServiceProvider provider)
    {
        _provider = provider;
    }

    public IService Create(string type)
    {
        return type switch
        {
            "A" => _provider.GetRequiredService<ServiceA>(),
            "B" => _provider.GetRequiredService<ServiceB>(),
            _ => throw new ArgumentException($"Unknown type: {type}")
        };
    }
}
```

**Lifetime Scope Pitfalls:**

```csharp
// DANGER: Captive Dependency
// Singleton holding a Scoped dependency - memory leak!
public class BadSingleton
{
    private readonly IOrderRepository _repository; // Scoped - BAD!

    public BadSingleton(IOrderRepository repository)
    {
        _repository = repository; // This instance will live forever
    }
}

// SOLUTION: Use IServiceScopeFactory
public class GoodSingleton
{
    private readonly IServiceScopeFactory _scopeFactory;

    public GoodSingleton(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }

    public async Task DoWorkAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var repository = scope.ServiceProvider.GetRequiredService<IOrderRepository>();
        // Use repository within scope
    }
}
```

---

# Entity Framework Core

## 21. How do you handle the N+1 query problem?

**Frequently Asked At:** All companies - Very common

**Answer:**

```csharp
public class EFCoreNPlusOne
{
    private readonly AppDbContext _context;

    public EFCoreNPlusOne(AppDbContext context)
    {
        _context = context;
    }

    // BAD: N+1 Problem
    public async Task<List<OrderDto>> GetOrdersBad()
    {
        var orders = await _context.Orders.ToListAsync();

        var result = new List<OrderDto>();
        foreach (var order in orders)
        {
            // Each access triggers a separate query!
            var items = order.OrderItems; // Lazy loading = N queries
            result.Add(new OrderDto
            {
                Id = order.Id,
                Items = items.Select(i => i.Name).ToList()
            });
        }
        return result;
    }
    // This executes: 1 query for orders + N queries for items!

    // GOOD: Eager Loading with Include
    public async Task<List<OrderDto>> GetOrdersGood()
    {
        var orders = await _context.Orders
            .Include(o => o.OrderItems) // Single query with JOIN
            .ToListAsync();

        return orders.Select(o => new OrderDto
        {
            Id = o.Id,
            Items = o.OrderItems.Select(i => i.Name).ToList()
        }).ToList();
    }
    // This executes: 1 query with JOIN

    // EVEN BETTER: Projection
    public async Task<List<OrderDto>> GetOrdersBest()
    {
        return await _context.Orders
            .Select(o => new OrderDto
            {
                Id = o.Id,
                Items = o.OrderItems.Select(i => i.Name).ToList()
            })
            .ToListAsync();
    }
    // Only fetches needed columns

    // Split Query (for large includes)
    public async Task<List<Order>> GetOrdersWithSplitQuery()
    {
        return await _context.Orders
            .Include(o => o.OrderItems)
            .Include(o => o.Customer)
            .AsSplitQuery() // Separate queries, avoids cartesian explosion
            .ToListAsync();
    }
}
```

---

## 22. Explain tracking vs no-tracking queries

**Frequently Asked At:** Microsoft, Product companies

**Answer:**

```csharp
public class EFCoreTracking
{
    private readonly AppDbContext _context;

    public EFCoreTracking(AppDbContext context)
    {
        _context = context;
    }

    // TRACKING (default) - EF tracks changes
    public async Task UpdateOrderTracking(int orderId)
    {
        var order = await _context.Orders.FindAsync(orderId);

        order.Status = "Shipped"; // EF detects this change

        await _context.SaveChangesAsync(); // Automatically generates UPDATE
    }

    // NO TRACKING - Better for read-only scenarios
    public async Task<List<OrderDto>> GetOrdersReadOnly()
    {
        return await _context.Orders
            .AsNoTracking() // No change tracking = better performance
            .Select(o => new OrderDto { Id = o.Id, Status = o.Status })
            .ToListAsync();
    }

    // Global no-tracking for read-heavy contexts
    public class ReadOnlyDbContext : DbContext
    {
        public ReadOnlyDbContext(DbContextOptions options) : base(options)
        {
            ChangeTracker.QueryTrackingBehavior = QueryTrackingBehavior.NoTracking;
        }
    }

    // When to use what:
    // Tracking: Updates, inserts, deletes
    // NoTracking: Read-only queries, reports, large data sets
}
```

---

## 23. How do you handle concurrent updates (optimistic concurrency)?

**Frequently Asked At:** Product companies, System design

**Answer:**

```csharp
public class ConcurrencyHandling
{
    // Entity with concurrency token
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }

        [Timestamp] // SQL Server rowversion
        public byte[] RowVersion { get; set; }

        // Or use ConcurrencyCheck attribute
        // [ConcurrencyCheck]
        // public DateTime LastModified { get; set; }
    }

    // Fluent API configuration
    public class ProductConfiguration : IEntityTypeConfiguration<Product>
    {
        public void Configure(EntityTypeBuilder<Product> builder)
        {
            builder.Property(p => p.RowVersion)
                .IsRowVersion();
        }
    }

    // Handling concurrency conflicts
    public async Task UpdateProductAsync(int productId, decimal newPrice)
    {
        var product = await _context.Products.FindAsync(productId);
        product.Price = newPrice;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException ex)
        {
            foreach (var entry in ex.Entries)
            {
                if (entry.Entity is Product)
                {
                    var databaseValues = await entry.GetDatabaseValuesAsync();

                    if (databaseValues == null)
                    {
                        throw new Exception("Product was deleted by another user");
                    }

                    // Strategy 1: Database wins (refresh from DB)
                    entry.OriginalValues.SetValues(databaseValues);

                    // Strategy 2: Client wins (force update)
                    // entry.OriginalValues.SetValues(databaseValues);
                    // await _context.SaveChangesAsync();

                    // Strategy 3: Merge (custom logic)
                    var dbProduct = (Product)databaseValues.ToObject();
                    // Custom merge logic here
                }
            }

            // Retry save
            await _context.SaveChangesAsync();
        }
    }
}
```

---

# ASP.NET Core Web API

## 24. Explain the middleware pipeline

**Frequently Asked At:** All companies

**Answer:**

```csharp
public class MiddlewareExample
{
    public void ConfigureMiddleware(WebApplication app)
    {
        // Middleware executes in order added
        // Request flows down, response flows back up

        /*
        Request  →  Middleware 1  →  Middleware 2  →  Endpoint
                 ←               ←                ←
        Response
        */

        // 1. Exception handling (first - catches all exceptions)
        app.UseExceptionHandler("/error");

        // 2. HTTPS redirection
        app.UseHttpsRedirection();

        // 3. Static files (before routing)
        app.UseStaticFiles();

        // 4. Routing (adds route data to HttpContext)
        app.UseRouting();

        // 5. CORS (must be between UseRouting and UseAuthorization)
        app.UseCors("AllowSpecificOrigin");

        // 6. Authentication (identifies user)
        app.UseAuthentication();

        // 7. Authorization (checks permissions)
        app.UseAuthorization();

        // 8. Custom middleware
        app.UseMiddleware<RequestLoggingMiddleware>();

        // 9. Endpoints
        app.MapControllers();
    }
}

// Custom Middleware
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();

        // Before next middleware
        _logger.LogInformation("Request: {Method} {Path}",
            context.Request.Method,
            context.Request.Path);

        try
        {
            await _next(context); // Call next middleware
        }
        finally
        {
            // After next middleware returns
            stopwatch.Stop();
            _logger.LogInformation("Response: {StatusCode} in {ElapsedMs}ms",
                context.Response.StatusCode,
                stopwatch.ElapsedMilliseconds);
        }
    }
}

// Short-circuiting middleware
public class MaintenanceModeMiddleware
{
    private readonly RequestDelegate _next;
    private readonly bool _isMaintenanceMode;

    public MaintenanceModeMiddleware(RequestDelegate next, IConfiguration config)
    {
        _next = next;
        _isMaintenanceMode = config.GetValue<bool>("MaintenanceMode");
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (_isMaintenanceMode)
        {
            context.Response.StatusCode = 503;
            await context.Response.WriteAsync("Service is under maintenance");
            return; // Short-circuit - don't call _next
        }

        await _next(context);
    }
}
```

---

## 25. How do you implement JWT authentication?

**Frequently Asked At:** All companies

**Answer:**

```csharp
// 1. Install packages
// dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer

// 2. Configure JWT in Program.cs
public class JwtConfiguration
{
    public void ConfigureServices(IServiceCollection services, IConfiguration config)
    {
        var jwtSettings = config.GetSection("JwtSettings");
        var secretKey = jwtSettings["SecretKey"];

        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtSettings["Issuer"],
                ValidAudience = jwtSettings["Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(secretKey)),
                ClockSkew = TimeSpan.Zero // Remove default 5 min tolerance
            };

            options.Events = new JwtBearerEvents
            {
                OnAuthenticationFailed = context =>
                {
                    if (context.Exception is SecurityTokenExpiredException)
                    {
                        context.Response.Headers.Add("Token-Expired", "true");
                    }
                    return Task.CompletedTask;
                }
            };
        });
    }
}

// 3. JWT Token Generator
public class JwtTokenService
{
    private readonly IConfiguration _config;

    public JwtTokenService(IConfiguration config)
    {
        _config = config;
    }

    public string GenerateToken(User user)
    {
        var securityKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_config["JwtSettings:SecretKey"]));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role),
            new Claim("department", user.Department),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: _config["JwtSettings:Issuer"],
            audience: _config["JwtSettings:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public string GenerateRefreshToken()
    {
        var randomBytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomBytes);
        return Convert.ToBase64String(randomBytes);
    }
}

// 4. Auth Controller
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly JwtTokenService _tokenService;
    private readonly IUserService _userService;

    public AuthController(JwtTokenService tokenService, IUserService userService)
    {
        _tokenService = tokenService;
        _userService = userService;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var user = await _userService.ValidateCredentialsAsync(
            request.Email, request.Password);

        if (user == null)
            return Unauthorized("Invalid credentials");

        var token = _tokenService.GenerateToken(user);
        var refreshToken = _tokenService.GenerateRefreshToken();

        // Store refresh token in database
        await _userService.SaveRefreshTokenAsync(user.Id, refreshToken);

        return Ok(new
        {
            AccessToken = token,
            RefreshToken = refreshToken,
            ExpiresIn = 3600
        });
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request)
    {
        var user = await _userService.GetByRefreshTokenAsync(request.RefreshToken);

        if (user == null)
            return Unauthorized("Invalid refresh token");

        var newToken = _tokenService.GenerateToken(user);
        var newRefreshToken = _tokenService.GenerateRefreshToken();

        await _userService.SaveRefreshTokenAsync(user.Id, newRefreshToken);

        return Ok(new { AccessToken = newToken, RefreshToken = newRefreshToken });
    }
}

// 5. Protecting endpoints
[ApiController]
[Route("api/[controller]")]
[Authorize] // Requires authentication
public class OrdersController : ControllerBase
{
    [HttpGet]
    public IActionResult GetOrders()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        // Get orders for user
        return Ok();
    }

    [HttpPost]
    [Authorize(Roles = "Admin")] // Role-based authorization
    public IActionResult CreateOrder()
    {
        return Ok();
    }

    [HttpDelete("{id}")]
    [Authorize(Policy = "CanDeleteOrders")] // Policy-based authorization
    public IActionResult DeleteOrder(int id)
    {
        return Ok();
    }
}
```

---

# Microservices & Distributed Systems

## 26. How do you handle distributed transactions?

**Frequently Asked At:** Product companies, System design interviews

**Answer:**

```csharp
// The Saga Pattern - Choreography vs Orchestration

// 1. CHOREOGRAPHY: Services communicate via events
public class OrderCreatedEvent
{
    public Guid OrderId { get; set; }
    public string CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
}

public class PaymentCompletedEvent
{
    public Guid OrderId { get; set; }
    public Guid PaymentId { get; set; }
}

public class PaymentFailedEvent
{
    public Guid OrderId { get; set; }
    public string Reason { get; set; }
}

// Order Service
public class OrderService
{
    private readonly IEventBus _eventBus;
    private readonly IOrderRepository _repository;

    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order
        {
            Id = Guid.NewGuid(),
            Status = OrderStatus.Pending,
            // ... other properties
        };

        await _repository.SaveAsync(order);

        // Publish event for other services
        await _eventBus.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            CustomerId = request.CustomerId,
            TotalAmount = request.TotalAmount
        });
    }

    // Handle compensation
    public async Task HandlePaymentFailed(PaymentFailedEvent evt)
    {
        var order = await _repository.GetByIdAsync(evt.OrderId);
        order.Status = OrderStatus.Cancelled;
        await _repository.SaveAsync(order);
    }
}

// 2. ORCHESTRATION: Central coordinator
public class OrderSagaOrchestrator
{
    private readonly IOrderService _orderService;
    private readonly IPaymentService _paymentService;
    private readonly IInventoryService _inventoryService;
    private readonly IShippingService _shippingService;

    public async Task<SagaResult> ExecuteOrderSagaAsync(CreateOrderRequest request)
    {
        var sagaState = new OrderSagaState();

        try
        {
            // Step 1: Create Order
            sagaState.OrderId = await _orderService.CreateOrderAsync(request);

            // Step 2: Reserve Inventory
            sagaState.InventoryReserved = await _inventoryService.ReserveAsync(
                request.Items);

            // Step 3: Process Payment
            sagaState.PaymentId = await _paymentService.ProcessAsync(
                request.PaymentInfo, request.TotalAmount);

            // Step 4: Arrange Shipping
            sagaState.ShippingId = await _shippingService.ArrangeAsync(
                sagaState.OrderId);

            // Step 5: Confirm Order
            await _orderService.ConfirmAsync(sagaState.OrderId);

            return SagaResult.Success(sagaState);
        }
        catch (Exception ex)
        {
            // Compensate in reverse order
            await CompensateAsync(sagaState);
            return SagaResult.Failed(ex.Message);
        }
    }

    private async Task CompensateAsync(OrderSagaState state)
    {
        if (state.ShippingId.HasValue)
            await _shippingService.CancelAsync(state.ShippingId.Value);

        if (state.PaymentId.HasValue)
            await _paymentService.RefundAsync(state.PaymentId.Value);

        if (state.InventoryReserved)
            await _inventoryService.ReleaseAsync(state.OrderId);

        if (state.OrderId != Guid.Empty)
            await _orderService.CancelAsync(state.OrderId);
    }
}

// 3. OUTBOX PATTERN - Ensure event publishing with DB transaction
public class OutboxOrderService
{
    private readonly AppDbContext _context;

    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();

        try
        {
            // Create order
            var order = new Order { /* ... */ };
            _context.Orders.Add(order);

            // Add to outbox (same transaction)
            var outboxMessage = new OutboxMessage
            {
                Id = Guid.NewGuid(),
                EventType = nameof(OrderCreatedEvent),
                Payload = JsonSerializer.Serialize(new OrderCreatedEvent
                {
                    OrderId = order.Id
                }),
                CreatedAt = DateTime.UtcNow
            };
            _context.OutboxMessages.Add(outboxMessage);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}

// Background service publishes outbox messages
public class OutboxPublisher : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var messages = await GetUnpublishedMessagesAsync();

            foreach (var message in messages)
            {
                await PublishToEventBusAsync(message);
                await MarkAsPublishedAsync(message.Id);
            }

            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }
}
```

---

## 27. How do you implement the Circuit Breaker pattern?

**Frequently Asked At:** Product companies

**Answer:**

```csharp
// Using Polly library
// dotnet add package Polly
// dotnet add package Microsoft.Extensions.Http.Polly

public class CircuitBreakerSetup
{
    public void ConfigureHttpClients(IServiceCollection services)
    {
        // Define circuit breaker policy
        var circuitBreakerPolicy = Policy<HttpResponseMessage>
            .Handle<HttpRequestException>()
            .OrResult(r => !r.IsSuccessStatusCode)
            .CircuitBreakerAsync(
                handledEventsAllowedBeforeBreaking: 3,  // Open after 3 failures
                durationOfBreak: TimeSpan.FromSeconds(30), // Stay open 30 seconds
                onBreak: (result, duration) =>
                {
                    Console.WriteLine($"Circuit opened for {duration.TotalSeconds}s");
                },
                onReset: () =>
                {
                    Console.WriteLine("Circuit closed");
                },
                onHalfOpen: () =>
                {
                    Console.WriteLine("Circuit half-open, testing...");
                }
            );

        // Retry policy
        var retryPolicy = Policy<HttpResponseMessage>
            .Handle<HttpRequestException>()
            .OrResult(r => r.StatusCode == System.Net.HttpStatusCode.ServiceUnavailable)
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)),
                onRetry: (result, delay, retryCount, context) =>
                {
                    Console.WriteLine($"Retry {retryCount} after {delay.TotalSeconds}s");
                }
            );

        // Timeout policy
        var timeoutPolicy = Policy.TimeoutAsync<HttpResponseMessage>(
            TimeSpan.FromSeconds(10));

        // Combine policies (order matters!)
        var combinedPolicy = Policy.WrapAsync(
            retryPolicy,      // Outermost
            circuitBreakerPolicy,
            timeoutPolicy     // Innermost
        );

        // Register HttpClient with policies
        services.AddHttpClient<IPaymentClient, PaymentClient>(client =>
        {
            client.BaseAddress = new Uri("https://api.payment.com");
            client.Timeout = TimeSpan.FromSeconds(30);
        })
        .AddPolicyHandler(combinedPolicy);
    }
}

// Custom implementation without Polly
public class SimpleCircuitBreaker
{
    private readonly int _failureThreshold;
    private readonly TimeSpan _openDuration;
    private int _failureCount;
    private DateTime _lastFailureTime;
    private CircuitState _state = CircuitState.Closed;
    private readonly object _lock = new();

    public SimpleCircuitBreaker(int failureThreshold, TimeSpan openDuration)
    {
        _failureThreshold = failureThreshold;
        _openDuration = openDuration;
    }

    public async Task<T> ExecuteAsync<T>(Func<Task<T>> action)
    {
        lock (_lock)
        {
            if (_state == CircuitState.Open)
            {
                if (DateTime.UtcNow - _lastFailureTime >= _openDuration)
                {
                    _state = CircuitState.HalfOpen;
                }
                else
                {
                    throw new CircuitBreakerOpenException();
                }
            }
        }

        try
        {
            var result = await action();

            lock (_lock)
            {
                _failureCount = 0;
                _state = CircuitState.Closed;
            }

            return result;
        }
        catch (Exception)
        {
            lock (_lock)
            {
                _failureCount++;
                _lastFailureTime = DateTime.UtcNow;

                if (_failureCount >= _failureThreshold)
                {
                    _state = CircuitState.Open;
                }
            }

            throw;
        }
    }
}

public enum CircuitState { Closed, Open, HalfOpen }
public class CircuitBreakerOpenException : Exception { }
```

---

# System Design Questions

## 28. Design a Rate Limiter

**Frequently Asked At:** Microsoft, Product companies

**Answer:**

```csharp
// 1. Token Bucket Algorithm
public class TokenBucketRateLimiter
{
    private readonly int _maxTokens;
    private readonly int _refillRate; // tokens per second
    private double _currentTokens;
    private DateTime _lastRefillTime;
    private readonly object _lock = new();

    public TokenBucketRateLimiter(int maxTokens, int refillRate)
    {
        _maxTokens = maxTokens;
        _refillRate = refillRate;
        _currentTokens = maxTokens;
        _lastRefillTime = DateTime.UtcNow;
    }

    public bool TryAcquire(int tokens = 1)
    {
        lock (_lock)
        {
            RefillTokens();

            if (_currentTokens >= tokens)
            {
                _currentTokens -= tokens;
                return true;
            }

            return false;
        }
    }

    private void RefillTokens()
    {
        var now = DateTime.UtcNow;
        var elapsed = (now - _lastRefillTime).TotalSeconds;
        var tokensToAdd = elapsed * _refillRate;

        _currentTokens = Math.Min(_maxTokens, _currentTokens + tokensToAdd);
        _lastRefillTime = now;
    }
}

// 2. Sliding Window Rate Limiter
public class SlidingWindowRateLimiter
{
    private readonly int _maxRequests;
    private readonly TimeSpan _window;
    private readonly ConcurrentQueue<DateTime> _requestTimestamps = new();

    public SlidingWindowRateLimiter(int maxRequests, TimeSpan window)
    {
        _maxRequests = maxRequests;
        _window = window;
    }

    public bool TryAcquire()
    {
        var now = DateTime.UtcNow;
        var windowStart = now - _window;

        // Remove expired timestamps
        while (_requestTimestamps.TryPeek(out var oldest) && oldest < windowStart)
        {
            _requestTimestamps.TryDequeue(out _);
        }

        if (_requestTimestamps.Count < _maxRequests)
        {
            _requestTimestamps.Enqueue(now);
            return true;
        }

        return false;
    }
}

// 3. ASP.NET Core Rate Limiting Middleware (.NET 7+)
public class RateLimitingSetup
{
    public void ConfigureRateLimiting(IServiceCollection services)
    {
        services.AddRateLimiter(options =>
        {
            // Fixed window limiter
            options.AddFixedWindowLimiter("fixed", opt =>
            {
                opt.Window = TimeSpan.FromMinutes(1);
                opt.PermitLimit = 100;
                opt.QueueLimit = 0;
            });

            // Sliding window limiter
            options.AddSlidingWindowLimiter("sliding", opt =>
            {
                opt.Window = TimeSpan.FromMinutes(1);
                opt.SegmentsPerWindow = 6; // 10-second segments
                opt.PermitLimit = 100;
            });

            // Token bucket
            options.AddTokenBucketLimiter("token", opt =>
            {
                opt.TokenLimit = 100;
                opt.ReplenishmentPeriod = TimeSpan.FromSeconds(10);
                opt.TokensPerPeriod = 10;
            });

            // Per-user rate limiting
            options.AddPolicy("per-user", context =>
            {
                var userId = context.User.Identity?.Name ?? "anonymous";

                return RateLimitPartition.GetSlidingWindowLimiter(userId, _ =>
                    new SlidingWindowRateLimiterOptions
                    {
                        Window = TimeSpan.FromMinutes(1),
                        SegmentsPerWindow = 6,
                        PermitLimit = 100
                    });
            });

            options.OnRejected = async (context, cancellationToken) =>
            {
                context.HttpContext.Response.StatusCode = 429;
                await context.HttpContext.Response.WriteAsync(
                    "Too many requests. Please try again later.",
                    cancellationToken);
            };
        });
    }

    public void Configure(WebApplication app)
    {
        app.UseRateLimiter();
    }
}

// Usage on controllers
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [EnableRateLimiting("per-user")]
    public IActionResult GetProducts()
    {
        return Ok();
    }

    [HttpPost]
    [DisableRateLimiting] // Exclude from rate limiting
    public IActionResult CreateProduct()
    {
        return Ok();
    }
}
```

---

# Behavioral & Scenario-Based Questions

## 29. How would you diagnose a performance issue in production?

**Frequently Asked At:** All senior roles - Very common

**Answer:**

```csharp
public class ProductionDiagnostics
{
    /*
    Step-by-step approach:

    1. GATHER INFORMATION
       - When did it start?
       - Which endpoints are affected?
       - What changed recently? (deployments, config, traffic)
       - Check monitoring dashboards (APM, metrics)

    2. CHECK METRICS
       - CPU, Memory, Disk I/O, Network
       - Request latency percentiles (p50, p95, p99)
       - Error rates
       - Database query times
       - External service response times

    3. ANALYZE LOGS
       - Look for errors, warnings
       - Correlate with timestamp of issue
       - Check for patterns (specific user, endpoint, etc.)

    4. PROFILING (if needed)
       - Memory profiler (dotMemory, PerfView)
       - CPU profiler (dotTrace, PerfView)
       - Database query analysis

    5. COMMON CAUSES & SOLUTIONS
    */

    // Example: Adding diagnostics to identify slow operations
    public class DiagnosticMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<DiagnosticMiddleware> _logger;

        public DiagnosticMiddleware(RequestDelegate next, ILogger<DiagnosticMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var stopwatch = Stopwatch.StartNew();
            var requestId = Guid.NewGuid().ToString();

            // Add correlation ID
            context.Response.Headers.Add("X-Request-Id", requestId);

            using (_logger.BeginScope(new Dictionary<string, object>
            {
                ["RequestId"] = requestId,
                ["Path"] = context.Request.Path
            }))
            {
                try
                {
                    await _next(context);
                }
                finally
                {
                    stopwatch.Stop();

                    var level = stopwatch.ElapsedMilliseconds > 1000
                        ? LogLevel.Warning
                        : LogLevel.Information;

                    _logger.Log(level,
                        "Request {Method} {Path} completed in {ElapsedMs}ms with status {StatusCode}",
                        context.Request.Method,
                        context.Request.Path,
                        stopwatch.ElapsedMilliseconds,
                        context.Response.StatusCode);
                }
            }
        }
    }

    // Database query logging
    public class SlowQueryInterceptor : DbCommandInterceptor
    {
        private readonly ILogger _logger;
        private readonly int _slowQueryThresholdMs;

        public SlowQueryInterceptor(ILogger logger, int slowQueryThresholdMs = 100)
        {
            _logger = logger;
            _slowQueryThresholdMs = slowQueryThresholdMs;
        }

        public override ValueTask<DbDataReader> ReaderExecutedAsync(
            DbCommand command,
            CommandExecutedEventData eventData,
            DbDataReader result,
            CancellationToken cancellationToken = default)
        {
            if (eventData.Duration.TotalMilliseconds > _slowQueryThresholdMs)
            {
                _logger.LogWarning(
                    "Slow query detected ({ElapsedMs}ms): {Query}",
                    eventData.Duration.TotalMilliseconds,
                    command.CommandText);
            }

            return base.ReaderExecutedAsync(command, eventData, result, cancellationToken);
        }
    }
}
```

---

## 30. Tell me about a challenging bug you solved

**Frequently Asked At:** All companies

**Sample Answer Structure:**

```
SITUATION:
"In our e-commerce platform, we noticed intermittent 500 errors during checkout,
affecting about 2% of transactions. The issue was hard to reproduce locally."

TASK:
"As the senior developer, I was responsible for identifying and fixing this
critical issue that was impacting revenue."

ACTION:
"1. Added detailed logging around the payment flow
 2. Analyzed Application Insights traces and found the errors correlated with
    high traffic periods
 3. Discovered a race condition in our inventory check - two concurrent requests
    could both pass the 'in stock' check for the last item
 4. Implemented optimistic concurrency with a retry mechanism using a version
    field in the database"

RESULT:
"The fix reduced checkout errors to near zero. I also added integration tests
for concurrent scenarios and documented the pattern for the team to prevent
similar issues."
```

**Code example for the fix:**

```csharp
public class InventoryService
{
    private readonly AppDbContext _context;
    private readonly ILogger<InventoryService> _logger;

    // Before: Race condition possible
    public async Task<bool> ReserveInventoryBad(int productId, int quantity)
    {
        var product = await _context.Products.FindAsync(productId);

        if (product.StockQuantity >= quantity)
        {
            product.StockQuantity -= quantity;
            await _context.SaveChangesAsync();
            return true;
        }

        return false;
    }

    // After: Optimistic concurrency with retry
    public async Task<bool> ReserveInventoryGood(int productId, int quantity, int maxRetries = 3)
    {
        for (int attempt = 0; attempt < maxRetries; attempt++)
        {
            try
            {
                var product = await _context.Products
                    .Where(p => p.Id == productId && p.StockQuantity >= quantity)
                    .FirstOrDefaultAsync();

                if (product == null)
                    return false;

                product.StockQuantity -= quantity;

                // RowVersion will cause concurrency exception if changed
                await _context.SaveChangesAsync();
                return true;
            }
            catch (DbUpdateConcurrencyException ex)
            {
                _logger.LogWarning(
                    "Concurrency conflict on attempt {Attempt} for product {ProductId}",
                    attempt + 1, productId);

                // Refresh and retry
                foreach (var entry in ex.Entries)
                {
                    await entry.ReloadAsync();
                }
            }
        }

        _logger.LogError("Failed to reserve inventory after {MaxRetries} attempts", maxRetries);
        return false;
    }
}
```

---

## Quick Reference: Most Frequently Asked Topics by Company Type

### Service-Based Companies (TCS, Infosys, Wipro, Cognizant)
1. OOP concepts (class vs interface, overloading vs overriding)
2. SQL queries and database concepts
3. Web API basics
4. Entity Framework basics
5. String vs StringBuilder
6. Value types vs Reference types

### Product-Based Companies (Microsoft, Startups)
1. Async/await and threading
2. Memory management and GC
3. System design (rate limiter, distributed systems)
4. Design patterns in real projects
5. Performance optimization
6. Debugging production issues

### Common Across All
1. SOLID principles
2. Dependency Injection
3. Collections performance
4. Exception handling
5. JWT authentication
6. RESTful API design

---

# LINQ Interview Questions

## 31. What is the difference between `IEnumerable` and `IQueryable`?

**Frequently Asked At:** All companies - Very common

**Answer:**

```csharp
public class EnumerableVsQueryable
{
    private readonly AppDbContext _context;

    // IEnumerable - Executes in memory
    public void IEnumerableExample()
    {
        IEnumerable<Order> orders = _context.Orders;

        // Filter happens IN MEMORY after loading ALL data
        var filtered = orders.Where(o => o.Total > 100);

        // SQL: SELECT * FROM Orders (loads everything!)
        foreach (var order in filtered) { }
    }

    // IQueryable - Executes on database
    public void IQueryableExample()
    {
        IQueryable<Order> orders = _context.Orders;

        // Filter is translated to SQL
        var filtered = orders.Where(o => o.Total > 100);

        // SQL: SELECT * FROM Orders WHERE Total > 100
        foreach (var order in filtered) { }
    }

    // Real-world impact
    public List<Order> GetExpensiveOrders_Bad()
    {
        // BAD: Loads all orders, then filters in memory
        IEnumerable<Order> allOrders = _context.Orders.ToList();
        return allOrders.Where(o => o.Total > 1000).ToList();
    }

    public List<Order> GetExpensiveOrders_Good()
    {
        // GOOD: Filter on database, only load matching records
        return _context.Orders.Where(o => o.Total > 1000).ToList();
    }
}
```

| Feature | IEnumerable | IQueryable |
|---------|-------------|------------|
| Namespace | System.Collections.Generic | System.Linq |
| Execution | In-memory | Deferred to provider |
| Best for | In-memory collections | Database queries |
| LINQ Provider | LINQ to Objects | LINQ to SQL/Entities |
| Performance | Loads all data first | Optimized queries |

---

## 32. Explain deferred execution in LINQ

**Frequently Asked At:** Microsoft, Product companies

**Answer:**

```csharp
public class DeferredExecution
{
    // Deferred execution - query is NOT executed when defined
    public void DeferredExample()
    {
        var numbers = new List<int> { 1, 2, 3, 4, 5 };

        // Query is defined but NOT executed yet
        var query = numbers.Where(n => n > 2);

        // Modify the source
        numbers.Add(6);

        // Query executes NOW - includes 6!
        foreach (var n in query)
        {
            Console.WriteLine(n); // 3, 4, 5, 6
        }
    }

    // Immediate execution - forces evaluation
    public void ImmediateExample()
    {
        var numbers = new List<int> { 1, 2, 3, 4, 5 };

        // ToList() forces immediate execution
        var result = numbers.Where(n => n > 2).ToList();

        // Modify the source
        numbers.Add(6);

        // Result was already captured - does NOT include 6
        foreach (var n in result)
        {
            Console.WriteLine(n); // 3, 4, 5
        }
    }

    // Methods that force immediate execution:
    // ToList(), ToArray(), ToDictionary(), ToHashSet()
    // Count(), Sum(), Max(), Min(), Average()
    // First(), FirstOrDefault(), Single(), SingleOrDefault()
    // Any(), All()
}
```

---

## 33. What is the difference between `Select` and `SelectMany`?

**Frequently Asked At:** All companies

**Answer:**

```csharp
public class SelectVsSelectMany
{
    public void Demonstrate()
    {
        var customers = new List<Customer>
        {
            new Customer { Name = "John", Orders = new List<string> { "Order1", "Order2" } },
            new Customer { Name = "Jane", Orders = new List<string> { "Order3" } }
        };

        // SELECT - Returns IEnumerable<IEnumerable<string>>
        var selectResult = customers.Select(c => c.Orders);
        // Result: [ ["Order1", "Order2"], ["Order3"] ]

        // SELECTMANY - Flattens to IEnumerable<string>
        var selectManyResult = customers.SelectMany(c => c.Orders);
        // Result: [ "Order1", "Order2", "Order3" ]

        // Practical example: Get all words from sentences
        var sentences = new[] { "Hello World", "LINQ is powerful" };

        var words = sentences.SelectMany(s => s.Split(' '));
        // Result: [ "Hello", "World", "LINQ", "is", "powerful" ]
    }

    // With index
    public void SelectManyWithIndex()
    {
        var departments = new[]
        {
            new { Name = "IT", Employees = new[] { "Alice", "Bob" } },
            new { Name = "HR", Employees = new[] { "Charlie" } }
        };

        var result = departments.SelectMany(
            (dept, deptIndex) => dept.Employees,
            (dept, emp) => new { Department = dept.Name, Employee = emp }
        );

        // Result: [{ IT, Alice }, { IT, Bob }, { HR, Charlie }]
    }
}

class Customer
{
    public string Name { get; set; }
    public List<string> Orders { get; set; }
}
```

---

## 34. How do you optimize LINQ queries?

**Frequently Asked At:** Senior roles at all companies

**Answer:**

```csharp
public class LinqOptimization
{
    private readonly AppDbContext _context;

    // 1. Use Any() instead of Count() > 0
    public bool HasOrders_Bad(int customerId)
    {
        return _context.Orders.Count(o => o.CustomerId == customerId) > 0;
        // Counts ALL matching records
    }

    public bool HasOrders_Good(int customerId)
    {
        return _context.Orders.Any(o => o.CustomerId == customerId);
        // Stops at first match
    }

    // 2. Use FirstOrDefault instead of Where().FirstOrDefault()
    public Order GetOrder_Bad(int id)
    {
        return _context.Orders.Where(o => o.Id == id).FirstOrDefault();
    }

    public Order GetOrder_Good(int id)
    {
        return _context.Orders.FirstOrDefault(o => o.Id == id);
    }

    // 3. Project only needed columns
    public List<string> GetOrderNumbers_Bad()
    {
        return _context.Orders.ToList().Select(o => o.OrderNumber).ToList();
        // Loads ALL columns, then selects in memory
    }

    public List<string> GetOrderNumbers_Good()
    {
        return _context.Orders.Select(o => o.OrderNumber).ToList();
        // SQL: SELECT OrderNumber FROM Orders
    }

    // 4. Use compiled queries for frequently executed queries
    private static readonly Func<AppDbContext, int, Order> GetOrderById =
        EF.CompileQuery((AppDbContext context, int id) =>
            context.Orders.FirstOrDefault(o => o.Id == id));

    public Order GetOrderCompiled(int id)
    {
        return GetOrderById(_context, id);
    }

    // 5. Avoid multiple enumerations
    public void AvoidMultipleEnumerations_Bad(IEnumerable<int> numbers)
    {
        if (numbers.Any()) // First enumeration
        {
            var sum = numbers.Sum(); // Second enumeration
            var count = numbers.Count(); // Third enumeration
        }
    }

    public void AvoidMultipleEnumerations_Good(IEnumerable<int> numbers)
    {
        var list = numbers.ToList(); // Materialize once
        if (list.Any())
        {
            var sum = list.Sum();
            var count = list.Count;
        }
    }

    // 6. Use AsNoTracking for read-only queries
    public List<Order> GetOrdersReadOnly()
    {
        return _context.Orders.AsNoTracking().ToList();
    }
}
```

---

## 35. Explain GroupBy and common use cases

**Frequently Asked At:** All companies

**Answer:**

```csharp
public class GroupByExamples
{
    public void BasicGroupBy()
    {
        var orders = new List<Order>
        {
            new Order { CustomerId = 1, Total = 100 },
            new Order { CustomerId = 1, Total = 200 },
            new Order { CustomerId = 2, Total = 150 }
        };

        // Group by customer
        var grouped = orders.GroupBy(o => o.CustomerId);

        foreach (var group in grouped)
        {
            Console.WriteLine($"Customer {group.Key}:");
            foreach (var order in group)
            {
                Console.WriteLine($"  Order Total: {order.Total}");
            }
        }
    }

    // GroupBy with aggregation
    public void GroupByWithAggregation()
    {
        var sales = GetSales();

        var summary = sales
            .GroupBy(s => s.Category)
            .Select(g => new
            {
                Category = g.Key,
                TotalSales = g.Sum(s => s.Amount),
                AverageSale = g.Average(s => s.Amount),
                Count = g.Count()
            })
            .OrderByDescending(x => x.TotalSales);
    }

    // GroupBy with multiple keys
    public void GroupByMultipleKeys()
    {
        var sales = GetSales();

        var grouped = sales.GroupBy(s => new { s.Year, s.Category })
            .Select(g => new
            {
                g.Key.Year,
                g.Key.Category,
                Total = g.Sum(s => s.Amount)
            });
    }

    // GroupBy with ToDictionary
    public Dictionary<string, List<Order>> GroupToDictionary()
    {
        var orders = GetOrders();

        return orders
            .GroupBy(o => o.Status)
            .ToDictionary(g => g.Key, g => g.ToList());
    }

    // Lookup - similar to GroupBy but for repeated queries
    public void UsingLookup()
    {
        var orders = GetOrders();

        // ToLookup creates an in-memory lookup table
        var lookup = orders.ToLookup(o => o.CustomerId);

        // Fast repeated access
        var customer1Orders = lookup[1];
        var customer2Orders = lookup[2];
    }

    private IEnumerable<Sale> GetSales() => new List<Sale>();
    private IEnumerable<Order> GetOrders() => new List<Order>();
}
```

---

# Modern C# Features (.NET 6/7/8)

## 36. What is the difference between `record`, `class`, and `struct`?

**Frequently Asked At:** All companies - Very common in 2024/2025

**Answer:**

```csharp
// CLASS - Reference type, mutable by default
public class PersonClass
{
    public string Name { get; set; }
    public int Age { get; set; }

    // Must manually implement equality
    public override bool Equals(object obj)
    {
        if (obj is PersonClass other)
            return Name == other.Name && Age == other.Age;
        return false;
    }

    public override int GetHashCode() => HashCode.Combine(Name, Age);
}

// RECORD - Reference type, immutable by default, value-based equality
public record PersonRecord(string Name, int Age);
// Compiler generates: Equals, GetHashCode, ToString, Deconstruct

// RECORD STRUCT (C# 10+) - Value type record
public record struct Point(int X, int Y);

// STRUCT - Value type, mutable by default
public struct PersonStruct
{
    public string Name { get; set; }
    public int Age { get; set; }
}

// READONLY STRUCT - Immutable value type
public readonly struct ImmutablePoint
{
    public int X { get; }
    public int Y { get; }

    public ImmutablePoint(int x, int y) => (X, Y) = (x, y);
}

// Demonstration
public class RecordFeatures
{
    public void DemonstrateRecords()
    {
        // 1. Value-based equality
        var person1 = new PersonRecord("John", 30);
        var person2 = new PersonRecord("John", 30);
        Console.WriteLine(person1 == person2); // True (compares values)

        // 2. Non-destructive mutation with 'with'
        var person3 = person1 with { Age = 31 };
        // person1 is unchanged, person3 is new instance

        // 3. Deconstruction
        var (name, age) = person1;

        // 4. ToString() auto-generated
        Console.WriteLine(person1); // PersonRecord { Name = John, Age = 30 }
    }
}
```

**When to use each:**

| Type | Use Case |
|------|----------|
| `class` | Complex behavior, identity-based, mutable state |
| `record` | DTOs, immutable data, value semantics |
| `record struct` | Small immutable data, performance-critical |
| `struct` | Small mutable data, performance-critical |
| `readonly struct` | Small immutable data, pass-by-value |

---

## 37. Explain pattern matching in C#

**Frequently Asked At:** Microsoft, Product companies

**Answer:**

```csharp
public class PatternMatchingExamples
{
    // 1. Type pattern
    public string GetDescription(object obj)
    {
        return obj switch
        {
            string s => $"String of length {s.Length}",
            int i => $"Integer: {i}",
            List<int> list => $"List with {list.Count} items",
            null => "Null value",
            _ => "Unknown type"
        };
    }

    // 2. Property pattern
    public decimal CalculateDiscount(Order order)
    {
        return order switch
        {
            { Total: > 1000, IsPremiumCustomer: true } => order.Total * 0.20m,
            { Total: > 1000 } => order.Total * 0.10m,
            { Total: > 500 } => order.Total * 0.05m,
            { IsPremiumCustomer: true } => order.Total * 0.03m,
            _ => 0
        };
    }

    // 3. Relational pattern (C# 9+)
    public string GetGrade(int score)
    {
        return score switch
        {
            >= 90 => "A",
            >= 80 and < 90 => "B",
            >= 70 and < 80 => "C",
            >= 60 and < 70 => "D",
            < 60 => "F"
        };
    }

    // 4. List pattern (C# 11+)
    public string DescribeArray(int[] numbers)
    {
        return numbers switch
        {
            [] => "Empty array",
            [var single] => $"Single element: {single}",
            [var first, var second] => $"Two elements: {first}, {second}",
            [var first, .., var last] => $"First: {first}, Last: {last}",
            _ => "Other"
        };
    }

    // 5. Logical patterns
    public bool IsValidAge(int age)
    {
        return age is >= 0 and <= 120;
    }

    // 6. Positional pattern with deconstruction
    public string DescribePoint(Point point)
    {
        return point switch
        {
            (0, 0) => "Origin",
            (var x, 0) => $"On X-axis at {x}",
            (0, var y) => $"On Y-axis at {y}",
            (var x, var y) when x == y => $"On diagonal at ({x}, {y})",
            (var x, var y) => $"Point at ({x}, {y})"
        };
    }

    // 7. Nested pattern
    public string ProcessOrder(Order order)
    {
        return order switch
        {
            { Customer: { IsPremium: true }, Total: > 1000 }
                => "VIP order",
            { Status: OrderStatus.Shipped, ShippingInfo: { TrackingNumber: not null } }
                => "Shipped with tracking",
            _ => "Regular order"
        };
    }
}

public record Point(int X, int Y);
```

---

## 38. What are the new features in .NET 8?

**Frequently Asked At:** Interviews in 2024/2025

**Answer:**

```csharp
public class DotNet8Features
{
    // 1. Primary Constructors for classes (C# 12)
    public class Person(string name, int age)
    {
        public string Name { get; } = name;
        public int Age { get; } = age;

        public void Greet() => Console.WriteLine($"Hello, {name}!");
    }

    // 2. Collection expressions (C# 12)
    public void CollectionExpressions()
    {
        // Old way
        int[] oldArray = new int[] { 1, 2, 3 };
        List<int> oldList = new List<int> { 1, 2, 3 };

        // New way
        int[] newArray = [1, 2, 3];
        List<int> newList = [1, 2, 3];

        // Spread operator
        int[] combined = [..newArray, 4, 5, ..newList];
    }

    // 3. Default lambda parameters (C# 12)
    public void DefaultLambdaParams()
    {
        var greet = (string name = "World") => $"Hello, {name}!";

        Console.WriteLine(greet());       // "Hello, World!"
        Console.WriteLine(greet("John")); // "Hello, John!"
    }

    // 4. Alias any type (C# 12)
    // using Point = (int X, int Y);
    // using Json = System.Text.Json.JsonSerializer;

    // 5. Inline arrays (C# 12) - for performance
    [System.Runtime.CompilerServices.InlineArray(10)]
    public struct TenIntegers
    {
        private int _element;
    }

    // 6. Frozen collections - Immutable and optimized for read
    public void FrozenCollections()
    {
        var dict = new Dictionary<string, int>
        {
            ["one"] = 1,
            ["two"] = 2
        };

        // Create frozen (optimized for lookup)
        var frozen = dict.ToFrozenDictionary();

        // Faster lookups but cannot be modified
        var value = frozen["one"];
    }

    // 7. TimeProvider for testable time
    public class OrderService
    {
        private readonly TimeProvider _timeProvider;

        public OrderService(TimeProvider timeProvider)
        {
            _timeProvider = timeProvider;
        }

        public bool IsExpired(Order order)
        {
            return _timeProvider.GetUtcNow() > order.ExpiresAt;
        }
    }

    // 8. Native AOT improvements
    // Better support for reflection-free compilation

    // 9. Keyed Services in DI
    public void KeyedServices(IServiceCollection services)
    {
        services.AddKeyedSingleton<INotificationService, EmailService>("email");
        services.AddKeyedSingleton<INotificationService, SmsService>("sms");
    }

    public class NotificationController
    {
        public NotificationController(
            [FromKeyedServices("email")] INotificationService emailService,
            [FromKeyedServices("sms")] INotificationService smsService)
        {
        }
    }
}
```

---

# SQL Server for .NET Developers

## 39. Explain different types of indexes and when to use them

**Frequently Asked At:** All companies

**Answer:**

```sql
-- 1. CLUSTERED INDEX
-- Physical order of data matches index order
-- Only ONE per table (usually on Primary Key)
CREATE CLUSTERED INDEX IX_Orders_OrderId ON Orders(OrderId);

-- 2. NON-CLUSTERED INDEX
-- Separate structure pointing to data rows
-- Multiple allowed per table
CREATE NONCLUSTERED INDEX IX_Orders_CustomerId ON Orders(CustomerId);

-- 3. COVERING INDEX (with INCLUDE)
-- Includes non-key columns to avoid table lookups
CREATE NONCLUSTERED INDEX IX_Orders_CustomerId_Covered
ON Orders(CustomerId)
INCLUDE (OrderDate, Total, Status);

-- Query can be satisfied entirely from index:
SELECT CustomerId, OrderDate, Total, Status
FROM Orders
WHERE CustomerId = 123;

-- 4. FILTERED INDEX
-- Index on subset of rows
CREATE NONCLUSTERED INDEX IX_Orders_Active
ON Orders(OrderDate)
WHERE Status = 'Active';

-- 5. COMPOSITE INDEX
-- Multiple columns
CREATE NONCLUSTERED INDEX IX_Orders_Customer_Date
ON Orders(CustomerId, OrderDate DESC);

-- Column order matters! This index helps:
-- WHERE CustomerId = 123
-- WHERE CustomerId = 123 AND OrderDate > '2024-01-01'
-- But NOT: WHERE OrderDate > '2024-01-01' (without CustomerId)
```

**C# Code for analyzing indexes:**

```csharp
public class IndexAnalysis
{
    private readonly AppDbContext _context;

    // Check if query uses index
    public async Task AnalyzeQueryPlan(int customerId)
    {
        var query = _context.Orders
            .Where(o => o.CustomerId == customerId)
            .Select(o => new { o.OrderDate, o.Total });

        // Get SQL and analyze
        var sql = query.ToQueryString();
        Console.WriteLine(sql);

        // In SSMS, run with:
        // SET STATISTICS IO ON
        // SET STATISTICS TIME ON
        // Your query here
    }

    // Missing index recommendations
    public string GetMissingIndexes()
    {
        return @"
            SELECT
                'CREATE INDEX IX_' + OBJECT_NAME(mid.object_id) + '_' +
                REPLACE(mid.equality_columns, ', ', '_')
                AS CreateStatement,
                mid.equality_columns,
                mid.inequality_columns,
                mid.included_columns,
                migs.avg_user_impact
            FROM sys.dm_db_missing_index_details mid
            JOIN sys.dm_db_missing_index_groups mig
                ON mid.index_handle = mig.index_handle
            JOIN sys.dm_db_missing_index_group_stats migs
                ON mig.index_group_handle = migs.group_handle
            ORDER BY migs.avg_user_impact DESC";
    }
}
```

---

## 40. Write optimized SQL queries for common scenarios

**Frequently Asked At:** All companies

**Answer:**

```csharp
public class SqlOptimization
{
    // 1. PAGINATION - Offset vs Keyset
    public async Task<List<Order>> GetOrdersPaginated_Bad(int page, int pageSize)
    {
        // BAD: OFFSET becomes slow on large datasets
        return await _context.Orders
            .OrderBy(o => o.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<List<Order>> GetOrdersPaginated_Good(int lastId, int pageSize)
    {
        // GOOD: Keyset pagination using index
        return await _context.Orders
            .Where(o => o.Id > lastId)
            .OrderBy(o => o.Id)
            .Take(pageSize)
            .ToListAsync();
    }

    // 2. BATCH OPERATIONS
    public async Task UpdateOrderStatus_Bad(List<int> orderIds, string status)
    {
        // BAD: N+1 updates
        foreach (var id in orderIds)
        {
            var order = await _context.Orders.FindAsync(id);
            order.Status = status;
            await _context.SaveChangesAsync();
        }
    }

    public async Task UpdateOrderStatus_Good(List<int> orderIds, string status)
    {
        // GOOD: Single batch update (EF Core 7+)
        await _context.Orders
            .Where(o => orderIds.Contains(o.Id))
            .ExecuteUpdateAsync(s => s.SetProperty(o => o.Status, status));
    }

    // 3. AVOIDING SELECT N+1
    public async Task<List<CustomerSummary>> GetCustomerSummaries_Good()
    {
        // Single query with aggregation
        return await _context.Customers
            .Select(c => new CustomerSummary
            {
                CustomerId = c.Id,
                Name = c.Name,
                OrderCount = c.Orders.Count(),
                TotalSpent = c.Orders.Sum(o => o.Total)
            })
            .ToListAsync();
    }

    // 4. USING RAW SQL FOR COMPLEX QUERIES
    public async Task<List<SalesReport>> GetSalesReport()
    {
        return await _context.Database
            .SqlQuery<SalesReport>($@"
                SELECT
                    YEAR(OrderDate) AS Year,
                    MONTH(OrderDate) AS Month,
                    COUNT(*) AS OrderCount,
                    SUM(Total) AS TotalSales
                FROM Orders
                WHERE Status = 'Completed'
                GROUP BY YEAR(OrderDate), MONTH(OrderDate)
                ORDER BY Year DESC, Month DESC")
            .ToListAsync();
    }
}

// Common SQL patterns
public class SqlPatterns
{
    /*
    -- Find duplicates
    SELECT Email, COUNT(*) as Count
    FROM Users
    GROUP BY Email
    HAVING COUNT(*) > 1;

    -- Delete duplicates (keep lowest ID)
    WITH CTE AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY Email ORDER BY Id) AS rn
        FROM Users
    )
    DELETE FROM CTE WHERE rn > 1;

    -- Running total
    SELECT
        OrderDate,
        Total,
        SUM(Total) OVER (ORDER BY OrderDate) AS RunningTotal
    FROM Orders;

    -- Get top N per group
    WITH RankedOrders AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY Total DESC) AS rn
        FROM Orders
    )
    SELECT * FROM RankedOrders WHERE rn <= 3;
    */
}
```

---

# Coding Problems & LeetCode Patterns

## 41. Common coding patterns for .NET interviews

**Frequently Asked At:** Amazon, Microsoft, Product companies

**Answer:**

```csharp
public class CodingPatterns
{
    // 1. TWO POINTERS
    public bool IsPalindrome(string s)
    {
        int left = 0, right = s.Length - 1;

        while (left < right)
        {
            while (left < right && !char.IsLetterOrDigit(s[left])) left++;
            while (left < right && !char.IsLetterOrDigit(s[right])) right--;

            if (char.ToLower(s[left]) != char.ToLower(s[right]))
                return false;

            left++;
            right--;
        }

        return true;
    }

    // 2. SLIDING WINDOW
    public int MaxSumSubarray(int[] nums, int k)
    {
        int windowSum = 0;
        int maxSum = int.MinValue;

        for (int i = 0; i < nums.Length; i++)
        {
            windowSum += nums[i];

            if (i >= k - 1)
            {
                maxSum = Math.Max(maxSum, windowSum);
                windowSum -= nums[i - (k - 1)];
            }
        }

        return maxSum;
    }

    // 3. HASHMAP FOR O(1) LOOKUP
    public int[] TwoSum(int[] nums, int target)
    {
        var map = new Dictionary<int, int>();

        for (int i = 0; i < nums.Length; i++)
        {
            int complement = target - nums[i];

            if (map.TryGetValue(complement, out int index))
                return new[] { index, i };

            map[nums[i]] = i;
        }

        return Array.Empty<int>();
    }

    // 4. BFS/DFS for Graphs
    public int NumberOfIslands(char[][] grid)
    {
        if (grid == null || grid.Length == 0) return 0;

        int count = 0;
        int rows = grid.Length, cols = grid[0].Length;

        for (int i = 0; i < rows; i++)
        {
            for (int j = 0; j < cols; j++)
            {
                if (grid[i][j] == '1')
                {
                    count++;
                    DFS(grid, i, j);
                }
            }
        }

        return count;
    }

    private void DFS(char[][] grid, int i, int j)
    {
        if (i < 0 || i >= grid.Length || j < 0 || j >= grid[0].Length || grid[i][j] != '1')
            return;

        grid[i][j] = '0'; // Mark visited

        DFS(grid, i + 1, j);
        DFS(grid, i - 1, j);
        DFS(grid, i, j + 1);
        DFS(grid, i, j - 1);
    }

    // 5. BINARY SEARCH
    public int BinarySearch(int[] nums, int target)
    {
        int left = 0, right = nums.Length - 1;

        while (left <= right)
        {
            int mid = left + (right - left) / 2;

            if (nums[mid] == target)
                return mid;
            else if (nums[mid] < target)
                left = mid + 1;
            else
                right = mid - 1;
        }

        return -1;
    }

    // 6. DYNAMIC PROGRAMMING
    public int ClimbStairs(int n)
    {
        if (n <= 2) return n;

        int prev1 = 1, prev2 = 2;

        for (int i = 3; i <= n; i++)
        {
            int current = prev1 + prev2;
            prev1 = prev2;
            prev2 = current;
        }

        return prev2;
    }

    // 7. LINKED LIST MANIPULATION
    public ListNode ReverseLinkedList(ListNode head)
    {
        ListNode prev = null;
        ListNode current = head;

        while (current != null)
        {
            ListNode next = current.next;
            current.next = prev;
            prev = current;
            current = next;
        }

        return prev;
    }

    // 8. STRING MANIPULATION - Anagram Check
    public bool IsAnagram(string s, string t)
    {
        if (s.Length != t.Length) return false;

        var count = new int[26];

        foreach (char c in s)
            count[c - 'a']++;

        foreach (char c in t)
        {
            count[c - 'a']--;
            if (count[c - 'a'] < 0) return false;
        }

        return true;
    }
}

public class ListNode
{
    public int val;
    public ListNode next;
    public ListNode(int val = 0, ListNode next = null)
    {
        this.val = val;
        this.next = next;
    }
}
```

---

# Real Interview Experiences

## Amazon .NET Developer Interview

**Source:** [LeetCode Discuss](https://leetcode.com/discuss/), [Medium](https://medium.com/)

**Interview Structure:**
1. Online Assessment (2 coding questions - 70 mins)
2. Phone Screen (1 coding + Leadership Principles)
3. On-site Loop (4-5 rounds: 2 coding, 1 system design, 2 behavioral)

**Common Questions:**
- LeetCode Medium/Hard (Arrays, Trees, DP)
- System Design: Design a CDN, Rate Limiter, URL Shortener
- Leadership Principles: Tell me about a time when...

**Tips:**
- Practice STAR format for behavioral questions
- Know Amazon's Leadership Principles
- Focus on: Arrays, Trees, Graphs, Dynamic Programming

---

## Microsoft .NET Developer Interview

**Source:** [Glassdoor](https://www.glassdoor.com/)

**Interview Structure:**
1. Phone Screen (45 mins - coding + discussion)
2. Virtual/On-site Loop (4-5 rounds)

**Common Questions:**
- Design patterns (asked to implement on whiteboard)
- Async/await deep dive
- System design for distributed systems
- SQL optimization scenarios
- Live coding: Implement LRU Cache, Design patterns

**Tips:**
- Understand Azure services
- Know EF Core internals
- Be ready to discuss production debugging experiences

---

## Service Company Interview Tips (TCS, Infosys, Wipro)

**Focus Areas:**
1. OOP fundamentals (be ready to explain with examples)
2. SQL queries (JOINs, GROUP BY, Subqueries)
3. Web API basics (REST principles, HTTP methods)
4. Entity Framework basics
5. Recent project discussion

**Sample Questions:**
- "Explain the ASP.NET MVC lifecycle"
- "What is the difference between Abstract class and Interface?"
- "Write a SQL query to find the second highest salary"
- "How does dependency injection work?"

---

## Additional Resources

- [CodeJourney - Real .NET Interview Questions](https://www.codejourney.net/real-net-interview-questions-2024-2025/)
- [Glassdoor - .NET Developer Interviews](https://www.glassdoor.com/Interview/net-developer-interview-questions-SRCH_KO0,13.htm)
- [InterviewBit - .NET Questions](https://www.interviewbit.com/dot-net-interview-questions/)
- [Toptal - C# Interview Questions](https://www.toptal.com/c-sharp/interview-questions)
- [ByteHide - Async/Await Questions](https://www.bytehide.com/blog/csharp-async-await-interview-questions)
- [Bool.dev - Design Patterns](https://bool.dev/blog/detail/part5-design-patterns-csharp-interview-questions)
- [FullStack.Cafe - LINQ Questions](https://www.fullstack.cafe/blog/linq-interview-questions-and-answers)
- [GitHub - Devinterview-io](https://github.com/Devinterview-io/linq-interview-questions)
- [LeetCode Discuss - Interview Experiences](https://leetcode.com/discuss/interview-question/)
- [Microsoft Learn - .NET Documentation](https://learn.microsoft.com/en-us/dotnet/)
- [Alex Xu - System Design](https://bytebytego.com/)

---

## Interview Preparation Checklist

### Week 1-2: Fundamentals
- [ ] OOP concepts with C# examples
- [ ] Collections and their Big O
- [ ] Async/await and threading
- [ ] SOLID principles

### Week 3-4: Framework & Tools
- [ ] ASP.NET Core middleware pipeline
- [ ] Entity Framework Core (N+1, tracking)
- [ ] Dependency Injection patterns
- [ ] JWT authentication

### Week 5-6: Advanced Topics
- [ ] Design patterns (Repository, Factory, Strategy)
- [ ] Microservices patterns (Saga, Circuit Breaker)
- [ ] System design basics
- [ ] SQL optimization

### Week 7-8: Practice
- [ ] LeetCode (50-100 problems: Easy/Medium)
- [ ] Mock interviews
- [ ] Project discussion preparation
- [ ] Behavioral questions (STAR format)
