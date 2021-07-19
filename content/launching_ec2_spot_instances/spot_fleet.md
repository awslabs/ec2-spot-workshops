+++
title = "Launching EC2 Spot Instances via Spot Fleet"
weight = 60
+++

## Launching EC2 Spot Instances via a Spot Fleet request

The Spot Fleet request specifies the total target capacity and the On-Demand target capacity. Amazon EC2 calculates the difference between the total capacity and On-Demand capacity, and launches the difference as Spot capacity. You can submit a single request that includes multiple launch specifications that vary by instance type, AMI, Availability Zone, or subnet.

You should use Spot Fleet for specific workloads that have a start and an end or when you want to have control over which instances to terminate. Additionally, you can benefit from integrations with other services.

**To create a Spot Fleet request using the recommended settings**

You are going to create a *json* file with all the configuration parameters needed to create the Spot Fleet request. One of the parameters is `IamFleetRole`, that must contain the ARN of an IAM role that grants the Spot Fleet the permission to request, launch, terminate, and tag instances on your behalf. For this purpose, you are going to first retrieve the ARN of the Service-Linked role named `AWSServiceRoleForEC2SpotFleet`. For more information read the [spot fleet prerequisites](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet-requests.html#spot-fleet-prerequisites).

{{%notice note%}}
If you have never launched a Spot Fleet, the AWSServiceRoleForEC2SpotFleet won't exist in your account. To create it run the following command: `aws iam create-service-linked-role --aws-service-name spotfleet.amazonaws.com`
{{% /notice %}}

Execute the following command to export the ARN of the Service-Linked role to an environment variable.

```bash
export EC2_SPOT_ROLE=$(aws iam get-role --role-name AWSServiceRoleForEC2SpotFleet | jq -r '.Role.Arn')
```

You are now ready to generate the configuration file:

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
               "Priority": 2.0
            },
            {
               "InstanceType":"m5.large",
               "Priority": 2.0
            },
            {
               "InstanceType":"r5.large",
               "Priority": 1.0
            },
            {
               "InstanceType":"c4.large",
               "Priority": 1.0
            },
            {
               "InstanceType":"m4.large",
               "Priority": 1.0
            },
            {
               "InstanceType":"r4.large",
               "Priority": 2.0
            }
         ]
      }
   ],
   "IamFleetRole": "${EC2_SPOT_ROLE}",
   "TargetCapacity": 10,
   "OnDemandTargetCapacity": 2,
   "TerminateInstancesWithExpiration": true,
   "Type": "maintain",
   "ReplaceUnhealthyInstances": true
}
EoF
```

The value for `AllocationStrategy` tells Spot Fleet to launch instances from Spot Instance pools with optimal capacity for the number of instances that are launching. `CapacityRebalance` is a signal that EC2 emits when a Spot instance is at an elevated risk of being interrupted. To allow Spot Fleet to launch a replacement Spot Instance when an instance rebalance notification is emitted, you specify `launch` as the `ReplacementStrategy`.

By specifying `maintain` as the request type, Spot Fleet places requests to meet the target capacity over time and automatically replenish any interrupted instances.


If you want to learn more about the other configuration parameters, you can review the documentation [here](https://docs.aws.amazon.com/cli/latest/reference/ec2/request-spot-fleet.html).

Copy and paste this command to submit the Spot Fleet request.

```bash
aws ec2 request-spot-fleet --spot-fleet-request-config file://spot-fleet-request-config.json
```

**Example return**

```bash
{
    "SpotFleetRequestId": "sfr-cccaf1ea-6922-47e9-99e0-055c635cb63f"
}
```

You have now created a Spot Fleet that combines Spot Instances and On-Demand instances to meet the specified target capacity.

Given the configuration we used above. **Try to answer the following questions:**

1. How many Spot vs On-Demand instances have been requested by the Spot Fleet?
2. Which Spot Instances and On-Demand instances will be launched first? Is the value of `Priority` effective for all instances?

{{%expand "Show me the answers:" %}}

1.) **How many Spot vs On-Demand instances have been requested by the Spot Fleet?**

This Spot fleet will mantain a target capacity of 10, as specified in the value for `TargetCapacity`. Additionally, we are specifying an On-Demand target capacity of 2. Remember that Amazon EC2 calculates the difference between the total capacity and On-Demand capacity in order to launch Spot instances. This would result in **2** On-Demand instances being launched and **8** Spot Instances being launched.

2.) **Which Spot Instances and On-Demand instances will be launched first? Is the value of `Priority` effective for all instances?**

On one hand, we have specified `capacityOptimized` as allocation strategy to follow the best practices associated with Spot. This will make the Spot Fleet launch instances from Spot Instance pools with optimal capacity. On the other hand, we specified `prioritized` as the allocation strategy for On-Demand Instances. Therefore, the order in which Spot Fleet will fulfill the On-Demand capacity is defined by the value of `Priority` in the list of overrides, launching first the instances with the higher priority. However, the priority override is not taken into account when fulfilling Spot capacity, so there is not a way to know which Spot instances will be launched first.

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
