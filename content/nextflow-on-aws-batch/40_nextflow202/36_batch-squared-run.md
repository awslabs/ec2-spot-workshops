---
title: "Batch Squared Run"
chapter: false
weight: 36
---

## Run Job

Within the 'Jobs' section, we press 'Submit Job' (**[1]**).

![run_job_0](/images/nextflow-on-aws-batch/nextflow202/run_job_0.png)

Please choose a meaningful name (**[1]**), the last revision of the job definition we just created and select the `workflow-queue` (**[3]**).

![run_job_1](/images/nextflow-on-aws-batch/nextflow202/run_job_1.png)

And finally submit the job (**[1]**).

![run_job_2](/images/nextflow-on-aws-batch/nextflow202/run_job_2.png)

You will see the workflow job submitting jobs into the job-queue.

### Workflow Job

At first the workflow-job will start.

![job_dash_0](/images/nextflow-on-aws-batch/nextflow202/job_dash_0.png)

The same way our local batch run submitted jobs in the `job-queue` this job will also add jobs to the queue.

![job_dash_1](/images/nextflow-on-aws-batch/nextflow202/job_dash_1.png)
