---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

Each notebook contains a section at the bottom for cleaning up any resources that were created during the execution of the workbook. All othe resources, including the Amazon SageMaker Notebook Instance and VPC can be deleted by deleting the CloudFormation Stack you deployed at the start of this lab.


1. Browse to the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation).
{{% notice note %}}
Make sure you are in AWS Region designated by the facilitators of the workshop.
{{% /notice %}}
1. Click the radio button next to the CloudFormation Stack you deployed. ![SageMaker Notebook Instance](/images/using-sagemaker-managed-spot-training/cleanup-1.png)

1. Click the ***Delete*** button. ![SageMaker Notebook Instance](/images/using-sagemaker-managed-spot-training/cleanup-2.png)

1. Click the ***Delete stack*** button.