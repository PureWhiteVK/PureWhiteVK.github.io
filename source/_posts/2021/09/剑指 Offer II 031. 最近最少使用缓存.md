---
title: 剑指 Offer II 031. 最近最少使用缓存
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 449b
---
# 剑指 Offer II 031. 最近最少使用缓存

运用所掌握的数据结构，设计和实现一个  LRU (Least Recently Used，最近最少使用) 缓存机制 。

实现 LRUCache 类：

- LRUCache(int capacity) 以正整数作为容量 capacity 初始化 LRU 缓存

- int get(int key) 如果关键字 key 存在于缓存中，则返回关键字的值，否则返回 -1 。

- void put(int key, int value) 如果关键字已经存在，则变更其数据值；如果关键字不存在，则插入该组「关键字-值」。当缓存容量达到上限时，它应该在写入新数据之前删除最久未使用的数据值，从而为新的数据值留出空间。

提示：

- 1 <= capacity <= 3000
- 0 <= key <= 10000
- 0 <= value <= 10<sup>5</sup>
- 最多调用 2 * 10<sup>5</sup> 次 get 和 put

**进阶**：是否可以在 `O(1)` 时间复杂度内完成这两种操作？

> 链接：https://leetcode-cn.com/problems/OrIXps

<!-- more -->

## 双向链表+哈希表

首先我们需要知道最近最少使用缓存（LRU cache）的思路，根据缓存内数据的使用情况，当缓存被占满的时候，优先替换掉最不常用的数据（也就是最近一段时间内都没有被使用的数据），而要想在o(1)的时间复杂度内完成插入和获取操作，首先获取十分简单，只需要使用哈希表即可，但是对于插入操作，由于cache存在容量限制，当容量满的时候需要选择最近不常使用的数据进行替换，单纯使用哈希表就不能在o(1)时间内进行删除并插入，因此我们考虑使用双向链表实现

为了实现o(1)时间复杂度内的检索，使用哈希表，同时为了实现o(1)时间内删除最近不常使用的数据，需要使用双向链表，哈希表中存储了双向链表的每一个节点，同时将数据的使用顺序组织称队列形式，每当一个数据最近被访问了，就将其放在队列的头部，每当缓存满的时候就优先删除队列尾部的数据，这样可以实现LRU，双向链表实现起来指针操作较多，容易出现错误，因此可以优先创建好链表头和链表尾，减少判断，提高代码正确性

```java
class LRUCache {
    private class Node{
        int key;
        int val;
        Node prev;
        Node next;
        Node(int k,int v){
            key = k;
            val = v;
        }
        Node(int k,int v,Node p,Node n){
            key = k;
            val = v;
            prev = p;
            next = n;
        }
    }

    private Node head,tail;
    private Map<Integer,Node> cache;
    private int capacity;

    public LRUCache(int _capacity) {
        capacity = _capacity;
        cache = new HashMap<>();
        // 预先创立好head和tail，防止代码执行过程中判断prev和next是否为空，提前创建好head和tail节点就可以保证不为空，减少出错几率
        head = new Node(-1,-1);
        tail = new Node(-1,-1);
        tail.prev = head;
        head.next = tail;
    }
    
    public int get(int key) {
        // System.out.println("get...");
        if(!cache.containsKey(key)){
            return -1;
        }
        int val = cache.get(key).val;
      	// 将最近访问的节点插入到队列头
        put(key,val);
        return val;
    }
    
    public void put(int key, int value) {
        // System.out.println("put...");
        // printList();
        if(cache.containsKey(key)){
            // 需要将map进行删除
            Node node = cache.get(key);
            node.prev.next = node.next;
            node.next.prev = node.prev;
        }
        // printList();
        // 将现在的节点插入到末尾
        Node prev = tail.prev;
        Node curr = new Node(key,value,prev,tail);
        prev.next = curr;
        tail.prev = curr;
        // printList();
        cache.put(key,curr);
        if(cache.size() > capacity){
            // 删除队列尾部的元素
            Node node = head.next;
            head.next = node.next;
            head.next.prev = head;
            cache.remove(node.key);
        }
        // printList();
    }

    private void printList(){
        StringBuilder sb = new StringBuilder();
        sb.append('[').append(' ');
        for(Node curr = head.next;curr != tail;curr = curr.next){
            sb.append('(').append(curr.key).append(',').append(curr.val).append(')').append(' ');
        }
        sb.append(']');
        System.out.println(sb);
    }

}

/**
 * Your LRUCache object will be instantiated and called as such:
 * LRUCache obj = new LRUCache(capacity);
 * int param_1 = obj.get(key);
 * obj.put(key,value);
 */
```

