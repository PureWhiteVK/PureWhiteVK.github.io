---
title: 剑指 Offer II 003. 前n个数字二进制中1的个数
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '3600'
date: 2021-10-30
---
# 剑指 Offer II 003. 前n个数字二进制中1的个数

给定一个非负整数 `n` ，请计算 `0` 到 `n` 之间的每个数字的二进制表示中 1 的个数，并输出一个数组。

> [剑指 Offer II 003. 前 n 个数字二进制中 1 的个数 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/w3tCBm/)

<!-- more -->

## 动态规划

使用dp[i]表示数字i对应二进制中1的个数，可以很轻松的得出状态转移方程
$$
dp[i] = dp[i>>1] + (i\&1)
$$
原理很容易理解，对于二进制 5，若已知 5>>1 即 0b10 对应的1的个数为1，那么只需要判断5的最后一位是否是1即可，使用 i&1可以轻松判断

```java
class Solution {
    public int[] countBits(int n) {
        // dp[i] = dp[i>>1] + (i&1);
        int[] dp = new int[n+1];
        for(int i=1;i<=n;++i){
            dp[i] = dp[i>>1] + (i&1);
        }
        return dp;
    }
}
```

