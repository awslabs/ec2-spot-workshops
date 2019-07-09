+++
title = "Launch EC2 Spot Fleet"
chapter = false
weight = 40
+++

### Launch an EC2 Spot Fleet and associate the Load Balancing Target Group with it

In this section, we'll launch an EC2 Spot Fleet and have the Spot Instances automatically associate themselves with the load balancer we created in the previous step.

1\. Head to **Spot Requests** in the EC2 console navigation pane.

2\. Click on **Request Spot Instances**.

3\. Leave the default selection **Load balancing workloads** under **Tell us your application or task need**. 

4\. Under the **Configure your instances** section, leave the **default** values for **AMI** (Amazon Linux 2 AMI (HVM)) and **Minimum compute unit** (c3.large). The console will use this value to generate a diverse recommendation of instance types matching the minimum compute unit as we will see later on. 

5\. Under the **Network** section, select the **VPC** that has been created by the Cloudformation template, named **EC2 Spot Fleet web app workshop**. Then, under the **Availability Zone** section, select the same Availability Zones and **Subnets** you selected when creating the Application Load Balancer.

6\. Select a **Key pair** name if you'd like to enable ssh access to your instances *(not required for this workshop)*.

7\. Click on the **Additional configurations** section to expand it. Under **Security groups** check the **default** security group. 

9\. On the **User data** field, enter the following data as text:

```bash
#!/bin/bash
yum -y update
yum -y install httpd
chkconfig httpd on
instanceid=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo "hello from $instanceid" > /var/www/html/index.html
service httpd start
```


9\. You'll need to add an **Instance tag** that includes the name of the load balancer target group ARN created in the load balancer creation step earlier. Click **Add new tag** and set **Key** = *loadBalancerTargetGroup*, **Value** = *[FULL-TARGET-GROUP-ARN]*

{{% notice info %}}
For this next step, you'll need the full Target group ARN you noted earlier in the previous section **Deploy the Application Load Balancer**, point 16
Example Target group ARN:
`arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/aa/cdbe5f2266d41909`

{{% /notice %}}




10\. Under **Tell us how much capacity you need** section, set the **Total target capacity** = *2*, and then leave the **Optional On-demand portion** = *0*. Also, click on the **Mantain target capacity** checkbox and leave the default **Interruption behavior** to **Terminate**.

11.\ You will find a default set of recommended capacity pools under **Fleet request settings**. Uncheck the **Apply recommendations** checkbox on the right side to customize the capacity pools. Feel free to add additional instance types by clicking **Select instance types**. 

{{% notice note %}}
The default instance type selection will include **t2.medium**, **t3.medium**, **t2.large** and **t3.large** which are a great fit for this workshop as we will not be bursting over the baseline level of CPU provided by t2 and t3 instances. In a **production** scenario, if your application is going to be consistently **bursting over baseline CPU performance**, consider replacing t2 and t3 instances to **fixed performance instance types**. You can find more details about burstable performance instances [**here**](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-credits-baseline-concepts.html) as well as Spot instance considerations for t2 and t3 instances [**here**](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-limits.html#t3-spot-instances)
{{% /notice %}}

12.\ On the **Fleet allocation strategy** leave the default **Diversified across x instance pools in my fleet (recommended)**. This will launch a diversified set of instances, which helps avoiding widespread concurrent interruptions. 

13.\ On the **Additional request details** section, uncheck the **Apply defaults** checkbox on the right side to configure the instances to register with the Application Load Balancer we created earlier.

{{% notice note %}}
When you use the Amazon EC2 console to create a Spot Fleet, it creates a role named **aws-ec2-spot-fleet-tagging-role** that grants the Spot Fleet permission to request, launch, terminate, and tag instances on your behalf. This role is selected when you create your Spot Fleet request. 
{{% /notice %}}

14.\ Leave all the default values, until the **Load Balancing** section. Check the **Receive traffic from one or more load balancers**. On the **Target Groups** dropdown, select the target group you created before. 

15.\ At this stage, at the bottom of the page, you will see the **Your fleet request at a glance** section, which summarizes your spot capacity request, the strength of the fleet and the estimated price and savings compared to on-demand. Optionally, click on the **JSON config** button to download a JSON file with your fleet configuration and take a look at it, you could use this to launch the Spot fleet you configured using the AWS CLI. 

16\. Click **Launch**.

Example return:

```
Spot request with id: sfr-d1f3c0cc-db37-45b6-88ec-a8b2d8f1520d successfully created.
```

17\. Take a moment to review the Spot Fleet request in the Spot console. You should see *2* Spot Instance requests being fulfilled. Click around to get a good feel for the Spot console.

18\. Head back to **Target Groups** in the EC2 console navigation pane and select your Target group. Select the **Targets** tab below and note the Spot Instances becoming available in the **Registered targets** and **Availability Zones**.