+++
title = "...On your own"
weight = 30
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


### Running the workshop self-paced, in your own AWS account

{{% notice warning %}}
If you are at an AWS Event, **please skip this step!**
{{% /notice %}}

{{% notice warning %}}
To avoid unwanted costs in your account, don't forget to go through the **Cleanup step** when you finish the workshop, or if you deploy the CloudFormation template but don't complete the workshop.
{{% /notice %}}

{{% notice note %}}
To complete this workshop, you need access to an AWS account with administrative permissions. An IAM user with administrator IAM access policy (**arn:aws:iam::aws:policy/AdministratorAccess**) or equivalent IAM access policy is required.
{{% /notice %}}

#### Deploy CloudFormation Stack
To save time on the initial setup, you deploy a **CloudFormation** template to create various supporting resources including IAM policies and roles, EC2 Launch Template, VPC, Subnets and a Cloud9 IDE environment for you to run the steps for the workshop in.

1. You can view and download the CloudFormation template from GitHub [here](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/efficient-and-resilient-ec2-auto-scaling/files/efficient-auto-scaling-quickstart-cnf.yml). (**Tip:** `Right click` the link and `Save Link As`, to download the file.). Take a moment to review the CloudFormation template so you understand the resources it will be creating.
1. Browse to the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation) and click **Create stack**, then **With new resources(standard)**.
1. In the **Specify template** section, select **Upload a template file**. Click **Choose file** and, select the template you downloaded in step 1 and click **Next**.
1. In the **Specify stack details** section, enter a **Stack name** and click **Next**. (**Tip:** The stack name cannot contain space, use `myEC2Workshop` for example.)
1. In **Configure stack options**, you don't need to make any changes and click **Next**.
1. Review the information for the stack. At the bottom under **Capabilities**, select **I acknowledge that AWS CloudFormation might create IAM resources**. When you're satisfied with the settings, click **Create stack**.

{{% notice note %}}
The CloudFormation stack takes about **45 minutes** for the environment setup and the bootstrap script to finish creating the CloudWatch metrics data.
{{% /notice %}}

### Login to AWS Cloud9 IDE

1. On the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), select the stack in the list.
1. In the stack details pane, click the **Events** tab.
1. Click the refresh button to update the events in the stack creation
1. When AWS CloudFormation has successfully created the stack, you will see the **CREATE_COMPLETE** event at the top of the Events tab.
1. In the stack details pane, click the **Outputs** tab.
1. Click on the url of the AWS Cloud9 environment, it's the value of **Cloud9IDE** in the CloudFormation stack outputs.
    ![cloudformation-create-complete](/images/efficient-and-resilient-ec2-auto-scaling/cloudformation-create-complete.png)
1. In the **Cloud9 IDE**, check the folders in left navigation, look for folder named **ec2-spot-workshops**, confirm it **exists**.
1. In the Cloud9 terminal, change into the workshop directory
	```bash
	cd ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling
	```  
    ![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/cloud9-workshop-directory.png)

