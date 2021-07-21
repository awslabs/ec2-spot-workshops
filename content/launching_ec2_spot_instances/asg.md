+++
title = "Launching EC2 Spot instances via EC2 Auto Scaling Group"
weight = 50
+++

## Launching EC2 Spot Instances via an EC2 Auto Scaling Group

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 instances available to handle the load for your application. You create collections of EC2 instances, called Auto Scaling Groups. You can specify the minimum number of instances in each Auto Scaling Group, and Amazon EC2 Auto Scaling ensures that your group never goes below this size. You can specify the maximum number of instances in each Auto Scaling Group, and Amazon EC2 Auto Scaling ensures that your group never goes above this size.

In most of the cases you should use Auto Scaling Groups to launch Spot instances, since it offers a very rich API and some benefits like scale-in protection, lifecycle hooks, rebalance recommendation, warm pools and predictive scaling that we will cover later.

{{% notice note %}}
In the past, Auto Scaling Groups used Launch Configurations. Applications using Launch Configurations should migrate to Launch Templates. With Launch Templates you can provision capacity across multiple instance types using both On-Demand instances and Spot instances to achieve the desired scale, performance, and cost optimization.
{{% /notice %}}

 **To create an Auto Scaling Group using a launch template**

We will launch a mixed instance Auto Scaling Group using Spot and On-demand instances.
Create a *json* that describes a mixed-instance-policy section where we will provide a set of overrides that will drive Spot instance pool diversification. The configuration of the Auto Scaling Group will also refer to the Launch Template that we created in the previous steps.

```bash
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

In the example, the override configuration section is used to apply diversification. Choosing as many instances that qualify for your application, in this case we selected a group of 6 instances types that meet the ".large" criteria.

With Auto Scaling Groups you can define what is the mix of Spot vs On-Demand instances that makes sense for your workload. `OnDemandBaseCapacity` allows you to set an initial capacity of On-Demand instances to use, after that, new capacity will be a mix of Spot and On-Demand as defined by the `OnDemandPercentageAboveBaseCapacity`.

The configuration above, sets the `SpotAllocationStrategy` to `capacity-optimized`. The `Capacity-optimized` allocation strategy allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching, making use of real-time capacity data and optimizing the selection of spot instances used. You can read about the benefits of using `capcity-optimized` in the blog post [Capacity-Optimized Spot Instance Allocation in Action at Mobileye and Skyscanner](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/).

Let's create the Auto Scaling Group. In this case the Auto Scaling Group spans across 3 availability zones (the ones used to create the Launch Template), and sets the `min-size` to 2, `max-size` to 10 and `desired-capacity` to 6.

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --min-size 1 --max-size 10 --desired-capacity 6 --capacity-rebalance --mixed-instances-policy file://asg-policy.json
```

You have now created a Mixed Instances Auto Scaling Group!


Given the configuration we used above. **Try to answer the following questions:**

1. How may Spot Instance pools does the Auto Scaling Group consider when applying Spot
diversification?
2. How many Spot vs On-Demand instances have been requested by the Auto Scaling Group?
3. How can you confirm which instances have been created within the Auto Scaling Group?

{{%expand "Show me the answers:" %}}

1.) **How may Spot Instance pools does the Auto Scaling Group consider when applying Spot
diversification?**

Remember: A Spot pool is a set of unused EC2 instances with the same instance type (for example, m5.large) and Availability Zone. In this case we used 6 instance types and 3 Availability Zones, which makes a total of **18 Spot pools**. Increasing the number of Spot pools we diversify on, is key for adopting Spot Best practices.

2.) **How many Spot vs On-Demand instances have been requested by the Auto Scaling Group?**

The `desired-capacity` of 6 is below the `max-size` of 10, so 6 instances are provisioned.
Out of them, the first 2 instances are on demand as requested by the `OnDemandBaseCapacity`.
The rest of the 4 instances up to the desired 6, follow a proportion of 75% Spot and 25% On-Demand according to `OnDemandPercentageAboveBaseCapacity`, which means there should be 3 Spot instances and 3 On-demand instances.

3.) **How can you confirm which instances have been created within the Auto Scaling Group?**

To check the instances within the newly created Auto ScalingGroup we can use `describe-auto-scaling-groups`.

```bash
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names EC2SpotWorkshopASG
```

{{% /expand %}}

{{% notice tip %}}
Auto Scaling Group has rich functionality that helps reduce the heavy lifting of managing capacity. Amazon EC2 Auto Scaling helps ensure that your application always has the right amount of capacity to handle the demand. Auto Scaling Groups can dynamically increase and decrease capacity as needed.
{{% /notice %}}


These are some of the characteristics and functionality that make Amazon EC2 Auto Scaling Groups the right choice for most workloads:

1. **Instance distribution & Availability Zone rebalancing**: Amazon EC2 Auto Scaling Groups attempt to distribute instances evenly to maximise the High availability of your workloads.
[Instance Distribution & AZ Rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-benefits.html#AutoScalingBehavior.Rebalancing).
1. **Flexible Scaling**: Auto Scaling Group has a set of rich API's to manage the scaling of your workload, allowing workloads to control their scaling needs whichever those are, from [Manual Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-manual-scaling.html), [Scheduled Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/schedule_time.html), [Dynamic Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html) using *Target Tracking*, *Step Scaling* and [Predictive Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html).
1. **Elastic Load Balancing Integration**: The integration with Elastic Load Balancing automatically distributes your incoming application traffic across all the EC2 instances that you are running. [Elastic Load Balancing and Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-load-balancer.html).
1. **Instance Refresh & Instance Replacement based on maximum instance lifetime**: Auto Scaling Group reduce the heavy lifting required when updating for example the underlying AMI. [Instance Refresh](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-refresh.html) allows user to gradually refresh the instances in an Auto Scaling Group. [Instance replacement can also be set up upon the maximum instance lifetime](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-max-instance-lifetime.html), helping users to apply best practices of governance.
1. **Scale-in protection**: Allowing to protect instances that are still working from being selected for Scale-in operations [Auto Scaling instance termination](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-instance-termination.html).
1. **Lifecycle hooks**: Enable an Auto Scaling Group trigger actions so that users can manage the lifecycle of Auto Scaling Group instances. [Amazon EC2 Auto Scaling lifecycle hooks](https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html).
1. **Capacity rebalance**: Amazon EC2 Auto Scaling is aware of EC2 instance [rebalance recommendation notifications](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/rebalance-recommendations.html). The Amazon EC2 Spot service emits these notifications when Spot Instances are at elevated risk of interruption. When [Capacity Rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html) is enabled for an Auto Scaling Group, Amazon EC2 Auto Scaling attempts to proactively replace Spot Instances in the group that have received a rebalance recommendation, providing the opportunity to rebalance your workload to new Spot Instances that are not at elevated risk of interruption.
1. **Instance Weights**: When you configure an Auto Scaling Group to launch multiple instance types, you have the option of defining the number of capacity units that each instance contributes to the desired capacity of the group, using instance weighting. This allows you to specify the relative weight of each instance type in a way that directly maps to the performance of your application. You can weight your instances to suit your specific application needs, for example, by the cores (vCPUs) or by memory (GiBs). [EC2 Auto Scaling Group Weights](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-weighting.html).
1. **Support for multiple Launch Templates**: Auto Scaling Group supports multiple Launch Templates. This allows for extra flexibility in how the auto Scaling Group is configured, for example supporting multiple architectures (i.e Graviton c6g and Intel c5) within a single Auto Scaling Group. [Multiple Launch Template Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-launch-template-overrides.html).
1. **Warm pools**: Warm pool decrease latency of procuring capacity on your workloads by managing a pool of pre-initialized EC2 instances. Whenever your application needs to scale out, the Auto Scaling Group can draw on the warm pool to meet its new desired capacity. [Warm pools for Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html).

If you want to learn more about all the benefits of Auto Scaling Groups, you can find more information in the [Amazon EC2 Auto Scaling Group documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html).
