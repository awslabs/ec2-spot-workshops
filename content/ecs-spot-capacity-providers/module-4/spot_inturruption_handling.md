---
title: "Spot Interruption Handling on EC2 Spot Instances"
chapter: true
weight: 5
---

### Spot Interruption Handling on EC2 Spot Instances

When Amazon EC2 is going to interrupt your Spot Instance, the interruption notification will be available in two ways

**Amazon CloudWatch Events**

EC2 service emits an event two minutes prior to the actual interruption. This event can be detected by Amazon CloudWatch Events.

**instance-action in the MetaData service (IMDS)**

If your Spot Instance is marked to be stopped or terminated by the Spot service, the instance-action

item is present in your instance metadata.

### Spot Interruption Handling on ECS Fargate Spot

When tasks using Fargate Spot capacity are stopped due to a Spot interruption, a two-minute warning

is sent before a task is stopped. The warning is sent as a task state change event to Amazon EventBridge

and a SIGTERM signal to the running task. When using Fargate Spot as part of a service, the service

scheduler will receive the interruption signal and attempt to launch additional tasks on Fargate Spot if

capacity is available.

To ensure that your containers exit gracefully before the task stops, the following can be configured:

• A stopTimeout value of 120 seconds or less can be specified in the container definition that the task

is using. Specifying a stopTimeout value gives you time between the moment the task state change

event is received and the point at which the container is forcefully stopped.

• The SIGTERM signal must be received from within the container to perform any cleanup actions.
