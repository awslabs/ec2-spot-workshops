+++
title = "Cluster Scaling: Infrastructure First vs Application First"
weight = 10
+++

There are different approaches for scaling a system. In this section we focus in the differences between Infrastructure First and Application First. During the Workshop we will use Application First as the main approach to scale our ECS Cluster.

## Infrastructure First Approach

In infrastructure First, we focus on infrastructure metrics and make decissions that drive the scale of our cluster. The application then is started and accomodates to whatever capacity that is provided. For example , we can estimate how much compute capacity our application might need and provision EC2 Instances (Infrastructure) accordingly. In doing so, the infrastructure will launch and be running before the application gets started, hence the *Infrastructure First* name. However, ensuring that the number of EC2 instances in our ECS cluster would scale as needed to accommodate our tasks and services can be challenging in some cases. ECS clusters may not always scale out when needed, and scaling in could affect availability unless handled carefully.


## Application First Approach

Unlike in the Infrastructure First, in this case we focus on scaling the application. The increase and scaling out the infrastructure is a side-effect of scaling the application. The goal of **Application First** is to focus on the application availability, scalability, and let the infrastructure react dynamically to meet the requirements. In this workshop we explore Amazon ECS capacity providers and Amazon ECS cluster auto scaling (CAS) along with EC2 Auto Scaling groups to implement an Application First approach.

To implement the Application First approach on ECS, we will use Amazon ECS cluster **Capacity Providers** to determine the infrastructure in use for our tasks and we will use Amazon ECS **Cluster Auto Scaling** (CAS) to enables to manage the scale of the cluster according to the application needs.

Capacity Providers configuration include:

* An *Auto Scaling Group* to associate with the capacity provider. The Autoscaling group must already exist.
* An attribute to enable/disable **Managed scaling**; if enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group through the use of AWS Auto Scaling scaling plan also referred to as **Cluster Auto Scaling** (CAS). This also means you can scale up your ECS cluster zero capacity in the Auto Scaling group.  
* An attribute to define the **Target capacity %(percentage)** - number between 1 and 100. When **managed scaling** is enabled this value is used as the target value against the metric used by Amazon ECS-managed target tracking scaling policy. 
* An attribute to define *Managed termination protection*. which prevents EC2 instances that contain ECS tasks and that are in an Auto Scaling group from being terminated during scale-in actions.


Each ECS cluster can have one or more capacity providers and an optional default capacity provider strategy. For an ECS Cluster there is a **Default capacity provider strategy** that can be set for Newly created tasks or services on the cluster that are created without an explicit strategy. Otherwise, for those services or tasks where the default capacity provider strategy does not meet your needs you can define a **capacity provider strategy** that is specific for that service or task.

{{% notice info %}}
You can read more about **Capacity Provider Strategies** [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html)
{{% /notice %}}

