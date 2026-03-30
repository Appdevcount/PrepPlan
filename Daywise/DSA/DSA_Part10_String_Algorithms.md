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

