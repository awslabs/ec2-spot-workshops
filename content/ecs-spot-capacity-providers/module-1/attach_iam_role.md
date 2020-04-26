---
title: "Attach the IAM role to your Workspace"
chapter: true
weight: 20
---

### Attach the IAM role to your Workspace

- Follow [this deep link to find your Cloud9 EC2 instance](https://console.aws.amazon.com/ec2/v2/home?#Instances:tag:Name=aws-cloud9-.*workshop.*;sort=desc:launchTime)
- Select the instance, then choose **Actions / Instance Settings / Attach/Replace IAM Role**
- Choose **ecsspotworkshop-admin** from the **IAM Role** drop down, and select **Apply**
- Return to your workspace and click the sprocket, or launch a new tab to open the Preferences tab
- Select **AWS SETTINGS**
- Turn off **AWS managed temporary credentials**
- Close the Preferences tab
- To ensure temporary credentials aren't already in place we will also remove any existing credentials file:
```
rm -vf ${HOME}/.aws/credentials
```

- We should configure our aws cli with our current region as default:
```
export ACCOUNT\_ID=$(aws sts get-caller-identity  --output text --query Account)
 export AWS\_REGION=$(curl -s  169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
 echo "export  ACCOUNT\_ID=${ACCOUNT\_ID}" \&gt;\&gt; ~/.bash\_profile
 echo "export  AWS\_REGION=${AWS\_REGION}" \&gt;\&gt; ~/.bash\_profile
 aws configure set default.region ${AWS\_REGION}
 aws configure get default.region
```

- Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity
```
- The output assumed-role name should contain:

```
{
      "Account": "000474600478",
      "UserId": "AROAQAHCJ2QPAONSHPAXY:i-01ad7d6cd53ba8945",
      "Arn": "arn:aws:sts::000474600478:assumed-role/ecsspotworkshop-admin/i-01ad7d6cd53ba8945"
 }
```



#### Attach IAM role to your Cloud 9 Environment:
![Cloud 9 Environment](/images/ecs-spot-capacity-providers/iam_attach_role.png)




Now you are done with Module-1, Proceed to Module-2 of this workshop.