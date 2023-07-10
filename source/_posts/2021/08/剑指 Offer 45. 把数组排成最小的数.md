---
title: 剑指 Offer 45. 把数组排成最小的数
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: e2ad
---
# 剑指 Offer 45. 把数组排成最小的数

输入一个非负整数数组，把数组里所有数字拼接起来排成一个数，打印能拼接出的所有数字中最小的一个。

> [剑指 Offer 45. 把数组排成最小的数 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/ba-shu-zu-pai-cheng-zui-xiao-de-shu-lcof/)

<!-- more -->

## 贪心+自定义排序

首先看到题目想到暴力，就需要枚举所有数字的组合方式（即全排列），那么共有nums.length!种排列方式，本题nums.length < 100，100!规模太大，肯定是不行的，那么就肯定需要找一点其他方法

这个解法说实话没想数来，看题解知道的，对于nums中的数字，如果有 String(x)+String(y) < String(y)+String(x)，说明x的优先级比y高，x排在y前面，按照这种排序方式对于nums进行排序，可保证最后得到的一定是最小的数字

证明：

首先说明为什么 String(x)+String(y) < String(y)+String(x)，x的优先级比y高

举个例子吧，x=101和y=10

10110和10101，明显是String(y)+String(x)更小，所以y在数字组合中一定是排在x前面的

再来看传递性，如果有x+y<y+x且y+z<z+y，则有x+z<z+x

设x=1，y=10，z=101

明显有110>101，则10的优先级比1高

10101>10110，则10的优先级比101高

1101>1010，则101的优先级比1高

当一个数，其和其余所有数组合之后得到的数都更小，说明这个数优先级很高，按照这个排序方式，最终一定可以的到最小的数（因为每一步都是最小）

```java
class Solution {
    public String minNumber(int[] nums) {
        String[] strs = new String[nums.length];
        for(int i=0;i<nums.length;++i){
            strs[i] = String.valueOf(nums[i]);
        }
        Arrays.sort(strs,(a,b)->(a+b).compareTo(b+a));
        StringBuilder sb = new StringBuilder();
        for(String i:strs){
            sb.append(i);
        }
        return sb.toString();
    }
}
```

