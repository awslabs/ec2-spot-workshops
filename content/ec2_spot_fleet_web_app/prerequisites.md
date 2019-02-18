+++
title = "Prerequisites"
weight = 10
+++


### Requirements Overview
To complete this workshop, have the [AWS CLI](https://aws.amazon.com/cli/) installed and configured, and appropriate permissions to launch EC2 instances and launch CloudFormation stacks within your AWS account.

This workshop is self-paced. The instructions may use both the AWS CLI and AWS Management Console- feel free to use either or both as you are comfortable.

While the workshop provides step by step instructions, please do take a moment to look around and understand what is happening. The workshop is meant as a getting started guide, but you will learn the most by digesting each of the steps.


{{% notice warning %}}
This workshop has been designed to run in the AWS Region **us-east-1 (Virginia)**. Please make sure you are operating in 
{{% /notice %}}


### Create an AWS account

{{% notice tip %}}
If you already have an AWS account, and have Administrator access, you can skip this page.
{{% /notice %}}

1. **If you don't already have an AWS account with Administrator access**: [create
one now](https://aws.amazon.com/getting-started/)

1. Once you have an AWS account, ensure you are following the remaining workshop steps
as an **IAM user** with administrator access to the AWS account:
[Create a new IAM user to use for the workshop](https://console.aws.amazon.com/iam/home?region=us-east-1#/users$new)

1. Enter the user details:
![Create User](/images/ec2_spot_fleet_web_app/iam-1-create-user.png)

1. Attach the AdministratorAccess IAM Policy:
![Attach Policy](/images/ec2_spot_fleet_web_app/iam-2-attach-policy.png)

1. Click to create the new user:
![Confirm User](/images/ec2_spot_fleet_web_app/iam-3-create-user.png)

1. Take note of the login URL and save:
![Login URL](/images/ec2_spot_fleet_web_app/iam-4-save-url.png)


