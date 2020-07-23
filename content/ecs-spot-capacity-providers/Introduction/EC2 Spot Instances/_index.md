+++
title = "Introduction to EC2 Spot Instances"
chapter = true
weight = 15
+++

Introduction to Amazon EC2 Spot Instances
---

[EC2 Spot Instances] (https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

Spot Instances in Containerized workloads
---

Many containerized workloads are usually stateless and fault tolerant and are great fit for running them on EC2 Spot. In this workshop we will explore how to run containers on inturruptable EC2 Spot instances and save significantly compared to running them on EC2 On-Demand instances.
