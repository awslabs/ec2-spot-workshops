---
title: "Running Efficient and Resilient Workloads with Amazon EC2 Auto Scaling"
menuTitle: "Efficient EC2 Auto Scaling"
weight: 110
pre: "<b>11. </b>"
---

## Overview

Welcome! This workshop is designed to get you familiar with the concepts and best practices for effectively and efficiently scaling [Amazon EC2](https://aws.amazon.com/ec2/) capacity using [Amazon EC2 Auto Scaling](https://aws.amazon.com/ec2/autoscaling/) and it's features including [predictive scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html) and [warm pools](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html).

In this workshop you assume the role of a Cloud Architect tasked to find an efficient Auto Scaling solution for a sample application. You have been provided with monolithic application which receives cyclical traffic, such as high use of resources during regular business hours and low use of resources during evenings and weekends. The application takes a long time (over 10 minutes) to initialize, causing a noticeable latency impact on application performance during scale-out events. You go through the hands-on labs to find an efficient Auto Scaling solution that ensures the application is **ready in minimal time** and scales faster by **launching capacity in advance of forecasted load** without the need to overprovision capacity.

## Estimated time and cost to run this workshop
The estimated time for completing the workshop is 60-90 minutes and cost of running this workshop is less than $5 USD.

## Prerequisites 
This is L400 workshop, we expect readers to be already familiar with basics of [Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html), [Amazon EC2 Auto Scaling groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html) and [AWS CloudWatch metrics for EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html).
