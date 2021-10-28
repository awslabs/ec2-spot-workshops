---
title: "Creating the job queue"
date: 2021-09-06T08:51:33Z
weight: 100
---

We are going to create a job queue that is going to be associated to the two compute environments that we just created. We will also assign an order of preference for the compute environments.

{{% notice info %}}
All the compute environments within a queue must be either (`SPOT` and/or `EC2`) or (`FARGATE` and/or `FARGATE_SPOT`). EC2 and Fargate compute environments can't be mixed. We will only work with `SPOT` and `EC2` compute environments.
{{% /notice %}}

Run the following to generate the configuration file that will be used to create the job queue:

```bash
export RENDERING_QUEUE_NAME=RenderingQueue

cat <<EoF > job-queue-config.json
{
    "jobQueueName": "${RENDERING_QUEUE_NAME}",
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

Execute this command to create the job queue. To learn more about this API, see [create-job-queue CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/create-job-queue.html).

```bash
aws batch create-job-queue --cli-input-json file://job-queue-config.json
```

Next, you are going to create a job definition that will be used to submit jobs.
