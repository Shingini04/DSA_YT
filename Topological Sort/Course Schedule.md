
## Mathematical Formulation of the Problem

We can model the $n$ courses as a set of vertices $V = \{1, 2, \dots, n\}$ and the $m$ prerequisites as a set of directed edges $E = \{(u, v) \mid \text{course } u \text{ must precede course } v\}$.

The problem requires us to find a valid **Topological Ordering** of the graph $G = (V, E)$. A topological ordering is a linear sequence of vertices such that for every directed edge $(u, v) \in E$, vertex $u$ appears before vertex $v$. Such an ordering is only mathematically possible if $G$ is a Directed Acyclic Graph (DAG).

## Intuitive Mental Model

Conceptually, imagine the graph as a physical structure made of interconnected blocks. You can only remove a block if nothing is resting on top of it (i.e., it has no incoming dependencies). Kahn's algorithm systematically "peels" away the independent layers of the graph. By removing the completely free blocks first and deleting their outgoing connections, new blocks become free to be removed in the next iteration.

## Algorithm and Code Breakdown

Your C++ code perfectly mirrors Kahn's algorithmic steps. Here is the step-by-step investigation of your implementation:

* **Zero-Based Normalization:** The graph inputs use 1-based indexing (`1` to $n$), but your code subtracts `1` to normalize the data for 0-based C++ vector operations, converting back only at the final output `ans[i] + 1`.
* **Adjacency List & Indegrees:** You construct the graph using `vector<vector<int>> adj(n)` while simultaneously building an `indeg[v]` array to track the number of incoming edges for each vertex.
* **Initialization (The Base Cases):** You scan the indegree array and push all vertices where `indeg[i] == 0` into a queue. These represent courses with zero prerequisites.
* **State Transition (Edge Relaxation):** While the queue is not empty, you pop a vertex $u$, add it to the topological sequence, and iterate through its neighbors. For each outgoing edge $(u, v)$, you decrement `indeg[v]`.
* **Queue Propagation:** If decrementing causes `indeg[v]` to reach 0, all of $v$'s prerequisites have been resolved, and $v$ is pushed into the queue.

## Formal Proof of Correctness & Cycle Detection

To rigorously prove this algorithm for an academic context, we must validate both its ordering and its failure state.

**Proof of Topological Property:** Let $v_i$ be the $i$-th vertex appended to the sequence vector. A vertex is only pushed to the queue (and subsequently appended) when its indegree reaches exactly 0. This guarantees that all parent vertices $u$ associated with edges $(u, v_i)$ have already been processed and appended to the sequence. Therefore, $u$ will strictly precede $v_i$ in the output.

**Proof of Cycle Detection:** A fundamental property of Kahn's Algorithm is its natural ability to detect cycles. If $G$ contains a directed cycle, the vertices forming the cycle will perpetually retain an indegree $\ge 1$. Consequently, they will never be pushed into the queue.

* Your code gracefully handles this with the condition `ans.size() != n`. If the final sequence length is less than $\vert{}V\vert{}$, it proves a cycle exists and correctly outputs `IMPOSSIBLE`.

**Complexity:** The time complexity is exactly $O(\vert{}V\vert{} + \vert{}E\vert{})$ because every vertex is pushed to the queue at most once, and every edge is traversed exactly once. The space complexity is also $O(\vert{}V\vert{} + \vert{}E\vert{})$ to store the adjacency list.

Algorithm: Kahn's Topological Sort
Input: A directed graph G = (V, E) where V is the set of n vertices and E is the set of directed edges.
Output: A topological sequence L of all vertices, or "IMPOSSIBLE" if G contains a cycle.

1:  Let indegree[1..n] be a new array initialized to 0
2:  Let L be an empty sequence that will contain the sorted elements
3:  Let Q be an empty queue

4:  // Step 1: Compute initial indegrees
5:  for each directed edge (u, v) in E do
6:      indegree[v] = indegree[v] + 1

7:  // Step 2: Initialize the queue with independent vertices
8:  for each vertex v in V do
9:      if indegree[v] == 0 then
10:         enqueue(Q, v)

11: // Step 3: Process the graph via BFS-like traversal
12: while Q is not empty do
13:     u = dequeue(Q)
14:     append u to L
15:     
16:     for each vertex v in G.Adj[u] do
17:         indegree[v] = indegree[v] - 1
18:         if indegree[v] == 0 then
19:             enqueue(Q, v)

20: // Step 4: Cycle detection validation
21: if length(L) == n then
22:     return L
23: else
24:     return "IMPOSSIBLE"
