+++
title = "Cluster Scaling: Infrastructure First Approach"
weight = 50
+++
The Infrastructure First approach means estimating how much compute capacity your application might need and provision server components (EC2 Instances) based on it. Your Infrastructure will start first before your application starts which is a notion we call - Infrastructure First. 

However, ensuring that the number of EC2 instances in your ECS cluster would scale as needed to accommodate your tasks and services could be a challenging task.  ECS clusters may not always scale out when needed, and scaling in could affect availability unless handled carefully.
