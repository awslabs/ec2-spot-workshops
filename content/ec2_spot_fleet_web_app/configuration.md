+++
title = "Spot Fleet Configuration"
chapter = false
weight = 50
+++


### Configure Automatic Scaling for the Spot Fleet

In this section, we'll configure automatic scaling for the Spot Fleet so it can scale based on the Application Load Balancer Request Count Per Target.

1\. Head back to **Spot Requests** in the EC2 console navigation pane.

2\. Select the **Spot Fleet Request Id** that you just launched.

3\. In the **lower section details** click on the **Auto Scaling** tab. Click the **Configure** button.

4\. You can now select details for how your Spot Fleet will scale. Set the **Scale capacity** between *2* and *10* instances.

{{% notice note %}}
When using the AWS Management Console to enable automatic scaling for your Spot Fleet, it creates a role named aws-ec2-spot-fleet-autoscale-role that grants Amazon EC2 Auto Scaling permission to describe the alarms for your policies, monitor the current capacity of the fleet, and modify the capacity of the fleet. 
{{% /notice %}}

5\. In **Scaling policies**, change the **Target metric** to *Application Load Balancer Request Count Per Target*.

6\. This will show a new field **ALB target group**. Select the **Target Group** created in the earlier step.

7\. Leave the rest of the settings as **default**.

8\. Click **Save**.

You have now attached a target based automatic scaling policy to your Spot Fleet to allow it to scale for peak demand. You can check out the associated CloudWatch alarms in the [CloudWatch console](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#).
