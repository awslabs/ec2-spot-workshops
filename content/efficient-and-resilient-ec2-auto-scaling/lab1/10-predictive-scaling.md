+++
title = "Predictive scaling"
weight = 10
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


After reviewing the differences between Scaling policies, you have decided to go with Predictive Scaling because it can help you scale faster by launching capacity in advance of forecasted load, compared to using only dynamic scaling, which is reactive in nature. Predictive scaling can also potentially save you money on your EC2 bill by helping you avoid the need to overprovision capacity.

### How it works?
Predictive scaling requires 24 hours of metric history before it can generate forecasts. Predictive scaling finds patterns in CloudWatch metric data from the previous 14 days to create an hourly forecast for the next 48 hours. Forecast data is updated daily based on the most recent CloudWatch metric data.

To generate forecasts, the predictive scaling algorithm needs **three** metrics as input: 
- **a load metric** that represents total demand on an Auto Scaling group. For the **load** metric specification, the most useful metric is a metric that represents the load on an Auto Scaling group as a whole, regardless of the group's capacity.
- **the number of instances** that represents the capacity of the Auto Scaling groups
- **a scaling metric** that represents the average utilization of the instances in the Auto Scaling groups. For the **scaling** metric specification, the most useful metric to scale by is an average throughput or utilization per instance metric.

{{% notice info %}}
Read more about predictive scaling in the [New – Predictive Scaling for EC2, Powered by Machine Learning](https://aws.amazon.com/blogs/aws/new-predictive-scaling-for-ec2-powered-by-machine-learning/) blog post.
{{% /notice %}}



{{% notice warning %}}
A core assumption of predictive scaling is that the Auto Scaling group is **homogenous** and all instances are of **equal capacity**. In this workshop you use **t3.micro**, a single instance type, in the Auto Scaling group.
If your actual workload uses Auto Scaling groups with multiple instance types (mixed instance groups), then use caution when creating predictive scaling policies. Predictive scaling with mixed instance groups can forecast capacity inaccurately and launch instance types of unequal capacity.
{{% /notice %}}

### 1. Enable and Configure Predictive Scaling policy

Predictive scaling can be created in "**forecast only**" mode so that you can evaluate the forecast before predictive scaling starts actively scaling capacity. You can view the forecast and recent metric data from CloudWatch in graph form from the Amazon EC2 Auto Scaling console. When you are ready to start scaling with predictive scaling, you can switch the policy from "**forecast only**" mode to "**forecast and scale**" mode. After you switch to "forecast and scale" mode, your Auto Scaling group starts scaling based on the forecast.

In this step, you are going to configure predictive scaling in "forecast only" mode for your Auto Scaling group.

1. In **Cloud9 IDE** terminal, run this command to create a simple configurations file for predictive scaling policy based on predefined metrics pair.

```bash
cat <<EoF > predictive-scaling-policy-cpu.json
{
    "MetricSpecifications": [
        {
            "TargetValue": 50,
            "PredefinedMetricPairSpecification": {
                "PredefinedMetricType": "ASGCPUUtilization"
            }
        }
    ],
    "Mode": "ForecastOnly"
}
EoF
```

2. Create the predictive scaling policy and attach it to the Auto Scaling group.

```bash
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name "ec2-workshop-asg" \
    --policy-name "CPUUtilizationpolicy" \
    --policy-type "PredictiveScaling" \
    --predictive-scaling-configuration file://predictive-scaling-policy-cpu.json
```

#### Verify predictive scaling policy in AWS Console

1. **Navigate** to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details), click on Auto Scaling group `ec2-workshop-asg`
2. Click on tab **Automatic scaling**
{{% notice note %}}
Note that Predictive scaling forecast shows **no data** as it requires 24 hours of metric history before it can generate forecasts. Therefore in next chapter, you use CloudWatch custom metrics to create a history of data that can be used for forecasting by predictive scaling policy.
{{% /notice %}}
![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/predictive-scaling-no-data.png)
