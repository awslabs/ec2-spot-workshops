+++
title = "Launching EC2 Spot Instances via EC2 Fleet"
weight = 60
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Launching EC2 Spot Instances](https://catalog.us-east-1.prod.workshops.aws/workshops/36a2c2bb-b92d-4428-8626-3a75df01efcc/en-US)**.

{{% /notice %}}

EC2 Fleet provides an API that allows to operate and procure capacity with quite granular controls. An *EC2 Fleet* contains the configuration information to launch a fleet or group of instances. Using EC2 Fleet, you can define separate On-Demand and Spot capacity targets, specify the instance types that work best for your applications, and specify how Amazon EC2 should distribute your fleet capacity within each purchasing model.

Workloads that can benefit from EC2 Fleet API are among other bespoke capacity orchestrators that implement tuned up and optimized logic to provision capacity. Just to name a few, the following projects use EC2 Fleet to manage capacity:

* [Karpenter](https://github.com/awslabs/karpenter). Karpenter is Kubernetes Cluster Autoscaler. It manages the node lifecycle. It observes incoming pods and launches the right instances for the situation.
* [Atlassian Escalator](https://github.com/atlassian/escalator), yet another Kubernetes Cluster Autoscaler. Designed for large batch or job based workloads that cannot be force-drained and moved when the cluster needs to scale down.

#### EC2 Fleet example : Applying instance diversification on HPC tightly coupled workloads with EC2 Fleet instant mode

In this part of the workshop you tackle a common workload for with EC2 Fleet provides benefit when running.

{{% notice warning %}}
Note that while using Spot Instances, most of MPI workloads, specially those that run for hours and do not use checkpointing, are not appropriate for Spot Instances. Remember Spot Instances are suited for fault tolerant applications that can recover from the loss and replacement of one or more instances.
{{% /notice %}}

In this part of the workshop you request an EC2 Fleet using the request type `instant`, which is a feature only available in EC2 Fleet. By doing so, EC2 Fleet places a synchronous one-time request for your desired capacity. In the API response, it returns the instances that launched, along with errors for those instances that could not be launched. More information on request types [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-request-type).

{{% notice info %}}
Tightly coupled HPC workloads typically suffer from performance degradation when the instances in the cluster are of different instance families and sizes (i.e: `c5.large` vs `c4.large` or `c5.large` vs `c5.xlarge`). The other characteristic of this workload is that all the instances must be close together (ideally in the same [placement group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html)). To satisfy these constraints you configure the fleet request with same instance type (for example `c5.large`) in a single Availability Zone. If your HPC application is loosely coupled and you can remove these constraints and use Auto Scaling groups instead.
{{% /notice %}}

1. Create the configuration file to launch the EC2 Fleet with [**attribute-based instance type selection (ABIS)**](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html). Run the following:

```bash
cat <<EoF > ./ec2-fleet-config.json
{
   "SpotOptions":{
      "SingleInstanceType": true,
      "SingleAvailabilityZone": true,
      "MinTargetCapacity": 4,
      "AllocationStrategy": "price-capacity-optimized",
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
                  "Min": 0
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

- The EC2 Fleet request specifies separately the target capacity for Spot and On-Demand Instances using the `OnDemandTargetCapacity` and `SpotTargetCapacity` fields inside the `TargetCapacitySpecification` structure. The value for `DefaultTargetCapacityType` specifies whether Spot or On-Demand Instances should be used to meet the `TotalTargetCapacity`.

- By setting `SingleInstanceType` and `SingleAvailabilityZone` to true, you are forcing the EC2 Fleet request to provision all the instances in the same Availability Zone and of the same type.  

2. Copy and paste this command to create the EC2 Fleet and export its identifier to an environment variable to later monitor the status of the fleet.

```bash
export FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-config.json | jq -r '.FleetId')
```

You have now created an EC2 Fleet with request type instance!

### Challenges
Given the configuration you used above, try to answer the following questions. Click to expand and see the answers. 

{{%expand "1. What would happen if the EC2 Fleet is not able to meet the target capacity of Spot or On-Demand instances?" %}}

You have specified a value for `MinTargetCapacity` inside `SpotOptions` and `OnDemandOptions` structures. This parameter sets the minimum target capacity that needs to be reached. If it is not reached, the fleet launches no instances and the response provides an error indicating that the minimum request for instances could not be met.

Note that that by providing additional diversification, EC2 Fleet will check into more pools and be able to reach more capacity. Consider adding more diversification in those cases.
{{% /expand %}}

{{%expand "2. How can you check the status of the request you just created?" %}}
You can view the configuration parameters of your EC2 Fleet using this command:

```bash
aws ec2 describe-fleets --fleet-ids "${FLEET_ID}"
```
{{% /expand %}}

{{%expand "3. How can you check which instances have been launched using the Spot purchasing model and which ones using the On-Demand?" %}}

To describe one or more instances you use `describe-fleets`. To retrieve all the Spot Instances that have been launched by the EC2 Fleet, you apply two filters: `instance-lifecycle` set to `spot` to retrieve only Spot Instances and the custom tag `aws:ec2:fleet-id` that must be set to $FLEET_ID.

{{% notice note %}}
When launching instances using an EC2 Fleet, EC2 Fleet automatically adds a tag to the instances with a key of aws:ec2:fleet-id and a value of the fleet id. You are going to use that tag to retrieve the instances that were launched by the EC2 Fleet you just created. 
{{% /notice %}}

```bash
aws ec2 describe-instances --filters Name=instance-lifecycle,Values=spot Name=tag:aws:ec2:fleet-id,Values=${FLEET_ID} Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].[InstanceId]" --output text
```

To check the newly created instances in the AWS Console, head to [EC2 Dashboard home](https://console.aws.amazon.com/ec2/home?#Home:), click on "Instances (running), and filter the list of instances using `aws:ec2:fleet-id = $FLEET_ID` and `Instance lifecycle = spot`.

{{% /expand %}}

#### Optional reads

These are some of the features and characteristics that EC2 Fleet provides, in addition to the ones covered in this section:

1. **Instant mode support**: EC2 Fleet supports `instant` mode, the mode you used during this workshop. A synchronous call that can be used as a drop-in-replacement for RunInstances but that offers a selection of pools and diversification using allocation strategies.
1. **Attribute-based instance type selection**: EC2 Fleet selects a number of instance families and sizes based a set of instance attributes that describe your compute requirements. [Attribute-based instance type selection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-attribute-based-instance-type-selection.html).
1. **Control Spending**: With EC2 Fleet you have finer granularity on how you specify the maximum price you are willing to pay. You can specify separately the maximum price per unit hour that you are willing to pay for a Spot or On-Demand Instance. You can also specify they maximum that you are willing to pay per hour for the fleet. Documentation to [EC2 Fleet control spending is available here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-control-spending)
1. **Valid from - until**: EC2 Fleet allows also to define the duration for which EC2 Fleet requests are valid by providing a *from* and *until* value.
1. **Replace unhealthy instances**: Like in the case of Auto Scaling groups, when running in `maintain` mode you can instruct EC2 Fleet to detect and replace un-healthy instances.
1. **Instance weighting**: Same as Amazon EC2 Auto Scaling group, EC2 Fleet supports weights and priorities.
1. **On-demand as primary capacity**: In EC2 Fleet, you can select which type of capacity (OnDemand or Spot) will be selected as primary when scaling out. [You can read more here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-on-demand-walkthrough)
1. **On-Demand Backup**: Everything that you have learned about diversification does not only apply to Spot Instances. It might apply, also, for very large workloads with On-Demand Instances. Although is really rare, there might be cases where if a specific type of an On-Demand Instance is not available, the workload would benefit from an [On-Demand Backup selection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-on-demand-backup)