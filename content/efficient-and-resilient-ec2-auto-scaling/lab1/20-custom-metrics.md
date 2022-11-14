+++
title = "Working with Custom Metrics"
weight = 120
+++


## Use predictive scaling with CloudWatch custom metrics

In a predictive scaling policy, you can use predefined or custom metrics. **Custom metrics** are useful when the predefined metrics (CPU, network I/O, and Application Load Balancer request count) do not sufficiently describe your application load.

To generate forecasts, the predictive scaling algorithm needs three metrics as input: a **load metric** that represents total demand on an Auto Scaling group, the **number of instances** that represents the capacity of the Auto Scaling groups, and a **scaling metric** that represents the average utilization of the instances in the Auto Scaling groups.

For the **load** metric specification, the most useful metric is a metric that represents the load on an Auto Scaling group as a whole, regardless of the group's capacity. For the **scaling** metric specification, the most useful metric to scale by is an average throughput or utilization per instance metric.

If you're creating a new auto scaling group for every time you deploy your application, predictive scaling needs at least 24 hours of metrics data and for this reason we will be loading data into custom CloudWatch metrics to be used for forecasting capacity for this auto scaling group.

### **Load** and **Scaling** metrics data

As part of the CloudFormation stack you created, a bash script has been executed to update two metrics data files which will be used to push data into CloudWatch metrics.

**Verify** that metrics data files have been updated during the bootstrap:

1. Using **Cloud9 IDE** left navigation, browse folder `workshop/efficient-and-resilient-ec2-auto-scaling/lab1`
2. Open files `metric-cpu.json` and `metric-instances.json`
3. It should include today's date in UTC format and the auto scaling group name `ec2-workshop-asg`
4. **DO NOT CONTINUE** with this lab, if the files are **not updated** with the date and auto scaling group name.

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/metrics-files.png)