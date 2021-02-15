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

We need to scale down the number of tasks in the ECS service before deleting it. Run the commands below to delete the ECS service *fargate-service-split* if you have completed the optional Fargate section.

```bash
aws ecs update-service --cluster EcsSpotWorkshop --service fargate-service-split --desired-count 0
aws ecs delete-service --cluster EcsSpotWorkshop --service fargate-service-split
aws ecs update-service --cluster EcsSpotWorkshop --service ec2-service-split --desired-count 0
aws ecs delete-service --cluster EcsSpotWorkshop --service ec2-service-split 

```

Run the commands below to the de-associate capacity providers with ECS Cluster first and then delete them

```bash
aws ecs put-cluster-capacity-providers \
     --cluster EcsSpotWorkshop \
     --capacity-providers [] \
     --default-capacity-provider-strategy []
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

* On the ECS Console, delete the ECS Cluster
* On the ECS Console, remove the registered tasks
* On the ECS Console, de-register the tasks
* On the ECR Console, delete "ecs-spot-workshop/webapp" repository

Run the commands below to delete the cloud formation stack

```bash
aws cloudformation delete-stack --stack-name EcsSpotWorkshop  
```
