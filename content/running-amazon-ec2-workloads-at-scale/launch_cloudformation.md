+++
title = "Setup with CloudFormation"
weight = 30
+++

### Launch the CloudFormation stack

To save time on the initial setup, a CloudFormation template will be used to create the Amazon VPC with subnets in two Availability Zones, as well as various supporting resources including IAM policies and roles, security groups, an S3 bucket, an EFS file system, and a Cloud9 IDE environment for you to run the steps for the workshop in.

#### To create the stack

1. You can view and download the CloudFormation template from GitHub [here](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/running-amazon-ec2-workloads-at-scale/running-amazon-ec2-workloads-at-scale.yaml).
                                                                            
1. Take a moment to review the CloudFormation template so you understand the resources it will be creating.

1. Browse to the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation).
{{% notice note %}}
Make sure you are in AWS Region designated by the facilitators of the workshop
{{% /notice %}}
1. Click **Create stack**.

1. In the **Specify template** section, select **Upload a template file**. Click **Choose file** and, select the template you downloaded in step 1.

1. Click **Next**.

1. In the **Specify stack details** section, enter *runningAmazonEC2WorkloadsAtScale* as **Stack name**. (You can use a different name if you want to, but make sure you update it when setting the $stack_name environment variable below. NOTE: The stack name cannot contain spaces.)

1. [Optional] In the **Parameters** section, optionally change the **sourceCidr** to restrict instance ssh/http access and load balancer http access.

1. Click **Next**.

1. In **Configure stack options**, you don't need to make any changes.

1. Click **Next**.

1. Review the information for the stack. At the bottom under **Capabilities**, select **I acknowledge that AWS CloudFormation might create IAM resources**. When you're satisfied with the settings, click **Create stack**.

#### Monitor the progress of stack creation

It will take roughly 5 minutes for the stack creation to complete.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack in the list.

1. In the stack details pane, click the **Events** tab. You can click the refresh button to update the events in the stack creation.
 
The **Events** tab displays each major step in the creation of the stack sorted by the time of each event, with latest events on top.

The **CREATE\_IN\_PROGRESS** event is logged when AWS CloudFormation reports that it has begun to create the resource. The **CREATE_COMPLETE** event is logged when the resource is successfully created.

When AWS CloudFormation has successfully created the stack, you will see the **CREATE_COMPLETE** event at the top of the Events tab:

#### Use your stack resources

In this workshop, you'll need to reference the resources created by the CloudFormation stack. You can see the resources that have been created on the [AWS Cloudformation console](https://console.aws.amazon.com/cloudformation). On the **Resources** pane you can see the whole list of resources that have been created. The template does also have a list **Outputs" with resource identifiers that will be used throughout the workshop. To avoid having you copy'ing and pasting them we will load those values as environment variables. 

	```
        export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
        export stack_name=runningAmazonEC2WorkloadsAtScale
        export code_deploy_bucket=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`codeDeployBucket`].OutputValue' --output text)
        export file_system=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`fileSystem`].OutputValue' --output text)
        export instance_profile=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`instanceProfile`].OutputValue' --output text)
        export event_rule=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`eventRule`].OutputValue' --output text)
        export vpc=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`vpc`].OutputValue' --output text)
        export instance_sg=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`instanceSecurityGroup`].OutputValue' --output text)
        export db_sg=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`dbSecurityGroup`].OutputValue' --output text)
        export lb_sg=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`loadBalancerSecurityGroup`].OutputValue' --output text)
        export lambda_function=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`lambdaDunction`].OutputValue' --output text)
        export sns_topic=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`snsTopic`].OutputValue' --output text)
        export public_subnet1=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`publicSubnet1`].OutputValue' --output text)
        export public_subnet2=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`publicSubnet2`].OutputValue' --output text)
        export db_subnet_group=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`dbSubnetGroup`].OutputValue' --output text)
        export code_deploy_service_role=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`codeDeployServiceRole`].OutputValue' --output text)
    ```