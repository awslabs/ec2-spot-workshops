---
title: "EMR Instance Fleets"
weight: 30
---

With EMR instance fleets, you specify target capacities for On-Demand Instances and Spot Instances within each fleet (Master, Core, Task). When the cluster launches, Amazon EMR provisions instances until the targets are fulfilled. You can specify up to five EC2 instance types per fleet for Amazon EMR to use when fulfilling the targets. You can also select multiple subnets for different Availability Zones.

**When Amazon EMR launches the cluster, it looks across those subnets to find the instances and purchasing options you specify, and will select the Spot Instances with the lowest chance of getting interrupted, for the lowest cost.**


While a cluster is running, if Amazon EC2 reclaims a Spot Instance or if an instance fails, Amazon EMR tries to replace the instance with any of the instance types that you specify in your fleet. This makes it easier to regain capacity in case some of the instances get interrupted by EC2 when it needs the Spot capacity back.