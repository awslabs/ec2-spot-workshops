---
title: "Dashboard View"
chapter: false
weight: 20
---

## AWS Batch Dashboard

Follow this [deep link to get to AWS Batch](https://console.aws.amazon.com/batch/home) you will be greated by the landing page.

![landingpage](/images/nextflow-on-aws-batch/batch/1_landingpage.png)

Click on 'get started' and skip the wizard.

![wizard](/images/nextflow-on-aws-batch/batch/2_wizard.png)

Now we are at the AWS Batch Dashboard, which allows us to create:

   1. **Job Definitions** Description of what application (Docker Image), how to use it (storage, resource requirements) and what IAM permissions are granted to the job execution.
   1. **Job Queues** Logical queue holding jobs. A queue uses Compute Environments to execute jobs. A queue can be linked to multiple Compute Environments with different priorities to use a second queue in case a Compute Environment has insufficient capacity (e.g. reached its configured maximum capacity)
   1. **Compute Environments** Compute capacity to run the job from the job-queue. They are backed by EC2 On-Demand and EC2 Spot instances running within an ECS cluster. A Compute Environment can back multiple queues, in which case a priority is defined.

![landingpage](/images/nextflow-on-aws-batch/batch/3_dashboard.png)
