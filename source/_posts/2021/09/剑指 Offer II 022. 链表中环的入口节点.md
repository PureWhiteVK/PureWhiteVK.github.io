---
title: 剑指 Offer II 022. 链表中环的入口节点
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 6dcb
date: 2021-09-17
---
# 剑指 Offer II 022. 链表中环的入口节点

给定一个链表，返回链表开始入环的第一个节点。 从链表的头节点开始沿着 next 指针进入环的第一个节点为环的入口节点。如果链表无环，则返回 null。

为了表示给定链表中的环，我们使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 pos 是 -1，则在该链表中没有环。注意，pos 仅仅是用于标识环的情况，并不会作为参数传递到函数中。

说明：不允许修改给定的链表。

> 链接：https://leetcode-cn.com/problems/c32eOV

<!-- more -->

## 哈希表

```java
/**
 * Definition for singly-linked list.
 * class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) {
 *         val = x;
 *         next = null;
 *     }
 * }
 */
public class Solution {
    public ListNode detectCycle(ListNode head) {
        // 直接使用哈希表记录一下哪个节点被访问过了，当再一次访问到这个节点的时候就是环的入口
        Map<ListNode,Boolean> notVisited = new HashMap<>();
        while(head!= null && notVisited.getOrDefault(head,true)){
            notVisited.put(head,false);
            head = head.next;
        }
        return head;
    }
}
```

## 快慢指针

```java
/**
 * Definition for singly-linked list.
 * class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) {
 *         val = x;
 *         next = null;
 *     }
 * }
 */
public class Solution {
    public ListNode detectCycle(ListNode head) {
        ListNode slow = head;
        ListNode fast = head;
        while (fast != null && fast.next != null) {
            // 慢的走的距离为 x+y
            // 快的走的距离为 x+y + n(y+z)
            // 且有 n(y+z) = x+y
            // x = n(y+z) - y
            // 也就是说，如果此时放一个指针在head处让他和slow同时前进，当这个指针和slow指针相遇的时候，就一定是环的入口x
            slow = slow.next;
            fast = fast.next.next;
            if (slow == fast) {
                ListNode point = head;
                while (point != slow) {
                    point = point.next;
                    slow = slow.next;
                }
                return point;
            }
        }
        return null;
    }
}
```

