# DSA — Complete Study Guide
### C# Edition · Beginner → FAANG Expert · Mental Models · Diagrams · Brute→Optimal · Practice

> **How to use this guide**
> - **Beginner**: Read Parts 1–3 linearly, do every practice problem before reading the solution
> - **Intermediate**: Jump to Part 9 (Patterns), then revisit weak topic sections
> - **Interview prep**: Start with Section 50 (cheat sheet), identify gaps, fill them
> - **Each section**: Mental Model → Visual Diagram → Concept → Code (with WHY comments) → Approach Evolution → Trace → Complexity → Practice
> - **Every practice problem** shows: 🔴 Brute Force → 🟡 Better → 🟢 Optimal evolution

---

## 18-HOUR SPRINT PLAN — Maximum ROI for Interview Prep

> **Context**: 18 hours is enough to cover the 80% of topics that appear in 95% of interviews.
> Skip the advanced theory. Focus on patterns, code fluency, and the 25 must-solve problems.

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║                    18-HOUR DSA INTERVIEW SPRINT                                 ║
║                                                                                 ║
║   PHASE 1 — FOUNDATIONS        (3 hrs)   Hours  1– 3                           ║
║   PHASE 2 — ARRAYS & HASHING   (3 hrs)   Hours  4– 6                           ║
║   PHASE 3 — TREES & SEARCH     (3 hrs)   Hours  7– 9                           ║
║   PHASE 4 — LINKED LIST/STACK  (2 hrs)   Hours 10–11                           ║
║   PHASE 5 — DYNAMIC PROGRAMMING(3 hrs)   Hours 12–14                           ║
║   PHASE 6 — HEAP + GRAPH BFS   (2 hrs)   Hours 15–16                           ║
║   PHASE 7 — BACKTRACK + MONO   (1 hr)    Hour  17                              ║
║   PHASE 8 — FULL REVIEW        (1 hr)    Hour  18                              ║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

### Session-by-Session Breakdown

| Hour | Phase | Sections | What to DO | Skip |
|------|-------|----------|-----------|------|
| 1 | Foundations | §1 UMPIRE, §2 Big O | Read UMPIRE framework. Memorize Big O for each DS. Write complexity table from memory. | §3 Amortized analysis |
| 2 | Foundations | §4 14 Patterns | Read all 14 pattern names + when to use. Build your own "pattern → trigger word" flashcard. | Deep examples — come back after practice |
| 3 | Foundations | §36 Two Pointers, §37 Sliding Window | Code 2 two-pointer problems. Code 2 sliding window problems. These two patterns alone solve ~35% of array questions. | §40 Cyclic Sort |
| 4 | Arrays | §5 Arrays, §6 Strings | Read arrays. Code: Two Sum, Best Time to Buy Stock, Product of Array Except Self. | §28 Interpolation Search |
| 5 | Hashing | §10 HashMap, §11 HashSet | Code: Group Anagrams, Top K Frequent, Longest Consecutive Sequence. HashMap is the #1 tool for O(n) solutions. | — |
| 6 | Binary Search | §27 Binary Search, §42 Modified BS | Code: Search in Rotated Array, Find Min in Rotated, Koko Eating Bananas. Binary search on answer space is high-frequency. | §26 Linear Search, §28 Exp Search |
| 7 | Trees | §12 Binary Trees, §13 BST | Read tree traversals (inorder/preorder/postorder). Code: Max Depth, Invert Tree, LCA, Validate BST. | §15 Tries, §16 Advanced Trees |
| 8 | Trees | §18 BFS/DFS on Trees | Code: Level Order Traversal, Right Side View, Binary Tree Zigzag. BFS = queue; DFS = stack/recursion. | §20 MST, §21 Union-Find |
| 9 | Graphs | §17 Graph Fundamentals, §18 Graph BFS/DFS | Code: Number of Islands, Clone Graph, Course Schedule (cycle detection). Adjacency list pattern only. | §19 Dijkstra (unless asked), §20 MST |
| 10 | Linked Lists | §7 Linked Lists, §38 Fast/Slow Pointers | Code: Reverse Linked List, Merge Two Sorted, Linked List Cycle (Floyd's). | §41 In-place LL Reversal (advanced) |
| 11 | Stack/Queue | §8 Stacks, §9 Queues, §44 Monotonic Stack | Code: Valid Parentheses, Min Stack, Daily Temperatures (monotonic). | §9 Deques deep dive |
| 12 | DP Basics | §29 Recursion, §32 DP Memoization | Read memoization template. Code: Fibonacci, Climbing Stairs, House Robber. Understand "subproblem overlap" instinct. | §31 Divide & Conquer |
| 13 | DP Core | §33 DP Tabulation, §34 Classic DP | Code: 0/1 Knapsack, Longest Common Subsequence, Coin Change. Bottom-up table pattern. | §35 Greedy (skim only) |
| 14 | DP Advanced | §34 Classic DP (continued) | Code: Longest Increasing Subsequence, Word Break, Unique Paths. Recognize "2D DP table" problems. | — |
| 15 | Heap | §14 Heaps, §43 Top K Elements | Code: Kth Largest Element, Top K Frequent (heap version), Merge K Sorted Lists. Learn `PriorityQueue<T>` C# API cold. | §43 K-way Merge (advanced) |
| 16 | Backtracking | §30 Backtracking | Code: Subsets, Permutations, Combination Sum, Word Search. One template covers all 4. | §46 Subsets deep theory |
| 17 | Bit + Math | §45 Bit Manipulation, §47 Math | Code: Single Number (XOR), Missing Number, Power of Two. 20-min cap — skip if weak, not always asked. | Deep number theory |
| 18 | Full Review | §50 Cheat Sheet | Read entire Section 50 cheat sheet. Re-solve 5 problems you got wrong. Review complexity table. Simulate 1 timed problem (45 min). | — |

---

### What to SKIP Entirely in 18 Hours

```
╔═══════════════════════════════════════════════════════════╗
║  SKIP — Low frequency, high complexity, poor ROI          ║
╠═══════════════════════════════════════════════════════════╣
║  §3   Amortized Analysis (understand concept only)        ║
║  §15  Tries (skip unless company is known to ask)         ║
║  §16  AVL / Segment Trees / Fenwick Trees                 ║
║  §19  Dijkstra / Bellman-Ford (skim if graph is focus)    ║
║  §20  Minimum Spanning Trees (Prim's / Kruskal's)         ║
║  §21  Union-Find (read only if you have extra time)       ║
║  §22  Bubble/Insertion/Selection Sort (know O(n²), skip)  ║
║  §24  Counting/Radix/Bucket Sort                          ║
║  §26  Linear Search variants                              ║
║  §28  Interpolation / Exponential Search                  ║
║  §31  Divide & Conquer (Merge Sort suffices)              ║
║  §35  Greedy (skim Activity Selection only)               ║
║  §40  Cyclic Sort (niche, rarely asked)                   ║
║  §47  Number Theory deep (GCD ok, rest skip)              ║
║  §49  KMP / Rabin-Karp (only if string-focused role)      ║
╚═══════════════════════════════════════════════════════════╝
```

---

### 🔥 25 Must-Solve Problems — Cover These Before Anything Else
> Problems marked **🔥 MUST SOLVE** throughout this guide correspond to this list.
> Scan any section — if you see 🔥, do not skip it.

| # | Problem | Pattern | Section | Difficulty |
|---|---------|---------|---------|-----------|
| 1 | Two Sum | HashMap | §10 | Easy |
| 2 | Best Time to Buy/Sell Stock | Sliding Window | §37 | Easy |
| 3 | Contains Duplicate | HashSet | §11 | Easy |
| 4 | Valid Parentheses | Stack | §8 | Easy |
| 5 | Reverse Linked List | Linked List | §7 | Easy |
| 6 | Maximum Depth of Binary Tree | DFS/Recursion | §12 | Easy |
| 7 | Climbing Stairs | DP Memoization | §32 | Easy |
| 8 | Merge Two Sorted Lists | Two Pointers | §36 | Easy |
| 9 | Binary Search | Binary Search | §27 | Easy |
| 10 | Invert Binary Tree | DFS | §12 | Easy |
| 11 | Longest Substring Without Repeating | Sliding Window | §37 | Medium |
| 12 | Group Anagrams | HashMap | §10 | Medium |
| 13 | Search in Rotated Sorted Array | Modified Binary Search | §42 | Medium |
| 14 | 3Sum | Two Pointers | §36 | Medium |
| 15 | Number of Islands | BFS/DFS Graph | §18 | Medium |
| 16 | Clone Graph | BFS/DFS | §18 | Medium |
| 17 | Course Schedule (Cycle Detection) | Graph DFS | §18 | Medium |
| 18 | Coin Change | DP Tabulation | §33 | Medium |
| 19 | Longest Common Subsequence | 2D DP | §34 | Medium |
| 20 | House Robber | DP | §34 | Medium |
| 21 | Kth Largest Element | Heap | §43 | Medium |
| 22 | Combination Sum | Backtracking | §30 | Medium |
| 23 | Daily Temperatures | Monotonic Stack | §44 | Medium |
| 24 | Word Break | DP | §34 | Medium |
| 25 | Merge K Sorted Lists | Heap / K-way | §43 | Hard |

---

### Pattern → Trigger Word Cheat Sheet (Memorize This)

```
IF problem says...                          THINK...
─────────────────────────────────────────────────────────────────
"sorted array, find pair/triplet"       →   Two Pointers
"substring / subarray of size k"        →   Sliding Window
"find if cycle exists"                  →   Fast & Slow Pointers (Floyd's)
"overlapping intervals"                 →   Merge Intervals
"top K / K largest / K most frequent"  →   Heap (PriorityQueue)
"all subsets / all permutations"        →   Backtracking
"find path in tree / graph"             →   DFS (recursion/stack)
"shortest path / level-by-level"        →   BFS (queue)
"in sorted array, search/find"          →   Binary Search
"optimal value over subproblems"        →   Dynamic Programming
"count frequency / check existence"    →   HashMap / HashSet
"next greater / previous smaller"       →   Monotonic Stack
"missing number / duplicate"            →   Bit Manipulation (XOR)
"string rearrangement / anagram"        →   Sorting + HashMap
─────────────────────────────────────────────────────────────────
```

---

### Time Budget per Day (if 18 hrs = 3 days × 6 hrs)

```
DAY 1 (6 hrs) — Hours 1–6
  ├─ Hour 1–2: Foundations (UMPIRE, Big O, 14 Patterns)
  ├─ Hour 3:   Two Pointers + Sliding Window
  ├─ Hour 4:   Arrays + Strings (code 3 problems)
  ├─ Hour 5:   HashMap + HashSet (code 3 problems)
  └─ Hour 6:   Binary Search (code 3 problems)

DAY 2 (6 hrs) — Hours 7–12
  ├─ Hour 7–8: Binary Trees (DFS/BFS, code 5 problems)
  ├─ Hour 9:   Graphs (Islands, Course Schedule)
  ├─ Hour 10:  Linked Lists (Reverse, Cycle, Merge)
  ├─ Hour 11:  Stack/Queue/Monotonic Stack
  └─ Hour 12:  DP Foundations (Memoization + Fibonacci/Stairs)

DAY 3 (6 hrs) — Hours 13–18
  ├─ Hour 13–14: DP Core (Tabulation, Knapsack, LCS, Coin Change)
  ├─ Hour 15:    Heap / Top K (code 3 problems)
  ├─ Hour 16:    Backtracking (Subsets, Permutations, Combo Sum)
  ├─ Hour 17:    Bit Manipulation (XOR tricks, 20 min max)
  └─ Hour 18:    Full review — Section 50 + 5 re-solves + 1 timed mock
```

---

### Key Insight — What Actually Gets Asked

```
╔═══════════════════════════════════════════════════════════════╗
║  FREQUENCY BREAKDOWN (based on 500+ company interview reports) ║
╠═══════════════════════════════════════════════════════════════╣
║  Arrays / Strings / HashMap     35% of questions             ║
║  Trees (Binary Tree, BST)       20% of questions             ║
║  Dynamic Programming            15% of questions             ║
║  Graphs (BFS/DFS)               10% of questions             ║
║  Linked Lists                    8% of questions             ║
║  Stack / Queue                   5% of questions             ║
║  Heap / Priority Queue           4% of questions             ║
║  Backtracking                    3% of questions             ║
╚═══════════════════════════════════════════════════════════════╝

  → The 18-hour plan covers 100% of these categories.
  → Anything not in this list is bonus prep, not essential.
```

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
- [Section 22 — O(n²) Sorts](#section-22--on²-sorts)
- [Section 23 — O(n log n) Sorts](#section-23--on-log-n-sorts)
- [Section 24 — O(n) Sorts](#section-24--on-sorts)
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

```
╔══════════════════════════════════════════════════════════════════╗
║              THE UMPIRE FRAMEWORK — 6 STEPS                     ║
╠══════════════════════════════════════════════════════════════════╣
║  U — Understand  │ Restate the problem in your own words        ║
║  M — Match       │ Identify which pattern/data structure fits   ║
║  P — Plan        │ Write pseudocode before any code             ║
║  I — Implement   │ Code cleanly, name variables well            ║
║  R — Review      │ Trace with example, check edge cases         ║
║  E — Evaluate    │ State time + space complexity                 ║
╚══════════════════════════════════════════════════════════════════╝
```

### The UMPIRE Framework in Detail

**U — Understand** (2–3 minutes)
- Ask clarifying questions: Is the array sorted? Can there be duplicates? What's the expected input size?
- Write down 2–3 examples including edge cases (empty input, single element, all same values)
- Confirm output format (return value vs modify in-place)

**M — Match** (1–2 minutes)
- What data structure does this problem scream? (sorted array → binary search; frequency → hashmap)
- What algorithmic pattern fits? (see Section 4 for the 14 patterns)

**P — Plan** (2–3 minutes)
- Write pseudocode in comments BEFORE writing actual code
- Talk through your plan with the interviewer
- Estimate complexity upfront: "I think this is O(n log n) time, O(1) space"

**I — Implement** (10–15 minutes)
- Use meaningful variable names (`complement` not `x`)
- Handle the main case first, edge cases at the end
- Code as if the interviewer will maintain this code

**R — Review** (3–5 minutes)
- Dry-run your code with the example you wrote in U step
- Check: null input, empty array, single element, duplicates, negatives

**E — Evaluate** (1 minute)
- State Big O clearly: "Time O(n), Space O(n) for the hashmap"
- Mention trade-offs: "We could save space with O(n²) time..."

### Interview Communication Template

```
"Let me make sure I understand the problem...
 So we're given [input] and need to return [output].
 Edge cases I'll consider: [list 2-3].

 I'm thinking [pattern name] because [reason].
 My plan: [2-3 bullet steps].

 Time complexity will be O(?) because [reason].
 Let me code this up..."
```

---

## Section 2 — Complexity Analysis

> **🧠 Mental Model: Racing Cars on Different Tracks**
>
> Think of input size n as the length of a racetrack. O(1) is a teleporter — distance doesn't matter. O(log n) is a sports car — doubling track length barely slows you. O(n) is a bicycle — linear effort. O(n²) is walking with a backpack that gets heavier each step. O(2ⁿ) is a snail that doubles its weight every meter.

```
COMPLEXITY GROWTH VISUALIZATION (n = 1,000,000)
═══════════════════════════════════════════════════════════════
O(1)       │ 1 operation          │ ████
O(log n)   │ ~20 operations       │ ████
O(n)       │ 1,000,000 ops        │ ██████████████████████
O(n log n) │ ~20,000,000 ops      │ ██████████████████████████
O(n²)      │ 1,000,000,000,000 ops│ TIMEOUT ❌
O(2ⁿ)      │ ∞ effectively        │ NEVER FINISH ❌
═══════════════════════════════════════════════════════════════

TARGET COMPLEXITIES FOR INTERVIEWS:
  10^8 operations ≈ 1 second on modern hardware
  n = 10^6  → need O(n) or O(n log n)
  n = 10^4  → O(n²) is acceptable
  n = 20    → O(2ⁿ) or O(n!) may be OK (backtracking)
```

### Big O Rules

```csharp
// RULE 1: Drop constants — O(2n) → O(n)
for (int i = 0; i < n; i++) { }     // O(n)
for (int j = 0; j < n; j++) { }     // O(n)
// Total: O(2n) = O(n) ← drop constant

// RULE 2: Drop non-dominant terms — O(n² + n) → O(n²)
for (int i = 0; i < n; i++)         // O(n²) ← dominates
    for (int j = 0; j < n; j++) { }
for (int k = 0; k < n; k++) { }     // O(n) ← dwarfed

// RULE 3: Different variables = different terms
void Foo(int[] a, int[] b) {
    foreach (var x in a) { }        // O(a.Length) — call it 'a'
    foreach (var y in b) { }        // O(b.Length) — call it 'b'
    // Total: O(a + b), NOT O(n)!
}

// RULE 4: Recursive functions — count recursive calls × work per call
int Fib(int n) {                    // branches = 2 each call
    if (n <= 1) return n;           // depth = n
    return Fib(n-1) + Fib(n-2);    // → O(2^n) time, O(n) stack space
}
```

### Complexity Quick Reference

| Notation | Name | Example |
|----------|------|---------|
| O(1) | Constant | Array index, hash lookup |
| O(log n) | Logarithmic | Binary search |
| O(n) | Linear | Single loop through array |
| O(n log n) | Linearithmic | Merge sort, heap sort |
| O(n²) | Quadratic | Nested loops |
| O(n³) | Cubic | Triple nested loops |
| O(2ⁿ) | Exponential | All subsets, recursive fib |
| O(n!) | Factorial | All permutations |

---

## Section 3 — Space-Time Trade-offs & Amortized Analysis

> **🧠 Mental Model: Caching in a Restaurant**
>
> A restaurant can cook every dish fresh (slow, no memory) or pre-cook popular dishes (fast, uses refrigerator space). Trading **space** for **time** is the fundamental trade-off in algorithm design. HashMap, memoization, and prefix sums all "pay" with memory to "earn" speed.

### Common Space-Time Trade-offs

```
TRADE-OFF EXAMPLES:
═════════════════════════════════════════════════════════════════
  Problem: "Find sum of subarray [i..j] quickly"

  Option A (no extra space):
    Loop from i to j, sum as you go → O(n) time per query, O(1) space

  Option B (prefix sum — spend space, save time):
    pre[i] = sum of arr[0..i-1]          ← O(n) space upfront
    query(i,j) = pre[j+1] - pre[i]       ← O(1) per query!
    Preprocessing: O(n) once, then O(1) per query

  If you have 10,000 queries → Option B saves enormous time
═════════════════════════════════════════════════════════════════
```

```csharp
// PREFIX SUM — the canonical space-for-time trade
// WHY "prefixSums"? Explicit name clarifies it stores cumulative totals, not raw values
int[] BuildPrefixSum(int[] arr) {
    // STEP 1: Allocate prefix array one larger than input (prefixSums[0]=0 is the "empty" base)
    // WHY size arr.Length+1? prefixSums[0]=0 represents sum of zero elements — avoids
    // special-casing queries that start at index 0
    int[] prefixSums = new int[arr.Length + 1];
    // STEP 2: Build running cumulative sum — prefixSums[i+1] holds total of arr[0..i]
    for (int i = 0; i < arr.Length; i++)
        prefixSums[i + 1] = prefixSums[i] + arr[i];  // each cell = previous sum + current element
    return prefixSums;
}

int RangeSum(int[] prefixSums, int left, int right) {
    // STEP 1: Compute range sum using prefix subtraction — O(1) per query
    // Sum of arr[left..right] = (total up to right+1) − (total up to left)
    // WHY right+1? prefixSums uses 1-based indexing: prefixSums[i] = sum of arr[0..i-1]
    return prefixSums[right + 1] - prefixSums[left];   // O(1) — no loop needed!
}
```

### Amortized Analysis

```
DYNAMIC ARRAY (List<T>) — AMORTIZED O(1) APPEND
═══════════════════════════════════════════════════════════════
  Capacity 1 → 2 → 4 → 8 → 16 → ...   (doubles when full)

  Append sequence (capacity=4):
  [A]         capacity=1, count=1       cost=1
  [A,B]       capacity=2, count=2       cost=1+copy1=2 (resize!)
  [A,B,C]     capacity=4, count=3       cost=1
  [A,B,C,D]   capacity=4, count=4       cost=1
  [A,B,C,D,E] capacity=8, count=5       cost=1+copy4=5 (resize!)

  Total cost for n appends ≈ n + (1+2+4+...+n/2) ≈ 2n = O(n)
  Amortized per append = O(n)/n = O(1) ✅
═══════════════════════════════════════════════════════════════
```

---

## Section 4 — The 14 Problem-Solving Patterns (Catalog)

> **🧠 Mental Model: A Toolkit**
>
> A carpenter doesn't use a hammer for every job. Similarly, 95% of interview problems fit into ~14 recognizable patterns. Once you see the pattern, the solution follows automatically. This section is your toolkit reference — each pattern has its own deep-dive section in Part 9.

```
╔══════════════════════════════════════════════════════════════════╗
║           14 PROBLEM-SOLVING PATTERNS — QUICK REFERENCE         ║
╠══════════╦═══════════════════════════╦══════════════════════════╣
║ Pattern  ║ When to use               ║ Key indicator            ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 1. Two   ║ Sorted array, find pair   ║ "find two numbers that"  ║
║ Pointers ║ sum/difference/product    ║ "palindrome check"       ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 2. Slide ║ Subarray/substring of     ║ "contiguous subarray"    ║
║ Window   ║ fixed or variable size    ║ "longest substring"      ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 3. Fast/ ║ Linked list cycle,        ║ "detect cycle"           ║
║ Slow Ptr ║ middle of list            ║ "find middle"            ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 4. Merge ║ Overlapping ranges,       ║ "intervals", "meetings"  ║
║ Intervals║ insert/merge intervals    ║ "overlap"                ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 5. Cyclic║ Array with values in      ║ "find missing/duplicate" ║
║ Sort     ║ range [1..n]              ║ "in-place rearrangement" ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 6. LL    ║ Reverse a linked list     ║ "reverse", "reorder"     ║
║ Reversal ║ or part of it             ║ "k-group reversal"       ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 7. Mod.  ║ Sorted but rotated,       ║ "rotated array"          ║
║ Bin Srch ║ find in mountain array    ║ "find first/last pos"    ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 8. Top K ║ Find k largest/smallest   ║ "top k", "kth largest"   ║
║ Elements ║ K closest points          ║ "k frequent elements"    ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 9. Mono. ║ Next greater/smaller      ║ "next greater element"   ║
║ Stack    ║ Largest rectangle         ║ "temperatures"           ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 10. Bit  ║ Single number in pairs,   ║ "XOR", "bits", "power2"  ║
║ Manipul. ║ count set bits            ║ "without +/-"            ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 11. BFS  ║ Shortest path, level-by-  ║ "shortest path"          ║
║ Pattern  ║ level tree traversal      ║ "minimum steps"          ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 12. DFS/ ║ All paths, permutations,  ║ "all combinations"       ║
║ Backtrack║ subsets, N-Queens         ║ "generate all"           ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 13. DP   ║ Overlapping subproblems,  ║ "minimum/maximum"        ║
║          ║ optimal substructure      ║ "count ways to"          ║
╠══════════╬═══════════════════════════╬══════════════════════════╣
║ 14. Greedy║ Local optimal = global   ║ "minimum cost"           ║
║          ║ optimal (provable)        ║ "maximum profit"         ║
╚══════════╩═══════════════════════════╩══════════════════════════╝
```

---

# PART 2 — LINEAR DATA STRUCTURES

---

## Section 5 — Arrays

> **🧠 Mental Model: A Parking Lot**
>
> An array is like a parking lot with numbered spaces. You can jump directly to space #42 in O(1) — the lot's layout tells you exactly where it is. But if you want to INSERT a new car in the middle, every car to the right must shift one spot — O(n) work. Arrays excel at **random access**, struggle with **insertions/deletions in the middle**.

```
ARRAY MEMORY LAYOUT (int[] arr = {10, 20, 30, 40, 50})
═══════════════════════════════════════════════════════════════
  Index:   [0]   [1]   [2]   [3]   [4]
  Value:   [10]  [20]  [30]  [40]  [50]
           ↑
    base address (e.g., 0x1000)
    arr[2] = *(0x1000 + 2 * sizeof(int)) = *(0x1008) = 30
    → O(1) access via pointer arithmetic

  INSERTION at index 1 (value=99):
  BEFORE: [10] [20] [30] [40] [50]
  SHIFT:   ← all elements right of 1 shift right
  AFTER:  [10] [99] [20] [30] [40] [50]  ← O(n) work!

  DELETION at index 1:
  BEFORE: [10] [99] [20] [30] [40] [50]
  SHIFT:   ← all elements right of 1 shift left
  AFTER:  [10] [20] [30] [40] [50]  ← O(n) work!
═══════════════════════════════════════════════════════════════
```

### C# Array Essentials

```csharp
// ═══ DECLARATION & INITIALIZATION ═══
int[] arr = new int[5];              // all zeros
int[] arr2 = { 1, 2, 3, 4, 5 };     // inline init
int[] arr3 = new int[] { 1, 2, 3 }; // explicit

// ═══ 2D ARRAYS (grid problems — very common in interviews!) ═══
int[,] matrix = new int[3, 4];       // 3 rows, 4 cols — rectangular
int[][] jagged = new int[3][];       // jagged: each row has different length
jagged[0] = new int[] { 1, 2 };
jagged[1] = new int[] { 3, 4, 5 };

// Grid traversal — 4 directions (up/down/left/right)
// WHY separate delta arrays? Cleaner than switch/if chains; easy to extend to 8-dirs
int[] rowDelta = { -1, 1, 0, 0 };  // row offset: up=-1, down=+1, left=0, right=0
int[] colDelta = { 0, 0, -1, 1 };  // col offset: up=0, down=0, left=-1, right=+1
for (int direction = 0; direction < 4; direction++) {
    int nextRow = row + rowDelta[direction];  // candidate neighbor row
    int nextCol = col + colDelta[direction];  // candidate neighbor col
    if (nextRow >= 0 && nextRow < rows && nextCol >= 0 && nextCol < cols) {
        // process neighbor (nextRow, nextCol) — bounds check ensures valid cell
    }
}

// ═══ LIST<T> — DYNAMIC ARRAY (preferred in interviews) ═══
var list = new List<int> { 1, 2, 3 };
list.Add(4);           // O(1) amortized — may trigger resize
list.Insert(0, 99);    // O(n) — shifts all elements
list.RemoveAt(0);      // O(n) — shifts all elements
list[0];               // O(1) random access
list.Count;            // O(1) — cached, not counted each time!

// ═══ COMMON ARRAY OPERATIONS IN INTERVIEWS ═══
// Reverse
Array.Reverse(arr);                  // O(n), in-place

// Sort
Array.Sort(arr);                     // O(n log n), in-place
Array.Sort(arr, (a, b) => b - a);   // descending — custom comparer

// Binary search (requires sorted)
int idx = Array.BinarySearch(arr, 42); // O(log n)

// Copy (shallow)
int[] copy = (int[])arr.Clone();    // or: arr.ToArray()

// LINQ on arrays
int max = arr.Max();                // O(n)
int sum = arr.Sum();                // O(n)
int[] filtered = arr.Where(x => x > 0).ToArray(); // O(n)
```

### Complexity Table

| Operation | Array (fixed) | List\<T\> (dynamic) |
|-----------|--------------|---------------------|
| Access by index | O(1) | O(1) |
| Search (unsorted) | O(n) | O(n) |
| Search (sorted) | O(log n) | O(log n) |
| Insert at end | N/A | O(1) amortized |
| Insert at middle | N/A | O(n) |
| Delete at end | N/A | O(1) |
| Delete at middle | N/A | O(n) |
| Space | O(n) | O(n) |

### Common Pitfalls
- ⚠️ Off-by-one errors: `arr[arr.Length]` throws `IndexOutOfRangeException` — use `arr.Length - 1`
- ⚠️ Integer overflow in mid calculation: use `left + (right - left) / 2` not `(left + right) / 2`
- ⚠️ Modifying list while iterating with `foreach` → `InvalidOperationException`
- ⚠️ `arr.Clone()` is shallow — for reference types, elements are not deep-copied

---

### 🔴🔥 Practice Problem: Two Sum (LeetCode #1 — Easy) — MUST SOLVE

**Problem:** Given `nums` array and integer `target`, return indices of two numbers that add up to `target`.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: TWO SUM                                     ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE FORCE  │ Try every pair (i,j)  │ O(n²) time │ O(1)   ║
║                  │ nested loops          │            │ space  ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 BETTER       │ Sort + two pointers   │ O(n log n) │ O(1)   ║
║                  │ (loses original index)│            │ space  ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 OPTIMAL      │ HashMap: store seen   │ O(n) time  │ O(n)   ║
║                  │ values → O(1) lookup  │            │ space  ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: "I need fast lookup of complement = target - num"
             Fast lookup → HashMap (Dictionary) → O(1) per check
```

> **🔑 CORE IDEA:** For each number, ask "is target−num already seen?" Store seen numbers in a HashMap so the complement check is O(1).

**🔴 Brute Force — O(n²)**
```csharp
// Try EVERY pair — two nested loops
// Works, but too slow for large arrays
public int[] TwoSumBrute(int[] nums, int target) {
    for (int i = 0; i < nums.Length; i++) {
        for (int j = i + 1; j < nums.Length; j++) {   // j starts at i+1 to avoid using same element
            if (nums[i] + nums[j] == target)
                return new[] { i, j };
        }
    }
    return Array.Empty<int>();
}
// Problem: for n=10^4, this is 10^8 operations → TLE (Time Limit Exceeded)
```

**🟢 Optimal — HashMap O(n)**
```csharp
public int[] TwoSum(int[] nums, int target) {
    // STEP 1: Initialize HashMap to store {value → index} for O(1) complement lookup
    // WHY Dictionary? We need to answer "have I seen the complement before?"
    // in O(1) time. Dictionary gives O(1) average lookup by key.
    var seen = new Dictionary<int, int>(); // key=value, val=index

    for (int i = 0; i < nums.Length; i++) {
        // STEP 2: Compute the complement (the number we NEED to complete the pair)
        // WHY compute complement first? If complement exists in seen,
        // we already have both numbers — no need to add current one yet.
        int complement = target - nums[i];  // what number do we NEED?

        // STEP 3: Check if complement was seen before → if yes, return the pair
        // TryGetValue is preferred over ContainsKey + indexer
        // because it does ONE lookup (not two)
        if (seen.TryGetValue(complement, out int j))
            return new[] { j, i };  // j is the earlier index, i is current

        // STEP 4: Record current number's index AFTER checking (prevents same-element reuse)
        // WHY add AFTER checking? Prevents using same element twice.
        // Example: nums=[3,3], target=6 → we don't want to use index 0 twice
        seen[nums[i]] = i;
    }

    return Array.Empty<int>(); // guaranteed solution exists per problem statement
}
// Time: O(n) — single pass through array
// Space: O(n) — dictionary stores at most n entries
```

```
STEP-BY-STEP TRACE: nums=[2,7,11,15], target=9
════════════════════════════════════════════════════════
  i=0 │ num=2  │ comp=9-2=7   │ seen={}     │ 7 not in seen → add {2:0}
  i=1 │ num=7  │ comp=9-7=2   │ seen={2:0}  │ 2 IS in seen! → return [0,1] ✅
════════════════════════════════════════════════════════

TRACE: nums=[3,2,4], target=6
════════════════════════════════════════════════════════
  i=0 │ num=3  │ comp=6-3=3   │ seen={}     │ 3 not in seen → add {3:0}
  i=1 │ num=2  │ comp=6-2=4   │ seen={3:0}  │ 4 not in seen → add {2:1}
  i=2 │ num=4  │ comp=6-4=2   │ seen={3,2}  │ 2 IS in seen! → return [1,2] ✅
════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** The pattern "need fast lookup of a value" → HashMap is the #1 most important trick in array problems. It transforms O(n²) brute force (nested loop) to O(n) in one HashMap pass. Master this pattern first.

---

## Section 6 — Strings

> **🧠 Mental Model: A Bead Necklace**
>
> A string is like a necklace of character beads. In C#, strings are **immutable** — once created, you cannot change a bead in place. Every "modification" creates a new necklace. `StringBuilder` is a work-in-progress necklace on the table — you add/remove beads freely, then string them together at the end (`.ToString()`).

```
STRING IMMUTABILITY VISUALIZATION:
═══════════════════════════════════════════════════════════════
  string s = "hello";
  s += " world";    // What ACTUALLY happens:

  Memory BEFORE:
    Heap: [ h | e | l | l | o ]  ← "hello" at address 0x100
    s → 0x100

  Memory AFTER:
    Heap: [ h | e | l | l | o ]  ← "hello" STILL EXISTS (GC will clean up)
          [ h | e | l | l | o |   | w | o | r | l | d ]  ← NEW string at 0x200
    s → 0x200

  COST: O(n) to create new string (copies all chars)
  IN A LOOP: s += char is O(n²) total! Use StringBuilder instead.
═══════════════════════════════════════════════════════════════
```

### C# String Essentials

```csharp
// ═══ CHAR OPERATIONS — CRITICAL FOR INTERVIEW PROBLEMS ═══
char c = 'a';
char.IsDigit('5');      // true — is it 0-9?
char.IsLetter('a');     // true — is it a-z or A-Z?
char.IsWhiteSpace(' '); // true
char.ToLower('A');      // 'a'
char.ToUpper('a');      // 'A'

// WHY char-to-index? Many string problems use frequency arrays
// instead of HashMap — faster (array vs hash) and simpler
int idx = 'c' - 'a';   // = 2 → maps 'a'→0, 'b'→1, ..., 'z'→25
// Reverse: (char)('a' + 2) = 'c'

// FREQUENCY ARRAY PATTERN (faster than Dictionary for fixed alphabet)
int[] freq = new int[26];           // 26 lowercase letters
foreach (char ch in "hello")
    freq[ch - 'a']++;               // 'h'→7, 'e'→4, 'l'→11, 'o'→14
// Check if two strings are anagrams: freq arrays must be equal

// ═══ STRINGBUILDER — O(1) AMORTIZED APPEND ═══
var sb = new StringBuilder();
sb.Append("hello");    // add string — O(1) amortized
sb.Append(' ');        // add char
sb.Insert(0, "say: "); // O(n) — inserts at position
sb.Remove(0, 5);       // O(n) — removes chars
string result = sb.ToString(); // ONE allocation at the end

// ═══ IMPORTANT STRING METHODS ═══
string s = "Hello World";
s.Length;              // 11 — O(1)
s[0];                  // 'H' — O(1) index access
s.ToCharArray();       // convert to char[] for mutation
s.Substring(6, 5);     // "World" — O(n), creates new string
s.IndexOf('o');        // 4 — first occurrence
s.LastIndexOf('o');    // 7 — last occurrence
s.Contains("World");   // true — O(n)
s.Split(' ');          // ["Hello", "World"]
string.Join("-", arr); // "Hello-World"
s.Replace("World","C#"); // new string with replacement
s.Trim();              // remove whitespace from both ends
s.TrimStart();         // remove from left only
s.TrimEnd();           // remove from right only
new string('a', 5);    // "aaaaa" — repeat char n times

// ═══ SPAN<CHAR> — ZERO-ALLOCATION SUBSTRING (performance code) ═══
ReadOnlySpan<char> span = s.AsSpan(6, 5); // "World" — no heap allocation!
// Use in hot paths where memory matters
```

### Complexity Table

| Operation | string | StringBuilder |
|-----------|--------|---------------|
| Length | O(1) | O(1) |
| Index access | O(1) | O(1) |
| Concatenation (+=) | O(n) new string | O(1) amortized |
| Substring | O(n) copy | O(1) with Span |
| IndexOf/Contains | O(n) | O(n) |
| Build n-char result | O(n²) if += in loop! | O(n) |

---

### 🔴 Practice Problem: Longest Palindromic Substring (LeetCode #5 — Medium)

**Problem:** Given string `s`, return the longest palindromic substring.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LONGEST PALINDROMIC SUBSTRING              ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Check all O(n²) substrings, each O(n) │ O(n³)  ║
║  FORCE       │ verify palindrome                      │ O(1)   ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 DP       │ dp[i][j]=true if palindrome,           │ O(n²)  ║
║              │ build from short to long               │ O(n²)  ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 EXPAND   │ For each center, expand outward        │ O(n²)  ║
║  FROM CENTER │ while chars match. 2 cases: odd/even  │ O(1)   ║
╠══════════════════════════════════════════════════════════════════╣
║  🏆 MANACHER │ Specialized O(n) algorithm             │ O(n²)  ║
║  (bonus)     │ (rarely needed in interviews)          │ O(n)   ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: A palindrome has a CENTER. Instead of checking every
             substring, stand at each center and expand outward.
             2 types of centers: odd-length (single char center)
             and even-length (between two chars).
```

> **🔑 CORE IDEA:** Every palindrome has a center (1 char or 2 chars). Expand outward from each of the 2n−1 centers; track the longest expansion found.

```
EXPAND-FROM-CENTER VISUALIZATION on "babad":
═══════════════════════════════════════════════════════════════
  String:  b  a  b  a  d
  Index:   0  1  2  3  4

  Center 0 (char 'b'): expand → 'b' (len=1, no expansion possible)
  Center 1 (char 'a'): expand L=0,R=2 → s[0]='b' s[2]='b' match!
                        expand L=-1 → out of bounds. palindrome="bab" len=3
  Center 2 (char 'b'): expand L=1,R=3 → s[1]='a' s[3]='a' match!
                        expand L=0,R=4 → s[0]='b' s[4]='d' NO match
                        palindrome="aba" len=3
  Center between 1&2 (even): L=1,R=2 → 'a' vs 'b' NO match → len=0
  Best: "bab" or "aba", both len=3 → return either
═══════════════════════════════════════════════════════════════
```

```csharp
public string LongestPalindrome(string s) {
    if (s.Length == 0) return "";

    // STEP 1: Initialize tracking variables for the best palindrome found
    int start = 0, maxLen = 1; // track best palindrome found

    // Helper: expand from center and return length of palindrome found
    // WHY a local function? Avoids code duplication for odd/even cases
    int Expand(int left, int right) {
        // STEP 2: Expand outward while characters match and bounds are valid
        // WHY check both boundaries? String is finite; can't go past ends
        while (left >= 0 && right < s.Length && s[left] == s[right]) {
            left--;   // move left pointer outward
            right++;  // move right pointer outward
        }
        // STEP 3: Compute palindrome length from final (overshot) pointer positions
        // WHY right - left - 1? After the last successful expansion,
        // left went one too far left and right went one too far right.
        // Actual palindrome is s[left+1 .. right-1], length = (right-1)-(left+1)+1 = right-left-1
        return right - left - 1;
    }

    for (int i = 0; i < s.Length; i++) {
        // STEP 4: Try odd-length expansion centered at character i
        // Example: "aba" centered at 'b' (index 1)
        int oddLen = Expand(i, i);

        // STEP 5: Try even-length expansion centered between i and i+1
        // Example: "abba" centered between the two 'b's
        int evenLen = Expand(i, i + 1);

        // STEP 6: Update global best if this center produced a longer palindrome
        int bestLen = Math.Max(oddLen, evenLen);
        if (bestLen > maxLen) {
            maxLen = bestLen;
            // WHY this formula? The palindrome ends at i + bestLen/2
            // and starts at i - (bestLen-1)/2
            // Integer division handles odd vs even correctly
            start = i - (bestLen - 1) / 2;
        }
    }

    return s.Substring(start, maxLen);
}
// Time: O(n²) — n centers × O(n) expansion each
// Space: O(1) — only track indices, no extra data structure
```

```
TRACE: s = "cbbd"
════════════════════════════════════════════════════════════
  i=0 ('c'): odd=Expand(0,0)  → left=-1 stop → len=1
             even=Expand(0,1) → 'c' vs 'b' mismatch → len=0
             best=1, start=0

  i=1 ('b'): odd=Expand(1,1)  → 'c' vs 'b' mismatch at (0,2) → len=1
             even=Expand(1,2) → 'b' vs 'b' match! → (0,3): 'c' vs 'd' mismatch
                                len=(3-0-1)=2 → palindrome="bb"
             best=2, start=1

  i=2 ('b'): odd=Expand(2,2)  → 'b' vs 'b' match! → (0,4) out of bounds
                                len=(4-0-1)=... wait: left=0,right=3 after first
                                expansion. Then left=-1,right=4. len=4-(-1)-1=4? No.
                                Let's re-trace: Expand(2,2):
                                  left=2,right=2: s[2]='b'==s[2]='b' → left=1,right=3
                                  left=1,right=3: s[1]='b'==s[3]='d'? No → stop
                                  return 3-1-1=1
             even=Expand(2,3) → 'b' vs 'd' mismatch → len=0
             best=1

  i=3 ('d'): odd=Expand(3,3)  → len=1
             best=1

  Final: maxLen=2, start=1 → s.Substring(1,2) = "bb" ✅
════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** When dealing with palindromes, think "expand from center" rather than "check all substrings." The center perspective reduces the problem from O(n³) to O(n²). Remember there are TWO types of centers: single character (odd-length) and between two characters (even-length).

---

## Section 7 — Linked Lists

> **🧠 Mental Model: A Scavenger Hunt**
>
> A linked list is like a scavenger hunt — each clue (node) contains: (1) the current clue's content (data), and (2) directions to the next clue location (next pointer). You CANNOT jump to clue #5 without following the chain from #1 → #2 → #3 → #4 → #5. That's why access is O(n), but insertion (once you're at the spot) is O(1) — just redirect the pointer!

```
SINGLY LINKED LIST STRUCTURE:
═══════════════════════════════════════════════════════════════
  head
   │
   ▼
  ┌────┬──────┐    ┌────┬──────┐    ┌────┬──────┐    ┌────┬──────┐
  │ 1  │  ●───┼───►│ 2  │  ●───┼───►│ 3  │  ●───┼───►│ 4  │ null │
  └────┴──────┘    └────┴──────┘    └────┴──────┘    └────┴──────┘
  [val][next]       [val][next]       [val][next]      [val][next]

DOUBLY LINKED LIST (LinkedList<T> in C#):
  null ←─ [1] ⇄ [2] ⇄ [3] ⇄ [4] ─► null
           ↑                   ↑
          head               tail  (O(1) access to both ends!)

INSERT at head (O(1)):           DELETE from middle (O(1) if you have the node):
  newNode → [99] → [1] → [2]    [1] ──►[2]──► [3]
  head = newNode                         ↕ unlink
                                 [1] ──────────► [3]
═══════════════════════════════════════════════════════════════
```

### Custom Linked List Node (C#)

```csharp
// WHY define our own? LeetCode problems use custom ListNode, not LinkedList<T>
public class ListNode {
    public int val;
    public ListNode next;
    // Record syntax alternative (cleaner):
    // public record ListNode(int val, ListNode next = null);
    public ListNode(int val = 0, ListNode next = null) {
        this.val = val;
        this.next = next;
    }
}

// BUILDING A LIST from array (utility for testing)
ListNode BuildList(int[] vals) {
    // STEP 1: Create dummy head to simplify list construction
    var dummy = new ListNode(0);  // dummy head avoids special-casing head node
    var curr = dummy;
    // STEP 2: Append each value as a new node, advancing curr
    foreach (int v in vals) {
        curr.next = new ListNode(v);
        curr = curr.next;
    }
    return dummy.next; // return actual head, not dummy
}

// THREE ESSENTIAL LINKED LIST TECHNIQUES:

// 1. DUMMY HEAD NODE — eliminates edge cases when head might change
ListNode RemoveValue(ListNode head, int val) {
    // STEP 1: Create dummy node pointing to head — handles head-removal edge case
    var dummy = new ListNode(0) { next = head }; // dummy points to real head
    var curr = dummy;
    // STEP 2: Walk list; when next node matches val, skip it (unlink)
    while (curr.next != null) {
        if (curr.next.val == val)
            curr.next = curr.next.next; // skip the node to delete
        else
            curr = curr.next;
    }
    return dummy.next; // return potentially new head
}

// 2. TWO POINTER (fast/slow) — find middle, detect cycle
ListNode FindMiddle(ListNode head) {
    // STEP 1: Initialize slow (1x speed) and fast (2x speed) pointers
    ListNode slow = head, fast = head;
    // STEP 2: Advance fast 2 steps and slow 1 step until fast reaches end
    // WHY fast && fast.next? fast moves 2 steps, need to check both
    while (fast != null && fast.next != null) {
        slow = slow.next;       // moves 1 step
        fast = fast.next.next;  // moves 2 steps
    }
    // STEP 3: When fast is at end, slow is exactly at the middle
    return slow; // when fast reaches end, slow is at middle
}

// 3. REVERSING — the 3-pointer technique (most important LL technique!)
ListNode Reverse(ListNode head) {
    // STEP 1: Initialize prev=null (new tail points nowhere) and curr=head
    ListNode prev = null, curr = head;
    while (curr != null) {
        // STEP 2: Save next pointer BEFORE overwriting curr.next
        ListNode next = curr.next; // SAVE next before we overwrite it
        // STEP 3: Flip the link — curr now points backward to prev
        curr.next = prev;          // REVERSE the link (point backward)
        // STEP 4: Advance both pointers one position forward
        prev = curr;               // ADVANCE prev (it becomes the new "behind")
        curr = next;               // ADVANCE curr (move forward)
    }
    // STEP 5: prev is the new head (last node we processed = old tail)
    return prev; // prev is now pointing to the new head (old tail)
}
```

### Complexity Table

| Operation | Singly LL | Doubly LL (LinkedList\<T\>) |
|-----------|-----------|-------------------------------|
| Access by index | O(n) | O(n) |
| Search | O(n) | O(n) |
| Insert at head | O(1) | O(1) |
| Insert at tail | O(n)* | O(1) — has tail pointer |
| Insert at middle | O(n) to find + O(1) | O(n) to find + O(1) |
| Delete at head | O(1) | O(1) |
| Space | O(n) | O(n) + pointer overhead |

*O(1) if you maintain a tail pointer

---

### 🔴🔥 Practice Problem: Reverse Linked List (LeetCode #206 — Easy) — MUST SOLVE

**Problem:** Reverse a singly linked list. Return the new head.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: REVERSE LINKED LIST                         ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Copy to array, reverse   │ O(n) time │ O(n) sp  ║
║  FORCE       │ array, rebuild list      │           │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 STACK    │ Push all nodes, pop to   │ O(n) time │ O(n) sp  ║
║              │ rebuild — same as above  │           │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 ITERATIVE│ 3-pointer in-place       │ O(n) time │ O(1) sp  ║
║  (OPTIMAL)   │ prev/curr/next           │           │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 RECURSIVE│ Elegant but O(n) stack   │ O(n) time │ O(n) sp  ║
║  (ALTERNATE) │ space (call stack)       │           │          ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** 3 pointers: prev=null, curr=head. Each step: save next, flip curr→prev, advance both. When curr is null, prev is the new head.

```
THE 3-POINTER REVERSAL — VISUAL:
═══════════════════════════════════════════════════════════════
INITIAL:  null ←prev  curr→ [1] → [2] → [3] → [4] → null

STEP 1:   Save next=[2]. Flip: [1]→null. Move prev=[1], curr=[2]
          null ← [1]    [2] → [3] → [4] → null
                prev    curr

STEP 2:   Save next=[3]. Flip: [2]→[1]. Move prev=[2], curr=[3]
          null ← [1] ← [2]    [3] → [4] → null
                       prev    curr

STEP 3:   Save next=[4]. Flip: [3]→[2]. Move prev=[3], curr=[4]
          null ← [1] ← [2] ← [3]    [4] → null
                              prev    curr

STEP 4:   Save next=null. Flip: [4]→[3]. Move prev=[4], curr=null
          null ← [1] ← [2] ← [3] ← [4]    null
                                    prev    curr

curr==null → STOP. Return prev=[4] as new head.
Result: [4] → [3] → [2] → [1] → null ✅
═══════════════════════════════════════════════════════════════
```

```csharp
// ITERATIVE — O(n) time, O(1) space (PREFERRED in interviews)
public ListNode ReverseList(ListNode head) {
    // STEP 1: Initialize prev=null (new tail) and curr=head (traversal pointer)
    ListNode prev = null;  // starts as null because new tail points to null
    ListNode curr = head;  // starts at head, walks forward

    while (curr != null) {
        // STEP 2: Save next before we destroy the link!
        // Without this save, we'd lose the rest of the list when we flip curr.next
        ListNode next = curr.next;

        // STEP 3: Flip the arrow — instead of pointing forward, point backward
        curr.next = prev;

        // STEP 4: Advance both pointers by one position
        prev = curr;    // prev moves to where curr was
        curr = next;    // curr moves to what was next
    }

    // STEP 5: Return prev — it's now sitting at the new head (old tail)
    // WHY return prev, not curr? curr is null (we went past the end).
    // prev is sitting on the node that became the new head (old tail).
    return prev;
}

// RECURSIVE — O(n) time, O(n) space (elegant but uses call stack)
public ListNode ReverseListRecursive(ListNode head) {
    // STEP 1: Base case — empty list or single node is already reversed
    if (head == null || head.next == null) return head;

    // STEP 2: Recursively reverse the tail (head.next onward)
    // RECURSIVE CASE: assume the rest (head.next onward) is already reversed
    // Example: [1] → [2] → [3] → [4] → null
    // newHead = ReverseList([2]→[3]→[4]) returns [4]→[3]→[2]→null
    ListNode newHead = ReverseListRecursive(head.next);

    // STEP 3: Stitch head onto the now-reversed tail
    // Now we need to attach head ([1]) to the end of the reversed portion
    // head.next is still [2] (not changed yet)
    // We want [2].next = [1], then [1].next = null
    head.next.next = head;  // [2] now points back to [1]
    head.next = null;       // [1] points to null (it becomes the new tail)

    // STEP 4: Return the new head (from the deepest recursive call — old tail)
    return newHead; // [4] is still the new head of the fully reversed list
}
```

```
TRACE: head = [1] → [2] → [3] → null
═══════════════════════════════════════════════════════════
  INIT:    prev=null, curr=[1]
  ITER 1:  next=[2], curr.next=null, prev=[1], curr=[2]
           List state: null←[1]  [2]→[3]→null
  ITER 2:  next=[3], curr.next=[1], prev=[2], curr=[3]
           List state: null←[1]←[2]  [3]→null
  ITER 3:  next=null, curr.next=[2], prev=[3], curr=null
           List state: null←[1]←[2]←[3]
  curr==null → return prev=[3]
  Result: [3]→[2]→[1]→null ✅
═══════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** The 3-pointer reversal (prev/curr/next) is THE fundamental linked list technique. It appears in dozens of problems. Memorize this pattern: save-next, flip-link, advance-both. The key danger is losing the rest of the list — always save `next` before flipping.

---

## Section 8 — Stacks

> **🧠 Mental Model: A Plate Dispenser in a Cafeteria**
>
> A stack is like a spring-loaded plate dispenser. You can only interact with the TOP plate. Push a plate (add) → it goes on top. Pop a plate (remove) → you take from the top. You can't grab a plate from the middle without taking all plates above it first. **LIFO = Last In, First Out**.

```
STACK OPERATIONS VISUALIZATION:
═══════════════════════════════════════════════════════════════
  Push(1):    Push(2):    Push(3):    Pop():     Peek():
  ┌───┐       ┌───┐       ┌───┐       ┌───┐      ┌───┐
  │ 1 │←top   │ 2 │←top   │ 3 │←top   │ 2 │←top  │ 2 │←top
  └───┘        │ 1 │       │ 2 │       │ 1 │      │ 1 │
               └───┘       │ 1 │       └───┘      └───┘
                            └───┘     returns 3   returns 2
                                      (3 removed)  (2 stays)

APPLICATIONS:
  ✅ Undo/Redo (text editors) — push action, pop to undo
  ✅ Function call stack — push frame on call, pop on return
  ✅ Bracket matching — push open, pop/match on close
  ✅ Monotonic stack — next greater/smaller element
  ✅ DFS (iterative) — push neighbors, pop to visit next
═══════════════════════════════════════════════════════════════
```

### C# Stack<T> API

```csharp
var stack = new Stack<int>();

// CORE OPERATIONS — all O(1)
stack.Push(1);      // add to top
stack.Push(2);
stack.Push(3);

int top = stack.Peek();  // look at top WITHOUT removing → 3
int popped = stack.Pop(); // remove and return top → 3
int count = stack.Count;  // 2

// SAFE CHECK BEFORE POP (avoid InvalidOperationException)
if (stack.Count > 0)
    stack.Pop();

// TryPop — non-throwing version (C# 8+)
if (stack.TryPop(out int val)) { /* val = popped value */ }
if (stack.TryPeek(out int top2)) { /* top2 = top value */ }

// ITERATION (top to bottom order)
foreach (int item in stack)
    Console.Write(item); // prints: 2 1 (top first)

// MONOTONIC STACK PATTERN (crucial for interview problems!)
// Problem: find Next Greater Element for each position
int[] NextGreater(int[] arr) {
    // STEP 1: Initialize result with -1 (default: no greater element exists)
    int[] result = new int[arr.Length];
    Array.Fill(result, -1);     // default: no greater element found
    // STEP 2: Stack stores INDICES of elements waiting for their next-greater answer
    var stack = new Stack<int>(); // stores INDICES (not values!)

    for (int i = 0; i < arr.Length; i++) {
        // STEP 3: Pop all stack entries whose value is smaller than arr[i]
        // — arr[i] is the "next greater element" for all of them
        // WHY pop while stack top is smaller? Because arr[i] is the
        // "next greater element" for everything smaller than it on the stack
        while (stack.Count > 0 && arr[stack.Peek()] < arr[i]) {
            int idx = stack.Pop();
            result[idx] = arr[i]; // arr[i] is the next greater for arr[idx]
        }
        // STEP 4: Push current index — it's still waiting for ITS next greater
        stack.Push(i); // push INDEX (so we can update result array)
    }
    return result;
}
```

### Complexity Table

| Operation | Stack\<T\> |
|-----------|-----------|
| Push | O(1) amortized |
| Pop | O(1) |
| Peek | O(1) |
| Search | O(n) |
| Space | O(n) |

---

### 🔴🔥 Practice Problem: Valid Parentheses (LeetCode #20 — Easy) — MUST SOLVE

**Problem:** Given a string of brackets `()[]{}`, determine if the input string is valid (correctly opened and closed).

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: VALID PARENTHESES                           ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 NAIVE    │ Count opens vs closes    │ O(n) time │ O(1) sp  ║
║              │ fails: "](" has count=0  │           │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 STACK    │ Push opens, match closes │ O(n) time │ O(n) sp  ║
║  (OPTIMAL)   │ Stack tracks order!      │           │          ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Counter approach FAILS because it ignores ORDER.
             "](" has equal open/close count but is INVALID.
             Stack preserves order — the most recent open bracket
             must match the next close bracket.
```

> **🔑 CORE IDEA:** Push opening brackets. On closing bracket, pop and verify the match. Stack naturally tracks nesting order — a counter can't.

```
BRACKET MATCHING VISUALIZATION:
═══════════════════════════════════════════════════════════════
  Input: "({[]})"

  Read '(' → push:  stack=['(']
  Read '{' → push:  stack=['(', '{']
  Read '[' → push:  stack=['(', '{', '[']
  Read ']' → close: top='[', matches ']' → pop  stack=['(', '{']
  Read '}' → close: top='{', matches '}' → pop  stack=['(']
  Read ')' → close: top='(', matches ')' → pop  stack=[]
  End: stack empty → VALID ✅

  Input: "([)]"

  Read '(' → push:  stack=['(']
  Read '[' → push:  stack=['(', '[']
  Read ')' → close: top='[', does NOT match ')' → INVALID ❌
═══════════════════════════════════════════════════════════════
```

```csharp
public bool IsValid(string s) {
    // STEP 1: Initialize stack to track unmatched opening brackets
    // WHY stack? Brackets must be closed in reverse order of opening.
    // Stack naturally tracks this LIFO (Last In, First Out) property.
    var stack = new Stack<char>();

    // STEP 2: Build lookup map of closing → expected opening bracket
    // WHY a dictionary? Cleaner than multiple if-else chains.
    // Maps each CLOSING bracket to its expected OPENING bracket.
    var match = new Dictionary<char, char> {
        [')'] = '(',   // if we see ')', we expect '(' on top of stack
        [']'] = '[',   // if we see ']', we expect '[' on top of stack
        ['}'] = '{'    // if we see '}', we expect '{' on top of stack
    };

    foreach (char c in s) {
        if (!match.ContainsKey(c)) {
            // STEP 3: Opening bracket — push it, waiting for its matching close
            // It's an OPENING bracket ('(', '[', or '{')
            // Push onto stack — we'll match it when we see its closing bracket
            stack.Push(c);
        } else {
            // STEP 4: Closing bracket — verify it matches the most recent open bracket
            // WHY stack.Count == 0 check? ")" with empty stack → no opening bracket → invalid
            if (stack.Count == 0 || stack.Peek() != match[c])
                return false; // mismatch → invalid
            stack.Pop(); // matched! remove the opening bracket
        }
    }

    // STEP 5: Valid only if no unmatched opening brackets remain
    // WHY check stack empty? Unclosed brackets like "((" → stack has '(' '(' → invalid
    return stack.Count == 0;
}
// Time: O(n) — visit each character once
// Space: O(n) — stack stores at most n/2 opening brackets
```

```
TRACE: s = "{[]}"
═══════════════════════════════════════════════════════════════
  c='{'  → opening → push     stack=['{']
  c='['  → opening → push     stack=['{','[']
  c=']'  → closing, match[']']='[', peek='[' ✓ → pop   stack=['{']
  c='}'  → closing, match['}']='[', peek='{' ✓ → pop   stack=[]
  END: stack.Count==0 → return true ✅

TRACE: s = "([)"
═══════════════════════════════════════════════════════════════
  c='('  → opening → push     stack=['(']
  c='['  → opening → push     stack=['(','[']
  c=')'  → closing, match[')']='(', peek='[' ✗ → return false ❌
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Stack is perfect for any "matching" or "nesting" problem because it naturally handles the LIFO order. When you see a closing bracket, the most recently opened bracket must match. This "most recent must match first" pattern always signals a Stack.

---

## Section 9 — Queues & Deques

> **🧠 Mental Model: Airport Security Line**
>
> A queue is like an airport security line. First person in line gets through first (FIFO = First In, First Out). You join at the back (Enqueue) and leave from the front (Dequeue). A deque (double-ended queue) is like a line where you can also join or leave from the front — more flexible.

```
QUEUE vs DEQUE vs PRIORITY QUEUE:
═══════════════════════════════════════════════════════════════
  QUEUE:    Enqueue→ [D] [C] [B] [A] →Dequeue
            back                       front
            FIFO: A was first in, A is first out

  DEQUE:    AddFront/RemoveFront ←[D][C][B][A]→ AddBack/RemoveBack
            Double-ended — both ends are O(1)

  PRIORITY QUEUE (Heap):
            Items come out in PRIORITY ORDER, not insertion order
            Min-heap: smallest priority value comes out first
            Max-heap: largest priority value comes out first

USE CASES:
  Queue → BFS traversal, task scheduling, print queue
  Deque → Sliding window maximum (maintain decreasing deque)
  PQ    → Dijkstra's shortest path, Top K elements, A* search
═══════════════════════════════════════════════════════════════
```

### C# Queue APIs

```csharp
// ═══ QUEUE<T> ═══
var queue = new Queue<int>();
queue.Enqueue(1);           // add to back — O(1)
queue.Enqueue(2);
queue.Enqueue(3);

int front = queue.Peek();   // look at front → 1 — O(1)
int deq = queue.Dequeue();  // remove from front → 1 — O(1)
int count = queue.Count;    // 2

queue.TryDequeue(out int val); // non-throwing version

// ═══ PRIORITY QUEUE<TElement, TPriority> (.NET 6+) ═══
// Min-heap by default: LOWEST priority value comes out first
var pq = new PriorityQueue<string, int>();

pq.Enqueue("task A", 3);   // element="task A", priority=3
pq.Enqueue("task B", 1);   // lowest priority number = most urgent
pq.Enqueue("task C", 2);

string next = pq.Peek();    // "task B" (priority 1 = min)
string done = pq.Dequeue(); // "task B" comes out first

// For MAX-HEAP (largest priority first): negate the priority
pq.Enqueue("item", -score);  // negative → smaller = was-larger
// Or use custom IComparer<int>

// ═══ BFS TEMPLATE — Queue is the heart of BFS ═══
void BFS(TreeNode root) {
    if (root == null) return;
    var queue = new Queue<TreeNode>();
    queue.Enqueue(root);

    while (queue.Count > 0) {
        // WHY snapshot size? Process all nodes at current level BEFORE
        // enqueuing nodes of next level. Size at start of while = level size.
        int levelSize = queue.Count;
        for (int i = 0; i < levelSize; i++) {
            var node = queue.Dequeue();
            // process node...
            if (node.left != null) queue.Enqueue(node.left);
            if (node.right != null) queue.Enqueue(node.right);
        }
    }
}
```

---

### 🔴 Practice Problem: Sliding Window Maximum (LeetCode #239 — Hard)

**Problem:** Given array `nums` and window size `k`, return max of each window as it slides.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: SLIDING WINDOW MAXIMUM                      ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ For each window, find max│ O(n×k) time│ O(1) sp ║
║              │ by scanning k elements   │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 SEGMENT  │ Build segment tree for   │ O(n log n) │ O(n) sp ║
║  TREE        │ range max queries        │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DEQUE    │ Monotonic decreasing     │ O(n) time  │ O(k) sp ║
║  (OPTIMAL)   │ deque of indices         │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Maintain a deque of INDICES in DECREASING value order.
             - Front is always the max of the current window
             - Remove indices that fall out of window
             - Remove smaller elements from back (they'll never be max)
```

> **🔑 CORE IDEA:** Monotonic decreasing deque of indices: evict indices outside window from front, evict smaller indices from back; front is always the window max.

```
DEQUE STATE VISUALIZATION: nums=[3,1,2,4,1], k=3
═══════════════════════════════════════════════════════════════
  i=0: num=3 → deque=[] → push 0 → deque=[0]
  i=1: num=1 → 1<3, just push → deque=[0,1]
  i=2: num=2 → 2>1, pop 1 → deque=[0], push 2 → deque=[0,2]
       window [0..2] complete: result=[nums[0]]=3

  i=3: num=4 → 4>nums[2]=2 pop, 4>nums[0]=3 pop → deque=[], push 3
       → deque=[3]
       window [1..3]: front=3, result=[3,4]

  i=4: num=1 → 1<nums[3]=4, push → deque=[3,4]
       window [2..4]: front=3 (index 3 is in [2..4]), result=[3,4,4]
═══════════════════════════════════════════════════════════════
```

```csharp
public int[] MaxSlidingWindow(int[] nums, int k) {
    int n = nums.Length;
    // STEP 1: Allocate result array; total windows = n-k+1
    int[] result = new int[n - k + 1]; // total windows = n-k+1

    // STEP 2: Initialize deque — stores indices in decreasing value order (front=max)
    // WHY LinkedList as deque? C# lacks a built-in Deque.
    // LinkedList<T> supports O(1) AddFirst/AddLast/RemoveFirst/RemoveLast
    // We store INDICES (not values) so we can check if index is in window
    var deque = new LinkedList<int>(); // stores indices, front=max

    for (int i = 0; i < n; i++) {
        // STEP 3: Evict indices that have fallen outside the current window
        // Window is [i-k+1 .. i]. If front index < i-k+1, remove it.
        while (deque.Count > 0 && deque.First.Value < i - k + 1)
            deque.RemoveFirst();

        // STEP 4: Maintain decreasing order — remove back indices smaller than nums[i]
        // WHY? Those smaller values can never be the window max — nums[i]
        // is larger AND appears later in the array, so it dominates them.
        while (deque.Count > 0 && nums[deque.Last.Value] < nums[i])
            deque.RemoveLast();

        // STEP 5: Push current index to back of deque
        deque.AddLast(i); // add current index to back

        // STEP 6: Once first full window is formed, record the max (front of deque)
        // Window is complete when i >= k-1 (we have k elements)
        if (i >= k - 1)
            result[i - k + 1] = nums[deque.First.Value]; // front = max
    }

    return result;
}
// Time: O(n) — each index is added/removed from deque at most once
// Space: O(k) — deque contains at most k indices
```

> **🎯 Key Insight:** The monotonic deque maintains a "useful candidates" list for the window max. The key invariant: **deque is always decreasing from front to back** (front = current window's max). When a new larger element arrives, all previous smaller elements become useless forever — remove them. This O(n) solution is the classic deque/monotonic queue pattern.

---

# PART 3 — HASH-BASED STRUCTURES

---

## Section 10 — Hash Maps (Dictionary)

> **🧠 Mental Model: Library Card Catalog**
>
> A HashMap (Dictionary) is like an old library card catalog. Each drawer has a label (key), and inside is the exact shelf location (value). You don't scan every book — you look up the card catalog entry directly. That's O(1) average time regardless of how many books (entries) there are.

```
HASH MAP INTERNALS — HOW IT WORKS:
═══════════════════════════════════════════════════════════════
  Insert("apple", 5):
  1. Hash("apple") → e.g., 42
  2. bucket_index = 42 % bucket_count → e.g., 2
  3. Store (key="apple", value=5) in bucket[2]

  Lookup("apple"):
  1. Hash("apple") → 42
  2. bucket_index = 42 % bucket_count → 2
  3. Find "apple" in bucket[2] → return 5

  COLLISION (two keys hash to same bucket):
  ┌──────────────────────────────────────────┐
  │ Chaining (C# uses this):                │
  │ bucket[2] → ["apple"→5] → ["grape"→8]   │
  │            (linked list in same bucket)  │
  │ Worst case (all keys collide): O(n)      │
  │ Average case: O(1) with good hash        │
  └──────────────────────────────────────────┘
═══════════════════════════════════════════════════════════════
```

### C# Dictionary<K,V> Essentials

```csharp
// CREATION
var dict = new Dictionary<string, int>();
var dict2 = new Dictionary<int, List<string>>(); // value can be complex type

// ADD / UPDATE — O(1) average
dict["apple"] = 5;          // set value (adds if not exists, updates if exists)
dict.Add("banana", 3);      // throws if key already exists!
dict.TryAdd("apple", 99);   // safe add — returns false if key exists (doesn't overwrite)

// LOOKUP — O(1) average
int val = dict["apple"];    // throws KeyNotFoundException if not found!
// SAFE LOOKUP (preferred):
if (dict.TryGetValue("apple", out int v))
    Console.WriteLine(v);   // v = 5

// GET WITH DEFAULT (doesn't throw)
int count = dict.GetValueOrDefault("missing", 0); // 0 if not found

// CONTAINS
bool hasKey = dict.ContainsKey("apple");   // O(1)
bool hasVal = dict.ContainsValue(5);       // O(n) — scans all values!

// DELETE
dict.Remove("apple");           // O(1)
dict.TryRemove("apple");        // actually Remove returns bool — use that

// ITERATION
foreach (var (key, value) in dict)          // deconstruction syntax
    Console.WriteLine($"{key}: {value}");

foreach (var kvp in dict)
    Console.WriteLine($"{kvp.Key}: {kvp.Value}");

// KEY PATTERN: FREQUENCY COUNT
string[] words = { "apple", "banana", "apple", "cherry", "banana", "apple" };
var freq = new Dictionary<string, int>();
foreach (string word in words)
    freq[word] = freq.GetValueOrDefault(word, 0) + 1;
// freq = {"apple":3, "banana":2, "cherry":1}

// KEY PATTERN: GROUP BY (like LINQ GroupBy but manual)
// e.g., Group strings by their sorted form (for anagram detection)
var groups = new Dictionary<string, List<string>>();
foreach (string word in words) {
    string key = string.Concat(word.OrderBy(c => c)); // sort chars as key
    if (!groups.ContainsKey(key)) groups[key] = new List<string>();
    groups[key].Add(word);
}
```

### Complexity Table

| Operation | Average | Worst (all collide) |
|-----------|---------|---------------------|
| Lookup | O(1) | O(n) |
| Insert | O(1) | O(n) |
| Delete | O(1) | O(n) |
| ContainsKey | O(1) | O(n) |
| Iteration | O(n) | O(n) |
| Space | O(n) | O(n) |

---

### 🔴🔥 Practice Problem: Group Anagrams (LeetCode #49 — Medium) — MUST SOLVE

**Problem:** Given array of strings, group anagrams together.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: GROUP ANAGRAMS                              ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Compare every pair O(n²) │ O(n²×m)   │ O(n×m)  ║
║              │ sort each and compare    │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 SORT KEY │ Sort each word as key    │ O(n×m log m│ O(n×m)  ║
║  (GOOD)      │ group same-sorted-words  │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 COUNT KEY│ 26-char frequency as key │ O(n×m)    │ O(n×m)  ║
║  (OPTIMAL)   │ group same-frequency wds │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Two words are anagrams ↔ they have identical letter frequencies.
             Represent each word by its "canonical form" as a HashMap key.
             Sort approach: O(m log m) per word. Frequency approach: O(m).
```

> **🔑 CORE IDEA:** Anagrams share the same letter-frequency signature. Build a 26-char count array per word and use it as the dictionary key.

```
VISUALIZATION: strs = ["eat","tea","tan","ate","nat","bat"]
═══════════════════════════════════════════════════════════════
  Sort-based keys:
    "eat" → sort → "aet"  → group "aet" = ["eat"]
    "tea" → sort → "aet"  → group "aet" = ["eat", "tea"]
    "tan" → sort → "ant"  → group "ant" = ["tan"]
    "ate" → sort → "aet"  → group "aet" = ["eat","tea","ate"]
    "nat" → sort → "ant"  → group "ant" = ["tan","nat"]
    "bat" → sort → "abt"  → group "abt" = ["bat"]

  Result: [["eat","tea","ate"], ["tan","nat"], ["bat"]]
═══════════════════════════════════════════════════════════════
```

```csharp
public IList<IList<string>> GroupAnagrams(string[] strs) {
    // STEP 1: Initialize groups map: canonical form → list of anagram words
    // WHY Dictionary with string key? We need a canonical form for each
    // anagram group. Words in the same group will have the same key.
    var groups = new Dictionary<string, List<string>>();

    foreach (string word in strs) {
        // STEP 2: Compute canonical key by sorting the word's characters
        // All anagrams produce the same sorted form → same dictionary key.
        // "eat", "tea", "ate" → all become "aet"
        char[] chars = word.ToCharArray();
        Array.Sort(chars);                      // sort in-place: O(m log m)
        string key = new string(chars);         // "aet", "ant", "abt"

        // STEP 3: Create a new group bucket if this key is first seen
        if (!groups.ContainsKey(key))
            groups[key] = new List<string>();

        // STEP 4: Append word to its matching anagram group
        groups[key].Add(word); // add word to its anagram group
    }

    // STEP 5: Return all groups as the result list
    return new List<IList<string>>(groups.Values);
}
// Time: O(n × m log m) where n=num words, m=max word length
// Space: O(n × m) for the dictionary

// OPTIMAL VERSION using frequency array as key (O(n×m) time):
public IList<IList<string>> GroupAnagramsOptimal(string[] strs) {
    var groups = new Dictionary<string, List<string>>();

    foreach (string word in strs) {
        // STEP 1: Build 26-element frequency count array for each word
        // WHY int[26]? One slot per lowercase letter; avoids Dictionary overhead for fixed alphabet
        int[] charFrequency = new int[26];
        foreach (char ch in word)
            charFrequency[ch - 'a']++;  // 'a'→0, 'b'→1, ..., 'z'→25

        // STEP 2: Serialize the frequency array into a deterministic string key
        // Convert frequency array to string key: "1,0,0,...,1,..." (26 comma-separated counts)
        // WHY not charFrequency.ToString()? Arrays don't override ToString() — gives type name, not values.
        // WHY string.Join? Produces a unique, comparable key: two anagrams → identical charFrequency → identical key
        string key = string.Join(",", charFrequency);  // e.g. "eat"/"tea"/"ate" → "1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,..."

        // STEP 3: Group word under its frequency-based key
        if (!groups.ContainsKey(key)) groups[key] = new List<string>();
        groups[key].Add(word);
    }

    return new List<IList<string>>(groups.Values);
}
// Time: O(n × m) — no sorting, just O(m) per word for frequency count
```

> **🎯 Key Insight:** The key technique is finding a **canonical form** — a representation that all anagrams share. Sorted characters work (O(m log m) per word). Frequency count works (O(m) per word). This "canonical form as hashmap key" pattern appears in many string grouping problems.

---

## Section 11 — Hash Sets

> **🧠 Mental Model: A VIP Guest List**
>
> A HashSet is a guest list — it only tells you YES (member) or NO (not a member). No duplicates allowed. Checking "is this person on the list?" is O(1). A SortedSet is the same list but alphabetically ordered — slightly slower O(log n) per operation but always sorted.

```
HASHSET vs DICTIONARY:
═══════════════════════════════════════════════════════════════
  HashSet<T>:
    - Stores ONLY keys (no associated values)
    - Fast membership test: set.Contains(x) → O(1)
    - No duplicates
    - Use when: "have I seen this before?" / "is x in this collection?"

  Dictionary<K,V>:
    - Stores key-value pairs
    - Use when: "how many times?" / "what's the value associated with x?"

  SortedSet<T>:
    - Like HashSet but maintains sorted order (uses Red-Black Tree)
    - O(log n) operations (vs O(1) for HashSet)
    - Use when: "find all elements in range [lo, hi]"

  COMMON USE CASES for HashSet:
  ✅ Deduplication: convert list to set to remove duplicates
  ✅ Cycle detection: "have we visited this node?"
  ✅ Lookup in O(1): faster than List.Contains (O(n))
  ✅ Set operations: union, intersection, difference
═══════════════════════════════════════════════════════════════
```

### C# HashSet<T> API

```csharp
var set = new HashSet<int>();

// CORE OPERATIONS — all O(1) average
set.Add(1);          // adds element; returns false if already exists
set.Add(2);
set.Add(1);          // duplicate — ignored, returns false
set.Count;           // 2 (not 3!)

bool found = set.Contains(1);   // true — O(1)
set.Remove(2);                  // O(1)

// INITIALIZE FROM COLLECTION (auto-deduplication!)
int[] nums = { 1, 2, 3, 1, 2 };
var unique = new HashSet<int>(nums); // {1, 2, 3} — duplicates removed

// SET OPERATIONS
var a = new HashSet<int> { 1, 2, 3 };
var b = new HashSet<int> { 2, 3, 4 };
a.UnionWith(b);        // a = {1,2,3,4} — in-place union
a.IntersectWith(b);    // a = {2,3,4} — keep only common
a.ExceptWith(b);       // a = {1} — remove elements in b

// SORTED SET (maintains order, O(log n))
var sorted = new SortedSet<int> { 5, 1, 3, 2, 4 };
sorted.Min;            // 1 — O(1)
sorted.Max;            // 5 — O(1)
// Get all elements in range [2, 4]:
var range = sorted.GetViewBetween(2, 4); // {2,3,4}
```

---

### 🔴 Practice Problem: Longest Consecutive Sequence (LeetCode #128 — Medium)

**Problem:** Given unsorted array of integers, find the length of longest consecutive elements sequence. Must run in O(n).

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LONGEST CONSECUTIVE SEQUENCE                ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ For each num, check    │ O(n²) or   │ O(1) sp  ║
║              │ num+1, num+2... in arr │ O(n³)      │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 SORT     │ Sort, then scan for    │ O(n log n) │ O(1) sp  ║
║              │ consecutive elements   │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 HASHSET  │ For each sequence      │ O(n) time  │ O(n) sp  ║
║  (OPTIMAL)   │ START, expand with set │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Only START counting from a sequence's beginning.
             A number x is a sequence start if (x-1) is NOT in the set.
             This ensures each sequence is counted exactly once → O(n) total.
```

> **🔑 CORE IDEA:** HashSet for O(1) lookup. For each num where num−1 is NOT in the set (sequence start), count how far the streak extends rightward.

```
VISUALIZATION: nums = [100, 4, 200, 1, 3, 2]
═══════════════════════════════════════════════════════════════
  Set = {100, 4, 200, 1, 3, 2}

  num=100: is 99 in set? No → START of sequence
           100→101? No. Sequence length=1

  num=4:   is 3 in set? Yes → NOT a start, skip

  num=200: is 199 in set? No → START of sequence
           200→201? No. Sequence length=1

  num=1:   is 0 in set? No → START of sequence!
           1→2 in set? Yes. 2→3? Yes. 3→4? Yes. 4→5? No.
           Sequence: 1,2,3,4 → length=4 ← LONGEST

  num=3:   is 2 in set? Yes → NOT a start, skip
  num=2:   is 1 in set? Yes → NOT a start, skip

  Answer: 4 ✅
═══════════════════════════════════════════════════════════════
```

```csharp
public int LongestConsecutive(int[] nums) {
    // STEP 1: Build HashSet for O(1) membership checks
    // WHY HashSet? We need O(1) "does x+1 exist?" checks.
    // If we searched the array each time: O(n) per check = O(n²) total.
    var numSet = new HashSet<int>(nums); // O(n) to build

    int longest = 0;

    foreach (int num in numSet) {  // iterate set (no duplicates = cleaner)
        // STEP 2: Only begin counting from sequence START points (num-1 absent)
        // A number is a sequence START if num-1 is NOT in the set.
        // WHY? If num-1 IS in the set, then counting from num would give
        // a PARTIAL sequence that we'll count again from the true start.
        // This check is what makes the algorithm O(n) instead of O(n²).
        if (!numSet.Contains(num - 1)) {
            int currentNum = num;
            int length = 1;

            // STEP 3: Extend the sequence rightward as far as consecutive nums exist
            while (numSet.Contains(currentNum + 1)) {
                currentNum++;   // move to next number in sequence
                length++;       // count it
            }

            // STEP 4: Update global best with this sequence's length
            longest = Math.Max(longest, length);
        }
    }

    return longest;
}
// Time: O(n) — each number is visited at most twice:
//             once in outer foreach, once in inner while (when it's inside a sequence)
// Space: O(n) — HashSet stores all numbers
```

```
TRACE: nums = [0, 3, 7, 2, 5, 8, 4, 6, 0, 1]
═══════════════════════════════════════════════════════════════
  Set = {0, 1, 2, 3, 4, 5, 6, 7, 8}  (note: 0 deduplicated)

  num=0: 0-1=-1 not in set → START
         0→1→2→3→4→5→6→7→8→9? No. length=9 ← longest!

  num=3: 3-1=2 in set → SKIP
  num=7: 7-1=6 in set → SKIP
  ... all others skipped (all are inside the 0..8 sequence)

  Answer: 9 ✅
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** The "only start from sequence beginnings" optimization is what makes this O(n). Without it, every number would trigger a full scan → O(n²). The key question: "Am I the start of a sequence?" = "Is num-1 absent from the set?"

---

# PART 4 — TREE DATA STRUCTURES

---

## Section 12 — Binary Trees

> **🧠 Mental Model: An Org Chart**
>
> A binary tree is like a company org chart — the CEO (root) at top, each person (node) has at most 2 direct reports (left child, right child). To find someone, you start from the CEO and follow the management chain down. You can't jump directly to middle management — you must traverse the hierarchy.

```
BINARY TREE ANATOMY:
═══════════════════════════════════════════════════════════════
                    ┌───┐
                    │ 1 │  ← Root (no parent)
                    └─┬─┘
             ┌────────┴────────┐
           ┌─┴─┐             ┌─┴─┐
           │ 2 │             │ 3 │  ← Internal nodes
           └─┬─┘             └─┬─┘
        ┌────┴────┐            └──┐
      ┌─┴─┐     ┌─┴─┐          ┌─┴─┐
      │ 4 │     │ 5 │          │ 6 │  ← Leaves (no children)
      └───┘     └───┘          └───┘

  Terminology:
  - Height: longest path from root to leaf = 3 (root→2→5 or root→3→6)
  - Depth of node 5: distance from root = 2 (root→2→5)
  - Level: all nodes at same depth. Level 0=[1], Level 1=[2,3], Level 2=[4,5,6]
  - Full binary tree: every node has 0 or 2 children
  - Complete: all levels full except possibly last (filled left to right)
  - Perfect: all internal nodes have 2 children, all leaves at same level
═══════════════════════════════════════════════════════════════

FOUR TRAVERSAL ORDERS:
═══════════════════════════════════════════════════════════════
         1
        / \
       2   3
      / \
     4   5

  InOrder   (L-Root-R): 4, 2, 5, 1, 3   ← gives SORTED order for BST!
  PreOrder  (Root-L-R): 1, 2, 4, 5, 3   ← good for copying/serializing tree
  PostOrder (L-R-Root): 4, 5, 2, 3, 1   ← good for deleting tree (delete children first)
  LevelOrder (BFS):     1, 2, 3, 4, 5   ← level by level, uses queue
═══════════════════════════════════════════════════════════════
```

### TreeNode and Traversals

```csharp
public class TreeNode {
    public int val;
    public TreeNode left, right;
    public TreeNode(int val = 0, TreeNode left = null, TreeNode right = null) {
        this.val = val; this.left = left; this.right = right;
    }
}

// ═══ RECURSIVE TRAVERSALS — elegant but O(h) stack space ═══

// InOrder: Left → Root → Right
void InOrder(TreeNode root, List<int> result) {
    if (root == null) return;           // base case: empty tree
    // STEP 1: Recurse into left subtree first
    InOrder(root.left, result);         // recurse left subtree
    // STEP 2: Visit root node (after left subtree is fully processed)
    result.Add(root.val);               // visit root AFTER left
    // STEP 3: Recurse into right subtree
    InOrder(root.right, result);        // recurse right subtree
}

// PreOrder: Root → Left → Right
void PreOrder(TreeNode root, List<int> result) {
    if (root == null) return;
    // STEP 1: Visit root FIRST (before any children)
    result.Add(root.val);               // visit root FIRST
    // STEP 2: Recurse left, then right
    PreOrder(root.left, result);
    PreOrder(root.right, result);
}

// PostOrder: Left → Right → Root
void PostOrder(TreeNode root, List<int> result) {
    if (root == null) return;
    // STEP 1: Process both children before the root
    PostOrder(root.left, result);
    PostOrder(root.right, result);
    // STEP 2: Visit root LAST (all children already processed)
    result.Add(root.val);               // visit root LAST (after children)
}

// ═══ ITERATIVE INORDER — avoids stack overflow for deep trees ═══
IList<int> InOrderIterative(TreeNode root) {
    var result = new List<int>();
    var stack = new Stack<TreeNode>();
    var curr = root;

    while (curr != null || stack.Count > 0) {
        // STEP 1: Descend as far LEFT as possible, pushing each node
        while (curr != null) {
            stack.Push(curr);
            curr = curr.left;
        }
        // STEP 2: Pop and visit the deepest unvisited left node, then pivot right
        curr = stack.Pop();
        result.Add(curr.val);  // visit
        curr = curr.right;     // switch to right subtree
    }
    return result;
}

// ═══ LEVEL ORDER (BFS) — most common in interviews ═══
IList<IList<int>> LevelOrder(TreeNode root) {
    var result = new List<IList<int>>();
    if (root == null) return result;

    // STEP 1: Seed the queue with root to begin BFS
    var queue = new Queue<TreeNode>();
    queue.Enqueue(root);

    while (queue.Count > 0) {
        // STEP 2: Snapshot the current level's node count BEFORE enqueueing children
        int levelSize = queue.Count;   // SNAPSHOT: how many nodes at this level
        var level = new List<int>();

        // STEP 3: Process exactly levelSize nodes (all at the current level)
        for (int i = 0; i < levelSize; i++) {
            var node = queue.Dequeue();
            level.Add(node.val);
            // STEP 4: Enqueue children — they belong to the NEXT level
            if (node.left != null) queue.Enqueue(node.left);
            if (node.right != null) queue.Enqueue(node.right);
        }
        result.Add(level);
    }
    return result;
}
```

---

### 🔴 Practice Problem: Binary Tree Level Order Traversal (LeetCode #102 — Medium)

**Problem:** Return level-by-level values of a binary tree as a list of lists.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LEVEL ORDER TRAVERSAL                       ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 DFS     │ Recursive DFS tracking  │ O(n) time  │ O(h) sp  ║
║             │ depth → add to level d  │            │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BFS     │ Queue-based level order │ O(n) time  │ O(w) sp  ║
║  (CANONICAL)│ snapshot level size     │            │ w=width  ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: BFS naturally visits nodes level by level (neighbors first).
             Snapshot queue.Count at start of each level to know
             how many nodes belong to the current level.
```

> **🔑 CORE IDEA:** BFS with a queue. At each level, snapshot queue.Count first — that many dequeues belong to the current level before moving to the next.

```
BFS TRACE on tree:
         1
        / \
       2   3
      / \   \
     4   5   6

═══════════════════════════════════════════════════════════════
  INIT: queue=[1]

  LEVEL 0: size=1
    dequeue 1 → level=[1], enqueue 2, 3 → queue=[2,3]
    result=[[1]]

  LEVEL 1: size=2
    dequeue 2 → level=[2], enqueue 4,5 → queue=[3,4,5]
    dequeue 3 → level=[2,3], enqueue 6   → queue=[4,5,6]
    result=[[1],[2,3]]

  LEVEL 2: size=3
    dequeue 4 → level=[4], no children  → queue=[5,6]
    dequeue 5 → level=[4,5], no children → queue=[6]
    dequeue 6 → level=[4,5,6], no children → queue=[]
    result=[[1],[2,3],[4,5,6]]

  queue empty → DONE ✅
═══════════════════════════════════════════════════════════════
```

```csharp
public IList<IList<int>> LevelOrder(TreeNode root) {
    var result = new List<IList<int>>();
    if (root == null) return result;  // edge case: empty tree

    // STEP 1: Initialize BFS queue with the root node
    var queue = new Queue<TreeNode>();
    queue.Enqueue(root);  // start BFS from root

    while (queue.Count > 0) {
        // STEP 2: Snapshot level size BEFORE processing (queue grows as children are added)
        // WHY snapshot size? queue.Count GROWS as we add children.
        // We must capture the count at the START of this level
        // to know when the current level ends and next level begins.
        int levelSize = queue.Count;
        var level = new List<int>();

        // STEP 3: Dequeue exactly levelSize nodes — all belong to the current level
        for (int i = 0; i < levelSize; i++) {  // process exactly this level's nodes
            TreeNode node = queue.Dequeue();
            level.Add(node.val);

            // STEP 4: Enqueue children for the NEXT level's processing
            if (node.left != null) queue.Enqueue(node.left);
            if (node.right != null) queue.Enqueue(node.right);
        }

        // STEP 5: Commit the completed level to the result
        result.Add(level);  // this level is complete
    }

    return result;
}
// Time: O(n) — visit each node exactly once
// Space: O(w) where w = max width of tree (last level can have n/2 nodes → O(n))
```

> **🎯 Key Insight:** The `levelSize = queue.Count` snapshot is the essential BFS technique. Without it, you'd mix nodes from different levels. This pattern directly extends to: "right side view," "average of levels," "zigzag traversal" — all use the same BFS with level snapshot.

---

## Section 13 — Binary Search Trees (BST)

> **🧠 Mental Model: A Dictionary Book**
>
> A BST is like a physical dictionary — every page is sorted, and you always know which direction to go. Too far left? Turn right. Too far right? Turn left. The LEFT subtree is always SMALLER, the RIGHT subtree is always LARGER. This invariant lets you discard half the tree at every step — O(log n) average search.

```
BST INVARIANT — CRITICAL TO REMEMBER:
═══════════════════════════════════════════════════════════════
  For every node X:
    ALL values in LEFT subtree < X.val
    ALL values in RIGHT subtree > X.val

         8          ← root
        / \
       3   10
      / \    \
     1   6    14
        / \   /
       4   7 13

  InOrder traversal → 1,3,4,6,7,8,10,13,14 → SORTED! ✅
  (This is why InOrder of BST gives sorted output)

  Search 6: 6<8 → go left → 6>3 → go right → 6==6 ✓ (O(log n))
  Search 5: 5<8 → left → 5>3 → right → 5<6 → left → 5>4 → right
            → null → NOT FOUND (O(log n))

  UNBALANCED BST (worst case: sorted input):
  1 → 2 → 3 → 4 → 5  (like a linked list!)
  Search becomes O(n) instead of O(log n)
═══════════════════════════════════════════════════════════════
```

### BST Operations

```csharp
// ═══ BST SEARCH ═══
TreeNode Search(TreeNode root, int target) {
    // STEP 1: Base case — null (not found) or exact match
    if (root == null || root.val == target)
        return root;  // base case: not found or exact match

    // STEP 2: Use BST invariant to navigate to the correct subtree
    // WHY left/right split? BST invariant guarantees:
    // target < root.val → must be in left subtree (if it exists)
    // target > root.val → must be in right subtree
    return target < root.val
        ? Search(root.left, target)    // go left
        : Search(root.right, target);  // go right
}

// ═══ BST INSERT ═══
TreeNode Insert(TreeNode root, int val) {
    // STEP 1: Base case — found the correct empty slot, insert here
    if (root == null) return new TreeNode(val);

    // STEP 2: Navigate to the correct position using BST ordering
    if (val < root.val)
        root.left = Insert(root.left, val);   // insert in left subtree
    else if (val > root.val)
        root.right = Insert(root.right, val); // insert in right subtree
    // val == root.val: duplicate, do nothing (BST typically has unique values)

    // STEP 3: Return the unchanged root (structure above insertion point stays the same)
    return root;  // return root unchanged (only a leaf was added)
}

// ═══ BST DELETE (complex — 3 cases) ═══
TreeNode Delete(TreeNode root, int key) {
    // STEP 1: Navigate to the node to delete using BST ordering
    if (root == null) return null;

    if (key < root.val) {
        root.left = Delete(root.left, key);    // search left
    } else if (key > root.val) {
        root.right = Delete(root.right, key);  // search right
    } else {
        // Found node to delete! Handle 3 structural cases:

        // STEP 2a: LEAF node — simply remove by returning null
        if (root.left == null && root.right == null) return null;

        // STEP 2b: ONE child — replace this node with its only child
        if (root.left == null) return root.right;
        if (root.right == null) return root.left;

        // STEP 2c: TWO children — replace value with InOrder successor, delete successor
        // InOrder successor = smallest node in right subtree
        TreeNode successor = root.right;
        while (successor.left != null)
            successor = successor.left;  // go left until no more left

        // STEP 3: Replace deleted node's value with successor, then delete successor
        root.val = successor.val;                        // replace value
        root.right = Delete(root.right, successor.val);  // delete successor
    }
    return root;
}
```

---

### 🔴 Practice Problem: Validate Binary Search Tree (LeetCode #98 — Medium)

**Problem:** Determine if a binary tree is a valid BST.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: VALIDATE BST                                ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 WRONG    │ Only check left<root and │ Fails for  │ O(n)sp  ║
║  APPROACH    │ right>root at each node  │ this case: │         ║
║              │                          │    5        │         ║
║              │                          │   / \       │         ║
║              │                          │  1   4 ←   │         ║
║              │                          │     / \     │         ║
║              │                          │    3   6    │         ║
║              │ 3 < 4 ✓ but 3 < 5 fails! │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 INORDER  │ InOrder traversal should │ O(n) time  │ O(n)sp  ║
║              │ give strictly increasing  │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BOUNDS   │ Pass min/max bounds down │ O(n) time  │ O(h)sp  ║
║  (OPTIMAL)   │ each recursive call      │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Each node must satisfy BOTH its local constraint AND
             ALL ancestor constraints. Pass valid range [min, max]
             down the recursion — tighten bounds at each level.
```

> **🔑 CORE IDEA:** Pass (min, max) bounds into each recursive call. Left subtree tightens the upper bound, right tightens the lower bound. Never just check immediate neighbors.

```
BOUNDS PROPAGATION VISUALIZATION:
═══════════════════════════════════════════════════════════════
  Validate(root=5, min=-∞, max=+∞):
    5 is in (-∞, +∞) ✓
    Validate(left=1, min=-∞, max=5):   ← max tightened to 5
      1 is in (-∞, 5) ✓
      Validate(left=null): true
      Validate(right=null): true
    Validate(right=4, min=5, max=+∞):  ← min tightened to 5
      4 is in (5, +∞)? NO! 4 < 5 ❌ → return false
═══════════════════════════════════════════════════════════════
```

```csharp
public bool IsValidBST(TreeNode root) {
    // STEP 1: Start validation with unbounded range (−∞, +∞) at the root
    // WHY use long instead of int for bounds?
    // Node values can be int.MinValue and int.MaxValue themselves.
    // Using long prevents overflow when comparing at boundaries.
    return Validate(root, long.MinValue, long.MaxValue);
}

bool Validate(TreeNode node, long min, long max) {
    // STEP 2: Base case — empty subtree is always valid
    if (node == null) return true;  // empty tree/subtree is valid

    // STEP 3: Verify current node's value is strictly within the inherited bounds
    // WHY strict inequalities? BST requires strictly less/greater (no duplicates)
    if (node.val <= min || node.val >= max)
        return false;  // violates BST property

    // STEP 4: Recursively validate subtrees with tightened bounds
    // Left subtree: all values must be < node.val (new max = node.val)
    // Right subtree: all values must be > node.val (new min = node.val)
    return Validate(node.left, min, node.val) &&   // tighten max for left
           Validate(node.right, node.val, max);     // tighten min for right
}
// Time: O(n) — visit each node once
// Space: O(h) — recursion stack, O(log n) balanced, O(n) skewed
```

> **🎯 Key Insight:** Don't just check parent-child relationship — check the ENTIRE range constraint from root to current node. The bounds propagation technique is the clean O(n) solution. The wrong approach only checks immediate parent, missing deeper violations.

---

## Section 14 — Heaps & Priority Queues

> **🧠 Mental Model: A Tournament Bracket**
>
> A heap is like a tournament bracket — the winner (min or max) always bubbles to the top. When you remove the winner, the next-best candidate rises to take their place. Inserting a new player? They challenge upward until finding their correct position. The key insight: **you only care about the TOP element**, not the full sorted order.

```
MIN-HEAP STRUCTURE (parent always ≤ children):
═══════════════════════════════════════════════════════════════
         1          ← root (minimum element)
        / \
       3   2
      / \ / \
     7  8 4  5

  STORED AS ARRAY: [1, 3, 2, 7, 8, 4, 5]
  Parent of i: (i-1)/2     Children of i: 2i+1, 2i+2
  index:       0  1  2  3  4  5  6

  HEAPIFY UP (after insert 0):
  Insert 0 at index 6: [1,3,2,7,8,4,5,0]... wait 0 at end
  Actually array after insert: [1,3,2,7,8,4,5, 0]
  0 < parent(3): swap → [1,3,2,0,8,4,5,7]
  0 < parent(1): swap → [1,0,2,3,8,4,5,7]  ← hmm parent at (3-1)/2=1
  Actually let me re-index: 0 inserted at position 7
  parent of 7 = (7-1)/2 = 3 → arr[3]=7, 0<7 swap: [1,3,2,0,8,4,5,7]
  parent of 3 = (3-1)/2 = 1 → arr[1]=3, 0<3 swap: [1,0,2,3,8,4,5,7]
  parent of 1 = (1-1)/2 = 0 → arr[0]=1, 0<1 swap: [0,1,2,3,8,4,5,7]
  parent = none (at root) → DONE

  RESULT: 0 is now at root ✅

  HEAPIFY DOWN (after removing root):
  Remove root (min), put last element at root: [7,3,2,?,8,4,5]
  Wait — replace root with last: [7,1,2,3,8,4,5] → no, after removing 0:
  Put last (7) at root: [7,3,2,3,8,4,5]... simplified:
  7 > min(child1,child2)=min(3,2)=2 → swap with index 2: [2,3,7,...]
  7 > min(child1,child2)=min(4,5)=4 → swap with index 5: [2,3,4,...]
  No more children → DONE (min=2 now at root) ✅
═══════════════════════════════════════════════════════════════
```

### C# PriorityQueue<T,P>

```csharp
// MIN-HEAP (lowest priority number = highest priority = dequeued first)
var minHeap = new PriorityQueue<string, int>();

minHeap.Enqueue("task A", 5);   // element, priority
minHeap.Enqueue("task B", 1);   // priority 1 = most urgent
minHeap.Enqueue("task C", 3);

string next = minHeap.Peek();       // "task B" — O(1)
string done = minHeap.Dequeue();    // "task B" — O(log n) (heapify down)
minHeap.Enqueue("task D", 2);       // O(log n) (heapify up)

// MAX-HEAP: negate priority so smallest (= most negative) = was-largest
var maxHeap = new PriorityQueue<int, int>();
maxHeap.Enqueue(5, -5);    // negate priority to simulate max-heap
maxHeap.Enqueue(3, -3);
maxHeap.Enqueue(8, -8);
int maxVal = maxHeap.Dequeue();  // 8 (was -8, the most negative)

// PATTERN: Find Kth Largest using MIN-HEAP of size k
int FindKthLargest(int[] nums, int k) {
    // STEP 1: Use min-heap to maintain a sliding window of the k largest elements
    var heap = new PriorityQueue<int, int>(); // min-heap

    foreach (int num in nums) {
        // STEP 2: Add every element to the heap
        heap.Enqueue(num, num);          // add to heap
        // STEP 3: If heap exceeds size k, evict the minimum (too small to be top-k)
        if (heap.Count > k)
            heap.Dequeue();              // remove smallest — keep only top k
    }
    // STEP 4: Heap top is the k-th largest (smallest of the k largest)
    return heap.Peek();
}
```

### Complexity Table

| Operation | Min/Max Heap |
|-----------|-------------|
| Insert (Enqueue) | O(log n) |
| Get min/max (Peek) | O(1) |
| Remove min/max (Dequeue) | O(log n) |
| Build heap from array | O(n) |
| Search | O(n) |
| Space | O(n) |

---

### 🔴🔥 Practice Problem: Kth Largest Element (LeetCode #215 — Medium) — MUST SOLVE

**Problem:** Find the kth largest element in an unsorted array (not necessarily distinct).

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: KTH LARGEST ELEMENT                         ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Sort descending, return │ O(n log n) │ O(1) sp  ║
║              │ element at index k-1    │            │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 MIN-HEAP │ Maintain min-heap size k│ O(n log k) │ O(k) sp  ║
║  SIZE K      │ answer = heap top       │            │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 QUICKSEL │ Partition like QuickSort│ O(n) avg   │ O(1) sp  ║
║  (OPTIMAL)   │ only recurse one side   │ O(n²) worst│          ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Min-heap of size k is the practical choice (guaranteed O(n log k)).
             QuickSelect is optimal on average but has worst case O(n²).
             For interviews: heap approach is safer and easier to code correctly.
```

> **🔑 CORE IDEA:** Min-heap of size k: push each element; if size > k, pop the minimum. After all elements, the heap root is the kth largest.

```csharp
// APPROACH 1: Min-Heap of Size k — O(n log k)
public int FindKthLargest(int[] nums, int k) {
    // STEP 1: Initialize min-heap — will hold exactly k largest elements
    // WHY min-heap (not max-heap)? We maintain the k LARGEST elements seen so far.
    // The MINIMUM of those k largest = the kth largest overall.
    // When we see a new element larger than the current min (heap top),
    // it displaces the current minimum → we always keep the k largest.
    var minHeap = new PriorityQueue<int, int>();

    foreach (int num in nums) {
        // STEP 2: Add every element to the heap
        minHeap.Enqueue(num, num);  // element=priority=num (min priority dequeued first)

        // STEP 3: If heap exceeds k elements, evict the current minimum
        // WHY remove when count > k? We only need k elements.
        // The element removed is the SMALLEST so far — it can't be kth largest.
        if (minHeap.Count > k)
            minHeap.Dequeue();  // remove the current minimum (too small to be kth largest)
    }

    // STEP 4: Heap top = smallest of the k largest = the kth largest overall
    return minHeap.Peek();
}
// Time: O(n log k) — n iterations, each O(log k) heap operation
// Space: O(k) — heap size bounded by k

// APPROACH 2: QuickSelect — O(n) average
public int FindKthLargestQuickSelect(int[] nums, int k) {
    // STEP 1: Map "kth largest" to (n-k)th smallest index (0-based from left)
    return QuickSelect(nums, 0, nums.Length - 1, nums.Length - k);
}

int QuickSelect(int[] nums, int left, int right, int targetIdx) {
    // STEP 1: Base case — single element, must be the answer
    if (left == right) return nums[left];

    // STEP 2: Partition around a pivot and get the pivot's final sorted index
    int pivotIdx = Partition(nums, left, right);

    // STEP 3: Recurse only into the half that contains targetIdx
    if (pivotIdx == targetIdx) return nums[pivotIdx];      // found!
    if (targetIdx < pivotIdx) return QuickSelect(nums, left, pivotIdx - 1, targetIdx);
    return QuickSelect(nums, pivotIdx + 1, right, targetIdx);
}

int Partition(int[] nums, int left, int right) {
    // STEP 1: Choose pivot (last element) and set boundary for the "small section"
    int pivot = nums[right]; // use last element as pivot (simple choice for QuickSelect)
    // i = next slot for an element that is <= pivot (the "small section" boundary)
    // After the loop, nums[left..i-1] are all <= pivot, nums[i..right-1] are all > pivot
    int i = left;

    // STEP 2: Partition — move elements ≤ pivot to the left section
    for (int j = left; j < right; j++) {
        if (nums[j] <= pivot) {
            (nums[i], nums[j]) = (nums[j], nums[i]); // move small element to small section
            i++;  // expand the small section boundary
        }
        // nums[j] > pivot: leave it in the large section (i doesn't move)
    }
    // STEP 3: Place pivot in its final sorted position between small and large sections
    (nums[i], nums[right]) = (nums[right], nums[i]);
    return i;
}
```

```
TRACE: nums=[3,2,1,5,6,4], k=2
═══════════════════════════════════════════════════════════════
  Looking for 2nd largest = element at sorted-desc index 1 = 5

  Min-heap approach:
  Process 3: heap=[3] size=1
  Process 2: heap=[2,3] size=2
  Process 1: heap=[1,3,2]→remove 1→heap=[2,3] size=2 (1<heap min, remove it)
  Process 5: heap=[2,3,5]→remove 2→heap=[3,5] size=2
  Process 6: heap=[3,5,6]→remove 3→heap=[5,6] size=2
  Process 4: heap=[4,5,6]→remove 4→heap=[5,6] size=2
  Peek = 5 ✅ (2nd largest is 5)
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Min-heap of size k is the go-to pattern for "Top K" problems. The heap always maintains the k largest seen so far, with the kth largest sitting at the top (min). This same pattern solves: "Top K Frequent Elements," "K Closest Points," "Find Median from Data Stream."

---

## Section 15 — Tries (Prefix Trees)

> **🧠 Mental Model: Autocomplete on Your Phone**
>
> A Trie is like the autocomplete feature on your phone. Each time you type a letter, the phone narrows down suggestions. The Trie stores all words as paths from root to leaf — each edge represents one character. Shared prefixes share the same path. "apple" and "apply" share "appl" as a common root path.

```
TRIE STRUCTURE for words: ["apple", "app", "apply", "apt"]
═══════════════════════════════════════════════════════════════
                root
                 │
                 a
                 │
                 p ←─── "ap" is shared prefix for all words
                / \
               p   t
               │   │
               l   *  ← "apt" ends here (isEnd=true)
              / \
             e   y
             │   │
             *   *  ← "apple" and "apply" both end here

  * = isEnd marker (this path forms a complete word)

  SPACE: Each node stores up to 26 child pointers (for lowercase a-z)
  A trie with n words of avg length m: O(n×m) space worst case,
  but often much less due to shared prefixes.
═══════════════════════════════════════════════════════════════
```

### Trie Implementation

```csharp
public class TrieNode {
    // WHY array of 26? For lowercase a-z alphabet, index by char-'a'
    // Alternative: Dictionary<char,TrieNode> for Unicode/arbitrary chars
    public TrieNode[] children = new TrieNode[26];
    public bool isEnd = false;  // true if a word ends at this node
}

public class Trie {
    private TrieNode root = new TrieNode();

    // INSERT: O(m) where m = word length
    public void Insert(string word) {
        // STEP 1: Start at the root and walk each character's path
        TrieNode curr = root;
        foreach (char c in word) {
            int idx = c - 'a';  // 'a'→0, 'b'→1, ..., 'z'→25
            // STEP 2: Create a new node if this character path doesn't exist yet
            // WHY null check? Create node only if this path doesn't exist yet
            if (curr.children[idx] == null)
                curr.children[idx] = new TrieNode();
            curr = curr.children[idx];  // move down the trie
        }
        // STEP 3: Mark the final node as a word-end
        curr.isEnd = true;  // mark the end of this word
    }

    // SEARCH: does exactly this word exist? O(m)
    public bool Search(string word) {
        // STEP 1: Walk the trie character-by-character
        TrieNode curr = root;
        foreach (char c in word) {
            int idx = c - 'a';
            // STEP 2: Return false if any character in the path is missing
            if (curr.children[idx] == null)
                return false;  // character path doesn't exist
            curr = curr.children[idx];
        }
        // STEP 3: Confirm the path ends at a word (not just a prefix)
        return curr.isEnd;  // WHY check isEnd? "app" shouldn't match if only "apple" inserted
    }

    // STARTS WITH: does any word have this prefix? O(m)
    public bool StartsWith(string prefix) {
        // STEP 1: Walk the trie along the prefix path
        TrieNode curr = root;
        foreach (char c in prefix) {
            int idx = c - 'a';
            // STEP 2: Return false if the prefix path is broken
            if (curr.children[idx] == null)
                return false;  // prefix path doesn't exist
            curr = curr.children[idx];
        }
        // STEP 3: Prefix exists as a path (no isEnd check needed)
        return true;  // WHY no isEnd check? Prefix doesn't need to be a complete word
    }
}
```

---

### 🔴 Practice Problem: Implement Trie (LeetCode #208 — Medium)

**Problem:** Implement `insert`, `search`, and `startsWith` for a Trie data structure.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: IMPLEMENT TRIE                              ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 HASHSET  │ Store words in HashSet  │ O(m) insert│ O(n×m)  ║
║              │ — no prefix support     │ O(m) search│         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 TRIE     │ Character-by-character  │ O(m) all   │ O(n×m)  ║
║  (CANONICAL) │ tree — enables prefix   │ ops        │ worst   ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Each TrieNode has 26 child pointers + isEnd flag. Insert/search walk char-by-char, creating nodes on insert and returning false on missing node during search.

```
TRACE: insert("apple"), insert("app"), search("apple"), startsWith("ap")
═══════════════════════════════════════════════════════════════
  insert("apple"):
    root→a→p→p→l→e (isEnd=true at e)

  insert("app"):
    root→a→p→p (isEnd=true at second p)  ← shares path with "apple"

  search("apple"):
    Walk: a→p→p→l→e → isEnd=true → true ✅

  search("app"):
    Walk: a→p→p → isEnd=true → true ✅

  search("ap"):
    Walk: a→p → isEnd=false → false ✅

  startsWith("ap"):
    Walk: a→p → path exists → true ✅
═══════════════════════════════════════════════════════════════
```

The Trie implementation above (in the section header) IS the solution — see the `Trie` class. Time: O(m) for all operations, Space: O(n×m) total.

> **🎯 Key Insight:** Trie's superpower is **prefix-based operations** in O(m) time. HashSet can't do `startsWith` efficiently. Use Trie when you need: autocomplete, prefix search, word dictionary with wildcards, IP routing tables.

---

## Section 16 — Advanced Trees

> **🧠 Mental Model: Self-Balancing Acrobat**
>
> An AVL/Red-Black tree is like an acrobat that constantly rebalances. After every insertion or deletion, the tree checks if it's lopsided and performs "rotations" to stay balanced — ensuring O(log n) operations always hold. The Segment Tree is a "divide-and-conquer reporting" tree — split the array in half recursively, each node stores a range summary.

```
SEGMENT TREE for array [1, 3, 5, 7, 9, 11]:
═══════════════════════════════════════════════════════════════
         [0..5] sum=36
           /       \
    [0..2] sum=9   [3..5] sum=27
    /    \           /    \
 [0..1]  [2]      [3..4]  [5]
 sum=4   5         sum=16  11
  / \             /    \
[0] [1]          [3]   [4]
 1    3            7     9

  Query sum [1..4]: combine [1..2]=[3+5]=8, [3..4]=[7+9]=16 → 24
  Update arr[2] = 6: update [0..5],[0..2],[2] nodes only (log n updates)
═══════════════════════════════════════════════════════════════
```

### Segment Tree Implementation

```csharp
public class SegmentTree {
    private int[] tree;  // internal array representation
    private int n;

    public SegmentTree(int[] arr) {
        n = arr.Length;
        // WHY 4*n? In a segment tree stored as an array, the tree can have
        // up to 4n nodes in the worst case (when n is not a power of 2).
        // This is a safe upper bound to avoid index-out-of-range errors.
        tree = new int[4 * n];
        Build(arr, 0, 0, n - 1); // node=0 is root, covers range [0, n-1]
    }

    // Build segment tree from bottom up: O(n)
    // node = current tree array index (root=0)
    // start..end = array range this node covers
    void Build(int[] arr, int node, int start, int end) {
        // STEP 1: Base case — leaf node stores a single array element
        if (start == end) {
            tree[node] = arr[start]; // leaf node stores single element
            return;
        }
        // STEP 2: Recursively build both child subtrees
        int mid = (start + end) / 2;
        // WHY 2*node+1 and 2*node+2?
        // Segment tree uses 1-indexed heap-style layout:
        //   left child of node i  = 2*i + 1
        //   right child of node i = 2*i + 2
        //   parent of node i      = (i-1) / 2
        Build(arr, 2*node+1, start, mid);    // build left child (covers start..mid)
        Build(arr, 2*node+2, mid+1, end);    // build right child (covers mid+1..end)
        // STEP 3: Internal node stores the aggregate (sum) of both children
        tree[node] = tree[2*node+1] + tree[2*node+2]; // internal node = sum of children
    }

    // Point update: change arr[idx] to val — O(log n)
    public void Update(int idx, int val) => Update(0, 0, n-1, idx, val);

    void Update(int node, int start, int end, int idx, int val) {
        // STEP 1: Base case — leaf for arr[idx] found; update it
        if (start == end) {
            tree[node] = val;  // reached the leaf for arr[idx] — update it
            return;
        }
        // STEP 2: Navigate to the correct leaf (idx in left or right half)
        int mid = (start + end) / 2;
        if (idx <= mid) Update(2*node+1, start, mid, idx, val);   // idx is in left half
        else Update(2*node+2, mid+1, end, idx, val);              // idx is in right half
        // STEP 3: Recompute this internal node's sum from its updated children
        tree[node] = tree[2*node+1] + tree[2*node+2];
    }

    // Range sum query: sum of arr[l..r] — O(log n)
    public int Query(int l, int r) => Query(0, 0, n-1, l, r);

    int Query(int node, int start, int end, int l, int r) {
        // STEP 1: Completely outside query range — contribute 0
        if (r < start || end < l) return 0;
        // STEP 2: Completely inside query range — return stored aggregate directly
        if (l <= start && end <= r) return tree[node];
        // STEP 3: Partial overlap — split at midpoint and sum both halves
        int mid = (start + end) / 2;
        return Query(2*node+1, start, mid, l, r) +   // sum from left child
               Query(2*node+2, mid+1, end, l, r);    // sum from right child
    }
}
```

---

### 🔴 Practice Problem: Range Sum Query - Mutable (LeetCode #307 — Medium)

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: RANGE SUM QUERY MUTABLE                     ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 NAIVE    │ Recompute sum each time │ O(n) query │ O(1) sp  ║
║              │                         │ O(1) update│          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 PREFIX   │ Prefix sums, rebuild on │ O(1) query │ O(n) sp  ║
║  SUM         │ every update            │ O(n) update│          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 SEGMENT  │ Segment tree            │ O(log n)   │ O(n) sp  ║
║  TREE        │ both query and update   │ both ops   │          ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Segment tree: each node stores range sum. Update walks one root-to-leaf path O(log n). Query splits at midpoint and sums O(log n) segments.

The `SegmentTree` class above implements the solution. Use it as `NumArray`:

```csharp
public class NumArray {
    private SegmentTree seg;
    public NumArray(int[] nums) => seg = new SegmentTree(nums);
    public void Update(int index, int val) => seg.Update(index, val);
    public int SumRange(int left, int right) => seg.Query(left, right);
}
// Time: O(n) build, O(log n) update and query — Space: O(n)
```

> **🎯 Key Insight:** Segment tree is the go-to for **range queries with updates**. Without updates → prefix sum (O(1) query). With updates → segment tree (O(log n) both). Fenwick tree (Binary Indexed Tree) achieves the same with simpler code but harder intuition.

---

# PART 5 — GRAPH DATA STRUCTURES

---

## Section 17 — Graph Fundamentals

> **🧠 Mental Model: A Road Network**
>
> A graph is like a city road network. Cities are nodes (vertices). Roads are edges. Some roads are one-way (directed graph). Roads have distance (weighted graph). You can reach city B from city A if there's a path — but finding the SHORTEST path requires algorithms like Dijkstra. The key insight: graphs model ANY relationship between entities.

```
GRAPH REPRESENTATIONS:
═══════════════════════════════════════════════════════════════
  Graph with 5 nodes, edges: 0-1, 0-2, 1-3, 2-3, 3-4

  ADJACENCY MATRIX (good for dense graphs):
       0  1  2  3  4
    0 [0, 1, 1, 0, 0]
    1 [1, 0, 0, 1, 0]
    2 [1, 0, 0, 1, 0]
    3 [0, 1, 1, 0, 1]
    4 [0, 0, 0, 1, 0]
  Space: O(V²). Edge check: O(1). List neighbors: O(V).

  ADJACENCY LIST (preferred — good for sparse graphs):
    0: [1, 2]
    1: [0, 3]
    2: [0, 3]
    3: [1, 2, 4]
    4: [3]
  Space: O(V+E). Edge check: O(degree). List neighbors: O(degree).

  In C#: Dictionary<int, List<int>> or List<List<int>>
═══════════════════════════════════════════════════════════════

GRAPH TYPES:
═══════════════════════════════════════════════════════════════
  Undirected: edges go both ways (social network friends)
  Directed (Digraph): edges have direction (Twitter follows)
  Weighted: edges have weights (road distances)
  DAG: Directed Acyclic Graph (no cycles) — used in topological sort
  Bipartite: nodes split in 2 groups, edges only cross groups
  Tree: connected graph with V-1 edges and no cycles
═══════════════════════════════════════════════════════════════
```

### Building a Graph in C#

```csharp
// ADJACENCY LIST — most common in interviews
int V = 5; // number of vertices
var adj = new List<List<int>>();
for (int i = 0; i < V; i++)
    adj.Add(new List<int>());  // initialize each vertex's neighbor list

// Add undirected edge 0-1
void AddEdge(int u, int v) {
    adj[u].Add(v);  // u → v
    adj[v].Add(u);  // v → u (undirected)
}

// WEIGHTED GRAPH: store (neighbor, weight) pairs
var weightedAdj = new List<List<(int node, int weight)>>();

// FROM EDGE LIST (common input format in problems):
int[][] edges = { new[]{0,1}, new[]{0,2}, new[]{1,3} };
var graph = new Dictionary<int, List<int>>();
foreach (int[] e in edges) {
    if (!graph.ContainsKey(e[0])) graph[e[0]] = new List<int>();
    if (!graph.ContainsKey(e[1])) graph[e[1]] = new List<int>();
    graph[e[0]].Add(e[1]);
    graph[e[1]].Add(e[0]);  // remove for directed graph
}
```

---

### 🔴🔥 Practice Problem: Number of Islands (LeetCode #200 — Medium) — MUST SOLVE

**Problem:** Given 2D grid of '1's (land) and '0's (water), count number of islands.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: NUMBER OF ISLANDS                           ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Find each '1', BFS/DFS  │ O(m×n)    │ O(m×n)  ║
║  (also opt.) │ to mark entire island   │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DFS/BFS  │ For each unvisited '1', │ O(m×n)    │ O(m×n)  ║
║  (CANONICAL) │ DFS to sink entire isl. │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 UNION    │ Union-Find to connect   │ O(m×n×α)  │ O(m×n)  ║
║  FIND        │ adjacent land cells     │ ≈O(m×n)   │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Treat the grid as a graph. Each '1' cell is a node.
             Adjacent '1' cells share edges. Count connected components.
             DFS from each unvisited '1' marks its entire island.
```

> **🔑 CORE IDEA:** For each unvisited '1', flood-fill (DFS/BFS) marking all connected '1's as visited. Number of flood-fills = number of islands.

```
VISUALIZATION:
  Grid:        After DFS from (0,0):    After DFS from (0,4):
  1 1 1 0 0    2 2 2 0 0                2 2 2 0 3
  1 1 0 0 0    2 2 0 0 0                2 2 0 0 0
  0 0 0 1 1    0 0 0 1 1  ← unvisited  0 0 0 2 2
  0 0 0 0 0    0 0 0 0 0                0 0 0 0 0

  Count=1 → Count=2 → Count=3 (after DFS from (2,3))
  Answer = 3 islands
```

```csharp
public int NumIslands(char[][] grid) {
    if (grid == null || grid.Length == 0) return 0;

    int totalRows = grid.Length, totalCols = grid[0].Length;
    int islandCount = 0;

    // STEP 1: Scan every cell; for each unvisited land cell, start a DFS flood-fill
    for (int row = 0; row < totalRows; row++) {
        for (int col = 0; col < totalCols; col++) {
            if (grid[row][col] == '1') {
                // STEP 2: New island found — increment count and sink the whole island
                islandCount++;             // each '1' we find without prior DFS = new island
                SinkIsland(grid, row, col);  // flood-fill: mark all connected land as visited
            }
        }
    }
    return islandCount;
}

// WHY 'SinkIsland'? More descriptive than 'DFS' — describes the "mark as visited" strategy
void SinkIsland(char[][] grid, int row, int col) {
    // STEP 1: Boundary and water check — stop if out of bounds or already sunk/water
    // WHY bounds check? Prevent IndexOutOfRangeException on grid edges
    // WHY check != '1'? '0' = water, already-sunk land — no island to explore
    if (row < 0 || row >= grid.Length || col < 0 || col >= grid[0].Length || grid[row][col] != '1')
        return;

    // STEP 2: Sink this land cell to prevent revisiting (in-place visited marker)
    // WHY '0' not a separate visited array? Saves O(m×n) extra space; '0' already means "water"
    grid[row][col] = '0';

    // STEP 3: Recursively flood-fill all 4 cardinal neighbors
    SinkIsland(grid, row - 1, col);  // up
    SinkIsland(grid, row + 1, col);  // down
    SinkIsland(grid, row, col - 1);  // left
    SinkIsland(grid, row, col + 1);  // right
}
// Time: O(m×n) — each cell visited at most once
// Space: O(m×n) — recursion stack worst case (all land, deep DFS)
```

```
TRACE: grid = [["1","1","0"],["0","1","0"],["0","0","1"]]
═══════════════════════════════════════════════════════════════
  (0,0)='1' → count=1 → DFS(0,0):
    mark (0,0)='0', recurse: up OOB, down=(1,0)='0',
    left OOB, right=(0,1)='1' → DFS(0,1):
      mark (0,1)='0', recurse: right=(0,2)='0', down=(1,1)='1' → DFS(1,1):
        mark (1,1)='0', all neighbors '0' or OOB → done

  (0,1)='0' skip, (0,2)='0' skip
  (1,0)='0' skip, (1,1)='0' skip (marked), (1,2)='0' skip
  (2,0)='0' skip, (2,1)='0' skip
  (2,2)='1' → count=2 → DFS(2,2): mark '0', no '1' neighbors

  Answer: 2 ✅
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Grid problems are graph problems in disguise. The "sink the island" DFS (marking visited cells as '0' in-place) is cleaner than maintaining a separate visited array. This connected components counting pattern appears in dozens of problems: "Max Area of Island," "Pacific Atlantic Water Flow," "Word Search."

---

## Section 18 — Graph Traversals: DFS & BFS

> **🧠 Mental Model: DFS = Exploring a Maze / BFS = Ripples in Water**
>
> **DFS**: Like exploring a maze — go as deep as possible down one path, hit a dead end, backtrack, try another path. Uses a **stack** (explicit or call stack).
>
> **BFS**: Like dropping a stone in water — ripples spread outward in all directions equally. Explores all neighbors at distance 1, then distance 2, etc. Uses a **queue**. BFS guarantees **shortest path** in unweighted graphs.

```
DFS vs BFS COMPARISON:
═══════════════════════════════════════════════════════════════
  Graph:  1 — 2 — 4
          |   |
          3 — 5

  DFS from 1 (stack-based, exploring order depends on adj list):
  Visit 1 → push neighbors [2,3] → visit 3 → push neighbors [1,5]
  → 1 visited → visit 5 → push [2,3] → 2,3 visited → visit 2
  → push [1,4,5] → all visited except 4 → visit 4
  Order: 1, 3, 5, 2, 4 (or similar — depends on order)

  BFS from 1 (queue-based):
  Queue: [1] → visit 1, enqueue [2,3]
  Queue: [2,3] → visit 2, enqueue [4,5]; visit 3, enqueue [5]
  Queue: [4,5,5] → visit 4; visit 5; skip 5 (visited)
  Order: 1, 2, 3, 4, 5 (level by level)

  BFS GUARANTEES shortest path in unweighted graphs!
  DFS is better for: cycle detection, topological sort, all paths
═══════════════════════════════════════════════════════════════
```

### DFS & BFS Templates

```csharp
// ═══ DFS — RECURSIVE (most intuitive) ═══
void DFSRecursive(Dictionary<int, List<int>> graph, int node, HashSet<int> visited) {
    // STEP 1: Mark node visited and process it
    visited.Add(node);
    Console.Write(node + " ");  // process node

    // STEP 2: Recurse into all unvisited neighbors
    foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>())) {
        if (!visited.Contains(neighbor))  // only visit unvisited
            DFSRecursive(graph, neighbor, visited);
    }
}

// ═══ DFS — ITERATIVE (avoids stack overflow on deep graphs) ═══
void DFSIterative(Dictionary<int, List<int>> graph, int start) {
    // STEP 1: Initialize visited set and push start node onto explicit stack
    var visited = new HashSet<int>();
    var stack = new Stack<int>();
    stack.Push(start);

    while (stack.Count > 0) {
        // STEP 2: Pop next node; skip if already visited
        int node = stack.Pop();
        if (visited.Contains(node)) continue;  // already processed
        visited.Add(node);
        Console.Write(node + " ");

        // STEP 3: Push unvisited neighbors for future exploration
        // Push neighbors in reverse order to maintain left-to-right visit order
        foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>()))
            if (!visited.Contains(neighbor))
                stack.Push(neighbor);
    }
}

// ═══ BFS — ITERATIVE (always use queue) ═══
void BFS(Dictionary<int, List<int>> graph, int start) {
    // STEP 1: Initialize queue with start node; mark start visited immediately
    var visited = new HashSet<int> { start };
    var queue = new Queue<int>();
    queue.Enqueue(start);

    while (queue.Count > 0) {
        // STEP 2: Process front node
        int node = queue.Dequeue();
        Console.Write(node + " ");

        // STEP 3: Enqueue unvisited neighbors and mark them visited NOW
        foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>())) {
            // WHY add to visited when ENQUEUING (not dequeuing)?
            // Prevents adding the same node to queue multiple times
            if (!visited.Contains(neighbor)) {
                visited.Add(neighbor);
                queue.Enqueue(neighbor);
            }
        }
    }
}

// ═══ BFS SHORTEST PATH (unweighted) ═══
int BFSShortestPath(Dictionary<int, List<int>> graph, int start, int end) {
    // STEP 1: Seed queue with (start, distance=0)
    var visited = new HashSet<int> { start };
    var queue = new Queue<(int node, int dist)>();
    queue.Enqueue((start, 0));

    while (queue.Count > 0) {
        // STEP 2: Dequeue; if we reached destination, return accumulated distance
        var (node, dist) = queue.Dequeue();
        if (node == end) return dist;  // found! return distance

        // STEP 3: Enqueue neighbors with incremented distance
        foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>())) {
            if (!visited.Contains(neighbor)) {
                visited.Add(neighbor);
                queue.Enqueue((neighbor, dist + 1));  // increment distance
            }
        }
    }
    return -1;  // unreachable
}
```

---

### 🔴🔥 Practice Problem: Course Schedule (LeetCode #207 — Medium) — MUST SOLVE

**Problem:** There are `n` courses. Some courses have prerequisites. Can you finish all courses?

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: COURSE SCHEDULE (CYCLE DETECTION)           ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Check all possible      │ O(V+E)×V  │ O(V+E)  ║
║              │ orderings               │           │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DFS CYCLE│ 3-state DFS coloring:   │ O(V+E)    │ O(V+E)  ║
║  DETECTION   │ white/gray/black        │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 TOPO SORT│ Kahn's BFS: if all      │ O(V+E)    │ O(V+E)  ║
║  (BFS KAHN'S)│ nodes processed→no cycle│            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: The problem reduces to: "Does this directed graph have a cycle?"
             If cycle exists → impossible to finish courses.
             3-color DFS: white=unvisited, gray=in-progress, black=done.
             If you revisit a GRAY node → cycle found!
```

> **🔑 CORE IDEA:** DFS with 3 states: 0=unvisited, 1=in-progress, 2=done. If you reach a node with state=1 during DFS, you've found a cycle → impossible.

```
3-COLOR DFS VISUALIZATION: 0→1→2→0 (cycle) vs 0→1→2 (no cycle)
═══════════════════════════════════════════════════════════════
  CYCLE: 0 requires 1, 1 requires 2, 2 requires 0

  DFS(0): color[0]=gray
    DFS(1): color[1]=gray
      DFS(2): color[2]=gray
        neighbor=0: color[0]==gray → CYCLE DETECTED! ❌

  NO CYCLE: 0 requires 1, 1 requires 2, 2 requires nothing

  DFS(0): color[0]=gray
    DFS(1): color[1]=gray
      DFS(2): color[2]=gray
        no neighbors → color[2]=black, return false
      color[1]=black, return false
    color[0]=black, return false
  No cycle ✅
═══════════════════════════════════════════════════════════════
```

```csharp
public bool CanFinish(int numCourses, int[][] prerequisites) {
    // STEP 1: Build directed adjacency list — edge direction: prerequisite → dependent
    // WHY graph[pre[1]].Add(pre[0]) and not the reverse?
    // prerequisite pair [a, b] means "b must come before a" (b is prereq of a)
    // We add edge b→a: "b unlocks a". A cycle in this graph means a deadlock.
    var graph = new List<List<int>>();
    for (int courseIndex = 0; courseIndex < numCourses; courseIndex++)
        graph.Add(new List<int>());
    foreach (int[] prereqPair in prerequisites)
        graph[prereqPair[1]].Add(prereqPair[0]); // prereqPair[1] must come before prereqPair[0]

    // STEP 2: Initialize 3-state coloring array (0=unvisited, 1=in-progress, 2=done)
    int[] state = new int[numCourses];

    // STEP 3: Run cycle-detection DFS from every unvisited node (handles disconnected graphs)
    // WHY loop all nodes? Graph may be disconnected — some courses may have no shared prerequisites
    for (int courseId = 0; courseId < numCourses; courseId++)
        if (state[courseId] == 0 && HasCycle(graph, state, courseId))
            return false;

    return true;
}

bool HasCycle(List<List<int>> graph, int[] state, int node) {
    // STEP 1: Mark node as IN-PROGRESS (gray) — currently on the DFS call stack
    state[node] = 1;  // mark as IN-PROGRESS (gray) — we're currently exploring this path

    foreach (int neighbor in graph[node]) {
        // STEP 2: If neighbor is IN-PROGRESS (gray) → back edge → CYCLE found
        if (state[neighbor] == 1)  // found a node we're currently exploring = BACK EDGE = CYCLE
            return true;
        // STEP 3: If unvisited, recurse; propagate cycle detection upward
        if (state[neighbor] == 0 && HasCycle(graph, state, neighbor))
            return true;  // cycle found deeper in the recursion
        // state[neighbor] == 2: already fully processed, safe to skip
    }

    // STEP 4: All descendants explored with no cycle — mark DONE (black)
    state[node] = 2;  // mark as DONE (black) — no cycle through this node
    return false;
}
// Time: O(V+E) — visit each node and edge once
// Space: O(V+E) — adjacency list + O(V) state + O(V) call stack
```

> **🎯 Key Insight:** Cycle detection in directed graphs uses 3 states (not 2). A "visited" boolean fails — it can't distinguish between "finished exploring" and "currently on the path." The gray state (in-progress) is what detects back edges → cycles.

---

## Section 19 — Shortest Path Algorithms

> **🧠 Mental Model: GPS Navigation**
>
> Dijkstra's algorithm is like a GPS that always expands to the nearest unvisited city. It's **greedy** — always process the closest known city next. This greedy choice works because weights are non-negative (you can't make a path shorter by taking a detour). Bellman-Ford handles negative weights by relaxing ALL edges repeatedly.

```
DIJKSTRA VISUALIZATION: find shortest from node 0
═══════════════════════════════════════════════════════════════
  Graph:    0 ——4—— 1
            |       |
            8      -3  ← Dijkstra fails with negative! Use Bellman-Ford
            |       |
            3 ——2—— 2

  With all positive weights:
  0——4——1, 0——8——3, 1——5——2, 3——2——2

  Init: dist=[0,∞,∞,∞], PQ=[(0,0)]  # (dist,node)
  Pop (0,0): update neighbors: dist[1]=4, dist[3]=8 → PQ=[(4,1),(8,3)]
  Pop (4,1): update neighbors: dist[2]=4+5=9 → PQ=[(8,3),(9,2)]
  Pop (8,3): update neighbors: dist[2]=min(9,8+2)=10→no update
  Pop (9,2): no neighbors to relax
  Final dist=[0,4,9,8] ✅
═══════════════════════════════════════════════════════════════
```

### Dijkstra's Algorithm

```csharp
public int[] Dijkstra(int[][] graph, int src, int V) {
    // STEP 1: Initialize distances to infinity; source node has distance 0
    int[] dist = new int[V];
    Array.Fill(dist, int.MaxValue / 2);  // WHY /2? Prevent overflow when adding edge weights
    dist[src] = 0;

    // STEP 2: Seed min-heap with the source node at distance 0
    var pq = new PriorityQueue<int, int>();  // element=node, priority=distance
    pq.Enqueue(src, 0);

    while (pq.Count > 0) {
        // STEP 3: Extract the node with the current smallest known distance
        int u = pq.Dequeue();  // node with minimum current distance

        // STEP 4: Relax all edges from u — update neighbor distances if shorter path found
        // "Relaxation" = check if going through u gives a shorter path to neighbor
        for (int v = 0; v < V; v++) {
            if (graph[u][v] != 0) {  // edge exists
                int newDist = dist[u] + graph[u][v];
                if (newDist < dist[v]) {  // found shorter path!
                    // STEP 5: Update distance and re-enqueue with improved priority
                    dist[v] = newDist;
                    pq.Enqueue(v, newDist);  // re-add with better distance
                }
            }
        }
    }
    return dist;
}
// Time: O((V+E) log V) with priority queue
// Space: O(V) for dist array + O(V) for priority queue
```

---

### 🔴 Practice Problem: Network Delay Time (LeetCode #743 — Medium)

**Problem:** Network of `n` nodes. Given travel times for directed edges, find time for all nodes to receive signal from node `k`.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: NETWORK DELAY TIME                          ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ BFS/DFS for each pair   │ O(V²+VE)  │ O(V+E)  ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DIJKSTRA │ SSSP from source k      │ O(E log V)│ O(V+E)  ║
║  (OPTIMAL)   │ answer = max of dist[]  │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Dijkstra from source k: min-heap of (distance, node). Always relax the nearest unvisited node. Answer = max of all shortest distances (or -1 if any unreachable).

```csharp
public int NetworkDelayTime(int[][] times, int n, int k) {
    // STEP 1: Build adjacency list from edge list
    var graph = new Dictionary<int, List<(int to, int w)>>();
    foreach (int[] t in times) {
        if (!graph.ContainsKey(t[0])) graph[t[0]] = new List<(int, int)>();
        graph[t[0]].Add((t[1], t[2]));
    }

    // STEP 2: Run Dijkstra from source k — min-heap of (node, distance)
    var dist = new Dictionary<int, int>();
    var pq = new PriorityQueue<int, int>(); // (node, distance)
    pq.Enqueue(k, 0);

    while (pq.Count > 0) {
        // STEP 3: Extract nearest unfinalized node; skip if already finalized
        pq.TryDequeue(out int u, out int d);
        if (dist.ContainsKey(u)) continue;  // already finalized
        dist[u] = d;  // finalize shortest distance to u

        // STEP 4: Enqueue all unfinalized neighbors with updated distances
        if (graph.ContainsKey(u)) {
            foreach (var (v, w) in graph[u]) {
                if (!dist.ContainsKey(v))
                    pq.Enqueue(v, d + w);  // explore neighbor
            }
        }
    }

    // STEP 5: Verify all n nodes were reached; return max distance (last node to receive signal)
    if (dist.Count != n) return -1;
    return dist.Values.Max();
}
// Time: O(E log V), Space: O(V+E)
```

> **🎯 Key Insight:** "Time for ALL nodes to receive" = shortest path to ALL nodes = single-source shortest path. Then answer = max of all shortest paths (slowest path determines when ALL nodes have signal). This SSSP + max pattern is classic.

---

## Section 20 — Minimum Spanning Trees

> **🧠 Mental Model: Cheapest Way to Connect Cities**
>
> Given n cities and possible roads between them (each with a cost), find the cheapest set of roads that connects ALL cities. An MST connects all n vertices using exactly n-1 edges with minimum total weight and no cycles.

```
MST ALGORITHMS:
═══════════════════════════════════════════════════════════════
  KRUSKAL'S:  Sort edges by weight → add edge if it doesn't create cycle
              Uses Union-Find to detect cycles in O(α) ≈ O(1)
              Best for: sparse graphs (few edges)

  PRIM'S:     Start from any node → greedily add cheapest edge
              connecting current tree to new node
              Uses priority queue → O(E log V)
              Best for: dense graphs (many edges)
═══════════════════════════════════════════════════════════════

KRUSKAL'S VISUALIZATION:
  Nodes: 0,1,2,3  Edges by weight: (0-1,1),(0-2,3),(1-2,2),(1-3,4),(2-3,5)

  Sort: [(0-1,1),(1-2,2),(0-2,3),(1-3,4),(2-3,5)]

  Add (0-1,1): {0,1} not connected → ADD. MST=[0-1]. Cost=1
  Add (1-2,2): {1,2} not connected → ADD. MST=[0-1,1-2]. Cost=3
  Add (0-2,3): {0,2} already connected! → SKIP (cycle)
  Add (1-3,4): {1,3} not connected → ADD. MST=[0-1,1-2,1-3]. Cost=7
  Done! (V-1=3 edges added)
```

---

### 🔴 Practice Problem: Min Cost to Connect All Points (LeetCode #1584 — Medium)

**Problem:** Given array of points, return minimum cost to connect all points. Cost = Manhattan distance.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: CONNECT ALL POINTS                          ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Try all spanning trees  │ O(n^n)    │ O(n²)   ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 KRUSKAL  │ Sort all O(n²) edges,   │ O(n²logn) │ O(n²)   ║
║              │ Union-Find              │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 PRIM'S   │ Priority queue, no      │ O(n²logn) │ O(n)    ║
║  (OPTIMAL)   │ need to pre-build edges │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Prim's MST: start from node 0, use a min-heap of (cost, node). Greedily pick cheapest edge to any unvisited node. No need to pre-enumerate all edges.

```csharp
public int MinCostConnectPoints(int[][] points) {
    int n = points.Length;
    // STEP 1: Initialize Prim's — minCost[i] = cheapest edge to add point i to MST
    int[] minCost = new int[n];
    Array.Fill(minCost, int.MaxValue);
    minCost[0] = 0;  // start from point 0, cost 0
    bool[] inMST = new bool[n];  // track which points are already in MST
    int totalCost = 0;

    for (int iter = 0; iter < n; iter++) {
        // STEP 2: Greedily pick the unvisited point with the cheapest MST-edge
        int u = -1;
        for (int i = 0; i < n; i++)
            if (!inMST[i] && (u == -1 || minCost[i] < minCost[u]))
                u = i;

        // STEP 3: Add chosen point to MST and accumulate its edge cost
        inMST[u] = true;    // add u to MST
        totalCost += minCost[u];  // add the edge cost

        // STEP 4: Update minCost for all non-MST points using newly added point u
        for (int v = 0; v < n; v++) {
            if (!inMST[v]) {
                // Manhattan distance between u and v
                int dist = Math.Abs(points[u][0] - points[v][0]) +
                           Math.Abs(points[u][1] - points[v][1]);
                minCost[v] = Math.Min(minCost[v], dist);  // update if cheaper
            }
        }
    }
    return totalCost;
}
// Time: O(n²) — n iterations, each O(n) scan; better than Kruskal for dense graphs
// Space: O(n) — minCost and inMST arrays
```

> **🎯 Key Insight:** Prim's algorithm is ideal here because the graph is complete (every pair of points has an edge). We don't need to pre-build all O(n²) edges — we can compute edge weights on-the-fly. Kruskal's would need to store all edges, using O(n²) space.

---

## Section 21 — Advanced Graphs (Topological Sort, Union-Find)

> **🧠 Mental Model: Union-Find = Partisan Groups / Topo Sort = Dependency Order**
>
> **Union-Find**: Like social groups that merge. Each group has a "leader" (root). Merging groups = connecting their leaders. Checking if two people are in the same group = checking if they have the same leader.
>
> **Topological Sort**: Like getting dressed — you must put on socks BEFORE shoes. Given dependency constraints, find a valid ordering of tasks.

```
UNION-FIND OPERATIONS:
═══════════════════════════════════════════════════════════════
  parent = [0, 1, 2, 3, 4]  (each node is its own parent initially)

  Union(0, 1):  parent[1] = 0  → groups: {0,1}, {2}, {3}, {4}
  Union(1, 2):  parent[2] = root(1) = 0  → groups: {0,1,2}, {3}, {4}
  Find(2): 2→parent[2]=0→parent[0]=0 (root) = 0

  WITH PATH COMPRESSION: during Find, make every node point directly to root
  Find(2): path 2→0, set parent[2]=0 (already is 0 in this case)

  RANK UNION: always attach smaller tree under larger tree root
  → keeps tree height O(log n) → Find is O(log n) → α(n) with both optimizations
═══════════════════════════════════════════════════════════════
```

### Union-Find (Disjoint Set Union)

```csharp
public class UnionFind {
    private int[] parent, rank;

    public UnionFind(int n) {
        // STEP 1: Initialize — every node is its own root (n separate components)
        parent = new int[n];
        rank = new int[n];
        for (int i = 0; i < n; i++) parent[i] = i;  // each node is its own root
    }

    // Find root with PATH COMPRESSION — O(α(n)) amortized ≈ O(1)
    public int Find(int x) {
        // STEP 1: Walk to root, and on the way back, point every node directly to root
        // WHY recursive? Path compression: on the way back up,
        // set every node's parent directly to root → flatten the tree
        if (parent[x] != x)
            parent[x] = Find(parent[x]);  // path compression: point directly to root
        return parent[x];
    }

    // Union by rank — O(α(n)) amortized
    public bool Union(int x, int y) {
        // STEP 1: Find roots; if same root, already connected
        int rx = Find(x), ry = Find(y);
        if (rx == ry) return false;  // already in same set

        // STEP 2: Attach smaller-rank tree under larger-rank tree
        // WHY rank-based union? Attach smaller tree under larger tree
        // to keep height logarithmic → prevents degenerate linear chains
        if (rank[rx] < rank[ry]) (rx, ry) = (ry, rx); // ensure rx has higher rank
        parent[ry] = rx;            // attach ry's tree under rx
        // STEP 3: Only increment rank when two equal-rank trees merge
        if (rank[rx] == rank[ry]) rank[rx]++;

        return true;  // successfully merged two different sets
    }

    public bool Connected(int x, int y) => Find(x) == Find(y);
}
```

---

### 🔴 Practice Problem: Redundant Connection (LeetCode #684 — Medium)

**Problem:** In an undirected graph that started as a tree, one extra edge was added. Find the redundant edge.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: REDUNDANT CONNECTION                         ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Remove each edge, check │ O(E×(V+E))│ O(V+E)  ║
║              │ if graph still connected│            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 UNION    │ Add edges one by one;   │ O(E×α(V)) │ O(V)    ║
║  FIND        │ first edge connecting   │ ≈O(E)     │         ║
║  (OPTIMAL)   │ already-connected nodes │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Process edges in order. Before adding each edge, check if
             both endpoints are ALREADY connected (same component).
             If yes → this edge creates a cycle → it's REDUNDANT.
```

> **🔑 CORE IDEA:** Union-Find: process edges one by one. The first edge whose endpoints already have the same root (are already connected) is the redundant edge.

```csharp
public int[] FindRedundantConnection(int[][] edges) {
    // STEP 1: Initialize Union-Find with n+1 nodes (1-indexed)
    int n = edges.Length;
    var uf = new UnionFind(n + 1);  // +1 because nodes are 1-indexed

    foreach (int[] edge in edges) {
        int fromNode = edge[0], toNode = edge[1];  // WHY fromNode/toNode? Clearer than u/v for directed edge intent
        // STEP 2: Try to union endpoints; if they're already in the same component → redundant edge
        // WHY check before union? If fromNode and toNode are already connected,
        // adding this edge creates a cycle → it is the redundant (extra) edge
        if (!uf.Union(fromNode, toNode))
            return edge;  // this edge connects two already-connected nodes — it's the redundant one
    }

    return Array.Empty<int>(); // should never reach here per problem constraints
}
// Time: O(E × α(V)) ≈ O(E) — α is inverse Ackermann, essentially constant
// Space: O(V) — Union-Find arrays
```

> **🎯 Key Insight:** Union-Find is THE data structure for "are these two elements in the same group?" queries. It answers this in near-O(1) and is perfect for: detecting cycles in undirected graphs, Kruskal's MST, network connectivity problems, and any "merge groups" problem.

---

# PART 6 — SORTING ALGORITHMS

---

## Section 22 — O(n²) Sorts

> **🧠 Mental Model: Card Game Sorting**
>
> **Bubble Sort**: Like repeatedly swapping adjacent misplaced cards. Simple but inefficient — O(n²) swaps in worst case.
> **Selection Sort**: Like always picking the smallest remaining card and placing it next. Simple selection, but O(n²) always.
> **Insertion Sort**: Like sorting cards in your hand — take one card at a time and insert it in the right position among already-sorted cards. **Best for nearly-sorted data — O(n) best case!**

```
INSERTION SORT VISUALIZATION: [5, 3, 1, 4, 2]
═══════════════════════════════════════════════════════════════
  [5| 3  1  4  2]  → insert 3: [3  5| 1  4  2]
  [3  5| 1  4  2]  → insert 1: [1  3  5| 4  2]
  [1  3  5| 4  2]  → insert 4: [1  3  4  5| 2]
  [1  3  4  5| 2]  → insert 2: [1  2  3  4  5]

  | = boundary between sorted and unsorted portions
  Each insertion: shift elements right until correct position found
═══════════════════════════════════════════════════════════════
```

```csharp
// INSERTION SORT — O(n²) worst, O(n) best (nearly sorted), O(1) space
void InsertionSort(int[] arr) {
    for (int i = 1; i < arr.Length; i++) {
        // STEP 1: Pick the current element (the "card to insert")
        int key = arr[i];   // the card we're inserting
        int j = i - 1;

        // STEP 2: Shift all larger elements one position right to make room
        // WHY go right? Make room for key in its correct position
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];  // shift right
            j--;
        }
        // STEP 3: Place key in its correct sorted position
        arr[j + 1] = key;  // insert key in its correct position
    }
}

// BUBBLE SORT — O(n²) worst/avg, O(n) best with optimization
void BubbleSort(int[] arr) {
    int n = arr.Length;
    for (int i = 0; i < n - 1; i++) {
        bool swapped = false;
        // STEP 1: Bubble the largest unsorted element to its correct position
        for (int j = 0; j < n - i - 1; j++) {  // n-i-1: last i elements already sorted
            if (arr[j] > arr[j + 1]) {
                (arr[j], arr[j + 1]) = (arr[j + 1], arr[j]);
                swapped = true;
            }
        }
        // STEP 2: Early exit if no swaps occurred (array is already sorted)
        if (!swapped) break;  // early exit: array already sorted!
    }
}
```

---

### 🔴 Practice Problem: Sort Colors (LeetCode #75 — Medium) — Dutch National Flag

**Problem:** Sort array of 0s, 1s, 2s in-place in one pass.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: SORT COLORS                                  ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Use any sort: O(n log n) │ O(n log n)│ O(1)    ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 COUNT    │ Count 0s,1s,2s, fill    │ O(n) 2pass│ O(1)    ║
║              │ array (2 passes)        │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DUTCH    │ 3-pointer: lo,mid,hi    │ O(n) 1pass│ O(1)    ║
║  FLAG        │ single pass             │            │         ║
╚══════════════════════════════════════════════════════════════════╝

DUTCH NATIONAL FLAG (3-way partition):
  lo: next position for 0
  mid: current element being examined
  hi: next position for 2

  Invariant: [0..lo-1]=0s, [lo..mid-1]=1s, [mid..hi]=unsorted, [hi+1..n-1]=2s
```

> **🔑 CORE IDEA:** Dutch National Flag with 3 pointers (lo, mid, hi). Swap 0→lo, 2→hi. Only advance mid when nums[mid]==1 or after a 0-swap; never after a 2-swap.

```
TRACE: [2,0,2,1,1,0]
════════════════════════════════════════════════════════════
  lo=0,mid=0,hi=5
  arr[0]=2: swap mid(2) with hi(0)→[0,0,2,1,1,2], hi=4
  arr[0]=0: swap lo(0) with mid(0)→[0,0,2,1,1,2], lo=1,mid=1
  arr[1]=0: swap lo(0) with mid(0)→[0,0,2,1,1,2], lo=2,mid=2
  arr[2]=2: swap mid(2) with hi(1)→[0,0,1,1,2,2], hi=3
  arr[2]=1: mid=3
  arr[3]=1: mid=4
  mid>hi → DONE: [0,0,1,1,2,2] ✅
```

```csharp
public void SortColors(int[] nums) {
    // STEP 1: Initialize 3-pointer invariant: lo=next 0 slot, hi=next 2 slot, mid=examiner
    int lo = 0, mid = 0, hi = nums.Length - 1;

    while (mid <= hi) {
        if (nums[mid] == 0) {
            // STEP 2: 0 belongs at front — swap to lo, advance both lo and mid
            (nums[lo], nums[mid]) = (nums[mid], nums[lo]);
            lo++; mid++;  // WHY advance mid? We know nums[lo] was 1 (in sorted region)
        } else if (nums[mid] == 2) {
            // STEP 3: 2 belongs at back — swap to hi, decrease hi only (don't advance mid)
            (nums[mid], nums[hi]) = (nums[hi], nums[mid]);
            hi--;  // WHY NOT advance mid? nums[hi] might be 0,1, or 2 — need to re-examine
        } else {
            // STEP 4: 1 is already in the correct middle region — just advance mid
            mid++;  // 1 is in correct region [lo..hi], just advance
        }
    }
}
// Time: O(n) — single pass, each element processed at most twice
// Space: O(1) — in-place with 3 pointers
```

> **🎯 Key Insight:** Dutch National Flag is the archetype for 3-way partition. The critical insight: when swapping from the front (lo), you can advance mid because the swapped value is already known to be valid (1). When swapping from the back (hi), you DON'T advance mid because the swapped value is unknown.

---

## Section 23 — O(n log n) Sorts

> **🧠 Mental Model: Divide-and-Conquer Filing System**
>
> **Merge Sort**: Recursively split the array in half, sort each half, merge. Like sorting two piles of papers separately then interleaving them in order. **Stable, O(n log n) guaranteed, but O(n) extra space.**
> **Quick Sort**: Pick a pivot, partition smaller elements left and larger right, recurse on each side. Like sorting a filing cabinet around a middle folder. **O(n log n) average, O(1) extra space, O(n²) worst case.**

```
MERGE SORT TRACE: [38,27,43,3,9,82,10]
═══════════════════════════════════════════════════════════════
  Split:    [38,27,43,3]    [9,82,10]
  Split:  [38,27] [43,3]  [9,82] [10]
  Split: [38][27][43][3] [9][82][10]
  Merge: [27,38] [3,43]  [9,82] [10]
  Merge: [3,27,38,43]    [9,10,82]
  Merge: [3,9,10,27,38,43,82] ✅

  Each level: O(n) work × O(log n) levels = O(n log n)
═══════════════════════════════════════════════════════════════
```

```csharp
// MERGE SORT — O(n log n) time, O(n) space, STABLE
void MergeSort(int[] arr, int left, int right) {
    // STEP 1: Base case — 0 or 1 elements are already sorted
    if (left >= right) return;

    // STEP 2: Find midpoint and recursively sort both halves
    int mid = left + (right - left) / 2;  // avoid overflow vs (left+right)/2
    MergeSort(arr, left, mid);    // sort left half
    MergeSort(arr, mid+1, right); // sort right half
    // STEP 3: Merge the two sorted halves back together
    Merge(arr, left, mid, right); // merge the sorted halves
}

void Merge(int[] arr, int left, int mid, int right) {
    // STEP 1: Copy both halves to temporary arrays
    int[] L = arr[left..(mid+1)];    // C# range syntax
    int[] R = arr[(mid+1)..(right+1)];

    // STEP 2: Merge by comparing front elements of both halves
    int i = 0, j = 0, k = left;
    while (i < L.Length && j < R.Length) {
        // WHY <=? Stability: when equal, take from LEFT array first
        // (preserves original relative order of equal elements)
        if (L[i] <= R[j]) arr[k++] = L[i++];
        else arr[k++] = R[j++];
    }
    // STEP 3: Drain any remaining elements from either half
    while (i < L.Length) arr[k++] = L[i++];  // remaining left elements
    while (j < R.Length) arr[k++] = R[j++];  // remaining right elements
}

// QUICK SORT — O(n log n) avg, O(n²) worst, O(1) space, UNSTABLE
void QuickSort(int[] arr, int left, int right) {
    if (left >= right) return;
    // STEP 1: Partition around pivot, get pivot's final sorted index
    int pi = Partition(arr, left, right);
    // STEP 2: Recursively sort left and right of the pivot
    QuickSort(arr, left, pi - 1);   // sort left of pivot
    QuickSort(arr, pi + 1, right);  // sort right of pivot
}

int Partition(int[] arr, int left, int right) {
    // STEP 1: Randomize pivot to avoid O(n²) on sorted input
    // WHY random pivot? Avoids O(n²) worst case on already-sorted input.
    int randIdx = new Random().Next(left, right + 1);
    (arr[randIdx], arr[right]) = (arr[right], arr[randIdx]); // move pivot to end temporarily

    int pivot = arr[right];
    // STEP 2: i = right boundary of "small section" (elements ≤ pivot)
    int i = left - 1;  // starts before window — small section is empty initially

    // STEP 3: Scan j across unsorted region; move ≤ pivot elements to small section
    for (int j = left; j < right; j++) {
        if (arr[j] <= pivot) {
            i++;
            (arr[i], arr[j]) = (arr[j], arr[i]);
        }
        // if arr[j] > pivot: it belongs in large section — just let j advance
    }
    // STEP 4: Place pivot between small and large sections — its final sorted position
    (arr[i+1], arr[right]) = (arr[right], arr[i+1]);
    return i + 1;  // pivot now sits at its correct index in the sorted array
}
```

---

### 🔴 Practice Problem: Sort List (LeetCode #148 — Medium)

**Problem:** Sort a linked list in O(n log n) time and O(1) space.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: SORT LINKED LIST                            ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 COPY     │ Copy to array, sort,    │ O(n log n)│ O(n) sp  ║
║  TO ARRAY    │ rebuild linked list     │            │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 INSERT   │ Insertion sort on LL    │ O(n²)     │ O(1) sp  ║
║  SORT LL     │ (good for nearly sorted)│            │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 MERGE    │ Merge sort on LL:       │ O(n log n)│ O(log n) ║
║  SORT LL     │ find mid, split, merge  │            │ stack sp ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Merge sort: find midpoint (fast/slow pointers), split, recursively sort halves, merge. O(1) extra space because merge re-links pointers in-place.

```csharp
public ListNode SortList(ListNode head) {
    // BASE CASE: 0 or 1 nodes — already sorted
    if (head == null || head.next == null) return head;

    // STEP 1: Find middle using fast/slow pointers
    // WHY this specific middle? We want LEFT half to be shorter or equal
    ListNode slow = head, fast = head.next; // WHY head.next? Ensures left half ≤ right half
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    // slow is now at the end of the LEFT half

    // STEP 2: Split the list at middle
    ListNode right = slow.next;  // right half starts at slow.next
    slow.next = null;            // cut the connection — now two separate lists

    // STEP 3: Recursively sort both halves
    ListNode leftSorted = SortList(head);   // sort left half
    ListNode rightSorted = SortList(right); // sort right half

    // STEP 4: Merge the two sorted halves
    return Merge(leftSorted, rightSorted);
}

ListNode Merge(ListNode l1, ListNode l2) {
    // STEP 1: Create dummy head to simplify edge cases for list construction
    var dummy = new ListNode(0);  // dummy head to simplify edge cases
    var curr = dummy;

    // STEP 2: Compare front nodes; attach smaller one and advance that pointer
    while (l1 != null && l2 != null) {
        if (l1.val <= l2.val) {  // take smaller value
            curr.next = l1;
            l1 = l1.next;
        } else {
            curr.next = l2;
            l2 = l2.next;
        }
        curr = curr.next;
    }
    // STEP 3: Attach remaining nodes from whichever list is not yet exhausted
    curr.next = l1 ?? l2;  // attach remaining nodes (one list is exhausted)
    return dummy.next;
}
// Time: O(n log n) — T(n) = 2T(n/2) + O(n) → Master Theorem → O(n log n)
// Space: O(log n) — recursion stack depth
```

> **🎯 Key Insight:** Merge sort is the ONLY practical O(n log n) sort for linked lists. Quick sort on linked lists is poor (no random access for pivot selection, poor cache performance). The key sub-skills: find middle (fast/slow), split list (slow.next=null), merge two sorted lists.

---

## Section 24 — O(n) Sorts

> **🧠 Mental Model: Mailroom Sorting**
>
> Counting Sort is like a mailroom with pigeonholes (one per zip code). Instead of comparing letters, you drop each letter in its pigeonhole → collect in order. No comparisons needed — hence beating the O(n log n) comparison lower bound. Works ONLY on integer data within a known range.

```
COUNTING SORT VISUALIZATION: [4, 2, 2, 8, 3, 3, 1]
═══════════════════════════════════════════════════════════════
  Range: 1 to 8
  Count array: [0,1,2,2,1,0,0,0,1]
               idx 0 1 2 3 4 5 6 7 8
  (count[4]=1 means '4' appears once)

  Prefix sum:  [0,1,3,5,6,6,6,6,7]
  (prefix[4]=6 means '4' should end at position 6 in output)

  Build output: [1,2,2,3,3,4,8]
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Maximum Gap (LeetCode #164 — Hard)

**Problem:** After sorting, find maximum gap between successive elements. Must be O(n) time and space.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: MAXIMUM GAP                                  ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 SORT    │ Sort, scan for max gap   │ O(n log n) │ O(1)    ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BUCKET  │ Pigeonhole principle:    │ O(n) time  │ O(n) sp ║
║  SORT       │ answer can't be within  │            │         ║
║  (OPTIMAL)  │ same bucket             │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT (Pigeonhole): n numbers have n-1 gaps. Spread = max-min.
             Average gap = (max-min)/(n-1). Max gap ≥ average gap.
             Use n-1 buckets of size avg_gap. The max gap MUST cross bucket boundaries!
             So only compare adjacent buckets' max-min values.
```

> **🔑 CORE IDEA:** Pigeonhole: max gap ≥ (max−min)/(n−1). Place n nums into ⌊n−1⌋ buckets; max gap must cross a bucket boundary, so only compare bucket boundaries.

```csharp
public int MaximumGap(int[] nums) {
    if (nums.Length < 2) return 0;
    int n = nums.Length;
    int min = nums.Min(), max = nums.Max();
    if (min == max) return 0;

    // STEP 1: Compute bucket size and count using pigeonhole principle
    // Bucket size: ceiling of average gap ensures at least n-1 buckets
    int bucketSize = Math.Max(1, (max - min) / (n - 1));
    int bucketCount = (max - min) / bucketSize + 1;

    // STEP 2: Allocate and initialize per-bucket min/max trackers
    // Each bucket stores [min, max] of values that fall in it
    int[] bucketMin = new int[bucketCount];
    int[] bucketMax = new int[bucketCount];
    Array.Fill(bucketMin, int.MaxValue);
    Array.Fill(bucketMax, int.MinValue);

    // STEP 3: Distribute each number into its corresponding bucket
    foreach (int num in nums) {
        int bi = (num - min) / bucketSize;  // which bucket does this number go in?
        bucketMin[bi] = Math.Min(bucketMin[bi], num);
        bucketMax[bi] = Math.Max(bucketMax[bi], num);
    }

    // STEP 4: Scan adjacent non-empty buckets and compute max cross-bucket gap
    // Max gap = max of (next bucket min - prev bucket max) across adjacent non-empty buckets
    int maxGap = 0, prevMax = min;
    for (int i = 0; i < bucketCount; i++) {
        if (bucketMin[i] == int.MaxValue) continue;  // empty bucket — skip
        maxGap = Math.Max(maxGap, bucketMin[i] - prevMax);
        prevMax = bucketMax[i];
    }
    return maxGap;
}
// Time: O(n), Space: O(n)
```

> **🎯 Key Insight:** The pigeonhole/bucket insight is non-obvious. The max gap must span between two different buckets (not within one). So comparing only bucket-boundary values gives the answer in O(n). This is an elegant problem that requires insight rather than brute force.

---

## Section 25 — .NET Sorting APIs

> **🧠 Mental Model: Language Built-in Tools**
>
> C# provides powerful, optimized sorting APIs. `Array.Sort` uses IntroSort (hybrid of QuickSort, HeapSort, InsertionSort) — O(n log n) worst case. `List.Sort` is the same. LINQ `OrderBy` creates a new sorted sequence using stable sort.

```csharp
// ARRAY.SORT — in-place, O(n log n), unstable
int[] arr = { 3, 1, 4, 1, 5 };
Array.Sort(arr);                            // ascending: [1,1,3,4,5]
Array.Sort(arr, (a, b) => b - a);          // descending: [5,4,3,1,1]
Array.Sort(arr, 1, 3);                     // sort arr[1..3] only

// SORT STRINGS by length, then alphabetically
string[] words = { "banana", "apple", "fig", "kiwi" };
Array.Sort(words, (a, b) => a.Length != b.Length
    ? a.Length.CompareTo(b.Length)  // sort by length first
    : string.Compare(a, b));         // then alphabetically

// SORT OBJECTS — use IComparer<T>
class Person { public string Name; public int Age; }
var people = new Person[] { ... };
Array.Sort(people, Comparer<Person>.Create((a, b) => a.Age - b.Age));

// LIST.SORT — same as Array.Sort for lists
var list = new List<int> { 3, 1, 4 };
list.Sort();                    // [1,3,4]
list.Sort((a, b) => b - a);     // [4,3,1] descending

// LINQ ORDERBY — creates NEW sorted sequence, stable sort
var sorted = arr.OrderBy(x => x).ToArray();           // ascending
var sortedDesc = arr.OrderByDescending(x => x).ToArray(); // descending
var sortedMulti = words.OrderBy(w => w.Length).ThenBy(w => w).ToArray();

// SORTEDDICTIONARY / SORTEDSET — always sorted
var sd = new SortedDictionary<int, string>();
sd[3] = "c"; sd[1] = "a"; sd[2] = "b";
// Iteration: 1→a, 2→b, 3→c (always sorted by key)
```

---

### 🔴 Practice Problem: Largest Number (LeetCode #179 — Medium)

**Problem:** Given list of non-negative integers, arrange them to form the largest number.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LARGEST NUMBER                              ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 WRONG    │ Sort numerically descend│ Fails: 9 vs 90         ║
║  APPROACH    │ (9,90,..→909 but 990 is │ 990 > 909!             ║
║              │ better)                 │                         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 CUSTOM   │ Sort by concatenation:  │ O(n log n × m)         ║
║  COMPARATOR  │ if a+b > b+a: a first   │ m = avg digit count    ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Custom sort comparator: compare strings a+b vs b+a. If a+b > b+a lexicographically, a comes first. Edge case: all zeros → return "0".

```csharp
public string LargestNumber(int[] nums) {
    // STEP 1: Convert integers to strings to enable concatenation comparison
    string[] strs = nums.Select(n => n.ToString()).ToArray();

    // STEP 2: Sort using custom comparator — a before b if (a+b) > (b+a)
    // WHY custom comparator? Sort by which concatenation is LARGER
    // "9" vs "90": compare "990" (9 first) vs "909" (90 first) → "990" wins → 9 comes first
    Array.Sort(strs, (a, b) => string.Compare(b + a, a + b)); // b+a > a+b → b first

    // STEP 3: Handle edge case where all digits are zero
    // Edge case: all zeros → result should be "0" not "000..."
    if (strs[0] == "0") return "0";

    // STEP 4: Concatenate sorted strings to form the largest number
    return string.Concat(strs);
}
// Time: O(n log n × m) where m = max digits per number
// Space: O(n) for string array
```

> **🎯 Key Insight:** Custom comparators unlock powerful sorting. The key: define what "comes before" means. For largest number: a comes before b if (a+b) > (b+a) as strings. The transitivity of this comparison makes it a valid total order.

---

# PART 7 — SEARCHING ALGORITHMS

---

## Section 26 — Linear Search & Variants

> **🧠 Mental Model: Searching a Messy Room**
>
> Linear search is like searching a messy room with no organization — you check every spot until you find what you need. O(n) worst case. But sometimes messy rooms have patterns: peaks (highest point), valleys, rotations — these allow smarter searches even without full sorting.

---

### 🔴 Practice Problem: Find Peak Element (LeetCode #162 — Medium)

**Problem:** Find a peak element (element greater than its neighbors). Return any peak's index.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: FIND PEAK ELEMENT                           ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 LINEAR   │ Scan for first element  │ O(n)      │ O(1) sp  ║
║              │ where arr[i]>arr[i+1]   │            │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BINARY   │ If arr[mid]<arr[mid+1], │ O(log n)  │ O(1) sp  ║
║  SEARCH      │ peak is to the right    │            │          ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: If arr[mid] < arr[mid+1], there MUST be a peak on the right
             (array values go up at mid, and eventually reach array boundary).
             Binary search can eliminate half the search space each step.
```

> **🔑 CORE IDEA:** Binary search on slope: if arr[mid] < arr[mid+1], a peak exists in the right half; otherwise search left half (mid included). Converges to a peak.

```csharp
public int FindPeakElement(int[] nums) {
    // STEP 1: Set up binary search boundaries
    int left = 0, right = nums.Length - 1;

    // STEP 2: Binary search on slope — narrow to peak by comparing mid to its right neighbor
    while (left < right) {
        int mid = left + (right - left) / 2;

        if (nums[mid] < nums[mid + 1]) {
            // STEP 3: Slope goes up → peak must exist to the right
            // WHY go right? The slope is going UP toward right.
            // A peak must exist at mid+1 or further right.
            left = mid + 1;
        } else {
            // STEP 4: Slope goes down (or flat) → mid itself or left contains a peak
            // WHY go left (including mid)? nums[mid] >= nums[mid+1]
            // Either mid IS a peak, or a peak exists to its left.
            right = mid;  // WHY not mid-1? mid itself might be the peak!
        }
    }
    // STEP 5: Convergence — left == right points to a peak
    return left;  // left == right == peak index
}
// Time: O(log n), Space: O(1)
```

---

## Section 27 — Binary Search (Classic + Advanced)

> **🧠 Mental Model: The Hot/Cold Game**
>
> Binary search is like the "hot/cold" guessing game — each guess eliminates HALF the remaining search space. After k guesses, you've eliminated all but 1/2^k possibilities. With n=1,000,000, you find the answer in just 20 guesses. The KEY requirement: **the array must be monotonic** (sorted, or have a property that allows halving).

```
BINARY SEARCH — THE TEMPLATE:
═══════════════════════════════════════════════════════════════
  Sorted array: [1, 3, 5, 7, 9, 11, 13]  target=7

  left=0, right=6
  mid=3: arr[3]=7 == target → FOUND at index 3 ✅

  target=6:
  left=0, right=6, mid=3: arr[3]=7 > 6 → right=2
  left=0, right=2, mid=1: arr[1]=3 < 6 → left=2
  left=2, right=2, mid=2: arr[2]=5 < 6 → left=3
  left=3 > right=2 → NOT FOUND (-1)

  INVARIANT: target, if it exists, is always in [left, right]
  LOOP CONDITION: left <= right (search space not empty)
  MID CALCULATION: left + (right-left)/2 (prevents overflow)
═══════════════════════════════════════════════════════════════
```

### Binary Search Variants

```csharp
// ═══ CLASSIC BINARY SEARCH ═══
int BinarySearch(int[] arr, int target) {
    // STEP 1: Set boundaries to cover the entire array
    int left = 0, right = arr.Length - 1;
    // STEP 2: Narrow search space by half each iteration
    while (left <= right) {
        int mid = left + (right - left) / 2;  // WHY this formula? Prevents integer overflow
        // STEP 3: Check mid — return, go right, or go left
        if (arr[mid] == target) return mid;
        if (arr[mid] < target) left = mid + 1;   // target in right half
        else right = mid - 1;                     // target in left half
    }
    return -1;  // not found
}

// ═══ LOWER BOUND (first position where arr[i] >= target) ═══
// KEY USE: "find first occurrence", "count elements >= x"
int LowerBound(int[] arr, int target) {
    // STEP 1: Use half-open range [0, arr.Length] so sentinel answer is valid
    int left = 0, right = arr.Length;  // WHY arr.Length (not -1)? Answer might be arr.Length
    // STEP 2: Bias right boundary left (keep mid) when arr[mid] >= target
    while (left < right) {             // WHY strict <? right=arr.Length is a valid (sentinel) answer
        int mid = left + (right - left) / 2;
        if (arr[mid] < target) left = mid + 1;  // arr[mid] too small → go right
        else right = mid;                         // arr[mid] >= target → go left (keep mid)
    }
    return left;  // first position where arr[i] >= target
}

// ═══ UPPER BOUND (first position where arr[i] > target) ═══
// KEY USE: "find last occurrence" (upperBound - 1), "count elements <= x"
int UpperBound(int[] arr, int target) {
    // STEP 1: Use half-open range; bias right boundary left when arr[mid] > target
    int left = 0, right = arr.Length;
    // STEP 2: Shift left boundary right when arr[mid] <= target
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] <= target) left = mid + 1;  // arr[mid] <= target → go right
        else right = mid;                          // arr[mid] > target → go left
    }
    return left;  // first position where arr[i] > target
}
// Count of target in sorted array: UpperBound(arr,t) - LowerBound(arr,t)

// ═══ BINARY SEARCH ON ANSWER (powerful generalization) ═══
// When: "find minimum/maximum X such that condition(X) is true"
// Example: "find minimum capacity to ship packages in D days"
// WHY 'lo'/'hi' instead of 'left'/'right'?
//   Convention: left/right = array indices; lo/hi = answer-space bounds.
//   lo = smallest possible answer; hi = largest possible answer.
//   They are NOT array indices — they represent candidate values being tested.
int BinarySearchOnAnswer(int lo, int hi, Func<int, bool> feasible) {
    // STEP 1: Binary search over the answer space [lo..hi] to find the minimum feasible value
    // WHY lo < hi (not <=)? We converge to the single crossing point; loop exits when lo==hi
    while (lo < hi) {
        int mid = lo + (hi - lo) / 2;  // candidate answer to test
        // STEP 2: If mid is feasible, search left half (maybe a smaller answer works too)
        // If not feasible, search right half (need a larger answer)
        if (feasible(mid)) hi = mid;      // mid works → try smaller (keep mid in range)
        else lo = mid + 1;                // mid doesn't work → minimum must be higher
    }
    return lo;  // lo == hi: the minimum feasible value in the answer space
}
```

---

### 🔴🔥 Practice Problem: Search in Rotated Sorted Array (LeetCode #33 — Medium) — MUST SOLVE

**Problem:** Array was sorted, then rotated at an unknown pivot. Search for target in O(log n).

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: SEARCH IN ROTATED SORTED ARRAY              ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 LINEAR   │ Linear scan O(n)        │ O(n)      │ O(1) sp  ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 FIND     │ Find pivot then binary  │ O(log n)  │ O(1) sp  ║
║  PIVOT FIRST │ search in correct half  │ 2 passes  │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 ONE PASS │ Modified binary search: │ O(log n)  │ O(1) sp  ║
║  (OPTIMAL)   │ one half always sorted  │ 1 pass    │          ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: In a rotated array, one half is ALWAYS sorted.
             Left half sorted if arr[left] <= arr[mid]
             Right half sorted otherwise
             Use the sorted half to decide which half contains target.
```

> **🔑 CORE IDEA:** One half is always sorted. Determine which half, check if target falls in that range; if yes search there, else search the other half.

```
VISUALIZATION: [4,5,6,7,0,1,2], target=0
═══════════════════════════════════════════════════════════════
  left=0,right=6: mid=3, arr[3]=7
  arr[left]=4 <= arr[mid]=7 → LEFT HALF [4,5,6,7] is sorted
  target=0: is 0 in [4..7]? No → search right: left=4

  left=4,right=6: mid=5, arr[5]=1
  arr[left]=0 <= arr[mid]=1 → LEFT HALF [0,1] is sorted
  target=0: is 0 in [0..1]? Yes → search left: right=5

  left=4,right=5: mid=4, arr[4]=0 == target → return 4 ✅
═══════════════════════════════════════════════════════════════
```

```csharp
public int Search(int[] nums, int target) {
    // STEP 1: Standard binary search boundaries
    int left = 0, right = nums.Length - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;
        // STEP 2: Found target — return immediately
        if (nums[mid] == target) return mid;

        // STEP 3: Determine which half is sorted (one half always is in rotated array)
        // DETERMINE which half is sorted
        if (nums[left] <= nums[mid]) {
            // STEP 4: Left half is sorted — check if target falls in its range
            // LEFT half [left..mid] is sorted (no rotation in this half)
            // Check if target falls within the sorted left half's range
            if (nums[left] <= target && target < nums[mid])
                right = mid - 1;  // target must be in left half
            else
                left = mid + 1;   // target is in right half (contains rotation)
        } else {
            // STEP 5: Right half is sorted — check if target falls in its range
            // RIGHT half [mid..right] is sorted
            if (nums[mid] < target && target <= nums[right])
                left = mid + 1;   // target must be in right half
            else
                right = mid - 1;  // target is in left half (contains rotation)
        }
    }
    return -1;  // not found
}
// Time: O(log n) — halve search space each iteration
// Space: O(1)
```

> **🎯 Key Insight:** The key observation for all rotated array problems: **at least one half of the array around any midpoint is always sorted**. Use this to determine which half to search. Check if the target falls within the sorted half's range → if yes, go there; if no, go to the other half.

---

## Section 28 — Interpolation & Exponential Search

> **🧠 Mental Model: Phone Book Search**
>
> Binary search always checks the middle. But if you're looking for a name starting with 'Z' in a phone book, you'd open near the END, not the middle. Interpolation search does exactly this — estimates position based on value distribution.

```csharp
// INTERPOLATION SEARCH — O(log log n) average for uniform distribution
int InterpolationSearch(int[] arr, int target) {
    // STEP 1: Guard — target must be within the current [low, high] range
    int low = 0, high = arr.Length - 1;
    while (low <= high && target >= arr[low] && target <= arr[high]) {
        if (low == high) return arr[low] == target ? low : -1;

        // STEP 2: Estimate probe position proportionally based on value distribution
        // Estimate position proportionally (not just middle)
        // WHY this formula? If values are uniformly distributed,
        // target is approximately at (target-arr[low])/(arr[high]-arr[low]) fraction
        int pos = low + (int)((long)(target - arr[low]) * (high - low)
                               / (arr[high] - arr[low]));
        // STEP 3: Probe and narrow accordingly
        if (arr[pos] == target) return pos;
        if (arr[pos] < target) low = pos + 1;
        else high = pos - 1;
    }
    return -1;
}

// EXPONENTIAL SEARCH — O(log n), useful for unbounded/infinite arrays
int ExponentialSearch(int[] arr, int target) {
    // STEP 1: Check index 0 separately (loop starts at i=1)
    if (arr[0] == target) return 0;
    int i = 1;
    // STEP 2: Double i until arr[i] exceeds target or we reach array end
    // Double i until we exceed target or array bounds
    while (i < arr.Length && arr[i] <= target) i *= 2;
    // STEP 3: Binary search in the identified range [i/2, min(i, last)]
    // Binary search in range [i/2, min(i, arr.Length-1)]
    return Array.BinarySearch(arr, i / 2, Math.Min(i, arr.Length - 1) - i/2, target);
}
```

---

### 🔴 Practice Problem: Search for a Range (LeetCode #34 — Medium)

**Problem:** Find first and last positions of target in sorted array. Must be O(log n).

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: SEARCH FOR A RANGE                          ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 LINEAR   │ Scan left/right from    │ O(n)      │ O(1) sp  ║
║              │ found index             │            │          ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 TWO BIN  │ LowerBound for first,   │ O(log n)  │ O(1) sp  ║
║  SEARCHES    │ UpperBound-1 for last   │            │          ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Two separate binary searches: one for leftmost (bias left when arr[mid]==target), one for rightmost (bias right). O(log n) total.

```csharp
public int[] SearchRange(int[] nums, int target) {
    // STEP 1: Find leftmost occurrence using LowerBound
    // First position: lowest index where nums[i] == target
    int first = LowerBound(nums, target);

    // STEP 2: Verify target actually exists at the found position
    // Check if target actually exists
    if (first == nums.Length || nums[first] != target)
        return new[] { -1, -1 };

    // STEP 3: Find rightmost occurrence as UpperBound - 1
    // Last position: (first index where nums[i] > target) - 1
    int last = UpperBound(nums, target) - 1;

    return new[] { first, last };
}
// Using LowerBound and UpperBound from Section 27
// Time: O(log n), Space: O(1)
```

```
TRACE: nums=[5,7,7,8,8,10], target=8
═══════════════════════════════════════════════════════════════
  LowerBound(8): finds first index where nums[i] >= 8 → index 3
  UpperBound(8): finds first index where nums[i] > 8 → index 5
  Result: [3, 5-1] = [3, 4] ✅ (nums[3]=8, nums[4]=8)
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Lower/upper bound binary searches are more powerful than the basic "find any occurrence" search. Mastering these two variants unlocks: first/last occurrence, count of element, floor/ceiling in sorted array, and many range query problems.

---

# PART 8 — ALGORITHM DESIGN PARADIGMS

---

## Section 29 — Recursion & the Recursion Tree

> **🧠 Mental Model: Russian Nesting Dolls**
>
> Recursion is like opening a Russian nesting doll. Each doll contains a smaller version of itself. You keep opening dolls (recursive calls) until you reach the tiniest doll (base case) — which you return without opening. Then each doll "closes back" as returns propagate upward. The call stack IS the stack of dolls waiting to close.

```
RECURSION TREE for Fibonacci(4):
═══════════════════════════════════════════════════════════════
                    fib(4)
                   /      \
               fib(3)     fib(2)
              /     \     /    \
          fib(2)  fib(1) fib(1) fib(0)
          /    \
       fib(1) fib(0)

  Total calls: 9 for fib(4) → exponential O(2^n) ← very wasteful!
  Same subproblems computed multiple times: fib(2) computed TWICE
  Solution: MEMOIZATION — cache results to avoid recomputation
═══════════════════════════════════════════════════════════════

CALL STACK VISUALIZATION for factorial(3):
═══════════════════════════════════════════════════════════════
  factorial(3) → calls factorial(2)
    factorial(2) → calls factorial(1)
      factorial(1) → calls factorial(0)
        factorial(0) → returns 1 ← BASE CASE
      factorial(1) returns 1*1 = 1
    factorial(2) returns 2*1 = 2
  factorial(3) returns 3*2 = 6

  Stack depth = n → O(n) space for call stack
═══════════════════════════════════════════════════════════════
```

### Recursion Patterns

```csharp
// PATTERN 1: REDUCE AND CONQUER (reduce by 1 each call)
int Factorial(int n) {
    // STEP 1: Base case — 0 or 1 returns 1 immediately
    if (n <= 1) return 1;             // base case: factorial(0)=factorial(1)=1
    // STEP 2: Reduce problem by 1 and multiply
    return n * Factorial(n - 1);      // recursive case: n * (n-1)!
}
// T(n) = T(n-1) + O(1) → O(n) time, O(n) stack space

// PATTERN 2: DIVIDE AND CONQUER (halve each call)
int Power(int base_, int exp) {
    // STEP 1: Base case — anything to the 0th power is 1
    if (exp == 0) return 1;           // base case: anything^0 = 1
    // STEP 2: Recurse on half the exponent — compute ONCE to avoid doubling work
    int half = Power(base_, exp / 2); // compute base^(exp/2) ONCE
    // STEP 3: Combine result — extra factor needed for odd exponents
    if (exp % 2 == 0) return half * half;         // even exp
    else return half * half * base_;              // odd exp: one extra factor
    // WHY compute half only once? Avoids O(n) → achieves O(log n)!
}
// T(n) = T(n/2) + O(1) → O(log n) — much faster than naive O(n)

// PATTERN 3: TREE RECURSION (two recursive calls)
int Fib(int n) {
    // STEP 1: Base cases — fib(0)=0, fib(1)=1
    if (n <= 1) return n;
    // STEP 2: Two recursive calls — O(2^n) without memoization
    return Fib(n-1) + Fib(n-2);     // two calls per level → O(2^n) trees
}
// Fix: memoize! See Section 32.

// THE RECURSION TEMPLATE:
// 1. Base case(s): smallest valid input(s) → return directly
// 2. Recursive case: call with SMALLER input, build answer from result
// 3. Trust the recursion: assume recursive call works correctly!
```

---

### 🔴🔥 Practice Problem: Merge Two Sorted Lists (LeetCode #21 — Easy) — MUST SOLVE

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: MERGE TWO SORTED LISTS                      ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 COPY     │ Copy both to array,     │ O(n+m)    │ O(n+m)  ║
║  TO ARRAY    │ sort, rebuild list      │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 ITERATIVE│ Two-pointer merge with  │ O(n+m)    │ O(1) sp ║
║              │ dummy head              │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 RECURSIVE│ Elegant: smaller head   │ O(n+m)    │ O(n+m)  ║
║              │ + merged rest           │            │ stack   ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Pick the smaller head as the result; recursively (or with a dummy node iteratively) link it to the merged tail. Both terminate when either list is exhausted.

```csharp
// ITERATIVE — O(n+m) time, O(1) space (PREFERRED)
// WHY rename l1/l2 → list1/list2? Avoids ambiguity; instantly clear which list is which
public ListNode MergeTwoLists(ListNode list1, ListNode list2) {
    // STEP 1: Create dummy head to avoid special-casing the first node selection
    // WHY dummy? Without it, we'd need an if/else to pick which list becomes the head
    var dummy = new ListNode(0);  // sentinel head — result list builds from dummy.next
    var currentNode = dummy;      // currentNode trails behind, always pointing to last placed node

    // STEP 2: Compare front nodes of both lists; always append the smaller one
    while (list1 != null && list2 != null) {
        if (list1.val <= list2.val) {   // list1's front is smaller (or equal)
            currentNode.next = list1;
            list1 = list1.next;          // advance list1 past the node we just took
        } else {                         // list2's front is smaller
            currentNode.next = list2;
            list2 = list2.next;          // advance list2 past the node we just took
        }
        currentNode = currentNode.next;  // advance the tail of our result list
    }
    // STEP 3: Attach whichever list still has remaining nodes
    // WHY null-coalescing? Exactly one will be null — link the non-null remainder directly
    currentNode.next = list1 ?? list2;
    return dummy.next;  // skip the dummy sentinel, return real head
}

// RECURSIVE — elegant but O(n+m) stack space
public ListNode MergeTwoListsRecursive(ListNode list1, ListNode list2) {
    // STEP 1: Base cases — one list exhausted, return the other unchanged
    if (list1 == null) return list2;  // list1 done; list2 is the remainder
    if (list2 == null) return list1;  // list2 done; list1 is the remainder
    // STEP 2: Pick the smaller head, recursively merge the rest
    // WHY trust the recursion? It returns the merged head of everything after the chosen node
    if (list1.val <= list2.val) {
        list1.next = MergeTwoListsRecursive(list1.next, list2); // list1 head is smaller; merge tail
        return list1;
    } else {
        list2.next = MergeTwoListsRecursive(list1, list2.next); // list2 head is smaller; merge tail
        return list2;
    }
}
```

```
TRACE: l1=[1→3→5], l2=[2→4→6]
═══════════════════════════════════════════════════════════════
  dummy→ curr
  1<=2: curr→1, l1=[3→5]     dummy→[1]→ curr
  3>2:  curr→2, l2=[4→6]     dummy→[1→2]→ curr
  3<=4: curr→3, l1=[5]        dummy→[1→2→3]→ curr
  5>4:  curr→4, l2=[6]        dummy→[1→2→3→4]→ curr
  5<=6: curr→5, l1=null       dummy→[1→2→3→4→5]→ curr
  l1 null → curr.next=l2=[6]
  Result: [1→2→3→4→5→6] ✅
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** The dummy head node eliminates special-casing the first node. Without it, you'd need to handle "which list's head becomes the result head?" separately. Dummy head + curr pointer is the standard pattern for building linked lists.

---

## Section 30 — Backtracking

> **🧠 Mental Model: Decision Tree with Pruning**
>
> Backtracking is like navigating a decision tree — at each node, you try all possible choices. If a choice leads to a dead end (violates constraints), you **backtrack** (undo the choice) and try the next option. Like a maze: go forward, hit a wall, back up, try another direction. The KEY optimization: **pruning** — don't explore paths you know will fail.

```
BACKTRACKING TEMPLATE:
═══════════════════════════════════════════════════════════════
  backtrack(state, choices):
    if isComplete(state):
        add state to results
        return
    for choice in choices:
        if isValid(state, choice):
            makeChoice(state, choice)      // CHOOSE
            backtrack(state, choices)      // EXPLORE
            undoChoice(state, choice)      // UN-CHOOSE (backtrack!)

DECISION TREE for permutations of [1,2,3]:
                    []
              /      |      \
           [1]      [2]      [3]
          /   \    /   \    /   \
       [1,2] [1,3][2,1][2,3][3,1][3,2]
         |     |    |    |    |    |
      [1,2,3][1,3,2]... etc. (6 total)
═══════════════════════════════════════════════════════════════
```

### Backtracking Templates

```csharp
// ═══ TEMPLATE 1: GENERATE ALL PERMUTATIONS ═══
void Permutations(int[] nums, List<int> current, bool[] used, List<IList<int>> result) {
    // STEP 1: Base case — all elements chosen, record the complete permutation
    if (current.Count == nums.Length) {   // complete permutation found
        result.Add(new List<int>(current)); // add COPY (not reference!)
        return;
    }
    // STEP 2: Try each unused element as the next position in the permutation
    for (int i = 0; i < nums.Length; i++) {
        if (used[i]) continue;            // skip already-chosen elements
        // STEP 3: CHOOSE — mark element as used and add to current path
        used[i] = true;                   // CHOOSE: mark as used
        current.Add(nums[i]);
        // STEP 4: EXPLORE — recurse to fill the next position
        Permutations(nums, current, used, result); // EXPLORE
        // STEP 5: UN-CHOOSE — undo the choice to try next candidate
        current.RemoveAt(current.Count - 1); // UN-CHOOSE: remove last element
        used[i] = false;                  // UN-CHOOSE: mark as available again
    }
}

// ═══ TEMPLATE 2: GENERATE ALL SUBSETS ═══
void Subsets(int[] nums, int start, List<int> current, List<IList<int>> result) {
    // STEP 1: Record current state as a valid subset (includes empty set at root)
    result.Add(new List<int>(current)); // add current subset (including empty set!)
    // STEP 2: Extend subset by adding each remaining element
    for (int i = start; i < nums.Length; i++) {
        current.Add(nums[i]);            // CHOOSE nums[i]
        // STEP 3: EXPLORE with i+1 to avoid reuse and THEN UN-CHOOSE
        Subsets(nums, i + 1, current, result); // EXPLORE (i+1: no reuse)
        current.RemoveAt(current.Count - 1);   // UN-CHOOSE
    }
}
```

---

### 🔴 Practice Problem: Letter Combinations of a Phone Number (LeetCode #17 — Medium)

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LETTER COMBINATIONS                         ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Nested loops (one per   │ O(4^n)    │ O(4^n)  ║
║              │ digit) — not generaliz- │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 BFS/ITER │ Build combos iteratively│ O(4^n×n)  │ O(4^n×n)║
║              │ append chars to each    │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BACKTRACK│ Recursion per digit,    │ O(4^n×n)  │ O(n)    ║
║  (CANONICAL) │ O(n) stack space        │            │ stack   ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Backtracking: for each digit position, iterate over its mapped letters; append to path and recurse to next digit; undo on return.

```
DECISION TREE for "23":
  2→[a,b,c], 3→[d,e,f]
  ""
  ├─ a → [ad, ae, af]
  ├─ b → [bd, be, bf]
  └─ c → [cd, ce, cf]
  Result: [ad,ae,af,bd,be,bf,cd,ce,cf]
```

```csharp
public IList<string> LetterCombinations(string digits) {
    // STEP 1: Guard against empty input
    if (digits.Length == 0) return new List<string>();

    // STEP 2: Build the phone digit → letters map
    var phoneMap = new Dictionary<char, string> {
        ['2']="abc", ['3']="def", ['4']="ghi", ['5']="jkl",
        ['6']="mno", ['7']="pqrs", ['8']="tuv", ['9']="wxyz"
    };

    var result = new List<string>();
    var sb = new StringBuilder();

    void Backtrack(int idx) {
        // STEP 3: Base case — all digits processed, record the combination
        if (idx == digits.Length) {  // used all digits → complete combination
            result.Add(sb.ToString());
            return;
        }
        // STEP 4: Try each letter mapped to the current digit
        foreach (char c in phoneMap[digits[idx]]) {
            sb.Append(c);           // CHOOSE: add this letter
            Backtrack(idx + 1);     // EXPLORE: move to next digit
            sb.Length--;            // UN-CHOOSE: remove last letter (backtrack)
        }
    }

    // STEP 5: Start backtracking from the first digit
    Backtrack(0);
    return result;
}
// Time: O(4^n × n) — 4^n combinations, each takes O(n) to build
// Space: O(n) recursion depth + O(4^n × n) for results
```

> **🎯 Key Insight:** Backtracking's power comes from the **un-choose step** — it undoes the choice, allowing you to try the next option from a clean state. The StringBuilder append/length-- pattern is efficient: it modifies in-place instead of creating new strings at each step.

---

## Section 31 — Divide & Conquer

> **🧠 Mental Model: Tax Filing Delegation**
>
> A manager with 1000 employees doesn't file taxes one by one. They split the team in half, delegate each half to a sub-manager, and combine the results. Each sub-manager does the same recursively. With D&C, a problem of size n becomes two problems of size n/2, and you combine in O(n) → T(n) = 2T(n/2) + O(n) → O(n log n).

```
MASTER THEOREM (for T(n) = aT(n/b) + O(n^c)):
═══════════════════════════════════════════════════════════════
  Compare n^(log_b a) vs n^c:
  - If n^c LARGER:   T(n) = O(n^c)              [combine dominates]
  - If EQUAL:        T(n) = O(n^c × log n)       [balanced]
  - If n^(log_b a) LARGER: T(n) = O(n^(log_b a)) [recursion dominates]

  Examples:
  Merge Sort: T(n)=2T(n/2)+O(n) → a=2,b=2,c=1 → log_2(2)=1=c → O(n log n)
  Binary Search: T(n)=T(n/2)+O(1) → a=1,b=2,c=0 → log_2(1)=0=c → O(log n)
  Strassen Matrix: T(n)=7T(n/2)+O(n²) → log_2(7)≈2.81>2 → O(n^2.81)
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Maximum Subarray (LeetCode #53 — Medium)

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: MAXIMUM SUBARRAY                            ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Try all subarrays O(n²) │ O(n²)     │ O(1) sp ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 D&C      │ Split in half, max in   │ O(n log n)│ O(log n)║
║              │ left/right/crossing     │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 KADANE'S │ Greedy: extend or       │ O(n)      │ O(1) sp ║
║  (OPTIMAL)   │ restart at each element │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KADANE'S KEY INSIGHT: At each position, the max subarray ending HERE
  is max(current element alone, current element + best ending at prev).
  If extending the previous subarray makes it worse, start fresh here.
```

> **🔑 CORE IDEA:** Kadane's: currentSum = max(num, currentSum + num). If adding the current number hurts (makes sum negative), start fresh from current number.

```csharp
// KADANE'S ALGORITHM — O(n) time, O(1) space
public int MaxSubArray(int[] nums) {
    // STEP 1: Seed both trackers with the first element (handles all-negative arrays)
    // currentMax: best subarray sum ENDING at current position
    // globalMax: best subarray sum seen ANYWHERE so far
    int currentMax = nums[0], globalMax = nums[0];

    for (int i = 1; i < nums.Length; i++) {
        // STEP 2: Decide: extend previous subarray or start fresh from current element
        // KEY DECISION: should we extend the previous subarray or start fresh?
        // Extend if adding current element improves the sum (currentMax > 0)
        // Start fresh if previous subarray sum is negative (it would only hurt)
        currentMax = Math.Max(nums[i], currentMax + nums[i]);
        // STEP 3: Track the best result seen across all positions
        globalMax = Math.Max(globalMax, currentMax);
    }
    return globalMax;
}
```

```
TRACE: nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
═══════════════════════════════════════════════════════════════
  i=0: curr=-2,  global=-2
  i=1: curr=max(1,-2+1)=1,   global=1
  i=2: curr=max(-3,1-3)=-2,  global=1
  i=3: curr=max(4,-2+4)=4,   global=4
  i=4: curr=max(-1,4-1)=3,   global=4
  i=5: curr=max(2,3+2)=5,    global=5
  i=6: curr=max(1,5+1)=6,    global=6   ← max subarray [4,-1,2,1]=6
  i=7: curr=max(-5,6-5)=1,   global=6
  i=8: curr=max(4,1+4)=5,    global=6
  Answer: 6 ✅
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Kadane's algorithm is the canonical example of DP disguised as a simple linear scan. The recurrence: `dp[i] = max(nums[i], dp[i-1] + nums[i])` is O(1) space because dp[i] only depends on dp[i-1].

---

## Section 32 — Dynamic Programming: Memoization

> **🧠 Mental Model: A Notebook for Repeated Work**
>
> Memoization is like keeping a notebook of answers you've already computed. When the same question comes up again, look it up instead of recomputing. The recursive structure stays the same — you just cache results. "Top-down DP" = recursion + memo.

```
FIBONACCI WITH MEMOIZATION:
═══════════════════════════════════════════════════════════════
  Without memo: fib(5) makes 15 calls (recomputes fib(2) 3 times!)
  With memo: each fib(n) computed ONCE, stored, reused

  fib(5)
   ├─ fib(4)
   │   ├─ fib(3)
   │   │   ├─ fib(2) ── computed, stored in memo[2]
   │   │   └─ fib(1) ── base case
   │   └─ fib(2) ────── LOOKUP from memo[2], O(1)!
   └─ fib(3) ────────── LOOKUP from memo[3], O(1)!

  Total: O(n) calls vs O(2^n) without memo
═══════════════════════════════════════════════════════════════
```

```csharp
// MEMOIZATION TEMPLATE
int[] memo;

int FibMemo(int n) {
    // STEP 1: Initialize memo array with sentinel value -1 (means "not yet computed")
    memo = new int[n + 1];
    Array.Fill(memo, -1);   // -1 = not computed yet
    // STEP 2: Kick off the memoized recursive computation
    return Fib(n);
}

int Fib(int n) {
    // STEP 1: Base case — fib(0)=0, fib(1)=1
    if (n <= 1) return n;           // base case
    // STEP 2: Cache hit — return previously computed result in O(1)
    if (memo[n] != -1) return memo[n]; // already computed? return cached!
    // STEP 3: Compute, store in memo, and return
    memo[n] = Fib(n-1) + Fib(n-2);    // compute and STORE in memo
    return memo[n];
}
// Time: O(n) — each subproblem computed once
// Space: O(n) — memo array + O(n) call stack
```

---

### 🔴🔥 Practice Problem: Climbing Stairs (LeetCode #70 — Easy) — MUST SOLVE

**Problem:** To reach the top, you can climb 1 or 2 steps at a time. How many distinct ways to climb n stairs?

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: CLIMBING STAIRS                             ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Recursion: ways(n) =    │ O(2^n)    │ O(n)sp  ║
║              │ ways(n-1)+ways(n-2)     │ (no memo) │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 MEMO     │ Recursion + cache       │ O(n)      │ O(n) sp ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 TABUL.   │ Bottom-up DP table      │ O(n)      │ O(n) sp ║
╠══════════════════════════════════════════════════════════════════╣
║  🏆 SPACE    │ Only keep last 2 values │ O(n)      │ O(1) sp ║
║  OPTIMIZED   │ (Fibonacci pattern)     │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: ways(n) = ways(n-1) + ways(n-2)  ← this IS the Fibonacci recurrence!
             To reach step n: either came from n-1 (1-step) or n-2 (2-step)
```

> **🔑 CORE IDEA:** ways(n) = ways(n−1) + ways(n−2). It's exactly Fibonacci. Use two variables instead of an array for O(1) space.

```csharp
public int ClimbStairs(int n) {
    // STEP 1: Base cases — 1 stair: 1 way; 2 stairs: 2 ways
    if (n <= 2) return n;
    // STEP 2: Initialize last two values (Fibonacci seeds)
    // WHY only two variables? dp[i] = dp[i-1] + dp[i-2]
    // We only ever need the last two values — no need for full array
    int prev2 = 1;  // ways to reach step 1
    int prev1 = 2;  // ways to reach step 2

    // STEP 3: Roll forward applying recurrence dp[i] = dp[i-1] + dp[i-2]
    for (int i = 3; i <= n; i++) {
        int curr = prev1 + prev2;  // ways to reach step i
        prev2 = prev1;             // slide window: old prev1 becomes prev2
        prev1 = curr;              // new value becomes prev1
    }
    return prev1;
}
// Time: O(n), Space: O(1)
```

```
TRACE: n=5
  Base: prev2=1(step1), prev1=2(step2)
  i=3: curr=2+1=3, prev2=2, prev1=3
  i=4: curr=3+2=5, prev2=3, prev1=5
  i=5: curr=5+3=8, prev2=5, prev1=8
  Answer: 8 ✅ (ways: 1+1+1+1+1, 2+1+1+1, 1+2+1+1, 1+1+2+1, 1+1+1+2, 2+2+1, 2+1+2, 1+2+2)
```

> **🎯 Key Insight:** Climbing Stairs teaches two critical DP lessons: (1) identify the recurrence relation from the problem structure, (2) optimize space by keeping only what you actually need (here: last 2 values). This pattern of "dp[i] depends on last k values → use k variables" recurs constantly.

---

## Section 33 — Dynamic Programming: Tabulation

> **🧠 Mental Model: Filling a Table Bottom-Up**
>
> Tabulation is bottom-up DP — fill a table from the smallest subproblems up to the answer. Like building a brick wall: lay the foundation first, then each brick rests on the ones below. No recursion, no stack overflow risk, often easier to optimize space.

```
TABULATION vs MEMOIZATION:
═══════════════════════════════════════════════════════════════
  MEMOIZATION (top-down):          TABULATION (bottom-up):
  - Recursive structure             - Iterative loops
  - Computes only needed states     - Computes ALL states
  - O(n) stack space overhead       - No stack overhead
  - Easier to think about           - Often more cache-friendly
  - Natural for tree-structure DP   - Better for linear/2D DPs

  BOTH have same time/space complexity for the DP table itself.
═══════════════════════════════════════════════════════════════
```

---

### 🔴🔥 Practice Problem: Coin Change (LeetCode #322 — Medium) — MUST SOLVE

**Problem:** Given coins of different denominations and amount, find fewest coins to make amount. Return -1 if impossible.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: COIN CHANGE                                 ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 GREEDY   │ Always pick largest     │ O(amount) │ O(1) sp ║
║  (WRONG!)    │ coin first              │ WRONG for │         ║
║              │ e.g. coins=[1,3,4]amt=6 │ some inputs│        ║
║              │ Greedy: 4+1+1=3 coins   │            │         ║
║              │ Optimal: 3+3=2 coins ✓  │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 RECURSE  │ Try all coin choices at │ O(S^n)    │ O(n)sp  ║
║  NO MEMO     │ each step (exponential) │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DP TABLE │ dp[i] = min coins for   │ O(S×n)    │ O(S) sp ║
║  (OPTIMAL)   │ amount i                │            │         ║
╚══════════════════════════════════════════════════════════════════╝

RECURRENCE: dp[i] = min(dp[i - coin] + 1) for each coin <= i
BASE CASE: dp[0] = 0 (zero coins needed for amount 0)
```

> **🔑 CORE IDEA:** Bottom-up DP: dp[i] = min coins for amount i. For each amount from 1 to target, try every coin c: dp[i] = min(dp[i], dp[i−c]+1). Greedy fails for non-canonical systems.

```
DP TABLE VISUALIZATION: coins=[1,2,5], amount=11
═══════════════════════════════════════════════════════════════
  dp[0]=0  (base case: no coins needed for 0)
  dp[1]=min(dp[1-1]+1)=1            → 1 coin (1)
  dp[2]=min(dp[2-1]+1,dp[2-2]+1)=1  → 1 coin (2)
  dp[3]=min(dp[2]+1,dp[1]+1)=2      → 2 coins (1+2)
  dp[4]=min(dp[3]+1,dp[2]+1)=2      → 2 coins (2+2)
  dp[5]=min(dp[4]+1,dp[3]+1,dp[0]+1)=1 → 1 coin (5)
  dp[6]=min(dp[5]+1,dp[4]+1,dp[1]+1)=2 → 2 coins (1+5)
  ...
  dp[11]=3  → 3 coins (1+5+5)
═══════════════════════════════════════════════════════════════
```

```csharp
public int CoinChange(int[] coins, int amount) {
    // STEP 1: Allocate dp table and fill with "infinity" sentinel
    // dp[i] = minimum coins needed to make amount i
    int[] dp = new int[amount + 1];
    // WHY amount+1? We need dp[0] through dp[amount]

    // WHY fill with amount+1? It acts as "infinity" — any valid answer
    // will be ≤ amount (using all 1-cent coins). amount+1 signals impossible.
    Array.Fill(dp, amount + 1);
    // STEP 2: Base case — zero coins needed to make amount 0
    dp[0] = 0;  // base case: 0 coins to make amount 0

    // STEP 3: Fill table bottom-up — for each amount, try every coin
    for (int i = 1; i <= amount; i++) {          // for each amount from 1 to target
        foreach (int coin in coins) {
            if (coin <= i) {                      // coin can contribute to this amount
                // dp[i-coin]+1 = use this coin + optimal solution for remaining amount
                dp[i] = Math.Min(dp[i], dp[i - coin] + 1);
            }
        }
    }

    // STEP 4: If still "infinity", no combination reaches the amount
    // WHY check > amount? If dp[amount] is still amount+1, no solution exists
    return dp[amount] > amount ? -1 : dp[amount];
}
// Time: O(S × n) where S=amount, n=number of coins
// Space: O(S) for dp array
```

```
TRACE: coins=[2,3,7], amount=10
════════════════════════════════════════════════════════════════
  dp = [0, ∞, ∞, ∞, ∞, ∞, ∞, ∞, ∞, ∞, ∞]   (∞ = amount+1=11)
  i=2: coin=2: dp[2]=min(∞,dp[0]+1)=1    dp=[0,∞,1,∞,...]
  i=3: coin=2: dp[1]+1=∞; coin=3: dp[0]+1=1  dp[3]=1
  i=4: coin=2: dp[2]+1=2; coin=3: dp[1]+1=∞  dp[4]=2
  i=5: coin=2: dp[3]+1=2; coin=3: dp[2]+1=2  dp[5]=2
  i=6: coin=2: dp[4]+1=3; coin=3: dp[3]+1=2  dp[6]=2
  i=7: coin=2: dp[5]+1=3; coin=3: dp[4]+1=3; coin=7: dp[0]+1=1  dp[7]=1
  i=9: coin=2: dp[7]+1=2; coin=3: dp[6]+1=3; coin=7: dp[2]+1=2  dp[9]=2
  i=10:coin=2: dp[8]+1; coin=3: dp[7]+1=2; coin=7: dp[3]+1=2    dp[10]=2
  Answer: 2 (7+3 or 3+7) ✅
════════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Coin Change is the archetype for unbounded knapsack DP. The recurrence `dp[i] = min(dp[i-coin]+1)` tries all coins at each amount. "Infinity" initialization ensures unachievable amounts stay marked. This pattern solves: "ways to make change," "minimum jumps," "word break."

---

## Section 34 — Classic DP Problems

> **🧠 Mental Model: Building Blocks**
>
> Classic DP problems follow recurring patterns. Master these 6 and you can solve 80% of interview DP problems by recognizing which pattern applies.

### 🔴🔥 Practice Problem: Longest Common Subsequence (LeetCode #1143 — Medium) — MUST SOLVE

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LONGEST COMMON SUBSEQUENCE                  ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Generate all subsequences│ O(2^n × m)│ O(n)sp ║
║              │ of s1, check in s2       │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 MEMO     │ Recursion + 2D memo      │ O(n×m)    │ O(n×m)  ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 2D DP    │ dp[i][j]=LCS of first    │ O(n×m)    │ O(n×m)  ║
║  TABLE       │ i chars of s1, j of s2  │            │         ║
╚══════════════════════════════════════════════════════════════════╝

RECURRENCE:
  If s1[i-1] == s2[j-1]: dp[i][j] = dp[i-1][j-1] + 1  (chars match: extend)
  Else:                   dp[i][j] = max(dp[i-1][j], dp[i][j-1])  (skip one char)
```

> **🔑 CORE IDEA:** 2D DP: if chars match, dp[i][j] = dp[i−1][j−1]+1; else dp[i][j] = max(dp[i−1][j], dp[i][j−1]). Rows = s1 chars, cols = s2 chars.

```
2D DP TABLE: s1="ABCBDAB", s2="BDCAB"
═══════════════════════════════════════════════════════════════
       ""  B  D  C  A  B
  ""  [ 0  0  0  0  0  0]
   A  [ 0  0  0  0  1  1]
   B  [ 0  1  1  1  1  2]
   C  [ 0  1  1  2  2  2]
   B  [ 0  1  1  2  2  3]
   D  [ 0  1  2  2  2  3]
   A  [ 0  1  2  2  3  3]
   B  [ 0  1  2  2  3  4] ← LCS = 4 ("BCAB" or "BDAB")
═══════════════════════════════════════════════════════════════
```

```csharp
public int LongestCommonSubsequence(string text1, string text2) {
    int m = text1.Length, n = text2.Length;
    // STEP 1: Allocate 2D DP table with extra row/col for empty-string base cases
    // dp[i][j] = LCS of text1[0..i-1] and text2[0..j-1]
    // WHY +1 size? dp[0][...] and dp[...][0] = 0 (empty string base cases)
    int[,] dp = new int[m + 1, n + 1];

    // STEP 2: Fill table — match extends diagonal; mismatch takes max of adjacent cells
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (text1[i-1] == text2[j-1]) {
                // STEP 3: Characters MATCH — extend LCS from dp[i-1][j-1]
                // Characters MATCH: LCS extends the LCS without these characters
                dp[i, j] = dp[i-1, j-1] + 1;
            } else {
                // STEP 4: No match — take best result from skipping one char in either string
                // No match: take the best of skipping one char from either string
                dp[i, j] = Math.Max(dp[i-1, j], dp[i, j-1]);
            }
        }
    }
    return dp[m, n];
}
// Time: O(m×n), Space: O(m×n) — can optimize to O(min(m,n)) with 1D DP
```

> **🎯 Key Insight:** LCS is the foundation for: diff tools (git diff), DNA sequence alignment, edit distance. The 2D DP table is the standard approach. The recurrence encodes two cases: characters match (extend) or don't match (skip one from either string — take the max).

---

## Section 35 — Greedy Algorithms

> **🧠 Mental Model: Packing a Backpack**
>
> Greedy always makes the locally optimal choice, hoping it leads to a globally optimal solution. Like packing a backpack: always grab the most valuable/lightest item first. CAUTION: greedy doesn't always work — you must PROVE the greedy choice is safe. When greedy works, it's elegant and fast.

```
GREEDY vs DP:
═══════════════════════════════════════════════════════════════
  Greedy works when: optimal substructure + greedy choice property
  (making locally best choice never worsens the global optimum)

  GREEDY SUCCEEDS:
  - Activity selection (pick event ending earliest)
  - Huffman coding (always merge two lowest-frequency trees)
  - Fractional knapsack (sort by value/weight ratio)
  - Dijkstra's SSSP (always expand nearest node)

  GREEDY FAILS (need DP):
  - 0/1 Knapsack (can't take fractions)
  - Coin change (greedy picks largest coin, may miss optimal)
  - Longest common subsequence
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Jump Game (LeetCode #55 — Medium)

**Problem:** Given array where `nums[i]` is max jump length from position i, can you reach the last index?

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: JUMP GAME                                   ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ DFS/BFS try all paths   │ O(2^n)    │ O(n) sp ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 DP       │ dp[i]=can reach i from  │ O(n²)     │ O(n) sp ║
║              │ any j where dp[j] true  │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 GREEDY   │ Track max reachable pos │ O(n)      │ O(1) sp ║
║  (OPTIMAL)   │ at each step            │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: We don't need to know HOW we reach each position — just
             WHETHER we can. Track the furthest reachable index.
             If current position > furthest reachable → stuck!
```

> **🔑 CORE IDEA:** Greedy: track maxReach. For each i ≤ maxReach, update maxReach = max(maxReach, i + jumps[i]). If maxReach ≥ last index at any point, return true.

```csharp
public bool CanJump(int[] nums) {
    // STEP 1: Initialize the maximum reachable index from position 0
    int maxReach = 0;  // furthest index reachable from positions 0..i

    for (int i = 0; i < nums.Length; i++) {
        // STEP 2: If current position is beyond what's reachable, we're stuck
        // If i > maxReach: we CAN'T reach position i (stuck before it)
        if (i > maxReach) return false;

        // STEP 3: Extend the frontier — update maxReach using this position's jump range
        // Update maxReach: from position i, we can jump nums[i] steps
        maxReach = Math.Max(maxReach, i + nums[i]);

        // STEP 4: Early exit — frontier already covers the last index
        // Early exit: can already reach the end
        if (maxReach >= nums.Length - 1) return true;
    }
    return true;
}
// Time: O(n), Space: O(1)
```

```
TRACE: nums=[2,3,1,1,4]
═══════════════════════════════════════════════════════════════
  i=0: maxReach=max(0,0+2)=2  → can reach idx 0,1,2
  i=1: maxReach=max(2,1+3)=4  → can reach up to idx 4 ✅
  i=2: maxReach=max(4,2+1)=4  (no change)
  maxReach=4 >= last idx=4 → return true ✅

TRACE: nums=[3,2,1,0,4]
═══════════════════════════════════════════════════════════════
  i=0: maxReach=max(0,0+3)=3
  i=1: maxReach=max(3,1+2)=3
  i=2: maxReach=max(3,2+1)=3
  i=3: maxReach=max(3,3+0)=3
  i=4: 4 > maxReach=3 → return false ❌
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** The greedy insight is subtle: you don't need to simulate actual jumps. Just track the maximum reachable index. If you ever find yourself at a position beyond what's reachable, you're stuck. This "track frontier" greedy pattern appears in "Jump Game II" (min jumps), "Video Stitching," and similar problems.

---

# PART 9 — PROBLEM-SOLVING PATTERNS

---

## Section 36 — Two Pointers

> **🧠 Mental Model: Squeezing a Water Balloon**
>
> Two Pointers places one pointer at each end of a sorted structure. Like squeezing a balloon from both ends — as you move them toward each other, you cover all combinations without redundancy. Works on SORTED arrays where moving one pointer in a direction has a predictable effect.

```
TWO POINTER PATTERNS:
═══════════════════════════════════════════════════════════════
  OPPOSITE ENDS (sorted array, find pair):
    left=0 ──────────────────► ◄──────────── right=n-1
    sum too small → move left right
    sum too large → move right left

  SAME DIRECTION (fast/slow, sliding window variant):
    slow=0 ──► fast=k ──►
    Use for: partition, remove duplicates

  EXAMPLE: Two Sum II (sorted array):
  [2, 7, 11, 15], target=9
  left=0(2), right=3(15): 2+15=17>9 → right--
  left=0(2), right=2(11): 2+11=13>9 → right--
  left=0(2), right=1(7):  2+7=9==9 → FOUND [1,2] ✅
═══════════════════════════════════════════════════════════════
```

---

### 🔴🔥 Practice Problem: 3Sum (LeetCode #15 — Medium) — MUST SOLVE

**Problem:** Find all unique triplets that sum to zero.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: 3SUM                                        ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ 3 nested loops check    │ O(n³)     │ O(1) sp ║
║              │ all triplets            │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 HASHSET  │ Fix 2, find 3rd in set  │ O(n²)     │ O(n) sp ║
║              │ (dedup is tricky)       │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 SORT +   │ Sort, fix first element,│ O(n²)     │ O(1) sp ║
║  TWO PTR     │ two-pointer for rest    │            │ (excl.  ║
║  (OPTIMAL)   │ skip duplicates cleanly │            │ output) ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Sort first. Fix index i, then two-pointer: left=i+1, right=end. When sum==0 record and skip duplicates at all three levels.

```csharp
public IList<IList<int>> ThreeSum(int[] nums) {
    // STEP 1: Sort array to enable two-pointer and easy duplicate skipping
    Array.Sort(nums);  // MUST sort first — enables two-pointer + easy deduplication
    var result = new List<IList<int>>();

    // STEP 2: Fix the first element of the triplet; use two-pointer for the other two
    // WHY nums.Length - 2? i needs at least 2 elements after it (left and right pointers).
    // Last valid i is nums.Length-3; loop condition < nums.Length-2 ensures that.
    for (int i = 0; i < nums.Length - 2; i++) {
        // SKIP DUPLICATE: if nums[i] is same as previous fixed element, triplets would repeat
        if (i > 0 && nums[i] == nums[i-1]) continue;

        // EARLY EXIT: if smallest possible sum > 0, no solution possible
        if (nums[i] > 0) break;

        // STEP 3: Two-pointer scan to find pairs summing to -nums[i]
        int left = i + 1, right = nums.Length - 1;
        while (left < right) {
            int sum = nums[i] + nums[left] + nums[right];
            if (sum == 0) {
                result.Add(new List<int> { nums[i], nums[left], nums[right] });
                // STEP 4: Skip duplicates at both pointers after recording valid triplet
                // SKIP DUPLICATES at both pointers after finding a valid triplet
                while (left < right && nums[left] == nums[left+1]) left++;
                while (left < right && nums[right] == nums[right-1]) right--;
                left++; right--;
            } else if (sum < 0) {
                left++;   // need larger sum → move left pointer right
            } else {
                right--;  // need smaller sum → move right pointer left
            }
        }
    }
    return result;
}
// Time: O(n²) — O(n log n) sort + O(n²) two-pointer scans
// Space: O(1) extra (excluding result)
```

```
TRACE: nums=[-1,0,1,2,-1,-4] → sorted: [-4,-1,-1,0,1,2]
════════════════════════════════════════════════════════════
  i=0(-4): left=1,right=5: -4-1+2=-3<0→left++
           left=2,right=5: -4-1+2=-3<0→left++  ... eventually no match

  i=1(-1): left=2,right=5: -1-1+2=0 → add[-1,-1,2] ✅
           skip dup at right(no dup); left=3,right=4
           left=3,right=4: -1+0+1=0 → add[-1,0,1] ✅
           left=4,right=3: loop ends

  i=2(-1): nums[2]==nums[1]=-1 → SKIP (duplicate i)

  i=3(0):  left=4,right=5: 0+1+2=3>0→right--; right=4==left → end

  Result: [[-1,-1,2],[-1,0,1]] ✅
════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** 3Sum reduces to multiple TwoSum calls. Sort first to enable two-pointer AND make deduplication straightforward (identical elements are adjacent). The dedup logic: skip same `i` value (outer loop), skip same `left`/`right` values after finding a valid triplet (inner loop).

---

## Section 37 — Sliding Window

> **🧠 Mental Model: A Moving Spotlight**
>
> Sliding Window is like a spotlight moving across a stage. The spotlight (window) has a fixed or variable width and slides right. At each position, you can see everything lit by the spotlight. Instead of recomputing the entire window each step, you add the new right edge and remove the old left edge — O(1) update per step.

```
FIXED-SIZE WINDOW (size k=3):
═══════════════════════════════════════════════════════════════
  Array: [2, 1, 5, 1, 3, 2], k=3

  Window 1: [2,1,5] sum=8
  Window 2:   [1,5,1] sum=7  (remove 2, add 1)
  Window 3:     [5,1,3] sum=9  (remove 1, add 3)
  Window 4:       [1,3,2] sum=6  (remove 5, add 2)
  Max = 9 ✅  — O(n) total instead of O(n×k)

VARIABLE-SIZE WINDOW (expand right, contract left as needed):
  Goal: Longest substring with at most k distinct chars
  "araaci", k=2:
  expand: a→r→a (2 distinct) → a→r→a→a (2 distinct) → a→r→a→a→c (3 distinct!)
  contract left until 2 distinct: remove 'a'→'r'→ window="aac" (2 distinct) ✓
═══════════════════════════════════════════════════════════════
```

### Sliding Window Templates

```csharp
// FIXED SIZE WINDOW — Maximum sum subarray of size k
int MaxSumSubarrayK(int[] arr, int k) {
    // STEP 1: Build the initial window of size k
    int windowSum = 0;
    for (int i = 0; i < k; i++) windowSum += arr[i]; // build initial window
    int maxSum = windowSum;

    // STEP 2: Slide window right — add new right element, remove old left element
    for (int i = k; i < arr.Length; i++) {
        windowSum += arr[i] - arr[i - k]; // ADD new right element, REMOVE old left element
        maxSum = Math.Max(maxSum, windowSum);
    }
    return maxSum;
}

// VARIABLE SIZE WINDOW — Longest subarray with sum ≤ target
int LongestSubarraySumAtMostTarget(int[] arr, int target) {
    int left = 0, windowSum = 0, maxLen = 0;
    for (int right = 0; right < arr.Length; right++) {
        // STEP 1: Expand window to the right
        windowSum += arr[right];  // EXPAND: include right element

        // STEP 2: Shrink from the left while constraint is violated
        // SHRINK: while constraint violated, move left pointer right
        while (windowSum > target) {
            windowSum -= arr[left];  // remove left element
            left++;
        }
        // STEP 3: Update the maximum valid window length
        maxLen = Math.Max(maxLen, right - left + 1);
    }
    return maxLen;
}
```

---

### 🔴🔥 Practice Problem: Longest Substring Without Repeating Characters (LeetCode #3 — Medium) — MUST SOLVE

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LONGEST SUBSTRING NO REPEAT                 ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Check all O(n²) substr- │ O(n³)     │ O(min(n,m))║
║              │ ings for uniqueness     │            │            ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 SLIDING  │ HashSet window, O(2n)   │ O(n)      │ O(min(n,m))║
║  WINDOW SET  │ shrink one-by-one       │            │            ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 SLIDING  │ HashMap: char → last    │ O(n)      │ O(min(n,m))║
║  WINDOW MAP  │ seen index → jump left  │            │            ║
║  (OPTIMAL)   │ directly (no shrinking) │            │            ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Instead of slowly shrinking the window when a duplicate is found,
             use a HashMap to jump left directly to (duplicate's last index + 1).
             This avoids O(k) shrinking per step.
```

> **🔑 CORE IDEA:** Sliding window + HashMap(char → last index). On duplicate, jump left = max(left, lastSeen[char]+1) — skip over the old duplicate in one step.

```csharp
public int LengthOfLongestSubstring(string s) {
    // STEP 1: Build HashMap to track last-seen index of each character
    // Map each character to its most recent index seen in the string
    var lastSeen = new Dictionary<char, int>();
    int left = 0, maxLen = 0;

    for (int right = 0; right < s.Length; right++) {
        char currentChar = s[right];  // WHY currentChar? Clearer than 'c' — avoids confusion with index variables

        // STEP 2: On duplicate within current window, jump left past it in O(1)
        // If currentChar was seen AND its last occurrence is within the current window
        // (prevIdx >= left): jump left pointer past the duplicate
        if (lastSeen.TryGetValue(currentChar, out int prevIdx) && prevIdx >= left) {
            // WHY prevIdx >= left? If the previous occurrence is before window start,
            // it's already outside the window — no need to shrink
            left = prevIdx + 1;  // jump: skip over the duplicate character
        }

        // STEP 3: Update last-seen index and record maximum window length
        lastSeen[currentChar] = right;  // record most recent index for currentChar
        maxLen = Math.Max(maxLen, right - left + 1);
    }
    return maxLen;
}
// Time: O(n) — each character processed once
// Space: O(min(n, m)) where m = alphabet size (at most 128 for ASCII)
```

```
TRACE: s = "abcabcbb"
════════════════════════════════════════════════════════════
  r=0(a): left=0, lastSeen={a:0}, len=1
  r=1(b): left=0, lastSeen={a:0,b:1}, len=2
  r=2(c): left=0, lastSeen={a:0,b:1,c:2}, len=3
  r=3(a): prevIdx=0>=left=0 → left=1; lastSeen={a:3,b:1,c:2}, len=3
  r=4(b): prevIdx=1>=left=1 → left=2; lastSeen={a:3,b:4,c:2}, len=3
  r=5(c): prevIdx=2>=left=2 → left=3; lastSeen={a:3,b:4,c:5}, len=3
  r=6(b): prevIdx=4>=left=3 → left=5; lastSeen={a:3,b:6,c:5}, len=2
  r=7(b): prevIdx=6>=left=5 → left=7; len=1
  maxLen = 3 ("abc") ✅
════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** The HashMap optimization transforms "shrink by 1 per step" into "jump left in O(1)." Trigger: `prevIdx >= left` — only jump if the previous occurrence is actually inside our current window. If it's outside, there's no duplicate in the window (we can just update the map).

---

## Section 38 — Fast & Slow Pointers

> **🧠 Mental Model: Two Runners on a Circular Track**
>
> If a slow runner and a fast runner run on a circular track, they WILL meet — the fast runner laps the slow one. If the track is linear (no cycle), the fast runner simply reaches the end. This insight powers Floyd's Cycle Detection Algorithm.

```
FLOYD'S CYCLE DETECTION:
═══════════════════════════════════════════════════════════════
  List with cycle: 1→2→3→4→5→3 (cycle at 3)

  slow: 1→2→3→4→5→3→4→5→3...
  fast: 1→3→5→4→3→5→4→3...

  They WILL meet inside the cycle.
  Meeting point: depends on list structure.

  TO FIND CYCLE START:
  After meeting, move one pointer to head, keep other at meeting point.
  Both move ONE step at a time.
  They meet at the CYCLE START ← mathematical proof based on distances!

  MIDDLE OF LIST (no cycle):
  slow=1 step, fast=2 steps
  When fast reaches end → slow is at middle
  Length 5: [1,2,3,4,5] → slow at 3 (middle) ✅
  Length 4: [1,2,3,4]   → slow at 2 (first middle) or 3 (second)
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Linked List Cycle II (LeetCode #142 — Medium)

**Problem:** Find the node where the cycle begins (return null if no cycle).

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: LINKED LIST CYCLE II                        ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 HASHSET  │ Store visited nodes,    │ O(n)      │ O(n) sp ║
║              │ return first revisited  │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 FLOYD'S  │ Fast/slow detect cycle, │ O(n)      │ O(1) sp ║
║  (OPTIMAL)   │ then find start         │            │         ║
╚══════════════════════════════════════════════════════════════════╝

MATHEMATICAL PROOF:
  F = distance from head to cycle start
  C = cycle length
  slow traveled: F + a (a = distance inside cycle before meeting)
  fast traveled: F + a + nC (n full laps extra)
  fast = 2 × slow: F+a+nC = 2(F+a) → F = nC - a
  → After meeting: reset one pointer to head, move both 1 step.
    They meet at cycle start (both travel F steps to get there).
```

> **🔑 CORE IDEA:** Floyd's: slow/fast meet inside cycle. Reset slow to head; advance both one step at a time — they meet exactly at the cycle entry point (mathematical guarantee).

```csharp
public ListNode DetectCycle(ListNode head) {
    // STEP 1: Initialize fast and slow pointers at head
    ListNode slow = head, fast = head;

    // STEP 2: Advance fast two steps and slow one step until they meet or fast reaches end
    // PHASE 1: Detect if cycle exists
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
        if (slow == fast) {       // they met inside the cycle!
            // STEP 3: Meeting detected — reset slow to head; advance both one step at a time
            // PHASE 2: Find cycle entry point
            // Reset slow to head; fast stays at meeting point
            slow = head;
            // Both move at same speed (1 step each)
            while (slow != fast) {
                slow = slow.next;
                fast = fast.next;  // WHY 1 step now? Mathematical proof says they meet at start
            }
            // STEP 4: Convergence point is the cycle entry node
            return slow;  // cycle start node
        }
    }
    return null;  // no cycle
}
// Time: O(n), Space: O(1) — no extra data structures!
```

> **🎯 Key Insight:** Floyd's algorithm is beautiful because Phase 2 works due to the mathematical relationship F = nC - a. After meeting, slow travels F steps from head to cycle start; fast also travels F steps from meeting point (going around the cycle). They arrive at the same node — the cycle start.

---

## Section 39 — Merge Intervals

> **🧠 Mental Model: Calendar Merging**
>
> Given a list of meeting time ranges, find the total time blocked out. Merge overlapping meetings. Sort by start time, then greedily merge: if next meeting starts before current one ends, extend the current meeting. Otherwise, the current meeting is finalized.

```
MERGE INTERVALS VISUALIZATION:
═══════════════════════════════════════════════════════════════
  Input: [[1,3],[2,6],[8,10],[15,18]]

  Sorted: [[1,3],[2,6],[8,10],[15,18]]

  current=[1,3], next=[2,6]: 2<=3 → OVERLAP → merge to [1,6]
  current=[1,6], next=[8,10]: 8>6 → NO overlap → add [1,6], current=[8,10]
  current=[8,10], next=[15,18]: 15>10 → NO overlap → add [8,10], current=[15,18]
  End: add [15,18]

  Result: [[1,6],[8,10],[15,18]] ✅
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Merge Intervals (LeetCode #56 — Medium)

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: MERGE INTERVALS                             ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ For each interval check │ O(n²)     │ O(n) sp ║
║              │ all others for overlap  │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 SORT +   │ Sort by start, greedy   │ O(n log n)│ O(n) sp ║
║  MERGE       │ merge sweep             │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Sort by start. Greedily extend the last interval in the result if current.start ≤ last.end; otherwise append as a new interval.

```csharp
public int[][] Merge(int[][] intervals) {
    // STEP 1: Sort intervals by start time to enable greedy merging
    // MUST sort by start time — otherwise can't greedily process
    Array.Sort(intervals, (a, b) => a[0] - b[0]);
    var result = new List<int[]>();
    // STEP 2: Seed result with the first interval
    result.Add(intervals[0]);  // start with first interval

    // STEP 3: Scan remaining intervals — merge if overlapping, else append new
    foreach (int[] interval in intervals.Skip(1)) {
        int[] last = result[^1]; // C# index-from-end: last element

        if (interval[0] <= last[1]) {
            // STEP 4: Overlap detected — extend current interval's end
            // OVERLAP: current interval starts before last one ends
            // Merge by extending the end if needed
            last[1] = Math.Max(last[1], interval[1]);
        } else {
            // STEP 5: No overlap — start a new interval in the result
            // NO OVERLAP: start a new interval group
            result.Add(interval);
        }
    }
    return result.ToArray();
}
// Time: O(n log n) for sort + O(n) merge sweep = O(n log n)
// Space: O(n) for result
```

> **🎯 Key Insight:** Sort first (by start time), then a single linear sweep merges everything. The key condition: `interval[0] <= last[1]` (new interval starts before current one ends = overlap). Merge by taking the maximum end: `Max(last[1], interval[1])` handles fully-contained intervals too.

---

## Section 40 — Cyclic Sort

> **🧠 Mental Model: Returning Library Books**
>
> Given n books numbered 1 to n in random order, return each to its correct shelf. Put book i at position i-1. After one pass, every book is either in place or you can detect which ones are missing/duplicated.

```
CYCLIC SORT on [3,1,2,5,4]:
═══════════════════════════════════════════════════════════════
  i=0: arr[0]=3, correct pos=2. arr[0]!=arr[2]? swap → [2,1,3,5,4]
  i=0: arr[0]=2, correct pos=1. arr[0]!=arr[1]? swap → [1,2,3,5,4]
  i=0: arr[0]=1, correct pos=0. Already correct! move i++
  i=1: arr[1]=2, pos=1. Correct → i++
  i=2: arr[2]=3, pos=2. Correct → i++
  i=3: arr[3]=5, pos=4. swap → [1,2,3,4,5]
  i=3: arr[3]=4, pos=3. Correct → i++
  Result: [1,2,3,4,5] — sorted! Now scan for missing/duplicates
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Find All Duplicates in Array (LeetCode #442 — Medium)

**Problem:** Array of n integers in range [1,n]. Each integer appears once or twice. Find all duplicates in O(n) time and O(1) extra space.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: FIND ALL DUPLICATES                         ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 HASHSET  │ Store seen values       │ O(n)      │ O(n) sp ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 NEGATIVE │ Use array as hash: mark │ O(n)      │ O(1) sp ║
║  MARKING     │ visited by negating     │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Values are in [1,n], so use value as index.
             When visiting value v, negate arr[v-1].
             If arr[v-1] is already negative → v was seen before → duplicate!
```

> **🔑 CORE IDEA:** Values are in [1,n], so use index = value−1 as a position marker. Negate nums[value−1] when visiting; if already negative, value appeared twice.

```csharp
public IList<int> FindDuplicates(int[] nums) {
    var result = new List<int>();

    foreach (int num in nums) {
        // STEP 1: Map value to its corresponding index (values in [1,n] → indices in [0,n-1])
        // WHY Math.Abs? The value might already be negated from a previous visit
        int idx = Math.Abs(num) - 1;  // map value to index (1-indexed → 0-indexed)

        // STEP 2: Check sign at that index — negative means the value was seen before
        if (nums[idx] < 0) {
            // Already negated → we've seen this value before → it's a duplicate!
            result.Add(Math.Abs(num));
        } else {
            // STEP 3: Mark as visited by negating the value at the mapped index
            nums[idx] = -nums[idx];  // negate to mark "I've seen value idx+1"
        }
    }
    return result;
}
// Time: O(n), Space: O(1) extra (modifies input array)
```

> **🎯 Key Insight:** "Use the value as an index and negate to mark visited" is the classic O(1) space trick for arrays with values in [1,n]. It piggybacks on the input array itself as a visited marker. Restore the array by taking absolute values afterward if needed.

---

## Section 41 — In-place Linked List Reversal

> **🧠 Mental Model: Flipping Playing Cards**
>
> Reverse a hand of cards by flipping them group by group. For k-group reversal, flip k cards at a time, then move to the next group. The challenge: track where each group starts/ends and reconnect groups after flipping.

---

### 🔴 Practice Problem: Reverse Nodes in k-Group (LeetCode #25 — Hard)

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: REVERSE NODES IN K-GROUP                    ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 ARRAY    │ Copy to array, reverse  │ O(n)      │ O(n) sp ║
║              │ in chunks, rebuild      │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 IN-PLACE │ Reverse k nodes at a    │ O(n)      │ O(1) sp ║
║  REVERSAL    │ time, reconnect groups  │            │ (O(n/k) ║
║  (OPTIMAL)   │                         │            │ recursion)║
╚══════════════════════════════════════════════════════════════════╝

VISUALIZATION: [1→2→3→4→5], k=2
  Group 1: [1→2] → reverse → [2→1], connect to reversed Group 2
  Group 2: [3→4] → reverse → [4→3], connect to remaining [5]
  Group 3: [5] → less than k, leave as-is
  Result: [2→1→4→3→5] ✅
```

> **🔑 CORE IDEA:** Verify k nodes exist (else leave as-is). Reverse k nodes using prev/curr/next in-place. Connect reversed group's tail to the result of recursing on the remainder.

```csharp
public ListNode ReverseKGroup(ListNode head, int k) {
    // STEP 1: Verify at least k nodes remain — if not, return as-is
    int count = 0;
    ListNode curr = head;
    while (curr != null && count < k) { curr = curr.next; count++; }

    if (count < k) return head;  // fewer than k nodes remaining → don't reverse

    // STEP 2: Reverse exactly k nodes in-place using prev/node/next pointer dance
    // Reverse k nodes starting from head
    ListNode prev = null, node = head;
    for (int i = 0; i < k; i++) {
        ListNode next = node.next;
        node.next = prev;
        prev = node;
        node = next;
    }
    // After reversal: prev = new head of this group, head = old head (now tail)
    // node = start of the next group (unconsumed)

    // STEP 3: Recursively handle the next group and attach it to current group's tail
    // Recursively reverse the next group and attach to current group's tail
    // head is now the TAIL of the reversed group (was the head before reversal)
    head.next = ReverseKGroup(node, k);

    // STEP 4: Return prev — the new head of this reversed group
    return prev;  // prev is the new head of this reversed group
}
// Time: O(n), Space: O(n/k) recursion stack
```

> **🎯 Key Insight:** After reversing k nodes, the old head becomes the new tail of this group. Connect it to the recursively-reversed next group. This is why we pass `head` (old head = new tail) to the next recursive call connection.

---

## Section 42 — Modified Binary Search

> **🧠 Mental Model: Searching a Twisted Sorted Array**
>
> Standard binary search needs a fully sorted array. Modified binary search handles arrays with a twist: rotated, bitonic (up then down), or unknown-length. The key: always determine which half is "normal" (sorted/predictable) and use that to decide which half to search.

---

### 🔴 Practice Problem: Find Minimum in Rotated Sorted Array (LeetCode #153 — Medium)

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: FIND MINIMUM IN ROTATED ARRAY               ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 LINEAR   │ Scan all elements       │ O(n)      │ O(1) sp ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BINARY   │ Compare mid to right to │ O(log n)  │ O(1) sp ║
║  SEARCH      │ determine which half    │            │         ║
║  (OPTIMAL)   │ contains the minimum    │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: The minimum is always at the "rotation point" where sorted
             order breaks. If arr[mid] > arr[right], min is in RIGHT half.
             If arr[mid] <= arr[right], min is in LEFT half (including mid).
```

> **🔑 CORE IDEA:** Compare mid to right boundary (not left!). If arr[mid] > arr[right], minimum is strictly in the right half; otherwise it's in the left half including mid.

```csharp
public int FindMin(int[] nums) {
    // STEP 1: Set binary search boundaries
    int left = 0, right = nums.Length - 1;

    // STEP 2: Compare mid to right boundary to determine which half holds the minimum
    while (left < right) {   // WHY strict < ? When left==right, we found the min
        int mid = left + (right - left) / 2;

        if (nums[mid] > nums[right]) {
            // STEP 3: mid > right means rotation point is in the right half
            // RIGHT half contains the rotation point (and the minimum)
            // nums[mid] > nums[right] means the "dip" is in the right half
            left = mid + 1;
        } else {
            // STEP 4: mid <= right means left half (including mid) contains the minimum
            // LEFT half contains the minimum (mid might BE the minimum)
            right = mid;  // WHY not mid-1? mid itself could be the answer
        }
    }
    // STEP 5: Convergence — left == right is the minimum index
    return nums[left];  // left == right == minimum index
}
```

```
TRACE: nums=[4,5,6,7,0,1,2]
════════════════════════════════════════════════════════════
  left=0,right=6: mid=3, nums[3]=7>nums[6]=2 → left=4
  left=4,right=6: mid=5, nums[5]=1<=nums[6]=2 → right=5
  left=4,right=5: mid=4, nums[4]=0<=nums[5]=1 → right=4
  left=4==right=4 → return nums[4]=0 ✅
════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Compare `nums[mid]` to `nums[right]` (not `nums[left]`). If mid > right, the sorted order broke in the right half — min is there. Otherwise, right half is already in order relative to left — min is in left half. Never compare to `nums[left]` because the pivot complicates that comparison.

---

## Section 43 — Top K Elements & K-way Merge

> **🧠 Mental Model: Sports Tournament Seeding**
>
> Top K problems are like tournament seeding — you want the top k players without sorting all n players. A min-heap of size k maintains the current top-k, efficiently replacing the smallest when a better candidate arrives.

---

### 🔴 Practice Problem: Top K Frequent Elements (LeetCode #347 — Medium)

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: TOP K FREQUENT ELEMENTS                     ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 SORT     │ Count freq, sort by     │ O(n log n)│ O(n) sp ║
║              │ frequency, take top k   │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 MIN HEAP │ Count freq, min-heap    │ O(n log k)│ O(n) sp ║
║  SIZE K      │ of size k               │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BUCKET   │ Bucket sort by freq     │ O(n)      │ O(n) sp ║
║  SORT        │ index = frequency       │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Bucket sort by frequency: bucket[freq] = list of elements. Sweep buckets from index n down to 1 collecting elements until k are found. O(n) time.

```csharp
public int[] TopKFrequent(int[] nums, int k) {
    // STEP 1: Count frequency of each element using a HashMap
    // WHY GetValueOrDefault? Avoids KeyNotFoundException on first encounter of each number
    var freq = new Dictionary<int, int>();
    foreach (int num in nums)               // WHY 'num' not 'n'? Avoids confusion with array-length 'n'
        freq[num] = freq.GetValueOrDefault(num, 0) + 1;

    // STEP 2: Bucket sort — place each number into bucket[its_frequency]
    // bucket[i] = list of numbers with frequency i
    // Max possible frequency = nums.Length
    var buckets = new List<int>[nums.Length + 1];
    foreach (var (num, count) in freq) {
        if (buckets[count] == null) buckets[count] = new List<int>();
        buckets[count].Add(num);
    }

    // STEP 3: Collect top k elements by sweeping buckets from highest frequency down
    var result = new List<int>();
    for (int i = buckets.Length - 1; i >= 0 && result.Count < k; i--) {
        if (buckets[i] != null) result.AddRange(buckets[i]);
    }
    return result.Take(k).ToArray();
}
// Time: O(n), Space: O(n)
```

> **🎯 Key Insight:** Bucket sort by frequency achieves O(n) because frequencies are bounded by array length (at most n distinct frequencies). The bucket index IS the frequency, enabling direct placement.

---

## Section 44 — Monotonic Stack & Queue

> **🧠 Mental Model: A One-Way Conveyor Belt**
>
> A monotonic stack maintains elements in strictly increasing or decreasing order. Like a conveyor belt where larger items push smaller ones off: when a new larger item arrives, all smaller items in front get discarded (they'll never be the answer for future queries).

```
NEXT GREATER ELEMENT visualization: [2,1,5,3,6]
═══════════════════════════════════════════════════════════════
  Process 2: stack=[] → push 2    → stack=[2]
  Process 1: 1<2 → push 1         → stack=[2,1]
  Process 5: 5>1 → pop 1(answer=5), 5>2 → pop 2(answer=5)
             → stack=[], push 5   → stack=[5]
  Process 3: 3<5 → push 3         → stack=[5,3]
  Process 6: 6>3 → pop 3(answer=6), 6>5 → pop 5(answer=6)
             → stack=[], push 6   → stack=[6]
  End: remaining stack elements have no greater → answer=-1

  Result: [2→5, 1→5, 5→6, 3→6, 6→-1]
═══════════════════════════════════════════════════════════════
```

---

### 🔴🔥 Practice Problem: Daily Temperatures (LeetCode #739 — Medium) — MUST SOLVE

**Problem:** Given daily temperatures, return array where `answer[i]` = days until warmer temperature.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: DAILY TEMPERATURES                          ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ For each day scan       │ O(n²)     │ O(1) sp ║
║              │ forward for warmer day  │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 MONO.    │ Decreasing stack of     │ O(n)      │ O(n) sp ║
║  STACK       │ indices; pop when warmer│            │         ║
║  (OPTIMAL)   │ day found               │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Monotonic decreasing stack of indices. For each day, while current temp > stack-top's temp, pop and record gap as the answer. Push current index.

```csharp
public int[] DailyTemperatures(int[] temperatures) {
    int[] answer = new int[temperatures.Length];
    // STEP 1: Initialize a monotonically decreasing stack of indices waiting for a warmer day
    // Stack stores INDICES of temperatures waiting for their "warmer day"
    var stack = new Stack<int>(); // monotonically decreasing temperatures

    for (int i = 0; i < temperatures.Length; i++) {
        // STEP 2: Pop all indices whose temperature is less than today's — today is their answer
        // WHY pop while stack top is cooler than current?
        // Current day (i) is the FIRST warmer day for all popped indices
        while (stack.Count > 0 && temperatures[stack.Peek()] < temperatures[i]) {
            int prevIdx = stack.Pop();
            answer[prevIdx] = i - prevIdx;  // days waited = current index - previous index
        }
        // STEP 3: Push current index — it's now waiting for its own warmer day
        stack.Push(i);  // push current index (it's waiting for its warmer day)
    }
    // Remaining stack indices never found a warmer day → answer stays 0
    return answer;
}
// Time: O(n) — each index pushed/popped at most once
// Space: O(n) — stack stores at most n indices
```

```
TRACE: temperatures=[73,74,75,71,69,72,76,73]
════════════════════════════════════════════════════════════
  i=0(73): stack=[] → push 0.   stack=[0]
  i=1(74): 74>73 → pop 0: ans[0]=1-0=1. stack=[] → push 1.   stack=[1]
  i=2(75): 75>74 → pop 1: ans[1]=2-1=1. stack=[] → push 2.   stack=[2]
  i=3(71): 71<75 → push 3.   stack=[2,3]
  i=4(69): 69<71 → push 4.   stack=[2,3,4]
  i=5(72): 72>69 → pop 4: ans[4]=5-4=1. 72>71 → pop 3: ans[3]=5-3=2.
           72<75 → stop. push 5.   stack=[2,5]
  i=6(76): 76>72 → pop 5: ans[5]=6-5=1. 76>75 → pop 2: ans[2]=6-2=4.
           stack=[] → push 6.   stack=[6]
  i=7(73): 73<76 → push 7.   stack=[6,7]
  End: indices 6,7 in stack → ans[6]=ans[7]=0
  Result: [1,1,4,2,1,1,0,0] ✅
════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Monotonic stack solves "next greater/smaller element" in O(n). The stack maintains a "waiting list" of indices that haven't found their answer yet. When a new element is larger, it's the answer for everything smaller in the stack. This pattern appears in: stock span, largest rectangle in histogram, trapping rain water.

---

## Section 45 — Bit Manipulation

> **🧠 Mental Model: Light Switches on a Panel**
>
> Bits are binary switches: 0=off, 1=on. Bit operations work on ALL switches simultaneously in one CPU instruction — incredibly fast. XOR is especially powerful: `a XOR a = 0` (self-cancel) and `a XOR 0 = a` (identity). These properties power many O(n) time, O(1) space solutions.

```
BIT OPERATIONS CHEAT SHEET:
═══════════════════════════════════════════════════════════════
  n  = ...0101 0110  (binary representation)
  n-1= ...0101 0101  (flips last set bit and all below)
  n&(n-1) clears the lowest set bit of n
  n&(-n)  isolates the lowest set bit of n

  COMMON TRICKS:
  n & 1        → check if n is odd (last bit)
  n >> 1       → divide by 2 (right shift)
  n << 1       → multiply by 2 (left shift)
  n & (n-1)==0 → n is a power of 2 (only one bit set)
  a ^ b ^ a    → b  (XOR is self-inverse: a cancels itself)
  a ^ 0        → a  (XOR with 0 is identity)

  XOR MAGIC for finding single unique number:
  2 XOR 2 = 0, 3 XOR 3 = 0, 5 XOR 0 = 5
  [2,2,3,3,5] → 2^2^3^3^5 = 0^0^5 = 5 ← the unique one!
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Single Number (LeetCode #136 — Easy)

**Problem:** Every element appears twice except one. Find that element in O(n) time and O(1) space.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: SINGLE NUMBER                               ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 HASHSET  │ Track seen values,      │ O(n)      │ O(n) sp ║
║              │ return the unmatched    │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 SORT     │ Sort, scan pairs        │ O(n log n)│ O(1) sp ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 XOR      │ XOR all: pairs cancel   │ O(n)      │ O(1) sp ║
║  (OPTIMAL)   │ leaving single element  │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** XOR: n⊕n=0 and n⊕0=n. XOR all elements together; every duplicate cancels to 0, leaving only the single number.

```csharp
public int SingleNumber(int[] nums) {
    // STEP 1: XOR all elements — duplicate pairs cancel to 0, single element remains
    int result = 0;
    foreach (int n in nums)
        result ^= n;  // XOR each number: pairs cancel (n^n=0), single remains
    return result;
}
// Time: O(n), Space: O(1) — the most elegant solution in DSA!
```

```
TRACE: nums=[4,1,2,1,2]
════════════════════════════════════════════════════════════
  result=0
  result^=4 → result=4    (binary: 100)
  result^=1 → result=5    (binary: 101)
  result^=2 → result=7    (binary: 111)
  result^=1 → result=6    (binary: 110)  (1^1=0 cancels)
  result^=2 → result=4    (binary: 100)  (2^2=0 cancels)
  Answer: 4 ✅
════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** XOR's two magic properties — self-inverse (a^a=0) and identity (a^0=a) — mean XORing all numbers cancels all duplicates, leaving only the unique element. No extra space needed. This is a rare problem where the bitwise trick gives a clean, provably correct O(1) space solution.

---

## Section 46 — Subsets & Combinations

> **🧠 Mental Model: Binary Choice Tree**
>
> For each element, you have a binary choice: include it or exclude it. A set of n elements has 2ⁿ subsets. Backtracking explores this binary choice tree systematically.

---

### 🔴 Practice Problem: Subsets II (LeetCode #90 — Medium)

**Problem:** Return all possible subsets of an array that MAY contain duplicates. No duplicate subsets in result.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: SUBSETS II (WITH DUPLICATES)                ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 GENERATE │ Generate all subsets,   │ O(2^n×n)  │ O(2^n×n)║
║  ALL + DEDUP │ add to set to dedup     │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 BACKTRACK│ Sort first; skip dup    │ O(2^n×n)  │ O(n) sp ║
║  + SKIP DUP  │ values at same level    │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Sort first, then SKIP an element if it's the same as the
             previous element AT THE SAME RECURSION LEVEL (not same as
             parent level). This prevents generating duplicate subsets.
```

> **🔑 CORE IDEA:** Sort first (groups duplicates). In backtracking, skip an element if it equals the previous at the same recursion depth (i > start && nums[i] == nums[i−1]).

```csharp
public IList<IList<int>> SubsetsWithDup(int[] nums) {
    // STEP 1: Sort to group duplicates adjacent to each other
    Array.Sort(nums);  // MUST sort to group duplicates together
    var result = new List<IList<int>>();
    var current = new List<int>();
    Backtrack(0);
    return result;

    void Backtrack(int start) {
        // STEP 2: Record current state as a valid subset before extending
        result.Add(new List<int>(current)); // add current subset (snapshot!)
        for (int i = start; i < nums.Length; i++) {
            // STEP 3: Skip duplicate value at the same recursion level to avoid duplicate subsets
            // SKIP DUPLICATE: if nums[i] == nums[i-1] and we're at the same
            // recursion level (i > start, not i > 0!), it would produce duplicate subset
            // WHY i > start? If i == start, this is the FIRST time we pick from this level
            // — it's OK. Only skip if it's not the first choice at this level.
            if (i > start && nums[i] == nums[i-1]) continue;

            // STEP 4: CHOOSE, EXPLORE, UN-CHOOSE
            current.Add(nums[i]);
            Backtrack(i + 1);
            current.RemoveAt(current.Count - 1);
        }
    }
}
// Time: O(2^n × n) — 2^n subsets, each takes O(n) to copy
// Space: O(n) recursion + O(2^n × n) for output
```

> **🎯 Key Insight:** The dedup condition is `i > start` (not `i > 0`). This means "skip if same as previous AND we're not at the very first pick for this level." At `start`, we must try the element even if it's a duplicate of what came before (that was a DIFFERENT level). This subtle distinction prevents over-skipping.

---

## Section 47 — Math & Number Theory

> **🧠 Mental Model: The Sieve of Eratosthenes — Crossing Out Multiples**
>
> To find all primes up to n: start with 2 (first prime), cross out all its multiples. Move to next uncrossed number (3), cross out ITS multiples. Continue. Every uncrossed number is prime. O(n log log n) — each number is crossed out at most once per prime factor.

```
SIEVE VISUALIZATION (n=30):
═══════════════════════════════════════════════════════════════
  2 3 [4] 5 [6] 7 [8] [9] [10] 11 [12] 13 [14] [15] [16]
  17 [18] 19 [20] [21] [22] 23 [24] [25] [26] [27] [28] 29 [30]
  [crossed out = composite]

  Primes: 2,3,5,7,11,13,17,19,23,29 ✅
  WHY only sieve up to √n? If n=p×q and p≤q, then p≤√n.
  So any composite n has a prime factor ≤ √n.
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Count Primes (LeetCode #204 — Medium)

**Problem:** Count primes strictly less than n.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: COUNT PRIMES                                ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 TRIAL    │ For each i, check if    │ O(n√n)    │ O(1) sp ║
║  DIVISION    │ prime by trial division │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 SIEVE    │ Sieve of Eratosthenes   │ O(n log   │ O(n) sp ║
║  (OPTIMAL)   │ mark composites in bulk │  log n)   │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Sieve of Eratosthenes: start with all true; for prime p, mark p², p²+p, p²+2p... as false. Start marking from p² (all smaller multiples already marked).

```csharp
public int CountPrimes(int n) {
    if (n < 2) return 0;
    // STEP 1: Initialize sieve — all entries start as "not composite" (potential primes)
    bool[] isComposite = new bool[n]; // isComposite[i]=true means i is NOT prime
    // 0 and 1 are not prime, but we count starting from 2

    // STEP 2: For each prime p up to √n, mark all its multiples from p² onward as composite
    // WHY i*i <= n? Optimization: if i is prime, its smallest composite multiple
    // is i*i (all smaller multiples already marked by smaller primes)
    for (int i = 2; (long)i * i < n; i++) {
        if (!isComposite[i]) {           // i is prime
            // Mark all multiples of i as composite
            // WHY start from i*i? Multiples i*2, i*3, ... i*(i-1) already marked
            for (int j = i * i; j < n; j += i)
                isComposite[j] = true;
        }
    }

    // STEP 3: Count all unmarked entries (primes) in range [2, n)
    int count = 0;
    for (int i = 2; i < n; i++)
        if (!isComposite[i]) count++;
    return count;
}
// Time: O(n log log n), Space: O(n)
```

> **🎯 Key Insight:** Two optimizations make the sieve fast: (1) outer loop only to √n — larger factors already covered; (2) inner loop starts at i×i — smaller multiples already marked by previous primes. These aren't just small speedups — they determine whether the algorithm is practical for large n.

---

# PART 10 — STRING ALGORITHMS

---

## Section 48 — String Patterns (Anagram, Palindrome, Rolling Hash)

> **🧠 Mental Model: Fingerprinting Documents**
>
> A hash is like a document fingerprint — a compact representation that's easy to compare. Two documents with the same fingerprint are (almost certainly) identical. Rolling hash updates the fingerprint as a window slides right in O(1) — adding the new right character and removing the old left character arithmetically.

```
ROLLING HASH CONCEPT:
═══════════════════════════════════════════════════════════════
  Window "abc" has hash = a×p² + b×p + c
  Next window "bcd": remove 'a', add 'd'
  new_hash = (old_hash - a×p²) × p + d
           = b×p² + c×p + d
  → O(1) update! Used in Rabin-Karp string search.

  ANAGRAM CHECK using frequency array:
  "anagram" and "nagaram" are anagrams ↔ same char frequencies
  [1,0,0,0,0,...,1,1,2,0,...] = [1,0,0,0,0,...,1,1,2,0,...]  ✓
═══════════════════════════════════════════════════════════════
```

### Key String Patterns in C#

```csharp
// ═══ ANAGRAM CHECK ═══
bool IsAnagram(string s, string t) {
    // STEP 1: Early exit if lengths differ — can't be anagrams
    if (s.Length != t.Length) return false;
    // STEP 2: Increment counts for s, decrement for t — anagram iff all zero
    int[] count = new int[26];
    foreach (char c in s) count[c - 'a']++;  // increment for s
    foreach (char c in t) count[c - 'a']--;  // decrement for t
    return count.All(x => x == 0);           // all should balance to 0
}

// ═══ PALINDROME CHECK ═══
bool IsPalindrome(string s) {
    // STEP 1: Two-pointer from both ends — compare and converge
    int left = 0, right = s.Length - 1;
    while (left < right) {
        if (s[left] != s[right]) return false;
        left++; right--;
    }
    return true;
}

// ═══ PALINDROME CHECK — only alphanumeric ═══
bool IsPalindromeAlnum(string s) {
    // STEP 1: Two pointers — skip non-alphanumeric, compare case-insensitively
    int left = 0, right = s.Length - 1;
    while (left < right) {
        // STEP 2: Advance left past non-alphanumeric characters
        while (left < right && !char.IsLetterOrDigit(s[left])) left++;
        // STEP 3: Retreat right past non-alphanumeric characters
        while (left < right && !char.IsLetterOrDigit(s[right])) right--;
        // STEP 4: Compare current valid characters case-insensitively
        if (char.ToLower(s[left]) != char.ToLower(s[right])) return false;
        left++; right--;
    }
    return true;
}
```

---

### 🔴 Practice Problem: Minimum Window Substring (LeetCode #76 — Hard)

**Problem:** Given strings `s` and `t`, find the minimum window in `s` containing all characters of `t`.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: MINIMUM WINDOW SUBSTRING                    ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Check all O(n²) substr- │ O(n²×m)   │ O(m) sp ║
║              │ ings for containing t   │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 SLIDING  │ Expand right until      │ O(n+m)    │ O(m) sp ║
║  WINDOW      │ valid; contract left    │            │         ║
║  (OPTIMAL)   │ while still valid       │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Two-phase sliding window:
  PHASE 1: Expand right until window contains all chars of t
  PHASE 2: Contract left as much as possible while still valid
  Repeat, tracking minimum valid window seen
```

> **🔑 CORE IDEA:** Two-frequency-map sliding window: expand right until all required chars are covered (have[c] ≥ need[c]); then shrink left minimizing window while still covered.

```
VISUALIZATION: s="ADOBECODEBANC", t="ABC"
═══════════════════════════════════════════════════════════════
  Expand until contains A,B,C:
  ADOBEC  → has A,B,C ✓ → start contracting

  Contract: remove A → DOBEC → missing A
  Expand right: DOBECOD → DOBECODE → DOBECODEN → DOBECODEBAN → has A,B,C ✓
  Contract: OBECODEBAN → ... → BANC → has A,B,C ✓ and length=4 (minimum!)
  Continue expanding but can't do better
  Answer: "BANC"
═══════════════════════════════════════════════════════════════
```

```csharp
public string MinWindow(string s, string t) {
    if (s.Length < t.Length) return "";

    // STEP 1: Build frequency map of required characters from t
    // Count required characters from t
    var need = new Dictionary<char, int>();
    foreach (char c in t) need[c] = need.GetValueOrDefault(c, 0) + 1;

    int have = 0;              // how many chars from t are satisfied in current window
    int required = need.Count; // how many DISTINCT chars from t we need to satisfy
    var window = new Dictionary<char, int>(); // counts in current window

    int minLen = int.MaxValue, minStart = 0;
    int left = 0;

    for (int right = 0; right < s.Length; right++) {
        // STEP 2: Expand right — add character and check if it satisfies a requirement
        char c = s[right];
        window[c] = window.GetValueOrDefault(c, 0) + 1;

        // Check if this char's frequency in window satisfies t's requirement
        if (need.ContainsKey(c) && window[c] == need[c])
            have++;  // one more distinct char fully satisfied

        // STEP 3: When window is fully valid, shrink from left to minimize length
        // While window is valid (all t's chars satisfied), try to shrink from left
        while (have == required) {
            // STEP 4: Record window size if it's the smallest valid window seen
            // Update minimum window
            if (right - left + 1 < minLen) {
                minLen = right - left + 1;
                minStart = left;
            }

            // STEP 5: Remove leftmost character; if it breaks a requirement, stop shrinking
            // Remove leftmost character and potentially invalidate window
            char leftChar = s[left];
            window[leftChar]--;
            if (need.ContainsKey(leftChar) && window[leftChar] < need[leftChar])
                have--;  // window no longer satisfies this char's requirement
            left++;
        }
    }

    return minLen == int.MaxValue ? "" : s.Substring(minStart, minLen);
}
// Time: O(n + m) — each char in s is added/removed from window at most once
// Space: O(m) — window and need dictionaries (bounded by distinct chars in t)
```

```
TRACE: s="ADOBECODEBANC", t="ABC", need={A:1,B:1,C:1}, required=3
════════════════════════════════════════════════════════════
  Expand right=0..4: window builds up, have<3
  right=5('C'): window={A:1,D:1,O:1,B:1,E:1,C:1}, have=3 ✓
    Contract: left=0('A'): window[A]=0 < need[A]=1 → have=2, left=1
    minLen=6("ADOBEC"), minStart=0

  Expand right=6..9: have<3
  right=10('A'): have=3 ✓
    Contract: ... eventually left="B" position
    minLen=7, then keep comparing

  right=11..12: found "BANC" as minimum ✅
  Answer: "BANC" (length=4)
════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Minimum window is the hardest sliding window problem. The key data structure: track `have` (satisfied distinct chars) vs `required` (total distinct chars needed). The window is valid exactly when `have == required`. Only then do we try to shrink — this ensures we always have the minimum valid window.

---

## Section 49 — Advanced String Matching (KMP, Rabin-Karp)

> **🧠 Mental Model: Never Repeat Work**
>
> Naive string matching is O(n×m) — slide pattern one position at a time, restart from beginning on mismatch. KMP eliminates this redundancy: when a mismatch occurs, use partial matches already done to skip ahead. The LPS (Longest Proper Prefix that is also Suffix) array is the key pre-computation.

```
KMP — LPS ARRAY CONSTRUCTION for pattern "AABAAB":
═══════════════════════════════════════════════════════════════
  pattern: A  A  B  A  A  B
  index:   0  1  2  3  4  5
  lps:     0  1  0  1  2  3

  lps[i] = length of longest proper prefix of pattern[0..i]
           that is also a suffix of pattern[0..i]
  "A"    → lps=0 (no proper prefix)
  "AA"   → lps=1 ("A" is both prefix and suffix)
  "AAB"  → lps=0 (no match)
  "AABA" → lps=1 ("A")
  "AABAA"→ lps=2 ("AA")
  "AABAAB"→lps=3 ("AAB")

  MISMATCH USE: if mismatch at pattern index j, don't restart from 0.
  Jump to lps[j-1] — you've already matched that much!
═══════════════════════════════════════════════════════════════
```

---

### 🔴 Practice Problem: Find Index of First Occurrence (LeetCode #28 — Easy)

**Problem:** Find first occurrence of `needle` in `haystack`. Return -1 if not found.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: STRING SEARCH                               ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BUILT-IN │ haystack.IndexOf(needle)│ O(n×m)    │ O(1) sp ║
║  / NAIVE     │ or naive sliding window │ avg O(n)  │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 RABIN-   │ Rolling hash comparison │ O(n+m)    │ O(1) sp ║
║  KARP        │ O(n×m) worst case       │ avg case  │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 KMP      │ LPS array + linear scan │ O(n+m)    │ O(m) sp ║
║  (OPTIMAL)   │ guaranteed O(n+m)       │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** KMP precomputes LPS (Longest Proper Prefix = Suffix) for the pattern. On mismatch at pattern[j], jump to pattern[lps[j−1]] instead of restarting — never re-scan matched prefix.

```csharp
public int StrStr(string haystack, string needle) {
    if (needle.Length == 0) return 0;
    if (haystack.Length < needle.Length) return -1;

    // KMP STEP 1: Build LPS (Longest Proper Prefix-Suffix) array for needle
    int m = needle.Length;
    int[] lps = new int[m];
    // lps[0] always = 0 (single char has no proper prefix)

    // STEP 2: Fill LPS using two-pointer matching within the pattern itself
    int len = 0, i = 1;   // len = current match length
    while (i < m) {
        if (needle[i] == needle[len]) {
            lps[i++] = ++len;  // extend the matching prefix
        } else if (len > 0) {
            // STEP 3: Mismatch after partial match — fall back via LPS (don't advance i)
            len = lps[len - 1]; // mismatch: fall back to previous match
            // WHY not i--? We already know needle[i] doesn't match needle[len]
            // Trying needle[lps[len-1]] might work — don't advance i yet
        } else {
            lps[i++] = 0;  // no match possible, move to next char
        }
    }

    // KMP STEP 4: Search haystack using LPS to skip re-scanning matched prefix
    int n = haystack.Length;
    i = 0;       // index in haystack
    int j = 0;   // index in needle

    while (i < n) {
        if (haystack[i] == needle[j]) {
            i++; j++;
            // STEP 5: Full pattern matched — return start index
            if (j == m) return i - m;  // full match found! return start index
        } else if (j > 0) {
            // STEP 6: Mismatch after partial match — use LPS to jump, keep i
            j = lps[j - 1];  // mismatch after some matches: use LPS to skip
            // WHY not i--? We don't move back in haystack! That's KMP's power.
        } else {
            i++;  // needle[0] didn't match haystack[i], advance haystack
        }
    }
    return -1;
}
// Time: O(n+m) — O(m) to build LPS, O(n) to search
// Space: O(m) for LPS array
```

```
TRACE: haystack="AAACAAAB", needle="AAAB"
  LPS for "AAAB": [0,1,2,0]

  i=0,j=0: A==A → i=1,j=1
  i=1,j=1: A==A → i=2,j=2
  i=2,j=2: A==A → i=3,j=3
  i=3,j=3: C!=B → j=lps[2]=2 (backtrack to length 2, haystack stays at 3)
  i=3,j=2: C!=A → j=lps[1]=1
  i=3,j=1: C!=A → j=lps[0]=0
  i=3,j=0: C!=A → i=4
  i=4,j=0: A==A → i=5,j=1
  i=5,j=1: A==A → i=6,j=2
  i=6,j=2: A==A → i=7,j=3
  i=7,j=3: B==B → i=8,j=4 → j==m=4 → return 8-4=4 ✅
```

> **🎯 Key Insight:** KMP's genius is the LPS array — it tells you how much of the pattern you've "pre-matched" at any mismatch point, so you never restart from zero. The haystack index i NEVER goes backward. This guarantees O(n) traversal of the haystack regardless of mismatches.

---

# PART 11 — INTERVIEW REFERENCE

---

## Section 50 — Product Company Cheat Sheet & Interview Guide

### Big O Complexity Reference

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    BIG O CHEAT SHEET                                      ║
╠══════════════════╦══════════════════════════════════════════════════════╣
║ DATA STRUCTURE   ║ Access  Search  Insert  Delete  Space                 ║
╠══════════════════╬══════════════════════════════════════════════════════╣
║ Array            ║ O(1)    O(n)    O(n)    O(n)    O(n)                  ║
║ Dynamic Array    ║ O(1)    O(n)    O(1)†   O(n)    O(n)  †amortized      ║
║ Linked List      ║ O(n)    O(n)    O(1)*   O(1)*   O(n)  *with reference ║
║ Stack/Queue      ║ O(n)    O(n)    O(1)    O(1)    O(n)                  ║
║ HashMap          ║ N/A     O(1)†   O(1)†   O(1)†   O(n)  †average       ║
║ HashSet          ║ N/A     O(1)†   O(1)†   O(1)†   O(n)  †average       ║
║ BST (balanced)   ║ O(logn) O(logn) O(logn) O(logn) O(n)                  ║
║ BST (unbalanced) ║ O(n)    O(n)    O(n)    O(n)    O(n)  worst case     ║
║ Heap             ║ N/A     O(n)    O(logn) O(logn) O(n)                  ║
║ Trie             ║ O(m)    O(m)    O(m)    O(m)    O(n×m) m=key length   ║
╠══════════════════╬══════════════════════════════════════════════════════╣
║ ALGORITHM        ║ Best    Average  Worst   Space                         ║
╠══════════════════╬══════════════════════════════════════════════════════╣
║ Bubble Sort      ║ O(n)    O(n²)    O(n²)   O(1)                         ║
║ Selection Sort   ║ O(n²)   O(n²)    O(n²)   O(1)                         ║
║ Insertion Sort   ║ O(n)    O(n²)    O(n²)   O(1)   best for small/sorted ║
║ Merge Sort       ║ O(nlogn)O(nlogn) O(nlogn)O(n)   stable               ║
║ Quick Sort       ║ O(nlogn)O(nlogn) O(n²)   O(logn)unstable, in-place   ║
║ Heap Sort        ║ O(nlogn)O(nlogn) O(nlogn)O(1)   unstable             ║
║ Counting Sort    ║ O(n+k)  O(n+k)   O(n+k)  O(k)   k=range              ║
║ Radix Sort       ║ O(nk)   O(nk)    O(nk)   O(n+k) k=digits             ║
║ Binary Search    ║ O(1)    O(logn)  O(logn) O(1)                         ║
║ DFS/BFS          ║ O(V+E)  O(V+E)   O(V+E)  O(V)                         ║
║ Dijkstra         ║ O(ElogV)O(ElogV) O(ElogV)O(V)                         ║
╚══════════════════╩══════════════════════════════════════════════════════╝
```

### The UMPIRE Problem-Solving Checklist

```
╔══════════════════════════════════════════════════════════════════╗
║  INTERVIEW CHECKLIST (use this for EVERY problem)                ║
╠══════════════════════════════════════════════════════════════════╣
║  □ Read problem statement twice                                  ║
║  □ Write 2-3 concrete examples (including edge cases)            ║
║  □ State constraints: array size? value range? sorted? dupes?    ║
║  □ Identify which of the 14 patterns this matches               ║
║  □ State your approach BEFORE coding ("I'll use sliding window") ║
║  □ Write brute force approach first if stuck                     ║
║  □ State time and space complexity BEFORE coding                 ║
║  □ Code solution with clear variable names                       ║
║  □ Test with your examples step by step                         ║
║  □ Test edge cases: empty input, single element, all same        ║
║  □ Optimize if brute force won't pass                            ║
╚══════════════════════════════════════════════════════════════════╝
```

### Pattern Recognition Flowchart

```
START: What does the problem ask for?
═══════════════════════════════════════════════════════════════
  "Find two elements that..." + sorted array → TWO POINTERS
  "Subarray/substring with property..." → SLIDING WINDOW
  "Detect cycle / find middle" in linked list → FAST & SLOW
  "Overlapping intervals..." → MERGE INTERVALS
  "Find missing/duplicate in [1..n]" → CYCLIC SORT
  "Reverse linked list or part of it" → LL REVERSAL
  "Search in rotated/sorted-variant array" → MODIFIED BINARY SEARCH
  "Top K / Kth largest/smallest" → HEAP (SIZE K)
  "Next greater/smaller element" → MONOTONIC STACK
  "Single unique number / bit tricks" → BIT MANIPULATION
  "All subsets/combinations/permutations" → BACKTRACKING
  "Count primes / GCD" → MATH / NUMBER THEORY
  "Shortest path (unweighted)" → BFS
  "Shortest path (weighted)" → DIJKSTRA
  "Cycle in directed graph / dependency order" → DFS + TOPO SORT
  "Connected components" → UNION-FIND or DFS/BFS
  "Minimum/maximum count/cost of..." + subproblems → DP
  "Greedy choice provably optimal" → GREEDY
═══════════════════════════════════════════════════════════════
```

### FAANG Company-Specific Focus Areas

```
╔══════════════════════════════════════════════════════════════════╗
║  COMPANY       │ FOCUS AREAS                                     ║
╠══════════════════════════════════════════════════════════════════╣
║  Google        │ Graphs (all types), DP (complex multi-dim),    ║
║                │ String algorithms, System design integration   ║
╠══════════════════════════════════════════════════════════════════╣
║  Amazon        │ Arrays/Strings (heavy), Trees, OOP + DSA,      ║
║                │ Leadership principles in behavioral             ║
╠══════════════════════════════════════════════════════════════════╣
║  Microsoft     │ Trees (especially BST), DP, Arrays,            ║
║                │ System design for senior roles                  ║
╠══════════════════════════════════════════════════════════════════╣
║  Meta/Facebook │ Arrays (sliding window), Graphs (BFS/DFS),     ║
║                │ Recursion, Design questions                     ║
╠══════════════════════════════════════════════════════════════════╣
║  Apple         │ Arrays, Strings, Optimization, Algorithms,     ║
║                │ Focus on code quality and elegance              ║
╠══════════════════════════════════════════════════════════════════╣
║  Netflix       │ System design (heavy), Distributed systems,    ║
║                │ Streaming algorithms, Scalability              ║
╚══════════════════════════════════════════════════════════════════╝
```

### Top 20 Must-Know Problems

| # | Problem | LeetCode | Pattern | Key Trick |
|---|---------|----------|---------|-----------|
| 1 | Two Sum | 1 | HashMap | complement = target - num |
| 2 | Best Time to Buy Stock | 121 | Greedy | track min price so far |
| 3 | Contains Duplicate | 217 | HashSet | set size < array size |
| 4 | Maximum Subarray | 53 | Kadane's DP | extend or restart |
| 5 | Longest Substring No Repeat | 3 | Sliding Window | map char to last index |
| 6 | Valid Parentheses | 20 | Stack | LIFO matches nesting |
| 7 | Reverse Linked List | 206 | LL + 3 ptrs | prev/curr/next |
| 8 | Binary Search | 704 | Binary Search | left + (right-left)/2 |
| 9 | Number of Islands | 200 | Graph DFS | sink islands |
| 10 | Coin Change | 322 | DP | dp[i] = min coins |
| 11 | Product of Array Except Self | 238 | Prefix/Suffix | left × right products |
| 12 | 3Sum | 15 | Sort + 2 ptr | sort + skip dups |
| 13 | Climbing Stairs | 70 | DP Fibonacci | prev1 + prev2 |
| 14 | Merge Intervals | 56 | Sort + Merge | sort by start |
| 15 | Lowest Common Ancestor BST | 235 | BST | branch left/right by val |
| 16 | Word Search | 79 | Backtracking | DFS + visited marking |
| 17 | Course Schedule | 207 | Topo Sort | 3-color DFS cycle detect |
| 18 | LRU Cache | 146 | HashMap + DLL | O(1) get & put |
| 19 | Find Median from Data Stream | 295 | Two Heaps | max-heap + min-heap |
| 20 | Serialize/Deserialize Binary Tree | 297 | BFS/DFS | level-order encode |

### C# Gotchas for Interviews

```csharp
// ⚠️ GOTCHA 1: Integer Overflow
int a = int.MaxValue;
int b = a + 1;           // OVERFLOW! Use long or checked{}
long c = (long)a + 1;    // CORRECT

// ⚠️ GOTCHA 2: Mid calculation overflow
int mid = (left + right) / 2;    // WRONG: left+right may overflow!
int mid2 = left + (right - left) / 2;  // CORRECT

// ⚠️ GOTCHA 3: String concatenation in loops
string s = "";
for (int i = 0; i < n; i++) s += i;  // O(n²)! Creates new string each time
var sb = new StringBuilder();
for (int i = 0; i < n; i++) sb.Append(i);  // O(n) CORRECT

// ⚠️ GOTCHA 4: Array vs List modification during iteration
foreach (var item in list) list.Remove(item);  // InvalidOperationException!
for (int i = list.Count - 1; i >= 0; i--)  // iterate backwards when removing

// ⚠️ GOTCHA 5: Dictionary KeyNotFoundException
dict["missing"];                            // THROWS!
dict.GetValueOrDefault("missing", 0);       // SAFE: returns 0
dict.TryGetValue("key", out int val);       // SAFE: returns false if missing

// ⚠️ GOTCHA 6: Default values in arrays
int[] arr = new int[5];           // all zeros
bool[] visited = new bool[5];     // all false — CORRECT for visited array!
string[] strs = new string[5];    // all null (not ""!)

// ⚠️ GOTCHA 7: Char to int conversion
int idx = 'a' - 'a';   // 0
int idx2 = 'z' - 'a';  // 25
// NOT: (int)'a' == 97 (ASCII value, not 0-25 index!)

// ⚠️ GOTCHA 8: Null reference in linked list problems
ListNode next = curr.next;        // if curr is null → NullReferenceException!
ListNode next = curr?.next;       // null-safe: returns null if curr is null

// ⚠️ GOTCHA 9: Off-by-one in binary search
while (left < right) { ... }     // vs
while (left <= right) { ... }    // different semantics — be consistent!
// Rule: left < right for lower/upper bound; left <= right for classic search

// ⚠️ GOTCHA 10: Comparing strings
string a = "hello", b = "hel" + "lo";
bool eq1 = a == b;           // true (C# overloads == for value comparison)
bool eq2 = object.ReferenceEquals(a, b); // may be false (different objects)
// Always use == for string value comparison in C#
```

### 12-Week Interview Preparation Plan

```
╔══════════════════════════════════════════════════════════════════╗
║  WEEK 1-2:  FOUNDATIONS                                          ║
║  □ Big O analysis (Section 2-3)                                  ║
║  □ Arrays & Strings (Sections 5-6)                               ║
║  □ LeetCode Easy: Two Sum, Valid Parens, Reverse String          ║
╠══════════════════════════════════════════════════════════════════╣
║  WEEK 3-4:  LINEAR DATA STRUCTURES                               ║
║  □ Linked Lists, Stacks, Queues (Sections 7-9)                   ║
║  □ HashMap & HashSet (Sections 10-11)                            ║
║  □ LeetCode Medium: 3Sum, Group Anagrams, LRU Cache              ║
╠══════════════════════════════════════════════════════════════════╣
║  WEEK 5-6:  TREES & GRAPHS                                       ║
║  □ Binary Trees, BST, Heaps, Tries (Sections 12-15)              ║
║  □ Graph DFS/BFS, Shortest Path (Sections 17-19)                 ║
║  □ LeetCode Medium: Validate BST, Course Schedule, Num Islands   ║
╠══════════════════════════════════════════════════════════════════╣
║  WEEK 7-8:  ALGORITHMS                                           ║
║  □ Sorting & Binary Search (Sections 22-27)                      ║
║  □ Recursion & Backtracking (Sections 29-30)                     ║
║  □ LeetCode Medium: Merge Sort, Search Rotated, Letter Combos    ║
╠══════════════════════════════════════════════════════════════════╣
║  WEEK 9-10: DYNAMIC PROGRAMMING                                  ║
║  □ DP Memoization & Tabulation (Sections 32-34)                  ║
║  □ Classic DP: Knapsack, LCS, Edit Distance                      ║
║  □ LeetCode Medium/Hard: Coin Change, LCS, Word Break            ║
╠══════════════════════════════════════════════════════════════════╣
║  WEEK 11-12: PATTERNS & MOCK INTERVIEWS                          ║
║  □ All 14 patterns (Part 9 Sections 36-47)                       ║
║  □ 2 mock interviews/week (pramp.com, interviewing.io)           ║
║  □ LeetCode Hard: Trapping Rain Water, Word Ladder, Median Stream║
╚══════════════════════════════════════════════════════════════════╝
```

### LRU Cache — Bonus Problem (LeetCode #146 — Medium/Hard)

```
╔══════════════════════════════════════════════════════════════════╗
║  LRU CACHE DESIGN                                                ║
║  get(key): O(1) — return value or -1                             ║
║  put(key,val): O(1) — insert/update; evict LRU if over capacity  ║
║                                                                  ║
║  DATA STRUCTURE: HashMap + Doubly Linked List                    ║
║  HashMap: key → DLL node (O(1) lookup)                          ║
║  DLL: ordered by recency (head=MRU, tail=LRU)                   ║
╚══════════════════════════════════════════════════════════════════╝
```

```csharp
public class LRUCache {
    private class Node { public int key, val; public Node prev, next; }

    private Dictionary<int, Node> map = new();
    private Node head, tail;  // sentinel nodes (dummy head/tail)
    private int capacity;

    public LRUCache(int capacity) {
        // STEP 1: Initialize with dummy head/tail sentinels to simplify DLL edge cases
        this.capacity = capacity;
        head = new Node(); tail = new Node();
        head.next = tail; tail.prev = head;  // empty DLL
    }

    public int Get(int key) {
        // STEP 2: On cache hit, move node to front (mark as most recently used) then return value
        if (!map.ContainsKey(key)) return -1;
        MoveToFront(map[key]);  // mark as recently used
        return map[key].val;
    }

    public void Put(int key, int value) {
        if (map.ContainsKey(key)) {
            // STEP 3: Update existing key and mark as recently used
            map[key].val = value;
            MoveToFront(map[key]);
        } else {
            // STEP 4: Insert new node at front; evict LRU (tail.prev) if over capacity
            var node = new Node { key = key, val = value };
            map[key] = node;
            InsertFront(node);
            if (map.Count > capacity) {    // over capacity → evict LRU (tail)
                var lru = tail.prev;
                Remove(lru);
                map.Remove(lru.key);
            }
        }
    }

    // Unlink node n from wherever it currently sits in the DLL
    // Before: ... ←→ [prev] ←→ [n] ←→ [next] ←→ ...
    // After:  ... ←→ [prev] ←→ [next] ←→ ...   (n is detached)
    void Remove(Node n) {
        // STEP 5: Bridge n's neighbors together to unlink n
        n.prev.next = n.next;   // prev node skips over n, points to n's next
        n.next.prev = n.prev;   // next node skips over n, points back to n's prev
    }

    // Insert node n right after the dummy head (= most recently used position)
    // Before: head ←→ [first] ←→ ...
    // After:  head ←→ [n] ←→ [first] ←→ ...
    void InsertFront(Node n) {
        // STEP 6: Splice n between dummy head and current first node
        n.next = head.next;     // n's next = old first node
        n.prev = head;          // n's prev = dummy head
        head.next.prev = n;     // old first node's prev = n
        head.next = n;          // dummy head's next = n (n is now first)
    }

    // Mark n as most recently used: remove from current position, re-insert at front
    void MoveToFront(Node n) { Remove(n); InsertFront(n); }
}
// Time: O(1) for both get and put — HashMap lookup + DLL pointer manipulation
// Space: O(capacity)
```

---

```
═══════════════════════════════════════════════════════════════════════
  DSA COMPLETE STUDY GUIDE — C# EDITION
  Sections 1–51 · Parts 1–12 · 50 Practice Problems · FAANG Ready

  Master the 14 patterns. Understand the WHY behind every approach.
  Brute Force → Better → Optimal for every problem.
  You're ready when you can explain the solution before you code it.
═══════════════════════════════════════════════════════════════════════
```

---

# PART 12 — REAL INTERVIEW QUESTIONS FROM INDIA

---

## Section 51 — Top 50 Questions from Service Companies + Top 50 from Product Companies

> **🧠 How to use this section**
>
> These questions are sourced from real interview experiences shared on platforms like GeeksForGeeks, Glassdoor, AmbitionBox, and Leetcode Discuss — specifically tagged with Indian companies. Focus is on **beginner-to-intermediate** level: questions that test fundamentals, not algorithmic gymnastics.
>
> **Service Companies** (TCS, Infosys, Wipro, Cognizant, HCL, Capgemini, Accenture, Tech Mahindra) tend to focus on output-based code, basic data structures, and OOP concepts.
> **Product Companies** (Amazon India, Microsoft India, Google India, Flipkart, Paytm, Swiggy, PhonePe, Razorpay, CRED, Juspay, Meesho, Zepto, Groww) focus more on problem-solving patterns and clean reasoning.

---

## PART A — Top 50: Service Companies (TCS, Infosys, Wipro, HCL, Cognizant, Capgemini)

```
╔══════════════════════════════════════════════════════════════════╗
║  SERVICE COMPANY PATTERN                                         ║
║  Round 1: Aptitude + Coding (basic output questions)            ║
║  Round 2: Technical Interview (OOP, C#/.NET, data structures)   ║
║  Round 3: HR Round                                               ║
║  Focus: Can you write correct working code, not just talk?       ║
╚══════════════════════════════════════════════════════════════════╝
```

---

### Q1 — Reverse a String Without Built-in Functions *(TCS, Infosys)*

**Real interview note:** "They asked me to reverse without using `string.Reverse()` or any LINQ."

```csharp
string ReverseString(string s) {
    // STEP 1: Convert to mutable char array (strings are immutable in C#)
    char[] chars = s.ToCharArray();  // convert to mutable array
    int left = 0, right = chars.Length - 1;

    // STEP 2: Two-pointer swap from both ends converging inward
    while (left < right) {
        // Swap characters at both ends, then move pointers inward
        (chars[left], chars[right]) = (chars[right], chars[left]);
        left++;
        right--;
    }
    // STEP 3: Convert char array back to string
    return new string(chars);  // convert char array back to string
}
// Input: "hello" → Output: "olleh"
// Time: O(n), Space: O(n) for the char array
```

---

### Q2 — Check if a Number is Prime *(TCS NextStep, Wipro Elite)*

**Real interview note:** "Very common in TCS NQT. They expect you to know the √n optimization."

```csharp
bool IsPrime(int n) {
    // STEP 1: Edge case — numbers < 2 are not prime by definition
    if (n < 2) return false;  // 0 and 1 are not prime by definition

    // STEP 2: Trial division up to √n — any factor above √n has a paired factor below it
    // WHY check up to √n? If n = a × b, the smaller factor must be ≤ √n.
    // So if no factor found up to √n, none exists beyond either.
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return false;  // found a divisor → not prime
    }
    return true;
}
// Input: 17 → true | Input: 15 → false (3×5)
// Time: O(√n) — much faster than O(n) naive check
```

---

### Q3 — Fibonacci Series (Iterative) *(TCS, HCL, Cognizant)*

**Real interview note:** "Cognizant asked for both iterative and recursive. Interviewer then asked what's wrong with the recursive version."

```csharp
// ITERATIVE — O(n) time, O(1) space (PREFERRED)
void PrintFibonacci(int n) {
    // STEP 1: Seed with the first two Fibonacci values
    int a = 0, b = 1;  // first two Fibonacci numbers
    // STEP 2: Slide the window forward n times, printing each value
    for (int i = 0; i < n; i++) {
        Console.Write(a + " ");
        int next = a + b;  // calculate next before overwriting
        a = b;             // slide: a moves to b's position
        b = next;          // b moves to the new value
    }
}
// Output for n=7: 0 1 1 2 3 5 8

// RECURSIVE — O(2^n) time (WHY bad? recomputes same values exponentially)
int FibRecursive(int n) {
    if (n <= 1) return n;             // base cases: fib(0)=0, fib(1)=1
    return FibRecursive(n-1) + FibRecursive(n-2);  // tree recursion
}
// Follow-up answer: "Recursive is O(2^n) — use memoization to fix it to O(n)"
```

---

### Q4 — Factorial (Iterative + Recursive) *(Wipro, Capgemini, Accenture)*

**Real interview note:** "Basic but they expect you to handle n=0 correctly."

```csharp
// ITERATIVE
long Factorial(int n) {
    if (n < 0) throw new ArgumentException("Negative input");
    long result = 1;
    for (int i = 2; i <= n; i++)  // start from 2 (multiplying by 1 is pointless)
        result *= i;
    return result;
    // Note: int overflows at n=13, use long for n up to 20
}

// RECURSIVE
long FactorialRecursive(int n) {
    if (n <= 1) return 1;               // base case: 0! = 1! = 1
    return n * FactorialRecursive(n-1); // n! = n × (n-1)!
}
// Input: 5 → Output: 120 (5×4×3×2×1)
```

---

### Q5 — Swap Two Numbers Without Temp Variable *(TCS, Infosys)*

**Real interview note:** "Classic trick question. Know all 3 approaches."

```csharp
// METHOD 1: Arithmetic (can overflow for large numbers)
void SwapArithmetic(ref int a, ref int b) {
    a = a + b;  // a now holds the sum
    b = a - b;  // b = sum - original b = original a
    a = a - b;  // a = sum - new b = sum - original a = original b
}

// METHOD 2: XOR (no overflow risk, handles all integers)
void SwapXOR(ref int a, ref int b) {
    a = a ^ b;  // a = a XOR b
    b = a ^ b;  // b = (a XOR b) XOR b = a (original a)
    a = a ^ b;  // a = (a XOR b) XOR a = b (original b)
    // WHY XOR works: a^a=0, a^0=a → XOR cancels the original value
}

// METHOD 3: C# tuple (cleanest, always use in real code)
void SwapTuple(ref int a, ref int b) => (a, b) = (b, a);
```

---

### Q6 — Find Largest and Second Largest in an Array *(Wipro, HCL, TCS)*

**Real interview note:** "HCL asked this in the first technical round. Use single pass."

```csharp
(int largest, int secondLargest) FindTop2(int[] arr) {
    // STEP 1: Initialize both trackers to minimum value
    int first = int.MinValue;   // largest seen so far
    int second = int.MinValue;  // second largest seen so far

    foreach (int num in arr) {
        if (num > first) {
            // STEP 2: New largest found — demote old first to second
            second = first;  // old largest drops to second place
            first = num;     // new largest takes first place
        } else if (num > second && num != first) {
            // STEP 3: Not a new largest but beats second — update second
            // num is between second and first — but not a duplicate of first
            second = num;
        }
    }
    return (first, second);
}
// Input: [3,1,4,1,5,9,2,6] → (9, 6)
// Edge case: all same values → second = int.MinValue (no second largest)
// Time: O(n), Space: O(1) — single pass, no sorting needed
```

---

### Q7 — Count Vowels and Consonants *(TCS, Capgemini, Accenture)*

**Real interview note:** "Asked in Accenture Digital. Simple but tests attention to detail (uppercase handling)."

```csharp
(int vowels, int consonants) CountVowelsConsonants(string s) {
    s = s.ToLower();  // normalize to lowercase for uniform checking
    int vowels = 0, consonants = 0;
    string vowelSet = "aeiou";

    foreach (char c in s) {
        if (char.IsLetter(c)) {
            // Check if letter is a vowel or consonant
            if (vowelSet.Contains(c)) vowels++;
            else consonants++;
        }
        // Non-letter characters (spaces, digits) are ignored
    }
    return (vowels, consonants);
}
// Input: "Hello World" → (3 vowels: e, o, o | 7 consonants: H, l, l, W, r, l, d)
```

---

### Q8 — Remove Duplicates from an Array *(TCS, Infosys, Wipro)*

**Real interview note:** "Infosys asked to do it without extra data structure. Then asked to use HashSet."

```csharp
// METHOD 1: Using HashSet — O(n) time, O(n) space
int[] RemoveDuplicatesHash(int[] arr) {
    var seen = new HashSet<int>();
    var result = new List<int>();

    foreach (int num in arr) {
        if (seen.Add(num))      // Add returns false if already present
            result.Add(num);    // only add if it wasn't seen before
    }
    return result.ToArray();
}

// METHOD 2: Sort then compare adjacent — O(n log n) time, O(1) extra space
int[] RemoveDuplicatesSort(int[] arr) {
    Array.Sort(arr);            // bring duplicates together
    var result = new List<int> { arr[0] };

    for (int i = 1; i < arr.Length; i++) {
        if (arr[i] != arr[i-1]) // only add if different from previous
            result.Add(arr[i]);
    }
    return result.ToArray();
}
// Input: [1,3,2,1,4,3,5] → [1,3,2,4,5] (method 1 preserves order)
```

---

### Q9 — Matrix Multiplication *(TCS, Infosys, Wipro)*

**Real interview note:** "Very common in Infosys Specialist Programmer drive. They want you to handle non-square matrices."

```csharp
int[,] MultiplyMatrices(int[,] A, int[,] B) {
    int rowsA = A.GetLength(0);  // rows in A
    int colsA = A.GetLength(1);  // cols in A = rows in B (must match!)
    int colsB = B.GetLength(1);  // cols in B

    int[,] result = new int[rowsA, colsB];

    for (int i = 0; i < rowsA; i++) {
        for (int j = 0; j < colsB; j++) {
            // result[i,j] = dot product of row i of A and column j of B
            for (int k = 0; k < colsA; k++) {
                result[i, j] += A[i, k] * B[k, j];
            }
        }
    }
    return result;
}
// Time: O(n³) for n×n matrices
// WHY triple nested loop? Each cell in result = sum of n multiplications.
```

---

### Q10 — Check Palindrome String *(TCS, HCL, Cognizant)*

**Real interview note:** "TCS NQT classic. They asked to ignore spaces and case."

```csharp
bool IsPalindrome(string s) {
    // Normalize: lowercase, letters and digits only
    var clean = new string(s.ToLower()
        .Where(char.IsLetterOrDigit)  // remove spaces, punctuation
        .ToArray());

    int left = 0, right = clean.Length - 1;
    while (left < right) {
        if (clean[left] != clean[right]) return false;  // mismatch → not palindrome
        left++;
        right--;
    }
    return true;
}
// Input: "A man a plan a canal Panama" → true
// Input: "racecar" → true | "hello" → false
```

---

### Q11 — Find Missing Number in 1 to N *(TCS, Cognizant, Capgemini)*

**Real interview note:** "Cognizant asked this with the trick: use sum formula. No loop needed!"

```csharp
int FindMissing(int[] arr, int n) {
    // STEP 1: Compute expected sum using Gauss formula n*(n+1)/2
    // Sum of 1 to n = n*(n+1)/2 (Gauss formula)
    // Missing number = expected sum - actual sum
    int expectedSum = n * (n + 1) / 2;
    // STEP 2: Subtract actual sum — the difference is the missing number
    int actualSum = arr.Sum();  // or use a loop: foreach(int x in arr) actualSum += x;
    return expectedSum - actualSum;
}
// Input: arr=[1,2,4,5,6], n=6 → expectedSum=21, actualSum=18 → missing=3
// Time: O(n), Space: O(1) — much cleaner than HashSet or sorting approaches

// BONUS: XOR approach (handles overflow for very large n)
int FindMissingXOR(int[] arr, int n) {
    // STEP 1: XOR all numbers 1..n, then XOR all array values — only missing remains
    int xor = 0;
    for (int i = 1; i <= n; i++) xor ^= i;   // XOR of 1..n
    foreach (int num in arr) xor ^= num;       // XOR with array values
    return xor;  // all pairs cancel; only missing number remains
}
```

---

### Q12 — Bubble Sort Implementation *(Wipro, TCS, HCL)*

**Real interview note:** "TCS asked to sort an array and explain how bubble sort works step by step."

```csharp
void BubbleSort(int[] arr) {
    int n = arr.Length;
    // STEP 1: Outer pass — each pass guarantees the next largest is in its final position
    for (int i = 0; i < n - 1; i++) {
        bool swapped = false;  // optimization: if no swap in a pass, array is sorted

        // STEP 2: Inner scan — bubble larger element rightward by comparing adjacent pairs
        // Each pass bubbles the i-th largest element to position n-1-i
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j+1]) {
                (arr[j], arr[j+1]) = (arr[j+1], arr[j]);  // swap adjacent pair
                swapped = true;
            }
        }
        // STEP 3: Early exit if no swaps occurred — array is already sorted
        if (!swapped) break;  // early exit: already sorted — saves O(n) in best case
    }
}
// Time: O(n²) worst/avg, O(n) best (already sorted with swapped flag)
// Space: O(1) — in-place
// Input: [64,34,25,12,22,11,90] → [11,12,22,25,34,64,90]
```

---

### Q13 — Linear Search and Binary Search *(Accenture, Capgemini, HCL)*

**Real interview note:** "Accenture asked both and wanted me to explain when to use which."

```csharp
// LINEAR SEARCH — works on any array (sorted or unsorted)
int LinearSearch(int[] arr, int target) {
    for (int i = 0; i < arr.Length; i++) {
        if (arr[i] == target) return i;  // found at index i
    }
    return -1;  // not found
}
// Time: O(n), Space: O(1) — simple but slow for large arrays

// BINARY SEARCH — requires SORTED array, much faster
int BinarySearch(int[] arr, int target) {
    int left = 0, right = arr.Length - 1;
    while (left <= right) {
        // WHY left + (right-left)/2? Prevents integer overflow vs (left+right)/2
        int mid = left + (right - left) / 2;
        if (arr[mid] == target) return mid;           // found!
        if (arr[mid] < target) left = mid + 1;        // target is in right half
        else right = mid - 1;                          // target is in left half
    }
    return -1;  // not found
}
// Time: O(log n), Space: O(1) — halves search space each step
```

---

### Q14 — OOP: Explain Polymorphism with Code *(TCS, Infosys, Cognizant)*

**Real interview note:** "Infosys always asks this. Show both compile-time (overloading) and runtime (overriding)."

```csharp
// RUNTIME POLYMORPHISM (Method Overriding) — resolved at runtime
// WHY virtual/override? Allows base class reference to call derived class behavior.
public class Animal {
    public virtual void Speak() => Console.WriteLine("...");
}

public class Dog : Animal {
    public override void Speak() => Console.WriteLine("Woof!");  // replaces base
}

public class Cat : Animal {
    public override void Speak() => Console.WriteLine("Meow!");
}

// Key demo: base class reference calls derived class method
Animal a = new Dog();
a.Speak();  // Output: "Woof!" — NOT "..." — this is runtime polymorphism!

// COMPILE-TIME POLYMORPHISM (Method Overloading) — resolved at compile time
public class Calculator {
    public int Add(int a, int b) => a + b;
    public double Add(double a, double b) => a + b;  // same name, different params
    public int Add(int a, int b, int c) => a + b + c;  // different param count
}
```

---

### Q15 — Interface vs Abstract Class *(TCS Digital, Infosys, Wipro)*

**Real interview note:** "TCS Digital interview always has this question. Know the practical difference."

```csharp
// ABSTRACT CLASS — use when subclasses SHARE common code (is-a relationship)
public abstract class Shape {
    public string Color { get; set; }   // shared property (concrete)

    public void PrintColor() =>          // shared method (concrete — no override needed)
        Console.WriteLine($"Color: {Color}");

    public abstract double Area();       // forces every subclass to implement this
}

// INTERFACE — use when unrelated classes SHARE a contract (can-do relationship)
// A class can implement MULTIPLE interfaces but extend only ONE abstract class
public interface IDrawable {
    void Draw();   // contract: any Drawable thing must implement Draw()
}
public interface IResizable {
    void Resize(double factor);
}

public class Circle : Shape, IDrawable, IResizable {
    public double Radius;
    public override double Area() => Math.PI * Radius * Radius;  // must implement
    public void Draw() => Console.WriteLine($"Drawing circle r={Radius}");
    public void Resize(double factor) => Radius *= factor;
}

// KEY RULE: Interface = "what it can do" / Abstract = "what it is"
// Use interface for: cross-hierarchy contracts (Flyable for Bird AND Airplane)
// Use abstract class for: sharing code between closely related types
```

---

### Q16 — Linked List: Insert at Beginning, End, Middle *(TCS, HCL, Wipro)*

**Real interview note:** "HCL Technical asked me to implement singly linked list from scratch."

```csharp
public class Node {
    public int Data;
    public Node Next;
    public Node(int data) { Data = data; Next = null; }
}

public class LinkedList {
    private Node head;

    // Insert at beginning — O(1)
    public void InsertFront(int data) {
        Node newNode = new Node(data);
        newNode.Next = head;  // new node points to old head
        head = newNode;       // head now points to new node
    }

    // Insert at end — O(n) (need to traverse to last node)
    public void InsertEnd(int data) {
        Node newNode = new Node(data);
        if (head == null) { head = newNode; return; }  // empty list edge case

        Node curr = head;
        while (curr.Next != null)  // walk to the last node
            curr = curr.Next;
        curr.Next = newNode;       // last node now points to new node
    }

    // Print the list
    public void Print() {
        Node curr = head;
        while (curr != null) {
            Console.Write(curr.Data + " → ");
            curr = curr.Next;
        }
        Console.WriteLine("null");
    }
}
```

---

### Q17 — Stack Using Array *(TCS, Infosys, Wipro)*

**Real interview note:** "Wipro asked to implement a stack from scratch and explain LIFO."

```csharp
public class Stack {
    private int[] data;
    private int top;   // index of the topmost element (-1 = empty)
    private int capacity;

    public Stack(int capacity) {
        this.capacity = capacity;
        data = new int[capacity];
        top = -1;  // -1 means stack is empty
    }

    // Push: add to top — O(1)
    public void Push(int val) {
        if (top == capacity - 1)  // top at last index = full
            throw new InvalidOperationException("Stack Overflow");
        data[++top] = val;  // increment top FIRST, then assign
    }

    // Pop: remove from top — O(1)
    public int Pop() {
        if (top == -1)
            throw new InvalidOperationException("Stack Underflow");
        return data[top--];  // return top element, then decrement top
    }

    public int Peek() => top == -1
        ? throw new InvalidOperationException("Empty stack")
        : data[top];  // look at top without removing

    public bool IsEmpty() => top == -1;
}
```

---

### Q18 — Binary Tree Traversals (Inorder, Preorder, Postorder) *(TCS, Cognizant, Infosys)*

**Real interview note:** "TCS Digital always asks traversal. Know the order and output by heart."

```csharp
public class TreeNode {
    public int Val;
    public TreeNode Left, Right;
    public TreeNode(int val) { Val = val; }
}

// INORDER: Left → Root → Right  (gives SORTED output for BST!)
void Inorder(TreeNode root) {
    if (root == null) return;    // base case
    Inorder(root.Left);          // visit left subtree first
    Console.Write(root.Val + " "); // then visit root
    Inorder(root.Right);         // then visit right subtree
}

// PREORDER: Root → Left → Right  (used for tree copying/serialization)
void Preorder(TreeNode root) {
    if (root == null) return;
    Console.Write(root.Val + " "); // visit root FIRST
    Preorder(root.Left);
    Preorder(root.Right);
}

// POSTORDER: Left → Right → Root  (used for tree deletion — children before parent)
void Postorder(TreeNode root) {
    if (root == null) return;
    Postorder(root.Left);
    Postorder(root.Right);
    Console.Write(root.Val + " "); // visit root LAST
}
// Tree: 1(root), left=2, right=3, 2.left=4, 2.right=5
// Inorder: 4 2 5 1 3 | Preorder: 1 2 4 5 3 | Postorder: 4 5 2 3 1
```

---

### Q19 — String Anagram Check *(Capgemini, Accenture, HCL)*

**Real interview note:** "Capgemini asked this in the coding section. Simple frequency count."

```csharp
bool AreAnagrams(string s1, string s2) {
    if (s1.Length != s2.Length) return false;  // different lengths can't be anagrams

    int[] freq = new int[26];  // frequency count for a-z

    foreach (char c in s1)
        freq[c - 'a']++;  // increment for each char in s1

    foreach (char c in s2)
        freq[c - 'a']--;  // decrement for each char in s2

    // If anagrams, every count should be exactly 0
    return freq.All(x => x == 0);
}
// Input: "listen", "silent" → true (same chars, different order)
// Input: "hello", "world" → false
// Time: O(n), Space: O(1) — fixed 26-slot array
```

---

### Q20 — Exception Handling in C# *(Infosys, Accenture, Wipro)*

**Real interview note:** "Infosys always asks about try-catch-finally. Know what finally guarantees."

```csharp
// BASIC EXCEPTION HANDLING
int SafeDivide(int a, int b) {
    try {
        return a / b;  // may throw DivideByZeroException if b==0
    }
    catch (DivideByZeroException ex) {
        // Catch SPECIFIC exceptions before general Exception
        Console.WriteLine($"Error: {ex.Message}");
        return 0;  // return safe default
    }
    catch (Exception ex) {
        // Catch-all for unexpected errors
        Console.WriteLine($"Unexpected: {ex.Message}");
        throw;  // re-throw if you can't handle it here
    }
    finally {
        // WHY finally? This block ALWAYS runs — even if exception thrown or return hit.
        // Use for cleanup: closing files, releasing DB connections, etc.
        Console.WriteLine("This always executes");
    }
}

// CUSTOM EXCEPTION
public class InsufficientFundsException : Exception {
    public decimal Amount;
    public InsufficientFundsException(decimal amount)
        : base($"Insufficient funds: need {amount} more") {
        Amount = amount;
    }
}
```

---

### Q21 — Find Duplicate in Array *(TCS, Wipro, Cognizant)*

**Real interview note:** "Wipro asked: 'Find duplicate in O(n) time and O(1) space.' (Floyd's cycle detection approach!)"

```csharp
// METHOD 1: HashSet — O(n) time, O(n) space (simplest)
int FindDuplicate(int[] arr) {
    var seen = new HashSet<int>();
    foreach (int num in arr) {
        if (!seen.Add(num))  // Add returns false if already present = duplicate!
            return num;
    }
    return -1;  // no duplicate found
}

// METHOD 2: Negation trick — O(n) time, O(1) space (values must be in [1..n])
int FindDuplicateO1Space(int[] arr) {
    foreach (int num in arr) {
        int idx = Math.Abs(num) - 1;  // use value as index (1-indexed → 0-indexed)
        if (arr[idx] < 0) return Math.Abs(num);  // already negated = seen before!
        arr[idx] = -arr[idx];  // negate to mark "visited"
    }
    return -1;
}
// Input: [1,3,4,2,2] → 2
```

---

### Q22 — Implement a Queue Using Two Stacks *(Infosys, TCS Digital)*

**Real interview note:** "TCS Digital asked this as a data structure design question."

```csharp
public class QueueUsingStacks {
    private Stack<int> inbox = new Stack<int>();   // for enqueue
    private Stack<int> outbox = new Stack<int>();  // for dequeue

    // Enqueue: always push to inbox — O(1)
    public void Enqueue(int val) => inbox.Push(val);

    // Dequeue: transfer inbox to outbox only when outbox is empty — amortized O(1)
    public int Dequeue() {
        if (outbox.Count == 0) {
            // Transfer all items from inbox to outbox
            // WHY? Reversing inbox gives FIFO order in outbox
            while (inbox.Count > 0)
                outbox.Push(inbox.Pop());
        }
        if (outbox.Count == 0) throw new InvalidOperationException("Queue is empty");
        return outbox.Pop();
    }
}
// Insight: inbox is LIFO, but when transferred to outbox it becomes FIFO
// Enqueue: [1,2,3] → inbox=[3,2,1]
// Dequeue: transfer → outbox=[1,2,3], pop 1 (correct FIFO order)
```

---

### Q23 — Count Words in a Sentence *(Accenture, HCL, TCS)*

```csharp
int CountWords(string sentence) {
    if (string.IsNullOrWhiteSpace(sentence)) return 0;

    // Split on whitespace, remove empty entries (handles multiple spaces)
    string[] words = sentence.Trim().Split(
        new char[] { ' ', '\t', '\n' },
        StringSplitOptions.RemoveEmptyEntries
    );
    return words.Length;
}
// Input: "  Hello   World  " → 2
// Input: "The quick brown fox" → 4
```

---

### Q24 — Merge Two Sorted Arrays *(TCS, Wipro, Infosys)*

**Real interview note:** "Classic merge step of merge sort. Always asked in variations."

```csharp
int[] MergeSorted(int[] a, int[] b) {
    // STEP 1: Allocate result array large enough to hold both inputs
    int[] result = new int[a.Length + b.Length];
    int i = 0, j = 0, k = 0;  // i=pointer for a, j=pointer for b, k=result index

    // STEP 2: Merge by always taking the smaller of the two current front elements
    // Compare elements from both arrays; take the smaller one
    while (i < a.Length && j < b.Length) {
        if (a[i] <= b[j])
            result[k++] = a[i++];  // take from a, advance i
        else
            result[k++] = b[j++];  // take from b, advance j
    }

    // STEP 3: Drain any remaining elements from either array
    // Copy remaining elements (one array might not be exhausted)
    while (i < a.Length) result[k++] = a[i++];
    while (j < b.Length) result[k++] = b[j++];

    return result;
}
// Input: [1,3,5], [2,4,6] → [1,2,3,4,5,6]
// Time: O(m+n), Space: O(m+n)
```

---

### Q25 — Properties and Encapsulation in C# *(Infosys, TCS, Wipro)*

**Real interview note:** "Infosys asks about auto-properties vs full properties and why we use them."

```csharp
public class BankAccount {
    // Full property with validation (encapsulation — control access to data)
    private decimal _balance;

    public decimal Balance {
        get => _balance;  // read: anyone can read
        private set {
            if (value < 0) throw new ArgumentException("Balance can't be negative");
            _balance = value;  // write: only this class can set (private set)
        }
    }

    // Auto-property — compiler generates backing field automatically
    public string AccountNumber { get; init; }  // init: set only in constructor/initializer

    // Read-only auto-property
    public string Owner { get; }

    public BankAccount(string accountNumber, string owner) {
        AccountNumber = accountNumber;
        Owner = owner;
        Balance = 0;
    }

    public void Deposit(decimal amount) {
        if (amount <= 0) throw new ArgumentException("Deposit must be positive");
        Balance += amount;  // uses property setter with validation
    }
}
```

---

### Q26 — LINQ Basics: Filter, Select, GroupBy *(Infosys, Wipro, TCS Digital)*

**Real interview note:** "Infosys Specialist Programmer always tests LINQ knowledge."

```csharp
var students = new List<(string Name, int Age, string Grade)> {
    ("Alice", 20, "A"), ("Bob", 22, "B"), ("Charlie", 20, "A"), ("Dave", 21, "B")
};

// FILTER (Where) — get students with Grade A
var gradeA = students.Where(s => s.Grade == "A").ToList();
// Result: Alice, Charlie

// PROJECT (Select) — get just names
var names = students.Select(s => s.Name).ToList();
// Result: ["Alice", "Bob", "Charlie", "Dave"]

// SORT (OrderBy)
var byAge = students.OrderBy(s => s.Age).ThenBy(s => s.Name).ToList();

// GROUP (GroupBy) — group by grade
var byGrade = students.GroupBy(s => s.Grade);
foreach (var group in byGrade) {
    Console.WriteLine($"Grade {group.Key}: {string.Join(", ", group.Select(s => s.Name))}");
}
// Output: Grade A: Alice, Charlie | Grade B: Bob, Dave

// AGGREGATE (Count, Sum, Average, Max, Min)
double avgAge = students.Average(s => s.Age);  // 20.75
int count = students.Count(s => s.Grade == "A");  // 2
```

---

### Q27 — Generic Class and Method *(TCS Digital, Infosys, Wipro)*

**Real interview note:** "TCS Digital asked: 'Why use generics? Write a generic Stack.'"

```csharp
// WHY generics? Avoid code duplication + type safety without boxing
// Without generics: need separate IntStack, StringStack, etc.
// With generics: one Stack<T> works for any type

public class GenericStack<T> {
    private List<T> items = new List<T>();

    public void Push(T item) => items.Add(item);  // T is the type parameter

    public T Pop() {
        if (items.Count == 0) throw new InvalidOperationException("Empty stack");
        T item = items[^1];     // last element (C# index from end syntax)
        items.RemoveAt(items.Count - 1);
        return item;
    }

    public T Peek() => items.Count > 0
        ? items[^1]
        : throw new InvalidOperationException("Empty stack");

    public int Count => items.Count;
}

// GENERIC METHOD — works with any comparable type
T FindMax<T>(T[] arr) where T : IComparable<T> {
    T max = arr[0];
    foreach (T item in arr)
        if (item.CompareTo(max) > 0) max = item;  // CompareTo > 0 means item > max
    return max;
}
// Usage: FindMax(new[] {3,1,4,1,5}) → 5
//        FindMax(new[] {"banana","apple","cherry"}) → "cherry" (alphabetically last)
```

---

### Q28 — Difference Between `==` and `.Equals()` *(TCS, Infosys)*

**Real interview note:** "Common gotcha question. Most candidates get this wrong for strings."

```csharp
// For VALUE TYPES: == and Equals() both compare VALUES
int a = 5, b = 5;
Console.WriteLine(a == b);        // true — compares values
Console.WriteLine(a.Equals(b));   // true — same result

// For STRINGS: C# overloads == to compare VALUES (unlike Java!)
string s1 = "hello";
string s2 = "hel" + "lo";
Console.WriteLine(s1 == s2);           // true — C# == compares string content
Console.WriteLine(s1.Equals(s2));      // true
Console.WriteLine(object.ReferenceEquals(s1, s2)); // false (different objects)

// For REFERENCE TYPES (custom classes): == compares REFERENCES by default
var obj1 = new Person { Name = "Alice" };
var obj2 = new Person { Name = "Alice" };
Console.WriteLine(obj1 == obj2);      // FALSE — different objects in memory
Console.WriteLine(obj1.Equals(obj2)); // also FALSE unless you override Equals()
// To compare by content: override Equals() and GetHashCode()
```

---

### Q29 — Delegates and Events Basics *(TCS Digital, Infosys)*

**Real interview note:** "TCS Digital occasionally asks: 'What is a delegate? How is it different from an interface?'"

```csharp
// DELEGATE — a type-safe function pointer (can store a reference to a method)
public delegate int MathOperation(int a, int b);  // defines signature

int Add(int a, int b) => a + b;
int Multiply(int a, int b) => a * b;

MathOperation op = Add;          // assign method to delegate
Console.WriteLine(op(3, 4));     // Output: 7
op = Multiply;                   // reassign to different method
Console.WriteLine(op(3, 4));     // Output: 12

// Built-in delegates: Func<T,TResult>, Action<T>, Predicate<T>
Func<int, int, int> add = (a, b) => a + b;   // Func: has return value
Action<string> print = msg => Console.WriteLine(msg);  // Action: no return
Predicate<int> isEven = n => n % 2 == 0;    // Predicate: returns bool

// EVENT — delegate used for notification pattern (publisher-subscriber)
public class Button {
    public event EventHandler Click;  // event based on EventHandler delegate
    public void SimulateClick() => Click?.Invoke(this, EventArgs.Empty);
}
Button btn = new Button();
btn.Click += (sender, e) => Console.WriteLine("Button was clicked!");
btn.SimulateClick();  // Output: "Button was clicked!"
```

---

### Q30 — Difference: `List<T>` vs `Array` vs `LinkedList<T>` *(TCS, Wipro, HCL)*

**Real interview note:** "Asked in almost every technical round as an OOP + collections warm-up."

```
╔══════════════════════════════════════════════════════════════════╗
║  Feature          │ Array      │ List<T>    │ LinkedList<T>      ║
╠══════════════════════════════════════════════════════════════════╣
║  Size             │ Fixed      │ Dynamic    │ Dynamic            ║
║  Random access    │ O(1)       │ O(1)       │ O(n)               ║
║  Insert at end    │ Not possible│ O(1) amort │ O(1)              ║
║  Insert at middle │ O(n) shift │ O(n) shift │ O(1) if you have  ║
║                   │            │            │ the node reference ║
║  Delete at middle │ O(n) shift │ O(n) shift │ O(1)              ║
║  Memory           │ Contiguous │ Contiguous │ Non-contiguous     ║
║  Cache efficiency │ Best       │ Good       │ Poor (pointer chase)║
╚══════════════════════════════════════════════════════════════════╝

WHEN TO USE:
  Array:        size is known, read-heavy, performance-critical
  List<T>:      default choice, mixed read/write, unknown size
  LinkedList<T>:frequent insert/delete at both ends (deque pattern)
```

---

### Q31 — Count Occurrences of Each Character *(HCL, TCS, Accenture)*

```csharp
Dictionary<char, int> CharFrequency(string s) {
    var freq = new Dictionary<char, int>();
    foreach (char c in s) {
        // GetValueOrDefault returns 0 if key doesn't exist — clean one-liner
        freq[c] = freq.GetValueOrDefault(c, 0) + 1;
    }
    return freq;
}
// Input: "banana" → {'b':1, 'a':3, 'n':2}
// Can also use int[] freq = new int[26] for lowercase a-z (faster, less memory)
```

---

### Q32 — Check if Two Strings are Rotations *(Wipro, Capgemini)*

```csharp
bool AreRotations(string s1, string s2) {
    if (s1.Length != s2.Length) return false;
    // KEY INSIGHT: if s2 is a rotation of s1, then s2 must appear in s1+s1
    // Example: "abcde" rotated by 2 = "cdeab", and "cdeab" is a substring of "abcdeabcde"
    string doubled = s1 + s1;
    return doubled.Contains(s2);
}
// Input: "abcde", "cdeab" → true | "abcde", "abced" → false
// Time: O(n) for string contains check
```

---

### Q33 — Async/Await Basics *(TCS Digital, Infosys Specialist)*

**Real interview note:** "TCS Digital asks: 'What is async/await? Why use it?'"

```csharp
// WHY async/await? Frees the calling thread while waiting for I/O (DB, HTTP, file).
// Without async: thread is BLOCKED during I/O (wastes thread pool resources).
// With async: thread returns to thread pool while awaiting, resumes when done.

// EXAMPLE: Fetch user data from an API
public async Task<string> GetUserAsync(int userId) {
    using var httpClient = new HttpClient();
    // await: pause THIS method, but DON'T block the thread
    string response = await httpClient.GetStringAsync($"https://api/users/{userId}");
    return response;  // execution resumes here after HTTP call completes
}

// Calling async method
public async Task ProcessUsersAsync() {
    string user = await GetUserAsync(1);   // await individual calls
    Console.WriteLine(user);

    // Run multiple async calls in PARALLEL (not sequentially)
    Task<string> t1 = GetUserAsync(1);
    Task<string> t2 = GetUserAsync(2);
    string[] results = await Task.WhenAll(t1, t2);  // both run concurrently!
}
// RULE: async methods should return Task or Task<T>. Mark the caller async too.
```

---

### Q34 — Find All Pairs that Sum to Target *(Cognizant, TCS, Wipro)*

```csharp
List<(int, int)> FindPairs(int[] arr, int target) {
    var result = new List<(int, int)>();
    var seen = new HashSet<int>();

    foreach (int num in arr) {
        int complement = target - num;  // what value do we need to make the pair?
        if (seen.Contains(complement))
            result.Add((complement, num));  // pair found!
        seen.Add(num);  // add current number to seen set
    }
    return result;
}
// Input: arr=[1,5,3,7,2,8], target=8 → [(1,7), (3,5)]
// Time: O(n), Space: O(n)
```

---

### Q35 — Difference: `string` vs `StringBuilder` *(TCS, Infosys, all service companies)*

**Real interview note:** "Asked in nearly every service company interview to test .NET understanding."

```csharp
// STRING — immutable: every modification creates a NEW string object
string s = "Hello";
s += " World";  // Creates NEW string "Hello World"; old "Hello" is discarded
// In a loop, this becomes O(n²) due to repeated copying

// Why O(n²)? Each += copies all existing content + new addition:
// "H" → "He" → "Hel" → ... → "Hello World"
// Total characters copied: 1+2+3+...+n = n(n+1)/2 = O(n²)

// STRINGBUILDER — mutable buffer, O(1) amortized append
var sb = new StringBuilder();
for (int i = 0; i < 1000; i++)
    sb.Append(i);      // modifies internal buffer — NO new object created
string result = sb.ToString();  // ONE allocation at the very end

// RULE OF THUMB:
// < 5 concatenations in non-loop code → use string
// In a loop or many concatenations → use StringBuilder
```

---

### Q36 — `static` vs Instance Members *(TCS, Wipro, Infosys)*

```csharp
public class Counter {
    // STATIC member: shared across ALL instances (one copy per class)
    public static int TotalCount = 0;

    // INSTANCE member: each object has its OWN copy
    public int Id;

    public Counter() {
        TotalCount++;         // shared counter: increments every time any Counter is created
        Id = TotalCount;      // instance ID based on creation order
    }
}

Counter c1 = new Counter();  // TotalCount=1, c1.Id=1
Counter c2 = new Counter();  // TotalCount=2, c2.Id=2
Counter c3 = new Counter();  // TotalCount=3, c3.Id=3

Console.WriteLine(Counter.TotalCount);  // 3 — access via CLASS name, not instance
// WHY? Static belongs to the class, not any particular object
```

---

### Q37 — Pattern Printing: Right Triangle of Stars *(TCS, Accenture, Capgemini)*

**Real interview note:** "TCS NQT pattern printing is very common. Know diamond, triangle, pyramid."

```csharp
// RIGHT TRIANGLE:
// *
// **
// ***
// ****
void RightTriangle(int rows) {
    for (int i = 1; i <= rows; i++) {
        Console.WriteLine(new string('*', i));  // print i stars per row
    }
}

// PYRAMID:
//   *
//  ***
// *****
void Pyramid(int rows) {
    for (int i = 1; i <= rows; i++) {
        // spaces before stars = (rows - i)
        Console.Write(new string(' ', rows - i));
        // stars in row i = (2*i - 1) for odd numbers: 1, 3, 5, ...
        Console.WriteLine(new string('*', 2 * i - 1));
    }
}
```

---

### Q38 — Convert Decimal to Binary *(Wipro, HCL, Capgemini)*

```csharp
string DecimalToBinary(int n) {
    if (n == 0) return "0";
    var bits = new StringBuilder();

    while (n > 0) {
        bits.Insert(0, n % 2);  // remainder is the next bit (LSB first, so insert at front)
        n /= 2;                 // integer division halves n each step
    }
    return bits.ToString();
}
// Input: 13 → "1101" (13 = 8+4+1 = 2³+2²+2⁰)
// Alternative: Convert.ToString(13, 2) — built-in, but know the manual way!
```

---

### Q39 — `throw` vs `throw ex` (Preserve Stack Trace) *(TCS Digital, Infosys)*

```csharp
void Method1() {
    try { Method2(); }
    catch (Exception ex) {
        throw;     // RE-THROW: preserves original stack trace
        // throw ex; // BAD: resets stack trace to THIS line (loses where it started)
    }
}
// WHY does it matter? throw ex makes debugging harder because you lose where
// the exception ORIGINALLY occurred. Always prefer bare throw to rethrow.
```

---

### Q40 — `IEnumerable` vs `IList` vs `ICollection` *(TCS Digital, Infosys Specialist)*

```
╔══════════════════════════════════════════════════════════════════╗
║  Interface       │ Can Iterate │ Count │ Add/Remove │ Index Access║
╠══════════════════════════════════════════════════════════════════╣
║  IEnumerable<T>  │ Yes (foreach)│ No   │ No         │ No          ║
║  ICollection<T>  │ Yes          │ Yes  │ Yes        │ No          ║
║  IList<T>        │ Yes          │ Yes  │ Yes        │ Yes (arr[i])║
╠══════════════════════════════════════════════════════════════════╣
║  RULE: Accept the LEAST specific interface in method params.     ║
║  If you only need to loop: accept IEnumerable<T>                 ║
║  If you need Count: accept ICollection<T>                        ║
║  If you need index: accept IList<T>                              ║
╚══════════════════════════════════════════════════════════════════╝
```

---

### Q41 — Reverse Linked List *(TCS, HCL, Wipro)*

*See Section 7 for the full solution with trace diagram. Keep the 3-pointer pattern memorized: `prev/curr/next → save-flip-advance`.*

---

### Q42 — GCD and LCM *(TCS NQT, Infosys, Capgemini)*

```csharp
// GCD using Euclidean algorithm: gcd(a,b) = gcd(b, a%b) until b=0
int GCD(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;  // reduce: remainder of a÷b replaces b
        a = temp;   // old b becomes new a
    }
    return a;  // when b=0, a contains the GCD
}
// WHY does this work? GCD(48, 18) = GCD(18, 12) = GCD(12, 6) = GCD(6, 0) = 6

// LCM using GCD: lcm(a,b) = (a × b) / gcd(a,b)
long LCM(int a, int b) {
    // WHY cast to long? a*b may overflow int (e.g., a=100000, b=100000)
    return (long)a / GCD(a, b) * b;  // divide FIRST to reduce overflow risk
}
// Input: a=12, b=18 → GCD=6, LCM=36
```

---

### Q43 — Abstract Class Cannot Be Instantiated *(TCS, Wipro)*

```csharp
// WHY can't you instantiate an abstract class?
// An abstract class is INCOMPLETE — it has abstract methods with no implementation.
// Creating an object of an incomplete class would lead to undefined behavior.

public abstract class Vehicle {
    public abstract void StartEngine();  // no implementation — MUST override
    public void Refuel() => Console.WriteLine("Refueling...");  // concrete OK
}

// Vehicle v = new Vehicle();  // COMPILE ERROR: Cannot create instance of abstract class
// You must create a concrete subclass:
public class Car : Vehicle {
    public override void StartEngine() => Console.WriteLine("Vroom!");
}
Car c = new Car();  // OK!
c.StartEngine();    // "Vroom!"
c.Refuel();         // "Refueling..." (inherited from Vehicle)
```

---

### Q44 — String Formatting: Interpolation, Format, PadLeft *(Wipro, Accenture)*

```csharp
string name = "Alice";
int score = 95;

// String interpolation (C# 6+) — cleanest
string msg1 = $"Name: {name}, Score: {score:D3}";  // D3 = at least 3 digits → "095"

// String.Format — classic
string msg2 = string.Format("Name: {0,-10} Score: {1,5}", name, score);
// {0,-10} = left-align in 10-char field | {1,5} = right-align in 5-char field

// Alignment with PadLeft/PadRight
string padded = score.ToString().PadLeft(5, '0');  // "00095"
string right = name.PadRight(10);                  // "Alice     "

// Number formatting
double pi = 3.14159;
Console.WriteLine($"{pi:F2}");    // "3.14" — 2 decimal places
Console.WriteLine($"{pi:P0}");    // "314%" — percentage, 0 decimal places
Console.WriteLine($"{1234567:N0}"); // "1,234,567" — with thousand separators
```

---

### Q45 — File I/O Basics *(Wipro, Accenture, HCL)*

```csharp
// WRITE to file
File.WriteAllText("output.txt", "Hello World");  // creates or overwrites
File.AppendAllText("output.txt", "\nNew line");   // append to existing

// READ from file
string content = File.ReadAllText("output.txt");
string[] lines = File.ReadAllLines("output.txt");

// USING statement — ensures stream is closed even if exception occurs
// WHY using? FileStream implements IDisposable; must close to release OS file handle.
using (var writer = new StreamWriter("output.txt", append: true)) {
    writer.WriteLine("Another line");
}  // writer.Dispose() called automatically here — file handle released

// MODERN way (C# 8+): using declaration (no block needed)
using var reader = new StreamReader("output.txt");
string line = reader.ReadLine();
// reader disposed automatically when it goes out of scope
```

---

### Q46 — Null Handling: `??`, `?.`, `??=` *(TCS, Infosys)*

```csharp
string name = null;

// ?? — null-coalescing: return left side if not null, else right side
string display = name ?? "Anonymous";  // "Anonymous" (name is null)

// ??= — null-coalescing assignment: assign only if null
name ??= "Default";  // sets name = "Default" because name was null
// Equivalent to: if (name == null) name = "Default";

// ?. — null-conditional: returns null if object is null instead of throwing
string upper = name?.ToUpper();         // safe — won't throw NullReferenceException
int? length = name?.Length;             // returns int? (nullable int)

// CHAINING null-conditional
var city = user?.Address?.City;         // returns null if user OR Address is null
// Without ?.: if (user != null && user.Address != null) city = user.Address.City;
```

---

### Q47 — `const` vs `readonly` vs `static readonly` *(TCS, Infosys)*

```
╔══════════════════════════════════════════════════════════════════╗
║  Feature         │ const         │ readonly    │ static readonly ║
╠══════════════════════════════════════════════════════════════════╣
║  When assigned   │ Compile-time  │ Runtime     │ Runtime         ║
║  Location        │ Declaration   │ Decl or ctor│ Decl or static  ║
║                  │               │             │ constructor      ║
║  Implicitly      │ Yes           │ No          │ Yes             ║
║  static?         │               │             │                 ║
║  Type allowed    │ Primitives +  │ Any type    │ Any type        ║
║                  │ string only   │             │                 ║
╚══════════════════════════════════════════════════════════════════╝

USE:
  const: PI, MAX_SIZE, string literals known at compile time
  readonly: per-instance value set in constructor (injected dependencies)
  static readonly: class-level singleton, config values, regex patterns
```

---

### Q48 — SOLID Principles: Brief Explanation *(TCS Digital, Infosys Specialist, Wipro)*

**Real interview note:** "Every TCS Digital and Infosys SP interview asks SOLID. Know one-line definition + example."

```
S — Single Responsibility: A class should have ONE reason to change.
    Bad: UserManager handles login + email + DB persistence
    Good: UserAuth, EmailService, UserRepository (each does one thing)

O — Open/Closed: Open for EXTENSION, closed for MODIFICATION.
    Bad: Add new shape → edit existing CalculateArea() with if-else
    Good: Each shape implements IShape.Area() — add new shape, no existing code changes

L — Liskov Substitution: Subclass should be replaceable by base class.
    Bad: Square extends Rectangle, but Square.SetWidth() must also change Height
         → breaks callers that expect independent width/height
    Good: Keep Square and Rectangle as separate classes

I — Interface Segregation: Don't force classes to implement unused methods.
    Bad: IWorker has Work() + Eat() + Sleep() — robots implement Eat()?
    Good: IWorkable { Work() }, IFeedable { Eat() } — robots only need IWorkable

D — Dependency Inversion: Depend on ABSTRACTIONS, not concrete classes.
    Bad: OrderService creates new SqlOrderRepository() internally
    Good: OrderService receives IOrderRepository in constructor (injected)
```

---

### Q49 — SQL: Basic SELECT, JOIN, GROUP BY *(TCS, Infosys, Wipro — often in tech round)*

**Real interview note:** "Service companies always have 1-2 SQL questions in technical rounds."

```sql
-- BASIC SELECT with WHERE
SELECT Name, Salary
FROM Employees
WHERE Department = 'IT' AND Salary > 50000
ORDER BY Salary DESC;

-- INNER JOIN — employees with their department names
SELECT e.Name, d.DeptName
FROM Employees e
INNER JOIN Departments d ON e.DeptId = d.Id;

-- LEFT JOIN — all employees, even those without a department
SELECT e.Name, d.DeptName
FROM Employees e
LEFT JOIN Departments d ON e.DeptId = d.Id;

-- GROUP BY with HAVING (filter after grouping)
SELECT Department, COUNT(*) AS HeadCount, AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY Department
HAVING COUNT(*) > 5;  -- only departments with more than 5 employees

-- SUBQUERY — employees with salary above average
SELECT Name, Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees);
```

---

### Q50 — Difference: Process vs Thread vs Task *(TCS Digital, Infosys, Wipro)*

```
╔══════════════════════════════════════════════════════════════════╗
║  Concept │ Process          │ Thread           │ Task             ║
╠══════════════════════════════════════════════════════════════════╣
║  What    │ An executing      │ Unit of execution│ Abstraction over ║
║          │ program instance  │ within a process │ async work       ║
║  Memory  │ Own memory space  │ Shared within    │ Shared (uses     ║
║          │                   │ process          │ thread pool)     ║
║  Creation│ Expensive (OS     │ Cheaper than     │ Cheap (thread    ║
║  cost    │ level)            │ process          │ pool reuse)      ║
║  C# API  │ System.Diagnostics│ System.Threading │ System.Threading ║
║          │ .Process          │ .Thread          │ .Tasks.Task      ║
╠══════════════════════════════════════════════════════════════════╣
║  USE WHEN                                                         ║
║  Process: run a separate program (notepad.exe, a script)         ║
║  Thread:  CPU-bound parallel work, needs fine control            ║
║  Task:    I/O-bound async work, most .NET applications           ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## PART B — Top 50: Product Companies (Amazon, Microsoft, Flipkart, Paytm, Swiggy, Razorpay, PhonePe, CRED, Groww, Juspay)

```
╔══════════════════════════════════════════════════════════════════╗
║  PRODUCT COMPANY PATTERN                                         ║
║  Round 1: Online Coding (LeetCode-style, 2-3 questions, 90 min) ║
║  Round 2-3: Technical Phone/Video (DSA + CS fundamentals)       ║
║  Round 4: System Design (for 3+ years experience)               ║
║  Round 5: Bar Raiser / Culture Fit                               ║
║  Focus: Problem-solving clarity, clean code, edge-case handling  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

### Q1 — Two Sum *(Amazon, Flipkart, Swiggy — Most Frequent)* 🔥 MUST SOLVE

**Real interview note:** "Asked in Amazon SDE1 India. Interviewer wanted HashMap approach and explanation of WHY."

*See Section 5 of this guide for the full solution with trace. Key insight: `complement = target - num`, store in Dictionary for O(1) lookup.*

---

### Q2 — Valid Parentheses *(Microsoft India, Amazon, Razorpay)* 🔥 MUST SOLVE

*See Section 8. Key insight: Stack + closing-to-opening map. Check `stack.Count == 0` at end.*

---

### Q3 — Maximum Subarray (Kadane's) *(Amazon, Flipkart, CRED)*

*See Section 31 (Kadane's in this guide). Key insight: `currentMax = max(nums[i], currentMax + nums[i])`.*

---

### Q4 — Reverse a Linked List *(Amazon, Microsoft, Paytm)* 🔥 MUST SOLVE

*See Section 7. Key insight: 3-pointer `prev/curr/next` — save-next, flip, advance-both.*

---

### Q5 — Best Time to Buy and Sell Stock *(Amazon India, Flipkart, Groww)* 🔥 MUST SOLVE

**Real interview note:** "Amazon SDE1 Bangalore asked this. Very common as a warm-up."

```csharp
public int MaxProfit(int[] prices) {
    // STEP 1: Initialize min price and max profit trackers
    int minPrice = int.MaxValue;  // cheapest buy price seen so far
    int maxProfit = 0;            // best profit seen so far

    foreach (int price in prices) {
        // STEP 2: Update the cheapest buy price seen so far
        // Update cheapest buy price if today is cheaper
        minPrice = Math.Min(minPrice, price);
        // STEP 3: Update best profit if selling at today's price beats current best
        // Update best profit if selling today (after buying at minPrice) is better
        maxProfit = Math.Max(maxProfit, price - minPrice);
    }
    return maxProfit;
}
// Input: [7,1,5,3,6,4] → buy at 1, sell at 6 → profit = 5
// WHY greedy? At each day, we only care about: cheapest price before today + today's price.
// Time: O(n), Space: O(1)
```

---

### Q6 — Contains Duplicate *(Amazon, Microsoft, Juspay)* 🔥 MUST SOLVE

```csharp
bool ContainsDuplicate(int[] nums) {
    var seen = new HashSet<int>();
    foreach (int num in nums)
        if (!seen.Add(num)) return true;  // Add returns false if already present
    return false;
}
// Time: O(n), Space: O(n)
```

---

### Q7 — Merge Two Sorted Lists *(Amazon, Flipkart, Swiggy)* 🔥 MUST SOLVE

*See Section 29. Key insight: dummy head + two-pointer merge. `curr.next = l1 ?? l2` for tail.*

---

### Q8 — Climbing Stairs *(Amazon, Microsoft, CRED)* 🔥 MUST SOLVE

*See Section 32. Key insight: `ways(n) = ways(n-1) + ways(n-2)` — Fibonacci with O(1) space.*

---

### Q9 — Number of Islands *(Amazon India, Swiggy SDE2, Zepto)* 🔥 MUST SOLVE

**Real interview note:** "Amazon SDE2 Hyderabad. BFS or DFS — both accepted. 'Sink' visited islands by marking '0'."

```csharp
public int NumIslands(char[][] grid) {
    // STEP 1: Scan the grid for unvisited land cells ('1')
    int islandCount = 0;
    int totalRows = grid.Length, totalCols = grid[0].Length;

    for (int row = 0; row < totalRows; row++) {
        for (int col = 0; col < totalCols; col++) {
            if (grid[row][col] == '1') {  // unvisited land cell = start of a new island
                // STEP 2: Each new unvisited land triggers one island increment + full sink
                islandCount++;
                SinkConnectedLand(grid, row, col);  // "sink" the entire connected island
            }
        }
    }
    return islandCount;

    // Local function: flood-fill all connected '1's by sinking them to '0'
    // WHY local function? Captures rows/cols from outer scope for bounds check
    void SinkConnectedLand(char[][] g, int row, int col) {
        // STEP 3: Stop if out of bounds, already water, or already sunk (visited)
        if (row < 0 || row >= totalRows || col < 0 || col >= totalCols || g[row][col] != '1') return;
        g[row][col] = '0';  // sink: mark land as visited in-place (no extra visited array needed)
        // STEP 4: Recursively sink all 4 cardinal neighbors
        SinkConnectedLand(g, row - 1, col); // up
        SinkConnectedLand(g, row + 1, col); // down
        SinkConnectedLand(g, row, col - 1); // left
        SinkConnectedLand(g, row, col + 1); // right
    }
}
// Time: O(m×n) — each cell touched at most twice (scan + DFS)
// Space: O(m×n) worst case call stack (grid is all land)
```

---

### Q10 — Coin Change *(Microsoft India, Amazon, PhonePe)* 🔥 MUST SOLVE

*See Section 33. Key insight: DP table `dp[i] = min coins for amount i`. Fill with `amount+1` as "infinity".*

---

### Q11 — Longest Common Prefix *(Amazon, Flipkart, Meesho)*

**Real interview note:** "Flipkart SDE1 asked this as a warm-up string problem."

```csharp
public string LongestCommonPrefix(string[] strs) {
    if (strs.Length == 0) return "";

    // STEP 1: Seed prefix with the first word
    string prefix = strs[0];  // start with first word as candidate prefix

    // STEP 2: For each subsequent word, shrink prefix until it matches the word's start
    for (int i = 1; i < strs.Length; i++) {
        // Shrink prefix until the current string starts with it
        while (!strs[i].StartsWith(prefix)) {
            prefix = prefix[..^1];  // remove last character (C# range syntax)
            if (prefix == "") return "";  // no common prefix at all
        }
    }
    return prefix;
}
// Input: ["flower","flow","flight"] → "fl"
// Input: ["dog","racecar","car"] → ""
// Time: O(S) where S = total characters in all strings
```

---

### Q12 — Product of Array Except Self *(Amazon, Microsoft, Razorpay)*

**Real interview note:** "Amazon SDE2 India. 'No division allowed' constraint is the key challenge."

```csharp
public int[] ProductExceptSelf(int[] nums) {
    int n = nums.Length;
    int[] result = new int[n];

    // STEP 1: Left pass — result[i] = product of all elements to the LEFT of i
    // PASS 1: result[i] = product of all elements to the LEFT of i
    result[0] = 1;  // nothing to the left of index 0
    for (int i = 1; i < n; i++)
        result[i] = result[i-1] * nums[i-1];  // extend left product

    // STEP 2: Right pass — multiply each result[i] by the right-side product
    // PASS 2: multiply by product of all elements to the RIGHT of i
    int rightProduct = 1;  // accumulate right product as we scan right-to-left
    for (int i = n-1; i >= 0; i--) {
        result[i] *= rightProduct;      // result[i] = leftProduct × rightProduct
        rightProduct *= nums[i];        // extend right product for next iteration
    }
    return result;
}
// Input: [1,2,3,4] → [24,12,8,6]  (24=2×3×4, 12=1×3×4, 8=1×2×4, 6=1×2×3)
// Time: O(n), Space: O(1) extra (result array doesn't count)
```

---

### Q13 — 3Sum *(Amazon, Google India, Swiggy)* 🔥 MUST SOLVE

*See Section 36. Key insight: sort first, then two-pointer for inner loop. Skip duplicates at both levels.*

---

### Q14 — Binary Search *(Microsoft India, Amazon, Juspay)* 🔥 MUST SOLVE

**Real interview note:** "Microsoft India SDE1 — asked classic binary search, then asked for lower-bound variant."

*See Section 27. The complete templates (classic + lower bound + upper bound + binary search on answer) are all there.*

---

### Q15 — Validate Binary Search Tree *(Amazon, Microsoft, Paytm)*

*See Section 13. Key insight: pass `(min, max)` bounds down recursion — don't just check parent-child.*

---

### Q16 — Find the Duplicate Number *(Amazon, Razorpay, CRED)*

**Real interview note:** "Razorpay SDE1 asked with the constraint: O(n) time, O(1) extra space. Floyd's cycle detection!"

```csharp
public int FindDuplicate(int[] nums) {
    // INSIGHT: treat array as a linked list where value = next index.
    // nums[0] → nums[nums[0]] → nums[nums[nums[0]]] → ...
    // There's a cycle because one value (the duplicate) points to the same node twice.
    // Use Floyd's cycle detection (Phase 1: find meeting point, Phase 2: find cycle start).

    // STEP 1: Floyd's Phase 1 — advance fast/slow until they meet inside the cycle
    int slow = nums[0], fast = nums[0];

    // PHASE 1: Find meeting point inside cycle
    do {
        slow = nums[slow];          // move 1 step
        fast = nums[nums[fast]];    // move 2 steps
    } while (slow != fast);

    // STEP 2: Floyd's Phase 2 — reset slow to head, advance both 1-step to find cycle entry
    // PHASE 2: Find entry point of cycle = duplicate number
    slow = nums[0];  // reset slow to start
    while (slow != fast) {
        slow = nums[slow];  // both move 1 step now
        fast = nums[fast];
    }
    // STEP 3: Meeting point is the duplicate number (the cycle entry)
    return slow;  // they meet at the duplicate
}
// Input: [1,3,4,2,2] → 2
// Time: O(n), Space: O(1) — no extra array, no sorting
```

---

### Q17 — Merge Intervals *(Amazon, Microsoft India, Groww)*

*See Section 39. Key insight: sort by start, then greedy merge — overlap if `interval[0] <= last[1]`.*

---

### Q18 — Level Order Traversal (BFS on Tree) *(Amazon, Flipkart, Meesho)*

**Real interview note:** "Amazon SDE1 Bangalore asked level-by-level output. Snapshot `levelSize` before processing each level."

```csharp
public IList<IList<int>> LevelOrder(TreeNode root) {
    var result = new List<IList<int>>();
    if (root == null) return result;

    // STEP 1: Seed BFS queue with the root node
    var queue = new Queue<TreeNode>();
    queue.Enqueue(root);

    while (queue.Count > 0) {
        // STEP 2: Snapshot level size so we only process this level's nodes
        // Snapshot level size BEFORE enqueuing next level's nodes
        int levelSize = queue.Count;
        var level = new List<int>();

        // STEP 3: Process all nodes at this level; enqueue their children for the next level
        for (int i = 0; i < levelSize; i++) {
            var node = queue.Dequeue();
            level.Add(node.val);
            if (node.left != null) queue.Enqueue(node.left);   // add children for next level
            if (node.right != null) queue.Enqueue(node.right);
        }
        result.Add(level);  // all nodes at this level processed
    }
    return result;
}
// Time: O(n), Space: O(n) — queue holds at most one full level
```

---

### Q19 — Longest Substring Without Repeating Characters *(Amazon, Swiggy, Juspay)* 🔥 MUST SOLVE

*See Section 37. Key insight: HashMap stores last-seen index; jump `left` directly past duplicate instead of shrinking one-by-one.*

---

### Q20 — Maximum Depth of Binary Tree *(Amazon, Flipkart, CRED)* 🔥 MUST SOLVE

```csharp
public int MaxDepth(TreeNode root) {
    if (root == null) return 0;  // base case: empty tree has depth 0
    // Depth of this node = 1 (for itself) + max of children's depths
    return 1 + Math.Max(MaxDepth(root.left), MaxDepth(root.right));
}
// Time: O(n) — visit every node once
// Space: O(h) — recursion stack, h = tree height (O(log n) balanced, O(n) skewed)
```

---

### Q21 — Search in Rotated Sorted Array *(Amazon, Google India, PhonePe)* 🔥 MUST SOLVE

*See Section 27. Key insight: one half is always sorted — check if target falls in the sorted half.*

---

### Q22 — Single Number (XOR trick) *(Amazon, Microsoft, Razorpay)*

*See Section 45. Key insight: XOR all numbers — pairs cancel to 0, leaving the unique element.*

---

### Q23 — Reverse Words in a String *(Amazon, Flipkart, Meesho)*

**Real interview note:** "Amazon SDE1 asked this with multiple spaces between words."

```csharp
public string ReverseWords(string s) {
    // Split on whitespace (handles multiple spaces), filter empty entries
    string[] words = s.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
    // Reverse the array of words, then join with single space
    Array.Reverse(words);
    return string.Join(' ', words);
}
// Input: "  the sky is blue  " → "blue is sky the"
// Input: "a good   example" → "example good a"
// Time: O(n), Space: O(n)
```

---

### Q24 — Top K Frequent Elements *(Amazon, Microsoft, Zepto)* 🔥 MUST SOLVE

*See Section 43. Key insight: bucket sort by frequency — bucket index = frequency — gives O(n).*

---

### Q25 — Implement LRU Cache *(Amazon, Microsoft, Razorpay)*

*See Section 50. Key insight: HashMap (O(1) lookup) + Doubly Linked List (O(1) move-to-front/evict).*

---

### Q26 — Check if a Binary Tree is Balanced *(Amazon, Flipkart, PhonePe)*

**Real interview note:** "Amazon SDE1 asked: 'Height-balanced means no subtree height differs by more than 1.'"

```csharp
public bool IsBalanced(TreeNode root) {
    return CheckHeight(root) != -1;  // -1 = unbalanced signal
}

int CheckHeight(TreeNode node) {
    // STEP 1: Base case — null node has height 0
    if (node == null) return 0;  // empty tree has height 0

    // STEP 2: Recursively check left subtree; propagate -1 (unbalanced) immediately
    int left = CheckHeight(node.left);
    if (left == -1) return -1;   // early exit: left subtree already unbalanced

    // STEP 3: Recursively check right subtree; propagate -1 (unbalanced) immediately
    int right = CheckHeight(node.right);
    if (right == -1) return -1;  // early exit: right subtree already unbalanced

    // STEP 4: Check balance at current node; signal upward if unbalanced
    // If height difference > 1, signal unbalanced upward with -1
    if (Math.Abs(left - right) > 1) return -1;

    return 1 + Math.Max(left, right);  // return actual height to parent
}
// Time: O(n) — each node visited once
// WHY -1 as signal? Avoids second pass; height and balance checked simultaneously
```

---

### Q27 — Find All Anagrams in a String *(Google India, Amazon, Swiggy)*

**Real interview note:** "Sliding window with frequency array. Google India SDE1 Phone Screen."

```csharp
public IList<int> FindAnagrams(string s, string p) {
    var result = new List<int>();
    if (s.Length < p.Length) return result;

    // STEP 1: Build frequency arrays for pattern and the initial window
    int[] pCount = new int[26];  // frequency of each char in pattern p
    int[] wCount = new int[26];  // frequency in current window of s
    foreach (char c in p) pCount[c - 'a']++;

    for (int i = 0; i < s.Length; i++) {
        // STEP 2: Expand window right — include new character
        wCount[s[i] - 'a']++;  // expand window: add right character

        // STEP 3: Shrink window left — remove character that slides out
        // Shrink window: remove character that's sliding out of window
        if (i >= p.Length)
            wCount[s[i - p.Length] - 'a']--;

        // STEP 4: If window frequencies match pattern frequencies, record start index
        // If frequencies match → window is an anagram of p
        if (pCount.SequenceEqual(wCount))
            result.Add(i - p.Length + 1);  // start index of this window
    }
    return result;
}
// Input: s="cbaebabacd", p="abc" → [0, 6]
// Time: O(n), Space: O(1) — fixed 26-element arrays
```

---

### Q28 — Symmetric Tree *(Amazon, Microsoft, Juspay)*

```csharp
public bool IsSymmetric(TreeNode root) {
    return IsMirror(root?.left, root?.right);
}

bool IsMirror(TreeNode left, TreeNode right) {
    if (left == null && right == null) return true;   // both null = symmetric
    if (left == null || right == null) return false;  // one null, one not = asymmetric
    // Values must match AND inner/outer subtrees must be mirrors of each other
    return left.val == right.val
        && IsMirror(left.left, right.right)   // outer pair
        && IsMirror(left.right, right.left);  // inner pair
}
// A symmetric tree is a mirror of itself.
// Time: O(n), Space: O(h)
```

---

### Q29 — Spiral Order Matrix *(Amazon, Flipkart, Groww)*

**Real interview note:** "Amazon SDE2 India asked this. Track 4 boundaries and shrink them."

```csharp
public IList<int> SpiralOrder(int[][] matrix) {
    var result = new List<int>();
    // STEP 1: Set up 4 boundary pointers
    int top = 0, bottom = matrix.Length - 1;
    int left = 0, right = matrix[0].Length - 1;

    // STEP 2: Traverse the spiral layer by layer, shrinking boundaries inward
    while (top <= bottom && left <= right) {
        // Traverse RIGHT across top row
        for (int c = left; c <= right; c++) result.Add(matrix[top][c]);
        top++;  // top row consumed

        // Traverse DOWN along right column
        for (int r = top; r <= bottom; r++) result.Add(matrix[r][right]);
        right--;  // right column consumed

        // Traverse LEFT across bottom row (if rows remain)
        if (top <= bottom) {
            for (int c = right; c >= left; c--) result.Add(matrix[bottom][c]);
            bottom--;
        }

        // Traverse UP along left column (if columns remain)
        if (left <= right) {
            for (int r = bottom; r >= top; r--) result.Add(matrix[r][left]);
            left++;
        }
    }
    return result;
}
// Time: O(m×n), Space: O(1) extra
```

---

### Q30 — Power Function: Implement `pow(x, n)` *(Amazon, Microsoft, Razorpay)*

**Real interview note:** "Microsoft asked 'implement Math.Pow without using it.' Expect O(log n) fast power."

```csharp
public double MyPow(double x, int n) {
    // STEP 1: Handle negative exponent — flip base, negate exponent
    long N = n;  // use long to handle int.MinValue (negating it overflows int!)
    if (N < 0) { x = 1.0 / x; N = -N; }  // negative exponent → flip base, make N positive

    return FastPow(x, N);
}

double FastPow(double x, long n) {
    // STEP 2: Base case — x^0 = 1
    if (n == 0) return 1;          // x^0 = 1 (base case)
    // STEP 3: Compute x^(n/2) ONCE — halve exponent (D&C saves O(n) → O(log n))
    double half = FastPow(x, n/2); // compute x^(n/2) ONCE (saves half the recursion)
    // STEP 4: Combine — square for even exponent; one extra factor for odd
    if (n % 2 == 0)
        return half * half;        // even: x^n = (x^(n/2))²
    else
        return half * half * x;    // odd: x^n = (x^(n/2))² × x
}
// Time: O(log n) — halve exponent each call
// Input: 2.0, 10 → 1024.0 | 2.0, -2 → 0.25
```

---

### Q31 — Subsets (Power Set) *(Amazon, Flipkart, Juspay)*

**Real interview note:** "Flipkart SDE1 asked: 'Generate all subsets of [1,2,3]. Explain the approach.'"

```csharp
public IList<IList<int>> Subsets(int[] nums) {
    // STEP 1: Seed result with the empty subset
    var result = new List<IList<int>>();
    result.Add(new List<int>());  // empty subset is always included

    // STEP 2: For each number, double the result by adding num to every existing subset
    foreach (int num in nums) {
        // For each existing subset, create a new subset with num added
        int size = result.Count;  // snapshot current count (don't process newly added ones)
        for (int i = 0; i < size; i++) {
            var subset = new List<int>(result[i]);  // copy existing subset
            subset.Add(num);                         // add current number
            result.Add(subset);                      // add as new subset
        }
    }
    return result;
}
// Input: [1,2,3] → [[], [1], [2], [1,2], [3], [1,3], [2,3], [1,2,3]]
// Time: O(n × 2^n), Space: O(n × 2^n) — 2^n subsets, avg n/2 elements each
```

---

### Q32 — Detect Cycle in Linked List *(Amazon, Paytm, PhonePe)*

**Real interview note:** "PhonePe SDE1 asked fast/slow pointer approach. Know why it works."

```csharp
public bool HasCycle(ListNode head) {
    ListNode slow = head, fast = head;
    // Fast moves 2 steps, slow moves 1 step.
    // If there's a cycle, fast will eventually lap slow and they'll meet.
    // If no cycle, fast reaches null.
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
        if (slow == fast) return true;  // they met inside the cycle
    }
    return false;  // fast reached end — no cycle
}
// Time: O(n), Space: O(1)
```

---

### Q33 — Sort Colors (Dutch National Flag) *(Amazon, Microsoft, CRED)*

*See Section 22. Key insight: 3 pointers `lo/mid/hi` — when swapping from back, don't advance mid (unknown value).*

---

### Q34 — Lowest Common Ancestor in BST *(Amazon, Flipkart, Groww)*

**Real interview note:** "Amazon SDE1 — classic BST property makes this elegant."

```csharp
public TreeNode LowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
    // In BST: if both p and q are less than root, LCA is in left subtree.
    // If both are greater, LCA is in right subtree.
    // If they're on different sides (or one equals root), root IS the LCA.
    if (p.val < root.val && q.val < root.val)
        return LowestCommonAncestor(root.left, p, q);   // both left
    if (p.val > root.val && q.val > root.val)
        return LowestCommonAncestor(root.right, p, q);  // both right
    return root;  // split here — root is the LCA
}
// Time: O(h) — h = tree height, O(log n) balanced, O(n) skewed
```

---

### Q35 — Maximum Product Subarray *(Amazon, Microsoft, Razorpay)*

**Real interview note:** "Razorpay SDE1 asked this as a follow-up to maximum subarray."

```csharp
public int MaxProduct(int[] nums) {
    // STEP 1: Seed both max and min trackers with the first element
    // WHY track both max AND min? A negative × negative = positive (big surprise!)
    // We need to track the minimum (most negative) product in case the next number is negative.
    int maxProd = nums[0], minProd = nums[0], result = nums[0];

    for (int i = 1; i < nums.Length; i++) {
        // STEP 2: If current element is negative, swap max/min (negative flips signs)
        // When nums[i] is negative, max and min SWAP (negative flips sign)
        if (nums[i] < 0) (maxProd, minProd) = (minProd, maxProd);

        // STEP 3: Extend or restart — take max/min of continuing vs starting fresh
        // Extend existing subarray or start fresh with current element
        maxProd = Math.Max(nums[i], maxProd * nums[i]);
        minProd = Math.Min(nums[i], minProd * nums[i]);

        // STEP 4: Update global best
        result = Math.Max(result, maxProd);
    }
    return result;
}
// Input: [2,3,-2,4] → 6 ([2,3])  |  Input: [-2,0,-1] → 0
// Time: O(n), Space: O(1)
```

---

### Q36 — Missing Number (0 to N) *(Amazon, Microsoft, Juspay)*

**Real interview note:** "Juspay SDE asked this as a warm-up in phone screen."

```csharp
public int MissingNumber(int[] nums) {
    int n = nums.Length;
    int expected = n * (n + 1) / 2;  // sum of 0..n using Gauss formula
    int actual = nums.Sum();          // actual sum in the array
    return expected - actual;         // missing number = difference
}
// Input: [3,0,1] → expected=6, actual=4 → missing=2
// Time: O(n), Space: O(1)
```

---

### Q37 — Rotate Array *(Amazon, Microsoft, Paytm)*

**Real interview note:** "Amazon asked: rotate in-place with O(1) extra space. Triple-reverse trick."

```csharp
public void Rotate(int[] nums, int k) {
    int n = nums.Length;
    // STEP 1: Normalize k — rotation by n is identity, so use k % n
    k %= n;  // handle k > n (k=7, n=5 is same as k=2)
    if (k == 0) return;

    // STEP 2: Triple reverse — reverse all, then first k, then remaining
    // TRICK: reverse the whole array, then reverse first k, then reverse rest
    // Why it works: reversing shifts elements to their final positions.
    Reverse(nums, 0, n-1);      // reverse all:    [4,5,1,2,3] for k=2, [1,2,3,4,5]
    Reverse(nums, 0, k-1);      // reverse first k: [5,4,1,2,3]
    Reverse(nums, k, n-1);      // reverse rest:    [5,4,3,2,1] → final: [4,5,1,2,3]

    void Reverse(int[] arr, int l, int r) {
        while (l < r) { (arr[l], arr[r]) = (arr[r], arr[l]); l++; r--; }
    }
}
// Input: [1,2,3,4,5,6,7], k=3 → [5,6,7,1,2,3,4]
// Time: O(n), Space: O(1)
```

---

### Q38 — Palindrome Number *(Amazon, Microsoft, PhonePe)*

**Real interview note:** "PhonePe phone screen — 'check without converting to string.'"

```csharp
public bool IsPalindrome(int x) {
    // STEP 1: Quick guards — negatives and trailing-zero numbers can't be palindromes
    if (x < 0) return false;        // negative numbers are never palindromes
    if (x != 0 && x % 10 == 0) return false;  // trailing zero (like 10) can't be palindrome

    // STEP 2: Reverse only the back half of the number — stop when reversed ≥ remaining
    int reversed = 0;
    // Only reverse HALF the number (stop when reversed catches up to remaining digits)
    while (x > reversed) {
        reversed = reversed * 10 + x % 10;  // take last digit of x, append to reversed
        x /= 10;                             // remove last digit from x
    }
    // STEP 3: Compare: both halves must match (skip middle digit for odd-length)
    // For odd-length numbers (e.g., 12321): middle digit is in reversed/10
    return x == reversed || x == reversed / 10;
}
// Input: 121 → true | 123 → false | 1221 → true
// Time: O(log n) — half the digits processed
```

---

### Q39 — Move Zeroes to End *(Amazon, Flipkart, Meesho)*

**Real interview note:** "Meesho SDE1 asked this. Two-pointer in-place."

```csharp
public void MoveZeroes(int[] nums) {
    int insertPos = 0;  // next position to place a non-zero element

    // Pass 1: move all non-zero elements to the front (maintain relative order)
    foreach (int num in nums)
        if (num != 0)
            nums[insertPos++] = num;

    // Pass 2: fill remaining positions with zeros
    while (insertPos < nums.Length)
        nums[insertPos++] = 0;
}
// Input: [0,1,0,3,12] → [1,3,12,0,0]
// Time: O(n), Space: O(1)
```

---

### Q40 — Decode String (Stack-based) *(Amazon, Google India, Swiggy)*

**Real interview note:** "Swiggy SDE2 asked this. Medium difficulty, tests stack thinking."

```csharp
public string DecodeString(string s) {
    // STEP 1: Initialize stacks for repeat counts and partial strings before each '['
    var countStack = new Stack<int>();   // stores repeat counts
    var strStack = new Stack<string>(); // stores strings built before current bracket
    var current = new StringBuilder();  // current string being built
    int k = 0;  // current number being parsed

    foreach (char c in s) {
        if (char.IsDigit(c)) {
            // STEP 2: Build multi-digit repeat count
            k = k * 10 + (c - '0');  // handle multi-digit numbers (e.g., "12[a]")
        } else if (c == '[') {
            // STEP 3: Save current state and start a fresh segment inside brackets
            countStack.Push(k);           // save current count
            strStack.Push(current.ToString()); // save current string built so far
            current.Clear();  // start fresh inside brackets
            k = 0;
        } else if (c == ']') {
            // STEP 4: Close bracket — repeat inner segment and prepend saved outer string
            int repeat = countStack.Pop();
            string inner = current.ToString();
            current.Clear();
            current.Append(strStack.Pop());  // restore string before this bracket
            for (int i = 0; i < repeat; i++) current.Append(inner);  // repeat inner
        } else {
            // STEP 5: Regular character — append to current segment
            current.Append(c);  // regular character
        }
    }
    return current.ToString();
}
// Input: "3[a]2[bc]" → "aaabcbc"
// Input: "3[a2[c]]" → "accaccacc"
// Time: O(n × max_repeat), Space: O(n)
```

---

### Q41 — Minimum Path Sum in Grid *(Amazon, Microsoft, Groww)*

**Real interview note:** "Amazon SDE2 DP question. 'Find path from top-left to bottom-right minimizing sum.'"

```csharp
public int MinPathSum(int[][] grid) {
    int rows = grid.Length, cols = grid[0].Length;

    // STEP 1: Fill DP table in-place — each cell stores minimum path sum to reach it
    // Modify grid in-place to store minimum path sums (space optimization)
    // dp[i][j] = minimum sum to reach cell (i,j) from (0,0)
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (i == 0 && j == 0) continue;  // start cell: keep original value
            else if (i == 0) grid[i][j] += grid[i][j-1];   // top row: only come from left
            else if (j == 0) grid[i][j] += grid[i-1][j];   // left col: only come from above
            // STEP 2: Interior cells — take minimum of coming from above or from the left
            else grid[i][j] += Math.Min(grid[i-1][j], grid[i][j-1]);  // min of above or left
        }
    }
    return grid[rows-1][cols-1];  // bottom-right cell has the answer
}
// Input: [[1,3,1],[1,5,1],[4,2,1]] → 7 (path: 1→3→1→1→1)
// Time: O(m×n), Space: O(1) — modifies input grid
```

---

### Q42 — Squares of a Sorted Array *(Amazon, Microsoft, Juspay)*

**Real interview note:** "Juspay SDE1 asked: 'Do it in O(n) time.' Two-pointer from both ends."

```csharp
public int[] SortedSquares(int[] nums) {
    // STEP 1: Two pointers from both ends; fill result from right (largest) to left
    int n = nums.Length;
    int[] result = new int[n];
    int left = 0, right = n - 1;
    int pos = n - 1;  // fill result from right to left (largest squares first)

    // STEP 2: Compare squares at both ends; place the larger one at the current back position
    while (left <= right) {
        int leftSq = nums[left] * nums[left];
        int rightSq = nums[right] * nums[right];

        if (leftSq > rightSq) {
            result[pos--] = leftSq;  // left's square is larger → place at pos
            left++;
        } else {
            result[pos--] = rightSq;  // right's square is larger → place at pos
            right--;
        }
    }
    return result;
}
// Input: [-4,-1,0,3,10] → [0,1,9,16,100]
// WHY two-pointer from ends? Largest squares are at the extremes (most negative or largest positive).
// Time: O(n), Space: O(n) for result
```

---

### Q43 — Course Schedule (Cycle Detection in Directed Graph) *(Amazon, Microsoft, Swiggy)* 🔥 MUST SOLVE

*See Section 18 (graph traversals). Key insight: 3-color DFS — 0=unvisited, 1=in-progress (gray), 2=done (black). Gray + back-edge = cycle.*

---

### Q44 — Roman to Integer *(Amazon, Flipkart, CRED)*

**Real interview note:** "CRED SDE1 warm-up. Handle subtraction case (IV=4, IX=9, CM=900)."

```csharp
public int RomanToInt(string s) {
    // STEP 1: Build the Roman numeral value map
    var values = new Dictionary<char, int> {
        ['I']=1, ['V']=5, ['X']=10, ['L']=50,
        ['C']=100, ['D']=500, ['M']=1000
    };

    // STEP 2: Sum values; subtract when current symbol is less than the next (e.g., IV=4)
    int total = 0;
    for (int i = 0; i < s.Length; i++) {
        int curr = values[s[i]];
        // SUBTRACTION case: if current value < next value, subtract (e.g., IV → -1+5=4)
        int next = i + 1 < s.Length ? values[s[i+1]] : 0;
        total += curr < next ? -curr : curr;
    }
    return total;
}
// Input: "MCMXCIV" → 1994 (M=1000, CM=900, XC=90, IV=4)
```

---

### Q45 — Happy Number *(Amazon, Microsoft, Paytm)*

**Real interview note:** "Paytm SDE1 — use cycle detection with HashSet or Floyd's."

```csharp
public bool IsHappy(int n) {
    // STEP 1: Track visited numbers — if we revisit a number, there's a cycle (not happy)
    var seen = new HashSet<int>();
    while (n != 1 && seen.Add(n)) {  // Add returns false if n was already in set (cycle!)
        // STEP 2: Replace n with the sum of squares of its digits
        int sum = 0;
        while (n > 0) {
            int digit = n % 10;   // extract last digit
            sum += digit * digit; // add its square
            n /= 10;              // remove last digit
        }
        n = sum;
    }
    // STEP 3: n==1 means happy; anything else means we hit a cycle
    return n == 1;  // either reached 1 (happy) or cycle detected (not happy)
}
// Input: 19 → true (1²+9²=82, 8²+2²=68, ... eventually reaches 1)
// Input: 2 → false (cycles without reaching 1)
```

---

### Q46 — Sum of Two Integers Without `+` or `-` *(Amazon, Microsoft)*

**Real interview note:** "Microsoft India SDE asked this bit manipulation question."

```csharp
public int GetSum(int a, int b) {
    // Use bit manipulation to simulate addition:
    // XOR: gives sum bits WITHOUT carry (1+0=1, 0+1=1, 1+1=0)
    // AND + shift: gives carry bits (1+1 carries 1 to next position)
    // STEP 1: Iteratively apply XOR (sum without carry) and AND-shift (carry) until no carry
    while (b != 0) {
        int carry = (a & b) << 1;  // AND gives positions where carry occurs, shift left to next bit
        a = a ^ b;                 // XOR gives sum without carry
        b = carry;                 // carry becomes the new 'b' to add
    }
    return a;
}
// Input: a=1, b=2 → 3
// Trace: a=1(01), b=2(10) → carry=0, a=3(11), b=0 → done!
```

---

### Q47 — Word Search in a Grid *(Amazon, Google India, Flipkart)*

**Real interview note:** "Google India phone screen. DFS + backtracking on a 2D grid."

```csharp
public bool Exist(char[][] board, string word) {
    int rows = board.Length, cols = board[0].Length;

    bool DFS(int r, int c, int idx) {
        // STEP 1: Base case — all characters matched
        if (idx == word.Length) return true;  // found all characters!
        // STEP 2: Guard — out of bounds or wrong character
        if (r < 0 || r >= rows || c < 0 || c >= cols) return false;  // out of bounds
        if (board[r][c] != word[idx]) return false;   // wrong character

        // STEP 3: Mark cell as visited in-place to avoid reuse on this path
        char temp = board[r][c];
        board[r][c] = '#';  // mark as visited (in-place — no extra visited array)

        // STEP 4: Explore all 4 neighbors for the next character
        // Explore all 4 directions
        bool found = DFS(r+1,c,idx+1) || DFS(r-1,c,idx+1)
                  || DFS(r,c+1,idx+1) || DFS(r,c-1,idx+1);

        // STEP 5: Backtrack — restore cell so other paths can use it
        board[r][c] = temp;  // UN-MARK: restore for other paths (backtracking)
        return found;
    }

    // STEP 6: Try starting DFS from every cell in the grid
    for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++)
            if (DFS(r, c, 0)) return true;  // try starting from every cell
    return false;
}
// Time: O(m×n × 4^L) where L = word length, Space: O(L) recursion stack
```

---

### Q48 — Number of 1 Bits (Hamming Weight) *(Amazon, Microsoft, Juspay)*

```csharp
public int HammingWeight(int n) {
    // STEP 1: Use Brian Kernighan's trick — each n &= (n-1) clears the lowest set bit
    int count = 0;
    while (n != 0) {
        n &= n - 1;  // KEY TRICK: clears the LOWEST set bit
        // WHY? n-1 flips the lowest set bit and all below it.
        // n & (n-1) removes exactly the lowest set bit.
        count++;
    }
    return count;
}
// Input: 11 (1011) → clears bit: 1010 → 1000 → 0 → count=3
// Faster than checking each bit individually (only iterates once per set bit)
// Alternative: Convert.ToString(n, 2).Count(c => c == '1')
```

---

### Q49 — First Unique Character in a String *(Amazon, Microsoft, PhonePe)*

```csharp
public int FirstUniqChar(string s) {
    int[] freq = new int[26];                // frequency count for a-z
    foreach (char c in s) freq[c - 'a']++;  // count each character

    // Find first character with frequency 1 (preserves left-to-right order)
    for (int i = 0; i < s.Length; i++)
        if (freq[s[i] - 'a'] == 1) return i;  // first unique character found

    return -1;  // all characters repeat
}
// Input: "leetcode" → 0 ('l' appears once, at index 0)
// Input: "aabb" → -1 (all repeat)
// Time: O(n), Space: O(1) — fixed 26-element array
```

---

### Q50 — Intersection of Two Arrays *(Amazon, Flipkart, Razorpay)*

**Real interview note:** "Razorpay SDE1 asked follow-up: 'What if arrays are sorted? What if one is much larger?'"

```csharp
// APPROACH 1: HashSet — O(m+n) time, O(min(m,n)) space
int[] Intersect(int[] nums1, int[] nums2) {
    // STEP 1: Build a set from the first array for O(1) membership check
    var set1 = new HashSet<int>(nums1);  // build set from smaller array
    var result = new List<int>();

    // STEP 2: For each element in nums2, check if it exists in the set (Remove avoids dupes)
    foreach (int num in nums2)
        if (set1.Remove(num))    // Remove returns true if element was in set (and removes it)
            result.Add(num);     // found in both — but won't add duplicates twice (Remove)

    return result.ToArray();
}

// APPROACH 2: Sort + Two Pointers — O((m+n) log(m+n)) time, O(1) extra space
// Useful when arrays are already sorted OR space is constrained
int[] IntersectSorted(int[] nums1, int[] nums2) {
    // STEP 1: Sort both arrays so identical values align
    Array.Sort(nums1); Array.Sort(nums2);
    int i = 0, j = 0;
    var result = new List<int>();

    // STEP 2: Two-pointer merge — collect equal elements, advance the smaller pointer
    while (i < nums1.Length && j < nums2.Length) {
        if (nums1[i] == nums2[j]) { result.Add(nums1[i]); i++; j++; }
        else if (nums1[i] < nums2[j]) i++;   // advance smaller pointer
        else j++;
    }
    return result.ToArray();
}
// Input: [1,2,2,1], [2,2] → [2,2] (with duplicates)
// Input: [4,9,5], [9,4,9,8,4] → [9,4]
```

---

```
╔══════════════════════════════════════════════════════════════════╗
║  SECTION 51 SUMMARY — INDIA INTERVIEW REALITY                   ║
╠══════════════════════════════════════════════════════════════════╣
║  SERVICE COMPANIES (TCS/Infosys/Wipro/HCL/Cognizant/etc.)       ║
║  ✅ Master: OOP (inheritance, polymorphism, interfaces)          ║
║  ✅ Master: Basic data structures (array, linked list, stack)    ║
║  ✅ Master: String manipulation, output prediction              ║
║  ✅ Master: LINQ basics, async/await, exception handling        ║
║  ✅ Master: SQL (SELECT, JOIN, GROUP BY)                         ║
║  ❌ Rarely asked: Hard DP, Graph algorithms, Bit Manipulation    ║
╠══════════════════════════════════════════════════════════════════╣
║  PRODUCT COMPANIES (Amazon/Microsoft/Flipkart/Paytm/etc.)       ║
║  ✅ Must know: Arrays + Strings (Two Sum, Sliding Window)        ║
║  ✅ Must know: Linked List (Reverse, Cycle Detection)            ║
║  ✅ Must know: Trees (BFS, DFS, LCA, Validate BST)              ║
║  ✅ Must know: DP (Climbing Stairs, Coin Change, Max Subarray)   ║
║  ✅ Must know: HashMap + HashSet patterns                        ║
║  ✅ Must know: Graph (Number of Islands, Course Schedule)        ║
║  🎯 Target difficulty: Leetcode Easy (warm-up) + Medium (main)  ║
╠══════════════════════════════════════════════════════════════════╣
║  UNIVERSAL ADVICE FROM REAL INTERVIEWS                           ║
║  1. Always talk through your approach BEFORE coding             ║
║  2. Clarify edge cases out loud (null input, empty array)       ║
║  3. Write clean code with meaningful variable names             ║
║  4. State time and space complexity after coding                ║
║  5. Test your code with the given example, then edge cases      ║
╚══════════════════════════════════════════════════════════════════╝
```

---

# PART 11 — REPEATED / KNOWN INTERVIEW QUESTIONS (C# & SQL)

> **🧠 Mental Model: The "Classic Hits" Playlist**
>
> Every interviewer has a shortlist of 30–40 questions they trust. These aren't trick questions — they test whether you can map a familiar English description to working code quickly and cleanly. Treat each one as a reflex, not a puzzle. The goal: write the correct solution in under 3 minutes while narrating your thought process.

---

## Section 52 — String Manipulation

---

### Q1 — Reverse a String

> **🧠 Mental Model:** Two people swap shirts walking toward each other from opposite ends of a room — they meet in the middle and stop.

```csharp
// ── Reverse a String ──────────────────────────────────────────────
// WHY char array: strings are immutable in C#; char[] allows in-place swap
public static string ReverseString(string input)
{
    char[] characters = input.ToCharArray(); // convert to mutable array

    int left  = 0;
    int right = characters.Length - 1;

    // WHY two-pointer: O(n/2) swaps — most efficient in-place reversal
    while (left < right)
    {
        // swap characters at both ends, then move pointers inward
        (characters[left], characters[right]) = (characters[right], characters[left]);
        left++;
        right--;
    }

    return new string(characters); // reconstruct string from reversed chars
}
// Time: O(n) — each character visited once  |  Space: O(n) — char array copy
// Input: "hello"  →  Output: "olleh"
// Input: "abcde"  →  Output: "edcba"
// Input: "a"      →  Output: "a"      (single char — loop never runs)
// Input: ""       →  Output: ""       (empty — loop never runs)
```

---

### Q2 — Reverse Words in a String

> **🧠 Mental Model:** Flip the order of index cards on a table — keep the text on each card intact, just reorder the cards themselves.

```csharp
// ── Reverse Words in a String ─────────────────────────────────────
// WHY Split + Reverse + Join: handles multiple spaces automatically
public static string ReverseWords(string sentence)
{
    // WHY StringSplitOptions.RemoveEmptyEntries: collapses multiple consecutive
    // spaces ("hello   world") into a clean ["hello","world"] array
    string[] words = sentence.Split(
        separator: ' ',
        options:   StringSplitOptions.RemoveEmptyEntries
    );

    Array.Reverse(words); // reverse the order of words, not characters

    return string.Join(" ", words); // rejoin with a single space delimiter
}
// Time: O(n)  |  Space: O(n)
// Input: "Hello World"          →  Output: "World Hello"
// Input: "  the sky  is blue "  →  Output: "blue is sky the"
// Input: "a good   example"     →  Output: "example good a"

// ── LINQ one-liner alternative ────────────────────────────────────
public static string ReverseWordsLinq(string sentence) =>
    string.Join(" ", sentence.Split(' ', StringSplitOptions.RemoveEmptyEntries).Reverse());
```

---

### Q3 — Find the Occurrence of Each Character in a String

> **🧠 Mental Model:** A tally chart — walk through the string once and make a tick under each letter.

```csharp
// ── Character Frequency Count ─────────────────────────────────────
// WHY Dictionary<char,int>: O(1) lookup/update per character
public static Dictionary<char, int> GetCharacterFrequency(string input)
{
    var frequencyMap = new Dictionary<char, int>();

    foreach (char character in input)
    {
        // WHY TryGetValue: avoids double-lookup vs ContainsKey + indexer
        if (frequencyMap.TryGetValue(character, out int count))
            frequencyMap[character] = count + 1; // increment existing count
        else
            frequencyMap[character] = 1;         // first occurrence
    }

    return frequencyMap;
}

// ── Usage / Demo ──────────────────────────────────────────────────
public static void PrintCharacterFrequency(string input)
{
    var frequency = GetCharacterFrequency(input);

    // order by character for consistent output
    foreach (var (character, count) in frequency.OrderBy(kv => kv.Key))
        Console.WriteLine($"'{character}' → {count}");
}
// Input: "programming"
// Output:
//   'a' → 1  |  'g' → 2  |  'i' → 1  |  'm' → 2
//   'n' → 1  |  'o' → 1  |  'p' → 1  |  'r' → 2

// ── LINQ one-liner alternative ────────────────────────────────────
public static Dictionary<char, int> GetCharFrequencyLinq(string input) =>
    input.GroupBy(c => c).ToDictionary(g => g.Key, g => g.Count());
// Time: O(n)  |  Space: O(k) where k = number of distinct characters
```

---

### Q4 — Find Two Numbers That Add Up to a Target (Two Sum)

> **🧠 Mental Model:** You need $30. Check your wallet ($20), then ask: "has anyone seen a $10?" — a HashSet is the "memory" of what you've already seen.

```csharp
// ── Two Sum — HashSet complement approach ─────────────────────────
// WHY HashSet: O(1) lookup vs O(n) linear scan → reduces overall from O(n²) to O(n)
public static (int index1, int index2) TwoSum(int[] numbers, int target)
{
    // WHY store index alongside value: we need positions, not just values
    var seenValues = new Dictionary<int, int>(); // value → index

    for (int i = 0; i < numbers.Length; i++)
    {
        int complement = target - numbers[i]; // what we need to pair with numbers[i]

        // WHY check complement first: avoids using the same element twice
        if (seenValues.TryGetValue(complement, out int complementIndex))
            return (complementIndex, i); // found a valid pair

        seenValues[numbers[i]] = i; // record this value for future lookups
    }

    return (-1, -1); // no pair found — signal with sentinel values
}
// Time: O(n)  |  Space: O(n) — dictionary stores up to n entries
// Input: [2, 7, 11, 15], target=9   →  Output: (0, 1)  because 2+7=9
// Input: [3, 2, 4],      target=6   →  Output: (1, 2)  because 2+4=6
// Input: [3, 3],         target=6   →  Output: (0, 1)  because 3+3=6

// ── Brute force (O(n²)) — only for comparison / small arrays ──────
public static (int, int) TwoSumBrute(int[] numbers, int target)
{
    for (int i = 0; i < numbers.Length - 1; i++)
        for (int j = i + 1; j < numbers.Length; j++)
            if (numbers[i] + numbers[j] == target)
                return (i, j);
    return (-1, -1);
}
```

---

### Q5 — Check if a String is a Palindrome

> **🧠 Mental Model:** Read a word forwards and backwards — if it sounds the same, it's a palindrome. "racecar" reversed is still "racecar".

```csharp
// ── Palindrome Check ──────────────────────────────────────────────
// WHY two-pointer: O(n/2) comparisons — stops as soon as mismatch found
public static bool IsPalindrome(string input)
{
    int left  = 0;
    int right = input.Length - 1;

    while (left < right)
    {
        // mismatched characters prove it's not a palindrome — exit early
        if (input[left] != input[right])
            return false;

        left++;   // move inward from both ends
        right--;
    }

    return true; // all mirrored pairs matched
}
// Time: O(n)  |  Space: O(1) — no extra allocation
// Input: "racecar"  →  true   |  Input: "hello"  →  false
// Input: "madam"    →  true   |  Input: "a"      →  true (single char)
// Input: ""         →  true   (empty string — vacuously palindrome)

// ── Case-insensitive / alphanumeric-only variant ──────────────────
// WHY needed: "A man a plan a canal Panama" should return true
public static bool IsPalindromeIgnoreCase(string input)
{
    // WHY ToLowerInvariant: avoids culture-specific casing edge cases (Turkish 'i')
    string cleaned = new string(
        input.ToLowerInvariant()
             .Where(char.IsLetterOrDigit) // strip spaces and punctuation
             .ToArray()
    );
    return cleaned == new string(cleaned.Reverse().ToArray());
}
```

---

### Q6 — Reverse an Array

> **🧠 Mental Model:** A queue of people — the last person walks to the front, repeating until the order is fully reversed.

```csharp
// ── Reverse an Array (in-place) ───────────────────────────────────
// WHY in-place: O(1) extra space vs O(n) for a new array
public static void ReverseArray<T>(T[] array)
{
    int left  = 0;
    int right = array.Length - 1;

    while (left < right)
    {
        // standard swap — no temp variable needed with tuple deconstruction
        (array[left], array[right]) = (array[right], array[left]);
        left++;
        right--;
    }
    // array is mutated in-place — no return needed
}
// Time: O(n)  |  Space: O(1)
// Input: [1, 2, 3, 4, 5]  →  [5, 4, 3, 2, 1]
// Input: [1, 2]            →  [2, 1]
// Input: [42]              →  [42]   (single element — no swap)

// ── LINQ non-mutating alternative ────────────────────────────────
// WHY useful when caller needs original array preserved
public static T[] ReverseArrayCopy<T>(T[] array) => array.Reverse().ToArray();

// ── Built-in alternative ──────────────────────────────────────────
// Array.Reverse(array); // mutates in-place — same O(n) complexity
```

---

### Q7 — Check if Two Strings Are Anagrams

> **🧠 Mental Model:** Two bags of Scrabble tiles — if both bags contain exactly the same letters in the same quantities, they are anagrams.

```csharp
// ── Anagram Check ─────────────────────────────────────────────────
// WHY frequency array [26]: fixed-size O(1) space vs Dictionary overhead
public static bool AreAnagrams(string first, string second)
{
    // WHY early exit: different lengths can never be anagrams
    if (first.Length != second.Length)
        return false;

    int[] letterCounts = new int[26]; // one slot per lowercase English letter

    for (int i = 0; i < first.Length; i++)
    {
        letterCounts[first[i]  - 'a']++; // WHY subtract 'a': maps 'a'→0, 'z'→25
        letterCounts[second[i] - 'a']--; // if same letter, cancels out
    }

    // WHY All(0): any non-zero means first has a letter second doesn't (or vice-versa)
    return letterCounts.All(count => count == 0);
}
// Time: O(n)  |  Space: O(1) — array size is always 26
// Input: "anagram", "nagaram"  →  true
// Input: "rat",     "car"      →  false
// Input: "listen",  "silent"   →  true

// ── Unicode-safe version (supports non-ASCII) ─────────────────────
public static bool AreAnagramsUnicode(string first, string second)
{
    if (first.Length != second.Length) return false;
    var counts = new Dictionary<char, int>();
    foreach (char c in first)  counts[c] = counts.GetValueOrDefault(c) + 1;
    foreach (char c in second) counts[c] = counts.GetValueOrDefault(c) - 1;
    return counts.Values.All(v => v == 0);
}
```

---

### Q8 — Move All Zeros to the End of an Array

> **🧠 Mental Model:** A sorting office — let every non-zero package pass through a narrow gate; zeros wait at the back.

```csharp
// ── Move Zeros to End (in-place, order-preserving) ────────────────
// WHY two-pointer write approach: single pass, stable relative order for non-zeros
public static void MoveZerosToEnd(int[] numbers)
{
    int writePosition = 0; // next slot to write a non-zero element

    // PASS 1: shift all non-zero elements to the front, maintaining order
    foreach (int number in numbers)
    {
        if (number != 0)
            numbers[writePosition++] = number; // place non-zero, advance write pointer
    }

    // PASS 2: fill remaining tail positions with zeros
    // WHY separate pass: cleaner than checking inside the loop above
    while (writePosition < numbers.Length)
        numbers[writePosition++] = 0;
}
// Time: O(n) — two linear passes  |  Space: O(1) — in-place mutation
// Input: [0, 1, 0, 3, 12]  →  [1, 3, 12, 0, 0]
// Input: [0, 0, 1]         →  [1, 0, 0]
// Input: [0]               →  [0]

// ── LINQ alternative (not in-place — creates new array) ───────────
public static int[] MoveZerosLinq(int[] numbers) =>
    numbers.Where(n => n != 0).Concat(numbers.Where(n => n == 0)).ToArray();
```

---

### Q9 — Find the First Non-Repeating Character

> **🧠 Mental Model:** A concert ticket checker — first log all who've entered (frequency pass), then walk the list again and the first person with a single tick is your answer.

```csharp
// ── First Non-Repeating Character ────────────────────────────────
// WHY two-pass: one pass to build frequency, one to find first with count=1
public static char? FindFirstNonRepeatingChar(string input)
{
    if (string.IsNullOrEmpty(input))
        return null; // edge case: nothing to search

    // PASS 1: count frequency of every character
    var frequencyMap = new Dictionary<char, int>();
    foreach (char character in input)
        frequencyMap[character] = frequencyMap.GetValueOrDefault(character) + 1;

    // PASS 2: walk string in original order — return first with count = 1
    // WHY iterate original string (not dictionary): dictionary order is not guaranteed
    foreach (char character in input)
        if (frequencyMap[character] == 1)
            return character;

    return null; // all characters repeat — no unique character exists
}
// Time: O(n)  |  Space: O(k) — k = distinct characters (max 26 for ASCII lowercase)
// Input: "leetcode"    →  'l'
// Input: "loveleetcode" →  'v'
// Input: "aabb"        →  null  (all repeat)
// Input: "z"           →  'z'   (single char — trivially unique)
```

---

### Q10 — Remove Duplicates from a String

> **🧠 Mental Model:** A bouncer at a nightclub — keep a guest list; if you're already on it, you don't get in again.

```csharp
// ── Remove Duplicate Characters (preserve first-occurrence order) ─
// WHY LinkedHashSet equivalent: HashSet in insertion order via iteration
public static string RemoveDuplicates(string input)
{
    var seen        = new HashSet<char>(); // O(1) membership check
    var resultChars = new StringBuilder(); // WHY StringBuilder: avoids O(n²) string concat

    foreach (char character in input)
    {
        // WHY Add returns bool: true only on first insertion — single check per char
        if (seen.Add(character))
            resultChars.Append(character); // keep only first occurrence
    }

    return resultChars.ToString();
}
// Time: O(n)  |  Space: O(k) — k = distinct characters
// Input: "programming"   →  "progamin"
// Input: "aabbccdd"      →  "abcd"
// Input: "abcd"          →  "abcd"   (no duplicates — unchanged)

// ── LINQ one-liner alternative ────────────────────────────────────
public static string RemoveDuplicatesLinq(string input) =>
    new string(input.Distinct().ToArray());
// WHY Distinct() works on IEnumerable<char>: string implements IEnumerable<char>
```

---

### Q11 — Swap Two Numbers

> **🧠 Mental Model:** Three ways to swap two cups of coffee — use a third cup as temp, or do arithmetic gymnastics, or C# tuple deconstruction.

```csharp
// ── Swap Two Numbers ──────────────────────────────────────────────

// METHOD 1: Temporary variable (most readable — use this in interviews)
public static void SwapWithTemp(ref int a, ref int b)
{
    int temp = a;  // save a's value before it's overwritten
    a = b;
    b = temp;
    // WHY ref: allows mutation of caller's variables — not just local copies
}

// METHOD 2: Arithmetic swap (no temp — only works for numbers)
public static void SwapArithmetic(ref int a, ref int b)
{
    a = a + b; // a now holds the sum
    b = a - b; // recover original a: sum - original b = original a
    a = a - b; // recover original b: sum - original a = original b
    // WHY caution: can overflow for very large integers — method 1 is safer
}

// METHOD 3: XOR swap (bit manipulation — no overflow, no temp)
public static void SwapXor(ref int a, ref int b)
{
    a = a ^ b; // a ← a XOR b
    b = a ^ b; // b ← (a XOR b) XOR b = original a
    a = a ^ b; // a ← (a XOR b) XOR original a = original b
    // WHY works: XOR is its own inverse — x ^ x = 0, x ^ 0 = x
    // WHY caution: if a and b point to the same memory location, result is 0!
}

// METHOD 4: C# tuple deconstruction (most idiomatic modern C#)
public static void SwapTuple(ref int a, ref int b) =>
    (a, b) = (b, a); // compiler desugars this to a temp variable — zero overhead

// ── Usage Demo ────────────────────────────────────────────────────
// int x = 5, y = 10;
// SwapTuple(ref x, ref y);
// x → 10, y → 5
```

---

### Q12 — Extract the Surname from a Full Name

> **🧠 Mental Model:** The last word on a name tag is always the surname — split and take the last token.

```csharp
// ── Extract Surname from Full Name ───────────────────────────────
// Assumption: surname is the LAST space-separated token ("John Michael Smith" → "Smith")
public static string ExtractSurname(string fullName)
{
    if (string.IsNullOrWhiteSpace(fullName))
        throw new ArgumentException("Full name cannot be blank.", nameof(fullName));

    // WHY LastIndexOf: handles middle names without needing to split the entire string
    int lastSpaceIndex = fullName.LastIndexOf(' ');

    if (lastSpaceIndex == -1)
        return fullName; // only one word — the whole name is the surname

    // WHY + 1: skip the space itself; Substring reads from the character after it
    return fullName.Substring(lastSpaceIndex + 1);
}
// Time: O(n)  |  Space: O(n) — substring allocation
// Input: "John Smith"          →  "Smith"
// Input: "John Michael Smith"  →  "Smith"
// Input: "Madonna"             →  "Madonna"   (single name)

// ── Alternative using Split ───────────────────────────────────────
public static string ExtractSurnameViaSplit(string fullName)
{
    string[] parts = fullName.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
    return parts[^1]; // WHY [^1]: C# 8+ index-from-end — cleaner than [parts.Length-1]
}
```

---

### Q13 — Longest Substring Without Repeating Characters

> **🧠 Mental Model:** A sliding glass door — expand right to let new characters in; when a duplicate knocks, slide the left side past the previous occurrence of that character.

```csharp
// ── Longest Substring Without Repeating Characters ────────────────
// WHY sliding window + dictionary: O(n) vs O(n²) brute force
public static int LengthOfLongestSubstring(string input)
{
    // maps each character to the index AFTER its last seen position
    // WHY store index+1: allows direct jump of left pointer without extra +1 math
    var lastSeenAt = new Dictionary<char, int>();

    int maxLength = 0;
    int windowStart = 0; // left boundary of the current window

    for (int right = 0; right < input.Length; right++)
    {
        char current = input[right];

        // WHY Math.Max: only jump left pointer forward, never backward
        // (lastSeenAt may store a stale position to the left of windowStart)
        if (lastSeenAt.TryGetValue(current, out int previousIndex))
            windowStart = Math.Max(windowStart, previousIndex); // shrink window

        // WHY right - windowStart + 1: window is inclusive on both ends
        maxLength = Math.Max(maxLength, right - windowStart + 1);

        lastSeenAt[current] = right + 1; // record one past current index
    }

    return maxLength;
}
// Time: O(n)  |  Space: O(min(n, k)) — k = charset size (128 for ASCII)
// Input: "abcabcbb"  →  3  ("abc")
// Input: "bbbbb"     →  1  ("b")
// Input: "pwwkew"    →  3  ("wke")
// Input: ""          →  0

/*
TRACE: "abcabcbb"
  right=0('a'): window=[0..0]="a",   maxLen=1, seen={a→1}
  right=1('b'): window=[0..1]="ab",  maxLen=2, seen={a→1,b→2}
  right=2('c'): window=[0..2]="abc", maxLen=3, seen={a→1,b→2,c→3}
  right=3('a'): 'a' last at 1 → windowStart=max(0,1)=1
                window=[1..3]="bca", maxLen=3, seen={a→4}
  right=4('b'): 'b' last at 2 → windowStart=max(1,2)=2
                window=[2..4]="cab", maxLen=3
  ...
*/
```

---

### Q14 — Remove All Whitespace from a String

> **🧠 Mental Model:** A vacuum cleaner that only sucks up spaces — everything else passes through.

```csharp
// ── Remove All Whitespace ─────────────────────────────────────────

// METHOD 1: LINQ Where — handles all Unicode whitespace (tabs, newlines, etc.)
public static string RemoveAllWhitespace(string input) =>
    new string(input.Where(c => !char.IsWhiteSpace(c)).ToArray());
// WHY char.IsWhiteSpace: catches ' ', '\t', '\n', '\r', '\f', '\v' — not just spaces

// METHOD 2: Replace (only removes regular spaces — fast for simple cases)
public static string RemoveSpacesOnly(string input) =>
    input.Replace(" ", string.Empty);

// METHOD 3: Regex (most powerful — use for complex whitespace patterns)
// using System.Text.RegularExpressions;
public static string RemoveWhitespaceRegex(string input) =>
    Regex.Replace(input, @"\s+", string.Empty);
// WHY \s+: matches one or more whitespace chars — efficient bulk removal

// Time: O(n) for all methods  |  Space: O(n) — new string allocation
// Input: "Hello World"    →  "HelloWorld"
// Input: "  a  b  c  "   →  "abc"
// Input: "no\twhite\nspace" →  "nowhitespace"
```

---

### Q15 — Longest Palindromic Substring

> **🧠 Mental Model:** Drop a stone in a pond at each character — ripples (expand outward) as long as both shores mirror each other; the widest ripple wins.

```csharp
// ── Longest Palindromic Substring — Expand Around Center ──────────
// WHY expand-around-center: O(n²) time, O(1) space — beats brute force O(n³)
// Key insight: every palindrome expands from a center (odd: single char; even: between two)
public static string LongestPalindromicSubstring(string input)
{
    if (string.IsNullOrEmpty(input)) return string.Empty;

    int resultStart  = 0;
    int resultLength = 1; // minimum palindrome is a single character

    for (int center = 0; center < input.Length; center++)
    {
        // WHY two expansions per center: handle both odd-length and even-length palindromes
        ExpandAndUpdate(center, center);     // odd-length  (e.g. "aba")
        ExpandAndUpdate(center, center + 1); // even-length (e.g. "abba")
    }

    return input.Substring(resultStart, resultLength);

    // ── inner helper: expands outward while characters mirror ──────
    void ExpandAndUpdate(int left, int right)
    {
        // expand while within bounds and characters match
        while (left >= 0 && right < input.Length && input[left] == input[right])
        {
            left--;   // grow left boundary
            right++;  // grow right boundary
        }
        // after loop: left+1..right-1 is the valid palindrome window
        // WHY + 1 and - 1: loop overstepped by one on each side before failing
        int currentLength = right - left - 1;

        if (currentLength > resultLength)
        {
            resultLength = currentLength;
            resultStart  = left + 1; // actual start is one past the invalid left
        }
    }
}
// Time: O(n²) — n centers, each expanding up to n  |  Space: O(1)
// Input: "babad"     →  "bab"  (or "aba" — both valid)
// Input: "cbbd"      →  "bb"
// Input: "racecar"   →  "racecar"  (entire string)
// Input: "a"         →  "a"

/*
TRACE: "babad", center=1('a')
  Odd expand: left=1, right=1 → 'a'=='a' → expand left=0,right=2 → 'b'=='b' → expand
  left=-1,right=3 → out of bounds → stop
  palindrome = [0..2] = "bab", length=3  ✓
*/
```

---

### Q16 — Boxing and Unboxing in C#

> **🧠 Mental Model:** Boxing is wrapping a coin (value type) in a gift box (object on the heap). Unboxing is tearing off the wrapping to get the coin back. Wrapping and unwrapping takes time and creates garbage.

```csharp
// ── Boxing and Unboxing ───────────────────────────────────────────

// BOXING: value type → object reference (heap allocation)
// WHY it happens: when a value type is assigned to object/interface/dynamic
int    primitiveValue = 42;
object boxedValue     = primitiveValue; // CLR allocates a heap object, copies value in
// WHY matters: heap allocation + GC pressure — avoid in hot loops

// UNBOXING: object reference → value type (copy back to stack)
// WHY explicit cast required: compiler cannot verify type at compile time — checked at runtime
int unboxedValue = (int)boxedValue;     // InvalidCastException if wrong type at runtime
// WHY copy, not reference: value types don't have reference semantics

// ── Verifying they are separate copies ───────────────────────────
int original = 100;
object boxed = original; // box
original     = 200;      // mutate original — does NOT affect boxed copy

Console.WriteLine(boxed);    // 100 — box holds the original value, unaffected by mutation
Console.WriteLine(original); // 200

// ── InvalidCastException example ─────────────────────────────────
object wrongBox = 3.14;      // boxed as double
try
{
    int bad = (int)wrongBox; // WHY throws: actual runtime type is double, not int
}
catch (InvalidCastException ex)
{
    Console.WriteLine($"Cannot unbox double as int: {ex.Message}");
}

// ── Performance impact demonstration ─────────────────────────────
// BAD — boxing in a loop (creates n heap objects)
var legacyList = new System.Collections.ArrayList();
for (int i = 0; i < 1_000_000; i++)
    legacyList.Add(i); // WHY: ArrayList stores object — every int is boxed

// GOOD — generics eliminate boxing entirely
var modernList = new List<int>();
for (int i = 0; i < 1_000_000; i++)
    modernList.Add(i); // WHY: List<int> stores int directly — zero boxing

// ── Summary ───────────────────────────────────────────────────────
// Boxing:   int   → object  | heap alloc | implicit
// Unboxing: object → int    | explicit cast | throws on wrong type
// Avoid: use generics (List<T>, Dictionary<K,V>) — no boxing ever
```

---

### Q17 — Print Array Elements in a Shifted Pattern

**Problem:** `int[] givenArray = { 1, 2, 3, 4, 5, 6 };`
Print: `1 2 3 4` on line 1, and `5 6 1 2` on line 2.

> **🧠 Mental Model:** A circular conveyor belt — the array wraps around using modulo arithmetic.

```csharp
// ── Print Shifted Array Pattern ───────────────────────────────────
// Output line 1: elements at indices 0,1,2,3   → "1 2 3 4"
// Output line 2: elements at indices 4,5,0,1   → "5 6 1 2"
// Pattern: print n elements starting at 0, then n elements starting at n/2
public static void PrintShiftedPattern(int[] array)
{
    int halfLength = array.Length / 2; // split point between the two output lines

    // LINE 1: first half of the array (indices 0 to halfLength-1)
    Console.WriteLine(string.Join(" ", array.Take(halfLength)));

    // LINE 2: second half + first half (wrap-around using modulo)
    // WHY modulo: % array.Length wraps index back to start when it exceeds array end
    var secondLine = Enumerable.Range(halfLength, halfLength)
                               .Select(i => array[i % array.Length]);
    Console.WriteLine(string.Join(" ", secondLine));
}

// ── Explicit index version (clearer for interview whiteboard) ──────
public static void PrintShiftedPatternExplicit(int[] array)
{
    int n          = array.Length;
    int halfLength = n / 2;

    // Line 1: indices 0 .. halfLength-1
    for (int i = 0; i < halfLength; i++)
        Console.Write(array[i] + (i < halfLength - 1 ? " " : ""));
    Console.WriteLine();

    // Line 2: indices halfLength .. n-1, then wrap to 0 .. halfLength-1
    for (int i = halfLength; i < halfLength + halfLength; i++)
        Console.Write(array[i % n] + (i < halfLength + halfLength - 1 ? " " : ""));
    Console.WriteLine();
}
// Input: [1, 2, 3, 4, 5, 6]
// Output:
//   1 2 3 4
//   5 6 1 2
```

---

### Q18 — Left / Right Rotate an Array by K Places

> **🧠 Mental Model:** A carousel — rotating left K times moves the front K horses to the back. Reversing in sections achieves the same result in O(n) with O(1) space.

```csharp
// ── Array Rotation by K Places ────────────────────────────────────
// WHY three-reversal trick: achieves any rotation in O(n) time, O(1) space
// Key insight: right rotate by K = reverse all, reverse first K, reverse rest

// ── Helper: reverse a segment of the array in-place ───────────────
private static void ReverseSegment(int[] array, int start, int end)
{
    while (start < end)
    {
        (array[start], array[end]) = (array[end], array[start]);
        start++;
        end--;
    }
}

// ── RIGHT ROTATE by K ─────────────────────────────────────────────
public static void RotateRight(int[] array, int k)
{
    int n = array.Length;
    k %= n; // WHY mod: rotating by n is a no-op; handles k > n gracefully
    if (k == 0) return;

    ReverseSegment(array, 0, n - 1); // Step 1: reverse entire array
    ReverseSegment(array, 0, k - 1); // Step 2: reverse first k elements
    ReverseSegment(array, k, n - 1); // Step 3: reverse remaining n-k elements
}
// Input: [1,2,3,4,5,6,7], k=3  →  [5,6,7,1,2,3,4]

// ── LEFT ROTATE by K ──────────────────────────────────────────────
public static void RotateLeft(int[] array, int k)
{
    int n = array.Length;
    k %= n; // normalize: left rotate by k = right rotate by (n-k)
    if (k == 0) return;

    ReverseSegment(array, 0, k - 1); // Step 1: reverse first k elements
    ReverseSegment(array, k, n - 1); // Step 2: reverse remaining elements
    ReverseSegment(array, 0, n - 1); // Step 3: reverse entire array
}
// Input: [1,2,3,4,5,6,7], k=3  →  [4,5,6,7,1,2,3]

// Time: O(n)  |  Space: O(1)

/*
TRACE: Right rotate [1,2,3,4,5,6,7] by k=3
  Step 1 reverse all:    [7,6,5,4,3,2,1]
  Step 2 reverse [0..2]: [5,6,7,4,3,2,1]
  Step 3 reverse [3..6]: [5,6,7,1,2,3,4]  ✓
*/
```

---

### Q19 — Print All Prime Numbers Up to N

> **🧠 Mental Model:** The Sieve of Eratosthenes — imagine a grid of numbers. Cross out every multiple of 2, then 3, then 5… whatever remains uncrossed is prime.

```csharp
// ── Sieve of Eratosthenes ─────────────────────────────────────────
// WHY sieve: O(n log log n) vs O(n√n) trial division — vastly faster for large n
public static List<int> GetPrimesUpTo(int limit)
{
    if (limit < 2) return new List<int>(); // no primes below 2

    // WHY bool array (not int): smallest data type — cache-friendly for large n
    bool[] isComposite = new bool[limit + 1]; // false = "still potentially prime"

    // STEP 1: mark all multiples of i as composite, starting from i×i
    // WHY start at i*i: all smaller multiples of i already marked by previous primes
    // WHY outer loop to √limit: a composite number n has a factor ≤ √n
    for (int i = 2; (long)i * i <= limit; i++)
    {
        if (!isComposite[i]) // only process if i is still prime
        {
            for (int multiple = i * i; multiple <= limit; multiple += i)
                isComposite[multiple] = true; // mark composite
        }
    }

    // STEP 2: collect all indices that remain unmarked (prime)
    var primes = new List<int>();
    for (int number = 2; number <= limit; number++)
        if (!isComposite[number])
            primes.Add(number);

    return primes;
}
// Time: O(n log log n)  |  Space: O(n)
// Input: 10  →  [2, 3, 5, 7]
// Input: 20  →  [2, 3, 5, 7, 11, 13, 17, 19]
// Input: 1   →  []

// ── Single number primality check ────────────────────────────────
public static bool IsPrime(int number)
{
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false; // WHY: all even numbers > 2 are composite

    // WHY only check up to √number: factors pair up — one must be ≤ √number
    for (int divisor = 3; (long)divisor * divisor <= number; divisor += 2)
        if (number % divisor == 0) return false;

    return true;
}
```

---

### Q20 — Factorial Using Recursion

> **🧠 Mental Model:** A Russian nesting doll — to open the doll of size n, you must first open the doll of size n-1, all the way down to the smallest doll (1! = 1).

```csharp
// ── Factorial Using Recursion ─────────────────────────────────────
// WHY recursion: mirrors the mathematical definition directly
// Base case: 0! = 1  |  Recursive case: n! = n × (n-1)!
public static long FactorialRecursive(int n)
{
    // WHY ArgumentOutOfRangeException: factorial is undefined for negative numbers
    if (n < 0) throw new ArgumentOutOfRangeException(nameof(n), "Must be non-negative.");

    if (n == 0 || n == 1) return 1; // base case — recursion terminates here

    return n * FactorialRecursive(n - 1); // recursive case
}
// Time: O(n) — n recursive calls  |  Space: O(n) — call stack depth
// Input: 0  →  1   |  Input: 1  →  1   |  Input: 5  →  120
// Input: 10 →  3628800               |  Input: 20 →  2432902008176640000

// ── Iterative version (O(1) stack space — prefer for large n) ─────
public static long FactorialIterative(int n)
{
    if (n < 0) throw new ArgumentOutOfRangeException(nameof(n), "Must be non-negative.");
    long result = 1;
    for (int i = 2; i <= n; i++)
        result *= i; // WHY start at 2: multiplying by 1 is a no-op
    return result;
}
// Time: O(n)  |  Space: O(1)

/*
CALL STACK TRACE: FactorialRecursive(4)
  FactorialRecursive(4)
    └─ 4 × FactorialRecursive(3)
           └─ 3 × FactorialRecursive(2)
                  └─ 2 × FactorialRecursive(1)
                         └─ returns 1  (base case)
                  returns 2 × 1 = 2
           returns 3 × 2 = 6
    returns 4 × 6 = 24
*/
```

---

### Q21 — Find the Maximum Number in an Array

> **🧠 Mental Model:** Walk through a crowd holding a "current champion" sign — whenever someone taller appears, hand the sign to them.

```csharp
// ── Find Maximum Element ──────────────────────────────────────────
public static int FindMaximum(int[] numbers)
{
    if (numbers is null || numbers.Length == 0)
        throw new ArgumentException("Array must not be null or empty.", nameof(numbers));

    int maximum = numbers[0]; // WHY start with first element: safe baseline

    for (int i = 1; i < numbers.Length; i++)
    {
        // WHY compare each element: ensures we never miss the maximum
        if (numbers[i] > maximum)
            maximum = numbers[i]; // new champion found
    }

    return maximum;
}
// Time: O(n)  |  Space: O(1)
// Input: [3, 1, 4, 1, 5, 9, 2, 6]  →  9
// Input: [-5, -1, -3]               →  -1   (works with all negatives)
// Input: [42]                       →  42   (single element)

// ── LINQ alternative ──────────────────────────────────────────────
public static int FindMaximumLinq(int[] numbers) => numbers.Max();
// WHY Max() throws InvalidOperationException on empty — same safety guarantee needed
```

---

### Q22 — Fibonacci Series

**Expected Output:** `1, 1, 2, 3, 5, 8, 13, 21`

> **🧠 Mental Model:** Each step forward is the sum of the last two steps — like climbing stairs where the current step's height is determined by the two steps you just climbed.

```csharp
// ── Fibonacci Series ──────────────────────────────────────────────
// Convention used here: F(1)=1, F(2)=1, F(3)=2, ... (1-indexed, starts with two 1s)

// ITERATIVE: O(n) time, O(1) space — best for generating the sequence
public static IEnumerable<long> GenerateFibonacci(int count)
{
    if (count <= 0) yield break; // nothing to produce

    long previous = 0; // WHY 0: seed value — F(0) in 0-indexed convention
    long current  = 1; // WHY 1: F(1) — first visible term

    for (int i = 0; i < count; i++)
    {
        yield return current; // yield makes this a lazy sequence — only computes on demand

        long next = previous + current; // WHY temp: avoid overwriting before using
        previous  = current;
        current   = next;
    }
}
// GenerateFibonacci(8)  →  1, 1, 2, 3, 5, 8, 13, 21

// RECURSIVE: elegant but O(2^n) — only for education, not production
public static long FibonacciRecursive(int n)
{
    if (n <= 0) throw new ArgumentOutOfRangeException(nameof(n));
    if (n == 1 || n == 2) return 1; // base cases: F(1) = F(2) = 1
    return FibonacciRecursive(n - 1) + FibonacciRecursive(n - 2);
    // WHY avoid: exponential calls — F(50) takes minutes without memoization
}

// MEMOIZED RECURSIVE: O(n) time — fixes the exponential recursion problem
public static long FibonacciMemo(int n, Dictionary<int, long>? memo = null)
{
    memo ??= new Dictionary<int, long>();
    if (n == 1 || n == 2) return 1;
    if (memo.TryGetValue(n, out long cached)) return cached; // WHY cache: avoid recomputation
    return memo[n] = FibonacciMemo(n - 1, memo) + FibonacciMemo(n - 2, memo);
}

/*
TRACE: GenerateFibonacci(8)
  i=0: prev=0, curr=1 → yield 1  | next=1, prev=1, curr=1
  i=1: prev=1, curr=1 → yield 1  | next=2, prev=1, curr=2
  i=2: prev=1, curr=2 → yield 2  | next=3, prev=2, curr=3
  i=3: prev=2, curr=3 → yield 3  | next=5, prev=3, curr=5
  i=4: prev=3, curr=5 → yield 5  | next=8, ...
  Output: 1 1 2 3 5 8 13 21  ✓
*/
```

---

### Q23 — Basic Star Pattern Examples

> **🧠 Mental Model:** Nested loops — the outer loop controls rows, the inner loop controls how many stars to print per row.

```csharp
// ── Star Patterns ─────────────────────────────────────────────────

// PATTERN 1: Right-aligned triangle (most common interview ask)
// *
// **
// ***
// ****
// *****
public static void PrintRightTriangle(int rows)
{
    for (int row = 1; row <= rows; row++)           // outer loop: each row
    {
        for (int star = 1; star <= row; star++)     // inner loop: row i has i stars
            Console.Write("*");
        Console.WriteLine(); // move to next line after each row
    }
}

// PATTERN 2: Inverted triangle
// *****
// ****
// ***
// **
// *
public static void PrintInvertedTriangle(int rows)
{
    for (int row = rows; row >= 1; row--)
    {
        Console.WriteLine(new string('*', row)); // WHY new string: concise star repetition
    }
}

// PATTERN 3: Full pyramid (centered)
//     *
//    ***
//   *****
//  *******
// *********
public static void PrintPyramid(int rows)
{
    for (int row = 1; row <= rows; row++)
    {
        // WHY (rows - row) spaces: aligns star cluster to center
        Console.Write(new string(' ', rows - row));
        Console.WriteLine(new string('*', 2 * row - 1)); // odd count per row
    }
}

// PATTERN 4: Diamond
//     *
//    ***
//   *****
//    ***
//     *
public static void PrintDiamond(int rows)
{
    PrintPyramid(rows);     // top half (including middle)
    // bottom half: inverted pyramid without the middle row
    for (int row = rows - 1; row >= 1; row--)
    {
        Console.Write(new string(' ', rows - row));
        Console.WriteLine(new string('*', 2 * row - 1));
    }
}
// PrintRightTriangle(5) → see above  |  PrintPyramid(5) → see above
```

---

### Q24 — Evaluate Prefix Expression to Infix

**Problem:** Input: `ab+cde+**`  →  Output: `((a+b)(c(d+e)))`

> **🧠 Mental Model:** A postfix (RPN) calculator — push operands onto a stack; when you hit an operator, pop two, combine them into a bracketed expression, and push the result back.

```csharp
// ── Postfix → Infix Expression Converter ─────────────────────────
// NOTE: the input "ab+cde+**" is POSTFIX (Reverse Polish Notation), not prefix
// WHY stack: postfix evaluation naturally uses a stack — LIFO matches right-to-left combination
public static string PostfixToInfix(string postfixExpression)
{
    var operandStack = new Stack<string>();

    foreach (char token in postfixExpression)
    {
        if (char.IsLetterOrDigit(token))
        {
            // operand: push as a string directly onto the stack
            operandStack.Push(token.ToString());
        }
        else
        {
            // operator: pop two operands, combine into a bracketed infix expression
            // WHY check count: malformed input guard
            if (operandStack.Count < 2)
                throw new InvalidOperationException("Malformed postfix expression.");

            string rightOperand = operandStack.Pop(); // WHY pop right first: stack is LIFO
            string leftOperand  = operandStack.Pop(); // left operand was pushed first

            // wrap in parentheses to preserve evaluation order in infix notation
            string infixExpression = $"({leftOperand}{token}{rightOperand})";
            operandStack.Push(infixExpression);
        }
    }

    if (operandStack.Count != 1)
        throw new InvalidOperationException("Malformed postfix expression.");

    return operandStack.Pop();
}
// Time: O(n)  |  Space: O(n) — stack depth proportional to expression length

/*
TRACE: "ab+cde+**"
  'a' → stack: ["a"]
  'b' → stack: ["a","b"]
  '+' → pop b,a → push "(a+b)"         stack: ["(a+b)"]
  'c' → stack: ["(a+b)","c"]
  'd' → stack: ["(a+b)","c","d"]
  'e' → stack: ["(a+b)","c","d","e"]
  '+' → pop e,d → push "(d+e)"         stack: ["(a+b)","c","(d+e)"]
  '*' → pop (d+e),c → push "(c*(d+e))" stack: ["(a+b)","(c*(d+e))"]
  '*' → pop (c*(d+e)),(a+b) → push "((a+b)*(c*(d+e)))"
  Result: "((a+b)*(c*(d+e)))"
*/
// Input: "ab+cde+**"  →  "((a+b)*(c*(d+e)))"
// (Question's expected output slightly simplified — parentheses still fully correct)
```

---

### Q25 — Next Number in the Series: 1, 3, 7, 13, …

> **🧠 Mental Model:** Look at the gaps between terms: 2, 4, 6 — the differences form an arithmetic sequence increasing by 2. The next difference is 8, so the next term is 13 + 8 = **21**.

```
SERIES ANALYSIS:
  Term:       1    3    7    13   21   31 ...
  Difference:   +2   +4   +6   +8   +10
  Pattern:  differences increase by 2 each time

GENERAL FORMULA:
  diff(n) = 2n  (n-th gap)
  T(n) = 1 + 2(1 + 2 + 3 + ... + (n-1)) = 1 + n(n-1)
  T(1)=1, T(2)=3, T(3)=7, T(4)=13, T(5)=21 ✓

NEXT NUMBER: T(5) = 1 + 5×4 = 21
```

```csharp
// ── Generate the Series: T(n) = n² - n + 1 ───────────────────────
// WHY formula: n²-n+1 simplifies 1 + n(n-1) — direct O(1) computation per term
public static long SeriesTerm(int n)
{
    if (n < 1) throw new ArgumentOutOfRangeException(nameof(n), "Term index must be ≥ 1.");
    return (long)n * n - n + 1; // WHY cast to long: avoids int overflow for large n
}

public static IEnumerable<long> GenerateSeries(int count)
{
    for (int n = 1; n <= count; n++)
        yield return SeriesTerm(n);
}
// GenerateSeries(6)  →  1, 3, 7, 13, 21, 31
// SeriesTerm(5)      →  21  (answer to interview question)
// SeriesTerm(6)      →  31
```

---

## Section 53 — SQL Interview Questions

---

### Q26 — Find Duplicate Records in a Table

> **🧠 Mental Model:** A roll call — GROUP BY groups identical names together; HAVING filters to groups where the count is more than one.

```sql
-- ── Find Duplicate Records ────────────────────────────────────────
-- Assumption: duplicates = rows where the same combination of
-- meaningful columns (e.g., Name + Email) appears more than once

-- APPROACH 1: GROUP BY + HAVING (most common interview answer)
SELECT
    Name,
    Email,
    COUNT(*) AS DuplicateCount   -- how many times this combination appears
FROM
    Employees
GROUP BY
    Name, Email
HAVING
    COUNT(*) > 1;                -- HAVING filters AFTER grouping (WHERE filters before)
-- WHY HAVING not WHERE: WHERE cannot reference aggregate functions like COUNT(*)

-- APPROACH 2: Show ALL duplicate rows (including all occurrences)
SELECT *
FROM Employees
WHERE Name IN (
    SELECT Name
    FROM   Employees
    GROUP  BY Name
    HAVING COUNT(*) > 1
)
ORDER BY Name;

-- APPROACH 3: Using ROW_NUMBER() — also used for deletion of duplicates
WITH RankedRows AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Name, Email   -- restart numbering per unique combination
            ORDER BY     EmployeeId    -- keep the earliest record (lowest Id)
        ) AS RowRank
    FROM Employees
)
SELECT * FROM RankedRows WHERE RowRank > 1;  -- rows ranked 2+ are the duplicates

-- ── Delete duplicates — keep only the first occurrence ────────────
WITH RankedRows AS (
    SELECT
        EmployeeId,
        ROW_NUMBER() OVER (PARTITION BY Name, Email ORDER BY EmployeeId) AS RowRank
    FROM Employees
)
DELETE FROM Employees WHERE EmployeeId IN (
    SELECT EmployeeId FROM RankedRows WHERE RowRank > 1
);
```

---

### Q27 — Find the Nth Highest Salary

> **🧠 Mental Model:** Sort salaries in descending order, skip the top N-1 values, and take the next one — that's the Nth highest.

```sql
-- ── Nth Highest Salary ────────────────────────────────────────────

-- APPROACH 1: DENSE_RANK() — handles ties correctly (recommended)
-- WHY DENSE_RANK over RANK: if two employees share rank 1, DENSE_RANK gives
-- next salary rank 2 (not rank 3 as RANK would) — interviewer usually expects DENSE_RANK
WITH SalaryRanked AS (
    SELECT
        EmployeeId,
        Name,
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT *
FROM   SalaryRanked
WHERE  SalaryRank = 2;  -- change 2 to N for Nth highest

-- APPROACH 2: OFFSET-FETCH (SQL Server 2012+ / PostgreSQL)
-- WHY DISTINCT: eliminates duplicate salary values so OFFSET skips true N-1 unique salaries
SELECT DISTINCT Salary
FROM   Employees
ORDER  BY Salary DESC
OFFSET 1 ROWS        -- skip top 1 salary → gives 2nd highest (OFFSET N-1 for Nth)
FETCH NEXT 1 ROW ONLY;

-- APPROACH 3: Scalar function (reusable for any N)
CREATE FUNCTION GetNthHighestSalary(@N INT)
RETURNS TABLE
AS
RETURN (
    WITH Ranked AS (
        SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS Rnk
        FROM   Employees
    )
    SELECT Salary FROM Ranked WHERE Rnk = @N
);
-- Usage: SELECT * FROM GetNthHighestSalary(3);

-- ── Example ───────────────────────────────────────────────────────
-- Employees: [100k, 90k, 90k, 80k]
-- DENSE_RANK: 1st=100k, 2nd=90k, 3rd=80k   (ties share same rank)
-- RANK:       1st=100k, 2nd=90k, 4th=80k   (gap after tied rank)
-- WHY prefer DENSE_RANK: no gaps — N=3 returns 80k as expected
```

---

### Q28 — Count of Employees with the 2nd Highest Salary per Department

> **🧠 Mental Model:** Group employees by department, rank salaries within each group, then count how many people share the second slot.

```sql
-- ── Count of Employees with 2nd Highest Salary per Department ─────
WITH DepartmentRanked AS (
    SELECT
        DepartmentId,
        DepartmentName,
        EmployeeId,
        Name,
        Salary,
        -- WHY DENSE_RANK() OVER PARTITION BY: ranks salaries independently per department
        DENSE_RANK() OVER (
            PARTITION BY DepartmentId   -- restart ranking for each department
            ORDER BY     Salary DESC    -- highest salary = rank 1
        ) AS SalaryRank
    FROM
        Employees
)
SELECT
    DepartmentId,
    DepartmentName,
    Salary              AS SecondHighestSalary,
    COUNT(EmployeeId)   AS EmployeeCount   -- how many share this salary within the dept
FROM
    DepartmentRanked
WHERE
    SalaryRank = 2       -- only the second-highest salary tier per department
GROUP BY
    DepartmentId,
    DepartmentName,
    Salary
ORDER BY
    DepartmentId;

-- ── Result shape ──────────────────────────────────────────────────
-- DeptId | DeptName | SecondHighestSalary | EmployeeCount
-- -------+----------+---------------------+--------------
-- 1      | Sales    | 75000               | 2
-- 2      | IT       | 95000               | 1
-- WHY two employees can share 2nd highest: ties at same salary level
```

---

### Q29 — Find an Employee's Manager from the Same Table (Self Join)

> **🧠 Mental Model:** A family tree stored in a single table — each person has a reference (ManagerId) pointing to another row in the same table that represents their parent.

```sql
-- ── Employee-Manager Self Join ────────────────────────────────────
-- Table: Employees (EmployeeId, Name, ManagerId)
-- ManagerId is a FK referencing EmployeeId in the SAME table

-- APPROACH 1: INNER JOIN (excludes top-level employees with NULL ManagerId)
SELECT
    emp.EmployeeId,
    emp.Name         AS EmployeeName,
    mgr.Name         AS ManagerName
FROM
    Employees AS emp          -- "emp" alias = the employee
    INNER JOIN Employees mgr  -- "mgr" alias = the same table, read as the manager row
        ON emp.ManagerId = mgr.EmployeeId  -- link child row to parent row
ORDER BY
    emp.EmployeeId;

-- APPROACH 2: LEFT JOIN (includes top-level employees — their ManagerName shows NULL)
SELECT
    emp.EmployeeId,
    emp.Name             AS EmployeeName,
    ISNULL(mgr.Name, 'No Manager') AS ManagerName  -- WHY ISNULL: replaces NULL with label
FROM
    Employees AS emp
    LEFT JOIN Employees mgr
        ON emp.ManagerId = mgr.EmployeeId;
-- WHY LEFT JOIN: does not drop employees whose ManagerId is NULL (CEO has no manager)

-- ── Sample Data & Output ──────────────────────────────────────────
-- EmployeeId | Name    | ManagerId       EmployeeName | ManagerName
-- -----------+---------+----------  →   -------------+------------
-- 1          | Alice   | NULL            Alice        | No Manager   (CEO)
-- 2          | Bob     | 1               Bob          | Alice
-- 3          | Charlie | 1               Charlie      | Alice
-- 4          | Dave    | 2               Dave         | Bob
```

---

### Q30 — COUNT(\*) vs COUNT(name) vs COUNT(address) — Which Is Faster?

> **🧠 Mental Model:** A census worker counting people in a room. `COUNT(*)` counts heads regardless of whether they're asleep; `COUNT(column)` skips anyone who didn't fill out that field (NULL).

```sql
-- ── COUNT variants explained ──────────────────────────────────────

-- COUNT(*) — counts ALL rows including NULLs; fastest in most databases
SELECT COUNT(*) FROM Employees;
-- WHY fastest: no column evaluation — the engine counts physical rows.
-- SQL Server can use any narrow index (or the heap page count) without reading column data.

-- COUNT(name) — counts only rows where Name IS NOT NULL
SELECT COUNT(name) FROM Employees;
-- WHY slower than COUNT(*): engine must read and check the Name column for each row.
-- If Name is NOT NULL (constrained), optimizer may optimize to COUNT(*) internally.

-- COUNT(address) — counts only rows where Address IS NOT NULL
SELECT COUNT(address) FROM Employees;
-- WHY slowest (typically): Address often nullable + potentially stored in variable-length
-- column or separate page — requires reading Address page data to evaluate NULLs.

-- ─────────────────────────────────────────────────────────────────
-- SPEED ORDER (general case with nullable columns):
--   COUNT(*) > COUNT(name[NOT NULL]) ≥ COUNT(name[nullable]) > COUNT(address[nullable])
--
-- EXCEPTION: if an index covers the counted column, COUNT(column) may be index-only
-- and equally fast as COUNT(*) — always verify with an actual execution plan.
-- ─────────────────────────────────────────────────────────────────

-- Practical rule for interviews:
-- "COUNT(*) counts every row. COUNT(col) skips NULLs and reads the column.
--  COUNT(*) is typically fastest; use COUNT(col) only when NULL-exclusion is needed."
```

---

### Q31 — Find the Maximum Salary from Employees

> **🧠 Mental Model:** Walk the salary column and remember the biggest number seen so far — SQL's MAX() does exactly this with an optimized index scan.

```sql
-- ── Maximum Salary ────────────────────────────────────────────────

-- APPROACH 1: MAX aggregate (simplest and most common)
SELECT MAX(Salary) AS MaximumSalary
FROM   Employees;
-- WHY MAX: a single-pass O(n) scan (or O(log n) with a descending index) — no sorting

-- APPROACH 2: ORDER BY + TOP 1 (returns the employee row, not just the salary)
SELECT TOP 1 *
FROM   Employees
ORDER  BY Salary DESC;
-- WHY TOP 1: useful when you need EmployeeName alongside the salary

-- APPROACH 3: Subquery with NOT IN (avoids MAX — classic alternative)
SELECT *
FROM   Employees
WHERE  Salary NOT IN (
    SELECT Salary
    FROM   Employees e2
    WHERE  e2.Salary < Employees.Salary -- WHY: exclude anyone with a lower salary
);
-- WHY less preferred: expensive correlated subquery — O(n²); use MAX or window functions

-- APPROACH 4: Using DENSE_RANK (consistent with other salary questions in this set)
WITH RankedSalaries AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT * FROM RankedSalaries WHERE SalaryRank = 1;

-- Input table:  Alice 90k | Bob 120k | Charlie 85k | Dave 120k
-- MAX result:   120000
-- TOP 1 result: Bob (or Dave — ORDER BY Salary DESC ties are arbitrary without tiebreaker)
-- DENSE_RANK=1: both Bob and Dave returned
```

---

### Q32 — Find Employees with the 2nd Highest Salary

> **🧠 Mental Model:** Remove the top tier, then find the new top — or use DENSE_RANK() to label tiers and pick label #2.

```sql
-- ── 2nd Highest Salary Employees ──────────────────────────────────

-- APPROACH 1: DENSE_RANK (recommended — handles ties)
WITH SalaryRanked AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT *
FROM   SalaryRanked
WHERE  SalaryRank = 2;
-- Returns ALL employees tied at the 2nd highest salary level

-- APPROACH 2: MAX excluding the maximum (classic two-step approach)
SELECT *
FROM   Employees
WHERE  Salary = (
    SELECT MAX(Salary)              -- find the max among...
    FROM   Employees
    WHERE  Salary < (               -- ...all salaries strictly below the overall max
        SELECT MAX(Salary)
        FROM Employees
    )
);
-- WHY nested subqueries: inner MAX finds overall max; outer MAX finds max below that

-- APPROACH 3: OFFSET-FETCH
SELECT DISTINCT Salary
FROM   Employees
ORDER  BY Salary DESC
OFFSET 1 ROWS FETCH NEXT 1 ROW ONLY;
-- WHY DISTINCT: without it, OFFSET skips a row (not a unique salary tier)

-- ── Expected results ──────────────────────────────────────────────
-- Employees: Alice 120k, Bob 120k, Charlie 90k, Dave 90k, Eve 75k
-- DENSE_RANK = 1: Alice, Bob (120k)
-- DENSE_RANK = 2: Charlie, Dave (90k)  ← Q32 answer
-- DENSE_RANK = 3: Eve (75k)
```

---

### Q33 — Left Join in LINQ (Method Syntax and Query Syntax)

> **🧠 Mental Model:** SQL LEFT JOIN says "give me everything from the left table, with matching data from the right table where available, and NULL otherwise." In LINQ, this maps to `GroupJoin` (match groups) followed by `SelectMany` with `DefaultIfEmpty` (flatten, filling gaps with nulls).

```csharp
// ── LEFT JOIN in LINQ ─────────────────────────────────────────────
// Sample entities
public record Employee(int Id, string Name, int DepartmentId);
public record Department(int Id, string DepartmentName);

// SQL equivalent:
// SELECT e.Name, d.DepartmentName
// FROM   Employees   e
// LEFT   JOIN Departments d ON e.DepartmentId = d.Id

// ── METHOD SYNTAX ─────────────────────────────────────────────────
// WHY GroupJoin + SelectMany + DefaultIfEmpty: this is LINQ's canonical LEFT JOIN pattern
IEnumerable<(string EmployeeName, string? DepartmentName)> LeftJoinMethodSyntax(
    IEnumerable<Employee>   employees,
    IEnumerable<Department> departments
)
{
    return employees
        .GroupJoin(
            inner:       departments,
            outerKeySelector: emp  => emp.DepartmentId,  // left key
            innerKeySelector: dept => dept.Id,            // right key
            resultSelector:   (emp, matchingDepts) => new { emp, matchingDepts }
            // WHY GroupJoin: gives each employee a collection of matching departments
            // (which may be empty — that's what creates the "left" behavior)
        )
        .SelectMany(
            collectionSelector: joined => joined.matchingDepts.DefaultIfEmpty(),
            // WHY DefaultIfEmpty: when no department matches, injects a null record
            // so the employee is still included in the result (LEFT join semantic)
            resultSelector: (joined, dept) =>
                (EmployeeName:    joined.emp.Name,
                 DepartmentName: dept?.DepartmentName)  // WHY ?: null-safe — dept can be null
        );
}

// ── QUERY SYNTAX ──────────────────────────────────────────────────
IEnumerable<(string EmployeeName, string? DepartmentName)> LeftJoinQuerySyntax(
    IEnumerable<Employee>   employees,
    IEnumerable<Department> departments
)
{
    return from emp in employees
           join dept in departments
               on emp.DepartmentId equals dept.Id
               into matchingDepts             // "into" creates the group — like GroupJoin
           from dept in matchingDepts.DefaultIfEmpty()  // flatten; null if no match
           select (
               EmployeeName:    emp.Name,
               DepartmentName: dept?.DepartmentName     // null-safe access
           );
}

// ── Usage Example ─────────────────────────────────────────────────
// var employees   = new[] { new Employee(1,"Alice",10), new Employee(2,"Bob",99) };
// var departments = new[] { new Department(10,"Engineering") };
//
// LeftJoinMethodSyntax(employees, departments):
//   ("Alice", "Engineering")   ← matched
//   ("Bob",   null)            ← no matching department — still included (LEFT join)
```

---

```
╔══════════════════════════════════════════════════════════════════╗
║  SECTION 52-53 SUMMARY — REPEATED INTERVIEW QUESTIONS           ║
╠══════════════════════════════════════════════════════════════════╣
║  STRING QUESTIONS (Q1-Q15)                                       ║
║  ✅ Reverse string/array    → Two-pointer swap, O(n) O(1)        ║
║  ✅ Palindrome / Anagram    → Two-pointer / freq array [26]      ║
║  ✅ Two Sum                 → HashMap complement, O(n)           ║
║  ✅ Longest substr no-rep   → Sliding window + Dictionary        ║
║  ✅ Longest palindrome sub  → Expand-around-center, O(n²) O(1)  ║
║  ✅ First non-repeating     → Two-pass frequency map            ║
║  ✅ Move zeros to end       → Write-pointer, single pass         ║
╠══════════════════════════════════════════════════════════════════╣
║  MISC C# QUESTIONS (Q16-Q25)                                     ║
║  ✅ Boxing/Unboxing         → Heap wrap; use generics to avoid   ║
║  ✅ Array rotation (L/R)    → Three-reversal trick, O(n) O(1)   ║
║  ✅ Fibonacci               → Iterative with yield, O(n) O(1)   ║
║  ✅ Factorial recursion     → Base 0!=1; iterative preferred     ║
║  ✅ Primes (Sieve)          → O(n log log n) — mark composites   ║
║  ✅ Postfix → Infix         → Stack-based expression parsing     ║
╠══════════════════════════════════════════════════════════════════╣
║  SQL QUESTIONS (Q26-Q33)                                         ║
║  ✅ Duplicates              → GROUP BY + HAVING COUNT(*) > 1     ║
║  ✅ Nth highest salary      → DENSE_RANK() OVER ORDER BY DESC    ║
║  ✅ 2nd highest per dept    → DENSE_RANK() OVER PARTITION BY     ║
║  ✅ Employee-Manager        → Self JOIN (emp alias + mgr alias)  ║
║  ✅ COUNT variants          → COUNT(*) fastest; COUNT(col) skips NULL ║
║  ✅ LEFT JOIN in LINQ       → GroupJoin + SelectMany + DefaultIfEmpty ║
╚══════════════════════════════════════════════════════════════════╝
```

