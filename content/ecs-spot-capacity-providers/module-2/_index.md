---
title: "Saving costs using AWS Fargate Spot Capacity Providers (Optional)"
weight: 40
---

AWS Fargate Capacity Providers
---

Amazon ECS cluster capacity providers enable you to use both Fargate and Fargate Spot capacity with your Amazon ECS tasks. With Fargate Spot you can run interruption tolerant Amazon ECS tasks at a discounted rate compared to the Fargate price. Fargate Spot runs tasks on spare compute capacity. When AWS needs the capacity back, your tasks will be interrupted with a two-minute warning

Creating a New ECS Cluster That Uses Fargate Capacity Providers
---

When a new Amazon ECS cluster is created, you specify one or more capacity providers to associate with the cluster. The associated capacity providers determine the infrastructure to run your tasks on. Set the following global variables for the names of resources be created in this workshop

Run the following command to create a new cluster and associate both the Fargate and Fargate Spot capacity providers with it.

```
aws ecs create-cluster \
--cluster-name EcsSpotWorkshop \
--capacity-providers FARGATE FARGATE_SPOT \
--region $AWS_REGION \
--default-capacity-provider-strategy capacityProvider=FARGATE,base=1,weight=1
```
If the above command fails with below error, run the command again. It should create the cluster now.

```
“An error occurred (InvalidParameterException) when calling the CreateCluster operation: Unable to assume the service linked role. Please verify that the ECS service linked role exists.“
```

The ECS cluster will look like below in the AWS Console. Select ECS in **Services** and click on **Clusters** on left panel

![ECS Cluster](/images/ecs-spot-capacity-providers/c1.png)

Note that above ECS cluster create command also specifies a default capacity provider strategy.

The strategy sets FARGATE as the default capacity provider. That means if there is no capacity provider strategy specified during the deployment of Tasks/Services, ECS by default chooses the FARGATE Capacity Provider to launch them.

Click  _***Update Cluster***_ on the top right corner to see default Capacity Provider Strategy. As shown base=1 is set for FARGATE Capacity Provider.

![ECS Cluster](/images/ecs-spot-capacity-providers/c2.png)

