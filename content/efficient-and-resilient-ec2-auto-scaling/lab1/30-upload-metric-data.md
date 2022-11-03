+++
title = "Update metric data"
weight = 130
+++


### 4. Upload metric data to CloudWatch

{{% notice note %}}
When you publish your own metrics, make sure to publish the data points at a minimum frequency of five minutes. Amazon EC2 Auto Scaling retrieves the data points from CloudWatch based on the length of the period that it needs. For example, the load metric specification uses hourly metrics to measure the load on your application
{{% /notice %}}

```bash
cd ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling/
```

```bash
aws cloudwatch put-metric-data --namespace "Workshop Custom Predictive Metrics" --metric-data file://metric-instances.json
```

```bash
aws cloudwatch put-metric-data --namespace "Workshop Custom Predictive Metrics" --metric-data file://metric-cpu.json
```
#### Verify in CloudWatch
