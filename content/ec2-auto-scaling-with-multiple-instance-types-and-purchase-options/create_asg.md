+++
title = "Create an EC2 Auto Scaling Group"
weight = 100
+++

Amazon EC2 Auto Scaling allows you to combine purchase options and instance types so you can optimize your compute costs. Stateless web applications are a great fit to run on Spot Instances as they can tolerate interruptions and are often flexible to run on multiple instance types. In this section, you will create an Auto Scaling group combining a base of On-Demand instances and scaling out with EC2 Spot instances and save an average of 70% in your compute costs. 

{{%expand "To learn more about EC2 Auto Scaling click here" %}}
Amazon EC2 Auto Scaling helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. You can also use Amazon EC2 Auto Scaling for dynamic scaling of EC2 instances in order to automatically increase the number of Amazon EC2 instances during demand spikes to maintain performance and decrease capacity during lulls to reduce costs. Amazon EC2 Auto Scaling is well suited both to applications that have stable demand patterns or that experience hourly, daily, or weekly variability in usage.
{{% /expand %}}

1. Open **asg.json** on the Cloud9 editor and review the configuration. Pay special attention at the **Overrides** and the **InstancesDistribution**. Take a look at our [docs](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies) to review how InstancesDistribution and allocation strategies work. You will also notice that the **CapacityRebalance** parameter is set to true, which will proactively attempt to replace Spot Instances at elevated risk of interruption. To learn more about the Capacity Relabancing feature, take a look at the [docs](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html).
{{%expand "Help me understand the AutoScaling configuration" %}}
The **Overrides** configuration block provides EC2 AutoScaling the list of instance types your workload can run on. As Spot instances are **spare** EC2 capacity, your workloads should be flexible to run on multiple instance types and multiple availability zones; hence leveraging multiple *spot capacity pools* and making the most out of the available spare capacity. You can use the [EC2 Instance Types console](https://console.aws.amazon.com/ec2/v2/home?#InstanceTypes:) or the [ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector) CLI tool to find suitable instance types. To adhere to best practices and maximize your chances of launching your target Spot capacity, configure a minimum of 6 different instance types across 3 Availability Zones). That would give you the ability to provision Spot capacity from 18 different capacity pools. 

Then, the *InstancesDistribution* configuration block determines how EC2 Auto Scaling picks the instance types to use, while at the same time it keeps a balanced number of EC2 instances per Availability Zone.

* The **prioritized** allocation strategy for on-demand instances makes AutoScaling try to launch the first instance type of your list and skip to the next instance type if for any reason it's unable to launch it (e.g. temporary unavailability of capacity). This is particularly useful if you have [Reserved Instances](https://aws.amazon.com/ec2/pricing/reserved-instances/) or [Savings Plans](https://aws.amazon.com/savingsplans/) for your baseline capacity, so Auto Scaling launches the instance type matching your reservations. 
* **OnDemandBaseCapacity** is set to 2, meaning the first two EC2 instances launched by EC2 AutoScaling will be on-demand.
* **OnDemandPercentageAboveBaseCapacity** is set to 0 so all the additional instances will be launched as Spot Instances
* **SpotAllocationStrategy** is capacity-optimized, which instructs AutoScaling to pick the optimal instance type on each Availability Zone based on launch time availability of spare capacity for your instance type selection.
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

# Optional exercise

Now that you have deployed an EC2 Auto Scaling group with Mixed Instance Types and Purchase options, take some time to go through the different configurations in the [console](https://console.aws.amazon.com/ec2autoscaling/home?#/). Click on the **myEC2Workshop** Auto Scaling group and go to the *Purchase options and instance types* section and try to edit the instance types configured on the Auto Scaling group and change the "primary instance type" to see how the Auto Scaling console provides you a recommended list of instance types based on your selected instance type.