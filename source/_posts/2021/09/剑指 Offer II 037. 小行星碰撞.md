---
title: 剑指 Offer II 037. 小行星碰撞
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: d4b9
date: 2021-09-24
---
# 剑指 Offer II 037. 小行星碰撞

给定一个整数数组 asteroids，表示在同一行的小行星。

对于数组中的每一个元素，其绝对值表示小行星的大小，正负表示小行星的移动方向（正表示向右移动，负表示向左移动）。每一颗小行星以相同的速度移动。

找出碰撞后剩下的所有小行星。碰撞规则：两个行星相互碰撞，较小的行星会爆炸。如果两颗行星大小相同，则两颗行星都会爆炸。两颗移动方向相同的行星，永远不会发生碰撞。

提示：

- 2 <= asteroids.length <= 10<sup>4</sup>
- -1000 <= asteroids[i] <= 1000
- asteroids[i] != 0

> 链接：https://leetcode-cn.com/problems/XagZNi

<!-- more -->

## 模拟+栈

只需要使用用例模拟一下就可以很快知道如何实现了，

我们从左往右进行遍历，在遍历的过程使用栈存储向右移动的小行星，如果碰到一个向左的小行星，此时检查栈是否为空，如果不为空，说明一定会发生碰撞，此时再根据规则进行消除即可，最终结果一定是向左移动的小行星在向右移动的小行星的左侧，否则就会发生碰撞

实际上这个思想已经有点类似于单调栈了（栈中小行星都是同一方向的，碰到不同方向的就会发生碰撞）

```java
class Solution {
    public int[] asteroidCollision(int[] asteroids) {
        // 模拟？
        Stack<Integer> right = new Stack<>(),left = new Stack<>();
        for(int i:asteroids){
            // 从左向右遍历
            if(i>0){
                right.push(i);
            }else{
                // 存活确认
                if(right.isEmpty()) left.push(i);
                else{
                    // 同右侧的进行对撞
                    while(!right.isEmpty() && Math.abs(i) > Math.abs(right.peek()) ){
                        right.pop();
                    }
                    if(right.isEmpty()) left.push(i);
                    else if(Math.abs(i) == Math.abs(right.peek())) right.pop();
                     
                }
            }
        }
        int[] res = new int[right.size()+left.size()];
        int i = res.length;
      	// 由于使用栈进行存储，需要倒着填值，且一定是right在右，即优先填充right
        while(!right.isEmpty()) res[--i] = right.pop();
        while(!left.isEmpty()) res[--i] = left.pop();
        return res;
    }
}
```

