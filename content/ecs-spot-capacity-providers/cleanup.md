---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 70
---

{{% notice warning %}}
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs !!
For those of you that are running as part of an AWS event, there's no need to go through the cleanup stage
{{% /notice %}}

{{% notice tip %}}
Before you clean up the resources and complete the workshop, you may want to review the complete some optional exercises in the previous section of this workshop!
{{% /notice %}}

We need to scale down the number of tasks in the ECS services before deleting it. 

Run the command below to delete the ECS service *ec2-service-split* 
```bash
aws ecs update-service --cluster EcsSpotWorkshop --service ec2-service-split --desired-count 0
q
```

Run the commands below to delete the ECS service *fargate-service-split* (if you have completed the optional Fargate section).

```bash
aws ecs update-service --cluster EcsSpotWorkshop --service fargate-service-split --desired-count 0

```

Run the commands below to the de-associate capacity providers with ECS Cluster

```bash
aws ecs put-cluster-capacity-providers \
     --cluster EcsSpotWorkshop \
     --capacity-providers [] \
     --default-capacity-provider-strategy []

```

Below commands to delete capacity providers
```bash
aws ecs delete-capacity-provider --capacity-provider CP-OD
aws ecs delete-capacity-provider --capacity-provider CP-SPOT 

```

Run the commands below to delete the both autoscaling groups

```bash
aws autoscaling delete-auto-scaling-group \
              --force-delete --auto-scaling-group-name EcsSpotWorkshop-ASG-SPOT
aws autoscaling delete-auto-scaling-group \
              --force-delete --auto-scaling-group-name EcsSpotWorkshop-ASG-OD  

```



Delete the **EcsSpotWorkshop** ECS Cluster
```bash
aws ecs delete-cluster --cluster EcsSpotWorkshop

```

Deregister [EC2 Task] (https://console.aws.amazon.com/ecs/home?#/taskDefinitions/ec2-task/status/ACTIVE) -- If you see multiple versions, repeate below steps for all versions.

```bash
aws ecs deregister-task-definition --task-definition ec2-task:1

```

Deregister [Fargate Task] (https://console.aws.amazon.com/ecs/home?#/taskDefinitions/fargate-task/status/ACTIVE) -- If you see multiple versions, repeate below steps for all versions.
```bash
aws ecs deregister-task-definition --task-definition fargate-task:1

```

Delete "ecs-spot-workshop/webapp" container from Amazon Elastic Container Registry

```bash
aws ecr delete-repository --force --repository-name ecs-spot-workshop/webapp

```

Run the commands below to delete the cloud formation stack

```bash
aws cloudformation delete-stack --stack-name $STACK_NAME  

```
{{% notice tip %}}
Please check [AWS CloudFormation console] (https://console.aws.amazon.com/cloudformation/home?#/stacks?filteringStatus=active&filteringText=&viewNested=true&hideStacks=false) to verify that, cloud formation stack is deleted without any failures. If you notice any filure, just delete again directly from Cloud Formation console.
{{% /notice %}}
