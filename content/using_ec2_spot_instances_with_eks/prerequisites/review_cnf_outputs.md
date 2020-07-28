---
title: "Review the Cloudformation Outputs"
chapter: false
weight: 29
---

{{% notice warning %}}
If you are running the workshop on your own, the Cloud9 workspace should be built by an IAM user with Administrator privileges, not the root account user. Please ensure you are logged in as an IAM user, not the root
account user.
{{% /notice %}}

{{% notice info %}}
If you are at an AWS hosted event (such as re:Invent, Kubecon, Immersion Day, or any other event hosted by 
an AWS employee), we have created the resources required to get started with the workshop
{{% /notice %}}

#### What resources are already deployed?

We have deployed the below resources required to get started with the workshop, you'll need to reference the resources created by the CloudFormation stack.

1. A [AWS Cloud9](https://console.aws.amazon.com/cloud9) with an IAM role with AdministratorAccess attached and setup with the utilities eksctl, kubectl.

2. An EKS cluster with the name `eksworkshop-eksctl`. It also created a nodegroup with 2 on-demand instances.

    {{%expand "Click to see the eksctl used to create the cluster" %}}
    ```
    eksctl create cluster --version=1.16 --name=eksworkshop-eksctl --node-private-networking  --managed --nodes=2 --alb-ingress-access --region=${AWS_REGION} --node-labels="lifecycle=OnDemand,intent=control-apps" --asg-access
    ```
    {{% /expand%}}

It is recommended that you keep this window open so you can easily refer to the outputs and resources throughout the workshop.

#### Use your resources 

In this workshop, you'll need to reference the resources created by the CloudFormation stack that we setup for you.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack in the list.

1. In the stack details pane, click the **Outputs** tab.

It is recommended that you keep this window open so you can easily refer to the outputs and resources throughout the workshop.

