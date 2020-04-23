---
title: "Configure Nextflow"
chapter: false
weight: 10
---

## Update Configuration

Now that we have created queues and compute environments, we can wire them into Nextflow.

```
cat << \EOF > $HOME/.nextflow/config
profiles {
  standard {
    process.container = 'nextflow/rnaseq-nf'
    docker.enabled = true
  }

  batch {
    aws.region = 'us-east-1'
    process.executor = 'awsbatch'
    process.queue = 'job-queue'
  }
}
EOF
sed -i -e "s/aws.region =.*/aws.region = '${AWS_REGION}'/" $HOME/.nextflow/config
```


## Create S3 Bucket

```
export BUCKET_NAME=nextflow-spot-batch--${RANDOM}-$(date +%s)
aws --region ${AWS_REGION} s3 mb s3://${BUCKET_NAME}
export BUCKET_NAME_TEMP=nextflow-spot-batch-temp-${RANDOM}-$(date +%s)
aws --region ${AWS_REGION} s3 mb s3://${BUCKET_NAME_TEMP}
```