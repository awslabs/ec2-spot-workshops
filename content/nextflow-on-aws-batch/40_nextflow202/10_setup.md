---
title: "Configure Nextflow"
chapter: false
weight: 10
---

## Update Configuration

Now that we have created queues and compute environments, we can wire them into Nextflow.

{{% notice info %}}
Please note that we are creating a config that does not hold a container name nor a AWS_REGION. We are going to change those values using `sed`.
{{% /notice %}}

```bash
cd ~/environment/nextflow-tutorial/
cat << \EOF > $HOME/.nextflow/config
profiles {
  standard {
    process.container = ''
    docker.enabled = true
  }

  batch {
    aws.region = ''
    process.container = ''
    process.executor = 'awsbatch'
    process.queue = 'job-queue'
  }
}
EOF
```
Nextflow will evaluate a `nextflow.config` file next to the script we are executing (which would be the file in the current directory) and also fall back to `$HOME/.nextflow/config` for additional configuration. As we are going to use the latter one when using AWS Batch squared we are changing both.
Thus, we are going to change the nextflow configuration files.

```bash
sed -i -e "s/aws.region =.*/aws.region = '${AWS_REGION}'/g" $HOME/.nextflow/config
sed -i -e "s#process.container =.*#process.container = '${RNASEQ_REPO_URI}:${IMG_TAG}'#g"  $HOME/.nextflow/config nextflow.config
```


Please make sure to **copy the complete image name (registry+name+tag) into your clipboard** for later use.

## Create S3 Bucket

```bash
echo ${BUCKET_NAME_RESULTS}
export BUCKET_NAME_TEMP=nextflow-spot-batch-temp-${RANDOM}-$(date +%s)
aws --region ${AWS_REGION} s3 mb s3://${BUCKET_NAME_TEMP}
aws s3api put-bucket-tagging --bucket ${BUCKET_NAME_TEMP} --tagging="TagSet=[{Key=nextflow-workshop,Value=true}]"
echo ${BUCKET_NAME_TEMP}
```
