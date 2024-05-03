+++
title = "Take control of instance Lifecycle"
weight = 60
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


You have successfully configured scaling policies in your Auto Scaling Group. You still need to solve **the challenge of instances long time of initiation, taking 5-10 minutes to start up**.

To elaborate the challenge further, the application provided to you has a long warm up time (10 minutes) and you have attempted to work with the application owners to speed up boot strapping and instance warm up time. Whilst there has been some improvement, it is not possible to speed this process up further without a complete re-architecture of the application.

In the following chapters, you explore how you can fix the challenge of slow boot strapping times with [**warm pools**](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html). With warm pools you can pre-initialize instances and stop them, ready for scale-out when needed. This approach significantly reduces the overall scale-out time.

Before you start working with warm pools, you explore **Lifecycle hooks**, another feature that helps in taking control of the instances lifecycle.

### Lifecycle hooks

Amazon EC2 Auto Scaling offers the ability to add lifecycle hooks to your Auto Scaling groups. These hooks let you create solutions that are aware of events in the Auto Scaling instance lifecycle, and then perform a custom action on instances when the corresponding lifecycle event occurs.

### How it works?

An Amazon EC2 instance transitions through different states from the time it launches until it is terminated. You can create lifecycle hooks to act when an instance transitions into a wait state.

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/lifecycle-hooks.png)

### Create a Lifecycle hook for instance launching

When a scale-out event occurs, your newly launched instance completes its startup sequence and transitions to a wait state. While the instance is in a wait state, it runs a script to download and install the needed software packages for your application, making sure that your instance is fully ready before it starts receiving traffic. When the script is finished installing software, it sends the **complete-lifecycle-action** command to continue. In our example application, this logic is scripted in the instance **userdata** which is configured in the **launch template**.

Run this command to create a lifecycle hook to control instance launching. Instances can remain in a wait state for a finite period of time, you set it in this command to **300** seconds using **heartbeat-timeout** parameter. When the heartbeat times out you can set the default action to **ABANDON** to terminate the instance and launch a new one, or set it to **CONTINUE** to launch the instance anyway.

```bash
aws autoscaling put-lifecycle-hook \
    --auto-scaling-group-name ec2-workshop-asg \
    --lifecycle-hook-name ec2-workshop-launch-hook \
    --lifecycle-transition autoscaling:EC2_INSTANCE_LAUNCHING \
    --heartbeat-timeout 300 \
    --default-result CONTINUE
```
