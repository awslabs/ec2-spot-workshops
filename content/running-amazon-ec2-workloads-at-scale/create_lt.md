+++
title = "Create an EC2 launch template"
weight = 70
+++

EC2 Launch Templates reduce the number of steps required to create an instance by capturing all launch parameters within one resource. 

You can create a launch template that contains the configuration information to launch an instance. Launch templates enable you to store launch parameters so that you do not have to specify them every time you launch an instance. For example, a launch template can contain the AMI ID, instance type, and network settings that you typically use to launch instances. When you launch an instance using the Amazon EC2 console, an AWS SDK, or a command line tool, you can specify the launch template to use. 

{{% notice note %}}
You might be wondering how a [Launch Template](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html) is different from a [Launch Configuration](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html). They are similar in that they both specify instance configuration information; however Launch Templates provide additional features like versioning and enable you to use the latest features of Amazon EC2 and Auto Scaling Groups with multiple instance types and purchase options.  You can learn more about Launch Templates [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)
{{% /notice %}}

You will create a launch template to specify configuration parameters for launching instances in this workshop. 

1. Execute the following command to update the file **user-data.txt** with the resources created by the CloudFormation template. The file contains the [User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) with the [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) directives that will be executed upon instance launch. 

    ```bash
    sed -i.bak -e "s/%awsRegionId%/$AWS_REGION/g" -e "s/%fileSystem%/$file_system/g" user-data.txt
    ```
1. Take a moment to look at the user data script to see the bootstrapping actions that is performing. 

1. Execute the below command to update the **launch-template-data.json** file with the base64 encoded user data script, the resource ids created by the CloudFormation template and the latest Amazon Linux 2 AMI. 

    ```
    # First, this command looks up the latest Amazon Linux 2 AMI
    export ami_id=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images |   sort_by(.CreationDate) | last(.[]).ImageId')

    sed -i.bak -e "s#%instanceProfile%#$instanceProfile#g" -e "s/%instanceSecurityGroup%/$instanceSecurityGroup/g" -e "s#%ami-id%#$ami_id#g" -e "s#%UserData%#$(cat user-data.txt | base64 --wrap=0)#g" launch-template-data.json
    ```

1. Take the time to look at the launch-template-data.json file; and then execute the below command to create the Launch template from the configuration file you have updated.

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