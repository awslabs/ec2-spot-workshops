---
title: "Create ECS Fargate Tasks"
weight: 10
---

In this section, we will register a task definition for fargate tasks.

Run the command below to create the task definition

```
aws ecs register-task-definition --cli-input-json file://fargate-task.json
```

The task will look like this in the console

![Fargate Task](/images/ecs-spot-capacity-providers/fargate_task1.png)
