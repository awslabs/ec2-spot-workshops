---
title: "Create On_demand Auto Scaling group"
weight: 10
---

In this section, we will create an EC2 Auto Scaling group (ASG) for On-Demand Instances using the Launch Template created in previous section.

Copy the file  **templates/asg.json** for the Auto Scaling group configuration.

```bash
cp templates/asg.json .
```

Take a moment to look at the **asg.json** file to see various configuration options for the EC2 Auto Scaling group.

Run the following commands to set variables and substitute them in the template

```bash
export ASG_NAME=EcsSpotWorkshop-ASG-OD
export OD_PERCENTAGE=100 # Note that ASG will have 100% On-Demand, 0% Spot
```

Run the following command to substitute the template with actual values from the global variables

```bash
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g"  asg.json
```

Create the ASG for the On-Demand Instances
```bash
aws autoscaling create-auto-scaling-group --cli-input-json  file://asg.json
ASG_ARN=$(aws autoscaling  describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME  ARN=$ASG_ARN"
```
The output of the above command looks like the below:
```plaintext
EcsSpotWorkshop-ASG-OD ARN=arn:aws:autoscaling:us-east-1:000474600478:autoScalingGroup:1e9de503-068e-4d78-8272-82536fc92d14:autoScalingGroupName/EcsSpotWorkshop-ASG-OD 
```
The above auto scaling group looks like below in the console

![On-demand ASG](/images/ecs-spot-capacity-providers/21.png)