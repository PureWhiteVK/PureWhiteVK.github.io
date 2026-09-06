---
title: Git 常用操作
mathjax: false
abbrlink: 8de3
date: 2024-09-07 09:59:28
tags:
- git
category: 技术笔记
---

Git 日常用到的命令不少，但真正常碰的，基本都围绕一条主线：把代码从远端拉下来，开分支修改，跟上远端的最新提交，再推回去。单独查某个命令的用法很容易，难的是搞清楚这些命令应该按什么顺序出现。这篇笔记用两个本地仓库把这条主线完整跑一遍，覆盖 clone、fetch、pull --rebase、branch、worktree、rebase、push，以及浅克隆、LFS 和多个 remote 等场景。

<!-- more -->

# 场景设置

场景设定为一个由 alice 和 bob 共同维护的小项目，仓库里只有一个 `README.md`，方便直接观察提交在本地和远端之间如何流动。

下面的流程在本地用三个目录完成，不依赖 GitHub 账号和网络：

```text
git-demo/
├─ team.git    线上仓库（bare）
├─ alice/      开发者 A
└─ bob/        开发者 B
```

```sh
mkdir D:\git-demo
cd D:\git-demo
git init --bare --initial-branch=main team.git
```

后面命令中的 `file:///<path-to-team.git>` 是占位符，以本示例来说就是 `file:///D:/git-demo/team.git`。

`team.git` 是裸仓库，没有工作区，角色和 GitHub/GitLab 上的仓库一致。

alice 是项目的初始开发者，先在本地初始化仓库，再把初始代码推送到 `team.git`：

```sh
mkdir alice
cd alice
git init --initial-branch=main
git config user.name alice
git config user.email alice@example.com
git remote add origin file:///<path-to-team.git>
```

新建 `README.md`（内容随意），提交并推送：

```sh
git add README.md
git commit -m "init: add README"
git push -u origin main
```

`-u` 会把 `origin/main` 设为当前分支的上游，之后直接 `git push` / `git pull` 即可。

到这里，`team.git` 的 main 上有了第一个提交，alice 的本地 main 和 `origin/main` 也指向同一个提交，项目正式建立。

# clone、fetch、pull

bob 加入项目的第一步是 clone。clone 完成时，bob 的本地 main、`origin/main` 和 `team.git` 的 main 都指向同一个提交：

```sh
cd ..
git clone file:///<path-to-team.git> bob
cd bob
git config user.name bob
git config user.email bob@example.com
```

bob 修改 `README.md` 后推送：

```sh
git add README.md
git commit -m "bob: tweak readme"
git push
```

推送后，远端 main 前进了一个提交。与此同时，alice 没有先同步，而是直接基于旧版本改了一处并本地提交。此时远端和 alice 本地各有一个新提交，谁都不包含对方的改动：

```sh
cd ../alice
# 修改 README.md
git add README.md
git commit -m "alice: rewrite heading"
```

执行 fetch 并查看状态：

```sh
git fetch origin
git status -sb
```

```sh
## main...origin/main [ahead 1, behind 1]
```

`ahead 1, behind 1` 表示本地和远端各有一个对方没有的提交。fetch 只更新了 `origin/main`，工作区没有变化，真正整合用 pull：

```sh
git pull --rebase origin main
git log --oneline --graph --all
```

`--rebase` 会把 alice 的本地提交挪到远端提交之后，历史保持一条直线，不会多出 merge commit。

## shallow clone

正常情况下 clone 会拉取全部历史。对于历史很长、或者只是想拿最新代码来阅读和构建的场景，只取最近一段提交会更省时间，也会让 clone 更快：

```sh
cd ..
git clone --depth 1 --no-single-branch file:///<path-to-team.git> alice-shallow
cd alice-shallow
git log --oneline
```

`--depth 1` 只取最近一层提交，`--no-single-branch` 保留所有远端分支的跟踪关系。

这里用 `file:///` 加绝对路径是为了让 `--depth` 生效，普通本地路径 `../team.git` 会忽略它；真实 GitHub/GitLab 地址没有这个问题。

检查当前仓库是不是浅克隆：

```sh
git rev-parse --is-shallow-repository
```

输出 `true` 表示浅克隆，`false` 表示完整仓库。

之后需要完整历史时：

```sh
git fetch --unshallow
```

如果仓库历史较多，一次 `--unshallow` 拉取压力过大或失败，也可以用 `--deepen` 在当前基础上逐步加深，例如每次加深 100 层：

```sh
git fetch --deepen 100
```

可以重复执行直到历史深度满足需要。

## LFS

小项目用普通文件即可，但仓库里一旦出现二进制大文件，直接提交会让仓库体积快速增长，clone 和 pull 都会越来越慢。LFS 的做法是在仓库里保存一个很小的指针文件，真实文件放到独立的 LFS 对象库中，只在需要时下载。下面让 alice 演示这个过程：

```sh
cd ../alice
git lfs install --local
git lfs track "*.bin"

# 随便生成一个 big.bin（内容无所谓）
git add .gitattributes big.bin
git commit -m "track big.bin with git lfs"
git push
```

仓库里保存的是指针文件，不是真实文件：

```text
version https://git-lfs.github.com/spec/v1
oid sha256:cd2eca...
```

clone 时跳过 LFS 下载：

```sh
cd ..

# PowerShell
$env:GIT_LFS_SKIP_SMUDGE = 1
git clone file:///<path-to-team.git> bob-lfs
Remove-Item Env:GIT_LFS_SKIP_SMUDGE
```

```sh
# Bash
# GIT_LFS_SKIP_SMUDGE=1 git clone file:///<path-to-team.git> bob-lfs
```

进入 bob-lfs 后 `big.bin` 还是指针，需要真实文件时执行：

```sh
cd bob-lfs
git lfs pull
```

想统一存放 LFS 对象时可以配置 `lfs.storage`：

```sh
git config --global lfs.storage "D:/git-lfs-store"
```

# branch、worktree

main 现在处于最新状态。alice 接到一个修改 README 的任务，按惯例不在 main 上直接改，而是从最新的 main 开一个功能分支，完成并确认没问题后再合并回去：

```sh
cd ../alice
git switch -c feature/rewrite-readme
```

老写法等价于 `git checkout -b feature/rewrite-readme`。Git 2.23 之后 `checkout` 被拆成 `switch`（切分支）和 `restore`（恢复文件）。

修改 `README.md` 后提交：

```sh
# 修改 README.md
git status
git diff
git add README.md
git commit -m "feature: rewrite readme"
```

`git status` 看改动了哪些文件，`git diff` 看具体内容。

feature 分支还在开发中，线上又反馈了一个 README 拼写错误。如果不想在 feature 和 hotfix 之间来回切换、频繁暂存未完成的改动，可以直接用 worktree 把仓库挂到另一个目录：

```sh
git worktree add ../alice-fix -b hotfix/fix-typo
git worktree list
```

两个目录共享同一份提交历史，但工作区相互独立；同一个分支不能被两个 worktree 同时检出。

分支的增删改：

```sh
git switch -c new-branch              # 创建并切换
git branch -m old new                 # 重命名
git branch -d branch-name             # 删除已合并的分支
git branch -D branch-name             # 强制删除，慎用
git push origin --delete old-branch   # 删除远端分支
```

# rebase

feature 分支在本地已经完成。先把它推到远端，之后 bob 在 main 上也改了 README，而且恰好是 alice 修改过的同一行。此时 feature 分支的基准已经落后于 main，直接合回去会产生冲突，常规做法是先把 feature rebase 到最新 main，再解决冲突：

先把功能分支推到远端：

```sh
git push -u origin feature/rewrite-readme
```

bob 更新 main 后修改同一行并推送：

```sh
cd ../bob
git pull --rebase

# 修改 README.md 中与 alice 相同的一行
git add README.md
git commit -m "bob: change same line"
git push
```

alice 执行 rebase：

```sh
cd ../alice
git fetch origin
git rebase origin/main
```

冲突输出如下（提交哈希因环境而异）：

```sh
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
error: could not apply fc650ca... feature: rewrite readme
```

`git status` 中冲突文件标记为 `UU`。打开文件删掉 `<<<<<<<`、`=======`、`>>>>>>>` 标记并保留需要的内容，然后：

```sh
git add README.md
git rebase --continue
```

rebase 解决冲突后不需要再手动 commit，`--continue` 会沿用原提交信息。如果弹出编辑器，保存关闭即可。

此时直接 push 会被拒绝，因为 rebase 改写了本地提交，远端还停留在旧版本：

```sh
 ! [rejected]        feature/rewrite-readme -> feature/rewrite-readme (non-fast-forward)
```

用 `--force-with-lease` 强制推送。它比 `-f` 多一层检查：远端分支不在上次记录的位置时直接拒绝，避免覆盖别人的提交。force push 只用于个人负责的分支。

```sh
git push --force-with-lease
```

fetch + rebase 的两步可以合并为 `git pull --rebase`：

```sh
git pull --rebase
```

# remote

上面的场景始终只有一个远端 `team.git`。实际参与开源或上游项目时，一个本地仓库经常会同时挂两个 remote：fork 出来的 `origin`，以及原项目的 `upstream`。为了在本地模拟，下面的演示把 `upstream` 也指向 `team.git`，效果与挂两个不同地址的远端一致：

给 alice 添加 upstream（本地演示指向同一个 `team.git`）：

```sh
git remote add upstream file:///<path-to-team.git>
git fetch upstream
git branch -r
```

```sh
  origin/feature/rewrite-readme
  origin/main
  upstream/feature/rewrite-readme
  upstream/main
```

`origin/main` 和 `upstream/main` 是两组独立的远端跟踪引用，分别对应 `refs/remotes/origin/main` 和 `refs/remotes/upstream/main`。`git fetch upstream` 只更新 `upstream/*`，不影响 `origin/*` 和本地分支。

remote 的常见操作：

```sh
git remote -v                          # 查看所有 remote
git remote add upstream <url>          # 新增 remote
git remote set-url origin <new-url>    # 修改 remote 地址
git remote remove upstream             # 删除 remote
```

同步上游：

```sh
git fetch upstream
git rebase upstream/main
git push origin HEAD
```
# 总结

核心流程速记：

```sh
git clone <url>          # 拿代码
git switch -c <branch>   # 开分支
git pull --rebase        # 追上远端
git push                 # 推代码
git push --force-with-lease  # rebase 后重推
git fetch upstream       # fork 后同步上游
```

整个流程走下来，命令本身并不多，关键是要清楚每一步动了什么：fetch 只更新 `origin/main` 这类远端跟踪引用，rebase 会重写本地提交，push 才把提交真正送到远端。之后遇到具体的参数或报错，直接查 `git xxx --help` 或问 AI 即可。
