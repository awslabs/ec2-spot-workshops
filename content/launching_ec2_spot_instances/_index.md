---
title: "Launching EC2 Spot Instances"
date: 2019-01-31T08:51:33Z
weight: 20
pre: "<b>⁃ </b>"
---

## Overview

Amazon EC2 Spot instances are spare compute capacity in the AWS Cloud
available to you at steep discounts compared to On-Demand prices. EC2
Spot enables you to optimize your costs on the AWS cloud and scale your
application’s throughput up to 10X for the same budget.

This lab will walk you through the APIs and commands used to create EC2 Spot instances: you will create an EC2 Launch Template, and then use this Launch Template to launch EC2 Spot instances using: Amazon EC2 Auto Scaling groups, EC2 Spot Fleet, EC2 Fleet and the EC2 RunInstances API.

## So which of these methods should I use in my application?
For most workloads and scenarios the answer will be Auto Scaling groups. With the launch of [EC2 Auto Scaling Groups With Multiple Instance Types & Purchase Options] (https://aws.amazon.com/blogs/aws/new-ec2-auto-scaling-groups-with-multiple-instance-types-purchase-options/), it has become a feature-rich tool for building applications on EC2 using Spot instances, with allocation strategies as capacity-optimized. [Click here]  (https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html) to learn more about EC2 Auto Scaling groups.


## Pre-Requisites for this lab:

 - An AWS account. You will create AWS resources during the workshop.
 - A laptop with Wi-Fi running Microsoft Windows, Mac OS X, or Linux.
 - An Internet browser such as Chrome, Firefox, Safari, or Edge.
 - AWS CloudShell configured with your console credentials.
