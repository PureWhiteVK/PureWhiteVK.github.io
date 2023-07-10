---
title: 剑指 Offer 68 - I. 二叉搜索树的最近公共祖先
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 9bbf
---
# 剑指 Offer 68 - I. 二叉搜索树的最近公共祖先

给定一个二叉搜索树, 找到该树中两个指定节点的最近公共祖先。

百度百科中最近公共祖先的定义为：“对于有根树 T 的两个结点 p、q，最近公共祖先表示为一个结点 x，满足 x 是 p、q 的祖先且 x 的深度尽可能大（一个节点也可以是它自己的祖先）。”

> 链接：https://leetcode-cn.com/problems/er-cha-sou-suo-shu-de-zui-jin-gong-gong-zu-xian-lcof

<!-- more -->

## 递归（利用二叉搜索树的性质）

由于二叉搜索树的有序性质（一定存在 左孩子 < 根 < 右节点），因此只需要在遍历时进行判断即可

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
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if(root == null) return null;
      	// 当当前节点的值比p和q都大，说明p和q一定都在root的左子树中，下一个需要判断root.left
        if(root.val > p.val && root.val > q.val) return lowestCommonAncestor(root.left,p,q);
      	// root.right同理
        if(root.val < p.val && root.val < q.val) return lowestCommonAncestor(root.right,p,q);
        return root;
    }
}
```



## 遍历

可以分别找出从根节点到p和q的路径，然后找出二者最后一个重合的节点就是最近公共祖先，这个思路也同样适用于二叉树

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
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        Deque<TreeNode> path1 = new LinkedList<>(),path2 = new LinkedList<>();
        getPath(root,p,path1);
        getPath(root,q,path2);
        // printPath(path1);
        // printPath(path2);
        TreeNode lastCommonNode = root;
        while(!path1.isEmpty() && !path2.isEmpty() && path1.peekFirst() == path2.peekFirst()){
            lastCommonNode = path1.peekFirst();
            path1.pollFirst();
            path2.pollFirst();
        }
        return lastCommonNode;
    }

    private void printPath(Deque<TreeNode> path){
        for(TreeNode t:path){
            System.out.print(t.val+" ");
        }
        System.out.println();
    }

    private boolean getPath(TreeNode root,TreeNode p,Deque<TreeNode> path){
        if(root == null) return false;
        if(root == p || getPath(root.left,p,path) || getPath(root.right,p,path)) {
            path.addFirst(root);
            return true;
        }
        return false;
    }
}
```

