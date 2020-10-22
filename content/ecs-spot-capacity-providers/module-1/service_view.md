---
title: "Managed Scaling in action"
weight: 60
---

Click the service name in the [ECS Console](https://console.aws.amazon.com/ecs/home?#/clusters) 

![Capacity Provider](/images/ecs-spot-capacity-providers/CP4.png) 

The pending task count is 10, which will cause the Capacity Provider Reservation value to change as ECS calculates a new value for M (from zero initially) to accommodate these pending tasks. Lets look at the CloudWatch Dashboard for the new Capacity Provider Reservations values for both Capacity Providers.

![Capacity Provider Reservation](/images/ecs-spot-capacity-providers/cp5.png) 

The Capacity Provider Reseration metric value is 200. This indicates the new value of M is higher than N by a factor 2X, which indicates the scaling (out) factor. After 1 min, let’s see if the ASG target tracking CloudWatch Alarm is triggered. Go to the CloudWatch console and click on the Alarms section.

![Cloud Watch Alarms](/images/ecs-spot-capacity-providers/cp6.png)

These alarms will cause the scale out action on both ASGs. Go to EC2 console, select any of the two ASGs and click on the Activity tab. You will see two instances are launched.

![ASG Scale Out](/images/ecs-spot-capacity-providers/cp10.png)

So we see that Capacity Providers Managed Scaling did its job of responding to the application service intent, and scaled out by launching 2 instancs. Move to the next step in the workshop to examine how the tasks were distributed across the On-Demand and Spot capacity providers. 