---
title: 剑指 Offer 07. 重建二叉树
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '9344'
---
# 剑指 Offer 07. 重建二叉树

输入某二叉树的前序遍历和中序遍历的结果，请构建该二叉树并返回其根节点。

假设输入的前序遍历和中序遍历的结果中都不含重复的数字。

> [剑指 Offer 07. 重建二叉树 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/zhong-jian-er-cha-shu-lcof/)

<!-- more -->

## 递归实现

只要知道先序遍历、中序遍历、后序遍历的特点

- 先序遍历 ：[根,[左子树],[右子树]]
- 中序遍历：[[左子树],根,[右子树]]
- 后序遍历：[[左子树],[右子树],根]

只要给出中序遍历和先序（后序）遍历结果，在树中数字唯一的情况下是可以将二叉树进行还原的

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
    int[] preorder;
    Map<Integer,Integer> inorderMap;
    int size;

    public TreeNode buildTree(int[] preorder, int[] inorder) {
        this.preorder = preorder;
        this.size = preorder.length;
        this.inorderMap = new HashMap<>();
        for(int i=0;i<size;++i){
            inorderMap.put(inorder[i],i);
        }
        // 3 9 20 15 7
        // 9 3 15 20 7
        // 在先序遍历中，第一个是根节点，其后一个为左节点，
        // 在中序遍历中，根节点左边数字是左子树，右边是右子树
        return helper(0,0,size-1);
    }
    // [inorderLeft,inorderRight]区间，确保该子树的节点范围
    private TreeNode helper(int rootIndex,int inorderLeft,int inorderRight){
        if(inorderLeft > inorderRight) return null;
        TreeNode root = new TreeNode(preorder[rootIndex]);
        int leftChildIndex = rootIndex + 1;
        int inorderRoot = inorderMap.get(root.val);
        // 这个节点不在范围内，说明实际不存在
        // if(inorderRoot < inorderLeft || inorderRoot > inorderRight) return null;
        int leftTreeSize = inorderRoot - inorderLeft;
        int rightChildIndex = leftChildIndex + leftTreeSize;
        // 此处如果左子树大小为1，则inorderLeft == inorderRoot-1,右子树同理，
        // 但是如果左子树为空，则此时inorderRoot和inorderLeft重合，
        // 那么inorderRoot-1一定小于inorderLeft，因此就会直接返回
        root.left = helper(leftChildIndex,inorderLeft,inorderRoot-1);
        root.right = helper(rightChildIndex,inorderRoot+1,inorderRight);
        return root;
    }
}
```



