+++
title = "Launching EC2 Spot instances via EC2 Auto Scaling Group"
weight = 50
+++

## Launching EC2 Spot Instances via an EC2 Auto Scaling Group

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 instances available to handle the load for your application. You create collections of EC2 instances, called Auto Scaling groups. You can specify the minimum number of instances in each Auto Scaling group, and Amazon EC2 Auto Scaling ensures that your group never goes below this size. You can specify the maximum number of instances in each Auto Scaling group, and Amazon EC2 Auto Scaling ensures that your group never goes above this size.

With launch templates, you can also provision capacity across multiple instance types using both On-Demand Instances and Spot Instances to achieve the desired scale, performance, and cost.

 **To create an Auto Scaling group using a launch template**

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name AsgForWebServer --launch-template LaunchTemplateId="${LAUNCH_TEMPLATE_ID}",Version=1 --min-size 2 --max-size 4 --desired-capacity 2 --capacity-rebalance
```

This API call creates an Auto Scaling Group named *AsgForWebServer* with the following configuration:

1. **Launch template**: version 1 of the one created in the previous step.
2. **Capacity rebalance**: When you turn on Capacity Rebalancing, Amazon EC2 Auto Scaling attempts to launch a Spot Instance whenever Amazon EC2 notifies that a Spot Instance is at an elevated risk of interruption. After launching a new instance.

You have now created an Auto Scaling group configured to launch not only EC2 Spot Instances but EC2 On-Demand Instances with multiple instance types.
