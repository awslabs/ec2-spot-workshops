---
title: "Karpenter"
titleMenu: "Karpenter"
chapter: true
weight: 50
draft: false
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

In this section we will setup Karpenter. Karpenter is an open-source autoscaling project built for Kubernetes. Karpenter is designed to provide the right compute resources to match your application’s needs in seconds, instead of minutes by observing the aggregate resource requests of unschedulable pods and makes decisions to launch and terminate nodes to optimize the cluster cost.

![Karpenter](/images/karpenter/karpenter_banner.png)
