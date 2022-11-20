+++
title = "Measure the Launch Speed of Instances"
weight = 180
+++


### Measure the Launch Speed of Instances Launched Directly into an Auto Scaling Group

In this step we will launch an instance directly into an Auto Scaling group. The Auto Scaling group we created `ec2-workshop-asg` uses lifecycle hooks to manage the application installation process. Using userdata script configured in the launch template that execute on the instance when the instance first boots, and every time the instance starts. This script installs and starts the application. Once the application is installed, a command is executed to complete the lifecycle action and allow the instance to transition to the next lifecycle step.

You can also use a Lambda function that executes in response to Amazon EventBridge events that are generated as instances transition through their lifecycle.

#### Before we get started with the next activity

We need to ensure it won't be interrupted by the auto scaling of the policies we created. Therefore, we will pause the predictive scaling and reset desired capacity to 0, incase there were any instances added.

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

Now, let's measure the launch speed of the instance. You will need to wait a few minutes for the instance to be launched by the previous step.

```bash
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "ec2-workshop-asg" | jq -r '.Activities[0]') && \
start_time=$(date -d "$(echo $activities | jq -r '.StartTime')" "+%s") && \
end_time=$(date -d "$(echo $activities | jq -r '.EndTime')" "+%s") && \
activity=$(echo $activities | jq -r '.Description') && \
echo $activity Duration: $(($end_time - $start_time))"s" || echo "Current activity is still in progress.."
```

#### Observe Launch Duration

Because the instance launched directly into the Auto Scaling group, all initialization actions needed to complete to prepare the instance to be placed in-service. From the results below we can see that these actions took a long time to complete, delaying how quickly our Auto Scaling group can scale.

```
Launching a new EC2 instance: i-075fa0ad6a018cdfc Duration: 243s
```