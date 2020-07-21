---
title: "Create ECS Fargate Tasks"
chapter: true
weight: 1
---

Create ECS Fargate Tasks
---

In this section, we will create a task definition for for tasks to be launched on the Fargate Capacity Providers.

Run the below command to create the task definition

```
aws ecs register-task-definition --cli-input-json file://fargate-task.json
```

The task will look like this in console

![Fargate Task](/images/ecs-spot-capacity-providers/fargate_task1.png)
