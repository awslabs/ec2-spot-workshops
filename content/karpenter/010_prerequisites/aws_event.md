---
title: "...at an AWS event"
chapter: false
weight: 20
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

### Running the workshop at an AWS Event

{{% notice warning %}}
Only complete this section if you are at an AWS hosted event (such as re:Invent,
Kubecon, Immersion Day, or any other event hosted by an AWS employee). If you 
are running the workshop on your own, go to: [Start the workshop on your own]({{< ref "/karpenter/010_prerequisites/self_paced.md" >}}).
{{% /notice %}}

### Login to the AWS Workshop Portal

If you are at an AWS event, an AWS account was created for you to use throughout the workshop. You will need the **Event access code** provided to you by the event's organizers.

1. Connect to the portal by browsing to [Workshop Studio](https://catalog.us-east-1.prod.workshops.aws/join).
2. Sign in by clicking on the `Email one-time password (OTP)` button.
3. Enter your email address in the text box, and click **Send Passcode**. You should receive a passcode within 5 minutes. Enter the passcode in the text box, and click **Sign in***.
4. Enter the `Event access code` in the text box, and click **Next** 
5. Review the `Terms and Conditions` and check the `I agree with the Terms and Conditions` box, and click **Join event** 
6. In the left panel, click **Open AWS console** 

You are now logged in to the AWS console in an account that was created for you, and will be available only throughout the workshop run time.

{{% notice info %}}
In the interest of time we have deployed everything required to run Karpenter for this workshop. All the pre-requisites and dependencies have been deployed. The resources deployed can befound in this CloudFormation Template (**[eks-spot-workshop-quickstarter-cnf.yml](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/using_ec2_spot_instances_with_eks/010_prerequisites/prerequisites.files/eks-spot-workshop-quickstart-cnf.yml)**). The template deploys resourcess such as (a) An [AWS Cloud9](https://console.aws.amazon.com/cloud9) workspace with all the dependencies and IAM privileges to run the workshop (b) An EKS Cluster with the name `eksworkshop-eksctl` and (c) a [EKS managed node group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)  with 2 on-demand instances. 
{{% /notice %}}

#### Getting access to Cloud9  

In this workshop, you'll need to reference the resources created by the CloudFormation stack.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack name **eks-spot-workshop-quickstart-cnf** in the list.

2. In the stack details pane, click the **Outputs** tab.

![cnf_output](/images/karpenter/prerequisites/cnf_output.png)

It is recommended that you keep this tab / window open so you can easily refer to the outputs and resources throughout the workshop.

{{% notice info %}}
you will notice additional Cloudformation stacks were also deployed which is the result of the stack that starts with **mod-**. One to deploy the Cloud9 Workspace and two other to create the EKS cluster and managed nodegroup.
{{% /notice %}}

#### Launch your Cloud9 workspace

- Click on the url against `Cloud9IDE` from the outputs

{{% insert-md-from-file file="karpenter/010_prerequisites/workspace_at_launch.md" %}}

{{% insert-md-from-file file="karpenter/010_prerequisites/update_workspace_settings.md" %}}

### Validate the IAM role {#validate_iam}

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

{{% insert-md-from-file file="karpenter/010_prerequisites/at_an_aws_validaterole.md" %}}



You are now ready to **[Test the Cluster]({{<  relref "/karpenter/test.md"  >}})**

