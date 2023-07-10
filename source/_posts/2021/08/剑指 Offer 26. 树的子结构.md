---
title: 剑指 Offer 26. 树的子结构
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 73ea
---
# 剑指 Offer 26. 树的子结构

输入两棵二叉树A和B，判断B是不是A的子结构。(约定空树不是任意一个树的子结构)

B是A的子结构， 即 A中有出现和B相同的结构和节点值。

> [剑指 Offer 26. 树的子结构 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/shu-de-zi-jie-gou-lcof/)

<!-- more -->

## 递归

由于树是递归定义的结构，因此通常使用递归来求解（不断划分子问题，最终求解）

编写递归函数有两个要点

- 子问题
- 终止条件

此处要求A中出现和B相同的结构和节点值，注意，这里并不是要求B是A的一颗子树（区别在于有些节点上B为空，但是A对应该节点可以不为空），只需要B上出现的所有节点值在A上出现且结构相同即可

```java
/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     int val;
 *     TreeNode left;
 *     TreeNode right;
 *     TreeNode(int x) { val = x; }
 * }
 */
class Solution {
    public boolean isSubStructure(TreeNode A, TreeNode B) {
        // 空树不是任意一个树的子结构
        if(A == null || B == null) return false;
        // 对A进行遍历，对于A的每一个节点，都有可能和B具有相同结构
        return isSameStructure(A,B) || isSubStructure(A.left,B) || isSubStructure(A.right,B);
    }

    private boolean isSameStructure(TreeNode A,TreeNode B){
        // 但是不知道从哪个起点开始
        // 如果B是A的子结构，说明A的某棵子树一定会和B重合，实际上只需要A上包含B上所有的结构即可，
        // 有可能出现A不为空，但是B为空的，这种情况实际上也可以满足相同条件
        if(A == null && B != null) return false;
        if(B == null) return true;
        // 如果两个值相同，
        return A.val == B.val && isSameStructure(A.left,B.left) && isSameStructure(A.right,B.right);
    }
}
```

