---
title: "Launch EKS"
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have validated the IAM role in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

### Validate the IAM role {#validate_iam}

Use the `get-caller-identity` CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

You can verify what the output an correct role shoulld be in the **[validate the IAM role section]({{< relref "../010_prerequisites/update_workspaceiam.md" >}})**. If you do see the correct role, proceed to next step to create an EKS cluster.

### Create an EKS cluster

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/021_terraform/create_eks_cluster_terraform_command.md" %}}

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 20 minutes
{{% /notice %}}