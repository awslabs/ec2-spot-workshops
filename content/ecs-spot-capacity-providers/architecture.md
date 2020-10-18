---
title: "Architecture"
date: 2020-04-15T08:30:11-07:00
weight: 4
---

Your Challenge
---

Your company hosts an external facing Apache web servers serving millions of users across the globe, based on microservice architecture and running inside docker containers on an Amazon ECS Cluster. The underlying compute for the ECS Cluster is completely based on EC2 On-demand Instances. The current auto scale in/out of the EC2 instances is based on the vCPU reservation metrics. However, it is observed that the ECS Cluster does not scale fast enough to handle the sudden surge of web traffic during peak hours. And also, during the scale in, sometimes EC2 instances that are actively running ECS tasks are getting terminated, causing disruption to the web service. 

Along with faster service response time, the company is also looking to optimize costs. AAs a long term strategy, your company does not want invest resources in undifferentiated heavy lifting such as managing the underlying computing infrastructure. The company also wants to evaluate running some of the containerized workloads on a serverless container platform, to further focus on the application and not the infrastructure.

You were introduced to Amazon EC2 Spot Instances and a few ECS features that can improve auto scaling configuration and efficiency. You were asked by your manager to re-architect the existing the solution with EC2 Spot and explore both EC2 Spot Instances and serverless options such as Fargate and Fargate Spot. Apart from cost optimization, you are also expected to improve the cluster scaling and increase the resilience of the application.

What are the various options you have to incorporate Spot Instances in your architecture? 
How do you decide which one is the right solution for the workload? How do you plan to improve the cluster scaling?

Here is the overall architecture of what you will be building throughout this workshop. By the end of the workshop, you will achieve the following 

1. Explore the serverless computing options such as Fargate and Fargate Spot for the compute platform.
2. Explore EC2 Spot Instances along with existing EC2 on-demand instances for the compute platform.
3. Leverage ECS new features to improve the ECS Cluster scaling
4. Prevent the termination of instances that are running tasks to minimize the service disruption.


#### Here is a diagram of the resulting architecture:
![Overall Architecture](/images/ecs-spot-capacity-providers/architecture.gif)
