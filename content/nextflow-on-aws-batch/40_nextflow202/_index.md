---
title: "Nextflow on AWS Batch"
chapter: true
weight: 40
---

Now that we setup AWS Batch we can use Nextflow to submit jobs we are getting closer to our architecture.
To aproach it slowly we will do two steps here.

### Local Run

The local run will use the job-queue to submit jobs directly.

![](/images/nextflow-on-aws-batch/nextflow202/nextflow-test-arch.png)

The drawback is that the nextflow process to supervise the execution is interactive and needs to keep running on the Cloud9 instance.

### Batch Squared

To decouple the supervision we are going to start the process within a second AWS Batch queue, so that it will stick around as long as the execution takes.
Some call this scenario 'batch squared' because it uses a queue to submit to a queue.

![](/images/nextflow-on-aws-batch/nextflow-workshop-arch.png)
