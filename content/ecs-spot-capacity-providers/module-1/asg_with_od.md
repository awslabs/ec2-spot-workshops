---
title: "Create an Auto Scaling group with EC2 On-Demand Instances"
weight: 10
---

In this section, we will create an EC2 Auto Scaling group (ASG) for On-Demand Instances using the Launch Template created in previous section.

Copy the file  **templates/asg.json** for the Auto Scaling group configuration.

```bash
cp templates/asg.json ./asg_od.json
```

Take a moment to look at the **asg_od.json** file to see various configuration options for the EC2 Auto Scaling group.

Run the following commands to set variables and substitute them in the template

```bash
export ASG_NAME=ecs-spot-workshop-asg-od
export OD_PERCENTAGE=100 # Note that ASG will have 100% On-Demand, 0% Spot
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g"  asg_od.json
```

Create the ASG for the On-Demand Instances
```bash
aws autoscaling create-auto-scaling-group --cli-input-json file://asg_od.json
```
The output of the above command looks like the below:
```plaintext
EcsSpotWorkshop-ASG-OD ARN=arn:aws:autoscaling:us-east-1:000474600478:autoScalingGroup:1e9de503-068e-4d78-8272-82536fc92d14:autoScalingGroupName/EcsSpotWorkshop-ASG-OD
```
The above auto scaling group looks like below in the console

![On-demand ASG](/images/ecs-spot-capacity-providers/21.png)