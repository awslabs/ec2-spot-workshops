#!/bin/bash

parse_arguments() {
  # Parses the command line arguments and stores the values in global variables.

  ACTION=$1
  
  if [ "${ACTION}" != "price" ] && [ "${ACTION}" != "merge" ] ; then
    echo $0 ": Unrecognised action " ${ACTION}
    exit 2
  fi

  while (( "$#" )); do
    case "$1" in
      -b)
        BUCKET=$2
        shift
        ;;
      -k)
        KEY=$2
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
    pv=$(python3 Autocallable.Note.py $notional $strike $barrier)
    rm output.json
    
    filename="result_${AWS_BATCH_JOB_ARRAY_INDEX}"
    echo $pv >${filename}
    aws s3 cp ${filename} "${OUTPUT_URI}/${AWS_BATCH_JOB_ID}/${filename}"
    rm ${filename}
    
}

merge()
{
    echo "hello"   
}


parse_arguments "$@"
if [ "${ACTION}" == "price" ] ; then
  if [ -z "${AWS_BATCH_JOB_ARRAY_INDEX}" ];
  then
    AWS_BATCH_JOB_ARRAY_INDEX=0
  fi
  price
else
  merge
fi


