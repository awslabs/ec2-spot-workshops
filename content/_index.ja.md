---
title: "Amazon EC2 Spot Workshops"
date: 2019-01-06T12:22:13Z
draft: false
---
# EC2スポットインスタンスワークショップへようこそ！

![spot_logo](/images/spotlogo.png )

### Overview

[Amazon EC2 スポットインスタンス](https://aws.amazon.com/ec2/spot/)はAWSの空きキャパシティを活用した、オンデマンドインスタンスに比べて大幅な割引でお使いいただけるEC2インスタンスの購入オプションのひとつです。スポットインスタンスを活用することでAWSの使用コストを最適化し、アプリケーションの対費用スループットを10倍にも高めることができます。


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

{{< card workshop 
    "launching_ec2_spot_instances"
    "Launching EC2 Spot Instances"
    "Amazon-EC2_Spot-Instance_light-bg.png" 
>}}
In this workshop you will explore different ways of requesting Amazon EC2 Spot requests
and understand how to qualify workloads for EC2 Spot.
{{< /card >}}

{{< card workshop 
    "ec2_spot_fleet_web_app"
    "EC2 Spot Fleet Web App"
    "AWS-Lambda_Lambda-Function_light-bg.png" 
>}}
This workshop is designed to understand how to take advantage of Amazon EC2 
Spot instance interruption notices using lambda functions.
{{< /card >}}







