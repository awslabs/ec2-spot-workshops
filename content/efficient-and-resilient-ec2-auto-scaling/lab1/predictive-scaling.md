+++
title = "Predictive Scaling"
weight = 110
+++


In this step, you are going to configure Predictive scaling for the autoscaling group.

### What is Predictive scaling?

Predictive scaling uses machine learning to predict capacity requirements based on historical data from CloudWatch. The machine learning algorithm consumes the available historical data and calculates capacity that best fits the historical load pattern, and then continuously learns based on new data to make future forecasts more accurate.

### When to use Predictive scaling?

In general, if you have regular patterns of traffic increases and applications that take a long time to initialize, you should consider using predictive scaling. Predictive scaling can help you scale faster by launching capacity in advance of forecasted load, compared to using only dynamic scaling, which is reactive in nature. Predictive scaling can also potentially save you money on your EC2 bill by helping you avoid the need to overprovision capacity.

{{% notice info %}}
Predictive scaling requires 24 hours of metric history before it can generate forecasts. Predictive scaling finds patterns in CloudWatch metric data from the previous 14 days to create an hourly forecast for the next 48 hours. Forecast data is updated daily based on the most recent CloudWatch metric data.
{{% /notice %}}


### Explain

To generate forecasts, the predictive scaling algorithm needs three metrics as input: a load metric that represents total demand on an Auto Scaling group, the number of instances that represents the capacity of the Auto Scaling groups, and a scaling metric that represents the average utilization of the instances in the Auto Scaling groups.




### 1. Enable and Configure Predictive Scaling policy


```
cat <<EoF > predictive-scaling-policy-cpu.json
{
    "MetricSpecifications": [
        {
            "TargetValue": 25,
            "PredefinedMetricPairSpecification": {
                "PredefinedMetricType": "ASGCPUUtilization"
            }
        }
    ],
    "Mode": "ForecastAndScale"
}
EoF
```

```
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name "Example Application Auto Scaling Group" \
    --policy-name "CPUUtilizationpolicy" \
    --policy-type "PredictiveScaling" \
    --predictive-scaling-configuration file://predictive-scaling-policy-cpu.json
```

```
aws autoscaling get-predictive-scaling-forecast
```