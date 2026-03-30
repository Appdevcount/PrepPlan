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

