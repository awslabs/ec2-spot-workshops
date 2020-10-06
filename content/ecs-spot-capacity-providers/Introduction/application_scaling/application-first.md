+++
title = "Application Scaling"
chapter = true
weight = 55
+++

Application Scaling: Application First Approach
---
<p style="text-align: justify;">
It refers that you focus on your application availability, scalability and other aspects and let infrastructure react dynamacally to meet the requirements. 
<br><br>
We explore Amazon ECS Capacity Providers(CP) and Amazon ECS Cluster Auto Scaler(CAS) along with Auto Scaling Groups to achieve our Application First approach.
<br><br>
ECS capacity providers enable you to manage the infrastructure the tasks in your clusters use. Each cluster can have one or more capacity providers and an optional default capacity provider strategy. The capacity provider strategy determines how the tasks are spread across the cluster's capacity providers
<br><br>
The CP definition will have the following configuration.
<br><br>
An *ASG* to associate with the capacity provider. The Auto Scaling group must already be created. 
<br><br>
*Target Capacity(TC) %*, if managed scaling is enabled, specify an integer between 1 and 100. The target capacity value is used as the target value for the CloudWatch metric used in the Amazon
ECS-managed target tracking scaling policy.  A value of 100 means 100% of the ASG capacity (i.e. instances) are used for the tasks and there is no idle or standby capacity available. A value of 70 means only 70% of the ASG capacity is used to run all the tasks assigned to that ASG and 30% is idle or standby capacity available.
<br><br>
*Managed termination protection*, when enabled, Amazon ECS prevents Amazon EC2 instances that contain tasks and that are in an ASG  from being terminated during a scale-in action. Managed termination protection can only be enabled if the Auto Scaling group also has instance protection from scale in enabled and if managed scaling is enabled. 
<br><br>
You can also run the application tasks/service even if there are no instances (zero capacity) in the ASG. In this case, tasks does not run immediately and instead waits in provisioning state for the CP provision the required capacity. That means the EC2 ASG scale out from zero capacity. A CP definition is independent of the actual infrastructure (i.e. instances) running in the cluster.  A CP also provides access control as to which user can access which CP using the IAM Roles.
<br><br>
*Capacity Provider Strategy(CPS)*: A Capacity Provider Strategy (CPS) allows the application provide an intent on how tasks should be distributed across different CPs based on the weights. A default CPR can be defined for the Cluster. Each service or tasks run API call can have its own CPS or Launch Type which will override the defailt CPS. 
<br><br>
In addition to the weight, CP also supports a base parameter which ensures the minimum number of tasks on that CP.  Please note there can be only one CP with a non-zero base value in an ECS.
<br><br>
Below table shows various example scenarios on how to use weight and base parameters for different distribution of tasks across CPs.
</p><br>

| CP strategy | Total  Tasks | Tasks on CP-OD | Tasks on CP-SPOT | Comments |
| --- | --- | --- | --- | --- |
| CP-OD weight=1; CP-SPOT weight=0 |	10 | 10 | 0	| Distribute all the service tasks on CP-OD |
| CP-SPOT weight=1; CP-OD weight=0 | 10 | 0 | 10 | Distribute all the service tasks on CP-SPOT |
| CP-OD weight=1; CP-SPOT weight=3 | 12 | 3 | 9 |For every 1 task on CP-OD, 3 tasks will be placed on CP-SPOT |
| CP-OD base=2 weight=1; CP-SPOT weight=3 | 10 | 4 | 6 |	First 2 tasks (as per base value) will be placed CP-OD and for the remaining 8 tasks, for every 1 task on CP-OD, 3 will be placed on CP-SPOT. |

A CP can be a ASG or fargate or fargate spot. An ECS cluster can have up to 6 CPs.