---
title: "... On your own"
date: 2021-09-06T08:51:33Z
weight: 27
---

## Deploying the CloudFormation stack

As a first step, **download** a [CloudFormation stack](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/rendering-with-batch/rendering-with-batch.files/stack.yaml) that will deploy for you the following resources:

- A VPC
- An S3 bucket
- An ECR repository
- A Launch Template
- An AWS Step Functions state machine
- An instance profile for AWS Batch compute environment
- The Cloud9 environment where you will run all the commands
- An AWS IAM Role used by AWS Fault Injection Simulator

After downloading the template, open the [CloudFormation console](https://console.aws.amazon.com/cloudformation) and on the top-right corner of the screen, click on **Create stack**. Follow the following steps:

1. In the **Create stack** page, click on **Choose file** and upload the CloudFormation template you just downloaded. Don't change any other configuration parameter.
2. In the **Specify stack details** page, set the stack name as **RenderingWithBatch**.
3. In the **Configure stack options** page, leave all the configuration as it is. Navigate to the bottom of the page and click on **Next**.
4. In the **Review** page, leave all the configuration as it is. Navigate to the bottom of the page, and click on **I acknowledge that AWS CloudFormation might create IAM resources** and finally on **Create stack**.

{{% notice warning %}}
It is important that you use **RenderingWithBatch** as the stack name, as later we will use that value to retrieve some outputs programmatically.
{{% /notice %}}

The stack creation process will begin. All the resources will be ready to use when the status of the stack is `CREATE_COMPLETE`.

{{% insert-md-from-file file="rendering-with-batch/start/review-outputs.md" %}}
