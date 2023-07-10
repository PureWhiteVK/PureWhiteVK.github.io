---
title: 剑指 Offer II 011. 0和1个数相同的子数组
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 859a
---
# 剑指 Offer II 011. 0和1个数相同的子数组

给定一个二进制数组 `nums` , 找到含有相同数量的 `0` 和 `1` 的最长连续子数组，并返回该子数组的长度。

> [剑指 Offer II 011. 0 和 1 个数相同的子数组 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/A1NYOS/)

<!-- more -->

## 前缀和

这个题实际上还有一点脑筋急转弯，如果按照正常思路，用zeros[i]表示从0～i上包含0的个数，ones[i]表示从0～i上包含1个数，这样可以遍历所有的子数组，判断0和1的个数是否相同

```java
class Solution {
    public int findMaxLength(int[] nums) {
        int l = nums.length;
        int[] zeros = new int[l+1];
        int[] ones = new int[l+1];
        for(int i=1;i<=l;++i){
          	// 统计0出现次数
            zeros[i] = zeros[i-1];
          	// 1出现次数
            ones[i] = ones[i-1];
            if(nums[i] == 0){
                ++zeros[i];
            }else{
                ++ones[i];
            }
        }
        // 然后遍历区间
        int res = 0;
        for(int i=0;i<l;++i){
            System.out.println(zeros[i+1]+" "+ones[i+1]);
            for(int j=0;j<i;++j){
                // 需要快速找出 两个数组区间内值相同的
                if(zeros[i+1]-zeros[j] == ones[i+1]-ones[j]){
                    res = Math.max(i+1-j,res);
                }
            }
        }
        return res;
        // o(n^2)必定超时，没什么好说的就
    }
}
```

但这样的算法时间复杂度为 o(n^2)，本题数据量较大，必定超时

因此需要找一个条件进行替换，关键在于，如果将0全部替换成-1，那么就是找出所有和为0的子数组

例如 [1,1,1,0,0,0,1,0,1,1,1,0]，将0替换成-1

[1,1,1,-1,-1,-1,1,-1,1,1,1,-1]，这样题目就转换成找出和为0的子数组中长度最长的那一个

对应前缀和 

[1,2,3,2,1,0,1,0,1,2,3,2]

```java
class Solution {
    public int findMaxLength(int[] nums) {
        // map记录的是第一次出现sum的位置，这样才能尽可能保持长度最长，因为越到后面长度越长
        Map<Integer,Integer> map = new HashMap<>();
        // 记录第一次出现0的位置
        map.put(0,-1);
        int sum = 0;
        int res = 0;
        for(int i=0;i<nums.length;++i){
            // 将0替换成-1，这样只需要找出前缀和为0的即可
            sum += (nums[i]==0?-1:1);
            if(map.containsKey(sum)){
                res = Math.max(i-map.get(sum),res);
            }else{
              	// 记录第一次出现sum的位置
                map.put(sum,i);
            }
        }
        return res;
    }
}
```

