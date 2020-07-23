---
title: "AWS Batch Squared"
chapter: true
weight: 40
---

## Detached Nextflow Run

To decouple the supervision we are going to start the process within a second AWS Batch queue, so that it will stick around as long as the execution takes.
Some call this scenario **AWS Batch Squared** because it uses a queue to submit to a queue.

![nextflow-workshop-arch](/images/nextflow-on-aws-batch/nextflow-workshop-arch.png)
