+++
title = "Managed Scaling"
chapter = true
weight = 60
+++

***Managed Scaling***
--------------------------------

*Managed scaling*, when enabled, Amazon ECS manages the scale-in and scale-out actions of the ASG. if managed scaling is disabled, you manage your ASG yourself. When a CP is created, it also creates a target tracking scaling policy for the associated ASG based on CPR metric.  A new metric called CapacityProviderReservation(CPR) for this purpose. When a CP is assigned to a Cluster, ECS will start emitting CPR metric to Amazon Cloudwatch for that CP on behalf of the customer. 

The CPR metric is defined as follows.

CPR  = (M/N ) x 100

N = Number of instances (where existing tasks are placed) already running  in an ASG
M = Number of instances needed for existing and new tasks to placed in an ASG

In other words, CPR metric is a relative proportion of TC value and dictates how much scale out/in should happen. Whenever the application scales out/in tasks (ex: via ECS Service autoscaling), ECS caclulates M i.e. number of instances required to run the desired number of tasks. It triggers the target tracking scaling policy associated with ASG to do the scale out/in activities.

ECS always tries to ensure CPR is equal to specified TC value either by increasing or decreasing number of instances in ASG based on value of M. 

The Scale-out in ASG occurs if CPR > TC for 1 datapoints with 1 minute duration. That means it takes 1 min to trigger the scale out Alarm to trigger.
The Scale-in in ASG occurs in CPR < TC for 15 datapoints with 1 minute duration. That it takes 15 minutes for scale in Alarm to trigger.

For example, let’s say TC=100 and ASG has two instances running i.e. N=2.  If there is ECS Service scale out occurs which needs to double the no of tasks and  ECS calculates M to be 4 i,e 2 x N.

So CPR = M/N * 100 = 4 / 2 * 100 = 200 which is twice the TC value of 100.  After 1 min of CPR (200) > TC (100), CWT Alarm is trigerred forscale out occurs and CP increases the number of instances by two (M - N). So the new value of N is 4 after the instances are launched. So CPR = 4/4 * 100 = 100 which is same as TC.

let’s say now ECS Service scale in occurs which reduces the desired no of tasks by half i.e. 2 and ECS calulcates M to be 2 i.e. N/2.  Please note tasks are terminated immediately as per the ECS service scale in.

Now CPR = 2 / 4 * 100 = 50.  After 15 min of CPR (50) < TC (100), CWT alarm is triggerd for scale in and CP reduces the number of instances (i.e. N=4) to make it equal to M (i.e. 2). If Managed Termination Protection is enabled, CP prevents instances from termination if there are containers running on it. 

All of this section is well explained in this workshop.
