---
title: "EMR Instance Fleets"
weight: 30
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



The **[instance fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html)** configuration for Amazon EMR clusters lets you select a wide variety of provisioning options for Amazon EC2 instances, and helps you develop a flexible and elastic resourcing strategy for each node type in your cluster. You can have only one instance fleet per  master, core, and task node type. In an instance fleet configuration, you specify a *target capacity* for **[On-Demand Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html)** and **[Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html)** within each fleet. 

When adopting Spot Instances into your workload, it is recommended to be flexible with selection of instance types across family, generation, sizes, and Availability Zones. With higher instance type diversification, Amazon EMR has more capacity pools to allocate capacity from, and chooses the Spot Instances which are least likely to be interrupted. 

{{% notice note %}}
EMR allows a maximum of five instance types per fleet, when you use use the default Amazon EMR cluster instance fleet configuration. However, you can specify a maximum of 15 instance types per fleet when you create a cluster using the EMR console and enable **[allocation strategy](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html#emr-instance-fleet-allocation-strategy)** option. This limit is further increased to 30 when you create a cluster using AWS CLI or Amazon EMR API and enable allocation strategy option.
{{% /notice %}}

As an enhancement to the default EMR instance fleets cluster configuration, the allocation strategy feature is available in EMR version **5.12.1 and later**. With allocation strategy EMR instance fleet with:

* On-Demand Instances uses a lowest-priced strategy, which launches the lowest-priced On-Demand Instances first.  
* Spot Instances uses a **[capacity-optimized](https://aws.amazon.com/about-aws/whats-new/2020/06/amazon-emr-uses-real-time-capacity-insights-to-provision-spot-instances-to-lower-cost-and-interruption/)** allocation strategy, which allocates instances from most-available Spot Instance pools and lowers the chance of further interruptions. This allocation strategy is appropriate for workloads that have a higher cost of interruption such as persistent EMR clusters running Apache Spark, Apache Hive, and Presto.

These options do not exist within the default EMR configuration option uniform instance groups, hence we recommend using instance fleets with Spot Instances.

{{% notice info %}}
**[Click here](https://aws.amazon.com/blogs/big-data/optimizing-amazon-emr-for-resilience-and-cost-with-capacity-optimized-spot-instances/)** for an in-depth blog post about capacity-optimized allocation strategy for Amazon EMR instance fleets.
{{% /notice %}}