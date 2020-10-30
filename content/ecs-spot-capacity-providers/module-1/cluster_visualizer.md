---
title: "Capacity Provider Instance Termination Protection in Action"
weight: 70
---


Refersh the C3Vis page by clicking on the “Roload Server Cache” button and click CPU metric. Your result should be similar to the below:

![Visualize](/images/ecs-spot-capacity-providers/c3vis_cluster_initial_view.png)

{{% notice note %}}
Please note that the exact distribution of tasks across instances within the Capacity Providers may be different from what is shown above, depending on when the instances were ready for task placement.  The important thing is that ECS will respect the capacity provider strategy and ensure that required the number of tasks to be placed on respective CP-OD and CP-SPOT as per their base and weight configuration.
{{% /notice %}}


To check more details on any of the ECS container instance, right click on the IP address and select **Open ECS Container Instance**

![Visualize](/images/ecs-spot-capacity-providers/c3vis_cluster_instance_view.png)


![Visualize](/images/ecs-spot-capacity-providers/c3vis_cluster_instance_view_details.png)


{{%expand "Question: Why were 6 tasks launched on CP-Spot and 4 tasks on CP-OD?" %}}


Quick reminder about our Capacity Provider Strategy: CP-OD-base=2,weight=1, CP-SPOT-weight=3
CP-OD has base=2 which means CP-OD should always have a baseline of 2 tasks running first. This can be transalted to the bare minimum required number of tasks needed to support your business critical application services. So ECS first assigns 2 tasks out of 10 to CP-OD as per the base parameter value.

Then the remaining 8 tasks will be distributed according to the weights. CP-OD weight is 1 and CP-SPOT weight is 3. That means that for every 1 task assigned to CP-OD, 3 will be assigned to CP-SPOT. This is translated to 2 to CP-OD and 6 to CP-SPOT.

Now let’s look the new values of Capacity Provider Reservation in the CloudWatch dashboard for these 2 CPs, and also look at the other metrics around number of instances and tasks.

![CPR](/images/ecs-spot-capacity-providers/cp24.png)

So Why do you think CPR changed from 200 to 100?  As you can guess, the value of M is 4 which is same as N value which is 4, hence Capacity Provider Reservation is 100, which means that all the desired capacity reuqired to run the ECS tasks is fulfilled. You can also notice the graph reflecting the change in number of tasks and instances.
{{% /expand%}}

As you might have noticed in the C3Visulization tool, one of the EC2 instance is completely empty and does not run any tasks. This should be the ideal candidate when the capacity provider scales down the capacity because selecting any other instance would cause terminating the tasks, causing the application disruption.

![CPR](/images/ecs-spot-capacity-providers/c3vis_cluster_initial_view_empty.png)



{{%expand "Question: But, what if your tasks distribution is different and there is NO empty EC2 instance in the ECS Cluster?" %}}

As mentioned in the Note above, this is possible that there are no empty EC2 instances without any tasks. And to test the Cluster Scale In activity, we need atleast one empty EC2 instance. Then   the capacity provider instance termination protection feature chooses only those instances without running any tasks. So to test this feature, let us manually scale down the ECS Service i.e. reducing number of tasks so that there will be an empty instance without any tasks.

Run the below command to scale down the service by reducing the number of tasks from 10 to 4.


```base
aws ecs update-service --cluster EcsSpotWorkshop \
--service ec2-service-split --desired-count 4
```

Now, guess what would be the distribution of 4 tasks across CP-OD and CP-SPOT?  

Run below command to see the task distribution across the ECS Cluster

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

The task distribution should look like this


![Visualizer](/images/ecs-spot-capacity-providers/tasks_after_scale_in.png)

Can you explain why CP-SPOT has only 1 task and CP-OD has 3 tasks?
Out of 4, CP-OD will have 2 in accordance with base and remaining 2 (4-2) will be split with 1 on CP-OD and 1 on CP-SPOT. 

Then how does the capacity provider metrics values changes as a result of this scale in event?   

Let’s look at the CPR values for both capacity providers

![Visualizer](/images/ecs-spot-capacity-providers/cp28.png)

Did you notice there is no change for CapacityProviderReservation metric value for CP-OD but changed from 100 to 50 for CP-SPOT. The value of 50 indicates the change in the value of M from 2 to 1.

 This will trigger a cloud watch alarm after 15 mins.

![Visualizer](/images/ecs-spot-capacity-providers/cp38.png)

The cloud watch alarm  cause the target tracking policy to trigger the scale in activity on the EcsSpotWorkshop-ASG-SPOT. Go to the AWS EC2 console page and select the EcsSpotWorkshop-ASG-SPOT and select the Activity History.

![Visualizer](/images/ecs-spot-capacity-providers/cp40.png)

***Congratulations !!!*** you have successfully completed this module and learnt how capacity providers instance termination protection feature avoids any disruption to your applications.  You can skip rest of the section and go to the next page.

{{% /expand%}}

Now, let us look at the Cloudwatch dashboard for the changes in the CapacityProviderReservation metric values,
 
 ![Visualizer](/images/ecs-spot-capacity-providers/cwt_dashboard_scale_in.png)


This will trigger the cloud watch alarms for the scale in activity

  ![Visualizer](/images/ecs-spot-capacity-providers/ecs_asg_od_scale_in_alarm.png)


You can now see that the Autoscaling group terminates the **empty EC2 instance** without causing any disruption to the application.


  ![Visualizer](/images/ecs-spot-capacity-providers/ecs_asg_od_scale_in_activity.png)


Let’s look at the C3VIS dashboard again

![Visualizer](/images/ecs-spot-capacity-providers/c3vis_after_scale_in.png)

As you see, the instance which does not run any tasks is terminated respecting the instance termination protection.

***Congratulations !!!*** you have successfully completed this module and learnt how capacity providers instance termination protection feature avoids any disruption to your applications.
