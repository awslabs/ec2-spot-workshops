---
title: "... At an AWS event"
date: 2021-09-06T08:51:33Z
weight: 25
---

If you are at an AWS event, an AWS account was created for you to use throughout the workshop. You will need the **Participant Hash** provided to you by the event's organizers.

1. Connect to the portal by browsing to [https://dashboard.eventengine.run/](https://dashboard.eventengine.run/).
2. Enter the Hash in the text box, and click **Proceed**
3. In the User Dashboard screen, click **AWS Console**
4. In the popup page, click **Open Console**

You are now logged in to the AWS console in an account that was created for you, and will be available only throughout the workshop run time. A CloudFormation stack has been automatically deployed for you with the following resources:

- A VPC
- An S3 bucket
- An ECR repository
- A Launch Template
- An instance profile for AWS Batch compute environment
- The Cloud9 environment where you will run all the commands



{{% insert-md-from-file file="rendering-with-batch/start/review-outputs.partial" %}}
