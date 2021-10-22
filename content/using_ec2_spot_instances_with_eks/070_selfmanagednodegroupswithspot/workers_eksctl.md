---
title: "Create self managed node groups with Spot Instances"
date: 2018-08-07T11:05:19-07:00
weight: 30
draft: false
---
{{% notice warning %}}

If you are starting with **self managed Spot workers** chapter directly and planning to run only self managed node groups with Spot Instances, then first complete below chapters and then return back here:<br>
<br>
[Start the workshop]({{< relref "/using_ec2_spot_instances_with_eks/010_prerequisites" >}})<br>
[Launch using eksctl]({{< relref "/using_ec2_spot_instances_with_eks/020_eksctl" >}})<br>
[Install Kubernetes Tools]({{< relref "/using_ec2_spot_instances_with_eks/030_k8s_tools" >}})<br>
[Select Instance Types for Diversification]({{< relref "/using_ec2_spot_instances_with_eks/040_eksmanagednodegroupswithspot/selecting_instance_types.md" >}})

{{% /notice %}}

{{% notice info %}}

If you are have already completed **EKS managed Spot workers** chapters and still want to explore self managed node groups with Spot Instances, then continue with this chapter.

{{% /notice %}}

In this section we will create self managed node groups with Spot best practices. To adhere to the best practice of instance diversification we will include instance types we identified in [Select Instance Types for Diversification]({{< relref "/using_ec2_spot_instances_with_eks/040_eksmanagednodegroupswithspot/selecting_instance_types.md" >}}) chapter. 



Let's first create the configuration file:
```
cat <<EoF > ~/environment/add-ngs-spot.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl
    region: $AWS_REGION
nodeGroups:
    - name: ng-spot-4vcpu-16gb
      minSize: 0
      maxSize: 4
      desiredCapacity: 2
      instancesDistribution:
        instanceTypes: ["m4.xlarge", "m5.xlarge", "m5a.xlarge", "m5ad.xlarge", "m5d.xlarge", "t2.xlarge", "t3.xlarge", "t3a.xlarge"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotAllocationStrategy: capacity-optimized
      labels:
        eks.amazonaws.com/capacityType: SPOT
        intent: apps
        type: self-managed-spot
      taints:
        spotInstance: "true:PreferNoSchedule"
      tags:
        k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/capacityType: SPOT
        k8s.io/cluster-autoscaler/node-template/label/intent: apps
        k8s.io/cluster-autoscaler/node-template/label/type: self-managed-spot
        k8s.io/cluster-autoscaler/node-template/taint/spotInstance: "true:PreferNoSchedule"
      iam:
        withAddonPolicies:
          autoScaler: true
          cloudWatch: true
          albIngress: true
    - name: ng-spot-8vcpu-32gb
      minSize: 0
      maxSize: 2
      desiredCapacity: 1
      instancesDistribution:
        instanceTypes: ["m4.2xlarge", "m5.2xlarge", "m5a.2xlarge", "m5ad.2xlarge", "m5d.2xlarge", "t2.2xlarge", "t3.2xlarge", "t3a.2xlarge"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotAllocationStrategy: capacity-optimized
      labels:
        eks.amazonaws.com/capacityType: SPOT
        intent: apps
        type: self-managed-spot
      taints:
        spotInstance: "true:PreferNoSchedule"
      tags:
        k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/capacityType: SPOT
        k8s.io/cluster-autoscaler/node-template/label/intent: apps
        k8s.io/cluster-autoscaler/node-template/label/type: self-managed-spot
        k8s.io/cluster-autoscaler/node-template/taint/spotInstance: "true:PreferNoSchedule"
      iam:
        withAddonPolicies:
          autoScaler: true
          cloudWatch: true
          albIngress: true
EoF
```

This will create a `add-ngs-spot.yaml` file that we will use to instruct eksctl to create two node groups.

```
eksctl create nodegroup -f add-ngs-spot.yaml
```

{{% notice note %}}
The creation of the workers will take about 3-4 minutes.
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these nodegroups.

 * First node group has **xlarge** (4 vCPU and 16 GB) instance types with **minSize** 0, **maxSize** 4 and **desiredCapacity** 2.
 * Second node group has **2xlarge** (8 vCPU and 32 GB) instance types with **minSize** 0, **maxSize** 2 and **desiredCapacity** 1.
 * **onDemandBaseCapacity** and **onDemandPercentageAboveBaseCapacity** both set to **0**. which implies all nodes in the node group would be **Spot instances**.
 * **spotAllocationStrategy** is set as **[Capacity Optimized](https://aws.amazon.com/about-aws/whats-new/2019/08/new-capacity-optimized-allocation-strategy-for-provisioning-amazon-ec2-spot-instances/)**. This will ensure the capacity we provision in our node groups is procured from the pools that will have less chances of being interrupted.
 * We applied a **[Taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)** `spotInstance: "true:PreferNoSchedule"`. **PreferNoSchedule** is used to indicate we prefer pods not be scheduled on Spot Instances. This is a “preference” or “soft” version of **NoSchedule** – the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required.
 * Notice that the we added 3 node labels per node:
  * **eks.amazonaws.com/capacityType: SPOT**, to  identify Spot nodes and use as [affinities](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).
  * **intent: apps**, to allow you to deploy stateless applications on nodes that have been labeled with value **apps**
  * **type: self-managed-spot**, to identify self managed Spot nodes and use as [nodeSelectors](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector).

 * Notice that the we added 4 cluster autoscaler related tags to node groups. These tags are used by cluster autoscaler when node groups scale down to 0 (and scale up from 0). Cluster autoscaler acts on Auto Scaling groups belonging to node groups, therefore it requires same tags on ASG as well. EKSCTL adds these tags to ASG automatically while creating self managed node groups. 

{{% notice info %}}
If you are wondering at this stage: *Where is spot bidding price ?* you are missing some of the changes EC2 Spot Instances had since 2017. Since November 2017 [EC2 Spot price changes infrequently](https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/) based on long term supply and demand of spare capacity in each pool independently. You can still set up a **maxPrice** in scenarios where you want to set maximum budget. By default *maxPrice* is set to the On-Demand price; Regardless of what the *maxPrice* value, Spot Instances will still be charged at the current spot market price.
{{% /notice %}}

### Confirm the Nodes

{{% notice tip %}}
Aside from familiarizing yourself with the kubectl commands below to obtain the cluster information, you should also explore your cluster using **kube-ops-view** and find out the nodes that were just created.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see the nodes added to the cluster.

```bash
kubectl get nodes
```

You can use the node-labels to identify the lifecycle of the nodes

```bash
kubectl get nodes --label-columns=eks.amazonaws.com/capacityType --selector=type=self-managed-spot | grep SPOT
```

```
ip-192-168-11-135.ap-southeast-1.compute.internal   NotReady   <none>   13s   v1.21.4-eks-033ce7e   SPOT
ip-192-168-78-145.ap-southeast-1.compute.internal   NotReady   <none>   5s    v1.21.4-eks-033ce7e   SPOT
ip-192-168-78-41.ap-southeast-1.compute.internal    NotReady   <none>   12s   v1.21.4-eks-033ce7e   SPOT
```

You can use the `kubectl describe nodes` with one of the spot nodes to see the taints applied to the EC2 Spot Instances.

![Spot Taints](/images/using_ec2_spot_instances_with_eks/spotworkers/spot-self-mng-taint.png)

{{% notice note %}}
Explore your cluster using kube-ops-view and find out the nodes that have just been created.
{{% /notice %}}