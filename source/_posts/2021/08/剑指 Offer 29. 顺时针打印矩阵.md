---
title: 剑指 Offer 29. 顺时针打印矩阵
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 703f
date: 2021-08-07
---
# 剑指 Offer 29. 顺时针打印矩阵

输入一个矩阵，按照从外向里以顺时针的顺序依次打印出每一个数字。

<!-- more -->

## 模拟

这个题没什么好说的，对于矩阵顺时针而言，一共就四个方向，水平向左，竖直向下，水平向右， 竖直向上，四个步骤不断重复，因此只需要模拟这四个过程，遍历的过程中将结果加入到res中就行

使用(y,x)表示当前访问矩阵的坐标，初始化为(0,0)，同时限制访问的边界 xLeft,xRight,yTop,yBottom

每当执行一个步骤之后，需要更新对应的边界

- 水平向左：该行访问完成，yTop向下走一行
- 竖直向下：该列访问完成，xRight向左走一行
- 水平向右：该行访问完成，yBottom向上走一行
- 竖直向上：该列访问完成，xLeft向右走一行

同时使用i记录当前坐标在一维数组中的下标，每走过一个便自增，每执行一步就需要判断是否完成遍历

```java
class Solution {
    public int[] spiralOrder(int[][] matrix) {
        /*
            1 2 3
            4 5 6   -> 1,2,3,6,9,8,7,4,5
            7 8 9

            1  2  3  4 
            5  6  7  8   -> 1,2,3,4,8,12,11,10,9,5,6
            9  10 11 12
         */
        if(matrix.length == 0){
            return new int[0];
        }
        int length = matrix.length * matrix[0].length;
        int[] res = new int[length];
        // 遍历顺序
        // (0,0) (0,1) (0,2) (1,2) (2,2) (2,1) (2,0) (1,0) (1,1)
        int i=0,x=0,y=0;
        int xLeft = 0,xRight = matrix[0].length-1;
        int yTop = 0,yBottom = matrix.length-1;
        while(true){
            // 首先水平向左
            // System.out.println("step1");
            for(x=xLeft;x<=xRight;++x){
                // printCoord(y,x);
                res[i++] = matrix[y][x]; 
            }
            ++yTop;
            --x;
            if(i == length) break;
            // 竖直向下
            // System.out.println("step2");
            for(y=yTop;y<=yBottom;++y){
                // printCoord(y,x);
                res[i++] = matrix[y][x];
            }
            --xRight;
            --y;
            if(i == length) break;
          	// 水平向右
            // System.out.println("step3");
            for(x=xRight;x >= xLeft;--x){
                // printCoord(y,x);
                res[i++] = matrix[y][x];
            }
            --yBottom;
            ++x;
            if(i == length) break;
          	// 竖直向上
            // System.out.println("step4");
            for(y=yBottom;y >= yTop;--y){
                // printCoord(y,x);
                res[i++] = matrix[y][x];
            }
            ++xLeft;
            ++y;
            if(i == length) break;
        }
        return res;
    }

    private void printCoord(int x,int y){
        System.out.println("("+x+","+y+")");
    }
}
```

