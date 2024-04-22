+++
title = "Create an EC2 Auto Scaling Group"
weight = 100
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Amazon EC2 Auto Scaling Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/0a0fe16c-8693-4d23-8679-4f1701dbd2b0/en-US)**.

{{% /notice %}}


To launch, maintain and scale EC2 instances dynamically for your application, you are going to create an Amazon EC2 Auto Scaling group. To help you meet your cost optimization goals, EC2 Auto Scaling allows you to combine purchase options and instance types within your Auto Scaling group. Stateless web applications are a great fit to run on EC2 Spot Instances as they can tolerate interruptions and are often flexible to run on multiple instance types. In this section, you will create an Auto Scaling group combining a base of On-Demand instances and scaling out with EC2 Spot instances and save an average of 70% in your compute costs. 

Amazon EC2 Auto Scaling helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. You can also use Amazon EC2 Auto Scaling for dynamic scaling of EC2 instances in order to automatically increase the number of Amazon EC2 instances during demand spikes to maintain performance and decrease capacity during lulls to reduce costs. Amazon EC2 Auto Scaling is well suited both to applications that have stable demand patterns or that experience hourly, daily, or weekly variability in usage. You can find more information on the [Auto Scaling documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html). 

1. Open **asg.json** on the Cloud9 editor and review the configuration. Pay special attention at the **Overrides** and the **InstancesDistribution**. Take a look at our [docs](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies) to review how InstancesDistribution and allocation strategies work.

2. The **Overrides** configuration block provides EC2 Auto Scaling a choice of instance types your workload can run on. As Spot instances are **spare** EC2 capacity, your workloads should be flexible to run on multiple instance types and availability zones; hence leveraging multiple *spot capacity pools* and making the most out of the available spare capacity. 

3. You will see in the Overrides block that instead of choosing and specifying instance types, we are specifying [instance requirements](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_InstanceRequirements.html) as a set of instance attributes. This feature is called **Attribute based Instance Type Selection** that lets you express your instance requirements, as a set of attributes including vCPUs, memory, memory per vCPU, processor architecture, instance generation, GPU count and more. Instance requirements are automatically translated to all matching instance types, whenever EC2 Auto Scaling launches instances. This also allows Auto Scaling groups to automatically use newer generation instance types, as and when they are released and eliminates need to update list of instance types.

{{% notice info %}}
To learn more about Attribute based Instance Type Selection, please take a look at the [docs](https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-instance-type-requirements.html) and this [blog](https://aws.amazon.com/blogs/aws/new-attribute-based-instance-type-selection-for-ec2-auto-scaling-and-ec2-fleet/).
{{% /notice %}}

For the purpose of this workshop, let's assume that your workload is flexible to run on any of the instance types matching below attributes:
 * Instances with 2 vCPUs
 * Instances with minimum 4 GiB and maximum 16 GiB memory  
 * Instances with CPU Architecture of Intel and AMD and no GPU Instances  
 * Instances that belong to current generation  
 * Exclude enhanced instance families (z, i and d) that are priced higher than R family
Let's see how above criteria is configured in the *InstanceRequirements* block of the *Overrides* configuration in *asg.json*.
```
"InstanceRequirements": {
            "VCpuCount": {
              "Min": 2,
              "Max": 2
            },
            "MemoryMiB": {
              "Min": 4096,
              "Max": 16384
            },
            "CpuManufacturers": [
              "intel",
              "amd"
            ],
            "InstanceGenerations": [
              "current"
            ],
            "AcceleratorCount": {
              "Max": 0
            },
            "ExcludedInstanceTypes": [
              "d*",
              "i*",
              "z*"
            ]
          }
 
```
Then, the *InstancesDistribution* configuration block determines how EC2 Auto Scaling picks the instance types to use, while at the same time it keeps a balanced number of EC2 instances per Availability Zone.

* **OnDemandAllocationStrategy** is **lowest-price**, which makes Auto Scaling try to launch on-demand instances from the lowest priced instance pools. You must use *lowest-price* as your on-demand allocation strategy with *Attribute based Instance Type Selection* feature. To use the **prioritized** allocation strategy, you must continue to manually add and prioritize your instance types in the Overrides list. This may be required if you have [Reserved Instances](https://aws.amazon.com/ec2/pricing/reserved-instances/) or [Savings Plans](https://aws.amazon.com/savingsplans/) for your baseline capacity, so that Auto Scaling launches the instance type matching your reservations.   
* **OnDemandBaseCapacity** is set to 2, meaning the first two EC2 instances launched by EC2 AutoScaling will be on-demand.
* **OnDemandPercentageAboveBaseCapacity** is set to 0 so all the additional instances will be launched as Spot Instances
* **SpotAllocationStrategy** is **capacity-optimized**, which instructs Auto Scaling to pick the optimal instance type on each Availability Zone based on launch time availability of spare capacity for your instance type selection. With *Attribute based Instance Type Selection*, your Spot allocation strategy must be either *capacity-optimized* or *lowest-price*.

{{% notice note %}}
In case, you have preference for certain instance types, you can use the *capacity-optimized-prioritized* allocation strategy. However, Attribute based Instance Type Selection does not support this strategy. You must manually add your instance types in the order of priority.
{{% /notice %}}


You will also notice that the **CapacityRebalance** parameter is set to true, which will proactively attempt to replace Spot Instances at elevated risk of interruption. To learn more about the Capacity Relabancing feature, take a look at the [docs](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html).

4. You will notice there are placeholder values for **`%TargetGroupArn%`**, **`%publicSubnet1%`** and **`%publicSubnet2%`**. To update the configuration file with the values of the Target Group you created previously and the outputs from the CloudFormation template, execute the following command:
```
sed -i.bak -e "s#%TargetGroupARN%#$TargetGroupArn#g" -e "s#%publicSubnet1%#$publicSubnet1#g" -e "s#%publicSubnet2%#$publicSubnet2#g" asg.json
```

5. Save the file and create the auto scaling group:
```
aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
```
{{% notice note %}}
This command will not return any output if it is successful.
{{% /notice %}}

	
6. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created auto scaling group. Take a look at the instances it has deployed.

# Optional exercise

Now that you have deployed an EC2 Auto Scaling group with Mixed Instance Types and Purchase options, take some time to go through the different configurations in the [console](https://console.aws.amazon.com/ec2autoscaling/home?#/). Click on the **myEC2Workshop** Auto Scaling group and go to the *Instance type requirements* section and click *Edit* button and scroll down to *Preview matching instance types*. Expand to see list of instance types based on your selected instance attributes. Try to edit the instance requirements configured on the Auto Scaling group and see how this preview list changes.