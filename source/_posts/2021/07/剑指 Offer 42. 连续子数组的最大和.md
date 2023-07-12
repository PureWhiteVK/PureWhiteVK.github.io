---
title: 剑指 Offer 42. 连续子数组的最大和
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: a314
date: 2021-07-17
---
# 剑指 Offer 42. 连续子数组的最大和

输入一个整型数组，数组中的一个或连续多个整数组成一个子数组。求所有子数组的和的最大值。

要求时间复杂度为O(n)。

> 链接：https://leetcode-cn.com/problems/lian-xu-zi-shu-zu-de-zui-da-he-lcof/

<!-- more -->

## 暴力解法（超时）

首先考虑暴力吧，自数组就是数组一个子区间内所有数组的和，这样只需要遍历所有的子数组的和，求其最大即可，首先需要计算前缀和

```java
class Solution {
    public int maxSubArray(int[] nums) {
        int n = nums.length;
        int[] sums = new int[n];
        sums[0] = nums[0];
        for(int i=1;i<n;++i){
            sums[i] = nums[i] + sums[i-1];
        }
        // 由于arr.length是10^5，如果使用暴力应该是会超时的
        int maxSum = sums[0];
        for(int i=0;i<n;++i){
            maxSum = Math.max(maxSum,sums[i]);
            // j一定是大于i的哈
            for(int j=i+1;j<n;++j){
                maxSum = Math.max(maxSum,sums[j]-sums[i]);
            }
        }
        return maxSum;
    }
}
```

## 动态规划

考虑动态规划的三个满足条件：

1. 重叠子问题
2. 最优子结构
3. 无后效性

观察这个问题

所有的子序列和都满足
$$
sums[i,j] = sums[i,j-1] + nums[j]
$$
本题目标是求解最大子序列和，，用`dp[i,j]`代表最大子序列和，则一定有
$$
dp[i,j] = max(dp[i,j-1]+nums[j],nums[j])
$$
考虑数组[-2,1,-3,4,-1,2,1,-5,4]

首先考虑维优化空间的时候，状态存储为

`int[][] dp = new int[n][n]`

`dp[0][0] = nums[0]`

之后不断遍历，填入dp可得

| 0    | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| -2   | 1    | -2   | 4    | 3    | 5    | 6    | 1    | 5    |

本来需要o(n^2)的空间，但是由于dp[i,j]仅与其前一个dp[i,j-1]有关，因此可以将其降维成o(1)，只使用一个值pre保存dp[i,j-1]的值，并在遍历的过程中将新的dp[i,j]更新至dp[i,j-1]上即可

```java
class Solution {
    public int maxSubArray(int[] nums) {
        int res = nums[0];
        int dpIJ = 0;
        for(int i : nums){
            dpIJ = Math.max(dpIJ+i,i);
            res = Math.max(dpIJ,res);
        }
        return res;
    }
}
```

