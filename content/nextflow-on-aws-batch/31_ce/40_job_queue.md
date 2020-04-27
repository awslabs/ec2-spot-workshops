---
title: "Create Job Queues"
chapter: false
weight: 40
---

## Create Job Queue

Two queues need to be created. Both are created via the console.
![5_queue_workflow_0](/images/nextflow-on-aws-batch/batch/5_queue_workflow_0.png)

### On-Demand Queue

To create the on-demand queue we choose a name (**workflow-queue**) a priority of 1 and the map them to the correct compute environment (**od-ce**).

![5_queue_workflow_1](/images/nextflow-on-aws-batch/batch/5_queue_workflow_1.png)

After we chose the CE the form will look like this:

![5_queue_workflow_1-1](/images/nextflow-on-aws-batch/batch/5_queue_workflow_1-1.png)

### EC2 Spot Queue

Please create a second queue called **job-queue** that links to the spot compute environment (**spot-ce**)

### Queue Dashboard

With both queues created the dashboard displays two queues with different compute environments.

!5_queue_workflow_2[](/images/nextflow-on-aws-batch/batch/5_queue_workflow_2.png)
