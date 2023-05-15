---
title: "Creating the job queue"
date: 2021-09-06T08:51:33Z
weight: 100
---

You are now going to create a Job Queue. The Job Queue is going to be associated with the two compute environments that we just created. We will assign an order of use for the Compute Environments using first the OnDemand environment and then the Spot.

Run the following to generate the configuration file that will be used to create the job queue:

```
export MC_QUEUE_NAME=MonteCarloQueue

cat <<EoF > job-queue-config.json
{
    "jobQueueName": "${MC_QUEUE_NAME}",
    "state": "ENABLED",
    "priority": 10,
    "computeEnvironmentOrder": [
        {
            "order": 1,
            "computeEnvironment": "${ONDEMAND_COMPUTE_ENV_ARN}"
        },
        {
            "order": 2,
            "computeEnvironment": "${SPOT_COMPUTE_ENV_ARN}"
        }
    ]
}
EoF
```

Let's explore the configuration parameters in the structure:

- **priority**: job queues with a higher priority are evaluated first when associated with the same compute environment. Priority is determined in descending order.
- **computeEnvironmentOrder**: the set of compute environments mapped to a job queue and their order relative to each other. A compute environment with a **lower** value of `order` is tried for job placement first. We specify the On-demand compute environment to be tried first to ensure that we have compute capacity throughout the whole execution, thus being able to comply with SLAs should there be any.

{{% notice note %}}
All the compute environments within a queue must be either (`SPOT` and/or `EC2`) or (`FARGATE` and/or `FARGATE_SPOT`). EC2 and Fargate compute environments can't be mixed. We will only work with `SPOT` and `EC2` compute environments.
{{% /notice %}}

Execute this command to create the job queue. To learn more about this API, see [create-job-queue CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/create-job-queue.html).

```
export JOB_QUEUE_ARN=$(aws batch create-job-queue --cli-input-json file://job-queue-config.json | jq -r '.jobQueueArn')
echo "Job queue Arn: ${JOB_QUEUE_ARN}"
```

Next, you are going to create a **Job Definition** that will be used to submit jobs.
