---
title: "CMP307: Running Efficient Kubernetes Clusters on Amazon EC2 with Karpenter"
date: 2019-01-24T09:05:54Z
weight: 10
---

# CMP307: Running Efficient Kubernetes Clusters on Amazon EC2 with Karpenter

In this workshop, you will learn how to provision, manage, and maintain your Kubernetes clusters with Amazon Elastic Kubernetes Service (Amazon EKS) at any scale using [Karpenter](https://github.com/awslabs/karpenter). Karpenter is a node lifecycle management solution used to scale your Kubernetes Cluster. It observes incoming pods and launches the right instances for the situation. Instance selection decisions are intent based and driven by the specification of incoming pods, including resource requests and scheduling constraints.

On EKS we will run a small EKS managed node groups, to deploy a minimum set of On-Demand instances that we will use to deploy controllers. After that we will use Karpenter to deploy a mix of On-Demand and Spot instances to showcase a few of the benefits of running a group-less auto scaler. EC2 Spot Instances allow you to architect for optimizations on cost and scale. 

This workshop is originally based on AWS [EKS Workshop](https://eksworkshop.com/). You can find there more modules and learn about other Amazon Elastic Kubernetes Service best practices.

![EKS](images/karpenter_banner.png)

