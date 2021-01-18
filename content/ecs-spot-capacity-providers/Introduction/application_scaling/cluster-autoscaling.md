+++
title = "ECS Cluster Auto scaling"
weight = 20
+++

  

When creating a capacity provider, you can optionally enable **managed scaling**. When managed scaling enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group. This is what we call ECS **Cluster Auto Scaling (CAS)**. CAS is a new capability for ECS to manage the scaling of EC2 Auto Scaling groups (ASG). CAS relies on ECS capacity providers.

On your behalf, Amazon ECS creates an AWS Auto Scaling scaling plan with a target tracking scaling policy based on the target capacity value you specify. Amazon ECS then associates this scaling plan with your Auto Scaling group. For each of the capacity providers with managed scaling enabled, an Amazon ECS managed CloudWatch metric with the prefix AWS/ECS/ManagedScaling is created along with two CloudWatch alarms. The CloudWatch metrics and alarms used to monitor the container instance capacity in your Auto Scaling groups and will trigger the Auto Scaling group to scale in and scale out as needed.

The scaling policy uses a new CloudWatch metric called **CapacityProviderReservation** that ECS publishes for every ASG capacity provider that has managed scaling enabled. The new CloudWatch metric CapacityProviderReservation is defined as follows.

```bash
CapacityProviderReservation  = ( M / N ) x 100
```

With N representing:

*  **N** : Current number of instances in the Auto Scaling group(ASG) that are **already running**
*  **M** : The number of instances running in an ASG necessary to meet the needs of the tasks assigned to that ASG, including tasks already running and tasks the customer is trying to run that don’t fit on the existing instances. 

Given this assumption, if N = M, scaling out not required, and scaling in isn’t possible. If N < M, scale out is required because you don’t have enough instances.  If N > M, scale in is possible (but not necessarily required) because you have more instances than you need to run all of your ECS tasks.The CapacityProviderReservation metric is a relative proportion of Target capacity value and dictates how much scale-out / scale-in should happen.  CAS always tries to ensure **CapacityProviderReservation** is equal to specified Target capacity value either by increasing or decreasing number of instances in ASG.

The scale-out activity is triggered if CapacityProviderReservation > Target capacity for 1 datapoints with 1 minute duration. That means it takes 1 minute to scale out the capacity in the ASG. The scale-in activity is triggered if CapacityProviderReservation < Target capacity for 15 datapoints with 1 minute duration. We will see all of this demonstrated in this workshop.

{{% notice info %}}
You can read more about **ECS Cluster Auto Scaling (CAS)** and how it works under different scenarios and conditions **[in this blog post](https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/)**
{{% /notice %}}

