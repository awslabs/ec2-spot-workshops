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

   - **[1]** define the job name: nf-head
   - **[2]** how often it is able to run before failing: 1
   - **[3]** the execution timeout (here 1 hour or 3600 seconds): 3600 
   - **[4]** the container image from the docker push before: copy paste the docker url visible in the log after executing the code "docker build -t $REPO_URI:${IMG_TAG} ." at previous step
   - **[5]** the entrypoint command: /usr/local/bin/entrypoint.sh
   - **[6]** and finally how many resources the image needs to run: 1 cpu, 256 Mb memory


### Security and Environment
- **Security** user: root  
Since the nextflow config is placed in the `$HOME` directory of root, we run the process within the container as `root` **[1]**.
- **Environement variables**
Finally we define environment variables to control which pipeline to run **[2]** and create the job definition.

Please set 2 environement variables:
- Key: `PIPELINE_URL` and Value: `https://github.com/seqeralabs/nextflow-tutorial.git` 
- Key: `NF_SCRIPT` and Value `script7.nf`.

![](/images/nextflow-on-aws-batch/nextflow202/create_jobdef_2.png)
