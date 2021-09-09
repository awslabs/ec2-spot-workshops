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
    *)
      shift
      ;;
  esac
done

aws s3 cp "${INPUT_URI}" ./tmp.blend
blender -b ./tmp.blend -o ./ -s 1 -e "${F_PER_JOB}"
aws s3 cp ./*.png ${OUTPUT_URI}
