---
title: "Create a Capacity Provider using ASG with EC2 Spot instances"
weight: 20
---

To create the CP, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you are looking to launch your cluster.
* Click *Clusters*
* Click [EcsSpotWorkshop] (https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/EcsSpotWorkshop)
* Click on the tab *Capacity Providers*
* Click on the *Create*
* For Capacity provider name, enter *CP-SPOT*
* For Auto Scaling group, select *EcsSpotWorkshop-ASG-SPOT*
* For Managed Scaling, leave with default selection of *Enabled*
* For Target capacity %, enter *100*
* For Managed termination protection, leave with default selection of *Enabled*
* Click on the *Create* on the right bottom

![Capacity Provider on Spot ASG](/images/ecs-spot-capacity-providers/CP_SPOT.png)

Refresh the tab “*Capacity Providers” *and you will see the CP-SPOT is created and attachd to the cluster.

![Capacity Provider on Spot ASG](/images/ecs-spot-capacity-providers/CP_SPOT1.png)

Now you will see that the CP creates a target tracking policy on the EcsSpotWorkshop-ASG-SPOT. Go to the AWS EC2 Console and select this scaling policies tab on this ASG.

![Spot ASG](/images/ecs-spot-capacity-providers/ASG2.png)

The ECS cluster should now contain 4 Capacity Providers: 2 from Auto Scaling groups (1 for OD and 1 for Spot), 1 from FARGATE and 1 from FARGATE_SPOT



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
