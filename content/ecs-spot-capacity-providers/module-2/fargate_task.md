---
title: "Create ECS Fargate Tasks"
chapter: true
weight: 1
---

###  Create ECS Fargate Tasks

In this section, we will create a task definition for for tasks to be launched on the Fargate Capacity Providers.

Run the below command to create the task definition

```
aws ecs register-task-definition --cli-input-json file://webapp-fargate-task.jso
```

The task will look like this in console

PIC: TBD