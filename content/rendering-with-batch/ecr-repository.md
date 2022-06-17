---
title: "Creating your Docker image"
date: 2021-07-07T08:51:33Z
weight: 50
---

The first step to implement the rendering pipeline is to generate a Docker image with the script that will run Blender and FFmpeg. This container image will be used by AWS Batch when running jobs. You are going to host that image in Amazon Elastic Container Registry.

## Amazon Elastic Container Registry

Amazon ECR is a fully managed container registry that makes it easy for developers to share and deploy container images and artifacts. Amazon ECR is integrated with Amazon Elastic Container Service (Amazon ECS),  Amazon Elastic Kubernetes Service (Amazon EKS), and AWS Lambda, simplifying your development to production workflow. Amazon ECR eliminates the need to operate your own container repositories or worry about scaling the underlying infrastructure. Amazon ECR hosts your images in a highly available and scalable architecture, allowing you to deploy containers for your applications reliably.

To learn more about ECR, visit [this web page](https://aws.amazon.com/ecr/).

If you want to learn more about containers, read [this containers deep dive](https://aws.amazon.com/getting-started/deep-dive-containers/).

### Download image files

To create the Docker image you will need two files; the DockerFile, which is a text document that contains all the commands a user could call on the command line to assemble an image, and the bash script that will be executed when running the Docker container.

Download both files executing these commands:

```
wget "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/rendering-with-batch/rendering-with-batch.files/docker-files/Dockerfile"
wget "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/rendering-with-batch/rendering-with-batch.files/docker-files/render.sh"
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

2. Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html). **The execution if this step might take a couple of minutes**.

    ```
    docker build -t "${IMAGE}" .
    ```

3. Push the image to ECR .

    ```
    docker push "${IMAGE}"
    ```

You are now done with the container part. Next, you will configure some environment variables needed to create resources in AWS Batch.

## Optional: understanding the render.sh script

When we send a batch job, the container that we just created will be executed. The entry point of the container is the bash script `render.sh`. The script just takes
a few arguments that AWS Batch will pass to each task and does run either blender when an environment variable named `ACTION` is set to `render` or or ffmpeg when is set to `stitch`.

The following section describes the `render.sh` script in more detail. You don't need to go through this to run this workshop, but if you are interested in fully understanding how Blender and FFmpeg are called it will give you a clear description.


#### Method parse_argument:

Reads the environment variable `ACTION` and decides from it what's the type of job to run, either render or stitch. It also takes other arguments such as the the *input*, *output*

{{< highlight go "linenos=table, linenostart=6" >}}
  ACTION=$1

  if [ "${ACTION}" != "render" ] && [ "${ACTION}" != "stitch" ] ; then
    echo "Unrecognised action"
    exit 2
  fi

{{< / highlight >}}


#### Method render:

1. Downloads the blender file from S3.

    {{< highlight go "linenos=table, linenostart=57" >}}
aws s3 cp "${INPUT_URI}" file.blend
{{< / highlight >}}

2. Calculates the slice of frames that has to render (we will se how in more detail when we talk about AWS Batch).

    {{< highlight go "linenos=table, linenostart=43" >}}
if [[ -z "${AWS_BATCH_JOB_ARRAY_INDEX}" ]]; then
  start_frame=1
  end_frame="${F_PER_JOB}"
else
  start_frame=$((AWS_BATCH_JOB_ARRAY_INDEX * F_PER_JOB + 1))
  end_frame=$((AWS_BATCH_JOB_ARRAY_INDEX * F_PER_JOB + F_PER_JOB))
fi
{{< / highlight >}}

3. Executes Blender.

    {{< highlight go "linenos=table, linenostart=63, hl_lines=3" >}}
mkdir frames
echo "Rendering frames ${start_frame} to ${end_frame}"
blender -b file.blend -E CYCLES -o "frames/" -s "${start_frame}" -e "${end_frame}" -a
{{< / highlight >}}

4. Uploads all the frames to S3.

    {{< highlight go "linenos=table, linenostart=68" >}}
aws s3 cp --recursive "frames" "${OUTPUT_URI}/frames"
{{< / highlight >}}

### Method stitch:

1. Downloads all the frames from S3.

    {{< highlight go "linenos=table, linenostart=75" >}}
mkdir frames
aws s3 cp --recursive "${INPUT_URI}/frames" frames/
{{< / highlight >}}

2. Executes FFmpeg.

    {{< highlight go "linenos=table, linenostart=79" >}}
ffmpeg -i frames/%04d.png output.mp4
{{< / highlight >}}

3. Uploads the video to S3.

    {{< highlight go "linenos=table, linenostart=82" >}}
aws s3 cp output.mp4 "${OUTPUT_URI}/output.mp4"
{{< / highlight >}}
