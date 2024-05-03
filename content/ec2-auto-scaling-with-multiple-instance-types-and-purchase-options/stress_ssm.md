+++
title = "Stress the app with AWS Systems Manager"
weight = 150
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Amazon EC2 Auto Scaling Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/0a0fe16c-8693-4d23-8679-4f1701dbd2b0/en-US)**.

{{% /notice %}}


AWS Systems Manager provides you safe, secure remote management of your instances at scale without logging into your servers, replacing the need for bastion hosts, SSH, or remote PowerShell. It provides a simple way of automating common administrative tasks across groups of instances such as registry edits, user management, and software and patch installations. Through integration with AWS Identity and Access Management (IAM), you can apply granular permissions to control the actions users can perform on instances. All actions taken with Systems Manager are recorded by AWS CloudTrail, allowing you to audit changes throughout your environment.

You will now emulate CPU stress on the instances in your automatic scaling group by issuing a remote command to each instance.

1. Review **ssm-stress.json** to understand the options. There are no changes to be made. Then go ahead and send the command:

	```
	aws ssm send-command --cli-input-json file://ssm-stress.json
	```   

1. Browse to the [AWS Systems Manager console](https://console.aws.amazon.com/systems-manager/run-command/executing-commands) to monitor the status of your run  commands.

1. Browse to the [CloudWatch console](https://console.aws.amazon.com/cloudwatch/home?#alarm:alarmFilter=ANY) to monitor the status of your alarms configured by the target tracking policy.

1. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and watch the activity history. Notice that in a few minutes, it will begin to scale up the instances according to the CloudWatch alarms the target tracking policy has configured for you (check the **Activity History** tab and the **Instances** tab).
{{% notice info %}}
If your account is new, or if you are using an account that was created for you within an AWS-led event, then your EC2 Auto Scaling group might be unable to scale out to the desired instance count due to hitting EC2 Spot instance count limits. The functionality of this step in the workshop still works despite launching a smaller number of instances, so you can simply ignore these errors.
{{% /notice %}}