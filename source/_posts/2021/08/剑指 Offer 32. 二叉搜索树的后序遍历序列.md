---
title: 剑指 Offer 32. 二叉搜索树的后序遍历序列
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 495a
---
# 剑指 Offer 32. 二叉搜索树的后序遍历序列

输入一个整数数组，判断该数组是不是某二叉搜索树的后序遍历结果。如果是则返回 `true`，否则返回 `false`。假设输入的数组的任意两个数字都互不相同。

<!-- more -->

## 排序+递归（还原二叉树）

由于题目明确说明是二叉搜索树，而二叉搜索树的中序遍历结果一定是有序的，且题目明说不包含重复数组，摆明了让你还原二叉树，因此可以根据后序遍历和对后序遍历序列排序后的中序遍历结果还原出这颗二叉树，同时在还原过程中对二叉树进行检查

满足，左孩子 < 根 < 右孩子

而二叉树的还原在 **剑指 Offer 07. 重建二叉树** 中有具体介绍，这里不过多赘述

```java
class Solution {
    Map<Integer,Integer> indexMap;
    int[] inorder;
    int[] postorder;
    int length;
    public boolean verifyPostorder(int[] postorder) {
        if(postorder.length == 0) return true;
        // 二叉搜索树的后序遍历结果
        // [[左子树],[右子树],根]
        // 最后一个值是根节点，然后倒数第二个是无法确定的
        // 对于一个二叉搜索树而言，其一定满足左孩子<根<右孩子
        // 二叉搜索树的中序遍历结果是有序的，那么可以对postorder进行排序，获得中序遍历结果
        // 然后就可以开始判断了
        this.indexMap = new HashMap<>();
        this.postorder = postorder;
        this.length = postorder.length;
        this.inorder = Arrays.copyOf(postorder,this.length);
        Arrays.sort(this.inorder);
        for(int i=0;i<this.length;++i){
            indexMap.put(this.inorder[i],i);
        }
        return check(this.length-1,0,this.length-1,true,postorder[this.length-1]+1);
        // 可以根据inorder和postorder还原二叉树，然后检查其左节点和右节点是否正确
    }

    private boolean check(int index,int left,int right,boolean isLeftChild,int parentVal){
        // 空节点直接返回true
        if(left > right) return true;
        // 拿到根节点值对应的中序遍历下标
        int rootVal = postorder[index];
      	// 检查是否满足二叉搜索树的条件
        if((isLeftChild && rootVal > parentVal) || (!isLeftChild && rootVal < parentVal)) return false;
        int rightChildIndex = index - 1;
        int inorderIndex = indexMap.get(rootVal);
        // 之后可以计算出左子树大小和右子树大小
        int leftChildIndex = rightChildIndex - right + inorderIndex;
        return check(leftChildIndex,left,inorderIndex-1,true,rootVal) &&
               check(rightChildIndex,inorderIndex+1,right,false,rootVal); 
    }
}
```

这个解法并不是最优解，还有其他解法

## 单调栈

## 递归

