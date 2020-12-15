---
title: "Selecting instance types"
weight: 50
---

Let's use our newly acquired knowledge around Spark executor sizing in order to select the EC2 Instance Types that will be used in our EMR cluster.\
EMR clusters run Master, Core and Task node types. [Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html) to read more about the different node types.

We determined that in order to be flexible and allow running on multiple instance types across R instance family, we will submit our Spark application with **"–executor-memory=18GB –executor-cores=4"**.

We will use **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** to help us select the relevant instance
types and families with sufficient number of vCPUs and RAM. 
For example: We identified R family instances, so EMR can run executors that will consume 4 vCPUs and 18 GB of RAM and still leave free RAM for the operating system and other processes. First, we can select different-sized instance types from current generation, such as r5.xlarge, r5.2xlarge and r5.4xlarge. Next, we can select different-sized instance types from previous generation, such as r4.xlarge, r4.2xlarge and r4.4xlarge. Last, we can select different-sized instances from R family local storage and processor variants, such as R5d instance types (local NVMe-based SSDs) and R5a instance types (powered by AMD processors).

There are over 275 different instance types available on EC2 which can make the process of selecting appropriate instance types difficult. **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** helps you select compatible instance types for your application to run on. The command line interface can be passed resource criteria like vCPUs, memory, network performance, and much more and then return the available, matching instance types.

Let's first install **amazon-ec2-instance-selector** on Cloud9 IDE:

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v1.3.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run
`ec2-instance-selector --help` to understand how you could use it for selecting
instances that match your workload requirements. For the purpose of this workshop
we need to first get a group of instances with sizes between 4vCPU to 16vCPUs and belong to R5, R4, R5D and R5A instance types.
Run the following command to get the list of instances.

```bash
ec2-instance-selector --vcpus-min 4  --vcpus-max 16  --allow-list '.*r5.*|.*r4.*|.*r5d.*|.*r5a.*'  --deny-list '.*n.*|.*ad.*|.*b.*'  
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
the instances based on the criteria selected in the command line, in our case 
we did filter for instances that meet the following criteria:\
 * Instances that have minimum 4 vCPUs and maximum 16 vCPUs\
 * Instances of R5, R4, R5D and R5A generation\
 * Instances that don't meet the regular expression `.*n.*|.*ad.*|.*b.*`, so effectively r5n, r5dn, r5ad and r5b.


{{% notice note %}}
You are encouraged to test what are the options that `ec2-instance-selector` provides and run a few commands with it to familiarize yourself with the tool.
For example, try running the same commands as you did before with the extra parameter **`--output table-wide`**.
{{% /notice %}}