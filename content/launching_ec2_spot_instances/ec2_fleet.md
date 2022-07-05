+++
title = "Launching EC2 Spot Instances via an EC2 Fleet"
weight = 50
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
cat <<EoF > ~/ec2-fleet-config.json
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

{{% notice note %}}
You may have noticed that we haven't included the `MaintenanceStrategies` structure. The reason for this is that specifying a replacement strategy is only possible when working with fleets of type maintain.
{{% /notice %}}

The EC2 Fleet request specifies separately the target capacity for Spot and On-Demand Instances using the `OnDemandTargetCapacity` and `SpotTargetCapacity` fields inside the `TargetCapacitySpecification` structure. The value for `DefaultTargetCapacityType` specifies whether Spot or On-Demand Instances should be used to meet the `TotalTargetCapacity`.

By setting `SingleInstanceType` and `SingleAvailabilityZone` to true, we are forcing the EC2 Fleet request to provision all the instances in the same Availability Zone and of the same type.  

Copy and paste this command to create the EC2 Fleet and export its identifier to an environment variable to later monitor the status of the fleet.

```bash
export FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-config.json | jq -r '.FleetId')
```

Given the configuration we used above. **Try to answer the following questions:**

1. What would happen if the EC2 Fleet is not able to meet the target of Spot or On-Demand instances?
2. How can you check the status of the request we just created?

{{%expand "Show me the answers:" %}}

1.) **What would happen if the EC2 Fleet is not able to meet the target capacity of Spot or On-Demand instances?**

We have specified a value for `MinTargetCapacity` inside `SpotOptions` and `OnDemandOptions` structures. This parameter sets the minimum target capacity that needs to be reached. If it is not reached, the fleet launches no instances and the response provides an error indicating that the minimum request for instances could not be met.

Note that that by providing additional diversification, EC2 Fleet will check into more pools and be able to reach more capacity. Consider adding more diversification in those cases.

2.) **How can you check the status of the request we just created?**
You can view the configuration parameters of your EC2 Fleet using this command:

```
aws ec2 describe-fleets --fleet-ids "${FLEET_ID}"
```


{{% notice note %}}
EC2 Fleet does also have a `aws ec2 describe-fleet-history` and `aws ec2 describe-fleet-instances`, similarly to Spot Fleet API. However, EC2 Fleet in instant mode is not considered a regular fleet request. In fact, while for EC2 Fleet and Spot Fleet you have limits on the number of active fleets you can create, for EC2 Fleet in instant mode you can make as many calls as needed. In this regard think of it as a replacement of RunInstance API that implements Spot best practices.
{{% /notice %}}

{{% /expand %}}


#### Brief Summary of EC2 Fleet functionality

These are some of the features and characteristics that EC2 Fleet provides, in addition to the ones covered in this section:

1. **Instant mode support**: EC2 Fleet supports `instant` mode, the mode we used during this workshop. A synchronous call that can be used as a drop-in-replacement for RunInstances but that offers a selection of pools and diversification using allocation strategies.
2. **Control Spending**: Similar to Spot Fleet, EC2 Fleet does offer fine granularity in the controls for the fleet spending. Documentation to [EC2 Fleet control spending is available here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-control-spending)
3. **Valid from - until**: Spot Fleet allows also to define the duration for which Spot Fleet requests are valid by providing a *from* and *until* value.
4. **Instance replacement**: In `maintain` and `request` modes, EC2 Fleet works like Spot Fleet.
5. **Instance weighting**: Same as EC2 Fleet and AutoScaling, EC2 Fleet supports weights and priorities.
6. **On-demand as primary capacity**: Unlike Spot Fleet, in EC2 Fleet you can select which type of capacity (OnDemand or Spot) will be selected as primary when scaling out. [You can read more here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-on-demand-walkthrough)
7. **On-Demand Backup**: Everything that we have learned about diversification does not only apply to Spot Instances. It might apply, also, for very large workloads with On-Demand Instances. Although is really rare, there might be cases where if a specific type of an On-Demand Instance is not available, the workload would benefit from an [On-Demand Backup selection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-on-demand-backup)

If you want to learn more about EC2 Fleets, you can find more information in the [Amazon EC2 Fleet documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet.html).
