+++
title = "Create an EC2 Auto Scaling Group"
weight = 100
+++

Amazon EC2 Auto Scaling helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. You can also use Amazon EC2 Auto Scaling for dynamic scaling of EC2 instances in order to automatically increase the number of Amazon EC2 instances during demand spikes to maintain performance and decrease capacity during lulls to reduce costs. Amazon EC2 Auto Scaling is well suited both to applications that have stable demand patterns or that experience hourly, daily, or weekly variability in usage.

1. Edit **asg.json** update the values of the Target Group created on the previous step, as well as the subnets created by the CloudFormation template..

	```
	sed -i.bak -e "s#%TargetGroupARN%#$tg_arn#g" -e "s#%publicSubnet1%#$public_subnet1#g" -e "s#%publicSubnet2%#$public_subnet2#g" asg.json
	```

   	#### Challenge
	The EC2 Auto Scaling group that you are going to deploy supports [multiple purchase options (On-Demand and Spot Instances) and EC2 instance types] (https://aws.amazon.com/blogs/aws/new-ec2-auto-scaling-groups-with-multiple-instance-types-purchase-options/). \
	Examining the asg.json configuration file, can you determine what would be the different configuration options in the deployed ASG?\
	How many On-Demand and Spot Instances would be deployed?\
	Which On-Demand and Spot Instances would be selected from the list of Overrides, and why?


	Hint: take a look at the [API reference for `InstancesDistribution`] (https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_InstancesDistribution.html) to understand the different paraneters in the asg.json configuration file.

	{{%expand "Click here for the answer" %}}
	With an `OnDemandBaseCapacity` of 2, `OnDemandPercentageAboveBaseCapacity` of 0, and `DesiredCapacity` of 4, initially the ASG is going to contain 2 On-Demand instances and 2 Spot Instances.\
	The lowest priced Spot Instances per AZ will be deployed. With the `lowest-price` `SpotAllocationStrategy` and `SpotInstancePools` of 4, once the desired capacity will be higher, the 4 lowest priced Spot Instance types from the list of Overrides will be selected to be deployed in each Availability Zone. 
	{{% /expand %}}

1. Create the auto scaling group running:

   ```
   aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
   ```

   {{% notice note %}}
   This command will not return any output if it is successful.
   {{% /notice %}}

	
1. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created Auto Scaling group. Go to the EC2 Instances console and check how many On-Demand instances and how many Spot Instances were deployed - you can do so by using the filter option and selecting Lifecycle = Normal or Spot.

#### Challenge
Since you deployed one Spot Instance in each Availability Zone, can you verify that the Auto Scaling group selected the lowest-priced Spot Instance in each Availability Zone?\
Hint: Use the [Spot Instance Pricing History] (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances-history.html) tool

{{%expand "Click here for the answer" %}}
1. In the [EC2 Instances console page] (https://console.aws.amazon.com/ec2/v2/home?#Instances), find your Spot Instances by filtering for Lifecycle=Spot.
2. Determine which Spot Instance type was deployed in each AZ.
3. In the [EC2 Spot Instances console] (https://console.aws.amazon.com/ec2sp/v1/spot/home), click the Price History button and check the current Spot price for the Spot Instance that you deployed. You can compare it to the other instance types in the list of Overrides in your asg.json configuration.
{{% /expand %}}
