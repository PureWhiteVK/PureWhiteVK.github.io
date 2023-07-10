---
title: 剑指 Offer 19. 正则表达式的匹配
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: e7c8
---
# 剑指 Offer 19. 正则表达式的匹配

请实现一个函数用来匹配包含'. '和'*'的正则表达式。模式中的字符'.'表示任意一个字符，而'*'表示它前面的字符可以出现任意次（含0次）。在本题中，匹配是指字符串的所有字符匹配整个模式。例如，字符串"aaa"与模式"a.a"和"ab\*ac\*a"匹配，但与"aa.a"和"ab*a"均不匹配。

> 链接：https://leetcode-cn.com/problems/zheng-ze-biao-da-shi-pi-pei-lcof

<!-- more -->

## 动态规划

*这一题动态规划需要考虑的地方很多，需要把所有情况都考虑完整，LeetCode上标定的难度是困难

匹配问题上大多数都是动态规划问题，例如最长公共子串

正则表达是的匹配本质上和最长公共子串类似，也需要判断两个串是否匹配，因此使用dp[i,j]代表A串的前i个字符是否可以和B串的前j个字符匹配

由于A串仅包含a-z，B串可以包含a-z、'.'、'*'三种情况，需要分别讨论

- 当 B[j]  为 a-z时，那么只需要判断A[i] == B[j] 即可，不等说明不匹配，直接return false，如果相同，那就只需要看前面的串能否匹配
- 当 B[j] 为 '.' 时，由于 '.' 为通配，效果实际上和 A[i] == B[j]一致，直接看前面的串能否匹配即可
- 当 B[j] 为 '*' 时，那么还需要查看B[j-1]，其代表B[j-1]可以出现多次（0次也行）
  - 此时检查A[i] 如果 A[i] == B[j-1] || B[j-1] == '.' 那么当前串是否匹配取决于dp[i-1,j]注意此处j并没有移动，这时因为B[j-1]B[j]的组合可以匹配多个B[j-1]
  - 如果不满足，那么说明B[j-1]B[j]组合没有作用，只需要看前面的能否匹配，即 dp[i,j-2]

```java
class Solution {
    public boolean isMatch(String s, String p) {
        int n = s.length();
        int m = p.length();
        boolean[][] dp = new boolean[n+1][m+1];
        // 空正则表达式可以匹配空串
        for(int i=0;i<=n;++i){
            for(int j=0;j<=m;++j){
                if(j==0){
                    // 空串可以匹配到空串
                    if(i==0) {
                        dp[i][j] = true;
                    }
                }else{
                  	// 非空串匹配
                    char pChar1 = p.charAt(j-1);
                    if(pChar1!='*'){
                        // 此时不是空正则串，需要拿值出来判断一下
                        if(i>0 && (s.charAt(i-1) == pChar1 || pChar1 == '.')){
                            dp[i][j] = dp[i-1][j-1];
                        }
                    }else{
                        // 碰到 '*' 号
                        if(j>1){
                            char pChar2 = p.charAt(j-2);
                          	// 忽略 c* 的情况
                            dp[i][j] |= dp[i][j-2];
                          	// 匹配到 c* 的情况
                            if(i>0 && (s.charAt(i-1) == pChar2 || pChar2 == '.')){
                                dp[i][j] |= dp[i-1][j];
                            }
                        }
                        
                    }
                }
            }
        }
        return dp[n][m];
    }
}
```



## 递归

这一题递归的思路实际上和动态规划的思路差不多，不断缩小问题规模，最后得出解

对于s和p，一共包含四种可能的情况

- s为空，p不为空（需要检查p是否可以匹配空）
- s不为空，p不为空（最为复杂，需要考虑多种情况）
- s为空，p为空（直接匹配）
- s不为空，p为空（直接不匹配）

```java
class Solution {
    public boolean isMatch(String s, String p) {
        // 首先检查s和p是否是空串
        int m = s.length();
        int n = p.length();
        if(m == 0){
            // 可能匹配的情况只可能是什么？
            // 就是类似于 a*b*c*这种，且必须是连续的，因此只需要检查*是否在奇数位置上即可
            // 且题目上也说了，不会出现两个连续**的情况
            // 奇数长度说明至少需要匹配一个字符，那也可以直接返回false
            if((n&1) == 1) return false;
            int i = 1;
            while(i<n){
                if(p.charAt(i) != '*') return false;
                i+=2;
            }
            return true;
        }
        if(n == 0){
            // 空正则匹配非空，肯定没说了
            return false;
        }
        // 最后两个来比较
        // s的最后一个字符
        char sChar = s.charAt(m-1);
        // p的最后一个字符
        char pChar = p.charAt(n-1);
        if(pChar != '*'){
            // 要么是相同，要么是不通
            if(sChar == pChar || pChar == '.'){
                return isMatch(s.substring(0,m-1),p.substring(0,n-1));
            }
            return false;
        }
        // pChar是*的情况
        if(n>1){
            char pChar1 = p.charAt(n-2);
            if(pChar1 == sChar || pChar1 == '.'){
                return isMatch(s.substring(0,m-1),p) || isMatch(s.substring(0,m),p.substring(0,n-2));
            }
            return isMatch(s.substring(0,m),p.substring(0,n-2));
        }
        // 单独一个*？
        if(sChar == pChar){
            return isMatch(s.substring(0,m-1),p.substring(0,n-1));
        }
        return false;
    }
}
```

