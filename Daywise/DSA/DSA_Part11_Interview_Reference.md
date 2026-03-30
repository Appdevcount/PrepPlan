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



