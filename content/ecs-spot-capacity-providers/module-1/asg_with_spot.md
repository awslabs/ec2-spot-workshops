---
title: "Create EC2 Spot Auto Scaling group"
weight: 15
---

In this section, you create an Auto Scaling group for EC2 Spot Instances using the Launch Template created by the CloudFormation stack. This procedure is exactly same as the previous section except for a few changes specific to the configuration for Spot Instances.


We configured the instance diversification in **asg.json**. We chose instance types with similar hardware characteristics in order to have a consistent auto scaling experience.

Copy the file **templates/asg.json** for the EC2 Auto Scaling group configuration.

```bash
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/
cp templates/asg.json .
```

Take a moment to look at the user **asg.json** to see various configuration options in the ASG.

Set environment variables for ASG name and On-Demand percentage field in ASG.

```bash
export ASG_NAME=EcsSpotWorkshop-ASG-SPOT
export OD_PERCENTAGE=0 # Note that ASG will have 0% On-Demand, 100% Spot
```

Substitute the placeholder names in the template with actual values from the environment variables.

```bash
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g" asg.json
```

Create the ASG for the Spot Instances.

```bash
aws autoscaling create-auto-scaling-group --cli-input-json  file://asg.json
ASG_ARN=$(aws autoscaling  describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME  ARN=$ASG_ARN"
```

The output of the above command looks like the below:

```plaintext
EcsSpotWorkshop-ASG-SPOT ARN=arn:aws:autoscaling:us-east-1:0004746XXXX:autoScalingGroup:dd7a67e0-4df0-4cda-98d7-7e13c36dec5b:autoScalingGroupName/EcsSpotWorkshop-ASG-SPOT
```

The EC2 Spot auto scaling group looks like below in the [console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-SPOT?view=details)

Note that there is no capacity provisioned i.e. desired capacity is zero in the ASG. We expect the capacity to be scaled up automatically when we deploy applications later.

![EC2 Spot ASG](/images/ecs-spot-capacity-providers/asg_spot_initial_view_1.png)

Also note that there are no scaling policies attached to this Auto scaling group.

![EC2 Spot ASG](/images/ecs-spot-capacity-providers/asg_spot_initial_view_2.png)
