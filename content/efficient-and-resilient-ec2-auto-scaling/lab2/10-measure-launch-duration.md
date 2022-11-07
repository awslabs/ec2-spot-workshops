+++
title = "Measure the Launch Speed of Instances"
weight = 30
+++


### Measure the Launch Speed of Instances Launched Directly into an Auto Scaling Group

With our Auto Scaling group deployed, and CLI utilities installed, we can begin our first activity. In this activity we will launch an instance directly into an Auto Scaling group. The example Auto Scaling groups deployed earlier use lifecycle hooks to manage the application installation process.

The userdata managed example uses a script that execute on the instance when the instance first boots, and every time the instance starts. This script detects if the application is installed, and if not, installs and starts it. If the application is already installed it ensures that it's started. Once the application is installed or started, a command is executed to complete the lifecycle action and allow the instance to transtion to the next lifecycle step.

The lambda managed example uses a Lambda function that executes in response to Amazon EventBridge events that are generated as instances transition through their lifecycle. The Lambda function can perform different actions as the instance is first launched, launched into a warm pool, or started from a warm pool. This allows the Lambda function to perform actions such as installing an application, registering an instance with a primary node, or ensuring that an application is started prior to the instance being moved in-service.

**Step 1: Increase Desired Capacity**

Set the desired capacity of the Auto Scaling group to 1 to launch an instance directly into the Auto Scaling group.

```bash
aws autoscaling set-desired-capacity --auto-scaling-group-name "Example Auto Scaling Group" --desired-capacity 1
```

**Step 2: Measure Launch Speed**

Now, let's measure the launch speed of the instance. You will need to wait a few minutes for the instance to be launched by the previous step.

```bash
activities=$(aws autoscaling describe-scaling-activities --auto-scaling-group-name "Example Auto Scaling Group")
for row in $(echo "${activities}" | jq -r '.Activities[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

   start_time=$(_jq '.StartTime')
   end_time=$(_jq '.EndTime')
   activity=$(_jq '.Description')

   echo $activity Duration: $(datediff $start_time $end_time)
done
```

**Step 3: Observe Launch Duration**

Because the instance launched directly into the Auto Scaling group, all initialization actions needed to complete to prepare the instance to be placed in-service. From the results below we can see that these actions took a long time to complete, delaying how quickly our Auto Scaling group can scale.

```
Launching a new EC2 instance: i-075fa0ad6a018cdfc Duration: 243s
```