+++
title = "Lab-1 Setup the workshop environment on AWS"
weight = 110
+++

## Set up the Workshop Environment on AWS

1. First, you'll need to select a region. For this lab, you will need to choose either Ohio or Oregon. At the top right hand corner of the AWS Console, you'll see a Support dropdown. To the left of that is the region selection dropdown.

2. Then you'll need to create an SSH key pair which will be used to login to the instances once provisioned. Go to the EC2 Dashboard and click on Key Pairs in the left menu under Network & Security. Click Create Key Pair, provide a name (can be anything, make it something memorable) when prompted, and click Create. Once created, the private key in the form of .pem file will be automatically downloaded.

If you're using linux or mac, change the permissions of the .pem file to be less open.


	$ chmod 400 PRIVATE_KEY.PEM
	
If you're on windows you'll need to convert the .pem file to .ppk to work with putty. Here is a link to instructions for the file conversion - [Connecting to Your Linux Instance from Windows Using PuTTY](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html)

3. For your convenience, we provide a CloudFormation template to stand up the core infrastructure.

Prior to launching a stack, be aware that a few of the resources launched need to be manually deleted when the workshop is over. When finished working, please review the "Workshop Cleanup" section to learn what manual teardown is required by you.

Click on one of these CloudFormation templates that matches the region you created your keypair in to launch your stack:

| Region            | Launch Template |
| :----------------|:-------------|
| Ohio (us-east-2)  | [Deploy to AWS](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=ecs-deep-learning-stack&templateURL=https://s3.amazonaws.com/ecs-dl-workshop-us-east-2/ecs-deep-learning-workshop.yaml) |
| Oregon (us-west-2)| [Deploy to AWS](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=ecs-deep-learning-stack&templateURL=https://s3.amazonaws.com/ecs-dl-workshop-us-west-2/ecs-deep-learning-workshop.yaml) |

The template will automatically bring you to the CloudFormation Dashboard and start the stack creation process in the specified region. Click "Next" on the page it brings you to. Do not change anything on the first screen. 

![](/images/ecs-deep-learning-workshop/cf-initial.png)

The template sets up a VPC, IAM roles, S3 bucket, ECR container registry and an ECS cluster which is comprised of one EC2 Instance with the Docker daemon running. The idea is to provide a contained environment, so as not to interfere with any other provisioned resources in your account. In order to demonstrate cost optimization strategies, the EC2 Instance is an [EC2 Spot Instance](https://aws.amazon.com/ec2/spot/) deployed by [Spot Fleet](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet.html). If you are new to [CloudFormation](https://aws.amazon.com/cloudformation/), take the opportunity to review the [template](https://github.com/awslabs/ecs-deep-learning-workshop/blob/master/lab-1-setup/cfn-templates/ecs-deep-learning-workshop.yaml) during stack creation.

**IMPORTANT:**

_On the parameter selection page of launching your CloudFormation stack, make sure to choose the key pair that you created in step 1. If you don't see a key pair to select, check your region and try again._

![](/images/ecs-deep-learning-workshop/cf-params.png)

#### Create the stack

After you've selected your ssh key pair, click **Next**. On the **Options** page, accept all defaults- you don't need to make any changes. Click **Next**. On the **Review page**, under **Capabilities** check the box next to **"I acknowledge that AWS CloudFormation might create IAM resources."** and click **Create**. Your CloudFormation stack is now being created.

#### Checkpoint

Periodically check on the stack creation process in the CloudFormation Dashboard. Your stack should show status **CREATE_COMPLETE** in roughly 5-10 minutes. In the Outputs tab, take note of the **ecrRepository** and **spotFleetName** values; you will need these in the next lab.

![](/images/ecs-deep-learning-workshop/cf-complete.png)

Note that when your stack moves to a **CREATE_COMPLETE** status, you won't necessarily see EC2 instances yet. If you don't, go to the EC2 console and click on **Spot Requests**. There you will see the pending or fulfilled spot requests. Once they are fulfilled, you will see your EC2 instances within the EC2 console.

If there was an error during the stack creation process, CloudFormation will rollback and terminate. You can investigate and troubleshoot by looking in the Events tab. Any errors encountered during stack creation will appear in the event log.
