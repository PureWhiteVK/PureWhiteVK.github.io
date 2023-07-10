---
title: 剑指 Offer 57. 和为s的两个数字
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 1fbe
---
# 剑指 Offer 57. 和为s的两个数字

输入一个递增排序的数组和一个数字s，在数组中查找两个数，使得它们的和正好是s。如果有多对数字的和等于s，则输出任意一对即可。

<!-- more -->

## 集合

这个方法也适用于无序的数组，用一个集合存储数组中的数组，然后对于nums[i]判断target-nums[i]是否在集合中即可

```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        Set<Integer> set = new HashSet<>();
        for(int num:nums){
            set.add(num);
        }
        for(int num:nums){
            if(set.contains(target-num)){
                return new int[]{num,target-num};
            }
        }
        return new int[0];
    }
}
```

时间复杂度：o(n)

空间复杂度：o(n)

## 二分查找

由于数组是一个递增排序的，直观反应出使用二分查找，对于nums中的每一个数组，判断target-nums[i]是否在数组中即可

```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        // 二分查找
        int[] res = new int[2];
        int l = nums.length;
        for(int i=0;i<l;++i){
            int t = target-nums[i];
            int j = binarySearch(nums,target-nums[i]);
            if(j < l && j > -1 && nums[j] == t){
                return new int[]{nums[i],nums[j]};
            }
        }
        return new int[0];
    }

    private int binarySearch(int[] nums,int target){
        int l = 0;
        int r = nums.length;
        while(l<r){
            // System.out.println(l+" "+r);
            int mid = (l+r) >> 1;
            if(nums[mid] >= target){
                r = mid;
            }else{
                l = mid+1;
            }
        }
        // System.out.println("index of target:"+target+" "+l);
        return l;
    }
}
```

时间复杂度：o(nlogn)

空间复杂度：o(1)

## 双指针

由于数组是有序的，因此可以使用双指针

初始时l=0,r=nums.length-1，t = nums[l] + nums[r]

此时t和target之间有三种关系

- t > target，此时nums[i]+nums[r]值太大，需要缩小一点，--r
- t < target，此时nums[i]+nums[r]值太小，需要放大一点，++l
- t = target，直接返回 [nums[i],nums[r] ]即可

```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        int l = 0;
        int r = nums.length-1;
        while(l<r){
            int t = nums[l] + nums[r];
            if(t > target){
                --r;
            }else if(t < target){
                ++l;
            }else{
                return new int[]{nums[l],nums[r]};
            }
        }
        return new int[0];
    }
}
```

时间复杂度：o(n)

空间复杂度：o(1)