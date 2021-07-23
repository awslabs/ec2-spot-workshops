+++
title = "Launching an EC2 Spot Instance via the RunInstances API"
weight = 80
+++

## Launching an EC2 Spot Instance via the RunInstances API

This API allows you to launch one or more instances, using a Launch Template that you have previously configured. Typically you would use the RunInstances API to launch one or more instances of the same type.

{{%notice note%}}
Even though RunInstances API allows you to launch Spot instances, it doesn't allow you to specify neither a replacement strategy nor an allocation strategy. Remember that by specifying multiple Spot capacity pools we can apply instance diversification and when working with the `capacity optimized` allocation strategy, Amazon EC2 will automatically launch Spot instances from the optimal capacity pools among the ones that have been specified.
{{% /notice %}}

This is why it is recommended to use EC2 Fleet as a drop-in replacement for RunInstances API.

## Launching an EC2 Fleet as a replacement for RunInstances API

As an example, we are going to launch 5 Spot instances of the same type using the Launch Template that we previously created.
Using the RunInstances API, you would need to create this configuration file:

```bash
cat <<EoF > ~/runinstances-config.json
{
    "MaxCount": 5,
    "MinCount": 5,
    "LaunchTemplate": {
        "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
        "Version": "1"
    },
    "InstanceMarketOptions": {
        "MarketType": "spot"
    }
}
EoF
```

Run this command to submit the RunInstances API request:

```bash
aws ec2 run-instances --cli-input-json file://runinstances-config.json
```

If the request is successful, you should see an output with the description of the instances that have been launched.

Now, how would you request 5 Spot instances using an EC2 Fleet? With what we have seen in the previous sections, try to perform the API call following Spot best practices (diversification, allocation strategy, etc). When you are ready, click on *Show me the answer* to see how you have done.

{{%expand "Show me the answer:" %}}

Configuration file for placing the request:

```bash
cat <<EoF > ~/ec2-fleet-replacement-config.json
{
   "SpotOptions":{
      "MinTargetCapacity": 5,
      "SingleAvailabilityZone": true,
      "AllocationStrategy": "capacity-optimized",
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
               "Priority": 3.0
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
            }
         ]
      }
   ],
   "TargetCapacitySpecification":{
      "TotalTargetCapacity": 5,
      "DefaultTargetCapacityType": "spot"
   },
   "Type":"instant"
}
EoF
```

Submit the EC2 Fleet request with this call:

```bash
export REPLACEMENT_FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-replacement-config.json | jq -r '.FleetId')
```

{{% /expand %}}

You have now seen that EC2 offers a richer API that allows you to achieve the same results than RunInstances API and on top of that makes it possible to apply more granular configuration parameters and also follow the best practices associated with Spot. If you want to learn more about RunInstances API, you can find all the documentation [here](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html).
