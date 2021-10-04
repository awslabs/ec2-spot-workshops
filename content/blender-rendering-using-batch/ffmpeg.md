---
title: "FFmpeg"
date: 2021-07-07T08:51:33Z
weight: 30
---

## Overview

FFmpeg is a free and open-source multimedia framework able to decode, encode, transcode, mux, demux, stream, filter and play loads of file formats. One of the framework components is the command line tool ffmpeg, the one you will use to implement the stitching job. You can learn more about the project in [this web page](https://www.ffmpeg.org/about.html).

### SlideShow

To concatenate multiple images and make a video out of them, you will use what in FFmpeg's wiki is referred to as [*SlideShow*](https://trac.ffmpeg.org/wiki/Slideshow). When you launch the stitching job, the Docker image that you create will execute ffmpeg from the command line and pass it some arguments needed to create the video. The command that will be executed is the following:

```bash
ffmpeg -i <input_path> <output_path>
```
