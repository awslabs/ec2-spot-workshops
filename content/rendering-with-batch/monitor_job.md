---
title: "Monitoring and results"
date: 2021-09-06T08:51:33Z
weight: 140
---

## Results

You can check the rendering progress by running these commands in the Cloud9 terminal:

```
while [ true ]
do
  export RENDERING_PROGRESS=$(aws batch describe-jobs --jobs "${RENDERING_JOB_ID}")
  export RENDER_COUNT=$(echo $RENDERING_PROGRESS | jq -r '.jobs[0].arrayProperties.statusSummary.SUCCEEDED')
  export FRAMES_TO_RENDER=$(echo $RENDERING_PROGRESS | jq -r '.jobs[0].arrayProperties.size')

  awk -v var1=$FRAMES_TO_RENDER -v var2=$RENDER_COUNT 'BEGIN { print  ("Rendering progress: " (var2 / var1) * 100 "% ==> " var2 " out of " var1 " frames rendered") }'

  if [ "${RENDER_COUNT}" == "${FRAMES_TO_RENDER}" ] ; then
    break
  fi

  sleep 7
done
```

{{% notice tip %}}
This operation will take about 5 minutes. While it progresses, go to the AWS Batch Console, and explore the state of: (a) Compute Environments, (b) Jobs. You can also check in the EC2 Console the: \(c\) EC2 Instances and (d) Auto Scaling groups defined.  
{{% /notice %}}

When the progress reaches 100%, the output video will be available in the following URL:

```
echo "Output url: https://s3.console.aws.amazon.com/s3/buckets/${BucketName}?region=${AWS_DEFAULT_REGION}&prefix=${JOB_NAME}/output.mp4"
```

Copy the output of the command into your browser. It will take you to the S3 page where the output file `output.mp4` has been stored. You can just click on the **Download** button to download it to your own computer and play it.

{{% notice warning %}}
You will need the appropriate program and video codecs to watch the mp4 generated video. You can use [VLC media player](https://www.videolan.org/vlc/).
{{% /notice %}}

{{% notice tip %}}
Explore also the rest of the S3 folders and check the frames that were created.
{{% /notice %}}



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

```
aws batch describe-jobs --jobs "${RENDERING_JOB_ID}" "${STITCHING_JOB_ID}"
```

To learn more about this command, you can review the [describe-jobs CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-jobs.html).

### Describing a queue

You can review the configuration of a queue using the following command:

```
aws batch describe-job-queues --job-queues "${RENDERING_QUEUE_NAME}"
```

To learn more about this command, you can review the [describe-job-queues CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-job-queues.html).

### Describing a compute environment

You can review the configuration of a compute environment using the following command:

```
aws batch describe-compute-environments --compute-environments "${SPOT_COMPUTE_ENV_NAME}" "${ONDEMAND_COMPUTE_ENV_NAME}"
```

To learn more about this command, you can review the [describe-compute-environments CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-compute-environments.html).

### Describing a job definition

You can review the configuration of a job definition using the following command:

```
aws batch describe-job-definitions --job-definition-name "${JOB_DEFINITION_NAME}"
```

To learn more about this command, you can review the [describe-job-definitions CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/describe-job-definitions.html).
