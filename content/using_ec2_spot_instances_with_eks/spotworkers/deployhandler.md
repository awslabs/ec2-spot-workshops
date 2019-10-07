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

We have provided an example K8s DaemonSet manifest. A DaemonSet runs one pod per node.

```
mkdir ~/environment/spot
curl -o ~/environment/spot/spot-interrupt-handler-example.yml https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/using_ec2_spot_instances_with_eks/spotworkers/deployhandler.files/spot-interrupt-handler-example.yml
```

As written, the manifest will deploy pods to all nodes including On-Demand, which is a waste of resources. We want to edit our DaemonSet to only be deployed on Spot Instances. Let's use the labels to identify the right nodes.

Use a `nodeSelector` to constrain our deployment to spot instances. View this [**link**](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) for more details.

### Challenge

**Configure our Spot Handler to use nodeSelector**
{{% expand "Expand here to see the solution"%}}
Place this at the end of the DaemonSet manifest under **spec.template.spec.**nodeSelector

```
      nodeSelector:
        lifecycle: Ec2Spot
```

If you need a reference of where those two lines should be inserted, check the highlighted text and line numbers in the section below. Note the syntax in the hierarchy maps with **spec.template.spec.**nodeSelector.

{{< highlight bash "linenos=table,hl_lines=11-12,linenostart=56" >}}
spec:
  selector:
    matchLabels:
      app: spot-interrupt-handler
  template:
    metadata:
      labels:
        app: spot-interrupt-handler
    spec:
      serviceAccountName: spot-interrupt-handler
      nodeSelector:
        lifecycle: Ec2Spot
      containers:
      - name: spot-interrupt-handler
{{< / highlight >}}

{{% /expand %}}


### Deploy the DaemonSet

Once that you have added the nodeSelector section to your file, deploy the DaemonSet using the following line on the console:

```
kubectl apply -f ~/environment/spot/spot-interrupt-handler-example.yml
```

{{% notice tip %}}
If you receive an error deploying the DaemonSet, there is likely a small error in the YAML file. We have provided a solution file at the bottom of this page that you can use to compare.
{{% /notice %}}

View the pods. There should be one for each spot node.

```
kubectl get daemonsets
```

{{% notice note %}}
Use **kube-ops-view** to confirm the *spot-interrupt-handler-example* DaemonSet has been deployed only to EC2 Spot nodes. 
{{% /notice %}}

{{%attachments title="Related files" pattern=".yml"/%}}
