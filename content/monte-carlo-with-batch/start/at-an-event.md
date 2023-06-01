---
title: "... At an AWS event"
date: 2021-09-06T08:51:33Z
weight: 25
---

If you are at an AWS event, an AWS account was created for you to use throughout the workshop. You will need to follow the instructions given to you by the event's organizers.

An account  was created for you, and will be available only throughout the workshop run time. A CloudFormation stack has been automatically deployed for you with the following resources:

- A VPC
- An S3 bucket
- An ECR repository
- A Launch Template
- An AWS Step Functions state machine
- An instance profile for AWS Batch compute environment
- The Cloud9 environment where you will run all the commands

{{% insert-md-from-file file="monte-carlo-with-batch/start/review-outputs.md" %}}
