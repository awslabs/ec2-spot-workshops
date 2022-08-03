---
title: "CI/CD Workloads with EC2 Spot Instances"
menuTitle: "CI/CD Workloads"
date: 2019-02-19T02:02:35
weight: 80
pre: "<b>8. </b>"
---

## Overview 
In this workshop, you'll get hands-on with Spot instances and discover architectural best practices through the lens of DevOps and CI/CD. We'll dive dive deep on how to deploy tools like Jenkins and use Spot instances as build agents. You'll also implement mechanisms to ensure that your CI/CD tooling recovers from Spot interruptions by simulating failures and decoupling application state from your compute resources. Moreover, you'll migrate your CI/CD environment to a containerized environments using ECS to eke out maximum performance and cost efficiency. In addition to covering the best practices to use Spot, we'll share some of the Spot-based mechanisms used by customers to optimize their infrastructure resources.

## Workshop Labs
This workshop will be broken down into a series of labs using differenct CI/CD tools and AWS services, topics covered are:

* [Jenkins with Auto Scaling groups](/amazon-ec2-spot-cicd-workshop/jenkins-asg.html)
* [Jenkins with ECS](/amazon-ec2-spot-cicd-workshop/jenkins-ecs.html)

{{% notice note %}}
As a reminder, you should have a laptop device (Windows/OSX/Linux are supported - tablets are not appropriate) with the current version of Google Chrome or Mozilla Firefox installed. You should also have a clean AWS account, with **AdministratorAccess** policy-level access. 
{{% /notice %}}

This workshop should take between two and three hours to complete, depending on your proficiency with the AWS services being featured.
