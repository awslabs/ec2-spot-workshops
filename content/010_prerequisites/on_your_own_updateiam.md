---
title: "...ON YOUR OWN - Updating Workspace Cloud9 Instance"
chapter: false
disableToc: true
hidden: true
---

## Create an IAM role for your Workspace

1. Follow this [deep link to create an IAM role with Administrator access](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess).
1. Confirm that **AWS service** and **EC2** are selected, then click **Next: Permisssions** to view permissions.
1. Confirm that **AdministratorAccess** is checked, then click **Next: Tags** to assign tags.
1. Take the defaults, and click **Next: Review** to review.
1. Enter **eksworkshop-admin** for the Name, and click **Create role**.
![createrole](/images/prerequisites/createrole.png)

## Attach the IAM role to your Workspace

1. Click the grey circle button (in top right corner) and select **Manage EC2 Instance**.
![cloud9Role](/images/prerequisites/cloud9-role.png)
1. Select the instance, then choose **Actions / Security / Modify IAM role**
![c9instancerole](/images/prerequisites/c9instancerole.png)
1. Choose **eksworkshop-admin** from the **IAM role** drop down, and select **Save**
![c9attachrole](/images/prerequisites/c9attachrole.png)