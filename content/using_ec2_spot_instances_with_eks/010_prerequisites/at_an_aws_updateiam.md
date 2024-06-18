---
title: "...AT AN AWS EVENT - Updating Workspace Cloud9 Instance"
chapter: false
disableToc: true
hidden: true
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

## Attach the IAM role to your Workspace

1. Click the grey circle button (in top right corner) and select **Manage EC2 Instance**.
![cloud9Role](/images/using_ec2_spot_instances_with_eks/prerequisites/cloud9-role.png)
1. Select the instance, then choose **Actions / Security / Modify IAM role**
![c9instancerole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9instancerole.png)
1. Choose **TeamRoleInstance** from the **IAM role** drop down, and select **Save**
![c9attachrole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9attachroleee.png)
