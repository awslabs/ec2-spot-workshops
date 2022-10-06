---
title: "Monitoring"
date: 2021-09-06T08:51:33Z
weight: 140
---

You can check the rendering progress by running these commands in the Cloud9 terminal:

```
while [ true ]
do
  while [ true ]
  do
    export RENDERING_JOB_ID=$(aws batch list-jobs --job-queue "${RENDERING_QUEUE_NAME}" --filters name=JOB_NAME,values="${JOB_NAME}" --query 'jobSummaryList[*].jobId' | jq -r '.[0]')

    if [ ! -z "$RENDERING_JOB_ID" ] ; then
      break
    fi

    echo "Rendering not started yet"
    sleep 5
  done

  export RENDERING_PROGRESS=$(aws batch describe-jobs --jobs "${RENDERING_JOB_ID}")
  export RENDER_COUNT=$(echo $RENDERING_PROGRESS | jq -r '.jobs[0].arrayProperties.statusSummary.SUCCEEDED')
  export FRAMES_TO_RENDER=$(echo $RENDERING_PROGRESS | jq -r '.jobs[0].arrayProperties.size')

  awk -v var1=$FRAMES_TO_RENDER -v var2=$RENDER_COUNT 'BEGIN { print  ("Rendering progress: " (var2 / var1) * 100 "% ==> " var2 " out of " var1 " frames rendered") }'

  if [ "${RENDER_COUNT}" == "${FRAMES_TO_RENDER}" ] ; then
    break
  fi

  sleep 5
done
```

{{% notice info %}}
It is normal if the progress is stuck at 0% at the beginning and after it increases rapidly. The reason for this is that AWS Batch is provisioning capacity for the Compute environments as defined earlier, and jobs will remain in the `RUNNABLE` state until sufficient resources are available. You can read more about job states here: [Job States](https://docs.aws.amazon.com/batch/latest/userguide/job_states.html).
{{% /notice %}}

### Viewing the automatically retried AWS Batch jobs

By running this script in your Cloud9 shell, you can see the individual render jobs and where there were multiple attempts due to the Spot interruption signal:

```
latestJobId=$(aws batch list-jobs --job-queue RenderingQueue --filters name=JOB_NAME,values=${JOB_NAME} | jq -r '.jobSummaryList[0].jobId')
numJobs=$(($(aws batch describe-jobs --jobs $latestJobId | jq -r '.jobs[].arrayProperties.size') - 1))
for ((x=0;x<=numJobs;x++)); do
    echo "Checking Job: $x of $numJobs..."
    if [[ $(aws batch describe-jobs --jobs $latestJobId:$x | jq '.jobs[].attempts | length') -gt 1 ]]
      then
        echo "------------------------------------------------"
        echo "Attempts: $(aws batch describe-jobs --jobs $latestJobId:$x | jq '.jobs[].attempts | length')"
        echo "Exit Reasons:"  
        echo "$(aws batch describe-jobs --jobs $latestJobId:$x | jq '.jobs[].attempts[].statusReason')"
        echo "------------------------------------------------"
      else
        echo "Attempts: 1 -- Exit reason: $(aws batch describe-jobs --jobs $latestJobId:$x | jq '.jobs[].attempts[].statusReason')"
    fi
done

```

#### Example output from the verification script:

In the example below, you can see that AWS Batch job 35 had 2 attempts, the first attempt was the result of the EC2 instance being terminated from the Spot interruption. The second attempt exited normally, allowing the job to complete gracefully.

```
Checking Job: 31 of 199...
Attempts: 1 -- Exit reason: "Essential container in task exited"
Checking Job: 32 of 199...
Attempts: 1 -- Exit reason: "Essential container in task exited"
Checking Job: 33 of 199...
Attempts: 1 -- Exit reason: "Essential container in task exited"
Checking Job: 34 of 199...
Attempts: 1 -- Exit reason: "Essential container in task exited"
Checking Job: 35 of 199...
------------------------------------------------
Attempts: 2
Exit Reasons:
"Host EC2 (instance i-04b17daec78ef4a0b) terminated."
"Essential container in task exited"
------------------------------------------------
Checking Job: 36 of 199...
Attempts: 1 -- Exit reason: "Essential container in task exited"
Checking Job: 37 of 199...
Attempts: 1 -- Exit reason: "Essential container in task exited"
```

{{% notice tip %}}
This rendering operation will take roughly 10 minutes. While it progresses, go to the AWS Batch Console, and explore the state of: (a) Compute Environments, (b) Jobs. You can also check in the EC2 Console the: \(c\) EC2 Instances and (d) Auto Scaling groups defined.  
{{% /notice %}}

### Viewing the result

When the AWS Batch job finishes, the output video will be available in the following URL:

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

### Viewing the execution of the state machine

You can follow the progress of the rendering pipeline by navigating to the executions tab of the state machine. To do it:

1. Navigate to the AWS Step Functions service page.
2. Select the state machine whose name begins with **RenderingPipeline**.
3. In the executions tab, select the first entry.
4. In the graph inspector, you can select a state to see the input it receives and the output it produces.

![AWS Step Functions console](/images/rendering-with-batch/step-functions.png)


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
aws batch describe-jobs --jobs "${RENDERING_JOB_ID}"
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
