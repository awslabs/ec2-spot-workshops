#!/bin/bash

parse_arguments() {
  # Parses the command line arguments and stores the values in global variables.

  ACTION=$1

  if [ "${ACTION}" != "render" ] && [ "${ACTION}" != "stitch" ] ; then
    echo "Unrecognised action"
    exit 2
  fi

  while (( "$#" )); do
    case "$1" in
      -i)
        INPUT_URI=$2
        shift
        ;;
      -o)
        OUTPUT_URI=$2
        shift
        ;;
      -f)
        F_PER_JOB=$2
        shift
        ;;
      -t)
        TOTAL_FRAMES=$2
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
}

calculate_render_frame_range() {
  # Calculates the start frame and end frame a job has to render
  # using the value of the env var AWS_BATCH_JOB_ARRAY_INDEX

  # If the env var AWS_BATCH_JOB_ARRAY_INDEX is empty, this is a single job. Render from start to end
  if [[ -z "${AWS_BATCH_JOB_ARRAY_INDEX}" ]]; then
    start_frame=1
    end_frame="${F_PER_JOB}"
  # Otherwise use the array index to calculate the corresponding frame slice
  else
    start_frame=$((AWS_BATCH_JOB_ARRAY_INDEX * F_PER_JOB + 1))
    end_frame=$((AWS_BATCH_JOB_ARRAY_INDEX * F_PER_JOB + F_PER_JOB))
  fi
}

render() {
  # Pipeline that is executed when this script is told to render.

  # Download the blender file from S3
  aws s3 cp "${INPUT_URI}" file.blend

  # Calculate start frame and end frame
  calculate_render_frame_range

  # Start the rendering process
  mkdir frames
  echo "Rendering frames ${start_frame} to ${end_frame}"
  blender -b file.blend -E CYCLES -o "frames/" -s "${start_frame}" -e "${end_frame}" -a

  # Upload all the rendered frames to a folder in S3
  aws s3 cp --recursive "frames" "${OUTPUT_URI}/frames"
}

stitch() {
  # Pipeline that is executed when this script is told to stitch.

  # Download the frames from S3
  mkdir frames
  aws s3 cp --recursive "${INPUT_URI}/frames" frames/

  # Start the stitching process
  ffmpeg -i frames/%04d.png output.mp4

  # Upload the output video to S3
  aws s3 cp output.mp4 "${OUTPUT_URI}/output.mp4"
}

parse_arguments "$@"

if [ "${ACTION}" == "render" ] ; then
  render
else
  stitch
fi
