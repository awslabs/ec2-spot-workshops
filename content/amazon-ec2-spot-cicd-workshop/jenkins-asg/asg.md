+++
title = "Provision an EC2 Auto Scaling Group"
weight = 110
+++
An Auto Scaling group contains a collection of Amazon EC2 Instances that are treated as a logical grouping for the purposes of automatic scaling and management. An Auto Scaling group also enables you to use Amazon EC2 Auto Scaling features such as health check replacements and scaling policies. Both maintaining the number of instances in an Auto Scaling group and automatic scaling are the core functionality of the Amazon EC2 Auto Scaling service.

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 Instances available to handle the load for your application. You can specify the minimum and maximum number of instances, and Amazon EC2 Auto Scaling ensures that your group never goes below or above this size.

When adopting EC2 Spot Instances, our recommendation is use Auto Scaling groups since it offers a very rich API with benefits like scale-in protection, health checks, lifecycle hooks, rebalance recommendation integration, warm pools and predictive scaling, and many more functionalities that we list below.

## Launching an Auto Scaling group
For this workshop, you need to create an Auto Scaling group that will be used by the Jenkins plugin to perform your application builds. To apply Spot best practices we will launch a mixed instance Auto Scaling group using Spot. This first step does create a *json* file. The file describes a mixed-instance-policy section with a set of overrides that drive **diversification of Spot Instance pools**. The configuration of the Auto Scaling group does refer to the Launch Template that was created in the previous steps with Cloudformation.

Run the following command:

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
            "InstanceType":"t2.large"
         },
         {
            "InstanceType":"t3.large"
         },
         {
            "InstanceType":"m4.large"
         },
         {
            "InstanceType":"m5.large"
         },
         {
            "InstanceType":"c5.large"
         },
         {
            "InstanceType":"c4.large"
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

In the override section, choose as many instances that qualify for your application as possible, in this case we selected a group of 6 instance types that meet the “.large” criteria.

With Auto Scaling groups you can define what is the balance between Spot vs On-Demand Instances that makes sense for your workload. OnDemandBaseCapacity allows you to set an initial capacity of On-Demand Instances to use. After that, any new procured capacity will be a mix of Spot and On-Demand Instances as defined by the OnDemandPercentageAboveBaseCapacity. This time, we configured the Auto Scaling group to launch only Spot instances.

Additionally, the configuration above, sets the `SpotAllocationStrategy` to `capacity-optimized`. The `capacity-optimized` allocation strategy **allocates instances from the Spot Instance pools with the optimal capacity for the number of instances that are launching**, making use of real-time capacity data and optimizing the selection of used Spot Instances. You can read about the benefits of using `capcity-optimized` in the blog post [Capacity-Optimized Spot Instance allocation in action at Mobileye and Skyscanner](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/).

Let’s create the Auto Scaling group. In this case the Auto Scaling group spans across 3 Availability Zones, and sets the min-size to 0 (to avoid having instances when there's no need), max-size to 2 and desired-capacity to 0. You'll override some of this configuration later through Jenkins.

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsASG --min-size 0 --max-size 2 --desired-capacity 0 --vpc-zone-identifier "${PRIVATE_SUBNETS}" --mixed-instances-policy file://asg-policy.json
```

You may now proceed with the next step.