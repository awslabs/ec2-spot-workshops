---
title: "Interrupting a Spot Instance using FIS"
weight: 110
---

In this section, you're going to launch a Spot Interruption using FIS and then verify that the capacity has been replenished and ECS cluster was able to continue running the tasks. This will help you to confirm the low impact on your workloads when implementing Spot effectively. Moreover, you can discover hidden weaknesses, and make your workloads fault-tolerant and resilient.


#### Launch the Spot Interruption Experiment
After creating the experiment template in FIS, you can start a new experiment to interrupt three (unless you changed the template) Spot instances. Run the following command:

```
FIS_EXP_TEMP_ID=$(aws cloudformation describe-stacks --stack-name $FIS_EXP_NAME --query "Stacks[0].Outputs[?OutputKey=='FISExperimentID'].OutputValue" --output text)
FIS_EXP_ID=$(aws fis start-experiment --experiment-template-id $FIS_EXP_TEMP_ID --no-cli-pager --query "experiment.id" --output text)
```

Wait around 30 seconds, and you should see that the experiment completes. Run the following command to confirm:

```
aws fis get-experiment --id $FIS_EXP_ID --no-cli-pager
```

As soon as FIS experiment completed, FIS triggered a Spot interruption notice for Spot instances ( 3 in this case ).
![fisExperiment](/images/running-ecs-on-spot/FIS.png)

Go to CloudWatch Logs group `/aws/events/spotinterruptions` to see which instances are being interrupted. You will see Spot notifications ( Rebalance Recommendations and Interruption ) for the experiment.
![spotInterruptions](/images/running-ecs-on-spot/spotInterruption.png)

You should see a log message like this one:
![SpotInterruptionLog](/images/running-ecs-on-spot/spotInterruptionlogs.png)

And after two minutes the Spot instances will be evicted. Review CloutTrail `BidEvictedEvent` Events for confirmation.
![bidEviction](/images/running-ecs-on-spot/bidEviction.png)

ECS agent running on every cluster host, monitors the Spot interruption signals and place the instance in DRAINING status. When an instance is set to DRAINING, Amazon ECS prevents new tasks from being scheduled on the instance and starts deregistering targets on target group. You can monitor this from EC2 console [ EC2 -> "Target groups" -> "EcsSpotWorkshop" (TargetGroup Name) ] or "DeregisterTargets" events in Cloudtrail.
![tgDraining](/images/running-ecs-on-spot/tgDraining.png)

ECS will try  launch replacement tasks, which you can confirm with tasks in status as `Provisioning` or `Pending`.
![ecsProvisioning](/images/running-ecs-on-spot/ecsProvisioning.png)

Instance Draining caused `Pending Tasks` count to increase, which can be confirmed from EcsSpotWorkshop CloudWatch Dashboard. 
![cwPendingTasks](/images/running-ecs-on-spot/cwPendingTasks.png)

And these pending ECS tasks trigger ECS Managed Target-Tracking autoscaling policy, which launches new EC2 instances to run these pending tasks. 
![cwScalingPolicy](/images/running-ecs-on-spot/cwScalingPolicy.png) 

From EC2 -> Auto Scaling Group -> Activity History, we can see new instances being launched.
![instanceLaunch](/images/running-ecs-on-spot/instanceLaunch.png) 

Now you should see all new ECS tasks in `Running` state in ECS console.
![ECSTasksRunning](/images/running-ecs-on-spot/ECSTasksRunning.png) 

Once the required ECS tasks are relaunched on new or other existing instances, after around `15 mins`, you'd observe the ECS Managed CloudWatch alarm trigger Auto Scaling Policy scale-in events to brings number of spot instances back to initial state. In current example, for first scale-in event ( 02:59:39 AM ), autoscaling group desired capacity shrinks from 7 to 5 and in next scale-in event ( 03:00:50 AM), it drop back to orignal value 4.
![cwScaleInPolicy](/images/running-ecs-on-spot/cwScaleInPolicy.png) 
![instanceTermination](/images/running-ecs-on-spot/instanceTermination.png) 



