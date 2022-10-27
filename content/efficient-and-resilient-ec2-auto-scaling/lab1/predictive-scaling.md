+++
title = "Predictive Scaling"
weight = 40
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

## 2. Configure predictive scaling policy using custom CloudWatch metrics

In a predictive scaling policy, you can use predefined or custom metrics. Custom metrics are useful when the predefined metrics (CPU, network I/O, and Application Load Balancer request count) do not sufficiently describe your application load.


For the load metric specification, the most useful metric is a metric that represents the load on an Auto Scaling group as a whole, regardless of the group's capacity.And for the scaling metric specification, the most useful metric to scale by is an average throughput or utilization per instance metric.


## 3. Preload CloudWatch metrics data

If you're creating a new auto scaling group for every time you deploy your application, predictive scaling needs at least 24 hours of metrics data and for this reason we will be loading data into custom CloudWatch metrics to be used for forecasting capacity for this auto scaling group.

### Prepare custom metric data: scaling metric

Change current directory

```bash
cd lab1/files
```

**Export metric data**

```bash
aws cloudwatch get-metric-data --cli-input-json file://query-instances.json | jq '.MetricDataResults[].Values' > instances-results.json
```

```bash
l=$(jq length metric-instances.json)
i=0
while [ $i -lt $l ]
do
  time=$(date -v $[-5*$i]M)
  echo $i
  cat metric-instances.json | jq --argjson i $i --arg t $time '.[$i].Timestamp |= $t' > tmp.json && mv tmp.json metric-instances.json
  i=$[$i+1]
done
```

Add auto scaling group name
```bash
sed -i '' -e 's/ASGPLACEHOLDER/Test Predictive ASG/g' metric-instances.json 

```
### Prepare custom metric data: load metric

**Export metric data**
```bash
aws cloudwatch get-metric-data --cli-input-json file://query-cpu.json | jq '.MetricDataResults[].Values' > cpu-results.json
```

Update timestamps
```bash
l=$(jq length metric-cpu.json)
i=0
while [ $i -lt $l ]
do
  time=$(date -v $[-5*$i]M)
  echo $i
  cat metric-cpu.json | jq --argjson i $i --arg t $time '.[$i].Timestamp |= $t' > tmp.json && mv tmp.json metric-cpu.json
  i=$[$i+1]
done
```
Add auto scaling group name
```bash
sed -i '' -e 's/ASGPLACEHOLDER/Test Predictive ASG/g' metric-cpu.json 
```

{{% notice note %}}
By default, Amazon EC2 Auto Scaling doesn't scale your EC2 capacity higher than your defined maximum capacity. However, it might be helpful to let it scale higher with slightly more capacity to avoid performance or availability issues.
{{% /notice %}}

Pre-launch instances, choose how far in advance you want your instances launched before the forecast calls for the load to increase.

When working with predictive scaling and custom metric, you have the option to choose pre-configured pair of metrics or go completely custom metrics for scaling,
load, capacity metrics.

{{% notice info %}}
A core assumption of predictive scaling is that the Auto Scaling group is homogenous and all instances are of equal capacity. If this isn’t true for your group, forecasted capacity can be inaccurate. 
{{% /notice %}}


