---
title: "Create RNA-Seq Docker Image"
chapter: false
weight: 05
---

## Build RNA-Seq Image

In order to run the RNA-Seq pipeline while using the AWS-Cli incapsulated within the image, we are going to derive an image from the tutorial image.

### ECR

#### Login

```bash
export AWS_DEFAULT_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
$(aws ecr get-login --no-include-email)
```

#### Create Repo

```bash
aws ecr create-repository --tags Key=nextflow-workshop,Value=true --repository-name nextflow-rna-seq
```

Extract the URI and set an environment variable.

```bash
export RNASEQ_REPO_URI=$(aws ecr describe-repositories --repository-names=nextflow-rna-seq |jq -r '.repositories[0].repositoryUri')
echo $RNASEQ_REPO_URI
```

Following container best practice we are using a unique contianer image tag and not just `:latest`.

```bash
export IMG_TAG=$(date +%F).1
```

Now, we create a Dockerfile that installs the aws-cli using pip in a separat directory and in a subsequent stage copies the path without installing the dependecies.

```bash
cd ~/environment/nextflow-tutorial
mkdir -p docker/simple
cd ~/environment/nextflow-tutorial/docker/simple
cat << \EOF > Dockerfile
FROM nextflow/rnaseq-nf AS build

RUN apt update \
 && apt install -y python-pip \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --target=/opt/pip awscli

## Using multi-stage to not install python-pip and all dependencies within resulting image
FROM nextflow/rnaseq-nf
ENV PATH=${PATH}:/opt/pip/bin
ENV PYTHONPATH=/opt/pip
COPY --from=build /opt/pip/ /opt/pip/
EOF
```

{{% notice info %}}
If you are not familiar with [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds), please take a moment to let it sink in. :)
What we are doing with the above Dockerfile is creating a `build` stage that installs all the dependencies to run `pip install` and subsequently installing `awscli`. Notice, that we use a different target.
Without that pip would install everything in the already masive `/opt/conda/` directory. In the final stage we are setup up the environment to pick up `aws` and its libraries.
{{% /notice %}}

Let's go ahead and build that image.

```bash
docker build -t $RNASEQ_REPO_URI:${IMG_TAG} .
```

The output should look like this:

```bash
$ docker build -t $RNASEQ_REPO_URI:${IMG_TAG} .
Sending build context to Docker daemon  2.048kB
Step 1/7 : FROM nextflow/rnaseq-nf AS build
 ---> 7ed5de31bd4d
Step 2/7 : RUN apt update  && apt install -y python-pip  && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 127354965638
Step 3/7 : RUN pip install --target=/opt/pip awscli
 ---> Using cache
 ---> 7a54bb0f800f
Step 4/7 : FROM nextflow/rnaseq-nf
 ---> 7ed5de31bd4d
Step 5/7 : ENV PATH=${PATH}:/opt/pip/bin
 ---> Using cache
 ---> 71c732034664
Step 6/7 : ENV PYTHONPATH=/opt/pip
 ---> Using cache
 ---> b036494dfcae
Step 7/7 : COPY --from=build /opt/pip/ /opt/pip/
 ---> Using cache
 ---> 6d8816bb059c
Successfully built 6d8816bb059c
Successfully tagged 470217903628.dkr.ecr.us-east-1.amazonaws.com/nextflow-rna-seq:2020-04-24.1
```

Please make sure to **copy the complete image name (registry+name+tag) into your clipboard** for later use.

Finally, push the image to ECR:

```bash
docker push $RNASEQ_REPO_URI:${IMG_TAG}
```

Output:

```bash
 $ docker push $RNASEQ_REPO_URI:${IMG_TAG}
The push refers to repository [470217903628.dkr.ecr.us-east-1.amazonaws.com/nextflow-rna-seq]
a8dbdc0c687a: Layer already exists
86700d53ba3b: Layer already exists
26763a0357b1: Layer already exists
b24b12a76720: Layer already exists
535e8d4012de: Layer already exists
78db50750faa: Layer already exists
805309d6b0e2: Layer already exists
2db44bce66cd: Layer already exists
2020-04-24.1: digest: sha256:dbfdba0419527cafc64dce52d176d1b1e415f926a270be1efac0c2ba2e113af7 size: 2005
```
