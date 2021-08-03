+++
title = "Launching EC2 Spot Instances via EC2 Auto Scaling group"
weight = 30
+++

An Auto Scaling group contains a collection of Amazon EC2 Instances that are treated as a logical grouping for the purposes of automatic scaling and management. An Auto Scaling group also enables you to use Amazon EC2 Auto Scaling features such as health check replacements and scaling policies. Both maintaining the number of instances in an Auto Scaling group and automatic scaling are the core functionality of the Amazon EC2 Auto Scaling service.

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 Instances available to handle the load for your application. You can specify the minimum and maximum number of instances, and Amazon EC2 Auto Scaling ensures that your group never goes below or above this size.

When adopting EC2 Spot Instances, our recommendation is to consider first Auto Scaling group since it offers a very rich API with benefits like scale-in protection, health checks, lifecycle hooks, rebalance recommendation integration, warm pools and predictive scaling, and many more functionalities that we list below.

{{% notice note %}}
In the past, Auto Scaling groups used Launch Configurations. Applications using Launch Configurations should migrate to Launch Templates. With Launch Templates you can provision capacity across multiple instance types using both Spot Instances and On-Demand Instances to achieve the desired scale, performance, and cost optimization.
{{% /notice %}}

#### Auto Scaling group example: Using mixed instance groups with Spot and On-Demand capacity

A common case when using Auto Scaling groups, is to use it with workloads that require a mix
of Spot and On-Deamand capacity.

To apply Spot best practices we will launch a mixed instance Auto Scaling group using Spot and On-demand Instances.

This first step does create a *json* file. The file describes a mixed-instance-policy section with a set of overrides that drive diversification of Spot Instance pools. The configuration of the Auto Scaling group does refer to the Launch Template that we created in the previous steps.

```
cat <<EoF > ~/asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"1"
      },
      "Overrides":[
         {
            "InstanceType":"c5.large"
         },
         {
            "InstanceType":"m5.large"
         },
         {
            "InstanceType":"r5.large"
         },
         {
            "InstanceType":"c4.large"
         },
         {
            "InstanceType":"m4.large"
         },
         {
            "InstanceType":"r4.large"
         }
      ]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":2,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"capacity-optimized"
   }
}
EoF
```

In the override section, choose as many instances that qualify for your application as possible, in this case we selected a group of 6 instance types that meet the ".large" criteria.

With Auto Scaling groups you can define what is the balance between Spot vs On-Demand Instances that makes sense for your workload. `OnDemandBaseCapacity` allows you to set an initial capacity of On-Demand Instances to use. After that, any new procured capacity will be a mix of Spot and On-Demand Instances as defined by the `OnDemandPercentageAboveBaseCapacity`.

The configuration above, sets the `SpotAllocationStrategy` to `capacity-optimized`. The `capacity-optimized` allocation strategy allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching, making use of real-time capacity data and optimizing the selection of used Spot Instances. You can read about the benefits of using `capcity-optimized` in the blog post [Capacity-Optimized Spot Instance allocation in action at Mobileye and Skyscanner](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/).

Let's create the Auto Scaling group. In this case the Auto Scaling group spans across 3 Availability Zones, and sets the `min-size` to 2, `max-size` to 10 and `desired-capacity` to 6.

```
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --min-size 1 --max-size 10 --desired-capacity 6 --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --capacity-rebalance --mixed-instances-policy file://asg-policy.json
```

You have now created a mixed instances Auto Scaling group!

Given the configuration we used above, **Try to answer the following questions:**

1. How many Spot Instance pools does the Auto Scaling group consider when applying Spot
diversification?
2. How many Spot vs On-Demand Instances have been requested by the Auto Scaling group?
3. How can you confirm which instances have been created within the Auto Scaling group?
4. How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?

{{%expand "Show me the answers:" %}}

1.) **How may Spot Instance pools does the Auto Scaling group consider when applying Spot
diversification?**

Remember: A Spot capacity pool is a set of unused EC2 Instances with the same instance type (for example, m5.large) and Availability Zone. In this case we used 6 instance types and 3 Availability Zones, which makes a total of **18 Spot pools**. Increasing the number of Spot pools we diversify on, is key for adopting Spot best practices.

2.) **How many Spot vs On-Demand Instances have been requested by the Auto Scaling group?**

The `desired-capacity` of 6 is below the `max-size` of 10, so 6 instances are provisioned.
Out of them, the first 2 instances are On-Demand as requested by the `OnDemandBaseCapacity`.
The rest of the 4 instances up to the desired 6, follow a proportion of 75% Spot and 25% On-Demand according to `OnDemandPercentageAboveBaseCapacity`, which means there should be 3 Spot Instances and 3 On-demand Instances.

3.) **How can you confirm which instances have been created within the Auto Scaling group?**

To check the instances within the newly created Auto Scaling group we can use `describe-auto-scaling-groups`.

```bash
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names EC2SpotWorkshopASG
```

4.) **How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?**

To describe one or more instances we use `describe-instances`. To retrieve all the Spot Instances that have been launched with the Auto Scaling group, we apply two filters: `instance-lifecycle` set to `spot` to retrieve only Spot Instances and the custom tag `InstanceLaunchedWith` that must be set to `EC2SpotWorkshopASG`.

```bash
aws ec2 describe-instances --filters Name=instance-lifecycle,Values=spot Name=tag:aws:autoscaling:groupName,Values=EC2SpotWorkshopASG --query "Reservations[*].Instances[*].[InstanceId]" --output text
```

The output will have the identifiers of the **3** Spot Instances, as we have deduced in the second question.

Similarly, you can run the following command to retrieve the identifiers of the instances that have been launched using the On-Demand purchasing model.

```bash
aws ec2 describe-instances --filters Name=tag:aws:autoscaling:groupName,Values=EC2SpotWorkshopASG --query "Reservations[*].Instances[? InstanceLifecycle==null].[InstanceId]" --output text
```

{{% /expand %}}

{{% notice tip %}}
Auto Scaling group has rich functionality that helps reduce the heavy lifting of managing capacity. Auto Scaling groups can dynamically increase and decrease capacity as needed.
{{% /notice %}}


#### Brief Summary of Auto Scaling group functionality
These are some of the characteristics and functionality that make Amazon EC2 Auto Scaling groups the right choice for most workloads:

1. **Instance distribution & Availability Zone rebalancing**: Amazon EC2 Auto Scaling groups attempt to distribute instances evenly to maximise the high availability of your workloads.
[Instance distribution & AZ rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-benefits.html#AutoScalingBehavior.Rebalancing).
1. **Flexible scaling**: Auto Scaling group has a set of rich APIs to manage the scaling of your workload, allowing workloads to control their scaling needs whichever those are, from [Manual scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-manual-scaling.html), [Scheduled scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/schedule_time.html), [Dynamic Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html) using *Target tracking*, *Step scaling* and [Predictive scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html).
1. **Elastic Load Balancing integration**: The integration with Elastic Load Balancing automatically distributes your incoming application traffic across all the EC2 Instances that you are running. [Elastic Load Balancing and Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-load-balancer.html).
1. **Instance refresh & instance replacement based on maximum instance lifetime**: Auto Scaling group reduces the heavy lifting required when updating for example the underlying AMI. [Instance Refresh](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-refresh.html) allows users to gradually refresh the instances in an Auto Scaling group. [Instance replacement can also be set up upon the maximum instance lifetime](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-max-instance-lifetime.html), helping users to apply best practices of governance.
1. **Scale-in protection**: Allowing to protect instances that are still working from being selected for scale-in operations [Auto Scaling instance termination](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-instance-termination.html).
1. **Lifecycle hooks**: Enable an Auto Scaling group to trigger actions so that users can manage the lifecycle of Auto Scaling group instances. [Amazon EC2 Auto Scaling lifecycle hooks](https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html).
1. **Capacity rebalance**: Amazon EC2 Auto Scaling is aware of EC2 Instance [rebalance recommendation notifications](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/rebalance-recommendations.html). The Amazon EC2 Spot service emits these notifications when Spot Instances are at elevated risk of interruption. When [Capacity Rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html) is enabled for an Auto Scaling Group, Amazon EC2 Auto Scaling attempts to proactively replace Spot Instances in the group that have received a rebalance recommendation, providing the opportunity to rebalance your workload to new Spot Instances that are not at elevated risk of interruption.
1. **Instance weights**: When you configure an Auto Scaling group to launch multiple instance types, you have the option of defining the number of capacity units that each instance contributes to the desired capacity of the group, using instance weighting. This allows you to specify the relative weight of each instance type in a way that directly maps to the performance of your application. You can weight your instances to suit your specific application needs, for example, by the cores (vCPUs) or by memory (GiBs). [EC2 Auto Scaling group weights](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-weighting.html).
1. **Support for multiple Launch Templates**: Auto Scaling group supports multiple Launch Templates. This allows for extra flexibility in how the auto Scaling group is configured, for example supporting multiple architectures (i.e Graviton c6g and Intel c5) within a single Auto Scaling group. [Multiple launch template documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-launch-template-overrides.html).
1. **Warm pools**: Warm pool decrease latency of procuring capacity on your workloads by managing a pool of pre-initialized EC2 Instances. Whenever your application needs to scale out, the Auto Scaling Group can draw on the warm pool to meet its new desired capacity. [Warm pools for Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html).

If you want to learn more about all the benefits of Auto Scaling groups, you can find more information in the [Amazon EC2 Auto Scaling group documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html).
