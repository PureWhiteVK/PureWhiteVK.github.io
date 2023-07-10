---
title: LCP 07. 传递信息
mathjax: true
tags:
  - 算法
category: LeetCode刷题记录
abbrlink: 1a91
---
# LCP 07. 传递信息

小朋友 A 在和 ta 的小伙伴们玩传信息游戏，游戏规则如下：

有 n 名玩家，所有玩家编号分别为 0 ～ n-1，其中小朋友 A 的编号为 0
每个玩家都有固定的若干个可传信息的其他玩家（也可能没有）。传信息的关系是单向的（比如 A 可以向 B 传信息，但 B 不能向 A 传信息）。
每轮信息必须需要传递给另一个人，且信息可重复经过同一个人
给定总玩家数 n，以及按 [玩家编号,对应可传递玩家编号] 关系组成的二维数组 relation。返回信息从小 A (编号 0 ) 经过 k 轮传递到编号为 n-1 的小伙伴处的方案数；若不能到达，返回 0。

> 链接：https://leetcode-cn.com/problems/chuan-di-xin-xi

<!-- more -->

## DFS

经典图论题，没什么好说的，直接暴力，遍历所有可行的路径然后开始走，同时记录步数，当步数等于k且终止节点是n-1时将结果加1，最后返回总个数就行

```java
class Solution {
    int res,k,n;
    Map<Integer,List<Integer>> map;
    public int numWays(int n, int[][] relation, int k) {
        this.res = 0;
        this.k = k;
        this.n = n;
        this.map = new HashMap<>();
        for(int[] r:relation){
            List<Integer> l = map.getOrDefault(r[0],new ArrayList<>());
            l.add(r[1]);
            map.put(r[0],l);
        }
        dfs(0,0);
        return res;
    }

    private void dfs(int node,int step){
        if(step == k){
            if(node == n-1){
                ++res;
            }
            return;
        }
        for(int v:map.getOrDefault(node,new ArrayList<>())){
            dfs(v,step+1);
        }
    }
}
```



## BFS

可以用dfs，那么bfs也同样适用，思路和dfs一致，使用队列进行，同时注意记录当前step数即可

```java
class Solution {
    public int numWays(int n, int[][] relation, int k) {
        Map<Integer,List<Integer>> map = new HashMap<>();
        for(int[] r:relation){
            List<Integer> l = map.getOrDefault(r[0],new ArrayList<>());
            l.add(r[1]);
            map.put(r[0],l);
        }

        Queue<Integer> queue = new LinkedList<>();
        queue.offer(0);
        for(int i=0;i<k;++i){
            int size = queue.size();
            // queue的前size个元素是当前层的，剩下的都是下一层新增加的
            for(int j=0;j<size;++j){
                int currNode = queue.poll();
                for(int v:map.getOrDefault(currNode,new ArrayList<>())){
                    queue.offer(v);
                }
            }
        }
        int res = 0;
        while(queue.size()!=0){
            if(queue.poll() == n-1){
                ++res;
            }
        }
        // 最后统计里面有多少个是4就行了
        return res;
    }
}
```



## 动态规划

除了暴力之外，这个题还可以使用动态规划来做，使用dp[i,j]存储第i步时可到达结点j的方案数，初始条件dp[0,0]为1，之后遍历所有边数，状态转移方程：
$$
dp[i,j] = dp[i,j] + \sum ^{n} _{k=1} dp[i-1,k]
$$
其中k为所有可达j的结点

```java
class Solution {
    public int numWays(int n, int[][] relation, int k) {
        // 图论问题+动态规划
        int[][] dp = new int[k+1][n];
        Map<Integer,List<Integer>> map = new HashMap<>();
        for(int[] r:relation){
            // 存储能到达该节点的所有节点
            List<Integer> l = map.getOrDefault(r[1],new ArrayList<>());
            l.add(r[0]);
            map.put(r[1],l);
        }
        dp[0][0] = 1;
        // 输出临接表
        // System.out.println(map);
        for(int i=1;i<=k;++i){
            // dp[i][j]代表第i步到达节点j的次数
            for(int j=0;j<n;++j){
                for(int v:map.getOrDefault(j,new ArrayList<>())){
                    dp[i][j] += dp[i-1][v];
                }
            }
        }
        return dp[k][n-1];
    }
}
```

## 动态规划优化（状态压缩）

从状态转移方程中可以很明显的发现，dp[i,j]仅与前一个状态dp[i-1,k]有关，因此可以只使用一个一维数组进行更新，从而节省空间

```java
class Solution {
    public int numWays(int n, int[][] relation, int k) {
        // 图论问题+动态规划
        int[] dp = new int[n];
        Map<Integer,List<Integer>> map = new HashMap<>();
        for(int[] r:relation){
            // 存储能到达该节点的所有节点
            List<Integer> l = map.getOrDefault(r[1],new ArrayList<>());
            l.add(r[0]);
            map.put(r[1],l);
        }
        dp[0] = 1;
        // 输出临接表
        // System.out.println(map);
        for(int i=0;i<k;++i){
            // dp[i][j]代表第i步到达节点j的次数
          	// 由于在更新的时候会使用原来的dp数组，因此遍历边的过程中不能改变原有的dp数组，需要新建一个数组来存储更新值，这个地方需要额外注意
            int[] next = new int[n];
            for(int j=0;j<n;++j){
                for(int v:map.getOrDefault(j,new ArrayList<>())){
                    next[j] += dp[v];
                }
            }
            dp = next;
        }
        return dp[n-1];
    }
}
```



## 后记

这一题很经典，包含了图论和动态规划，但LeetCode将其难度划为简单，也说明这个题是程序员的基本功，需要掌握扎实