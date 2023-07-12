---
title: 剑指 Offer II 017. 含所有字符的最短字符串
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 49ad
date: 2021-09-12
---
# 剑指 Offer II 017. 含所有字符的最短字符串

给定两个字符串 s 和 t 。返回 s 中包含 t 的所有字符的最短子字符串。如果 s 中不存在符合条件的子字符串，则返回空字符串 "" 。

如果 s 中存在多个符合条件的子字符串，返回任意一个。

注意： 对于 t 中重复字符，我们寻找的子字符串中该字符数量必须不少于 t 中该字符数量。

> 链接：https://leetcode-cn.com/problems/M1oyTv

<!-- more -->

## 滑动窗口

### 暴力

很明显，可以将初始窗口大小设置为t的长度，之后逐个进行判断，并不断增加窗口的大小，最终遍历s所有长度在 [t.length(),s.length()]内的子串

```java
class Solution {
    public String minWindow(String s, String t) {
        // 思路1，直接暴力，从长度为t的窗口开始遍历？
        Map<Character,Integer> tMap = new HashMap<>();
        int tLength = t.length(),sLength = s.length();
        for(int i=0;i<tLength;++i){
            char t1 = t.charAt(i);
            tMap.put(t1,tMap.getOrDefault(t1,0)+1);

        }
        for(int l = tLength;l<=sLength;++l){
          	// 从长度为tLength的子串一直到长度为sLength的子串
            int left = 0;
            int right = l;
            // 初始化窗口
            Map<Character,Integer> sMap = new HashMap<>();
            for(int i=left;i<right;++i){
                char s1 = s.charAt(i);
                sMap.put(s1,sMap.getOrDefault(s1,0)+1);
            }
            if(check(tMap,sMap)) return s.substring(left,right);
            while(right < sLength){
                char leftChar = s.charAt(left);
                char rightChar = s.charAt(right);
                sMap.put(leftChar,sMap.get(leftChar)-1);
                sMap.put(rightChar,sMap.getOrDefault(rightChar,0)+1);
                ++left;
                ++right;
                if(check(tMap,sMap)) return s.substring(left,right);
            }
        }
        // 遍历完所有的都没找到，直接返回空
        return "";
    }

    private boolean check(Map<Character,Integer> map1,Map<Character,Integer> map2){
        for(Character ch:map1.keySet()){
            if(map2.getOrDefault(ch,0) < map1.get(ch)) return false;
        }
        return true;
    }
}
```

很明显，在计算过程中需要不断遍历s，初始化窗口，然后开始滑动，这一个过程太耗时间，实际上只需要初始化一次窗口即可

时间复杂度：o(n^2)



### 优化

由于暴力解法中遍历了所有的子串，且每次都需要重新初始化窗口，实际上可以在一次遍历中不断调整窗口大小，同时记录满足条件的最小值即可

下面以 s = "ADOBECODEBANC" 和 t = "ABC" 来介绍计算过程

初始化：

tMap = {A:1,B:1,C:1}

left = 0, right = 0, cnt = 0

**step1:**

窗口为 [0,0] 代表s的子串 A

sMap = {A:1}，而A在t内，cnt=1, right=1

**step2：**

窗口为 [0,1] 代表s的子串 AD

sMap = {A:1,D:1}，D并不在t内，cnt保持不变，right=2

**step3：**

窗口为 [0,2] 代表s的子串 ADO

sMap = {A:1,D:1,O:1}，O并不在t内，cnt保持不变，right=3

**step4：**

窗口为 [0,3] 代表s的子串 ADOB

sMap = {A:1,B:1,D:1,O:1}，B在t内，cnt=2，right=4

**step5：**

窗口为 [0,4] 代表s的子串 ADOBE

sMap = {A:1,B:1,D:1,E:1,O:1}，E并不在t内，cnt保持不变，right=5

**step6：**

窗口为 [0,5] 代表s的子串 ADOBEC，C在t内，cnt=3，right=6

cnt == tMap.size()，说明ADOBEC已经包含了ABC的所有字符，更新res = ADOBEC

**step7:**

窗口为 [0,6] 代表s的子串 ADOBECO

sMap = {A:1,B:1,C;1,D:1,E:1,O:2}，O并不在t内，cnt保持不变，right=7

**step8:**

窗口为 [0,7] 代表s的子串 ADOBECOD

sMap = {A:1,B:1,C:1,D:2,E:1,O:2}，D并不在t内，cnt保持不变，right=8

**step9:**

窗口为 [0,8] 代表s的子串 ADOBECODE

sMap = {A:1,B:1,C:1,D:2,E:2,O:2}，E并不在t内，cnt保持不变，right=9

**step10:**

窗口为 [0,9] 代表s的子串 ADOBECODEB

sMap = {A:1,B:2,C:1,D:2,E:2,O:2}，B在t内，但已经满足条件，cnt保持不变，right=10

**step11:**

窗口为 [0,10] 代表s的子串 ADOBECODEB

sMap = {A:1,B:2,C:1,D:2,E:2,O:2}，B在t内，但已经满足条件，cnt保持不变，right=11

**step12:**

窗口为 [0,11] 代表s的子串 ADOBECODEBA

sMap = {A:2,B:2,C:1,D:2,E:2,O:2}，A在t内，

此时s.charAt(0) = 'A'，且t只需要一个 'A'，此时子字符串中已经包含了两个'A'，收缩窗口，更新sMap

sMap = {A:1,B:2,C:1,D:2,E:2,O:2}

left = 1，窗口为 [1,11] 代表s的子串 DOBECODEBA，

此时s.charAt(1) = 'D'，且t不需要 'D'，收缩窗口，更新sMap

sMap = {A:1,B:2,C:1,D:1,E:2,O:2}

left = 2，窗口为 [2,11] 代表s的子串 OBECODEBA

此时s.charAt(2) = 'O'，且t不需要 'O'，收缩窗口，更新sMap

sMap = {A:1,B:2,C:1,D:1,E:2,O:1}

left = 3，窗口为 [3,11] 代表s的子串 BECODEBA

此时s.charAt(3) = 'B'，且t只需要一个 'B'，此时子字符串中已经包含了两个'B'，收缩窗口，更新sMap

sMap = {A:1,B:1,C:1,D:1,E:2,O:1}

left = 4，窗口为 [4,11] 代表s的子串 ECODEBA

此时s.charAt(4) = 'E'，且t不需要 'E'，收缩窗口，更新sMap

sMap = {A:1,B:1,C:1,D:1,E:1,O:1}

left = 5，窗口为 [5,11] 代表s的子串 CODEBA

此时s.charAt(5) = 'C' ，且t需要一个'C'，s仅包含一个'C'，无法继续收缩窗口，继续扩展窗口，right=12

**step13:**

窗口为 [5,12] 代表s的子串 CODEBAN

sMap = {A:1,B:1,C:1,D:1,E:1,N:1,O:1}，N不在t内，cnt保持不变，right=13

**step14**

窗口为 [5,13] 代表s的子串 CODEBANC，C在t内，但是s已经包含过一个C，可以收缩窗口，更新sMap

sMap = {A:1,B:1,C:1,D:1,E:1,N:1,O:1}

left=6，窗口为 [6,13] 代表s的子串 ODEBANC

此时s.charAt(6) = 'O'，t不包含'O'，收缩窗口，更新sMap

sMap = {A:1,B:1,C:1,D:1,E:1,N:1}

left=7，窗口为 [7,13] 代表s的子串 DEBANC

此时s.charAt(7) = 'D'，t不包含 'D'，收缩窗口，更新sMap

sMap = {A:1,B:1,C:1,E:1,N:1}

left=8，窗口为 [8,13] 代表s的子串 EBANC

此时s.charAt(8) = 'E'，t不包含 'E'，收缩窗口，更新sMap

sMap = {A:1,B:1,C:1,N:1}

left=9，窗口为 [9,13] 代表s的子串 BANC

此时s.charAt(9) = 'B'，t需要一个'B'，此时子串也仅包含一个B，无法进行收缩，更新res

res = BANC

此时遍历结束，返回最小窗口为BANC

从这个过程中，可以很清楚的看到，在遍历s的过程中，不断判断是否可以收缩窗口，从而在仅遍历一次s的情况下得到结果

时间复杂度o(n)

```java
class Solution {
    public String minWindow(String s, String t) {
        // 思路1，直接暴力，从长度为t的窗口开始遍历？
        // 超时，卡在最后一个样例
        Map<Character,Integer> tMap = new HashMap<>(),sMap = new HashMap<>();
        int tLength = t.length(),sLength = s.length();
        for(int i=0;i<tLength;++i){
            char t1 = t.charAt(i);
            tMap.put(t1,tMap.getOrDefault(t1,0)+1);
        }
        // 仅遍历一次s，在遍历过程中更新左右指针，
        int tUniqueChars = tMap.size();
        int left = 0;
        int cnt = 0;
        String res = "";
        for(int right = 0;right < sLength;++right){
            char s1 = s.charAt(right);
            sMap.put(s1,sMap.getOrDefault(s1,0)+1);
            // 遍历过程中不断判断当前是否满足条件
            if(tMap.containsKey(s1) && sMap.get(s1).equals(tMap.get(s1))) ++cnt;
            while(left <= right){
                char s2 = s.charAt(left);
                // 当最左端的字符没用时，收缩窗口
                if(sMap.get(s2) > tMap.getOrDefault(s2,0)){
                    sMap.put(s2,sMap.get(s2)-1);
                    if(tMap.containsKey(s2) && tMap.get(s2) > sMap.get(s2)) --cnt;
                    ++left;
                }else{
                    break;
                }
            }
            if(cnt == tUniqueChars && (res.equals("") || res.length() > right + 1 -left)){
                res = s.substring(left,right+1);
            }
        }
        return res;
    }
}
```

