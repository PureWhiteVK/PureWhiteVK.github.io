---
title: 剑指 Offer 28. 对称的二叉树
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '382'
---
# 剑指 Offer 28. 对称的二叉树

请实现一个函数，用来判断一棵二叉树是不是对称的。如果一棵二叉树和它的镜像一样，那么它是对称的。

> [剑指 Offer 28. 对称的二叉树 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/dui-cheng-de-er-cha-shu-lcof/)

<!-- more -->

## 模拟

看到这题，首先想到的是求出这颗树的镜像二叉树，然后判断它和它的镜像是否一样即可（主要是因为前一题就是让你求镜像二叉树23333 [剑指 Offer 27. 二叉树的镜像 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/er-cha-shu-de-jing-xiang-lcof/)）

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
    public boolean isSymmetric(TreeNode root) {
        // 题目上说的很清楚了，如果一颗二叉树和它的镜像一样，那么它是对称的
        // 那么可以先找出root的镜像数，然后进行遍历，判断每个节点是否相同
        return isSame(root,mirrorTree(root));
    }

    private boolean isSame(TreeNode A,TreeNode B){
        if(A == null && B == null) return true;
        if((A==null && B!= null) || (A!=null && B==null)) return false;
        return A.val == B.val && isSame(A.left,B.left) && isSame(A.right,B.right);
    }

    private TreeNode mirrorTree(TreeNode root){
        if(root == null) return null;
        TreeNode newRoot = new TreeNode(root.val);
        newRoot.left = mirrorTree(root.right);
        newRoot.right = mirrorTree(root.left);
        return newRoot;
    }
}
```

## 递归

以下面这的树为例，可以发现，从根节点开始，需要判断其两棵子树是否对称（左子树的右子树和右子树的左子树是否相同，左子树的左子树和右子树的右子树是够相同）

```NULL
                  1        <- root
                 / \
root.left->     2   2      <- root.right
               / \ / \
              3  4 4  3
```

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
    public boolean isSymmetric(TreeNode root) {
        if(root == null) return true;
        return check(root.left,root.right);
    }

    public boolean check(TreeNode A,TreeNode B){
        if((A==null&&B!=null) || (A!=null && B==null)) return false;
        if(A==null && B==null) return true;
        return A.val == B.val && check(A.left,B.right) && check(A.right,B.left);
    }
}
```

## 层序遍历

从上面的样例可以看出，如果对这棵树进行层序遍历，其每一层的结构都是对称，那么只需要使用迭代方式生成这棵树每一层的结点情况，然后使用双指针进行判断即可

```
    1
   / \
  2   2
   \   \
   3    3
```

可以看到上面这个案例，其层序遍历结果实际上也是对称的，但是并不满足条件，这是由于我们在按层遍历过程中忽略了NULL结点，如果在遍历过程中考虑到了空节点，这样的层序遍历结果可以唯一对应一棵树

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
    public boolean isSymmetric(TreeNode root) {
        Queue<TreeNode> queue = new LinkedList<>();
        queue.offer(root);
        while(queue.size() != 0){
            int currSize = queue.size();
            List<TreeNode> list = new ArrayList<>(); 
            while(currSize > 0){
                TreeNode curr = queue.poll();
                list.add(curr);
                if(curr != null){
                  	// 如果该节点的左孩子和右孩子是空节点，同样也将其加入队列中，这样可以保持层序遍历结果正确性
                    queue.offer(curr.left);
                    queue.offer(curr.right);
                }
                --currSize;
            }
            // 当前层遍历完成，判断是否对称
            if(!check(list)) return false;
        }
        return true;
    }

    private boolean check(List<TreeNode> list){
        int l = 0;
        int r = list.size()-1;
        while(l<r){
            TreeNode left = list.get(l);
            TreeNode right = list.get(r);
            ++l;
            --r;
            if(left == null && right == null) continue;
            if(
              (left == null && right != null) || 
              (left != null && right == null) || 
              left.val != right.val
            ) return false;
        }
        return true;
    }
}
```

