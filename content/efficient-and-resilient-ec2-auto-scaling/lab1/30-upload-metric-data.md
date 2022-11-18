+++
title = "Check CloudWatch Custom Metrics"
weight = 130
+++

#### Verify in CloudWatch metrics using AWS Console

Verify **scaling** and **load** metrics data in CloudWatch.

1. Navigate to [Amazon CloudWatch Console](https://console.aws.amazon.com/cloudwatch).
2. Make sure the correct **region** is selected in the **AWS Console**.
3. From left side navigation, click on **Metrics** then **All metrics**.
4. In the Browse tab select **Workshop Customer Predictive Metrics** under Custom namespaces
5. Select **AutoScalingGroupName**, then select the two metrics attached with **ec2-workshop-asg**. This should add the metrics to the graph.
6. To view all metrics data, from the time window filter select **3d** to view data of the last 3 days
7. Note the workload pattern in the custom metrics graph, this makes it a good use case for predictive scaling.

{{% notice info %}}
There might be few minutes delay between uploading the data to CloudWatch and actually seeing it on the graph. If the metrics graph doesn't show two days of data, give it 3 minutes and check back again.
{{% /notice %}}

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/cloudwatch-custom-metrics-graph.png)
