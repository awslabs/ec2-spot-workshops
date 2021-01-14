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

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/prerequisites/validate_workspace_role.md" %}}

If you do not see the correct role, please go back and **[validate the IAM role]({{< relref "../prerequisites/update_workspaceiam.md" >}})** for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}


### Create an EKS cluster

The following command will create an eks cluster with the name `eksworkshop-eksctl`. It will also create a nodegroup with 2 on-demand instances.

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/eksctl/create_eks_cluster_eksctl_command.md" %}}

eksctl allows us to pass parameters to initialize the cluster. While initializing the cluster, eksctl does also allow us to create nodegroups.

The managed nodegroup will have two m5.large nodes and it will bootstrap with the labels **lifecycle=OnDemand** and **intent=control-apps**. 

{{% notice info %}}
Launching EKS and all the dependencies will take approximately **15 minutes**
{{% /notice %}}

The command above, created a **Managed Nodegroup**. [Amazon EKS managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) automate the provisioning and lifecycle management of nodes. Managed Nodegroups use the latest [EKS-optimized AMIs](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html). The node run in your AWS account provisioned as apart of an EC2 Auto Scaling group that is managed for you by Amazon EKS. This means EKS takes care of the lifecycle management and undifferentiated heavy lifting on operations such as node updates, handling of terminations, gracefully drain of nodes to ensure that your applications stay available.