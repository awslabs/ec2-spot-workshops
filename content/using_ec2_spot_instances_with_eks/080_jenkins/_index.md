---
title: "(Optional) Running cost optimized and resilient Jenkins jobs"
chapter: true
weight: 80
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}


# Running Jenkins jobs - optional module

In this section, we will deploy a Jenkins server into our cluster, and configure build jobs that will launch Jenkins agents inside Kubernetes pods. The Kubernetes pods will run on a dedicated EKS managed node group with Spot capacity. We will demonstrate automatically restarting jobs that could potentially fail due to EC2 Spot Interruptions, that occur when EC2 needs the capacity back.
