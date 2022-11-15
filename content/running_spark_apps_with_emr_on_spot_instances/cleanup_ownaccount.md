---
title: "event"
chapter: false
disableToc: true
hidden: true
---

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