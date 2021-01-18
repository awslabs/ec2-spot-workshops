---
title: "...at an AWS event"
chapter: false
weight: 20
---

### Running the workshop at an AWS Event

{{% notice warning %}}
Only complete this section if you are at an AWS hosted event (such as re:Invent,
Kubecon, Immersion Day, or any other event hosted by an AWS employee). If you 
are running the workshop on your own, go to: [Start the workshop on your own]({{< ref "/using_ec2_spot_instances_with_eks/prerequisites/self_paced.md" >}}).
{{% /notice %}}

### Login to the AWS Workshop Portal

If you are at an AWS event, an AWS account was created for you to use throughout the workshop. You will need the **Participant Hash** provided to you by the event's organizers.

1. Connect to the portal by browsing to [https://dashboard.eventengine.run/](https://dashboard.eventengine.run/).
2. Enter the Hash in the text box, and click **Proceed** 
3. In the User Dashboard screen, click **AWS Console** 
4. In the popup page, click **Open Console** 

You are now logged in to the AWS console in an account that was created for you, and will be available only throughout the workshop run time.

{{% notice info %}}
In the interest of time for shorter events we sometimes deploy the resources required as a prerequisite for you. If you were told so, please review the cloudformation outputs of the stack that was deployed by **expanding the instructions below**.
{{% /notice %}}

{{%expand "Click to reveal detailed instructions" %}}

#### What resources are already deployed {#resources_deployed}

We have deployed the below resources required to get started with the workshop using a CloudFormation Template (**[eks-spot-workshop-quickstarter-cnf.yml] (prerequisites.files/eks-spot-workshop-quickstart-cnf.yml)**), Please reference the below  resources created by the stack.

+ An [AWS Cloud9](https://console.aws.amazon.com/cloud9) workspace with
    - An IAM role created and attached to the workspace with Administrator access
    - Kubernetes tools installed (kubectl, jq and envsubst)
    - awscli upgraded to v2
    - Created and imported a key pair to Amazon EC2
    - [eksctl](https://eksctl.io/) installed, The official CLI for Amazon EKS 

+ An EKS cluster with the name `eksworkshop-eksctl` and a [EKS managed node group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)  with 2 on-demand instances.

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/eksctl/create_eks_cluster_eksctl_command.md" %}}


#### Use your resources 

In this workshop, you'll need to reference the resources created by the CloudFormation stack that we setup for you.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack name that starts with **mod-** in the list.

1. In the stack details pane, click the **Outputs** tab.

![cnf_output](/images/using_ec2_spot_instances_with_eks/prerequisites/cnf_output.png)

It is recommended that you keep this window open so you can easily refer to the outputs and resources throughout the workshop.

{{% notice info %}}
you will notice additional Cloudformation stacks were also deployed which is the result of the stack that starts with **mod-**. One to deploy the Cloud9 Workspace and two other to create the EKS cluster and managed nodegroup.
{{% /notice %}}

#### Launch your Cloud9 workspace

- Click on the url against `Cloud9IDE` from the outputs

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/prerequisites/workspace_at_launch.md" %}}

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/prerequisites/update_workspace_settings.md" %}}

### Validate the IAM role {#validate_iam}

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/prerequisites/at_an_aws_validaterole.md" %}}

{{% notice note %}}
Since we have already setup the prerequisites, **you can head straight to [Test the Cluster]({{<  relref "/using_ec2_spot_instances_with_eks/eksctl/test.md"  >}})**
{{% /notice %}}

{{% /expand%}}

