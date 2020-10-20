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

![Capacity Provider on Spot ASG](/images/ecs-spot-capacity-providers/CP-SPOT.png)

The capacity provider creates a target tracking policy on the EcsSpotWorkshop-ASG-SPOT. Go to the EC2 Management Console and select the scaling policies tab on this ASG.

![Spot ASG](/images/ecs-spot-capacity-providers/ASG2.png)
