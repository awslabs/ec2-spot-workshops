---
title: "Attach IAM role to Cloud9 Workspace"
weight: 10
---

In order to work with ECS from our new Cloud9 IDE environment, we will need the appropriate permissions.

* Find your Cloud9 EC2 instance [here] (https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:search=aws-cloud9-EcsSpotWorkshop)

* Select the instance, then choose Actions -> Instance Settings -> Attach/Replace IAM Role
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

The output assumed-role name should contain the name of the role.

```
{
    "UserId": "AROAQAHCJ2QPOAJPQADXV:i-0eedc304975256fac",
    "Account": "0004746XXXXX",
    "Arn": "arn:aws:sts::0004746XXXXX:assumed-role/EcsSpotWorkshop-Cloud9InstanceRole/i-0eedc304975256fac"
}
```