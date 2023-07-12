---
title: 剑指 Offer 51. 数组中的逆序对
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: a16a
date: 2021-08-17
---
# 剑指 Offer 51. 数组中的逆序对

在数组中的两个数字，如果前面一个数字大于后面的数字，则这两个数字组成一个逆序对。输入一个数组，求出这个数组中的逆序对的总数。

> [剑指 Offer 51. 数组中的逆序对 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/shu-zu-zhong-de-ni-xu-dui-lcof/)

<!-- more -->

## 暴力

最简单的，直接遍历数组中的每一个数对，判断前一个是否大于后一个，并计数

```java
class Solution {
    public int reversePairs(int[] nums) {
        int cnt = 0;
        int l = nums.length;
        for(int i=0;i<l;++i){
            for(int j=i+1;j<l;++j){
                if(nums[i] > nums[j]){
                    ++cnt;
                }
            }
        }
        return cnt;
    }
}
```

时间复杂度：o(n^2)，本题nums最长50000，要求算法时间复杂度至少是o(nlogn)级别的才行

## 归并排序

看了眼题解，提示可以用归并排序来解这个题，那么首先了解一下归并排序，归并排序的思想是，将数组划分成两部分，分别将左右两部分排序后在进行合并

nums = [7,6,5,4,3,2,1,0]

**step1**

l=0, r=1

sort{7,6}

7 > 6, cnt = 1

nums = [6,7,5,4,3,2,1,0]

**step2**

l=2, r=3

sort{5,4}

5 > 4, cnt = 2

nums = [6,7,4,5,3,2,1,0]

**step3**

l=4, r=5

sort{3,2}

3>2, cnt = 3

nums = [6,7,4,5,2,3,1,0]

**step4**

l=6, r=7

sort{1,0}

1>0, cnt = 4

nums = [6,7,4,5,2,3,0,1]

**step5**

l=0,r=3

{6,7} merge {4,5}

6>4, cnt=6

6>5, cnt=8

nums= [4,5,6,7,2,3,0,1]

**step6**

l=4,r=7

{2,3} merge {0,1}

2>0, cnt=10

2>1, cnt=12

nums=[4,5,6,7,0,1,2,3]

**step7**

l=0,r=7

{4,5,6,7} merge {0,1,2,3}

4>0,cnt=16

4>1,cnt=20

4>2,cnt=24

4>3,cnt=28

nums=[0,1,2,3,4,5,6,7]

nums 已经有序，返回逆序对数28

代码实现也很简单，只需要在归并排序的基础上添加一行代码即可

```java
class Solution {
    private int cnt;
    private int[] temp;
    public int reversePairs(int[] nums) {
        cnt = 0;
        temp = new int[nums.length];
        mergeSort(nums,0,nums.length-1);
        return cnt;
    }
	
  	// 归并排序模版代码
    private void mergeSort(int[] nums,int l,int r){
        // System.out.println(l+" "+r);
        if(l>=r) return;
        int mid = (l+r) >> 1;
        mergeSort(nums,l,mid);
        mergeSort(nums,mid+1,r);
        // 开始归并
        int l1 = l,l2 = mid+1,i=l;
        while(l1<=mid && l2 <= r){
            // 在这里计算的时候，如果有出现temp[l1]>temp[l2]，说明左边的是要大于右边的
            if(nums[l1] > nums[l2]){
                temp[i++] = nums[l2++];
              	// 只需要添加这一行
                // 所有在temp[l1]后面的都会比temp[l2]大，因此需要进行累加
                cnt += (mid+1-l1);
            }else {
                temp[i++] = nums[l1++];
            }
        }
        while(l1<=mid){
            temp[i++] = nums[l1++];
        }
        while(l2<=r){
            temp[i++] = nums[l2++];
        }
        for(i=l;i<=r;++i){
            nums[i] = temp[i];
        }
    }
}
```



## 排序+离散化树状数组

还有一种计算逆序对的思路，将nums中每一个数字映射到桶中，bucket[i]表示数字i出现的次数，例如 nums = [5,5,2,3,6]

那么 bucket = [0,0,1,1,0,2,1]

那么在建立映射的过程中，实际上就可以计算逆序对数了，具体做法就是从后向前遍历数组nums，对于当前数而言，其在bucket中的前缀和就可以表示在前面有多少个数小于他，因为在bucket中已经计过数的说明是在当前数后面出现的，而其在bucket中位置在当前数之前，这样就构成了逆序对，因此计算bucket的前缀和就可以得到当前数的逆序对，最终可以计算出所有的逆序对

具体计算过程

nums = [5,5,2,3,6]

bucket = [0,0,0,0,0,0,0]

**step1**

i = 4, nums[i] = 6

prefix[4] = 0

bucket = [0,0,0,0,0,0,1]

**step2**

i = 3, nums[i] = 3

prefix[3] = 0

bucket = [0,0,0,1,0,0,1]

**step3**

i = 2, nums[i] = 2

prefix[2] = 0

bucket = [0,0,1,1,0,0,1]

**step4**

i = 1, nums[i] = 5

prefix[5] = 2, cnt = 2

bucket = [0,0,1,1,0,1,1]

**step5**

i = 0, nums[i] = 5

prefix[5] = 2,cnt = 4

bucket = [0,0,1,1,0,2,1]

遍历结束，逆序对数为4

这个方法时间复杂度为o(n)，但是空间要求很高（桶需要足够大），因此并不实用，需要进行优化

