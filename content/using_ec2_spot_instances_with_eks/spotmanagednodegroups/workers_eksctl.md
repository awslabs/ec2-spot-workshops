---
title: "Adding Spot Workers with eksctl"
date: 2018-08-07T11:05:19-07:00
weight: 30
draft: false
---

In this section we will deploy the instance types we selected and request nodegroups that adhere to Spot diversification best practices. For that we will use **[eksctl create nodegroup](https://eksctl.io/usage/managing-nodegroups/)** to generate the ClusterConfig file and save the output. The ClusterConfig file will be edited with additional configuration including filtering the instance types, and use the edited eksctl configuration files to add the new nodes to the cluster.

Let's first create the configuration file:

```bash
eksctl create nodegroup \
    --cluster=eksworkshop-eksctl \
    --region=$AWS_REGION \
    --dry-run \
    --managed \
    --spot \
    --name=dev-4vcpu-16gb-spot \
    --instance-selector-vcpus=4 \
    --instance-selector-memory=16 \
    --instance-selector-cpu-architecture=x86_64 \
    --instance-selector-gpus=0 \
    > ~/environment/spot_nodegroup_4vcpu_16gb.yml

eksctl create nodegroup \
    --cluster=eksworkshop-eksctl \
    --region=$AWS_REGION \
    --dry-run \
    --managed \
    --spot \
    --name=dev-8vcpu-32gb-spot \
    --instance-selector-vcpus=8 \
    --instance-selector-memory=32 \
    --instance-selector-cpu-architecture=x86_64 \
    --instance-selector-gpus=0 \
    > ~/environment/spot_nodegroup_8vcpu_32gb.yml
```

This will create 2 files, `spot_nodegroups_4vcpu_16gb.yml` and `spot_nodegroups_8vcpu_32gb.yml`, that we will use to instruct eksctl to create two nodegroups, both with a diversified configuration.

Let's edit the 2 configuration files before using it to create the node groups:

1. Change the **maxSize** to 5.

1. Delete the *d3en*, *h1* and *g4dn* instances from the **instanceTypes**. Leave in only the Instances from M and T families.

1. In the **labels:** section, add the following labels in a new line: **intent: apps**

    We will use this label **intent** to force a hard partition of the cluster for our applications. During this workshop we will deploy control applications on nodes that have been labeled with **intent: control-apps** while our applications get deployed to nodes labeled with **intent: apps**.

1. In the  **tags:** section, add the following tags in a new line: **k8s.io/cluster-autoscaler/node-template/label/intent: apps**

1. Remove the section **instanceSelector:**.

If you are still struggling with the implementation, the solution files is available here

{{%attachments title="Related files" pattern=".yml"/%}}

Create the two node groups:

```bash
eksctl create nodegroup -f spot_nodegroup_4vcpu_16gb.yml
```

```bash
eksctl create nodegroup -f spot_nodegroup_8vcpu_32gb.yml
```

{{% notice note %}}
The creation of the worker nodes will take about 3 minutes.
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these nodegroups.

 * The configuration setup the nodes under the **managedNodeGroups** section. This is to indicate the node group being created is a managed node group.
 * The configuration setup a configuration **spot: true** to indicate that the node group being created is a Spot managed node group, which implies all nodes in the nodegroup would be **Spot instances**.
 * Notice that the configuration setup a **minSize** to 2, **maxSize** to 2 and **desiredCapacity** to 2. Spot managed nodegroups are created with minimum of 2 nodes.
 * Notice that the configuration setup 2 node label under **labels** - **alpha.eksctl.io/cluster-name: : eksworkshop-eksctl** to indicate the node label belongs to **eksworkshop-eksctl** cluster, and **alpha.eksctl.io/nodegroup-name: dev-4vcpu-16gb-spot** node group.

{{% notice info %}}
If you are wondering at this stage: *Where is spot bidding price ?* you are missing some of the changes EC2 Spot instances had since 2017. Since November 2017 [EC2 Spot price changes infrequently](https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/) based on long term supply and demand of spare capacity in each pool independently. You can still set up a **maxPrice** in scenarios where you want to set maximum budget. By default *maxPrice* is set to the On-Demand price; Regardless of what the *maxPrice* value, spot instances will still be charged at the current spot market price.
{{% /notice %}}

### Confirm the Nodes

{{% notice tip %}}
Aside from familiarizing yourself with the kubectl commands below to obtain the cluster information, you should also explore your cluster using **kube-ops-view** and find out the nodes that were just created.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see the nodes added to the cluster.

```bash
kubectl get nodes
```

Managed node groups automatically create a label **eks.amazonaws.com/capacityType** to identify which nodes are Spot Instances and which are On-Demand Instances so that we can schedule the appropriate workloads to run on Spot Instances. You can use this node label to identify the lifecycle of the nodes

```bash
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=SPOT
```

The output of this command should return nodes running on Spot Instances. The output of the command shows the CAPACITYTYPE for the current nodes is set to SPOT.

![Spot Output](/images/using_ec2_spot_instances_with_eks/spotworkers/spot_get_spot.png)

Now we will show all nodes running on On Demand Instances. The output of the command shows the CAPACITYTYPE for the current nodes is set to ON_DEMAND.

```bash
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=ON_DEMAND
```
![OnDemand Output](/images/using_ec2_spot_instances_with_eks/spotworkers/spot_get_od.png)

{{% notice note %}}
Explore your cluster using kube-ops-view and find out the nodes that have just been created.
{{% /notice %}}

