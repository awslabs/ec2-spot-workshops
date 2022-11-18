+++
title = "Create an EC2 Auto Scaling Group"
weight = 85
+++


1. We will create an Auto Scaling group using a configuration file.
2. You can view **asg.json** on the **Cloud9 IDE** terminal and review the configuration.

    ```bash
    cat ./asg.json
    ```

1. Now create the auto scaling group. This command will not return any output if it is successful.

    ```bash
    aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
    ```

4. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created auto scaling group. At this step of the workshop, the auto scaling group will have **no instances running**, as the desired number of instances is set to **0**.