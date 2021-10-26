---
title: "Creating your Docker image"
date: 2021-07-07T08:51:33Z
weight: 50
---

The first step to implement the rendering pipeline is to generate a Docker image with the script that will run Blender and FFmpeg. As you will see later, this image will be run by Batch when running jobs. You are going to host that image in Amazon Elastic Container Registry.

## Amazon Elastic Container Registry

Amazon ECR is a fully managed container registry that makes it easy for developers to share and deploy container images and artifacts. Amazon ECR is integrated with Amazon Elastic Container Service (Amazon ECS),  Amazon Elastic Kubernetes Service (Amazon EKS), and AWS Lambda, simplifying your development to production workflow. Amazon ECR eliminates the need to operate your own container repositories or worry about scaling the underlying infrastructure. Amazon ECR hosts your images in a highly available and scalable architecture, allowing you to deploy containers for your applications reliably.

To learn more about ECR, visit [this web page](https://aws.amazon.com/ecr/).

If you want to learn more about containers, read [this containers deep dive](https://aws.amazon.com/getting-started/deep-dive-containers/).

### Download image files

To create the Docker image you will  need two files; the DockerFile, which is a text document that contains all the commands a user could call on the command line to assemble an image, and the bash script that will be executed when running the Docker container.

1. Download the *Dockerfile* executing this command:

    ```bash
    wget "https://raw.githubusercontent.com/bperezme/ec2-spot-workshops/blender_rendering_using_batch/content/rendering-with-batch/docker-files/Dockerfile"
    ```

2. Download the *render.sh* script that will be executed when running the Docker container executing this command:

    ```bash
    wget "https://raw.githubusercontent.com/bperezme/ec2-spot-workshops/blender_rendering_using_batch/content/rendering-with-batch/docker-files/render.sh"
    ```

### Push the image to ECR

1. Retrieve the repository's Uri and separate the top level from the resource:

    ```bash
    export REPOSITORY_DATA=$(aws ecr describe-repositories --repository-names "${RepositoryName}")
    export REPOSITORY_URI=$((echo $REPOSITORY_DATA) | jq -r '.repositories[0].repositoryUri')
    export REGISTRY_ID=$((echo $REPOSITORY_DATA) | jq -r '.repositories[0].registryId')
    export IMAGE="${REPOSITORY_URI}:latest"
    ```

1. Retrieve an authentication token and authenticate your Docker client to your registry.

    ```bash
    aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin "${REGISTRY_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
    ```

2. Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html).

    ```bash
    docker build -t "${RepositoryName}" .
    ```

3. Tag your image so you can push the image to this repository.

    ```bash
    docker tag "${RepositoryName}:latest" "${IMAGE}"
    ```

4. Push the image to your newly created AWS repository.

    ```bash
    docker push "${IMAGE}"
    ```

You are now done with the container part. Next, you will configure some environment variables needed to create resources in Batch.


### Optional: understanding the render.sh script

In broad strokes, the script *render.sh* does the following:

1. **Method parse_arguments**: extracts the command arguments and verify that the specified action is either *render* or *stitch*.
2. **Method render** (if the action is render):
  1. Downloads the blender file from S3.
  2. Calculates the slice of frames that has to render (we will se how in more detail when we talk about Batch).
  3. Executes Blender.
  4. Uploads all the frames to S3.
3. **Method stitch** (if the action is stitch):
  1. Downloads all the frames from S3.
  2. Executes ffmpeg.
  3. Uploads the video to S3.
