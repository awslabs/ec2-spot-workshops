---
title: "Selecting instance types"
weight: 50
---

Let's use our newly acquired knowledge around Spark executor sizing in order to select the EC2 Instance Types that will be used in our EMR cluster.\
EMR clusters run Master, Core and Task node types. [Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html) to read more about the different node types.

We determined that in order to be flexible and allow running on multiple instance types across R instance family, we will submit our Spark application with **"–executor-memory=18GB –executor-cores=4"**.

We will use **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** to help us select the relevant instance
types and familes with sufficient number of vCPUs and RAM. 
For example: We will indentiy R family instances, so EMR can run executors that will consume 4 vCPUs and 18 GB of RAM and still leave free RAM for the operating system and other processes. We can select different-sized instance types such as r5.xlarge and r5.2xlarge. Second, add previous generation r4.xlarge and other R4 instance sizes. After we have added different sizes within the same family, as well as previous generation instance types, we can add extra instance types with similar hardware characteristics and vCPU to memory ratio, such as the r5a instance family with AMD processors, r5d instance family with locally attached NVMe storage, and more.

There are over 270 different instance types available on EC2 which can make the process of selecting appropriate instance types difficult. **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** helps you select compatible instance types for your application to run on. The command line interface can be passed resource criteria like vcpus, memory, network performance, and much more and then return the available, matching instance types.

Let's first install **amazon-ec2-instance-selector** on Cloud9 IDE:

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v1.3.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run
`ec2-instance-selector --help` to understand how you could use it for selecting
instances that match your workload requirements. For the purpose of this workshop
we need to first get a group of instances with sizes between 4vCPU to 16vCPUs and belong to current generation R family.
Run the following command to get the list of instances.

```bash
ec2-instance-selector --vcpus-min 4  --vcpus-max 16  --allow-list '.*r5.*|.*r4.*|.*r5a.*|.*r5d.*'  --deny-list '.*n.*|.*ad.*|.*b.*'  
```

This should display a list like the one that follows (note results might differ depending on the region). We will use this instances as part of our EMR Core and Task Instance Fleets.

```
r4.2xlarge
r4.4xlarge
r4.xlarge
r5.2xlarge
r5.4xlarge
r5.xlarge
r5a.2xlarge
r5a.4xlarge
r5a.xlarge
r5d.2xlarge
r5d.4xlarge
r5d.xlarge          
```

Internally ec2-instance-selector is making calls to the [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) for the specific region and filtering
the intstances based on the criteria selected in the command line, in our case 
we did filter for instances that meet the following criteria:\
 * Instances that have minimum 4 vCPUs and maximum 16 vCPUs\
 * Instances of R5, R5A, R5D and R4 generation (4th gen onwards)\
 * Instances that don't meet the regular expresion `.*n.*|.*ad.*|.*b.*` so effectively r5n, r5dn, r5ad and r5b.


{{% notice note %}}
You are encouraged to test what are the options that `ec2-instance-selector` provides and run a few commands with it to familiarize yourself with the tool.
For example, try running the same commands as you did before with the extra parameter **`--output table-wide`**.
{{% /notice %}}

### Challenge 

Find out another group that adheres to a 1vCPU:8GB ratio but this time across all instance families with same deny list.

{{%expand "Expand this for an example on the list of instances" %}}

That should be easy. You can run the command:  

```bash
ec2-instance-selector --vcpus-to-memory-ratio 1:8 --vcpus-min 4  --vcpus-max 32 --gpus 0 --current-generation -a x86_64 --deny-list '.*n.*|.*ad.*|.*b.*'
```

which should yield a list as follows 

```
d2.2xlarge
d2.4xlarge
d2.xlarge
i3.2xlarge
i3.4xlarge
i3.8xlarge
i3.xlarge
r4.2xlarge
r4.4xlarge
r4.8xlarge
r4.xlarge
r5.2xlarge
r5.4xlarge
r5.8xlarge
r5.xlarge
r5a.2xlarge
r5a.4xlarge
r5a.8xlarge
r5a.xlarge
r5d.2xlarge
```
{{% /expand %}}
