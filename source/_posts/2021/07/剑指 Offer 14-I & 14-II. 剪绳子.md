---
title: 剑指 Offer 14-I. 剪绳子 & II. 剪绳子II
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 904c
date: 2021-07-31
---
# 剑指 Offer 14-I. 剪绳子

给你一根长度为 n 的绳子，请把绳子剪成整数长度的 m 段（m、n都是整数，n>1并且m>1），每段绳子的长度记为 k[0],k[1]...k[m-1] 。请问 k[0]*k[1]*...*k[m-1] 可能的最大乘积是多少？例如，当绳子的长度是8时，我们把它剪成长度分别为2、3、3的三段，此时得到的最大乘积是18。

> 链接：https://leetcode-cn.com/problems/jian-sheng-zi-lcof

<!-- more -->

## 动态规划（二维DP）

看到这个题，有长度和分段数，首先想到用dp[i,j]来表示长度为i时分段数为j时的最优解，初态 dp[i,1] = i，状态转移方程
$$
dp[i,j] = max(dp[i,j],dp[k,j-1]*(i-k))
$$
其中k取值范围为[1,i)

最终最佳划分值为max(dp[n,i])，长度为n的所有划分情况下的最大值

```java
class Solution {
    public int cuttingRope(int n) {
        int[][] dp = new int[n+1][n+1];
        for(int i=1;i<=n;++i){
            dp[i][1] = i;
        }
        for(int i=2;i<=n;++i){
            for(int j=2;j<=i;++j){
                for(int k=1;k<i;++k){
                    dp[i][j] = Math.max(dp[i][j],dp[k][j-1] * (i-k));
                }
            }
        }
        // 找到最大值
        int res = 0;
        for(int i=2;i<=n;++i){
            res = Math.max(res,dp[n][i]);
        }
        return res;
    }
}
```

时间复杂度：o(n^3)

空间复杂度：o(n^2)

## 动态规划（一维DP）

这个题采用二维动态规划有些浪费，实际上可以使用一维动态规划实现，使用dp[i]代表长度为i的绳子进行划分为m段时的最大值，且dp[1] = 1，状态转移方程
$$
dp[i] = max(dp[i],max(j*(i-j),j*dp[i-j]))
$$
理解起来也很简单，对于一段长度为i的绳子，有三种操作方式

1. 不进行划分
2. 划分成j之后不再进行划分
3. 划分成j之后继续进行划分（此时便将问题规模缩小，且之前已经求解过了）

```java
class Solution {
    public int cuttingRope(int n) {
        int[] dp = new int[n+1];
        dp[2] = 1;
        for(int i=3;i<=n;++i){
            for(int j=2;j<i;++j){
                dp[i] = Math.max(dp[i],Math.max(j*(i-j),j*dp[i-j]));
            }
        }
        return dp[n];
    }
}
```

时间复杂度：o(n^2)

空间复杂度：o(n)

## 数学

由算术几何均值不等式可知，
$$
\frac{n_1+n_2+...+n_a}{a} \ge \sqrt[a]{n_1n_2...n_a}
$$
当n1...na相等时取得等号，因此划分时应尽可能保持划分的长度相同

假设划分成a分，则有
$$
n = ax
$$
且乘积为
$$
y = x^a = x^{\frac{n}{x}}=(x^{\frac{1}{x}})^n
$$
由于n为常数，要使乘积最大即求函数
$$
y=x^{\frac{1}{x}}
$$
的极大值，这个函数高数中也介绍过，很经典，其极大值在x=e处取的，且由于要求划分的长度为整数，可得当x=3时y更大
$$
3^{\frac{1}{3}} > 2^{\frac{1}{2}}
$$
则需要尽可能将切割的长度保持3，此时考虑划分方式

对于长度为i的绳子，其对3取余

- 0时说明刚好整除，3^(i/3)即为最大值
- 1时说明最后一个划分长度为1，当i为4时最优划分不是（3+1）而是（2+2），因此只需要拿出一个3和最后剩下的1组合成4，使最后的结果最大，结果为3^(i/3-1)*4
- 2时就是3^(i/3)*2

```java
class Solution {
    public int cuttingRope(int n) {
        if(n<4){
            return n-1;
        }
        int d = n % 3;
        int a = n / 3;
        return d == 0 ? (int)Math.pow(3,a) 
                      : (d == 1 ? (int)(Math.pow(3,a-1)*4) 
                                : (int)(Math.pow(3,a)*2));
    }
}
```



# 剑指 Offer 14-II. 剪绳子II

这一题的题目并没有发生变化，只是数据规模变大，且还需要对1e9+7取模，直接使用max也无法比较大小了（意味着DP无法使用，或者使用BigInteger，但是写起来比较麻烦），且由于最大n可到1000，需要计算3^300的幂，计算过程中需要对幂次取余

幂次求余有两种方式

- 循环取余法o(n)
- 快速幂取余法o(logn)

## 循环取余

$$
(a*b)\% c = ((a \% c) * (b \% c))\%c
$$

例如：(12*15)%3 =((12%3)\*(15%3))%3=2

因此，对于x^n，可以在循环过程中不断计算x^1、x^2、...、x^n的余数
$$
x^n \% c = ((x^{n-1} \% c) *(x \% c)) \% c
$$

```java
private long pow(int v,int n){
  long res = 1;
  for(int i=0;i<n;++i){
    res = (res * v) % mod;
  }
  return res;
}
```

## 快速幂取余

$$
x^n \% c = (x^{2})^{\frac{a}{2}} \% c = ((x^2\%c)^{\frac{a}{2}})\%c
$$

因此可以在一次循环中将运算降至n//2，最终只需要循环log(n)次即可，可以在o(logn)时间复杂度下成幂次取余运算

> [快速幂求余 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/307759581)

```java
public long myPow(long base, int num){
  long res = 1;
  while(num > 0){
    if((num & 1) == 1){
      res = res * base % mod;
    }
    // 注意此处一定是 base = base * base % mod;
    // 因为当num为偶数的时候
    // x^11 = x^10 * x = (x^2)^5*x
    base = base * base % mod;
    num >>= 1;
  }
  return res;
}
```

