---
title: "EKS with Karpenter"
date: 2019-01-24T09:05:54Z
weight: 40
pre: "<b>4. </b>"
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

## Running Efficient Kubernetes Clusters on Amazon EC2 with Karpenter

In this workshop, you will learn how to provision, manage, and maintain your Kubernetes clusters with Amazon Elastic Kubernetes Service (Amazon EKS) at any scale using [Karpenter](https://github.com/awslabs/karpenter). Karpenter is a node lifecycle management solution used to scale your Kubernetes Cluster. It observes incoming pods and launches the right instances for the situation. Instance selection decisions are intent based and driven by the specification of incoming pods, including resource requests and scheduling constraints.

On EKS we will run a small EKS managed node groups, to deploy a minimum set of On-Demand instances that we will use to deploy controllers. After that we will use Karpenter to deploy a mix of On-Demand and Spot instances to showcase a few of the benefits of running a group-less auto scaler. EC2 Spot Instances allow you to architect for optimizations on cost and scale. 

This workshop is originally based on AWS [EKS Workshop](https://eksworkshop.com/) but expands and focuses on how efficient Flexible Compute can be implemented using Karpenter. You can find there more modules and learn about other Amazon Elastic Kubernetes Service best practices.

{{% notice note %}}
In this workshop we will not cover the introduction to EKS. We expect users of this workshop to understand about Kubernetes, Horizontal Pod Autoscaler and Cluster Autoscaler. Please refer to the **[Containers with EKS](using_ec2_spot_instances_with_eks/005_introduction.html)** workshops
{{% /notice %}}

![EKS](images/karpenter/karpenter_banner.png)

