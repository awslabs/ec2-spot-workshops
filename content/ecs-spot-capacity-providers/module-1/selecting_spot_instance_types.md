---
title: "Selecting Spot Instance Types"
date: 2018-08-07T11:05:19-07:00
weight: 60
draft: false
---

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. One of the best practices for successful adoption of Spot instances is to implement **Spot instance diversification** as part of your configuration. Spot instance diversification helps to acquire capacity from multiple Spot Instance pools, both for scaling up and for replacing spot instances that may receive a spot instance termination notification. A Spot instance pool is a set of unused EC2 instances with the same instance type and size (for example, m5.large), availability zone (AZ), in the same region
 
We can diversify Spot instances by selecting a mix of instances types and families from different pools that meet the same vCPU's and memory criteria. In the case of ECS we can check what's the ratio of vCPU and Memory used by our task resources. For example, look at the ECS task resource reservation in the file **ec2-task.json**:

```plaintext
"cpu": "512", "memory": "2048"
```

This means the ratio for vCPU:Memory in our ECS task that would run in the cluster is **1:4**. Ideally, we should select instance types with similar vCPU:Memory ratio, in order to have good utilization of the resources in the EC2 instances. There are over 270 different instance types available on EC2 which can make selecting appropriate instance types difficult. **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** helps you select compatible instance types for your application to run on. We can pass the command line options for resource criteria like vCPUs, memory, network performance, and much more and then return the available, matching instance types.

{{% notice note%}}
To learn more about EC2 instance types, click [here](https://aws.amazon.com/ec2/instance-types/). As for **ec2-instance-selector**, it is an open source tool that makes calls to [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) APIs, on the specific region and filters instances based on the criteria selected in the command line.
{{% /notice %}}

In our case, for the **1:4** vCPU to memory ratio, the smallest instance type which would satisfy these criteria from the latest generation of x86_64 EC2 instance types is m5.large.  We will use **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** to help us select the relevant instance types and families with an enough number of vCPUs and Memory.  Let's first install **amazon-ec2-instance-selector** :

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v1.3.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run `ec2-instance-selector --help` to understand how you could use it for selecting
Instances that match your workload requirements. For this workshop, we need to first get a group of instances that meet the following criteria: 

* 1:4 vCPU:RAM Ratio 
* Instances have a Min of 2 vCPU and max 4 vCPUs 
* Instances don't have a GPUs
* Instances Architecture is: x86_64 (no ARM instances like A1 or m6g instances, for example)
* Instances of current generation (4th gen onwards)
* Instances that don't meet the regular expression `.*n.*|.*d.*`, so effectively m5n, m5dn, m5d.


```bash
ec2-instance-selector --vcpus-to-memory-ratio 1:4 --vcpus-min 2 --vcpus-max=4 --burst-support=1 --gpus 0 --current-generation -a x86_64 --deny-list '.*n.*|.*d.*'     
```

This should display a list like the one that follows (note results might differ depending on the region). We will use these instance types as part or EC2 Auto Scaling groups.

```
m4.large
m4.xlarge
m5.large
m5.xlarge
m5a.large
m5a.xlarge          
```
{{% notice warning %}}Your workload may have other constraints that you should consider when selecting instances types. For example. **t2** and **t3** instance types are [burstable instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances.html) and might not be appropriate for CPU bound workloads that require CPU execution determinism. Instances such as m5**a** are [AMD Instances](https://aws.amazon.com/ec2/amd/), if your workload is sensitive to numerical differences (i.e. financial risk calculations, industrial simulations) mixing these instance types might not be appropriate.
{{% /notice %}}

{{% notice note %}}
We encourage you to test what are the options available with `ec2-instance-selector` and run a few commands with it to familiarize yourself with the tool.For example, try running the same commands as you did before with the extra parameter **`--output table-wide`**.
{{% /notice %}}

