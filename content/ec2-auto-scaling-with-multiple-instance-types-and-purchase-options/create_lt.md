+++
title = "Create an EC2 launch template"
weight = 70
+++

EC2 Launch Templates reduce the number of steps required to create an instance by capturing all launch parameters within one resource. 

You can create a launch template that contains the configuration information to launch an instance. Launch templates enable you to store launch parameters so that you do not have to specify them every time you launch an instance. For example, a launch template can contain the AMI ID, instance type, and network settings that you typically use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the launch template to use.

{{% notice note %}}
You might be wondering how a [Launch Template](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html) is different from a [Launch Configuration](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html). They are similar in that they both specify instance configuration information; however Launch Templates provide additional features like versioning and enable you to use the latest features of Amazon EC2 and Auto Scaling Groups with multiple instance types and purchase options.  You can learn more about Launch Templates [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)
{{% /notice %}}

You'll use a launch template to specify configuration parameters for launching instances in this workshop.
	
1. Open **launch-template-data.json** on the Cloud9 editor and examine the configuration, you will notice some of the parameters have a placeholder value **%variableName%**: %instanceProfile%, %instanceSecurityGroup% and %ami-id%.
![Cloud9 Editor](/images/ec2-auto-scaling-with-multiple-instance-types-and-purchase-options/cloud9-editor.jpg)

1. The variable %ami-id% should contain the latest Amazon Linux 2 AMI, and instanceProfile and instanceSecurityGroup need to be populated with the resources created by your CloudFormation stack; which are available as Stack Outputs. We can pull the latest Amazon Linux 2 AMI with the AWS CLI, and as we have loaded our CloudFormation stack outputs as environment variables on a previous step, for convenience we can use the following commands to update your configuration file:

    ```bash
    # First, this command looks up the latest Amazon Linux 2 AMI
    export ami_id=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images |   sort_by(.CreationDate) | last(.[]).ImageId')

    sed -i.bak -e "s#%instanceProfile%#$instanceProfile#g" -e "s/%instanceSecurityGroup%/$instanceSecurityGroup/g" -e "s#%ami-id%#$ami_id#g" -e "s#%UserData%#$(cat user-data.txt | base64 --wrap=0)#g" launch-template-data.json

    ```

1. Your configuration file should now have the variables populated. If you don't see the file updated on the Cloud9 editor, click on it and you will get a message box indicating the file has changed. In that case, click on **Keep remote**.

1. Create the launch template from the launch template config you just updated:

	```
	aws ec2 create-launch-template --launch-template-name myEC2Workshop --launch-template-data file://launch-template-data.json
	```
	
1. Browse to the [Launch Templates console](https://console.aws.amazon.com/ec2/v2/home?#LaunchTemplates:sort=launchTemplateId) and check out your newly created launch template.

1. Verify that the contents of the launch template are correct:

	```
	aws ec2 describe-launch-template-versions --launch-template-name myEC2Workshop
	```

1. Take a look at the user-data script configured on the launch template to understand what will be installed on the instances while being bootstrapped. 

	```
	aws ec2 describe-launch-template-versions  --launch-template-name myEC2Workshop --output json | jq -r '.LaunchTemplateVersions[].LaunchTemplateData.UserData' | base64 --decode
	```