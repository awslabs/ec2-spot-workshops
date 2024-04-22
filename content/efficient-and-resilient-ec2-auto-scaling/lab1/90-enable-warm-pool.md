+++
title = "How Warm Pools work?"
weight = 90
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


#### Observe warm pool changes

You can also use AWS CLI to observe changes in the warm pool at any state of the instances lifecycle. Run this command to list all instances with their state in the warm pool now.

```bash
aws autoscaling describe-warm-pool --auto-scaling-group-name "ec2-workshop-asg" | jq -r '.Instances[]| "\(.InstanceId)\t\(.LifecycleState)"'
```

You can see that multiple instances were launched into the warm pool. The number of instances is the difference between the number of current running instances and the Auto Scaling group max capacity. Since you have one instance already in service, (Auto Scaling group max size - 1) additional instances were launched into the warm pool.

```
i-02875409c2488c8d0     Warmed:Stopped
i-0851feaba1df1fcc5     Warmed:Stopped
i-0d3f75c968995f1dc     Warmed:Stopped
i-0e6f840558778cbd4     Warmed:Stopped
```

When an instance is launched into a warm pool it will transition through lifecycle states, with **Warmed:Pending**.

If a **lifecycle hook** is configured, the instance can wait in a **Warmed:Pending:Wait** state until initialization actions are completed.

After initialization actions are completed, and the lifecycle hook is sent a **CONTINUE** signal, the instance will move to a **Warmed:Pending:Proceed** state.

Since you configured instances in your warm pool to be stopped after initialization, the instance launch will complete with the instance in a **Warmed:Stopped** state. The instance is now pre-initialized and ready to be launched into the Auto Scaling group as additional capacity is needed.

![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/warm-pools-scale-out-event-diagram.png)

#### Observe launch speed into warm pool

Now let's see how long it took to launch an instance into the warm pool.

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
