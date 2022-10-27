---
title: "AWS CloudShell"
date: 2021-07-07T08:51:33Z
weight: 40
---

## AWS CloudShell

In this workshop we will use the AWS Command Line Interface (CLI). We will run our commands into the AWS CloudShell console. AWS CloudShell is a browser-based shell console that makes it easy to securely manage, explore, and interact with your AWS resources. You can access CloudShell from AWS Web Console, in the same way that you access other AWS services. You will find a shortcut in the top navigation bar, to the right of the search bar (highlighted in green in the image). You can as well type *CloudShell* in the search bar and it will appear in the search results panel.

Before starting the workshop checkout and confirm the region that you are running is the right one. If you are running at an AWS event, you will be guided to the right region. 

You can use the example below where the region is highlighted in red, to find out which is the region you are currently connected to. All the resources that you create throughout the workshop, will be deployed in the region that you select there.

{{% notice note %}}
The purpose of this workshop is for you to learn how to deploy EC2 Spot instances with different mechanisms in a programmatic manner, starting from a Launch Template (in the next section you will learn more about them). Although the environment in which this workshop is run is AWS CloudShell, all the API calls you are going to make can be reproduced in other programming languages or SDKs, and even CloudFormation or Terraform, obtaining the same results.
{{% /notice %}}

![How to access CloudShell](/images/launching_ec2_spot_instances/CloudShell.png)
