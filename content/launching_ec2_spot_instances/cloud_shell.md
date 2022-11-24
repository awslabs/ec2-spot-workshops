---
title: "Starting the workshop"
date: 2021-07-07T08:51:33Z
weight: 10
---

To provision AWS resources in a programmatic manner you run AWS Command Line Interface (CLI) commands in [AWS CloudShell](https://aws.amazon.com/cloudshell/). All the CLI commands you are going to run can be reproduced using CloudFormation, AWS SDKs, and Terraform.

### AWS CloudShell

AWS CloudShell is a browser-based shell console that makes it easy to securely manage, explore, and interact with your AWS resources.
To launch CloudShell click on the shortcut available in the top navigation bar (highlighted in green in below image), or simply click on this [AWS CloudShell console](https://console.aws.amazon.com/cloudshell) link. 

{{% notice note %}}
You can use the example below to find out which is the region you are currently connected to (region is highlighted in red). All the resources that you create throughout the workshop are deployed in the selected region.
{{% /notice %}}

![How to access CloudShell](/images/launching_ec2_spot_instances/CloudShell.png)