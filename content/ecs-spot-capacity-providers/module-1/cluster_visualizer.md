---
title: "capacity provider Instance Termination Protection in Action"
weight: 70
---


Refresh the C3Vis page by clicking on the **Roload Server Cache** button and click CPU metric. Your result should be like below:

![Visualize](/images/ecs-spot-capacity-providers/c3vis_cluster_initial_view.png)

{{% notice note %}}
Please note that the tasks spread across instances within the capacity providers may differ from what it shows above.  The important thing to note is that ECS ensure that it spread the tasks across CP-OD and CP-SPOT capacity providers according to the capacity provider strategy.
{{% /notice %}}


To check more details on any of the ECS container instance, right click on the IP address and select **Open ECS Container Instance**

![Visualize](/images/ecs-spot-capacity-providers/c3vis_cluster_instance_view.png)


![Visualize](/images/ecs-spot-capacity-providers/c3vis_cluster_instance_view_details.png)


{{%expand "Question: Why there are 6 tasks launched on CP-SPOT and 4 tasks on CP-OD?" %}}


Quick reminder about our capacity provider strategy: CP-OD with base=2,weight=1 and CP-SPOT with weight=3.

CP-OD has base=2 which means 2 tasks of 10 total tasks, must launch first on CP-OD.  The remaining 8 tasks (10 - 2) spread according to the weights. CP-OD has weight is 1 and CP-SPOT has weight is 3. That means that for every 1 task assigned to CP-OD, ECS will assign 3 to CP-SPOT. That means 2 more tasks on CP-OD and 6 to CP-SPOT.

Now, let us look at the new values of CapacityProviderReservation metric for CP-OD and CP-SPOT capacity providers in the CloudWatch dashboard.

![CPR](/images/ecs-spot-capacity-providers/cp24.png)

So Why do you think CapacityProviderReservation changed from 200 to 100?  The value of M is 4 which is same as N, hence CapacityProviderReservation is 100. That means ECS provisioned the required capacity to run all the tasks.
{{% /expand%}}

Also, in the C3Vis page, one of the EC2 instance is completely unused and does not run any tasks. This should be the ideal candidate when the capacity provider scales down the ECS cluster because selecting any other instance would cause terminating the tasks, causing the application disruption.

![CPR](/images/ecs-spot-capacity-providers/c3vis_cluster_initial_view_empty.png)


{{%expand "Question: What if your task distribution is different and there is no unused EC2 instance in the ECS cluster?" %}}

As mentioned in the note above, tasks spread across instances within the capacity providers may be different and all the EC2 instances may run at least one task. But, to test the ECS cluster scale-in activity, we need at least one unused EC2 instance. For testing purpose, let us manually scale down the ECS service by reducing the number of tasks so that there will be an unused instance with no tasks. Then the capacity provider instance termination protection feature should ideally choose only those unused instances running no tasks. 

Run the command below to scale down the service by reducing the number of tasks from 10 to 4.


```base
aws ecs update-service --cluster EcsSpotWorkshop \
--service ec2-service-split --desired-count 4
```

Now, guess the distribution of 4 tasks across CP-OD and CP-SPOT capacity providers would be?  

Run the command below to see the task spread across the capacity providers.

```bash
export cluster_name=EcsSpotWorkshop 
export service_name=ec2-service-split
aws ecs describe-tasks \
--tasks $(aws ecs list-tasks --cluster $cluster_name \
--service-name $service_name --query taskArns[*] --output text) \
--cluster $cluster_name \
--query 'sort_by(tasks,&capacityProviderName)[*].{TaskArn:taskArn,CapacityProvider:capacityProviderName,Instance:containerInstanceArn,AZ:availabilityZone,Status:lastStatus}' \
--output table
```

The task spread should look like this.


![Visualizer](/images/ecs-spot-capacity-providers/tasks_after_scale_in.png)

How would you explain that CP-SPOT has only 1 task and CP-OD has 3 tasks?

Out of 4 tasks in the ECS service, CP-OD will have 2 due to base=2 and remaining 2 (4-2) splits with 1 on CP-OD and 1 on CP-SPOT. 

What would the new values of CapacityProviderReservation for CP-SPOT and CP-OD be after of the scale-in event?   

Let us look at the CloudWatch dashboard again.

![Visualizer](/images/ecs-spot-capacity-providers/cp28.png)

Did you notice there is no change for CapacityProviderReservation metric value for CP-OD but changed from 100 to 50 for CP-SPOT? The value of 50 indicates the change in the value of M from 2 to 1 in the EC2 SPOT ASG.

 This triggers a CloudWatch alarm after 15 mins.

![Visualizer](/images/ecs-spot-capacity-providers/cp38.png)

The CloudWatch alarm triggers the scale-in activity on the **EcsSpotWorkshop-ASG-SPOT**. Go to the AWS EC2 console page and select the EcsSpotWorkshop-ASG-SPOT and select the Activity History.

![Visualizer](/images/ecs-spot-capacity-providers/cp40.png)

In the C3vis page, observe that the unused EC2 instance, which is not running any tasks, selected for termination, causing no disruption to the application.

{{% /expand%}}

Now, let us look at the CloudWatch dashboard for the changes in the CapacityProviderReservation metric values.
 
 ![Visualizer](/images/ecs-spot-capacity-providers/cwt_dashboard_scale_in.png)

Note that the CapacityProviderReservation value for CP-OD changed from 100 to 50 because of the unused EC2 instance in the ECS cluster.

This triggers the CloudWatch alarm for the scale-in activity on the **EcsSpotWorkshop-ASG-OD**

  ![Visualizer](/images/ecs-spot-capacity-providers/ecs_asg_od_scale_in_alarm.png)

Go to the AWS EC2 console page and select the **EcsSpotWorkshop-ASG-OD** and select the Activity History. You can see that the CP-OD capacity provider terminates the **unused EC2 instance** causing no disruption to the application.


  ![Visualizer](/images/ecs-spot-capacity-providers/ecs_asg_od_scale_in_activity.png)


Let us look at the C3Vis dashboard again.

![Visualizer](/images/ecs-spot-capacity-providers/c3vis_after_scale_in.png)

In the C3vis page, observe that the unused EC2 instance, which is not running any tasks, selected for termination, causing no disruption to the application.

Now that you verified the ECS cluster scale-in activity, click on the arrow button to move to the next page.


