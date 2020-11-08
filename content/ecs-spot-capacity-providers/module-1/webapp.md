---
title: "Build webapp container and Register ECS Task Definition"
weight: 45
---
In this section, we will build a simple python flask based web application and deploy in our ECS cluster.

Note the initial CloudFormation template already created an ECR registry.  

Retrieve an authentication token and authenticate your Docker client to your registry.

```bash
export ECR_REPO_URI=$(aws ecr describe-repositories --repository-names ecs-spot-workshop/webapp | jq -r '.repositories[0].repositoryUri')
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI
```

Run the below command to build the webapp docker image.

```bash
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/webapp/
docker build --no-cache  -t ecs-spot-workshop/webapp .
```

Tag the webapp container and push to the ECR docker registry

```bash
docker tag ecs-spot-workshop/webapp:latest $ECR_REPO_URI:latest
docker push $ECR_REPO_URI:latest
```

Copy the template file *templates/ec2-task.json* to the current directory and substitute the template with actual value of the docker image path.

```bash
cd ..
cp -Rfp templates/ec2-task.json .
sed -i -e "s#DOCKER_IMAGE_URI#$ECR_REPO_URI:latest#g" ec2-task.json
```

## Creating a task definition

Run the below command to register a task definition

```bash
aws ecs register-task-definition --cli-input-json file://ec2-task.json
```
The task definition will look like this in the console:

![Task](/images/ecs-spot-capacity-providers/task1.png)