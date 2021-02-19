---
title: "Create On-Demand Auto Scaling Group and Capacity Provider"
weight: 30
---

## Create the OnDemand Auto Scaling Group

So far we have an ECS Cluster created and a Launch Template that bootstrap ECS agents and links them against the ECS Cluster. In this section, we will create an EC2 Auto Scaling group (ASG) for On-Demand Instances using the Launch Template created by the CloudFormation stack. Go back to your Cloud9 environment and copy the file **templates/asg.json** for the EC2 Auto Scaling group configuration.

```bash
cd ~/environment/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/
cp templates/asg.json .
```
We will now replace the environment variables in the **asg.json** file with the On-Demand settings, changing the OnDemand percentage field in ASG and
substituting the CloudFormation environment variables that we exported earlier with the **asg.json** placeholder names in the template.

```bash
export ASG_NAME=EcsSpotWorkshop-ASG-OD
export OD_PERCENTAGE=100 # Note that ASG will have 100% On-Demand, 0% Spot
sed -i -e "s#%ASG_NAME%#$ASG_NAME#g" -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g" -e "s#%PUBLIC_SUBNET_LIST%#$VPCPublicSubnets#g" asg.json
```
{{% notice info%}}
Read the **asg.json** file and understand the various configuration options for the EC2 Auto Scaling group. Check how although this is an OnDemand we still apply instance diversification with the Prioritized allocation strategy. Check how the **Launch Template** we reviewed in the previous section is referenced in the Auto Scaling Group.
{{% /notice %}}

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


#### Optional Exercises

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


## Create the OnDemand Capacity Provider

To create a capacity provider, follow these steps:

* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you deployed the CFN template.
* Click **Clusters**
* Click [EcsSpotWorkshop] (https://console.aws.amazon.com/ecs/home#/clusters/EcsSpotWorkshop)
* Click the tab **Capacity Providers**
* Click **Create**
* For capacity provider name, enter **CP-OD**
* For Auto Scaling group, select **EcsSpotWorkshop-ASG-OD**
* For Managed Scaling, leave with default selection of **Enabled**
* For Target capacity %, enter **100**
* For Managed termination protection, leave with default selection of **Enabled**
* Click on **Create** on the bottom right 

![Capacity Provider on OD ASG](/images/ecs-spot-capacity-providers/CP_OD.png)

#### Optional Exercises

Based on the configuration and steps above, try to answer the following questions:

* **How would you check in the console the details about the new capacity provider created?**

{{%expand "Show me the answer" %}}
* Open the [ECS console] (https://console.aws.amazon.com/ecs/home) in the region where you deployed the CFN template.
* Click **Clusters**
* Click [EcsSpotWorkshop] (https://console.aws.amazon.com/ecs/home#/clusters/EcsSpotWorkshop)
* Refresh the *Capacity Providers* tab, and you will see the CP-OD is created and attached to the ECS cluster.

![Capacity Provider on OD ASG](/images/ecs-spot-capacity-providers/CP-OD.png)
{{% /expand %}}


* When creating the capacity provider against the Auto Scaling Group, we did enable "Managed Scaling" or CAS (Cluster Auto Scaling). **How can I confirm the right scaling policy has been created for this Auto Scaling Group?**

{{%expand "Show me the answer" %}}
The capacity provider creates a target tracking policy on the On-Demand Auto Scaling group. 

Go to the [AWS EC2 Console](https://console.aws.amazon.com/ec2autoscaling/home?#/details/EcsSpotWorkshop-ASG-OD?view=scaling) and select the Automatic Scaling tab on the EcsSpotWorkshop-ASG-OD.

![OD ASG](/images/ecs-spot-capacity-providers/asg_od_with_cp_view_1.png)
{{% /expand %}}