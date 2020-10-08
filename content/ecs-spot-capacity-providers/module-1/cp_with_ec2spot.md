---
title: "Create a Capacity Provider using ASG with EC2 Spot instances"
weight: 20
---

To create the CP, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you are looking to launch your cluster.
* Click *Clusters*
* Click [EcsSpotWorkshop] (https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/EcsSpotWorkshop)
* Click the tab *Capacity Providers*
* Click *Create*
* For Capacity provider name, enter *CP-SPOT*
* For Auto Scaling group, select *EcsSpotWorkshop-ASG-SPOT*
* For Managed Scaling, leave with default selection of *Enabled*
* For Target capacity %, enter *100*
* For Managed termination protection, leave with default selection of *Enabled*
* Click on *Create* on the bottom right 
* 
![Capacity Provider on Spot ASG](/images/ecs-spot-capacity-providers/CP_SPOT.png)

Refresh the *Capacity Providers* tab and you will see the CP-SPOT is created and attached to the cluster.

![Capacity Provider on Spot ASG](/images/ecs-spot-capacity-providers/CP_SPOT1.png)

The CP creates a target tracking policy on the EcsSpotWorkshop-ASG-SPOT. Go to the EC2 Management Console and select the scaling policies tab on this ASG.

![Spot ASG](/images/ecs-spot-capacity-providers/ASG2.png)

### Update ECS Cluster with Auto Scaling Capacity Providers

So far we created two Auto Scaling Capacity Providers. Now let's update our existing ECS Cluster with these Capacity Providers.

Run the following command to create the Capacity Providers on the ECS cluster:

```bash
aws ecs put-cluster-capacity-providers   \
        --cluster EcsSpotWorkshopCluster \
        --capacity-providers FARGATE FARGATE_SPOT od-capacity_provider ec2spot-capacity_provider  \
        --default-capacity-provider-strategy capacityProvider=od-capacity_provider,base=1,weight=1   \
        --region $AWS_REGION
```

The ECS cluster should now contain 4 Capacity Providers: 2 from Auto Scaling groups (1 for On-Demand and 1 for Spot), 1 from FARGATE and 1 from FARGATE_SPOT. The Fargate capacity providers are created by default.

Also note the default capacity provider strategy used in the above command. It sets base=1 and weight=1 for the On-demand Auto Scaling group Capacity Provider. This will override the previous default capacity provider strategy which is set to FARGATE capacity provider.

Click on the **Update Cluster** on the top right corner to see default Capacity Provider Strategy. As shown base=1 is set for OD Capacity Provider.

That means if there is no capacity provider strategy specified during the deployment of ECS Tasks or Services, ECS by default chooses the OD Capacity Provider to launch them.

Click on Cancel as we don't want to change the default strategy for now.
