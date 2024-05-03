+++
title = "Clone the GitHub repo"
weight = 60
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Amazon EC2 Auto Scaling Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/0a0fe16c-8693-4d23-8679-4f1701dbd2b0/en-US)**.

{{% /notice %}}


In order to execute the steps in the workshop, you'll need to clone the workshop GitHub repo.


1. In the Cloud9 IDE terminal, run the following command:

	```
	git clone https://github.com/awslabs/ec2-spot-workshops.git
	```    
	
1. Change into the workshop directory:

	```
	cd ec2-spot-workshops/workshops/ec2-auto-scaling-with-multiple-instance-types-and-purchase-options
	```    

1. Feel free to browse around. You can also browse the directory structure in the **Environment** tab on the left, and even edit files directly there by double clicking on them.

1. During the workshop, you will need to modify the configuration files to refer to the identifiers of the resources created by the CloudFormation stack you deployed. To reduce copy and paste across the CloudFormation console and the Cloud9 environment, we will load the CloudFormation Stack **Outputs** to environment variables. During the workshop the instructions will provide [sed](https://linux.die.net/man/1/sed) commands to populate configuration files. Make sure you open them on the Cloud9 editor to review the files and understand the settings of the resources you will be launching.
	
	First, configure the stack_name environment variable with the name of your CloudFormation template. For example, if the name of your stack is **myEC2Workshop** run the following command:
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
	awsRegionId : eu-west-1
	instanceProfile : arn:aws:iam::012345678910:instance-profile/running-workloads-at-scale-instanceProfile-1AWCE0JMHIRI4
	vpc : vpc-0f0a34a6f7f3f999f
	instanceSecurityGroup : sg-0ce120b3dde73b545
	publicSubnet2 : subnet-0278bf57661c1f82b
	publicSubnet1 : subnet-0f7bec73da5be90c2
	cloud9Environment : cloud9Environment-C8KgzeALZ6w0
	loadBalancerSecurityGroup : sg-0b6df7c3ed7c9118d
	```      