---
title: "What Have We Accomplished"
chapter: false
weight: 1
---

Congratulations! you have reached the end of the workshop. In this workshop, you learned about the need to be flexible with EC2 instance types when using Spot Instances, and how to size your EKS nodes and apply EC2 diversification best practices. 

We have:

- Deployed and managed EKS clusters and worker resources using [eksctl](https://github.com/weaveworks/eksctl)
- Deployed an application consisting of microservices
- Deployed packages using [Helm](https://helm.sh/) such as [Kube-ops-view](https://github.com/hjacobs/kube-ops-view)
- Configured automatic scaling of our pods and worker nodes while applying EC2 Best practices of diversification both in the number of nodegroups and within the nodegroups internal AWS Autoscaling Group 
- Configured an EKS Cluster with a mix of On-demand and Spot workers and handled placement using Taints/Tolerations and hard/soft Affinities
- Configured a DaemonSet to handle spot interruptions gracefully
 
# EC2 Spot Savings 

There is one more thing that we've accomplished !

  * Log into the **[EC2 Spot Request](https://console.aws.amazon.com/ec2sp/v1/spot/home)** page in the Console.
  * Click on the **Savings Summary** button.

![EC2 Spot Savings](/images/spot_savings_summary.png)

{{% notice note %}}
We have achieved a significant cost saving over On-Demand prices that we can apply in a controlled way and at scale. We hope this savings will help you try new experiments or build other cool projects. Now Go Build !
{{% /notice %}}

{{< youtube 3wGeqmSwz9k >}}