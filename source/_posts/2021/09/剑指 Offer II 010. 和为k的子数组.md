---
title: 剑指 Offer II 010. 和为k的子数组
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 6aaa
---
# 剑指 Offer II 010. 和为k的子数组

给定一个整数数组和一个整数 `k` **，**请找到该数组中和为 `k` 的连续子数组的个数。

> [剑指 Offer II 010. 和为 k 的子数组 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/QTMn0o/)

<!-- more -->

## 前缀和

看到连续子数组，下意识想到滑动窗口，可是这个题并不能使用滑动窗口来解，题目设定数组中的数为整数，并不是正整数，这并不符合滑动窗口扩大或收缩的条件，因此无法适用，那么除了这个之外，能快速计算连续区间内的和的就是前缀和了

可以先求出数组对应的前缀和，然后遍历不同长度的子数组，找到满足条件的即可

```java
class Solution {
    public int subarraySum(int[] nums, int k) {
        int length = nums.length;
        int[] prefixSum = new int[length+1];
        for(int i=0;i<length;++i){
            prefixSum[i+1] = prefixSum[i] + nums[i];
        }
        // 遍历前缀和，找出即可
        // o(n^2)
        int cnt = 0;
      	// 遍历所有子数组情况
        for(int i=0;i<=length;++i){
            for(int j=0;j<i;++j){
                if(prefixSum[i]-prefixSum[j] == k){
                    ++cnt;
                }
            }
        }
        return cnt;
    }
}
```

上面的算法时间复杂度为 o(n^2)，实际上可以使用哈希表进一步优化，使其时间复杂度降为 o(n)

主要思路是在计算前缀和的过程中将之前计算的结果存储在哈希表中，然后每当计算从0～当前位置的前缀和之后，就从哈希表中判断是够满足

sum - target 的值，如果存在，则说明存在连续子数组

下面以数组 [0,1,2,3,0,-1,-2,-3] 为例，找出所有和为 3 的子数组

初始化

map = {0:1} 

代表空数组的前缀和0

sum = 0

cnt = 0

step1:

sum += nums[0]，sum = 0

在map中查找 sum-target 即 前缀和为-3的，并不存在，更新map

map = {0:2}

step2:

sum += nums[1]，sum = 1

在map中查找 sum-target 即 前缀和为-2的，并不存在，更新map

map = {0:2,1:1}

step3:

sum += nums[2]，sum = 3

在map中查找 sum-target即前缀和为0的，此时存在2个前缀和为0，更新cnt

cnt = 2，代表的是 [0,1,2] 和 [1,2]

map = {0:2,1:1,3:1}

step4:

sum += nums[3]，sum = 6，找 sum-target 即前缀和为3的，此时存在1个前缀和为3的，更新cnt

cnt = 3，代表 [0,1,2] , [1,2] , [3]

map = {0:2,1:1,3:1,6:1}

step5:

sum += nums[4]，sum = 6，找sum-target即前缀和为3的，此时存在1一个前缀和为3的，更新cnt

cnt = 4，代表 [0,1,2] , [1,2] , [3] , [3,0]

map = {0:2,1:1,3:1,6:2}

step6:

sum += nums[5]，sum = 5，找sum-target即前缀和为2的，此时并不存在，更新map

map = {0:2,1:1,3:1,5:1,6:2}

step7:

sum += nums[6]，sum = 3，找sum-target即前缀和为0的，更新cnt

cnt = 6，代笔 [0,1,2] , [1,2] , [3] , [3,0] , [0,1,2,3,0,-1,-2] , [1,2,3,0,-1,-2]

map = {0:2,1:1,3:2,5:1,6:2}

step8:

sum += nums[7]，sum = 0，找sum-target即前缀和为-3的，不存在，更新map

map = {0:3,1:1,3:2,5:1,6:2}

遍历结束，返回cnt = 6



知道流程后，写出代码就很容易了

```java
class Solution {
    public int subarraySum(int[] nums, int k) {
        int sum = 0;
        int res = 0;
        HashMap<Integer, Integer> map = new HashMap<>();
        map.put(0, 1);
        for (int i : nums) {
            sum += i;
            res += map.getOrDefault(sum - k, 0);
            map.put(pre_sum, map.getOrDefault(sum, 0) + 1);
        }
        return res;
    }
}
```

只需要遍历一次，时间复杂度为 o(n)