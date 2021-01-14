---
title: "Update IAM settings for your Workspace"
chapter: false
weight: 60
---

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/prerequisites/update_workspace_settings.md" %}}

We should configure our aws cli with our current region as default:
```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

echo "export ACCOUNT_ID=${ACCOUNT_ID}" >> ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
```

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/prerequisites/validate_workspace_role.md" %}}

