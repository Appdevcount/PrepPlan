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

