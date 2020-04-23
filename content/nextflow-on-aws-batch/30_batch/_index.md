---
title: "Setup AWS Batch"
chapter: true
weight: 30
---

# Setup AWS Batch

Nextflow uses **process** definitions to define what script or command to execute, an executor is used to determine **how** the process is executed on the target system.

The [nextflow documentation](https://www.nextflow.io/docs/latest/basic.html#execution-abstraction) exmplains it nicely:

> In other words, Nextflow provides an abstraction between the pipeline's functional logic and the underlying execution system. Thus it is possible to write a pipeline once and to seamlessly run it on your computer, a grid platform, or the cloud, without modifying it, by simply defining the target execution platform in the configuration file.

> In other words, Nextflow provides an abstraction between the pipeline's functional logic and the underlying execution system. Thus it is possible to write a pipeline once and to seamlessly run it on your computer, a grid platform, or the cloud, without modifying it, by simply defining the target execution platform in the configuration file.

Within this workshop we already used a local **Docker** executor in the small example - for the remainder of the workshop we are going to use the [awsbatch executor](https://www.nextflow.io/docs/latest/awscloud.html#aws-batch) to submit jobs to [AWS Batch](https://aws.amazon.com/batch/).
