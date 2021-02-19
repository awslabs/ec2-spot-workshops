---
title: "Create ECS Fargate Tasks"
weight: 10
---

In this section, we will register a task definition for Fargate tasks. Run the command below to create the task definition

```
aws ecs register-task-definition --cli-input-json file://fargate-task.json
```

{{% notice tip %}}
Take some time to read the Fargate task definition **fargate-task.json** file. Check the setting of properties such as 
**requiresCompatibilities** and read more about **[Fargate Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/userguide/fargate-task-defs.html)** documentation.
{{% /notice %}}

The task will look like this in the console

![Fargate Task](/images/ecs-spot-capacity-providers/fargate_task1.png)
