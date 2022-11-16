---
title: "Running Efficient and Resilient Workloads with Amazon EC2 Auto Scaling"
menuTitle: "Efficient EC2 Auto Scaling"
weight: 110
pre: "<b>11. </b>"
---

## Overview

Welcome! This workshop is designed to get you familiar with the concepts and best practices for managing Amazon EC2 capacity needed for workloads running with Auto Scaling groups. We will deep dive using hands-on guidance to effectively and efficiently scale capacity using [Predictive Scaling for EC2](https://aws.amazon.com/blogs/aws/new-predictive-scaling-for-ec2-powered-by-machine-learning/) and [EC2 Warm Pools](https://aws.amazon.com/blogs/compute/scaling-your-applications-faster-with-ec2-auto-scaling-warm-pools/).

In this workshop we will running this **scenario** where **you are a Cloud Architect working for a software provider company**. Your company provides a software-as-a-service application for hundreds of customers including government entities and asset-intensive industries. The software your company runs is a **monolithic** application, while it’s easy to test and deploy, it’s not flexible and adds complexity to the automatic scaling and capacity planning of the application. Due to application dependencies, it also requires initiation logic to run with each new instance added to its compute capacity which could take between **5-10 minutes**.

Your company is facing a challenge with growing customers demand and you have been asked to **1) ensure the service continues to be responsive at any time especially during the peak hours without any waste or underutilization of cloud resources.**

So far you have been **manually** controlling the desired capacity for the application based on your experience with the customers demand. There have been few incidents where the application were not available to limited number of users due to unexpected demand in capacity. The business wants to remove or reduce the likelihood of this happening again. So you have been asked to **2) ensure the service is ready to scale and operate with minimum readiness time.**

Requirements include the ability to **automatically** scale the service for traffic patterns, all without breaking the budget.


{{% notice info %}}
The estimated time for completing the workshop is **60-90 minutes.**
{{% /notice %}}