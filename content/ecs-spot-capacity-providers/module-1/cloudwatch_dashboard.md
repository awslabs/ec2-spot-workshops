---
title: "Create Cloudwatch Dashboard to view key metrics of the ECS Cluster"
weight: 40
---


Run the below command to create the cloudwatch dashboard to watch key metrics

```
cd ..
aws cloudwatch put-dashboard --dashboard-name EcsSpotWorkshop --dashboard-body file://cwt-dashboard.json
```
The output of the command looks like below

{
"DashboardValidationMessages": []
}

In the [AWS Cloudwatch console] (https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#) select this newly created dashboard, drag it right/down to expand to view the graphs properly and save the dashboard.

![Cloud Watch](/images/ecs-spot-capacity-providers/cwt4.png)

Now observer the initial values for the CPR metric for both ASG CPs i.e. CP-OD and CP-SPOT. What values do you expect for both them initially when they are no tasks/instances running in the Cluster. Make a guess before you see next graph.

![CPR Metric](/images/ecs-spot-capacity-providers/CP3.png)

Why do you think both values are 100 intially? 

Well, let’s re-look at the formula once again. CPR = M/N * 100. As explained earlier, M is just a relative propotion value to N.  As it is a brand new cluster, there are no instances i.e. N = 0. M is also caluclated as zero.  In other words, what the cluster needed (M=0) is same what is available capacity (N=0) which means CP satisfy the TC value of 100. 

For more details on the how the ECS cluster autoscaler works, refer to ths [blog] (https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/).

Now let’s us deploy some tasks on this cluster and see the CP Managed Scaling in Action !!!
