---
title: "Selecting Instance Types"
date: 2018-08-07T11:05:19-07:00
weight: 10
draft: false
---

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

One of the best practices to adopt Spot instances successfully is to implement Spot instance diversification as part of your configuration. This helps to procure
capacity from multiple Spot Instance pools both for scaling up and for replacing spot instances that may receive a spot instance termination notification with instances from alternative pools.
A Spot instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone.

### Cluster Autoscaler And Spot Instance Diversification

Cluster Autoscaler is a tool that automatically adjusts the size of the Kubernetes cluster when there are pods that failed to run in the cluster due to insufficient resources (Scale Out) or there are nodes in the cluster that have been underutilized for a period of time (Scale In).

{{% notice info %}}
When using Spot instances with [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) there are a few 
notes that [should be considered](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md). For example Cluster Autoscaler makes the assumption that all nodes within a nodegroup have the same number of vCPUs and Memory.
{{% /notice %}}

When applying Spot Diversification best practices to EKS and K8s clusters using Cluster Autoscaler to dynamically scale capacity, we must implement diversification in a way that adheres to Cluster Autoscaler expected operation mode. In this workshop we will assume that our cluster
nodegroups should be provisioned with instance types that match a ratio of 1vCPU:4GB of RAM.

We can diversify the instance pools that we have access using two strategies:

 - Creating multiple nodegroups, each with a node type of different sizes. For example a nodegroup of 4VCPU's and 16GB Ram, and another nodegroup of 8vCPU's and 32GB Ram.
 
 - Implementing instance diversification within each nodegroup, by selecting a mix of instances that meet the same vCPU's and Memory criteria.

Our goal is to create at least 2 diversified groups of instances that adhere to that ratio. We can use [Spot Instance Advisor](https://aws.amazon.com/ec2/spot/instance-advisor/) page to find the relevant instance types with sufficient number of vCPUs and RAM, and use this to also select instance types with low interruption rates.

![Selecting Instance Type with 4vCPU and 16GB](/images/using_ec2_spot_instances_with_eks/spotworkers/4cpu_16_ram_instances.png)

In this case with Spot Instance Advisor we can create a 4vCPUs_16GB nodegroup with the following diversified instances: m5.xlarge, m5d.xlarge, m4.xlarge, m5a.xlarge, t2.xlarge, t3.xlarge, t3a.xlarge

{{% notice note %}}
Spot Instance interruption rates are dynamic, the above just provides a real world example from a specific time and would probably be different when you are performing this workshop. Note also that not all the instances are available in all the regions.
{{% /notice %}}

{{% notice warning %}}
Your workload may have other constraints that you should consider when selecting instances types. For example. **t2** and **t3** instance types are [burstable instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances.html) and might not be appropriate in CPU bounded workloads that require CPU execution determinism. Instances such as m5**a** are [AMD Instances](https://aws.amazon.com/ec2/amd/), if your workload is very sensitive to numerical differences (i.e: risk calculations, industrial simulations) mixing these instance types might not appropriate.
{{% /notice %}}

**Challenge** : Find out another group that adheres to a 1vCPU:4GB ratio, this time using instances with 8vCPU's and 32GB of RAM.

{{%expand "Expand this for an example on the list of instances" %}}
That should be easy. 

m5.2xlarge, m5d.2xlarge, m4.2xlarge, m5a.2xlarge, t2.2xlarge, t3.2xlarge, t3a.2xlarge
{{% /expand %}}


