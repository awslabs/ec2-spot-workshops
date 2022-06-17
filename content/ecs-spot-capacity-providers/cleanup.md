---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 70
---

{{% notice warning %}}
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs !! For those of you that are running as part of an AWS event, there's no need to go through the cleanup stage
{{% /notice %}}

{{% notice tip %}}
Before you clean up the resources and complete the workshop, you may want to review the complete some optional exercises in the previous section of this workshop!
{{% /notice %}}

We need to scale down the number of tasks in the ECS services before deleting it. 

Run the command below to delete the ECS Servers *ec2-service-split* and *fargate-service-split*. This command may take
some time to complete. All the task will be terminated and the services removed.

{{% notice note %}}
To delete resources like the ECS cluster and the capacity providers, we need first to make sure the resources they depend on have been terminated and the status is *DELETED* or *INACTIVE*. The following command has a few **while** loops, just to wait until the conditions required for a clear removal are met.
{{% /notice %}}

```
aws ecs update-service --cluster EcsSpotWorkshop --service ec2-service-split --desired-count 0 > /dev/null
aws ecs update-service --cluster EcsSpotWorkshop --service fargate-service-split --desired-count 0 > /dev/null
while [ 1 -ne $(aws ecs list-tasks --cluster EcsSpotWorkshop --output yaml | wc -l) ]
do
  aws  ecs list-tasks --cluster EcsSpotWorkshop --output table
  echo "Waiting for the tasks above to clear out"
  sleep 10
done
aws ecs delete-service --cluster EcsSpotWorkshop --service ec2-service-split > /dev/null
aws ecs delete-service --cluster EcsSpotWorkshop --service fargate-service-split > /dev/null
```

Once the services and tasks have been removed we can remove the capacity providers.

```
aws ecs put-cluster-capacity-providers \
--cluster EcsSpotWorkshop \
--capacity-providers [] \
--default-capacity-provider-strategy [] > /dev/null
aws ecs delete-capacity-provider --capacity-provider CP-OD > /dev/null
while [ "true" == $(aws ecs describe-capacity-providers --capacity-provider CP-OD --query "capacityProviders[0].status!='INACTIVE'") ]
do   
  echo "Waiting for Capacity-provider CP-OD to become inactive"
  sleep 5
done
aws ecs delete-capacity-provider --capacity-provider CP-SPOT > /dev/null
while [ "true" == $(aws ecs describe-capacity-providers --capacity-provider CP-SPOT --query "capacityProviders[0].status!='INACTIVE'") ]
do   
  echo "Waiting for Capacity-provider CP-SPOT to become inactive"
  sleep 5
done
```


Now let's remove the auto scaling group and the ECS cluster.
Note again how we will need to wait for all the instances to be terminated
before the cluster deletion can proceed.

```
aws autoscaling delete-auto-scaling-group \
--force-delete --auto-scaling-group-name EcsSpotWorkshop-ASG-SPOT
aws autoscaling delete-auto-scaling-group \
--force-delete --auto-scaling-group-name EcsSpotWorkshop-ASG-OD
while [ 1 -ne $(aws ecs list-container-instances --cluster EcsSpotWorkshop --output yaml | wc -l) ]
do
  aws ecs list-container-instances --cluster EcsSpotWorkshop --output table
  echo "Waiting for the instances above to clear out"
  sleep 10
done
aws ecs delete-cluster --cluster EcsSpotWorkshop 
```

Deregister [EC2 Task](https://console.aws.amazon.com/ecs/home?#/taskDefinitions/ec2-task/status/ACTIVE) -- If you see multiple versions, repeate below steps for all versions.

```
aws ecs deregister-task-definition --task-definition ec2-task:1
```

Deregister [Fargate Task](https://console.aws.amazon.com/ecs/home?#/taskDefinitions/fargate-task/status/ACTIVE) -- If you see multiple versions, repeate below steps for all versions.
```
aws ecs deregister-task-definition --task-definition fargate-task:1
```

Delete "ecs-spot-workshop/webapp" container from Amazon Elastic Container Registry

```
aws ecr delete-repository --force --repository-name ecs-spot-workshop/webapp
```

Finally, let's remove the cloudformation stack. Go to the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation/home?#/stacks?filteringStatus=active&filteringText=&viewNested=true&hideStacks=false) and select the Cloudformation stack **EcsSpotWorkshop** , finally click on **delete** to remove the stack and all resources associated.

![DeleteStacl](/images/ecs-spot-capacity-providers/cloudformation_delete_stack.png)

{{% notice tip %}}
Please verify in the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation/home?#/stacks?filteringStatus=active&filteringText=&viewNested=true&hideStacks=false) cloudformation stack is deleted without any failures. If you notice any failure, just delete again directly from Cloud Formation console.
{{% /notice %}}

That's it, all the resources you created during this workshops have now been removed.
