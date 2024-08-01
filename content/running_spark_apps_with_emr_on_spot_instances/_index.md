---
title: "Running Spark apps with EMR on Spot Instances"
date: 2019-01-24T09:05:54Z
weight: 80
pre: "<b>8. </b>"
---



{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



## Overview

Welcome! In this workshop you will assume the role of a data engineer, tasked with optimizing the organization's costs for running Spark applications, using Amazon EMR and EC2 Spot Instances.

{{% notice info %}} The **estimated time** for completing the workshop is 60-90 minutes and the **estimated cost** for running the workshop's resources in your AWS account is less than $2.\
The **learning objective** for the workshop is to become familiar with the best practices and tooling that are available to you for cost optimizing your EMR clusters running Spark applications, using Spot Instances. {{% /notice %}}

## Recap - Amazon EMR and EC2 Spot Instances

* [Amazon EMR] (https://aws.amazon.com/emr/) provides a managed Hadoop framework that makes it easy, fast, and cost-effective to process vast amounts of data across dynamically scalable Amazon EC2 instances. You can also run other popular distributed frameworks such as [Apache Spark] (https://aws.amazon.com/emr/details/spark/), [HBase] (https://aws.amazon.com/emr/details/hbase/), [Presto] (https://aws.amazon.com/emr/details/presto/), and [Flink] (https://aws.amazon.com/blogs/big-data/use-apache-flink-on-amazon-emr/) in EMR, and interact with data in other AWS data stores such as Amazon S3 and Amazon DynamoDB. EMR Notebooks, based on the popular Jupyter Notebook, provide a development and collaboration environment for ad hoc querying and exploratory analysis.
  EMR securely and reliably handles a broad set of big data use cases, including log analysis, web indexing, data transformations (ETL), machine learning, financial analysis, scientific simulation, and bioinformatics.
    
* [Amazon EC2 Spot Instances] (https://aws.amazon.com/ec2/spot/) offer spare compute capacity available in the AWS Cloud at steep discounts compared to On-Demand prices. EC2 can interrupt Spot Instances with two minutes of notification when EC2 needs the capacity back. You can use Spot Instances for various fault-tolerant and flexible applications. Some examples are analytics, containerized workloads, high-performance computing (HPC), stateless web servers, rendering, CI/CD, and other test and development workloads.

## About Spot Instances in Analytics workloads
The most important best practice when using Spot Instances is to be flexible with the EC2 instance types that our application can run on, in order to be able to access many spare capacity pools (a combination of EC2 instance type and an Availability Zone), as well as achieve our desired capacity from a different instance type in case some of our Spot capacity in the EMR cluster is interrupted, when EC2 needs the spare capacity back.  
It's possible to run Spark applications in a single cluster that is running on multiple different instance types, we'll just need to right-size our executors and use the EMR Instance Fleets configuration option in order to meet the Spot diversification best practice. We'll look into that in detail during this workshop.

