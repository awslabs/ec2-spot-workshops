---
title: "Using AWS Fargate Spot capacity providers"
weight: 60
---

![Fargate](/images/ecs-spot-capacity-providers/fargate.png)   

[AWS Fargate](https://aws.amazon.com/fargate/) is a technology for Amazon ECS that allows you to run containers without having to manage servers or clusters. With AWS Fargate, you no longer have to provision, configure, and scale clusters of virtual machines to run containers. This removes the need to choose server types, decide when to scale your clusters, or optimize cluster packing. AWS Fargate removes the need for you to interact with or think about servers or clusters. Fargate lets you focus on designing and building your applications instead of managing the infrastructure that runs them.


## AWS Fargate capacity providers

In this section, **we will learn how to leverage ECS FARGATE and FARGATE_SPOT capacity providers to optimize costs**.


Amazon ECS cluster capacity providers enable you to use both Fargate and Fargate Spot capacity with your Amazon ECS tasks. With Fargate Spot you can run interruption tolerant Amazon ECS tasks at a discounted rate compared to the Fargate price. Fargate Spot runs tasks on spare compute capacity. When AWS needs the capacity back, your tasks will be interrupted with a two-minute warning notice.

