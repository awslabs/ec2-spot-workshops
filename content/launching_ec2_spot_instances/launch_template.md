---
title: "Creating a Launch Template"
date: 2021-07-07T08:51:33Z
weight: 40
---

## Creating a Launch Template

You can create a Launch Template that contains the configuration
information to launch an instance. Launch Templates enable you to store
launch parameters so that you do not have to specify them every time you
launch an instance. For example, a Launch Template can contain the AMI
ID, instance type, and network settings that you typically use to launch
instances. When you launch an instance using the Amazon EC2 console, an
AWS SDK, or a command line tool, you can specify the Launch Template to
use.

For each Launch Template, you can create one or more numbered Launch Template versions. Each version can have different launch parameters. When you launch an instance from a Launch Template, you can use any version of the Launch Template. If you do not specify a version, the default version is used. You can set any version of the Launch Template as the default version.

**Environment variables definition**

You will need to gather some data and store it in environment variables that will later be referenced from the API calls.

{{% notice warning %}}
If you have deleted your default VPC, find the identifier of the VPC that you want to use and replace the first block of code with this: `export VPC_ID="vpc-id"` where *vpc-id* is the identifier of your VPC.
{{% /notice %}}

1. **Gathering Subnet information**: Run the following commands to retrieve your default VPC and then its subnets.
    To learn more about these APIs, see [describe vpcs](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html) and [describe subnets](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html).

    ```bash
    export VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true | jq -r '.Vpcs[0].VpcId')
    export SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="${VPC_ID}")
    export SUBNET_1=$((echo $SUBNETS) | jq -r '.Subnets[0].SubnetId')
    export SUBNET_2=$((echo $SUBNETS) | jq -r '.Subnets[1].SubnetId')
    export SUBNET_3=$((echo $SUBNETS) | jq -r '.Subnets[2].SubnetId')
    ```

2. **Gathering the AMI ID**: To retrieve a valid AMI identifier you can perform the following call. It will store the first returned AMI identifier based on some filters.
    You can modify those filters as described in [describe images](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html).

    ```bash
    export AMI_ID=$(aws ec2 describe-images --region "${AWS_REGION}" --filters Name=owner-alias,Values=amazon Name=architecture,Values=x86_64 Name=name,Values=amzn2-ami-hvm* | jq -r '.Images[0].ImageId')
    ```

3. **Setting up the instance type**: Now you have to specify an instance type that is compatible with the chosen AMI. For
    more information, see [Instance
    Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html).

    ```bash
    export INSTANCE_TYPE="c5.large"
    ```

**Launch template creation**

Create the Launch Template from the command line as follows:
You can check all the accepted parameters here: [create launch template](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-launch-template.html).

```bash
aws ec2 create-launch-template --launch-template-name TemplateForWebServer --version-description 1 --launch-template-data "{\"NetworkInterfaces\":[{\"DeviceIndex\":0,\"SubnetId\":\"${SUBNET_1}\"}],\"ImageId\":\"${AMI_ID}\",\"InstanceType\":\"${INSTANCE_TYPE}\"}"
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

Finally, you are going to perform an additional API call to retrieve the identifier of the launch template that was just created and store it in an environment variable:

```bash
export LAUNCH_TEMPLATE_ID=$(aws ec2 describe-launch-templates --filters Name=launch-template-name,Values=TemplateForWebServer | jq -r '.LaunchTemplates[0].LaunchTemplateId')
```

The environment is now ready and you can start using this Launch Template to launch EC2 Spot instances in different ways.
