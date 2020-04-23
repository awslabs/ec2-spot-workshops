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
export REPO_URI=$(aws ecr create-repository --repository-name nextflow-head |jq -r '.repository.repositoryUri')
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
set -x
PIPELINE_URL=${PIPELINE_URL:-https://github.com/seqeralabs/nextflow-tutorial.git}
NF_SCRIPT=${NF_SCRIPT:-main.nf}
NF_OPTS=${NF_OPTS}

if [[ "${PIPELINE_URL}" =~ ^s3://.* ]]; then
    aws s3 cp --recursive ${PIPELINE_URL} /scratch
else
    # Assume it is a git repository
    git clone ${PIPELINE_URL} /scratch
fi

cd /scratch

nextflow run ${NF_SCRIPT} -profile batch ${NF_OPTS}

EOF
chmod +x entrypoint.sh
```
Docker image holding nextflow to run the execution task.

```
export IMG_TAG=$(date +%F).1
```

```
cd ~/environment/nextflow-tutorial/docker
cp ~/.nextflow/config config
cat << \EOF > Dockerfile
FROM amazoncorretto:8

RUN curl -s https://get.nextflow.io | bash \
 && mv nextflow /usr/local/bin/
RUN yum install -y git
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
VOLUME ["/scratch"]
CMD ["/usr/local/bin/entrypoint.sh"]
COPY config /root/.nextflow/config
EOF
docker build -t $REPO_URI:${IMG_TAG} .
docker push $REPO_URI:${IMG_TAG}
```
