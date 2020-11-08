---
title: "Create an ECS service"
weight: 55
---

In this section, we will create an ECS service which uses the default cluster capacity provider strategy to spread tasks on CP-OD and CP-SPOT: **CP-OD base=2 & weight=1** and **CP-SPOT weight=3**. This capacity provider strategy created based on the following application requirements:

* There should be at least 2 tasks running on On-Demand instances to serve the normal traffic. The **base=2** configuration satisfies this requirement.
* Any additional traffic should be handled by tasks deployed on On-Demand and Spot Instances in the ratio of 1:3

To create the service, follow these steps:

* Select the **Services** Tab in the [ECS Cluster](https://console.aws.amazon.com/ecs/home?#/clusters/EcsSpotWorkshop/services)
* Click on **Create**
* For Capacity provider strategy, leave it to default value **Cluster default Strategy**
* For Task Definition Family, select **ec2-task**
* For Task Definition Revision, select **1**
* For Cluster, leave default value **EcsSpotWorkshop**
* For Service name, **ec2-service-split**
* For Service type, leave it to the default value **REPLICA**
* For Number of tasks, enter **10**

![Service](/images/ecs-spot-capacity-providers/Ser1.png)

* Leave the default values for **Minimum healthy percent** and **Maximum percent**
* Under Deployments section, leave it to default values
* Under Task Placement section, for Placement Templates, select **BinPack**
* Under Task tagging configuration section, leave it to default values
* Click on **Next Step**

![Service Binpack](/images/ecs-spot-capacity-providers/ser2.png)

* Under Configure network section, in Load balancing, for Load balancer type*, select **Application Load Balancer**
* For Service IAM role, leave default value
* For Load balancer name, select **EcsSpotWorkshop**

![Service ALB](/images/ecs-spot-capacity-providers/ecs_service_alb.png)

* Under Container to load balance, for Container name : port, click on **add to load balancer**
* For Production listener port,  Select **HTTP:80** from the dropdown list
* For Production listener protocol, leave default value of **HTTP**
* For Target group name, select **EcsSpotWorkshop** from the list
* Leave default values for *Target group protocol*, *Target type*, *Path pattern*, *Health check path*
* Click on **Next Step**

![Service ALB Target Group](/images/ecs-spot-capacity-providers/ecs_service_alb_listener.png)

* Under Set Auto Scaling (optional), leave default value for service auto scaling
* Click on **Next Step**
* Click on **Create Service**
* Click on **View Service**







