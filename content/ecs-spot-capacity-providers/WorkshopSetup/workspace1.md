---
title: "Setup Cloud9 Environment"
weight: 6
---


If you are running the workshop on your own, the Cloud9 workspace should be built by an IAM user with Administrator privileges, not the root account user. Please ensure you are logged in as an IAM user.

We will open the Cloud9 environment first to execute all the commands needed for this workshop.

1. Login into AWS console with your account credentials and choose the region where you deployed the CloudFormation template.
1. Select **Services** and type **Cloud9**
1. Click on  **Your environments**
1. Select the Cloud9 environment with the name **EcsSpotWorkshop**
1. Click on **Open IDE**

![Cloud 9 Environment](/images/ecs-spot-capacity-providers/cloud9_environment.png)

1. When it comes up, customize the environment by closing the **welcome tab** and **lower work area**, and opening a new **terminal** tab in the main work area:
1. If you like the dark theme seen below, you can choose it yourself by selecting **View / Themes / Solarized / Solarized Dark** in the Cloud9 workspace menu.


#### Your workspace should now look like this:
![Cloud 9 Environment](/images/ecs-spot-capacity-providers/cloud9_4.png)
