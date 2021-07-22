+++
title = "Launching EC2 Spot Instances via an EC2 Fleet"
weight = 70
+++

## Launching EC2 Spot Instances with On-Demand Instances via an EC2 Fleet

EC2 Fleet provides a very rich API that allows to operate and procure capacity with quite granular controls. Workloads that can benefit from this API are among other
bespoke capacity orchestrators that implement tuned up and optimized logic to provision capacity. The following projects use EC2 Fleet to manage capacity:

* [Karpenter](https://github.com/awslabs/karpenter). Karpenter is Kubernetes Cluster Autoscaler. It manages the node lifecycle. It observes incoming pods and launches the right instances for the situation.
* [Atlassian Escalator](https://github.com/atlassian/escalator), yet another Kubernetes Cluster Autoscaler. Designed for large batch or job based workloads that cannot be force-drained and moved when the cluster needs to scale down.

An *EC2 Fleet* contains the configuration information to launch a
fleet or group of instances. In a single API call, a fleet can launch
multiple instance types across multiple Availability Zones, using the
On-Demand Instance, Reserved Instance, and Spot Instance purchasing
models together. Using EC2 Fleet, you can define separate On-Demand and
Spot capacity targets, specify the instance types that work best for
your applications, and specify how Amazon EC2 should distribute your
fleet capacity within each purchasing model.

In this part of the workshop we will request an EC2 Fleet using the `instant` fleet request type, which is a feature only available in EC2 Fleet. By doing so, EC2 Fleet places a synchronous one-time request for your desired capacity. In the API response, it returns the instances that launched, along with errors for those instances that could not be launched. More information on request types [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html#ec2-fleet-request-type).

Also, we are going to configure the fleet request so that all the instances are requested of the same type (for example `c5.large`) and in the same Availability Zone. This configuration is suitable for applications that use, for instance, MPI. However, if your use case is different you can remove this constraints from the configuration file, keeping in mind that Auto Scaling Groups is the appropriate solution for most use cases.

**To create a new EC2 Fleet using the command line, run the following**

First, you are going to create the configuration file that will be used to launch the EC2 Fleet. Run the following:

```bash
cat <<EoF > ~/ec2-fleet-config.json
{
   "SpotOptions":{
      "SingleInstanceType": true,
      "SingleAvailabilityZone": true,
      "MinTargetCapacity": 8,
      "AllocationStrategy": "capacity-optimized",
      "InstanceInterruptionBehavior": "terminate"
   },
   "OnDemandOptions":{
      "AllocationStrategy": "prioritized",
      "SingleInstanceType": true,
      "SingleAvailabilityZone": true,
      "MinTargetCapacity": 2
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
               "Priority": 3.0,
               "SubnetId": "${SUBNET_1}"
            },
            {
               "InstanceType":"m5.large",
               "Priority": 2.0,
               "SubnetId": "${SUBNET_1}"
            },
            {
               "InstanceType":"r5.large",
               "Priority": 1.0,
               "SubnetId": "${SUBNET_1}"
            },
            {
               "InstanceType":"c5.xlarge",
               "Priority": 6.0,
               "SubnetId": "${SUBNET_1}"
            },
            {
               "InstanceType":"m5.xlarge",
               "Priority": 5.0,
               "SubnetId": "${SUBNET_1}"
            },
            {
               "InstanceType":"r5.xlarge",
               "Priority": 4.0,
               "SubnetId": "${SUBNET_1}"
            },
            {
               "InstanceType":"c5.large",
               "Priority": 3.0,
               "SubnetId": "${SUBNET_2}"
            },
            {
               "InstanceType":"m5.large",
               "Priority": 2.0,
               "SubnetId": "${SUBNET_2}"
            },
            {
               "InstanceType":"r5.large",
               "Priority": 1.0,
               "SubnetId": "${SUBNET_2}"
            },
            {
               "InstanceType":"c5.xlarge",
               "Priority": 6.0,
               "SubnetId": "${SUBNET_2}"
            },
            {
               "InstanceType":"m5.xlarge",
               "Priority": 5.0,
               "SubnetId": "${SUBNET_2}"
            },
            {
               "InstanceType":"r5.xlarge",
               "Priority": 4.0,
               "SubnetId": "${SUBNET_2}"
            },
            {
               "InstanceType":"c5.large",
               "Priority": 3.0,
               "SubnetId": "${SUBNET_3}"
            },
            {
               "InstanceType":"m5.large",
               "Priority": 2.0,
               "SubnetId": "${SUBNET_3}"
            },
            {
               "InstanceType":"r5.large",
               "Priority": 1.0,
               "SubnetId": "${SUBNET_3}"
            },
            {
               "InstanceType":"c5.xlarge",
               "Priority": 6.0,
               "SubnetId": "${SUBNET_3}"
            },
            {
               "InstanceType":"m5.xlarge",
               "Priority": 5.0,
               "SubnetId": "${SUBNET_3}"
            },
            {
               "InstanceType":"r5.xlarge",
               "Priority": 4.0,
               "SubnetId": "${SUBNET_3}"
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
   "Type":"instant"
}
EoF
```

The EC2 fleet request specifies separately the target capacity for Spot and On-Demand Instances using the `OnDemandTargetCapacity` and `SpotTargetCapacity` fields inside the `TargetCapacitySpecification` structure. The value for `DefaultTargetCapacityType` specifies whether Spot or On-Demand instances should be used to meet the `TotalTargetCapacity`.

By setting `SingleInstanceType` and `SingleAvailabilityZone` to true, we are forcing the EC2 Fleet request to provision all the instances in the same Availability Zone and of the same type.  

Copy and paste this command to create the EC2 Fleet and export its identifier to an environment variable to later monitor the status of the fleet.

```bash
export FLEET_ID=$(aws ec2 create-fleet --cli-input-json file://ec2-fleet-config.json | jq -r '.FleetId')
```

Given the configuration we used above. **Try to answer the following questions:**

1. What would happen if the EC2 Fleet is not able to meet the target of Spot or On-Demand instances?

{{%expand "Show me the answers:" %}}

1.) **What would happen if the EC2 Fleet is not able to meet the target capacity of Spot or On-Demand instances?**

We have specified a value for `MinTargetCapacity` inside `SpotOptions` and `OnDemandOptions` structures. This parameter sets the minimum target capacity that needs to be reached. If it is not reached, the fleet launches no instances.

{{% /expand %}}

These are some of the features and characteristics that EC2 Fleet provides, in addition to the ones covered in this section:

1. **Max price**: The maximum price per unit hour that you are willing to pay for a Spot Instance. When the maximum amount you're willing to pay is reached, the fleet stops launching instances even if it hasn’t met the target capacity.
2. **Valid from**: the start date and time of the request. The default behaviour is to start fulfilling the request immediately.
3. **Valid until**: The end date and time of the request. At this point, no new EC2 Fleet requests are placed or able to fulfill the request.
4. **Instance replacement**: While the fleet is running, if Amazon EC2 reclaims a Spot Instance because of a price increase or instance failure, EC2 Fleet can try to replace the instances with any of the instance types that you specify. This makes it easier to regain capacity during a spike in Spot pricing.
5. **Instance weighting**: Inside the list of overrides, you can specify a `WeightedCapacity` value. When you do that, you are specifying the number of units provided by the specified instance type. Typically you would set the value according to number of VCPUs of the instance. By implementing instance weighting, the capacities that you specify in the `TargetCapacitySpecification` structure won't refer to number of instances but to number of capacity units.

If you want to learn more about EC2 Fleets, you can find more information in the [Amazon EC2 Fleet documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet.html).

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
