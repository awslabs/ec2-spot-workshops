---
title: "What Have We Accomplished"
chapter: false
weight: 1
---

Congratulations! you have reached the end of the workshop. In this workshop, you learned about the need to be flexible with EC2 instance types when using Spot Instances, and how to size your EKS nodes and apply EC2 diversification best practices. 

We have:

- Deployed and managed eks clusters and worker resources using eksctl
- Deployed an application consisting of microservices
- Deployed packages using Helm such as Kube-ops-view
- Configured Automatic scaling of our pods and worker nodes while applying EC2 Best practices of diversification both in the number of nodegroups and within the nodegroups internal AWS Autoscaling Group 
- Configured a mix On-demand and Spot workloads and handled placement using Taints/Tolerations and hard/soft Affinities
- Configured a DaemonSet to handle spot interruptions gracefully
 