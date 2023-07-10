---
title: 剑指 Offer 03. 数组中重复的数字
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: c7a8
date: 2021-07-10 10:58:04
---
# 剑指 Offer 03. 数组中重复的数字

找出数组中重复的数字。

**在一个长度为 n 的数组 nums 里的所有数字都在 0～n-1 的范围内**。数组中某些数字是重复的，但不知道有几个数字重复了，也不知道每个数字重复了几次。请找出数组中任意一个重复的数字。

> 链接：https://leetcode-cn.com/problems/shu-zu-zhong-zhong-fu-de-shu-zi-lcof

<!-- more -->

## HashSet

这题很简单，也没什么好说的，使用set存储元素，每碰到一个新元素就判断其是否在set中出现过，如果没有就加入，出现过就可以直接返回了

```java
class Solution {
    public int findRepeatNumber(int[] nums) {
        Set<Integer> set = new HashSet<>();
        for(int i:nums){
            if(set.contains(i)) {
                return i;   
            }else{
                set.add(i);
            }
        }
        return 0;
    }
}
```

该算法时间复杂度o(n)，空间复杂度o(n)

## 索引

使用set解决该问题时，实际上并没有使用上述的一个条件，"长度为n的数组nums里的所有数字都在0～n-1范围内"

这个条件说明，nums数组中的数的索引和数字实际上可以做到一一对应，如果发现有重复的，直接返回即可【这个思路还挺好的，把题设条件都用到了】

[2,3,1,0,2,5,3]

iter1:

swap(nums[0],nums[nums[0]])

[1,3,2,0,2,5,3]

iter2:

swap(nums[0],nums[nums[0]])

[3,1,2,0,2,5,3]

iter3:

swap(nums[0],nums[nums[0]])

[0,1,2,3,2,5,3]

iter4:

nums[0] == 0

i = 1

iter5:

nums[1] = 1

i = 2

iter6:

nums[2] = 2

i = 3

iter6:

nums[3] = 3

i = 4

iter7:

nums[4] = 2

nums[2] = 2

collision -> 2 is redundant



```java
class Solution {
    public int findRepeatNumber(int[] nums) {
        int i = 0;
        while(i < nums.length) {
            if(nums[i] == i) {
                i++;
                continue;
            }
            if(nums[nums[i]] == nums[i]) return nums[i];
            int tmp = nums[i];
            nums[i] = nums[tmp];
            nums[tmp] = tmp;
        }
        return -1;
    }
}
```



