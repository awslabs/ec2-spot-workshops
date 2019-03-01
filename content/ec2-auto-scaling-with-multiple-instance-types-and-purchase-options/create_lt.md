+++
title = "Create an EC2 launch template"
weight = 70
+++

EC2 Launch Templates reduce the number of steps required to create an instance by capturing all launch parameters within one resource. 

You can create a launch template that contains the configuration information to launch an instance. Launch templates enable you to store launch parameters so that you do not have to specify them every time you launch an instance. For example, a launch template can contain the AMI ID, instance type, and network settings that you typically use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the launch template to use.

You'll use a launch template to specify configuration parameters for launching instances in this workshop.
	
1. Edit **launch-template-data.json**.

1. Update the following values from the CloudFormation stack outputs: **%instanceProfile%** and **%instanceSecurityGroup%**.

1. Update **%ami-id%** with the AMI ID for the latest version of Amazon Linux 2 in the AWS region you launched. You can find the AMI ID by running the following command:

	```	
	aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId'
	```

1. Save the file.

1. Create the launch template from the launch template config you just saved:

	```
	aws ec2 create-launch-template --launch-template-name myEC2Workshop --launch-template-data file://launch-template-data.json
	```
	
1. Browse to the [Launch Templates console](https://console.aws.amazon.com/ec2/v2/home?#LaunchTemplates:sort=launchTemplateId) and check out your newly created launch template.

1. Verify that the contents of the launch template are correct:

	```
	aws ec2 describe-launch-template-versions --launch-template-name myEC2Workshop
	```

1. Verify that the contents of the launch template user data are correct:

	```
	aws ec2 describe-launch-template-versions  --launch-template-name myEC2Workshop --output json | jq -r '.LaunchTemplateVersions[].LaunchTemplateData.UserData' | base64 --decode
	```