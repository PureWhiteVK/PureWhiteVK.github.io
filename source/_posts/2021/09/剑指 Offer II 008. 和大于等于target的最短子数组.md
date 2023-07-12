---
title: 剑指 Offer II 008. 和大于等于target的最短子数组
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: bb96
date: 2021-09-24
---
# 剑指 Offer II 008. 和大于等于target的最短子数组

给定一个含有 n 个正整数的数组和一个正整数 target 。

找出该数组中满足其和 ≥ target 的长度最小的 连续子数组 [numsl, numsl+1, ..., numsr-1, numsr] ，并返回其长度。如果不存在符合条件的子数组，返回 0 。

> 链接：https://leetcode-cn.com/problems/2VG8Kg

<!-- more -->

## 前缀和+二分查找

从题目中可以看到，数组中仅包含正整数，那么其前缀和一定是一个非递减的序列，就可以使用二分查找，两数之差大于等于target的索引差最小值即可

```java
class Solution {
    public int minSubArrayLen(int target, int[] nums) {
        // 首先计算前缀和
        int length = nums.length;
        int[] prefixSum = new int[length+1];
        for(int i=0;i<length;++i){
            prefixSum[i+1] = prefixSum[i] + nums[i];
        }
        int minLength = Integer.MAX_VALUE;
        for(int i=length;prefixSum[i] >= target;--i){
            // 二分查找
            int l = 0;
            int r = i;
            int t = prefixSum[i] - target;
            // upperBound
            while(l<r){
                int mid = (l+r)>>1;
                if(prefixSum[mid] > t){
                    r = mid;
                }else{
                    l = mid+1;
                }
            }
            minLength = Math.min(minLength,i-l+1);
        }
        return minLength == Integer.MAX_VALUE ? 0 : minLength;
    }
}
```

## 滑动窗口

滑动窗口思想也很简单，使用两个指针，分别指向窗口的最左边和最右端，之后不断变更窗口大小，同时记录窗口值符合条件，下面拿个例子判断

初始化：

nums = [2,3,1,2,4,3]

target = 7

res = Integer.MAX_VALUE

l=0

r=0

sum = 0

step1：

窗口为 [2]，sum=2 < 7，不符合条件，继续更新

sum = 2

l = 0

r = 1

step2：

窗口为 [2,3]，sum=5 < 7，不符合条件，继续更新

sum = 5

l = 0

r = 2

step3：

窗口为 [2,3,1]，sum =6 < 7，不符合条件，继续更新

sum = 6

l = 0

r = 3

step4：

窗口为 [2,3,1,2]，sum=8>7，符合条件

记录最小窗口大小 res = min(Integer.MAX_VALUE,4)= 4

收缩窗口

l = 1，窗口变成 [3,1,2]，sum=6 < 7，不符合条件，继续更新

r = 4

sum = 6

step5：

窗口为 [3,1,2,4]，sum=10 > 7，符合条件

记录最小窗口大小 res = min(4,4) = 4

收缩窗口

l = 2，窗口为 [1,2,4]，sum=7>=7，符合条件

记录最小窗口大小 res = min(3,4) = 3

收缩窗口

l = 3，窗口为 [2,4]，sum=6<7，不符合条件，继续更新

r = 5

sum = 6

step6：

窗口为 [2,4,3]，sum=9>7，符合条件

记录最小窗口大小 res = min(3,3) = 3

收缩窗口

l = 4，窗口为[4,3]，sum=7>=7，符合条件

记录最小窗口大小 res = min(3,2) = 2

收缩窗口

l = 5，窗口为[3]，sum=3 < 7，不符合条件，继续更新

r = 6 == length 

遍历结束，返回最小窗口大小为2

```java
class Solution {
    public int minSubArrayLen(int target, int[] nums) {
        int left = 0;
        int total = 0;
        int ret = Integer.MAX_VALUE;
        for (int right = 0; right < nums.length; right++) {
          	// [left,right]区间内的和
            total += nums[right];
            while (total >= target) {
              	// 当满足条件是更新长度
                ret = Math.min(ret, right - left + 1);
              	// 左指针右移
              	// 收缩窗口
                total -= nums[left++];
            }
        }
        return ret > nums.length ? 0 : ret;
    }
}
```

## 滑动窗口模版

滑动窗口适用于求解数组中连续区间内的值问题（和、积等）

```java
初始化左边界 left = 0
初始化返回值 ret = 最小值 or 最大值
for 右边界 in 可迭代对象:
	更新窗口内部信息
	while 根据题意进行调整：
		比较并更新ret(收缩场景时)
		扩张或收缩窗口大小
	比较并更新ret(扩张场景时)
返回 ret
```

