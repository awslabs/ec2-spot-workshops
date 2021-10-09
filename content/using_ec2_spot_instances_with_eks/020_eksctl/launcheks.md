---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role]({{< relref "../010_prerequisites/update_workspaceiam.md#validate_iam" >}}) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:
**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/010_prerequisites/validate_workspace_role.md" %}}

If you do not see the correct role, please go back and **[validate the IAM role]({{< relref "../010_prerequisites/update_workspaceiam.md" >}})** for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}


### Create an EKS cluster

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/020_eksctl/create_eks_cluster_eksctl_command.md" %}}

eksctl allows us to pass parameters to initialize the cluster. While initializing the cluster, eksctl does also allow us to create nodegroups.

The managed nodegroup will have two m5.large nodes (m5.large is the default instance type used if no instance types are specified) and it will bootstrap with the label **intent=control-apps**. 

Amazon EKS adds the following Kubernetes label to all nodes in your managed node group: **eks.amazonaws.com/capacityType: ON_DEMAND**. You can use this label to schedule stateful or fault intolerant applications on On-Demand nodes.