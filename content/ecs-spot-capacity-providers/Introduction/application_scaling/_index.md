+++
title = "Scaling ECS Workloads"
weight = 20
+++


There are two kinds of scaling in ECS Workloads

* **ECS Service / Application Scaling**: This refers to the ability to increase or decrease the desired count of tasks in your Amazon ECS service based on dynamic traffic and load patterns in the workload.  Amazon ECS publishes CloudWatch metrics with your service’s average CPU and memory usage.You can use these and other CloudWatch metrics to scale out your service (add more tasks) to deal with high demand at peak times, and to scale in your service (run fewer tasks) to reduce costs during periods of low utilization. 

* **ECS Container Instances Scaling**: This refers to the ability to increase or decrease the desired count of EC2 instances in your Amazon ECS luster based on ECS Service / Application scaling. For this kind of scaling, it is typical practice depending upon Autoscaling group level scaling policies. However, ensuring that the number of EC2 instances in your ECS cluster would scale as needed to accommodate your tasks and services could be challenging.  ECS clusters could not always scale out when needed, and scaling in could impact availability unless handled carefully.  The next few sections discuss these challenges in detail and offer solutions to address them.
