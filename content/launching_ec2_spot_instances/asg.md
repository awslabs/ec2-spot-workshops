+++
title = "Launching EC2 Spot instances via EC2 Auto Scaling Group"
weight = 50
+++

## Launching EC2 Spot Instances via an EC2 Auto Scaling Group

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 instances available to handle the load for your application. You create collections of EC2 instances, called Auto Scaling groups. You can specify the minimum number of instances in each Auto Scaling group, and Amazon EC2 Auto Scaling ensures that your group never goes below this size. You can specify the maximum number of instances in each Auto Scaling group, and Amazon EC2 Auto Scaling ensures that your group never goes above this size.

In most of the cases you should use Auto Scaling groups to launch Spot instances, since it offers a very rich API and some benefits like warm pools, predictive scaling, scale-in protection, lifecycle hooks and rebalance recommendation that we will cover later.

{{% notice note %}}
Unlike using launch configurations, with launch templates you can also provision capacity across multiple instance types using both On-Demand Instances and Spot Instances to achieve the desired scale, performance, and cost.
{{% /notice %}}

 **To create an Auto Scaling group using a launch template**

In order to select a launch template and define the distribution of On-Demand Instances and Spot Instances, you are going to create a *json* file that will contain the `mixed-instances-policy` information that will be used to create the Auto Scaling Group.

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
            "InstanceType":"c5.large",
            "WeightedCapacity":"2"
         },
         {
            "InstanceType":"c5.xlarge",
            "WeightedCapacity":"4"
         },
         {
            "InstanceType":"c4.large",
            "WeightedCapacity":"2"
         }
      ]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity":2,
      "OnDemandPercentageAboveBaseCapacity":20,
      "SpotAllocationStrategy":"capacity-optimized",
      "SpotMaxPrice":""
   }
}
EoF
```

The properties specified in the `overrides` list will override those same properties in the Launch Template. In the example, you are overriding the instance type that was used to create the Launch Template. Instead, three different instance types are specified to implement a better instance diversification. The attribute `WeightedCapacity` refers to the number of capacity units provided by the instance type.

`SpotAllocationStrategy` indicates how to allocate instances across Spot Instance pools. By choosing `capacity-optimized`, the Auto Scaling group launches instances using Spot pools that are optimally chosen based on the available Spot capacity.

Additionally, one of the parameters that needs to be specified when creating the Auto Scaling Group is the list of Availability Zones where the instances are going to be deployed. By specifying several Availability Zones, the amount of capacity pools used to deploy Spot instances is increased, thus reducing the chances of running out of instances.
Run the following command to retrieve the list of Availability Zones in your region and store some of them in an environment variable.

```bash
export AZs=$(aws ec2 describe-availability-zones --filters Name=group-name,Values="${AWS_REGION}" Name=zone-type,Values=availability-zone | jq -r '.AvailabilityZones[0].ZoneName + " " + .AvailabilityZones[1].ZoneName + " " + .AvailabilityZones[2].ZoneName')
```

Finally, execute the following command to create the Auto Scaling Group.

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name AsgForWebServer --min-size 2 --max-size 10 --desired-capacity 2 --availability-zones "${AZs}" --capacity-rebalance true --mixed-instances-policy file://asg-policy.json
```

You have now created an Auto Scaling group configured to launch not only EC2 Spot Instances but EC2 On-Demand Instances with multiple instance types.

When working with Auto Scaling groups, you can benefit from the following:

1. **Warm pools**: A warm pool gives you the ability to decrease latency of your applications by working with a pool of pre-initialized EC2 instances. Whenever your application needs to scale out, the Auto Scaling group can draw on the warm pool to meet its new desired capacity. [Warm pools for Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html).
2. **Predictive scaling**: Use predictive scaling to increase the number of EC2 instances in your Auto Scaling group in advance of daily and weekly patterns in traffic flows. [Predictive scaling for Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html).
3. **Scale-in protection**: It allows to control whether an Auto Scaling group can terminate a particular instance when scaling in. [Auto Scaling instance termination](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-instance-termination.html).
4. **Lifecycle hooks**: They enable an Auto Scaling group to be aware of events in the Auto Scaling instance lifecycle, and then perform a custom action when the corresponding lifecycle event occurs. [Amazon EC2 Auto Scaling lifecycle hooks](https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html).
5. **Capacity rebalance**: When you turn on Capacity Rebalancing, Amazon EC2 Auto Scaling attempts to launch a Spot Instance whenever Amazon EC2 notifies that a Spot Instance is at an elevated risk of interruption. After launching a new instance. [Capacity rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html).

If you want to learn more about all the benefits of Auto Scaling groups, you can do it here: [Scaling the size of your Auto Scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/scaling_plan.html).
