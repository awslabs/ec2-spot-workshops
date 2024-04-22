+++
title = "...At an AWS event"
weight = 20
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Efficient and Resilient Workloads with Amazon EC2 Auto Scaling](https://catalog.us-east-1.prod.workshops.aws/workshops/20c57d32-162e-4ad5-86a6-dff1f8de4b3c/en-US)**.

{{% /notice %}}


### Running the workshop at an AWS Event

{{% notice warning %}}
Only complete this section if you are at an AWS hosted event (such as re:Invent, public workshop, Immersion Day, or any other event hosted by an AWS employee).
{{% /notice %}}

To **save time** on the initial setup, **a CloudFormation stack has been deployed** to your workshop account to create various supporting resources including IAM policies and roles, EC2 Launch Template, VPC, Subnets and a Cloud9 IDE environment for you to run the steps for the workshop in.

### Login to the AWS Workshop Portal

If you are at an AWS event, an AWS account was created for you to use throughout the workshop. You will need the **Participant Hash** provided to you by the event's organizers.

1. Connect to the portal by browsing to [https://dashboard.eventengine.run/](https://dashboard.eventengine.run/). **Tip:** Right click the link and Open in a Private Browser Window.
1. Enter the Hash in the text box, and click **Proceed** 
1. In the User Dashboard screen, click **AWS Console** 
1. In the popup page, click **Open Console**
1. You are now logged in to the AWS console in an account that was created for you, and **will be available only throughout the workshop run time**.
1. Browse to [AWS Cloud9](https://console.aws.amazon.com/cloud9control/home), you should find one environment has been created, then within Cloud9 IDE column click **Open**
    ![cloudformation-create-complete](/images/efficient-and-resilient-ec2-auto-scaling/open-cloud9-ide.png)
1. In the **Cloud9 IDE**, check the folders in left navigation, look for folder named **ec2-spot-workshops**, confirm it **exists**.
1. In the Cloud9 terminal, change into the workshop directory
	```bash
	cd ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling
	```  
    ![predictive-scaling](/images/efficient-and-resilient-ec2-auto-scaling/cloud9-workshop-directory.png)