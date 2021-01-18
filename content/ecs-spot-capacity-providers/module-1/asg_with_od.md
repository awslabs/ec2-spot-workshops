---
title: "Create On-Demand Auto Scaling group"
weight: 40
---

So far we have an ECS Cluster created and a Launch Template that bootstrap ECS agents and links them against the ECS Cluster. In this section, we will create an EC2 Auto Scaling group (ASG) for On-Demand Instances using the Launch Template created by the CloudFormation stack. Go back to your Cloud9 environment and copy the file **templates/asg.json** for the EC2 Auto Scaling group configuration.

```bash
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/
cp templates/asg.json .
```

Take a moment to read the **asg.json** file and understand the various configuration options for the EC2 Auto Scaling group. Then replace the environment variables with ASG name and On-Demand percentage field in ASG.

```bash
export ASG_NAME=EcsSpotWorkshop-ASG-OD
export OD_PERCENTAGE=100 # Note that ASG will have 100% On-Demand, 0% Spot
```

Substitute the placeholder names in the template with actual values from the environment variables.

```bash
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g" -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g" asg.json
```

Create the ASG for the On-Demand Instances.

```bash
aws autoscaling create-auto-scaling-group --cli-input-json  file://asg.json
ASG_ARN=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME  ARN=$ASG_ARN"
```
The output of the above command will appear and will be similar to the one below. We have captured the ASG ARM to use in the next sections.
```plaintext
EcsSpotWorkshop-ASG-OD ARN=arn:aws:autoscaling:us-east-1:0004746XXXX:autoScalingGroup:1e9de503-068e-4d78-8272-82536fc92d14:autoScalingGroupName/EcsSpotWorkshop-ASG-OD 
```


The On-Demand auto scaling group will appear as below in the [console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-OD?view=details)


### Optional Exercises

Based on the configuration and steps above, try to answer the following questions:


* Now that we have created an OnDemand AutoScaling Group, **Can you guess how much capacity we have allocated to our Cluster ?** 


{{%expand "Show me the answer" %}}
{{% notice note %}}
So far there is no capacity provisioned in the Auto Scaling Group, or in our ECS cluster. Check how the desired capacity is zero in the ASG. We expect the capacity to scale up automatically when we deploy applications later.
{{% /notice %}}

![On-demand ASG](/images/ecs-spot-capacity-providers/asg_od_initial_view_1.png)
{{% /expand %}}


* **How did we configured the Auto Scaling Group to Scale on demand instances?**

{{%expand "Show me the answer" %}}

{{% notice note %}}
Check in the console that there are no scaling policies attached to this Auto scaling group. Later on the policies will be created when we enable CAS (managed Cluster Auto Scaling) in the capacity providers.
{{% /notice %}}

![On-demand ASG](/images/ecs-spot-capacity-providers/asg_od_initial_view_2.png)

{{% /expand %}}