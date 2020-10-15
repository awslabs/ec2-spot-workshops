---
title: "Module-2: Spot Interruption Handling"
weight: 40
---

Inturruption Handling On EC2 Spot Instances
---

Amazon EC2 terminates your Spot Instance when it needs the capacity back. Amazon EC2 provides a Spot Instance interruption notice, which gives the instance a two-minute warning before it is interrupted.

When Amazon EC2 is going to interrupt your Spot Instance, the interruption notification will be available in two ways:

1. ***Amazon EventBridge Events:*** EC2 service emits an event two minutes prior to the actual interruption. This event can be detected by Amazon CloudWatch Events.

1. ***EC2 Instance Metadata service (IMDS):*** If your Spot Instance is marked for termination by EC2, the instance-action item is present in your instance metadata.

In the Launch Template configuration, we added:
```plaintext
echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=true" >> /etc/ecs/ecs.config
```
When Amazon ECS Spot Instance draining is enabled on the instance, ECS receives the Spot Instance interruption notice and places the instance in DRAINING status. When a container instance is set to DRAINING, Amazon ECS prevents new tasks from being scheduled for placement on the container instance [Click here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-spot.html) to learn more.

The web application (app.py) we used to buld docker image in this module shows two ways to handle the EC2 Spot interruption within a docker container. This allows you to perform actions such as preventing the processing of new work, checkpointing the progress of a batch job, or gracefully exiting the application to complete tasks such as ensuring database connections are properly closed

In the first method, it checks the instance metadata service for spot interruption and display a message to web page notifying the users (this is, of course, just a demonstration and not for real-life scenarios).

{{% notice warning %}}
In a production environment, you should not provide access from the ECS tasks to the IMDS. This is done in this workshop for simplification purposes.
{{% /notice %}}


```plaintext
URL = "http://169.254.169.254/latest/meta-data/spot/termination-time"
SpotInt = requests.get(URL)
if SpotInt.status_code == 200:
    response += "<h1>This Spot Instance will be terminated at: {} </h1> <hr/>".format(SpotInt.text)
```

In the second method, it listens to the **SIGTERM** signal. The ECS container agent calls the StopTask API to stop all the tasks running on the Spot Instance.

When StopTask is called on a task, the equivalent of docker stop is issued to the containers running in the task. This results in a **SIGTERM** value and a default 30-second timeout, after which the SIGKILL value is sent and the containers are forcibly stopped. If the container handles the **SIGTERM** value gracefully and exits within 30 seconds from receiving it, no SIGKILL value is sent.

```python
class Ec2SpotInterruptionHandler:
  signals = {
    signal.SIGINT: 'SIGINT',
    signal.SIGTERM: 'SIGTERM'
  }

def __init__(self):
   signal.signal(signal.SIGINT, self.exit_gracefully)
   signal.signal(signal.SIGTERM, self.exit_gracefully)

def exit_gracefully(self, signum, frame):
   print("\nReceived {} signal".format(self.signals[signum]))
   if self.signals[signum] == 'SIGTERM':
     print("Looks like there is a Spot Interruption. Let's wrap up the processing to avoid forceful killing of the applucation in next 30 sec ...")
```

Spot Interruption Handling on ECS Fargate Spot
---

When tasks using Fargate Spot capacity are stopped due to a Spot interruption, a two-minute warning is sent before a task is stopped. The warning is sent as a task state change event to Amazon EventBridge
and a SIGTERM signal to the running task. When using Fargate Spot as part of a service, the service
scheduler will receive the interruption signal and attempt to launch additional tasks on Fargate Spot if
capacity is available.

To ensure that your containers exit gracefully before the task stops, the following can be configured:

• A stopTimeout value of 120 seconds or less can be specified in the container definition that the task
is using. Specifying a stopTimeout value gives you time between the moment the task state change event is received and the point at which the container is forcefully stopped. 

• The **SIGTERM** signal must be received from within the container to perform any cleanup actions.

