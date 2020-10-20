---
title: "Create an EC2 launch template"
weight: 8
---

- EC2 Launch Templates reduce the number of steps required to create an instance by capturing all launch parameters within one resource.

- For example, a launch template can contain the ECS optimized AMI, instance type, User data section, Instance Profile / Role, and network settings that you typically use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, a command line tool or an EC2 Auto Scaling group (like we will use in this workshop), you can specify the launch template to use. 

- The EC2 Launch Template is already created using the CloudFormation stack - you can use the AWS Management Console to see the configuration. Please note that Launch templates are mandatory in order to use EC2 Auto Scaling groups with mixed instances policy (to allow for mixing On-Demand and Spot Instances in an Auto Scaling group, and diversifying the instance type selection)

![Launch Template](/images/ecs-spot-capacity-providers/c9_6.png)

Also review the user data section of the Launch Template to see ECS Container agent configuration.

![User Data](/images/ecs-spot-capacity-providers/c9_7.png)

- *ECS_CONTAINER_STOP_TIMEOUT*: Time to wait from when a task is stopped before its containers are forcefully stopped if they do not exit normally on their own

- *ECS_ENABLE_SPOT_INSTANCE_DRAINING*: Whether to enable Spot Instance draining for the container instance. When true, if the container instance receives a Spot interruption notice, then the agent sets the instance status to DRAINING, which gracefully shuts down and replaces all tasks running on the instance that are part of a service.

- *ECS_ENABLE_CONTAINER_METADATA*: When true, the agent creates a file describing the container's metadata. The file can be located and consumed by using the container environment variable $ECS_CONTAINER_METADATA_FILE
