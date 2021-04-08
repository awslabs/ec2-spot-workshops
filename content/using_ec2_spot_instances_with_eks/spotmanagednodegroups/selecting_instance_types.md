---
title: "Selecting Instance Types"
date: 2018-08-07T11:05:19-07:00
weight: 10
draft: false
---

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

One of the best practices to successfully adopt Spot instances is to implement **Spot instance diversification** as part of your configuration. Spot instance diversification helps to procure
capacity from multiple Spot Instance pools, both for scaling up and for replacing spot instances that may receive a spot instance termination notification. A Spot instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone.

### Cluster Autoscaler And Spot Instance Diversification

Cluster Autoscaler is a tool that automatically adjusts the size of the Kubernetes cluster when there are pods that fail to run in the cluster due to insufficient resources (Scale Out) or there are nodes in the cluster that have been underutilized for a period of time (Scale In).

{{% notice info %}}
When using Spot instances with [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) there are a few things that [should be considered](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md). For example Cluster Autoscaler makes the assumption that all nodes within a nodegroup will have the same number of vCPUs and Memory.
{{% /notice %}}

When applying Spot Diversification best practices to EKS and K8s clusters, using Cluster Autoscaler to dynamically scale capacity, we must implement diversification in a way that adheres to Cluster Autoscaler expected operational mode. In this workshop we will assume that our cluster nodegroups should be provisioned with instance types that adhere to a 1vCPU:4GB RAM ratio.

We can diversify Spot instance pools using two strategies:

 - By creating multiple nodegroups, each of different sizes. For example a nodegroup of size 4VCPU's and 16GB Ram, and another nodegroup of 8vCPU's and 32GB Ram. 
 
 - By Implementing instance diversification within the nodegroups, by selecting a mix of instances types and families from different Spot instance pools that meet the same vCPU's and memory criteria.

Our goal in this workshop, is to create at least 2 diversified groups of instances that adhere the 1vCPU:4GB RAM ratio. 

There are over 270 different instance types available on EC2 which can make the process of selecting appropriate instance types difficult. We will use the Instance Selector options flags in `eksctl create nodegroup` command to help you select compatible instance types for your application to run on. The Instance Selector options can filter instances based on vcpu, memory, cpu architecture, and even gpu. The options we will use:

 - `--instance-selector-vcpus` option can be set to an integer value representing the number of vCPUs
 
 - `--instance-selector-memory` option can be set to integer value representing the memory.

 - `--instance-selector-cpu-architecture` option can be used to limit the instances to x86 (x86_64) or arm (arm64) architecture. 

 - `--dry-run` option help us skip nodegroup creation and instead generate a ClusterConfig for review.  

You can run `eksctl create nodegroup --help` to understand how you could use the above options for selecting instances that match your workload requirements. For the purpose of this workshop we need to first get a group of instances that meet the 4vCPUs and 16GB of RAM. Run the following command to get the list of instances.

```bash
eksctl create nodegroup \
    --cluster=eksworkshop-eksctl \
    --region=$AWS_REGION \
    --dry-run \
    --managed \
    --spot \
    --name=dev-4vcpu-16gb-spot \
    --instance-selector-vcpus=4 \
    --instance-selector-memory=16 \
    --instance-selector-cpu-architecture=x86_64 \
    --instance-selector-gpus=0
```

This should display a list in the instanceTypes under managedNodeGroups like the one that follows (note results might differ depending on the region). We will use this instances as part of one of our node groups.

```bash
  instanceSelector:
    cpuArchitecture: x86_64
    memory: "16"
    vCPUs: 4
  instanceTypes:
  - d3en.xlarge
  - g4dn.xlarge
  - m4.xlarge
  - m5.xlarge
  - m5a.xlarge
  - m5ad.xlarge
  - m5d.xlarge
  - m5dn.xlarge
  - m5n.xlarge
  - m5zn.xlarge
  - t2.xlarge
  - t3.xlarge
  - t3a.xlarge
```

Internally the Instance Selector is making calls to the [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) for the specific region and filtering the intstances based on the criteria selected in the command line. In our case we did filter for instances that meet the following criteria:

 - 4 vCPUs and 16GB of Ram
 - x86_64 Architecture (no ARM instances like A1 or m6g instances for example)
 - no GPUs
 
{{% notice warning %}}
Your workload may have other constraints that you should consider when selecting instances types. For example. **t2** and **t3** instance types are [burstable instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances.html) and might not be appropriate for CPU bound workloads that require CPU execution determinism. Instances such as m5**a** are [AMD Instances](https://aws.amazon.com/ec2/amd/), if your workload is sensitive to numerical differences (i.e: financial risk calculations, industrial simulations) mixing these instance types might not be appropriate.
{{% /notice %}}

### Challenge 

Find out another group that adheres to a 1vCPU:4GB ratio, this time using instances with 8vCPU's and 32GB of RAM.

{{%expand "Expand this for an example on the list of instances" %}}

That should be easy. You can run the command:  

```bash
eksctl create nodegroup \
    --cluster=eksworkshop-eksctl \
    --region=$AWS_REGION \
    --dry-run \
    --managed \
    --spot \
    --name=dev-8vcpu-32gb-spot \
    --instance-selector-vcpus=8 \
    --instance-selector-memory=32 \
    --instance-selector-cpu-architecture=x86_64 \
    --instance-selector-gpus=0
```

which should yield a list as follows 

```
  instanceSelector:
    cpuArchitecture: x86_64
    memory: "32"
    vCPUs: 8
  instanceTypes:
  - d3en.2xlarge
  - g4dn.2xlarge
  - h1.2xlarge
  - m4.2xlarge
  - m5.2xlarge
  - m5a.2xlarge
  - m5ad.2xlarge
  - m5d.2xlarge
  - m5dn.2xlarge
  - m5n.2xlarge
  - m5zn.2xlarge
  - t2.2xlarge
  - t3.2xlarge
  - t3a.2xlarge
```

{{% /expand %}}




