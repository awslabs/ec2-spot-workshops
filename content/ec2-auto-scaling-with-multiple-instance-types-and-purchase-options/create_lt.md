+++
title = "Create an EC2 launch template"
weight = 70
+++

{{%expand "You will use a Launch Template to specify configuration parameters for launching instances with EC2 Auto Scaling in this workshop. Click here to learn more about Launch Templates" %}}
A launch template specifies EC2 instance configuration information: the ID of the Amazon Machine Image (AMI), the instance type, a key pair, security groups, and the other parameters that you use to launch EC2 instances. This configuration can later be used to launch instances from that template via the EC2 API, via EC2 Auto Scaling groups and other AWS services. Launch Templates are similar to Auto Scaling [launch configurations](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html); however, defining a launch template instead of a launch configuration allows you to have multiple versions of a template. With versioning, you can create a subset of the full set of parameters and then reuse it to create other templates or template versions. For example, you can create a default template that defines common configuration parameters and allow the other parameters to be specified as part of another version of the same template.

It's recommended that you create Auto Scaling groups from launch templates to ensure that you're accessing the latest features and improvements. Note that not all Auto Scaling group features are available in Launch Configurations. For example, with launch configurations, you cannot create an Auto Scaling group that launches both Spot and On-Demand Instances or that specifies multiple instance types or multiple launch templates. You must use a launch template to configure these features. For more information, see [Auto Scaling groups with multiple instance types and purchase options](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html). 
{{% /expand %}}

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