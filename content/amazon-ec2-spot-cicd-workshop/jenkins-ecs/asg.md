+++
title = "Launch an Auto Scaling group"
weight = 110
+++
An Auto Scaling group contains a collection of Amazon EC2 Instances that are treated as a logical grouping for the purposes of automatic scaling and management. An Auto Scaling group also enables you to use Amazon EC2 Auto Scaling features such as health check replacements and scaling policies. Both maintaining the number of instances in an Auto Scaling group and automatic scaling are the core functionality of the Amazon EC2 Auto Scaling service.

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 Instances available to handle the load for your application. You can specify the minimum and maximum number of instances, and Amazon EC2 Auto Scaling ensures that your group never goes below or above this size.

When adopting EC2 Spot Instances, our recommendation is use Auto Scaling groups since it offers a very rich API with benefits like scale-in protection, health checks, lifecycle hooks, rebalance recommendation integration, warm pools and predictive scaling, and many more functionalities that we list below.

## Launching an Auto Scaling group
For this workshop, you need to create an Auto Scaling group that will be used by the Jenkins plugin to perform your application builds. One of the key Spot best practice is to select multiple instance types. At AWS, instance types comprise varying combinations of CPU, memory, storage, and networking capacity to give you the flexibility to choose the appropriate mix of resources for your applications. However, to make this selection simpler, AWS released **[Attribute-Based Instance Type Selection (ABS)](https://aws.amazon.com/blogs/aws/new-attribute-based-instance-type-selection-for-ec2-auto-scaling-and-ec2-fleet/)** to express workload requirements as a set of instance attributes such as: vCPU, memory, type of processor, etc. ABS translates these requirements and selects all matching instance types that meet the criteria. To select which instance to launch, the Auto Scaling group chose instances based on the allocation strategy configured. For Spot Instances we recommend to use **capacity-optimized**, which select the optimal instances that reduce the frequency of interruptions. ABS does also future-proof the Auto Scaling group configuration: *any new instance type we launch that matches the selected attributes, will be included in the list automatically*. No need to update the Auto Scaling group configuration.

To launch the Auto Scaling group, first create a *json* configuration file. This file describes a mixed-instance-policy section with a set of overrides that drive **diversification of Spot Instance pools** using ABS. The configuration of the Auto Scaling group does refer to the Launch Template that was created in the previous steps with Cloudformation, so make sure you have the corresponding value in the `LAUNCH_TEMPLATE_ID` environment variable

Here's the command you need to run to create the configuration file:

```bash
cat <<EoF > ~/asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"\$Latest"
      },
      "Overrides":[
         {
            "InstanceRequirements": {
            "VCpuCount":{"Min": 2, "Max": 8},
            "MemoryMiB":{"Min": 4096} }
         }
      ]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity": 0,
      "OnDemandPercentageAboveBaseCapacity": 0,
      "SpotAllocationStrategy":"capacity-optimized"
   }
}
EoF
```

Notice that in the override section is where you specify the instance attributes with a range of 2 to 8 vCPUs, and a minimum of 4 GBs of memory. ABS will pick a list of instance types that match the criteria like `m5.large`, `c4.large`, or `c5.large`. Then, based on the **capacity-optimized** allocation strategy, the Auto Scaling group will launch instances from pool with more spare capacity available.

With Auto Scaling groups you can define what is the balance between Spot vs On-Demand Instances that makes sense for your workload. `OnDemandBaseCapacity` allows you to set an initial capacity of On-Demand Instances to use. After that, any new procured capacity will be a mix of Spot and On-Demand Instances as defined by the `OnDemandPercentageAboveBaseCapacity`. This time, *we've configured the Auto Scaling group to launch only Spot instances*.

Finally, the configuration above, sets the `SpotAllocationStrategy` to `capacity-optimized`. The `capacity-optimized` allocation strategy **allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching**, making use of real-time capacity data and optimizing the selection of used Spot Instances. You can read about the benefits of using `capcity-optimized` in the blog post [Capacity-Optimized Spot Instance allocation in action at Mobileye and Skyscanner](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/).

Let’s now create the Auto Scaling group. In this case the Auto Scaling group spans across 3 Availability Zones, and sets the min-size to 0 (*to avoid running instances when there's no need*), max-size to 2 and desired-capacity to 0. You'll override some of this configuration later through Jenkins.

{{% notice note %}}
We’re initialising the Auto Scaling group with zero instances to reduce costs. However, the impact is that you need to wait around five minutes to launch a new job while the new instance starts. If you want to launch pending jobs faster, you need set up number of minimum number of instances to the ones you'll need as a baseline for capacity of Jenkins agents.
{{% /notice %}}

Run the following command:

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsASG --min-size 0 --max-size 2 --desired-capacity 0 --vpc-zone-identifier "${PRIVATE_SUBNETS}" --mixed-instances-policy file://asg-policy.json
```

Nothing else to do here, it's time to configure Jenkins to use this Auto Scaling group.