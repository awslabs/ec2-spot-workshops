---
title: "Prerequisites"
weight: 10
---

For this module, we need to download and install the [Terraform](https://www.terraform.io/) binary. In Cloud9 workspace, run these commands:

```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform-1.3.7-1
```

Confirm the Terraform command works:

```
terraform version  
```