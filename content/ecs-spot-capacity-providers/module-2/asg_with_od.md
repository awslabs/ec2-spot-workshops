---
title: "Creating an Auto Scaling Group (ASG) with EC2 On-Demand Instances"
weight: 5
---

In this section, we will create an EC2 Auto Scaling Group for On-Demand Instances using the Launch Template created in previous section.

Copy the file  **templates/asg.json** for the Auto scaling group configuration.

```
cp templates/asg.json .
```

Take a moment to look at the user asg.json to see various configuration options in the ASG.

Set the following variables for auto scaling configuration

```
export ASG_NAME=ecs-spot-workshop-asg-od
 export OD_PERCENTAGE=100 # Note that ASG will have 100% On-Demand, 0% Spot
```

Set the auto scaling service linked role ARN

Note: Replace the **\&lt;AWS Acount ID\&gt;** with your AWS account

```
export SERVICE_ROLE_ARN=&quot;arn:aws:iam::\&lt;AWS Account  ID\&gt;:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling_ec2&quot;
```

Run the following command to substitute the template with actual values from the global variables

```
sed -i -e &quot;s#%ASG_NAME%#$ASG_NAME#g&quot; -e &quot;s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g&quot; -e &quot;s#%PUBLIC_SUBNET_LIST%#$PUBLIC_SUBNET_LIST#g&quot;  -e &quot;s#%SERVICE_ROLE_ARN%#$SERVICE_ROLE_ARN#g&quot;  asg.json
```

Create the ASG for the On Demand Instances

```
aws autoscaling  create-auto-scaling-group --cli-input-json file://asg.json
 ASG_ARN=$(aws autoscaling  describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME_OD | jq -r &#39;.AutoScalingGroups[0].AutoScalingGroupARN&#39;)
echo &quot;$ASG_NAME_OD  ARN=$ASG_ARN&quot;
```

The output of the above command looks like below

```
ecs-spot-workshop-asg-od ARN=arn:aws:autoscaling:us-east-1:000474600478:autoScalingGroup:1e9de503-068e-4d78-8272-82536fc92d14:autoScalingGroupName/ecs-spot-workshop-asg-od
```

The above auto scaling group looks like below in the console


### Creating a Capacity Provider using above ASG with EC2 On-demand instances.

A capacity provider is used in association with a cluster to determine the infrastructure that a task runs

on.

Copy the template file  **templates/ecs-capacityprovider.json** to the current directory.

```
cp -Rfp templates/ecs-capacityprovider.json .
```

Take a moment to look at the user ecs-capacityprovider.json to see various configuration options in the Capacity Provider. When creating a capacity provider, you specify the following details:

1. An Auto Scaling group Amazon Resource Name (ARN)

1. Whether or not to enable managed scaling. When managed scaling is enabled, Amazon ECS manages the scale-in and scale-out actions of the Auto Scaling group through the use of AWS Auto Scaling scaling plans. When managed scaling is disabled, you manage your Auto Scaling groups yourself.
1. Whether or not to enable managed termination protection. When managed termination protection is enabled, Amazon ECS prevents Amazon EC2 instances that contain tasks and that are in an Auto Scaling group from being terminated during a scale-in action. Managed termination protection can only be enabled if the Auto Scaling group also has instance protection from scale in enabled

Run below commands to replace the configuration values in the template file.

```
export CAPACITY_PROVIDER_NAME=od-capacity_provider
 sed -i -e &quot;s#%CAPACITY_PROVIDER_NAME%#$CAPACITY_PROVIDER_NAME#g&quot;  -e &quot;s#%ASG_ARN%#$ASG_ARN#g&quot;  ecs-capacityprovider.json
```

Create the On-Demand Capacity Provider with Auto scaling group

```
CAPACITY_PROVIDER_ARN=$(aws ecs create-capacity-provider  --cli-input-json file://ecs-capacityprovider.json | jq -r &#39;.capacityProvider.capacityProviderArn&#39;)
 echo &quot;$OD_CAPACITY_PROVIDER_NAME  ARN=$CAPACITY_PROVIDER_ARN&quot;
```

The output of the above command looks like

```
od-capacity_provider ARN=arn:aws:ecs:us-east-1:000474600478:capacity-provider/od-capacity_provider
```
