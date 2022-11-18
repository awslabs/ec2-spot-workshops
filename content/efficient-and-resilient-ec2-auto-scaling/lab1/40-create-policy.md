+++
title = "Create Predictive Scaling Policy"
weight = 140
+++

### Create the predictive scaling policy

Following up with our scenario, one of the requirements is to reduce the impact of time the application takes to become ready. You found out that the predictive scaling policy can pre-launch instances, Using parameter **SchedulingBufferTime** in policy configuration you can choose how far in advance (seconds) you want your instances launched before the forecast calls for the load to increase.

1. In **Cloud9** IDE terminal, check you're at this directory `ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling`

2. Review the policy configuration file and note how the custom metrics have been used in it.
  ```bash
  cat ./policy-config.json
  ```

```json
    "Mode": "ForecastAndScale",
    "SchedulingBufferTime": 300,
    "MaxCapacityBreachBehavior": "HonorMaxCapacity"
```

2. Run this command to create the policy with the custom metrics and attach it to the auto scaling group.
```bash
aws autoscaling put-scaling-policy --policy-name workshop-predictive-scaling-policy \
  --auto-scaling-group-name "ec2-workshop-asg" --policy-type PredictiveScaling \
  --predictive-scaling-configuration file://policy-config.json
```

If successful, the command should return the created policy ARN.

```
{
    "PolicyARN": "arn:aws:autoscaling:ap-southeast-2:115751184547:scalingPolicy:df0e550e-b0d6-4924-8663-d394de77b0e3:autoScalingGroupName/ec2-workshop-asg:policyName/workshop-predictive-scaling-policy",
    "Alarms": []
}
```

{{% notice note %}}
To **edit** a predictive scaling policy that uses customized metrics, you must use the **AWS CLI** or an **SDK**. Console support for customized metrics will be available soon.
{{% /notice %}}
