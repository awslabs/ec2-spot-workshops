+++
title = "Tasks and Scheduling"
weight = 25
+++

A task is the instantiation of a task definition within a cluster. After you have created a task definition for your application within Amazon ECS, you can specify the number of tasks that will run on your cluster.

Each task that uses the Fargate launch type has its own isolation boundary and does not share the underlying kernel, CPU resources, memory resources, or elastic network interface with another task.

The Amazon ECS task scheduler is responsible for placing tasks within your cluster. There are several different scheduling options available. For example, you can define a service that runs and maintains a specified number of tasks simultaneously. For more information about the different scheduling options available, see [Scheduling Amazon ECS Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/scheduling_tasks.html).