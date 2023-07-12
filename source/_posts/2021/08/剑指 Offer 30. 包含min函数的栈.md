---
title: 剑指 Offer 30. 包含min函数的栈
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: d44e
date: 2021-08-07
---
# 剑指 Offer 30. 包含min函数的栈

定义栈的数据结构，请在该类型中实现一个能够得到栈的最小元素的 min 函数在该栈中，调用 min、push 及 pop 的时间复杂度都是 O(1)。

<!-- more -->

## 单调栈

由于需要实现O(1)时间复杂度的最小元素查询，需要再维护一个单调栈，不断存储加入的序列中的最小值

```java
class MinStack {
    private Stack<Integer> stack;
    private Stack<Integer> monoStack;
    /** initialize your data structure here. */
    public MinStack() {
        stack = new Stack<>();
        monoStack = new Stack<>();
    }
    
    public void push(int x) {
        // 需要实现单调栈？
        stack.push(x);
        if(monoStack.empty() || x <= monoStack.peek()){
            monoStack.push(x);
        }
    }
    
    public void pop() {
        // pop的时候需要更新minValue，因为可能把最小值给pop掉了
        if(stack.pop() == monoStack.peek()){
            monoStack.pop();
        }
    }
    
    public int top() {
        return stack.peek();
    }
    
    public int min() {
        return monoStack.peek();
    }
}

/**
 * Your MinStack object will be instantiated and called as such:
 * MinStack obj = new MinStack();
 * obj.push(x);
 * obj.pop();
 * int param_3 = obj.top();
 * int param_4 = obj.min();
 */
```

