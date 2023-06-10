---
disableToc: true
hidden: true
---

## Reviewing the Launch Template

You can check the CloudFormation stack by downloading the following file: [CloudFormation stack](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/monte-carlo-with-batch/monte-carlo-with-batch.files/stack.yaml)

Note that the `UserData` of the created Launch Template contains the following script:

```
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
For more information on how AWS Batch uses Amazon ECS, see the [FAQs](https://aws.amazon.com/batch/faqs/).

## Gathering the CloudFormation outputs
You will create other AWS resources using the AWS CLI in [Cloud9](https://aws.amazon.com/cloud9/), a cloud-based integrated development environment (IDE) that lets you write, run, and debug your code with just a browser. It includes a code editor, debugger, and terminal. Cloud9 comes prepackaged with essential tools for popular programming languages, including JavaScript, Python, PHP, and more.

Navigate to the [Cloud9 console](https://console.aws.amazon.com/cloud9) and open the environment that was created for you. Execute the following commands to retrieve the outputs of the CloudFormation stack:

```
for output in $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[].OutputKey' --output text)
do
    echo export $output=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
    eval "echo $output : \"\$$output\""
done
```

You can now start the workshop by heading to [**Risk pipeline**](/monte-carlo-with-batch/risk_pipeline.html).
