---
title: "Nextflow Docker Image"
chapter: false
weight: 30
---

Now, we are build an image to be used to submit AWS Batch jobs from a headnode Nextflow AWS Batch job; some referr to it as 'AWS Batch Squared'.
![nextflow-workshop-arch](/images/nextflow-on-aws-batch/nextflow-workshop-arch.png)

## ECR

### Create Repo

```bash
aws ecr create-repository --tags Key=nextflow-workshop,Value=true  --repository-name nextflow-head
```

Extract the URI and set an environment variable.

```bash
export REPO_URI=$(aws ecr describe-repositories --repository-names=nextflow-head |jq -r '.repositories[0].repositoryUri')
echo $REPO_URI
```

## Create Docker Image

### Entrypoint

The entrypoint script will consume the link to an S3 bucket or a git repository from which to download the Nextflow pipeline and executes it.

```bash
cd ~/environment/nextflow-tutorial
mkdir -p docker/headless
cd ~/environment/nextflow-tutorial/docker/headless
cat << \EOF > entrypoint.sh
#!/bin/bash
set -ex
PIPELINE_URL=${PIPELINE_URL:-https://github.com/seqeralabs/nextflow-tutorial.git}
NF_SCRIPT=${NF_SCRIPT:-main.nf}
NF_OPTS=${NF_OPTS}

if [[ -z ${AWS_REGION} ]];then
            AWS_REGION=$(curl --silent ${ECS_CONTAINER_METADATA_URI} |jq -r '.Labels["com.amazonaws.ecs.task-arn"]' |awk -F: '{print $4}')
fi

if [[ "${PIPELINE_URL}" =~ ^s3://.* ]]; then
    aws s3 cp --recursive ${PIPELINE_URL} /scratch
else
    # Assume it is a git repository
    git clone ${PIPELINE_URL} /scratch
fi

cd /scratch
echo ">> Remove container from pipeline config if present."
sed -i -e '/process.container/d' nextflow.config

# sanitize BUCKER_NAME
BUCKET_NAME_RESULTS=$(echo ${BUCKET_NAME_RESULTS} |sed -e 's#s3://##')
BUCKET_TEMP_NAME=nextflow-spot-batch-temp-${AWS_BATCH_JOB_ID}
aws --region ${AWS_REGION} s3 mb s3://${BUCKET_TEMP_NAME}

nextflow run ${NF_SCRIPT} -profile batch -bucket-dir s3://${BUCKET_TEMP_NAME} ${NF_OPTS} --output s3://${BUCKET_NAME_RESULTS}/${AWS_BATCH_JOB_ID}
EOF
chmod +x entrypoint.sh
```

Following container best practice we are using a unique contianer image tag and not just `:latest`.

```bash
export IMG_TAG=$(date +%F).1
```

Now, we build and push the Docker image holding nextflow to run the execution task.

```bash
# make sure we are in the right directory and have the correct NF config
cd ~/environment/nextflow-tutorial/docker/headless
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
docker build -t ${REPO_URI}:${IMG_TAG} .
docker push ${REPO_URI}:${IMG_TAG}
echo "IMAGE NAME = ${REPO_URI}:${IMG_TAG}"
echo "BUCKET_NAME_RESULTS = ${BUCKET_NAME_RESULTS}"
```

Please make sure to **copy the complete image name (registry+name+tag) into your clipboard** for later use. You are going to need the `BUCKET_NAME_RESULTS` value as well in the next section.
