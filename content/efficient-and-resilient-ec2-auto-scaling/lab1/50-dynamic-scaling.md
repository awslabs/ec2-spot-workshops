+++
title = "Configure Dynamic scaling"
weight = 50
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


{{% notice note %}}
In previous chapter you verified that the Auto Scaling group successfully forecasted with predictive scaling policy. As predictive scaling starts launching instances only **beginning of each hour**, to save time you can proceed with this next step.
{{% /notice %}}

{{% notice info %}}
With predictive scaling, EC2 Auto Scaling does not **scale in** when the predicted capacity is lower than the actual capacity. Due to this behavior, you need to combine predictive scaling with another scaling policy to scale in capacity when it's not needed.
{{% /notice %}}

### Configure Dynamic scaling for scale in and demand changes

**Dynamic scaling** is used to automatically scale capacity in response to real-time changes in resource utilization. Using it with predictive scaling helps you follow the demand curve for your application closely, **scaling in** during periods of low traffic and scaling out when traffic is higher than expected to react to demand changes or spikes that were not forecasted by predictive scaling.

{{% notice note %}}
When **multiple** scaling policies are active, each policy determines the desired capacity independently, and the desired capacity is set to the **maximum** of those.
{{% /notice %}}

In this section, you configure the Auto Scaling group to automatically scale out and scale in as your **application load** fluctuates. You use a average CPU utilization across the Auto Scaling group instances.

1. Review this command to understand the options, then go ahead and run it 

```
cat <<EoF > asg-automatic-scaling.json
{
  "AutoScalingGroupName": "ec2-workshop-asg",
  "PolicyName": "automaticScaling",
  "PolicyType": "TargetTrackingScaling",
  "EstimatedInstanceWarmup": 300,
  "TargetTrackingConfiguration": {
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 75,
    "DisableScaleIn": false
  }
}
EoF
```

2. Go ahead and apply the scaling policy:

```
aws autoscaling put-scaling-policy --cli-input-json file://asg-automatic-scaling.json
```

Command should return policy ARN and target tracking alarms that have been created.

```json
{
    "PolicyARN": "arn:aws:autoscaling:ap-southeast-2:115751184547:scalingPolicy:04b7b7eb-6d65-40fb-946d-e5d2a1a55747:autoScalingGroupName/ec2-workshop-asg:policyName/automaticScaling",
    "Alarms": [
        {
            "AlarmName": "TargetTracking-ec2-workshop-asg-AlarmHigh-6c60b9c6-b7e8-4fcf-9733-d9c390754b99",
            "AlarmARN": "arn:aws:cloudwatch:ap-southeast-2:115751184547:alarm:TargetTracking-ec2-workshop-asg-AlarmHigh-6c60b9c6-b7e8-4fcf-9733-d9c390754b99"
        },
        {
            "AlarmName": "TargetTracking-ec2-workshop-asg-AlarmLow-70cbbd68-5540-4293-a4c5-3ab2d8aa72bb",
            "AlarmARN": "arn:aws:cloudwatch:ap-southeast-2:115751184547:alarm:TargetTracking-ec2-workshop-asg-AlarmLow-70cbbd68-5540-4293-a4c5-3ab2d8aa72bb"
        }
    ]
}
```

3. Navigate to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created scaling policy in the **Scaling Policies** tab.
4. The dynamic scaling policy **reduces** the capacity at the times with low demand using the **average CPU utilization** metric.

{{% notice note %}}
Because predictive scaling starts launching instances only **beginning of each hour**, you have to wait for the end of the hour to see dynamic scaling in action alongside predictive scaling. To save time you can proceed with this next chapters.
{{% /notice %}}


Now you have predictive and dynamic scaling polices in place to ensure application responsiveness at the times of increased demand. **You have successfully completed the first task** you've been asked to do. **Great work!**

#### **You have one more task to do, proceed to next chapter to find out..**