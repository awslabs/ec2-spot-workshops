+++
title = "How Warm Pools work?"
weight = 90
+++

#### Describe warm pool Configuration
You can now see that one instance was launched into your warm pool. This is because your warm's maximum prepared capacity is equal to the Auto Scaling group max size. Since you have one instance already in service, only one additional instance was launched into the warm pool to equal the maximum prepared capacity of 2.

```bash
aws autoscaling describe-warm-pool --auto-scaling-group-name "ec2-workshop-asg"
```

When an instance is launched into a warm pool it will transition through lifecycle states, with Warmed:Pending.

If a lifecycle hook is configured, the instance can wait in a Warmed:Pending:Wait state until initialization actions are completed.

After initialization actions are completed, and the lifecycle hook is sent a CONTINUE signal, the instance will move to a Warmed:Pending:Proceed state.

Since you configured instances in your warm pool to be stopped after initialization, the instance launch will complete with the instance in a Warmed:Stopped state. The instance is now pre-initialized and ready to be launched into the Auto Scaling group as additional capacity is needed.


#### Observe Launch Speed into warm pool

Now let's see how long it took to launch the instance into the warm pool.

```bash
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "ec2-workshop-asg" | jq -r '.Activities[0]') && \
start_time=$(date -d "$(echo $activities | jq -r '.StartTime')" "+%s") && \
end_time=$(date -d "$(echo $activities | jq -r '.EndTime')" "+%s") && \
activity=$(echo $activities | jq -r '.Description') && \
echo $activity Duration: $(($end_time - $start_time))"s" || echo "Current activity is still in progress.."
```

As you can see from the following results, launching an instance into a warm pool took a similar length of time to launching an instance directly into the Auto Scaling group.

```
Launching a new EC2 instance into warm pool: i-0ea10fdc59a07df6e Duration: 260s
```