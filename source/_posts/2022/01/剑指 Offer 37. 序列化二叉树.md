---
title: 剑指 Offer 37. 序列化二叉树
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: bef
---
# 剑指 Offer 37. 序列化二叉树

请实现两个函数，分别用来序列化和反序列化二叉树。

你需要设计一个算法来实现二叉树的序列化与反序列化。这里不限定你的序列 / 反序列化算法执行逻辑，你只需要保证一个二叉树可以被序列化为一个字符串并且将这个字符串反序列化为原始的树结构。

提示：输入输出格式与 LeetCode 目前使用的方式一致，详情请参阅 LeetCode 序列化二叉树的格式。你并非必须采取这种方式，你也可以采用其他的方法解决这个问题。

> 链接：https://leetcode-cn.com/problems/xu-lie-hua-er-cha-shu-lcof

<!-- more -->

## 层序遍历实现

层序遍历将二叉树转换成字符串没什么难度，之前也写过很多了，这里不赘述，直接上代码

```java
public class Codec {
    private Queue<TreeNode> queue;

    public Codec(){
        queue = new LinkedList<>();
    }
    // Encodes a tree to a single string.
    public String serialize(TreeNode root) {
        // 层序遍历进行序列化
        StringBuilder sb = new StringBuilder();
        sb.append('[');
        queue.offer(root);
        while(queue.size()!=0){
            int size = queue.size();
            while(size>0){
                TreeNode curr = queue.poll();
                if(curr==null){
                    sb.append("null").append(',');
                }else{
                    sb.append(curr.val).append(',');
                    queue.offer(curr.left);
                    queue.offer(curr.right);
                }
                --size;
            }
        }
        sb.deleteCharAt(sb.length()-1);
        sb.append(']');
        return sb.toString();
    }
}
```

实际难点在于如何对字符串进行反序列化

下面以一个例子来介绍反序列化过程

<img src="Image/serialize-binary-tree.png" style="zoom:50%;" />

首先这棵树序列话结果如下

[1,2,null,3,4,null,null,7,null,8,9,null,null,11,10,null,null,null.null]

计算流程如下

对于一个不为null的节点，其一定包含两个孩子节点（不管是有值还是null）

因此可以统计孩子节点的个数，并使用队列存储前一层的节点

```java
// Decodes your encoded data to tree.
public TreeNode deserialize(String data) {
  // 如何将层序遍历结果还原成一棵树
  // 根据第一个值的情况，可以计算出当前层次包含的节点数
  // java的substring是区间是左闭右开的
  // 首先划分字符串
  String[] nodes = data.substring(1,data.length()-1).split(",");
  String rootVal = nodes[0];
  int length = nodes.length;
  if(rootVal.equals("null")) return null;
  TreeNode root = new TreeNode(Integer.parseInt(rootVal));
  queue.offer(root);
  int i=1;
  int childCount = 2;
  int nextChildCount = 0;
  TreeNode parent = null;
  TreeNode node = null;
  while(i<length){
    while(childCount > 0){
      String nodeVal = nodes[i];
      if(nodeVal.equals("null")){
        node = null;
      }else{
        node = new TreeNode(Integer.parseInt(nodeVal));
        nextChildCount += 2;
        // 将其将入下一轮
        queue.offer(node);
      }
      // 由于不为空的节点一定包含两个孩子节点，偶数代表左孩子，奇数代表右孩子
      if((childCount & 1) == 0){
        // 偶数说明是左孩子
        parent = queue.poll();
        parent.left = node;
      }else {
        parent.right = node;
      }
      --childCount;
      ++i;
    }
    childCount = nextChildCount;
    nextChildCount = 0;
  }
  return root;
}
```



