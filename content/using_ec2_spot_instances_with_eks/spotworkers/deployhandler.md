---
title: "Deploy The Spot Interrupt Handler"
date: 2018-08-07T12:32:40-07:00
weight: 40
draft: false
---

When new On-Demand instances are requested from a pool if the available On-Demand capacity of the pool is depleted, the system will select a set of spot instances from the pool to be terminated. A A Spot instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone. The Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things. We will deploy a pod on each spot instance to detect and redeploy applications elsewhere in the cluster.

The first thing that we need to do is deploy the Spot Interrupt Handler on each Spot Instance. This will monitor the EC2 metadata service on the instance for a interruption notice.

The workflow can be summarized as:

* Identify that a Spot Instance is being reclaimed.
* Use the 2-minute notification window to gracefully prepare the node for termination.
* [**Taint**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) the node and cordon it off to prevent new pods from being placed.
* [**Drain**](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) connections on the running pods.
* Replace the pods on remaining nodes to maintain the desired capacity.

We have provided an example K8s DaemonSet manifest. A DaemonSet runs one pod per node.

```bash
mkdir ~/environment/spot
pushd ~/environment/spot
wget https://eksworkshop.com/spot/managespot/deployhandler.files/spot-interrupt-handler-example.yml
popd 
```

As written, the manifest will deploy pods to all nodes including On-Demand, which is a waste of resources. We want to edit our DaemonSet to only be deployed on Spot Instances. Let's use the labels to identify the right nodes.

Use a `nodeSelector` to constrain our deployment to spot instances. View this [**link**](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) for more details.

#### Challenge

**Configure our Spot Handler to use nodeSelector**
{{% expand "Expand here to see the solution"%}}
Place this at the end of the DaemonSet manifest under Spec.Template.Spec.nodeSelector

```
      nodeSelector:
        lifecycle: Ec2Spot
```

{{% /expand %}}

Deploy the DaemonSet

```bash
kubectl apply -f ~/environment/spot/spot-interrupt-handler-example.yml
```

{{% notice tip %}}
If you receive an error deploying the DaemonSet, there is likely a small error in the YAML file. We have provided a solution file at the bottom of this page that you can use to compare.
{{% /notice %}}

View the pods. There should be one for each spot node.

```bash
kubectl get daemonsets
```

{{%attachments title="Related files" pattern=".yml"/%}}