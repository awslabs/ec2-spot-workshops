---
title: "Nextflow Docker Image"
chapter: false
weight: 30
---



To check our setup we will run nextflow on the Cloud9 instance, submitting jobs to AWS Batch.

![](/images/nextflow-on-aws-batch/nextflow-workshop-arch.png)


## ECR 

### Login

```
export AWS_DEFAULT_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
$(aws ecr get-login --no-include-email)
```

### Create Repo

```
aws ecr create-repository --repository-name nextflow-head 
```

Extract the URI and set an environment variable.
```
export REPO_URI=$(aws ecr describe-repositories --repository-names=nextflow-head |jq -r '.repositories[0].repositoryUri')
echo $REPO_URI
```
## Create Docker Image

### Entrypoint

The entrypoint script will consume the link to an S3 bucket or a git repository from which to download the Nextflow pipeline and executes it.

```
cd ~/environment/nextflow-tutorial
mkdir -p docker
cd docker
cat << \EOF > entrypoint.sh
#!/bin/bash
set -ex
PIPELINE_URL=${PIPELINE_URL:-https://github.com/seqeralabs/nextflow-tutorial.git}
NF_SCRIPT=${NF_SCRIPT:-main.nf}
NF_OPTS=${NF_OPTS}

AWS_REGION=$(curl --silent ${ECS_CONTAINER_METADATA_URI} |jq -r '.Labels["com.amazonaws.ecs.task-arn"]' |awk -F: '{print $4}')

if [[ "${PIPELINE_URL}" =~ ^s3://.* ]]; then
    aws s3 cp --recursive ${PIPELINE_URL} /scratch
else
    # Assume it is a git repository
    git clone ${PIPELINE_URL} /scratch
fi

cd /scratch
BUCKET_TEMP_NAME=nextflow-spot-batch-temp-${AWS_BATCH_JOB_ID}
aws --region ${AWS_REGION} s3 mb s3://${BUCKET_TEMP_NAME}
nextflow run ${NF_SCRIPT} -profile batch -bucket-dir s3://${BUCKET_TEMP_NAME} ${NF_OPTS} --output s3://${BUCKET_NAME}/${AWS_BATCH_JOB_ID}
EOF
chmod +x entrypoint.sh
```

Following container best practice we are using a unique contianer image tag and not just `:latest`.

```
export IMG_TAG=$(date +%F).1
```

Now, we build and push the Docker image holding nextflow to run the execution task.

```
# make sure we are in the right directory and have the correct NF config
cd ~/environment/nextflow-tutorial/docker
cp ~/.nextflow/config config
# write DOckerfile
cat << \EOF > Dockerfile
FROM amazoncorretto:8

RUN curl -s https://get.nextflow.io | bash \
 && mv nextflow /usr/local/bin/
RUN yum install -y git python-pip curl jq
RUN pip install --upgrade awscli
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
VOLUME ["/scratch"]
CMD ["/usr/local/bin/entrypoint.sh"]
COPY config /root/.nextflow/config
EOF
# build and push the docker image
docker build -t $REPO_URI:${IMG_TAG} .
docker push $REPO_URI:${IMG_TAG}
```

Please make sure to **copy the complete image name (registry+name+tag) into your clipboard** for later use.