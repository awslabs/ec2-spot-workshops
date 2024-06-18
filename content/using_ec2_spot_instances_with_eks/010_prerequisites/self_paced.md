---
title: "...on your own"
chapter: false
weight: 20
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

{{% notice warning %}}
Only complete this section if you are running the workshop on your own. If you are at an AWS hosted event (such as re:Invent, Kubecon, Immersion Day, etc), go to [Start the workshop at an AWS event]({{< ref "/using_ec2_spot_instances_with_eks/010_prerequisites/aws_event.md" >}}).
{{% /notice %}}

### Running the workshop on your own

{{% notice warning %}}
Your account must have the ability to create new IAM roles and scope other IAM permissions.
{{% /notice %}}

1. If you don't already have an AWS account with Administrator access: [create
one now by clicking here](https://aws.amazon.com/getting-started/)

1. Once you have an AWS account, ensure you are following the remaining workshop steps
as an IAM user with administrator access to the AWS account:
[Create a new IAM user to use for the workshop](https://console.aws.amazon.com/iam/home?#/users$new)

1. Enter the user details:
![Create User](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-1-create-user.png)

1. Attach the AdministratorAccess IAM Policy:
![Attach Policy](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-2-attach-policy.png)

1. Click to create the new user:
![Confirm User](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-3-create-user.png)

1. Take note of the login URL and save:
![Login URL](/images/using_ec2_spot_instances_with_eks/prerequisites/iam-4-save-url.png)

### Deploying CloudFormation 

In the interest of time and to focus just on the workshop, we will install everything required to run this workshop using CloudFormation. 

1. Download locally this cloudformation stack into a file (**[eks-spot-workshop-quickstart-cnf.yml](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/using_ec2_spot_instances_with_eks/010_prerequisites/prerequisites.files/eks-spot-workshop-quickstart-cnf.yml)**).

1. Go into the CloudFormation console and select the creation of a new stack. Select **Template is ready**, and then **Upload a template file**, then select the file that you downloaded to your computer and click on **Next**

1. Fill in the **Stack Name** using 'eks-spot-workshop', Leave all the settings in the parameters section with the default prarameters and click **Next**

1. In the Configure Stack options just scroll to the bottom of the page and click **Next**

1. Finally in the **Review eks-spot-workshop** go to the bottom of the page and tick the `Capabilities` section *I acknowledge that AWS CloudFormation might create IAM resources.* then click **Create stack**

{{% notice warning %}}
The deployment of this stack may take up to 20minutes. You should wait until all the resources in the cloudformation stack have been completed before you start the rest of the workshop. The template deploys resourcess such as (a) An [AWS Cloud9](https://console.aws.amazon.com/cloud9) workspace with all the dependencies and IAM privileges to run the workshop (b) An EKS Cluster with the name `eksspotworkshop` and (c) a [EKS managed node group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)  with 3 on-demand instances. 
{{% /notice %}}

### Checking the completion of the stack deployment

One way to check your stack has been fully deployed is to check that all the cloudformation dependencies are green and succedded in the cloudformation dashboard; This should look similar to the state below.

![cnf_output](/images/using_ec2_spot_instances_with_eks/prerequisites/cfn_stak_completion.png)

#### Getting access to Cloud9  

In this workshop, you'll need to reference the resources created by the CloudFormation stack.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack name that starts with **eksspotworkshop-** in the list.

2. In the stack details pane, click the **Outputs** tab.

![cnf_output](/images/using_ec2_spot_instances_with_eks/prerequisites/cnf_output.png)

It is recommended that you keep this tab / window open so you can easily refer to the outputs and resources throughout the workshop.

{{% notice info %}}
You will notice an additional Cloudformation stack was also deployed which is the result of the stack that starts with **eksspotworkshop-**, and it's basically to deploy the Cloud9 Workspace.
{{% /notice %}}

#### Launch your Cloud9 workspace

- Click on the url against `Cloud9IDE` from the outputs

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/010_prerequisites/workspace_at_launch.md" %}}

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/010_prerequisites/update_workspace_settings.md" %}}


You are now ready to **[Test the Cluster]({{<  relref "/using_ec2_spot_instances_with_eks/021_terraform/"  >}})**
