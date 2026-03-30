## Section 17 — Graph Fundamentals

> **🧠 Mental Model: A Road Network**
>
> A graph is like a city road network. Cities are nodes (vertices). Roads are edges. Some roads are one-way (directed graph). Roads have distance (weighted graph). You can reach city B from city A if there's a path — but finding the SHORTEST path requires algorithms like Dijkstra. The key insight: graphs model ANY relationship between entities.

```
GRAPH REPRESENTATIONS:
═══════════════════════════════════════════════════════════════
  Graph with 5 nodes, edges: 0-1, 0-2, 1-3, 2-3, 3-4

  ADJACENCY MATRIX (good for dense graphs):
       0  1  2  3  4
    0 [0, 1, 1, 0, 0]
    1 [1, 0, 0, 1, 0]
    2 [1, 0, 0, 1, 0]
    3 [0, 1, 1, 0, 1]
    4 [0, 0, 0, 1, 0]
  Space: O(V²). Edge check: O(1). List neighbors: O(V).

  ADJACENCY LIST (preferred — good for sparse graphs):
    0: [1, 2]
    1: [0, 3]
    2: [0, 3]
    3: [1, 2, 4]
    4: [3]
  Space: O(V+E). Edge check: O(degree). List neighbors: O(degree).

  In C#: Dictionary<int, List<int>> or List<List<int>>
═══════════════════════════════════════════════════════════════

GRAPH TYPES:
═══════════════════════════════════════════════════════════════
  Undirected: edges go both ways (social network friends)
  Directed (Digraph): edges have direction (Twitter follows)
  Weighted: edges have weights (road distances)
  DAG: Directed Acyclic Graph (no cycles) — used in topological sort
  Bipartite: nodes split in 2 groups, edges only cross groups
  Tree: connected graph with V-1 edges and no cycles
═══════════════════════════════════════════════════════════════
```

### Building a Graph in C#

```csharp
// ADJACENCY LIST — most common in interviews
int V = 5; // number of vertices
var adj = new List<List<int>>();
for (int i = 0; i < V; i++)
    adj.Add(new List<int>());  // initialize each vertex's neighbor list

// Add undirected edge 0-1
void AddEdge(int u, int v) {
    adj[u].Add(v);  // u → v
    adj[v].Add(u);  // v → u (undirected)
}

// WEIGHTED GRAPH: store (neighbor, weight) pairs
var weightedAdj = new List<List<(int node, int weight)>>();

// FROM EDGE LIST (common input format in problems):
int[][] edges = { new[]{0,1}, new[]{0,2}, new[]{1,3} };
var graph = new Dictionary<int, List<int>>();
foreach (int[] e in edges) {
    if (!graph.ContainsKey(e[0])) graph[e[0]] = new List<int>();
    if (!graph.ContainsKey(e[1])) graph[e[1]] = new List<int>();
    graph[e[0]].Add(e[1]);
    graph[e[1]].Add(e[0]);  // remove for directed graph
}
```

---

### 🔴🔥 Practice Problem: Number of Islands (LeetCode #200 — Medium) — MUST SOLVE

**Problem:** Given 2D grid of '1's (land) and '0's (water), count number of islands.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: NUMBER OF ISLANDS                           ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Find each '1', BFS/DFS  │ O(m×n)    │ O(m×n)  ║
║  (also opt.) │ to mark entire island   │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DFS/BFS  │ For each unvisited '1', │ O(m×n)    │ O(m×n)  ║
║  (CANONICAL) │ DFS to sink entire isl. │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 UNION    │ Union-Find to connect   │ O(m×n×α)  │ O(m×n)  ║
║  FIND        │ adjacent land cells     │ ≈O(m×n)   │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Treat the grid as a graph. Each '1' cell is a node.
             Adjacent '1' cells share edges. Count connected components.
             DFS from each unvisited '1' marks its entire island.
```

> **🔑 CORE IDEA:** For each unvisited '1', flood-fill (DFS/BFS) marking all connected '1's as visited. Number of flood-fills = number of islands.

```
VISUALIZATION:
  Grid:        After DFS from (0,0):    After DFS from (0,4):
  1 1 1 0 0    2 2 2 0 0                2 2 2 0 3
  1 1 0 0 0    2 2 0 0 0                2 2 0 0 0
  0 0 0 1 1    0 0 0 1 1  ← unvisited  0 0 0 2 2
  0 0 0 0 0    0 0 0 0 0                0 0 0 0 0

  Count=1 → Count=2 → Count=3 (after DFS from (2,3))
  Answer = 3 islands
```

```csharp
public int NumIslands(char[][] grid) {
    if (grid == null || grid.Length == 0) return 0;

    int totalRows = grid.Length, totalCols = grid[0].Length;
    int islandCount = 0;

    // STEP 1: Scan every cell; for each unvisited land cell, start a DFS flood-fill
    for (int row = 0; row < totalRows; row++) {
        for (int col = 0; col < totalCols; col++) {
            if (grid[row][col] == '1') {
                // STEP 2: New island found — increment count and sink the whole island
                islandCount++;             // each '1' we find without prior DFS = new island
                SinkIsland(grid, row, col);  // flood-fill: mark all connected land as visited
            }
        }
    }
    return islandCount;
}

// WHY 'SinkIsland'? More descriptive than 'DFS' — describes the "mark as visited" strategy
void SinkIsland(char[][] grid, int row, int col) {
    // STEP 1: Boundary and water check — stop if out of bounds or already sunk/water
    // WHY bounds check? Prevent IndexOutOfRangeException on grid edges
    // WHY check != '1'? '0' = water, already-sunk land — no island to explore
    if (row < 0 || row >= grid.Length || col < 0 || col >= grid[0].Length || grid[row][col] != '1')
        return;

    // STEP 2: Sink this land cell to prevent revisiting (in-place visited marker)
    // WHY '0' not a separate visited array? Saves O(m×n) extra space; '0' already means "water"
    grid[row][col] = '0';

    // STEP 3: Recursively flood-fill all 4 cardinal neighbors
    SinkIsland(grid, row - 1, col);  // up
    SinkIsland(grid, row + 1, col);  // down
    SinkIsland(grid, row, col - 1);  // left
    SinkIsland(grid, row, col + 1);  // right
}
// Time: O(m×n) — each cell visited at most once
// Space: O(m×n) — recursion stack worst case (all land, deep DFS)
```

```
TRACE: grid = [["1","1","0"],["0","1","0"],["0","0","1"]]
═══════════════════════════════════════════════════════════════
  (0,0)='1' → count=1 → DFS(0,0):
    mark (0,0)='0', recurse: up OOB, down=(1,0)='0',
    left OOB, right=(0,1)='1' → DFS(0,1):
      mark (0,1)='0', recurse: right=(0,2)='0', down=(1,1)='1' → DFS(1,1):
        mark (1,1)='0', all neighbors '0' or OOB → done

  (0,1)='0' skip, (0,2)='0' skip
  (1,0)='0' skip, (1,1)='0' skip (marked), (1,2)='0' skip
  (2,0)='0' skip, (2,1)='0' skip
  (2,2)='1' → count=2 → DFS(2,2): mark '0', no '1' neighbors

  Answer: 2 ✅
═══════════════════════════════════════════════════════════════
```

> **🎯 Key Insight:** Grid problems are graph problems in disguise. The "sink the island" DFS (marking visited cells as '0' in-place) is cleaner than maintaining a separate visited array. This connected components counting pattern appears in dozens of problems: "Max Area of Island," "Pacific Atlantic Water Flow," "Word Search."

---

## Section 18 — Graph Traversals: DFS & BFS

> **🧠 Mental Model: DFS = Exploring a Maze / BFS = Ripples in Water**
>
> **DFS**: Like exploring a maze — go as deep as possible down one path, hit a dead end, backtrack, try another path. Uses a **stack** (explicit or call stack).
>
> **BFS**: Like dropping a stone in water — ripples spread outward in all directions equally. Explores all neighbors at distance 1, then distance 2, etc. Uses a **queue**. BFS guarantees **shortest path** in unweighted graphs.

```
DFS vs BFS COMPARISON:
═══════════════════════════════════════════════════════════════
  Graph:  1 — 2 — 4
          |   |
          3 — 5

  DFS from 1 (stack-based, exploring order depends on adj list):
  Visit 1 → push neighbors [2,3] → visit 3 → push neighbors [1,5]
  → 1 visited → visit 5 → push [2,3] → 2,3 visited → visit 2
  → push [1,4,5] → all visited except 4 → visit 4
  Order: 1, 3, 5, 2, 4 (or similar — depends on order)

  BFS from 1 (queue-based):
  Queue: [1] → visit 1, enqueue [2,3]
  Queue: [2,3] → visit 2, enqueue [4,5]; visit 3, enqueue [5]
  Queue: [4,5,5] → visit 4; visit 5; skip 5 (visited)
  Order: 1, 2, 3, 4, 5 (level by level)

  BFS GUARANTEES shortest path in unweighted graphs!
  DFS is better for: cycle detection, topological sort, all paths
═══════════════════════════════════════════════════════════════
```

### DFS & BFS Templates

```csharp
// ═══ DFS — RECURSIVE (most intuitive) ═══
void DFSRecursive(Dictionary<int, List<int>> graph, int node, HashSet<int> visited) {
    // STEP 1: Mark node visited and process it
    visited.Add(node);
    Console.Write(node + " ");  // process node

    // STEP 2: Recurse into all unvisited neighbors
    foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>())) {
        if (!visited.Contains(neighbor))  // only visit unvisited
            DFSRecursive(graph, neighbor, visited);
    }
}

// ═══ DFS — ITERATIVE (avoids stack overflow on deep graphs) ═══
void DFSIterative(Dictionary<int, List<int>> graph, int start) {
    // STEP 1: Initialize visited set and push start node onto explicit stack
    var visited = new HashSet<int>();
    var stack = new Stack<int>();
    stack.Push(start);

    while (stack.Count > 0) {
        // STEP 2: Pop next node; skip if already visited
        int node = stack.Pop();
        if (visited.Contains(node)) continue;  // already processed
        visited.Add(node);
        Console.Write(node + " ");

        // STEP 3: Push unvisited neighbors for future exploration
        // Push neighbors in reverse order to maintain left-to-right visit order
        foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>()))
            if (!visited.Contains(neighbor))
                stack.Push(neighbor);
    }
}

// ═══ BFS — ITERATIVE (always use queue) ═══
void BFS(Dictionary<int, List<int>> graph, int start) {
    // STEP 1: Initialize queue with start node; mark start visited immediately
    var visited = new HashSet<int> { start };
    var queue = new Queue<int>();
    queue.Enqueue(start);

    while (queue.Count > 0) {
        // STEP 2: Process front node
        int node = queue.Dequeue();
        Console.Write(node + " ");

        // STEP 3: Enqueue unvisited neighbors and mark them visited NOW
        foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>())) {
            // WHY add to visited when ENQUEUING (not dequeuing)?
            // Prevents adding the same node to queue multiple times
            if (!visited.Contains(neighbor)) {
                visited.Add(neighbor);
                queue.Enqueue(neighbor);
            }
        }
    }
}

// ═══ BFS SHORTEST PATH (unweighted) ═══
int BFSShortestPath(Dictionary<int, List<int>> graph, int start, int end) {
    // STEP 1: Seed queue with (start, distance=0)
    var visited = new HashSet<int> { start };
    var queue = new Queue<(int node, int dist)>();
    queue.Enqueue((start, 0));

    while (queue.Count > 0) {
        // STEP 2: Dequeue; if we reached destination, return accumulated distance
        var (node, dist) = queue.Dequeue();
        if (node == end) return dist;  // found! return distance

        // STEP 3: Enqueue neighbors with incremented distance
        foreach (int neighbor in graph.GetValueOrDefault(node, new List<int>())) {
            if (!visited.Contains(neighbor)) {
                visited.Add(neighbor);
                queue.Enqueue((neighbor, dist + 1));  // increment distance
            }
        }
    }
    return -1;  // unreachable
}
```

---

### 🔴🔥 Practice Problem: Course Schedule (LeetCode #207 — Medium) — MUST SOLVE

**Problem:** There are `n` courses. Some courses have prerequisites. Can you finish all courses?

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: COURSE SCHEDULE (CYCLE DETECTION)           ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Check all possible      │ O(V+E)×V  │ O(V+E)  ║
║              │ orderings               │           │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DFS CYCLE│ 3-state DFS coloring:   │ O(V+E)    │ O(V+E)  ║
║  DETECTION   │ white/gray/black        │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 TOPO SORT│ Kahn's BFS: if all      │ O(V+E)    │ O(V+E)  ║
║  (BFS KAHN'S)│ nodes processed→no cycle│            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: The problem reduces to: "Does this directed graph have a cycle?"
             If cycle exists → impossible to finish courses.
             3-color DFS: white=unvisited, gray=in-progress, black=done.
             If you revisit a GRAY node → cycle found!
```

> **🔑 CORE IDEA:** DFS with 3 states: 0=unvisited, 1=in-progress, 2=done. If you reach a node with state=1 during DFS, you've found a cycle → impossible.

```
3-COLOR DFS VISUALIZATION: 0→1→2→0 (cycle) vs 0→1→2 (no cycle)
═══════════════════════════════════════════════════════════════
  CYCLE: 0 requires 1, 1 requires 2, 2 requires 0

  DFS(0): color[0]=gray
    DFS(1): color[1]=gray
      DFS(2): color[2]=gray
        neighbor=0: color[0]==gray → CYCLE DETECTED! ❌

  NO CYCLE: 0 requires 1, 1 requires 2, 2 requires nothing

  DFS(0): color[0]=gray
    DFS(1): color[1]=gray
      DFS(2): color[2]=gray
        no neighbors → color[2]=black, return false
      color[1]=black, return false
    color[0]=black, return false
  No cycle ✅
═══════════════════════════════════════════════════════════════
```

```csharp
public bool CanFinish(int numCourses, int[][] prerequisites) {
    // STEP 1: Build directed adjacency list — edge direction: prerequisite → dependent
    // WHY graph[pre[1]].Add(pre[0]) and not the reverse?
    // prerequisite pair [a, b] means "b must come before a" (b is prereq of a)
    // We add edge b→a: "b unlocks a". A cycle in this graph means a deadlock.
    var graph = new List<List<int>>();
    for (int courseIndex = 0; courseIndex < numCourses; courseIndex++)
        graph.Add(new List<int>());
    foreach (int[] prereqPair in prerequisites)
        graph[prereqPair[1]].Add(prereqPair[0]); // prereqPair[1] must come before prereqPair[0]

    // STEP 2: Initialize 3-state coloring array (0=unvisited, 1=in-progress, 2=done)
    int[] state = new int[numCourses];

    // STEP 3: Run cycle-detection DFS from every unvisited node (handles disconnected graphs)
    // WHY loop all nodes? Graph may be disconnected — some courses may have no shared prerequisites
    for (int courseId = 0; courseId < numCourses; courseId++)
        if (state[courseId] == 0 && HasCycle(graph, state, courseId))
            return false;

    return true;
}

bool HasCycle(List<List<int>> graph, int[] state, int node) {
    // STEP 1: Mark node as IN-PROGRESS (gray) — currently on the DFS call stack
    state[node] = 1;  // mark as IN-PROGRESS (gray) — we're currently exploring this path

    foreach (int neighbor in graph[node]) {
        // STEP 2: If neighbor is IN-PROGRESS (gray) → back edge → CYCLE found
        if (state[neighbor] == 1)  // found a node we're currently exploring = BACK EDGE = CYCLE
            return true;
        // STEP 3: If unvisited, recurse; propagate cycle detection upward
        if (state[neighbor] == 0 && HasCycle(graph, state, neighbor))
            return true;  // cycle found deeper in the recursion
        // state[neighbor] == 2: already fully processed, safe to skip
    }

    // STEP 4: All descendants explored with no cycle — mark DONE (black)
    state[node] = 2;  // mark as DONE (black) — no cycle through this node
    return false;
}
// Time: O(V+E) — visit each node and edge once
// Space: O(V+E) — adjacency list + O(V) state + O(V) call stack
```

> **🎯 Key Insight:** Cycle detection in directed graphs uses 3 states (not 2). A "visited" boolean fails — it can't distinguish between "finished exploring" and "currently on the path." The gray state (in-progress) is what detects back edges → cycles.

---

## Section 19 — Shortest Path Algorithms

> **🧠 Mental Model: GPS Navigation**
>
> Dijkstra's algorithm is like a GPS that always expands to the nearest unvisited city. It's **greedy** — always process the closest known city next. This greedy choice works because weights are non-negative (you can't make a path shorter by taking a detour). Bellman-Ford handles negative weights by relaxing ALL edges repeatedly.

```
DIJKSTRA VISUALIZATION: find shortest from node 0
═══════════════════════════════════════════════════════════════
  Graph:    0 ——4—— 1
            |       |
            8      -3  ← Dijkstra fails with negative! Use Bellman-Ford
            |       |
            3 ——2—— 2

  With all positive weights:
  0——4——1, 0——8——3, 1——5——2, 3——2——2

  Init: dist=[0,∞,∞,∞], PQ=[(0,0)]  # (dist,node)
  Pop (0,0): update neighbors: dist[1]=4, dist[3]=8 → PQ=[(4,1),(8,3)]
  Pop (4,1): update neighbors: dist[2]=4+5=9 → PQ=[(8,3),(9,2)]
  Pop (8,3): update neighbors: dist[2]=min(9,8+2)=10→no update
  Pop (9,2): no neighbors to relax
  Final dist=[0,4,9,8] ✅
═══════════════════════════════════════════════════════════════
```

### Dijkstra's Algorithm

```csharp
public int[] Dijkstra(int[][] graph, int src, int V) {
    // STEP 1: Initialize distances to infinity; source node has distance 0
    int[] dist = new int[V];
    Array.Fill(dist, int.MaxValue / 2);  // WHY /2? Prevent overflow when adding edge weights
    dist[src] = 0;

    // STEP 2: Seed min-heap with the source node at distance 0
    var pq = new PriorityQueue<int, int>();  // element=node, priority=distance
    pq.Enqueue(src, 0);

    while (pq.Count > 0) {
        // STEP 3: Extract the node with the current smallest known distance
        int u = pq.Dequeue();  // node with minimum current distance

        // STEP 4: Relax all edges from u — update neighbor distances if shorter path found
        // "Relaxation" = check if going through u gives a shorter path to neighbor
        for (int v = 0; v < V; v++) {
            if (graph[u][v] != 0) {  // edge exists
                int newDist = dist[u] + graph[u][v];
                if (newDist < dist[v]) {  // found shorter path!
                    // STEP 5: Update distance and re-enqueue with improved priority
                    dist[v] = newDist;
                    pq.Enqueue(v, newDist);  // re-add with better distance
                }
            }
        }
    }
    return dist;
}
// Time: O((V+E) log V) with priority queue
// Space: O(V) for dist array + O(V) for priority queue
```

---

### 🔴 Practice Problem: Network Delay Time (LeetCode #743 — Medium)

**Problem:** Network of `n` nodes. Given travel times for directed edges, find time for all nodes to receive signal from node `k`.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: NETWORK DELAY TIME                          ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ BFS/DFS for each pair   │ O(V²+VE)  │ O(V+E)  ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 DIJKSTRA │ SSSP from source k      │ O(E log V)│ O(V+E)  ║
║  (OPTIMAL)   │ answer = max of dist[]  │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Dijkstra from source k: min-heap of (distance, node). Always relax the nearest unvisited node. Answer = max of all shortest distances (or -1 if any unreachable).

```csharp
public int NetworkDelayTime(int[][] times, int n, int k) {
    // STEP 1: Build adjacency list from edge list
    var graph = new Dictionary<int, List<(int to, int w)>>();
    foreach (int[] t in times) {
        if (!graph.ContainsKey(t[0])) graph[t[0]] = new List<(int, int)>();
        graph[t[0]].Add((t[1], t[2]));
    }

    // STEP 2: Run Dijkstra from source k — min-heap of (node, distance)
    var dist = new Dictionary<int, int>();
    var pq = new PriorityQueue<int, int>(); // (node, distance)
    pq.Enqueue(k, 0);

    while (pq.Count > 0) {
        // STEP 3: Extract nearest unfinalized node; skip if already finalized
        pq.TryDequeue(out int u, out int d);
        if (dist.ContainsKey(u)) continue;  // already finalized
        dist[u] = d;  // finalize shortest distance to u

        // STEP 4: Enqueue all unfinalized neighbors with updated distances
        if (graph.ContainsKey(u)) {
            foreach (var (v, w) in graph[u]) {
                if (!dist.ContainsKey(v))
                    pq.Enqueue(v, d + w);  // explore neighbor
            }
        }
    }

    // STEP 5: Verify all n nodes were reached; return max distance (last node to receive signal)
    if (dist.Count != n) return -1;
    return dist.Values.Max();
}
// Time: O(E log V), Space: O(V+E)
```

> **🎯 Key Insight:** "Time for ALL nodes to receive" = shortest path to ALL nodes = single-source shortest path. Then answer = max of all shortest paths (slowest path determines when ALL nodes have signal). This SSSP + max pattern is classic.

---

## Section 20 — Minimum Spanning Trees

> **🧠 Mental Model: Cheapest Way to Connect Cities**
>
> Given n cities and possible roads between them (each with a cost), find the cheapest set of roads that connects ALL cities. An MST connects all n vertices using exactly n-1 edges with minimum total weight and no cycles.

```
MST ALGORITHMS:
═══════════════════════════════════════════════════════════════
  KRUSKAL'S:  Sort edges by weight → add edge if it doesn't create cycle
              Uses Union-Find to detect cycles in O(α) ≈ O(1)
              Best for: sparse graphs (few edges)

  PRIM'S:     Start from any node → greedily add cheapest edge
              connecting current tree to new node
              Uses priority queue → O(E log V)
              Best for: dense graphs (many edges)
═══════════════════════════════════════════════════════════════

KRUSKAL'S VISUALIZATION:
  Nodes: 0,1,2,3  Edges by weight: (0-1,1),(0-2,3),(1-2,2),(1-3,4),(2-3,5)

  Sort: [(0-1,1),(1-2,2),(0-2,3),(1-3,4),(2-3,5)]

  Add (0-1,1): {0,1} not connected → ADD. MST=[0-1]. Cost=1
  Add (1-2,2): {1,2} not connected → ADD. MST=[0-1,1-2]. Cost=3
  Add (0-2,3): {0,2} already connected! → SKIP (cycle)
  Add (1-3,4): {1,3} not connected → ADD. MST=[0-1,1-2,1-3]. Cost=7
  Done! (V-1=3 edges added)
```

---

### 🔴 Practice Problem: Min Cost to Connect All Points (LeetCode #1584 — Medium)

**Problem:** Given array of points, return minimum cost to connect all points. Cost = Manhattan distance.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: CONNECT ALL POINTS                          ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Try all spanning trees  │ O(n^n)    │ O(n²)   ║
╠══════════════════════════════════════════════════════════════════╣
║  🟡 KRUSKAL  │ Sort all O(n²) edges,   │ O(n²logn) │ O(n²)   ║
║              │ Union-Find              │            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 PRIM'S   │ Priority queue, no      │ O(n²logn) │ O(n)    ║
║  (OPTIMAL)   │ need to pre-build edges │            │         ║
╚══════════════════════════════════════════════════════════════════╝
```

> **🔑 CORE IDEA:** Prim's MST: start from node 0, use a min-heap of (cost, node). Greedily pick cheapest edge to any unvisited node. No need to pre-enumerate all edges.

```csharp
public int MinCostConnectPoints(int[][] points) {
    int n = points.Length;
    // STEP 1: Initialize Prim's — minCost[i] = cheapest edge to add point i to MST
    int[] minCost = new int[n];
    Array.Fill(minCost, int.MaxValue);
    minCost[0] = 0;  // start from point 0, cost 0
    bool[] inMST = new bool[n];  // track which points are already in MST
    int totalCost = 0;

    for (int iter = 0; iter < n; iter++) {
        // STEP 2: Greedily pick the unvisited point with the cheapest MST-edge
        int u = -1;
        for (int i = 0; i < n; i++)
            if (!inMST[i] && (u == -1 || minCost[i] < minCost[u]))
                u = i;

        // STEP 3: Add chosen point to MST and accumulate its edge cost
        inMST[u] = true;    // add u to MST
        totalCost += minCost[u];  // add the edge cost

        // STEP 4: Update minCost for all non-MST points using newly added point u
        for (int v = 0; v < n; v++) {
            if (!inMST[v]) {
                // Manhattan distance between u and v
                int dist = Math.Abs(points[u][0] - points[v][0]) +
                           Math.Abs(points[u][1] - points[v][1]);
                minCost[v] = Math.Min(minCost[v], dist);  // update if cheaper
            }
        }
    }
    return totalCost;
}
// Time: O(n²) — n iterations, each O(n) scan; better than Kruskal for dense graphs
// Space: O(n) — minCost and inMST arrays
```

> **🎯 Key Insight:** Prim's algorithm is ideal here because the graph is complete (every pair of points has an edge). We don't need to pre-build all O(n²) edges — we can compute edge weights on-the-fly. Kruskal's would need to store all edges, using O(n²) space.

---

## Section 21 — Advanced Graphs (Topological Sort, Union-Find)

> **🧠 Mental Model: Union-Find = Partisan Groups / Topo Sort = Dependency Order**
>
> **Union-Find**: Like social groups that merge. Each group has a "leader" (root). Merging groups = connecting their leaders. Checking if two people are in the same group = checking if they have the same leader.
>
> **Topological Sort**: Like getting dressed — you must put on socks BEFORE shoes. Given dependency constraints, find a valid ordering of tasks.

```
UNION-FIND OPERATIONS:
═══════════════════════════════════════════════════════════════
  parent = [0, 1, 2, 3, 4]  (each node is its own parent initially)

  Union(0, 1):  parent[1] = 0  → groups: {0,1}, {2}, {3}, {4}
  Union(1, 2):  parent[2] = root(1) = 0  → groups: {0,1,2}, {3}, {4}
  Find(2): 2→parent[2]=0→parent[0]=0 (root) = 0

  WITH PATH COMPRESSION: during Find, make every node point directly to root
  Find(2): path 2→0, set parent[2]=0 (already is 0 in this case)

  RANK UNION: always attach smaller tree under larger tree root
  → keeps tree height O(log n) → Find is O(log n) → α(n) with both optimizations
═══════════════════════════════════════════════════════════════
```

### Union-Find (Disjoint Set Union)

```csharp
public class UnionFind {
    private int[] parent, rank;

    public UnionFind(int n) {
        // STEP 1: Initialize — every node is its own root (n separate components)
        parent = new int[n];
        rank = new int[n];
        for (int i = 0; i < n; i++) parent[i] = i;  // each node is its own root
    }

    // Find root with PATH COMPRESSION — O(α(n)) amortized ≈ O(1)
    public int Find(int x) {
        // STEP 1: Walk to root, and on the way back, point every node directly to root
        // WHY recursive? Path compression: on the way back up,
        // set every node's parent directly to root → flatten the tree
        if (parent[x] != x)
            parent[x] = Find(parent[x]);  // path compression: point directly to root
        return parent[x];
    }

    // Union by rank — O(α(n)) amortized
    public bool Union(int x, int y) {
        // STEP 1: Find roots; if same root, already connected
        int rx = Find(x), ry = Find(y);
        if (rx == ry) return false;  // already in same set

        // STEP 2: Attach smaller-rank tree under larger-rank tree
        // WHY rank-based union? Attach smaller tree under larger tree
        // to keep height logarithmic → prevents degenerate linear chains
        if (rank[rx] < rank[ry]) (rx, ry) = (ry, rx); // ensure rx has higher rank
        parent[ry] = rx;            // attach ry's tree under rx
        // STEP 3: Only increment rank when two equal-rank trees merge
        if (rank[rx] == rank[ry]) rank[rx]++;

        return true;  // successfully merged two different sets
    }

    public bool Connected(int x, int y) => Find(x) == Find(y);
}
```

---

### 🔴 Practice Problem: Redundant Connection (LeetCode #684 — Medium)

**Problem:** In an undirected graph that started as a tree, one extra edge was added. Find the redundant edge.

```
╔══════════════════════════════════════════════════════════════════╗
║  APPROACH EVOLUTION: REDUNDANT CONNECTION                         ║
╠══════════════════════════════════════════════════════════════════╣
║  🔴 BRUTE    │ Remove each edge, check │ O(E×(V+E))│ O(V+E)  ║
║              │ if graph still connected│            │         ║
╠══════════════════════════════════════════════════════════════════╣
║  🟢 UNION    │ Add edges one by one;   │ O(E×α(V)) │ O(V)    ║
║  FIND        │ first edge connecting   │ ≈O(E)     │         ║
║  (OPTIMAL)   │ already-connected nodes │            │         ║
╚══════════════════════════════════════════════════════════════════╝

KEY INSIGHT: Process edges in order. Before adding each edge, check if
             both endpoints are ALREADY connected (same component).
             If yes → this edge creates a cycle → it's REDUNDANT.
```

> **🔑 CORE IDEA:** Union-Find: process edges one by one. The first edge whose endpoints already have the same root (are already connected) is the redundant edge.

```csharp
public int[] FindRedundantConnection(int[][] edges) {
    // STEP 1: Initialize Union-Find with n+1 nodes (1-indexed)
    int n = edges.Length;
    var uf = new UnionFind(n + 1);  // +1 because nodes are 1-indexed

    foreach (int[] edge in edges) {
        int fromNode = edge[0], toNode = edge[1];  // WHY fromNode/toNode? Clearer than u/v for directed edge intent
        // STEP 2: Try to union endpoints; if they're already in the same component → redundant edge
        // WHY check before union? If fromNode and toNode are already connected,
        // adding this edge creates a cycle → it is the redundant (extra) edge
        if (!uf.Union(fromNode, toNode))
            return edge;  // this edge connects two already-connected nodes — it's the redundant one
    }

    return Array.Empty<int>(); // should never reach here per problem constraints
}
// Time: O(E × α(V)) ≈ O(E) — α is inverse Ackermann, essentially constant
// Space: O(V) — Union-Find arrays
```

> **🎯 Key Insight:** Union-Find is THE data structure for "are these two elements in the same group?" queries. It answers this in near-O(1) and is perfect for: detecting cycles in undirected graphs, Kruskal's MST, network connectivity problems, and any "merge groups" problem.

---

# PART 6 — SORTING ALGORITHMS

---

