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
      "AllocationStrategy":"capacity-optimized",
      "InstanceInterruptionBehavior":"terminate",
      "MaxTotalPrice":"1",
      "MaintenanceStrategies":{
         "CapacityRebalance":{
            "ReplacementStrategy":"launch"
         }
      }
   },
   "OnDemandOptions":{
      "AllocationStrategy":"lowest-price",
      "MaxTotalPrice":"1"
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
               "WeightedCapacity":2
            },
            {
               "InstanceType":"c5.xlarge",
               "WeightedCapacity":4
            },
            {
               "InstanceType":"c4.large",
               "WeightedCapacity":2
            }
         ]
      }
   ],
   "TargetCapacitySpecification":{
      "TotalTargetCapacity":8,
      "OnDemandTargetCapacity":2,
      "SpotTargetCapacity":6,
      "DefaultTargetCapacityType":"spot"
   },
   "Type":"maintain",
   "ReplaceUnhealthyInstances":true
}
EoF
```

Copy and paste this command to create the EC2 Fleet.

```bash
aws ec2 create-fleet -cli-input-json file://ec2-fleet-config.json
```

**Example return**

```bash
{
"FleetId": "fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183"
}
```

## Monitoring Your EC2 Fleet

**To monitor your EC2 Fleet using the command line**
