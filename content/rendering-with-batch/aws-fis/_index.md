---
title: "AWS Fault Injection Simulator"
date: 2022-09-20T00:00:00Z
weight: 150
---

## Overview

[AWS Fault Injection Simulator (AWS FIS)](https://aws.amazon.com/fis/) is a fully managed service for running fault injection experiments on AWS that makes it easier to improve an application’s performance, observability, and resiliency. Fault injection experiments are used in chaos engineering, which is the practice of stressing an application in testing or production environments by creating disruptive events, such as sudden increase in CPU or memory consumption, observing how the system responds, and implementing improvements.

In this section you will use AWS FIS to run a fault injection experiment in the ECS cluster associated to the AWS Batch Spot compute environment.

## Features

 - **Simple setup**: AWS Fault Injection Simulator supports best practice chaos engineering parameters to make it easy to get started building and running fault injection experiments, without needing to install any agents. Fully managed fault injection actions are used to define actions such as stopping an instance.

 - **Run real-world scenarios**: simplistic scenarios can be insufficient to create the real-world conditions that cause failure so AWS Fault Injection Simulator supports gradually and simultaneously impairing performance of different types of resources, APIs, services, and geographic locations.

 - **Fine grained safety controls**: when running experiments in live environments, there’s a risk of unintended impact. To provide guardrails and keep your fault injection experiments under control, AWS Fault Injection Simulator allow you to target based on environments, application, and other dimensions using tags.

 - **Integrated security model**: AWS Fault Injection Simulator is integrated with AWS Identity and Access Management (IAM) so that you can control which users and resources have permission to access and run Fault Injection Simulator experiments, and which resources and services can be affected.

 - **Visibility throughout an experiment**: AWS Fault Injection Simulator provides visibility throughout every stage of an experiment via the console and APIs.

 - **Console and programmatic access**: You can use AWS Fault Injection Simulator with the AWS Management Console, AWS CLI, and AWS SDKs.

 You can find [the list of features here](https://aws.amazon.com/fis/features/) and [a list of fault injection actions here](https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html#fis-actions-reference-fis).

 ## Working with AWS FIS
 
 {{% children %}}