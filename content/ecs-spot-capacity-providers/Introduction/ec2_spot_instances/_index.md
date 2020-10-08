+++
title = "Amazon EC2 Spot Instances"
weight = 15
+++

[Amazon EC2 Spot Instances] (https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

### Spot Instances in Containerized workloads


Many containerized workloads are usually stateless and fault tolerant and are great fit for running on EC2 Spot Instances. In this workshop we will explore how to run containers on interruptible EC2 Spot Instances and achieve significant cost savings.