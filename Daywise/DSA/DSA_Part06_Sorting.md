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

