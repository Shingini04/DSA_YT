

## Step 1: The Foundation - What is a DAG?

Before we sort, we must define the structure we are operating on: the **Directed Acyclic Graph (DAG)**.

* **Directed:** Edges have a strict one-way direction (you can go from $u \to v$, but not necessarily $v \to u$).
* **Acyclic:** There are no loops. If you leave a node, there is absolutely no path to return to it.

> **Real-world analogy:** Think of a university prerequisite tree. You must take Calculus I before Calculus II. The edges point from prerequisite to the next course. You cannot have a cycle (Course A requires B, and B requires A), or no one could ever graduate!

---

## Step 2: Defining Topological Sort

A **Topological Sort** is a linear ordering of the vertices of a DAG such that for every directed edge $u \to v$, vertex $u$ comes strictly *before* vertex $v$ in the ordering.

Notice in the image above: Once the nodes are laid out in a topological line, **all arrows point to the right**. If even one arrow pointed backward to the left, the sort would be invalid.

There are two primary ways to achieve this: a Breadth-First Search (BFS) approach and a Depth-First Search (DFS) approach.

---

## Step 3: Kahn's Algorithm (The BFS Approach)

Kahn's Algorithm is often the most intuitive for students because it mimics how we naturally solve prerequisite problems.

It relies on the concept of **indegree**: the number of incoming edges a node has.

**The Logic:**

1. Calculate the indegree for every vertex.
2. Find all vertices with an indegree of `0` (these have no prerequisites/dependencies) and place them in a Queue.
3. While the Queue is not empty:
* Pop a node $u$ from the front of the queue and append it to your final `top_sort` list.
* For every neighbor $v$ that $u$ points to, conceptually "remove" the edge $u \to v$ by subtracting `1` from $v$'s indegree.
* If $v$'s indegree drops to `0`, push $v$ into the Queue (its prerequisites are now fulfilled).



**Why it works:** You are systematically peeling off the "independent" nodes layer by layer.

---

## Step 4: The DFS Approach

The DFS approach is elegant and uses the recursion stack to naturally find the topological order.

**The Logic:**

1. Maintain a `visited` boolean array.
2. For each unvisited node, launch a DFS.
3. The DFS recursively visits all unvisited neighbors.
4. **The crucial step:** *Only after* a node has finished visiting all of its children (and their children), do you push it onto a stack (or append it to a list).
5. Once all nodes are processed, reverse the list (or pop from the stack).

**Why it works:** By definition of DFS post-order traversal, a node is added to the list only after all its dependencies downstream are fully resolved. Reversing this list gives you the topological order, ensuring parents appear before their children.

---

## Step 5: Cycle Detection (Handling the Impossible)

A topological sort is mathematically impossible if the graph contains a cycle. How do our algorithms handle this?

**Using Kahn's (BFS):**
If a graph has a cycle, the nodes within the cycle will never reach an indegree of `0`. Therefore, they will never enter the Queue.

* **The Check:** If the length of your final `top_sort` array does not equal the total number of vertices in the graph, a cycle exists.

**Using DFS:**
To detect a cycle in DFS, we change our `visited` array from simple booleans to three states (often called 3-color DFS):

* `0`: Unvisited
* `1`: Currently on the recursive call stack (Visiting)
* `2`: Fully processed (Visited)
* **The Check:** During your DFS, if you ever try to visit a neighbor that is currently marked as `1` (on the stack), you have found a back-edge. This means a cycle exists.

---

## Step 6: The Payoff - Dynamic Programming on DAGs

Why do competitive programmers and PhD researchers care so much about this? Because topological sorting unlocks **Dynamic Programming (DP) on graphs**.

In DP, you must compute the answer for a subproblem *before* it is needed by a larger problem. In an array, you just iterate left-to-right. But in a complex graph, how do you know what order to process the states?

**Topological Sort gives you that exact order.**

### Example: Longest Flight Route

Suppose you want to find the longest path ending at node $v$. Let $dp[v]$ denote this length.

The recurrence relation is:


$$dp[v] = \max_{(u \to v)} (dp[u] + 1)$$

If we process the nodes in their **Topological Order**, we are mathematically guaranteed that by the time we calculate $dp[v]$, all possible parent nodes $u$ that point to $v$ have **already been calculated**.
