---
title: "ECS Managed Scaling(CAS) in action"
weight: 60
---

Click the service name in the [ECS Console](https://console.aws.amazon.com/ecs/home?#/clusters/EcsSpotWorkshop/services/ec2-service-split/details) 

![Capacity Provider](/images/ecs-spot-capacity-providers/CP4.png) 

The pending task count is 10, which changes the CapacityProviderReservation metric values as ECS calculates a new value for M to accommodate these pending tasks.
 
 Let us look at the [CloudWatch Dashboard](https://console.aws.amazon.com/cloudwatch/home?#dashboards:name=EcsSpotWorkshop) for the CapacityProviderReservation metric values for both capacity providers.


![Capacity Provider Reservation](/images/ecs-spot-capacity-providers/cp5.png) 

The CapacityProviderReservation metric value is 200 for both CP-OD and SP-SPOT. 

If M > 0 and N = 0, meaning no instances, no running tasks, but at least one provisioning task, then CapacityProviderReservation = 200. (Target tracking scaling has a special case for scaling from zero capacity, where it assumes for the purposes of scaling that the current capacity is one and not zero).

 This triggers the CloudWatch alarms associated with the target tracking policy in the Auto Scaling groups.  
 
 Go to the CloudWatch console and click on the [Alarms section](https://console.aws.amazon.com/cloudwatch/home?#alarmsV2:!alarmStateFilter=ALARM).

![Cloud Watch Alarms](/images/ecs-spot-capacity-providers/ecs_service_alarms.png)

Because of this, the scale-out activity triggered to provision instances in both Auto Scaling groups. 

Go to EC2 console, select [OnDemand ASG](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-OD?view=activity) and click the Activity tab. You will see two instances are just getting launched.

![ASG Scale Out](/images/ecs-spot-capacity-providers/ecs_asg_od_scale_out.png)


Go to EC2 console, select [EC2 Spot ASG](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-SPOT?view=activity) and click the Activity tab. You will see two instances are just getting launched.

![ASG Scale Out](/images/ecs-spot-capacity-providers/ecs_asg_spot_scale_out.png)

So, that means ECS Cluster auto scaling (CAS) responds to the application's intent and scales the required capacity in the Auto Scaling groups.

 Move to the next section in the workshop to examine how the tasks spread across the On-Demand and Spot capacity providers. 