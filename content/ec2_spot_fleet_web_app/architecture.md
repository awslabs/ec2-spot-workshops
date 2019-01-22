+++
title = "Architecture"
weight = 20
+++

### Architecture

In this workshop, you will deploy the following:

* An Amazon Virtual Private Cloud (Amazon VPC) with subnets in two Availability Zones
* An Application Load Balancer (ALB) with a listener and target group
* An Amazon CloudWatch Events rule
* An AWS Lambda function
* An Amazon Simple Notification Service (SNS) topic
* Associated IAM policies and roles for all of the above
* An Amazon EC2 Spot Fleet request diversified across both Availability Zones using a couple of recent Spot Fleet features: Elastic Load Balancing integration and Tagging Spot Fleet Instances

When any of the Spot Instances receives an interruption notice, Spot Fleet sends the event to CloudWatch Events. The CloudWatch Events rule then notifies both targets, the Lambda function and SNS topic. The Lambda function detaches the Spot Instance from the Application Load Balancer target group, taking advantage of a full two minutes of connection draining before the instance is interrupted. The SNS topic also receives a message, and is provided as an example for the reader to use as an exercise.

{{% notice tip %}}
Have SNS to send you an email or an SMS message.
{{% /notice %}}


Here is a diagram of the resulting architecture:

![Architecture Description](/images/ec2_spot_fleet_web_app/interruption_notices_arch_diagram.jpg)

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