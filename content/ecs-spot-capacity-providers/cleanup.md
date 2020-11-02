---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

{{% notice note %}}
If you're running in an account that was created for you as part of an AWS event, there's no need to go through the cleanup stage - the account will be closed automatically.\
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}

{{% notice tip %}}
Before you clean up the resources and complete the workshop, you may want to review the complete some of the optional exercises in previous section of this workshop!
{{% /notice %}}

We need to scale down the number of tasks in the ECS service before deleting it.


Run below commands to delete the ECS Service *fargate-service-split* if you have completed the optional Fargate section

```bash
aws ecs update-service --cluster EcsSpotWorkshop  \
                       --service  fargate-service-split --desired-count 0
aws ecs delete-service --cluster EcsSpotWorkshop  \
                       --service  fargate-service-split  
```


Run below commands to delete the ECS Service *ec2-service-split*

```bash
aws ecs update-service --cluster EcsSpotWorkshop  \
                       --service   ec2-service-split --desired-count 0
aws ecs delete-service --cluster EcsSpotWorkshop \
                        --service   ec2-service-split   
```

Run below commands to the de-associate capacity providers with ECS Cluster first and then delete them

```bash
aws ecs put-cluster-capacity-providers \
     --cluster EcsSpotWorkshop \
     --capacity-providers [] \
     --default-capacity-provider-strategy []

aws ecs delete-capacity-provider      --capacity-provider CP-OD
aws ecs delete-capacity-provider      --capacity-provider CP-SPOT 
```

Run below commands to delete the both autoscaling groups

```bash
aws autoscaling delete-auto-scaling-group \
              --auto-scaling-group-name EcsSpotWorkshop-ASG-SPOT
aws autoscaling delete-auto-scaling-group \
              --auto-scaling-group-name EcsSpotWorkshop-ASG-OD  
```

Run below commands to delete the cloud formation stack

```bash
aws cloudformation delete-stack --stack-name EcsSpotWorkshop  
```