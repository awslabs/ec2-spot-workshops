---
title: "Running Spark apps with EMR on Spot Instances"
date: 2019-01-24T09:05:54Z
weight: 60
draft: true
pre: "<b>⁃ </b>"
---

## This workshop is still in draft! ping ranshein@amazon.com for any concerns.

## Overview

In this workshop you will assume the role of a data engineer, tasked with building a platform that will allow your organization to run data processing jobs, specifically Apache Spark applications. 

The requirements for the platform are:

1. Use a managed service - in order to avoid the heavy lifting of installing, maintaining and upgrading compute clusters that run Apache Hadoop framework software, mainly Spark.
2. Be secure - allow network level isolation and encryption at rest and in transit.
3. Be cost optimized - use Amazon EC2 Spot Instances, as well as easily run transient clusters (that will be spun up just to run a job and then spun down) where possible in order to cost optimize.
4. Decouple compute and storage - in order to allow to elastically scale your processing power independently from having to provision more storage for your clusters. 
5. Be self-healing in order to decrease operations overhead - if a compute node fails, the cluster will automatically replace it and continue running the job.


## The decision is simple - <span style="color:#ff9900">***Amazon EMR***</span> fulfills all the requirements. 

* [Amazon EMR] (https://aws.amazon.com/emr/) provides a managed Hadoop framework that makes it easy, fast, and cost-effective to process vast amounts of data across dynamically scalable Amazon EC2 instances. You can also run other popular distributed frameworks such as [Apache Spark] (https://aws.amazon.com/emr/details/spark/), [HBase] (https://aws.amazon.com/emr/details/hbase/), [Presto] (https://aws.amazon.com/emr/details/presto/), and [Flink] (https://aws.amazon.com/blogs/big-data/use-apache-flink-on-amazon-emr/) in EMR, and interact with data in other AWS data stores such as Amazon S3 and Amazon DynamoDB. EMR Notebooks, based on the popular Jupyter Notebook, provide a development and collaboration environment for ad hoc querying and exploratory analysis.
  EMR securely and reliably handles a broad set of big data use cases, including log analysis, web indexing, data transformations (ETL), machine learning, financial analysis, scientific simulation, and bioinformatics.
    
* [Amazon EC2 Spot Instances] (https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

### About Spot Instances in Analytics workloads
The most important best practice when using Spot Instances is to be flexible with the EC2 instance types that our application can run on, in order to be able to access many spare capacity pools (a combination of EC2 instance type and an Availability Zone), as well as get our desired capacity from a different instance type in case some of our Spot capacity in the EMR cluster is interrupted, when EC2 needs the spare capacity back. It's possible to run Spark applications in a single cluster that is running on multiple different instance types, we'll just need to right-size our executors and use the EMR Instance Fleets configuration option in order to meet the Spot diversification best practice.