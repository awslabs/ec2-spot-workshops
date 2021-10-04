---
title: "Creating your Docker image"
date: 2021-07-07T08:51:33Z
weight: 50
---

{{% notice note %}}
If you don't want to create your own Docker image and prefer to use one that has already been created, execute just the following block of code and move to the next page:

```bash
export IMAGE='bpguasch/blender-rendering:latest'
```

{{% /notice %}}


## Amazon Elastic Container Registry

Amazon ECR is a fully managed container registry that makes it easy for developers to share and deploy container images and artifacts. Amazon ECR is integrated with Amazon Elastic Container Service (Amazon ECS),  Amazon Elastic Kubernetes Service (Amazon EKS), and AWS Lambda, simplifying your development to production workflow. Amazon ECR eliminates the need to operate your own container repositories or worry about scaling the underlying infrastructure. Amazon ECR hosts your images in a highly available and scalable architecture, allowing you to deploy containers for your applications reliably.

To learn more about ECR, visit [this web page](https://aws.amazon.com/ecr/).

If you want to learn more about containers, read [this containers deep dive](https://aws.amazon.com/getting-started/deep-dive-containers/).

### Create the repository

Perform the following call to create the repository where you will publish the image. To learn more about this API, see [create-repository CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ecr/create-repository.html).

```bash
export REPOSITORY_NAME="batch-rendering"
export IMAGE="${REPOSITORY_NAME}:latest"

aws ecr create-repository --repository-name "${REPOSITORY_NAME}"
```

**Example output**

```bash
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1xxxxxxxxrepository/batch-rendering",
        "registryId": ":xxxxxxxx:",
        "repositoryName": "batch-rendering",
        "repositoryUri": ":xxxxxxxx:.dkr.ecr.us-east-1.amazonaws.com/batch-rendering",
        "createdAt": "2021-10-04T16:26:24+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
```

### Download image files

To create the Docker image you will  need two files; the DockerFile, which is a text document that contains all the commands a user could call on the command line to assemble an image, and the bash script that will be executed when running the Docker container.

1. Download the Dockerfile from [this link](https://raw.githubusercontent.com/bperezme/ec2-spot-workshops/blender_rendering_using_batch/content/blender-rendering-using-batch/batch-rendering-docker/Dockerfile).
2. Download the script that will be executed when running the Docker container from [this link](https://raw.githubusercontent.com/bperezme/ec2-spot-workshops/blender_rendering_using_batch/content/blender-rendering-using-batch/batch-rendering-docker/render.sh).

Take your time to read and understand both files. In broad strokes, the script *render.sh* does the following:

1. Extract the command arguments and verify that the specified action is either *render* or *stitch*.
2. If the action is render:
  1. Downloads the blender file from S3.
  2. Calculates the slice of frames that has to render (we will se how in more detail when we talk about Batch).
  3. Executes Blender.
  4. Uploads all the frames to S3.
3. If the action is stitch:
  1. Downloads all the frames from S3.
  2. Executes ffmpeg.
  3. Uploads the video to S3.

### Push the image to ECR

{{% notice warning %}}
Execute the rest of the commands from this page **in your laptop's console**, not in CloudShell.
{{% /notice %}}

Navigate to the directory where you have downloaded the files and execute these steps:

1. Retrieve the repository's Uri and separate the top level from the resource:

    ```bash
    export REPOSITORY_NAME="batch-rendering"
    export IMAGE="${REPOSITORY_NAME}:latest"

    export REPOSITORY_URI=$(aws ecr describe-repositories --repository-names "${REPOSITORY_NAME}" | jq -r '.repositories[0].repositoryUri')

    export IFS="/"
    read -a repoUriComponents <<< "${REPOSITORY_URI}"
    ```

1. Retrieve an authentication token and authenticate your Docker client to your registry.

    ```bash
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${repoUriComponents[0]}"
    ```

2. Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html).

    ```bash
    docker build -t batch-rendering .
    ```

3. Tag your image so you can push the image to this repository.

    ```bash
    docker tag "${IMAGE}" "${REPOSITORY_URI}:latest"
    ```

4. Push the image to your newly created AWS repository.

    ```bash
    docker push "${REPOSITORY_URI}:latest"
    ```

You are now done with the container part. Next, you will configure some environment variables needed to create resources in Batch.
