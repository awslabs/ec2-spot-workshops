---
title: "CI/CD and Test Workloads (GitLab) with EC2 Spot Instances"
menuTitle: "GitLab"
weight: 20
pre: "<b></b>"
---

## Overview 
In this workshop you will add runners on Amazon EC2 Spot instances to a pre-installed GitLab. Then you will build a containerized demo application on them and install it into Kubernetes cluster that also uses only spot instances as its worker nodes. In the end you will test it to verify the results.

You can perform all workshop steps one-by-one to get to the expected results, but for better understanding of using Spot instances with GitLab we recommend that you also look into the used templates and result files and try modifying them additionally.

Many workshop steps imply manual actions in the AWS console to better demonstrate the underlying concepts, but in a Production environment it is better to automate them using Infrastructure as Code (IaC), such as [AWS CloudFormation](https://aws.amazon.com/cloudformation/) and [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/home.html).

## Workshop Details
This workshop will be broken down into a series of sections that flow on from each other (that is, you must complete each section before proceeding with the next). The whole flow looks as following:

![GitLab on Spot workshop flow](/images/gitlab-spot/lab-flow.png)


The exercises that will be covered are:

* [Starting the workshop](gitlab-spot/before.html) where you will log in to AWS accounts and deploy GitLab, if it is not yet deployed
* [Workshop Preparation](gitlab-spot/prep.html) where you will save GitLab access details and create an AWS Cloud9 environment to execute the workshop steps
* [Create a GitLab repository](gitlab-spot/lab1.html) where you will create a repository in GitLab CI/CD and create a demo application.
* [Configure GitLab runners on Spot instances](gitlab-spot/lab2.html) where you will deploy the GitLab Runners in an auto-scaling group on spot instances
* [Building the demo app](gitlab-spot/lab3.html) where you will push the changes and make sure that your pipeline executes successfully.
* [Deploying Amazon EKS on Spot instances](gitlab-spot/lab4.html) where you will create a new Kubernetes cluster in Amazon EKS that will only have worker nodes on spot instances
* [Installing the demo app into Amazon EKS](gitlab-spot/lab5.html) where you will modify your GitLab CI/CD scripts to add a stage of deploying on Amazon EKS and test the result
* [Workshop Cleanup](gitlab-spot/cleanup.html) where you will remove all the resources created during the workshop

The final architecture that we will be building looks the following way:

![GitLab on Spot workshop architecture diagram](/images/gitlab-spot/gitlab-spot-architecture.png)