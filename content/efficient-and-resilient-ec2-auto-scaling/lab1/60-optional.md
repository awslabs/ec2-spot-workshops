+++
title = "Optional"
weight = 180
+++


### Exercise: Onetime scaling event is coming, how to handle scaling?

Scheduled Scaling

### Exercise: A predictive scaling policy that can scale higher than maximum capacity

{{% notice note %}}
By default, Amazon EC2 Auto Scaling doesn't scale your EC2 capacity higher than your defined maximum capacity. However, it might be helpful to let it scale higher with slightly more capacity to avoid performance or availability issues.
{{% /notice %}}

MaxCapacityBreachBehavior

```
{
    "MetricSpecifications": [
        {
            "TargetValue": 70,
            "PredefinedMetricPairSpecification": {
                "PredefinedMetricType": "ASGCPUUtilization"
            }
        }
    ],
    "MaxCapacityBreachBehavior": "IncreaseMaxCapacity",
    "MaxCapacityBuffer": 10
}
```


**Export metric data**

```bash
aws cloudwatch get-metric-data --cli-input-json file://query-instances.json | jq '.MetricDataResults[].Values' > instances-results.json
```

```bash
aws cloudwatch get-metric-data --cli-input-json file://query-cpu.json | jq '.MetricDataResults[].Values' > cpu-results.json
```
