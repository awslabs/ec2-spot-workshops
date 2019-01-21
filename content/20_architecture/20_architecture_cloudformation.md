+++
title = "CloudFormation Template"
chapter = false
weight = 20
+++

### Let's Begin!  

#### 1\. Launch the CloudFormation stack

To save time on the initial setup, a CloudFormation template will be used to create the Amazon VPC with subnets in two Availability Zones, as well as the IAM policies and roles, and security groups.

1\.  Go ahead and launch the CloudFormation stack. You can check it out from GitHub, or grab the [template directly](https://github.com/awslabs/ec2-spot-labs/blob/master/workshops/ec2-spot-fleet-web-app/ec2-spot-fleet-web-app.yaml). I use the stack name “ec2-spot-fleet-web-app“, but feel free to use any name you like. Just remember to change it in the instructions.

```bash
$ git clone https://github.com/awslabs/ec2-spot-labs.git
```

```bash
$ aws cloudformation create-stack --stack-name ec2-spot-fleet-web-app --template-body file://ec2-spot-labs/workshops/ec2-spot-fleet-web-app/ec2-spot-fleet-web-app.yaml --capabilities CAPABILITY_IAM --region us-east-1
```

You should receive a StackId value in return, confirming the stack is launching.

```bash
{
	"StackId": "arn:aws:cloudformation:us-east-1:123456789012:stack/spot-fleet-web-app/083e7ad0-0ade-11e8-9e36-500c219ab02a"
}
```

2\. Wait for the status of the CloudFormation stack to move to <span style="color:green">**CREATE_COMPLETE**</span> before moving on to the next step. You will need to reference the **Output** values from the stack in the next steps.


{{% notice note %}}
Read the [contents of the CloudFormation Template](https://github.com/awslabs/ec2-spot-labs/blob/master/workshops/ec2-spot-fleet-web-app/ec2-spot-fleet-web-app.yaml) to get an understanding on how Infrastructure as Code can be deployed on AWS. You can [read more about CloudFormation here](https://aws.amazon.com/cloudformation/)
{{% /notice %}}