---
title: "ECS: Cost Optimize Container Workloads using Spot"
date: 2020-04-15T09:05:54Z
weight: 39
pre: "<b>⁃ </b>"
---

## Overview


Welcome! In this workshop you learn how to **cost optimize** running a sample container based web application, using Amazon ECS and EC2 Spot Instances.  

The *estimated time* for completing the workshop is 90-120 minutes.  

The **learning objective** of this hands-on workshop is to help understand the different options to cost optimize container workloads running on [***Amazon ECS***] (https://aws.amazon.com/ecs/) using [***EC2 Spot Instances***] (https://aws.amazon.com/ec2/spot/) and [***Amazon Fargate Spot***] (https://aws.amazon.com/fargate/).  

This workshop covers ECS Cluster Auto scaling(by using **[Capacity Providers] (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html)**) on two compute options, user managed compute on **EC2** and fully managed serverless compute on **Amazon Fargate.**


### About Spot Instances in Containerized workloads

Many containerized workloads are usually stateless and fault tolerant and are great fit for running them on EC2 Spot. In this workshop we will explore how to run containers on inturruptable EC2 Spot instances and save significantly compared to running them on EC2 On-Demand instances.
