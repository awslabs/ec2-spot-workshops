---
title: "EC2 Spot Interruption Handling in ECS"
weight: 100
---

The Amazon EC2 service interrupts your Spot instance when it needs the capacity back. It provides a Spot instance interruption notice, 2 minutes before the instance gets terminated. The EC2 spot interruption notification is available in two ways:

1. **Amazon EventBridge Events:** EC2 service emits an event two minutes prior to the actual interruption. This event can be detected by Amazon CloudWatch Events.

1. **EC2 Instance Metadata service (IMDS):** If your Spot Instance marked for termination by EC2, the instance-action item is present in your instance metadata.

While for EC2 applications we may need to provide an implementation to handle the events described above so we can gracefully terminate our
application uppon a Spot notification for termination, that is not the case with ECS. On ECS, the ECS agent deployed on the instances, can be configured to automatically capture and handle the Spot interruption instance 
notification. You can [read more in the ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-spot.html)

During this workshop, the Launch Template that we used to create the Auto Scaling Groups had the following entry:
```plaintext
echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=true" >> /etc/ecs/ecs.config
```

When Amazon ECS Spot instance draining is enabled on the instance, the ECS container agent receives the Spot instance interruption notice and places the instance in DRAINING status.


## Graceful application termination

By enabling the `ECS_ENABLE_SPOT_INSTANCE_DRAINING` in the ECS agent configuration, the ECS agent will monitor the Spot interruption
signal and place the instance in `DRAINING` status. When an instance is set to `DRAINING` Amazon ECS prevents new tasks from being scheduled
on the instance. Tasks will also are moved from RUNNING to STOPPED state using the [SpotTask API](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_StopTask.html). The StopTask API is the equivalent of docker stop, it is issued to the containers running in the task and results in 
a **SIGTERM** System V signal sent to the application. 

As a best practice application should capture the **SIGTERM** signal and implement a graceful termination mechanism. By default ECS Agent does
up to `ECS_CONTAINER_STOP_TIMEOUT`, by default 30 seconds, to handle the graceful termination of the process. After the 30 seconds a **SIGKILL** 
signal is sent and the containers are forcibly stopped. The `ECS_CONTAINER_STOP_TIMEOUT` can be extended to provide some extra time, but 
note that anything above the 120 seconds (2 minute notification for Spot) will result in a Spot termination.

For this workshop we used a Python application. The code snippet below shows how our python application can capture the 
IPC (Inter Process Communication) relevant signals and call a specific method `exit_gracefully` to coordinate graceful termination
activities. The code below is obviously is a simplification, as the coordination may require coordinating threads and become more complex.
Implementing a graceful termination is however highly recommended to among other things:

* Log the reason the process is being terminated
* Release resources. For example terminate connection with databases so that the Database can re-use those connections with other instances
* Complete in-flight operations but stop processing new operations
* Flush buffers and do best effort checkpointing (note there is a 30sec to 120sec limit)
* ...


```python
class Ec2SpotInterruptionHandler:
  def __init__(self):
    signal.signal(signal.SIGINT, self.exit_gracefully)
    signal.signal(signal.SIGTERM, self.exit_gracefully)

  def exit_gracefully(self, signum, frame):
    print("\nReceived {} signal".format(self.signals[signum]))
    if self.signals[signum] == 'SIGTERM':
      print("SIGTERM Signal Received. Let's wrap up..")
```

***Congratulations!*** you have successfully completed the section on *Using Spot Instances with Auto Scaling groups capacity providers*. 

You may continue to **optional** section on how to save costs using ***Fargate Spot*** capacity providers.

