---
title: "Build the Microservice"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

In this section we will be building the application that used to scale our cluster. First, let's download all the assets that we will need to build the application and image. Run the following command. We will use git to download the project and bring all the files needed to build our Monte Carlo microservice application:

```
cd ~/environment
git clone https://github.com/awslabs/ec2-spot-workshops.git
cd ~/environment/ec2-spot-workshops/workshops/karpenter
```

Great. We are now ready to build up our application, compile it first, build the docker image and finally push the image to Amazon ECR.


```
export APP_NAME=monte-carlo-sim
aws ecr get-login-password | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
aws ecr create-repository --repository-name ${APP_NAME}
export MONTE_CARLO_REPO=$(aws ecr describe-repositories --repository-names ${APP_NAME} | jq -r '.repositories[0].repositoryUri')
echo "export MONTE_CARLO_IMAGE=$(echo ${MONTE_CARLO_REPO}:latest)" >> ~/.bash_profile
source ~/.bash_profile
docker build -f Dockerfile --tag ${MONTE_CARLO_IMAGE} .
docker push ${MONTE_CARLO_IMAGE}
echo "${MONTE_CARLO_IMAGE} image ready for use"
```

{{% notice note %}}
This process does take 2 to 3 minutes.
{{% /notice %}}

The steps above:


* Create a new registry in ECR for the monte-carlo-sim application
* Build the application using the Dockerfile. The Dockerfile uses a [multi-stage](https://docs.docker.com/build/building/multi-stage/) build that
compiles the Go application and then packages it in a minimal image that pulls from [scratch](https://hub.docker.com/_/scratch/). The size of this Docker image is ~ 3.2 MiB.
* The newly created image is pushed into the registry and the registry is stored as an environment variable so we can refer to it in the rest of the workshop.


