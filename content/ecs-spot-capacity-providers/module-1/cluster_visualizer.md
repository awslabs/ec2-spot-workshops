---
title: "Capacity Provider Instance Termination Protection in Action"
weight: 70
---


Refersh the C3Vis page by clicking on the “Roload Server Cache” button and click CPU metric. Your result should be similar to the below:

![Visualize](/images/ecs-spot-capacity-providers/cp13.png)

Please note that the exact distribution of tasks across instances within the Capacity Providers may be different from what is shown above, depending on when the instances were ready for task placement. 

It is possible that you may see different distribution of tasks per instance in your cluster. But the important thing is that ECS will respect the capacity provider strategy and ensure that required the number of tasks to be placed on respective CP-OD and CP-SPOT as per their base and weight configuration.

To check more details on any of the ECS container instance, right click on the IP address and select **Open ECS Container Instance**

![Visualize](/images/ecs-spot-capacity-providers/cp16.png)
![Visualize](/images/ecs-spot-capacity-providers/cp17.png)


{{%expand "Question: Why were 6 tasks launched on CP-Spot and 4 tasks on CP-OD?" %}}


Quick reminder about our Capacity Provider Strategy: CP-OD-base=2,weight=1, CP-SPOT-weight=3
CP-OD has base=2 which means CP-OD should always have a baseline of 2 tasks running first. This can be transalted to the bare minimum required number of tasks needed to support your business critical application services. So ECS first assigns 2 tasks out of 10 to CP-OD as per the base parameter value.

Then the remaining 8 tasks will be distributed according to the weights. CP-OD weight is 1 and CP-SPOT weight is 3. That means that for every 1 task assigned to CP-OD, 3 will be assigned to CP-SPOT. This is translated to 2 to CP-OD and 6 to CP-SPOT.

Now let’s look the new values of Capacity Provider Reservation in the CloudWatch dashboard for these 2 CPs, and also look at the other metrics around number of instances and tasks.

![CPR](/images/ecs-spot-capacity-providers/cp24.png)

So Why do you think CPR changed from 200 to 100?  As you can guess, the value of M is 4 which is same as N value which is 4, hence Capacity Provider Reservation is 100, which means that all the desired capacity reuqired to run the ECS tasks is fulfilled. You can also notice the graph reflecting the change in number of tasks and instances.
{{% /expand%}}

Now let’s test the scale in behavior on this cluster by reducing the number of tasks from 10 to 6.

```base
aws ecs update-service --cluster EcsSpotWorkshop \
--service ec2-service-split --desired-count 6
```

What would be the result of decreasing the desired count for the tasks in the service? Check V3Vis to see the result.

![Visualizer](/images/ecs-spot-capacity-providers/cp25.png)

Out of 6 tasks remaining, CP-OD will have 2 as per the base configuration, and the remaining 4 tasks will be split with 1 on CP-OD and 3 on CP-SPOT. 

Did you notice service scale in does not translate to ASG scale in this case? There is no change in the number of instances in ASGs. This is because there are no idle instances without any tasks. Since there is no change in the desired number of instances (M), so there is no change in Capacity Provider Reservation value.


Optional Exercise:
Try again scale down the service by changing task count from 6 to 4

Now let’s trigger one more service scale in activity to reduce tasks count from 6 to 4

```
aws ecs update-service --cluster EcsSpotWorkshop \
--service ec2-service-split --desired-count 4
```

What do you think should happen now w.r.t CPR and task distribution? Let’s look at C3VIS tool again

![Visualizer](/images/ecs-spot-capacity-providers/cp27.png)

Can you explain why both CP-SPOT has only 1 task and CP-OD has 3 tasks?
Out of 4, CP-OD will have 2 as per base and remaining 2 (4-2) will be split with 1 on CP-OD and 1 on CP-SPOT. 

Then what about the Autoscaling Group scale in this time? Notice there is one instance (i.e. SPOT1) without any tasks running.  

Let’s look at the CPR values for both capacity providers

![Visualizer](/images/ecs-spot-capacity-providers/cp28.png)

Did you notice there is no change for CapacityProviderReservation metric value for CP-OD butchanged from 100 to 50 for CP-SPOT. The value of 50 indicates the change in the value of M from 2 to 1.  This will trigger a cloud watch alarm after 15 mins.

![Visualizer](/images/ecs-spot-capacity-providers/cp38.png)

The cloud watch alarm  cause the target tracking policy to trigger the scale in activity on the EcsSpotWorkshop-ASG-SPOT. Go to the AWS EC2 console page and select the EcsSpotWorkshop-ASG-SPOT and select the Activity History.

![Visualizer](/images/ecs-spot-capacity-providers/cp40.png)


Now, the important question is which one of 2 instances(SPOT1 or SPOT2) in the EcsSpotWorkshop-ASG-SPOT will be terminated?? If you recall, we enabled Capacity Provider Managed Termination Protection. This will ensure that only instance which does not run any tasks will be selected for termination to avoid any disruption to the applications.

Let’s look at the C3VIS dashboard again

![Visualizer](/images/ecs-spot-capacity-providers/cp43.png)

As you see, the instance which does not run any tasks (SPOT1) is terminated respecting the instance termination protection.

Can you explain why both CP-SPOT has 1 task and CP-OD has 3 tasks?
Out of 4, CP-OD will have 2 as per base and remaining 2 (4-2) will be split with 1 on CP-OD and 1 on CP-SPOT. 

***Congratulations !!!*** you have successfully completed Module-1 and learnt how to create Autoscaling group capacity providers and schedule ECS services across Spot and On-demand instances for a given ratio.
