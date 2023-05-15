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
    # select the specific row from the s3 file using S3 SELECT
    aws s3api select-object-content --bucket $BUCKET --key $KEY --expression "SELECT * FROM S3Object[*].Positions[${AWS_BATCH_JOB_ARRAY_INDEX}]" --expression-type SQL --input-serialization '{"JSON": {"Type": "Document"}, "CompressionType": "NONE"}' --output-serialization '{"JSON": {}}' "output.json"

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


