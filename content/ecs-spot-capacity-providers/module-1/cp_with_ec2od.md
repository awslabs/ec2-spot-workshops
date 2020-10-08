---
title: "Create a Capacity Provider using ASG with EC2 On-demand instances"
weight: 11
---

To create the CP, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you deployed the CFn template
* Click *Clusters*
* Click [EcsSpotWorkshop] (https://console.aws.amazon.com/ecs/home#/clusters/EcsSpotWorkshop)
* Click the tab *Capacity Providers*
* Click *Create*
* For Capacity provider name, enter *CP-OD*
* For Auto Scaling group, select **EcsSpotWorkshop-ASG-OD**
* For Managed Scaling, leave with default selection of *Enabled*
* For Target capacity %, enter *100*
* For Managed termination protection, leave with default selection of *Enabled*
* Click on *Create* on the bottom right 

![Capacity Provider on OD ASG](/images/ecs-spot-capacity-providers/CP_OD.png)

Some explanations about what you are building:

* *Managed Scaling*: When managed scaling is enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group through the use of AWS Auto Scaling scaling plans. When managed scaling is disabled, you manage the scaling aspect of your Auto Scaling groups yourself.

* *Managed termination protection*: When managed termination protection is enabled, Amazon ECS prevents Amazon EC2 instances that contain tasks and that are in an Auto Scaling group from being terminated during a scale-in action. Managed termination protection can only be enabled if the Auto Scaling group also has instance protection from scale in enabled

Refresh the *Capacity Providers* tab and you will see the CP-OD is created and attachd to the cluster.

![Capacity Provider on OD ASG](/images/ecs-spot-capacity-providers/CP_OD1.png)

Now you will see that the CP creates a target tracking policy on the EcsSpotWorkshop-ASG-OD. Go to the AWS EC2 Console and select this scaling policies tab on this ASG.

![OD ASG](/images/ecs-spot-capacity-providers/ASG1.png)