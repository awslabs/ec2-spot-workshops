+++
title = "(Optional) - Launching an EC2 Spot Instance via the RunInstances API"
weight = 200
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Launching EC2 Spot Instances](https://catalog.us-east-1.prod.workshops.aws/workshops/36a2c2bb-b92d-4428-8626-3a75df01efcc/en-US)**.

{{% /notice %}}


{{%notice warning%}}
We strongly discourage using the RunInstances API for launching Spot Instances because doesn't allow you to specify a replacement strategy or an allocation strategy. Remember that by specifying multiple Spot capacity pools you can apply instance diversification and by using `price-capacity-optimized` allocation strategy, Amazon EC2 will automatically launch Spot Instances from the most optimal capacity pools with low prices. This is why we recommended to use EC2 Fleet in `instant` mode as a drop-in replacement for RunInstances API or use Auto Scaling group to manage the instance lifecycle.
{{% /notice %}}

RunInstances API allows you to launch one or more instances, using a launch template that you have previously configured. Typically you would use the RunInstances API to launch one or more instances of the same type in situations where you are not planning to replace or manage the instances as a group entity.

## RunInstance example: Launching a single instance

1. To launch a Spot Instance with RunInstances API you create below configuration file:

```
cat <<EoF > ./runinstances-config.json
{
    "MaxCount": 1,
    "MinCount": 1,
    "InstanceType": "c5.large",
    "LaunchTemplate": {
        "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
        "Version": "1"
    },
    "InstanceMarketOptions": {
        "MarketType": "spot"
    },
    "TagSpecifications": [
        {
            "ResourceType": "instance",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "EC2SpotWorkshopRunInstance"
                }
            ]
        }
    ]
}
EoF
```

2. Run this command to submit the RunInstances API request:

```bash
aws ec2 run-instances --cli-input-json file://runinstances-config.json
```

If the request is successful, you should see an output with the description of the instances that have been launched.

### Challenges
Given the configuration you used above, try to answer the following questions. Click to expand and see the answers. 

{{%notice info%}}
In some applications where RunInstances is used to create and manage instances replacing the RunInstance API with EC2 Fleet API helps to ensure that Spot best practices are enforced while making the minimum modifications to the application. The fact the EC2 Fleet API is also synchronous makes it more reliable than polling with asynchronous RunInstances APIs.
{{% /notice %}}

{{%expand "1. Do you know how to replace this Spot Instance with same launch parameters as above example with EC2 Fleet?" %}}

Based on the previous sections, try to perform the API call following Spot best practices (diversification, allocation strategy, etc).

Configuration file for placing the request:

```
cat <<EoF > ./ec2-fleet-replacement-config.json
{
   "SpotOptions":{
      "MinTargetCapacity": 1,
      "SingleAvailabilityZone": true,
      "AllocationStrategy": "capacity-optimized-prioritized",
      "InstanceInterruptionBehavior": "terminate"
   },
   "LaunchTemplateConfigs":[
      {
         "LaunchTemplateSpecification":{
            "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
            "Version":"1"
         },
         "Overrides":[            
            {
               "InstanceType":"c5.large",
               "Priority": 6.0
            },
            {
               "InstanceType":"m5.large",
               "Priority": 5.0
            },
            {
               "InstanceType":"r5.large",
               "Priority": 4.0
            },
            {
               "InstanceType":"c5a.large",
               "Priority": 3.0
            },
            {
               "InstanceType":"m5a.large",
               "Priority": 2.0
            },
            {
               "InstanceType":"r5a.large",
               "Priority": 1.0
            }
         ]
      }
   ],
   "TargetCapacitySpecification":{
      "TotalTargetCapacity": 1,
      "DefaultTargetCapacityType": "spot"
   },
   "Type":"instant",
   "TagSpecifications": [
      {
         "ResourceType": "instance",
            "Tags": [
               {
                  "Key": "Name",
                  "Value": "EC2SpotWorkshopRunInstance"
               }
            ]
      }
   ]
}
EoF
```

Submit the EC2 Fleet request with this call:

```bash
export REPLACEMENT_FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-replacement-config.json | jq -r '.FleetId')
```

Confirm that the newly created instance by the replacement fleet is running on Spot.

```bash
aws ec2 describe-instances --filters Name=instance-lifecycle,Values=spot Name=tag:aws:ec2:fleet-id,Values=${REPLACEMENT_FLEET_ID} Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].[InstanceId]" --output text
```

{{% /expand %}}
