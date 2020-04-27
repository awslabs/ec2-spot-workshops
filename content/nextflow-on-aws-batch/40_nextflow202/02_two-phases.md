---
title: "Local and Detached Run"
chapter: false
weight: 02
---

The first run will run the supervision locally and the second one runs the supervision in AWS Batch itself.

### Local Run

The local run will use the job-queue to submit jobs directly.

![nextflow-test-arch](/images/nextflow-on-aws-batch/nextflow202/nextflow-test-arch.png)

The drawback is that the nextflow process to supervise the execution is interactive and needs to keep running on the Cloud9 instance.

### Batch Squared

To decouple the supervision we are going to start the process within a second AWS Batch queue, so that it will stick around as long as the execution takes.
Some call this scenario 'batch squared' because it uses a queue to submit to a queue.

![nextflow-workshop-arch](/images/nextflow-on-aws-batch/nextflow-workshop-arch.png)
