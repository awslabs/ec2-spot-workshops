+++
title = "Review the outcome of predictive scaling"
weight = 40
+++

### Verify predictive scaling policy in AWS Console

{{% notice info %}}
Predictive scaling scales the number of instances at the **beginning of each hour**.
{{% /notice %}}

1. **Navigate** to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details), click on auto scaling group `ec2-workshop-asg`
2. Click on tab **Automatic scaling**
3. A new policy has been created under **Predictive scaling policies**

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/predictive-scaling-forcast.png)

At the head of next hour, predictive scaling is forecasting capacity of 5 instances
![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/capacity-forcast.png)

### Challenges 

{{% expand "Do you know at what time predictive scaling will start launching instances? Expand to see the answer." %}}
Predictive scaling starts launching instances 5 minutes before the head of the hour, because you have set SchedulingBufferTime as 300 seconds (5 minutes).
![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/asg-activity.png)

Predictive scaling starts launching instances only **beginning of each hour**, therefore you have to wait for the current hour to end before you can see the actual launch of 5 instances. To save time and continue with the workshop you can back to this step by end of hour and compare ASG activity.
![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/asg-instances.png)
{{% /expand %}}

{{% expand "Do you know the AWS CLI command to verify the created predictive policy? Expand to see the answer." %}}

```bash
aws autoscaling describe-policies \
    --auto-scaling-group-name 'ec2-workshop-asg'
```
{{% /expand %}}