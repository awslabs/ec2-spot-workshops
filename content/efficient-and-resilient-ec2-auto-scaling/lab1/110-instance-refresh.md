+++
title = "Instance Refresh and Rollback"
weight = 210
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


**Instance refresh** allows you to programmatically update your instances in your Auto Scaling Group instead of manually replacing instances. You can use instance refresh to update to a new Amazon Machine Image (AMI), a new user data script, a new launch template, or new version of your launch template. Once started, an instance refresh will proceed to replace the instances in your Auto Scaling Group in batches according to parameters you define. If configured appropriately, it is also possible to rollback an in-progress instance refresh to the previous configuration.

For this section, you have been tasked with updating the instances in your Auto Scaling Group to larger instances with zero workload downtime while being sensitive to cost (so no full blue/green strategies). You decide instance refresh enables exactly the kind of rolling update you need while also allowing you to monitor the progress and cancel or rollback the changes.

#### Prep

While instance refresh will work with active scaling, to simplify our steps we are going to ensure our Auto Scaling Group does not scale out or in during this part. While we have already set our predictive scaling to forecast only, we need to disable the scale-in on our target tracking policy. Then we'll scale up our Auto Scaling Group to 5 instances so we can see the instance refresh occur.

1. In your **Cloud9** IDE terminal, run this command to create a config file that we will use to disable the scale-in on our target tracking policy (note that DisableScaleIn is set to true).

    ```
    cat <<EoF > asg-no-scale-in.json
    {
        "AutoScalingGroupName": "ec2-workshop-asg",
        "PolicyName": "automaticScaling",
        "PolicyType": "TargetTrackingScaling",
        "EstimatedInstanceWarmup": 300,
        "TargetTrackingConfiguration": {
            "PredefinedMetricSpecification": {
                "PredefinedMetricType": "ASGAverageCPUUtilization"
            },
            "TargetValue": 75,
            "DisableScaleIn": true
        }
    }
    EoF
    ```

2. Then apply the change:

    ```
    aws autoscaling put-scaling-policy --cli-input-json file://asg-no-scale-in.json
    ```

3. Set the desired capacity of your Auto Scaling Group to 5:

    ```
    aws autoscaling set-desired-capacity --auto-scaling-group-name "ec2-workshop-asg" --desired-capacity 5
    ```

It will take a few minutes for the new instances to reach an InService state. You can view the progress in the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details).

#### Configure and run an instance refresh

To run an instance refresh, you define a desired configuration to replace instances with. You will create a new version of the existing launch template being used by your Auto Scaling Group and change the instance type from t3.micro to t3.small. This way you can easily see the change happening in the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details). In order to enable instance refresh rollback (something we will do in a bit), the launch template can't use SSM to define the AMI, so we'll need to make that change for our desired configuration here as well.

1. Get the AMI ID that we are using through SSM and store it in an environment variable.

    ```
    export ami_id=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 'Parameters[0].Value' --output text)
    ```

2. Then create a new launch template version from the default (version 1) with a larger instance type and our AMI ID.

    ```
    aws ec2 create-launch-template-version --launch-template-name EC2WorkshopLaunchTemplate --source-version 1 --launch-template-data ImageId=$ami_id,InstanceType=t3.small
    ```

    If successful you should get back a response that looks something like this:
    ```
    {
        "LaunchTemplateVersion": {
            "LaunchTemplateId": "lt-010140c6a224a6bb2",
            "LaunchTemplateName": "EC2WorkshopLaunchTemplate",
            "VersionNumber": 2,
            "CreateTime": "2023-04-27T19:52:47+00:00",
            "CreatedBy": "arn:aws:sts::073564150117:assumed-role/Admin/rmccone-Isengard",
            "DefaultVersion": false,
            "LaunchTemplateData": {
                "IamInstanceProfile": {
                "Arn": "arn:aws:iam::073564150117:instance-profile/asg-workshop-InstanceProfile-OE6P43eUSw0m"
            },
            "ImageId": "resolve:ssm:/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2",
            "InstanceType": "t3.small",
            ...
            }
        }
    }
    ```

3. Start the instance refresh updating our instances to version 2 of our launch template. Expect the instance refresh to take 10 to 15 minutes to complete.

    ```
    aws autoscaling start-instance-refresh --auto-scaling-group-name "ec2-workshop-asg" 
    --preferences MinHealthyPercentage=60,StandbyInstances=Terminate 
    --desired-configuration '{"LaunchTemplate":{"LaunchTemplateName":"EC2WorkshopLaunchTemplate","Version":"2"}}'
    ```

    You can monitor the progress of your instance refresh by calling **describe-instance-refresh**:
    ```
    aws autoscaling describe-instance-refreshes --auto-scaling-group-name "ec2-workshop-asg"
    ```
    Or by going to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details), clicking into your Auto Scaling Group (**ec2-workshop-asg**), and clicking on the **Instance refresh** tab.

    ![instance-refresh](/images/efficient-and-resilient-ec2-auto-scaling/instance-refresh-console-progress.png)

{{% notice info %}}
**MinHealthyPercentage** is the minimum number of healthy instances in your Auto Scaling Group. Setting this value tells instance refresh how many instances it can terminate and replace at the same time. For example, our ASG has 5 instances and we are setting **MinHealthyPercentage** to 60, so 40% can be replaced at once, which is 2 instances. If our ASG had 10 instances, then the same **MinHealthyPercentage** would mean 4 instances would be replaced at once.
{{% /notice %}}

#### Questions
What would happen if you set the **MinHealthyPercentage** to 0?
{{% expand "Show answer" %}}
Every instance in your ASG would get terminated and replaced at the same time.
{{% /expand %}}

What would happen if you set the **MinHealthyPercentage** to 100?
{{% expand "Show answer" %}}
Instance refresh would terminate and replace instances one at a time.
{{% /expand %}}

#### Instance refresh rollback

Once your instance refresh has completed, let's prepare to do another one which we will interrupt by initiating a rollback. A rollback will cause the Auto Scaling Group to stop its in-progress instance refresh and revert changes back to the previous configuration.

1. Create a new launch template version to update to, we'll change the instance type again, this time back to t3.micro.

    ```
    aws ec2 create-launch-template-version --launch-template-name EC2WorkshopLaunchTemplate --source-version 2 --launch-template-data InstanceType=t3.micro
    ```
2. Start a new instance refresh. Notice we are setting **AutoRollback** to true, so if our instance refresh were to fail on its own (e.g. by going below the **MinHealthyPercentage** we've set due to instances failing health checks) then the instance refresh would automatically cancel and rollback itself.

    ```
    aws autoscaling start-instance-refresh --auto-scaling-group-name "ec2-workshop-asg" 
    --preferences MinHealthyPercentage=60,StandbyInstances=Terminate,AutoRollback=true 
    --desired-configuration '{"LaunchTemplate":{"LaunchTemplateName":"EC2WorkshopLaunchTemplate","Version":"3"}}'
    ```
3. Give it a few minutes for the instance refresh to start, then initiate the rollback.

    ```
    aws autoscaling rollback-instance-refresh --auto-scaling-group-name "ec2-workshop-asg"
    ```

    You can monitor the progress of your rollback by going to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details), clicking into your Auto Scaling Group (**ec2-workshop-asg**), and clicking on the **Instance refresh** tab.

    ![instance-refresh-rollback](/images/efficient-and-resilient-ec2-auto-scaling/instance-refresh-rollback-console.png)

#### Optional

At the beginning of an earlier activity, you paused the predictive scaling policy. **Let's turn it back on.**
1. In AWS Console window, navigate to [EC2 Auto Scaling](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details).
2. Click on tab **Automatic scaling**, find policy `workshop-predictive-scaling-policy` and turn on toggle **Scaling based on forecast**.
3. Click **Yes, turn on scaling** in the confirmation message.

And for this activity you disabled scale in on the target tracking policy. **Let's re-enable it.**

```
aws autoscaling put-scaling-policy --cli-input-json file://asg-automatic-scaling.json
```

Manually scale down your Auto Scaling Group back to 2 desired instances.

```
aws autoscaling set-desired-capacity --auto-scaling-group-name "ec2-workshop-asg" --desired-capacity 2
```

{{% notice info %}}
If the current time is close to the head of the hour, you can wait till 5 minutes to the hour to see both predictive scaling and warm pools in action as the Auto Scaling starts the scaling out activities.
{{% /notice %}}

At this stage, **you have successfully completed all tasks** you've been asked to do. **Great work!** One more step before you finish, proceed to next page...