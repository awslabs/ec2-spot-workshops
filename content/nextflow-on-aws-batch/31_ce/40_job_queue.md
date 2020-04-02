---
title: "Create Job Queues"
chapter: false
weight: 40
---

## Create Job Queue

Two queues need to be created. Both are created via the console.
![](/images/nextflow-on-aws-batch/batch/5_queue_workflow_0.png)

To create both queues we choose a name (**workflow-queue** / **job-queue**) a priority of 1 and the map them to the correct compute environment.

![](/images/nextflow-on-aws-batch/batch/5_queue_workflow_1.png)

After we chose the CE the form will look like this:

![](/images/nextflow-on-aws-batch/batch/5_queue_workflow_1-1.png)

## Job queues Dashboard

With both queues created the dashboard displays two queues with different compute environments.

![](/images/nextflow-on-aws-batch/batch/5_queue_workflow_2.png)