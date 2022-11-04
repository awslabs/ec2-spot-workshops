+++
title = "Review the outcome of predictive scaling"
weight = 145
+++

### 6. Verify predictive scaling policy in AWS Console

{{% notice warning %}}
Predictive scaling scales the number of instances at the **beginning of each hour**.
{{% /notice %}}

1. **Navigate** to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details), click on auto scaling group `ec2-workshop-asg`
2. Click on tab **Automatic scaling**
3. A new policy has been created under **Predictive scaling policies**

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/predictive-scaling-forcast.png)

At the head of next hour, predictive scaling is forecasting capacity of 5 instances
![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/capacity-forcast.png)

5 minutes before the head of the hour, predictive scaling starts launching instances. (Can you guess why 5 minutes?)
![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/asg-activity.png)

Now we have 5 healthy instances proactively launched, running and ready for the forecasted load.
![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/asg-instances.png)

Also you can use **AWS CLI** to verify the created predictive policy
```bash
aws autoscaling describe-policies \
    --auto-scaling-group-name 'ec2-workshop-asg'
```