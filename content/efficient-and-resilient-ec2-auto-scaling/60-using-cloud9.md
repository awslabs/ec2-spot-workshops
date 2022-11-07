+++
title = "Cloud9 Environment Setup"
weight = 60
+++
AWS Cloud9 comes with a terminal that includes sudo privileges to the managed Amazon EC2 instance that is hosting your development environment and a preauthenticated AWS Command Line Interface. This makes it easy for you to quickly run commands and directly access AWS services.

An AWS Cloud9 environment was launched as a part of the CloudFormation stack (you may have noticed a second CloudFormation stack created by Cloud9).

{{% notice note %}}
You'll be using this Cloud9 environment to execute the steps in the workshop, and not the local command line on your computer.
{{% /notice %}}

1. Find the url of the AWS Cloud9 environment by checking the value of **Cloud9IDE** in the CloudFormation stack outputs.
2. Click on the link, this should take you to the provisioned Cloud9 environment.

3. **Or** sign in to the [AWS Cloud9 console](https://console.aws.amazon.com/cloud9/home).

4. Find the Cloud9 environment in **Your environments**, and click **Open IDE**.
{{% notice note %}}
Please make sure you are using the Cloud9 environment created by the workshop CloudFormation stack!
{{% /notice %}}

1. Take a moment to get familiar with the Cloud9 environment. You can even take a quick tour of Cloud9 [here](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html#tutorial-tour-ide) if you'd like.

#### Let's get started with the environment setup you will need for this workshop:

1. Feel free to browse around. You can also browse the directory structure in the **Environment** tab on the left, and even edit files directly there by double clicking on them.
2. Check the folders in left navigation, if it doesn't have folder named **ec2-spot-workshops**, wait for few more minutes till the bootstrap script finishes the environment setup.
3. **Don't** proceed with next steps till folder **ec2-spot-workshops** shows in left navigation.
4. In the **Cloud9 IDE** terminal, change into the workshop directory:

	```
	cd ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling
	```    

3. During the workshop, you will need to modify the configuration files to refer to the identifiers of the resources created by the CloudFormation stack you deployed. To reduce copy and paste across the CloudFormation console and the Cloud9 environment, we will load the CloudFormation Stack **Outputs** to environment variables. During the workshop the instructions will provide [sed](https://linux.die.net/man/1/sed) commands to populate configuration files. Make sure you open them on the Cloud9 editor to review the files and understand the settings of the resources you will be launching.
	
	First, set the stack_name environment variable with the name you choose while creating the CloudFormation stack in the previous step. For example, if the name of your stack is **myEC2Workshop** run the following command:
	```bash
	export stack_name=myEC2Workshop

	```    

	Now, load the CloudFormation stack outputs on environment variables running the following command:
	```bash
	export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
	

	# load outputs to env vars
	for output in $(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[].OutputKey' --output text)
	do
    	export $output=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
    	eval "echo $output : \"\$$output\""
	done

	```    

	If successful, the output should be similar to the following:

	```bash
	PrivateSubnet1 : subnet-028e48cc979b4896c
	PrivateSubnet2 : subnet-0b29e19a108a3c69a
	Cloud9IDE : https://ap-southeast-2.console.aws.amazon.com/cloud9/ide/bcfdc605a9c64d5b8502cb547972af08?region=ap-southeast-2
	VPC : vpc-05b0e744df476e8d4
	```      