+++
title = "Cluster"
chapter = true
weight = 15
+++

***Cluster***
-------------

An Amazon ECS cluster is a logical grouping of tasks or services.

If you are running tasks or services that use the EC2 launch type, a cluster is also a grouping of container instances.
If you are using capacity providers, a cluster is also a logical grouping of capacity providers.
A Cluster can be a combination of Fargate and EC2 launch types.
When you first use Amazon ECS, a default cluster is created for you, but you can create multiple clusters in an account to keep your resources separate.

For more information on ECS Clusters, see [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html).


![Amazon ECS](/images/ecs-spot-capacity-providers/ecs.png)    

[Amazon Elastic Container Service (Amazon ECS)](https://aws.amazon.com/ecs/)  is a highly scalable, high-performance container orchestration service that supports Docker containers and allows you to easily run and scale containerized applications on AWS.

Amazon ECS eliminates the need for you to install and operate your own container orchestration software, manage and scale a cluster of virtual machines, or schedule containers on those virtual machines.

ECS is also deeply integrated into the rest of the AWS ecosystem.

![ECS integration](/images/ecs-spot-capacity-providers/integration.svg)

In this section, we’ll cover the following topics:

* [Cluster] (https://ecsworkshop.com/introduction/ecs_basics/cluster/)
* Task Definitions
* Tasks and Scheduling
* Services
* Fargate
* Service Discovery