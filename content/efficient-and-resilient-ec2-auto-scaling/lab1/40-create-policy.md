+++
title = "Create Scaling Policy"
weight = 140
+++

### 5. Create the predictive scaling policy

{{% notice info %}}
A core assumption of predictive scaling is that the Auto Scaling group is homogenous and all instances are of equal capacity. If this isn’t true for your group, forecasted capacity can be inaccurate.
{{% /notice %}}

Pre-launch instances, choose how far in advance you want your instances launched before the forecast calls for the load to increase.

```
cat <<EoF > policy-config.json
{
    "MetricSpecifications": [
      {
        "TargetValue": 25,
        "CustomizedScalingMetricSpecification": {
          "MetricDataQueries": [
            {
              "Label": "Average CPU Utilization in ASG",
              "Id": "cpu_avg",
              "MetricStat": {
                "Metric": {
                  "MetricName": "CustomWSCPUUTILIZATION",
                  "Namespace": "Workshop Custom Predictive Metrics",
                  "Dimensions": [
                    {
                      "Name": "AutoScalingGroupName",
                      "Value": "ec2-workshop-asg"
                    }
                  ]
                },
                "Stat": "Average"
              },
              "ReturnData": true
            }
          ]
        },
        "CustomizedLoadMetricSpecification": {
          "MetricDataQueries": [
            {
              "Label": "Average CPU Utilization in ASG",
              "Id": "cpu_avg",
              "MetricStat": {
                "Metric": {
                  "MetricName": "CustomWSCPUUTILIZATION",
                  "Namespace": "Workshop Custom Predictive Metrics",
                  "Dimensions": [
                    {
                      "Name": "AutoScalingGroupName",
                      "Value": "ec2-workshop-asg"
                    }
                  ]
                },
                "Stat": "Sum"
              },
              "ReturnData": true
            }
          ]
        },
        "CustomizedCapacityMetricSpecification": {
          "MetricDataQueries": [
            {
              "Label": "Number of instances in ASG",
              "Id": "capacity_avg",
              "MetricStat": {
                "Metric": {
                  "MetricName": "CustomWSGroupInstances",
                  "Namespace": "Workshop Custom Predictive Metrics",
                  "Dimensions": [
                    {
                      "Name": "AutoScalingGroupName",
                      "Value": "ec2-workshop-asg"
                    }
                  ]
                },
                "Stat": "Average"
              },
              "ReturnData": true
            }
          ]
        }
      }
    ],
    "Mode": "ForecastAndScale",
    "SchedulingBufferTime": 300,
    "MaxCapacityBreachBehavior": "HonorMaxCapacity"
  }
EoF
```

```bash
aws autoscaling put-scaling-policy --policy-name workshop-predictive-scaling-policy \
  --auto-scaling-group-name "ec2-workshop-asg" --policy-type PredictiveScaling \
  --predictive-scaling-configuration file://lab1/policy-config.json
```

If successful, the command should return the created policy ARN.

```
{
    "PolicyARN": "arn:aws:autoscaling:ap-southeast-2:115751184547:scalingPolicy:df0e550e-b0d6-4924-8663-d394de77b0e3:autoScalingGroupName/ec2-workshop-asg:policyName/workshop-predictive-scaling-policy",
    "Alarms": []
}
```

{{% notice note %}}
To edit a predictive scaling policy that uses customized metrics, you must use the AWS CLI or an SDK. Console support for customized metrics will be available soon.
{{% /notice %}}


```bash
aws autoscaling get-predictive-scaling-forecast --auto-scaling-group-name "ec2-workshop-asg" \
    --policy-name workshop-predictive-scaling-policy \
    --start-time "2021-09-12T00:00:00Z" \
    --end-time "2021-09-13T23:00:00Z"
```
