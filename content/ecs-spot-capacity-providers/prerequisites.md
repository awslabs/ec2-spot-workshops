---
title: "Prerequisites"
weight: 10
---

To run through this workshop we expect you to have some familiarity with [Docker](https://en.wikipedia.org/wiki/Docker_(software)), AWS, any container orchestration tools such as [Amazon Elastic Container Service (ECS)](https://aws.amazon.com/ecs), [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/), or [Kubernetes](https://kubernetes.io/). During the workshop you will use [AWS Cloud9](https://aws.amazon.com/cloud9/) IDE to run [AWS CLI](https://aws.amazon.com/cli/) commands. Use the AWS region that is specified by the facilitator when running this workshop at AWS hosted event. You may use any AWS region that supports Cloud9 (you can check [here](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/)) while running it self-paced mode in your own AWS account.

## Conventions:

Throughout this workshop, we provide commands for you to run in the Cloud9 terminal (not in your local terminal). These commands will look like:

<pre>
$ ssh -i PRIVATE_KEY.PEM ec2-user@EC2_PUBLIC_DNS_NAME
</pre>

The command starts after `$`.  Words that are ***UPPER_ITALIC_BOLD*** indicate a value unique to your environment.  For example, the ***PRIVATE\_KEY.PEM*** refers to the private key of an SSH key pair you've created, and the ***EC2\_PUBLIC\_DNS\_NAME*** is a value specific to an EC2 instance launched in your account.  

## General requirements and notes: 
 
1. This workshop is self-paced. The instructions will walk you through achieving the workshop’s learning objective using the AWS Management Console and CLI.

2. While the workshop provides step-by-step instructions, *please take a moment to look around and understand what is happening at each step* as this will enhance your learning experience. The workshop meant as a getting started guide, but you will learn the most by digesting each of the steps and thinking about how they would apply in your own environment and in your own organization. You can even consider experimenting with the steps to challenge yourself.