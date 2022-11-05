---
title: "Monitoring the experiment"
date: 2021-09-06T08:51:33Z
weight: 157
---


## Viewing the automatically retried AWS Batch jobs

By running this script in your Cloud9 shell, you can see the individual render jobs and where there were multiple attempts due to the Spot interruption signal:

```
latestJobId=$(aws batch list-jobs --job-queue RenderingQueue --filters name=JOB_NAME,values=${FIS_JOB_NAME} | jq -r '.jobSummaryList[0].jobId')
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

### Example output from the verification script:

In the example below, you can see that AWS Batch job 35 had 2 attempts, the first attempt failed to complete as a result of the Spot interruption leading to the EC2 instance being terminated. The second attempt exited normally, allowing the job to succeed.

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

### Viewing the result

When the AWS Batch job finishes, the output video will be available in the following URL:

```
echo "Output url: https://s3.console.aws.amazon.com/s3/buckets/${BucketName}?region=${AWS_DEFAULT_REGION}&prefix=${FIS_JOB_NAME}/output.mp4"
```

Copy the output of the command into your browser. It will take you to the S3 page where the output file `output.mp4` has been stored. You can just click on the **Download** button to download it to your own computer and play it.

{{% notice warning %}}
You will need the appropriate program and video codecs to watch the mp4 generated video. You can use [VLC media player](https://www.videolan.org/vlc/).
{{% /notice %}}

{{% notice tip %}}
There will be 2 output files, one from the first job and the second from the job we interrupted.
{{% /notice %}}

Next, you will clean up the resources you have created.