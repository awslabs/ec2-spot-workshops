---
title: "Creating the Launch Template"
date: 2021-07-07T08:51:33Z
weight: 70
---

When creating the Batch compute environment, we need to specify some configuration parameters that will be passed on to the EC2 instances when launched, like the Security Group, the Availability Zones and bootstrapping scripts (User data). To encapsulate those properties and be able to easily reuse them, we will use a Launch Template.

## Overview

Launch Templates enable you to define launch parameters so that you do not have to specify them every time you launch an instance. For example, a Launch Template can contain the AMI ID, instance type and network settings that you'd use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the Launch Template to use.

Launch Templates are immutable. Once created they cannot be changed, however they can be
versioned. Every change to the Launch Template can be tracked and you can select which version to use as new changes are applied to the template. This can be used for governance as well as to manage approved upgrades to, for example, Auto Scaling groups. If you do not specify a version, the default version is used.

## Enviroment variables definition

First, We need to store some data in environment variables that we will reference later and replace some of the entries in the commands with their values.

### Gathering subnet information

{{% notice info %}}
Note: During this workshop, we will use your account's default VPC to create the instances. If your account does not have a default VPC you can create or nominate one following [this link](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html#create-default-vpc)
{{% /notice %}}

Run the following commands to retrieve your default VPC and then its subnets.
    To learn more about these APIs, see [describe-vpcs CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html) and [describe-subnets CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html).

```bash
export VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true | jq -r '.Vpcs[0].VpcId')
export SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="${VPC_ID}")
export SUBNET_1=$((echo $SUBNETS) | jq -r '.Subnets[0].SubnetId')
export SUBNET_2=$((echo $SUBNETS) | jq -r '.Subnets[1].SubnetId')
export SUBNET_3=$((echo $SUBNETS) | jq -r '.Subnets[2].SubnetId')
```

### Gathering the default security group ID

To retrieve the identifier of the default security group you can perform the following call. To learn more about this API, see [describe-security-groups CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html).

```bash
export SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="default" | jq -r '.SecurityGroups[0].GroupId')
```

## Launch template creation

Create the Launch Template from the command line as follows.
You can check which other parameters Launch Templates could take [here](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-launch-template.html).

```bash
export LAUNCH_TEMPLATE_NAME="TemplateForBatch"

aws ec2 create-launch-template --launch-template-name "${LAUNCH_TEMPLATE_NAME}" --version-description 1 --launch-template-data "{\"SecurityGroupIds\": [\"${SECURITY_GROUP_ID}\"], \"UserData\": \"TUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UeXBlOiBtdWx0aXBhcnQvbWl4ZWQ7IGJvdW5kYXJ5PSI9PU1ZQk9VTkRBUlk9PSIKCi0tPT1NWUJPVU5EQVJZPT0KQ29udGVudC1UeXBlOiB0ZXh0L3gtc2hlbGxzY3JpcHQ7IGNoYXJzZXQ9InVzLWFzY2lpIgoKIyEvYmluL2Jhc2gKZWNobyAiRUNTX0NMVVNURVI9RWNzU3BvdFdvcmtzaG9wIiA+PiAvZXRjL2Vjcy9lY3MuY29uZmlnCmVjaG8gIkVDU19FTkFCTEVfU1BPVF9JTlNUQU5DRV9EUkFJTklORz10cnVlIiA+PiAvZXRjL2Vjcy9lY3MuY29uZmlnCmVjaG8gIkVDU19DT05UQUlORVJfU1RPUF9USU1FT1VUPTkwcyIgPj4gL2V0Yy9lY3MvZWNzLmNvbmZpZwplY2hvICJFQ1NfRU5BQkxFX0NPTlRBSU5FUl9NRVRBREFUQT10cnVlIiA+PiAvZXRjL2Vjcy9lY3MuY29uZmlnCgotLT09TVlCT1VOREFSWT09LS0=\"}"
```

Amazon EC2 user data in Launch Templates must be in the MIME multi-part archive format and needs to be encoded in base64 when creating the Launch Template using the CLI. To learn more, see [Amazon EC2 user data in launch templates](https://docs.aws.amazon.com/batch/latest/userguide/launch-templates.html).

The *UserData* parameter in the structure contains the following script encoded in Base64.

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

Execute the following command to base64 decode the string passed as *UserData*. You will see that the output matches the previous lines of code:

```bash
echo 'TUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UeXBlOiBtdWx0aXBhcnQvbWl4ZWQ7IGJvdW5kYXJ5PSI9PU1ZQk9VTkRBUlk9PSIKCi0tPT1NWUJPVU5EQVJZPT0KQ29udGVudC1UeXBlOiB0ZXh0L3gtc2hlbGxzY3JpcHQ7IGNoYXJzZXQ9InVzLWFzY2lpIgoKIyEvYmluL2Jhc2gKZWNobyAiRUNTX0NMVVNURVI9RWNzU3BvdFdvcmtzaG9wIiA+PiAvZXRjL2Vjcy9lY3MuY29uZmlnCmVjaG8gIkVDU19FTkFCTEVfU1BPVF9JTlNUQU5DRV9EUkFJTklORz10cnVlIiA+PiAvZXRjL2Vjcy9lY3MuY29uZmlnCmVjaG8gIkVDU19DT05UQUlORVJfU1RPUF9USU1FT1VUPTkwcyIgPj4gL2V0Yy9lY3MvZWNzLmNvbmZpZwplY2hvICJFQ1NfRU5BQkxFX0NPTlRBSU5FUl9NRVRBREFUQT10cnVlIiA+PiAvZXRjL2Vjcy9lY3MuY29uZmlnCgotLT09TVlCT1VOREFSWT09LS0=' | base64 --decode
```

What we are doing here is enabling [Spot Instance Draining](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-spot.html). When ECS Spot Instance draining is enabled on the instance, ECS receives the Spot Instance interruption notice and places the instance in DRAINING status. When a container instance is set to DRAINING, Amazon ECS prevents new tasks from being scheduled for placement on the container instance. To learn more about Spot instance interruption notices, visit [Spot Instance interruption notices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html#spot-instance-termination-notices).

**Example return**

```bash
{
    "LaunchTemplate": {
        "CreateTime": "2019-02-14T05:53:07.000Z",
        "LaunchTemplateName": "TemplateForBatch",
        "DefaultVersionNumber": 1,
        "CreatedBy": "arn:aws:iam::123456789012:user/xxxxxxxx",
        "LatestVersionNumber": 1,
        "LaunchTemplateId": "lt-00ac79500cbd56d11"
    }
}
```

You have created a Launch Template and stored into environment variables all the details that we will need to refer to it in the next steps. Let's start now configuring AWS Batch.
