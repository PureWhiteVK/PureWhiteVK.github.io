---
title: 剑指 Offer II 039. 直方图最大矩形面积
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 5eb0
date: 2021-11-10
---
# 剑指 Offer II 039. 直方图最大矩形面积

给定非负整数数组 heights ，数组中的数字用来表示柱状图中各个柱子的高度。每个柱子彼此相邻，且宽度为 1 。

求在该柱状图中，能够勾勒出来的矩形的最大面积。

**提示：**

- 1 <= heights.length <=10<sup>5</sup>
- 0 <= heights[i] <= 10<sup>4</sup>

> 链接：https://leetcode-cn.com/problems/0ynMMM

<!-- more -->

## 单调栈

如果采用暴力的话，我们需要以所有高度为高，计算矩形以这个高度可以达到的最大面积，然后求出最大面积，这种算法的时间复杂度为o(n^2)，需要确认有多少连续的满足当前高度

这个题实际上和前两题思路类似，都是使用栈维护一个单调数组

```java
class Solution {
    public int largestRectangleArea(int[] heights) {
        // 单调栈？如何进行维护，如何计算最大值？
        // 需要维护一个单调递增的栈，内部存储的是高度对应的索引
        Stack<Integer> stack = new Stack<>();
        stack.push(-1);
        int res = 0;
        for(int i=0;i<heights.length;++i){
            // 以栈顶元素对应的高度作为矩形的计算高度，
            // 那么其对应的矩形的宽度就是左边第一个小于该高度的索引到右边第一个大于该高度的索引
            while(stack.peek() != -1 && heights[i] <= heights[stack.peek()] ){
                int height = heights[stack.pop()];
                int width = i - stack.peek() - 1;
                res = Math.max(res,height*width);
            }
            stack.push(i);
        }
        // 数组遍历完成，此时栈有可能不为空，那么此时右边界就变成了heights.length
        while(!stack.isEmpty() && stack.peek() != -1){
            int height = heights[stack.pop()];
            int width = heights.length - stack.peek() - 1;
            res = Math.max(res,height*width);
        }
        return res;
    }
}
```

过了几个月再来看又有点没办法理解了，还是写一个例子帮助理解

初始化:

heights = [2,1,5,6,2,3]

stack = [-1]

res = 0

step1:

索引为0，当前高度为2，栈顶元素为-1，直接进栈

stack = [-1,0]

step2:

索引为1，当前高度为1，栈顶元素为0，对应高度为1，此时高度小于栈顶对应高度，

出栈，计算面积，高度为栈顶元素高度2，宽度为1，更新res = 1

然后再进栈

stack = [-1,1]

step3:

索引为2，当前高度为5，栈顶元素为1，对应高度为1，此时高度大于栈顶对应高度，直接进栈

stack = [-1,1,2]

step4:

索引为3，当前高度为6，栈顶元素为2，对应高度为5，此时高度大于栈顶对应高度，直接进栈

stack = [-1,1,2,3]

step5:

索引为4，当前高度为2，栈顶元素为3，对应高度为6，此时高度小于栈顶对应高度，

出栈，计算面积，高度为栈顶元素高度6，宽度1，更新res = 6

stack = [-1,1,2]

出栈，计算面积，高度为栈顶元素高度5，宽度2，更新res = 10

stack = [-1,1]

此时高度大于栈顶对应高度，直接进栈

stack = [-1,1,4]

step6:

索引为5，当前高度为3，栈顶元素为4，对应高度为2，此时高度大于栈顶对应高度，直接进栈

stack = [-1,1,4,5]

此时遍历结束，但是栈不为空，此时右边界为height.length

出栈，计算面积，高度为栈顶元素高度3，宽度1，res = 10

出栈，计算面积，高度为栈顶元素高度2，宽度2，res = 10

出栈，计算面积，高度为栈顶元素高度1，宽度5，res = 10

此时栈顶为-1，结束

最终直方图中最大面积为10

