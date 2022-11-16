+++
title = "Enable Warm Pools"
weight = 190
+++

### Enable Warm Pools for the Auto Scaling Group

Let's add a Warm Pool to our Auto Scaling group so we can pre-initialize our instances so that they can be brought into service more rapidly.

**Step 1: Put Warm Pool Configuration**

We can add a Warm Pool to our Auto Scaling group with a PutWarmPool API call. We will keep our Warm Pool instances in a stopped state after they have completed their initialization actions. We will omit the optional Warm Pool sizing parameters (--min-size and --max-group-prepared-capacity) meaning our Warm Pool will have a minimum size of 0 and a maximum repared capacity equal to the max size of the Auto Scaling group. The maximum prepared capacity will include instances launched into the Auto Scaling group, and instances launched into the Warm Pool. If you deployed one of the example Auto Scaling groups, this will be set to 2 as a default.

```bash
aws autoscaling put-warm-pool --auto-scaling-group-name "ec2-workshop-asg" --pool-state Stopped
```

**Step 2: Describe Warm Pool Configuration**

By using a DescribeWarmPool API call, we can now see that one instance was launched into our Warm Pool. This is because our Warm Pool's maximum prepared capacity is equal to the Auto Scaling group max size. Since we have one instance already in service, only one additional instance was launched into the Warm Pool to equal the maximum prepared capacity of 2.

```bash
aws autoscaling describe-warm-pool --auto-scaling-group-name "ec2-workshop-asg"
```

When an instance is launched into a Warm Pool it will transition through lifecycle states, with Warmed:Pending.

```
{
    "WarmPoolConfiguration": {
        "MinSize": 0,
        "PoolState": "Stopped"
    },
    "Instances": [
        {
            "InstanceId": "i-0ea10fdc59a07df6e",
            "InstanceType": "t2.micro",
            "AvailabilityZone": "us-west-2a",
            "LifecycleState": "Warmed:Pending",
            "HealthStatus": "Healthy",
            "LaunchTemplate": {
                "LaunchTemplateId": "lt-0356f1c452b0eb0eb",
                "LaunchTemplateName": "LaunchTemplate_O7hvkiPu9hmf",
                "Version": "1"
            }
        }
    ]
}
```

If a lifecycle hook is configured, the instance can wait in a Warmed:Pending:Wait state until initialization actions are completed.

```
{
    "WarmPoolConfiguration": {
        "MinSize": 0,
        "PoolState": "Stopped"
    },
    "Instances": [
        {
            "InstanceId": "i-0ea10fdc59a07df6e",
            "InstanceType": "t2.micro",
            "AvailabilityZone": "us-west-2a",
            "LifecycleState": "Warmed:Pending:Wait",
            "HealthStatus": "Healthy",
            "LaunchTemplate": {
                "LaunchTemplateId": "lt-0356f1c452b0eb0eb",
                "LaunchTemplateName": "LaunchTemplate_O7hvkiPu9hmf",
                "Version": "1"
            }
        }
    ]
}
```
After initialization actions are completed, and the lifecycle hook is sent a CONTINUE signal, the instance will move to a Warmed:Pending:Proceed state.
```
{
    "WarmPoolConfiguration": {
        "MinSize": 0,
        "PoolState": "Stopped"
    },
    "Instances": [
        {
            "InstanceId": "i-0ea10fdc59a07df6e",
            "InstanceType": "t2.micro",
            "AvailabilityZone": "us-west-2a",
            "LifecycleState": "Warmed:Pending:Proceed",
            "HealthStatus": "Healthy",
            "LaunchTemplate": {
                "LaunchTemplateId": "lt-0356f1c452b0eb0eb",
                "LaunchTemplateName": "LaunchTemplate_O7hvkiPu9hmf",
                "Version": "1"
            }
        }
    ]
}
```

Since we configured instances in our Warm Pool to be stopped after initialization, the instance launch will complete with the instance in a Warmed:Stopped state. The instance is now pre-initialized and ready to be launched into the Auto Scaling group as additional capacity is needed.

```
{
    "WarmPoolConfiguration": {
        "MinSize": 0,
        "PoolState": "Stopped"
    },
    "Instances": [
        {
            "InstanceId": "i-0ea10fdc59a07df6e",
            "InstanceType": "t2.micro",
            "AvailabilityZone": "us-west-2a",
            "LifecycleState": "Warmed:Stopped",
            "HealthStatus": "Healthy",
            "LaunchTemplate": {
                "LaunchTemplateId": "lt-0356f1c452b0eb0eb",
                "LaunchTemplateName": "LaunchTemplate_O7hvkiPu9hmf",
                "Version": "1"
            }
        }
    ]
}
```

**Observe Launch Speed into Warm Pool**

Now let's see how long it took to launch the instance into the Warm Pool.

```bash
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "ec2-workshop-asg")
for row in $(echo "${activities}" | jq -r '.Activities[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

   start_time=$(date -d "$(_jq '.StartTime')" "+%s")
   end_time=$(date -d "$(_jq '.EndTime')" "+%s")
   activity=$(_jq '.Description')

   echo $activity Duration: $(($end_time - $start_time))"s"
done
```

As you can see from the following results, launching an instance into a Warm Pool took a similar length of time to launching an instance directly into the Auto Scaling group.

```
Launching a new EC2 instance into warm pool: i-0ea10fdc59a07df6e Duration: 260s
```