---
title: "event"
chapter: false
disableToc: true
hidden: true
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Cost efficient Spark applications on Amazon EMR](https://catalog.us-east-1.prod.workshops.aws/workshops/aaa003a7-9c9e-46ad-af28-477b0d906f47/en-US)**.
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