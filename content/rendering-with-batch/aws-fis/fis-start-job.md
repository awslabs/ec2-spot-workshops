---
title: "Starting a new render job"
date: 2021-09-06T08:51:33Z
weight: 154
---

This section of the lab will start a new rendering job. This second job will be intentionally interrupted using AWS FIS.

{{% notice warning %}}
This section has dependencies on the completion of the [AWS Batch section]({{< ref batch >}}) of the lab.  Please ensure you have followed all steps, the previous job has completed, and you have verified the output by following the [monitoring steps in the previous lab]({{< ref monitor.md >}})
{{% /notice %}}

You can start the new rendering job by running this command:

```
export FIS_JOB_NAME="FIS-Pottery"
export EXECUTION_ARN=$(aws stepfunctions start-execution --state-machine-arn "${StateMachineArn}" --input "{\"jobName\": \"${FIS_JOB_NAME}\", \"inputUri\": \"s3://${BucketName}/${BlendFileName}\", \"outputUri\": \"s3://${BucketName}/${FIS_JOB_NAME}\", \"jobDefinitionArn\": \"${JOB_DEFINITION_ARN}\", \"jobQueueArn\": \"${JOB_QUEUE_ARN}\", \"framesPerJob\": \"1\"}" | jq -r '.executionArn')
echo "State machine started. Execution Arn: ${EXECUTION_ARN}."
```

To learn more about this API, see [start-execution CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/stepfunctions/start-execution.html). At this point the state machine is started and you are ready to monitor the progress of the pipeline.