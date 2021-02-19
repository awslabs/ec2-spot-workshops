---
title: "Architecture"
date: 2020-04-15T08:30:11-07:00
weight: 10
---

Your Challenge
---

Your company hosts external-facing Apache web servers serving millions of users across the globe, based on micro-services architecture running inside Docker containers on an Amazon ECS Cluster. The underlying compute for the ECS Cluster is completely based on EC2 On-demand instances. Your company is forecasting huge traffic in the next couple of months and would like to leverage Amazon EC2 Spot instances for cost optimization. 

Also, the current scale in/out policies are based on the vCPU reservation metrics of the EC2 instances. However, it is observed that the ECS cluster does not scale fast enough to handle the sudden surge of web traffic during peak hours. During the scale in, sometimes EC2 instances that are actively running ECS tasks are getting terminated, causing disruption to the web service. 

As a long-term strategy, your company does not want to invest resources in undifferentiated heavy lifting of managing the underlying computing infrastructure and instead would like to evaluate running some containerized workloads on a serverless container platform, to further focus on the application and not the infrastructure.

You were introduced to Amazon EC2 Spot instances and few ECS features that can improve cluster scaling and increase the resilience of the applications. Your manager ask you to build a PoC to test all these features. 

* What options do you have to incorporate EC2 Spot instances in your architecture? 
* How do you plan to improve the cluster scaling and resilience of the applications?
 
Here is the overall architecture. By the end of the workshop, you will achieve the following objectives.

1. Explore the serverless computing options such as ECS Fargate and ECS Fargate Spot.
2. Explore both EC2 Spot and On-Demand instances for the underlying compute platform.
3. Leverage ECS features such capacity providers and Cluster Autoscaling (CAS) to improve the scaling and resilience of the applications


#### Amazon ECS Application Architecture:
![Overall Architecture](/images/ecs-spot-capacity-providers/amazon_ecs_arch.png)
