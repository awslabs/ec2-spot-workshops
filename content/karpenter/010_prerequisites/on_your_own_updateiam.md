---
title: "...ON YOUR OWN - Updating Workspace Cloud9 Instance"
chapter: false
disableToc: true
hidden: true
---

{{% notice info %}}
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

## Create an IAM role for your Workspace

1. Follow this [deep link to create an IAM role with Administrator access](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess).
1. Confirm that **AWS service** and **EC2** are selected, then click **Next: Permisssions** to view permissions.
1. Confirm that **AdministratorAccess** is checked, then click **Next: Tags** to assign tags.
1. Take the defaults, and click **Next: Review** to review.
1. Enter **eksworkshop-admin** for the Name, and click **Create role**.
![createrole](/images/using_ec2_spot_instances_with_eks/prerequisites/createrole.png)

## Attach the IAM role to your Workspace

1. Click the grey circle button (in top right corner) and select **Manage EC2 Instance**.
![cloud9Role](/images/using_ec2_spot_instances_with_eks/prerequisites/cloud9-role.png)
1. Select the instance, then choose **Actions / Security / Modify IAM role**
![c9instancerole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9instancerole.png)
1. Choose **eksworkshop-admin** from the **IAM role** drop down, and select **Save**
![c9attachrole](/images/using_ec2_spot_instances_with_eks/prerequisites/c9attachrole.png)