---
title: 剑指 Offer II 038. 每日温度
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 3a8e
date: 2021-09-24
---
# 剑指 Offer II 038. 每日温度

请根据每日 气温 列表 temperatures ，重新生成一个列表，要求其对应位置的输出为：要想观测到更高的气温，至少需要等待的天数。如果气温在这之后都不会升高，请在该位置用 0 来代替。

> 链接：https://leetcode-cn.com/problems/iIQa4I

<!-- more -->

## 暴力

没什么好说的，对于当前的数，遍历数组，找到下一个比他更大的值，如果不存在，就为0

```java
class Solution {
    public int[] dailyTemperatures(int[] temperatures) {
        int[] res = new int[temperatures.length];
        for(int i=0;i<temperatures.length;++i){
            int j = i + 1;
            while(j < temperatures.length && temperatures[j] <= temperatures[i]) ++j;
            if(j < temperatures.length) res[i] = j-i;
        }
        return res;
    }
}
```

时间复杂度：o(n^2)

空间复杂度：o(1)

## 单调栈

使用栈存储当前尚未找到下一个更大值的数据（实际上栈中存储数据为单调不增的），每遍历到下一个数据的时候，将其与栈顶元素进行比较，如果比栈顶元素大，就将栈顶元素出栈，不断执行这个过程，确保栈中存储的数据是一个单调递减的

下面以 [74,75,71,69,72,76] 为例介绍算法的执行过程

初始化：

monoStack = []

res = [0,0,0,0,0,0]

step1:

当前元素 74，栈为空，直接将74入栈

monoStack = [74]

step2:

当前元素75，栈顶元素74，75大于74，74出栈，同时更新res

此时栈为空，直接将75入栈

res[0] = 1

monoStack = [75]

step3:
当前元素71，栈顶元素75，71小于75，71入栈，等待结果

monoStack = [75,71]

step4:

当前元素69，栈顶元素71，69小于71，69入栈，等待结果

monoStack = [75,71,69]

step5:

当前元素72，栈顶元素69，72大于69，69出栈，并更新res

res[3] = 1

此时栈顶元素为71，72大于71，71出栈，更新res

res[2] = 2

此时栈顶元素75，75大于72，72入栈

monoStack = [75,72]

step6:

当前元素76，栈顶元素72，76大于72，72出栈，更新res

res[4] = 1

此时栈顶元素75，76大于75，75出栈，更新res

res[1] = 4

此时栈为空，76入栈

此时遍历结束，返回res = [1,4,2,1,1,0] 



```java
class Solution {
    public int[] dailyTemperatures(int[] temperatures) {
        // 找到数组中下一个大于该数字的索引
        // 如果直接暴力的话，那就是 o(n^2)，直接超时
        // 维护一个单调递减的栈，因为当出现递增的时候可以直接确定值，只有递减的时候需要进一步判断
        // （75，2）（71，3）（69，4）（72，5）
      	// 栈中实际存储的是元素在数组中的索引
        Stack<Integer> monoStack = new Stack<>();
        int l = temperatures.length;
        int[] res = new int[l];
        monoStack.push(0);
        for(int i=0;i<temperatures.length;++i){
            while(!monoStack.isEmpty() && temperatures[i]>temperatures[monoStack.peek()]){
                // 找到比他大的值，出栈
                int curr = monoStack.pop();
                res[curr] = i - curr;
            }
            monoStack.push(i);
        }
        return res;
    }
}
```

