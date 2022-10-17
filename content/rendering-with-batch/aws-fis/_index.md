---
title: "AWS Fault Injection Simulator"
date: 2022-09-20T00:00:00Z
weight: 150
---

## Overview

[AWS Fault Injection Simulator (AWS FIS)](https://aws.amazon.com/fis/) is a fully managed service for running fault injection experiments on AWS that makes it easier to improve an application’s performance, observability, and resiliency. Fault injection experiments are used in chaos engineering, which is the practice of stressing an application in testing or production environments by creating disruptive events, such as sudden increase in CPU or memory consumption, observing how the system responds, and implementing improvements.

This section of the lab will use AWS FIS to run a fault injection experiment in the ECS cluster associated to the AWS Batch Spot compute environment.

## Features

 - Simple setup - AWS Fault Injection Simulator supports best practice chaos engineering parameters to make it easy to get started building and running fault injection experiments, without needing to install any agents. Sample experiments are available to use as a starting point. Fully managed fault injection actions are used to define actions such as stopping an instance, throttling an API, and failing over a database. Fault Injection Simulator supports Amazon CloudWatch so that you can use your existing metrics to monitor Fault Injection Simulator experiments.

 - Run real-world scenarios - Simplistic scenarios can be insufficient to create the real-world conditions that cause failure so AWS Fault Injection Simulator supports gradually and simultaneously impairing performance of different types of resources, APIs, services, and geographic locations. Affected resources can be randomized, and custom fault types can be created using AWS Systems Manager to further increase complexity.

 - Fine grained safety controls - When running experiments in live environments, there’s a risk of unintended impact. To provide guardrails and keep your fault injection experiments under control, AWS Fault Injection Simulator allow you to target based on environments, application, and other dimensions using tags. For example, you could increase CPU utilization on 10% of your instances with the tag “environment”:“prod”. Fault Injection Simulator also has the option to set rules based on Amazon CloudWatch Alarms or other tools to stop an experiment. For example, an experiment can be set to stop before completion if a web page response time decreases below an acceptable level.

 - Integrated security model - AWS Fault Injection Simulator is integrated with AWS Identity and Access Management (IAM) so that you can control which users and resources have permission to access and run Fault Injection Simulator experiments, and which resources and services can be affected.

 - Visibility throughout an experiment - AWS Fault Injection Simulator provides visibility throughout every stage of an experiment via the console and APIs. As an experiment is running you can observe what actions have executed. After an experiment has completed you can see details on what actions were run, if stop conditions were triggered, how metrics compared to your expected steady state, and more. To support accurate operational metrics and effective troubleshooting, you can also identify what resources and APIs are affected by a Fault Injection Simulator experiment.

 - Console and programmatic access - You can use AWS Fault Injection Simulator with the AWS Management Console, AWS CLI, and AWS SDKs. The Fault Injection Simulator APIs allow you to programmatically access the service so that you can integrate fault injection testing into your continuous integration and continuous delivery (or CI/CD) pipeline, and custom tooling.

 You can find a [list of supported fault injections here](https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html#fis-actions-reference-fis).

 ## Working with AWS FIS
 
 {{% children %}}