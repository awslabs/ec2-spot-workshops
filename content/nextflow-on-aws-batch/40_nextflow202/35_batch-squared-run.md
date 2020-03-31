---
title: "Batch Sqared Config"
chapter: false
weight: 35
---

## Create Job-Definition


![](/images/nextflow-on-aws-batch/nextflow202/create_jobdef_0.png)

### Basic Configuration
Now that we have everything, we need to create a job definition. For that click **[1]**.
   
![](/images/nextflow-on-aws-batch/nextflow202/create_jobdef_1.png)

   - **[1]** define the job name
   - **[2]** how often it is able to run before failing
   - **[3]** the execution timeout (here 1h)
   - **[4]** the container image from the docker push before
   - **[5]** the entrypoint command
   - **[6]** and finally how many resources the image needs to run.


### Security and Environment

Since the nextflow config is placed in the `$HOME` directory of root, we run the process within the container as `root` **[1]**.
Finally we define environment variables to control which pipeline to run **[2]** and create the job definition.

Please set `PIPELINE_URL` to `https://github.com/seqeralabs/nextflow-tutorial.git` and `NF_SCRIPT` to `script7.nf`.

![](/images/nextflow-on-aws-batch/nextflow202/create_jobdef_2.png)