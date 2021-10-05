---
title: "Submitting the job"
date: 2021-09-06T08:51:33Z
weight: 120
---

## Downloading the python script

To submit the jobs that will implement the rendering and stitching you are going to use a python script that has already been coded. Execute the following command to download it from GitHub.

```bash
wget https://raw.githubusercontent.com/bperezme/ec2-spot-workshops/blender_rendering_using_batch/content/blender-rendering-using-batch/batch/job_submission.py
```

## Reviewing the command line arguments

This script needs a couple of command line arguments as input, execute the following to read the help documentation:

```bash
python3 job_sumbission.py -h
```

You see that the script needs to receive the location of the blender file and where the results should be uploaded, as well as the the job definition that will be used to submit the job, the queue where it will be placed and the name that will be used to submit it.

Additionally, there's an extra argument *-f* that needs to be passed. Thanks to this argument you can specify how many frames each job should render. This will have a direct impact on the size of the array job that is submitted. E.g.: if you want to render a file that has 250 frames and you specify a value of 1 for that argument, the size of the array job will be 250. If you specify a value of 5, the size will be 50 and so on. As you can imagine, the less the frames each job has to render, the less the time it will take for the job to complete.

## Submitting the job

To submit the rendering job, run the following block of code replacing the values of the arguments -i, -o, -f and, optionally, -n. It will launch the python script and export the identifiers of the two jobs to environment variables to be able to monitor them.

```bash
export JOB_IDS=$(python3 job_sumbission.py -i <input> -o <output> -f <n_frames> -n RenderingJob -q "${RENDERING_QUEUE_NAME}" -d "${JOB_DEFINITION_NAME}")
export RENDERING_JOB_ID=$((echo $JOB_IDS) | jq -r '.[0].jobId')
export STITCHING_JOB_ID=$((echo $JOB_IDS) | jq -r '.[1].jobId')
```

At this point the jobs have been submitted and you are ready to monitor them.

## Optional: understanding the script

### submit_rendering_job

Two important things to highlight from this method:

1. The command that is passed to the container is defined in the line 183. The arguments are preceded by the keyword *render*. These arguments will be received by the bash script that we have talked about in the section *Download image files* inside *Creating your Docker image*.
2. The array job is created by specifying the *arrayProperties* value. An array job is a job that shares common parameters, such as the job definition, vCPUs, and memory. It runs as a collection of related, yet separate, basic jobs that may be distributed across multiple hosts and may run concurrently. At runtime, the *AWS_BATCH_JOB_ARRAY_INDEX* environment variable is set to the container's corresponding job array index number. This is how the bash script is able to calculate the slice of frames that needs to render.
To learn more about it, visit [Array jobs](https://docs.aws.amazon.com/batch/latest/userguide/array_jobs.html) and [Tutorial: Using the Array Job Index to Control Job Differentiation](https://docs.aws.amazon.com/batch/latest/userguide/array_index_example.html).

### submit_stitching_job

Two important things to highlight from this method:

1. The command that is passed to the container is defined in the line 207. The arguments are preceded by the keyword *stitch*.
2. The job dependency is created by specifying the *dependsOn* value, which is a dictionary that contains the identifier of the job towards which create the dependency, and the type of dependency. In this case, the dependency is *SEQUENTIAL* because the stitching job must be launched **after** all the frames have been rendered. To learn more about job dependencies visit [Job Dependencies](https://docs.aws.amazon.com/batch/latest/userguide/job_dependencies.html).
