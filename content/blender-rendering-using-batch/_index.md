---
title: "Using AWS Batch with Blender for distributed rendering"
date: 2021-09-06T08:51:33Z
weight: 10
pre: "<b>⁃ </b>"
---

## Overview

In this workshop you will learn to submit jobs with AWS Batch following Spot best practices to render a Blender file in a distributed fashion, running a Docker container that you will create and publish to Amazon Elastic Container Registry (ECR). After going through all the sections, you will have the following pipeline created:

1. A python script downloads the Blender file from S3 to extract the number of frames.
2. The script submits a Batch array job (rendering job) of dimension *n* depending on the number of frames. It also submits a single job (stitching job) with a sequential dependency on the rendering job. (You will learn more about job dependencies later).
3. Each of the jobs in the rendering job array run a Docker container that executes Blender to render a slice of frames, and after uploads them to S3.
4. The stitching job runs a Docker container that downloads all the frames from S3, executes FFmpeg (you will learn more about it in a future section) to create a video out of the rendered frames and uploads the video to S3.

{{% notice info %}}
The estimated completion time of this lab is **45** minutes. Rendering the same animation that you see below, you will incur in an estimated cost of **5€**.
{{% /notice %}}

### Output example

To have an idea of what you will be rendering, take a look to this animation.

![Possible output](/images/blender-rendering-using-batch/animation_example.gif)


### Architecture diagram

The following diagram illustrates the what you will deploy:

![Architecture diagram](/images/blender-rendering-using-batch/architecture.png)

## Pre-Requisites for this lab:

 - An AWS account. You will create AWS resources during the workshop.
 - A laptop with Wi-Fi running Microsoft Windows, Mac OS X, or Linux.
 - An Internet browser such as Chrome, Firefox, Safari, or Edge.
 - AWS CloudShell configured with your console credentials.
 - AWS CLI installed in your laptop.

 If you want to create your own Docker image, additionally you will need:

 - Docker installed in your laptop.
