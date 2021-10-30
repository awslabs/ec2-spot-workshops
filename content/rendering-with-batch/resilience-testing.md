---
title: "Resilience testing"
date: 2021-09-06T08:51:33Z
weight: 130
hidden: True
---

If you remember the configuration of the job definition, we specified 3 attempts inside the structure `retryStrategy`. This means that, in case of job failure, AWS Batch will retry running it twice more. In this section we are going to put that to test to see how our architecture would react if any of the Spot instances was terminated.

## AWS Fault Injection Simulator

[AWS Fault Injection Simulator](https://aws.amazon.com/fis/) is a fully managed service for running fault injection experiments on AWS that makes it easier to improve an application’s performance, observability, and resiliency. Fault injection experiments are used in chaos engineering, which is the practice of stressing an application in testing or production environments by creating disruptive events, such as sudden increase in CPU or memory consumption, observing how the system responds, and implementing improvements.

We are going to use AWS FIS to run a fault injection experiment in the ECS cluster associated to the Spot compute environment.

## Running the experiment

AWS FIS supports running fault injection actions in several targets. For a list of all the available targets, see [Targets for AWS FIS](https://docs.aws.amazon.com/fis/latest/userguide/targets.html). In our case, the target is going to be an ECS cluster.

### Retrieving the cluster ARN

Execute the following command to retrieve the ARN of the ECS cluster associated with the Spot compute environment:

```bash
export ECS_CLUSTER_ARN=$(aws batch describe-compute-environments --compute-environments "${SPOT_COMPUTE_ENV_NAME}" | jq -r '.computeEnvironments[0].ecsClusterArn')
```

### Creating the experiment

Run the following to generate the configuration file that will be used to create the AWS FIS experiment:

```bash
cat <<EoF > fis-experiment-config.json
{
    "description": "experimentTemplate",
    "stopConditions": [
        {
            "source": "none"
        }
    ],
    "targets": {
        "ECS-cluster": {
            "resourceType": "aws:ecs:cluster",
            "resourceArns": [
                "${ECS_CLUSTER_ARN}"
            ],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "drain": {
            "actionId": "aws:ecs:drain-container-instances",
            "description": "Drain cluster",
            "parameters": {
              "drainagePercentage": "60",
              "duration": "PT5M"
            },
            "targets": {
                "Clusters": "ECS-cluster"
            }
        }
    },
    "roleArn": "${FISRole}"
}
EoF
```

Let's explore the configuration parameters:

- **stopConditions**: specifies the stop conditions for the experiment. If there is one, `source` must point to a CloudWatch alarm.
- **targets**: the targets for the experiment:
  - **resourceType**: the AWS resource type. For a list of available resources, see [Resource types](https://docs.aws.amazon.com/fis/latest/userguide/targets.html#resource-types).
  - **selectionMode**: scopes the identified resources to a specific count. Valid values are `ALL` | `COUNT(n)` | `PERCENT(n)`.
- **actions**: the list of actions to perform:
  - **actionId**: the identifier of the action. For a list of available actions, see [AWS FIS actions reference](https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html). Each action takes different parameters.
  - **drainagePercentage**: percentage of underlying Amazon EC2 instances to drain.
  - **duration**: the duration of the action. With the AWS FIS API, the value is a string in [ISO 8601 format](https://www.digi.com/resources/documentation/digidocs/90001437-13/reference/r_iso_8601_duration_format.htm).
- **roleArn**: the Amazon Resource Name (ARN) of an IAM role that grants the AWS FIS service permission to perform service actions on your behalf. The needed permissions are outlined in the AWS FIS actions reference page.

Execute this command to create FIS experiment template and export its ARN to an environment variable. To learn more about this API, see [create-experiment-template CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/create-experiment-template.html).

```bash
export EXPERIMENT_TEMPLATE_ID=$(aws fis create-experiment-template --cli-input-json file://fis-experiment-config.json | jq -r '.experimentTemplate.id')
```

### Starting the experiment

The experiment will fail if we run it and the cluster does not have ECS container instances. To verify the number of registered container instances we can execute the following command:

```
aws ecs describe-clusters --clusters "${ECS_CLUSTER_ARN}"
```

To learn more about this API, see [describe-clusters CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ecs/describe-clusters.html). If the value of `registeredContainerInstancesCount` is 0, repeat the API call until it reaches 10 (approximately). Once that happens, you can start the experiment with the following command:

```bash
export EXPERIMENT_ID=$(aws fis start-experiment --experiment-template-id "${EXPERIMENT_TEMPLATE_ID}" | jq -r '.experiment.id')
```

To learn more about this API, see [start-experiment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/fis/start-experiment.html).

## Checking the results

### Reviewing the experiment

Execute the following command to get information about the experiment:

```bash
aws fis get-experiment --id "${EXPERIMENT_ID}"
```
To learn more about this API, see [get-experiment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/fis/get-experiment.html).

### Reviewing job attempts

To check which frames have been attempted to render more than once, execute the following command:

```bash
python3 verifying_resilience.py "${RENDERING_JOB_ID}"
```
