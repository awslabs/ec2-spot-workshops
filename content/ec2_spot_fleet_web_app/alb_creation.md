+++
title = "Deploy the Application Load Balancer"
chapter = false
weight = 30
+++

### Deploy the Application Load Balancer

To deploy your Application Load Balancer and Spot Fleet in your AWS account, you will begin by signing in to the AWS Management Console with your user name and password. 

1\. Go to the EC2 console by choosing **EC2** under **Compute**.

2\. Next, choose **Load Balancers** in the navigation pane. This page shows a list of load balancer types to choose from.

3\. Click **Create Load Balancer** at the top, and then choose **Create** in the **Application Load Balancer** box. 

4\. Give your load balancer a **Name**.

5\. You can leave the rest of the **Basic Configuration** and **Listeners** options as **default** for the purposes of this workshop.

6\. Under **Availability Zones**, you'll need to select the **VPC** created by the CloudFormation stack you launched in the previous step, and then select both **Availability Zones** for the Application Load Balancer to route traffic to. Best practices for both load balancing and Spot Fleet are to select at least two Availability Zones - ideally you should select as many as possible. Remember that you can specify only one subnet per Availability Zone.

7\. Once done, click on **Next: Configure Security Settings**.

{{% notice warning %}}
Since this is a demonstration, we will continue without configuring a secure listener. However, if this was a production load balancer, it is recommended to configure a secure listener if your traffic to the load balancer needs to be secure.
{{% /notice %}}


8\. Go ahead and click on **Next: Configure Security Groups**. Choose **Select an existing security group**, then select both the **default** security group, and the security group created in the CloudFormation stack.

9\. Click on **Next: Configure Routing**.

10\. In the **Configure Routing section**, we'll configure a **Target group**. Your load balancer routes requests to the targets in this target group using the protocol and port that you specify, and performs health checks on the targets using these health check settings. Give your Target group a **Name**, and leave the rest of the options as **defaults** under **Target group**, **Health checks**, and **Advanced health check settings**.

11\. Click on **Next: Register Targets**. On the **Register Targets** section, we don't need to register any targets or instances at this point because we will do this when we configure the EC2 Spot Fleet.

12\. Click on **Next: Review**.

13\. Here you can review your settings. Once you are done reviewing, click **Create**.

14\. You should get a return that your Application Load Balancer was successfully created.

15\. Click **Close**.

16\. You'll need to make a note of the ARN of the Target group you created, as you'll be using it a few times in the following steps. Back on the EC2 console, choose **Target Groups** in the navigation pane. This page shows a list of Target groups to choose from. Select the Target group you just created, and copy/paste the full ARN of the Target group listed below in the **Basic Configuration** of the **Description** tab somewhere for easy access in the later steps (or simply know where to refer back when you need it).

>Example Target group ARN:

`arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/aa/cdbe5f2266d41909`
