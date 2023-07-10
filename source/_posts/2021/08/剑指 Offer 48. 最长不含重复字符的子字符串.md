---
title: 剑指 Offer 48. 最长不含重复字符的子字符串
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 6d2f
---
# 剑指 Offer 48. 最长不含重复字符的子字符串

请从字符串中找出一个最长的不包含重复字符的子字符串，计算该最长子字符串的长度。

> [剑指 Offer 48. 最长不含重复字符的子字符串 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/zui-chang-bu-han-zhong-fu-zi-fu-de-zi-zi-fu-chuan-lcof/)

<!-- more -->

## 动态规划 + 哈希表

dp[j]指的是以字符s[j]结尾的字符串的长度。注意，这个字符串需要尽可能的长，且不能含有重复字符。

我们可以记为字符串sub[j], 该字符串以字符s[j]结尾，长度为dp[j]。

这样就比较好理解状态转移方程了。固定右边界 j ，同时定义从边界 j 往左侧距离最近的相同字符的索引为 i 。

以字符s[j-1]结尾的字符串记录为sub[j-1]，其长度为dp[j-1]，注意sub [j-1]中字符不重复。 我们看索引 j 的情况：在 j 的左侧寻找一个重复的字符s [i],那么索引 i 可能在字符串sub[j-1]的区间内，也可能在字符串sub[j-1]的左边界更左侧才有可能寻找到。这样就需要分两种情况考虑。

- 如果字符 s[i] 在子字符串 sub[j−1] 区间之外，也就是更左侧, 那么dp[j-1] < j-i，这种情况下，由于sub [j-1]中字符不重复，且当前最长，所以以s[ j ]为结尾的字符串只需要在子字符串 sub[j−1]后面接上这个字符s[ j ]就可以了，其长度dp [ j ] = dp[j-1]+1;

- 如果字符 s[ i ] 在子字符串 sub[ j− 1 ] 区间之中，必然dp[ j−1 ] ≥ j − i，这种情况下，由于我们需要寻找以s[ j ]结尾且最长的字符串，那么sub[ j ]的左边界只能是 i 了，其长度 dp[ j ] = j − i 。

下面举个例子，设字符串为“abcdbaa”

初始化 

dp = [0,0,0,0,0,0,0]

lastIndex = {}

step1:

index = 0，对应字符为 'a' ，lastIndex.get('b') = null，直接更新并记录索引

lastIndex = {'a':0}

dp = [1,0,0,0,0,0,0]

step2

index = 1，对应字符为 'b' ，lastIndex.get('b') = null ，直接更新并记录索引

又由于此时 dp[0] = 1，且对于字符 'b' 而言，这是其第一次出现在字符串中，也就是说在以str[index-1] 即 'a' 为结尾的最长不包含重复字符的字符串（"a"）中并不包含 'b'，此时可以将 'b' 加入字符串中

lastIndex = {'a':0,'b':1}

dp = [1,2,0,0,0,0,0]

step3

index = 2，对应字符为 'c' ，lastIndex.get('c') = null ，直接更新并记录索引

又由于此时 dp[1] = 2，且对于字符 'c' 而言，这是其第一次出现在字符串中，也就是说在以str[index-1] 即 'b' 为结尾的最长不包含重复字符的字符串（"ab"）中并不包含 'c'，此时可以将 'c' 加入字符串中

lastIndex = {'a':0,'b':1,'c':2}

dp = [1,2,3,0,0,0,0]

step4

index = 3，对应字符为 'd' ，lastIndex.get('d') = null ，直接更新并记录索引

又由于此时 dp[2] = 3，且对于字符 'd' 而言，这是其第一次出现在字符串中，也就是说在以str[index-1] 即 'c' 为结尾的最长不包含重复字符的字符串（"abc"）中并不包含 'd'，此时可以将 'd' 加入字符串中

lastIndex = {'a':0,'b':1,'c':2,'d':4}

dp = [1,2,3,4,0,0,0]

step5

index = 4，对应字符为 'b'，lastIndex.get('b') = 1，而 dp[index-1] = 4（即对应字符串 "abcd"），此处可以发现b是曾经出现在dp[index-1]对应的最长不包含重复字符的字符串中的，那么此时以当前字符 'b' 结尾的最长不包含重复字符的字符串就只能是 "cbd"，即从其前一次出现的位置的下一个字符开始算起，再这期间，由于 dp[index-1] 对应的字符串不包含重复字符，那么其子字符串也一定不包含，最后按照第二条状态转移公式更新并记录索引

lastIndex = {'a':0,'b':4,'c':2,'d':3}

dp = [1,2,3,4,3,0,0]

step6

index = 5，对应字符为 'a'，lastIndex.get('a') = 0，dp[index-1] = 3，对应字符串为 "cbd"，此时 'a' 明显不在这个字符串中，可以将其加入，按照第一条状态转移公式进行更新

lastIndex = {'a':5,'b':4,'c':2,'d':3}

dp = [1,2,3,4,3,4,0]

step6

index = 6，对应字符为 'a'，lastIndex.get('a') = 5，dp[index-1] = 4，对应的字符串为 "cbda"，此时a位于该字符串中，使用第二条状态转移公式进行更新，此时以当前的 'a'结尾的符合条件的字符串就只有 "a"了

lastIndex = {'a':6,'b':4,'c':2,'d':3}

dp = [1,2,3,4,3,4,1]

此时遍历完成，返回dp中的最大值 4 （对应的是 "abcd" 或 "cdba"）

从状态转移方程中可以看到，dp[i] 实际上仅和 dp[i-1]有关，因此可以将空间复杂度优化为 o(1)

```java
class Solution {
    public int lengthOfLongestSubstring(String s) {
      	// 记录字符上一次出现的位置
        Map<Character, Integer> map = new HashMap<>();
        // dp表示以s[i]结尾的不包含重复字符串的最长长度
        int res = 0, dp = 0;
        for(int j = 0; j < s.length(); j++) {
            // 记录的是字符s[j]的前一个出现位置
            int i = map.getOrDefault(s.charAt(j), -1); // 获取索引 i
            map.put(s.charAt(j), j); // 更新哈希表
          	// dp < j - i 实际判断的就是 str[j] 是否出现在 以 str[j-1] 结尾的满足条件的字符串中，如果不在就可以继续增加
          	// 如果再其中就只能从其出现位置之后重新开始计算
            dp = dp < j - i ? dp + 1 : j - i; // dp[j - 1] -> dp[j]
          	// 最后记录一下最大值即可
            res = Math.max(res, dp); // max(dp[j - 1], dp[j])
        }
        return res;
    }
}
```







