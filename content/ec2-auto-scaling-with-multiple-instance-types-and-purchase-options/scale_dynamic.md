+++
title = "Using Dynamic Scaling in ASG"
weight = 140
+++

When you configure dynamic scaling, you must define how to scale in response to changing demand. For example, you have a web application that currently runs on two instances and you do not want the CPU utilization of the Auto Scaling group to exceed 70 percent. You can configure your Auto Scaling group to scale automatically to meet this need. The policy type determines how the scaling action is performed.

Target tracking scaling policies simplify how you configure dynamic scaling. You select a predefined metric or configure a customized metric, and set a target value. Amazon EC2 Auto Scaling creates and manages the CloudWatch alarms that trigger the scaling policy and calculates the scaling adjustment based on the metric and the target value. The scaling policy adds or removes capacity as required to keep the metric at, or close to, the specified target value. In addition to keeping the metric close to the target value, a target tracking scaling policy also adjusts to the fluctuations in the metric due to a fluctuating load pattern and minimizes rapid fluctuations in the capacity of the Auto Scaling group.

1. Review **asg-automatic-scaling.json** to understand the options. There are no changes to be made. Then go ahead and apply the scaling policy:

	```
	aws autoscaling put-scaling-policy --cli-input-json file://asg-automatic-scaling.json
	```

1. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created scaling policy in the **Scaling Policies** tab. Notice that in 10-15 minutes, it will begin to scale down the instances that were previously scaled up by the scheduled scaling action in order to satisfy the target tracking metrics defined in the automatic scaling policy (check the **Activity History** tab and the **Instances** tab).