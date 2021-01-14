---
title: "EMR Instance Fleets"
weight: 30
---

When adopting Spot Instances into your workload, it is recommended to be flexible around how to launch your workload in terms of Availability Zone and Instance Types. This is in order to be able to achieve the required scale from multiple Spot capacity pools (a combination of EC2 instance type in an availability zone) or one capacity pool which has sufficient capacity, as well as decrease the impact on your workload in case some of the Spot capacity is interrupted with a 2-minute notice when EC2 needs the capacity back, and allow EMR to replenish the capacity with a different instance type.

With EMR instance fleets, you specify target capacities for On-Demand Instances and Spot Instances within each fleet (Master, Core, Task). When the cluster launches, Amazon EMR provisions instances until the targets are fulfilled. You can specify up to five EC2 instance types per fleet for Amazon EMR to use when fulfilling the targets. You can also select multiple subnets for different Availability Zones.  

{{% notice info %}}
[Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) to learn more about EMR Instance Fleets in the official documentation.
{{% /notice %}}

While a cluster is running, if Amazon EC2 reclaims a Spot Instance or if an instance fails, Amazon EMR tries to replace the instance with any of the instance types that you specify in your fleet. This makes it easier to regain capacity in case some of the instances get interrupted by EC2 when it needs the Spot capacity back.

These options do not exist within the default EMR configuration option "Uniform Instance Groups", hence we will be using EMR Instance Fleets only.

As an enhancement to the default EMR instance fleets cluster configuration, the allocation strategy feature is available in EMR version **5.12.1 and later**. With allocation strategy:    
* On-Demand instances use a lowest-price strategy, which launches the lowest-priced instances first.  
* Spot instances use a [capacity-optimized] (https://aws.amazon.com/about-aws/whats-new/2020/06/amazon-emr-uses-real-time-capacity-insights-to-provision-spot-instances-to-lower-cost-and-interruption/) allocation strategy, which allocates instances from most-available Spot Instance pools and lowers the chance of interruptions. This allocation strategy is appropriate for workloads that have a higher cost of interruption such as persistent EMR clusters running Apache Spark, Apache Hive, and Presto.

{{% notice note %}}
This allocation strategy option also lets you specify **up to 15 EC2 instance types on task instance fleet**. By default, Amazon EMR allows a maximum of 5 instance types for each type of instance fleet. By enabling allocation strategy, you can diversify your Spot request for task instance fleet across 15 instance pools. With more instance type diversification, Amazon EMR has more capacity pools to allocate capacity from, this allows you to get more compute capacity. 
{{% /notice %}}

{{% notice info %}}
[Click here] (https://aws.amazon.com/blogs/big-data/optimizing-amazon-emr-for-resilience-and-cost-with-capacity-optimized-spot-instances/) for an in-depth blog post about capacity-optimized allocation strategy for Amazon EMR instance fleets.
{{% /notice %}}