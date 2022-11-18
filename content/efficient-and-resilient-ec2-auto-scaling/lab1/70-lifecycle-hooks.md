+++
title = "Take control of instance Lifecycle"
weight = 170
+++

You have successfully deployed a Predictive Scaling policy to your Auto Scaling Group. However, you still need to solve the challenge of instances taking 5-10 minutes to start up. Previously, you were manually scaling ahead of time, attempting to beat the increase in traffic. Manually scaling with the long warm up time was not accurate and reduced the effectiveness or missed scale event.

### Lifecycle hooks

Amazon EC2 Auto Scaling offers the ability to add lifecycle hooks to your Auto Scaling groups. These hooks let you create solutions that are aware of events in the Auto Scaling instance lifecycle, and then perform a custom action on instances when the corresponding lifecycle event occurs. A lifecycle hook provides a specified amount of time (one hour by default) to wait for the action to complete before the instance transitions to the next state.

### How it works?

An Amazon EC2 instance transitions through different states from the time it launches until it is terminated. You can create lifecycle hooks to act when an instance transitions into a wait state.

### Events of Lifecycle hooks

Instance launching

```bash
aws autoscaling put-lifecycle-hook \
    --auto-scaling-group-name ec2-workshop-asg \
    --lifecycle-hook-name ec2-workshop-launch-hook \
    --lifecycle-transition autoscaling:EC2_INSTANCE_LAUNCHING \
    --heartbeat-timeout 300
```

Instance terminating