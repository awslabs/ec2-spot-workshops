---
title: "Creating an Auto Scaling Group (ASG) with EC2 Spot Instances"
chapter: true
weight: 10
---

### Creating an Auto Scaling Group (ASG) with EC2 Spot Instances

In this section, let us create an Auto Scaling group for EC2 Spot Instances using the Launch Template created in previous section. This procedure is exactly same as the previous section except the few changes specific to the  configuration for EC2 Spot instances.

One of the best practices for adoption of Spot Instances is to diversify the EC2 instances across different instance types and availability zones, in order to tap into multiple spare capacity pools. The ASG currently will support up to 20 different instance type configurations for diversification.

One key criteria for choosing the instance size can be based on the ECS Task vCPU and Memory limit configuration.  For example, look at the ECS task resource limits in the file **webapp-ec2-task.json**

_**"cpu": "256", "memory": "1024"**_

This means the ratio for vCPU:Memory is **1:4**.  So it would be ideal to select instance size which satisfy this criteria. The instance lowest size which satisfy this critera are of large size.  Please note there may be bigger sizes which satisfy 1:4 ratio. But in this workshop, let's select the smallest size i.e. large to illustrate the aspect of EC2 spot diversification.

So let's select different instance types and generations for large size using the Instance Types console within the AWS EC2 console as follows.

![OD ASG](/images/ecs-spot-capacity-providers/ec1.png)
![OD ASG](/images/ecs-spot-capacity-providers/ec2.png)
![OD ASG](/images/ecs-spot-capacity-providers/ec3.png)

We selected 10 different instant types as seen asg.json but you can configure up to 20 different instance types in an Autoscaling group.

Copy the file  **templates/asg.json** for the Auto scaling group configuration.

```
cp templates/asg.json ./asg_spot.json
```

Take a moment to look at the user asg_spot.json to see various configuration options in the ASG.

Set the following commands to set variables and substitute them in the template

```
export ASG_NAME=ecs-spot-workshop-asg-spot
export OD_PERCENTAGE=0 # Note that ASG will have 0% On-Demand, 100% Spot
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$PUBLIC_SUBNET_LIST#g"  -e "s#%SERVICE_ROLE_ARN%#$SERVICE_ROLE_ARN#g"  asg_spot.json
```

Create the Auto scaling group for EC2 spot

```
aws autoscaling create-auto-scaling-group --cli-input-json  file://asg_spot.json
ASG_ARN=$(aws autoscaling  describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME  ARN=$ASG_ARN"
```

The output for the above command looks like this

```
EcsSpotWorkshop-ASG-SPOT ARN=arn:aws:autoscaling:us-east-1:000474600478:autoScalingGroup:dd7a67e0-4df0-4cda-98d7-7e13c36dec5b:autoScalingGroupName/EcsSpotWorkshop-ASG-SPOT
```

The above auto scaling looks like below in console 

![Spot ASG](/images/ecs-spot-capacity-providers/22.png)