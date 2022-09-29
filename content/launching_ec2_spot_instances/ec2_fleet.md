+++
title = "Launching EC2 Spot Instances via EC2 Fleet"
weight = 60
+++

EC2 Fleet provides an API that allows to operate and procure capacity with quite granular controls. An *EC2 Fleet* contains the configuration information to launch a
fleet or group of instances. In a single API call, a fleet can launch
multiple instance types across multiple Availability Zones, using the
On-Demand Instance, Reserved Instance, and Spot Instance purchasing
models together. Using EC2 Fleet, you can define separate On-Demand and
Spot capacity targets, specify the instance types that work best for
your applications, and specify how Amazon EC2 should distribute your
fleet capacity within each purchasing model.


Workloads that can benefit from this API are among other
bespoke capacity orchestrators that implement tuned up and optimized logic to provision capacity. Just to name a few, the following projects use EC2 Fleet to manage capacity:

* [Karpenter](https://github.com/awslabs/karpenter). Karpenter is Kubernetes Cluster Autoscaler. It manages the node lifecycle. It observes incoming pods and launches the right instances for the situation.
* [Atlassian Escalator](https://github.com/atlassian/escalator), yet another Kubernetes Cluster Autoscaler. Designed for large batch or job based workloads that cannot be force-drained and moved when the cluster needs to scale down.

EC2 Fleet can also be used in `instant` type or mode as a drop-in-replacement to the RunInstances API, where you can create single instance types, but with the benefit of adhering to Spot best practices of diversification.

#### EC2 Fleet example : Applying instance diversification on HPC tightly coupled workloads with EC2 Fleet instant mode

In this part of the workshop we tackle a common workload for with EC2 Fleet provides benefit when running.

{{% notice warning %}}
Note that while we will be using Spot Instances, most of MPI workloads, specially those that run for hours and do not use checkpointing, are not appropriate for Spot Instances. Remember Spot Instances are suited for fault tolerant applications that can recover from the loss and replacement of one or more instances.
{{% /notice %}}

In this part of the workshop we will request an EC2 Fleet using the `instant` fleet request type, which is a feature only available in EC2 Fleet. By doing so, EC2 Fleet places a synchronous one-time request for your desired capacity. In the API response, it returns the instances that launched, along with errors for those instances that could not be launched. More information on request types [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-request-type).


Tightly coupled HPC workloads typically suffer from performance degradation when the instances in the cluster are of different types (i.e: `c5.large` vs `c4.xlarge`). However we still want to apply diversification for Spot instances! The other characteristic of this workload is that all the instances must be close together (ideally in the same [placement group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html)).

We are going to configure the fleet request so that all the instances provided by the fleet are of the same type (for example `c5.large`) and also from the same Availability Zone.

This configuration is suitable for HPC tightly coupled applications that use MPI. If your HPC application is loosely coupled and you can remove these constraints, keep in mind that Auto Scaling groups is the appropriate solution for most use cases.

First, you are going to create the configuration file that will be used to launch the EC2 Fleet. Run the following:

```bash
cat <<EoF > ./ec2-fleet-config.json
{
   "SpotOptions":{
      "SingleInstanceType": true,
      "SingleAvailabilityZone": true,
      "MinTargetCapacity": 4,
      "AllocationStrategy": "capacity-optimized-prioritized",
      "InstanceInterruptionBehavior": "terminate"
   },
   "OnDemandOptions":{
      "AllocationStrategy": "prioritized",
      "SingleInstanceType": true,
      "SingleAvailabilityZone": true,
      "MinTargetCapacity": 0
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
      "TotalTargetCapacity": 4,
      "OnDemandTargetCapacity": 0,
      "DefaultTargetCapacityType": "spot"
   },
   "Type":"instant"
}
EoF
```

The EC2 Fleet request specifies separately the target capacity for Spot and On-Demand Instances using the `OnDemandTargetCapacity` and `SpotTargetCapacity` fields inside the `TargetCapacitySpecification` structure. The value for `DefaultTargetCapacityType` specifies whether Spot or On-Demand Instances should be used to meet the `TotalTargetCapacity`.

By setting `SingleInstanceType` and `SingleAvailabilityZone` to true, we are forcing the EC2 Fleet request to provision all the instances in the same Availability Zone and of the same type.  

Copy and paste this command to create the EC2 Fleet and export its identifier to an environment variable to later monitor the status of the fleet.

```bash
export FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-config.json | jq -r '.FleetId')
```

Given the configuration we used above. **Try to answer the following questions:**

1. What would happen if the EC2 Fleet is not able to meet the target of Spot or On-Demand instances?
2. How can you check the status of the request we just created?
3. How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?

{{%expand "Show me the answers:" %}}

1.) **What would happen if the EC2 Fleet is not able to meet the target capacity of Spot or On-Demand instances?**

We have specified a value for `MinTargetCapacity` inside `SpotOptions` and `OnDemandOptions` structures. This parameter sets the minimum target capacity that needs to be reached. If it is not reached, the fleet launches no instances and the response provides an error indicating that the minimum request for instances could not be met.

Note that that by providing additional diversification, EC2 Fleet will check into more pools and be able to reach more capacity. Consider adding more diversification in those cases.

2.) **How can you check the status of the request we just created?**
You can view the configuration parameters of your EC2 Fleet using this command:

```bash
aws ec2 describe-fleets --fleet-ids "${FLEET_ID}"
```

3.) **How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?**

To describe one or more instances we use `describe-fleets`. To retrieve all the Spot Instances that have been launched by the EC2 Fleet, we apply two filters: `instance-lifecycle` set to `spot` to retrieve only Spot Instances and the custom tag `aws:ec2:fleet-id` that must be set to $FLEET_ID.

{{% notice note %}}
When launching instances using an EC2 Fleet, EC2 Fleet automatically adds a tag to the instances with a key of aws:ec2:fleet-id and a value of the fleet id. We are going to use that tag to retrieve the instances that were launched by the EC2 Fleet we just created. 
{{% /notice %}}

```bash
aws ec2 describe-instances --filters Name=instance-lifecycle,Values=spot Name=tag:aws:ec2:fleet-id,Values=${FLEET_ID} Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].[InstanceId]" --output text
```

The output will have the identifiers of the Spot Instances, as we have deduced in the second question.

Similarly, you can run the following command to retrieve the identifiers of the instances that have been launched using the On-Demand purchasing model.

```bash
aws ec2 describe-instances --filters Name=tag:aws:ec2:fleet-id,Values=${FLEET_ID} Name=instance-state-name,Values=running --query "Reservations[*].Instances[? InstanceLifecycle==null].[InstanceId]" --output text
```
{{% /expand %}}

#### How about using attribute-based instance type selection

[*Attribute-based instance type selection (ABS)*](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html) offers an alternative to manually choosing instance types when creating an Amazon EC2 Auto Scaling (ASG) or EC2 Fleet, by specifying a set of instance attributes `InstanceRequirements` that describe your compute requirements. As ASG or EC2 Fleet launches instances, any instance types used by them will match your required instance attributes.  *ABS* only supports `lowest-price` allocation strategy for On-Demand, and `capacity-optimized` or `lowest-price`  allocation strategy for Spot instances. 

*ABS* can be utilized on ASG or EC2 Fleet via the AWS Management Console, AWS CLI, or SDKs. *ABS* is suitable for picking a set of Amazon EC2 instances that can run a flexible workloads and/or frameworks. *By using ABS to select the list of Amazon EC2 instances for your workload, your application will follow the Spot best practice of diversifying instances across as many Spot pools, thus enabling your ASG or EC2 Fleet to optimally provision Spot capacity.*

*Attribute-based instance type selection* also provides for two price protection thresholds -  `OnDemandMaxPricePercentageOverLowestPrice` for On-Demand instances, and `SpotMaxPricePercentageOverLowestPrice` for Spot instances, so that you can prevent Amazon EC2 Auto Scaling or EC2 Fleet from launching more expensive instance types. Price protection is enabled by default when using ASG or EC2 Fleet, with a default threshold of 20 percent for On-Demand instances and 100 percent for Spot instances. The thresholds represent what you are willing to pay, defined in terms of a percentage above a baseline, rather than as absolute values. The baseline is determined by the price of the least expensive current generation M, C, or R instance type with your specified attributes. If your attributes don't match any M, C, or R instance types, we use the lowest priced instance type. When ASG or EC2 Fleet selects instance types with your attributes, it excludes instance types priced above your threshold. 

{{%expand "Setting up ABS for my EC2 Fleet:" %}}

To create an EC2 Fleet with *attribute-based instance type selection*, you can use a *json* file that is given below. The example selects *intel* instances via `CpuManufacturers` with vcpus between 2 and 4 using `VCpuCount` attribute, and memory between 8Gib and 32Gib using `MemoryMiB` attribute. The selection will include instances including c5.xlarge, m5.xlarge, r5.xlarge, and many other instance types. We will only use the default price protection thresholds for both On-Demand and Spot instances.

Note the changes to these allocation strategies in the EC2 Fleet request as *ABS* only supports `lowest-price` allocation strategy for On-Demand and `capacity-optimized`  allocation strategy for Spot instances. 

```bash
cat <<EoF > ./ec2-fleet-config.json
{
   "SpotOptions":{
      "SingleInstanceType": true,
      "SingleAvailabilityZone": true,
      "MinTargetCapacity": 4,
      "AllocationStrategy": "capacity-optimized",
      "InstanceInterruptionBehavior": "terminate"
   },
   "OnDemandOptions":{
      "AllocationStrategy": "lowest-price",
      "SingleInstanceType": true,
      "SingleAvailabilityZone": true,
      "MinTargetCapacity": 0
   },
   "LaunchTemplateConfigs":[
      {
         "LaunchTemplateSpecification":{
            "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
            "Version":"1"
         },
         "Overrides":[{
            "InstanceRequirements": {
               "VCpuCount": {
                  "Min": 2, 
                  "Max": 4
               },
               "MemoryMiB": {
                  "Min": 8192,
                  "Max": 32768
               },
               "CpuManufacturers": [
                  "intel"
               ]
            }
         }]
      }
   ],
   "TargetCapacitySpecification":{
      "TotalTargetCapacity": 4,
      "OnDemandTargetCapacity": 0,
      "DefaultTargetCapacityType": "spot"
   },
   "Type":"instant"
}
EoF
```

To delete your existing EC2 Fleet and terminate the running instances using the CLI

```bash
aws ec2 delete-fleets --fleet-ids "${FLEET_ID}" --terminate-instances
```

Run this command to recreate the EC2 Fleet and we will export its identifier to an environment variable to later monitor the status of the fleet.

```bash
export FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-config.json | jq -r '.FleetId')
```

{{% /expand %}}

#### Brief Summary of EC2 Fleet functionality

These are some of the features and characteristics that EC2 Fleet provides, in addition to the ones covered in this section:

1. **Instant mode support**: EC2 Fleet supports `instant` mode, the mode we used during this workshop. A synchronous call that can be used as a drop-in-replacement for RunInstances but that offers a selection of pools and diversification using allocation strategies.
1. **Attribute-based instance type selection**: EC2 Fleet selects a number of instance families and sizes based a set of instance attributes that describe your compute requirements. [Attribute-based instance type selection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-attribute-based-instance-type-selection.html).
1. **Control Spending**: With EC2 Fleet you have finer granularity on how you specify the maximum price you are willing to pay. You can specify separately the maximum price per unit hour that you are willing to pay for a Spot or On-Demand Instance. You can also specify they maximum that you are willing to pay per hour for the fleet. Documentation to [EC2 Fleet control spending is available here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-control-spending)
1. **Valid from - until**: EC2 Fleet allows also to define the duration for which EC2 Fleet requests are valid by providing a *from* and *until* value.
1. **Replace unhealthy instances**: Like in the case of Auto Scaling groups, when running in `maintain` mode you can instruct EC2 Fleet to detect and replace un-healthy instances.
1. **Instance weighting**: Same as Amazon EC2 Auto Scaling group, EC2 Fleet supports weights and priorities.
1. **On-demand as primary capacity**: In EC2 Fleet, you can select which type of capacity (OnDemand or Spot) will be selected as primary when scaling out. [You can read more here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-on-demand-walkthrough)
1. **On-Demand Backup**: Everything that we have learned about diversification does not only apply to Spot Instances. It might apply, also, for very large workloads with On-Demand Instances. Although is really rare, there might be cases where if a specific type of an On-Demand Instance is not available, the workload would benefit from an [On-Demand Backup selection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-on-demand-backup)

If you want to learn more about EC2 Fleets, you can find more information in the [Amazon EC2 Fleet documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet.html).
