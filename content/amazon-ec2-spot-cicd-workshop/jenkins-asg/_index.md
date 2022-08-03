+++
title = "Jenkins with Auto Scaling groups"
weight = 100
+++
By default, all job builds are executed on the same instance that Jenkins is running on. This results in a couple of less-than-desirable behaviours:
* When CPU-intensive builds are being executed, there may not be sufficient system resources to display the Jenkins server interface; and
* The Jenkins server is often provisioned with more resources than the server interface requires in order to allow builds to execute. When builds are not being executed, these server resources are essentially going to waste.

To address these behaviours, Jenkins provides the capability to execute builds on external hosts (called build agents). Further, AWS provides a Jenkins plugin to allow Jenkins to scale out a fleet of EC2 instances in order to execute build jobs on. This lab will focus on implementing EC2 Spot build agents, showcasing what a batch processing workload typically looks like when using Amazon EC2 Spot instances.

## What we'll be doing?
The purpose of these labs is to help you understand how to configure build agents using Spot instances. We'll focus on configuring a Jenkins plugin so that build agents are launched only when you need them. At the end of these labs, you'll be able to:

* Learn how to launch Spot instances following our best practices using Auto Scaling groups
* Configure properly the EC2 Fleet Jenkins plugin
* Configure Jenkins build jobs to use Spot instances as agents
* Simulate Spot interruption events to increase fault-tolerance
* Test how resilient and fault-toleran Jenkins could be using Spot instances