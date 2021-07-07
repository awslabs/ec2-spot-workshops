---
title: "Spot configuration and lifecycle"
date: 2021-04-07T12:00:00-00:00
weight: 40
draft: false
---

### View the Spot Managed Node Group Configuration

Use the AWS Management Console to inspect the Spot managed node group deployed in your Kubernetes cluster. Select **Elastic Kubernetes Service**, click on **Clusters**, and then on **eksworkshop-eksctl** cluster. Select the **Configuration** tab and **Compute** sub tab. You can see 3 node groups created - one On-Demand node group and two Spot node groups.

Click on **dev-4vcpu-16gb-spot** group and you can see the instance types set from the create command.

Click on the Auto Scaling Group name in the **Details** tab. Scroll to the Purchase options and instance types settings. Note how Spot best practices are applied out of the box:

* **Capacity Optimized** allocation strategy, which will launch Spot Instances from the most-available spare capacity pools. This results in minimizing the Spot Interruptions.
* **Capacity Rebalance** helps EKS managed node groups manage the lifecycle of the Spot Instance by proactively replacing instances that are at higher risk of being interrupted. Node groups use Auto Scaling Group's Capacity Rebalance feature to launch replacement nodes in response to Rebalance Recommendation notice, thus proactively maintaining desired node capacity.

![Spot Best Practices](/images/using_ec2_spot_instances_with_eks/spotworkers/asg_spot_best_practices.png)

### Interruption Handling in Spot Managed Node Groups

To handle Spot interruptions, you do not need to install any extra automation tools on the cluster such as the AWS Node Termination Handler. The managed node group handles Spot interruptions for you in the following way: the underlying EC2 Auto Scaling Group is opted-in to Capacity Rebalancing, which means that when one of the Spot Instances in your node group is at elevated risk of interruption and gets an EC2 instance rebalance recommendation, it will attempt to launch a replacement instance. The more instance types you configure in the managed node group, the more chances EC2 Auto Scaling Group has of launching a replacement Spot Instance.
sw replacement Spot node and waits until it successfully joins the cluster.
* When a replacement Spot node is bootstrapped and in the Ready state on Kubernetes, Amazon EKS cordons and drains the Spot node that received the rebalance recommendation. Cordoning the Spot node ensures that the node is marked as ‘unschedulable’ and kube-scheduler will not schedule any new pods on it. It also removes it from its list of healthy, active Spot nodes. [Draining](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) the Spot node ensures that running pods are evicted gracefully.
* If a Spot two-minute interruption notice arrives before the replacement Spot node is in a Ready state, Amazon EKS starts draining the Spot node that received the rebalance recommendation.

This process avoids waiting for new capacity to be available when there is a termination notice, and instead procures capacity in advance, limiting the time that pods might be left pending.

![Spot Rebalance Recommendation](/images/using_ec2_spot_instances_with_eks/spotworkers/rebalance_recommendation.png)