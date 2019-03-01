+++
title = "Using Scheduled Scaling in ASG"
weight = 130
+++

Scaling based on a schedule allows you to scale your application in response to predictable load changes. For example, every week the traffic to your web application starts to increase on Wednesday, remains high on Thursday, and starts to decrease on Friday. You can plan your scaling activities based on the predictable traffic patterns of your web application.

To configure your Auto Scaling group to scale based on a schedule, you create a scheduled action, which tells Amazon EC2 Auto Scaling to perform a scaling action at specified times. To create a scheduled scaling action, you specify the start time when the scaling action should take effect, and the new minimum, maximum, and desired sizes for the scaling action. At the specified time, Amazon EC2 Auto Scaling updates the group with the values for minimum, maximum, and desired size specified by the scaling action.

1. Edit **asg-scheduled-scaling.json** and replace **%StartTime%** with a UTC timestamp of a few minutes in the future. For example: **2019-02-26T14:00:00**. You can use this [site](https://timestampgenerator.com/) to help. Look for the **Atom** format. Save the file.

1. Schedule the scaling action:

	```
	aws autoscaling put-scheduled-update-group-action --cli-input-json file://asg-scheduled-scaling.json
	```
{{% notice note %}}
This command will not return any output if it is successful.
{{% /notice %}}
1. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created scheduled scaling action in the **Scheduled Actions** tab. Wait for the time you chose, and take a look at the instances it has deployed by checking the **Activity History** tab and the **Instances** tab.