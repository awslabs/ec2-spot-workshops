---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role]({{< relref "../prerequisites/update_workspaceiam.md#validate_iam" >}}) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:
**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

{{% notice note %}}
**Select the tab** and and validate the assumed role…
{{% /notice %}}
{{< tabs name="Region" >}}
    {{< tab name="...ON YOUR OWN" include="../prerequisites/on_your_own_validaterole.md" />}}
    {{< tab name="...AT AN AWS EVENT" include="../prerequisites/at_an_aws_validaterole.md" />}}
{{< /tabs >}}

If you do not see the correct role, please go back and **[validate the IAM role]({{< relref "../prerequisites/update_workspaceiam.md" >}})** for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}


### Create an EKS cluster

The following command will create an eks cluster with the name `eksworkshop-eksctl`
.It will also create a nodegroup with 2 on-demand instances.

```
eksctl create cluster --version=1.14 --name=eksworkshop-eksctl --nodes=2 --alb-ingress-access --region=${AWS_REGION} --node-labels="lifecycle=OnDemand,intent=control-apps" --asg-access
```

eksctl allows us to pass parameters to initialize the cluster. While initializing the cluster eksctl does also allow us to create a nodegroup. The nodegroup will have one single node and it will bootstrap with the labels **lifecycle=OnDemand** and **intent=control-apps**.

{{% notice info %}}
Launching EKS and all the dependencies will take approximately **15 minutes**
{{% /notice %}}


