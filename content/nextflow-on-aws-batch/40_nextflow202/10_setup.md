---
title: "Configure Nextflow"
chapter: false
weight: 10
---

## Update Configuration

Now that we have created queues and compute environments, we can wire them into Nextflow.

```bash
cd ~/environment/nextflow-tutorial/
cat > $HOME/.nextflow/config  << EOF
profiles {
  standard {
    process.container = '${RNASEQ_REPO_URI}:${IMG_TAG}'
    docker.enabled = true
  }

  batch {
    aws.region = '${AWS_REGION}'
    process.container = '${RNASEQ_REPO_URI}:${IMG_TAG}'
    process.executor = 'awsbatch'
    process.queue = 'job-queue'
  }
}
EOF
```

Nextflow will evaluate a `nextflow.config` file next to the script we are executing (which would be the file in the current directory) and also fall back to `$HOME/.nextflow/config` for additional configuration. As we are going to use the latter one when using AWS Batch squared we are changing both.
Thus, we are going to change the nextflow configuration files.

Please make sure to **copy the complete image name (registry+name+tag) into your clipboard** for later use.

## Create S3 Bucket

We already have a S3 bucket that keeps the results `BUCKET_NAME_RESULTS`.

```bash
$ echo ${BUCKET_NAME_RESULTS}
nextflow-spot-batch-result-20033-1587976463
```

When running job in a batch environment hte intermediate files are stored within a S3 bucket so that work can be picked up if it gets interrupted.

```bash
export BUCKET_NAME_TEMP=nextflow-spot-batch-temp-${RANDOM}-$(date +%s)
aws --region ${AWS_REGION} s3 mb s3://${BUCKET_NAME_TEMP}
aws s3api put-bucket-tagging --bucket ${BUCKET_NAME_TEMP} --tagging="TagSet=[{Key=nextflow-workshop,Value=true}]"
echo ${BUCKET_NAME_TEMP}
```
