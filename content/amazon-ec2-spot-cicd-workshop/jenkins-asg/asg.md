+++
title = "Provision an Auto Scaling Group"
weight = 110
+++
Before configuring the EC2 Fleet Jenkins Plugin, create an Auto Scaling Group (ASG) that will be used by the plugin to perform your application builds. As this is a batch processing use case, remember the best practices for this type of workload - leverage per-second billing (catered for through the use of an Amazon Linux AMI defined in the Launch Template); determine job completion and retry failed jobs (the former is handled by the Jenkins EC2 Fleet plugin); and be instance flexible.

First, you are going to create the configuration file that will be used to launch the EC2 Fleet. Run the following commands:

```bash
cat <<EoF > ~/asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"1"
      },
      "Overrides":[
         {
            "InstanceType":"t2.large"
         },
         {
            "InstanceType":"t3.large"
         },
         {
            "InstanceType":"m4.large"
         },
         {
            "InstanceType":"m5.large"
         },
         {
            "InstanceType":"c5.large"
         },
         {
            "InstanceType":"c4.large"
         }
      ]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity": 0,
      "OnDemandPercentageAboveBaseCapacity": 0,
      "SpotAllocationStrategy":"capacity-optimized"
   }
}
EoF
```

Copy and paste this command to create the EC2 Fleet and export its identifier to an environment variable to later monitor the status of the fleet.

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsASG --min-size 0 --max-size 2 --desired-capacity 1 --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --mixed-instances-policy file://asg-policy.json
```