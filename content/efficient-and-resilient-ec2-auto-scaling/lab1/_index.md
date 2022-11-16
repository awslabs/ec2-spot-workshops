---
title: "Amazon EC2 Auto Scaling"
menuTitle: "Amazon EC2 Auto Scaling"
weight: 80
# pre: "<b>Lab 1: </b>"
---

Let's start by learning more about Amazon EC2 Auto Scaling and the several ways to scale your application.

## What is Amazon EC2 Auto Scaling?

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 instances available to handle the load for your application.


## Manual scaling
At any time, you can change the size of an existing Auto Scaling group manually. You can either update the desired capacity of the Auto Scaling group, or update the instances that are attached to the Auto Scaling group. Manually scaling your group can be useful when automatic scaling is not needed or when you need to hold capacity at a fixed number of instances.

## Dynamic scaling

A **dynamic scaling** policy instructs Amazon EC2 Auto Scaling to track a specific **CloudWatch** metric, and it defines what action to take when the associated CloudWatch alarm is in ALARM. The metrics that are used to invoke the alarm state are an aggregation of metrics coming from all of the instances in the Auto Scaling group. When the policy is in effect, Amazon EC2 Auto Scaling adjusts the group's desired capacity up or down when the threshold of an alarm is breached.

{{% notice note %}}
**Dynamic scaling** policies are **reactive**. They allow you to track a specific CloudWatch metric and to take an action when the CloudWatch alarm is triggered. **Predictive scaling** policies are used in combination with dynamic scaling policies when your application demand changes rapidly but with a **recurring pattern** or when your application instances require a longer time to initialize.
{{% /notice %}}

## Scheduled scaling

Scheduled scaling helps you to set up your own scaling schedule according to predictable load changes. For example, let's say that every week the traffic to your web application starts to increase on Wednesday, remains high on Thursday, and starts to decrease on Friday. You can configure a schedule for Amazon EC2 Auto Scaling to increase capacity on Wednesday and decrease capacity on Friday.


## Predictive scaling

This will be our main focus for this lab, let's get started...