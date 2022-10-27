+++
title = "Predictive Scaling Continued.."
weight = 50
+++


### 4. Upload metric data to CloudWatch

{{% notice note %}}
When you publish your own metrics, make sure to publish the data points at a minimum frequency of five minutes. Amazon EC2 Auto Scaling retrieves the data points from CloudWatch based on the length of the period that it needs. For example, the load metric specification uses hourly metrics to measure the load on your application
{{% /notice %}}

```bash
aws cloudwatch put-metric-data --namespace "Workshop Custom Predictive Metrics" --metric-data file://metric-instances.json
```

```bash
aws cloudwatch put-metric-data --namespace "Workshop Custom Predictive Metrics" --metric-data file://metric-cpu.json
```

### 5. Create the predictive scaling policy
```bash
aws autoscaling put-scaling-policy --policy-name workshop-predictive-scaling-policy \
  --auto-scaling-group-name "Test Predictive ASG" --policy-type PredictiveScaling \
  --predictive-scaling-configuration file://policy-config.json
```

{{% notice note %}}
To edit a predictive scaling policy that uses customized metrics, you must use the AWS CLI or an SDK. Console support for customized metrics will be available soon.
{{% /notice %}}

```bash
aws autoscaling get-predictive-scaling-forecast --auto-scaling-group-name "Test Predictive ASG" \
    --policy-name workshop-predictive-scaling-policy \
    --start-time "2021-09-12T00:00:00Z" \
    --end-time "2021-09-13T23:00:00Z"
```


Verify scaling has been created, get predictive scaling policy

```bash
aws autoscaling describe-policies \
    --auto-scaling-group-name 'Example Application Auto Scaling Group'
```
### 6. Verify predictive scaling policy in AWS Console