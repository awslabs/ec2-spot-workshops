---
title: "Registering the job definition"
date: 2021-09-06T08:51:33Z
weight: 100
---

Run the following to generate the configuration file that will be used to create the job definition:

```bash
export JOB_DEFINITION_NAME=RenderingJobDefinition

cat <<EoF > ~/job-definition-config.json
{
    "jobDefinitionName": "${JOB_DEFINITION_NAME}",
    "type": "container",
    "containerProperties": {
        "image": "nytimes/blender",
        "vcpus": 1,
        "memory": 1024
    },
    "retryStrategy": {
        "attempts": 1
    },
    "platformCapabilities": [
        "EC2"
    ]
}
EoF
```

Execute this command to create the job definition. To learn more about this API, see [register-job-definition CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/register-job-definition.html).

```bash
aws batch register-job-definition --cli-input-json file://job-definition-config.json
```

Finally, you are going to submit a job request.
