+++
title = "Create an EC2 Auto Scaling Group"
weight = 100
+++

Amazon EC2 Auto Scaling helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. You can also use Amazon EC2 Auto Scaling for dynamic scaling of EC2 instances in order to automatically increase the number of Amazon EC2 instances during demand spikes to maintain performance and decrease capacity during lulls to reduce costs. Amazon EC2 Auto Scaling is well suited both to applications that have stable demand patterns or that experience hourly, daily, or weekly variability in usage.

1. Open **asg.json** on the Cloud9 editor and review the configuration. Pay special attention at the **Overrides** and the **InstancesDistribution** configuration blocks and try to guess how many instances of which instance type and which purchase option will be launched. Take a look at our [docs](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies) to review how InstancesDistribution and allocation strategies work.
{{%expand "Help me understand the AutoScaling configuration" %}}
The **Overrides** configuration block provides EC2 AutoScaling the list of instance types your workload can run on. As Spot instances are **spare** EC2 capacity, your workloads should be flexible to run on multiple instance types and multiple availability zones; hence leveraging multiple *spot capacity pools* and making the most out of the available spare capacity. To select a list of instance types for your workload you can use [Spot Instance Advisor](https://aws.amazon.com/ec2/spot/instance-advisor/) which will help you filtering suitable instances by number of vCPUs and amount of memory and also provide you data about the interruption rate during the last 30 days for each instance type, so you can pick a list of best-suited instance types with low interruption rates.

Then, the InstancesDistribution configuration block determines how EC2 AutoScaling picks the instance types to use, while at the same time it keeps a balanced number of EC2 instances per Availability Zone.

* The *prioritized* allocation strategy for on-demand instances will make AutoScaling try to use the first instance type of your list; this is particularly useful if you have Reserved Instances for your baseline capacity, so AutoScaling launches instance types matching your reservations. 
* OnDemandBaseCapacity is set to 2, meaning the first two EC2 instances launched by EC2 AutoScaling will be on-demand.
* OnDemandPercentageAboveBaseCapacity is set to 0, meaning that all the additional instance swill be launched as Spot Instances
* SpotAllocationStrategy is lowest-price, which instructs AutoScaling to pick the cheapest instance type.
* SpotInstancePools is 4, which tells AutoScaling to launch instances across the 4 cheapest instance types on each Availability Zone for the list of instances provided in the overrides; hence acquiring capacity from multiple *Spot pools*. 
{{% /expand %}}

1. You will notice there are placeholder values for **%TargetGroupArn%**, **%publicSubnet1%** and **%publicSubnet2%**. To update the configuration file with the values of the Target Group you created previously and the outputs from the CloudFormation template, execute the following command:
```
sed -i.bak -e "s#%TargetGroupARN%#$TargetGroupArn#g" -e "s#%publicSubnet1%#$publicSubnet1#g" -e "s#%publicSubnet2%#$publicSubnet2#g" asg.json
```

1. Save the file and create the auto scaling group:
```
aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
```
{{% notice note %}}
This command will not return any output if it is successful.
{{% /notice %}}

	
1. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created auto scaling group. Take a look at the instances it has deployed.


## Optional exercise

Now that you have deployed an EC2 AutoScaling group with Mixed Instance Types and Purchase Options, take some time to manually scale out and scale in the number of instances of the group and see which instance types AutoScaling launches. Also, modify the SpotInstancePools parameter and experiment with the [capacity-optimized](https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/) allocation strategy to get a good grasp of how the different allocation strategies behave. 