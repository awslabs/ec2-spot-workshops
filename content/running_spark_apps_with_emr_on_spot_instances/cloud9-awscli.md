---
title: "Configure your Cloud9 workspace"
chapter: false
weight: 20
comment: default install now includes aws-cli/1.15.83
---

{{% notice tip %}}
For this workshop, please ignore warnings about the version of pip being used.
{{% /notice %}}

1. Uninstall the AWS CLI 1.x by running:
```bash
sudo pip uninstall -y awscli
```

1. Install the AWS CLI 2.x by running the following command:
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
. ~/.bash_profile
```

1. Confirm you have a newer version:
```
aws --version
```

1. Create an SSH Key pair so you can then SSH into the EMR cluster

```bash
aws ec2 create-key-pair --key-name emr-workshop-key-pair --query "KeyMaterial" --output text > emr-workshop-key-pair.pem
chmod 400 emr-workshop-key-pair.pem
```
