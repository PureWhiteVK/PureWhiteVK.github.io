---
title: 剑指 Offer 04. 二维数组中的查找
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: adae
date: 2021-07-27
---
# 剑指 Offer 04. 二维数组中的查找

在一个 n * m 的二维数组中，每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个高效的函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。

> 链接：https://leetcode-cn.com/problems/er-wei-shu-zu-zhong-de-cha-zhao-lcof

<!-- more -->

## 暴力

没什么好说的，就嗯搜呗，遍历

```java
class Solution {
    public boolean findNumberIn2DArray(int[][] matrix, int target) {
        int n = matrix.length;
      	if(n == 0) return false;
      	int m = matrix[0].length;
      	for(int i=0;i<n;++i){
          for(int j=0;j<m;++j){
            if(matrix[i][j] == target){
              return true;
            }
          }
        }
      	return false;
    }
}
```

## 二分查找

```java
class Solution {
    public boolean findNumberIn2DArray(int[][] matrix, int target) {
        // 每一行从左到右都是递增，每列从上至下递增
        // o(nlogn)吧
        // 直接每行做一次二分查找
        boolean isIn = false;
        int n = matrix.length;
        for(int i=0;i<n;++i){
            isIn = isIn || binarySearch(matrix[i],target);
        }
        return isIn;
    }

    private boolean binarySearch(int[] nums,int target){
        if(nums.length == 0 ||target < nums[0] || target > nums[nums.length-1]) return false;
        int l = 0,r=nums.length;
        while(l<r){
            int mid = (l+r) >> 1;
            if(nums[mid] >= target){
                r = mid;
            }else{
                l = mid + 1;
            }
        }
        return nums[l] == target;
    }
}
```

时间复杂度o(m*logn)

## 暴力优化

由于matrix从左至右有序，从上至下有序，可以从matrix的右上角开始搜索，当前值小于target值时，就只能向下走，因为当前值左边的都是小于target值的，当前值大于target值时，就只能向左走，因为当前值下方的都是大于target值的【实在是太巧妙了】

```java
class Solution {
    public boolean findNumberIn2DArray(int[][] matrix, int target) {
        int n = matrix.length;
      	if(n == 0) return false;
      	int m = matrix[0].length;
      	int startX = 0,startY = m - 1;
      	while(startX < n && startY > -1){
            if(matrix[startX][startY] == target) return true;
            else if(matrix[startX][startY] > target) --startY;
            else if(matrix[startX][startY] < target) ++startX;
        }
      	return false;
    }
}
```

时间复杂度o(m+n)