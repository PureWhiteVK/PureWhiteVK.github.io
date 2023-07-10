---
title: 剑指 Offer 63. 股票的最大利润
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: e776
---
# 剑指 Offer 63. 股票的最大利润

假设把某股票的价格按照时间先后顺序存储在数组中，请问买卖该股票一次可能获得的最大利润是多少？

> [剑指 Offer 63. 股票的最大利润 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/gu-piao-de-zui-da-li-run-lcof/)

<!-- more -->

## 动态规划

使用dp[i]代表第i天可以获得的最大利润，dp[0] = 0，那么可以得到状态转移方程
$$
dp[i] = max(dp[i-1],prices[i]-min(prices[0:i-1]))
$$
如果直接使用这个状态转移方程去编写代码，每次获得min(prices[0:i-1])的时间复杂度为o(i)，整体时间复杂度为o(n^2)，一定会超时，需要进行优化，实际上可以在循环的时候不断更新当前的最小值，那么状态转移方程可以优化成下列形式
$$
dp[i] = max(dp[i-1],prices[i]-min\_price)
$$
又由于dp[i]仅和dp[i-1]有关，可以将其优化成一个数，然后不断更新其值
$$
dp = max(dp,prices[i]-min\_price)
$$
最终代码

```java
class Solution {
    public int maxProfit(int[] prices) {
        int profit = 0;
        int price = Integer.MAX_VALUE;
        for(int p:prices){
            price = Math.min(price,p);
            profit = Math.max(p-price,profit);
        }
        return profit;
    }
}
```

