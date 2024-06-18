---
title: "Spot Best Practices and Interruption Handling"
date: 2021-04-07T12:00:00-00:00
weight: 40
draft: false
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

### View EKS managed node groups Configurations

Use the AWS Management Console to inspect the managed node groups deployed in your Kubernetes cluster. 

* Go to **Elastic Kubernetes Service** >> click on **Clusters** >> select **eksspotworkshop** cluster >> select **Configuration** tab >> go to **Compute** tab in the bottom pane.
* You can see 3 node groups created; one On-Demand node group and two Spot node groups.
* Click on **mng-spot-4vcpu-16gb** node group and you can see the instance types we selected in earlier section.
* Click on the `Auto Scaling Group name` in the **Details** tab. Scroll to the Purchase options and instance types settings. Note how Spot best practices are applied out of the box:
    * **Capacity Optimized** allocation strategy, which will launch Spot Instances from the most-available spare capacity pools. This results in minimizing the Spot Interruptions.
    * **Capacity Rebalance** helps EKS managed node groups manage the lifecycle of the Spot Instance by proactively replacing instances that are at higher risk of being interrupted. Node groups use Auto Scaling Group's Capacity Rebalance feature to launch replacement nodes in response to Rebalance Recommendation notice, thus proactively maintaining desired node capacity.

![Spot Best Practices](/images/using_ec2_spot_instances_with_eks/spotworkers/asg_spot_best_practices.png)

### Interruption Handling in EKS managed node groups with Spot capacity

To handle Spot interruptions, you do not need to install any extra automation tools on the cluster such as the AWS Node Termination Handler. A managed node group configures an Amazon EC2 Auto Scaling group on your behalf and handles the Spot interruption in following manner: 

* Amazon EC2 Spot Capacity Rebalancing is enabled so that Amazon EKS can gracefully drain and rebalance your Spot nodes to minimize application disruption when a Spot node is at elevated risk of interruption. For more information, see [Amazon EC2 Auto Scaling Capacity Rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html) in the Amazon EC2 Auto Scaling User Guide.

* When a replacement Spot node is bootstrapped and in the Ready state on Kubernetes, Amazon EKS cordons and drains the Spot node that received the rebalance recommendation. Cordoning the Spot node ensures that the node is marked as unschedulable and kube-scheduler will not schedule any new pods on it. It also removes it from its list of healthy, active Spot nodes. [Draining](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) the Spot node ensures that running pods are evicted gracefully.

* If a Spot two-minute interruption notice arrives before the replacement Spot node is in a Ready state, Amazon EKS starts draining the Spot node that received the rebalance recommendation.

This process avoids waiting for replacement Spot node till Spot interruption arrives, instead it procures replacement in advance and helps in minimizing the scheduling time for pending pods.

![Spot Rebalance Recommendation](/images/using_ec2_spot_instances_with_eks/spotworkers/rebalance_recommendation.png)