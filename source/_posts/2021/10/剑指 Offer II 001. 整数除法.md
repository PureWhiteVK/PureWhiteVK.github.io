---
title: 剑指 Offer II 001. 整数除法
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '665'
date: 2021-10-30
---
# 剑指 Offer II 001. 整数除法

给定两个整数 `a` 和 `b` ，求它们的除法的商 `a/b` ，要求不得使用乘号 `'*'`、除号 `'/'` 以及求余符号 `'%'` 。

注意：

- 整数除法的结果应当截去（truncate）其小数部分，例如：truncate(8.345) = 8 以及 truncate(-2.7335) = -2
- 假设我们的环境只能存储 32 位有符号整数，其数值范围是 [−2<sup>31</sup>, 2<sup>31</sup>−1]。本题中，如果除法结果溢出，则返回 2<sup>31</sup> − 1

> 链接：https://leetcode-cn.com/problems/xoh6Oh

<!-- more -->

## 暴力（超时）

最简单的，从除法定义出发，a = a/b * b + a%b，即a最多可以包含多少倍的b，那么最简单的就在循环中不断减去，直到最终结果小于b为止，对于负数情况，可以先取出符号位，然后取绝对值，同时存在一种特殊情况，当a为`-2^31`即Integer.MIN_VALUE时，b为1时，实际除出来的结果为`2^31`，而这个值已经超出Integer.MAX_VALUE（`2^31-1`)，按照题目要求，最终结果返回`2^31-1`

```java
class Solution {
    public int divide(int a, int b) {
        // 感觉还是需要使用位运算来模拟
        // 特殊情况
        if(a == Integer.MIN_VALUE && b == -1) return Integer.MAX_VALUE;
        // 不能使用乘法、除法、取余，那就用减法嘛
        int i = 0;
        // 还需要考虑负数问题
        boolean isPositive = ( a>0 && b>0 ) || ( a<0 && b<0 );
        a = abs(a);
        b = abs(b);
        // 对于 a >> b的情况，需要减的太过了
        // 如果a=2^31，b=1，这样的话计算起来太慢了，需要找其他方法
        // 实际上可以有更好的解决方式
        while(a>=b){
            a-=b;
            ++i;
        }
        return isPositive ? i : -i;
    }

    private int abs(int v){
        if(v<0) return -v;
        return v;
    }
}
```



## 位运算

实际上，这个思路有点类似于 `剑指 Offer 64. 求1+2+...+n` ，剑指 Offer 64 一题实际上是需要使用位运算模拟乘法，而本题要求用位运算模拟除法，本质上思路是一致的。

下面举一个例子来介绍

求 15 / 2

初始化

a = 15

b = 2

v = 0

step1:

首先可以很快知道 2^3 = 8 < 15 < 2^4 = 16，包含4倍的2

此时更新值

a = 15 - 8 = 7

b = 2

v = 4 （2^3 >> 1 = 4）

step2:

又有2^2 = 4 < 7 < 2^3 = 8，此时包含2倍的2

a = 7 - 4 = 3

b = 2

v = 6 （4 + 2^2 >> 1 = 6)

step3:

此时 2 < 3 < 2^2 = 4

a = 3 - 2 = 1

b = 2

v = 7 (6 + 2>>1 = 7)

此时 a < b ，计算完成，a/b 结果为 7

知道计算过程之后，写出代码就很简单了

```java
class Solution {
    public int divide(int a, int b) {
        boolean isPositive = (a>0&&b>0) || (a<0&&b<0);
        long a1 = Math.abs((long)a);
        long b1 = Math.abs((long)b);
        // System.out.println(a1+" "+b1);
        long v = 0;
        while(a1>=b1){
            long b2 = b1;
            long shift = 1;
            while(a1 > (b2 << 1)){
                // 每左移一次相当于乘二
                b2 <<= 1;
                shift <<= 1;
            }
            v+=shift;
            a1 -= b2;
        }
        v = isPositive ? v : -v;
        if(v > Integer.MAX_VALUE){
            return Integer.MAX_VALUE;
        }
        return (int)v;
    }
}
```