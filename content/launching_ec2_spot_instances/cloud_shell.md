---
title: "Configuring AWS CloudShell"
date: 2021-07-07T08:51:33Z
weight: 30
pre: "<b>⁃ </b>"
---

## Configuring AWS CloudShell

AWS CloudShell is a browser-based shell that makes it easy to securely manage, explore, and interact with your AWS resources. You can access CloudShell from the console, in the same way that you access other AWS services. Additionally, you will find a shortcut in the top navigation bar, to the right of the search bar (highlighted in green in the image). You can as well type *CloudShell* in the search bar and it will appear in the search results panel.

Before entering the service it is important that you pay attention to the region you have selected. In the image is highlighted in red where you can consult this information. All the resources that you create throughout the workshop, will be deployed in the region that you select there.

![How to access CloudShell](/images/launching_ec2_spot_instances/CloudShell.png)

The purpose of this workshop is for you to learn how to deploy EC2 instances through different mechanisms in a programmatic manner, starting from a Launch Template (in the next section you will learn more about them).
Although the environment in which this workshop is run is AWS CloudShell, all the API calls you are going to make can be reproduced in other programming languages or SDKs obtaining the same results.
