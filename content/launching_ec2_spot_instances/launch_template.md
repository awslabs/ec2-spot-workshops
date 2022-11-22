---
title: "Creating a Launch Template"
date: 2021-07-07T08:51:33Z
weight: 40
---

As a prerequisite step before creating EC2 Auto Scaling groups or EC2 Fleet, you create a [launch template](https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-templates.html). Launch templates enable you to define launch parameters so that you do not have to specify them every time you
launch an instance. It includes the ID of the Amazon Machine Image (AMI), the instance type, a key pair, security groups, and other parameters used to launch EC2 instances.

{{% notice note %}}
Note: During this workshop, we will use your account's default VPC to create the instances. If your account does not have a default VPC you can create or nominate one following [this link](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html#create-default-vpc)
{{% /notice %}}

### Creating a launch template

1. Create **launch-template-data.json** configuration file in CloudShell by running below commands. When you examine the configuration, you notice that **ImageId** parameter has a placeholder value `%ami-id%`, and **UserData** contains a base64 encoded Webserver install steps. Once you have created the launch template you can decode to see the script content.

```bash
cat << EOF > launch-template-data.json
{
  "ImageId": "%ami-id%",
  "TagSpecifications": [
    {
      "ResourceType": "instance",
      "Tags": [
        {
          "Key": "Name",
          "Value": "mySpotWorkshop"
        }
      ]
    }
  ],
  "UserData": "I2Nsb3VkLWNvbmZpZwpyZXBvX3VwZGF0ZTogdHJ1ZQpyZXBvX3VwZ3JhZGU6IGFsbAoKcGFja2FnZXM6CiAgLSBodHRwZAogIC0gY3VybAoKcnVuY21kOgogIC0gWyBzaCwgLWMsICJhbWF6b24tbGludXgtZXh0cmFzIGluc3RhbGwgLXkgZXBlbCIgXQogIC0gWyBzaCwgLWMsICJ5dW0gLXkgaW5zdGFsbCBzdHJlc3MtbmciIF0KICAtIFsgc2gsIC1jLCAiZWNobyBoZWxsbyB3b3JsZC4gTXkgaW5zdGFuY2UtaWQgaXMgJChjdXJsIC1zIGh0dHA6Ly8xNjkuMjU0LjE2OS4yNTQvbGF0ZXN0L21ldGEtZGF0YS9pbnN0YW5jZS1pZCkuIE15IGluc3RhbmNlLXR5cGUgaXMgJChjdXJsIC1zIGh0dHA6Ly8xNjkuMjU0LjE2OS4yNTQvbGF0ZXN0L21ldGEtZGF0YS9pbnN0YW5jZS10eXBlKS4gPiAvdmFyL3d3dy9odG1sL2luZGV4Lmh0bWwiIF0KICAtIFsgc2gsIC1jLCAic3lzdGVtY3RsIGVuYWJsZSBodHRwZCIgXQogIC0gWyBzaCwgLWMsICJzeXN0ZW1jdGwgc3RhcnQgaHR0cGQiIF0KCgo="
}
EOF
```

2. The variable %ami-id% should be replaced with the latest Amazon Linux 2 AMI. You pull the latest Amazon Linux 2 AMI ID and update the AMI Id in your configuration file by running following commands.
```bash
# First, this command looks up the latest Amazon Linux 2 AMI
export ami_id=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-kernel*gp2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)

sed -i.bak -e "s#%instanceProfile%#$instanceProfile#g" -e "s#%ami-id%#$ami_id#g" -e "s#%UserData%#$(cat user-data.txt | base64 --wrap=0)#g" launch-template-data.json
```

3. Create the launch template from the launch template config you just updated. You can check which other parameters Launch Templates could take [here](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-launch-template.html).

```
aws ec2 create-launch-template --launch-template-name TemplateForWebServer --launch-template-data file://launch-template-data.json
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
3. Take a look at the user-data script configured on the launch template to understand what is installed on the instances while being bootstrapped. 

```
aws ec2 describe-launch-template-versions  --launch-template-name TemplateForWebServer --output json | jq -r '.LaunchTemplateVersions[].LaunchTemplateData.UserData' | base64 --decode
```

4. As the last step of this section, you are going to perform an additional API call to retrieve the identifier of the Launch Template that was just created and store it in an environment variable. We will use this ID when creating Auto Scaling groups, Spot Fleets, EC2 Fleets, etc.
```
export LAUNCH_TEMPLATE_ID=$(aws ec2 describe-launch-templates --filters Name=launch-template-name,Values=TemplateForWebServer | jq -r '.LaunchTemplates[0].LaunchTemplateId')
```

Well done! You have created a Launch Template and stored into environment variables all the details that we will need to refer to it in the next steps. Let's now move to Auto Scaling groups.
