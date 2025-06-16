---
title: "... On your own"
date: 2021-09-06T08:51:33Z
weight: 27
---

## Deploying the CloudFormation stack

As a first step, [download the CloudFormation stack](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/monte-carlo-with-batch/monte-carlo-with-batch.files/on-your-own.yaml) that will deploy the following resources for you:

- A VPC
- An S3 bucket
- An ECR repository
- A Launch Template
- An AWS Step Functions state machine
- An instance profile for the AWS Batch compute environment
- The Visual Studio Code environment where you will run all the commands

After downloading the template, open the [CloudFormation console](https://console.aws.amazon.com/cloudformation) and on the top-right corner of the screen, click on **Create stack**. Follow the following steps:

1. In the **Create stack** page, click on **Choose file** and upload the CloudFormation template you just downloaded. Don't change any other configuration parameter.
2. In the **Specify stack details** page, set the stack name as **MonteCarloWithBatch**.
3. In the **Configure stack options** page, leave all the configuration as it is. Navigate to the bottom of the page and click on **Next**.
4. In the **Review** page, leave all the configuration as it is. Navigate to the bottom of the page, and click on **I acknowledge that AWS CloudFormation might create IAM resources** and finally on **Create stack**.

{{% notice warning %}}
It is important that you use **MonteCarloWithBatch** as the stack name, as later we will use that value to retrieve some outputs programmatically.
{{% /notice %}}

The stack creation process will begin. All the resources will be ready to use when the status of the stack is `CREATE_COMPLETE`.

Now you can login to the Visual Studio Code environment deployed for you by following the steps below. 

1. Retrieve the Cloudfront URL and password as shown below:

![Get Outputs](/images/montecarlo-with-batch/workshop.001.get-outputs.png)

2. Paste the URL into a web browser and when presented with the login screen, enter the password you got from step 1

![Login](/images/montecarlo-with-batch/workshop.002.code-server-login.png)

3. Finally, you will reach the VS Code Server that has a Terminal window. You will run all of the workshop commands from there.

![Terminal](/images/montecarlo-with-batch/workshop.003.code-server-logged-in.png)

Now continue with the next steps below:

{{% insert-md-from-file file="monte-carlo-with-batch/start/review-outputs.md" %}}