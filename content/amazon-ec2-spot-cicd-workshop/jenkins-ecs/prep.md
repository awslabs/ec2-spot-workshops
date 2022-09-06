+++
title = "Setup with CloudFormation"
weight = 10
+++
Before we start presenting content on how to configure Jenkins with EC2 Spot instances in ECS, you'll need to prepare the AWS account that you've come to this workshop with. Specifically, this workshop involves working with a large number of AWS resources as well as a deployment of Jenkins that if manually configured, would leave you little time to discover how to use EC2 Spot instances in the most effective manner. To address that, you will deploy an Amazon CloudFormation template that does a lot of the heavy lifting of provisioning these resources for you.

## Launchh the CloudFormation template
So that you can concentrate on the aspects of this workshop that directly relate to Amazon EC2 Spot instances, there is a CloudFormation template that will deploy the base AWS infrastructure needed for all of the labs within the workshop - saving you from having to create things like ECS Cluster, VPCs, Security Groups, IAM policies and so forth.

Download and deploy the CloudFormation template:
[amazon-ec2-spot-cicd-workshop-asg.yaml](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/amazon-ec2-spot-cicd-workshop/amazon-ec2-spot-cicd-workshop-ecs.yaml)

Be sure to give it a stack name of **SpotCICDWorkshopECS** and ensure that you supply appropriate parameters when prompted.

1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1));
2. Click on the **Create Stack** button towards the top of the console;
3. At the Select Template screen, select the **Upload a template file** radio button and choose the CloudFormation template you downloaded before, then click on the **Next** button;
4. At the Specify Details screen, enter in **SpotCICDWorkshopECS** as the Stack name. Under the Parameters section:
    1. Identify what your current public IP address is by going to https://www.google.com.au/search?q=what%27s+my+ip+address. Enter the first three octets of this IP address into the **CurrentIP** parameter field and then add the **.0/24** suffix. For example if your IP address was 54.240.193.193, you would enter 54.240.193.0/24 into the CurrentIP field;
    2. Enter in a password that you would like to use for the administrator account within the Jenkins server that will be launched by the CloudFormation template;
5. Click on the **Next** button;
6. At the Options screen, there is no need to make any changes to the default options – simply click on the **Next** button;
7. Finally at the Review screen, verify your settings, mark the **I acknowledge that AWS CloudFormation might create IAM resources with custom names** checkbox and then click on the **Create** button. Wait for the stack to complete provisioning, which should take a couple of minutes.

The stack should take around five minutes to deploy.

{{% notice note %}}
It's good security practice to ensure that the web and SSH services being used in this workshop are not accessible to everyone on the Internet. In most cases, limiting access to the /24 CIDR block that you IP address is in provides a reasonable level of access control - but this may still be too restrictive in some corporate IT environments. If you have trouble accessing resources, additional instructions within this lab guide will guide you through what settings need to be manually changed.
{{% /notice %}}

{{% notice note %}}
The CloudFormation template creates a new Launch Template to install and bootstrap Jenkins. However, you can continue using any existing Launch Template that you might already have. 
{{% /notice %}}

## Setting Up environment variables
You need to set up the following environment variables that you'll use in the workshop, to do so, run the following commands:

```bash
export PRIVATE_SUBNETS=$(aws cloudformation describe-stacks --stack-name SpotCICDWorkshop --query "Stacks[0].Outputs[?OutputKey=='JenkinsVPCPrivateSubnets'].OutputValue" --output text);
export PUBLIC_SUBNETS=$(aws cloudformation describe-stacks --stack-name SpotCICDWorkshop --query "Stacks[0].Outputs[?OutputKey=='JenkinsVPCPublicSubnets'].OutputValue" --output text);
export LAUNCH_TEMPLATE_ID=$(aws ec2 describe-launch-templates --filters Name=launch-template-name,Values=JenkinsBuildAgentLaunchTemplate | jq -r '.LaunchTemplates[0].LaunchTemplateId');
```

{{% notice note %}}
If for some reason the environment variables are cleared, you can run the previous commands again without any problem.
{{% /notice %}}
