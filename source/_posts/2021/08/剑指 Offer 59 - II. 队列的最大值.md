---
title: 剑指 Offer 59 - II. 队列的最大值
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 16a5
date: 2021-08-26
---
# 剑指 Offer 59 - II. 队列的最大值

请定义一个队列并实现函数 max_value 得到队列里的最大值，要求函数max_value、push_back 和 pop_front 的均摊时间复杂度都是O(1)。

若队列为空，pop_front 和 max_value 需要返回 -1

> 链接：https://leetcode-cn.com/problems/dui-lie-de-zui-da-zhi-lcof

<!-- more -->

## 单调队列

```java
class MaxQueue {
    Queue<Integer> q;
    Deque<Integer> d;
    // 假如输入序列 [1,4,3,5,2]
    /*
        输入1时，maxvalue 1
        输入4时，maxvalue 4 , 
        输入3时，maxvalue 3 ，此时d为 [4,3,]，q为 [1,4,3,5]
        输入5是，maxvalue 5 ，此时d为 []
    */
    public MaxQueue() {
        q = new LinkedList<Integer>();
        d = new LinkedList<Integer>();
    }
    
    public int max_value() {
        return d.isEmpty() ? -1 : d.peekFirst();
    }
    
    // 注意这是队列，不是栈，所以最后进来的一定最后出去，因此比它小的一定会优先其出去
    public void push_back(int value) {
        // 维护一个单调队列
        // 保持队首一定是当前的最大值
        while (!d.isEmpty() && d.peekLast() < value) {
            d.pollLast();
        }
        d.offerLast(value);
        q.offer(value);
        // System.out.println(d);
        // System.out.println(q);
    }
    
    public int pop_front() {
        if (q.isEmpty()) {
            return -1;
        }
        int ans = q.poll();
        if (ans == d.peekFirst()) {
            d.pollFirst();
        }
        return ans;
    }
}
```

