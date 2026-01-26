# 60 C# Coding Interview Coding Questions (With Explanations and Solutions)

This list contains 60 coding-focused C# interview questions, inspired by real interview experiences at top Indian service-based and product-based companies. Each question includes a detailed explanation, reasoning, and a sample implementation.

---

## Beginner Level

### 1. Reverse a String
**Explanation:** Reverse the characters in a string.
**Reason:** Tests string manipulation basics.
**Code:**
```csharp
public string ReverseString(string s) => new string(s.Reverse().ToArray());
```

---

### 2. Check for Palindrome
**Explanation:** Determine if a string reads the same backward.
**Reason:** Common string logic.
**Code:**
```csharp
public bool IsPalindrome(string s) => s.SequenceEqual(s.Reverse());
```

---

### 3. Find the Maximum in an Array
**Explanation:** Return the largest element.
**Reason:** Array traversal basics.
**Code:**
```csharp
public int MaxInArray(int[] arr) => arr.Max();
```

---

### 4. Fibonacci Series (Iterative)
**Explanation:** Print first N Fibonacci numbers.
**Reason:** Loops and variable updates.
**Code:**
```csharp
public List<int> Fibonacci(int n) {
    var res = new List<int> {0, 1};
    for (int i = 2; i < n; i++)
        res.Add(res[i-1] + res[i-2]);
    return res.Take(n).ToList();
}
```

---

### 5. Factorial (Recursive)
**Explanation:** Compute n! recursively.
**Reason:** Recursion basics.
**Code:**
```csharp
public int Factorial(int n) => n <= 1 ? 1 : n * Factorial(n-1);
```

---

### 6. Remove Duplicates from Array
**Explanation:** Return array with unique elements.
**Reason:** Set usage.
**Code:**
```csharp
public int[] RemoveDuplicates(int[] arr) => arr.Distinct().ToArray();
```

---

### 7. Merge Two Sorted Arrays
**Explanation:** Merge two sorted arrays into one sorted array.
**Reason:** Array merging logic.
**Code:**
```csharp
public int[] MergeSorted(int[] a, int[] b) => a.Concat(b).OrderBy(x => x).ToArray();
```

---

### 8. Find Missing Number in 1-N
**Explanation:** Given N-1 numbers from 1 to N, find the missing one.
**Reason:** Math and array traversal.
**Code:**
```csharp
public int FindMissing(int[] arr, int n) => n*(n+1)/2 - arr.Sum();
```

---

### 9. Count Vowels in a String
**Explanation:** Count number of vowels.
**Reason:** String traversal and conditions.
**Code:**
```csharp
public int CountVowels(string s) => s.Count(c => "aeiouAEIOU".Contains(c));
```

---

### 10. Find Second Largest Element
**Explanation:** Return the second largest number in an array.
**Reason:** Sorting and edge cases.
**Code:**
```csharp
public int SecondLargest(int[] arr) => arr.Distinct().OrderByDescending(x => x).Skip(1).First();
```

---

## Intermediate Level

### 11. Reverse a Linked List
**Explanation:** Reverse a singly linked list.
**Reason:** Pointer manipulation.
**Code:**
```csharp
public ListNode ReverseList(ListNode head) {
    ListNode prev = null, curr = head;
    while (curr != null) {
        var next = curr.next;
        curr.next = prev;
        prev = curr;
        curr = next;
    }
    return prev;
}
```

---

### 12. Detect Cycle in Linked List
**Explanation:** Use Floyd’s cycle-finding algorithm.
**Reason:** Fast/slow pointer logic.
**Code:**
```csharp
public bool HasCycle(ListNode head) {
    var slow = head; var fast = head;
    while (fast?.next != null) {
        slow = slow.next;
        fast = fast.next.next;
        if (slow == fast) return true;
    }
    return false;
}
```

---

### 13. Find Intersection of Two Arrays
**Explanation:** Return common elements.
**Reason:** Set operations.
**Code:**
```csharp
public int[] Intersect(int[] a, int[] b) => a.Intersect(b).ToArray();
```

---

### 14. Move Zeroes to End
**Explanation:** Move all 0s to end, maintain order.
**Reason:** In-place array manipulation.
**Code:**
```csharp
public void MoveZeroes(int[] arr) {
    int j = 0;
    for (int i = 0; i < arr.Length; i++)
        if (arr[i] != 0) arr[j++] = arr[i];
    for (; j < arr.Length; j++) arr[j] = 0;
}
```

---

### 15. Find All Anagrams in a String
**Explanation:** Find all start indices of anagrams of a pattern in a string.
**Reason:** Sliding window, hash maps.
**Code:**
```csharp
public IList<int> FindAnagrams(string s, string p) {
    var res = new List<int>();
    var pCount = new int[26];
    var sCount = new int[26];
    foreach (var c in p) pCount[c - 'a']++;
    for (int i = 0; i < s.Length; i++) {
        sCount[s[i] - 'a']++;
        if (i >= p.Length) sCount[s[i - p.Length] - 'a']--;
        if (i >= p.Length - 1 && pCount.SequenceEqual(sCount)) res.Add(i - p.Length + 1);
    }
    return res;
}
```

---

### 16. Implement Stack Using Array
**Explanation:** Basic stack operations.
**Reason:** Data structure implementation.
**Code:**
```csharp
public class Stack {
    private int[] arr; private int top = -1;
    public Stack(int size) { arr = new int[size]; }
    public void Push(int x) { arr[++top] = x; }
    public int Pop() { return arr[top--]; }
    public int Peek() { return arr[top]; }
}
```

---

### 17. Implement Queue Using Two Stacks
**Explanation:** Use two stacks to simulate a queue.
**Reason:** Stack/queue logic.
**Code:**
```csharp
public class MyQueue {
    Stack<int> s1 = new Stack<int>(), s2 = new Stack<int>();
    public void Enqueue(int x) => s1.Push(x);
    public int Dequeue() {
        if (!s2.Any()) while (s1.Any()) s2.Push(s1.Pop());
        return s2.Pop();
    }
}
```

---

### 18. Find First Non-Repeating Character
**Explanation:** Return index of first unique char.
**Reason:** Hash map usage.
**Code:**
```csharp
public int FirstUniqChar(string s) {
    var dict = new Dictionary<char, int>();
    foreach (var c in s) dict[c] = dict.GetValueOrDefault(c, 0) + 1;
    for (int i = 0; i < s.Length; i++) if (dict[s[i]] == 1) return i;
    return -1;
}
```

---

### 19. Implement Binary Search
**Explanation:** Find element in sorted array.
**Reason:** Classic algorithm.
**Code:**
```csharp
public int BinarySearch(int[] arr, int target) {
    int l = 0, r = arr.Length - 1;
    while (l <= r) {
        int m = l + (r - l) / 2;
        if (arr[m] == target) return m;
        if (arr[m] < target) l = m + 1; else r = m - 1;
    }
    return -1;
}
```

---

### 20. Find GCD of Two Numbers
**Explanation:** Use Euclidean algorithm.
**Reason:** Math logic.
**Code:**
```csharp
public int GCD(int a, int b) => b == 0 ? a : GCD(b, a % b);
```

---

## Advanced Level

### 21. Find All Permutations of a String
**Explanation:** Generate all possible orderings.
**Reason:** Recursion/backtracking.
**Code:**
```csharp
public void Permute(string s, string ans, List<string> res) {
    if (s.Length == 0) { res.Add(ans); return; }
    for (int i = 0; i < s.Length; i++)
        Permute(s.Remove(i,1), ans + s[i], res);
}
```

---

### 22. Longest Substring Without Repeating Characters
**Explanation:** Find length of longest substring with unique chars.
**Reason:** Sliding window.
**Code:**
```csharp
public int LengthOfLongestSubstring(string s) {
    var set = new HashSet<char>();
    int l = 0, res = 0;
    for (int r = 0; r < s.Length; r++) {
        while (!set.Add(s[r])) set.Remove(s[l++]);
        res = Math.Max(res, r - l + 1);
    }
    return res;
}
```

---

### 23. Merge Intervals
**Explanation:** Merge overlapping intervals.
**Reason:** Sorting and interval logic.
**Code:**
```csharp
public int[][] Merge(int[][] intervals) {
    if (intervals.Length == 0) return intervals;
    Array.Sort(intervals, (a, b) => a[0] - b[0]);
    var res = new List<int[]>();
    var curr = intervals[0];
    foreach (var next in intervals.Skip(1)) {
        if (curr[1] >= next[0]) curr[1] = Math.Max(curr[1], next[1]);
        else { res.Add(curr); curr = next; }
    }
    res.Add(curr);
    return res.ToArray();
}
```

---

### 24. Find Kth Largest Element
**Explanation:** Return kth largest in array.
**Reason:** Heap/quickselect.
**Code:**
```csharp
public int FindKthLargest(int[] nums, int k) => nums.OrderByDescending(x => x).ElementAt(k-1);
```

---

### 25. Implement LRU Cache
**Explanation:** Least Recently Used cache with O(1) operations.
**Reason:** Data structure design.
**Code:**
```csharp
public class LRUCache {
    private int cap;
    private LinkedList<(int key, int val)> list = new();
    private Dictionary<int, LinkedListNode<(int, int)>> map = new();
    public LRUCache(int capacity) { cap = capacity; }
    public int Get(int key) {
        if (!map.ContainsKey(key)) return -1;
        var node = map[key];
        list.Remove(node); list.AddFirst(node);
        return node.Value.val;
    }
    public void Put(int key, int value) {
        if (map.ContainsKey(key)) list.Remove(map[key]);
        else if (list.Count == cap) { map.Remove(list.Last.Value.key); list.RemoveLast(); }
        var node = new LinkedListNode<(int, int)>((key, value));
        list.AddFirst(node); map[key] = node;
    }
}
```

---

### 26. Find All Subsets (Power Set)
**Explanation:** Generate all subsets.
**Reason:** Recursion/bitmasking.
**Code:**
```csharp
public IList<IList<int>> Subsets(int[] nums) {
    var res = new List<IList<int>>();
    int n = nums.Length;
    for (int i = 0; i < (1 << n); i++) {
        var subset = new List<int>();
        for (int j = 0; j < n; j++) if (((i >> j) & 1) == 1) subset.Add(nums[j]);
        res.Add(subset);
    }
    return res;
}
```

---

### 27. Find Lowest Common Ancestor in BST
**Explanation:** Return LCA of two nodes.
**Reason:** Tree traversal.
**Code:**
```csharp
public TreeNode LCA(TreeNode root, TreeNode p, TreeNode q) {
    if (root == null) return null;
    if (p.val < root.val && q.val < root.val) return LCA(root.left, p, q);
    if (p.val > root.val && q.val > root.val) return LCA(root.right, p, q);
    return root;
}
```

---

### 28. Serialize and Deserialize Binary Tree
**Explanation:** Convert tree to string and back.
**Reason:** Recursion, data encoding.
**Code:**
```csharp
public string Serialize(TreeNode root) {
    if (root == null) return "#";
    return root.val + "," + Serialize(root.left) + "," + Serialize(root.right);
}
public TreeNode Deserialize(string data) {
    var q = new Queue<string>(data.Split(','));
    TreeNode D() {
        var val = q.Dequeue();
        if (val == "#") return null;
        var node = new TreeNode(int.Parse(val));
        node.left = D(); node.right = D();
        return node;
    }
    return D();
}
```

---

### 29. Implement Min Stack
**Explanation:** Stack with O(1) min retrieval.
**Reason:** Stack/auxiliary data structure.
**Code:**
```csharp
public class MinStack {
    Stack<int> s = new(), minS = new();
    public void Push(int x) {
        s.Push(x);
        if (!minS.Any() || x <= minS.Peek()) minS.Push(x);
    }
    public void Pop() {
        if (s.Pop() == minS.Peek()) minS.Pop();
    }
    public int Top() => s.Peek();
    public int GetMin() => minS.Peek();
}
```

---

### 30. Find Median from Data Stream
**Explanation:** Add numbers and get median at any time.
**Reason:** Heaps, streaming data.
**Code:**
```csharp
public class MedianFinder {
    private PriorityQueue<int, int> min = new(), max = new();
    public void AddNum(int num) {
        max.Enqueue(-num, -num);
        min.Enqueue(-max.Dequeue(), -max.Peek());
        if (min.Count > max.Count) max.Enqueue(-min.Dequeue(), -min.Peek());
    }
    public double FindMedian() => max.Count > min.Count ? -max.Peek() : (-max.Peek() + min.Peek()) / 2.0;
}
```

---

## Expert Level

### 31. Implement Trie (Prefix Tree)
**Explanation:** Insert/search words efficiently.
**Reason:** Data structure design.
**Code:**
```csharp
public class Trie {
    private class Node { public bool End; public Node[] Next = new Node[26]; }
    private Node root = new();
    public void Insert(string word) {
        var node = root;
        foreach (var c in word) {
            int i = c - 'a';
            if (node.Next[i] == null) node.Next[i] = new Node();
            node = node.Next[i];
        }
        node.End = true;
    }
    public bool Search(string word) {
        var node = root;
        foreach (var c in word) {
            int i = c - 'a';
            if (node.Next[i] == null) return false;
            node = node.Next[i];
        }
        return node.End;
    }
}
```

---

### 32. Word Ladder (BFS)
**Explanation:** Shortest transformation sequence from begin to end word.
**Reason:** Graph traversal.
**Code:**
```csharp
public int LadderLength(string begin, string end, IList<string> wordList) {
    var set = new HashSet<string>(wordList);
    var q = new Queue<(string, int)>();
    q.Enqueue((begin, 1));
    while (q.Any()) {
        var (word, len) = q.Dequeue();
        if (word == end) return len;
        for (int i = 0; i < word.Length; i++)
            for (char c = 'a'; c <= 'z'; c++) {
                var next = word.Substring(0, i) + c + word[(i+1)..];
                if (set.Remove(next)) q.Enqueue((next, len+1));
            }
    }
    return 0;
}
```

---

### 33. Top K Frequent Elements
**Explanation:** Return k most frequent elements.
**Reason:** Hash map, heap.
**Code:**
```csharp
public int[] TopKFrequent(int[] nums, int k) =>
    nums.GroupBy(x => x).OrderByDescending(g => g.Count()).Take(k).Select(g => g.Key).ToArray();
```

---

### 34. Course Schedule (Cycle Detection in Graph)
**Explanation:** Can you finish all courses given prerequisites?
**Reason:** Graph, DFS, cycle detection.
**Code:**
```csharp
public bool CanFinish(int n, int[][] prereq) {
    var g = new List<int>[n];
    for (int i = 0; i < n; i++) g[i] = new();
    foreach (var p in prereq) g[p[0]].Add(p[1]);
    var visited = new int[n];
    bool Dfs(int u) {
        if (visited[u] == 1) return false;
        if (visited[u] == 2) return true;
        visited[u] = 1;
        foreach (var v in g[u]) if (!Dfs(v)) return false;
        visited[u] = 2;
        return true;
    }
    for (int i = 0; i < n; i++) if (!Dfs(i)) return false;
    return true;
}
```

---

### 35. Implement Thread-Safe Singleton
**Explanation:** Only one instance, thread-safe.
**Reason:** Concurrency, design pattern.
**Code:**
```csharp
public sealed class Singleton {
    private static readonly Lazy<Singleton> instance = new(() => new Singleton());
    public static Singleton Instance => instance.Value;
    private Singleton() { }
}
```

---

### 36. Producer-Consumer Using BlockingCollection
**Explanation:** Thread-safe queue for producer/consumer.
**Reason:** Concurrency.
**Code:**
```csharp
BlockingCollection<int> queue = new();
Task.Run(() => { for (int i = 0; i < 10; i++) queue.Add(i); queue.CompleteAdding(); });
Task.Run(() => { foreach (var x in queue.GetConsumingEnumerable()) Console.WriteLine(x); });
```

---

### 37. Implement Observer Pattern
**Explanation:** Notify subscribers on change.
**Reason:** Design pattern.
**Code:**
```csharp
public interface IObserver { void Update(); }
public class Subject {
    private List<IObserver> obs = new();
    public void Attach(IObserver o) => obs.Add(o);
    public void Notify() { foreach (var o in obs) o.Update(); }
}
```

---

### 38. Implement Dependency Injection Manually
**Explanation:** Inject dependencies via constructor.
**Reason:** Design pattern.
**Code:**
```csharp
public class Service { }
public class Consumer {
    private Service _service;
    public Consumer(Service service) { _service = service; }
}
```

---

### 39. Implement Custom Attribute and Use Reflection
**Explanation:** Add metadata and read it at runtime.
**Reason:** Reflection, attributes.
**Code:**
```csharp
[AttributeUsage(AttributeTargets.Class)]
public class MyAttr : Attribute { public string Info; public MyAttr(string info) { Info = info; } }
[MyAttr("Test")] public class TestClass { }
var attr = (MyAttr)Attribute.GetCustomAttribute(typeof(TestClass), typeof(MyAttr));
```

---

### 40. Implement Async/Await for I/O Operation
**Explanation:** Read file asynchronously.
**Reason:** Async programming.
**Code:**
```csharp
public async Task<string> ReadFileAsync(string path) => await File.ReadAllTextAsync(path);
```

---

## System Design & Real-World Scenarios

### 41. Design a URL Shortener (Core Logic)
**Explanation:** Map long URLs to short codes.
**Reason:** Hashing, dictionary.
**Code:**
```csharp
public class UrlShortener {
    private Dictionary<string, string> map = new();
    public string Shorten(string url) {
        var code = Guid.NewGuid().ToString()[..6];
        map[code] = url; return code;
    }
    public string Restore(string code) => map.TryGetValue(code, out var url) ? url : null;
}
```

---

### 42. Rate Limiter (Token Bucket)
**Explanation:** Allow N requests per time window.
**Reason:** Concurrency, real-world system.
**Code:**
```csharp
public class RateLimiter {
    private int tokens, capacity;
    private DateTime last;
    private TimeSpan interval;
    public RateLimiter(int cap, TimeSpan win) { capacity = tokens = cap; interval = win; last = DateTime.Now; }
    public bool Allow() {
        var now = DateTime.Now;
        tokens += (int)((now - last).TotalMilliseconds / interval.TotalMilliseconds);
        if (tokens > capacity) tokens = capacity;
        last = now;
        if (tokens == 0) return false;
        tokens--;
        return true;
    }
}
```

---

### 43. Design a Thread Pool
**Explanation:** Manage a pool of worker threads.
**Reason:** Concurrency, resource management.
**Code:**
```csharp
public class SimpleThreadPool {
    private Queue<Action> tasks = new();
    private List<Thread> workers = new();
    private bool running = true;
    public SimpleThreadPool(int n) {
        for (int i = 0; i < n; i++) workers.Add(new Thread(Work) { IsBackground = true });
        workers.ForEach(t => t.Start());
    }
    public void Enqueue(Action a) { lock (tasks) { tasks.Enqueue(a); Monitor.Pulse(tasks); } }
    private void Work() {
        while (running) {
            Action a = null;
            lock (tasks) { while (!tasks.Any()) Monitor.Wait(tasks); a = tasks.Dequeue(); }
            a();
        }
    }
}
```

---

### 44. Implement a Logger (Thread-Safe)
**Explanation:** Log messages from multiple threads.
**Reason:** Concurrency, file I/O.
**Code:**
```csharp
public class Logger {
    private static readonly object _lock = new();
    public static void Log(string msg) {
        lock (_lock) File.AppendAllText("log.txt", msg + "\n");
    }
}
```

---

### 45. Implement a Scheduler (Delayed Task Execution)
**Explanation:** Run tasks after a delay.
**Reason:** Timers, threading.
**Code:**
```csharp
public class Scheduler {
    public void Schedule(Action a, int ms) => Task.Delay(ms).ContinueWith(_ => a());
}
```

---

### 46. Implement a Simple Cache with Expiry
**Explanation:** Store key-value pairs with TTL.
**Reason:** Dictionary, timers.
**Code:**
```csharp
public class SimpleCache<T> {
    private Dictionary<string, (T val, DateTime exp)> map = new();
    public void Set(string k, T v, int sec) => map[k] = (v, DateTime.Now.AddSeconds(sec));
    public T Get(string k) => map.TryGetValue(k, out var v) && v.exp > DateTime.Now ? v.val : default;
}
```

---

### 47. Implement a Blocking Queue
**Explanation:** Thread-safe queue with blocking dequeue.
**Reason:** Concurrency.
**Code:**
```csharp
public class BlockingQueue<T> {
    private Queue<T> q = new();
    private SemaphoreSlim sem = new(0);
    public void Enqueue(T item) { lock (q) q.Enqueue(item); sem.Release(); }
    public T Dequeue() { sem.Wait(); lock (q) return q.Dequeue(); }
}
```

---

### 48. Implement a Publish-Subscribe System
**Explanation:** Subscribers receive published messages.
**Reason:** Event-driven design.
**Code:**
```csharp
public class PubSub<T> {
    private List<Action<T>> subs = new();
    public void Subscribe(Action<T> a) => subs.Add(a);
    public void Publish(T msg) { foreach (var s in subs) s(msg); }
}
```

---

### 49. Implement a Memory Pool
**Explanation:** Reuse objects to reduce allocations.
**Reason:** Performance.
**Code:**
```csharp
public class ObjectPool<T> where T : new() {
    private Stack<T> pool = new();
    public T Get() => pool.Any() ? pool.Pop() : new T();
    public void Return(T obj) => pool.Push(obj);
}
```

---

### 50. Implement a Custom LINQ Extension
**Explanation:** Add a custom extension method to IEnumerable.
**Reason:** LINQ, extension methods.
**Code:**
```csharp
public static class LinqExt {
    public static IEnumerable<T> WhereEven<T>(this IEnumerable<T> src, Func<T, int> selector) => src.Where(x => selector(x) % 2 == 0);
}
```

---

## Expert/Architect Level

### 51. Implement a Custom Serialization/Deserialization
**Explanation:** Convert object to string and back.
**Reason:** Reflection, data encoding.
**Code:**
```csharp
public string Serialize<T>(T obj) => JsonConvert.SerializeObject(obj);
public T Deserialize<T>(string s) => JsonConvert.DeserializeObject<T>(s);
```

---

### 52. Implement a Circuit Breaker Pattern
**Explanation:** Prevent repeated failures in distributed systems.
**Reason:** Resilience.
**Code:**
```csharp
public class CircuitBreaker {
    private int failures = 0, threshold = 3;
    private DateTime? openUntil = null;
    public bool Allow() => openUntil == null || DateTime.Now > openUntil;
    public void OnFailure() { if (++failures >= threshold) openUntil = DateTime.Now.AddSeconds(10); }
    public void OnSuccess() { failures = 0; openUntil = null; }
}
```

---

### 53. Implement a Retry Policy
**Explanation:** Retry failed operations with backoff.
**Reason:** Reliability.
**Code:**
```csharp
public async Task<T> Retry<T>(Func<Task<T>> op, int max, int delayMs) {
    for (int i = 0; i < max; i++) {
        try { return await op(); } catch { if (i == max-1) throw; await Task.Delay(delayMs); }
    }
    return default;
}
```

---

### 54. Implement a Custom Middleware in ASP.NET Core
**Explanation:** Intercept HTTP requests.
**Reason:** Web pipeline.
**Code:**
```csharp
public class MyMiddleware {
    private readonly RequestDelegate _next;
    public MyMiddleware(RequestDelegate next) { _next = next; }
    public async Task Invoke(HttpContext ctx) {
        // Do something
        await _next(ctx);
    }
}
```

---

### 55. Implement a Custom Model Binder in ASP.NET Core
**Explanation:** Bind HTTP request data to model.
**Reason:** Web API customization.
**Code:**
```csharp
public class CustomBinder : IModelBinder {
    public Task BindModelAsync(ModelBindingContext ctx) {
        // Custom binding logic
        return Task.CompletedTask;
    }
}
```

---

### 56. Implement a Custom Exception Filter in ASP.NET Core
**Explanation:** Handle exceptions globally.
**Reason:** Error handling.
**Code:**
```csharp
public class MyExceptionFilter : IExceptionFilter {
    public void OnException(ExceptionContext ctx) {
        // Custom error response
    }
}
```

---

### 57. Implement a Custom Authorization Attribute
**Explanation:** Restrict access to controllers/actions.
**Reason:** Security.
**Code:**
```csharp
public class MyAuthAttribute : AuthorizeAttribute {
    protected override bool IsAuthorized(HttpActionContext ctx) {
        // Custom logic
        return true;
    }
}
```

---

### 58. Implement a Custom Validation Attribute
**Explanation:** Validate model properties.
**Reason:** Data validation.
**Code:**
```csharp
public class MyValidationAttribute : ValidationAttribute {
    public override bool IsValid(object value) {
        // Custom validation
        return true;
    }
}
```

---

### 59. Implement a Custom Logging Provider
**Explanation:** Log to custom destination.
**Reason:** Observability.
**Code:**
```csharp
public class MyLoggerProvider : ILoggerProvider {
    public ILogger CreateLogger(string category) => new MyLogger();
    public void Dispose() { }
}
public class MyLogger : ILogger {
    public IDisposable BeginScope<TState>(TState state) => null;
    public bool IsEnabled(LogLevel level) => true;
    public void Log<TState>(LogLevel level, EventId id, TState state, Exception ex, Func<TState, Exception, string> formatter) {
        // Custom log
    }
}
```

---

### 60. Implement a Custom Dependency Injection Container
**Explanation:** Register and resolve dependencies.
**Reason:** Framework design.
**Code:**
```csharp
public class SimpleContainer {
    private Dictionary<Type, Func<object>> map = new();
    public void Register<T>(Func<T> f) => map[typeof(T)] = () => f();
    public T Resolve<T>() => (T)map[typeof(T)]();
}
```

---

*This list is based on real interview coding rounds and expert recommendations for senior .NET developers in India.*
