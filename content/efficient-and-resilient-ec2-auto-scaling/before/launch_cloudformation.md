+++
title = "Environment Setup"
weight = 30
+++

{{% notice warning %}}
If you are at an AWS Event, **please skip this step!**
{{% /notice %}}

To save time on the initial setup, a **CloudFormation** template will be used to create  various supporting resources including IAM policies and roles, EC2 Launch Template, VPC, Subnets and a **Cloud9** IDE environment for you to run the steps for the workshop in.

#### Deploy CloudFormation Stack

1. You can view and download the CloudFormation template from GitHub [here](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/efficient-and-resilient-ec2-auto-scaling/files/efficient-auto-scaling-quickstart-cnf.yml). **Tip:** Right click the link and Save Link As.. to download the file.
                                                                            
2. Take a moment to review the CloudFormation template so you understand the resources it will be creating.

3. Browse to the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation).

4. Click **Create stack**, then **With new resources(standard)**.

5. In the **Specify template** section, select **Upload a template file**. Click **Choose file** and, select the template you downloaded in step 1.

6. Click **Next**.

7. In the **Specify stack details** section, enter a **Stack name**. For example, use **myEC2Workshop**. The stack name cannot contain spaces.

8. [Optional] In the **Parameters** section, optionally change the **C9InstanceType** to change the EC2 instance type for the Cloud9 environment.

9. Click **Next**.

10. In **Configure stack options**, you don't need to make any changes.

11. Click **Next**.

12. Review the information for the stack. At the bottom under **Capabilities**, select **I acknowledge that AWS CloudFormation might create IAM resources**. When you're satisfied with the settings, click **Create stack**.

#### Monitor the progress of stack creation

It will take roughly 5 minutes for the stack creation to complete.
{{% notice info %}}
**If you're not at an AWS event,** you should expect the CloudFormation stack to be ready within **45 minutes** as the bootstrap script finishes the environment setup and the CloudWatch data becomes available.
{{% /notice %}}


1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack in the list.
1. In the stack details pane, click the **Events** tab.
2. Click the refresh button to update the events in the stack creation
3. When AWS CloudFormation has successfully created the stack, you will see the **CREATE_COMPLETE** event at the top of the Events tab.
4. In the stack details pane, click the **Outputs** tab.
5. Click on the url of the AWS Cloud9 environment, it's the value of **Cloud9IDE** in the CloudFormation stack outputs.

![cloudformation-create-complete](/images/efficient-and-resilient-ec2-auto-scaling/cloudformation-create-complete.png)