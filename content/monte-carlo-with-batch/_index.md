---
menuTitle: "Pricing Financial Derivatives with AWS Batch"
title: "Pricing Financial Derivatives AWS Batch"
date: 2021-09-06T08:51:33Z
weight: 110
pre: "<b>11. </b>"
---

{{% notice info %}}
The estimated completion time of this lab is **90 minutes**. Please note that pricing the derivatives presented below can incur in costs up to **$15**.
{{% /notice %}}
## Overview

In this workshop you will learn how to submit jobs with [AWS Batch](https://aws.amazon.com/batch/) following Spot best practices to price a financial derivative product using Monte Carlo methods. 
You will be creating a Docker container and publishing it in Amazon Elastic Container Registry (ECR). You will then use that container in AWS Batch and run on [EC2 Spot](https://aws.amazon.com/ec2/spot/) instances. 
<!-- 1. A python script downloads the Blender file from S3 to extract the number of frames from the Blender project.
2. The script submits a batch job using an `array job` with as many tasks as number of frames. It also submits a single stitching job using [FFmpeg](https://ffmpeg.org/) to create a final video file.
3. Each of the jobs in the rendering job array run a Docker container that executes Blender to render a slice of frames, and after uploads them to S3. -->



