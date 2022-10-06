---
title: "Create the AWS FIS experiment"
date: 2022-09-20T00:00:00Z
weight: 115
---

If you recall the configuration of the job definition, we specified 3 attempts inside the structure `retryStrategy`. This means that, in case of job failure, AWS Batch will retry running it twice more. In this section we are going to put that to test to see how our architecture would react if any of the Spot instances was terminated.

## AWS Fault Injection Simulator

[AWS Fault Injection Simulator](https://aws.amazon.com/fis/) is a fully managed service for running fault injection experiments on AWS that makes it easier to improve an application’s performance, observability, and resiliency. Fault injection experiments are used in chaos engineering, which is the practice of stressing an application in testing or production environments by creating disruptive events, such as sudden increase in CPU or memory consumption, observing how the system responds, and implementing improvements.

We are going to use AWS FIS to run a fault injection experiment in the ECS cluster associated to the Spot compute environment.

## Creating the experiment

Run the following command to generate the AWS Fault Injection Simulator (AWS FIS) experiement template file. The FIS Experiemnt will create an AWS FIS experiment to send a interruption signal to up to 5 of the EC2 Spot instances. The instance selection is randomly chosen based on the presence of the tags that were set when creating the compute environment `type : Spot`. If the EC2 instance is running an AWS Batch job, the job will exit and retry after other jobs finish or more EC2 capacity is dynamically added in response to the interruption signal.

```
cat <<EoF > fis-experiment.json
{
    "description": "SpotInterruption",
    "targets": {
        "SpotTags": {
            "resourceType": "aws:ec2:spot-instance",
            "resourceTags": {
                "type": "Spot"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": [
                        "running"
                    ]
                }
            ],
            "selectionMode": "COUNT(5)"
        }
    },
    "actions": {
        "Spot": {
            "actionId": "aws:ec2:send-spot-instance-interruptions",
            "parameters": {
                "durationBeforeInterruption": "PT2M"
            },
            "targets": {
                "SpotInstances": "SpotTags"
            }
        }
    },
    "stopConditions": [
        {
            "source": "none"
        }
    ],
    "roleArn": "${FISCustomRole}",
    "tags": {}
}
EoF
```

Let's explore the configuration parameters in the structure:

- **description**: a description for the experiment template.
- **targets**: the targets for the experiment.
  - **SpotTags**: an identifier for the grouping of resources.
    - **resourceType**: the resource type, in this case EC2 Spot Instances.
    - **resourceTags**: the tags for the target resource, in this case, where the tag named "type" has the value of "Spot".
  - **filters**: the filters to apply to identify target resources using specific attributes. In this case, only instances that are in the "running" state
  - **selectionMode**: scopes the identified resources to a specific count of the resources at random, or a percentage of the resources. All identified resources are included in the target.
    - COUNT(n) - Run the action on the specified number of targets, chosen from the identified targets at random. For example, COUNT(1) selects one of the targets.
  - **actions**: the actions for the experiment, in this case, sending a 2-minute Spot Interruption notice to the selected instances. For more information, see [Actions](https://docs.aws.amazon.com/fis/latest/userguide/actions.html) in the Fault Injection Simulator User Guide .
  - **stopConditions**: specifies a stop condition for an experiment template. In this case, we don't have any.
  - **roleArn**: the Amazon Resource Name (ARN) of an IAM role that grants the AWS FIS service permission to perform service actions on your behalf.

Execute this command to create the AWS FIS template from the JSON file defined above. To learn more about this API, see [create-experiment-template CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/create-experiment-template.html).

```
export FIS_TEMPLATE=$(aws fis create-experiment-template --cli-input-json file://fis-experiment.json | jq -r '.experimentTemplate.id')
echo "FIS Template ID: ${FIS_TEMPLATE}"
```