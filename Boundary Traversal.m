### Concept: Divide & Conquer the Perimeter

Boundary traversal walks the outer perimeter of a tree **anti-clockwise**:

$$\text{Perimeter} = \text{Root} \ \cup \ \text{Left Boundary (top-down)} \ \cup \ \text{All Leaves (left-to-right)} \ \cup \ \text{Right Boundary (bottom-up)}$$

```
          [ 1 ]          <-- Root
         /     \
       [2]     [3]       <-- Left Boundary [2], Right Boundary [3]
       / \     / \
     [4] [5] [6] [7]     <-- Leaves [4, 5, 6, 7]

```

**Anti-clockwise path:** `1` $\rightarrow$ `2` $\rightarrow$ `4, 5, 6, 7` $\rightarrow$ `3`

#### Invariant: Mutual Exclusion of Leaves

The primary source of bugs in this problem is **duplicate nodes**. If the left boundary includes the leftmost leaf, and the leaf routine also collects it, that node appears twice.

* **Rule:** The Left and Right boundary routines handle **strictly non-leaf nodes**.
* The Leaf routine handles **all leaves**.

---

### Step 1: The Leaf Detector

Every subroutine needs to know whether a node is a leaf to prevent duplicate insertions:

```cpp
bool isLeaf(TreeNode* node) {
    return (node != nullptr) && (node->left == nullptr) && (node->right == nullptr);
}

```

---

### Step 2: The Left Boundary (Top-Down, Non-Leaves)

We start at `root->left`. We prioritize going left; if left does not exist, we fall back to right. We stop immediately before any leaf node:

```cpp
void addLeftBoundary(TreeNode* root, vector<int>& res) {
    TreeNode* curr = root->left;
    while (curr) {
        // Only include if it is NOT a leaf
        if (!isLeaf(curr)) {
            res.push_back(curr->data);
        }
        // Prefer left; if absent, step right
        if (curr->left) {
            curr = curr->left;
        } else {
            curr = curr->right;
        }
    }
}

```

---

### Step 3: All Leaves (Left-to-Right via Preorder DFS)

Standard DFS visits the leftmost leaves first and rightmost leaves last. When a leaf is encountered, add it to `res`:

```cpp
void addLeaves(TreeNode* node, vector<int>& res) {
    if (!node) return;

    if (isLeaf(node)) {
        res.push_back(node->data);
        return;
    }

    addLeaves(node->left, res);
    addLeaves(node->right, res);
}

```

---

### Step 4: The Right Boundary (Bottom-Up, Non-Leaves)

We start at `root->right`. We prioritize going right; if right does not exist, we fall back to left.

Because we need the perimeter in **anti-clockwise** order, we collect these nodes in a temporary stack (or vector) and reverse them, or push them on the return phase of recursion.

```cpp
void addRightBoundary(TreeNode* root, vector<int>& res) {
    TreeNode* curr = root->right;
    vector<int> temp;

    while (curr) {
        if (!isLeaf(curr)) {
            temp.push_back(curr->data);
        }
        // Prefer right; if absent, step left
        if (curr->right) {
            curr = curr->right;
        } else {
            curr = curr->left;
        }
    }

    // Reverse to achieve bottom-up order
    for (int i = (int)temp.size() - 1; i >= 0; --i) {
        res.push_back(temp[i]);
    }
}

```

---

### Step 5: Assembly

Combine all pieces into the main method:

```cpp
class Solution {
public:
    bool isLeaf(TreeNode* node) {
        return node && !node->left && !node->right;
    }

    void addLeftBoundary(TreeNode* root, vector<int>& res) {
        TreeNode* curr = root->left;
        while (curr) {
            if (!isLeaf(curr)) res.push_back(curr->data);
            curr = curr->left ? curr->left : curr->right;
        }
    }

    void addLeaves(TreeNode* node, vector<int>& res) {
        if (!node) return;
        if (isLeaf(node)) {
            res.push_back(node->data);
            return;
        }
        addLeaves(node->left, res);
        addLeaves(node->right, res);
    }

    void addRightBoundary(TreeNode* root, vector<int>& res) {
        TreeNode* curr = root->right;
        vector<int> temp;
        while (curr) {
            if (!isLeaf(curr)) temp.push_back(curr->data);
            curr = curr->right ? curr->right : curr->left;
        }
        for (int i = (int)temp.size() - 1; i >= 0; --i) {
            res.push_back(temp[i]);
        }
    }

    vector<int> boundary(TreeNode* root) {
        if (!root) return {};

        vector<int> res;

        // 1. Root node (only if it's not a single-node tree to avoid duplicate)
        if (!isLeaf(root)) {
            res.push_back(root->data);
        }

        // 2. Left boundary (top-down)
        addLeftBoundary(root, res);

        // 3. Leaves (left-to-right)
        addLeaves(root, res);

        // 4. Right boundary (bottom-up)
        addRightBoundary(root, res);

        return res;
    }
};

```

---

### Quiz Solution Walkthrough

Given the input from your prompt:
`root = [5, 1, 2, 8, null, 4, 5, null, 6]`

Tree Structure:

```
           5
         /   \
        1     2
       /     / \
      8     4   5
       \
        6

```

1. **Root (non-leaf):** `[5]`
2. **Left Boundary (top-down, non-leaves):**
* Start at child `1`: not a leaf $\rightarrow$ `[1]`
* Go to `1->left` which is `8`: has a child `6`, so not a leaf $\rightarrow$ `[8]`
* Go to `8->right` which is `6`: it is a leaf, stop.
* Collected so far: `[5, 1, 8]`


3. **Leaves (left-to-right):**
* In left subtree: `6`
* In right subtree: `4`, `5`
* Collected leaves: `[6, 4, 5]`


4. **Right Boundary (bottom-up, non-leaves):**
* Start at child `2`: not a leaf $\rightarrow$ buffer `[2]`
* Go to `2->right` which is `5` (leaf) $\rightarrow$ stop.
* Reversed buffer: `[2]`



**Concatenation:**
`[5, 1, 8]` + `[6, 4, 5]` + `[2]` = **`[5, 1, 8, 6, 4, 5, 2]`**

**Correct option:** `[5, 1, 8, 6, 4, 5, 2]`

---

### Complexity Analysis

* **Time Complexity:** $\mathcal{O}(N)$
* Left boundary traversal takes $\mathcal{O}(H)$ time, where $H$ is the height of the tree.
* Right boundary traversal takes $\mathcal{O}(H)$ time.
* Leaf collection visits every node via DFS, taking $\mathcal{O}(N)$ time.
* Total time = $\mathcal{O}(H) + \mathcal{O}(N) + \mathcal{O}(H) = \mathcal{O}(N)$.


* **Space Complexity:** $\mathcal{O}(H)$ auxiliary call stack space during recursive DFS leaf collection ($\mathcal{O}(N)$ in the worst-case of a degenerate skewed tree).
