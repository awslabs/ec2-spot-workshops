+++
title = "Launch From Warm Pool"
weight = 200
+++

### Measure the Launch Speed of Instances Launched From Warm Pool into an Auto Scaling group

Now that we have pre-initialized instance in the Warm Pool, we can scale our Auto Scaling group and launch the pre-initialized instance rather than launching a new instance that has not been pre-initialized.

**Step 1: Increase Desired Capacity**

Let's increase the desired capacity of our Auto Scaling group to 2.

```bash
aws autoscaling set-desired-capacity --auto-scaling-group-name "ec2-workshop-asg" --desired-capacity 2
```

**Step 2: Observe Warm Pool Change**

Now, let's describe our Warm Pool and observe any changes. As you can see below, the instance we previously launched is no longer in our Warm Pool. This is beause it was launched from the Warm Pool, into the Auto Scaling group in response to our increase in desired capacity.

```bash
aws autoscaling describe-warm-pool --auto-scaling-group-name "ec2-workshop-asg"
```

```
{
    "WarmPoolConfiguration": {
        "MinSize": 0,
        "PoolState": "Stopped"
    },
    "Instances": []
}
```

**Step 3: Measure Launch Speed**

We can now measure the launch speed of the instance from the Warm Pool to the Auto Scaling group.

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

As you can see from the following results, because our instance was pre-initialized our launch was duration was significantly reduced. This means we can now more rapidly place instances into service in response to load placed on our workload by launching pre-initialized instances from the Warm Pool.

```
Launching a new EC2 instance from warm pool: i-0ea10fdc59a07df6e Duration: 36s
```