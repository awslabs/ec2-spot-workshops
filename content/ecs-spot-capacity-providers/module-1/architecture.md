---
title: "Architecture"
date: 2020-04-15T08:30:11-07:00
weight: 7
---

Your Challenge
---

Your company hosts an external facing Apache web servers serving millions of users across the globe, based on microservice architecture and running inside docker containers on an Amazon ECS Cluster. The underlying compute for the ECS Cluster completely based on EC2 On-demand Instances. Your company forecasting huge traffic in next couple of months and would like to leverage Amazon EC2 Spot instances for cost optimization. 

Also the current auto scale in/out of the EC2 instances based on the vCPU reservation metrics. However, it is observed that the ECS Cluster does not scale fast enough to handle the sudden surge of web traffic during peak hours. During the scale in, sometimes EC2 instances that are actively running ECS tasks are getting terminated, causing disruption to the web service. 

Also, as a long term strategy, your company does not want invest resources in undifferentiated heavy lifting of managing the underlying computing infrastructure and instead would like to evaluate running some containerized workloads on a serverless container platform, to further focus on the application and not the infrastructure.

You were introduced to Amazon EC2 Spot Instances and also few ECS features that can improve cluster scaling and increase the resilience of the applications. You were asked by your manager to build a PoC to test all these features. 

What options do you have to incorporate Spot Instances in your architecture? 
How do you plan to improve the cluster scaling and resilience of the applications?
 
Well, that is exactly what you will be building in this workshop.
Here is the overall architecture. By the end of the workshop, you will achieve the following.

1. Explore the serverless computing options such as Fargate and Fargate Spot
2. Explore both EC2 Spot and on-demand instances for compute platform.
3. Leverage ECS new features such capacity providers and cluster autoscaling to improve the scaling and resilience of the applications


#### Amazon ECS Application Architecture:
![Overall Architecture](/images/ecs-spot-capacity-providers/amazon_ecs_arch.png)
