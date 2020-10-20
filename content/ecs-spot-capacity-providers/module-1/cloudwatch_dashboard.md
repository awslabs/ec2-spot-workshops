---
title: "Create a Cloudwatch Dashboard to view key metrics of the ECS Cluster"
weight: 40
---

Go back to your initial terminal and run the below command to create the cloudwatch dashboard to watch key metrics

```
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/
aws cloudwatch put-dashboard --dashboard-name EcsSpotWorkshop --dashboard-body file://cwt-dashboard.json
```
The output of the command looks like below

```plaintext
{
"DashboardValidationMessages": []
}
```

In the [AWS Cloudwatch console] (https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#) select this newly created dashboard, drag it right/down to expand to view the graphs properly and save the dashboard.

![Cloud Watch](/images/ecs-spot-capacity-providers/cwt4.png)


{{%expand "Question: What are the values for the cluster's ManagedScaling metrics when there are no tasks/instances running in the cluster, and why? Click to expand the answer." %}}
![CPR Metric](/images/ecs-spot-capacity-providers/CP3.png)

Why are the values 100? Consider the Managed Scaling formula: 

**Capacity Provider Reservation = M/N * 100**. 

There are a few special cases where this formula is not used. If M and N are both zero, meaning no instances, no running tasks, and no provisioning tasks, then CapacityProviderReservation = 100.  If M > 0 and N = 0, meaning no instances, no running tasks, but at least one provisioning task, then CapacityProviderReservation = 200. (Target tracking scaling has a special case for scaling from zero capacity, where it assumes for the purposes of scaling that the current capacity is one and not zero).

For more details on the how ECS cluster auto scaling works, refer to ths [blog] (https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/).

{{% /expand%}}

Continue to the next step in the workshop to start deploying tasks to the cluster, and seeing ECS Manager Scaling in action.