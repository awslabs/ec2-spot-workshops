---
title: "Selecting instance types"
weight: 50
---

Let's use our newly acquired knowledge around Spark executor sizing in order to select the EC2 Instance Types that will be used in our EMR cluster.\
EMR clusters run Master, Core and Task node types. [Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html) to read more about the different node types.

We determined that in order to be flexible and allow running on multiple instance types across R instance family, we will submit our Spark application with **"–executor-memory=18GB –executor-cores=4"**.

To apply the instance diversification best practices while meeting the application constraints defined in the previous section, we can add different instances sizes from the latest generation, such as r5.xlarge, r5.2xlarge and r5.4xlarge. We can also add instances from previous generations such as r4.xlarge, r4.2xlarge and r4.4xlarge. There are even variants, such as R5d instance types (local NVMe-based SSDs) and R5a instance types (powered by AMD processors) that can be included.

{{% notice info %}}
There are over 275 different instance types available on EC2 which can make the process of selecting appropriate instance types difficult. **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** helps you select compatible instance types for your application to run on. The command line interface can be passed resource criteria like vCPUs, memory, network performance, and much more and then return the available, matching instance types.
{{% /notice %}}

We will use **amazon-ec2-instance-selector** to help us select the relevant instance
types and families with sufficient number of vCPUs and RAM.

Let's first install **amazon-ec2-instance-selector** on Cloud9 IDE:

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v1.3.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run
`ec2-instance-selector --help` to understand how you could use it for selecting
instances that match your workload requirements. For the purpose of this workshop
we need to first get a group of instances with sizes between 4vCPU to 16vCPUs and belong to current generation of R Family (vCPU to Memory ratio of 1:8).

Run the following command to get the list of instances.

```bash
ec2-instance-selector --vcpus-min 4  --vcpus-max 16  --vcpus-to-memory-ratio 1:8 --cpu-architecture x86_64 --current-generation --gpus 0 --deny-list '.*[n].*|.*[b].*|^[diz].*'
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
r5ad.2xlarge
r5ad.4xlarge
r5ad.xlarge
r5d.2xlarge
r5d.4xlarge
r5d.xlarge         
```

Internally ec2-instance-selector is making calls to the [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) for the specific region and filtering
the instances based on the criteria selected in the command line, in our case 
we did filter for instances that meet the following criteria:\
 * Instances that have minimum 4 vCPUs and maximum 16 vCPUs\
 * Instances of R family with vCPU to Memory ratio of 1:8\
 * Filtering out GPU type instances\
 * Instances that don't meet the regular expression `.*[n].*|.*[b].*|^[zid].*`. Effectively lesser popular R5N and R5B variants and  higher priced Z, I and D Instance families. 

{{% notice note %}}
You are encouraged to test what are the options that `ec2-instance-selector` provides and run a few commands with it to familiarize yourself with the tool.
For example, try running the same commands as you did before with the extra parameter **`--output table-wide`**.
{{% /notice %}}