---
title: "Setup Cloud9 Environment"
weight: 20
---

## Seting up Cloud 9 Environment

{{% notice warning %}}
If you are running the workshop on your own, the Cloud9 workspace should be built by an IAM user with Administrator privileges, not the root account user. 
{{% /notice %}}

Please ensure you are logged in as an IAM user. We will open the Cloud9 environment first to execute all the commands needed for this workshop.

1. Login into AWS console with your account credentials and choose the region where you deployed the CloudFormation template.
1. Select **Services** and type **Cloud9**
1. Click on  **Your environments**.
1. Select the Cloud9 environment with the name **EcsSpotWorkshop**
1. Click on **Open IDE**

![Cloud 9 Environment](/images/ecs-spot-capacity-providers/cloud9_environment.png)

1. When it comes up, customize the environment by closing the **welcome tab** and **lower work area**, and opening a new **terminal** tab in the main work area:
1. If you like the dark theme seen below, you can choose it yourself by selecting **View / Themes / Solarized / Solarized Dark** in the Cloud9 workspace menu.

{{% notice tip %}}
If you have not used Cloud9 before, take your time to explore the IDE (Integrated Development Environment). We will primarily be using the terminal and the editor to read files.
{{% /notice %}}


Your workspace should now look like this:
![Cloud 9 Environment](/images/ecs-spot-capacity-providers/cloud9_4.png)


## Attaching an IAM role to the Cloud9 workspace

In order to work with ECS from our new Cloud9 IDE environment, we need the required permissions.

* Find your Cloud9 EC2 instance [here] (https://console.aws.amazon.com/ec2/v2/home?#Instances:search=aws-cloud9-EcsSpotWorkshop)
* Select the Instance, then choose **Actions** -> **Security** -> **Modify IAM Role**

![Attach IAM Role](/images/ecs-spot-capacity-providers/attach_iam_role.png)

* Choose **EcsSpotWorkshop-Cloud9InstanceProfile** from the *IAM Role* drop down, and select *Apply*

![Attach IAM Role](/images/ecs-spot-capacity-providers/c9_2.png)

* Return to your Cloud9 instance and click on the **Settings** icon at the top right
* Select **AWS SETTINGS** 
* Turn off **AWS managed temporary credentials** 
* Close the Preferences tab

![Attach IAM Role](/images/ecs-spot-capacity-providers/c9_3.png)

Use the [GetCallerIdentity] (https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity
```

The output assumed-role name should contain the name of the role in the Arn field.

```
{
    "UserId": "AROAQAHCJ2QPOAJPQADXV:i-0eedc304975256fac",
    "Account": "0004746XXXXX",
    "Arn": "arn:aws:sts::0004746XXXXX:assumed-role/EcsSpotWorkshop-Cloud9InstanceRole/i-0eedc304975256fac"
}
```