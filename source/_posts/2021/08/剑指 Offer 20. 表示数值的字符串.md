---
title: 剑指 Offer 20. 表示数值的字符串
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 97fe
---
# 剑指 Offer 20. 表示数值的字符串

请实现一个函数用来判断字符串是否表示数值（包括整数和小数）。

**数值**（按顺序）可以分成以下几个部分：

1. 若干空格

2. 一个 小数 或者 整数

3. （可选）一个 'e' 或 'E' ，后面跟着一个 整数

4. 若干空格

**小数**（按顺序）可以分成以下几个部分：

1. （可选）一个符号字符（'+' 或 '-'）

2. 下述格式之一：

   1. 至少一位数字，后面跟着一个点 '.'

   2. 至少一位数字，后面跟着一个点 '.' ，后面再跟着至少一位数字

   3. 一个点 '.' ，后面跟着至少一位数字

**整数**（按顺序）可以分成以下几个部分：

1. （可选）一个符号字符（'+' 或 '-'）
2. 至少一位数字

部分数值列举如下：

- ["+100", "5e2", "-123", "3.1416", "-1E-16", "0123"]

部分非数值列举如下：

- ["12e", "1a3.14", "1.2.3", "+-5", "12e+5.4"]

> 链接：https://leetcode-cn.com/problems/biao-shi-shu-zhi-de-zi-fu-chuan-lcof

<!-- more -->

## 有限状态机

参考别人的状态图

<img src="剑指 Offer 20. 表示数值的字符串/dfa.png" alt="dfa" style="zoom:50%;" />

实现细节看代码就可以了，switch实现

```java
class Solution {
    enum State{
        s0,s1,s2,s3,s4,s5,s6,s7,s8
    }
    public boolean isNumber(String str) {
        // 有限状态机，没什么好说的，只要能正确归纳出有限状态机就可以写出来
        State s = State.s0;
        char[] chArr = str.toCharArray();
        int next = 0;
        int length = str.length();
        while(next < length){
            char curr = chArr[next];
            ++next;
            // System.out.println("curr State:"+s+" "+curr);
            switch(s){
                case s0:{
                    if(curr == ' '){
                        s = State.s0;
                    }else if(curr == '+' || curr == '-'){
                        s = State.s1;
                    }else if(curr >= '0' && curr <= '9'){
                        s = State.s2;
                    }else if(curr == '.'){
                        s = State.s4;
                    }else{
                        return false;
                    }
                    break;
                }
                case s1:{
                    if(curr == '.'){
                        s = State.s4;
                    }else if(curr >= '0' && curr <= '9'){
                        s = State.s2;
                    }else{
                        return false;
                    }
                    break;
                }
                case s2:{
                    if(curr == 'e' || curr == 'E'){
                        s = State.s5;
                    }else if(curr >= '0' && curr <= '9'){
                        s = State.s2;
                    }else if(curr == '.'){
                        s = State.s3;
                    }else if(curr == ' '){
                        s = State.s8;
                    }else{
                        return false;
                    }
                    break;
                }
                case s3:{
                    if(curr == 'e' || curr == 'E'){
                        s = State.s5;
                    }else if(curr >= '0' && curr <= '9'){
                        s = State.s3;
                    }else if(curr == ' '){
                        s = State.s8;
                    }else{
                        return false;
                    }
                    break;
                }
                case s4:{
                    if(curr >= '0' && curr <= '9'){
                        s = State.s3;
                    }else{
                        return false;
                    }
                    break;
                }
                case s5:{
                    if(curr == '+' || curr == '-'){
                        s = State.s6;
                    }else if(curr >= '0' && curr <= '9'){
                        s = State.s7;
                    }else{
                        return false;
                    }
                    break;
                }
                case s6:{
                    if(curr >= '0' && curr <= '9'){
                        s = State.s7;
                    }else{
                        return false;
                    }
                    break;
                }
                case s7:{
                    if(curr >= '0' && curr <= '9'){
                        s = State.s7;
                    }else if(curr ==' '){
                        s = State.s8;
                    }else{
                        return false;
                    }
                    break;
                }
                case s8:{
                    if(curr == ' '){
                        s = State.s8;
                    }else{
                        return false;
                    }
                    break;
                }
            }
        }
        // System.out.println("curr State:"+s);
        if(s == State.s2 || s == State.s3 || s == State.s7 || s == State.s8){
            return true;
        }
        return false;
    }
}
```

