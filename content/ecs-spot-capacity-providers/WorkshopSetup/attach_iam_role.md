---
title: "Attach the IAM role to your Workspace"
chapter: true
weight: 10
---

Attach the IAM role for your Workspace
---

In order to work with ECS from our workstation, we will need the appropriate permissions for our developer workstation instance.

* Find your Cloud9 EC2 instance from [here] (https://console.aws.amazon.com/cloud9/home?region=us-east-1)
* Select the instance, then choose Actions / Instance Settings / Attach/Replace IAM Role
* Choose **EcsSpotWorkshop-Cloud9InstanceProfile** from the *IAM Role* drop down, and select *Apply*

![Attach IAM Role](/images/ecs-spot-capacity-providers/c9_1.png)
![Attach IAM Role](/images/ecs-spot-capacity-providers/c9_2.png)

* Click on the *Settings* icon on the top right
* Select *AWS SETTINGS* 
* Turn off *AWS managed temporary credentials* 
* Close the Preferences tab

![Attach IAM Role](/images/ecs-spot-capacity-providers/c9_3.png)

Use the [GetCallerIdentity] (https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity
```

The output assumed-role name should contain:

```
{
    "UserId": "AROAQAHCJ2QPOAJPQADXV:i-0eedc304975256fac",
    "Account": "000474600478",
    "Arn": "arn:aws:sts::000474600478:assumed-role/EcsSpotWorkshop-Cloud9InstanceRole/i-0eedc304975256fac"
}
```

