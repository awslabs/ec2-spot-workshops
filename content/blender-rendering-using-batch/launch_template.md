---
title: "Creating a Launch Template"
date: 2021-07-07T08:51:33Z
weight: 70
---

## Overview

Launch Templates enable you to define launch parameters so that you do not have to specify them every time you launch an instance. For example, a Launch Template can contain the AMI ID, instance type and network settings that you'd use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the Launch Template to use.

Launch Templates are immutable. Once created they cannot be changed, however they can be
versioned. Every change to the Launch Template can be tracked and you can select which version to use as new changes are applied to the template. This can be used for governance as well as to manage approved upgrades to, for example, Auto Scaling groups. If you do not specify a version, the default version is used.

## Launch Template creation

Create the Launch Template from the command line as follows.
You can check which other parameters Launch Templates could take [here](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-launch-template.html).

```bash
export LAUNCH_TEMPLATE_NAME="TemplateForBatch"

aws ec2 create-launch-template --launch-template-name "${LAUNCH_TEMPLATE_NAME}" --version-description 1 --launch-template-data "{\"SecurityGroupIds\": [\"${SECURITY_GROUP_ID}\"], \"UserData\": \"Fn::Base64: !Sub | #!/bin/bash echo 'ECS_CLUSTER=EcsSpotWorkshop' >> /etc/ecs/ecs.config echo 'ECS_ENABLE_SPOT_INSTANCE_DRAINING=true' >> /etc/ecs/ecs.config echo 'ECS_CONTAINER_STOP_TIMEOUT=90s' >> /etc/ecs/ecs.config echo 'ECS_ENABLE_CONTAINER_METADATA=true' >> /etc/ecs/ecs.config\"}"
```

TODO: Explain user data

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
