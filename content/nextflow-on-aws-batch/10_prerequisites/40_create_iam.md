---
title: "Create an IAM role for your Workspace"
chapter: false
weight: 39
---

## Create an IAM role for your Workspace

1. Head over to the IAM console and find *create role* (**[2]**) under the *Roles* (**[1]**) section.
![create_role_0](/images/nextflow-on-aws-batch/prerequisites/create_role-0.png)
1. Pick the EC2 use-case (**[1]**) and hit **Next** button at the bottom.
![create_role_1](/images/nextflow-on-aws-batch/prerequisites/create_role-1.png)
1. Wait for the Permission tab to render and chose **AdministratorAccess** (**[1]**).
![create_role_2](/images/nextflow-on-aws-batch/prerequisites/create_role-2.png)
1. Add a tag **nextflow-workshop** without a value to identify the role for cleanup.
![create_role_3](/images/nextflow-on-aws-batch/prerequisites/create_role-3.png)
