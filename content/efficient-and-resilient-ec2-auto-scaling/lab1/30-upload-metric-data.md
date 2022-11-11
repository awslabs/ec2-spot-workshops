+++
title = "Update metric data"
weight = 130
+++


### 4. Upload metric data to CloudWatch


{{% notice note %}}
When you publish your own metrics, make sure to publish the data points at a minimum frequency of five minutes. Amazon EC2 Auto Scaling retrieves the data points from CloudWatch based on the length of the period that it needs. For example, the load metric specification uses hourly metrics to measure the load on your application
{{% /notice %}}

1. Make sure the **Cloud9** terminal pointing at the correct directory. `ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling`

2. Run these commands to add **scaling** metric data to CloudWatch and verify metric has been created.

```bash
aws cloudwatch put-metric-data --namespace "Workshop Custom Predictive Metrics" --metric-data file://lab1/metric-instances.json
```

```bash
aws cloudwatch list-metrics --namespace "Workshop Custom Predictive Metrics"
```

3. Then these commands to add **load** metric data to CloudWatch and verify metric has been created.

```bash
aws cloudwatch put-metric-data --namespace "Workshop Custom Predictive Metrics" --metric-data file://lab1/metric-cpu.json
```

```bash
aws cloudwatch list-metrics --namespace "Workshop Custom Predictive Metrics"
```

#### Verify in CloudWatch using AWS Console

1. Navigate to [Amazon CloudWatch Console](https://console.aws.amazon.com/cloudwatch).
2. Make sure the correct **region** is selected in the **AWS Console**.
3. From left side navigation, click on **Metrics** then **All metrics**.
4. In the Browse tab select **Workshop Customer Predictive Metrics** under Custom namespaces
5. Select **AutoScalingGroupName**, then select the two metrics attached with **ec2-workshop-asg**. This should add the metrics to the graph.
6. To view all metrics data, from the time window filter select **3d** to view data iof the last 3 days
7. Note the workload pattern in the custom metrics graph, this makes it a good use case for predictive scaling.

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/cloudwatch-custom-metrics-graph.png)

{{% notice info %}}
There might be few minutes delay between uploading the data to CloudWatch and actually seeing it on the graph. If the metrics doesn't contain two days of data, give it few minutes and check back again.
{{% /notice %}}