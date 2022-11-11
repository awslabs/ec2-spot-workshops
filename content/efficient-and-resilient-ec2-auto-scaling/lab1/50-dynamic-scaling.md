+++
title = "Dynamic scaling"
weight = 150
+++

## Use predictive scaling with dynamic scaling

{{% notice warning %}}
When using predictive scaling, Amazon EC2 Auto Scaling scales the number of instances at the **beginning of each hour**. Scales out if actual capacity is less than the predicted, **however** if actual capacity is greater than the predicted capacity, EC2 Auto Scaling **doesn't scale in** capacity. That's why we need to combine predictive scaling with another scaling policy to scale in capacity when it's not needed.
{{% /notice %}}

Dynamic scaling is used to automatically scale capacity in response to real-time changes in resource utilization. Using it with predictive scaling helps you follow the demand curve for your application closely, **scaling in** during periods of low traffic and scaling out when traffic is higher than expected.

{{% notice note %}}
When **multiple** scaling policies are active, each policy determines the desired capacity independently, and the desired capacity is set to the maximum of those.
{{% /notice %}}

**For example**, if 10 instances are required to stay at the target utilization in a target tracking scaling policy, and 8 instances are required to stay at the target utilization in a predictive scaling policy, then the group's desired capacity is set to 10.

Now you are going to configure the Auto Scaling group to automatically scale out and scale in as your application load fluctuates. When you configure dynamic scaling, you must define how to scale in response to changing demand. For example, you have a web application that currently runs on two instances and you do not want the CPU utilization of the Auto Scaling group to exceed 70 percent. You can configure your Auto Scaling group to scale automatically to meet this need. The policy type determines how the scaling action is performed.

{{% notice note %}}
**Target tracking** scaling policies simplify how you configure dynamic scaling. You select a predefined metric or configure a customized metric, and set a target value. Amazon EC2 Auto Scaling creates and manages the CloudWatch alarms that trigger the scaling policy and calculates the scaling adjustment based on the metric and the target value.
{{% /notice %}}

 The scaling policy adds or removes capacity as required to keep the metric at, or close to, the specified target value. In addition to keeping the metric close to the target value, a target tracking scaling policy also adjusts to the fluctuations in the metric due to a fluctuating load pattern and minimizes rapid fluctuations in the capacity of the Auto Scaling group.

1. Review this command to understand the options, then go ahead and run it 

```
cat <<EoF > asg-automatic-scaling.json
{
  "AutoScalingGroupName": "ec2-workshop-asg",
  "PolicyName": "automaticScaling",
  "PolicyType": "TargetTrackingScaling",
  "EstimatedInstanceWarmup": 180,
  "TargetTrackingConfiguration": {
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 50,
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

```
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