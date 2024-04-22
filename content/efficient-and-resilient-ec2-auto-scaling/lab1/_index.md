---
title: "Amazon EC2 Auto Scaling"
menuTitle: "Amazon EC2 Auto Scaling"
weight: 20
# pre: "<b>Lab 1: </b>"
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}

**Amazon EC2 Auto Scaling** helps you maintain application availability and allows you to dynamically scale your Amazon EC2 capacity up or down automatically according to conditions you define. You can use Amazon EC2 Auto Scaling for fleet management of EC2 instances to help maintain the health and availability of your fleet and ensure that you are running your desired number of Amazon EC2 instances. about Amazon EC2 Auto Scaling and the several ways to configure scaling policies for your application.

You have decided to leverage EC2 Auto Scaling to scale your application efficiently. To start, you create an EC2 Auto Scaling group without any Auto Scaling policies. 

1. In **Cloud9** IDE terminal, check you're at this directory `ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling`. 
2. You create an Auto Scaling group using **asg.json** configuration file, open the file to review the configuration.
    ```bash
    cat ./asg.json
    ```
3. Create the auto scaling group using below command. This command does not return any output if it is successful.
    ```bash
    aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
    ```
4. Then run this command to enable CloudWatch metrics collection for the Auto Scaling group, which will help you in monitoring the capacity in the group.
   ```bash
   aws autoscaling enable-metrics-collection \
    --auto-scaling-group-name ec2-workshop-asg \
    --granularity "1Minute"
    ```
5. Browse to the [Auto Scaling console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) and check out your newly created auto scaling group. At this step of the workshop, the auto scaling group will have **no instances running**, as the desired number of instances is set to **0**.

### Challenge 

Do you know different ways to scale the capacity of your Auto Scaling group?

{{% notice tip %}}
Go to [Scale the size of your Auto Scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/scale-your-group.html) documentation page for more information.
{{% /notice %}}

{{% expand "Show answers" %}}
You can scale the capacity of your Auto Scaling group using below scaling policies.

### Manual scaling
At any time, you can change the size of an existing Auto Scaling group manually. You can either update the desired capacity of the Auto Scaling group, or update the instances that are attached to the Auto Scaling group. Manually scaling your group can be useful when automatic scaling is not needed or when you need to hold capacity at a fixed number of instances.

### Dynamic scaling

A dynamic scaling policy instructs Amazon EC2 Auto Scaling to track a specific **CloudWatch** metric, and it defines what action to take when the associated CloudWatch alarm is in ALARM. The metrics that are used to invoke the alarm state are an aggregation of metrics coming from all of the instances in the Auto Scaling group. When the policy is in effect, Amazon EC2 Auto Scaling adjusts the group's desired capacity up or down when the threshold of an alarm is breached.

Dynamic scaling policies are **reactive**. They allow you to track a specific CloudWatch metric and to take an action when the CloudWatch alarm is triggered. **Predictive scaling** policies are used in combination with dynamic scaling policies when your application demand changes rapidly but with a **recurring pattern** or when your application instances require a longer time to initialize.

### Scheduled scaling

Scheduled scaling helps you to set up your own scaling schedule according to predictable load changes. For example, let's say that every week the traffic to your web application starts to increase on Wednesday, remains high on Thursday, and starts to decrease on Friday. You can configure a schedule for Amazon EC2 Auto Scaling to increase capacity on Wednesday and decrease capacity on Friday.

### Predictive scaling
Predictive scaling uses machine learning to predict capacity requirements based on historical data from CloudWatch. The machine learning algorithm consumes the available historical data and calculates capacity that best fits the historical load pattern, and then continuously learns based on new data to make future forecasts more accurate.

{{% /expand %}}