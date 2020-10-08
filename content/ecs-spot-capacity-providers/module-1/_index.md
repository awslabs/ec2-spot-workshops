---
title: "Module-1: Cost optimizing ECS using Spot Instances with Auto Scaling groups Capacity Providers"
chapter: true
weight: 20
---

### Amazon ECS Cluster Auto Scaling

Amazon ECS cluster auto scaling enables you to have more control over how you scale tasks within a cluster. Each cluster has one or more capacity providers and an optional default capacity provider strategy. The capacity providers determine the infrastructure to use for the tasks, and the capacity provider strategy determines how the tasks are spread across the capacity providers. When you run a task or create a service, you may either use the cluster's default capacity provider strategy or specify a capacity provider strategy that overrides the cluster's default strategy

### Amazon ECS Capacity Providers

Amazon ECS capacity providers use EC2 Auto Scaling groups to manage the Amazon EC2 instances registered to their clusters.


### Amazon ECS Capacity Provider - Managed Scaling

When creating a capacity provider, you can optionally enable managed scaling. When managed scaling is enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group. On your behalf, Amazon ECS creates an AWS Auto Scaling scaling plan with a target tracking scaling policy based on the target capacity value you specify. Amazon ECS then associates this scaling plan with your Auto Scaling group. For each of the capacity providers with managed scaling enabled, an Amazon ECS managed CloudWatch metric with the prefix AWS/ECS/ManagedScaling is created along with two CloudWatch alarms. The CloudWatch metrics and alarms are used to monitor the container instance capacity in your Auto Scaling groups and will trigger the Auto Scaling group to scale in and scale out as needed.

