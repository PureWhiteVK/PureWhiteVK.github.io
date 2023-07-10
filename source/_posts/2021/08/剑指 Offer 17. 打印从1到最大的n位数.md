---
title: 剑指 Offer 17. 打印从1到最大的n位数
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: '268'
---
# 剑指 Offer 17. 打印从1到最大的n位数

输入数字 `n`，按顺序打印出从 1 到最大的 n 位十进制数。比如输入 3，则打印出 1、2、3 一直到最大的 3 位数 999。

\*需要考虑大整数问题

<!-- more -->

## 字符串+全排列

实际上，本题的主要考察点是大数越界情况下的打印。需要解决一下三个问题

1. 如何表示大数（int？long？还是string）
2. 如何生成数字
   - 字符串大数加减法（模拟竖式计算）
   - 全排列生成

对于字符串模拟的可以直接使用BigInteger实现，这里不做详细介绍，重点介绍一下全排列解法

考虑位数为2的情况

1,2,...99

实际上可以将前面的0也算入，即00,01,02,...99，最后只需要在递归结束的时候删除前导0即可

便可以理解为全排列

```java
class Solution {
    List<String> res;
    int k;
    public List<String> printNumbers(int k){
        // 打印出k为的所有数字（从1开始)
        this.res = new LinkedList<>();
        this.k = k;
        helper(new LinkedList<>());
        return res;
    }

    private void helper(Deque<Character> deque){
        if(deque.size() == k){
            // 删除前导0
            StringBuilder sb = new StringBuilder();
            boolean leadingZero = true;
            for(char c : deque){
                if(c == '0'){
                    if(!leadingZero){
                        sb.append(c);
                    }
                }else{
                    sb.append(c);
                    leadingZero = false;
                }
            }
            if(sb.length() != 0){
                res.add(sb.toString());
            }
            return;
        }
        for(char i='0';i<='9';++i){
            deque.addLast(i);
            helper(deque);
            deque.removeLast();
        }
    }
}
```

