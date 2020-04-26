---
title: "Module-1: Setup the workshop environment on AWS"
chapter: true
weight: 15
---

## Select Region and Create keypair

1. First, you’ll need to select a region of your choice. At the top right hand corner of the AWS Console, you’ll see a Support dropdown. To the left of that is the region selection dropdown. For this lab, us-east-1/North Virginia is assumed.
1. Then you’ll need to create an SSH key pair which will be used to login to the instances once provisioned. Go to the EC2 Dashboard and click on Key Pairs in the left menu under Network & Security. Click Create Key Pair, provide a name (can be anything, make it something memorable) when prompted, and click Create. Once created, the private key in the form of .pem file will be automatically downloaded.

If you’re using linux or mac, change the permissions of the .pem file to be less open.

    chmod 400 <private_key>.pem

If you’re on windows you’ll need to convert the .pem file to .ppk to work with putty. Here is a link to instructions for the file conversion - [Connecting to Your Linux Instance from Windows Using PuTTY] (http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html)

## Preparation steps: 

Deploy a new VPC that will be used to run your ECS cluster in the workshop.

1. Open the [Modular and Scalable VPC Architecture Quick stage page] (https://aws.amazon.com/quickstart/architecture/vpc/) and go to the “How to deploy” tab, Click the [Launch the Quick Start] (https://fwd.aws/mm853) link.
1. Select your desired region to run the workshop from the top right corner of the AWS Management Console and click *Next*.
1. Provide a name for the stack or leave it as *Quick-Start-VPC*.
1. Under *Availability Zones*, select three availability zones from the list, and set the *Number of Availability Zones* to *3*.
1. Under *Create private subnets* select *false*.
1. click *Next* and again *Next* in the next screen.
1. Click *Create stack*.

 The stack creation should take under 2 minutes and the status of the stack will be *CREATE_COMPLETE*.

### ***Congratulations!*** you completed the prerequisites needed to start the workshop, you now have a VPC to run your ECS cluster
