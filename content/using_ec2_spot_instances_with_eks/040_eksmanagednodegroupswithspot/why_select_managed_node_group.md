---
title: "EKS managed node groups"
date: 2018-08-07T11:05:19-07:00
weight: 10
draft: false
---

[Amazon EKS managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) automate the provisioning and lifecycle management of nodes (Amazon EC2 instances) for Amazon EKS clusters. This greatly simplifies operational activities such as rolling updates for new AMIs or Kubernetes version deployments.

Advantages of running Amazon EKS managed node groups:

* Create, automatically update, or terminate nodes with a single operation using the Amazon EKS console, eksctl, AWS CLI, AWS API, or infrastructure as code tools including AWS CloudFormation.
* Provisioned nodes run using the latest Amazon EKS optimized AMIs.
* Nodes provisioned under managed node group are automatically tagged for auto-discovery by the Kubernetes cluster autoscaler via node labels: **k8s.io/cluster-autoscaler/enabled=true** and **k8s.io/cluster-autoscaler/<cluster-name>**
* Node updates and terminations automatically and gracefully drain nodes to ensure that your applications stay available.
* No additional costs to use Amazon EKS managed node groups, pay only for the AWS resources provisioned.

### EKS managed node groups with Spot capacity

Amazon EKS managed node groups with Spot capacity enhances the managed node group experience with ease to provision and manage EC2 Spot Instances. EKS managed node groups launch an EC2 Auto Scaling group with Spot best practices and handle [Spot Instance interruptions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html) automatically. This enables you to take advantage of the steep savings that Spot Instances provide for your interruption tolerant containerized applications. 

In addition to the advantages of managed node groups, EKS managed node groups with Spot capacity have these additional advantages:

* Allocation strategy to provision Spot capacity is set to [Capacity Optimized](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html#use-capacity-optimized-allocation-strategy) to ensure that Spot nodes are provisioned in the optimal Spot capacity pools. 
* Specify [multiple instance types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html#be-instance-type-flexible) during managed node groups creation, to increase the number of Spot capacity pools available for allocating capacity.
* Nodes provisioned under managed node groups with Spot capacity are automatically tagged with capacity type: **eks.amazonaws.com/capacityType: SPOT**. You can use this label to schedule fault tolerant applications on Spot nodes.
* Amazon EC2 Spot [Capacity Rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-capacity-rebalancing.html) enabled to ensure Amazon EKS can gracefully drain and rebalance your Spot nodes to minimize application disruption when a Spot node is at elevated risk of interruption. 