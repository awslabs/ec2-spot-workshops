---
title: "Advantages of EKS Spot Managed Node Group"
date: 2018-08-07T11:05:19-07:00
weight: 10
draft: false
---

### Why EKS Managed Node Groups?

[Amazon EKS managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) automate the provisioning and lifecycle management of nodes (Amazon EC2 instances) for Amazon EKS Kubernetes clusters. This greatly simplifies operational activities such as rolling updates for new AMIs or Kubernetes version deployments.

Advantages of running Amazon EKS managed node groups:

* Create, automatically update, or terminate nodes with a single operation using the Amazon EKS console, eksctl, AWS CLI, AWS API, or infrastructure as code tools including AWS CloudFormation.
* Provisioned nodes run using the latest Amazon EKS optimized AMIs.
* Nodes provisioned under managed node group are automatically tagged for auto-discovery by the Kubernetes cluster autoscaler via node labels: **k8s.io/cluster-autoscaler/enabled=true** and **k8s.io/cluster-autoscaler/<cluster-name>**
* Node updates and terminations automatically and gracefully drain nodes to ensure that your applications stay available.
* No additional costs to use Amazon EKS managed node groups, pay only for the AWS resources provisioned.

### Why EKS Spot Managed Node Groups?

**Amazon EKS Spot managed node groups** enhances the managed node group experience in using EKS managed node groups to easily provision and manage EC2 Spot Instances. EKS managed node group will configure and launch an EC2 Autoscaling group of Spot Instances following Spot best practices and draining Spot worker nodes automatically before the instances are interrupted by AWS. This enables you to take advantage of the steep savings that Spot Instances provide for your interruption tolerant containerized applications. 

In addition to the advantages of managed node groups, Amazon EKS Spot managed node groups have these additional advantages:

* Allocation strategy to provision Spot capacity is set to **Capacity Optimized** to ensure that Spot nodes are provisioned in the optimal Spot capacity pools. 
* Specify **multiple instance types** during EKS Spot managed Node Group creation, to increase the number of Spot capacity pools available for allocating capacity.
* Nodes provisioned under Spot managed node group are automatically tagged with capacity type: **eks.amazonaws.com/capacityType: SPOT**. You can use this label to schedule fault tolerant applications on Spot nodes.
* Amazon EC2 Spot **Capacity Rebalancing** enabled to ensure Amazon EKS can gracefully drain and rebalance your Spot nodes to minimize application disruption when a Spot node is at elevated risk of interruption. 
