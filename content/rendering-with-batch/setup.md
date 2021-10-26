---
title: "Environment set up"
date: 2021-07-07T08:51:33Z
weight: 20
---

## Deploying the CloudFormation stack

As a first step, you are going to download a [CloudFormation stack](www.test.com) that will deploy for you the following resources:

- An S3 bucket
- An ECR repository
- A Launch Template
- The Cloud9 environment where you will run all the commands

After downloading the template, open the [CloudFormation console](https://console.aws.amazon.com/cloudformation) and on the top-right corner of the screen, click on **Create stack**. Follow the following steps:

1. In the *Create stack* page, click on **Choose file** and upload the CloudFormation template you just downloaded. Don't change any other configuration parameter.
2. In the *Specify stack details* page, enter **RenderingWithBatch** as the stack name.
3. In the *Configure stack options* page, leave all the configuration as it is. Navigate to the bottom of the page and click on **Next**.
4. In the *Review* page, leave all the configuration as it is. Navigate to the bottom of the page, and click on **I acknowledge that AWS CloudFormation might create IAM resources** and finally on **Create stack**.

The stack creation process will begin. When the status of the stack is *CREATE_COMPLETE*, navigate to the [Cloud9 console](https://console.aws.amazon.com/cloud9) and open the environment that was created for you.

## Gathering the outputs

The first thing that we need to do in Cloud9 is gather the identifier of the resources that were created by CloudFormation,  to reference them later in some API calls. Run the following commands:

```bash
export STACK_NAME="RenderingWithBatch"

for output in $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[].OutputKey' --output text)
do
    export $output=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
    eval "echo $output : \"\$$output\""
done

export Subnets=($Subnets)
```

```bash
export AWS_DEFAULT_REGION="us-east-1"
sudo yum -y install jq
sudo pip install boto3
```

You are now done with the environment configuration.

## Optional: reviewing the Launch Template

When creating the Batch compute environment, we need to specify some configuration parameters that will be passed on to the EC2 instances when launched, like the Security Group, the Availability Zones and bootstrapping scripts (User data). To encapsulate those properties and be able to easily reuse them, we will use a Launch Template.

The *UserData* of the created Launch Template contains the following script:

```bash
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
echo "ECS_CLUSTER=EcsSpotWorkshop" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=true" >> /etc/ecs/ecs.config
echo "ECS_CONTAINER_STOP_TIMEOUT=90s" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

--==MYBOUNDARY==--
```

What we are doing here is enabling [Spot Instance Draining](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-spot.html). When ECS Spot Instance draining is enabled on the instance, ECS receives the Spot Instance interruption notice and places the instance in DRAINING status. When a container instance is set to DRAINING, Amazon ECS prevents new tasks from being scheduled for placement on the container instance. To learn more about Spot instance interruption notices, visit [Spot Instance interruption notices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html#spot-instance-termination-notices).
