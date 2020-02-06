+++
title = "Clone the GitHub repo"
weight = 60
+++

In order to execute the steps in the workshop, you'll need to clone the workshop GitHub repo.


1. In the Cloud9 IDE terminal, run the following command:

	```
	git clone https://github.com/awslabs/ec2-spot-workshops.git
	```
	
1. Change into the workshop directory:

	```
	cd ec2-spot-workshops/workshops/running-amazon-ec2-workloads-at-scale
	```

1. Feel free to browse around. You can also browse the directory structure in the **Environment** tab on the left, and even edit files directly there by double clicking on them.


1. As you will neeed to modify the configuration files to refer to the identifiers of the resources created by the CloudFormation stack, run the following command to load the CloudFormation **Outputs** to environment variables. You will use these environment variables throughout the workshop to edit the files with *[sed](https://linux.die.net/man/1/sed)*.
	```bash
	export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
	export stack_name=runningAmazonEC2WorkloadsAtScale

	# load outputs to env vars
	for output in $(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[].OutputKey' --output text)
	do
	    export $output=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
	    eval "echo $output : \"\$$output\""
	done
	```
