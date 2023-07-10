---
title: 剑指 Offer 16. 数值的整数次方
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 13c2
---
# 剑指 Offer 16. 数值的整数次方

实现 [pow(*x*, *n*)](https://www.cplusplus.com/reference/valarray/pow/) ，即计算 x 的 n 次幂函数（即，xn）。不得使用库函数，同时不需要考虑大数问题。

> 链接：https://leetcode-cn.com/problems/shu-zhi-de-zheng-shu-ci-fang-lcof/

<!-- more -->

## 快速幂（二分）

由于指数幂次的计算特点
$$
x^n = (x^2)^{\frac{n}{2}}
$$
可以在每次计算过程中都计算当前值的平方，这样每次都可以使n减半，这样就可以在o(logn)时间复杂度内完成计算

### 递归写法

```java
class Solution {
    public double myPow(double x, int n) {
        // 每次都乘上两次自身
        if(n==0) return 1;
        // 这个地方是个坑点，如果是直接使用 return myPow(1/x,-n) 
        // 当n=-2147483648的时候，就会出现 n = -n ,从而出现死循环
        else if(n==-1) return 1/x;
      	// 此处位移也必须采用带符号的位移，保证携带有符号
        else if((n&1) == 1) return x*myPow(x*x,n>>1);
        return myPow(x*x,n>>1);
    }
}
```

### 迭代写法

```java
class Solution {
  public double myPow(double x,int n){
    long res = 1L;
    while (n > 0){
      if ((n & 1) != 0 ){
        res *= x;
      }
      x = x * x;
      n >>= 1;
    }
    return res;
  }
}
```

