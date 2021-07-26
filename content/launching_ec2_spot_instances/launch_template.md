---
title: "Creating a Launch Template"
date: 2021-07-07T08:51:33Z
weight: 20
---

The first step we will do in this wokshop is creating a launch template. 
We will use the Launch Template on the rest of the steps in the workshop.
Launch Templates enable you to define
launch parameters so that you do not have to specify them every time you
launch an instance. For example, a Launch Template can contain the AMI
ID, instance type, and network settings that you'd use to launch
instances. When you launch an instance using the Amazon EC2 console, an
AWS SDK, or a command line tool, you can specify the Launch Template to
use.

Launch Templates are immutable. Once created they cannot be changed, however they can be
versioned. Every change to the Launch Template can be tracked and you can select which version to use as new changes are applied to the template. This can be used for governance as well as to manage approved upgrades to for example Auto Scaling Groups. If you do not specify a version, the default version is used. 


{{% notice warning %}}
Note: During this workshop, we will use your account default VPC to create the instances. If your account does not have a default VPC you can create or nominate one with following [this link](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html#create-default-vpc)
{{% /notice %}}

**Environment variables definition**

During the workshop we may need to gather some data into environment variables so we can reference them later on to replace some of the entries in the commands. 

1. **Gathering Subnet information**: Run the following commands to retrieve your default VPC and then its subnets.
    To learn more about these APIs, see [describe vpcs](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html) and [describe subnets](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html).

    ```
    export VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true | jq -r '.Vpcs[0].VpcId')
    export SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="${VPC_ID}")
    export SUBNET_1=$((echo $SUBNETS) | jq -r '.Subnets[0].SubnetId')
    export SUBNET_2=$((echo $SUBNETS) | jq -r '.Subnets[1].SubnetId')
    export SUBNET_3=$((echo $SUBNETS) | jq -r '.Subnets[2].SubnetId')
    ```

2. **Gathering the AMI ID**: To retrieve a valid AMI identifier you can perform the following call. It will store the first returned AMI identifier based on some filters.
    You can modify those filters as described in [describe images](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html).

    ```
    export AMI_ID=$(aws ec2 describe-images --region "${AWS_REGION}" --filters Name=owner-alias,Values=amazon Name=architecture,Values=x86_64 Name=name,Values=amzn2-ami-hvm* | jq -r '.Images[0].ImageId')
    ```

3. **Setting up the instance type**: Now you have to specify an instance type that is compatible with the chosen AMI. For
    more information, see [Instance
    Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html).

    ```
    export INSTANCE_TYPE="c5.large"
    ```

**Launch template creation**

Create the Launch Template from the command line as follows. 
You can which other parameters Launch Templates could take [here](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-launch-template.html).

```bash
aws ec2 create-launch-template --launch-template-name TemplateForWebServer --version-description 1 --launch-template-data "{\"ImageId\":\"${AMI_ID}\",\"InstanceType\":\"${INSTANCE_TYPE}\"}"
```

**Example return**

```bash
{
    "LaunchTemplate": {
        "CreateTime": "2019-02-14T05:53:07.000Z",
        "LaunchTemplateName": "TemplateForWebServer",
        "DefaultVersionNumber": 1,
        "CreatedBy": "arn:aws:iam::123456789012:user/xxxxxxxx",
        "LatestVersionNumber": 1,
        "LaunchTemplateId": "lt-00ac79500cbd56d11"
    }
}
```

As the last step of this section, you are going to perform an additional API call to retrieve the identifier of the launch template that was just created and store it in an environment variable. we will use this ID when creating Auto Scaling Groups, Spot Fleets, EC2 Fleets, etc.

```
export LAUNCH_TEMPLATE_ID=$(aws ec2 describe-launch-templates --filters Name=launch-template-name,Values=TemplateForWebServer | jq -r '.LaunchTemplates[0].LaunchTemplateId')
```

Well done ! we have created a Launch Template and stored into environment variables all the details that we will need to refer to it in the next steps. Let's now move to Auto Scaling Groups.
