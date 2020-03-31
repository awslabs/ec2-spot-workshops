---
title: "Setup AWS Batch"
chapter: true
weight: 30
---

# Setup AWS Batch as a Backend


## Architecture

The workshop will use two queues to submit and execute jobs.

### workflow queue

As the nextflow process is supervising the execution of a job it needs to run continuesly. Thus, a workflow queue will hold this job and executes them on rather small instances with 2vCPUs.

### job queue

The nextflow process will compute a execution flow and submit jobs for individual tasks into the *job-queue*. Those tasks do the actual computation.
