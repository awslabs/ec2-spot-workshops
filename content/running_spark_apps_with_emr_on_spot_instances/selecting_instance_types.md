---
title: "Selecting instance types"
weight: 50
---

Let's use our newly acquired knowledge around Spark executor sizing in order to select the EC2 Instance Types that will be used in our EMR cluster.\
EMR clusters run Master, Core and Task node types. [Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html) to read more about the different node types.

We determined that in order to maximize usage of R4 instance types, we will submit our Spark application with **"–executor-memory=18GB –executor cores=4"**, 

We can use the [Spot Instance Advisor] (https://aws.amazon.com/ec2/spot/instance-advisor/) page to find the relevant instance types with sufficient number of vCPUs and RAM, and use this opportunity to also select instance types with low interruption rates. \
For example: r5.2xlarge has 8 vCPUs and 64 GB of RAM, so EMR will automatically run 2 executors that will consume 36 GB of RAM and still leave free RAM for the operating system and other processes.\
However, at the time of writing, when looking at the EU (Ireland) region in the Spot Instance advisor, the r5.2xlarge instance type is showing an interruption rate of >20%.\
Instead, we'll focus on instance types with lower interruption rates and suitable vCPU/Memory ratio. As an example, at the time of writing, in the EU (Ireland) region, these could be: r4.xlarge, r4.2xlarge, i3.xlarge, i3.2xlarge, r5d.xlarge

![Spot Instance Advisor](/images/running-emr-spark-apps-on-spot/spotinstanceadvisor1.png)

{{% notice note %}}
Spot Instance interruption rates are dynamic, the above just provides a real world example from a specific time and would probably be different when you are performing this workshop.
{{% /notice %}}

To keep our flexibility in place and be able to provide multiple instance types for our EMR cluster, we need to make sure that our executor size will be under the EMR YARN limitation that we saw in the previous step, 

**Your first task**: Find and take note of 5 instance types in the region where you have created your VPC to run your EMR cluster, which will allow running executors with at least 4 vCPUs and 30+ GB of RAM, and also have low Spot interruption rates (maximum 10-15%).

{{%expand "Click here to see a hint for the task" %}}
Instance types with sufficient Memory and vCPUs for our executor size, as well as suitable for our desired vCPU:Mem ratio, and are also under the default memory EMR limitations:\

**Recommended for the workshop:**\
- r4.xlarge and larger\
- r5.xlarge and larger\
- r5a.xlarge and larger\
- r5d.xlarge and larger\
- i3.xlarge and larger\

**Previous generation instance types:**\
- r3.xlarge and larger\
- i2.xlarge and larger\
you will notice that these instance types have double the vCores as they do vCPU, as reflected in the EMR instance selection window - this is an EMR optimization method. Feel free to use these as well, but note that the executor calculations that we're referring to in the workshop will differ. Also, these previous generation instance types will perform slower and the application will take more time to complete.\
Also note that not all instance types exist in all regions.
{{% /expand%}}

