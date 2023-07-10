---
title: 剑指 Offer II 040. 矩阵中最大的矩形
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '1019'
---
# 剑指 Offer II 040. 矩阵中最大的矩形

给定一个由 `0` 和 `1` 组成的矩阵 `matrix` ，找出只包含 `1` 的最大矩形，并返回其面积。

**注意：**此题 `matrix` 输入格式为一维 `01` 字符串数组。

<!-- more -->

## 脑筋急转弯+单调栈

```
1 0 1 0 0
1 0 1 1 1
1 1 1 1 1
1 0 0 1 0

从上至下逐层遍历，可以看成一个直方图
step1 
height = [1,0,1,0,0]

step2
height = [2,0,2,1,1]

step3
height = [3,1,3,2,2]

step4
height = [4,0,0,3,0]
```

然后使用 `剑指 Offer II 039. 直方图最大矩形面积` 进行计算即可

```java
class Solution {
    private static final Stack<Integer> stack = new Stack<>();
    static{
        stack.push(-1);
    }
    public int maximalRectangle(String[] matrix) {
        if(matrix.length == 0) return 0;
        int n = matrix[0].length();
        int[] height = new int[n];
        int res = 0;
        for(String row:matrix){
            for(int i=0;i<n;++i){
                int curr = row.charAt(i) - '0';
                if(curr == 0){
                    height[i] = 0;
                }else{
                    ++height[i];
                }
            }
            res = Math.max(res,largestRectangleArea(height));
        }
        return res;
    }

    // 转换成直方图求最大面积
    private int largestRectangleArea(int[] heights) {
        // 单调栈？如何进行维护，如何计算最大值？
        // 需要维护一个单调递增的栈，内部存储的是高度对应的索引
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



