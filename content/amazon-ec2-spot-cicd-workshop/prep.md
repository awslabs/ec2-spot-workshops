+++
title = "Workshop Preparation"
weight = 10
+++
Before we start presenting content on the different use cases for EC2 Spot instances through the lens of CI/CD workloads, you'll need to prepare the AWS account that you've come to this workshop with. Specifically, this workshop involves working with a large number of AWS resources as well as a deployment of Jenkins that if manually configured, would leave you little time to discover how to use EC2 Spot instances in the most effective manner. To address that, you will deploy an Amazon CloudFormation template that does a lot of the heavy lifting of provisioning these resources for you.

## CREATE A NEW EC2 KEY PAIR
You will need to access the SSH interfaces of some Linux EC2 instances created in this workshop. To do so in a secure manner, please create a new EC2 key pair with a name of **Spot CICD Workshop Key Pair** in the **EU (Ireland)** region (all activities for this workshop will be carried out in this region).
{{%expand "Click to reveal detailed instructions" %}}
1. Log in to your AWS Account;
2. Switch to the **EU (Ireland)** region;
3. Provision a new EC2 Key Pair:
    1. Go to the **EC2** console and click on the **Key Pairs** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs));
    2. Click on the **Create Key Pair** button;
    3. Enter **Spot CICD Workshop Key Pair** as the Key pair name and click on the **Create** button;
    4. Your web browser should download a .pem file – keep this file as it will be required to access the EC2 instances that you create in this workshop. If you're using a Windows system, convert the .pem file to a puTTY .ppk file. If you're not sure how to do this, instructions are available [here](https://aws.amazon.com/premiumsupport/knowledge-center/convert-pem-file-into-ppk/).
{{% /expand%}}

## LAUNCH THE CLOUDFORMATION TEMPLATE
So that you can concentrate on the aspects of this workshop that directly relate to Amazon EC2 Spot instances, there is a CloudFormation template that will deploy the base AWS infrastructure needed for all of the labs within the workshop - saving you from having to create things like VPCs, Security Groups, IAM policies and so forth.

Deploy the CloudFormation template located at:
[https://https://ec2spotworkshops.com/workshops/amazon-ec2-spot-cicd-workshop/amazon-ec2-spot-cicd-workshop.yaml](https://https://ec2spotworkshops.com/workshops/amazon-ec2-spot-cicd-workshop/amazon-ec2-spot-cicd-workshop.yaml)

Be sure to give it a stack name of **SpotCICDWorkshop** and ensure that you supply appropriate parameters when prompted.
{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1));
2. Click on the **Create Stack** button towards the top of the console;
3. At the Select Template screen, select the **Specify an Amazon S3 template URL** radio button and type in [https://s3-us-west-2.amazonaws.com/amazon-ec2-spot-cicd-workshop/amazon-ec2-spot-cicd-workshop.yaml](https://s3-us-west-2.amazonaws.com/amazon-ec2-spot-cicd-workshop/amazon-ec2-spot-cicd-workshop.yaml) as the URL, then click on the **Next** button;
4. At the Specify Details screen, enter in **SpotCICDWorkshop** as the Stack name. Under the Parameters section:
    1. Identify what your current public IP address is by going to https://www.google.com.au/search?q=what%27s+my+ip+address. Enter the first three octets of this IP address into the **CurrentIP** parameter field and then add the **.0/24** suffix. For example if your IP address was 54.240.193.193, you would enter 54.240.193.0/24 into the CurrentIP field[^1];
    2. Enter in a password that you would like to use for the administrator account within the Jenkins server that will be launched by the CloudFormation template;
    3. Select the **Spot CICD Workshop Key Pair** option in the Keypair dropdown.
5. Click on the **Next** button;
6. At the Options screen, there is no need to make any changes to the default options – simply click on the **Next** button;
7. Finally at the Review screen, verify your settings, mark the **I acknowledge that AWS CloudFormation might create IAM resources with custom names** checkbox and then click on the **Create** button. Wait for the stack to complete provisioning, which should take a couple of minutes.

[^1]: It's good security practice to ensure that the web and SSH services being used in this workshop are not accessible to everyone on the Internet. In most cases, limiting access to the /24 CIDR block that you IP address is in provides a reasonable level of access control - but this may still be too restrictive in some corporate IT environments. If you have trouble accessing resources, additional instructions within this lab guide will guide you through what settings need to be manually changed.
{{% /expand%}}

The stack should take around five minutes to deploy.

## PROCEED TO LAB 1
Once the CloudFormation is in the process of being deployed, you've completed all of the preparation required to start the workshop, you may proceed with [Lab 1](/amazon-ec2-spot-cicd-workshop/lab1.html).
