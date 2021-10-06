---
title: "Update Workshop Settings"
chapter: false
disableToc: true
hidden: true
---
<!--
This markdown file is used as part of another file using 'insert-md-from-file' shortcode
-->

{{% notice info %}}
Cloud9 normally manages IAM credentials dynamically. This isn't currently compatible with
the EKS IAM authentication, so we will disable it and rely on the IAM role instead.
{{% /notice %}}


- Return to your workspace and click the sprocket, or launch a new tab to open the Preferences tab
- Select **AWS SETTINGS**
- Turn off **AWS managed temporary credentials**
- Close the Preferences tab
![c9disableiam](/images/using_ec2_spot_instances_with_eks/prerequisites/c9disableiam.png)

To ensure temporary credentials aren't already in place we will also remove
any existing credentials file:
```
rm -vf ${HOME}/.aws/credentials
```



