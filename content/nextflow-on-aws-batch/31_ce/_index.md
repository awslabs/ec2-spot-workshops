---
title: "Compute Environments & Queues"
chapter: true
weight: 31
---

### Setup AWS Batch Compute Environments and Job Queues

<!-- [comment]: **needs some improvements** -->

AWS Batch defines Compute Environments to executes jobs and Job Queues to submit jobs to.

The workshop will use two queues to submit and execute jobs.

- **workflow queue** As the nextflow process is supervising the execution of a job it needs to run continuously. Thus, a workflow queue will hold this job and execute them on rather small (2 vCPU), On-Demand instances.
- **job-queue** The nextflow process will compute a execution flow and submit jobs for individual tasks into the *job-queue*. Those tasks do the actual computation and uses the a Compute Environment `spot-ce` leveraging EC2 Spot instances.
