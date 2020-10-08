---
title: "Architecture"
date: 2020-04-15T08:30:11-07:00
weight: 4
---

Your Challenge
---

Your company hosts an external facing Apache web server serving millions of users across the globe. The web servers are based on the micro service architecture and running as docker containers on AWS ECS Cluster.  The underlying computing platform/dataplane  for the ECS Cluster is completely based on EC2 on-demand instances.  The current auto scale in/out of the EC2 instances is based on the vCPU based metrics. However it is observed that ECS Cluster does not scale fast enough to handle the sudden surge of web traffic during peak hours. And during the scale in, sometimes EC2 instances that are actively running ECS tasks are getting terminated, causing disruption to the web service. 

Along with faster service response time, the company is also looking to optimize costs. Also as a long term strategy, your company does not want invest resources in undifferentiated heavy lifting such as managing the underlying computing infrastructure. Also, wants to leverage any serverless options and focus on their business critical applications.

You were introduced to Amazon EC2 Spot Instances and a few ECS features that can improve autoscaling configuration and efficiency. You were asked by your manager to re-architect the existing the solution with EC2 Spot and explore both EC2 Spot Instances and serverless options such as Fargate and Fargate Spot. Apart from cost optimization, you are also expected to solve the cluster scaling issues and increase the resilience of the application.

What are the various options do you have to incorporate Spot Instances in your solution? 
How do you decide which one is the right solution for the workload? How do you plan to fix the scaling issue?

Here is the overall architecture of what you will be building throughout this workshop. By the end of the workshop, you will achieve the following 

1. Explore the serverless computing options such as Fargate and Fargate Spot for the dataplane.
2. Explore Spot Instances along with existing on-demand instances for the dataplane.
3. Fix the scaling Issues during bursts of traffic
4. Enable the instance termination protection feature, which will prevent instances with many tasks running from getting terminated.


#### Here is a diagram of the resulting architecture:
![Overall Architecture](/images/ecs-spot-capacity-providers/architecture1.png)
