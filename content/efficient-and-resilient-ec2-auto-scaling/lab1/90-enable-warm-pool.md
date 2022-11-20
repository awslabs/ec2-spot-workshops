+++
title = "How Warm Pools work?"
weight = 190
+++

#### Describe Warm Pool Configuration

we can now see that one instance was launched into our Warm Pool. This is because our Warm Pool's maximum prepared capacity is equal to the Auto Scaling group max size. Since we have one instance already in service, only one additional instance was launched into the Warm Pool to equal the maximum prepared capacity of 2.

```bash
aws autoscaling describe-warm-pool --auto-scaling-group-name "ec2-workshop-asg"
```

When an instance is launched into a Warm Pool it will transition through lifecycle states, with Warmed:Pending.

If a lifecycle hook is configured, the instance can wait in a Warmed:Pending:Wait state until initialization actions are completed.

After initialization actions are completed, and the lifecycle hook is sent a CONTINUE signal, the instance will move to a Warmed:Pending:Proceed state.

Since we configured instances in our Warm Pool to be stopped after initialization, the instance launch will complete with the instance in a Warmed:Stopped state. The instance is now pre-initialized and ready to be launched into the Auto Scaling group as additional capacity is needed.


#### Observe Launch Speed into Warm Pool

Now let's see how long it took to launch the instance into the Warm Pool.

```bash
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "ec2-workshop-asg" | jq -r '.Activities[0]') && \
start_time=$(date -d "$(echo $activities | jq -r '.StartTime')" "+%s") && \
end_time=$(date -d "$(echo $activities | jq -r '.EndTime')" "+%s") && \
activity=$(echo $activities | jq -r '.Description') && \
echo $activity Duration: $(($end_time - $start_time))"s" || echo "Current activity is still in progress.."
```

As you can see from the following results, launching an instance into a Warm Pool took a similar length of time to launching an instance directly into the Auto Scaling group.

```
Launching a new EC2 instance into warm pool: i-0ea10fdc59a07df6e Duration: 260s
```