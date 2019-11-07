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
	```
	export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
	export stack_name=runningAmazonEC2WorkloadsAtScale
	export code_deploy_bucket=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`codeDeployBucket`].OutputValue' --output text)
	export file_system=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`fileSystem`].OutputValue' --output text)
	export instance_profile=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`instanceProfile`].OutputValue' --output text)
	export event_rule=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`eventRule`].OutputValue' --output text)
	export vpc=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`vpc`]	.OutputValue' --output text)
	export instance_sg=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`instanceSecurityGroup`].OutputValue' --output text)
	export db_sg=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`dbSecurityGroup`].OutputValue' --output text)
	export lb_sg=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`loadBalancerSecurityGroup`].OutputValue' --output text)
	export lambda_function=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`lambdaDunction`].OutputValue' --output text)
	export sns_topic=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`snsTopic`].OutputValue' --output text)
	export public_subnet1=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`publicSubnet1`].OutputValue' --output text)
	export public_subnet2=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`publicSubnet2`].OutputValue' --output text)
	export db_subnet_group=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`dbSubnetGroup`].OutputValue' --output text)
	export code_deploy_service_role=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?	OutputKey==`codeDeployServiceRole`].OutputValue' --output text)
	```