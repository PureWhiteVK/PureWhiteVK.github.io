---
title: 剑指 Offer 52. 两个链表的第一个公共节点
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: f7a3
---
# 剑指 Offer 52. 两个链表的第一个公共节点

输入两个链表，找出它们的第一个公共节点

<!-- more -->

## 哈希集合解法

首先比较简单的解法就是遍历一遍A和B，统计其中节点出现的次数，第一个发现出现过的节点就是公共节点了

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) {
 *         val = x;
 *         next = null;
 *     }
 * }
 */
public class Solution {
    public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
        // 思路一：统计每个Node出现的次数，如果遍历过程中发现有一个节点已经出现过了，说明重复，该节点就是重复节点
        Map<ListNode,Integer> map = new HashMap<>();
        ListNode a = headA,b=headB;
        while(a!=null){
            map.put(a,map.getOrDefault(a,0)+1);
            a = a.next;
        }
        while(b!=null){
            if(map.getOrDefault(b,0) != 0){
                return b;
            }
            map.put(b,map.getOrDefault(b,0)+1);
            b = b.next;
        }
        return null;
    }
}
```

稍微优化一点的就是使用集合(set)而不是映射（map）

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) {
 *         val = x;
 *         next = null;
 *     }
 * }
 */
public class Solution {
    public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
        Set<ListNode> set = new HashSet<>();
        ListNode a = headA,b=headB;
        while(a!=null){
            set.add(a);
            a = a.next;
        }
        while(b!=null){
            if(set.contains(b)){
                return b;
            }
            b = b.next;
        }
        return null;
    }
}
```

但是使用哈希计数的方式时间复杂度为o(m+n)，空间复杂度也为o(m+n)，其实还有空间复杂度为o(1)的算法

## 双指针

假设两个链表l1和l2，不妨设l1的长度大于l2，在遍历的过程

例如

​    4->1

​			 ->8->4->5

5->0->1

可以发现l1的长度是小于l2，此时使用双指针分别指向l1和l2的开始，二者同步运行，那么必定有一个会预先到达null，此时先到的说明已经遍历完短边，再切换成长边时两个指针就会有一个速度差，此时二者一定会相遇，就可以找到相交的部分（因为两个指针走过的距离是一致的）

l1的指针路径

4->1->8->4->5->5->0->1->8->4->5

l2的指针路径

5->0->1->8->4->5->4->1->8->4->5

可以发现，二者路径上是一定会重合的

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) {
 *         val = x;
 *         next = null;
 *     }
 * }
 */
public class Solution {
    public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
        if(headA == null || headB == null) return null;
        ListNode a = headA,b=headB;
        while(a != b){
            a = a == null ? headB : a.next;
            b = b == null ? headA : b.next;
        }
        return a;
    }
}
```

