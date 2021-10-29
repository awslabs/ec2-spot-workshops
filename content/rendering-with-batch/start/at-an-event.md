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
- An IAM Role for AWS FIS
- An instance profile for AWS Batch compute environment
- The Cloud9 environment where you will run all the commands

## Gathering the outputs

Navigate to the Cloud9 console and open the environment that was created for you. Execute the following commands to retrieve the outputs of the CloudFormation stack and your current region:

```bash
export AWS_DEFAULT_REGION=$(curl -s  169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export STACK_NAME="RenderingWithBatch"

for output in $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[].OutputKey' --output text)
do
    export $output=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
    eval "echo $output : \"\$$output\""
done
```

You can now start the workshop by heading to [**Rendering pipeline**](/rendering-with-batch/rendering_pipeline.html).

## Optional: reviewing the Launch Template

When creating the Batch compute environment, we need to specify some configuration parameters that will be passed on to the EC2 instances when launched, like the Security Group, the Availability Zones and bootstrapping scripts (User data). To encapsulate those properties and be able to easily reuse them, we will use a Launch Template.

The `UserData` of the created Launch Template contains the following script:

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
