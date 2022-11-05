---
title: "Creating the experiment"
date: 2022-09-20T00:00:00Z
weight: 153
---

You are now going to create an AWS FIS experiment template. An experiment template contains one or more actions to run on specified targets during an experiment.

{{% notice note %}}
You may recall the configuration of the AWS Batch job definition, which specified 3 attempts inside the structure `retryStrategy`. With this configuration in place, in case of job failure, AWS Batch will retry running that job twice more.
{{% /notice %}}

## Creating the experiment template

We are going to create an AWS FIS experiment template to send a interruption signal to up to 5 of the EC2 Spot instances. The instance selection is randomly chosen based on the presence of the tags that were set when creating the compute environment `type : Spot`. If the EC2 instance is running an AWS Batch job, the job will exit and retry after other jobs finish or more EC2 capacity is dynamically added in response to the interruption signal.

Run the following command to generate the AWS Fault Injection Simulator (AWS FIS) experiment template file.

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
  - **filters**: the filters to apply to identify target resources using specific attributes. In this case, only instances that are in the "running" state.
  - **selectionMode**: scopes the identified resources to a specific count of the resources at random, or a percentage of the resources. All identified resources are included in the target.
    - COUNT(n) - Run the action on the specified number of targets, chosen from the identified targets at random. For example, COUNT(1) selects one of the targets.
  - **actions**: the actions for the experiment, in this case, sending a 2-minute Spot Interruption notice to the selected instances. For more information, see [Actions](https://docs.aws.amazon.com/fis/latest/userguide/actions.html) in the Fault Injection Simulator User Guide.
  - **stopConditions**: specifies a stop condition for an experiment template. In this case, there aren't any.
  - **roleArn**: the Amazon Resource Name (ARN) of an IAM role that grants the AWS FIS service permission to perform service actions on your behalf.

Execute this command to create the AWS FIS template from the JSON file defined above. To learn more about this API, see [create-experiment-template CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/create-experiment-template.html).

```
export FIS_TEMPLATE=$(aws fis create-experiment-template --cli-input-json file://fis-experiment.json | jq -r '.experimentTemplate.id')
echo "FIS Template ID: ${FIS_TEMPLATE}"
```

Next, you are going to submit a rendering job request.