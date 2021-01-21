---
title: "Create ECS Fargate service"
weight: 15
---
Now that we have a fargate task registered, let's define a ECS Fargate service to deploy Fargate tasks accross the FARGATE and FARGATE_SPOT
capacity providers. In this case, we will be overriding the cluster default capacity provider strategy (with FARGATE weight 1 and FARGATE_SPOT weight 1) and instead appply a weight of 1 to FARGATE_SPOT and weight 3 to FARGATE. For every 1 task on FARGATE_SPOT deployed in this service there will be 3 tasks on FARGATE.

We will create an ECS service to place tasks in the new VPC created by the CloudFormation stack. By executing the comand below, we can 
load all the Outputs from the Cloudformation stack into environment variables. We will need some of the environment variables such as:
`$VPCPublicSubnets`, `$vpc`, and the default `SECURITY_GROUP` for the vpc.

```bash
export STACK_NAME=EcsSpotWorkshop
for output in $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[].OutputKey' --output text)
do
    export $output=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
    eval "echo $output : \"\$$output\""
done
export SECURITY_GROUP=$( aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpc  Name=group-name,Values='default' | jq -r '.SecurityGroups[0].GroupId')
echo "SECURITY_GROUP : $SECURITY_GROUP"

```

We can now create the ECS service. We will name it **fargate-service-split**. We will deploy a total of 4 different tasks. Execute the command below:

```bash
aws ecs create-service \
     --capacity-provider-strategy capacityProvider=FARGATE,weight=3 capacityProvider=FARGATE_SPOT,weight=1 \
     --cluster EcsSpotWorkshop \
     --service-name fargate-service-split \
     --task-definition fargate-task:1 \
     --desired-count 4\
     --region $AWS_REGION \
     --network-configuration "awsvpcConfiguration={subnets=[$VPCPublicSubnets],securityGroups=[$SECURITY_GROUP],assignPublicIp="ENABLED"}" 


```

{{% notice note %}}
Note how the command we are about to execute uses the environment variables that we just read to define attributes such as 
in which vpc and subnets Fargate tasks will run as well as the Security group to be used. Also observe how we are overriding the
capacity provider strategy with the `--capacity-provider-strategy` parameter, just for this specific service. The custom strategy 
sets a weight of 3 to FARGATE and 1 to FARGATE_SPOT capacity provider. 
{{% /notice %}}

**Exercise:  How many tasks are you expecting on FARGATE ? How many on FARGATE_SPOT? Verify the tasks spread on FARAGTE and FARGATE_SPOT under the custom strategy?** 

{{%expand "Click here to show the answer" %}}

Similar to what we did before, we can run the following command to see how tasks spread across capacity providers.

```
aws ecs describe-tasks \
--tasks $(aws ecs list-tasks --cluster EcsSpotWorkshop \
--service-name fargate-service-split --query taskArns[*] --output text) \
--cluster $cluster_name \
--query 'sort_by(tasks,&capacityProviderName)[*].{TaskArn:taskArn,CapacityProvider:capacityProviderName,Instance:containerInstanceArn,AZ:availabilityZone,Status:lastStatus}' \
--output table
```

The output of the above command should display a table as below.

![Table](/images/ecs-spot-capacity-providers/table1.png) 

**3 tasks were placed on FARGATE** and **1 task on FARGATE_SPOT** capacity providers, as expected.

{{% /expand %}}


## Spot Interruption Handling on ECS Fargate Spot

When tasks using Fargate Spot capacity are stopped because of a Spot interruption, a two-minute warning is sent before a task is stopped.
So far this is similar to the EC2 case. There are however a few differences.

* Fargate Spot is configured automatically to capture Spot Interruptions and set the task in DRAINING mode, a **SITERM** is sent to the task 
and containers and the application is expected to capture the **SIGTERM** signal and proceed in the same terms as in the EC2 case with a
graceful termination (the implementation is the same to all effects). 

* The container definition can define the `stopTimeout` attribute (30 seconds by default) and increase the value up to 120 seconds. This
is the value between the **SIGTERM** and the **SIGKILL** termination IPC signal when the task will be forced to finish.

* Finally, Fargate manages serverless containers, as such there is no access to instance metadata or signals for spot terminations that come
through Cloudwatch/Event Bridge state change for instances. Instead the you can monitor Fargate Spot interruptions with Event Bridge but
checking for ECS task state changes. Spot interruption change states will show up when the `detail-type` is `ECS Task State Change` and the
`stoppedReason` is set to `Your Spot Task was interrupted.` You can read more [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-capacity-providers.html#fargate-capacity-providers-termination)

## Optional Exercises

 {{% notice warning %}}
 Some of this exercises will take time for CAS to scale up and down. If you are running this workshop at a AWS event or with limited time, 
 we recommend to come back to this section.
 {{% /notice %}}

 In this section we propose additional exercises you can do at your own pace to get a better understanding of Capacity Providers and Fargate.
 Note that we are not providing solutions for this section. You should be able to reach to the solution by using some of your
 new acquired skills.


* Change the default strategy of the cluster to FARGATE weight 4 FARGATE_SPOT weight 1. What is the impact hat you expect on existing services 
such as `fargate-service-split` and `ec2-service-split` ? 

* Ups, it seems that we miss-configured quite a few things on the service and now we cannot get access to the application ! Is there anyway you can reconfigure the service so customer can get access to the web application?  

