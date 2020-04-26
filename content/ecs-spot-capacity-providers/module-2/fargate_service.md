---
title: "Create ECS Fargate Services"
chapter: true
weight: 2
---

###  Create ECS Fargate Services

In this section, we will create 3 ECS Services to show how tasks can be deployed across FARGATE and FARGATE\_SPOT capacity providers(CP).


| **Service Name** | **No. of Tasks** | **No. of Tasks on FARGATE CP** | **Number of Tasks on FARGATE_SPOT CP** | **CP Strategy** |
| --- | --- |--- |--- |--- |
| **webapp-fargate-service-fargate** | 2 | 2 | 0 | FARGATE Capacity Provider weight =1 |
| **fargate-service-fargate-spot** | 2 | 0 | 2 | FARGATE_SPOT Capacity Provider weight =1 |
| **fargate-service-fargate-mix** | 4 | 3 | 1 | FARGATE Capacity Provider weight =3 FARGATE_SPOT Capacity Provider weight =1 |

We will be creating the ECS services and tasks in the new VPC we created in the Module-1 i.e. **Quick-Start-VPC**

So let's first find the default public subnets created in this VPC. You can find the subnet IDs in this VPC in the  AWS console as shown below, under the VPC service.

Alternatively you can run the below command to list all the subnets in this VPC

```
aws ec2 describe-subnets --filters "Name=tag:aws:cloudformation:stack-name,Values=Quick-Start-VPC" | jq -r '.Subnets[].SubnetId'
```

The output from above command looks like below.

```
subnet-07a877ee28959daa3
subnet-015fc3e06f653980a
subnet-003ef0ebc04c89b2d
```

Run the below command to set a variable for the subnets. We will use this variable in other steps.

```
export PUBLIC\_SUBNET\_LIST="subnet-07a877ee28959daa3,subnet-015fc3e06f653980a,subnet-003ef0ebc04c89b2d"
```

Now let's find the default security group created in this VPC. You can find it in the AWS console as follows.

You can also run the below command to list the default security group in this VPC

```
export VPC\_ID=$(aws ec2 describe-vpcs --filters "Name=tag:aws:cloudformation:stack-name,Values=Quick-Start-VPC" | jq -r '.Vpcs[0].VpcId')
 echo "Quick Start VPC ID is $VPC\_ID"
```

The output from above command looks like below.

```
Quick Start VPC ID is vpc-0a2fc4f24cbfab696
```

```
export SECURITY\_GROUP=$( aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC\_ID" | jq -r '.SecurityGroups[0].GroupId')
 echo "Default Security group is $SECURITY\_GROUP"
```

The output from above command looks like below.

```
Default Security group is sg-03ccfca80f9fddf4d
```

Deploy the service **webapp-fargate-service-fargate** using below command.

```
aws ecs create-service \
     --capacity-provider-strategy capacityProvider=FARGATE,weight=1 \
     --cluster EcsSpotWorkshopCluster \
     --service-name webapp-fargate-service-fargate \
     --task-definition webapp-fargate-task:1 \
     --desired-count 2 \
     --region $AWS\_REGION \
     --network-configuration "awsvpcConfiguration={subnets=[$PUBLIC\_SUBNET\_LIST],securityGroups=[$SECURITY\_GROUP],assignPublicIp="ENABLED"}"

```
Note the capacity provider strategy used for this service.  It provides weight only for FARGATE capacity provider. This strategy overrides the default capacity provider strategy which is set to FARGATE capacity provider.

That means ECS schedules all of the tasks (2 in this case) in service on the FARGATE Capacity providers.

Deploy the service **webapp-fargate-service-fargate-spot** using below command

```
aws ecs create-service \
	 --capacity-provider-strategy capacityProvider=FARGATE\_SPOT,weight=1 \
     --cluster EcsSpotWorkshopCluster \
     --service-name webapp-fargate-service-fargate-spot \
     --task-definition webapp-fargate-task:1 \
     --desired-count 2\
     --region $AWS\_REGION \
     --network-configuration "awsvpcConfiguration={subnets=[$PUBLIC\_SUBNET\_LIST],securityGroups=[$SECURITY\_GROUP],assignPublicIp="ENABLED"}"
```

Note the capacity provider strategy used for this service. It provides weight only for FARGATE\_SPOT capacity provider. This strategy overrides the default capacity provider strategy which is set to FARGATE capacity provider.

That means ECS schedules all of the tasks (2 in this case) in service on the FARGATE\_SPOT Capacity providers.

Deploy the service **webapp-fargate-service-fargate-mix** using below command

```
aws ecs create-service \
	 --capacity-provider-strategy capacityProvider=FARGATE,weight=3 capacityProvider=FARGATE\_SPOT,weight=1 \
     --cluster EcsSpotWorkshopCluster \
     --service-name webapp-fargate-service-fargate-mix \
     --task-definition webapp-fargate-task:1 \
     --desired-count 4\
     --region $AWS\_REGION \
     --network-configuration "awsvpcConfiguration={subnets=[$PUBLIC\_SUBNET\_LIST],securityGroups=[$SECURITY\_GROUP],assignPublicIp="ENABLED"}"
```

Note the capacity provider strategy used for this service.  It provides a weight of 3 to FARGATE and 1 to FARGATE\_SPOT capacity provider. This strategy overrides the default capacity provider strategy which is set to FARGATE capacity provider.

That means ECS schedules splits the total tasks (4 in this case) in 3:1 ratio between FARGATE and FARGATE\_SPOT Capacity providers.

But how do you verify if ECS really scheduled the tasks in this way?

Click on the service  **webapp-fargate-service-fargate-mix** and select Tasks Tab

Click on each task and note the Capacity Provider