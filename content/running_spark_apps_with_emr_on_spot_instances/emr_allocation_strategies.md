---
title: "EMR Allocation Strategies"
weight: 35
---

As an enhancement to the default EMR instance fleets cluster configuration, the allocation strategy feature is available in EMR version 5.12.1 and later. It optimizes the allocation of instance fleet capacity and lets you choose a target strategy for each cluster node. 

* On-Demand instances use a lowest-price strategy, which launches the lowest-priced instances first.
* Spot instances use a capacity-optimized strategy, which launches Spot instances from Spot instance pools that have optimal capacity for the number of instances that are launching.

{{% notice note %}}
The allocation strategy option also lets you specify up to 15 EC2 instance types per task node when creating your cluster, as opposed to 5 maximum allowed by the default EMR cluster instance fleet configuration.
{{% /notice %}}

The capacity-optimized allocation strategy for Spot instances uses real-time capacity data to allocate instances from the Spot instance pools with the optimal capacity for the number of instances that are launching. This allocation strategy is appropriate for workloads that have a higher cost of interruption. Examples include long-running jobs and multi-tenant persistent clusters running Apache Spark, Apache Hive, and Presto. This allocation strategy lets you specify up to 15 EC2 instance types on task instance fleets to diversify your Spot requests and get steep discounts. Previously, instance fleets allowed a maximum of five instance types. You can now diversify your Spot requests across these 15 pools within each Availability Zone and prioritize deploying into a deeper capacity pool to lower the chance of interruptions. With more instance type diversification, Amazon EMR has more capacity pools to allocate capacity from, and chooses the Spot Instances which are least likely to be interrupted.

{{% notice info %}}
[Click here] (https://aws.amazon.com/blogs/big-data/optimizing-amazon-emr-for-resilience-and-cost-with-capacity-optimized-spot-instances/) For an in-depth blog post about capacity-optimized allocation strategy for Amazon EMR instance fleets.
{{% /notice %}}