---
title: "Creating the job queue"
date: 2021-09-06T08:51:33Z
weight: 90
---

Run the following to generate the configuration file that will be used to create the job queue:

```bash
export RENDERING_QUEUE_NAME=RenderingQueue

cat <<EoF > ~/job-queue-config.json
{
    "jobQueueName": "${RENDERING_QUEUE_NAME}",
    "state": "ENABLED",
    "priority": 10,
    "computeEnvironmentOrder": [
        {
            "order": 1,
            "computeEnvironment": "${COMPUTE_ENV_ARN}"
        }
    ]
}
EoF
```

Execute this command to create the job queue. To learn more about this API, see [create-job-queue CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/create-job-queue.html).

```bash
aws batch create-job-queue --cli-input-json file://job-queue-config.json
```

Next, you are going to create a job definition that will be used to submit jobs.
