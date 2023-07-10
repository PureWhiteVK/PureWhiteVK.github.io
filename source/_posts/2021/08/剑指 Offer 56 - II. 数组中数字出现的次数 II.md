---
title: 剑指 Offer 56 - II. 数组中数字出现的次数 II
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: b470
---
# 剑指 Offer 56 - II. 数组中数字出现的次数 II

在一个数组 `nums` 中除一个数字只出现一次之外，其他数字都出现了三次。请找出那个只出现一次的数字。

> [剑指 Offer 56 - II. 数组中数字出现的次数 II - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/shu-zu-zhong-shu-zi-chu-xian-de-ci-shu-ii-lcof/)

<!-- more -->

## 暴力

实际上这题都没有限制空间复杂度什么的，那么最简单的就是使用map统计每个数字出现的次数，然后返回出现次数为1的就可以了

```java
class Solution {
    public int singleNumber(int[] nums) {
        Map<Integer,Integer> map = new HashMap<>();
        for(int i:nums){
            map.put(i,map.getOrDefault(i,0)+1);
        }
        for(int i:map.keySet()){
            if(map.get(i) == 1) return i;
        }
        return -1;
    }
}
```

## 位运算（1）

这个思路实际上可以应用于其他数字出现于m次，仅有一个数字出现了1次。只需要统计每个位上1出现的次数，然后将这个出现次数模上m，当余数为1时就说明仅出现一个的那个数字在此位上为1，之后就可以根据这个还原出仅出现一次的数字

```java
class Solution {
    // 统计0～31为上数字出现的次数
    private static final int[] counts = new int[32];
    public int singleNumber(int[] nums) {
        Arrays.fill(counts,0);
        for(int num:nums){
            for(int i=0;i<32;++i){
                counts[i] += (num & 1);
              	// 此处必须是无符号右移，防止符号上的1也被统计上
                num >>>= 1;
            }
        }
        int res = 0;
      // 根据1出现的次数还原出仅出现1次的数字
        for(int i=0;i<32;++i){
            if(counts[i] % 3 == 1){
                res |= (1<<i);
            }
        }
        return res;
    }
}
```

## 位运算（2）

位1计数器（每个状态代表1出现的次数）

有限状态机，从位运算（1）解法中可以看到，由于每位上1出现的次数对3取余后要么是0，要么是1，那么对于每一个输入的位，我们可以绘制出状态转移表，然后根据输入转移到下一个状态。

| 输入\状态 | 0（代表1出现次数取余后为0） | 1（代表1出现次数取余后为1） | 2（代表1出现次数取余后为2） |
| :-------: | :-------------------------: | :-------------------------: | :-------------------------: |
|     0     |              0              |              1              |              2              |
|     1     |              1              |              2              |              0              |

又由于三个状态需要使用两个二进制位来表示，那么可以得到 00，01，10 三个状态，之后再根据输入情况设置状态转移情况即可

| 输入\状态 |  00  |  01  |  10  |
| :-------: | :--: | :--: | :--: |
|     0     |  00  |  01  |  10  |
|     1     |  01  |  10  |  00  |

再单独看每个位随输入的变化情况，记高位为a，低位为b

- 当输入为0时
  - 当a=0时
    - b保持不变
  - 当a=1时
    - b = 0
- 当输入为1时
  - 当a=0时
    - b = ~b
  - 当a=1时
    - 0

根据这个状态变化情况，可以得出低位b的状态更新公式

b = b ^ n & ~a;

再根据状态更新后的b来考察a的状态更新公式

a = a ^ n & ~b;

```java
class Solution {
    public int singleNumber(int[] nums) {
        int ones = 0, twos = 0;
        for(int num : nums){
            ones = ones ^ num & ~twos;
            twos = twos ^ num & ~ones;
        }
        return ones;
    }
}
```



