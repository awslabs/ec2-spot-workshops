+++
title = "(Optional) - Launching an EC2 Spot Instance via the RunInstances API"
weight = 200
+++

## Launching an EC2 Spot Instance via the RunInstances API

This API allows you to launch one or more instances, using a Launch Template that you have previously configured. Typically you would use the RunInstances API to launch one or more instances of the same type in situations where you are not planning to replace or manage the instances as a group entity.

{{%notice note%}}
Even though RunInstances API allows you to launch Spot instances, it doesn't allow you to specify a replacement strategy or an allocation strategy. Remember that by specifying multiple Spot capacity pools we can apply instance diversification and by using `price-capacity-optimized` allocation strategy, Amazon EC2 will automatically launch Spot Instances from the most optimal capacity pools having the lowest Spot pool prices. This is why it is recommended to use EC2 Fleet in `instant` mode as a drop-in replacement for RunInstances API.
{{% /notice %}}

## RunInstance example: Launching a single instance

The most common way to launch a one-off single instance is RunInstance. We will use the Launch Template that we previously created. To launch a RunInstances on EC2 Spot you would need to create this configuration file:

{{%notice note%}}
In this case we are adding a Tag to the newly created instance. We will use this tag to terminate the instance later on.
{{% /notice %}}


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

Run this command to submit the RunInstances API request:

```bash
aws ec2 run-instances --cli-input-json file://runinstances-config.json
```

If the request is successful, you should see an output with the description of the instances that have been launched.

Now, how would you request a Spot instances using an EC2 Fleet?

With what we have seen in the previous sections, try to perform the API call following Spot best practices (diversification, allocation strategy, etc). When you are ready, click on *Show me the answer* to see how you have done.

{{%expand "Show me the answer:" %}}

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
               "InstanceType":"c5.xlarge",
               "Priority": 6.0
            },
            {
               "InstanceType":"m5.xlarge",
               "Priority": 5.0
            },
            {
               "InstanceType":"r5.xlarge",
               "Priority": 4.0
            },
            {
               "InstanceType":"c5.large",
               "Priority": 3.0
            },
            {
               "InstanceType":"m5.large",
               "Priority": 2.0
            },
            {
               "InstanceType":"r5.large",
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

In some applications where RunInstances was used to create and manage instances, this technique of replacing the RunInstance call with EC2 Fleet helps to ensure that Spot best practices are enforced while making the minimum modifications to the application. The fact the call is also synchronous and that shows the result of the provision capacity (Spot or On-Demand), makes it more reliable than polling with asynchronous APIs. Additionally, it provides all the diversification best practices we've seen so far in the rest of the APIs.

Our advise for those applications using still RunInstances and Spot is to consider moving to Auto Scaling Groups. Using even a Single EC2 Spot Instance in an Auto Scaling Group is a good pattern. The Auto Scaling group will replace the instance if un-healthy and manage the life-cycle according to all the best practices we've seen so far.
