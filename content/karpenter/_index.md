---
title: "EKS and Karpenter"
date: 2019-01-24T09:05:54Z
weight: 50
pre: "<b>5. </b>"
---

## Running Efficient Kubernetes Clusters on Amazon EC2 with Karpenter

In this workshop, you will learn how to provision, manage, and maintain your Kubernetes clusters with Amazon Elastic Kubernetes Service (Amazon EKS) at any scale using [Karpenter](https://github.com/awslabs/karpenter). Karpenter is a node lifecycle management solution used to scale your Kubernetes Cluster. It observes incoming pods and launches the right instances for the situation. Instance selection decisions are intent based and driven by the specification of incoming pods, including resource requests and scheduling constraints.

On EKS we will run a small EKS managed node groups, to deploy a minimum set of On-Demand instances that we will use to deploy controllers. After that we will use Karpenter to deploy a mix of On-Demand and Spot instances to showcase a few of the benefits of running a group-less auto scaler. EC2 Spot Instances allow you to architect for optimizations on cost and scale. 

This workshop is originally based on AWS [EKS Workshop](https://eksworkshop.com/) but expands and focuses on how efficient Flexible Compute can be implemented using Karpenter. You can find there more modules and learn about other Amazon Elastic Kubernetes Service best practices.

{{% notice note %}}
In this workshop we will not cover the introduction to EKS. We expect users of this workshop to understand about Kubernetes, Horizontal Pod Autoscaler and Cluster Autoscaler. Please refer to the **[Containers with EKS](using_ec2_spot_instances_with_eks/005_introduction.html)** workshops
{{% /notice %}}

![EKS](images/karpenter/karpenter_banner.png)

