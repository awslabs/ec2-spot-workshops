+++
title = "Working with Custom Metrics"
weight = 20
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


{{% notice info %}}
In most use cases the predefined metrics are used to define and create a predictive scaling policy. However, you can use [**Custom metrics**](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html) when the predefined metrics (CPU, network I/O, and Application Load Balancer request count) do not sufficiently describe your application load.
{{% /notice %}}

As mentioned in previous chapter you don't have 24 hours data for predictive scaling to start forecasting. Therefore, as part of the CloudFormation stack you created, a bash script has been executed to update two CloudWatch custom metrics which can be used in creating the predictive scaling policy.

#### Verify in CloudWatch metrics using AWS Console

Verify **scaling** and **load** metrics data in CloudWatch.

1. Navigate to [Amazon CloudWatch Console](https://console.aws.amazon.com/cloudwatch).
2. Make sure the correct **region** is selected in the **AWS Console**.
3. From left side navigation, click on **Metrics** then **All metrics**.
4. In the Browse tab select **EC2 Workshop Custom Metrics** under Custom namespaces
5. Select **AutoScalingGroupName**, then select the two metrics attached with **ec2-workshop-asg**. This should add the metrics to the graph.
6. To view all metrics data, from the time window filter select **3d** to view data of the last 3 days
7. Note the workload pattern in the custom metrics graph, this makes it a good use case for predictive scaling.

{{% notice info %}}
If you're running the workshop in your own account, there might be up to 30 minutes delay for CloudWatch to make the metric data available.
{{% /notice %}}

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/cloudwatch-custom-metrics-graph.png)
