---
title: "Selecting instance types"
weight: 50
---

Let's use our newly acquired knowledge around Spark executor sizing in order to select the EC2 Instance Types that will be used in our EMR cluster. We determined that in order to be flexible and allow running on multiple instance types, we will submit our Spark application with **"–executor-memory=18GB –executor-cores=4"**.

To apply the instance diversification best practices while meeting the application constraints defined in the previous section, we can add different instances sizes from the current generation, such as R5 and R4. We can even include variants, such as R5d instance types (local NVMe-based SSDs) and R5a instance types (powered by AMD processors).

{{% notice info %}}
There are over 275 different instance types available on EC2 which can make the process of selecting appropriate instance types difficult. **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** helps you select compatible instance types for your application to run on. The command line interface can be passed resource criteria like vCPUs, memory, network performance, and much more and then return the available, matching instance types.
{{% /notice %}}

We will use **amazon-ec2-instance-selector** to help us select the relevant instance
types with sufficient number of vCPUs and RAM.

Let's first install amazon-ec2-instance-selector on Cloud9 IDE:

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v1.3.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run
`ec2-instance-selector --help`, to understand how you could use it for selecting
instances that match your workload requirements.

For the purpose of this workshop we will select instances based on below criteria:  
 * Instances that have minimum 4 vCPUs and maximum 16 vCPUs  
 * Instances which have vCPU to Memory ratio of 1:8, same as R Instance family  
 * Instances with CPU Architecture x86_64 and no GPU Instances  
 * Instances that belong to current generation  
 * Instances types that are not supported by EMR such as R5N, R5ad and R5b. Enhanced z, I and D Instance families, which are priced higher than R family. So basically, adding a deny list with the regular expression `.*n.*|.*ad.*|.*b.*|^[zid].*`.

{{% notice info %}}
[Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-supported-instance-types.html) to find out the instance types that Amazon EMR supports .
{{% /notice %}}

Run the following command with above mentioned criteria, to get the list of instances.

```bash
ec2-instance-selector --vcpus-min 4  --vcpus-max 16  --vcpus-to-memory-ratio 1:8 --cpu-architecture x86_64 --current-generation --gpus 0 --deny-list '.*n.*|.*ad.*|.*b.*|^[zid].*'
```

Internally ec2-instance-selector is making calls to the [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) for the specific region and filtering
the instances based on the criteria selected in the command line. Above command should display a list like the one that follows (note results might differ depending on the region). We will use this instances as part of our EMR Core and Task Instance Fleets.

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

{{% notice note %}}
You are encouraged to test what are the options that `ec2-instance-selector` provides and run a few commands with it to familiarize yourself with the tool.
For example, try running the same commands as you did before with the extra parameter **`--output table-wide`**.
{{% /notice %}}