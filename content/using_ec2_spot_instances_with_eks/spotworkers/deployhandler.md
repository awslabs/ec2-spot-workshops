---
title: "Deploy The Spot Interrupt Handler"
date: 2018-08-07T12:32:40-07:00
weight: 40
draft: false
---

When users requests On-Demand instances from a pool to the point that the pool is depleted, the system will select a set of spot instances from the pool to be terminated. A Spot instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone, and network platform. The Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things. 

We will deploy a pod on each spot instance to detect the instance termination notification signal so that we can both terminate gracefully any pod that was running on that node, drain from load balancers and redeploy applications elsewhere in the cluster.

To deploy Spot Interrupt Handler on each Spot Instance we will use a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). This will monitor the EC2 metadata service on the instance for a interruption notice.

Within the Spot Interrupt Handler DaemonSet, the workflow can be summarized as:

* Identify that a Spot Instance is being reclaimed.
* Use the 2-minute notification window to gracefully prepare the node for termination.
* [**Taint**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) the node and cordon it off to prevent new pods from being placed.
* [**Drain**](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) connections on the running pods.
* Replace the pods on remaining nodes to maintain the desired capacity.

By default, the **[aws-node-termination-handler](https://github.com/aws/aws-node-termination-handler)** will run on all of your nodes (on-demand and spot). If your spot instances are labeled, you can configure `aws-node-termination-handler` to only run on your labeled spot nodes. If you're using the tag `lifecycle=Ec2Spot`, you can run the following to apply our spot-node-selector overlay.


```
helm repo add eks https://aws.github.io/eks-charts
helm install --name aws-node-termination-handler \
             --namespace kube-system \
             --set nodeSelector.lifecycle=Ec2Spot \
             eks/aws-node-termination-handler
```

Verify that the pods are only running on node with label `lifecycle=Ec2Spot`
```
kubectl get daemonsets --all-namespaces
```

{{% notice note %}}
Use **kube-ops-view** to confirm the *spot-interrupt-handler-example* DaemonSet has been deployed only to EC2 Spot nodes. 
{{% /notice %}}

{{%attachments title="Related files" pattern=".yml"/%}}
