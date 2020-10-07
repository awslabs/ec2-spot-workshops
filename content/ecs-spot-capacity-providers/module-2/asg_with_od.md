---
title: "Create an Auto Scaling Group (ASG) with EC2 On-Demand Instances"
weight: 10
---

In this section, we will create an EC2 Auto Scaling Group for On-Demand Instances using the Launch Template created in previous section.

Copy the file  **templates/asg.json** for the Auto scaling group configuration.

```
cp templates/asg.json ./asg_od.json
```

Take a moment to look at the user asg_od.json to see various configuration options in the ASG.

Set the following commands to set variables and substitute them in the template

```
export ASG_NAME=ecs-spot-workshop-asg-od
export OD_PERCENTAGE=100 # Note that ASG will have 100% On-Demand, 0% Spot
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g"  asg_od.json
```

Create the ASG for the On Demand Instances

```
aws autoscaling  create-auto-scaling-group --cli-input-json file://asg_od.json
```
The output of the above command looks like below
```
EcsSpotWorkshop-ASG-OD ARN=arn:aws:autoscaling:us-east-1:000474600478:autoScalingGroup:1e9de503-068e-4d78-8272-82536fc92d14:autoScalingGroupName/EcsSpotWorkshop-ASG-OD
```
The above auto scaling group looks like below in the console

![On-demand ASG](/images/ecs-spot-capacity-providers/21.png)