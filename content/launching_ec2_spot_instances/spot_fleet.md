+++
title = "Launching EC2 Spot Instances via Spot Fleet"
weight = 60
+++

## Launching EC2 Spot Instances via a Spot Fleet request

The Spot Fleet request specifies the total target capacity and the On-Demand target capacity. Amazon EC2 calculates the difference between the total capacity and On-Demand capacity, and launches the difference as Spot capacity. You can submit a single request that includes multiple launch specifications that vary by instance type, AMI, Availability Zone, or subnet.

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
   "OnDemandAllocationStrategy": "lowestPrice",
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
         "Overrides": [
            {
               "InstanceType": "c5.large",
               "WeightedCapacity": 2
            },
            {
               "InstanceType": "c5.xlarge",
               "WeightedCapacity": 4
            },
            {
               "InstanceType": "c4.large",
               "WeightedCapacity": 2
            }
         ]
      }
   ],
   "IamFleetRole": "${EC2_SPOT_ROLE}",
   "TargetCapacity": 8,
   "OnDemandTargetCapacity": 2,
   "OnDemandMaxTotalPrice": "1",
   "SpotMaxTotalPrice": "1",
   "TerminateInstancesWithExpiration": true,
   "Type": "maintain",
   "ReplaceUnhealthyInstances": true
}
EoF
```

The value for `AllocationStrategy` tells Spot Fleet to launch instances from Spot Instance pools with optimal capacity for the number of instances that are launching. `CapacityRebalance` is a signal that EC2 emits when a Spot instance is at an elevated risk of being interrupted. To allow Spot Fleet to launch a replacement Spot Instance when an instance rebalance notification is emitted, you specify `launch` as the `ReplacementStrategy`.

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
