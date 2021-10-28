---
title: "Monitoring and results"
date: 2021-09-06T08:51:33Z
weight: 140
---

## Results

You can check the rendering progress by running these commands:

```bash
export RENDERING_PROGRESS=$(aws batch describe-jobs --jobs "${RENDERING_JOB_ID}") && \
export RENDER_COUNT=$(echo $RENDERING_PROGRESS | jq -r '.jobs[0].arrayProperties.statusSummary.SUCCEEDED') && \
export FRAMES_TO_RENDER=$(echo $RENDERING_PROGRESS | jq -r '.jobs[0].arrayProperties.size') && \
awk -v var1=$FRAMES_TO_RENDER -v var2=$RENDER_COUNT 'BEGIN { print  ("Rendering progress: " (var2 / var1) * 100 "% ==> " var2 " out of " var1 " frames rendered.") }'
```

When the progress reaches 100%, the output video will be available in the following URL:

```bash
echo "Output url: https://s3.console.aws.amazon.com/s3/buckets/${BucketName}?region=${AWS_DEFAULT_REGION}&prefix=${JOB_NAME}/output.mp4"
```

## Monitoring

### Viewing the logs of a job

To view the logs of a job using the console:

1. Navigate to the AWS Batch service page.
2. On the left navigation panel, select **Jobs**.
3. Select the job of which you want to view the logs.
4. Follow the link under **Log stream name** inside the **Job information** section.

![AWS Batch console](/images/rendering-with-batch/logs.png)

### Monitoring the status of a job

You can monitor the status of a job using the following command:

```bash
aws batch describe-jobs --jobs "${RENDERING_JOB_ID}" "${STITCHING_JOB_ID}"
```

To learn more about this command, you can review the [describe-jobs CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-jobs.html).

### Describing a queue

You can review the configuration of a queue using the following command:

```bash
aws batch describe-job-queues --job-queues "${RENDERING_QUEUE_NAME}"
```

To learn more about this command, you can review the [describe-job-queues CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-job-queues.html).

### Describing a compute environment

You can review the configuration of a compute environment using the following command:

```bash
aws batch describe-compute-environments --compute-environments "${SPOT_COMPUTE_ENV_NAME}" "${ONDEMAND_COMPUTE_ENV_NAME}"
```

To learn more about this command, you can review the [describe-compute-environments CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-compute-environments.html).

### Describing a job definition

You can review the configuration of a job definition using the following command:

```bash
aws batch describe-job-definitions --job-definition-name "${JOB_DEFINITION_NAME}"
```

To learn more about this command, you can review the [describe-job-definitions CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-job-definitions.html).
