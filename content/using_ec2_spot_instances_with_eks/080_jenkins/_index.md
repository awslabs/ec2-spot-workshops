---
title: "(Optional) Running cost optimized and resilient Jenkins jobs"
chapter: true
weight: 80
---

# Running Jenkins jobs - optional module

In this section, we will deploy a Jenkins server into our cluster, and configure build jobs that will launch Jenkins agents inside Kubernetes pods. The Kubernetes pods will run on a dedicated EKS managed node group with Spot capacity. We will demonstrate automatically restarting jobs that could potentially fail due to EC2 Spot Interruptions, that occur when EC2 needs the capacity back.
