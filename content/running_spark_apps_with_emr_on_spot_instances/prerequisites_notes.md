---
title: "Prerequisites and initial steps"
weight: 10
draft: true
---
#### General requirements and notes:\

1. To complete this workshop, have access to an AWS account with administrative permissions. An IAM user with the  administrator access IAM policy applied to it (arn:aws:iam::aws:policy/AdministratorAccess) would do great.
2. This workshop is self-paced. The instructions will  be given using the AWS Command Line Interface (CLI) (https://aws.amazon.com/cli) or the AWS Management Console. 
3. While the workshop provides step by step instructions, **please do take a moment to look around and understand what is happening at each step** as this will enhance your learning experience. The workshop is meant as a getting started guide, but you will learn the most by digesting each of the steps and thinking about how they would apply in your own environment and in your own organization. You can even consider experimenting with the steps to challenge yourself.


#### Preparation steps:\

1. Create an S3 bucket for your Spark application code (which will be provided later) and the EMR application's results. Using the AWS CLI, run: **aws s3 mb s3://\<unique-bucket-name\>** or create a new bucket using the AWS Management Console.
2. Deploy a new VPC that will be used to run your EMR cluster in the workshop.\
a. Open the ["Modular and Scalable VPC Architecture Quick stage page"] (https://aws.amazon.com/quickstart/architecture/vpc/) and go to the "How to deploy" tab, Click the ["Launch the Quick Start"] (https://fwd.aws/mm853) link.\
b. Select your desired region to run the workshop from the top right corner of the AWS Management Console and click **Next**.\
c. Provide a name for the stack or leave it as **Quick-Start-VPC**.\
d. Under **Availability Zones**, select three availabliity zones from the list, and set the **Number of Availabliity Zones** to **3**.\
e. Under **Create private subnets** select **false**.\
f. click **Next** and again **Next** in the next screen.\
g. Click **Create stack**.\
The stack creation should take under 2 minutes and the status of the stack will be **CREATE_COMPLETE**.

Congratulations! you completed the pre-requisites to start the workshop, you now have a VPC to run your EMR cluster in, and an S3 bucket for the Spark application code and the results. Continue to the next step to proceed in the workshop.