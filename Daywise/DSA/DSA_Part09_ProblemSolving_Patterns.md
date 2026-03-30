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

