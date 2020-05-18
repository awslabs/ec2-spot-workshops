---
title: "Local Run w/ AWS Batch"
chapter: true
weight: 35
---

## Nextflow on AWS Batch

Now that we setup AWS Batch we can use Nextflow to submit jobs we are getting closer to our architecture.

The local run will use the job-queue to submit jobs while the nextflow process is running locally.

![nextflow-test-arch](/images/nextflow-on-aws-batch/nextflow202/nextflow-test-arch.png)
