---
title: 剑指 Offer II 035. 最小时间差
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 72b1
---
# 剑指 Offer II 035. 最小时间差

给定一个 24 小时制（小时:分钟 **"HH:MM"**）的时间列表，找出列表中任意两个时间的最小时间差并以分钟数表示。

**提示：**

- `2 <= timePoints <= 2 * 10^4`
- `timePoints[i]` 格式为 **"HH:MM"**

> https://leetcode-cn.com/problems/569nqc/

<!-- more -->

## 暴力

没什么好说的，直接两两比较，计算时间差即可

```java
class Solution {
    public int findMinDifference(List<String> timePoints) {
        // 就直接暴力呗，两两进行计算即可
        int min = 1440;
        int l = timePoints.size();
        for(int i=0;i<l;++i){
            for(int j=0;j<i;++j){
                // System.out.println(i+" "+j);
                min = Math.min(min,difference(timePoints.get(i),timePoints.get(j)));
            }
        }
        return min;
    }

    private int difference(String t1,String t2){
        int[] hm1 = parseTimeString(t1);
        int[] hm2 = parseTimeString(t2);
        // 计算时间差，统一采用t1-t2，最后返回绝对值即可
        // 一天总共 24*60 = 1440 分钟
        int t = abs((hm1[0]-hm2[0])*60 + hm1[1]-hm2[1]);
        // System.out.println(t1+"-"+t2+":"+t);
        // 有可能两个时间是在同一天，也有可能是在不同的天，因此需和1440（一天的时间）计算比较而得
        return Math.min(t,1440-t);
    }

    private int abs(int v){
        if(v>0) return v;
        return -v;
    }

    private int[] parseTimeString(String t){
        int[] res = new int[2];
        res[0] = (t.charAt(0)-'0')*10 + (t.charAt(1)-'0');
        res[1] = (t.charAt(3)-'0')*10 + (t.charAt(4)-'0');
        return res;
    }
}
```

时间复杂度：o(n^2)

本题测试样例为 2*10^4 ，数量级还是有点大，卡的死死的，纯暴力会超时

## 暴力优化

由于一天按分钟划分只有24*60 = 1440个时间间隔，因此当timePoints的长度大于1440时一定存在重复元素，直接返回0，这样可以

```java
class Solution {
    public int findMinDifference(List<String> timePoints) {
      	if(timePoints.size() > 1440) return 0;
        // 就直接暴力呗，两两进行计算即可
        int min = 1440;
        int l = timePoints.size();
        for(int i=0;i<l;++i){
            for(int j=0;j<i;++j){
                // System.out.println(i+" "+j);
                min = Math.min(min,difference(timePoints.get(i),timePoints.get(j)));
            }
        }
        return min;
    }

    private int difference(String t1,String t2){
        int[] hm1 = parseTimeString(t1);
        int[] hm2 = parseTimeString(t2);
        // 计算时间差，统一采用t1-t2，最后返回绝对值即可
        // 一天总共 24*60 = 1440 分钟
        int t = abs((hm1[0]-hm2[0])*60 + hm1[1]-hm2[1]);
        // System.out.println(t1+"-"+t2+":"+t);
        // 有可能两个时间是在同一天，也有可能是在不同的天，因此需和1440（一天的时间）计算比较而得
        return Math.min(t,1440-t);
    }

    private int abs(int v){
        if(v>0) return v;
        return -v;
    }

    private int[] parseTimeString(String t){
        int[] res = new int[2];
        res[0] = (t.charAt(0)-'0')*10 + (t.charAt(1)-'0');
        res[1] = (t.charAt(3)-'0')*10 + (t.charAt(4)-'0');
        return res;
    }
}
```



## 自定义排序

直接暴力行不通，可以先对timePoints数组进行排序，按照小时和分钟进行排序，之后计算两个元素之间差值的最小值即可

```java
class Solution {
    public int findMinDifference(List<String> timePoints) {
        if(timePoints.size() > 1440) return 0;
        int min = 1440;
        int l = timePoints.size();
        int[][] t = new int[l][2];
        for(int i=0;i<l;++i){
            t[i] = parseTimeString(timePoints.get(i));
        }
        Arrays.sort(t,(a,b)->a[0]==b[0]?a[1]-b[1]:a[0]-b[0]);
        // for(int[] ti:t){
        //     System.out.println(ti[0]+":"+ti[1]);
        // }
        // 自定义排序+遍历？
        for(int i=1;i<l;++i){
            min = Math.min(min,difference(t[i-1],t[i]));
        }
        // 最后再比较一下首尾即可
        min = Math.min(min,difference(t[l-1],t[0]));
        return min;
    }

    private int difference(int[] hm1,int[] hm2){
        // 计算时间差，统一采用t1-t2，最后返回绝对值即可
        // 一天总共 24*60 = 1440 分钟
        int t = abs((hm1[0]-hm2[0])*60 + hm1[1]-hm2[1]);
        // System.out.println(t1+"-"+t2+":"+t);
        // 有可能两个时间是在同一天，也有可能是在不同的天，因此需和1440（一天的时间）计算比较而得
        return Math.min(t,1440-t);
    }

    private int abs(int v){
        if(v>0) return v;
        return -v;
    }

    private int[] parseTimeString(String t){
        int[] res = new int[2];
        res[0] = (t.charAt(0)-'0')*10 + (t.charAt(1)-'0');
        res[1] = (t.charAt(3)-'0')*10 + (t.charAt(4)-'0');
        return res;
    }
}
```

