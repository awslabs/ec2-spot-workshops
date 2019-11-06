+++
title = "Create an EC2 Auto Scaling Group"
weight = 100
+++

Amazon EC2 Auto Scaling helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. You can also use Amazon EC2 Auto Scaling for dynamic scaling of EC2 instances in order to automatically increase the number of Amazon EC2 instances during demand spikes to maintain performance and decrease capacity during lulls to reduce costs. Amazon EC2 Auto Scaling is well suited both to applications that have stable demand patterns or that experience hourly, daily, or weekly variability in usage.

1. Edit **asg.json** update the values of the Target Group created on the previous step, as well as the subnets created by the CloudFormation template..

	```
	sed -i.bak -e "s#%TargetGroupARN%#$tg_arn#g" -e "s#%publicSubnet1%#$public_subnet1#g" -e "s#%publicSubnet2%#$public_subnet2#g" asg.json
	```

1. Take a look at the configuration file and create the auto scaling group:

	```
	aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
	```
{{% notice note %}}
This command will not return any output if it is successful.
{{% /notice %}}

	
1. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created auto scaling group. Take a look at the instances it has deployed.