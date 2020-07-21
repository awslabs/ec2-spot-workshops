---
title: "Create an EC2 launch template"
chapter: true
weight: 5
---

Create an EC2 launch template
---

- EC2 Launch Templates reduce the number of steps required to create an instance by capturing all launch parameters within one resource.

- You can create a launch template that contains the configuration information to launch an instance. Launch templates enable you to store launch parameters so that you do not have to specify them every time you launch an instance. For example, a launch template can contain the ECS optimized AMI, instance type, User data section, Instance Profile / Role and network settings that you typically use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the launch template to use. Instance user data required to bootstrap the instance into the ECS Cluster.

- The Ec2 Launch Template is already created using the CFN stack. Take a moment to see the configuration.  Please note that Launch templates are mandatory to use Mixed Instance Group (i.e. using on-demand and spot purchase options) in an Autoscaling group.

![Launch Template](/images/ecs-spot-capacity-providers/c9_6.png)

Also review the user data section of the Launch Template to see ECS Container agent configuration.

![User Data](/images/ecs-spot-capacity-providers/c9_7.png)

- *ECS_CONTAINER_STOP_TIMEOUT*: Time to wait from when a task is stopped before its containers are forcefully stopped if they do not exit normally on their own

- *ECS_ENABLE_SPOT_INSTANCE_DRAINING*: Whether to enable Spot Instance draining for the container instance. When true, if the container instance receives a Spot interruption notice, then the agent sets the instance status to DRAINING, which gracefully shuts down and replaces all tasks running on the instance that are part of a service.

- *ECS_ENABLE_CONTAINER_METADATA*: When true, the agent creates a file describing the container's metadata. The file can be located and consumed by using the container environment variable $ECS_CONTAINER_METADATA_FILE
