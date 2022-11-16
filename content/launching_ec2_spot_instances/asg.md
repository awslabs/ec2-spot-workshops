+++
title = "Launching EC2 Spot Instances via EC2 Auto Scaling group"
weight = 50
+++

An Auto Scaling group contains a collection of Amazon EC2 Instances that are treated as a logical grouping for the purposes of automatic scaling and management. An Auto Scaling group also enables you to use Amazon EC2 Auto Scaling features such as health check replacements and scaling policies. Both maintaining the number of instances in an Auto Scaling group and automatic scaling are the core functionality of the Amazon EC2 Auto Scaling service.

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 Instances available to handle the load for your application. You can specify the minimum and maximum number of instances, and Amazon EC2 Auto Scaling ensures that your group never goes below or above this size.

**When adopting EC2 Spot Instances, our recommendation is to consider first Auto Scaling group since it offers a very rich API with benefits like attribute-based instance type selection, health checks, lifecycle hooks, rebalance recommendation integration, manual and targetted scaling, scheduled scaling, predictive scaling, scale-in protection, warm pools and many more functionalities that we list below.**

{{% notice note %}}
In the past, Auto Scaling groups used Launch Configurations. Applications using Launch Configurations should migrate to Launch Templates so that you can leverage the latest features. With Launch Templates you can provision capacity across multiple instance types using both Spot Instances and On-Demand Instances to achieve the desired scale, performance, and cost optimization.
{{% /notice %}}

## Auto Scaling group example: Using attribute-based instance type selection and mixed instance groups

A common case when using Auto Scaling groups, is to use it with workloads that require a mix
of Spot and On-Demand capacity.

To apply Spot best practices we will launch a mixed instance Auto Scaling group using Spot and On-demand Instances.

This first step does create a *json* file. The file describes a mixed-instance-policy section with a set of overrides that drive diversification of Spot Instance pools. The configuration of the Auto Scaling group does refer to the Launch Template that we created in the previous steps.

```
cat <<EoF > ./asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"1"
      },
      "Overrides":[{
         "InstanceRequirements": {
            "VCpuCount": {
               "Min": 4, 
               "Max": 8
            },
            "MemoryMiB": {
               "Min": 16384
            },
            "CpuManufacturers": [
               "intel",
               "amd"
            ]
         }
      }]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":2,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"price-capacity-optimized"
   }
}
EoF
```

#### Using attribute-based instance type selection

In this configuration, we are using [*attribute-based instance type selection (ABS)*](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html) to select instance families for the Auto Scaling group. *Attribute-based instance type selection (ABS)* offers an alternative to manually choosing instance types when creating an Amazon EC2 Auto Scaling (ASG) or EC2 Fleet, by specifying a set of instance attributes `InstanceRequirements` that describe your compute requirements. As ASG or EC2 Fleet launches instances, any instance types used by them will match your required instance attributes. *ABS* can be utilized on ASG or EC2 Fleet via the AWS Management Console, AWS CLI, or SDKs. *ABS* only supports `lowest-price` allocation strategy for On-Demand, and `price-capacity-optimized`, `capacity-optimized` or `lowest-price`  allocation strategy for Spot instances. 

*ABS* is suitable for picking a set of Amazon EC2 instances that can run a flexible workloads and/or frameworks. *By using ABS to select the list of Amazon EC2 instances for your workload, your application will follow the Spot best practice of diversifying instances across as many Spot pools, thus enabling your ASG or EC2 Fleet to optimally provision Spot capacity.*

*Attribute-based instance type selection* also provides for two price protection thresholds -  `OnDemandMaxPricePercentageOverLowestPrice` for On-Demand instances, and `SpotMaxPricePercentageOverLowestPrice` for Spot instances, so that you can prevent Amazon EC2 Auto Scaling or EC2 Fleet from launching more expensive instance types. Price protection is enabled by default when using ASG or EC2 Fleet, with a default threshold of 20 percent for On-Demand instances and 100 percent for Spot instances. The thresholds represent what you are willing to pay, defined in terms of a percentage above a baseline, rather than as absolute values. The baseline is determined by the price of the least expensive current generation M, C, or R instance type with your specified attributes. If your attributes don't match any M, C, or R instance types, we use the lowest priced instance type. When ASG or EC2 Fleet selects instance types with your attributes, it excludes instance types priced above your threshold. 

In this configuration, we are using *ABS* to select all instances that have a minimum of 4 vcpu's and a maximum of 8 vcpu's using `VCpuCount` attribute, have a minimum of 16 Gib memory using `MemoryMiB` attribute, and have intel/amd chip manufacturers `CpuManufacturers`. We will only use the default price protection thresholds for both On-Demand and Spot instances. A sample of the instances selected by this configuration include c5.2xlarge, c6i.2xlarge, c6a.2xlarge, m5.2xlarge, m5a.2xlarge, r5.2xlarge, r5a.2xlarge, r6i.2xlarge, and r6a.2xlarge. 

#### Using mixed instance groups with Spot and On-Demand capacity

With Auto Scaling groups you can define what is the balance between Spot vs On-Demand Instances that makes sense for your workload. `OnDemandBaseCapacity` allows you to set an initial capacity of On-Demand Instances to use. After that, any new procured capacity will be a mix of Spot and On-Demand Instances as defined by the `OnDemandPercentageAboveBaseCapacity`.

The configuration above, sets the `SpotAllocationStrategy` to `price-capacity-optimized`. The `price-capacity-optimized` allocation strategy <b>not only</b> allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching, <b>but also</b> provision Spot instances with the lowest price. The benefit of using this allocation strategy is Spot allocation looks at both price and capacity to select the Spot Instance pools that are the least likely to be interrupted and have the lowest possible price, thus maintaining an interruption rate comparable to the `capacity-optimized` allocation strategy, while keeping the total price of your Spot Instances lower. You can read more about the `price-capacity-optimized` allocation strategy in the launch post [Amazon EC2 announces new price and capacity optimized allocation strategy for provisioning Amazon EC2 Spot Instances](https://aws.amazon.com/about-aws/whats-new/2022/11/amazon-ec2-price-capacity-optimized-allocation-strategy-provisioning-ec2-spot-instances/)

<!-- The configuration above, sets the `SpotAllocationStrategy` to `capacity-optimized`. The `capacity-optimized` allocation strategy allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching, making use of real-time capacity data and optimizing the selection of used Spot Instances. You can read about the benefits of using `capcity-optimized` in the blog post [Capacity-Optimized Spot Instance allocation in action at Mobileye and Skyscanner](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/). 
-->

Let's create the Auto Scaling group. In this case the Auto Scaling group spans across 3 Availability Zones, and sets the `min-size` to 4, `max-size` to 20 and `desired-capacity` to 8 in vcpu units.

```
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --min-size 4 --max-size 20 --desired-capacity 8 --desired-capacity-type vcpu --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --capacity-rebalance --mixed-instances-policy file://asg-policy.json
```

You have now created a mixed instances Auto Scaling group!

Given the configuration we used above, **Try to answer the following questions:**

1. How many Spot Instance pools does the Auto Scaling group consider when applying Spot
diversification?
2. How many Spot vs On-Demand Instances have been requested by the Auto Scaling group?
3. How can you confirm which instances have been created within the Auto Scaling group?
4. How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?
5. How can I select specific instance types instead of ABS in my Auto Scaling group?
6. How can I select a mix of instance types of different sizes in my Auto Scaling group?

To create an Auto Scaling group with specific/individual instance types, you can use a *json* file that is given below. The example uses m5.large, c5.large, r5.large, m4.large, c4.large, and r4.large.

{{%expand "Show me the answers:" %}}

1.) **How may Spot Instance pools does the Auto Scaling group consider when applying Spot
diversification?**

Remember: A Spot capacity pool is a set of unused EC2 Instances with the same instance type (for example, m5.large) and Availability Zone. At the time of creation of the workshop, our example matched 96 instance types and 3 Availability Zones, which makes a total of **(96*3)=288 Spot pools**. Increasing the number of Spot pools we diversify on, is key for adopting Spot best practices.

2.) **How many Spot vs On-Demand Instances have been requested by the Auto Scaling group?**

The `desired-capacity` of 8 vcpus is below the `max-size` of 20, so instances having a sum of 6 vcpus are provisioned. Out of them, the first 2 EC2 instances are On-Demand as requested by the `OnDemandBaseCapacity`. The rest of the instances, follow a proportion of 75% Spot and 25% On-Demand according to `OnDemandPercentageAboveBaseCapacity`. 

3.) **How can you confirm which instances have been created within the Auto Scaling group?**

To check the instances within the newly created Auto Scaling group we can use `describe-auto-scaling-groups`.

```bash
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names EC2SpotWorkshopASG
```

To check the newly created instances Auto Scaling group in the AWS Console, head to [EC2 Dashboard home](https://console.aws.amazon.com/ec2/home?#Home:), click on "Instances (running), and filter the list of instances using `aws:autoscaling:groupName = EC2SpotWorkshopASG`.

4.) **How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?**

To describe one or more instances we use `describe-instances`. To retrieve all the Spot Instances that have been launched with the Auto Scaling group, we apply two filters: `instance-lifecycle` set to `spot` to retrieve only Spot Instances and the custom tag `aws:autoscaling:groupName` that must be set to `EC2SpotWorkshopASG`.

{{% notice note %}}
When launching instances using an Auto Scaling group, the Auto Scaling group automatically adds a tag to the instances with a key of aws:autoscaling:groupName and a value of the name of the Auto Scaling group. We are going to use that tag to retrieve the instances that were launched by the ASG we just created. To learn more about Tagging lifecycle, review [this documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-tagging.html#tag-lifecycle).
{{% /notice %}}

```bash
aws ec2 describe-instances --filters Name=instance-lifecycle,Values=spot Name=tag:aws:autoscaling:groupName,Values=EC2SpotWorkshopASG Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].[InstanceId]" --output text
```

The output will have the identifiers of the Spot Instances, as we have deduced in the second question.

Similarly, you can run the following command to retrieve the identifiers of the instances that have been launched using the On-Demand purchasing model.

```bash
aws ec2 describe-instances --filters Name=tag:aws:autoscaling:groupName,Values=EC2SpotWorkshopASG Name=instance-state-name,Values=running --query "Reservations[*].Instances[? InstanceLifecycle==null].[InstanceId]" --output text
```

5.) **How can I select specific instance types instead of ABS in my Auto Scaling group?**

To create an Auto Scaling group with specific/individual instance types, you can use a *json* file that is given below. The example uses m5.large, c5.large, r5.large, m4.large, c4.large, and r4.large. 

```
cat <<EoF > ./asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"1"
      },
      "Overrides":[
         {
            "InstanceType":"m5.large"
         },
         {
            "InstanceType":"c5.large"
         },
         {
            "InstanceType":"r5.large"
         },
         {
            "InstanceType":"m4.large"
         },
         {
            "InstanceType":"c4.large"
         },
         {
            "InstanceType":"r4.large"
         }
      ]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":2,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"price-capacity-optimized"
   }
}
EoF
```

Delete the Auto Scaling group if it has been created. 

```bash
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --force-delete
```

To create the Auto Scaling group, use this command to create a `min-size` to 4, `max-size` to 20 and `desired-capacity` to 8 instances. Not the use of instances as the unit for Auto Scaling group capacity.

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --min-size 4 --max-size 20 --desired-capacity 8 --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --capacity-rebalance --mixed-instances-policy file://asg-policy.json
```

6.) **How can I select a mix of instance types of different sizes in my Auto Scaling group?**

To create an Auto Scaling group with specific/individual instance types, you can use a *json* file that is given below. The example uses m5.large, c5.large, r5.large, m5.xlarge, c5.xlarge, and r5.xlarge. Note the use of the instance weights to indicate the unit weight contribution for each instance. In our example, we have used the number of vcpu's as a indicator of the unit. 

```
cat <<EoF > ./asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"1"
      },
      "Overrides":[
         {
            "InstanceType":"m5.large",
            "WeightedCapacity": "2"
         },
         {
            "InstanceType":"c5.large",
            "WeightedCapacity": "2"
         },
         {
            "InstanceType":"r5.large",
            "WeightedCapacity": "2"
         },
         {
            "InstanceType":"m5.xlarge",
            "WeightedCapacity": "4"
         },
         {
            "InstanceType":"c5.xlarge",
            "WeightedCapacity": "4"
         },
         {
            "InstanceType":"r5.xlarge",
            "WeightedCapacity": "4"
         }
      ]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":2,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"price-capacity-optimized"
   }
}
EoF
```

Delete the Auto Scaling group if it has been created. 

```bash
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --force-delete
```

To create the Auto Scaling group, use this command to create a `min-size` to 4, `max-size` to 20 and `desired-capacity` to 8 all defined by the weights associated with the instances.

```
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --min-size 4 --max-size 20 --desired-capacity 8 --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --capacity-rebalance --mixed-instances-policy file://asg-policy.json
```

{{% /expand %}}

{{% notice tip %}}
Auto Scaling group has rich functionality that helps reduce the heavy lifting of managing capacity. Auto Scaling groups can dynamically increase and decrease capacity as needed.
{{% /notice %}}

#### Other Spot allocation strategies

The `capacity-optimized` allocation strategy allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching, making use of real-time capacity data and optimizing the selection of used Spot Instances. Use `capacity-optimized` Spot allocation strategy works well for workloads where the cost of a Spot interruption is very high or `price-capacity-optimized` strategy is experiencing higher Spot interruptions. You can read about the benefits of using `capcity-optimized` in the blog post [Capacity-Optimized Spot Instance allocation in action at Mobileye and Skyscanner](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/). 

{{%expand "How to use the strategy" %}}

```
cat <<EoF > ./asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"1"
      },
      "Overrides":[{
         "InstanceRequirements": {
            "VCpuCount": {
               "Min": 4, 
               "Max": 8
            },
            "MemoryMiB": {
               "Min": 16384
            },
            "CpuManufacturers": [
               "intel",
               "amd"
            ]
         }
      }]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":2,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"capacity-optimized"
   }
}
EoF
```
Delete the Auto Scaling group if it has been created. 

```bash
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --force-delete
```

To create the Auto Scaling group, use this command.

```
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --min-size 4 --max-size 20 --desired-capacity 8 --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --capacity-rebalance --mixed-instances-policy file://asg-policy.json
```

{{% /expand %}}


#### Brief Summary of Auto Scaling group functionality
These are some of the characteristics and functionality that make Amazon EC2 Auto Scaling groups the right choice for most workloads:

1. **Attribute-based instance type selection**: Amazon EC2 Auto Scaling groups selects a number of instance families and sizes based a set of instance attributes that describe your compute requirements. [Attribute-based instance type selection](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html).
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
