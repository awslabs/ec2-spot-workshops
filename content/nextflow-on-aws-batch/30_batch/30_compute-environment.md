---
title: "ComputeEnv: Spot"
chapter: false
weight: 30
---

## Create EC2 Spot Compute Environment

TO run the actual genomics tasks, we create a compute environment (CE) using EC2 Spot instances. 

![](/images/nextflow-on-aws-batch/batch/4_create_ce_0.png?classes=shadow)

In the first section we **choose the name 'spot-ce' [1]**, let the wizard create a **new service role [2]** and select the previously **created admin role [3]**.

![](/images/nextflow-on-aws-batch/batch/4_create_ce_1.png)

In the second section we select **Spot [1]** as the provisioning model, leave most of the defaults, set the minimal and desired vCPUs to 4 **[2]** and paste in the AMI-ID we just created with packer **[3]**.

![](/images/nextflow-on-aws-batch/batch/4_create_ce_2.png)

{{% notice info %}}
In a production environment we might want to choose 0 as a minimum to scale down to no compute at all in case no work is to be done. 
When conducting a workshop we keep the CE from scale down to zero, as a scale out takes a couple of minutes.
{{% /notice %}}

We keep the defaults in the third section and click **create [1]**.

![](/images/nextflow-on-aws-batch/batch/4_create_ce_3.png)

Afterwards the dashboard shows a *spot-ce* compute environment.

![](/images/nextflow-on-aws-batch/batch/4_create_ce_4.png)