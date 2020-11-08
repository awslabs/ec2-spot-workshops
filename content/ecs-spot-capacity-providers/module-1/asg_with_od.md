---
title: "Create On-Demand Auto Scaling group"
weight: 10
---

In this section, we will create an EC2 Auto Scaling group (ASG) for On-Demand Instances using the Launch Template created by the CloudFormation stack.

Copy the file **templates/asg.json** for the EC2 Auto Scaling group configuration.

```bash
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/
cp templates/asg.json .
```

Take a moment to look at the **asg.json** file to see various configuration options for the EC2 Auto Scaling group.

Set environment variables for ASG name and On-Demand percentage field in ASG.

```bash
export ASG_NAME=EcsSpotWorkshop-ASG-OD
export OD_PERCENTAGE=100 # Note that ASG will have 100% On-Demand, 0% Spot
```

Substitute the placeholder names in the template with actual values from the environment variables.

```bash
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g"  asg.json
```

Create the ASG for the On-Demand Instances.

```bash
aws autoscaling create-auto-scaling-group --cli-input-json  file://asg.json
ASG_ARN=$(aws autoscaling  describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME  ARN=$ASG_ARN"
```
The output of the above command looks like the below:
```plaintext
EcsSpotWorkshop-ASG-OD ARN=arn:aws:autoscaling:us-east-1:0004746XXXX:autoScalingGroup:1e9de503-068e-4d78-8272-82536fc92d14:autoScalingGroupName/EcsSpotWorkshop-ASG-OD 
```
The On-Demand auto scaling group looks like below in the [console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-OD?view=details)

Note that there is no capacity provisioned i.e. desired capacity is zero in the ASG. We expect the capacity to be scaled up automatically when we deploy applications later.

![On-demand ASG](/images/ecs-spot-capacity-providers/asg_od_initial_view_1.png)

Also note that there are no scaling policies attached to this Auto scaling group.

![On-demand ASG](/images/ecs-spot-capacity-providers/asg_od_initial_view_2.png)
