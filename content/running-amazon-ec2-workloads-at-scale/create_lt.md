+++
title = "Create an EC2 launch template"
weight = 70
+++

EC2 Launch Templates reduce the number of steps required to create an instance by capturing all launch parameters within one resource. 

You can create a launch template that contains the configuration information to launch an instance. Launch templates enable you to store launch parameters so that you do not have to specify them every time you launch an instance. For example, a launch template can contain the AMI ID, instance type, and network settings that you typically use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the launch template to use. 

A Launch Template is similar to a launch configuration, in that it specifies instance configuration information; however they provide additional features like versioning and enable you to use the latest features of Amazon EC2 and Auto Scaling Groups with multiple instance types and purchase options.  You can learn more about Launch Templates [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)

We are going to create a launch template to specify configuration parameters for launching instances in this workshop. 

One of the settings of a launch template is the [User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html). User data passes a shell script or [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) directives to perform configuration actions when an instance is launched. In this workshop you will pass user data to the instances launched to install packages ([amazon-efs-utils](https://docs.aws.amazon.com/efs/latest/ug/using-amazon-efs-utils.html) among others), install the AWS CodeDeploy agent and mount the EFS filesystem that will be used by Koel to store our audio files. 

The file **user-data.txt** contains the cloud-init directives that will be executed upon instance launch. The file needs to be updated to the region you are using for the workshop, as well as the filesystem that has been previously created by CloudFormation. Execute the following command to update the file:

```
sed -i.bak -e "s/%awsRegionId%/$AWS_REGION/g" -e "s/%fileSystem%/$file_system/g" user-data.txt
```

Take the time to look at the user data and see the actions that will be performed to bootstrap the instances.

The **launch-template-data.json** contains the configuration of the launch template that you will create for this workshop. The launch template specifies the AMI from which the instances will be launched, an Instance Profile that allows the instance access CodeDeploy S3 buckets and run [SSM commands](https://docs.aws.amazon.com/systems-manager/latest/userguide/execute-remote-commands.html) (that will be used at a later stage to simulate load), and the security group that was created by CloudFormation; as well as the user data base64 encoded. To populate the file execute the following command:

```
# First, this command looks up the latest Amazon Linux 2 AMI
export ami_id=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images |sort_by(.CreationDate) | last(.[]).ImageId')
sed -i.bak -e "s#%instanceProfile%#$instance_profile#g" -e "s/%instanceSecurityGroup%/$instance_sg/g" -e "s#%ami-id%#$ami_id#g" -e "s#%UserData%#$(cat user-data.txt | base64 --wrap=0)g" launch-template-data.json
```

Take the time to look at the launch-template-data.json file; and then create the launch template. 

```
aws ec2 create-launch-template --launch-template-name runningAmazonEC2WorkloadsAtScale --version-description dev --launch-template-data file://launch-template-data.json
```

You should see an output similar to the following:

```
{
    "LaunchTemplate": {
        "LatestVersionNumber": 1, 
        "LaunchTemplateId": "lt-04c1ee7ef0e1e6b3b", 
        "LaunchTemplateName": "runningAmazonEC2WorkloadsAtScale", 
        "DefaultVersionNumber": 1, 
        "CreatedBy": "arn:aws:sts::012345678912:assumed-role/runningEC2WorkloadsAtScale-instanceRole-E5CPATQAY4O0/i-xxxxxxx", 
        "CreateTime": "2019-11-05T13:27:58.000Z"
    }
}
```

Now that the launch template is created, browse to the [Launch Templates console](https://console.aws.amazon.com/ec2/v2/home?#LaunchTemplates:sort=launchTemplateId) and check out your newly created launch template. Verify that the launch template has been correctly created:

* Verify that the contents of the launch template are correct:

	```
	aws ec2 describe-launch-template-versions  --launch-template-name runningAmazonEC2WorkloadsAtScale
	```

* Verify that the contents of the launch template user data are correct:

	```
	aws ec2 describe-launch-template-versions  --launch-template-name runningAmazonEC2WorkloadsAtScale --output json | jq -r '.LaunchTemplateVersions[].LaunchTemplateData.UserData' | base64 --decode
	```