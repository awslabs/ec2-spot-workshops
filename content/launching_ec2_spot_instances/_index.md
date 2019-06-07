---
title: "Launching EC2 Spot Instances"
date: 2019-01-31T08:51:33Z
weight: 20
pre: "<b>⁃ </b>"
---

## Overview

Amazon EC2 Spot instances are spare compute capacity in the AWS Cloud
available to you at steep discounts compared to On-Demand prices. EC2
Spot enables you to optimize your costs on the AWS cloud and scale your
application’s throughput up to 10X for the same budget.

This lab will walk you through creating an EC2 Launch Template, and then
using this Launch Template to launch EC2 Spot Instances the following 4
ways: Amazon EC2 Auto Scaling, the EC2 RunInstances API, EC2 Spot Fleet, and 
EC2 Fleet.


## Pre-Requisites

This lab requires:

 - A laptop with Wi-Fi running Microsoft Windows, Mac OS X, or Linux.
 - The AWS CLI installed and configured.
 - An Internet browser such as Chrome, Firefox, Safari, or Edge.
 - An AWS account. You will create AWS resources including IAM roles during the workshop.