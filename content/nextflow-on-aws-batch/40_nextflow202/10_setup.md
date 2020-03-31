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
    aws.batch.cliPath = '/home/ec2-user/miniconda/bin/aws'
    process.executor = 'awsbatch'
    process.queue = 'job-queue'
  }
}
EOF
```

## Create S3 Bucket

```
export BUCKET_NAME=nextflow-spot-batch-$(date +%s)
aws s3 mb s3://${BUCKET_NAME}
```

