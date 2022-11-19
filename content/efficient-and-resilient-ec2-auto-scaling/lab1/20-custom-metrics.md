+++
title = "Working with Custom Metrics"
weight = 120
+++

In most use cases the predefined metrics will be used to define and create a predictive scaling policy. For the sake of this workshop and because predictive scaling forecast  requires 24 hours of metric history before it can generate forecasts, we will be using CloudWatch custom metrics with preloaded data to help us configure predictive scaling and see the capacity forecast.


### Use predictive scaling with CloudWatch custom metrics

In a predictive scaling policy, you can use predefined or [**Custom metrics**](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html) which are useful when the predefined metrics (CPU, network I/O, and Application Load Balancer request count) do not sufficiently describe your application load.

To generate forecasts, the predictive scaling algorithm needs three metrics as input: a **load metric** that represents total demand on an Auto Scaling group, the **number of instances** that represents the capacity of the Auto Scaling groups, and a **scaling metric** that represents the average utilization of the instances in the Auto Scaling groups.

For the **load** metric specification, the most useful metric is a metric that represents the load on an Auto Scaling group as a whole, regardless of the group's capacity. For the **scaling** metric specification, the most useful metric to scale by is an average throughput or utilization per instance metric.

If you're creating a new auto scaling group for every time you deploy your application, predictive scaling needs at least 24 hours of metrics data and for this reason we will be loading data into custom CloudWatch metrics to be used for forecasting capacity for this auto scaling group.

