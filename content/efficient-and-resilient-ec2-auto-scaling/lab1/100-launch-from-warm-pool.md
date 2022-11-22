+++
title = "Launch From Warm Pool"
weight = 200
+++

### Measure the Launch Speed of Instances Launched From warm pool into an Auto Scaling group

Now that you have pre-initialized instances in the warm pool, you can scale your Auto Scaling group and launch a pre-initialized instance rather than launching a new instance that has not been pre-initialized.

#### Increase Desired Capacity

Let's increase the desired capacity of your Auto Scaling group to 2.

```bash
aws autoscaling set-desired-capacity --auto-scaling-group-name "ec2-workshop-asg" --desired-capacity 2
```

#### Observe warm pool Change

Now, let's describe your warm pool and observe any changes. As you can see below, the instance you previously launched is no longer in your warm pool. This is because it was launched from the warm pool, into the Auto Scaling group in response to your increase in desired capacity.

```bash
aws autoscaling describe-warm-pool --auto-scaling-group-name "ec2-workshop-asg"
```

```
{
    "WarmPoolConfiguration": {
        "MinSize": 2,
        "PoolState": "Stopped"
    },
    "Instances": [...]
}
```

#### Measure Launch Speed

You can now measure the launch speed of the instance from the warm pool to the Auto Scaling group.

```bash
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "ec2-workshop-asg" | jq -r '.Activities[0]') && \
start_time=$(date -d "$(echo $activities | jq -r '.StartTime')" "+%s") && \
end_time=$(date -d "$(echo $activities | jq -r '.EndTime')" "+%s") && \
activity=$(echo $activities | jq -r '.Description') && \
echo $activity Duration: $(($end_time - $start_time))"s" || echo "Current activity is still in progress.."
```

As you can see from the following results, because the instance was pre-initialized, the instance launch duration was **significantly reduced**. This means you can now more rapidly place instances into service in response to load placed on your workload by launching pre-initialized instances from the warm pool. Making your application more resilient and responsive to spike demands.

```
Launching a new EC2 instance from warm pool: i-0ea10fdc59a07df6e Duration: 36s
```

Since you have enabled the CloudWatch metrics collection for the Auto Scaling group, **let's compare the capacity metrics before and after enabling warm pools.**

1. Navigate to [Amazon CloudWatch Console](https://console.aws.amazon.com/cloudwatch).
2. From left side navigation, click on **Metrics** then **All metrics**.
3. In the **Browse** tab select **Auto Scaling** under AWS namespaces
4. Select **Group Metrics**, then select these two metrics **GroupDesiredCapacity** and **GroupInServiceCapacity** attached with **ec2-workshop-asg**. This should add the metrics to the graph.
5. Note the difference in time between **DesiredCapacity** and **InServiceCapacity** before and after enabling warm pools

![warm-pool](/images/efficient-and-resilient-ec2-auto-scaling/warm-pool-before.png)
![warm-pool](/images/efficient-and-resilient-ec2-auto-scaling/warm-pool-after.png)