+++
title = "Launching EC2 Spot Instances via an EC2 Fleet"
weight = 70
+++

## Launching EC2 Spot Instances with On-Demand Instances via an EC2 Fleet

An *EC2 Fleet* contains the configuration information to launch a
fleet—or group—of instances. In a single API call, a fleet can launch
multiple instance types across multiple Availability Zones, using the
On-Demand Instance, Reserved Instance, and Spot Instance purchasing
models together. Using EC2 Fleet, you can define separate On-Demand and
Spot capacity targets, specify the instance types that work best for
your applications, and specify how Amazon EC2 should distribute your
fleet capacity within each purchasing model.

**To create a new EC2 Fleet using the command line, run the following**

First, you are going to create the configuration file that will be used to launch the EC2 Fleet. Rn the following:

```bash
cat <<EoF > ~/ec2-fleet-config.json
{
   "SpotOptions":{
      "AllocationStrategy": "capacity-optimized",
      "InstanceInterruptionBehavior": "terminate",
      "MaintenanceStrategies":{
         "CapacityRebalance":{
            "ReplacementStrategy": "launch"
         }
      }
   },
   "OnDemandOptions":{
      "AllocationStrategy": "lowest-price"
   },
   "LaunchTemplateConfigs":[
      {
         "LaunchTemplateSpecification":{
            "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
            "Version":"1"
         },
         "Overrides":[
            {
               "InstanceType": "c5.large"
            },
            {
               "InstanceType": "m5.large"
            },
            {
               "InstanceType": "r5.large"
            },
            {
               "InstanceType": "c4.large"
            },
            {
               "InstanceType":"m4.large"
            },
            {
               "InstanceType":"r4.large"
            }
         ]
      }
   ],
   "TargetCapacitySpecification":{
      "TotalTargetCapacity": 10,
      "OnDemandTargetCapacity": 2,
      "SpotTargetCapacity": 8,
      "DefaultTargetCapacityType": "spot"
   },
   "Type":"instant",
   "ReplaceUnhealthyInstances":true
}
EoF
```

One of the main differences between Spot Fleet and EC2 Fleet is that you can use the `instant` fleet request type with EC2 Fleets. By doing so, EC2 Fleet places a synchronous one-time request for your desired capacity. In the API response, it returns the instances that launched, along with errors for those instances that could not be launched. More information on request types [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-request-type).

In addition, with EC2 fleet you can specify separetely the target capacity for Spot and On-Demand Instances. The value for `DefaultTargetCapacityType` specifies wheter Spot or On-Demand instances should be used to meet the `TotalTargetCapacity`.

Copy and paste this command to create the EC2 Fleet and export its identifier to an environment variable to later monitor the status of the fleet.

```bash
export FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-config.json | jq -r '.FleetId')
```

## Monitoring Your EC2 Fleet

**To monitor your EC2 Fleet using the command line**

You can view the configuration parameters of your EC2 Fleet using this command:

```bash
aws ec2 describe-fleets --fleet-ids "${FLEET_ID}"
```

You can view the status of the instances provisioned by the EC2 Fleet using the following command:

```bash
aws ec2 describe-fleet-instances --fleet-id "${FLEET_ID}"
```
