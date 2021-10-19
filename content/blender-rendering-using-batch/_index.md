---
title: "Rendering with AWS Batch"
date: 2021-09-06T08:51:33Z
weight: 10
pre: "<b>⁃ </b>"
---

## Overview

In this workshop you will learn to submit jobs with AWS Batch following Spot best practices to [render](https://en.wikipedia.org/wiki/Rendering_(computer_graphics)) a [Blender](https://www.blender.org/) file in a distributed fashion, running a Docker container that you will create and publish to Amazon Elastic Container Registry (ECR). After going through all the sections, you will have the following pipeline created:

1. A python script downloads the Blender file from S3 to extract the number of frames.
2. The script submits a Batch array job (rendering job) of dimension *n* depending on the number of frames. It also submits a single job (stitching job) with a sequential dependency on the rendering job. (You will learn more about job dependencies later).
3. Each of the jobs in the rendering job array run a Docker container that executes Blender to render a slice of frames, and after uploads them to S3.
4. The stitching job runs a Docker container that downloads all the frames from S3, executes [FFmpeg](https://ffmpeg.org/) (you will learn more about it in a future section) to create a video out of the rendered frames and finally uploads it to S3.

To have an idea of what you will be rendering, take a look to this animation.

![Possible output](/images/blender-rendering-using-batch/animation_example.gif)

Special thanks to [Prokster](https://blendswap.com/profile/1012752) for being so kind to let us use the project *[Pottery](https://blendswap.com/blend/28661)*, that is licensed under [Creative Commons 0](https://creativecommons.org/share-your-work/public-domain/cc0/).

Head to the next page to take a look at the architecture that you will deploy.
