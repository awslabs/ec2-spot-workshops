---
title: "Tracking Spot interruptions"
weight: 100
---

Now we're in the process of getting started with adopting Spot Instances for our EMR clusters. We're still not sure that our jobs are fully resilient and what would actually happen if some of the EC2 Spot Instances in our EMR clusters get interrupted, when EC2 needs the capacity back for On-Demand.

{{% notice note %}}
In most cases, when running fault-tolerant workloads, we don't really need to track the Spot interruptions as our applications should be built to handle them gracefully without any impact to performance or availability. However, when we get started with running our EMR jobs on Spot Instances this could be useful, as our organization can use these to correlate to possible EMR job failures or prolonged execution times, in case Spot Instances were interrupted during Spark run time.
{{% /notice %}}


Let's set up an email notification for when Spot interruptions occur, so if there are any failures in our EMR applications, we'll be able to check if the failures correlate to a Spot interruption.

#### Creating an SNS topic for the notifications
1. Create a new SNS topic and subscribe to the topic with your email address  
For guidance, you can follow steps #1 & #2 in the [Amazon SNS getting started guide] (https://docs.aws.amazon.com/sns/latest/dg/sns-getting-started.html)
1. You will receive an email with the subject "AWS Notification - Subscription Confirmation". Click the "**Confirm subscription**" link in the email in order to allow SNS to send email to the endpoint (your email).

#### Creating a CloudWatch Events rule for the Spot Interruption notifications

1. You now have an SNS topic that CloudWatch Events can send the EC2 Spot Interruption Notification to, let's configure CloudWatch to do so. In the AWS Management Console, go to Cloudwatch -> Events -> Rules and click **Create Rule**.

1. Under **Service Name** select EC2 and under Event Type select **EC2 Spot Instance Interruption Warning**

1. On the right side of the console, click **Add Target**, scroll down and select **SNS topic** -> select your topic name, Your result should look like this: 
![tags](/images/running-emr-spark-apps-on-spot/cloudwatcheventsrule.png)
1. Click **Configure Details** in the  bottom right corner.
1. Provide a name to your CloudWatch Events rule and click **Create rule**.

#### Verifying that the notification works

The only way to simulate a Spot Interruption Notification is to use Spot Fleet. Spot Fleet is an EC2 instance provisioning and management tool that is not used in this workshop for any of the actual EMR/Spark work (not to be confused with EMR Instance Fleets). We will only use Spot Fleet to trigger a Spot Interruption that will help you verify that the notification that you set up works.

1. In the AWS console, go to EC2 -> Spot Requests -> click **Request Spot Instances**
1. Leave all the settings as-is and check the box next to "**Maintain target capacity**", then at the bottom click **Launch**. This will create a Spot Fleet with one instance and you will get a Success window.
1. Still in the Spot console, click the console refresh button until your fleet has started the one instance (when capacity changes to **1 of 1**). 
1. With your fleet checked, click Actions -> **Modify target capacity** -> Change "**New target capacity**" to 0, leave Terminate instances checked -> Click **Submit**
1. Within a minute or two you should receive an SNS notification from the topic you created, with a JSON event that indicates that the Spot Instance in the fleet was interrupted.

```json
{"version":"0","id":"6009a9f4-cc7a-8a77-46f2-310520b31e0f","detail-type":"EC2 Spot Instance Interruption Warning","source":"aws.ec2","account":"<account-id>","time":"2019-05-27T04:52:57Z","region":"eu-west-1","resources":["arn:aws:ec2:eu-west-1b:instance/i-0481ef86f172b68d7"],"detail":{"instance-id":"i-0481ef86f172b68d7","instance-action":"terminate"}}
```

Go ahead and terminate the fleet request itself by checking the fleet, click actions -> **Cancel Spot request** -> **Confirm**.

From now on, any EC2 Spot interruption in the account/region that you set this up in will alert you via email. Disable or delete the CloudWatch Event rule if you are not interested in the notifications.
