---
title: "Create ECS Tasks for EC2 Capacity Providers"
chapter: true
weight: 20
---

### Create ECS Tasks for EC2 Capacity Providers

In this section, we will create a task definition for for tasks to be launched on the Auto Scaling Capacity Providers.

Run the below command to create the task definition

```
aws ecs register-task-definition --cli-input-json file://webapp-ec2-task.json
WEBAPP_EC2_TASK_DEF=$(cat webapp-ec2-task.json | jq -r '.family')
```

The task will look like this in console

Image: TBD