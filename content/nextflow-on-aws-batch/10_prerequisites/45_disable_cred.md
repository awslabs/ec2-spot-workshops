---
title: "Disable Temporary Credentials"
chapter: false
weight: 45
---

## Managed Credential Handling from Cloud9

To not have Cloud9 overwrite the IAM roles with temporary crendentials, we will disable temporary crendential management within Cloud9.

![disable_cred](/images/nextflow-on-aws-batch/prerequisites/disable_cred.png)

Please verify that your IAM role is providing your identity by executing the following command:

```bash
aws sts get-caller-identity
```

The output should include the IAM role name (`nextflow-workshop-admin`), similar to:

```bash
$ aws sts get-caller-identity
{
    "UserId": "AROA4KFOLXRT3PYT5QRNW:i-0aca005990c36734f",
    "Account": "846474230887",
    "Arn": "arn:aws:sts::846474230887:assumed-role/nextflow-workshop-admin/i-0aca005990c36734f"
}
```
