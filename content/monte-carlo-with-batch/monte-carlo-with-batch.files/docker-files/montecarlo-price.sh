#!/bin/bash

parse_arguments() {
  # Parses the command line arguments and stores the values in global variables.

  ACTION=$1
  
  if [ "${ACTION}" != "price" ] && [ "${ACTION}" != "merge" ] ; then
    echo $0 ": Unrecognised action " ${ACTION}
    exit 2
  fi
  echo "Action:" $ACTION

  while (( "$#" )); do
    case "$1" in
      -b)
        BUCKET=$2
        echo "Bucket: " $BUCKET
        shift
        ;;
      -k)
        KEY=$2
        echo "Key: " $KEY
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
}

price()
{
    # select the specific row from the s3 file using S3 SELECT
    aws s3api select-object-content --bucket $BUCKET --key $KEY --expression "SELECT * FROM S3Object[*].Positions[${AWS_BATCH_JOB_ARRAY_INDEX}]" --expression-type SQL --input-serialization '{"JSON": {"Type": "Document"}, "CompressionType": "NONE"}' --output-serialization '{"JSON": {}}' "output.json"

    notional=$(jq '.notional' output.json)
    strike=$(jq '.strike' output.json)
    barrier=$(jq '.barrier' output.json)
    #echo python3 Autocallable.Note.py $notional $strike $barrier
    echo $notional $strike $barrier
    rm output.json
}

merge()
{
    echo "hello"   
}


echo Your container args are "$@"
parse_arguments "$@"
if [ "${ACTION}" == "price" ] ; then
  if [ -z "${AWS_BATCH_JOB_ARRAY_INDEX}" ];
  then
    echo "Setting AWS_BATCH_JOB_ARRAY_INDEX to 0 because value not found"
    AWS_BATCH_JOB_ARRAY_INDEX=0
  fi
  price
else
  merge
fi


