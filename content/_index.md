---
title: "Amazon EC2 Spot Workshops"
date: 2019-01-06T12:22:13Z
draft: false
---
# Welcome to the Amazon EC2 Spot Instances Workshops website

![spot_logo](/images/spotlogo.png )

### Overview

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in 
the AWS cloud at steep discounts compared to On-Demand instances. Spot Instances enable you to optimize 
your costs on the AWS cloud and scale your application's throughput up to 10X for the same budget.

Spot Instances can be interrupted by EC2 with two minutes of notification when EC2 needs the capacity 
back. You can use Spot Instances for various fault-tolerant and flexible applications, such as 
big data, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, 
CI/CD and other test & development workloads. 

This website contains a set of workshops designed for you to get familiar with EC2
Spot Instances and how to use them in different scenarios. The workshops highlight 
best practices to follow when using EC2 Spot instances in your 
applications and workloads.

Select a workshop from the left panel or just click and explore the workshops hightlighted below.

{{< card important_workshop 
    "running-amazon-ec2-workloads-at-scale" 
    "Running EC2 Workloads at Scale with EC2 Auto Scaling"
    "Amazon-EC2_Auto-Scaling_light-bg.png" 
>}}
This workshop is designed to get you familiar with best practices for requesting 
Amazon EC2 capacity at scale in a cost optimized architecture.
{{< /card >}}

{{< card important_workshop 
    "running_spark_apps_with_emr_on_spot_instances"
    "Running Spark apps with EMR on Spot instances"
    "Amazon-EC2_Instances_light-bg.png" 
>}}
In this workshop you will assume the role of a data engineer, tasked with cost optimizing the organization’s 
costs for running Spark applications, using Amazon EMR and EC2 Spot Instances.
{{< /card >}}

{{< card important_workshop 
    "using_ec2_spot_instances_with_eks"
    "Using Spot Instances with EKS"
    "Amazon-Elastic-Container-Service-for-Kubernetes.svg" 
>}}
In this workshop, you learn how to provision, manage, and maintain your Amazon Kubernetes clusters with Amazon EKS at any scale on Spot Instances to architect for optimizations on cost and scale.
{{< /card >}}

{{< card workshop 
    "ec2_spot_fleet_web_app"
    "EC2 Spot Fleet Web App"
    "AWS-Lambda_Lambda-Function_light-bg.png" 
>}}
This workshop is designed to understand how to take advantage of Amazon EC2 
Spot instance interruption notices using lambda functions.
{{< /card >}}







