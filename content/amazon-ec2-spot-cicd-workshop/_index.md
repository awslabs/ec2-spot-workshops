---
title: "Run your CI/CD and Test Workloads with Spot Instances"
date: 2019-02-19T02:02:35
weight: 70
---

## Overview 
During this workshop, you'll get hands-on with Amazon EC2 Spot and discover architectural best practices through the lens of DevOps and CI/CD. You'll deploy Jenkins build agents and test environments on Spot instances at a fraction of the cost of on-demand instances. You'll also implement mechanisms to ensure that your CI/CD tooling recovers from spot market events by decoupling application state from your compute resources. Finally, you'll migrate your CI/CD environment to a containered environment to eke out maximum performance and cost efficiency. In addition to covering the ins and outs of Spot, we'll share some of the Spot-based mechanisms used by customers to reduce the cost of their test and production workloads.

## Workshop Details
This workshop will be broken down into a series of labs that flow on from each other (that is, you must complete each lab in order before proceeding with the next). The lab exercises that will be covered are:

* Workshop preparation: Deploy pre-requisite resources through Amazon CloudFormation;
* Lab 1: Reduce the cost of builds using Amazon EC2 Spot Fleet;
* Lab 2: Deploy testing environments using Amazon EC2 Spot, Amazon CloudFormation & Amazon EC2 Launch Templates;
* Lab 3: Externalize state data to add resiliency and reduce cost for your CI/CD tooling;
* Lab 4: Using containers backed by Auto Scaling Groups comprised of both on-demand and Spot instances;
* Workshop clean up.

As a reminder, you should have a laptop device (Windows/OSX/Linux are supported - tablets are not appropriate) with the current version of Google Chrome or Mozilla Firefox installed. You should also have a clean AWS account, with **AdministratorAccess** policy-level access. 

This workshop should take between two and three hours to complete, depending on your proficiency with the AWS services being featured.

#### Additional considerations when running this workshop in a corporate IT environment
If you are running this workshop from a corporate IT environment, contact your Systems Administrator to ensure that you will be able to establish outbound Secure Shell (SSH) connections to an Internet host:

* If you cannot establish SSH connections to Internet hosts (and do not have a suitable workaround), you will not be able to complete Labs 3 & 4;
* If you can establish SSH connections to Internet hosts, obtain from your Systems Administrator the source IP address CIDR block that connections will be established from. 

If you access the Intenet through a transparent proxy server running in your corporate IT environment and this proxy server uses a different source address than where SSH connections come from, additional configuration of AWS Security Groups will need to be carried out. The lab guide will indicate the configuration steps required when appropriate. 

