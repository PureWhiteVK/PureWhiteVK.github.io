---
title: 剑指 Offer II 020. 回文子字符串的个数
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 1deb
---
# 剑指 Offer II 020. 回文子字符串的个数

给定一个字符串 `s` ，请计算这个字符串中有多少个回文子字符串。

具有不同开始位置或结束位置的子串，即使是由相同的字符组成，也会被视作不同的子串。

**提示：**

- `1 <= s.length <= 1000`
- `s` 由小写英文字母组成

> [剑指 Offer II 020. 回文子字符串的个数 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/a7VOhD/)

<!-- more -->

## 暴力

没什么好说的，遍历字符串的所有子串，判断是否是回文串即可

```java
class Solution {
    public int countSubstrings(String s) {
        // 暴力的话也不是不行，数据量又不大
        int l = s.length();
        int res = 0;
        for(int i=0;i<l;++i){
            for(int j=i+1;j<=l;++j){
                if(check(s.substring(i,j))){
                    ++res;
                }
            }
        }
        return res;
    }

    private boolean check(String s){
        // System.out.println(s);
        int l = 0;
        int r = s.length()-1;
        while(l<r){
            if(s.charAt(l) != s.charAt(r)) return false;
            ++l;
            --r;
        }
        return true;
    }
}
```

时间复杂度：o(n^3)

空间复杂度：o(1)

## 动态规划

dp[i,j]代表字符串从i到j的子串是否是回文串，有以下初始化方案

dp[i,i] = true

dp[i,i+1] = true if s.charAt(i) == s.charAt(i+1)

dp[i,j] = dp[i+1,j-1] && s.charAt(i) == s.charAt(j)

```java
class Solution {
    public int countSubstrings(String s) {
        int l = s.length();
        boolean[][] dp = new boolean[l][l];
        // dp[i][i] = 1;
        // dp[i][i+1] = true if s.charAt(i) == s.charAt(i+1)
        // dp[i][j] = dp[i+1][j-1] && s.charAt(i) == s.charAt(j)
        dp[0][0] = true;
        int res = 1;
        char[] arr = s.toCharArray();
        for(int i=1;i<l;++i){
            dp[i][i] = true;
            ++res;
            if(arr[i] == arr[i-1]){
                dp[i-1][i] = true;
                ++res;
            }
        }
        for(int j=2;j<=l;++j){
            for(int i=0;i+j<l;++i){
                int k = i+j;
                dp[i][k] = dp[i+1][k-1] && arr[i] == arr[k];
                if(dp[i][k]) ++res;
            }
        }
        return res;
    }
}
```

时间复杂度：o(n^2)

空间复杂度：o(n^2)

## 滑动窗口

遍历字符串，对每个字符，都看作回文的中心，向两端延申进行判断直到非回文。

回文的中心可能是一个字符，也可能是两个字符。

```java
class Solution {
    char[] arr;
    int length;
    int res;
    public int countSubstrings(String s) {
        arr = s.toCharArray();
        length = arr.length;
        res = 0;
        for(int i=0;i<length;++i){
            check(i,i);
            check(i,i+1);
        }
        return res;
    }

    private void check(int l,int r){
        while(l>-1 && r < length && arr[l] == arr[r]){
            ++res;
            --l;
            ++r;
        }
    }
}
```

时间复杂度：o(n^2)

空间复杂度：o(1)

