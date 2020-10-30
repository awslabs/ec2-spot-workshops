---
title: "ECS: Cost Optimize Container Workloads using Spot"
date: 2020-04-15T09:05:54Z
weight: 39
pre: "<b>⁃ </b>"
---

## Overview

Welcome! In this workshop you learn how to **cost optimize** your Amazon ECS clusters using EC2 Spot Instances.

The **learning objective** of this hands-on workshop is to help understand the different options to cost optimize container workloads running on **[Amazon ECS](https://aws.amazon.com/ecs/)** using **[EC2 Spot Instances](https://aws.amazon.com/ec2/spot/)** and **[Amazon Fargate Spot](https://aws.amazon.com/fargate/)**. This workshop covers topics such as ECS cluster auto scaling and how to scale efficiently with **[Capacity Providers](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html)** to spread your tasks across a mix of resources, both on AWS Fargate and AWS Fargate Spot as well as EC2 On-Demand and Spot Instances.


{{% notice info %}}
The estimated time for completing the workshop is **90 to 120 minutes**. The estimated cost will be less than **$5**.
{{% /notice %}}

The workshop is designed to be completed in sequence. If you are reading this at a live AWS event, the workshop attendants will give you a high level run down of the workshop. Then it's up to you to follow the instructions below to completion. Don't worry if you're embarking on this journey in the comfort of your office or home, this site contains all the materials for you'll need to complete this workshop.


### About Spot Instances in Containerized workloads

Many containerized workloads are usually stateless and fault tolerant and are great fit for running on EC2 Spot Instances. In this workshop we will explore how to run containers on interruptable EC2 Spot Instances and achieve significant cost savings.
