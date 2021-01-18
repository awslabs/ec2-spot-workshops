+++
title = "Introduction to Containers"
weight = 10
+++

![Container Ship](/images/ecs-spot-capacity-providers/containership.jpg)

What is a Container?
---

* Containers provide a standard way to package your application’s code, configurations, and dependencies into a single object.
* Containers share an operating system installed on the server and run as a resource-isolated processes, ensuring quick, reliable, and consistent deployments, regardless of environment.
* Whether you deploy locally on your laptop or to production, the experience will remain the same (except secrets and other environmental values, of course).

Why Containers?
---
Containers allow developers to iterate at high velocity and offer the speed to scale to meet the demands of the application. It is first important to understand what a container is, and how it enables teams to move faster.

Benefits of Containers
---

Containers are a powerful way for developers to package and deploy their applications. They are lightweight and provide a consistent, portable software environment for applications to easily run and scale anywhere. Building and deploying microservices, running batch jobs, for machine learning applications, and moving existing applications into the cloud is just some popular use cases for containers. 

Amazon EC2 Spot Instances
---

[Amazon EC2 Spot Instances] (https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.
