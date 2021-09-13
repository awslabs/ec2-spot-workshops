#!/bin/bash

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
    -n)
      JOB_NAME=$2
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ "${ACTION}" == "render" ] ; then
  # Download the blender file from S3
  aws s3 cp "${INPUT_URI}" file.blend
  mkdir "${JOB_NAME}"

  # If the env var AWS_BATCH_JOB_ARRAY_INDEX is empty, this is a single job
  # Render from start to end
  if [[ -z "${AWS_BATCH_JOB_ARRAY_INDEX}" ]]; then
    start_frame=1
    end_frame="${F_PER_JOB}"
  else
    start_frame=$((AWS_BATCH_JOB_ARRAY_INDEX * F_PER_JOB + 1))
    end_frame=$((AWS_BATCH_JOB_ARRAY_INDEX * F_PER_JOB + F_PER_JOB))
  fi

  echo "Rendering frames ${start_frame} to ${end_frame}"
  blender -b file.blend -E CYCLES -o "${JOB_NAME}/" -s "${start_frame}" -e "${end_frame}" -a

  # Upload all the rendered frames to S3
  aws s3 cp --recursive "${JOB_NAME}" "${OUTPUT_URI}/${JOB_NAME}/"
else
  echo "Stitching not yet implemented"
fi
