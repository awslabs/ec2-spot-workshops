---
title: "Launching EC2 Spot Instances"
menuTitle: "Launching Spot Instances"
date: 2019-01-31T08:51:33Z
weight: 10
pre: "<b>1. </b>"
---

## Overview

In this workshop, you will learn how to provision, and maintain EC2 Spot Instances capacity using [Amazon EC2 Auto Scaling groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html), and [EC2 Fleet](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet.html) in instant mode, leveraging [Launch Templates](https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-templates.html) to specify instance configuration information. You will learn to take advantage of AWS tools to implement EC2 Spot best practices. Firstly, we will use [attribute-based instance selection](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html) to implement instance diversity and flexibility based on EC2 metadata.  Secondly, you will use [Spot Placement Score](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-placement-score.html) to determine which Region/AZ has optimal EC2 Spot capacity for you workloads. Thirdly, you will learn to use [Amazon Fault Injection Simulator](https://aws.amazon.com/fis/) to triggering an EC2 Spot Instance interruption so that you can test resiliency of your workload. Lastly, you will learn to use [Spot Blueprints](https://console.aws.amazon.com/ec2sp/v2/home?region=us-east-1#/spot/blueprints?show_feedback=true) to quickly get complete workload configuration in infrastructure as code templates. In short, this workshop is intended to showcase the steps you need to quickly kick-start your Spot journey using Amazon EC2 Auto Scaling or EC2 Fleet.

## Background

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt EC2 Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use EC2 Spot Instances for various fault-tolerant and flexible applications. Spot workloads should be flexible, meaning they can utilize a variety of different EC2 instance types and/or have the ability to be run real time where the spare capacity currently is. 

Some examples of workloads running on EC2 Spot are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads. 

AWS services including [Amazon EKS](https://aws.amazon.com/eks/), [Amazon ECS](https://aws.amazon.com/ecs/), [Amazon EMR](https://aws.amazon.com/emr/), and [AWS Batch](https://aws.amazon.com/batch/), integrate with Spot to reduce overall compute costs without the need to manage the individual instances or fleets. If one of these AWS integrations is not a fit for your workload, or you want to manage the EC2 Spot capacity directly, you should use [Amazon EC2 Auto Scaling groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html). If you are looking for more control over the provisioning of EC2 Spot instances or fleet, you should use [EC2 Fleet](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet.html) in instant mode. 

## Estimated workshop length

45-60 minutes

