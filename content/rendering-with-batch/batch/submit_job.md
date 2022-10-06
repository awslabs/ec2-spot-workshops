---
title: "Workflow orchestration"
date: 2021-09-06T08:51:33Z
weight: 120
---

You have now all the AWS Batch and AWS Fault Injection Simulator components in place, and are ready to start submitting jobs that will be placed in a queue, then processed by a compute environment when AWS Batch's scheduler starts running them. We are going to use [AWS Step Functions](https://aws.amazon.com/step-functions/?nc1=h_ls&step-functions.sort-by=item.additionalFields.postDateTime&step-functions.sort-order=desc) to orchestrate the execution of our rendering pipeline, from the pre-processing of the Blender file to the stitching of the frames.

AWS Step Functions helps you orchestrate your AWS Batch jobs using serverless workflows, called state machines. You can use Step Functions to orchestrate preprocessing of data and Batch to handle the large compute executions, providing an automated, scalable, and managed batch computing workflow. The CloudFormation template has created the following state machine:

![State machine](/images/rendering-with-batch/state_machine.png)

You can notice that each step in the rendering pipeline has been mapped to a state. In AWS Step Functions, you can create state machines using the [Amazon States Language](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html) or the [AWS Step Functions Workflow Studio](https://docs.aws.amazon.com/step-functions/latest/dg/tutorial-workflow-studio-using.html).


The script needs: (a) the location of the blender file, (b) the location where results will be uploaded, \(c\) the Job Definition that will be used to submit the job, (d) the Job Queue where it will be placed and (e) the name that will be used to submit it.

The state machine will:

1. Download the Blender file from S3 to determine how many frames it has.
2. Submit a Batch array job that will run Blender to render the frames in parallel.
3. Submit a Batch job that will run FFmpeg to produce the final video.

To start the process, perform the following api call to pass a payload to the state machine with the job name, input path, output path, ARNs of the Job Definition and Job queue for AWS Batch to use and the number of frames each job has to render:

```
export JOB_NAME="Pottery"
export EXECUTION_ARN=$(aws stepfunctions start-execution --state-machine-arn "${StateMachineArn}" --input "{\"jobName\": \"${JOB_NAME}\", \"inputUri\": \"s3://${BucketName}/${BlendFileName}\", \"outputUri\": \"s3://${BucketName}/${JOB_NAME}\", \"jobDefinitionArn\": \"${JOB_DEFINITION_ARN}\", \"jobQueueArn\": \"${JOB_QUEUE_ARN}\", \"framesPerJob\": \"1\"}" | jq -r '.executionArn')
echo "State machine started. Execution Arn: ${EXECUTION_ARN}."
```

To learn more about this API, see [start-execution CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/stepfunctions/start-execution.html). At this point the state machine is started and you are ready to monitor the progress of the pipeline.

## Optional: understanding the state machine

We have orchestrated the workflow of the rendering pipeline using an AWS Step Functions state machine. Feel free to move to the next section and monitor its execution, but if at some point you are interested in knowing the details of its states, you can read the sections below.

### State *Number of frames extraction*

This is the entry point of our state machine. In this state, a Lambda function is invoked to determine the number of frames of the Blender file. To do that, we are using a script included in Blender's script library that extracts information related to the scenes of the composition. In broad strokes, the Lambda function implements the following logic:

1. Receives the payload that we passed on to the state machine when we started it.
2. Downloads the Blender file from S3.
3. Reads the number of frames of the file.
4. Calculates the dimension of the Batch array job taking into account the number of frames and how many frames each job has to render.

An array job is a job that shares common parameters, such as the job definition, vCPUs, and memory. It runs as a collection of related, yet separate, basic jobs that may be distributed across multiple hosts and may run concurrently. At runtime, the `AWS_BATCH_JOB_ARRAY_INDEX` environment variable is set to the container's corresponding job array index number. This is how the bash script is able to calculate the slice of frames that needs to render.
To learn more about it, visit [Array jobs](https://docs.aws.amazon.com/batch/latest/userguide/array_jobs.html) and [Tutorial: Using the Array Job Index to Control Job Differentiation](https://docs.aws.amazon.com/batch/latest/userguide/array_index_example.html).

You can view the Lambda function in the following URL:

```
echo "https://console.aws.amazon.com/lambda/home?region=${AWS_DEFAULT_REGION}#/functions/${PreprocessingLambda}?tab=code"
```

### State *Rendering*

Submits an AWS Batch array job of dimension *n*, where *n* is the number returned by the Lambda function of the previous state. Three important configurations are implemented in the definition of this state:

1. **Extraction of the ARNs of the Job Definition and Job Queue** from the payload received by the state machine using a [JSONPath](https://docs.aws.amazon.com/kinesisanalytics/latest/dev/about-json-path.html) expression. Those are passed on to AWS Batch when submitting the job:

    {{< highlight go "linenos=inline, linenostart=1, hl_lines=15-16" >}}
"Rendering": {
  "Type": "Task",
  "Resource": "arn:aws:states:::batch:submitJob.sync",
  "Parameters": {
    "JobName": "Rendering",
    "ArrayProperties": {
      "Size.$": "$.output.Payload.body.arrayJobSize"
    },
    "Parameters": {
      "action": "render",
      "inputUri.$": "$.inputUri",
      "outputUri.$": "$.outputUri",
      "framesPerJob.$": "$.framesPerJob"
    },
    "JobDefinition.$": "$.jobDefinitionArn",
    "JobQueue.$": "$.jobQueueArn"
  },
  "Next": "Stitching",
  "ResultPath": "$.output"
}
{{< / highlight >}}

    Read [this blog post](https://aws.amazon.com/es/blogs/compute/using-jsonpath-effectively-in-aws-step-functions/) to learn how to effectively use JSONPath expressions in AWS Step Functions.

2. **Setting the dimension of the array job** by specifying a value for the attribute `Size` inside the `ArrayProperties` structure. Now, we are taking that value from the output of the previous state:

    {{< highlight go "linenos=inline, linenostart=1, hl_lines=6-8" >}}
"Rendering": {
  "Type": "Task",
  "Resource": "arn:aws:states:::batch:submitJob.sync",
  "Parameters": {
    "JobName": "Rendering",
    "ArrayProperties": {
      "Size.$": "$.output.Payload.body.arrayJobSize"
    },
    "Parameters": {
      "action": "render",
      "inputUri.$": "$.inputUri",
      "outputUri.$": "$.outputUri",
      "framesPerJob.$": "$.framesPerJob"
    },
    "JobDefinition.$": "$.jobDefinitionArn",
    "JobQueue.$": "$.jobQueueArn"
  },
  "Next": "Stitching",
  "ResultPath": "$.output"
}
{{< / highlight >}}

3. **Setting a value for the parameters defined in the Job Definition**. If you remember, we did specify a `command` attribute with the value `["Ref::action", "-i", "Ref::inputUri", "-o", "Ref::outputUri", "-f", "Ref::framesPerJob"]` when we created the Job Definition. Now it's time to give a value to the placeholders in that expression:

    {{< highlight go "linenos=inline, linenostart=1, hl_lines=9-14" >}}
"Rendering": {
  "Type": "Task",
  "Resource": "arn:aws:states:::batch:submitJob.sync",
  "Parameters": {
    "JobName": "Rendering",
    "ArrayProperties": {
      "Size.$": "$.output.Payload.body.arrayJobSize"
    },
    "Parameters": {
      "action": "render",
      "inputUri.$": "$.inputUri",
      "outputUri.$": "$.outputUri",
      "framesPerJob.$": "$.framesPerJob"
    },
    "JobDefinition.$": "$.jobDefinitionArn",
    "JobQueue.$": "$.jobQueueArn"
    },
  "Next": "Stitching",
  "ResultPath": "$.output"
}
{{< / highlight >}}

As you can see, the action is set to `render`, since this state implements the rendering part of the pipeline.

### State *Stitching*

Similarly to the previous state, the *Stitching* state launches an AWS Batch job but, in this case, it is a single job. By the way we have defined the execution flow of the state machine, this state will be executed **after** the previous state has completed its execution. Optionally, in AWS Batch you can define job dependencies to manage the relationship of jobs and start them when others finish their execution. To learn more about job dependencies visit [Job Dependencies](https://docs.aws.amazon.com/batch/latest/userguide/job_dependencies.html) and to learn more about AWS Step Functions transitions visit [Transitions](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-transitions.html).

The only configuration of this state that differs from the previous is the value of the parameter `action`, that in this case is set to `stitch` so that our Docker container runs FFmpeg to produce the video when all the frames have been rendered.
