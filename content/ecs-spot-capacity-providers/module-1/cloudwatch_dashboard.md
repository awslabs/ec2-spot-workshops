---
title: "Create CloudWatch dashboard for ECS Cluster with key metrics"
weight: 40
---

Go back to your initial terminal and run the command below to create the CloudWatch dashboard to watch key metrics

```
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/
sed -i -e "s#%AWS_REGION%#$AWS_REGION#g" cwt-dashboard.json
aws cloudwatch put-dashboard --dashboard-name EcsSpotWorkshop --dashboard-body file://cwt-dashboard.json
```
The output of the command appears as below.

```plaintext
{
"DashboardValidationMessages": []
}
```

In the [AWS Cloudwatch console] (https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#) select the newly created dashboard, drag it right/down to expand to view the graphs properly and save the dashboard.

![Cloud Watch](/images/ecs-spot-capacity-providers/cwt4.png)


{{%expand "Question: What are initial values of CapacityProviderReservation metrics for CP-OD and CP-SPOT capacity providers when there are no tasks or instances running in the ECS cluster, and why? Click to expand the answer." %}}
![CPR Metric](/images/ecs-spot-capacity-providers/CP3.png)

Why are the values 100? Consider the Managed Scaling formula: 

**Capacity Provider Reservation = M/N * 100**. 

There are a few special cases where this formula not used. If M and N are both zero, meaning no instances, no running tasks, and no provisioning tasks, then CapacityProviderReservation = 100.  

For more details on how ECS cluster auto scaling works, refer to this [blog] (https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/).

{{% /expand%}}

Continue to the next section in the workshop to deploy tasks in the cluster, and to see ECS Managed Scaling in action.