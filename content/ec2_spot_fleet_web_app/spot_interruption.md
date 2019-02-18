+++
title = "Spot Instance interruption"
chapter = false
weight = 70
+++

### Enable the Spot Instance interruption notice handler Lambda function

Now let's take advantage of the two-minute Spot Instance interruption notice by tuning the Elastic Load Balancing target group deregistration timeout delay to match. When a target is deregistered from the target group, it is put into connection draining mode for the length of the timeout delay:  120 seconds to equal the two-minute notice.

1\. Click on **Target Groups** in the EC2 console navigation pane.

2\. Select your **Target group**.

3\. In the **Description** tab below, scroll down to **Attributes** and click on **Edit attributes**.

4\. Change the **Deregistration delay** to *120 seconds*. Click **Save**.

To capture the Spot Instance interruption notice being published to CloudWatch Events, we'll use a rule with two targets that was created in the CloudFormation stack. The two targets are a Lambda function and an SNS topic.

5\. Go to the [Lambda console](https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions) by choosing **Lambda** under **Compute** in the AWS Management Console.

6\. Find the name of the Lambda function created in the CloudFormation stack and select it.

7\. Scroll down to the **Function code** where you can edit the code inline. Replace the existing code for **index.py** with the following:

```python
import boto3
def handler(event, context):
  instanceId = event['detail']['instance-id']
  instanceAction = event['detail']['instance-action']
  try:
    ec2client = boto3.client('ec2')
    describeTags = ec2client.describe_tags(Filters=[{'Name': 'resource-id','Values':[instanceId]},{'Name':'key','Values':['loadBalancerTargetGroup']}])
  except:
    print("No action being taken. Unable to describe tags for instance id:", instanceId)
    return
  try:
    elbv2client = boto3.client('elbv2')
    deregisterTargets = elbv2client.deregister_targets(TargetGroupArn=describeTags['Tags'][0]['Value'],Targets=[{'Id':instanceId}])
  except:
    print("No action being taken. Unable to deregister targets for instance id:", instanceId)
    return
  print("Detaching instance from target:")
  print(instanceId, describeTags['Tags'][0]['Value'], deregisterTargets, sep=",")
  return
```

8\. Click **Save** in the upper right-hand corner.

The Lambda function does the heavy lifting for you. The details of the CloudWatch event are published to the Lambda function, which then uses [boto3](https://boto3.readthedocs.io/en/latest/) to make a couple of AWS API calls. The first call is to describe the EC2 tags for the Spot Instance, filtering on a key of “TargetGroupArn”. If this tag is found, the instance is then deregistered from the target group ARN stored as the value of the tag.