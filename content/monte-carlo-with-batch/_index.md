---
menuTitle: "Pricing Financial Derivatives with AWS Batch"
title: "Pricing Financial Derivatives with AWS Batch"
date: 2021-09-06T08:51:33Z
weight: 90
pre: "<b>9. </b>"
---

{{% notice info %}}
The estimated completion time of this lab is **90 minutes**. Please note that pricing the derivatives presented below can incur in costs up to **$15**.
{{% /notice %}}

## Overview

In this workshop you will learn how to submit jobs with [AWS Batch](https://aws.amazon.com/batch/) following Spot best practices to price a financial derivative product using Monte Carlo methods. 
You will be creating a Docker container and publishing it in [Amazon Elastic Container Registry](https://aws.amazon.com/ecr/). You will then use that container in AWS Batch and run on [Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/).