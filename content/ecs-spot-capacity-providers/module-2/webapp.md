---
title: "Building the webapp container"
chapter: true
weight: 45
---

Building the webapp container
---

Run the below command to build the container

```
cd webapp
docker build --no-cache  -t ecs-spot-workshop/webapp .

export ECR_REPO_URI=$(aws ecr describe-repositories --repository-names ecs-spot-workshop/webapp | jq -r '.repositories[0].repositoryUri')
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI
docker tag ecs-spot-workshop/webapp:latest $ECR_REPO_URI:latest
docker push $ECR_REPO_URI:latest
```

Copy the template file *templates/ec2-task.json* to the current directory and substitute the template with actual values.

```
cd ..
cp -Rfp templates/ec2-task.json .
sed -i -e "s#DOCKER_IMAGE_URI#$ECR_REPO_URI:latest#g" ec2-task.json
```

In this section, we will create a task definition for for tasks to be launched on the Auto Scaling Capacity Providers.

### Run the below command to create the task definition

```
aws ecs register-task-definition --cli-input-json file://ec2-task.json
```
### The task will look like this in console

![Task](/images/ecs-spot-capacity-providers/task1.png)