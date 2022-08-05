---
title: "Registering the job definition"
date: 2021-09-06T08:51:33Z
weight: 110
---

As a last step to configuring AWS Batch, we will register a job definition that will act as a template when we submit jobs.

Run the following to generate the configuration file that will be used to create the job definition:

```
export JOB_DEFINITION_NAME=RenderingJobDefinition

cat <<EoF > job-definition-config.json
{
    "jobDefinitionName": "${JOB_DEFINITION_NAME}",
    "type": "container",
    "containerProperties": {
        "image": "${IMAGE}",
        "vcpus": 1,
        "memory": 8000
    },
    "retryStrategy": {
        "attempts": 3
    },
    "platformCapabilities": [
        "EC2"
    ]
}
EoF
```

Let's explore the configuration parameters in the structure:

- **type**: `container` is the default type and allows to run loosely coupled HPC workloads at scale. The other available type is `multi-node`. With AWS Batch multi-node  you can run large-scale, tightly coupled, high performance computing applications. Note `multi-node` jobs are not supported with Spot instances. To learn more about `multi-node` jobs, visit [multi-node parallel jobs](https://docs.aws.amazon.com/batch/latest/userguide/multi-node-parallel-jobs.html).
- **image**: the image used to start a container, this value is passed directly to the Docker daemon.
- **vcpus**: The number of vCPUs reserved for the job. Each vCPU is equivalent to 1,024 CPU shares.
- **memory**: hard limit (in MiB) for a container. If your container attempts to exceed the specified number, it's terminated.
- **platformCapabilities**: the platform capabilities required by the job definition. Either `EC2` or `FARGATE`.

{{% notice info %}}
The values of `vcpus` and `memory` have been defined based on the resources needed to render a specific file. Each Blender file can be different in this sense and those values should be adapted accordingly to prevent the container from running out of memory when executing Blender.
{{% /notice %}}

Execute this command to create the job definition. To learn more about this API, see [register-job-definition CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/register-job-definition.html).

```
export JOB_DEFINITION_ARN=$(aws batch register-job-definition --cli-input-json file://job-definition-config.json | jq -r '.jobDefinitionArn')
echo "Job definition Arn: ${JOB_DEFINITION_ARN}"
```

Finally, you are going to submit a job request.
