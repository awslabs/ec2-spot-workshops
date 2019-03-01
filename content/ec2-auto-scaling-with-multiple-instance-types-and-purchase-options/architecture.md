+++
title = "Architecture"
weight = 20
+++

In this workshop, you will deploy the following:

* An AWS CloudFormation stack, which will include:
	* An Amazon Virtual Private Cloud (Amazon VPC) with subnets in two Availability Zones
	* An AWS Cloud9 environment
	* Supporting IAM policies and roles
	* Supporting security groups
* An Amazon EC2 launch template
* An Application Load Balancer (ALB) with a listener and target group
* An Amazon EC2 Auto Scaling group, with:
	* A scheduled scaling action
	* A dynamic scaling policy
* An AWS Systems Manager run command to emulate load on the service

Here is a diagram of the resulting architecture:

![Architecture Description](/images/ec2-auto-scaling-with-multiple-instance-types-and-purchase-options/architecture.jpg)
