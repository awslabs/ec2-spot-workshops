---
menuTitle: "Rendering with AWS Batch"
title: "Rendering Blender Projects with AWS Batch"
date: 2021-09-06T08:51:33Z
weight: 80
pre: "<b>8. </b>"
---

## Overview

In this workshop you will learn to submit jobs with [AWS Batch](https://aws.amazon.com/batch/) following Spot best practices to [render](https://en.wikipedia.org/wiki/Rendering_(computer_graphics)) a [Blender](https://www.blender.org/) file in a distributed fashion, running a Docker container that you will create and publish to Amazon Elastic Container Registry (ECR). [Spot instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) are EC2 spare capacity offered at steep discounts compared to On-Demand instances and are a cost-effective choice for applications that can be interrupted, what makes them well-suited for the batch processing that we will run. After going through all the sections, you will have the following pipeline created:

1. A python script downloads the Blender file from S3 to extract the number of frames.
2. The script submits a Batch array job (rendering job) of dimension *n* depending on the number of frames. It also submits a single job (stitching job) with a sequential dependency on the rendering job. (You will learn more about job dependencies later).
3. Each of the jobs in the rendering job array run a Docker container that executes Blender to render a slice of frames, and after uploads them to S3.
4. The stitching job runs a Docker container that downloads all the frames from S3, executes [FFmpeg](https://ffmpeg.org/) (you will learn more about it in a future section) to create a video out of the rendered frames and finally uploads it to S3.

To have an idea of what you will be rendering, take a look to this animation.

![Possible output](/images/rendering-with-batch/animation_example.gif)

This output is the result of rendering the project *[Pottery](https://blendswap.com/blend/28661)* by [Prokster](https://blendswap.com/profile/1012752), that is shared under the [Creative Commons 0](https://creativecommons.org/share-your-work/public-domain/cc0/) license. Head to the next page to take a look at the architecture that you will deploy.
