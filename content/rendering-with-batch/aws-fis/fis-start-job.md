---
title: "Starting a new rendering job"
date: 2021-09-06T08:51:33Z
weight: 154
---

In this section you are going to start a new rendering job that will be intentionally interrupted by AWS FIS using the experiment that you have created in the previous section.

{{% notice warning %}}
This section has dependencies on the completion of the [AWS Batch section]({{< ref batch >}}) of the previous lab.  Please, ensure that you have followed all the steps and that the previous job has completed. Also, verify the output by [following the monitoring steps in the previous lab]({{< ref monitor.md >}})
{{% /notice %}}

You can start the new rendering job by running this command:

```
export FIS_JOB_NAME="FIS-Pottery"
export EXECUTION_ARN=$(aws stepfunctions start-execution --state-machine-arn "${StateMachineArn}" --input "{\"jobName\": \"${FIS_JOB_NAME}\", \"inputUri\": \"s3://${BucketName}/${BlendFileName}\", \"outputUri\": \"s3://${BucketName}/${FIS_JOB_NAME}\", \"jobDefinitionArn\": \"${JOB_DEFINITION_ARN}\", \"jobQueueArn\": \"${JOB_QUEUE_ARN}\", \"framesPerJob\": \"1\"}" | jq -r '.executionArn')
echo "State machine started. Execution Arn: ${EXECUTION_ARN}."
```

Next, you are going to interrupt the running job.