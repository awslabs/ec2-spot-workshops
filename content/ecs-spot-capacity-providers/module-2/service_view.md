---
title: "Explore ECS Service"
chapter: true
weight: 60
---

Explore ECS Service
---

Click on this Service in the AWS ECS Console and it looks like below

![Capacity Provider](/images/ecs-spot-capacity-providers/CP4.png) 

What did you notice? 

Look at the pending task count of 10, which will cause the CPR value to change as ECS calculates new value for M (from initial zero) to accommodate these pending tasks. Let’s looks at the CWT dashboard for the new CPR values for both CPs.

![Capacity Provider Reservation](/images/ecs-spot-capacity-providers/cp5.png) 

So CPR is 200 which means twice the earlier value of 100. This indicates the new value of M is higher than N by a factor 2X which indicates the scaling (out) factor. After 1 min, let’s see if the ASG target tracking CWT Alarm is fired. Go to the CWT consile and click on the Alarms and you should see something like below.

![Cloud Watch Alarms](/images/ecs-spot-capacity-providers/cp6.png)

These alarms will cause the scale out action on both ASGs. Go to EC2 console, select any of the two ASGs and click on the Activity History. You will see two instances are launched.

![ASG Scale Out](/images/ecs-spot-capacity-providers/cp10.png)

So we see that CP Managed Scaling did its job of responding to the application service intent and scale out 2 instancs from zero capacity. Then what about task distributiuon on these CPs? Well, as you can recall, that is dictated by the CPS.
