---
title: "...AT AN AWS EVENT - Updating Workspace Cloud9 Instance"
chapter: false
disableToc: true
hidden: true
---

## Attach the IAM role to your Workspace

1. Click the grey circle button (in top right corner) and select **Manage EC2 Instance**.
![cloud9Role](/images/using_ec2_spot_instances_with_eks/prerequisites/cloud9-role.png)
1. Select the instance, then choose **Actions / Security / Modify IAM role**
![c9instancerole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9instancerole.png)
1. Choose **TeamRoleInstance** from the **IAM role** drop down, and select **Save**
![c9attachrole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9attachroleee.png)
