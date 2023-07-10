---
title: 剑指 Offer 41. 数据流中的中位数
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '9236'
---
# 剑指 Offer 41. 数据流中的中位数

如何得到一个数据流中的中位数？如果从数据流中读出奇数个数值，那么中位数就是所有数值排序之后位于中间的数值。如果从数据流中读出偶数个数值，那么中位数就是所有数值排序之后中间两个数的平均值。

例如，

[2,3,4] 的中位数是 3

[2,3] 的中位数是 (2 + 3) / 2 = 2.5

设计一个支持以下两种操作的数据结构：

- void addNum(int num) - 从数据流中添加一个整数到数据结构中。
- double findMedian() - 返回目前所有元素的中位数。

> 链接：https://leetcode-cn.com/problems/shu-ju-liu-zhong-de-zhong-wei-shu-lcof

<!-- more -->

## 优先队列

首先想到的是使用二分查找，维护一个有序序列，这样每次调用findMedian就可以在o(1)时间复杂度内返回，但是对于插入而言，则需要o(n)的时间复杂度，首先使用二分查找找到元素待插入的位置，然后需要将每个元素向后移动，这样插入的时间复杂度就会很高，实际效果并不好。

实际上可以使用优先队列进行优化，由于优先队列队首元素一定是该队中的最大（最小）值，那么可以将数据流排序后分成两部分（长度均分），其中较大的那一部分存储在小根堆中，较小的一部分存储在大根堆中，这样插入的时间复杂度为o(logn)，查找中位数时间复杂度为o(1)

既然要保持两个队列之间大小差距不超过1，在插入元素时需要考虑一下

- 当maxHeap的大小和minHeap的大小一致的时候

  先将元素插入到minHeap中，然后将minHeap的队首元素插入到maxHeap（这样会使得maxHeap的大小比minHeap大1）

- 当maxHeap大小比minHeap的大小大1的时候

  先将元素插入到maxHeap中，然后将maxHeap的队首元素插入到minHeap中（这样就使得maxHeap的大小和minHeap一样大的）

```java
class MedianFinder {
    PriorityQueue<Integer> A, B;
    public MedianFinder() {
        minHeap = new PriorityQueue<>(); // 小顶堆，保存较大的一半
        maxHeap = new PriorityQueue<>((x, y) -> (y - x)); // 大顶堆，保存较小的一半
    }
    public void addNum(int num) {
        if(maxHeap.size() > minHeap.size()) {
            // 将A中最小的插入B内
            maxHeap.add(num);
            minHeap.add(maxHeap.poll());
        } else {
            // 此时A的大小一定会比B多1，中位数就会位于A内
            // 当两者大小相等的时候
            // 默认插入较小的那一批，再将较小的中的最大号插入较大的一批中
            minHeap.add(num);
            maxHeap.add(minHeap.poll());
        }
    }
    public double findMedian() {
        return maxHeap.size() != minHeap.size() ? maxHeap.peek() : (maxHeap.peek() + minHeap.peek()) / 2.0;
    }
}
```

