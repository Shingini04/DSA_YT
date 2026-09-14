Here is how to build Breadth-First Search (BFS) and adapt it to Zigzag traversal step by step, progressing from core state management to optimization.

---

### Step 1: The Core BFS Engine

Standard BFS uses a First-In, First-Out (**Queue**) discipline to explore a graph or tree layer by layer.

```cpp
vector<int> standardBFS(TreeNode* root) {
    if (!root) return {};

    vector<int> order;
    queue<TreeNode*> q;
    q.push(root);

    while (!q.empty()) {
        TreeNode* curr = q.front();
        q.pop();

        order.push_back(curr->data);

        if (curr->left)  q.push(curr->left);
        if (curr->right) q.push(curr->right);
    }
    return order;
}

```

* **Invariant:** Nodes enter the queue strictly ordered by depth $d$, and then by horizontal position from left to right.
* **Limitation:** This flattens the tree into a 1D sequence without preserving where one level ends and the next begins.

---

### Step 2: Level-by-Level Chunking

To group nodes into individual levels (a 2D matrix), freeze the queue size before entering the level's processing loop.

```cpp
vector<vector<int>> levelOrder(TreeNode* root) {
    if (!root) return {};

    vector<vector<int>> ans;
    queue<TreeNode*> q;
    q.push(root);

    while (!q.empty()) {
        int levelSize = q.size(); // Freeze current frontier size
        vector<int> currentLevel;

        for (int i = 0; i < levelSize; ++i) {
            TreeNode* curr = q.front();
            q.pop();

            currentLevel.push_back(curr->data);

            if (curr->left)  q.push(curr->left);
            if (curr->right) q.push(curr->right);
        }
        ans.push_back(currentLevel);
    }
    return ans;
}

```

* **Frontier Isolation:** At line `int levelSize = q.size();`, the queue contains **only** nodes belonging to depth $k$. Any children added during the loop belong to depth $k+1$ and are not processed until the next `while` cycle.

---

### Step 3: The Zigzag Modification (Naive Approach)

The simplest conceptual jump to Zigzag is adding a direction toggle and reversing alternate levels.

```cpp
vector<vector<int>> zigzagNaive(TreeNode* root) {
    if (!root) return {};

    vector<vector<int>> ans;
    queue<TreeNode*> q;
    q.push(root);
    bool leftToRight = true;

    while (!q.empty()) {
        int levelSize = q.size();
        vector<int> currentLevel;

        for (int i = 0; i < levelSize; ++i) {
            TreeNode* curr = q.front();
            q.pop();
            currentLevel.push_back(curr->data);

            if (curr->left)  q.push(curr->left);
            if (curr->right) q.push(curr->right);
        }

        if (!leftToRight) {
            reverse(currentLevel.begin(), currentLevel.end()); // Extra work
        }

        ans.push_back(currentLevel);
        leftToRight = !leftToRight; // Invert direction for next layer
    }
    return ans;
}

```

* **Complexity Bottleneck:** While still technically $O(N)$ overall, calling `std::reverse` introduces an unnecessary second pass over the elements of odd-indexed rows.

---

### Step 4: Optimal $O(N)$ In-Place Indexing

Instead of post-reversing, preallocate a fixed-size buffer of length $L = \text{levelSize}$ and place elements directly into their target positions.

```cpp
vector<vector<int>> zigzagOptimal(TreeNode* root) {
    if (!root) return {};

    vector<vector<int>> ans;
    queue<TreeNode*> q;
    q.push(root);
    bool leftToRight = true;

    while (!q.empty()) {
        int levelSize = q.size();
        // Allocate exact memory upfront
        vector<int> row(levelSize);

        for (int i = 0; i < levelSize; ++i) {
            TreeNode* curr = q.front();
            q.pop();

            // Direct index mapping:
            // Left-to-Right: i
            // Right-to-Left: (levelSize - 1) - i
            int targetIdx = leftToRight ? i : (levelSize - 1 - i);
            row[targetIdx] = curr->data;

            if (curr->left)  q.push(curr->left);
            if (curr->right) q.push(curr->right);
        }

        ans.push_back(std::move(row)); // Move semantics: zero-copy transfer
        leftToRight = !leftToRight;
    }
    return ans;
}

```

---

### Theoretical Takeaways for Teaching

* **Queue Invariant Preserved:** The BFS queue order is never altered. Tree exploration remains strictly canonical (left-to-right). Only the projection into the output array alternates.
* **Space Complexity:** $O(W)$, where $W$ is the maximum width of the binary tree (at most $\lceil N/2 \rceil$ nodes at the leaves of a balanced tree).
* **Time Complexity:** Strictly $O(N)$, where each node is visited once and written to memory exactly once.
