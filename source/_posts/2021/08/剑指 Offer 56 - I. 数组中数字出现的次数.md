---
title: 剑指 Offer 56 - I. 数组中数字出现的次数
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '8027'
date: 2021-08-18
---
# 剑指 Offer 56 - I. 数组中数字出现的次数

一个整型数组 `nums` 里除两个数字之外，其他数字都出现了两次。请写程序找出这两个只出现一次的数字。要求时间复杂度是O(n)，空间复杂度是O(1)。

> [剑指 Offer 56 - I. 数组中数字出现的次数 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/shu-zu-zhong-shu-zi-chu-xian-de-ci-shu-lcof/)

<!-- more -->

## 位运算

这一题非常巧妙的考察了的异或运算的性质

a^b = b^a

a^a = 0

0^a = a

由于nums中除了两个数字外，其他数字都出现了两次，设这两个数字对应下标分别为i和j，则有
$$
xor = nums[0] \oplus nums[1] \oplus nums[2] \oplus \cdots \oplus nums[n-1] = nums[i] \oplus nums[j]
$$
又由于nums[i]和nums[j]一定是两个不同的值，那么对于nums[i]和nums[j]，其对应的二进制上至少有一位是不同的，之后我们根据这一位来将nums划分成两部分，再进行一次异或运算，就可以得到其中一个值，再和xor值进行一个异或运算就可以得到另外一个值

使用
$$
xor \and (-xor) 
$$
就可以得到xor的最低位对应的数，这是由于计算机负数使用补码表示，取反+1，

下面拿0b00111101举例

该数对应的反码为

0b11000010

对应的补码为

0b11000011

之后再将这两个值进行一个与运算

0b00000001，这个值就代表了0b00111101的最末尾的1

再举一个，0b00000010

反码：0b11111101

补码：0b11111110

lowerbit：0b00000010，可以看到刚好对应的是0b00000010的最低位的1

知道这个之后，就可以写代码了

```java
class Solution {
    public int[] singleNumbers(int[] nums) {
        // 除了两个数字之外，其它的数字都出现了两次
        // 考虑最坏情况
        // 共有 nums.length / 2 + 1 个不重复的数字，
        // 然后前 nums.length / 2 + 1都是不重复的，后面才是重复的
        // [1,2,3,4,5,1,2,3]
        // a^a = 0
        // 0^a = a
        // 1^2^3^4^5^1^2^3 = 4^5 = a^b
        // 根据lowerbit可以将nums划分成两部分，然后对这两部分分别进行异或，最终就可以找到不同的数字
        // lowerbit = res & (-res)
        int xor = 0;
        for(int num:nums){
            xor ^= num;
        }
        int a = 0;
        int lowerbit = xor & (-xor);
        for(int num:nums){
            if((lowerbit & num) != 0){
                a ^= num;
            }
        }
        return new int[]{a,xor^a};
    }
}
```

