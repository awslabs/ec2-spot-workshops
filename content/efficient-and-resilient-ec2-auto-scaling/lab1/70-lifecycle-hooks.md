+++
title = "Take control of instance Lifecycle"
weight = 170
+++

You have successfully configured scaling policies in your Auto Scaling Group. However, you still need to solve **the challenge of instances long time of initiation, taking 5-10 minutes to start up**. 

To elaborate the challenge further, the application provided to you has long warm up time (10 minutes) and you have attempted to work with the application owners to speed up boot strapping and instance warm up time. Whilst there has been some improvement, it is not possible to speed this process up further without a complete re-architecture of the application.

In the following chapters, you explore how you can fix the challenge of slow boot strapping times with [**warm pools**](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html). With warm pools you can pre-initialize instances and stop them, ready for scale-out when needed. This approach significantly reduces the overall scale-out time.

Before you start working with warm pools, you explore **Lifecycle hooks**, another feature that helps in taking control of the instances lifecycle.

### Lifecycle hooks

Amazon EC2 Auto Scaling offers the ability to add lifecycle hooks to your Auto Scaling groups. These hooks let you create solutions that are aware of events in the Auto Scaling instance lifecycle, and then perform a custom action on instances when the corresponding lifecycle event occurs.

### How it works?

An Amazon EC2 instance transitions through different states from the time it launches until it is terminated. You can create lifecycle hooks to act when an instance transitions into a wait state.

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/lifecycle-hooks.png)

### Create a Lifecycle hook for instance launching

Run this command to create a lifecycle hook to control instance launching.

```bash
aws autoscaling put-lifecycle-hook \
    --auto-scaling-group-name ec2-workshop-asg \
    --lifecycle-hook-name ec2-workshop-launch-hook \
    --lifecycle-transition autoscaling:EC2_INSTANCE_LAUNCHING \
    --heartbeat-timeout 300 \
    --default-result CONTINUE
```
