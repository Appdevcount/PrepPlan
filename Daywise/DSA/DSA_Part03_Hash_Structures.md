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

