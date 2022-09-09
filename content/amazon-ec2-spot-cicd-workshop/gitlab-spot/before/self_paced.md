+++
title = "...On your own"
weight = 20
+++

{{% notice warning %}}
Only complete this section if you are running the workshop on your own or if you do not have a CloudFormation stack with GitLab available. If you are at an AWS hosted event (such as re:Invent, public workshop, Immersion Day, or any other event hosted by an AWS employee), go to [Start the workshop at an AWS event]({{< ref "/amazon-ec2-spot-cicd-workshop/gitlab-spot/before/aws_event.md" >}}).
{{% /notice %}}

### Preparation

{{% notice warning %}}
Your account must have the ability to create new IAM roles and scope other IAM permissions.
{{% /notice %}}

1. If you don't already have an AWS account with Administrator access: [create one now by clicking here](https://aws.amazon.com/getting-started/)
2. Log in to [AWS Console](https://console.aws.amazon.com/) with an IAM user having administrator permissions.

### Create an SSH key

You don't need the key to complete the labs, but it is still configured when creating the instances, because you might want to explore the environment and log in to the provisioned instances. The following steps show how to create it.

1. Open **EC2** service in the AWS Console.
2. In the navigation pane choose **Key Pairs** in the **Network & Security** section.
3. If there is already an existing SSH key and you have its private key, remember its name, otherwise create a new one:
    * Choose **Create key pair**
    * In the **Name** field enter `ee-default-key-pair`
    * In the **Private key file format** list select `.pem` (even if you use Microsoft Windows: we will be uploading this key into an AWS Cloud9 environment)
    * Choose **Create key pair**
    * Save the .pem file as suggested by your browser

### Deploy GitLab
Now you will deploy a GitLab without any runners. As it is not the purpose of this workshop to dive deep into GitLab itself, the deployment will be fully automated using Infrastructure as Code template in AWS CloudFormation. It will deploy a VPC with two public subnets, an Amazon S3 bucket that you can configure as GitLab cache, an EC2 Auto Scaling group for GitLab, an Application Load Balancer and an Amazon CloudFront distribution to organize a secure access to it, an Amazon ECR repository for storing the container image, and a number of supplementary resources.

1. Open **CloudFormation** service in the AWS Console.
2. In the navigation pane choose **Stacks**.
3. Choose **Create stack** and in the dropdown choose **With new resources (standard)**.
4. Download the CloudFormation YAML-template from [this link](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/amazon-ec2-spot-cicd-workshop/gitlab-spot/gitlab-deploy.yml).
5. In the **Template source** field select **Upload a template file**, choose the file you saved in the step above, and choose **Next**.
6. In the **Stack name** field enter `mod-gitlab-spot-workshop`, in the **EEKeyPair** field select `ee-default-key-pair` or the name of the key you used in the steps above. Leave the default values in other fields and choose **Next**.
7. Choose **Next**.
8. Mark the checkbox **I acknowledge that AWS CloudFormation might create IAM resources.** and choose **Create stack**.
9. Wait until the stack is in `CREATE_COMPLETE` status (it should take approximately 15 minutes) and continue with [**Workshop Preparation**](/amazon-ec2-spot-cicd-workshop/gitlab-spot/010-prep.html).