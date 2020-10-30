---
title: "Create EC2 Spot Auto Scaling Group"
weight: 15
---

In this section, you create an Auto Scaling group for EC2 Spot Instances using the Launch Template created in previous section. This procedure is exactly same as the previous section except for a few changes specific to the configuration for Spot Instances.


We have configured the instance diversification in asg.json. We chose instance types with similar hardware characteristics in order to have a consistent auto scaling experience.

Copy the file **templates/asg.json** for the Auto Scaling group configuration.

```bash
cp templates/asg.json .
```

Take a moment to look at the user asg_spot.json to see various configuration options in the ASG.

Run the following commands to set variables and substitute them in the template

```bash
export ASG_NAME=EcsSpotWorkshop-ASG-SPOT
export OD_PERCENTAGE=0 # Note that ASG will have 0% On-Demand, 100% Spot
```

Run the following command to substitute the template with actual values from the global variables

```bash
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g" asg.json
```

Create the Auto scaling group that will run Spot Instances in our cluster

```bash
aws autoscaling create-auto-scaling-group --cli-input-json  file://asg.json
ASG_ARN=$(aws autoscaling  describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME  ARN=$ASG_ARN"
```

The output of the above command looks like the below:

```plaintext
EcsSpotWorkshop-ASG-SPOT ARN=arn:aws:autoscaling:us-east-1:000474600478:autoScalingGroup:dd7a67e0-4df0-4cda-98d7-7e13c36dec5b:autoScalingGroupName/EcsSpotWorkshop-ASG-SPOT
```

The EC2 Spot auto scaling group looks like below in the [console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-SPOT?view=details)
Notice that there is no capacity provisioned i.e. desired capacity is zero. We expect the capacity to be scaled up when we deploy applications later.

![EC2 Spot ASG](/images/ecs-spot-capacity-providers/asg_spot_initial_view_1.png)

Also notice that there are no scaling policies attached to this auto scaling group

![EC2 Spot ASG](/images/ecs-spot-capacity-providers/asg_spot_initial_view_2.png)
