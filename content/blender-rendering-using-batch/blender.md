---
title: "Blender"
date: 2021-09-06T08:51:33Z
weight: 20
---

## Overview

Blender is the free and open source 3D creation suite. It supports the entirety of the 3D pipeline—modeling, rigging, animation, simulation, rendering, compositing and motion tracking, video editing and 2D animation pipeline. To learn more about its features, you can visit [this web page](https://www.blender.org/features/).

In this workshop we will use its [rendering capabilities](https://www.blender.org/features/rendering/) to render an already created file.

### Command line rendering

Blender makes it possible to launch its rendering capabilities right from the command line, what allows to access Blender remotely and also reduce compute resource consumption since it does not need to load a user interface. The Docker image that you will create will do exactly this; run a bash script that will execute Blender and pass it some arguments needed to render a specific slice of frames. The command that will be executed is the following:

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

## Gathering a Blender file

We will download a Blender file from [BlendSwap](https://blendswap.com/categories). In that web page, Blender-powered 3D artists can share, exchange, collaborate, and learn from other artists in the community. You can download the same file that was rendered to generate the animation that you've seen in the previous page from [here](https://blendswap.com/blend/28661). If you want to use a different one, feel free to do so! Just take into account the following:

- The file must be configured to render the frames as .png files.
- The more frames it has, the more compute resources you will need to render it thus impacting the costs of running the workshop.

{{% notice note %}}
**Once you have chosen a file, download it from BlendSwap and upload it to an S3 bucket of your choice.**
{{% /notice %}}
