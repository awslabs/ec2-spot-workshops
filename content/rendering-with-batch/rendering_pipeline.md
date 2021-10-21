---
title: "Rendering pipeline"
date: 2021-09-06T08:51:33Z
weight: 20
---

![Rendering pipeline](/images/rendering-with-batch/pipeline.png)

## Overview

The rendering pipeline that we will implement has two differentiated jobs: rendering job and stitching job. Rendering is the process of generating an image from a 2D or 3D model, whereas stitching is the process of combining multiple images to produce a video. Each of them will be carried out using different software; to render we will use Blender and to stitch we will use FFmpeg.

## Blender: rendering job

Blender is the free and open source 3D creation suite. It supports the entirety of the 3D pipeline—modeling, rigging, animation, simulation, rendering, compositing and motion tracking, video editing and 2D animation pipeline. To learn more about its features, you can visit [this web page](https://www.blender.org/features/).

In this workshop we will use its [rendering capabilities](https://www.blender.org/features/rendering/) to render an already created file.

### Command line rendering

You can launch Blender's rendering capabilities from the command line. This allows to access Blender remotely and reduce compute resource consumption since it does not need to load a graphical interface. The Docker image that you will create will do exactly this; run a bash script that will execute Blender and pass to it some arguments needed to render a specific slice of frames. The command that will be executed is the following:

```bash
blender -b <input_path> -E CYCLES -o <output_path> -s <start_frame> -e <end_frame> -a
```

The arguments mean the following:

- **-b**: tells Blender to render in the background, without graphical interface.
- **-E**: specifies what engine to use when rendering. You can learn more about Blender's CYCLES engine [here](https://www.blender.org/features/rendering/#cycles).
- **-o**: specifies the output path.
- **-s**: specifies the starting frame (integer value).
- **-e**: specifies the ending frame (integer value).
- **-a**: tells Blender to render from <start_frame> to <end_frame>, both inclusive.

If you want to learn more about Blender's command line rendering, visit [this web page](https://docs.blender.org/manual/en/latest/advanced/command_line/render.html). Additionally, you can check all the arguments it accepts [here](https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html).

### Gathering a Blender file

We will use a Blender file from [BlendSwap](https://blendswap.com/categories). In that web page, Blender-powered 3D artists can share, exchange, collaborate, and learn from other artists in the community. We will work with [the same file](https://blendswap.com/blend/28661) that was rendered to generate the animation that you've seen in the landing page. That file was created by [Prokster](https://blendswap.com/profile/1012752) and is licensed under [Creative Commons 0](https://creativecommons.org/share-your-work/public-domain/cc0/). If you want to use a different one, feel free to do so! Just take into account the following:

- The file must be configured to render the frames as .png files.
- The more frames it has, the more compute resources you will need to render it thus impacting the costs of running the workshop.

Run the following command to download the file:

```bash
export BLEND_FILE_NAME="blendfile.blend"
curl "https://github.com/bperezme/ec2-spot-workshops/raw/blender_rendering_using_batch/content/blender-rendering-using-batch/pottery.blend" -o "${BLEND_FILE_NAME}"
```

Execute the following commands to create an S3 bucket and upload to it the Blender file:

```bash
export BUCKET_NAME=("batch-rendering-"$(uuidgen))
aws s3api create-bucket --bucket "${BUCKET_NAME}"
aws s3api put-object --bucket "${BUCKET_NAME}" --key "${BLEND_FILE_NAME}" --body "${BLEND_FILE_NAME}"
```

## FFmpeg: stitching job

FFmpeg is a free and open-source multimedia framework able to decode, encode, transcode, mux, demux, stream, filter and play loads of file formats. One of the framework components is the command line tool ffmpeg, the one you will use to implement the stitching job. You can learn more about the project in [this web page](https://www.ffmpeg.org/about.html).

### SlideShow

To concatenate multiple images and make a video out of them, you will use what in FFmpeg's wiki is referred to as [*SlideShow*](https://trac.ffmpeg.org/wiki/Slideshow). When you launch the stitching job, the Docker image that you create will execute ffmpeg from the command line and pass it some arguments needed to create the video. The command that will be executed is the following:

```bash
ffmpeg -i <input_path> <output_path>
```
