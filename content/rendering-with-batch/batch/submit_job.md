---
title: "Submitting the job"
date: 2021-09-06T08:51:33Z
weight: 120
---

You have now all the AWS Batch components in place, and are ready to start submitting jobs that will be placed in a queue and processed by a compute environment when AWS Batch's scheduler starts running them. The last step is to download a Python script that will take the bucket name, the rendering queue and the job definition as input parameters and will launch the two jobs of the rendering pipeline using the [AWS SDK for Python, Boto3](https://aws.amazon.com/sdk-for-python/).

## Downloading the python script

To submit the jobs that will implement the rendering and stitching you are going to use a python script that has already been coded. Execute the following command to download it from GitHub.

```
wget https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/rendering-with-batch/batch/batch.files/job_submission.py
```

## Reviewing the command line arguments

This script needs a couple of command line arguments as input, execute the following to read the help documentation:

```
python3 job_submission.py -h
```

The script needs: (a) the location of the blender file, (b) the location where results will be uploaded, (c) as well as the the Job Definition that will be used to submit the job, (d) the Job Queue where it will be placed and the name that will be used to submit it.

Additionally, there's an extra argument `-f` that needs to be passed. The `-f` argument can be used to specify how many frames each job should render. This will have a direct impact on the size of the array job that is submitted. E.g.: if you want to render a file that has 250 frames and you specify a value of 1 for that argument, the size of the array job will be 250. If you specify a value of 5, the size will be 50 and so on. As you can imagine, the less the frames each job has to render, the less the time it will take for the job to complete.

## Submitting the job

To submit the rendering job, run the following block of code optionally replacing the value of the argument -f. It will launch the python script and export the identifiers of the two jobs to environment variables to be able to monitor them.

```
export JOB_NAME="RenderingWithBatch"
export JOB_IDS=$(python3 job_submission.py -i "s3://${BucketName}/${BlendFileName}" -o "s3://${BucketName}" -f 1 -n "${JOB_NAME}" -q "${RENDERING_QUEUE_NAME}" -d "${JOB_DEFINITION_NAME}")
export RENDERING_JOB_ID=$((echo $JOB_IDS) | jq -r '.[0].jobId')
export STITCHING_JOB_ID=$((echo $JOB_IDS) | jq -r '.[1].jobId')
echo "Job successfully submitted. Rendering job Id: ${RENDERING_JOB_ID}. Stitching job Id: ${STITCHING_JOB_ID}"
```

At this point the jobs have been submitted and you are ready to monitor them.

## Optional: understanding the script

We have used a python program to programmatically submit the jobs to AWS Batch. Feel free to move to the next section and monitor the execution of your AWS Batch job. If at some point you are interested to know the details of how the `job_submission.py` python job submits the job, you can read the sections below.

### Method submit_rendering_job

Two important things to highlight from this method:

1. The command that is passed to the container is defined in the line 200. The arguments are preceded by the keyword `render`. These arguments will be received by the bash script that we have talked about in the section *Download image files* inside *Creating your Docker image*.

    {{< highlight go "linenos=table, hl_lines=3, linenostart=198" >}}
full_output_uri = '{}/{}'.format(OUTPUT_URI, JOB_NAME)
client = boto3.client('batch')
command = 'render -i {} -o {} -f {} -t {}'.format(INPUT_URI, full_output_uri, F_PER_JOB, n_frames)
kwargs = build_job_kwargs('{}_Rendering'.format(JOB_NAME), command.split())
{{< / highlight >}}

2. The array job is created by specifying the `arrayProperties` value. An array job is a job that shares common parameters, such as the job definition, vCPUs, and memory. It runs as a collection of related, yet separate, basic jobs that may be distributed across multiple hosts and may run concurrently. At runtime, the `AWS_BATCH_JOB_ARRAY_INDEX` environment variable is set to the container's corresponding job array index number. This is how the bash script is able to calculate the slice of frames that needs to render.
To learn more about it, visit [Array jobs](https://docs.aws.amazon.com/batch/latest/userguide/array_jobs.html) and [Tutorial: Using the Array Job Index to Control Job Differentiation](https://docs.aws.amazon.com/batch/latest/userguide/array_index_example.html).

    {{< highlight go "linenos=table, linenostart=204" >}}
if array_size > 1:
    kwargs['arrayProperties'] = {
      'size': array_size
    }
{{< / highlight >}}

### Method submit_stitching_job

Two important things to highlight from this method:

1. The command that is passed to the container is defined in the line 225. The arguments are preceded by the keyword `stitch`.

    {{< highlight go "linenos=table, hl_lines=3, linenostart=225" >}}
full_output_uri = '{}/{}'.format(OUTPUT_URI, JOB_NAME)
client = boto3.client('batch')
command = 'stitch -i {} -o {}'.format(full_output_uri, full_output_uri)
kwargs = build_job_kwargs('{}_Stitching'.format(JOB_NAME), command.split())
{{< / highlight >}}

2. The job dependency is created by specifying the `dependsOn` value, which is a dictionary that contains the identifier of the job towards which create the dependency, and the type of dependency. In this case, the dependency is `SEQUENTIAL` because the stitching job must be launched **after** all the frames have been rendered. To learn more about job dependencies visit [Job Dependencies](https://docs.aws.amazon.com/batch/latest/userguide/job_dependencies.html).

    {{< highlight go "linenos=table, linenostart=229" >}}
kwargs['dependsOn'] = [
    {
        'jobId': depends_on_job_id,
        'type': 'SEQUENTIAL'
    }
]
{{< / highlight >}}
