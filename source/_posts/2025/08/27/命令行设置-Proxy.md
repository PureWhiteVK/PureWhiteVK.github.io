---
title: 命令行设置 Proxy
mathjax: false
abbrlink: 4af5
date: 2025-08-27 21:14:04
tags:
- 命令行
category: 技术笔记
---


# Powershell 设置

通过 `$PROFILE` 变量，可以查询到 Powershell 默认加载的配置文件路径，如下所示

![image-20250827211708072](命令行设置-Proxy/image-20250827211708072.png)

如果文件不存在，直接创建一个即可，然后填入下面两个预定义的函数（默认代理的地址为 `127.0.0.1:7890`，纪念天国的CFW🙏）

```powershell
function proxy_on {
    $proxy="http://127.0.0.1:7890"
    $Env:http_proxy = "$proxy"
    $Env:https_proxy = "$proxy"
    Write-Host "Proxy enabled: $proxy"
}

function proxy_off {
    Remove-Item Env:\http_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:\https_proxy -ErrorAction SilentlyContinue
    Write-Host "Proxy disabled"
}
```

当更改完 `$PROFILE` 文件后，使用 `. $PROFILE` 加载更新后的配置文件，并通过简单的 `curl` 命令判断是否可用

<!-- more -->

![image-20250827212341633](命令行设置-Proxy/image-20250827212341633.png)

（由于 cmd 并不支持 profile ，就无法编写类似的函数了，不过其基本思路也就是设置 `http_proxy` 和 删除 `http_proxy` 而已）

# Bash 设置

对于 bash 文件，也可以编写类似的脚本，修改 `~/.bashrc`，并插入如下内容

```bash
proxy_on() {
    local proxy="http://127.0.0.1:7890"
    export http_proxy="$proxy"
    export https_proxy="$proxy"
    echo "Proxy enabled: $proxy"
}

proxy_off() {
    unset http_proxy
    unset https_proxy
    echo "Proxy disabled"
}
```

更新完成后，使用 `source ~/.bashrc` （实际上也可以使用 `. ~/.bashrc`） 加载更新后的配置文件，并进行简单的验证

![image-20250827212804711](命令行设置-Proxy/image-20250827212804711.png)