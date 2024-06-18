---
title: "Select Instance Types for Diversification"
date: 2018-08-07T11:05:19-07:00
weight: 20
draft: false
---

{{% notice warning %}}
![STOP](../../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

One of the best practices to successfully adopt Spot Instances is to implement **Spot Instance diversification** as part of your configuration. Spot Instance diversification helps to procure capacity from multiple Spot Instance pools, both for scaling up and for replacing Spot Instances that may receive a Spot Instance termination notification. A Spot Instance pool is a set of unused EC2 instances with the same Instance type, operating system and Availability Zone (for example, m5.large on Red Hat Enterprise Linux in us-east-1a).

### Cluster Autoscaler And Spot Instance Diversification

Cluster Autoscaler is a tool that automatically adjusts the size of the Kubernetes cluster when there are pods that fail to run in the cluster due to insufficient resources (Scale Out) or there are nodes in the cluster that have been underutilized for a period of time (Scale In).

{{% notice info %}}
When using Spot Instances with [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) there are a few things that [should be considered](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md). One key consideration is, each Auto Scaling group should be composed of instance types that provide approximately equal capacity. Cluster Autoscaler will attempt to determine the CPU, memory, and GPU resources provided by an Auto Scaling Group based on first override provided in an ASG's Mixed Instances Policy. If any such overrides are found, only the first instance type found will be used. See [Using Mixed Instances Policies and Spot Instances](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#Using-Mixed-Instances-Policies-and-Spot-Instances) for details.
{{% /notice %}}

When applying Spot Diversification best practices to EKS and K8s clusters, using Cluster Autoscaler to dynamically scale capacity, we must implement diversification in a way that adheres to Cluster Autoscaler expected operational mode. In this workshop we will assume that our cluster node groups should be provisioned with instance types that adhere to a 1vCPU:4GB RAM ratio.

We can diversify Spot Instance pools using two strategies:

 - By creating multiple node groups, each of different sizes. For example, a node group of size 4 vCPUs and 16GB RAM, and another node group of 8 vCPUs and 32GB RAM. 
 
 - By Implementing instance diversification within the node groups, by selecting a mix of instance types and families from different Spot Instance pools that meet the same vCPUs and memory criteria.

Our goal in this workshop, is to create 2 diversified node groups that adhere the 1 vCPU:4 GB RAM ratio. 

We will use **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** to help us select the relevant instance
types and families with sufficient number of vCPUs and RAM. 

There are over 350 different instance types available on EC2 which can make the process of selecting appropriate instance types difficult. amazon-ec2-instance-selector helps you select compatible instance types for your application to run on. The command line interface can be passed resource criteria like vcpus, memory, network performance, and much more and then return the available, matching instance types.

Let's first install **amazon-ec2-instance-selector** :

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.0.3/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run
`ec2-instance-selector --help` to understand how you could use it for selecting
instances that match your workload requirements. For the purpose of this workshop
we need to first get a group of instances that meet the 4 vCPUs and 16 GB of RAM.
Run the following command to get the list of instances.

{{% notice note %}}
The results might differ if you created Cloud9 in any other region than the five regions (N. Virginia, Oregon, Ireland, Ohio and Singapore) suggested when starting the workshop. We will use **`--deny-list`** for filtering out the instances that are not supported across these five regions. 
{{% /notice %}}

```
ec2-instance-selector --vcpus 4 --memory 16 --gpus 0 --current-generation -a x86_64 --deny-list '.*[ni].*'   
```

This should display a list like the one that follows . We will use this instances as part of one of our node groups.



```
m4.xlarge
m5.xlarge
m5a.xlarge
m5ad.xlarge
m5d.xlarge
t2.xlarge
t3.xlarge
t3a.xlarge
```

Internally ec2-instance-selector is making calls to the [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) for the specific region and filtering the instances based on the criteria selected in the command line, in our case we did filter for instances that meet the following criteria:
 
 * Instances with no GPUs
 * of x86_64 Architecture (no ARM instances like A1 or m6g instances for example)
 * Instances that have 4 vCPUs and 16 GB of RAM
 * Instances of current generation (4th gen onwards)
 * Instances that don’t meet the regular expression .*[in].*, so effectively latest generation Intel instances and improved network throughput instances. The main reason to discard those in this workshop is that some of those might not be available (at the time of writing this workshop) on all the regions. You can check the availability using instance selector and add them yourselve as an exercise.

{{% notice warning %}}
Your workload may have other constraints that you should consider when selecting instance types. For example. **t2** and **t3** instance types are [burstable instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances.html) and might not be appropriate for CPU bound workloads that require CPU execution determinism. Instances such as m5**a** are [AMD Instances](https://aws.amazon.com/ec2/amd/), if your workload is sensitive to numerical differences (i.e: financial risk calculations, industrial simulations) mixing these instance types might not be appropriate.
{{% /notice %}}

{{% notice note %}}
You are encouraged to test what are the options that `ec2-instance-selector` provides and run a few commands with it to familiarize yourself with the tool.<br>
<br>
For example, try running the same commands as you did before with the extra parameters, like **`--output table-wide`** for a tabular view.
{{% /notice %}}

### Challenge 

Find out another group that adheres to a 1 vCPU:4 GB ratio, this time using instances with 8 vCPUs and 32 GB of RAM.

{{%expand "Expand this for an example on the list of instances" %}}

That should be easy. You can run the command:  

```
ec2-instance-selector --vcpus 8 --memory 32 --gpus 0 --current-generation -a x86_64 --deny-list '.*[nih].*'  
```

which should yield a list as follows 

```
m4.2xlarge
m5.2xlarge
m5a.2xlarge
m5ad.2xlarge
m5d.2xlarge
t2.2xlarge
t3.2xlarge
t3a.2xlarge
```

{{% /expand %}}

