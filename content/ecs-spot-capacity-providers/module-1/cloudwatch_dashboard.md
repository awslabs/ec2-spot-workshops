---
title: "Create a Cloudwatch Dashboard to view key metrics of the ECS Cluster"
weight: 40
---


Run the below command to create the cloudwatch dashboard to watch key metrics

```
cd ..
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

Why are the values 100?
Consider the Managed Scaling formula: **Capacity Provider Reservation = M/N * 100**. 

As explained in the introduction section of the workshop, M is just a relative propotion value to N. As it is a brand new cluster, there are no instances running in the cluster, meaning N = 0. M is also caluclated as zero because there is no need for capacity to facilitate tasks (since none are running). In other words, the capacity that the cluster requested (M=0) is identical to the available capacity (N=0) which means that the Capacity Providers satisfy the target capacity value of 100. 

For more details on the how ECS cluster auto scaling works, refer to ths [blog] (https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/).

{{% /expand%}}

Continue to the next step in the workshop to start deploying tasks to the cluster, and seeing ECS Manager Scaling in action.