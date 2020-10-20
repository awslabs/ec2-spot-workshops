---
title: "Create an EC2 launch template"
weight: 5
---

Let us first create an empty ECS Cluster.

To create an ECS Cluster, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you are looking to launch your cluster.
* Click **Create Cluster**
* Under *Select cluster template* select **EC2 Linux + Networking**

![ECS Cluster](/images/ecs-spot-capacity-providers/ecs_cluster_type.png)

* Click **Next step**
* Under *Configure cluster* for *Cluster name*, enter **EcsSpotWorkshop**
* Select the checkbox **Create an empty cluster**
* Select the checkbox **Enable Container Insights**

![ECS Cluster](/images/ecs-spot-capacity-providers/ecs_create_cluster.png)

* Click **Create**
* Click **View Cluster**
* Click **Capacity Providers** tab
 
The new ECS cluster will look like below in the AWS Console.  

![ECS Cluster](/images/ecs-spot-capacity-providers/ecs_empty_cluster.png)


