---
title: "Setup AWS Batch"
chapter: true
weight: 30
---

# Setup AWS Batch

Nextflow uses **process** definitions to define what script or command to execute. An executor is used to determine **how** the process is executed on the target system.

The [nextflow documentation](https://www.nextflow.io/docs/latest/basic.html#execution-abstraction) explains it nicely:

> In other words, Nextflow provides an abstraction between the pipeline's functional logic and the underlying execution system. Thus it is possible to write a pipeline once and to seamlessly run it on your computer, a grid platform, or the cloud, without modifying it, by simply defining the target execution platform in the configuration file.
