+++
title = "Create Scaling Policy"
weight = 140
+++

### 5. Create the predictive scaling policy

{{% notice info %}}
A core assumption of predictive scaling is that the Auto Scaling group is homogenous and all instances are of equal capacity. If this isn’t true for your group, forecasted capacity can be inaccurate. 
{{% /notice %}}
```bash
aws autoscaling put-scaling-policy --policy-name workshop-predictive-scaling-policy \
  --auto-scaling-group-name "ec2-workshop-asg" --policy-type PredictiveScaling \
  --predictive-scaling-configuration file://policy-config.json
```

{{% notice note %}}
To edit a predictive scaling policy that uses customized metrics, you must use the AWS CLI or an SDK. Console support for customized metrics will be available soon.
{{% /notice %}}

```bash
aws autoscaling get-predictive-scaling-forecast --auto-scaling-group-name "ec2-workshop-asg" \
    --policy-name workshop-predictive-scaling-policy \
    --start-time "2021-09-12T00:00:00Z" \
    --end-time "2021-09-13T23:00:00Z"
```


Verify scaling has been created, get predictive scaling policy

```bash
aws autoscaling describe-policies \
    --auto-scaling-group-name 'ec2-workshop-asg'
```
### 6. Verify predictive scaling policy in AWS Console