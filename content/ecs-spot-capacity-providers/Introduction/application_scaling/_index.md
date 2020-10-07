+++
title = "Application Scaling-Infrastructure First Approach"
weight = 20
+++


Its estimating how much compute capacity your application might need and provision server components based on it. In other words, your Infrastructure will start first before you application starts which is a notion we call - Infrastructure First. However this has few challenges.

In the existing architecture with EC2 ASG used for ECS Cluster,  you provision the infrastructure first (i.e. EC2 ASG) which will create instances (i.e. capacity) and then run your application services/tasks on this capacity using the EC2 Launch Type. In this case, running any task/service fails if there are no instances (zero capacity) in the ASG.

1. ECS is unaware of the EC2 ASGs. So there is disconnect between the application tasks resource requirements and EC2 ASG scale out/in policies.  The ASG scale out/in polices are based on the tasks or instances which are already running in that cluster and does not account for the new application tasks which needs to be scheduled. This means ASG custom scaling policies may not scale out/in well as per the application requirements.

2. EC2 ASG are unaware of the containers/tasks running in the ECS Cluster which may cause termination of instances running tasks during the scale in acitivity.
