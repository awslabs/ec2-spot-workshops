---
title: "...on your own"
chapter: false
weight: 10
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

{{% notice warning %}}
Only complete this section if you are running the workshop on your own. If you are at an AWS hosted event (such as re:Invent, Kubecon, Immersion Day, etc), go to [Start the workshop at an AWS event]({{< ref "/karpenter/010_prerequisites/aws_event.md" >}}).
{{% /notice %}}

## Running the workshop on your own


### Creating an account to run the workshop

{{% notice warning %}}
Your account must have the ability to create new IAM roles and scope other IAM permissions.
{{% /notice %}}

1. If you don't already have an AWS account with Administrator access: [create
one now by clicking here](https://aws.amazon.com/getting-started/)

1. Once you have an AWS account, ensure you are following the remaining workshop steps
as an IAM user with administrator access to the AWS account:
[Create a new IAM user to use for the workshop](https://console.aws.amazon.com/iam/home?#/users$new)

1. Enter the user details:
![Create User](/images/karpenter/prerequisites/iam-1-create-user.png)

1. Attach the AdministratorAccess IAM Policy:
![Attach Policy](/images/karpenter/prerequisites/iam-2-attach-policy.png)

1. Click to create the new user:
![Confirm User](/images/karpenter/prerequisites/iam-3-create-user.png)

1. Take note of the login URL and save:
![Login URL](/images/karpenter/prerequisites/iam-4-save-url.png)

### Deploying CloudFormation 

In the interest of time and to focus just on karpenter, we will install everything required to run this Karpenter workshop using cloudformation. 

1. Download locally this cloudformation stack into a file (**[eks-spot-workshop-quickstarter-cnf.yml](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/karpenter/010_prerequisites/prerequisites.files/eks-spot-workshop-quickstart-cnf.yml)**).

1. Go into the CloudFormation console and select the creation of a new stack. Select **Template is ready**, and then **Upload a template file**, then select the file that you downloaded to your computer and click on **Next**

1. Fill in the **Stack Name** using 'karpenter-workshop', Leave all the settings in the parameters section with the default prarameters and click **Next**

1. In the Configure Stack options just scroll to the bottom of the page and click **Next**

1. Finally in the **Review karpenter-workshop** go to the bottom of the page and tick the `Capabilities` section *I acknowledge that AWS CloudFormation might create IAM resources.* then click **Create stack**

{{% notice warning %}}
The deployment of this stack may take up to 20minutes. You should wait until all the resources in the cloudformation stack have been completed before you start the rest of the workshop. The template deploys resourcess such as (a) An [AWS Cloud9](https://console.aws.amazon.com/cloud9) workspace with all the dependencies and IAM privileges to run the workshop (b) An EKS Cluster with the name `eksworkshop-eksctl` and (c) a [EKS managed node group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)  with 2 on-demand instances. 
{{% /notice %}}

### Checking the completion of the stack deployment

One way to check your stack has been fully deployed is to check that all the cloudformation dependencies are green and succedded in the cloudformation dashboard; This should look similar to the state below.

![cnf_output](/images/karpenter/prerequisites/cfn_stak_completion.png)

#### Getting access to Cloud9  

In this workshop, you'll need to reference the resources created by the CloudFormation stack.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack name that starts with **mod-** in the list.

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

Before we use Karpenter, there are a few things that we will need to prepare in our environment for it to work as expected.

## Create the Amazon EC2 Spot Linked Role

To finish the set-up we need to create the spot [EC2 Spot Linked role](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html#service-linked-roles-spot-instance-requests).

{{% notice warning %}}
This step is only necessary if this is the first time you’re using EC2 Spot in this account. If the role has already been successfully created, you will see: *An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.* . Just ignore the error and proceed with the rest of the workshop.
{{% /notice %}}

In your Cloud9 terminal workspace, run the following command:

```
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```

You are now ready to **[Test the Cluster]({{<  relref "/karpenter/test.md"  >}})**
