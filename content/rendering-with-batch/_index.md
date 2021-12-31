---
menuTitle: "Rendering with AWS Batch"
title: "Rendering Blender Projects with AWS Batch"
date: 2021-09-06T08:51:33Z
weight: 80
pre: "<b>8. </b>"
---

{{% notice info %}}
The estimated completion time of this lab is **90 minutes**. Please note that rendering the animation presented below can incur in costs up to **$15**.
{{% /notice %}}
## Overview

In this workshop you will learn to submit jobs with [AWS Batch](https://aws.amazon.com/batch/) following Spot best practices to [render](https://en.wikipedia.org/wiki/Rendering_(computer_graphics)) a [Blender](https://www.blender.org/) file in a distributed way. You will be creating a docker container and publishing it in Amazon Elastic Container Registry (ECR). Then you will use that container in AWS Batch using a mix of EC2 On-Demand and Spot instances. [Spot instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) are EC2 spare capacity offered at steep discounts compared to On-Demand instances and are a cost-effective choice for applications that can be interrupted, what makes them well-suited for the batch processing that we will run. After going through all the sections, you will have the following pipeline created, orchestrated by AWS Step Functions:

1. A Lambda function downloads the Blender file from S3 to read the number of frames it has.
2. An AWS Batch `array job` (rendering) is submitted with as many tasks as number of frames. Each of the jobs in the array job run a Docker container that executes Blender to render a slice of frames, and after uploads them to S3.
3. An AWS Batch single job (stitching) is submitted to run a Docker container that executes [FFmpeg](https://ffmpeg.org/) to concatenate the frames and create a final video file that it's uploaded to S3.

The outcome of the workshop would be the following animation:

![Pottery output](/images/rendering-with-batch/animation_example.gif)

This output is the result of rendering the project *[Pottery](https://blendswap.com/blend/28661)* by [Prokster](https://blendswap.com/profile/1012752). We thank **Prokster** for providing the project under the [Creative Commons 0](https://creativecommons.org/share-your-work/public-domain/cc0/) license. Head to the next page to take a look at the architecture that you will deploy.
