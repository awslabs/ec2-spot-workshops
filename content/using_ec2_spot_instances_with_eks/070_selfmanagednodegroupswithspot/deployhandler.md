---
title: "Deploy AWS Node Termination Handler"
date: 2018-08-07T12:32:40-07:00
weight: 40
draft: false
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}


When users requests On-Demand Instances from a pool to the point that the pool is depleted, the system will select a set of Spot Instances from the pool to be terminated. A Spot Instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone, and network platform. The Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things. 

We will deploy a pod on each Spot Instance to detect the instance termination notification signal so that we can both terminate gracefully any pod that was running on that node, drain from load balancers and redeploy applications elsewhere in the cluster.

**[AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler)**
 ensures that the Kubernetes control plane responds appropriately to events that can cause your EC2 instance to become unavailable, such as [EC2 maintenance events](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-instances-status-check_sched.html), [EC2 Spot interruptions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html), [ASG Scale-In](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroupLifecycle.html#as-lifecycle-scale-in), [ASG AZ Rebalance](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-benefits.html#AutoScalingBehavior.InstanceUsage), and EC2 Instance Termination via the API or Console. If not handled, your application code may not stop gracefully, take longer to recover full availability, or accidentally schedule work to nodes that are going down.

The aws-node-termination-handler (NTH) can operate in two different modes: **Instance Metadata Service (IMDS)** or the **Queue Processor**.

* The aws-node-termination-handler **Instance Metadata Service Monitor** will run a small pod on each host to perform monitoring of IMDS paths like /spot or /events and react accordingly to drain and/or cordon the corresponding node.
* The aws-node-termination-handler **Queue Processor** will monitor an SQS queue of events from Amazon EventBridge for ASG lifecycle events, EC2 status change events, Spot Interruption Termination Notice events, and Spot Rebalance Recommendation events. When NTH detects an instance is going down, we use the Kubernetes API to cordon the node to ensure no new work is scheduled there, then drain it, removing any existing work. The termination handler Queue Processor requires AWS IAM permissions to monitor and manage the SQS queue and to query the EC2 API. Review below table to decide on which option to use:

| Syntax                                | IMDS Processor | Queue Processor |
| ------------                          | -----------    | -----------     |
| K8s DaemonSet                         | ✅	            | ❌               | 
| K8s Deployment                        | ❌             | ✅               |
| Spot Instance Interruptions (ITN)     | ✅	            | ✅	              |
| Scheduled Events                      | ✅             | ✅               |
| EC2 Instance Rebalance Recommendation | ✅	            | ✅               |
| ASG Lifecycle Hooks                   | ❌             | ✅               |
| EC2 Status Changes                    | ❌             | ✅               |
| Setup Required                        | ❌             | ✅               |


To keep it simple, we will use Helm chart to deploy aws-node-termination-handler in IMDS mode on each Spot Instance as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Within the aws-node-termination-handler in IMDS mode, the workflow can be summarized as:

* Identify that a Spot Instance is being reclaimed.
* Use the 2-minute notification window to gracefully prepare the node for termination.
* [**Taint**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) the node and cordon it off to prevent new pods from being placed.
* [**Drain**](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) connections on the running pods.
* Replace the pods on remaining nodes to maintain the desired capacity.

By default, **[aws-node-termination-handler](https://github.com/aws/aws-node-termination-handler)** will run on all of your nodes. Let's limit it's scope to only self managed node groups with Spot Instances.


```
helm repo add eks https://aws.github.io/eks-charts
helm install aws-node-termination-handler \
             --namespace kube-system \
             --version 0.21.0 \
             --set nodeSelector.type=self-managed-spot \
             eks/aws-node-termination-handler
```

Verify that the pods are running on all nodes: 
```
kubectl get daemonsets --all-namespaces
```

Use **kube-ops-view** to confirm *AWS Node Termination Handler* DaemonSet has been deployed to all nodes.