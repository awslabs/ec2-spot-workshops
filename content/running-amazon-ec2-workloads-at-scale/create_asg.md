+++
title = "Create an EC2 Auto Scaling Group"
weight = 100
+++

Amazon EC2 Auto Scaling helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. You can also use Amazon EC2 Auto Scaling for dynamic scaling of EC2 instances in order to automatically increase the number of Amazon EC2 instances during demand spikes to maintain performance and decrease capacity during lulls to reduce costs. Amazon EC2 Auto Scaling is well suited both to applications that have stable demand patterns or that experience hourly, daily, or weekly variability in usage.

1. Run the following command to edit **asg.json** updating the values of the Target Group created on the previous step, as well as the subnets created by the CloudFormation template.

   ```bash
   sed -i.bak -e "s#%TargetGroupARN%#$tg_arn#g" -e "s/%publicSubnet1%/$publicSubnet1/g" -e "s/%publicSubnet2%/$publicSubnet2/g" asg.json
   ```
   \
   **Challenge**\
   The EC2 Auto Scaling group that you are going to deploy supports [multiple purchase options (On-Demand and Spot Instances) and EC2 instance types](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html). \
   * Examining the asg.json configuration file, can you determine what would be the different configuration options in the deployed ASG?\
   * How many On-Demand and Spot Instances would be deployed?\
   * Which On-Demand and Spot Instances would be selected from the list of Overrides, and why?
   \
   \
   *Hint:* take a look at the [API reference for `InstancesDistribution`] (https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_InstancesDistribution.html) to understand the different   parameters in the asg.json configuration file.
   \
   {{%expand "Click here for the answer" %}}
   With an `OnDemandBaseCapacity` of 2, `OnDemandPercentageAboveBaseCapacity` of 0, and `DesiredCapacity` of 4, initially the ASG is going to contain 2 On-Demand instances and 2 Spot Instances.\
   The instance type of the On-Demand instances will be the first of the list of `Overrides`.\
   The `capacity-optimized` `SpotAllocationStrategy` will pick the instance types that have the most availability of spare capacity in each Availability Zone at launch time. 
   {{% /expand %}}
   \
1. Create the auto scaling group by running:
   ```
   aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
   ```
   \
   {{% notice note %}}
   This command will not return any output if it is successful.
   {{% /notice %}}

	
1. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2autoscaling/home#/details) and check out your newly created Auto Scaling group. Go to the EC2 Instances console and check how many On-Demand instances and how many Spot Instances were deployed - you can do so by using the filter option and selecting Lifecycle = Normal or Spot.
