---
title: "Nextflow with AWS Batch"
date: 2020-03-28T09:05:54Z
weight: 80
pre: "<b>⁃ </b>"
---

The content of this workshop are derived from a tutorial created by the nice folks at [Seqera Labs](https://github.com/seqeralabs/nextflow-tutorial), kudos to them!


## Overview 
During this workshop you will implement a proof of concept of a RNA-seq pipeline. The goal of this workshop is not te become a Bioinformatician nor a Nextflow guru, but to get familiar with the concepts of nextflow and AWS Batch.

{{% notice info %}}
The estimated cost for running this **Y hour** workshop will be less than **$X**.
{{% /notice %}}

## Introduction

### Conventions:  
Throughout this workshop, we provide commands for you to run in the terminal.  These commands will look like this: 

<pre>
$ ssh -i PRIVATE_KEY.PEM ec2-user@EC2_PUBLIC_DNS_NAME
</pre>

The command starts after `$`.  Words that are ***UPPER_ITALIC_BOLD*** indicate a value that is unique to your environment.  For example, the ***PRIVATE\_KEY.PEM*** refers to the private key of an SSH key pair that you've created, and the ***EC2\_PUBLIC\_DNS\_NAME*** is a value that is specific to an EC2 instance launched in your account.  

