+++
title = "Measure the Launch Speed of Instances"
weight = 70
+++

In this section, you launch an instance directly into an Auto Scaling group. The Auto Scaling group you created `ec2-workshop-asg` uses lifecycle hooks to manage the application installation process. 

As a part of initial set up with CloudFormation, you created a launch template with user data script. This script is executed on the instance during the the boot up, to installs and starts the application. Once the application is installed, another command is executed to complete the lifecycle action and allow the instance to transition to the next lifecycle step.

#### Pausing scaling before next activity

You need to ensure that adding a single instance is not removed by the Auto Scaling policies you created earlier. Therefore, in this step you pause the predictive scaling and reset desired capacity to 0.

1. In AWS Console window, navigate to [EC2 Auto Scaling](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details).
2. Click on tab **Automatic scaling**
3. Under **Predictive scaling policies**, find policy `workshop-predictive-scaling-policy` and turn off toggle **Scaling based on forecast**.
4. Click **Yes, turn of scaling** in the confirmation message.
5. If there are any instances running, then in **Cloud9 IDE** terminal run this command to ensure current capacity sets at 0 instances and **wait two minutes** to get all running instances terminated.
    ```bash
    aws autoscaling set-desired-capacity --auto-scaling-group-name "ec2-workshop-asg" --desired-capacity 0
    ```

#### Increase Desired Capacity

Set the desired capacity of the Auto Scaling group to 1 to launch an instance directly into the Auto Scaling group.

```bash
aws autoscaling set-desired-capacity --auto-scaling-group-name "ec2-workshop-asg" --desired-capacity 1
```

#### Measure Launch Speed

Now, let's measure the launch speed of the instance. You need to wait a few minutes for the instance to be launched by the previous step.

```bash
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "ec2-workshop-asg" | jq -r '.Activities[0]') && \
start_time=$(date -d "$(echo $activities | jq -r '.StartTime')" "+%s") && \
end_time=$(date -d "$(echo $activities | jq -r '.EndTime')" "+%s") && \
activity=$(echo $activities | jq -r '.Description') && \
echo $activity Duration: $(($end_time - $start_time))"s" || echo "Current activity is still in progress.."
```

#### Observe Launch Duration

Because the instance launched directly into the Auto Scaling group, all initialization actions needed to complete to prepare the instance to be placed in-service. From the results below you can see that these actions took a long time to complete, delaying how quickly your Auto Scaling group can scale.

```
Launching a new EC2 instance: i-075fa0ad6a018cdfc Duration: 243s
```



