---
title: "Create ECS Service"
chapter: true
weight: 18
---

Create ECS Service
---

In this section, we will create an ECS Service which distributes tasks on CP-OD and CP-SPOT with a custom strategy with CP-OD base=2 weight=1 and CP-SPOT weight=3.  This Capacity Provider Strategy results from the following application requirements

* There should be always at least 2 tasks running all the time for the regular traffic.  The base=2 configuration satisfies this requirement.
* Any spiky or elastic traffic should be handled by tasks deployed on on-demand and spot instances in the ratio 1:3


To create the service, follow these steps:

* Click on the tab *Services*
* Click on the *Create*
* For Capacity provider strategy, leave it to default value *Cluster default Strategy*
* For Task Definition Family, select *ec2-task*
* For Task Definition Revision, select *1*
* For Cluster, leave default value *EcsSpotWorkshop*
* For Service name, *ec2-service-split*
* For Service type, leave it default *REPLICA*
* For Number of tasks, enter *10*
* Leave default values for *Minimum healthy percent* and *Maximum percent*
* Under Deployments section, leave it to default values
* Under Task Placement section, for Placement Templates, select *BinPack*
* Under Configure network section, in  Load balancing, for Service IAM role, leave default value
* For Load balancer name, select *EcsSpotWorkshop*
* Under Container to load balance, for Container name : port, click on *add to load balancer*
* For Production listener port,  Select *HTTP:80* from the dropdown list
* For Production listener protocol, leave default value of *HTTP*
* For Target group name, select *EcsSpotWorkshop* from the list
* Leave default values for *Target group protocol*, *Target type*, *Path pattern*, *Health check path*
* Click on *Next Step*
* Under Set Auto Scaling (optional), leave default value for Service Auto Scaling
* Click on *Next Step*
* Click on *Create Service*
* Click on *View Service*

![Service](/images/ecs-spot-capacity-providers/Ser1.png)
![Service Binpack](/images/ecs-spot-capacity-providers/ser2.png)
![Service ALB](/images/ecs-spot-capacity-providers/ser5.png)
![Service ALB Target Group](/images/ecs-spot-capacity-providers/ser6.png)

Click on this Service in the AWS ECS Console and it looks like below

![Capacity Provider](/images/ecs-spot-capacity-providers/CP4.png) 

What did you notice? 

Look at the pending task count of 10, which will cause the CPR value to change as ECS calculates new value for M (from initial zero) to accommodate these pending tasks. Let’s looks at the CWT dashboard for the new CPR values for both CPs.

![Capacity Provider Reservation](/images/ecs-spot-capacity-providers/cp5.png) 

So CPR is 200 which means twice the earlier value of 100. This indicates the new value of M is higher than N by a factor 2X which indicates the scaling (out) factor. After 1 min, let’s see if the ASG target tracking CWT Alarm is fired. Go to the CWT consile and click on the Alarms and you should see something like below.

![Cloud Watch Alarms](/images/ecs-spot-capacity-providers/cp6.png)

These alarms will cause the scale out action on both ASGs. Go to EC2 console, select any of the two ASGs and click on the Activity History.  You will see two instances are launched.

![ASG Scale Out](/images/ecs-spot-capacity-providers/cp10.png)

So we see that CP Managed Scaling did its job of responding to the application service intent and scale out 2 instancs from zero capacity. Then what about task distributiuon on these CPs? Well, as you can recall, that is dictated by the CPS.

Let’s first check if our application is up and running fine.  Go to the Target Group in the AWS console. check click on the targets. Ensure that all the targets are healthy.



Get the DNS name of the Applicaton Load Balancer from the output section of the Cloud formation stack.

![Get DNS](/images/ecs-spot-capacity-providers/CFN.png)

Open a brower tab and enter this DNS Name. You should see a simple web page displaying various useful info about the underlyong infrastucture used to run this application inside a docker container.

![Application](/images/ecs-spot-capacity-providers/app.png)

As you keep refresh the web page, you will notice that some of the above data changing as ALB keeps routing the requests to different docker containers across the CPs in the ECS Cluster.

Now let’s check if the tasks are distributed on on-demand and spot Capacity Providers as per the strategy.

Run the below command to see how tasks are distributed across the Capacity Providers.

```
export cluster_name=EcsSpotWorkshop 
export service_name=ec2-service-split
aws ecs describe-tasks \
--tasks $(aws ecs list-tasks --cluster $cluster_name \
--service-name $service_name --query taskArns[*] --output text) \
--cluster $cluster_name \
--query 'sort_by(tasks,&capacityProviderName)[*].{TaskArn:taskArn,CapacityProvider:capacityProviderName,Instance:containerInstanceArn,AZ:availabilityZone,Status:lastStatus}' \
--output table
```

The output of the above command should display a table like this below.

![Results Table](/images/ecs-spot-capacity-providers/table.png)

What did you notice? Do you have an explanation for the above distribution of 4 tasks on CP-OD and 6 on CP-SPOT? Take a guess before reading further.

Alternative let’s look at the C3VIS dashboard to see the visual representation of the ECS cluster and the distribution of tasks on different CPs.  Before you see the visual representation, try calculating yourself what the task distribution would be as per the CPS? Notice the CPS used for this service is CP-OD,base=2,weight=1, CP-SPOT,weight=3


Refersh the C3Vis page by clicking on the “Roload Server Cache” and click CPU metric. You will see something like below.

![Visualize](/images/ecs-spot-capacity-providers/cp13.png)

Please note that the exact distribution of tasks across instances within a CP-OD or CP-SPOT may be different in than what is shown above, depending upon when the instances are ready for task placement. 
But ECS will respect the CP strategy w.r.t  the number of tasks to be placed on CP-OD and CP-SPOT.

What did you notice in the above placement? Well, there are 4 instances running 14 tasks including 10 application tasks (pink color) and 4 cwt container insights daemons (blue color)

But how are these 10 tasks distributed across CPs?  We see only IP address of the instances in this tool. To check which CP (OD or SPOT) does this instance belongs to,  right click on the IP address and select the option “Open ECS container instance console”
![Visualize](/images/ecs-spot-capacity-providers/cp16.png)
![Visualize](/images/ecs-spot-capacity-providers/cp17.png)

So the instance with IP 10.0.171.50 belongs to CP-OD and runs 3 tasks. Now let’s check all other instance details

![Visualize](/images/ecs-spot-capacity-providers/cp18.png)
![Visualize](/images/ecs-spot-capacity-providers/cp20.png)
![Visualize](/images/ecs-spot-capacity-providers/cp21.png)

Now let’s label these instances and summarize our finding in this table for easy understanding  

![Summary](/images/ecs-spot-capacity-providers/summary.png)


------

Can you explain why CP-SPOT has 6 and CP-OD has only 4? 

Let’s understand the CPS first. CP-OD,base=2,weight=1, CP-SPOT,weight=3
CP-OD has base=2 which means at CP-OD should always have min of 2 tasks running first. This can be transalted to the bare minimum required number of tasks needed on on-demand to support your business critical application services.  So ECS first assigns 2 tasks out of 10 to CP-OD as per the base parameter value.

Then the remaining 8 (10-2) will distributed according to the weights. CP-OD weight is 1 and CP-SPOT weight is 3.  That means for every 1 task assigned to CP-OD, 3 will be assigned to CP-SPOT. This translated to 2 to CP-OD and 6 to CP-SPOT.


Now let’s look the new values of CPR in the CWT dashboard for these 2 CPs and also look at the other metrics w.r.t number of instances and tasks.

![CPR](/images/ecs-spot-capacity-providers/cp24.png)

So Why do you think CPR is changed from 200 to 100?  As you can guess, the value of M is 4 which is same as N value which is 4, hence CPR is 100 which means cluster is stable.  You can also notice the graph reflect the change in number of tasks and instances.


Now let’s do some the scale in actions on this Cluster by reducing the number of tasks from 10 to 6.

Optional Exercise:
try scale down the service by reducing task count from 10 to 6

```
aws ecs update-service --cluster EcsSpotWorkshop \
--service ec2-service-split --desired-count 6
```

What do you think should happen now w.r.t CPR and task distribution? Let’s look at C3VIS tool again

![Visualizer](/images/ecs-spot-capacity-providers/cp25.png)

And the table looks below after the service scale in activity. 


![Table](/images/ecs-spot-capacity-providers/table2.png)
				

Can you explain why both CP-SPOT and CP-OD has 3 tasks each?
Out of 6, CP-OD will have 2 as per base and remaining 4 (6-2) will be split with 1 on CP-OD and 3 on CP-SPOT. 

Did you notice service scale in does not translate to ASG scale in in this case i.e. no reduction in the number on instances in ASGs. This is because there are no idle instances without any tasks. Since there is no change in desired number of instances (i,e, M), so there is no change in CPR value.

Earlier the task distribution was SPOT1 → 3, SPOT2 → 3, OD1 → 2, OD2 → 2. 
The new distribution is           SPOT1 → 1, SPOT2 → 2, OD1 → 1, OD2 → 2. 

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

Then what about the ASG scale in this time? Notice there is one instance (i.e. SPOT1) without any tasks running. Note that CP doesn’t consider the non application tasks such cloud watch container insights domain tasks towards scale in/out activities.

Let’s look at the CPR values for both CPs.

![Visualizer](/images/ecs-spot-capacity-providers/cp28.png)

Did you notice there is no change for CPR value for CP-OD and CPR changed from 100 to 50 for CP-SPOT. CPR value of 50 indicates the change in the value of M from 2 to 1.  This will trigger the CWT alarm after 15 mins as exaplined earlier,

![Visualizer](/images/ecs-spot-capacity-providers/cp38.png)

The CWT alarm will trigger the correspnding scale in activity on the EcsSpotWorkshop-ASG-SPOT. Go to the AWS EC2 console page and select the EcsSpotWorkshop-ASG-SPOT and select the Activity History.

![Visualizer](/images/ecs-spot-capacity-providers/cp40.png)


Now, the most important question is which one of 2 instances(SPOT1 or SPOT2) in the EcsSpotWorkshop-ASG-SPOT will be terminated?? If you recall, we enabled CP Managed Termination Protection. This will ensure that only instance which does not run any tasks will be selected for termination.

Let’s look at the C3VIS dashboard again

![Visualizer](/images/ecs-spot-capacity-providers/cp43.png)

As you see, the instance which does not run any tasks (SPOT1) is terminated respecting the instance termination protection.

And the table looks below after the service scale in activity. 
![Table](/images/ecs-spot-capacity-providers/table3.png)

Can you explain why both CP-SPOT has 1 task and CP-OD has 3 tasks?
Out of 4, CP-OD will have 2 as per base and remaining 2 (4-2) will be split with 1 on CP-OD and 1 on CP-SPOT. 

The task distribution after the scale in activity looks like below.

Earlier the task distribution was SPOT1 → 1, SPOT2 → 2, OD1 → 1, OD2 → 2. 
The new distribution is           SPOT2 → 1, OD1 → 1, OD2 → 2. 

***Congratulations !!!*** you have successfully completed Module-2 and learnt how to create ASG CPs and schedule ECS services across Spot and On-demand CPs.
