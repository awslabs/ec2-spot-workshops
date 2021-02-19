---
title: "Create EC2 Spot Auto Scaling Group and Capacity Provider"
weight: 50
---

## Create the Spot Auto Scaling Group

In this section, you create an Auto Scaling group for EC2 Spot Instances using the Launch Template created by the CloudFormation stack. This procedure is exactly the same as the previous section, except for a few changes specific to the configuration for Spot Instances. 

Copy the file **templates/asg.json** for the EC2 Auto Scaling group configuration.

```bash
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/
cp templates/asg.json spot-asg.json
```

{{% notice note %}}
Read the **spot-asg.json** file. We configured the instance diversification in **spot-asg.json** according to the guidelines from our **[previous section](/ecs-spot-capacity-providers/module-1/selecting_spot_instance_types.html)**. Notice how we've chosen instance types with similar hardware characteristics in order to have a consistent auto scaling experience. Check also how the allocation strategy chosen for Spot is **[Capacity-optimized](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/)**, this will let the ASG select the instances that mimimize the frequency of spot interruptions.
{{% /notice %}}

We will now replace the environment variables in the spot-asg.json file with the Spot settings, setting the OnDemand percentage to 0 and substituting the CloudFormation environment variables that we exported earlier.


```bash
export ASG_NAME=EcsSpotWorkshop-ASG-SPOT
export OD_PERCENTAGE=0 # Note that ASG will have 0% On-Demand, 100% Spot
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g"  -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g" spot-asg.json
```

Finally we create the ASG for the Spot Instances and store the ARN for the spot group.

```bash
aws autoscaling create-auto-scaling-group --cli-input-json  file://spot-asg.json
ASG_ARN=$(aws autoscaling  describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME  ARN=$ASG_ARN"
```

The output of the above command will appear as below:

```plaintext
EcsSpotWorkshop-ASG-SPOT ARN=arn:aws:autoscaling:us-east-1:0004746XXXX:autoScalingGroup:dd7a67e0-4df0-4cda-98d7-7e13c36dec5b:autoScalingGroupName/EcsSpotWorkshop-ASG-SPOT
```

The EC2 Spot auto scaling group should appear as below in the [console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-SPOT?view=details) Note that there is no capacity provisioned i.e. desired capacity is zero in the ASG. We expect the capacity to scale up automatically when we deploy applications later.

<!-- We've already done this exercise, this bit does not add much at this stage. Ready for removal.
![EC2 Spot ASG](/images/ecs-spot-capacity-providers/asg_spot_initial_view_1.png)

Also note that there are no scaling policies attached to this Auto scaling group.

![EC2 Spot ASG](/images/ecs-spot-capacity-providers/asg_spot_initial_view_2.png)
-->

## Create the Spot Capacity Provider

To create the capacity provider, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you are looking to launch your cluster.
* Click **Clusters**
* Click [EcsSpotWorkshop] (https://console.aws.amazon.com/ecs/home?#/clusters/EcsSpotWorkshop)
* Click the tab **Capacity Providers**
* Click **Create**
* For Capacity provider name, enter **CP-SPOT**
* For Auto Scaling group, select **EcsSpotWorkshop-ASG-SPOT**
* For Managed Scaling, leave with default selection of **Enabled**
* For Target capacity %, enter **100**
* For Managed termination protection, leave with default selection of *Enabled*
* Click on **Create** on the bottom right 


![Capacity Provider on Spot ASG](/images/ecs-spot-capacity-providers/CP_SPOT.png)

{{% notice tip %}}
We encourage you to do a similar exercise to what you did with the OnDemand Auto Scaling Group. Check in the console that the 
ECS Cluster has the new **CP-SPOT** Capacity Provider, and check out the configuration and scaling policy created on the **EcsSpotWorkshop-ASG-SPOT**
Auto Scaling Group
{{% /notice %}}

Refresh the *Capacity Providers* tab, and you will see the CP-SPOT is created and attached to the ECS cluster.

![Capacity Provider on Spot ASG](/images/ecs-spot-capacity-providers/CP-SPOT.png)

<!-- doesn't add much after we have done previous exercises
Also note, that the capacity provider creates a target tracking policy on the EcsSpotWorkshop-ASG-SPOT. 
Go to the [AWS EC2 Console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-SPOT?view=scaling) and select the Automatic Scaling tab on the EcsSpotWorkshop-ASG-SPOT ASG.

![Spot ASG](/images/ecs-spot-capacity-providers/asg_spot_with_cp_view_1.png)
--> 