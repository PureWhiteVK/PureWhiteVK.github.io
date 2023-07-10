---
title: 剑指 Offer 62. 圆圈中最后剩下的数字
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '8994'
---
# 剑指 Offer 62. 圆圈中最后剩下的数字


0,1,···,n-1这n个数字排成一个圆圈，从数字0开始，每次从这个圆圈里删除第m个数字（删除后从下一个数字开始计数）。求出这个圆圈里剩下的最后一个数字。

例如，0、1、2、3、4这5个数字组成一个圆圈，从数字0开始每次删除第3个数字，则删除的前4个数字依次是2、0、4、1，因此最后剩下的数字是3。

> [剑指 Offer 62. 圆圈中最后剩下的数字 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/yuan-quan-zhong-zui-hou-sheng-xia-de-shu-zi-lcof/)
>
> 这一题实际上就是约瑟夫环（Joseph circle）

<!-- more -->

## 模拟（1）

最开始想到的是使用双端队列，直接进行模拟

```java
class Solution {
    public int lastRemaining(int n, int m) {
        // 如何直接进行模拟的话，所需的时间复杂度为o(m*n)太高了，不合适
        // 可以进行倒退，假设最后一个剩下的数为k，是否可以计算出其前一个被删除的是哪一个？
        // 第一次删除对应的索引 -> (0+m-1) % n = k1
        // 第二次删除对应的索引 -> ((k1+1)+(m-1)) % n-1 = k2
        Deque<Integer> deque = new LinkedList<>();
        for(int i=0;i<n;++i){
            deque.offerLast(i);
        }
        while(n>1){
          int minOps = (m-1+n)%n;
          while(minOps>0){
            deque.offerLast(deque.pollFirst());
            --minOps;
          }
          deque.pollFirst();
          --n;
        }
      	return deque.pollFirst();
    }
}
```

时间复杂度为o(n^2)必定会超时的

## 模拟（2）

同样可以使用ArrayList进行模拟

```java
class Solution {
    public int lastRemaining(int n, int m) {
        // 如何直接进行模拟的话，所需的时间复杂度为o(m*n)太高了，不合适
        // 可以进行倒退，假设最后一个剩下的数为k，是否可以计算出其前一个被删除的是哪一个？
        // 第一次删除对应的索引 -> (0+m-1) % n = k1
        // 第二次删除对应的索引 -> ((k1+1)+(m-1)) % n-1 = k2
        ArrayList<Integer> list = new ArrayList<>();
        for(int i=0;i<n;++i){
            list.add(i);
        }
        int c = 0;
        while(n>1){
            c = (c + m - 1) % n;
            list.remove(c);
            --n;
        }
        return list.get(0);
    }
}
```

由于删除操作需要o(n)时间复杂度，最终时间复杂度为o(n^2)，空间复杂度为o(n)，勉强是可行的

## 数学

实际上我们从双端队列的模拟运行结果可以看出，可以倒推出最后以被删除的数的下标，以n=5,m=3为例

初始状态 list = [0,1,2,3,4]，3所在位置为3

step1:

list = [3,4,0,1], drop 2，3所在位置为0

step2:

list = [1,3,4], drop 0，3所在位置为1

step3:

list = [1,3], drop 4， 3所在位置为1

step4:

list = [3], drop 1，3所在位置为0



然后我们从最后剩下的 3 倒着看，我们可以**反向推出这个数字在之前每个轮次的位置**。

最后剩下的 3 的下标是 0。

第四轮反推，补上 m 个位置，然后模上当时的数组大小 2，位置是(0 + 3) % 2 = 1。

第三轮反推，补上 m 个位置，然后模上当时的数组大小 3，位置是(1 + 3) % 3 = 1。

第二轮反推，补上 m 个位置，然后模上当时的数组大小 4，位置是(1 + 3) % 4 = 0。

第一轮反推，补上 m 个位置，然后模上当时的数组大小 5，位置是(0 + 3) % 5 = 3。

所以最终剩下的数字的下标就是3。因为数组是从0开始的，所以最终的答案就是3。

总结一下反推的过程，就是 (当前index + m) % 上一轮剩余数字的个数。

```java
class Solution {
    public int lastRemaining(int n, int m) {
        int ans = 0;
        // 最后一轮剩下2个人，所以从2开始反推
        for (int i = 2; i <= n; i++) {
            ans = (ans + m) % i;
        }
        return ans;
    }
}
```

