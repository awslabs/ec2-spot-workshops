+++
title = "Application Scaling"
weight = 20
+++


Infrastructure first approach means estimating how much compute capacity your application might need and provision server components (EC2 Instances) based on it. In other words, your Infrastructure will start first before you application starts which is a notion we call - Infrastructure First. However, this has few challenges.

In the existing architecture with EC2 Auto Scaling groups used for your ECS Cluster, you provision the infrastructure first, which will create EC2 instances and then run (schedule) the ECS tasks on this capacity using the EC2 Launch Type. In this case, running any task/service fails if there are no instances (zero capacity) in the Auto Scaling group

1. ECS is unaware of the EC2 ASGs. So there is disconnect between the application tasks resource requirements and EC2 ASG scale out/in policies.  The ASG scale out/in polices are based on the tasks or instances which are already running in that cluster and does not account for the new application tasks which needs to be scheduled. This means ASG custom scaling policies may not scale out/in well as per the application requirements.

2. EC2 ASG are unaware of the containers/tasks running in the ECS Cluster which may cause termination of instances running tasks during the scale in acitivity.
