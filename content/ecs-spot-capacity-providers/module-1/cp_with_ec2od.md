---
title: "Create On-demand ASG Capacity Provider"
weight: 11
---

To create the CP, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you deployed the CFN template
* Click **Clusters**
* Click [EcsSpotWorkshop] (https://console.aws.amazon.com/ecs/home#/clusters/EcsSpotWorkshop)
* Click the tab **Capacity Providers**
* Click **Create**
* For Capacity provider name, enter **CP-OD**
* For Auto Scaling group, select **EcsSpotWorkshop-ASG-OD**
* For Managed Scaling, leave with default selection of **Enabled**
* For Target capacity %, enter **100**
* For Managed termination protection, leave with default selection of **Enabled**
* Click on **Create** on the bottom right 

![Capacity Provider on OD ASG](/images/ecs-spot-capacity-providers/CP_OD.png)

Refresh the *Capacity Providers* tab and you will see the CP-OD is created and attachd to the cluster.

![Capacity Provider on OD ASG](/images/ecs-spot-capacity-providers/CP-OD.png)

Now you will see that the capacity provider creates a target tracking policy on the EcsSpotWorkshop-ASG-OD. 
Go to the [AWS EC2 Console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-OD?view=scaling) and select the Automatic Scaling tab on this ASG.

![OD ASG](/images/ecs-spot-capacity-providers/asg_od_with_cp_view_1.png)