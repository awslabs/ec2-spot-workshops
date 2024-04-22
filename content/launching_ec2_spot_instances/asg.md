+++
title = "Launching EC2 Spot Instances via EC2 Auto Scaling group"
weight = 50
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Launching EC2 Spot Instances](https://catalog.us-east-1.prod.workshops.aws/workshops/36a2c2bb-b92d-4428-8626-3a75df01efcc/en-US)**.

{{% /notice %}}

{{% notice note %}}
When adopting EC2 Spot Instances, we recommend you to consider Amazon EC2 Auto Scaling group (ASG) since it offers the most up to date EC2 features such as attribute-based instance type selection, capacity rebalancing, scaling policies and many more functionalities.
{{% /notice %}}

[Amazon EC2 Auto Scaling groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html) contain a collection of Amazon EC2 Instances that are treated as a logical grouping for the purposes of automatic scaling and management. Auto Scaling groups also enable you to use Amazon EC2 Auto Scaling features such as health check replacements and scaling policies. Both maintaining the number of instances in an Auto Scaling group and automatic scaling are the core functionality of the Amazon EC2 Auto Scaling service.

{{% notice info %}}
In the past, Auto Scaling groups used launch configurations. Applications using launch configurations should migrate to **launch templates** so that you can leverage the latest features. With launch templates you can provision capacity across multiple instance types using both Spot Instances and On-Demand Instances to achieve the desired scale, performance, and cost optimization.
{{% /notice %}}

## Using attribute-based instance type selection and mixed instance groups

Being instance flexible is an important [Spot best practice](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html), you can use [*attribute-based instance type selection (ABIS)*](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html) to automatically select multiple instance types matching your requirements. A common case when using Auto Scaling groups, is to use it with workloads that require a mix of Spot and On-Demand capacity.

In this step you create a *json* file for creating Auto Scaling groups using AWS CLI. The configuration uses the launch template that you created in the previous steps and ABIS to pick any current generation non-GPU instance types with `2 vCPU` and no limit on memory. `OnDemandBaseCapacity` allows you to set an initial capacity of `1` On-Demand Instance. Remaining capacity is mix of `25%` On-Demand Instances and `75%` Spot Instances defined by the `OnDemandPercentageAboveBaseCapacity`.

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
               "Min": 2, 
               "Max": 2
            },
            "MemoryMiB": {
               "Min": 0
            },
            "CpuManufacturers": [
               "intel",
               "amd"
            ],
            "InstanceGenerations": [
               "current"
            ],
            "AcceleratorCount": {
               "Max": 0
            }
         }
      }]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":1,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"price-capacity-optimized"
   }
}
EoF
```
{{% notice info %}}
In this configuration you set the `SpotAllocationStrategy` to `price-capacity-optimized`. The `price-capacity-optimized` allocation strategy allocates instances from the Spot Instance pools that offer low prices and high capacity availability. You can read more about the `price-capacity-optimized` allocation strategy in [Introducing the price-capacity-optimized allocation strategy for EC2 Spot Instances](https://aws.amazon.com/blogs/compute/introducing-price-capacity-optimized-allocation-strategy-for-ec2-spot-instances/) blog post.
{{% /notice %}}

1. Run the following commands to retrieve your default VPC and then its subnets.
```
export VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true | jq -r '.Vpcs[0].VpcId')
export SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="${VPC_ID}")
export SUBNET_1=$((echo $SUBNETS) | jq -r '.Subnets[0].SubnetId')
export SUBNET_2=$((echo $SUBNETS) | jq -r '.Subnets[1].SubnetId')
```

2. Run the following commands to create an Auto Scaling group across `2` Availability Zones, min-size `2`, max-size `20`, and desired-capacity `10` vCPU units.
```
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --min-size 2 --max-size 20 --desired-capacity 10 --desired-capacity-type vcpu --vpc-zone-identifier "${SUBNET_1},${SUBNET_2}" --capacity-rebalance --mixed-instances-policy file://asg-policy.json
```

You have now created a mixed instances Auto Scaling group!

### Challenges
Given the configuration you used above, try to answer the following questions. Click to expand and see the answers. 

{{%expand "1. How may Spot Instance pools does the Auto Scaling group consider when applying Spot diversification?" %}}

A Spot capacity pool is a set of unused EC2 Instances with the same instance type (for example, m5.large) and Availability Zone. At the time of creation of the workshop, our example matched 35 instance types and 3 Availability Zones, which makes a total of **(35*2)=70 Spot pools**. Increasing the number of Spot pools is a key for adopting Spot best practices.

{{% /expand %}}

{{%expand "2. How many Spot vs On-Demand Instances have been requested by the Auto Scaling group?" %}}

The desired capacity is `10` vCPUs, so 5 instances having a sum of 10 vCPUs are provisioned. Out of them, the first 1 EC2 instance is On-Demand as requested by the **OnDemandBaseCapacity**. The rest of the instances, follow a proportion of `25%` On-Demand (1 instances) and `75%` Spot (3 Instances) according to **OnDemandPercentageAboveBaseCapacity**. 

{{% /expand %}}

{{%expand "3. How can you confirm which instances have been created within the Auto Scaling group?" %}}
To check the instances within the newly created Auto Scaling group you can use `describe-auto-scaling-groups`.
```bash
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names EC2SpotWorkshopASG
```

To check the newly created instances Auto Scaling group in the AWS Console, head to [EC2 Dashboard home](https://console.aws.amazon.com/ec2/home?#Home:), click on "Instances (running), and filter the list of instances using `aws:autoscaling:groupName = EC2SpotWorkshopASG`.

{{% /expand %}}

{{%expand "4. How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?" %}}

To describe one or more instances you use `describe-instances`. To retrieve all the Spot Instances that have been launched with the Auto Scaling group, you apply two filters: `instance-lifecycle` set to `spot` to retrieve only Spot Instances and the custom tag `aws:autoscaling:groupName` that must be set to `EC2SpotWorkshopASG`. To learn more about Tagging lifecycle, review [this documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-tagging.html#tag-lifecycle).

```bash
aws ec2 describe-instances --filters Name=instance-lifecycle,Values=spot Name=tag:aws:autoscaling:groupName,Values=EC2SpotWorkshopASG Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].[InstanceId]" --output text
```

Similarly, you can run the following command to retrieve the identifiers of the instances that have been launched using the On-Demand purchasing model.

```bash
aws ec2 describe-instances --filters Name=tag:aws:autoscaling:groupName,Values=EC2SpotWorkshopASG Name=instance-state-name,Values=running --query "Reservations[*].Instances[? InstanceLifecycle==null].[InstanceId]" --output text
```
{{% /expand %}}

{{%expand "5. How can you select specific instance types manually instead of ABIS in your Auto Scaling group?" %}}

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
      "OnDemandBaseCapacity":1,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"price-capacity-optimized"
   }
}
EoF
```
{{% /expand %}}


{{%expand "6. How can you select a mix of instance types of different sizes in your Auto Scaling group?" %}}
 To create an Auto Scaling group with specific/individual instance types, you can use a *json* file that is given below. The example instances that have 2 vCPUs and 4 vCPUs example m5.large, c5.large, r5.large, m5.xlarge, c5.xlarge, and r5.xlarge.

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
               "Min": 2, 
               "Max": 4
            },
            "MemoryMiB": {
               "Min": 0
            },
            "CpuManufacturers": [
               "intel",
               "amd"
            ],
            "InstanceGenerations": [
               "current"
            ],
            "AcceleratorCount": {
               "Max": 0
            }
         }
      }]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":1,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"capacity-optimized"
   }
}
EoF
```

{{% /expand %}}

{{%expand "7. How can you select capacity-optimized Spot allocation strategy in your Auto Scaling group?" %}}

The `capacity-optimized` allocation strategy allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching, making use of real-time capacity data and optimizing the selection of used Spot Instances. Use `capacity-optimized` Spot allocation strategy works well for workloads where the cost of a Spot interruption is very significant. You can read about the benefits of using `capcity-optimized` in the blog post [Capacity-Optimized Spot Instance allocation in action at Mobileye and Skyscanner](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/). 

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
               "Min": 2, 
               "Max": 2
            },
            "MemoryMiB": {
               "Min": 0
            },
            "CpuManufacturers": [
               "intel",
               "amd"
            ],
            "InstanceGenerations": [
               "current"
            ],
            "AcceleratorCount": {
               "Max": 0
            }
         }
      }]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":1,
      "OnDemandPercentageAboveBaseCapacity":25,
      "SpotAllocationStrategy":"capacity-optimized"
   }
}
EoF
```
{{% /expand %}}




#### Optional reads
These are some of the characteristics and functionality that make Amazon EC2 Auto Scaling groups the right choice for most workloads:

1. **Attribute-based instance type selection**: Amazon EC2 Auto Scaling groups selects a number of instance families and sizes based a set of instance attributes that describe your compute requirements. [Attribute-based instance type selection](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html).
1. **Instance distribution & Availability Zone rebalancing**: Amazon EC2 Auto Scaling groups attempt to distribute instances evenly to maximize the high availability of your workloads.
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