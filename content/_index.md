---
title: "Amazon EC2 Spot Workshops"
date: 2019-01-06T12:22:13Z
draft: false
---
## Welcome to the Efficient Compute - Hands on Workshops

---


#### Efficient Compute Workshops offers a comprehensive series of hands-on workshops designed to enhance your proficiency with Amazon EC2 Spot Instances and AWS Graviton Instances across various workloads. These workshops emphasize best practices for efficiently utilizing compute resources, selecting suitable EC2 purchasing options to optimize costs, and improving efficiency by selecting the appropriate CPU architecture (such as ARM and x86)


## About Spot Instances

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in 
the AWS cloud at steep discounts compared to On-Demand instances. Spot Instances enable you to optimize 
your costs on the AWS cloud and scale your application's throughput up to 10X for the same budget. 


Spot Instances can be interrupted by EC2 with two minutes of notification when EC2 needs the capacity 
back. You can use Spot Instances for various fault-tolerant and flexible applications, such as 
big data, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, 
CI/CD and other test & development workloads. 

## Quick comparison of Spot with other purchasing options.

![EC2 Purchasing Options](/images/ec2-purchasing-options.png)

#### Explore the most used workshops below. You can access full catalog of EC2 Spot workshops from the left menu.

{{< card important_workshop
    "karpenter" 
    "Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization"
    "karpenter/Karptneter-small.png" 
>}}
In this workshop, you will learn how to provision, manage, and maintain your Kubernetes clusters with Amazon Elastic Kubernetes Service (Amazon EKS ) scaling optimally using Karpenter . Karpenter is a node lifecycle management solution used to scale your Kubernetes cluster. Karpenter observes incoming pods and launches the right-sized Amazon EC2 Instance appropriately for the workload. Instance selection decisions are intent based and driven by the specification of incoming pods, including resource requests and scheduling constraints.
{{< /card >}}

{{< card important_workshop 
    "running_spark_apps_with_eks_on_spot_instances"
    "Running Spark Apps with EKS on Spot Instances"
    "Amazon-Elastic-Container-Service-for-Kubernetes.svg" 
>}}
In this workshop, fill the roles of Data Engineer/Platform Engineer/Data Analyst and learn to build a data processing pipeline on Kubernetes with a focus on cost-efficiency, scale, and observability. Start with a ready-to-use Amazon EKS cluster and a AWS Cloud9 IDE with Terraform installed. Then, learn to use Data on EKS Blueprints to deploy Apache Airflow, Kubernetes Operator for Apache Spark and observability Add-ons. You must bring your laptop to participate.
{{< /card >}}

{{< card important_workshop 
    "ec2-auto-scaling-with-multiple-instance-types-and-purchase-options" 
    "EC2 Auto Scaling"
    "Amazon-EC2_Auto-Scaling_light-bg.png" 
>}}
This workshop is designed to get you familiar with best practices for requesting 
Amazon EC2 capacity at scale in a cost optimized architecture.
{{< /card >}}

{{< card important_workshop 
    "launching_ec2_spot_instances"
    "Launching EC2 Spot instances"
    "Amazon-EC2_Instances_light-bg.png" 
>}}
In this workshop, you will learn how to leverage Managed Spot Training with Amazon SageMaker to save up to 70-90% on your Amazon SageMaker Training Jobs.
{{< /card >}}








