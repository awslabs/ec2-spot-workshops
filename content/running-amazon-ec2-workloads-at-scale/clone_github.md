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


1. You will need to modify the configuration files in this workshop to refer to the identifiers of the resources created by the CloudFormation stack. To make this easier, we will load the CloudFormation **Outputs** to environment variables. These environment variables will be used throughout the workshop to edit the files with *[sed](https://linux.die.net/man/1/sed)*. If you have not used `runningAmazonEC2WorkloadsAtScale`as the name of your CloudFormation stack, make sure you update the stack_name variable to match your stack name.
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

	After executing the above commands you should see the CloudFormation stack outputs listed on your terminal as the following:
	```bash
	codeDeployBucket : running-at-scale-codedeploybucket-g1sy53g73ko0
	fileSystem : fs-38a6dabb
	instanceProfile : arn:aws:iam::123456789101:instance-profile/running-at-scale-instanceProfile-1DTQQUCMGIU9G
	eventRule : running-at-scale-eventRule-14TS7W590680Y
	vpc : vpc-04e37aea04c2de488
	instanceSecurityGroup : sg-0655496d3a6994056
	cloud9Environment : cloud9Environment-F48dIcjGd66j
	dbSecurityGroup : sg-05a351e4895604fd2
	loadBalancerSecurityGroup : sg-0b88cdbbeffb3823a
	awsRegionId : us-east-1
	lambdaFunction : running-at-scale-lambdaFunction-1SR2D6K0S1BU1
	snsTopic : arn:aws:sns:us-east-1:123456789101:running-at-scale-snsTopic-VOPFFD9IADN7
	publicSubnet2 : subnet-096d42d2a1b2a2db0
	dbSubnetGroup : running-at-scale-dbsubnetgroup-t25qeq64q246
	publicSubnet1 : subnet-0e367e32d2f35cc94
	codeDeployServiceRole : arn:aws:iam::123456789101:role/running-at-scale-codeDeployServiceRole-AFUU6QGYXOQH
	```

{{% notice info %}}
The automation to edit configuration files in this workshop is designed avoid excessive copy-pasting. The instructions provide commands that use **[sed](https://en.wikipedia.org/wiki/Sed)** to update placeholder values like this `%placeholder-value%` with the resource identifications (ids) created by the output of CloudFormation.  Regardless of the automation you are encouraged to read and understand the configuration files and confirm the changes applied.
{{% /notice %}}