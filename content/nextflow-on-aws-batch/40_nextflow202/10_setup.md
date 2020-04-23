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
    workDir = BUCKET
    aws.region = 'us-east-1'
    aws.batch.cliPath = '/home/ec2-user/miniconda/bin/aws'
    process.executor = 'awsbatch'
    process.queue = 'job-queue'
  }
}
EOF
```

## Create S3 Bucket

```
export BUCKET_NAME=nextflow-spot-batch--${RANDOM}-$(date +%s)
aws --region ${AWS_REGION} s3 mb s3://${BUCKET_NAME}
sed -i -e "s#workDir =.*#workDir = 's3://${BUCKET_NAME}'#" $HOME/.nextflow/config
sed -i -e "s/aws.region =.*/aws.region = '${AWS_REGION}'/" $HOME/.nextflow/config
```