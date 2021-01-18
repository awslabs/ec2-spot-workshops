---
title: "Create an ECS cluster"
weight: 20
---

Let us first create an empty ECS cluster.

To create an ECS cluster, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you are looking to launch your cluster.
* Click **Create Cluster**
* Under *Select cluster template* select **EC2 Linux + Networking**

![ECS Cluster](/images/ecs-spot-capacity-providers/ecs_cluster_type.png)

* Click **Next step**
* Under *Configure cluster* for *Cluster name*, enter **EcsSpotWorkshop**
* Select the checkbox **Create an empty cluster**
* Select the checkbox **Enable Container Insights**

{{% notice info %}}
**CloudWatch Container Insights** collects, aggregates, and summarizes metrics and logs from your containerized applications and microservices. It collects metrics for many resources, such as CPU, memory, disk, and network. Container Insights is available for Amazon Elastic Container Service (Amazon ECS), Amazon Elastic Kubernetes Service (Amazon EKS), and Kubernetes platforms on Amazon EC2. Amazon ECS support includes support for Fargate. You can **[read more about CloudWatch Container Insights here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)**. 
{{% /notice %}}

![ECS Cluster](/images/ecs-spot-capacity-providers/ecs_create_cluster.png)

* Click **Create**
* Click **View Cluster**
* Click **Capacity Providers** tab
 
The new ECS cluster will appear as below in the AWS Console.  

![ECS Cluster](/images/ecs-spot-capacity-providers/ecs_empty_cluster.png)


