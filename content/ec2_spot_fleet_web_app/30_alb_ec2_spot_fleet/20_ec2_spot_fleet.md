+++
title = "Launch EC2 Spot Fleet"
chapter = false
weight = 10
+++

### Launch an EC2 Spot Fleet and associate the Load Balancing Target Group with it

In this section, we'll launch an EC2 Spot Fleet and have the Spot Instances automatically associate themselves with the load balancer we created in the previous step.

1\. Head to **Spot Requests** in the EC2 console navigation pane.

2\. Click on **Request Spot Instances**.

3\. Select **Request and Maintain** under **Request type**. This requests a fleet of Spot instances to maintain your target capacity.
 
4\. Under **Amount**, set the **Total target capacity** = *2*, and leave the **Optional On-Demand portion** = *0*.

5\. We'll make a few changes under **Requirements**. First, leave the **AMI** with the default **Amazon Linux AMI**.

6\. Let's add an additional Instance type by clicking **Select**, and then checking both **c3.large** and **c4.large**. This will allow the Spot Fleet to be flexible across both instance types when it is requesting Spot capacity. Click **Select** to save your changes.

7\. For **Network**, make sure to select the same **VPC** you used when creating the Application Load Balancer.

8\. Then check the same **Availability Zones** and **Subnets** you selected when creating the Application Load Balancer.

9\. Check **Replace unhealthy instances** at **Health check**.

10\. Check the **default** Security group.

11\. Select a **Key pair** name if you'd like to enable ssh access to your instances *(not required for this workshop)*.

12\. In the **User data** field, enter the following data as text:

```bash
#!/bin/bash
yum -y update
yum -y install httpd
chkconfig httpd on
instanceid=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo "hello from $instanceid" > /var/www/html/index.html
service httpd start
```

13\. You'll need to add an **instance tag** that includes the name of the load balancer target group ARN created in the load balancer creation step earlier. Click **add new tag** and set **key** = *loadBalancerTargetGroup*, **value** = *[FULL-TARGET-GROUP-ARN]*

{{% notice info %}}
For this next step, you'll need the full Target group ARN you noted earlier in the previous section **Deploy the Application Load Balancer**, point 16
Example Target group ARN:
`arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/aa/cdbe5f2266d41909`

{{% /notice %}}






14\. Under **Load balancing**, check the **Load balancing** box to receive traffic from one or more load balancers. Select the Target group you created in the earlier step of creating the Application Load Balancer.

15\. Under **Spot request fulfillment**, change **Allocation strategy** to **Diversified**, and leave the rest of the settings as **default** options.

{{% notice note %}}
When you use the Amazon EC2 console to create a Spot Fleet, it creates a role named **aws-ec2-spot-fleet-tagging-role** that grants the Spot Fleet permission to request, launch, terminate, and tag instances on your behalf. This role is selected when you create your Spot Fleet request. 
{{% /notice %}}

16\. Click **Launch**.

Example return:

```
Spot request with id: sfr-d1f3c0cc-db37-45b6-88ec-a8b2d8f1520d successfully created.
```

17\. Take a moment to review the Spot Fleet request in the Spot console. You should see *2* Spot Instance requests being fulfilled. Click around to get a good feel for the Spot console.

18\. Head back to **Target Groups** in the EC2 console navigation pane and select your Target group. Select the **Targets** tab below and note the Spot Instances becoming available in the **Registered targets** and **Availability Zones**.