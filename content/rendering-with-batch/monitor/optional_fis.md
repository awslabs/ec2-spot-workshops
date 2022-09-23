---
title: "Optional - Spot Interruption"
date: 2022-09-20T00:00:00Z
weight: 145
---


## This step is optional and is not required

{{% notice warning %}}
You should wait until the AWS Batch job from your first experiment has fully completed before starting this optional lab.
{{% /notice %}}

To experiment with how AWS Batch jobs handles EC2 Spot Interruptions, you can follow this guide...

Run the following command to disable the "OnDemand" compute environment for AWS Batch.

```
aws batch update-compute-environment --compute-environment ${ONDEMAND_COMPUTE_ENV_ARN} --state DISABLED
```

Now start a rendering job, by initiating the state machine

```
export JOB_NAME="Pottery-FIS"
export EXECUTION_ARN=$(aws stepfunctions start-execution --state-machine-arn "${StateMachineArn}" --input "{\"jobName\": \"${JOB_NAME}\", \"inputUri\": \"s3://${BucketName}/${BlendFileName}\", \"outputUri\": \"s3://${BucketName}/${JOB_NAME}\", \"jobDefinitionArn\": \"${JOB_DEFINITION_ARN}\", \"jobQueueArn\": \"${JOB_QUEUE_ARN}\", \"framesPerJob\": \"1\"}" | jq -r '.executionArn')
echo "State machine started. Execution Arn: ${EXECUTION_ARN}."
```

Run the following command to generate the Fault Injection Simulator(FIS) Experiement template file. The FIS Experiemnt will create an interruption signal for some of the EC2 Spot instances.

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
            "selectionMode": "COUNT(3)"
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
    "roleArn": "arn:aws:iam::${REGISTRY_ID}:role/FIS-Custom-Role",
    "tags": {}
}
EoF
```

Let's explore the configuration parameters in the structure:

- **description**: A description for the experiment template.
- **targets**: The targets for the experiment.
  - **SpotTags**: An identifier for the grouping of resources.
    - **resourceType**: The resource type, in this case EC2 Spot Instances.
    - **resourceTags**: The tags for the target resource, in this case, where the Tag named "type" has the value of "Spot".
  - **filters**: The filters to apply to identify target resources using specific attributes.  In this case, only instances that are in the "running" state
  - **selectionMode**: Scopes the identified resources to a specific count of the resources at random, or a percentage of the resources. All identified resources are included in the target.
    - COUNT(n) - Run the action on the specified number of targets, chosen from the identified targets at random. For example, COUNT(1) selects one of the targets.
  - **actions**: The actions for the experiment, in this case, sending a 2-minute Spot Interruption notice to the selected instances. For more information, see [Actions](https://docs.aws.amazon.com/fis/latest/userguide/actions.html) in the Fault Injection Simulator User Guide .
  - **stopConditions**: Specifies a stop condition for an experiment template.  In this case, we don't have any.
  - **roleArn**: The Amazon Resource Name (ARN) of an IAM role that grants the FIS service permission to perform service actions on your behalf.

Execute this command to create the FIS template from the JSON defined above.

```
export FIS_TEMPLATE=$(aws fis create-experiment-template --cli-input-json file://fis-experiment.json | jq -r '.experimentTemplate.id')
echo "FIS Template ID: ${FIS_TEMPLATE}"
```

Execute this command to start the FIS experiment from the template.  You can run this command several times during the AWS Batch run to simulate multiple Spot Interruptions.

```
export FIS_EXPERIMENT=$(aws fis start-experiment --experiment-template-id ${FIS_TEMPLATE} | jq -r '.experiment.id')
echo "FIS Experiment ID: ${FIS_EXPERIMENT}"
```

{{% notice note %}}
The FIS experiment starts an asynchronous process to send the interruption signal to 3 EC2 instances
{{% /notice %}}

You can check the status of the FIS Experiment's progress with the following command

```
aws fis get-experiment --id ${FIS_EXPERIMENT}  | jq -r '.experiment.state'
```

If the status is:
- **running**: the job is still underway
- **completed**: the FIS experiment has been run and instances should respond to the 2 minute interruption notice.
- **failed**: the FIS Experiment has failed and the reason will help you understand why

  {{% notice info %}}
  If the AWS Batch job is not active, the "failed" reason code will be "Target resolution returned empty set".  This indicates no EC2 instances with the "Spot" tag were found.
  {{% /notice %}}

At any time before, during, or after the FIS experiment, you can look at your AWS EC2 Spot instance request status with the following command

```
aws ec2 describe-spot-instance-requests --query 'SpotInstanceRequests[].[InstanceId, Status.Code]'
```

The output will show you the EC2 instance IDs and the Spot instance request state:
  - **fulfilled**: indicates and EC2 spot request was fulfilled and is still active
  - **instance-terminated-by-experiment**: indicates that the EC2 Spot instance received the FIS Interruption signal and was terminated
  - **instance-terminated-by-user**: indicates that the EC2 Spot instance fulfilled it's job and was terminated by AWS Batch after no longer being needed.

### Allow the job to complete and verify the AWS Batch Job completed successfully

[Follow these steps](/rendering-with-batch/monitor.html) from the Monitoring and Results section

{{% notice note %}}
Even though the FIS Experiments removes 3 EC2 instances from the Spot compute environment, AWS Batch will still be able to handle the interruptions gracefully and complete the rendering job due to the retry policy. It is possible to create specific retry logic within AWS Batch if desired.  Details about this capability can be viewed in the [AWS Batch Documentation](https://docs.aws.amazon.com/batch/latest/userguide/job_retries.html)
{{% /notice %}}

### Viewing the automatically retried AWS Batch Jobs

By pasting this script into your Cloud9 shell, you can see the individual render jobs and where there were multiple attempts due to the Spot Interruption signal

```
latestJobId=$(aws batch list-jobs --job-queue RenderingQueue --filters name=JOB_NAME,values=Pottery-FIS | jq -r '.jobSummaryList[0].jobId')
numJobs=$(aws batch describe-jobs --jobs $latestJobId | jq -r '.jobs[].arrayProperties.size')
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

In the example below, you can see that Job 35 had 2 attempts, the first attempt was the result of the EC2 instance being terminated from the Spot Interruption. The second attempt exited normally, allowing the job to complete gracefully.

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