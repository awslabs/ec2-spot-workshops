---
title: "Visualizing ECS Scaling Metrics"
weight: 70
---

## Visualizing ECS Metrics with CloudWatch Dashboards

Before we start testing our cluster scaling, let's check out how to visualize the scaling activities in the cluster.Go back to your initial terminal and run the command below to create the CloudWatch dashboard to watch key metrics

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

In the [AWS Cloudwatch console] (https://console.aws.amazon.com/cloudwatch/home) select the newly created dashboard, drag it right/down to expand to view the graphs properly and save the dashboard.

![Cloud Watch](/images/ecs-spot-capacity-providers/cwt4.png)

**Question: What are initial values of CapacityProviderReservation metrics for CP-OD and CP-SPOT capacity providers when there are no tasks or instances running in the ECS cluster, and why?**

{{%expand "Click to expand the answer." %}}
![CPR Metric](/images/ecs-spot-capacity-providers/CP3.png)

Why are the values 100? If you recall from the introduction, the metric **CapacityProviderReservation** is obtain by using the following formula.

```plaintext
Capacity Provider Reservation = M/N * 100 
```

In this case both `N` and `M` are 0 hence the division comes up with an undefined value. There are a few special cases where the formula is not used. If M and N are both zero, meaning no instances, no running tasks, and no provisioning tasks, then **`CapacityProviderReservation = 100`**.  For more details on how ECS cluster auto scaling works, refer to this [blog] (https://aws.amazon.com/blogs/containers/deep-dive-on-amazon-ecs-cluster-auto-scaling/).

{{% /expand%}}

## Visualizing ECS and Cluster metrics with C3VIS (Cloud Container Cluster Visualizer) Tool

[C3vis](https://github.com/ExpediaDotCom/c3vis) is an open source tool useful to show the visual representation of the tasks placements across instances in an ECS Cluster. We will use it as an example to display how tasks are placed in different capacity providers. Let's first setup the application. Go back to the in your Cloud9 Environment, and create a new terminal, we will use that terminal to run and expose C3VIS.

The following screenshot shows how to create a new terminal :
![c3vis](/images/ecs-spot-capacity-providers/cloud9_new_terminal.png)

The following lines, clone the c3vis tool repository, build the c3is application docker image and run the container.

```bash
cd ~/environment/
git clone https://github.com/ExpediaDotCom/c3vis.git
cd c3vis 
docker build -t c3vis .
docker run -e "AWS_REGION=$AWS_REGION" -p 8080:3000 c3vis

```

Open the preview application in your cloud9 environment and click on the arrow on the top right to open the application in the browser

![c3vis](/images/ecs-spot-capacity-providers/c3vs_tool.png)

The initial screen will appear as below, since there are no tasks or instances running in the cluster for now.

![c3vis](/images/ecs-spot-capacity-providers/c3vis2.png)

Since our ECS cluster is empty and does not have any instances, the c3vis application shows an empty page.