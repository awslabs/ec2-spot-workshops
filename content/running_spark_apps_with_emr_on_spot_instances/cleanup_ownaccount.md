---
title: "event"
chapter: false
disableToc: true
hidden: true
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



1. Delete the CloudFormation stack for the Cloud9, S3 Buckets, and Athena table you created. Run the following command:
```
aws cloudformation delete-stack --stack-name emrspot-workshop
```
1. Delete the CloudFormation stack for the FIS experiment templates. Run the following command:
```
aws cloudformation delete-stack --stack-name fis-spot-interruption
```
1. Delete the CloudFormation stack for tracking the Spot interruptions. Run the following command:
```
aws cloudformation delete-stack --stack-name track-spot-interruption
```