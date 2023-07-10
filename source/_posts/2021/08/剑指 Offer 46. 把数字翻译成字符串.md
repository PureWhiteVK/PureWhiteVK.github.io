---
title: 剑指 Offer 46. 把数字翻译成字符串
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 11c0
---
# 剑指 Offer 46. 把数字翻译成字符串

给定一个数字，我们按照如下规则把它翻译为字符串：0 翻译成 “a” ，1 翻译成 “b”，……，11 翻译成 “l”，……，25 翻译成 “z”。一个数字可能有多个翻译。请编程实现一个函数，用来计算一个数字有多少种不同的翻译方法。

> 链接：https://leetcode-cn.com/problems/ba-shu-zi-fan-yi-cheng-zi-fu-chuan-lcof

<!-- more -->

## 动态规划

统计数字翻译方法，典型的动态规划，首先可以将数字转换成字符串形式，之后按字符串序列来进行求解

使用dp[i]表示从0～i这段序列所有的翻译方式，dp[0] = 1，状态更新方程

value = (nums[i-1]-'0') * 10 + nums[i]-'0'

dp [i] = dp[i-1] + dp[i-2] if 10 < value < 26

dp[i] = dp[i-1]

只有两种可能，第i-1个和第i个可以代表一个字母，这算一种翻译方式，此时当将i-1和i看成一个整体时，翻译方法总数为dp[i-2]，当将i单独看成一个字母时，翻译总方法数为dp[i-1]，因此可得上述递推公式

根据递推公式可以写出代码

```java
class Solution {
    public int translateNum(int num) {
        char[] nums = String.valueOf(num).toCharArray();
        int length = nums.length;
        int[] dp = new int[length];
        // dp[i][j]表示数字串在[0,i]段具有翻译方式
        dp[0] = 1;
        for(int i=1;i<length;++i){
            // 判断 nums[i-1] nums[i] 是否可以组合成一个
            // 注意 06 只能分开算，不能合并算
            dp[i] = dp[i-1];
            if(nums[i-1] == '0'){
                continue;
            }
            int value = (nums[i-1]-'0') * 10 + nums[i]-'0';
            if(value < 26){
                if(i>2){
                    dp[i] += dp[i-2];
                }else{
                    ++dp[i];
                }
                
            }
        }
        return dp[length-1];
    }
}
```

从递推公式上可以看到，实际上dp[i]仅取决于dp[i-1]和dp[i-2]，那么实际上只需要使用三个数p，q，r记录三个值，并在遍历过程中不断更新即可，同时我们从后向前读取，使用取模操作，可以直接读取数字值，不需要转换成字符串来处理，这样可以将空间复杂度降低为o(1)

优化代码

```java
class Solution {
    public int translateNum(int num) {
        // 实际上dp[i]仅和dp[i-1],dp[i-2]有关，可以只保存三个数
        // 同时从后向前遍历，可以不用转换成字符串，直接进行计算
     		// 一次读取两位
        int value = num % 100;
        // p代表dp[i-2]
        // q代表dp[i-1]
        // r代表dp[i]
        int p = 1;
      	// 当 i 和 i-1 可以合起来代表一个字母时
        int q = value > 9 && value < 26 ? 2 : 1;
        int r = q;
        num = num / 10;
        while(num > 0){
            value = num % 100;
            r = q;
            if(value > 9 && value < 26){
                r += p;
            }
          	// 向前移动一位
            num /= 10;
            p = q;
            q = r;
        }

        return r;
    }
}
```

