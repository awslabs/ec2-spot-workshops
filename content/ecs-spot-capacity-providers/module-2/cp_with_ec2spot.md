---
title: "Creating a Capacity Provider using ASG with EC2 Spot instances"
weight: 15
---

A capacity provider is used in association with a cluster to determine the infrastructure that a task runs on.

Copy the template file  **templates/ecs-capacityprovider.json** to the current directory.

```
cp -Rfp templates/ecs-capacityprovider.json .
```

Run the following commands to substitute the template with actual values from the global variables

```
export CAPACITY_PROVIDER_NAME=ec2spot-capacity_provider
 sed -i -e "s#%CAPACITY_PROVIDER_NAME%#$CAPACITY_PROVIDER_NAME#g" -e "s#%ASG_ARN%#$ASG_ARN#g"  ecs-capacityprovider.json
```
```
CAPACITY_PROVIDER_ARN=$(aws ecs create-capacity-provider  --cli-input-json file://ecs-capacityprovider.json | jq -r '.capacityProvider.capacityProviderArn')
 echo "$SPOT_CAPACITY_PROVIDER_NAME  ARN=$CAPACITY_PROVIDER_ARN"
```

The output of the above command looks like

```
spot-capacity_provider ARN=arn:aws:ecs:us-east-1:000474600478:capacity-provider/ec2spot-capacity_provider
```

### Update ECS Cluster with Auto Scaling Capacity Providers

So far we created two Auto Scaling Capacity Providers. Now let's update our existing ECS Cluster with these Capacity Providers.

Run the following command to create the ECS Cluster

```
aws ecs put-cluster-capacity-providers   \
        --cluster EcsSpotWorkshopCluster \
        --capacity-providers FARGATE FARGATE_SPOT od-capacity_provider ec2spot-capacity_provider  \
        --default-capacity-provider-strategy capacityProvider=od-capacity_provider,base=1,weight=1   \
        --region $AWS_REGION
```

The ECS cluster should now contain 4 Capacity Providers: 2 from Auto Scaling groups (1 for OD and 1 for Spot), 1 from FARGATE and 1 from FARGATE_SPOT

Also note the default capacity provider strategy used in the above command. It sets base=1 and weight=1 for On-demand Auto Scaling Group Capacity Provider. This will override the previous default capacity strategy which is set to FARGATE capacity provider.

Click on the **Update Cluster** on the top right corner to see default Capacity Provider Strategy. As shown base=1 is set for OD Capacity Provider.

That means if there is no capacity provider strategy specified during the deploying Tasks/Services, ECS by default chooses the OD Capacity Provider to launch them.

Click on Cancel as we don't want to change the default strategy for now.
