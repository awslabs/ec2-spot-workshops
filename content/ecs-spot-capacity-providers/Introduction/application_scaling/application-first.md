+++
title = "Cluster Scaling: Application First Approach"
weight = 55
+++

The Application First approach refers that you focus on your application availability, scalability and other aspects and let infrastructure react dynamically to meet the requirements. 
We explore Amazon ECS capacity providers and Amazon ECS cluster auto scaling (CAS) along with EC2 Auto Scaling groups to achieve our Application First approach.

Amazon ECS cluster capacity providers determine the infrastructure to use for your tasks. 

Amazon ECS cluster auto scaling enables you to have more control over how you scale tasks within a cluster.

The capacity provider configuration includes the following fields.

An *Autoscaling group* to associate with the capacity provider. The Autoscaling group must already be created. 

*Managed scaling*, if enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group through the use of AWS Auto Scaling scaling plans. This also means you can scale up your ECS cluster zero capacity in the Auto Scaling group.  

*Target capacity %*, if managed scaling enabled, specify an integer between 1 and 100. This value used as the target value for the CloudWatch metric used in the Amazon ECS-managed target tracking scaling policy. 

*Managed termination protection*, when enabled, Amazon ECS prevents Amazon EC2 instances that contain tasks and that are in an Auto Scaling group from being terminated during a scale-in action.

 Each cluster can have one or more capacity providers and an optional default capacity provider strategy.  
 
*Capacity provider strategy*: A capacity provider strategy gives you control over how your tasks use one or more capacity providers.

*Default capacity provider strategy*: A default capacity provider strategy associated with each Amazon ECS cluster. This determines the capacity provider strategy the cluster will use if no other capacity provider strategy or launch type specified when running a task or creating a service.

