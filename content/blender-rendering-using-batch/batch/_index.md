---
title: "AWS Batch"
date: 2021-09-06T08:51:33Z
weight: 80
---

## Overview

AWS Batch is a set of batch management capabilities that enables you to easily and efficiently run hundreds of thousands of batch computing jobs on AWS. AWS Batch dynamically provisions the optimal quantity and type of compute resources (e.g., CPU or memory optimized compute resources) based on the volume and specific resource requirements of the batch jobs submitted.

AWS Batch plans, schedules, and executes your batch computing workloads across the full range of AWS compute services and features, such as AWS Fargate, Amazon EC2 and Spot Instances. There is no additional charge for AWS Batch. You only pay for the AWS resources you create to store and run your batch jobs.

Thanks to Batch computing, you can execute a series of programs ("jobs") on one or more computers without manual intervention. Input parameters are pre-defined through scripts, command-line arguments, control files, or job control language. A given batch job may depend on the completion of preceding jobs, or on the availability of certain inputs, making the sequencing and scheduling of multiple jobs important, and incompatible with interactive processing.

## Understanding Batch components

### Typical job architecture

![Batch components](/images/blender-rendering-using-batch/batch_architecture.png)

### Compute environment

An AWS Batch Compute Environment is a collection of compute resources on which jobs are executed. AWS Batch supports two types of Compute Environments; Managed Compute Environments which are provisioned and managed by AWS and Unmanaged Compute Environments which are managed by customers.

With Managed Compute environments, you can use the following instance configurations:

- Fargate: Allows AWS Batch to run containers without having to manage servers or clusters of Amazon EC2 instances.
- Fargate Spot: Fargate Spot allows you to run interruption tolerant AWS Batch jobs at up to a 70% discount off the Fargate price.
- On-demand: EC2 instances that are billed per second.
- Spot: save money by using EC2 spare capacity.

To learn more about Compute environments, visit [AWS Batch Compute environment](https://docs.aws.amazon.com/batch/latest/userguide/compute_environments.html).

### Job queue

Jobs are submitted to a job queue where they reside until they can be scheduled to run in a compute environment. You can configure several job queues. Job queues have a priority that's used by the scheduler to determine which jobs in which queue should be evaluated for execution first.

To learn more about Job queues, visit [AWS Batch Job queues](https://docs.aws.amazon.com/batch/latest/userguide/job_queues.html).

### Job definition

A Job Definition describes the job to be executed, parameters, environmental variables, compute requirements, and other information that is used to optimize the execution of a job. Job Definitions are defined in advance of submitting a job and can be shared with others.

To learn more about Job definitions, visit [AWS Batch Job definitions](https://docs.aws.amazon.com/batch/latest/userguide/job_definitions.html).

## When you should use AWS Batch

AWS Batch can be used in several scenarios that imply executing tasks which can be tore down to small components, jobs, thus drastically reducing execution time by running programs in parallel, and also automating the workloads. These are some example scenarios:

- Post-trade analytics: trading desks require batch processing of large data sets to constantly analyse day's transaction costs and execution reporting, among other areas. AWS Batch enables the automation of these workloads so that you can understand the pertinent risk going into the next day’s trading cycle and make better decisions based on data.
- Drug screening: AWS Batch allows research scientists involved in drug discovery to more efficiently and rapidly search libraries of small molecules in order to identify those structures which are most likely to bind to a drug target, typically a protein receptor or enzyme.
- Rendering: AWS Batch provides content producers and post-production houses with tools to automate content rendering workloads and reduces the need for human intervention due to execution dependencies or resource scheduling.
- Media supply chain: AWS Batch simplifies complex media supply chain workflows by coordinating the execution of disparate and dependent jobs at different stages of processing, and supports a common framework for managing content preparation for different contributors to the media supply chain.

## AWS Batch features
- **Dynamic compute resource provisioning and scaling**: you only need to set up a few concepts in Batch (a Compute environment, job queue, and job definition), and you have a complete queue, scheduler, and compute architecture without managing a single piece of compute infrastructure.
- **AWS Batch with Fargate**: AWS Batch with Fargate resources allows you to have a completely serverless architecture for your batch jobs.
- **Integration with EC2 Launch Templates**: AWS Batch now supports EC2 Launch Templates, allowing you to build customized templates for your compute resources, and enabling Batch to scale instances with those requirements.
- **Priority-based job scheduling**: AWS Batch enables you to set up multiple queues with different priority levels. Batch jobs are stored in the queues until compute resources are available to execute the job. The AWS Batch scheduler evaluates when, where, and how to run jobs that have been submitted to a queue based on the resource requirements of each job.

These are just some examples of all the features AWS Batch has. If you want to learn in detail all its capabilities, visit [this web page](https://aws.amazon.com/batch/features/?nc=sn&loc=2).

## Working with AWS Batch

{{% children  %}}
