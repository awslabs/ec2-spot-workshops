---
title: "EMR Instance Fleets"
weight: 30
---

When adopting Spot Instances into your workload, it is recommended to be flexible around how to launch your workload in terms of Availability Zone and Instance Types. This is in order to be able to achieve the required scale from multiple Spot capacity pools (a combination of EC2 instance type in an availability zone) or one capacity pool which has sufficient capacity, as well as decrease the impact on your workload in case some of the Spot capacity is interrupted with a 2-minute notice when EC2 needs the capacity back, and allow EMR to replenish the capacity with a different instance type.

With EMR instance fleets, you specify target capacities for On-Demand Instances and Spot Instances within each fleet (Master, Core, Task). When the cluster launches, Amazon EMR provisions instances until the targets are fulfilled. You can specify up to five EC2 instance types per fleet for Amazon EMR to use when fulfilling the targets. You can also select multiple subnets for different Availability Zones.\

{{% notice info %}}
[Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) to learn more about EMR Instance Fleets in the official documentation.
{{% /notice %}}

**When Amazon EMR launches the cluster, it looks across those subnets to find the instances and purchasing options you specify, and will select the Spot Instances with the lowest chance of getting interrupted, for the lowest cost.**


While a cluster is running, if Amazon EC2 reclaims a Spot Instance or if an instance fails, Amazon EMR tries to replace the instance with any of the instance types that you specify in your fleet. This makes it easier to regain capacity in case some of the instances get interrupted by EC2 when it needs the Spot capacity back.\
These options do not exist within the default EMR configuration option "Uniform Instance Groups", hence we will be using EMR Instance Fleets only.
