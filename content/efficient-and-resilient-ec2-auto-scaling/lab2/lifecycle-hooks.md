+++
title = "Lifecycle hooks"
weight = 150
+++

Amazon EC2 Auto Scaling offers the ability to add lifecycle hooks to your Auto Scaling groups. These hooks let you create solutions that are aware of events in the Auto Scaling instance lifecycle, and then perform a custom action on instances when the corresponding lifecycle event occurs. A lifecycle hook provides a specified amount of time (one hour by default) to wait for the action to complete before the instance transitions to the next state.

## How it work?

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