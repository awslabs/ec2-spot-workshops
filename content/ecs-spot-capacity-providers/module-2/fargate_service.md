---
title: "Create ECS Fargate service"
weight: 15
---n

In this section, we will create an ECS service to deploy fargate tasks on FARGATE and FARGATE_SPOT capacity providers using a custom strategy, overriding the cluster default capacity provider strategy. We will assign a weight of 1 to FARGATE_SPOT and 3 to FARGATE, which differs from the default strategy with equal weight of 1 to both FARGATE_SPOT and FARGATE.  Here, for every 1 task on FARGATE_SPOT, ECS places 3 tasks on FARGATE.

We will create a ECS service to place tasks in the new VPC created by the CloudFormation stack.

Recall that at the beginning of the workshop we loaded CloudFormation outputs to the environment variable. 

The environment variable **VPCPublicSubnets** contains the value of the list of public subnets created in the new VPC. Run the below command to check.

```
echo $VPCPublicSubnets
```

The output from above command looks like below.

```
subnet-0207bed3b4fea0f8a,subnet-06d1fea4f304ee224
```

The environment variable *vpc* contains the vpc id created in the CloudFormation stack. Check its value using below command.

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

Create the ECS service **fargate-service-split** using below command

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

Note that we override the default cluster capacity provider strategy with a custom strategy for this service.  The custom strategy sets a weight of 3 to FARGATE and 1 to FARGATE_SPOT capacity provider.

That means ECS splits the total tasks (4 in this case) in 3:1 ratio between FARGATE and FARGATE_SPOT capacity providers. 

But how do you verify if the tasks spread on FARAGTE and FARGATE_SPOT under the custom strategy? 

Run the below command to see how tasks spread across both capacity providers.

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

Note that 3 tasks placed on FARGATE and 1 task on FARGATE_SPOT capacity providers as expected.

Spot Interruption Handling on ECS Fargate Spot
---

When tasks using Fargate Spot capacity stopped because of a Spot interruption, a two-minute warning sent before a task is stopped. The warning is sent as a task state change event to Amazon EventBridge and a SIGTERM signal to the running task. When using Fargate Spot as part of a service, the service scheduler will receive the interruption signal and attempt to launch additional tasks on Fargate Spot if capacity is available.

To ensure that the application containers exit gracefully before the task stops, you can configure the following:

• A stopTimeout value of 120 seconds or less can be specified in the container definition that the task is using. Specifying a stopTimeout value gives you time between the moment the task state change event is received and the point at which the container is forcefully stopped. 

• The **SIGTERM** signal must be received from within the container to perform any cleanup actions.


***Optional Exercise:***

Try changing the capacity provider strategy by assigning different weights to FARGATE and FARGATE_SPOT capacity providers and update the service.

***Congratulations!!!*** you have successfully completed the workshop!!!.
