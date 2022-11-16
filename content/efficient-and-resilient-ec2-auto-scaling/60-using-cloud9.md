+++
title = "Cloud9 Environment Setup"
weight = 60
+++

Now we have access to a **Cloud9** environment, let's start configuring it to use it for running this workshop steps.

**AWS Cloud9** comes with a terminal that includes sudo privileges to the managed Amazon EC2 instance that is hosting your development environment and a preauthenticated AWS Command Line Interface. This makes it easy for you to quickly run commands and directly access AWS services.


#### Configure Cloud9 environment:

1. From the last step, you should have a browser window open with the **Cloud9 IDE**, you can browse the directory structure in the **Environment** tab on the left, and even edit files directly there by double clicking on them.
2. Check the folders in left navigation, look for folder named **ec2-spot-workshops**.
{{% notice info %}}
You should expect the folder **ec2-spot-workshops** to be visible within **5 minutes** as the bootstrap script finishes the environment setup.
{{% /notice %}}
1. **Don't** proceed with next steps till folder **ec2-spot-workshops** shows in left navigation.
2. In the **Cloud9 IDE** terminal, change into the workshop directory:

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