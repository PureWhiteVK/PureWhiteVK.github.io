---
title: 剑指 Offer II 005. 单词长度的最大乘积
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '1829'
date: 2021-08-31
---
# 剑指 Offer II 005. 单词长度的最大乘积

给定一个字符串数组 words，请计算当两个字符串 words[i] 和 words[j] 不包含相同字符时，它们长度的乘积的最大值。假设字符串中只包含英语的小写字母。如果没有不包含相同字符的一对字符串，返回 0。

> 链接：https://leetcode-cn.com/problems/aseY1I

<!-- more -->

## 暴力+位运算

首先看到这个题，没什么好想法，直接暴力吧，首先肯定需要遍历每一个单词对，判断这两个单词对之间是否存在相同字符，如果采用暴力方式判断的话，时间复杂度很高，o(n^2*m^2)，m = max(words[i].length)，但是这个题还有一个条件没有用到，字符串中仅包含**英语小写字母**，只有26个字母，那么就可以想到使用位图来表示一个字符串所使用的字母，然后对比两个字符串是否包含相同字符，就只需要将两个位图进行与运算，如果结果为0，则表示这两个字符串不包含相同字符，这样判断两个字符串是否具有相同字符就可以在o(1)的时间复杂度内完成

```java
class Solution {
    public int maxProduct(String[] words) {
        // 首先考虑暴力吧？
        // 直接遍历所有的words[i],words[j]，判断其是否包含相同字符？然后进行比较？
        // 这样感觉时间复杂度太高了
        // 由于仅包含小写字符
        // 26个，int可以装下，然后判断是否包含相同字符，只需要bitmap[i] & bitmap[j] != 0，说明包含相同的字符
        // 直接位运算啊，怎么都需要遍历的
        int l = words.length;
        int[] bitmap = new int[l];
        for(int i=0;i<l;++i){
            for(char ch:words[i].toCharArray()){
                bitmap[i] |= (1<<(ch-'a')); 
            }
        }
        int res = 0;
        for(int i=0;i<l;++i){
            for(int j=0;j<i;++j){
                if((bitmap[i] & bitmap[j]) == 0){
                    res = Math.max(words[i].length()*words[j].length(),res);
                }
            }
        }
        return res;
    }
}
```

