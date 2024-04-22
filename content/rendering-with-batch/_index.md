---
menuTitle: "Rendering with AWS Batch"
title: "Rendering Blender Projects with AWS Batch"
date: 2021-09-06T08:51:33Z
weight: 100
pre: "<b>10. </b>"
---

{{% notice info %}}
The estimated completion time of this lab is **90 minutes**. Please note that rendering the animation presented below can incur in costs up to **$15**.
{{% /notice %}}
## Overview

In this workshop you will learn to submit fault tolerant jobs with [AWS Batch](https://aws.amazon.com/batch/) following Spot best practices to [render](https://en.wikipedia.org/wiki/Rendering_(computer_graphics)) a [Blender](https://www.blender.org/) file in a distributed way. You will be creating a docker container and publishing it in Amazon Elastic Container Registry (ECR). Then you will use that container in AWS Batch using a mix of EC2 On-Demand and Spot Instances. AWS Batch workloads are usually a perfect fit for [Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html), EC2 spare capacity offered at steep discounts compared to On-Demand instances. Using [AWS Fault Injection Simulator (AWS FIS)](https://aws.amazon.com/fis/), you will simulate an EC2 [Spot Instance interruption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html). After going through all the sections, you will have a resilient pipeline created, orchestrated by AWS Step Functions:

1. A python script downloads the Blender file from S3 to extract the number of frames from the Blender project.
2. The script submits a batch job using an `array job` with as many tasks as number of frames. It also submits a single stitching job using [FFmpeg](https://ffmpeg.org/) to create a final video file.
3. Each of the jobs in the rendering job array run a Docker container that executes Blender to render a slice of frames, and after uploads them to S3.

The outcome of the workshop would be the following animation:

![Pottery output](/images/rendering-with-batch/animation_example.gif)

This output is the result of rendering the project *[Pottery](https://blendswap.com/blend/28661)* by [Prokster](https://blendswap.com/profile/1012752). We thank **Prokster** for providing the project under the [Creative Commons 0](https://creativecommons.org/share-your-work/public-domain/cc0/) license. Head to the next page to take a look at the architecture that you will deploy.
