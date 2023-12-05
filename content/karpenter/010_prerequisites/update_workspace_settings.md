---
disableToc: true
hidden: true
---

{{% notice info %}}
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

**Note**: Cloud9 normally manages IAM credentials dynamically. This isn’t currently compatible with the EKS IAM authentication, so we will disable it and rely on the IAM role instead. To do so, run the following commands in the Cloud9 workspace:
```
aws cloud9 update-environment --environment-id ${C9_PID} --managed-credentials-action DISABLE
rm -vf ${HOME}/.aws/credentials
```



