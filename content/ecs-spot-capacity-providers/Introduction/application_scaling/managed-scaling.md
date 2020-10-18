+++
title = "ECS Cluster Autoscaling (CAS)"
weight = 60
+++

ECS Cluster Auto Scaling (CAS) is a new capability for ECS to manage the scaling of EC2 Auto Scaling Groups (ASG). With CAS, you can configure ECS to scale your ASG automatically, and just focus on running your tasks. ECS will ensure the ASG scales in and out as needed with no further intervention required. CAS relies on ECS capacity providers.  

ECS creates a scaling plan for the ASG and attaches a target tracking scaling policy to the scaling plan. The scaling policy uses a new CloudWatch metric called  CapacityProviderReservation that ECS publishes for every ASG capacity provider that has managed scaling enabled.

The new metric CloudWatch metric CapacityProviderReservation is defined as follows.

CapacityProviderReservation  = (M/N ) x 100

N = The current number of instances in the Autoscaling group(ASG) that are already running 
M = The number of instances are running in an ASG to meet the needs of the tasks assigned to that ASG, including tasks already running as well as tasks the customer is trying to run that don’t fit on the existing instances. 

Given this assumption, if N = M, scaling out is not required, and scaling in isn’t possible. On the other hand, if N < M, scale out is required because you don’t have enough instances.  Lastly, if N > M, scale in is possible (but not necessarily required) because you have more instances than you need to run all of your ECS tasks.

The CapacityProviderReservation metric is a relative proportion of Target capacity value and dictates how much scale-out / scale-in should happen.  CAS always tries to ensure CapacityProviderReservation is equal to specified Target capacity value either by increasing or decreasing number of instances in ASG.

In other words, the scale-out activity triggered if CapacityProviderReservation > Target capacity for 1 datapoints with 1 minute duration. That means it takes 1 min to scale out the capacity in teh ASG. And the scalee-in activity triggered if CapacityProviderReservation < Target capacity for 15 datapoints with 1 minute duration.  

All of this is well explained in this workshop.
