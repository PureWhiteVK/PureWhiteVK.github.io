---
title: WebRTC实践
mathjax: false
abbrlink: ac0d
date: 2023-07-12 10:26:36
tags:
- WebRTC
- Web
category: 技术笔记
---


# WebRTC实践

[WebRTC](https://webrtc.org/)

WebRTC 表示 Web **R**eal-**T**ime **C**ommunication，通过建立端到端的P2P连接，实现高效的数据传输

由于两个客户端并不能直接连通，需要借助一个服务器来完成建立连接的工作，下面展示了一个最简单的WebRTC交互模型，包含两个客户端以及一个服务端

- Client1

- Client2

- Signalling Server

  establish p2p connection

  hand shaking

> both clients need to provide an ICE Server configuration. This is either a STUN or a TURN-server, and their role is to provide ICE candidates to each client which is then transferred to the remote peer. This transferring of ICE candidates is commonly called signaling.
>
> ICE Server stands for **I**nternet **C**onnectivity **E**stablishment Server（中文翻译就是用于建立互联网连接的服务器）
>
> Passing SDP objects to remote peers is called signaling and is not covered by the WebRTC specification.

名词解释

- WebRTC
- P2P
- ICE
- STUN
- TURN
- SDP
- NAT

> Before two peers can communitcate using WebRTC, they need to exchange connectivity information. Since the network conditions can vary depending on a number of factors, an external service is usually used for discovering the possible candidates for connecting to a peer. This service is called ICE and is using either a STUN or a TURN server. ***STUN stands for Session Traversal Utilities for NAT, and is usually used indirectly in most WebRTC applications.***
>
> ***TURN (Traversal Using Relay NAT) is the more advanced solution that incorporates the STUN protocols and most commercial WebRTC based services use a TURN server for establishing connections between peers.*** The WebRTC API supports both STUN and TURN directly, and it is gathered under the more complete term Internet Connectivity Establishment. When creating a WebRTC connection, we usually provide one or several ICE servers in the configuration for the `RTCPeerConnection` object.

<!-- more -->

client1 -> TURN -> client2 (fake p2p, relay)

client1 -> client2 (real p2p)



> But sometimes this would not be sufficient because there are possibilities where some users might face connectivity issues because of different IP networks where Firewalls and NATs (Network Address Translators) could include specific network policies that will not allow RTC communications.
>
> In order to solve this kind of network connection scenario, we need to use ICE (Interactive Connectivity Establishment) protocol and it defines a systematic way of finding possible communication options between a peer and the Video Gateway (WebRTC).
>
> ICE (INTERACTIVE CONNECTIVITY ESTABLISHMENT) is a protocol used to generate media traversal candidates that can be used in WebRTC applications, and it can be successfully sent and received through Network Address Translation (NAT)s using STUN and TURN.



## 基本概念



## 年轻人的第一个 WebRTC 应用



## 其他应用场景

通过 webrtc 可以是两个应用端之间的p2p 交互（这也是为什么腾讯会议在两个人的时候不限时，而在超过两个人的时候限时了，两个人的时候用的是 p2p 连接，腾讯会议的服务器只需要建立p2p连接就行，其他不管，但是多人情况下可能需要服务端进行推流，需要消耗大量服务器资源，因此要收费）

也可以实现前端后后端的交互（例如深度学习应用的部署）