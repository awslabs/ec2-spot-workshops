---
title: "Selecting instance types"
weight: 50
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



Let's use our newly acquired knowledge around Spark executor sizing in order to select the EC2 instance types that will be used in our EMR cluster. We determined that in order to be flexible and allow running on multiple instance types, we will submit our Spark application with **"–executor-memory=18GB –executor-cores=4"**.

To apply the instance diversification best practices while meeting the application constraints defined in the previous section, we can add different instance sizes from the current generation, such as R5 and R4. We can even include variants, such as R5d instance types (local NVMe-based SSDs) and R5a instance types (powered by AMD processors).

{{% notice info %}}
There are over 500 different instance types available on EC2 which can make the process of selecting appropriate instance types types difficult. **[amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)** helps you select compatible instance types for your application to run on. The command line interface can be passed resource criteria like vCPUs, memory, network performance, and much more and then return the available, matching instance types.
{{% /notice %}}

We will use amazon-ec2-instance-selector to help us select the relevant instance
types with sufficient number of vCPUs and RAM.

Let's first install amazon-ec2-instance-selector on Cloud9 IDE:

```
curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version
```

Now that you have ec2-instance-selector installed, you can run `ec2-instance-selector --help`, to understand how you could use it for selecting instance types that match your workload requirements.

For the purpose of this workshop we will select instance types based on below criteria:

 * Instances that have minimum 4 vCPUs and maximum 16 vCPUs  
 * Instances which have vCPU to Memory ratio of 1:8, same as R instance family  
 * Instances with CPU Architecture x86_64 and no GPU instance types.  
 * Instances that belong to current generation  
 * Exclude instance types that are not supported by EMR by adding --service emr-5.xx.0 flag. Set the correct *Release label* of EMR, it should match the EMR version you will choose later during cluster creation steps. 
 * Exclude enhanced instance types (z, I and D ) that are priced higher than R family. So basically, adding a deny list with a regular expression `^[zid].*`.

{{% notice info %}}
**[Click here](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-supported-instance-types.html)** to find out the instance types that Amazon EMR supports .
{{% /notice %}}

Run the following command with above mentioned criteria, to get the list of instance types. You need to change the EMR release label to match your cluster version.

```bash
ec2-instance-selector --vcpus-min 4  --vcpus-max 16  --vcpus-to-memory-ratio 1:8 --cpu-architecture x86_64 --current-generation --gpus 0 --service emr-5.36.0 --deny-list '^[zid].*'
```

Internally ec2-instance-selector is making calls to the [DescribeInstanceTypes](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstanceTypes.html) for the specific region and filtering
the instance types based on the criteria selected in the command line. Above command should display a list like the one that follows (**note results might differ depending on the region**). We will use below instance types as part of our EMR Core and Task instance fleets.

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
r5b.2xlarge
r5b.4xlarge
r5b.xlarge
r5d.2xlarge
r5d.4xlarge
r5d.xlarge
r5dn.2xlarge
r5dn.4xlarge
r5dn.xlarge     
```

{{% notice note %}}
You are encouraged to test other options that `ec2-instance-selector` provides and run a few commands with it to familiarize yourself with the tool.
For example, try running the same commands as you did before with the extra parameter `--output table-wide`.
{{% /notice %}}
