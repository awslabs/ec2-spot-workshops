---
title: "Create ECS EC2 Services"
weight: 25
---

In this section, we will create 3 ECS Services to show how tasks can be deployed across On-demand and EC2 Spot based Auto Scaling Capacity providers.

| **Service Name** | **Number of Tasks** | **Number  of Tasks on On-demand ASG Capacity Provider** | **Number of Tasks on EC2 Spot ASG Capacity Provider** | **Capacity Provider Strategy** |
| --- | --- | --- | --- | --- |
| **webapp-ec2-service-od** | 2 | 2 | 0 | OD Capacity Provider weight =1 |
| **webapp-ec2-service-spot** | 2 | 0 | 2 | Spot Capacity Provider weight =1 |
| **webapp-ec2-service-mix** | 6 | 2 | 4 | OD Capacity Provider weight =1 Spot Capacity Provider weight =3 |

Deploy the service **webapp-ec2-service-od** using below command.

```
aws ecs create-service \
      --capacity-provider-strategy capacityProvider=od-capacity_provider,weight=1 \
      --cluster EcsSpotWorkshopCluster\
      --service-name webapp-ec2-service-od\
      --task-definition webapp-ec2-task:1 \
      --desired-count 2\
      --region $AWS_REGION
```

Note the capacity provider strategy used for this service.  It provides weight only for On-demand based ASG capacity provider. This strategy overrides the default capacity provider strategy which is set to On-demand ASG capacity provider.

That means ECS schedules all of the tasks (2 in this case) in service on the On-demand ASG Capacity providers.

Note this ASG does not have any instances launched since the desired capacity is set to Zero. Since this ECS service deployment needs 2 tasks to be placed in the ECS cluster, it triggers CloudWatch alarms for Cluster Capacity. Based on the specified weight for Capacity Providers, the OD Capacity Provider in this case (i.e. corresponding Auto scaling group) scales 2 instances to schedule 2 tasks for this service.

Notice the change in the desired capacity in the On-demand Auto Scaling Group

Deploy the service **webapp-ec2-service-spot** using below command.

```
aws ecs create-service \
      --capacity-provider-strategy capacityProvider=ec2spot-capacity_provider,weight=1 \
      --cluster EcsSpotWorkshopCluster\
      --service-name webapp-ec2-service-spot\
      --task-definition webapp-ec2-task:1 \
      --desired-count 2\
      --region $AWS_REGION
```
Note the capacity provider strategy used for this service.  It provides weight only for EC2 Spot based ASG capacity provider. This strategy overrides the default capacity provider strategy which is set to On-demand ASG capacity provider.

That means ECS schedules all of the tasks (2 in this case) in service on the EC2 Spot ASG Capacity providers.

Note this ASG does not have any instances launched since the desired capacity is set to Zero. Since this ECS service deployment needs 2 tasks to be placed in the ECS cluster, it triggers Cloud watch alarms for Cluster Capacity. Based on the specified weightage for Capacity Providers, the Spot Capacity Provider in this case (i.e. corresponding Auto scaling group) scales 2 instances to schedule 2 tasks for this service.

Notice the change in the desired capacity in the Spot  Auto Scaling Group

Deploy the service **webapp-ec2-service-mix** using below command

```
aws ecs create-service \
      --capacity-provider-strategy capacityProvider=od-capacity_provider,weight=1 \
                                   capacityProvider=ec2spot-capacity_provider,weight=3 \
      --cluster EcsSpotWorkshopCluster\
      --service-name webapp-ec2-service-mix\
      --task-definition webapp-ec2-task:1 \
      --desired-count 6\
      --region $AWS_REGION
```
Note the capacity provider strategy used for this service.  It provides weight of 1 to On-demand based ASG capacity provider and weight of 3 to EC2 Spot based ASG capacity provider. This strategy overides the default capacity provider strategy which is set to On-demand ASG capacity provider.

That means ECS schedules splits total  number of the tasks (6 in this case) in service in 1:3 ration which means 2 tasks on On-demand based ASG capacity provider and 4 tasks on EC2 Spot ASG Capacity provider.

Note that On-demand and Spot bases ASGs already have few instances launched for the ECS services launched earlier.   Since this ECS service deployment needs 6 tasks to be placed in the ECS cluster, it triggers Cloud watch alarms for Cluster Capacity. Based on the specified weight (i.e. OD=1, Spot=3) for Capacity Providers, Both OD and  Spot Capacity Provider in this case (i.e. corresponding Auto scaling groups) scales additional instances in Spot and OD instances.

Now look at the AWS console to see  these 6 tasks running for this service.

But how do we know if ECS really satisfy our tasks placement requirement of 2 tasks on OD and 4 on Spot instances?

To check which task is placed on which instance type (OD or Spot), click on the Task Id.

As shown task Id 0c6ca084-12a4-4469-a3b5-bbb0ad3c7bc3 is placed on OD Capacity Provider

Check the remaining 5 tasks and check if ECS confirms to our Task Placement strategy.
