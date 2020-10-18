+++
title = "Application Scaling: Infrastructure First Approach"
weight = 20
+++


The Infrastructure first approach means estimating how much compute capacity your application might need and provision server components (EC2 Instances) based on it. In other words, your Infrastructure will start first before you application starts which is a notion we call - Infrastructure First. 

In the existing architecture with EC2 Auto Scaling groups used for your ECS Cluster, you provision the infrastructure first, which will create EC2 instances and then run (schedule) the ECS tasks on this capacity using the EC2 Launch Type. In this case, running any task/service fails if there are no instances in the Auto Scaling group. However, there are few challenges with this approach.

1. ECS Cluster Scaling: The EC2 Auto Scaling Group scaling policies typically use metrics related to EC2 Instance vCPU/Memory Utilization. However, these metrics may not correlate well with the vCPU/Memory resource requirements of the ECS Tasks scaled OUT/IN due to ECS Service (Application) Scaling. So there may be a disconnect between ECS Service Scaling and EC2 Instance Scaling. This is because the EC2 Autoscaling groups are not aware of ECS Tasks in the Cluster and vice versa.  Also, the Autoscaling scale OUT/IN polices are based on resource utilization of the already existing EC2 instances in the ECS Cluster, but do not account for the new EC2 tasks resulting from ECS Service Scaling OUT. This may slow down the ECS Cluster Scaling and impact the Application availability. 

2. Instance Termination: During the scaling IN activity, EC2 Autoscaling group may choose (In accordance with the instance termination policy)an Instance which is running tasks since it is not aware of the EC2 tasks in the ECS Cluster.  This may cause disruption to the applications.
