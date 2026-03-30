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

