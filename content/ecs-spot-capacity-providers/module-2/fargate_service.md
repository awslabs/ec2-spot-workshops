---
title: "Create ECS Fargate Services"
weight: 15
---

In this section, we will create a ECS service to deploy fargate tasks on FARGATE and FARGATE_SPOT capacity providers using a custom strategy, overriding the  cluster default strategy. We will use a assign a weight of 1 to FARGATE_SPOT and 3 to FARGATE, which is different from the default strategy with equal weight of 1 to both FARGATE_SPOT and FARGATE.  In this case, for every task on FARGATE_SPOT, 3 tasks will be placed on FARGATE.

We will be creating the ECS services and tasks in the new VPC we created earlier using the CFN stack.


Please note that at the beginning of the workshop we loaded Cloudformation Outputs to Environment variables to make running the workshop easier; you'll be able to see the outputs on the Cloudformation console.

So let’s first find the default public subnets created in this VPC. You can find the list of public subnet IDs in this VPC using the output variables in the CFN stack.

The environment variable **VPCPublicSubnets** contains this value of list of public subnets. Check its value using below command.  If not, run the command again as shown in the Workspace setup section.

```
echo $VPCPublicSubnets
```

The output from above command looks like below.

```
subnet-0207bed3b4fea0f8a,subnet-06d1fea4f304ee224
```

The environment variable *vpc* contains the vpc id created in the CFN template. Check its value using below command.

```
echo $vpc
```

The output from above command looks like below.

```
vpc-085e8de17baa3996e
```
Rub the below command to get the security group id for the default security group

```
export SECURITY_GROUP=$( aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpc  Name=group-name,Values='default' | jq -r '.SecurityGroups[0].GroupId')
echo "Default Security group is $SECURITY_GROUP"
```

The output from above command looks like below.

```
Default Security group is sg-0db37aac5427520c1
```

Deploy the service  **fargate-service-split** using below command

```
aws ecs create-service \
     --capacity-provider-strategy capacityProvider=FARGATE,weight=3 capacityProvider=FARGATE_SPOT,weight=1 \
     --cluster EcsSpotWorkshop \
     --service-name fargate-service-split \
     --task-definition fargate-task:1 \
     --desired-count 4\
     --region $AWS_REGION \
     --network-configuration "awsvpcConfiguration={subnets=[$VPCPublicSubnets],securityGroups=[$SECURITY_GROUP],assignPublicIp="ENABLED"}" 


```

Note the capacity provider strategy used for this service.  It provides a weight of 3 to FARGATE and 1 to FARGATE_SPOT capacity provider. This strategy overrides the default capacity provider strategy which is set to FARGATE capacity provider.

That means ECS schedules splits the total tasks (4 in this case) in 3:1 ratio between FARGATE and FARGATE_SPOT Capacity providers. 

But how do you verify if ECS really scheduled the tasks as per the weights specificed for FARAGTE and FARGATE_SPOT?


Run the below command to see how tasks are distributed across the Capacity Providers.

```
export cluster_name=EcsSpotWorkshop 
export service_name=fargate-service-split
aws ecs describe-tasks \
--tasks $(aws ecs list-tasks --cluster $cluster_name \
--service-name $service_name --query taskArns[*] --output text) \
--cluster $cluster_name \
--query 'sort_by(tasks,&capacityProviderName)[*].{TaskArn:taskArn,CapacityProvider:capacityProviderName,Instance:containerInstanceArn,AZ:availabilityZone,Status:lastStatus}' \
--output table
```

The output of the above command should display a table like this below.

![Table](/images/ecs-spot-capacity-providers/table1.png) 

As you see 3 tasks were placed on FARGATE and 1 is placed on FARGATE_SPOT Capacity Providers as per the Capacity Providers Strategy.

Spot Interruption Handling on ECS Fargate Spot
---

When tasks using Fargate Spot capacity are stopped due to a Spot interruption, a two-minute warning is sent before a task is stopped. The warning is sent as a task state change event to Amazon EventBridge
and a SIGTERM signal to the running task. When using Fargate Spot as part of a service, the service
scheduler will receive the interruption signal and attempt to launch additional tasks on Fargate Spot if
capacity is available.

To ensure that your containers exit gracefully before the task stops, the following can be configured:

• A stopTimeout value of 120 seconds or less can be specified in the container definition that the task
is using. Specifying a stopTimeout value gives you time between the moment the task state change event is received and the point at which the container is forcefully stopped. 

• The **SIGTERM** signal must be received from within the container to perform any cleanup actions.


***Optional Exercise:***
Try changing the Capacity Provider Strategy by assigning different weightrs to FARGATE and FARGATE_SPOT Capacity Providers and update the service.

***Congratulations !!!*** you have successfully completed the workshop!!!.
