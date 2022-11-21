+++
title = "Create Predictive Scaling Policy"
weight = 140
+++

Following up with our scenario, one of the requirements is to reduce the impact of time the application takes to become ready.

Predictive scaling has a **SchedulingBufferTime** parameter that  allows instances to launch in advance. For example, the forecast says to add capacity at 10:00 AM, and you choose to pre-launch instances by 5 minutes. In that case, the instances will be launched at 9:55 AM. The intention is to give resources time to be provisioned.

### Create the predictive scaling policy

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
