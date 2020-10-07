---
title: "Create an EC2 launch template"
weight: 1
---

EC2 Launch Templates reduce the number of steps required to create an instance by capturing all launch parameters within one resource.

You can create a launch template that contains the configuration information to launch an instance. Launch templates enable you to store launch parameters so that you do not have to specify them every time you launch an instance. For example, a launch template can contain the ECS optimized AMI, instance type, User data section, Instance Profile / Role and network settings that you typically use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the launch template to use. Instance user data required to bootstrap the instance into the ECS Cluster.

You will create a launch template to specify configuration parameters for launching instances in this workshop.

Copy the template file  **templates/user-data.txt** to the current directory,

```
cp templates/user-data.txt .

```

Take a moment to look at the user data script to see the bootstrapping actions that is performing. Also notice ECS auto draining is enabled in the configuration

```
echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=true" >> /etc/ecs/ecs.config
```

Set the following variables for the resources be used in creating the launch template in this workshop.

Set the ARN of the IAM role **ecslabinstanceprofile** created in Module-1

Get your AWS account id with below command. This is needed in the next step.

```
echo $ACCOUNT_ID
```

Note: Replace the **AWS Acount ID** with your AWS account in the below command.

```
export IAM_INSTANT_PROFILE_ARN=arn:aws:iam::$ACCOUNT_ID :instance-profile/ecslabinstanceprofile
```

It is recommended to use the latest ECS Optimized AMI which contains the ECS container agent. This is used to join the ECS cluster/

```
export AMI_ID=$(aws ssm get-parameters --names  /aws/service/ecs/optimized-ami/amazon-linux-2/recommended | jq -r 'last(.Parameters[]).Value' | jq -r '.image\id')
 echo "Latest  ECS Optimized Amazon AMI\ID is $AMI_ID"
```

The output from above command looks like below.

```
Latest ECS Optimized Amazon AMI_ID is ami-07a63940735aebd38
```

copy the template file  **templates/launch-template-data.json** to the current directory,

```
cp templates/launch-template-data.json .
```

Run the following commands to substitute the template with actual values from the variables.

```
sed -i -e "s#%instanceProfile%#$IAM_INSTANT_PROFILE_ARN#g"  -e "s#%instanceSecurityGroup%#$SECURITY_GROUP#g"  -e "s#%ami-id%#$AMI_ID#g"  -e "s#%UserData%#$(cat user-data.txt |  base64 --wrap=0)#g" launch-template-data.json
```


Now let is create the launch template

```
LAUCH_TEMPLATE_ID=$(aws ec2 create-launch-template  --launch-template-name ecs-spot-workshop-lt  --version-description 1 --launch-template-data file://launch-template-data.json | jq -r '.LaunchTemplate.LaunchTemplateId')
 echo "Amazon  LAUCH_TEMPLATE_ID is $LAUCH_TEMPLATE_ID"
```


The output from above command looks like this, you can also view this Launch Template in the Console.

```
Amazon LAUCH_TEMPLATE_ID is lt-023e2e52afc51d7ed
```


Verify that the contents of the launch template are correct:

```
aws ec2 describe-launch-template-versions  --launch-template-name ecs-spot-workshop-lt
```


Verify that the contents of the launch template user data are correct:

```
aws ec2 describe-launch-template-versions  --launch-template-name ecs-spot-workshop-lt--output json | jq -r '.LaunchTemplateVersions[].LaunchTemplateData.UserData' | base64 --decode
```