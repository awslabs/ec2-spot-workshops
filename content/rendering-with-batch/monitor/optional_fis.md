---
title: "Optional - Spot Interruption"
date: 2022-09-20T00:00:00Z
weight: 145
---


## This step is optional and is not required

{{% notice warning %}}
You should wait until the AWS Batch job from your first experiment has fully completed before starting this optional lab.
{{% /notice %}}

Since AWS Batch workloads are containerized, AWS Batch is a perfect fit for Spot Instances. If a workload is interrupted, Batch will automatically spin-up another Spot Instance you’ve specified. This optional lab allows you to experiment with this feature, by using the AWS Fault Injection Simulator (AWS FIS) to send an interruption signal to the EC2 Spot instances defined within the AWS Batch compute environment.

Start a rendering job by initiating the state machine:

```
export FIS_JOB_NAME="Pottery-FIS"
export EXECUTION_ARN=$(aws stepfunctions start-execution --state-machine-arn "${StateMachineArn}" --input "{\"jobName\": \"${FIS_JOB_NAME}\", \"inputUri\": \"s3://${BucketName}/${BlendFileName}\", \"outputUri\": \"s3://${BucketName}/${FIS_JOB_NAME}\", \"jobDefinitionArn\": \"${JOB_DEFINITION_ARN}\", \"jobQueueArn\": \"${JOB_QUEUE_ARN}\", \"framesPerJob\": \"1\"}" | jq -r '.executionArn')
echo "State machine started. Execution Arn: ${EXECUTION_ARN}."
```

Run the following command to generate the AWS Fault Injection Simulator (AWS FIS) experiement template file. The FIS Experiemnt will create an AWS FIS experiment to send a interruption signal to up to 5 of the EC2 Spot instances. The instance selection is randomly chosen based on the presence of the tags that were set when creating the compute environment("type" : "Spot"). If the EC2 instance is running an AWS Batch job, the job will stop, and be resumed after other jobs finish or more EC2 capacity is dynamically added in response to the interruption signal.

```
cat <<EoF > fis-experiment.json
{
    "description": "SpotInterruption",
    "targets": {
        "SpotTags": {
            "resourceType": "aws:ec2:spot-instance",
            "resourceTags": {
                "type": "Spot"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": [
                        "running"
                    ]
                }
            ],
            "selectionMode": "COUNT(5)"
        }
    },
    "actions": {
        "Spot": {
            "actionId": "aws:ec2:send-spot-instance-interruptions",
            "parameters": {
                "durationBeforeInterruption": "PT2M"
            },
            "targets": {
                "SpotInstances": "SpotTags"
            }
        }
    },
    "stopConditions": [
        {
            "source": "none"
        }
    ],
    "roleArn": "${FISCustomRole}",
    "tags": {}
}
EoF
```

Let's explore the configuration parameters in the structure:

- **description**: a description for the experiment template.
- **targets**: the targets for the experiment.
  - **SpotTags**: an identifier for the grouping of resources.
    - **resourceType**: the resource type, in this case EC2 Spot Instances.
    - **resourceTags**: the tags for the target resource, in this case, where the tag named "type" has the value of "Spot".
  - **filters**: the filters to apply to identify target resources using specific attributes. In this case, only instances that are in the "running" state
  - **selectionMode**: scopes the identified resources to a specific count of the resources at random, or a percentage of the resources. All identified resources are included in the target.
    - COUNT(n) - Run the action on the specified number of targets, chosen from the identified targets at random. For example, COUNT(1) selects one of the targets.
  - **actions**: the actions for the experiment, in this case, sending a 2-minute Spot Interruption notice to the selected instances. For more information, see [Actions](https://docs.aws.amazon.com/fis/latest/userguide/actions.html) in the Fault Injection Simulator User Guide .
  - **stopConditions**: specifies a stop condition for an experiment template. In this case, we don't have any.
  - **roleArn**: the Amazon Resource Name (ARN) of an IAM role that grants the AWS FIS service permission to perform service actions on your behalf.

Execute this command to create the AWS FIS template from the JSON file defined above. To learn more about this API, see [create-experiment-template CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/create-experiment-template.html).

```
export FIS_TEMPLATE=$(aws fis create-experiment-template --cli-input-json file://fis-experiment.json | jq -r '.experimentTemplate.id')
echo "FIS Template ID: ${FIS_TEMPLATE}"
```

{{% notice info %}}
You should wait a few minutes after starting the job above for enough EC2 instances to have joined the pool before starting the AWS FIS experiment.
{{% /notice %}}

At any time before, during, or after the AWS FIS experiment, you can look at your AWS EC2 Spot instance request status with the following command. To learn more about this API, see [describe-spot-instance-requests CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-spot-instance-requests.html).

```
aws ec2 describe-spot-instance-requests --query 'SpotInstanceRequests[].[InstanceId, Status.Code]'
```

The output will show you the EC2 instance IDs and the Spot instance request state:
  - **fulfilled**: indicates an EC2 spot request was fulfilled and is still active and running
  - **instance-terminated-by-experiment**: indicates that the EC2 Spot instance received the AWS FIS Interruption signal and was terminated
  - **instance-terminated-by-user**: indicates that the EC2 Spot instance fulfilled its job and was terminated by AWS Batch after no longer being needed.

Before you execute the next command to start the AWS FIS experiment from the template, make sure that you have at least 3 EC2 Spot requests that are **fulfilled** using the previous command. Additionally, you can run this command at several points during the AWS Batch run to simulate multiple Spot interruptions. To learn more about this API, see [start-experiment CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/start-experiment.html).

```
export FIS_EXPERIMENT=$(aws fis start-experiment --experiment-template-id ${FIS_TEMPLATE} | jq -r '.experiment.id')
echo "FIS Experiment ID: ${FIS_EXPERIMENT}"
```

{{% notice note %}}
AWS FIS starts sends the interruption signal to up to 5 EC2 instances, then waits 2 minutes before terminating the EC2 host.
{{% /notice %}}

To get the status of the AWS FIS experiment, execute the following command. To learn more about this API, see [get-experiment CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/get-experiment.html).

```
aws fis get-experiment --id ${FIS_EXPERIMENT}  | jq -r '.experiment.state'
```

If the status is:
- **running**: the job is still underway.
- **completed**: the FIS experiment has been run and instances will respond to the interruption notice based on the time delay set in the template.
- **failed**: the FIS experiment has failed, a reason code will be provided to assist in understanding why the experiment failed. (e.g. "Target resolution returned empty set")

  {{% notice info %}}
  If the AWS Batch job is not active, the "failed" reason code will be "Target resolution returned empty set". This indicates no running EC2 instances with the "Spot" tag were found. You should wait a few minutes longer after the AWS Batch job is underway and start the FIS experiment again.
  {{% /notice %}}

### Allow the job to complete and verify that the AWS Batch job completed successfully

{{% notice tip %}}
This Spot-only operation can take a little more than 30 minutes. While it progresses, go to the AWS Batch console, and explore the state of: (a) compute environments, (b) jobs. You can also check in the EC2 console the: \(c\) EC2 instances and (d) Auto Scaling groups defined. 
{{% /notice %}}

When the AWS Batch job is finished, the output video will be available in the following URL:

```
echo "Output url: https://s3.console.aws.amazon.com/s3/buckets/${BucketName}?region=${AWS_DEFAULT_REGION}&prefix=${FIS_JOB_NAME}/output.mp4"
```

[Follow these steps](/rendering-with-batch/monitor.html) from the Monitoring and Results section

{{% notice note %}}
Even though each run of the FIS Experiment removes 3 EC2 instances from the Spot compute environment, AWS Batch will still be able to handle the interruptions gracefully and complete the rendering job due to the retry policy. It is possible to create specific retry logic within AWS Batch if desired. Details about this capability can be viewed in the [AWS Batch Documentation](https://docs.aws.amazon.com/batch/latest/userguide/job_retries.html).
{{% /notice %}}

### Viewing the automatically retried AWS Batch jobs

By pasting this script into your Cloud9 shell, you can see the individual render jobs and where there were multiple attempts due to the Spot interruption signal:

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