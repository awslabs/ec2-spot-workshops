---
title: "Launching EC2 Spot Instances"
date: 2019-01-31T08:51:33Z
weight: 10
pre: "<b>1 </b>"
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Launching EC2 Spot Instances](https://catalog.us-east-1.prod.workshops.aws/workshops/36a2c2bb-b92d-4428-8626-3a75df01efcc/en-US)**.

{{% /notice %}}

## Overview

Amazon EC2 Spot instances are spare compute capacity in the AWS Cloud
available to you at steep discounts compared to On-Demand prices. EC2
Spot enables you to optimize your costs on the AWS cloud and scale your
application’s throughput up to 10X for the same budget.

This lab will walk you through creating an EC2 Launch Template, and then
using this Launch Template to launch EC2 Spot Instances the following 4
ways: Amazon EC2 Auto Scaling groups, the EC2 RunInstances API, EC2 Spot Fleet, and 
EC2 Fleet.

## So which of these methods should I use in my application?
When designing your application to run on Amazon EC2, start by looking into EC2 Auto Scaling groups. With the launch of [EC2 Auto Scaling Groups With Multiple Instance Types & Purchase Options] (https://aws.amazon.com/blogs/aws/new-ec2-auto-scaling-groups-with-multiple-instance-types-purchase-options/), it has become the most comprehensive and feature-rich tool for building applications on EC2, and using Spot Instances with allocation strategies such as lowest-price and capacity-optimized. [Click here]  (https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html) to learn more about EC2 Auto Scaling groups, and check out the two workshops on this website to get hands-on experience: [Running EC2 Workloads at Scale with EC2 Auto Scaling] (https://ec2spotworkshops.com/running-amazon-ec2-workloads-at-scale.html) and [EC2 Auto Scaling with multiple instance types and purchase options] (https://ec2spotworkshops.com/ec2-auto-scaling-with-multiple-instance-types-and-purchase-options.html)


## Pre-Requisites for this lab:

 - A laptop with Wi-Fi running Microsoft Windows, Mac OS X, or Linux.
 - The AWS CLI installed and configured.
 - An Internet browser such as Chrome, Firefox, Safari, or Edge.
 - An AWS account. You will create AWS resources including IAM roles during the workshop.
