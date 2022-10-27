+++
title = "Scaling your application faster"
weight = 20
+++

## Warm Pools

A warm pool is a pool of pre-initialized EC2 instances that sits alongside an Auto Scaling group. Whenever your application needs to scale out, gives you the ability to decrease latency for your applications that have exceptionally long boot times.

Three options to set the warm pool size

- Warm pool size is the difference between the number of currently running instances and the maximum capacity.
- Another method to seth the size is by setting the maximum prepared instances, the warm pool size in this case is calculated as  the difference between the maximum prepared and the current desired capacity.
- You can also set the minimum size setting for warm pool to statically set minimum number of instance in the warm pool


You can keep instances in the warm pool in one of three states: Stopped, Running, or Hibernated.
Keeping instances in a Stopped state is an effective way to minimize costs. With stopped instances,
you pay only for the volumes that you use and the Elastic IP addresses attached to the instances.

Lifecycle hooks can be used to put instances in wait state before launch or terminate.

Reusing instances, by default when ASG scales in instances it get terminates but you can configure reuse policy to return instances to warm pool. only available in CLI and CDK.

### Create warm pool
```bash
aws autoscaling put-warm-pool \
    --auto-scaling-group-name workshop-predictive-asg \
    --min-size 2
```

```bash
aws autoscaling describe-warm-pool --auto-scaling-group-name workshop-predictive-asg
```

{{% notice info %}}
**Limitations**:
You cannot add a warm pool to Auto Scaling groups that have a mixed instances policy or that launch Spot Instances.
{{% /notice %}}
