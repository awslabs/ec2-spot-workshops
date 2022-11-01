+++
title = "Optional"
weight = 180
+++


### Exercise: Onetime scaling event is coming, how to handle scaling?

Scheduled Scaling

### Exercise: A predictive scaling policy that can scale higher than maximum capacity

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