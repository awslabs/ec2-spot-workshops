---
title: "Nextflow with AWS Batch"
date: 2020-03-28T09:05:54Z
weight: 80
pre: "<b>⁃ </b>"
---

The content of this workshop is derived from a tutorial created by the nice folks at [Seqera Labs](https://github.com/seqeralabs/nextflow-tutorial), kudos to them!
We won't create or own pipelines and tweak code, but rather jump right in with a small proof-of-concept pipeline, which we will run locally in containers, submit locally to AWS Batch and run a batch job that submits to AWS Batch.

## Overview

During this workshop you will implement a proof of concept of a RNA-seq pipeline. The goal of this workshop is not te become a Bioinformatician nor a Nextflow guru, but to get familiar with the concepts of nextflow and AWS Batch.

{{% notice info %}}
The estimated cost for running this **1.5 hour** workshop will be less than **$5**.
{{% /notice %}}

## Introduction

### Conventions

Throughout this workshop, we provide commands for you to run in the terminal.  These commands will look like this:

```bash
ssh -i PRIVATE_KEY.PEM ec2-user@EC2_PUBLIC_DNS_NAME
```

The command starts after `$`.  Words that are ***UPPER_ITALIC_BOLD*** indicate a value that is unique to your environment.  For example, the ***PRIVATE\_KEY.PEM*** refers to the private key of an SSH key pair that you've created, and the ***EC2\_PUBLIC\_DNS\_NAME*** is a value that is specific to an EC2 instance launched in your account.  
