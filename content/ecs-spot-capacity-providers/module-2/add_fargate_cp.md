---
title: "Add Fargate capacity providers to ECS Cluster"
weight: 10
---

Before we deploy tasks on ECS Fargate, let us first add Fargate capacity providers to the ECS cluster. Unlike with EC2 Auto Scaling Groups
the Capacity Providers `FARGATE` and `FARGATE_SPOT` are already predefined by default, so the only thing we need to do is attach them
to our cluster running the following command. 

```
aws ecs put-cluster-capacity-providers   \
        --cluster EcsSpotWorkshop \
        --capacity-providers FARGATE FARGATE_SPOT CP-OD CP-SPOT  \
        --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1 capacityProvider=FARGATE_SPOT,weight=1 \
        --region $AWS_REGION
```

{{% notice note %}}
The command above does not only insert the two capacity providers but has also modified the cluster default capacity provider strategy. 
In this case we do set both weights to 1. However if you run the command `aws ecs describe-clusters --cluster EcsSpotWorkshop` you 
will see how the service `ec2-service-split` still holds the initial capacity provider strategy. 
{{% /notice %}}

The strategy sets a weight of 1 both FARGATE and FARGATE_SPOT as the default capacity provider strategy. That means for equal distribution of tasks on FARGATE and FARGATE_SPOT. The ECS cluster should now contain 4 capacity providers i.e. CP-OD, CP-SPOT, FARGATE and FARGATE_SPOT.

![Fargate Capacity Providers](/images/ecs-spot-capacity-providers/ecs_fargate_cps.png)
