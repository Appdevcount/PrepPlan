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

