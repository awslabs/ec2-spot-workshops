---
title: "AWS Fault Injection Simulator"
date: 2022-09-20T00:00:00Z
weight: 150
---

## Overview

[AWS Fault Injection Simulator](https://aws.amazon.com/fis/) is a fully managed service for running fault injection experiments on AWS that makes it easier to improve an application’s performance, observability, and resiliency. Fault injection experiments are used in chaos engineering, which is the practice of stressing an application in testing or production environments by creating disruptive events, such as sudden increase in CPU or memory consumption, observing how the system responds, and implementing improvements.

We are going to use AWS FIS to run a fault injection experiment in the ECS cluster associated to the Spot compute environment.