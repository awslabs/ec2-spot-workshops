+++
title = "Scaling ECS Workloads"
weight = 30
+++

There are different approaches for scaling a system. Traditionally systems have used, what we call an **Infrastructure First** approach, where the system focuses on infrastructure metrics such as CPU or Memory usage, and scales up the cluster infrastructure. In this case the application scales up following the metrics derived from the infrastructure.

While you can still use that approach on ECS, ECS follows an **Application First** scaling approach, where the scaling is based on the number of desired. ECS has two type of scaling activities: 

* **ECS Service / Application Scaling**: This refers to the ability to increase or decrease the desired count of tasks in your Amazon ECS service based on dynamic traffic and load patterns in the workload.  Amazon ECS publishes CloudWatch metrics with your service’s average CPU and memory usage. You can use these and other CloudWatch metrics to scale out your service (add more tasks) to deal with high demand at peak times, and to scale in your service (run fewer tasks) to reduce costs during periods of low utilization. 

* **ECS Container Instances Scaling**: This refers to the ability to increase or decrease the desired count of EC2 instances in your Amazon ECS cluster based on ECS Service / Application scaling. For this kind of scaling, it is typical practice depending upon Auto Scaling group level scaling policies. 


To scale the infrastructure using the **Application First** approach on ECS, we will use Amazon ECS cluster **Capacity Providers** to determine the infrastructure in use for our tasks and we will use Amazon ECS **Cluster Auto Scaling** (CAS) to enables to manage the scale of the cluster according to the application needs.

Capacity Providers configuration include:

* An **Auto Scaling Group** to associate with the capacity provider. The Autoscaling group must already exist.
* An attribute to enable/disable **Managed scaling**; if enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group through the use of AWS Auto Scaling scaling plan also referred to as **Cluster Auto Scaling** (CAS). This also means you can scale up your ECS cluster zero capacity in the Auto Scaling group.  
* An attribute to define the **Target capacity %(percentage)** - number between 1 and 100. When **managed scaling** is enabled this value is used as the target value against the metric used by Amazon ECS-managed target tracking scaling policy. 
* An attribute to define **Managed termination protection**. which prevents EC2 instances that contain ECS tasks and that are in an Auto Scaling group from being terminated during scale-in actions.


Each ECS cluster can have one or more capacity providers and an optional default capacity provider strategy. For an ECS Cluster there is a **Default capacity provider strategy** that can be set for Newly created tasks or services on the cluster that are created without an explicit strategy. Otherwise, for those services or tasks where the default capacity provider strategy does not meet your needs you can define a **capacity provider strategy** that is specific for that service or task.

{{% notice info %}}
You can read more about **Capacity Provider Strategies** [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html)
{{% /notice %}}

# ECS Cluster Auto scaling

When enabling **managed scaling** Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group. This is what we call ECS **Cluster Auto Scaling (CAS)**. CAS is a new capability for ECS to manage the scaling of EC2 Auto Scaling groups (ASG). CAS relies on ECS capacity providers.

Amazon ECS creates an AWS Auto Scaling scaling plan with a target tracking scaling policy based on the target capacity value you specify. Amazon ECS then associates this scaling plan with your Auto Scaling group. For each of the capacity providers with managed scaling enabled, an Amazon ECS managed CloudWatch metric with the prefix `AWS/ECS/ManagedScaling` is created along with two CloudWatch alarms. The CloudWatch metrics and alarms used to monitor the container instance capacity in your Auto Scaling groups and will trigger the Auto Scaling group to scale in and scale out as needed.

The scaling policy uses a new CloudWatch metric called **CapacityProviderReservation** that ECS publishes for every ASG capacity provider that has managed scaling enabled. The new CloudWatch metric CapacityProviderReservation is defined as follows.

```bash
CapacityProviderReservation  = ( M / N ) x 100
```

Where: 

*  **N** represents the current number of instances in the Auto Scaling group(ASG) that are **already running**
*  **M** represents the number of instances running in an ASG necessary to meet the needs of the tasks assigned to that ASG, including tasks already running and tasks the customer is trying to run that don’t fit on the existing instances. 

Given this assumption, if N = M, scaling out not required, and scaling in isn’t possible. If N < M, scale out is required because you don’t have enough instances.  If N > M, scale in is possible (but not necessarily required) because you have more instances than you need to run all of your ECS tasks.The CapacityProviderReservation metric is a relative proportion of Target capacity value and dictates how much scale-out / scale-in should happen.  CAS always tries to ensure **CapacityProviderReservation** is equal to specified Target capacity value either by increasing or decreasing number of instances in ASG.

The scale-out activity is triggered if **`CapacityProviderReservation` > `Target capacity`** for 1 datapoints with 1 minute duration. That means it takes 1 minute to scale out the capacity in the ASG. The scale-in activity is triggered if CapacityProviderReservation < Target capacity for 15 data points with 1 minute duration. We will see all of this demonstrated in this workshop.

{{% notice info %}}
You can read more about **ECS Cluster Auto Scaling (CAS)** and how it works under different scenarios and conditions **[in this blog post](https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/)**
{{% /notice %}}