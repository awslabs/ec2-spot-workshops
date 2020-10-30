---
title: "Setup with CloudFormation"
weight: 5
---

Launch the CloudFormation stack 
---

To save time on the initial setup, a CloudFormation template will be used to create the required resources needed for the workshop.
 
1. You can view and download the CloudFormation template from GitHub [here, Change location before making it live] (https://github.com/ec2-spot-workshops/workshops/ecs-spot-capacity-providers/ecs-spot-workshop-cfn.yaml).
2. Take a moment to review the CloudFormation template so you understand the resources it will be creating.
3. Browse to the [AWS CloudFormation console] (https://console.aws.amazon.com/cloudformation). Make sure you are in AWS region designated by the facilitators of the workshop
4. Click **Create stack**.
5. Udner the *Specify template* section, select **Upload a template file**. Click **Choose file** and, select the template you downloaded in step 1.
6. Click **Next**
7. In the *Specify stack details* section, enter **EcsSpotWorkshop** as *Stack name*.
8. [Optional] In the *Parameters* section, optionally change the *sourceCidr* to restrict instance ssh/http access and load balancer http access.
9. Click **Next**
10. In *Configure stack options*, you don’t need to make any changes.
11. Click **Next**
12. Review the information for the stack. At the bottom under *Capabilities*, select **I acknowledge that AWS CloudFormation might create IAM resources*. When you’re satisfied with the settings, click **Create stack**.

Monitor the progress of stack creation 
---

It will take roughly 5 minutes for the stack creation to complete.

1. On the [AWS CloudFormation console] (https://console.aws.amazon.com/cloudformation), select the stack in the list.
2. In the stack details pane, click the **Events** tab. You can click the refresh button to update the events in the stack creation.

The *Events* tab displays each major step in the creation of the stack sorted by the time of each event, with latest events on top.
The *CREATE_IN_PROGRESS* event is logged when AWS CloudFormation reports that it has begun to create the resource. The *CREATE_COMPLETE* event is logged when the resource is successfully created.
When AWS CloudFormation has successfully created the stack, you will see the *CREATE_COMPLETE* event at the top of the Events tab:

Take a moment and check out all the resources created by this stack.

![Cloud Formation Stack](/images/ecs-spot-capacity-providers/ecs_cfn_stack.png) 

Note that if you are running this workshop inside an Event Engine, the Cloud formation stack names may look like this 

![Cloud Formation Stack](/images/ecs-spot-capacity-providers/CFN_stacks.png) 


The cloud formation stack creates the following resources for the workshop.


* **1 VPC with 3 public and 3 private subnets**
* **Application Load Balancer (ALB) with its own security group**
* **Target Group (TG) and an ALB listener**
* **Cloud9 Environment and it's IAM Role**
* **EC2 Launch Template with necessary ECS config to bootstrapping into the ECS cluster**
* **ECR Repository**