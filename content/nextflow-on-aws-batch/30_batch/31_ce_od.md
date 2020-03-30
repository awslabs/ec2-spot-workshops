---
title: "ComputeEnv: OD"
chapter: false
weight: 31
---

## Create EC2 On-Demand Compute Environment

The nextflow tasks, which are supervising the orchestration of the actual workflow are not able to tolerate interruptions as they need to run for the duration of the complete workflow.
Thus, we create a small On-Demand compute environment which will run the supervision task.

In the first section we **choose the name 'od-ce' [1]** and the **IAM roles [2] & [3]** which were created when we setup the Spot CE.
![](/images/nextflow-on-aws-batch/batch/4_create_ce-OD_1.png)

In the second section we select **On-Demand[1]** as the provisioning model, leave most of the defaults, set the **minimal and desired vCPUs to 1 [2]** and paste in the AMI-ID we just created with packer **[3]**.

![](/images/nextflow-on-aws-batch/batch/4_create_ce-OD_2.png)

We keep the defaults in the third section and click **create [1]**.

![](/images/nextflow-on-aws-batch/batch/4_create_ce_3.png)