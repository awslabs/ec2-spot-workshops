+++
title = "Setup with CloudFormation"
weight = 50
+++

### Launch the CloudFormation stack

To save time on the initial setup, a **CloudFormation** template will be used to create  various supporting resources including IAM policies and roles, security groups, and a **Cloud9** IDE environment for you to run the steps for the workshop in.

#### To create the stack

**>>>>>[remove this note when you update the link for the cfn template in final PR]<<<<<**
1. You can view and download the CloudFormation template from GitHub [here](https://raw.githubusercontent.com/nadaahm/ec2-spot-workshops/nadaahm-asg-workshop-reinvent/content/efficient-and-resilient-ec2-auto-scaling/files/efficient-auto-scaling-quickstart-cnf.yml). **Tip:** Right click the link and Save Link As.. to download the file.
                                                                            
1. Take a moment to review the CloudFormation template so you understand the resources it will be creating.

1. Browse to the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation).
{{% notice info %}}
Make sure you are in AWS Region designated by the facilitators of the workshop
{{% /notice %}}
1. Click **Create stack**, then **With new resources(standard)**.

1. In the **Specify template** section, select **Upload a template file**. Click **Choose file** and, select the template you downloaded in step 1.

1. Click **Next**.

1. In the **Specify stack details** section, enter a **Stack name**. For example, use **myEC2Workshop**. The stack name cannot contain spaces.

1. [Optional] In the **Parameters** section, optionally change the **C9InstanceType** to change the EC2 instance type for the Cloud9 environment.

1. Click **Next**.

1. In **Configure stack options**, you don't need to make any changes.

1. Click **Next**.

1. Review the information for the stack. At the bottom under **Capabilities**, select **I acknowledge that AWS CloudFormation might create IAM resources**. When you're satisfied with the settings, click **Create stack**.

#### Monitor the progress of stack creation

It will take roughly 5 minutes for the stack creation to complete.

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack in the list.

1. In the stack details pane, click the **Events** tab.
2. Click the refresh button to update the events in the stack creation
3. When AWS CloudFormation has successfully created the stack, you will see the **CREATE_COMPLETE** event at the top of the Events tab.
4. In the stack details pane, click the **Outputs** tab.
5. Click on the url of the AWS Cloud9 environment, it's the value of **Cloud9IDE** in the CloudFormation stack outputs.

![cloudformation-create-complete](/images/efficient-and-resilient-ec2-auto-scaling/cloudformation-create-complete.png)