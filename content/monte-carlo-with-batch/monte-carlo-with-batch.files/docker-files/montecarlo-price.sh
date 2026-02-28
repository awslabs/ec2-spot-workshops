#!/bin/bash 

parse_arguments() {
  # Parses the command line arguments and stores the values in global variables.

  ACTION=$1
  
  if [ "${ACTION}" != "price" ] ; then
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
      -o)
        OUTPUT_URI=$2
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
    # Download the entire JSON file from S3
    aws s3 cp s3://$BUCKET/$KEY output_full.json

    # Use jq to extract the specific position based on AWS_BATCH_JOB_ARRAY_INDEX
    # This simulates the S3 Select functionality by processing locally
    jq ".positions[${AWS_BATCH_JOB_ARRAY_INDEX}]" output_full.json > output.json

    # Clean up the full downloaded file
    rm output_full.json

    # extract the parameters for this risk run from the JSON returned by S3 Select
    echo "output.json: "
    cat output.json

    notional=$(jq '.notional' output.json)
    strike=$(jq '.strike' output.json)
    barrier=$(jq '.barrier' output.json)

    rm output.json

    # execute the Python script that calculates the PV based on these inputs
    pv=$(python3 Autocallable.Note.py $notional $strike $barrier)

    # create a filename based on our index in the batch job array
    filename="result_${AWS_BATCH_JOB_ARRAY_INDEX}"

    # create a simple JSON output of strike and PV, for later aggregation
    jq -n --arg st "$strike" --arg pv "$pv" '{strike: $st, pv: $pv}' >${filename}

    # upload the resulting file to S3

    echo "filename: " $filename
    echo "output_uri: " $OUTPUT_URI
    echo "aws_batch_job_id: " $AWS_BATCH_JOB_ID

    aws s3 cp ${filename} "${OUTPUT_URI}/${AWS_BATCH_JOB_ID}/${filename}"
    rm ${filename}
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


