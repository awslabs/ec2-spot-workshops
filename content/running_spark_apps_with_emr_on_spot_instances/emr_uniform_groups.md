---
title: "EMR Uniform Groups"
weight: 20
---

When using the EMR console to create a cluster via the quick settings, default advanced settings, or with the AWS CLI - Amazon EMR will provision your EMR cluster with a configuration option called "Uniform Instance Groups".

With the Uniform Groups configuration option, you select the Availability Zone in which you want to launch your EMR cluster, and one instance type per group (Master, Core, and optional multiple Task groups). 

When adopting Spot Instances into your workload, it's required to be flexible around how to launch your workload in terms of Availability Zone and Instance Types. This is in order to be able to achieve the required scale from multiple Spot capacity pools (a combination of EC2 instance type in an availability zone) or one capacity pool which has sufficient capacity, as well as decrease the impact on your workload in case some of the Spot capacity is interrupted with a 2-minute notice when EC2 needs the capacity back, and allow EMR to replenish the capacity with a different instance type.

For that reason, we will not use EMR Uniform Groups configuration option in this workshop. Instead, we will focus on the more robust and Spot friendly configuration option - **EMR Instance Fleets** - continue the workshop to learn more and use this configuration option.