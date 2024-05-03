+++
title = "Create Predictive Scaling Policy"
weight = 30
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


Following up with your scenario, one of the requirements is to reduce the impact of time the application takes to become ready.

{{% notice info %}}
Predictive scaling has a **SchedulingBufferTime** parameter that  allows instances to launch in advance. For example, the forecast says to add capacity at 10:00 AM, and you choose to pre-launch instances by 5 minutes. In that case, the instances will be launched at 9:55 AM. The intention is to give the instances time to be initialized..
{{% /notice %}}

### Create the predictive scaling policy

1. In **Cloud9** IDE terminal, check you're at this directory `ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling`

2. Review the policy configuration file and note how the custom metrics have been used in it.
  ```bash
  cat ./policy-config.json
  ```
Note this section in the outcome, what effect do you think the parameter **MaxCapacityBreachBehavior** could have on the Auto Scaling group capacity?
{{% expand "Show answer" %}}
The forecasted capacity could be higher than the Auto Scaling group maximum capacity, when it happens, the **MaxCapacityBreachBehavior** parameter defines the behavior of the Auto Scaling group. It's currently set to **HonorMaxCapacity** to enforce the maximum capacity as a hard limit. You can also set it to **IncreaseMaxCapacity** to allow exceeding the maximum capacity with an upper limit that can be set by another parameter called **MaxCapacityBuffer**
{{% /expand %}}
```json
    "Mode": "ForecastAndScale",
    "SchedulingBufferTime": 300,
    "MaxCapacityBreachBehavior": "HonorMaxCapacity"
```

3. Run this command to create the policy with the custom metrics and attach it to the auto scaling group.

```bash
aws autoscaling put-scaling-policy --policy-name workshop-predictive-scaling-policy \
  --auto-scaling-group-name "ec2-workshop-asg" --policy-type PredictiveScaling \
  --predictive-scaling-configuration file://policy-config.json
```

If successful, the command should return the created policy ARN.

```json
{
    "PolicyARN": "arn:aws:autoscaling:ap-southeast-2:115751184547:scalingPolicy:df0e550e-b0d6-4924-8663-d394de77b0e3:autoScalingGroupName/ec2-workshop-asg:policyName/workshop-predictive-scaling-policy",
    "Alarms": []
}
```

{{% notice note %}}
To **edit** a predictive scaling policy that uses customized metrics, you must use the **AWS CLI** or an **SDK**. Console support for customized metrics will be available soon.
{{% /notice %}}