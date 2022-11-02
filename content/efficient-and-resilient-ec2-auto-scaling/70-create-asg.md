+++
title = "Create an EC2 Auto Scaling Group"
weight = 60
+++

**Amazon EC2 Auto Scaling** helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. You can also use Amazon EC2 Auto Scaling for dynamic scaling of EC2 instances in order to automatically increase the number of Amazon EC2 instances during demand spikes to maintain performance and decrease capacity during lulls to reduce costs. Amazon EC2 Auto Scaling is well suited both to applications that have stable demand patterns or that experience hourly, daily, or weekly variability in usage. You can find more information on the [Auto Scaling documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html). 

{{% notice note %}}
A core assumption of **predictive scaling** is that the Auto Scaling group is **homogenous** and all instances are of **equal capacity**. If this isn’t true for your group, forecasted capacity can be inaccurate. Therefore, use caution when creating predictive scaling policies for mixed instances groups, because instances of different types can be provisioned that are of unequal capacity.
{{% /notice %}}

1. Open **asg.json** on the **Cloud9 IDE** terminal and review the configuration.


2. You will notice there are placeholder values for **`%PrivateSubnet1%`** and **`%PrivateSubnet2%`**. To update the configuration file with the values of the outputs from the CloudFormation stack, execute the following command:
```
sed -i.bak -e "s#%PrivateSubnet1%#$PrivateSubnet1#g" -e "s#%PrivateSubnet2%#$PrivateSubnet2#g" asg.json
```

3. Save the file and create the auto scaling group:
```
aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
```
{{% notice note %}}
This command will not return any output if it is successful.
{{% /notice %}}

	
4. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created auto scaling group. Take a look at the instances it has deployed.

