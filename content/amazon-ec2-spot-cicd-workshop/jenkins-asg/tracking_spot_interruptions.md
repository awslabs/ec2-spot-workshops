---
title: "Tracking Spot interruptions"
weight: 140
---
At some point in time, you might receive a Spot interruption notice when On-Demand needs the capacity back. When this happens, your Spot instance will be provided with a two-minute notice of termination and after that time lapses, the instance will be terminated. At this point, the Auto Scaling group will observe that there are no running instances in the group and because the desired capacity is one. Then, it will launch a replacement instance from the pool with more capacity available (this is why diversification across many capacity pool is a best practice). The new instance will be launched and bootstrapped in exactly the same manner as your original instance.

Before we start testing the resiliency of Jenkins with Spot, let's configure CloudWatch Logs to log Spot interruptions. If a Jenkins job fails, we'll be able to check if the failure correlates to a Spot interruption or not.

{{% notice note %}}
In most cases we don't really need to track the Spot interruptions as Jenkins jobs can be retried if it fails. However, when we're starting with running our Jenkins jobs on Spot instances tracking could be useful. Organizations can use this data to correlate possible job failures or prolonged execution times, in case Spot instances were interrupted during a job execution.
{{% /notice %}}

#### Creating the CloudFormation Stack to Track EC2 Spot Interruptions

We've created a CloudFormation template that includes all the resources you need to track EC2 Spot Interruptions. The stack creates the following:

* An Event Rule for tracking EC2 Spot Interruption Warnings
* A CloudWatch Log group to log interruptions and instance details
* IAM Role to allow the event rule to log into CloudWatch Logs

You can view the CloudFormation template (**cloudwatchlogs.yaml**) at GitHub [here](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/track-spot-interruptions/cloudwatchlogs.yaml). To download it, you can run the following command:

```
wget https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/track-spot-interruptions/cloudwatchlogs.yaml
```

After downloading the CloudFormation template, run the following command in a terminal:

```
aws cloudformation create-stack --stack-name track-spot-interruption --template-body file://cloudwatchlogs.yaml --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name track-spot-interruption
```

You should see an event rule in the Amazon EventBridge console, like this:

![Spot Interruption Event Rule](/images/tracking-spot/itn-event-rule.png)
