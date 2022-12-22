---
title: "Creating your Docker image"
date: 2021-07-07T08:51:33Z
weight: 50
---


The first step to implement the risk pipeline is to generate a Docker image with the script that will run our QuantLib pricing script. This container image will be used by AWS Batch when running jobs. You are going to host that image in Amazon Elastic Container Registry.

## Amazon Elastic Container Registry

Amazon ECR is a fully managed container registry that makes it easy for developers to share and deploy container images and artifacts. Amazon ECR is integrated with Amazon Elastic Container Service (Amazon ECS),  Amazon Elastic Kubernetes Service (Amazon EKS), and AWS Lambda, simplifying your development to production workflow. Amazon ECR eliminates the need to operate your own container repositories or worry about scaling the underlying infrastructure. Amazon ECR hosts your images in a highly available and scalable architecture, allowing you to deploy containers for your applications reliably.

To learn more about ECR, visit [this web page](https://aws.amazon.com/ecr/).

If you want to learn more about containers, read [this containers deep dive](https://aws.amazon.com/getting-started/deep-dive-containers/).

### Download image files

To create the Docker image you will need three files: the DockerFile, which is a text document that contains all the commands a user could call on the command line to assemble an image, a requirements file for Python dependencies, and the bash script that will be executed when running the Docker container.

Download the files by executing these commands:

```
wget "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/monte-carlo-with-batch/monte-carlo-with-batch.files/docker-files/Dockerfile"
wget "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/monte-carlo-with-batch/monte-carlo-with-batch.files/docker-files/requirements.txt"
wget "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/monte-carlo-with-batch/monte-carlo-with-batch.files/docker-files/montecarlo-price.sh"
```

### Push the image to ECR

1. Retrieve the repository's Uri and registry Id:

    ```
    export REPOSITORY_DATA=$(aws ecr describe-repositories --repository-names "${RepositoryName}")
    export REPOSITORY_URI=$((echo $REPOSITORY_DATA) | jq -r '.repositories[0].repositoryUri')
    export REGISTRY_ID=$((echo $REPOSITORY_DATA) | jq -r '.repositories[0].registryId')
    export IMAGE="${REPOSITORY_URI}:latest"
    echo "Repository Uri: ${REPOSITORY_URI}"
    echo "Registry Id: ${REGISTRY_ID}"
    ```

1. Retrieve an authentication token and authenticate your Docker client to your registry.

    ```
    aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin "${REGISTRY_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
    ```

2. Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html). **The execution of this step might take a couple of minutes**.

    ```
    docker build -t "${IMAGE}" .
    ```

3. Push the image to ECR .

    ```
    docker push "${IMAGE}"
    ```

You are now done with the container part. Next, you will configure some environment variables needed to create resources in AWS Batch.


