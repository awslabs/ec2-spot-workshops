---
title: "Tracking Spot interruptions"
weight: 96
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



Now we're in the process of getting started with adopting Spot Instances for our EMR clusters. We're still not sure that our jobs are fully resilient and what would actually happen if some of the EC2 Spot Instances in our EMR clusters get interrupted, when EC2 needs the capacity back for On-Demand.

{{% notice note %}}
In most cases, when running fault-tolerant workloads, we don't really need to track the Spot interruptions as our applications should be built to handle them gracefully without any impact to performance or availability. However, when we get started with running our EMR jobs on Spot Instances this could be useful, as our organization can use these to correlate to possible EMR job failures or prolonged execution times, in case Spot Instances were interrupted during Spark run time.
{{% /notice %}}

Let's set up CloudWatch Logs to log Spot interruptions, so if there are any failures in our EMR applications, we'll be able to check if the failures correlate to a Spot interruption.

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
