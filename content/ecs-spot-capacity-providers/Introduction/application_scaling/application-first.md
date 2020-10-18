+++
title = "Application Scaling: Application First Approach"
weight = 55
+++

The Application first approach refers that you focus on your application availability, scalability and other aspects and let infrastructure react dynamically to meet the requirements. ECS capacity providers enable you to manage the infrastructure the tasks in your clusters use.

We explore Amazon ECS capacity providers and Amazon ECS Cluster Auto Scaler(CAS) along with Autoscaling groups to achieve our Application First approach.

The capacity provider configuration includes the following fields.

An *Autoscaling group* to associate with the capacity provider. The Autoscaling group must already be created. 

*Managed scaling*, if enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group through the use of AWS Auto Scaling scaling plans. This also means you can scale up your ECS Cluster zero capacity in the Autoscaling group. When managed scaling is disabled, you manage your AutoScaling groups yourself.   

*Target capacity %*, if managed scaling enabled, specify an integer between 1 and 100. This value used as the target value for the CloudWatch metric used in the Amazon ECS-managed target tracking scaling policy.  A value of 100 means that managed scaling provides just enough capacity in the EC2 autoscaling group required to run the EC2 tasks assigned to this capacity provider.  A value of 80 means, managed scaling provides 20% extra capacity in the EC2 autoscaling group that means only 80% of capacity required to run the EC2 tasks assigned to this capacity provider. So you can use this field to configure a warm pool of instance (i.e. standby capacity) for specific application which needs faster response time.

*Managed termination protection*, when enabled, Amazon ECS prevents Amazon EC2 instances that contain tasks and that are in an Auto Scaling group from being terminated during a scale-in action. Managed termination protection can only be enabled if the Auto Scaling group also has instance protection from scale in enabled and if managed scaling is enabled.


 Each cluster can have one or more capacity providers and an optional default capacity provider strategy. The capacity provider strategy determines how the tasks are spread across the cluster's capacity providers.
 
 
*Capacity Provider Strategy*: A Capacity Provider Strategy allows the application provide an intent on how tasks should be distributed across different CPs based on the weights. A default capacity provider strategy can be defined for the Cluster. Each service or tasks run API call can specify a different strategy overriding the default strategy.The capacity provider strategy allows two fields base and weight. The base parameter ensures minimum number of tasks deployed in that capacity provider.  The remaining tasks will be deployed across capacity providers based on their relative weights.

