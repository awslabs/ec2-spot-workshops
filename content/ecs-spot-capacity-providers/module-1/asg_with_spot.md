---
title: "Create EC2 Spot Auto Scaling Group"
weight: 15
---

In this section, you create an Auto Scaling group for EC2 Spot Instances using the Launch Template created in previous section. This procedure is exactly same as the previous section except for a few changes specific to the configuration for Spot Instances.

One of the best practices for adoption of Spot Instances is to diversify the EC2 instances across different instance types and availability zones, in order to tap into multiple spare capacity pools. 

One key criteria for choosing the instance size can be based on the ECS Task vCPU and Memory limit configuration. For example, look at the ECS task resource limits in the file **ec2-task.json**:

```plaintext
"cpu": "256", "memory": "1024"
```

This means the ratio for vCPU:Memory in our ECS task that would run in the cluster is **1:4**. Ideally, we should select instance types with similar vCPU:Memory ratio, in order to have good utilization of the resources in the EC2 instances. The smallest instance type which would satisfy this critera from the latest generation of x86_64 EC2 instance types is m5.large. To learn more about EC2 instance types click [here](https://aws.amazon.com/ec2/instance-types/)

In order to adhere to EC2 Spot best practices and diversify our use of instance types (in order to tap into multiple spare capacity pools), we can use the EC2 Instance Types console to find instance types which have similar hardware characteristics to the m5.large. The t2 & t3 instance types are burstable instance types, which also fit our objective in this workshop. To learn more about EC2 burstable instance types, click [here](https://aws.amazon.com/ec2/instance-types/t3/)

![OD ASG](/images/ecs-spot-capacity-providers/ec1.png)
![OD ASG](/images/ecs-spot-capacity-providers/ec2.png)
![OD ASG](/images/ecs-spot-capacity-providers/ec3.png)

We selected 10 different instance types as can seen asg.json, but you can configure up to 20 different instance types in an ASG. We chose instance types with similar hardware characteristics in order to have a consistent auto scaling experience.

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
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g" -e "s#%LT_ID%#$LaunchTemplateId#g"  asg.json
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

Your Auto Scaling group should look like this in the AWS Management Console:

![Spot ASG](/images/ecs-spot-capacity-providers/22.png)