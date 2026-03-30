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

