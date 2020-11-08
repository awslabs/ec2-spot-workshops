---
title: "Using AWS Fargate Spot capacity providers (Optional)"

weight: 40
---

In this section, we will learn how to leverage ECS FARGATE and FARGATE_SPOT capacity providers to optimize costs.

AWS Fargate capacity providers
---

Amazon ECS cluster capacity providers enable you to use both Fargate and Fargate Spot capacity with your Amazon ECS tasks. With Fargate Spot you can run interruption tolerant Amazon ECS tasks at a discounted rate compared to the Fargate price. Fargate Spot runs tasks on spare compute capacity. When AWS needs the capacity back, your tasks will be interrupted with a two-minute warning notice.

