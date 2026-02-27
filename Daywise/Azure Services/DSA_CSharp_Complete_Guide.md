# DSA — Complete Study Guide
### C# Edition · Beginner → FAANG Expert · Mental Models · Patterns · Practice

> **How to use this guide**
> - **Beginner**: Read Parts 1–3 linearly, do every practice problem before moving on
> - **Intermediate**: Jump to Part 9 (Patterns) first, then revisit weak topic sections
> - **Interview prep**: Start with Section 50 (cheat sheet), identify gaps, fill them
> - **Each section is self-contained**: Mental model → concept → code → complexity → practice
> - **Practice problems**: Full C# solutions included — attempt the problem BEFORE reading the solution

---

## Table of Contents

### PART 1 — FOUNDATIONS & MENTAL MODELS
- [Section 1 — How to Think Like an Algorithm Designer (UMPIRE)](#section-1--how-to-think-like-an-algorithm-designer)
- [Section 2 — Complexity Analysis: Big O, Big Θ, Big Ω](#section-2--complexity-analysis)
- [Section 3 — Space-Time Trade-offs & Amortized Analysis](#section-3--space-time-trade-offs--amortized-analysis)
- [Section 4 — The 14 Problem-Solving Patterns (Catalog)](#section-4--the-14-problem-solving-patterns-catalog)

### PART 2 — LINEAR DATA STRUCTURES
- [Section 5 — Arrays](#section-5--arrays)
- [Section 6 — Strings](#section-6--strings)
- [Section 7 — Linked Lists](#section-7--linked-lists)
- [Section 8 — Stacks](#section-8--stacks)
- [Section 9 — Queues & Deques](#section-9--queues--deques)

### PART 3 — HASH-BASED STRUCTURES
- [Section 10 — Hash Maps (Dictionary)](#section-10--hash-maps-dictionary)
- [Section 11 — Hash Sets](#section-11--hash-sets)

### PART 4 — TREE DATA STRUCTURES
- [Section 12 — Binary Trees](#section-12--binary-trees)
- [Section 13 — Binary Search Trees (BST)](#section-13--binary-search-trees-bst)
- [Section 14 — Heaps & Priority Queues](#section-14--heaps--priority-queues)
- [Section 15 — Tries (Prefix Trees)](#section-15--tries-prefix-trees)
- [Section 16 — Advanced Trees (AVL, Segment, Fenwick)](#section-16--advanced-trees)

### PART 5 — GRAPH DATA STRUCTURES
- [Section 17 — Graph Fundamentals](#section-17--graph-fundamentals)
- [Section 18 — Graph Traversals: DFS & BFS](#section-18--graph-traversals-dfs--bfs)
- [Section 19 — Shortest Path Algorithms](#section-19--shortest-path-algorithms)
- [Section 20 — Minimum Spanning Trees](#section-20--minimum-spanning-trees)
- [Section 21 — Advanced Graphs (Topological Sort, Union-Find)](#section-21--advanced-graphs)

### PART 6 — SORTING ALGORITHMS
- [Section 22 — O(n²) Sorts (Bubble, Selection, Insertion)](#section-22--on²-sorts)
- [Section 23 — O(n log n) Sorts (Merge, Quick, Heap)](#section-23--on-log-n-sorts)
- [Section 24 — O(n) Sorts (Counting, Radix, Bucket)](#section-24--on-sorts)
- [Section 25 — .NET Sorting APIs](#section-25--net-sorting-apis)

### PART 7 — SEARCHING ALGORITHMS
- [Section 26 — Linear Search & Variants](#section-26--linear-search--variants)
- [Section 27 — Binary Search (Classic + Advanced)](#section-27--binary-search)
- [Section 28 — Interpolation & Exponential Search](#section-28--interpolation--exponential-search)

### PART 8 — ALGORITHM DESIGN PARADIGMS
- [Section 29 — Recursion & the Recursion Tree](#section-29--recursion--the-recursion-tree)
- [Section 30 — Backtracking](#section-30--backtracking)
- [Section 31 — Divide & Conquer](#section-31--divide--conquer)
- [Section 32 — Dynamic Programming: Memoization](#section-32--dynamic-programming-memoization)
- [Section 33 — Dynamic Programming: Tabulation](#section-33--dynamic-programming-tabulation)
- [Section 34 — Classic DP Problems](#section-34--classic-dp-problems)
- [Section 35 — Greedy Algorithms](#section-35--greedy-algorithms)

### PART 9 — PROBLEM-SOLVING PATTERNS
- [Section 36 — Two Pointers](#section-36--two-pointers)
- [Section 37 — Sliding Window](#section-37--sliding-window)
- [Section 38 — Fast & Slow Pointers (Floyd's)](#section-38--fast--slow-pointers)
- [Section 39 — Merge Intervals](#section-39--merge-intervals)
- [Section 40 — Cyclic Sort](#section-40--cyclic-sort)
- [Section 41 — In-place Linked List Reversal](#section-41--in-place-linked-list-reversal)
- [Section 42 — Modified Binary Search](#section-42--modified-binary-search)
- [Section 43 — Top K Elements & K-way Merge](#section-43--top-k-elements--k-way-merge)
- [Section 44 — Monotonic Stack & Queue](#section-44--monotonic-stack--queue)
- [Section 45 — Bit Manipulation](#section-45--bit-manipulation)
- [Section 46 — Subsets & Combinations](#section-46--subsets--combinations)
- [Section 47 — Math & Number Theory](#section-47--math--number-theory)

### PART 10 — STRING ALGORITHMS
- [Section 48 — String Patterns (Anagram, Palindrome, Hashing)](#section-48--string-patterns)
- [Section 49 — Advanced String Matching (KMP, Rabin-Karp)](#section-49--advanced-string-matching)

### PART 11 — INTERVIEW REFERENCE
- [Section 50 — Product Company Cheat Sheet & Interview Guide](#section-50--product-company-cheat-sheet)

---

# PART 1 — FOUNDATIONS & MENTAL MODELS

---

## Section 1 — How to Think Like an Algorithm Designer

> **🧠 Mental Model: The Chef Preparing a Dish**
>
> A great chef doesn't just start cooking randomly. They: **Understand** the dish → **Map** out ingredients → **Plan** steps → **Implement** → **Review** taste → **Evaluate** presentation. Algorithm design is the same structured process. The UMPIRE framework is your recipe card.

### The UMPIRE Framework (6 Steps for Every Interview Problem)

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE UMPIRE FRAMEWORK                         │
├─────────┬───────────────────────────────────────────────────────┤
│    U    │  UNDERSTAND — Restate the problem in your own words   │
│    M    │  MATCH — Which data structure / pattern fits?         │
│    P    │  PLAN — Pseudocode the approach before coding         │
│    I    │  IMPLEMENT — Write clean code                         │
│    R    │  REVIEW — Trace through with example + edge cases     │
│    E    │  EVALUATE — State time & space complexity             │
└─────────┴───────────────────────────────────────────────────────┘
```

### U — Understand (3–5 minutes)
Ask clarifying questions BEFORE writing any code. Interviewers reward this.

```
Questions to always ask:
1. What are the input types and ranges? (ints, strings, arrays — null? empty? negative?)
2. What should I return? (index, value, bool, modified input?)
3. Are there duplicates? Is the input sorted?
4. What are the constraints? (n ≤ 10^5 means O(n log n) is fine; n ≤ 10^9 means O(log n))
5. Can I modify the input in-place?
```

### M — Match (Pattern Recognition)
```
If input is array/string        → Two Pointers, Sliding Window, Binary Search
If input is LinkedList          → Fast/Slow Pointers, In-place Reversal
If input is Tree                → DFS (recursion), BFS (queue)
If input is Graph               → DFS/BFS + visited set
If problem asks for "all combos" → Backtracking
If problem asks "optimal value"  → DP or Greedy
If problem asks "top K"          → Heap (PriorityQueue)
If problem needs fast lookup     → HashMap / HashSet
If problem has sorted structure  → Binary Search
```

### P — Plan (Write Pseudocode)
Never skip this. Write 3–5 lines of pseudocode first. This catches logical errors before you get deep into implementation.

### I — Implement (Write Clean C# Code)
```csharp
// Use descriptive variable names (not i,j if context is unclear)
// Write helper methods for repeated logic
// Handle edge cases explicitly at the TOP of the function
// int.MaxValue / 2 instead of int.MaxValue to avoid overflow when adding
```

### R — Review (Trace Through an Example)
Pick the simplest non-trivial example and trace through manually. Then check:
- Empty input
- Single element
- All same elements
- Already sorted / reverse sorted
- Negative numbers / zero

### E — Evaluate (Complexity)
Always state both:
- **Time complexity**: with justification ("O(n log n) because we sort once")
- **Space complexity**: include recursion stack for recursive solutions

> **🎯 Key Insight:** Most interviewers care more about your THINKING PROCESS (steps U, M, P) than the final code. Talking out loud during these steps separates good candidates from great ones.

---

## Section 2 — Complexity Analysis

> **🧠 Mental Model: The Russian Nesting Dolls**
>
> Big O describes HOW FAST a function grows, not the actual time. A loop inside a loop is O(n²) — like opening a doll to find another doll. The outer doll is one n, the inner doll multiplies by another n. The constant (paint color, size ratio) doesn't matter at scale — only the nesting depth does.

### The Big O Hierarchy (from fastest to slowest)

```
┌──────────────────────────────────────────────────────────┐
│  COMPLEXITY GROWTH (n = 1,000,000 operations)            │
├──────────────┬──────────────┬────────────────────────────┤
│  Notation    │  n=100 ops   │  Name / Example            │
├──────────────┼──────────────┼────────────────────────────┤
│  O(1)        │  1           │  Constant — array access   │
│  O(log n)    │  7           │  Logarithmic — binary srch │
│  O(n)        │  100         │  Linear — single loop      │
│  O(n log n)  │  700         │  Log-linear — merge sort   │
│  O(n²)       │  10,000      │  Quadratic — nested loops  │
│  O(2ⁿ)       │  10^30       │  Exponential — all subsets │
│  O(n!)       │  9 * 10^157  │  Factorial — permutations  │
└──────────────┴──────────────┴────────────────────────────┘
```

### Big O Rules (Drop Constants, Keep Dominants)

```csharp
// Rule 1: Drop constants
// O(2n) → O(n)
for (int i = 0; i < n; i++) { }  // O(n)
for (int i = 0; i < n; i++) { }  // O(n)
// Total: O(2n) = O(n)

// Rule 2: Drop non-dominant terms
// O(n² + n) → O(n²)
for (int i = 0; i < n; i++)          // O(n)
    for (int j = 0; j < n; j++) { }  // O(n) inside = O(n²)
for (int k = 0; k < n; k++) { }      // O(n) — dominated by n²
// Total: O(n² + n) = O(n²)

// Rule 3: Different inputs = different variables
// O(a + b) — NOT O(n)
for (int i = 0; i < a.Length; i++) { }  // O(a)
for (int j = 0; j < b.Length; j++) { }  // O(b)
// Total: O(a + b) — use separate variables for separate inputs

// Rule 4: Nested loops multiply
// O(n * m)
for (int i = 0; i < n; i++)
    for (int j = 0; j < m; j++) { }  // O(n * m)
```

### Complexity by Problem Constraint (Interview cheat)

```
n ≤ 10        → O(n!) is fine (backtracking with small n)
n ≤ 20        → O(2ⁿ) is fine
n ≤ 500       → O(n²) is fine
n ≤ 5,000     → O(n² log n) might work
n ≤ 100,000   → O(n log n) needed
n ≤ 1,000,000 → O(n) needed
n ≤ 10^9      → O(log n) or O(1) only
```

### Space Complexity

```csharp
// O(1) — no extra space proportional to input
int sum = 0;
for (int i = 0; i < arr.Length; i++) sum += arr[i];

// O(n) — extra array or dictionary proportional to input
var dict = new Dictionary<int, int>();  // grows with n

// O(log n) — recursion stack for binary search / balanced tree DFS
// O(n) — recursion stack for linear recursion (unbalanced tree DFS)
// O(h) — tree height h for tree DFS (best case log n, worst case n)
```

> **🎯 Key Insight:** Recursion always has hidden space cost — the call stack. A recursive DFS on a tree of depth h uses O(h) space even with no explicit data structures. For a balanced tree h = O(log n); for a skewed tree h = O(n).

---

## Section 3 — Space-Time Trade-offs & Amortized Analysis

> **🧠 Mental Model: The Pre-cooked Meal vs. Fresh Cooking**
>
> Space-time trade-off: you can cook from scratch every time (slow, low memory) OR pre-cook and store in fridge (fast, uses space). Caching/memoization is the "pre-cooked meal" strategy. Amortized analysis: spreading the occasional expensive operation (restock the fridge) across many cheap operations (grab from fridge).

### Space-Time Trade-off Examples

```csharp
// PROBLEM: Check if array has duplicates

// Option 1: O(n²) time, O(1) space — no extra storage
bool HasDuplicateBrute(int[] arr) {
    for (int i = 0; i < arr.Length; i++)
        for (int j = i + 1; j < arr.Length; j++)
            if (arr[i] == arr[j]) return true;
    return false;
}

// Option 2: O(n) time, O(n) space — trade space for speed
bool HasDuplicateOptimal(int[] arr) {
    var seen = new HashSet<int>();  // O(n) space
    foreach (int x in arr) {
        if (!seen.Add(x)) return true;  // Add returns false if duplicate
    }
    return false;
}
// Decision: If memory is limited → use Option 1; if speed matters → Option 2
```

### Amortized Analysis — Dynamic Array (List\<T\>)

```csharp
// List<T> doubles capacity when full. Each doubling is O(n), but rare.
// Amortized cost per Add() = O(1) because doublings happen less and less.

// Proof: n operations on List<T>
// Copies: n/2 + n/4 + n/8 + ... ≤ n
// Total copies ≤ n → amortized O(1) per operation

var list = new List<int>();  // capacity starts at 4
for (int i = 0; i < 1000; i++)
    list.Add(i);  // O(1) amortized — occasional O(n) doubling happens
```

### When to Choose Which

| Scenario | Choice | Reason |
|----------|--------|--------|
| Memory-constrained embedded system | Time cost | Space is precious |
| Web API serving millions of requests | Space cost | Speed matters more |
| One-time batch job | Either | Optimize for simplicity |
| Repeated lookups on same data | Cache (space) | Avoid recomputation |
| Streaming data (can't store) | Time cost | Can't store all input |

---

## Section 4 — The 14 Problem-Solving Patterns Catalog

> **🧠 Mental Model: A Doctor's Diagnostic Playbook**
>
> Doctors don't diagnose from scratch each time — they match symptoms to known patterns. Similarly, 95% of coding problems map to one of ~14 patterns. Once you recognize the pattern, the solution structure is mostly known. The skill is PATTERN RECOGNITION, not memorizing every problem.

### The 14 Patterns — Quick Reference

```
┌───┬──────────────────────────┬─────────────────────────────────────────┐
│ # │  Pattern                 │  Trigger Keywords                       │
├───┼──────────────────────────┼─────────────────────────────────────────┤
│ 1 │  Two Pointers            │  sorted array, pair sum, palindrome     │
│ 2 │  Sliding Window          │  subarray/substring, contiguous, max/min│
│ 3 │  Fast & Slow Pointers    │  cycle detection, middle of list        │
│ 4 │  Merge Intervals         │  overlapping intervals, meeting rooms   │
│ 5 │  Cyclic Sort             │  numbers 1–n, find missing/duplicate    │
│ 6 │  Linked List Reversal    │  reverse in-place, reverse sublist      │
│ 7 │  Tree BFS                │  level-by-level, shortest path in tree  │
│ 8 │  Tree DFS                │  path sum, all paths, depth             │
│ 9 │  Two Heaps               │  median of stream, scheduling           │
│10 │  Subsets                 │  all combinations, power set            │
│11 │  Modified Binary Search  │  sorted+rotated, bitonic, first/last    │
│12 │  Top K Elements          │  k largest/smallest/frequent            │
│13 │  K-way Merge             │  merge k sorted lists/arrays            │
│14 │  Topological Sort        │  dependencies, course prerequisites     │
└───┴──────────────────────────┴─────────────────────────────────────────┘
```

### Pattern Decision Tree

```
Is the input sorted (or can be sorted)?
├── YES → Binary Search or Two Pointers
└── NO
    Is it a contiguous subarray/substring problem?
    ├── YES → Sliding Window
    └── NO
        Is it a LinkedList problem?
        ├── YES → Fast/Slow Pointers or In-place Reversal
        └── NO
            Is it a Tree/Graph problem?
            ├── TREE → BFS (level order) or DFS (path/depth)
            └── GRAPH → BFS (shortest path) or DFS (connectivity)
                Is it "find all combinations/subsets"?
                ├── YES → Backtracking / Subsets pattern
                └── NO
                    Does it ask for "optimal" (max/min)?
                    ├── YES → DP (overlapping subproblems?) or Greedy
                    └── NO → HashMap/HashSet for O(1) lookup
```

> **🎯 Key Insight:** Spend 3–5 minutes on pattern matching (Step M of UMPIRE) before any coding. Saying "this looks like a sliding window problem" immediately shows the interviewer you have structured problem-solving skills.

---

# PART 2 — LINEAR DATA STRUCTURES

---

## Section 5 — Arrays

> **🧠 Mental Model: A Parking Lot**
>
> An array is like a numbered parking lot. Every spot has a fixed number (index 0, 1, 2...). You can drive directly to spot #42 in O(1) — no need to check spots 0–41. But if you want to INSERT a spot between 3 and 4, you must physically move every car after spot 3 — that's O(n). The lot has a fixed size — if it's full and you need more space, you build a new bigger lot and move every car (that's how `List<T>` resizes).

### Array Layout in Memory

```
Index:  0     1     2     3     4
      ┌─────┬─────┬─────┬─────┬─────┐
      │  10 │  20 │  30 │  40 │  50 │
      └─────┴─────┴─────┴─────┴─────┘
        ↑                             ↑
     base addr                   base + 4*4 (int = 4 bytes)

Random access: arr[i] = base_address + i * element_size  → O(1)
```

### C# Array Operations

```csharp
// DECLARATION
int[] arr = new int[5];                    // fixed size, all zeros
int[] arr2 = { 1, 2, 3, 4, 5 };           // initialize with values
int[,] matrix = new int[3, 4];            // 2D array (3 rows, 4 cols)
int[][] jagged = new int[3][];            // jagged array (rows can differ)

// DYNAMIC ARRAY — List<T> (preferred in C#)
var list = new List<int> { 1, 2, 3 };
list.Add(4);                               // O(1) amortized
list.Insert(1, 99);                        // O(n) — shifts elements right
list.RemoveAt(2);                          // O(n) — shifts elements left
list.Contains(99);                         // O(n) — linear search

// USEFUL OPERATIONS
Array.Sort(arr);                           // O(n log n) — introsort
Array.Reverse(arr);                        // O(n)
Array.BinarySearch(arr, 30);              // O(log n) — array must be sorted
int[] copy = (int[])arr.Clone();           // shallow copy
Array.Fill(arr, 0);                        // fill all with value

// 2D ARRAY TRAVERSAL
for (int row = 0; row < matrix.GetLength(0); row++)
    for (int col = 0; col < matrix.GetLength(1); col++)
        Console.Write(matrix[row, col]);

// COMMON IDIOMS
int[] prefix = new int[arr.Length + 1];   // prefix sum array
for (int i = 0; i < arr.Length; i++)
    prefix[i + 1] = prefix[i] + arr[i];   // prefix[i] = sum of arr[0..i-1]
// Range sum [l, r] = prefix[r+1] - prefix[l]  → O(1) after O(n) build
```

### Complexity Table

| Operation | Array (fixed) | List\<T\> (dynamic) |
|-----------|--------------|---------------------|
| Access by index | O(1) | O(1) |
| Search (unsorted) | O(n) | O(n) |
| Search (sorted) | O(log n) | O(log n) |
| Insert at end | N/A (fixed) | O(1) amortized |
| Insert at middle | N/A (fixed) | O(n) |
| Delete at end | N/A (fixed) | O(1) |
| Delete at middle | N/A (fixed) | O(n) |
| Space | O(n) | O(n) |

### Common Pitfalls
- ⚠️ Off-by-one errors: `arr[arr.Length]` throws `IndexOutOfRangeException`
- ⚠️ Integer overflow: `int mid = (left + right) / 2` can overflow — use `left + (right - left) / 2`
- ⚠️ Modifying array while iterating with `foreach` — use index-based `for` instead
- ⚠️ `arr.Clone()` is a shallow copy — for array of objects, objects are not deep-copied

### 🔴 Practice Problem: Two Sum (LeetCode #1 — Easy)

**Problem:** Given an array of integers `nums` and an integer `target`, return indices of the two numbers that add up to target. Each input has exactly one solution, you may not use the same element twice.

**Approach:** HashMap for O(n) — for each number, check if its complement (target - num) is already seen.

```csharp
public int[] TwoSum(int[] nums, int target) {
    // Store: number → index, for O(1) complement lookup
    var seen = new Dictionary<int, int>();

    for (int i = 0; i < nums.Length; i++) {
        int complement = target - nums[i];

        // If complement already seen, we found our pair
        if (seen.TryGetValue(complement, out int j))
            return new[] { j, i };

        // Otherwise record this number and its index
        seen[nums[i]] = i;
    }

    return Array.Empty<int>(); // problem guarantees a solution exists
}
// Time: O(n) — single pass | Space: O(n) — dictionary stores up to n entries
```

> **🎯 Key Insight:** The brute-force O(n²) nested loop is the natural first thought. Recognizing "I need fast lookup of a VALUE" → HashMap is the key mental leap. Almost every array problem that needs "find complement/pair" uses this HashMap trick.

---

## Section 6 — Strings

> **🧠 Mental Model: A Bead Necklace**
>
> A string is like a necklace of character beads. In C#, strings are **immutable** — once created, you cannot change a bead. Every "modification" creates a new necklace. `StringBuilder` is like a work-in-progress necklace on the table — you add/remove beads freely, then string them together at the end.

### C# String Fundamentals

```csharp
// IMMUTABILITY — every operation creates a new string
string s = "hello";
string s2 = s.ToUpper();  // new string "HELLO" — s is still "hello"
s += " world";            // creates a new string — old "hello" is garbage collected

// CHAR OPERATIONS
char c = s[0];                  // O(1) index access
int len = s.Length;             // O(1)
bool hasA = s.Contains("a");    // O(n) — linear scan
int idx = s.IndexOf('l');       // O(n)

// CHARACTER CHECKS (important for interview problems)
char.IsDigit('5');              // true
char.IsLetter('a');             // true
char.IsWhiteSpace(' ');         // true
char.ToLower('A');              // 'a'
(int)('a' - 'a') == 0           // convert char to 0-25 index — key for frequency arrays!
(int)('z' - 'a') == 25

// FREQUENCY ARRAY (faster than Dictionary for lowercase letters)
int[] freq = new int[26];
foreach (char ch in s)
    freq[ch - 'a']++;           // map 'a'→0, 'b'→1, ..., 'z'→25

// STRINGBUILDER — O(1) amortized append vs O(n) for string concatenation
var sb = new StringBuilder();
sb.Append("hello");
sb.Append(' ');
sb.Append("world");
string result = sb.ToString();  // build once at end

// SPLITTING AND JOINING
string[] words = "hello world".Split(' ');
string joined = string.Join(", ", words);  // "hello, world"

// SPAN<CHAR> — zero-allocation slicing (performance-critical code)
ReadOnlySpan<char> span = s.AsSpan(1, 3);  // slice without allocation
```

### Complexity Table

| Operation | String | StringBuilder |
|-----------|--------|---------------|
| Length | O(1) | O(1) |
| Index access | O(1) | O(1) |
| Concatenation | O(n) new string | O(1) amortized |
| Substring | O(n) copy | O(1) with Span |
| Contains/IndexOf | O(n) | O(n) |
| Compare | O(n) | O(n) |

### Common Pitfalls
- ⚠️ String concatenation in a loop: `s += char` is O(n²) total — always use `StringBuilder`
- ⚠️ `string.Compare` vs `==`: use `==` for value equality (C# overloads it correctly for strings)
- ⚠️ `null` vs `""` vs `" "` — check with `string.IsNullOrWhiteSpace(s)`
- ⚠️ Unicode: `s.Length` is UTF-16 code units, not characters — emoji can be length 2

### 🔴 Practice Problem: Longest Palindromic Substring (LeetCode #5 — Medium)

**Problem:** Given string `s`, return the longest palindromic substring.

**Approach:** Expand Around Center — for each character, try expanding outward while characters match.

```csharp
public string LongestPalindrome(string s) {
    if (s.Length == 0) return "";

    int start = 0, maxLen = 1;

    // Try each character as center (odd length) and between chars (even length)
    for (int i = 0; i < s.Length; i++) {
        // Odd length palindromes (center at i)
        int len1 = ExpandFromCenter(s, i, i);
        // Even length palindromes (center between i and i+1)
        int len2 = ExpandFromCenter(s, i, i + 1);

        int len = Math.Max(len1, len2);
        if (len > maxLen) {
            maxLen = len;
            // Calculate start: center - half the length
            start = i - (len - 1) / 2;
        }
    }

    return s.Substring(start, maxLen);
}

private int ExpandFromCenter(string s, int left, int right) {
    // Expand while within bounds AND characters match
    while (left >= 0 && right < s.Length && s[left] == s[right]) {
        left--;
        right++;
    }
    // When loop ends, left and right are OUTSIDE the palindrome
    return right - left - 1;  // length of palindrome
}
// Time: O(n²) — n centers, each expansion up to O(n)
// Space: O(1) — only store start index and length
```

> **🎯 Key Insight:** There are two types of palindrome centers: single character (odd length like "aba") and between characters (even length like "abba"). Always check both. The DP solution is O(n²) time AND space — expand-around-center achieves same time with O(1) space.

---

## Section 7 — Linked Lists

> **🧠 Mental Model: A Scavenger Hunt**
>
> A linked list is like a scavenger hunt where each clue (node) contains: (1) a message (data) and (2) the location of the NEXT clue (pointer). You MUST start from clue #1 and follow the chain — you cannot jump to clue #7 directly. To add a new clue between clues 3 and 4: just change clue 3 to point to the new clue, and new clue points to old clue 4. No "moving" required — O(1) insert once you're at position.

### Linked List Structure

```
Singly Linked List:
┌──────┬──┐   ┌──────┬──┐   ┌──────┬──┐   ┌──────┬────┐
│  10  │ ─┼──►│  20  │ ─┼──►│  30  │ ─┼──►│  40  │null│
└──────┴──┘   └──────┴──┘   └──────┴──┘   └──────┴────┘
  head                                         tail

Doubly Linked List:
     ┌──────────────────────────────────────────┐
     │  ┌──┬──────┬──┐   ┌──┬──────┬──┐        │
null◄┼──┤  │  10  │ ─┼──►│  │  20  │ ─┼──► ... │
     │  └──┴──────┴──┘ ◄─┼──┴──────┴──┘        │
     └──────────────────────────────────────────┘
```

### C# Linked List — From Scratch + Built-in

```csharp
// NODE DEFINITION (for interview problems — write this yourself)
public class ListNode {
    public int Val;
    public ListNode Next;
    public ListNode(int val = 0, ListNode next = null) {
        Val = val; Next = next;
    }
}

// COMMON LINKED LIST OPERATIONS
// 1. Traverse
void Traverse(ListNode head) {
    ListNode curr = head;
    while (curr != null) {
        Console.Write(curr.Val + " → ");
        curr = curr.Next;
    }
}

// 2. Insert at front — O(1)
ListNode InsertFront(ListNode head, int val) {
    var newNode = new ListNode(val);
    newNode.Next = head;   // new node points to old head
    return newNode;        // new node is new head
}

// 3. Delete a node by value — O(n)
ListNode DeleteVal(ListNode head, int val) {
    var dummy = new ListNode(0, head);  // dummy prevents null head special case
    ListNode prev = dummy;
    while (prev.Next != null) {
        if (prev.Next.Val == val) {
            prev.Next = prev.Next.Next;  // skip the target node
            break;
        }
        prev = prev.Next;
    }
    return dummy.Next;  // real head (may have changed if we deleted original head)
}

// .NET BUILT-IN: LinkedList<T>
var ll = new LinkedList<int>();
ll.AddFirst(10);              // O(1)
ll.AddLast(20);               // O(1)
ll.AddAfter(ll.First, 15);    // O(1) given node reference
ll.Remove(ll.First);          // O(1) given node reference
ll.Find(20);                  // O(n) — returns LinkedListNode<T>
```

### Complexity Table

| Operation | Array/List\<T\> | Linked List |
|-----------|----------------|-------------|
| Access by index | O(1) | O(n) |
| Search | O(n) | O(n) |
| Insert at front | O(n) shift | O(1) |
| Insert at back | O(1) amortized | O(1) with tail ptr |
| Insert at middle | O(n) shift | O(1) if at position |
| Delete at front | O(n) shift | O(1) |
| Delete at middle | O(n) shift | O(1) if at position |
| Space | O(n) | O(n) + pointer overhead |

### Common Pitfalls
- ⚠️ Always use a **dummy node** when the head might change — avoids null-head special cases
- ⚠️ Save `curr.Next` BEFORE modifying `curr.Next` in reversal problems
- ⚠️ Null check before accessing `.Next` or `.Val`
- ⚠️ Off-by-one in "find kth from end" — use two-pointer approach with k gap

### 🔴 Practice Problem: Reverse Linked List (LeetCode #206 — Easy)

**Problem:** Reverse a singly linked list. Return the new head.

```csharp
// ITERATIVE — O(n) time, O(1) space
public ListNode ReverseList(ListNode head) {
    ListNode prev = null;
    ListNode curr = head;

    while (curr != null) {
        ListNode nextTemp = curr.Next;  // save next BEFORE we overwrite it
        curr.Next = prev;              // reverse the pointer
        prev = curr;                   // advance prev to current
        curr = nextTemp;               // advance curr to saved next
    }

    return prev;  // prev is now the new head (last node of original list)
}

// RECURSIVE — O(n) time, O(n) space (call stack)
public ListNode ReverseListRecursive(ListNode head) {
    if (head == null || head.Next == null) return head;  // base case

    ListNode newHead = ReverseListRecursive(head.Next);  // reverse rest
    head.Next.Next = head;  // make next node point back to current
    head.Next = null;       // disconnect current from old direction
    return newHead;
}
// Mental trace: 1→2→3→null
// After reverse: null←1←2←3 → return 3 as new head
```

> **🎯 Key Insight:** The 3-variable iterative pattern (`prev`, `curr`, `nextTemp`) is the foundation for ALL linked list reversal problems. Memorize it cold. The recursive version is elegant but uses O(n) stack space — interviewers may ask for both.

---

## Section 8 — Stacks

> **🧠 Mental Model: A Plate Dispenser in a Cafeteria**
>
> A stack is like a spring-loaded plate dispenser. You can only add (push) to the top or remove (pop) from the top. The plate at the bottom was put there first (LIFO — Last In, First Out). The key insight: "the most recently added item is always processed FIRST." This property makes stacks perfect for: undo operations, matching parentheses, function call tracking, and "next greater element" problems.

### Stack Operations

```
PUSH 10 → PUSH 20 → PUSH 30 → POP → POP

  ┌────┐
  │ 30 │  ← top     POP → 30
  ├────┤
  │ 20 │            POP → 20
  ├────┤
  │ 10 │  ← bottom
  └────┘
```

### C# Stack Implementation

```csharp
// .NET BUILT-IN Stack<T>
var stack = new Stack<int>();
stack.Push(10);            // O(1)
stack.Push(20);
stack.Push(30);
int top = stack.Peek();    // O(1) — look without removing: 30
int val = stack.Pop();     // O(1) — remove and return: 30
int count = stack.Count;   // O(1)
bool empty = stack.Count == 0;

// FROM SCRATCH (using List<T> as backing store)
public class MyStack<T> {
    private List<T> _data = new();

    public void Push(T item) => _data.Add(item);      // add to end = top

    public T Pop() {
        if (_data.Count == 0) throw new InvalidOperationException();
        T item = _data[^1];     // [^1] = last element (C# 8+ index from end)
        _data.RemoveAt(_data.Count - 1);
        return item;
    }

    public T Peek() => _data.Count == 0
        ? throw new InvalidOperationException()
        : _data[^1];

    public int Count => _data.Count;
}

// MONOTONIC STACK PATTERN — next greater element
int[] NextGreaterElement(int[] arr) {
    int n = arr.Length;
    int[] result = new int[n];
    Array.Fill(result, -1);       // default: no greater element
    var stack = new Stack<int>(); // stores INDICES (not values)

    for (int i = 0; i < n; i++) {
        // Pop all indices whose element is smaller than current
        while (stack.Count > 0 && arr[stack.Peek()] < arr[i]) {
            int idx = stack.Pop();
            result[idx] = arr[i]; // arr[i] is the next greater for arr[idx]
        }
        stack.Push(i);            // push current index
    }
    return result;
}
// Input:  [2, 1, 2, 4, 3]
// Output: [4, 2, 4,-1,-1]
```

### Complexity Table

| Operation | Time | Space |
|-----------|------|-------|
| Push | O(1) | O(1) |
| Pop | O(1) | O(1) |
| Peek | O(1) | O(1) |
| Search | O(n) | O(1) |
| Overall space | — | O(n) |

### Common Pitfalls
- ⚠️ Always check `Count > 0` before `Pop()` or `Peek()` — both throw on empty stack
- ⚠️ In monotonic stack problems, decide upfront: increasing or decreasing monotonic? (next greater = decreasing, next smaller = increasing)
- ⚠️ Store INDICES in stack, not values — you often need the index to compute distances/results

### 🔴 Practice Problem: Valid Parentheses (LeetCode #20 — Easy)

**Problem:** Given string with `()[]{}`, determine if the brackets are valid (properly opened and closed in order).

```csharp
public bool IsValid(string s) {
    var stack = new Stack<char>();

    // Map each closing bracket to its expected opening bracket
    var map = new Dictionary<char, char> {
        { ')', '(' },
        { ']', '[' },
        { '}', '{' }
    };

    foreach (char c in s) {
        if (!map.ContainsKey(c)) {
            // It's an opening bracket — push it
            stack.Push(c);
        } else {
            // It's a closing bracket — must match the top of stack
            if (stack.Count == 0 || stack.Pop() != map[c])
                return false;
        }
    }

    return stack.Count == 0; // valid only if all opening brackets were matched
}
// Time: O(n) | Space: O(n) for the stack
// Edge cases: ")(" → false (close before open), "" → true (empty is valid)
```

> **🎯 Key Insight:** Any "matching pairs" problem (HTML tags, brackets, quotes) uses a stack. Push opens, when you see a close — pop and verify it matches. Final stack must be empty for full validity.

---

## Section 9 — Queues & Deques

> **🧠 Mental Model: Airport Security Line**
>
> A queue is an airport security line: first person to join (enqueue) is the first to pass through security (dequeue). FIFO — First In, First Out. A deque (double-ended queue) is like a line where VIPs can jump to the front OR join at the back, and anyone can leave from either end. Critical insight: **BFS always uses a Queue** (process nodes level by level — the first node added at a level must be processed before the next level).

### Queue & Deque Operations

```
ENQUEUE:  front ← [10][20][30] ← rear    (enqueue adds to rear)
DEQUEUE:  front → 10  [20][30] ← rear    (dequeue removes from front)

DEQUE:
AddFront/RemoveFront ↔ [10][20][30] ↔ AddBack/RemoveBack
```

### C# Queue & Deque Implementation

```csharp
// .NET BUILT-IN Queue<T>
var queue = new Queue<int>();
queue.Enqueue(10);          // O(1) — add to back
queue.Enqueue(20);
queue.Enqueue(30);
int front = queue.Peek();   // O(1) — view front: 10
int val = queue.Dequeue();  // O(1) — remove front: 10
int count = queue.Count;    // O(1)

// DEQUE (Double-Ended Queue) — use LinkedList<T> in C#
var deque = new LinkedList<int>();
deque.AddFirst(10);          // add to front — O(1)
deque.AddLast(20);           // add to back  — O(1)
int firstVal = deque.First.Value;  // peek front
int lastVal = deque.Last.Value;    // peek back
deque.RemoveFirst();         // O(1)
deque.RemoveLast();          // O(1)

// PRIORITY QUEUE (min-heap by default in .NET 6+)
var pq = new PriorityQueue<string, int>();
pq.Enqueue("task1", 3);     // element, priority (lower = higher priority)
pq.Enqueue("task2", 1);
pq.Enqueue("task3", 2);
string next = pq.Dequeue(); // "task2" — lowest priority number first

// For MAX-HEAP, negate the priority:
pq.Enqueue("task1", -3);    // will be dequeued first (largest original priority)

// CIRCULAR QUEUE (fixed size) — interview question
public class MyCircularQueue {
    private int[] _buf;
    private int _head, _tail, _size, _capacity;

    public MyCircularQueue(int k) {
        _buf = new int[k];
        _capacity = k;
    }

    public bool EnQueue(int val) {
        if (_size == _capacity) return false;
        _buf[_tail] = val;
        _tail = (_tail + 1) % _capacity;  // wrap around
        _size++;
        return true;
    }

    public bool DeQueue() {
        if (_size == 0) return false;
        _head = (_head + 1) % _capacity;  // wrap around
        _size--;
        return true;
    }

    public int Front() => _size == 0 ? -1 : _buf[_head];
    public int Rear()  => _size == 0 ? -1 : _buf[(_tail - 1 + _capacity) % _capacity];
    public bool IsEmpty() => _size == 0;
    public bool IsFull()  => _size == _capacity;
}
```

### Complexity Table

| Operation | Queue | Deque (LinkedList) | PriorityQueue |
|-----------|-------|--------------------|---------------|
| Enqueue/Add | O(1) | O(1) | O(log n) |
| Dequeue/Remove | O(1) | O(1) | O(log n) |
| Peek | O(1) | O(1) | O(1) |
| Space | O(n) | O(n) | O(n) |

### 🔴 Practice Problem: Sliding Window Maximum (LeetCode #239 — Hard)

**Problem:** Given array `nums` and window size `k`, return array of maximums for each window of size k.

**Approach:** Monotonic Deque — maintain indices of useful elements (decreasing order of values).

```csharp
public int[] MaxSlidingWindow(int[] nums, int k) {
    int n = nums.Length;
    int[] result = new int[n - k + 1];
    // Deque stores INDICES — front = index of current window maximum
    var deque = new LinkedList<int>();

    for (int i = 0; i < n; i++) {
        // Remove indices outside current window from front
        while (deque.Count > 0 && deque.First.Value < i - k + 1)
            deque.RemoveFirst();

        // Remove indices whose VALUES are smaller than nums[i] from back
        // They can never be the max while nums[i] is in the window
        while (deque.Count > 0 && nums[deque.Last.Value] < nums[i])
            deque.RemoveLast();

        deque.AddLast(i);  // add current index

        // Window is full — record the max (front of deque)
        if (i >= k - 1)
            result[i - k + 1] = nums[deque.First.Value];
    }

    return result;
}
// Time: O(n) — each element added and removed at most once
// Space: O(k) — deque holds at most k elements
```

> **🎯 Key Insight:** PriorityQueue\<TElement, TPriority\> was added in .NET 6. For older .NET, you need to implement a heap or use `SortedSet<(int val, int idx)>`. Always clarify .NET version in interviews. The monotonic deque pattern achieves O(n) vs O(n log n) for a heap-based approach.

---

# PART 3 — HASH-BASED STRUCTURES

---

## Section 10 — Hash Maps (Dictionary)

> **🧠 Mental Model: The Library Card Catalog**
>
> A hash map is like a library's card catalog. When you receive a book, you apply a "catalog rule" (hash function) to its title to decide which drawer (bucket) it goes in. To find a book later, apply the same rule to jump directly to the right drawer — O(1). If two books hash to the same drawer (collision), you flip through a short sub-list within that drawer. With a good hash function, drawers stay short → still near O(1).

### Hash Map Internals

```
key → hash(key) → bucket index → linked list (for collision handling)

hash("apple") → 3  → bucket[3] → ["apple": 5]
hash("grape") → 7  → bucket[7] → ["grape": 12]
hash("mango") → 3  → bucket[3] → ["apple": 5] → ["mango": 8]  ← collision!
                                   └── linear probe or chaining ──┘
```

### C# Dictionary Operations

```csharp
// CREATION
var dict = new Dictionary<string, int>();
var dict2 = new Dictionary<int, List<int>>();  // value can be complex type

// ADD / UPDATE
dict["apple"] = 5;               // add or update (no exception on duplicate key)
dict.Add("grape", 12);           // throws if key exists
dict.TryAdd("apple", 99);        // safe — returns false if key exists, doesn't throw

// ACCESS
int val = dict["apple"];                  // throws KeyNotFoundException if missing
dict.TryGetValue("mango", out int v);    // safe — returns false if missing
int count = dict.GetValueOrDefault("banana", 0);  // returns 0 if missing

// CHECK EXISTENCE
bool hasKey = dict.ContainsKey("apple"); // O(1)
bool hasVal = dict.ContainsValue(5);     // O(n) — avoid in hot paths

// REMOVE
dict.Remove("apple");            // O(1) average

// ITERATION
foreach (var (key, value) in dict)    // deconstruct KeyValuePair
    Console.WriteLine($"{key}: {value}");

foreach (string key in dict.Keys) { }
foreach (int value in dict.Values) { }

// FREQUENCY COUNT PATTERN (most common use in interviews)
int[] nums = { 1, 2, 2, 3, 3, 3 };
var freq = new Dictionary<int, int>();
foreach (int n in nums)
    freq[n] = freq.GetValueOrDefault(n, 0) + 1;
// freq = {1:1, 2:2, 3:3}

// GROUPING PATTERN
string[] words = { "eat", "tea", "tan", "ate", "nat", "bat" };
var groups = new Dictionary<string, List<string>>();
foreach (string word in words) {
    char[] chars = word.ToCharArray();
    Array.Sort(chars);
    string key = new string(chars);  // sorted version as key
    if (!groups.TryGetValue(key, out var list))
        groups[key] = list = new List<string>();
    list.Add(word);
}
// groups: {"aet": ["eat","tea","ate"], "ant": ["tan","nat"], "abt": ["bat"]}
```

### Complexity Table

| Operation | Average | Worst (many collisions) |
|-----------|---------|------------------------|
| Insert | O(1) | O(n) |
| Lookup | O(1) | O(n) |
| Delete | O(1) | O(n) |
| Space | O(n) | O(n) |

### Common Pitfalls
- ⚠️ `dict[key]` throws `KeyNotFoundException` — always use `TryGetValue` for safe access
- ⚠️ Mutable objects as keys: if you modify the key object after insertion, lookup breaks (hash changes)
- ⚠️ Iterating and modifying dictionary simultaneously throws `InvalidOperationException`
- ⚠️ `Dictionary` is NOT ordered — use `SortedDictionary<K,V>` for sorted iteration (O(log n) ops)

### 🔴 Practice Problem: Group Anagrams (LeetCode #49 — Medium)

**Problem:** Given array of strings, group anagrams together.

```csharp
public IList<IList<string>> GroupAnagrams(string[] strs) {
    // Key insight: all anagrams have the same SORTED characters
    var groups = new Dictionary<string, List<string>>();

    foreach (string s in strs) {
        // Sort the characters to create a canonical key
        char[] chars = s.ToCharArray();
        Array.Sort(chars);
        string key = new string(chars);  // "eat" → "aet", "tea" → "aet"

        if (!groups.ContainsKey(key))
            groups[key] = new List<string>();
        groups[key].Add(s);
    }

    return new List<IList<string>>(groups.Values);
}
// Time: O(n * k log k) where n = num strings, k = max string length
// Space: O(n * k) for the dictionary

// OPTIMIZATION: Use frequency array as key instead of sorting
public IList<IList<string>> GroupAnagramsOptimal(string[] strs) {
    var groups = new Dictionary<string, List<string>>();

    foreach (string s in strs) {
        int[] freq = new int[26];
        foreach (char c in s) freq[c - 'a']++;
        // Convert freq array to string key: "1#0#0#...#1#..."
        string key = string.Join("#", freq);  // O(26) = O(1)

        if (!groups.ContainsKey(key))
            groups[key] = new List<string>();
        groups[key].Add(s);
    }

    return new List<IList<string>>(groups.Values);
}
// Time: O(n * k) — no sorting! k is max string length
```

---

## Section 11 — Hash Sets

> **🧠 Mental Model: The Guestlist Clipboard**
>
> A HashSet is like a bouncer's clipboard at a club. The bouncer can instantly check "is this person on the list?" (O(1) lookup), add someone to the list (O(1) insert), or cross off a name (O(1) delete). There's no concept of "what's at position 5?" — it's purely membership: in or out. Unlike Dictionary which maps key→value, HashSet only stores keys.

### C# HashSet Operations

```csharp
// CREATION
var set = new HashSet<int>();
var set2 = new HashSet<int> { 1, 2, 3 };  // initialize with values
var set3 = new HashSet<int>(arr);          // from array (deduplicates automatically)

// CORE OPERATIONS
set.Add(5);           // O(1) — returns true if added, false if already exists
set.Remove(5);        // O(1) — returns true if removed, false if not found
bool has = set.Contains(5);    // O(1) — the key operation!

// SET OPERATIONS
var a = new HashSet<int> { 1, 2, 3, 4 };
var b = new HashSet<int> { 3, 4, 5, 6 };

a.IntersectWith(b);   // a = {3, 4}       — modifies a in-place
a.UnionWith(b);       // a = {1,2,3,4,5,6}
a.ExceptWith(b);      // a = {1, 2}       — elements in a but not b
a.SymmetricExceptWith(b); // a = {1,2,5,6} — elements in one but not both

// NON-MODIFYING (create new set)
bool isSubset = a.IsSubsetOf(b);
bool isSuperset = a.IsSupersetOf(b);
bool overlaps = a.Overlaps(b);
bool equal = a.SetEquals(b);

// SORTED SET — maintains sorted order, O(log n) operations
var sortedSet = new SortedSet<int> { 5, 1, 3, 2, 4 };
// Iterates as: 1, 2, 3, 4, 5
int min = sortedSet.Min;      // O(log n)
int max = sortedSet.Max;      // O(log n)
var range = sortedSet.GetViewBetween(2, 4);  // {2, 3, 4} — O(log n)
```

### Complexity Table

| Operation | HashSet | SortedSet |
|-----------|---------|-----------|
| Add | O(1) avg | O(log n) |
| Remove | O(1) avg | O(log n) |
| Contains | O(1) avg | O(log n) |
| Min/Max | O(n) | O(log n) |
| Range query | O(n) | O(log n) |
| Space | O(n) | O(n) |

### 🔴 Practice Problem: Longest Consecutive Sequence (LeetCode #128 — Medium)

**Problem:** Given unsorted array of integers, find length of longest consecutive elements sequence. Must be O(n).

```csharp
public int LongestConsecutive(int[] nums) {
    // O(n) build — HashSet for O(1) lookup
    var numSet = new HashSet<int>(nums);
    int longest = 0;

    foreach (int num in numSet) {
        // Only start counting from the BEGINNING of a sequence
        // A number is a sequence start if (num - 1) is NOT in the set
        if (!numSet.Contains(num - 1)) {
            int currentNum = num;
            int streak = 1;

            // Extend the sequence as far as possible
            while (numSet.Contains(currentNum + 1)) {
                currentNum++;
                streak++;
            }

            longest = Math.Max(longest, streak);
        }
    }

    return longest;
}
// Time: O(n) — each number is visited at most twice (once in outer loop, once in inner)
// Space: O(n) for the HashSet

// WHY NOT SORT? Sorting = O(n log n). The HashSet trick avoids that.
// Key insight: skip non-starts to avoid redundant work — that's why it's O(n) not O(n²)
```

> **🎯 Key Insight:** The trick that makes this O(n) instead of O(n²) is starting sequences ONLY from their beginning (when `num - 1` is absent). Without this, every number starts a count-up, causing O(n²). Always ask: "Can I avoid redundant starting points?"

---

# PART 4 — TREE DATA STRUCTURES

---

## Section 12 — Binary Trees

> **🧠 Mental Model: The Company Org Chart**
>
> A binary tree is like a company org chart. The CEO (root) manages at most 2 direct reports (left child, right child). Each manager also manages at most 2 people. To find someone's salary, you might need to search the whole chart (O(n)). The SHAPE of the tree determines efficiency — a balanced tree (same depth on both sides) is O(log n) deep; a skewed tree (everyone has only one report) degenerates to a linked list at O(n) deep.

### Binary Tree Structure

```
         ┌───┐
         │ 1 │           Level 0 (root)
         └─┬─┘
      ┌────┴────┐
    ┌─┴─┐     ┌─┴─┐
    │ 2 │     │ 3 │      Level 1
    └─┬─┘     └─┬─┘
  ┌──┴──┐   ┌──┴──┐
┌─┴─┐ ┌─┴─┐ │ 6 │ │ 7 │  Level 2 (leaves)
│ 4 │ │ 5 │ └───┘ └───┘
└───┘ └───┘

Height = 2 (longest root-to-leaf path)
Perfect binary tree of height h has 2^(h+1) - 1 total nodes
```

### Tree Traversals

```
     1
    / \
   2   3
  / \
 4   5

Inorder   (Left→Root→Right): 4, 2, 5, 1, 3  ← BST gives SORTED order
Preorder  (Root→Left→Right): 1, 2, 4, 5, 3  ← good for serializing tree
Postorder (Left→Right→Root): 4, 5, 2, 3, 1  ← good for deletion
Level order (BFS left→right): 1, 2, 3, 4, 5  ← level-by-level processing
```

### C# Binary Tree Implementation

```csharp
// NODE — write this in every tree interview
public class TreeNode {
    public int Val;
    public TreeNode Left, Right;
    public TreeNode(int val = 0, TreeNode left = null, TreeNode right = null) {
        Val = val; Left = left; Right = right;
    }
}

// INORDER — Recursive
void Inorder(TreeNode root, List<int> res) {
    if (root == null) return;
    Inorder(root.Left, res);
    res.Add(root.Val);
    Inorder(root.Right, res);
}

// INORDER — Iterative (avoids stack overflow on huge trees)
List<int> InorderIterative(TreeNode root) {
    var res = new List<int>();
    var stack = new Stack<TreeNode>();
    TreeNode curr = root;
    while (curr != null || stack.Count > 0) {
        while (curr != null) { stack.Push(curr); curr = curr.Left; }
        curr = stack.Pop();
        res.Add(curr.Val);
        curr = curr.Right;
    }
    return res;
}

// LEVEL ORDER — BFS
IList<IList<int>> LevelOrder(TreeNode root) {
    var res = new List<IList<int>>();
    if (root == null) return res;
    var q = new Queue<TreeNode>();
    q.Enqueue(root);
    while (q.Count > 0) {
        int size = q.Count;                // snapshot of current level size!
        var level = new List<int>();
        for (int i = 0; i < size; i++) {
            var node = q.Dequeue();
            level.Add(node.Val);
            if (node.Left != null) q.Enqueue(node.Left);
            if (node.Right != null) q.Enqueue(node.Right);
        }
        res.Add(level);
    }
    return res;
}

// HEIGHT
int Height(TreeNode root) {
    if (root == null) return 0;
    return 1 + Math.Max(Height(root.Left), Height(root.Right));
}
```

### Complexity Table

| Operation | Balanced | Skewed (worst) |
|-----------|----------|----------------|
| Search | O(log n) | O(n) |
| Traversal | O(n) | O(n) |
| Height | O(log n) | O(n) |
| Space (DFS) | O(log n) stack | O(n) stack |
| Space (BFS) | O(n) queue | O(n) queue |

### 🔴 Practice Problem: Binary Tree Level Order Traversal (LeetCode #102 — Medium)

The `LevelOrder` method above IS the solution. Key insight: `int size = q.Count` snapshots the current level count — without this, you'd mix nodes from different levels.

```csharp
// Time: O(n) — each node visited once
// Space: O(n) — queue holds up to n/2 nodes at the leaf level
```

> **🎯 Key Insight:** The `int size = queue.Count` snapshot is THE key pattern for level-order problems. It separates "current level nodes" from "next level nodes being added." Memorize this pattern cold.

---

## Section 13 — Binary Search Trees (BST)

> **🧠 Mental Model: A Physical Dictionary**
>
> A BST is like a physical dictionary. Every page (node) has a word. All words to the LEFT come alphabetically before this word; RIGHT come after. To find "monkey": open to middle, if "monkey" < current word flip left; if greater flip right. Each comparison eliminates HALF the remaining search space — O(log n).

### BST Property & Operations

```
BST Invariant: left subtree values < node.Val < right subtree values

      8
     / \
    3   10
   / \    \
  1   6    14
     / \   /
    4   7 13

Inorder gives sorted: 1, 3, 4, 6, 7, 8, 10, 13, 14
```

```csharp
// SEARCH — O(log n) balanced
TreeNode Search(TreeNode root, int target) {
    if (root == null || root.Val == target) return root;
    return target < root.Val ? Search(root.Left, target) : Search(root.Right, target);
}

// INSERT — O(log n) balanced
TreeNode Insert(TreeNode root, int val) {
    if (root == null) return new TreeNode(val);
    if (val < root.Val) root.Left = Insert(root.Left, val);
    else if (val > root.Val) root.Right = Insert(root.Right, val);
    return root;
}

// DELETE — O(log n) — 3 cases
TreeNode Delete(TreeNode root, int key) {
    if (root == null) return null;
    if (key < root.Val) { root.Left = Delete(root.Left, key); }
    else if (key > root.Val) { root.Right = Delete(root.Right, key); }
    else {
        if (root.Left == null) return root.Right;   // case 1 & 2: 0 or 1 child
        if (root.Right == null) return root.Left;
        // Case 3: 2 children — replace with inorder successor (min of right subtree)
        TreeNode successor = root.Right;
        while (successor.Left != null) successor = successor.Left;
        root.Val = successor.Val;
        root.Right = Delete(root.Right, successor.Val);
    }
    return root;
}
```

### 🔴 Practice Problem: Validate Binary Search Tree (LeetCode #98 — Medium)

```csharp
public bool IsValidBST(TreeNode root) => Validate(root, long.MinValue, long.MaxValue);

bool Validate(TreeNode node, long min, long max) {
    if (node == null) return true;
    if (node.Val <= min || node.Val >= max) return false;
    // Tighten the valid range for children
    return Validate(node.Left, min, node.Val)
        && Validate(node.Right, node.Val, max);
}
// Time: O(n) | Space: O(h)
// WHY long? If node value is int.MinValue, (val <= int.MinValue) would be wrong
// Common mistake: only check local left < root < right — misses global invariant violation
```

---

## Section 14 — Heaps & Priority Queues

> **🧠 Mental Model: The Tournament Bracket**
>
> A heap is a single-elimination tournament. The winner (min-heap: smallest; max-heap: largest) is always at the top (root). Remove the winner → runner-up bubbles up. Add new participant → starts at bottom and bubbles up if they win matchups. Always a nearly-complete tree → O(log n) depth guaranteed.

### Heap Array Representation

```
MIN-HEAP:          Array: [1, 2, 3, 4, 5, 6, 7]
        1          Index:  0  1  2  3  4  5  6
       / \
      2   3         Parent of i    = (i-1)/2
     / \ / \        Left child     = 2*i+1
    4  5 6  7       Right child    = 2*i+2
```

```csharp
// .NET 6+ PriorityQueue<TElement, TPriority> — min-heap by default
var minHeap = new PriorityQueue<int, int>();
minHeap.Enqueue(5, 5);   // (element, priority) — lower priority = dequeued first
minHeap.Enqueue(1, 1);
minHeap.Enqueue(3, 3);
int min = minHeap.Peek();     // 1  — O(1)
int val = minHeap.Dequeue();  // 1  — O(log n)

// MAX-HEAP: negate the priority
var maxHeap = new PriorityQueue<int, int>();
maxHeap.Enqueue(5, -5);  // priority -5 → comes out first (smallest priority number)
int max = maxHeap.Dequeue();  // element=5

// FROM SCRATCH — MinHeap internals
public class MinHeap {
    private List<int> _data = new();
    public int Count => _data.Count;
    public int Peek() => _data[0];

    public void Push(int val) {
        _data.Add(val);
        BubbleUp(_data.Count - 1);
    }

    public int Pop() {
        int min = _data[0];
        _data[0] = _data[^1];
        _data.RemoveAt(_data.Count - 1);
        if (_data.Count > 0) BubbleDown(0);
        return min;
    }

    void BubbleUp(int i) {
        while (i > 0) {
            int p = (i - 1) / 2;
            if (_data[p] <= _data[i]) break;
            (_data[p], _data[i]) = (_data[i], _data[p]);
            i = p;
        }
    }

    void BubbleDown(int i) {
        int n = _data.Count;
        while (true) {
            int s = i, l = 2*i+1, r = 2*i+2;
            if (l < n && _data[l] < _data[s]) s = l;
            if (r < n && _data[r] < _data[s]) s = r;
            if (s == i) break;
            (_data[s], _data[i]) = (_data[i], _data[s]);
            i = s;
        }
    }
}
```

### Complexity Table

| Operation | Time |
|-----------|------|
| Push (Enqueue) | O(log n) |
| Pop (Dequeue) | O(log n) |
| Peek | O(1) |
| Build from array | O(n) |
| Space | O(n) |

### 🔴 Practice Problem: Kth Largest Element (LeetCode #215 — Medium)

```csharp
public int FindKthLargest(int[] nums, int k) {
    // Min-heap of size k: top = kth largest
    var minHeap = new PriorityQueue<int, int>();
    foreach (int num in nums) {
        minHeap.Enqueue(num, num);
        if (minHeap.Count > k) minHeap.Dequeue();  // evict smallest
    }
    return minHeap.Peek();  // top = kth largest
}
// Time: O(n log k) | Space: O(k)
// Better than sorting O(n log n) when k << n
```

---

## Section 15 — Tries (Prefix Trees)

> **🧠 Mental Model: Phone Autocomplete**
>
> A Trie powers your phone's autocomplete. Each character you type navigates DOWN one level. All words sharing the prefix "ap" (apple, application, apt) share the "ap" path. Lookup is O(L) — word length — regardless of how many words are stored. Perfect for: autocomplete, spell check, prefix matching, word dictionaries.

### Trie Structure

```
Words: ["app", "apple", "bat", "ball"]

         root
        /    \
       a      b
       |      |
       p      a
       |     / \
       p    t   l
      / \   |   |
    [✓] l  [✓] l
        |       |
        e      [✓]
        |
       [✓]  ← "apple"
[✓] = IsEnd (complete word)
```

```csharp
public class TrieNode {
    public TrieNode[] Children = new TrieNode[26];
    public bool IsEnd;
}

public class Trie {
    private readonly TrieNode _root = new();

    public void Insert(string word) {
        TrieNode node = _root;
        foreach (char c in word) {
            int i = c - 'a';
            node.Children[i] ??= new TrieNode();
            node = node.Children[i];
        }
        node.IsEnd = true;
    }

    public bool Search(string word) {
        var node = GetNode(word);
        return node != null && node.IsEnd;  // must exist AND be end of word
    }

    public bool StartsWith(string prefix) => GetNode(prefix) != null;

    private TrieNode GetNode(string s) {
        TrieNode node = _root;
        foreach (char c in s) {
            int i = c - 'a';
            if (node.Children[i] == null) return null;
            node = node.Children[i];
        }
        return node;
    }
}
// All operations: O(L) time, O(L) space per insert
```

### 🔴 Practice Problem: Implement Trie (LeetCode #208 — Medium)

The Trie class above is the complete solution. Key test:
```csharp
var t = new Trie();
t.Insert("apple");
t.Search("apple");    // true
t.Search("app");      // false — not inserted
t.StartsWith("app");  // true — prefix exists
t.Insert("app");
t.Search("app");      // true — now explicitly inserted
```

> **🎯 Key Insight:** `IsEnd` distinguishes a PREFIX ("app") from a WORD ("app" inserted). Always use `Children[26]` array (not Dictionary) for lowercase-only problems — simpler and faster. Use Dictionary only when character set is unknown/large.

---

## Section 16 — Advanced Trees

> **🧠 Mental Model: The Self-Balancing Scale**
>
> AVL trees self-balance like a scale that auto-adjusts after every weight change. Segment trees are like pre-computed tournament brackets for range queries — answer "sum of positions 3–7" in O(log n) instead of O(n) linear scan.

### Segment Tree — Range Sum with Point Update

```csharp
public class SegmentTree {
    private int[] _tree;
    private int _n;

    public SegmentTree(int[] nums) {
        _n = nums.Length;
        _tree = new int[4 * _n];
        Build(nums, 0, 0, _n - 1);
    }

    void Build(int[] nums, int node, int start, int end) {
        if (start == end) { _tree[node] = nums[start]; return; }
        int mid = (start + end) / 2;
        Build(nums, 2*node+1, start, mid);
        Build(nums, 2*node+2, mid+1, end);
        _tree[node] = _tree[2*node+1] + _tree[2*node+2];
    }

    public void Update(int idx, int val) => Update(0, 0, _n-1, idx, val);
    void Update(int node, int start, int end, int idx, int val) {
        if (start == end) { _tree[node] = val; return; }
        int mid = (start + end) / 2;
        if (idx <= mid) Update(2*node+1, start, mid, idx, val);
        else Update(2*node+2, mid+1, end, idx, val);
        _tree[node] = _tree[2*node+1] + _tree[2*node+2];
    }

    public int Query(int l, int r) => Query(0, 0, _n-1, l, r);
    int Query(int node, int start, int end, int l, int r) {
        if (r < start || end < l) return 0;             // out of range
        if (l <= start && end <= r) return _tree[node]; // fully in range
        int mid = (start + end) / 2;
        return Query(2*node+1, start, mid, l, r)
             + Query(2*node+2, mid+1, end, l, r);
    }
}
// Build: O(n) | Update: O(log n) | Query: O(log n) | Space: O(n)
```

### 🔴 Practice Problem: Range Sum Query - Mutable (LeetCode #307 — Medium)

```csharp
public class NumArray {
    private SegmentTree _tree;
    public NumArray(int[] nums) { _tree = new SegmentTree(nums); }
    public void Update(int index, int val) { _tree.Update(index, val); }
    public int SumRange(int left, int right) { return _tree.Query(left, right); }
}
```

> **🎯 Key Insight:** Segment Tree supports ANY associative operation (sum, min, max, GCD). Fenwick Tree (BIT) is simpler code but only works for invertible operations like sum/XOR. In interviews, knowing Segment Tree is impressive; Fenwick Tree is a bonus.

---

# PART 5 — GRAPH DATA STRUCTURES

---

## Section 17 — Graph Fundamentals

> **🧠 Mental Model: The Road Network**
>
> A graph is a road network. Cities = NODES (vertices). Roads = EDGES. One-way roads = DIRECTED edges. Roads with distance = WEIGHTED edges. "Can you reach city B from A?" = CONNECTIVITY. "Shortest route?" = SHORTEST PATH. Grids (2D matrices) are the most common graph in interviews — cells are nodes, adjacent cells are edges.

### Graph Representations

```
Graph:  1 — 2 — 3
        |   |
        4 — 5

Adjacency List (sparse graphs — O(V+E) space):
{ 1:[2,4], 2:[1,3,5], 3:[2], 4:[1,5], 5:[2,4] }

Adjacency Matrix (dense or O(1) edge check — O(V²) space):
   1 2 3 4 5
1 [0,1,0,1,0]
2 [1,0,1,0,1]
3 [0,1,0,0,0]
```

```csharp
// BUILD adjacency list from edge list (standard interview setup)
int n = 5;
int[][] edges = { new[]{0,1}, new[]{1,2}, new[]{0,2} };

var adj = new List<List<int>>();
for (int i = 0; i < n; i++) adj.Add(new List<int>());
foreach (var e in edges) {
    adj[e[0]].Add(e[1]);
    adj[e[1]].Add(e[0]);  // undirected: add both directions
}

// GRID AS GRAPH — 4-directional movement
int[] dr = { -1, 1, 0, 0 };  // up, down, left, right
int[] dc = {  0, 0,-1, 1 };
// neighbors of (r,c):
for (int d = 0; d < 4; d++) {
    int nr = r + dr[d], nc = c + dc[d];
    if (nr >= 0 && nr < rows && nc >= 0 && nc < cols)
        // (nr, nc) is a valid neighbor
        ;
}
// For 8-directional (diagonals too): extend dr/dc with (-1,-1),(-1,1),(1,-1),(1,1)
```

### Graph Vocabulary

| Term | Definition |
|------|-----------|
| DAG | Directed Acyclic Graph — used for dependencies/scheduling |
| Tree | Connected undirected graph with exactly V-1 edges (no cycles) |
| Connected component | Maximal set of mutually reachable vertices |
| In-degree | Number of incoming edges (directed graph) |
| Topological order | Linear ordering of vertices in a DAG respecting edge directions |

### 🔴 Practice Problem: Number of Islands (LeetCode #200 — Medium)

```csharp
public int NumIslands(char[][] grid) {
    int rows = grid.Length, cols = grid[0].Length, count = 0;
    for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++)
            if (grid[r][c] == '1') { count++; Sink(grid, r, c); }
    return count;
}

void Sink(char[][] grid, int r, int c) {
    if (r < 0 || r >= grid.Length || c < 0 || c >= grid[0].Length || grid[r][c] != '1') return;
    grid[r][c] = '0';  // mark visited by sinking land into water
    Sink(grid, r-1, c); Sink(grid, r+1, c);
    Sink(grid, r, c-1); Sink(grid, r, c+1);
}
// Time: O(rows × cols) | Space: O(rows × cols) worst-case stack
```

---

## Section 18 — Graph Traversals: DFS & BFS

> **🧠 Mental Model: Two Styles of Maze Exploration**
>
> **DFS** = brave explorer: go as DEEP as possible, only backtrack when stuck. Uses a stack/recursion. Best for: cycle detection, connected components, topological sort, all-paths.
>
> **BFS** = methodical explorer: explore all neighbors at current distance before going farther. Uses a queue. Best for: SHORTEST PATH in unweighted graphs, level-by-level processing.

```csharp
// DFS — Recursive
void DfsRecursive(List<List<int>> graph, int node, bool[] visited) {
    visited[node] = true;
    foreach (int neighbor in graph[node])
        if (!visited[neighbor])
            DfsRecursive(graph, neighbor, visited);
}

// DFS — Iterative (avoids stack overflow)
void DfsIterative(List<List<int>> graph, int start, bool[] visited) {
    var stack = new Stack<int>();
    stack.Push(start);
    while (stack.Count > 0) {
        int node = stack.Pop();
        if (visited[node]) continue;
        visited[node] = true;
        foreach (int nb in graph[node])
            if (!visited[nb]) stack.Push(nb);
    }
}

// BFS — SHORTEST PATH (unweighted)
int BfsShortestPath(List<List<int>> graph, int start, int end) {
    bool[] visited = new bool[graph.Count];
    var queue = new Queue<(int node, int dist)>();
    visited[start] = true;
    queue.Enqueue((start, 0));
    while (queue.Count > 0) {
        var (node, dist) = queue.Dequeue();
        if (node == end) return dist;
        foreach (int nb in graph[node])
            if (!visited[nb]) { visited[nb] = true; queue.Enqueue((nb, dist+1)); }
    }
    return -1;  // unreachable
}
```

### DFS vs BFS Comparison

| Aspect | DFS | BFS |
|--------|-----|-----|
| Data structure | Stack (or recursion) | Queue |
| Space | O(h) — height of DFS tree | O(w) — width of BFS frontier |
| Shortest path? | No (for unweighted) | Yes (for unweighted) |
| Best for | Cycles, components, paths | Shortest path, levels |
| Grid problems | Connected components | Minimum steps |

### 🔴 Practice Problem: Course Schedule (LeetCode #207 — Medium)

**Can you finish all courses given prerequisites? (cycle detection in directed graph)**

```csharp
public bool CanFinish(int numCourses, int[][] prerequisites) {
    var graph = new List<List<int>>();
    for (int i = 0; i < numCourses; i++) graph.Add(new List<int>());
    foreach (var pre in prerequisites)
        graph[pre[1]].Add(pre[0]);  // b → a means b must come before a

    // 0=unvisited, 1=in-progress (current DFS path), 2=completed
    int[] state = new int[numCourses];

    bool HasCycle(int node) {
        if (state[node] == 1) return true;   // back edge → cycle!
        if (state[node] == 2) return false;  // already fully explored
        state[node] = 1;
        foreach (int nb in graph[node])
            if (HasCycle(nb)) return true;
        state[node] = 2;
        return false;
    }

    for (int i = 0; i < numCourses; i++)
        if (HasCycle(i)) return false;
    return true;
}
// Time: O(V + E) | Space: O(V + E)
```

---

## Section 19 — Shortest Path Algorithms

> **🧠 Mental Model: GPS Navigation**
>
> Dijkstra = GPS always exploring the nearest unvisited city first — guaranteed shortest for NON-NEGATIVE weights. Bellman-Ford = GPS that rechecks all roads V-1 times — handles negative weights, detects negative cycles. Floyd-Warshall = precomputes a complete distance table for ALL city pairs.

### Dijkstra's Algorithm

```csharp
int[] Dijkstra(List<List<(int nb, int w)>> graph, int src) {
    int n = graph.Count;
    int[] dist = new int[n];
    Array.Fill(dist, int.MaxValue / 2);  // /2 prevents overflow when adding weights
    dist[src] = 0;

    var pq = new PriorityQueue<int, int>();  // (node, distance)
    pq.Enqueue(src, 0);

    while (pq.Count > 0) {
        int curr = pq.Dequeue();
        foreach (var (nb, w) in graph[curr]) {
            int newDist = dist[curr] + w;
            if (newDist < dist[nb]) {
                dist[nb] = newDist;
                pq.Enqueue(nb, newDist);
            }
        }
    }
    return dist;
}
// Time: O((V + E) log V) | Space: O(V + E)
// ONLY works for non-negative weights!
```

### Bellman-Ford (Negative Weights)

```csharp
int[] BellmanFord(int n, int[][] edges, int src) {
    int[] dist = new int[n];
    Array.Fill(dist, int.MaxValue / 2);
    dist[src] = 0;
    // Relax all edges V-1 times
    for (int i = 0; i < n - 1; i++)
        foreach (var e in edges)   // e = [u, v, weight]
            if (dist[e[0]] + e[2] < dist[e[1]])
                dist[e[1]] = dist[e[0]] + e[2];
    // Vth relaxation detects negative cycle
    foreach (var e in edges)
        if (dist[e[0]] + e[2] < dist[e[1]]) return null;  // negative cycle!
    return dist;
}
// Time: O(V × E) | Space: O(V)
```

### 🔴 Practice Problem: Network Delay Time (LeetCode #743 — Medium)

```csharp
public int NetworkDelayTime(int[][] times, int n, int k) {
    var graph = new List<List<(int, int)>>();
    for (int i = 0; i <= n; i++) graph.Add(new List<(int, int)>());
    foreach (var t in times) graph[t[0]].Add((t[1], t[2]));

    int[] dist = Dijkstra(graph, k);  // shortest from source k

    int maxDist = 0;
    for (int i = 1; i <= n; i++) {
        if (dist[i] == int.MaxValue / 2) return -1;  // unreachable
        maxDist = Math.Max(maxDist, dist[i]);
    }
    return maxDist;  // max shortest path = time for signal to reach all nodes
}
```

---

## Section 20 — Minimum Spanning Trees

> **🧠 Mental Model: Building a Power Grid**
>
> Connect all n houses with power lines (weighted edges) at minimum total cost, no redundant loops. An MST uses exactly V-1 edges to connect all V vertices with minimum total weight. Kruskal's: sort edges by weight, greedily add if they don't create a cycle (use Union-Find). Prim's: grow the tree one vertex at a time via min-heap.

### Kruskal's Algorithm

```csharp
int Kruskal(int n, int[][] edges) {  // edges = [[u, v, weight], ...]
    Array.Sort(edges, (a, b) => a[2].CompareTo(b[2]));  // sort by weight
    int[] parent = Enumerable.Range(0, n).ToArray();
    int[] rank = new int[n];

    int Find(int x) {
        if (parent[x] != x) parent[x] = Find(parent[x]);  // path compression
        return parent[x];
    }
    bool Union(int x, int y) {
        int px = Find(x), py = Find(y);
        if (px == py) return false;  // same component → cycle
        if (rank[px] < rank[py]) (px, py) = (py, px);
        parent[py] = px;
        if (rank[px] == rank[py]) rank[px]++;
        return true;
    }

    int total = 0, edgesUsed = 0;
    foreach (var e in edges) {
        if (Union(e[0], e[1])) {
            total += e[2];
            if (++edgesUsed == n - 1) break;
        }
    }
    return edgesUsed == n - 1 ? total : -1;
}
// Time: O(E log E) for sort + O(E α(V)) for Union-Find
```

### 🔴 Practice Problem: Min Cost to Connect All Points (LeetCode #1584 — Medium)

```csharp
public int MinCostConnectPoints(int[][] points) {
    int n = points.Length;
    var edges = new List<int[]>();
    for (int i = 0; i < n; i++)
        for (int j = i + 1; j < n; j++) {
            int cost = Math.Abs(points[i][0]-points[j][0]) + Math.Abs(points[i][1]-points[j][1]);
            edges.Add(new[] { i, j, cost });
        }
    return Kruskal(n, edges.ToArray());
}
// Time: O(n² log n) — building O(n²) edges then sorting
```

---

## Section 21 — Advanced Graphs

> **🧠 Mental Model: Topological Sort = Project Scheduling**
>
> Topological sort gives a valid task ORDER when tasks have dependencies. Only works on DAGs (no circular deps). Kahn's algorithm: repeatedly remove tasks with no remaining prerequisites. Union-Find: "are these two people in the same social circle?" — efficiently answers dynamic connectivity.

### Topological Sort (Kahn's BFS)

```csharp
IList<int> TopoSort(int n, int[][] edges) {
    var graph = new List<List<int>>();
    int[] inDegree = new int[n];
    for (int i = 0; i < n; i++) graph.Add(new List<int>());
    foreach (var e in edges) { graph[e[0]].Add(e[1]); inDegree[e[1]]++; }

    var queue = new Queue<int>();
    for (int i = 0; i < n; i++) if (inDegree[i] == 0) queue.Enqueue(i);

    var order = new List<int>();
    while (queue.Count > 0) {
        int node = queue.Dequeue();
        order.Add(node);
        foreach (int nb in graph[node])
            if (--inDegree[nb] == 0) queue.Enqueue(nb);
    }
    return order.Count == n ? order : new List<int>();  // empty = has cycle
}
// Time: O(V + E) | Space: O(V + E)
```

### Union-Find

```csharp
public class UnionFind {
    private int[] _parent, _rank;
    public int Components { get; private set; }

    public UnionFind(int n) {
        _parent = Enumerable.Range(0, n).ToArray();
        _rank = new int[n];
        Components = n;
    }

    public int Find(int x) {
        if (_parent[x] != x) _parent[x] = Find(_parent[x]);  // path compression
        return _parent[x];
    }

    public bool Union(int x, int y) {
        int px = Find(x), py = Find(y);
        if (px == py) return false;
        if (_rank[px] < _rank[py]) (px, py) = (py, px);
        _parent[py] = px;
        if (_rank[px] == _rank[py]) _rank[px]++;
        Components--;
        return true;
    }

    public bool Connected(int x, int y) => Find(x) == Find(y);
}
```

### 🔴 Practice Problem: Redundant Connection (LeetCode #684 — Medium)

```csharp
public int[] FindRedundantConnection(int[][] edges) {
    var uf = new UnionFind(edges.Length + 1);  // nodes are 1-indexed
    foreach (var edge in edges)
        if (!uf.Union(edge[0], edge[1]))
            return edge;  // already connected → this edge is redundant
    return Array.Empty<int>();
}
// Time: O(n α(n)) ≈ O(n) | Space: O(n)
```

> **🎯 Key Insight:** Union-Find with path compression + union by rank achieves nearly O(1) per operation — one of the most elegant data structures in CS. It answers "are X and Y connected?" in nearly constant time, making it perfect for Kruskal's MST and any dynamic connectivity problem.

---
