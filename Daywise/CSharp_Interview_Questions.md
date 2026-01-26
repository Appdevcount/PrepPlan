# C# Interview Questions - Beginner to Expert Level

A comprehensive guide with 90 theory questions and 30 coding challenges for C# developers.

---

## Table of Contents
1. [Beginner Level Questions (1-30)](#beginner-level-questions)
2. [Intermediate Level Questions (31-60)](#intermediate-level-questions)
3. [Advanced/Expert Level Questions (61-90)](#advancedexpert-level-questions)
4. [Coding Interview Questions (91-120)](#coding-interview-questions)

---

## Beginner Level Questions

### Q1: What is C# and what are its key features?

**Answer:**
C# (pronounced "C-Sharp") is a modern, object-oriented, type-safe programming language developed by Microsoft as part of the .NET initiative.

**Key Features:**
- **Object-Oriented:** Supports encapsulation, inheritance, and polymorphism
- **Type-Safe:** Prevents type errors at compile time
- **Garbage Collection:** Automatic memory management
- **Cross-Platform:** Runs on Windows, Linux, macOS via .NET Core/.NET 5+
- **Strongly Typed:** Variables must be declared with a type
- **Component-Oriented:** Supports properties, events, and attributes

```csharp
// Example demonstrating key features
public class Person  // Object-oriented
{
    public string Name { get; set; }  // Properties
    public int Age { get; set; }

    public virtual void Introduce()  // Polymorphism support
    {
        Console.WriteLine($"Hi, I'm {Name}");
    }
}
```

---

### Q2: What is the difference between Value Types and Reference Types?

**Answer:**

| Aspect | Value Types | Reference Types |
|--------|-------------|-----------------|
| Storage | Stack | Heap |
| Contains | Actual data | Reference to data |
| Default | 0, false, etc. | null |
| Examples | int, float, struct, enum | class, string, array, delegate |
| Assignment | Copies value | Copies reference |

```csharp
// Value Type Example
int a = 10;
int b = a;  // b gets a COPY of the value
b = 20;
Console.WriteLine(a);  // Output: 10 (unchanged)

// Reference Type Example
int[] arr1 = { 1, 2, 3 };
int[] arr2 = arr1;  // arr2 points to SAME array
arr2[0] = 100;
Console.WriteLine(arr1[0]);  // Output: 100 (changed!)

// Struct (Value Type)
struct Point
{
    public int X, Y;
}

Point p1 = new Point { X = 1, Y = 2 };
Point p2 = p1;  // Complete copy
p2.X = 100;
Console.WriteLine(p1.X);  // Output: 1 (unchanged)
```

---

### Q3: Explain the difference between `const` and `readonly`

**Answer:**

| Feature | const | readonly |
|---------|-------|----------|
| Initialization | At declaration only | Declaration or constructor |
| Compile-time/Runtime | Compile-time constant | Runtime constant |
| Static | Implicitly static | Can be instance or static |
| Types | Primitive types, string | Any type |

```csharp
public class Constants
{
    // const - must be initialized at declaration, compile-time
    public const double PI = 3.14159;
    public const string AppName = "MyApp";

    // readonly - can be set in constructor, runtime
    public readonly DateTime CreatedAt;
    public readonly int[] Numbers;

    public Constants()
    {
        CreatedAt = DateTime.Now;  // Valid
        Numbers = new int[] { 1, 2, 3 };  // Valid
        // PI = 3.14;  // Error! Cannot modify const
    }

    public void SomeMethod()
    {
        // CreatedAt = DateTime.Now;  // Error! Cannot modify readonly outside constructor
    }
}
```

---

### Q4: What is the difference between `String` and `StringBuilder`?

**Answer:**

**String:** Immutable - every modification creates a new string object.
**StringBuilder:** Mutable - modifications happen in place.

```csharp
// String - Inefficient for multiple concatenations
string str = "";
for (int i = 0; i < 10000; i++)
{
    str += i.ToString();  // Creates new string each time!
}

// StringBuilder - Efficient for multiple modifications
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 10000; i++)
{
    sb.Append(i);  // Modifies in place
}
string result = sb.ToString();

// Performance comparison
var sw = Stopwatch.StartNew();
string s = "";
for (int i = 0; i < 100000; i++) s += "a";
Console.WriteLine($"String: {sw.ElapsedMilliseconds}ms");  // ~5000ms

sw.Restart();
var builder = new StringBuilder();
for (int i = 0; i < 100000; i++) builder.Append("a");
Console.WriteLine($"StringBuilder: {sw.ElapsedMilliseconds}ms");  // ~2ms
```

**When to use which:**
- Use `String` for small, infrequent modifications
- Use `StringBuilder` when building strings in loops or with many concatenations

---

### Q5: What are the different types of access modifiers in C#?

**Answer:**

| Modifier | Same Class | Same Assembly | Derived Class (Same Assembly) | Derived Class (Other Assembly) | Other Assembly |
|----------|------------|---------------|-------------------------------|--------------------------------|----------------|
| `public` | Yes | Yes | Yes | Yes | Yes |
| `private` | Yes | No | No | No | No |
| `protected` | Yes | No | Yes | Yes | No |
| `internal` | Yes | Yes | Yes | No | No |
| `protected internal` | Yes | Yes | Yes | Yes | No |
| `private protected` | Yes | No | Yes | No | No |

```csharp
public class AccessModifierDemo
{
    public int PublicField;           // Accessible everywhere
    private int _privateField;        // Only in this class
    protected int ProtectedField;     // This class + derived classes
    internal int InternalField;       // Same assembly only
    protected internal int ProtInternal;  // Same assembly OR derived classes
    private protected int PrivProtected;  // Same assembly AND derived classes

    public void Method()
    {
        // All accessible here
        PublicField = 1;
        _privateField = 2;
        ProtectedField = 3;
        InternalField = 4;
    }
}

public class DerivedClass : AccessModifierDemo
{
    public void DerivedMethod()
    {
        PublicField = 1;        // OK
        // _privateField = 2;   // Error! Private
        ProtectedField = 3;     // OK - derived class
        InternalField = 4;      // OK - same assembly
    }
}
```

---

### Q6: What is boxing and unboxing?

**Answer:**

**Boxing:** Converting a value type to a reference type (object or interface).
**Unboxing:** Converting a boxed reference type back to a value type.

```csharp
// Boxing - value type to object (implicit)
int number = 42;
object boxed = number;  // Boxing occurs here
// The int is wrapped in an object on the heap

// Unboxing - object to value type (explicit cast required)
int unboxed = (int)boxed;  // Unboxing occurs here

// Performance impact demonstration
var sw = Stopwatch.StartNew();
ArrayList list = new ArrayList();  // Non-generic, stores objects
for (int i = 0; i < 1000000; i++)
{
    list.Add(i);  // Boxing each int
}
Console.WriteLine($"ArrayList (boxing): {sw.ElapsedMilliseconds}ms");

sw.Restart();
List<int> genericList = new List<int>();  // Generic, no boxing
for (int i = 0; i < 1000000; i++)
{
    genericList.Add(i);  // No boxing
}
Console.WriteLine($"List<int> (no boxing): {sw.ElapsedMilliseconds}ms");

// Common boxing scenarios
int value = 10;
Console.WriteLine("Value: " + value);  // Boxing! value converted to object
Console.WriteLine($"Value: {value}");  // Also boxing in older .NET versions
```

**Why avoid boxing:**
- Memory allocation on heap
- Garbage collection overhead
- Performance penalty

---

### Q7: What is the difference between `==` and `.Equals()`?

**Answer:**

```csharp
// For Value Types - Both compare values
int a = 5, b = 5;
Console.WriteLine(a == b);         // True - value comparison
Console.WriteLine(a.Equals(b));    // True - value comparison

// For Reference Types - Different behavior by default
object obj1 = new object();
object obj2 = new object();
object obj3 = obj1;

Console.WriteLine(obj1 == obj2);       // False - different references
Console.WriteLine(obj1.Equals(obj2));  // False - default compares references
Console.WriteLine(obj1 == obj3);       // True - same reference

// String is special - overrides both
string s1 = "hello";
string s2 = "hello";
string s3 = new string("hello".ToCharArray());

Console.WriteLine(s1 == s2);       // True - value comparison (overloaded)
Console.WriteLine(s1.Equals(s2));  // True - value comparison (overridden)
Console.WriteLine((object)s1 == (object)s3);  // May be False (reference comparison)
Console.WriteLine(s1.Equals(s3)); // True - still value comparison

// Custom class example
public class Person
{
    public string Name { get; set; }

    public override bool Equals(object obj)
    {
        if (obj is Person other)
            return Name == other.Name;
        return false;
    }

    public override int GetHashCode() => Name?.GetHashCode() ?? 0;

    public static bool operator ==(Person a, Person b)
    {
        if (ReferenceEquals(a, b)) return true;
        if (a is null || b is null) return false;
        return a.Equals(b);
    }

    public static bool operator !=(Person a, Person b) => !(a == b);
}
```

---

### Q8: What is a namespace and why is it used?

**Answer:**

A namespace is a container that organizes code and prevents naming conflicts.

```csharp
// Defining namespaces
namespace MyCompany.ProjectA.DataAccess
{
    public class Customer
    {
        public string Name { get; set; }
    }
}

namespace MyCompany.ProjectB.Models
{
    public class Customer  // Same name, different namespace - no conflict!
    {
        public int Id { get; set; }
        public string FullName { get; set; }
    }
}

// Using namespaces
using MyCompany.ProjectA.DataAccess;
using ProjectBModels = MyCompany.ProjectB.Models;  // Alias

class Program
{
    static void Main()
    {
        // Use fully qualified name
        MyCompany.ProjectA.DataAccess.Customer c1 = new();

        // Use with 'using' directive
        Customer c2 = new Customer();  // ProjectA.Customer

        // Use alias
        ProjectBModels.Customer c3 = new();
    }
}

// File-scoped namespace (C# 10+)
namespace MyCompany.Utilities;

public class Helper
{
    // Entire file belongs to this namespace
}

// Global using (C# 10+)
// In a separate file or at top of file
global using System.Collections.Generic;
```

---

### Q9: What are the different types of loops in C#?

**Answer:**

```csharp
// 1. for loop - known number of iterations
for (int i = 0; i < 5; i++)
{
    Console.WriteLine($"for: {i}");
}

// 2. while loop - condition checked before each iteration
int count = 0;
while (count < 5)
{
    Console.WriteLine($"while: {count}");
    count++;
}

// 3. do-while loop - executes at least once
int num = 0;
do
{
    Console.WriteLine($"do-while: {num}");
    num++;
} while (num < 5);

// 4. foreach loop - iterate over collections
string[] fruits = { "Apple", "Banana", "Cherry" };
foreach (string fruit in fruits)
{
    Console.WriteLine($"foreach: {fruit}");
}

// 5. Loop control statements
for (int i = 0; i < 10; i++)
{
    if (i == 3) continue;  // Skip iteration
    if (i == 7) break;     // Exit loop
    Console.WriteLine(i);  // Prints: 0, 1, 2, 4, 5, 6
}

// 6. Nested loops with labels (goto - rarely used)
for (int i = 0; i < 3; i++)
{
    for (int j = 0; j < 3; j++)
    {
        if (i == 1 && j == 1)
            goto EndLoops;  // Break out of nested loops
        Console.WriteLine($"{i}, {j}");
    }
}
EndLoops:
Console.WriteLine("Done");

// Modern alternative using LINQ
Enumerable.Range(0, 5).ToList().ForEach(i => Console.WriteLine(i));
```

---

### Q10: What is the difference between `Array` and `ArrayList`?

**Answer:**

| Feature | Array | ArrayList |
|---------|-------|-----------|
| Type Safety | Strongly typed | Stores objects (boxing) |
| Size | Fixed | Dynamic |
| Performance | Better | Slower (boxing/unboxing) |
| Namespace | System | System.Collections |

```csharp
// Array - fixed size, type-safe
int[] numbers = new int[3];
numbers[0] = 1;
numbers[1] = 2;
numbers[2] = 3;
// numbers[3] = 4;  // Runtime error! Index out of bounds
// numbers[0] = "hello";  // Compile error! Type mismatch

// ArrayList - dynamic size, not type-safe
ArrayList list = new ArrayList();
list.Add(1);          // Boxing int to object
list.Add("hello");    // Can add any type - dangerous!
list.Add(3.14);
int first = (int)list[0];  // Must cast - unboxing

// Modern alternative: List<T> - best of both worlds
List<int> genericList = new List<int>();
genericList.Add(1);
genericList.Add(2);
// genericList.Add("hello");  // Compile error! Type-safe
int value = genericList[0];  // No casting needed

// Array initialization methods
int[] arr1 = new int[3] { 1, 2, 3 };
int[] arr2 = new int[] { 1, 2, 3 };
int[] arr3 = { 1, 2, 3 };
int[] arr4 = new[] { 1, 2, 3 };  // Type inferred

// Multi-dimensional arrays
int[,] matrix = new int[2, 3] { { 1, 2, 3 }, { 4, 5, 6 } };
int[][] jagged = new int[2][];  // Jagged array
jagged[0] = new int[] { 1, 2 };
jagged[1] = new int[] { 3, 4, 5, 6 };
```

---

### Q11: What are nullable types in C#?

**Answer:**

Nullable types allow value types to represent `null` in addition to their normal range of values.

```csharp
// Nullable value types
int? nullableInt = null;
double? nullableDouble = 3.14;
bool? nullableBool = null;

// Checking for value
if (nullableInt.HasValue)
{
    Console.WriteLine(nullableInt.Value);
}
else
{
    Console.WriteLine("No value");
}

// Null coalescing operator (??)
int result = nullableInt ?? 0;  // Use 0 if null
Console.WriteLine(result);  // Output: 0

// Null coalescing assignment (??=) - C# 8+
nullableInt ??= 10;  // Assign 10 only if null
Console.WriteLine(nullableInt);  // Output: 10

// Null conditional operator (?.)
string? name = null;
int? length = name?.Length;  // null, not exception

// Nullable reference types (C# 8+)
#nullable enable
string? nullableString = null;  // OK
string nonNullableString = "hello";
// nonNullableString = null;  // Warning!

void ProcessName(string? name)
{
    // Must check for null before using
    if (name != null)
    {
        Console.WriteLine(name.ToUpper());
    }

    // Or use null-forgiving operator (!) if you're certain
    // Console.WriteLine(name!.ToUpper());  // Dangerous!
}

// Pattern matching with null
object? obj = GetValue();
if (obj is int number)
{
    Console.WriteLine($"It's an int: {number}");
}
else if (obj is null)
{
    Console.WriteLine("It's null");
}
```

---

### Q12: What is the difference between `out` and `ref` parameters?

**Answer:**

| Feature | ref | out |
|---------|-----|-----|
| Initialization before call | Required | Not required |
| Assignment in method | Optional | Required |
| Use case | Modify existing value | Return multiple values |

```csharp
public class ParameterDemo
{
    // ref - must be initialized before passing
    public void ModifyWithRef(ref int number)
    {
        number *= 2;  // Optional to assign
    }

    // out - must be assigned in method
    public void GetValues(out int x, out int y)
    {
        x = 10;  // Required!
        y = 20;  // Required!
    }

    // Practical example: TryParse pattern
    public bool TryParseCustom(string input, out int result)
    {
        if (int.TryParse(input, out result))
        {
            return true;
        }
        result = 0;  // Must assign even on failure
        return false;
    }

    public void Demo()
    {
        // ref usage
        int value = 5;  // Must initialize
        ModifyWithRef(ref value);
        Console.WriteLine(value);  // Output: 10

        // out usage
        int a, b;  // No initialization needed
        GetValues(out a, out b);
        Console.WriteLine($"{a}, {b}");  // Output: 10, 20

        // out with inline declaration (C# 7+)
        GetValues(out int x, out int y);
        Console.WriteLine($"{x}, {y}");

        // Discard unused out parameters
        GetValues(out int onlyX, out _);

        // Common use: TryParse
        if (int.TryParse("123", out int parsed))
        {
            Console.WriteLine(parsed);  // Output: 123
        }
    }
}
```

---

### Q13: What is the difference between `throw` and `throw ex`?

**Answer:**

```csharp
public class ExceptionDemo
{
    public void Method1()
    {
        try
        {
            Method2();
        }
        catch (Exception ex)
        {
            // throw; - Preserves original stack trace
            throw;
        }
    }

    public void Method2()
    {
        try
        {
            Method3();
        }
        catch (Exception ex)
        {
            // throw ex; - Resets stack trace (loses original location!)
            throw ex;  // BAD PRACTICE!
        }
    }

    public void Method3()
    {
        throw new InvalidOperationException("Error in Method3");
    }

    // Best practice - wrap with inner exception
    public void BetterMethod()
    {
        try
        {
            Method3();
        }
        catch (Exception ex)
        {
            // Preserves original exception as inner exception
            throw new ApplicationException("Wrapper message", ex);
        }
    }
}

// Stack trace comparison:
// With 'throw;':     Method3 -> Method2 -> Method1 -> Main (full trace)
// With 'throw ex;':  Method2 -> Method1 -> Main (loses Method3 info!)
```

**Best Practices:**
- Use `throw;` to rethrow and preserve stack trace
- Use `throw new Exception("message", ex);` to wrap with additional context
- Never use `throw ex;` as it loses debugging information

---

### Q14: What are properties in C# and what are their types?

**Answer:**

Properties provide a flexible mechanism to read, write, or compute values of private fields.

```csharp
public class PropertyDemo
{
    // 1. Full property with backing field
    private string _name;
    public string Name
    {
        get { return _name; }
        set { _name = value; }
    }

    // 2. Auto-implemented property
    public int Age { get; set; }

    // 3. Read-only property
    public string Id { get; }  // Can only set in constructor

    // 4. Property with different access modifiers
    public string Email { get; private set; }  // Public get, private set

    // 5. Expression-bodied property (read-only)
    public string FullInfo => $"{Name}, Age: {Age}";

    // 6. Property with validation
    private int _score;
    public int Score
    {
        get => _score;
        set
        {
            if (value < 0 || value > 100)
                throw new ArgumentOutOfRangeException(nameof(value));
            _score = value;
        }
    }

    // 7. Computed property
    public bool IsAdult => Age >= 18;

    // 8. Init-only property (C# 9+)
    public string CreatedBy { get; init; }

    // 9. Required property (C# 11+)
    public required string RequiredField { get; set; }

    // Constructor
    public PropertyDemo(string id)
    {
        Id = id;  // Can set read-only property here
    }
}

// Usage
var demo = new PropertyDemo("123")
{
    Name = "John",
    Age = 25,
    CreatedBy = "Admin",  // init - can only set during initialization
    RequiredField = "Must provide this"
};
// demo.CreatedBy = "Other";  // Error! init-only
```

---

### Q15: What is the `static` keyword and where can it be used?

**Answer:**

The `static` keyword indicates that a member belongs to the type itself rather than to instances.

```csharp
// Static class - cannot be instantiated
public static class MathHelper
{
    // Static field
    public static double PI = 3.14159;

    // Static method
    public static int Add(int a, int b) => a + b;

    // Static property
    public static string Version { get; } = "1.0";
}

// Regular class with static members
public class Counter
{
    // Static field - shared across all instances
    private static int _totalCount = 0;

    // Instance field - unique per instance
    private int _instanceId;

    // Static constructor - runs once when class is first used
    static Counter()
    {
        Console.WriteLine("Static constructor called");
    }

    // Instance constructor
    public Counter()
    {
        _totalCount++;
        _instanceId = _totalCount;
    }

    // Static property
    public static int TotalCount => _totalCount;

    // Instance property
    public int InstanceId => _instanceId;

    // Static method
    public static void ResetCount() => _totalCount = 0;
}

// Static local function (C# 8+)
public int Calculate(int x)
{
    return Add(x, 5);

    static int Add(int a, int b) => a + b;  // Can't access instance members
}

// Usage
Console.WriteLine(MathHelper.Add(5, 3));  // 8
Console.WriteLine(MathHelper.PI);          // 3.14159

var c1 = new Counter();  // _instanceId = 1
var c2 = new Counter();  // _instanceId = 2
Console.WriteLine(Counter.TotalCount);  // 2
Console.WriteLine(c1.InstanceId);       // 1
```

---

### Q16: What is method overloading?

**Answer:**

Method overloading allows multiple methods with the same name but different parameters (different signature).

```csharp
public class Calculator
{
    // Overloaded by number of parameters
    public int Add(int a, int b) => a + b;
    public int Add(int a, int b, int c) => a + b + c;

    // Overloaded by parameter types
    public double Add(double a, double b) => a + b;
    public string Add(string a, string b) => a + b;

    // Overloaded by parameter order
    public void Display(string message, int count)
        => Console.WriteLine($"{message}: {count}");
    public void Display(int count, string message)
        => Console.WriteLine($"{count} - {message}");

    // With optional parameters
    public int Multiply(int a, int b, int c = 1) => a * b * c;

    // With params
    public int Sum(params int[] numbers) => numbers.Sum();
}

// Usage
var calc = new Calculator();
Console.WriteLine(calc.Add(1, 2));           // 3 (int version)
Console.WriteLine(calc.Add(1, 2, 3));        // 6 (three int version)
Console.WriteLine(calc.Add(1.5, 2.5));       // 4.0 (double version)
Console.WriteLine(calc.Add("Hello", " World")); // "Hello World"

calc.Display("Count", 5);   // "Count: 5"
calc.Display(5, "Items");   // "5 - Items"

Console.WriteLine(calc.Multiply(2, 3));      // 6
Console.WriteLine(calc.Multiply(2, 3, 4));   // 24
Console.WriteLine(calc.Sum(1, 2, 3, 4, 5));  // 15

// NOTE: These are NOT valid overloads:
// - Different return type only
// - Different parameter names only
// public double Add(int a, int b) => a + b;  // Error! Same signature
```

---

### Q17: What is the difference between `break`, `continue`, and `return`?

**Answer:**

```csharp
public class FlowControlDemo
{
    public void BreakDemo()
    {
        // break - exits the loop entirely
        for (int i = 0; i < 10; i++)
        {
            if (i == 5) break;  // Exit loop when i = 5
            Console.Write($"{i} ");  // Output: 0 1 2 3 4
        }
        Console.WriteLine("After loop");  // This executes
    }

    public void ContinueDemo()
    {
        // continue - skips current iteration, continues loop
        for (int i = 0; i < 10; i++)
        {
            if (i % 2 == 0) continue;  // Skip even numbers
            Console.Write($"{i} ");  // Output: 1 3 5 7 9
        }
        Console.WriteLine("After loop");  // This executes
    }

    public int ReturnDemo(int x)
    {
        // return - exits the method entirely
        for (int i = 0; i < 10; i++)
        {
            if (i == x) return i * 2;  // Exit method with value
            Console.Write($"{i} ");
        }
        Console.WriteLine("After loop");  // May not execute
        return -1;
    }

    public void NestedLoopBreak()
    {
        // break only exits innermost loop
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                if (j == 1) break;  // Only exits inner loop
                Console.WriteLine($"i={i}, j={j}");
            }
        }
        // Output: i=0,j=0  i=1,j=0  i=2,j=0
    }

    public void BreakInSwitch(int day)
    {
        // break in switch - exits switch statement
        switch (day)
        {
            case 1:
                Console.WriteLine("Monday");
                break;  // Required! Prevents fall-through
            case 2:
                Console.WriteLine("Tuesday");
                break;
            default:
                Console.WriteLine("Other day");
                break;
        }
    }
}
```

---

### Q18: What are the different types of comments in C#?

**Answer:**

```csharp
// 1. Single-line comment
// This is a single line comment

// 2. Multi-line comment
/* This is a
   multi-line comment
   spanning multiple lines */

// 3. XML Documentation comment
/// <summary>
/// Calculates the sum of two integers.
/// </summary>
/// <param name="a">The first integer</param>
/// <param name="b">The second integer</param>
/// <returns>The sum of a and b</returns>
/// <example>
/// <code>
/// int result = Add(5, 3); // returns 8
/// </code>
/// </example>
/// <exception cref="OverflowException">Thrown when result exceeds int.MaxValue</exception>
public int Add(int a, int b)
{
    return a + b;
}

// 4. Region (code folding, not a comment but related)
#region Helper Methods
public void Helper1() { }
public void Helper2() { }
#endregion

// 5. Pragma (compiler directives)
#pragma warning disable CS0168  // Variable declared but never used
int unusedVariable;
#pragma warning restore CS0168

// 6. TODO/HACK/UNDONE comments (recognized by IDE)
// TODO: Implement error handling
// HACK: Temporary workaround for bug #123
// UNDONE: Reverted changes, needs review

// XML documentation tags:
/// <remarks>Additional information about the method</remarks>
/// <seealso cref="OtherClass"/>
/// <see cref="OtherMethod"/>
/// <value>Description of property value</value>
/// <typeparam name="T">Description of type parameter</typeparam>
/// <inheritdoc/>  // Inherits documentation from base
```

---

### Q19: What is an enum and how is it used?

**Answer:**

An enum (enumeration) is a value type that defines a set of named constants.

```csharp
// Basic enum
public enum DayOfWeek
{
    Sunday,    // 0
    Monday,    // 1
    Tuesday,   // 2
    Wednesday, // 3
    Thursday,  // 4
    Friday,    // 5
    Saturday   // 6
}

// Enum with explicit values
public enum HttpStatusCode
{
    OK = 200,
    Created = 201,
    BadRequest = 400,
    NotFound = 404,
    InternalServerError = 500
}

// Enum with specific underlying type
public enum ByteEnum : byte
{
    Small = 1,
    Medium = 2,
    Large = 3
}

// Flags enum (bitwise operations)
[Flags]
public enum FilePermissions
{
    None = 0,
    Read = 1,      // 0001
    Write = 2,     // 0010
    Execute = 4,   // 0100
    ReadWrite = Read | Write,  // 0011
    All = Read | Write | Execute  // 0111
}

// Usage examples
DayOfWeek today = DayOfWeek.Monday;
Console.WriteLine(today);           // "Monday"
Console.WriteLine((int)today);      // 1

// Parse from string
DayOfWeek parsed = Enum.Parse<DayOfWeek>("Friday");
bool success = Enum.TryParse<DayOfWeek>("Sunday", out DayOfWeek day);

// Get all values
foreach (DayOfWeek d in Enum.GetValues<DayOfWeek>())
{
    Console.WriteLine($"{d} = {(int)d}");
}

// Flags usage
FilePermissions perms = FilePermissions.Read | FilePermissions.Write;
Console.WriteLine(perms);  // "ReadWrite" or "Read, Write"
bool canRead = perms.HasFlag(FilePermissions.Read);  // true
bool canExecute = (perms & FilePermissions.Execute) != 0;  // false

// Switch expression with enum
string GetMessage(HttpStatusCode code) => code switch
{
    HttpStatusCode.OK => "Success",
    HttpStatusCode.NotFound => "Resource not found",
    HttpStatusCode.InternalServerError => "Server error",
    _ => "Unknown status"
};
```

---

### Q20: What is a struct and how does it differ from a class?

**Answer:**

| Feature | struct | class |
|---------|--------|-------|
| Type | Value type | Reference type |
| Storage | Stack (typically) | Heap |
| Inheritance | Cannot inherit (except interfaces) | Can inherit |
| Default constructor | Cannot define parameterless (before C# 10) | Can define |
| Null | Cannot be null (unless nullable) | Can be null |
| Copy behavior | Copies all data | Copies reference |

```csharp
// Struct definition
public struct Point
{
    public int X { get; set; }
    public int Y { get; set; }

    public Point(int x, int y)
    {
        X = x;
        Y = y;
    }

    public double DistanceFromOrigin() => Math.Sqrt(X * X + Y * Y);
}

// Class definition
public class PointClass
{
    public int X { get; set; }
    public int Y { get; set; }
}

// Comparison
Point p1 = new Point(3, 4);
Point p2 = p1;  // Creates a COPY
p2.X = 100;
Console.WriteLine(p1.X);  // 3 (unchanged)

PointClass pc1 = new PointClass { X = 3, Y = 4 };
PointClass pc2 = pc1;  // Same reference
pc2.X = 100;
Console.WriteLine(pc1.X);  // 100 (changed!)

// Readonly struct (C# 7.2+) - immutable
public readonly struct ImmutablePoint
{
    public int X { get; }
    public int Y { get; }

    public ImmutablePoint(int x, int y) => (X, Y) = (x, y);
}

// Record struct (C# 10+) - value type record
public record struct RecordPoint(int X, int Y);

// When to use struct:
// - Small data (16 bytes or less recommended)
// - Short-lived objects
// - Immutable data
// - Frequently created/destroyed objects

// Built-in structs: int, double, bool, DateTime, Guid, etc.
```

---

### Q21: What is type casting in C#?

**Answer:**

Type casting is converting a value from one data type to another.

```csharp
// 1. Implicit casting (automatic) - no data loss
int intValue = 100;
long longValue = intValue;      // int to long
float floatValue = intValue;    // int to float
double doubleValue = floatValue; // float to double

// 2. Explicit casting (manual) - potential data loss
double d = 123.456;
int i = (int)d;  // 123 (truncated, not rounded)

long big = 1000L;
int small = (int)big;  // OK if value fits

// 3. Convert class
string str = "123";
int converted = Convert.ToInt32(str);
double dbl = Convert.ToDouble("123.45");
bool b = Convert.ToBoolean(1);  // true

// 4. Parse methods
int parsed = int.Parse("123");
double dParsed = double.Parse("123.45");

// 5. TryParse (safe parsing)
if (int.TryParse("123", out int result))
{
    Console.WriteLine(result);
}

// 6. as operator (reference types only, returns null if fails)
object obj = "Hello";
string s = obj as string;  // "Hello"
List<int> list = obj as List<int>;  // null (not exception)

// 7. is operator (type checking)
if (obj is string text)
{
    Console.WriteLine(text.Length);
}

// 8. Pattern matching (C# 7+)
object value = 42;
if (value is int number)
{
    Console.WriteLine($"It's an integer: {number}");
}

// Casting hierarchy for reference types
class Animal { }
class Dog : Animal { }

Animal animal = new Dog();  // Implicit upcast
Dog dog = (Dog)animal;      // Explicit downcast

// Safe downcasting
if (animal is Dog d)
{
    d.Bark();
}
// Or
Dog? maybeDog = animal as Dog;
maybeDog?.Bark();
```

---

### Q22: What are default parameter values and named arguments?

**Answer:**

```csharp
public class ParameterDemo
{
    // Default parameter values (must be compile-time constants)
    public void Greet(
        string name,
        string greeting = "Hello",    // Default value
        int times = 1,                 // Default value
        bool uppercase = false)        // Default value
    {
        string message = uppercase ? greeting.ToUpper() : greeting;
        for (int i = 0; i < times; i++)
        {
            Console.WriteLine($"{message}, {name}!");
        }
    }

    // Rules for default parameters:
    // 1. Must be at the end of parameter list
    // 2. Must be compile-time constants
    // public void Invalid(string x = GetValue()) { }  // Error!
    // public void Invalid(DateTime dt = DateTime.Now) { }  // Error!

    public void ValidDefaults(
        int x = 10,
        string s = "default",
        bool? b = null,
        object o = default)  // default keyword works
    { }
}

// Named arguments
var demo = new ParameterDemo();

// Using positional arguments
demo.Greet("Alice", "Hi", 2, true);

// Using named arguments - can be in any order
demo.Greet(name: "Bob", uppercase: true, greeting: "Welcome");

// Mix positional and named (positional must come first)
demo.Greet("Charlie", times: 3);

// Skip middle default parameters using named arguments
demo.Greet("David", uppercase: true);  // Skip 'greeting' and 'times'

// Named arguments improve readability
CreateUser(
    name: "John",
    email: "john@example.com",
    isActive: true,
    role: "Admin"
);

// Versus positional (less clear)
CreateUser("John", "john@example.com", true, "Admin");

void CreateUser(string name, string email, bool isActive, string role) { }
```

---

### Q23: What is the `this` keyword in C#?

**Answer:**

The `this` keyword refers to the current instance of a class.

```csharp
public class Person
{
    private string name;
    private int age;

    // 1. Distinguish between field and parameter
    public Person(string name, int age)
    {
        this.name = name;   // 'this' refers to field
        this.age = age;
    }

    // 2. Pass current instance as parameter
    public void Register(Registry registry)
    {
        registry.Add(this);  // Pass current instance
    }

    // 3. Return current instance (fluent interface)
    public Person SetName(string name)
    {
        this.name = name;
        return this;
    }

    public Person SetAge(int age)
    {
        this.age = age;
        return this;
    }

    // 4. Constructor chaining
    public Person() : this("Unknown", 0) { }

    public Person(string name) : this(name, 0) { }
}

// Extension methods use 'this' parameter
public static class StringExtensions
{
    // 'this' keyword makes it an extension method
    public static bool IsNullOrEmpty(this string str)
    {
        return string.IsNullOrEmpty(str);
    }

    public static string Repeat(this string str, int count)
    {
        return string.Concat(Enumerable.Repeat(str, count));
    }
}

// Indexer using 'this'
public class CustomCollection
{
    private int[] _items = new int[10];

    public int this[int index]
    {
        get => _items[index];
        set => _items[index] = value;
    }
}

// Usage
var person = new Person()
    .SetName("Alice")   // Fluent chain
    .SetAge(30);

string text = "Hello";
bool empty = text.IsNullOrEmpty();  // Extension method
string repeated = text.Repeat(3);    // "HelloHelloHello"

var collection = new CustomCollection();
collection[0] = 42;  // Using indexer
```

---

### Q24: What is the difference between `is` and `as` operators?

**Answer:**

| Feature | is | as |
|---------|----|----|
| Purpose | Type checking | Type casting |
| Returns | bool | Object or null |
| Failure | Returns false | Returns null |
| Value types | Works | Only nullable value types |
| Throws | Never | Never |

```csharp
object obj = "Hello, World!";

// 'is' operator - type checking
if (obj is string)
{
    Console.WriteLine("It's a string");
}

// 'is' with pattern matching (C# 7+)
if (obj is string str)
{
    Console.WriteLine(str.Length);  // Can use 'str' directly
}

// 'is' with negation (C# 9+)
if (obj is not null)
{
    Console.WriteLine("Not null");
}

// 'as' operator - safe casting (returns null if fails)
string s = obj as string;  // "Hello, World!"
if (s != null)
{
    Console.WriteLine(s.ToUpper());
}

List<int> list = obj as List<int>;  // null (not a List<int>)

// Combining is and as patterns
void ProcessObject(object item)
{
    // Using 'is' with pattern matching (preferred)
    if (item is string text)
    {
        Console.WriteLine($"String of length {text.Length}");
    }
    else if (item is int number)
    {
        Console.WriteLine($"Integer: {number}");
    }
    else if (item is IEnumerable<int> numbers)
    {
        Console.WriteLine($"Collection with {numbers.Count()} items");
    }

    // Using 'as' (older pattern)
    var maybeString = item as string;
    if (maybeString != null)
    {
        // Use maybeString
    }
}

// 'as' doesn't work with non-nullable value types
object boxedInt = 42;
// int i = boxedInt as int;  // Error! Can't use 'as' with non-nullable value type
int? ni = boxedInt as int?;  // OK - nullable int
int direct = (int)boxedInt;   // OK - explicit cast

// Type pattern combinations (C# 9+)
if (obj is string { Length: > 5 } longString)
{
    Console.WriteLine($"Long string: {longString}");
}
```

---

### Q25: What is a constructor and what are its types?

**Answer:**

A constructor is a special method that initializes an object when it's created.

```csharp
public class Employee
{
    // Fields
    private static int _totalEmployees;
    private int _id;
    private string _name;
    private string _department;

    // 1. Static constructor - runs once when class is first used
    static Employee()
    {
        _totalEmployees = 0;
        Console.WriteLine("Static constructor called");
    }

    // 2. Default constructor (parameterless)
    public Employee()
    {
        _id = ++_totalEmployees;
        _name = "Unknown";
        _department = "Unassigned";
    }

    // 3. Parameterized constructor
    public Employee(string name, string department)
    {
        _id = ++_totalEmployees;
        _name = name;
        _department = department;
    }

    // 4. Constructor chaining using 'this'
    public Employee(string name) : this(name, "Unassigned")
    {
        // Additional initialization if needed
    }

    // 5. Copy constructor
    public Employee(Employee other)
    {
        _id = ++_totalEmployees;  // New ID
        _name = other._name;
        _department = other._department;
    }

    // Properties
    public int Id => _id;
    public string Name => _name;
    public static int TotalEmployees => _totalEmployees;
}

// 6. Constructor in derived class
public class Manager : Employee
{
    public int TeamSize { get; set; }

    // Call base constructor
    public Manager(string name, string department, int teamSize)
        : base(name, department)
    {
        TeamSize = teamSize;
    }
}

// 7. Private constructor (Singleton pattern)
public class Singleton
{
    private static Singleton _instance;

    private Singleton() { }  // Prevents external instantiation

    public static Singleton Instance
    {
        get
        {
            _instance ??= new Singleton();
            return _instance;
        }
    }
}

// 8. Primary constructor (C# 12+)
public class Person(string name, int age)
{
    public string Name { get; } = name;
    public int Age { get; } = age;
}

// Usage
var emp1 = new Employee();
var emp2 = new Employee("Alice", "Engineering");
var emp3 = new Employee("Bob");
var emp4 = new Employee(emp2);  // Copy
var mgr = new Manager("Carol", "Engineering", 5);
```

---

### Q26: What is garbage collection in C#?

**Answer:**

Garbage Collection (GC) is automatic memory management that reclaims memory occupied by objects no longer in use.

```csharp
public class GarbageCollectionDemo
{
    // Objects eligible for GC when no references exist
    public void CreateObjects()
    {
        var obj1 = new MyClass();  // Created on heap
        var obj2 = new MyClass();

        obj1 = null;  // obj1 is now eligible for GC
        obj2 = new MyClass();  // Original obj2 is eligible for GC

    }  // obj2 goes out of scope, eligible for GC

    // GC Generations
    // Gen 0: Short-lived objects (most collected)
    // Gen 1: Medium-lived objects
    // Gen 2: Long-lived objects (least collected)

    // Forcing garbage collection (not recommended in production)
    public void ForceGC()
    {
        GC.Collect();  // Forces GC of all generations
        GC.Collect(0); // Forces GC of generation 0 only
        GC.WaitForPendingFinalizers();  // Wait for finalizers
    }

    // Check memory
    public void MemoryInfo()
    {
        long totalMemory = GC.GetTotalMemory(false);
        int gen0Collections = GC.CollectionCount(0);
        int gen1Collections = GC.CollectionCount(1);
        int gen2Collections = GC.CollectionCount(2);

        Console.WriteLine($"Total Memory: {totalMemory / 1024} KB");
        Console.WriteLine($"Gen 0 Collections: {gen0Collections}");
    }
}

// Implementing IDisposable for deterministic cleanup
public class ResourceHolder : IDisposable
{
    private bool _disposed = false;
    private IntPtr _unmanagedResource;
    private FileStream _managedResource;

    // Finalizer (destructor) - called by GC
    ~ResourceHolder()
    {
        Dispose(false);
    }

    // Public Dispose method
    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);  // Prevent finalizer from running
    }

    // Protected Dispose pattern
    protected virtual void Dispose(bool disposing)
    {
        if (!_disposed)
        {
            if (disposing)
            {
                // Dispose managed resources
                _managedResource?.Dispose();
            }

            // Free unmanaged resources
            // CloseHandle(_unmanagedResource);

            _disposed = true;
        }
    }
}

// Using 'using' statement for automatic disposal
using (var resource = new ResourceHolder())
{
    // Use resource
}  // Dispose() called automatically

// Using declaration (C# 8+)
using var file = new StreamReader("file.txt");
// Disposed at end of scope
```

---

### Q27: What is the `var` keyword?

**Answer:**

The `var` keyword enables implicit typing where the compiler infers the type from the initialization.

```csharp
// Compiler infers types
var number = 42;              // int
var text = "Hello";           // string
var price = 19.99m;           // decimal
var items = new List<int>();  // List<int>
var dict = new Dictionary<string, int>();  // Dictionary<string, int>

// Hover over 'var' in IDE to see actual type
var query = from p in products
            where p.Price > 100
            select new { p.Name, p.Price };  // Anonymous type!

// var is required for anonymous types
var person = new { Name = "Alice", Age = 30 };
// Cannot declare: AnonymousType person = new { ... }

// Rules for var:
// 1. Must be initialized at declaration
// var x;  // Error! Must initialize

// 2. Cannot be null without cast
// var y = null;  // Error! Type cannot be inferred
var y = (string?)null;  // OK - explicit type

// 3. Cannot be used for method parameters or return types
// public var GetValue() { }  // Error!

// 4. Can be used in for/foreach
for (var i = 0; i < 10; i++) { }
foreach (var item in items) { }

// 5. Can be used in using statements
using var stream = new FileStream("file.txt", FileMode.Open);

// When to use var:
// - When type is obvious from right side
var customer = new Customer();  // Clear - it's a Customer
var orders = GetOrders();       // Less clear - what's the return type?

// When NOT to use var:
// - When type isn't obvious
// var result = ProcessData();  // What type is result?
CustomerData result = ProcessData();  // More readable

// Target-typed 'new' (C# 9+) - alternative to var
Customer customer2 = new();  // Type on left, 'new' without type on right
List<int> numbers = new() { 1, 2, 3 };
```

---

### Q28: What is string interpolation?

**Answer:**

String interpolation allows embedding expressions directly in string literals using the `$` prefix.

```csharp
string name = "Alice";
int age = 30;
double salary = 50000.50;

// Basic interpolation
string message = $"Hello, {name}!";
Console.WriteLine(message);  // "Hello, Alice!"

// Expressions in interpolation
string info = $"{name} is {age} years old and will be {age + 1} next year.";

// Format specifiers
string formatted = $"Salary: {salary:C}";           // "Salary: $50,000.50"
string number = $"Value: {123456:N0}";              // "Value: 123,456"
string percentage = $"Rate: {0.156:P1}";            // "Rate: 15.6%"
string date = $"Today: {DateTime.Now:yyyy-MM-dd}"; // "Today: 2024-01-15"
string padded = $"ID: {42:D5}";                     // "ID: 00042"
string hex = $"Hex: {255:X2}";                      // "Hex: FF"

// Alignment
string aligned = $"|{name,-10}|{age,5}|";  // Left-align name (10), right-align age (5)
// "|Alice     |   30|"

// Verbatim interpolated strings (multiline)
string multiline = $@"
    Name: {name}
    Age: {age}
    Path: C:\Users\{name}\Documents
";

// Raw string literals with interpolation (C# 11+)
string raw = $"""
    Name: {name}
    JSON: {{"name": "{name}"}}
    """;

// Escaping braces
string escaped = $"Use {{braces}} like this: {name}";
// "Use {braces} like this: Alice"

// Conditional expression
bool isAdult = true;
string status = $"Status: {(isAdult ? "Adult" : "Minor")}";

// Method calls
string upper = $"Uppercase: {name.ToUpper()}";
string length = $"Length: {name.Length}";

// Null handling
string? nullName = null;
string safe = $"Name: {nullName ?? "Unknown"}";

// Interpolated string handler (C# 10+) - performance optimization
// The compiler can optimize interpolated strings passed to certain methods
logger.LogInformation($"Processing {itemCount} items");
```

---

### Q29: What is a delegate in C#?

**Answer:**

A delegate is a type-safe function pointer that holds references to methods with a specific signature.

```csharp
// Declare a delegate type
public delegate int MathOperation(int a, int b);
public delegate void MessageHandler(string message);

public class DelegateDemo
{
    // Methods matching delegate signatures
    public static int Add(int a, int b) => a + b;
    public static int Multiply(int a, int b) => a * b;
    public static void PrintMessage(string msg) => Console.WriteLine(msg);

    public void Demo()
    {
        // 1. Create delegate instance
        MathOperation operation = Add;
        int result = operation(5, 3);  // 8

        // 2. Reassign to different method
        operation = Multiply;
        result = operation(5, 3);  // 15

        // 3. Multicast delegate (multiple methods)
        MessageHandler handler = PrintMessage;
        handler += msg => Console.WriteLine($"Lambda: {msg}");
        handler += msg => Console.WriteLine($"Another: {msg}");

        handler("Hello");
        // Output:
        // Hello
        // Lambda: Hello
        // Another: Hello

        // 4. Remove from multicast
        handler -= PrintMessage;

        // 5. Anonymous method
        MathOperation subtract = delegate(int a, int b)
        {
            return a - b;
        };

        // 6. Lambda expression (preferred)
        MathOperation divide = (a, b) => a / b;
    }
}

// Built-in delegate types
public class BuiltInDelegates
{
    public void Demo()
    {
        // Action - void return
        Action sayHello = () => Console.WriteLine("Hello");
        Action<string> greet = name => Console.WriteLine($"Hello, {name}");
        Action<int, int> printSum = (a, b) => Console.WriteLine(a + b);

        // Func - with return value (last type is return type)
        Func<int> getNumber = () => 42;
        Func<int, int> square = x => x * x;
        Func<int, int, int> add = (a, b) => a + b;
        Func<string, int> getLength = s => s.Length;

        // Predicate - returns bool
        Predicate<int> isEven = x => x % 2 == 0;
        Predicate<string> isEmpty = s => string.IsNullOrEmpty(s);

        // Usage
        sayHello();               // "Hello"
        greet("Alice");           // "Hello, Alice"
        int num = getNumber();    // 42
        bool even = isEven(4);    // true

        // With LINQ
        var numbers = new[] { 1, 2, 3, 4, 5 };
        var evenNumbers = numbers.Where(isEven);  // 2, 4
    }
}
```

---

### Q30: What is the difference between `Array.CopyTo()` and `Array.Clone()`?

**Answer:**

```csharp
// Clone() - Creates a shallow copy and returns object
int[] original = { 1, 2, 3, 4, 5 };
int[] cloned = (int[])original.Clone();  // Need to cast

cloned[0] = 100;
Console.WriteLine(original[0]);  // 1 (unchanged for value types)

// CopyTo() - Copies to existing array at specified index
int[] destination = new int[10];
original.CopyTo(destination, 2);  // Copy starting at index 2
// destination: [0, 0, 1, 2, 3, 4, 5, 0, 0, 0]

// Key differences:
// | Feature          | Clone()                    | CopyTo()                    |
// |------------------|----------------------------|------------------------------|
// | Creates new array| Yes                        | No, uses existing            |
// | Return type      | object (needs cast)        | void                         |
// | Destination index| Always 0                   | Configurable                 |
// | Shallow copy     | Yes                        | Yes                          |

// Shallow copy behavior with reference types
public class Person
{
    public string Name { get; set; }
}

Person[] people = { new Person { Name = "Alice" }, new Person { Name = "Bob" } };
Person[] clonedPeople = (Person[])people.Clone();

clonedPeople[0].Name = "Changed";  // Modifies the SAME Person object
Console.WriteLine(people[0].Name);  // "Changed" - reference was copied!

clonedPeople[0] = new Person { Name = "New" };  // New reference
Console.WriteLine(people[0].Name);  // "Changed" - original unaffected

// Deep copy (manual)
Person[] deepCopy = people.Select(p => new Person { Name = p.Name }).ToArray();

// Array.Copy static method
int[] source = { 1, 2, 3, 4, 5 };
int[] dest = new int[5];
Array.Copy(source, 1, dest, 0, 3);  // Copy 3 elements from index 1
// dest: [2, 3, 4, 0, 0]

// Span-based copy (most efficient)
source.AsSpan().CopyTo(dest);
```

---

