---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role](/prerequisites/workspaceiam/#validate-the-iam-role) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:
**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}
Run `aws sts get-caller-identity` and validate that your _Arn_ contains `eksworkshop-admin` 
(or the role created when starting the workshop) and an Instance Id.

```output
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-admin/i-01234567890abcdef"
}
```

If you do not see the correct role, please go back and [validate the IAM role](/prerequisites/workspaceiam/#validate-the-iam-role) for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}


### Create an EKS cluster

The following command will create an eks cluster with the name `eksworkshop-eksctl`
.It will also create a nodegroup with 2 on-demand instances.

```
eksctl create cluster --version=1.13 --name=eksworkshop-eksctl --nodes=2 --alb-ingress-access --region=${AWS_REGION} --node-labels="lifecycle=OnDemand,intent=control-apps" --asg-access
```

eksctl allows us to pass parameters to initialize the cluster. While initializing the cluster eksctl does also allow us to create a nodegroup. The nodegroup will have one single node and it will bootstrap with the labels **lifecycle=OnDemand** and **intent=control-apps**.

{{% notice info %}}
Launching EKS and all the dependencies will take approximately **15 minutes**
{{% /notice %}}


