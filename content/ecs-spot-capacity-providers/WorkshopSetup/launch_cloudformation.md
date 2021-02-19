---
title: "Deploy CloudFormation Stack"
weight: 10
---

To save time on the initial setup, a CloudFormation template will be used to create the required resources needed for the workshop.
 
1. You can view and download the CloudFormation template from GitHub [here] (https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/ecs-spot-capacity-providers/ecs-spot-workshop-cfn.yaml).
2. Take a moment to review the CloudFormation template so you understand the resources it will be creating.
3. Browse to the [AWS CloudFormation console] (https://console.aws.amazon.com/cloudformation). Make sure you are in AWS region designated by the facilitators of the workshop.
4. Click **Create stack**.
5. Under the *Specify template* section, select **Upload a template file**. Click **Choose file** and, select the template you downloaded in step 1.
6. Click **Next**.
7. In the *Specify stack details* section, enter **EcsSpotWorkshop** as *Stack name*.
8. [Optional] In the *Parameters* section, optionally change the *sourceCidr* to restrict load balancer http access.
9. Click **Next**.
10. In *Configure stack options*, you don’t need to make any changes.
11. Click **Next**.
12. Review the information for the stack. At the bottom under *Capabilities*, select **I acknowledge that AWS CloudFormation might create IAM resources*. When you’re satisfied with the settings, click **Create stack**.

### Monitor the progress of stack creation 

It will take roughly 5 minutes for the stack creation to complete.

1. On the [AWS CloudFormation console] (https://console.aws.amazon.com/cloudformation), select the stack in the list.
2. In the stack details pane, click the **Events** tab. You can click the refresh button to update the events in the stack creation.

The *Events* tab displays each major step in the stack's creation sorted by the time of each event, with the latest events on top.

The *CREATE_IN_PROGRESS* event is logged when AWS CloudFormation reports that it has begun to create the resource. The *CREATE_COMPLETE* event logged when the resources successfully created.

When AWS CloudFormation has successfully created the stack, you will see the *CREATE_COMPLETE* event at the top of the Events tab:

Take a moment and check out all the resources created by this stack.

![CloudFormation Stack](/images/ecs-spot-capacity-providers/ecs_cfn_stack.png) 

Note that if you are running this workshop inside an Event Engine, the CloudFormation stack names may look like this 

![CloudFormation Stack](/images/ecs-spot-capacity-providers/CFN_stacks.png) 


The CloudFormation stack creates the following resources for the workshop. 

* 1 VPC with 6 subnets; 3 public and 3 private subnets
* Application Load Balancer (ALB) with its own security group
* Target Group and an ALB listener
* Cloud9 Environment and its IAM Role
* EC2 Launch template with necessary ECS config for bootstrapping the instances into the ECS cluster
* ECR Repository