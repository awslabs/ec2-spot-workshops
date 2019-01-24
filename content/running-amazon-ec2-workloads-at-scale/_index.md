---
title: "Running Amazon EC2 Workloads at Scale"
date: 2019-01-24T09:05:54Z
---

## Overview 
This workshop is designed to get you familiar with the concepts and best practices for requesting Amazon EC2 capacity at scale in a cost optimized architecture.

## Setting
You've been tasked with deploying a next-generation music streaming service. You do extensive research, and determine that [Koel](https://koel.phanan.net/)- a personal music streaming server (*that works)- is the perfect fit.

Requirements include the ability to automatically deploy and scale the service for both predictable and dynamic traffic patterns, all without breaking the budget.

In order to optimize performance and cost, you will use Amazon EC2 Auto Scaling to [scale across multiple instance types and purchase options](https://aws.amazon.com/blogs/aws/new-ec2-auto-scaling-groups-with-multiple-instance-types-purchase-options/).

## Requirements, notes, and legal
1\. To complete this workshop, have access to an AWS account with administrative permissions. An IAM user with administrator access (**arn:aws:iam::aws:policy/AdministratorAccess**) will do nicely.

2\. __This workshop is self-paced__. The instructions will primarily be given using the [AWS Command Line Interface (CLI)](https://aws.amazon.com/cli) - this way the guide will not become outdated as changes or updates are made to the AWS Management Console. However, most steps in the workshop can be done in the AWS Management Console directly. Feel free to use whatever is comfortable for you.

3\. While the workshop provides step by step instructions, please do take a moment to look around and understand what is happening at each step. The workshop is meant as a getting started guide, but you will learn the most by digesting each of the steps and thinking about how they would apply in your own environment. You might even consider experimenting with the steps to challenge yourself.

4\. This workshop has been designed to run in any public AWS Region that supports AWS Cloud9. See [Regional Products and Services](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) for details.

5\. During this workshop, you will install software (and dependencies) on the Amazon EC2 instances launched in your account. The software packages and/or sources you will install will be from the [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/) distribution as well as from third party repositories and sites. Please review and decide your comfort with installing these before continuing.
