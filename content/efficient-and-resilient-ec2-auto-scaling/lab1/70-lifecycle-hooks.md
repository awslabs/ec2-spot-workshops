+++
title = "Take control of instance Lifecycle"
weight = 170
+++

You have successfully configured scaling policies in your Auto Scaling Group. However, you still need to solve **the challenge of instances long time of initiation, taking 5-10 minutes to start up**. Previously, you were manually scaling ahead of time, attempting to beat the increase in traffic. Manually scaling with the long warm up time was not accurate and reduced the effectiveness or missed scale event.

You have attempted to work with the application owners to speed up boot strapping and instance warm up time, whilst there has been some improvement, it is not possible to speed this process up further without a complete re-architecture of the application.

When looking at how to fix slow warm up times in Auto Scaling Groups, you came across a feature called Warm Pools. You can now pre-initialize instances and stop them, ready for scale-out when needed. You hope this will significantly reduce the time it takes to scale-out and reduce the time of the boot strapping procedure that currently is impacting your ability to scale-out efficiently.

You've also came across another feature called **Lifecycle hooks**, which could help you in taking control of the instances lifecycle , **let's explore it first** before we start working with warm pools.

### Lifecycle hooks

Amazon EC2 Auto Scaling offers the ability to add lifecycle hooks to your Auto Scaling groups. These hooks let you create solutions that are aware of events in the Auto Scaling instance lifecycle, and then perform a custom action on instances when the corresponding lifecycle event occurs.

### How it works?

An Amazon EC2 instance transitions through different states from the time it launches until it is terminated. You can create lifecycle hooks to act when an instance transitions into a wait state.

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/lifecycle-hooks.png)

### Create a Lifecycle hook

Instance launching

Run this command to create a lifecycle hook to control instance launching.

```bash
aws autoscaling put-lifecycle-hook \
    --auto-scaling-group-name ec2-workshop-asg \
    --lifecycle-hook-name ec2-workshop-launch-hook \
    --lifecycle-transition autoscaling:EC2_INSTANCE_LAUNCHING \
    --heartbeat-timeout 300 \
    --default-result CONTINUE
```
