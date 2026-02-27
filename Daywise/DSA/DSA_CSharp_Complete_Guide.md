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

# PART 6 — SORTING ALGORITHMS

---

## Section 22 — O(n²) Sorts

> **🧠 Mental Model: Different Ways to Sort Playing Cards**
>
> **Bubble Sort** = rookie mistake: scan left to right, swap adjacent cards if out of order, repeat. The largest card "bubbles" to the right each pass. **Selection Sort** = find the smallest card in the unsorted pile, place it at the end of the sorted pile. **Insertion Sort** = how you naturally sort cards in your hand — pick one card and insert it into its correct position among already-sorted cards. Insertion sort is actually OPTIMAL for nearly-sorted data.

### The Three O(n²) Sorts

```csharp
// BUBBLE SORT — O(n²) time, O(1) space
// Mental: each pass "bubbles" the max to the end
void BubbleSort(int[] arr) {
    int n = arr.Length;
    for (int i = 0; i < n - 1; i++) {
        bool swapped = false;
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                (arr[j], arr[j+1]) = (arr[j+1], arr[j]);
                swapped = true;
            }
        }
        if (!swapped) break;  // early exit — already sorted!
    }
}

// SELECTION SORT — O(n²) time, O(1) space
// Mental: find minimum, swap to front, repeat on remaining
void SelectionSort(int[] arr) {
    int n = arr.Length;
    for (int i = 0; i < n - 1; i++) {
        int minIdx = i;
        for (int j = i + 1; j < n; j++)
            if (arr[j] < arr[minIdx]) minIdx = j;
        (arr[i], arr[minIdx]) = (arr[minIdx], arr[i]);
    }
}

// INSERTION SORT — O(n²) worst, O(n) best (already sorted!)
// Mental: grow a sorted sub-array by inserting one element at a time
void InsertionSort(int[] arr) {
    for (int i = 1; i < arr.Length; i++) {
        int key = arr[i];
        int j = i - 1;
        // Shift elements greater than key one position right
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;  // insert key in its correct position
    }
}
```

### Complexity Comparison

| Algorithm | Best | Average | Worst | Space | Stable? |
|-----------|------|---------|-------|-------|---------|
| Bubble | O(n) | O(n²) | O(n²) | O(1) | Yes |
| Selection | O(n²) | O(n²) | O(n²) | O(1) | No |
| Insertion | O(n) | O(n²) | O(n²) | O(1) | Yes |

**When to use O(n²) sorts:**
- Small arrays (n < 20): insertion sort often beats O(n log n) sorts due to low overhead
- Nearly sorted data: insertion sort is O(n) in best case
- Memory constrained: all are O(1) space

### 🔴 Practice Problem: Sort Colors (LeetCode #75 — Medium)

**Problem:** Given array with only 0, 1, 2 (Dutch National Flag problem), sort in-place without using library sort.

**Approach:** Three-pointer technique — Dutch Flag partition.

```csharp
public void SortColors(int[] nums) {
    int low = 0, mid = 0, high = nums.Length - 1;

    // Invariant:
    //   [0..low-1] = all 0s
    //   [low..mid-1] = all 1s
    //   [mid..high] = unknown
    //   [high+1..n-1] = all 2s

    while (mid <= high) {
        if (nums[mid] == 0) {
            (nums[low], nums[mid]) = (nums[mid], nums[low]);
            low++; mid++;         // 0 goes to low zone, advance both
        } else if (nums[mid] == 1) {
            mid++;                // 1 already in correct zone
        } else {
            (nums[mid], nums[high]) = (nums[high], nums[mid]);
            high--;               // 2 goes to high zone; DON'T advance mid (new nums[mid] unchecked)
        }
    }
}
// Time: O(n) single pass | Space: O(1)
```

> **🎯 Key Insight:** Insertion sort is used internally by .NET's `Array.Sort` for small subarrays (< 16 elements) — it's faster than quicksort for tiny arrays due to lower constant factors. This is called "introsort" — hybrid of quicksort, heapsort, and insertion sort.

---

## Section 23 — O(n log n) Sorts

> **🧠 Mental Model: Divide and Conquer the Chaos**
>
> **Merge Sort** = split the pile into two halves, sort each half separately, then carefully merge the two sorted piles — like a librarian sorting books by splitting the shelf, sorting each half, then merging back. Always O(n log n), guaranteed. **Quick Sort** = pick a "pivot" book, put all smaller books to its left, all larger to its right — now the pivot is in its final position! Repeat on left and right piles. Average O(n log n) but O(n²) worst case with bad pivot.

### Merge Sort

```csharp
// MERGE SORT — O(n log n) time, O(n) space — STABLE, guaranteed performance
void MergeSort(int[] arr, int left, int right) {
    if (left >= right) return;           // base case: single element

    int mid = left + (right - left) / 2; // avoid overflow vs (left+right)/2
    MergeSort(arr, left, mid);           // sort left half
    MergeSort(arr, mid + 1, right);      // sort right half
    Merge(arr, left, mid, right);        // merge sorted halves
}

void Merge(int[] arr, int left, int mid, int right) {
    // Copy to temp arrays
    int[] leftArr = arr[left..(mid+1)];     // C# range syntax
    int[] rightArr = arr[(mid+1)..(right+1)];

    int i = 0, j = 0, k = left;
    while (i < leftArr.Length && j < rightArr.Length) {
        // Take smaller element — <= makes it STABLE (preserves equal elements' order)
        if (leftArr[i] <= rightArr[j]) arr[k++] = leftArr[i++];
        else arr[k++] = rightArr[j++];
    }
    while (i < leftArr.Length) arr[k++] = leftArr[i++];
    while (j < rightArr.Length) arr[k++] = rightArr[j++];
}
// Time: O(n log n) always | Space: O(n) for temp arrays
```

### Quick Sort

```csharp
// QUICK SORT — O(n log n) average, O(n²) worst, O(log n) space — NOT stable
void QuickSort(int[] arr, int left, int right) {
    if (left >= right) return;
    int pivotIdx = Partition(arr, left, right);
    QuickSort(arr, left, pivotIdx - 1);
    QuickSort(arr, pivotIdx + 1, right);
}

int Partition(int[] arr, int left, int right) {
    // Lomuto partition — pivot = last element
    int pivot = arr[right];
    int i = left - 1;               // i = boundary of "less than pivot" zone

    for (int j = left; j < right; j++) {
        if (arr[j] <= pivot) {
            i++;
            (arr[i], arr[j]) = (arr[j], arr[i]);  // move to left zone
        }
    }
    // Place pivot in its final position
    (arr[i+1], arr[right]) = (arr[right], arr[i+1]);
    return i + 1;
}

// RANDOMIZED QUICKSORT — prevents O(n²) on sorted input
int PartitionRandom(int[] arr, int left, int right) {
    int randIdx = new Random().Next(left, right + 1);
    (arr[randIdx], arr[right]) = (arr[right], arr[randIdx]);  // swap random to end
    return Partition(arr, left, right);
}
```

### Heap Sort

```csharp
// HEAP SORT — O(n log n) guaranteed, O(1) space — NOT stable
void HeapSort(int[] arr) {
    int n = arr.Length;
    // Build max-heap: heapify from last non-leaf down to root
    for (int i = n / 2 - 1; i >= 0; i--)
        Heapify(arr, n, i);

    // Extract max one by one
    for (int i = n - 1; i > 0; i--) {
        (arr[0], arr[i]) = (arr[i], arr[0]);  // move current max to end
        Heapify(arr, i, 0);                    // re-heapify reduced heap
    }
}

void Heapify(int[] arr, int n, int i) {
    int largest = i, left = 2*i+1, right = 2*i+2;
    if (left < n && arr[left] > arr[largest]) largest = left;
    if (right < n && arr[right] > arr[largest]) largest = right;
    if (largest != i) {
        (arr[i], arr[largest]) = (arr[largest], arr[i]);
        Heapify(arr, n, largest);  // recursively heapify affected subtree
    }
}
```

### Comparison Table

| Algorithm | Best | Average | Worst | Space | Stable | Use when |
|-----------|------|---------|-------|-------|--------|---------|
| Merge Sort | O(n log n) | O(n log n) | O(n log n) | O(n) | Yes | Need stability or linked list sort |
| Quick Sort | O(n log n) | O(n log n) | O(n²) | O(log n) | No | General purpose, cache-friendly |
| Heap Sort | O(n log n) | O(n log n) | O(n log n) | O(1) | No | Need O(1) space + O(n log n) guarantee |

### 🔴 Practice Problem: Sort List (LeetCode #148 — Medium)

**Problem:** Sort a linked list in O(n log n) time and O(1) space.

```csharp
public ListNode SortList(ListNode head) {
    if (head?.Next == null) return head;  // base case: 0 or 1 nodes

    // Find middle using fast/slow pointers
    ListNode slow = head, fast = head.Next;
    while (fast?.Next != null) { slow = slow.Next; fast = fast.Next.Next; }

    ListNode mid = slow.Next;
    slow.Next = null;  // split the list into two halves

    ListNode left = SortList(head);   // sort first half
    ListNode right = SortList(mid);   // sort second half
    return Merge(left, right);        // merge sorted halves
}

ListNode Merge(ListNode l1, ListNode l2) {
    var dummy = new ListNode(0);
    ListNode curr = dummy;
    while (l1 != null && l2 != null) {
        if (l1.Val <= l2.Val) { curr.Next = l1; l1 = l1.Next; }
        else { curr.Next = l2; l2 = l2.Next; }
        curr = curr.Next;
    }
    curr.Next = l1 ?? l2;
    return dummy.Next;
}
// Time: O(n log n) | Space: O(log n) for recursion stack
```

---

## Section 24 — O(n) Sorts

> **🧠 Mental Model: Sorting Mail by ZIP Code**
>
> If you know the RANGE of values, you can sort without comparisons. **Counting Sort**: count how many envelopes go to each ZIP code, then place them — O(n + k) where k is the range. **Radix Sort**: sort by last digit, then second-to-last, etc. — sorting envelopes by ZIP digit-by-digit. **Bucket Sort**: divide envelopes into ZIP-code buckets (0-1k, 1k-2k...), sort each small bucket, combine.

### Counting Sort

```csharp
// COUNTING SORT — O(n + k) time, O(k) space where k = value range
// ONLY works for non-negative integers with a known bounded range
int[] CountingSort(int[] arr) {
    if (arr.Length == 0) return arr;
    int max = arr.Max();                // find range

    int[] count = new int[max + 1];
    foreach (int x in arr) count[x]++;  // count occurrences

    // Accumulate prefix sums (for stable sorting)
    for (int i = 1; i <= max; i++) count[i] += count[i - 1];

    int[] output = new int[arr.Length];
    // Build output right-to-left to maintain stability
    for (int i = arr.Length - 1; i >= 0; i--) {
        output[--count[arr[i]]] = arr[i];
    }
    return output;
}
```

### Radix Sort

```csharp
// RADIX SORT — O(d × (n + k)) where d = digits, k = base (usually 10)
// Best for large n with fixed-length integers
void RadixSort(int[] arr) {
    int max = arr.Max();
    // Sort by each digit position: 1s, 10s, 100s, ...
    for (int exp = 1; max / exp > 0; exp *= 10)
        CountingSortByDigit(arr, exp);
}

void CountingSortByDigit(int[] arr, int exp) {
    int n = arr.Length;
    int[] output = new int[n];
    int[] count = new int[10];  // digits 0-9

    foreach (int x in arr) count[(x / exp) % 10]++;
    for (int i = 1; i < 10; i++) count[i] += count[i - 1];
    for (int i = n - 1; i >= 0; i--) {
        int digit = (arr[i] / exp) % 10;
        output[--count[digit]] = arr[i];
    }
    Array.Copy(output, arr, n);
}
// Time: O(d × n) where d = number of digits | Space: O(n + 10)
```

### 🔴 Practice Problem: Maximum Gap (LeetCode #164 — Hard)

**Problem:** Given unsorted array, find max difference between successive elements in sorted form, in O(n) time and space.

```csharp
public int MaximumGap(int[] nums) {
    if (nums.Length < 2) return 0;
    int min = nums.Min(), max = nums.Max();
    if (min == max) return 0;

    int n = nums.Length;
    // Pigeonhole: gap >= (max-min)/(n-1) — use bucket size = this floor value
    int bucketSize = Math.Max(1, (max - min) / (n - 1));
    int bucketCount = (max - min) / bucketSize + 1;

    int[] bucketMin = new int[bucketCount];
    int[] bucketMax = new int[bucketCount];
    Array.Fill(bucketMin, int.MaxValue);
    Array.Fill(bucketMax, int.MinValue);

    foreach (int num in nums) {
        int idx = (num - min) / bucketSize;
        bucketMin[idx] = Math.Min(bucketMin[idx], num);
        bucketMax[idx] = Math.Max(bucketMax[idx], num);
    }

    int maxGap = 0, prevMax = min;
    foreach (int i in Enumerable.Range(0, bucketCount)) {
        if (bucketMin[i] == int.MaxValue) continue;  // empty bucket
        maxGap = Math.Max(maxGap, bucketMin[i] - prevMax);
        prevMax = bucketMax[i];
    }
    return maxGap;
}
// Time: O(n) | Space: O(n) — bucket sort approach
```

---

## Section 25 — .NET Sorting APIs

> **🧠 Mental Model: Using Power Tools Instead of Hand Tools**
>
> Writing your own sort is like carving with hand tools — great to understand, but in practice you use .NET's highly-optimized power tools. .NET's `Array.Sort` uses introsort (quicksort + heapsort + insertion sort hybrid) — O(n log n) guaranteed. Know the APIs cold for interview coding; know the internals for depth questions.

### .NET Sorting APIs

```csharp
// ARRAY.SORT — in-place, O(n log n), introsort
int[] arr = { 3, 1, 4, 1, 5, 9 };
Array.Sort(arr);                                    // ascending
Array.Sort(arr, (a, b) => b.CompareTo(a));          // descending
Array.Sort(arr, 2, 3);                              // sort subarray [2..4]

// SORT WITH CUSTOM COMPARER
string[] words = { "banana", "apple", "cherry" };
Array.Sort(words, (a, b) => a.Length.CompareTo(b.Length));  // by length

// LIST.SORT — same as Array.Sort but for List<T>
var list = new List<int> { 3, 1, 4, 1, 5 };
list.Sort();
list.Sort((a, b) => b - a);  // descending via difference (safe only for small values)

// LINQ ORDERING — creates new IEnumerable, does NOT sort in-place
var sorted = arr.OrderBy(x => x);                  // ascending
var sortedDesc = arr.OrderByDescending(x => x);    // descending
var multiSort = arr.OrderBy(x => x % 2).ThenBy(x => x);  // even first, then by value

// SORTEDSET / SORTEDDICTIONARY — auto-sorted on insert, O(log n) per op
var ss = new SortedSet<int> { 5, 1, 3 };           // iterates: 1, 3, 5
var sd = new SortedDictionary<string, int>();       // sorted by key

// STABILITY: List.Sort and Array.Sort are NOT stable (use LINQ OrderBy for stable sort)
// LINQ OrderBy IS stable — equal elements maintain original order
```

### 🔴 Practice Problem: Largest Number (LeetCode #179 — Medium)

**Problem:** Given array of non-negative integers, arrange them to form the largest number.

```csharp
public string LargestNumber(int[] nums) {
    string[] strs = Array.ConvertAll(nums, n => n.ToString());

    // Custom compare: "34" vs "3" → compare "343" vs "334" → "343" > "334" → "34" comes first
    Array.Sort(strs, (a, b) => string.Compare(b + a, a + b, StringComparison.Ordinal));

    // Edge case: if largest number is 0, whole result is "0"
    if (strs[0] == "0") return "0";

    return string.Concat(strs);
}
// Time: O(n k log n) where k = avg number length
// Key insight: define custom total order using concatenation comparison
```

> **🎯 Key Insight:** The comparison `(a + b).CompareTo(b + a)` defines a total order on strings for "maximum concatenation." This is the classic trick for this problem type. Always use `string.Compare` with `StringComparison.Ordinal` for predictable, locale-independent string comparison.

---

# PART 7 — SEARCHING ALGORITHMS

---

## Section 26 — Linear Search & Variants

> **🧠 Mental Model: Looking for Your Keys**
>
> Linear search is like looking for your keys in a messy room — you check every spot one by one until you find them. Inefficient but UNIVERSAL: works on ANY collection, sorted or not. The "Find Peak Element" variant is clever: use a directional clue (if left neighbor is bigger, peak must be left; if right is bigger, peak must be right) to eliminate half the search space at each step — turning O(n) into O(log n).

```csharp
// BASIC LINEAR SEARCH — O(n) time, O(1) space
int LinearSearch(int[] arr, int target) {
    for (int i = 0; i < arr.Length; i++)
        if (arr[i] == target) return i;
    return -1;
}

// .NET equivalents:
int idx = Array.IndexOf(arr, target);       // O(n) — returns -1 if not found
int idx2 = list.IndexOf(target);            // O(n) — List<T>
bool has = arr.Contains(target);            // O(n) — LINQ (NOT HashSet)
int first = arr.First(x => x > 5);         // O(n) — LINQ first matching
```

### 🔴 Practice Problem: Find Peak Element (LeetCode #162 — Medium)

**Problem:** A peak element is greater than its neighbors. Find any peak element's index in O(log n).

```csharp
public int FindPeakElement(int[] nums) {
    int left = 0, right = nums.Length - 1;

    while (left < right) {
        int mid = left + (right - left) / 2;

        if (nums[mid] > nums[mid + 1]) {
            // Peak is in left half (including mid) — mid could be the peak
            right = mid;
        } else {
            // nums[mid] < nums[mid+1]: peak is in right half
            left = mid + 1;
        }
    }

    return left;  // left == right: found the peak
}
// Time: O(log n) — binary search on unsorted! | Space: O(1)
// Key insight: if nums[mid] < nums[mid+1], going right is "uphill" → peak exists right
```

---

## Section 27 — Binary Search

> **🧠 Mental Model: The Hot-Cold Game**
>
> Binary search is the "hot/cold" guessing game. You guess the MIDDLE number. If too high → cold (go lower). If too low → cold (go higher). If just right → hot (found it!). Each guess eliminates HALF the remaining search space. After log₂(n) guesses you're guaranteed to find it. The SORTED requirement is like knowing the numbers are arranged from cold to hot — without sorting, you have no directional clue.

### Binary Search Variants

```csharp
// CLASSIC — find exact target
int BinarySearch(int[] arr, int target) {
    int left = 0, right = arr.Length - 1;
    while (left <= right) {                          // <= because right = arr.Length-1 (inclusive)
        int mid = left + (right - left) / 2;         // avoids integer overflow vs (left+right)/2
        if (arr[mid] == target) return mid;
        if (arr[mid] < target) left = mid + 1;       // target in right half
        else right = mid - 1;                         // target in left half
    }
    return -1;  // not found
}

// FIND LEFTMOST (first occurrence of target)
int FindFirst(int[] arr, int target) {
    int left = 0, right = arr.Length - 1, result = -1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] == target) {
            result = mid;   // record but keep searching LEFT
            right = mid - 1;
        } else if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return result;
}

// FIND RIGHTMOST (last occurrence of target)
int FindLast(int[] arr, int target) {
    int left = 0, right = arr.Length - 1, result = -1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] == target) {
            result = mid;   // record but keep searching RIGHT
            left = mid + 1;
        } else if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return result;
}

// LOWER BOUND — first index where arr[i] >= target
int LowerBound(int[] arr, int target) {
    int left = 0, right = arr.Length;  // right = arr.Length (exclusive)
    while (left < right) {             // < not <= (because right is exclusive)
        int mid = left + (right - left) / 2;
        if (arr[mid] < target) left = mid + 1;
        else right = mid;              // arr[mid] >= target: narrow from right
    }
    return left;  // first index >= target (arr.Length if all < target)
}

// UPPER BOUND — first index where arr[i] > target
int UpperBound(int[] arr, int target) {
    int left = 0, right = arr.Length;
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] <= target) left = mid + 1;
        else right = mid;
    }
    return left;  // first index > target
}

// .NET BUILT-IN
int idx = Array.BinarySearch(arr, target);   // returns idx if found, ~idx if not
// If not found: returns bitwise complement of insertion point (~idx = -(idx+1))
if (idx < 0) idx = ~idx;  // convert to insertion point
```

### 🔴 Practice Problem: Search in Rotated Sorted Array (LeetCode #33 — Medium)

**Problem:** Array was sorted then rotated at unknown pivot. Find target. O(log n).

```csharp
public int Search(int[] nums, int target) {
    int left = 0, right = nums.Length - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] == target) return mid;

        // Determine which half is sorted
        if (nums[left] <= nums[mid]) {
            // LEFT half is sorted [left..mid]
            if (nums[left] <= target && target < nums[mid])
                right = mid - 1;     // target in sorted left half
            else
                left = mid + 1;      // target in right half
        } else {
            // RIGHT half is sorted [mid..right]
            if (nums[mid] < target && target <= nums[right])
                left = mid + 1;      // target in sorted right half
            else
                right = mid - 1;     // target in left half
        }
    }
    return -1;
}
// Time: O(log n) | Space: O(1)
// Key: one of the two halves is ALWAYS sorted after rotation — identify which, then check if target falls in it
```

---

## Section 28 — Interpolation & Exponential Search

> **🧠 Mental Model: Smarter Phone Book Search**
>
> Binary search always checks the MIDDLE. But if you're looking for "Smith" in a phone book, you'd open near the END (S is toward the end). Interpolation search uses the VALUE to estimate position — more intuitive guessing. Exponential search starts with small jumps (1, 2, 4, 8, 16...) to find the RANGE, then binary searches within it — great for unbounded/infinite arrays.

```csharp
// INTERPOLATION SEARCH — O(log log n) avg for uniform distribution, O(n) worst
int InterpolationSearch(int[] arr, int target) {
    int left = 0, right = arr.Length - 1;
    while (left <= right && target >= arr[left] && target <= arr[right]) {
        if (left == right) return arr[left] == target ? left : -1;

        // Estimate position based on value distribution
        int pos = left + (int)((long)(target - arr[left]) * (right - left)
                               / (arr[right] - arr[left]));

        if (arr[pos] == target) return pos;
        if (arr[pos] < target) left = pos + 1;
        else right = pos - 1;
    }
    return -1;
}
// Works best when values are uniformly distributed
// Danger: integer overflow in formula — use (long) cast

// EXPONENTIAL SEARCH — O(log n) — good for unbounded arrays or when target is near front
int ExponentialSearch(int[] arr, int target) {
    if (arr[0] == target) return 0;
    int i = 1;
    // Double i until we find a range where target might be
    while (i < arr.Length && arr[i] <= target) i *= 2;
    // Binary search in [i/2, min(i, n-1)]
    return BinarySearch(arr, target, i / 2, Math.Min(i, arr.Length - 1));
}

int BinarySearch(int[] arr, int target, int left, int right) {
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] == target) return mid;
        if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}
```

### 🔴 Practice Problem: Search for a Range (LeetCode #34 — Medium)

**Problem:** Given sorted array and target, find [first, last] positions. O(log n).

```csharp
public int[] SearchRange(int[] nums, int target) {
    return new[] { FindFirst(nums, target), FindLast(nums, target) };
}
// Use the FindFirst and FindLast implementations from Section 27
// Time: O(log n) — two binary searches | Space: O(1)
```

---

# PART 8 — ALGORITHM DESIGN PARADIGMS

---

## Section 29 — Recursion & the Recursion Tree

> **🧠 Mental Model: Russian Nesting Dolls (Matryoshka)**
>
> Recursion is like opening a Russian doll — each doll contains a smaller identical doll, until you reach the tiny solid doll (base case). When you open the tiny doll, you start "returning" back: close the tiny doll inside the second-smallest, etc. The CALL STACK is the stack of open dolls on your table. Too many nested calls → stack overflow (too many dolls on the table).

### Recursion Template

```csharp
// RECURSION TEMPLATE — every recursive function follows this pattern:
ReturnType Solve(params) {
    // 1. BASE CASE(S) — when to stop recursing
    if (baseCondition) return baseValue;

    // 2. RECURSIVE CASE — break into smaller subproblem(s)
    ReturnType subResult = Solve(smallerParams);

    // 3. COMBINE — combine subresult with current state
    return combine(currentValue, subResult);
}

// EXAMPLES:
// Factorial — O(n) time, O(n) space
int Factorial(int n) {
    if (n <= 1) return 1;          // base case
    return n * Factorial(n - 1);   // recursive case + combine
}

// Fibonacci — O(2^n) naive, O(n) with memoization
int Fib(int n) {
    if (n <= 1) return n;
    return Fib(n-1) + Fib(n-2);   // two recursive calls
}

// Power function — O(log n) with divide & conquer
double Power(double x, int n) {
    if (n == 0) return 1;
    if (n < 0) return 1.0 / Power(x, -n);  // handle negative exponent
    if (n % 2 == 0) {
        double half = Power(x, n / 2);
        return half * half;                  // square the half-result
    }
    return x * Power(x, n - 1);
}
// O(log n) because we halve n each time with even exponent
```

### Recursion Tree Analysis

```
Fib(4)
├── Fib(3)
│   ├── Fib(2)
│   │   ├── Fib(1) = 1
│   │   └── Fib(0) = 0
│   └── Fib(1) = 1
└── Fib(2)
    ├── Fib(1) = 1  ← DUPLICATE WORK!
    └── Fib(0) = 0  ← DUPLICATE WORK!

Nodes in tree = O(2^n) → exponential time
Height of tree = n → O(n) space (call stack)
Fix: memoize already-computed values → O(n) time (see Section 32)
```

### 🔴 Practice Problem: Merge Two Sorted Lists (LeetCode #21 — Easy)

```csharp
public ListNode MergeTwoLists(ListNode l1, ListNode l2) {
    // Base cases
    if (l1 == null) return l2;
    if (l2 == null) return l1;

    // Compare heads and recurse on the rest
    if (l1.Val <= l2.Val) {
        l1.Next = MergeTwoLists(l1.Next, l2);  // l1 head wins, recurse rest of l1 with l2
        return l1;
    } else {
        l2.Next = MergeTwoLists(l1, l2.Next);  // l2 head wins, recurse l1 with rest of l2
        return l2;
    }
}
// Time: O(m + n) | Space: O(m + n) recursion stack
// Iterative version uses O(1) space — prefer that for very long lists
```

---

## Section 30 — Backtracking

> **🧠 Mental Model: A Decision Tree with an Eraser**
>
> Backtracking is like solving a maze with a pencil and eraser. At every junction, you pick a direction (make a choice), follow it, and if it leads to a dead end (invalid state), you erase your path and try the next option. The KEY operations are: **choose** (make a decision), **explore** (recurse), **unchoose** (undo the decision — this is what makes it "backtracking"). Pruning (skipping bad paths early) is what makes backtracking efficient.

### Backtracking Template

```csharp
void Backtrack(state, choices, results) {
    // 1. Is this a complete solution?
    if (isSolution(state)) {
        results.Add(state.Clone());  // add a copy, not reference!
        return;
    }

    foreach (choice in getChoices(state)) {
        if (isValid(state, choice)) {
            // Choose
            makeChoice(state, choice);
            // Explore
            Backtrack(state, choices, results);
            // Unchoose (backtrack)
            undoChoice(state, choice);
        }
    }
}
```

### Classic Backtracking Problems

```csharp
// PERMUTATIONS — generate all orderings of nums
IList<IList<int>> Permute(int[] nums) {
    var result = new List<IList<int>>();
    bool[] used = new bool[nums.Length];
    var current = new List<int>();

    void Backtrack() {
        if (current.Count == nums.Length) {
            result.Add(new List<int>(current));  // copy! not reference
            return;
        }
        for (int i = 0; i < nums.Length; i++) {
            if (used[i]) continue;               // skip used elements
            used[i] = true;   current.Add(nums[i]);      // choose
            Backtrack();                                   // explore
            used[i] = false;  current.RemoveAt(current.Count - 1); // unchoose
        }
    }

    Backtrack();
    return result;
}
// Time: O(n! × n) | Space: O(n) recursion + O(n! × n) output

// N-QUEENS — place n queens on n×n board, no two attack each other
IList<IList<string>> SolveNQueens(int n) {
    var result = new List<IList<string>>();
    int[] queens = new int[n];  // queens[row] = column of queen in that row
    bool[] cols = new bool[n], diag1 = new bool[2*n], diag2 = new bool[2*n];

    void Place(int row) {
        if (row == n) {
            result.Add(BuildBoard(queens, n));
            return;
        }
        for (int col = 0; col < n; col++) {
            if (cols[col] || diag1[row-col+n] || diag2[row+col]) continue;
            cols[col] = diag1[row-col+n] = diag2[row+col] = true;
            queens[row] = col;
            Place(row + 1);
            cols[col] = diag1[row-col+n] = diag2[row+col] = false;
        }
    }
    Place(0);
    return result;
}

IList<string> BuildBoard(int[] queens, int n) {
    return Enumerable.Range(0, n).Select(r => {
        char[] row = new string('.', n).ToCharArray();
        row[queens[r]] = 'Q';
        return new string(row);
    }).ToList();
}
```

### 🔴 Practice Problem: Letter Combinations of a Phone Number (LeetCode #17 — Medium)

```csharp
public IList<string> LetterCombinations(string digits) {
    if (string.IsNullOrEmpty(digits)) return new List<string>();

    var phone = new Dictionary<char, string> {
        {'2',"abc"},{'3',"def"},{'4',"ghi"},{'5',"jkl"},
        {'6',"mno"},{'7',"pqrs"},{'8',"tuv"},{'9',"wxyz"}
    };

    var result = new List<string>();
    var sb = new StringBuilder();

    void Backtrack(int idx) {
        if (idx == digits.Length) { result.Add(sb.ToString()); return; }
        foreach (char c in phone[digits[idx]]) {
            sb.Append(c);          // choose
            Backtrack(idx + 1);    // explore
            sb.Length--;           // unchoose (remove last char)
        }
    }

    Backtrack(0);
    return result;
}
// Time: O(4^n × n) worst case (digit '7' has 4 letters) | Space: O(n) recursion
```

---

## Section 31 — Divide & Conquer

> **🧠 Mental Model: The Army General's Strategy**
>
> Divide and conquer is the general who never fights a massive battle directly. Instead: DIVIDE the enemy into smaller armies, CONQUER each small army separately, then COMBINE victories into overall victory. The power: if dividing in half each time, you get O(log n) levels. If each level does O(n) work, total is O(n log n). Master Theorem formalizes this.

### Master Theorem (Quick Reference)

```
Recurrence: T(n) = aT(n/b) + f(n)
where: a = subproblems, b = size reduction factor, f(n) = work at current level

Case 1: f(n) = O(n^(log_b(a) - ε))  → T(n) = O(n^log_b(a))    [subproblem work dominates]
Case 2: f(n) = O(n^log_b(a))        → T(n) = O(n^log_b(a) × log n) [work at each level equal]
Case 3: f(n) = Ω(n^(log_b(a) + ε)) → T(n) = O(f(n))            [current level work dominates]

Examples:
Merge sort: T(n) = 2T(n/2) + O(n) → a=2, b=2, n^log2(2)=n → Case 2 → O(n log n)
Binary search: T(n) = T(n/2) + O(1) → a=1, b=2, n^log2(1)=1 → Case 2 → O(log n)
```

```csharp
// MAXIMUM SUBARRAY — divide & conquer approach (not optimal but educational)
int MaxSubArray(int[] nums, int left, int right) {
    if (left == right) return nums[left];  // base case: single element

    int mid = (left + right) / 2;
    int leftMax = MaxSubArray(nums, left, mid);        // max in left half
    int rightMax = MaxSubArray(nums, mid + 1, right);  // max in right half
    int crossMax = MaxCrossing(nums, left, mid, right); // max spanning mid

    return Math.Max(Math.Max(leftMax, rightMax), crossMax);
}

int MaxCrossing(int[] nums, int left, int mid, int right) {
    // Max sum from mid going LEFT
    int leftSum = int.MinValue, sum = 0;
    for (int i = mid; i >= left; i--) {
        sum += nums[i];
        leftSum = Math.Max(leftSum, sum);
    }
    // Max sum from mid+1 going RIGHT
    int rightSum = int.MinValue; sum = 0;
    for (int i = mid + 1; i <= right; i++) {
        sum += nums[i];
        rightSum = Math.Max(rightSum, sum);
    }
    return leftSum + rightSum;
}
// Time: O(n log n) — Kadane's algorithm is O(n) and simpler, but this shows D&C
```

### 🔴 Practice Problem: Maximum Subarray (LeetCode #53 — Medium)

```csharp
// KADANE'S ALGORITHM — O(n) time, O(1) space (the production solution)
public int MaxSubArray(int[] nums) {
    int maxSum = nums[0], currentSum = nums[0];

    for (int i = 1; i < nums.Length; i++) {
        // Either extend previous subarray or start fresh from current element
        currentSum = Math.Max(nums[i], currentSum + nums[i]);
        maxSum = Math.Max(maxSum, currentSum);
    }
    return maxSum;
}
// Key insight: if currentSum goes negative, starting fresh is always better
```

---

## Section 32 — Dynamic Programming: Memoization

> **🧠 Mental Model: The Student with a Notebook**
>
> Imagine a student solving math problems. Without a notebook (pure recursion), they solve the same sub-problems from scratch every time — wasteful. With a notebook (memoization), they write down each answer the first time: "Fib(10) = 55". Next time Fib(10) is needed, just look up the notebook — O(1). Memoization = recursion + a lookup table (notebook). Top-down: start from the big problem, recurse down, save results.

### Memoization Pattern

```csharp
// FIBONACCI with memoization — O(n) time, O(n) space
int[] memo = new int[n + 1];
Array.Fill(memo, -1);  // -1 = not computed yet

int Fib(int n) {
    if (n <= 1) return n;
    if (memo[n] != -1) return memo[n];  // already computed — O(1) lookup
    memo[n] = Fib(n-1) + Fib(n-2);     // compute and SAVE
    return memo[n];
}
// Without memo: O(2^n) time. With memo: O(n) time — same problem!

// GENERAL MEMOIZATION TEMPLATE with Dictionary (for non-integer keys)
var cache = new Dictionary<string, int>();

int SolveDP(string state) {
    if (IsBaseCase(state)) return BaseValue(state);
    if (cache.ContainsKey(state)) return cache[state];

    int result = ComputeFromSubproblems(state);
    cache[state] = result;
    return result;
}

// CLIMBING STAIRS — O(n) time, O(n) space with memo
int[] dp;
int ClimbStairs(int n) {
    dp = new int[n + 1];
    return Climb(n);
}
int Climb(int n) {
    if (n <= 1) return 1;
    if (dp[n] != 0) return dp[n];
    dp[n] = Climb(n-1) + Climb(n-2);  // can take 1 or 2 steps
    return dp[n];
}
```

### 🔴 Practice Problem: Climbing Stairs (LeetCode #70 — Easy)

**Problem:** To climb n stairs, you can take 1 or 2 steps at a time. How many distinct ways?

```csharp
// MEMOIZED RECURSION
public int ClimbStairs(int n) {
    int[] memo = new int[n + 1];
    return Helper(n, memo);
}
int Helper(int n, int[] memo) {
    if (n <= 1) return 1;                          // 0 or 1 stair: 1 way
    if (memo[n] != 0) return memo[n];
    memo[n] = Helper(n-1, memo) + Helper(n-2, memo);
    return memo[n];
}

// BOTTOM-UP (tabulation — see Section 33 for full explanation)
public int ClimbStairsDP(int n) {
    if (n <= 1) return 1;
    int prev2 = 1, prev1 = 1;
    for (int i = 2; i <= n; i++) {
        int curr = prev1 + prev2;
        prev2 = prev1;
        prev1 = curr;
    }
    return prev1;
}
// Time: O(n) | Space: O(1) — notice it's the same as Fibonacci!
```

> **🎯 Key Insight:** Climbing stairs with 1 or 2 steps = Fibonacci sequence. stairs(n) = stairs(n-1) + stairs(n-2). This pattern "number of ways to reach state n = sum of ways to reach previous states" appears constantly in DP problems.

---

## Section 33 — Dynamic Programming: Tabulation

> **🧠 Mental Model: Filling a Spreadsheet Bottom-Up**
>
> Tabulation (bottom-up DP) is like filling a spreadsheet from cell A1 upward. You start with known base values, then compute each cell using already-computed cells. No recursion — just iteration. The DP table explicitly stores all subproblem answers. Advantage over memoization: no recursion overhead, no stack overflow, easier to optimize space by keeping only recent rows.

### Tabulation Pattern

```csharp
// FIBONACCI — tabulation (contrast with memoization in Section 32)
int FibTabulation(int n) {
    if (n <= 1) return n;
    int[] dp = new int[n + 1];
    dp[0] = 0; dp[1] = 1;                      // base cases
    for (int i = 2; i <= n; i++)
        dp[i] = dp[i-1] + dp[i-2];             // build up from base
    return dp[n];
}

// SPACE OPTIMIZED — only keep last 2 values (O(1) space)
int FibOptimized(int n) {
    if (n <= 1) return n;
    int prev2 = 0, prev1 = 1;
    for (int i = 2; i <= n; i++) {
        int curr = prev1 + prev2;
        prev2 = prev1; prev1 = curr;
    }
    return prev1;
}

// 0/1 KNAPSACK — classic 2D DP table
// items[i] = (weight, value), capacity = max weight
int Knapsack(int[] weights, int[] values, int capacity) {
    int n = weights.Length;
    // dp[i][w] = max value using first i items with capacity w
    int[,] dp = new int[n + 1, capacity + 1];

    for (int i = 1; i <= n; i++) {
        for (int w = 0; w <= capacity; w++) {
            // Option 1: don't take item i
            dp[i, w] = dp[i-1, w];
            // Option 2: take item i (if it fits)
            if (weights[i-1] <= w)
                dp[i, w] = Math.Max(dp[i, w],
                    dp[i-1, w - weights[i-1]] + values[i-1]);
        }
    }
    return dp[n, capacity];
}
// Time: O(n × capacity) | Space: O(n × capacity)
// Space optimization: use 1D rolling array O(capacity)
```

### 🔴 Practice Problem: Coin Change (LeetCode #322 — Medium)

**Problem:** Given coins of different denominations and an amount, find minimum coins needed.

```csharp
public int CoinChange(int[] coins, int amount) {
    // dp[i] = minimum coins to make amount i
    int[] dp = new int[amount + 1];
    Array.Fill(dp, amount + 1);  // initialize with impossible large value
    dp[0] = 0;                   // base case: 0 coins to make amount 0

    for (int i = 1; i <= amount; i++) {
        foreach (int coin in coins) {
            if (coin <= i) {
                // Option: use this coin + min coins for (i - coin)
                dp[i] = Math.Min(dp[i], dp[i - coin] + 1);
            }
        }
    }

    return dp[amount] > amount ? -1 : dp[amount];  // -1 if impossible
}
// Time: O(amount × coins.Length) | Space: O(amount)

// TRACE for coins=[1,2,5], amount=11:
// dp[0]=0, dp[1]=1, dp[2]=1, dp[3]=2, dp[4]=2, dp[5]=1, dp[6]=2, ..., dp[11]=3
// Answer: 11 = 5+5+1 → 3 coins
```

> **🎯 Key Insight:** The key DP recurrence is: `dp[i] = min(dp[i - coin] + 1)` for all coins ≤ i. "Use this coin" means solve a smaller subproblem (amount - coin) and add 1 coin. Always initialize the DP table to an "impossible" sentinel (amount+1 or int.MaxValue/2) to distinguish reachable from unreachable states.

---

## Section 34 — Classic DP Problems

> **🧠 Mental Model: Building Blocks — Each State Uses Previous States**
>
> Every DP problem has the same soul: "the answer to the current state is a function of previously computed states." The art is identifying WHAT the state represents, WHAT the transition is, and WHAT the base cases are.

### Longest Common Subsequence (LCS)

```csharp
// dp[i][j] = LCS length of s1[0..i-1] and s2[0..j-1]
public int LongestCommonSubsequence(string s1, string s2) {
    int m = s1.Length, n = s2.Length;
    int[,] dp = new int[m + 1, n + 1];  // extra row/col for empty string base case

    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (s1[i-1] == s2[j-1])
                dp[i, j] = dp[i-1, j-1] + 1;  // characters match: extend LCS
            else
                dp[i, j] = Math.Max(dp[i-1, j], dp[i, j-1]);  // skip one char
        }
    }
    return dp[m, n];
}
// Time: O(m × n) | Space: O(m × n), optimizable to O(min(m,n))
```

### Longest Increasing Subsequence (LIS)

```csharp
// O(n²) DP: dp[i] = LIS ending at index i
public int LengthOfLIS(int[] nums) {
    int n = nums.Length;
    int[] dp = new int[n];
    Array.Fill(dp, 1);  // each element is a subsequence of length 1

    for (int i = 1; i < n; i++)
        for (int j = 0; j < i; j++)
            if (nums[j] < nums[i])
                dp[i] = Math.Max(dp[i], dp[j] + 1);

    return dp.Max();
}
// Time: O(n²) | Space: O(n)

// O(n log n) — patience sorting with binary search
public int LengthOfLISOpt(int[] nums) {
    var tails = new List<int>();  // tails[i] = smallest tail of IS of length i+1

    foreach (int num in nums) {
        int pos = tails.BinarySearch(num);
        if (pos < 0) pos = ~pos;          // insertion point
        if (pos == tails.Count) tails.Add(num);   // extend LIS
        else tails[pos] = num;                      // replace to keep tails small
    }
    return tails.Count;
}
// Time: O(n log n) | Space: O(n)
```

### Edit Distance

```csharp
// dp[i][j] = min edits to convert s1[0..i-1] to s2[0..j-1]
public int MinDistance(string word1, string word2) {
    int m = word1.Length, n = word2.Length;
    int[,] dp = new int[m + 1, n + 1];

    // Base cases: convert to/from empty string
    for (int i = 0; i <= m; i++) dp[i, 0] = i;  // delete all of word1
    for (int j = 0; j <= n; j++) dp[0, j] = j;  // insert all of word2

    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (word1[i-1] == word2[j-1]) {
                dp[i, j] = dp[i-1, j-1];          // no edit needed
            } else {
                dp[i, j] = 1 + Math.Min(dp[i-1, j-1],    // replace
                               Math.Min(dp[i-1, j],        // delete from word1
                                        dp[i, j-1]));       // insert into word1
            }
        }
    }
    return dp[m, n];
}
// Time: O(m × n) | Space: O(m × n)
```

### 🔴 Practice Problem: Longest Common Subsequence (LeetCode #1143 — Medium)

The `LongestCommonSubsequence` method above is the solution.

```csharp
// Time: O(m × n) | Space: O(m × n)
// TRACE: s1="abcde", s2="ace"
// LCS = "ace" → length 3
// dp[i][j] table shows how LCS grows character by character
```

---

## Section 35 — Greedy Algorithms

> **🧠 Mental Model: The Backpacker's Knapsack (Fractional)**
>
> A greedy algorithm makes the LOCALLY OPTIMAL choice at each step, hoping it leads to a globally optimal solution. Like a hiker choosing trails: always take the path with the best scenery now (no backtracking). Greedy works when the problem has "greedy choice property" — locally optimal choices lead to globally optimal. Greedy DOESN'T work for 0/1 knapsack (you can't take fraction of item) but DOES work for fractional knapsack and interval scheduling.

### When Greedy Works

```
Greedy works when:
1. Greedy choice property: local optimal → global optimal
2. Optimal substructure: optimal solution contains optimal sub-solutions

Classic greedy problems:
- Activity selection / interval scheduling
- Huffman encoding
- Dijkstra's algorithm (greedy shortest path)
- Kruskal's / Prim's MST
- Fractional knapsack
- Jump Game
```

### Interval Scheduling (Activity Selection)

```csharp
// Maximize number of non-overlapping activities
// Greedy: always pick the activity that ENDS EARLIEST
int MaxActivities(int[,] intervals) {
    // Sort by end time
    int n = intervals.GetLength(0);
    var sorted = Enumerable.Range(0, n)
        .OrderBy(i => intervals[i, 1])
        .Select(i => (start: intervals[i, 0], end: intervals[i, 1]))
        .ToArray();

    int count = 1;
    int lastEnd = sorted[0].end;

    for (int i = 1; i < n; i++) {
        if (sorted[i].start >= lastEnd) {  // non-overlapping
            count++;
            lastEnd = sorted[i].end;
        }
    }
    return count;
}
```

### 🔴 Practice Problem: Jump Game (LeetCode #55 — Medium)

**Problem:** Given array where nums[i] = max jump length at position i, can you reach the last index?

```csharp
public bool CanJump(int[] nums) {
    int maxReach = 0;  // furthest index we can reach so far

    for (int i = 0; i < nums.Length; i++) {
        if (i > maxReach) return false;           // can't reach position i
        maxReach = Math.Max(maxReach, i + nums[i]); // update furthest reach
    }
    return true;
}
// Time: O(n) | Space: O(1)
// Greedy choice: at each position, extend our reach as far as possible
// If we ever find a position we CAN'T reach → return false
```

> **🎯 Key Insight:** Proving greedy works requires showing the "exchange argument": swapping any non-greedy choice with the greedy choice doesn't make things worse. For Jump Game: the greedy "maximize reach" choice is optimal because covering more ground can only help — never hurts.

---

# PART 9 — PROBLEM-SOLVING PATTERNS

---

## Section 36 — Two Pointers

> **🧠 Mental Model: Squeezing a Water Balloon**
>
> Two pointers is like two hands squeezing a water balloon from both ends toward the middle. One pointer starts at the left, one at the right. They move toward each other based on logic (e.g., "sum too small → move left pointer right; sum too big → move right pointer left"). Works perfectly on SORTED arrays because the sorted order gives directional information — moving a pointer is a meaningful decision, not a random guess.

### Two Pointers Patterns

```csharp
// PATTERN 1: OPPOSITE ENDS — find pair with target sum in sorted array
bool TwoSum_Sorted(int[] arr, int target) {
    int left = 0, right = arr.Length - 1;
    while (left < right) {
        int sum = arr[left] + arr[right];
        if (sum == target) return true;
        if (sum < target) left++;      // need bigger sum → move left right
        else right--;                  // need smaller sum → move right left
    }
    return false;
}
// Time: O(n) | Space: O(1)

// PATTERN 2: SAME DIRECTION — remove duplicates from sorted array
int RemoveDuplicates(int[] nums) {
    int slow = 0;  // boundary of unique elements
    for (int fast = 1; fast < nums.Length; fast++) {
        if (nums[fast] != nums[slow]) {
            slow++;
            nums[slow] = nums[fast];  // place unique element
        }
    }
    return slow + 1;  // length of unique portion
}

// PATTERN 3: PARTITION — Dutch flag, quicksort partition
// (See Section 22 — Sort Colors for example)

// IS PALINDROME — two pointers from both ends
bool IsPalindrome(string s) {
    int left = 0, right = s.Length - 1;
    while (left < right) {
        if (s[left] != s[right]) return false;
        left++; right--;
    }
    return true;
}
```

### 🔴 Practice Problem: 3Sum (LeetCode #15 — Medium)

**Problem:** Find all unique triplets that sum to zero.

```csharp
public IList<IList<int>> ThreeSum(int[] nums) {
    Array.Sort(nums);  // sort first — enables two-pointer + skip duplicates
    var result = new List<IList<int>>();

    for (int i = 0; i < nums.Length - 2; i++) {
        if (i > 0 && nums[i] == nums[i-1]) continue;  // skip duplicate first elements
        if (nums[i] > 0) break;                        // sorted: if first > 0, no triplet sums to 0

        int left = i + 1, right = nums.Length - 1;
        while (left < right) {
            int sum = nums[i] + nums[left] + nums[right];
            if (sum == 0) {
                result.Add(new List<int> { nums[i], nums[left], nums[right] });
                while (left < right && nums[left] == nums[left+1]) left++;   // skip dupes
                while (left < right && nums[right] == nums[right-1]) right--; // skip dupes
                left++; right--;
            } else if (sum < 0) left++;
            else right--;
        }
    }
    return result;
}
// Time: O(n²) | Space: O(1) extra (output not counted)
```

> **🎯 Key Insight:** Two pointers requires SORTED input to make directional decisions meaningful. Always sort first if not sorted (O(n log n) prefix). Duplicate-skipping logic is the trickiest part — skip after finding a valid triplet to avoid duplicate output.

---

## Section 37 — Sliding Window

> **🧠 Mental Model: A Moving Spotlight on a Stage**
>
> Imagine a spotlight on a theater stage. It illuminates a fixed-width section (window), then slides right. At each position, you can see the actors (elements) in the spotlight. Adding the rightmost actor: O(1). Removing the leftmost when sliding: O(1). The entire scan is O(n) because every actor enters and exits the spotlight exactly once. Fixed window = window size never changes. Variable window = expand right until invalid, then shrink from left.

### Fixed & Variable Window

```csharp
// FIXED-SIZE WINDOW — max sum of subarray of size k
int MaxSumSubarray(int[] arr, int k) {
    int windowSum = 0, maxSum = 0;
    // Build initial window
    for (int i = 0; i < k; i++) windowSum += arr[i];
    maxSum = windowSum;
    // Slide: add right element, remove left element
    for (int i = k; i < arr.Length; i++) {
        windowSum += arr[i] - arr[i - k];  // O(1): add new, remove old
        maxSum = Math.Max(maxSum, windowSum);
    }
    return maxSum;
}

// VARIABLE-SIZE WINDOW — smallest subarray with sum >= target
int MinSubarrayLen(int target, int[] nums) {
    int minLen = int.MaxValue, windowSum = 0, left = 0;

    for (int right = 0; right < nums.Length; right++) {
        windowSum += nums[right];                // expand window right

        while (windowSum >= target) {            // shrink from left while valid
            minLen = Math.Min(minLen, right - left + 1);
            windowSum -= nums[left++];
        }
    }
    return minLen == int.MaxValue ? 0 : minLen;
}
// Time: O(n) — right moves n times, left moves at most n times total
```

### 🔴 Practice Problem: Longest Substring Without Repeating (LeetCode #3 — Medium)

```csharp
public int LengthOfLongestSubstring(string s) {
    var charIndex = new Dictionary<char, int>();  // char → last seen index
    int maxLen = 0, left = 0;

    for (int right = 0; right < s.Length; right++) {
        char c = s[right];

        // If char seen before AND it's inside current window → shrink left
        if (charIndex.TryGetValue(c, out int prevIdx) && prevIdx >= left)
            left = prevIdx + 1;  // move left past the duplicate

        charIndex[c] = right;    // update last seen position
        maxLen = Math.Max(maxLen, right - left + 1);
    }
    return maxLen;
}
// Time: O(n) | Space: O(min(n, charset)) — dictionary size bounded by alphabet size

// OPTIMIZATION with int[128] for ASCII:
int LengthOptimized(string s) {
    int[] lastSeen = new int[128];  // ASCII char → last seen index
    Array.Fill(lastSeen, -1);
    int maxLen = 0, left = 0;
    for (int right = 0; right < s.Length; right++) {
        int c = s[right];
        if (lastSeen[c] >= left) left = lastSeen[c] + 1;
        lastSeen[c] = right;
        maxLen = Math.Max(maxLen, right - left + 1);
    }
    return maxLen;
}
```

---

## Section 38 — Fast & Slow Pointers

> **🧠 Mental Model: The Tortoise and the Hare**
>
> Fast pointer moves 2 steps at a time; slow pointer moves 1 step. If there's a cycle (loop), the hare eventually laps the tortoise and they meet inside the cycle — like runners on a circular track. If no cycle, the hare reaches the end first. This "differential speed" technique is magical: it detects cycles in O(1) space (no visited set needed) and finds the MIDDLE of a list (when hare reaches end, tortoise is at middle).

```csharp
// DETECT CYCLE — Floyd's Tortoise and Hare
bool HasCycle(ListNode head) {
    ListNode slow = head, fast = head;
    while (fast?.Next != null) {         // fast needs 2 nodes ahead
        slow = slow.Next;
        fast = fast.Next.Next;
        if (slow == fast) return true;   // they met → cycle!
    }
    return false;
}

// FIND CYCLE START — where does the cycle begin?
ListNode DetectCycle(ListNode head) {
    ListNode slow = head, fast = head;
    // Phase 1: detect cycle
    while (fast?.Next != null) {
        slow = slow.Next; fast = fast.Next.Next;
        if (slow == fast) break;
    }
    if (fast?.Next == null) return null;  // no cycle

    // Phase 2: find cycle start
    // Mathematical proof: distance from head to cycle start = distance from meeting point to cycle start
    slow = head;
    while (slow != fast) { slow = slow.Next; fast = fast.Next; }
    return slow;  // cycle start node
}

// FIND MIDDLE OF LINKED LIST
ListNode FindMiddle(ListNode head) {
    ListNode slow = head, fast = head;
    while (fast?.Next != null) {
        slow = slow.Next;
        fast = fast.Next.Next;
    }
    return slow;  // when fast reaches end, slow is at middle
    // For even length: slow points to second middle (use fast.Next != null for first middle)
}
```

### 🔴 Practice Problem: Linked List Cycle II (LeetCode #142 — Medium)

**Problem:** Return the node where the cycle begins. If no cycle, return null.

The `DetectCycle` method above IS the solution.

```csharp
// Why does slow=head + both advance at speed 1 find cycle start?
// Let: F = distance from head to cycle start
//      C = cycle length
//      a = distance from cycle start to meeting point
// When they meet: slow traveled F+a, fast traveled F+a+C (one extra loop)
// Fast = 2 × Slow: F+a+C = 2(F+a) → C = F+a → F = C-a
// So: head → cycle_start = cycle_start+a → cycle_start (wrapping)
// Moving both at speed 1, they MUST meet at cycle_start!
```

---

## Section 39 — Merge Intervals

> **🧠 Mental Model: Combining Overlapping Calendar Appointments**
>
> Given a calendar with overlapping appointments [1,3], [2,6], [8,10] — you want to merge [1,3] and [2,6] into [1,6] because they overlap. Sort all appointments by start time, then greedily merge: if current appointment starts before the previous one ends, extend the previous end. Otherwise, start a new merged interval.

```csharp
// MERGE INTERVALS
public int[][] Merge(int[][] intervals) {
    if (intervals.Length <= 1) return intervals;

    // Sort by start time
    Array.Sort(intervals, (a, b) => a[0].CompareTo(b[0]));

    var result = new List<int[]>();
    result.Add(intervals[0]);

    for (int i = 1; i < intervals.Length; i++) {
        int[] last = result[^1];         // last merged interval
        if (intervals[i][0] <= last[1]) {
            // Overlapping: extend the end of last interval if needed
            last[1] = Math.Max(last[1], intervals[i][1]);
        } else {
            // Non-overlapping: add as new interval
            result.Add(intervals[i]);
        }
    }
    return result.ToArray();
}
// Time: O(n log n) for sort + O(n) merge = O(n log n) | Space: O(n)

// INSERT INTERVAL — insert into sorted non-overlapping list
public int[][] Insert(int[][] intervals, int[] newInterval) {
    var result = new List<int[]>();
    int i = 0, n = intervals.Length;

    // Add all intervals ending before newInterval starts
    while (i < n && intervals[i][1] < newInterval[0])
        result.Add(intervals[i++]);

    // Merge all overlapping intervals with newInterval
    while (i < n && intervals[i][0] <= newInterval[1]) {
        newInterval[0] = Math.Min(newInterval[0], intervals[i][0]);
        newInterval[1] = Math.Max(newInterval[1], intervals[i][1]);
        i++;
    }
    result.Add(newInterval);

    // Add remaining non-overlapping intervals
    while (i < n) result.Add(intervals[i++]);
    return result.ToArray();
}
// Time: O(n) — single pass | Space: O(n)
```

### 🔴 Practice Problem: Merge Intervals (LeetCode #56 — Medium)

The `Merge` method above is the complete solution.

> **🎯 Key Insight:** Sorting by start time is the key pre-step. After sorting, you only need to compare each interval with the LAST merged interval (not all previous ones). The merge condition is `intervals[i].start <= last.end` (not `< last.end` — touching intervals should merge).

---

## Section 40 — Cyclic Sort

> **🧠 Mental Model: Putting Books in Their Numbered Slots**
>
> You have books numbered 1 to n, placed randomly on a shelf. Cyclic sort: look at the book in position i — if it belongs in slot X, swap it to slot X. Repeat until the book in position i IS in its correct slot. Each book is placed at most ONCE, so the total is O(n). Perfect for "numbers 1 to n with duplicates or missing values."

```csharp
// CYCLIC SORT — O(n) time, O(1) space
// Works when numbers are in range [1, n] or [0, n-1]
void CyclicSort(int[] nums) {
    int i = 0;
    while (i < nums.Length) {
        int j = nums[i] - 1;  // correct index for nums[i] (1-indexed: value 3 → index 2)
        if (nums[i] != nums[j]) {
            (nums[i], nums[j]) = (nums[j], nums[i]);  // swap to correct position
        } else {
            i++;  // element is in correct position or is a duplicate
        }
    }
}

// FIND MISSING NUMBER — after cyclic sort, find index where nums[i] != i+1
int FindMissingNumber(int[] nums) {
    CyclicSort(nums);
    for (int i = 0; i < nums.Length; i++)
        if (nums[i] != i + 1) return i + 1;
    return nums.Length + 1;
}
```

### 🔴 Practice Problem: Find All Duplicates in Array (LeetCode #442 — Medium)

**Problem:** Array of n integers where 1 ≤ a[i] ≤ n. Some appear twice. Find all duplicates.

```csharp
public IList<int> FindDuplicates(int[] nums) {
    var result = new List<int>();
    // Cyclic sort: place each num at index (num-1)
    int i = 0;
    while (i < nums.Length) {
        int correct = nums[i] - 1;
        if (nums[i] != nums[correct]) {
            (nums[i], nums[correct]) = (nums[correct], nums[i]);
        } else {
            i++;
        }
    }
    // Any number not at its correct index is a duplicate
    for (int j = 0; j < nums.Length; j++)
        if (nums[j] != j + 1) result.Add(nums[j]);
    return result;
}
// Time: O(n) | Space: O(1) extra
```

---

## Section 41 — In-place Linked List Reversal

> **🧠 Mental Model: Reversing a Chain of Paperclips**
>
> Each paperclip (node) has a hook pointing right (Next pointer). To reverse, unhook each clip from the right and reattach it to the left. The 3-variable dance: save the next clip (nextTemp), reattach current clip leftward (curr.Next = prev), advance both pointers. Reverse in groups: reverse k clips at a time, then reconnect the groups.

```csharp
// REVERSE ENTIRE LIST — O(n) time, O(1) space
ListNode ReverseList(ListNode head) {
    ListNode prev = null, curr = head;
    while (curr != null) {
        ListNode next = curr.Next;  // 1. save next
        curr.Next = prev;           // 2. reverse pointer
        prev = curr;                // 3. advance prev
        curr = next;                // 4. advance curr
    }
    return prev;  // new head
}

// REVERSE SUBLIST [left, right] — 1-indexed
ListNode ReverseBetween(ListNode head, int left, int right) {
    var dummy = new ListNode(0, head);
    ListNode prev = dummy;

    // Advance prev to node just before 'left'
    for (int i = 1; i < left; i++) prev = prev.Next;

    ListNode curr = prev.Next;  // first node of sublist to reverse
    for (int i = 0; i < right - left; i++) {
        ListNode next = curr.Next;
        curr.Next = next.Next;   // disconnect next from its position
        next.Next = prev.Next;   // attach next at the front of reversed portion
        prev.Next = next;        // update prev's next to the newly inserted node
    }
    return dummy.Next;
}
```

### 🔴 Practice Problem: Reverse Nodes in k-Group (LeetCode #25 — Hard)

```csharp
public ListNode ReverseKGroup(ListNode head, int k) {
    // Check if there are at least k nodes remaining
    ListNode check = head;
    for (int i = 0; i < k; i++) {
        if (check == null) return head;  // fewer than k nodes — don't reverse
        check = check.Next;
    }

    // Reverse k nodes
    ListNode prev = null, curr = head;
    for (int i = 0; i < k; i++) {
        ListNode next = curr.Next;
        curr.Next = prev;
        prev = curr;
        curr = next;
    }

    // head is now the tail of reversed group — connect to recursively reversed rest
    head.Next = ReverseKGroup(curr, k);
    return prev;  // prev is new head of reversed group
}
// Time: O(n) | Space: O(n/k) recursion stack (one frame per group)
```

---

## Section 42 — Modified Binary Search

> **🧠 Mental Model: Binary Search with a Twist**
>
> Standard binary search requires a fully sorted array. Modified binary search applies when the array has STRUCTURE but not perfect sorting — rotated arrays (sorted then rotated), bitonic arrays (first increasing then decreasing), or finding the boundary between two conditions. The key question at each step: "which half has the property I need?" — based on comparing array values, not just index.

```csharp
// FIND MINIMUM IN ROTATED SORTED ARRAY
public int FindMin(int[] nums) {
    int left = 0, right = nums.Length - 1;
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] > nums[right])
            left = mid + 1;   // min is in right half (rotation happened here)
        else
            right = mid;      // min is in left half (including mid)
    }
    return nums[left];
}

// SEARCH IN BITONIC ARRAY (first ascending then descending)
int SearchBitonic(int[] arr, int target) {
    // Find peak index
    int left = 0, right = arr.Length - 1;
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] > arr[mid + 1]) right = mid;
        else left = mid + 1;
    }
    int peak = left;
    // Binary search on ascending part
    int result = BinarySearchAscending(arr, target, 0, peak);
    if (result != -1) return result;
    // Binary search on descending part
    return BinarySearchDescending(arr, target, peak + 1, arr.Length - 1);
}

// BINARY SEARCH ON CONDITION (generalized)
// Find leftmost index where condition(index) is true
// (assumes: false false ... false TRUE TRUE ... true)
int FirstTrue(int n, Func<int, bool> condition) {
    int left = 0, right = n - 1, result = -1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (condition(mid)) { result = mid; right = mid - 1; }
        else left = mid + 1;
    }
    return result;
}
```

### 🔴 Practice Problem: Find Minimum in Rotated Sorted Array (LeetCode #153 — Medium)

The `FindMin` method above is the complete solution.

```csharp
// Key insight: compare nums[mid] with nums[right] (NOT nums[left])
// If nums[mid] > nums[right]: minimum is in right half (nums[right] would be max otherwise)
// If nums[mid] <= nums[right]: minimum is in left half (including mid)
// Time: O(log n) | Space: O(1)
```

---

## Section 43 — Top K Elements & K-way Merge

> **🧠 Mental Model: Finding the K Fastest Runners**
>
> To find the k fastest runners from n competitors, you don't need to rank all n — just maintain a "tracking sheet" of the k fastest seen so far. When a new result comes in, if it's faster than the SLOWEST on the tracking sheet, swap it in. A min-heap of size k does this in O(log k) per element. K-way merge: merge k sorted lists using a heap — always extract the minimum, add from same list.

```csharp
// TOP K FREQUENT ELEMENTS
public int[] TopKFrequent(int[] nums, int k) {
    // Count frequencies
    var freq = new Dictionary<int, int>();
    foreach (int n in nums) freq[n] = freq.GetValueOrDefault(n, 0) + 1;

    // Min-heap of size k: keep k most frequent
    var minHeap = new PriorityQueue<int, int>();  // (element, frequency)
    foreach (var (num, count) in freq) {
        minHeap.Enqueue(num, count);
        if (minHeap.Count > k) minHeap.Dequeue();  // remove least frequent
    }

    return Enumerable.Range(0, k).Select(_ => minHeap.Dequeue()).ToArray();
}
// Time: O(n log k) | Space: O(n) for freq map + O(k) for heap

// K-WAY MERGE — merge k sorted arrays
int[] MergeKSorted(int[][] arrays) {
    // Min-heap stores (value, arrayIndex, elementIndex)
    var heap = new PriorityQueue<(int val, int arr, int idx), int>();
    var result = new List<int>();

    // Initialize heap with first element from each array
    for (int i = 0; i < arrays.Length; i++)
        if (arrays[i].Length > 0)
            heap.Enqueue((arrays[i][0], i, 0), arrays[i][0]);

    while (heap.Count > 0) {
        var (val, arr, idx) = heap.Dequeue();
        result.Add(val);
        // Add next element from same array
        if (idx + 1 < arrays[arr].Length)
            heap.Enqueue((arrays[arr][idx+1], arr, idx+1), arrays[arr][idx+1]);
    }
    return result.ToArray();
}
// Time: O(N log k) where N = total elements, k = number of arrays
```

### 🔴 Practice Problem: Top K Frequent Elements (LeetCode #347 — Medium)

The `TopKFrequent` method above is the complete solution.

> **🎯 Key Insight:** Min-heap of size k maintains the "top k" efficiently. Keep the MINIMUM of the top-k at the heap top — when a new element is larger than the min (should be in top-k), pop the min and push the new element. O(n log k) total, which beats sorting O(n log n) when k << n.

---

## Section 44 — Monotonic Stack & Queue

> **🧠 Mental Model: The Impatient Queue at the Bank**
>
> A monotonic stack maintains elements in increasing (or decreasing) order. When a new element arrives, all "weaker" elements (smaller for decreasing, larger for increasing) are evicted — they can never be the answer for future queries. Like an impatient queue: new VIP customer evicts all regular customers who arrived before them (they're "dominated"). Each element is pushed and popped at most once → O(n) total.

```csharp
// NEXT GREATER ELEMENT — monotonic decreasing stack
int[] NextGreaterElement(int[] arr) {
    int n = arr.Length;
    int[] result = new int[n];
    Array.Fill(result, -1);
    var stack = new Stack<int>();  // stores INDICES

    for (int i = 0; i < n; i++) {
        // Pop all elements smaller than current — their next greater is arr[i]
        while (stack.Count > 0 && arr[stack.Peek()] < arr[i]) {
            result[stack.Pop()] = arr[i];
        }
        stack.Push(i);
    }
    return result;
}

// LARGEST RECTANGLE IN HISTOGRAM
public int LargestRectangleArea(int[] heights) {
    var stack = new Stack<int>();  // stores indices, monotonic increasing heights
    int maxArea = 0;
    int n = heights.Length;

    for (int i = 0; i <= n; i++) {
        int h = (i == n) ? 0 : heights[i];  // sentinel 0 at end flushes remaining

        while (stack.Count > 0 && heights[stack.Peek()] > h) {
            int height = heights[stack.Pop()];
            int width = stack.Count == 0 ? i : i - stack.Peek() - 1;
            maxArea = Math.Max(maxArea, height * width);
        }
        stack.Push(i);
    }
    return maxArea;
}
// Time: O(n) — each element pushed and popped at most once
```

### 🔴 Practice Problem: Daily Temperatures (LeetCode #739 — Medium)

**Problem:** For each day, how many days until a warmer temperature? Return array of waits.

```csharp
public int[] DailyTemperatures(int[] temps) {
    int n = temps.Length;
    int[] result = new int[n];
    var stack = new Stack<int>();  // indices of days awaiting a warmer day

    for (int i = 0; i < n; i++) {
        // Found a warmer day for all days in stack with lower temp
        while (stack.Count > 0 && temps[stack.Peek()] < temps[i]) {
            int idx = stack.Pop();
            result[idx] = i - idx;  // days waited = current index - waiting index
        }
        stack.Push(i);
    }
    // Remaining in stack: no warmer day found → result stays 0 (default)
    return result;
}
// Time: O(n) | Space: O(n)
```

---

## Section 45 — Bit Manipulation

> **🧠 Mental Model: Light Switches**
>
> Bits are on/off light switches. XOR is the "toggle switch" — flipping a switch twice returns to original state. AND is "both must be on." OR is "at least one on." Left shift `<< 1` doubles the value (like adding a zero at the end in binary). Right shift `>> 1` halves it. The XOR trick: `a ^ a = 0` and `a ^ 0 = a` — XOR-ing a value with itself cancels out. XOR all numbers: duplicates cancel, leaving the unique one.

### Bit Operations Cheatsheet

```csharp
// FUNDAMENTALS
int a = 0b1010;  // binary literal = 10
a & b            // AND: 1 only if both 1
a | b            // OR: 1 if either 1
a ^ b            // XOR: 1 if different, 0 if same
~a               // NOT: flip all bits
a << n           // left shift: multiply by 2^n
a >> n           // right shift: divide by 2^n (arithmetic, preserves sign)
a >>> n          // unsigned right shift (C# 11+)

// COMMON TRICKS
n & 1            // check if odd (last bit is 1)
n & (n - 1)      // clear lowest set bit (if result==0: n is power of 2!)
n & (-n)         // isolate lowest set bit (used in Fenwick tree)
n ^ n == 0       // XOR with itself = 0
n ^ 0 == n       // XOR with 0 = unchanged

// SET/CLEAR/TOGGLE bit i
n |= (1 << i)    // set bit i
n &= ~(1 << i)   // clear bit i
n ^= (1 << i)    // toggle bit i
(n >> i) & 1     // check bit i

// COUNT SET BITS (Brian Kernighan's algorithm)
int CountBits(int n) {
    int count = 0;
    while (n != 0) { n &= (n - 1); count++; }  // clears lowest set bit each iteration
    return count;
}

// CHECK POWER OF 2
bool IsPowerOfTwo(int n) => n > 0 && (n & (n-1)) == 0;

// SWAP WITHOUT TEMP
a ^= b; b ^= a; a ^= b;  // a and b swapped (works but avoid — clarity matters)
```

### 🔴 Practice Problem: Single Number (LeetCode #136 — Easy)

**Problem:** Every element in array appears twice except one. Find that one.

```csharp
public int SingleNumber(int[] nums) {
    int result = 0;
    foreach (int n in nums)
        result ^= n;  // pairs cancel out (a^a=0), unique survives (0^a=a)
    return result;
}
// Time: O(n) | Space: O(1) — the most elegant bit trick!
// Example: [4,1,2,1,2] → 4^1^2^1^2 = 4^(1^1)^(2^2) = 4^0^0 = 4
```

---

## Section 46 — Subsets & Combinations

> **🧠 Mental Model: The Binary Choice Tree**
>
> Every subset problem has the same structure: for each element, you make a binary choice — INCLUDE it or EXCLUDE it. The recursion tree has 2^n leaves, one per subset. Combinations extend this with an ordering constraint (choose k from n without replacement). Backtracking with a "start index" prevents revisiting earlier elements and avoids duplicate combinations.

```csharp
// ALL SUBSETS — O(n × 2^n) time
IList<IList<int>> Subsets(int[] nums) {
    var result = new List<IList<int>>();
    void Backtrack(int start, List<int> current) {
        result.Add(new List<int>(current));  // add current subset (including empty)
        for (int i = start; i < nums.Length; i++) {
            current.Add(nums[i]);            // include nums[i]
            Backtrack(i + 1, current);       // explore subsets including nums[i]
            current.RemoveAt(current.Count - 1);  // exclude nums[i] (backtrack)
        }
    }
    Backtrack(0, new List<int>());
    return result;
}

// COMBINATIONS — choose k from n
IList<IList<int>> Combine(int n, int k) {
    var result = new List<IList<int>>();
    void Backtrack(int start, List<int> current) {
        if (current.Count == k) { result.Add(new List<int>(current)); return; }
        // Pruning: if not enough elements left to fill k, stop
        for (int i = start; i <= n - (k - current.Count) + 1; i++) {
            current.Add(i);
            Backtrack(i + 1, current);
            current.RemoveAt(current.Count - 1);
        }
    }
    Backtrack(1, new List<int>());
    return result;
}

// BFS APPROACH — generate subsets iteratively
IList<IList<int>> SubsetsBFS(int[] nums) {
    var result = new List<IList<int>> { new List<int>() };  // start with empty set
    foreach (int num in nums) {
        int size = result.Count;
        for (int i = 0; i < size; i++) {
            var newSubset = new List<int>(result[i]) { num };  // add num to existing
            result.Add(newSubset);
        }
    }
    return result;
}
```

### 🔴 Practice Problem: Subsets II (LeetCode #90 — Medium)

**Problem:** Array may contain duplicates. Return all unique subsets.

```csharp
public IList<IList<int>> SubsetsWithDup(int[] nums) {
    Array.Sort(nums);  // sort to group duplicates together
    var result = new List<IList<int>>();

    void Backtrack(int start, List<int> current) {
        result.Add(new List<int>(current));
        for (int i = start; i < nums.Length; i++) {
            // Skip duplicate elements at the same recursion level
            if (i > start && nums[i] == nums[i-1]) continue;
            current.Add(nums[i]);
            Backtrack(i + 1, current);
            current.RemoveAt(current.Count - 1);
        }
    }

    Backtrack(0, new List<int>());
    return result;
}
// Time: O(n × 2^n) | Space: O(n) recursion depth
// Key: sort first, then skip duplicates with `i > start && nums[i] == nums[i-1]`
```

---

## Section 47 — Math & Number Theory

> **🧠 Mental Model: Ancient Greek Mathematical Tools**
>
> Number theory gives us elegant shortcuts: Sieve of Eratosthenes eliminates composite numbers like a sieve eliminates small rocks. GCD (Euclid's algorithm) divides by remainders until zero — incredibly efficient. Modular arithmetic keeps numbers from overflowing in combinatorics problems.

```csharp
// SIEVE OF ERATOSTHENES — find all primes up to n in O(n log log n)
bool[] SievePrimes(int n) {
    bool[] isPrime = new bool[n + 1];
    Array.Fill(isPrime, true);
    isPrime[0] = isPrime[1] = false;

    for (int i = 2; i * i <= n; i++) {
        if (isPrime[i]) {
            // Mark all multiples of i as composite
            for (int j = i * i; j <= n; j += i)
                isPrime[j] = false;
        }
    }
    return isPrime;  // isPrime[i] = true means i is prime
}

// GCD — Euclidean algorithm O(log(min(a,b)))
int Gcd(int a, int b) => b == 0 ? a : Gcd(b, a % b);
int Lcm(int a, int b) => a / Gcd(a, b) * b;  // avoid overflow: divide first

// FAST POWER (modular exponentiation)
long PowerMod(long base, long exp, long mod) {
    long result = 1;
    base %= mod;
    while (exp > 0) {
        if ((exp & 1) == 1) result = result * base % mod;  // odd exponent
        base = base * base % mod;                          // square the base
        exp >>= 1;                                          // halve the exponent
    }
    return result;
}
// Time: O(log exp) | Space: O(1)

// COMBINATIONS (n choose k) with modular arithmetic
long nCk(int n, int k, long mod = 1_000_000_007L) {
    if (k > n) return 0;
    long[] fact = new long[n + 1];
    fact[0] = 1;
    for (int i = 1; i <= n; i++) fact[i] = fact[i-1] * i % mod;

    long inv_k = PowerMod(fact[k], mod - 2, mod);     // Fermat's little theorem
    long inv_nk = PowerMod(fact[n-k], mod - 2, mod);
    return fact[n] * inv_k % mod * inv_nk % mod;
}
```

### 🔴 Practice Problem: Count Primes (LeetCode #204 — Medium)

**Problem:** Count all primes less than n.

```csharp
public int CountPrimes(int n) {
    if (n < 2) return 0;
    bool[] notPrime = new bool[n];  // notPrime[i] = true means composite

    for (int i = 2; (long)i * i < n; i++) {  // cast to long to prevent i*i overflow
        if (!notPrime[i]) {
            for (int j = i * i; j < n; j += i)
                notPrime[j] = true;
        }
    }

    int count = 0;
    for (int i = 2; i < n; i++)
        if (!notPrime[i]) count++;
    return count;
}
// Time: O(n log log n) — sieve complexity | Space: O(n)
```

---

# PART 10 — STRING ALGORITHMS

---

## Section 48 — String Patterns

> **🧠 Mental Model: The Fingerprint Approach**
>
> Many string problems need a "fingerprint" — a compact representation that identifies a string's properties without comparing character by character. Sorted characters are the fingerprint for anagrams. Frequency arrays are the fingerprint for character counts. Rolling hash is a fingerprint that can SLIDE along the string in O(1) per step — enabling O(n) pattern matching.

### Anagram & Palindrome Patterns

```csharp
// CHECK ANAGRAM — same character frequencies
bool IsAnagram(string s, string t) {
    if (s.Length != t.Length) return false;
    int[] count = new int[26];
    foreach (char c in s) count[c - 'a']++;
    foreach (char c in t) count[c - 'a']--;
    return count.All(x => x == 0);
}

// PALINDROME CHECK — two pointer
bool IsPalindrome(string s) {
    int l = 0, r = s.Length - 1;
    while (l < r) { if (s[l++] != s[r--]) return false; }
    return true;
}

// VALID PALINDROME II (can delete at most 1 char)
bool ValidPalindrome(string s) {
    int l = 0, r = s.Length - 1;
    while (l < r) {
        if (s[l] != s[r])
            return IsPalindromeRange(s, l+1, r) || IsPalindromeRange(s, l, r-1);
        l++; r--;
    }
    return true;
}
bool IsPalindromeRange(string s, int l, int r) {
    while (l < r) { if (s[l++] != s[r--]) return false; }
    return true;
}

// ROLLING HASH — check if substring is anagram of pattern (O(n) sliding window)
IList<int> FindAnagrams(string s, string p) {
    var result = new List<int>();
    if (s.Length < p.Length) return result;

    int[] pCount = new int[26], wCount = new int[26];
    for (int i = 0; i < p.Length; i++) { pCount[p[i]-'a']++; wCount[s[i]-'a']++; }

    if (pCount.SequenceEqual(wCount)) result.Add(0);

    for (int i = p.Length; i < s.Length; i++) {
        wCount[s[i] - 'a']++;                    // add right
        wCount[s[i - p.Length] - 'a']--;         // remove left
        if (pCount.SequenceEqual(wCount)) result.Add(i - p.Length + 1);
    }
    return result;
}
// Time: O(n × 26) = O(n) since alphabet is constant | Space: O(1) for fixed-size arrays
```

### 🔴 Practice Problem: Minimum Window Substring (LeetCode #76 — Hard)

**Problem:** Find minimum window in string s that contains all characters of string t.

```csharp
public string MinWindow(string s, string t) {
    if (s.Length < t.Length) return "";

    int[] need = new int[128];   // how many of each char we still need
    foreach (char c in t) need[c]++;
    int required = t.Length;     // total characters still needed

    int left = 0, minStart = 0, minLen = int.MaxValue;

    for (int right = 0; right < s.Length; right++) {
        // Add right character to window
        if (need[s[right]] > 0) required--;  // satisfied one requirement
        need[s[right]]--;

        // Shrink from left while window is valid
        while (required == 0) {
            if (right - left + 1 < minLen) {
                minLen = right - left + 1;
                minStart = left;
            }
            need[s[left]]++;
            if (need[s[left]] > 0) required++;  // removing this char breaks requirement
            left++;
        }
    }
    return minLen == int.MaxValue ? "" : s.Substring(minStart, minLen);
}
// Time: O(|s| + |t|) | Space: O(1) — fixed-size array for ASCII
```

---

## Section 49 — Advanced String Matching

> **🧠 Mental Model: The Smart Bookmark**
>
> Naive string matching (check pattern at every position): O(n × m). KMP uses a "failure function" — when a mismatch occurs, instead of restarting from scratch, it consults the failure function to know how far BACK to backtrack in the pattern (not the text). The text pointer never moves backward — O(n + m) total. Rabin-Karp uses rolling hash: slide the hash window O(1) per step, only verify character-by-character on hash collision.

### KMP Algorithm

```csharp
// KMP — O(n + m) string search
public int StrStr(string haystack, string needle) {
    if (needle.Length == 0) return 0;
    int[] lps = BuildLPS(needle);  // longest proper prefix = suffix

    int i = 0  // haystack index
      , j = 0; // needle index
    while (i < haystack.Length) {
        if (haystack[i] == needle[j]) {
            i++; j++;
            if (j == needle.Length) return i - j;  // found!
        } else if (j > 0) {
            j = lps[j - 1];  // DON'T advance i — jump j using failure function
        } else {
            i++;  // mismatch at j=0, advance i
        }
    }
    return -1;
}

// BUILD LPS (Longest Proper Prefix that is also Suffix) table
int[] BuildLPS(string pattern) {
    int[] lps = new int[pattern.Length];
    int len = 0, i = 1;
    while (i < pattern.Length) {
        if (pattern[i] == pattern[len]) {
            lps[i++] = ++len;
        } else if (len > 0) {
            len = lps[len - 1];  // fallback using previously computed lps
        } else {
            lps[i++] = 0;
        }
    }
    return lps;
}
// Time: O(n + m) | Space: O(m) for LPS table

// RABIN-KARP — rolling hash O(n + m) avg, O(nm) worst (hash collisions)
int RabinKarp(string text, string pattern) {
    int n = text.Length, m = pattern.Length;
    if (n < m) return -1;

    long mod = 1_000_000_007L, base_val = 31;
    long patHash = 0, textHash = 0, power = 1;

    for (int i = 0; i < m; i++) {
        patHash = (patHash * base_val + (pattern[i] - 'a' + 1)) % mod;
        textHash = (textHash * base_val + (text[i] - 'a' + 1)) % mod;
        if (i > 0) power = power * base_val % mod;
    }

    for (int i = 0; i <= n - m; i++) {
        if (patHash == textHash) {
            if (text.Substring(i, m) == pattern) return i;  // verify (avoid false positive)
        }
        if (i < n - m) {
            textHash = (textHash - (text[i] - 'a' + 1) * power % mod + mod) % mod;
            textHash = (textHash * base_val + (text[i + m] - 'a' + 1)) % mod;
        }
    }
    return -1;
}
```

### 🔴 Practice Problem: Find Index of First Occurrence (LeetCode #28 — Easy)

```csharp
public int StrStr(string haystack, string needle) {
    // Use the KMP implementation above
    return KmpSearch(haystack, needle);
}
// Or simply: return haystack.IndexOf(needle); — but KMP shows you know the algorithm!
```

> **🎯 Key Insight:** In interviews, implementing KMP demonstrates mastery of string algorithms. The key insight: the LPS table precomputes "if mismatch at pattern[j], how far back can we jump in the pattern without missing any potential match?" — avoiding redundant comparisons in the text string.

---

# PART 11 — INTERVIEW REFERENCE

---

## Section 50 — Product Company Cheat Sheet & Interview Guide

---

### BIG O COMPLEXITY REFERENCE CARD

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMPLETE COMPLEXITY REFERENCE                            │
├─────────────────┬──────────────┬──────────────────────────────────────────┤
│  Data Structure │  Operations  │  Time Complexity                         │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  Array          │  Access      │  O(1)                                    │
│                 │  Search      │  O(n) unsorted / O(log n) sorted        │
│                 │  Insert/Del  │  O(n) shift                             │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  LinkedList     │  Access      │  O(n)                                   │
│                 │  Search      │  O(n)                                   │
│                 │  Insert/Del  │  O(1) at known node                    │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  Stack/Queue    │  Push/Pop    │  O(1)                                   │
│                 │  Peek        │  O(1)                                   │
│                 │  Search      │  O(n)                                   │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  HashMap        │  Get/Put     │  O(1) avg / O(n) worst                 │
│  HashSet        │  Contains    │  O(1) avg / O(n) worst                 │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  BST (balanced) │  Search      │  O(log n)                               │
│                 │  Insert/Del  │  O(log n)                               │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  Heap           │  Push/Pop    │  O(log n)                               │
│                 │  Peek        │  O(1)                                   │
│                 │  Build       │  O(n)                                   │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  Trie           │  Insert/Find │  O(L) — word length                    │
├─────────────────┼──────────────┼──────────────────────────────────────────┤
│  Graph (V,E)    │  DFS/BFS     │  O(V + E)                               │
│                 │  Dijkstra    │  O((V+E) log V)                         │
│                 │  Bellman-Ford│  O(V × E)                               │
│                 │  Floyd-W     │  O(V³)                                  │
└─────────────────┴──────────────┴──────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                      SORTING COMPLEXITY REFERENCE                          │
├──────────────┬──────────────┬──────────────┬──────────────┬───────────────┤
│  Algorithm   │  Best        │  Average     │  Worst       │  Space/Stable │
├──────────────┼──────────────┼──────────────┼──────────────┼───────────────┤
│  Bubble      │  O(n)        │  O(n²)       │  O(n²)       │  O(1) / Yes  │
│  Selection   │  O(n²)       │  O(n²)       │  O(n²)       │  O(1) / No   │
│  Insertion   │  O(n)        │  O(n²)       │  O(n²)       │  O(1) / Yes  │
│  Merge       │  O(n log n)  │  O(n log n)  │  O(n log n)  │  O(n) / Yes  │
│  Quick       │  O(n log n)  │  O(n log n)  │  O(n²)       │  O(log n)/No │
│  Heap        │  O(n log n)  │  O(n log n)  │  O(n log n)  │  O(1) / No   │
│  Counting    │  O(n+k)      │  O(n+k)      │  O(n+k)      │  O(k) / Yes  │
│  Radix       │  O(nk)       │  O(nk)       │  O(nk)       │  O(n+k)/Yes  │
└──────────────┴──────────────┴──────────────┴──────────────┴───────────────┘
```

---

## Coding Problem-Solving Approach (Non-DSA)

### Framework: UCCEE Method

**1. UNDERSTAND the Problem**
- Read the problem twice
- Identify inputs and outputs
- Ask clarifying questions
- Understand constraints

Example questions:
- "What's the expected input format?"
- "Should I handle null inputs?"
- "What's the expected behavior for edge cases?"
- "Are there performance requirements?"

**2. CLARIFY Requirements**
- Functional requirements
- Non-functional requirements (performance, security)
- Edge cases and error handling

**3. COMMUNICATE Your Approach**
- Explain your solution before coding
- Discuss trade-offs
- Mention alternatives

**4. EXECUTE with Quality Code**
- Write clean, readable code
- Use meaningful variable names
- Follow SOLID principles
- Add comments for complex logic

**5. EVALUATE and Test**
- Walk through your code
- Test with sample inputs
- Consider edge cases
- Discuss improvements

### UMPIRE CHECKLIST (Print this for every interview)

```
□  U — UNDERSTAND
   □ Restate the problem in your own words
   □ Identify input/output types, constraints, edge cases
   □ Ask: sorted? duplicates? null? empty? negative? size?

□  M — MATCH
   □ What data structure matches? (array→pointers, LL→fast/slow, tree→DFS/BFS)
   □ What pattern matches? (optimal→DP/greedy, all combos→backtrack, K elements→heap)

□  P — PLAN
   □ Write 3–5 lines of pseudocode BEFORE coding
   □ Identify any tricky sub-problems
   □ Estimate time/space complexity of your plan

□  I — IMPLEMENT
   □ Code the solution cleanly
   □ Handle edge cases at the top
   □ Use descriptive variable names
   □ Use int.MaxValue/2 for infinity (avoids overflow)

□  R — REVIEW
   □ Trace through with simplest non-trivial example
   □ Test edge cases: empty, single element, all same, negative
   □ Check for off-by-one errors (< vs <=, length vs length-1)

□  E — EVALUATE
   □ State time complexity with justification
   □ State space complexity (include recursion stack!)
   □ Discuss trade-offs and alternative approaches
```

---

### PATTERN RECOGNITION QUICK GUIDE

```
Problem says...                      Use...
────────────────────────────────────────────────────────────────
"sorted array + find target"       → Binary Search
"sorted array + pair/triplet sum"  → Two Pointers
"subarray/substring max/min"       → Sliding Window
"linked list cycle/middle"         → Fast & Slow Pointers
"overlapping intervals"            → Merge Intervals (sort by start)
"numbers 1 to n, missing/dupe"     → Cyclic Sort
"reverse linked list"              → In-place Reversal
"level-by-level tree"              → BFS (Queue)
"tree path/depth"                  → DFS (recursion)
"all combinations/subsets"         → Backtracking
"top K / K largest / K smallest"   → Heap (size K)
"K sorted lists/streams"           → K-way Merge (heap)
"dependencies, order of tasks"     → Topological Sort
"optimal value exists"             → DP or Greedy
"count/frequency lookup"           → HashMap
"membership test O(1)"             → HashSet
"prefix/autocomplete"              → Trie
"connectivity of nodes"            → Union-Find
"next greater/smaller element"     → Monotonic Stack
"only 2 different values in array" → Bit manipulation (XOR)
"max sum contiguous subarray"      → Kadane's (DP/Greedy)
```

---

### FAANG COMPANY FOCUS AREAS

```
┌────────────┬─────────────────────────────────────────────────────────────┐
│  Company   │  Primary DSA Focus                                         │
├────────────┼─────────────────────────────────────────────────────────────┤
│  Google    │  Graphs, DP, String algorithms, Math, Advanced data structs │
│            │  Expect: BFS/DFS, shortest path, substring matching        │
├────────────┼─────────────────────────────────────────────────────────────┤
│  Amazon    │  Arrays, Trees, OOP + DSA combined, System design          │
│            │  Expect: sliding window, tree traversals, design patterns  │
├────────────┼─────────────────────────────────────────────────────────────┤
│  Microsoft │  Trees, Linked Lists, DP, Recursion, System design        │
│            │  Expect: BST operations, LCA, DP on trees                 │
├────────────┼─────────────────────────────────────────────────────────────┤
│  Meta (FB) │  Graphs (social network), Arrays, String manipulation      │
│            │  Expect: BFS, two pointers, sliding window                │
├────────────┼─────────────────────────────────────────────────────────────┤
│  Apple     │  Arrays, Strings, Optimization, Low-level efficiency       │
│            │  Expect: in-place algorithms, space optimization           │
└────────────┴─────────────────────────────────────────────────────────────┘
```

---

### TOP 20 MUST-KNOW PROBLEMS (With Approach)

| # | Problem | LeetCode | Pattern | Key Insight |
|---|---------|----------|---------|-------------|
| 1 | Two Sum | 1 | HashMap | complement = target - num |
| 2 | Best Time to Buy/Sell | 121 | Greedy | track min price so far |
| 3 | Valid Parentheses | 20 | Stack | push open, match close |
| 4 | Merge Intervals | 56 | Sort + Greedy | sort by start, merge overlaps |
| 5 | Reverse Linked List | 206 | In-place reversal | prev/curr/next 3 pointers |
| 6 | Max Depth Binary Tree | 104 | Tree DFS | 1 + max(left, right) |
| 7 | Level Order Traversal | 102 | BFS | snapshot queue.Count per level |
| 8 | Climbing Stairs | 70 | DP | dp[n] = dp[n-1] + dp[n-2] |
| 9 | Coin Change | 322 | DP tabulation | dp[i] = min(dp[i-coin]+1) |
| 10 | Number of Islands | 200 | DFS/BFS | sink visited land |
| 11 | Longest Substring No Repeat | 3 | Sliding Window | shrink on duplicate |
| 12 | Validate BST | 98 | Tree DFS | pass (min,max) range |
| 13 | Search Rotated Array | 33 | Binary Search | identify sorted half |
| 14 | 3Sum | 15 | Two Pointers | sort + fix one + two pointers |
| 15 | Kth Largest | 215 | Heap | min-heap size k |
| 16 | Course Schedule | 207 | Graph DFS | 3-state cycle detection |
| 17 | Word Search | 79 | Backtracking | DFS + visited marking |
| 18 | LCS | 1143 | 2D DP | dp[i][j] = match or max skip |
| 19 | Implement Trie | 208 | Trie | children[26] + IsEnd |
| 20 | Median of Stream | 295 | Two Heaps | max-heap left + min-heap right |

---

### C# GOTCHAS IN INTERVIEWS

```csharp
// 1. INTEGER OVERFLOW
int mid = (left + right) / 2;      // ❌ overflows if both large
int mid = left + (right - left) / 2; // ✅ safe

// 2. NULL REFERENCE
node.Next.Val      // ❌ crashes if Next is null
node?.Next?.Val    // ✅ null-conditional

// 3. OFF-BY-ONE — most common bug
arr[arr.Length]     // ❌ IndexOutOfRange
arr[arr.Length - 1] // ✅ last element

// 4. STRING CONCATENATION IN LOOP
string s = "";
for (int i = 0; i < n; i++) s += chars[i];  // ❌ O(n²)
var sb = new StringBuilder();
for (int i = 0; i < n; i++) sb.Append(chars[i]); // ✅ O(n)

// 5. DICTIONARY ACCESS
dict[key]                    // ❌ throws KeyNotFoundException
dict.TryGetValue(key, out v) // ✅ safe

// 6. MODIFYING WHILE ITERATING
foreach (var item in list) list.Remove(item); // ❌ InvalidOperationException
for (int i = list.Count-1; i >= 0; i--)       // ✅ iterate backwards

// 7. SHALLOW VS DEEP COPY
int[] copy = arr;           // ❌ same reference!
int[] copy = (int[])arr.Clone(); // ✅ shallow copy (fine for primitives)

// 8. INT.MAXVALUE ADDITION OVERFLOW
int dist = int.MaxValue;
dist + weight;              // ❌ overflows to negative!
int.MaxValue / 2 + weight;  // ✅ safe

// 9. NEGATIVE MODULO
(-7) % 3 = -1               // in C# — can be negative!
(((-7) % 3) + 3) % 3 = 2   // ✅ always positive result

// 10. LINQ DEFERRED EXECUTION
var q = list.Where(x => x > 0);  // not executed yet!
var r = q.ToList();               // ← executed here; always materialize
```

---

### STUDY PLAN — 12 WEEKS TO PRODUCT COMPANY READINESS

```
WEEKS 1–2: FOUNDATIONS (Sections 1–4, 10–11)
  □ Master UMPIRE framework — apply to every practice problem
  □ Arrays, Strings, HashMap, HashSet — cold
  □ Big O analysis — justify every solution
  □ Daily: 2 easy problems on LeetCode

WEEKS 3–4: LINEAR STRUCTURES (Sections 5–9)
  □ Linked Lists — implement from scratch, reverse, detect cycle
  □ Stacks & Queues — monotonic stack, BFS template
  □ Two Pointers & Sliding Window patterns
  □ Daily: 1 easy + 1 medium problem

WEEKS 5–6: TREES & GRAPHS (Sections 12–21)
  □ All 4 tree traversals — recursive AND iterative
  □ BST operations — insert, delete, validate
  □ DFS + BFS on graphs — both iterative and recursive
  □ Dijkstra's algorithm — implement from scratch
  □ Daily: 2 medium problems

WEEKS 7–8: DYNAMIC PROGRAMMING (Sections 32–35)
  □ Fibonacci → climbing stairs → coin change progression
  □ LCS, LIS, edit distance — build DP table by hand
  □ Backtracking: subsets, permutations, N-Queens
  □ Daily: 2 medium + 1 hard

WEEKS 9–10: PATTERNS (Sections 36–47)
  □ All 12 patterns — one day each, 2 problems per pattern
  □ Heaps, Union-Find, Trie — implement from scratch
  □ Bit manipulation tricks — memorize XOR properties
  □ Daily: 3 medium problems

WEEKS 11–12: MOCK INTERVIEWS & HARD PROBLEMS
  □ LeetCode hard problems — 1 per day
  □ Timed mock interviews (45 min, no hints)
  □ Review Section 50 cheat sheet weekly
  □ System design + DSA combination problems
  □ Company-specific practice (see FAANG focus areas)

THROUGHOUT:
  □ Explain every solution out loud (rubber duck method)
  □ After solving: look at top solutions for alternative approaches
  □ Track personal weak areas — revisit those sections
  □ Aim for: 100 unique problems solved before any interview
```

---

### MEDIAN OF DATA STREAM (Two Heaps Pattern — Bonus)

> This classic problem uses TWO HEAPS and is asked by every major company.

```csharp
// MEDIAN FINDER — LeetCode #295 — Hard
// Mental model: two piles of sorted numbers split at median
// Left pile (max-heap): smaller half | Right pile (min-heap): larger half
// Invariant: |left| - |right| ∈ {0, 1} (left can have at most 1 extra)

public class MedianFinder {
    private PriorityQueue<int,int> _left  = new(); // max-heap (negate priority)
    private PriorityQueue<int,int> _right = new(); // min-heap

    public void AddNum(int num) {
        // Always add to left first
        _left.Enqueue(num, -num);  // negate for max-heap behavior

        // Balance: right's min must be >= left's max
        if (_right.Count > 0 && _left.Peek() > _right.Peek()) {
            int top = _left.Dequeue();
            _right.Enqueue(top, top);
        }

        // Rebalance sizes: left can have at most 1 more than right
        if (_left.Count > _right.Count + 1) {
            int top = _left.Dequeue();
            _right.Enqueue(top, top);
        } else if (_right.Count > _left.Count) {
            int top = _right.Dequeue();
            _left.Enqueue(top, -top);
        }
    }

    public double FindMedian() {
        if (_left.Count > _right.Count) return _left.Peek();
        return (_left.Peek() + (double)_right.Peek()) / 2.0;
    }
}
// Time: O(log n) per AddNum, O(1) FindMedian | Space: O(n)
```

---

> **🎯 Final Key Insight: The Meta-Pattern**
>
> After solving hundreds of problems, you'll notice: most HARD problems are just MEDIUM patterns applied in clever combinations. A hard graph problem = BFS + heap + state compression. A hard DP problem = 2D DP + binary search optimization. The path from intermediate to expert is not learning new patterns — it's recognizing how to COMBINE and ADAPT the patterns you already know. Practice with intention: after each problem, ask "what PATTERN is this?" and "how would I recognize this pattern in a new problem?"

---

*DSA Complete Study Guide — C# Edition*
*Sections 1–50 · Parts 1–11 · 50 Practice Problems · FAANG Ready*

