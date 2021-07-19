+++
title = "Launching EC2 Spot Instances via Spot Fleet"
weight = 60
+++

## Launching EC2 Spot Instances via a Spot Fleet request

Spot Fleet is an API that is mainly used on workloads that have a start and and end (batch workloads), specially when the workload requires you to have control over which instances to terminate in your own code. You can benefit from integrations with other services such as Load Blanancers, however if you are thinking about using Load Balancers, Auto Scaling Grups are a better option 

Spot Fleet does allow to diversify across different AZ's and networks. Unlike Auto Scaling Group, Spot fleet by default does not take into consideration any best practice to maintain a balance across AZ's, just providing capacity as fast as possible from the eligible pools. Spot Fleet does support types: `maintain`, `request`.  Similar To Auto Scaling Groups, the `maintain` type will preserve the number of instances when one of the instances becomes un-healthy.

{{%notice info%}}
To support mix instances with different instance types and purchasing options, Spot Fleet must use **Launch Templates**. In this exercise, we will re-use the same Launch Template that we created before.
{{% /notice %}}

In this part of the workshop we will provide an example to a scenario that is quite common to see when using Spot Fleet: The use of Weights and Target Capacity. This maps well with the concept of "Compute Slots" in batch workloads. Some batch workloads can have more than one worker processes within an instance. The larger the instance, the more worker processes they can run. For example one worker may consume 1 vCPU: 2GB Ram, which means that on a C5.xlarge (4vCVUs:8GB) instance we should define a weight of 4. 

By default when we select the Target Capacity for Spot Fleet (note the same weight concept is now available on Auto Scaling Group and EC2 Fleet), the target defines the number of instances that the Spot Fleet will procure. However when we use Spot Fleet Weights, we associate a custom weight with an instance in the override section and we associate with a "Compute Slot", and the Total Target Capacity is total number of "Compute Slots" or vCPUs that we want on our Spot Fleet. 

**To create a Spot Fleet request using Target Capacity & Weights**

You are going to create a *json* that sets a few relevant Spot parameters; One of the parameters is `IamFleetRole`. `IamFleetRole` must be set up to point the ARN of an IAM role that grants the Spot Fleet the permission to request, launch, terminate, and tag instances on your behalf. For this purpose, you are going to first retrieve the ARN of the Service-Linked role named `AWSServiceRoleForEC2SpotFleet`. For more information read the [spot fleet prerequisites](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet-requests.html#spot-fleet-prerequisites).

{{%notice warning%}}
If you have never launched a Spot Fleet, the AWSServiceRoleForEC2SpotFleet won't exist in your account. To create it run the following command in the AWS CloudShell: `aws iam create-service-linked-role --aws-service-name spotfleet.amazonaws.com`
{{% /notice %}}

Execute the following command to export the ARN of the Service-Linked role to an environment variable.

```bash
export EC2_SPOT_ROLE=$(aws iam get-role --role-name AWSServiceRoleForEC2SpotFleet | jq -r '.Role.Arn')
```

You are now ready to generate the configuration file, copy and paste the following in the AWS CloudShell:

```bash
cat <<EoF > ~/spot-fleet-request-config.json
{
   "AllocationStrategy": "capacityOptimized",
   "OnDemandAllocationStrategy": "prioritized",
   "SpotMaintenanceStrategies": {
      "CapacityRebalance": {
         "ReplacementStrategy": "launch"
      }
   },
   "LaunchTemplateConfigs": [
      {
         "LaunchTemplateSpecification": {
            "LaunchTemplateId": "${LAUNCH_TEMPLATE_ID}",
            "Version": "1"
         },
         "Overrides":[
            {
               "InstanceType":"c5.large",
               "WeightedCapacity": 2.0,
               "Priority": 3.0
            },
            {
               "InstanceType":"m5.large",
               "WeightedCapacity": 2.0,
               "Priority": 2.0
            },
            {
               "InstanceType":"r5.large",
               "WeightedCapacity": 2.0,
               "Priority": 1.0
            },
            {
               "InstanceType":"c5.xlarge",
               "WeightedCapacity": 4.0,
               "Priority": 6.0
            },
            {
               "InstanceType":"m5.xlarge",
               "WeightedCapacity": 4.0,
               "Priority": 5.0
            },
            {
               "InstanceType":"r5.xlarge",
               "WeightedCapacity": 4.0,
               "Priority": 4.0
            }
         ]
      }
   ],
   "IamFleetRole": "${EC2_SPOT_ROLE}",
   "TargetCapacity": 12,
   "OnDemandTargetCapacity": 4,
   "TerminateInstancesWithExpiration": true,
   "Type": "maintain",
   "ReplaceUnhealthyInstances": true
}
EoF
```
The Spot Fleet request specifies the total target capacity and the On-Demand target capacity. Amazon EC2 calculates the difference between the total capacity and On-Demand capacity, and launches the difference as Spot capacity. You can submit a single request that includes multiple launch specifications that vary by instance type, AMI, Availability Zone, or subnet.

When `AllocationStrategy` is set to `capacityOptimized` tells Spot Fleet to launch instances from optimal Spot pools Spot for the target capacity of instances (in this case weights) that we are launching. 


Spot Fleet does support `CapacityRebalance` as part of the Metat data service. `CapacityRebalance` is a signal that EC2 emits when a Spot instance is at an elevated risk of being interrupted. Users can intercept this event and decide if they want to launch a replacement by selecting `launch` as the `ReplacementStrategy` within the `SpotMaintenanceStrategies` structure.

By specifying `maintain` as the request type, Spot Fleet places requests to meet the target capacity over time and automatically replenish any interrupted instances.


If you want to learn more about the other configuration parameters, you can review the documentation [here](https://docs.aws.amazon.com/cli/latest/reference/ec2/request-spot-fleet.html).

Once that you've read and familiarized yourself with the configuration, copy and paste this command to submit the Spot Fleet request.

```bash
aws ec2 request-spot-fleet --spot-fleet-request-config file://spot-fleet-request-config.json
```

**Example return**

```bash
{
    "SpotFleetRequestId": "sfr-cccaf1ea-6922-47e9-99e0-055c635cb63f"
}
```

You have now created a Spot Fleet that uses weights and combines Spot and On-Demand instances to meet the specified target capacity.

Given the configuration we used above. **Try to answer the following questions:**

1. How many Spot vs On-Demand instances have been requested by the Spot Fleet?
2. Which Spot Instances and On-Demand instances will be launched first? Is the value of `Priority` effective for all instances?

{{%expand "Show me the answers:" %}}

1.) **How many Spot vs On-Demand instances have been requested by the Spot Fleet?**

This Spot fleet will maintain a weighted target capacity of 12, as specified in the value for `TargetCapacity`. Additionally, we are specifying an On-Demand target capacity of 4. Remember that Amazon EC2 calculates the difference between the total capacity and On-Demand capacity in order to launch Spot instances. This would result in **1** On-Demand instances being launched and in the case of spot instances, given that we are using `capacityOptimized` allocation strategy, a few things may happen, the most common is that out of the 18 pools one is selected as optimal (has more capacity, etc), if the pool selected is one of the 9 pools defined as **large** 4 Spot instances will be added. If the pool selected is one of the 9 **xlarge** 2 Spot instances will be created.

2.) **For On-Demand Capacity, what does it mean the `Priority` section?**

 We did specifie `prioritized` as the allocation strategy for On-Demand Instances. Therefore, the order in which Spot Fleet will attempt to fulfill the On-Demand capacity, is defined by the value of `Priority` in the list of overrides. It will aim first to launch capacity from the pools with the highest priority `c5.xlarge`, if there are [Insufficient Capacity Errors](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/troubleshooting-launch.html#troubleshooting-launch-capacity), it will go into the pools with the next higher priority `m5.xlarge`, and so on.  
 
 
 For Spot, the `priority` attribute will have no effect in the expample. We have specified `capacityOptimized` as allocation strategy to follow the best practices associated with Spot. This will make the Spot Fleet launch instances from Spot Instance pools with optimal capacity. On the other hand,

{{%notice note%}}
Read about how Spot allocation strategy also supports `capacityOptimizedPrioritized`. What would be the results if you repeat the same exercise with this allocation strategy ?

{{% /notice %}}


{{% /expand %}}

{{% notice tip %}}
The Spot Fleet selects the Spot capacity pools that meet your needs and launches Spot Instances to meet the target capacity for the fleet. By default, Spot Fleets are set to maintain target capacity by launching replacement instances after Spot Instances in the fleet are terminated.
{{% /notice %}}

## Monitoring Your Spot Fleet

The Spot Fleet launches Spot Instances when your maximum price exceeds
the Spot price and capacity is available. The Spot Instances run until
they are interrupted or you terminate them.

**To monitor your Spot Fleet using the console**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. Select your Spot Fleet request. The configuration details are available in the **Description** tab.
4. To list the Spot Instances for the Spot Fleet, choose the **Instances** tab.
5.  To view the history for the Spot Fleet, choose the **History** tab.

![Spot Fleet requests](/images/launching_ec2_spot_instances/SpotFleetRequest.png)
